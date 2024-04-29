--------------------------------------------------------
--  DDL for Package Body OKL_AM_CONSOLIDATED_QTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CONSOLIDATED_QTE_PVT" AS
/* $Header: OKLRCNQB.pls 120.3 2007/12/14 13:57:33 nikshah ship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_STATEMENT            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_consolidated_qte_pvt.';

  -- Start of comments
  --
  -- Procedure Name	: get_set_database_values
  -- Description	  : Gets the values of the quote from DB and if not passed
  --                  assigns them to out parameter
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE get_and_set_database_values(
               p_qtev_tbl               IN   qtev_tbl_type,
               x_return_status          OUT  NOCOPY VARCHAR2,
               x_qtev_tbl               OUT  NOCOPY qtev_tbl_type)  IS

    -- Cursor to get the quote values from the database
    CURSOR get_quote_values_csr (p_qte_id IN NUMBER) IS
      SELECT id,
             qst_code,
             qtp_code,
             qrs_code,
             khr_id,
             accepted_yn,
             consolidated_yn,
             early_termination_yn,
             partial_yn,
             consolidated_qte_id,
             date_effective_from,
             date_effective_to,
             quote_number
      FROM   OKL_TRX_QUOTES_V
      WHERE  id = p_qte_id;

    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    get_quote_values_rec     get_quote_values_csr%ROWTYPE;
    i                        NUMBER;
    lp_qtev_tbl              qtev_tbl_type := p_qtev_tbl;
    lx_qtev_tbl              qtev_tbl_type := p_qtev_tbl;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_and_set_database_values';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      FOR i IN p_qtev_tbl.FIRST..p_qtev_tbl.LAST LOOP
        IF (p_qtev_tbl.exists(i)) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').id : ' || p_qtev_tbl(i).id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').qst_code : ' || p_qtev_tbl(i).qst_code);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').qtp_code : ' || p_qtev_tbl(i).qtp_code);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').qrs_code : ' || p_qtev_tbl(i).qrs_code);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').khr_id : ' || p_qtev_tbl(i).khr_id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').accepted_yn : ' || p_qtev_tbl(i).accepted_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').consolidated_yn : ' || p_qtev_tbl(i).consolidated_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').early_termination_yn : ' || p_qtev_tbl(i).early_termination_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').partial_yn : ' || p_qtev_tbl(i).partial_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').consolidated_qte_id : ' || p_qtev_tbl(i).consolidated_qte_id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').date_effective_from : ' || p_qtev_tbl(i).date_effective_from);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').date_effective_to : ' || p_qtev_tbl(i).date_effective_to);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').quote_number : ' || p_qtev_tbl(i).quote_number);
        END IF;
      END LOOP;
    END IF;

    i := lp_qtev_tbl.FIRST;

    LOOP

      OPEN  get_quote_values_csr (lp_qtev_tbl(i).id);
      FETCH get_quote_values_csr INTO get_quote_values_rec;
      IF get_quote_values_csr%NOTFOUND OR get_quote_values_rec.id IS NULL THEN
        -- Invalid value for id.
        OKL_API.SET_MESSAGE(p_app_name     => OKC_API.G_APP_NAME,
                       	    p_msg_name     => OKC_API.G_INVALID_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'id');
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      CLOSE get_quote_values_csr;


      IF lp_qtev_tbl(i).qst_code IS NULL
      OR lp_qtev_tbl(i).qst_code = OKL_API.G_MISS_CHAR THEN
        lx_qtev_tbl(i).qst_code := get_quote_values_rec.qst_code;
      END IF;

      IF lp_qtev_tbl(i).qtp_code IS NULL
      OR lp_qtev_tbl(i).qtp_code = OKL_API.G_MISS_CHAR THEN
        lx_qtev_tbl(i).qtp_code := get_quote_values_rec.qtp_code;
      END IF;

      IF lp_qtev_tbl(i).qrs_code IS NULL
      OR lp_qtev_tbl(i).qrs_code = OKL_API.G_MISS_CHAR THEN
        lx_qtev_tbl(i).qrs_code := get_quote_values_rec.qrs_code;
      END IF;

      IF lp_qtev_tbl(i).khr_id IS NULL
      OR lp_qtev_tbl(i).khr_id = OKL_API.G_MISS_NUM THEN
        lx_qtev_tbl(i).khr_id := get_quote_values_rec.khr_id;
      END IF;

      IF lp_qtev_tbl(i).accepted_yn IS NULL
      OR lp_qtev_tbl(i).accepted_yn = OKL_API.G_MISS_CHAR THEN
        lx_qtev_tbl(i).accepted_yn := get_quote_values_rec.accepted_yn;
      END IF;

      IF lp_qtev_tbl(i).consolidated_yn IS NULL
      OR lp_qtev_tbl(i).consolidated_yn = OKL_API.G_MISS_CHAR THEN
        lx_qtev_tbl(i).consolidated_yn := get_quote_values_rec.consolidated_yn;
      END IF;

      IF lp_qtev_tbl(i).early_termination_yn IS NULL
      OR lp_qtev_tbl(i).early_termination_yn = OKL_API.G_MISS_CHAR THEN
        lx_qtev_tbl(i).early_termination_yn := get_quote_values_rec.early_termination_yn;
      END IF;

      IF lp_qtev_tbl(i).partial_yn IS NULL
      OR lp_qtev_tbl(i).partial_yn = OKL_API.G_MISS_CHAR THEN
        lx_qtev_tbl(i).partial_yn := get_quote_values_rec.partial_yn;
      END IF;

      IF lp_qtev_tbl(i).consolidated_qte_id IS NULL
      OR lp_qtev_tbl(i).consolidated_qte_id = OKL_API.G_MISS_NUM THEN
        lx_qtev_tbl(i).consolidated_qte_id := get_quote_values_rec.consolidated_qte_id;
      END IF;

      IF lp_qtev_tbl(i).date_effective_from IS NULL
      OR lp_qtev_tbl(i).date_effective_from = OKL_API.G_MISS_DATE THEN
        lx_qtev_tbl(i).date_effective_from := get_quote_values_rec.date_effective_from;
      END IF;

      IF lp_qtev_tbl(i).date_effective_to IS NULL
      OR lp_qtev_tbl(i).date_effective_to = OKL_API.G_MISS_DATE THEN
        lx_qtev_tbl(i).date_effective_to := get_quote_values_rec.date_effective_to;
      END IF;

      IF lp_qtev_tbl(i).quote_number IS NULL
      OR lp_qtev_tbl(i).quote_number = OKL_API.G_MISS_NUM THEN
        lx_qtev_tbl(i).quote_number := get_quote_values_rec.quote_number;
      END IF;

      EXIT WHEN (i = lp_qtev_tbl.LAST);
      i := lp_qtev_tbl.NEXT(i);
    END LOOP;

    -- Set the return status
    x_return_status                :=   l_return_status;
    x_qtev_tbl                     :=   lx_qtev_tbl;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       IF (is_debug_exception_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_HALT_VALIDATION');
       END IF;

       IF get_quote_values_csr%ISOPEN THEN
         CLOSE get_quote_values_csr;
       END IF;

       x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
       IF (is_debug_exception_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
       END IF;

       IF get_quote_values_csr%ISOPEN THEN
         CLOSE get_quote_values_csr;
       END IF;

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END get_and_set_database_values;


  -- Start of comments
  --
  -- Procedure Name	: set_consolidated_quote_rec
  -- Description	  : Set the quote record for consolidated quote
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE set_consolidated_quote_rec(
               p_qtev_rec               IN   qtev_rec_type,
               x_return_status          OUT  NOCOPY VARCHAR2,
               x_qtev_rec               OUT  NOCOPY qtev_rec_type)  IS

    l_quote_status           VARCHAR2(200) := 'DRAFTED';
    l_quote_reason           VARCHAR2(200) := 'EOT';
    l_sys_date               DATE;
    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'set_consolidated_quote_rec';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.date_effective_from: ' || p_qtev_rec.date_effective_from);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.date_effective_to: ' || p_qtev_rec.date_effective_to);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.date_requested: ' || p_qtev_rec.date_requested);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.date_proposal: ' || p_qtev_rec.date_proposal);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.qtp_code: ' || p_qtev_rec.qtp_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.qst_code: ' || p_qtev_rec.qst_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.qrs_code: ' || p_qtev_rec.qrs_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.early_termination_yn: ' || p_qtev_rec.early_termination_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.partial_yn: ' || p_qtev_rec.partial_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.consolidated_yn: ' || p_qtev_rec.consolidated_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.accepted_yn: ' || p_qtev_rec.accepted_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.approved_yn: ' || p_qtev_rec.approved_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.preproceeds_yn: ' || p_qtev_rec.preproceeds_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.summary_format_yn: ' || p_qtev_rec.summary_format_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.payment_received_yn: ' || p_qtev_rec.payment_received_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.khr_id: ' || p_qtev_rec.khr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.currency_code: ' || p_qtev_rec.currency_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.currency_conversion_code: ' || p_qtev_rec.currency_conversion_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.currency_conversion_type: ' || p_qtev_rec.currency_conversion_type);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.currency_conversion_rate: ' || p_qtev_rec.currency_conversion_rate);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.currency_conversion_date: ' || p_qtev_rec.currency_conversion_date);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.id: ' || p_qtev_rec.id);
    END IF;
    -- Get the sysdate
    SELECT sysdate INTO l_sys_date FROM DUAL;

    -- Set the date_effective_from to date effective from of first quote
    x_qtev_rec.date_effective_from :=  p_qtev_rec.date_effective_from;

    -- Set the date_effective_to to date effective to of first quote
    x_qtev_rec.date_effective_to   :=  p_qtev_rec.date_effective_to;

    -- Set the date_requested to sysdate
    x_qtev_rec.date_requested      :=  l_sys_date;

    -- Set the date_proposal to sysdate
    x_qtev_rec.date_proposal       :=  l_sys_date;

    -- Set the qtp_code (quote type) to qtp of first quote
    x_qtev_rec.qtp_code            :=  p_qtev_rec.qtp_code;

    -- Set the qst_code (quote status) to qst of first quote
    x_qtev_rec.qst_code            :=  p_qtev_rec.qst_code;

    -- Set the qrs_code (quote reason) to qrs of first quote
    x_qtev_rec.qrs_code            :=  p_qtev_rec.qrs_code;

    x_qtev_rec.early_termination_yn :=  p_qtev_rec.early_termination_yn;

    x_qtev_rec.partial_yn           :=  p_qtev_rec.partial_yn;

    -- Set the requested_by to 1
    x_qtev_rec.requested_by        :=  1; --***OKL_QTE_PVT.Validate_Requested_By

    -- Set the consolidated_yn to YES
    x_qtev_rec.consolidated_yn     :=  G_YES;

    -- Always NO during consolidated quote creation
    x_qtev_rec.accepted_yn          :=  G_NO;
    x_qtev_rec.approved_yn          :=  G_NO;
    x_qtev_rec.preproceeds_yn       :=  G_NO;
    x_qtev_rec.summary_format_yn    :=  G_NO;
    x_qtev_rec.payment_received_yn  :=  G_NO;

    -- Set KHR_ID for now -- will remove later once OKL_AM_QUOTES_UV changes
    x_qtev_rec.khr_id               :=  p_qtev_rec.khr_id;

    -- Set the return status
    x_return_status                :=   l_return_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END set_consolidated_quote_rec;



  -- Start of comments
  --
  -- Procedure Name	: validate_quotes
  -- Description	  : Validates all the quotes passed
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  -- History        : RMUNJULU 23-DEC-02 2726739 Added code to check currency
  --                  codes match
  -- rmunjulu 3884338, initialize all date_eff_from and date_eff_to to NULL
  --
  -- End of comments
  PROCEDURE validate_quotes (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_control_flag                IN VARCHAR2,
           p_qtev_tbl                    IN  qtev_tbl_type,
           x_qtev_tbl                    OUT NOCOPY qtev_tbl_type) IS

    -- Cursor to get the product id of the contract for the quote
    CURSOR prod_id_csr (p_khr_id IN NUMBER) IS
     SELECT   K.pdt_id,
              K.contract_number
     FROM     OKL_K_HEADERS_FULL_V     K
     WHERE    K.id = p_khr_id;

    -- Cursor to get the recipient id of the quote
    CURSOR recpt_id_csr (p_qte_id IN NUMBER) IS
     SELECT   Q.recipient_id
     FROM     OKL_AM_QUOTES_UV     Q
     WHERE    Q.id = p_qte_id
     AND      Q.quote_party_role = 'RECIPIENT';

    l_return_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                      NUMBER;
    j                      NUMBER;
    lp_qtev_tbl            qtev_tbl_type := p_qtev_tbl;
    l_qtev_tbl             qtev_tbl_type := p_qtev_tbl;
    l_date_effective_from  DATE;
    l_date_effective_to    DATE;
    l_quote_type           VARCHAR2(200);
    l_quote_status         VARCHAR2(200);
    l_product_id           NUMBER;
    lp_product_id          NUMBER;
    l_recipient_id         NUMBER;
    lp_recipient_id        NUMBER;
    l_khr_id_first         NUMBER;
    l_contract_number      VARCHAR2(200);
    l_qte_number_first     NUMBER;

    TYPE khr_rec_type IS RECORD (
      khr_id              NUMBER,
      quote_number        NUMBER);

    TYPE khr_tbl_type IS TABLE OF khr_rec_type INDEX BY BINARY_INTEGER;

    l_khr_tbl              khr_tbl_type;


    -- RMUNJULU 23-DEC-02 2726739 Added variables
    l_chr_currency_code VARCHAR2(15);
    l_contract_currency_code VARCHAR2(15);
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'validate_quotes';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_control_flag: '||p_control_flag);
      FOR i IN p_qtev_tbl.FIRST..p_qtev_tbl.LAST LOOP
        IF (p_qtev_tbl.exists(i)) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').id : ' || p_qtev_tbl(i).id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').qst_code : ' || p_qtev_tbl(i).qst_code);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').qtp_code : ' || p_qtev_tbl(i).qtp_code);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').qrs_code : ' || p_qtev_tbl(i).qrs_code);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').khr_id : ' || p_qtev_tbl(i).khr_id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').accepted_yn : ' || p_qtev_tbl(i).accepted_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').consolidated_yn : ' || p_qtev_tbl(i).consolidated_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').early_termination_yn : ' || p_qtev_tbl(i).early_termination_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').partial_yn : ' || p_qtev_tbl(i).partial_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').consolidated_qte_id : ' || p_qtev_tbl(i).consolidated_qte_id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').date_effective_from : ' || p_qtev_tbl(i).date_effective_from);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').date_effective_to : ' || p_qtev_tbl(i).date_effective_to);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').quote_number : ' || p_qtev_tbl(i).quote_number);
        END IF;
      END LOOP;
    END IF;

    -- Check if min of 2 quotes selected
    -- The validation needs to go before the validation of quote id since screen
    -- can pass g_miss_num for 1st quote if no quotes selected.
    IF lp_qtev_tbl.COUNT < 2 THEN

      -- Message: A minimum of 2 quotes needs to be selected to create a consolidated quote.
      OKL_API.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_QTE_TWO_MIN_ERR');

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- rmunjulu 3755190, initialize all date_eff_from and date_eff_to to NULL,
    -- as the G_MISS_DATE they are being set to is incorrect.
    -- The proper date will then be fetched from the database in procedure
    -- get_and_set_database_values which is called below
    FOR k IN 1..lp_qtev_tbl.count LOOP

       lp_qtev_tbl(k).date_effective_from := NULL;
       lp_qtev_tbl(k).date_effective_to := NULL;

    END LOOP;

    -- Get and Set the qtev tbl
    get_and_set_database_values(
               p_qtev_tbl                => lp_qtev_tbl,
               x_return_status           => l_return_status,
               x_qtev_tbl                => l_qtev_tbl);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called get_and_set_database_values , return status: ' || l_return_status);
    END IF;

    -- Raise error if this fails
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- Check if first quote already accepted
    IF l_qtev_tbl(l_qtev_tbl.FIRST).accepted_yn = G_YES
    OR l_qtev_tbl(l_qtev_tbl.FIRST).qst_code = 'ACCEPTED' THEN

      -- Message: The selected quotes cannot be consolidated because one or
      -- more of them is already accepted.
      OKL_API.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_QTE_ALRDY_ACCEPTED');

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- Check if first quote already consolidated
    IF (l_qtev_tbl(l_qtev_tbl.FIRST).consolidated_yn = G_YES) THEN

      -- Message: The selected quotes cannot be consolidated because one or
      -- more of them are themselves consolidated.
      OKL_API.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_QTE_ALRDY_CONSOLDTD');

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- Check if first quote partial
    IF (l_qtev_tbl(l_qtev_tbl.FIRST).partial_yn = G_YES) THEN

      -- Message: The selected quotes cannot be consolidated because one or
      -- more of them are partial.
      OKL_API.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_QTE_ALRDY_PARTIAL');

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    --Only if create do this check
    -- ( since this wont happen from screen we do not need a user friendly message)
    IF p_control_flag = 'CREATE' THEN
      -- Check if first quote already part of another consolidated quote
      IF  (l_qtev_tbl(l_qtev_tbl.FIRST).consolidated_qte_id IS NOT NULL)
      AND (l_qtev_tbl(l_qtev_tbl.FIRST).consolidated_qte_id <> OKL_API.G_MISS_NUM) THEN
            -- Invalid value for consolidated_qte_id.
            OKL_API.SET_MESSAGE(p_app_name     => OKC_API.G_APP_NAME,
                          	    p_msg_name     => OKC_API.G_INVALID_VALUE,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'consolidated_qte_id');

        RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;
    END IF;

    -- Get the contract ids of all the full quotes passed and check if more than
    -- one full quote selected for the same contract
    IF (l_qtev_tbl.COUNT > 1) THEN

      i := l_qtev_tbl.FIRST;
      j := 1;
      LOOP

        -- Get the contract id and qte id values into table if full quote
        IF (l_qtev_tbl(i).partial_yn <> 'Y') THEN

          l_khr_tbl(j).khr_id := l_qtev_tbl(i).khr_id;
          l_khr_tbl(j).quote_number := l_qtev_tbl(i).quote_number;

        END IF;

        EXIT WHEN (i = l_qtev_tbl.LAST);
        i := l_qtev_tbl.NEXT(i);
        j := j+1;
      END LOOP;

      --Check if same khr_id exists more than once
      IF (l_khr_tbl.COUNT > 1) THEN

        i := l_khr_tbl.FIRST;
        LOOP

          l_khr_id_first := l_khr_tbl(i).khr_id;
          l_qte_number_first := l_khr_tbl(i).quote_number;
          j := i+1;
          LOOP

            -- If khr_id same for 2 quotes then get the qte numbers and set message and exit
            IF l_khr_id_first = l_khr_tbl(j).khr_id THEN

              -- Get the contract number for khr_id and set message and exit loops
              OPEN  prod_id_csr(l_khr_id_first);
              FETCH prod_id_csr INTO l_product_id, l_contract_number;
              CLOSE prod_id_csr;

              -- Cannot consolidate multiple full quotes (quote 1 = QTE_1 and quote 2 = QTE_2)
              -- for the same contract CONTRACT_NUMBER.
              OKL_API.SET_MESSAGE(p_app_name     => 'OKL',
                            	    p_msg_name     => 'OKL_AM_CONS_FULL_QTE_ERR',
                                  p_token1       => 'QTE_1',
                                  p_token1_value => l_qte_number_first,
                                  p_token2       => 'QTE_2',
                                  p_token2_value => l_khr_tbl(j).quote_number,
                                  p_token3       => 'CONTRACT_NUMBER',
                                  p_token3_value => l_contract_number);

              RAISE G_EXCEPTION_HALT_VALIDATION;

            END IF;

            EXIT WHEN (j = l_khr_tbl.LAST);
            j := l_khr_tbl.NEXT(j);
          END LOOP;

          EXIT WHEN (i = l_khr_tbl.COUNT - 1);
          i := l_khr_tbl.NEXT(i);
        END LOOP;

      END IF;

    END IF;

    -- if more than one quote passed
    IF (l_qtev_tbl.COUNT > 1) THEN

      -- Get the values of quote type, product, recipient, effective from,
      -- effective to, quote status of first quote and compare with the rest
      l_date_effective_from :=  TRUNC(l_qtev_tbl(l_qtev_tbl.FIRST).date_effective_from);
      l_date_effective_to   :=  TRUNC(l_qtev_tbl(l_qtev_tbl.FIRST).date_effective_to);
      l_quote_type          :=  l_qtev_tbl(l_qtev_tbl.FIRST).qtp_code;
      l_quote_status        :=  l_qtev_tbl(l_qtev_tbl.FIRST).qst_code;

      -- RMUNJULU 23-DEC-02 2726739 Added code to get chr_currency_code for the
      -- first quotes contract
      -- Get the contract currency from AM_Util
      l_contract_currency_code := OKL_AM_UTIL_PVT.get_chr_currency(l_qtev_tbl(l_qtev_tbl.FIRST).khr_id);

      -- Get the product id of first quote
      OPEN  prod_id_csr(l_qtev_tbl(l_qtev_tbl.FIRST).khr_id);
      FETCH prod_id_csr INTO l_product_id, l_contract_number;
      CLOSE prod_id_csr;

      -- Get the recipient id of first quote
      OPEN  recpt_id_csr(l_qtev_tbl(l_qtev_tbl.FIRST).id);
      FETCH recpt_id_csr INTO l_recipient_id;
      CLOSE recpt_id_csr;

      i := l_qtev_tbl.FIRST + 1 ; -- safe to do this since we already know more than one quote exist
      LOOP

        -- Check if already accepted
        IF l_qtev_tbl(i).accepted_yn = G_YES
        OR l_qtev_tbl(i).qst_code IN ('ACCEPTED') THEN
            -- Message: The selected quotes cannot be consolidated because one or
          -- more of them is already accepted.
          OKL_API.set_message(p_app_name     => 'OKL',
                              p_msg_name     => 'OKL_AM_QTE_ALRDY_ACCEPTED');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- Check if already consolidated
        IF (l_qtev_tbl(i).consolidated_yn = G_YES) THEN
          -- Message: The selected quotes cannot be consolidated because one or
          -- more of them are themselves consolidated.
          OKL_API.set_message(p_app_name     => 'OKL',
                              p_msg_name     => 'OKL_AM_QTE_ALRDY_CONSOLDTD');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- Check if quote partial
        IF (l_qtev_tbl(i).partial_yn = G_YES) THEN
          -- Message: The selected quotes cannot be consolidated because one or
          -- more of them are partial.
          OKL_API.set_message(p_app_name     => 'OKL',
                              p_msg_name     => 'OKL_AM_QTE_ALRDY_PARTIAL');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        --Only if create do this check
        -- ( since this wont happen from screen we do not need a user friendly message)
        IF p_control_flag = 'CREATE' THEN
          -- Check if quote already part of another consolidated quote
          IF  (l_qtev_tbl(i).consolidated_qte_id IS NOT NULL)
          AND (l_qtev_tbl(i).consolidated_qte_id <> OKL_API.G_MISS_NUM)THEN
            -- Invalid value for consolidated_qte_id.
            OKL_API.SET_MESSAGE(p_app_name     => OKC_API.G_APP_NAME,
                          	    p_msg_name     => OKC_API.G_INVALID_VALUE,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'consolidated_qte_id');
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
        END IF;

        -- Compare this quote with first quote for date effective from
        IF (TRUNC(l_qtev_tbl(i).date_effective_from) <> l_date_effective_from) THEN
          -- Message: The selected quotes cannot be consolidated because the date effective from
          -- is not the same for all of them.
          OKL_API.set_message(p_app_name     => 'OKL',
                              p_msg_name     => 'OKL_AM_QTE_DATE_EFF_FRM_MSG');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- Compare this quote with first quote for date effective to
        IF (TRUNC(l_qtev_tbl(i).date_effective_to) <> l_date_effective_to) THEN
          -- Message: The selected quotes cannot be consolidated because the date effective to
          -- is not the same for all of them.
          OKL_API.set_message(p_app_name     => 'OKL',
                              p_msg_name     => 'OKL_AM_QTE_DATE_EFF_TO_MSG');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- Compare this quote with first quote for quote type
        IF (l_qtev_tbl(i).qtp_code <> l_quote_type) THEN
          -- Message: The selected quotes cannot be consolidated because the quote type
          -- is not the same for all of them.
          OKL_API.set_message(p_app_name     => 'OKL',
                              p_msg_name     => 'OKL_AM_QTE_TYPE_MSG');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- Compare this quote with first quote for quote status
        IF (l_qtev_tbl(i).qst_code <> l_quote_status) THEN
          -- Message: The selected quotes cannot be consolidated because the quote status
          -- is not the same for all of them.
          OKL_API.set_message(p_app_name     => 'OKL',
                              p_msg_name     => 'OKL_AM_QTE_STATUS_MSG');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- Get the product id for this quote
        OPEN  prod_id_csr(l_qtev_tbl(i).khr_id);
        FETCH prod_id_csr INTO lp_product_id, l_contract_number;
        CLOSE prod_id_csr;

        -- Compare this quote with first quote for product
        IF (lp_product_id <> l_product_id) THEN
          -- Message: The selected quotes cannot be consolidated because the product type
          -- is not the same for all of them.
          OKL_API.set_message(p_app_name     => 'OKL',
                              p_msg_name     => 'OKL_AM_QTE_PDT_TYPE_MSG');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- Get the recipient id for this quote
        OPEN  recpt_id_csr(l_qtev_tbl(i).id);
        FETCH recpt_id_csr INTO lp_recipient_id;
        CLOSE recpt_id_csr;

        -- Compare this quote with first quote for recipient
        IF (lp_recipient_id <> l_recipient_id) THEN
          -- Message: The selected quotes cannot be consolidated because the quote recipient
          -- is not the same for all of them.
          OKL_API.set_message(p_app_name     => 'OKL',
                              p_msg_name     => 'OKL_AM_QTE_RECIPIENT_MSG');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- RMUNJULU 23-DEC-02 2726739 Added condition and new message
        -- Get the contract currency from AM_Util
        l_chr_currency_code := OKL_AM_UTIL_PVT.get_chr_currency(l_qtev_tbl(i).khr_id);

        -- If the contract currency of the first contract does not match
        -- contract currency of the current contract then error
        IF l_contract_currency_code <> l_chr_currency_code THEN

          -- The selected quotes cannot be consolidated because currency
          -- is not the same for all of them.
          OKL_API.set_message(p_app_name     => 'OKL',
                              p_msg_name     => 'OKL_AM_QTE_CURRENCY_MSG');

          RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

        EXIT WHEN (i = l_qtev_tbl.LAST);
        i := l_qtev_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status :=  l_return_status;
    x_qtev_tbl := l_qtev_tbl;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       IF (is_debug_exception_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_HALT_VALIDATION');
       END IF;

       IF prod_id_csr%ISOPEN THEN
         CLOSE prod_id_csr;
       END IF;

       IF recpt_id_csr%ISOPEN THEN
         CLOSE recpt_id_csr;
       END IF;

       x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
       IF (is_debug_exception_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
       END IF;

       IF prod_id_csr%ISOPEN THEN
         CLOSE prod_id_csr;
       END IF;

       IF recpt_id_csr%ISOPEN THEN
         CLOSE recpt_id_csr;
       END IF;

      OKL_API.set_message(p_app_name     => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_quotes;




  -- Start of comments
  --
  -- Function  Name  : set_currency_defaults
  -- Description     : This procedure Defaults the Multi-Currency Columns for
  --                   consolidated quote
  -- Business Rules  :
  -- Parameters      : Input parameters : p_first_qtev_rec, px_qtev_rec, p_sys_date
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  -- End of comments
  PROCEDURE set_currency_defaults(
            p_first_qtev_rec  IN qtev_rec_type,
            px_qtev_rec       IN OUT NOCOPY qtev_rec_type,
            p_sys_date        IN DATE,
            x_return_status   OUT NOCOPY VARCHAR2) IS

       l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
       l_functional_currency_code VARCHAR2(15);
       l_contract_currency_code VARCHAR2(15);

       -- Since we do not use the conversion columns for the consolidated quote
       -- set a hardcoded value for these columns
       l_currency_conversion_type VARCHAR2(30) := 'User';
       l_currency_conversion_rate NUMBER := 1;
       l_currency_conversion_date DATE := p_sys_date;
       l_module_name VARCHAR2(500) := G_MODULE_NAME || 'set_currency_defaults';
       is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
       is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
       is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_sys_date: '||p_sys_date);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_first_qtev_rec.khr_id: ' || p_first_qtev_rec.khr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_first_qtev_rec.currency_code: ' || p_first_qtev_rec.currency_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_first_qtev_rec.currency_conversion_code: ' || p_first_qtev_rec.currency_conversion_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_first_qtev_rec.currency_conversion_type: ' || p_first_qtev_rec.currency_conversion_type);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_first_qtev_rec.currency_conversion_rate: ' || p_first_qtev_rec.currency_conversion_rate);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_first_qtev_rec.currency_conversion_date: ' || p_first_qtev_rec.currency_conversion_date);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_first_qtev_rec.id: ' || p_first_qtev_rec.id);
    END IF;

     -- Get the functional currency from AM_Util
     l_functional_currency_code := OKL_AM_UTIL_PVT.get_functional_currency();

     -- Get the contract currency from AM_Util
     l_contract_currency_code := OKL_AM_UTIL_PVT.get_chr_currency(p_first_qtev_rec.khr_id);

     px_qtev_rec.currency_code := l_contract_currency_code;
     px_qtev_rec.currency_conversion_code := l_functional_currency_code;

     -- If the functional currency is different from contract currency then set
     -- currency conversion columns
     IF l_functional_currency_code <> l_contract_currency_code THEN

        -- Set the currency conversion columns
        px_qtev_rec.currency_conversion_type := l_currency_conversion_type;
        px_qtev_rec.currency_conversion_rate := l_currency_conversion_rate;
        px_qtev_rec.currency_conversion_date := l_currency_conversion_date;

     END IF;

     -- Set the return status
     x_return_status := l_return_status;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION


     WHEN OTHERS THEN
         IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
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

  END set_currency_defaults;




  -- Start of comments
  --
  -- Procedure Name	: create_consolidate_quote
  -- Description	  : Procedure to create a consolidated quote for the quotes
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  -- History        : RMUNJULU 23-DEC-02 2726739 Added call to set_currency_defaults
  --
  -- End of comments
  PROCEDURE create_consolidate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_qtev_tbl                    IN  qtev_tbl_type,
           x_cons_rec                    OUT NOCOPY qtev_rec_type) IS

    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30):= 'create_consolidate_quote';
    l_api_version            CONSTANT NUMBER      := 1;
    l_overall_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                        NUMBER;
    lp_consolidate_quote_rec qtev_rec_type;
    lx_consolidate_quote_rec qtev_rec_type;
    lp_qtev_tbl              qtev_tbl_type := p_qtev_tbl;
    lx_qtev_tbl              qtev_tbl_type;

    lp_quot_tbl              qtev_tbl_type;
    lx_quot_tbl              qtev_tbl_type;

    -- RMUNJULU 23-DEC-02 2726739 Added variable
    l_sys_date DATE;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_consolidate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      FOR i IN p_qtev_tbl.FIRST..p_qtev_tbl.LAST LOOP
        IF (p_qtev_tbl.exists(i)) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').id : ' || p_qtev_tbl(i).id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').qst_code : ' || p_qtev_tbl(i).qst_code);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').qtp_code : ' || p_qtev_tbl(i).qtp_code);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').qrs_code : ' || p_qtev_tbl(i).qrs_code);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').khr_id : ' || p_qtev_tbl(i).khr_id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').accepted_yn : ' || p_qtev_tbl(i).accepted_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').consolidated_yn : ' || p_qtev_tbl(i).consolidated_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').early_termination_yn : ' || p_qtev_tbl(i).early_termination_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').partial_yn : ' || p_qtev_tbl(i).partial_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').consolidated_qte_id : ' || p_qtev_tbl(i).consolidated_qte_id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').date_effective_from : ' || p_qtev_tbl(i).date_effective_from);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').date_effective_to : ' || p_qtev_tbl(i).date_effective_to);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_tbl(' || i || ').quote_number : ' || p_qtev_tbl(i).quote_number);
        END IF;
      END LOOP;
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

    -- If quotes passed
    IF (p_qtev_tbl.COUNT > 0) THEN

      -- RMUNJULU 23-DEC-02 2726739 Added select to get sysdate
      SELECT SYSDATE INTO l_sys_date FROM DUAL;


      -- Validate the quotes that are passed
      validate_quotes (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_control_flag                 => 'CREATE',
          p_qtev_tbl                     => lp_qtev_tbl,
          x_qtev_tbl                     => lx_qtev_tbl);
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called validate_quotes , return status: ' || l_return_status);
       END IF;

      -- Throw exception if validation of one or more of selected quotes fails
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Set the rec type for consolidated quote
      set_consolidated_quote_rec(
               p_qtev_rec                => lx_qtev_tbl(p_qtev_tbl.FIRST),
               x_return_status           => l_return_status,
               x_qtev_rec                => lp_consolidate_quote_rec);
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called set_consolidated_quote_rec , return status: ' || l_return_status);
       END IF;

      -- Throw exception if setting the consolidated quote record fails
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;


      -- RMUNJULU 23-DEC-02 2726739 Added call to set_currency_defaults
      -- Set the currency columns for the consolidated quote
      set_currency_defaults(
               p_first_qtev_rec  => lx_qtev_tbl(p_qtev_tbl.FIRST),
               px_qtev_rec       => lp_consolidate_quote_rec,
               p_sys_date        => l_sys_date,
               x_return_status   => l_return_status);
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called set_currency_defaults , return status: ' || l_return_status);
       END IF;


      -- Throw exception if setting the consolidated quote record fails
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;


      -- Call the insert_row of tapi to insert the consolidated quote
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TRX_QUOTES_PUB.insert_trx_quotes');
      END IF;
      OKL_TRX_QUOTES_PUB.insert_trx_quotes (
         p_api_version                   =>   p_api_version,
         p_init_msg_list                 =>   OKL_API.G_FALSE,
         x_msg_count                     =>   x_msg_count,
         x_msg_data                      =>   x_msg_data,
         x_return_status                 =>   l_return_status,
         p_qtev_rec                      =>   lp_consolidate_quote_rec,
         x_qtev_rec                      =>   lx_consolidate_quote_rec);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_TRX_QUOTES_PUB.insert_trx_quotes , return status: ' || l_return_status);
      END IF;

      -- Throw exception if inserting the consolidated quote record fails
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Update all the quotes passed to have a FKey link to this consolidate
      -- quote which was created
      i := lx_qtev_tbl.FIRST;
      LOOP
        -- Set the quote tbl
        lp_quot_tbl(i).id                  := lx_qtev_tbl(i).id;
        lp_quot_tbl(i).consolidated_qte_id := lx_consolidate_quote_rec.id;

        EXIT WHEN (i = lx_qtev_tbl.LAST);
        i := lx_qtev_tbl.NEXT(i);
      END LOOP;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TRX_QUOTES_PUB.update_trx_quotes');
      END IF;
      -- For all quotes passed call update_row of tapi
      OKL_TRX_QUOTES_PUB.update_trx_quotes (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qtev_tbl                     => lp_quot_tbl,
          x_qtev_tbl                     => lx_quot_tbl);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_TRX_QUOTES_PUB.update_trx_quotes , return status: ' || l_return_status);
      END IF;

      -- Throw exception if updating the selected quotes to set the consolidated
      -- quote for anyone of them fails
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    -- Set the return status and out param
    x_return_status :=  l_return_status;
    x_cons_rec      :=  lx_consolidate_quote_rec;

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
  END create_consolidate_quote;

  -- Start of comments
  --
  -- Procedure Name	: validate_consolidated_quote
  -- Description	  : Validates consolidated quote
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE validate_consolidated_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_cons_rec                    IN  qtev_rec_type) IS

    -- Cursor to get consolidated quote DB values
    CURSOR get_cons_db_vals_csr (p_qte_id IN NUMBER) IS
     SELECT   accepted_yn,
              date_effective_from
     FROM     OKL_TRX_QUOTES_V
     WHERE    id = p_qte_id;


    l_return_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_cons_rec            qtev_rec_type := p_cons_rec;
    get_cons_db_vals_rec   get_cons_db_vals_csr%ROWTYPE;
    l_date_eff_from        DATE;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'validate_consolidated_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.id: ' || p_cons_rec.id);
    END IF;

    OPEN  get_cons_db_vals_csr(lp_cons_rec.id);
    FETCH get_cons_db_vals_csr INTO get_cons_db_vals_rec;
    CLOSE get_cons_db_vals_csr;

    -- Check if date_effective_to is NULL
    IF p_cons_rec.date_effective_to IS NULL
    OR p_cons_rec.date_effective_to = OKL_API.G_MISS_DATE THEN

      -- You must enter a value for PROMPT
      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_EFFECTIVE_TO'));
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- Get the date_eff_from from database if not passed
    IF  (p_cons_rec.date_effective_from IS NOT NULL)
    AND (p_cons_rec.date_effective_from <> OKL_API.G_MISS_DATE) THEN
      l_date_eff_from := p_cons_rec.date_effective_from;
    ELSE
      l_date_eff_from := get_cons_db_vals_rec.date_effective_from;
    END IF;

    -- Check date_eff_to > date_eff_from
    IF  (l_date_eff_from IS NOT NULL)
    AND (l_date_eff_from <> OKL_API.G_MISS_DATE)
    AND (p_cons_rec.date_effective_to IS NOT NULL)
    AND (p_cons_rec.date_effective_to <> OKL_API.G_MISS_DATE) THEN

       IF (TRUNC(p_cons_rec.date_effective_to) <= TRUNC(l_date_eff_from)) THEN

         -- Message : Date Effective To DATE_EFFECTIVE_TO cannot be before
         -- Date Effective From DATE_EFFECTIVE_FROM.
         OKL_API.SET_MESSAGE(p_app_name    	 => 'OKL',
      			                 p_msg_name		   => 'OKL_AM_DATE_EFF_FROM_LESS_TO',
      			                 p_token1		     => 'DATE_EFFECTIVE_TO',
    		  	                 p_token1_value	 => p_cons_rec.date_effective_to,
    			                   p_token2		     => 'DATE_EFFECTIVE_FROM',
    			                   p_token2_value	 => l_date_eff_from);

         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;

    -- Check if trying to change an already accepted consolidated quote
    IF  get_cons_db_vals_rec.accepted_yn = G_YES
    AND lp_cons_rec.accepted_yn = G_NO THEN
       -- Quote QUOTE_NUMBER is already accepted.
       OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_QUOTE_ALREADY_ACCP',
                            p_token1        => 'QUOTE_NUMBER',
                            p_token1_value  => lp_cons_rec.quote_number);
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status :=  l_return_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       IF (is_debug_exception_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_HALT_VALIDATION');
       END IF;

       IF get_cons_db_vals_csr%ISOPEN THEN
         CLOSE get_cons_db_vals_csr;
       END IF;

       x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

       IF get_cons_db_vals_csr%ISOPEN THEN
         CLOSE get_cons_db_vals_csr;
       END IF;

      OKL_API.set_message(p_app_name     => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_consolidated_quote;


  -- Start of comments
  --
  -- Procedure Name	: get_quotes_of_consolidated_qte
  -- Description	  : get_quotes_of_consolidated_qte
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  FUNCTION get_quotes_of_consolidated_qte (
           p_cons_rec    IN  qtev_rec_type) RETURN qtev_tbl_type IS

    -- Cursor to get quote details of quotes forming part of consolidated quote
    CURSOR get_qtes_of_cons_qte_csr (p_qte_id IN NUMBER) IS
     SELECT   id
     FROM     OKL_TRX_QUOTES_V
     WHERE    consolidated_qte_id = p_qte_id;

    lp_qtev_tbl            qtev_tbl_type;
    i                      NUMBER;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_quotes_of_consolidated_qte';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.id: ' || p_cons_rec.id);
    END IF;

    i := 1;
    FOR get_qtes_of_cons_qte_rec IN get_qtes_of_cons_qte_csr(p_cons_rec.id) LOOP

      lp_qtev_tbl(i).id := get_qtes_of_cons_qte_rec.id;
      i := i + 1;

    END LOOP;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

    RETURN lp_qtev_tbl;

  EXCEPTION
    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      OKL_API.set_message(p_app_name     => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END get_quotes_of_consolidated_qte;


  -- Start of comments
  --
  -- Procedure Name	: get_quotes_lines
  -- Description	  : get_quotes_lines
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  FUNCTION get_quotes_lines (
           p_qtev_rec    IN  qtev_rec_type) RETURN OKL_AM_REPURCHASE_ASSET_PUB.tqlv_tbl_type IS

    -- Cursor to get quote details of quotes forming part of consolidated quote
    CURSOR get_qtes_lines_of_qte_csr (p_qte_id IN NUMBER) IS
     SELECT   id
     FROM     OKL_TXL_QUOTE_LINES_V
     WHERE    qte_id = p_qte_id;

    lp_tqlv_tbl            OKL_AM_REPURCHASE_ASSET_PUB.tqlv_tbl_type;
    i                      NUMBER;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_quotes_lines';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qtev_rec.id: ' || p_qtev_rec.id);
    END IF;

    i := 1;
    FOR get_qtes_lines_of_qte_rec IN get_qtes_lines_of_qte_csr(p_qtev_rec.id) LOOP

      lp_tqlv_tbl(i).id := get_qtes_lines_of_qte_rec.id;
      i := i + 1;

    END LOOP;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

    RETURN lp_tqlv_tbl;

  EXCEPTION
    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      OKL_API.set_message(p_app_name     => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END get_quotes_lines;

  -- Start of comments
  --
  -- Procedure Name	: update_consolidate_quote
  -- Description	  : Gets the values of the quote from DB and if not passed
  --                  assigns them to out parameter
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  -- History        : RMUNJULU 04-FEB-03 2783130 Added code to get proper qtp_code
  --
  -- End of comments
  PROCEDURE update_consolidate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_cons_rec                    IN  qtev_rec_type,
           x_cons_rec                    OUT NOCOPY qtev_rec_type,
           x_qtev_tbl                    OUT NOCOPY qtev_tbl_type) IS

           -- RMUNJULU 04-FEB-03 2783130 Added cursor to get proper qtp_code
           -- get the consolidated quote details
           CURSOR get_qte_details_csr ( p_qte_id IN NUMBER) IS
                SELECT qte.qtp_code
                FROM  OKL_TRX_QUOTES_V qte
                WHERE qte.id = p_qte_id;

    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30):= 'update_consolidate_quote';
    l_api_version            CONSTANT NUMBER      := 1;
    l_overall_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_err_msg                VARCHAR2(200);
    i                        NUMBER;
    l_sys_date               DATE;

    lp_qtev_tbl              qtev_tbl_type;
    li_qtev_tbl              qtev_tbl_type;
    lx_qtev_tbl              qtev_tbl_type;

    lp_cons_rec              qtev_rec_type := p_cons_rec;
    lx_cons_rec              qtev_rec_type;

    lp_tqlv_tbl              OKL_AM_REPURCHASE_ASSET_PUB.tqlv_tbl_type;
    lx_tqlv_tbl              OKL_AM_REPURCHASE_ASSET_PUB.tqlv_tbl_type;

    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'update_consolidate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.date_effective_from: ' || p_cons_rec.date_effective_from);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.date_effective_to: ' || p_cons_rec.date_effective_to);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.date_requested: ' || p_cons_rec.date_requested);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.date_proposal: ' || p_cons_rec.date_proposal);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.qtp_code: ' || p_cons_rec.qtp_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.qst_code: ' || p_cons_rec.qst_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.qrs_code: ' || p_cons_rec.qrs_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.early_termination_yn: ' || p_cons_rec.early_termination_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.partial_yn: ' || p_cons_rec.partial_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.consolidated_yn: ' || p_cons_rec.consolidated_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.accepted_yn: ' || p_cons_rec.accepted_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.approved_yn: ' || p_cons_rec.approved_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.preproceeds_yn: ' || p_cons_rec.preproceeds_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.summary_format_yn: ' || p_cons_rec.summary_format_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.payment_received_yn: ' || p_cons_rec.payment_received_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.khr_id: ' || p_cons_rec.khr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.currency_code: ' || p_cons_rec.currency_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.currency_conversion_code: ' || p_cons_rec.currency_conversion_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.currency_conversion_type: ' || p_cons_rec.currency_conversion_type);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.currency_conversion_rate: ' || p_cons_rec.currency_conversion_rate);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.currency_conversion_date: ' || p_cons_rec.currency_conversion_date);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cons_rec.id: ' || p_cons_rec.id);
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

    -- validate consolidated quote ( if already accepted) dont accept
    -- Validate the consolidated quote
    validate_consolidated_quote (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cons_rec                     => lp_cons_rec);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called validate_consolidated_quote , return status: ' || l_return_status);
      END IF;

    -- Throw exception if validation of consolidated quote fails
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Get the quotes which are part of consolidated quote
    lp_qtev_tbl := get_quotes_of_consolidated_qte(lp_cons_rec);

    -- Validate the quotes that are part of consolidated quote
    validate_quotes (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_control_flag                 => 'UPDATE',
          p_qtev_tbl                     => lp_qtev_tbl,
          x_qtev_tbl                     => li_qtev_tbl);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called validate_quotes , return status: ' || l_return_status);
      END IF;

    -- Throw exception if validation of one or more of selected quotes fails
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF li_qtev_tbl.COUNT > 0 THEN

      i := li_qtev_tbl.FIRST;
      LOOP
        -- Set the rec type of each quote
        li_qtev_tbl(i).accepted_yn        := lp_cons_rec.accepted_yn;
        li_qtev_tbl(i).date_effective_to  := lp_cons_rec.date_effective_to;
        li_qtev_tbl(i).comments           := lp_cons_rec.comments;

        -- RMUNJULU 04-FEB-03 2783130 Added code to get proper qtp_code
        -- if value for qtp_code passed use it or else get from DB
        IF lp_cons_rec.qtp_code IS NOT NULL
        AND lp_cons_rec.qtp_code <> OKL_API.G_MISS_CHAR THEN

          li_qtev_tbl(i).qtp_code := lp_cons_rec.qtp_code;

        ELSE

          -- get the qtp code from database
          FOR get_qte_details_rec IN get_qte_details_csr(li_qtev_tbl(i).id) LOOP

             li_qtev_tbl(i).qtp_code := get_qte_details_rec.qtp_code;

          END LOOP;


        END IF;


        IF li_qtev_tbl(i).qtp_code LIKE 'TER%' THEN

          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_TERMNT_QUOTE_PUB.terminate_quote');
          END IF;
          -- Call terminate quote update api
          OKL_AM_TERMNT_QUOTE_PUB.terminate_quote(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_term_rec                     => li_qtev_tbl(i),
            x_term_rec                     => lx_qtev_tbl(i),
            x_err_msg                      => l_err_msg);
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_TERMNT_QUOTE_PUB.terminate_quote , return status: ' || l_return_status);
          END IF;

          -- Throw exception if terminate quote update failed
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        ELSIF li_qtev_tbl(i).qtp_code LIKE 'REP%' THEN

          -- get the quote lines
          lp_tqlv_tbl := get_quotes_lines (
                              p_qtev_rec   => li_qtev_tbl(i));

          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_REPURCHASE_ASSET_PUB.update_repurchase_quote');
          END IF;
          -- Call terminate quote update api
          OKL_AM_REPURCHASE_ASSET_PUB.update_repurchase_quote(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_qtev_rec                     => li_qtev_tbl(i),
            p_tqlv_tbl                     => lp_tqlv_tbl,
            x_qtev_rec                     => lx_qtev_tbl(i),
            x_tqlv_tbl                     => lx_tqlv_tbl);
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_REPURCHASE_ASSET_PUB.update_repurchase_quote , return status: ' || l_return_status);
          END IF;

          -- Throw exception if repurchase quote update failed
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;


        ELSIF li_qtev_tbl(i).qtp_code LIKE 'RES%' THEN

          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_RESTRUCTURE_QUOTE_PUB.update_restructure_quote');
          END IF;
          -- Call terminate quote update api
          OKL_AM_RESTRUCTURE_QUOTE_PUB.update_restructure_quote(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_quot_rec                     => li_qtev_tbl(i),
            x_quot_rec                     => lx_qtev_tbl(i));
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_RESTRUCTURE_QUOTE_PUB.update_restructure_quote , return status: ' || l_return_status);
          END IF;

          -- Throw exception if restructure quote update failed
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;

        EXIT WHEN (i = li_qtev_tbl.LAST);
        i := li_qtev_tbl.NEXT(i);

      END LOOP;

    END IF;

    SELECT SYSDATE INTO l_sys_date FROM DUAL;

    -- Set the consolidated quote before updating
    -- Set the qst_code to ACCEPTED and date_accepted, if the quote is accepted
    IF (lp_cons_rec.accepted_yn = G_YES) THEN
      lp_cons_rec.qst_code := 'ACCEPTED';
      lp_cons_rec.date_accepted := l_sys_date;
    END IF;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TRX_QUOTES_PUB.update_trx_quotes');
    END IF;
    -- update consolidate quote
    OKL_TRX_QUOTES_PUB.update_trx_quotes (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qtev_rec                     => lp_cons_rec,
          x_qtev_rec                     => lx_cons_rec);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_TRX_QUOTES_PUB.update_trx_quotes , return status: ' || l_return_status);
    END IF;

    -- Throw exception if updating the consolidated quote fails
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Set the return status and out param
    x_return_status :=  l_return_status;
    x_cons_rec      :=  lx_cons_rec;
    x_qtev_tbl      :=  lx_qtev_tbl;

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
  END update_consolidate_quote;

END OKL_AM_CONSOLIDATED_QTE_PVT;

/
