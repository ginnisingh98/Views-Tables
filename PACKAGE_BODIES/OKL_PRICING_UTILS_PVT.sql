--------------------------------------------------------
--  DDL for Package Body OKL_PRICING_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PRICING_UTILS_PVT" AS
/* $Header: OKLRPIUB.pls 120.75.12010000.4 2009/10/06 11:35:52 rgooty ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

  PROCEDURE put_in_log(
              p_debug_enabled         IN VARCHAR2,
              is_debug_procedure_on   IN BOOLEAN,
              is_debug_statement_on   IN BOOLEAN,
              p_module                IN fnd_log_messages.module%TYPE,
              p_level                 IN VARCHAR2,
              msg                     IN VARCHAR2 )
  AS
    -- l_level: S - Statement, P- Procedure, B - Both
  BEGIN
    IF(p_debug_enabled='Y' AND is_debug_procedure_on AND p_level = 'P')
    THEN
        okl_debug_pub.log_debug(
          FND_LOG.LEVEL_PROCEDURE,
          p_module,
          msg);
    ELSIF (p_debug_enabled='Y' AND is_debug_statement_on AND
          (p_level = 'S' OR p_level = 'B' ))
    THEN
        okl_debug_pub.log_debug(
          FND_LOG.LEVEL_STATEMENT,
          p_module,
          msg);
    END IF;
  END put_in_log;

  -- Returns true if the inputed p_year is an leap year
  --  else false
  FUNCTION is_leap_year( p_year IN NUMBER)
    RETURN BOOLEAN
  AS
    l_year    NUMBER(5);
  BEGIN
    IF ( MOD(p_year, 4) = 0 AND MOD(p_year, 100) <> 0  )OR
         MOD(p_year, 400) = 0
    THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  END is_leap_year;

  -- Returns true if the year in the p_date is a leap year
  --   else returns false
  FUNCTION is_leap_year( p_date IN DATE)
    RETURN BOOLEAN
  AS
    l_year    NUMBER(5);
  BEGIN
    l_year := to_number( to_char( p_date, 'YYYY') );
    IF is_leap_year( p_year => l_year )
    THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  END is_leap_year;

  PROCEDURE get_day_count_method(
      p_days_in_month    IN VARCHAR2,
      p_days_in_year     IN VARCHAR2,
      x_day_count_method OUT NOCOPY  VARCHAR2,
      x_return_status    OUT NOCOPY  VARCHAR2 )
  AS
    l_api_name      VARCHAR2(30) := 'get_day_count_method';
  BEGIN
    IF p_days_in_month = '30' AND
       p_days_in_year = '360'
    THEN
      x_day_count_method := 'THIRTY';
    ELSIF p_days_in_month = 'ACTUAL' AND
          p_days_in_year = '365'
    THEN
      x_day_count_method := 'ACT365';
    ELSIF p_days_in_month = 'ACTUAL' AND
          p_days_in_year = 'ACTUAL'
    THEN
      x_day_count_method := 'ACTUAL';
    ELSE
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
    --print( l_api_name || ': ' || 'l_days_in_month= ' || p_days_in_month ||
    --             ' |  l_days_in_year = ' || p_days_in_year);

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  END get_day_count_method;


  PROCEDURE get_days_in_year_and_month(
      p_day_count_method IN         VARCHAR2,
      x_days_in_month    OUT NOCOPY VARCHAR2,
      x_days_in_year     OUT NOCOPY VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2 )
  AS
    l_api_name      VARCHAR2(30) := 'get_days_in_year_and_month';
  BEGIN
    IF  p_day_count_method = 'THIRTY'
    THEN
      x_days_in_month := '30';
      x_days_in_year := '360';
    ELSIF p_day_count_method = 'ACT365'
    THEN
      x_days_in_month := 'ACTUAL';
      x_days_in_year := '365';
    ELSIF p_day_count_method = 'ACTUAL'
    THEN
      x_days_in_month := 'ACTUAL';
      x_days_in_year := 'ACTUAL';
    ELSE
      --print( l_api_name || ': ' || 'p_day_count_method= ' || p_day_count_method );
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
    --print( l_api_name || ': ' || 'l_days_in_month= ' || x_days_in_month ||
    --         ' |  l_days_in_year = ' || x_days_in_year);
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  END get_days_in_year_and_month;

  -- Procedure to fetch the day convention from the OKL_K_RATE_PARAMS
  --  if not found reach the SGT assosiated and fetch the day conventions
  PROCEDURE  get_day_convention(
               p_id              IN          NUMBER,   -- ID of the contract/quote
               p_source          IN          VARCHAR2, -- 'ESG'/'ISG' are acceptable values
               x_days_in_month   OUT NOCOPY  VARCHAR2,
               x_days_in_year    OUT NOCOPY  VARCHAR2,
               x_return_status   OUT NOCOPY  VARCHAR2)
  AS
    l_api_name      VARCHAR2(30) := 'get_day_convention';
    l_return_status               VARCHAR2(1);

    -- Cursor to fetch the day convention from the OKL_K_RATE_PARAMS table ..
    CURSOR day_conv_csr( khrId NUMBER) IS
     SELECT days_in_a_year_code,
            days_in_a_month_code,
            DECODE(rate_params.days_in_a_month_code,'30','360',
                   rate_params.days_in_a_month_code) esg_days_in_month_code
     FROM  OKL_K_RATE_PARAMS rate_params
     WHERE khr_id = khrId;

    -- Cursor to fetch the day convention from the SGT
    CURSOR  get_day_conv_on_sgt_csr( p_khr_id IN VARCHAR2 )
    IS
    SELECT  gts.days_in_month_code days_in_a_month_code,
            gts.days_in_yr_code days_in_a_year_code,
            DECODE(gts.days_in_month_code,'30','360',gts.days_in_month_code)
                  esg_days_in_month_code
    FROM
            okl_k_headers khr,
            okl_products_v pdt,
            okl_ae_tmpt_sets_v aes,
            OKL_ST_GEN_TMPT_SETS gts
    WHERE
            khr.pdt_id = pdt.id AND
            pdt.aes_id = aes.id AND
            aes.gts_id = gts.id AND
            khr.id  = p_khr_id;
   l_days_in_month   VARCHAR2(30);
   l_days_in_year    VARCHAR2(30);
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    l_return_status := G_RET_STS_ERROR;
    FOR t_rec IN day_conv_csr(p_id)
    LOOP
      IF p_source = 'ESG'
      THEN
        l_days_in_month := t_rec.esg_days_in_month_code;
      ELSE
        l_days_in_month := t_rec.days_in_a_month_code;
      END IF;
      l_days_in_year := t_rec.days_in_a_year_code;
      l_return_status := G_RET_STS_SUCCESS;
    END LOOP;
    -- Bug 4960625: Start
    -- If there is a record present in the OKL_K_RATE_PARAMS for the corresponding
    --  Contract, but the Day conventions are null there, then fetch the Day conventions
    --  from the Stream Generation Template.
    IF l_days_in_month IS NULL OR
       l_days_in_year IS NULL
    THEN
      l_return_status := G_RET_STS_ERROR;
    END IF;
    -- Bug 4960625: End
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'Tried fetching the day convention from OKL_K_RATE_PARAMS ' || l_return_status );
    END IF;
    IF l_return_status <> G_RET_STS_SUCCESS
    THEN
      -- Fetch the day convention from the SGT assosiated to the contract
      FOR t_rec IN get_day_conv_on_sgt_csr( p_khr_id => p_id )
      LOOP
        IF p_source = 'ESG'
        THEN
          l_days_in_month := t_rec.esg_days_in_month_code;
        ELSE
          l_days_in_month := t_rec.days_in_a_month_code;
        END IF;
        l_days_in_year  := t_rec.days_in_a_year_code;
        l_return_status := G_RET_STS_SUCCESS;
      END LOOP;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'Tried fetching the day convention from SGT ' || l_return_status );
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'Month / Year = ' || l_days_in_month || '/' || l_days_in_year );
    END IF;
    IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Return the values
    x_days_in_month := l_days_in_month;
    x_days_in_year  := l_days_in_year;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_DB_ERROR,
        p_token1       => G_PROG_NAME_TOKEN,
        p_token1_value => l_api_name,
        p_token2       => G_SQLCODE_TOKEN,
        p_token2_value => sqlcode,
        p_token3       => G_SQLERRM_TOKEN,
        p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END get_day_convention;


  -- Get the Quick Quote Header Details
  PROCEDURE  get_so_hdr(
                p_api_version       IN  NUMBER,
                p_init_msg_list     IN  VARCHAR2,
                x_return_status     OUT NOCOPY VARCHAR2,
                x_msg_count         OUT NOCOPY NUMBER,
                x_msg_data          OUT NOCOPY VARCHAR2,
                p_so_id             IN  NUMBER,
                p_so_type           IN  VARCHAR2,
                x_so_hdr_rec        OUT NOCOPY so_hdr_rec_type )
  AS
    CURSOR so_qq_hdr_csr( p_qq_id IN NUMBER )
    IS
      SELECT   ID
              ,REFERENCE_NUMBER
              ,EXPECTED_START_DATE
              ,CURRENCY_CODE
              ,TERM
              ,SALES_TERRITORY_ID
              ,END_OF_TERM_OPTION_ID
              ,PRICING_METHOD
              ,STRUCTURED_PRICING
              ,LINE_LEVEL_PRICING
              ,LEASE_RATE_FACTOR
              ,RATE_CARD_ID
              ,RATE_TEMPLATE_ID
              ,TARGET_RATE_TYPE
              ,TARGET_RATE
              ,TARGET_AMOUNT    -- Need to solve for this amount only ...!
              ,TARGET_FREQUENCY
              ,TARGET_ARREARS
              ,TARGET_PERIODS
        FROM  OKL_QUICK_QUOTES_B
        WHERE ID = p_qq_id;
    l_so_hdr_rec        so_hdr_rec_type;
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_so_hdr';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.OKL_PRICING_UTILS_PVT.get_so_hdr';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRPIUB.pls call get_so_hdr');
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- Call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              ': p_so_type =' || p_so_type );
   put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              ': p_so_id =' || p_so_id );
    IF (p_so_type = 'QQ')
    THEN
      -- Fetch the Header Information from the so_qq_hdr_csr
      FOR t_rec in so_qq_hdr_csr(p_qq_id => p_so_id)
      LOOP
        l_so_hdr_rec.id                     := t_rec.id;
        l_so_hdr_rec.so_type                := 'QQ';
        l_so_hdr_rec.reference_number       := t_rec.reference_number ;
        l_so_hdr_rec.expected_start_date    := t_rec.expected_start_date ;
        l_so_hdr_rec.currency_code          := t_rec.currency_code ;
        l_so_hdr_rec.term                   := t_rec.term ;
        l_so_hdr_rec.sales_territory_id     := t_rec.sales_territory_id;
        l_so_hdr_rec.end_of_term_option_id  := t_rec.end_of_term_option_id ;
        l_so_hdr_rec.pricing_method         := t_rec.pricing_method;
        l_so_hdr_rec.structured_pricing     := t_rec.structured_pricing;
        l_so_hdr_rec.line_level_pricing     := t_rec.line_level_pricing;
        l_so_hdr_rec.lease_rate_factor      := t_rec.lease_rate_factor;
        l_so_hdr_rec.rate_card_id           := t_rec.rate_card_id ;
        l_so_hdr_rec.rate_template_id       := t_rec.rate_template_id ;
        l_so_hdr_rec.target_rate_type       := t_rec.target_rate_type ;
        l_so_hdr_rec.target_rate            := t_rec.target_rate ;
        l_so_hdr_rec.target_amount          := t_rec.target_amount ;
        l_so_hdr_rec.target_frequency       := t_rec.target_frequency ;
        l_so_hdr_rec.target_arrears         := t_rec.target_arrears ;
        l_so_hdr_rec.target_periods         := t_rec.target_periods;
      END LOOP;
    ELSIF p_so_type = 'SQ'
    THEN
      -- Code to be written for handling the Standard Quote
      NULL;
    ELSE
      -- Code to be written for raising an exception
      OKL_API.SET_MESSAGE(  p_app_name     => g_app_name,
                            p_msg_name     => g_invalid_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'QQ_ID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_so_hdr_rec := l_so_hdr_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count, x_msg_data        => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call get_so_hdr');
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             p_api_name  => l_api_name,
                             p_pkg_name  => G_PKG_NAME,
                             p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                             x_msg_count => x_msg_count,
                             x_msg_data  => x_msg_data,
                             p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            p_api_name  => l_api_name,
                            p_pkg_name  => G_PKG_NAME,
                            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                            x_msg_count => x_msg_count,
                            x_msg_data  => x_msg_data,
                            p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            p_api_name  => l_api_name,
                            p_pkg_name  => G_PKG_NAME,
                            p_exc_name  => 'OTHERS',
                            x_msg_count => x_msg_count,
                            x_msg_data  => x_msg_data,
                            p_api_type  => g_api_type);
  END get_so_hdr;
  -- Procedure to return the Days Per Period and Periods Per Year
  -- This api is based on the day convention of THIRTY only !
  -- so for x_dpp the possible return values are 30, 90, 180. 360 only.
  PROCEDURE get_dpp_ppy(
             p_frequency            IN  VARCHAR2,
             x_dpp                  OUT NOCOPY NUMBER,
             x_ppy                  OUT NOCOPY NUMBER,
             x_return_status        OUT NOCOPY VARCHAR2)
  IS
    l_api_name VARCHAR2(30):= 'get_dpp_ppy';
  BEGIN
    IF p_frequency = 'M'
    THEN
      -- Monthly
      x_dpp := 30;
      x_ppy := 12;
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      RETURN;
    ELSIF p_frequency = 'Q'
    THEN
      -- Quarterly
      x_dpp := 90;
      x_ppy := 4;
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      RETURN;
    ELSIF p_frequency = 'S'
    THEN
      -- Semi Anually
      x_dpp := 180;
      x_ppy := 2;
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      RETURN;
    ELSIF p_frequency = 'A'
    THEN
      -- Annually
      x_dpp := 360;
      x_ppy := 1;
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      RETURN;
    ELSE
      -- Raise an Exception
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_DB_ERROR,
        p_token1       => G_PROG_NAME_TOKEN,
        p_token1_value => l_api_name,
        p_token2       => G_SQLCODE_TOKEN,
        p_token2_value => sqlcode,
        p_token3       => G_SQLERRM_TOKEN,
        p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END get_dpp_ppy;

  -- API to get the Item Category Details for a particular quick quote
  PROCEDURE  get_qq_item_cat_details(
              p_api_version         IN             NUMBER,
              p_init_msg_list       IN             VARCHAR2,
              x_return_status       OUT NOCOPY     VARCHAR2,
              x_msg_count           OUT NOCOPY     NUMBER,
              x_msg_data            OUT NOCOPY     VARCHAR2,
              p_qq_id               IN             NUMBER,
              p_pricing_method      IN             VARCHAR2,
              x_asset_amounts_tbl   OUT NOCOPY     so_asset_details_tbl_type)
  AS
    -- Cursor Declarations
    CURSOR item_cat_csr( p_qq_id NUMBER )
    IS
      SELECT  value
             ,basis
             ,nvl(nvl(end_of_term_value, end_of_term_value_default), 0) end_of_term_amount
             ,percentage_of_total_cost
       FROM  OKL_QUICK_QUOTE_LINES_B qql
      WHERE  qql.quick_quote_id = p_qq_id
        AND  TYPE = G_ITEMCATEGORY_TYPE; -- Item Category Type
    -- Cursor to fetch the EOT Type
    CURSOR get_eot_type( p_qq_id NUMBER )
    IS
      SELECT  qq.id
         ,qq.reference_number
         ,eot.end_of_term_name
         ,eot.eot_type_code eot_type_code
         ,eot.end_of_term_id end_of_term_id
         ,eotversion.end_of_term_ver_id
     FROM OKL_QUICK_QUOTES_B qq,
          okl_fe_eo_term_vers eotversion,
          okl_fe_eo_terms_all_b eot
     WHERE qq.END_OF_TERM_OPTION_ID = eotversion.end_of_term_ver_id
       AND eot.end_of_term_id = eotversion.end_of_term_id
       AND qq.id = p_qq_id;
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_qq_item_cat_details';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Variables Declaration
    l_asset_amounts_tbl           so_asset_details_tbl_type;
    ic_index                      NUMBER;
    l_eot_type_code               VARCHAR2(30);
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               ': p_qq_id =' || p_qq_id );
    -- Know the type of the EOT and then proceed with the values directly or calculate the amount
    FOR t_rec IN get_eot_type( p_qq_id => p_qq_id  )
    LOOP
      l_eot_type_code := t_rec.eot_type_code;
    END LOOP;
    ic_index := 1;
    FOR t_rec in item_cat_csr( p_qq_id => p_qq_id )
    LOOP
      -- Store the Item Category Details in the Item Categories Table also
      IF p_pricing_method = 'SF' -- Solve for Financed Amount
      THEN
        l_asset_amounts_tbl(ic_index).asset_cost := NULL;
      ELSE
        l_asset_amounts_tbl(ic_index).asset_cost := t_rec.value;
      END IF;
      l_asset_amounts_tbl(ic_index).value := t_rec.value;
      l_asset_amounts_tbl(ic_index).basis := t_rec.basis;
      l_asset_amounts_tbl(ic_index).percentage_of_total_cost := t_rec.percentage_of_total_cost;
      IF l_eot_type_code = 'AMOUNT' OR l_eot_type_code = 'RESIDUAL_AMOUNT'
      THEN
        -- End of Term Amounts has been directly mentioned in this case
        l_asset_amounts_tbl(ic_index).end_of_term_amount := t_rec.end_of_term_amount;
      ELSIF ( l_eot_type_code = 'PERCENT' OR l_eot_type_code = 'RESIDUAL_PERCENT' )
      THEN
        -- End of Term Amounts are entered in terms of percentage here
        IF p_pricing_method = 'SF'
        THEN
          -- Store the equivalent percentage of the EOT Amount interms of percentage only.
          -- Note: Both percentage_of_total_cost and end_of_term_amount are
          --       stored in terms of percentage
          l_asset_amounts_tbl(ic_index).end_of_term_amount :=
            (t_rec.percentage_of_total_cost / 100 ) * (t_rec.end_of_term_amount /100);
        ELSE
          -- Apply the End of Term Percentage on the Asset Cost to get the EOT Amount
          l_asset_amounts_tbl(ic_index).end_of_term_amount :=
           t_rec.end_of_term_amount * t_rec.value / 100;
        END IF;
      END IF;
      -- Increment the ic_index
      ic_index := ic_index + 1;
    END LOOP;
    -- Setting up the return variables
    x_asset_amounts_tbl := l_asset_amounts_tbl;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_qq_item_cat_details;

  PROCEDURE get_qq_asset_oec (
              p_api_version          IN  NUMBER,
              p_init_msg_list        IN  VARCHAR2,
              x_return_status        OUT NOCOPY VARCHAR2,
              x_msg_count            OUT NOCOPY NUMBER,
              x_msg_data             OUT NOCOPY VARCHAR2,
              p_asset_cost           IN  NUMBER,
              p_fin_adj_det_rec      IN  so_amt_details_rec_type,
              x_oec                  OUT NOCOPY NUMBER)
  AS
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_qq_asset_oec';
    l_return_status               VARCHAR2(1);

    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

    l_oec                    NUMBER;
    l_item_cat_percent       NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',':Start ' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S', 'p_asset_cost=' || p_asset_cost );

    l_oec := p_asset_cost;
    l_item_cat_percent := 0;
    -- Dealing with the downpayment amount
    IF p_fin_adj_det_rec.down_payment_basis = G_FIXED_BASIS
    THEN
      l_oec := l_oec - p_fin_adj_det_rec.down_payment_amount;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Down Payment Amount= '||  p_fin_adj_det_rec.down_payment_amount );
    ELSIF p_fin_adj_det_rec.down_payment_basis = G_QQ_ASSET_COST_BASIS
    THEN
      l_item_cat_percent := nvl(l_item_cat_percent, 0 ) + p_fin_adj_det_rec.down_payment_value;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Down payment percentage ' || p_fin_adj_det_rec.down_payment_value );
    END IF;
    IF p_fin_adj_det_rec.tradein_basis = G_FIXED_BASIS
    THEN
      l_oec := l_oec - p_fin_adj_det_rec.tradein_amount;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Trade-in Amount= '||  p_fin_adj_det_rec.tradein_amount );
    ELSIF p_fin_adj_det_rec.tradein_basis = G_QQ_ASSET_COST_BASIS
    THEN
      l_item_cat_percent := nvl(l_item_cat_percent, 0 ) + p_fin_adj_det_rec.tradein_value;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Trade-in %age = ' || p_fin_adj_det_rec.tradein_value );
    END IF;
    IF p_fin_adj_det_rec.subsidy_basis_tbl IS NOT NULL AND
       p_fin_adj_det_rec.subsidy_basis_tbl.COUNT > 0
    THEN
      FOR t in p_fin_adj_det_rec.subsidy_basis_tbl.FIRST ..
               p_fin_adj_det_rec.subsidy_basis_tbl.LAST
      LOOP
        IF p_fin_adj_det_rec.subsidy_basis_tbl(t) = G_FIXED_BASIS
        THEN
          l_oec := l_oec - p_fin_adj_det_rec.subsidy_value_tbl(t);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Subsidy Amount(' || t || ')= '||  p_fin_adj_det_rec.subsidy_value_tbl(t) );
        ELSIF p_fin_adj_det_rec.subsidy_basis_tbl(t) = G_QQ_ASSET_COST_BASIS
        THEN
          l_item_cat_percent := nvl(l_item_cat_percent, 0 ) + p_fin_adj_det_rec.subsidy_value_tbl(t);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Subsidy(' || t || ') %age =' || p_fin_adj_det_rec.subsidy_value_tbl(t) );
        END IF;
      END LOOP;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'l_item_cat_percent=' || nvl( l_item_cat_percent,0) );
    -- Calculate the final OEC of the Asset !
    l_oec := l_oec - ( p_asset_cost * l_item_cat_percent / 100 );
    IF l_oec > 0
    THEN
      -- Valid! Do Nothing!
      NULL;
    ELSE
      -- Item OEC should be greater than zero !
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 ' Asset OEC should be greater than zero !! p_asset_cost= '|| p_asset_cost );
      -- Show an error Message OKL_LP_FIN_ADJ_AMT_LESS
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKL_LP_FIN_ADJ_AMT_LESS');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Setting up the retun values
    x_oec := l_oec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
         WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_qq_asset_oec;

  -- API to get the Capital Cost, Subsidy Amount,
  -- Down Payment Amount, Trade in Amount for a particular Quick Quote
  -- Accepts quick quote id
  PROCEDURE  get_qq_fin_adj_details(
              p_api_version          IN  NUMBER,
              p_init_msg_list        IN  VARCHAR2,
              x_return_status        OUT NOCOPY VARCHAR2,
              x_msg_count            OUT NOCOPY NUMBER,
              x_msg_data             OUT NOCOPY VARCHAR2,
              p_qq_id                IN  NUMBER,
              p_pricing_method       IN  VARCHAR2,
              p_item_category_amount IN  NUMBER,
              x_all_amounts_rec      OUT NOCOPY so_amt_details_rec_type)
  AS
    -- Cursor to fetch the Quick Quote Financial Adjustment Details
    --  like Down Payment, Tradein, Subsidy
    CURSOR fin_adj_csr( p_qq_id NUMBER )
    IS
      SELECT  type
             ,basis
             ,value
       FROM  OKL_QUICK_QUOTE_LINES_B qql
      WHERE  qql.quick_quote_id = p_qq_id
        AND  TYPE IN ( G_DOWNPAYMENT_TYPE,  -- Down Payment Type
                       G_TRADEIN_TYPE,      -- Trade in Type
                       G_SUBSIDY_TYPE       -- Subsidy Type
                     )
      ORDER BY TYPE;
    -- Local Variables
    l_all_amounts_rec                 so_amt_details_rec_type;
    l_api_version          CONSTANT   NUMBER          DEFAULT 1.0;
    l_api_name             CONSTANT   VARCHAR2(30)    DEFAULT 'get_qq_fin_adj_details';
    l_return_status                   VARCHAR2(1);
    l_module               CONSTANT   fnd_log_messages.module%TYPE
                                             := 'LEASE.ACCOUNTING.PRICING.OKL_PRICING_UTILS_PVT.get_qq_fin_adjustments';
    l_debug_enabled                   VARCHAR2(10);
    is_debug_procedure_on             BOOLEAN;
    is_debug_statement_on             BOOLEAN;

    sub_index                         NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRPIUB.pls call get_qq_fin_adjustments');
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- Call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',':Start ' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',' p_qq_id   : '  || p_qq_id);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',' p_pricing_method : '  || p_pricing_method  );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',' p_item_category_amount ' ||  p_item_category_amount);
    sub_index := 1;
    FOR t_rec in fin_adj_csr( p_qq_id => p_qq_id )
    LOOP
      IF t_rec.type = G_DOWNPAYMENT_TYPE
      THEN
        l_all_amounts_rec.down_payment_basis := t_rec.basis;
        l_all_amounts_rec.down_payment_value := t_rec.value;
      ELSIF t_rec.type = G_SUBSIDY_TYPE
      THEN
        l_all_amounts_rec.subsidy_basis_tbl(sub_index) := t_rec.basis;
        l_all_amounts_rec.subsidy_value_tbl(sub_index) := t_rec.value;
        -- Increment the sub_index
        sub_index := sub_index + 1;
      ELSIF t_rec.type = G_TRADEIN_TYPE
      THEN
        l_all_amounts_rec.tradein_basis := t_rec.basis;
        l_all_amounts_rec.tradein_value := t_rec.value;
      END IF;
    END LOOP;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               ' Looped on fin_adj_csr successfully ! ' );
    -- Basis for Down Payment/Subsidy/Trade can be
    --    FIXED      : Amount directly
    --    ASSET_COST : Percentage of Asset Cost
    IF l_all_amounts_rec.down_payment_basis = G_FIXED_BASIS
    THEN
      -- Store the downpayment value directly in the downpayment_amount
      l_all_amounts_rec.down_payment_amount := l_all_amounts_rec.down_payment_value;
    ELSE
      -- Basis will be ASSET_COST, so apply the %age in the value on the total items cost
      IF p_pricing_method <> 'SF'
      THEN
        l_all_amounts_rec.down_payment_amount :=
            p_item_category_amount * l_all_amounts_rec.down_payment_value / 100;
      ELSE
        -- What to do in this case
        NULL;
      END IF;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               ' Down Payment Details: Basis=' || l_all_amounts_rec.down_payment_basis
               || ' | Value=' || l_all_amounts_rec.down_payment_value
               || ' Amount=' || l_all_amounts_rec.down_payment_amount );
    IF l_all_amounts_rec.subsidy_basis_tbl IS NOT NULL AND
       l_all_amounts_rec.subsidy_basis_tbl.COUNT > 0
    THEN
      FOR t IN l_all_amounts_rec.subsidy_basis_tbl.FIRST ..
               l_all_amounts_rec.subsidy_basis_tbl.LAST
      LOOP
        IF l_all_amounts_rec.subsidy_basis_tbl(t) = G_FIXED_BASIS
        THEN
          -- Store the downpayment value directly in the downpayment_amount
          l_all_amounts_rec.subsidy_amount := nvl(l_all_amounts_rec.subsidy_amount, 0 ) +
                                                  l_all_amounts_rec.subsidy_value_tbl(t);
        ELSE
          IF p_pricing_method <> 'SF'
          THEN
            l_all_amounts_rec.subsidy_amount := nvl(l_all_amounts_rec.subsidy_amount, 0 ) +
                (p_item_category_amount * l_all_amounts_rec.subsidy_value_tbl(t) / 100 );
          ELSE
            -- What to do in this case
            NULL;
          END IF;
        END IF;  -- IF l_all_amounts_rec.subsidy_basis = G_FIXED_BASIS
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   ' Subsidy Details: Basis=' || l_all_amounts_rec.subsidy_basis_tbl(t)
                   || ' | Value=' || l_all_amounts_rec.subsidy_value_tbl(t)
                   || ' Amount=' || l_all_amounts_rec.subsidy_amount );
      END LOOP; -- Loop on the Subsidy Table
    END IF;

    IF l_all_amounts_rec.tradein_basis = G_FIXED_BASIS
    THEN
      -- Store the downpayment value directly in the downpayment_amount
      l_all_amounts_rec.tradein_amount := l_all_amounts_rec.tradein_value;
    ELSE
      IF p_pricing_method <> 'SF'
      THEN
        l_all_amounts_rec.tradein_amount :=
            p_item_category_amount * l_all_amounts_rec.tradein_value / 100;
      ELSE
        -- What to do in this case
        NULL;
      END IF;
    END IF; --IF l_all_amounts_rec.tradein_basis = G_FIXED_BASIS
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              ' Trade-in Details: Basis=' || l_all_amounts_rec.tradein_basis
             || ' | Value=' || l_all_amounts_rec.tradein_value
             || ' Amount=' || l_all_amounts_rec.tradein_amount );
    -- Return the values ..
    x_all_amounts_rec    := l_all_amounts_rec;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               l_api_name || ':End ' );
    x_return_status      := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count, x_msg_data        => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'end debug OKLRPIUB.pls call get_qq_details');
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             p_api_name  => l_api_name,
                             p_pkg_name  => G_PKG_NAME,
                             p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                             x_msg_count => x_msg_count,
                             x_msg_data  => x_msg_data,
                             p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            p_api_name  => l_api_name,
                            p_pkg_name  => G_PKG_NAME,
                            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                            x_msg_count => x_msg_count,
                            x_msg_data  => x_msg_data,
                            p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            p_api_name  => l_api_name,
                            p_pkg_name  => G_PKG_NAME,
                            p_exc_name  => 'OTHERS',
                            x_msg_count => x_msg_count,
                            x_msg_data  => x_msg_data,
                            p_api_type  => g_api_type);
  END get_qq_fin_adj_details;

  PROCEDURE get_qq_sgt_day_convention(
                p_api_version       IN  NUMBER,
                p_init_msg_list     IN  VARCHAR2,
                x_return_status     OUT NOCOPY VARCHAR2,
                x_msg_count         OUT NOCOPY NUMBER,
                x_msg_data          OUT NOCOPY VARCHAR2,
                p_qq_id                IN NUMBER,
                x_days_in_month        OUT NOCOPY VARCHAR2,
                x_days_in_year         OUT NOCOPY VARCHAR2)
  AS
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_qq_sgt_day_convention';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Cursor declarations
    CURSOR get_sgt_day_convention_csr( p_qq_id   NUMBER )
    IS
      SELECT gts.days_in_month_code days_in_month,
             gts.days_in_yr_code days_in_year,
             gts.id  gts_id,
             pdt.id  pdt_id
      FROM  okl_fe_eo_terms_all_b eot
           ,okl_fe_eo_term_vers eov
           ,okl_quick_quotes_b qqh
           ,okl_products pdt
           ,okl_ae_tmpt_sets aes
           ,okl_st_gen_tmpt_sets gts
      WHERE qqh.end_of_term_option_id = eov.end_of_term_ver_id
        AND eov.end_of_term_id = eot.end_of_term_id
        AND eot.product_id = pdt.id
        AND pdt.aes_id = aes.id
        AND aes.gts_id = gts.id
        AND qqh.id = p_qq_id;
    get_sgt_day_convention_rec   get_sgt_day_convention_csr%ROWTYPE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Fetch the day convention from the SGT assosiated to the QQ ..
    l_return_status := OKL_API.G_RET_STS_ERROR;
    FOR t_rec IN get_sgt_day_convention_csr( p_qq_id => p_qq_id )
    LOOP
      get_sgt_day_convention_rec := t_rec;
      l_return_status := OKL_API.G_RET_STS_SUCCESS;
    END LOOP;
    IF l_return_status = OKL_API.G_RET_STS_ERROR
    THEN
      -- Show the error message and then error out ..
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Unable to pick the day convention from the SGT ');
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKL_LP_INVALID_SGT');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Return the Days per month n Year ..
    x_days_in_month := get_sgt_day_convention_rec.days_in_month;
    x_days_in_year  := get_sgt_day_convention_rec.days_in_year;
    -- Return the status ..
    x_return_status      := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_qq_sgt_day_convention;

 PROCEDURE get_lq_sgt_day_convention(
                p_api_version       IN  NUMBER,
                p_init_msg_list     IN  VARCHAR2,
                x_return_status     OUT NOCOPY VARCHAR2,
                x_msg_count         OUT NOCOPY NUMBER,
                x_msg_data          OUT NOCOPY VARCHAR2,
                p_lq_id                IN NUMBER,
                x_days_in_month        OUT NOCOPY VARCHAR2,
                x_days_in_year         OUT NOCOPY VARCHAR2)
  AS
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_lq_sgt_day_convention';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Cursor declarations
    CURSOR get_sgt_day_convention_csr( p_lq_id   NUMBER )
    IS
      SELECT gts.days_in_month_code days_in_month,
             gts.days_in_yr_code days_in_year,
             gts.id  gts_id,
             pdt.id  pdt_id
      FROM  okl_lease_quotes_b lqh
           ,okl_products pdt
           ,okl_ae_tmpt_sets aes
           ,okl_st_gen_tmpt_sets gts
      WHERE lqh.product_id = pdt.id
        AND pdt.aes_id = aes.id
        AND aes.gts_id = gts.id
        AND lqh.id = p_lq_id;
    get_sgt_day_convention_rec   get_sgt_day_convention_csr%ROWTYPE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Fetch the day convention from the SGT assosiated to the QQ ..
    l_return_status := OKL_API.G_RET_STS_ERROR;
    FOR t_rec IN get_sgt_day_convention_csr( p_lq_id => p_lq_id )
    LOOP
      get_sgt_day_convention_rec := t_rec;
      l_return_status := OKL_API.G_RET_STS_SUCCESS;
    END LOOP;
    IF l_return_status = OKL_API.G_RET_STS_ERROR
    THEN
      -- Show the error message and then error out ..
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Unable to pick the day convention from the SGT ');
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKL_LP_INVALID_SGT');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Return the Days per month n Year ..
    x_days_in_month := get_sgt_day_convention_rec.days_in_month;
    x_days_in_year  := get_sgt_day_convention_rec.days_in_year;
    -- Return the status ..
    x_return_status      := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_lq_sgt_day_convention;

  -- API to get the Cash flows and Cash Flow Levels for Quick Quote
  --  when the pricing option is STRUCTURED PRICING
  PROCEDURE  get_qq_cash_flows(
              p_api_version          IN  NUMBER,
              p_init_msg_list        IN  VARCHAR2,
              x_return_status        OUT NOCOPY VARCHAR2,
              x_msg_count            OUT NOCOPY NUMBER,
              x_msg_data             OUT NOCOPY VARCHAR2,
              p_cf_source_type       IN  VARCHAR2,
              p_qq_id                IN  NUMBER,  -- Can be QQ/LQ/Asset ID/Fee ID Id ..
              x_days_in_month        OUT NOCOPY VARCHAR2,
              x_days_in_year         OUT NOCOPY VARCHAR2,
              x_cash_flow_rec        OUT NOCOPY so_cash_flows_rec_type,
              x_cash_flow_det_tbl    OUT NOCOPY so_cash_flow_details_tbl_type)
  AS
    -- Cursor Declarations
    -- Cursor to fetch the Quick Quotes Cash Flow Details
    CURSOR qq_cash_flows_csr( p_qq_id NUMBER )
    IS
      SELECT   cf.id  caf_id
              ,dnz_khr_id khr_id
              ,dnz_qte_id qte_id
              ,cfo_id cfo_id
              ,sts_code sts_code
              ,sty_id sty_id
              ,cft_code cft_code
              ,due_arrears_yn due_arrears_yn
              ,start_date start_date
              ,number_of_advance_periods number_of_advance_periods
              ,oty_code oty_code
      FROM    OKL_CASH_FLOWS         cf,
              OKL_CASH_FLOW_OBJECTS  cfo
     WHERE    cf.cfo_id = cfo.id
       AND    cfo.source_table = p_cf_source_type
       AND    cfo.source_id = p_qq_id
       AND    cf.sts_code = 'CURRENT';
    -- Cursor to fetch the Cash Flow Details
    CURSOR qq_cash_flow_levels_csr( p_caf_id NUMBER )
    IS
      SELECT  id cfl_id
             ,caf_id
             ,fqy_code
             ,rate  -- No rate is defined at Cash Flows Level.. Need to confirm
             ,stub_days
             ,stub_amount
             ,number_of_periods
             ,amount
             ,start_date
        FROM OKL_CASH_FLOW_LEVELS
       WHERE caf_id = p_caf_id
      ORDER BY start_date;
    -- Cursor Declarations for fetching the Lease Quote ID
    CURSOR get_ass_lq_id_csr( p_ast_id NUMBER )
    IS
      SELECT  ast.parent_object_id lq_id
        FROM  okl_assets_b ast
       WHERE  ast.id = p_ast_id;
    CURSOR get_fee_lq_id_csr( p_fee_id NUMBER )
    IS
      SELECT fee.parent_object_id lq_id
       FROM  okl_fees_b fee
      WHERE  fee.id = p_fee_id;

    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_qq_cash_flows';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Declarations
    l_cash_flow_rec        so_cash_flows_rec_type;
    l_cash_flow_det_tbl    so_cash_flow_details_tbl_type;
    cfl_index              NUMBER;
    l_qq_id                NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- Call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Use l_return_status as a flag
    -- Fetching the Cash Flows Information
    l_return_status := OKL_API.G_RET_STS_ERROR;
    FOR t_rec in qq_cash_flows_csr( p_qq_id )
    LOOP
      l_cash_flow_rec.caf_id   := t_rec.caf_id;
      l_cash_flow_rec.khr_id   := t_rec.khr_id;
      l_cash_flow_rec.khr_id   := t_rec.khr_id;
      l_cash_flow_rec.qte_id   := t_rec.qte_id;
      l_cash_flow_rec.cfo_id   := t_rec.cfo_id;
      l_cash_flow_rec.sts_code := t_rec.sts_code;
      l_cash_flow_rec.sty_id   := t_rec.sty_id;
      l_cash_flow_rec.cft_code := t_rec.cft_code;
      l_cash_flow_rec.due_arrears_yn := t_rec.due_arrears_yn;
      l_cash_flow_rec.start_date     := t_rec.start_date;
      l_cash_flow_rec.number_of_advance_periods := t_rec.number_of_advance_periods;
      -- Use l_retun_status as a flag
      l_return_status := OKL_API.G_RET_STS_SUCCESS;
    END LOOP;
    -- Fetch the Cash Flow Levels information only if the Cash Flow is present..
    IF l_return_status = OKL_API.G_RET_STS_SUCCESS
    THEN
      cfl_index := 1;
      -- Cash Flows exists. So, fetch the Cash Flow Levels
      FOR t_rec in qq_cash_flow_levels_csr( l_cash_flow_rec.caf_id )
      LOOP
        l_cash_flow_det_tbl(cfl_index).cfl_id   := t_rec.cfl_id;
        l_cash_flow_det_tbl(cfl_index).caf_id   := t_rec.caf_id;
        l_cash_flow_det_tbl(cfl_index).fqy_code   := t_rec.fqy_code;
        l_cash_flow_det_tbl(cfl_index).rate       := t_rec.rate;
        l_cash_flow_det_tbl(cfl_index).stub_days   := t_rec.stub_days;
        l_cash_flow_det_tbl(cfl_index).stub_amount   := t_rec.stub_amount;
        l_cash_flow_det_tbl(cfl_index).number_of_periods   := t_rec.number_of_periods;
        l_cash_flow_det_tbl(cfl_index).amount := t_rec.amount;
        l_cash_flow_det_tbl(cfl_index).start_date := t_rec.start_date;
        -- Remember the flag whether its a stub payment or not
        IF t_rec.stub_days IS NOT NULL --and t_rec.stub_amount IS NOT NULL
        THEN
          -- Stub Payment
          l_cash_flow_det_tbl(cfl_index).is_stub := 'Y';
        ELSE
          -- Regular Periodic Payment
          l_cash_flow_det_tbl(cfl_index).is_stub := 'N';
        END IF;
        -- Use l_retun_status as a flag
        l_return_status := OKL_API.G_RET_STS_SUCCESS;
        -- Increment i
        cfl_index := cfl_index + 1;
      END LOOP;
    ELSE
      l_return_status := OKL_API.G_RET_STS_SUCCESS;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'p_cf_source_type =' || p_cf_source_type || 'p_qq_id = ' || p_qq_id);
    IF p_cf_source_type =  G_CF_SOURCE_QQ-- Quick Quote
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Fetching Quick Quote Day convention from the SGT' );
      -- Fetch the day convention from the Stream Generation Template ...
      get_qq_sgt_day_convention(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_qq_id             => p_qq_id,
        x_days_in_month     => x_days_in_month,
        x_days_in_year      => x_days_in_year);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'After get_qq_sgt_day_convention ' || l_return_status );
    ELSIF p_cf_source_type = G_CF_SOURCE_LQ OR-- Lease Quote
          p_cf_source_type = G_CF_SOURCE_LQ_ASS OR
          p_cf_source_type = G_CF_SOURCE_LQ_FEE
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Fetching Lease Quote Day convention from the SGT' );
      l_qq_id := p_qq_id;
      IF  p_cf_source_type = G_CF_SOURCE_LQ_ASS
      THEN
        FOR t_rec IN get_ass_lq_id_csr( p_ast_id => l_qq_id )
        LOOP
          l_qq_id := t_rec.lq_id;
        END LOOP;
      ELSIF p_cf_source_type = G_CF_SOURCE_LQ_FEE
      THEN
        FOR t_rec IN get_fee_lq_id_csr( p_fee_id => l_qq_id )
        LOOP
          l_qq_id := t_rec.lq_id;
        END LOOP;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Fetched Lease Qutoe ID  ' || l_qq_id );
      get_lq_sgt_day_convention(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_lq_id             => l_qq_id,
        x_days_in_month     => x_days_in_month,
        x_days_in_year      => x_days_in_year);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'After get_lq_sgt_day_convention ' || l_return_status );
    END IF;
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 x_days_in_month || ' / ' || x_days_in_year);
    -- Setting the return variables ..
    x_cash_flow_rec      := l_cash_flow_rec;
    x_cash_flow_det_tbl  := l_cash_flow_det_tbl;
    x_return_status      := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_qq_cash_flows;

  -- API to get the Cash flows and Cash Flow Levels for Fees and Services
  PROCEDURE  get_fee_srvc_cash_flows(
              p_api_version          IN  NUMBER,
              p_init_msg_list        IN  VARCHAR2,
              x_return_status        OUT NOCOPY VARCHAR2,
              x_msg_count            OUT NOCOPY NUMBER,
              x_msg_data             OUT NOCOPY VARCHAR2,
              p_hdr_rec              IN  so_hdr_rec_type,
              p_tot_item_cat_cost    IN  NUMBER,
              p_tot_rent_payment     IN  NUMBER,
              x_fee_srv_tbl          OUT NOCOPY so_fee_srv_tbl_type)
  AS
    -- Cursor Declarations
    -- Cursor to fetch the Fees and Services Details !!
    --  like Expenses, Fee Payments, Services, Tax and Insurance !
    CURSOR fee_n_service_csr( p_qq_id NUMBER )
    IS
      SELECT  qql.id    qq_line_id
             ,qql.type  type
             ,qql.basis basis
             ,qql.value value
       FROM  OKL_QUICK_QUOTE_LINES_B qql
      WHERE  qql.quick_quote_id = p_qq_id
        AND  TYPE IN (G_QQ_FEE_EXPENSE,
                      G_QQ_FEE_PAYMENT)
      ORDER BY TYPE;
    -- Cursor to fetch the Quick Quotes Cash Flow Details
    CURSOR qq_cash_flows_csr( p_qq_line_id NUMBER)
    IS
      SELECT   cf.id  caf_id
              ,dnz_khr_id khr_id
              ,dnz_qte_id qte_id
              ,cfo_id cfo_id
              ,sts_code sts_code
              ,sty_id sty_id
              ,cft_code cft_code
              ,due_arrears_yn due_arrears_yn
              ,start_date start_date
              ,number_of_advance_periods number_of_advance_periods
              ,oty_code oty_code
      FROM    OKL_CASH_FLOWS         cf,
              OKL_CASH_FLOW_OBJECTS  cfo
     WHERE    cf.cfo_id = cfo.id
       AND    cfo.source_table = 'OKL_QUICK_QUOTE_LINES_B'
       AND    cfo.source_id = p_qq_line_id;
    -- Cursor to fetch the Cash Flow Details
    CURSOR qq_cash_flow_levels_csr( p_caf_id NUMBER )
    IS
      SELECT  id cfl_id
             ,caf_id
             ,fqy_code
             ,rate
             ,stub_days
             ,stub_amount
             ,number_of_periods
             ,amount
             ,start_date
        FROM OKL_CASH_FLOW_LEVELS
       WHERE caf_id = p_caf_id
      ORDER BY start_date;
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_fee_srvc_cash_flows';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Declarations
    l_fee_srv_tbl          so_fee_srv_tbl_type;
    l_cash_flow_rec        so_cash_flows_rec_type;
    l_cash_flow_level_tbl  so_cash_flow_details_tbl_type;
    fin_index              NUMBER;  -- Index for the l_fee_srv_tbl
    cfl_index              NUMBER;  -- Index for the l_fee_srv_tbl.cash_flow_level_tbl
    l_hdr_rec              so_hdr_rec_type;
    l_fee_srv_tot_payment  NUMBER;
    l_tot_item_cat_cost    NUMBER;
    l_tot_rent_payment     NUMBER;
    l_override_cf_amt      BOOLEAN;
    l_tot_periods          NUMBER;
    l_periodic_amt         NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- Call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_hdr_rec := p_hdr_rec;
    fin_index := 1;  -- Initialize the fin_index .. !
    l_tot_item_cat_cost    := p_tot_item_cat_cost;
    l_tot_rent_payment     := p_tot_rent_payment;
    l_tot_periods := 0;
    FOR fin_rec IN fee_n_service_csr( p_qq_id => l_hdr_rec.id )
    LOOP
      -- Store the type, value, basis into l_fin_adj_table
      l_fee_srv_tbl(fin_index).type  := fin_rec.type;
      l_fee_srv_tbl(fin_index).basis := fin_rec.basis;
      l_fee_srv_tbl(fin_index).value := fin_rec.value;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              ': Line ID | Line Type | Line Basis | Line Value ');
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              fin_rec.qq_line_id || ' | ' || fin_rec.type || ' | ' ||
              fin_rec.basis || ' | ' || fin_rec.value);
      FOR cf_rec IN qq_cash_flows_csr( p_qq_line_id => fin_rec.qq_line_id )
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              ': Fetched the Cash Flow Rec for Line ID ' ||fin_rec.qq_line_id );
        l_cash_flow_rec.caf_id   := cf_rec.caf_id;
        l_cash_flow_rec.khr_id   := cf_rec.khr_id;
        l_cash_flow_rec.khr_id   := cf_rec.khr_id;
        l_cash_flow_rec.qte_id   := cf_rec.qte_id;
        l_cash_flow_rec.cfo_id   := cf_rec.cfo_id;
        l_cash_flow_rec.sts_code := cf_rec.sts_code;
        l_cash_flow_rec.sty_id   := cf_rec.sty_id;
        l_cash_flow_rec.cft_code := cf_rec.cft_code;
        l_cash_flow_rec.due_arrears_yn := cf_rec.due_arrears_yn;
        l_cash_flow_rec.start_date     := cf_rec.start_date;
        l_cash_flow_rec.number_of_advance_periods := cf_rec.number_of_advance_periods;
        -- Store the cash flow record @ index fin_index in table l_fee_srv_tbl
        l_fee_srv_tbl(fin_index).cash_flow_rec := l_cash_flow_rec;
        -- Retrieve the Cash flow levels ..
        cfl_index := 1;  -- Initialize the cfl_index
        l_cash_flow_level_tbl.DELETE;
        -- Here we need to decide based on the basis type
        --  whether we can st. away use the amount mentioned in the DB Cash flow levels
        --  or ISG has to calculate the periodic payment amount !
        l_override_cf_amt := FALSE;
        l_fee_srv_tot_payment := NULL;
        IF ( l_fee_srv_tbl(fin_index).basis = 'RENT' ) AND
           ( ( l_hdr_rec.pricing_method = 'TR' AND l_hdr_rec.target_rate_type = 'IIR' )
             OR l_hdr_rec.pricing_method = 'SP'
             OR l_hdr_rec.pricing_method = 'RC' )
        THEN
          -- When the fee/srv. basis is %age of asset cost and
          -- pricing method is SP/TR/RC then we need to build the cash flow levels
          --  instead of using the existing cash flows in the DB.
          l_fee_srv_tot_payment := l_fee_srv_tbl(fin_index).value * 0.01 * l_tot_rent_payment;
          l_override_cf_amt := TRUE;
        ELSIF  l_fee_srv_tbl(fin_index).basis = 'ASSET_COST'  AND
               l_hdr_rec.pricing_method = 'SF'
        THEN
          -- When pricing method is SF, ISG wuld have solved for financed
          --  amount, so use this amount on which the %age will be applied.
          l_fee_srv_tot_payment := l_fee_srv_tbl(fin_index).value * 0.01 * l_tot_item_cat_cost ;
          l_override_cf_amt := TRUE;
        END IF;
        IF l_override_cf_amt
        THEN
          l_tot_periods := 0;
          FOR cfl_rec IN qq_cash_flow_levels_csr( p_caf_id => l_cash_flow_rec.caf_id )
          LOOP
            l_tot_periods := l_tot_periods + nvl( cfl_rec.number_of_periods, 0 );
          END LOOP;
          l_periodic_amt := l_fee_srv_tot_payment/l_tot_periods;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                ':******* Overriding the cash flow level amount ' || fin_rec.qq_line_id );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'l_tot_item_cat_cost | l_tot_rent_payment | l_fee_srv_tot_payment | Periodic Amount' );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              round(l_tot_item_cat_cost, 4) || ' | ' ||
              round(l_tot_rent_payment, 4) || ' | ' ||
              round(l_fee_srv_tot_payment, 4)  || ' | ' ||
              round(l_periodic_amt, 4));
        END IF;

        FOR cfl_rec IN qq_cash_flow_levels_csr( p_caf_id => l_cash_flow_rec.caf_id )
        LOOP
          l_cash_flow_level_tbl(cfl_index).cfl_id   := cfl_rec.cfl_id;
          l_cash_flow_level_tbl(cfl_index).caf_id   := cfl_rec.caf_id;
          l_cash_flow_level_tbl(cfl_index).fqy_code := cfl_rec.fqy_code;
          l_cash_flow_level_tbl(cfl_index).locked_amt := 'Y';  -- For QQ Fee Expense/Payments always lock the amt.
          IF l_hdr_rec.pricing_method = 'TR' AND l_hdr_rec.target_rate_type = 'PIRR'
          THEN
            l_cash_flow_level_tbl(cfl_index).rate := l_hdr_rec.target_rate; -- Rate is being stored as %age
          ELSE
            l_cash_flow_level_tbl(cfl_index).rate := cfl_rec.rate;
          END IF;
          l_cash_flow_level_tbl(cfl_index).stub_days   := cfl_rec.stub_days;
          l_cash_flow_level_tbl(cfl_index).stub_amount := cfl_rec.stub_amount;
          l_cash_flow_level_tbl(cfl_index).number_of_periods := cfl_rec.number_of_periods;
          IF l_override_cf_amt
          THEN
            -- Calculate the periodic amount, dividing by the number of periods
            l_cash_flow_level_tbl(cfl_index).amount := l_periodic_amt;
          ELSE
            l_cash_flow_level_tbl(cfl_index).amount := cfl_rec.amount;
          END IF;
          l_cash_flow_level_tbl(cfl_index).start_date  := cfl_rec.start_date;
          -- Remember the flag whether its a stub payment or not
          IF cfl_rec.stub_days IS NOT NULL and cfl_rec.stub_amount IS NOT NULL
          THEN
            -- Stub Payment
            l_cash_flow_level_tbl(cfl_index).is_stub := 'Y';
          ELSE
            -- Regular Periodic Payment
            l_cash_flow_level_tbl(cfl_index).is_stub := 'N';
          END IF;
        END LOOP;
        -- Store the Cash flow levels table in the l_fee_srv_tbl(fin_index)
        l_fee_srv_tbl(fin_index).cash_flow_level_tbl := l_cash_flow_level_tbl;
      END LOOP;
      -- Increment fin_index
      fin_index := fin_index + 1;
    END LOOP;
    -- Setting the return variables ..
    x_fee_srv_tbl   := l_fee_srv_tbl;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_fee_srvc_cash_flows;


  -- API to return the number of days per annum
  -- based on the start date of the business object being passed !
  --  Possible return values are 360/ 365 / 366
  FUNCTION get_days_per_annum(
             p_day_convention   IN            VARCHAR2,
             p_start_date       IN            DATE,
             p_cash_inflow_date IN            DATE,
             x_return_status      OUT NOCOPY VARCHAR2 )
    RETURN NUMBER
  AS
    l_start_year   NUMBER;
    l_cf_year      NUMBER;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF p_day_convention = 'ACTUAL'
    THEN
      l_start_year := TO_NUMBER( TO_CHAR( p_start_date, 'YYYY') );
      l_cf_year := TO_NUMBER( TO_CHAR( p_cash_inflow_date, 'YYYY') );

      IF is_leap_year(l_cf_year)
      THEN
        -- Cash inflow is occuring in a leap year.
        IF to_date( '29-2-' || l_cf_year , 'DD-MM-YYYY') >= p_start_date
        THEN
          RETURN 366;
        ELSE
          RETURN 365;
        END IF;
      END IF;
      -- Since cash inflow is occuring in non-leap year, so .. return 365 days..
      RETURN 365;
    ELSIF p_day_convention = 'ACT365'
    THEN
      -- Number of days per annum doesnot depend on the year
      --  all years are assumed to be having 365 days
      RETURN 365;
    ELSE
      -- p_day_convention = 'THIRTY'
      -- Number of days per annum doesnot depend on the year ...
      --  all years are assumed to be having 360 days
      RETURN 360;
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  END get_days_per_annum;

  -- Procedure to create stream elements for each cash flows level passed !
  -- Expecting the p_cfd_rec to have atleast the following
  --  fqy_code    - Frequency
  --  rate        - Rate
  --  stub_days   - Stub days
  --  stub_amount - Stub Amount
  --  number_of_periods - Periods
  --  Amount            - Regular Periodic amount
  --  is_stub           - Is a Stub or not ..
 -- Added parameter p_recurrence_date by Durga Janaswamy for bug 6007644
  PROCEDURE gen_so_cf_strm_elements(
              p_start_date              IN         DATE,
              p_frequency               IN         VARCHAR2,
              p_advance_arrears         IN         VARCHAR2,
              p_periods                 IN         NUMBER,
              p_amount                  IN         NUMBER,
              p_stub_days               IN         NUMBER,
              p_stub_amount             IN         NUMBER,
              p_stub_flag               IN         VARCHAR2,
              x_cf_strm_elements_tbl    OUT NOCOPY cash_inflows_tbl_type,
              x_return_status           OUT NOCOPY VARCHAR2,
              p_recurrence_date         IN         DATE)
  IS
    l_months_factor      NUMBER;
    l_first_ele_date     DATE;
    l_cash_inflows_tbl   cash_inflows_tbl_type;
    n_periods            NUMBER;  -- Index for the Cash Inflow elements Table
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'gen_so_cf_strm_elements';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.OKL_PRICING_UTILS_PVT.gen_so_cf_strm_elements';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    l_period_start_date   DATE;
    l_period_end_date     DATE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
        'begin debug OKLRPIUB.pls call gen_so_cf_strm_elements');
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- If its a stub payment only one cash_inflows will be returned
    IF  p_stub_flag = 'Y'
        OR ( p_periods IS NULL AND p_stub_days IS NOT NULL )
    THEN
      -- This is a Stub Payment
      l_cash_inflows_tbl(1).is_stub := 'Y';
      l_cash_inflows_tbl(1).cf_amount := p_stub_amount;
      -- Bug 6660626 : Start
      l_cash_inflows_tbl(1).cf_days := p_stub_days;
      -- Bug 6660626 : End
      IF p_advance_arrears = 'ARREARS' OR p_advance_arrears = 'Y'
      THEN
        l_cash_inflows_tbl(1).is_arrears := 'Y';
        l_cash_inflows_tbl(1).cf_date := p_start_date + p_stub_days - 1;
        l_cash_inflows_tbl(1).cf_period_start_end_date
          := p_start_date;
      ELSE
        l_cash_inflows_tbl(1).is_arrears := 'N';
        l_cash_inflows_tbl(1).cf_date := p_start_date;
        l_cash_inflows_tbl(1).cf_period_start_end_date
          := p_start_date + p_stub_days - 1;
      END IF;
    ELSE
      -- This is a regular periodic Payment
      n_periods := p_periods;
      -- Get the month Factor
      -- okl_stream_generator_pvt.get_months_factor handle if frequence is passed one among M/Q/S/A
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'p_frequency_passed'||p_frequency);

      If ( nvl(p_frequency, 'X') = 'X') Then

          OKL_API.set_message(
            p_app_name      => G_APP_NAME,
            p_msg_name      => OKL_API.G_REQUIRED_VALUE,
            p_token1        => OKL_API.G_COL_NAME_TOKEN,
            p_token1_value  => 'FREQUENCY');

          RAISE OKL_API.G_EXCEPTION_ERROR;

      End If;

      l_months_factor := okl_stream_generator_pvt.get_months_factor(
                            p_frequency       =>   p_frequency,
                            x_return_status   =>   l_return_status);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'p_months_factor'||l_months_factor);

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Looping throug the Periods ..
      FOR i in 1 .. n_periods
      LOOP
        l_cash_inflows_tbl(i).is_stub := 'N';
        l_cash_inflows_tbl(i).cf_amount := p_amount;
        -- Bug 6660626 : Start
        l_cash_inflows_tbl(i).cf_days := null;
        -- Bug 6660626 : End
        -- Get the Stream Element date after i months from the p_start_date
        --  when the payments are ADVANCE
       -- Added parameter p_recurrence_date by Durga Janaswamy for bug 6007644
        okl_stream_generator_pvt.get_sel_date(
          p_start_date         => p_start_date,
          p_advance_or_arrears => 'N',
          p_periods_after      => i,
          p_months_per_period  => l_months_factor,
          x_date               => l_period_start_date,
          x_return_status      => l_return_status,
          p_recurrence_date    => p_recurrence_date);
        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Get the Stream Element date after i months from the p_start_date
        --  when the payments are ARREARS
       -- Added parameter p_recurrence_date by Durga Janaswamy for bug 6007644
        okl_stream_generator_pvt.get_sel_date(
          p_start_date         => p_start_date,
          p_advance_or_arrears => 'Y',
          p_periods_after      => i,
          p_months_per_period  => l_months_factor,
          x_date               => l_period_end_date,
          x_return_status      => l_return_status,
          p_recurrence_date    => p_recurrence_date);
        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Based on the payment type is 'ADVANCE' / 'ARREARS' do the assignment ..
        IF p_advance_arrears = 'ARREARS' OR p_advance_arrears = 'Y'
        THEN
          -- Streams for Arrear Payments
          l_cash_inflows_tbl(i).is_arrears := 'Y';
          l_cash_inflows_tbl(i).cf_date := l_period_end_date;
          l_cash_inflows_tbl(i).cf_period_start_end_date := l_period_start_date;
        ELSE
          -- Streams for advance payments
          l_cash_inflows_tbl(i).is_arrears := 'N';
          l_cash_inflows_tbl(i).cf_date := l_period_start_date;
          l_cash_inflows_tbl(i).cf_period_start_end_date := l_period_end_date;
        END IF;
      END LOOP;
    END IF;
    x_cf_strm_elements_tbl := l_cash_inflows_tbl;
    x_return_status        := l_return_status;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call gen_cf_strm_elements');
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_DB_ERROR,
        p_token1       => G_PROG_NAME_TOKEN,
        p_token1_value => l_api_name,
        p_token2       => G_SQLCODE_TOKEN,
        p_token2_value => sqlcode,
        p_token3       => G_SQLERRM_TOKEN,
        p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END gen_so_cf_strm_elements;

  -- Procedure to generate the Streams
  -- based on the Cash Flow n Cash Flow Levels Infomration inputted.
  PROCEDURE  gen_so_cf_strms(
              p_api_version            IN              NUMBER,
              p_init_msg_list          IN              VARCHAR2,
              x_return_status          OUT NOCOPY      VARCHAR2,
              x_msg_count              OUT NOCOPY      NUMBER,
              x_msg_data               OUT NOCOPY      VARCHAR2,
              p_cash_flow_rec          IN              so_cash_flows_rec_type,
              p_cf_details_tbl         IN              so_cash_flow_details_tbl_type,
              x_cash_inflow_strms_tbl  OUT NOCOPY      cash_inflows_tbl_type)
  IS
    -- Local Variables
    l_cf_strms_tbl                  cash_inflows_tbl_type;
    l_temp_cf_strms_tbl             cash_inflows_tbl_type;
    l_api_version         CONSTANT  NUMBER  DEFAULT 1.0;
    l_api_name            CONSTANT  VARCHAR2(30)  DEFAULT 'gen_so_cf_strms';
    l_return_status                 VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.OKL_PRICING_UTILS_PVT.GEN_SO_CF_STRMS';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Local Variables
    i                     NUMBER;
    l_cf_count            NUMBER;
    l_dpp                 NUMBER;  -- Stores Days Per period for each Cash Inflow level
    l_ppy                 NUMBER;  -- Stores Periods Per Year for each Cash Inflow Level

    --Added by DJanaswa for bug 6007644
    l_recurrence_date    DATE := NULL;
    --end DJANASWA

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
           'begin debug OKLRPIUB.pls call gen_so_cf_strms');
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- Call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Actual logic Begins here
    -- Create the cash inflow streams table ..
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Payment Levels =' || p_cf_details_tbl.COUNT );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Rate | Start Date| Frequency| Arrears | Periods | Amount | Stub Days | Stub Amount | Is Stub | Locked' );
    FOR i IN p_cf_details_tbl.FIRST..p_cf_details_tbl.LAST
    LOOP
      -- Validate whether the start_date is there or not
      IF p_cf_details_tbl(i).start_date IS NULL
      THEN
        -- Raise an Exception, cant proceed.
        OKL_API.SET_MESSAGE (
          p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKL_NO_SLL_SDATE');
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  p_cf_details_tbl(i).rate
                  || ' | ' || p_cf_details_tbl(i).start_date
                  || ' | ' || p_cf_details_tbl(i).fqy_code
                  || ' | ' || p_cash_flow_rec.due_arrears_yn
                  || ' | ' || p_cf_details_tbl(i).number_of_periods
                  || ' | ' || p_cf_details_tbl(i).amount
                  || ' | ' || p_cf_details_tbl(i).stub_days
                  || ' | ' || p_cf_details_tbl(i).stub_amount
                  || ' | ' || p_cf_details_tbl(i).is_stub
                  || ' | ' || p_cf_details_tbl(i).locked_amt );

      --Added by djanaswa for bug 6007644
      IF((p_cf_details_tbl(i).number_of_periods IS NULL) AND (p_cf_details_tbl(i).stub_days IS NOT NULL)) THEN
        --Set the recurrence date to null for stub payment
        l_recurrence_date := NULL;
      ELSIF(l_recurrence_date IS NULL) THEN
        --Set the recurrence date as periodic payment level start date
        l_recurrence_date := p_cf_details_tbl(i).start_date;
      END IF;
      --end djanaswa

      -- Create the cash inflow streams
 -- Added parameter p_recurrence_date by djanaswa for bug6007644
      gen_so_cf_strm_elements(
        p_start_date              => p_cf_details_tbl(i).start_date,
        p_frequency               => p_cf_details_tbl(i).fqy_code,
        p_advance_arrears         => p_cash_flow_rec.due_arrears_yn,
        p_periods                 => p_cf_details_tbl(i).number_of_periods,
        p_amount                  => p_cf_details_tbl(i).amount,
        p_stub_days               => p_cf_details_tbl(i).stub_days,
        p_stub_amount             => p_cf_details_tbl(i).stub_amount,
        p_stub_flag               => p_cf_details_tbl(i).is_stub,
        x_cf_strm_elements_tbl    => l_temp_cf_strms_tbl,
        x_return_status           => l_return_status,
        p_recurrence_date         => l_recurrence_date);
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Accumulate the Cash Inflow Streams created
      l_cf_count := nvl(l_cf_strms_tbl.COUNT, 0 );
      get_dpp_ppy(
        p_frequency     => p_cf_details_tbl(i).fqy_code,
        x_dpp           => l_dpp,
        x_ppy           => l_ppy,
        x_return_status => l_return_status);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'l_dpp | l_ppy | l_cf_count | l_return_status ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                l_dpp || '|' ||  l_ppy || '|' ||  l_cf_count || '|' ||  l_return_status  );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Append the l_temp_cf_strms_tbl to l_temp_cf_strms_tbl
      FOR j in l_temp_cf_strms_tbl.FIRST .. l_temp_cf_strms_tbl.LAST
      LOOP
        -- Make updations here for the stream elements generated here..
        l_temp_cf_strms_tbl(j).line_number := l_cf_count + j;
        -- Days per period
        l_temp_cf_strms_tbl(j).cf_dpp := l_dpp;
        -- Periods per Year
        l_temp_cf_strms_tbl(j).cf_ppy := l_ppy;
        -- We are not calculating the cf_days here .....
        -- cf_days will be calculated as and when needed based on the start_date
        -- Also, think about the logic to populate the payment amount
        -- Store the rate from the cash flow
        -- Rate in levels will be stored in terms of percentage !!
        l_temp_cf_strms_tbl(j).cf_rate := p_cf_details_tbl(i).rate / 100;
        IF l_temp_cf_strms_tbl(j).cf_amount IS NULL THEN
          l_temp_cf_strms_tbl(j).cf_miss_pay := 'Y';
        ELSE
          l_temp_cf_strms_tbl(j).cf_miss_pay := 'N';
        END IF;
        l_temp_cf_strms_tbl(j).locked_amt := p_cf_details_tbl(i).locked_amt; -- Populate the LOCKED Flag
        l_cf_strms_tbl( l_cf_count + j ) := l_temp_cf_strms_tbl(j);
      END LOOP;
      -- Delete the streams created ..
      l_temp_cf_strms_tbl.DELETE;
    END LOOP;
    -- For Debugging purpose
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'line_number|cf_amount|cf_date|cf_purpose|cf_dpp|cf_ppy|cf_days|cf_rate|cf_miss_pay|is_stub|is_arrears|cf_period_start_end_date|Locked');
    FOR t in l_cf_strms_tbl.FIRST .. l_cf_strms_tbl.LAST
    LOOP
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 l_cf_strms_tbl(t).line_number || '|' || round(l_cf_strms_tbl(t).cf_amount,4)
                 || '|' || l_cf_strms_tbl(t).cf_date || '|' || l_cf_strms_tbl(t).cf_purpose
                 || '|' || l_cf_strms_tbl(t).cf_dpp || '|' || l_cf_strms_tbl(t).cf_ppy
                 || '|' || l_cf_strms_tbl(t).cf_days || '|' || l_cf_strms_tbl(t).cf_rate
                 || '|' || l_cf_strms_tbl(t).cf_miss_pay || '|' || l_cf_strms_tbl(t).is_stub
                 || '|' || l_cf_strms_tbl(t).is_arrears || '|' || l_cf_strms_tbl(t).cf_period_start_end_date
                 || '|' || l_cf_strms_tbl(t).locked_amt  );
    END LOOP;
    -- Setting up the out parameters to return ....
    x_cash_inflow_strms_tbl := l_cf_strms_tbl;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count, x_msg_data        => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call gen_so_cf_strms');
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             p_api_name  => l_api_name,
                             p_pkg_name  => G_PKG_NAME,
                             p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                             x_msg_count => x_msg_count,
                             x_msg_data  => x_msg_data,
                             p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            p_api_name  => l_api_name,
                            p_pkg_name  => G_PKG_NAME,
                            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                            x_msg_count => x_msg_count,
                            x_msg_data  => x_msg_data,
                            p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            p_api_name  => l_api_name,
                            p_pkg_name  => G_PKG_NAME,
                            p_exc_name  => 'OTHERS',
                            x_msg_count => x_msg_count,
                            x_msg_data  => x_msg_data,
                            p_api_type  => g_api_type);
  END gen_so_cf_strms;

  -- Fetches the appropriate rate on a particular stream element date,
  --  looping through the inputted the cash inflows streams
  PROCEDURE get_rate(
          p_date           IN        DATE,
          p_cf_strms_tbl   IN        cash_inflows_tbl_type,
          x_rate           OUT       NOCOPY NUMBER,
          x_return_status  OUT       NOCOPY VARCHAR2)
  AS
    i                NUMBER;
    l_prev_date      DATE;
    l_curr_date      DATE;
    l_prev_rate      NUMBER;
    l_curr_rate      NUMBER;
    l_api_name       VARCHAR2(30) := 'get_rate';
  BEGIN
    -- Assumption: p_cf_strms_tbl sorted by cf_date in Ascending Order
    IF p_cf_strms_tbl.COUNT > 0
    THEN
      -- No problem can proceed !
      NULL;
    ELSE
      -- Cant proceed ! Raise an Exception ..
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    i := p_cf_strms_tbl.FIRST;
    l_prev_date      := p_cf_strms_tbl(i).cf_date;
    -- In few Scenarios rate amount may be missing
    l_prev_rate      := nvl(p_cf_strms_tbl(i).cf_rate, p_cf_strms_tbl(i).cf_amount );
    l_curr_rate      := nvl(p_cf_strms_tbl(i).cf_rate, p_cf_strms_tbl(i).cf_amount );
    WHILE i <= p_cf_strms_tbl.LAST
    LOOP
      -- Assign dates and rates
      l_curr_date      := p_cf_strms_tbl(i).cf_date;
      l_curr_rate      := nvl(p_cf_strms_tbl(i).cf_rate, p_cf_strms_tbl(i).cf_amount );
      IF l_prev_date >= l_curr_date AND
         i <> p_cf_strms_tbl.FIRST        -- Should not execute for first element
      THEN
        -- Stream Elements should be in ascending chronological order
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF; -- If for l_prev_date
      IF  p_date = p_cf_strms_tbl(i).cf_date
      THEN
        -- Dates matched exactly ..
        x_rate := nvl(p_cf_strms_tbl(i).cf_rate, p_cf_strms_tbl(i).cf_amount );
        RETURN;
      ELSIF p_date < p_cf_strms_tbl(i).cf_date
        AND p_cf_strms_tbl(i).is_arrears = 'Y'
      THEN
        -- Arrears Payment
        x_rate := l_curr_rate;
        RETURN;
      ELSIF p_date < p_cf_strms_tbl(i).cf_date
        AND p_cf_strms_tbl(i).is_arrears = 'N'
      THEN
        -- Advance Payment
        x_rate := l_prev_rate;
        RETURN;
      ELSE
        l_prev_rate := l_curr_rate;
        l_prev_date := l_curr_date;
        i := p_cf_strms_tbl.NEXT(i);
      END IF; -- If based on p_cf_strms_tbl(i).cf_date
    END LOOP; -- While i <= p_cf_strms_tbl.LAST
    x_rate          := l_prev_rate;
    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_DB_ERROR,
        p_token1       => G_PROG_NAME_TOKEN,
        p_token1_value => l_api_name,
        p_token2       => G_SQLCODE_TOKEN,
        p_token2_value => sqlcode,
        p_token3       => G_SQLERRM_TOKEN,
        p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END get_rate;

  -- Function to calculate the Difference between the
  -- start and End Dates inputted.
  FUNCTION GET_DAY_COUNT(
          p_days_in_month     IN      VARCHAR2,
          p_days_in_year      IN      VARCHAR2,
          p_start_date        IN      DATE,
          p_end_date          IN      DATE,
          p_arrears           IN      VARCHAR2,
          x_return_status     OUT     NOCOPY VARCHAR2)
      RETURN NUMBER
  AS
    n_months            NUMBER := 0;
    n_days              NUMBER := 0;
    n_Years             NUMBER := 0;
    l_start_year        NUMBER;
    l_end_year          NUMBER;
    l_start_month       NUMBER;
    l_end_month         NUMBER;
    l_start_day         NUMBER;
    l_orig_start_day    NUMBER;
    l_end_day           NUMBER;
    l_start_date        DATE;
    l_end_date          DATE;
    l_temp_date         DATE;
    n_leap_years        NUMBER;
    l_day_convention    VARCHAR2(10); -- Flag for 365 Year/360 Year based calculation
    l_mod_days          NUMBER;       -- Added by ssohal for Bug#6706568
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Validation: If Start Date cant be greater than End Date then return zero.
    l_start_date := trunc( p_start_date );
    l_end_date   := trunc( p_end_date   );
    IF( l_start_date > l_end_date )
    THEN
      RETURN 0;
    END IF;
    -- Based on p_day_convention calculate the days between Start and End dates
    IF p_days_in_month = 'ACTUAL' AND
       p_days_in_year = 'ACTUAL'
    THEN
      -- Calculations are based on the 365/366 Days/Year assumption
      n_days := floor( l_end_date - l_start_date );

    ELSIF p_days_in_month = 'ACTUAL' AND
          p_days_in_year = '365'
    THEN
      -- Calculations are based on 365 days per year, even in a leap year
      -- Parse years ..
      l_start_year := to_char( p_start_date, 'YYYY' );
      --print( l_api_name ||  ': '  || 'l_start_year ' || l_start_year );
      IF MOD(l_start_year, 4) <> 0
      THEN
        -- Go to the next probable leap year
        l_start_year := l_start_year + ( 4 - MOD( l_start_year, 4 ) );
      END IF;

      -- Check whether l_start_year is a leap year
      IF is_leap_year( l_start_year)
      THEN
        -- leap year, so leave it as it is
        NULL;
      ELSE
        l_start_year := l_start_year + 4;
      END IF;
      --print( l_api_name ||  ': '  || 'Starting with Leap Year ' || l_start_year );
      n_leap_years := 0;
      -- Form a date with 29-Feb-<l_start_year>
      l_temp_date := to_date( '29-02-' || to_char(l_start_year), 'DD-MM-YYYY' );
      --print( l_api_name ||  ': '  || 'l_temp_date ' || l_temp_date );
      WHILE l_temp_date >= l_start_date AND
            l_temp_date <= l_end_date
      LOOP
        -- Increment the Leap Year count
        n_leap_years := n_leap_years + 1;
        l_start_year := l_start_year + 4;
        -- Check whether l_start_year is a leap year
        IF is_leap_year( l_start_year )
        THEN
          -- leap year, so leave it as it is
          NULL;
        ELSE
          l_start_year := l_start_year + 4;
        END IF;
        -- Form a date with 29-Feb-<l_start_year>
        l_temp_date := to_date( '29-02-' || to_char(l_start_year), 'DD-MM-YYYY' );
        --print( l_api_name ||  ': '  || 'l_temp_date ' || l_temp_date );
      END LOOP;
      -- First, count the actual number of dates between l_start_date and l_end_date
      n_days := floor( l_end_date - l_start_date );
      -- Remove the number of leap years falling between
      n_days := n_days - n_leap_years;
    ELSIF p_days_in_month = '30' AND
          p_days_in_year = '360'
    THEN
      -- Parse years ..
      l_start_year := to_char( p_Start_date, 'YYYY' );
      l_end_year   := to_char( p_end_date, 'YYYY' );
      -- Parse months ..
      l_start_month := to_char( p_start_date, 'MM' );
      l_end_month   := to_char( p_end_date, 'MM' );
      -- Parse days ..
      l_start_day := to_char( p_start_date, 'DD' );
      l_orig_start_day := l_start_day;
      l_end_day   := to_char( p_end_date, 'DD' );
      -- Calculation is based on the assumption of 30 days per month.
      n_Years := l_end_year - l_start_year;
      n_Months := n_Years * 12 - l_start_month + l_end_month;

      -- IF D1 is last day of February,
      --   and D2 day > D1 day ( D2 day in ( 29, 30, 31) )
      --     then move D1 to 30
      -- If D2 is last day of February,
      --    If D1 day = D2 day and D1 month <> 2, then make D1 to 30
      --    If D1 is not the last day of february month in earlier years or D1 = D2
      --      Make D2 to 30
      --  IF d1 is last day of the non-February month move d1 to 30
      --  IF d2 is last day of the non-February month move d2 to 30

      IF l_start_month = 2  AND l_start_date = LAST_DAY( l_start_date )
           AND l_end_day > l_start_day
      THEN
        -- Move D1 to 30
        l_start_day := 30;
      END IF;
      IF l_end_month = 2 AND  l_end_date = LAST_DAY( l_end_date )
      THEN
        IF l_start_day = l_end_day AND l_start_month <> 2
        THEN
          l_start_day := 30;
        END IF;
        IF ( MOD(n_months, 12) <> 0 OR n_months = 0 )
           AND ( p_arrears = 'Y' )
        THEN
          l_end_day := 30;
        END IF;
      END IF;

      IF l_start_month <> 2 AND l_start_date = LAST_DAY( l_start_date)
      THEN
        l_start_day := 30;
      END IF;

      IF l_end_month <> 2 AND l_end_date = LAST_DAY( l_end_date)
      THEN
        l_end_day := 30;
      END IF;
      -- Calculate the number of days ...
      n_days := n_Months * 30 - l_start_day + l_end_day;
    ELSE
      x_return_Status := OKL_API.G_RET_STS_ERROR;
      RETURN 0;
    END IF;

    -- Consider the last day incase of arrears Payments
    -- Start : Added by ssohal for Bug#6706568
    IF p_arrears = 'Y'
    THEN
       IF p_days_in_month = '30' AND
          p_days_in_year = '360'
       THEN
          l_mod_days := MOD(n_days,30);
          IF ( l_mod_days <> 0 OR n_days = 0 ) AND ( l_orig_start_day <> 31 )
          THEN
             n_days := n_days + 1;
          END IF;
       ELSE
          n_days := n_days + 1;
       END IF;
    END IF;
    -- End : Added by ssohal for Bug#6706568

    -- Set the OUT parameters and return
    x_return_status := 'S';
    RETURN n_days;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
      RETURN -1;  -- get_day_count returns negative in case of error/failure
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      RETURN -1;  -- get_day_count returns negative in case of error/failure
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_DB_ERROR,
          p_token1       => G_PROG_NAME_TOKEN,
          p_token1_value => 'GET_DAY_COUNT',
          p_token2       => G_SQLCODE_TOKEN,
          p_token2_value => sqlcode,
          p_token3       => G_SQLERRM_TOKEN,
          p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
      RETURN -1;  -- get_day_count returns negative in case of error/failure
  END get_day_count;

  PROCEDURE compute_irr(
              p_api_version             IN              NUMBER,
              p_init_msg_list           IN              VARCHAR2,
              x_return_status           OUT NOCOPY      VARCHAR2,
              x_msg_count               OUT NOCOPY      NUMBER,
              x_msg_data                OUT NOCOPY      VARCHAR2,
              p_start_date              IN              DATE,
              p_day_count_method        IN              VARCHAR2,
              p_currency_code           IN              VARCHAR2,
              p_pricing_method          IN              VARCHAR2,
              p_initial_guess           IN              NUMBER,
              px_pricing_parameter_tbl  IN  OUT NOCOPY  pricing_parameter_tbl_type,
              px_irr                    IN  OUT NOCOPY  NUMBER,
              x_payment                 OUT     NOCOPY  NUMBER)
  AS
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'compute_irr';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Cursor Definitions
     CURSOR get_precision_csr(p_currency_code VARCHAR2)
     IS
       SELECT NVL(cur.precision,0) precision
         FROM fnd_currencies cur
        WHERE cur.currency_code = p_currency_code;
    -- Local Variables/Constants Declaration
    l_cash_inflow_strms_tbl  cash_inflows_tbl_type;
    l_cash_outflow_strms_tbl cash_inflows_tbl_type;
    l_residuals_tbl          cash_inflows_tbl_type;
    l_days_in_month              VARCHAR2(30);
    l_days_in_year               VARCHAR2(30);
    cin_index                NUMBER;  -- Index for Cash Inflows
    cout_index               NUMBER;  -- Index for Cash Outflows
    res_index                NUMBER;  -- Index for Residuals Table
    l_time_zero_cost         NUMBER;
    l_adv_inf_payment        NUMBER;
    l_precision              NUMBER;
    l_irr_limit              NUMBER;
    l_irr                    NUMBER;
    l_npv                    NUMBER;
    l_npv_sign               NUMBER;
    l_increment_rate         NUMBER;
    l_abs_incr_rate          NUMBER;
    n_iterations             NUMBER;
    l_cf_dpp                 NUMBER;
    l_cf_ppy                 NUMBER;
    l_cf_amount              NUMBER;
    l_cf_date                DATE;
    l_days_in_future         NUMBER;
    l_periods                NUMBER;
    l_rate                   NUMBER;
    l_prev_irr               NUMBER;
    l_prev_npv               NUMBER;
    l_prev_npv_sign          NUMBER;
    l_prev_incr_sign         NUMBER;
    l_positive_npv_irr       NUMBER;
    l_negative_npv_irr       NUMBER;
    l_positive_npv           NUMBER;
    l_negative_npv           NUMBER;
    l_crossed_zero           VARCHAR2(1);
    l_irr_decided            VARCHAR2(1);
    l_temp_amount            NUMBER;  -- Debug Purpose
    l_disc_rate              NUMBER;  -- Debug Purpose
    l_term_interest          NUMBER;
    l_acc_term_interest      NUMBER;
    i                        NUMBER;  -- Used as Index
    l_period_start_date      DATE;
    l_period_end_date        DATE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- Call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validations here ..
    get_days_in_year_and_month(
      p_day_count_method => p_day_count_method,
      x_days_in_month    => l_days_in_month,
      x_days_in_year     => l_days_in_year,
      x_return_status    => l_return_status);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'After get_days_in_year_and_month ' || l_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'l_days_in_month= ' || l_days_in_month || ' |  l_days_in_year = ' || l_days_in_year);

    -- 1/ Fetch the Start Date
    IF p_start_date IS NULL
    THEN
      -- Show the error message
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF; -- IF p_start_date
    IF px_pricing_parameter_tbl.COUNT > 0
    THEN
      -- Do Nothing
      NULL;
    ELSE
      -- Cant proceed.
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF; -- IF px_pricing_parameter_tbl.COUNT > 0

    IF p_pricing_method = 'SY' OR
       p_pricing_method = 'TR'
    THEN
       -- Do Nothing
       NULL;
    ELSE
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Compute_irr currently supports only Solve for Yields and Target Rate Pricing Scenarios only ' );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Start Date     =' || p_start_date );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Pricing Method =' || p_pricing_method  );
    -- Starting to Initialize things .....
    l_time_zero_cost         := 0;  -- Time Zero Outflows
    l_adv_inf_payment        := 0;  -- Cash Inflow Amounts
    cin_index := 1;
    cout_index := 1;
    res_index := 1;
    -- Consolidate all the Cash and Residual Inflows per each
    --  pricing parameter record with line_type as FREE_FORM1 ..
    i := px_pricing_parameter_tbl.FIRST;
    WHILE i <= px_pricing_parameter_tbl.LAST
    LOOP
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Time Zero Cost[SUM] | Financed Amount| Subsidy | Down Payment | Tradein | Capitalized Fee Amt' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               round( l_time_zero_cost, 4) || '|' || round( px_pricing_parameter_tbl(i).financed_amount, 4 )
               || '|' || round( px_pricing_parameter_tbl(i).subsidy, 4 ) || '|' || round( px_pricing_parameter_tbl(i).down_payment, 4 )
               || '|' || round( px_pricing_parameter_tbl(i).trade_in, 4)  || '|' || round( px_pricing_parameter_tbl(i).cap_fee_amount, 4) );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'compute_irr: line_type ' || px_pricing_parameter_tbl(i).line_type );
      IF px_pricing_parameter_tbl(i).line_type = 'FREE_FORM1'
      THEN
        -- Handling the Cash inflows Details
        IF px_pricing_parameter_tbl(i).cash_inflows IS NOT NULL AND
           px_pricing_parameter_tbl(i).cash_inflows.COUNT > 0
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Cash Inflows: -------------------------------------------------------------' );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Rate | Date | Amount | Days | Arrears | Stub | cf_dpp | cf_ppy | cf_period_start_end_date | LOCKED');
          FOR t_index IN px_pricing_parameter_tbl(i).cash_inflows.FIRST ..
                       px_pricing_parameter_tbl(i).cash_inflows.LAST
          LOOP
            l_cash_inflow_strms_tbl( cin_index ) :=
              px_pricing_parameter_tbl(i).cash_inflows(t_index);
            -- Need to calculate just the cf_days
            l_cash_inflow_strms_tbl(cin_index).cf_days :=
              get_day_count(
                p_days_in_month  => l_days_in_month,
                p_days_in_year   => l_days_in_year,
                p_start_date     => p_start_date,     -- Start date mentioned in the Header rec
                p_end_date       => l_cash_inflow_strms_tbl(cin_index).cf_date,
                p_arrears        => l_cash_inflow_strms_tbl(cin_index).is_arrears,
                x_return_status  => l_return_status);
              IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            -- cf_dpp, cf_ppy, cf_periods are being populated
            IF p_day_count_method <> 'THIRTY'
            THEN
              -- Pricing Day convention is not THIRTY day based !!
              -- So, override the existing the cf_dpp here !
              IF l_cash_inflow_strms_tbl(cin_index).is_arrears = 'Y'
              THEN
                -- cf_date represents end of the period
                l_period_start_date := l_cash_inflow_strms_tbl(cin_index).cf_period_start_end_date;
                l_period_end_date := l_cash_inflow_strms_tbl(cin_index).cf_date;
              ELSE
                -- cf_date represents start of the period
                l_period_start_date := l_cash_inflow_strms_tbl(cin_index).cf_date;
                l_period_end_date := l_cash_inflow_strms_tbl(cin_index).cf_period_start_end_date;
              END IF;
              l_cash_inflow_strms_tbl(cin_index).cf_dpp :=
                get_day_count(
                  p_days_in_month  => l_days_in_month,
                  p_days_in_year   => l_days_in_year,
                  p_start_date     => l_period_start_date,     -- Start date mentioned in the Header rec
                  p_end_date       => l_period_end_date,
                  p_arrears        => 'Y',
                  x_return_status  => l_return_status);
                IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            END IF; -- If p_day_convention <> 'THIRTY'
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  ROUND(l_cash_inflow_strms_tbl(cin_index).cf_rate,4) || '|' || l_cash_inflow_strms_tbl(cin_index).cf_date
                  || '|' || round(l_cash_inflow_strms_tbl(cin_index).cf_amount,4) || '|' || l_cash_inflow_strms_tbl(cin_index).cf_days
                  || '|' || l_cash_inflow_strms_tbl(cin_index).is_Arrears || '|' || l_cash_inflow_strms_tbl(cin_index).is_stub
                  || '|' || l_cash_inflow_strms_tbl(cin_index).cf_dpp || '|' || l_cash_inflow_strms_tbl(cin_index).cf_ppy
                  || '|' || l_cash_inflow_strms_tbl(cin_index).cf_period_start_end_date || ' | ' ||
                  l_cash_inflow_strms_tbl(cin_index).locked_amt);
            -- Validations regarding either of the Payment amount or rate should be present
            --   can be placed here ... Think about it ..
            cin_index := cin_index + 1;
          END LOOP;
        END IF;
        -- Handling the Residual Inflows
        IF px_pricing_parameter_tbl(i).residual_inflows IS NOT NULL AND
           px_pricing_parameter_tbl(i).residual_inflows.COUNT > 0
        THEN
          -- Calculation of the Residual Value Inflow Amounts
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Residuals: -----------------------------------' || px_pricing_parameter_tbl(i).residual_inflows.COUNT );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Rate | Date | Residual Amount | Days | Arrears | cf_dpp | cf_ppy | cf_period_start_end_date| LOCKED');
          FOR t_index IN px_pricing_parameter_tbl(i).residual_inflows.FIRST ..
                         px_pricing_parameter_tbl(i).residual_inflows.LAST
          LOOP
            l_residuals_tbl( res_index ) :=
              px_pricing_parameter_tbl(i).residual_inflows(t_index);
             -- The wrapper API has to take the responsibility of passing the
             -- cf_date, cf_dpp, cf_ppy, cf_amount per each residual record
            get_rate(
              p_date          => l_residuals_tbl(res_index).cf_date,
              p_cf_strms_tbl  => px_pricing_parameter_tbl(i).cash_inflows,
              x_rate          => l_residuals_tbl(res_index).cf_rate,
              x_return_status => l_return_status);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            l_residuals_tbl(res_index).cf_days :=
              get_day_count(
                p_days_in_month  => l_days_in_month,
                p_days_in_year   => l_days_in_year,
                p_start_date     => p_start_date,     -- Start date mentioned in the Header rec
                p_end_date       => l_residuals_tbl(res_index).cf_date,
                p_arrears        => 'Y', -- Residuals are always obtained at the end of the term
                x_return_status  => l_return_status);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            IF p_day_count_method <> 'THIRTY'
            THEN
              -- Calculating the cf_dpp for the residual values
              l_period_end_date := l_residuals_tbl(res_index).cf_date;
              okl_stream_generator_pvt.add_months_new(
                p_start_date     => l_period_end_date,
                p_months_after   => -12 / l_residuals_tbl(res_index).cf_ppy, -- Will get the frequency for us
                x_date           => l_period_start_date,
                x_return_status  => l_return_status);
              IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              l_period_start_date := l_period_start_date + 1;
              l_residuals_tbl(res_index).cf_period_start_end_date := l_period_start_date;
              -- Residual value will be calculated based on the
              -- number of days between the l_period_start_date and l_period_end_date !!
              l_residuals_tbl(res_index).cf_dpp :=
                get_day_count(
                  p_days_in_month  => l_days_in_month,
                  p_days_in_year   => l_days_in_year,
                  p_start_date     => l_period_start_date,     -- Start date mentioned in the Header rec
                  p_end_date       => l_period_end_date,
                  p_arrears        => 'Y',
                  x_return_status  => l_return_status);
              IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            END IF; -- IF p_day_count_method = 'THIRTY'
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              round(l_residuals_tbl(res_index).cf_rate,4) || '|' || l_residuals_tbl(res_index).cf_date
              || '|' || round(l_residuals_tbl(res_index).cf_amount,4) || '|' || l_residuals_tbl(res_index).cf_days
              || '|' || l_residuals_tbl(res_index).cf_purpose || '|' || l_residuals_tbl(res_index).is_Arrears
              || '|' || l_residuals_tbl(res_index).cf_dpp || '|' || l_residuals_tbl(res_index).cf_ppy
              || '|' || l_residuals_tbl(res_index).cf_period_start_end_date || '|' || l_residuals_tbl(res_index).locked_amt);
            -- Increment the res_index
            res_index := res_index + 1;
          END LOOP;
        END IF;
        l_time_zero_cost := l_time_zero_cost +
                           nvl( px_pricing_parameter_tbl(i).financed_amount, 0 ) -
                           nvl( px_pricing_parameter_tbl(i).subsidy, 0 ) -
                           nvl( px_pricing_parameter_tbl(i).trade_in, 0 ) -
                           nvl( px_pricing_parameter_tbl(i).down_payment, 0 ) +
                           nvl( px_pricing_parameter_tbl(i).cap_fee_amount, 0 );
     -- Code to handle various possible fees/service other than the FREE_FORM1
     ELSIF px_pricing_parameter_tbl(i).payment_type = 'INCOME'
     THEN
       -- Assumption is that the outflow amount is placed in the
       -- financed_amount. And the inflows are being passed in the l_cash_inflow_strms_tbl
       l_time_zero_cost := l_time_zero_cost + nvl(px_pricing_parameter_tbl(i).financed_amount,0);

       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',px_pricing_parameter_tbl(i).payment_type ||
            ' Inflows: -------------------------------------------------------------' );
       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Rate | Date | Amount | Days | Arrears | Stub | cf_dpp | cf_ppy | cf_period_start_end_date | LOCKED');
       FOR t_index IN px_pricing_parameter_tbl(i).cash_inflows.FIRST ..
                      px_pricing_parameter_tbl(i).cash_inflows.LAST
       LOOP
         l_cash_inflow_strms_tbl( cin_index ) :=
           px_pricing_parameter_tbl(i).cash_inflows(t_index);
         -- Need to calculate just the cf_days
         l_cash_inflow_strms_tbl(cin_index).cf_days :=
           get_day_count(
             p_days_in_month  => l_days_in_month,
             p_days_in_year   => l_days_in_year,
             p_start_date     => p_start_date,     -- Start date mentioned in the Header rec
             p_end_date       => l_cash_inflow_strms_tbl(cin_index).cf_date,
             p_arrears        => l_cash_inflow_strms_tbl(cin_index).is_arrears,
             x_return_status  => l_return_status);
         IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         -- cf_dpp, cf_ppy, cf_periods are being populated
         IF p_day_count_method <> 'THIRTY'
         THEN
           -- Pricing Day convention is not THIRTY day based !!
           -- So, override the existing the cf_dpp here !
           IF l_cash_inflow_strms_tbl(cin_index).is_arrears = 'Y'
           THEN
             -- cf_date represents end of the period
             l_period_start_date := l_cash_inflow_strms_tbl(cin_index).cf_period_start_end_date;
             l_period_end_date := l_cash_inflow_strms_tbl(cin_index).cf_date;
           ELSE
             -- cf_date represents start of the period
             l_period_start_date := l_cash_inflow_strms_tbl(cin_index).cf_date;
             l_period_end_date := l_cash_inflow_strms_tbl(cin_index).cf_period_start_end_date;
           END IF;
           l_cash_inflow_strms_tbl(cin_index).cf_dpp :=
             get_day_count(
               p_days_in_month  => l_days_in_month,
               p_days_in_year   => l_days_in_year,
               p_start_date     => l_period_start_date,     -- Start date mentioned in the Header rec
               p_end_date       => l_period_end_date,
               p_arrears        => 'Y',
               x_return_status  => l_return_status);
           IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END IF; -- If p_day_convention <> 'THIRTY'
         put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            round(l_cash_inflow_strms_tbl(cin_index).cf_rate,4) || '|' || l_cash_inflow_strms_tbl(cin_index).cf_date
            || '|' || round(l_cash_inflow_strms_tbl(cin_index).cf_amount,4) || '|' || l_cash_inflow_strms_tbl(cin_index).cf_days
            || '|' || l_cash_inflow_strms_tbl(cin_index).is_Arrears || '|' || l_cash_inflow_strms_tbl(cin_index).is_stub
            || '|' || l_cash_inflow_strms_tbl(cin_index).cf_dpp || '|' || l_cash_inflow_strms_tbl(cin_index).cf_ppy
            || '|' || l_cash_inflow_strms_tbl(cin_index).cf_period_start_end_date
            || '|' || l_cash_inflow_strms_tbl(cin_index).locked_amt);
         -- Validations regarding either of the Payment amount or rate should be present
         --   can be placed here ... Think about it ..
         cin_index := cin_index + 1;
       END LOOP; -- Loop on the px_pricing_parameter_tbl(i).cash_inflows
     -- Handling the Outflows
     ELSIF px_pricing_parameter_tbl(i).payment_type = 'EXPENSE'
     THEN
       -- One time expense amount is being passed in the financed_amount
       -- Recurring expenses are being passed as cash inflows. (Reverse the sign here)
       l_time_zero_cost := l_time_zero_cost + nvl(px_pricing_parameter_tbl(i).financed_amount,0);
       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S', px_pricing_parameter_tbl(i).payment_type ||
            'Handling Outflows: -------------------------------------------------------------' );
       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Rate | Date | Amount | Days | Arrears | Stub | cf_dpp | cf_ppy | cf_period_start_end_date|LOCKED');
       IF px_pricing_parameter_tbl(i).cash_inflows.COUNT > 0
       THEN
         FOR t_index IN px_pricing_parameter_tbl(i).cash_inflows.FIRST ..
                        px_pricing_parameter_tbl(i).cash_inflows.LAST
         LOOP
           l_cash_outflow_strms_tbl( cout_index ) :=
             px_pricing_parameter_tbl(i).cash_inflows(t_index);
           -- Checking that the amount should be negative, as they are expenses
           --   and expenses are always considered negative from Lessor perspective !!
           IF l_cash_outflow_strms_tbl(cout_index).cf_amount > 0
           THEN
             l_cash_outflow_strms_tbl(cout_index).cf_amount := -1 * l_cash_outflow_strms_tbl(cout_index).cf_amount;
           END IF;
           -- calculate the cf_days
           l_cash_outflow_strms_tbl(cout_index).cf_days :=
             get_day_count(
               p_days_in_month  => l_days_in_month,
               p_days_in_year   => l_days_in_year,
               p_start_date     => p_start_date,     -- Start date mentioned in the Header rec
               p_end_date       => l_cash_outflow_strms_tbl(cout_index).cf_date,
               p_arrears        => l_cash_outflow_strms_tbl(cout_index).is_arrears,
               x_return_status  => l_return_status);
           IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
           -- cf_dpp, cf_ppy, cf_periods are being populated
           IF p_day_count_method <> 'THIRTY'
           THEN
             -- Pricing Day convention is not THIRTY day based !!
             -- So, override the existing the cf_dpp here !
             IF l_cash_outflow_strms_tbl(cout_index).is_arrears = 'Y'
             THEN
               -- cf_date represents end of the period
               l_period_start_date := l_cash_outflow_strms_tbl(cout_index).cf_period_start_end_date;
               l_period_end_date := l_cash_outflow_strms_tbl(cout_index).cf_date;
             ELSE
               -- cf_date represents start of the period
               l_period_start_date := l_cash_outflow_strms_tbl(cout_index).cf_date;
               l_period_end_date := l_cash_outflow_strms_tbl(cout_index).cf_period_start_end_date;
             END IF;
             l_cash_outflow_strms_tbl(cout_index).cf_dpp :=
               get_day_count(
                 p_days_in_month  => l_days_in_month,
                 p_days_in_year   => l_days_in_year,
                 p_start_date     => l_period_start_date,
                 p_end_date       => l_period_end_date,
                 p_arrears        => 'Y',
                 x_return_status  => l_return_status);
             IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
           END IF; -- If p_day_convention <> 'THIRTY'
           put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                ROUND(l_cash_outflow_strms_tbl(cout_index).cf_rate,4) || '|' || l_cash_outflow_strms_tbl(cout_index).cf_date
                || '|' || round(l_cash_outflow_strms_tbl(cout_index).cf_amount,4) || '|' || l_cash_outflow_strms_tbl(cout_index).cf_days
                || '|' || l_cash_outflow_strms_tbl(cout_index).is_Arrears || '|' || l_cash_outflow_strms_tbl(cout_index).is_stub
                || '|' || l_cash_outflow_strms_tbl(cout_index).cf_dpp || '|' || l_cash_outflow_strms_tbl(cout_index).cf_ppy
                || '|' || l_cash_outflow_strms_tbl(cout_index).cf_period_start_end_date
                || '|' || l_cash_outflow_strms_tbl(cout_index).locked_amt);
           -- Validations regarding either of the Payment amount or rate should be present
           --   can be placed here ... Think about it ..
           cout_index := cout_index + 1;
         END LOOP; -- Loop on the px_pricing_parameter_tbl(i).cash_inflows
       END IF; -- If cash_inflows.count
     -- Handling the Outflows
     ELSIF px_pricing_parameter_tbl(i).line_type = 'SECDEPOSIT'
     THEN
       -- Security Deposit is a different kind of Fee. Need to handle that differently.
       -- Security Deposit is kind of payment, which is considered intially as inflow
       -- and at the end of the term, it is considered as outflow !!
       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
             px_pricing_parameter_tbl(i).line_type ||
            'Handling Security Deposit Streams: -------------------------------------------------------------' );
       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Rate | Date | Amount | Days | Arrears | Stub | cf_dpp | cf_ppy | cf_period_start_end_date|LOCKED');
       FOR t_index IN px_pricing_parameter_tbl(i).cash_inflows.FIRST ..
                      px_pricing_parameter_tbl(i).cash_inflows.LAST
       LOOP

         l_cash_inflow_strms_tbl( cin_index ) :=
           px_pricing_parameter_tbl(i).cash_inflows(t_index);
         -- calculate the cf_days
         l_cash_inflow_strms_tbl(cin_index).cf_days :=
           get_day_count(
             p_days_in_month  => l_days_in_month,
             p_days_in_year   => l_days_in_year,
             p_start_date     => p_start_date,     -- Start date mentioned in the Header rec
             p_end_date       => l_cash_inflow_strms_tbl(cin_index).cf_date,
             p_arrears        => 'N',
             x_return_status  => l_return_status);
         IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         -- cf_dpp, cf_ppy, cf_periods are being populated
         IF p_day_count_method <> 'THIRTY'
         THEN
           -- Pricing Day convention is not THIRTY day based !!
           -- So, override the existing the cf_dpp here !
           IF l_cash_inflow_strms_tbl(cin_index).is_arrears = 'Y'
           THEN
             -- cf_date represents end of the period
             l_period_start_date := l_cash_inflow_strms_tbl(cin_index).cf_period_start_end_date;
             l_period_end_date := l_cash_inflow_strms_tbl(cin_index).cf_date;
           ELSE
             -- cf_date represents start of the period
             l_period_start_date := l_cash_inflow_strms_tbl(cin_index).cf_date;
             l_period_end_date := l_cash_inflow_strms_tbl(cin_index).cf_period_start_end_date;
           END IF;
           l_cash_inflow_strms_tbl(cin_index).cf_dpp :=
             get_day_count(
               p_days_in_month  => l_days_in_month,
               p_days_in_year   => l_days_in_year,
               p_start_date     => l_period_start_date,
               p_end_date       => l_period_end_date,
               p_arrears        => 'Y',
               x_return_status  => l_return_status);
           IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END IF; -- If p_day_convention <> 'THIRTY'
         put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            ROUND(l_cash_inflow_strms_tbl(cin_index).cf_rate,4) || '|' || l_cash_inflow_strms_tbl(cin_index).cf_date
            || '|' || round(l_cash_inflow_strms_tbl(cin_index).cf_amount,4) || '|' || l_cash_inflow_strms_tbl(cin_index).cf_days
            || '|' || l_cash_inflow_strms_tbl(cin_index).is_Arrears || '|' || l_cash_inflow_strms_tbl(cin_index).is_stub
            || '|' || l_cash_inflow_strms_tbl(cin_index).cf_dpp || '|' || l_cash_inflow_strms_tbl(cin_index).cf_ppy
            || '|' || l_cash_inflow_strms_tbl(cin_index).cf_period_start_end_date
            || '|' || l_cash_inflow_strms_tbl(cin_index).locked_amt);
         l_cash_outflow_strms_tbl( cout_index ) :=
           px_pricing_parameter_tbl(i).cash_inflows(t_index);
         -- Checking that the amount should be negative, as they are expenses
         --   and expenses are always considered negative from Lessor perspective !!
         IF l_cash_outflow_strms_tbl(cout_index).cf_amount > 0
         THEN
           l_cash_outflow_strms_tbl(cout_index).cf_amount := -1 * l_cash_outflow_strms_tbl(cout_index).cf_amount;
         END IF;
         -- calculate the cf_days
         l_cash_outflow_strms_tbl(cout_index).cf_days :=
           get_day_count(
             p_days_in_month  => l_days_in_month,
             p_days_in_year   => l_days_in_year,
             p_start_date     => p_start_date,
             p_end_date       => px_pricing_parameter_tbl(i).line_end_date,
             p_arrears        => 'N',
             x_return_status  => l_return_status);
         IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         -- Use the cash inflows cf_dpp as the cf_dpp for outflows too,
         --  instead of calculation of the cf_dpp for ACT365/ ACTUAL day count methods pricing
         l_cash_outflow_strms_tbl(cout_index).cf_dpp :=
           l_cash_inflow_strms_tbl(cin_index).cf_dpp;
         put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
             round(l_cash_outflow_strms_tbl(cout_index).cf_rate,4) || '|' || l_cash_outflow_strms_tbl(cout_index).cf_date
             || '|' || round(l_cash_outflow_strms_tbl(cout_index).cf_amount,4) || '|' || l_cash_outflow_strms_tbl(cout_index).cf_days
             || '|' || l_cash_outflow_strms_tbl(cout_index).is_Arrears || '|' || l_cash_outflow_strms_tbl(cout_index).is_stub
             || '|' || l_cash_outflow_strms_tbl(cout_index).cf_dpp || '|' || l_cash_outflow_strms_tbl(cout_index).cf_ppy
             || '|' || l_cash_outflow_strms_tbl(cout_index).cf_period_start_end_date
             || '|' || l_cash_outflow_strms_tbl(cout_index).locked_amt);
         -- Increment the cin_index and cout_indexes
         cin_index := cin_index + 1;
         cout_index := cout_index + 1;
       END LOOP; -- Loop on the px_pricing_parameter_tbl(i).cash_inflows
     END IF; -- If on the line_type
     -- Increment index i ..
     i := px_pricing_parameter_tbl.NEXT(i);
   END LOOP;
    -- Loop thru' the inflows and sum the amount
    IF l_cash_inflow_strms_tbl.COUNT > 0
    THEN
      FOR t_in in l_cash_inflow_strms_tbl.FIRST .. l_cash_inflow_strms_tbl.LAST
      LOOP
        IF l_cash_inflow_strms_tbl(t_in).cf_date <= p_start_date
        THEN
          -- Sum the amount
          l_adv_inf_payment := l_adv_inf_payment + nvl( l_cash_inflow_strms_tbl(t_in).cf_amount, 0 );
        END IF;
      END LOOP;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
             'Rent Inflows on or before the Start Date ' || round(l_adv_inf_payment,4) );

    -- 20/ Validation: Sum of all the inflows should not exceed the Total Time zero cost
    IF l_adv_inf_payment   >= l_time_zero_cost
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           'Unable to calculate the IRR l_adv_inf_payment= ' || round(l_adv_inf_payment, 4)
           || 'l_time_zero_cost = ' || round( l_time_zero_cost, 4) );
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKL_IRR_CALC_INF_LOOP',
        p_token1       => 'ADV_AMOUNT',
        p_token1_value => l_adv_inf_payment,
        p_token2       => 'CAPITAL_AMOUNT',
        p_token2_value => l_time_zero_cost);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- 30/ Validate Currency code and Precision ...
    IF p_currency_code IS NOT NULL
    THEN
      OPEN  get_precision_csr(p_currency_code);
      FETCH get_precision_csr INTO l_precision;
      CLOSE get_precision_csr;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Precision=' || nvl(l_precision, 1) );
    -- If Precision is null throw error and return
    IF l_precision IS NULL
    THEN
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          ': '  || 'Precision is not mentioned !' );
      OKL_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => OKL_API.G_REQUIRED_VALUE,
        p_token1        => OKL_API.G_COL_NAME_TOKEN,
        p_token1_value  => 'CURRENCY_CODE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Setting up all for the MAIN Loop ....
    -- Setting the IRR limit
    l_irr_limit := ROUND(NVL(ABS(fnd_profile.value('OKL_PRE_TAX_IRR_LIMIT')), 1000), 0)/100;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           ': '  || 'IRR Limit=' || l_irr_limit );
    -- n_iterations represent the number of Iteration we are in ..
    n_iterations         := 0;
    l_acc_term_interest  := 0;
    l_increment_rate     := 0.1; -- 10% increment
    l_crossed_zero       := 'N'; -- Y/N Flags
    l_irr_decided        := 'N'; -- Y/N Flags
    l_irr                := nvl(p_initial_guess,0.1);
    -- Forming the Equation (1)
    -- pvCF + pvR - ( C - S - D - T )= 0
    -- Until now  l_time_zero_cost = C - S - D - T + Cap. Fee Amt, so negate l_time_zero_cost
    l_time_zero_cost := -1 * l_time_zero_cost;
    -- As we see in Equation (1) only pvR and pvCF are based on the rate we assume/calculate
    -- Hence we calculate them per loop with the current l_irr
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           'Time Zero Cost ' || round(l_time_zero_cost,4) );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Advance Inflows Amount' || round(l_adv_inf_payment,4) );
    LOOP
      -- Increment the current iteration
      n_iterations := n_iterations + 1;
      -- Start with the Net Present value as the l_time_zero_cost
      l_npv        := l_time_zero_cost;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S','Iteration #       ' || n_iterations);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S','Net Present Value ' || round(l_npv,4) );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S','l_irr             ' || l_irr );
      -- Handling the Present Value of the Residuals
      IF l_residuals_tbl.COUNT > 0
      THEN
        res_index := l_residuals_tbl.FIRST;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  '--- Residual Values ------------------------------------------------------------' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'DPP | PPY | Days | Periods | Res. Amount | Rate | Discount Rate | Present Value' );
        WHILE res_index <= l_residuals_tbl.LAST
        LOOP
          l_cf_dpp          :=  l_residuals_tbl(res_index).cf_dpp;
          l_cf_ppy          :=  l_residuals_tbl(res_index).cf_ppy;
          l_cf_amount       :=  l_residuals_tbl(res_index).cf_amount;
          l_cf_date         :=  l_residuals_tbl(res_index).cf_date;
          l_days_in_future  :=  l_residuals_tbl(res_index).cf_days;
          IF l_cf_dpp <> 0
          THEN
            l_periods         :=  l_days_in_future / l_cf_dpp;
          ELSE
            l_periods := 0;
          END IF;
          -- This is the variable you will be change based on the Pricing Method ..
          -- Eg., For 'Target Payment' you will be using l_irr as l_rate
          --      For 'Target Rate' you will be using the l_residuals_tbl(res_index).cf_rate ..
          IF p_pricing_method = 'SY'
          THEN
            l_rate            := l_irr;
          ELSE
            l_rate            := l_residuals_tbl(res_index).cf_rate;
          END IF;
          -- Now, calculate the Present Value of the Residual Value Cash Inflow
         IF (l_rate /l_cf_ppy = -1) or ((l_periods < 1) AND (l_rate /l_cf_ppy <= -1))
          THEN
            OKL_API.SET_MESSAGE (
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_IRR_ZERO_DIV');
            l_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          l_disc_rate := 1 / POWER((1 + l_rate /(l_cf_ppy)), l_periods);
          l_temp_amount := l_cf_amount  * l_disc_rate;
          l_npv := l_npv + nvl(l_temp_amount,0);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      round( l_cf_dpp,4) || ' | ' || l_cf_ppy || ' | ' || l_days_in_future
                      || ' | ' || round(l_periods,4) || ' | ' || round(l_cf_amount,4)
                      || ' | ' || round(l_rate,4) || ' | ' || round(l_disc_rate,4)
                      || ' | ' || round(l_temp_amount, 4) );
          -- Increment the Index of the Residuals Table
          res_index := l_residuals_tbl.NEXT(res_index);
        END LOOP;
      END IF;
      -- Handling the Present Value of the Cash Inflows
      IF l_cash_inflow_strms_tbl.COUNT > 0
      THEN
        IF p_pricing_method = 'SY'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      'Cash Inflows -------------------------------------------------------------' );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      'DPP | PPY | Periods | Inflow Amount | Rate | Discount Rate | Present Value' );
        ELSE
          -- Pricing Method is TR
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      'Targetted Net Present Value: ' || round(l_npv,0) );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      'Cash Inflows ------------------------------------------' );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       '--- |---- |-------- |--------| Discount  | Accumulated |' );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       'DPP | PPY | Days | Periods |  Rate  | Rate/Term |  Interest   |' );
        END IF;
        cin_index := l_cash_inflow_strms_tbl.FIRST;
        WHILE cin_index <= l_cash_inflow_strms_tbl.LAST
        LOOP
          l_cf_dpp          :=  l_cash_inflow_strms_tbl(cin_index).cf_dpp;
          l_cf_ppy          :=  l_cash_inflow_strms_tbl(cin_index).cf_ppy;
          l_cf_amount       :=  l_cash_inflow_strms_tbl(cin_index).cf_amount;
          l_cf_date         :=  l_cash_inflow_strms_tbl(cin_index).cf_date;
          l_days_in_future  :=  l_cash_inflow_strms_tbl(cin_index).cf_days;
          IF l_cf_dpp <> 0
          THEN
            l_periods         :=  l_days_in_future / l_cf_dpp;
          ELSE
            l_periods := 0;
          END IF;
          -- This is the variable you will be changing based on the
          -- Pricing Method ..
          -- Say like for Target Payment you will be using l_irr as l_rate
          --  when for Target Rate you will be using the l_cash_inflow_strms_tbl(cin_index).cf_rate ..
          IF p_pricing_method = 'SY'
          THEN
            l_rate :=  l_irr;
            IF (l_rate /l_cf_ppy = -1) or ((l_periods < 1) AND (l_rate /l_cf_ppy <= -1))
          THEN
            OKL_API.SET_MESSAGE (
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_IRR_ZERO_DIV');
            l_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Now, calculate the Present Value of the Cash Inflows
            l_disc_rate := 1/ POWER((1 + l_rate /(l_cf_ppy)), l_periods);
            l_temp_amount := l_cf_amount  * l_disc_rate;
            l_npv := l_npv + l_temp_amount;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       l_cf_dpp || ' | ' || l_cf_ppy || ' | ' || l_days_in_future
                       || ' | ' || round(l_periods,4) || ' | ' || round(l_cf_amount,4)
                       || ' | ' || round(l_rate,4) || ' | ' || round(l_disc_rate, 4)
                       || ' | ' || round(l_temp_amount,4) );
          ELSIF p_pricing_method = 'TR'
          THEN
            IF nvl(l_cash_inflow_strms_tbl(cin_index).locked_amt, 'N') = 'N'
            THEN
              -- Rate given, need to solve for Payment
              l_rate := l_cash_inflow_strms_tbl(cin_index).cf_rate;
              IF (l_rate /l_cf_ppy = -1) or ((l_periods < 1) AND (l_rate /l_cf_ppy <= -1))
              THEN
                OKL_API.SET_MESSAGE (
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_IRR_ZERO_DIV');
                l_return_status := OKL_API.G_RET_STS_ERROR;
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
              l_term_interest    := 1/ POWER((1 + l_rate /(l_cf_ppy)), l_periods);
              l_acc_term_interest := l_acc_term_interest + l_term_interest;
              put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                          l_cf_dpp  || ' | ' || l_cf_ppy || ' | ' || l_days_in_future || ' | ' || round(l_periods,4)
                          || ' | ' || round(l_rate,4) || ' | ' || round(l_term_interest, 4)
                          || ' | ' || round(l_acc_term_interest,4) );
            ELSE
              -- The possible case is that the Quote Pricing method is TR and User has entered Income/Misc Fee with proper Amount.
              -- In such a case, pricing should consider the amount using the Rate which is being stored at the Cash flow levels of the Fees
              -- NOTE: Be sure that the fee streams has the Rate populated, may be pricing only needs to populate them
              --       as front end may not take the responsibility of updating the CFL with the target_rate.
              l_disc_rate := 1 / POWER((1 + l_cash_inflow_strms_tbl(cin_index).cf_rate /(l_cf_ppy)), l_periods);
              l_temp_amount := l_cf_amount  * l_disc_rate;
              l_npv := l_npv + nvl(l_temp_amount,0);
              put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                round( l_cf_dpp,4) || ' | ' || l_cf_ppy || ' | ' || l_days_in_future || ' | ' || round(l_periods,4) || ' | ' || round(l_cf_amount,4)
                || ' | ' || round(l_cash_inflow_strms_tbl(cin_index).cf_rate,4) || ' | ' || round(l_disc_rate,4) || ' | ' || round(l_temp_amount, 4) );
            END IF;
          END IF; -- IF based on Pricing method
          -- Increment the Index of the Residuals Table
          cin_index := l_cash_inflow_strms_tbl.NEXT(cin_index);
        END LOOP;
      END IF;
      -- Handling the Present Value of the Cash Outflows
      IF l_cash_outflow_strms_tbl.COUNT > 0
      THEN
        IF p_pricing_method = 'SY'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      'Cash Outflows: -------------------------------------------------------------' );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'DPP | PPY | Periods | Inflow Amount | Rate | Discount Rate | Present Value' );
        ELSE
          -- Pricing Method is TR
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Targetted Net Present Value: ' || round(l_npv,0) );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Cash Outflows ------------------------------------------' );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '--- |---- |-------- |--------| Discount  | Accumulated |' );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      'DPP | PPY | Days | Periods |  Rate  | Rate/Term |  Interest   |' );
        END IF;
        cout_index := l_cash_outflow_strms_tbl.FIRST;
        WHILE cout_index <= l_cash_outflow_strms_tbl.LAST
        LOOP
          l_cf_dpp          :=  l_cash_outflow_strms_tbl(cout_index).cf_dpp;
          l_cf_ppy          :=  l_cash_outflow_strms_tbl(cout_index).cf_ppy;
          l_cf_amount       :=  l_cash_outflow_strms_tbl(cout_index).cf_amount;
          l_cf_date         :=  l_cash_outflow_strms_tbl(cout_index).cf_date;
          l_days_in_future  :=  l_cash_outflow_strms_tbl(cout_index).cf_days;
          IF l_cf_dpp <> 0
          THEN
            l_periods         :=  l_days_in_future / l_cf_dpp;
          ELSE
            l_periods := 0;
          END IF;
          IF p_pricing_method = 'SY'
          THEN
            l_rate :=  l_irr;
            IF (l_rate /l_cf_ppy = -1) or ((l_periods < 1) AND (l_rate /l_cf_ppy <= -1))
            THEN
              OKL_API.SET_MESSAGE (
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_IRR_ZERO_DIV');
              l_return_status := OKL_API.G_RET_STS_ERROR;
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Now, calculate the Present Value of the Cash Inflows
            l_disc_rate := 1/ POWER((1 + l_rate /(l_cf_ppy)), l_periods);
            l_temp_amount := l_cf_amount  * l_disc_rate;
            l_npv := l_npv + l_temp_amount;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                        l_cf_dpp || ' | ' || l_cf_ppy || ' | ' || l_days_in_future
                        || ' | ' || round(l_periods,4) || ' | ' || round(l_cf_amount,4)
                        || ' | ' || round(l_rate,4) || ' | ' || round(l_disc_rate, 4)
                        || ' | ' || round(l_temp_amount,4) );
          ELSIF p_pricing_method = 'TR'
          THEN
            IF nvl(l_cash_outflow_strms_tbl(cout_index).locked_amt, 'N') = 'N'
            THEN
              -- Rate given, need to solve for Payment
              l_rate := l_cash_outflow_strms_tbl(cout_index).cf_rate;
              IF (l_rate /l_cf_ppy = -1) or ((l_periods < 1) AND (l_rate /l_cf_ppy <= -1))
              THEN
                OKL_API.SET_MESSAGE (
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_IRR_ZERO_DIV');
                l_return_status := OKL_API.G_RET_STS_ERROR;
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
              l_term_interest    := 1/ POWER((1 + l_rate /(l_cf_ppy)), l_periods);
              l_acc_term_interest := l_acc_term_interest + l_term_interest;
              put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                l_cf_dpp || ' | ' || l_cf_ppy || ' | ' || round(l_periods,4) || ' | ' || round(l_rate,4) || ' | ' || round(l_term_interest, 4)
                || ' | ' || round(l_acc_term_interest,4) );
            ELSE
              l_disc_rate := 1 / POWER((1 + l_cash_outflow_strms_tbl(cout_index).cf_rate /(l_cf_ppy)), l_periods);
              l_temp_amount := l_cf_amount  * l_disc_rate;
              l_npv := l_npv + nvl(l_temp_amount,0);
              put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                round( l_cf_dpp,4) || ' | ' || l_cf_ppy || ' | ' ||
                l_days_in_future || ' | ' || round(l_periods,4) || ' | ' ||
                round(l_cf_amount,4)  || ' | ' || round(l_cash_outflow_strms_tbl(cout_index).cf_rate,4)
                || ' | ' || round(l_disc_rate,4) || ' | ' || round(l_temp_amount, 4) );
            END IF;
          END IF; -- IF based on Pricing method
          -- Increment the Index of the Residuals Table
          cout_index := l_cash_outflow_strms_tbl.NEXT(cout_index);
        END LOOP;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S', 'NPV : ' || round(l_npv,4) );
      -- If Pricing Method is Solve for Payments ..
      IF p_pricing_method = 'SY'
      THEN
        -- With the current l_irr rate if the NPV is nearly zero ..
        --  then return the current rate as the final irr ...
        IF ROUND( l_npv, l_precision + 4 ) = 0
        THEN
          -- If the net present value is ZERO
-------------------------------------------------------
-- Need to place the code to return the payment too ...
-------------------------------------------------------
          px_irr := l_irr;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                        'INTERNAL RATE OF RETURN = ' || px_irr );
          EXIT;
        END IF;
      ELSIF p_pricing_method = 'TR'
      THEN
        -- Calculate the Payment and exit .. ..( NO LOOPING ...)
        IF ROUND( l_acc_term_interest, l_precision + 4 ) = 0
        THEN
          OKL_API.SET_MESSAGE (
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_IRR_ZERO_DIV');
          l_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (l_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        x_payment := -l_npv/ l_acc_term_interest;
        px_irr := l_irr;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                        'CALCULATED PAYMENT AMOUNT = ' || round( x_payment,4) );
        EXIT;
      END IF; -- p_pricing_method IF

      IF p_pricing_method = 'SY' THEN
        -- Determine whether we are having NPVs with different signs ..
        IF SIGN(l_npv) <> SIGN(l_prev_npv) AND
           l_crossed_zero = 'N'            AND
           n_iterations > 1                THEN
          l_crossed_zero := 'Y';
          IF  SIGN( l_npv) = 1   THEN
            l_positive_npv     := l_npv;
            l_negative_npv     := l_prev_npv;
            l_positive_npv_irr := l_irr;
            l_negative_npv_irr := l_prev_irr;
          ELSE
            l_positive_npv     := l_prev_npv;
            l_negative_npv     := l_npv;
            l_positive_npv_irr := l_prev_irr;
            l_negative_npv_irr := l_irr;
          END IF;
        END IF;

        IF( SIGN(l_npv) = 1) THEN
          l_positive_npv := l_npv;
          l_positive_npv_irr := l_irr;
        ELSE
          l_negative_npv := l_npv;
          l_negative_npv_irr := l_irr;
        END IF;
        IF l_crossed_zero = 'Y'
        THEN
          -- Means First time we have got two opposite signed NPVs
          -- Introducing Interpolation approach instead of the Binary Method
          IF n_iterations > 1 then
            l_abs_incr_rate := abs(( l_positive_npv_irr - l_negative_npv_irr )
                          / ( l_positive_npv - l_negative_npv )  * l_positive_npv) ;
            IF ( l_positive_npv_irr < l_negative_npv_irr ) THEN
              l_irr := l_positive_npv_irr + l_abs_incr_rate;
            ELSE
              l_irr := l_positive_npv_irr - l_abs_incr_rate;
            END IF;
            l_irr_decided := 'Y';
          ELSE
            -- Feel so we wont be here any time ..
            -- Use Binary Method to reach the desired IRR
            l_abs_incr_rate := ABS(l_increment_rate) / 2;
          END IF;
        ELSE
          -- If still not crossed zero, increment the rate with l_increment_rate as it is ..
          l_abs_incr_rate := ABS(l_increment_rate);
        END IF;
        IF n_iterations > 1                   THEN
          IF SIGN(l_npv) <> SIGN(l_prev_npv)  THEN
            IF l_prev_incr_sign = 1           THEN
              -- Change sign of the increment if the current and previous npvs are of different signs
              l_increment_rate := - l_abs_incr_rate;
            ELSE
              -- Proceed with the same increment if the current and previous npvs are of same sign
              l_increment_rate := l_abs_incr_rate;
            END IF; -- l_prev_incr_sign
          ELSE -- IF SIGN(l_npv) <> SIGN(l_prev_npv)
            -- Current and Previous npvs are of same signs
            IF l_prev_incr_sign = 1          THEN
              -- Proceed with the same increment
              l_increment_rate := l_abs_incr_rate;
            ELSE
              l_increment_rate := - l_abs_incr_rate;
            END IF;
          END IF;
        ELSE -- Else for n_iterations If ..
          -- First Iteration ...
          IF SIGN(l_npv) = -1
          THEN
            l_increment_rate := -l_increment_rate;
          END IF;
        END IF; -- n_iteratios if ..
        l_prev_irr        := l_irr;
        IF l_irr_decided = 'N'
        THEN
          l_irr             :=  l_irr + l_increment_rate;
        ELSE
          -- l_irr has been already decided .. just change the flag here ..
          l_irr_decided := 'N';
        END IF;
        -- If IRR exceeded the limit set in the profile, then raise an error
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_irr ' || round( l_irr, 4 ) );
        IF ABS(l_irr) > l_irr_limit         THEN
          OKL_API.SET_MESSAGE (
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_IRR_CALC_IRR_LIMIT',
            p_token1       => 'IRR_LIMIT',
            p_token1_value => l_irr_limit*100);
            x_return_status := OKL_API.G_RET_STS_ERROR;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '---------------- IRR crossed the limit --------------------------- ' );
          RAISE OKL_API.G_EXCEPTION_ERROR;
          --EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        l_prev_incr_sign  :=  SIGN(l_increment_rate);
        l_prev_npv_sign   :=  SIGN(l_npv);
        l_prev_npv        :=  l_npv;
      END IF;
    END LOOP; -- (Loop on n_iterations .. )
    -- Setting up the return variables
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END compute_irr;
  -- Procedure -- for solving the Financed Amount when EOTs
  --   are of type Percent !
  -- Please be sure that no down payments, Trade in , Subsidy are being
  -- passed in the pricing param recrod, they need to be handled irrespective
  -- whether they are direct amounts or percentage of Asset Cost.
  PROCEDURE compute_iir_sfp(
              p_api_version             IN             NUMBER,
              p_init_msg_list           IN             VARCHAR2,
              x_return_status           OUT     NOCOPY VARCHAR2,
              x_msg_count               OUT     NOCOPY NUMBER,
              x_msg_data                OUT     NOCOPY VARCHAR2,
              p_start_date              IN             DATE,
              p_day_count_method        IN             VARCHAR2,
              p_pricing_method          IN             VARCHAR2,
              p_initial_guess           IN             NUMBER,
              px_pricing_parameter_rec  IN  OUT NOCOPY pricing_parameter_rec_type,
              px_iir                    IN  OUT NOCOPY NUMBER,
              x_closing_balance         OUT     NOCOPY NUMBER,
              x_residual_percent        OUT     NOCOPY NUMBER,
              x_residual_int_factor     OUT     NOCOPY NUMBER)
  AS
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'compute_iir_sfp';
    l_return_status               VARCHAR2(1);

    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    l_days_in_month          VARCHAR2(30);
    l_days_in_year           VARCHAR2(30);
    l_start_date             DATE;
    l_cash_inflows_tbl       cash_inflows_tbl_type;
    l_asset_cost             NUMBER;
    l_residual_amount        NUMBER;
    l_next_cif_date          DATE;
    l_residuals_tbl          cash_inflows_tbl_type;
    cf_index                 NUMBER;
    res_index                NUMBER;
    i                        NUMBER;
    l_opening_bal            NUMBER;
    l_closing_bal            NUMBER;
    l_rate                   NUMBER;
    l_iir                    NUMBER;
    l_days_per_annum         NUMBER;
    l_interest_factor        NUMBER;
    l_residual_percent       NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- Call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S','-Start' );
    get_days_in_year_and_month(
      p_day_count_method => p_day_count_method,
      x_days_in_month    => l_days_in_month,
      x_days_in_year     => l_days_in_year,
      x_return_status    => l_return_status);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S','After get_day_count_method ' || l_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'l_days_in_month= ' || l_days_in_month || ' |  l_days_in_year = ' || l_days_in_year);
    -- Initializations
    l_start_date             := p_start_date;
    l_asset_cost             := nvl(px_pricing_parameter_rec.financed_amount, 0);
    l_residuals_tbl          := px_pricing_parameter_rec.residual_inflows;
    l_residual_amount        := 0;
    -- Introducing new pricing method called SFR, to
    --  Handle the SF method when the Residual Amt is percentage of OEC
    IF p_pricing_method <> 'SFP'
    THEN
      -- Not handling other pricing scenarios as of now
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Compute_iir_sfp currently supports only Solve for Financed Amount EOT Percent Pricing method only' );
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKL_LP_INVALID_PRICING_METHOD');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF px_pricing_parameter_rec.cash_inflows IS NOT NULL AND
       px_pricing_parameter_rec.cash_inflows.COUNT > 0
    THEN
      cf_index          := px_pricing_parameter_rec.cash_inflows.FIRST;
      i                 := 1;  -- Store inflows as an 1-Based Array
      l_next_cif_date   := p_start_date;
      -- Loop thorugh the Cash Inflows ..
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Cash Inflows: --------------------------------------------------- ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Date | Amount | Days | Purpose| Arrears | Interest Acc. on Capital |l_next_cif_date ' );
      WHILE cf_index <= px_pricing_parameter_rec.cash_inflows.LAST
      LOOP
        -- Copy a record from px_table to l_cash_inflows_tbl ..
        -- rate, cf_date, is_arrears, cf_miss_pay, amount .. will be copied
        l_cash_inflows_tbl(i) := px_pricing_parameter_rec.cash_inflows(cf_index);
        l_cash_inflows_tbl(i).cf_days := GET_DAY_COUNT(
          p_days_in_month    => l_days_in_month,
          p_days_in_year     => l_days_in_year,
          p_start_date       => l_next_cif_date,
          p_end_date         => l_cash_inflows_tbl(i).cf_date,
          p_arrears          => l_cash_inflows_tbl(i).is_arrears,
          x_return_status    => l_return_status);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF ( l_cash_inflows_tbl(i).cf_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT')
        THEN
          l_cash_inflows_tbl(i).cf_purpose := 'P';
        ELSIF ( l_cash_inflows_tbl(i).cf_purpose = 'UNSCHEDULED_INTEREST_PAYMENT')
        THEN
          l_cash_inflows_tbl(i).cf_purpose := 'I';
        ELSE
          l_cash_inflows_tbl(i).cf_purpose := 'B';
        END IF;
        -- Interest calculated for l_next_cif_date to l_cash_inflows_tbl(i).cf_date
        l_days_per_annum := get_days_per_annum(
                              p_day_convention   => p_day_count_method,
                              p_start_date       => p_start_date,
                              p_cash_inflow_date => l_cash_inflows_tbl(i).cf_date,
                              x_return_status    => l_return_status );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Sum the Interest based on the capitalized amount
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                l_cash_inflows_tbl(i).cf_date || '|' || round(l_cash_inflows_tbl(i).cf_amount,4)
                || '|' || l_cash_inflows_tbl(i).cf_days || '|' || l_cash_inflows_tbl(i).cf_purpose
                || '|' || l_cash_inflows_tbl(i).is_Arrears || '|' || '--'
                || '|' || l_next_cif_date);
        -- Incrementing the Start Date for next period
        l_next_cif_date  :=  l_cash_inflows_tbl(cf_index).cf_date;
        IF l_cash_inflows_tbl(cf_index).is_arrears = 'Y'
        THEN
          l_next_cif_date  :=  l_next_cif_date + 1;
        END IF;
        -- Increment the indexes
        cf_index := px_pricing_parameter_rec.cash_inflows.NEXT(cf_index);
        i := i + 1;
      END LOOP; -- End While Looping on px_cash_inflow_tbl
    END IF; -- If px_cash_inflow_tbl
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Residuals: -------------------------------------' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Date | Residual Amount | Days | Purpose| Arrears' );
    -- Handling Residual Value Streams
    IF l_residuals_tbl.COUNT > 0
    THEN
      res_index := l_residuals_tbl.FIRST;
      WHILE res_index <= l_residuals_tbl.LAST
      LOOP
        l_residual_amount := l_residual_amount + l_residuals_tbl(res_index).cf_amount;
        -- To get rate, instead of using the get_rate api, we can directly take the rate from the
        --   last inflow ..
        l_residuals_tbl(res_index).cf_rate := l_cash_inflows_tbl(l_cash_inflows_tbl.LAST).cf_rate;
        IF l_next_cif_date >= l_residuals_tbl( res_index ).cf_date
        THEN
          l_residuals_tbl(res_index).cf_days := 0;
        ELSE
          l_residuals_tbl(res_index).cf_days := GET_DAY_COUNT(
            p_days_in_month    => l_days_in_month,
            p_days_in_year     => l_days_in_year,
            p_start_date       => l_next_cif_date,
            p_end_date         => l_residuals_tbl(res_index).cf_date,
            p_arrears          => 'Y',
            x_return_status    => l_return_status);
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF; -- IF l_next_cif_date >= l_residuals_tbl( res_index ).cf_date
        l_next_cif_date := l_residuals_tbl( res_index ).cf_date;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               l_residuals_tbl(res_index).cf_date || '|' || round(l_residuals_tbl(res_index).cf_amount,4)
               || '|' || l_residuals_tbl(res_index).cf_days || '|' || l_residuals_tbl(res_index).cf_purpose
               || '|' || l_residuals_tbl(res_index).is_Arrears);
        -- Increment the Residual Table Index
        res_index := l_residuals_tbl.NEXT( res_index );
      END LOOP;
    END IF;
    -- Compute_iir can directly calculate the Financed Amount/Subsidy/Down payment/Trade in Amount
    -- without any iterations !!
    IF p_pricing_method = 'SFP'
    THEN
      -- Pricing Logic for Solve for Financed Amount/ Solve for Subsidy
      l_opening_bal := 0;
      l_closing_bal := 0;  -- Targetting l_closing_bal as zero
      l_rate        := 0;
      l_interest_factor := 1;
      l_residual_percent := 0;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Targeting Closing Balance: ' || l_closing_bal );
      IF l_residuals_tbl IS NOT NULL AND
         l_residuals_tbl.COUNT > 0
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Residual Details: -----------------------------------------------------------------' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Days/Annum | Rate | Closing Balance|Days|Residual Amount|Interest Factor on Res. Amount|Opening Balance' );
        res_index := l_residuals_tbl.COUNT;
        WHILE res_index >= 1
        LOOP
          IF p_pricing_method = 'SFP'
          THEN
            l_days_per_annum := get_days_per_annum(
                                  p_day_convention   => p_day_count_method,
                                  p_start_date       => p_start_date,
                                  p_cash_inflow_date => l_residuals_tbl(res_index).cf_date,
                                 x_return_status    => l_return_status );
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Sum the Residual Percentage. Cf_amount will be storing the percentages
            --  instead of directly the amounts
            l_residual_percent := l_residual_percent + nvl( l_residuals_tbl(res_index).cf_amount, 0);
            l_rate := 1 + ( l_residuals_tbl(res_index).cf_days *
                          l_residuals_tbl(res_index).cf_rate /l_days_per_annum );
            -- Multiply this interest factor
            l_interest_factor := l_interest_factor * l_rate;
          END IF;
          -- Decrement the Iterator
          res_index := res_index - 1;
        END LOOP;
      ELSE
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'No Residual Amounts Passed !!! ' );
      END IF;
      IF l_cash_inflows_tbl IS NOT NULL AND
         l_cash_inflows_tbl.COUNT > 0
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Inflows Details: ------------------------------------------------------------------' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Days/Annum | Rate | Closing Balance|Days|Inflow Amount|Interest Factor on Inflow Amount|Opening Balance' );
        -- Looping through Inflows in Reverse way
        cf_index := l_cash_inflows_tbl.COUNT;
        WHILE cf_index >= 1
        LOOP
          l_days_per_annum := get_days_per_annum(
                                p_day_convention   => p_day_count_method,
                                p_start_date       => p_start_date,
                                p_cash_inflow_date => l_cash_inflows_tbl(cf_index).cf_date,
                                x_return_status    => l_return_status );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          l_rate := 1 + ( l_cash_inflows_tbl(cf_index).cf_days *
                          l_cash_inflows_tbl(cf_index).cf_rate /l_days_per_annum );
          -- Multiply this interest factor
          l_interest_factor := l_interest_factor * l_rate;
          l_opening_bal := ( l_closing_bal + l_cash_inflows_tbl(cf_index).cf_amount ) / l_rate;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  l_days_per_annum || '|' || l_cash_inflows_tbl(cf_index).cf_rate || ' | ' || round(l_closing_bal,4) || '|' || l_cash_inflows_tbl(cf_index).cf_days
                  || '|' || round(l_cash_inflows_tbl(cf_index).cf_amount,4) || '|' || round( l_rate, 4 )
                  || '|' || round(l_opening_bal,4));
          l_closing_bal := l_opening_bal;
          -- Decrement the Iterator
          cf_index := cf_index - 1;
        END LOOP;
      END IF; -- IF l_cash_inflow_tbl is not null
      -- Now, after looping through the Residuals and then the Rent Inflows,
      -- the Opening Balance is nothing but the Financed Amount.
      --   The opening balance is the amount represent which should be the starting
      --   Financed Amount such that at the end the closing balance is ZERO.
      -- The above logic is just nothing but the Reverse Approach !!
      -- Store the Financed Amount and return now !
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        ' Closing Balance | Residual Percent | Residual Interest Factor ');
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        ROUND( l_closing_bal, 4 ) || ' | ' || round(l_residual_percent, 4) || '  | ' || round(l_interest_factor, 4));
      -- Solve for Financed Amount Logic when the Residuals are percentage of OEC
      x_closing_balance := l_closing_bal; -- This is the OEC'
      x_residual_percent := l_residual_percent;
      x_residual_int_factor := l_interest_factor;
    END IF;
    -- Set ther return values and return them !!
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END compute_iir_sfp;
  -- Procedure: Calculation of the IIR
  PROCEDURE compute_iir(
              p_api_version             IN             NUMBER,
              p_init_msg_list           IN             VARCHAR2,
              x_return_status           OUT     NOCOPY VARCHAR2,
              x_msg_count               OUT     NOCOPY NUMBER,
              x_msg_data                OUT     NOCOPY VARCHAR2,
              p_start_date              IN             DATE,
              p_day_count_method        IN             VARCHAR2,
              p_pricing_method          IN             VARCHAR2,
              p_initial_guess           IN             NUMBER,
              px_pricing_parameter_rec  IN  OUT NOCOPY pricing_parameter_rec_type,
              px_iir                    IN  OUT NOCOPY NUMBER,
              x_payment                 OUT     NOCOPY NUMBER)
  AS
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'compute_iir';
    l_return_status               VARCHAR2(1);

    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    l_days_in_month          VARCHAR2(30);
    l_days_in_year           VARCHAR2(30);
    l_start_date             DATE;
    l_cash_inflows_tbl       cash_inflows_tbl_type;
    l_asset_cost             NUMBER;
    l_tradein_amt            NUMBER;
    l_subsidy_amt            NUMBER;
    l_downpayment_amt        NUMBER;
    l_ast_cap_fee_amt        NUMBER;
    l_residual_amount        NUMBER;
    l_next_cif_date          DATE;
    l_residuals_tbl          cash_inflows_tbl_type;
    l_investment             NUMBER;
    l_adv_amount             NUMBER;
    l_interest               NUMBER;
    cf_index                 NUMBER;
    res_index                NUMBER;
    i                        NUMBER;
    n_iterations             NUMBER;
    l_opening_bal            NUMBER;
    l_closing_bal            NUMBER;
    l_payment                NUMBER;
    l_principal_payment      NUMBER;
    l_diff                   NUMBER;
    l_prev_diff              NUMBER;
    l_positive_diff_pay      NUMBER := 0;
    l_negative_diff_pay      NUMBER := 0;
    l_positive_diff          NUMBER := 0;
    l_negative_diff          NUMBER := 0;
    l_crossed_zero           VARCHAR2(1);
    l_periodic_amount        NUMBER;
    l_prev_periodic_amount   NUMBER := 0;
    l_increment              NUMBER;
    l_abs_incr               NUMBER;
    l_prev_incr_sign         NUMBER;
    l_prev_diff_sign         NUMBER;
    l_rate                   NUMBER;
    l_iir                    NUMBER;
    l_prev_iir               NUMBER;
    l_positive_diff_iir      NUMBER;
    l_negative_diff_iir      NUMBER;
    l_days_per_annum         NUMBER;
    l_interest_factor        NUMBER;
    l_residual_percent       NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- Call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S','-Start' );
    get_days_in_year_and_month(
      p_day_count_method => p_day_count_method,
      x_days_in_month    => l_days_in_month,
      x_days_in_year     => l_days_in_year,
      x_return_status    => l_return_status);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S','After get_day_count_method ' || l_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'l_days_in_month= ' || l_days_in_month || ' |  l_days_in_year = ' || l_days_in_year);
    -- Initializations
    l_start_date             := p_start_date;
    l_asset_cost             := nvl(px_pricing_parameter_rec.financed_amount, 0);
    l_tradein_amt            := nvl(px_pricing_parameter_rec.trade_in, 0);
    l_subsidy_amt            := nvl(px_pricing_parameter_rec.subsidy, 0);
    l_downpayment_amt        := nvl(px_pricing_parameter_rec.down_payment, 0);
    l_ast_cap_fee_amt        := nvl(px_pricing_parameter_rec.cap_fee_amount, 0);
    l_residuals_tbl          := px_pricing_parameter_rec.residual_inflows;
    l_periodic_amount        := 0;
    l_investment             := 0;
    l_adv_amount             := 0;
    l_interest               := 0;
    l_residual_amount        := 0;
    -- Introducing new pricing method called SFR, to
    --  Handle the SF method when the Residual Amt is percentage of OEC
    IF p_pricing_method <> 'SP'  AND
       p_pricing_method <> 'SM'  AND
       p_pricing_method <> 'SF'  AND
       p_pricing_method <> 'SFP' AND
       p_pricing_method <> 'SS'  AND
       p_pricing_method <> 'SY'  AND
       p_pricing_method <> 'SI'  AND -- Solve for Trade in
       p_pricing_method <> 'SD'  AND
       p_pricing_method <> 'TR'  AND
       p_pricing_method <> 'SPP'
    THEN
      -- Not handling other pricing scenarios as of now
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Compute_iir currently supports only Solve for Payment, Solve for Financed Amount, ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Solve for Subsidy, Solve for Subsidy, Down Payment, Tradein, Missing Payment Pricing Scenarios only, Target Rate ( IIR) ' );
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKL_LP_INVALID_PRICING_METHOD');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF p_pricing_method = 'SP' OR
       p_pricing_method = 'SY' OR
       p_pricing_method = 'SM' OR
       p_pricing_method = 'TR' OR
       p_pricing_method = 'SPP'
    THEN
      -- Solve for Payment Scenario
      -- So, validate whether we have been given the Financed Amount,
      --   and Residual Value properly atleast
      IF px_pricing_parameter_rec.financed_amount IS NULL
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Financed Amount cannot be null .. Pricing Method '|| p_pricing_method );
        -- Raise an Error

        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- The cash inflows should have rate populated !
      FOR t IN px_pricing_parameter_rec.cash_inflows.FIRST ..
               px_pricing_parameter_rec.cash_inflows.LAST
      LOOP
        IF px_pricing_parameter_rec.cash_inflows(t).cf_rate IS NULL AND
           p_pricing_method <> 'SY'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Streams Passed are not having the Rate. Pricing Method '|| p_pricing_method );
          -- Raise an Error
          OKL_API.set_message(
            G_APP_NAME,
            OKL_API.G_INVALID_VALUE,
            OKL_API.G_COL_NAME_TOKEN,
            'CF_RATE');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
    END IF;
    IF p_pricing_method = 'SF' AND
       p_pricing_method = 'SFP'
    THEN
      -- Place validations for Solve for Financed Amount, such that
      -- Rate and Amounts should be present for all inflows in the px_cash_inflow_tbl table
      -- Also, validations what we need to impose for this table is
      -- a/ The inflow elements table should be ordered by date
      NULL;
    END IF;
    IF p_pricing_method = 'SS'
    THEN
      -- Solve for Subsidy Scenario
      -- So, validate whether we have been given the Financed Amount, Cash Inflows
      --   and Residual Value properly atleast
      IF px_pricing_parameter_rec.financed_amount IS NULL
      THEN
        -- Raise an Error
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- Calculate the Investment ..
    -- C - S - D - T
    l_investment := l_asset_cost - l_tradein_amt - l_subsidy_amt - l_downpayment_amt + l_ast_cap_fee_amt;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Investment including the Cap. Fee for this Asset (l_investment) ' || l_investment );
    IF px_pricing_parameter_rec.cash_inflows IS NOT NULL AND
       px_pricing_parameter_rec.cash_inflows.COUNT > 0
    THEN
      cf_index          := px_pricing_parameter_rec.cash_inflows.FIRST;
      i                 := 1;  -- Store inflows as an 1-Based Array
      l_next_cif_date   := p_start_date;
      -- Loop thorugh the Cash Inflows ..
      --  1/ Calculate the days, average rate if rates are different ..
      --  2/ Sum the amounts which you are getting on or before the p_start_date
      --      into l_adv_amount, so that we can later validate such that
      --      l_investment should be greater than the l_adv_amount
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Cash Inflows: --------------------------------------------------- ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Date | Amount | Days | Purpose| Arrears | Interest Acc. on Capital |l_next_cif_date | cf_ratio ' );
      WHILE cf_index <= px_pricing_parameter_rec.cash_inflows.LAST
      LOOP
        -- Copy a record from px_table to l_cash_inflows_tbl ..
        -- rate, cf_date, is_arrears, cf_miss_pay, amount .. will be copied
        l_cash_inflows_tbl(i) := px_pricing_parameter_rec.cash_inflows(cf_index);
        l_cash_inflows_tbl(i).cf_days := GET_DAY_COUNT(
          p_days_in_month    => l_days_in_month,
          p_days_in_year     => l_days_in_year,
          p_start_date       => l_next_cif_date,
          p_end_date         => l_cash_inflows_tbl(i).cf_date,
          p_arrears          => l_cash_inflows_tbl(i).is_arrears,
          x_return_status    => l_return_status);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF ( l_cash_inflows_tbl(i).cf_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT')
        THEN
          l_cash_inflows_tbl(i).cf_purpose := 'P';
        ELSIF ( l_cash_inflows_tbl(i).cf_purpose = 'UNSCHEDULED_INTEREST_PAYMENT')
        THEN
          l_cash_inflows_tbl(i).cf_purpose := 'I';
        ELSE
          l_cash_inflows_tbl(i).cf_purpose := 'B';
        END IF;
        -- Sum the amounts, which we are getting on or before the Start Date
        IF l_cash_inflows_tbl(i).cf_date <= p_start_date
        THEN
          l_adv_amount := l_adv_amount + nvl( l_cash_inflows_tbl(i).cf_amount, 0 );
        END IF;
        -- Interest calculated for l_next_cif_date to l_cash_inflows_tbl(i).cf_date
        l_days_per_annum := get_days_per_annum(
                              p_day_convention   => p_day_count_method,
                              p_start_date       => p_start_date,
                              p_cash_inflow_date => l_cash_inflows_tbl(i).cf_date,
                              x_return_status    => l_return_status );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Sum the Interest based on the capitalized amount
        l_interest := l_interest +
          (l_investment * l_cash_inflows_tbl(i).cf_rate * l_cash_inflows_tbl(i).cf_days / l_days_per_annum );

        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                l_cash_inflows_tbl(i).cf_date || '|' || round(l_cash_inflows_tbl(i).cf_amount,4)
                || '|' || l_cash_inflows_tbl(i).cf_days || '|' || l_cash_inflows_tbl(i).cf_purpose
                || '|' || l_cash_inflows_tbl(i).is_Arrears || '|' || l_interest
                || '|' || l_next_cif_date || ' | ' || l_cash_inflows_tbl(i).cf_ratio);
        -- Incrementing the Start Date for next period
        l_next_cif_date  :=  l_cash_inflows_tbl(cf_index).cf_date;
        IF l_cash_inflows_tbl(cf_index).is_arrears = 'Y'
        THEN
          l_next_cif_date  :=  l_next_cif_date + 1;
        END IF;
        -- Increment the indexes
        cf_index := px_pricing_parameter_rec.cash_inflows.NEXT(cf_index);
        i := i + 1;
      END LOOP; -- End While Looping on px_cash_inflow_tbl
    END IF; -- If px_cash_inflow_tbl
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Residuals: -------------------------------------' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Date | Residual Amount | Days | Purpose| Arrears' );
    -- Handling Residual Value Streams
    IF l_residuals_tbl.COUNT > 0
    THEN
      res_index := l_residuals_tbl.FIRST;
      WHILE res_index <= l_residuals_tbl.LAST
      LOOP
        l_residual_amount := l_residual_amount + l_residuals_tbl(res_index).cf_amount;
        -- Get rate as on that date when residuals are returned
        -- Instead of using the get_rate api, we can directly take the rate from the
        --   last inflow ..  Think over this !!!
        l_residuals_tbl(res_index).cf_rate := l_cash_inflows_tbl(l_cash_inflows_tbl.LAST).cf_rate;
        IF l_next_cif_date >= l_residuals_tbl( res_index ).cf_date
        THEN
          l_residuals_tbl(res_index).cf_days := 0;
        ELSE
          l_residuals_tbl(res_index).cf_days := GET_DAY_COUNT(
            p_days_in_month    => l_days_in_month,
            p_days_in_year     => l_days_in_year,
            p_start_date       => l_next_cif_date,
            p_end_date         => l_residuals_tbl(res_index).cf_date,
            p_arrears          => 'Y',
            x_return_status    => l_return_status);
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF; -- IF l_next_cif_date >= l_residuals_tbl( res_index ).cf_date
        l_next_cif_date := l_residuals_tbl( res_index ).cf_date;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               l_residuals_tbl(res_index).cf_date || '|' || round(l_residuals_tbl(res_index).cf_amount,4)
               || '|' || l_residuals_tbl(res_index).cf_days || '|' || l_residuals_tbl(res_index).cf_purpose
               || '|' || l_residuals_tbl(res_index).is_Arrears);
        -- Increment the Residual Table Index
        res_index := l_residuals_tbl.NEXT( res_index );
      END LOOP;
    END IF;
    -- Compute_iir can directly calculate the Financed Amount/Subsidy/Down payment/Trade in Amount
    -- without any iterations !!
    -- For solving the Payment/ Missing Payment/Yields compute_iir will use the
    -- iterative interpolation approach !
    IF p_pricing_method = 'SF' OR
       p_pricing_method = 'SS' OR
       p_pricing_method = 'SD' OR
       p_pricing_method = 'SI' OR -- Solve for Tradein
       p_pricing_method = 'SFP'
    THEN
      -- Pricing Logic for Solve for Financed Amount/ Solve for Subsidy
      l_opening_bal := 0;
      l_closing_bal := 0;  -- Targetting l_closing_bal as zero
      l_rate        := 0;
      l_interest_factor := 1;
      l_residual_percent := 0;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Targeting Closing Balance: ' || l_closing_bal );
      IF l_residuals_tbl IS NOT NULL AND
         l_residuals_tbl.COUNT > 0
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Residual Details: -----------------------------------------------------------------' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Days/Annum | Rate | Closing Balance|Days|Residual Amount|Interest Factor on Res. Amount|Opening Balance' );
        res_index := l_residuals_tbl.COUNT;
        WHILE res_index >= 1
        LOOP
          IF p_pricing_method = 'SFP'
          THEN
            -- Sum the Residual Percentage. Cf_amount will be storing the percentages
            --  instead of directly the amounts
            l_residual_percent := l_residual_percent + nvl( l_residuals_tbl(res_index).cf_amount, 0);
          ELSE
            -- Interest calculated from p_start_date to l_residuals_tbl(res_index).cf_date
            l_days_per_annum := get_days_per_annum(
                                  p_day_convention   => p_day_count_method,
                                  p_start_date       => p_start_date,
                                  p_cash_inflow_date => l_residuals_tbl(res_index).cf_date,
                                  x_return_status    => l_return_status );
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            l_rate := 1 + ( l_residuals_tbl(res_index).cf_days *
                            l_residuals_tbl(res_index).cf_rate /l_days_per_annum );
            l_opening_bal := ( l_closing_bal + l_residuals_tbl(res_index).cf_amount ) / l_rate;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    l_days_per_annum || '|'  || l_residuals_tbl(res_index).cf_rate || ' | ' || round(l_closing_bal,4)
                    || '|' || l_residuals_tbl(res_index).cf_days || '|' || round(l_residuals_tbl(res_index).cf_amount,4)
                    || '|' || round( l_rate, 4 ) || '|' || round(l_opening_bal,4));
            l_closing_bal := l_opening_bal;
          END IF;
          -- Decrement the Iterator
          res_index := res_index - 1;
        END LOOP;
      ELSE
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'No Residual Amounts Passed !!! ' );
      END IF;
      IF l_cash_inflows_tbl IS NOT NULL AND
         l_cash_inflows_tbl.COUNT > 0
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Inflows Details: ------------------------------------------------------------------' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Days/Annum | Rate | Closing Balance|Days|Inflow Amount|Interest Factor on Inflow Amount|Opening Balance' );
        -- Looping through Inflows in Reverse way
        cf_index := l_cash_inflows_tbl.COUNT;
        WHILE cf_index >= 1
        LOOP
          -- Interest calculated from p_start_date to l_residuals_tbl(res_index).cf_date
          l_days_per_annum := get_days_per_annum(
                                p_day_convention   => p_day_count_method,
                                p_start_date       => p_start_date,
                                p_cash_inflow_date => l_cash_inflows_tbl(cf_index).cf_date,
                                x_return_status    => l_return_status );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          l_rate := 1 + ( l_cash_inflows_tbl(cf_index).cf_days *
                          l_cash_inflows_tbl(cf_index).cf_rate /l_days_per_annum );
          -- Multiply this interest factor
          IF p_pricing_method = 'SFP'
          THEN
            l_interest_factor := l_interest_factor * l_rate;
          END IF;
          l_opening_bal := ( l_closing_bal + l_cash_inflows_tbl(cf_index).cf_amount ) / l_rate;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  l_days_per_annum || '|' || l_cash_inflows_tbl(cf_index).cf_rate || ' | ' || round(l_closing_bal,4) || '|' || l_cash_inflows_tbl(cf_index).cf_days
                  || '|' || round(l_cash_inflows_tbl(cf_index).cf_amount,4) || '|' || round( l_rate, 4 )
                  || '|' || round(l_opening_bal,4));
          l_closing_bal := l_opening_bal;
          -- Decrement the Iterator
          cf_index := cf_index - 1;
        END LOOP;
      END IF; -- IF l_cash_inflow_tbl is not null
      -- Now, after looping through the Residuals and then the Rent Inflows,
      -- the Opening Balance is nothing but the Financed Amount.
      --   The opening balance is the amount represent which should be the starting
      --   Financed Amount such that at the end the closing balance is ZERO.
      -- The above logic is just nothing but the Reverse Approach !!
      -- Store the Financed Amount and return now !
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_closing_bal | l_investment ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   ROUND( l_closing_bal, 4 ) || ' | ' || ROUND( l_investment, 4) );
      IF p_pricing_method = 'SF'
      THEN
        -- Solve for Financed Amount Logic
        px_pricing_parameter_rec.financed_amount := l_closing_bal - l_investment;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'The Financed Amount should be: ' || round(px_pricing_parameter_rec.financed_amount, 4) );
      ELSIF p_pricing_method = 'SFP'
      THEN
        -- Solve for Financed Amount Logic when the Residuals are percentage of OEC
        px_pricing_parameter_rec.financed_amount := l_closing_bal - l_investment; -- This is the OEC'
        -- RV pays for that part of OEC that is not paid out by the payments.
        -- Hence, the present value of RV is infact the component of OEC that is not paid by the payments.
        -- so, RV component of OEC = RV / interest rate factor
        -- Hence, OEC = RV component of OEC + payments component of OEC ( OEC' )
        --   OEC = RV / interest rate factor + OEC'
        -- OEC = OEC' * interest_factor / ( interest_factor - residual_percent )
        IF l_residual_percent > 0 AND
           (l_interest_factor - l_residual_percent ) <> 0
        THEN
          -- If there was any residual percentage declared then only the
          --  RV Component of OEC will be present.
          -- Also, px_pricing_parameter_rec.financed_amount by now holds the OEC'
          px_pricing_parameter_rec.financed_amount :=
            (px_pricing_parameter_rec.financed_amount * l_interest_factor ) /
            ( l_interest_factor - l_residual_percent);
        END IF;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'The Financed Amount should be: ' || round(px_pricing_parameter_rec.financed_amount, 4) );
      ELSIF p_pricing_method = 'SS'
      THEN
        -- Solve for Subsidy Amount
        px_pricing_parameter_rec.subsidy := l_investment - l_closing_bal;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Subsidy Amount ' || ROUND( px_pricing_parameter_rec.subsidy, 4) );
      ELSIF p_pricing_method = 'SI' -- Solve for Trade-in
      THEN
        -- Solve for Trade in amount ..
        px_pricing_parameter_rec.trade_in := l_investment - l_closing_bal;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Tradein Amount ' || ROUND( px_pricing_parameter_rec.trade_in, 4) );
      ELSIF p_pricing_method = 'SD'
      THEN
        -- Solve for Down payment amount ...
        px_pricing_parameter_rec.down_payment := l_investment - l_closing_bal;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Down Payment Amount ' || ROUND( px_pricing_parameter_rec.down_payment, 4) );
      END IF;  -- IF p_pricing_method
      -- End of Pricing Logic for Solve for Financed Amount/Solve for Subsidy
    ELSIF p_pricing_method = 'SP' OR
          p_pricing_method = 'SY' OR
          p_pricing_method = 'SM' OR    -- Solve for Missing Payment Amount !
          p_pricing_method = 'TR' OR
          p_pricing_method = 'SPP'
    THEN
      -- Initial Guess for the Payment Amount
      -- Formula is based on the Simple Interest Calculation ..
      -- Payment = (l_investment + interest for l_investment based on avg rate - Residual Value )
      --            / Number of Periods
      IF p_pricing_method = 'SP' OR
         p_pricing_method = 'SM' OR
         p_pricing_method = 'TR' OR
         p_pricing_method = 'SPP'
      THEN
        l_periodic_amount := ( l_investment + l_interest - l_residual_amount ) / l_cash_inflows_tbl.COUNT ;
        l_increment  := l_periodic_amount / 2;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_investment | l_interest | l_residual_value | Number of Terms| l_periodic_payment | First Increment' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   round(l_investment, 4) || '|' || round(l_interest, 4) || '|' ||
                   round(l_residual_amount, 4) || '|' || round(l_cash_inflows_tbl.COUNT ) || '|' ||
                   round(l_periodic_amount, 4) || '|' || round(l_increment, 4));
      ELSE
        l_iir := nvl( p_initial_guess, 0.1 );
        l_increment  := 0.1;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_investment | l_residual_value | Initial IIR | First Increment' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   round(l_investment, 4) || '|' || round(l_residual_amount, 4) || '|' ||
                   round(l_iir, 4) || '|' || l_increment);
      END IF;
      -- Logic for Solve for Payments
      n_iterations    := 1;
      l_crossed_zero  := 'N';
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S', 'Iteration # ' || n_iterations );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Cash Inflows: ----------------------------------------------------------------------------' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Days/Annum|Rate|Days|Opening Balance|Payment Amount|Interest Income|Principal Payment|Closing Balance' );
        l_opening_bal   := l_investment;
        FOR cf_index in l_cash_inflows_tbl.FIRST .. l_cash_inflows_tbl.LAST
        LOOP
          IF p_pricing_method = 'SP' OR
             p_pricing_method = 'TR'
          THEN
            l_payment := l_periodic_amount;
            l_rate    := l_cash_inflows_tbl(cf_index).cf_rate;
          ELSIF p_pricing_method = 'SPP'
          THEN
            l_payment := l_periodic_amount * nvl(l_cash_inflows_tbl(cf_index).cf_ratio,1);
            l_rate    := l_cash_inflows_tbl(cf_index).cf_rate;
          ELSIF p_pricing_method = 'SM'
          THEN
            IF l_cash_inflows_tbl(cf_index).cf_rate IS NOT NULL AND
               l_cash_inflows_tbl(cf_index).cf_amount IS NULL
            THEN
              -- Payment level for which the amount is being calculated iteratively !
              l_payment := l_periodic_amount;
              l_rate    := l_cash_inflows_tbl(cf_index).cf_rate;
            ELSE
              l_payment := l_cash_inflows_tbl(cf_index).cf_amount;
              l_rate := l_cash_inflows_tbl(cf_index).cf_rate;
            END IF;
          ELSE
            l_payment := l_cash_inflows_tbl(cf_index).cf_amount;
            l_rate    := l_iir;
          END IF;
          -- Interest calculated for p_start_date to l_cash_inflows_tbl(i).cf_date
          l_days_per_annum := get_days_per_annum(
                                p_day_convention   => p_day_count_method,
                                p_start_date       => p_start_date,
                                p_cash_inflow_date => l_cash_inflows_tbl(cf_index).cf_date,
                                x_return_status    => l_return_status );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          IF ( l_cash_inflows_tbl(cf_index).cf_purpose = 'B' )
          THEN
              l_interest := l_opening_bal * l_cash_inflows_tbl(cf_index).cf_days
                                * l_rate /l_days_per_annum;
          ELSIF ( l_cash_inflows_tbl(cf_index).cf_purpose = 'P' )
          THEN
              l_interest := 0;
          ELSIF ( l_cash_inflows_tbl(cf_index).cf_purpose = 'I' )
          THEN
              l_interest := l_principal_payment;
          END IF;
          l_principal_payment := l_payment - l_interest;
          l_closing_bal       := l_opening_bal - l_principal_payment;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               l_days_per_annum  || '|' || round(l_rate,4)
               || '|' || l_cash_inflows_tbl(cf_index).cf_days
               || '|' || round(l_opening_bal,4)  || '|' || round(l_payment,4)
               || '|' || round(l_interest,4)  || '|' || round(l_principal_payment,4)
               || '|' || round(l_closing_bal,4) );
          l_opening_bal       := l_closing_bal;
        END LOOP;
        IF l_residuals_tbl IS NOT NULL AND
           l_residuals_tbl.COUNT > 0
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S','Residuals: ---------- ' );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Rate|Days|Opening Balance|Residual Amount|Interest Income|Principal Payment|Closing Balance' );

          FOR res_index in l_residuals_tbl.FIRST .. l_residuals_tbl.LAST
          LOOP
            l_payment  := l_residuals_tbl(res_index).cf_amount;
            IF p_pricing_method = 'SP' OR
               p_pricing_method = 'SM' OR
               p_pricing_method = 'TR' OR
               p_pricing_method = 'SPP'
            THEN
              l_rate := l_residuals_tbl(res_index).cf_rate;
            ELSE
              l_rate := l_iir;
            END IF;
            -- Interest calculated for p_start_date to l_cash_inflows_tbl(i).cf_date
            l_days_per_annum := get_days_per_annum(
                                  p_day_convention   => p_day_count_method,
                                  p_start_date       => p_start_date,
                                  p_cash_inflow_date => l_residuals_tbl(res_index).cf_date,
                                  x_return_status    => l_return_status );
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            l_interest := l_opening_bal * l_residuals_tbl(res_index).cf_days
                                        * l_rate /l_days_per_annum;
            l_principal_payment := l_payment - l_interest;
            l_closing_bal       := l_opening_bal - l_principal_payment;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       l_days_per_annum  || '|' || l_rate || '|' || l_residuals_tbl(res_index).cf_days
                        || '|' || round(l_opening_bal,4) || '|' || round(l_residuals_tbl(res_index).cf_amount,4)
                        || '|' || round(l_interest,4) || '|' || round(l_principal_payment, 4)
                        || '|' || round(l_closing_bal,4) );
            l_opening_bal       := l_closing_bal;
          END LOOP;
        END IF;
        l_diff := l_opening_bal;
        IF ROUND( l_diff, 4 ) = 0
        THEN
          IF p_pricing_method = 'SP' OR
             p_pricing_method = 'SM' OR
             p_pricing_method = 'TR' OR
             p_pricing_method = 'SPP'
          THEN
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'CALCULATED PAYMENT AMOUNT = ' || l_periodic_amount );
            x_payment := l_periodic_amount;
          ELSE
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'IMPLICIT INTEREST RATE =' || l_iir );
            px_iir := l_iir;
          END IF;
          x_return_status := OKL_API.G_RET_STS_SUCCESS;

          OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                               x_msg_data   => x_msg_data);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                  'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
          EXIT;
        END IF; -- If ROUND(L_DIFF, 4) = 0
        -- Else Use the Interpolation method
        IF n_iterations > 1 AND
           SIGN(l_diff) <> SIGN(l_prev_diff) AND
           l_crossed_zero = 'N'
        THEN
          l_crossed_zero := 'Y';
          IF ( SIGN( l_diff) = 1 )
          THEN
            -- Positive Diff ones
            l_positive_diff := l_diff;
            l_negative_diff := l_prev_diff;
            IF p_pricing_method = 'SP' OR
               p_pricing_method = 'SM' OR
               p_pricing_method = 'TR' OR
               p_pricing_method = 'SPP'
            THEN
              l_positive_diff_pay := l_periodic_amount;
              l_negative_diff_pay := l_prev_periodic_amount;
            ELSE
              l_positive_diff_iir := l_iir;
              l_negative_diff_iir := l_prev_iir;
            END IF;
           ELSE
            -- Negative Diff ones
            l_positive_diff := l_prev_diff;
            l_negative_diff := l_diff;
            IF p_pricing_method = 'SP' OR
               p_pricing_method = 'SM' OR
               p_pricing_method = 'TR' OR
               p_pricing_method = 'SPP'
            THEN
              l_positive_diff_pay := l_prev_periodic_amount;
              l_negative_diff_pay := l_periodic_amount;
            ELSE
              l_positive_diff_iir := l_prev_iir;
              l_negative_diff_iir := l_iir;
            END IF;
          END IF;  -- IF SIGN(L_DIFF) = 1
        END IF; -- n_iterations > 1 IF
        -- Else if this is the first time store in appropriate variables
        IF( SIGN(l_diff) = 1)
        THEN
          l_positive_diff     := l_diff;
          IF p_pricing_method = 'SP' OR
             p_pricing_method = 'SM' OR
             p_pricing_method = 'TR' OR
             p_pricing_method = 'SPP'
          THEN
            l_positive_diff_pay := l_periodic_amount;
          ELSE
            l_positive_diff_iir := l_iir;
          END IF;
        ELSE
         l_negative_diff     := l_diff;
          IF p_pricing_method = 'SP' OR
             p_pricing_method = 'SM' OR
             p_pricing_method = 'TR' OR
             p_pricing_method = 'SPP'
          THEN
            l_negative_diff_pay := l_periodic_amount;
          ELSE
            l_negative_diff_iir := l_iir;
          END IF;
        END IF;
        IF l_crossed_zero = 'Y' THEN
          -- Use interpolation method ...
          IF n_iterations > 1
          THEN
            IF p_pricing_method = 'SP' OR
               p_pricing_method = 'SM' OR
               p_pricing_method = 'TR' OR
               p_pricing_method = 'SPP'
            THEN
              l_abs_incr :=  abs(( l_positive_diff_pay - l_negative_diff_pay ) /
                             ( l_positive_diff - l_negative_diff )  * l_diff);
            ELSE
              l_abs_incr :=  abs(( l_positive_diff_iir - l_negative_diff_iir ) /
                             ( l_positive_diff - l_negative_diff )  * l_diff);
            END IF;
          ELSE
            l_abs_incr := ABS(l_increment) / 2;
          END IF;
        ELSE
          l_abs_incr := ABS(l_increment);
        END IF;

        IF n_iterations > 1 THEN
          IF SIGN(l_diff) <> l_prev_diff_sign THEN
            IF l_prev_incr_sign = 1 THEN
              l_increment :=  -l_abs_incr;
            ELSE
              l_increment := l_abs_incr;
            END IF;
          ELSE
            IF l_prev_incr_sign = 1 THEN
              l_increment := l_abs_incr;
            ELSE
              l_increment := - l_abs_incr;
            END IF;
          END IF;
        ELSE  -- First Iteration
          IF p_pricing_method = 'SP' OR
             p_pricing_method = 'SM' OR
             p_pricing_method = 'TR' OR
             p_pricing_method = 'SPP'
          THEN
            l_increment := -l_increment;
          END IF;
          IF SIGN(l_diff) = 1 THEN
            l_increment := -l_increment;
          ELSE
            l_increment := l_increment;
          END IF;
        END IF;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_diff         ' || round(l_diff,4) );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_prev_diff    ' || round(l_prev_diff,4) );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_crossed_zero ' || l_crossed_zero );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_abs_incr     ' || l_abs_incr );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_increment    ' || l_increment );
        IF p_pricing_method = 'SP' OR
           p_pricing_method = 'SM' OR
           p_pricing_method = 'TR' OR
           p_pricing_method = 'SPP'
        THEN
          l_prev_periodic_amount := l_periodic_amount;
          l_periodic_amount      := l_periodic_amount  + l_increment;
        ELSE
          l_prev_iir  := l_iir;
          l_iir       := l_iir + l_increment;
        END IF;
        IF n_iterations > 100
        THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_IIR_CALC_IIR_LIMIT',
                              p_token1       => 'IIR_LIMIT',
                              p_token1_value => 100);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_prev_incr_sign  :=  SIGN(l_increment);
        l_prev_diff_sign  :=  SIGN(l_diff);
        l_prev_diff       :=  l_diff;
        -- Increment the n_iterations index ..
        n_iterations := n_iterations + 1;
      END LOOP; -- Loop on n_iterations
      -- End of the Pricing Logic for Solve for Payments
    END IF; -- IF p_pricing_method ...
    -- Set ther return values and return them !!
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END compute_iir;

  -- Validates whether for a particular object ( Eg. Quick Quote )
  --  the inputed pricing method is valid or not ( Eg. SY, TR, SP, SF .. etc )
  FUNCTION  validate_pricing_method(
             p_pricing_method           IN              VARCHAR2,
             p_object_type              IN              VARCHAR2,
             x_return_status            IN OUT NOCOPY   VARCHAR2)
    RETURN BOOLEAN
  IS
    l_valid           BOOLEAN;
  BEGIN
    l_valid := FALSE;
    --print( 'validate_pricing_method: p_pricing_method = ' || p_pricing_method );
    IF 'RC|SF|SP|SS|SY|TR' LIKE '%'||p_pricing_method||'%' AND
       p_object_type = 'QQ'
    THEN
      l_valid := TRUE;
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    RETURN l_valid;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := G_RET_STS_ERROR;
      RETURN false;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      RETURN false;
    WHEN OTHERS
    THEN
      OKL_API.SET_MESSAGE (
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_DB_ERROR,
          p_token1       => G_PROG_NAME_TOKEN,
          p_token1_value => 'validate_pricing_method',
          p_token2       => G_SQLCODE_TOKEN,
          p_token2_value => sqlcode,
          p_token3       => G_SQLERRM_TOKEN,
          p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
      RETURN false;
  END validate_pricing_method;


  -- API which accepts the Lease Rate Set id
  --  and returns all the Lease Rate set Details, Factors, and Levels
  --  based on the term and end of term %age passeed.
  PROCEDURE get_lease_rate_factors(
              p_api_version            IN              NUMBER,
              p_init_msg_list          IN              VARCHAR2,
              x_return_status          OUT NOCOPY      VARCHAR2,
              x_msg_count              OUT NOCOPY      NUMBER,
              x_msg_data               OUT NOCOPY      VARCHAR2,
              p_lrt_id                 IN              NUMBER, -- Assuming LRS ID Header
              p_start_date             IN              DATE,
              p_term_in_months         IN              NUMBER,
              p_eot_percentage         IN              NUMBER,
              x_lrs_details            OUT NOCOPY      lrs_details_rec_type,
              x_lrs_factor             OUT NOCOPY      lrs_factor_rec_type,
              x_lrs_levels             OUT NOCOPY      lrs_levels_tbl_type)
  IS
    -- Cursor Declarations
    CURSOR lrs_version_details_csr(
             p_lrs_version_id IN okl_ls_rt_fctr_sets_v.ID%TYPE,
             p_date           IN DATE )
      IS
    SELECT
        hdr.id header_id,
        ver.rate_set_version_id version_id,
        hdr.NAME name,
        hdr.lrs_type_code lrs_type_code,
        hdr.FRQ_CODE frq_code,
        hdr.currency_code currency_code,
        ver.sts_code sts_code,
        ver.effective_from_date effective_from_date,
        ver.effective_to_date   effective_to_date,
        ver.arrears_yn arrears_yn,
        ver.end_of_term_ver_id end_of_term_ver_id,
        ver.std_rate_tmpl_ver_id std_rate_tmpl_ver_id,
        ver.adj_mat_version_id adj_mat_version_id,
        ver.version_number version_number,
        ver.lrs_rate lrs_version_rate,
        ver.rate_tolerance rate_tolerance,
        ver.residual_tolerance residual_tolerance,
        ver.deferred_pmts deferred_pmts,
        ver.advance_pmts advance_pmts
    FROM okl_ls_rt_fctr_sets_v hdr,
         okl_fe_rate_set_versions_v ver
    WHERE ver.rate_set_id = hdr.id
     AND  ver.rate_set_version_id = p_lrs_version_id
     AND  trunc(ver.effective_from_date) <= p_date
     AND  nvl(trunc(ver.effective_to_date), p_date) >= p_date;

    CURSOR lrs_factors_csr(
             p_lrs_version_id IN NUMBER,
             p_term           IN NUMBER,
             p_eot_percentage IN NUMBER,
             p_res_tolerance  IN NUMBER -- From the version record
             )
     IS
     SELECT fac.id factor_id,
            fac.term_in_months term_in_months,
            fac.residual_value_percent residual_value_percent
       FROM okl_ls_rt_fctr_ents_v fac
      WHERE fac.rate_set_version_id = p_lrs_version_id
       AND  fac.term_in_months  = p_term
       AND  p_eot_percentage BETWEEN fac.residual_value_percent - nvl(p_res_tolerance, 0) AND
                                     fac.residual_value_percent + nvl(p_res_tolerance, 0);


    CURSOR lrs_levels_csr( p_lrs_factor_id  IN NUMBER )
     IS
       SELECT lvl.sequence_number sequence_number,
              lvl.periods periods,
              lvl.lease_rate_factor lease_rate_factor
       FROM okl_fe_rate_set_levels lvl
       WHERE lvl.rate_set_factor_id = p_lrs_factor_id
       ORDER BY sequence_number ASC;

    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_lease_rate_factors';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Variable Declarations
    lrs_details_rec               lrs_details_rec_type;
    lrs_factor                    lrs_factor_rec_type;
    lrs_levels                    lrs_levels_tbl_type;
    lvl_index                     NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- Call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Actual logic Begins here
    IF p_start_date IS NULL OR
       p_lrt_id     IS NULL OR
       p_eot_percentage IS NULL OR
       p_term_in_months IS NULL
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Missing required input value ' );

      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Start with fetching the Lease Rate Set Header n Version information
    l_return_status := OKL_API.G_RET_STS_ERROR;
    FOR t_rec IN lrs_version_details_csr(
                    p_lrs_version_id  => p_lrt_id,
                    p_date            => p_start_date)
    LOOP
      lrs_details_rec.header_id            := t_rec.header_id;
      lrs_details_rec.version_id           := t_rec.version_id;
      lrs_details_rec.name                 := t_rec.name;
      lrs_details_rec.lrs_type_code        := t_rec.lrs_type_code;
      lrs_details_rec.frq_code             := t_rec.frq_code;
      lrs_details_rec.currency_code        := t_rec.currency_code;
      lrs_details_rec.sts_code             := t_rec.sts_code;
      lrs_details_rec.effective_from_date  := t_rec.effective_from_date;
      lrs_details_rec.effective_to_date    := t_rec.effective_to_date ;
      lrs_details_rec.arrears_yn           := t_rec.arrears_yn ;
      lrs_details_rec.end_of_term_ver_id   := t_rec.end_of_term_ver_id ;
      lrs_details_rec.std_rate_tmpl_ver_id := t_rec.std_rate_tmpl_ver_id ;
      lrs_details_rec.adj_mat_version_id   := t_rec.adj_mat_version_id ;
      lrs_details_rec.version_number       := t_rec.version_number ;
      lrs_details_rec.lrs_version_rate     := t_rec.lrs_version_rate ;
      lrs_details_rec.rate_tolerance       := t_rec.rate_tolerance ;
      lrs_details_rec.residual_tolerance   := t_rec.residual_tolerance ;
      lrs_details_rec.deferred_pmts        := t_rec.deferred_pmts ;
      lrs_details_rec.advance_pmts         := t_rec.advance_pmts ;
      -- Using l_return_status as a flag
      l_return_status := OKL_API.G_RET_STS_SUCCESS;
    END LOOP;
    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   ' Successfully fetched the Lease Rate Set Header n Version Details !' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   ' p_term_in_months | p_eof_percentage | Residual Tolerance ' ||
                   p_term_in_months || ' | ' || round(p_eot_percentage, 4)
                   || ' | ' || round(lrs_details_rec.residual_tolerance, 4));
    -- Fetch the Factors Information
    l_return_status := OKL_API.G_RET_STS_ERROR;
    FOR t_rec IN lrs_factors_csr(
                   p_lrs_version_id => lrs_details_rec.version_id,
                   p_term           => p_term_in_months,
                   p_eot_percentage => p_eot_percentage,
                   p_res_tolerance  => lrs_details_rec.residual_tolerance)
    LOOP
      lrs_factor.factor_id              := t_rec.factor_id;
      lrs_factor.term_in_months         := t_rec.term_in_months;
      lrs_factor.residual_value_percent := t_rec.residual_value_percent;
      -- Using l_return_status as a flag
      l_return_status := OKL_API.G_RET_STS_SUCCESS;
    END LOOP; -- lrs_factors
    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Successfully fetched the Lesae Rate Set Factors !' );
    -- Fetch the levels Information
    l_return_status := OKL_API.G_RET_STS_ERROR;
    lvl_index       := 1;
    FOR t_rec IN lrs_levels_csr( p_lrs_factor_id => lrs_factor.factor_id )
    LOOP
      lrs_levels(lvl_index).sequence_number   := t_rec.sequence_number;
      lrs_levels(lvl_index).periods           := t_rec.periods;
      lrs_levels(lvl_index).lease_rate_factor := t_rec.lease_rate_factor;
      -- Using l_return_status as a flag
      l_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- Increment the lvl_index
      lvl_index := lvl_index + 1;
    END LOOP; -- lrs_levels
    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Successfully fetched the Lease Rate Factor Levels !' );
    -- Setting up the return variables ...
    x_lrs_details := lrs_details_rec;
    x_lrs_factor := lrs_factor;
    x_lrs_levels := lrs_levels;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_lease_rate_factors;

  -- API which accepts the standard rate template version id and
  --   returns all the SRT details !
  PROCEDURE get_standard_rates(
              p_api_version            IN              NUMBER,
              p_init_msg_list          IN              VARCHAR2,
              x_return_status          OUT NOCOPY      VARCHAR2,
              x_msg_count              OUT NOCOPY      NUMBER,
              x_msg_data               OUT NOCOPY      VARCHAR2,
              p_srt_id                 IN              NUMBER, -- Version ID
              p_start_date             IN              DATE,
              x_srt_details            OUT NOCOPY      srt_details_rec_type)
  IS
    -- Cursor Declarations
    CURSOR srt_details_csr(
             p_srt_version_id IN NUMBER,
             p_date           IN DATE )
     IS
       SELECT hdr.std_rate_tmpl_id srt_header_id,
              ver.std_rate_tmpl_ver_id srt_version_id,
              hdr.template_name template_name,
              hdr.currency_code currency_code,
              ver.version_number version_number,
              ver.effective_from_date effective_from_date,
              ver.effective_to_date effective_to_date,
              ver.sts_code sts_code,
              hdr.pricing_engine_code pricing_engine_code,
              hdr.rate_type_code rate_type_code,
              ver.srt_rate srt_rate,
              hdr.index_id index_id,
              ver.spread spread,
              ver.day_convention_code day_convention_code,
              hdr.frequency_code frequency_code,
              ver.adj_mat_version_id adj_mat_version_id,
              ver.min_adj_rate min_adj_rate,
              ver.max_adj_rate max_adj_rate
      FROM okl_fe_std_rt_tmp_v hdr,
           okl_fe_std_rt_tmp_vers  ver
     WHERE ver.std_rate_tmpl_ver_id = p_srt_version_id AND
           hdr.std_rate_tmpl_id = ver.std_rate_tmpl_id AND
           ver.effective_from_date <= p_date AND
           nvl(ver.effective_to_date, p_date)   >= p_date;

    -- Fetch the Rate from the if the rate_type_code is INDEX.
    Cursor srt_index_rate_csr(
             p_srt_header_id IN NUMBER,
             p_date          IN DATE)
    IS
    SELECT   indx.value srt_rate
      FROM   okl_fe_std_rt_tmp_all_b hdr,
             okl_index_values indx
      WHERE  hdr.std_rate_tmpl_id = p_srt_header_id
      AND    hdr.index_id = indx.idx_id
      AND    p_date BETWEEN indx.datetime_valid AND NVL(indx.datetime_invalid,p_date+1);
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_standard_rates';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    srt_details           srt_details_rec_type;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- Call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF p_start_date IS NULL
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Start Date is null !! ' );
      OKL_API.set_message(
        G_APP_NAME,
        OKL_API.G_INVALID_VALUE,
        OKL_API.G_COL_NAME_TOKEN,
        'EXPECTED START DATE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF p_srt_id IS NULL
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Standard Rate Template ID is required !! ' );
      OKL_API.set_message(
        G_APP_NAME,
        OKL_API.G_REQUIRED_VALUE,
        OKL_API.G_COL_NAME_TOKEN,
        'STANDARD RATE TEMPLATE ID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    ': p_srt_id= ' || p_srt_id );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    ': p_start_date= '||  p_start_date );

    l_return_status := OKL_API.G_RET_STS_ERROR;
    FOR t_rec IN srt_details_csr(
                   p_srt_version_id => p_srt_id,
                   p_date           => p_start_date )
    LOOP
      srt_details.srt_header_id        := t_rec.srt_header_id;
      srt_details.srt_version_id       := t_rec.srt_version_id;
      srt_details.template_name        := t_rec.template_name;
      srt_details.currency_code        := t_rec.currency_code;
      srt_details.version_number       := t_rec.version_number;
      srt_details.effective_from_date  := t_rec.effective_from_date;
      srt_details.effective_to_date    := t_rec.effective_to_date;
      srt_details.sts_code             := t_rec.sts_code;
      srt_details.pricing_engine_code  := t_rec.pricing_engine_code;
      srt_details.rate_type_code       := t_rec.rate_type_code;
      srt_details.srt_rate             := t_rec.srt_rate;
      srt_details.index_id             := t_rec.index_id;
      srt_details.spread               := t_rec.spread;
      srt_details.day_convention_code  := t_rec.day_convention_code;
      srt_details.frequency_code       := t_rec.frequency_code;
      srt_details.adj_mat_version_id   := t_rec.adj_mat_version_id;
      srt_details.min_adj_rate         := t_rec.min_adj_rate;
      srt_details.max_adj_rate         := t_rec.max_adj_rate;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Successfully fetched the SRT Header n Version Details ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'SRT Rate Type Code | Min Adj Rate | Max. Adj Rate | Rate | Spread ');
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      srt_details.rate_type_code || ' | ' || srt_details.min_adj_rate
      || ' | ' || srt_details.max_adj_rate || ' | ' || srt_details.srt_rate || ' | ' || srt_details.spread);

      -- Using l_return_status as flag
      l_return_status := OKL_API.G_RET_STS_SUCCESS;
    END LOOP; -- srt_details_csr
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF srt_details.rate_type_code = G_QQ_SRT_RATE_TYPE
    THEN
      -- Initialize l_return_status to 'E'
      l_return_status := OKL_API.G_RET_STS_ERROR;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  ': p_srt_header_id = ' || srt_details.srt_header_id );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  ': p_start_date=' || p_start_date );
      FOR t_rec IN srt_index_rate_csr(
             p_srt_header_id => srt_details.srt_header_id,
             p_date          => p_start_date)
      LOOP
        srt_details.srt_rate := t_rec.srt_rate;
        -- Using l_return_status as flag
        l_return_status := OKL_API.G_RET_STS_SUCCESS;
      END LOOP; -- srt_index_rate_csr
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  ': After srt_index_rate_csr ' || l_return_status );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- IF srt_details.rate_type_code = 'INDEX'
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Rate from the SRT ' || srt_details.srt_rate );
    -- Setting up the return variables ..
    x_srt_details  := srt_details;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_standard_rates;

  PROCEDURE compute_bk_yield(
              p_api_version            IN              NUMBER,
              p_init_msg_list          IN              VARCHAR2,
              x_return_status          OUT NOCOPY      VARCHAR2,
              x_msg_count              OUT NOCOPY      NUMBER,
              x_msg_data               OUT NOCOPY      VARCHAR2,
              p_start_date              IN             DATE,
              p_day_count_method        IN             VARCHAR2,
              p_pricing_method          IN             VARCHAR2,
              p_initial_guess           IN             NUMBER,
              p_term                    IN             NUMBER,
              px_pricing_parameter_rec  IN  OUT NOCOPY pricing_parameter_rec_type,
              x_bk_yield                IN  OUT NOCOPY NUMBER,
              x_termination_tbl             OUT NOCOPY cash_inflows_tbl_type,
              x_pre_tax_inc_tbl             OUT NOCOPY cash_inflows_tbl_type
              -- Parameters for Prospective Rebooking
             ,p_prosp_rebook_flag      IN              VARCHAR2
             ,p_rebook_date            IN              DATE
             ,p_orig_income_streams    IN              cash_inflows_tbl_type
              )
  IS
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'compute_bk_yield';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled                VARCHAR2(10);
    is_debug_procedure_on          BOOLEAN;
    is_debug_statement_on          BOOLEAN;
    l_start_date                   DATE;
    l_end_date                     DATE;
    i                              NUMBER;
    p                              NUMBER;
    t                              NUMBER;
    m                              NUMBER;
    l_days_in_month              VARCHAR2(30);
    l_days_in_year               VARCHAR2(30);
    cf_index                       NUMBER;
    l_se_date                      DATE;
    res_index                      NUMBER;
    l_days                         NUMBER;
    l_tmp_interest                 NUMBER;
    l_is_arrears                   VARCHAR2(1);
    l_is_res_arrears               VARCHAR2(1);
    l_cf_inflows                   cash_inflows_tbl_type;
    l_residuals                    cash_inflows_tbl_type;
    l_termination_val_tbl          cash_inflows_tbl_type;
    l_pre_tax_income_tbl           cash_inflows_tbl_type;
    l_investment                   NUMBER := 0;
    l_residual_amount              NUMBER := 0;
    l_termination_val              NUMBER := 0;
    n_iterations                   NUMBER;
    l_k_start_date                 DATE;
    l_k_end_date                   DATE;
    l_k_se_date                    DATE;
    l_term_complete                VARCHAR2(1) := 'N';
    l_crossed_zero                 VARCHAR2(1) := 'N';
    l_diff                         NUMBER;
    l_prev_diff                    NUMBER;
    l_prev_diff_sign               NUMBER;
    l_prev_incr_sign               NUMBER;
    l_positive_diff                NUMBER;
    l_negative_diff                NUMBER;
    l_bk_yield                     NUMBER;
    l_prev_bk_yeild                NUMBER;
    l_increment                    NUMBER := 0.1;
    l_abs_incr                     NUMBER := 0;
    l_positive_diff_bk_yeild       NUMBER := 0;
    l_negative_diff_bk_yeild       NUMBER := 0;
    l_days_per_annum               NUMBER := 0;
    -- Prospective Rebooking Enhancement
    l_prosp_rebook_flag            VARCHAR2(30);
    l_last_accrued_date            DATE;
    l_eff_investment_for_prb       NUMBER;
    p_index                        NUMBER; -- Pre-Tax Income Stream Index
    t_index                        NUMBER; -- Termination Value Stream Index
    cf_index_start_prb             NUMBER;
    l_opening_bal                  NUMBER;
    l_ending_bal                   NUMBER;
    l_period_start_date            DATE;
    l_period_end_date              DATE;
    l_sum_rent_in_curr_month       NUMBER;
    l_orig_income_in_curr_month    NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| LOWER(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- Call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Actual logic Begins here
    -- Validate the input parameters
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'COMPUTE_BK_YIELD -------------- Start !! ' );
    get_days_in_year_and_month(
      p_day_count_method => p_day_count_method,
      x_days_in_month    => l_days_in_month,
      x_days_in_year     => l_days_in_year,
      x_return_status    => l_return_status);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'After get_day_count_method ' || l_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'l_days_in_month= ' || l_days_in_month || ' |  l_days_in_year = ' || l_days_in_year);
    IF p_start_date IS NULL OR
       p_term IS NULL OR p_term <= 0 OR
       px_pricing_parameter_rec.cash_inflows IS NULL OR
       px_pricing_parameter_rec.cash_inflows.COUNT <= 0 OR
       px_pricing_parameter_rec.line_end_date IS NULL
    THEN
      -- Show the error message and
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Input Parameters p_start_date, p_end_date, count(cash_inflows)  = '
             || p_start_date || ',' || px_pricing_parameter_rec.line_end_date || ',' ||
             px_pricing_parameter_rec.cash_inflows.COUNT );
    -- Dealing with the Cash Inflows
    l_start_date := p_start_date;
    cf_index := 1;
    i := px_pricing_parameter_rec.cash_inflows.FIRST;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Date | Amount | Arrears | Purpose ' );
    WHILE i <= px_pricing_parameter_rec.cash_inflows.LAST
    LOOP
      l_cf_inflows(cf_index) := px_pricing_parameter_rec.cash_inflows(i);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               l_cf_inflows(cf_index).cf_date
               || ' | ' || l_cf_inflows(cf_index).cf_amount || ' | ' ||
               l_cf_inflows(cf_index).is_arrears || ' | ' ||
               l_cf_inflows(cf_index).cf_purpose );
      -- Increment the indexes
      i := px_pricing_parameter_rec.cash_inflows.NEXT( i );
      cf_index := cf_index + 1;
    END LOOP; -- WHILE cf_index <= l_cf_inflows.LAST
    -- Dealing with the Residual Inflows now .. :-;
    l_start_date      := p_start_date;
    l_residual_amount := 0;
    res_index         := 1;
    i := px_pricing_parameter_rec.residual_inflows.FIRST;
    WHILE i <= px_pricing_parameter_rec.residual_inflows.LAST
    LOOP
      l_residuals(res_index) := px_pricing_parameter_rec.residual_inflows(i);
      -- Store the total Residual Amount
      l_residual_amount := l_residual_amount + nvl( l_residuals(res_index).cf_amount, 0 );
      -- cf_amount, cf_date, is_stub, is_arrears, cf_dpp, cf_ppy, cf_days,(  cf_rate ?? )
      -- would have been already populated.
      -- Increment the indexes
      i := l_residuals.NEXT( i );
      res_index := res_index + 1;
    END LOOP; -- WHILE cf_index <= l_cf_inflows.LAST
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Total Residual Amount  ' || round(l_residual_amount , 4) );
    -- Calculation of the Invested amount
    -- Investment = Item Original Cost ( Financed amount ) - Subsidy - Down Payment - Trade In;
    l_investment := nvl( px_pricing_parameter_rec.financed_amount, 0 ) -
                    nvl( px_pricing_parameter_rec.subsidy, 0 ) -
                    nvl( px_pricing_parameter_rec.down_payment, 0 ) -
                    nvl( px_pricing_parameter_rec.trade_in, 0 );
    IF l_investment <= 0
    THEN
      -- Initial Investment itself cant be negative !!
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF; -- IF l_investment ..

    -- Initialize the things
    n_iterations   := 0;
    l_k_start_date := p_start_date;
    l_bk_yield     := nvl( p_initial_guess, 0 );
    l_increment    := 0.1;
    -- Bug: Instead of assuming that the first cash flow is always RENT
    --   Loop on the cash inflows to fetch the first Rent Cash inflow and
    --   use the arrears flag and store it ..
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Identifying the first Rent Stream Element to fetch the Advance/Arrears Flag ');
    FOR i IN l_cf_inflows.FIRST .. l_cf_inflows.LAST
    LOOP
      IF l_cf_inflows(i).cf_purpose = 'RENT'
      THEN
        l_is_arrears   := l_cf_inflows(i).is_arrears;
        EXIT;
      END IF;
    END LOOP;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Advance/Arrears Flag for Rents Considered: ' || l_is_arrears );
    -- Fetch the end date
/*
    okl_stream_generator_pvt.add_months_new(
      p_start_date     => l_start_date,
      p_months_after   => p_term,
      x_date           => l_k_end_date,
      x_return_status  => l_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_k_end_date := l_k_end_date - 1;
*/
    -- Assume the line end date as passed in the .line_end_date
    l_k_end_date := px_pricing_parameter_rec.line_end_date;

    -- Modifications for the Prospective Rebooking Enhancement
    l_prosp_rebook_flag := NVL(p_prosp_rebook_flag, 'N' );
    -- Validating the Prospective Rebooking flag
    IF l_prosp_rebook_flag= 'Y'
    THEN
      -- If Rebook Effective Date is on the Contract Start Date itself
      --  then its a Retrospective Rebooking only
      IF TRUNC(p_rebook_date) = TRUNC(p_start_date)
      THEN
        -- Contract Start Date <> Rebook Revision Date
        l_prosp_rebook_flag := 'N';
      END IF;
      -- Step: Derieve the Last Accrued Date
      -- Rule 1: Last Accrual Date is the date of the immediately preceding
      --          Lease/Interest Income stream element. This is the previous
      --          calendar month end.
      l_last_accrued_date := TRUNC(LAST_DAY( ADD_MONTHS(p_rebook_date, -1)));
      IF l_last_accrued_date < TRUNC(p_start_date)
      THEN
        -- Last Accrued Date is before the Contract Start Date itself
        -- Hence, rebooking should be Retrospective.
        l_prosp_rebook_flag := 'N';
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Line Start Date= ' || p_start_date || ' | Rebook Date= ' || p_rebook_date ||
        ' | Last Accrued Date= ' || l_last_accrued_date ||
        ' | l_prosp_rebook_flag= ' || l_prosp_rebook_flag );
    END IF; -- IF l_prosp_rebook_flag= 'Y'

    IF l_prosp_rebook_flag= 'Y' -- If Still its a Prospective Rebooking
    THEN
      -- Start Looping on for the Booking Yield from l_last_accrued_date + 1
      l_k_start_date := l_last_accrued_date + 1;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Rebook Date | Last Accrued Date | Loop Start Date' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 p_rebook_date || ' | ' || l_last_accrued_date || ' | ' || l_k_start_date  );

      -- Derieve the Cash Flow Index after the Last Accrued Date
      IF l_cf_inflows.COUNT > 0
      THEN
        cf_index_start_prb  := 0; -- p_orig_rent_streams.FIRST;
        FOR i in l_cf_inflows.FIRST .. l_cf_inflows.LAST
        LOOP
          IF l_cf_inflows(i).cf_date <= l_last_accrued_date
          THEN
            cf_index_start_prb  := i;
          END IF;
        END LOOP;
        -- Increment the Cash flow Prospective Rebooking Index
        --  as cf_index_start_prb stored the last element index number, which is before
        --  the last accrued date
        cf_index_start_prb := cf_index_start_prb + 1;
      END IF; -- IF p_orig_rent_streams.COUNT > 0
      -- Derieve the Effective Investment on the Last Accrued Date + 1
      t_index := 1;
      l_opening_bal       := l_investment;
      l_period_start_date := TRUNC(p_start_date);
      l_period_end_date   := TRUNC( LAST_DAY( l_period_start_date) );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Period Start | Period End | Opening Bal | Interest Amount | Rent Amount | Ending Balance ' );

      WHILE l_period_start_date <= l_last_accrued_date
      LOOP
        -- Find sum[rents of revised asset], till the end of this month
        l_sum_rent_in_curr_month := 0;
        FOR r_index IN l_cf_inflows.FIRST .. l_cf_inflows.LAST
        LOOP
          IF LAST_DAY(l_cf_inflows(r_index).cf_date) = l_period_end_date
          THEN
            -- Rent Payment falls in the Current Month, so sum the Rent
            l_sum_rent_in_curr_month := l_sum_rent_in_curr_month +
                                        l_cf_inflows(r_index).cf_amount;
          END IF;
        END LOOP;
        -- Find the Pre-Tax Income Amount for this Period from Original Contract
        l_orig_income_in_curr_month := 0;
        FOR in_index IN p_orig_income_streams.FIRST .. p_orig_income_streams.LAST
        LOOP
          IF LAST_DAY( p_orig_income_streams(in_index).cf_date) =
             l_period_end_date
          THEN
            -- Interest for the current period
            l_orig_income_in_curr_month := p_orig_income_streams(in_index).cf_amount;
          END IF;
        END LOOP;
        -- Calculate the Termination Value at the end of the Current Period
        l_ending_bal := l_opening_bal - l_sum_rent_in_curr_month + l_orig_income_in_curr_month;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          l_period_start_date        || ' | ' ||
          l_period_end_date          || ' | ' ||
          l_opening_bal              || ' | ' ||
          l_orig_income_in_curr_month|| ' | ' ||
          l_sum_rent_in_curr_month   || ' | ' ||
          l_ending_bal );
        -- Store the Ending Balance as the Termination Value at the end of the period
        x_termination_tbl(t_index).cf_date   := l_period_end_date;
        x_termination_tbl(t_index).cf_amount := l_ending_bal;
        x_termination_tbl(t_index).line_number := t_index;
        -- Increment the p_index
        t_index := t_index + 1;
        -- Re-intialize to proceed for the next iteration
        l_opening_bal := l_ending_bal;
        l_period_start_date := l_period_end_date + 1;
        l_period_end_date   := TRUNC( LAST_DAY( l_period_start_date) );
        -- Store the Last Effective Balance as the Effective Balance
        l_eff_investment_for_prb := NVL(l_ending_bal, 0);
      END LOOP; -- WHILE l_period_start_date <= l_last_accrued_date
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Effective Investment as on the Last Accrued Date = ' || l_eff_investment_for_prb );
    ELSE
      -- Non-Prospective Rebooking Logic
      -- Effective Investment will be nothing but the l_investment
      l_eff_investment_for_prb := l_investment;
      cf_index_start_prb       := 1;
    END IF; -- IF NVL( p_prosp_rebook_flag, 'N' ) = 'Y'
    -- If the current flow is not a prospective Rebooking
    --  use l_eff_investment_for_prb as l_investment
    -- Actual Logic for calculation of the Booking Yield.
    LOOP
      -- Incrementing the Iteration Index
      n_iterations := n_iterations + 1;
      -- Initialize the things
      l_pre_tax_income_tbl.DELETE;
      l_termination_val_tbl.DELETE;
      l_termination_val := l_eff_investment_for_prb; -- Effective Investment
      cf_index          := cf_index_start_prb; -- Consider inflows only after the Last Accrued Date
      p := 1;
      t := 1;
      l_term_complete := 'N';
      l_crossed_zero  := 'N';
      l_start_date    := l_k_start_date;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Iteration # ' || n_iterations );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Booking |-Investment-|-Residual-|-Termination-|--------------|--------------|');
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 '-Yield--|------------|--Value---|-----Value---|l_k_start_date| l_k_end_date |');
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  round( l_bk_yield, 4 ) || '|' || round(l_eff_investment_for_prb , 4) || '|' || round(l_residual_amount , 4)
                  || '|' || round(l_termination_val , 4) || '|' || l_k_start_date || '|' || l_k_end_date);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'P/M | Bk. Yield | Arrears | Days/Annum | Start Date | End Date | Days | Interest | Payment Amount | Termination value ' );
      -- Main while loop ... !!! Loops until the term completes ;-)
      WHILE l_term_complete = 'N'
      LOOP
        -- There exists a possiblity during Prospective Rebooking that
        --  No Cashflows after the Last Accrued Date and hence, need to skip the following
        -- section and continue as is like all Payments are processed !
        -- Example: Prospective Rebooking: Yes
        --          Contract Start Date: 10-Jan-2009, One Asset, with One Annual Advance Payment
        --          and Rebook Happened on 15-Feb-2009
        -- As there are no payments till the end of the contract, we need to skip this section
        IF cf_index <= l_cf_inflows.LAST AND
           l_cf_inflows.exists(cf_index)
        THEN
          IF LAST_DAY( TRUNC(l_start_date) ) <>
             LAST_DAY( TRUNC(l_cf_inflows(cf_index).cf_date ) )
          THEN
            -- Handling till the end of the month ..
            --  Period:  ( l_start_date, LAST_DAY(l_start_day) ]
            l_end_date := LAST_DAY( l_start_date );
            l_days := get_day_count(
                p_days_in_month  => l_days_in_month,
                p_days_in_year   => l_days_in_year,
                p_start_date     => l_start_date,
                p_end_date       => l_end_date,
                p_arrears        => 'Y', -- Calculate until the end of the month !
                x_return_status  => l_return_status);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Case when the start date and end date are as follows:
            --  Start Date = 31st of the Month
            --  End Date = 31st of the Month
            --  Day Count returns 0, but ..
            --  Say, when Payments are received every month end 31st in Advance
            --   we need to calculate the 1 day interest from 31st to 31st itself
            IF TO_CHAR( l_start_date, 'DD' ) = 31 -- RGOOTY: 8935347
               AND TO_CHAR( l_end_date, 'DD' ) = 31
               AND l_is_arrears = 'N' -- Advance Payments
            THEN
              -- Case when, Advance Payments and is being received on the month end
              l_days := 1;
            END IF;
            l_days_per_annum := get_days_per_annum(
                                  p_day_convention   => p_day_count_method,
                                  p_start_date       => p_start_date,
                                  p_cash_inflow_date => l_start_date,
                                  x_return_status    => l_return_status );
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            l_tmp_interest := l_termination_val * l_days * l_bk_yield / l_days_per_annum;
            l_termination_val := l_termination_val + l_tmp_interest;
            l_termination_val_tbl(t).cf_amount := l_termination_val;
            -- Making the l_se_date to LAST_DAY(l_start_date)
            l_se_date := LAST_DAY(l_start_date);
            IF ( nvl(p_day_count_method, 'THIRTY') = 'THIRTY' AND
                 TO_CHAR(LAST_DAY(l_se_date), 'DD') = '31' ) OR
               ( nvl(p_day_count_method, 'THIRTY' ) = '365' AND
                 TO_CHAR(LAST_DAY(l_se_date), 'DD' ) = '29' AND
                 TO_CHAR(l_se_date, 'MON' ) = 'FEB' )
            THEN
              l_se_date := l_se_date - 1;
            END IF;
            l_termination_val_tbl(t).cf_date := LAST_DAY(l_se_date);
            t := t + 1;
            -- If l_start_date = l_k_start_date OR
            --    l_start_date is first of the month then no need to accumulate the pretax income
            -- else accumulate the pre-tax income.
            IF TRUNC(l_start_date) = TRUNC(l_k_start_date) OR
               TO_NUMBER(TO_CHAR(l_start_date, 'DD' )) = 1
            THEN
              -- No need to accumulate
              l_pre_tax_income_tbl(p).cf_amount := l_tmp_interest;
            ELSE
              -- Accumulate
              l_pre_tax_income_tbl(p).cf_amount := nvl( l_pre_tax_income_tbl(p).cf_amount , 0)
                                                + l_tmp_interest;
            END IF;
            l_pre_tax_income_tbl(p).cf_date := l_se_date;
            p := p + 1;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'M | ' || round( l_bk_yield, 4 ) || ' | ' || 'Y' || ' | ' || l_days_per_annum
                    || ' | ' || l_start_date || ' | ' || l_end_date || ' | ' || l_days
                    || ' | ' || round( l_tmp_interest, 4 ) || ' | - | ' || round(l_termination_val, 4 ) );
            -- Increment the things
            -- Change the start date to first of next month
            l_start_date := l_end_date + 1;
          ELSE
            -- Current month is having the payment ..
            -- Handling the period from ( l_start_date , l_cf_inflows(cf_index).cf_date )
            l_end_date := l_cf_inflows(cf_index).cf_date;
            l_days := get_day_count(
                p_days_in_month  => l_days_in_month,
                p_days_in_year   => l_days_in_year,
                p_start_date     => l_start_date,
                p_end_date       => l_end_date,
                p_arrears        => l_cf_inflows(cf_index).is_arrears,
                x_return_status  => l_return_status);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Based on the day convention, get the days/annum
            l_days_per_annum := get_days_per_annum(
                                  p_day_convention   => p_day_count_method,
                                  p_start_date       => p_start_date,
                                  p_cash_inflow_date => l_start_date,
                                  x_return_status    => l_return_status );
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Calculation of Interest
            l_tmp_interest := l_termination_val * l_days * l_bk_yield / l_days_per_annum;
            -- Termination value streams assignments
            l_termination_val := l_termination_val + l_tmp_interest;
            l_termination_val := l_termination_val - l_cf_inflows(cf_index).cf_amount;
            l_termination_val_tbl(t).cf_amount := l_termination_val;
            l_termination_val_tbl(t).cf_date := l_cf_inflows(cf_index).cf_date;
            -- Pre_tax streams assignments
            t := t + 1;
            IF l_pre_tax_income_tbl.exists(p)
            THEN
              l_pre_tax_income_tbl(p).cf_amount := nvl( l_pre_tax_income_tbl(p).cf_amount, 0 ) +
                                                   l_tmp_interest;
            ELSE
              l_pre_tax_income_tbl(p).cf_amount := l_tmp_interest;
            END IF;
            -- Date for the Pre-Tax Income will be put above
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      'P | ' || round( l_bk_yield, 4 ) || ' | ' || l_cf_inflows(cf_index).is_arrears || ' | ' || l_days_per_annum
                     || ' | ' || l_start_date  || ' | ' || l_end_date || ' | ' || l_days
                     || ' | ' || round( l_tmp_interest, 4 ) || ' | ' ||
                     round(l_cf_inflows(cf_index).cf_amount, 4) || ' | ' || round(l_termination_val, 4 ) );
            -- Increment the cf_index
            l_start_date := l_cf_inflows(cf_index).cf_date;
            IF l_cf_inflows(cf_index).is_arrears = 'Y' AND
  --             TRUNC(l_start_date) <> TRUNC(LAST_DAY( l_start_date)) AND
               l_start_date < l_k_end_date
            THEN
             l_start_date := l_start_date + 1;
            END IF;
            -- If the Current Period End Date and Next Period Start Date
            --   doesnot fall in the same month, then increment the Pre-Tax Income table index
            IF TRUNC(LAST_DAY(l_start_date)) > TRUNC(LAST_DAY(l_end_date))
            THEN
              -- Handling the Case when l_end_date = Calender end of the month
              --  and next payment starts only after the next month
              l_pre_tax_income_tbl(p).cf_date := l_end_date;
              p := p + 1;
            END IF;
            cf_index := cf_index + 1;
          END IF;
        END IF; -- If cf_index <= l_cf_inflows.LAST
        -- Check whether we have crossed the Stream Element dates or not???
        IF cf_index > l_cf_inflows.LAST
        THEN
          m := 1;
          -- Last Cash Inflow
          LOOP
            IF LAST_DAY(l_start_date) <> LAST_DAY(l_k_end_date) THEN
              l_end_date := LAST_DAY(l_start_date);
            ELSE
              l_end_date := l_k_end_date;
            END IF;
            -- Residual Amount is always considered as inflow at the
            -- very last momment of the Contract
            l_is_res_arrears := 'Y';
            -- But, In case, when Last Stream Element Date = Contract End Date
            --  and Payments are arrears, then Day Count should be equal to zero.
            IF l_start_date = l_end_date AND
               l_end_date = l_k_end_date AND
               l_is_arrears = 'Y'
            THEN
              l_is_res_arrears := 'N';
            END IF;
            l_days := get_day_count(
                p_days_in_month  => l_days_in_month,
                p_days_in_year   => l_days_in_year,
                p_start_date     => l_start_date,
                p_end_date       => l_end_date,
                p_arrears        => l_is_res_arrears, -- Calculate until the end of the month/Contract End Date
                x_return_status  => l_return_status);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- But, In case, when Last Stream Element Date = Contract End Date
            --  and Payments are arrears, then Day Count should be equal to zero.
            IF TO_CHAR( p_start_date, 'DD') = 31 AND -- Contract Starting on 31st of Month
               l_end_date = l_k_end_date AND         -- Handling the Last Residual Stream
               TO_CHAR(l_end_date, 'DD' ) = 30 AND   -- Residual is coming on months 30 end
               TO_CHAR(l_start_date, 'DD' ) = 1      -- Last Handled Stream element was 31st
            THEN
              l_days := l_days - 1; -- Dont include the last day of the contract
            END IF;
            -- Case when the start date and end date are as follows:
            --  Start Date = 31st of the Month
            --  End Date = 31st of the Month
            --  Day Count returns 0, but ..
            --  Say, when Payments are received every month end 31st in Advance
            --   we need to calculate the 1 day interest from 31st to 31st itself
            IF TO_CHAR( l_start_date, 'DD' ) = 31 -- RGOOTY: 8935347
               AND TO_CHAR( l_end_date, 'DD' ) = 31
               AND l_is_arrears = 'N' -- Advance Payments
            THEN
              -- Case when, Advance Payments and is being received on the month end
              l_days := 1;
            END IF;
            --shagarg commented for bug 6604271
           /* IF l_is_arrears= 'Y' AND m = 1 AND l_days >= 1
            THEN
              l_days := l_days - 1;
            END IF;*/
            --shagarg bug 6604271 end
            -- Get days/annum based on the day count method
            l_days_per_annum := get_days_per_annum(
                                  p_day_convention   => p_day_count_method,
                                  p_start_date       => p_start_date,
                                  p_cash_inflow_date => l_start_date,
                                  x_return_status    => l_return_status );
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Interest Calculation
            l_tmp_interest := l_termination_val * l_days * l_bk_yield / l_days_per_annum;
            -- Termination value streams assignment
            l_termination_val := l_termination_val + l_tmp_interest;
            -- If the current month is the first one .. !
            IF m = 1
            THEN
              -- Accumulate the Pre-Tax Income
              IF l_pre_tax_income_tbl.exists(p)
	      THEN
                l_pre_tax_income_tbl(p).cf_amount := NVL(l_pre_tax_income_tbl(p).cf_amount,0)
                                                    + l_tmp_interest;
              ELSE
                l_pre_tax_income_tbl(p).cf_amount :=l_tmp_interest;
              END IF;
            ELSE
              -- Pre-Tax is calculated for entire month, hence, no need to accumulate.
              l_pre_tax_income_tbl(p).cf_amount := l_tmp_interest;
            END IF;
            l_pre_tax_income_tbl(p).cf_date := l_end_date;
            p := p + 1;

            IF TRUNC(l_end_date) = TRUNC(l_k_end_date)
            THEN
              l_termination_val := l_termination_val - l_residual_amount;
              l_term_complete := 'Y';
            END IF;
            -- Termination value streams assignment
            l_termination_val_tbl(t).cf_amount := l_termination_val;
            l_termination_val_tbl(t).cf_date := l_end_date;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'L | ' || round( l_bk_yield, 4 ) || ' | ' || 'Y' || ' | ' || l_days_per_annum
                   || ' | ' || l_start_date || ' | ' || l_end_date || ' | ' || l_days
                   || ' | ' || round( l_tmp_interest, 4 ) || ' | - | ' || round(l_termination_val_tbl(t).cf_amount, 4 ) );
            t := t + 1;
            EXIT WHEN TRUNC(l_end_date) = TRUNC(l_k_end_date);
            -- Increment the Start Date to Next Month First
            l_start_date := LAST_DAY(l_start_date) + 1;
            -- Increment m
            m := m + 1;
          END LOOP; -- Loop on m
        END IF; -- IF cf_index = l_cf_inflows.LAST
      END LOOP; -- Looping through the Inflows
      -- Assign the termination value at the end of the period to l_diff and proceed !!
      l_diff := l_termination_val;
      -- If the current bk_yield is making the termination value as zero at the end of the
      -- period, then we have attained the solution, hence return the termination value
      -- and pre_tax streams along with the bk_yield !!
      IF ROUND(l_diff, 4) = 0
      THEN
        IF NVL( p_prosp_rebook_flag, 'N' ) = 'Y' AND
           p_rebook_date <> p_start_date         -- Contract Start Date <> Rebook Revision Date
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            ' !!! Returning Streams based on Prospective Rebooking Case !!!' );
          -- Prospective Rebooking Enhancement
          -- The Booking Yield Algorithm has been modified to generate the
          --  Lease Income Streams prospectively from the Last Accrued Date to the
          --  Contract End Date
          -- Hence, prepend the Before Revision Pre-Tax Income Streams
          --  to the l_pre_tax_income_tbl streams
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Copying Pre-Tax Income Streams from Contract Start Date to Last Accrual Date' );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
             ' # | Date | amount ' );
          p_index := 1;
          WHILE TRUNC(p_orig_income_streams(p_index).cf_date) <=
                TRUNC(l_last_accrued_date)
          LOOP
            x_pre_tax_inc_tbl(p_index).cf_date := TRUNC(p_orig_income_streams(p_index).cf_date);
            x_pre_tax_inc_tbl(p_index).cf_amount := p_orig_income_streams(p_index).cf_amount;
            x_pre_tax_inc_tbl(p_index).line_number := p_index;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              p_index || ' | ' ||
              x_pre_tax_inc_tbl(p_index).cf_date || ' | ' ||
              x_pre_tax_inc_tbl(p_index).cf_amount);
            -- Increment the p_index
            p_index := p_index + 1;
          END LOOP;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Appending Pre-Tax Income Streams from Contract Start Date to Last Accrual Date' );
          -- Append the Newly generated the Pre-Tax Income Streams
          FOR p in l_pre_tax_income_tbl.FIRST .. l_pre_tax_income_tbl.LAST
          LOOP
            x_pre_tax_inc_tbl(p_index).cf_date := TRUNC(l_pre_tax_income_tbl(p).cf_date);
            x_pre_tax_inc_tbl(p_index).cf_amount := l_pre_tax_income_tbl(p).cf_amount;
            x_pre_tax_inc_tbl(p_index).line_number := p_index;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              p_index || ' | ' ||
              x_pre_tax_inc_tbl(p_index).cf_date || ' | ' ||
              x_pre_tax_inc_tbl(p_index).cf_amount);
            -- Increment the p_index
            p_index := p_index + 1;
          END LOOP;
          -- The Termination Value Streams on or before Last Accrued Date
          --  are already calculated during the process to calculate
          --  the effective Investement as on the Effective Rebook Date [Last Accrued Date +1]
          -- Append the Newly generated the Pre-Tax Income Streams
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Appending Termination Value Streams from Contract Start Date to Last Accrual Date' );
          FOR t in l_termination_val_tbl.FIRST .. l_termination_val_tbl.LAST
          LOOP
            x_termination_tbl(t_index).cf_date := TRUNC(l_termination_val_tbl(t).cf_date);
            x_termination_tbl(t_index).cf_amount := l_termination_val_tbl(t).cf_amount;
            x_termination_tbl(t_index).line_number := t_index;
            -- Increment the p_index
            t_index := t_index + 1;
          END LOOP;
          x_termination_tbl(x_termination_tbl.LAST).cf_amount := l_residual_amount;
        ELSE
          -- Copying back the Pre-Tax Income Streams
          FOR p in l_pre_tax_income_tbl.FIRST .. l_pre_tax_income_tbl.LAST
          LOOP
            x_pre_tax_inc_tbl(p).cf_date := trunc(l_pre_tax_income_tbl(p).cf_date);
            x_pre_tax_inc_tbl(p).cf_amount := l_pre_tax_income_tbl(p).cf_amount;
            x_pre_tax_inc_tbl(p).line_number := p;
          END LOOP;
          -- Copying back the Termination Value Streams
          FOR t in l_termination_val_tbl.FIRST .. l_termination_val_tbl.LAST
          LOOP
            x_termination_tbl(t).cf_date := trunc(l_termination_val_tbl(t).cf_date);
            x_termination_tbl(t).cf_amount := l_termination_val_tbl(t).cf_amount;
            x_termination_tbl(t).line_number := t;
          END LOOP;
          x_termination_tbl(x_termination_tbl.LAST).cf_amount := l_residual_amount;
        END IF;
        x_bk_yield := l_bk_yield;
        -- Achieved the booking yeild, now returning back
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'BOOKING YIELD =  ' || round( x_bk_yield, 4));
        x_return_status := 'S';
        RETURN;
      END IF;
      -- Using Interpolation approach to estimate/increment the next
      -- propsed booking yield .. !
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Inrementation Details:Before' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'n_iterations|l_crossed_zero|l_increment|l_abs_incr|l_prev_incr_sign|SIGN(l_diff)' ||
        'l_diff|l_positive_diff|l_negative_diff|l_prev_diff|' ||
        'l_bk_yield|l_prev_bk_yeild|l_positive_diff_bk_yeild|l_negative_diff_bk_yeild' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        n_iterations||'|'||l_crossed_zero||'|'||l_increment||'|'||l_abs_incr||'|'||l_prev_incr_sign||'|'||SIGN(l_diff)||'|'||
        l_diff||'|'||l_positive_diff||'|'||l_negative_diff||'|'||l_prev_diff||'|'||
        l_bk_yield||'|'||l_prev_bk_yeild||'|'||l_positive_diff_bk_yeild||'|'||l_negative_diff_bk_yeild );
      IF n_iterations > 1 AND
         SIGN(l_diff) <> SIGN(l_prev_diff)
         AND l_crossed_zero = 'N'
      THEN
        l_crossed_zero := 'Y';
        IF (SIGN(l_diff) = 1)
        THEN
          l_positive_diff := l_diff;
          l_negative_diff := l_prev_diff;
          l_positive_diff_bk_yeild := l_bk_yield;
          l_negative_diff_bk_yeild := l_prev_bk_yeild;
        ELSE
          l_positive_diff := l_prev_diff;
          l_negative_diff := l_diff;
          l_positive_diff_bk_yeild := l_prev_bk_yeild;
          l_negative_diff_bk_yeild := l_bk_yield;
        END IF;
      END IF;
      IF (SIGN(l_diff) = 1)
      THEN
        l_positive_diff := l_diff;
        l_positive_diff_bk_yeild := l_bk_yield;
      ELSE
        l_negative_diff := l_diff;
        l_negative_diff_bk_yeild := l_bk_yield;
      END IF;
      IF l_crossed_zero = 'Y'
      THEN
        IF n_iterations > 1
        THEN
          l_abs_incr := abs((l_positive_diff_bk_yeild - l_negative_diff_bk_yeild) /
                            (l_positive_diff - l_negative_diff) * l_diff);
        ELSE
          l_abs_incr := ABS(l_increment) / 2;
        END IF;
      ELSE
        l_abs_incr := ABS(l_increment);
      END IF;
      IF n_iterations > 1
      THEN
        IF SIGN(l_diff) <> l_prev_diff_sign
        THEN
          IF l_prev_incr_sign = 1
          THEN
            l_increment := - l_abs_incr;
          ELSE
            l_increment := l_abs_incr;
          END IF;
        ELSE
          IF l_prev_incr_sign = 1
          THEN
            l_increment := l_abs_incr;
          ELSE
            l_increment := - l_abs_incr;
          END IF;
        END IF;
      ELSE
        IF SIGN(l_diff) = 1
        THEN
          l_increment := - l_increment;
        ELSE
          l_increment := l_increment;
        END IF;
      END IF;
      l_prev_bk_yeild := l_bk_yield;
      l_bk_yield := l_bk_yield + l_increment;
      l_prev_incr_sign := SIGN(l_increment);
      l_prev_diff_sign := SIGN(l_diff);
      l_prev_diff := l_diff;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Inrementation Details: After Calculations' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        n_iterations||'|'||l_crossed_zero||'|'||l_increment||'|'||l_abs_incr||'|'||l_prev_incr_sign||'|'||SIGN(l_diff)||'|'||
        l_diff||'|'||l_positive_diff||'|'||l_negative_diff||'|'||l_prev_diff||'|'||
        l_bk_yield||'|'||l_prev_bk_yeild||'|'||l_positive_diff_bk_yeild||'|'||l_negative_diff_bk_yeild );
    END LOOP; -- Loop on n_iterations
    -- Actual logic Ends here
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END compute_bk_yield;

  PROCEDURE get_qq_rc_cash_flows(
             p_api_version          IN            NUMBER,
             p_init_msg_list        IN            VARCHAR2,
             x_return_status           OUT NOCOPY VARCHAR2,
             x_msg_count               OUT NOCOPY NUMBER,
             x_msg_data                OUT NOCOPY VARCHAR2,
             p_qq_hdr_rec           IN            so_hdr_rec_type,
             x_days_in_month           OUT NOCOPY VARCHAR2,
             x_days_in_year            OUT NOCOPY VARCHAR2,
             x_item_cat_cf_tbl         OUT NOCOPY item_cat_cf_tbl_type)
  IS
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_qq_rc_cash_flows';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Cursor Declarations
    CURSOR item_cat_csr( p_qq_id NUMBER )
    IS
      SELECT  id
             ,item_category_id
             ,value
             ,basis
             ,nvl(nvl(end_of_term_value, end_of_term_value_default), 0) end_of_term_amount
             ,lease_rate_factor
       FROM  OKL_QUICK_QUOTE_LINES_B qql
      WHERE  qql.quick_quote_id = p_qq_id
        AND  TYPE = G_ITEMCATEGORY_TYPE; -- Item Category Type

   CURSOR get_cat_name(p_category_id IN NUMBER) IS
     SELECT category_concat_segs name,
            description
      FROM mtl_categories_v
     WHERE category_id = p_category_id;
    cat_rec     get_cat_name%ROWTYPE;

    -- Cursor to get the Financial Adjustments defined @ QQ Level
    CURSOR fin_adj_csr( p_qq_id NUMBER, p_tot_item_cost IN NUMBER )
    IS
      SELECT  TYPE  type
             ,SUM(CASE basis
                   WHEN 'FIXED'      THEN value
                   WHEN 'ASSET_COST' THEN value * p_tot_item_cost * .01
                  END ) AS fin_value
        FROM  OKL_QUICK_QUOTE_LINES_B qql
      WHERE  qql.quick_quote_id = p_qq_id
        AND  TYPE IN ( G_DOWNPAYMENT_TYPE,  -- Down Payment Type
                       G_TRADEIN_TYPE,      -- Trade in Type
                       G_SUBSIDY_TYPE )       -- Subsidy Type
      GROUP BY TYPE
      ORDER BY TYPE;

    -- Cursor to fetch the End of Term Option Type
    CURSOR get_eot_type( p_qq_id NUMBER )
    IS
      SELECT  qq.id
         ,qq.reference_number
         ,eot.end_of_term_name
         ,eot.eot_type_code eot_type_code
         ,eot.end_of_term_id end_of_term_id
         ,eotversion.end_of_term_ver_id
     FROM OKL_QUICK_QUOTES_B qq,
          okl_fe_eo_term_vers eotversion,
          okl_fe_eo_terms_all_b eot
     WHERE qq.END_OF_TERM_OPTION_ID = eotversion.end_of_term_ver_id
       AND eot.end_of_term_id = eotversion.end_of_term_id
       AND qq.id = p_qq_id;
    -- Local Variables
    l_lrs_details          lrs_details_rec_type;
    l_lrs_factor           lrs_factor_rec_type;
    l_lrs_levels           lrs_levels_tbl_type;
    l_ac_rec_type          OKL_EC_EVALUATE_PVT.okl_ac_rec_type;
    l_adj_factor           NUMBER;
    l_got_adj_factor       BOOLEAN;
    l_eot_percentage       NUMBER;
    l_asset_fin_amt        NUMBER;
    l_months_per_period    NUMBER;
    l_months_after         NUMBER;
    l_item_cat_cf_tbl      item_cat_cf_tbl_type;
    cf_index               NUMBER; -- Using as an index for Cash flow levels
    i                      NUMBER; -- Using as an index for Item Categories
    l_periods              NUMBER;
    l_sum_fin_amt          NUMBER; -- Sum of Financed Amount
    l_tot_down_payment     NUMBER;
    l_tot_tradein          NUMBER;
    l_tot_subsidy          NUMBER;
    l_eot_type_code               VARCHAR2(30);
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Know the type of the EOT and then proceed with the values directly or calculate the amount
    FOR t_rec IN get_eot_type(p_qq_id => p_qq_hdr_rec.id)
    LOOP
      l_eot_type_code := t_rec.eot_type_code;
    END LOOP;
    -- First of all, Calculate the Total OEC for all the Assets.
    l_sum_fin_amt := 0;
    i := 1;
    FOR t_rec IN item_cat_csr( p_qq_id => p_qq_hdr_rec.id )
    LOOP
      l_sum_fin_amt := l_sum_fin_amt + t_rec.value;
      -- Populate the Item Cat PL/SQL Table for calculation of the Proportionated Financial Adjustments
      l_item_cat_cf_tbl(i).line_id          := t_rec.id;
      l_item_cat_cf_tbl(i).item_category_id := t_rec.item_category_id;
      -- Returning the Asset COST in the Financed Amount COLUMN, remember we are not returning C-S-D-T here !!
      l_item_cat_cf_tbl(i).financed_amount  := t_rec.value;        -- Populating the Cash Flow Record
      -- Increment i
      i := i + 1;
    END LOOP;
    -- Fetch the Financial adjustments, Down Payment/Tradein/Subsidy defined @ QQ level ..
    FOR t_rec IN fin_adj_csr( p_qq_id => p_qq_hdr_rec.id
                             ,p_tot_item_cost => l_sum_fin_amt )
    LOOP
      IF t_rec.type = G_DOWNPAYMENT_TYPE
      THEN
        l_tot_down_payment := t_rec.fin_value;
      ELSIF t_rec.type = G_TRADEIN_TYPE
      THEN
        l_tot_tradein := t_rec.fin_value;
      ELSIF t_rec.type = G_SUBSIDY_TYPE
      THEN
        l_tot_subsidy := t_rec.fin_value;
      END IF;
    END LOOP;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'TOTALS: p_qq_id | p_tot_item_cost | Tot Down Payment | Trade in | Subsidy ');
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      p_qq_hdr_rec.id || ' | ' ||  round(l_sum_fin_amt, 4) || ' | ' ||
      round( l_tot_down_payment, 4) || ' | ' || round( l_tot_tradein, 4) || ' | ' || round( l_tot_subsidy, 4) );
    -- Code for distributing the fin. adj. @ QQ level to individual item categories !
    -- Approach is to proportionate the financial adjustments entered @ Header level
    --  based on the item category cost
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'PROPORTIONATED AMOUNTS: Item ID | Financed Amount | Down Payment | Trade in | Subsidy ');
    FOR t IN l_item_cat_cf_tbl.FIRST .. l_item_cat_cf_tbl.LAST
    LOOP
      l_item_cat_cf_tbl(t).down_payment := nvl(l_tot_down_payment * l_item_cat_cf_tbl(t).financed_amount/l_sum_fin_amt, 0);
      l_item_cat_cf_tbl(t).subsidy      := nvl(l_tot_subsidy * l_item_cat_cf_tbl(t).financed_amount/l_sum_fin_amt, 0);
      l_item_cat_cf_tbl(t).trade_in     := nvl(l_tot_tradein * l_item_cat_cf_tbl(t).financed_amount/l_sum_fin_amt, 0);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        l_item_cat_cf_tbl(t).line_id || ' | ' || round(l_item_cat_cf_tbl(t).financed_amount, 4) || ' | ' ||
        round( l_item_cat_cf_tbl(t).down_payment, 4) || ' | ' || round( l_item_cat_cf_tbl(t).trade_in, 4) || ' | ' || round( l_item_cat_cf_tbl(t).subsidy, 4) );
    END LOOP;
    -- 1/ Check for the structured_pricing column in p_qq_hdr_rec.structured_pricing
    -- IF 'N' then fetch the lease rate factor levels for each item category
    IF p_qq_hdr_rec.structured_pricing IS NULL OR
       p_qq_hdr_rec.structured_pricing = 'N'
    THEN
      l_got_adj_factor := FALSE;
      i := 1;
      FOR t_rec IN item_cat_csr( p_qq_id => p_qq_hdr_rec.id )
      LOOP
        -- Calculate EOT %age. FORMULA: EOT %age = EOT of the Asset / Assets OEC * 100
        IF l_eot_type_code = 'AMOUNT' OR l_eot_type_code = 'RESIDUAL_AMOUNT'
        THEN
          l_eot_percentage := (t_rec.end_of_term_amount / t_rec.VALUE ) * 100;
          l_item_cat_cf_tbl(i).eot_amount := t_rec.end_of_term_amount;
        ELSE
          -- End of Term Amount is representing actually the percentage
          l_eot_percentage := t_rec.end_of_term_amount;
          l_item_cat_cf_tbl(i).eot_amount := (t_rec.end_of_term_amount * t_rec.VALUE ) / 100;
        END IF;
        -- Loop through all the assets and fetch the corresponding LRF and payment amounts !
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Extracting the information from Lease Rate Set ' );
        l_lrs_levels.DELETE;
        -- Extract the data from the Lease Rate Set !
        get_lease_rate_factors(
          p_api_version            => p_api_version,
          p_init_msg_list          => p_init_msg_list,
          x_return_status          => l_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_lrt_id                 => p_qq_hdr_rec.rate_card_id,
          p_start_date             => p_qq_hdr_rec.expected_start_date,
          p_term_in_months         => p_qq_hdr_rec.term,
          p_eot_percentage         => l_eot_percentage,
          x_lrs_details            => l_lrs_details,
          x_lrs_factor             => l_lrs_factor,
          x_lrs_levels             => l_lrs_levels);
        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
        THEN
          OPEN get_cat_name(p_category_id => t_rec.item_category_id);
          FETCH get_cat_name INTO cat_rec;
          CLOSE get_cat_name;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Couldnot found the Lease Rate Factor levels for Item Category ' || cat_rec.name );
          -- Show the message and then return back throwing an error!
          OKL_API.set_message(
            p_app_name => G_APP_NAME,
            p_msg_name => 'OKL_LP_NO_LRS_LEVELS_FOUND',
            p_token1 => 'ITEMCAT',
            p_token1_value => cat_rec.name,
            p_token2 => 'ITEMTERM',
            p_token2_value => p_qq_hdr_rec.term,
            p_token3 => 'ITEMEOTPERCENT',
            p_token3_value => ROUND(l_eot_percentage,4) );
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Apply the adjustment matrix if needed!
        IF l_lrs_details.adj_mat_version_id IS NOT NULL AND
           l_got_adj_factor = FALSE
        THEN
          l_ac_rec_type.src_id := l_lrs_details.adj_mat_version_id; -- Pricing adjustment matrix ID
          l_ac_rec_type.source_name := NULL; -- NOT Mandatory Pricing Adjustment Matrix Name !
          l_ac_rec_type.target_id := p_qq_hdr_rec.ID ; -- Quote ID
          l_ac_rec_type.src_type := 'PAM'; -- Lookup Code
          l_ac_rec_type.target_type := 'QUOTE'; -- Same for both Quick Quote and Standard Quote
          l_ac_rec_type.target_eff_from  := p_qq_hdr_rec.expected_start_date; -- Quote effective From
          l_ac_rec_type.term  := p_qq_hdr_rec.term; -- Remaining four will be from teh business object like QQ / LQ
          l_ac_rec_type.territory := p_qq_hdr_rec.sales_territory_id;
          l_ac_rec_type.deal_size := l_sum_fin_amt; -- Not sure how to pass this value
          l_ac_rec_type.customer_credit_class := NULL; -- Not sure how to pass this even ..
          -- Fetching the deal_size ..
          -- Calling the API to get the adjustment factor ..
          okl_ec_evaluate_pvt. get_adjustment_factor(
             p_api_version       => p_api_version,
             p_init_msg_list     => p_init_msg_list,
             x_return_status     => x_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             p_okl_ac_rec        => l_ac_rec_type,
             x_adjustment_factor => l_adj_factor );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        IF l_got_adj_factor = FALSE
        THEN
          l_got_adj_factor := TRUE;
          l_adj_factor := nvl( l_adj_factor, 0 );
        END IF;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S', 'Adjustment Factor ' ||  l_adj_factor );
        -- Calculating the Asset Level Financed Amount. i.e C- nvl(S+D+T, 0)
        l_asset_fin_amt := l_item_cat_cf_tbl(i).financed_amount - nvl( l_item_cat_cf_tbl(i).subsidy +
                             l_item_cat_cf_tbl(i).down_payment + l_item_cat_cf_tbl(i).trade_in, 0);
        -- Store the Item Category details in the PL/SQL table to return back ..
        l_item_cat_cf_tbl(i).cash_flow_rec.due_arrears_yn := l_lrs_details.arrears_yn;
        l_item_cat_cf_tbl(i).cash_flow_rec.start_date := p_qq_hdr_rec.expected_start_date;
        -- Get the Months factor!
        l_months_per_period := okl_stream_generator_pvt.get_months_factor(
                                p_frequency     => l_lrs_details.frq_code,
                                x_return_status => l_return_status);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S', 'Months/Period ' || l_months_per_period );
        -- Populating the Cash Flow Levels
        l_months_after := 0;
        cf_index := 1;
        FOR t in l_lrs_levels.FIRST .. l_lrs_levels.LAST
        LOOP
         l_item_cat_cf_tbl(i).cash_flow_level_tbl(cf_index).fqy_code := l_lrs_details.frq_code;
         l_item_cat_cf_tbl(i).cash_flow_level_tbl(cf_index).number_of_periods := l_lrs_levels(t).periods;
         l_item_cat_cf_tbl(i).cash_flow_level_tbl(cf_index).amount := ( l_lrs_levels(t).lease_rate_factor + nvl(l_adj_factor,0) ) * l_asset_fin_amt;
         l_item_cat_cf_tbl(i).cash_flow_level_tbl(cf_index).is_stub := 'N';
         l_item_cat_cf_tbl(i).cash_flow_level_tbl(cf_index).rate := l_lrs_levels(t).lease_rate_factor;
         -- Need to populate the start date per line .. !!
         okl_stream_generator_pvt.add_months_new(
           p_start_date     => p_qq_hdr_rec.expected_start_date,
           p_months_after   => l_months_after,
           x_date           => l_item_cat_cf_tbl(i).cash_flow_level_tbl(cf_index).start_date,
           x_return_status  => l_return_status);
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- Add to the l_months_after
          l_months_after := l_months_after + ( l_lrs_levels(t).periods * l_months_per_period );
          -- Increment the index
          cf_index := cf_index + 1;
        END LOOP;
        -- Increment the item category index
        i := i + 1;
      END LOOP;
    ELSE
      -- Note:
      --  When user hasn't picked the LRS for Rate Card pricing and wishes
      --  to enter the LRF .. ie. Structured Pricing, Suresh PB has confirmed
      --  that irrespective of the line level pricing has been checked or not
      --  sales team will populate the LRF in OKL_QUICK_QUOTE_LINES_B.
      --  Hence, pricing can just fetch the LRF in OKL_QUICK_QUOTE_LINES_B and
      --   then build the cash flows from that ..
      -- Get the Months factor!
      l_months_per_period := okl_stream_generator_pvt.get_months_factor(
                              p_frequency     => p_qq_hdr_rec.target_frequency,
                              x_return_status => l_return_status);
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S', 'Months/Period ' || l_months_per_period );
      l_periods := p_qq_hdr_rec.term / l_months_per_period;
      -- Need to validate that the term / ( frequency factor ) should be a whole number !
      IF l_periods <> TRUNC( l_periods )
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S', 'Periods has to be a whole number ');
        OKL_API.set_message( G_APP_NAME, OKL_API.G_INVALID_VALUE, OKL_API.G_COL_NAME_TOKEN, 'l_periods');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Line ID | OEC | EOT Amount | Arrears YN | Freq | Periods | LRF | Amt | Start Date ' );
      i := 1;
      -- Loop through all item categories and build the corresponding cash flows ..
      FOR t_rec IN item_cat_csr( p_qq_id => p_qq_hdr_rec.id )
      LOOP
        -- Calculate the EOT Amount. FORMULA: EOT% = EOT % * Asset OEC / 100;
        IF l_eot_type_code = 'AMOUNT' OR l_eot_type_code = 'RESIDUAL_AMOUNT'
        THEN
          l_item_cat_cf_tbl(i).eot_amount := t_rec.end_of_term_amount;
        ELSE
          l_item_cat_cf_tbl(i).eot_amount := t_rec.value * t_rec.end_of_term_amount / 100;
        END IF;
        -- Calculate the Asset level Financed Amount: FORMULA: Asset Fin. Amt = C - NVL(S+D+T, 0)
        l_asset_fin_amt := l_item_cat_cf_tbl(i).financed_amount - nvl( l_item_cat_cf_tbl(i).subsidy +
                            l_item_cat_cf_tbl(i).down_payment + l_item_cat_cf_tbl(i).trade_in, 0);
        -- Populating the Cash Flow Record
        l_item_cat_cf_tbl(i).cash_flow_rec.due_arrears_yn := p_qq_hdr_rec.target_arrears;
        l_item_cat_cf_tbl(i).cash_flow_rec.start_date := p_qq_hdr_rec.expected_start_date;
        -- Populating the Cash Flow Levels
        l_item_cat_cf_tbl(i).cash_flow_level_tbl(1).fqy_code := p_qq_hdr_rec.target_frequency;
        l_item_cat_cf_tbl(i).cash_flow_level_tbl(1).number_of_periods := l_periods;
        l_item_cat_cf_tbl(i).cash_flow_level_tbl(1).amount := t_rec.lease_rate_factor * l_asset_fin_amt;
        l_item_cat_cf_tbl(i).cash_flow_level_tbl(1).is_stub := 'N';
        l_item_cat_cf_tbl(i).cash_flow_level_tbl(1).start_date := p_qq_hdr_rec.expected_start_date;
        l_item_cat_cf_tbl(i).cash_flow_level_tbl(1).rate := t_rec.lease_rate_factor;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          t_rec.ID || ' | ' || round(l_item_cat_cf_tbl(i).financed_amount,2) || ' | ' || round(t_rec.end_of_term_amount, 2) || ' | ' ||
          p_qq_hdr_rec.target_arrears || ' | ' || p_qq_hdr_rec.target_frequency || ' | ' || l_periods || ' | ' ||
          t_rec.lease_rate_factor || ' | ' || round(l_item_cat_cf_tbl(i).cash_flow_level_tbl(1).amount,2) || ' | ' ||
          l_item_cat_cf_tbl(i).cash_flow_level_tbl(1).start_date );
        -- Increment the item category index
        i := i + 1;
      END LOOP; -- Loop on item_cat_csr
    END IF;
    -- Fetch the day convention from the Stream Generation Template ...
    get_qq_sgt_day_convention(
      p_api_version       => p_api_version,
      p_init_msg_list     => p_init_msg_list,
      x_return_status     => l_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      p_qq_id             => p_qq_hdr_rec.id,
      x_days_in_month     => x_days_in_month,
      x_days_in_year      => x_days_in_year);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After get_qq_sgt_day_convention ' || l_return_status );
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'SGT Day convention: ' || x_days_in_month || ' / ' || x_days_in_year);
    -- Return the values ...
    x_item_cat_cf_tbl  := l_item_cat_cf_tbl;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_qq_rc_cash_flows;


  -- This API is responsible to create cash flow and cash flow details records when
  --  the pricing type is Target Rate or
  --  User has picked the rate from SRT/LRS
  --  User has picked the structured pricing and mentiond the rate, periods, amount ..etc
  --
  -- Returns the populated cash flow record and cash flow levels table
  PROCEDURE get_qq_cash_flows(
             p_api_version          IN            NUMBER,
             p_init_msg_list        IN            VARCHAR2,
             x_return_status           OUT NOCOPY VARCHAR2,
             x_msg_count               OUT NOCOPY NUMBER,
             x_msg_data                OUT NOCOPY VARCHAR2,
             p_qq_hdr_rec           IN            so_hdr_rec_type,
             p_eot_percentage       IN            NUMBER,
             p_oec                  IN            NUMBER,
             x_days_in_month           OUT NOCOPY VARCHAR2,
             x_days_in_year            OUT NOCOPY VARCHAR2,
             x_cash_flow_rec           OUT NOCOPY so_cash_flows_rec_type,
             x_cash_flow_det_tbl       OUT NOCOPY so_cash_flow_details_tbl_type)
  IS
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_qq_cash_flows (QQ)';
    l_return_status               VARCHAR2(1);

    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

    -- Cursor Declarations
    CURSOR get_deal_size_csr( p_qq_id NUMBER )
    IS
      SELECT  sum(VALUE) deal_size
       FROM  OKL_QUICK_QUOTE_LINES_B qql
      WHERE  qql.quick_quote_id = p_qq_id
        AND  qql.TYPE = G_ITEMCATEGORY_TYPE; -- Item Category Type
    -- Local Variables declaration
    l_cash_flow_rec        so_cash_flows_rec_type;
    l_cash_flow_det_tbl    so_cash_flow_details_tbl_type;
    i                      NUMBER; -- Index for looping over the Cash Flow Details
    l_months_per_period    NUMBER;
    l_months_after         NUMBER;
    -- Lease Rate Factor Variables
    l_lrs_details          lrs_details_rec_type;
    l_lrs_factor           lrs_factor_rec_type;
    l_lrs_levels           lrs_levels_tbl_type;
    -- Standard Rate Template Variables
    l_srt_details          srt_details_rec_type;
    l_ac_rec_type          OKL_EC_EVALUATE_PVT.okl_ac_rec_type;
    l_adj_factor           NUMBER;
    l_deal_size            NUMBER;
    l_months_factor        NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Pricing Method is ' || p_qq_hdr_rec.pricing_method );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                ': p_qq_hdr_rec.rate_template_id=' || p_qq_hdr_rec.rate_template_id );
    i := 1;
    l_months_after := 0;
    l_adj_factor := 0;

    IF p_qq_hdr_rec.rate_template_id IS NOT NULL
    THEN
      -- Extract details from the Standard Rate Template
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Fetching the Details from the Standard Rate Template ' );
      get_standard_rates(
        p_api_version     => p_api_version,
        p_init_msg_list   => p_init_msg_list,
        x_return_status   => l_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_srt_id          => p_qq_hdr_rec.rate_template_id,
        p_start_date      => p_qq_hdr_rec.expected_start_date,
        x_srt_details     => l_srt_details);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                ': l_return_status ' || l_return_status );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Using SRT ' || l_srt_details.template_name || ' Version ' || l_srt_details.version_number
                 || ' Status ' || l_srt_details.sts_code  || ' Pricing Engine ' || l_srt_details.pricing_engine_code
                 || ' Rate Type ' || l_srt_details.rate_type_code  || ' Day Convention ' || l_srt_details.day_convention_code );
      IF l_srt_details.adj_mat_version_id IS NOT NULL
      THEN
        -- Fetch the Deal Size
        OPEN  get_deal_size_csr( p_qq_id => p_qq_hdr_rec.ID );
        FETCH get_deal_size_csr INTO l_deal_size;
        CLOSE get_deal_size_csr;
        -- Populate the Adjustment mat. rec.
        l_ac_rec_type.src_id := l_srt_details.adj_mat_version_id; -- Pricing adjustment matrix ID
        l_ac_rec_type.source_name := NULL; -- NOT Mandatory Pricing Adjustment Matrix Name !
        l_ac_rec_type.target_id := p_qq_hdr_rec.ID ; -- Quote ID
        l_ac_rec_type.src_type := 'PAM'; -- Lookup Code
        l_ac_rec_type.target_type := 'QUOTE'; -- Same for both Quick Quote and Standard Quote
        l_ac_rec_type.target_eff_from  := p_qq_hdr_rec.expected_start_date; -- Quote effective From
        l_ac_rec_type.term  := p_qq_hdr_rec.term; -- Remaining four will be from teh business object like QQ / LQ
        l_ac_rec_type.territory := p_qq_hdr_rec.sales_territory_id;
        l_ac_rec_type.deal_size := l_deal_size;
        l_ac_rec_type.customer_credit_class := NULL; -- Not sure how to pass this even ..
        -- Calling the API to get the adjustment factor ..
        okl_ec_evaluate_pvt. get_adjustment_factor(
           p_api_version       => p_api_version,
           p_init_msg_list     => p_init_msg_list,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_okl_ac_rec        => l_ac_rec_type,
           x_adjustment_factor => l_adj_factor );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Adjustment Factor ' ||  l_adj_factor );
      -- Populating the Cash flows
      l_cash_flow_rec.due_arrears_yn := p_qq_hdr_rec.target_arrears;
      l_cash_flow_rec.start_date := p_qq_hdr_rec.expected_start_date;
      -- Populating the Cash flow levels
      l_cash_flow_det_tbl(1).fqy_code := l_srt_details.frequency_code;
      l_cash_flow_det_tbl(1).rate := l_srt_details.srt_rate + nvl(l_srt_details.spread,0) + nvl(l_adj_factor,0); -- Rate is being stored as Percentage
      IF nvl( l_srt_details.min_adj_rate,l_cash_flow_det_tbl(1).rate) > l_cash_flow_det_tbl(1).rate
      THEN
        l_cash_flow_det_tbl(1).rate := l_srt_details.min_adj_rate;
      ELSIF nvl( l_srt_details.max_adj_rate,l_cash_flow_det_tbl(1).rate) < l_cash_flow_det_tbl(1).rate
      THEN
        l_cash_flow_det_tbl(1).rate := l_srt_details.max_adj_rate;
      END IF;
      l_cash_flow_det_tbl(1).is_stub := 'N';
      l_cash_flow_det_tbl(1).start_date := p_qq_hdr_rec.expected_start_date;
      l_cash_flow_det_tbl(1).number_of_periods := p_qq_hdr_rec.target_periods;
      l_cash_flow_det_tbl(1).amount := p_qq_hdr_rec.target_amount;
      x_days_in_year  := l_srt_details.day_convention_code;
      IF x_days_in_year = '360'
      THEN
         x_days_in_month := '30';
      ELSIF x_days_in_year = '365' OR x_days_in_year = 'ACTUAL'
      THEN
        x_days_in_month := 'ACTUAL';
      END IF;
    ELSIF p_qq_hdr_rec.pricing_method = 'TR'
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Building the Cash flows n Inflows ' || p_qq_hdr_rec.pricing_method );
      -- Populating the Cash flows
      l_cash_flow_rec.due_arrears_yn := p_qq_hdr_rec.target_arrears;
      l_cash_flow_rec.start_date := p_qq_hdr_rec.expected_start_date;
      -- Populating the Cash flow levels
      l_cash_flow_det_tbl(1).fqy_code := p_qq_hdr_rec.target_frequency;
      l_cash_flow_det_tbl(1).rate := p_qq_hdr_rec.target_rate; -- Rate is being stored as Percentage
      l_cash_flow_det_tbl(1).is_stub := 'N';
      l_cash_flow_det_tbl(1).start_date := p_qq_hdr_rec.expected_start_date;
      l_months_factor := okl_stream_generator_pvt.get_months_factor(
                            p_frequency     => p_qq_hdr_rec.target_frequency,
                            x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_cash_flow_det_tbl(1).number_of_periods := p_qq_hdr_rec.term / l_months_factor;
      IF l_cash_flow_det_tbl(1).number_of_periods <> TRUNC( l_cash_flow_det_tbl(1).number_of_periods )
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S', 'Periods has to be a whole number ');
        OKL_API.set_message( G_APP_NAME, OKL_API.G_INVALID_VALUE, OKL_API.G_COL_NAME_TOKEN, 'Target Frequency');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Fetch the day convention from the Stream Generation Template ...
      get_qq_sgt_day_convention(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_qq_id             => p_qq_hdr_rec.id,
        x_days_in_month     => x_days_in_month,
        x_days_in_year      => x_days_in_year);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'After get_qq_sgt_day_convention ' || l_return_status );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'SGT Day convention: ' || x_days_in_month || ' / ' || x_days_in_year);
    ELSIF p_qq_hdr_rec.structured_pricing <> 'N'
    THEN
      -- Structured Pricing API
      -- Get the Pricing Details
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Fetching from the Cash Flows ');
      get_qq_cash_flows(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => l_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_cf_source_type     => G_CF_SOURCE_QQ,
        p_qq_id              => p_qq_hdr_rec.id,
        x_days_in_month      => x_days_in_month,
        x_days_in_year       => x_days_in_year,
        x_cash_flow_rec      => l_cash_flow_rec,  -- Cash Flow Record
        x_cash_flow_det_tbl  => l_cash_flow_det_tbl); -- Cash Flow Details Table
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'After get_qq_cash_flows ' || l_return_status  );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'l_cash_flow_det_tbl.COUNT ' || l_cash_flow_det_tbl.COUNT);
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- IF p_qq_hdr_rec.pricing_method
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 ': Built the Cash flows and Levels ' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Arrears = ' || l_cash_flow_rec.due_arrears_yn
                            || 'Start Date=' || l_cash_flow_rec.start_date );
    IF l_cash_flow_det_tbl.COUNT > 0
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  ': Frequency | Rate | Stub Amount | Stub Days | Periods | Amount | Start Date ' );
      FOR t IN l_cash_flow_det_tbl.FIRST .. l_cash_flow_det_tbl.LAST
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   l_cash_flow_det_tbl(t).fqy_code || '|' || l_cash_flow_det_tbl(t).rate
                   || '|' || l_cash_flow_det_tbl(t).stub_days  || '|' || l_cash_flow_det_tbl(t).stub_amount
                   || '|' || l_cash_flow_det_tbl(t).number_of_periods || '|' || l_cash_flow_det_tbl(t).amount
                   || '|' || l_cash_flow_det_tbl(t).START_DATE || '|' || l_cash_flow_det_tbl(t).is_stub );
      END LOOP;
    END IF;
    -- Setting up the return variables
    x_cash_flow_rec        := l_cash_flow_rec;
    x_cash_flow_det_tbl    := l_cash_flow_det_tbl;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_qq_cash_flows;

  -- This API is responsible to create cash flow and cash flow details records when
  --  User has picked the rate from SRT for an Asset / Lease Quote
  --  User has picked the structured pricing and mentiond the rate, periods, amount ..etc
  --    either at the Lease Quote or Asset Level !
  -- Returns the populated cash flow record and cash flow levels table
  PROCEDURE get_lq_cash_flows(
             p_api_version          IN            NUMBER,
             p_init_msg_list        IN            VARCHAR2,
             x_return_status           OUT NOCOPY VARCHAR2,
             x_msg_count               OUT NOCOPY NUMBER,
             x_msg_data                OUT NOCOPY VARCHAR2,
             p_id                   IN            NUMBER,
             p_lq_srt_id            IN            NUMBER,
             p_cf_source            IN            VARCHAR2,
             p_adj_mat_cat_rec      IN            adj_mat_cat_rec,
             p_pricing_method       IN            VARCHAR2,
             x_days_in_month           OUT NOCOPY VARCHAR2,
             x_days_in_year            OUT NOCOPY VARCHAR2,
             x_cash_flow_rec           OUT NOCOPY so_cash_flows_rec_type,
             x_cash_flow_det_tbl       OUT NOCOPY so_cash_flow_details_tbl_type)
  IS
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_lq_cash_flows';
    l_return_status               VARCHAR2(1);

    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

    -- Cursor Declarations ..
    CURSOR quote_csr(qteid    NUMBER)
    IS
      SELECT qte.expected_start_date expected_start_date,
             qte.target_rate_type target_rate_type,
             qte.target_frequency target_frequency,
             qte.target_arrears_yn target_arrears,
             qte.target_rate target_rate,
             qte.target_periods target_periods,
             qte.target_amount target_amount,
             qte.term term,
             qte.structured_pricing structured_pricing,
             qte.pricing_method pricing_method
        FROM okl_lease_quotes_b qte
       WHERE qte.id = qteid;
    quote_rec  quote_csr%ROWTYPE;
    -- Cursor to fetch the ID of the CFL defined at Quote Level !
    CURSOR get_cfl_id_csr( qteId NUMBER )
    IS
      SELECT cfl.ID cfl_id,
             cfh.id caf_id,
             cfo.id cfo_id,
             cfh.sty_id stream_type_id
       FROM  OKL_CASH_FLOW_LEVELS cfl,
             OKL_CASH_FLOWS cfh,
             OKL_CASH_FLOW_OBJECTS cfo
       WHERE cfl.caf_id = cfh.id
         AND cfh.cfo_id = cfo.id
         AND cfo.source_table = 'OKL_LEASE_QUOTES_B'
         AND cfo.source_id = qteId
       ORDER BY cfl.start_date;
    -- Cursor to fetch the Details from the Asset
    CURSOR asset_details_csr( p_astId NUMBER )
    IS
      SELECT target_arrears,
             target_amount,
             parent_object_id
        FROM OKL_ASSETS_B
       WHERE id = p_astId;
    -- Cursor to fetch the Details from the Asset
    CURSOR fee_details_csr( p_feeId NUMBER )
    IS
      SELECT target_arrears,
             target_amount,
             parent_object_id,
             payment_type_id
        FROM OKL_FEES_B
       WHERE id = p_feeId;
    -- Cursor to fetch the Cash flow header information
    CURSOR lq_cash_flows_csr( p_id NUMBER, p_cf_source_type VARCHAR2 )
    IS
      SELECT   cf.id  caf_id
              ,dnz_khr_id khr_id
              ,dnz_qte_id qte_id
              ,cfo_id cfo_id
              ,sts_code sts_code
              ,sty_id sty_id
              ,cft_code cft_code
              ,due_arrears_yn due_arrears_yn
              ,start_date start_date
              ,number_of_advance_periods number_of_advance_periods
              ,oty_code oty_code
      FROM    OKL_CASH_FLOWS         cf,
              OKL_CASH_FLOW_OBJECTS  cfo
     WHERE    cf.cfo_id = cfo.id
       AND    cfo.source_table = p_cf_source_type
       AND    cfo.source_id = p_id;
    -- Cursor to fetch the Cash Flow Details
    CURSOR lq_cash_flow_levels_csr( p_caf_id NUMBER )
    IS
      SELECT  id cfl_id
             ,caf_id
             ,fqy_code
             ,rate  -- No rate is defined at Cash Flows Level.. Need to confirm
             ,stub_days
             ,stub_amount
             ,number_of_periods
             ,amount
             ,start_date
        FROM OKL_CASH_FLOW_LEVELS
       WHERE caf_id = p_caf_id
      ORDER BY start_date;
    -- Local Variables declaration
    l_cash_flow_rec        so_cash_flows_rec_type;
    l_cash_flow_det_tbl    so_cash_flow_details_tbl_type;
    i                      NUMBER; -- Index for looping over the Cash Flow Details
    l_months_per_period    NUMBER;
    l_months_after         NUMBER;
    -- Standard Rate Template Variables
    l_srt_details          srt_details_rec_type;
    l_ac_rec_type          OKL_EC_EVALUATE_PVT.okl_ac_rec_type;
    l_adj_factor           NUMBER;
    l_months_factor        NUMBER;
    l_lq_id                NUMBER;
    l_target_arrears       NUMBER;
    cfl_index              BINARY_INTEGER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S', ': p_id=' || p_id );
    i := 1;
    l_months_after := 0;
    l_adj_factor := 0;
    IF p_cf_source = G_CF_SOURCE_LQ
    THEN
      l_lq_id := p_id;
    ELSIF p_cf_source = G_CF_SOURCE_LQ_ASS
    THEN
      FOR t_rec IN asset_details_csr( p_id )
      LOOP
        l_lq_id := t_rec.parent_object_id;
      END LOOP;
    ELSIF p_cf_source = G_CF_SOURCE_LQ_FEE
    THEN
      FOR t_rec IN fee_details_csr( p_id )
      LOOP
        l_lq_id := t_rec.parent_object_id;
      END LOOP;
    END IF;
    -- Check whether the pricing method is of type Rate Card
    IF p_lq_srt_id IS NOT NULL
    THEN
      -- Fetch the target column values ..
      OPEN quote_csr(qteid => l_lq_id );
      FETCH quote_csr INTO quote_rec;
      CLOSE quote_csr;
      -- Extract details from the Standard Rate Template
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Fetching the Details from the Standard Rate Template ' );
      get_standard_rates(
        p_api_version     => p_api_version,
        p_init_msg_list   => p_init_msg_list,
        x_return_status   => l_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_srt_id          => p_lq_srt_id,
        p_start_date      => p_adj_mat_cat_rec.target_eff_from,
        x_srt_details     => l_srt_details);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  ': l_return_status ' || l_return_status );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
             'Using SRT ' || l_srt_details.template_name || ' Version ' || l_srt_details.version_number
             || ' Status ' || l_srt_details.sts_code || ' Pricing Engine ' || l_srt_details.pricing_engine_code
             || ' Rate Type ' || l_srt_details.rate_type_code || ' Day Convention ' ||
             l_srt_details.day_convention_code );
      -- Need to apply the Adjustment factor to the rate !
      IF l_srt_details.adj_mat_version_id IS NOT NULL
      THEN
        l_ac_rec_type.src_id := l_srt_details.adj_mat_version_id; -- Pricing adjustment matrix ID
        l_ac_rec_type.source_name := NULL; -- NOT Mandatory Pricing Adjustment Matrix Name !
        l_ac_rec_type.target_id := l_lq_id; -- Quote ID
        l_ac_rec_type.src_type := 'PAM'; -- Lookup Code
        l_ac_rec_type.target_type := 'QUOTE'; -- Same for both Quick Quote and Standard Quote
        l_ac_rec_type.target_eff_from  := p_adj_mat_cat_rec.target_eff_from; -- Quote effective From
        l_ac_rec_type.term  := p_adj_mat_cat_rec.term; -- Remaining four will be from teh business object like QQ / LQ
        l_ac_rec_type.territory := p_adj_mat_cat_rec.territory;
        l_ac_rec_type.deal_size := p_adj_mat_cat_rec.deal_size; -- Not sure how to pass this value
        l_ac_rec_type.customer_credit_class := p_adj_mat_cat_rec.customer_credit_class; -- Not sure how to pass this even ..
        -- Calling the API to get the adjustment factor ..
        okl_ec_evaluate_pvt. get_adjustment_factor(
           p_api_version       => p_api_version,
           p_init_msg_list     => p_init_msg_list,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_okl_ac_rec        => l_ac_rec_type,
           x_adjustment_factor => l_adj_factor );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      -- Populating the Cash flow Header information
      IF p_cf_source = G_CF_SOURCE_LQ
      THEN
        l_cash_flow_rec.due_arrears_yn := quote_rec.target_arrears;
        l_cash_flow_det_tbl(1).amount := quote_rec.target_amount;
      ELSIF p_cf_source = G_CF_SOURCE_LQ_ASS
      THEN
        FOR t_rec IN asset_details_csr( p_id )
        LOOP
          l_cash_flow_rec.due_arrears_yn := t_rec.target_arrears;
          l_cash_flow_det_tbl(1).amount := t_rec.target_amount;
        END LOOP;
      ELSIF p_cf_source = G_CF_SOURCE_LQ_FEE
      THEN
        FOR t_rec IN fee_details_csr( p_id )
        LOOP
          l_cash_flow_rec.due_arrears_yn := t_rec.target_arrears;
          l_cash_flow_rec.sty_id         := t_rec.payment_type_id;
          l_cash_flow_det_tbl(1).amount  := t_rec.target_amount;
        END LOOP;
      END IF;
      l_cash_flow_rec.start_date := quote_rec.expected_start_date;
      IF quote_rec.pricing_method <> 'SM'
      THEN
        l_cash_flow_rec.sts_code := 'WORK';
        -- Populating the Cash flow levels
        l_cash_flow_det_tbl(1).fqy_code := l_srt_details.frequency_code;
        l_cash_flow_det_tbl(1).rate := l_srt_details.srt_rate + nvl(l_srt_details.spread,0) + nvl(l_adj_factor,0); -- Rate is being stored as Percentage
        IF nvl( l_srt_details.min_adj_rate,l_cash_flow_det_tbl(1).rate) > l_cash_flow_det_tbl(1).rate
        THEN
          l_cash_flow_det_tbl(1).rate := l_srt_details.min_adj_rate;
        ELSIF nvl( l_srt_details.max_adj_rate,l_cash_flow_det_tbl(1).rate) < l_cash_flow_det_tbl(1).rate
        THEN
          l_cash_flow_det_tbl(1).rate := l_srt_details.max_adj_rate;
        END IF;
        l_cash_flow_det_tbl(1).is_stub := 'N';
        l_cash_flow_det_tbl(1).start_date := quote_rec.expected_start_date;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
              'GET_LQ p_frequency_passed' || l_srt_details.frequency_code);
        l_months_factor := okl_stream_generator_pvt.get_months_factor(
                              p_frequency       =>   l_srt_details.frequency_code,
                              x_return_status   =>   l_return_status);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
              'p_months_factor'||l_months_factor);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_cash_flow_det_tbl(1).number_of_periods := quote_rec.term / l_months_factor;
        --l_cash_flow_det_tbl(1).amount has been already fetched from the
        -- target_amount column either from OKL_LEASE_QUOTES_B/OKL_ASSETS_B/OKL_FEES_B
      ELSE
        -- When the LQ is being priced for SM pricng method, on selecting the SRT
        --  as the pricing option, the user will be shown to enter the Cash flow levels too.
        -- Hence, retrieve the cash flow levels even when the pricing option is SRT.
        -- From SRT, get the Rate,Frequency
        -- From CFL, get the Advance/Arrears, n, Fetching the Cash Flows Information
        l_return_status := OKL_API.G_RET_STS_ERROR;
        FOR t_rec in lq_cash_flows_csr( p_id =>p_id,
                                        p_cf_source_type => p_cf_source )
        LOOP
          l_cash_flow_rec.caf_id   := t_rec.caf_id;
          l_cash_flow_rec.khr_id   := t_rec.khr_id;
          l_cash_flow_rec.khr_id   := t_rec.khr_id;
          l_cash_flow_rec.qte_id   := t_rec.qte_id;
          l_cash_flow_rec.cfo_id   := t_rec.cfo_id;
          l_cash_flow_rec.sts_code := t_rec.sts_code;
          l_cash_flow_rec.sty_id   := t_rec.sty_id;
          l_cash_flow_rec.cft_code := t_rec.cft_code;
          l_cash_flow_rec.due_arrears_yn := t_rec.due_arrears_yn;
          l_cash_flow_rec.start_date     := t_rec.start_date;
          l_cash_flow_rec.number_of_advance_periods := t_rec.number_of_advance_periods;
          -- Use l_retun_status as a flag
          l_return_status := OKL_API.G_RET_STS_SUCCESS;
        END LOOP;
        -- Fetch the Cash Flow Levels information only if the Cash Flow is present..
        IF l_return_status = OKL_API.G_RET_STS_SUCCESS
        THEN
          cfl_index := 1;
          l_return_status := OKL_API.G_RET_STS_ERROR;
          -- Cash Flows exists. So, fetch the Cash Flow Levels
          FOR t_rec in lq_cash_flow_levels_csr( l_cash_flow_rec.caf_id )
          LOOP
            l_cash_flow_det_tbl(cfl_index).cfl_id      := t_rec.cfl_id;
            l_cash_flow_det_tbl(cfl_index).caf_id      := t_rec.caf_id;
            l_cash_flow_det_tbl(cfl_index).fqy_code    := l_srt_details.frequency_code;
            -- Effective Rate from SRT = Rate + Spread + Adj Matrix
            l_cash_flow_det_tbl(cfl_index).rate :=
              l_srt_details.srt_rate + nvl(l_srt_details.spread,0) + nvl(l_adj_factor,0);
            IF nvl( l_srt_details.min_adj_rate,l_cash_flow_det_tbl(cfl_index).rate) >
               l_cash_flow_det_tbl(cfl_index).rate
            THEN
              l_cash_flow_det_tbl(cfl_index).rate := l_srt_details.min_adj_rate;
            ELSIF nvl( l_srt_details.max_adj_rate, l_cash_flow_det_tbl(1).rate) <
                  l_cash_flow_det_tbl(cfl_index).rate
            THEN
              l_cash_flow_det_tbl(cfl_index).rate := l_srt_details.max_adj_rate;
            END IF;
            l_cash_flow_det_tbl(cfl_index).stub_days   := t_rec.stub_days;
            l_cash_flow_det_tbl(cfl_index).stub_amount := t_rec.stub_amount;
            l_cash_flow_det_tbl(cfl_index).number_of_periods := t_rec.number_of_periods;
            l_cash_flow_det_tbl(cfl_index).amount      := t_rec.amount;
            l_cash_flow_det_tbl(cfl_index).start_date  := t_rec.start_date;
            -- Remember the flag whether its a stub payment or not
            IF t_rec.stub_days IS NOT NULL and t_rec.stub_amount IS NOT NULL
            THEN
              -- Stub Payment
              l_cash_flow_det_tbl(cfl_index).is_stub := 'Y';
            ELSE
              -- Regular Periodic Payment
              l_cash_flow_det_tbl(cfl_index).is_stub := 'N';
            END IF;
            -- Use l_retun_status as a flag
            l_return_status := OKL_API.G_RET_STS_SUCCESS;
            -- Increment i
            cfl_index := cfl_index + 1;
          END LOOP;
        ELSE
          l_return_status := OKL_API.G_RET_STS_SUCCESS;
        END IF;
      END IF;
      -- Get the Day convention from the SRT itself !
      x_days_in_year  := l_srt_details.day_convention_code;
      IF x_days_in_year = '360'
      THEN
         x_days_in_month := '30';
      ELSIF x_days_in_year = '365' OR x_days_in_year = 'ACTUAL'
      THEN
        x_days_in_month := 'ACTUAL';
      END IF;
    ELSIF p_pricing_method = 'TR'
    THEN
      -- Fetch the target column values ..
      OPEN quote_csr(qteid => l_lq_id );
      FETCH quote_csr INTO quote_rec;
      CLOSE quote_csr;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After fetching the quote_csr details ');
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Building the Cash flows n Inflows ' || p_pricing_method );
      -- Populating the Cash flows
      IF p_cf_source = G_CF_SOURCE_LQ_FEE
      THEN
        -- For Rollover/Financed fee, though the PM is TR, where LLO is not applicable
        -- there also, pricing will fetch Adv/Arrears, Rate, Frequency will be fetched
        -- from the quote, but the Payment Stream ID will be store in the okl_fees_b.payment_sty_id
        FOR t_rec IN fee_details_csr( p_id )
        LOOP
          l_cash_flow_rec.sty_id         := t_rec.payment_type_id;
        END LOOP;
      END IF;
      l_cash_flow_rec.due_arrears_yn := quote_rec.target_arrears;
      l_cash_flow_rec.start_date := quote_rec.expected_start_date;
      -- Populating the Cash flow levels
      l_cash_flow_det_tbl(1).fqy_code := quote_rec.target_frequency;
      l_cash_flow_det_tbl(1).rate := quote_rec.target_rate; -- Rate is being stored as Percentage
      l_cash_flow_det_tbl(1).is_stub := 'N';
      l_cash_flow_det_tbl(1).start_date := quote_rec.expected_start_date;
      l_cash_flow_det_tbl(1).number_of_periods := quote_rec.target_periods;
      -- Need to fetch the CFL Id for the Updation
      FOR t_rec IN get_cfl_id_csr( qteId => p_id )
      LOOP
        l_cash_flow_rec.caf_id := t_rec.caf_id;
        l_cash_flow_rec.cfo_id := t_rec.cfo_id;
        l_cash_flow_rec.sty_id := t_rec.stream_type_id;
        l_cash_flow_det_tbl(1).cfl_id := t_rec.cfl_id;
      END LOOP;
      get_lq_sgt_day_convention(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_lq_id             => p_id,
        x_days_in_month     => x_days_in_month,
        x_days_in_year      => x_days_in_year);
     put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   ': After Fetching the Day convention from the SGT - TR ' );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE
      -- Assuming that the Asset is having Structured Pricing overridden
      --  from that of the Payment Structure defined at the Lease Quote level
      get_qq_cash_flows(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => l_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_cf_source_type     => p_cf_source, -- Pass the source type OKL_ASSETS_B/OKL_LEASE_QUOTES_B
        p_qq_id              => p_id,  -- Pass the id of the Assets/ Lease Quote !
        x_days_in_month      => x_days_in_month,
        x_days_in_year       => x_days_in_year,
        x_cash_flow_rec      => l_cash_flow_rec,  -- Cash Flow Record
        x_cash_flow_det_tbl  => l_cash_flow_det_tbl); -- Cash Flow Details Table
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After get_qq_cash_flows ' || l_return_status  );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_cash_flow_det_tbl.COUNT ' || l_cash_flow_det_tbl.COUNT);
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- IF p_qq_hdr_rec.pricing_method
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   ': Built the Cash flows and Levels ' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Arrears = ' || l_cash_flow_rec.due_arrears_yn
                            || 'Start Date=' || l_cash_flow_rec.start_date );
    IF l_cash_flow_det_tbl.COUNT > 0
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   ': Frequency | Rate | Stub Amount | Stub Days | Periods | Amount | Start Date ' );
      FOR t IN l_cash_flow_det_tbl.FIRST .. l_cash_flow_det_tbl.LAST
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   l_cash_flow_det_tbl(t).fqy_code  || '|' || l_cash_flow_det_tbl(t).rate
                   || '|' || l_cash_flow_det_tbl(t).stub_days || '|' || l_cash_flow_det_tbl(t).stub_amount
                   || '|' || l_cash_flow_det_tbl(t).number_of_periods
                   || '|' || l_cash_flow_det_tbl(t).amount  || '|' || l_cash_flow_det_tbl(t).start_date
                   || '|' || l_cash_flow_det_tbl(t).is_stub );
      END LOOP;
    END IF;
    -- Setting up the return variables
    x_cash_flow_rec        := l_cash_flow_rec;
    x_cash_flow_det_tbl    := l_cash_flow_det_tbl;
    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_lq_cash_flows;

  -- API to price a quick quote... Just need to pass me the ID ;-)
  PROCEDURE price_quick_quote(
             p_api_version              IN              NUMBER,
             p_init_msg_list            IN              VARCHAR2,
             x_return_status            OUT      NOCOPY VARCHAR2,
             x_msg_count                OUT      NOCOPY NUMBER,
             x_msg_data                 OUT      NOCOPY VARCHAR2,
             p_qq_id                    IN              NUMBER,
             x_yileds_rec               OUT      NOCOPY yields_rec,
             x_subsidized_yileds_rec    OUT      NOCOPY yields_rec,
             x_pricing_results_tbl      OUT      NOCOPY pricing_results_tbl_type )
  IS
    -- Cursor to fetch EOT Type
    CURSOR get_eot_type( p_qq_id NUMBER )
    IS
      SELECT  qq.id
         ,qq.reference_number
         ,eot.end_of_term_name
         ,eot.eot_type_code eot_type_code
         ,eot.end_of_term_id end_of_term_id
         ,eotversion.end_of_term_ver_id
     FROM OKL_QUICK_QUOTES_B qq,
          okl_fe_eo_term_vers eotversion,
          okl_fe_eo_terms_all_b eot
     WHERE qq.END_OF_TERM_OPTION_ID = eotversion.end_of_term_ver_id
       AND eot.end_of_term_id = eotversion.end_of_term_id
       AND qq.id = p_qq_id;

    --Bug 5884825 PAGARG start
    CURSOR get_product_name( p_qq_id NUMBER )
    IS
      SELECT PDT.NAME PRODUCTNAME
      FROM OKL_QUICK_QUOTES_B QQ
         , OKL_FE_EO_TERM_VERS EOTVERSION
         , OKL_FE_EO_TERMS_ALL_B EOT
         , OKL_PRODUCTS PDT
      WHERE QQ.END_OF_TERM_OPTION_ID = EOTVERSION.END_OF_TERM_VER_ID
        AND EOT.END_OF_TERM_ID       = EOTVERSION.END_OF_TERM_ID
        AND PDT.ID                   = EOT.PRODUCT_ID
        AND QQ.ID                    = P_QQ_ID;
    --Bug 5884825 PAGARG End

    -- Local Variables
    l_product_name                okl_products.NAME%TYPE;--Bug 5884825 PAGARG
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'price_quick_quote';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled             VARCHAR2(10);
    is_debug_procedure_on       BOOLEAN;
    is_debug_statement_on       BOOLEAN;
    -- Declarations
    l_valid_pm                  BOOLEAN; -- Flag holding true/false for valid Pricing Method
    l_tot_item_cat_amount       NUMBER;
    l_tot_rent_payment          NUMBER;
    l_tot_eot_amount            NUMBER;
    l_eot_percentage            NUMBER;
    l_oec                       NUMBER;
    l_hdr_rec                   so_hdr_rec_type;
    l_item_cat_tbl              so_asset_details_tbl_type;
    l_residual_strms_tbl        cash_inflows_tbl_type;
    l_pricing_parameters_rec    pricing_parameter_rec_type;
    l_pricing_parameters_tbl    pricing_parameter_tbl_type;
    l_pricing_parameters_tbl_cp pricing_parameter_tbl_type;
    l_tmp_prc_params_tbl        pricing_parameter_tbl_type;
    pp_index                    NUMBER;  -- Index for the l_pricing_parameters_tbl
    l_fin_adj_rec               so_amt_details_rec_type;
    l_cash_flow_rec             so_cash_flows_rec_type;
    l_cash_flow_det_tbl         so_cash_flow_details_tbl_type;
    l_fee_srv_tbl               so_fee_srv_tbl_type;
    l_strm_ele_tbl              cash_inflows_tbl_type;
    l_dummy_strm_ele_tbl        cash_inflows_tbl_type;
    l_eot_date                  DATE;
    l_iir                       NUMBER;
    l_irr                       NUMBER;
    l_bk_yield                  NUMBER;
    l_cf_dpp                    NUMBER;
    l_cf_ppy                    NUMBER;
    l_day_count_method          VARCHAR2(30);
    l_days_in_month             VARCHAR2(30);
    l_days_in_year              VARCHAR2(30);
    l_miss_payment              NUMBER;
    l_yields_rec                yields_rec;
    l_subsidized_yields_rec     yields_rec;
    l_qqlv_rec                  OKL_QQL_PVT.qqlv_rec_type;
    x_qqlv_rec                  OKL_QQL_PVT.qqlv_rec_type;
    x_termination_tbl           cash_inflows_tbl_type;
    x_pre_tax_inc_tbl           cash_inflows_tbl_type;
    i                           NUMBER;
    res_index                   NUMBER := 1;
    l_frequency                 VARCHAR2(30);
    l_item_cat_cf_tbl           item_cat_cf_tbl_type;
    l_tmp_pp_index              NUMBER;
    l_sgt_days_in_month         VARCHAR2(30);
    l_sgt_days_in_year          VARCHAR2(30);
    l_sgt_day_count_method      VARCHAR2(30);
    l_eot_type_code             VARCHAR2(30);
    l_net_percent               NUMBER;
    l_net_financed_amount       NUMBER;
    l_closing_balance           NUMBER;
    l_residual_percent          NUMBER;
    l_residual_int_factor       NUMBER;
    l_net_adj_amt               NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    -- Call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   ': p_qq_id ' || p_qq_id  );

    --Bug 5884825 PAGARG start
    OPEN get_product_name(p_qq_id);
    FETCH get_product_name INTO l_product_name;
    CLOSE get_product_name;
    --Bug 5884825 PAGARG end

    -- Fetch the Header Details such as Start Date, Term, Pricing Method .. etc
    get_so_hdr(
      p_api_version       => p_api_version,
      p_init_msg_list     => p_init_msg_list,
      x_return_status     => l_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      p_so_id             => p_qq_id,
      p_so_type           => 'QQ',
      x_so_hdr_rec        => l_hdr_rec );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After get_so_hdr  ' || l_return_status );
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Pricing Method for Quick Quote
    -- RC, SF, SP, SS, SY, TR are the permitted pricing methods for the Quick Quote
    l_valid_pm := validate_pricing_method(
                    p_pricing_method  => l_hdr_rec.pricing_method,
                    p_object_type     => 'QQ',
                    x_return_status   => l_return_status);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After validate_pricing_method ' || l_return_status );
    IF l_valid_pm
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'l_valid_pm = TRUE' );
    ELSE
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_valid_pm = FALSE' );
    END IF;
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- If Pricing Method is invalid .. raise exception ..
    IF l_valid_pm = FALSE
    THEN
      -- Display a message and raise an exception ..
      OKL_API.SET_MESSAGE(
        p_app_name     => g_app_name,
        p_msg_name     => g_invalid_value,
        p_token1       => g_col_name_token,
        p_token1_value => 'Pricing Method');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Know the type of the EOT and then proceed with the values directly or calculate the amount
    FOR t_rec IN get_eot_type( p_qq_id => p_qq_id  )
    LOOP
      l_eot_type_code := t_rec.eot_type_code;
    END LOOP;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'l_eot_type_code=' || l_eot_type_code );
    -- Get Item Costs, Residual Values
    get_qq_item_cat_details(
      p_api_version         => p_api_version,
      p_init_msg_list       => p_init_msg_list,
      x_return_status       => l_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_qq_id               => p_qq_id,
      p_pricing_method      => l_hdr_rec.pricing_method,
      x_asset_amounts_tbl   => l_item_cat_tbl);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After get_qq_item_cat_details ' || l_return_status );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_item_cat_tbl.COUNT ' || l_item_cat_tbl.COUNT );
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Loop through the Item Category Table and determine the Total Item Cat Cost
    l_tot_item_cat_amount := 0;
    l_tot_eot_amount := 0;
    IF l_hdr_rec.pricing_method <> 'SF' AND
       l_item_cat_tbl IS NOT NULL       AND
       l_item_cat_tbl.COUNT > 0
    THEN
      FOR i in l_item_cat_tbl.FIRST .. l_item_cat_tbl.LAST
      LOOP
        l_tot_item_cat_amount := l_tot_item_cat_amount + nvl( l_item_cat_tbl(i).asset_cost,0);
      END LOOP;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_tot_item_cat_amount =' || l_tot_item_cat_amount );
    -- Calculate the total End of term value amount
    l_tot_eot_amount := 0;
    IF l_item_cat_tbl IS NOT NULL       AND
       l_item_cat_tbl.COUNT > 0
    THEN
      FOR itc_index in l_item_cat_tbl.FIRST .. l_item_cat_tbl.LAST
      LOOP
        l_tot_eot_amount := l_tot_eot_amount + l_item_cat_tbl(itc_index).end_of_term_amount;
      END LOOP;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'l_tot_eot_amount =' || l_tot_eot_amount );
    -- Get Finance Adjustment Details
    --  like down payment, trade in, subsidy
    get_qq_fin_adj_details(
      p_api_version          => p_api_version,
      p_init_msg_list        => p_init_msg_list,
      x_return_status        => l_return_status,
      x_msg_count            => x_msg_count,
      x_msg_data             => x_msg_data,
      p_qq_id                => p_qq_id,
      p_pricing_method       => l_hdr_rec.pricing_method,
      p_item_category_amount => l_tot_item_cat_amount,
      x_all_amounts_rec      => l_fin_adj_rec);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After get_qq_fin_adj_details ' || l_return_status  );
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Possibly now, we can build the Pricing Parameter Record
    l_pricing_parameters_rec.financed_amount := l_tot_item_cat_amount;
    l_pricing_parameters_rec.trade_in        := l_fin_adj_rec.tradein_amount;
    l_pricing_parameters_rec.down_payment    := l_fin_adj_rec.down_payment_amount;
    l_pricing_parameters_rec.subsidy         := l_fin_adj_rec.subsidy_amount;

    -- Calculate the eot percentage using the formula
    -- ( l_tot_eot_amount / l_tot_item_cat_amount - subsidy - downpayment - trade in ) * 100
    l_eot_percentage := 0;
    IF l_hdr_rec.pricing_method <> 'SF'
    THEN
      -- Need to deduct the Trade_in, Subsidy, Down Payment values from the
      get_qq_asset_oec (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_asset_cost        => l_tot_item_cat_amount,
        p_fin_adj_det_rec   => l_fin_adj_rec,
        x_oec               => l_oec);
     put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After get_qq_asset_oec ' || l_return_status  );
     put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_oec=' || nvl( l_oec, 0 ) );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_eot_percentage := ( l_tot_eot_amount / l_oec ) * 100; -- EOT Percentage;
    END IF;
    IF l_hdr_rec.pricing_method = 'RC' -- Rate card pricing
    THEN
      -- Build the cash flows when the pricing method is Rate Card !
      get_qq_rc_cash_flows(
         p_api_version      => p_api_version,
         p_init_msg_list    => p_init_msg_list,
         x_return_status    => l_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
         p_qq_hdr_rec       => l_hdr_rec,
         x_days_in_month    => l_days_in_month,
         x_days_in_year     => l_days_in_year,
         x_item_cat_cf_tbl  => l_item_cat_cf_tbl);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After get_qq_rc_cash_flows ' || l_return_status );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- The frequency needs to be fetched from the target_frequency
      l_frequency := l_item_cat_cf_tbl(1).cash_flow_level_tbl(1).fqy_code;
    ELSE
      -- Retrieve or build the Cash flows and Levels when user picked
      --     Structured pricing / SRT ..
      -- Modifying this API to fetch you the pricing day convention
      get_qq_cash_flows(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => l_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_qq_hdr_rec         => l_hdr_rec,
        p_eot_percentage     => l_eot_percentage,
        p_oec                => l_oec,
        x_days_in_month      => l_days_in_month,
        x_days_in_year       => l_days_in_year,
        x_cash_flow_rec      => l_cash_flow_rec,  -- Cash Flow Record
        x_cash_flow_det_tbl  => l_cash_flow_det_tbl); -- Cash Flow Details Table
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After get_qq_cash_flows ' || l_return_status );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Generate the Streams
      IF l_cash_flow_det_tbl IS NOT NULL AND
         l_cash_flow_det_tbl.COUNT > 0
      THEN
        -- Initialize the Strm Count to Zero
        gen_so_cf_strms(
          p_api_version            => p_api_version,
          p_init_msg_list          => p_init_msg_list,
          x_return_status          => l_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_cash_flow_rec          => l_cash_flow_rec,
          p_cf_details_tbl         => l_cash_flow_det_tbl,
          x_cash_inflow_strms_tbl  => l_strm_ele_tbl);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_frequency := l_cash_flow_det_tbl(l_cash_flow_det_tbl.FIRST).fqy_code;
      ELSE
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'No Cash flow and Cash flow Levels obtained ! ' );
        OKL_API.SET_MESSAGE (
          p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKL_LLA_PMT_SELECT');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- IF on Rate Card Pricing Method ..
    -- Build the Residuals Table
    IF l_item_cat_tbl IS NOT NULL AND
       l_item_cat_tbl.COUNT > 0
    THEN
      okl_stream_generator_pvt.add_months_new(
        p_start_date     => l_hdr_rec.expected_start_date,
        p_months_after   => l_hdr_rec.term,
        x_date           => l_eot_date,
        x_return_status  => l_return_status);
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_eot_date := l_eot_date - 1;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'QQ End date: ' || l_eot_date);
      -- Get the DPP and PPY inorder to populate for the Residuals Table
      get_dpp_ppy(
        p_frequency            => l_frequency,
        x_dpp                  => l_cf_dpp,
        x_ppy                  => l_cf_ppy,
        x_return_status        => l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After get_dpp_ppy : ' || l_return_status);
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF l_hdr_rec.pricing_method <> 'RC'
      THEN
        FOR i in l_item_cat_tbl.FIRST .. l_item_cat_tbl.LAST
        LOOP
          l_residual_strms_tbl(i).line_number := i;
          l_residual_strms_tbl(i).cf_amount   := l_item_cat_tbl(i).end_of_term_amount;
          l_residual_strms_tbl(i).cf_date     := l_eot_date;
          l_residual_strms_tbl(i).cf_miss_pay := 'N';
          l_residual_strms_tbl(i).is_stub     := 'N';
          l_residual_strms_tbl(i).is_arrears  := 'Y';
          l_residual_strms_tbl(i).cf_dpp := l_cf_dpp;
          l_residual_strms_tbl(i).cf_ppy := l_cf_ppy;
        END LOOP;
      END IF; -- IF l_hdr_rec.pricing_method <> 'RC'
    END IF;
    pp_index := 1;
    IF l_hdr_rec.pricing_method = 'RC'
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Populate the Cash Flows and Levels for all item categories ');
      -- Generate the Streams
      FOR t IN l_item_cat_cf_tbl.FIRST .. l_item_cat_cf_tbl.LAST
      LOOP
        l_pricing_parameters_tbl(pp_index).line_type := 'FREE_FORM1';
        l_pricing_parameters_tbl(pp_index).line_start_date := l_hdr_rec.expected_start_date;
        l_pricing_parameters_tbl(pp_index).financed_amount := l_item_cat_cf_tbl(t).financed_amount;
        l_pricing_parameters_tbl(pp_index).down_payment := l_item_cat_cf_tbl(t).down_payment;
        l_pricing_parameters_tbl(pp_index).subsidy := l_item_cat_cf_tbl(t).subsidy;
        l_pricing_parameters_tbl(pp_index).trade_in := l_item_cat_cf_tbl(t).trade_in;

        -- Storing the residual streams ..
        res_index := 1;
        l_pricing_parameters_tbl(pp_index).residual_inflows(res_index).line_number := res_index;
        l_pricing_parameters_tbl(pp_index).residual_inflows(res_index).cf_amount := l_item_cat_cf_tbl(t).eot_amount;
        l_pricing_parameters_tbl(pp_index).residual_inflows(res_index).cf_date     := l_eot_date;
        l_pricing_parameters_tbl(pp_index).residual_inflows(res_index).cf_miss_pay := 'N';
        l_pricing_parameters_tbl(pp_index).residual_inflows(res_index).is_stub     := 'N';
        l_pricing_parameters_tbl(pp_index).residual_inflows(res_index).is_arrears  := 'Y';
        l_pricing_parameters_tbl(pp_index).residual_inflows(res_index).cf_dpp := l_cf_dpp;
        l_pricing_parameters_tbl(pp_index).residual_inflows(res_index).cf_ppy := l_cf_ppy;

        IF l_item_cat_cf_tbl(t).cash_flow_level_tbl IS NOT NULL AND
           l_item_cat_cf_tbl(t).cash_flow_level_tbl.COUNT > 0
        THEN
          -- Initialize the Strm Count to Zero
          gen_so_cf_strms(
            p_api_version            => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_cash_flow_rec          => l_item_cat_cf_tbl(t).cash_flow_rec,
            p_cf_details_tbl         => l_item_cat_cf_tbl(t).cash_flow_level_tbl,
            x_cash_inflow_strms_tbl  => l_strm_ele_tbl);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After gen_so_cf_strms ' || l_return_status );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        ELSE
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'No Cash flow and Cash flow Levels obtained ! ' );
          OKL_API.SET_MESSAGE (
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_LLA_PMT_SELECT');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_pricing_parameters_tbl(pp_index).cash_inflows := l_strm_ele_tbl;
        l_strm_ele_tbl.DELETE;
        -- Increment the pricing param index ..
        pp_index := pp_index + 1;
      END LOOP;
      -- Remember the pp_index count ... for calling the IIR !!
      l_tmp_pp_index := pp_index - 1;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'No. of Item Pricing Params built for RC (l_tmp_pp_index ) ' || l_tmp_pp_index );
    ELSE
      -- Build the pricing param rec with line type as FREE_FORM1
      l_pricing_parameters_rec.residual_inflows := l_residual_strms_tbl;
      l_pricing_parameters_rec.cash_inflows     := l_strm_ele_tbl;
      -- Build the pricing parameters table !!
      l_pricing_parameters_tbl(pp_index) := l_pricing_parameters_rec;
      l_pricing_parameters_tbl(pp_index).line_type := 'FREE_FORM1';
      -- Increment the pp_index ...
      pp_index := pp_index + 1;
    END IF;
    -- Initialize things common for various Pricing Methods
    -- Assigning the day count methods !
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'l_days_in_month= ' || l_days_in_month ||  ' |  l_days_in_year = ' || l_days_in_year);
    get_day_count_method(
      p_days_in_month    => l_days_in_month,
      p_days_in_year     => l_days_in_year,
      x_day_count_method => l_day_count_method,
      x_return_status    => l_return_status );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After get_day_count_method ' || l_return_status);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'l_day_count_method = ' || l_day_count_method);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      --Bug 5884825 PAGARG start
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_ISG_DAY_CONVENTION',
                           p_token1       => 'PRODUCT_NAME',
                           p_token1_value => l_product_name);
      --Bug 5884825 PAGARG end
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF l_hdr_rec.rate_template_id IS NOT NULL
    THEN
      -- Fetch the day convention from the Stream Generation Template ...
      --  only if the user has picked the SRT otherwise while building the cash flows
      --  itself, we would have fetched the day convention from the SGT.
      get_qq_sgt_day_convention(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_qq_id             => p_qq_id,
        x_days_in_month     => l_sgt_days_in_month,
        x_days_in_year      => l_sgt_days_in_year);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After get_qq_sgt_day_convention ' || l_return_status );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'SGT Day convention: ' || l_days_in_month || ' / ' || l_days_in_year);
      -- Get the day convention ..
      get_day_count_method(
        p_days_in_month    => l_sgt_days_in_month,
        p_days_in_year     => l_sgt_days_in_year,
        x_day_count_method => l_sgt_day_count_method,
        x_return_status    => l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  '2/ After get_day_count_method ' || l_return_status);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'l_sgt_day_count_method = ' || l_sgt_day_count_method);
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        --Bug 5884825 PAGARG start
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_ISG_DAY_CONVENTION',
                             p_token1       => 'PRODUCT_NAME',
                             p_token1_value => l_product_name);
        --Bug 5884825 PAGARG end
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE
      -- The day convention returned by the get_qq_rc_cash_flows / get_qq_cash_flows
      --  will be from the SGT already, so just store them in the SGT day convention variables.
      l_sgt_days_in_month := l_days_in_month;
      l_sgt_days_in_year  := l_days_in_year;
      l_sgt_day_count_method := l_day_count_method;
    END IF;
    --------------------------------------------------------------------------------
    -- Solving for Missing Parameter
    --------------------------------------------------------------------------------
    -- We now have all the parameters in the tables to pass to the compute_iir api ..
    IF l_hdr_rec.pricing_method = 'SF' AND
       (l_eot_type_code = 'PERCENT' OR l_eot_type_code = 'RESIDUAL_PERCENT' )
    THEN
      l_hdr_rec.pricing_method := 'SFP';
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before compute_iir l_hdr_rec.pricing_method=' || l_hdr_rec.pricing_method || ' | l_eot_type_code = ' || l_eot_type_code);
    IF l_hdr_rec.pricing_method = 'SP' OR
       l_hdr_rec.pricing_method = 'SF' OR
       l_hdr_rec.pricing_method = 'SS' OR
       ( l_hdr_rec.pricing_method = 'TR' AND
         l_hdr_rec.target_rate_type = 'IIR') -- Target Rate and Interest Type is IIR
    THEN
      -- Compute iir !!
      compute_iir(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => l_hdr_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_pricing_method          => l_hdr_rec.pricing_method,
        p_initial_guess           => 0.1,
        px_pricing_parameter_rec  => l_pricing_parameters_tbl(1),
        px_iir                    => l_iir,
        x_payment                 => l_miss_payment);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After compute_iir ' || l_return_status );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF l_hdr_rec.pricing_method = 'SP' OR
         (l_hdr_rec.pricing_method = 'TR' AND
          l_hdr_rec.target_rate_type = 'IIR' )
      THEN
        IF  l_miss_payment < 0
        THEN
          OKL_API.SET_MESSAGE (
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_NEGATIVE_ADJ_AMT',
            p_token1       => 'TYPE',
            p_token1_value => 'Payment',
            p_token2       => 'AMOUNT',
            p_token2_value => round(l_miss_payment,2) );
          RAISE okl_api.g_exception_error;
        END IF;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  ' SOLVED PAYMENT AMOUNT : ' || l_miss_payment  );
        -- Populate back the missing payment amount in all the stream elements
        FOR t_index IN l_pricing_parameters_tbl(1).cash_inflows.FIRST ..
                       l_pricing_parameters_tbl(1).cash_inflows.LAST
        LOOP
          l_pricing_parameters_tbl(1).cash_inflows(t_index).cf_amount := l_miss_payment;
        END LOOP; -- Loop on l_pricing_parameters_tbl
      ELSIF l_hdr_rec.pricing_method = 'SF'
      THEN
        -- Solve for Financed Amount
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 ' SOLVED FOR FINANCED AMOUNT ' || l_pricing_parameters_tbl(1).financed_amount );
      ELSIF l_hdr_rec.pricing_method = 'SS'
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'SOLVED SUBSIDY AMOUNT ' || l_pricing_parameters_tbl(1).subsidy );
        IF  l_pricing_parameters_tbl(1).subsidy < 0
        THEN
          OKL_API.SET_MESSAGE (
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_NEGATIVE_ADJ_AMT',
            p_token1       => 'TYPE',
            p_token1_value => 'Subsidy',
            p_token2       => 'AMOUNT',
            p_token2_value => round(l_pricing_parameters_tbl(1).subsidy,2) );
          RAISE okl_api.g_exception_error;
        END IF;
      END IF; -- IF on pricing method
    ELSIF l_hdr_rec.pricing_method = 'SFP'
    THEN
      -- Before calling the compute_iir_sfp, the pricing param rec, should
      --  not be passed with any asset cost, and adjustments with either
      --  FIXED or PERCENTAGE OF ASSET COST !
      compute_iir_sfp(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => l_hdr_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_pricing_method          => l_hdr_rec.pricing_method,
        p_initial_guess           => 0.1,
        px_pricing_parameter_rec  => l_pricing_parameters_tbl(1),
        px_iir                    => l_iir,
        x_closing_balance         => l_closing_balance,
        x_residual_percent        => l_residual_percent,
        x_residual_int_factor     => l_residual_int_factor);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After compute_iir_sfp ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Closing Balance | Residual Percent | l_residual_int_factor ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        round(l_closing_balance, 4) || ' | ' || round( l_residual_percent, 4) || ' | ' || round(l_residual_int_factor,4) );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    IF l_hdr_rec.pricing_method = 'SF' OR
       l_hdr_rec.pricing_method = 'SFP'
    THEN
      --Need to manipulate the financial adjustments which are of type percentage ..
      -- Find the Financed Amount ( C-S-D-T, considering only D, T, S which are of type FIXED. )
      l_net_financed_amount := l_pricing_parameters_tbl(1).financed_amount;
      l_tot_item_cat_amount := l_pricing_parameters_tbl(1).financed_amount;
      -- Now sum the percentages of the D, T, S
      l_net_percent := 0;
      l_net_adj_amt := 0;
      IF l_fin_adj_rec.down_payment_basis <> 'FIXED'
      THEN
        l_net_percent := l_net_percent + nvl(l_fin_adj_rec.down_payment_value, 0);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     ' ** Down Payment %age ' || l_fin_adj_rec.down_payment_value );
      ELSE
        l_net_adj_amt := l_net_adj_amt + nvl(l_pricing_parameters_tbl(1).down_payment,0);
      END IF;
      IF l_fin_adj_rec.tradein_basis <> 'FIXED'
      THEN
        l_net_percent := l_net_percent + nvl(l_fin_adj_rec.tradein_value, 0);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   ' ** Tradein  %age ' || l_fin_adj_rec.tradein_value );
      ELSE
        l_net_adj_amt := l_net_adj_amt + nvl(l_pricing_parameters_tbl(1).trade_in,0);
      END IF;
      IF l_fin_adj_rec.subsidy_basis_tbl.COUNT > 0
      THEN
        FOR t IN l_fin_adj_rec.subsidy_basis_tbl.FIRST ..
                 l_fin_adj_rec.subsidy_basis_tbl.LAST
        LOOP
          IF l_fin_adj_rec.subsidy_basis_tbl(t) <> 'FIXED'
          THEN
            l_net_percent := l_net_percent + nvl(l_fin_adj_rec.subsidy_value_tbl(t), 0);
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       ' ** Subsidy('||t|| ')  %age ' || l_fin_adj_rec.tradein_value );
          END IF;
        END LOOP;
      END IF; -- Subsidies exists
      l_net_adj_amt := l_net_adj_amt + nvl(l_pricing_parameters_tbl(1).subsidy,0);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        ' Down Payment | Trade in | Subsidy ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        round(l_pricing_parameters_tbl(1).down_payment,4) || ' | ' ||
        round(l_pricing_parameters_tbl(1).trade_in,4) || ' | ' ||
        round(l_pricing_parameters_tbl(1).subsidy,4) );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        ' Financed Amount ' || round(l_net_financed_amount,4) || ' Total Percentage of Financial Adjustments ' || round(l_net_percent,4)
        || ' Total Adjustment Amount (FIXED)= ' || round( l_net_adj_amt, 4));
      IF l_hdr_rec.pricing_method = 'SFP'
      THEN
        l_pricing_parameters_tbl(1).financed_amount :=
         ( (l_closing_balance + l_net_adj_amt) /
           ( 1- (l_net_percent/100) - (l_residual_percent/l_residual_int_factor) ) );
      ELSIF l_hdr_rec.pricing_method = 'SF'
      THEN
        -- Find the Asset Cost C = F+[S++D+T]/(1-[S'+D'+T']/100)
        -- S,D,T are fixed financial adjustment amounts
        l_pricing_parameters_tbl(1).financed_amount := l_net_financed_amount / ( 1- l_net_percent / 100 );
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        ' !!!! Asset Cost should be  ' || l_pricing_parameters_tbl(1).financed_amount );
      IF l_net_percent > 0 AND
         l_net_percent <= 100
      THEN
        IF l_fin_adj_rec.down_payment_basis <> 'FIXED'
        THEN
          l_pricing_parameters_tbl(1).down_payment :=
            l_pricing_parameters_tbl(1).financed_amount * l_fin_adj_rec.down_payment_value/ 100;
        END IF;
        IF l_fin_adj_rec.tradein_basis <> 'FIXED'
        THEN
          l_pricing_parameters_tbl(1).trade_in := l_pricing_parameters_tbl(1).financed_amount
                                                  * l_fin_adj_rec.tradein_value / 100;
        END IF;
        IF l_fin_adj_rec.subsidy_basis_tbl.COUNT > 0
        THEN
          FOR t IN l_fin_adj_rec.subsidy_basis_tbl.FIRST ..
                   l_fin_adj_rec.subsidy_basis_tbl.LAST
          LOOP
            IF l_fin_adj_rec.subsidy_basis_tbl(t) <> 'FIXED'
            THEN
              l_pricing_parameters_tbl(1).subsidy := l_pricing_parameters_tbl(1).subsidy +
                  ( l_pricing_parameters_tbl(1).financed_amount * l_fin_adj_rec.subsidy_value_tbl(t));
            END IF;
          END LOOP;
        END IF; -- If subsidies exists
      END IF;
      IF l_hdr_rec.pricing_method = 'SFP'
      THEN
        -- Still the calculation need to be done ..
        -- After pricing the EOT has to be calculated interms of amounts
        --   for pricing to calculate the yields further.
        FOR t_in IN l_pricing_parameters_tbl(1).residual_inflows.FIRST ..
                    l_pricing_parameters_tbl(1).residual_inflows.LAST
        LOOP
          l_pricing_parameters_tbl(1).residual_inflows(t_in).cf_amount :=
          l_pricing_parameters_tbl(1).residual_inflows(t_in).cf_amount *
           l_pricing_parameters_tbl(1).financed_amount;
        END LOOP;
      END IF;
    END IF; -- IF pricing_method ='SF'/'SFP'
    -- If pricing method is RC, calculate the total Rent Payment amount, which
    --  needs to be passed in the get_fee_srvc_cash_flows
    -- Get the Total Rent Payment Amount
    -- For this loop through all the pricing params with line_type as FREE_FORM1
    --  and sumup the streams being passed there !
    l_tot_rent_payment := 0;
    FOR a IN l_pricing_parameters_tbl.FIRST .. l_pricing_parameters_tbl.LAST
    LOOP
      IF l_pricing_parameters_tbl(a).line_type = 'FREE_FORM1'
      THEN
        FOR b IN l_pricing_parameters_tbl(a).cash_inflows.FIRST ..
                 l_pricing_parameters_tbl(a).cash_inflows.LAST
        LOOP
          l_tot_rent_payment := l_tot_rent_payment + nvl(l_pricing_parameters_tbl(a).cash_inflows(b).cf_amount, 0);
        END LOOP;
      END IF;
    END LOOP;
    ------------------------------------
    -- Get the Fee or Service Parameters
    ------------------------------------
    get_fee_srvc_cash_flows(
      p_api_version        => p_api_version,
      p_init_msg_list      => p_init_msg_list,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_hdr_rec            => l_hdr_rec,
      p_tot_item_cat_cost  => l_tot_item_cat_amount,
      p_tot_rent_payment   => l_tot_rent_payment,
      x_fee_srv_tbl        => l_fee_srv_tbl);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After get_fee_srvc_cash_flows ' || l_return_status );
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now need to loop through the l_fee_srv_tbl, generate streams if needed
    --  and accumulate the streams in the l_pricing_parameters_tbl !!
    IF l_fee_srv_tbl.COUNT > 0
    THEN
      FOR t_index IN l_fee_srv_tbl.FIRST .. l_fee_srv_tbl.LAST
      LOOP
        -- Populate the line_type, payment_type and streams in the
        -- l_pricing_parameters_tbl
        l_pricing_parameters_tbl(pp_index).line_type := l_fee_srv_tbl(t_index).type;
        -- Populate either INCOME / EXPENSE as a value for the payment_type !
        IF l_fee_srv_tbl(t_index).type = G_QQ_FEE_EXPENSE
        THEN
          l_pricing_parameters_tbl(pp_index).payment_type := 'EXPENSE';
        ELSIF l_fee_srv_tbl(t_index).TYPE = G_QQ_FEE_PAYMENT
        THEN
          l_pricing_parameters_tbl(pp_index).payment_type := 'INCOME';
        END IF;
        -- Start date for the line will be the quote expected start date
        l_pricing_parameters_tbl(pp_index).line_start_date :=l_hdr_rec.expected_start_date;
        l_pricing_parameters_tbl(pp_index).financed_amount := 0;
        -- Generate the streams .. using the corresponding cash flows and levels
        l_strm_ele_tbl.DELETE;
        IF l_fee_srv_tbl(t_index).cash_flow_level_tbl IS NOT NULL AND
           l_fee_srv_tbl(t_index).cash_flow_level_tbl.COUNT > 0
        THEN
          -- Initialize the Strm Count to Zero
          gen_so_cf_strms(
            p_api_version            => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_cash_flow_rec          => l_fee_srv_tbl(t_index).cash_flow_rec,
            p_cf_details_tbl         => l_fee_srv_tbl(t_index).cash_flow_level_tbl,
            x_cash_inflow_strms_tbl  => l_strm_ele_tbl);
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        -- Get the line_end_date from the last stream element generated !
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After gen_so_cf_strms for fees ' || l_return_status );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Streams generated ' || l_strm_ele_tbl.COUNT );
        IF l_strm_ele_tbl IS NOT NULL AND
           l_strm_ele_tbl.COUNT > 0
        THEN
          IF l_strm_ele_tbl(l_strm_ele_tbl.LAST).is_arrears = 'N'
          THEN
            l_pricing_parameters_tbl(pp_index).line_end_date :=
               l_strm_ele_tbl(l_strm_ele_tbl.LAST).cf_period_start_end_date;
          ELSE
            l_pricing_parameters_tbl(pp_index).line_end_date :=
              l_strm_ele_tbl(l_strm_ele_tbl.LAST).cf_date;
          END IF;
        END IF;
        -- Assign the generated streams to the Pricing Parameters cash inflows table !
        l_pricing_parameters_tbl(pp_index).cash_inflows := l_strm_ele_tbl;
        -- Increment the pp_index
        pp_index := pp_index + 1;
      END LOOP; -- Loop on the l_fee_srv_tbl
    END IF; -- IF l_fee_srv_tbl.COUNT > 0
    -- Solve for the missing parameter using the IRR method if pricing method is
    -- Target Rate and Target Rate type is IRR
    IF ( l_hdr_rec.pricing_method = 'TR' AND
            l_hdr_rec.target_rate_type = 'PIRR' )
    THEN
      -- Check whether the interest picked is IIR or not??
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => l_hdr_rec.expected_start_date,
        p_day_count_method        => l_sgt_day_count_method,
        p_currency_code           => l_hdr_rec.currency_code,
        p_pricing_method          => l_hdr_rec.pricing_method,
        p_initial_guess           => 0.1,
        px_pricing_parameter_tbl  => l_pricing_parameters_tbl,
        px_irr                    => l_irr,
        x_payment                 => l_miss_payment);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After compute_irr ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'SOLVED FOR TARGET-RATE (PIRR) ' || l_miss_payment );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF  l_miss_payment < 0
      THEN
        OKL_API.SET_MESSAGE (
          p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKL_NEGATIVE_ADJ_AMT',
          p_token1       => 'TYPE',
          p_token1_value => 'Payment',
          p_token2       => 'AMOUNT',
          p_token2_value => round(l_miss_payment,2) );
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;  -- Pricing method IF
    -- In case of the Pricing Method is SP...
    -- populate back the missing amount into the Cash Inflow Levels and the Streams too..
    -- for further solving for Yields
    IF l_hdr_rec.pricing_method = 'SP' OR
       l_hdr_rec.pricing_method = 'TR'
    THEN
      FOR i in l_strm_ele_tbl.FIRST .. l_strm_ele_tbl.LAST
      LOOP
        l_strm_ele_tbl(i).cf_amount := l_miss_payment;
      END LOOP;
      -- Need to populate back the Cash flow details, which will be
      --  returned back to the wrapper API !!
      FOR i in l_cash_flow_det_tbl.FIRST .. l_cash_flow_det_tbl.LAST
      LOOP
        l_cash_flow_det_tbl(i).amount := l_miss_payment;
      END LOOP;
      -- Need to populate back the Cash inflows with the solved Amount for the FREE_FORM1 lines
      FOR i_index IN l_pricing_parameters_tbl.FIRST ..
                     l_pricing_parameters_tbl.LAST
      LOOP
        FOR j_index IN l_pricing_parameters_tbl(i_index).cash_inflows.FIRST ..
                       l_pricing_parameters_tbl(i_index).cash_inflows.LAST
        LOOP
          IF l_pricing_parameters_tbl(i_index).line_type = 'FREE_FORM1'
          THEN
            l_pricing_parameters_tbl(i_index).cash_inflows(j_index).cf_amount := l_miss_payment;
          END IF;
        END LOOP;
      END LOOP;
      -- Commenting the below code becasue, when QQ is being priced for TR[IRR],
      -- User will give the Fee Expense/Fee Payment amount, Pricing should not actually change that amounts
/*
      -- Need to populate back the Cash flows into all the streams table back ..
      IF l_hdr_rec.target_rate_type = 'PIRR' AND
         l_fee_srv_tbl.COUNT > 0
      THEN
        FOR i_index IN l_fee_srv_tbl.FIRST .. l_fee_srv_tbl.LAST
        LOOP
          FOR j_index IN l_fee_srv_tbl(i_index).cash_flow_level_tbl.FIRST ..
                         l_fee_srv_tbl(i_index).cash_flow_level_tbl.LAST
          LOOP
            l_fee_srv_tbl(i_index).cash_flow_level_tbl(j_index).amount := l_miss_payment;
          END LOOP;
        END LOOP;
      END IF;
*/
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               '--------------------------------------------------------------------------');
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               '    -- Subsidized Yields calculation');
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               '--------------------------------------------------------------------------');
    -- Get the Total Item Categories cost
    IF l_hdr_rec.pricing_method = 'SF' OR
       l_hdr_rec.pricing_method = 'SFP'
    THEN
      -- The total financed amount would have been solved the compute_iir api
      --  and has been returned in l_pricing_parameters_tbl(1).financed_amount
      l_tot_item_cat_amount := l_pricing_parameters_tbl(1).financed_amount;
    END IF;
    -- When the pricing method is 'RC', we would have directly come to here
    --  as Rate Card method pricing is very similiar to the SY pricing method.
    --  'Coz we have already calculated the payment amounts based on the
    --  Lease Rate Factor levels
    IF l_hdr_rec.pricing_method = 'TR' AND
         l_hdr_rec.target_rate_type = 'IIR'
    THEN
      l_iir := l_hdr_rec.target_rate /100;
    ELSE
      -- Calculate IIR
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Subsidized IIR Calculation ------------------' );
      -- We will be calling the compute_irr with just the item cat. information
      -- and its residual streams .. ignoring fees and fee payments
      IF l_hdr_rec.pricing_method = 'RC'
      THEN
        -- We need to pass the pricing params corresponding to only the
        -- item categories leaving the Fee and else !
        FOR t IN 1 .. l_tmp_pp_index
        LOOP
          l_tmp_prc_params_tbl(t) := l_pricing_parameters_tbl(t);
        END LOOP;
      ELSE
        l_tmp_prc_params_tbl(1) := l_pricing_parameters_tbl(1);
      END IF;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => l_hdr_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_hdr_rec.currency_code,
        p_pricing_method          => 'SY',
        p_initial_guess           => 0.1,
        px_pricing_parameter_tbl  => l_tmp_prc_params_tbl,
        px_irr                    => l_iir,
        x_payment                 => l_miss_payment);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '1/ After compute_iir ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'SOLVED FOR IIR ' || l_iir );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Store back the pricing params record in l_pricing_parameters_tbl
      IF l_hdr_rec.pricing_method = 'RC'
      THEN
        FOR t IN 1 .. l_tmp_pp_index
        LOOP
          l_pricing_parameters_tbl(t) := l_tmp_prc_params_tbl(t);
        END LOOP;
      ELSE
        l_pricing_parameters_tbl(1) := l_tmp_prc_params_tbl(1);
      END IF;
    END IF; -- IF l_hdr_rec.pricing_mthod = 'TR' and l_hdr_rec.target_rate_type = 'IIR'
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Subsidized IRR Calculation ------------------' );
    IF l_hdr_rec.pricing_method = 'TR' AND
         l_hdr_rec.target_rate_type = 'PIRR'
    THEN
      l_irr := l_hdr_rec.target_rate / 100;
    ELSE
      -- Calculate the IRR !
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => l_hdr_rec.expected_start_date,
        p_day_count_method        => l_sgt_day_count_method,
        p_currency_code           => l_hdr_rec.currency_code,
        p_pricing_method          => 'SY',
        p_initial_guess           => l_iir,
        px_pricing_parameter_tbl  => l_pricing_parameters_tbl,
        px_irr                    => l_irr,
        x_payment                 => l_miss_payment);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'After compute_irr ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'px_irr ' || l_irr );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- IF l_hdr_rec.pricing_method = 'TR' AND l_hdr_rec.target_rate_type = 'PIRR'
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Subsidized Booking Yield Calculation ' );
    IF l_hdr_rec.pricing_method = 'RC'
    THEN
      -- Store the IIR @ QQ level as the Booking Yield
      l_bk_yield := l_iir;
    ELSE
      -- Compute the Booking Yield
      l_bk_yield := l_iir;
      /*
      compute_bk_yield(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => l_hdr_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_pricing_method          => 'SY',
        p_initial_guess           => l_iir,
        p_term                    => l_hdr_rec.term,
        px_pricing_parameter_rec  => l_pricing_parameters_tbl(1),
        x_bk_yield                => l_bk_yield,
        x_termination_tbl         => x_termination_tbl,
        x_pre_tax_inc_tbl         => x_pre_tax_inc_tbl);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'After compute_bk_yield ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'x_bk_yield ' || l_bk_yield );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      */
    END IF;
    -- Need to store the Subsidized Yields into  l_subsized_yileds_rec
    -- ISG doesnot calculate yet the after_tax_irr
    l_subsidized_yields_rec.pre_tax_irr := l_irr;
    l_subsidized_yields_rec.iir := l_iir;
    l_subsidized_yields_rec.bk_yield := l_bk_yield;
    -- Storing the l_pricing_parameters_tbl into l_pricing_parameters_tbl_cp
    --   which will be useful during returning back of the pricing params ..
    l_pricing_parameters_tbl_cp := l_pricing_parameters_tbl;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Computed Subsidized Yields successfully ' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Pre_Tax_IRR | IIR | Boooking Yield ' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                round( l_subsidized_yields_rec.pre_tax_irr , 4 ) || ' | '
                || round( l_subsidized_yields_rec.iir , 4 ) || ' | '
                ||round( l_subsidized_yields_rec.bk_yield, 4 ) );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              '-------------------------------------------------------------');
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               '    -- Calculation of the Yields ');
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               '-------------------------------------------------------------');
    -- Dont consider any subsidy amount here !!
    FOR t_index IN l_pricing_parameters_tbl.FIRST .. l_pricing_parameters_tbl.LAST
    LOOP
      -- Remove the subsidy amount, normal yeilds calculation shouldnot consider
      --  subsidy amount as an inflow
      l_pricing_parameters_tbl(t_index).subsidy := 0;
    END LOOP;
    -- Calculate the IIR
    -- API being called is compute_irr but without passing any of the
    --   fees and fee payments info. from the QQ
    l_tmp_prc_params_tbl.DELETE;
    IF l_hdr_rec.pricing_method = 'RC'
    THEN
      -- We need to pass the pricing params corresponding to only the
      -- item categories leaving the Fee and else !
      FOR t IN 1 .. l_tmp_pp_index
      LOOP
        l_tmp_prc_params_tbl(t) := l_pricing_parameters_tbl(t);
      END LOOP;
    ELSE
      l_tmp_prc_params_tbl(1) := l_pricing_parameters_tbl(1);
    END IF;
    compute_irr(
      p_api_version             => p_api_version,
      p_init_msg_list           => p_init_msg_list,
      x_return_status           => l_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      p_start_date              => l_hdr_rec.expected_start_date,
      p_day_count_method        => l_day_count_method,
      p_currency_code           => l_hdr_rec.currency_code,
      p_pricing_method          => 'SY',
      p_initial_guess           => l_subsidized_yields_rec.iir,
      px_pricing_parameter_tbl  => l_tmp_prc_params_tbl,
      px_irr                    => l_iir,
      x_payment                 => l_miss_payment);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Store back the pricing params ..
    IF l_hdr_rec.pricing_method = 'RC'
    THEN
      FOR t IN 1 .. l_tmp_pp_index
      LOOP
        l_pricing_parameters_tbl(t) := l_tmp_prc_params_tbl(t);
      END LOOP;
    ELSE
      l_pricing_parameters_tbl(1) := l_tmp_prc_params_tbl(1);
    END IF;
    -- Calculate the IRR !
    compute_irr(
      p_api_version             => p_api_version,
      p_init_msg_list           => p_init_msg_list,
      x_return_status           => l_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      p_start_date              => l_hdr_rec.expected_start_date,
      p_day_count_method        => l_sgt_day_count_method,
      p_currency_code           => l_hdr_rec.currency_code,
      p_pricing_method          => 'SY',
      p_initial_guess           => l_subsidized_yields_rec.pre_tax_irr,
      px_pricing_parameter_tbl  => l_pricing_parameters_tbl,
      px_irr                    => l_irr,
      x_payment                 => l_miss_payment);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'After compute_irr ' || l_return_status );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'px_irr ' || l_irr );
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF l_hdr_rec.pricing_method = 'RC'
    THEN
      -- Store the IIR as the Booking Yield @ the QQ level
      l_bk_yield := l_iir;
    ELSE
      -- Compute the Booking Yield
      l_bk_yield := l_iir;
      /*
      compute_bk_yield(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => l_hdr_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.bk_yield,
        p_term                    => l_hdr_rec.term,
        px_pricing_parameter_rec  => l_pricing_parameters_tbl(1),
        x_bk_yield                => l_bk_yield,
        x_termination_tbl         => x_termination_tbl,
        x_pre_tax_inc_tbl         => x_pre_tax_inc_tbl);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S', 'After compute_bk_yield ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S', 'x_bk_yield ' || l_bk_yield );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      */
    END IF;
    -- ISG doesnot calculate the after_tax_irr yet
    l_yields_rec.pre_tax_irr := l_irr;
    l_yields_rec.iir := l_iir;
    l_yields_rec.bk_yield := l_bk_yield;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               '---------------------------------------------------' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Yields  ' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               '---------------------------------------------------' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Pre_Tax_IRR | IIR | Boooking Yield ' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               round( l_yields_rec.pre_tax_irr , 4 ) || ' | ' || round( l_yields_rec.iir , 4 ) || ' | '
               ||round( l_yields_rec.bk_yield, 4 ) );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               '---------------------------------------------------' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Subsidized Yields ' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               '---------------------------------------------------' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Pre_Tax_IRR | IIR | Boooking Yield ' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               round( l_subsidized_yields_rec.pre_tax_irr , 4 ) || ' | '
               || round( l_subsidized_yields_rec.iir , 4 ) || ' | '
               ||round( l_subsidized_yields_rec.bk_yield, 4 ) );
    -- Need to calculate a quote API to update the Yields and Subsidized yields !
    -- Call the API which changes the status of the QQ !
    -- Actual logic Ends here
    x_yileds_rec            := l_yields_rec;
    x_subsidized_yileds_rec := l_subsidized_yields_rec;
    -- Need to populate back the pricing results using the x_pricing_results_tbl ....
    i := 1;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               ' ************** PRICING ENGINE RETURN VALUES: ************** ' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Line Type | Asset Cost | Down Payment | Trade In | Subsidy ' );
    IF l_hdr_rec.pricing_method = 'RC'
    THEN
      -- Loop through the l_item_cat_cf_tbl and then return the pricing results
      FOR t in l_item_cat_cf_tbl.FIRST .. l_item_cat_cf_tbl.LAST
      LOOP
        x_pricing_results_tbl(i).line_type           := 'FREE_FORM1';
        x_pricing_results_tbl(i).line_id             := l_item_cat_cf_tbl(t).line_id;
        x_pricing_results_tbl(i).item_category_id    := l_item_cat_cf_tbl(t).item_category_id;
        x_pricing_results_tbl(i).financed_amount     := l_item_cat_cf_tbl(t).financed_amount;
        x_pricing_results_tbl(i).trade_in            := l_item_cat_cf_tbl(t).trade_in;
        x_pricing_results_tbl(i).down_payment        := l_item_cat_cf_tbl(t).down_payment;
        x_pricing_results_tbl(i).subsidy             := l_item_cat_cf_tbl(t).subsidy;
        x_pricing_results_tbl(i).cash_flow_rec       := l_item_cat_cf_tbl(t).cash_flow_rec;
        x_pricing_results_tbl(i).cash_flow_level_tbl := l_item_cat_cf_tbl(t).cash_flow_level_tbl;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    x_pricing_results_tbl(1).line_type || ' | ' ||
                    round(x_pricing_results_tbl(i).financed_amount, 4) || ' | ' ||
                    round(x_pricing_results_tbl(i).down_payment, 4) || ' | ' ||
                    round(x_pricing_results_tbl(i).trade_in, 4) || ' | ' ||
                    round(x_pricing_results_tbl(i).subsidy, 4) ) ;
        IF x_pricing_results_tbl(i).cash_flow_level_tbl.COUNT > 0 AND
           x_pricing_results_tbl(i).cash_flow_level_tbl IS NOT NULL
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            '   Cash Flow Level details ' );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            '   Rate | Start Date | Frequency | Arrears Y/N | | Stub Days | Stub Amount | Periods | Periodic Amount ' );
          FOR t_in IN x_pricing_results_tbl(i).cash_flow_level_tbl.FIRST ..
                x_pricing_results_tbl(i).cash_flow_level_tbl.LAST
          LOOP
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              '   ' || x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).rate || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).START_DATE || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).fqy_code || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_rec.due_arrears_yn || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).stub_days || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).stub_amount || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).number_of_periods || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).amount );
          END LOOP;
        END IF;
        -- Increment i
        i := i + 1;
      END LOOP;
    ELSE
      -- The first pricing param will be the FREE_FORM1 line only ..
      --  in case of the pricing method is not RC.
      x_pricing_results_tbl(i).line_type           := l_pricing_parameters_tbl_cp(1).line_type;
      x_pricing_results_tbl(i).financed_amount     := l_pricing_parameters_tbl_cp(1).financed_amount;
      x_pricing_results_tbl(i).trade_in            := l_pricing_parameters_tbl_cp(1).trade_in;
      x_pricing_results_tbl(i).down_payment        := l_pricing_parameters_tbl_cp(1).down_payment;
      x_pricing_results_tbl(i).subsidy             := l_pricing_parameters_tbl_cp(1).subsidy;
      x_pricing_results_tbl(i).cash_flow_rec       := l_cash_flow_rec;
      x_pricing_results_tbl(i).cash_flow_level_tbl := l_cash_flow_det_tbl;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    x_pricing_results_tbl(1).line_type || ' | ' ||
                    round(x_pricing_results_tbl(1).financed_amount, 4) || ' | ' ||
                    round(x_pricing_results_tbl(1).down_payment, 4) || ' | ' ||
                    round(x_pricing_results_tbl(1).trade_in, 4) || ' | ' ||
                    round(x_pricing_results_tbl(1).subsidy, 4) ) ;
      IF x_pricing_results_tbl(i).cash_flow_level_tbl.COUNT > 0 AND
         x_pricing_results_tbl(i).cash_flow_level_tbl IS NOT NULL
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          '   Cash Flow Level details ' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          '   Rate | Start Date | Frequency | Arrears Y/N | | Stub Days | Stub Amount | Periods | Periodic Amount ' );
        FOR t_in IN x_pricing_results_tbl(i).cash_flow_level_tbl.FIRST ..
              x_pricing_results_tbl(i).cash_flow_level_tbl.LAST
        LOOP
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            '   ' || x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).rate || ' | ' ||
            x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).START_DATE || ' | ' ||
            x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).fqy_code || ' | ' ||
            x_pricing_results_tbl(i).cash_flow_rec.due_arrears_yn || ' | ' ||
            x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).stub_days || ' | ' ||
            x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).stub_amount || ' | ' ||
            x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).number_of_periods || ' | ' ||
            x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).amount );
        END LOOP;
      END IF;
      --Increment i ..
      i := i + 1;
    END IF;
    -- Need to return back the expense and fee payment cash flows !
    IF l_fee_srv_tbl.COUNT > 0
    THEN
      FOR t IN l_fee_srv_tbl.FIRST .. l_fee_srv_tbl.LAST
      LOOP
        x_pricing_results_tbl(i).line_type           := l_fee_srv_tbl(t).type;
        x_pricing_results_tbl(i).financed_amount     := NULL;
        x_pricing_results_tbl(i).trade_in            := NULL;
        x_pricing_results_tbl(i).down_payment        := NULL;
        x_pricing_results_tbl(i).subsidy             := NULL;
        x_pricing_results_tbl(i).cash_flow_rec       := l_fee_srv_tbl(t).cash_flow_rec;
        x_pricing_results_tbl(i).cash_flow_level_tbl := l_fee_srv_tbl(t).cash_flow_level_tbl;
        IF x_pricing_results_tbl(i).cash_flow_level_tbl.COUNT > 0 AND
           x_pricing_results_tbl(i).cash_flow_level_tbl IS NOT NULL
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            '   Cash Flow Level details for LINE_TYPE ' || x_pricing_results_tbl(i).line_type );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            '   Rate | Start Date | Frequency | Arrears Y/N | | Stub Days | Stub Amount | Periods | Periodic Amount ' );
          FOR t_in IN x_pricing_results_tbl(i).cash_flow_level_tbl.FIRST ..
                x_pricing_results_tbl(i).cash_flow_level_tbl.LAST
          LOOP
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              '   ' || x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).rate || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).START_DATE || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).fqy_code || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_rec.due_arrears_yn || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).stub_days || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).stub_amount || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).number_of_periods || ' | ' ||
              x_pricing_results_tbl(i).cash_flow_level_tbl(t_in).amount );
          END LOOP;
        END IF;
        -- Increment i !
        i := i + 1;
      END LOOP;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_name) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END price_quick_quote;

  PROCEDURE distribute_fin_amount_lq(
             p_api_version          IN            NUMBER,
             p_init_msg_list        IN            VARCHAR2,
             x_return_status           OUT NOCOPY VARCHAR2,
             x_msg_count               OUT NOCOPY NUMBER,
             x_msg_data                OUT NOCOPY VARCHAR2,
             p_lq_id                   IN         NUMBER,
             p_tot_fin_amount          IN         NUMBER)
  IS
    -- Local Variables
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'distribute_fin_amount_lq';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE :=
                      'LEASE.ACCOUNTING.PRICING.OKL_PRICING_UTILS_PVT.distribute_fin_amount_lq';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Cursor to fetch the Lease Quote Header details
    CURSOR quote_csr(qteid  NUMBER)
    IS
      SELECT qte.pricing_method pricing_method,
             qte.rate_template_id rate_template_id,
             qte.structured_pricing structured_pricing,
             qte.line_level_pricing line_level_pricing,
             qte.target_arrears_yn target_arrears
        FROM OKL_LEASE_QUOTES_B qte
       WHERE qte.id = qteid;
    quote_rec      quote_csr%ROWTYPE;
    -- Cursor to fetch the Assets Details for a Lease Quote
    --  and SRT attached to the Asset ( if any .. )
    CURSOR assets_csr(qteid     NUMBER)
    IS
      SELECT ast.id                 ast_id,
             ast.asset_number       asset_number,
             ast.oec                oec,
             ast.oec_percentage     oec_percentage,
             ast.structured_pricing structured_pricing,
             ast.rate_template_id   rate_template_id,
             ast.target_arrears     target_arrears
        FROM okl_assets_b         ast,
             okl_lease_quotes_b   qte
       WHERE ast.parent_object_code = 'LEASEQUOTE' AND
             ast.parent_object_id = qte.id AND
             qte.id = qteid;
    CURSOR c_asset_comp_csr( p_asset_id NUMBER) IS
      SELECT
         id
        ,primary_component
        ,unit_cost
        ,number_of_units
      FROM okl_asset_components_v
      WHERE asset_id = p_asset_id
       AND  primary_component = 'YES';

    -- Local Variables Declaration !
    l_overridden        BOOLEAN;
    tot_oec_percentage  NUMBER;
    i                   NUMBER;
    lq_level_fin_amt    NUMBER;
    l_asset_tbl         OKL_LEASE_QUOTE_ASSET_PVT.asset_tbl_type;
    l_component_tbl     OKL_LEASE_QUOTE_ASSET_PVT.asset_component_tbl_type;
    l_cf_hdr_rec        OKL_LEASE_QUOTE_ASSET_PVT.cashflow_hdr_rec_type;
    l_cf_level_tbl      OKL_LEASE_QUOTE_ASSET_PVT.cashflow_level_tbl_type;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Loop thu all the assets
    --   store the non-overriding assets id into assets_tbl
    --   sum the oec_percentage
    --end loop
    OPEN quote_csr( qteId => p_lq_id );
    FETCH quote_csr INTO quote_rec;
    CLOSE quote_csr;

    tot_oec_percentage := 0;
    i := 1;
    FOR asset_rec IN assets_csr(qteid => p_lq_id )
    LOOP
      l_overridden := is_asset_overriding(
                        p_qte_id                => p_lq_id,
                        p_ast_id                => asset_rec.ast_id,
                        p_lq_line_level_pricing => quote_rec.line_level_pricing,
                        p_lq_srt_id             => quote_rec.rate_template_id,
                        p_ast_srt_id            => asset_rec.rate_template_id,
                        p_lq_struct_pricing     => quote_rec.structured_pricing,
                        p_ast_struct_pricing    => asset_rec.structured_pricing,
                        p_lq_arrears_yn         => quote_rec.target_arrears,
                        p_ast_arrears_yn        => asset_rec.target_arrears,
                        x_return_status         => l_return_status);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'After is_asset_overriding assets_rec.id =' || asset_rec.ast_id);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               '  l_return_status =' || l_return_status );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF l_overridden = FALSE
      THEN
        -- Asset is following the Payment Structure defined at Lease quote ..
        tot_oec_percentage := tot_oec_percentage + nvl(asset_rec.oec_percentage,0);
        l_asset_tbl(i).id := asset_rec.ast_id;
        l_asset_tbl(i).oec_percentage := asset_rec.oec_percentage;
        -- Increment the index
        i := i + 1;
      END IF;
    END LOOP;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Sum(OEC %age) for non-overiding assets = ' || ROUND( tot_oec_percentage, 4));
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'assets_tbl = ' || l_asset_tbl.COUNT );
    IF l_asset_tbl.COUNT > 0
    THEN
      lq_level_fin_amt := p_tot_fin_amount * 100 / ( tot_oec_percentage );
      -- Loop through the assets_tbl and update the OEC of each asset !
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Districution of Assets OEC ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Asset ID  | Financed Amount ');
      FOR t IN l_asset_tbl.FIRST .. l_asset_tbl.LAST
      LOOP
        l_asset_tbl(t).oec := lq_level_fin_amt * l_asset_tbl(t).oec_percentage / 100;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                l_asset_tbl(t).id || ' | ' || l_asset_tbl(t).oec );
        l_component_tbl.DELETE;
        FOR t_rec IN c_asset_comp_csr( p_asset_id => l_asset_tbl(t).id )
        LOOP
          l_component_tbl(1).id := t_rec.id;
          l_component_tbl(1).unit_cost := l_asset_tbl(t).oec / t_rec.number_of_units;
          l_component_tbl(1).record_mode := 'update';
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Updated l_component_tbl(1).unit_cost =  ' || l_component_tbl(1).unit_cost );
        END LOOP;
        -- Call the update api to store back the calculated OEC of the Asset!
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Before OKL_LEASE_QUOTE_ASSET_PVT.update_asset ');
        -- Instead we need to use the OKL_LEASE_QUOTE_ASSET_PVT.update_asset
        OKL_LEASE_QUOTE_ASSET_PVT.update_asset (
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_transaction_control => 'T',
          p_asset_rec           => l_asset_tbl(t),
          p_component_tbl       => l_component_tbl,
          p_cf_hdr_rec          => l_cf_hdr_rec,
          p_cf_level_tbl        => l_cf_level_tbl,
          x_return_status       => l_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'After OKL_LEASE_QUOTE_ASSET_PVT.update_asset ' || l_return_status );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
    END IF;
    -- Logic ends here !
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END distribute_fin_amount_lq;

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : price_standard_quote_asset
  -- Description          : This API would have been called once for each asset
  --                        which has overridden the Quote Level Pricing Structure !
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 22-May-2005 - created
  -- 1/ Added params p_price_at_lq_level
  --     When passed TRUE for p_price_at_lq_level, this api, will
  --     price the Asset, with the payment strucutre defined at the LQ level.
  --     Such senario, will be happening when the pricing_method is SP, and
  --      after we calculated the IIR at quote level, again, we will want to
  --      calculate the payments at each individual asset levels.
  --      p_target_rate will be passed as the IIR at the LQ Level.
  --     When p_price_at_lq_level is FALSE, then the Asset will be assumed
  --     to be overriding the payment structure defined at the LQ level.
  --     Hence, the Asset Level Cash flow Details will be fetched/defined ( incase of SRT )
  --      and the asset will be priced based on such information.
  -- 2/ Added, x_pricing_parameter_rec as an output parameter, because
  --   the price_standard_quote api can use the already built streams for this asset
  --   directly instead of it generating them again.
  -- 3/ Bug 7445154: Param p_line_type has been added.
  --    Pass FREE_FORM1 in case of Line Type = Asset
  --    If Line is a Fee, expected values are FINANCED/ROLLOVER
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE price_standard_quote_asset(
              x_return_status             OUT NOCOPY  VARCHAR2,
              x_msg_count                 OUT NOCOPY  NUMBER,
              x_msg_data                  OUT NOCOPY  VARCHAR2,
              p_api_version            IN             NUMBER,
              p_init_msg_list          IN             VARCHAR2,
              p_qte_id                 IN             NUMBER,
              p_ast_id                 IN             NUMBER, -- could be fee id.
              p_price_at_lq_level      IN             BOOLEAN,
              p_target_rate            IN             NUMBER,
              p_line_type              IN             VARCHAR2,
              x_pricing_parameter_rec  IN  OUT NOCOPY pricing_parameter_rec_type)
  IS
    l_api_version        CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name           CONSTANT VARCHAR2(30) DEFAULT 'price_standard_quote_asset';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);

    l_debug_enabled             VARCHAR2(10);
    is_debug_procedure_on       BOOLEAN;
    is_debug_statement_on       BOOLEAN;

    CURSOR subsidy_adj_csr( subId NUMBER)
    IS
       SELECT amount
         FROM okl_subsidies_b
        WHERE id = subId;

    subsidy_adj_rec subsidy_adj_csr%ROWTYPE;

    -- Cursor to fetch the Lease Quote Header details
    CURSOR quote_csr(qteid  NUMBER)
    IS
      SELECT qte.pricing_method pricing_method,
             qte.rate_template_id rate_template_id,
             qte.expected_start_date expected_start_date,
             qte.expected_delivery_date expected_delivery_date,
             qte.term term,
             qte.lease_rate_factor,
             qte.structured_pricing structured_pricing,
             qte.line_level_pricing line_level_pricing,
             qte.rate_card_id,
             qte.id,
             qte.parent_object_code,
             qte.target_frequency target_frequency,
             qte.target_arrears_yn target_arrears,
             qte.product_id,
             qte.sub_iir  -- Yield used while calculating the payments @ Asset Level
        FROM OKL_LEASE_QUOTES_B qte
       WHERE qte.id = qteid;
    quote_rec                    quote_csr%ROWTYPE;

    --Bug 5884825 PAGARG start
    --Cursor to fetch product name
    CURSOR product_name_csr(qteid  NUMBER)
    IS
      SELECT PDT.NAME PRODUCTNAME
      FROM OKL_LEASE_QUOTES_B QTE
         , OKL_PRODUCTS PDT
      WHERE QTE.PRODUCT_ID = PDT.ID
        AND QTE.ID = QTEID;
    --Bug 5884825 PAGARG end

    -- Local Variables Declaration
    l_product_name         okl_products.NAME%TYPE;--Bug 5884825 PAGARG
    l_lrs_details          lrs_details_rec_type;
    l_lrs_factor           lrs_factor_rec_type;
    l_lrs_levels           lrs_levels_tbl_type;
    l_ac_rec_type          OKL_EC_EVALUATE_PVT.okl_ac_rec_type;
    l_adj_factor           NUMBER;
    l_months_per_period    NUMBER;
    l_months_after         NUMBER;
    cf_index               NUMBER; -- Using as an index for Cash flow levels
    --Bug 5121548 dpsingh start
    --Cursor to fetch the Fees name for a Lease Quote
    CURSOR fees_csr(qteid         NUMBER,
                    fee_id    NUMBER)
    IS
    SELECT stytl.name
    FROM  okl_fees_b fee,
          okl_strm_type_tl stytl
    WHERE fee.parent_object_code = 'LEASEQUOTE'
    AND  fee.parent_object_id = qteid
    AND  fee.id = fee_id
    AND  fee.STREAM_TYPE_ID = stytl.id
    AND stytl.LANGUAGE = USERENV('LANG');
    --Bug 5121548 dpsingh end

    -- Cursor to fetch the Assets Details for a Lease Quote
    --  and SRT attached to the Asset ( if any .. )
    CURSOR assets_csr(qteid         NUMBER,
                      ast_fee_id    NUMBER)
    IS
      SELECT ast.asset_number,
             ast.id ast_id,
             TO_NUMBER(NULL) fee_id,
             ast.rate_card_id,
             ast.rate_template_id rate_template_id,
             ast.structured_pricing,
             'FREE_FORM1' fee_type,
             TO_NUMBER(NULL) fee_amount,
             ast.lease_rate_factor lease_rate_factor,
             ast.asset_number name,
             ast.target_frequency target_frequency,
             ast.target_arrears target_arrears
        FROM okl_assets_b ast,
             okl_lease_quotes_b qte
       WHERE ast.parent_object_code = 'LEASEQUOTE'
         AND ast.parent_object_id = qte.id
         AND qte.id = qteid
         AND ast.id = ast_fee_id
         AND p_line_type = 'FREE_FORM1'
     UNION
       SELECT NULL asset_number,
              TO_NUMBER(NULL) ast_id,
              fee.id fee_id,
              fee.rate_card_id,
              fee.rate_template_id,
              fee.structured_pricing,
              fee.fee_type,
              fee.fee_amount,
              fee.lease_rate_factor lease_rate_factor,
              fee.fee_type || ' FEE' name,
              fee.target_frequency target_frequency,
              fee.target_arrears target_arrears
        FROM  okl_fees_b fee,
              okl_lease_quotes_b qte
        WHERE fee.parent_object_code = 'LEASEQUOTE'
         AND  fee.parent_object_id = qte.id
         AND  qte.id = qteid
         AND  fee.id = ast_fee_id
         AND  p_line_type IN ( 'FINANCED', 'ROLLOVER' );
    assets_rec                   assets_csr%ROWTYPE;
    -- Cursor to fetch the Asset Level Details
    CURSOR asset_adj_csr(qteid                          NUMBER,
                         astid                          NUMBER)
    IS
      SELECT ast.asset_number,
             ast.install_site_id,
             ast.rate_card_id,
             ast.rate_template_id,
             ast.oec,
             nvl(nvl(ast.end_of_term_value, ast.end_of_term_value_default),0) end_of_term_value,
             ast.oec_percentage,
             cmp.unit_cost,
             cmp.number_of_units,
             cmp.primary_component
        FROM okl_assets_b ast,
             okl_lease_quotes_b qte,
             okl_asset_components_b cmp
       WHERE ast.parent_object_code = 'LEASEQUOTE' AND
             ast.parent_object_id = qte.id AND
             qte.id = qteid AND
             ast.id = astid AND
             cmp.primary_component = 'YES' AND
             cmp.asset_id = ast.id;
    -- Cursor to fetch the Asset Level Details
    CURSOR asset_cost_adj_csr(qteid        NUMBER,
                              astid        NUMBER)
    IS
      SELECT adj.adjustment_source_type,
             adj.adjustment_source_id,
             adj.basis,
             -- Start : DJANASWA : Bug# 6347118
             nvl(adj.value,adj.default_subsidy_amount) value
             -- End : DJANASWA : Bug# 6347118
        FROM okl_assets_b ast,
             okl_lease_quotes_b qte,
             okl_cost_adjustments_b adj
       WHERE ast.parent_object_code = 'LEASEQUOTE' AND
             ast.parent_object_id = qte.id AND
             qte.id = qteid AND
             ast.id = astid AND
             adj.parent_object_id = ast.id;
    -- Cursor to fetch the Customer Details
    CURSOR get_cust_details_csr( p_lq_id  NUMBER )
    IS
      SELECT  lopp.id                 parent_id
             ,lopp.prospect_id        prospect_id
             ,lopp.cust_acct_id       cust_acct_id
             ,lopp.sales_territory_id sales_territory_id
             ,lopp.currency_code      currency_code
      FROM   okl_lease_quotes_b  lq,
             okl_lease_opportunities_b lopp
      WHERE  parent_object_code = 'LEASEOPP'
       AND   parent_object_id = lopp.id
       AND   lq.id = p_lq_id;
    --Cursor to fetch the Parent Object Details
    CURSOR get_cust_details_csr_lapp( p_lq_id  NUMBER )
    IS
      SELECT  lapp.id                 parent_id
             ,lapp.prospect_id        prospect_id
             ,lapp.cust_acct_id       cust_acct_id
             ,lapp.sales_territory_id sales_territory_id
             ,lapp.currency_code      currency_code
      FROM   okl_lease_quotes_b  lq,
             okl_lease_applications_b lapp
      WHERE  parent_object_code = 'LEASEAPP'
       AND   parent_object_id = lapp.id
       AND   lq.id = p_lq_id;
    -- Cursor to fetch the Asset components details
    CURSOR c_asset_comp_csr( p_asset_id NUMBER) IS
      SELECT
         id
        ,primary_component
        ,unit_cost
        ,number_of_units
      FROM okl_asset_components_v
      WHERE asset_id = p_asset_id
       AND  primary_component = 'YES';

    CURSOR check_cfo_exists_csr(
      p_oty_code     IN VARCHAR2,
      p_source_table IN VARCHAR2,
      p_source_id    IN VARCHAR2 )
    IS
      SELECT 'YES' cfo_exists,
             cfo.id cfo_id,
             caf.id caf_id,
             caf.sty_id sty_id
       FROM  OKL_CASH_FLOW_OBJECTS cfo,
             OKL_CASH_FLOWS caf
      WHERE  OTY_CODE     = p_oty_code
       AND   SOURCE_TABLE = p_source_table
       AND   SOURCE_ID    = p_source_id
       AND   caf.cfo_id = cfo.id;
    check_cfo_exists_rec         check_cfo_exists_csr%ROWTYPE;
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

    -- Cursor to fetch the Stream Type for FINANCED/ROLLOVER Fee Payment in case of TR pricing method
    CURSOR c_fee_pmnt_strm_type_csr (
             pdtId        NUMBER,
             expStartDate DATE,
             strm_purpose VARCHAR)
    IS
     SELECT STRM.STY_ID PAYMENT_TYPE_ID,
             STRM.STY_NAME PAYMENT_TYPE,
             STRM.START_DATE,
             STRM.END_DATE,
             STRM.STY_PURPOSE
      FROM OKL_STRM_TMPT_PRIMARY_UV STRM
      WHERE STY_PURPOSE = strm_purpose
        AND START_DATE <= expStartDate
        AND NVL(END_DATE, expStartDate ) >= expStartDate
        AND NVL(STRM.CAPITALIZE_YN, 'N') = 'N'
        AND STRM.BILLABLE_YN = 'Y'
        AND STRM.PDT_ID = pdtId;

    -- Cursor to fetch EOT Type
    CURSOR get_eot_type( p_lq_id NUMBER )
    IS
      SELECT  lq.id
         ,lq.reference_number
         ,eot.end_of_term_name
         ,eot.eot_type_code eot_type_code
         ,eot.end_of_term_id end_of_term_id
         ,eotversion.end_of_term_ver_id
     FROM OKL_LEASE_QUOTES_B lq,
          okl_fe_eo_term_vers eotversion,
          okl_fe_eo_terms_all_b eot
     WHERE lq.END_OF_TERM_OPTION_ID = eotversion.end_of_term_ver_id
       AND eot.end_of_term_id = eotversion.end_of_term_id
       AND lq.id = p_lq_id;
    l_eot_type_code             VARCHAR2(30);
    -- Cursor to handle the CAPITALIZED Fee amount for each Asset
    CURSOR get_asset_cap_fee_amt(p_source_type VARCHAR2,
                             p_source_id         OKL_LINE_RELATIONSHIPS_B.source_line_ID%TYPE,
                             p_related_line_type OKL_LINE_RELATIONSHIPS_B.related_line_type%TYPE)
    IS
      SELECT SUM(amount) capitalized_amount
        FROM okl_line_relationships_v lre
       WHERE source_line_type = p_source_type
        AND related_line_type = 'CAPITALIZED'
        AND source_line_id = p_source_id;

    -- Local Variables Declarations !
    l_day_count_method           VARCHAR2(30);
    l_days_in_month              VARCHAR2(30);
    l_days_in_year               VARCHAR2(30);
    l_currency                   VARCHAR2(30);
    l_srt_details                okl_pricing_utils_pvt.srt_details_rec_type;
    l_ast_srt_details            okl_pricing_utils_pvt.srt_details_rec_type;
    lx_pricing_parameter_rec     okl_pricing_utils_pvt.pricing_parameter_rec_type;
    x_iir                        NUMBER;
    l_initial_guess              NUMBER := 0.1;
    x_payment                    NUMBER;
    -- Cash flow and Cash flow level variables
    l_cash_flow_rec              so_cash_flows_rec_type;
    l_cash_flow_det_tbl          so_cash_flow_details_tbl_type;
    l_cash_inflows               okl_pricing_utils_pvt.cash_inflows_tbl_type;
    l_residual_inflows           okl_pricing_utils_pvt.cash_inflows_tbl_type;
    cfl_index                    BINARY_INTEGER;
    res_index                    BINARY_INTEGER;
    l_eot_date                   DATE;  -- Effective To of the quote
    l_cf_dpp                     NUMBER;
    l_cf_ppy                     NUMBER;
    l_pricing_method             VARCHAR2(30);
    l_target_rate                NUMBER := p_target_rate;
    l_adj_mat_cat_rec            adj_mat_cat_rec;
    -- Variables used for storing back the pricing results !
    lx_asset_rec                 okl_ass_pvt.assv_rec_type;
    lx_fee_rec                   okl_fee_pvt.feev_rec_type;
    l_ass_adj_tbl                okl_lease_quote_asset_pvt.asset_adjustment_tbl_type;
    l_cf_source                  VARCHAR2(30);
    l_fee_yn                     VARCHAR2(1) := 'N';
    l_cashflow_header_rec        OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_header_rec_type;
    l_cashflow_level_tbl         OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_tbl_type;
    l_asset_rec                  OKL_LEASE_QUOTE_ASSET_PVT.asset_rec_type;
    l_component_tbl              OKL_LEASE_QUOTE_ASSET_PVT.asset_component_tbl_type;
    l_cf_hdr_rec                 OKL_LEASE_QUOTE_ASSET_PVT.cashflow_hdr_rec_type;
    l_cf_level_tbl               OKL_LEASE_QUOTE_ASSET_PVT.cashflow_level_tbl_type;
    l_cfo_exists                 VARCHAR2(30);
    l_eot_percentage             NUMBER;
    l_eot_amount                 NUMBER;
    l_rate_card_id               NUMBER;
    l_lease_rate_factor          NUMBER;
    l_asset_follows_lq_pricing   VARCHAR2(30);
    l_rc_pricing                 VARCHAR2(30);
    l_target_frequency           VARCHAR2(30);
    l_target_arrears_yn          VARCHAR2(30);
    l_sty_id                     NUMBER;
    l_srt_id                     NUMBER;
    l_adj_type                   VARCHAR2(30);
    l_quote_type_code            OKL_LEASE_QUOTES_B.PARENT_OBJECT_CODE%TYPE;
    l_missing_pmnts              BOOLEAN;
    l_asset_number               VARCHAR2(15);
    l_fee_name                   VARCHAR2(150);
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => l_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug 5884825 PAGARG start
    OPEN product_name_csr(p_qte_id);
    FETCH product_name_csr INTO l_product_name;
    CLOSE product_name_csr;
    --Bug 5884825 PAGARG end

    -- Fetch the Lease Quote Header Details !
    OPEN quote_csr(p_qte_id);
    FETCH quote_csr INTO quote_rec;
    IF (quote_csr%NOTFOUND) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    CLOSE quote_csr;
    --Populate l_quote_type_code appropriately
    IF quote_rec.parent_object_code = 'LEASEAPP' THEN
      l_quote_type_code := 'LA';
    ELSE
      l_quote_type_code := 'LQ';
    END IF;
    l_pricing_method := quote_rec.pricing_method;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Fetched the Lease Quote Details ' || p_qte_id);
    -- Derieve the End of Term Date of the Lease Quote
    okl_stream_generator_pvt.add_months_new(
      p_start_date     => quote_rec.expected_start_date,
      p_months_after   => quote_rec.term,
      x_date           => l_eot_date,
      x_return_status  => l_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_eot_date := l_eot_date - 1;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Effective To of the LQ ' || l_eot_date );
    -- Retrieve the Payment Structure or build the Cash flow or Cash flow Level objects
    lx_pricing_parameter_rec.financed_amount := 0;
    lx_pricing_parameter_rec.down_payment    := 0;
    lx_pricing_parameter_rec.trade_in        := 0;
    lx_pricing_parameter_rec.subsidy         := 0;
    -- Retrieve the Asset level information !
    FOR assets_rec IN assets_csr(p_qte_id, p_ast_id) -- could be fee id (ROLLOVER or FINANCED)
    LOOP
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Fetching the Asset Details ' );
     --Bug 5121548 dpsingh start
      l_asset_number := assets_rec.asset_number;
      --Bug 5121548 dpsingh end
      IF ( assets_rec.fee_type <> 'FREE_FORM1' OR assets_rec.ast_id IS NULL )
      THEN
        l_fee_yn := 'Y';
      ELSE
        l_fee_yn := 'N';
      END IF;
      -- Know the type of the EOT
      FOR t_rec IN get_eot_type( p_lq_id => p_qte_id  )
      LOOP
        l_eot_type_code := t_rec.eot_type_code;
      END LOOP;
      -- Populate the Adjustment Matrix Criteria Record.
      l_adj_mat_cat_rec.target_eff_from := quote_rec.expected_start_date;
      l_adj_mat_cat_rec.term := quote_rec.term;
      IF quote_rec.parent_object_code = 'LEASEOPP'
      THEN
        -- Fetch from the Lease Opportunity
        FOR t_rec IN get_cust_details_csr( p_lq_id => p_qte_id )
        LOOP
          l_adj_mat_cat_rec.territory := t_rec.sales_territory_id;
          l_adj_mat_cat_rec.customer_credit_class :=
            okl_lease_app_pvt.get_credit_classfication(
               p_party_id      => t_rec.prospect_id,
               p_cust_acct_id  => t_rec.cust_acct_id,
               p_site_use_id   => -99);
        END LOOP;
      ELSE
        -- Fetch from the Lease Application
        FOR t_rec IN get_cust_details_csr_lapp( p_lq_id => p_qte_id )
        LOOP
          l_adj_mat_cat_rec.territory := t_rec.sales_territory_id;
          l_adj_mat_cat_rec.customer_credit_class :=
            okl_lease_app_pvt.get_credit_classfication(
               p_party_id      => t_rec.prospect_id,
               p_cust_acct_id  => t_rec.cust_acct_id,
               p_site_use_id   => -99);
        END LOOP;
      END IF;
      l_adj_mat_cat_rec.deal_size := NULL;
      IF assets_rec.ast_id IS NOT NULL
      THEN
        l_cf_source := G_CF_SOURCE_LQ_ASS;
        lx_pricing_parameter_rec.line_type := 'FREE_FORM1';
      ELSE
        l_cf_source := G_CF_SOURCE_LQ_FEE;
        lx_pricing_parameter_rec.payment_type := 'INCOME';
        lx_pricing_parameter_rec.line_type := assets_rec.fee_type;
      END IF;
      IF quote_rec.pricing_method <> 'RC'
      THEN
        IF p_price_at_lq_level = FALSE OR p_price_at_lq_level IS NULL
        THEN
          --  get_lq_cash_flows will fetch the Cash flows or Cash flow levels during Structured
          --  pricing (or) builds the CF and CF Levels in case of SRT and return.
          -- Very similiar API to the get_qq_cash_flows-2
          -- User p_cf_source as G_CF_SOURCE_LQ_ASS, as now we will be pricing the asset
          --  with the payment structure defined at the Asset Level itself !
          l_srt_id := assets_rec.rate_template_id;
          get_lq_cash_flows(
            p_api_version          => p_api_version,
            p_init_msg_list        => p_init_msg_list,
            x_return_status        => l_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data,
            p_id                   => nvl(assets_rec.ast_id, assets_rec.fee_id),
            p_lq_srt_id            => assets_rec.rate_template_id,
            p_cf_source            => l_cf_source,
            p_adj_mat_cat_rec      => l_adj_mat_cat_rec,
            p_pricing_method       => quote_rec.pricing_method,
            x_days_in_month        => l_days_in_month,
            x_days_in_year         => l_days_in_year,
            x_cash_flow_rec        => l_cash_flow_rec,
            x_cash_flow_det_tbl    => l_cash_flow_det_tbl);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Fetched asset cash flows at Asset level l_return_status = ' || l_return_status);
        ELSE
          -- Fetching the Cash Flows Assosiated at the Lesae Quote Level
          l_cf_source := G_CF_SOURCE_LQ;
          -- Let the initial iir be p_target_rate
          l_initial_guess := p_target_rate;
          -- Fetch/Retrieve the Cash flows n levels
          get_lq_cash_flows(
            p_api_version          => p_api_version,
            p_init_msg_list        => p_init_msg_list,
            x_return_status        => l_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data,
            p_id                   => p_qte_id,
            p_lq_srt_id            => quote_rec.rate_template_id,
            p_cf_source            => l_cf_source,
            p_adj_mat_cat_rec      => l_adj_mat_cat_rec,
            p_pricing_method       => quote_rec.pricing_method,
            x_days_in_month        => l_days_in_month,
            x_days_in_year         => l_days_in_year,
            x_cash_flow_rec        => l_cash_flow_rec,
            x_cash_flow_det_tbl    => l_cash_flow_det_tbl);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Fetched asset cash flows @LQ level l_return_status = ' || l_return_status);
        END IF; -- If on get_lq_cash_flows
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   quote_rec.pricing_method || 'After lq_cash_flows ' || l_return_status);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'No. of Cash Flow Levels ' || l_cash_flow_det_tbl.COUNT );
        IF l_cash_flow_det_tbl IS NULL OR
           l_cash_flow_det_tbl.COUNT <= 0
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'No Cash flow and Cash flow Levels obtained ! ' );
          OKL_API.SET_MESSAGE (
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_LLA_PMT_SELECT');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_missing_pmnts := FALSE;
        -- When the pricing method is SM, an overridden asset may have a missing payment
        --  or not. If no missing payment is present, rates will be present for all CFL levels
        --  else, rate wont be present.
        IF quote_rec.pricing_method = 'SM'
        THEN
          FOR t_in IN l_cash_flow_det_tbl.FIRST .. l_cash_flow_det_tbl.LAST
          LOOP
            IF ( l_cash_flow_det_tbl(t_in).stub_days > 0 AND
                 l_cash_flow_det_tbl(t_in).stub_amount IS NULL ) OR
               ( l_cash_flow_det_tbl(t_in).number_of_periods > 0 AND
                 l_cash_flow_det_tbl(t_in).amount IS NULL )
            THEN
              l_missing_pmnts := TRUE;
              put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '***** Need to solve for the Missing Payments *********' );
            END IF;
          END LOOP;
        END IF;
        -- Populate app. values for l_days_in_month and l_days_in_year !
        get_day_count_method(
          p_days_in_month    => l_days_in_month,
          p_days_in_year     => l_days_in_year,
          x_day_count_method => l_day_count_method,
          x_return_status    => l_return_status );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'After get_day_count_method ' || l_return_status);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          --Bug 5884825 PAGARG start
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_ISG_DAY_CONVENTION',
                               p_token1       => 'PRODUCT_NAME',
                               p_token1_value => l_product_name);
          --Bug 5884825 PAGARG end
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'l_days_in_month= ' || l_days_in_month || ' |  l_days_in_year = ' || l_days_in_year);
        -- Get the DPP and PPY inorder to populate for the Residuals Table
        get_dpp_ppy(
          p_frequency            => l_cash_flow_det_tbl(l_cash_flow_det_tbl.FIRST).fqy_code,
          x_dpp                  => l_cf_dpp,
          x_ppy                  => l_cf_ppy,
          x_return_status        => l_return_status );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After get_dpp_ppy ' || l_return_status );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF; -- IF quote_rec.pricing_method <> 'RC'
      -- Retrieve the Cost adjustments defined for the Asset ! None for fees
      IF  assets_rec.ast_id IS NOT NULL
      THEN
        FOR asset_cost_adj_rec IN asset_cost_adj_csr(p_qte_id, nvl(assets_rec.ast_id, -9999) )
        LOOP
          IF asset_cost_adj_rec.adjustment_source_type = G_DOWNPAYMENT_TYPE  AND
             quote_rec.pricing_method <> 'SD'
          THEN
              lx_pricing_parameter_rec.down_payment := lx_pricing_parameter_rec.down_payment
                                                         + asset_cost_adj_rec.value;
          ELSIF asset_cost_adj_rec.adjustment_source_type = G_SUBSIDY_TYPE AND
             quote_rec.pricing_method <> 'SS'
          THEN
            IF ( nvl(asset_cost_adj_rec.value, -9999) = -9999)
            THEN
              OPEN subsidy_adj_csr(asset_cost_adj_rec.ADJUSTMENT_SOURCE_ID);
              FETCH subsidy_adj_csr INTO subsidy_adj_rec;
              CLOSE subsidy_adj_csr;
              -- Bug 6622178 : Start
              -- Consider all subsidies for the asset
              lx_pricing_parameter_rec.subsidy := lx_pricing_parameter_rec.subsidy + NVL(subsidy_adj_rec.amount,0);
            ELSE
              lx_pricing_parameter_rec.subsidy := lx_pricing_parameter_rec.subsidy + NVL(asset_cost_adj_rec.value,0);
              -- Bug 6622178 : End
            END IF;
          ELSIF asset_cost_adj_rec.adjustment_source_type = G_TRADEIN_TYPE AND
             quote_rec.pricing_method <> 'SI'
          THEN
            lx_pricing_parameter_rec.trade_in := lx_pricing_parameter_rec.trade_in
                                                     + asset_cost_adj_rec.value;
          END IF;
        END LOOP;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'After Retrieving the Asset Cost Adjustments ');
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Down Payment| Trade In | Subsidy ' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               lx_pricing_parameter_rec.down_payment || ' | ' ||
               lx_pricing_parameter_rec.trade_in || ' | ' ||
               lx_pricing_parameter_rec.subsidy );
      END IF; -- IF assets_rec.ast_id IS NOT NULL
      -- Generate the Streams for this Asset !
      -- Retrieve the Financed amount and the End of Term amount !
      res_index := 1;
      l_eot_amount := 0;
      IF ( assets_rec.ast_id IS NOT NULL)
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Asset/Fee ID = ' || assets_rec.ast_id );
        FOR asset_adj_rec IN asset_adj_csr(p_qte_id, assets_rec.ast_id)
        LOOP
          IF l_pricing_method <> 'SF' OR ( quote_rec.pricing_method = 'SF' AND p_price_at_lq_level )
          THEN
            lx_pricing_parameter_rec.financed_amount := lx_pricing_parameter_rec.financed_amount
                                                        + nvl(asset_adj_rec.oec,0);
          END IF;
          -- Calculate the Capitalized Fee for this Asset
          FOR t_rec IN get_asset_cap_fee_amt(
                         p_source_type       => 'ASSET',
                         p_source_id         => assets_rec.ast_id,
                         p_related_line_type => 'CAPITALIZED')
          LOOP
            lx_pricing_parameter_rec.cap_fee_amount := nvl(t_rec.capitalized_amount, 0);
          END LOOP;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Unit Cost=' || asset_adj_rec.unit_cost || ' No. of Units ' || asset_adj_rec.number_of_units);
          l_residual_inflows(res_index).line_number := res_index;
          IF ( l_eot_type_code = 'PERCENT' OR l_eot_type_code = 'RESIDUAL_PERCENT' ) AND
             ( l_pricing_method <> 'SF'  OR ( quote_rec.pricing_method = 'SF' AND p_price_at_lq_level ) )
          THEN
            -- Formula: EOT amount = OEC * residual_percentage
            -- The above formulat is applicable, a/ When EOT is PERCENT/RESIDUAL_PERCENT
            -- b/ When solving for an overridden asset, its financed amount.
            -- c/ When Qt. level pricing method is SF, but you are here actually for derieving
            --    the payment structures for non-overridden assets when pricing method is SF
            l_residual_inflows(res_index).cf_amount :=
              (asset_adj_rec.end_of_term_value/100) * nvl(asset_adj_rec.unit_cost * asset_adj_rec.number_of_units,0);
            l_eot_percentage := asset_adj_rec.end_of_term_value;
          ELSIF ( l_eot_type_code = 'PERCENT' OR l_eot_type_code = 'RESIDUAL_PERCENT' ) AND
                  ( l_pricing_method = 'SF'  )
          THEN
             -- EOT is given in terms of percentage .. store the percentage
             -- NOTE: For overriden assets, OEC percentage doesnot matter. As they are being priced seperately
            l_residual_inflows(res_index).cf_amount := (asset_adj_rec.end_of_term_value/100);
          ELSE
            -- EOT is an amount so directly store it ..
            l_residual_inflows(res_index).cf_amount   := asset_adj_rec.end_of_term_value;
          END IF;
          -- Store the End of Term Value
          l_eot_amount := l_eot_amount + l_residual_inflows(res_index).cf_amount;
          l_residual_inflows(res_index).cf_date     := l_eot_date;
          l_residual_inflows(res_index).cf_miss_pay := 'N';
          l_residual_inflows(res_index).is_stub     := 'N';
          l_residual_inflows(res_index).is_arrears  := 'Y';
          l_residual_inflows(res_index).cf_dpp := l_cf_dpp;
          l_residual_inflows(res_index).cf_ppy := l_cf_ppy;
          -- Increment the res_index
          res_index := res_index + 1;
        END LOOP;
      ELSE -- ELSE IT IS A FEE
        lx_pricing_parameter_rec.financed_amount := assets_rec.fee_amount;
      END IF;
      IF l_pricing_method = 'RC' AND l_fee_yn = 'N'
      THEN
        -- Calculate the EOT Percentage Amount
        IF ( l_eot_type_code <> 'PERCENT' AND l_eot_type_code <> 'RESIDUAL_PERCENT' )
        THEN
          l_eot_percentage := nvl(l_eot_amount,0) / lx_pricing_parameter_rec.financed_amount * 100;
        END IF;
        l_asset_follows_lq_pricing := 'Y';
        l_rc_pricing := 'Y';
        -- Prioritize Configuration line ones first
        IF nvl(quote_rec.line_level_pricing, 'N') = 'Y'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '******* Line Level Pricing is enabled at Quote *******' );
          -- Line level pricing has been enabled
          -- Store the Lease Rate Factor and Rate Template of the of the Configuration lines
          IF nvl(assets_rec.structured_pricing, 'N') = 'Y'
          THEN
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '******* Structured Pricing picked @ Asset ******* ' || assets_rec.structured_pricing );
            l_lease_rate_factor := assets_rec.lease_rate_factor;
            l_asset_follows_lq_pricing := 'N';
            l_rc_pricing := 'N';
            -- May need to store the Frequency/Arrears flag even here
            l_target_frequency := assets_rec.target_frequency;
            l_target_arrears_yn := assets_rec.target_arrears;
          ELSIF assets_rec.rate_card_id IS NOT NULL
          THEN
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '******* Rate Card picked @ Asset ******* '  || assets_rec.rate_card_id );
            l_rate_card_id := assets_rec.rate_card_id;
            l_asset_follows_lq_pricing := 'N';
            l_rc_pricing := 'Y';
          END IF;
        END IF;
        IF NVL(quote_rec.line_level_pricing, 'N') = 'N' OR
           l_asset_follows_lq_pricing = 'Y'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '******* Either Line Level Pricing is NULL/N or Asset follws rate @ Quote *******' ||
                quote_rec.line_level_pricing || ' | ' || l_asset_follows_lq_pricing );
          -- If Line level pricing is not picked or
          --  the configuration line is not overriding the pricing params
          --  picked at the lease quote level, use the data at the lease quote level itself.
          IF nvl(quote_rec.structured_pricing, 'N') = 'Y'
          THEN
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '******* Structured Pricing Enabled @ Quote *******' || quote_rec.structured_pricing );
            l_lease_rate_factor := quote_rec.lease_rate_factor;
            l_rc_pricing := 'N';
            -- May need to store the Frequency/Arrears flag even here
            l_target_frequency := quote_rec.target_frequency;
            l_target_arrears_yn := quote_rec.target_arrears;
          ELSIF quote_rec.rate_card_id IS NOT NULL
          THEN
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '******* Rate Card Picked @ Quote *******' || quote_rec.rate_card_id );
            l_rate_card_id := quote_rec.rate_card_id;
            l_rc_pricing := 'Y';
          END IF;
        END IF;
      ELSIF l_pricing_method = 'RC' AND l_fee_yn = 'Y'
      THEN
        -- Handling seperately for config fee FINANCED/ROLLOVER
        l_eot_percentage := 0;
        l_asset_follows_lq_pricing := 'N';
        IF nvl(assets_rec.structured_pricing, 'N') = 'Y'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              '******* Structured Pricing picked @ Config FEE level = ' || assets_rec.structured_pricing );
          l_lease_rate_factor := assets_rec.lease_rate_factor;
          l_asset_follows_lq_pricing := 'N';
          l_rc_pricing := 'N';
          -- May need to store the Frequency/Arrears flag even here
          l_target_frequency := assets_rec.target_frequency;
          l_target_arrears_yn := assets_rec.target_arrears;
        ELSIF assets_rec.rate_card_id IS NOT NULL
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              '******* Rate Card picked @ config Fee Level = '  || assets_rec.rate_card_id );
          l_rate_card_id := assets_rec.rate_card_id;
          l_rc_pricing := 'Y';
        END IF;
      END IF;
      IF l_pricing_method = 'RC' AND
         l_rc_pricing = 'Y'
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Pricing using a Rate Card with ID ' || l_rate_card_id );
        get_lease_rate_factors(
          p_api_version            => p_api_version,
          p_init_msg_list          => p_init_msg_list,
          x_return_status          => l_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_lrt_id                 => l_rate_card_id,
          p_start_date             => quote_rec.expected_start_date,
          p_term_in_months         => quote_rec.term,
          p_eot_percentage         => l_eot_percentage,
          x_lrs_details            => l_lrs_details,
          x_lrs_factor             => l_lrs_factor,
          x_lrs_levels             => l_lrs_levels);
        -- If unable to find the Lease Rate Factor levels throw the error ..
        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Couldnot found the Lease Rate Factor levels for configuration line ' || assets_rec.name );
          -- Show the message and then return back throwing an error!
          OKL_API.set_message(
            p_app_name => G_APP_NAME,
            p_msg_name => 'OKL_LP_NO_LRS_LEVELS_FOUND',
            p_token1 => 'ITEMCAT',
            p_token1_value => assets_rec.name,
            p_token2 => 'ITEMTERM',
            p_token2_value => quote_rec.term,
            p_token3 => 'ITEMEOTPERCENT',
            p_token3_value => ROUND(l_eot_percentage,4) );
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Apply the adjustment matrix if needed!
        l_adj_factor := 0;
        IF l_lrs_details.adj_mat_version_id IS NOT NULL
        THEN
          l_ac_rec_type.src_id := l_lrs_details.adj_mat_version_id; -- Pricing adjustment matrix ID
          l_ac_rec_type.source_name := NULL; -- NOT Mandatory Pricing Adjustment Matrix Name !
          l_ac_rec_type.target_id := quote_rec.ID ; -- Quote ID
          l_ac_rec_type.src_type := 'PAM'; -- Lookup Code
          l_ac_rec_type.target_type := 'QUOTE'; -- Same for both Quick Quote and Standard Quote
          l_ac_rec_type.target_eff_from  := quote_rec.expected_start_date; -- Quote effective From
          l_ac_rec_type.term  := quote_rec.term; -- Remaining four will be from teh business object like QQ / LQ
          l_ac_rec_type.territory := l_adj_mat_cat_rec.territory;
          l_ac_rec_type.deal_size := lx_pricing_parameter_rec.financed_amount; -- Not sure how to pass this value
          l_ac_rec_type.customer_credit_class := l_adj_mat_cat_rec.customer_credit_class; -- Not sure how to pass this even ..
          -- Fetching the deal_size ..
          -- Calling the API to get the adjustment factor ..
          okl_ec_evaluate_pvt.get_adjustment_factor(
             p_api_version       => p_api_version,
             p_init_msg_list     => p_init_msg_list,
             x_return_status     => x_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             p_okl_ac_rec        => l_ac_rec_type,
             x_adjustment_factor => l_adj_factor );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Adjustment Factor ' ||  l_adj_factor );
        l_months_per_period := okl_stream_generator_pvt.get_months_factor(
                                 p_frequency     => l_lrs_details.frq_code,
                                 x_return_status => l_return_status);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Months/Period ' || l_months_per_period );
        l_cash_flow_rec.due_arrears_yn := l_lrs_details.arrears_yn;
        --Populating the Cash Flow Levels
        l_months_after := 0;
        cf_index := 1;
        FOR i in l_lrs_levels.FIRST .. l_lrs_levels.LAST
        LOOP
          l_cash_flow_det_tbl(cf_index).fqy_code := l_lrs_details.frq_code;
          l_cash_flow_det_tbl(cf_index).number_of_periods := l_lrs_levels(i).periods;
          -- FORMULA: Periodic Amt = (Rate Factor + Adj. Factor ) * ( C - NVL( S+D+T, 0) )
          l_cash_flow_det_tbl(cf_index).amount :=
            ( l_lrs_levels(cf_index).lease_rate_factor + NVL(l_adj_factor,0) ) *
                ( lx_pricing_parameter_rec.financed_amount - NVL(lx_pricing_parameter_rec.subsidy +
              lx_pricing_parameter_rec.down_payment + lx_pricing_parameter_rec.trade_in,0 ) );
          l_cash_flow_det_tbl(cf_index).is_stub := 'N';
          -- Need to populate the start date per line .. !!
          okl_stream_generator_pvt.add_months_new(
            p_start_date     => quote_rec.expected_start_date,
            p_months_after   => l_months_after,
            x_date           => l_cash_flow_det_tbl(cf_index).start_date,
            x_return_status  => l_return_status);
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- Add to the l_months_after
          l_months_after := l_months_after + ( l_lrs_levels(i).periods * l_months_per_period );
          -- Increment the index
          cf_index := cf_index + 1;
        END LOOP;
      ELSIF l_pricing_method = 'RC' AND
            l_rc_pricing = 'N'
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '!!!!! STRUCTURED PRICING IN RATE CARD PRICING !!!!!! ' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'lease rate factor | Frequency | Arrears ' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                l_lease_rate_factor || ' | ' || l_target_frequency || ' | ' || l_target_arrears_yn  );
        l_months_per_period := okl_stream_generator_pvt.get_months_factor(
                                 p_frequency     => l_target_frequency,
                                 x_return_status => l_return_status);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Months/Period ' || l_months_per_period );
        l_cash_flow_rec.due_arrears_yn := l_target_arrears_yn;
        --Populating the Cash Flow Levels
        l_months_after := 0;
        l_cash_flow_det_tbl(1).fqy_code := l_target_frequency;
        l_cash_flow_det_tbl(1).number_of_periods := quote_rec.term/l_months_per_period;
        -- Need to check whether the periods is a whole number or not
        IF trunc(l_cash_flow_det_tbl(1).number_of_periods) <>
           l_cash_flow_det_tbl(1).number_of_periods
        THEN
          -- Throw the message saying that Periods have to be whole number
          OKL_API.SET_MESSAGE (
            p_app_name => G_APP_NAME,
            p_msg_name => 'OKL_LEVEL_PERIOD_FRACTION');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- FORMULA: Periodic Amt = User Entered Rate Factor  * ( C - NVL( S+D+T, 0) )
        l_cash_flow_det_tbl(1).amount :=  l_lease_rate_factor *
                ( lx_pricing_parameter_rec.financed_amount - NVL(lx_pricing_parameter_rec.subsidy +
              lx_pricing_parameter_rec.down_payment + lx_pricing_parameter_rec.trade_in,0 ) );
        l_cash_flow_det_tbl(1).is_stub := 'N';
        l_cash_flow_det_tbl(1).start_date := quote_rec.expected_start_date;
      END IF;
      -- Generate the Streams based on the Cash flows obtained above
      IF l_cash_flow_det_tbl IS NOT NULL AND
         l_cash_flow_det_tbl.COUNT > 0
      THEN
        -- Initialize the Strm Count to Zero
        gen_so_cf_strms(
          p_api_version            => p_api_version,
          p_init_msg_list          => p_init_msg_list,
          x_return_status          => l_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_cash_flow_rec          => l_cash_flow_rec,
          p_cf_details_tbl         => l_cash_flow_det_tbl,
          x_cash_inflow_strms_tbl  => l_cash_inflows);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'After gen_so_cf_strms ' || l_return_status);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Number of Stream Elements generated ' || l_cash_inflows.COUNT);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'No Cash flow and Cash flow Levels obtained ! ' );
        OKL_API.SET_MESSAGE (
          p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKL_LLA_PMT_SELECT');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF; -- IF l_cash_flow_det_tbl.COUNT > 0
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'After building the Residual Table Count ' || l_residual_inflows.COUNT );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Financed Amount = ' || lx_pricing_parameter_rec.financed_amount);
      lx_pricing_parameter_rec.cash_inflows := l_cash_inflows;
      lx_pricing_parameter_rec.residual_inflows := l_residual_inflows;
      -- Bug 7440199: Quote Streams ER: RGOOTY
      lx_pricing_parameter_rec.cfo_id := l_cash_flow_rec.cfo_id;
      -- Bug 7440199: Quote Streams ER: RGOOTY
      IF quote_rec.pricing_method = 'RC'
      THEN
        -- Get the DPP and PPY inorder to populate for the Residuals Table
        get_dpp_ppy(
          p_frequency            => l_cash_flow_det_tbl(l_cash_flow_det_tbl.FIRST).fqy_code,
          x_dpp                  => l_cf_dpp,
          x_ppy                  => l_cf_ppy,
          x_return_status        => l_return_status );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After get_dpp_ppy ' || l_return_status );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF lx_pricing_parameter_rec.residual_inflows.COUNT > 0
        THEN
          FOR r_in IN lx_pricing_parameter_rec.residual_inflows.FIRST ..
                      lx_pricing_parameter_rec.residual_inflows.LAST
          LOOP
            lx_pricing_parameter_rec.residual_inflows(r_in).cf_dpp := l_cf_dpp;
            lx_pricing_parameter_rec.residual_inflows(r_in).cf_ppy := l_cf_ppy;
          END LOOP;
        END IF;
      END IF;
      IF quote_rec.pricing_method = 'TR' AND l_fee_yn = 'Y'
      THEN
        FOR t_in IN lx_pricing_parameter_rec.cash_inflows.FIRST ..
                     lx_pricing_parameter_rec.cash_inflows.LAST
        LOOP
          -- For each cash flow level use the SUB_IIR rate solved
          lx_pricing_parameter_rec.cash_inflows(t_in).cf_rate := p_target_rate ;
        END LOOP;
      END IF;
      -- End: Fix for SY pricing method @ Asset Level
      IF quote_rec.pricing_method = 'SM' AND l_missing_pmnts = FALSE
      THEN
        -- Nothing to be solved for
        NULL;
      ELSE
        IF ( ( l_fee_yn = 'Y' ) AND ( l_pricing_method IN ( 'SP', 'SM', 'TR' ) ) ) OR
           ( ( l_fee_yn = 'N' ) AND ( l_pricing_method NOT IN ( 'SY', 'RC' ) ) )
        THEN
          -- call compute_iir for payment
          -- For fees, when the pricing method is SP/SM/TR, then only we solve for the payment amount
          -- For Assets, when pricing method is SY/RC, therez nothing to solve
          IF l_pricing_method = 'SF' AND
             ( l_eot_type_code = 'PERCENT' OR l_eot_type_code = 'RESIDUAL_PERCENT' )
          THEN
            l_pricing_method := 'SFP';
          END IF;
          compute_iir(
            p_api_version            => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_start_date             => quote_rec.expected_start_date,
            p_day_count_method       => l_day_count_method,
            p_pricing_method         => l_pricing_method,
            p_initial_guess          => l_initial_guess,
            px_pricing_parameter_rec => lx_pricing_parameter_rec,
            px_iir                   => x_iir,
            x_payment                => x_payment);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           'After compute_iir l_return_status = ' || l_return_status || 'Solved Payment Amount ' || x_payment);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Financed Amount | Down Payment | Subsidy | Trade in ');
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            ROUND(lx_pricing_parameter_rec.financed_amount, 4) || ' | ' || ROUND(lx_pricing_parameter_rec.down_payment, 4) || ' | ' ||
            ROUND(lx_pricing_parameter_rec.subsidy, 4) || ' | ' || ROUND(lx_pricing_parameter_rec.trade_in, 4)  );
          IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;
          IF l_pricing_method IN ( 'SP', 'SM', 'TR' ) AND
             x_payment < 0
          THEN
            --Bug 5121548 dpsingh start
            IF l_fee_yn = 'Y'
            THEN
              OPEN fees_csr(p_qte_id,p_ast_id);
              FETCH fees_csr into l_fee_name;
              CLOSE fees_csr;
              OKL_API.SET_MESSAGE (
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_NEGATIVE_ADJ_AMT_FEE',
                p_token1       => 'TYPE',
                p_token1_value => 'Payment',
                p_token2       => 'AMOUNT',
                p_token2_value => round(x_payment,2),
                p_token3       => 'NAME',
                p_token3_value => l_fee_name);
            ELSE
              OKL_API.SET_MESSAGE (
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_NEGATIVE_ADJ_AMT_ASSET',
                p_token1       => 'TYPE',
                p_token1_value => 'Payment',
                p_token2       => 'AMOUNT',
                p_token2_value => round(x_payment,2),
                p_token3       => 'NAME',
                p_token3_value => l_asset_number);
            END IF;
            --Bug 5121548 dpsingh end
            RAISE okl_api.g_exception_error;
          END IF;
          IF l_pricing_method = 'SFP'
          THEN
            l_pricing_method := 'SF';  -- Revert back the pricing method to 'SF'
            -- Change the residual amount
            IF lx_pricing_parameter_rec.residual_inflows IS NOT NULL AND
               lx_pricing_parameter_rec.residual_inflows.COUNT > 0
            THEN
              FOR t_in IN lx_pricing_parameter_rec.residual_inflows.FIRST ..
                          lx_pricing_parameter_rec.residual_inflows.LAST
              LOOP
                lx_pricing_parameter_rec.residual_inflows(t_in).cf_amount :=
                  lx_pricing_parameter_rec.residual_inflows(t_in).cf_amount *
                  lx_pricing_parameter_rec.financed_amount;
               put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'lx_pricing_parameter_rec.residual_inflows(t_in).cf_amount = ' ||
                 round(lx_pricing_parameter_rec.residual_inflows(t_in).cf_amount, 4) );
              END LOOP;
            END IF; -- Count on Residual Table
          END IF; -- IF l_pricing_method = 'SFP'
        END IF;
      END IF;
    END LOOP; -- For loop on assets_csr
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               ' quote_rec.pricing_method = ' || quote_rec.pricing_method ||
               'assets_rec.rate_template_id = ' || assets_rec.rate_template_id );
    IF quote_rec.pricing_method = 'SP' OR
       quote_rec.pricing_method = 'RC' OR
       ( quote_rec.pricing_method = 'SM' AND l_missing_pmnts )OR
       (p_price_at_lq_level AND quote_rec.pricing_method IN ( 'SY', 'TR', 'SF') ) OR
       l_srt_id IS NOT NULL -- When the lines uses the SRT
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Creating/Updating the Cash Flow Object !!' );
      -- Check whether CFO already exists or not, if so, update
      -- else create new
      l_cfo_exists := 'NO';
      IF l_fee_yn = 'Y'
      THEN
        l_cashflow_header_rec.parent_object_code := 'QUOTED_FEE';
        FOR t_rec IN check_cfo_exists_csr(
          p_oty_code     => 'QUOTED_FEE',
          p_source_table => 'OKL_FEES_B',
          p_source_id    => p_ast_id)
        LOOP
          l_cfo_exists := t_rec.cfo_exists;
          l_sty_id := t_rec.sty_id;
        END LOOP;
      ELSE
        l_cashflow_header_rec.parent_object_code := 'QUOTED_ASSET';
        FOR t_rec IN check_cfo_exists_csr(
          p_oty_code     => 'QUOTED_ASSET',
          p_source_table => 'OKL_ASSETS_B',
          p_source_id    => p_ast_id)
        LOOP
          l_cfo_exists := t_rec.cfo_exists;
          l_sty_id := t_rec.sty_id;
        END LOOP;
      END IF;
      -- IF cash flows exists delete the existing ones and create afresh ..
      IF l_cfo_exists = 'YES'
      THEN
        -- Delete the Cash Flow Levels which may be already created by Pricing ..
        okl_lease_quote_cashflow_pvt.delete_cashflows (
          p_api_version          => p_api_version,
          p_init_msg_list        => p_init_msg_list,
          p_transaction_control  => NULL,
          p_source_object_code   => l_cashflow_header_rec.parent_object_code,
          p_source_object_id     => p_ast_id,
          x_return_status        => l_return_status,
          x_msg_count            => x_msg_count,
          x_msg_data             => x_msg_data);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  ' ----- After deleting the Cash flows for the asset  ' || l_return_status );
        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
      ELSE
        FOR t_rec IN c_strm_type (
             pdtId        => quote_rec.product_id,
             expStartDate => quote_rec.expected_start_date,
             strm_purpose => 'RENT')
        LOOP
          l_sty_id := t_rec.payment_type_id;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Fetched stream type id from the cursor' || l_sty_id );
        END LOOP;
      END IF;
      --  Create cash flows in case of user using the SRT
      l_cashflow_header_rec.parent_object_id := p_ast_id;
      l_cashflow_header_rec.type_code := 'INFLOW';
      l_cashflow_header_rec.status_code := l_cash_flow_rec.sts_code;
      IF p_price_at_lq_level = TRUE
      THEN
        -- You will reach this code only when you are actually Solving for Payment
        -- or Missing Payment for the Assets, which follow the payment strucutre
        -- at the lease quote, and you want to find out the payment at each and every
        -- Non-overriding Fee/Asset.
        -- Pricing solves the payment amount for all the non-overriding assets and
        -- store the WORK statused cash flow levels.
       l_cashflow_header_rec.status_code := 'WORK';
      END IF;
      l_cashflow_header_rec.arrears_flag := l_cash_flow_rec.due_arrears_yn;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Stream type id using for creation of cash flows ' || l_sty_id );
      IF l_sty_id IS NULL AND
         l_fee_yn = 'N'
      THEN
        -- When pricing option is SRT, you may come here ..
        FOR t_rec IN c_strm_type (
             pdtId        => quote_rec.product_id,
             expStartDate => quote_rec.expected_start_date,
             strm_purpose => 'RENT')
        LOOP
          l_sty_id := t_rec.payment_type_id;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Fetched stream type id from the cursor' || l_sty_id );
        END LOOP;
      END IF;
      IF l_cash_flow_rec.sty_id IS NOT NULL
      THEN
        l_cashflow_header_rec.stream_type_id := l_cash_flow_rec.sty_id;
      ELSE
        l_cashflow_header_rec.stream_type_id := l_sty_id;
      END IF;
      -- Exception for Stream Type id is: TR pricing method, Fees=Yes,
      IF l_fee_yn = 'Y' and quote_rec.pricing_method = 'TR'
      THEN
        FOR t_rec IN c_fee_pmnt_strm_type_csr ( pdtId => quote_rec.product_id,
              expStartDate => quote_rec.expected_start_date, strm_purpose => 'FEE_PAYMENT')
        LOOP
          l_cashflow_header_rec.stream_type_id := t_rec.payment_type_id;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Fetched fee pmnt cursor id from the cursor' || l_sty_id );
          EXIT;
        END LOOP;
      END IF;
      l_cashflow_header_rec.frequency_code := l_cash_flow_det_tbl(l_cash_flow_det_tbl.FIRST).fqy_code;
      l_cashflow_header_rec.quote_type_code := l_quote_type_code;
      l_cashflow_header_rec.quote_id := p_qte_id;
      FOR i in l_cash_flow_det_tbl.FIRST..l_cash_flow_det_tbl.LAST
      LOOP
        l_cashflow_level_tbl(i).start_date := l_cash_flow_det_tbl(i).start_date;
        IF p_price_at_lq_level AND quote_rec.pricing_method IN ('SY', 'TR', 'SF')
        THEN
          l_cashflow_level_tbl(i).rate := quote_rec.sub_iir;
        ELSE
          l_cashflow_level_tbl(i).rate := l_cash_flow_det_tbl(i).rate;
        END IF;
        l_cashflow_level_tbl(i).stub_amount := l_cash_flow_det_tbl(i).stub_amount;
        l_cashflow_level_tbl(i).stub_days := l_cash_flow_det_tbl(i).stub_days;
        l_cashflow_level_tbl(i).periods := l_cash_flow_det_tbl(i).number_of_periods;
        l_cashflow_level_tbl(i).periodic_amount := l_cash_flow_det_tbl(i).amount;
        IF quote_rec.pricing_method = 'RC'
        THEN
          l_cashflow_level_tbl(i).periodic_amount := l_cash_flow_det_tbl(i).amount;
        ELSIF quote_rec.pricing_method = 'SP' OR
             ( p_price_at_lq_level AND quote_rec.pricing_method IN ('SY', 'TR', 'SF'))
        THEN
          -- Pricing would have solved the periodic/stub amount for all cash flow levels
          IF l_cash_flow_det_tbl(i).stub_days > 0
          THEN
            l_cashflow_level_tbl(i).stub_amount := x_payment;
          ELSIF l_cash_flow_det_tbl(i).number_of_periods > 0
          THEN
            l_cashflow_level_tbl(i).periodic_amount := x_payment;
          END IF;
        ELSIF quote_rec.pricing_method = 'SM'
        THEN
          -- Pricing would have solved the periodic/stub amount for only the cash flow
          -- level which misses it ..
          IF l_cash_flow_det_tbl(i).stub_days > 0 AND l_cash_flow_det_tbl(i).stub_amount IS NULL
          THEN
            l_cashflow_level_tbl(i).stub_amount := x_payment;
            l_cashflow_level_tbl(i).missing_pmt_flag := 'Y';
          ELSIF l_cash_flow_det_tbl(i).number_of_periods > 0 AND l_cash_flow_det_tbl(i).amount IS NULL
          THEN
            l_cashflow_level_tbl(i).periodic_amount := x_payment;
            l_cashflow_level_tbl(i).missing_pmt_flag := 'Y';
          END IF;
        END IF;
        l_cashflow_level_tbl(i).record_mode := 'CREATE';
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Before calling create_cash_flow ' );
      OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_transaction_control => NULL,
        p_cashflow_header_rec => l_cashflow_header_rec,
        p_cashflow_level_tbl  => l_cashflow_level_tbl,
        x_return_status       => l_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data);
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Bug 7440199: Quote Streams ER: RGOOTY: Start
      lx_pricing_parameter_rec.cfo_id := l_cashflow_header_rec.cashflow_object_id;
      -- Bug 7440199: Quote Streams ER: RGOOTY: End
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'After calling create_cash_flow ' || l_return_status);
     END IF;
     -- When the pricing method is SP/SM update the pricing rec with the
     --  solved payment amount back
     IF quote_rec.pricing_method IN ( 'SP', 'TR' ) OR
        ( quote_rec.pricing_method = 'SM' AND l_missing_pmnts )
     THEN
       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Updating the Cash inflows back with the solved payment amount ' || x_payment);
       FOR t_in IN lx_pricing_parameter_rec.cash_inflows.FIRST ..
                   lx_pricing_parameter_rec.cash_inflows.LAST
       LOOP
         IF lx_pricing_parameter_rec.cash_inflows(t_in).cf_miss_pay = 'Y' OR
            quote_rec.pricing_method IN ( 'SP', 'TR' )
         THEN
           lx_pricing_parameter_rec.cash_inflows(t_in).cf_amount := x_payment;
         END IF;
         put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    lx_pricing_parameter_rec.cash_inflows(t_in).cf_date || ' | ' ||
                    lx_pricing_parameter_rec.cash_inflows(t_in).cf_miss_pay || ' | ' ||
                    lx_pricing_parameter_rec.cash_inflows(t_in).cf_amount );
       END LOOP;
     END IF;
     IF quote_rec.pricing_method = 'SF' AND
        p_price_at_lq_level = FALSE
     THEN
       lx_asset_rec.id  := p_ast_id;
       IF (l_fee_yn = 'N')
       THEN
         -- Need to change here to call the okl_lease_quote_asset_pvt.update_asset
        l_asset_rec.id  := p_ast_id;
        l_asset_rec.oec := lx_pricing_parameter_rec.financed_amount;
        FOR t_rec IN c_asset_comp_csr( p_asset_id => p_ast_id )
        LOOP
          l_component_tbl(1).id := t_rec.id;
          l_component_tbl(1).unit_cost := l_asset_rec.oec / t_rec.number_of_units;
          l_component_tbl(1).record_mode := 'update';
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Updated l_component_tbl(1).unit_cost =  ' || l_component_tbl(1).unit_cost );
        END LOOP;
        -- Call the update api to store back the calculated OEC of the Asset!
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Before OKL_LEASE_QUOTE_ASSET_PVT.update_asset ');
        -- Instead we need to use the OKL_LEASE_QUOTE_ASSET_PVT.update_asset
        OKL_LEASE_QUOTE_ASSET_PVT.update_asset (
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_transaction_control => 'T',
          p_asset_rec           => l_asset_rec,
          p_component_tbl       => l_component_tbl,
          p_cf_hdr_rec          => l_cf_hdr_rec,
          p_cf_level_tbl        => l_cf_level_tbl,
          x_return_status       => l_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'After OKL_LEASE_QUOTE_ASSET_PVT.update_asset ' || l_return_status );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        -- Do Nothing
        NULL;
      END IF;
     ELSIF (quote_rec.pricing_method = 'SD' OR
            quote_rec.pricing_method = 'SI' OR
            quote_rec.pricing_method = 'SS') AND (l_fee_yn = 'N')
     THEN
       ----------------------------------------------------------------------------------
       -- Create an Asset Cost Adjustment for the Solved Down Payment/Trade-in/Subsidy !!
       ----------------------------------------------------------------------------------
       -- Need to populate the following !!
       l_ass_adj_tbl.DELETE;
       l_ass_adj_tbl(1).parent_object_code := 'ASSET';
       l_ass_adj_tbl(1).parent_object_id := p_ast_id;
       l_ass_adj_tbl(1).basis := 'FIXED';
       IF quote_rec.pricing_method = 'SI'
       THEN
         l_ass_adj_tbl(1).adjustment_source_type := 'TRADEIN';
         l_ass_adj_tbl(1).VALUE := lx_pricing_parameter_rec.trade_in;
         l_adj_type := 'Trade-in';
       ELSIF quote_rec.pricing_method = 'SD'
       THEN
         l_ass_adj_tbl(1).adjustment_source_type := 'DOWN_PAYMENT';
         l_ass_adj_tbl(1).VALUE := lx_pricing_parameter_rec.down_payment;
         l_adj_type := 'Down Payment';
       ELSIF quote_rec.pricing_method = 'SS'
       THEN
         l_ass_adj_tbl(1).adjustment_source_type := 'SUBSIDY';
         l_ass_adj_tbl(1).VALUE := lx_pricing_parameter_rec.subsidy;
         l_adj_type := 'Subsidy';
       END IF;
       IF l_ass_adj_tbl(1).VALUE < 0 THEN
         --Bug 5121548 dpsingh start
         OKL_API.SET_MESSAGE (
           p_app_name     => G_APP_NAME,
           p_msg_name     => 'OKL_NEGATIVE_ADJ_AMT_ASSET',
           p_token1       => 'TYPE',
           p_token1_value => l_adj_type,
           p_token2       => 'AMOUNT',
           p_token2_value => round(l_ass_adj_tbl(1).VALUE, 2),
           p_token3       => 'NAME',
           p_token3_value => l_asset_number);
         --Bug 5121548 dpsingh end
         RAISE okl_api.g_exception_error;
       END IF;
       okl_lease_quote_asset_pvt.create_adjustment(
         p_api_version             => p_api_version,
         p_init_msg_list           => p_init_msg_list,
         p_transaction_control     => FND_API.G_TRUE,
         p_asset_adj_tbl           => l_ass_adj_tbl,
         x_return_status           => l_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data );
       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After okl_lease_quote.asset.create_adjustment ' || l_return_status);
       IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
       ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
       END IF;
     END IF; -- IF quote_rec.pricing_method  .....
     -- Actual logic Ends here
     x_pricing_parameter_rec := lx_pricing_parameter_rec;
     x_return_status := l_return_status;
     OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                          x_msg_data   => x_msg_data);
     put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_name) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END price_standard_quote_asset;
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : is_asset_overriding
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 5-Aug-2005 - created
  -- This is the API, which will return TRUE, if an Asset in a Lease Quote has overridden
  --  the Payment option defined at the quote level, otherwise if it has to follow the payment
  --  option at the quote level, return false !
  -- End of Commnets
  --------------------------------------------------------------------------------
   FUNCTION is_asset_overriding( p_qte_id                IN NUMBER,
                                p_ast_id                IN NUMBER,
                                p_lq_line_level_pricing IN VARCHAR2,
                                p_lq_srt_id             IN NUMBER,
                                p_ast_srt_id            IN NUMBER,
                                p_lq_struct_pricing     IN VARCHAR2,
                                p_ast_struct_pricing    IN VARCHAR2,
                                p_lq_arrears_yn         IN VARCHAR2,
                                p_ast_arrears_yn        IN VARCHAR2,
                                x_return_status         OUT NOCOPY VARCHAR2)
   RETURN BOOLEAN
  AS
    l_api_name           CONSTANT VARCHAR2(30) DEFAULT 'is_asset_overriding';
    l_return_status               VARCHAR2(1);
    l_ret_value                   BOOLEAN;
  BEGIN

    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_ret_value := FALSE;
    IF p_lq_line_level_pricing = 'Y' AND
       p_lq_struct_pricing IS NULL AND
       p_lq_srt_id IS NULL
    THEN
      -- User opted for Line level override, havent picked Structured Pricing at Quote level
      -- and havent picked SRT too at quote level. This means all assets are overriding
      l_ret_value := TRUE;
    ELSIF p_lq_line_level_pricing IS NULL OR
       p_lq_line_level_pricing = 'N'
    THEN
      l_ret_value := FALSE;
    ELSIF p_lq_struct_pricing = 'Y' AND
          p_ast_struct_pricing = 'Y'
    THEN
      -- Case 1: Two scenarios possible here !
      -- Lq has a structured payment structure and Asset follows another structured payment structure
      IF p_lq_line_level_pricing = 'Y'
      THEN
        l_ret_value := TRUE;
      ELSE
        l_ret_value := FALSE;
      END IF;
    ELSIF p_lq_struct_pricing = 'Y' AND
          ( p_ast_struct_pricing = 'N' OR p_ast_srt_id IS NOT NULL )
    THEN
      -- Case 2: LQ with Structured Pricing and Asset linked to SRT
      l_ret_value := TRUE;
    ELSIF p_ast_struct_pricing = 'Y' AND
          ( p_lq_struct_pricing = 'N' OR p_lq_srt_id IS NOT NULL )
    THEN
      -- Case 3: LQ linked to SRT and Asset following Strucured Pricing
      l_ret_value := TRUE;
    ELSIF p_lq_srt_id IS NOT NULL AND
          p_ast_srt_id IS NOT NULL AND
          p_lq_srt_id <> p_ast_srt_id
    THEN
      -- Case 4: User picked the SRT at the quote level and at the Asset level
      --         also, user picked another SRT !
      l_ret_value := TRUE;
    ELSIF p_lq_srt_id IS NOT NULL AND
          p_ast_srt_id IS NOT NULL AND
          p_lq_srt_id = p_ast_srt_id AND
          nvl(p_lq_arrears_yn, 'N') <> nvl(p_ast_arrears_yn, 'N')
    THEN
      -- Case 5: User picked the same SRT at Quote and Asset level,
      -- but varied Advance/Arrears
      l_ret_value := TRUE;
    ELSIF p_lq_srt_id IS NOT NULL AND
          p_ast_srt_id IS NOT NULL AND
          p_lq_line_level_pricing = 'Y'
    THEN
      -- Case 6: User picked the same SRT at Quote and Asset level.
      -- Returning TRUE in this case also, as User picked the same SRT explicitly
      -- but enabling the Line Level Override.
      l_ret_value := TRUE;
    END IF;
    x_return_status := l_return_status;
    return l_ret_value;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS
    THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END is_asset_overriding;

  -- Bug 7440199: Quote Streams ER: RGOOTY: Start
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_lq_srvc_cash_flows
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : RGOOTY   27-May-2008 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE get_lq_srvc_cash_flows(
              p_api_version      IN          NUMBER,
              p_init_msg_list    IN          VARCHAR2,
              x_return_status    OUT NOCOPY  VARCHAR2,
              x_msg_count        OUT NOCOPY  NUMBER,
              x_msg_data         OUT NOCOPY  VARCHAR2,
              p_srvc_type        IN          VARCHAR2,
              p_lq_id            IN          NUMBER,
              p_srvc_id          IN          NUMBER,
              x_inflow_caf_rec   OUT NOCOPY  so_cash_flows_rec_type,
              x_inflow_cfl_tbl   OUT NOCOPY  so_cash_flow_details_tbl_type)
  IS
    -- Cursor to fetch the Lease Quotes Cash Flow Details
    CURSOR lq_cash_flows_csr(
             p_id        NUMBER,
             p_cf_source VARCHAR2,
             p_cft_code  VARCHAR2)
    IS
      SELECT   cf.id  caf_id
              ,dnz_khr_id khr_id
              ,dnz_qte_id qte_id
              ,cfo_id cfo_id
              ,sts_code sts_code
              ,sty_id sty_id
              ,cft_code cft_code
              ,due_arrears_yn due_arrears_yn
              ,start_date start_date
              ,number_of_advance_periods number_of_advance_periods
              ,cfo.oty_code oty_code
      FROM    OKL_CASH_FLOWS         cf,
              OKL_CASH_FLOW_OBJECTS  cfo
     WHERE    cf.cfo_id        = cfo.id
       AND    cfo.source_table = p_cf_source
       AND    cfo.source_id    = p_id
       AND    cf .cft_code     = p_cft_code ;

    -- Cursor to fetch the Cash Flow Details
    CURSOR cash_flow_levels_csr( p_caf_id NUMBER )
    IS
      SELECT  id cfl_id
             ,caf_id
             ,fqy_code
             ,rate  -- No rate is defined at Cash Flows Level.. Need to confirm
             ,stub_days
             ,stub_amount
             ,number_of_periods
             ,amount
             ,start_date
        FROM OKL_CASH_FLOW_LEVELS
       WHERE caf_id = p_caf_id
      ORDER BY start_date;

    l_api_version        CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name           CONSTANT VARCHAR2(30) DEFAULT 'get_lq_srvc_cash_flows';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);

    l_debug_enabled             VARCHAR2(10);
    is_debug_procedure_on       BOOLEAN;
    is_debug_statement_on       BOOLEAN;
    cfl_index                   NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  '!!!!! Fetching the Inflow Cash flows for service ' || p_srvc_type );

      FOR t_rec IN  lq_cash_flows_csr(
               p_id        => p_srvc_id,
               p_cf_source => 'OKL_SERVICES_B',
               p_cft_code  => 'PAYMENT_SCHEDULE')
      LOOP
        x_inflow_caf_rec.caf_id   := t_rec.caf_id;
        x_inflow_caf_rec.khr_id   := t_rec.khr_id;
        x_inflow_caf_rec.khr_id   := t_rec.khr_id;
        x_inflow_caf_rec.qte_id   := t_rec.qte_id;
        x_inflow_caf_rec.cfo_id   := t_rec.cfo_id;
        x_inflow_caf_rec.sts_code := t_rec.sts_code;
        x_inflow_caf_rec.sty_id   := t_rec.sty_id;
        x_inflow_caf_rec.cft_code := t_rec.cft_code;
        x_inflow_caf_rec.due_arrears_yn := t_rec.due_arrears_yn;
        x_inflow_caf_rec.start_date     := t_rec.start_date;
        x_inflow_caf_rec.number_of_advance_periods := t_rec.number_of_advance_periods;
        -- Use l_retun_status as a flag
        l_return_status := OKL_API.G_RET_STS_SUCCESS;
      END LOOP;
      -- Fetch the Cash Flow Levels information only if the Cash Flow is present..
      IF l_return_status = OKL_API.G_RET_STS_SUCCESS
      THEN
        cfl_index := 1;
        -- Cash Flows exists. So, fetch the Cash Flow Levels
        FOR t_rec in cash_flow_levels_csr( x_inflow_caf_rec.caf_id )
        LOOP
          x_inflow_cfl_tbl(cfl_index).cfl_id   := t_rec.cfl_id;
          x_inflow_cfl_tbl(cfl_index).caf_id   := t_rec.caf_id;
          x_inflow_cfl_tbl(cfl_index).fqy_code   := t_rec.fqy_code;
          x_inflow_cfl_tbl(cfl_index).rate       := t_rec.rate;
          x_inflow_cfl_tbl(cfl_index).stub_days   := t_rec.stub_days;
          x_inflow_cfl_tbl(cfl_index).stub_amount   := t_rec.stub_amount;
          x_inflow_cfl_tbl(cfl_index).number_of_periods   := t_rec.number_of_periods;
          x_inflow_cfl_tbl(cfl_index).amount := t_rec.amount;
          x_inflow_cfl_tbl(cfl_index).start_date := t_rec.start_date;
          x_inflow_cfl_tbl(cfl_index).locked_amt := 'Y';
          -- Remember the flag whether its a stub payment or not
          IF t_rec.stub_days IS NOT NULL and t_rec.stub_amount IS NOT NULL
          THEN
            -- Stub Payment
            x_inflow_cfl_tbl(cfl_index).is_stub := 'Y';
          ELSE
            -- Regular Periodic Payment
            x_inflow_cfl_tbl(cfl_index).is_stub := 'N';
          END IF;
          -- Use l_retun_status as a flag
          l_return_status := OKL_API.G_RET_STS_SUCCESS;
          -- Increment i
          cfl_index := cfl_index + 1;
        END LOOP;
      ELSE
        -- Show an error saying that no cash flow levels found
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  '!!!!! No Inflow Cash flow levels obtained for the service ' || p_srvc_type );
        OKL_API.SET_MESSAGE (
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_LLA_PMT_SELECT');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    -- Setting up the return variables
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_lq_srvc_cash_flows;
  --end bkatraga
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : Price_Standard_Quote
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : ssiruvol 22-May-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE get_lq_fee_cash_flows(
              p_api_version      IN          NUMBER,
              p_init_msg_list    IN          VARCHAR2,
              x_return_status    OUT NOCOPY  VARCHAR2,
              x_msg_count        OUT NOCOPY  NUMBER,
              x_msg_data         OUT NOCOPY  VARCHAR2,
              p_fee_type         IN          VARCHAR2,
              p_lq_id            IN          NUMBER,
              p_fee_id           IN          NUMBER,
              x_outflow_caf_rec  OUT NOCOPY  so_cash_flows_rec_type,
              x_outflow_cfl_tbl  OUT NOCOPY  so_cash_flow_details_tbl_type,
              x_inflow_caf_rec   OUT NOCOPY  so_cash_flows_rec_type,
              x_inflow_cfl_tbl   OUT NOCOPY  so_cash_flow_details_tbl_type)
  IS
    -- Cursor to fetch the Lease Quotes Cash Flow Details
    CURSOR lq_cash_flows_csr(
             p_id        NUMBER,
             p_cf_source VARCHAR2,
             p_cft_code  VARCHAR2)
    IS
      SELECT   cf.id  caf_id
              ,dnz_khr_id khr_id
              ,dnz_qte_id qte_id
              ,cfo_id cfo_id
              ,sts_code sts_code
              ,sty_id sty_id
              ,cft_code cft_code
              ,due_arrears_yn due_arrears_yn
              ,start_date start_date
              ,number_of_advance_periods number_of_advance_periods
              ,cfo.oty_code oty_code
      FROM    OKL_CASH_FLOWS         cf,
              OKL_CASH_FLOW_OBJECTS  cfo
     WHERE    cf.cfo_id        = cfo.id
       AND    cfo.source_table = p_cf_source
       AND    cfo.source_id    = p_id
       AND    cf .cft_code     = p_cft_code ;
    -- Cursor to fetch the Cash Flow Details
    CURSOR cash_flow_levels_csr( p_caf_id NUMBER )
    IS
      SELECT  id cfl_id
             ,caf_id
             ,fqy_code
             ,rate  -- No rate is defined at Cash Flows Level.. Need to confirm
             ,stub_days
             ,stub_amount
             ,number_of_periods
             ,amount
             ,start_date
        FROM OKL_CASH_FLOW_LEVELS
       WHERE caf_id = p_caf_id
      ORDER BY start_date;

    l_api_version        CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name           CONSTANT VARCHAR2(30) DEFAULT 'get_lq_fee_cash_flows';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);

    l_debug_enabled             VARCHAR2(10);
    is_debug_procedure_on       BOOLEAN;
    is_debug_statement_on       BOOLEAN;
    cfl_index                   NUMBER;
  BEGIN
   l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Expense Fees/Miscellaneous Fees will have OUTFLOW_SCHEDULE oty_code cash flows
    IF p_fee_type IN ( 'EXPENSE', 'MISCELLANEOUS' )
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  '!!!!! Fetching the Expense Cash flows for fee type ' || p_fee_type );
      FOR t_rec IN  lq_cash_flows_csr(
               p_id        => p_fee_id,
               p_cf_source => 'OKL_FEES_B',
               p_cft_code  => 'OUTFLOW_SCHEDULE')
      LOOP
        x_outflow_caf_rec.caf_id   := t_rec.caf_id;
        x_outflow_caf_rec.khr_id   := t_rec.khr_id;
        x_outflow_caf_rec.khr_id   := t_rec.khr_id;
        x_outflow_caf_rec.qte_id   := t_rec.qte_id;
        x_outflow_caf_rec.cfo_id   := t_rec.cfo_id;
        x_outflow_caf_rec.sts_code := t_rec.sts_code;
        x_outflow_caf_rec.sty_id   := t_rec.sty_id;
        x_outflow_caf_rec.cft_code := t_rec.cft_code;
        x_outflow_caf_rec.due_arrears_yn := t_rec.due_arrears_yn;
        x_outflow_caf_rec.start_date     := t_rec.start_date;
        x_outflow_caf_rec.number_of_advance_periods := t_rec.number_of_advance_periods;
        -- Use l_retun_status as a flag
        l_return_status := OKL_API.G_RET_STS_SUCCESS;
      END LOOP;
      -- Fetch the Cash Flow Levels information only if the Cash Flow is present..
      IF l_return_status = OKL_API.G_RET_STS_SUCCESS
      THEN
        cfl_index := 1;
        -- Cash Flows exists. So, fetch the Cash Flow Levels
        FOR t_rec in cash_flow_levels_csr( x_outflow_caf_rec.caf_id )
        LOOP
          x_outflow_cfl_tbl(cfl_index).cfl_id   := t_rec.cfl_id;
          x_outflow_cfl_tbl(cfl_index).caf_id   := t_rec.caf_id;
          x_outflow_cfl_tbl(cfl_index).fqy_code   := t_rec.fqy_code;
          x_outflow_cfl_tbl(cfl_index).rate       := t_rec.rate;
          x_outflow_cfl_tbl(cfl_index).stub_days   := t_rec.stub_days;
          x_outflow_cfl_tbl(cfl_index).stub_amount   := t_rec.stub_amount;
          x_outflow_cfl_tbl(cfl_index).number_of_periods   := t_rec.number_of_periods;
          x_outflow_cfl_tbl(cfl_index).amount := t_rec.amount;
          x_outflow_cfl_tbl(cfl_index).start_date := t_rec.start_date;
          x_outflow_cfl_tbl(cfl_index).locked_amt := 'Y';
          -- Remember the flag whether its a stub payment or not
          IF t_rec.stub_days IS NOT NULL and t_rec.stub_amount IS NOT NULL
          THEN
            -- Stub Payment
            x_outflow_cfl_tbl(cfl_index).is_stub := 'Y';
          ELSE
            -- Regular Periodic Payment
            x_outflow_cfl_tbl(cfl_index).is_stub := 'N';
          END IF;
          -- Use l_retun_status as a flag
          l_return_status := OKL_API.G_RET_STS_SUCCESS;
          -- Increment i
          cfl_index := cfl_index + 1;
        END LOOP;
      ELSE
        -- Show an error saying that no cash flow levels found
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  '!!!!! No Cash flow levels obtained for the fee type ' || p_fee_type );
        OKL_API.SET_MESSAGE (
          p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKL_AM_NO_PYMT_INFO');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- If p_fee_type = 'EXPENSE'/'MISCELLANEOUS'
    -- Income Fees/Security Deposit will have PAYMENT_SCHEDULE cash flows
    --  Miscellaneous Fees may have an inflow PAYMENT_SCHEDULE ( Not Mandatory for Payment )
    IF p_fee_type IN ( 'INCOME', 'SECDEPOSIT', 'MISCELLANEOUS' )
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  '!!!!! Fetching the Income Cash flows for fee type ' || p_fee_type );
      l_return_status := OKL_API.G_RET_STS_ERROR;
      FOR t_rec IN  lq_cash_flows_csr(
               p_id        => p_fee_id,
               p_cf_source => 'OKL_FEES_B',
               p_cft_code  => 'PAYMENT_SCHEDULE')
      LOOP
        x_inflow_caf_rec.caf_id   := t_rec.caf_id;
        x_inflow_caf_rec.khr_id   := t_rec.khr_id;
        x_inflow_caf_rec.khr_id   := t_rec.khr_id;
        x_inflow_caf_rec.qte_id   := t_rec.qte_id;
        x_inflow_caf_rec.cfo_id   := t_rec.cfo_id;
        x_inflow_caf_rec.sts_code := t_rec.sts_code;
        x_inflow_caf_rec.sty_id   := t_rec.sty_id;
        x_inflow_caf_rec.cft_code := t_rec.cft_code;
        x_inflow_caf_rec.due_arrears_yn := t_rec.due_arrears_yn;
        x_inflow_caf_rec.start_date     := t_rec.start_date;
        x_inflow_caf_rec.number_of_advance_periods := t_rec.number_of_advance_periods;
        -- Use l_retun_status as a flag
        l_return_status := OKL_API.G_RET_STS_SUCCESS;
      END LOOP;
      -- Fetch the Cash Flow Levels information only if the Cash Flow is present..
      IF l_return_status = OKL_API.G_RET_STS_SUCCESS
      THEN
        cfl_index := 1;
        -- Cash Flows exists. So, fetch the Cash Flow Levels
        FOR t_rec in cash_flow_levels_csr( x_inflow_caf_rec.caf_id )
        LOOP
          x_inflow_cfl_tbl(cfl_index).cfl_id   := t_rec.cfl_id;
          x_inflow_cfl_tbl(cfl_index).caf_id   := t_rec.caf_id;
          x_inflow_cfl_tbl(cfl_index).fqy_code   := t_rec.fqy_code;
          x_inflow_cfl_tbl(cfl_index).rate       := t_rec.rate;
          x_inflow_cfl_tbl(cfl_index).stub_days   := t_rec.stub_days;
          x_inflow_cfl_tbl(cfl_index).stub_amount   := t_rec.stub_amount;
          x_inflow_cfl_tbl(cfl_index).number_of_periods   := t_rec.number_of_periods;
          x_inflow_cfl_tbl(cfl_index).amount := t_rec.amount;
          x_inflow_cfl_tbl(cfl_index).start_date := t_rec.start_date;
          x_inflow_cfl_tbl(cfl_index).locked_amt := 'Y';
          -- Remember the flag whether its a stub payment or not
          IF t_rec.stub_days IS NOT NULL and t_rec.stub_amount IS NOT NULL
          THEN
            -- Stub Payment
            x_inflow_cfl_tbl(cfl_index).is_stub := 'Y';
          ELSE
            -- Regular Periodic Payment
            x_inflow_cfl_tbl(cfl_index).is_stub := 'N';
          END IF;
          -- Use l_retun_status as a flag
          l_return_status := OKL_API.G_RET_STS_SUCCESS;
          -- Increment i
          cfl_index := cfl_index + 1;
        END LOOP;
      ELSE
        -- Show an error saying that no cash flow levels found
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  '!!!!! No Cash flow levels obtained for the fee type ' || p_fee_type );
        IF p_fee_type <>  'MISCELLANEOUS'
        THEN
          OKL_API.SET_MESSAGE (
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_LLA_PMT_SELECT');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END IF; -- If p_fee_type = 'INCOME'/'SECDEPOSIT'/'MISCELLANEOUS'
    -- Setting up the return variables
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END get_lq_fee_cash_flows;
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : solve_pmnts_at_lq
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 6-Mar-20006 Created.
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE solve_pmnts_at_lq(
             p_api_version          IN            NUMBER,
             p_init_msg_list        IN            VARCHAR2,
             x_return_status           OUT NOCOPY VARCHAR2,
             x_msg_count               OUT NOCOPY NUMBER,
             x_msg_data                OUT NOCOPY VARCHAR2,
             p_id                   IN            NUMBER,
             x_caf_rec                 OUT NOCOPY OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_header_rec_type,
             x_cfl_tbl                 OUT NOCOPY OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_tbl_type,
             x_solved                  OUT NOCOPY VARCHAR2)
  IS
    -- Cursor to fetch all the Assets in a Lease Quote
    CURSOR all_assets_csr( p_qte_id IN okl_lease_quotes_b.id%TYPE)
    IS
      SELECT ast.id               ast_id,
             ast.asset_number ast_number
        FROM okl_assets_b ast,
             okl_lease_quotes_b qte
       WHERE ast.parent_object_code = 'LEASEQUOTE'
         AND ast.parent_object_id = qte.id
         AND qte.id = p_qte_id;
    all_assets_rec       all_assets_csr%ROWTYPE;
    -- Cursor to fetch the payment structure defined/derieved of an asset
    CURSOR ast_payments_csr( p_ast_id OKL_ASSETS_B.ID%TYPE,
                             p_qte_id OKL_LEASE_QUOTES_B.ID%TYPE)
    IS
      SELECT cfl.fqy_code frequency,
             caf.due_arrears_yn adv_arrears,
             caf.sty_id sty_id,
             cfl.start_date,
             cfl.rate,
             cfl.stub_days,
             cfl.stub_amount,
             cfl.number_of_periods periods,
             cfl.amount periodic_amount
       FROM  okl_assets_b ast,
             okl_cash_flow_objects cfo,
             okl_cash_flows caf,
             okl_cash_flow_levels cfl,
             okl_strm_type_b sty
       WHERE ast.id = p_ast_id
         AND ast.parent_object_id = p_qte_id
         AND cfo.source_id = ast.id
         AND caf.cfo_id = cfo.id
         AND cfl.caf_id = caf.id
         AND cfo.source_table = 'OKL_ASSETS_B'
         AND cfo.oty_code = 'QUOTED_ASSET'
         AND caf.sts_code IN ( 'CURRENT', 'WORK')
         AND caf.sty_id = sty.id
         AND sty.stream_type_purpose = 'RENT'
       ORDER BY cfl.start_date;
    ast_payments_rec            ast_payments_csr%ROWTYPE;
    -- Local Variables Declaration
    l_api_version        CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name           CONSTANT VARCHAR2(30) DEFAULT 'solve_pmnts_at_lq';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);

    l_debug_enabled             VARCHAR2(10);
    is_debug_procedure_on       BOOLEAN;
    is_debug_statement_on       BOOLEAN;
    i                           NUMBER;
    l_first                     BOOLEAN;
    l_caf_rec                   OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_header_rec_type;
    l_cfl_tbl                   OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_tbl_type;
    l_solved                    VARCHAR2(30);
  BEGIN
   l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => x_return_status);
    --Check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Actual logic starts here
    l_first     := TRUE;
    l_solved    := 'YES';
    FOR ast_rec IN all_assets_csr( p_qte_id => p_id)
    LOOP
      i := 1;
      IF l_first
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          ' FIRST ONE : Frequency | Adv/Arrears | Rate | Days | Amount | Periods | Periodic Amount ' );
        FOR cfl_rec IN ast_payments_csr( p_ast_id => ast_rec.ast_id,
                                         p_qte_id => p_id)
        LOOP
          -- Store them in the Cash flows and Cash Flow Levels
          l_caf_rec.frequency_code     := cfl_rec.frequency;
          l_caf_rec.arrears_flag       := cfl_rec.adv_arrears;
          l_caf_rec.stream_type_id     := cfl_rec.sty_id;
          l_cfl_tbl(i).record_mode     := 'CREATE';
          l_cfl_tbl(i).start_date      := cfl_rec.start_date;
          l_cfl_tbl(i).rate            := cfl_rec.rate;
          l_cfl_tbl(i).stub_days       := cfl_rec.stub_days;
          l_cfl_tbl(i).stub_amount     := cfl_rec.stub_amount;
          l_cfl_tbl(i).periods         := cfl_rec.periods;
          l_cfl_tbl(i).periodic_amount := cfl_rec.periodic_amount;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            cfl_rec.frequency || ' | ' || cfl_rec.adv_arrears || ' | ' || cfl_rec.rate || ' | ' ||
            cfl_rec.stub_days || ' | ' || cfl_rec.stub_amount || ' | ' ||
            cfl_rec.periods || ' | ' || cfl_rec.periodic_amount );
          i := i + 1;
          l_first := FALSE;
        END LOOP;
      ELSE
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          ' Frequency | Adv/Arrears | Rate | Days | Amount | Periods | Periodic Amount ' );
        FOR cfl_rec IN ast_payments_csr( p_ast_id => ast_rec.ast_id,
                                         p_qte_id => p_id)
        LOOP
          -- Compare with the previous cash flow levels
          IF l_cfl_tbl.EXISTS(i) AND (
             l_caf_rec.frequency_code         = cfl_rec.frequency AND
             nvl(l_caf_rec.arrears_flag,'N')  = nvl(cfl_rec.adv_arrears, 'N') AND
             l_cfl_tbl(i).start_date          = cfl_rec.start_date AND
             nvl(l_cfl_tbl(i).stub_days,-1)   = nvl(cfl_rec.stub_days, -1) AND
             nvl(l_cfl_tbl(i).periods, -1)    = nvl(cfl_rec.periods, -1) )
          THEN
            l_cfl_tbl(i).stub_amount     := l_cfl_tbl(i).stub_amount     + cfl_rec.stub_amount;
            l_cfl_tbl(i).periodic_amount := l_cfl_tbl(i).periodic_amount + cfl_rec.periodic_amount;
          ELSE
            l_solved := 'NO';
            EXIT;
          END IF;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            cfl_rec.frequency || ' | ' || cfl_rec.adv_arrears || ' | ' || cfl_rec.rate || ' | ' ||
            l_cfl_tbl(i).stub_days || ' | ' || cfl_rec.stub_amount || ' | ' ||
            cfl_rec.periods || ' | ' || cfl_rec.periodic_amount );
          i := i + 1;
        END LOOP; -- Loop on the ast_payments_csr
      END IF; -- IF l_first
      EXIT WHEN l_solved = 'NO';
    END LOOP; -- Loop on the Assets
    x_caf_rec := l_caf_rec;
    x_cfl_tbl := l_cfl_tbl;
    x_solved  := l_solved;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'end debug OKLRPIUB.pls call ' || LOWER(l_api_version) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END solve_pmnts_at_lq;

  -- Bug 7440199: Quote Streams ER: RGOOTY: Start
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : delete_quote_streams
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : RGOOTY   27-May-2009 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE delete_quote_streams(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quote_id                     IN NUMBER
    ) IS

   l_return_status      VARCHAR2(1):= G_RET_STS_SUCCESS;
   l_api_name           CONSTANT VARCHAR2(30) DEFAULT 'delete_quote_streams';
   l_api_version        CONSTANT NUMBER  DEFAULT 1.0;
   l_strm_elements_tbl  OKL_QSL_PVT.qsl_tbl_type;
   l_streams_tbl        OKL_QSH_PVT.qsh_tbl_type;
   p_index              NUMBER;

   CURSOR get_strm_elements_csr IS
    SELECT QTE_SEL.QUOTE_STRM_ELEMENT_ID
      FROM OKL_QUOTE_STREAMS QTE_STM,
           OKL_QUOTE_STRM_ELEMENTS QTE_SEL
     WHERE QTE_STM.QUOTE_STREAM_ID = QTE_SEL.QUOTE_STREAM_ID
       AND QTE_STM.QUOTE_ID = p_quote_id;

   CURSOR get_streams_csr IS
    SELECT QTE_STM.QUOTE_STREAM_ID
      FROM OKL_QUOTE_STREAMS QTE_STM
     WHERE QTE_STM.QUOTE_ID = p_quote_id;

  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => l_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    p_index := 1;
    FOR strm_element_rec IN get_strm_elements_csr
    LOOP
      l_strm_elements_tbl(p_index).quote_strm_element_id := strm_element_rec.QUOTE_STRM_ELEMENT_ID;
      p_index := p_index + 1;
    END LOOP;
    IF(l_strm_elements_tbl.COUNT > 0) THEN
       OKL_QSL_PVT.delete_row(p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_qsl_tbl       => l_strm_elements_tbl
                              );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;

    p_index := 1;
    FOR strm_rec IN get_streams_csr
    LOOP
      l_streams_tbl(p_index).quote_stream_id := strm_rec.QUOTE_STREAM_ID;
      p_index := p_index + 1;
    END LOOP;
    IF(l_streams_tbl.COUNT > 0) THEN
       OKL_QSH_PVT.delete_row(p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_qsh_tbl       => l_streams_tbl
                              );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END delete_quote_streams;
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : insert_quote_streams
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : RGOOTY   27-May-2009 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE insert_quote_streams(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quote_id                     IN NUMBER,
    p_quote_type                   IN VARCHAR2,
    p_currency                     IN VARCHAR2,
    p_pricing_param_tbl            IN OKL_PRICING_UTILS_PVT.pricing_parameter_tbl_type
    ) IS

   l_return_status      VARCHAR2(1):= G_RET_STS_SUCCESS;
   l_sty_id             OKL_STRM_TYPE_B.ID%TYPE;
   l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'insert_quote_streams';
   l_pricing_param_tbl  OKL_PRICING_UTILS_PVT.pricing_parameter_tbl_type;
   l_stm_id             NUMBER;
   l_sel_id             NUMBER;
   l_residual_sty_id    OKL_STRM_TYPE_B.ID%TYPE;
   l_residual_count     NUMBER;
   l_residual_amt       NUMBER;
   l_api_version        CONSTANT NUMBER  DEFAULT 1.0;
   l_sel_amount         NUMBER;
   l_stream_rec         OKL_QSH_PVT.qsh_rec_type;
   x_stream_rec         OKL_QSH_PVT.qsh_rec_type;
   l_stm_element_rec    OKL_QSL_PVT.qsl_rec_type;
   x_stm_element_rec    OKL_QSL_PVT.qsl_rec_type;
   l_stm_element_tbl    OKL_QSL_PVT.qsl_tbl_type;
   x_stm_element_tbl    OKL_QSL_PVT.qsl_tbl_type;
   p_index              NUMBER;
   l_product_type       VARCHAR2(30);

   CURSOR get_quote_details_csr IS
     SELECT LSE_QT.PRODUCT_ID,
            LSE_QT.EXPECTED_START_DATE,
            PDT.DEAL_TYPE
       FROM OKL_LEASE_QUOTES_B LSE_QT,
            OKL_PRODUCT_PARAMETERS_V PDT
      WHERE LSE_QT.PRODUCT_ID = PDT.ID
        AND LSE_QT.ID = p_quote_id;

   quote_det_rec   get_quote_details_csr%ROWTYPE;

   CURSOR header_info_csr(p_cfo_id OKL_CASH_FLOW_OBJECTS.ID%TYPE) IS
     SELECT OTY_CODE,
            SOURCE_TABLE,
            SOURCE_ID,
            STY_ID,
            CFT_CODE
       FROM OKL_CASH_FLOW_OBJECTS CFLOW_OBJ,
            OKL_CASH_FLOWS CFLOW
      WHERE CFLOW.CFO_ID = CFLOW_OBJ.ID
        AND CFLOW_OBJ.ID = p_cfo_id;

   header_info_rec   header_info_csr%ROWTYPE;

   CURSOR residual_sty_csr (l_product_id NUMBER, l_start_date DATE) IS
     SELECT PRIMARY_STY_ID
       FROM OKL_STRM_TMPT_LINES_UV STL
      WHERE STL.PRIMARY_YN = 'Y'
        AND STL.PDT_ID = l_product_id
        AND (STL.START_DATE <= l_start_date)
        AND (STL.END_DATE >= l_start_date OR STL.END_DATE IS NULL)
        AND	PRIMARY_STY_PURPOSE = 'RESIDUAL_VALUE';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                     || G_PKG_NAME || '.' || UPPER(l_api_name);
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
  BEGIN
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    -- check for logging on STATEMENT level
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => l_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'Executing the API ' || l_api_name );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'P_QUOTE_ID=' || P_QUOTE_ID || ' P_QUOTE_TYPE=' || p_quote_type || ' p_currency=' || p_currency  );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Before Executing the Cursor get_quote_details_csr');
    OPEN get_quote_details_csr;
    FETCH get_quote_details_csr INTO quote_det_rec;
    IF (get_quote_details_csr%NOTFOUND) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    CLOSE get_quote_details_csr;

    l_product_type := quote_det_rec.DEAL_TYPE;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Sucessfully executed the Cursor get_quote_details_csr. l_product_type=' || l_product_type);

    l_pricing_param_tbl := p_pricing_param_tbl;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'l_pricing_param_tbl.COUNT=' || l_pricing_param_tbl.COUNT );
    IF l_pricing_param_tbl.COUNT > 0 THEN
      FOR k IN l_pricing_param_tbl.FIRST .. l_pricing_param_tbl.LAST
      LOOP
         put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           'Index = ' || k || ' l_pricing_param_tbl(k).line_type= ' || l_pricing_param_tbl(k).line_type );
         IF(l_pricing_param_tbl(k).line_type IS NOT NULL)
         THEN
           put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
             'Before Executing the Cursor header_info_csr. l_pricing_param_tbl(k).cfo_id= ' || l_pricing_param_tbl(k).cfo_id );
           OPEN header_info_csr(l_pricing_param_tbl(k).cfo_id);
           FETCH header_info_csr INTO header_info_rec;
           IF (header_info_csr%NOTFOUND) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           END IF;
           CLOSE header_info_csr;
           put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
             'After Executing the Cursor header_info_csr. header_info_rec.CFT_CODE= ' || header_info_rec.CFT_CODE );
           IF(header_info_rec.CFT_CODE <> 'OUTFLOW_SCHEDULE')
           THEN
             l_stream_rec.object_version_number := 1;
             l_stream_rec.quote_type := p_quote_type;
             l_stream_rec.quote_id := p_quote_id;
             l_stream_rec.oty_code := header_info_rec.OTY_CODE;
             l_stream_rec.source_id := header_info_rec.SOURCE_ID;
             l_stream_rec.source_table := header_info_rec.SOURCE_TABLE;
             l_stream_rec.sty_id := header_info_rec.STY_ID;
             l_stream_rec.link_asset_id := l_pricing_param_tbl(k).link_asset_id; --Added by bkatraga for bug 7410991

             l_stream_rec.say_code := 'CURR';
             put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Before Calling the API OKL_QSH_PVT.insert_row ' );
             --Inserting the stream header
             OKL_QSH_PVT.insert_row(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => l_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_qsh_rec       => l_stream_rec,
                                    x_qsh_rec       => x_stream_rec
                                    );
             put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'After Calling the API OKL_QSH_PVT.insert_row ' || l_return_status );
             IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             p_index := 1;
             l_stm_element_tbl.delete;
             IF(l_pricing_param_tbl(k).cash_inflows.COUNT > 0)
             THEN
               FOR m IN l_pricing_param_tbl(k).cash_inflows.FIRST .. l_pricing_param_tbl(k).cash_inflows.LAST
               LOOP
                  l_sel_amount := okl_accounting_util.round_amount(p_amount => l_pricing_param_tbl(k).cash_inflows(m).cf_amount,
                                                                   p_currency_code => p_currency);
                  l_stm_element_tbl(p_index).quote_stream_id := x_stream_rec.quote_stream_id;
                  l_stm_element_tbl(p_index).object_version_number := 1;
                  l_stm_element_tbl(p_index).stream_element_date := l_pricing_param_tbl(k).cash_inflows(m).cf_date;
                  l_stm_element_tbl(p_index).amount := l_sel_amount;
                  p_index := p_index + 1;
               END LOOP;
             END IF;
             --Inserting the stream elements
             put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Before Calling the API OKL_QSL_PVT.insertv_tbl ' );
             OKL_QSL_PVT.insert_row(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => l_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_qsl_tbl       => l_stm_element_tbl,
                                    x_qsl_tbl       => x_stm_element_tbl
                                    );
             put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'After Calling the API OKL_QSL_PVT.insertv_tbl x_return_status=' || l_return_status );
             IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             --Residual streams
             IF((l_pricing_param_tbl(k).residual_inflows.COUNT > 0) AND
               (l_product_type IN('LEASEDF','LEASEOP','LEASEST')))
             THEN
                put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Before executing the cursor residual_sty_csr ' );
                OPEN residual_sty_csr(quote_det_rec.product_id, quote_det_rec.EXPECTED_START_DATE);
                FETCH residual_sty_csr INTO l_residual_sty_id;
                IF (residual_sty_csr%NOTFOUND) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                END IF;
                CLOSE residual_sty_csr;
                put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After executing the cursor residual_sty_csr ' );
                l_stream_rec.object_version_number := 1;
                l_stream_rec.quote_type := p_quote_type;
                l_stream_rec.quote_id := p_quote_id;
                l_stream_rec.oty_code := header_info_rec.OTY_CODE;
                l_stream_rec.source_id := header_info_rec.SOURCE_ID;
                l_stream_rec.source_table := header_info_rec.SOURCE_TABLE;
                l_stream_rec.sty_id := l_residual_sty_id;
                l_stream_rec.say_code := 'CURR';
                --Inserting the residual stream header
                put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Before executing the API  OKL_QSH_PVT.insert_row ' );
                OKL_QSH_PVT.insert_row(p_api_version   => p_api_version,
                                       p_init_msg_list => p_init_msg_list,
                                       x_return_status => l_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data,
                                       p_qsh_rec       => l_stream_rec,
                                       x_qsh_rec       => x_stream_rec
                                       );
                put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After executing the API  OKL_QSH_PVT.insert_row. x_return_status=' || l_return_status );
                IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                l_residual_count := l_pricing_param_tbl(k).residual_inflows.COUNT;
                l_residual_amt   := 0;
                FOR m IN l_pricing_param_tbl(k).residual_inflows.FIRST .. l_pricing_param_tbl(k).residual_inflows.LAST
                LOOP
                   IF((header_info_rec.OTY_CODE = 'LEASE_QUOTE') AND (m <> l_residual_count)) THEN
                     l_residual_amt := l_residual_amt + l_pricing_param_tbl(k).residual_inflows(m).cf_amount;
                   ELSE
                     l_sel_amount := l_pricing_param_tbl(k).residual_inflows(m).cf_amount + l_residual_amt;
                     l_sel_amount := okl_accounting_util.round_amount(p_amount => l_sel_amount,
                                                                      p_currency_code => p_currency);

                     l_stm_element_rec.quote_stream_id := x_stream_rec.quote_stream_id;
                     l_stm_element_rec.object_version_number := 1;
                     l_stm_element_rec.stream_element_date := l_pricing_param_tbl(k).residual_inflows(m).cf_date;
                     l_stm_element_rec.amount := l_sel_amount;
                     --Inserting the stream element
                     put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       'Before executing the API  OKL_QSL_PVT.insert_row. ' );
                     OKL_QSL_PVT.insert_row(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_qsl_rec       => l_stm_element_rec,
                                            x_qsl_rec       => x_stm_element_rec
                                           );
                     put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       'After executing the API  OKL_QSL_PVT.insert_row. x_return_status=' || l_return_status );
                     IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                     END IF;
                   END IF;
                END LOOP; -- residual_inflows loop
              END IF; --Residual streams IF
           END IF; --OUTFLOW_SCHEDULE IF
         END IF; --line type IF
      END LOOP;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Returning from the API ' || l_api_name || ' with x_return_status = ' || l_return_status );
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END insert_quote_streams;
  -- Bug 7440199: Quote Streams ER: RGOOTY: End
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : Price_Standard_Quote
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : ssiruvol 22-May-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE price_standard_quote(x_return_status                  OUT NOCOPY  VARCHAR2,
                                 x_msg_count                      OUT NOCOPY  NUMBER,
                                 x_msg_data                       OUT NOCOPY  VARCHAR2,
                                 p_api_version                 IN             NUMBER,
                                 p_init_msg_list               IN             VARCHAR2,
                                 p_qte_id                      IN             NUMBER)
  IS
    l_api_version        CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name           CONSTANT VARCHAR2(30) DEFAULT 'price_standard_quote';
    l_return_status               VARCHAR2(1);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'LEASE.ACCOUNTING.PRICING.'
                      || G_PKG_NAME || '.' || UPPER(l_api_name);

    l_debug_enabled             VARCHAR2(10);
    is_debug_procedure_on       BOOLEAN;
    is_debug_statement_on       BOOLEAN;
    -- Cursors declaration !
    -- Cursor to fetch the Lease Quote Header details
    CURSOR quote_csr(qteid                          NUMBER)
    IS
      SELECT qte.term term,
             qte.pricing_method,
             qte.rate_template_id,
             qte.expected_start_date,
             qte.expected_delivery_date,
             qte.structured_pricing structured_pricing,
             qte.line_level_pricing line_level_pricing,
             qte.target_rate_type target_rate_type,
             qte.target_frequency target_frequency,
             qte.target_arrears_yn target_arrears,
             qte.target_rate target_rate,
             qte.target_periods target_periods,
             qte.lease_rate_factor,
             qte.rate_card_id,
             qte.id,
             qte.parent_object_code,
             qte.parent_object_id,
             qte.object_version_number,
             qte.reference_number,
             qte.product_id
        FROM okl_lease_quotes_b qte
       WHERE qte.id = qteid;
    quote_rec                    quote_csr%ROWTYPE;

    CURSOR c_strm_type ( qteID NUMBER, expStartDate DATE) IS
    SELECT STRM.STY_ID PAYMENT_TYPE_ID,
           STRM.STY_NAME PAYMENT_TYPE,
           STRM.START_DATE,
           STRM.END_DATE,
           STRM.STY_PURPOSE
    FROM OKL_STRM_TMPT_PRIMARY_UV STRM,
         OKL_LEASE_QUOTES_B QUOTE
    WHERE STY_PURPOSE = 'RENT'
            AND START_DATE <= expStartDate
            AND NVL(END_DATE, expStartDate) >= expStartDate
            AND STRM.PDT_ID = QUOTE.PRODUCT_ID
            AND QUOTE.ID = qteID;

    r_strm_type                    c_strm_type%ROWTYPE;

    l_lrs_details          lrs_details_rec_type;
    l_lrs_factor           lrs_factor_rec_type;
    l_lrs_levels           lrs_levels_tbl_type;

    l_ac_rec_type          OKL_EC_EVALUATE_PVT.okl_ac_rec_type;
    l_adj_factor           NUMBER;
    l_months_per_period    NUMBER;
    l_months_after         NUMBER;
    cf_index               NUMBER; -- Using as an index for Cash flow levels
    -- Cursor to fetch all the Asset and Rollover and Financed fee Details included in the Lease Quote
    CURSOR assets_csr(qteid  NUMBER)
    IS
      SELECT ast.asset_number,
             ast.id ast_id,
             TO_NUMBER(NULL) fee_id,
             ast.rate_card_id,
             ast.rate_template_id rate_template_id,
             ast.structured_pricing,
             'FREE_FORM1' fee_type,
             TO_NUMBER(NULL) fee_amount,
             qte.expected_start_date line_start_date,
             qte.expected_delivery_date line_end_date,
             ast.lease_rate_factor lease_rate_factor,
             ast.target_arrears    target_arrears,
             ast.oec_percentage oec_percentage
        FROM okl_assets_b ast,
             okl_lease_quotes_b qte
       WHERE ast.parent_object_code = 'LEASEQUOTE'
         AND ast.parent_object_id = qte.id
         AND qte.id = qteid
     UNION
       SELECT NULL asset_number,
              TO_NUMBER(NULL) ast_id,
              fee.id fee_id,
              fee.rate_card_id,
              fee.rate_template_id,
              fee.structured_pricing,
              fee.fee_type,
              fee.fee_amount,
              fee.effective_from line_start_date,
              fee.effective_to line_end_date,
              fee.lease_rate_factor lease_rate_factor,
              fee.target_arrears    target_arrears,
              NULL oec_percentage
        FROM okl_fees_b fee,
             okl_lease_quotes_b qte
        WHERE fee.parent_object_code = 'LEASEQUOTE'
          AND fee.parent_object_id = qte.id
          AND qte.id = qteid;
    assets_rec                   assets_csr%ROWTYPE;

    -- Bug 7440199: Quote Streams ER: RGOOTY: Start
    CURSOR services_csr(qteid  NUMBER)
    IS
      SELECT srvc.id srvc_id,
             srvc.effective_from line_start_date
        FROM okl_services_b srvc,
             okl_lease_quotes_b qte
       WHERE srvc.parent_object_code = 'LEASEQUOTE'
         AND srvc.parent_object_id = qte.id
         AND qte.id = qteid;

    l_srvc_inflow_caf_rec        so_cash_flows_rec_type;
    l_srvc_inflow_cfl_tbl        so_cash_flow_details_tbl_type;
    -- Bug 7440199: Quote Streams ER: RGOOTY: End
    -- Cursor to fetch the Asset Component Details
    CURSOR asset_adj_csr(qteid    NUMBER,
                         astid    NUMBER)
    IS
      SELECT ast.asset_number,
             ast.install_site_id,
             ast.rate_card_id,
             ast.rate_template_id,
             ast.oec,
             nvl(nvl(ast.end_of_term_value, ast.end_of_term_value_default),0) end_of_term_value,
             ast.oec_percentage,
             cmp.unit_cost,
             cmp.number_of_units,
             cmp.primary_component
        FROM okl_assets_b ast,
             okl_lease_quotes_b qte,
             okl_asset_components_b cmp
       WHERE ast.parent_object_code = 'LEASEQUOTE' AND
             ast.parent_object_id = qte.id AND
             qte.id = qteid AND
             ast.id = astid AND
             cmp.primary_component = 'YES' AND
             cmp.asset_id = ast.id;
    -- Cursor to fetch the Asset Cost Adjustment Details
    CURSOR asset_cost_adj_csr(qteid        NUMBER,
                              astid        NUMBER)
    IS
      SELECT adj.adjustment_source_type,
             adj.adjustment_source_id,
             adj.basis,
             -- Start : DJANASWA : Bug# 6347118
             nvl(adj.value,adj.default_subsidy_amount) value
             -- End : DJANASWA : Bug# 6347118
        FROM okl_assets_b ast,
             okl_lease_quotes_b qte,
             okl_cost_adjustments_b adj
       WHERE ast.parent_object_code = 'LEASEQUOTE' AND
             ast.parent_object_id = qte.id AND
             qte.id = qteid AND
             ast.id = astid AND
             adj.parent_object_id = ast.id;

    Cursor subsidy_adj_csr( subId NUMBER)
    IS
       -- Bug 6622178 : Start
       -- Fetch the Subsidy Calculation Basis
       Select amount, SUBSIDY_CALC_BASIS
       -- Bug 6622178 : End
       From okl_subsidies_b
       where id = subId;
    subsidy_adj_rec subsidy_adj_csr%ROWTYPE;
    -- Cursor to fetch the Territory ID, Customer Credit Class
    CURSOR get_cust_details_csr( p_lq_id  NUMBER )
    IS
      SELECT  lopp.id                 parent_id
             ,lopp.prospect_id        prospect_id
             ,lopp.cust_acct_id       cust_acct_id
             ,lopp.sales_territory_id sales_territory_id
             ,lopp.currency_code      currency_code
      FROM   okl_lease_quotes_b  lq,
             okl_lease_opportunities_b lopp
      WHERE  parent_object_code = 'LEASEOPP'
       AND   parent_object_id = lopp.id
       AND   lq.id = p_lq_id;

    CURSOR get_cust_details_csr_lapp( p_lq_id  NUMBER )
    IS
      SELECT  lapp.id                 parent_id
             ,lapp.prospect_id        prospect_id
             ,lapp.cust_acct_id       cust_acct_id
             ,lapp.sales_territory_id sales_territory_id
             ,lapp.currency_code      currency_code
      FROM   okl_lease_quotes_b  lq,
             okl_lease_applications_b lapp
      WHERE  parent_object_code = 'LEASEAPP'
       AND   parent_object_id = lapp.id
       AND   lq.id = p_lq_id;
    -- Cursor for checking whether the CFO Exists or not
    CURSOR check_cfo_exists_csr(
      p_oty_code     IN VARCHAR2,
      p_source_table IN VARCHAR2,
      p_source_id    IN VARCHAR2,
      p_sts_code     IN VARCHAR2 )
    IS
      SELECT 'YES' cfo_exists,
             cfo.id cfo_id,
             caf.id caf_id
       FROM  OKL_CASH_FLOW_OBJECTS cfo,
             OKL_CASH_FLOWS caf
      WHERE  OTY_CODE     = p_oty_code
       AND   SOURCE_TABLE = p_source_table
       AND   SOURCE_ID    = p_source_id
       AND   caf.cfo_id = cfo.id;
    check_cfo_exists_rec         check_cfo_exists_csr%ROWTYPE;
    -- Cursor to fetch EOT Type
    CURSOR get_eot_type( p_lq_id NUMBER )
    IS
      SELECT  lq.id
         ,lq.reference_number
         ,eot.end_of_term_name
         ,eot.eot_type_code eot_type_code
         ,eot.end_of_term_id end_of_term_id
         ,eotversion.end_of_term_ver_id
     FROM OKL_LEASE_QUOTES_B lq,
          okl_fe_eo_term_vers eotversion,
          okl_fe_eo_terms_all_b eot
     WHERE lq.END_OF_TERM_OPTION_ID = eotversion.end_of_term_ver_id
       AND eot.end_of_term_id = eotversion.end_of_term_id
       AND lq.id = p_lq_id;
    l_eot_type_code             VARCHAR2(30);
    -- Cursor to handle the CAPITALIZED Fee amount for each Asset
    CURSOR get_asset_cap_fee_amt(p_source_type VARCHAR2,
                             p_source_id         OKL_LINE_RELATIONSHIPS_B.source_line_ID%TYPE,
                             p_related_line_type OKL_LINE_RELATIONSHIPS_B.related_line_type%TYPE)
    IS
      SELECT SUM(amount) capitalized_amount
        FROM okl_line_relationships_v lre
       WHERE source_line_type = p_source_type
        AND related_line_type = 'CAPITALIZED'
        AND source_line_id = p_source_id;

    --Bug 5884825 PAGARG start
    CURSOR product_name_csr(qteid  NUMBER)
    IS
      SELECT PDT.NAME PRODUCTNAME
      FROM OKL_LEASE_QUOTES_B QTE
         , OKL_PRODUCTS PDT
      WHERE QTE.PRODUCT_ID = PDT.ID
        AND QTE.ID = qteid;
    --Bug 5884825 PAGARG end

    l_product_name               okl_products.NAME%TYPE;--Bug 5884825 PAGARG
    l_day_count_method           VARCHAR2(30);
    l_days_in_month              VARCHAR2(30);
    l_days_in_year               VARCHAR2(30);
    l_currency                   VARCHAR2(30);
    l_srt_details                OKL_PRICING_UTILS_PVT.srt_details_rec_type;
    l_ast_srt_details            OKL_PRICING_UTILS_PVT.srt_details_rec_type;
    x_iir                        NUMBER;
    l_initial_guess              NUMBER := 0.1;
    x_payment                    NUMBER;
    l_lq_cash_flow_rec           OKL_PRICING_UTILS_PVT.so_cash_flows_rec_type;        -- Quote Level Cash Flow Object
    l_lq_cash_flow_det_tbl       OKL_PRICING_UTILS_PVT.so_cash_flow_details_tbl_type; -- Quote Level Cash Flow levels
    l_lq_cash_inflows            OKL_PRICING_UTILS_PVT.cash_inflows_tbl_type; -- Lease Quote level Streams
    l_lq_pricing_parameter_rec   OKL_PRICING_UTILS_PVT.pricing_parameter_rec_type;
    l_tmp_pricing_parameter_rec  OKL_PRICING_UTILS_PVT.pricing_parameter_rec_type;
    l_pricing_parameter_tbl      OKL_PRICING_UTILS_PVT.pricing_parameter_tbl_type;
    l_pp_non_sub_iir_tbl         OKL_PRICING_UTILS_PVT.pricing_parameter_tbl_type;
    l_pp_non_sub_irr_tbl         OKL_PRICING_UTILS_PVT.pricing_parameter_tbl_type;
    l_pp_lq_fee_srv_tbl          OKL_PRICING_UTILS_PVT.pricing_parameter_tbl_type;
    l_lq_residual_inflows        OKL_PRICING_UTILS_PVT.cash_inflows_tbl_type;
    l_overridden                 BOOLEAN;
    l_non_overiding_assets_tbl   OKL_STREAMS_UTIL.NumberTabTyp;
    l_noa_pp_tbl                 OKL_PRICING_UTILS_PVT.pricing_parameter_tbl_type;
    lnoa_index                   BINARY_INTEGER;
    ppfs_index                   BINARY_INTEGER;
    l_eot_date                   DATE;
    l_cf_dpp                     NUMBER;
    l_cf_ppy                     NUMBER;
    res_index                    BINARY_INTEGER;
    pp_index                     BINARY_INTEGER;
    l_yields_rec                 yields_rec;
    l_subsidized_yields_rec      yields_rec;
    l_iir_noa_dts                NUMBER; -- IIR @ LQ level for Non-overriding assets considering
                                         --  Downpayment/Subsidy/Trade-In
    l_iir_noa                    NUMBER; -- IIR @ LQ level for Non-overriding assets with out
                                         --  considering Downpayment/Subsidy/Trade-In
    l_lq_pp_noa_dts              OKL_PRICING_UTILS_PVT.pricing_parameter_rec_type;
    l_lq_pp_noa                  OKL_PRICING_UTILS_PVT.pricing_parameter_rec_type;
    l_iir_temp                   NUMBER;
    l_adj_mat_cat_rec            adj_mat_cat_rec;
    l_ass_adj_tbl                OKL_LEASE_QUOTE_ASSET_PVT.asset_adjustment_tbl_type;
    l_cash_flow_rec              so_cash_flows_rec_type;
    l_cash_flow_det_tbl          so_cash_flow_details_tbl_type;
    l_cash_inflows               OKL_PRICING_UTILS_PVT.cash_inflows_tbl_type;
    l_lease_qte_rec              OKL_LEASE_QUOTE_PVT.lease_qte_rec_type;
    x_lease_qte_rec              OKL_LEASE_QUOTE_PVT.lease_qte_rec_type;
    l_lq_payment_header_rec      OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_header_rec_type;
    l_lq_payment_level_tbl       OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_tbl_type;
    l_cfo_exists_at_lq           VARCHAR2(30);
    l_cfo_exists_at_noa          VARCHAR2(30);
    l_tot_noa_oec                NUMBER;
    l_noa_cash_flow_rec          OKL_PRICING_UTILS_PVT.so_cash_flows_rec_type;
    l_noa_cash_flow_det_tbl      OKL_PRICING_UTILS_PVT.so_cash_flow_details_tbl_type;
    l_noa_payment_header_rec     OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_header_rec_type;
    l_noa_payment_level_tbl      OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_tbl_type;
    l_fee_outflow_caf_rec        so_cash_flows_rec_type;
    l_fee_outflow_cfl_tbl        so_cash_flow_details_tbl_type;
    l_fee_inflow_caf_rec         so_cash_flows_rec_type;
    l_fee_inflow_cfl_tbl         so_cash_flow_details_tbl_type;
    l_adj_type                   VARCHAR2(30);
    l_pricing_method             OKL_LEASE_QUOTES_B.PRICING_METHOD%TYPE;
    l_sp_for_assets              BOOLEAN;
    l_an_ass_follow_lq           BOOLEAN;
    l_lq_details_prc_rec         OKL_PRICING_UTILS_PVT.pricing_parameter_rec_type;
    l_rent_sty_id                OKL_STRM_TYPE_B.ID%TYPE;
    l_asset_caf_rec              OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_header_rec_type;
    l_asset_cfl_tbl              OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_tbl_type;
    l_ast_level_fin_amt          NUMBER;
    l_lq_level_fin_amt           NUMBER;
    l_quote_type_code            OKL_LEASE_QUOTES_B.PARENT_OBJECT_CODE%TYPE;
    l_solved                     VARCHAR2(30);
    l_tmp_amount                 NUMBER;
    l_lq_con_cash_inflows        cash_inflows_tbl_type;
    l_iir                        NUMBER;
    l_miss_payment               NUMBER;
    l_rnd_sum_assets_pmnts_tbl   OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_tbl_type;
    l_rnd_lq_payment_level_tbl   OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_tbl_type;
    l_sum_of_noa_oec_percent     NUMBER;
    -- Bug 6622178 : Start
    l_disp_sf_msg  BOOLEAN;
    -- Bug 6622178 : End
    -- Bug 7440199: Quote Streams ER: RGOOTY: Start
    l_amount                NUMBER;
    l_sum_assoc_assets_amt  NUMBER;
    l_assoc_assets_count    NUMBER;
    l_assets_indx           NUMBER;
    l_fee_id                OKL_FEES_B.ID%TYPE;

    TYPE amount_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_amount_tbl amount_tabtype;

    --Cursor to get the associated assets count and amount for Service Line
    CURSOR CHECK_ASSOC_ASSETS(P_LINE_TYPE VARCHAR2,
                              P_FEE_SRVC_ID OKL_LINE_RELATIONSHIPS_B.RELATED_LINE_ID%TYPE) IS
    SELECT SUM(AMOUNT),
           COUNT(*)
      FROM OKL_LINE_RELATIONSHIPS_B
     WHERE SOURCE_LINE_TYPE = 'ASSET'
       AND RELATED_LINE_TYPE = P_LINE_TYPE
       AND RELATED_LINE_ID = P_FEE_SRVC_ID;

    --Cursor to get the Associated Asset ID and Amount for Service Line
    CURSOR GET_ASSOC_ASSETS(P_LINE_TYPE VARCHAR2,
                            P_FEE_SRVC_ID OKL_LINE_RELATIONSHIPS_B.RELATED_LINE_ID%TYPE) IS
    SELECT SOURCE_LINE_ID,
           AMOUNT
      FROM OKL_LINE_RELATIONSHIPS_B
     WHERE SOURCE_LINE_TYPE = 'ASSET'
       AND RELATED_LINE_TYPE = P_LINE_TYPE
       AND RELATED_LINE_ID = P_FEE_SRVC_ID;

    CURSOR GET_FEE_ID(P_CFO_ID OKL_CASH_FLOW_OBJECTS.ID%TYPE) IS
    SELECT SOURCE_ID
      FROM OKL_CASH_FLOW_OBJECTS
     WHERE ID = P_CFO_ID;
   -- Bug 7440199: Quote Streams ER: RGOOTY: End
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := OKL_DEBUG_PUB.check_log_enabled;
    is_debug_procedure_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
                              'begin debug OKLRPIUB.pls call '|| lower(l_api_name));
    is_debug_statement_on := OKL_DEBUG_PUB.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name      => l_api_name,
                            p_pkg_name      => G_PKG_NAME,
                            p_init_msg_list => p_init_msg_list,
                            l_api_version   => l_api_version,
                            p_api_version   => p_api_version,
                            p_api_type      => g_api_type,
                            x_return_status => l_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Bug 7440199: Quote Streams ER: RGOOTY: Start
    delete_quote_streams(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => l_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_quote_id      => p_qte_id
                         );
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Bug 7440199: Quote Streams ER: RGOOTY: End
    --Bug 5884825 PAGARG start
    OPEN product_name_csr(p_qte_id);
    FETCH product_name_csr INTO l_product_name;
    CLOSE product_name_csr;
    --Bug 5884825 PAGARG end

    -- Fetch the Lease Quote Header Details !
    OPEN quote_csr(p_qte_id);
    FETCH quote_csr INTO quote_rec;
    IF (quote_csr%NOTFOUND) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    CLOSE quote_csr;
    IF quote_rec.parent_object_code = 'LEASEAPP' THEN
      l_quote_type_code := 'LA';
    ELSE
      l_quote_type_code := 'LQ';
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ');
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      '!!!!!!!!!!!!Pricing of ' || quote_rec.reference_number || '!!!!!!!!!!!! ');
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ');
    -- Derieve the End of Term Date of the Lease Quote
    okl_stream_generator_pvt.add_months_new(
      p_start_date     => quote_rec.expected_start_date,
      p_months_after   => quote_rec.term,
      x_date           => l_eot_date,
      x_return_status  => l_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_eot_date := l_eot_date - 1;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Effective To of the LQ ' || l_eot_date );
    -- Populate the l_adj_mat_cat_rec !
    -- Here instead of straightly assuming that user will only pick the SRT at the
    --  Quote level, we should be writing an API, which will build the cash flows and cash flow levels
    --  if the user has picked the SRT, or otherwise the API will fetch directly from
    --  the Cash flows in case of User picked the Structured Pricing option ...
    l_adj_mat_cat_rec.target_eff_from := quote_rec.expected_start_date;
    l_adj_mat_cat_rec.term := quote_rec.term;
    IF quote_rec.parent_object_code = 'LEASEOPP'
    THEN
      -- Fetch from the Lease Opportunity
      FOR t_rec IN get_cust_details_csr( p_lq_id => p_qte_id )
      LOOP
        l_adj_mat_cat_rec.territory := t_rec.sales_territory_id;
        l_adj_mat_cat_rec.customer_credit_class :=
          okl_lease_app_pvt.get_credit_classfication(
             p_party_id      => t_rec.prospect_id,
             p_cust_acct_id  => t_rec.cust_acct_id,
             p_site_use_id   => -99);
         -- Store the currency now
         l_currency := t_rec.currency_code;
      END LOOP;
    ELSE
      -- Fetch from the Lease Application
      FOR t_rec IN get_cust_details_csr_lapp( p_lq_id => p_qte_id )
      LOOP
        l_adj_mat_cat_rec.territory := t_rec.sales_territory_id;
        l_adj_mat_cat_rec.customer_credit_class :=
          okl_lease_app_pvt.get_credit_classfication(
             p_party_id      => t_rec.prospect_id,
             p_cust_acct_id  => t_rec.cust_acct_id,
             p_site_use_id   => -99);
         -- Store the currency now
         l_currency := t_rec.currency_code;
      END LOOP;
    END IF;
    l_adj_mat_cat_rec.deal_size := NULL; -- Dont know how to get these value !
    -- Know the type of the EOT
    FOR t_rec IN get_eot_type( p_lq_id => p_qte_id  )
    LOOP
      l_eot_type_code := t_rec.eot_type_code;
    END LOOP;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   '****Currency Code = ' || l_currency || '****EOT Type ' || l_eot_type_code);
    IF quote_rec.pricing_method <> 'RC'
    THEN
      get_lq_cash_flows(
        p_api_version          => p_api_version,
        p_init_msg_list        => p_init_msg_list,
        x_return_status        => l_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_id                   => p_qte_id,
        p_lq_srt_id            => quote_rec.rate_template_id,
        p_cf_source            => G_CF_SOURCE_LQ, -- Fetch SRT / Strucutured Pricing details at Lease Quote Level
        p_adj_mat_cat_rec      => l_adj_mat_cat_rec,
        p_pricing_method       => quote_rec.pricing_method,
        x_days_in_month        => l_days_in_month,
        x_days_in_year         => l_days_in_year,
        x_cash_flow_rec        => l_lq_cash_flow_rec,
        x_cash_flow_det_tbl    => l_lq_cash_flow_det_tbl);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After get_lq_cash_flows ' || l_return_status);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'No. of Cash Flow Levels ' || l_lq_cash_flow_det_tbl.COUNT );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_cfo_exists_at_lq := 'NO';
      FOR t_rec IN check_cfo_exists_csr(
                     p_oty_code     => 'LEASE_QUOTE',
                     p_source_table => 'OKL_LEASE_QUOTES_B',
                     p_source_id    => p_qte_id,
                     p_sts_code     => 'CURRENT')
      LOOP
        l_cfo_exists_at_lq := t_rec.cfo_exists;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'After check_cfo_exists_csr. l_cfo_exists_at_lq' || l_cfo_exists_at_lq);
      -- Populate the l_payment_header_rec and l_payment_level_tbl structures
      -- CFO, CFH Population
      IF l_cfo_exists_at_lq = 'YES'
      THEN
        l_lq_payment_header_rec.cashflow_header_id := l_lq_cash_flow_rec.caf_id;
        l_lq_payment_header_rec.cashflow_object_id := l_lq_cash_flow_rec.cfo_id;
        l_lq_payment_header_rec.stream_type_id := l_lq_cash_flow_rec.sty_id;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Passing l_lq_payment_header_rec.cashflow_header_id ' ||
                  l_lq_payment_header_rec.cashflow_header_id  );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  ' l_lq_payment_header_rec.cashflow_object_id ' ||
                  l_lq_payment_header_rec.cashflow_object_id);
      END IF;
      IF l_lq_payment_header_rec.stream_type_id IS NULL OR
         l_cfo_exists_at_lq = 'NO'
      THEN
        OPEN c_strm_type ( quote_rec.id, quote_rec.expected_start_date );
        FETCH c_strm_type INTO r_strm_type;
        CLOSE c_strm_type;
        l_lq_payment_header_rec.stream_type_id := r_strm_type.payment_type_id;
      END IF;
      -- Store the rent Stream ID
      l_rent_sty_id := l_lq_payment_header_rec.stream_type_id;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Fetched the RENT Stream Type ID ' || l_lq_payment_header_rec.stream_type_id
        || ' Quote ID ' || quote_rec.id || ' Start Date ' || quote_rec.expected_start_date );
      l_lq_payment_header_rec.parent_object_id := p_qte_id;
      l_lq_payment_header_rec.quote_id         := p_qte_id;
      l_lq_payment_header_rec.type_code        := 'INFLOW';
      IF l_lq_cash_flow_rec.sts_code = 'CURRENT' THEN
        l_lq_payment_header_rec.status_code:= 'CURRENT';
      ELSE
        l_lq_payment_header_rec.status_code:= 'WORK';
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 '****** Cash flow status code ' || l_lq_payment_header_rec.status_code );
      l_lq_payment_header_rec.parent_object_code := 'LEASE_QUOTE';
      l_lq_payment_header_rec.arrears_flag       := l_lq_cash_flow_rec.due_arrears_yn;
      l_lq_payment_header_rec.quote_type_code    := l_quote_type_code;
      -- Populate the Cash flow levels
      IF l_lq_cash_flow_det_tbl.COUNT > 0
      THEN
        l_lq_payment_header_rec.frequency_code :=
          l_lq_cash_flow_det_tbl(l_lq_cash_flow_det_tbl.FIRST).fqy_code;
        FOR t_index IN l_lq_cash_flow_det_tbl.FIRST .. l_lq_cash_flow_det_tbl.LAST
        LOOP
          IF l_cfo_exists_at_lq = 'YES'
          THEN
            l_lq_payment_level_tbl(t_index).cashflow_level_id  := l_lq_cash_flow_det_tbl(t_index).cfl_id;
            l_lq_payment_level_tbl(t_index).record_mode        := 'UPDATE';
            l_lq_payment_level_tbl(t_index).cashflow_level_ovn := NULL;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  ' l_lq_payment_level_tbl(t_index).cashflow_level_id ' ||
                  l_lq_payment_level_tbl(t_index).cashflow_level_id);
          ELSE
            l_lq_payment_level_tbl(t_index).record_mode := 'CREATE';
          END IF;
          l_lq_payment_level_tbl(t_index).rate        := l_lq_cash_flow_det_tbl(t_index).rate;
          l_lq_payment_level_tbl(t_index).stub_days   := l_lq_cash_flow_det_tbl(t_index).stub_days;
          l_lq_payment_level_tbl(t_index).stub_amount := l_lq_cash_flow_det_tbl(t_index).stub_amount;
          l_lq_payment_level_tbl(t_index).periods     := l_lq_cash_flow_det_tbl(t_index).number_of_periods;
          l_lq_payment_level_tbl(t_index).periodic_amount := l_lq_cash_flow_det_tbl(t_index).amount;
          l_lq_payment_level_tbl(t_index).start_date  := l_lq_cash_flow_det_tbl(t_index).start_date;
        END LOOP;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Stored the Cash Flows in the l_lq_payment_level_tbl' );
      -- Populated the payment_header_rec and payment_level for use at later Stage !
      get_day_count_method(
        p_days_in_month    => l_days_in_month,
        p_days_in_year     => l_days_in_year,
        x_day_count_method => l_day_count_method,
        x_return_status    => l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Return Status | l_days_in_month | l_days_in_year | l_day_count_method ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        l_return_status || ' | ' || l_days_in_month || ' | ' || l_days_in_year || ' | ' ||  l_day_count_method  );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        --Bug 5884825 PAGARG start
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_ISG_DAY_CONVENTION',
                             p_token1       => 'PRODUCT_NAME',
                             p_token1_value => l_product_name);
        --Bug 5884825 PAGARG end
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Generate the Streams for the payment at the Quote Level !
      IF l_lq_cash_flow_det_tbl IS NOT NULL AND
         l_lq_cash_flow_det_tbl.COUNT > 0
      THEN
        -- Initialize the Strm Count to Zero
        gen_so_cf_strms(
          p_api_version            => p_api_version,
          p_init_msg_list          => p_init_msg_list,
          x_return_status          => l_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_cash_flow_rec          => l_lq_cash_flow_rec,
          p_cf_details_tbl         => l_lq_cash_flow_det_tbl,
          x_cash_inflow_strms_tbl  => l_lq_cash_inflows);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'After gen_so_cf_strms ' || l_return_status);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Number of Stream Elements generated ' || l_lq_cash_inflows.COUNT);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Get the DPP and PPY inorder to populate for the Residuals Table
        get_dpp_ppy(
          p_frequency            => l_lq_cash_flow_det_tbl(l_lq_cash_flow_det_tbl.FIRST).fqy_code,
          x_dpp                  => l_cf_dpp,
          x_ppy                  => l_cf_ppy,
          x_return_status        => l_return_status );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'After get_dpp_ppy ' || l_return_status );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          '********** No pricing option picked @ LQ ! *******' );
      END IF; -- IF l_cash_flow_det_tbl.COUNT > 0
    END IF; -- IF pricing_method <> 'RC'
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module,
               'price method ' || quote_rec.pricing_method, l_return_status );
    IF quote_rec.pricing_method = 'SP' OR
       quote_rec.pricing_method = 'SM'
    THEN
      -- Solve for Payment
      l_lq_pricing_parameter_rec.financed_amount := 0;
      l_lq_pricing_parameter_rec.down_payment := 0;
      l_lq_pricing_parameter_rec.trade_in := 0;
      l_lq_pricing_parameter_rec.subsidy := 0;
      l_lq_pricing_parameter_rec.cap_fee_amount := 0;
      pp_index := 1;
      lnoa_index := 1;
      res_index := 1;
      l_non_overiding_assets_tbl.DELETE;
      -- Loop through the Assets and check price the asset seperately
      --  which has overriddent the payment option picked at the Quote Level
      FOR assets_rec IN assets_csr(p_qte_id)                 -- for all assets
      LOOP
        -- Check whether this Asset has overridden the Payment option defined
        --  at the quote level !
        IF assets_rec.fee_type <> 'FREE_FORM1'
        THEN
          l_overridden := TRUE;
        ELSE
          l_overridden := is_asset_overriding(
                          p_qte_id                => p_qte_id,
                          p_ast_id                => assets_rec.ast_id,
                          p_lq_line_level_pricing => quote_rec.line_level_pricing,
                          p_lq_srt_id             => quote_rec.rate_template_id,
                          p_ast_srt_id            => assets_rec.rate_template_id,
                          p_lq_struct_pricing     => quote_rec.structured_pricing,
                          p_ast_struct_pricing    => assets_rec.structured_pricing,
                          p_lq_arrears_yn         => quote_rec.target_arrears,
                          p_ast_arrears_yn        => assets_rec.target_arrears,
                          x_return_status         => l_return_status);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After is_asset_overriding assets_rec.id =' || assets_rec.ast_id);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '  l_return_status =' || l_return_status );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        IF l_overridden = FALSE
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            ' Asset follows the Payment Structure defined @ Lease Quote level ' || assets_rec.asset_number );
          -- The current Asset is following the pricing option defined at the LQ level !
          l_non_overiding_assets_tbl(lnoa_index) := assets_rec.ast_id;
          FOR asset_cost_adj_rec IN asset_cost_adj_csr( qteid => p_qte_id,
                                                        astid => assets_rec.ast_id)
          LOOP
            -- Fetch the Asset Cost Adjustment information like ..
            --  Down Payment/Subsidy/Trade-in
            IF asset_cost_adj_rec.adjustment_source_type = G_DOWNPAYMENT_TYPE
            THEN
              l_noa_pp_tbl(lnoa_index).down_payment := nvl(asset_cost_adj_rec.VALUE, 0 );
            ELSIF asset_cost_adj_rec.adjustment_source_type = G_SUBSIDY_TYPE
            THEN
              IF ( nvl(asset_cost_adj_rec.value, -9999) = -9999)
              THEN
                OPEN subsidy_adj_csr(asset_cost_adj_rec.ADJUSTMENT_SOURCE_ID);
                FETCH subsidy_adj_csr INTO subsidy_adj_rec;
                CLOSE subsidy_adj_csr;
                -- Bug 6622178 : Start
                -- Consider all subsidies for the asset
                IF l_noa_pp_tbl.EXISTS(lnoa_index) then
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(l_noa_pp_tbl(lnoa_index).subsidy,0) + NVL(subsidy_adj_rec.amount,0);
                ELSE
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(subsidy_adj_rec.amount,0);
                  -- Bug 6622178 : End
                END IF;
              ELSE
                -- Bug 6622178 : Start
                -- Consider all subsidies for the asset
                IF l_noa_pp_tbl.EXISTS(lnoa_index) then
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(l_noa_pp_tbl(lnoa_index).subsidy,0) + NVL(asset_cost_adj_rec.value,0);
                ELSE
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(asset_cost_adj_rec.value,0);
                  -- Bug 6622178 : End
                END IF;
              END IF;
            ELSIF asset_cost_adj_rec.adjustment_source_type = G_TRADEIN_TYPE
            THEN
              l_noa_pp_tbl(lnoa_index).trade_in := nvl(asset_cost_adj_rec.VALUE, 0);
            END IF;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'After Retrieving the Asset Cost Adjustments ');
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Down Payment| Trade In | Subsidy ' );
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              l_noa_pp_tbl(lnoa_index).down_payment || ' | ' || l_noa_pp_tbl(lnoa_index).trade_in || ' | ' || l_noa_pp_tbl(lnoa_index).subsidy );
          END LOOP;
          FOR asset_adj_rec IN asset_adj_csr(p_qte_id, assets_rec.ast_id)
          LOOP
            l_noa_pp_tbl(lnoa_index).financed_amount := nvl(asset_adj_rec.oec,0);
            -- Calculate the Capitalized Fee for this Asset
            FOR ct_rec IN get_asset_cap_fee_amt(
                           p_source_type       => 'ASSET',
                           p_source_id         => assets_rec.ast_id,
                           p_related_line_type => 'CAPITALIZED')
            LOOP
              l_noa_pp_tbl(lnoa_index).cap_fee_amount := nvl(ct_rec.capitalized_amount, 0);
            END LOOP;
            l_lq_residual_inflows(res_index).line_number := res_index;
            IF ( l_eot_type_code = 'PERCENT' OR l_eot_type_code = 'RESIDUAL_PERCENT' )
            THEN
              -- Store EOT %age in terms of Decimal like 0.25 for 25%
              l_lq_residual_inflows(res_index).cf_amount :=
                nvl((asset_adj_rec.end_of_term_value /100) * l_noa_pp_tbl(lnoa_index).financed_amount, 0);
            ELSE
              -- EOT is mentioned in terms of Amount
              l_lq_residual_inflows(res_index).cf_amount   := nvl(asset_adj_rec.end_of_term_value, 0);
            END IF;
            l_lq_residual_inflows(res_index).cf_date     := l_eot_date;
            l_lq_residual_inflows(res_index).cf_miss_pay := 'N';
            l_lq_residual_inflows(res_index).is_stub     := 'N';
            l_lq_residual_inflows(res_index).is_arrears  := 'Y';
            l_lq_residual_inflows(res_index).cf_dpp := l_cf_dpp;
            l_lq_residual_inflows(res_index).cf_ppy := l_cf_ppy;
            -- Store the Asset Residuals in the corresponding NOA Assets table
            l_noa_pp_tbl(lnoa_index).residual_inflows(1) := l_lq_residual_inflows(res_index);
            -- Increment the res_index
            res_index := res_index + 1;
          END LOOP;
          -- Bug 6669429 : Start
          l_lq_pricing_parameter_rec.financed_amount := l_lq_pricing_parameter_rec.financed_amount + nvl(l_noa_pp_tbl(lnoa_index).financed_amount,0);
          l_lq_pricing_parameter_rec.down_payment    := l_lq_pricing_parameter_rec.down_payment    + nvl(l_noa_pp_tbl(lnoa_index).down_payment,0);
          l_lq_pricing_parameter_rec.trade_in        := l_lq_pricing_parameter_rec.trade_in        + nvl(l_noa_pp_tbl(lnoa_index).trade_in,0);
          l_lq_pricing_parameter_rec.subsidy         := l_lq_pricing_parameter_rec.subsidy         + nvl(l_noa_pp_tbl(lnoa_index).subsidy,0);
          l_lq_pricing_parameter_rec.cap_fee_amount  := l_lq_pricing_parameter_rec.cap_fee_amount  + nvl(l_noa_pp_tbl(lnoa_index).cap_fee_amount,0);
          -- Bug 6669429 : End
          lnoa_index := lnoa_index + 1;
        ELSE -- IF l_overridden = FALSE
          -- Price this Asset which has overridden the payment strcuture defined on the LQ !
          IF  assets_rec.fee_type = 'FREE_FORM1'
          THEN
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              ' Asset with ID '||  assets_rec.ast_id || ' overrides the payment structure @ LQ level' );
            price_standard_quote_asset(
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              p_qte_id                 => p_qte_id,
              p_ast_id                 => nvl(assets_rec.ast_id, assets_rec.fee_id),
              p_price_at_lq_level      => FALSE, -- Use Asset Level Cash flows only !
              p_target_rate            => NULL,
              p_line_type              => assets_rec.fee_type,
              x_pricing_parameter_rec  => l_tmp_pricing_parameter_rec );
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'After price_standard_quote_asset ' || l_return_status );
            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
              RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
            END IF;
            l_pricing_parameter_tbl(pp_index) := l_tmp_pricing_parameter_rec;
            -- Increment the pp_index
            pp_index := pp_index + 1;
          END IF;
        END IF;
      END LOOP; -- Loop on the Assets csr
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        ' Number of Overriding Lines = ' || l_pricing_parameter_tbl.COUNT  || ' | ' ||
        ' Number of Non-Overriding Lines = ' || l_non_overiding_assets_tbl.COUNT );
      IF l_non_overiding_assets_tbl.COUNT > 0
      THEN
        -- Store into Pricing Params only if there is atleast one noa assets
        l_lq_pricing_parameter_rec.cash_inflows := l_lq_cash_inflows;
        l_lq_pricing_parameter_rec.residual_inflows := l_lq_residual_inflows;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          ' Before Calling compute_iir to solve for payment @ LQ level ' );
        -- Now Solve for Payment at the Lease Quote Level using amortization logic !
        compute_iir(
          p_api_version            => p_api_version,
          p_init_msg_list          => p_init_msg_list,
          x_return_status          => l_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_start_date             => quote_rec.expected_start_date,
          p_day_count_method       => l_day_count_method,
          p_pricing_method         => quote_rec.pricing_method,
          p_initial_guess          => l_initial_guess,
          px_pricing_parameter_rec => l_lq_pricing_parameter_rec,
          px_iir                   => x_iir,
          x_payment                => x_payment);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'After compute_iir ' || l_return_status );
        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
        IF x_payment < 0
        THEN
          OKL_API.SET_MESSAGE (
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_NEGATIVE_ADJ_AMT',
            p_token1       => 'TYPE',
            p_token1_value => 'Payment',
            p_token2       => 'AMOUNT',
            p_token2_value => round(x_payment,2) );
          RAISE okl_api.g_exception_error;
        END IF;
        -- Now, we need to populate back the Payment Amount back
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           '***** **** Updating the stream elements and cash flow with the amount ' || x_payment );
        --  Update the Cash inflows with the Solved Amount ..
        FOR t_in IN l_lq_pricing_parameter_rec.cash_inflows.FIRST ..
                    l_lq_pricing_parameter_rec.cash_inflows.LAST
        LOOP
          IF l_lq_pricing_parameter_rec.cash_inflows(t_in).cf_miss_pay = 'Y' OR
             quote_rec.pricing_method = 'SP'
          THEN
            l_lq_pricing_parameter_rec.cash_inflows(t_in).cf_amount := x_payment;
          END IF;
        END LOOP;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'After Updating the PP_REC.cash_inflows with the solved payment amount ' || round( x_payment, 4) );
        -- Update the LQ Cash inflows with the Solved Payment Amount
        FOR t_in IN l_lq_cash_flow_det_tbl.FIRST..l_lq_cash_flow_det_tbl.LAST
        LOOP
          IF quote_rec.pricing_method = 'SP' OR
            (quote_rec.pricing_method = 'SM' AND  l_lq_cash_flow_det_tbl(t_in).number_of_periods > 0 AND l_lq_cash_flow_det_tbl(t_in).amount IS NULL ) OR
            ( quote_rec.pricing_method = 'SM' AND  l_lq_cash_flow_det_tbl(t_in).stub_days > 0 AND l_lq_cash_flow_det_tbl(t_in).stub_amount IS NULL ) THEN
            IF l_lq_cash_flow_det_tbl(t_in).number_of_periods > 0
            THEN
              l_lq_payment_level_tbl(t_in).periodic_amount := x_payment;
              l_lq_payment_level_tbl(t_in).missing_pmt_flag := 'Y';
            ELSE
              l_lq_payment_level_tbl(t_in).stub_amount := x_payment;
              l_lq_payment_level_tbl(t_in).missing_pmt_flag := 'Y';
            END IF;
          END IF;
        END LOOP;
        -- Storing the l_lq_pricing_parameter_rec for derieving payments @ every NOA Asset Level.
        l_an_ass_follow_lq   := TRUE;  -- Store the flag
        l_lq_details_prc_rec := l_lq_pricing_parameter_rec;
        IF l_cfo_exists_at_lq = 'YES'
        THEN
          -- Delete the Cash Flow Levels which may be already created by Pricing ..
          okl_lease_quote_cashflow_pvt.delete_cashflows (
            p_api_version          => p_api_version,
            p_init_msg_list        => p_init_msg_list,
            p_transaction_control  => NULL,
            p_source_object_code   => 'LEASE_QUOTE',
            p_source_object_id     => p_qte_id,
            x_return_status        => l_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    ' ----- After deleting the Cash flows for the asset  ' || l_return_status );
          IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;
        END IF;
        FOR cfl_index IN l_lq_payment_level_tbl.FIRST .. l_lq_payment_level_tbl.LAST
        LOOP
          l_lq_payment_level_tbl(cfl_index).record_mode := 'CREATE';
        END LOOP;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Before creating the cash flows call'  );
        OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_transaction_control => NULL,
          p_cashflow_header_rec => l_lq_payment_header_rec,
          p_cashflow_level_tbl  => l_lq_payment_level_tbl,
          x_return_status       => l_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After update_cashflow call ' || l_Return_Status );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- pp_index is an post-assigned incremented index!
        l_lq_pricing_parameter_rec.line_type := 'FREE_FORM1';
        -- Bug 7440199: Quote Streams ER: RGOOTY: Start
        l_lq_pricing_parameter_rec.cfo_id := l_lq_payment_header_rec.cashflow_object_id;
        -- Bug 7440199: Quote Streams ER: RGOOTY: End
        l_pricing_parameter_tbl(pp_index) := l_lq_pricing_parameter_rec;
        -- Increment the pp_index
        pp_index := pp_index + 1;
      END IF;
      -- Store the Pricing Params to solve again for Non-Subsidized Yields
      -- Handling the ROLLOVER AND FINANCED FEES
      FOR assets_rec IN assets_csr(p_qte_id) -- ALL Assets or FEES
      LOOP
        IF  assets_rec.fee_type IN ( 'ROLLOVER', 'FINANCED')
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            ' Calling price_standard_quote_asset for ' || assets_rec.fee_type || ' with ID ' || assets_rec.fee_id );
          -- Price the fees ROLLOVER OR FINANCED
          price_standard_quote_asset(
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_api_version            => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_qte_id                 => p_qte_id,
            p_ast_id                 => nvl(assets_rec.ast_id, assets_rec.fee_id),
            p_price_at_lq_level      => FALSE, -- Use Asset Level Cash flows only !
            p_target_rate            => NULL,
            p_line_type              => assets_rec.fee_type,
            x_pricing_parameter_rec  => l_tmp_pricing_parameter_rec );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After price_standard_quote_asset ' || l_return_status );
          IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;
          l_pricing_parameter_tbl(pp_index) := l_tmp_pricing_parameter_rec;
          -- Increment the pp_index
          pp_index := pp_index + 1;
        END IF;
      END LOOP;
      l_pp_non_sub_iir_tbl := l_pricing_parameter_tbl;
      -- Now call the compute_irr api to solve for the IIR Yield at the Lease quote Level !
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => x_iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pricing_parameter_tbl,
        px_irr                    => x_iir,
        x_payment                 => x_payment);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of SUBSIDIZED-IIR @ LQ Level ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR IIR ' || x_iir );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_subsidized_yields_rec.iir      :=  x_iir;
      l_subsidized_yields_rec.bk_yield :=  l_subsidized_yields_rec.iir;
      -- Populate the Pricing Params with all the other configuration lines
      --  for solving the SUBSIDIZED YIELDS @ Lease Quote Level
      -- Extract the fess information and built the Cash Inflows and Pricing Parameters
      FOR assets_rec IN assets_csr(p_qte_id)                 -- for all assets
      LOOP
        IF ( assets_rec.fee_type NOT IN ('FREE_FORM1', 'ROLLOVER', 'FINANCED', 'ABSORBED') )
        THEN
          -- Delete the previous fees cash flows
          l_fee_outflow_cfl_tbl.DELETE;
          l_fee_inflow_cfl_tbl.DELETE;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       '!!!!!!  Handling fee ' || assets_rec.fee_type );
          get_lq_fee_cash_flows(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => l_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_fee_type         => assets_rec.fee_type,
            p_lq_id            => p_qte_id,
            p_fee_id           => assets_rec.fee_id,
            x_outflow_caf_rec  => l_fee_outflow_caf_rec,
            x_outflow_cfl_tbl  => l_fee_outflow_cfl_tbl,
            x_inflow_caf_rec   => l_fee_inflow_caf_rec,
            x_inflow_cfl_tbl   => l_fee_inflow_cfl_tbl);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After get_lq_fee_cash_flows ' || l_return_status );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- Based on the outflows/Inflows obtained generate the streams
          IF l_fee_outflow_cfl_tbl.COUNT > 0
          THEN
            l_cash_inflows.DELETE;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!! Obtained Expense Cash flow levels !!!!!!!!' );
            gen_so_cf_strms(
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_cash_flow_rec          => l_fee_outflow_caf_rec,
              p_cf_details_tbl         => l_fee_outflow_cfl_tbl,
              x_cash_inflow_strms_tbl  => l_cash_inflows);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Place the information in the pricing params
            pp_index := pp_index + 1;
            l_pricing_parameter_tbl(pp_index).line_type := assets_rec.fee_type;
            l_pricing_parameter_tbl(pp_index).payment_type := 'EXPENSE';
            l_pricing_parameter_tbl(pp_index).line_start_date := assets_rec.line_start_date;
            l_pricing_parameter_tbl(pp_index).line_end_date := assets_rec.line_end_date;
            l_pricing_parameter_tbl(pp_index).cash_inflows := l_cash_inflows;
            -- Bug 7440199: Quote Streams ER: RGOOTY: Start
            l_pricing_parameter_tbl(pp_index).cfo_id := l_fee_outflow_caf_rec.cfo_id;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
          END IF;
          -- Based on the outflows/Inflows obtained generate the streams
          IF l_fee_inflow_cfl_tbl.COUNT > 0
          THEN
            l_cash_inflows.DELETE;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!! Obtained Income Cash flow levels !!!!!!!!' );
            gen_so_cf_strms(
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_cash_flow_rec          => l_fee_inflow_caf_rec,
              p_cf_details_tbl         => l_fee_inflow_cfl_tbl,
              x_cash_inflow_strms_tbl  => l_cash_inflows);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Place the information in the pricing params
            pp_index := pp_index + 1;
            l_pricing_parameter_tbl(pp_index).line_type := assets_rec.fee_type;
            IF assets_rec.fee_type IN ( 'INCOME', 'MISCELLANEOUS' )
            THEN
              l_pricing_parameter_tbl(pp_index).payment_type := 'INCOME';
            ELSE
              l_pricing_parameter_tbl(pp_index).payment_type := 'SECDEPOSIT';
            END IF;
            l_pricing_parameter_tbl(pp_index).line_start_date := assets_rec.line_start_date;
            l_pricing_parameter_tbl(pp_index).line_end_date := assets_rec.line_end_date;
            l_pricing_parameter_tbl(pp_index).cash_inflows := l_cash_inflows;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
            l_pricing_parameter_tbl(pp_index).cfo_id := l_fee_inflow_caf_rec.cfo_id;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
          END IF;
        END IF; -- IF on Fee_type not in ...
        IF  assets_rec.fee_type = 'ABSORBED'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!  Building cash inflows for this Absorbed fee ' || assets_rec.fee_type );
          -- Increment the pp_index and store the pricng params
          pp_index := pp_index + 1;
          l_pricing_parameter_tbl(pp_index).payment_type := 'EXPENSE';
          l_pricing_parameter_tbl(pp_index).financed_amount := assets_rec.fee_amount;
        END IF;
      END LOOP;
      -- Store the Pricing Params to solve again for Non-Subsidized IRR Yields
      l_pp_non_sub_irr_tbl := l_pricing_parameter_tbl;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ Before Computation of SUBSIDIZED-IRR @ LQ Level ' );
      -- Now call the compute_irr api to solve for the IIR Yield at the Lease quote Level !
      l_iir_temp := NULL;
      l_iir_temp := l_subsidized_yields_rec.pre_tax_irr;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => x_iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pricing_parameter_tbl, -- includes the fees as well
        -- px_irr                    => l_subsidized_yields_rec.pre_tax_irr,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
        l_subsidized_yields_rec.pre_tax_irr := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of SUBSIDIZED-IRR @ LQ Level ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR IRR ' || l_subsidized_yields_rec.pre_tax_irr );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Calculation of the Non-Subsidized Yields
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!!!!! Before Computation of NON-SUBSIDIZED-IIR @ LQ Level !!!!!!!!' );
      -- Remove subsidy Amount and then solve the IIR now
      FOR t_in IN l_pp_non_sub_iir_tbl.FIRST .. l_pp_non_sub_iir_tbl.LAST
      LOOP
        l_pp_non_sub_iir_tbl(t_in).subsidy := 0;
      END LOOP;
      -- Now call the compute_irr api to solve for the IIR Yield at the Lease quote Level !
      l_iir_temp := NULL;
      l_iir_temp := l_yields_rec.iir;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_iir_tbl, -- includes the fees as well
        -- px_irr                    => l_yields_rec.iir,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
       l_yields_rec.iir := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of NON-SUBSIDIZED-IIR @ LQ Level ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR NON-SUBSIDIZED-IIR ' || l_yields_rec.iir );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_yields_rec.bk_yield :=  l_yields_rec.iir;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ Before Computation of NON-SUBSIDIZED-IRR @ LQ Level ' );
      FOR t_in IN l_pp_non_sub_irr_tbl.FIRST .. l_pp_non_sub_irr_tbl.LAST
      LOOP
        l_pp_non_sub_irr_tbl(t_in).subsidy := 0;
      END LOOP;
      -- Now call the compute_irr api to solve for the IIR Yield at the Lease quote Level !
      l_iir_temp := NULL;
      l_iir_temp := l_yields_rec.pre_tax_irr;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.pre_tax_irr, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_irr_tbl, -- includes the fees as well
        -- px_irr                    => l_yields_rec.pre_tax_irr,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
      l_yields_rec.pre_tax_irr := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After Computation of NON-SUBSIDIZED-IRR @ LQ Level ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR NON-SUBSIDIZED-IRR ' || l_yields_rec.pre_tax_irr );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF quote_rec.pricing_method = 'SF'
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 ' SOLVING FOR FINANCED AMOUNT ' || l_return_status );
      -- End of IF p_pricing_method = 'SP' / 'SM' and begin 'SF'.
      -- Solve for Financed Amount
      l_lq_pricing_parameter_rec.financed_amount := 0;
      l_lq_pricing_parameter_rec.down_payment := 0;
      l_lq_pricing_parameter_rec.trade_in := 0;
      l_lq_pricing_parameter_rec.subsidy := 0;
      l_lq_pricing_parameter_rec.cap_fee_amount := 0;
      l_sum_of_noa_oec_percent := 0;
      pp_index := 1;
      lnoa_index := 1;
      res_index := 1;
      l_non_overiding_assets_tbl.DELETE;
      -- Bug 6622178 : Start
      l_disp_sf_msg := FALSE;
      -- Bug 6622178 : End
      FOR assets_rec IN assets_csr(p_qte_id)
      LOOP
        -- Loop through all the assets !
        IF assets_rec.fee_type <> 'FREE_FORM1'
        THEN
         l_overridden := TRUE;
        ELSE
          l_overridden := is_asset_overriding(
                           p_qte_id                => p_qte_id,
                           p_ast_id                => assets_rec.ast_id,
                           p_lq_line_level_pricing => quote_rec.line_level_pricing,
                           p_lq_srt_id             => quote_rec.rate_template_id,
                           p_ast_srt_id            => assets_rec.rate_template_id,
                           p_lq_struct_pricing     => quote_rec.structured_pricing,
                           p_ast_struct_pricing    => assets_rec.structured_pricing,
                           p_lq_arrears_yn         => quote_rec.target_arrears,
                           p_ast_arrears_yn        => assets_rec.target_arrears,
                           x_return_status         => l_return_status);
           put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       ' Pricing method = SF | x_return_status = ' || l_return_status );
           IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END IF;
         IF l_overridden = FALSE
         THEN
           put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       ' Asset follows the Payment Structure defined @ Lease Quote level ' || assets_rec.asset_number );
           -- The current Asset is following the pricing option defined at the LQ level !
           l_non_overiding_assets_tbl(lnoa_index) := assets_rec.ast_id;
           FOR asset_cost_adj_rec IN asset_cost_adj_csr( qteid => p_qte_id,
                                                         astid => assets_rec.ast_id)
           LOOP
             -- Fetch the Asset Cost Adjustment information like ..
             --  Down Payment/Subsidy/Trade-in
             IF asset_cost_adj_rec.adjustment_source_type = G_DOWNPAYMENT_TYPE
             THEN
               l_noa_pp_tbl(lnoa_index).down_payment := nvl(asset_cost_adj_rec.VALUE, 0 );
             ELSIF asset_cost_adj_rec.adjustment_source_type = G_SUBSIDY_TYPE
             THEN
               -- Bug 6622178 : Start
/*             IF ( nvl(asset_cost_adj_rec.value, -9999) = -9999)
               THEN
                 OPEN subsidy_adj_csr(asset_cost_adj_rec.ADJUSTMENT_SOURCE_ID);
                 FETCH subsidy_adj_csr INTO subsidy_adj_rec;
                 CLOSE subsidy_adj_csr;
                 l_noa_pp_tbl(lnoa_index).subsidy := subsidy_adj_rec.amount;
               ELSE
                 l_noa_pp_tbl(lnoa_index).subsidy := asset_cost_adj_rec.value;
               END IF;
*/
             OPEN subsidy_adj_csr(asset_cost_adj_rec.ADJUSTMENT_SOURCE_ID);
             FETCH subsidy_adj_csr INTO subsidy_adj_rec;
             CLOSE subsidy_adj_csr;
             IF ( UPPER(subsidy_adj_rec.SUBSIDY_CALC_BASIS) = 'FINANCED_AMOUNT' AND
                  asset_cost_adj_rec.value IS NULL)
             THEN
               l_disp_sf_msg := TRUE;
             END IF;
             -- Bug 6622178 : End
	     -- Bug 7429169 : Start
             IF l_noa_pp_tbl.EXISTS(lnoa_index)
	     THEN
               l_noa_pp_tbl(lnoa_index).subsidy := NVL(l_noa_pp_tbl(lnoa_index).subsidy,0)
	                                           + NVL(asset_cost_adj_rec.value,0);
             ELSE
               l_noa_pp_tbl(lnoa_index).subsidy := NVL(asset_cost_adj_rec.value,0);
             END IF;
             -- l_noa_pp_tbl(lnoa_index).subsidy := asset_cost_adj_rec.value;
	     -- Bug 7429169 : End
             ELSIF asset_cost_adj_rec.adjustment_source_type = G_TRADEIN_TYPE
             THEN
               l_noa_pp_tbl(lnoa_index).trade_in := nvl(asset_cost_adj_rec.VALUE, 0);
             END IF;
             put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'After Retrieving the Asset Cost Adjustments ');
             put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               'Down Payment| Trade In | Subsidy ' );
             put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               l_noa_pp_tbl(lnoa_index).down_payment || ' | ' || l_noa_pp_tbl(lnoa_index).trade_in || ' | ' || l_noa_pp_tbl(lnoa_index).subsidy );
           END LOOP;
           FOR asset_adj_rec IN asset_adj_csr(p_qte_id, assets_rec.ast_id)
           LOOP
             -- Dont know how to store the financed amount here
             l_noa_pp_tbl(lnoa_index).financed_amount := 0;
             -- Calculate the Capitalized Fee for this Asset
             FOR ct_rec IN get_asset_cap_fee_amt(
                            p_source_type       => 'ASSET',
                            p_source_id         => assets_rec.ast_id,
                            p_related_line_type => 'CAPITALIZED')
             LOOP
               l_noa_pp_tbl(lnoa_index).cap_fee_amount := nvl(ct_rec.capitalized_amount, 0);
             END LOOP;
             l_lq_residual_inflows(res_index).line_number := res_index;
             IF ( l_eot_type_code = 'PERCENT' OR l_eot_type_code = 'RESIDUAL_PERCENT' )
             THEN
               -- Store EOT %age in terms of Decimal like 0.25 for 25%
               l_lq_residual_inflows(res_index).cf_amount :=
                 (asset_adj_rec.end_of_term_value /100) * (assets_rec.oec_percentage/100);
               -- Accumulate Assets OEC in the l_sum_of_noa_oec_percent
               l_sum_of_noa_oec_percent := l_sum_of_noa_oec_percent + nvl(assets_rec.oec_percentage,0);
             ELSE
               -- EOT is mentioned in terms of Amount
               l_lq_residual_inflows(res_index).cf_amount   := asset_adj_rec.end_of_term_value;
             END IF;
             l_lq_residual_inflows(res_index).cf_date     := l_eot_date;
             l_lq_residual_inflows(res_index).cf_miss_pay := 'N';
             l_lq_residual_inflows(res_index).is_stub     := 'N';
             l_lq_residual_inflows(res_index).is_arrears  := 'Y';
             l_lq_residual_inflows(res_index).cf_dpp := l_cf_dpp;
             l_lq_residual_inflows(res_index).cf_ppy := l_cf_ppy;
             -- Store the Asset Residuals in the corresponding NOA Assets table
             l_noa_pp_tbl(lnoa_index).residual_inflows(1) := l_lq_residual_inflows(res_index);
             -- Increment the res_index
             res_index := res_index + 1;
           END LOOP;
           -- Bug 6669429 : Start
           l_lq_pricing_parameter_rec.financed_amount := l_lq_pricing_parameter_rec.financed_amount + nvl(l_noa_pp_tbl(lnoa_index).financed_amount,0);
           l_lq_pricing_parameter_rec.down_payment    := l_lq_pricing_parameter_rec.down_payment    + nvl(l_noa_pp_tbl(lnoa_index).down_payment,0);
           l_lq_pricing_parameter_rec.trade_in        := l_lq_pricing_parameter_rec.trade_in        + nvl(l_noa_pp_tbl(lnoa_index).trade_in,0);
           l_lq_pricing_parameter_rec.subsidy         := l_lq_pricing_parameter_rec.subsidy         + nvl(l_noa_pp_tbl(lnoa_index).subsidy,0);
           l_lq_pricing_parameter_rec.cap_fee_amount  := l_lq_pricing_parameter_rec.cap_fee_amount  + nvl(l_noa_pp_tbl(lnoa_index).cap_fee_amount,0);
           -- Bug 6669429 : End
           lnoa_index := lnoa_index + 1;
         ELSE -- IF l_overridden = FALSE in pricing method 'SF'
           -- Price this Asset which has overridden the payment strcuture defined on the LQ !
           IF assets_rec.fee_type = 'FREE_FORM1'  --, 'ROLLOVER', 'FINANCED' )
           THEN
             put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               ' Asset Overrides the Payment Structure defined @ Lease Quote level ' || assets_rec.asset_number );
             price_standard_quote_asset(
               x_return_status          => l_return_status,
               x_msg_count              => x_msg_count,
               x_msg_data               => x_msg_data,
               p_api_version            => p_api_version,
               p_init_msg_list          => p_init_msg_list,
               p_qte_id                 => p_qte_id,
               p_ast_id                 => nvl(assets_rec.ast_id, assets_rec.fee_id),
               p_price_at_lq_level      => FALSE, -- Use Asset Level Cash flows only !
               p_target_rate            => NULL,
               p_line_type              => assets_rec.fee_type,
               x_pricing_parameter_rec  => l_tmp_pricing_parameter_rec );
             put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       'PM = SF | After price_Standard_quote_asset l_return_Status = '|| l_return_status );
             IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
             ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
             END IF;
             l_pricing_parameter_tbl(pp_index) := l_tmp_pricing_parameter_rec;
             -- Increment the pp_index
             pp_index := pp_index + 1;
           END IF;
         END IF;
      END LOOP; -- Loop on the Assets csr
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 ' Number of Overriding Lines = ' || l_pricing_parameter_tbl.COUNT );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 ' Number of Non-Overriding Lines = ' || l_non_overiding_assets_tbl.COUNT );
      -- Store the Cash inflow streams and Residual streams in the l_lq_pricing_parameter_rec
      --  using amortization logic !
      IF l_non_overiding_assets_tbl.COUNT > 0
      THEN
        -- Manipulate the l_lq_residual_inflows such that the Effective EOT %age is based on
        --  OEC Percentage of only non-overriding Assets. Refer eg. in Bug. 5167302
        IF ( l_eot_type_code = 'PERCENT' OR l_eot_type_code = 'RESIDUAL_PERCENT' ) AND
            nvl(l_sum_of_noa_oec_percent,100) <> 100
        THEN
          IF l_lq_residual_inflows IS NOT NULL AND
             l_lq_residual_inflows.COUNT > 0
          THEN
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              ' !!!! Manipulating the Effective EOT %age. l_sum_of_noa_oec_percent = ' || round(l_sum_of_noa_oec_percent, 4) );
            FOR r_in IN l_lq_residual_inflows.FIRST .. l_lq_residual_inflows.LAST
            LOOP
              l_lq_residual_inflows(r_in).cf_amount := l_lq_residual_inflows(r_in).cf_amount * 100 /l_sum_of_noa_oec_percent;
            END LOOP;
          END IF;
          IF l_noa_pp_tbl IS NOT NULL AND l_noa_pp_tbl.COUNT > 0
          THEN
            FOR t_in IN l_noa_pp_tbl.FIRST .. l_noa_pp_tbl.LAST
            LOOP
              l_noa_pp_tbl(t_in).residual_inflows(1).cf_amount :=
                l_noa_pp_tbl(t_in).residual_inflows(1).cf_amount * 100 /l_sum_of_noa_oec_percent;
            END LOOP;
          END IF;
        END IF;
        -- If there is atleast one asset which follows the Payment Structure
        -- defined at Lease Quote Level, then pass the Pricing param table
        -- withe the Cash flows information at lease quote level else DON'T !!
        -- Store the Cash inflow streams and Residual streams in the l_lq_pricing_parameter_rec
        l_lq_pricing_parameter_rec.cash_inflows := l_lq_cash_inflows;
        l_lq_pricing_parameter_rec.residual_inflows := l_lq_residual_inflows;
        l_lq_pricing_parameter_rec.line_type := 'FREE_FORM1';
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
         'SF | ------------------ Before compute_iir ------------------  ' );
        IF l_eot_type_code = 'PERCENT' OR l_eot_type_code = 'RESIDUAL_PERCENT'
        THEN
          l_pricing_method := 'SFP';
        ELSE
          l_pricing_method := 'SF';
        END IF;
        compute_iir(
          p_api_version            => p_api_version,
          p_init_msg_list          => p_init_msg_list,
          x_return_status          => l_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_start_date             => quote_rec.expected_start_date,
          p_day_count_method       => l_day_count_method,
          p_pricing_method         => l_pricing_method,
          p_initial_guess          => l_initial_guess,
          px_pricing_parameter_rec => l_lq_pricing_parameter_rec,
          px_iir                   => x_iir,
          x_payment                => x_payment);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           'Pricing method = SF | After compute_iir l_return_Status = ' || l_return_status || ' Financed Amount = ' ||
           round(l_lq_pricing_parameter_rec.financed_amount, 4) );
        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
        IF l_pricing_method = 'SFP'
        THEN
          l_pricing_method := 'SF';  -- Revert back the pricing method to 'SF'
          -- Calculate the Residual Amount for each of the Non-overridden Asset for furhter yields calculation
          IF l_lq_pricing_parameter_rec.residual_inflows IS NOT NULL AND
             l_lq_pricing_parameter_rec.residual_inflows.COUNT > 0
          THEN
            FOR t_in IN l_lq_pricing_parameter_rec.residual_inflows.FIRST ..
                        l_lq_pricing_parameter_rec.residual_inflows.LAST
            LOOP
              l_lq_pricing_parameter_rec.residual_inflows(t_in).cf_amount :=
                l_lq_pricing_parameter_rec.residual_inflows(t_in).cf_amount *
                l_lq_pricing_parameter_rec.financed_amount;
              put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'l_lq_pricing_parameter_rec.residual_inflows(t_in).cf_amount = ' || round(l_lq_pricing_parameter_rec.residual_inflows(t_in).cf_amount, 4) );

            END LOOP;
          END IF; -- Count on Residual Table
          -- Calculate the Residual Amount for each of the Non-overridden Asset for pmnt calculation
          IF l_noa_pp_tbl IS NOT NULL AND l_noa_pp_tbl.COUNT > 0
          THEN
            FOR t_in IN l_noa_pp_tbl.FIRST .. l_noa_pp_tbl.LAST
            LOOP
              l_noa_pp_tbl(t_in).residual_inflows(1).cf_amount :=
                l_noa_pp_tbl(t_in).residual_inflows(1).cf_amount * l_lq_pricing_parameter_rec.financed_amount;
            END LOOP;
          END IF;
        END IF; -- IF l_pricing_method = 'SFP'
        -- So, we have now already solved for financed amount at lease quote level !
        -- We need to distribute the solved financed amount ( which is at the LQ level )
        --  to individual assets !
        l_an_ass_follow_lq   := TRUE;  -- Store the flag
        l_lq_details_prc_rec := l_lq_pricing_parameter_rec;
        distribute_fin_amount_lq(
          p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => l_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_lq_id           => p_qte_id,
          p_tot_fin_amount  => l_lq_pricing_parameter_rec.financed_amount);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After distribute_fin_amount_lq ' || l_return_status );
        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
        -- After compute_iir above, the l_lq_pricing_parameter_rec
        --  should have been populated with the appropriate values for
        --  Financed Amount, Down Payment, Subsidy and all
        -- pp_index is an post-assigned incremented index!
        --Commented. Bug 7440199: Quote Streams ER: RGOOTY: Start
        /*l_pricing_parameter_tbl(pp_index) := l_lq_pricing_parameter_rec;
        pp_index := pp_index + 1;*/
        -- Bug 7440199: Quote Streams ER: RGOOTY: End
        -- Pricing has to create the Cash Flow levels when the Pricing option is SRT.
        -- So, check whether the Cash flows have been already created by the Pricing or not
        -- If already created, then delete and create new else, create new cash flow levels.
        IF quote_rec.rate_template_id IS NOT NULL
        THEN
          IF l_cfo_exists_at_lq = 'YES'
          THEN
            -- Delete the Cash Flow Levels which may be already created by Pricing ..
            okl_lease_quote_cashflow_pvt.delete_cashflows (
              p_api_version          => p_api_version,
              p_init_msg_list        => p_init_msg_list,
              p_transaction_control  => NULL,
              p_source_object_code   => 'LEASE_QUOTE',
              p_source_object_id     => p_qte_id,
              x_return_status        => l_return_status,
              x_msg_count            => x_msg_count,
              x_msg_data             => x_msg_data);
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      ' ----- "SF" ---- After deleting the Cash flows @ LQ Level ' || l_return_status );
            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
              RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
            END IF;
          END IF;
          FOR cfl_index IN l_lq_payment_level_tbl.FIRST .. l_lq_payment_level_tbl.LAST
          LOOP
            l_lq_payment_level_tbl(cfl_index).record_mode := 'CREATE';
          END LOOP;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Before creating the cash flows call ' || 'Sty_id ' || l_lq_payment_header_rec.stream_type_id
            || 'Status_code ' || l_lq_payment_header_rec.status_code  );
          OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            p_transaction_control => NULL,
            p_cashflow_header_rec => l_lq_payment_header_rec,
            p_cashflow_level_tbl  => l_lq_payment_level_tbl,
            x_return_status       => l_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After update_cashflow call ' || l_Return_Status );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
             'After creating the cash flows call ' || 'Sty_id ' || l_lq_payment_header_rec.stream_type_id
             || 'Status_code ' || l_lq_payment_header_rec.status_code  );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF; -- Check if Pricing Option = SRT
        -- Bug 7440199: Quote Streams ER: RGOOTY: Start
        -- After compute_iir above, the l_lq_pricing_parameter_rec
        --  should have been populated with the appropriate values for
        --  Financed Amount, Down Payment, Subsidy and all
        -- pp_index is an post-assigned incremented index!
        l_lq_pricing_parameter_rec.cfo_id := l_lq_payment_header_rec.cashflow_object_id;
        l_pricing_parameter_tbl(pp_index) := l_lq_pricing_parameter_rec;
        pp_index := pp_index + 1;
        -- Bug 7440199: Quote Streams ER: RGOOTY: End
      END IF;
      -- Handling the ROLLOVER AND FINANCED FEES
      FOR assets_rec IN assets_csr(p_qte_id) -- ALL Assets or FEES
      LOOP
        IF  assets_rec.fee_type IN ( 'ROLLOVER', 'FINANCED')
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            ' Calling price_standard_quote_asset for ' || assets_rec.fee_type || ' with ID ' || assets_rec.fee_id );
          -- Price the fees ROLLOVER OR FINANCED
          price_standard_quote_asset(
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_api_version            => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_qte_id                 => p_qte_id,
            p_ast_id                 => nvl(assets_rec.ast_id, assets_rec.fee_id),
            p_price_at_lq_level      => FALSE, -- Use Fee Level Cash flows only !
            p_target_rate            => NULL,
            p_line_type              => assets_rec.fee_type,
            x_pricing_parameter_rec  => l_tmp_pricing_parameter_rec );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After price_standard_quote_asset ' || l_return_status );
          IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;
          l_pricing_parameter_tbl(pp_index) := l_tmp_pricing_parameter_rec;
          -- Increment the pp_index
          pp_index := pp_index + 1;
        END IF;
      END LOOP;
      -- Build Pricing Params for solving IIR @ LQ level
      l_pp_non_sub_iir_tbl := l_pricing_parameter_tbl;
      -- Now call the compute_iir api to solve the IIR @ Lease Quote Level
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 '!!!!!!!! Before Calculating the Subsidized IIR !!!!!!!!!!!' );
      l_iir_temp := NULL;
      l_iir_temp := l_subsidized_yields_rec.iir;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => x_iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pricing_parameter_tbl,
        -- px_irr                    => l_subsidized_yields_rec.iir,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
      l_subsidized_yields_rec.iir := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'After Calculating the Subsidized IIR ' || round(l_subsidized_yields_rec.iir, 4) );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Store the IIR as the Booking Yield
      l_subsidized_yields_rec.bk_yield :=  l_subsidized_yields_rec.iir;
      -- Now Build the pricing params table for the calculation of the
      --  IRR @ Lease Quote level
      l_pp_non_sub_irr_tbl := l_pricing_parameter_tbl;
      ppfs_index := nvl(l_pp_non_sub_irr_tbl.LAST, 0);
      -- Extract the fess information and built the Cash Inflows and Pricing Parameters
      FOR assets_rec IN assets_csr(p_qte_id)                 -- for all assets
      LOOP
        IF ( assets_rec.fee_type NOT IN ('FREE_FORM1', 'ROLLOVER', 'FINANCED', 'ABSORBED') )
        THEN
          -- Delete the previous fees cash flows
          l_fee_outflow_cfl_tbl.DELETE;
          l_fee_inflow_cfl_tbl.DELETE;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       '!!!!!!  Handling fee ' || assets_rec.fee_type );
          get_lq_fee_cash_flows(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => l_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_fee_type         => assets_rec.fee_type,
            p_lq_id            => p_qte_id,
            p_fee_id           => assets_rec.fee_id,
            x_outflow_caf_rec  => l_fee_outflow_caf_rec,
            x_outflow_cfl_tbl  => l_fee_outflow_cfl_tbl,
            x_inflow_caf_rec   => l_fee_inflow_caf_rec,
            x_inflow_cfl_tbl   => l_fee_inflow_cfl_tbl);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After get_lq_fee_cash_flows ' || l_return_status );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- Based on the outflows/Inflows obtained generate the streams
          IF l_fee_outflow_cfl_tbl.COUNT > 0
          THEN
            l_cash_inflows.DELETE;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!! Obtained Expense Cash flow levels !!!!!!!!' );
            gen_so_cf_strms(
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_cash_flow_rec          => l_fee_outflow_caf_rec,
              p_cf_details_tbl         => l_fee_outflow_cfl_tbl,
              x_cash_inflow_strms_tbl  => l_cash_inflows);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Place the information in the pricing params
            ppfs_index := ppfs_index + 1;
            l_pp_non_sub_irr_tbl(ppfs_index).line_type := assets_rec.fee_type;
            l_pp_non_sub_irr_tbl(ppfs_index).payment_type := 'EXPENSE';
            l_pp_non_sub_irr_tbl(ppfs_index).line_start_date := assets_rec.line_start_date;
            l_pp_non_sub_irr_tbl(ppfs_index).line_end_date := assets_rec.line_end_date;
            l_pp_non_sub_irr_tbl(ppfs_index).cash_inflows := l_cash_inflows;
            -- Bug 7440199: Quote Streams ER: RGOOTY: Start
            l_pp_non_sub_irr_tbl(ppfs_index).cfo_id := l_fee_outflow_caf_rec.cfo_id;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
          END IF;
          -- Based on the outflows/Inflows obtained generate the streams
          IF l_fee_inflow_cfl_tbl.COUNT > 0
          THEN
            l_cash_inflows.DELETE;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!! Obtained Income Cash flow levels !!!!!!!!' );
            gen_so_cf_strms(
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_cash_flow_rec          => l_fee_inflow_caf_rec,
              p_cf_details_tbl         => l_fee_inflow_cfl_tbl,
              x_cash_inflow_strms_tbl  => l_cash_inflows);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Place the information in the pricing params
            ppfs_index := ppfs_index + 1;
            l_pp_non_sub_irr_tbl(ppfs_index).line_type := assets_rec.fee_type;
            IF assets_rec.fee_type IN ( 'INCOME', 'MISCELLANEOUS' )
            THEN
              l_pp_non_sub_irr_tbl(ppfs_index).payment_type := 'INCOME';
            ELSE
              l_pp_non_sub_irr_tbl(ppfs_index).payment_type := 'SECDEPOSIT';
            END IF;
            l_pp_non_sub_irr_tbl(ppfs_index).line_start_date := assets_rec.line_start_date;
            l_pp_non_sub_irr_tbl(ppfs_index).line_end_date := assets_rec.line_end_date;
            l_pp_non_sub_irr_tbl(ppfs_index).cash_inflows := l_cash_inflows;
            -- Bug 7440199: Quote Streams ER: RGOOTY: Start
            l_pp_non_sub_irr_tbl(ppfs_index).cfo_id := l_fee_inflow_caf_rec.cfo_id;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
          END IF;
        END IF; -- IF on Fee_type not in ...
        IF  assets_rec.fee_type = 'ABSORBED'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!  Building cash inflows for this Absorbed fee ' || assets_rec.fee_type );
          -- Increment the pp_index and store the pricng params
          ppfs_index := ppfs_index + 1;
          l_pp_non_sub_irr_tbl(ppfs_index).payment_type := 'EXPENSE';
          l_pp_non_sub_irr_tbl(ppfs_index).financed_amount := assets_rec.fee_amount;
        END IF;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Populated the Fees and Service Pricing Params ' );
      -- Now call the compute_irr api to solve for the IIR @ LQ Level !
      l_iir_temp := NULL;
      l_iir_temp := l_subsidized_yields_rec.pre_tax_irr;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_irr_tbl,
        -- px_irr                    => l_subsidized_yields_rec.pre_tax_irr,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
      l_subsidized_yields_rec.pre_tax_irr := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'After Calculating the Subsidized IRR ' || round(l_subsidized_yields_rec.pre_tax_irr, 4) );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 '!!!!!!!!!!! NON-SUBSIDIZIED YIELDS CALCULATION !!!!!!!!!!!' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Removing subsidy from the l_pp_non_sub_iir_tbl ' );
      FOR t IN l_pp_non_sub_iir_tbl.FIRST .. l_pp_non_sub_iir_tbl.LAST
      LOOP
        IF l_pp_non_sub_iir_tbl(t).line_type = 'FREE_FORM1'
        THEN
          l_pp_non_sub_iir_tbl(t).subsidy := 0;
        END IF;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Before calculating the IIR ( NON-SUBSIDY ) ' );
      -- Now call the compute_irr api to solve for the IIR @ LQ Level !
      l_iir_temp := NULL;
      l_iir_temp := l_yields_rec.iir;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_iir_tbl,
        -- px_irr                    => l_yields_rec.iir,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
       l_yields_rec.iir := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'After Calculating the NON-Subsidized IIR ' || round(l_yields_rec.pre_tax_irr, 4) );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_yields_rec.bk_yield := l_yields_rec.iir;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Removing subsidy from the l_pp_non_sub_irr_tbl ' );
      FOR t IN l_pp_non_sub_irr_tbl.FIRST .. l_pp_non_sub_irr_tbl.LAST
      LOOP
        IF l_pp_non_sub_irr_tbl(t).line_type = 'FREE_FORM1'
        THEN
          l_pp_non_sub_irr_tbl(t).subsidy := 0;
        END IF;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Before calculating the IIR ( NON-SUBSIDY ) ' );
      -- Now call the compute_irr api to solve for the IIR @ LQ Level !
      l_iir_temp := NULL;
      l_iir_temp := l_yields_rec.pre_tax_irr;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_yields_rec.iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_irr_tbl,
        -- px_irr                    => l_yields_rec.pre_tax_irr,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
      l_yields_rec.pre_tax_irr := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'After Calculating the NON-Subsidized IRR ' || round(l_yields_rec.pre_tax_irr, 4) );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_disp_sf_msg) THEN
          OKL_API.SET_MESSAGE (
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_UNSUB_RATES_SF');
      END IF;
    ELSIF quote_rec.pricing_method = 'SI' OR
          quote_rec.pricing_method = 'SD' OR
          quote_rec.pricing_method = 'SS'
    THEN
      -- End of IF p_pricing_method = 'SF' and begin SI/SD/SS
      l_lq_pricing_parameter_rec.financed_amount := 0;
      l_lq_pricing_parameter_rec.down_payment := 0;
      l_lq_pricing_parameter_rec.trade_in := 0;
      l_lq_pricing_parameter_rec.subsidy  := 0;
      l_lq_pricing_parameter_rec.cap_fee_amount := 0;
      pp_index := 1;
      lnoa_index := 1;
      res_index := 1;
      l_non_overiding_assets_tbl.DELETE;
      -- Loop through all the Assets !
      FOR assets_rec IN assets_csr(p_qte_id)
      LOOP
        If assets_rec.fee_type <> 'FREE_FORM1'
        THEN
          l_overridden := TRUE;
        ELSE
          l_overridden := is_asset_overriding(
                          p_qte_id                => p_qte_id,
                          p_ast_id                => assets_rec.ast_id,
                          p_lq_line_level_pricing => quote_rec.line_level_pricing,
                          p_lq_srt_id             => quote_rec.rate_template_id,
                          p_ast_srt_id            => assets_rec.rate_template_id,
                          p_lq_struct_pricing     => quote_rec.structured_pricing,
                          p_ast_struct_pricing    => assets_rec.structured_pricing,
                          p_lq_arrears_yn         => quote_rec.target_arrears,
                          p_ast_arrears_yn        => assets_rec.target_arrears,
                          x_return_status         => l_return_status);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      'PM = SS/SD/ST | After is_asset_overriding | l_return_status = ' ||
                      l_return_status || ' | Asset ID = ' || assets_rec.ast_id );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        IF l_overridden = FALSE
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           'This configuration line follows payment defined @ LQ level !!' );
          -- Storing the non overriding assets for future
          l_non_overiding_assets_tbl(lnoa_index) := assets_rec.ast_id;
          FOR asset_cost_adj_rec IN asset_cost_adj_csr( qteid => p_qte_id,
                                                        astid => assets_rec.ast_id)
          LOOP
            IF asset_cost_adj_rec.adjustment_source_type = G_DOWNPAYMENT_TYPE AND
               quote_rec.pricing_method <> 'SD'
            THEN
              l_noa_pp_tbl(lnoa_index).down_payment := nvl(asset_cost_adj_rec.VALUE, 0 );
            ELSIF asset_cost_adj_rec.adjustment_source_type = G_SUBSIDY_TYPE AND
               quote_rec.pricing_method <> 'SS'
            THEN
              IF ( nvl(asset_cost_adj_rec.value, -9999) = -9999)
              THEN
                OPEN subsidy_adj_csr(asset_cost_adj_rec.ADJUSTMENT_SOURCE_ID);
                FETCH subsidy_adj_csr INTO subsidy_adj_rec;
                CLOSE subsidy_adj_csr;
                -- Bug 7429169: Start
                -- l_noa_pp_tbl(lnoa_index).subsidy := subsidy_adj_rec.amount;
                IF  l_noa_pp_tbl.EXISTS(lnoa_index)
                THEN
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(l_noa_pp_tbl(lnoa_index).subsidy,0) + NVL(subsidy_adj_rec.amount,0);
                ELSE
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(subsidy_adj_rec.amount,0);
                END IF;
                -- Bug 7429169: End
              ELSE
                -- l_noa_pp_tbl(lnoa_index).subsidy := asset_cost_adj_rec.value;
                IF  l_noa_pp_tbl.EXISTS(lnoa_index)
                THEN
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(l_noa_pp_tbl(lnoa_index).subsidy,0) + NVL(asset_cost_adj_rec.value,0);
                ELSE
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(asset_cost_adj_rec.value,0);
                END IF;
                -- Bug 7429169: End
              END IF;
            ELSIF asset_cost_adj_rec.adjustment_source_type = G_TRADEIN_TYPE AND
               quote_rec.pricing_method <> 'SI'
            THEN
              l_noa_pp_tbl(lnoa_index).trade_in := nvl(asset_cost_adj_rec.VALUE, 0 );
            END IF;
          END LOOP;
          FOR asset_adj_rec IN asset_adj_csr(p_qte_id, assets_rec.ast_id)
          LOOP
            l_noa_pp_tbl(lnoa_index).financed_amount := nvl(asset_adj_rec.oec,0);
            -- Calculate the Capitalized Fee for this Asset
            FOR ct_rec IN get_asset_cap_fee_amt(
                           p_source_type       => 'ASSET',
                           p_source_id         => assets_rec.ast_id,
                           p_related_line_type => 'CAPITALIZED')
            LOOP
              l_noa_pp_tbl(lnoa_index).cap_fee_amount := nvl(ct_rec.capitalized_amount, 0);
            END LOOP;
            l_lq_residual_inflows(res_index).line_number := res_index;
            IF ( l_eot_type_code = 'PERCENT' OR l_eot_type_code = 'RESIDUAL_PERCENT' )
            THEN
              -- EOT = OEC * EOT %age /100;
              l_lq_residual_inflows(res_index).cf_amount   :=
                nvl((asset_adj_rec.end_of_term_value/100) * l_noa_pp_tbl(lnoa_index).financed_amount, 0);
            ELSE
              -- EOT is an amount so directly store it ..
              l_lq_residual_inflows(res_index).cf_amount   := asset_adj_rec.end_of_term_value;
            END IF;
            l_lq_residual_inflows(res_index).cf_date     := l_eot_date;
            l_lq_residual_inflows(res_index).cf_miss_pay := 'N';
            l_lq_residual_inflows(res_index).is_stub     := 'N';
            l_lq_residual_inflows(res_index).is_arrears  := 'Y';
            l_lq_residual_inflows(res_index).cf_dpp := l_cf_dpp;
            l_lq_residual_inflows(res_index).cf_ppy := l_cf_ppy;
            -- Store the Asset Residuals in the corresponding NOA Assets table
            l_noa_pp_tbl(lnoa_index).residual_inflows(1) := l_lq_residual_inflows(res_index);
            -- Increment the res_index
            res_index := res_index + 1;
          END LOOP;
          -- Bug 6669429 : Start
          l_lq_pricing_parameter_rec.financed_amount := l_lq_pricing_parameter_rec.financed_amount + nvl(l_noa_pp_tbl(lnoa_index).financed_amount,0);
          l_lq_pricing_parameter_rec.down_payment    := l_lq_pricing_parameter_rec.down_payment    + nvl(l_noa_pp_tbl(lnoa_index).down_payment,0);
          l_lq_pricing_parameter_rec.trade_in        := l_lq_pricing_parameter_rec.trade_in        + nvl(l_noa_pp_tbl(lnoa_index).trade_in,0);
          l_lq_pricing_parameter_rec.subsidy         := l_lq_pricing_parameter_rec.subsidy         + nvl(l_noa_pp_tbl(lnoa_index).subsidy,0);
          l_lq_pricing_parameter_rec.cap_fee_amount  := l_lq_pricing_parameter_rec.cap_fee_amount  + nvl(l_noa_pp_tbl(lnoa_index).cap_fee_amount,0);
          -- Bug 6669429 : End
          -- Increment the lnoa_index
          lnoa_index := lnoa_index + 1;
        ELSE -- IF l_overridden = FALSE
          -- Price this Asset which has overridden the payment strcuture defined on the LQ !
            IF  assets_rec.fee_type = 'FREE_FORM1'
          THEN
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
             'Asset with ID ' || assets_rec.ast_id || ' is overriding the payment structure defined @ LQ level !!' );
            price_standard_quote_asset(
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              p_qte_id                 => p_qte_id,
              p_ast_id                 => nvl(assets_rec.ast_id, assets_rec.fee_id),
              p_price_at_lq_level      => FALSE, -- Use Asset Level Cash flows only !
              p_target_rate            => NULL,
              p_line_type              => assets_rec.fee_type,
              x_pricing_parameter_rec  => l_tmp_pricing_parameter_rec );
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Pricing method = ' || quote_rec.pricing_method || ' | After price_standard_quote_asset l_return_status = ' || l_return_status ||
              ' | assets_rec.ast_id = ' || assets_rec.ast_id  );
            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
              RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
            END IF;
            l_pricing_parameter_tbl(pp_index) := l_tmp_pricing_parameter_rec;
            -- Increment the pp_index
            pp_index := pp_index + 1;
          END IF;
        END IF;
      END LOOP; -- Loop on the Assets csr
      -- Now Solve for Subsidy/Trade in/Down Payment at the Lease Quote Level
      --  using amortization logic for assets which doesnot override the payment structure
      --  at lease quote level !
      IF l_non_overiding_assets_tbl.COUNT > 0
      THEN
        -- Store the Cash inflow streams and Residual streams in the l_lq_pricing_parameter_rec
        l_lq_pricing_parameter_rec.cash_inflows := l_lq_cash_inflows;
        l_lq_pricing_parameter_rec.residual_inflows := l_lq_residual_inflows;
        -- Step 1: Solve for DownPayment/Subsidy/Trade-in @ Lease Quote Level
        --         Using payment structures defined @ LQ !
        compute_iir(
          p_api_version            => p_api_version,
          p_init_msg_list          => p_init_msg_list,
          x_return_status          => l_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_start_date             => quote_rec.expected_start_date,
          p_day_count_method       => l_day_count_method,
          p_pricing_method         => quote_rec.pricing_method,
          p_initial_guess          => l_initial_guess,
          px_pricing_parameter_rec => l_lq_pricing_parameter_rec,
          px_iir                   => x_iir,
          x_payment                => x_payment);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Pricing Method =' || quote_rec.pricing_method || ' | 1/ After compute_iir at LQ level l_return_status = ' || l_return_status );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           'Financed Amount | Down Payment |  Subsidy Amount | Trade In Amount | CAP Fee Amt ' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           round(l_lq_pricing_parameter_rec.financed_amount, 4 ) || ' | ' || round(l_lq_pricing_parameter_rec.down_payment, 4)
           || ' | ' || round(l_lq_pricing_parameter_rec.subsidy, 4) || ' | ' || round(l_lq_pricing_parameter_rec.trade_in, 4)
           || ' | ' || round(l_lq_pricing_parameter_rec.cap_fee_amount, 4));
        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
        l_an_ass_follow_lq   := TRUE;  -- Store the flag
        l_lq_details_prc_rec := l_lq_pricing_parameter_rec;
        -- By now, we have solved for the Down Payment/Subsidy/Tradein @ LQ Level !
        -- Now calculate the IIR at the LQ Level. Here, we have to just consider those
        --  assets only which follow the payment structured defined at LQ level !
        -- l_lq_pricing_parameter_rec will be now updated with the solved
        --   DownPayment/Subsidy/Trade In
        -- Calculating the IIR at LQ level ( including only assets which follows the payment structure
        --   defined at the asset, 'coz there can be multiple paymnet levels in the payment structure !!
        l_lq_pp_noa_dts  := l_lq_pricing_parameter_rec;
        -- Proportionate the Solved Down Payment/Subsidy/TradeIn Amount now
        --  based on the Asset OEC ! -- TBD
        l_tot_noa_oec := 0;
        FOR t_index IN l_noa_pp_tbl.FIRST .. l_noa_pp_tbl.LAST
        LOOP
          l_tot_noa_oec := l_tot_noa_oec + nvl( l_noa_pp_tbl(t_index).financed_amount, 0 );
        END LOOP;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'SUM( OEC ) of non-overriding Assets ' || round( l_tot_noa_oec , 4 ));
        FOR t_index IN l_noa_pp_tbl.FIRST .. l_noa_pp_tbl.LAST
        LOOP
          ----------------------------------------------------------------------------------
          -- Create an Asset Cost Adjustment for the Solved Down Payment/Trade-in/Subsidy !!
          ----------------------------------------------------------------------------------
          l_ass_adj_tbl.DELETE;
          l_ass_adj_tbl(1).parent_object_code := 'ASSET';
          l_ass_adj_tbl(1).parent_object_id := l_non_overiding_assets_tbl(t_index); -- Asset ID
          l_ass_adj_tbl(1).basis := 'FIXED';
          IF quote_rec.pricing_method = 'SI'
          THEN
            l_ass_adj_tbl(1).adjustment_source_type := 'TRADEIN';
            l_ass_adj_tbl(1).VALUE := l_lq_pp_noa_dts.trade_in *
               l_noa_pp_tbl(t_index).financed_amount/ l_tot_noa_oec;
            l_noa_pp_tbl(t_index).trade_in := l_ass_adj_tbl(1).VALUE;
            l_adj_type := 'Trade-in';
          ELSIF quote_rec.pricing_method = 'SD'
          THEN
            l_ass_adj_tbl(1).adjustment_source_type := 'DOWN_PAYMENT';
            l_ass_adj_tbl(1).VALUE := l_lq_pp_noa_dts.down_payment *
               l_noa_pp_tbl(t_index).financed_amount/ l_tot_noa_oec;
            l_noa_pp_tbl(t_index).down_payment := l_ass_adj_tbl(1).VALUE;
            l_adj_type := 'Down Payment';
          ELSIF quote_rec.pricing_method = 'SS'
          THEN
            l_ass_adj_tbl(1).adjustment_source_type := 'SUBSIDY';
            l_ass_adj_tbl(1).VALUE := l_lq_pp_noa_dts.subsidy *
               l_noa_pp_tbl(t_index).financed_amount/ l_tot_noa_oec;
            l_noa_pp_tbl(t_index).subsidy := l_ass_adj_tbl(1).VALUE;
            l_adj_type := 'Subsidy';
          END IF;
          IF l_ass_adj_tbl(1).VALUE < 0
          THEN
            OKL_API.SET_MESSAGE (
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_NEGATIVE_ADJ_AMT',
              p_token1       => 'TYPE',
              p_token1_value => l_adj_type,
              p_token2       => 'AMOUNT',
              p_token2_value => round(l_ass_adj_tbl(1).VALUE,2));
            RAISE okl_api.g_exception_error;
          END IF;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Asset ID | Cost | Down Payment | Subsidy | Trade In ' );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            l_ass_adj_tbl(1).parent_object_id || ' | ' ||
            round( l_noa_pp_tbl(t_index).financed_amount , 4 ) || ' | ' ||
            round( l_noa_pp_tbl(t_index).down_payment , 4 ) || ' | ' ||
            round( l_noa_pp_tbl(t_index).subsidy , 4 ) || ' | ' ||
            round( l_noa_pp_tbl(t_index).trade_in , 4 ) );
          -- Create/Update the Solved Financial Adjustment
          okl_lease_quote_asset_pvt.create_adjustment(
             p_api_version             => p_api_version,
             p_init_msg_list           => p_init_msg_list,
             p_transaction_control     => FND_API.G_TRUE,
             p_asset_adj_tbl           => l_ass_adj_tbl,
             x_return_status           => l_return_status,
             x_msg_count               => x_msg_count,
             x_msg_data                => x_msg_data );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After okl_lease_quote.asset.create_adjustment ' || l_return_status);
          IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;
        END LOOP; -- Loop on the Non-overriding Assets
        l_lq_pricing_parameter_rec.line_type := 'FREE_FORM1';
        /* Commented. Bug 7440199: Quote Streams ER: RGOOTY: Start
        -- pp_index is an post-assigned incremented index!
        l_pricing_parameter_tbl(pp_index) := l_lq_pricing_parameter_rec;
        pp_index := pp_index + 1;*/
        -- Pricing has to create the Cash Flow levels when the Pricing option is SRT @ LQ level.
        -- So, check whether the Cash flows have been already created by the Pricing or not
        -- If already created, then delete and create new else, create new cash flow levels.
        IF quote_rec.rate_template_id IS NOT NULL
        THEN
          IF l_cfo_exists_at_lq = 'YES'
          THEN
            -- Delete the Cash Flow Levels which may be already created by Pricing ..
            okl_lease_quote_cashflow_pvt.delete_cashflows (
              p_api_version          => p_api_version,
              p_init_msg_list        => p_init_msg_list,
              p_transaction_control  => NULL,
              p_source_object_code   => 'LEASE_QUOTE',
              p_source_object_id     => p_qte_id,
              x_return_status        => l_return_status,
              x_msg_count            => x_msg_count,
              x_msg_data             => x_msg_data);
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      ' ----- "SD/SS/ST" ---- After deleting the Cash flows @ LQ Level ' || l_return_status );
            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
              RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
            END IF;
          END IF;
          FOR cfl_index IN l_lq_payment_level_tbl.FIRST .. l_lq_payment_level_tbl.LAST
          LOOP
            l_lq_payment_level_tbl(cfl_index).record_mode := 'CREATE';
          END LOOP;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Before creating the cash flows call ' || 'Sty_id ' || l_lq_payment_header_rec.stream_type_id
            || 'Status_code ' || l_lq_payment_header_rec.status_code  );
          OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            p_transaction_control => NULL,
            p_cashflow_header_rec => l_lq_payment_header_rec,
            p_cashflow_level_tbl  => l_lq_payment_level_tbl,
            x_return_status       => l_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After update_cashflow call ' || l_Return_Status );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'After creating the cash flows call ' || 'Sty_id ' || l_lq_payment_header_rec.stream_type_id
            || 'Status_code ' || l_lq_payment_header_rec.status_code  );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF; -- Check if Pricing Option = SRT
        -- Bug 7440199: Quote Streams ER: RGOOTY: Start
        -- pp_index is an post-assigned incremented index!
        l_lq_pricing_parameter_rec.cfo_id := l_lq_payment_header_rec.cashflow_object_id;
        l_pricing_parameter_tbl(pp_index) := l_lq_pricing_parameter_rec;
        pp_index := pp_index + 1;
        -- Bug 7440199: Quote Streams ER: RGOOTY: End
      END IF;  -- IF noa count > 0
      -- Fetch the ROLLOVER and Financed Fees Information
      FOR assets_rec IN assets_csr(p_qte_id)
      LOOP
        IF  assets_rec.fee_type IN ( 'ROLLOVER', 'FINANCED' )
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            ' Pricing for fee type ' || assets_rec.fee_type );
          price_standard_quote_asset(
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_api_version            => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_qte_id                 => p_qte_id,
            p_ast_id                 => nvl(assets_rec.ast_id, assets_rec.fee_id),
            p_price_at_lq_level      => FALSE, -- Use Asset Level Cash flows only !
            p_target_rate            => NULL,
            p_line_type              => assets_rec.fee_type,
            x_pricing_parameter_rec  => l_tmp_pricing_parameter_rec );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Pricing method = ' || quote_rec.pricing_method ||
                     ' | After price_standard_quote_asset l_return_status = ' || l_return_status ||
                     ' | assets_rec.ast_id = ' || assets_rec.ast_id  );
          IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;
          l_pricing_parameter_tbl(pp_index) := l_tmp_pricing_parameter_rec;
          -- Increment the pp_index
          pp_index := pp_index + 1;
        END IF;
      END LOOP; --       FOR assets_rec IN assets_csr(p_qte_id)
      -- Store the Pricing Params for later use
      l_pp_non_sub_iir_tbl := l_pricing_parameter_tbl;
      ----------------------------------------------------------------------
      -- Compute the IIR @ Lease quote level, considering all the Assets !
      ----------------------------------------------------------------------
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => x_iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pricing_parameter_tbl,
        px_irr                    => x_iir,
        x_payment                 => x_payment);
       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'After Calculating the Subsidized IIR ' || round(x_iir, 4) );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_subsidized_yields_rec.iir      :=  x_iir;
      l_subsidized_yields_rec.bk_yield :=  x_iir;
      -- Fetching the Fees and Service Information for the calculation of the
      -- Pre-tax Internal Rate of Return
      -- Extract the fess information and built the Cash Inflows and Pricing Parameters
      FOR assets_rec IN assets_csr(p_qte_id)                 -- for all assets
      LOOP
        IF ( assets_rec.fee_type NOT IN ('FREE_FORM1', 'ROLLOVER', 'FINANCED', 'ABSORBED') )
        THEN
          -- Delete the previous fees cash flows
          l_fee_outflow_cfl_tbl.DELETE;
          l_fee_inflow_cfl_tbl.DELETE;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       '!!!!!!  Handling fee ' || assets_rec.fee_type );
          get_lq_fee_cash_flows(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => l_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_fee_type         => assets_rec.fee_type,
            p_lq_id            => p_qte_id,
            p_fee_id           => assets_rec.fee_id,
            x_outflow_caf_rec  => l_fee_outflow_caf_rec,
            x_outflow_cfl_tbl  => l_fee_outflow_cfl_tbl,
            x_inflow_caf_rec   => l_fee_inflow_caf_rec,
            x_inflow_cfl_tbl   => l_fee_inflow_cfl_tbl);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After get_lq_fee_cash_flows ' || l_return_status );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- Based on the outflows/Inflows obtained generate the streams
          IF l_fee_outflow_cfl_tbl.COUNT > 0
          THEN
            l_cash_inflows.DELETE;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!! Obtained Expense Cash flow levels !!!!!!!!' );
            gen_so_cf_strms(
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_cash_flow_rec          => l_fee_outflow_caf_rec,
              p_cf_details_tbl         => l_fee_outflow_cfl_tbl,
              x_cash_inflow_strms_tbl  => l_cash_inflows);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Place the information in the pricing params
            l_pricing_parameter_tbl(pp_index).line_type := assets_rec.fee_type;
            l_pricing_parameter_tbl(pp_index).payment_type := 'EXPENSE';
            l_pricing_parameter_tbl(pp_index).line_start_date := assets_rec.line_start_date;
            l_pricing_parameter_tbl(pp_index).line_end_date := assets_rec.line_end_date;
            l_pricing_parameter_tbl(pp_index).cash_inflows := l_cash_inflows;
            -- Bug 7440199: Quote Streams ER: RGOOTY: Start
            l_pricing_parameter_tbl(pp_index).cfo_id := l_fee_outflow_caf_rec.cfo_id;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
            pp_index := pp_index + 1;
          END IF;
          -- Based on the outflows/Inflows obtained generate the streams
          IF l_fee_inflow_cfl_tbl.COUNT > 0
          THEN
            l_cash_inflows.DELETE;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!! Obtained Income Cash flow levels !!!!!!!!' );
            gen_so_cf_strms(
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_cash_flow_rec          => l_fee_inflow_caf_rec,
              p_cf_details_tbl         => l_fee_inflow_cfl_tbl,
              x_cash_inflow_strms_tbl  => l_cash_inflows);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Place the information in the pricing params
            l_pricing_parameter_tbl(pp_index).line_type := assets_rec.fee_type;
            IF assets_rec.fee_type IN ( 'INCOME', 'MISCELLANEOUS' )
            THEN
              l_pricing_parameter_tbl(pp_index).payment_type := 'INCOME';
            ELSE
              l_pricing_parameter_tbl(pp_index).payment_type := 'SECDEPOSIT';
            END IF;
            l_pricing_parameter_tbl(pp_index).line_start_date := assets_rec.line_start_date;
            l_pricing_parameter_tbl(pp_index).line_end_date := assets_rec.line_end_date;
            l_pricing_parameter_tbl(pp_index).cash_inflows := l_cash_inflows;
            -- Bug 7440199: Quote Streams ER: RGOOTY: Start
            l_pricing_parameter_tbl(pp_index).cfo_id := l_fee_inflow_caf_rec.cfo_id;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
            pp_index := pp_index + 1;
          END IF;
        END IF; -- IF on Fee_type not in ...
        IF  assets_rec.fee_type = 'ABSORBED'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!  Building cash inflows for this Absorbed fee ' || assets_rec.fee_type );
          -- Increment the pp_index and store the pricng params
          l_pricing_parameter_tbl(pp_index).payment_type := 'EXPENSE';
          l_pricing_parameter_tbl(pp_index).financed_amount := assets_rec.fee_amount;
          pp_index := pp_index + 1;
        END IF;
      END LOOP;
      -- Store the Pricing Params for calculation of Non-subsidized IRR
      l_pp_non_sub_irr_tbl := l_pricing_parameter_tbl;
      -- Now call the compute_irr api to solve for the IIR @ LQ Level !
      l_iir_temp := NULL;
      l_iir_temp := l_subsidized_yields_rec.pre_tax_irr;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pricing_parameter_tbl,
        -- px_irr                    => l_subsidized_yields_rec.pre_tax_irr,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
      l_subsidized_yields_rec.pre_tax_irr := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'After Calculating the Subsidized IRR ' || round(l_subsidized_yields_rec.pre_tax_irr, 4) );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 '!!!!!!!!!!! NON-SUBSIDIZIED YIELDS CALCULATION !!!!!!!!!!!' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Removing subsidy from the l_pp_non_sub_iir_tbl ' );
      FOR t IN l_pp_non_sub_iir_tbl.FIRST .. l_pp_non_sub_iir_tbl.LAST
      LOOP
        IF l_pp_non_sub_iir_tbl(t).line_type = 'FREE_FORM1'
        THEN
          l_pp_non_sub_iir_tbl(t).subsidy := 0;
        END IF;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Before calculating the IIR ( NON-SUBSIDY ) ' );
      -- Now call the compute_irr api to solve for the IIR @ LQ Level !
      l_iir_temp := NULL;
      l_iir_temp := l_yields_rec.iir;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_iir_tbl,
        -- px_irr                    => l_yields_rec.iir,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
       l_yields_rec.iir := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'After Calculating the NON-Subsidized IIR ' || round(l_yields_rec.pre_tax_irr, 4) );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_yields_rec.bk_yield := l_yields_rec.iir;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Removing subsidy from the l_pp_non_sub_irr_tbl ' );
      FOR t IN l_pp_non_sub_irr_tbl.FIRST .. l_pp_non_sub_irr_tbl.LAST
      LOOP
        IF l_pp_non_sub_irr_tbl(t).line_type = 'FREE_FORM1'
        THEN
          l_pp_non_sub_irr_tbl(t).subsidy := 0;
        END IF;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Before calculating the IIR ( NON-SUBSIDY ) ' );
      -- Now call the compute_irr api to solve for the IIR @ LQ Level !
      l_iir_temp := NULL;
      l_iir_temp := l_yields_rec.pre_tax_irr;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_yields_rec.iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_irr_tbl,
        -- px_irr                    => l_yields_rec.pre_tax_irr,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
       l_yields_rec.pre_tax_irr := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'After Calculating the NON-Subsidized IRR ' || round(l_yields_rec.pre_tax_irr, 4) );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF quote_rec.pricing_method = 'TR'
    THEN
      -- Target for rate, which is IIR !
      l_lq_pricing_parameter_rec.line_type := 'FREE_FORM1';
      l_lq_pricing_parameter_rec.financed_amount := 0;
      l_lq_pricing_parameter_rec.down_payment := 0;
      l_lq_pricing_parameter_rec.trade_in := 0;
      l_lq_pricing_parameter_rec.subsidy := 0;
      l_lq_pricing_parameter_rec.cap_fee_amount := 0;
      pp_index := 1;
      lnoa_index := 1;
      res_index := 1;
      l_non_overiding_assets_tbl.DELETE;
      -- Loop through the Assets and check price the asset seperately
      --  which has overriddent the payment option picked at the Quote Level
      FOR assets_rec IN assets_csr(p_qte_id)                 -- for all assets
      LOOP
        -- Check whether this Asset has overridden the Payment option defined
        --  at the quote level !
        IF ( assets_rec.fee_type <> 'FREE_FORM1' )
        THEN
          -- For financed fee/Rollover fee its not yet clear ..but
          -- pricing needs to solve the payments for them for sure !
          l_overridden := TRUE;
        ELSE
          -- All assets in TR pricing method follow the pricing option picked at lease quote
          l_overridden := FALSE;
        END IF;
        IF l_overridden = FALSE
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   '  Asset Follows the Payment Structure @ Lease Quote Level ' || assets_rec.asset_number );
          -- If asset is not overriding the Payment option defined at the Quote Level ...
          -- Store the Asset Id for later use ..
          l_non_overiding_assets_tbl(lnoa_index) := assets_rec.ast_id;
          -- Fetch the Asset Cost Adjustment Details for each Asset and accumulate them
          --  in the lx_pricing_parameter_rec
          FOR asset_cost_adj_rec IN asset_cost_adj_csr( qteid => p_qte_id,
                                                        astid => assets_rec.ast_id)
          LOOP
            IF asset_cost_adj_rec.adjustment_source_type = G_DOWNPAYMENT_TYPE
            THEN
              l_noa_pp_tbl(lnoa_index).down_payment := nvl(asset_cost_adj_rec.VALUE, 0 );
            ELSIF asset_cost_adj_rec.adjustment_source_type = G_SUBSIDY_TYPE
            THEN
              IF ( nvl(asset_cost_adj_rec.value, -9999) = -9999)
              THEN
                OPEN subsidy_adj_csr(asset_cost_adj_rec.ADJUSTMENT_SOURCE_ID);
                FETCH subsidy_adj_csr INTO subsidy_adj_rec;
                CLOSE subsidy_adj_csr;
                -- Bug 7429169 : Start
                -- l_noa_pp_tbl(lnoa_index).subsidy := subsidy_adj_rec.amount;
                IF  l_noa_pp_tbl.EXISTS(lnoa_index)
                THEN
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(l_noa_pp_tbl(lnoa_index).subsidy,0) + NVL(subsidy_adj_rec.amount,0);
                ELSE
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(subsidy_adj_rec.amount,0);
                END IF;
                -- Bug 7429169 : End
              ELSE
                -- Bug 7429169 : Start
                -- l_noa_pp_tbl(lnoa_index).subsidy := asset_cost_adj_rec.value;
                IF  l_noa_pp_tbl.EXISTS(lnoa_index)
                THEN
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(l_noa_pp_tbl(lnoa_index).subsidy,0) + NVL(asset_cost_adj_rec.value,0);
                ELSE
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(asset_cost_adj_rec.value,0);
                END IF;
                -- Bug 7429169 : End
              END IF;
            ELSIF asset_cost_adj_rec.adjustment_source_type = G_TRADEIN_TYPE
            THEN
              l_noa_pp_tbl(lnoa_index).trade_in := nvl(asset_cost_adj_rec.VALUE, 0);
            END IF;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                        'After Retrieving the Asset Cost Adjustments ');
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       'Down Payment| Trade In | Subsidy ' );
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               l_noa_pp_tbl(lnoa_index).down_payment || ' | ' || l_noa_pp_tbl(lnoa_index).trade_in || ' | ' ||
               l_noa_pp_tbl(lnoa_index).subsidy );
          END LOOP;
          FOR asset_adj_rec IN asset_adj_csr(p_qte_id, assets_rec.ast_id)
          LOOP
            l_noa_pp_tbl(lnoa_index).financed_amount := nvl(asset_adj_rec.oec,0);
            -- Calculate the Capitalized Fee for this Asset
            FOR ct_rec IN get_asset_cap_fee_amt(
                           p_source_type       => 'ASSET',
                           p_source_id         => assets_rec.ast_id,
                           p_related_line_type => 'CAPITALIZED')
            LOOP
              l_noa_pp_tbl(lnoa_index).cap_fee_amount := nvl(ct_rec.capitalized_amount, 0);
            END LOOP;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Unit Cost=' || asset_adj_rec.unit_cost || ' No. of Units ' || asset_adj_rec.number_of_units);
            l_lq_residual_inflows(res_index).line_number := res_index;
            l_lq_residual_inflows(res_index).line_number := res_index;
            IF ( l_eot_type_code = 'PERCENT' OR l_eot_type_code = 'RESIDUAL_PERCENT' )
            THEN
              -- EOT = OEC * EOT %age /100;
              l_lq_residual_inflows(res_index).cf_amount   :=
                nvl((asset_adj_rec.end_of_term_value/100) * l_noa_pp_tbl(lnoa_index).financed_amount, 0);
            ELSE
              -- EOT is an amount so directly store it ..
              l_lq_residual_inflows(res_index).cf_amount   := asset_adj_rec.end_of_term_value;
            END IF;
            l_lq_residual_inflows(res_index).cf_date     := l_eot_date;
            l_lq_residual_inflows(res_index).cf_miss_pay := 'N';
            l_lq_residual_inflows(res_index).is_stub     := 'N';
            l_lq_residual_inflows(res_index).is_arrears  := 'Y';
            l_lq_residual_inflows(res_index).cf_dpp := l_cf_dpp;
            l_lq_residual_inflows(res_index).cf_ppy := l_cf_ppy;
            -- Store the Asset Residuals in the corresponding NOA Assets table
            l_noa_pp_tbl(lnoa_index).residual_inflows(1) := l_lq_residual_inflows(res_index);
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Financed Amount = ' || l_noa_pp_tbl(lnoa_index).financed_amount);
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Storing residual amt ' || l_lq_residual_inflows(res_index).cf_amount );
            -- Increment the res_index
            res_index := res_index + 1;
          END LOOP;
          -- Bug 6669429 : Start
          l_lq_pricing_parameter_rec.financed_amount := l_lq_pricing_parameter_rec.financed_amount + nvl(l_noa_pp_tbl(lnoa_index).financed_amount,0);
          l_lq_pricing_parameter_rec.down_payment    := l_lq_pricing_parameter_rec.down_payment    + nvl(l_noa_pp_tbl(lnoa_index).down_payment,0);
          l_lq_pricing_parameter_rec.trade_in        := l_lq_pricing_parameter_rec.trade_in        + nvl(l_noa_pp_tbl(lnoa_index).trade_in,0);
          l_lq_pricing_parameter_rec.subsidy         := l_lq_pricing_parameter_rec.subsidy         + nvl(l_noa_pp_tbl(lnoa_index).subsidy,0);
          l_lq_pricing_parameter_rec.cap_fee_amount  := l_lq_pricing_parameter_rec.cap_fee_amount  + nvl(l_noa_pp_tbl(lnoa_index).cap_fee_amount,0);
          -- Bug 6669429 : End
          lnoa_index := lnoa_index + 1;
        END IF;
      END LOOP; -- Loop on the Assets csr
      -- Store the Cash inflow streams and Residual streams in the l_lq_pricing_parameter_rec
      --  at the Lease Quote Header Level
      l_lq_pricing_parameter_rec.cash_inflows     := l_lq_cash_inflows;
      l_lq_pricing_parameter_rec.residual_inflows := l_lq_residual_inflows;
      -- Bug 7440199: Quote Streams ER: RGOOTY: Start
      l_lq_pricing_parameter_rec.cfo_id := l_lq_cash_flow_rec.cfo_id;
      -- Bug 7440199: Quote Streams ER: RGOOTY: End
      l_an_ass_follow_lq   := TRUE;  -- Store the flag
      l_lq_details_prc_rec := l_lq_pricing_parameter_rec;
      -- Extract and preserve the Fees and Other Information and
      -- store it in l_pp_lq_fee_srv_tbl
      l_pp_non_sub_iir_tbl.DELETE;
      l_pp_non_sub_iir_tbl(1) := l_lq_pricing_parameter_rec;
      ppfs_index := 1; -- Only one pricing parameter rec would have been built
      -- Need to derieve the Payment for the FINANCED/ROLLOVER Fees.
      FOR assets_rec IN assets_csr(p_qte_id) -- ALL Assets or FEES
      LOOP
        IF  assets_rec.fee_type IN ( 'ROLLOVER', 'FINANCED')
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            ' Calling price_standard_quote_asset for ' || assets_rec.fee_type || ' with ID ' || assets_rec.fee_id );
          -- Price the fees ROLLOVER OR FINANCED
          price_standard_quote_asset(
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_api_version            => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_qte_id                 => p_qte_id,
            p_ast_id                 => nvl(assets_rec.ast_id, assets_rec.fee_id),
            p_price_at_lq_level      => TRUE, -- Use Asset Level Cash flows only !
            p_target_rate            => quote_rec.target_rate / 100,
            p_line_type              => assets_rec.fee_type,
            x_pricing_parameter_rec  => l_tmp_pricing_parameter_rec );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After price_standard_quote_asset ' || l_return_status );
          IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;
          FOR t_in IN l_tmp_pricing_parameter_rec.cash_inflows.FIRST ..
                      l_tmp_pricing_parameter_rec.cash_inflows.LAST
          LOOP
            l_tmp_pricing_parameter_rec.cash_inflows(t_in).locked_amt := 'Y';
          END LOOP;
          -- Store the ROLLOVER/FINANCED Fee PP Rec in the l_pp_non_sub_iir_tbl
          ppfs_index := ppfs_index + 1;
          l_pp_non_sub_iir_tbl(ppfs_index) :=  l_tmp_pricing_parameter_rec;
        END IF;
      END LOOP;
      l_pp_non_sub_irr_tbl.DELETE;
      l_pp_non_sub_irr_tbl := l_pp_non_sub_iir_tbl;
      -- Extract the fess information and built the Cash Inflows and Pricing Parameters
      FOR assets_rec IN assets_csr(p_qte_id)                 -- for all assets
      LOOP
        IF ( assets_rec.fee_type NOT IN ('FREE_FORM1', 'ROLLOVER', 'FINANCED', 'ABSORBED') )
        THEN
          -- Delete the previous fees cash flows
          l_fee_outflow_cfl_tbl.DELETE;
          l_fee_inflow_cfl_tbl.DELETE;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       '!!!!!!  Handling fee ' || assets_rec.fee_type );
          get_lq_fee_cash_flows(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => l_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_fee_type         => assets_rec.fee_type,
            p_lq_id            => p_qte_id,
            p_fee_id           => assets_rec.fee_id,
            x_outflow_caf_rec  => l_fee_outflow_caf_rec,
            x_outflow_cfl_tbl  => l_fee_outflow_cfl_tbl,
            x_inflow_caf_rec   => l_fee_inflow_caf_rec,
            x_inflow_cfl_tbl   => l_fee_inflow_cfl_tbl);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After get_lq_fee_cash_flows ' || l_return_status );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- Based on the outflows/Inflows obtained generate the streams
          IF l_fee_outflow_cfl_tbl.COUNT > 0
          THEN
            l_cash_inflows.DELETE;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!! Obtained Expense Cash flow levels !!!!!!!!' );
            IF quote_rec.target_rate_type = 'PIRR'
            THEN
              FOR t_in IN l_fee_outflow_cfl_tbl.FIRST ..l_fee_outflow_cfl_tbl.LAST
              LOOP
                l_fee_outflow_cfl_tbl(t_in).rate := quote_rec.target_rate;
              END LOOP;
            END IF;
            gen_so_cf_strms(
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_cash_flow_rec          => l_fee_outflow_caf_rec,
              p_cf_details_tbl         => l_fee_outflow_cfl_tbl,
              x_cash_inflow_strms_tbl  => l_cash_inflows);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Place the information in the pricing params
            ppfs_index := ppfs_index + 1;
            l_pp_non_sub_irr_tbl(ppfs_index).line_type := assets_rec.fee_type;
            l_pp_non_sub_irr_tbl(ppfs_index).payment_type := 'EXPENSE';
            l_pp_non_sub_irr_tbl(ppfs_index).line_start_date := assets_rec.line_start_date;
            l_pp_non_sub_irr_tbl(ppfs_index).line_end_date := assets_rec.line_end_date;
            l_pp_non_sub_irr_tbl(ppfs_index).cash_inflows := l_cash_inflows;
            --- Bug 7440199: Quote Streams ER: RGOOTY: Start
            l_pp_non_sub_irr_tbl(ppfs_index).cfo_id := l_fee_outflow_caf_rec.cfo_id;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
          END IF;
          -- Based on the outflows/Inflows obtained generate the streams
          IF l_fee_inflow_cfl_tbl.COUNT > 0
          THEN
            l_cash_inflows.DELETE;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!! Obtained Income Cash flow levels !!!!!!!!' );
            IF quote_rec.target_rate_type = 'PIRR'
            THEN
              FOR t_in IN l_fee_inflow_cfl_tbl.FIRST ..l_fee_inflow_cfl_tbl.LAST
              LOOP
                l_fee_inflow_cfl_tbl(t_in).rate := quote_rec.target_rate;
              END LOOP;
            END IF;
            gen_so_cf_strms(
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_cash_flow_rec          => l_fee_inflow_caf_rec,
              p_cf_details_tbl         => l_fee_inflow_cfl_tbl,
              x_cash_inflow_strms_tbl  => l_cash_inflows);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Place the information in the pricing params
            ppfs_index := ppfs_index + 1;
            l_pp_non_sub_irr_tbl(ppfs_index).line_type := assets_rec.fee_type;
            IF assets_rec.fee_type IN ( 'INCOME', 'MISCELLANEOUS' )
            THEN
              l_pp_non_sub_irr_tbl(ppfs_index).payment_type := 'INCOME';
            ELSE
              l_pp_non_sub_irr_tbl(ppfs_index).payment_type := 'SECDEPOSIT';
            END IF;
            l_pp_non_sub_irr_tbl(ppfs_index).line_start_date := assets_rec.line_start_date;
            l_pp_non_sub_irr_tbl(ppfs_index).line_end_date := assets_rec.line_end_date;
            l_pp_non_sub_irr_tbl(ppfs_index).cash_inflows := l_cash_inflows;
            -- Bug 7440199: Quote Streams ER: RGOOTY: Start
            l_pp_non_sub_irr_tbl(ppfs_index).cfo_id := l_fee_inflow_caf_rec.cfo_id;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
          END IF;
        END IF; -- IF on Fee_type not in ...
        IF  assets_rec.fee_type = 'ABSORBED'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!  Building cash inflows for this Absorbed fee ' || assets_rec.fee_type );
          -- Increment the pp_index and store the pricng params
          ppfs_index := ppfs_index + 1;
          l_pp_non_sub_irr_tbl(ppfs_index).payment_type := 'EXPENSE';
          l_pp_non_sub_irr_tbl(ppfs_index).financed_amount := assets_rec.fee_amount;
        END IF;
      END LOOP;-- FOR LOOP ON Assets_csr
      -- Solve for the Payment
      IF quote_rec.target_rate_type = 'IIR'
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Calling the IIR api to solve the payment amount ' );
        -- Now solve the Payment amount calling the compute_irr
        compute_irr(
          p_api_version             => p_api_version,
          p_init_msg_list           => p_init_msg_list,
          x_return_status           => l_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          p_start_date              => quote_rec.expected_start_date,
          p_day_count_method        => l_day_count_method,
          p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
          p_pricing_method          => quote_rec.pricing_method,
          p_initial_guess           => l_initial_guess, -- Use the IIR derieved prev. as initial guess
          px_pricing_parameter_tbl  => l_pp_non_sub_iir_tbl,
          px_irr                    => x_iir,
          x_payment                 => x_payment);
        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
        -- IIR @ LQ level has already been given by the user itself ..
        --   So, we wont be calling the compute_irr api just passing the assets information.
        l_subsidized_yields_rec.iir :=  quote_rec.target_rate / 100;
        l_subsidized_yields_rec.bk_yield :=  l_subsidized_yields_rec.iir;
      ELSE
        l_iir_temp := NULL;
        l_iir_temp := l_subsidized_yields_rec.pre_tax_irr;
        compute_irr(
          p_api_version             => p_api_version,
          p_init_msg_list           => p_init_msg_list,
          x_return_status           => l_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          p_start_date              => quote_rec.expected_start_date,
          p_day_count_method        => l_day_count_method,
          p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
          p_pricing_method          => quote_rec.pricing_method,
          p_initial_guess           => x_iir, -- Use the IIR derieved prev. as initial guess
          px_pricing_parameter_tbl  => l_pp_non_sub_irr_tbl,
          -- px_irr                    => l_subsidized_yields_rec.pre_tax_irr,
          px_irr                    => l_iir_temp,
          x_payment                 => x_payment);

        l_subsidized_yields_rec.pre_tax_irr := l_iir_temp;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   quote_rec.pricing_method || ': FINAL: After compute_irr ' || l_return_status );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_subsidized_yields_rec.pre_tax_irr := quote_rec.target_rate / 100;
      END IF;
      IF x_payment < 0
      THEN
        OKL_API.SET_MESSAGE (
          p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKL_NEGATIVE_ADJ_AMT',
          p_token1       => 'TYPE',
          p_token1_value => 'Payment',
          p_token2       => 'AMOUNT',
          p_token2_value => round(x_payment,2) );
        RAISE okl_api.g_exception_error;
      END IF;
      -- Store the Calculated Payment amount back in the quote Header
      l_lease_qte_rec.target_amount := x_payment;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'SOLVED TARGET AMOUNT ' || round(l_lease_qte_rec.target_amount,4) );
      -- Pricing need to create CFO, CFH, CFL @ Lease Quote level storing this
      --  targetted Amount
      -- When the pricing method is Target Rate, pricing will create cash flows with
      -- only one cash flow level always, which is a regular payment. Hence, updating the CFL
      -- with the solved amount.
      FOR t_in IN l_lq_payment_level_tbl.FIRST .. l_lq_payment_level_tbl.LAST
      LOOP
        l_lq_payment_level_tbl(t_in).periodic_amount := x_payment;
      END LOOP;
      IF l_cfo_exists_at_lq = 'YES'
      THEN
        -- Update the CFL Table
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Before OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow l_lq_payment_header_rec  '
                   || l_lq_payment_header_rec.stream_type_id
                   || ' status_code ' || l_lq_payment_header_rec.status_code );
        OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow (
          p_api_version         => G_API_VERSION,
          p_init_msg_list       => p_init_msg_list,
          p_transaction_control => G_FALSE,
          p_cashflow_header_rec => l_lq_payment_header_rec,
          p_cashflow_level_tbl  => l_lq_payment_level_tbl,
          x_return_status       => l_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow ' || l_return_status );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow l_lq_payment_header_rec  '
                   || l_lq_payment_header_rec.stream_type_id
                   || ' status_code ' || l_lq_payment_header_rec.status_code );
        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'Before OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow l_lq_payment_header_rec  '
                   || l_lq_payment_header_rec.stream_type_id
                   || ' status_code ' || l_lq_payment_header_rec.status_code );
        OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow (
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_transaction_control => G_FALSE,
          p_cashflow_header_rec => l_lq_payment_header_rec,
          p_cashflow_level_tbl  => l_lq_payment_level_tbl,
          x_return_status       => l_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow ' || l_return_status );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow l_lq_payment_header_rec  '
                   || l_lq_payment_header_rec.stream_type_id
                   || ' status_code ' || l_lq_payment_header_rec.status_code );
        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Bug 7440199: Quote Streams ER: RGOOTY: Start
        l_pp_non_sub_irr_tbl(1).cfo_id := l_lq_payment_header_rec.cashflow_object_id;
        -- Bug 7440199: Quote Streams ER: RGOOTY: End
      END IF;
     -- Update pmnt. amount in l_pp_non_sub_iir_tbl(1).cash_inflows and l_pp_non_sub_irr_tbl(1).cash_inflows
     put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  '***** Updating the stream elements with the solved amount *****');
      FOR t IN l_pp_non_sub_iir_tbl(1).cash_inflows.FIRST ..
               l_pp_non_sub_iir_tbl(1).cash_inflows.LAST
      LOOP
        -- Update the Cash Inflow Streams for the FREE_FORM1 line !
        l_pp_non_sub_iir_tbl(1).cash_inflows(t).cf_amount := x_payment;
        l_pp_non_sub_irr_tbl(1).cash_inflows(t).cf_amount := x_payment;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   l_pp_non_sub_iir_tbl(1).cash_inflows(t).cf_date || ' | ' ||
                   l_pp_non_sub_iir_tbl(1).cash_inflows(t).cf_amount );
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Updated the Payment amount back in the Cash Inflows ');
      -- Need to solve for the IIR if Target_Rate is PIRR else Solve for IRR if
      --  target rate type is IIR
      IF quote_rec.target_rate_type = 'IIR'
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   '******** Solving for the Subsidized IRR ********** ' );
        l_iir_temp := NULL;
        l_iir_temp := l_subsidized_yields_rec.pre_tax_irr;
        compute_irr(
          p_api_version             => p_api_version,
          p_init_msg_list           => p_init_msg_list,
          x_return_status           => l_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          p_start_date              => quote_rec.expected_start_date,
          p_day_count_method        => l_day_count_method,
          p_currency_code           => l_currency,
          p_pricing_method          => 'SY',
          p_initial_guess           => l_subsidized_yields_rec.iir, -- Use the IIR derieved prev. as initial guess
          px_pricing_parameter_tbl  => l_pp_non_sub_irr_tbl,
          -- px_irr                    => l_subsidized_yields_rec.pre_tax_irr,
          px_irr                    => l_iir_temp,
          x_payment                 => x_payment);
        l_subsidized_yields_rec.pre_tax_irr := l_iir_temp;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   quote_rec.pricing_method || ': FINAL: After compute_irr ' || l_return_status );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   '******** Solving for the Subsidized IIR ********** ' );
        -- Now solve the Payment amount calling the compute_iir
        compute_irr(
          p_api_version             => p_api_version,
          p_init_msg_list           => p_init_msg_list,
          x_return_status           => l_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          p_start_date              => quote_rec.expected_start_date,
          p_day_count_method        => l_day_count_method,
          p_currency_code           => l_currency,
          p_pricing_method          => 'SY',
          p_initial_guess           => l_subsidized_yields_rec.pre_tax_irr, -- Use the IIR derieved prev. as initial guess
          px_pricing_parameter_tbl  => l_pp_non_sub_iir_tbl,
          px_irr                    => x_iir,
          x_payment                 => x_payment);
        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
        -- IIR @ LQ level has already been given by the user itself ..
        --   So, we wont be calling the compute_irr api just passing the assets information.
        l_subsidized_yields_rec.iir :=  x_iir;
        l_subsidized_yields_rec.bk_yield :=  x_iir;
      END IF;
      -- Solve for the Non-Subsidized Yields now
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 '!!!!!!!!!!!!! SOLVING FOR NON-SUBSIDIZED YIELDS NOW !!!!!!!!!!!!!!!!! ' );
      -- Loop through the l_pp_non_sub_iir_tbl table and make the Subsidy Amount to zero !
      FOR ny IN l_pp_non_sub_iir_tbl.FIRST .. l_pp_non_sub_iir_tbl.LAST
      LOOP
        -- line_type, subsidy
        l_pp_non_sub_iir_tbl(ny).subsidy := 0;
      END LOOP;
      l_iir_temp := NULL;
      l_iir_temp := l_yields_rec.iir;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_iir_tbl, -- includes the fees as well
        -- px_irr                    => l_yields_rec.iir,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
      l_yields_rec.iir := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of IIR (NON-SUBSIDIZED) ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR IIR (NON-SUBSIDY)' || l_yields_rec.iir );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Store the IIR as the Booking Yield
      l_yields_rec.bk_yield := l_yields_rec.iir;
      -- Loop through the l_pp_non_sub_iir_tbl table and make the Subsidy Amount to zero !
      FOR ny IN l_pp_non_sub_irr_tbl.FIRST .. l_pp_non_sub_irr_tbl.LAST
      LOOP
        -- line_type, subsidy
        l_pp_non_sub_irr_tbl(ny).subsidy := 0;
      END LOOP;
      -- Loop through the l_pp_non_sub_iir_tbl table and delete the Subsidy Amount
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '1/ Before Computation of IRR @ LQ Level ' );
      l_iir_temp := NULL;
      l_iir_temp := l_yields_rec.pre_tax_irr;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.pre_tax_irr, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_irr_tbl, -- includes the fees as well
        -- px_irr                    => l_yields_rec.pre_tax_irr,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
      l_yields_rec.pre_tax_irr := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of IRR @ LQ Level ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR IRR (NON-SUBSIDY)' || l_yields_rec.pre_tax_irr );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF quote_rec.pricing_method = 'RC'
    THEN
      -- Fetch the SGT Day convention to be used
      get_lq_sgt_day_convention(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_lq_id             => p_qte_id,
        x_days_in_month     => l_days_in_month,
        x_days_in_year      => l_days_in_year);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   ': After Fetching the Day convention from the SGT - RC ' );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Get the Day count method for passing into the compute_irr api version.
      get_day_count_method(
        p_days_in_month    => l_days_in_month,
        p_days_in_year     => l_days_in_year,
        x_day_count_method => l_day_count_method,
        x_return_status    => l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Return Status | l_days_in_month | l_days_in_year | l_day_count_method ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    l_return_status || ' | ' || l_days_in_month || ' | ' ||
                    l_days_in_year || ' | ' ||  l_day_count_method  );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        --Bug 5884825 PAGARG start
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_ISG_DAY_CONVENTION',
                             p_token1       => 'PRODUCT_NAME',
                             p_token1_value => l_product_name);
        --Bug 5884825 PAGARG end
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      pp_index := 1;
      -- Loop through each configuration line and price it seperately ...
      FOR assets_rec IN assets_csr(p_qte_id)
      LOOP
        IF  assets_rec.fee_type = 'FREE_FORM1'
        THEN
          -- For Rate Card Pricing the price_standard_quote_asset api will
          --  a/ Create Cash flows for each configuration line
          --      Checks whether to pick the RC from Header of configuration level itself.
          --  b/ builds and return the pricing parameter record
          price_standard_quote_asset(
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_api_version            => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_qte_id                 => p_qte_id,
            p_ast_id                 => nvl(assets_rec.ast_id, assets_rec.fee_id),
            p_price_at_lq_level      => FALSE, -- Use Asset Level Cash flows only !
            p_target_rate            => NULL,
            p_line_type              => assets_rec.fee_type,
            x_pricing_parameter_rec  => l_tmp_pricing_parameter_rec );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After price_standard_quote_asset ' || l_return_status );
          IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;
          -- Store the Pricing Parameter for solving yields at the entire quote level
          l_pricing_parameter_tbl(pp_index) :=  l_tmp_pricing_parameter_rec;
          -- Increment the pp_index
          pp_index := pp_index + 1;
        END IF;
      END LOOP; -- Loop on the Assets csr
      -- Loop through ROLLOVER and Financed Fees, and fetch the pricng parameter rec. structure
      FOR assets_rec IN assets_csr(p_qte_id)
      LOOP
        IF  assets_rec.fee_type in ('ROLLOVER', 'FINANCED')
        THEN
          -- For Rate Card Pricing the price_standard_quote_asset api will
          --  a/ Create Cash flows for each configuration line
          --      Checks whether to pick the RC from Header of configuration level itself.
          --  b/ builds and return the pricing parameter record
          price_standard_quote_asset(
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_api_version            => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_qte_id                 => p_qte_id,
            p_ast_id                 => nvl(assets_rec.ast_id, assets_rec.fee_id),
            p_price_at_lq_level      => FALSE, -- Use Asset Level Cash flows only !
            p_target_rate            => NULL,
            p_line_type              => assets_rec.fee_type,
            x_pricing_parameter_rec  => l_tmp_pricing_parameter_rec );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After price_standard_quote_asset ' || l_return_status );
          IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;
          -- Store the Pricing Parameter for solving yields at the entire quote level
          l_pricing_parameter_tbl(pp_index) :=  l_tmp_pricing_parameter_rec;
          -- Increment the pp_index
          pp_index := pp_index + 1;
        END IF;
      END LOOP; -- Loop on the Assets csr
      -- Store the Pricing Param Table for calculation of the Non-Subsidized Yields
      l_pp_non_sub_iir_tbl := l_pricing_parameter_tbl;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'Before calling irr for iir at quote level ' || l_return_status );
      -- Compute IIR @ Lease Quote Level.
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => x_iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pricing_parameter_tbl, -- includes the fees as well
        px_irr                    => x_iir,
        x_payment                 => x_payment);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of IIR @ LQ Level ( SUBSIDY )' || l_return_status );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_subsidized_yields_rec.iir :=  x_iir;
      l_subsidized_yields_rec.bk_yield :=  x_iir;
      -- Extract the other fees and other lines information for computation of the IRR
      -- Extract the fess information and built the Cash Inflows and Pricing Parameters
      FOR assets_rec IN assets_csr(p_qte_id)                 -- for all assets
      LOOP
        IF ( assets_rec.fee_type NOT IN ('FREE_FORM1', 'ROLLOVER', 'FINANCED', 'ABSORBED') )
        THEN
          -- Delete the previous fees cash flows
          l_fee_outflow_cfl_tbl.DELETE;
          l_fee_inflow_cfl_tbl.DELETE;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       '!!!!!!  Handling fee ' || assets_rec.fee_type );
          get_lq_fee_cash_flows(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => l_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_fee_type         => assets_rec.fee_type,
            p_lq_id            => p_qte_id,
            p_fee_id           => assets_rec.fee_id,
            x_outflow_caf_rec  => l_fee_outflow_caf_rec,
            x_outflow_cfl_tbl  => l_fee_outflow_cfl_tbl,
            x_inflow_caf_rec   => l_fee_inflow_caf_rec,
            x_inflow_cfl_tbl   => l_fee_inflow_cfl_tbl);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After get_lq_fee_cash_flows ' || l_return_status );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- Based on the outflows/Inflows obtained generate the streams
          IF l_fee_outflow_cfl_tbl.COUNT > 0
          THEN
            l_cash_inflows.DELETE;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!! Obtained Expense Cash flow levels !!!!!!!!' );
            gen_so_cf_strms(
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_cash_flow_rec          => l_fee_outflow_caf_rec,
              p_cf_details_tbl         => l_fee_outflow_cfl_tbl,
              x_cash_inflow_strms_tbl  => l_cash_inflows);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Place the information in the pricing params
            l_pricing_parameter_tbl(pp_index).line_type := assets_rec.fee_type;
            l_pricing_parameter_tbl(pp_index).payment_type := 'EXPENSE';
            l_pricing_parameter_tbl(pp_index).line_start_date := assets_rec.line_start_date;
            l_pricing_parameter_tbl(pp_index).line_end_date := assets_rec.line_end_date;
            l_pricing_parameter_tbl(pp_index).cash_inflows := l_cash_inflows;
            -- Bug 7440199: Quote Streams ER: RGOOTY: Start
            l_pricing_parameter_tbl(pp_index).cfo_id := l_fee_outflow_caf_rec.cfo_id;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
            pp_index := pp_index + 1;
          END IF;
          -- Based on the outflows/Inflows obtained generate the streams
          IF l_fee_inflow_cfl_tbl.COUNT > 0
          THEN
            l_cash_inflows.DELETE;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!! Obtained Income Cash flow levels !!!!!!!!' );
            gen_so_cf_strms(
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_cash_flow_rec          => l_fee_inflow_caf_rec,
              p_cf_details_tbl         => l_fee_inflow_cfl_tbl,
              x_cash_inflow_strms_tbl  => l_cash_inflows);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Place the information in the pricing params
            l_pricing_parameter_tbl(pp_index).line_type := assets_rec.fee_type;
            IF assets_rec.fee_type IN ( 'INCOME', 'MISCELLANEOUS' )
            THEN
              l_pricing_parameter_tbl(pp_index).payment_type := 'INCOME';
            ELSE
              l_pricing_parameter_tbl(pp_index).payment_type := 'SECDEPOSIT';
            END IF;
            l_pricing_parameter_tbl(pp_index).line_start_date := assets_rec.line_start_date;
            l_pricing_parameter_tbl(pp_index).line_end_date := assets_rec.line_end_date;
            l_pricing_parameter_tbl(pp_index).cash_inflows := l_cash_inflows;
            -- Bug 7440199: Quote Streams ER: RGOOTY: Start
            l_pricing_parameter_tbl(pp_index).cfo_id := l_fee_inflow_caf_rec.cfo_id;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
            pp_index := pp_index + 1;
          END IF;
        END IF; -- IF on Fee_type not in ...
        IF  assets_rec.fee_type = 'ABSORBED'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!  Building cash inflows for this Absorbed fee ' || assets_rec.fee_type );
          -- Increment the pp_index and store the pricng params
          l_pricing_parameter_tbl(pp_index).payment_type := 'EXPENSE';
          l_pricing_parameter_tbl(pp_index).financed_amount := assets_rec.fee_amount;
          pp_index := pp_index + 1;
        END IF;
      END LOOP;
      -- Store the Pricing Param Table for calculation of the
      --  Non-Subsidized Yields
      l_pp_non_sub_irr_tbl := l_pricing_parameter_tbl;
      l_iir_temp := NULL;
      l_iir_temp := l_subsidized_yields_rec.pre_tax_irr;

      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => x_iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pricing_parameter_tbl, -- includes the fees as well
        -- px_irr                    => l_subsidized_yields_rec.pre_tax_irr,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
     l_subsidized_yields_rec.pre_tax_irr := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of IRR @ LQ Level ( SUBSIDY )' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR IRR ' || l_subsidized_yields_rec.pre_tax_irr );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Calculate the Yields without involving the Subsidy Amount
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ CALCULATING THE YEILDS WIHTOUT THE SUBSIDY AMOUNT INVOLVED !! ' );
      -- Loop through the l_pp_non_sub_iir_tbl table and delete the Subsidy Amount
      FOR ny IN l_pp_non_sub_iir_tbl.FIRST .. l_pp_non_sub_iir_tbl.LAST
      LOOP
        -- line_type, subsidy
        l_pp_non_sub_iir_tbl(ny).subsidy := 0;
      END LOOP;
      l_iir_temp := NULL;
      l_iir_temp := l_yields_rec.iir;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_iir_tbl, -- includes the fees as well
        -- px_irr                    => l_yields_rec.iir,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
      l_yields_rec.iir := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of IIR @ LQ Level ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR IIR (NON-SUBSIDY)' || l_yields_rec.iir );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Store the IIR as the Booking Yield
      l_yields_rec.bk_yield := l_yields_rec.iir;

      -- Loop through the l_pp_non_sub_iir_tbl table and delete the Subsidy Amount
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ Before Computation of IRR @ LQ Level ' );
      FOR ny IN l_pp_non_sub_irr_tbl.FIRST .. l_pp_non_sub_irr_tbl.LAST
      LOOP
        -- For Asset lines, change the Subsidy Amount to Zero ..
        IF l_pp_non_sub_irr_tbl(ny).line_type = 'FREE_FORM1'
        THEN
           l_pp_non_sub_irr_tbl(ny).subsidy := 0;
        END IF;
      END LOOP;
      l_iir_temp := NULL;
      l_iir_temp := l_yields_rec.pre_tax_irr;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.pre_tax_irr, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_irr_tbl, -- includes the fees as well
        -- px_irr                    => l_yields_rec.pre_tax_irr,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
       l_yields_rec.pre_tax_irr := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of IRR @ LQ Level ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR IRR (NON-SUBSIDY)' || l_yields_rec.pre_tax_irr );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- End of Rate Card Pricing
    ELSIF quote_rec.pricing_method = 'SY'
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'SOlving for Yields ' || l_return_status );
      l_lq_pricing_parameter_rec.financed_amount := 0;
      l_lq_pricing_parameter_rec.down_payment := 0;
      l_lq_pricing_parameter_rec.trade_in := 0;
      l_lq_pricing_parameter_rec.subsidy := 0;
      l_lq_pricing_parameter_rec.cap_fee_amount := 0;
      pp_index := 1;
      lnoa_index := 1;
      res_index := 1;
      l_non_overiding_assets_tbl.DELETE;
      -- Loop through the Assets and check price the asset seperately
      --  which has overriddent the payment option picked at the Quote Level
      FOR assets_rec IN assets_csr(p_qte_id)                 -- for all assets
      LOOP
        -- Check whether this Asset has overridden the Payment option defined
        --  at the quote level !
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'loop thru assets ' || assets_rec.asset_number || ' ' || l_return_status );
        IF nvl(assets_rec.fee_type, 'XXXX') <> 'FREE_FORM1'
        THEN
          l_overridden := TRUE;
        ELSE
          l_overridden := is_asset_overriding(
                          p_qte_id                => p_qte_id,
                          p_ast_id                => assets_rec.ast_id,
                          p_lq_line_level_pricing => quote_rec.line_level_pricing,
                          p_lq_srt_id             => quote_rec.rate_template_id,
                          p_ast_srt_id            => assets_rec.rate_template_id,
                          p_lq_struct_pricing     => quote_rec.structured_pricing,
                          p_ast_struct_pricing    => assets_rec.structured_pricing,
                          p_lq_arrears_yn         => quote_rec.target_arrears,
                          p_ast_arrears_yn        => assets_rec.target_arrears,
                          x_return_status         => l_return_status);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After is_asset_overriding assets_rec.id =' || assets_rec.ast_id || ' | ' ||
                     '  l_return_status =' || l_return_status );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        IF l_overridden = FALSE
        THEN
          -- If asset is not overriding the Payment option defined at the Quote Level ...
          -- Store the Asset Id for later use ..
          l_non_overiding_assets_tbl(lnoa_index) := assets_rec.ast_id;
          -- Fetch the Asset Cost Adjustment Details for each Asset and accumulate them
          --  in the lx_pricing_parameter_rec
          FOR asset_cost_adj_rec IN asset_cost_adj_csr( qteid => p_qte_id,
                                                        astid => assets_rec.ast_id)
          LOOP
            IF asset_cost_adj_rec.adjustment_source_type = G_DOWNPAYMENT_TYPE
            THEN
              l_noa_pp_tbl(lnoa_index).down_payment := nvl(asset_cost_adj_rec.VALUE, 0 );
            ELSIF asset_cost_adj_rec.adjustment_source_type = G_SUBSIDY_TYPE
            THEN
              IF ( nvl(asset_cost_adj_rec.value, -9999) = -9999)
              THEN
                OPEN subsidy_adj_csr(asset_cost_adj_rec.ADJUSTMENT_SOURCE_ID);
                FETCH subsidy_adj_csr INTO subsidy_adj_rec;
                CLOSE subsidy_adj_csr;
                -- Bug 7429169 : Start
                -- l_noa_pp_tbl(lnoa_index).subsidy := subsidy_adj_rec.amount;
                IF  l_noa_pp_tbl.EXISTS(lnoa_index)
                THEN
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(l_noa_pp_tbl(lnoa_index).subsidy,0) + NVL(subsidy_adj_rec.amount,0);
                ELSE
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(subsidy_adj_rec.amount,0);
                END IF; -- djanaswa bug7295753 end
                -- Bug 7429169 : End
              ELSE
                -- Bug 7429169 : Start
                -- l_noa_pp_tbl(lnoa_index).subsidy := asset_cost_adj_rec.value;
                IF  l_noa_pp_tbl.EXISTS(lnoa_index)
                THEN
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(l_noa_pp_tbl(lnoa_index).subsidy,0) + NVL(asset_cost_adj_rec.value,0);
                ELSE
                  l_noa_pp_tbl(lnoa_index).subsidy := NVL(asset_cost_adj_rec.value,0);
                END IF; -- djanaswa bug7295753 end
                -- Bug 7429169 : End
              END IF;
            ELSIF asset_cost_adj_rec.adjustment_source_type = G_TRADEIN_TYPE
            THEN
              l_noa_pp_tbl(lnoa_index).trade_in := nvl(asset_cost_adj_rec.VALUE, 0);
            END IF;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      'Down Payment| Trade In | Subsidy ' );
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
               l_noa_pp_tbl(lnoa_index).down_payment || ' | ' ||
               l_noa_pp_tbl(lnoa_index).trade_in || ' | ' ||
               l_noa_pp_tbl(lnoa_index).subsidy );
          END LOOP;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After Retrieving the Asset Cost Adjustments ');
          --res_index := 1;
          FOR asset_adj_rec IN asset_adj_csr(p_qte_id, assets_rec.ast_id)
          LOOP
            l_noa_pp_tbl(lnoa_index).financed_amount := nvl(asset_adj_rec.oec, 0);
            -- Calculate the Capitalized Fee for this Asset
            FOR ct_rec IN get_asset_cap_fee_amt(
                           p_source_type       => 'ASSET',
                           p_source_id         => assets_rec.ast_id,
                           p_related_line_type => 'CAPITALIZED')
            LOOP
              l_noa_pp_tbl(lnoa_index).cap_fee_amount := nvl(ct_rec.capitalized_amount, 0);
            END LOOP;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                      asset_adj_rec.unit_cost|| ' No. of Units ' || asset_adj_rec.number_of_units);
            l_lq_residual_inflows(res_index).line_number := res_index;
            IF ( l_eot_type_code = 'PERCENT' OR l_eot_type_code = 'RESIDUAL_PERCENT' )
            THEN
              -- EOT = OEC * EOT %age /100;
              l_lq_residual_inflows(res_index).cf_amount   :=
                nvl((asset_adj_rec.end_of_term_value/100) * l_noa_pp_tbl(lnoa_index).financed_amount, 0 );
            ELSE
              -- EOT is an amount so directly store it ..
              l_lq_residual_inflows(res_index).cf_amount   := asset_adj_rec.end_of_term_value;
            END IF;
            l_lq_residual_inflows(res_index).cf_date     := l_eot_date;
            l_lq_residual_inflows(res_index).cf_miss_pay := 'N';
            l_lq_residual_inflows(res_index).is_stub     := 'N';
            l_lq_residual_inflows(res_index).is_arrears  := 'Y';
            l_lq_residual_inflows(res_index).cf_dpp := l_cf_dpp;
            l_lq_residual_inflows(res_index).cf_ppy := l_cf_ppy;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Financed Amount = ' || l_noa_pp_tbl(lnoa_index).financed_amount);
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    'Storing residual amt ' || l_lq_residual_inflows(res_index).cf_amount );
            -- Store the Asset Residuals in the corresponding NOA Assets table
            l_noa_pp_tbl(lnoa_index).residual_inflows(1) := l_lq_residual_inflows(res_index);
            -- Increment the res_index
            res_index := res_index + 1;
          END LOOP;
          -- Bug 6669429 : Start
          l_lq_pricing_parameter_rec.financed_amount := l_lq_pricing_parameter_rec.financed_amount + nvl(l_noa_pp_tbl(lnoa_index).financed_amount,0);
          l_lq_pricing_parameter_rec.down_payment    := l_lq_pricing_parameter_rec.down_payment    + nvl(l_noa_pp_tbl(lnoa_index).down_payment,0);
          l_lq_pricing_parameter_rec.trade_in        := l_lq_pricing_parameter_rec.trade_in        + nvl(l_noa_pp_tbl(lnoa_index).trade_in,0);
          l_lq_pricing_parameter_rec.subsidy         := l_lq_pricing_parameter_rec.subsidy         + nvl(l_noa_pp_tbl(lnoa_index).subsidy,0);
          l_lq_pricing_parameter_rec.cap_fee_amount  := l_lq_pricing_parameter_rec.cap_fee_amount  + nvl(l_noa_pp_tbl(lnoa_index).cap_fee_amount,0);
          -- Bug 6669429 : End
          lnoa_index := lnoa_index + 1;
        ELSE -- IF l_overridden = TRUE
          IF  assets_rec.fee_type = 'FREE_FORM1'
          THEN
            -- Price this Asset which has overridden the payment strcuture defined on the LQ !
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     ' Calling price_standard_quote_asset ' || 'p_qte_id ' || p_qte_id
                     || ' | assets_rec.ast_id ' || nvl(assets_rec.ast_id, assets_rec.fee_id) ||
                    ' | p_price_at_lq_level = FALSE | p_target_rate = NULL' );
            price_standard_quote_asset(
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              p_qte_id                 => p_qte_id,
              p_ast_id                 => nvl(assets_rec.ast_id, assets_rec.fee_id),
              p_price_at_lq_level      => FALSE, -- Use Asset Level Cash flows only !
              p_target_rate            => NULL,
              p_line_type              => assets_rec.fee_type,
              x_pricing_parameter_rec  => l_tmp_pricing_parameter_rec );
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After price_standard_quote_asset ' || l_return_status );
            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
              RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
            END IF;
            -- Increment the pp_index
            l_pricing_parameter_tbl(pp_index) := l_tmp_pricing_parameter_rec;
            pp_index := pp_index + 1;
          END IF;
        END IF;
      END LOOP; -- Loop on the Assets csr
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 ' Number of Overriding Lines = ' || l_pricing_parameter_tbl.COUNT || ' | ' ||
                 ' Number of Non-Overriding Lines = ' || l_non_overiding_assets_tbl.COUNT );
      IF l_non_overiding_assets_tbl.COUNT > 0
      THEN
        -- If there is atleast one asset which follows the Payment Structure
        -- defined at Lease Quote Level, then pass the Pricing param table
        -- withe the Cash flows information at lease quote level else DON'T !!
        -- Store the Cash inflow streams and Residual streams in the l_lq_pricing_parameter_rec
        l_lq_pricing_parameter_rec.cash_inflows := l_lq_cash_inflows;
        l_lq_pricing_parameter_rec.residual_inflows := l_lq_residual_inflows;
        -- Bug 7440199: Quote Streams ER: RGOOTY: Start
        l_lq_pricing_parameter_rec.cfo_id := l_lq_cash_flow_rec.cfo_id;
        -- Bug 7440199: Quote Streams ER: RGOOTY: End
        -- pp_index is an post-assigned incremented index!
        l_lq_pricing_parameter_rec.line_type := 'FREE_FORM1';
        l_pricing_parameter_tbl(pp_index) := l_lq_pricing_parameter_rec;
        pp_index := pp_index + 1;
        l_an_ass_follow_lq := TRUE;  -- Store the flag
        l_lq_details_prc_rec := l_lq_pricing_parameter_rec;
      END IF;
      -- Handling the ROLLOVER AND FINANCED FEES
      FOR assets_rec IN assets_csr(p_qte_id) -- ALL Assets or FEES
      LOOP
        IF  assets_rec.fee_type IN ( 'ROLLOVER', 'FINANCED')
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            ' Calling price_standard_quote_asset for ' || assets_rec.fee_type || ' with ID ' || assets_rec.fee_id );
          -- Price the fees ROLLOVER OR FINANCED
          price_standard_quote_asset(
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_api_version            => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_qte_id                 => p_qte_id,
            p_ast_id                 => nvl(assets_rec.ast_id, assets_rec.fee_id),
            p_price_at_lq_level      => FALSE, -- Use Asset Level Cash flows only !
            p_target_rate            => NULL,
            p_line_type              => assets_rec.fee_type,
            x_pricing_parameter_rec  => l_tmp_pricing_parameter_rec );
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'After price_standard_quote_asset ' || l_return_status );
          IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;
          l_pricing_parameter_tbl(pp_index) := l_tmp_pricing_parameter_rec;
          -- Increment the pp_index
          pp_index := pp_index + 1;
        END IF;
      END LOOP;
      -- Store the Pricing Param Table for calculation of the Non-Subsidized Yields
      l_pp_non_sub_iir_tbl := l_pricing_parameter_tbl;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Before calling irr for iir at quote level ' || l_return_status );
      -- Compute IIR @ Lease Quote Level.
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => x_iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pricing_parameter_tbl, -- includes the fees as well
        px_irr                    => x_iir,
        x_payment                 => x_payment);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of IIR @ LQ Level ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR IIR ' || x_iir );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_subsidized_yields_rec.iir :=  x_iir;
      l_subsidized_yields_rec.bk_yield :=  x_iir;
      -- Extract the fess information and built the Cash Inflows and Pricing Parameters
      FOR assets_rec IN assets_csr(p_qte_id)                 -- for all assets
      LOOP
        IF ( assets_rec.fee_type NOT IN ('FREE_FORM1', 'ROLLOVER', 'FINANCED', 'ABSORBED') )
        THEN
          -- Delete the previous fees cash flows
          l_fee_outflow_cfl_tbl.DELETE;
          l_fee_inflow_cfl_tbl.DELETE;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                       '!!!!!!  Handling fee ' || assets_rec.fee_type );
          get_lq_fee_cash_flows(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => l_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_fee_type         => assets_rec.fee_type,
            p_lq_id            => p_qte_id,
            p_fee_id           => assets_rec.fee_id,
            x_outflow_caf_rec  => l_fee_outflow_caf_rec,
            x_outflow_cfl_tbl  => l_fee_outflow_cfl_tbl,
            x_inflow_caf_rec   => l_fee_inflow_caf_rec,
            x_inflow_cfl_tbl   => l_fee_inflow_cfl_tbl);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     'After get_lq_fee_cash_flows ' || l_return_status );
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- Based on the outflows/Inflows obtained generate the streams
          IF l_fee_outflow_cfl_tbl.COUNT > 0
          THEN
            l_cash_inflows.DELETE;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!! Obtained Expense Cash flow levels !!!!!!!!' );
            gen_so_cf_strms(
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_cash_flow_rec          => l_fee_outflow_caf_rec,
              p_cf_details_tbl         => l_fee_outflow_cfl_tbl,
              x_cash_inflow_strms_tbl  => l_cash_inflows);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Place the information in the pricing params
            l_pricing_parameter_tbl(pp_index).line_type := assets_rec.fee_type;
            l_pricing_parameter_tbl(pp_index).payment_type := 'EXPENSE';
            l_pricing_parameter_tbl(pp_index).line_start_date := assets_rec.line_start_date;
            l_pricing_parameter_tbl(pp_index).line_end_date := assets_rec.line_end_date;
            l_pricing_parameter_tbl(pp_index).cash_inflows := l_cash_inflows;
            -- Bug 7440199: Quote Streams ER: RGOOTY: Start
            l_pricing_parameter_tbl(pp_index).cfo_id := l_fee_outflow_caf_rec.cfo_id;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
            pp_index := pp_index + 1;
          END IF;
          -- Based on the outflows/Inflows obtained generate the streams
          IF l_fee_inflow_cfl_tbl.COUNT > 0
          THEN
            l_cash_inflows.DELETE;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!! Obtained Income Cash flow levels !!!!!!!!' );
            gen_so_cf_strms(
              p_api_version            => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_cash_flow_rec          => l_fee_inflow_caf_rec,
              p_cf_details_tbl         => l_fee_inflow_cfl_tbl,
              x_cash_inflow_strms_tbl  => l_cash_inflows);
            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Place the information in the pricing params
            l_pricing_parameter_tbl(pp_index).line_type := assets_rec.fee_type;
            IF assets_rec.fee_type IN ( 'INCOME', 'MISCELLANEOUS' )
            THEN
              l_pricing_parameter_tbl(pp_index).payment_type := 'INCOME';
            ELSE
              l_pricing_parameter_tbl(pp_index).payment_type := 'SECDEPOSIT';
            END IF;
            l_pricing_parameter_tbl(pp_index).line_start_date := assets_rec.line_start_date;
            l_pricing_parameter_tbl(pp_index).line_end_date := assets_rec.line_end_date;
            l_pricing_parameter_tbl(pp_index).cash_inflows := l_cash_inflows;
            -- Bug 7440199: Quote Streams ER: RGOOTY: Start
            l_pricing_parameter_tbl(pp_index).cfo_id := l_fee_inflow_caf_rec.cfo_id;
            -- Bug 7440199: Quote Streams ER: RGOOTY: End
            pp_index := pp_index + 1;
          END IF;
        END IF; -- IF on Fee_type not in ...
        IF  assets_rec.fee_type = 'ABSORBED'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '!!!!!!  Building cash inflows for this Absorbed fee ' || assets_rec.fee_type );
          -- Increment the pp_index and store the pricng params
          l_pricing_parameter_tbl(pp_index).payment_type := 'EXPENSE';
          l_pricing_parameter_tbl(pp_index).financed_amount := assets_rec.fee_amount;
          pp_index := pp_index + 1;
        END IF;
      END LOOP;
      -- Store the Pricing Param Table for calculation of the
      --  Non-Subsidized Yields
      l_pp_non_sub_irr_tbl.DELETE;
      l_pp_non_sub_irr_tbl := l_pricing_parameter_tbl;
      -- Now call the compute_irr api to solve for the Yield at the Lease quote Level !
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => x_iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pricing_parameter_tbl, -- includes the fees as well
        px_irr                    => x_iir,
        x_payment                 => x_payment);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of IRR @ LQ Level ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR IRR ' || x_iir );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_subsidized_yields_rec.pre_tax_irr   :=  x_iir;
      -- Calculate the Yields without involving the Subsidy Amount
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ CALCULATING THE YEILDS WIHTOUT THE SUBSIDY AMOUNT INVOLVED !! ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of IIR @ LQ Level ' || l_return_status );
      -- Loop through the l_pp_non_sub_iir_tbl table and delete the Subsidy Amount
      FOR ny IN l_pp_non_sub_iir_tbl.FIRST .. l_pp_non_sub_iir_tbl.LAST
      LOOP
        -- line_type, subsidy
        l_pp_non_sub_iir_tbl(ny).subsidy := 0;
      END LOOP;
      l_iir_temp := NULL;
      l_iir_temp := l_yields_rec.iir;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.iir, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_iir_tbl, -- includes the fees as well
        -- px_irr                    => l_yields_rec.iir,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
      l_yields_rec.iir := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of IIR @ LQ Level ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR IIR (NON-SUBSIDY)' || l_yields_rec.iir );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Store the IIR as the Booking Yield
      l_yields_rec.bk_yield := l_yields_rec.iir;
      -- Loop through the l_pp_non_sub_iir_tbl table and delete the Subsidy Amount
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ Before Computation of IRR @ LQ Level loop subsidy ' || to_char(l_pp_non_sub_irr_tbl.COUNT));
      FOR ny IN l_pp_non_sub_irr_tbl.FIRST .. l_pp_non_sub_irr_tbl.LAST
      LOOP
        -- For Asset lines, change the Subsidy Amount to Zero ..
        IF nvl(l_pp_non_sub_irr_tbl(ny).line_type, 'XXXX') = 'FREE_FORM1'
        THEN
           l_pp_non_sub_irr_tbl(ny).subsidy := 0;
        END IF;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ Before Computation of IRR @ LQ Level ' );
      l_iir_temp := NULL;
      l_iir_temp := l_yields_rec.pre_tax_irr;
      compute_irr(
        p_api_version             => p_api_version,
        p_init_msg_list           => p_init_msg_list,
        x_return_status           => l_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data,
        p_start_date              => quote_rec.expected_start_date,
        p_day_count_method        => l_day_count_method,
        p_currency_code           => l_currency,  -- Replace this USD with the appropriate column!
        p_pricing_method          => 'SY',
        p_initial_guess           => l_subsidized_yields_rec.pre_tax_irr, -- Use the IIR derieved prev. as initial guess
        px_pricing_parameter_tbl  => l_pp_non_sub_irr_tbl, -- includes the fees as well
        -- px_irr                    => l_yields_rec.pre_tax_irr,
        px_irr                    => l_iir_temp,
        x_payment                 => x_payment);
      l_yields_rec.pre_tax_irr := l_iir_temp;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                     '1/ After Computation of IRR @ LQ Level ' || l_return_status );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'SOLVED FOR IRR (NON-SUBSIDY)' || l_yields_rec.pre_tax_irr );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- Populate the l_lease_qte_rec appropriately for the Updation
    l_lease_qte_rec.id := p_qte_id;
    l_lease_qte_rec.SUB_IIR               := round(l_subsidized_yields_rec.iir * 100, 4);
    l_lease_qte_rec.SUB_PIRR              := round(l_subsidized_yields_rec.pre_tax_irr * 100, 4);
    l_lease_qte_rec.SUB_BOOKING_YIELD     := round(l_subsidized_yields_rec.bk_yield * 100, 4);
    l_lease_qte_rec.IIR                   := round(l_yields_rec.iir * 100, 4);
    l_lease_qte_rec.PIRR                  := round(l_yields_rec.pre_tax_irr * 100, 4);
    l_lease_qte_rec.BOOKING_YIELD         := round(l_yields_rec.bk_yield * 100, 4);
    l_lease_qte_rec.status                := 'PR-COMPLETE';
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'Update the Yields on the Lease Quote'  );
    okl_lease_quote_pvt.update_lease_qte(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            p_transaction_control => NULL,
            p_lease_qte_rec       => l_lease_qte_rec,
            x_lease_qte_rec       => x_lease_qte_rec,
            x_return_status       => l_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 'After updation of Yields on Lease Quote. Status: ' || l_return_status );
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now after the Yields has been calculated, we need to calculate the payments
    -- for all Non-Overridden assets !
    IF quote_rec.pricing_method <> 'RC'
       AND l_an_ass_follow_lq
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        ' !!!!!!!! CALCULATION OF THE ASSET LEVEL PAYMENTS !!!!!! ' );
      -- Calculate the Quote leve C-S-D-T
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'LQ Level: Asset Cost (C) | Down Payment (D) | Trade-in (T) | Subsidy (s)' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        round( l_lq_details_prc_rec.financed_amount, 4) || ' | ' || round( l_lq_details_prc_rec.down_payment, 4) || ' | ' ||
        round( l_lq_details_prc_rec.trade_in, 4) || ' | ' ||     round( l_lq_details_prc_rec.subsidy, 4));
      IF quote_rec.pricing_method <> 'TR'
      THEN
        -- Now compute the IIR for the group of assets which follow the payment
        --  entered at the Quote Level.
        compute_iir(
          p_api_version             => p_api_version,
          p_init_msg_list           => p_init_msg_list,
          x_return_status           => l_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          p_start_date              => quote_rec.expected_start_date,
          p_day_count_method        => l_day_count_method,
          p_pricing_method          => 'SY',
          p_initial_guess           => (l_lease_qte_rec.iir/ 100 ),
          px_pricing_parameter_rec  => l_lq_details_prc_rec,
          px_iir                    => l_iir,
          x_payment                 => l_miss_payment);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'After SY @ LQ level ' || x_return_status || ' | l_iir=' || round(l_iir,4) );
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        l_iir := (l_lease_qte_rec.iir / 100 );
      END IF;
      -- Loop the Streams at the Quote level and put the l_iir as rate, and cf_ratio also
      -- needs to be populated appropriately.
      l_lq_con_cash_inflows := l_lq_details_prc_rec.cash_inflows;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '!! Assigning the Quote level rate and cf_ratio !!' );
      FOR t_in IN l_lq_con_cash_inflows.FIRST .. l_lq_con_cash_inflows.LAST
      LOOP
        IF l_lq_con_cash_inflows(t_in).cf_amount > 0
        THEN
          l_tmp_amount := l_lq_con_cash_inflows(t_in).cf_amount;
          EXIT;
        END IF;
      END LOOP;
      FOR t_in IN l_lq_con_cash_inflows.FIRST .. l_lq_con_cash_inflows.LAST
      LOOP
        l_lq_con_cash_inflows(t_in).cf_rate := l_iir;
        l_lq_con_cash_inflows(t_in).cf_ratio:= l_lq_con_cash_inflows(t_in).cf_amount/l_tmp_amount;
      END LOOP;
      -- Store the amount from the first cash flow level which can be a Stub/Periodic Amount and is non-zero
      FOR t_in IN l_lq_payment_level_tbl.FIRST .. l_lq_payment_level_tbl.LAST
      LOOP
        IF l_lq_payment_level_tbl(t_in).stub_days IS NOT NULL AND
           l_lq_payment_level_tbl(t_in).stub_amount > 0
        THEN
          -- Found a first stub CFL with some amount, using this as a base for the proportion.
          l_tmp_amount := l_lq_payment_level_tbl(t_in).stub_amount;
          EXIT;
        ELSIF l_lq_payment_level_tbl(t_in).periods IS NOT NULL AND
              l_lq_payment_level_tbl(t_in).periodic_amount > 0
        THEN
          -- Found a regular CFL with some amount, using this as a base for the proportion.
          l_tmp_amount := l_lq_payment_level_tbl(t_in).periodic_amount;
          EXIT;
        END IF;
      END LOOP;
      l_rnd_lq_payment_level_tbl := l_lq_payment_level_tbl;
      l_rnd_sum_assets_pmnts_tbl := l_lq_payment_level_tbl;
      FOR t_in IN l_rnd_lq_payment_level_tbl.FIRST .. l_rnd_lq_payment_level_tbl.LAST
      LOOP
        IF l_rnd_lq_payment_level_tbl(t_in).stub_days IS NOT NULL AND
           l_rnd_lq_payment_level_tbl(t_in).stub_amount > 0
        THEN
            l_rnd_lq_payment_level_tbl(t_in).stub_amount :=
              okl_accounting_util.round_amount(
                p_amount        => l_rnd_lq_payment_level_tbl(t_in).stub_amount,
                p_currency_code => l_currency );
            l_rnd_sum_assets_pmnts_tbl(t_in).stub_amount := 0;
        ELSE
            l_rnd_lq_payment_level_tbl(t_in).periodic_amount :=
              okl_accounting_util.round_amount(
                p_amount        => l_rnd_lq_payment_level_tbl(t_in).periodic_amount,
                p_currency_code => l_currency );
           l_rnd_sum_assets_pmnts_tbl(t_in).periodic_amount := 0;
        END IF;
      END LOOP;
      -- Loop through the assets which follow the LQ payment structure
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '!!!!!!!! **** DERIEVING PAYMENTS FOR ALL ASSETS ***** !!!!!!!!!' );
      FOR t IN l_noa_pp_tbl.FIRST .. l_noa_pp_tbl.LAST
      LOOP
        IF quote_rec.pricing_method IN ( 'SF' )
        THEN
          -- Asset Cost is not stored in the l_noa_pp_tbl while solving it .. Hence, fetch it
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            ' Asset ID = ' || l_non_overiding_assets_tbl(t) );
          FOR asset_adj_rec IN asset_adj_csr(p_qte_id, l_non_overiding_assets_tbl(t))
          LOOP
            l_noa_pp_tbl(t).financed_amount := nvl(asset_adj_rec.oec,0);
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Asset cost was fetched from the DB ' || l_noa_pp_tbl(t).financed_amount );
          END LOOP;
        END IF;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Asset Cost (C) | Down Payment (D) | Trade-in (T) | Subsidy (s)' );
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          round( l_noa_pp_tbl(t).financed_amount, 4) || ' | ' || round( l_noa_pp_tbl(t).down_payment, 4) || ' | ' ||
          round( l_noa_pp_tbl(t).trade_in, 4) || ' | ' || round( l_noa_pp_tbl(t).subsidy, 4));
        -- The streams for this asset should resemble the Quote level ones. Hence, copying them to the Asset PP Rec.
        l_noa_pp_tbl(t).cash_inflows  := l_lq_con_cash_inflows;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Calculating the Asset level Payment for ID ' || l_non_overiding_assets_tbl(t) );
        compute_iir(
          p_api_version             => p_api_version,
          p_init_msg_list           => p_init_msg_list,
          x_return_status           => l_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          p_start_date              => quote_rec.expected_start_date,
          p_day_count_method        => l_day_count_method,
          p_pricing_method          => 'SPP', -- Use the Algorithm which proportionates the Payment Amt
          p_initial_guess           => l_lease_qte_rec.iir,
          px_pricing_parameter_rec  => l_noa_pp_tbl(t),
          px_iir                    => l_iir,
          x_payment                 => l_miss_payment);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'SPP: For Asset Status=' || x_return_status || ' | l_iir=' || round(l_iir,4) || ' | l_miss_payment = ' || round(l_miss_payment, 2));
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Need to delete the cash flow (if any exists) for this Asset with WORK Status.
        l_cfo_exists_at_noa := 'YES';
        FOR t_rec IN check_cfo_exists_csr(
          p_oty_code     => 'QUOTED_ASSET',
          p_source_table => 'OKL_ASSETS_B',
          p_source_id    => l_non_overiding_assets_tbl(t),
          p_sts_code     => 'WORK')
        LOOP
          l_cfo_exists_at_noa := t_rec.cfo_exists;
        END LOOP;
        -- Delete the Cash flows if they are already present
        IF l_cfo_exists_at_noa = 'YES'
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            ' Deleting already existing CFO ' );
          -- Delete the Cash Flow Levels which may be already created by Pricing ..
          okl_lease_quote_cashflow_pvt.delete_cashflows (
            p_api_version          => p_api_version,
            p_init_msg_list        => p_init_msg_list,
            p_transaction_control  => NULL,
            p_source_object_code   => 'QUOTED_ASSET',
            p_source_object_id     => l_non_overiding_assets_tbl(t),
            x_return_status        => l_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    ' ----- After deleting the Cash flows for the asset  ' || l_return_status );
          IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;
        END IF;
        -- Create the Cash flows with the structure similiar to the LQ
        l_asset_caf_rec.parent_object_code := 'QUOTED_ASSET';
        l_asset_caf_rec.parent_object_id   := l_non_overiding_assets_tbl(t);
        l_asset_caf_rec.status_code        := 'WORK';
        l_asset_caf_rec.type_code          := 'INFLOW';
        l_asset_caf_rec.arrears_flag       := l_lq_payment_header_rec.arrears_flag;
        l_asset_caf_rec.stream_type_id     := l_rent_sty_id;
        l_asset_caf_rec.frequency_code     := l_lq_payment_header_rec.frequency_code;
        l_asset_caf_rec.quote_type_code    := l_quote_type_code;
        l_asset_caf_rec.quote_id           := p_qte_id;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          ' Frequency | Adv/ Arrears | Rate | Stub Days | Stub Amount | Periods | Amount | Start Date ' );
        FOR i in l_lq_payment_level_tbl.FIRST..l_lq_payment_level_tbl.LAST
        LOOP
          l_asset_cfl_tbl(i).record_mode := 'CREATE';
          l_asset_cfl_tbl(i).start_date  := l_lq_payment_level_tbl(i).start_date;
          l_asset_cfl_tbl(i).rate        := l_iir;
          l_asset_cfl_tbl(i).stub_amount := l_lq_payment_level_tbl(i).stub_amount;
          l_asset_cfl_tbl(i).stub_days   := l_lq_payment_level_tbl(i).stub_days;
          l_asset_cfl_tbl(i).periods     := l_lq_payment_level_tbl(i).periods;
          l_asset_cfl_tbl(i).periodic_amount := l_lq_payment_level_tbl(i).periodic_amount;
          -- Using the l_miss_amount and the ratio of the cash flows we need to determine the Amount @ every CFL
          IF l_lq_cash_flow_det_tbl(i).stub_days > 0
          THEN
            IF t = l_noa_pp_tbl.LAST
            THEN
              -- The Last Payment, hence use the Round LQ Amount - Sum of Prev. Assets Amount, instead of the proportion.
              l_asset_cfl_tbl(i).stub_amount := l_rnd_lq_payment_level_tbl(i).stub_amount - l_rnd_sum_assets_pmnts_tbl(i).stub_amount;
            ELSE
              l_asset_cfl_tbl(i).stub_amount :=
                l_miss_payment * (l_lq_payment_level_tbl(i).stub_amount / l_tmp_amount);
              l_rnd_sum_assets_pmnts_tbl(i).stub_amount := l_rnd_sum_assets_pmnts_tbl(i).stub_amount +
                okl_accounting_util.round_amount(
                  p_amount        => l_asset_cfl_tbl(i).stub_amount,
                  p_currency_code => l_currency );
            END IF;
          ELSIF l_lq_cash_flow_det_tbl(i).number_of_periods > 0
          THEN
            IF t = l_noa_pp_tbl.LAST
            THEN
              -- The Last Payment, hence use the Round LQ Amount - Sum of Prev. Assets Amount, instead of the proportion.
              l_asset_cfl_tbl(i).periodic_amount := l_rnd_lq_payment_level_tbl(i).periodic_amount - l_rnd_sum_assets_pmnts_tbl(i).periodic_amount;
            ELSE
              l_asset_cfl_tbl(i).periodic_amount :=
                l_miss_payment * (l_lq_payment_level_tbl(i).periodic_amount / l_tmp_amount );
              l_rnd_sum_assets_pmnts_tbl(i).periodic_amount := l_rnd_sum_assets_pmnts_tbl(i).periodic_amount +
                okl_accounting_util.round_amount(
                  p_amount        => l_asset_cfl_tbl(i).periodic_amount,
                  p_currency_code => l_currency );
            END IF;
          END IF;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            l_asset_caf_rec.frequency_code || ' | ' || l_asset_caf_rec.arrears_flag  || ' | ' || l_asset_cfl_tbl(i).rate|| ' | ' ||
            l_asset_cfl_tbl(i).stub_days || ' | ' || l_asset_cfl_tbl(i).stub_amount|| ' | ' || l_asset_cfl_tbl(i).periods|| ' | ' ||
            l_asset_cfl_tbl(i).periodic_amount || ' | ' || l_asset_cfl_tbl(i).start_Date  );
        END LOOP;
        -- Create the Cash flows for the Asset
        OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_transaction_control => NULL,
          p_cashflow_header_rec => l_asset_caf_rec,
          p_cashflow_level_tbl  => l_asset_cfl_tbl,
          x_return_status       => l_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data);
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'After calling create_cash_flow ' || l_return_status);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Bug 7440199: Quote Streams ER: RGOOTY: Start
        -- Based on the Derieved Cash flows for the Non-overriding Assets
        --  Generate the Streams for the Non-Overriding Assets
        IF l_asset_cfl_tbl.COUNT > 0
        THEN
          -- Delete the Temporary Streams Table
          l_cash_inflows.DELETE;
          l_noa_cash_flow_det_tbl.DELETE;
          -- Populate the Cash Flow Header Equivalent Record Structure to generate Streams
          l_noa_cash_flow_rec.caf_id := l_asset_caf_rec.cashflow_header_id;
          l_noa_cash_flow_rec.qte_id := p_qte_id;
          l_noa_cash_flow_rec.cfo_id := l_asset_caf_rec.cashflow_object_id;
          l_noa_cash_flow_rec.sts_code := 'WORK';
          l_noa_cash_flow_rec.sty_id := l_asset_caf_rec.stream_type_id;
          l_noa_cash_flow_rec.cft_code := 'PAYMENT_SCHEDULE';
          l_noa_cash_flow_rec.due_arrears_yn := l_asset_caf_rec.arrears_flag;
          l_noa_cash_flow_rec.start_date := NULL;
          l_noa_cash_flow_rec.number_of_advance_periods := NULL;
          -- Populate the Cash Flow Level equivalent Record Structure to generate streams
          FOR i in l_asset_cfl_tbl.FIRST .. l_asset_cfl_tbl.LAST
          LOOP
            l_noa_cash_flow_det_tbl(i).start_date  := l_asset_cfl_tbl(i).start_date;
            l_noa_cash_flow_det_tbl(i).rate        := l_asset_cfl_tbl(i).rate;
            l_noa_cash_flow_det_tbl(i).fqy_code    := l_asset_caf_rec.frequency_code;
            l_noa_cash_flow_det_tbl(i).number_of_periods := l_asset_cfl_tbl(i).periods;
            l_noa_cash_flow_det_tbl(i).amount      := l_asset_cfl_tbl(i).periodic_amount;
            l_noa_cash_flow_det_tbl(i).stub_days   := l_asset_cfl_tbl(i).stub_days;
            l_noa_cash_flow_det_tbl(i).stub_amount := l_asset_cfl_tbl(i).stub_amount;
          END LOOP;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   'Generating the Stream Elements for the Asset!' );
          gen_so_cf_strms(
            p_api_version            => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_cash_flow_rec          => l_noa_cash_flow_rec,
            p_cf_details_tbl         => l_noa_cash_flow_det_tbl,
            x_cash_inflow_strms_tbl  => l_cash_inflows);
          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- Place the information in the Consolidated Pricing Params Table
          -- so that the insert_quote_api inserts the Streams Captured here !
          pp_index := l_pp_non_sub_irr_tbl.COUNT + 1;
          l_pp_non_sub_irr_tbl(pp_index).line_type := 'FREE_FORM1';
          l_pp_non_sub_irr_tbl(pp_index).payment_type := 'QUOTED_ASSET';
          --l_pricing_parameter_tbl(pp_index).line_end_date := srvc_rec.line_end_date;
          l_pp_non_sub_irr_tbl(pp_index).cash_inflows := l_cash_inflows;
          l_pp_non_sub_irr_tbl(pp_index).cfo_id := l_asset_caf_rec.cashflow_object_id;
          -- Push the Residual Values also
          l_pp_non_sub_irr_tbl(pp_index).residual_inflows := l_noa_pp_tbl(t).residual_inflows;
        END IF;
        -- Bug 7440199: Quote Streams ER: RGOOTY: End
      END LOOP; -- Loop on the l_noa_det_prc_tbl
    END IF;
    -- Delete (if exists any..) LEASE_QUOTE_CONSOLIDATED cash flows existing
    --  at the Lease Quote level.
    l_cfo_exists_at_lq := 'NO';
    FOR t_rec IN check_cfo_exists_csr(
                  p_oty_code     => 'LEASE_QUOTE_CONSOLIDATED',
                  p_source_table => 'OKL_LEASE_QUOTES_B',
                  p_source_id    => p_qte_id,
                  p_sts_code     => 'WORK')
    LOOP
      l_cfo_exists_at_lq := t_rec.cfo_exists;
    END LOOP;
    IF  l_cfo_exists_at_lq = 'YES'
    THEN
      -- Delete the Payment structure already derieved by pricing
      okl_lease_quote_cashflow_pvt.delete_cashflows (
        p_api_version          => p_api_version,
        p_init_msg_list        => p_init_msg_list,
        p_transaction_control  => NULL,
        p_source_object_code   => 'LEASE_QUOTE_CONSOLIDATED',
        p_source_object_id     => p_qte_id,
        x_return_status        => l_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Deleted the Consolidated Cash flow levels @ LQ levels. Status: ' || l_return_status );
      IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;
    END IF; -- IF l_cfo_exists_at_lq
    -- Code for solving the payment amount @ LQ level follows ..
    -- If for all the assets, frequency, adv/arrears, the payment structure matches
    --  then the solve_pmnts_at_lq API returns the solved payment structure @ LQ level
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      '!!! *** DERIEVING THE CONSOLIDATED PAYMENT AMOUNT AT LEASE QUOTE LEVEL *** !!! ');
    solve_pmnts_at_lq(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => l_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_id             => p_qte_id,
      x_caf_rec        => l_lq_payment_header_rec,
      x_cfl_tbl        => l_lq_payment_level_tbl,
      x_solved         => l_solved);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF l_solved = 'YES' AND l_lq_payment_level_tbl IS NOT NULL AND l_lq_payment_level_tbl.COUNT > 0
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '!!! *** Payments can be derieved at Lease Quote level *** !!! ' || l_lq_payment_level_tbl.COUNT );
      l_lq_payment_header_rec.type_code          := 'INFLOW';
      l_lq_payment_header_rec.parent_object_code := 'LEASE_QUOTE_CONSOLIDATED';
      l_lq_payment_header_rec.parent_object_id   := p_qte_id;
      l_lq_payment_header_rec.status_code        := 'WORK';
      IF quote_rec.pricing_method = 'RC'
      THEN
        OPEN c_strm_type ( quote_rec.id, quote_rec.expected_start_date );
        FETCH c_strm_type INTO r_strm_type;
        CLOSE c_strm_type;
        l_rent_sty_id := r_strm_type.payment_type_id;
      END IF;
      l_lq_payment_header_rec.stream_type_id     := l_rent_sty_id;
      l_lq_payment_header_rec.quote_type_code    := l_quote_type_code;
      l_lq_payment_header_rec.quote_id           := p_qte_id;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        ' Frequency | Adv/ Arrears | Rate | Stub Days | Stub Amount | Periods | Amount | Start Date ' );
      FOR i IN l_lq_payment_level_tbl.FIRST .. l_lq_payment_level_tbl.LAST
      LOOP
        l_lq_payment_level_tbl(i).record_mode := 'CREATE';
        IF l_lq_payment_level_tbl(i).rate IS NULL
        THEN
          l_lq_payment_level_tbl(i).rate := l_lease_qte_rec.sub_iir;
        END IF;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          l_lq_payment_header_rec.frequency_code || ' | ' || l_lq_payment_header_rec.arrears_flag  || ' | ' || l_lq_payment_level_tbl(i).rate|| ' | ' ||
          l_lq_payment_level_tbl(i).stub_days || ' | ' || l_lq_payment_level_tbl(i).stub_amount|| ' | ' || l_lq_payment_level_tbl(i).periods|| ' | ' ||
          l_lq_payment_level_tbl(i).periodic_amount || ' | ' || l_lq_payment_level_tbl(i).start_Date  );
      END LOOP;
      OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_transaction_control => NULL,
        p_cashflow_header_rec => l_lq_payment_header_rec,
        p_cashflow_level_tbl  => l_lq_payment_level_tbl,
        x_return_status       => l_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Creation of LQ level cash flow levels stauts: ' || l_Return_Status );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '!!!!! PRICING ENGINE IS UNABLE TO DERIEVE PAYMENTS AT LQ LEVEL !!!!!' );
    END IF; -- IF l_solved = 'YES'
    -- Bug 7440199: Quote Streams ER: RGOOTY: Start
    --Get the service cash inflows and generate the streams
    FOR srvc_rec IN services_csr(p_qte_id)
    LOOP
      -- Delete the previous services cash inflows
      l_srvc_inflow_cfl_tbl.DELETE;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                    '!!!!!!  Handling service ');
      get_lq_srvc_cash_flows(
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        x_return_status    => l_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_srvc_type        => 'SERVICE',
        p_lq_id            => p_qte_id,
        p_srvc_id          => srvc_rec.srvc_id,
        x_inflow_caf_rec   => l_srvc_inflow_caf_rec,
        x_inflow_cfl_tbl   => l_srvc_inflow_cfl_tbl);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  'After get_lq_srvc_cash_flows ' || l_return_status );
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Based on the Inflows obtained generate the streams
      IF l_srvc_inflow_cfl_tbl.COUNT > 0
      THEN
        l_cash_inflows.DELETE;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 '!!!!!!! Obtained Service Cash flow levels !!!!!!!!' );
        gen_so_cf_strms(
          p_api_version            => p_api_version,
          p_init_msg_list          => p_init_msg_list,
          x_return_status          => l_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_cash_flow_rec          => l_srvc_inflow_caf_rec,
          p_cf_details_tbl         => l_srvc_inflow_cfl_tbl,
          x_cash_inflow_strms_tbl  => l_cash_inflows);
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Place the information in the pricing params
        pp_index := l_pp_non_sub_irr_tbl.COUNT + 1;
        l_pp_non_sub_irr_tbl(pp_index).line_type := 'SERVICE';
        l_pp_non_sub_irr_tbl(pp_index).payment_type := 'SERVICE';
        l_pp_non_sub_irr_tbl(pp_index).line_start_date := srvc_rec.line_start_date;
        --l_pricing_parameter_tbl(pp_index).line_end_date := srvc_rec.line_end_date;
        l_pp_non_sub_irr_tbl(pp_index).cash_inflows := l_cash_inflows;
        l_pp_non_sub_irr_tbl(pp_index).cfo_id := l_srvc_inflow_caf_rec.cfo_id;

        --Added by bkatraga for bug 7410991
        l_sum_assoc_assets_amt := 0;
        l_assoc_assets_count := 0;
        OPEN CHECK_ASSOC_ASSETS('SERVICE', srvc_rec.srvc_id);
        FETCH CHECK_ASSOC_ASSETS INTO l_sum_assoc_assets_amt, l_assoc_assets_count;
        CLOSE CHECK_ASSOC_ASSETS;

        IF(l_assoc_assets_count > 0) THEN
          l_assets_indx := 0;
          l_amount_tbl.DELETE;

          FOR i in l_cash_inflows.FIRST .. l_cash_inflows.LAST
          LOOP
            l_cash_inflows(i).cf_amount := okl_accounting_util.round_amount(p_amount => l_cash_inflows(i).cf_amount,
                                                                            p_currency_code => l_currency);
            l_amount_tbl(i) := 0;
          END LOOP;

          FOR assoc_asset_rec IN GET_ASSOC_ASSETS('SERVICE', srvc_rec.srvc_id)
          LOOP
            l_assets_indx := l_assets_indx + 1;

            pp_index := l_pp_non_sub_irr_tbl.COUNT + 1;
            l_pp_non_sub_irr_tbl(pp_index).line_type := 'ASSOC_ASSET_SRVC';
            l_pp_non_sub_irr_tbl(pp_index).payment_type := 'ASSOC_ASSET_SRVC';
            l_pp_non_sub_irr_tbl(pp_index).line_start_date := srvc_rec.line_start_date;
            l_pp_non_sub_irr_tbl(pp_index).cash_inflows := l_cash_inflows;
            l_pp_non_sub_irr_tbl(pp_index).cfo_id := l_srvc_inflow_caf_rec.cfo_id;
            l_pp_non_sub_irr_tbl(pp_index).link_asset_id := assoc_asset_rec.source_line_id;

            FOR i in l_cash_inflows.FIRST .. l_cash_inflows.LAST
            LOOP
              IF(l_assets_indx = l_assoc_assets_count) THEN --LAST ASSET
                 l_pp_non_sub_irr_tbl(pp_index).cash_inflows(i).cf_amount := l_cash_inflows(i).cf_amount - l_amount_tbl(i);
              ELSE
                IF(l_sum_assoc_assets_amt = 0) THEN
                  l_amount := 0;
                ELSE
                  l_amount := (assoc_asset_rec.amount/l_sum_assoc_assets_amt) * l_cash_inflows(i).cf_amount;
                  l_amount :=  okl_accounting_util.round_amount(p_amount => l_amount,
                                                                p_currency_code => l_currency);
                END IF;
                l_pp_non_sub_irr_tbl(pp_index).cash_inflows(i).cf_amount := l_amount;
                l_amount_tbl(i) := l_amount_tbl(i) + l_amount;
              END IF;
            END LOOP;
          END LOOP;
        END IF;
        -- Bug 7440199: Quote Streams ER: RGOOTY: End

      END IF;
    END LOOP;
    -- Bug 7440199: Quote Streams ER: RGOOTY: Start
    --Logic to generate Associated Asset Level streams for Financed and Rollover Fees
    FOR k in l_pp_non_sub_irr_tbl.first .. l_pp_non_sub_irr_tbl.last
    LOOP
      IF(l_pp_non_sub_irr_tbl(k).line_type IN('FINANCED','ROLLOVER')) THEN
        OPEN GET_FEE_ID(l_pp_non_sub_irr_tbl(k).cfo_id);
        FETCH GET_FEE_ID into l_fee_id;
        CLOSE GET_FEE_ID;

        l_sum_assoc_assets_amt := 0;
        l_assoc_assets_count := 0;
        OPEN CHECK_ASSOC_ASSETS(l_pp_non_sub_irr_tbl(k).line_type, l_fee_id);
        FETCH CHECK_ASSOC_ASSETS INTO l_sum_assoc_assets_amt, l_assoc_assets_count;
        CLOSE CHECK_ASSOC_ASSETS;

        IF(l_assoc_assets_count > 0) THEN
          l_assets_indx := 0;
          l_amount_tbl.DELETE;
          l_cash_inflows := l_pp_non_sub_irr_tbl(k).cash_inflows;

          FOR i in l_cash_inflows.FIRST .. l_cash_inflows.LAST
          LOOP
            l_cash_inflows(i).cf_amount := okl_accounting_util.round_amount(p_amount => l_cash_inflows(i).cf_amount,
                                                                            p_currency_code => l_currency);
            l_amount_tbl(i) := 0;
          END LOOP;

          FOR assoc_asset_rec IN GET_ASSOC_ASSETS(l_pp_non_sub_irr_tbl(k).line_type, l_fee_id)
          LOOP
            l_assets_indx := l_assets_indx + 1;

            pp_index := l_pp_non_sub_irr_tbl.COUNT + 1;
            l_pp_non_sub_irr_tbl(pp_index).line_type := 'ASSOC_ASSET_FEE';
            l_pp_non_sub_irr_tbl(pp_index).payment_type := 'ASSOC_ASSET_FEE';
            l_pp_non_sub_irr_tbl(pp_index).line_start_date := l_pp_non_sub_irr_tbl(k).line_start_date;
            l_pp_non_sub_irr_tbl(pp_index).cash_inflows := l_cash_inflows;
            l_pp_non_sub_irr_tbl(pp_index).cfo_id := l_pp_non_sub_irr_tbl(k).cfo_id;
            l_pp_non_sub_irr_tbl(pp_index).link_asset_id := assoc_asset_rec.source_line_id;

            FOR i in l_cash_inflows.FIRST .. l_cash_inflows.LAST
            LOOP
              IF(l_assets_indx = l_assoc_assets_count) THEN --LAST ASSET
                 l_pp_non_sub_irr_tbl(pp_index).cash_inflows(i).cf_amount := l_cash_inflows(i).cf_amount - l_amount_tbl(i);
              ELSE
                IF(l_sum_assoc_assets_amt = 0) THEN
                  l_amount := 0;
                ELSE
                  l_amount := (assoc_asset_rec.amount/l_sum_assoc_assets_amt) * l_cash_inflows(i).cf_amount;
                  l_amount :=  okl_accounting_util.round_amount(p_amount => l_amount,
                                                                p_currency_code => l_currency);
                END IF;
                l_pp_non_sub_irr_tbl(pp_index).cash_inflows(i).cf_amount := l_amount;
                l_amount_tbl(i) := l_amount_tbl(i) + l_amount;
              END IF;
            END LOOP;
          END LOOP;
        END IF;
      END IF;
    END LOOP;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'Before Calling the API insert_quote_streams ');
    insert_quote_streams(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => l_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_quote_id      => p_qte_id,
                         p_quote_type    => 'LEASE_QUOTE',
                         p_currency      => l_currency,
                         p_pricing_param_tbl => l_pp_non_sub_irr_tbl);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'After Calling the API insert_quote_streams x_return_status= ' || x_return_status);
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Bug 7440199: Quote Streams ER: RGOOTY: End
    -- Pass the results back
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'end debug OKLRPIUB.pls call ' || LOWER(l_api_name) );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                         p_api_name  => l_api_name,
                         p_pkg_name  => G_PKG_NAME,
                         p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                         x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END price_standard_quote;
END OKL_PRICING_UTILS_PVT;

/
