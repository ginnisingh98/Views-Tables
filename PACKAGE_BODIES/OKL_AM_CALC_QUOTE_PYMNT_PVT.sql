--------------------------------------------------------
--  DDL for Package Body OKL_AM_CALC_QUOTE_PYMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CALC_QUOTE_PYMNT_PVT" AS
/* $Header: OKLRCQPB.pls 120.5.12010000.2 2009/04/15 08:14:18 nikshah ship $ */

--Bug 4299668 PAGARG declared these table types & counters for bulk insert
--**START**--
--Define it globally, keep populating the table of records and finally make a
--call to bulk insert procedure
  g_cfov_tbl_type okl_cash_flow_objects_pub.cfov_tbl_type;
  g_cafv_tbl_type okl_cash_flows_pub.cafv_tbl_type;
  g_cflv_tbl_type okl_cash_flow_levels_pub.cflv_tbl_type;
  g_qcov_tbl_type okl_trx_qte_cf_objects_pub.qcov_tbl_type;
  gx_cfov_tbl_type okl_cash_flow_objects_pub.cfov_tbl_type;
  gx_cafv_tbl_type okl_cash_flows_pub.cafv_tbl_type;
  gx_cflv_tbl_type okl_cash_flow_levels_pub.cflv_tbl_type;
  gx_qcov_tbl_type okl_trx_qte_cf_objects_pub.qcov_tbl_type;
  g_cfov_counter NUMBER := 0;
  g_cafv_counter NUMBER := 0;
  g_cflv_counter NUMBER := 0;
  g_qcov_counter NUMBER := 0;
--**END 4299668**--

-- GLOBAL VARIABLES for debug logging
  G_LEVEL_PROCEDURE             CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT             CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_EXCEPTION             CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_MODULE_NAME                 CONSTANT VARCHAR2(500) := 'okl.am.plsql.Okl_am_calc_quote_pymnt_pvt.';

TYPE cashflow_rec_type IS RECORD
(    p_cfo_id                   NUMBER,
     p_sts_code                 VARCHAR2(30),
     p_sty_id                   NUMBER,
     p_due_arrears_yn           VARCHAR2(3),
     p_start_date               DATE,
     p_advance_periods          NUMBER,
     p_khr_id                   NUMBER,
     p_quote_id                 NUMBER,
     p_amount                   NUMBER,
     p_period_in_months         NUMBER,
     p_frequency                VARCHAR2(30),
     p_seq_num                  NUMBER DEFAULT NULL,
     p_stub_days                NUMBER,
     p_stub_amount              NUMBER);

--Bug 4299668 PAGARG Function to obtain sequence id for primary key
--It is used for cash flow object & cash flows as their refernce is to be stored
--in child records
--**START**--
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;
--**END 4299668**--

/*========================================================================
 | PUBLIC PROCEDURE get_payment_summary
 |
 | DESCRIPTION
 |     This procedure is used by the first payment screen to display payment
 |     summary information
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     This procedure is called directly from the payment details screen
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 |
 | PARAMETERS
 |      p_qte_id                IN      Quote ID
 |      x_pymt_smry_tbl         OUT     Payment Summary Table
 |      x_pymt_smry_tbl_count   OUT     Payment Summary Table Count
 |      x_total_curr_amt        OUT     Total Curernt Amount
 |      x_total_prop_amt        OUT     Total proposed Amount
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 14-OCT-2003           SECHAWLA          Created
 | 26-Apr-2005 PAGARG Bug 4299668 Populating stream type id also in payment
 |                    summary table of records as stream type code may not be
 |                    unique after UDS impact.
 *=======================================================================*/
PROCEDURE get_payment_summary(p_api_version                     IN  NUMBER,
                                  p_init_msg_list               IN  VARCHAR2,
                                  x_msg_count                   OUT NOCOPY NUMBER,
                                  x_msg_data                    OUT NOCOPY VARCHAR2,
                                  x_return_status               OUT NOCOPY VARCHAR2,
                              p_qte_id                  IN  NUMBER,
                              x_pymt_smry_tbl           OUT NOCOPY pymt_smry_uv_tbl_type,
                              x_pymt_smry_tbl_count     OUT NOCOPY NUMBER,
                              x_total_curr_amt          OUT NOCOPY NUMBER,
                              x_total_prop_amt          OUT NOCOPY NUMBER) IS

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

-- This cursor returns the current total and proposed total for each stream type
CURSOR l_pymtsummary_csr(cp_qte_id IN NUMBER) IS
--PAGARG Bug 4299668: Query Stream type id also.
SELECT stm.id STY_ID
     , stm.code sty_code
     , caf.sts_code status
     , caf.dnz_khr_id khr_id
     , (nvl(sum(amount * number_of_periods),0) + nvl(sum(stub_amount),0)) Total
FROM okl_cash_flows caf
   , okl_strm_type_b stm
   , okl_cash_flow_levels cfl
WHERE dnz_qte_id = cp_qte_id
  AND caf.sty_id = stm.id
  AND caf.id = cfl.caf_id
  AND caf.sts_code IN ( G_CURRENT_STATUS, G_PROPOSED_STATUS)
  AND caf.cft_code = G_CASH_FLOW_TYPE
GROUP BY stm.id
       , stm.code
       , caf.sts_code
       , caf.dnz_khr_id
ORDER BY stm.id;

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

l_pymt_smry_tbl         pymt_smry_uv_tbl_type;
l_tbl_count             NUMBER := 0;
l_csr_count             NUMBER := 0;
l_prev_sty_id           NUMBER := -1;
l_total_curr_amt        NUMBER := 0 ;
l_total_prop_amt        NUMBER := 0 ;

l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_version           CONSTANT NUMBER := 1;
l_api_name              CONSTANT VARCHAR2(30) := 'get_payment_summary';

    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_payment_summary';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   --Print Input Variables
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_qte_id :'||p_qte_id);

   END IF;

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

  IF p_qte_id IS NULL OR p_qte_id = OKL_API.G_MISS_NUM THEN

     -- quote id is required
     OKL_API.set_message( p_app_name      => 'OKC',
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'QUOTE_ID');
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- This cursor will return 2 rows for each stream type
  FOR l_pymtsummary_rec IN l_pymtsummary_csr(p_qte_id) LOOP
      l_csr_count := l_csr_count + 1;

      IF l_pymtsummary_rec.sty_id <> l_prev_sty_id THEN
         l_tbl_count := l_tbl_count + 1;

--PAGARG Bug 4299668: Populate Stream type id also.
         l_pymt_smry_tbl(l_tbl_count).p_strm_type_id := l_pymtsummary_rec.sty_id;
         l_pymt_smry_tbl(l_tbl_count).p_strm_type_code := l_pymtsummary_rec.sty_code;
         l_pymt_smry_tbl(l_tbl_count).p_curr_total := l_pymtsummary_rec.total;

         l_prev_sty_id := l_pymtsummary_rec.sty_id;

         l_total_curr_amt := l_total_curr_amt + l_pymtsummary_rec.total;
      ELSE
         l_pymt_smry_tbl(l_tbl_count).p_prop_total := l_pymtsummary_rec.total;

         l_total_prop_amt := l_total_prop_amt + l_pymtsummary_rec.total ;
      END IF;

  END LOOP;

  x_pymt_smry_tbl_count := l_tbl_count;
  x_pymt_smry_tbl := l_pymt_smry_tbl;
  x_total_curr_amt := l_total_curr_amt ;
  x_total_prop_amt := l_total_prop_amt ;
  x_return_status  := l_return_status;

  OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);

  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
  END IF;

  EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
       END IF;

       IF l_pymtsummary_csr%ISOPEN THEN
                        CLOSE l_pymtsummary_csr;
           END IF;
       x_return_status := OKL_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
       IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||sqlerrm);
       END IF;
                -- Close open cursors

                IF l_pymtsummary_csr%ISOPEN THEN
                        CLOSE l_pymtsummary_csr;
                END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_payment_summary;

/*========================================================================
 | PRIVATE PROCEDURE create_cash_flow_object
 |
 | DESCRIPTION
 |    This procedure creates a cash flow object
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     get_current_payments, calc_prop_line_payments, calc_proposed_payments
 |
 | CALLS PROCEDURES/FUNCTIONS
 |
 |
 | PARAMETERS
 |      p_obj_type_code                IN      Object type
 |      p_src_table                    IN      Source Table originating the cash flow object
 |      p_src_id                       IN      ID of the row in the source table
 |      p_base_src_id                  IN      ID of the source of the cash flow object
 |      p_sts_code                     IN      cash flow status
 |      x_cfo_id                       OUT     cash flow Object ID
 |
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 14-OCT-2003           SECHAWLA          Created
 | 22-Apr-2005 4299668   PAGARG   Instead of calling insert for each cash flow object,
 |                                store it in table and finally call bulk insert
 *=======================================================================*/

PROCEDURE create_cash_flow_object(p_api_version    IN   NUMBER,
                                  x_msg_count      OUT  NOCOPY NUMBER,
                                  x_msg_data       OUT  NOCOPY VARCHAR2,
                                  p_obj_type_code  IN   VARCHAR2,
                                  p_src_table      IN   VARCHAR2,
                                  p_src_id         IN   NUMBER,
                                  p_base_src_id    IN   NUMBER,
                                  p_sts_code       IN   VARCHAR2,
                                  x_cfo_id         OUT  NOCOPY NUMBER,
                                  x_return_status  OUT  NOCOPY   VARCHAR2) IS


/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

 --This cursor checks if an object already exists
 CURSOR l_cash_flow_objects_csr(cp_oty_code IN VARCHAR2, cp_source_table IN VARCHAR2,
                                cp_source_id IN NUMBER, cp_sts_code IN VARCHAR2,
                                cp_base_src_id IN NUMBER) IS
 --SELECT cfo.id
 SELECT 'x'
 FROM   okl_cash_flow_objects cfo, okl_cash_flows caf, OKL_TRX_QTE_CF_OBJECTS qco
 WHERE  cfo.id = caf.cfo_id
 AND    cfo.id = qco.cfo_id
 AND    cfo.oty_code = cp_oty_code
 AND    cfo.source_table = cp_source_table
 AND    cfo.source_id = cp_source_id
 AND    caf.sts_code = cp_sts_code
 AND    qco.base_source_id = cp_base_src_id;

 /*-----------------------------------------------------------------------+
 | SubType Declarations
 +-----------------------------------------------------------------------*/

 SUBTYPE cfov_rec_type IS okl_cash_flow_objects_pub.cfov_rec_type;


/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

l_cfo_id                     NUMBER;
lp_cfov_rec                  cfov_rec_type;
lx_cfov_rec                  cfov_rec_type;
l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_dummy                      VARCHAR2(1);

    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'create_cash_flow_object';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   --Print Input Variables
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_obj_type_code :'||p_obj_type_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_src_table :'||p_src_table);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_src_id :'||p_src_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_base_src_id :'||p_base_src_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_sts_code :'||p_sts_code);
   END IF;

-- Check if Object already exists
  OPEN  l_cash_flow_objects_csr(p_obj_type_code, p_src_table, p_src_id, p_sts_code, p_base_src_id);
  FETCH l_cash_flow_objects_csr INTO l_dummy;

  IF l_cash_flow_objects_csr%NOTFOUND THEN  -- Object does not exist

     lp_cfov_rec.oty_code := p_obj_type_code;
     lp_cfov_rec.source_table := p_src_table;
     lp_cfov_rec.source_id := p_src_id;

     --Bug 4299668 PAGARG Instead of calling the procedure to insert cash flow
     --object, store the record in the table
     --**START**--
     lp_cfov_rec.id := get_seq_id;
     g_cfov_counter := g_cfov_counter + 1;
     g_cfov_tbl_type(g_cfov_counter) := lp_cfov_rec;

     x_cfo_id := lp_cfov_rec.id;
     --**END 4299668**--

  ELSE
     --OTY_CODE object already exists for STS_CODE payments.

     OKL_API.set_message(p_app_name       => 'OKL',
                          p_msg_name      => 'OKL_AM_OBJ_EXISTS',
                          p_token1        => 'OTY_CODE',
                          p_token1_value  => p_obj_type_code,
                          p_token2        => 'STS_CODE',
                          p_token2_value  => p_sts_code);
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  CLOSE l_cash_flow_objects_csr;

  x_return_status := l_return_status;

  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'end(-)');
  END IF;

   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
     END IF;

     IF l_cash_flow_objects_csr%ISOPEN THEN
        CLOSE l_cash_flow_objects_csr;
     END IF;
     x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
     END IF;

     IF l_cash_flow_objects_csr%ISOPEN THEN
        CLOSE l_cash_flow_objects_csr;
     END IF;
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN

     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||sqlerrm);
     END IF;

     IF l_cash_flow_objects_csr%ISOPEN THEN
        CLOSE l_cash_flow_objects_csr;
     END IF;
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- unexpected error
     OKL_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
END create_cash_flow_object;


/*========================================================================
 | PRIVATE PROCEDURE create_cash_flows
 |
 | DESCRIPTION
 |    This procedure creates cash flow header and cash flow levels
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     get_current_payments, calc_prop_line_payments, calc_proposed_payments
 |
 | CALLS PROCEDURES/FUNCTIONS
 |
 |
 | PARAMETERS
 |      p_cashflow_rec      IN        Cash Flow rec details (cashflow_rec_type)
 |      px_new_cash_flow    IN OUT    flag to indicate if it is a new cash flow
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 14-OCT-2003           SECHAWLA          Created
 | 22-Apr-2005 4299668   PAGARG   Instead of calling insert for each cash flow
 |                                and cash flow level, store it in table and
 |                                finally call bulk insert
 *=======================================================================*/
PROCEDURE create_cash_flows(p_api_version           IN     NUMBER,
                            x_msg_count             OUT    NOCOPY NUMBER,
                            x_msg_data              OUT    NOCOPY VARCHAR2,
                            p_cashflow_rec          IN     cashflow_rec_type,
                            px_new_cash_flow        IN     OUT NOCOPY VARCHAR2,
                            x_return_status         OUT    NOCOPY VARCHAR2
                            ) IS

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

-- This cursor checks if a cash flow header has already been created for a stream type (payment type)
    CURSOR l_cashflow_csr(cp_cfo_id IN NUMBER, cp_sty_id IN NUMBER) IS
    SELECT id
    FROM   okl_cash_flows
    WHERE  cfo_id = cp_cfo_id
    AND    sty_id = cp_sty_id;

    -- get the currency code for the contract for which the quote is created
    CURSOR l_kheaders_csr(cp_khr_id IN NUMBER) IS
    SELECT currency_code
    FROM   okc_k_headers_b
    WHERE  id = cp_khr_id;

 /*-----------------------------------------------------------------------+
 | SubType Declarations
 +-----------------------------------------------------------------------*/

    SUBTYPE cafv_rec_type IS okl_cash_flows_pub.cafv_rec_type;
    SUBTYPE cflv_rec_type IS okl_cash_flow_levels_pub.cflv_rec_type;

 /*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    lp_cafv_rec                  cafv_rec_type;
    lx_cafv_rec                  cafv_rec_type;

    lp_cflv_rec                  cflv_rec_type;
    lx_cflv_rec                  cflv_rec_type;

    l_dummy                      VARCHAR2(1) := '?';
    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_caf_id                     NUMBER ;
    l_currency_code              VARCHAR2(15);
    l_amount                     NUMBER;
    l_stub_amount                NUMBER;

    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'create_cash_flows';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   --Print Input Variables
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_cfo_id :'||p_cashflow_rec.p_cfo_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_sts_code :'||p_cashflow_rec.p_sts_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_sty_id :'||p_cashflow_rec.p_sty_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_sty_id :'||p_cashflow_rec.p_sty_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_sty_id :'||p_cashflow_rec.p_sty_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_due_arrears_yn :'||p_cashflow_rec.p_due_arrears_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_start_date :'||p_cashflow_rec.p_start_date);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_advance_periods :'||p_cashflow_rec.p_advance_periods);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_khr_id :'||p_cashflow_rec.p_khr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_quote_id :'||p_cashflow_rec.p_quote_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_amount :'||p_cashflow_rec.p_amount);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_period_in_months :'||p_cashflow_rec.p_period_in_months);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_frequency :'||p_cashflow_rec.p_frequency);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_seq_num :'||p_cashflow_rec.p_seq_num);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_cashflow_rec.p_stub_days :'||p_cashflow_rec.p_stub_days);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'px_new_cash_flow :'||px_new_cash_flow);

   END IF;

   OPEN  l_cashflow_csr(p_cashflow_rec.p_cfo_id , p_cashflow_rec.p_sty_id);
   FETCH l_cashflow_csr INTO l_caf_id;
   CLOSE l_cashflow_csr;

   IF l_caf_id IS NULL THEN -- Stream type has not been inserted yet in the cash flow header

        lp_cafv_rec.cfo_id := p_cashflow_rec.p_cfo_id;
        lp_cafv_rec.sts_code := p_cashflow_rec.p_sts_code;
        lp_cafv_rec.sty_id := p_cashflow_rec.p_sty_id;
        lp_cafv_rec.cft_code := G_CASH_FLOW_TYPE;
        lp_cafv_rec.due_arrears_yn := nvl(p_cashflow_rec.p_due_arrears_yn,'N');
        lp_cafv_rec.start_date := p_cashflow_rec.p_start_date;
        lp_cafv_rec.number_of_advance_periods := p_cashflow_rec.p_advance_periods;
        lp_cafv_rec.dnz_khr_id := p_cashflow_rec.p_khr_id;
        lp_cafv_rec.dnz_qte_id := p_cashflow_rec.p_quote_id;

     --Bug 4299668 PAGARG Instead of calling the procedure to insert cash flow,
     --store the record in the table
     --**START**--
     lp_cafv_rec.id := get_seq_id;
     g_cafv_counter := g_cafv_counter + 1;
     g_cafv_tbl_type(g_cafv_counter) := lp_cafv_rec;
     l_caf_id := lp_cafv_rec.id;
     --**END 4299668**--

        px_new_cash_flow := 'Y';
     END IF;

     IF l_caf_id IS NULL THEN
        l_caf_id := lx_cafv_rec.id;
     END IF;

     -- Create cash flow level
     IF px_new_cash_flow = 'Y' THEN
            --    lp_cflv_rec.caf_id := lx_cafv_rec.id;
            lp_cflv_rec.caf_id := l_caf_id;

            OPEN  l_kheaders_csr(p_cashflow_rec.p_khr_id);
            FETCH l_kheaders_csr INTO l_currency_code;
            IF l_kheaders_csr%NOTFOUND THEN
               -- contract ID is invalid
              OKL_API.set_message( p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'CONTRACT_ID');

              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            CLOSE l_kheaders_csr;

            IF p_cashflow_rec.p_stub_days IS NOT NULL THEN
               okl_accounting_util.round_amount(
                    p_api_version              =>    p_api_version,
                    p_init_msg_list            =>    OKL_API.G_FALSE,
                    x_return_status            =>    l_return_status,
                    x_msg_count                =>    x_msg_count,
                    x_msg_data                 =>    x_msg_data,
                    p_amount                   =>    p_cashflow_rec.p_stub_amount,
                    p_currency_code            =>    l_currency_code,
                    p_round_option             =>    'AEL',
                    x_rounded_amount           =>    l_stub_amount);

                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                lp_cflv_rec.stub_days := p_cashflow_rec.p_stub_days;
                lp_cflv_rec.stub_amount := l_stub_amount;
            ELSE

                okl_accounting_util.round_amount(
                    p_api_version              =>    p_api_version,
                    p_init_msg_list            =>    OKL_API.G_FALSE,
                    x_return_status            =>    l_return_status,
                    x_msg_count                =>    x_msg_count,
                    x_msg_data                 =>    x_msg_data,
                    p_amount                   =>    p_cashflow_rec.p_amount,
                    p_currency_code            =>    l_currency_code,
                    p_round_option             =>    'AEL',
                    x_rounded_amount           =>    l_amount);

                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                lp_cflv_rec.amount := l_amount;
                lp_cflv_rec.number_of_periods := p_cashflow_rec.p_period_in_months;
                lp_cflv_rec.fqy_code := p_cashflow_rec.p_frequency;

            END IF;

            lp_cflv_rec.level_sequence := p_cashflow_rec.p_seq_num;
            lp_cflv_rec.start_date := p_cashflow_rec.p_start_date;

            --Bug 4299668 PAGARG Instead of calling the procedure to insert cash flow
            --level, store the record in the table
            --**START**--
            g_cflv_counter := g_cflv_counter + 1;
            g_cflv_tbl_type(g_cflv_counter) := lp_cflv_rec;
            --**END 4299668**--

     END IF;
   x_return_status := l_return_status;
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
     END IF;

     IF l_cashflow_csr%ISOPEN THEN
        CLOSE l_cashflow_csr;
     END IF;
     IF l_kheaders_csr%ISOPEN THEN
        CLOSE l_kheaders_csr;
     END IF;
     x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
     END IF;

     IF l_cashflow_csr%ISOPEN THEN
        CLOSE l_cashflow_csr;
     END IF;
     IF l_kheaders_csr%ISOPEN THEN
        CLOSE l_kheaders_csr;
     END IF;
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN

     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||sqlerrm);
     END IF;

     IF l_cashflow_csr%ISOPEN THEN
        CLOSE l_cashflow_csr;
     END IF;
     IF l_kheaders_csr%ISOPEN THEN
        CLOSE l_kheaders_csr;
     END IF;
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- unexpecetd error
     OKL_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
END create_cash_flows;

/*========================================================================
 | PRIVATE PROCEDURE get_current_payments
 |
 | DESCRIPTION
 |    This procedure queries the current payments and populates the payment structures
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     calc_quote_payments,
 |
 | CALLS PROCEDURES/FUNCTIONS
 |     create_cash_flow_object, create_cash_flows
 |
 | PARAMETERS
 |      p_quote_id                 IN        Quote ID
 |      p_khr_id                   IN        Contract ID
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date         Author     Description of Changes
 | 14-OCT-2003  SECHAWLA   Created
 | 29-SEP-2004  pagarg     Bug #3921591: Added the logic to obtain the
 |                         current payments for fee asset line.
 | 22-Apr-2005  PAGARG     Bug 4299668 Instead of calling insert for each quote
 |                         cash flow object, prepare table of records and finally
 |                         call bulk insert for all four objects
 *=======================================================================*/
 PROCEDURE get_current_payments(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_quote_id          IN  NUMBER,
    p_khr_id            IN  NUMBER) AS

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- get the current contract level payments
    CURSOR  l_kpayments_csr(cp_chr_id IN NUMBER) IS
    SELECT  rgp.cle_id cle_id,
        sttyp.id1   sty_id,
        sttyp.code  stream_type,
        tuom.id1 frequency,
        sll_rul.rule_information1 seq_num,
        sll_rul.rule_information2 start_date,
        sll_rul.rule_information3 period_in_months,
        sll_rul.rule_information5 advance_periods,
        sll_rul.rule_information6 amount,
        sll_rul.rule_information10 due_arrears_yn,
        sll_rul.rule_information7 stub_days,
        sll_rul.rule_information8 stub_amount,
        rgp.dnz_chr_id
    FROM    okl_time_units_v tuom,
        okc_rules_b sll_rul,
        okl_strmtyp_source_v sttyp,
        okc_rules_b slh_rul,
        okc_rule_groups_b rgp
    WHERE   tuom.id1      = sll_rul.object1_id1
    AND     sll_rul.object2_id1 = to_char(slh_rul.id)
    AND     sll_rul.rgp_id    = rgp.id
    AND     sll_rul.rule_information_category = 'LASLL'
    AND     sttyp.id1 = slh_rul.object1_id1
    AND     slh_rul.rgp_id = rgp.id
    AND     slh_rul.rule_information_category = 'LASLH'
    AND     rgp.rgd_code = 'LALEVL'
    AND     rgp.dnz_chr_id = cp_chr_id
    AND     rgp.cle_id IS NULL
    ORDER BY stream_type, start_date;

    -- Get all the asset, service and fee lines attached to the contract
    -- These lines may or may not have payments associated with them
    CURSOR l_okcklines_csr(cp_chr_id IN NUMBER) IS
    SELECT cle.id, cle.lse_id, lse.lty_code
    FROM   okc_k_lines_b cle, okc_line_styles_b lse
    WHERE  cle.lse_id = lse.id
    AND    cle.sts_code IN ('BOOKED', 'TERMINATED')
    AND    chr_id = cp_chr_id;

    --This cursor returns the payments associated with an Asset/Service/Fee Line (If Any)

    -- Get the current Line Level payments
    CURSOR  l_lpayments_csr(cp_cle_id IN NUMBER) IS
    SELECT  rgp.cle_id cle_id,
        sttyp.id1   sty_id,
        sttyp.code  stream_type,
        tuom.id1 frequency,
        sll_rul.rule_information1 seq_num,
        sll_rul.rule_information2 start_date,
        sll_rul.rule_information3 period_in_months,
        sll_rul.rule_information5 advance_periods,
        sll_rul.rule_information6 amount,
        sll_rul.rule_information10 due_arrears_yn,
        sll_rul.rule_information7 stub_days,
        sll_rul.rule_information8 stub_amount,
        rgp.dnz_chr_id
    FROM    okl_time_units_v tuom,
        okc_rules_b sll_rul,
        okl_strmtyp_source_v sttyp,
        okc_rules_b slh_rul,
        okc_rule_groups_b rgp
    WHERE   tuom.id1      = sll_rul.object1_id1
    AND     sll_rul.object2_id1 = to_char(slh_rul.id)
    AND     sll_rul.rgp_id    = rgp.id
    AND     sll_rul.rule_information_category = 'LASLL'
    AND     sttyp.id1 = slh_rul.object1_id1
    AND     slh_rul.rgp_id = rgp.id
    AND     slh_rul.rule_information_category = 'LASLH'
    AND     rgp.rgd_code = 'LALEVL'
    AND     rgp.cle_id = cp_cle_id
    ORDER BY stream_type, start_date;

    --Bug #3921591: pagarg +++ Rollover +++
    -- Modified the cursor to get assets for any given line type.
    -- Get the assets associated with the given line type
    CURSOR l_lineassets_csr(cp_line_id IN NUMBER, cp_line_type_code IN VARCHAR2) IS
    SELECT cim.object1_id1, cle.id
    FROM   okc_k_lines_b cle, okc_line_styles_b lse, okc_k_items cim
    WHERE  cle.lse_id = lse.id
    AND    lse.lty_code = cp_line_type_code
    AND    cim.cle_id = cle.id
    AND    cle.cle_id = cp_line_id;

 /*-----------------------------------------------------------------------+
 | Subype Declarations                                                   |
 +-----------------------------------------------------------------------*/

   SUBTYPE cfov_rec_type IS okl_cash_flow_objects_pub.cfov_rec_type;
   SUBTYPE cafv_rec_type IS okl_cash_flows_pub.cafv_rec_type;
   SUBTYPE cflv_rec_type IS okl_cash_flow_levels_pub.cflv_rec_type;
   SUBTYPE qcov_rec_type IS okl_trx_qte_cf_objects_pub.qcov_rec_type;

 /*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    lp_cfov_rec                  cfov_rec_type;
    lx_cfov_rec                  cfov_rec_type;

    lp_cafv_rec                  cafv_rec_type;
    lx_cafv_rec                  cafv_rec_type;

    lp_cflv_rec                  cflv_rec_type;
    lx_cflv_rec                  cflv_rec_type;

    lp_qcov_rec                  qcov_rec_type;
    lx_qcov_rec                  qcov_rec_type;

    lp_cashflow_rec              cashflow_rec_type;

    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_pymt_count                 NUMBER := 0;
    l_sys_date   DATE;
    l_api_version                CONSTANT NUMBER := 1;
    l_cfo_id                     NUMBER;
    l_dummy                      VARCHAR2(1) := '?';
    l_oty_code                   VARCHAR2(30);

    lx_new_cash_flow             VARCHAR2(1);

    l_prev_sty_id NUMBER := -99;
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_current_payments';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
    END IF;

    --Print Input Variables
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_quote_id :'||p_quote_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_khr_id  :'||p_khr_id );

   END IF;

    ------------------------- Get contract level payments------------------------------
    l_pymt_Count := 0;

    --loop thru all the payments for this contract, create one cash flow object, create cash flows for each stream type,
    -- create cash flow levels for each payment record
    FOR l_kpayments_rec IN l_kpayments_csr(p_khr_id) LOOP

       l_pymt_count := l_pymt_count + 1;

       IF l_pymt_count = 1 THEN -- K level payments exist, create a K Object

          create_cash_flow_object(p_api_version    => p_api_version,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_obj_type_code  => G_CONTRACT_OBJ_TYPE,
                                  p_src_table      => G_OBJECT_SRC_TABLE,
                                  p_src_id         => p_quote_id,
                                  p_base_src_id    => p_khr_id,
                                  p_sts_code       => G_CURRENT_STATUS,
                                  x_cfo_id         => l_cfo_id,
                                  x_return_status  => l_return_status);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to create_cash_flow_object :'||l_return_status);
           END IF;

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         -- Store Objects in OKL_TRX_QTE_CF_OBJECTS

         lp_qcov_rec.qte_id := p_quote_id;
         lp_qcov_rec.cfo_id := l_cfo_id;
         lp_qcov_rec.BASE_SOURCE_ID := p_khr_id;
         --Bug 4299668 PAGARG Instead of calling the procedure to insert each
         --quote cash flow object, prepare table of records
         --**START**--
         g_qcov_counter := g_qcov_counter + 1;
         g_qcov_tbl_type(g_qcov_counter) := lp_qcov_rec;
         --**END 4299668**--

       END IF;

       IF l_kpayments_rec.sty_id <> l_prev_sty_id THEN
          lx_new_cash_flow := 'N';
          l_prev_sty_id := l_kpayments_rec.sty_id;
       END IF;

       lp_cashflow_rec.p_cfo_id := l_cfo_id;
       lp_cashflow_rec.p_sts_code := G_CURRENT_STATUS;
       lp_cashflow_rec.p_sty_id := l_kpayments_rec.sty_id;
       lp_cashflow_rec.p_due_arrears_yn := l_kpayments_rec.due_arrears_yn;
       lp_cashflow_rec.p_start_date := to_date(l_kpayments_rec.start_date,'yyyy/mm/dd hh24:mi:ss');
       lp_cashflow_rec.p_advance_periods := to_number(l_kpayments_rec.advance_periods);
       lp_cashflow_rec.p_khr_id := p_khr_id;
       lp_cashflow_rec.p_quote_id := p_quote_id;
       lp_cashflow_rec.p_amount := l_kpayments_rec.amount;
       lp_cashflow_rec.p_period_in_months := l_kpayments_rec.period_in_months;
       lp_cashflow_rec.p_frequency := l_kpayments_rec.frequency;
       lp_cashflow_rec.p_seq_num := to_number(l_kpayments_rec.seq_num);
       lp_cashflow_rec.p_stub_days := l_kpayments_rec.stub_days;
       lp_cashflow_rec.p_stub_amount := l_kpayments_rec.stub_amount;

       create_cash_flows(   p_api_version           => p_api_version,
                            x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                            p_cashflow_rec          => lp_cashflow_rec,
                            px_new_cash_flow        => lx_new_cash_flow,
                            x_return_status         => l_return_status);

          IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to create_cash_flows :'||l_return_status);
           END IF;

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

   END LOOP;

   --------------end current contract level payments ----------------------


   --------------get curent line level payments ---------------------------
   -- get all the contract lines
   FOR l_okcklines_rec IN l_okcklines_csr(p_khr_id) LOOP

       l_prev_sty_id := -99;

       l_pymt_Count := 0;

       -- get the line level payemnts, create cash flow object, cash flows and cash flow levels
       FOR l_lpayments_rec IN l_lpayments_csr(l_okcklines_rec.id) LOOP
          l_pymt_Count := l_pymt_Count + 1;


              IF l_pymt_count = 1 THEN -- line level payments exist

                 l_cfo_id := NULL;
                 IF    l_okcklines_rec.lty_code = 'FREE_FORM1' THEN
                       l_oty_code := G_FIN_ASSET_OBJ_TYPE;
                 ELSIF l_okcklines_rec.lty_code = 'SOLD_SERVICE' THEN
                       l_oty_code := G_SERVICE_LINE_OBJ_TYPE;
                 ELSIF l_okcklines_rec.lty_code = 'FEE' THEN
                       l_oty_code := G_FEE_LINE_OBJ_TYPE;
                 END IF;

                 create_cash_flow_object(
                                  p_api_version    => p_api_version,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_obj_type_code  => l_oty_code,
                                  p_src_table      => G_OBJECT_SRC_TABLE,
                                  p_src_id         => p_quote_id,
                                  p_base_src_id    => l_okcklines_rec.id,
                                  p_sts_code       => G_CURRENT_STATUS,
                                  x_cfo_id         => l_cfo_id,
                                  x_return_status  => l_return_status);

         IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to create_cash_flow_object :'||l_return_status);
           END IF;


                 IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;

                 lp_qcov_rec.qte_id := p_quote_id;
                 lp_qcov_rec.cfo_id := l_cfo_id;
                 lp_qcov_rec.BASE_SOURCE_ID := l_okcklines_rec.id;
                 --Bug 4299668 PAGARG Instead of calling the procedure to insert
                 --each quote cash flow object, prepare table of records
                 --**START**--
                 g_qcov_counter := g_qcov_counter + 1;
                 g_qcov_tbl_type(g_qcov_counter) := lp_qcov_rec;
                 --**END 4299668**--
            END IF;

            IF l_lpayments_rec.sty_id <> l_prev_sty_id THEN
                lx_new_cash_flow := 'N';
                l_prev_sty_id := l_lpayments_rec.sty_id;
            END IF;

            lp_cashflow_rec.p_cfo_id := l_cfo_id;
            lp_cashflow_rec.p_sts_code := G_CURRENT_STATUS;
            lp_cashflow_rec.p_sty_id := l_lpayments_rec.sty_id;
            lp_cashflow_rec.p_due_arrears_yn := l_lpayments_rec.due_arrears_yn;
            lp_cashflow_rec.p_start_date := to_date(l_lpayments_rec.start_date,'yyyy/mm/dd hh24:mi:ss');
            lp_cashflow_rec.p_advance_periods := to_number(l_lpayments_rec.advance_periods);
            lp_cashflow_rec.p_khr_id := p_khr_id;
            lp_cashflow_rec.p_quote_id := p_quote_id;
            lp_cashflow_rec.p_amount := l_lpayments_rec.amount;
            lp_cashflow_rec.p_period_in_months := l_lpayments_rec.period_in_months;
            lp_cashflow_rec.p_frequency := l_lpayments_rec.frequency;
            lp_cashflow_rec.p_seq_num := to_number(l_lpayments_rec.seq_num);
            lp_cashflow_rec.p_stub_days := l_lpayments_rec.stub_days;
            lp_cashflow_rec.p_stub_amount := l_lpayments_rec.stub_amount;

            create_cash_flows(   p_api_version           => p_api_version,
                            x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                            p_cashflow_rec          => lp_cashflow_rec,
                            px_new_cash_flow        => lx_new_cash_flow,
                            x_return_status         => l_return_status);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to create_cash_flows :'||l_return_status);
           END IF;

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
       END LOOP;

       ------------------------Get Serviced Asset Line level payments --------------------------
       -- If the current line is a service line, then also get the subline payments
       IF l_okcklines_rec.lty_code = 'SOLD_SERVICE' THEN

            l_prev_sty_id := -99;

            --Bug #3921591: pagarg +++ Rollover +++
            --Modified the cursor call to pass line type also
            -- get the financial assets associated with the service line
            FOR l_servicelineassets_rec IN l_lineassets_csr(l_okcklines_rec.id, G_LINKED_SERVICE_LINE_TYPE) LOOP
                l_pymt_Count := 0;
                -- get the payments associated with the sub lines of the service line(serviced assets)
                FOR l_lpayments_rec IN l_lpayments_csr(l_servicelineassets_rec.id) LOOP
                    l_pymt_Count := l_pymt_Count + 1;

                    IF l_pymt_count = 1 THEN -- line level payments exist
                        create_cash_flow_object(
                                  p_api_version    => p_api_version,
                                  x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data,
                                  p_obj_type_code  => G_SERV_ASSET_OBJ_TYPE,
                                  p_src_table      => G_OBJECT_SRC_TABLE,
                                  p_src_id         => p_quote_id,
                                  p_base_src_id    => l_servicelineassets_rec.id,
                                  p_sts_code       => G_CURRENT_STATUS,
                                  x_cfo_id         => l_cfo_id,
                                  x_return_status  => l_return_status);

          IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to create_cash_flow_object :'||l_return_status);
           END IF;
                        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;

                        lp_qcov_rec.qte_id := p_quote_id;
                        lp_qcov_rec.cfo_id := l_cfo_id;
                        lp_qcov_rec.BASE_SOURCE_ID := l_servicelineassets_rec.id;
                        --Bug 4299668 PAGARG Instead of calling the procedure to
                        --insert quote cash flow object, store the record in the table
                        --**START**--
                        g_qcov_counter := g_qcov_counter + 1;
                        g_qcov_tbl_type(g_qcov_counter) := lp_qcov_rec;
                        --**END 4299668**--

                    END IF;

                    IF l_lpayments_rec.sty_id <> l_prev_sty_id THEN
                        lx_new_cash_flow := 'N';
                        l_prev_sty_id := l_lpayments_rec.sty_id;
                    END IF;

                    lp_cashflow_rec.p_cfo_id := l_cfo_id;
                    lp_cashflow_rec.p_sts_code := G_CURRENT_STATUS;
                    lp_cashflow_rec.p_sty_id := l_lpayments_rec.sty_id;
                    lp_cashflow_rec.p_due_arrears_yn := l_lpayments_rec.due_arrears_yn;
                    lp_cashflow_rec.p_start_date := to_date(l_lpayments_rec.start_date,'yyyy/mm/dd hh24:mi:ss');
                    lp_cashflow_rec.p_advance_periods := to_number(l_lpayments_rec.advance_periods);
                    lp_cashflow_rec.p_khr_id := p_khr_id;
                    lp_cashflow_rec.p_quote_id := p_quote_id;
                    lp_cashflow_rec.p_amount := l_lpayments_rec.amount;
                    lp_cashflow_rec.p_period_in_months := l_lpayments_rec.period_in_months;
                    lp_cashflow_rec.p_frequency := l_lpayments_rec.frequency;
                    lp_cashflow_rec.p_seq_num := to_number(l_lpayments_rec.seq_num);
                    lp_cashflow_rec.p_stub_days := l_lpayments_rec.stub_days;
                    lp_cashflow_rec.p_stub_amount := l_lpayments_rec.stub_amount;

                    create_cash_flows(   p_api_version           => p_api_version,
                            x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                            p_cashflow_rec          => lp_cashflow_rec,
                            px_new_cash_flow        => lx_new_cash_flow,
                            x_return_status         => l_return_status);

          IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to create_cash_flows :'||l_return_status);
           END IF;
                    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                END LOOP;
            END LOOP;
            ----
       END IF;

       --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
       --------------------- Get Fee Asset Line level payments -----------------
       -- If the current line is a fee line, then also get the subline payments
       IF l_okcklines_rec.lty_code = 'FEE'
       THEN
         l_prev_sty_id := -99;
         -- get the financial assets associated with the fee line
         FOR l_feelineassets_rec IN l_lineassets_csr(l_okcklines_rec.id,
                                                     G_LINKED_FEE_LINE_TYPE)
         LOOP
           l_pymt_Count := 0;
           -- get the payments associated with the sub lines of the fee line
           FOR l_lpayments_rec IN l_lpayments_csr(l_feelineassets_rec.id)
           LOOP
             l_pymt_Count := l_pymt_Count + 1;
             IF l_pymt_count = 1 THEN -- line level payments exist
               create_cash_flow_object(
                              p_api_version    => p_api_version,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_obj_type_code  => G_FEE_ASSET_OBJ_TYPE,
                              p_src_table      => G_OBJECT_SRC_TABLE,
                              p_src_id         => p_quote_id,
                              p_base_src_id    => l_feelineassets_rec.id,
                              p_sts_code       => G_CURRENT_STATUS,
                              x_cfo_id         => l_cfo_id,
                              x_return_status  => l_return_status);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to create_cash_flow_object :'||l_return_status);
           END IF;

               IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
               lp_qcov_rec.qte_id := p_quote_id;
               lp_qcov_rec.cfo_id := l_cfo_id;
               lp_qcov_rec.BASE_SOURCE_ID := l_feelineassets_rec.id;
               --Bug 4299668 PAGARG Instead of calling the procedure to insert
               --quote cash flow object, store the record in the table
               --**START**--
               g_qcov_counter := g_qcov_counter + 1;
               g_qcov_tbl_type(g_qcov_counter) := lp_qcov_rec;
               --**END 4299668**--
             END IF;
             -- End of creation of cash flow object

             -- Creation of cash flows for each payment
             IF l_lpayments_rec.sty_id <> l_prev_sty_id THEN
               lx_new_cash_flow := 'N';
               l_prev_sty_id := l_lpayments_rec.sty_id;
             END IF;
             lp_cashflow_rec.p_cfo_id := l_cfo_id;
             lp_cashflow_rec.p_sts_code := G_CURRENT_STATUS;
             lp_cashflow_rec.p_sty_id := l_lpayments_rec.sty_id;
             lp_cashflow_rec.p_due_arrears_yn := l_lpayments_rec.due_arrears_yn;
             lp_cashflow_rec.p_start_date := to_date(l_lpayments_rec.start_date,'yyyy/mm/dd hh24:mi:ss');
             lp_cashflow_rec.p_advance_periods := to_number(l_lpayments_rec.advance_periods);
             lp_cashflow_rec.p_khr_id := p_khr_id;
             lp_cashflow_rec.p_quote_id := p_quote_id;
             lp_cashflow_rec.p_amount := l_lpayments_rec.amount;
             lp_cashflow_rec.p_period_in_months := l_lpayments_rec.period_in_months;
             lp_cashflow_rec.p_frequency := l_lpayments_rec.frequency;
             lp_cashflow_rec.p_seq_num := to_number(l_lpayments_rec.seq_num);
             lp_cashflow_rec.p_stub_days := l_lpayments_rec.stub_days;
             lp_cashflow_rec.p_stub_amount := l_lpayments_rec.stub_amount;
             create_cash_flows(
                    p_api_version           => p_api_version,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data,
                    p_cashflow_rec          => lp_cashflow_rec,
                    px_new_cash_flow        => lx_new_cash_flow,
                    x_return_status         => l_return_status);

          IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to create_cash_flows :'||l_return_status);
           END IF;
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
           END LOOP;
         END LOOP;
       END IF;
       --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++

   END LOOP;
   --------------------end get current line level payments -----------------------

   --Bug 4299668 PAGARG All the four object table of records is populated for
   --current payment. Now call proceure for bulk insert.
   --**START**--
   okl_cfo_pvt.insert_row_bulk(p_api_version    => p_api_version,
                               p_init_msg_list  => OKL_API.G_FALSE,
                               x_return_status  => l_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_cfov_tbl       => g_cfov_tbl_type,
                               x_cfov_tbl       => gx_cfov_tbl_type);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_cfo_pvt.insert_row_bulk :'||l_return_status);
           END IF;

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OKL_QCO_PVT.insert_row_bulk(p_api_version    => p_api_version,
                               p_init_msg_list  => OKL_API.G_FALSE,
                               x_return_status  => l_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_qcov_tbl       => g_qcov_tbl_type,
                               x_qcov_tbl       => gx_qcov_tbl_type);

      IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_cfo_pvt.insert_row_bulk :'||l_return_status);
           END IF;

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   okl_caf_pvt.insert_row_bulk(p_api_version       => p_api_version,
                               p_init_msg_list     => OKL_API.G_FALSE,
                               x_return_status     => l_return_status,
                               x_msg_count         => x_msg_count,
                               x_msg_data          => x_msg_data,
                               p_cafv_tbl          => g_cafv_tbl_type,
                               x_cafv_tbl          => gx_cafv_tbl_type);

   IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_cfo_pvt.insert_row_bulk :'||l_return_status);
   END IF;

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OKL_CFL_PVT.insert_row_bulk(p_api_version     =>    p_api_version,
                               p_init_msg_list   =>    OKL_API.G_FALSE,
                               x_return_status   =>    l_return_status,
                               x_msg_count       =>    x_msg_count,
                               x_msg_data        =>    x_msg_data,
                               p_cflv_tbl        =>    g_cflv_tbl_type,
                               x_cflv_tbl        =>    gx_cflv_tbl_type);

      IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_cfo_pvt.insert_row_bulk :'||l_return_status);
      END IF;

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   --**END 4299668**--

  -- set the return status and out variables
  x_return_status := l_return_status;

  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
  END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
       END IF;


       IF l_kpayments_csr%ISOPEN THEN
          CLOSE l_kpayments_csr;
       END IF;
       IF l_okcklines_csr%ISOPEN THEN
          CLOSE l_okcklines_csr;
       END IF;
       IF l_lpayments_csr%ISOPEN THEN
          CLOSE l_lpayments_csr;
       END IF;

       --Bug #3921591: pagarg +++ Rollover +++
       -- Changed the cursor name as made it generalised
       IF l_lineassets_csr%ISOPEN THEN
          CLOSE l_lineassets_csr;
       END IF;
       x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
       END IF;

       IF l_kpayments_csr%ISOPEN THEN
          CLOSE l_kpayments_csr;
       END IF;
       IF l_okcklines_csr%ISOPEN THEN
          CLOSE l_okcklines_csr;
       END IF;
       IF l_lpayments_csr%ISOPEN THEN
          CLOSE l_lpayments_csr;
       END IF;
       --Bug #3921591: pagarg +++ Rollover +++
       -- Changed the cursor name as made it generalised
       IF l_lineassets_csr%ISOPEN THEN
          CLOSE l_lineassets_csr;
       END IF;
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
       IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||sqlerrm);
       END IF;

       IF l_kpayments_csr%ISOPEN THEN
          CLOSE l_kpayments_csr;
       END IF;
       IF l_okcklines_csr%ISOPEN THEN
          CLOSE l_okcklines_csr;
       END IF;
       IF l_lpayments_csr%ISOPEN THEN
          CLOSE l_lpayments_csr;
       END IF;
       --Bug #3921591: pagarg +++ Rollover +++
       -- Changed the cursor name as made it generalised
       IF l_lineassets_csr%ISOPEN THEN
          CLOSE l_lineassets_csr;
       END IF;
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- unexpected error
     OKL_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);

  END get_current_payments;

  /*========================================================================
 | PRIVATE PROCEDURE calc_prop_line_payments
 |
 | DESCRIPTION
 |    This procedure calculates the proposed payments of asset, service and service sublines
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     calc_proposed_payments,
 |
 | CALLS PROCEDURES/FUNCTIONS
 |     create_cash_flow_object, create_cash_flows
 |
 | PARAMETERS
 |      p_curr_cfo_id                 IN        Current Cashflow ID
 |      p_prop_obj_type_code          IN        Proposed Object Type
 |      p_prop_base_source_id         IN        base source ID of the proposed object
 |      p_prorate_ratio               IN        Prorate Ratio
 |      p_date_eff_from               IN        quote effective date
 |      p_quote_id                    IN        Quote ID
 |      p_khr_id                      IN        Contract ID
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 14-OCT-2003           SECHAWLA          Created
 | 20-SEP-2004           SECHAWLA          3816891 Modified the payment
 |                                         calculation for Arrears
 *=======================================================================*/
  PROCEDURE calc_prop_line_payments( p_api_version           IN  NUMBER,
                                    x_msg_count             OUT NOCOPY NUMBER,
                                                x_msg_data              OUT NOCOPY VARCHAR2,
                                    p_curr_cfo_id           IN  NUMBER,
                                    p_prop_obj_type_code    IN  VARCHAR2,
                                    p_prop_base_source_id   IN  NUMBER,
                                    p_prorate_ratio         IN  NUMBER,
                                    p_date_eff_from         IN  DATE,
                                    p_quote_id              IN  NUMBER,
                                    p_khr_id                IN  NUMBER,
                                    x_return_status         OUT NOCOPY   VARCHAR2) IS

  /*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
   -- Get the current cashflows
    CURSOR l_cashflows_csr(cp_cfo_id IN NUMBER) IS
    -- SECHAWLA 20-SEP-04 3816891 : added nvl for due_arrears_yn
    SELECT caf.id, caf.sty_id, nvl(caf.due_arrears_yn, 'N') due_arrears_yn, cfl.start_date, caf.number_of_advance_periods,
           cfl.amount, cfl.number_of_periods, cfl.fqy_code, cfl.level_sequence, cfl.stub_days, cfl.stub_amount
    FROM   okl_cash_flows caf, okl_cash_flow_levels cfl
    WHERE  cfo_id = cp_cfo_id
    AND    caf.id = cfl.caf_id
    AND    caf.sts_code = G_CURRENT_STATUS
    AND    caf.cft_code = G_CASH_FLOW_TYPE
    ORDER  BY caf.sty_id, cfl.start_date;


    -- Get the start date of the last period
    CURSOR l_lastperiodstatdt_csr(cp_firstperiodstartdt IN DATE, cp_number_of_months IN NUMBER) IS
    SELECT add_months(cp_firstperiodstartdt,cp_number_of_months)
    FROM   DUAL;

    -- Get the number of months between period start dt and quote eff date
    CURSOR l_monthsuptodate_csr(cp_quote_eff_dt IN DATE, cp_period_start_dt IN DATE) IS
    SELECT months_between(cp_quote_eff_dt,cp_period_start_dt)
    FROM   DUAL;

 /*-----------------------------------------------------------------------+
 | SubType Declarations
 +-----------------------------------------------------------------------*/

    SUBTYPE qcov_rec_type IS okl_trx_qte_cf_objects_pub.qcov_rec_type;

 /*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_cfo_id                     NUMBER;
    l_pymt_Count                 NUMBER;
    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_prev_sty_id                NUMBER := -99;

    l_lowest_level_seq           NUMBER;
    l_number_of_months           NUMBER;
    lx_new_cash_flow             VARCHAR2(1);
    l_split_level                 VARCHAR2(1);
    l_months_between             NUMBER;
    l_new_periods                NUMBER ;
    l_new_stub_days              NUMBER ;
    l_first_period_start_date    DATE;
    l_remaining_periods          NUMBER ;
    l_remaining_stub_days        NUMBER ;

    l_new_amount                 NUMBER;
    l_new_stub_amount            NUMBER;
    l_new_seq                    NUMBER;
    l_curr_level_start_date      DATE;
    l_next_level_start_date      DATE;

    lp_qcov_rec                  qcov_rec_type;
    lx_qcov_rec                  qcov_rec_type;

    lp_cashflow_rec              cashflow_rec_type;

    --SECHAWLA 20-SEP-04 3816891 : new declaration
    l_months_to_check_last_day   NUMBER;

     L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'calc_prop_line_payments';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN
        IF (is_debug_procedure_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
        END IF;

        --Print Input Variables
        IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_curr_cfo_id :'||p_curr_cfo_id);
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_prop_obj_type_code :'||p_prop_obj_type_code);
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_prop_base_source_id :'||p_prop_base_source_id);
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_prorate_ratio :'||p_prorate_ratio);
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_date_eff_from :'||p_date_eff_from);
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_quote_id :'||p_quote_id);
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_khr_id :'||p_khr_id);
        END IF;

        l_pymt_Count := 0;
        -- Get the cash flows for the line, create cash flows and cash flow levels
        FOR l_cashflows_rec IN l_cashflows_csr(p_curr_cfo_id) LOOP
            l_pymt_Count := l_pymt_Count + 1;
            IF l_pymt_count = 1 THEN -- current asset line level payments exist
                -- create new line object
                l_cfo_id := NULL;
                create_cash_flow_object(
                                  p_api_version    => p_api_version,
                                  x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                  p_obj_type_code  => p_prop_obj_type_code,
                                  p_src_table      => G_OBJECT_SRC_TABLE,
                                  p_src_id         => p_quote_id,
                                  p_base_src_id    => p_prop_base_source_id,
                                  p_sts_code       => G_PROPOSED_STATUS,
                                  x_cfo_id         => l_cfo_id,
                                  x_return_status  => l_return_status);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to create_cash_flow_object :'||l_return_status);
                   END IF;

                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                -- Create quote cf object
                lp_qcov_rec.qte_id := p_quote_id;
                lp_qcov_rec.cfo_id := l_cfo_id;
                lp_qcov_rec.BASE_SOURCE_ID := p_prop_base_source_id;
                --Bug 4299668 PAGARG Instead of calling the procedure to insert
                --quote cash flow object, store the record in the table
                --**START**--
                g_qcov_counter := g_qcov_counter + 1;
                g_qcov_tbl_type(g_qcov_counter) := lp_qcov_rec;
                --**END 4299668**--
            END IF;

            l_new_stub_amount := NULL;
            l_new_amount := NULL;

             --SECHAWLA 20-SEP-04 3816891 : Initialize stub days and periods
            l_new_periods := NULL;
            l_new_stub_days := NULL;
            l_remaining_stub_days := NULL;
            l_remaining_periods := NULL;

            l_curr_level_start_date := l_cashflows_rec.start_date;

            IF  p_date_eff_from >= l_curr_level_start_date OR l_split_level = 'Y' THEN

                IF l_cashflows_rec.sty_id <> l_prev_sty_id THEN
                    lx_new_cash_flow := 'N';
                    l_prev_sty_id := l_cashflows_rec.sty_id;
                    l_split_level := 'N';
                    --l_curr_level_start_date := l_cashflows_rec.start_date;
                END IF;

                IF l_split_level = 'Y' THEN
                   IF  l_cashflows_rec.stub_days IS NULL THEN
                       l_new_amount := l_cashflows_rec.amount * p_prorate_ratio;
                   ELSE
                       l_new_stub_amount := l_cashflows_rec.stub_amount *  p_prorate_ratio;
                   END IF;

                   lp_cashflow_rec.p_cfo_id := l_cfo_id;
                   lp_cashflow_rec.p_sts_code := G_PROPOSED_STATUS;
                   lp_cashflow_rec.p_sty_id := l_cashflows_rec.sty_id;
                   lp_cashflow_rec.p_due_arrears_yn := l_cashflows_rec.due_arrears_yn;
                   lp_cashflow_rec.p_start_date := l_cashflows_rec.start_date;
                   lp_cashflow_rec.p_advance_periods := l_cashflows_rec.number_of_advance_periods;
                   lp_cashflow_rec.p_khr_id := p_khr_id;
                   lp_cashflow_rec.p_quote_id := p_quote_id;
                   lp_cashflow_rec.p_amount := l_new_amount;
                   lp_cashflow_rec.p_period_in_months := l_cashflows_rec.number_of_periods;
                   lp_cashflow_rec.p_frequency := l_cashflows_rec.fqy_code;
                   lp_cashflow_rec.p_seq_num := l_cashflows_rec.level_sequence;
                   lp_cashflow_rec.p_stub_days := l_cashflows_rec.stub_days;
                   lp_cashflow_rec.p_stub_amount := l_new_stub_amount;

                   create_cash_flows(
                            p_api_version           => p_api_version,
                            x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                            p_cashflow_rec          => lp_cashflow_rec,
                            px_new_cash_flow        => lx_new_cash_flow,
                            x_return_status         => l_return_status);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to create_cash_flows:'||l_return_status);
                   END IF;

                    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                    ----

                ELSE

                    IF l_cashflows_rec.stub_days IS NULL THEN

                        -- get the number of months that a payment covers
                        IF  l_cashflows_rec.fqy_code = 'M' THEN
                            l_number_of_months := (l_cashflows_rec.number_of_periods);
                        ELSIF l_cashflows_rec.fqy_code = 'Q' THEN
                            l_number_of_months := (l_cashflows_rec.number_of_periods) * 3;
                        ELSIF l_cashflows_rec.fqy_code = 'S' THEN
                            l_number_of_months := (l_cashflows_rec.number_of_periods) * 6;
                        ELSIF l_cashflows_rec.fqy_code = 'A' THEN
                            l_number_of_months := (l_cashflows_rec.number_of_periods) * 12;
                        END IF;

                        -- add months
                        -- Get the first date after the last level period ends
                        OPEN  l_lastperiodstatdt_csr(l_curr_level_start_date, l_number_of_months);
                        FETCH l_lastperiodstatdt_csr INTO l_next_level_start_date;
                        CLOSE l_lastperiodstatdt_csr;

                    ELSE
                        -- sechawla 20-SEP-04  3816891 : still ok, no changes
                        l_next_level_start_date := l_curr_level_start_date + l_cashflows_rec.stub_days;
                    END IF;

                    IF p_date_eff_from >= l_next_level_start_date THEN -- sechawla 20-SEP-04 3816891 : still ok, no changes
                        -- keep the whole payment
                        -- Create the payment header with same details as the current payment

                        lp_cashflow_rec.p_cfo_id := l_cfo_id;
                        lp_cashflow_rec.p_sts_code := G_PROPOSED_STATUS;
                        lp_cashflow_rec.p_sty_id := l_cashflows_rec.sty_id;
                        lp_cashflow_rec.p_due_arrears_yn := l_cashflows_rec.due_arrears_yn;
                        lp_cashflow_rec.p_start_date := l_cashflows_rec.start_date;
                        lp_cashflow_rec.p_advance_periods := l_cashflows_rec.number_of_advance_periods;
                        lp_cashflow_rec.p_khr_id := p_khr_id;
                        lp_cashflow_rec.p_quote_id := p_quote_id;
                        lp_cashflow_rec.p_amount := l_cashflows_rec.amount;
                        lp_cashflow_rec.p_period_in_months := l_cashflows_rec.number_of_periods;
                        lp_cashflow_rec.p_frequency := l_cashflows_rec.fqy_code;
                        lp_cashflow_rec.p_seq_num := l_cashflows_rec.level_sequence;
                        lp_cashflow_rec.p_stub_days := l_cashflows_rec.stub_days;
                        lp_cashflow_rec.p_stub_amount := l_cashflows_rec.stub_amount;

                        create_cash_flows(
                            p_api_version           => p_api_version,
                            x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                            p_cashflow_rec          => lp_cashflow_rec,
                            px_new_cash_flow        => lx_new_cash_flow,
                            x_return_status         => l_return_status);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to create_cash_flows :'||l_return_status);
                   END IF;

                        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;

                    ELSIF p_date_eff_from >= l_curr_level_start_date AND p_date_eff_from < l_next_level_start_date THEN

                        IF l_cashflows_rec.stub_days is NULL THEN

                            -- keep the number of months upto the termination quote date
                            OPEN  l_monthsuptodate_csr(p_date_eff_from, l_curr_level_start_date);
                            FETCH l_monthsuptodate_csr INTO l_months_between;
                            CLOSE l_monthsuptodate_csr;

                            IF l_months_between = CEIL(l_months_between) THEN

                                IF l_cashflows_rec.due_arrears_yn = 'N' THEN  -- SECHAWLA 20-SEP-04 3816891: bump up the month count only if payment is in ADV

                                    -- Include payments for the whole month if quote was created on the first day
                                    -- of the period
                                    l_months_between := l_months_between + 1;
                                ELSE  -- SECHAWLA 20-SEP-04  3816891
                                    NULL; -- SECHAWLA 20-SEP-04 3816891 do not bump up the month count. Month count is a whole number here
                                          -- l_months_between can also be zero here if the quote was created on the first pymnt date
                                END IF;  -- SECHAWLA 20-SEP-04  3816891
                            ELSE

                                -- quote not created on the first day of the period

                                -- -- SECHAWLA 20-SEP-04  3816891

                                IF l_cashflows_rec.due_arrears_yn = 'Y' THEN  -- Arrears
                                    -- Get the number of months between quote eff date+1 and the curret level start date
                                    -- This is to check if the quote effective date is the last date of the current level period (M/Q/S/A)
                                    OPEN  l_monthsuptodate_csr(p_date_eff_from + 1, l_curr_level_start_date);
                                    FETCH l_monthsuptodate_csr INTO l_months_to_check_last_day;
                                    CLOSE l_monthsuptodate_csr;

                                    IF     l_cashflows_rec.fqy_code = 'M' THEN
                                           IF l_months_to_check_last_day <> ceil(l_months_to_check_last_day) THEN
                                              -- SECHAWLA 20-SEP-04 3816891, date effective was not the last day of the current level period
                                              l_months_between := FLOOR(l_months_between);
                                           ELSE
                                              -- SECHAWLA 20-SEP-04 3816891, date effective was the last day of the current level period
                                              l_months_between := CEIL(l_months_between);
                                           END IF;

                                    ELSIF  l_cashflows_rec.fqy_code = 'Q' THEN
                                           IF (l_months_to_check_last_day/3) <> ceil(l_months_to_check_last_day/3) THEN
                                              l_months_between := FLOOR(l_months_between); -- SECHAWLA 20-SEP-04 3816891
                                           ELSE
                                              l_months_between := CEIL(l_months_between);
                                           END IF;
                                    ELSIF  l_cashflows_rec.fqy_code = 'S' THEN
                                           IF (l_months_to_check_last_day/6) <> ceil(l_months_to_check_last_day/6) THEN
                                              l_months_between := FLOOR(l_months_between); -- SECHAWLA 20-SEP-04 3816891
                                           ELSE
                                              l_months_between := CEIL(l_months_between);
                                           END IF;
                                    ELSIF  l_cashflows_rec.fqy_code = 'A' THEN
                                           IF (l_months_to_check_last_day/12) <> ceil(l_months_to_check_last_day/12) THEN
                                              l_months_between := FLOOR(l_months_between); -- SECHAWLA 20-SEP-04 3816891
                                           ELSE
                                              l_months_between := CEIL(l_months_between);
                                           END IF;
                                    END IF;
                                ELSE -- Advance
                                    l_months_between := CEIL(l_months_between);
                                END IF;

                            END IF;

                            IF  l_cashflows_rec.fqy_code = 'M' THEN
                                l_new_periods := l_months_between;
                            ELSIF l_cashflows_rec.fqy_code = 'Q' THEN
                                IF l_cashflows_rec.due_arrears_yn = 'Y' THEN -- SECHAWLA 20-SEP-04 3816891
                                   l_new_periods := floor(l_months_between / 3); -- SECHAWLA 20-SEP-04 3816891
                                ELSE -- SECHAWLA 20-SEP-04 3816891
                                   l_new_periods := ceil(l_months_between / 3);
                                END IF; -- SECHAWLA 20-SEP-04 3816891

                            ELSIF l_cashflows_rec.fqy_code = 'S' THEN
                                IF l_cashflows_rec.due_arrears_yn = 'Y' THEN -- SECHAWLA 20-SEP-04 3816891
                                   l_new_periods := floor(l_months_between / 6); -- SECHAWLA 20-SEP-04  3816891
                                ELSE -- SECHAWLA 20-SEP-04   3816891
                                   l_new_periods := ceil(l_months_between / 6);
                                END IF; -- SECHAWLA 20-SEP-04 3816891

                            ELSIF l_cashflows_rec.fqy_code = 'A' THEN
                                IF l_cashflows_rec.due_arrears_yn = 'Y' THEN -- SECHAWLA 20-SEP-04 3816891
                                   l_new_periods := floor(l_months_between / 12);-- SECHAWLA 20-SEP-04 3816891
                                ELSE -- SECHAWLA 20-SEP-04 3816891
                                   l_new_periods := ceil(l_months_between / 12);
                                END IF; -- SECHAWLA 20-SEP-04 3816891

                            END IF;

                        ELSE
                            -- -- SECHAWLA 20-SEP-04  3816891 START
                            -- l_new_stub_days will either be = total stub days of that level (l_cashflows_rec.stub_days)
                            -- or be 0.  Stub payment level will not be split
                            IF l_cashflows_rec.due_arrears_yn = 'N' THEN -- Advance, -- SECHAWLA 20-SEP-04  3816891
                               l_new_stub_days := l_cashflows_rec.stub_days; -- SECHAWLA 20-SEP-04 3816891 keep the whole stub period
                            ELSE -- Arrears, SECHAWLA 20-SEP-04  3816891
                               IF p_date_eff_from = l_next_level_start_date - 1 THEN -- quote created on the last day of the stub level
                                  l_new_stub_days := l_cashflows_rec.stub_days; -- SECHAWLA 20-SEP-04 3816891 keep the whole stub period
                               ELSE
                                  l_new_stub_days := 0;
                               END IF;
                            END IF;
                            --l_new_stub_days := (p_date_eff_from - l_curr_level_start_date) + 1 ; -- SECHAWLA 20-SEP-04 3816891 :commneted out
                            -- SECHAWLA 20-SEP-04 3816891: END

                        END IF;

                        IF l_new_periods > 0 OR l_new_stub_days > 0 THEN -- SECHAWLA 20-SEP-04 3816891: added this check
                        -- new periods /stub days will be 0 in the scenario where payments are in arrears and quote
                        -- is created before the last date of the first payment period. e.g
                        -- 01-jan-04  3  100
                        -- 01-apr-04  2  80
                        -- 01-jun-04  2  50
                        -- quote created between 01-jan-04 and 30-jan-04
                        -- In this case for full line termination, there won't be any payments
                        -- or partial line termination, new payments would be -
                        -- 01-jan-04  3  50
                        -- 01-apr-04  2  40
                        -- 01-jun-04  2  25

                            lp_cashflow_rec.p_cfo_id := l_cfo_id;
                            lp_cashflow_rec.p_sts_code := G_PROPOSED_STATUS;
                            lp_cashflow_rec.p_sty_id := l_cashflows_rec.sty_id;
                            lp_cashflow_rec.p_due_arrears_yn := l_cashflows_rec.due_arrears_yn;
                            lp_cashflow_rec.p_start_date := l_cashflows_rec.start_date;
                            lp_cashflow_rec.p_advance_periods := l_cashflows_rec.number_of_advance_periods;
                            lp_cashflow_rec.p_khr_id := p_khr_id;
                            lp_cashflow_rec.p_quote_id := p_quote_id;
                            lp_cashflow_rec.p_amount := l_cashflows_rec.amount;
                            lp_cashflow_rec.p_period_in_months := l_new_periods;
                            lp_cashflow_rec.p_frequency := l_cashflows_rec.fqy_code;
                            lp_cashflow_rec.p_seq_num := l_cashflows_rec.level_sequence;
                            lp_cashflow_rec.p_stub_days := l_new_stub_days;
                            lp_cashflow_rec.p_stub_amount := l_cashflows_rec.stub_amount;

                            --create cash flow with new number of periods, same start date, same amount and status = 'PROPOSED'
                            create_cash_flows(
                                p_api_version           => p_api_version,
                                x_msg_count             => x_msg_count,
                                            x_msg_data              => x_msg_data,
                                p_cashflow_rec          => lp_cashflow_rec,
                                px_new_cash_flow        => lx_new_cash_flow,
                                x_return_status         => l_return_status);

                                IF (is_debug_statement_on) THEN
                                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                                 'after call to create_cash_flows :'||l_return_status);
                                 END IF;

                            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_ERROR;
                            END IF;
                        END IF;  --  IF l_new_periods > 0 OR l_new_stub_days > 0 THEN -- SECHAWLA 20-SEP-04 3816891: added this check


                        IF l_cashflows_rec.stub_days IS NULL THEN
                            l_remaining_periods := l_cashflows_rec.number_of_periods - l_new_periods;

                        ELSE
                            l_remaining_stub_days := l_cashflows_rec.stub_days - l_new_stub_days;
                        END IF;

                        -- SECHAWLA 20-SEP-04 3816891: l_remaining_stub_days will either be 0 (if whole stub level was retained)
                        -- OR l_remaining_stub_days will be = total stub days on that level (if whole stub level was excuded, as in Arrears)

                        IF p_prorate_ratio > 0 THEN  -- partial line termination
                           l_split_level := 'Y';
                        END IF;
                        -- create a new split level
                        IF l_remaining_periods > 0 OR l_remaining_stub_days > 0  THEN

                        -- In case of termination with full asset qty, there will be no more payments after the
                        -- quote effective date. In case of partial line termination, when the quote eff dt is
                        -- between the level start date and end date, the payment level will be split into 2
                        -- levels.
                            IF p_prorate_ratio > 0 THEN  -- partial line termination
                                -- Get the start date of the first period after the split happens

                                IF  l_cashflows_rec.stub_days IS NULL THEN
                                    IF  l_cashflows_rec.fqy_code = 'M' THEN
                                        -- add months
                                        OPEN  l_lastperiodstatdt_csr(l_curr_level_start_date, l_new_periods);
                                        FETCH l_lastperiodstatdt_csr INTO l_first_period_start_date;
                                        CLOSE l_lastperiodstatdt_csr;
                                    ELSIF l_cashflows_rec.fqy_code = 'Q' THEN
                                        -- add months
                                        OPEN  l_lastperiodstatdt_csr(l_curr_level_start_date, l_new_periods*3);
                                        FETCH l_lastperiodstatdt_csr INTO l_first_period_start_date;
                                        CLOSE l_lastperiodstatdt_csr;
                                    ELSIF l_cashflows_rec.fqy_code = 'S' THEN
                                        -- add months
                                        OPEN  l_lastperiodstatdt_csr(l_curr_level_start_date, l_new_periods*6);
                                        FETCH l_lastperiodstatdt_csr INTO l_first_period_start_date;
                                        CLOSE l_lastperiodstatdt_csr;
                                    ELSIF l_cashflows_rec.fqy_code = 'A' THEN
                                        -- add months
                                        OPEN  l_lastperiodstatdt_csr(l_curr_level_start_date, l_new_periods*12);
                                        FETCH l_lastperiodstatdt_csr INTO l_first_period_start_date;
                                        CLOSE l_lastperiodstatdt_csr;
                                    END IF;

                                ELSE

                                    -- l_first_period_start_date := p_date_eff_from + 1; -- SECHAWLA 20-SEP-04 3816891: commented out

                                    -- SECHAWLA 20-SEP-04 3816891: At this point, l_new_stub_days will always be 0. So the
                                    -- l_first_period_start_date will be = start date of that stub level
                                    l_first_period_start_date := l_curr_level_start_date + l_new_stub_days ;
                                END IF;

                                IF  l_cashflows_rec.stub_days IS NULL THEN
                                    l_new_amount := l_cashflows_rec.amount * p_prorate_ratio;

                                ELSE
                                    l_new_stub_amount := l_cashflows_rec.stub_amount *  p_prorate_ratio;
                                END IF;

                                --     l_new_seq :=  l_cashflows_rec.level_sequence + l_lowest_level_seq;

                                -- create cash flow with new number of periods (l_remaining_periods), new start date (l_first_period_start_date)
                                -- new amount (l_new_amount), new seq number  and status = 'PROPOSED'
                                -- This call to create_cash_flow procedure will just create the new level in cash flow levels
                                -- for the same header.

                                lp_cashflow_rec.p_cfo_id := l_cfo_id;
                                lp_cashflow_rec.p_sts_code := G_PROPOSED_STATUS;
                                lp_cashflow_rec.p_sty_id := l_cashflows_rec.sty_id;
                                lp_cashflow_rec.p_due_arrears_yn := l_cashflows_rec.due_arrears_yn;
                                lp_cashflow_rec.p_start_date := l_first_period_start_date;
                                lp_cashflow_rec.p_advance_periods := l_cashflows_rec.number_of_advance_periods;
                                lp_cashflow_rec.p_khr_id := p_khr_id;
                                lp_cashflow_rec.p_quote_id := p_quote_id;
                                lp_cashflow_rec.p_amount := l_new_amount;
                                lp_cashflow_rec.p_period_in_months := l_remaining_periods;
                                lp_cashflow_rec.p_frequency := l_cashflows_rec.fqy_code;
                              --  lp_cashflow_rec.p_seq_num := l_cashflows_rec.level_sequence;
                                lp_cashflow_rec.p_stub_days := l_remaining_stub_days;
                                lp_cashflow_rec.p_stub_amount := l_new_stub_amount;

                                create_cash_flows(
                                    p_api_version           => p_api_version,
                                    x_msg_count             => x_msg_count,
                                                x_msg_data              => x_msg_data,
                                    p_cashflow_rec          => lp_cashflow_rec,
                                    px_new_cash_flow        => lx_new_cash_flow,
                                    x_return_status         => l_return_status);

                                IF (is_debug_statement_on) THEN
                                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                                 'after call to create_cash_flows :'||l_return_status);
                                 END IF;

                                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                    RAISE OKL_API.G_EXCEPTION_ERROR;
                                END IF;
                        -----------

                            END IF;
                        END IF; -- l_remaining_periods > 0

                END IF;   -- IF p_date_eff_from >= l_next_level_start_date THEN
             END IF; -- p_split_level = 'Y'

            END IF;  -- IF  p_date_eff_from >= l_curr_level_start_date THEN

          -- commented because the start date is now stored at the levels
       --   l_curr_level_start_date := l_next_level_start_date;
        END LOOP;

   x_return_status := l_return_status;

   IF (is_debug_procedure_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

       IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
       END IF;

       IF l_cashflows_csr%ISOPEN THEN
          CLOSE l_cashflows_csr;
       END IF;
       IF l_lastperiodstatdt_csr%ISOPEN THEN
          CLOSE l_lastperiodstatdt_csr;
       END IF;
       IF l_monthsuptodate_csr%ISOPEN THEN
          CLOSE l_monthsuptodate_csr;
       END IF;

       x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

       IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
       END IF;

       IF l_cashflows_csr%ISOPEN THEN
          CLOSE l_cashflows_csr;
       END IF;
       IF l_lastperiodstatdt_csr%ISOPEN THEN
          CLOSE l_lastperiodstatdt_csr;
       END IF;
       IF l_monthsuptodate_csr%ISOPEN THEN
          CLOSE l_monthsuptodate_csr;
       END IF;

       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN

       IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||sqlerrm);
       END IF;

       IF l_cashflows_csr%ISOPEN THEN
        CLOSE l_cashflows_csr;
       END IF;
       IF l_lastperiodstatdt_csr%ISOPEN THEN
          CLOSE l_lastperiodstatdt_csr;
       END IF;
       IF l_monthsuptodate_csr%ISOPEN THEN
          CLOSE l_monthsuptodate_csr;
       END IF;

       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       -- unexpected error
     OKL_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
  END calc_prop_line_payments;

 /*========================================================================
 | PRIVATE PROCEDURE calc_proposed_payments
 |
 | DESCRIPTION
 |    This is the main procedure to calculate and store revised payments for a termination quote
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     calc_quote_payments
 |
 | CALLS PROCEDURES/FUNCTIONS
 |     create_cash_flow_object, create_cash_flows, calc_prop_line_payments
 |
 | PARAMETERS
 |      p_quote_id                    IN        Quote ID
 |      p_khr_id                      IN        Contarct ID
 |      p_date_eff_from               IN        quote effective date
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date         Author      Description of Changes
 | 14-OCT-2003  SECHAWLA    Created
 | 29-SEP-2004  pagarg      Bug #3921591
 |                          Added logic to calculate porposed payments for
 |                          fee asset line and modified the logic for fee line
 |                          to consider the assets associated with the fee,
 *=======================================================================*/
  PROCEDURE calc_proposed_payments(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_quote_id          IN  NUMBER,
    p_khr_id            IN  NUMBER,
    p_date_eff_from     IN  DATE) AS

 /*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    --Bug #3921591: pagarg +++ Rollover +++
    -- Modified the cursor to obtain booked assets with the given line type
    -- Get all the booked assets associated with the given line type
    CURSOR l_lineassets_csr(cp_line_id IN NUMBER, cp_line_type_code IN VARCHAR2) IS
    SELECT cim.object1_id1, cle.id
    FROM   okc_k_lines_b cle, okc_line_styles_b lse, okc_k_items cim
    WHERE  cle.lse_id = lse.id
    AND    lse.lty_code = cp_line_type_code
    AND    cim.cle_id = cle.id
    AND    cle.cle_id = cp_line_id
    AND    cle.sts_code = 'BOOKED';

    -- Check if an asset belongs to a quote
    CURSOR l_assetinquote_csr(cp_quote_id IN NUMBER, cp_kle_id IN NUMBER) IS
    SELECT id,
    --kle_id,
    asset_quantity, quote_quantity
    FROM   okl_txl_quote_lines_b
    WHERE  qte_id = cp_quote_id
    AND    qlt_code = 'AMCFIA'
    AND    kle_id = cp_kle_id;

    --Bug #3921591: pagarg +++ Rollover +++
    -- Modified the cursor to obtain financial assets with the given line type
    -- Get the financial asset associated with a given line type asset line (subline)
    CURSOR l_finasset_csr(cp_fee_serviced_asset_line_id IN NUMBER, cp_line_type IN VARCHAR2) IS
    SELECT cim.object1_id1
    FROM   okc_k_lines_b cle, okc_line_styles_b lse, okc_k_items cim
    WHERE  cle.lse_id = lse.id
    AND    lse.lty_code = cp_line_type
    AND    cim.cle_id = cle.id
    AND    cle.id = cp_fee_serviced_asset_line_id;

    -- get current payment objects of a particular type
    CURSOR l_currpymtobjects_csr(cp_oty_code IN VARCHAR2, cp_quote_id IN NUMBER) IS
    SELECT DISTINCT cfo.id, qco.base_source_id
    FROM   okl_cash_flow_objects cfo, okl_cash_flows caf, OKL_TRX_QTE_CF_OBJECTS qco
    WHERE  cfo.id = caf.cfo_id
    AND    cfo.id = qco.cfo_id
    AND    cfo.oty_code = cp_oty_code
    AND    cfo.source_table = G_OBJECT_SRC_TABLE
    AND    cfo.source_id = cp_quote_id
    AND    caf.sts_code = G_CURRENT_STATUS
    AND    caf.cft_code = G_CASH_FLOW_TYPE;

    -- get the payment lines for a given object
    CURSOR l_currpymtlines_csr(cp_obj_id IN NUMBER) IS
    SELECT caf.sty_id, caf.due_arrears_yn, cfl.start_date, caf.number_of_advance_periods, cfl.amount,
           cfl.number_of_periods, cfl.fqy_code, cfl.level_Sequence, cfl.stub_days, cfl.stub_amount
    FROM   okl_cash_flows caf, okl_cash_flow_levels cfl
    WHERE  caf.id = cfl.caf_id
    AND    caf.cfo_id = cp_obj_id
    ORDER  BY caf.sty_id, cfl.start_date;

 /*-----------------------------------------------------------------------+
 | SubType Declarations                                                   |
 +-----------------------------------------------------------------------*/

    SUBTYPE qcov_rec_type IS okl_trx_qte_cf_objects_pub.qcov_rec_type;

 /*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    lp_qcov_rec                  qcov_rec_type;
    lx_qcov_rec                  qcov_rec_type;

    l_cfo_id                     NUMBER;
    l_pymt_Count                 NUMBER;
    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_prev_sty_id                NUMBER := -99;

    lx_new_cash_flow             VARCHAR2(1);

    l_prorate_ratio              NUMBER;
    l_count                      NUMBER;
    l_total_curr_cost            NUMBER;
    l_total_new_cost             NUMBER;
    l_curr_cap_cost              NUMBER;
    l_new_cap_cost               NUMBER;
    l_asset_quantity             NUMBER;
    l_quote_quantity             NUMBER;
    l_quote_line_id              NUMBER;

    l_fin_asset_id               NUMBER;
    lp_cashflow_rec              cashflow_rec_type;
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'calc_proposed_payments';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   --Print Input Variables
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_quote_id :'||p_quote_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_khr_id :'||p_khr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_date_eff_from :'||p_date_eff_from);
   END IF;

   -------------------------- Get proposed K Level payments ----------------------------------

   -- Get the current contract object for which the payment exists
   -------------
   FOR l_currpymtobjects_rec IN l_currpymtobjects_csr(G_CONTRACT_OBJ_TYPE, p_quote_id) LOOP
      l_pymt_Count := 0;

      -- get the payment lines for contract object, create proposed object, proposed cash flows and proposed
      -- cash flow levels
      FOR l_currpymtlines_rec IN l_currpymtlines_csr(l_currpymtobjects_rec.id) LOOP

        l_pymt_count := l_pymt_count + 1;

        IF l_pymt_count = 1 THEN -- K level payments exist, create a K Object

            create_cash_flow_object(p_api_version    => p_api_version,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_obj_type_code  => G_CONTRACT_OBJ_TYPE,
                                  p_src_table      => G_OBJECT_SRC_TABLE,
                                  p_src_id         => p_quote_id,
                                  p_base_src_id    => p_khr_id,
                                  p_sts_code       => G_PROPOSED_STATUS,
                                  x_cfo_id         => l_cfo_id,
                                  x_return_status  => l_return_status);

            IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                  'after call to create_cash_flow_object :'||l_return_status);
            END IF;


            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            lp_qcov_rec.qte_id := p_quote_id;
            lp_qcov_rec.cfo_id := l_cfo_id;
            lp_qcov_rec.BASE_SOURCE_ID := p_khr_id;
            --Bug 4299668 PAGARG Instead of calling the procedure to insert
            --quote cash flow object, store the record in the table
            --**START**--
            g_qcov_counter := g_qcov_counter + 1;
            g_qcov_tbl_type(g_qcov_counter) := lp_qcov_rec;
            --**END 4299668**--
         END IF;

         IF  l_currpymtlines_rec.sty_id <> l_prev_sty_id THEN
             lx_new_cash_flow := 'N';
             l_prev_sty_id := l_currpymtlines_rec.sty_id;
         END IF;

         lp_cashflow_rec.p_cfo_id := l_cfo_id;
         lp_cashflow_rec.p_sts_code := G_PROPOSED_STATUS;
         lp_cashflow_rec.p_sty_id := l_currpymtlines_rec.sty_id;
         lp_cashflow_rec.p_due_arrears_yn := l_currpymtlines_rec.due_arrears_yn;
         lp_cashflow_rec.p_start_date := l_currpymtlines_rec.start_date;
         lp_cashflow_rec.p_advance_periods := l_currpymtlines_rec.number_of_advance_periods;
         lp_cashflow_rec.p_khr_id := p_khr_id;
         lp_cashflow_rec.p_quote_id := p_quote_id;
         lp_cashflow_rec.p_amount := l_currpymtlines_rec.amount;
         lp_cashflow_rec.p_period_in_months := l_currpymtlines_rec.number_of_periods;
         lp_cashflow_rec.p_frequency := l_currpymtlines_rec.fqy_code;
         lp_cashflow_rec.p_seq_num := l_currpymtlines_rec.level_sequence;
         lp_cashflow_rec.p_stub_days := l_currpymtlines_rec.stub_days;
         lp_cashflow_rec.p_stub_amount := l_currpymtlines_rec.stub_amount;

         create_cash_flows(   p_api_version           => p_api_version,
                            x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                            p_cashflow_rec          => lp_cashflow_rec,
                            px_new_cash_flow        => lx_new_cash_flow,
                            x_return_status         => l_return_status);

            IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                  'after call to create_cash_flows:'||l_return_status);
            END IF;

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

     END LOOP;
  END LOOP;

   ---------------------------end proposed contract level payments ----------------------


   -------------------------- Get the proposed asset line payments ------------------------
   -- Get the current financial asset lines objects for which the payment exists
   FOR l_currpymtobjects_rec IN l_currpymtobjects_csr(G_FIN_ASSET_OBJ_TYPE, p_quote_id) LOOP

       -- Check if asset line is included in the quote
       OPEN   l_assetinquote_csr(p_quote_id, l_currpymtobjects_rec.base_source_id);
       FETCH  l_assetinquote_csr INTO l_quote_line_id, l_asset_quantity, l_quote_quantity;  -- not using thsese ?
       IF  l_assetinquote_csr%FOUND THEN
           l_prorate_ratio :=  (l_asset_quantity - l_quote_quantity) / l_asset_quantity;
           -- Prorate ratio can not be 1 as quote quantity will not be 0
           IF l_prorate_ratio >= 0 AND l_prorate_ratio < 1 THEN

             -- Get the new asset line level payments
              calc_prop_line_payments( p_api_version           =>    p_api_version,
                                       x_msg_count             =>    x_msg_count,
                                       x_msg_data              =>    x_msg_data,
                                       p_curr_cfo_id           =>    l_currpymtobjects_rec.id,
                                       p_prop_obj_type_code    =>    G_FIN_ASSET_OBJ_TYPE,
                                       p_prop_base_source_id   =>    l_currpymtobjects_rec.base_source_id,
                                       p_prorate_ratio         =>    l_prorate_ratio,
                                       p_date_eff_from         =>    p_date_eff_from,
                                       p_quote_id              =>    p_quote_id,
                                       p_khr_id                =>    p_khr_id ,
                                       x_return_status         =>    l_return_status);

              IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                  'after call to calc_prop_line_payments :'||l_return_status);
             END IF;
              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
          END IF;
      ELSE
               --
            l_prev_sty_id := -99;

            l_pymt_Count := 0;
            -- get the current payemnts for the financila asset and store them as proposed
            FOR l_currpymtlines_rec IN l_currpymtlines_csr(l_currpymtobjects_rec.id) LOOP
                l_pymt_Count := l_pymt_Count + 1;
                IF l_pymt_count = 1 THEN -- line level payments exist

                    l_cfo_id := NULL;

                    create_cash_flow_object(
                                  p_api_version    => p_api_version,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_obj_type_code  => G_FIN_ASSET_OBJ_TYPE,
                                  p_src_table      => G_OBJECT_SRC_TABLE,
                                  p_src_id         => p_quote_id,
                                  p_base_src_id    => l_currpymtobjects_rec.base_source_id,
                                  p_sts_code       => G_PROPOSED_STATUS,
                                  x_cfo_id         => l_cfo_id,
                                  x_return_status  => l_return_status);

                        IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                         'after call to calc_prop_line_payments :'||l_return_status);
                         END IF;


                    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    lp_qcov_rec.qte_id := p_quote_id;
                    lp_qcov_rec.cfo_id := l_cfo_id;
                    lp_qcov_rec.BASE_SOURCE_ID := l_currpymtobjects_rec.base_source_id;
                    --Bug 4299668 PAGARG Instead of calling the procedure to insert
                    --quote cash flow object, store the record in the table
                    --**START**--
                    g_qcov_counter := g_qcov_counter + 1;
                    g_qcov_tbl_type(g_qcov_counter) := lp_qcov_rec;
                    --**END 4299668**--
                END IF;

                IF l_currpymtlines_rec.sty_id <> l_prev_sty_id THEN
                    lx_new_cash_flow := 'N';
                    l_prev_sty_id := l_currpymtlines_rec.sty_id;
                END IF;

                lp_cashflow_rec.p_cfo_id                := l_cfo_id;
                lp_cashflow_rec.p_sts_code              := G_PROPOSED_STATUS;
                lp_cashflow_rec.p_sty_id                := l_currpymtlines_rec.sty_id;
                lp_cashflow_rec.p_due_arrears_yn        := l_currpymtlines_rec.due_arrears_yn;
                lp_cashflow_rec.p_start_date            := l_currpymtlines_rec.start_date;
                lp_cashflow_rec.p_advance_periods       := l_currpymtlines_rec.number_of_advance_periods;
                lp_cashflow_rec.p_khr_id                := p_khr_id;
                lp_cashflow_rec.p_quote_id              := p_quote_id;
                lp_cashflow_rec.p_amount                := l_currpymtlines_rec.amount;
                lp_cashflow_rec.p_period_in_months              := l_currpymtlines_rec.number_of_periods;
                lp_cashflow_rec.p_frequency := l_currpymtlines_rec.fqy_code;
                lp_cashflow_rec.p_seq_num := l_currpymtlines_rec.level_sequence;
                lp_cashflow_rec.p_stub_days := l_currpymtlines_rec.stub_days;
                lp_cashflow_rec.p_stub_amount := l_currpymtlines_rec.stub_amount;

                create_cash_flows(      p_api_version           => p_api_version,
                                        x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                                        p_cashflow_rec          => lp_cashflow_rec,
                                        px_new_cash_flow        => lx_new_cash_flow,
                                        x_return_status         => l_return_status);

                IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'after call to create_cash_flows :'||l_return_status);
                 END IF;


                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

            END LOOP;
       ---------------

        END IF;
        CLOSE l_assetinquote_csr;
   END LOOP;

    -------------------------- Get the proposed service line payments ------------------------
   -- get all the service lines for which current payment exists

   FOR l_currpymtobjects_rec IN l_currpymtobjects_csr(G_SERVICE_LINE_OBJ_TYPE, p_quote_id) LOOP

       l_count := 0;
       l_total_curr_cost := 0;
       l_total_new_cost := 0;

       --Bug #3921591: pagarg +++ Rollover +++
       -- Modified the cursor call to pass line type also
       -- Get all the booked assets associated with the service line
       FOR l_servicelineassets_rec IN l_lineassets_csr(l_currpymtobjects_rec.base_source_id, G_LINKED_SERVICE_LINE_TYPE) LOOP
           l_count := l_count + 1 ;

           -- get the capitalize cost of the asset

           OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => p_api_version,
                                       p_init_msg_list =>  OKL_API.G_FALSE,
                                       x_return_status => l_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data,
                                       p_formula_name  => 'LINE_CAP_AMNT',
                                       p_contract_id   => p_khr_id,
                                       p_line_id       => l_servicelineassets_rec.object1_id1,
                                       x_value         => l_curr_cap_cost);


                IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'after call to OKL_EXECUTE_FORMULA_PUB.EXECUTE :'||l_return_status);
                 END IF;

           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           -- Check if asset belongs to the quote
           OPEN  l_assetinquote_csr(p_quote_id, l_servicelineassets_rec.object1_id1);
           FETCH l_assetinquote_csr INTO l_quote_line_id, l_asset_quantity, l_quote_quantity;
           IF  l_assetinquote_csr%NOTFOUND THEN
               l_new_cap_cost := l_curr_cap_cost;
           ELSE
               IF l_asset_quantity = l_quote_quantity THEN
                  l_new_cap_cost := 0;
               ELSE
                  l_new_cap_cost := (l_curr_cap_cost / l_asset_quantity) * (l_asset_quantity - l_quote_quantity);
               END IF;
           END IF;
           CLOSE l_assetinquote_csr;

           l_total_curr_cost :=  l_total_curr_cost + l_curr_cap_cost ;
           l_total_new_cost := l_total_new_cost +  l_new_cap_cost;

       END LOOP;

       IF l_count > 0 THEN -- assets associated with service line

          l_prorate_ratio := l_total_new_cost / l_total_curr_cost;

          IF l_prorate_ratio >= 0 AND l_prorate_ratio < 1 THEN

                calc_prop_line_payments( p_api_version           =>    p_api_version,
                               x_msg_count             =>    x_msg_count,
                                           x_msg_data              =>    x_msg_data,
                               p_curr_cfo_id           =>    l_currpymtobjects_rec.id,
                               p_prop_obj_type_code    =>    G_SERVICE_LINE_OBJ_TYPE,
                               p_prop_base_source_id   =>    l_currpymtobjects_rec.base_source_id,
                               p_prorate_ratio         =>    l_prorate_ratio,
                               p_date_eff_from         =>    p_date_eff_from,
                               p_quote_id              =>    p_quote_id,
                               p_khr_id                =>    p_khr_id ,
                               x_return_status         =>    l_return_status);

                IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'after call to calc_prop_line_payments :'||l_return_status);
                 END IF;

                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            END IF;
            ---
       END IF;

       -- if no assets are associated with the service line or none of the assets attached to the service line are quoted
       IF l_count = 0 OR l_prorate_ratio =  1 THEN
          l_prev_sty_id := -99;

          l_pymt_Count := 0;
          -- get the current payment lines for the service line and store them as proposed payments
          FOR l_currpymtlines_rec IN l_currpymtlines_csr(l_currpymtobjects_rec.id) LOOP

              l_pymt_Count := l_pymt_Count + 1;
              IF l_pymt_count = 1 THEN -- line level payments exist

                 l_cfo_id := NULL;

                 create_cash_flow_object(
                                  p_api_version    => p_api_version,
                                  x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data,
                                  p_obj_type_code  => G_SERVICE_LINE_OBJ_TYPE,
                                  p_src_table      => G_OBJECT_SRC_TABLE,
                                  p_src_id         =>  p_quote_id,
                                  p_base_src_id    =>  l_currpymtobjects_rec.base_source_id,
                                  p_sts_code       => G_PROPOSED_STATUS,
                                  x_cfo_id         =>  l_cfo_id,
                                  x_return_status  =>  l_return_status);

                IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'after call to create_cash_flow_object :'||l_return_status);
                 END IF;

                 IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;

                 lp_qcov_rec.qte_id := p_quote_id;
                 lp_qcov_rec.cfo_id := l_cfo_id;
                 lp_qcov_rec.BASE_SOURCE_ID := l_currpymtobjects_rec.base_source_id;
                 --Bug 4299668 PAGARG Instead of calling the procedure to insert
                 --quote cash flow object, store the record in the table
                 --**START**--
                 g_qcov_counter := g_qcov_counter + 1;
                 g_qcov_tbl_type(g_qcov_counter) := lp_qcov_rec;
                 --**END 4299668**--
             END IF;

             IF l_currpymtlines_rec.sty_id <> l_prev_sty_id THEN
                lx_new_cash_flow := 'N';
                l_prev_sty_id := l_currpymtlines_rec.sty_id;
             END IF;

             lp_cashflow_rec.p_cfo_id := l_cfo_id;
             lp_cashflow_rec.p_sts_code := G_PROPOSED_STATUS;
             lp_cashflow_rec.p_sty_id := l_currpymtlines_rec.sty_id;
             lp_cashflow_rec.p_due_arrears_yn := l_currpymtlines_rec.due_arrears_yn;
             lp_cashflow_rec.p_start_date := l_currpymtlines_rec.start_date;
             lp_cashflow_rec.p_advance_periods := l_currpymtlines_rec.number_of_advance_periods;
             lp_cashflow_rec.p_khr_id := p_khr_id;
             lp_cashflow_rec.p_quote_id := p_quote_id;
             lp_cashflow_rec.p_amount := l_currpymtlines_rec.amount;
             lp_cashflow_rec.p_period_in_months := l_currpymtlines_rec.number_of_periods;
             lp_cashflow_rec.p_frequency := l_currpymtlines_rec.fqy_code;
             lp_cashflow_rec.p_seq_num := l_currpymtlines_rec.level_sequence;
             lp_cashflow_rec.p_stub_days := l_currpymtlines_rec.stub_days;
             lp_cashflow_rec.p_stub_amount := l_currpymtlines_rec.stub_amount;

             create_cash_flows(   p_api_version           => p_api_version,
                            x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                            p_cashflow_rec          => lp_cashflow_rec,
                            px_new_cash_flow        => lx_new_cash_flow,
                            x_return_status         => l_return_status);

                IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'after call to create_cash_flows :'||l_return_status);
                 END IF;



             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

         END LOOP;
            ---

       END IF;
   END LOOP;

   -------------------------- Get the proposed fee line payments ------------------------
   -- Get the current fee lines for which the payment exists
   FOR l_currpymtobjects_rec IN l_currpymtobjects_csr(G_FEE_LINE_OBJ_TYPE, p_quote_id) LOOP
     --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
     -- Added the code to check for the associated assets and prorate the proposed fee line payments
     -- based on the Original Equipment Cost.
     l_count := 0;

     l_total_curr_cost := 0;
     l_total_new_cost := 0;
     -- Get all the booked assets associated with the fee line
     FOR l_feelineassets_rec IN l_lineassets_csr(l_currpymtobjects_rec.base_source_id,
                                                 G_LINKED_FEE_LINE_TYPE)
     LOOP
       l_count := l_count + 1 ;
       -- get the capitalize cost of the asset
       OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => p_api_version,
                                         p_init_msg_list => OKL_API.G_FALSE,
                                         x_return_status => l_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_formula_name  => 'LINE_CAP_AMNT',
                                         p_contract_id   => p_khr_id,
                                         p_line_id       => l_feelineassets_rec.object1_id1,
                                         x_value         => l_curr_cap_cost);



       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Check if asset belongs to the quote
       OPEN  l_assetinquote_csr(p_quote_id, l_feelineassets_rec.object1_id1);
       FETCH l_assetinquote_csr INTO l_quote_line_id, l_asset_quantity, l_quote_quantity;
         IF  l_assetinquote_csr%NOTFOUND THEN
           l_new_cap_cost := l_curr_cap_cost;
         ELSE
           IF l_asset_quantity = l_quote_quantity THEN
             l_new_cap_cost := 0;
           ELSE
             l_new_cap_cost := (l_curr_cap_cost / l_asset_quantity) * (l_asset_quantity - l_quote_quantity);
           END IF;
         END IF;
       CLOSE l_assetinquote_csr;
       l_total_curr_cost :=  l_total_curr_cost + l_curr_cap_cost ;
       l_total_new_cost := l_total_new_cost + l_new_cap_cost;
     END LOOP;

     IF l_count > 0 THEN -- assets associated with fee line
       l_prorate_ratio := l_total_new_cost / l_total_curr_cost;
       IF l_prorate_ratio >= 0 AND l_prorate_ratio < 1 THEN
         calc_prop_line_payments(
                         p_api_version           =>    p_api_version,
                         x_msg_count             =>    x_msg_count,
                         x_msg_data              =>    x_msg_data,
                         p_curr_cfo_id           =>    l_currpymtobjects_rec.id,
                         p_prop_obj_type_code    =>    G_FEE_LINE_OBJ_TYPE,
                         p_prop_base_source_id   =>    l_currpymtobjects_rec.base_source_id,
                         p_prorate_ratio         =>    l_prorate_ratio,
                         p_date_eff_from         =>    p_date_eff_from,
                         p_quote_id              =>    p_quote_id,
                         p_khr_id                =>    p_khr_id ,
                         x_return_status         =>    l_return_status);

                IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'after call to calc_prop_line_payments :'||l_return_status);
                 END IF;

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
     END IF;

     -- if no assets are associated with the rollover fee line or none of the assets attached to the rollover fee line are quoted or all the assets are quoted with full quantity.
     IF l_count = 0 OR l_prorate_ratio = 1 THEN
       l_prev_sty_id := -99;

     --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++
     -- Following is the existing code i.e. if there is no asset associated to fee line

       l_pymt_Count := 0;
       -- get the current payments for the fee line and store them as proposed payments
       FOR l_currpymtlines_rec IN l_currpymtlines_csr(l_currpymtobjects_rec.id) LOOP
           l_pymt_Count := l_pymt_Count + 1;
           IF l_pymt_count = 1 THEN -- line level payments exist

              l_cfo_id := NULL;

              create_cash_flow_object(
                                  p_api_version    => p_api_version,
                                  x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data,
                                  p_obj_type_code  => G_FEE_LINE_OBJ_TYPE,
                                  p_src_table      => G_OBJECT_SRC_TABLE,
                                  p_src_id         => p_quote_id,
                                  p_base_src_id    => l_currpymtobjects_rec.base_source_id,
                                  p_sts_code       => G_PROPOSED_STATUS,
                                  x_cfo_id         => l_cfo_id,
                                  x_return_status  => l_return_status);

                 IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'after call to create_cash_flow_object :'||l_return_status);
                 END IF;

               IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               lp_qcov_rec.qte_id := p_quote_id;
               lp_qcov_rec.cfo_id := l_cfo_id;
               lp_qcov_rec.BASE_SOURCE_ID := l_currpymtobjects_rec.base_source_id;
               --Bug 4299668 PAGARG Instead of calling the procedure to insert
               --quote cash flow object, store the record in the table
               --**START**--
               g_qcov_counter := g_qcov_counter + 1;
               g_qcov_tbl_type(g_qcov_counter) := lp_qcov_rec;
               --**END 4299668**--
           END IF;

           IF l_currpymtlines_rec.sty_id <> l_prev_sty_id THEN
              lx_new_cash_flow := 'N';
              l_prev_sty_id := l_currpymtlines_rec.sty_id;
           END IF;

           lp_cashflow_rec.p_cfo_id := l_cfo_id;
           lp_cashflow_rec.p_sts_code := G_PROPOSED_STATUS;
           lp_cashflow_rec.p_sty_id := l_currpymtlines_rec.sty_id;
           lp_cashflow_rec.p_due_arrears_yn := l_currpymtlines_rec.due_arrears_yn;
           lp_cashflow_rec.p_start_date := l_currpymtlines_rec.start_date;
           lp_cashflow_rec.p_advance_periods := l_currpymtlines_rec.number_of_advance_periods;
           lp_cashflow_rec.p_khr_id := p_khr_id;
           lp_cashflow_rec.p_quote_id := p_quote_id;
           lp_cashflow_rec.p_amount := l_currpymtlines_rec.amount;
           lp_cashflow_rec.p_period_in_months := l_currpymtlines_rec.number_of_periods;
           lp_cashflow_rec.p_frequency := l_currpymtlines_rec.fqy_code;
           lp_cashflow_rec.p_seq_num := l_currpymtlines_rec.level_sequence;
           lp_cashflow_rec.p_stub_days := l_currpymtlines_rec.stub_days;
           lp_cashflow_rec.p_stub_amount := l_currpymtlines_rec.stub_amount;

           create_cash_flows(   p_api_version           => p_api_version,
                            x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                            p_cashflow_rec          => lp_cashflow_rec,
                            px_new_cash_flow        => lx_new_cash_flow,
                            x_return_status         => l_return_status);

                IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'after call to create_cash_flows :'||l_return_status);
                 END IF;

           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

       END LOOP;
     END IF;
   END LOOP;
   -----------------------------  end proposed fee line payments ---------------------------------

   -------------------------- Get the proposed service asset line payments ------------------------
   -- get all the service asset lines for which current payment exists
   FOR l_currpymtobjects_rec IN l_currpymtobjects_csr(G_SERV_ASSET_OBJ_TYPE, p_quote_id) LOOP

       --Bug #3921591: pagarg +++ Rollover +++
       -- Modified the cursor call to pass line type also
       -- get the financial asset associated with the subline
       OPEN  l_finasset_csr(l_currpymtobjects_rec.base_source_id, G_LINKED_SERVICE_LINE_TYPE);
       FETCH l_finasset_csr INTO l_fin_asset_id;
       CLOSE l_finasset_csr;

       -- Check if asset belongs to the quote
       OPEN  l_assetinquote_csr(p_quote_id, l_fin_asset_id);
       FETCH l_assetinquote_csr INTO l_quote_line_id, l_asset_quantity, l_quote_quantity;
       IF  l_assetinquote_csr%FOUND THEN

           l_prorate_ratio := ( l_asset_quantity - l_quote_quantity ) / l_asset_quantity;

           IF l_prorate_ratio >= 0 AND l_prorate_ratio < 1 THEN

                calc_prop_line_payments( p_api_version           =>    p_api_version,
                               x_msg_count             =>    x_msg_count,
                                           x_msg_data              =>    x_msg_data,
                               p_curr_cfo_id           =>    l_currpymtobjects_rec.id,
                               p_prop_obj_type_code    =>    G_SERV_ASSET_OBJ_TYPE,
                               p_prop_base_source_id   =>   l_currpymtobjects_rec.base_source_id,
                               p_prorate_ratio         =>    l_prorate_ratio,
                               p_date_eff_from         =>    p_date_eff_from,
                               p_quote_id              =>    p_quote_id,
                               p_khr_id                =>    p_khr_id ,
                               x_return_status         =>    l_return_status);

                IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'after call to calc_prop_line_payments :'||l_return_status);
                 END IF;

                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

            END IF;

         ELSE

            l_prev_sty_id := -99;
            l_pymt_Count := 0;
            -- get the current payments for teh service line subline and store them as proposed payments
            FOR l_currpymtlines_rec IN l_currpymtlines_csr(l_currpymtobjects_rec.id) LOOP
                l_pymt_Count := l_pymt_Count + 1;
                IF l_pymt_count = 1 THEN -- line level payments exist

                    l_cfo_id := NULL;
                    create_cash_flow_object(
                                  p_api_version    => p_api_version,
                                  x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data,
                                  p_obj_type_code  => G_SERV_ASSET_OBJ_TYPE,
                                  p_src_table      => G_OBJECT_SRC_TABLE,
                                  p_src_id         => p_quote_id,
                                  p_base_src_id    => l_currpymtobjects_rec.base_source_id,
                                  p_sts_code       => G_PROPOSED_STATUS,
                                  x_cfo_id         => l_cfo_id,
                                  x_return_status  => l_return_status);

                    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    -- Store Objects in okl_quote_cf_objects
                    lp_qcov_rec.qte_id := p_quote_id;
                    lp_qcov_rec.cfo_id := l_cfo_id;
                    lp_qcov_rec.BASE_SOURCE_ID := l_currpymtobjects_rec.base_source_id;
                    --Bug 4299668 PAGARG Instead of calling the procedure to insert
                    --quote cash flow object, store the record in the table
                    --**START**--
                    g_qcov_counter := g_qcov_counter + 1;
                    g_qcov_tbl_type(g_qcov_counter) := lp_qcov_rec;
                    --**END 4299668**--
                END IF;

                IF l_currpymtlines_rec.sty_id <> l_prev_sty_id THEN
                    lx_new_cash_flow := 'N';
                    l_prev_sty_id := l_currpymtlines_rec.sty_id;
                END IF;

                lp_cashflow_rec.p_cfo_id := l_cfo_id;
                lp_cashflow_rec.p_sts_code := G_PROPOSED_STATUS;
                lp_cashflow_rec.p_sty_id := l_currpymtlines_rec.sty_id;
                lp_cashflow_rec.p_due_arrears_yn := l_currpymtlines_rec.due_arrears_yn;
                lp_cashflow_rec.p_start_date := l_currpymtlines_rec.start_date;
                lp_cashflow_rec.p_advance_periods := l_currpymtlines_rec.number_of_advance_periods;
                lp_cashflow_rec.p_khr_id := p_khr_id;
                lp_cashflow_rec.p_quote_id := p_quote_id;
                lp_cashflow_rec.p_amount := l_currpymtlines_rec.amount;
                lp_cashflow_rec.p_period_in_months := l_currpymtlines_rec.number_of_periods;
                lp_cashflow_rec.p_frequency := l_currpymtlines_rec.fqy_code;
                lp_cashflow_rec.p_seq_num := l_currpymtlines_rec.level_sequence;
                lp_cashflow_rec.p_stub_days := l_currpymtlines_rec.stub_days;
                lp_cashflow_rec.p_stub_amount := l_currpymtlines_rec.stub_amount;

                create_cash_flows(   p_api_version           => p_api_version,
                            x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                            p_cashflow_rec          => lp_cashflow_rec,
                            px_new_cash_flow        => lx_new_cash_flow,
                            x_return_status         => l_return_status);

                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

            END LOOP;
       ---------------
         END IF;
         CLOSE l_assetinquote_csr;
   END LOOP;

  --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
  ------------------ Get the proposed fee asset line payments ------------------
  -- get all the fee asset lines for which current payment exists

  FOR l_currpymtobjects_rec IN l_currpymtobjects_csr(G_FEE_ASSET_OBJ_TYPE, p_quote_id)
  LOOP
     -- get the financial asset associated with the subline
     OPEN  l_finasset_csr(l_currpymtobjects_rec.base_source_id, G_LINKED_FEE_LINE_TYPE);
     FETCH l_finasset_csr INTO l_fin_asset_id;
     CLOSE l_finasset_csr;
     -- Check if asset belongs to the quote
     OPEN  l_assetinquote_csr(p_quote_id, l_fin_asset_id);
     FETCH l_assetinquote_csr INTO l_quote_line_id, l_asset_quantity, l_quote_quantity;
       IF  l_assetinquote_csr%FOUND THEN
         l_prorate_ratio := ( l_asset_quantity - l_quote_quantity ) / l_asset_quantity;
         IF l_prorate_ratio >= 0 AND l_prorate_ratio < 1 THEN
           calc_prop_line_payments(
                        p_api_version           =>   p_api_version,
                        x_msg_count             =>   x_msg_count,
                        x_msg_data              =>   x_msg_data,
                        p_curr_cfo_id           =>   l_currpymtobjects_rec.id,
                        p_prop_obj_type_code    =>   G_FEE_ASSET_OBJ_TYPE,
                        p_prop_base_source_id   =>   l_currpymtobjects_rec.base_source_id,
                        p_prorate_ratio         =>   l_prorate_ratio,
                        p_date_eff_from         =>   p_date_eff_from,
                        p_quote_id              =>   p_quote_id,
                        p_khr_id                =>   p_khr_id ,
                        x_return_status         =>   l_return_status);
           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END IF;
      ELSE
        l_prev_sty_id := -99;
        l_pymt_Count := 0;
        -- get the current payments for the fee line subline and store them as
        -- proposed payments
        FOR l_currpymtlines_rec IN l_currpymtlines_csr(l_currpymtobjects_rec.id)
        LOOP
          l_pymt_Count := l_pymt_Count + 1;
          IF l_pymt_count = 1 THEN -- line level payments exist
            l_cfo_id := NULL;
            create_cash_flow_object(
                         p_api_version    => p_api_version,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_obj_type_code  => G_FEE_ASSET_OBJ_TYPE,
                         p_src_table      => G_OBJECT_SRC_TABLE,
                         p_src_id         => p_quote_id,
                         p_base_src_id    => l_currpymtobjects_rec.base_source_id,
                         p_sts_code       => G_PROPOSED_STATUS,
                         x_cfo_id         => l_cfo_id,
                         x_return_status  => l_return_status);
            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Store Objects in okl_quote_cf_objects
            lp_qcov_rec.qte_id := p_quote_id;
            lp_qcov_rec.cfo_id := l_cfo_id;
            lp_qcov_rec.BASE_SOURCE_ID := l_currpymtobjects_rec.base_source_id;
            --Bug 4299668 PAGARG Instead of calling the procedure to insert
            --quote cash flow object, store the record in the table
            --**START**--
            g_qcov_counter := g_qcov_counter + 1;
            g_qcov_tbl_type(g_qcov_counter) := lp_qcov_rec;
            --**END 4299668**--
          END IF;
          IF l_currpymtlines_rec.sty_id <> l_prev_sty_id THEN
            lx_new_cash_flow := 'N';
            l_prev_sty_id := l_currpymtlines_rec.sty_id;
          END IF;
          lp_cashflow_rec.p_cfo_id := l_cfo_id;
          lp_cashflow_rec.p_sts_code := G_PROPOSED_STATUS;
          lp_cashflow_rec.p_sty_id := l_currpymtlines_rec.sty_id;
          lp_cashflow_rec.p_due_arrears_yn := l_currpymtlines_rec.due_arrears_yn;
          lp_cashflow_rec.p_start_date := l_currpymtlines_rec.start_date;
          lp_cashflow_rec.p_advance_periods := l_currpymtlines_rec.number_of_advance_periods;
          lp_cashflow_rec.p_khr_id := p_khr_id;
          lp_cashflow_rec.p_quote_id := p_quote_id;
          lp_cashflow_rec.p_amount := l_currpymtlines_rec.amount;
          lp_cashflow_rec.p_period_in_months := l_currpymtlines_rec.number_of_periods;
          lp_cashflow_rec.p_frequency := l_currpymtlines_rec.fqy_code;
          lp_cashflow_rec.p_seq_num := l_currpymtlines_rec.level_sequence;
          lp_cashflow_rec.p_stub_days := l_currpymtlines_rec.stub_days;
          lp_cashflow_rec.p_stub_amount := l_currpymtlines_rec.stub_amount;
          create_cash_flows(
                     p_api_version           => p_api_version,
                     x_msg_count             => x_msg_count,
                     x_msg_data              => x_msg_data,
                     p_cashflow_rec          => lp_cashflow_rec,
                     px_new_cash_flow        => lx_new_cash_flow,
                     x_return_status         => l_return_status);
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END LOOP;
      END IF;
    CLOSE l_assetinquote_csr;
  END LOOP;

   --Bug 4299668 PAGARG All the four object table of records is populated for
   --current payment. Now call proceure for bulk insert.
   --**START**--
   okl_cfo_pvt.insert_row_bulk(p_api_version    => p_api_version,
                               p_init_msg_list  => OKL_API.G_FALSE,
                               x_return_status  => l_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_cfov_tbl       => g_cfov_tbl_type,
                               x_cfov_tbl       => gx_cfov_tbl_type);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OKL_QCO_PVT.insert_row_bulk(p_api_version    => p_api_version,
                               p_init_msg_list  => OKL_API.G_FALSE,
                               x_return_status  => l_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_qcov_tbl       => g_qcov_tbl_type,
                               x_qcov_tbl       => gx_qcov_tbl_type);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   okl_caf_pvt.insert_row_bulk(p_api_version       => p_api_version,
                               p_init_msg_list     => OKL_API.G_FALSE,
                               x_return_status     => l_return_status,
                               x_msg_count         => x_msg_count,
                               x_msg_data          => x_msg_data,
                               p_cafv_tbl          => g_cafv_tbl_type,
                               x_cafv_tbl          => gx_cafv_tbl_type);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OKL_CFL_PVT.insert_row_bulk(p_api_version     =>    p_api_version,
                               p_init_msg_list   =>    OKL_API.G_FALSE,
                               x_return_status   =>    l_return_status,
                               x_msg_count       =>    x_msg_count,
                               x_msg_data        =>    x_msg_data,
                               p_cflv_tbl        =>    g_cflv_tbl_type,
                               x_cflv_tbl        =>    gx_cflv_tbl_type);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   --**END 4299668**--

  -- set the return status and out variables
  x_return_status := l_return_status;
  --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++

  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
  END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
      END IF;

      IF l_currpymtlines_csr%ISOPEN THEN
         CLOSE l_currpymtlines_csr;
      END IF;

       --Bug #3921591: pagarg +++ Rollover +++
       -- Changed the cursor name as made it generalised
      IF l_lineassets_csr%ISOPEN THEN
         CLOSE l_lineassets_csr;
      END IF;
      IF l_assetinquote_csr%ISOPEN THEN
         CLOSE l_assetinquote_csr;
      END IF;
      IF l_finasset_csr%ISOPEN THEN
         CLOSE l_finasset_csr;
      END IF;
      IF l_currpymtobjects_csr%ISOPEN THEN
         CLOSE l_currpymtobjects_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      IF l_currpymtlines_csr%ISOPEN THEN
         CLOSE l_currpymtlines_csr;
      END IF;

       --Bug #3921591: pagarg +++ Rollover +++
       -- Changed the cursor name as made it generalised
      IF l_lineassets_csr%ISOPEN THEN
         CLOSE l_lineassets_csr;
      END IF;
      IF l_assetinquote_csr%ISOPEN THEN
         CLOSE l_assetinquote_csr;
      END IF;
      IF l_finasset_csr%ISOPEN THEN
         CLOSE l_finasset_csr;
      END IF;
      IF l_currpymtobjects_csr%ISOPEN THEN
         CLOSE l_currpymtobjects_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN

      IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||sqlerrm);
      END IF;

      IF l_currpymtlines_csr%ISOPEN THEN
         CLOSE l_currpymtlines_csr;
      END IF;

      --Bug #3921591: pagarg +++ Rollover +++
      -- Changed the cursor name as made it generalised
      IF l_lineassets_csr%ISOPEN THEN
         CLOSE l_lineassets_csr;
      END IF;
      IF l_assetinquote_csr%ISOPEN THEN
         CLOSE l_assetinquote_csr;
      END IF;
      IF l_finasset_csr%ISOPEN THEN
         CLOSE l_finasset_csr;
      END IF;
      IF l_currpymtobjects_csr%ISOPEN THEN
         CLOSE l_currpymtobjects_csr;
      END IF;
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- unexpected error
     OKL_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
  END calc_proposed_payments;


 /*========================================================================
 | PUBLIC PROCEDURE calc_quote_payments
 |
 | DESCRIPTION
 |    This is the public procedure caleld from the quote creation screen to calculate
 |    revised payments for a partial termination quote
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |     get_current_payments, calc_proposed_payments
 |
 | PARAMETERS
 |      p_quote_id                    IN        Quote ID
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 14-OCT-2003           SECHAWLA          Created
 |
 *=======================================================================*/
  PROCEDURE calc_quote_payments(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_quote_id          IN  NUMBER) IS


 /*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- Get the quote effective from date
    CURSOR l_quotehdr_csr(cp_id IN NUMBER) IS
    SELECT khr_id, trunc(date_effective_from)
    FROM   okl_trx_quotes_b
    WHERE  id = cp_id;

 /*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_version            CONSTANT NUMBER := 1;
    l_api_name               CONSTANT VARCHAR2(30) := 'calc_quote_payments';
    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_khr_id                 NUMBER;
    l_date_eff_from          DATE;
  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'calc_quote_payments';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
    END IF;


    --Print Input Variables
    IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_quote_id :'||p_quote_id);
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

    IF p_quote_id IS NULL OR p_quote_id = OKL_API.G_MISS_NUM THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       -- quote id is required
       OKC_API.set_message( p_app_name      => 'OKC',
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'QUOTE_ID');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    OPEN  l_quotehdr_csr(p_quote_id);
    FETCH l_quotehdr_csr INTO l_khr_id, l_date_eff_from;
    IF l_quotehdr_csr%NOTFOUND THEN
       -- quote ID is invalid
       x_return_status := OKL_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'QUOTE_ID');

       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE l_quotehdr_csr;

    --Bug 4299668 PAGARG Reset the global table of records for the four objects
    --and reset the Counter
    --**START**--
    g_cfov_tbl_type.delete;
    g_cafv_tbl_type.delete;
    g_cflv_tbl_type.delete;
    g_qcov_tbl_type.delete;
    g_cfov_counter := 0;
    g_cafv_counter := 0;
    g_cflv_counter := 0;
    g_qcov_counter := 0;
    --**END 4299668**--

    get_current_payments(
        p_api_version           =>   p_api_version,
        p_init_msg_list         =>   OKL_API.G_FALSE,
        x_return_status         =>   l_return_status,
        x_msg_count                     =>   x_msg_count,
        x_msg_data                      =>   x_msg_data,
        p_quote_id          =>   p_quote_id,
        p_khr_id            =>   l_khr_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug 4299668 PAGARG Reset the global table of records for the four objects
    --and reset the Counter
    --**START**--
    g_cfov_tbl_type.delete;
    g_cafv_tbl_type.delete;
    g_cflv_tbl_type.delete;
    g_qcov_tbl_type.delete;
    g_cfov_counter := 0;
    g_cafv_counter := 0;
    g_cflv_counter := 0;
    g_qcov_counter := 0;
    --**END 4299668**--

    calc_proposed_payments(
        p_api_version           =>   p_api_version,
        p_init_msg_list         =>   OKL_API.G_FALSE,
        x_return_status         =>   l_return_status,
        x_msg_count                     =>   x_msg_count,
        x_msg_data                      =>   x_msg_data,
        p_quote_id          =>   p_quote_id,
        p_khr_id            =>   l_khr_id,
        p_date_eff_from     =>   l_date_eff_from);

     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

   x_return_status := l_return_status;

   -- end the transaction
   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
  END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF (is_debug_exception_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
      END IF;

      IF l_quotehdr_csr%ISOPEN THEN
         CLOSE l_quotehdr_csr;
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
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      IF l_quotehdr_csr%ISOPEN THEN
         CLOSE l_quotehdr_csr;
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
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME,
                  'EXCEPTION :'||sqlerrm);
      END IF;

      IF l_quotehdr_csr%ISOPEN THEN
         CLOSE l_quotehdr_csr;
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

  END calc_quote_payments;

END OKL_AM_CALC_QUOTE_PYMNT_PVT;

/
