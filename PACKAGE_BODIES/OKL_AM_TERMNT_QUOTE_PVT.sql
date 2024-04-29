--------------------------------------------------------
--  DDL for Package Body OKL_AM_TERMNT_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_TERMNT_QUOTE_PVT" As
/* $Header: OKLRTNQB.pls 120.43.12010000.3 2009/08/05 12:59:50 rpillay ship $ */
--
-- BAKUCHIB Bug 2484327 start
--
-------------------------------------------------------------------------------------------------
-- GLOBAL VARIABLES
-------------------------------------------------------------------------------------------------
  G_NO_MATCHING_RECORD          CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE               CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_FIN_LINE_LTY_CODE                     OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_LEASE_SCS_CODE                        OKC_K_HEADERS_V.SCS_CODE%TYPE := 'LEASE';
  G_LOAN_SCS_CODE                         OKC_K_HEADERS_V.SCS_CODE%TYPE := 'LOAN';
  G_TLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'TLS';
  G_LEVEL_PROCEDURE            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_STATEMENT            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_termnt_quote_pvt.';
-------------------------------------------------------------------------------------------------
-- GLOBAL COMPSITE TYPE
-------------------------------------------------------------------------------------------------
    subtype tqdv_rec_type is OKL_TXD_QTE_LN_DTLS_PUB.tqdv_rec_type;
-------------------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
-------------------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';
------------------------------------------------------------------------------------------------------------

  -- Start of comments
  --
  -- Function  Name  : recalculate_quote
  -- Description     : Recalculate quote elements like Gain/Loss when a quote
  --                   amount is created/updated
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_rec
  -- Version         : 1.0
  -- History         : PAGARG 4102565 Created
  --
  -- End of comments
  PROCEDURE recalculate_quote(
               x_return_status  OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type)
  IS
    -- Cursor to get the quote and quote line details
    CURSOR get_qte_dtls_csr (p_line_id IN NUMBER) IS
      SELECT  qte.id,
              qte.qst_code,
              qte.qtp_code,
              qte.quote_number,
              qte.khr_id,
              qte.partial_yn,
              qte.early_termination_yn,
              tql.qlt_code
      FROM    okl_trx_quotes_b qte,
              okl_txl_quote_lines_b tql
      WHERE   tql.id  = p_line_id
      AND     tql.qte_id = qte.id;

    l_return_status VARCHAR2(3);
    lx_net_gain_loss NUMBER;

    l_quot_rec OKL_AM_CREATE_QUOTE_PVT.quot_rec_type;
    lp_quot_rec OKL_AM_CREATE_QUOTE_PVT.quot_rec_type;
    lx_quot_rec OKL_AM_CREATE_QUOTE_PVT.quot_rec_type;

    l_api_version       CONSTANT NUMBER := 1;
    l_msg_count NUMBER := OKL_API.G_MISS_NUM;
    l_msg_data VARCHAR2(2000);
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'recalculate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.id: ' || p_tqlv_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qlt_code: ' || p_tqlv_rec.qlt_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.kle_id: ' || p_tqlv_rec.kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.sty_id: ' || p_tqlv_rec.sty_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qte_id: ' || p_tqlv_rec.qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.line_number: ' || p_tqlv_rec.line_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.amount: ' || p_tqlv_rec.amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.modified_yn: ' || p_tqlv_rec.modified_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.taxed_yn: ' || p_tqlv_rec.taxed_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.defaulted_yn: ' || p_tqlv_rec.defaulted_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.org_id: ' || p_tqlv_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.start_date: ' || p_tqlv_rec.start_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.period: ' || p_tqlv_rec.period);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.number_of_periods: ' || p_tqlv_rec.number_of_periods);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.lock_level_step: ' || p_tqlv_rec.lock_level_step);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.advance_or_arrears: ' || p_tqlv_rec.advance_or_arrears);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_name: ' || p_tqlv_rec.yield_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_value: ' || p_tqlv_rec.yield_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.implicit_interest_rate: ' || p_tqlv_rec.implicit_interest_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_value: ' || p_tqlv_rec.asset_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.residual_value: ' || p_tqlv_rec.residual_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.unbilled_receivables: ' || p_tqlv_rec.unbilled_receivables);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_quantity: ' || p_tqlv_rec.asset_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.quote_quantity: ' || p_tqlv_rec.quote_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_id: ' || p_tqlv_rec.split_kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_name: ' || p_tqlv_rec.split_kle_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_code: ' || p_tqlv_rec.currency_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_code: ' || p_tqlv_rec.currency_conversion_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_type: ' || p_tqlv_rec.currency_conversion_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_rate: ' || p_tqlv_rec.currency_conversion_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_date: ' || p_tqlv_rec.currency_conversion_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.due_date: ' || p_tqlv_rec.due_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.try_id: ' || p_tqlv_rec.try_id);
	 END IF;
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Get quote and quote line details
    FOR get_qte_dtls_rec IN get_qte_dtls_csr (p_tqlv_rec.id)
    LOOP
      l_quot_rec.id := get_qte_dtls_rec.id;
      l_quot_rec.khr_id := get_qte_dtls_rec.khr_id;
      l_quot_rec.qtp_code := get_qte_dtls_rec.qtp_code;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_CREATE_QUOTE_PVT.get_net_gain_loss');
      END IF;
      -- recalculate gain/loss
      OKL_AM_CREATE_QUOTE_PVT.get_net_gain_loss(
                                 p_quote_rec      => l_quot_rec,
                                 p_chr_id         => l_quot_rec.khr_id,
                                 x_return_status  => l_return_status,
                                 x_net_gain_loss  => lx_net_gain_loss);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_CREATE_QUOTE_PVT.get_net_gain_loss , return status: ' || l_return_status);
      END IF;

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
      THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
      THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- set the quote header elements for update
      lp_quot_rec.id := l_quot_rec.id ;
      lp_quot_rec.gain_loss := lx_net_gain_loss;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TRX_QUOTES_PUB.update_trx_quotes');
      END IF;
      -- update the quote header with recalculated GAIN LOSS
      OKL_TRX_QUOTES_PUB.update_trx_quotes (
                p_api_version      =>   l_api_version,
                p_init_msg_list    =>   OKL_API.G_FALSE,
                x_msg_count        =>   l_msg_count,
                x_msg_data         =>   l_msg_data,
                p_qtev_rec         =>   lp_quot_rec,
                x_qtev_rec         =>   lx_quot_rec,
                x_return_status    =>   l_return_status);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TRX_QUOTES_PUB.update_trx_quotes, return status: ' || l_return_status);
      END IF;

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
      THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
      THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

    x_return_status := l_return_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
     END IF;
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
     END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS
    THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END recalculate_quote;

  -- Start of comments
  --
  -- Function  Name  : validate_upd_quote_line
  -- Description     : validate for quote rules during update of quote line
  -- RULE 1          : Check for Min/Max rule if quote type "Purchase Amount" and Auto Quote
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_rec
  -- Version         : 1.0
  -- History         : PAGARG 4102565 Created
  --                 : rmunjulu Bug 4246171 Pass kle_id when evaluating min/max values.
  --
  -- End of comments
  PROCEDURE validate_upd_quote_line(
               x_return_status  OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type)
  IS
    -- Cursor to get the quote and quote line details
    CURSOR get_qte_dtls_csr (p_line_id IN NUMBER) IS
      SELECT  qte.id,
              qte.qst_code,
              qte.qtp_code,
              qte.quote_number,
              qte.khr_id,
              qte.partial_yn,
              qte.early_termination_yn,
              tql.qlt_code,
              tql.kle_id
      FROM    okl_trx_quotes_b qte,
              okl_txl_quote_lines_b tql
      WHERE   tql.id  = p_line_id
      AND     tql.qte_id = qte.id;

      -- Get asset number for line id
      CURSOR get_asset_number_csr (p_line_id IN NUMBER) IS
        SELECT kle.name asset_number
        FROM   okc_k_lines_v kle
        WHERE  kle.id = p_line_id;

      l_return_status VARCHAR2(3);

      g_empty_line_tbl OKL_AM_CALCULATE_QUOTE_PVT.asset_tbl_type;
      g_sub_tqlv_tbl  OKL_AM_CALCULATE_QUOTE_PVT.tqlv_tbl_type;
      l_qtev_rec OKL_AM_CALCULATE_QUOTE_PVT.qtev_rec_type;
      l_min_max_value NUMBER;
      l_rgd_code VARCHAR2(300);
      l_operand VARCHAR2(300);
      l_min_value NUMBER;
      l_max_value NUMBER;
      l_min_amt VARCHAR2(30);
      l_max_amt VARCHAR2(30);
      l_asset_num VARCHAR2(350);
      l_module_name VARCHAR2(500) := G_MODULE_NAME || 'validate_upd_quote_line';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
      is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
      is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.id: ' || p_tqlv_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qlt_code: ' || p_tqlv_rec.qlt_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.kle_id: ' || p_tqlv_rec.kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.sty_id: ' || p_tqlv_rec.sty_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qte_id: ' || p_tqlv_rec.qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.line_number: ' || p_tqlv_rec.line_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.amount: ' || p_tqlv_rec.amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.modified_yn: ' || p_tqlv_rec.modified_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.taxed_yn: ' || p_tqlv_rec.taxed_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.defaulted_yn: ' || p_tqlv_rec.defaulted_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.org_id: ' || p_tqlv_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.start_date: ' || p_tqlv_rec.start_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.period: ' || p_tqlv_rec.period);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.number_of_periods: ' || p_tqlv_rec.number_of_periods);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.lock_level_step: ' || p_tqlv_rec.lock_level_step);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.advance_or_arrears: ' || p_tqlv_rec.advance_or_arrears);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_name: ' || p_tqlv_rec.yield_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_value: ' || p_tqlv_rec.yield_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.implicit_interest_rate: ' || p_tqlv_rec.implicit_interest_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_value: ' || p_tqlv_rec.asset_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.residual_value: ' || p_tqlv_rec.residual_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.unbilled_receivables: ' || p_tqlv_rec.unbilled_receivables);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_quantity: ' || p_tqlv_rec.asset_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.quote_quantity: ' || p_tqlv_rec.quote_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_id: ' || p_tqlv_rec.split_kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_name: ' || p_tqlv_rec.split_kle_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_code: ' || p_tqlv_rec.currency_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_code: ' || p_tqlv_rec.currency_conversion_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_type: ' || p_tqlv_rec.currency_conversion_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_rate: ' || p_tqlv_rec.currency_conversion_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_date: ' || p_tqlv_rec.currency_conversion_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.due_date: ' || p_tqlv_rec.due_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.try_id: ' || p_tqlv_rec.try_id);
	 END IF;

    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Get quote and quote line details and check for min/max value for the same
    FOR get_qte_dtls_rec IN get_qte_dtls_csr (p_tqlv_rec.id)
    LOOP
      -- RULE 1 : Check for Min/Max rule if quote type "Purchase Amount" and Auto Quote
      IF  get_qte_dtls_rec.qlt_code = 'AMBPOC'  -- Purchase amount
          AND get_qte_dtls_rec.qtp_code NOT LIKE 'TER_MAN%' -- Auto quote
      THEN

        l_qtev_rec.id := get_qte_dtls_rec.id;
        l_qtev_rec.khr_id := get_qte_dtls_rec.khr_id;

        IF NVL(get_qte_dtls_rec.early_termination_yn,'N') = 'Y'
        THEN
          l_rgd_code := 'AMTEOC'; -- Early Term Purchase Conditions
        ELSE
          l_rgd_code := 'AMTFOC'; -- End of Term Purchase Conditions
        END IF;

        l_operand := 'AMBPOC'; -- Purchase Amount

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_CALCULATE_QUOTE_PVT.get_operand_value');
        END IF;
        -- Check for Min/Max Rule
        OKL_AM_CALCULATE_QUOTE_PVT.get_operand_value (
                           p_rgd_code         => l_rgd_code,
                           p_operand          => l_operand,
                           p_qtev_rec         => l_qtev_rec,
                           p_rule_cle_id      => NULL,
                           p_formul_cle_id    => get_qte_dtls_rec.kle_id, -- rmunjulu Bug 4246171 Pass kle_id when getting min/max values
                           p_head_rgd_code    => NULL,
                           p_line_rgd_code    => NULL,
                           p_asset_tbl        => g_empty_line_tbl,
                           px_sub_tqlv_tbl    => g_sub_tqlv_tbl,
                           x_operand_value    => l_min_max_value,
                           x_return_status    => l_return_status,
                           x_min_value        => l_min_value,
                           x_max_value        => l_max_value);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_CALCULATE_QUOTE_PVT.get_operand_value , return status: ' || l_return_status);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_max_value  : ' || l_max_value);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_min_max_value  : ' || l_min_max_value);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_min_value  : ' || l_min_value);
        END IF;

        -- Check if value entered falls within the range of Min/Max
        IF p_tqlv_rec.amount < l_min_value
           OR p_tqlv_rec.amount > l_max_value
        THEN
          l_min_amt := nvl(to_char(l_min_value),' '); -- rmunjulu 10-Jan-05 do nvl
          l_max_amt := nvl(to_char(l_max_value),' '); -- rmunjulu 10-Jan-05 do nvl

          IF get_qte_dtls_rec.kle_id IS NOT NULL
             OR  get_qte_dtls_rec.kle_id <> OKL_API.G_MISS_NUM
          THEN

            -- get asset number
            FOR get_asset_number_rec IN get_asset_number_csr (get_qte_dtls_rec.kle_id)
            LOOP
              l_asset_num := get_asset_number_rec.asset_number;
            END LOOP;

            -- Invalid purchase amount entered AMT_ENTERED for Asset Number ASSET_NUM.
            -- Please enter purchase amount within the range minimum = MIN_AMT and maximum = MAX_AMT.
            OKL_API.set_message(
                          p_app_name      => 'OKL',
                          p_msg_name      => 'OKL_AM_MIN_MAX_ASSET_ERR',
                          p_token1        => 'AMT_ENTERED',
                          p_token1_value  => p_tqlv_rec.amount,
                          p_token2        => 'ASSET_NUM',
                          p_token2_value  => l_asset_num,
                          p_token3        => 'MIN_AMT',
                          p_token3_value  => l_min_amt,
                          p_token4        => 'MAX_AMT',
                          p_token4_value  => l_max_amt);

          ELSE -- Quote amount at contract level

            -- Invalid purchase amount entered AMT_ENTERED.
            -- Please enter purchase amount within the range minimum = MIN_AMT and maximum = MAX_AMT.
            OKL_API.set_message(
                          p_app_name      => 'OKL',
                          p_msg_name      => 'OKL_AM_MIN_MAX_ERR',
                          p_token1        => 'AMT_ENTERED',
                          p_token1_value  => p_tqlv_rec.amount,
                          p_token2        => 'MIN_AMT',
                          p_token2_value  => l_min_amt,
                          p_token3        => 'MAX_AMT',
                          p_token3_value  => l_max_amt);

          END IF;
          l_return_status := OKL_API.G_RET_STS_ERROR;

        END IF;
      END IF;
    END LOOP;

    x_return_status := l_return_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
     END IF;
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
     END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS
    THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END validate_upd_quote_line;

  -- Start of comments
  --
  -- Procedure Name	: check_asset_validity_in_fa
  -- Description	: checks asset validity in Fixed Assets
  -- Business Rules	: FA has following restriction during adjustment/retirment
  --                  1. You can retire retroactively only in the current fiscal year,
  --                  2. and only after the most recent transaction date.
  --                  if p_check_fa_year = Y then will check for FA fiscal year validity
  --                  if p_check_fa_trn = Y then will check for FA transaction date validity
  -- Parameters		:
  -- History        : rmunjulu EDAT Created
  --                : rmunjulu Bug 4143251 Added code to check quote effective date should be
  --                  in FA Fiscal year
  -- Version		: 1.0
  --
  -- End of comments
  PROCEDURE check_asset_validity_in_fa(
                p_kle_id          IN NUMBER,
                p_trn_date        IN DATE, -- quote eff from date will be passed
                p_check_fa_year   IN VARCHAR2,
				p_check_fa_trn    IN VARCHAR2,
				p_contract_number IN VARCHAR2,
				x_return_status   OUT NOCOPY VARCHAR2) AS

     -- get all books and asset_id for financial asset id (p_kle_id)
     CURSOR get_fa_dtls_csr (p_kle_id IN NUMBER) IS
         SELECT oal.asset_id asset_id,
                oal.asset_number asset_number,
                fab.book_type_code book_type_code
         FROM   OKX_ASSET_LINES_V oal,
		        FA_BOOKS fab
         WHERE  oal.parent_line_id = p_kle_id -- fin id
         AND    oal.asset_id = fab.asset_id
         AND    fab.date_ineffective IS NULL
         AND    fab.transaction_header_id_out IS NULL;

    -- get the max transaction date from FA -- before this there can be no transaction
    -- cursor provided by FA team
	CURSOR get_fa_trn_csr (p_asset_id in NUMBER,
	                       p_book     in VARCHAR2) IS
         SELECT max(th.transaction_date_entered) transaction_date_entered
         FROM   FA_TRANSACTION_HEADERS th
         WHERE  th.asset_id = p_asset_id
         AND    th.book_type_code = p_book;

	l_max_transaction_date DATE;
	fa_exception EXCEPTION;
	l_return_status VARCHAR2(3);

	-- rmunjulu Bug 4143251
	l_fa_fiscal_year VARCHAR2(10);
	l_quote_eff_year VARCHAR2(10);

        -- CDUBEY for Bug 5181502
	p_calendar_period_close_date DATE;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_asset_validity_in_fa';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_kle_id: ' || p_kle_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_trn_date: ' || p_trn_date);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_check_fa_year: ' || p_check_fa_year);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_check_fa_trn: ' || p_check_fa_trn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_number: ' || p_contract_number);
     END IF;

     l_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- loop thru all the FA books for the asset and for each book check the fa validations
     FOR get_fa_dtls_rec IN get_fa_dtls_csr (p_kle_id) LOOP

        -- call cache for book details
        IF NOT fa_cache_pkg.fazcbc(X_book => get_fa_dtls_rec.book_type_code) THEN

           -- message : error during FA check for contract CONTRACT_NUMBER.
           OKL_API.set_message (
            			 p_app_name     => 'OKL',
           	    		 p_msg_name     => 'OKL_AM_ERR_FA_CHECK',
                         p_token1       => 'CONTRACT_NUMBER',
                         p_token1_value => p_contract_number);

           RAISE fa_exception;

        END IF;

        -- call the cache for fiscal year details
        IF NOT fa_cache_pkg.fazcfy

          (X_fiscal_year_name => fa_cache_pkg.fazcbc_record.fiscal_year_name,

           X_fiscal_year => fa_cache_pkg.fazcbc_record.current_fiscal_year) THEN

           -- message : error during FA check for contract CONTRACT_NUMBER.
           OKL_API.set_message (
            			 p_app_name     => 'OKL',
           	    		 p_msg_name     => 'OKL_AM_ERR_FA_CHECK',
                         p_token1       => 'CONTRACT_NUMBER',
                         p_token1_value => p_contract_number);

           RAISE fa_exception;

        END IF;

        -- check for FA fiscal year check to make sure trn date is not before current fiscal year date
        IF p_check_fa_year = 'Y' THEN

           -- rmunjulu 4384945
           IF NOT fa_cache_pkg.fazcdp(X_book_type_code => get_fa_dtls_rec.book_type_code) THEN

              -- message : error during FA check Deprn Period information.
              OKL_API.set_message (
            			 p_app_name     => 'OKL',
           	    		 p_msg_name     => 'OKL_AM_ERR_FA_CHECK',
                         p_token1       => 'CONTRACT_NUMBER',
                         p_token1_value => p_contract_number);

              RAISE fa_exception;
           END IF;

           -- if okl transaction date before current fiscal year then raise error

	  -- CDUBEY for Bug 5181502, fa_cache_pkg is not refreshed with the current close period, so have quried the data from the table directly
	   SELECT calendar_period_close_date INTO  p_calendar_period_close_date FROM fa_deprn_periods WHERE  book_type_code = get_fa_dtls_rec.book_type_code AND period_close_date is null;

           IF (trunc(p_trn_date) < trunc(fa_cache_pkg.fazcfy_record.start_date)) THEN -- rmunjulu 4384945

               -- message Quote Effective From date EFFECTIVE_DATE can not be before Fixed Assets fiscal year start date START_DATE.
               OKL_API.set_message (
            			 p_app_name     => 'OKL',
           	    		 p_msg_name     => 'OKL_AM_ERR_FA_YEAR_START_DATE',
                         p_token1       => 'EFFECTIVE_DATE',
                         p_token1_value => trunc(p_trn_date),
                         p_token2       => 'START_DATE',
						 p_token2_value =>trunc(fa_cache_pkg.fazcfy_record.start_date));

               RAISE fa_exception;

            -- rmunjulu 4384945 if okl transaction date after Fixed Assets calendar period close date
            ELSIF (trunc(p_trn_date) > trunc(p_calendar_period_close_date)) THEN -- CDUBEY for Bug 5181502

                --Quote Effective From date EFFECTIVE_DATE can not be after Fixed Assets calendar period close date END_DATE.
                OKL_API.set_message (
            			 p_app_name     => 'OKL',
           	    		 p_msg_name     => 'OKL_AM_ERR_FA_CAL_END_DATE',
                         p_token1       => 'EFFECTIVE_DATE',
                         p_token1_value => trunc(p_trn_date),
                         p_token2       => 'END_DATE',
						 p_token2_value =>trunc(p_calendar_period_close_date)); -- CDUBEY for Bug 5181502

                RAISE fa_exception;
           END IF;

/*
           -- rmunjulu Bug 4143251 Added check to make sure quote effective from date falls in current FA fiscal year
		   l_fa_fiscal_year := to_char(fa_cache_pkg.fazcbc_record.current_fiscal_year);
		   l_quote_eff_year := substr(to_char(p_trn_date,'MM/DD/YYYY'),7);

		   -- If FA Fiscal year and quote effective date year do not match then error
		   IF l_fa_fiscal_year <> l_quote_eff_year THEN

               -- message : Quote Effective From date EFFECTIVE_DATE should be in current fixed assets fiscal year FA_FISCAL_YEAR.
               OKL_API.set_message (
            			 p_app_name     => 'OKL',
           	    		 p_msg_name     => 'OKL_AM_ERR_FA_FISCAL_YEAR',
                         p_token1       => 'EFFECTIVE_DATE',
                         p_token1_value => trunc(p_trn_date),
						 p_token2       => 'FA_FISCAL_YEAR',
						 p_token2_value => l_fa_fiscal_year);

               RAISE fa_exception;

		   END IF;
*/
        END IF;

        -- check for FA transactions to make sure trn date is not before any FA transactions
        IF p_check_fa_trn = 'Y' THEN

           -- get the max transaction date for FA asset in this book
           FOR get_fa_trn_rec IN get_fa_trn_csr (get_fa_dtls_rec.asset_id,
		                                         get_fa_dtls_rec.book_type_code) LOOP

		       l_max_transaction_date := get_fa_trn_rec.transaction_date_entered;

           END LOOP;

           -- if okl transaction is before max transaction then raise error
           IF (trunc(p_trn_date) <= trunc(l_max_transaction_date)) then

               -- message : Transactions in Fixed assets exist after Quote Effective From date EFFECTIVE_DATE.
               OKL_API.set_message (
            			 p_app_name     => 'OKL',
           	    		 p_msg_name     => 'OKL_AM_ERR_FA_TRN',
                         p_token1       => 'EFFECTIVE_DATE',
                         p_token1_value => trunc(p_trn_date));

               RAISE fa_exception;

           END IF;
        END IF;
	 END LOOP;

	 x_return_status := l_return_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION

     WHEN fa_exception THEN
     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'fa_exception');
     END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

     WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => sqlcode,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => sqlerrm);

  END check_asset_validity_in_fa;


  -- Start of comments
  -- Function Name	: check_asset_sno
  -- Description	: Check's for a given booked asset line, if there are serial numbers.
  -- Business Rules	:
  -- Parameters IN      : p_asset_line    -- Financial Asset line
  --            OUT       x_return_status -- Status of the Procedure
  --            OUT       x_sno_yn        -- True/False indicates Asset has serial Number or not.
  --            OUT       x_clev_tbl      -- Install Base Line Id
  -- Version		: 1.0
  -- History            : BAKUCHIB 10-DEC-2002 Bug 2484327 Created
  --                      RMUNJULU 24-JAN-03 2759726 Changed cursor and removed
  --                      contract sts check
  -- End of comments
  FUNCTION check_asset_sno(p_asset_line IN OKL_K_LINES.ID%TYPE,
                           x_sno_yn     OUT NOCOPY VARCHAR2,
                           x_clev_tbl   OUT NOCOPY clev_tbl_type) RETURN VARCHAR2 AS

    G_CONTRACT_INACTIVE   CONSTANT VARCHAR2(200) := 'OKL_AM_CONTRACT_INACTIVE';
    lv_sno_yn                      VARCHAR2(3) := OKL_API.G_FALSE;
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(3)	:= OKL_API.G_RET_STS_SUCCESS;
    lv_sts_code                    OKC_K_LINES_B.STS_CODE%TYPE;
    lv_lty_code                    OKC_LINE_STYLES_B.LTY_CODE%TYPE;
    lv_contract_number             OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;

    -- Cursor to Know asset has serial number
    -- RMUNJULU 24-JAN-03 2759726 Taken out the line status check
    -- and check line sts same as header sts
    CURSOR l_asset_sno_csr (p_asset_line  IN OKL_K_LINES.ID%TYPE) IS
    SELECT csi.serial_number,
           cle_ib.id
    FROM csi_item_instances csi,
         okc_k_items cim_ib,
         okc_line_styles_b lse_ib,
         okc_k_lines_b cle_ib,
         okc_line_styles_b lse_inst,
         okc_k_lines_b cle_inst,
         okc_line_styles_b lse_fin,
         okc_k_lines_b cle_fin,
         okc_k_headers_b khr -- RMUNJULU 24-JAN-03 2759726 Added
    WHERE cle_fin.cle_id is null
--    AND cle_fin.sts_code = 'BOOKED' -- RMUNJULU 24-JAN-03 2759726 Removed
    AND cle_fin.chr_id = khr.id -- RMUNJULU 24-JAN-03 2759726 Added
    AND cle_fin.sts_code = khr.sts_code -- RMUNJULU 24-JAN-03 2759726 Added
    AND cle_fin.chr_id = cle_fin.dnz_chr_id
    AND lse_fin.id = cle_fin.lse_id
    AND lse_fin.lty_code = 'FREE_FORM1'
    AND cle_inst.cle_id = cle_fin.id
    AND cle_inst.dnz_chr_id = cle_fin.dnz_chr_id
    AND cle_inst.lse_id = lse_inst.id
    AND lse_inst.lty_code = 'FREE_FORM2'
    AND cle_ib.cle_id = cle_inst.id
    AND cle_ib.dnz_chr_id = cle_fin.dnz_chr_id
    AND cle_ib.lse_id = lse_ib.id
    AND lse_ib.lty_code = 'INST_ITEM'
    AND cim_ib.cle_id = cle_ib.id
    AND cim_ib.dnz_chr_id = cle_ib.dnz_chr_id
    AND cim_ib.object1_id1 = csi.instance_id
    AND cim_ib.object1_id2 = '#'
    AND cim_ib.jtot_object1_code = 'OKX_IB_ITEM'
    AND cle_fin.id = p_asset_line;

    -- To get the Line code of the asset line,
    -- Status of the contract and the contract number
    CURSOR l_ast_line_csr(p_asset_line OKL_K_LINES.ID%TYPE)
    IS
    SELECT lse.lty_code,
           cle.sts_code,
           chr.contract_number
    FROM okc_k_lines_b cle,
         okc_k_headers_b chr,
         okc_line_styles_b lse
    WHERE cle.id = p_asset_line
    AND cle.lse_id = lse.id
    AND cle.dnz_chr_id = chr.id;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_asset_sno';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_asset_line: ' || p_asset_line);
    END IF;

    OPEN  l_ast_line_csr(p_asset_line => p_asset_line);
    FETCH l_ast_line_csr INTO lv_lty_code,
                              lv_sts_code,
                              lv_contract_number;
    IF l_ast_line_csr%NOTFOUND THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_NO_MATCHING_RECORD,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'Asset Line');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE l_ast_line_csr;

    IF lv_lty_code <> 'FREE_FORM1' THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_INVALID_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'p_asset_line');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- RMUNJULU 24-JAN-03 2759726 Removed check that K sts is Booked
--    IF lv_sts_code <> 'BOOKED' THEN
      -- Unable to complete process because the Contract CONTRACT_NUMBER status is STATUS.
--      OKL_API.set_message(p_app_name      => G_APP_NAME,
--                          p_msg_name      => G_CONTRACT_INACTIVE,
--                          p_token1        => 'CONTRACT_NUMBER',
--                          p_token1_value  => lv_contract_number,
--                          p_token2        => 'STATUS',
--                          p_token2_value  => lv_sts_code);
--      RAISE OKL_API.G_EXCEPTION_ERROR;
--    END IF;

    -- Cursor to Know asset has serial number
    FOR r_asset_sno_csr IN l_asset_sno_csr(p_asset_line => p_asset_line) LOOP
      IF r_asset_sno_csr.serial_number IS NOT NULL OR
         r_asset_sno_csr.serial_number <> OKL_API.G_MISS_CHAR THEN
         lv_sno_yn := OKL_API.G_TRUE;
      END IF;
      x_clev_tbl(i).id := r_asset_sno_csr.id;
      i := i + 1;
    END LOOP;
    x_sno_yn := lv_sno_yn;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
    IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning l_return_status: ' || l_return_status);
    END IF;
    RETURN l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;
      IF l_ast_line_csr%ISOPEN THEN
        CLOSE l_ast_line_csr;
      END IF;
      IF l_asset_sno_csr%ISOPEN THEN
        CLOSE l_asset_sno_csr;
      END IF;
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

      IF l_ast_line_csr%ISOPEN THEN
        CLOSE l_ast_line_csr;
      END IF;
      IF l_asset_sno_csr%ISOPEN THEN
        CLOSE l_asset_sno_csr;
      END IF;
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_return_status;
  END check_asset_sno;
-----------------------------------------------------------------------------------------------------
--
-- BAKUCHIB Bug 2484327 end
--

  -- Start of comments
  --
  -- Procedure Name	: terminate_quote
  -- Description	: terminates the quote
  --
  -- Business Rules	:
  -- Parameters		:
  -- History        : RMUNJULU -- 12-DEC-02 Bug # 2484327 -- Added code to check
  --                  for accepted quote based on asset level termination changes
  --                : RMUNJULU 30-DEC-02 2699412 Changed cursor and added code
  --                  to cancel other termination quotes and set currency cols
  --                : RMUNJULU 06-JAN-03 2736865 Added code to check date eff from
  --                : RMUNJULU 14-JAN-03 2748581 Added condition to check only
  --                  when partial line
  --                : RMUNJULU 03-APR-03 2880556 Added condition to check for
  --                  past unbilled streams
  --                : RMUNJULU 07-APR-03 2883292 Changed the msg and added new token
  --                : RMUNJULU 09-APR-03  Changed the query to get only BILLABLE streams
  --                : RMUNJULU 14-APR-03 2904268 Added amount > 0
  --                : RMUNJULU 3078988 Added code to check if accruals were done for the contract
  --                : RMUNJULU 3061751 SERVICE K INTERGRATION CODE
  --                : PAGARG   29-SEP-04 Bug #3921591
  --                           Added additional parameter p_acceptance_source
  --                           This is to identify the source from where this
  --                           procedure is being called. Default value for this
  --                           is null.
  --                           Rollover quote can be accepted only through
  --                           ativiation of rolled over contract. So, as part
  --                           of that of that process, this procedure should be
  --                           called with p_acceptance_source as 'ROLLOVER'
  --                           throw error if p_acceptance_source is 'ROLLOVER'
  --                           but quote is not a rollover quote.
  --                : rmunjulu EDAT Added code to get quote_creation_date and do
  --                  quote_eff_to_max date logic based on that. Also added code to check
  --                  for insurance claims if pre-dated quote
  --                : PAGARG   21-OCT-04 Bug# 3925453
  --                           Release quote can be accepted only through
  --                           ativiation of released contract. So, as part
  --                           of that of that process, this procedure should be
  --                           called with p_acceptance_source as 'RELEASE_CONTRACT'
  --                           throw error if p_acceptance_source is 'RELEASE_CONTRACT'
  --                           but quote is not a release quote.
  --                           set the value of date_effective_to from dtabase
  --                : rmunjulu 10-Nov-04 Rollover/Release Fixes for the checks
  --                : rmunjulu EDAT Modified to check accruals till quote eff from date
  --                : rmunjulu 19-Jan-05 4128965 Modified to NOT launch Workflow if ROLLOVER
  --                : rmunjulu 21-Jan-05 4128965 Added additional check to catch error
  --                : rmunjulu Bug 4143251 Modified to do FA checks for all quotes (NOT JUST PRIOR DATED QUOTES)
  --                : rmunjulu EDAT 16-Feb-05 Added back the condition check for transactions only for POST dated quotes
  --                : rmunjulu Bug 4201215 Eff_To date passed but already expired
  --                : RMUNJULU LOANS_ENHANCEMENTS Termination with purchase not allowed for loans
  --                   Partial Line Termination not allowed for loans with actual/estimated actual
  --                   Also check for verify int calculation done or not
  --                   Also use new API to check accruals done or not.
  --                : SECHAWLA 04-JAN-06 4915133 - partial quotes not allowed for a loan K with rec rec method
  --                   'ESTIMATED_AND_BILLED'/'ACTUAL'
  -- Version		: 1.0
  --
  -- End of comments
  PROCEDURE terminate_quote(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_term_rec                      IN  term_rec_type,
    x_term_rec                      OUT NOCOPY term_rec_type,
    x_err_msg                       OUT NOCOPY VARCHAR2,
    p_acceptance_source             IN  VARCHAR2 DEFAULT NULL)  AS



    -- RMUNJULU -- 12-DEC-02 Bug # 2484327 Changes for Asset level termination
    -- added qst_code to cursor
    -- Cursor to get the database values for the quote
    -- RMUNJULU 30-DEC-02 2699412 Added columns
    -- RMUNJULU 3061751 Added partial_yn for SERVICE_K_INTEGRATION
    CURSOR qte_db_vals_csr ( p_id IN NUMBER) IS
    SELECT OKHV.id,
           OTQV.accepted_yn,
           OTQV.date_effective_from,
           OTQV.date_effective_to,
           OTQV.quote_number,
           OKHV.contract_number,
           OTQV.id qte_id,
           OTQV.qtp_code,
           OTQV.qst_code, -- RMUNJULU -- 12-DEC-02 Bug # 2484327 added
           OTQV.currency_conversion_date, -- RMUNJULU 30-DEC-02 2699412 added
           OTQV.currency_code, -- RMUNJULU 30-DEC-02 2699412 added
           OTQV.currency_conversion_code, -- RMUNJULU 30-DEC-02 2699412 added
           OTQV.partial_yn, -- RMUNJULU 3061751 Added
           TRUNC(OTQV.creation_date), -- rmunjulu EDAT Added
           OTQV.perdiem_amount, -- rmunjulu LOANS_ENHANCEMENT
           OTQV.REPO_QUOTE_INDICATOR_YN -- Bug 6674730
    FROM   OKL_TRX_QUOTES_V       OTQV,
           OKL_K_HEADERS_FULL_V   OKHV
    WHERE  OTQV.id       = p_id
    AND    OTQV.khr_id   = OKHV.id;


    -- Cursor to get the contract number
    CURSOR get_k_num_csr ( p_khr_id IN NUMBER) IS
    SELECT  contract_number
    FROM    OKL_K_HEADERS_FULL_V K
    WHERE   K.id = p_khr_id;


      -- RMUNJULU -- 12-DEC-02 Bug # 2484327 Changes for Asset level termination
      -- Get the lines for the quote
      -- RMUNJULU 14-JAN-03 2748581 Added asset_quantity column
      CURSOR get_qte_lines_csr ( p_qte_id IN NUMBER) IS
         SELECT KLE.id   kle_id,
                KLE.name asset_name,
                TQL.id   tql_id,
                TQL.quote_quantity quote_quantity,
                TQL.asset_quantity asset_quantity
         FROM   OKL_TXL_QUOTE_LINES_V  TQL,
                OKC_K_LINES_V          KLE
         WHERE  TQL.qte_id = p_qte_id
         AND    TQL.qlt_code = 'AMCFIA'
         AND    TQL.kle_id = KLE.id;


      -- RMUNJULU -- 12-DEC-02 Bug # 2484327 Changes for Asset level termination
      -- Get the count of IB lines for the quote_line_id (TQL_ID )
      CURSOR get_ib_lines_cnt_csr ( p_tql_id IN NUMBER) IS
         SELECT COUNT(TXD.id) ib_lines_count
         FROM   OKL_TXD_QUOTE_LINE_DTLS  TXD
         WHERE  TXD.tql_id = p_tql_id;



      -- RMUNJULU 03-APR-03 2880556 Get the past unbilled streams for the contract
      -- RMUNJULU 09-APR-03  Changed the query to get only BILLABLE streams
      -- RMUNJULU 14-APR-03 2904268 Added amount > 0
      CURSOR get_unbill_strms_csr ( p_khr_id IN NUMBER, p_eff_from_date IN DATE) IS
            SELECT SEL.id
            FROM   OKL_STREAMS_V STM,
                   OKL_STRM_ELEMENTS_V SEL,
                   OKC_K_HEADERS_V KHR,
                   OKL_STRM_TYPE_B STY
            WHERE  KHR.id = p_khr_id
            AND    KHR.id = STM.khr_id
            AND    STM.id = SEL.stm_id
            AND    STM.say_code = 'CURR'
            AND    STM.active_yn = 'Y'
            AND    SEL.date_billed IS NULL
            AND    STM.sty_id = STY.id
            AND    NVL(STY.billable_yn,'N') = 'Y'
            AND    TRUNC(SEL.stream_element_date) <= TRUNC(p_eff_from_date)
            AND    SEL.amount > 0
            AND    ROWNUM < 2;


      -- RMUNJULU 3078988
      -- Returns if Accrual for contract till accrue till date has NOT been run
      CURSOR check_accrual_csr(p_chr_id NUMBER, p_accrue_till_date DATE) IS
      SELECT 'Y'
      FROM OKC_K_HEADERS_B CHR
      WHERE id = p_chr_id
      AND EXISTS (
             SELECT 1
             FROM        OKL_STRM_TYPE_B       sty,
                         OKL_STREAMS           stm,
                         OKL_STRM_ELEMENTS     ste,
                         OKL_PROD_STRM_TYPES_V psty,
                         OKL_K_HEADERS         khr
             WHERE stm.khr_id = chr.id
             AND khr.id = stm.khr_id
             AND stm.say_code = 'CURR'
             AND stm.active_yn = 'Y'
             AND stm.sty_id = sty.id
             AND sty.id = psty.sty_id
             AND psty.pdt_id = khr.pdt_id
             AND psty.accrual_yn = 'Y'
             AND stm.id = ste.stm_id
             AND ste.stream_element_date <= p_accrue_till_date
             AND ste.amount <> 0
             AND ste.accrued_yn IS NULL);

      -- rmunjulu EDAT
      -- check transactions for contract exist after p_date (which will be quote creation date)
      -- used for post dated terminations
      CURSOR chk_contract_trn_csr ( p_khr_id IN NUMBER, p_date IN DATE) IS
         SELECT trn.id id,
		        fnd.meaning,
                fnd.description,
                TRUNC(trn.creation_date) transaction_date
         FROM   OKL_TRX_CONTRACTS trn,
                FND_LOOKUPS fnd
         WHERE  trn.khr_id = p_khr_id
         --rkuttiya added for 12.1.1 Multi GAAP
         AND    trn.representation_type = 'PRIMARY'
         --
         AND    trunc(trn.creation_date) >= trunc(p_date)
         AND    fnd.lookup_type = 'OKL_TCN_TYPE'
         AND    fnd.lookup_code = trn.tcn_type
         AND    trn.tcn_type IN ('TMT',  -- Termination
                                 'ALT',  -- Asset Termination
				  'EVG' , -- Evergreen --akrangan bug 5354501 fix added 'EVG'
		                         'RVC',  -- Reverse
		                         'SPLC', -- Split contract
								 'TAA',  -- Transfer and Assumption
								 'TRBK', -- Rebook
								 'PPD'   -- Principal Paydown
								 )
         AND    trn.tmt_status_code NOT IN ('CANCELED'); -- status --akrangan changed for sla tmt_status_code cr

      -- rmunjulu 4556370
      -- check transactions for contract exist after p_date (which will be quote creation date)
      -- used for post dated terminations
      -- Check for only non canceled and non processed transactions
      CURSOR chk_contract_trn_csr1 ( p_khr_id IN NUMBER, p_date IN DATE) IS
         SELECT trn.id id,
		        fnd.meaning,
                fnd.description,
                TRUNC(trn.creation_date) transaction_date
         FROM   OKL_TRX_CONTRACTS trn,
                FND_LOOKUPS fnd
         WHERE  trn.khr_id = p_khr_id
         --rkuttiya added for 12.1.1 Multi GAAP
         AND    trn.representation_type = 'PRIMARY'
         --
         AND    trunc(trn.creation_date) >= trunc(p_date)
         AND    fnd.lookup_type = 'OKL_TCN_TYPE'
         AND    fnd.lookup_code = trn.tcn_type
         AND    trn.tcn_type IN ('TMT',  -- Termination
                                 'ALT',  -- Asset Termination
				 'EVG' , -- Evergreen --akrangan bug 5354501 fix added 'EVG'
		                         'RVC',  -- Reverse
		                         'SPLC', -- Split contract
								 'TAA',  -- Transfer and Assumption
								 'TRBK', -- Rebook
								 'PPD'   -- Principal Paydown
								 )
         AND    trn.tmt_status_code NOT IN ('CANCELED','PROCESSED'); -- status --akrangan changed for sla tmt_status_code cr

      -- rmunjulu EDAT
      -- check split asset transactions for contract exist after p_date (which will be quote creation date)
      -- used for post dated terminations
      CURSOR chk_split_trn_csr	(p_khr_id IN NUMBER, p_date IN DATE) IS
         SELECT tas.id,
	            fnd.meaning,
                fnd.description,
                TRUNC(tas.creation_date) transaction_date
	     FROM   OKL_TRX_ASSETS tas,
		        OKL_TXL_ASSETS_V tal,
                FND_LOOKUPS fnd
		 WHERE  tas.id = tal.tas_id
		 AND    tal.dnz_khr_id = p_khr_id
		 AND    trunc(tas.creation_date) >= trunc(p_date)
         AND    fnd.lookup_type = 'OKL_TRANS_HEADER_TYPE'
         AND    fnd.lookup_code = tas.tas_type
		 AND    tas.tas_type IN ('ALI') -- Split Asset Transaction
		 AND    tas.tsu_code NOT IN ('CANCELED'); -- status

      -- rmunjulu 4556370
      -- check split asset transactions for contract exist after p_date (which will be quote creation date)
      -- used for post dated terminations]
	  -- check for non canceled and non processed transactions
      CURSOR chk_split_trn_csr1	(p_khr_id IN NUMBER, p_date IN DATE) IS
         SELECT tas.id,
	            fnd.meaning,
                fnd.description,
                TRUNC(tas.creation_date) transaction_date
	     FROM   OKL_TRX_ASSETS tas,
		        OKL_TXL_ASSETS_V tal,
                FND_LOOKUPS fnd
		 WHERE  tas.id = tal.tas_id
		 AND    tal.dnz_khr_id = p_khr_id
		 AND    trunc(tas.creation_date) >= trunc(p_date)
         AND    fnd.lookup_type = 'OKL_TRANS_HEADER_TYPE'
         AND    fnd.lookup_code = tas.tas_type
		 AND    tas.tas_type IN ('ALI') -- Split Asset Transaction
		 AND    tas.tsu_code NOT IN ('CANCELED','PROCESSED'); -- status

	-- rmunjulu bug 4556370 added to check the setup
    CURSOR l_sys_prms_csr IS
      SELECT NVL(upper(CANCEL_QUOTES_YN), 'N') CANCEL_QUOTES
      FROM   OKL_SYSTEM_PARAMS;

    l_keep_existing_quotes_yn VARCHAR2(3);

    lp_term_rec                      term_rec_type := p_term_rec;
    lx_term_rec                      term_rec_type;
    l_trmn_rec                       OKL_AM_LEASE_LOAN_TRMNT_PUB.term_rec_type;
    l_tcnv_rec                       OKL_AM_LEASE_LOAN_TRMNT_PUB.tcnv_rec_type;
    l_err_msg                        VARCHAR2(2000);
    l_return_status                  VARCHAR2(200);
    l_quote_number                   NUMBER;
    lx_quot_rec                      OKL_AM_CREATE_QUOTE_PVT.quot_rec_type;
    l_quote_eff_to_dt                DATE;
    db_accepted_yn                   VARCHAR2(200);
    db_date_effective_from           DATE;
    db_date_effective_to             DATE;
    db_contract_id                   NUMBER;
    db_sysdate                       DATE;
    db_quote_number                  NUMBER;
    db_contract_number               VARCHAR2(2000);
    db_qte_id                        NUMBER;
    db_qtp_code                      VARCHAR2(200);
    l_quote_eff_days                 NUMBER;
    l_quote_eff_max_days             NUMBER;
    l_trn_exists                     VARCHAR2(1) := '?';
    l_api_name              CONSTANT VARCHAR2(30) := 'terminate_quote';
    l_api_version           CONSTANT NUMBER := 1;
    l_qtp_code                       VARCHAR2(30);
    l_quote_type                     VARCHAR2(200);
    l_contract_id                    NUMBER;
    l_contract_number                VARCHAR2(200);
    lx_contract_status               VARCHAR2(200);
    l_event_name                     VARCHAR2(2000);
    l_date_eff_from                  DATE;
    l_q_eff_quot_rec                 OKL_AM_CREATE_QUOTE_PVT.quot_rec_type;


    -- RMUNJULU -- 12-DEC-02 Bug # 2484327 Changes for Asset level termination
    -- Added these variables
    db_qst_code  VARCHAR2(200);
    l_qst_code_1 VARCHAR2(200);
    l_qst_code_2 VARCHAR2(200);
    lx_trn_tbl   OKL_AM_UTIL_PVT.trn_tbl_type;
    lx_quote_tbl OKL_AM_UTIL_PVT.quote_tbl_type;
    lx_asset_serialized_yn VARCHAR2(3);
    lx_clev_tbl  clev_tbl_type;
    l_ib_lines_count NUMBER;


    -- RMUNJULU 30-DEC-02 2699412 Added variables
    lp_canceled_qtev_rec term_rec_type;
    lx_canceled_qtev_rec term_rec_type;
    i NUMBER;
    db_currency_conversion_date DATE;
    db_functional_currency_code VARCHAR2(15);
    db_contract_currency_code VARCHAR2(15);
    l_currency_conversion_type VARCHAR2(30);
    l_currency_conversion_rate NUMBER;
    l_currency_conversion_date DATE;
    l_converted_amount NUMBER;

    -- Since we do not use the amount or converted amount in TRX_Quotes table
    -- set a hardcoded value for the amount (and pass to to
    -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
    -- conversion values )
    l_hard_coded_amount NUMBER := 100;

    -- RMUNJULU 03-APR-03 2880556
    l_unbill_strms_yn VARCHAR2(1) := 'N';
    l_id NUMBER;

    -- RMUNJULU 3078988
    l_accrual_not_done VARCHAR2(3);

    -- RMUNJULU 3061751 Added variables for SERVICE_K_INTEGRATION
    db_partial_yn VARCHAR2(3);
    l_true_partial_quote VARCHAR2(1) := 'N';
    l_service_contract VARCHAR2(300);
    l_oks_chr_id NUMBER;
    l_msg_count NUMBER := OKL_API.G_MISS_NUM;
    l_msg_data VARCHAR2(2000);
    l_billing_done VARCHAR2(1);

    -- RMUNJULU 3061751 Added for SERVICE_K_INTEGRATION
    -- Get Service K details
    CURSOR get_service_k_dtls_csr(p_service_id IN NUMBER) IS
    SELECT CHR.contract_number
    FROM   OKC_K_HEADERS_B CHR
    WHERE  CHR.id = p_service_id;

    -- rmunjulu EDAT
    l_claims_exists VARCHAR2(3);
    db_creation_date DATE;

    -- rmunjulu LOANS_ENHANCEMENT
    l_deal_type VARCHAR2(300);
    l_rev_rec_method VARCHAR2(300);
	l_int_cal_basis VARCHAR2(300);
	l_tax_owner VARCHAR2(300);
    l_int_calc_done VARCHAR2(3);
    db_perdiem_amount NUMBER;
    l_accrual_done    VARCHAR2(3);

    --rmunjulu 4769094
    CURSOR check_accrual_previous_csr IS
    SELECT NVL(CHK_ACCRUAL_PREVIOUS_MNTH_YN,'N')
    FROM OKL_SYSTEM_PARAMS;

    --rmunjulu 4769094
    l_accrual_previous_mnth_yn VARCHAR2(3);
    l_previous_mnth_last_date DATE;
   /* Bug 6674730 start */
    db_repo_yn VARCHAR2(1);

   CURSOR c_asset_return_csr(p_line_id IN NUMBER) IS
   SELECT ARS_CODE
   FROM OKL_ASSET_RETURNS_B
   WHERE kle_id = p_line_id
   AND ARS_CODE = 'REPOSSESSED';

   l_ars_code VARCHAR2(300);

   /* Bug 6674730 end */
   l_module_name VARCHAR2(500) := G_MODULE_NAME || 'terminate_quote';
   is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
   is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
   is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

   -- RMUNJULU bug 6736148
   l_final_accrual_date DATE;
   l_accrual_rec OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type;

   -- rmunjulu 6795295 get contract details
   CURSOR k_details_csr (l_khr_id IN NUMBER) IS
   SELECT sts_code,
          org_id
   FROM   Okc_K_Headers_b
   WHERE  id = l_khr_id;

   -- rmunjulu 6795295 get concurrent details
   CURSOR conc_details_csr (l_org_id IN NUMBER) IS
     SELECT P.user_concurrent_program_name,
            R.request_id request_id
     FROM   Fnd_Concurrent_Requests R,
            Fnd_Concurrent_Programs_VL P
      WHERE R.Concurrent_Program_Id = P.Concurrent_program_ID
        AND R.Program_Application_ID= P.Application_ID
        AND P.concurrent_program_name IN ( -- Following Concurrent Programs
                    'OKLAGNCALC' --Generate Accruals Master - Streams
                   ,'OKLAGNCALCW' -- Generate Accruals
                   ,'OKL_STREAM_BILLING' -- Process Billable Streams
                   ,'OKL_STREAM_BILLING_MASTER' -- Master Program -- Process Billable Streams
                    )
        AND R.org_id = l_org_id -- check if billing or accruals running for the same org
        AND R.phase_code = 'R'; -- Concurrent Program with Phase = 'Running'

   l_sts_code VARCHAR2(300);
   l_org_id NUMBER;
   l_conc_req_found VARCHAR2(3);
   conc_details_rec conc_details_csr%ROWTYPE;
   l_phase_meaning VARCHAR2(300);
   l_status_meaning VARCHAR2(300);
   l_dev_phase VARCHAR2(300);
   l_dev_status VARCHAR2(300);
   l_fnd_message VARCHAR2(300);
   l_success BOOLEAN;
   l_stream_bill_done_yn VARCHAR2(3);
  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_acceptance_source: ' || p_acceptance_source);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.id: ' || p_term_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.qrs_code: ' || p_term_rec.qrs_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.qst_code: ' || p_term_rec.qst_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.qtp_code: ' || p_term_rec.qtp_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.trn_code: ' || p_term_rec.trn_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.pop_code_end: ' || p_term_rec.pop_code_end);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.pop_code_early: ' || p_term_rec.pop_code_early);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.consolidated_qte_id: ' || p_term_rec.consolidated_qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.khr_id: ' || p_term_rec.khr_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.art_id: ' || p_term_rec.art_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.pdt_id: ' || p_term_rec.pdt_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.early_termination_yn: ' || p_term_rec.early_termination_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.partial_yn: ' || p_term_rec.partial_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.preproceeds_yn: ' || p_term_rec.preproceeds_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_requested: ' || p_term_rec.date_requested);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_proposal: ' || p_term_rec.date_proposal);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_effective_to: ' || p_term_rec.date_effective_to);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_accepted: ' || p_term_rec.date_accepted);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.summary_format_yn: ' || p_term_rec.summary_format_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.consolidated_yn: ' || p_term_rec.consolidated_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.principal_paydown_amount: ' || p_term_rec.principal_paydown_amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.residual_amount: ' || p_term_rec.residual_amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.yield: ' || p_term_rec.yield);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.rent_amount: ' || p_term_rec.rent_amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_restructure_end: ' || p_term_rec.date_restructure_end);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_restructure_start: ' || p_term_rec.date_restructure_start);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.term: ' || p_term_rec.term);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.purchase_percent: ' || p_term_rec.purchase_percent);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_due: ' || p_term_rec.date_due);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.payment_frequency: ' || p_term_rec.payment_frequency);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.remaining_payments: ' || p_term_rec.remaining_payments);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_effective_from: ' || p_term_rec.date_effective_from);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.quote_number: ' || p_term_rec.quote_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.approved_yn: ' || p_term_rec.approved_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.accepted_yn: ' || p_term_rec.accepted_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.payment_received_yn: ' || p_term_rec.payment_received_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_payment_received: ' || p_term_rec.date_payment_received);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_approved: ' || p_term_rec.date_approved);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.approved_by: ' || p_term_rec.approved_by);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.org_id: ' || p_term_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.purchase_amount: ' || p_term_rec.purchase_amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.purchase_formula: ' || p_term_rec.purchase_formula);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.asset_value: ' || p_term_rec.asset_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.residual_value: ' || p_term_rec.residual_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.unbilled_receivables: ' || p_term_rec.unbilled_receivables);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.gain_loss: ' || p_term_rec.gain_loss);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.PERDIEM_AMOUNT: ' || p_term_rec.PERDIEM_AMOUNT);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_code: ' || p_term_rec.currency_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_code: ' || p_term_rec.currency_conversion_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_type: ' || p_term_rec.currency_conversion_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_rate: ' || p_term_rec.currency_conversion_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_date: ' || p_term_rec.currency_conversion_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.legal_entity_id: ' || p_term_rec.legal_entity_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.repo_quote_indicator_yn: ' || p_term_rec.repo_quote_indicator_yn);
	 END IF;


    -- LOGIC START --

    -- Fetch Database values for Quote
    -- Validate Qte_id
    -- Validate Contract
    -- Validate Qtp_code
    -- Validate p_acceptance_source to be rollover if quote is rollover quote
    -- Validate Date_effective_to
    -- If trying to accept this quote for the first time then
      -- If quote not reached eff from date then error end if
      -- If quote expired then error end if
      -- If quote status not 'APPROVED' then error end if
      -- If unprocessed trn for contract exists then error end if
      -- If accepted qte with no trn exists for contract then error end if
      -- Get the assets for quote
      -- Loop thru assets
        -- If asset serialized, then count of okl_txd_quote_line_dtls
        -- for the TQL_ID should equal the quote quantity
        -- Get other quotes for asset
        -- Loop thru quotes
             -- If different quote id and not completed or canceled then
                -- Cancel
             -- End if
        -- End loop
      -- End loop
      -- If conversion_date different from sysdate then
           -- Set currency cols to be updated
      -- End if
      -- Securitization checks done
    -- Elseif trying to change accepted quote then error
    -- End if
    -- Update Trx Quote to accepted
    -- Launch the Pre/Post Proceeds WF

    -- LOGIC END --


    --Check API version, initialize message list and create savepoint.
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

    -- initialize return variables
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_err_msg       := OKL_API.G_RET_STS_SUCCESS;

    -----------------------
    -- GET/SET DB VALUES --
    -----------------------

    SELECT SYSDATE INTO db_sysdate FROM DUAL;

    -- Get tbe database values for the quote
    OPEN qte_db_vals_csr(lp_term_rec.id);
    FETCH qte_db_vals_csr INTO db_contract_id,
                               db_accepted_yn,
                               db_date_effective_from,
                               db_date_effective_to,
                               db_quote_number,
                               db_contract_number,
                               db_qte_id,
                               db_qtp_code,
                               db_qst_code, -- RMUNJULU Bug # 2484327 Added
                               db_currency_conversion_date, -- RMUNJULU 30-DEC-02 2699412 Added
                               --akrangan bug 6140771 codefix begin -- swapped the currency code variables ..
                               db_contract_currency_code, -- RMUNJULU 30-DEC-02 2699412 Added
			       db_functional_currency_code, -- RMUNJULU 30-DEC-02 2699412 Added
			       --akrangan bug 6140771 codefix end
                               db_partial_yn, -- RMUNJULU 3061751 Added
                               db_creation_date, -- rmunjulu EDAT Added
                               db_perdiem_amount, -- rmunjulu LOANS_ENHANCEMENT
                               db_repo_yn; -- Bug 6674730
    CLOSE qte_db_vals_csr;

    -- Check if quote id passed is valid
    IF db_qte_id IS NULL OR db_qte_id = OKL_API.G_MISS_NUM THEN

      OKL_API.set_message( p_app_name     => OKC_API.G_APP_NAME,
                           p_msg_name     => OKC_API.G_INVALID_VALUE,
                           p_token1       => OKC_API.G_COL_NAME_TOKEN,
                           p_token1_value => 'Quote id');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    -- if Khr_Id not passed get from DB
    IF lp_term_rec.khr_id IS NULL OR lp_term_rec.khr_id = OKL_API.G_MISS_NUM THEN
      l_contract_id := db_contract_id;
      l_contract_number := db_contract_number;
    ELSE
      l_contract_id := lp_term_rec.khr_id;
      OPEN  get_k_num_csr (l_contract_id);
      FETCH get_k_num_csr INTO l_contract_number;
      CLOSE get_k_num_csr;
    END IF;

    -- rmunjulu 6795295 Get contract details
    OPEN k_details_csr (l_contract_id);
    FETCH k_details_csr INTO l_sts_code, l_org_id;
    CLOSE k_details_csr;

    -----------------------
    -- KHR_ID VALIDATION --
    -----------------------

    -- Call the validate contract to check contract status only if quote not accepted
    IF db_accepted_yn <> G_YES THEN
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract');
      END IF;
      OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   OKL_API.G_FALSE,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_contract_id                 =>   l_contract_id,
           p_control_flag                =>   'TRMNT_QUOTE_UPDATE',
           x_contract_status             =>   lx_contract_status);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract , return status: ' || l_return_status);
      END IF;

      -- Raise exception if validate K fails
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -----------------------
    -- QTP_CODE VALIDATION --
    -----------------------

    -- IF qtp_code not null then check if valid
    IF  lp_term_rec.qtp_code IS NOT NULL
    AND lp_term_rec.qtp_code <> OKL_API.G_MISS_CHAR
    AND lp_term_rec.qtp_code NOT LIKE 'TER%' THEN

      -- Please select a valid Quote Type.
      OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                           p_msg_name      => 'OKL_AM_QTP_CODE_INVALID');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    -- if qtp_code is null then get from db and check
    ELSIF  (lp_term_rec.qtp_code IS NULL
    OR lp_term_rec.qtp_code = OKL_API.G_MISS_CHAR)
    AND db_qtp_code NOT LIKE 'TER%' THEN

      -- Please select a valid Quote Type.
      OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                           p_msg_name      => 'OKL_AM_QTP_CODE_INVALID');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    -- rmunjulu Rollover/Release -- moved the checks into the If below where it first
    -- checks if quote being accepted
    -- rmunjulu Rollover/Release -- Also modified to check for nvl

    -- In case of acceptance of rollover quote from activation of contract, it
    -- is not required to pass date_effective_to so populate date_effective_to
    -- with the one in database for that quote.
    --Bug# 3925453: pagarg +++ T and A +++++++
    -- Use existing code for Rollover quote to populate date_effective_to
    -- for Release quote also.
    IF  lp_term_rec.qtp_code IS NOT NULL
    AND lp_term_rec.qtp_code <> OKL_API.G_MISS_CHAR
    THEN
       IF (lp_term_rec.qtp_code LIKE 'TER_ROLL%'
           AND p_acceptance_source = 'ROLLOVER')
       OR
          (lp_term_rec.qtp_code = 'TER_RELEASE_WO_PURCHASE'
           AND p_acceptance_source = 'RELEASE_CONTRACT')
       THEN
          lp_term_rec.date_effective_to := db_date_effective_to;
       END IF;
    -- if qtp_code is null then get from db and check
    ELSIF  (lp_term_rec.qtp_code IS NULL
    OR lp_term_rec.qtp_code = OKL_API.G_MISS_CHAR)
    THEN
       IF (db_qtp_code LIKE 'TER_ROLL%'
           AND p_acceptance_source = 'ROLLOVER')
       OR
          (db_qtp_code = 'TER_RELEASE_WO_PURCHASE'
           AND p_acceptance_source = 'RELEASE_CONTRACT')
       THEN
          lp_term_rec.date_effective_to := db_date_effective_to;
       END IF;
    END IF;
    --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++

    -----------------------
    -- DATE_EFFECTIVE_TO VALIDATION --
    -----------------------

    -- Check if date_effective_to is NULL
    IF lp_term_rec.date_effective_to IS NULL
    OR lp_term_rec.date_effective_to = OKL_API.G_MISS_DATE THEN

      -- You must enter a value for PROMPT
      IF (NVL(db_repo_yn,'N') <> 'Y') THEN -- 6674730
        OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_EFFECTIVE_TO'));

        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    -- Get the date_eff_from from database if not passed
    IF  (lp_term_rec.date_effective_from IS NOT NULL)
    AND (lp_term_rec.date_effective_from <> OKL_API.G_MISS_DATE) THEN
      l_date_eff_from := lp_term_rec.date_effective_from;
    ELSE
      l_date_eff_from := db_date_effective_from;
    END IF;

    -- Check date_eff_to > date_eff_from
    IF  (l_date_eff_from IS NOT NULL)
    AND (l_date_eff_from <> OKL_API.G_MISS_DATE)
    AND (lp_term_rec.date_effective_to IS NOT NULL)
    AND (lp_term_rec.date_effective_to <> OKL_API.G_MISS_DATE) THEN

       IF (TRUNC(lp_term_rec.date_effective_to) <= TRUNC(l_date_eff_from)) THEN

         -- Message : Date Effective To DATE_EFFECTIVE_TO cannot be before
         -- Date Effective From DATE_EFFECTIVE_FROM.
         OKL_API.SET_MESSAGE(p_app_name    	 => 'OKL',
      			                 p_msg_name		   => 'OKL_AM_DATE_EFF_FROM_LESS_TO',
      			                 p_token1		     => 'DATE_EFFECTIVE_TO',
    		  	                 p_token1_value	 => lp_term_rec.date_effective_to,
    			                   p_token2		     => 'DATE_EFFECTIVE_FROM',
    			                   p_token2_value	 => l_date_eff_from);

         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;

    -- If date effective to changed then
    IF  (lp_term_rec.date_effective_to IS NOT NULL)
    AND (lp_term_rec.date_effective_to <> OKL_API.G_MISS_DATE)
    AND (lp_term_rec.date_effective_to <> db_date_effective_to) THEN

      -- set the date eff to from rules
      l_q_eff_quot_rec.khr_id := l_contract_id;
      l_q_eff_quot_rec.qtp_code := lp_term_rec.qtp_code;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_CREATE_QUOTE_PVT.quote_effectivity');
      END IF;
      OKL_AM_CREATE_QUOTE_PVT.quote_effectivity(
           p_quot_rec             => l_q_eff_quot_rec,
           x_quote_eff_days       => l_quote_eff_days,
           x_quote_eff_max_days   => l_quote_eff_max_days,
           x_return_status        => l_return_status);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_CREATE_QUOTE_PVT.quote_effectivity , return status: ' || l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_quote_eff_days: ' || l_quote_eff_days);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_quote_eff_max_days: ' || l_quote_eff_max_days);
      END IF;

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --rmunjulu EDAT removed and replaced with below logic
--            l_quote_eff_to_dt := db_date_effective_from + l_quote_eff_max_days;

      -- rmunjulu EDAT logic for date_effective_to varies for pre and post
      IF trunc(db_sysdate) > trunc(l_date_eff_from) THEN -- pre dated
         -- PRE DATED QUOTE: effective_to = date_created + quote_eff_days
         l_quote_eff_to_dt   :=  db_creation_date + l_quote_eff_max_days;
      ELSIF trunc(db_sysdate) < trunc(l_date_eff_from) THEN -- post dated
         -- POST DATED QUOTE: effective_to = eff_from + quote_eff_days
         l_quote_eff_to_dt   :=  l_date_eff_from + l_quote_eff_max_days;
      ELSE -- current
         -- CURRENT DATED QUOTE: effective_to = eff_from + quote_eff_days
         l_quote_eff_to_dt   :=  l_date_eff_from + l_quote_eff_max_days;
      END IF;


      -- if max quote eff to date is less than sysdate then error
      IF TRUNC(l_quote_eff_to_dt) < TRUNC(db_sysdate) THEN
         --Message : Quote QUOTE_NUMBER is already expired.
         OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                              p_msg_name      => 'OKL_AM_QUOTE_ALREADY_EXP',
                              p_token1        => 'QUOTE_NUMBER',
                              p_token1_value  => db_quote_number);

         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- if date is less than sysdate then error
      IF TRUNC(lp_term_rec.date_effective_to) < TRUNC(db_sysdate) THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        -- Please enter an Effective To date that occurs
        -- after the current system date.
        OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                             p_msg_name      => 'OKL_AM_DATE_EFF_TO_PAST');

        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- if eff_to date > l_quote_eff_to_dt then err msg
      IF  TRUNC(lp_term_rec.date_effective_to) > TRUNC(l_quote_eff_to_dt) THEN
        -- Please enter Effective To date before DATE_EFF_TO_MAX.
        OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                             p_msg_name      => 'OKL_AM_DATE_EFF_TO_ERR',
                             p_token1        => 'DATE_EFF_TO_MAX',
                             p_token1_value  => l_quote_eff_to_dt);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    -- rmunjulu LOANS_ENHANCEMENT perdiem amount validation
    IF lp_term_rec.perdiem_amount IS NOT NULL
    AND lp_term_rec.perdiem_amount <> OKL_API.G_MISS_NUM THEN

       IF lp_term_rec.perdiem_amount <> nvl(db_perdiem_amount,OKL_API.G_MISS_NUM)
       AND db_qst_code NOT IN ('DRAFTED','REJECTED') THEN

        -- Perdiem amount is allowed to be updated for quotes in DRAFTED or REJECTED status.
        OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                             p_msg_name      => 'OKL_AM_PERDIEM_UPD_ERR');
        RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;

    -----------------------
    -- ACCEPTED_YN VALIDATION --
    -----------------------

    -- RMUNJULU -- 12-DEC-02 Bug # 2484327 -- START --

    -- Added code to check for accepted
    -- quote based on asset level termination changes

    -- If trying to accept this quote for the first time
    IF  lp_term_rec.accepted_yn IS NOT NULL
    AND lp_term_rec.accepted_yn <> OKL_API.G_MISS_CHAR
    AND lp_term_rec.accepted_yn = G_YES
    AND db_accepted_yn = G_NO THEN

        -- RMUNJULU 06-JAN-03 2736865 Added code to check date eff from -- START

        -- *****************
        -- If quote not reached Effective From Date then error
        -- *****************

         -- if quote eff from date is greater than sysdate then error
         IF TRUNC(l_date_eff_from) > TRUNC(db_sysdate) THEN

            -- Quote QUOTE_NUMBER can only be accepted during the quote effective dates.
            OKL_API.set_message( p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_DATE_EFF_FROM_ACC',
                                 p_token1        => 'QUOTE_NUMBER',
                                 p_token1_value  => db_quote_number);

            RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;

        -- RMUNJULU 06-JAN-03 2736865  -- END



        -- *****************
        -- If quote EXPIRED then error
        -- *****************


        -- If date_eff_to is not passed
        IF ((lp_term_rec.date_effective_to IS NULL) OR
           (lp_term_rec.date_effective_to = OKL_API.G_MISS_DATE))
		AND (NVL(db_repo_yn,'N') <> 'Y') THEN -- 6674730 -- No quote expiration if Repo Quote

          --if quote expired
          IF TRUNC(db_sysdate) > TRUNC(db_date_effective_to)  THEN

            --Message : Quote QUOTE_NUMBER is already expired.
            OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                                 p_msg_name      => 'OKL_AM_QUOTE_ALREADY_EXP',
                                 p_token1        => 'QUOTE_NUMBER',
                                 p_token1_value  => db_quote_number);

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

        ELSE -- rmunjulu Bug 4201215 Eff_To date passed but already expired

          --if quote expired
          IF TRUNC(db_sysdate) > TRUNC(lp_term_rec.date_effective_to) THEN

            --Message : Quote QUOTE_NUMBER is already expired.
            OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                                 p_msg_name      => 'OKL_AM_QUOTE_ALREADY_EXP',
                                 p_token1        => 'QUOTE_NUMBER',
                                 p_token1_value  => db_quote_number);

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

        END IF;


        -- *****************
        -- If quote status not APPROVED then error
        -- *****************

        -- Get APPROVED meaning
        l_qst_code_1 := OKL_AM_UTIL_PVT.get_lookup_meaning(
                                      'OKL_QUOTE_STATUS',
                                      'APPROVED',
                                      'Y');

        -- Get ACCEPTED meaning
        l_qst_code_2 := OKL_AM_UTIL_PVT.get_lookup_meaning(
                                      'OKL_QUOTE_STATUS',
                                      'ACCEPTED',
                                      'Y');

        -- Check qst_code
        IF  lp_term_rec.qst_code IS NOT NULL
        AND lp_term_rec.qst_code  <> OKL_API.G_MISS_CHAR THEN


           IF lp_term_rec.qst_code <> 'APPROVED' THEN


              -- Quote QUOTE_NUMBER should be QST_CODE_APPROVED before
              -- it is QST_CODE_ACCEPTED.
              OKL_API.set_message (
              			 p_app_name  	  => 'OKL',
              			 p_msg_name  	  => 'OKL_AM_QTE_APPROVE_ERR',
                     p_token1       => 'QUOTE_NUMBER',
                     p_token1_value => db_quote_number,
                     p_token2       => 'QST_CODE_APPROVED',
                     p_token2_value => l_qst_code_1,
                     p_token3       => 'QST_CODE_ACCEPTED',
                     p_token3_value => l_qst_code_2);

              RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;


        ELSE -- qst_code not passed so check db value


           IF db_qst_code <> 'APPROVED' THEN

              -- Quote QUOTE_NUMBER should be QST_CODE_APPROVED before
              -- it is QST_CODE_ACCEPTED.
              OKL_API.set_message (
              			 p_app_name  	  => 'OKL',
              			 p_msg_name  	  => 'OKL_AM_QTE_APPROVE_ERR',
                     p_token1       => 'QUOTE_NUMBER',
                     p_token1_value => db_quote_number,
                     p_token2       => 'QST_CODE_APPROVED',
                     p_token2_value => l_qst_code_1,
                     p_token3       => 'QST_CODE_ACCEPTED',
                     p_token3_value => l_qst_code_2);

              RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;

        END IF;

    --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
    -----------------------
    -- P_ACCEPTANCE_SOURCE VALIDATION --
    -----------------------
    -- If acceptance source is rollover and quote type is not rollover then
    -- raise invalid value error.
    IF nvl(p_acceptance_source,'*') = 'ROLLOVER' -- rmunjulu Rollover/Release Use nvl
    THEN
       IF  lp_term_rec.qtp_code IS NOT NULL
       AND lp_term_rec.qtp_code <> OKL_API.G_MISS_CHAR
       THEN
          IF lp_term_rec.qtp_code NOT LIKE 'TER_ROLL%'
          THEN
             OKL_API.set_message(p_app_name      => G_APP_NAME,
                                 p_msg_name      => G_INVALID_VALUE,
                                 p_token1        => G_COL_NAME_TOKEN,
                                 p_token1_value  => 'Acceptance Source');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       ELSIF (lp_term_rec.qtp_code IS NULL
       OR lp_term_rec.qtp_code = OKL_API.G_MISS_CHAR)
       THEN
          IF db_qtp_code NOT LIKE 'TER_ROLL%'
          THEN
             OKL_API.set_message(p_app_name      => G_APP_NAME,
                                 p_msg_name      => G_INVALID_VALUE,
                                 p_token1        => G_COL_NAME_TOKEN,
                                 p_token1_value  => 'Acceptance Source');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END IF;
    END IF;

    -- If quote is rollover quote and acceptance_source is not ROLLOVER then
    -- throw error message as rollover quote can be accepted only from rolled
    -- over contract.
    IF  lp_term_rec.qtp_code IS NOT NULL
    AND lp_term_rec.qtp_code <> OKL_API.G_MISS_CHAR
    THEN
       IF lp_term_rec.qtp_code LIKE 'TER_ROLL%'
       AND nvl(p_acceptance_source,'*') <> 'ROLLOVER' -- rmunjulu Rollover/Release Use nvl
       THEN
          -- Rollover quote can be accepted only from rolled over contract
          OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                               p_msg_name      => 'OKL_NO_ACPT_ROLL_QTE');
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    -- if qtp_code is null then get from db and check
    ELSIF (lp_term_rec.qtp_code IS NULL
    OR lp_term_rec.qtp_code = OKL_API.G_MISS_CHAR)
    THEN
       IF db_qtp_code LIKE 'TER_ROLL%'
       AND nvl(p_acceptance_source,'*') <> 'ROLLOVER' -- rmunjulu Rollover/Release Use nvl
       THEN
          -- Rollover quote can be accepted only from rolled over contract
          OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                               p_msg_name      => 'OKL_NO_ACPT_ROLL_QTE');
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;

    --Bug# 3925453: pagarg +++ T and A +++++++ Start ++++++++++
    -- If acceptance source is RELEASE_CONTRACT and quote type is not release quote then
    -- raise invalid value error.
    IF nvl(p_acceptance_source,'*') = 'RELEASE_CONTRACT' -- rmunjulu Rollover/Release Use nvl
    THEN
       IF  lp_term_rec.qtp_code IS NOT NULL
       AND lp_term_rec.qtp_code <> OKL_API.G_MISS_CHAR
       THEN
          IF lp_term_rec.qtp_code <> 'TER_RELEASE_WO_PURCHASE'
          THEN
             OKL_API.set_message(p_app_name      => G_APP_NAME,
                                 p_msg_name      => G_INVALID_VALUE,
                                 p_token1        => G_COL_NAME_TOKEN,
                                 p_token1_value  => 'Acceptance Source');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       ELSIF (lp_term_rec.qtp_code IS NULL
       OR lp_term_rec.qtp_code = OKL_API.G_MISS_CHAR)
       THEN
          IF db_qtp_code <> 'TER_RELEASE_WO_PURCHASE'
          THEN
             OKL_API.set_message(p_app_name      => G_APP_NAME,
                                 p_msg_name      => G_INVALID_VALUE,
                                 p_token1        => G_COL_NAME_TOKEN,
                                 p_token1_value  => 'Acceptance Source');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END IF;
    END IF;

    -- If quote is release quote and acceptance_source is not RELEASE_CONTRACT then
    -- throw error message as release quote can be accepted only from released
    -- contract.
    IF  lp_term_rec.qtp_code IS NOT NULL
    AND lp_term_rec.qtp_code <> OKL_API.G_MISS_CHAR
    THEN
       IF lp_term_rec.qtp_code = 'TER_RELEASE_WO_PURCHASE'
       AND nvl(p_acceptance_source,'*') <> 'RELEASE_CONTRACT' -- rmunjulu Rollover/Release Use nvl
       THEN
          -- Rollover quote can be accepted only from rolled over contract
          OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                               p_msg_name      => 'OKL_AM_NO_ACPT_RELEASE_QTE');
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    -- if qtp_code is null then get from db and check
    ELSIF (lp_term_rec.qtp_code IS NULL
    OR lp_term_rec.qtp_code = OKL_API.G_MISS_CHAR)
    THEN
       IF db_qtp_code = 'TER_RELEASE_WO_PURCHASE'
       AND nvl(p_acceptance_source,'*') <> 'RELEASE_CONTRACT' -- rmunjulu Rollover/Release Use nvl
       THEN
          -- Rollover quote can be accepted only from rolled over contract
          OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                               p_msg_name      => 'OKL_AM_NO_ACPT_RELEASE_QTE');
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;
    --Bug# 3925453: pagarg +++ T and A +++++++ End ++++++++++


        -- *****************
        -- IF unprocessed termination trn exists for the contract then error
        -- *****************

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_contract_transactions');
        END IF;
        -- Get all the unprocessed transactions for the contract
        OKL_AM_UTIL_PVT.get_contract_transactions (
             p_khr_id        => l_contract_id,
             x_trn_tbl       => lx_trn_tbl,
             x_return_status => l_return_status);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.get_contract_transactions , return status: ' || l_return_status);
        END IF;

        -- Check the return status
        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

            -- Error occured in util proc, message set by util proc raise exp
            RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;

        -- Check if termination transaction exists for the asset
        IF lx_trn_tbl.COUNT > 0 THEN

           -- A termination transaction for the contract CONTRACT_NUMBER
           -- is already in progress.
           OKL_API.set_message (
         			       p_app_name  	  => 'OKL',
              			 p_msg_name  	  => 'OKL_AM_K_PENDING_TRN_ERROR',
                     p_token1       => 'CONTRACT_NUMBER',
                     p_token1_value => db_contract_number);

            RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;


        -- *****************
        -- IF accepted quote with no trn exists for contract then error
        -- *****************

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_non_trn_contract_quotes');
        END IF;
        -- Get accepted quote for contract with no trn
        OKL_AM_UTIL_PVT.get_non_trn_contract_quotes (
           p_khr_id        => l_contract_id,
           x_quote_tbl     => lx_quote_tbl,
           x_return_status => l_return_status);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.get_non_trn_contract_quotes , return status: ' || l_return_status);
        END IF;

        -- Check the return status
        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

            -- Error occured in util proc, message set by util proc raise exp
            RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;

        -- Check if accepted quote exists for the contract
        IF lx_quote_tbl.COUNT > 0 THEN

            l_quote_type := OKL_AM_UTIL_PVT.get_lookup_meaning(
                                      'OKL_QUOTE_TYPE',
                                      lx_quote_tbl(lx_quote_tbl.FIRST).qtp_code,
                                      'Y');

            -- Accepted quote QUOTE_NUMBER of quote type QUOTE_TYPE exists for
            -- contract CONTRACT_NUMBER. Cannot accept multiple quotes for the
            -- same contract.
            OKL_API.set_message (
         			 p_app_name  	  => 'OKL',
         			 p_msg_name  	  => 'OKL_AM_QTE_ACC_EXISTS_ERR',
               p_token1       => 'QUOTE_NUMBER',
               p_token1_value => lx_quote_tbl(lx_quote_tbl.FIRST).quote_number,
               p_token2       => 'QUOTE_TYPE',
               p_token2_value => l_quote_type,
               p_token3       => 'CONTRACT_NUMBER',
               p_token3_value => db_contract_number);

            RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;


        -- rmunjulu EDAT Added code to check for insurance claims if exist for a pre-dated quote
        IF trunc(l_date_eff_from) < trunc(db_creation_date) THEN

           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_INSURANCE_POLICIES_PUB.check_claims');
           END IF;
           -- check that no claims exist
           OKL_INSURANCE_POLICIES_PUB.check_claims(
                    p_api_version      => p_api_version,
                    p_init_msg_list    => p_init_msg_list,
                    x_return_status    => l_return_status,
                    x_msg_count        => x_msg_count,
                    x_msg_data         => x_msg_data,
                    p_khr_id           => l_contract_id,
                    x_clm_exist        => l_claims_exists,
                    p_trx_date         => l_date_eff_from);
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_INSURANCE_POLICIES_PUB.check_claims , return status: ' || l_return_status);
           END IF;

           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

              -- Error checking claims for contract CONTRACT_NUMBER.
              OKL_API.set_message (
            			 p_app_name     => 'OKL',
           	    		 p_msg_name     => 'OKL_AM_ERR_CHECK_CLAIMS',
                         p_token1       => 'CONTRACT_NUMBER',
                         p_token1_value => db_contract_number);

              RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;

           -- If claims exist do not accept quote
           IF nvl(l_claims_exists, 'N') = 'Y' THEN

              -- Claims exist for the contract CONTRACT_NUMBER.
              OKL_API.set_message (
            			 p_app_name     => 'OKL',
           	    		 p_msg_name     => 'OKL_AM_INS_CLAIMS_EXIST',
                         p_token1       => 'CONTRACT_NUMBER',
                         p_token1_value => db_contract_number);

              RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;


        END IF;

        -- rmunjulu EDAT Added code to check for transactions if post-dated quote
        IF trunc(l_date_eff_from) > trunc(db_creation_date) THEN
        -- rmunjulu 4143251 Removed the above condition, NOW check for transactions in all cases PRIOR, CURRENT and POST DATED
        -- rmunjulu EDAT Added back the above condition, NOW check for transactions only for POST dated quotes

		    -- RMUNJULU 4556370 initialize variable
		   l_keep_existing_quotes_yn := 'N';

           -- RMUNJULU 4556370 Check system option
           OPEN l_sys_prms_csr;
           FETCH l_sys_prms_csr INTO l_keep_existing_quotes_yn;
           IF l_sys_prms_csr%NOTFOUND THEN
              l_keep_existing_quotes_yn := 'N';
           END IF;
           CLOSE l_sys_prms_csr;

           -- RMUNJULU 4556370 added condition to check for non cancelled trns only when cancel quotes setup
           -- rmunjulu 4556370 logic is now reversed if retain existing termination quotes is NO then do earlier processing
           IF nvl(l_keep_existing_quotes_yn,'N') = 'N' THEN

		   -- check for transactions for rebook, reverse, split contract, transfer and assumption
		   -- which exists after the quote creation date and which are not canceled
		   FOR chk_contract_trn_rec IN chk_contract_trn_csr (l_contract_id, db_creation_date) LOOP

		      -- if trn exist raise error
		      IF  chk_contract_trn_rec.id IS NOT NULL THEN

                 -- Transaction exists for contract CONTRACT_NUMBER which was processed
			     -- after this quote was created. This quote is now invalid.
                 OKL_API.set_message (
            			 p_app_name     => 'OKL',
           	    		 p_msg_name     => 'OKL_AM_TRN_EXISTS_ERR',
                         p_token1       => 'CONTRACT_NUMBER',
                         p_token1_value => db_contract_number);

                 RAISE OKL_API.G_EXCEPTION_ERROR;

		      END IF;
		   END LOOP;

           -- check for split asset transaction
           FOR chk_split_trn_rec IN chk_split_trn_csr (l_contract_id, db_creation_date) LOOP

      	      -- if split asset transaction exists then raise error
			  IF chk_split_trn_rec.id IS NOT NULL THEN

                 -- Transaction exists for contract CONTRACT_NUMBER which was processed
                 -- after this quote was created. This quote is now invalid.
                 OKL_API.set_message (
            			       p_app_name     => 'OKL',
           	    		       p_msg_name     => 'OKL_AM_TRN_EXISTS_ERR',
                               p_token1       => 'CONTRACT_NUMBER',
                               p_token1_value => db_contract_number);

                 RAISE OKL_API.G_EXCEPTION_ERROR;

              END IF;
            END LOOP;

		   ELSE -- go by new checks -- where you check for noncanceled and non processed transactions in some cases

		   -- check for transactions for rebook, reverse, split contract, transfer and assumption
		   -- which exists after the quote creation date and which are not canceled
		   -- and rebook and partial terminations which are not canceled nor processed
		   FOR chk_contract_trn_rec1 IN chk_contract_trn_csr1 (l_contract_id, db_creation_date) LOOP

		      -- if trn exist raise error
		      IF  chk_contract_trn_rec1.id IS NOT NULL THEN

                 -- Transaction exists for contract CONTRACT_NUMBER which was processed
			     -- after this quote was created. This quote is now invalid.
                 OKL_API.set_message (
            			 p_app_name     => 'OKL',
           	    		 p_msg_name     => 'OKL_AM_TRN_EXISTS_ERR',
                         p_token1       => 'CONTRACT_NUMBER',
                         p_token1_value => db_contract_number);

                 RAISE OKL_API.G_EXCEPTION_ERROR;

		      END IF;
		   END LOOP;

           -- check for split asset transaction -- GO BY NEW CHECK -- checks for non canceled and non processed split asset transactions
           FOR chk_split_trn_rec1 IN chk_split_trn_csr1 (l_contract_id, db_creation_date) LOOP

      	      -- if split asset transaction exists then raise error
			  IF chk_split_trn_rec1.id IS NOT NULL THEN

                 -- Transaction exists for contract CONTRACT_NUMBER which was processed
                 -- after this quote was created. This quote is now invalid.
                 OKL_API.set_message (
            			       p_app_name     => 'OKL',
           	    		       p_msg_name     => 'OKL_AM_TRN_EXISTS_ERR',
                               p_token1       => 'CONTRACT_NUMBER',
                               p_token1_value => db_contract_number);

                 RAISE OKL_API.G_EXCEPTION_ERROR;

              END IF;
           END LOOP;
		   END IF;
		END IF;

        -- *****************
        -- LOOP thru quote assets
        -- *****************

        -- Get the quote lines
        FOR get_qte_lines_rec IN get_qte_lines_csr(lp_term_rec.id) LOOP


           -- *****************
           -- IF asset serialized, then count of okl_txd_quote_line_dtls
           -- for the TQL_ID should equal the quote asset quantity
           -- *****************

           -- Get if asset serialized
           l_return_status := check_asset_sno(
                                  p_asset_line  => get_qte_lines_rec.kle_id,
                                  x_sno_yn      => lx_asset_serialized_yn,
                                  x_clev_tbl    => lx_clev_tbl);
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called check_asset_sno, return status :' || l_return_status);
           END IF;


           -- If error in checking if asset serialized
           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN


              RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;


           -- If asset serialized and IB Line Count <> Quote Qty then error
           IF lx_asset_serialized_yn = OKL_API.G_TRUE THEN


              -- Get the IB line count
              OPEN  get_ib_lines_cnt_csr(get_qte_lines_rec.tql_id);
              FETCH get_ib_lines_cnt_csr INTO l_ib_lines_count;
              CLOSE get_ib_lines_cnt_csr;


              -- If IB line count does not match Quote Qty raise msg and exp
              -- RMUNJULU 14-JAN-03 2748581 Added condition to check only when partial line
              IF l_ib_lines_count <> get_qte_lines_rec.quote_quantity
              AND get_qte_lines_rec.quote_quantity <> get_qte_lines_rec.asset_quantity THEN


                  -- Asset ASSET_NUMBER is serialized. Quote quantity
                  -- QUOTE_QUANTITY does not match the number of selected asset
                  -- units ASSET_UNITS.
                  OKL_API.set_message (
                			 p_app_name  	  => 'OKL',
            	    		 p_msg_name  	  => 'OKL_AM_QTE_QTY_SRL_CNT_ERR',
                       p_token1       => 'ASSET_NUMBER',
                       p_token1_value => get_qte_lines_rec.asset_name,
                       p_token2       => 'QUOTE_QUANTITY',
                       p_token2_value => get_qte_lines_rec.quote_quantity,
                       p_token3       => 'ASSET_UNITS',
                       p_token3_value => l_ib_lines_count);


                  RAISE OKL_API.G_EXCEPTION_ERROR;

              END IF;
           END IF;

           -- rmunjulu EDAT Add code for FA checks, do this only for prior dated terminations
           -- and termination with purchase (which is when we do asset disposal)
           --IF  trunc(l_date_eff_from) < trunc(db_creation_date)
           -- rmunjulu Bug 4143251 Check for FA checks for all quotes (not just PRIOR DATED)
    	   IF  db_qtp_code IN ( 'TER_PURCHASE',     -- Termination - With Purchase
		                        'TER_MAN_PURCHASE', -- Termination - Manual With Purchase
		   					    'TER_RECOURSE',     -- Termination - Recourse With Purchase
		 						'TER_ROLL_PURCHASE' -- Termination - Rollover To New Contract With Purchase
							   ) THEN

                 check_asset_validity_in_fa(
                      p_kle_id          => get_qte_lines_rec.kle_id,
                      p_trn_date        => l_date_eff_from, -- quote eff from date will be passed
                      p_check_fa_year   => 'Y', -- do we need to check fiscal year
				      p_check_fa_trn    => 'Y', -- do we need to check fa transactions
				      p_contract_number => db_contract_number,
				      x_return_status   => l_return_status);
                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called check_asset_validity_in_fa , return status: ' || l_return_status);
                 END IF;

              -- If error in FA checks the throw exception, message set in above routine
              IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_contract_product_details');
              END IF;
              -- rmunjulu LOANS_ENHACEMENTS Termination with purchase not allowed for loans
			  -- Get the contract product details
              OKL_AM_UTIL_PVT.get_contract_product_details(
                      p_khr_id           => l_contract_id,
                      x_deal_type        => l_deal_type,
                      x_rev_rec_method   => l_rev_rec_method,
				      x_int_cal_basis    => l_int_cal_basis,
				      x_tax_owner        => l_tax_owner,
				      x_return_status    => l_return_status);
              IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.get_contract_product_details , return status: ' || l_return_status);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_deal_type: ' || l_deal_type);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_rev_rec_method: ' || l_rev_rec_method);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_int_cal_basis: ' || l_int_cal_basis);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_tax_owner: ' || l_tax_owner);
              END IF;

              -- If error then throw exception
              IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              IF  l_deal_type LIKE 'LOAN%' THEN

                 -- Termination with purchase quote is not allowed for loan contract.
                 OKL_API.SET_MESSAGE(
                     p_app_name     => 'OKL',
 	                 p_msg_name     => 'OKL_AM_LOAN_PAR_ERR');

                 RAISE G_EXCEPTION_HALT_VALIDATION;

              END IF;

           END IF;


           -- rmunjulu LOANS_ENHANCEMENTS Partial Line Termination not allowed for loans with Actual/Estimated Actual
           --IF  get_qte_lines_rec.quote_quantity < get_qte_lines_rec.asset_quantity THEN -- SECHAWLA 04-JAN-06 4915133
		   IF db_partial_yn = 'Y' THEN --  SECHAWLA 04-JAN-06 4915133 : partial quotes not allowed for loan k with
		                               -- rev rec method 'ESTIMATED_AND_BILLED','ACTUAL'
			  -- Get the contract product details
              IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_contract_product_details');
              END IF;
              OKL_AM_UTIL_PVT.get_contract_product_details(
                      p_khr_id           => l_contract_id,
                      x_deal_type        => l_deal_type,
                      x_rev_rec_method   => l_rev_rec_method,
				      x_int_cal_basis    => l_int_cal_basis,
				      x_tax_owner        => l_tax_owner,
				      x_return_status    => l_return_status);
              IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.get_contract_product_details , return status: ' || l_return_status);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_deal_type: ' || l_deal_type);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_rev_rec_method: ' || l_rev_rec_method);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_int_cal_basis: ' || l_int_cal_basis);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_tax_owner: ' || l_tax_owner);
              END IF;

              -- If error then throw exception
              IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              IF  l_deal_type LIKE 'LOAN%'
              AND l_rev_rec_method IN ('ESTIMATED_AND_BILLED','ACTUAL') THEN

                --SECHAWLA 04-JAN-06 4915133
                OKL_API.SET_MESSAGE(
                     p_app_name     => 'OKL',
 	                 p_msg_name     => 'OKL_AM_LOAN_PAR_LN_TRMNT');

                 RAISE OKL_API.G_EXCEPTION_ERROR;

              END IF;
           END IF;

           -- RMUNJULU 30-DEC-02 2699412 Added code to get and set other quotes statuses

           -- *****************
           -- CANCEL all the other non canceled/completed termination quotes for the asset
           -- *****************


           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_all_term_quotes_for_line');
           END IF;
           -- Get quotes for line
           OKL_AM_UTIL_PVT.get_all_term_quotes_for_line (
               p_kle_id        => get_qte_lines_rec.kle_id,
               x_quote_tbl     => lx_quote_tbl,
               x_return_status => l_return_status);
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.get_all_term_quotes_for_line , return status: ' || l_return_status);
           END IF;



           -- Loop thru the quotes for the asset
           IF lx_quote_tbl.COUNT > 0 THEN

              i := lx_quote_tbl.FIRST;
              LOOP

                 -- if the quote id different and quote not consolidated and not
                 -- completed/canceled then cancel it
                 IF  lx_quote_tbl(i).id <> lp_term_rec.id
                 AND NVL(lx_quote_tbl(i).consolidated_yn,'N') <> 'Y'
                 AND lx_quote_tbl(i).qst_code NOT IN('COMPLETED',
                                                     'CANCELLED') THEN

                    -- set the canceled qtev rec
                    lp_canceled_qtev_rec.id := lx_quote_tbl(i).id;
                    lp_canceled_qtev_rec.qst_code := 'CANCELLED';


                    IF (is_debug_statement_on) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TRX_QUOTES_PUB.update_trx_quotes');
                    END IF;
                    -- update the quote to canceled
                    OKL_TRX_QUOTES_PUB.update_trx_quotes(
                             p_api_version    => p_api_version,
                             p_init_msg_list  => OKL_API.G_FALSE,
                             x_return_status  => l_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_qtev_rec       => lp_canceled_qtev_rec,
                             x_qtev_rec       => lx_canceled_qtev_rec);
                    IF (is_debug_statement_on) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_TRX_QUOTES_PUB.update_trx_quotes , return status: ' || l_return_status);
                    END IF;

                    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                 END IF;

                 EXIT WHEN i = lx_quote_tbl.LAST;
                 i := lx_quote_tbl.NEXT(i);
              END LOOP;


           END IF;

            -- Bug 6674730 start
            -- Check all asset returns for assets on repossession quote are in
            -- 'Repossessed' status

           IF NVL(db_repo_yn,'N') = 'Y' THEN
              l_ars_code := '?';
              OPEN c_asset_return_csr(get_qte_lines_rec.kle_id);
              FETCH c_asset_return_csr INTO l_ars_code;
              CLOSE c_asset_return_csr;

              IF (NVL(l_ars_code,'?') <> 'REPOSSESSED') THEN
                -- You cannot accept this termination quote.
		        -- Please update the Asset Return status to Repossessed for all
			    -- assets on contract number CONTRACT_NUMBER.
                OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                                     p_msg_name      => 'OKL_AM_ASSET_NOT_REPO',
                                     p_token1        => 'CONTRACT_NUMBER',
                                     p_token1_value  => l_contract_number);

               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
           END IF;
           -- Bug 6674730 end

        END LOOP;

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.check_int_calc_done');
        END IF;
          -- rmunjulu LOANS_ENHANCEMENTS
        l_int_calc_done :=  OKL_AM_LEASE_LOAN_TRMNT_PVT.check_int_calc_done(
                                   p_contract_id      => l_contract_id,
                                   p_contract_number  => l_contract_number,
                                   p_quote_number     => db_quote_number,
                                   p_source           => 'UPDATE',
                                   p_trn_date         => l_date_eff_from);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PVT.check_int_calc_done');
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_int_calc_done: ' || l_int_calc_done);
        END IF;

        IF l_int_calc_done IS NULL OR l_int_calc_done = 'N' THEN

            -- Message will be set in called procedure
            RAISE OKL_API.G_EXCEPTION_ERROR;

            -- rmunjulu Check if Variable Rate NON REAMORT case, if yes then run variable rate billing API

        END IF;

        --SECHAWLA 20-JAN-06 4970009 : Moved the billing check after the interest calculation check
        -- Interest calculation check now also checks variable rate processing for lease contract ('FLOAT_FACTORS','REAMORT')
        -- for float_factor contract, if last interest calculation date is null that means float factor streams
		-- have not been generated. Variable rate processing on a float factor contract generates the float factor
		-- streams and then bills them. So we should do the billing check after we know that float factor streams have
		-- been created. Similarly, for reamort contract, variable rate processing regenerates the streams (RENT)
		-- We need to then manually run billing to bill those streams. So we should do the billing check after we
		-- know that varaibel rate processing has regenerated the streams

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_SERVICE_INTEGRATION_PVT.check_service_link');
        END IF;

        -- Check if linked service contract exists for the quoted contract
        OKL_SERVICE_INTEGRATION_PVT.check_service_link (
                                p_api_version           => l_api_version,
                                p_init_msg_list         => OKL_API.G_FALSE,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data,
                                p_lease_contract_id     => l_contract_id,
                                x_service_contract_id   => l_oks_chr_id);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
          'called OKL_SERVICE_INTEGRATION_PVT.check_service_link , return status: ' || l_return_status);

          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
          'called OKL_SERVICE_INTEGRATION_PVT.check_service_link , l_oks_chr_id: ' || l_oks_chr_id);
        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           -- Error checking service integration details.
           OKL_API.set_message (
                   p_app_name  	  => OKL_API.G_APP_NAME,
        	          p_msg_name  	  => 'OKL_AM_K_SRV_INT_ERR');
        END IF;

        -- raise exception if error
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Bug# 8756653
        -- Moved check for true partial quote outside the IF condition for linked service contract
        -- IF Partial Quote
        IF db_partial_yn = 'Y' THEN

          IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.check_true_partial_quote');
          END IF;
          -- need to check if no more assets (This case p_quote_id is Always populated)
          l_true_partial_quote := OKL_AM_LEASE_LOAN_TRMNT_PVT.check_true_partial_quote(
                                  p_quote_id     => lp_term_rec.id,
                                  p_contract_id  => l_contract_id);
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PVT.check_true_partial_quote , l_true_partial_quote: ' || l_true_partial_quote);
          END IF;

        ELSE -- Partial_YN = 'N'

          l_true_partial_quote := 'N';

        END IF;

        -- If linked Lease
        IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
        AND l_oks_chr_id IS NOT NULL THEN

            -- If partial quote and since linked lease
            IF l_true_partial_quote = 'Y' THEN

                -- Get Service Contract Details
                FOR get_service_k_dtls_rec IN get_service_k_dtls_csr(l_oks_chr_id) LOOP
                    l_service_contract := get_service_k_dtls_rec.contract_number;
                END LOOP;

                -- Partial Quote QUOTE_NUMBER for Lease Contract LEASE_CONTRACT can not be accepted,
                -- since Lease Contract is linked to Service Contract SERVICE_CONTRACT.
                OKL_API.set_message (
         			       p_app_name  	  => OKL_API.G_APP_NAME,
              			   p_msg_name  	  => 'OKL_AM_ACCEPT_LINKED_LEASE',
                           p_token1       => 'QUOTE_NUMBER',
                           p_token1_value => db_quote_number,
                           p_token2       => 'LEASE_CONTRACT',
                           p_token2_value => l_contract_number,
                           p_token3       => 'SERVICE_CONTRACT',
                           p_token3_value => l_service_contract);

                RAISE OKL_API.G_EXCEPTION_ERROR;

            END IF;

        END IF;

        --Bug# 8756653
        -- Check if contract has been upgraded for effective dated rebook
        IF (l_true_partial_quote = 'Y' AND l_sts_code = 'BOOKED')  THEN

          IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
              'calling OKL_LLA_UTIL_PVT.check_rebook_upgrade');
          END IF;

          OKL_LLA_UTIL_PVT.check_rebook_upgrade
            (p_api_version     => l_api_version,
             p_init_msg_list   => OKL_API.G_FALSE,
             x_return_status   => l_return_status,
             x_msg_count       => l_msg_count,
             x_msg_data        => l_msg_data,
             p_chr_id          => l_contract_id);

          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
            'called OKL_LLA_UTIL_PVT.check_rebook_upgrade , return status: ' || l_return_status);
          END IF;

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
          'calling OKL_AM_UTIL_PVT.get_contract_product_details ');
        END IF;

        -- Get the Product Qualities
        OKL_AM_UTIL_PVT.get_contract_product_details (
           p_khr_id         => l_contract_id,
           x_deal_type      => l_deal_type,
           x_rev_rec_method => l_rev_rec_method,
           x_int_cal_basis  => l_int_cal_basis,
           x_tax_owner      => l_tax_owner,
           x_return_status  => l_return_status);

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
          'called OKL_AM_UTIL_PVT.get_contract_product_details ');

          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
          'l_return_status: ' || l_return_status);
        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           -- Error getting contract product details.
           OKL_API.set_message (
                   p_app_name  	  => OKL_API.G_APP_NAME,
        	          p_msg_name  	  => 'OKL_AM_K_PRD_DTLS_ERR');
        END IF;

        -- raise exception if error
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

         -- BPD Now provides a API which tells till when the billing was done, use that
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
          'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.check_billing_done');
        END IF;

        -- rmunjulu 6736148  Check if stream billing done
        l_billing_done :=  OKL_AM_LEASE_LOAN_TRMNT_PVT.check_billing_done(
                                   p_contract_id      => l_contract_id,
                                   p_contract_number  => l_contract_number,
                                   p_quote_number     => db_quote_number,
                                   p_trn_date         => l_date_eff_from,
                                   p_rev_rec_method   => l_rev_rec_method, -- rmunjulu 6795295
                                   p_int_cal_basis    => l_int_cal_basis, -- rmunjulu 6795295
                                   p_oks_chr_id       => l_oks_chr_id, -- rmunjulu 6795295
                                   p_sts_code         => l_sts_code); -- rmunjulu 6795295

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
          'called OKL_AM_LEASE_LOAN_TRMNT_PVT.check_billing_done');

          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
          'l_billing_done: ' || l_billing_done);
        END IF;

        -- rmunjulu 6736148  this now tells of stream billing done
        IF l_billing_done IS NULL OR l_billing_done = 'N' THEN

          -- if RevRec=STREAMS and IntCalc=FIXED
          -- and No OKS contract and Contract status in Booked then perform Billing by calling Stream Billing API.
          IF  l_rev_rec_method = 'STREAMS'
          AND l_int_cal_basis = 'FIXED'
          AND l_oks_chr_id IS NULL
          AND l_sts_code = 'BOOKED' THEN -- rmunjulu 6795295  added check for BOOKED contract

            -- rmunjulu 6795295 Check if billing or accrual concurrent programs running
            OPEN conc_details_csr (l_org_id);
            FETCH conc_details_csr INTO conc_details_rec;
            IF conc_details_csr%found THEN
              l_conc_req_found := 'Y';
            END IF;
            CLOSE conc_details_csr;

            IF l_conc_req_found = 'Y' THEN

              -- get the phase using FND API
              l_success := FND_CONCURRENT.get_request_status(
                  request_id  => conc_details_rec.request_id,
     	    		      phase       => l_phase_meaning,
         			      status      => l_status_meaning,
         			      dev_phase   => l_dev_phase,
         			      dev_status  => l_dev_status,
         			      message     => l_fnd_message);

              -- Termination Quote 'QUOTE_NUMBER' cannot be accepted at this time as
              -- the concurrent program 'PROGRAM_NAME'
              -- (Request Id = 'REQUEST_ID') is 'PHASE'.
              -- Please accept the termination quote after the program has completed.
              OKL_API.set_message (
                   p_app_name  	  => OKL_API.G_APP_NAME,
        	          p_msg_name  	  => 'OKL_AM_CONC_REC_FOUND',
                   p_token1       => 'QUOTE_NUMBER',
                   p_token1_value => db_quote_number,
                   p_token2       => 'PROGRAM_NAME',
                   p_token2_value => conc_details_rec.user_concurrent_program_name,
                   p_token3       => 'REQUEST_ID',
                   p_token3_value => conc_details_rec.request_id,
                   p_token4       => 'PHASE',
                   p_token4_value => l_phase_meaning);

              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            -- Call Billing API to do billing of contract
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
              'calling OKL_STREAM_BILLING_PVT.bill_streams');
            END IF;

            -- Call stream billing API if stream billing not done
           	OKL_STREAM_BILLING_PVT.bill_streams (
               			p_api_version		    => p_api_version,
               			p_init_msg_list		  => OKL_API.G_FALSE,
               			x_return_status		  => l_return_status,
               			x_msg_count		      => x_msg_count,
               			x_msg_data		       => x_msg_data,
                  p_commit           => FND_API.G_FALSE,
               			p_contract_number	 => l_contract_number,
                  p_from_bill_date	  => null,
                  p_to_bill_date		   => l_date_eff_from, -- do billing till quote effective from
                  p_cust_acct_id     => null,
                  p_assigned_process => null);

            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
              'called OKL_STREAM_BILLING_PVT.bill_streams');

              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
              'l_return_status: ' || l_return_status);
            END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                -- Error during billing for the contract.
                OKL_API.set_message (
         			               p_app_name  	  => OKL_API.G_APP_NAME,
              			          p_msg_name  	  => 'OKL_AM_BILL_ERROR');
            END IF;

            -- raise exception if error
            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          ELSE -- RevRec IS NOT STREAMS or IntCalc IS NOT FIXED or OKS may be linked

             -- rmunjulu 6795295 set the message if needed
             IF nvl(l_stream_bill_done_yn ,'*') = 'N' THEN
                -- Quote QUOTE_NUMBER can not be accepted. Please process Regular Stream billing
                -- for contract CONTRACT_NUMBER up to the quote effective from date.
                OKL_API.set_message (
         			                   p_app_name  	  => 'OKL',
              		    	          p_msg_name  	  => 'OKL_AM_ACCEPT_TQ_RUN_BILLING',
                               p_token1       => 'QUOTE_NUMBER',
                               p_token1_value => db_quote_number,
                               p_token2       => 'CONTRACT_NUMBER',
                               p_token2_value => l_contract_number);
             ELSE -- service billing not done, message will be set in called procedure
                NULL;
             END IF;
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
            -- rmunjulu AutoTerminate -- END
        END IF;



        -- ++++++++++++++++++++  service contract integration end   ++++++++++++

/* -- rmunjulu LOANS_ENHANCEMENTS
        -- RMUNJULU 3078988 Added code to check if accrual was done for the contract
        -- Check if accruals done
        OPEN  check_accrual_csr(l_contract_id, l_date_eff_from); -- rmunjulu EDAT Check for Accruals till quote eff from date
        FETCH check_accrual_csr INTO l_accrual_not_done;
        CLOSE check_accrual_csr;
*/

        -- rmunjulu 4769094 Based on CHK_ACCRUAL_PREVIOUS_MNTH_YN setup check accruals till quote eff date OR previous month last date
        OPEN  check_accrual_previous_csr;
        FETCH check_accrual_previous_csr INTO l_accrual_previous_mnth_yn;
        CLOSE check_accrual_previous_csr;

        IF nvl(l_accrual_previous_mnth_yn,'N') = 'N' THEN -- rmunjulu 4769094 continue with current check till quote effective date

           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
             'calling OKL_GENERATE_ACCRUALS_PVT.check_date_accrued_till');
           END IF;

           -- rmunjulu LOANS_ENHANCEMENTS -- Check for accrual using new API
           l_accrual_done := OKL_GENERATE_ACCRUALS_PVT.check_date_accrued_till(
                                     p_khr_id => l_contract_id,
                                     p_date   => l_date_eff_from);

           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
             'called OKL_GENERATE_ACCRUALS_PVT.check_date_accrued_till, l_accrual_done: ' || l_accrual_done);
           END IF;

           -- rmunjulu 6736148
           l_final_accrual_date := l_date_eff_from;

      		ELSE -- rmunjulu 4769094 new check till quote eff dates previous month last date

           l_previous_mnth_last_date := LAST_DAY(TRUNC(l_date_eff_from, 'MONTH')-1);

           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
             'calling OKL_GENERATE_ACCRUALS_PVT.check_date_accrued_till');
           END IF;

           l_accrual_done := OKL_GENERATE_ACCRUALS_PVT.check_date_accrued_till(
                                     p_khr_id => l_contract_id,
                                     p_date   => l_previous_mnth_last_date);

           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
             'called OKL_GENERATE_ACCRUALS_PVT.check_date_accrued_till, l_accrual_done: ' || l_accrual_done);
           END IF;

           -- rmunjulu 6736148
           l_final_accrual_date := l_previous_mnth_last_date;

		      END IF;

        -- if accrual not done then error
        IF (l_accrual_done IS NULL ) THEN -- rmunjulu 5036337 check for Null-- check for null rmunjulu LOANS_ENHANCEMENTS Use new variable

            -- Error occurred while checking the accrual status for contract number CONTRACT_NUMBER.
         			-- Function OKL_GENERATE_ACCRUALS_PVT.check_date_accrued_till returned a NULL
           OKL_API.set_message (
                 			       p_app_name  	  => OKL_API.G_APP_NAME,
              			          p_msg_name  	  => 'OKL_AM_CHK_ACCRUAL_ERR',
                           p_token1       => 'CONTRACT_NUMBER',
                           p_token1_value => l_contract_number);

           RAISE OKL_API.G_EXCEPTION_ERROR;

        ELSIF (l_accrual_done = 'N' ) THEN -- rmunjulu 5036337 check for N

          -- rmunjulu 6736148 -- start
          -- if RevRec=STREAMS and IntCalc=FIXED
          -- then perform accruals by calling Generate Accrual API.
          IF  l_rev_rec_method = 'STREAMS'
          AND l_int_cal_basis = 'FIXED'
          AND l_oks_chr_id IS NULL
          AND l_sts_code = 'BOOKED' THEN  -- rmunjulu 6795295  added check for BOOKED status

            -- rmunjulu 6795295 Check if billing or accrual concurrent programs running
            OPEN conc_details_csr (l_org_id);
            FETCH conc_details_csr INTO conc_details_rec;
            IF conc_details_csr%found THEN
              l_conc_req_found := 'Y';
            END IF;
            CLOSE conc_details_csr;

            IF l_conc_req_found = 'Y' THEN

              -- get the phase using FND API
              l_success := FND_CONCURRENT.get_request_status(
                  request_id  => conc_details_rec.request_id,
     	    		      phase       => l_phase_meaning,
         			      status      => l_status_meaning,
         			      dev_phase   => l_dev_phase,
         			      dev_status  => l_dev_status,
         			      message     => l_fnd_message);

              -- Termination Quote 'QUOTE_NUMBER' cannot be accepted at this time as
              -- the concurrent program 'PROGRAM_NAME'
              -- (Request Id = 'REQUEST_ID') is 'PHASE'.
              -- Please accept the termination quote after the program has completed.
              OKL_API.set_message (
                   p_app_name  	  => OKL_API.G_APP_NAME,
        	          p_msg_name  	  => 'OKL_AM_CONC_REC_FOUND',
                   p_token1       => 'QUOTE_NUMBER',
                   p_token1_value => db_quote_number,
                   p_token2       => 'PROGRAM_NAME',
                   p_token2_value => conc_details_rec.user_concurrent_program_name,
                   p_token3       => 'REQUEST_ID',
                   p_token3_value => conc_details_rec.request_id,
                   p_token4       => 'PHASE',
                   p_token4_value => l_phase_meaning);

              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

             -- set the accrual_rec
             l_accrual_rec.contract_id := l_contract_id;
             l_accrual_rec.accrual_date := l_final_accrual_date;
             l_accrual_rec.source_trx_id := lp_term_rec.id; -- quote_id
             l_accrual_rec.source_trx_type := 'QTE';

             IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
               'calling OKL_GENERATE_ACCRUALS_PVT.generate_accruals');
             END IF;

             -- Call Accruals API
             OKL_GENERATE_ACCRUALS_PVT.generate_accruals (
               			p_api_version		    => p_api_version,
               			p_init_msg_list		  => OKL_API.G_FALSE,
               			x_return_status		  => l_return_status,
               			x_msg_count		      => x_msg_count,
               			x_msg_data		       => x_msg_data,
                  p_accrual_rec      => l_accrual_rec);

             IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
               'called OKL_GENERATE_ACCRUALS_PVT.generate_accruals');

               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,
               'l_return_status: ' || l_return_status);
             END IF;

             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                -- Error during running accrual for the contract.
                OKL_API.set_message (
         			               p_app_name  	  => OKL_API.G_APP_NAME,
              			          p_msg_name  	  => 'OKL_AM_ACCRUAL_ERROR');
             END IF;

             -- raise exception if error
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          -- rmunjulu 6736148 -- end
          ELSE -- RevRec IS NOT STREAMS or IntCalc IS NOT FIXED

             IF nvl(l_accrual_previous_mnth_yn,'N') = 'N' THEN -- rmunjulu 4769094 continue with current message

               -- Quote QUOTE_NUMBER can not be accepted. Please process accrual
               -- for contract CONTRACT_NUMBER up to the quote effective from date.
               OKL_API.set_message (
                 			       p_app_name  	  => OKL_API.G_APP_NAME,
                     			   p_msg_name  	  => 'OKL_AM_ACCEPT_TQ_RUN_ACCRUAL',
                           p_token1       => 'QUOTE_NUMBER',
                           p_token1_value => db_quote_number,
                           p_token2       => 'CONTRACT_NUMBER',
                           p_token2_value => l_contract_number);

             ELSE -- rmunjulu 4769094 new message check till quote eff dates previous month last date
               -- Quote QUOTE_NUMBER can not be accepted. Please process accrual
               -- for contract CONTRACT_NUMBER up to the DATE.
               OKL_API.set_message (
         		        	       p_app_name  	  => OKL_API.G_APP_NAME,
              			          p_msg_name  	  => 'OKL_AM_ACCEPT_TQ_RUN_ACCR_NEW',
                           p_token1       => 'QUOTE_NUMBER',
                           p_token1_value => db_quote_number,
                           p_token2       => 'CONTRACT_NUMBER',
                           p_token2_value => l_contract_number,
                  						   p_token3       => 'DATE',
                           p_token3_value => l_previous_mnth_last_date);
             END IF;

             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
        END IF;

        -- RMUNJULU 30-DEC-02 2699412 Added code to set currency conversion columns

        -- *****************
        -- SET the currency cols if acceptance date different from currency_conversion_date
        -- *****************


        IF TRUNC(db_sysdate) <> TRUNC(db_currency_conversion_date) THEN


          -- If the functional currency is different from contract currency then set
          -- currency conversion columns
          IF db_functional_currency_code <> db_contract_currency_code THEN

             IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_ACCOUNTING_UTIL.convert_to_functional_currency');
             END IF;
             -- Get the currency conversion details from ACCOUNTING_Util
             OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id  		  	          => l_contract_id,
                     p_to_currency   		        => db_functional_currency_code,
                     p_transaction_date 		    => db_sysdate,
                     p_amount 			            => l_hard_coded_amount,
                     x_return_status            => l_return_status,
                     x_contract_currency		    => db_contract_currency_code,
                     x_currency_conversion_type	=> l_currency_conversion_type,
                     x_currency_conversion_rate	=> l_currency_conversion_rate,
                     x_currency_conversion_date	=> l_currency_conversion_date,
                     x_converted_amount 		    => l_converted_amount);
             IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_ACCOUNTING_UTIL.convert_to_functional_currency , return status: ' || l_return_status);
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'db_contract_currency_code: ' || db_contract_currency_code);
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_currency_conversion_type: ' || l_currency_conversion_type);
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_currency_conversion_rate: ' || l_currency_conversion_rate);
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_currency_conversion_date: ' || l_currency_conversion_date);
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_converted_amount: ' || l_converted_amount);
             END IF;

             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                -- The currency conversion rate could not be
                -- identified for specified currency.
                OKL_API.set_message(
                          p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_CONV_RATE_NOT_FOUND');

             END IF;

             -- raise exception if error
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             -- Set the currency conversion columns
             lp_term_rec.currency_conversion_type := l_currency_conversion_type;
             lp_term_rec.currency_conversion_rate := l_currency_conversion_rate;
             lp_term_rec.currency_conversion_date := l_currency_conversion_date;

          END IF;


        END IF;

        -- Setting the quote values
        lp_term_rec.qst_code := 'ACCEPTED';
        lp_term_rec.date_accepted := db_sysdate;


    -- if already accepted and trying to change then raise error
    ELSIF  lp_term_rec.accepted_yn IS NOT NULL
    AND lp_term_rec.accepted_yn <> OKL_API.G_MISS_CHAR
    AND lp_term_rec.accepted_yn = G_NO
    AND db_accepted_yn = G_YES THEN

        --Quote QUOTE_NUMBER is already accepted.
        OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                             p_msg_name      => 'OKL_AM_QUOTE_ALREADY_ACCP',
                             p_token1        => 'QUOTE_NUMBER',
                             p_token1_value  => db_quote_number);

        RAISE OKL_API.G_EXCEPTION_ERROR;

	-- rmunjulu 4128965 Added this additional check
    -- if already accepted and trying to accept again
    -- Could happen when same rollover quote was added to 2 contracts and
	-- accepted from one activation and then trying to accept from other activation
    ELSIF  lp_term_rec.accepted_yn IS NOT NULL
    AND lp_term_rec.accepted_yn <> OKL_API.G_MISS_CHAR
    AND lp_term_rec.accepted_yn = G_YES
    AND db_accepted_yn = G_YES THEN

        --Quote QUOTE_NUMBER is already accepted.
        OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                             p_msg_name      => 'OKL_AM_QUOTE_ALREADY_ACCP',
                             p_token1        => 'QUOTE_NUMBER',
                             p_token1_value  => db_quote_number);

        RAISE OKL_API.G_EXCEPTION_ERROR;


    END IF; -- end if quote being accepted now

    -- RMUNJULU -- 12-DEC-02 Bug # 2484327 -- END --



    -----------------------
    -- CALL TO UPDATE QUOTE --
    -----------------------

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TRX_QUOTES_PUB.update_trx_quotes');
    END IF;
    -- update the quote
    OKL_TRX_QUOTES_PUB.update_trx_quotes(
             p_api_version                  => p_api_version,
             p_init_msg_list                => p_init_msg_list,
             x_return_status                => l_return_status,
             x_msg_count                    => x_msg_count,
             x_msg_data                     => x_msg_data,
             p_qtev_rec                     => lp_term_rec,
             x_qtev_rec                     => lx_term_rec);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_TRX_QUOTES_PUB.update_trx_quotes , return status: ' || l_return_status);
    END IF;

     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    --*************
    -- launch WF
    --*************

    -- if the quote is accepted now
    IF (lp_term_rec.accepted_yn = G_YES AND db_accepted_yn = G_NO)
	AND nvl(p_acceptance_source,'*') <> 'ROLLOVER' THEN -- rmunjulu 4128965 Launch WF only for Non Rollover

      -- Trigger the launch of WFs
      IF lp_term_rec.preproceeds_yn = G_YES THEN
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_WF.raise_business_event');
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'lp_term_rec.id: ' || lp_term_rec.id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'event: oracle.apps.okl.am.preproceeds');
        END IF;
        -- Launch the pre-proceeds WF
        OKL_AM_WF.raise_business_event (
                       	p_transaction_id => lp_term_rec.id,
                        p_event_name	   => 'oracle.apps.okl.am.preproceeds');
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_WF.raise_business_event');
        END IF;

        -- Get the event name
        l_event_name := OKL_AM_UTIL_PVT.get_wf_event_name(
                            p_wf_process_type => 'OKLAMPPT',
                            p_wf_process_name => 'OKL_AM_PRE_PRO_TER',
                            x_return_status   => l_return_status);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_event_name: ' || l_event_name);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_return_status: ' || l_return_status);
        END IF;

        -- raise exception if error
        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

      ELSE
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_WF.raise_business_event');
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'lp_term_rec.id: ' || lp_term_rec.id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'event: oracle.apps.okl.am.postproceeds');
        END IF;
        -- Launch the post-proceeds WF
        OKL_AM_WF.raise_business_event (
                        p_transaction_id => lp_term_rec.id,
                        p_event_name	   => 'oracle.apps.okl.am.postproceeds');
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_WF.raise_business_event');
        END IF;

        -- Get the event name
        l_event_name := OKL_AM_UTIL_PVT.get_wf_event_name(
                            p_wf_process_type => 'OKLAMPPT',
                            p_wf_process_name => 'OKL_AM_POST_PRO_TER',
                            x_return_status   => l_return_status);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_event_name: ' || l_event_name);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_return_status: ' || l_return_status);
        END IF;

        -- raise exception if error
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

      -- Set message on stack
      -- Workflow event EVENT_NAME has been requested.
      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_WF_EVENT_MSG',
                          p_token1       => 'EVENT_NAME',
                          p_token1_value => l_event_name);


      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.process_messages');
      END IF;
      -- Save message from stack into transaction message table
      OKL_AM_UTIL_PVT.process_messages(
  	                      p_trx_source_table	=> 'OKL_TRX_QUOTES_V',
    	                    p_trx_id		        => lp_term_rec.id,
    	                    x_return_status     => l_return_status);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.process_messages , return status: ' || l_return_status);
      END IF;

      -- raise exception if error
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

     -- set return variables
     x_return_status := l_return_status;
     x_term_rec      := lx_term_rec;
     x_err_msg       := l_err_msg;

     -- end the transaction
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;
      IF qte_db_vals_csr%ISOPEN THEN
        CLOSE qte_db_vals_csr;
      END IF;
      IF get_k_num_csr%ISOPEN THEN
        CLOSE get_k_num_csr;
      END IF;

      IF get_qte_lines_csr%ISOPEN THEN
        CLOSE get_qte_lines_csr;
      END IF;
      IF get_ib_lines_cnt_csr%ISOPEN THEN
        CLOSE get_ib_lines_cnt_csr;
      END IF;
      -- RMUNJULU 03-APR-03 2880556
      IF get_unbill_strms_csr%ISOPEN THEN
        CLOSE get_unbill_strms_csr;
      END IF;

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
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;
      IF qte_db_vals_csr%ISOPEN THEN
        CLOSE qte_db_vals_csr;
      END IF;
      IF get_k_num_csr%ISOPEN THEN
        CLOSE get_k_num_csr;
      END IF;

      IF get_qte_lines_csr%ISOPEN THEN
        CLOSE get_qte_lines_csr;
      END IF;
      IF get_ib_lines_cnt_csr%ISOPEN THEN
        CLOSE get_ib_lines_cnt_csr;
      END IF;
      -- RMUNJULU 03-APR-03 2880556
      IF get_unbill_strms_csr%ISOPEN THEN
        CLOSE get_unbill_strms_csr;
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      IF qte_db_vals_csr%ISOPEN THEN
        CLOSE qte_db_vals_csr;
      END IF;
      IF get_k_num_csr%ISOPEN THEN
        CLOSE get_k_num_csr;
      END IF;

      IF get_qte_lines_csr%ISOPEN THEN
        CLOSE get_qte_lines_csr;
      END IF;
      IF get_ib_lines_cnt_csr%ISOPEN THEN
        CLOSE get_ib_lines_cnt_csr;
      END IF;
      -- RMUNJULU 03-APR-03 2880556
      IF get_unbill_strms_csr%ISOPEN THEN
        CLOSE get_unbill_strms_csr;
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END terminate_quote;

  -- Start of comments
  --
  -- Procedure Name	: terminate_quote
  -- Description	  : terminates the quote for a input of tbl type
  --
  -- Business Rules	:
  -- Parameters		  :
  -- History        : PAGARG   29-SEP-04 Bug #3921591
  --                           Added additional parameter p_acceptance_source
  --                           This is to identify the source from where this
  --                           procedure is being called. Default value for this
  --                           is null.
  --                           Rollover quote can be accepted only through
  --                           ativiation of rolled over contract. So, as part
  --                           of that of that process, this procedure should be
  --                           called with p_acceptance_source as 'ROLLOVER'
  --                   rmunjulu 19-Jan-05 4128965 Modified to Call Term Qte Rec
  --                           in a separate loop for ROLLOVER and Launch WFs at the end
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE terminate_quote(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_term_tbl                      IN  term_tbl_type,
    x_term_tbl                      OUT NOCOPY term_tbl_type,
    x_err_msg                       OUT NOCOPY VARCHAR2,
    p_acceptance_source             IN  VARCHAR2 DEFAULT NULL)  AS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30) := 'terminate_quote';
    l_api_version            CONSTANT NUMBER := 1;

    -- rmunjulu 4128965 Get quote details
    CURSOR get_qte_dtls_csr ( p_qte_id IN NUMBER) IS
       SELECT qte.accepted_yn
       FROM okl_trx_quotes_v qte
	   WHERE qte.id = p_qte_id;

    -- rmunjulu 4128965
	get_qte_dtls_rec get_qte_dtls_csr%ROWTYPE;
	l_event_name VARCHAR2(320);

    TYPE accepted_yn_tbl IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
    l_accepted_yn_tbl accepted_yn_tbl;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'terminate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_acceptance_source: ' || p_acceptance_source);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl.COUNT: ' || p_term_tbl.COUNT);
    END IF;

    --Check API version, initialize message list and create savepoint.
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

    IF (p_term_tbl.COUNT > 0) THEN
      i := p_term_tbl.FIRST;
      LOOP

          -- rmunjulu 4128965 Get Quote details and store for later use
	      OPEN   get_qte_dtls_csr (p_term_tbl(i).id);
		  FETCH  get_qte_dtls_csr INTO get_qte_dtls_rec;
		  CLOSE  get_qte_dtls_csr;

		  l_accepted_yn_tbl(i) := get_qte_dtls_rec.accepted_yn;

          terminate_quote (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_term_rec                     => p_term_tbl(i),
          x_term_rec                     => x_term_tbl(i),
          x_err_msg                      => x_err_msg,
          p_acceptance_source            => p_acceptance_source);
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called terminate_quote , return status: ' || x_return_status);
          END IF;

       IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
          IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := x_return_status;
          END IF;
       END IF;

       EXIT WHEN (i = p_term_tbl.LAST);
       i := p_term_tbl.NEXT(i);
     END LOOP;
     x_return_status := l_overall_status;

     -- rmunjulu 4128965 If Rollover Quotes then
     IF nvl(p_acceptance_source,'*') =  'ROLLOVER' THEN

       -- raise exception if error
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- rmunjulu 4128965 Loop through the table again to Launch the Termination Workflows, as they were not launched earlier
       i := p_term_tbl.FIRST;
       LOOP

          -- if the quote is accepted now Launch the workflows for all Termination Recs
          IF (nvl(p_term_tbl(i).accepted_yn,'*') = G_YES AND nvl(l_accepted_yn_tbl(i),'*') = G_NO) THEN

             -- Check Pre or Post Proceeds
             IF nvl(p_term_tbl(i).preproceeds_yn,'*') = G_YES THEN

               IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_WF.raise_business_event');
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_term_tbl(' || i || ').id : ' || p_term_tbl(i).id);
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'event : oracle.apps.okl.am.preproceeds');
               END IF;
               -- Launch the pre-proceeds WF
               OKL_AM_WF.raise_business_event (
                       	p_transaction_id   => p_term_tbl(i).id,
                        p_event_name	   => 'oracle.apps.okl.am.preproceeds');
               IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_WF.raise_business_event');
               END IF;

               -- Get the event name
               l_event_name := OKL_AM_UTIL_PVT.get_wf_event_name(
                            p_wf_process_type => 'OKLAMPPT',
                            p_wf_process_name => 'OKL_AM_PRE_PRO_TER',
                            x_return_status   => x_return_status);
               IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_event_name : ' || l_event_name);
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'x_return_status: ' || x_return_status);
               END IF;

               -- raise exception if error
               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               -- Set message on stack
               -- Workflow event EVENT_NAME has been requested.
               OKL_API.set_message(
			              p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_WF_EVENT_MSG',
                          p_token1       => 'EVENT_NAME',
                          p_token1_value => l_event_name);

             ELSE -- Post Proceeds

               IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_WF.raise_business_event');
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_term_tbl(' || i || ').id : ' || p_term_tbl(i).id);
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'event : oracle.apps.okl.am.postproceeds');
               END IF;
               -- Launch the post-proceeds WF
               OKL_AM_WF.raise_business_event (
                        p_transaction_id   => p_term_tbl(i).id,
                        p_event_name	   => 'oracle.apps.okl.am.postproceeds');

               IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_WF.raise_business_event');
               END IF;
               -- Get the event name
               l_event_name := OKL_AM_UTIL_PVT.get_wf_event_name(
                            p_wf_process_type => 'OKLAMPPT',
                            p_wf_process_name => 'OKL_AM_POST_PRO_TER',
                            x_return_status   => x_return_status);
               IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_event_name : ' || l_event_name);
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'x_return_status: ' || x_return_status);
               END IF;

               -- raise exception if error
               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               -- Set message on stack
               -- Workflow event EVENT_NAME has been requested.
               OKL_API.set_message(
			              p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_WF_EVENT_MSG',
                          p_token1       => 'EVENT_NAME',
                          p_token1_value => l_event_name);

             END IF;

             IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.process_messages');
             END IF;
             -- Save message from stack into transaction message table
             OKL_AM_UTIL_PVT.process_messages(
  	                      p_trx_source_table  => 'OKL_TRX_QUOTES_V',
    	                  p_trx_id		      => p_term_tbl(i).id,
    	                  x_return_status     => x_return_status);
             IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.process_messages , return status: ' || x_return_status);
             END IF;

             -- raise exception if error
             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          END IF; -- End of If accepted now

          EXIT WHEN (i = p_term_tbl.LAST);
          i := p_term_tbl.NEXT(i);
          END LOOP;

    	  x_return_status := l_return_status;

       END IF; -- End of Rollover If

    END IF; -- End of Tbl count

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;
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
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END terminate_quote;

  -- Start of comments
  --
  -- Procedure Name : submit_for_approval
  -- Description    : New procedure to support manual termination quote approval via workflow.
  -- Business Rules :
  -- Parameters     : IN quote record structure using only quote id and quote status
  -- Version        : 1.0
  -- History        : MDOKAL    25-NOV-02 - 2680558 : New procedure.
  --                  RMUNJULU 23-JAN-03 2762065 Get the qst_code from DB if not passed
  --                  RMUNJULU 13-May-04 3630826 Changed the business event being raised
  --                  from the submit process.
  -- End of comments

  PROCEDURE submit_for_approval(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_term_rec                      IN  term_rec_type,
    x_term_rec                      OUT NOCOPY term_rec_type) AS


      -- RMUNJULU 23-JAN-03 2762065 Added cursor
      -- Get the quote status
      CURSOR get_quote_status_csr (p_qte_id IN NUMBER) IS
           SELECT QTE.qst_code
           FROM   OKL_TRX_QUOTES_V QTE
           WHERE  QTE.id = p_qte_id;

    l_return_status                 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT VARCHAR2(30) := 'submit_for_approval';
    l_api_version          CONSTANT NUMBER := 1;
    l_event_name                    VARCHAR2(2000);


       l_qst_code VARCHAR2(300);
   l_module_name VARCHAR2(500) := G_MODULE_NAME || 'submit_for_approval';
   is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
   is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
   is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


    BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.id: ' || p_term_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.qrs_code: ' || p_term_rec.qrs_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.qst_code: ' || p_term_rec.qst_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.qtp_code: ' || p_term_rec.qtp_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.trn_code: ' || p_term_rec.trn_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.pop_code_end: ' || p_term_rec.pop_code_end);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.pop_code_early: ' || p_term_rec.pop_code_early);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.consolidated_qte_id: ' || p_term_rec.consolidated_qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.khr_id: ' || p_term_rec.khr_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.art_id: ' || p_term_rec.art_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.pdt_id: ' || p_term_rec.pdt_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.early_termination_yn: ' || p_term_rec.early_termination_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.partial_yn: ' || p_term_rec.partial_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.preproceeds_yn: ' || p_term_rec.preproceeds_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_requested: ' || p_term_rec.date_requested);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_proposal: ' || p_term_rec.date_proposal);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_effective_to: ' || p_term_rec.date_effective_to);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_accepted: ' || p_term_rec.date_accepted);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.summary_format_yn: ' || p_term_rec.summary_format_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.consolidated_yn: ' || p_term_rec.consolidated_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.principal_paydown_amount: ' || p_term_rec.principal_paydown_amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.residual_amount: ' || p_term_rec.residual_amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.yield: ' || p_term_rec.yield);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.rent_amount: ' || p_term_rec.rent_amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_restructure_end: ' || p_term_rec.date_restructure_end);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_restructure_start: ' || p_term_rec.date_restructure_start);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.term: ' || p_term_rec.term);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.purchase_percent: ' || p_term_rec.purchase_percent);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_due: ' || p_term_rec.date_due);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.payment_frequency: ' || p_term_rec.payment_frequency);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.remaining_payments: ' || p_term_rec.remaining_payments);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_effective_from: ' || p_term_rec.date_effective_from);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.quote_number: ' || p_term_rec.quote_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.approved_yn: ' || p_term_rec.approved_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.accepted_yn: ' || p_term_rec.accepted_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.payment_received_yn: ' || p_term_rec.payment_received_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_payment_received: ' || p_term_rec.date_payment_received);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_approved: ' || p_term_rec.date_approved);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.approved_by: ' || p_term_rec.approved_by);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.org_id: ' || p_term_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.purchase_amount: ' || p_term_rec.purchase_amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.purchase_formula: ' || p_term_rec.purchase_formula);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.asset_value: ' || p_term_rec.asset_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.residual_value: ' || p_term_rec.residual_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.unbilled_receivables: ' || p_term_rec.unbilled_receivables);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.gain_loss: ' || p_term_rec.gain_loss);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.PERDIEM_AMOUNT: ' || p_term_rec.PERDIEM_AMOUNT);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_code: ' || p_term_rec.currency_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_code: ' || p_term_rec.currency_conversion_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_type: ' || p_term_rec.currency_conversion_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_rate: ' || p_term_rec.currency_conversion_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_date: ' || p_term_rec.currency_conversion_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.legal_entity_id: ' || p_term_rec.legal_entity_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.repo_quote_indicator_yn: ' || p_term_rec.repo_quote_indicator_yn);
	 END IF;

    --Check API version, initialize message list and create savepoint.
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

    -- Check if quote id passed is valid
    IF p_term_rec.id IS NULL OR p_term_rec.id = OKL_API.G_MISS_NUM THEN

      OKL_API.set_message( p_app_name     => OKC_API.G_APP_NAME,
                           p_msg_name     => OKC_API.G_REQUIRED_VALUE,
                           p_token1       => OKC_API.G_COL_NAME_TOKEN,
                           p_token1_value => 'id');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;


    -- RMUNJULU 23-JAN-03 2762065 Added IF to get the qst_code if not passed
    -- If qst code not passed get from DB
    IF   p_term_rec.qst_code IS NULL
    OR   p_term_rec.qst_code = OKL_API.G_MISS_CHAR THEN

       -- get qst code from DB
       FOR get_quote_status_rec IN get_quote_status_csr(p_term_rec.id) LOOP

           -- Set l_qst_code from DB value
           l_qst_code := get_quote_status_rec.qst_code;

       END LOOP;

    ELSE

      -- Set l_qst_code from parameter value
      l_qst_code := p_term_rec.qst_code;

    END IF;

    -- Check if quote status passed is valid
    -- RMUNJULU 23-JAN-03 2762065 commented out IF since always gets the qst_code
--    IF p_term_rec.qst_code IS NOT NULL AND p_term_rec.qst_code <> OKL_API.G_MISS_CHAR THEN
        IF l_qst_code NOT IN ('DRAFTED','REJECTED') THEN

            -- Generate incorrect status message.
            OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                                 p_msg_name      => 'OKL_AM_SUBMIT_FOR_APPROVAL');

            RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE

             IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_WF.raise_business_event');
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_term_rec.id : ' || p_term_rec.id);
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'event : oracle.apps.okl.am.submitquoteforapproval');
             END IF;
            -- Launch the NSend Quote WF
            -- RMUNJULU 3630826 Changed the business event being raised to a new seeded one
            OKL_AM_WF.raise_business_event (
                    p_transaction_id => p_term_rec.id,
		            p_event_name	 => 'oracle.apps.okl.am.submitquoteforapproval');
             IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_WF.raise_business_event');
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.process_messages');
             END IF;
            -- Save messages in database
            OKL_AM_UTIL_PVT.process_messages (
                	    p_trx_source_table	=> 'OKL_TRX_QUOTES_V',
                	    p_trx_id		=> p_term_rec.id,
                	    x_return_status	=> l_return_status);
             IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.process_messages , return status: ' || l_return_status);
             END IF;

        END IF;
--    ELSE

--      OKL_API.set_message( p_app_name     => OKC_API.G_APP_NAME,
--                           p_msg_name     => OKC_API.G_REQUIRED_VALUE,
--                           p_token1       => OKC_API.G_COL_NAME_TOKEN,
--                           p_token1_value => 'qst_code');
--
--      RAISE OKL_API.G_EXCEPTION_ERROR;

--    END IF;

    -- rmunjulu returning p_term_rec as x_term_rec for bug 4547970
    x_term_rec := p_term_rec;

    x_return_status := l_return_status;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;
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
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    END submit_for_approval;
--
-- BAKUCHIB Bug 2484327 start
--
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_qte_ln_dtls
-- Description          : This Local Procedure is used for validate Quote Line Details Record.
-- Business Rules       :
-- Parameters           : PL/SQL table of record of qte_ln_dtl_tbl type
--                        x_return_status OUT NOCOPY VARCHAR2
-- Version              : 1.0
-- History              : BAKUCHIB  10-DEC-02 - 2484327 created
--                      : BAKUCHIB  13-DEC-02 - 2484327 Modified
--                      : a) Corrected the cursor validate_qte_id_csr
--                        to get the quote number.
--                        b) Also changed to check the count of
--                        select_yn = 'Y' matching quote qty outside
--                        the loop.
--                        c) Removed l_k_lines_validate_csr as not used.
--                      : BAKUCHIB  16-DEC-02 - 2484327 Modified
--                        Quote qty should always be less than or equal to
--                        Asset qty. Earlier an error was been thrown when
--                        Quote qty >= Asset qty.
--                        RMUNJULU 09-JAN-03 2743604 Changed if to check for
--                        assetqty <> qteqty and changed message token
--                        RMUNJULU 14-JAN-03 2748581 Removed the check
--                        assetqty <> qteqty
--                        RMUNJULU 24-JAN-03 2759726 Added code to do proper
--                        validations and raise proper exceptions
--                        Added validations for quote and contract statuses
-- End of Commnets

  PROCEDURE validate_qte_ln_dtls(
                    p_qld_tbl       IN OUT NOCOPY qte_ln_dtl_tbl,
                    x_return_status OUT NOCOPY VARCHAR2) IS

    ln_asset_qty              OKL_TXL_QUOTE_LINES_B.ASSET_QUANTITY%TYPE;
    ln_qte_qty                OKL_TXL_QUOTE_LINES_B.QUOTE_QUANTITY%TYPE;
    lv_asset_number           OKC_K_LINES_TL.NAME%TYPE := null;
    ln_dummy1                 NUMBER := 0;
    ln_dummy2                 NUMBER := 0;
    ln_quote_number           OKL_TRX_QUOTES_B.QUOTE_NUMBER%TYPE := null;
    i                         NUMBER := 0;
    l_qld_tbl                 qte_ln_dtl_tbl := p_qld_tbl;
    l_clev_tbl                CLEV_TBL_TYPE;
    lv_sno_yn                 VARCHAR2(3);
    lv_select_yn              VARCHAR2(3);
    l_return_status           VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    ln_select_count           NUMBER := 0;
    ln_fin_line_id            OKC_K_LINES_B.ID%TYPE;

    G_QUOTE_ALREADY_ACCP      CONSTANT VARCHAR2(200) := 'OKL_AM_QUOTE_ALREADY_ACCP';
    G_INVALID_QUOTE_QTY       CONSTANT VARCHAR2(200) := 'OKL_AM_INVALID_QUOTE_QTY';
    G_QTE_QTY_SRL_CNT_ERR     CONSTANT VARCHAR2(200) := 'OKL_AM_QTE_QTY_SRL_CNT_ERR';

      -- RMUNJULU 24-JAN-03 2759726 Added variables
      ln_chr_id NUMBER;
      lx_contract_status VARCHAR2(300);
      l_api_version	 CONSTANT NUMBER	:= 1;
      l_msg_count NUMBER := OKL_API.G_MISS_NUM;
      l_msg_data VARCHAR2(2000);


    -- Get the asset qty, Quote qty and Asset Number
    -- RMUNJULU 24-JAN-03 2759726 Taken out the sts_code check
    CURSOR get_tql_csr(p_tql_id OKL_TXL_QUOTE_LINES_B.ID%TYPE) IS
    SELECT tql.asset_quantity,
           tql.quote_quantity,
           cle.name,
           cle.chr_id -- RMUNJULU 24-JAN-03 2759726 Added
    FROM OKL_TXL_QUOTE_LINES_B tql,
         OKC_K_LINES_V cle,
         OKC_LINE_STYLES_B lse
    WHERE tql.id = P_tql_id
    AND tql.qlt_code = 'AMCFIA'
    AND tql.kle_id = cle.id
    --AND cle.sts_code = 'BOOKED'
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_FIN_LINE_LTY_CODE
    AND lse.lse_type = G_TLS_TYPE
    AND lse.lse_parent_id IS NULL;

    -- Validate the contract id
    -- RMUNJULU 24-JAN-03 2759726 Taken out the sts_code check
    CURSOR validate_chr_id_csr(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKC_K_HEADERS_B chr
                  WHERE chr.id = p_dnz_chr_id
                  AND scs_code = G_LEASE_SCS_CODE);
                  --AND sts_code = 'BOOKED');

    -- Validate the Install Base line id and contract id
    CURSOR validate_Ib_line_csr(p_ib_id      OKC_K_LINES_B.ID%TYPE,
                                p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKC_K_LINES_B cle,
                       OKC_LINE_STYLES_B lse
                  WHERE cle.id = p_ib_id
                  AND cle.dnz_chr_id = p_dnz_chr_id
                  AND cle.lse_id = lse.id
                  AND lse.lty_code = 'INST_ITEM');

    -- Get the Quote number for Qte id
    CURSOR validate_qte_id_csr(p_qte_id OKL_TRX_QUOTES_B.ID%TYPE) IS
    SELECT quote_number
    FROM OKL_TRX_QUOTES_B qte
    WHERE qte.id = p_qte_id;
   l_module_name VARCHAR2(500) := G_MODULE_NAME || 'validate_qte_ln_dtls';
   is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
   is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
   is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
	 IF (is_debug_statement_on) THEN
	   FOR i IN p_qld_tbl.FIRST..p_qld_tbl.LAST LOOP
	     IF (p_qld_tbl.exists(i)) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').qst_code: ' || p_qld_tbl(i).qst_code);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').qte_id: ' || p_qld_tbl(i).qte_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').instance_quantity: ' || p_qld_tbl(i).instance_quantity);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').tql_id: ' || p_qld_tbl(i).tql_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').tqd_id: ' || p_qld_tbl(i).tqd_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').select_yn: ' || p_qld_tbl(i).select_yn);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').ib_line_id: ' || p_qld_tbl(i).ib_line_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').fin_line_id: ' || p_qld_tbl(i).fin_line_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').dnz_chr_id: ' || p_qld_tbl(i).dnz_chr_id);
	     END IF;
	   END LOOP;
	 END IF;
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF l_qld_tbl.COUNT > 0 THEN

      i := l_qld_tbl.FIRST;

      -- Looping the table of record to validate
      LOOP

        IF (l_qld_tbl(i).tql_id IS NULL OR
           l_qld_tbl(i).tql_id = OKL_API.G_MISS_NUM) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_REQUIRED_VALUE,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'TQL_ID');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

        IF (l_qld_tbl(i).ib_line_id IS NULL OR
           l_qld_tbl(i).ib_line_id = OKL_API.G_MISS_NUM) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_REQUIRED_VALUE,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'IB_LINE_ID');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

        IF (l_qld_tbl(i).fin_line_id IS NULL OR
           l_qld_tbl(i).fin_line_id = OKL_API.G_MISS_NUM) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_REQUIRED_VALUE,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'FIN_LINE_ID');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

        IF (l_qld_tbl(i).dnz_chr_id IS NULL OR
           l_qld_tbl(i).dnz_chr_id = OKL_API.G_MISS_NUM) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_REQUIRED_VALUE,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'DNZ_CHR_ID');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

        IF (l_qld_tbl(i).instance_quantity IS NULL OR
           l_qld_tbl(i).instance_quantity = OKL_API.G_MISS_NUM) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_REQUIRED_VALUE,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'INSTANCE_QUANTITY');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

        -- Validating QTE ID
        OPEN  validate_qte_id_csr(p_qte_id => l_qld_tbl(i).qte_id);
        FETCH validate_qte_id_csr INTO ln_quote_number;
        IF validate_qte_id_csr%NOTFOUND THEN
          ln_quote_number := null;
        END IF;
        CLOSE validate_qte_id_csr;

        IF (ln_quote_number IS NULL OR
           ln_quote_number = OKL_API.G_MISS_NUM) THEN
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_INVALID_VALUE,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'QTE_ID');
          -- RMUNJULU 24-JAN-03 2759726 Changed l_return_status to x_return_status
          x_return_status := OKL_API.G_RET_STS_ERROR;
          -- RMUNJULU 24-JAN-03 2759726 Added exit when
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

-- RMUNJULU 24-JAN-03 2759726 commented out this code
--        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
--          IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
--            x_return_status := l_return_status;
--          END IF;
--        END IF;

        -- Validating QST_CODE
        IF l_qld_tbl(i).qst_code IN ('ACCEPTED','COMPLETE') THEN

          -- Quote QUOTE_NUMBER is already accepted.
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_QUOTE_ALREADY_ACCP,
                              p_token1        => 'QUOTE_NUMBER',
                              p_token1_value  => TO_CHAR(ln_quote_number));
          -- RMUNJULU 24-JAN-03 2759726 Changed l_return_status to x_return_status
          x_return_status := OKL_API.G_RET_STS_ERROR;
          -- RMUNJULU 24-JAN-03 2759726 Added exit when
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

        -- RMUNJULU 24-JAN-03 2759726 Check if Quote is already canceled.
        IF l_qld_tbl(i).qst_code = 'CANCELLED' THEN

          -- Quote QUOTE_NUMBER is already canceled.
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => 'OKL_AM_QUOTE_ALREADY_CANCELED',
                              p_token1        => 'QUOTE_NUMBER',
                              p_token1_value  =>  TO_CHAR(ln_quote_number));

          x_return_status := OKL_API.G_RET_STS_ERROR;

          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);

        END IF;


--        RMUNJULU 24-JAN-03 2759726 commented out this code
--        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
--          IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
--            x_return_status := l_return_status;
--          END IF;
--        END IF;

        -- Validating TQL_ID
        OPEN  get_tql_csr(p_tql_id => l_qld_tbl(i).tql_id);
        FETCH get_tql_csr INTO ln_asset_qty,
                               ln_qte_qty,
                               lv_asset_number,
                               ln_chr_id; -- RMUNJULU 24-JAN-03 2759726 Added
        IF get_tql_csr%NOTFOUND THEN
          lv_asset_number := null;
        END IF;
        CLOSE get_tql_csr;

        IF (lv_asset_number IS NOT NULL AND --RMUNJULU 24-JAN-03 2759726 Changed OR to AND
            lv_asset_number <> OKL_API.G_MISS_CHAR) THEN

          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract');
          END IF;
          -- RMUNJULU 24-JAN-03 2759726 Added code to check if contract valid
          OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract(
                          p_api_version     => l_api_version,
                          p_init_msg_list   => OKL_API.G_FALSE,
                          x_return_status   => x_return_status,
                          x_msg_count       => l_msg_count,
                          x_msg_data        => l_msg_data,
                          p_contract_id     => ln_chr_id,
                          p_control_flag    => 'TRMNT_QUOTE_UPDATE',
                          x_contract_status => lx_contract_status);
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract , lx_contract_status: ' || lx_contract_status);
          END IF;


          -- RMUNJULU 24-JAN-03 2759726 Added code to exit out of loop
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR
                  OR x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);


          IF ln_qte_qty IS NOT NULL AND --RMUNJULU 24-JAN-03 2759726 Changed OR to AND
             ln_asset_qty IS NOT NULL THEN

            IF ln_qte_qty > ln_asset_qty THEN

              -- Asset ASSET_NUMBER quantity is less than the specified quote quantity.
              OKL_API.set_message(p_app_name      => G_APP_NAME,
                                  p_msg_name      => G_INVALID_QUOTE_QTY,
                                  p_token1        => 'ASSET_NUMBER',
                                  p_token1_value  => lv_asset_number);

              -- RMUNJULU 24-JAN-03 2759726 Changed l_return_status to x_return_status
              x_return_status := OKL_API.G_RET_STS_ERROR;

              -- RMUNJULU 24-JAN-03 2759726 Added exit when
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);

            END IF;

          ELSE

            OKL_API.set_message(p_app_name      => G_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE, -- RMUNJULU 24-JAN-03 2759726 Changed
                                p_token1        => G_COL_NAME_TOKEN,
                                p_token1_value  => 'TQL_ID');

            -- RMUNJULU 24-JAN-03 2759726 Changed l_return_status to x_return_status
            x_return_status := OKL_API.G_RET_STS_ERROR;

            -- RMUNJULU 24-JAN-03 2759726 Added exit when
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);

          END IF;
        ELSE
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_INVALID_VALUE,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'TQL_ID');
          -- RMUNJULU 24-JAN-03 2759726 Changed l_return_status to x_return_status
          x_return_status := OKL_API.G_RET_STS_ERROR;
          -- RMUNJULU 24-JAN-03 2759726 Added exit when
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

--        RMUNJULU 24-JAN-03 2759726 commented out this code
--        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
--          IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
--            x_return_status := l_return_status;
--          END IF;
--        END IF;

        -- Validating SELECT YN
        IF upper(nvl(l_qld_tbl(i).select_yn,'N')) NOT in ('Y','N') THEN
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_INVALID_VALUE,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'SELECT_YN');
          -- RMUNJULU 24-JAN-03 2759726 Changed l_return_status to x_return_status
          x_return_status := OKL_API.G_RET_STS_ERROR;
          -- RMUNJULU 24-JAN-03 2759726 Added exit when
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        ELSE
          l_qld_tbl(i).select_yn := upper(nvl(l_qld_tbl(i).select_yn,'N'));
          IF l_qld_tbl(i).select_yn = 'Y' THEN
            ln_select_count := ln_select_count + 1;
          END IF;
        END IF;

--        RMUNJULU 24-JAN-03 2759726 commented out this code
--        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
--          IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
--            x_return_status := l_return_status;
--          END IF;
--        END IF;

        -- Validating DNZ CHR ID
        OPEN  validate_chr_id_csr(p_dnz_chr_id => l_qld_tbl(i).dnz_chr_id);
        FETCH validate_chr_id_csr INTO ln_dummy2;
        IF validate_chr_id_csr%NOTFOUND THEN
          ln_dummy2 := 0;
        END IF;
        CLOSE validate_chr_id_csr;

        IF ln_dummy2 = 0 THEN
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_INVALID_VALUE,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'DNZ_CHR_ID');
          -- RMUNJULU 24-JAN-03 2759726 Changed l_return_status to x_return_status
          x_return_status := OKL_API.G_RET_STS_ERROR;
          -- RMUNJULU 24-JAN-03 2759726 Added exit when
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

--        RMUNJULU 24-JAN-03 2759726 commented out this code
--        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
--          IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
--            x_return_status := l_return_status;
--          END IF;
--        END IF;

        -- Validating Ib LINE ID
        OPEN  validate_Ib_line_csr(p_ib_id      => l_qld_tbl(i).ib_line_id,
                                   p_dnz_chr_id => l_qld_tbl(i).dnz_chr_id);
        FETCH validate_Ib_line_csr INTO ln_dummy1;
        IF validate_Ib_line_csr%NOTFOUND THEN
          ln_dummy1 := 0;
        END IF;
        CLOSE validate_Ib_line_csr;

        IF ln_dummy1 = 0 THEN
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_INVALID_VALUE,
                              p_token1        => G_COL_NAME_TOKEN,
                              p_token1_value  => 'IB_LINE_ID');
          -- RMUNJULU 24-JAN-03 2759726 Changed l_return_status to x_return_status
          x_return_status := OKL_API.G_RET_STS_ERROR;
          -- RMUNJULU 24-JAN-03 2759726 Added exit when
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

--        RMUNJULU 24-JAN-03 2759726 commented out this code
--        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
--          IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
--            x_return_status := l_return_status;
--          END IF;
--        END IF;

        -- We will validate the Financial Asset Line out of the loop, since
        -- We need to check if the count of the quote qty equal to count of select_yn = 'Y'
        ln_fin_line_id  := l_qld_tbl(i).fin_line_id;

        IF x_return_status = OKL_API.G_RET_STS_ERROR OR
           l_return_status = OKL_API.G_RET_STS_ERROR THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        ELSIF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR
              l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          EXIT WHEN (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR);
        END IF;

        EXIT WHEN (i = l_qld_tbl.LAST);

        i := l_qld_tbl.NEXT(i);

      END LOOP;

      -- RMUNJULU 24-JAN-03 2759726 Changed = to <> and 'E' to 'S'
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- Validate Fin Line id by checking the asset is Serialized
      x_return_status := check_asset_sno(p_asset_line => ln_fin_line_id,
                                         x_sno_yn     => lv_sno_yn,
                                         x_clev_tbl   => l_clev_tbl);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called check_asset_sno , x_return_status : ' || x_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'lv_sno_yn : ' || lv_sno_yn);
      END IF;

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;


      IF lv_sno_yn = OKL_API.G_TRUE THEN

        -- Check if selected assets count not the same as quote quantity
        -- RMUNJULU 09-JAN-03 2743604 Added additional condition to check if
        -- asset qty not the same as quote qty
        -- RMUNJULU 14-JAN-03 2748581 Removed the check ln_asset_qty <> ln_qte_qty
        IF  ln_select_count <> ln_qte_qty  THEN
        --AND ln_asset_qty <> ln_qte_qty THEN

          -- Asset ASSET_NUMBER is serialized. Quote quantity QUOTE_QUANTITY
          -- does not match the number of selected asset units ASSET_UNITS.
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_QTE_QTY_SRL_CNT_ERR,
                              p_token1        => 'ASSET_NUMBER',
                              p_token1_value  => lv_asset_number,
                              p_token2        => 'QUOTE_QUANTITY',
                              p_token2_value  => ln_qte_qty,
                              p_token3        => 'ASSET_UNITS',
                              p_token3_value  => ln_select_count); -- RMUNJULU 2743604

          RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

      END IF;

      p_qld_tbl := l_qld_tbl;

    ELSE -- table has no records

     -- RMUNJULU 24-JAN-03 2759726 Added set msg
     OKL_API.set_message(p_app_name      => G_APP_NAME,
                         p_msg_name      => G_INVALID_VALUE,
                         p_token1        => G_COL_NAME_TOKEN,
                         p_token1_value  => 'p_qld_tbl');

      x_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_HALT_VALIDATION');
      END IF;
      IF get_tql_csr%ISOPEN THEN
        CLOSE get_tql_csr;
      END IF;
      IF validate_chr_id_csr%ISOPEN THEN
        CLOSE validate_chr_id_csr;
      END IF;
      IF validate_Ib_line_csr%ISOPEN THEN
        CLOSE validate_Ib_line_csr;
      END IF;
      IF validate_qte_id_csr%ISOPEN THEN
        CLOSE validate_qte_id_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      IF get_tql_csr%ISOPEN THEN
        CLOSE get_tql_csr;
      END IF;
      IF validate_chr_id_csr%ISOPEN THEN
        CLOSE validate_chr_id_csr;
      END IF;
      IF validate_Ib_line_csr%ISOPEN THEN
        CLOSE validate_Ib_line_csr;
      END IF;
      IF validate_qte_id_csr%ISOPEN THEN
        CLOSE validate_qte_id_csr;
      END IF;
      -- store SQL error message on message stack
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM);
      -- notify caller of an error as UNEXPETED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_qte_ln_dtls;
--------------------------------------------------------------------------------------------------------

-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : quote_line_dtls
-- Description          : Used for creation of DML on Quote Line details record
-- Business Rules       : After Validtion of the PL/SQL table of records, If Select YN is select
--                        'Y' and tqd_id is null then we create a record in OKL_TXD_QUOTE_LINE_DTLS
--                       , If Select YN is N and tqd_id is not null then we delete the record in
--                       OKL_TXD_QUOTE_LINE_DTLS
-- Parameters           : PL/SQL table of record of qte_ln_dtl_tbl type
-- Version              : 1.0
-- History              : BAKUCHIB 10-DEC-2002 Bug 2484327 Created
-- End of Commnets

  PROCEDURE quote_line_dtls(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_qld_tbl          IN OUT NOCOPY qte_ln_dtl_tbl) IS

    l_qld_tbl               qte_ln_dtl_tbl :=p_qld_tbl ;
    l_api_name              VARCHAR2(200) := 'QUOTE_LINE_DTLS';
    i                       NUMBER := 0;
    l_tqdv_rec              tqdv_rec_type;
    lx_tqdv_rec             tqdv_rec_type;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'quote_line_dtls';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
	 IF (is_debug_statement_on) THEN
	   FOR i IN p_qld_tbl.FIRST..p_qld_tbl.LAST LOOP
	     IF (p_qld_tbl.exists(i)) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').qst_code: ' || p_qld_tbl(i).qst_code);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').qte_id: ' || p_qld_tbl(i).qte_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').instance_quantity: ' || p_qld_tbl(i).instance_quantity);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').tql_id: ' || p_qld_tbl(i).tql_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').tqd_id: ' || p_qld_tbl(i).tqd_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').select_yn: ' || p_qld_tbl(i).select_yn);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').ib_line_id: ' || p_qld_tbl(i).ib_line_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').fin_line_id: ' || p_qld_tbl(i).fin_line_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').dnz_chr_id: ' || p_qld_tbl(i).dnz_chr_id);
	     END IF;
	   END LOOP;
	 END IF;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the table of record
    validate_qte_ln_dtls(p_qld_tbl       => l_qld_tbl,
                         x_return_status => x_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called validate_qte_ln_dtls , x_return_status : ' || x_return_status);
    END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF l_qld_tbl.COUNT > 0 THEN
      i := l_qld_tbl.FIRST;
      -- looping the table of record to decide weather to
      -- Create or Delete OKL_TXD_QUOTE_LINE_DTLS record
      LOOP
        IF l_qld_tbl(i).select_yn = 'Y' AND
           (l_qld_tbl(i).tqd_id IS NULL OR
           l_qld_tbl(i).tqd_id = OKL_API.G_MISS_NUM) THEN
          l_tqdv_rec.number_of_units := l_qld_tbl(i).instance_quantity;
          l_tqdv_rec.kle_id          := l_qld_tbl(i).ib_line_id;
          l_tqdv_rec.tql_id          := l_qld_tbl(i).tql_id;
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TXD_QTE_LN_DTLS_PUB.create_txd_qte_ln_dtls');
          END IF;
          OKL_TXD_QTE_LN_DTLS_PUB.create_txd_qte_ln_dtls(
                                  p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_tqdv_rec       => l_tqdv_rec,
                                  x_tqdv_rec       => lx_tqdv_rec);
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TXD_QTE_LN_DTLS_PUB.create_txd_qte_ln_dtls , return status: ' || x_return_status);
          END IF;
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          l_qld_tbl(i).tqd_id := lx_tqdv_rec.id;
        ELSIF l_qld_tbl(i).select_yn = 'N' AND
           (l_qld_tbl(i).tqd_id IS NOT NULL OR
           l_qld_tbl(i).tqd_id <> OKL_API.G_MISS_NUM) THEN
          l_tqdv_rec.id          := l_qld_tbl(i).tqd_id;
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TXD_QTE_LN_DTLS_PUB.delete_txd_qte_ln_dtls');
          END IF;
          OKL_TXD_QTE_LN_DTLS_PUB.delete_txd_qte_ln_dtls(
                                  p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_tqdv_rec       => l_tqdv_rec);
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_TXD_QTE_LN_DTLS_PUB.delete_txd_qte_ln_dtls , return status: ' || x_return_status);
          END IF;
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          l_qld_tbl(i).tqd_id := null;
        END IF;
        EXIT WHEN (i = l_qld_tbl.LAST);
        i := l_qld_tbl.NEXT(i);
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      p_qld_tbl := l_qld_tbl;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                         x_msg_data );
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END quote_line_dtls;
--
-- BAKUCHIB Bug 2484327 end
--





  -- Start of comments
  --
  -- Function  Name  : validate_quote_line
  -- Description     : Validates quote line
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_rec
  --                   Output Parameters : x_return_status
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  --                   30-DEC-02 RMUNJULU 2726739 Changed OKC to OKL for msgs
  --                   05-FEB-03 RMUNJULU 2788257 Added code to check if type and amount null
  -- End of comments
  PROCEDURE validate_quote_line(
               p_tqlv_rec       IN tqlv_rec_type,
               x_return_status  OUT NOCOPY VARCHAR2) IS

     CURSOR get_qte_lines_csr ( p_qte_id IN NUMBER) IS
        SELECT TQL.kle_id kle_id
        FROM   OKL_TXL_QUOTE_LINES_V TQL
        WHERE  TQL.qte_id = p_qte_id
        AND    TQL.qlt_code = 'AMCFIA';


     l_kle_id_found VARCHAR2(1) := 'N';

     l_module_name VARCHAR2(500) := G_MODULE_NAME || 'validate_quote_line';
     is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
     is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
     is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.id: ' || p_tqlv_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qlt_code: ' || p_tqlv_rec.qlt_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.kle_id: ' || p_tqlv_rec.kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.sty_id: ' || p_tqlv_rec.sty_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qte_id: ' || p_tqlv_rec.qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.line_number: ' || p_tqlv_rec.line_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.amount: ' || p_tqlv_rec.amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.modified_yn: ' || p_tqlv_rec.modified_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.taxed_yn: ' || p_tqlv_rec.taxed_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.defaulted_yn: ' || p_tqlv_rec.defaulted_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.org_id: ' || p_tqlv_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.start_date: ' || p_tqlv_rec.start_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.period: ' || p_tqlv_rec.period);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.number_of_periods: ' || p_tqlv_rec.number_of_periods);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.lock_level_step: ' || p_tqlv_rec.lock_level_step);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.advance_or_arrears: ' || p_tqlv_rec.advance_or_arrears);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_name: ' || p_tqlv_rec.yield_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_value: ' || p_tqlv_rec.yield_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.implicit_interest_rate: ' || p_tqlv_rec.implicit_interest_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_value: ' || p_tqlv_rec.asset_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.residual_value: ' || p_tqlv_rec.residual_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.unbilled_receivables: ' || p_tqlv_rec.unbilled_receivables);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_quantity: ' || p_tqlv_rec.asset_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.quote_quantity: ' || p_tqlv_rec.quote_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_id: ' || p_tqlv_rec.split_kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_name: ' || p_tqlv_rec.split_kle_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_code: ' || p_tqlv_rec.currency_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_code: ' || p_tqlv_rec.currency_conversion_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_type: ' || p_tqlv_rec.currency_conversion_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_rate: ' || p_tqlv_rec.currency_conversion_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_date: ' || p_tqlv_rec.currency_conversion_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.due_date: ' || p_tqlv_rec.due_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.try_id: ' || p_tqlv_rec.try_id);
	 END IF;


    -- If no qte_id then error
    IF p_tqlv_rec.qte_id IS NULL
    OR p_tqlv_rec.qte_id = OKL_API.G_MISS_NUM THEN

      -- Required value for kle_id
      OKL_API.set_message(
                    p_app_name     => 'OKL', -- RMUNJULU 30-DEC-02 2726739
                    p_msg_name     => G_REQUIRED_VALUE,
                    p_token1       => G_COL_NAME_TOKEN,
                    p_token1_value => 'qte_id');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;


    -- If kle_id is passed
    IF  p_tqlv_rec.kle_id IS NOT NULL
    AND p_tqlv_rec.kle_id <> OKL_API.G_MISS_NUM THEN

       -- Check that kle_id passed is one of the assets quoted
       FOR get_qte_lines_rec IN get_qte_lines_csr(p_tqlv_rec.qte_id) LOOP

         IF get_qte_lines_rec.kle_id = p_tqlv_rec.kle_id THEN
            l_kle_id_found := 'Y';
         END IF;

       END LOOP;


       -- If the asset is not a quoted asset then error
       IF l_kle_id_found <> 'Y' THEN

         -- Invalid value for kle_id
         OKL_API.set_message(
                    p_app_name     => 'OKL', -- RMUNJULU 30-DEC-02 2726739
                    p_msg_name     => G_INVALID_VALUE,
                    p_token1       => G_COL_NAME_TOKEN,
                    p_token1_value => 'kle_id');

         RAISE OKL_API.G_EXCEPTION_ERROR;

       END IF;
    END IF;


    -- RMUNJULU 05-FEB-03 2788257 Added code to check if type and amount are null
    -- Check if qlt_code is NULL
    IF p_tqlv_rec.qlt_code IS NULL
    OR p_tqlv_rec.qlt_code = OKL_API.G_MISS_CHAR THEN

      -- You must enter a value for PROMPT
      OKL_API.set_message(
                 p_app_name     => OKL_API.G_APP_NAME,
                 p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                 p_token1       => 'PROMPT',
                 p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_TYPE'));

       RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    -- Check if amount is NULL
    IF p_tqlv_rec.amount IS NULL
    OR p_tqlv_rec.amount = OKL_API.G_MISS_NUM THEN

      -- You must enter a value for PROMPT
      OKL_API.set_message(
                 p_app_name     => OKL_API.G_APP_NAME,
                 p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                 p_token1       => 'PROMPT',
                 p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_AMOUNT'));

       RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN
         IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
         END IF;

         IF get_qte_lines_csr%ISOPEN THEN
            CLOSE get_qte_lines_csr;
         END IF;

         x_return_status := OKL_API.G_RET_STS_ERROR;

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

         IF get_qte_lines_csr%ISOPEN THEN
            CLOSE get_qte_lines_csr;
         END IF;

         -- unexpected error
         OKL_API.set_message(
                         p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);

          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_quote_line;



  -- Start of comments
  --
  -- Function  Name  : set_line_currency_defaults
  -- Description     : Sets the currency cols for quote line
  -- Business Rules  :
  -- Parameters      : Input parameters : px_tqlv_rec, p_sys_date
  --                   Output Parameters : x_return_status
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  --                   30-DEC-02 RMUNJULU 2699412 Added msg
  --                   31-JAN-03 RMUNJULU 2780539 changed cursor
  -- End of comments
  PROCEDURE set_line_currency_defaults(
               p_sys_date       IN DATE,
               px_tqlv_rec      IN OUT NOCOPY tqlv_rec_type,
               x_return_status  OUT NOCOPY VARCHAR2) IS


       -- get the contract id for the quote line
       -- RMUNJULU 31-JAN-03 2780539 changed cursor
       -- get the contract id for the quote, since the quote line id does not
       -- exist during create
       CURSOR get_khr_id_csr (p_qte_id IN NUMBER) IS
          SELECT QTE.khr_id khr_id
          FROM   OKL_TRX_QUOTES_V QTE
          WHERE  QTE.id = p_qte_id;

       l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
       l_functional_currency_code VARCHAR2(15);
       l_contract_currency_code VARCHAR2(15);
       l_currency_conversion_type VARCHAR2(30);
       l_currency_conversion_rate NUMBER;
       l_currency_conversion_date DATE;

       l_converted_amount NUMBER;
       l_khr_id NUMBER;

       -- Since we do not use the amount or converted amount in TRX_Quotes table
       -- set a hardcoded value for the amount (and pass to to
       -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
       -- conversion values )
       l_hard_coded_amount NUMBER := 100;
       l_module_name VARCHAR2(500) := G_MODULE_NAME || 'set_line_currency_defaults';
       is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
       is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
       is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);



  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_sys_date: ' || p_sys_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.id: ' || px_tqlv_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.qlt_code: ' || px_tqlv_rec.qlt_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.kle_id: ' || px_tqlv_rec.kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.sty_id: ' || px_tqlv_rec.sty_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.qte_id: ' || px_tqlv_rec.qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.line_number: ' || px_tqlv_rec.line_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.amount: ' || px_tqlv_rec.amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.modified_yn: ' || px_tqlv_rec.modified_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.taxed_yn: ' || px_tqlv_rec.taxed_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.defaulted_yn: ' || px_tqlv_rec.defaulted_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.org_id: ' || px_tqlv_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.start_date: ' || px_tqlv_rec.start_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.period: ' || px_tqlv_rec.period);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.number_of_periods: ' || px_tqlv_rec.number_of_periods);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.lock_level_step: ' || px_tqlv_rec.lock_level_step);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.advance_or_arrears: ' || px_tqlv_rec.advance_or_arrears);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.yield_name: ' || px_tqlv_rec.yield_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.yield_value: ' || px_tqlv_rec.yield_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.implicit_interest_rate: ' || px_tqlv_rec.implicit_interest_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.asset_value: ' || px_tqlv_rec.asset_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.residual_value: ' || px_tqlv_rec.residual_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.unbilled_receivables: ' || px_tqlv_rec.unbilled_receivables);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.asset_quantity: ' || px_tqlv_rec.asset_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.quote_quantity: ' || px_tqlv_rec.quote_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.split_kle_id: ' || px_tqlv_rec.split_kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.split_kle_name: ' || px_tqlv_rec.split_kle_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.currency_code: ' || px_tqlv_rec.currency_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.currency_conversion_code: ' || px_tqlv_rec.currency_conversion_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.currency_conversion_type: ' || px_tqlv_rec.currency_conversion_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.currency_conversion_rate: ' || px_tqlv_rec.currency_conversion_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.currency_conversion_date: ' || px_tqlv_rec.currency_conversion_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.due_date: ' || px_tqlv_rec.due_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_tqlv_rec.try_id: ' || px_tqlv_rec.try_id);
	 END IF;

     -- Get the functional currency from AM_Util
     -- RMUNJULU 30-DEC-02 2699412 changed to call right function
     l_functional_currency_code := OKL_AM_UTIL_PVT.get_functional_currency;


     -- Get the contract id for the quote line
     -- RMUNJULU 31-JAN-03 2780539 Changed to send the qte_id to cursor
     OPEN get_khr_id_csr(px_tqlv_rec.qte_id);
     FETCH get_khr_id_csr INTO l_khr_id;
     CLOSE get_khr_id_csr;


     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_ACCOUNTING_UTIL.convert_to_functional_currency');
     END IF;
     -- Get the contract currency details from ACCOUNTING_Util
     OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id  		  	          => l_khr_id,
                     p_to_currency   		        => l_functional_currency_code,
                     p_transaction_date 		    => p_sys_date,
                     p_amount 			            => l_hard_coded_amount,
                     x_return_status            => l_return_status,
                     x_contract_currency		    => l_contract_currency_code,
                     x_currency_conversion_type	=> l_currency_conversion_type,
                     x_currency_conversion_rate	=> l_currency_conversion_rate,
                     x_currency_conversion_date	=> l_currency_conversion_date,
                     x_converted_amount 		    => l_converted_amount);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_ACCOUNTING_UTIL.convert_to_functional_currency , return status: ' || l_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_contract_currency_code: ' || l_contract_currency_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_currency_conversion_type: ' || l_currency_conversion_type);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_currency_conversion_rate: ' || l_currency_conversion_rate);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_currency_conversion_date: ' || l_currency_conversion_date);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_converted_amount: ' || l_converted_amount);
     END IF;


    -- RMUNJULU 30-DEC-02 2699412 Added msg
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

       -- The currency conversion rate could not be identified for specified currency.
       OKL_API.set_message(
                  p_app_name     => 'OKL',
                  p_msg_name     => 'OKL_CONV_RATE_NOT_FOUND');

     END IF;

     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     px_tqlv_rec.currency_code := l_contract_currency_code;
     px_tqlv_rec.currency_conversion_code := l_functional_currency_code;

     -- If the functional currency is different from contract currency then set
     -- currency conversion columns
     IF l_functional_currency_code <> l_contract_currency_code THEN

        -- Set the currency conversion columns
        px_tqlv_rec.currency_conversion_type := l_currency_conversion_type;
        px_tqlv_rec.currency_conversion_rate := l_currency_conversion_rate;
        px_tqlv_rec.currency_conversion_date := l_currency_conversion_date;

     END IF;

     -- Set the return status
     x_return_status := l_return_status;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN
         IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
         END IF;

         IF get_khr_id_csr%ISOPEN THEN
            CLOSE get_khr_id_csr;
         END IF;

         x_return_status := OKL_API.G_RET_STS_ERROR;

     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
         END IF;

         IF get_khr_id_csr%ISOPEN THEN
            CLOSE get_khr_id_csr;
         END IF;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

         IF get_khr_id_csr%ISOPEN THEN
            CLOSE get_khr_id_csr;
         END IF;

         -- unexpected error
         OKL_API.set_message(
                         p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);

          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END set_line_currency_defaults;


  -- Start of comments
  --
  -- Function  Name  : create_quote_line
  -- Description     : Creates quote line
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_rec
  --                   Output Parameters : X_tqlv_rec
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  --                 : 11-Jan-05 PAGARG Bug 4104815 Added call to recalculate_quote
  --                 : rmunjulu Sales_Tax_Enhancement
  -- End of comments
  PROCEDURE create_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type,
               x_tqlv_rec       OUT NOCOPY tqlv_rec_type) IS


    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_tqlv_rec tqlv_rec_type := p_tqlv_rec;
    lx_tqlv_rec tqlv_rec_type := p_tqlv_rec;
    l_api_name VARCHAR2(30) := 'create_quote_line';
    l_api_version CONSTANT NUMBER := 1;
    l_sys_date DATE;

    -- Added by rravikir (eBTax enhancement) Bug 5866207
    CURSOR get_try_id_csr (p_trx_name IN VARCHAR2) IS
    SELECT try.id
    FROM   okl_trx_types_v try
    WHERE  try.name = p_trx_name;

    l_try_id NUMBER;
    -- End (eBTax enhancement) Bug 5866207
     --akrangan Bug# 5485331:Start
      -- get the max line_number within a quote
     CURSOR get_max_tql_line_num_csr(p_qte_id IN NUMBER) IS
	 select max(line_number) from OKL_TXL_QUOTE_LINES_B
	 where qte_id = p_qte_id;
     l_new_line_number NUMBER;
     --akrangan Bug# 5485331:End
     l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_quote_line';
     is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
     is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
     is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.id: ' || p_tqlv_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qlt_code: ' || p_tqlv_rec.qlt_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.kle_id: ' || p_tqlv_rec.kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.sty_id: ' || p_tqlv_rec.sty_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qte_id: ' || p_tqlv_rec.qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.line_number: ' || p_tqlv_rec.line_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.amount: ' || p_tqlv_rec.amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.modified_yn: ' || p_tqlv_rec.modified_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.taxed_yn: ' || p_tqlv_rec.taxed_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.defaulted_yn: ' || p_tqlv_rec.defaulted_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.org_id: ' || p_tqlv_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.start_date: ' || p_tqlv_rec.start_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.period: ' || p_tqlv_rec.period);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.number_of_periods: ' || p_tqlv_rec.number_of_periods);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.lock_level_step: ' || p_tqlv_rec.lock_level_step);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.advance_or_arrears: ' || p_tqlv_rec.advance_or_arrears);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_name: ' || p_tqlv_rec.yield_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_value: ' || p_tqlv_rec.yield_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.implicit_interest_rate: ' || p_tqlv_rec.implicit_interest_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_value: ' || p_tqlv_rec.asset_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.residual_value: ' || p_tqlv_rec.residual_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.unbilled_receivables: ' || p_tqlv_rec.unbilled_receivables);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_quantity: ' || p_tqlv_rec.asset_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.quote_quantity: ' || p_tqlv_rec.quote_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_id: ' || p_tqlv_rec.split_kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_name: ' || p_tqlv_rec.split_kle_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_code: ' || p_tqlv_rec.currency_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_code: ' || p_tqlv_rec.currency_conversion_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_type: ' || p_tqlv_rec.currency_conversion_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_rate: ' || p_tqlv_rec.currency_conversion_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_date: ' || p_tqlv_rec.currency_conversion_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.due_date: ' || p_tqlv_rec.due_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.try_id: ' || p_tqlv_rec.try_id);
	 END IF;
     --Check API version, initialize message list and create savepoint.
     l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                               G_PKG_NAME,
                                               p_init_msg_list,
                                               l_api_version,
                                               p_api_version,
                                               '_PVT',
                                               x_return_status);

     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    SELECT SYSDATE INTO l_sys_date FROM DUAL;

     -- Validate the quote line
     validate_quote_line(
                  p_tqlv_rec      => lp_tqlv_rec,
                  x_return_status => l_return_status);

     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- Set the quote line currency columns
     set_line_currency_defaults(
                  p_sys_date      => l_sys_date,
                  px_tqlv_rec     => lp_tqlv_rec,
                  x_return_status => l_return_status);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called  set_line_currency_defaults , return status: ' || l_return_status);
     END IF;

     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- Added by rravikir (eBTax enhancement) Bug 5866207
     OPEN  get_try_id_csr ('Estimated Billing');
     FETCH get_try_id_csr INTO l_try_id;
	 CLOSE get_try_id_csr;

     lp_tqlv_rec.try_id := l_try_id;
     -- End (eBTax enhancement) Bug 5866207
    -- akrangan Bug# 5468781:Start
     IF lp_tqlv_rec.LINE_NUMBER IS NULL OR lp_tqlv_rec.LINE_NUMBER = OKL_API.G_MISS_NUM THEN
     -- get current max line number and increment it by one as the new line#
	 OPEN get_max_tql_line_num_csr (lp_tqlv_rec.QTE_ID);
	 FETCH get_max_tql_line_num_csr INTO l_new_line_number;

	 IF get_max_tql_line_num_csr%NOTFOUND THEN
	   l_new_line_number := 1;
	 ELSE
	   l_new_line_number := l_new_line_number + 1;
	 END IF;

	 CLOSE get_max_tql_line_num_csr;

	 lp_tqlv_rec.line_number := l_new_line_number;
     END IF;
   --akrangan Bug# 5468781:End
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TXL_QUOTE_LINES_PUB.insert_txl_quote_lines');
     END IF;
     -- Insert line into table using TAPI
     OKL_TXL_QUOTE_LINES_PUB.insert_txl_quote_lines(
                               p_api_version   => p_api_version,
                               p_init_msg_list => G_FALSE,
                               x_return_status => l_return_status,
                               x_msg_count     => x_msg_count,
                               x_msg_data      => x_msg_data,
                               p_tqlv_rec      => lp_tqlv_rec,
                               x_tqlv_rec      => lx_tqlv_rec);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called  OKL_TXL_QUOTE_LINES_PUB.insert_txl_quote_lines , return status: ' || l_return_status);
     END IF;

     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax');
     END IF;
    -- rmunjulu Sales_Tax_Enhancement
    -- Call the new OKL Tax engine to RECALCULATE tax for all quote lines
	OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax(
    	p_api_version          => l_api_version,
    	p_init_msg_list        => OKL_API.G_FALSE,
    	x_return_status        => l_return_status,
    	x_msg_count            => x_msg_count,
    	x_msg_data             => x_msg_data,
    	p_source_trx_id		   => lx_tqlv_rec.qte_id, -- TRX_ID is QUOTE_ID
    	p_source_trx_name      => 'Estimated Billing',	-- TRX_NAME IS NULL
    	p_source_table         => 'OKL_TRX_QUOTES_B');  -- SOURCE_TABLE IS OKL_TRX_QUOTES_B
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax , return status: ' || l_return_status);
     END IF;

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        -- Tax Processing failed.
        OKL_API.set_message( p_app_name      => 'OKL',
                             p_msg_name      =>'OKL_AM_PROCESS_TAX_ERR');
      END IF;

     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- PAGARG 4102565 Recalculate quote header elements and update quote header
     recalculate_quote(
               x_return_status  => l_return_status,
               p_tqlv_rec       => lx_tqlv_rec);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called recalculate_quote , return status: ' || l_return_status);
     END IF;

     -- PAGARG 4102565 raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
     THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
     THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- set the return status and out variables
     x_return_status := l_return_status;
     x_tqlv_rec      := lx_tqlv_rec;

     -- end the transaction
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;

      IF (get_try_id_csr%isopen) THEN
        CLOSE get_try_id_csr;
      END IF;

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
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      IF (get_try_id_csr%isopen) THEN
        CLOSE get_try_id_csr;
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

      IF (get_try_id_csr%isopen) THEN
        CLOSE get_try_id_csr;
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  END create_quote_line ;


  -- Start of comments
  --
  -- Function  Name  : create_quote_line
  -- Description     : Creates multiple quote lines
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_tbl
  --                   Output Parameters : x_tqlv_tbl
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  -- End of comments
  PROCEDURE create_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_tbl       IN tqlv_tbl_type,
               x_tqlv_tbl       OUT NOCOPY tqlv_tbl_type) IS



    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_tqlv_tbl tqlv_tbl_type := p_tqlv_tbl;
    lx_tqlv_tbl tqlv_tbl_type := p_tqlv_tbl;
    l_api_name VARCHAR2(30) := 'create_quote_line';
    l_api_version CONSTANT NUMBER := 1;
    i NUMBER;

    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_quote_line';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl.COUNT: ' || p_tqlv_tbl.COUNT);
	 END IF;

     --Check API version, initialize message list and create savepoint.
     l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                               G_PKG_NAME,
                                               p_init_msg_list,
                                               l_api_version,
                                               p_api_version,
                                               '_PVT',
                                               x_return_status);


     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


     -- Loop thru the input tbl and call the rec type API
     IF (lp_tqlv_tbl.COUNT > 0) THEN

       i := lp_tqlv_tbl.FIRST;

       LOOP

         -- Insert line into table using rec type API
         create_quote_line(
               p_api_version   => p_api_version,
               p_init_msg_list => G_FALSE,
               x_return_status => l_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_tqlv_rec      => lp_tqlv_tbl(i),
               x_tqlv_rec      => lx_tqlv_tbl(i));
         IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called create_quote_line , return status: ' || l_return_status);
         END IF;

         -- raise exception if error
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         EXIT WHEN (i = lp_tqlv_tbl.LAST);
         i := lp_tqlv_tbl.NEXT(i);
       END LOOP;

     END IF;


     -- set the return status and out variables
     x_return_status := l_return_status;
     x_tqlv_tbl      := lx_tqlv_tbl;


     -- end the transaction
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION


    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;

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
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  END create_quote_line ;


  -- Start of comments
  --
  -- Function  Name  : update_quote_line
  -- Description     : Updates quote line
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_rec
  --                   Output Parameters : X_tqlv_rec
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  --                   16-JAN-03 RMUNJULU 2754574 Added quote status condition
  -- GKADARKA bug 3825037, default currency_conversion_date, start_date, creation_date and
  -- program_update_date to NULL/G_MISS_DATE so that correct date is stamped.
  -- issue occurs when g_miss_date passed from rossetta layer does not match okl_api.g_miss_date
  --                 : PAGARG 4102565 Added call to validate_upd_quote_line to validate the amounts
  --                 : PAGARG 4102565 Added call to recalculate_quote
  --                 : rmunjulu Sales_Tax_Enhancement
  -- End of comments
  PROCEDURE update_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type,
               x_tqlv_rec       OUT NOCOPY tqlv_rec_type) IS


    -- RMUNJULU 16-JAN-03 2754574   Added cursor to get quote status
    -- Get the quote details
    CURSOR get_quote_dtls_csr ( p_tql_id IN NUMBER) IS
        SELECT QTE.qst_code,
        	   QTE.id qte_id, -- rmunjulu Sales_Tax_Enhancement
               TQL.amount -- rmunjulu Sales_Tax_Enhancement
        FROM   OKL_TRX_QUOTES_V QTE,
               OKL_TXL_QUOTE_LINES_V TQL
        WHERE  TQL.id = p_tql_id
        AND    TQL.qte_id = QTE.id;

    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_tqlv_rec tqlv_rec_type := p_tqlv_rec;
    lx_tqlv_rec tqlv_rec_type := p_tqlv_rec;
    l_api_name VARCHAR2(30) := 'update_quote_line';
    l_api_version CONSTANT NUMBER := 1;

    -- RMUNJULU 16-JAN-03 2754574 Added variable
    l_qst_code VARCHAR2(30);

    -- rmunjulu Sales_Tax_Enhancement
    CURSOR get_try_id_csr (p_trx_name IN VARCHAR2) IS
    SELECT try.id
    FROM   okl_trx_types_v try
    WHERE  try.name = p_trx_name;

    -- rmunjulu Sales_Tax_Enhancement
    l_qte_id NUMBER;
    l_amount NUMBER;
    l_try_id NUMBER;
    l_trx_name okl_trx_types_v.name%TYPE;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'update_quote_line';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.id: ' || p_tqlv_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qlt_code: ' || p_tqlv_rec.qlt_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.kle_id: ' || p_tqlv_rec.kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.sty_id: ' || p_tqlv_rec.sty_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qte_id: ' || p_tqlv_rec.qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.line_number: ' || p_tqlv_rec.line_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.amount: ' || p_tqlv_rec.amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.modified_yn: ' || p_tqlv_rec.modified_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.taxed_yn: ' || p_tqlv_rec.taxed_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.defaulted_yn: ' || p_tqlv_rec.defaulted_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.org_id: ' || p_tqlv_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.start_date: ' || p_tqlv_rec.start_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.period: ' || p_tqlv_rec.period);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.number_of_periods: ' || p_tqlv_rec.number_of_periods);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.lock_level_step: ' || p_tqlv_rec.lock_level_step);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.advance_or_arrears: ' || p_tqlv_rec.advance_or_arrears);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_name: ' || p_tqlv_rec.yield_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_value: ' || p_tqlv_rec.yield_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.implicit_interest_rate: ' || p_tqlv_rec.implicit_interest_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_value: ' || p_tqlv_rec.asset_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.residual_value: ' || p_tqlv_rec.residual_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.unbilled_receivables: ' || p_tqlv_rec.unbilled_receivables);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_quantity: ' || p_tqlv_rec.asset_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.quote_quantity: ' || p_tqlv_rec.quote_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_id: ' || p_tqlv_rec.split_kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_name: ' || p_tqlv_rec.split_kle_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_code: ' || p_tqlv_rec.currency_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_code: ' || p_tqlv_rec.currency_conversion_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_type: ' || p_tqlv_rec.currency_conversion_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_rate: ' || p_tqlv_rec.currency_conversion_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_date: ' || p_tqlv_rec.currency_conversion_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.due_date: ' || p_tqlv_rec.due_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.try_id: ' || p_tqlv_rec.try_id);
	 END IF;

     --Check API version, initialize message list and create savepoint.
     l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                               G_PKG_NAME,
                                               p_init_msg_list,
                                               l_api_version,
                                               p_api_version,
                                               '_PVT',
                                               x_return_status);

     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- RMUNJULU 16-JAN-03 2754574 Added code to get quote status and check if
     -- DRAFTED or REJECTED.
     -- Get the quote status
     FOR get_quote_dtls_rec IN get_quote_dtls_csr(p_tqlv_rec.id) LOOP

         l_qst_code := get_quote_dtls_rec.qst_code;
         l_qte_id := get_quote_dtls_rec.qte_id; -- rmunjulu Sales_Tax_Enhancement
         l_amount := get_quote_dtls_rec.amount; -- rmunjulu Sales_Tax_Enhancement

     END LOOP;

     -- If the quote is not DRAFTED or REJECTED, can not delete lines.
     IF l_qst_code NOT IN ('DRAFTED','REJECTED' ) THEN

        -- Quote status must be either Drafted or Rejected.
        OKL_API.set_message (
              			 p_app_name  	  => 'OKL',
              			 p_msg_name  	  => 'OKL_AM_SUBMIT_FOR_APPROVAL');

        RAISE OKL_API.G_EXCEPTION_ERROR;

     END IF;

    -- GKADARKA bug 3825037, default currency_conversion_date, start_date, creation_date and
    -- program_update_date to NULL/G_MISS_DATE so that correct date is stamped.
    -- issue occurs when g_miss_date passed from rossetta layer does not match okl_api.g_miss_date

     lp_tqlv_rec.currency_conversion_date := OKL_API.G_MISS_DATE;
     lp_tqlv_rec.creation_date := OKL_API.G_MISS_DATE;
     lp_tqlv_rec.start_date := null;
     lp_tqlv_rec.program_update_date := null;

     -- PAGARG 4102565 Added validate quote line to check for rules during updates
     validate_upd_quote_line(
         x_return_status  => l_return_status,
         p_tqlv_rec       => lp_tqlv_rec);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called validate_upd_quote_line , return status: ' || l_return_status);
     END IF;

     -- PAGARG 4102565 raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
     THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
     THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- rmunjulu Sales_Tax_Enhancement
     IF l_amount >= 0 THEN

		   l_trx_name := 'Estimated Billing';

		   --get and set try_id with try_id of billing transaction
		   OPEN  get_try_id_csr (l_trx_name );
		   FETCH get_try_id_csr INTO l_try_id;
		   CLOSE get_try_id_csr;

     ELSE -- amount < 0

		   l_trx_name := 'Estimated Billing';

		   --get and set try_id with try_id of billing transaction
		   OPEN  get_try_id_csr (l_trx_name );
		   FETCH get_try_id_csr INTO l_try_id;
		   CLOSE get_try_id_csr;

 	 END IF;

     -- rmunjulu Sales_Tax_Enhancement
     lp_tqlv_rec.try_id := l_try_id;

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TXL_QUOTE_LINES_PUB.update_txl_quote_lines');
     END IF;
     -- Insert line into table using TAPI
     OKL_TXL_QUOTE_LINES_PUB.update_txl_quote_lines(
                               p_api_version   => p_api_version,
                               p_init_msg_list => G_FALSE,
                               x_return_status => l_return_status,
                               x_msg_count     => x_msg_count,
                               x_msg_data      => x_msg_data,
                               p_tqlv_rec      => lp_tqlv_rec,
                               x_tqlv_rec      => lx_tqlv_rec);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_TXL_QUOTE_LINES_PUB.update_txl_quote_lines , return status: ' || l_return_status);
     END IF;

     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax');
     END IF;
    -- rmunjulu Sales_Tax_Enhancement
    -- Call the new OKL Tax engine to RECALCULATE tax for all quote lines
	OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax(
    	p_api_version          => l_api_version,
    	p_init_msg_list        => OKL_API.G_FALSE,
    	x_return_status        => l_return_status,
    	x_msg_count            => x_msg_count,
    	x_msg_data             => x_msg_data,
    	p_source_trx_id		   => l_qte_id, -- TRX_ID is QUOTE_ID
    	p_source_trx_name      => 'Estimated Billing',	-- TRX_NAME IS NULL
    	p_source_table         => 'OKL_TRX_QUOTES_B');  -- SOURCE_TABLE IS OKL_TRX_QUOTES_B
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax , return status: ' || l_return_status);
     END IF;

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        -- Tax Processing failed.
        OKL_API.set_message( p_app_name      => 'OKL',
                             p_msg_name      =>'OKL_AM_PROCESS_TAX_ERR');
      END IF;

     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- PAGARG 4102565 Recalculate quote header elements and update quote header
     recalculate_quote(
         x_return_status  => l_return_status,
         p_tqlv_rec       => lx_tqlv_rec);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called recalculate_quote , return status: ' || l_return_status);
     END IF;

     -- PAGARG 4102565  raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
     THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
     THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- set the return status and out variables
     x_return_status := l_return_status;
     x_tqlv_rec      := lx_tqlv_rec;

     -- end the transaction
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;

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
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  END update_quote_line ;


  -- Start of comments
  --
  -- Function  Name  : update_quote_line
  -- Description     : Updates multiple quote lines
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_tbl
  --                   Output Parameters : x_tqlv_tbl
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  -- End of comments
  PROCEDURE update_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_tbl       IN tqlv_tbl_type,
               x_tqlv_tbl       OUT NOCOPY tqlv_tbl_type) IS



    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_tqlv_tbl tqlv_tbl_type := p_tqlv_tbl;
    lx_tqlv_tbl tqlv_tbl_type := p_tqlv_tbl;
    l_api_name VARCHAR2(30) := 'update_quote_line';
    l_api_version CONSTANT NUMBER := 1;
    i NUMBER;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'update_quote_line';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl.COUNT: ' || p_tqlv_tbl.COUNT);
	 END IF;

     --Check API version, initialize message list and create savepoint.
     l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                               G_PKG_NAME,
                                               p_init_msg_list,
                                               l_api_version,
                                               p_api_version,
                                               '_PVT',
                                               x_return_status);


     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


     -- Loop thru the input tbl and call the rec type API
     IF (lp_tqlv_tbl.COUNT > 0) THEN

       i := lp_tqlv_tbl.FIRST;

       LOOP

         -- Update line of table using rec type API
         update_quote_line(
               p_api_version   => p_api_version,
               p_init_msg_list => G_FALSE,
               x_return_status => l_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_tqlv_rec      => lp_tqlv_tbl(i),
               x_tqlv_rec      => lx_tqlv_tbl(i));
         IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called update_quote_line , return status: ' || l_return_status);
         END IF;

         -- raise exception if error
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         EXIT WHEN (i = lp_tqlv_tbl.LAST);
         i := lp_tqlv_tbl.NEXT(i);
       END LOOP;

     END IF;


     -- set the return status and out variables
     x_return_status := l_return_status;
     x_tqlv_tbl      := lx_tqlv_tbl;


     -- end the transaction
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION


    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;

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
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  END update_quote_line ;


  -- Start of comments
  --
  -- Function  Name  : get_quote_units
  -- Description     : Returns the quote units for the TQL id passed
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tql_id
  --                   Output Parameters : x_unit_tbl
  -- Version         : 1.0
  -- History         : RMUNJULU 08-JAN-03 2736865 Created
  -- End of comments
  PROCEDURE get_quote_units(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tql_id         IN NUMBER,
               x_unit_tbl       OUT NOCOPY unit_tbl_type) IS



       -- Cursor to check if quote units exists
       CURSOR check_quote_units_exist_csr( p_tql_id IN NUMBER) IS
         SELECT TQD.id
         FROM   OKL_TXD_QUOTE_LINE_DTLS TQD
         WHERE  TQD.tql_id = p_tql_id;


      -- Cursor to return data when quote units not populated -- get from IB INST
       CURSOR get_ib_instances_csr( p_tql_id IN NUMBER) IS
          SELECT QTE.QUOTE_NUMBER QUOTE_NUMBER,
                 QTE.QST_CODE QST_CODE,
                 QTE.QTP_CODE QTP_CODE,
                 TQL.ID TQL_ID,
                 NULL TQD_ID,
                 TQL.ASSET_QUANTITY ASSET_QUANTITY,
                 TQL.QUOTE_QUANTITY QUOTE_QUANTITY,
                 CLE_IB.ID IB_LINE_ID,
                 CLE_FIN.ID FIN_LINE_ID,
                 CLE_FIN.DNZ_CHR_ID DNZ_CHR_ID,
                 CSI.SERIAL_NUMBER SERIAL_NUMBER,
                 CSI.QUANTITY INSTANCE_QUANTITY,
                 CSI.INSTANCE_NUMBER INSTANCE_NUMBER,
                 CLET_FIN.NAME ASSET_NUMBER,
                 CLET_FIN.ITEM_DESCRIPTION ASSET_DESCRIPTION,
                 SUBSTR(ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS(NULL,
                                                          HL.ADDRESS1,
                                                          HL.ADDRESS2,
                                                          HL.ADDRESS3,
                                                          HL.ADDRESS4,
                                                          HL.CITY,
                                                          HL.COUNTY,
                                                          HL.STATE,
                                                          HL.PROVINCE,
                                                          HL.POSTAL_CODE,
                                                          NULL,
                                                          HL.COUNTRY,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          'N',
                                                          'N',
                                                          80,1,1),1,80) LOCATION_DESCRIPTION,
                  QTE.ID QTE_ID
          FROM HZ_LOCATIONS HL,
               HZ_PARTY_SITES HPS,
               HZ_PARTY_SITE_USES HPSU,
               CSI_ITEM_INSTANCES CSI,
               OKC_K_ITEMS CIM_IB,
               OKC_LINE_STYLES_B LSE_IB,
               OKC_K_LINES_B CLE_IB,
               OKC_LINE_STYLES_B LSE_INST,
               OKC_K_LINES_B CLE_INST,
               OKC_LINE_STYLES_B LSE_FIN,
               OKL_TXL_QUOTE_LINES_B TQL,
               OKL_TRX_QUOTES_B QTE,
               OKC_K_LINES_TL CLET_FIN,
               OKC_K_LINES_B CLE_FIN
         WHERE CLE_FIN.CLE_ID IS NULL
         AND   CLE_FIN.CHR_ID = CLE_FIN.DNZ_CHR_ID
         AND   CLE_FIN.ID = CLET_FIN.ID
         AND   CLET_FIN.LANGUAGE = USERENV('LANG')
         AND   CLE_FIN.ID = TQL.KLE_ID
         AND   TQL.QLT_CODE = 'AMCFIA'
         AND   LSE_FIN.ID = CLE_FIN.LSE_ID
         AND   LSE_FIN.LTY_CODE = 'FREE_FORM1'
         AND   CLE_INST.CLE_ID = CLE_FIN.ID
         AND   CLE_INST.LSE_ID = LSE_INST.ID
         AND   LSE_INST.LTY_CODE = 'FREE_FORM2'
         AND   CLE_IB.CLE_ID = CLE_INST.ID
         AND   CLE_IB.LSE_ID = LSE_IB.ID
         AND   LSE_IB.LTY_CODE = 'INST_ITEM'
         AND   CIM_IB.CLE_ID = CLE_IB.ID
         AND   CIM_IB.OBJECT1_ID1 = CSI.INSTANCE_ID
         AND   CIM_IB.OBJECT1_ID2 = '#'
         AND   CIM_IB.JTOT_OBJECT1_CODE = 'OKX_IB_ITEM'
         AND   CSI.INSTALL_LOCATION_ID = HPSU.PARTY_SITE_ID
         AND   HPSU.SITE_USE_TYPE = 'INSTALL_AT'
         AND   HPSU.PARTY_SITE_ID = HPS.PARTY_SITE_ID
         AND   HPS.LOCATION_ID = HL.LOCATION_ID
         AND   TQL.QTE_ID = QTE.ID
         AND   TQL.ID = p_tql_id;


      -- Cursor to return data when quote units populated -- get from TQD
       CURSOR get_quote_units_csr( p_tql_id IN NUMBER) IS
          SELECT QTE.QUOTE_NUMBER QUOTE_NUMBER,
                 QTE.QST_CODE QST_CODE,
                 QTE.QTP_CODE QTP_CODE,
                 TQL.ID TQL_ID,
                 TQD.ID TQD_ID,
                 TQL.ASSET_QUANTITY ASSET_QUANTITY,
                 TQL.QUOTE_QUANTITY QUOTE_QUANTITY,
                 CLE_IB.ID IB_LINE_ID,
                 CLE_FIN.ID FIN_LINE_ID,
                 CLE_FIN.DNZ_CHR_ID DNZ_CHR_ID,
                 CSI.SERIAL_NUMBER SERIAL_NUMBER,
                 CSI.QUANTITY INSTANCE_QUANTITY,
                 CSI.INSTANCE_NUMBER INSTANCE_NUMBER,
                 CLET_FIN.NAME ASSET_NUMBER,
                 CLET_FIN.ITEM_DESCRIPTION ASSET_DESCRIPTION,
                 SUBSTR(ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS(NULL,
                                                          HL.ADDRESS1,
                                                          HL.ADDRESS2,
                                                          HL.ADDRESS3,
                                                          HL.ADDRESS4,
                                                          HL.CITY,
                                                          HL.COUNTY,
                                                          HL.STATE,
                                                          HL.PROVINCE,
                                                          HL.POSTAL_CODE,
                                                          NULL,
                                                          HL.COUNTRY,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          'N',
                                                          'N',
                                                          80,1,1),1,80) LOCATION_DESCRIPTION,
                  QTE.ID QTE_ID
          FROM HZ_LOCATIONS HL,
               HZ_PARTY_SITES HPS,
               HZ_PARTY_SITE_USES HPSU,
               CSI_ITEM_INSTANCES CSI,
               OKC_K_ITEMS CIM_IB,
               OKC_LINE_STYLES_B LSE_IB,
               OKC_K_LINES_B CLE_IB,
               OKC_LINE_STYLES_B LSE_INST,
               OKC_K_LINES_B CLE_INST,
               OKC_LINE_STYLES_B LSE_FIN,
               OKL_TXL_QUOTE_LINES_B TQL,
               OKL_TRX_QUOTES_B QTE,
               OKC_K_LINES_TL CLET_FIN,
               OKC_K_LINES_B CLE_FIN,
               OKL_TXD_QUOTE_LINE_DTLS TQD
         WHERE CLE_FIN.CLE_ID IS NULL
         AND   CLE_FIN.CHR_ID = CLE_FIN.DNZ_CHR_ID
         AND   CLE_FIN.ID = CLET_FIN.ID
         AND   CLET_FIN.LANGUAGE = USERENV('LANG')
         AND   CLE_FIN.ID = TQL.KLE_ID
         AND   TQL.QLT_CODE = 'AMCFIA'
         AND   LSE_FIN.ID = CLE_FIN.LSE_ID
         AND   LSE_FIN.LTY_CODE = 'FREE_FORM1'
         AND   CLE_INST.CLE_ID = CLE_FIN.ID
         AND   CLE_INST.LSE_ID = LSE_INST.ID
         AND   LSE_INST.LTY_CODE = 'FREE_FORM2'
         AND   CLE_IB.CLE_ID = CLE_INST.ID
         AND   CLE_IB.LSE_ID = LSE_IB.ID
         AND   LSE_IB.LTY_CODE = 'INST_ITEM'
         AND   CIM_IB.CLE_ID = CLE_IB.ID
         AND   CIM_IB.OBJECT1_ID1 = CSI.INSTANCE_ID
         AND   CIM_IB.OBJECT1_ID2 = '#'
         AND   CIM_IB.JTOT_OBJECT1_CODE = 'OKX_IB_ITEM'
         AND   CSI.INSTALL_LOCATION_ID = HPSU.PARTY_SITE_ID
         AND   HPSU.SITE_USE_TYPE = 'INSTALL_AT'
         AND   HPSU.PARTY_SITE_ID = HPS.PARTY_SITE_ID
         AND   HPS.LOCATION_ID = HL.LOCATION_ID
         AND   TQL.QTE_ID = QTE.ID
         AND   TQD.TQL_ID = TQL.ID
         AND   TQD.KLE_ID = CLE_IB.ID
         AND   TQL.ID = p_tql_id;

      l_unit_tbl unit_tbl_type;
      i NUMBER;
      l_id NUMBER;
      l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_api_name VARCHAR2(30) := 'get_quote_units';
      l_api_version NUMBER := 1;

    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_quote_units';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tql_id: ' || p_tql_id);
	 END IF;

     --Check API version, initialize message list and create savepoint.
     l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                               G_PKG_NAME,
                                               p_init_msg_list,
                                               l_api_version,
                                               p_api_version,
                                               '_PVT',
                                               x_return_status);


     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


     -- Check if tqd populated
     OPEN check_quote_units_exist_csr(p_tql_id);
     FETCH check_quote_units_exist_csr INTO l_id;

     -- if TQD populated then use TQD cursor
     IF check_quote_units_exist_csr%FOUND THEN

       i := 0;

       -- for the quote units set the quote units tbl
       FOR get_quote_units_rec IN get_quote_units_csr(p_tql_id) LOOP

         -- Set the unit tbl with cursor values
         l_unit_tbl(i).quote_number := get_quote_units_rec.quote_number;
         l_unit_tbl(i).qst_code := get_quote_units_rec.qst_code;
         l_unit_tbl(i).qtp_code := get_quote_units_rec.qtp_code;
         l_unit_tbl(i).tql_id := get_quote_units_rec.tql_id;
         l_unit_tbl(i).tqd_id := get_quote_units_rec.tqd_id;
         l_unit_tbl(i).asset_quantity := get_quote_units_rec.asset_quantity;
         l_unit_tbl(i).quote_quantity := get_quote_units_rec.quote_quantity;
         l_unit_tbl(i).ib_line_id := get_quote_units_rec.ib_line_id;
         l_unit_tbl(i).fin_line_id := get_quote_units_rec.fin_line_id;
         l_unit_tbl(i).dnz_chr_id := get_quote_units_rec.dnz_chr_id;
         l_unit_tbl(i).serial_number := get_quote_units_rec.serial_number;
         l_unit_tbl(i).instance_quantity := get_quote_units_rec.instance_quantity;
         l_unit_tbl(i).instance_number := get_quote_units_rec.instance_number;
         l_unit_tbl(i).asset_number := get_quote_units_rec.asset_number;
         l_unit_tbl(i).asset_description := get_quote_units_rec.asset_description;
         l_unit_tbl(i).location_description := get_quote_units_rec.location_description;
         l_unit_tbl(i).qte_id := get_quote_units_rec.qte_id;

         i := i + 1;

       END LOOP;

     ELSE -- TQD not populated use IB cursor

       i := 0;

       -- for the IB lines set the quote units tbl
       FOR get_ib_instances_rec IN get_ib_instances_csr(p_tql_id) LOOP

         -- Set the unit tbl with cursor values
         l_unit_tbl(i).quote_number := get_ib_instances_rec.quote_number;
         l_unit_tbl(i).qst_code := get_ib_instances_rec.qst_code;
         l_unit_tbl(i).qtp_code := get_ib_instances_rec.qtp_code;
         l_unit_tbl(i).tql_id := get_ib_instances_rec.tql_id;
         l_unit_tbl(i).tqd_id := get_ib_instances_rec.tqd_id;
         l_unit_tbl(i).asset_quantity := get_ib_instances_rec.asset_quantity;
         l_unit_tbl(i).quote_quantity := get_ib_instances_rec.quote_quantity;
         l_unit_tbl(i).ib_line_id := get_ib_instances_rec.ib_line_id;
         l_unit_tbl(i).fin_line_id := get_ib_instances_rec.fin_line_id;
         l_unit_tbl(i).dnz_chr_id := get_ib_instances_rec.dnz_chr_id;
         l_unit_tbl(i).serial_number := get_ib_instances_rec.serial_number;
         l_unit_tbl(i).instance_quantity := get_ib_instances_rec.instance_quantity;
         l_unit_tbl(i).instance_number := get_ib_instances_rec.instance_number;
         l_unit_tbl(i).asset_number := get_ib_instances_rec.asset_number;
         l_unit_tbl(i).asset_description := get_ib_instances_rec.asset_description;
         l_unit_tbl(i).location_description := get_ib_instances_rec.location_description;
         l_unit_tbl(i).qte_id := get_ib_instances_rec.qte_id;

         i := i + 1;

       END LOOP;

     END IF;
     CLOSE check_quote_units_exist_csr;

     -- Set the return variables
     x_return_status := l_return_status;
     x_unit_tbl := l_unit_tbl;

     -- end the transaction
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION


    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;

      IF check_quote_units_exist_csr%ISOPEN THEN
        CLOSE check_quote_units_exist_csr;
      END IF;

      IF get_ib_instances_csr%ISOPEN THEN
        CLOSE get_ib_instances_csr;
      END IF;

      IF get_quote_units_csr%ISOPEN THEN
        CLOSE get_quote_units_csr;
      END IF;

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
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      IF check_quote_units_exist_csr%ISOPEN THEN
        CLOSE check_quote_units_exist_csr;
      END IF;

      IF get_ib_instances_csr%ISOPEN THEN
        CLOSE get_ib_instances_csr;
      END IF;

      IF get_quote_units_csr%ISOPEN THEN
        CLOSE get_quote_units_csr;
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

      IF check_quote_units_exist_csr%ISOPEN THEN
        CLOSE check_quote_units_exist_csr;
      END IF;

      IF get_ib_instances_csr%ISOPEN THEN
        CLOSE get_ib_instances_csr;
      END IF;

      IF get_quote_units_csr%ISOPEN THEN
        CLOSE get_quote_units_csr;
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  END get_quote_units;



  -- Start of comments
  --
  -- Function  Name  : delete_quote_line
  -- Description     : Deletes quote line
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_rec
  -- Version         : 1.0
  -- History         : 16-JAN-03 RMUNJULU 2754574 Created
  --                 : rmunjulu Sales_Tax_Enhancement
  -- End of comments
  PROCEDURE delete_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type) IS


    -- Get the quote details
    CURSOR get_quote_dtls_csr ( p_tql_id IN NUMBER) IS
        SELECT QTE.qst_code,
        	   QTE.id qte_id -- rmunjulu Sales_Tax_Enhancement
        FROM   OKL_TRX_QUOTES_V QTE,
               OKL_TXL_QUOTE_LINES_V TQL
        WHERE  TQL.id = p_tql_id
        AND    TQL.qte_id = QTE.id;


    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_tqlv_rec tqlv_rec_type := p_tqlv_rec;
    l_api_name VARCHAR2(30) := 'delete_quote_line';
    l_api_version CONSTANT NUMBER := 1;
    l_qst_code VARCHAR2(30);

    -- rmunjulu Sales_Tax_Enhancement
    l_qte_id NUMBER;

    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'delete_quote_line';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.id: ' || p_tqlv_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qlt_code: ' || p_tqlv_rec.qlt_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.kle_id: ' || p_tqlv_rec.kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.sty_id: ' || p_tqlv_rec.sty_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qte_id: ' || p_tqlv_rec.qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.line_number: ' || p_tqlv_rec.line_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.amount: ' || p_tqlv_rec.amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.modified_yn: ' || p_tqlv_rec.modified_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.taxed_yn: ' || p_tqlv_rec.taxed_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.defaulted_yn: ' || p_tqlv_rec.defaulted_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.org_id: ' || p_tqlv_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.start_date: ' || p_tqlv_rec.start_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.period: ' || p_tqlv_rec.period);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.number_of_periods: ' || p_tqlv_rec.number_of_periods);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.lock_level_step: ' || p_tqlv_rec.lock_level_step);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.advance_or_arrears: ' || p_tqlv_rec.advance_or_arrears);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_name: ' || p_tqlv_rec.yield_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_value: ' || p_tqlv_rec.yield_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.implicit_interest_rate: ' || p_tqlv_rec.implicit_interest_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_value: ' || p_tqlv_rec.asset_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.residual_value: ' || p_tqlv_rec.residual_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.unbilled_receivables: ' || p_tqlv_rec.unbilled_receivables);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_quantity: ' || p_tqlv_rec.asset_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.quote_quantity: ' || p_tqlv_rec.quote_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_id: ' || p_tqlv_rec.split_kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_name: ' || p_tqlv_rec.split_kle_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_code: ' || p_tqlv_rec.currency_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_code: ' || p_tqlv_rec.currency_conversion_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_type: ' || p_tqlv_rec.currency_conversion_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_rate: ' || p_tqlv_rec.currency_conversion_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_date: ' || p_tqlv_rec.currency_conversion_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.due_date: ' || p_tqlv_rec.due_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.try_id: ' || p_tqlv_rec.try_id);
	 END IF;


     --Check API version, initialize message list and create savepoint.
     l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                               G_PKG_NAME,
                                               p_init_msg_list,
                                               l_api_version,
                                               p_api_version,
                                               '_PVT',
                                               x_return_status);


     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


     -- Get the quote status
     FOR get_quote_dtls_rec IN get_quote_dtls_csr(p_tqlv_rec.id) LOOP

         l_qst_code := get_quote_dtls_rec.qst_code;
         l_qte_id := get_quote_dtls_rec.qte_id; -- rmunjulu Sales_Tax_Enhancement

     END LOOP;


     -- If the quote is not DRAFTED or REJECTED, can not delete lines.
     IF l_qst_code NOT IN ('DRAFTED','REJECTED' ) THEN

        -- Quote status must be either Drafted or Rejected.
        OKL_API.set_message (
              			 p_app_name  	  => 'OKL',
              			 p_msg_name  	  => 'OKL_AM_SUBMIT_FOR_APPROVAL');

        RAISE OKL_API.G_EXCEPTION_ERROR;

     END IF;



     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TXL_QUOTE_LINES_PUB.delete_txl_quote_lines');
     END IF;
     -- Delete line from table using TAPI
     OKL_TXL_QUOTE_LINES_PUB.delete_txl_quote_lines(
                               p_api_version   => p_api_version,
                               p_init_msg_list => G_FALSE,
                               x_return_status => l_return_status,
                               x_msg_count     => x_msg_count,
                               x_msg_data      => x_msg_data,
                               p_tqlv_rec      => lp_tqlv_rec);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_TXL_QUOTE_LINES_PUB.delete_txl_quote_lines , return status: ' || l_return_status);
     END IF;



     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax');
    END IF;
    -- rmunjulu Sales_Tax_Enhancement
    -- Call the new OKL Tax engine to RECALCULATE tax for all quote lines
	OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax(
    	p_api_version          => l_api_version,
    	p_init_msg_list        => OKL_API.G_FALSE,
    	x_return_status        => l_return_status,
    	x_msg_count            => x_msg_count,
    	x_msg_data             => x_msg_data,
    	p_source_trx_id		   => l_qte_id, -- TRX_ID is QUOTE_ID
    	p_source_trx_name      => 'Estimated Billing',	-- TRX_NAME IS NULL
    	p_source_table         => 'OKL_TRX_QUOTES_B');  -- SOURCE_TABLE IS OKL_TRX_QUOTES_B
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax , return status: ' || l_return_status);
    END IF;

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        -- Tax Processing failed.
        OKL_API.set_message( p_app_name      => 'OKL',
                             p_msg_name      =>'OKL_AM_PROCESS_TAX_ERR');
      END IF;

     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- set the return status and out variables
     x_return_status := l_return_status;


     -- end the transaction
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION


    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;

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
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


  END delete_quote_line ;




  -- Start of comments
  --
  -- Function  Name  : delete_quote_line
  -- Description     : Deletes multiple quote lines
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_tbl
  -- Version         : 1.0
  -- History         : 16-JAN-03 RMUNJULU 2754574 Created
  -- End of comments
  PROCEDURE delete_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_tbl       IN tqlv_tbl_type) IS



    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_tqlv_tbl tqlv_tbl_type := p_tqlv_tbl;
    l_api_name VARCHAR2(30) := 'delete_quote_line';
    l_api_version CONSTANT NUMBER := 1;
    i NUMBER;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'delete_quote_line';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl.COUNT: ' || p_tqlv_tbl.COUNT);
	 END IF;

     --Check API version, initialize message list and create savepoint.
     l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                               G_PKG_NAME,
                                               p_init_msg_list,
                                               l_api_version,
                                               p_api_version,
                                               '_PVT',
                                               x_return_status);


     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


     -- Loop thru the input tbl and call the rec type API
     IF (lp_tqlv_tbl.COUNT > 0) THEN

       i := lp_tqlv_tbl.FIRST;

       LOOP

         -- Update line of table using rec type API
         delete_quote_line(
               p_api_version   => p_api_version,
               p_init_msg_list => G_FALSE,
               x_return_status => l_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_tqlv_rec      => lp_tqlv_tbl(i));
         IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called delete_quote_line , return status: ' || l_return_status);
         END IF;

         -- raise exception if error
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         EXIT WHEN (i = lp_tqlv_tbl.LAST);
         i := lp_tqlv_tbl.NEXT(i);
       END LOOP;

     END IF;


     -- set the return status and out variables
     x_return_status := l_return_status;


     -- end the transaction
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION


    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;

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
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  END delete_quote_line ;

END OKL_AM_TERMNT_QUOTE_PVT;

/
