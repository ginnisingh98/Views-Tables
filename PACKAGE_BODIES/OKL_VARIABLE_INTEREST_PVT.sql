--------------------------------------------------------
--  DDL for Package Body OKL_VARIABLE_INTEREST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VARIABLE_INTEREST_PVT" AS
/* $Header: OKLRVARB.pls 120.79.12010000.12 2009/08/05 12:58:58 rpillay ship $ */

    G_DEBUG           CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_INIT_NUMBER     CONSTANT  NUMBER := -9999;
    G_API_TYPE        CONSTANT  VARCHAR2(4) := '_PVT';
    G_REQUIRED_VALUE  CONSTANT  VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
    G_COL_NAME_TOKEN  CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
	G_FIN_LINE_LTY_ID CONSTANT  NUMBER := 33;
    rule_failed       EXCEPTION;


    SUBTYPE vir_tbl_type IS OKL_VIR_PVT.vir_tbl_type;

    TYPE vrc_rec_type IS RECORD (
       CONTRACT_NUMBER                  OKL_K_HEADERS_FULL_V.CONTRACT_NUMBER%TYPE
      ,CONTRACT_ID                      OKL_K_HEADERS_FULL_V.ID%TYPE
      ,START_DATE                       OKL_K_HEADERS_FULL_V.START_DATE%TYPE
      ,END_DATE                         OKL_K_HEADERS_FULL_V.END_DATE%TYPE
      ,INTEREST_CALCULATION_BASIS       OKL_PRODUCT_PARAMETERS_V.INTEREST_CALCULATION_BASIS%TYPE
	  ,DAYS_IN_A_MONTH_CODE             OKL_K_RATE_PARAMS.DAYS_IN_A_MONTH_CODE%TYPE
	  ,DAYS_IN_A_YEAR_CODE              OKL_K_RATE_PARAMS.DAYS_IN_A_YEAR_CODE%TYPE
	  ,RATE_CHANGE_VALUE                OKL_K_RATE_PARAMS.RATE_CHANGE_VALUE%TYPE
	  ,PROCESS_STATUS                   VARCHAR2(1));

    TYPE vrc_tbl_type IS TABLE OF vrc_rec_type INDEX BY BINARY_INTEGER;

    g_vir_tbl                     vir_tbl_type;
    g_vir_tbl_counter             NUMBER;
    g_vpb_tbl                     vpb_tbl_type;
    g_vpb_tbl_counter             NUMBER := 0;
    g_to_date                     DATE;
    g_no_of_contracts_processed   NUMBER;
    g_no_of_rejected_contracts    NUMBER;
    g_no_of_successful_contracts  NUMBER;
    -- varangan - Billing-Inline changes - Bug#5898792 - New constant added -Begin
    -- sosharma changed the the value from STREAMS to VARIABLE_RATE
    G_SOURCE_BILLING_TRX    CONSTANT VARCHAR2(200) :='VARIABLE_RATE';
    -- varangan - Billing-Inline changes - Bug#5898792 - New constant added -End

--Bug# 7277007
TYPE rpt_summary_rec_type IS RECORD (
  total_contract_num_success   NUMBER
 ,total_contract_num_error     NUMBER);

TYPE rpt_summary_tbl_type IS TABLE OF rpt_summary_rec_type INDEX BY VARCHAR2(30);
g_rpt_summary_tbl         rpt_summary_tbl_type;

TYPE error_msg_tbl_type is TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

TYPE rpt_error_rec_type IS RECORD (
  contract_number             okc_k_headers_b.contract_number%TYPE
 ,product_name                okl_products.name%TYPE
 ,interest_calc_basis         fnd_lookup_values.lookup_code%TYPE
 ,last_int_calc_date          DATE
 ,error_msg_tbl               error_msg_tbl_type);

TYPE rpt_error_tbl_type IS TABLE OF rpt_error_rec_type INDEX BY BINARY_INTEGER;
g_rpt_error_tbl         rpt_error_tbl_type;
g_rpt_error_tbl_counter BINARY_INTEGER := 0;

TYPE rpt_success_rec_type IS RECORD (
   contract_id                okc_k_headers_b.id%TYPE
  ,contract_number            okc_k_headers_b.contract_number%TYPE
  ,days_in_a_month_code       okl_k_rate_params.days_in_a_month_code%TYPE
  ,days_in_a_year_code        okl_k_rate_params.days_in_a_year_code%TYPE);

TYPE rpt_success_tbl_type IS TABLE OF rpt_success_rec_type INDEX BY BINARY_INTEGER;

TYPE rpt_success_icb_tbl_type IS TABLE OF rpt_success_tbl_type INDEX BY VARCHAR2(30);

g_rpt_success_icb_tbl         rpt_success_icb_tbl_type;
--Bug# 7277007

FUNCTION set_value_null(p_value_in IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  IF (p_value_in = OKL_API.G_MISS_CHAR) THEN
    RETURN NULL;
  END IF;
  RETURN p_value_in;
END;

FUNCTION set_value_null(p_value_in IN DATE) RETURN DATE IS
BEGIN
  IF (p_value_in = OKL_API.G_MISS_DATE) THEN
    RETURN NULL;
  END IF;
  RETURN p_value_in;
END;

FUNCTION set_value_null(p_value_in IN NUMBER) RETURN NUMBER IS
BEGIN
  IF (p_value_in = OKL_API.G_MISS_NUM) THEN
    RETURN NULL;
  END IF;
  RETURN p_value_in;
END;

--get the payment start date of skip and stub payments
FUNCTION get_pay_level_start_date(p_kle_id IN NUMBER,
                                  p_sequence IN NUMBER) RETURN DATE IS
  l_start_date DATE := NULL;

  cursor l_start_date_csr(cp_kle_id IN NUMBER, cp_sequence IN NUMBER) IS select start_date from (
  select rownum sequence, --this can replace the seq since seq num is not stored by authoring
    A.* from
    (Select sll.id,
           styp.code payment_type,
           sll.object1_id1        Pay_freq,
           sll.rule_information1  seq,
           fnd_date.canonical_to_date(sll.rule_information2) start_date,
           sll.rule_information3  number_periods,
           sll.rule_information4  tuoms_per_period,
           sll.rule_information6  amount,
           sll.rule_information7  stub_days,
           sll.rule_information8  stub_amount,
           sll.rule_information10 advance_or_arrears,
           sll.rule_information13 rate,
           rgp.cle_id             cle_id
    from   okc_rules_b sll,
           okc_rules_b slh,
           okl_strm_type_v styp,
           okc_rule_groups_b rgp
    where  to_number(sll.object2_id1) = slh.id
    and    sll.rule_information_category = 'LASLL'
    and    sll.dnz_chr_id  =  rgp.dnz_chr_id
    and    sll.rgp_id      = rgp.id
    and    slh.rule_information_category = 'LASLH'
    and    slh.dnz_chr_id  =  rgp.dnz_chr_id
    and    slh.rgp_id      = rgp.id
    and    slh.object1_id1 = styp.id
    and    rgp.rgd_code    = 'LALEVL'
    and    rgp.cle_id      = cp_kle_id
    order by rgp.cle_id
    , fnd_date.canonical_to_date(sll.rule_information2)) A
  )
  where sequence = cp_sequence;

BEGIN
  OPEN l_start_date_csr (p_kle_id, p_sequence);
  FETCH l_start_date_csr INTO l_start_date;
  CLOSE l_start_date_csr;

  return l_start_date;
END;

--get the start date, stub amount and stub days for a stub payment
FUNCTION get_stub_info(p_kle_id IN NUMBER,
                       p_start_date IN DATE,
                       x_stub_start_date OUT NOCOPY DATE,
                       x_stub_days OUT NOCOPY NUMBER,
                       x_stub_amount OUT NOCOPY NUMBER) RETURN VARCHAR2 IS
  l_stub_start_date DATE;
  l_stub_days NUMBER;
  l_stub_amount NUMBER;

  CURSOR l_stub_csr(cp_kle_id IN NUMBER, cp_start_date IN DATE) IS
  Select   fnd_date.canonical_to_date(sll.rule_information2) start_date,
           sll.rule_information7  stub_days,
           sll.rule_information8  stub_amount
    from   okc_rules_b sll,
           okc_rules_b slh,
           okl_strm_type_v styp,
           okc_rule_groups_b rgp
    where  to_number(sll.object2_id1) = slh.id
    and    sll.rule_information_category = 'LASLL'
    and    sll.dnz_chr_id  =  rgp.dnz_chr_id
    and    sll.rgp_id      = rgp.id
    and    slh.rule_information_category = 'LASLH'
    and    slh.dnz_chr_id  =  rgp.dnz_chr_id
    and    slh.rgp_id      = rgp.id
    and    slh.object1_id1 = styp.id
    and    rgp.rgd_code    = 'LALEVL'
    and    rgp.cle_id      = cp_kle_id
    and    sll.rule_information7 IS NOT NULL
    and    sll.rule_information8 IS NOT NULL
    --and    fnd_date.canonical_to_date(sll.rule_information2) <= cp_start_date
    order  by abs(fnd_date.canonical_to_date(sll.rule_information2) - cp_start_date) asc;
BEGIN
  OPEN l_stub_csr(p_kle_id, p_start_date);
  FETCH l_stub_csr INTO l_stub_start_date, l_stub_days, l_stub_amount;
  CLOSE l_stub_csr;

  x_stub_start_date := l_stub_start_date;
  x_stub_days := l_stub_days;
  x_stub_amount := l_stub_amount;

  return '';
END;
  ------------------------------------------------------------------------------
  -- PROCEDURE print_line
  --
  --  This procedure prints message
  --
  -- Calls:
  -- Called By:
  ------------------------------------------------------------------------------

PROCEDURE print_line (p_message IN VARCHAR2) IS
BEGIN
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, p_message);
EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '** EXCEPTION IN print_line: '||SQLERRM);
END print_line;

  ------------------------------------------------------------------------------
  -- PROCEDURE print
  --
  --  This procedure prints message
  --
  -- Calls:
  -- Called By:
  ------------------------------------------------------------------------------
/* Included this procedure to avoid GSCC error file.sql.26 */
PROCEDURE print(p_message IN VARCHAR2) IS
BEGIN
  FND_FILE.PUT(FND_FILE.OUTPUT, p_message);
EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '** EXCEPTION IN print_line: '||SQLERRM);
END print;

  ------------------------------------------------------------------------------
  -- PROCEDURE print_debug
  --
  --  This procedure prints message
  --
  -- Calls:
  -- Called By:
  ------------------------------------------------------------------------------

PROCEDURE print_debug (p_message IN VARCHAR2) IS
BEGIN
--  IF ( G_DEBUG = 'Y' ) THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, p_message);
    --OKL_DEBUG_PUB.logmessage(p_message, 25);
--    dbms_output.put_line(p_message);
--  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, '** EXCEPTION IN print_line: '||SQLERRM);
END print_debug;

  ------------------------------------------------------------------------------
  -- PROCEDURE print_error_message
  --
  --  This procedure prints error message in the request log file
  --
  -- Calls:
  -- Called By:
  ------------------------------------------------------------------------------

PROCEDURE print_error_message (p_message IN VARCHAR2) IS
BEGIN
    FND_FILE.PUT_LINE (FND_FILE.LOG, p_message);
EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, '** EXCEPTION IN print_line: '||SQLERRM);
END print_error_message;

  ------------------------------------------------------------------------------
  -- PROCEDURE report_error
  --
  --  This procedure prints error messages
  --
  -- Calls:
  -- Called By:
  ------------------------------------------------------------------------------

  PROCEDURE Report_Error(p_contract_number     IN VARCHAR2,
                         p_product_name        IN VARCHAR2,
                         p_interest_calc_basis IN VARCHAR2,
                         p_last_int_calc_date  IN DATE,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        ) IS

  x_msg_index_out NUMBER;
  x_msg_out       VARCHAR2(2000);

  BEGIN

    okl_api.end_activity(
                         X_msg_count => x_msg_count,
                         X_msg_data  => x_msg_data
                        );

     --Bug# 7277007
     IF g_rpt_summary_tbl.EXISTS(p_interest_calc_basis)
     THEN
       g_rpt_summary_tbl(p_interest_calc_basis).total_contract_num_error :=
         NVL(g_rpt_summary_tbl(p_interest_calc_basis).total_contract_num_error,0) + 1;
     ELSE
       g_rpt_summary_tbl(p_interest_calc_basis).total_contract_num_error := 1;
     END IF;

    g_rpt_error_tbl_counter := g_rpt_error_tbl_counter + 1;
    g_rpt_error_tbl(g_rpt_error_tbl_counter).contract_number      := p_contract_number;
    g_rpt_error_tbl(g_rpt_error_tbl_counter).product_name         := p_product_name;
    g_rpt_error_tbl(g_rpt_error_tbl_counter).interest_calc_basis  := p_interest_calc_basis;
    g_rpt_error_tbl(g_rpt_error_tbl_counter).last_int_calc_date   := p_last_int_calc_date;
    --Bug# 7277007

    FOR i in 1..x_msg_count
    LOOP
      FND_MSG_PUB.GET(
                      p_msg_index     => i,
                      p_encoded       => FND_API.G_FALSE,
                      p_data          => x_msg_data,
                      p_msg_index_out => x_msg_index_out
                     );

      --Bug# 7277007
      g_rpt_error_tbl(g_rpt_error_tbl_counter).error_msg_tbl(i) := SUBSTR(x_msg_data,1,2000);
      print_debug('Error '||to_char(i)||': '||x_msg_data);

    END LOOP;
    return;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Report_Error;
------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    initialize_contract_params
    -- Description:      This procedure initializes the package variables
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  PROCEDURE initialize_contract_params (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER)   IS

  l_api_name                   CONSTANT    VARCHAR2(30) := 'INITIALIZE_CONTRACT_PARAMS';
  l_api_version                CONSTANT    NUMBER       := 1.0;
  init_ctr_params_failed       EXCEPTION;
  l_interest_calculation_basis OKL_PRODUCT_PARAMETERS_V.interest_calculation_basis%TYPE;


  Cursor contract_csr (p_contract_id NUMBER) IS
      SELECT id,
	         deal_type,
             start_date,
             end_date,
             currency_code,
             pdt_id,
             authoring_org_id
      FROM   okl_k_headers_full_v
      WHERE  id = p_contract_id;

  Cursor interest_params_csr (p_contract_id NUMBER) IS
      SELECT interest_basis_code,
             calculation_formula_id,
             nvl(principal_basis_code, 'ACTUAL') principal_basis_code,
             days_in_a_month_code,
             days_in_a_year_code,
             catchup_settlement_code
      FROM   okl_k_rate_params
      WHERE  khr_id = p_contract_id
      AND    SYSDATE BETWEEN effective_from_date and nvl(effective_to_date, SYSDATE);

  Cursor product_params_csr (p_product_id NUMBER) IS
      SELECT ppm.revenue_recognition_method,
             ppm.interest_calculation_basis
      FROM   okl_product_parameters_v ppm
       WHERE ppm.id = p_product_id;

  BEGIN
    x_return_status     := OKL_API.G_RET_STS_SUCCESS;

    print_debug('Executing procedure INITIALIZE_CONTRACT_PARAMS using following parameters : ');
    print_debug(' p_contract_id : '|| p_contract_id );

    IF (G_CONTRACT_ID IS NULL OR G_CONTRACT_ID <> p_contract_id) THEN
      OPEN contract_csr (p_contract_id);
      FETCH contract_csr INTO G_CONTRACT_ID, G_DEAL_TYPE, G_CONTRACT_START_DATE, G_CONTRACT_END_DATE,
	                          G_CURRENCY_CODE, G_PRODUCT_ID, G_AUTHORING_ORG_ID;
      IF (contract_csr%NOTFOUND) THEN
        CLOSE contract_csr;
        print_error_message('Contract cursor did not return records for contract ID :' || p_contract_id);
        RAISE init_ctr_params_failed;
      END IF;
      CLOSE contract_csr;

      -- Fix for bug 6760186
      OPEN product_params_csr (G_PRODUCT_ID);
      FETCH product_params_csr INTO G_REVENUE_RECOGNITION_METHOD, l_interest_calculation_basis;
      IF (product_params_csr%NOTFOUND) THEN
        CLOSE product_params_csr;
        print_error_message('Product Params cursor did not return records for product ID :' || G_PRODUCT_ID);
        RAISE init_ctr_params_failed;
      END IF;
      CLOSE product_params_csr;

      OPEN interest_params_csr (p_contract_id);
      FETCH interest_params_csr INTO G_INTEREST_BASIS_CODE, G_CALCULATION_FORMULA_ID, G_PRINCIPAL_BASIS_CODE,
	                          G_DAYS_IN_A_MONTH_CODE, G_DAYS_IN_A_YEAR_CODE, G_CATCHUP_SETTLEMENT_CODE;
      IF (interest_params_csr%NOTFOUND) THEN
        CLOSE interest_params_csr;
        print_error_message('Interest Params cursor did not return records for contract ID :' || p_contract_id);
        RAISE init_ctr_params_failed;
      END IF;
      CLOSE interest_params_csr;

      /* Moved this code before querying interest rate parameters --6760186 */
      /*OPEN product_params_csr (G_PRODUCT_ID);
      FETCH product_params_csr INTO G_REVENUE_RECOGNITION_METHOD, l_interest_calculation_basis;
      IF (product_params_csr%NOTFOUND) THEN
        CLOSE product_params_csr;
        print_error_message('Product Params cursor did not return records for product ID :' || G_PRODUCT_ID);
        RAISE init_ctr_params_failed;
      END IF;
      CLOSE product_params_csr;      */
      -- 5047041
      -- These changes are required to meet the requirements of code in procedure Interest_Date_Range
      IF (G_INTEREST_CALCULATION_BASIS IS NULL OR G_INTEREST_CALCULATION_BASIS <> 'DAILY_INTEREST') THEN
        G_INTEREST_CALCULATION_BASIS := l_interest_calculation_basis;
      END IF;

      IF (l_interest_calculation_basis = 'FIXED' AND
        G_REVENUE_RECOGNITION_METHOD = 'ACTUAL') THEN
        G_INTEREST_CALCULATION_BASIS := 'DAILY_INTEREST';
      END IF;
      -- These changes are required to meet the requirements of code in procedure Interest_Date_Range
    END IF;



        print_debug('Contract ID: '|| G_CONTRACT_ID);
        print_debug('Authoring Org ID: '|| G_AUTHORING_ORG_ID);
        print_debug('Product ID: '|| G_PRODUCT_ID);
  	    print_debug('deal type :'|| G_DEAL_TYPE );
	    print_debug('Contract Start Date: '||G_CONTRACT_START_DATE);
	    print_debug('Contract End Date: '||G_CONTRACT_END_DATE);
	    print_debug('Currency code: '||G_CURRENCY_CODE);
	    print_debug('calculation basis : '|| G_INTEREST_CALCULATION_BASIS );
	    print_debug('revenue recognition method : '|| G_REVENUE_RECOGNITION_METHOD);
	    print_debug('Principal Balance : '|| G_CONTRACT_PRINCIPAL_BALANCE);
	    print_debug('Interest basis : '|| G_INTEREST_BASIS_CODE );
	    print_debug('Calculation Formula ID : '|| G_CALCULATION_FORMULA_ID);
	    print_debug('Principal Basis : '|| G_PRINCIPAL_BASIS_CODE);
	    print_debug('Days in a Month : '|| G_DAYS_IN_A_MONTH_CODE);
	    print_debug('Days in a Year  : '|| G_DAYS_IN_A_YEAR_CODE);
	    print_debug('Catchup Settlement Code  : '|| G_CATCHUP_SETTLEMENT_CODE);

	    print_debug ('Exiting initialize_contract_params');

  EXCEPTION
     WHEN init_ctr_params_failed THEN
       print_error_message('init_ctr_params_failed Exception raised in procedure INITIALIZE_CONTRACT_PARAMS');
       x_return_status := OKL_API.G_RET_STS_ERROR;

     WHEN OTHERS THEN
       print_error_message('Exception raised in procedure INITIALIZE_CONTRACT_PARAMS');
       Okl_Api.SET_MESSAGE(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_UNEXPECTED_ERROR,
               p_token1       => G_SQLCODE_TOKEN,
               p_token1_value => SQLCODE,
               p_token2       => G_SQLERRM_TOKEN,
               p_token2_value => SQLERRM);

       x_return_status := OKL_API.G_RET_STS_ERROR;

  END initialize_contract_params;

------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    Get_contract_financed_amount
    -- Description:      The function derives the financed amount at Header Level
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  PROCEDURE get_contract_financed_amount (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
			x_principal_balance  OUT NOCOPY NUMBER) IS

  l_api_name               CONSTANT    VARCHAR2(30) := 'GET_CONTRACT_FINANCED_AMOUNT';
  l_api_version            CONSTANT    NUMBER       := 1.0;
  get_ctr_fin_amt_failed   EXCEPTION;


  BEGIN
    x_return_status     := OKL_API.G_RET_STS_SUCCESS;

    print_debug('Executing procedure GET_CONTRACT_FINANCED_AMOUNT using following parameters : ');
    print_debug(' p_contract_id : '|| p_contract_id );
    print_debug(' G_CONTRACT_ID : '|| G_CONTRACT_ID );
    print_debug(' G_CONTRACT_PRINCIPAL_BALANCE : '|| G_CONTRACT_PRINCIPAL_BALANCE );


    IF (G_CONTRACT_ID IS NULL OR
        G_CONTRACT_PRINCIPAL_BALANCE IS NULL OR
	    G_CONTRACT_ID <> p_contract_id
	   ) THEN
      -- Derive Principal Balance
      Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => 1.0,
                                      p_init_msg_list        => OKL_API.G_FALSE,
                                      x_return_status        => x_return_status,
                                      x_msg_count            => x_msg_count,
                                      x_msg_data             => x_msg_data,
                                      p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                      p_contract_id          => p_contract_id,
                                      p_line_id              => NULL,
                                      x_value               =>  x_principal_balance
                                     );

      IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	     print_debug ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE completed successfully');
      ELSIF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  	     print_debug ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned unexpected error');
  	     print_error_message ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned unexpected error');
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	     print_debug ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned exception');
	     print_error_message ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned exception');
         RAISE get_ctr_fin_amt_failed;
      END IF;

	  G_CONTRACT_ID := p_contract_id;
	  G_CONTRACT_PRINCIPAL_BALANCE := x_principal_balance;

	ELSE
      x_principal_balance := G_CONTRACT_PRINCIPAL_BALANCE;
	END IF;

    print_debug('Contract Financed Amount : '|| x_principal_balance);


  EXCEPTION
     WHEN get_ctr_fin_amt_failed THEN
       print_error_message('get_ctr_fin_amt_failed Exception raised in procedure GET_CONTRACT_FINANCED_AMOUNT');
       x_return_status := OKL_API.G_RET_STS_ERROR;

     WHEN OTHERS THEN
       print_error_message('Exception raised in procedure GET_CONTRACT_FINANCED_AMOUNT');
       Okl_Api.SET_MESSAGE(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_UNEXPECTED_ERROR,
               p_token1       => G_SQLCODE_TOKEN,
               p_token1_value => SQLCODE,
               p_token2       => G_SQLERRM_TOKEN,
               p_token2_value => SQLERRM);

       x_return_status := OKL_API.G_RET_STS_ERROR;

  END get_contract_financed_amount;

------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    Get_Line_financed_amount
    -- Description:      The function derives the financed amount at Header Level
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  PROCEDURE get_asset_financed_amount (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_line_id            IN  NUMBER,
			x_principal_balance  OUT NOCOPY NUMBER) IS

  l_api_name               CONSTANT    VARCHAR2(30) := 'GET_ASSET_FINANCED_AMOUNT';
  l_api_version            CONSTANT    NUMBER       := 1.0;
  get_asset_fin_amt_failed   EXCEPTION;


  BEGIN
    x_return_status     := OKL_API.G_RET_STS_SUCCESS;

    print_debug('Executing procedure GET_ASSET_FINANCED_AMOUNT using following parameters : ');
    print_debug(' p_contract_id : '|| p_contract_id );
    print_debug(' p_line_id : '|| p_line_id );
    print_debug(' G_CONTRACT_ID : '|| G_CONTRACT_ID );
    print_debug(' G_FIN_AST_LINE_ID : '|| G_FIN_AST_LINE_ID);
    print_debug(' G_ASSET_PRINCIPAL_BALANCE : '|| G_ASSET_PRINCIPAL_BALANCE );


    IF (G_CONTRACT_ID IS NULL OR
	    G_FIN_AST_LINE_ID IS NULL OR
        G_ASSET_PRINCIPAL_BALANCE IS NULL OR
	    G_CONTRACT_ID <> p_contract_id OR
		G_FIN_AST_LINE_ID <> p_line_id
	   ) THEN
      -- Derive Principal Balance
      Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => 1.0,
                                      p_init_msg_list        => OKL_API.G_FALSE,
                                      x_return_status        => x_return_status,
                                      x_msg_count            => x_msg_count,
                                      x_msg_data             => x_msg_data,
                                      p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                      p_contract_id          => p_contract_id,
                                      p_line_id              => p_line_id,
                                      x_value               =>  x_principal_balance
                                     );

      IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	     print_debug ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE completed successfully');
      ELSIF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  	     print_debug ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned unexpected error');
  	     print_error_message ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned unexpected error');
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	     print_debug ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned exception');
	     print_error_message ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned exception');
         RAISE get_asset_fin_amt_failed;
      END IF;

	  G_CONTRACT_ID := p_contract_id;
	  G_FIN_AST_LINE_ID := p_line_id;
	  G_ASSET_PRINCIPAL_BALANCE := x_principal_balance;

	ELSE
      x_principal_balance := G_ASSET_PRINCIPAL_BALANCE;
	END IF;

    print_debug('Asset Line Financed Amount : '|| x_principal_balance);


  EXCEPTION
     WHEN get_asset_fin_amt_failed THEN
       print_error_message('get_asset_fin_amt_failed Exception raised in procedure GET_ASSET_FINANCED_AMOUNT');
       x_return_status := OKL_API.G_RET_STS_ERROR;

     WHEN OTHERS THEN
       print_error_message('Exception raised in procedure GET_ASSET_FINANCED_AMOUNT');
       Okl_Api.SET_MESSAGE(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_UNEXPECTED_ERROR,
               p_token1       => G_SQLCODE_TOKEN,
               p_token1_value => SQLCODE,
               p_token2       => G_SQLERRM_TOKEN,
               p_token2_value => SQLERRM);

       x_return_status := OKL_API.G_RET_STS_ERROR;

  END get_asset_financed_amount;
  ------------------------------------------------------------------------------
  -- PROCEDURE print_report
  --
  --  This procedure prints consolidated list of processed contracts
  --
  -- Calls:
  -- Called By:
  ------------------------------------------------------------------------------
  --Bug# 7277007
  PROCEDURE Print_Report(
                         p_contract_number IN VARCHAR2
                        ) IS

  l_operating_unit_name  HR_OPERATING_UNITS.name%TYPE;
  l_currency_code        GL_LEDGERS_PUBLIC_V.currency_code%TYPE;
  l_index                NUMBER;
  l_rec_count            NUMBER;
  l_no_of_days           NUMBER;
  l_counter              NUMBER;
  l_contract_number      OKC_K_HEADERS_B.contract_number%TYPE;
  l_contract_number1     OKC_K_HEADERS_B.contract_number%TYPE;
  l_contract_number2     OKC_K_HEADERS_B.contract_number%TYPE;
  l_icb_counter          VARCHAR2(30);
  l_days_in_a_month_code OKL_K_RATE_PARAMS.days_in_a_month_code%TYPE;
  l_days_in_a_year_code  OKL_K_RATE_PARAMS.days_in_a_year_code%TYPE;
  l_separator            VARCHAR2(1);
  l_success_count        NUMBER;
  l_rejected_count       NUMBER;

  CURSOR operating_unit_csr IS
    SELECT hou.name,
           book.currency_code
    FROM   hr_operating_units hou,
           GL_LEDGERS_PUBLIC_V book
    WHERE  hou.set_of_books_id = book.ledger_id
                  AND hou.ORGANIZATION_ID = mo_global.get_current_org_id();

  CURSOR var_int_params_csr (p_contract_id NUMBER) IS
    SELECT vip.interest_calc_start_date,
           vip.interest_calc_end_date,
           vip.interest_rate,
           OKL_ACCOUNTING_UTIL.format_amount(NVL(vip.principal_balance,0),chr.currency_code) principal_balance,
           OKL_ACCOUNTING_UTIL.format_amount(NVL(vip.interest_amt,0),chr.currency_code) interest_amt,
           vip.interest_calc_days
    FROM   okl_var_int_params vip,
           okc_k_headers_b chr
    WHERE  chr.id = p_contract_id
    AND    vip.khr_id = chr.id
    AND    vip.request_id = g_request_id;

  BEGIN

    OPEN operating_unit_csr;
    FETCH operating_unit_csr INTO l_operating_unit_name, l_currency_code;
    IF ( operating_unit_csr % NOTFOUND) THEN
       NULL;
    END IF;
    CLOSE operating_unit_csr;

    print_line('Create Receivables Variable Rate Invoices');
    print_line('****************************************************************************************************');
    print_line('Program Run Date: '||trunc(sysdate));
    print_line('Operating Unit: '||l_operating_unit_name);
    print_line('Contract Number: '||p_contract_number);
    print_line('To Due Date: '||trunc(g_to_date));
    print_line('****************************************************************************************************');
    print_line(' ');
    print_line(' ');
    print_line('====================================================================================================');
    print_line('Summary');
    print_line(' ');
    print_line(' _________________________________________________________________________');
    print_line('|                               |           Number of contracts           |');
    print_line('| Interest Calculation Basis    |   Processed |    Rejected |       Total |');
    print_line('|_______________________________|_____________|_____________|_____________|');

    l_success_count := 0;
    l_rejected_count := 0;
    IF (g_rpt_summary_tbl.COUNT > 0) THEN
      l_icb_counter := g_rpt_summary_tbl.FIRST;
      LOOP

        l_success_count  := l_success_count + NVL(g_rpt_summary_tbl(l_icb_counter).total_contract_num_success,0);
        l_rejected_count := l_rejected_count + NVL(g_rpt_summary_tbl(l_icb_counter).total_contract_num_error,0);

        print_line('| ' || RPAD(l_icb_counter,30,' ') || '|' ||
                           LPAD(NVL(g_rpt_summary_tbl(l_icb_counter).total_contract_num_success,0),12,' ')  || ' |' ||
                           LPAD(NVL(g_rpt_summary_tbl(l_icb_counter).total_contract_num_error,0),12,' ')    || ' |' ||
                           LPAD((NVL(g_rpt_summary_tbl(l_icb_counter).total_contract_num_success,0) +
                                 NVL(g_rpt_summary_tbl(l_icb_counter).total_contract_num_error,0)),12,' ')  || ' |');

        print_line('|_________________________________________________________________________|');

        EXIT WHEN l_icb_counter = g_rpt_summary_tbl.LAST;
        l_icb_counter := g_rpt_summary_tbl.next(l_icb_counter);
      END LOOP;
    ELSE
      print_line('|_________________________________________________________________________|');
    END IF;

    print_line('| ' || RPAD('Total',30,' ') || '|' || LPAD(l_success_count,12,' ') || ' |' || LPAD(l_rejected_count,12,' ') || ' |');
    print_line('|_______________________________|_____________|_____________|');

    print_line(' ');
    print_line(' ');
    print_line('====================================================================================================');

    IF (g_rpt_error_tbl.COUNT > 0) THEN
      print_line('Rejected Contracts');
      print_line('____________________________________________________________________________________________________');

      FOR i IN g_rpt_error_tbl.FIRST..g_rpt_error_tbl.LAST LOOP
        print_line(' ');
        print_line(RPAD('Contract Number: '||g_rpt_error_tbl(i).contract_number,77,' ')||
                   'Product: '||g_rpt_error_tbl(i).product_name);

        IF LENGTH(g_rpt_error_tbl(i).contract_number) > 60 THEN
          print_line(LPAD(SUBSTR(g_rpt_error_tbl(i).contract_number,61),' ',17));
        END IF;

        print_line(RPAD('Interest Calculation Basis: '||g_rpt_error_tbl(i).interest_calc_basis,77,' ')||
                   'Last Interest Calculation Date: '||g_rpt_error_tbl(i).last_int_calc_date);
        print_line(' ');
        print_line('Error Description: ');

        FOR j IN g_rpt_error_tbl(i).error_msg_tbl.FIRST..g_rpt_error_tbl(i).error_msg_tbl.LAST LOOP

          l_counter := 1;
          WHILE l_counter <= LENGTH(g_rpt_error_tbl(i).error_msg_tbl(j))
          LOOP
            print_line(SUBSTR(g_rpt_error_tbl(i).error_msg_tbl(j),l_counter,105));
            l_counter := l_counter + 105;
          END LOOP;

        END LOOP;

        print_line(' ');
        print_line('____________________________________________________________________________________________________');
      END LOOP;

      print_line(' ');
      print_line(' ');
      print_line('====================================================================================================');
    END IF;

    IF (g_rpt_success_icb_tbl.COUNT > 0) THEN

      print_line('Processed Contracts');
      print_line(' ');

      l_icb_counter := g_rpt_success_icb_tbl.FIRST;
      LOOP

        print_line('Interest Calculation Basis'||RPAD(' ',30,' ')||': '||l_icb_counter);
        print_line(' ');
        print_line(' '|| RPAD('_',151,'_'));

        print_line('|' || RPAD('Contract Number',40,' ') ||
                  ' |' || RPAD('Days',15,' ') ||
                  ' |' || RPAD('Interest',11,' ') ||
                  ' |' || RPAD('Interest',11,' ') ||
                  ' |' || LPAD('Interest',10,' ') ||
                  ' |' || LPAD('Effective(%)',13,' ') ||
                  ' |' || LPAD('Principal Amount',18,' ') ||
                  ' |' || LPAD('Interest Amount',18,' ') ||
                  ' |');

        print_line('|' || RPAD(' ',40,' ') ||
                  ' |' || RPAD('Month/Year',15,' ') ||
                  ' |' || RPAD('Start Date',11,' ') ||
                  ' |' || RPAD('End Date',11,' ') ||
                  ' |' || LPAD('Calc. Days',10,' ') ||
                  ' |' || LPAD('Interest Rate',13,' ') ||
                  ' |' || LPAD(' ',18,' ') ||
                  ' |' || LPAD(' ',18,' ') ||
                  ' |');

        print_line('|' || RPAD('_',151,'_') || '|');

        FOR i IN  g_rpt_success_icb_tbl(l_icb_counter).FIRST..g_rpt_success_icb_tbl(l_icb_counter).LAST LOOP

          l_contract_number  := g_rpt_success_icb_tbl(l_icb_counter)(i).contract_number;
          l_contract_number1 := NULL;
          l_contract_number2 := NULL;
          IF LENGTH(l_contract_number) > 40 THEN
            l_contract_number1 := SUBSTR(l_contract_number,41,40);
            l_contract_number2 := SUBSTR(l_contract_number,81,40);
          END IF;

          l_days_in_a_month_code := g_rpt_success_icb_tbl(l_icb_counter)(i).days_in_a_month_code;
          l_days_in_a_year_code  := g_rpt_success_icb_tbl(l_icb_counter)(i).days_in_a_year_code;
          l_separator            := '/';

          FOR var_int_param_rec IN var_int_params_csr(g_rpt_success_icb_tbl(l_icb_counter)(i).contract_id)
          LOOP

            print_line('|' || RPAD(l_contract_number,40,' ') ||
                      ' |' || LPAD(l_days_in_a_month_code,7,' ') || l_separator || RPAD(l_days_in_a_year_code,7,' ') ||
                      ' |' || RPAD(TO_CHAR(var_int_param_rec.interest_calc_start_date,'DD-MON-RRRR'),11,' ') ||
                      ' |' || RPAD(TO_CHAR(var_int_param_rec.interest_calc_end_date,'DD-MON-RRRR'),11,' ') ||
                      ' |' || LPAD(NVL(var_int_param_rec.interest_calc_days,0),10,' ') ||
                      ' |' || LPAD(NVL(var_int_param_rec.interest_rate,0),13,' ') ||
                      ' |' || LPAD(NVL(var_int_param_rec.principal_balance,0),18,' ') ||
                      ' |' || LPAD(NVL(var_int_param_rec.interest_amt,0),18,' ') ||
                      ' |');

            IF l_contract_number1 IS NOT NULL THEN
              print_line('|' || RPAD(l_contract_number1,40,' ') ||
                        ' |' || RPAD(' ',15,' ') ||
                        ' |' || RPAD(' ',11,' ') ||
                        ' |' || RPAD(' ',11,' ') ||
                        ' |' || LPAD(' ',10,' ') ||
                        ' |' || LPAD(' ',13,' ') ||
                        ' |' || LPAD(' ',18,' ') ||
                        ' |' || LPAD(' ',18,' ') ||
                        ' |');
            END IF;

            IF l_contract_number2 IS NOT NULL THEN
              print_line('|' || RPAD(l_contract_number2,40,' ') ||
                        ' |' || RPAD(' ',15,' ') ||
                        ' |' || RPAD(' ',11,' ') ||
                        ' |' || RPAD(' ',11,' ') ||
                        ' |' || LPAD(' ',10,' ') ||
                        ' |' || LPAD(' ',13,' ') ||
                        ' |' || LPAD(' ',18,' ') ||
                        ' |' || LPAD(' ',18,' ') ||
                        ' |');
            END IF;
            l_contract_number      := ' ';
            l_contract_number1     := NULL;
            l_contract_number2     := NULL;
            l_days_in_a_month_code := ' ';
            l_days_in_a_year_code  := ' ';
            l_separator            := ' ';
          END LOOP;
          print_line('|' || RPAD('_',151,'_') || '|');
        END LOOP;

        EXIT WHEN l_icb_counter = g_rpt_success_icb_tbl.LAST;
        l_icb_counter := g_rpt_success_icb_tbl.next(l_icb_counter);
        print_line(' ');
        print_line(' ');
      END LOOP;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       Sanjeev Ahuja
    -- Function Name  contract_future rent
    -- Description:   returns the sum of rent
    -- Dependencies:
    -- Parameters: contract id, date.
    -- Version: 1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  FUNCTION contract_future_rents(
            p_chr_id            IN    NUMBER,
            p_kle_id            IN    NUMBER,
            p_date              IN    DATE,
            p_advance_or_arrears IN   VARCHAR2) RETURN NUMBER  IS

/*    l_api_name		CONSTANT    VARCHAR2(30) := 'contract_future_rents';
    l_api_version	CONSTANT    NUMBER	      := 1;
    x_return_status             VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(256);
*/
    l_rents                     NUMBER := 0;

    Cursor ln_future_rents_csr (p_chr_id NUMBER, p_kle_id NUMBER, p_date DATE, p_advance_or_arrears VARCHAR2 ) IS
    select NVL(sum(sel.amount), 0) amount
    from
         okl_K_lines_full_v kle,
         okc_statuses_b sts,
         okl_strm_elements sel,
         okl_streams stm,
         okl_strm_type_b sty
    WHERE kle.dnz_chr_id = p_chr_id
    AND   kle.id = p_kle_id
    AND   kle.sts_code = sts.code
    AND   sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD')
    AND   kle.dnz_chr_id = stm.khr_id
    AND   kle.id   = stm.kle_id
    AND   stm.say_code = 'CURR'
    AND   stm.active_yn = 'Y'
    AND   stm.sty_id = sty.id
    AND   sty.stream_type_purpose = 'RENT'
    AND   stm.id = sel.stm_id
    AND   ((p_advance_or_arrears = 'ARREARS' and sel.stream_element_date > p_date)
            OR (p_advance_or_arrears <> 'ARREARS' and sel.stream_element_date >= p_date));

    ln_future_rents_rec ln_future_rents_csr%ROWTYPE;

    Cursor l_chr_rents_csr (p_chr_id NUMBER, p_kle_id NUMBER, p_date DATE, p_advance_or_arrears VARCHAR2) IS
    SELECT  NVL(SUM(sele.amount),0) amount
    FROM    okl_strm_elements sele,
        okl_streams str,
        okl_strm_type_b sty
    WHERE   sele.stm_id = str.id
    AND     str.sty_id = sty.id
    AND     sty.stream_type_purpose = 'RENT'
    AND     str.say_code = 'CURR'
    AND     str.active_yn = 'Y'
    AND     nvl( str.purpose_code, 'XXXX' ) = 'XXXX'
    AND     str.khr_id = p_chr_id
    AND     str.kle_id = p_kle_id
    AND     nvl(str.kle_id, -1) = -1
    AND   ((p_advance_or_arrears = 'ARREARS' and sele.stream_element_date > p_date)
            OR (p_advance_or_arrears <> 'ARREARS' and sele.stream_element_date >= p_date));

    l_chr_rents_rec l_chr_rents_csr%ROWTYPE;

  BEGIN

       IF ( p_chr_id IS NULL OR p_kle_id IS NULL) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       OPEN ln_future_rents_csr(p_chr_id, p_kle_id, p_date, p_advance_or_arrears);
       FETCH ln_future_rents_csr INTO ln_future_rents_rec;
       CLOSE ln_future_rents_csr;

       OPEN l_chr_rents_csr(p_chr_id, p_kle_id, p_date, p_advance_or_arrears);
       FETCH l_chr_rents_csr INTO l_chr_rents_rec;
       CLOSE l_chr_rents_csr;

       l_rents := ln_future_rents_rec.amount + l_chr_rents_rec.amount;

       print_debug('Contract future rent :' || l_rents);
       RETURN l_rents;


  EXCEPTION
	WHEN OTHERS  THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;

  END contract_future_rents;

  ------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Sanjeev Ahuja
    -- Function Name  contract_future_income
    -- Description:   returns sum of all future incomes of financial asset lines of a contract
    -- Dependencies:
    -- Parameters: contract id, date.
    -- Version: 1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  FUNCTION contract_future_income(
            p_chr_id          IN  NUMBER,
            p_kle_id          IN  NUMBER,
            p_date            IN  DATE) RETURN NUMBER  IS

/*    l_api_name		CONSTANT    VARCHAR2(30) := 'RETURN_CONTRACT_FUTURE_INCOME';
    l_api_version	CONSTANT    NUMBER	      := 1;
    x_return_status             VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(256);
*/
    l_income                    NUMBER := 0;

    Cursor l_chr_income_csr (p_chr_id NUMBER, p_kle_id NUMBER, p_date DATE) IS
    select NVL(sum(sel.amount), 0) amount
    from
         okl_K_lines_full_v kle,
         okc_statuses_b sts,
         okl_strm_elements sel,
         okl_streams stm,
         okl_strm_type_b sty
    WHERE kle.dnz_chr_id = p_chr_id
    AND   kle.id = p_kle_id
    AND   kle.sts_code = sts.code
    AND   sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD')
    AND   kle.dnz_chr_id = stm.khr_id
    AND   kle.id   = stm.kle_id
    AND   stm.say_code = 'CURR'
    AND   stm.active_yn = 'Y'
    AND   stm.sty_id = sty.id
    AND   sty.stream_type_purpose = 'LEASE_INCOME'
    AND   stm.id = sel.stm_id
    AND   sel.stream_element_date >= TRUNC(p_date, 'MONTH');

    l_chr_income_rec l_chr_income_csr%ROWTYPE;
  BEGIN

       IF ( p_chr_id IS  NULL OR p_kle_id IS NULL) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       OPEN l_chr_income_csr(p_chr_id, p_kle_id, p_date);
       FETCH l_chr_income_csr INTO l_chr_income_rec;
       CLOSE l_chr_income_csr;

       l_income := l_chr_income_rec.amount;

       print_debug('Contract future income :' || l_income);
       RETURN l_income;


  EXCEPTION

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;


  END contract_future_income;

  ------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Sanjeev Ahuja
    -- Function Name  contract_future_income
    -- Description:   returns sum of all future incomes of financial asset lines of a contract
    -- Dependencies:
    -- Parameters: contract id, date.
    -- Version: 1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  FUNCTION contract_residual_value(
            p_chr_id          IN  NUMBER,
            p_kle_id          IN  NUMBER) RETURN NUMBER  IS

/*    l_api_name		CONSTANT    VARCHAR2(30) := 'contract_residual_value';
    l_api_version	CONSTANT    NUMBER	      := 1;
    x_return_status             VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(256);
*/
    l_residual_value                    NUMBER := 0;

    Cursor residual_value_csr (p_chr_id     IN NUMBER, p_kle_id IN NUMBER) IS
    SELECT  nvl(kle.residual_value,0) Value
    FROM    OKC_LINE_STYLES_B LS,
        okl_K_lines_full_v kle,
	    okc_statuses_b sts
    WHERE   LS.ID = KLE.LSE_ID
    AND     LS.LTY_CODE ='FREE_FORM1'
    AND     KLE.DNZ_CHR_ID = p_chr_id --289326506849179644190030423574805590144
    AND     KLE.id = p_kle_id
    AND     kle.sts_code = sts.code
    AND     sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');

    residual_value_rec residual_value_csr%ROWTYPE;
  BEGIN

       IF ( p_chr_id IS NULL OR p_kle_id IS NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       OPEN residual_value_csr(p_chr_id, p_kle_id);
       FETCH residual_value_csr INTO residual_value_rec;
       CLOSE residual_value_csr;

       l_residual_value := residual_value_rec.Value;

       print_debug('Contract residual value :' || l_residual_value);
       RETURN l_residual_value;


  EXCEPTION

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;


  END contract_residual_value;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Sanjeev Ahuja
    -- Function Name  asset_cost_loan
    -- Description:   returns asset cost for a loan contract
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Comments

----------------------------------------------------------------------------------------------------
  FUNCTION asset_cost_loan(
            p_chr_id          IN  NUMBER) RETURN NUMBER  IS

    l_api_name		CONSTANT    VARCHAR2(30) := 'RETURN_CONTRACT_RESIDUAL_VALUE';
    l_api_version	CONSTANT    NUMBER	      := 1;
    x_return_status             VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(256);

    l_asset_cost                    NUMBER := 0;

    Cursor loan_asset_cost_csr (p_chr_id     IN NUMBER) IS
    select  sum(okl_line.capital_amount) asset_cost
    from    okc_k_lines_b okc_line,
        okc_line_styles_b style,
        okl_k_lines okl_line
    where   okc_line.chr_id             = p_chr_id --276779267018378275653765386722943545472
    and     okc_line.lse_id             = style.id
    and     style.lty_code              = 'FREE_FORM1'
    and     okc_line.id                 = okl_line.id;

    loan_asset_cost_rec loan_asset_cost_csr%ROWTYPE;
  BEGIN

       IF ( p_chr_id = NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       OPEN loan_asset_cost_csr(p_chr_id);
       FETCH loan_asset_cost_csr INTO loan_asset_cost_rec;
       CLOSE loan_asset_cost_csr;

       l_asset_cost := loan_asset_cost_rec.asset_cost;

       RETURN l_asset_cost;


  EXCEPTION

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;


  END asset_cost_loan;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Sanjeev Ahuja
    -- Function Name  payment_received
    -- Description:   returns payment received for a loan contract
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Comments

----------------------------------------------------------------------------------------------------
  FUNCTION payment_received(
            p_chr_id          IN    NUMBER,
            p_date            IN    DATE) RETURN NUMBER  IS

    l_api_name		CONSTANT    VARCHAR2(30) := 'RETURN_CONTRACT_RESIDUAL_VALUE';
    l_api_version	CONSTANT    NUMBER	      := 1;
    x_return_status             VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(256);

    l_payment_received                    NUMBER := 0;

-- Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
    Cursor Principal_Paid_Cur (p_chr_id     IN NUMBER, p_date   IN  DATE) IS
    SELECT   NVL(SUM(AR_REC.AMOUNT_APPLIED),0) AMOUNT
    FROM     AR_RECEIVABLE_APPLICATIONS_ALL AR_REC,
         AR_PAYMENT_SCHEDULES_ALL AR_PAY,
         okl_bpd_tld_ar_lines_v TLD,
         OKL_STRM_TYPE_B STRM
    WHERE    AR_REC.APPLY_DATE              <= p_date -- TO BE REPLACED WITH APPLY DATE
    AND      TLD.KHR_ID                   = p_chr_id --298074492502791815515340871034511143040
    AND      TLD.STY_ID                   = STRM.ID
    AND      STRM.STREAM_TYPE_PURPOSE       = 'PRINCIPAL_PAYMENT'
    AND      TLD.CUSTOMER_TRX_ID = AR_PAY.CUSTOMER_TRX_ID
    AND      AR_PAY.PAYMENT_SCHEDULE_ID     = AR_REC.APPLIED_PAYMENT_SCHEDULE_ID
    AND      AR_PAY.CLASS                   = 'INV'
    AND      AR_REC.STATUS                  = 'APP';
-- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007


    Principal_Paid_Rec Principal_Paid_Cur%ROWTYPE;
  BEGIN

       IF ( p_chr_id = NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       OPEN Principal_Paid_Cur(p_chr_id,p_date);
       FETCH Principal_Paid_Cur INTO Principal_Paid_Rec.AMOUNT;
       CLOSE Principal_Paid_Cur;

       l_payment_received := Principal_Paid_Rec.AMOUNT;

       RETURN l_payment_received;


  EXCEPTION

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    RETURN NULL;


  END payment_received;
----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Sanjeev Ahuja
    -- Function Name  funding_req
    -- Description:   returns funding requested for a loan contract
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Comments

----------------------------------------------------------------------------------------------------
  FUNCTION funding_req(
            p_chr_id          IN    NUMBER,
            p_date            IN    DATE) RETURN NUMBER  IS

    l_api_name		CONSTANT    VARCHAR2(30) := 'RETURN_CONTRACT_RESIDUAL_VALUE';
    l_api_version	CONSTANT    NUMBER	      := 1;
    x_return_status             VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(256);

    l_funding_req                    NUMBER := 0;

    -- sjalasut, modified the cursor to change khr_id references from hdr to line
    -- also introduced okl_cnsld_ap_invs_all table to have consolidated ap
    -- invoice id joined to the ap_invoices table. fts on ap_payment_schedules_all
    Cursor Amount_Funded_Cur (p_chr_id     IN NUMBER, p_date   IN DATE) IS
    select nvl(sum(ap_inv.payment_amount_total), 0) AMOUNT
    from ap_invoices_all ap_inv,
         okl_trx_ap_invoices_b okl_inv,
         ap_payment_schedules_all pay_sche
         ,okl_cnsld_ap_invs_all cnsld
         ,okl_txl_ap_inv_lns_all_b okl_inv_ln
         ,fnd_application fnd_app
    where okl_inv.id = okl_inv_ln.tap_id
      and okl_inv_ln.khr_id = p_chr_id
      and ap_inv.application_id = fnd_app.application_id
      and fnd_app.application_short_name = 'OKL'
      and okl_inv_ln.cnsld_ap_inv_id = cnsld.cnsld_ap_inv_id
      and cnsld.cnsld_ap_inv_id = to_number(ap_inv.reference_key1)
      and okl_inv.funding_type_code = 'BORROWER_PAYMENT'
      and ap_inv.invoice_id = pay_sche.invoice_id
      and pay_sche.creation_date > p_date
      and ap_inv.payment_status_flag in ('Y','P');


     Amount_Funded_Rec Amount_Funded_Cur%ROWTYPE;
  BEGIN

       IF ( p_chr_id = NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       OPEN Amount_Funded_Cur(p_chr_id,p_date);
       FETCH Amount_Funded_Cur INTO Amount_Funded_Rec.AMOUNT;
       CLOSE Amount_Funded_Cur;

       l_funding_req := Amount_Funded_Rec.AMOUNT;

       RETURN l_funding_req;


  EXCEPTION

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;


  END funding_req;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Sanjeev Ahuja
    -- Function Name  prin_bal_OP_lease
    -- Description:   returns Principal Balance for a Operating Lease contract
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Comments

----------------------------------------------------------------------------------------------------
  FUNCTION prin_bal_OP_lease(
            p_chr_id          IN  NUMBER,
            p_kle_id          IN NUMBER) RETURN NUMBER  IS

/*    l_api_name		CONSTANT    VARCHAR2(30) := 'CONTRACT_RESIDUAL_VALUE';
    l_api_version	CONSTANT    NUMBER	      := 1;
    x_return_status             VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(256);
*/
    l_net_book_value            NUMBER := 0;

    Cursor lease_asset_cost_csr (p_chr_id     IN NUMBER, p_kle_id IN NUMBER) IS
    Select  FA_BOOKS.ASSET_ID ASSET_ID,
        FA_BOOKS.cost ASSET_COST,
        FA_BOOKS.book_type_code BOOK_TYPE_CODE
    from    FA_BOOKS ,
        FA_BOOK_CONTROLS,
        OKC_K_LINES_B LINES,
        OKC_LINE_STYLES_B STYLE,
        OKC_K_ITEMS KITEM
    where   FA_BOOKS.asset_id           = KITEM.OBJECT1_ID1
    and     LINES.DNZ_CHR_ID            = p_chr_id --291511068054787299132375269533568315520
    and     LINES.cle_id                = p_kle_id
    and     LINES.ID                    = KITEM.CLE_ID
    and     LINES.LSE_ID                = STYLE.ID
    and     STYLE.LTY_CODE              = 'FIXED_ASSET'
    and     FA_BOOKS.book_type_code     = FA_BOOK_CONTROLS.book_type_code
    and     FA_BOOK_CONTROLS.book_class = 'CORPORATE'
    and     FA_BOOKS.transaction_header_id_out is null;

    Cursor Deprn_csr (p_asset_id     IN NUMBER,
                  p_book_type_code IN VARCHAR2) IS
    select  sum(deprn_amount) ACCUMULATED_DEPRECIATION
    from    fa_deprn_summary
    where   Asset_id                    = p_asset_id
    and     book_type_code              = p_book_type_code;

    Deprn_rec Deprn_csr%ROWTYPE;

  BEGIN

       IF ( p_chr_id = NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       print_debug('Asset id :' || p_kle_id);
       FOR l_lease_asset_cost_csr IN lease_asset_cost_csr(p_chr_id, p_kle_id)
       LOOP

         OPEN Deprn_csr(l_lease_asset_cost_csr.ASSET_ID,l_lease_asset_cost_csr.BOOK_TYPE_CODE);
         FETCH Deprn_csr INTO Deprn_rec.ACCUMULATED_DEPRECIATION;
         CLOSE Deprn_csr;

         print_debug('Asset cost :' || l_lease_asset_cost_csr.ASSET_COST);
         print_debug('Accumulated depreciation :' || Deprn_rec.ACCUMULATED_DEPRECIATION);

         l_net_book_value := l_net_book_value + (l_lease_asset_cost_csr.ASSET_COST -
                                                Deprn_rec.ACCUMULATED_DEPRECIATION);

         print_debug('Net book value :' || l_net_book_value);
       END LOOP;


       RETURN l_net_book_value;


  EXCEPTION

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;


  END prin_bal_OP_lease;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_tot_principal_amt
-- Description     : get principal balance amount
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  FUNCTION get_tot_principal_amt(
  p_khr_id              IN  NUMBER,
  p_kle_id              IN  NUMBER,
  p_date                IN  DATE,
  p_advance_or_arrears  IN  VARCHAR2) RETURN NUMBER IS

    l_principal_balance NUMBER := 0;


    l_api_version              NUMBER := 1;
    l_init_msg_list            VARCHAR2(100) := OKC_API.G_FALSE;
    x_return_status            VARCHAR2(100);
    x_msg_count                NUMBER;
    x_msg_data                 VARCHAR2(1999);
    x_value                    NUMBER := 0;
    l_formula_name             VARCHAR2(100);
    lx_rulv_rec		          Okl_Rule_Apis_Pvt.rulv_rec_type;
    p_bal_date                 DATE;



    CURSOR c_khr_type (p_khr_id  NUMBER) IS
    SELECT khr.deal_type deal_type
    FROM    okc_k_headers_b CHR,
        okl_k_headers khr
    WHERE   khr.id = CHR.id
    AND     khr.id = p_khr_id;

    c_khr_type_rec  c_khr_type%ROWTYPE;

/*    CURSOR c_principal_bal_cur(p_contract_id NUMBER, p_bal_date DATE) IS
    SELECT sum(sel.amount) amount
    FROM   okl_strm_elements sel,okl_streams stm, okl_strm_type_b sty
    WHERE  stm.khr_id          = p_contract_id
    AND    stm.active_yn           = 'Y'
    AND    stm.say_code            = 'CURR'
    AND    sty.id                  = stm.sty_id
    AND   sty.stream_type_purpose  = 'PRINCIPAL_BALANCE'
    AND    sel.stm_id          = stm.id
    and   trunc(sel.stream_element_date) = ( select trunc(max(sel.stream_element_date))
                                 FROM   okl_strm_elements sel,okl_streams stm,
                                        okl_strm_type_b sty
                                 WHERE  stm.khr_id          = p_contract_id
                                 AND    stm.active_yn       = 'Y'
                                 AND    stm.say_code        = 'CURR'
                                 AND    sty.id              = stm.sty_id
                                 AND    sty.stream_type_purpose = 'PRINCIPAL_BALANCE'
                                 AND    sel.stm_id          = stm.id
                                 and   trunc(sel.stream_element_date) <= p_bal_date);

    CURSOR c_stream_date_arr(p_contract_id NUMBER, p_bal_date DATE) IS
    select trunc(min(sel.stream_element_date))
    FROM   okl_strm_elements sel,okl_streams stm,
           okl_strm_type_b sty
    WHERE  stm.khr_id          = p_contract_id
    AND    stm.active_yn       = 'Y'
    AND    stm.say_code        = 'CURR'
    AND    sty.id              = stm.sty_id
    AND    sty.stream_type_purpose = 'PRINCIPAL_BALANCE'
    AND    sel.stm_id          = stm.id
    and    sel.stream_element_date >= p_bal_date;
*/
  BEGIN
       IF ( p_khr_id IS NULL OR p_kle_id IS NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       OPEN c_khr_type(p_khr_id);
       FETCH c_khr_type INTO c_khr_type_rec.deal_type;
       CLOSE c_khr_type;


       /*Okl_Bp_Rules.extract_rules(
           	    p_api_version      => l_api_version,
       	        p_init_msg_list    => l_init_msg_list,
    	   	 	p_khr_id           => p_khr_id,
    			p_kle_id           => null,
    			p_rgd_code         => 'LAIIND',
    			p_rdf_code         => 'LAICLC',
    			x_return_status    => x_return_status,
    			x_msg_count        => x_msg_count,
    			x_msg_data         => x_msg_data,
    			x_rulv_rec         => lx_rulv_rec);

       debug_message('Variable Interest Type: '||lx_rulv_rec.rule_information5);
       debug_message('Reamort Date: '||p_date);*/

--       if(G_INTEREST_CALCULATION_BASIS = 'REAMORT') THEN

         print_debug('get_tot_principal_amt : p_advance_or_arrears => ' || p_advance_or_arrears);
         if(c_khr_type_rec.deal_type = 'LEASEDF' or c_khr_type_rec.deal_type = 'LEASEST') THEN
           l_principal_balance :=  contract_future_rents(p_khr_id, p_kle_id, p_date, p_advance_or_arrears) +
                                contract_residual_value(p_khr_id, p_kle_id) -
                                contract_future_income(p_khr_id, p_kle_id, p_date);


         elsif(c_khr_type_rec.deal_type = 'LEASEOP') THEN
           l_principal_balance :=  prin_bal_OP_lease(p_khr_id, p_kle_id);


/*         elsif(c_khr_type_rec.deal_type = 'LOAN') THEN

           OPEN c_stream_date_arr(p_khr_id, p_date);
           FETCH c_stream_date_arr INTO p_bal_date;
           CLOSE c_stream_date_arr;

           OPEN c_principal_bal_cur(p_khr_id, p_bal_date);
           FETCH c_principal_bal_cur INTO l_principal_balance;
           CLOSE c_principal_bal_cur;
           debug_message('Principal Balance Loan: '||l_principal_balance);
*/         end if;

/*       else
         if(c_khr_type_rec.deal_type = 'LOAN') THEN
           l_principal_balance :=  asset_cost_loan(p_khr_id) -
                                payment_received(p_khr_id,p_date);

         elsif(c_khr_type_rec.deal_type = 'LOAN-REVOLVING') THEN
           l_principal_balance :=  funding_req(p_khr_id,p_date) -
                                payment_received(p_khr_id,p_date);
         end if;
       end if;*/

       RETURN l_principal_balance;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
    RETURN NULL;

  END get_tot_principal_amt;
  ------------------------------------------------------------------
  -- Function GET_TRX_TYPE to extract transaction type
  ------------------------------------------------------------------

  FUNCTION get_trx_type
	(p_name		VARCHAR2,
	p_language	VARCHAR2)
	RETURN		NUMBER IS

	CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
		SELECT	id
		FROM	okl_trx_types_tl
		WHERE	name	= cp_name
		AND	LANGUAGE	= cp_language;

	l_trx_type	okl_trx_types_v.id%TYPE;

  BEGIN

    l_trx_type := NULL;

	  OPEN	c_trx_type (p_name, p_language);
	  FETCH	c_trx_type INTO l_trx_type;
	  CLOSE	c_trx_type;

	  RETURN	l_trx_type;

  END get_trx_type;

  PROCEDURE print_loan_tables(p_rent_tbl      IN csm_periodic_expenses_tbl_type,
                              p_csm_loan_level_tbl IN csm_loan_level_tbl_type) IS
    l_api_name	        CONSTANT VARCHAR2(30) := 'print_loan_tables';
    i NUMBER;
    l_source Number;
    l_rent_tbl csm_periodic_expenses_tbl_type;
    l_csm_loan_level_tbl csm_loan_level_tbl_type;
  BEGIN
    l_rent_tbl := p_rent_tbl;
    l_csm_loan_level_tbl := p_csm_loan_level_tbl;

    print_debug('*****************************************');
    print_debug('*******START CONTENTS OF P_RENT_TBL******');
    i := l_rent_tbl.first;
    loop
      exit when i is null;
      print_debug('l_rent_tbl element # '|| i);
      print_debug('----------------------------------------------------');
      print_debug('sequence number of the payment level: '|| set_value_null(l_rent_tbl(i).level_index_number));
      print_debug('number of payments for a payment level: '|| set_value_null(l_rent_tbl(i).number_of_periods));
      print_debug('foreign key to table OKL_SIF_RETS: '||set_value_null(l_rent_tbl(i).sir_id));
      print_debug('reference to the asset index number: '||set_value_null(l_rent_tbl(i).index_number));
      print_debug('payment type: '||set_value_null(l_rent_tbl(i).level_type));
      print_debug('amount: '||set_value_null(l_rent_tbl(i).amount));
      print_debug('advance_or_arrears: '||set_value_null(l_rent_tbl(i).advance_or_arrears));
      print_debug('frequency: '||set_value_null(l_rent_tbl(i).period));
      print_debug('lock_level_step: '||set_value_null(l_rent_tbl(i).lock_level_step));
      print_debug('days in a payment period: '||set_value_null(l_rent_tbl(i).days_in_period));
      print_debug('first payment date for a payment level: '||set_value_null(l_rent_tbl(i).first_payment_date));
      print_debug('rate: '||set_value_null(l_rent_tbl(i).rate));
      i := l_rent_tbl.next(i);
    end loop;
    print_debug('*******END CONTENTS OF P_RENT_TBL********');
    print_debug('*****************************************');


    print_debug('*****************************************');
    print_debug('**START CONTENTS OF P_CSM_LOAN_LEVEL_TBL*');
    i := l_csm_loan_level_tbl.first;
    loop
      exit when i is null;
      print_debug('l_csm_loan_level_tbl element # '|| i);
      print_debug('----------------------------------------------------');
      print_debug('description: '||set_value_null(l_csm_loan_level_tbl(i).description));
      print_debug('first payment date for a payment level: '||set_value_null(l_csm_loan_level_tbl(i).date_start));
      print_debug('asset line id: '||set_value_null(l_csm_loan_level_tbl(i).kle_loan_id));
      print_debug('sequence number of the payment level: '||set_value_null(l_csm_loan_level_tbl(i).level_index_number));
      print_debug('payment type: '||set_value_null(l_csm_loan_level_tbl(i).level_type));

      --IF (l_csm_loan_level_tbl(i).level_type <> 'FUNDING') THEN
      print_debug('number of payments for a payment level: '||set_value_null(l_csm_loan_level_tbl(i).number_of_periods));
      print_debug('lock_level_step: '||set_value_null(l_csm_loan_level_tbl(i).lock_level_step));
      print_debug('frequency: '||set_value_null(l_csm_loan_level_tbl(i).period));
      print_debug('advance_or_arrears: '||set_value_null(l_csm_loan_level_tbl(i).advance_or_arrears));
      print_debug('income_or_expense: '||set_value_null(l_csm_loan_level_tbl(i).income_or_expense));
      print_debug('query_level_yn: '||set_value_null(l_csm_loan_level_tbl(i).query_level_yn));
      print_debug('payment_type: '||set_value_null(l_csm_loan_level_tbl(i).payment_type));
      --END IF;
      print_debug('amount: '||set_value_null(l_csm_loan_level_tbl(i).amount));
      print_debug('rate: '||set_value_null(l_csm_loan_level_tbl(i).rate));
      i := l_csm_loan_level_tbl.next(i);
    end loop;
    print_debug('**END CONTENTS OF P_CSM_LOAN_LEVEL_TBL***');
    print_debug('*****************************************');
  Exception
   	WHEN OTHERS THEN
      print_debug('error in procedure print_loan_tables');
      print_debug('sqlcode : ' || sqlcode || ' $ sqlerrm : ' || sqlerrm);
  END print_loan_tables;

  PROCEDURE print_lease_tables(p_rents_tbl_in IN Okl_Create_Streams_Pub.csm_periodic_expenses_tbl_type,
                               p_csm_line_details_tbl IN okl_create_streams_pvt.csm_line_details_tbl_type) IS
    l_api_name	        CONSTANT VARCHAR2(30) := 'print_lease_tables';
    i NUMBER;
    l_source Number;
    l_rents_tbl_in Okl_Create_Streams_Pub.csm_periodic_expenses_tbl_type;
    l_csm_line_details_tbl okl_create_streams_pvt.csm_line_details_tbl_type;
  BEGIN
    l_rents_tbl_in := p_rents_tbl_in;
    l_csm_line_details_tbl := p_csm_line_details_tbl;
    print_debug('******************************************');
    print_debug('*****START CONTENTS OF P_RENTS_TBL_IN*****');
    i := l_rents_tbl_in.first;
    loop
      exit when i is null;
      print_debug('l_rents_tbl_in element # '|| i);
      print_debug('----------------------------------------------------');
      print_debug('description: '||set_value_null(l_rents_tbl_in(i).description));
      print_debug('first payment date for a payment level: '||set_value_null(l_rents_tbl_in(i).date_start));
      print_debug('kle_asset_id: '||set_value_null(l_rents_tbl_in(i).kle_asset_id));
      print_debug('sequence number of the payment level: '||set_value_null(l_rents_tbl_in(i).level_index_number));
      print_debug('payment type: '||set_value_null(l_rents_tbl_in(i).level_type));
      print_debug('number of payments for a payment level: '||set_value_null(l_rents_tbl_in(i).number_of_periods));
      print_debug('amount: '||set_value_null(l_rents_tbl_in(i).amount));
      print_debug('rate: '||set_value_null(l_rents_tbl_in(i).rate));
      print_debug('lock_level_step: '||set_value_null(l_rents_tbl_in(i).lock_level_step));
      print_debug('frequency: '||set_value_null(l_rents_tbl_in(i).period));
      print_debug('advance_or_arrears: '||set_value_null(l_rents_tbl_in(i).advance_or_arrears));
      print_debug('income_or_expense: '||set_value_null(l_rents_tbl_in(i).income_or_expense));
      i := l_rents_tbl_in.next(i);
    end loop;
    print_debug('******END CONTENTS OF P_RENTS_TBL_IN******');
    print_debug('******************************************');

    print_debug('*START CONTENTS OF P_CSM_LINE_DETAILS_TBL*');
    print_debug('******************************************');
    i := l_csm_line_details_tbl.first;
    loop
      exit when i is null;
      print_debug('kle_asset_id: '||set_value_null(l_csm_line_details_tbl(i).kle_asset_id));
      print_debug('----------------------------------------------------');
      print_debug('asset_cost: '||set_value_null(l_csm_line_details_tbl(i).asset_cost));
      print_debug('residual_amount: '||set_value_null(l_csm_line_details_tbl(i).residual_amount));
      print_debug('residual_date: '||set_value_null(l_csm_line_details_tbl(i).residual_date));
      print_debug('description: '||set_value_null(l_csm_line_details_tbl(i).description));
      i := l_csm_line_details_tbl.next(i);
    end loop;
    print_debug('**END CONTENTS OF P_CSM_LINE_DETAILS_TBL***');
    print_debug('*******************************************');
  Exception
   	WHEN OTHERS THEN
      print_debug('error in procedure print_lease_tables');
      print_debug('sqlcode : ' || sqlcode || ' $ sqlerrm : ' || sqlerrm);
  END print_lease_tables;

  PROCEDURE print_var_int_tables(p_rbk_tbl IN rbk_tbl,
                                 p_strm_lalevl_tbl IN strm_lalevl_tbl) IS

    l_api_name	        CONSTANT VARCHAR2(30) := 'print_var_int_tables';
    i NUMBER;
    d NUMBER;
    l_rbk_tbl rbk_tbl;
    l_strm_lalevl_tbl strm_lalevl_tbl;
  BEGIN
    l_rbk_tbl := p_rbk_tbl;
    l_strm_lalevl_tbl := p_strm_lalevl_tbl;

    print_debug('*******START CONTENTS OF P_RBK_TBL********');
    print_debug('******************************************');
    FOR i IN 1..l_rbk_tbl.COUNT
    LOOP
      print_debug('Rec#: '||i);
      print_debug('KHR ID: '||l_rbk_tbl(i).khr_id);
      print_debug('KLE ID: '||l_rbk_tbl(i).kle_id);
    END LOOP;
    print_debug('*********END CONTENTS OF P_RBK_TBL*********');
    print_debug('*******************************************');

    print_debug('***START CONTENTS OF P_STRM_LALEVL_TBL****');
    print_debug('******************************************');
    for d in 1..l_strm_lalevl_tbl.COUNT
    loop
      print_debug('Rec#: '||d);
      print_debug('-->Chr_Id :'||set_value_null(l_strm_lalevl_tbl(d).chr_id));
      print_debug('-->Cle_Id :'||set_value_null(l_strm_lalevl_tbl(d).cle_id));
      print_debug('-->Rule_Information_Category:'||set_value_null(l_strm_lalevl_tbl(d).rule_information_category));

      IF (l_strm_lalevl_tbl(d).rule_information_category = 'LASLH') THEN
        print_debug('-->Jtot_Object1_Code - stream_type_source :'||set_value_null(l_strm_lalevl_tbl(d).jtot_object1_code));
        print_debug('-->Jtot_Object2_Code - time_value :'||set_value_null(l_strm_lalevl_tbl(d).jtot_object2_code));
        print_debug('-->Object1_Id1 - sty_id :'||set_value_null(l_strm_lalevl_tbl(d).object1_id1));
        print_debug('-->Rule_Information1 - billing_schedule_type :'||set_value_null(l_strm_lalevl_tbl(d).Rule_Information1));
        print_debug('-->Rule_Information2 - rate_type :'||set_value_null(l_strm_lalevl_tbl(d).rule_information2));
      ELSE
        print_debug('-->Jtot_Object1_Code - time_unit_of_measure :'||set_value_null(l_strm_lalevl_tbl(d).jtot_object1_code));
        print_debug('-->Jtot_Object2_Code - stream_level_header :'||set_value_null(l_strm_lalevl_tbl(d).jtot_object2_code));
        print_debug('-->Object1_Id1 - Pay_freq :'||set_value_null(l_strm_lalevl_tbl(d).object1_id1));
        print_debug('-->Rule_Information1 - seq :'||set_value_null(l_strm_lalevl_tbl(d).Rule_Information1));
        print_debug('-->Rule_Information2 - start_date :'||set_value_null(l_strm_lalevl_tbl(d).rule_information2));
     END IF;

      print_debug('-->Rule_Information3 - number_periods :'||set_value_null(l_strm_lalevl_tbl(d).rule_information3));
      print_debug('-->Rule_Information4 - tuoms_per_period:'||set_value_null(l_strm_lalevl_tbl(d).rule_information4));
      print_debug('-->Rule_Information5 - structure:'||set_value_null(l_strm_lalevl_tbl(d).rule_information5));
      print_debug('-->Rule_Information6 - amount:'||set_value_null(l_strm_lalevl_tbl(d).rule_information6));
      print_debug('-->Rule_Information7 - stub_days:'||set_value_null(l_strm_lalevl_tbl(d).rule_information7));
      print_debug('-->Rule_Information8 - stub_amount:'||set_value_null(l_strm_lalevl_tbl(d).rule_information8));
      print_debug('-->Rule_Information10 - advance_or_arrears:'||set_value_null(l_strm_lalevl_tbl(d).rule_information10));
      print_debug('-->Rule_Information13 - rate:'||set_value_null(l_strm_lalevl_tbl(d).rule_information13));

      print_debug('-->Object1_Id2 :'||set_value_null(l_strm_lalevl_tbl(d).object1_id2));
      print_debug('-->Object2_Id1 :'||set_value_null(l_strm_lalevl_tbl(d).object2_id1));
      print_debug('-->Object2_Id2 :'||set_value_null(l_strm_lalevl_tbl(d).object2_id2));
    end loop;
    print_debug('***END CONTENTS OF P_STRM_LALEVL_TBL****');
    print_debug('******************************************');

  Exception
   	WHEN OTHERS THEN
      print_debug('error in procedure print_var_int_tables');
      print_debug('sqlcode : ' || sqlcode || ' $ sqlerrm : ' || sqlerrm);
  END print_var_int_tables;

/*
  PROCEDURE interest_cal(
            p_api_version   IN   NUMBER,
            p_init_msg_list IN   VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_count     OUT NOCOPY NUMBER,
            x_msg_data      OUT NOCOPY VARCHAR2,
            p_interest_rec  IN   interest_rec,
            x_interest_rec  OUT NOCOPY interest_rec) IS

    ------------------------------------------------------------
    -- Declare Process variables
    ------------------------------------------------------------

    l_adder             NUMBER(5,2);
    l_adjustment_frequency  NUMBER;
    l_days_in_month     VARCHAR2(20);
    l_interest_start_date  DATE;
    l_method_of_calculation VARCHAR2(100);
    l_period_rate       NUMBER(5,2):= 0;
    l_days_tot          NUMBER:= 0;
    l_days_rate_tot     NUMBER:= 0;
    lx_rulv_rec		    Okl_Rule_Apis_Pvt.rulv_rec_type;
    l_index_name        VARCHAR2(100);
    l_last_int_rate     NUMBER:=0;
    l_date              DATE;
    l_first_time_calc   BOOLEAN:=FALSE;
    l_present_int_rate  NUMBER:=0;
    l_calc_days         NUMBER := 0;
    l_year_part         VARCHAR2(4);
    l_year_days         VARCHAR2(20) := '0';
    l_contract_start_date DATE;
    l_contract_end_date DATE;
    l_interest_amount  NUMBER;
    l_deal_type        okl_k_headers.deal_type%TYPE;
    l_last_interim_int_cal_date DATE;
    l_due_date         DATE;
    l_currency_code    okc_k_headers_b.currency_code%TYPE;

    l_interest_rec  interest_rec;
    lx_interest_rec interest_rec;
    ------------------------------------------------------------
    -- Declare variable Interest Cursor
    ------------------------------------------------------------

    CURSOR c_days_rate (p_start_date DATE, p_end_date DATE) IS
    select ive.value VALUE,
    (LEAST(trunc(p_end_date),NVL(datetime_invalid, sysdate))
    - GREATEST(trunc(p_start_date),datetime_valid)) DAYS
    ,idx.name index_name,
    GREATEST(trunc(p_start_date),datetime_valid) VALID_FROM,
    LEAST(trunc(p_end_date),NVL(datetime_invalid, sysdate)) VALID_UNTIL
    from okl_indices idx,
    okl_index_values ive
    where idx.id = ive.idx_id
    AND   ive.idx_id = l_interest_rec.index_name
    AND   (p_start_date between datetime_valid and nvl(datetime_invalid, SYSDATE)
    OR    (p_end_date between datetime_valid and nvl(datetime_invalid, SYSDATE))
    OR    (datetime_valid >= p_start_date AND nvl(datetime_invalid,SYSDATE) <= p_end_date) )
    order by VALID_FROM;


    CURSOR  c_implicit_rate (p_index_name VARCHAR2, p_end_date DATE) IS
    SELECT  val.value, ind.name index_name
    FROM    okl_index_values val
           ,okl_indices ind
    WHERE   val.idx_id = p_index_name
    AND     ind.id = val.idx_id
    AND     val.datetime_valid = (SELECT MAX(val.datetime_valid)
    FROM    OKL_INDEX_VALUES val ,
            OKL_INDICES ind
    WHERE   ind.id              =   val.idx_id
    AND     val.idx_id          =   p_index_name
    AND     val.datetime_valid <   p_end_date);

    CURSOR c_calc_start_date (c_contract_id NUMBER)IS
    select min(sel.stream_element_date)
    FROM    okl_strm_elements sel,okl_streams stm, okl_strm_type_b sty,
        okl_k_headers khr, okc_k_headers_b chr
    WHERE	stm.khr_id          =  c_contract_id
    AND	stm.active_yn		= 'Y'
    AND	stm.say_code		= 'CURR'
    AND	sty.id				= stm.sty_id
    AND (sty.stream_type_purpose = 'RENT' OR sty.stream_type_purpose = 'PRINCIPAL_PAYMENT')
    AND	sel.stm_id          = stm.id
    and khr.id              = stm.khr_id
    and chr.id              = khr.id
    and sel.stream_element_date > nvl(khr.date_last_interim_interest_cal,chr.start_date);

    CURSOR c_contract_start_date (c_contract_id NUMBER)IS
    SELECT  chr.start_date
        ,khr.deal_type
        ,khr.date_last_interim_interest_cal
        ,chr.end_date
        ,chr.currency_code
    FROM   okc_k_headers_b chr
        ,okl_k_headers khr
    WHERE	chr.id = c_contract_id
    AND     khr.id = chr.id;

    CURSOR c_last_int_rate(c_contract_id NUMBER)IS
    select max(tai.date_invoiced) last_date_invoiced, ipm.param_value int_rate
    from okl_trx_ar_invoices_v tai, okl_trx_params_b ipm
    where tai.khr_id = c_contract_id
    and tai.description = 'Variable Interest Stream Billing'
    and ipm.source_id = tai.id
    and param_value <> 0
    group by ipm.param_value;

	BEGIN

  	-----------------------------------------------------------------
  	-- Initialize out parameters with in values
   	-----------------------------------------------------------------

    l_interest_rec := p_interest_rec;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Calculating Interest');
    print_debug('In Interest Calculating Procedure');
   	-----------------------------------------------------------------
  	-- Derive Variable Interest Basis from Rules
   	-----------------------------------------------------------------

    Okl_Bp_Rules.extract_rules(
     	    p_api_version      => p_api_version,
 	        p_init_msg_list    => p_init_msg_list,
   	   	 	p_khr_id           => l_interest_rec.khr_id,
    			p_kle_id           => null,
    			p_rgd_code         => 'LAIIND',
    			p_rdf_code         => 'LAIVAR',
    			x_return_status    => x_return_status,
    			x_msg_count        => x_msg_count,
    			x_msg_data         => x_msg_data,
    			x_rulv_rec         => lx_rulv_rec);


		IF 	(x_return_status = 'S' ) THEN
 				print_debug ('        -- Rules Found.');
  	ELSE
 				print_debug ('        -- Rules Error.');
		END IF;

    l_interest_rec.variable_method  := lx_rulv_rec.rule_information1;
    l_interest_rec.index_name       := lx_rulv_rec.rule_information2;
    l_interest_rec.base_rate        := lx_rulv_rec.rule_information3;
    l_adder                         := lx_rulv_rec.rule_information4;
    l_interest_rec.minimum_rate     := lx_rulv_rec.rule_information6;
    l_interest_rec.maximum_rate     := lx_rulv_rec.rule_information5;
    l_interest_rec.tolerance        := lx_rulv_rec.rule_information7;
    --l_adjustment_frequency          := lx_rulv_rec.rule_information8;

    Okl_Bp_Rules.extract_rules(
     	    p_api_version      => p_api_version,
 	        p_init_msg_list    => p_init_msg_list,
   	   	 	p_khr_id           => l_interest_rec.khr_id,
    			p_kle_id           => null,
    			p_rgd_code         => 'LAIIND',
    			p_rdf_code         => 'LAICLC',
    			x_return_status    => x_return_status,
    			x_msg_count        => x_msg_count,
    			x_msg_data         => x_msg_data,
    			x_rulv_rec         => lx_rulv_rec);

		IF 	(x_return_status = 'S' ) THEN
 				print_debug ('        -- Rules Found1.');
		ELSE
 				print_debug ('        -- Rules Error.');
		END IF;

		print_debug ('        -- After Rules.'||lx_rulv_rec.rule_information1);

    l_interest_rec.days_in_year         := lx_rulv_rec.rule_information1;
		print_debug ('        -- After Rules.');
    l_days_in_month                     := lx_rulv_rec.rule_information2;
    l_interest_rec.interest_method      := lx_rulv_rec.rule_information3;
    l_method_of_calculation             := lx_rulv_rec.rule_information5;

    print_debug('In Type: '||l_interest_rec.variable_method);
    --FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'In Type '||l_interest_rec.variable_method);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Method of Calculation: '||l_interest_rec.variable_method);

    open c_last_int_rate(l_interest_rec.khr_id);
    fetch c_last_int_rate into l_date,l_last_int_rate;
    l_first_time_calc := FALSE;
    close c_last_int_rate;

    if(l_last_int_rate = 0) THEN
      l_last_int_rate := l_interest_rec.base_rate;
      l_first_time_calc := TRUE;
    END IF;

    print_debug (' Last Int Rate: '||l_last_int_rate);
  	------------------------------------------------------------
    -- Derive Interest Start Date
  	------------------------------------------------------------
    open c_contract_start_date(l_interest_rec.khr_id);
  	fetch c_contract_start_date into
         l_contract_start_date,l_deal_type, l_last_interim_int_cal_date, l_contract_end_date, l_currency_code;
  	close c_contract_start_date;

    If ((l_deal_type = 'LOAN' or l_deal_type ='LOAN-REVOLVING') AND
         (l_interest_rec.variable_method = 'FLOAT')) THEN

      OKL_STREAM_GENERATOR_PVT.get_next_billing_date(
                p_api_version            => p_api_version,
       	        p_init_msg_list          => p_init_msg_list,
        	   	 	p_khr_id                 => l_interest_rec.khr_id,
                p_billing_date           => l_last_interim_int_cal_date,
                x_next_due_date          => l_due_date,
                x_next_period_start_date => l_interest_rec.start_date,
                x_next_period_end_date   => l_due_date,
          			x_return_status          => x_return_status,
          			x_msg_count              => x_msg_count,
          			x_msg_data               => x_msg_data);

      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Stream Element Date: '|| l_due_date);

      print_debug('Stream Element Date: '||l_due_date);

    else
      print_debug('Contract Id: ' || l_interest_rec.khr_id);
      print_debug('Interest Start Date before: '||l_interest_rec.start_date);
    	open c_calc_start_date(l_interest_rec.khr_id);
    	fetch c_calc_start_date into l_interest_rec.start_date;
    	close c_calc_start_date;
      print_debug('Interest Start Date after: '||l_interest_rec.start_date);

      if(l_interest_rec.start_date is null) THEN
        l_interest_rec.start_date := l_contract_start_date;
      end if;

    end if;

    print_debug('Interest Start Date: '||l_interest_rec.start_date||
                    ' Contract Start Date: '||l_contract_start_date ||
                    ' Contract End Date: '||l_contract_end_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Interest Start Date: '||l_interest_rec.start_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Contract Start Date: '||l_contract_start_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Contract End Date: '||l_contract_end_date);

    x_interest_rec.interest_amount := 0;
  	------------------------------------------------------------
  	-- Derive Effective Interest Rate
   	------------------------------------------------------------

    l_interest_rec.effective_rate := l_interest_rec.base_rate;

    print_debug('Method of Calculation: '||l_interest_rec.variable_method||
                    ' Base Rate: '||l_interest_rec.base_rate);

    --    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Method of Calculation: '||l_interest_rec.variable_method);
    IF l_interest_rec.variable_method = 'FIXEDADJUST' THEN

        --print_debug('Index Name: ' || to_char(l_interest_rec.index_name));
        OPEN c_implicit_rate(l_interest_rec.index_name,l_interest_rec.start_date);
        FETCH c_implicit_rate INTO l_interest_rec.effective_rate, l_index_name;
        CLOSE c_implicit_rate;

        l_interest_rec.effective_rate := l_interest_rec.effective_rate + l_adder;

        IF  l_interest_rec.effective_rate >= l_interest_rec.maximum_rate THEN
            l_interest_rec.effective_rate := l_interest_rec.maximum_rate;
        ELSIF  l_interest_rec.effective_rate <= l_interest_rec.minimum_rate THEN
            l_interest_rec.effective_rate := l_interest_rec.minimum_rate;
        END IF;

        x_interest_rec.effective_rate := l_interest_rec.effective_rate;

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Interest Rate: '||l_interest_rec.effective_rate);
        print_debug('Implicit Rate: '||l_interest_rec.effective_rate);

    ELSIF l_interest_rec.variable_method = 'FLOAT' THEN

      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Interest Start Date: '||l_interest_rec.start_date||
                    ' , Interest End Date: '||l_interest_rec.end_date);
      print_debug('Params for Interest Days Cursor: Start Date: '||l_interest_rec.start_date||
                    ' End Date: '||l_interest_rec.end_date);

      FOR r_days_rate IN c_days_rate (l_interest_rec.start_date, l_interest_rec.end_date )
      LOOP

        if(l_days_in_month = '30') THEN
          if(r_days_rate.VALID_FROM = l_contract_start_date or r_days_rate.VALID_FROM <> l_interest_rec.start_date) THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'1 VALID_FROM: '||r_days_rate.VALID_FROM ||
                          'VALID_UNTIL: ' || r_days_rate.VALID_UNTIL);
            print_debug('No. of Days in Month in Contract Start Date');
            null;
          else
            print_debug('No. of Days in Month NOT in Contract Start Date');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'2 VALID_FROM: '||r_days_rate.VALID_FROM ||
                          'VALID_UNTIL: ' || r_days_rate.VALID_UNTIL);
            --r_days_rate.VALID_FROM := r_days_rate.VALID_FROM +1;
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'3 VALID_FROM: '||r_days_rate.VALID_FROM ||
                          'VALID_UNTIL: ' || r_days_rate.VALID_UNTIL);
          end if;
          print_debug('Valid From: '||r_days_rate.VALID_FROM||' Valid To: '||r_days_rate.VALID_UNTIL);

          l_calc_days := OKL_STREAM_GENERATOR_PVT.get_day_count(r_days_rate.VALID_FROM,
                                                            r_days_rate.VALID_UNTIL,
                                                            'Y',
                                                            x_return_status);
          print_debug('No Of Days: '||l_calc_days);
        else

          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'5 VALID_FROM: '||r_days_rate.VALID_FROM ||
                          'VALID_UNTIL: ' || r_days_rate.VALID_UNTIL);
          l_calc_days := (r_days_rate.VALID_UNTIL - r_days_rate.VALID_FROM + 1);
        end if;

        print_debug('Values from Interest Days Cursor-Interest Rate: '||r_days_rate.VALUE||
                    ' Date From: '||r_days_rate.VALID_FROM||' Date Until: '||r_days_rate.VALID_UNTIL
                    ||' No. of Days in Between: '||r_days_rate.DAYS);

        print_debug('No. of Days in Month: '||l_days_in_month||
                    ' Interest Calc. Days: '||l_calc_days);

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'No. of Days in Month: '||l_days_in_month);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Interest Calc. Days: '||l_calc_days);

        l_year_days := l_interest_rec.days_in_year;

        if(l_year_days = 'ACTUAL') THEN
          l_year_part := to_char(l_interest_rec.start_date, 'YYYY');
          l_year_days := (to_date(('01-01-'||(l_year_part+1)),'DD-MM-YYYY') -
                           to_date(('01-01-'||l_year_part), 'DD-MM-YYYY'));
        else
          l_year_days := l_interest_rec.days_in_year;
        end if;

        l_interest_rec.principle := get_tot_principal_amt(l_interest_rec.khr_id, r_days_rate.VALID_FROM);

        IF((abs(l_last_int_rate - (r_days_rate.VALUE+l_adder)) >= l_interest_rec.tolerance)
          OR(l_first_time_calc))  THEN
          l_present_int_rate := r_days_rate.VALUE + l_adder;
        ELSE
          l_present_int_rate := l_last_int_rate;
        END IF;

        --        l_days_tot :=  l_days_tot + r_days_rate.DAYS;

        IF  l_present_int_rate >= l_interest_rec.maximum_rate THEN
          l_present_int_rate := l_interest_rec.maximum_rate;
        ELSIF  l_present_int_rate <= l_interest_rec.minimum_rate THEN
          l_present_int_rate := l_interest_rec.minimum_rate;
        END IF;

        x_interest_rec.effective_rate := l_present_int_rate;
        l_interest_rec.effective_rate := l_present_int_rate;

        print_debug('Effective Interest Rate: '||l_interest_rec.effective_rate||' Principal: '||l_interest_rec.Principle
                    ||' Month Days: '||l_calc_days||' Year Days: '||l_year_days);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Effective Interest Rate: '||l_interest_rec.effective_rate);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Principal: '||l_interest_rec.Principle);

        -- l_days_rate_tot := l_days_rate_tot + r_days_rate.DAYS*l_present_int_rate;

        l_interest_amount := OKL_ACCOUNTING_UTIL.round_amount((l_interest_rec.Principle * l_interest_rec.effective_rate/100)* (l_calc_days/l_year_days),l_currency_code);

        x_interest_rec.interest_amount := l_interest_amount+ x_interest_rec.interest_amount;

        print_debug('Interest Amount: '||l_interest_amount||' Total Interest Amount: '||x_interest_rec.interest_amount);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Interest Amount: '||l_interest_amount||' Total Interest Amount: '||x_interest_rec.interest_amount);

      END LOOP;

      --        l_interest_rec.effective_rate := l_days_rate_tot/l_days_tot;
      --        x_interest_rec.effective_rate := l_interest_rec.effective_rate;
    END IF;
  	------------------------------------------------------------
   	-- Derive Period Interest Amount
   	------------------------------------------------------------

    --    x_interest_rec.interest_amount := l_interest_rec.Principle * ((l_calc_days)/l_year_days) * l_interest_rec.effective_rate/100;

  EXCEPTION
        WHEN OTHERS THEN NULL;

  END interest_cal;

  PROCEDURE variable_interest_old(
        p_api_version   IN  NUMBER,
        p_init_msg_list IN  VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_contract_number IN VARCHAR2,
        P_to_date       IN  DATE)

    IS
    ------------------------------------------------------------
    -- Declare variables required by APIs
    ------------------------------------------------------------

    l_api_version	    CONSTANT NUMBER := 1;
    l_api_name	        CONSTANT VARCHAR2(30) := 'VARIABLE_INTEREST';
    l_return_status	    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_index_out     NUMBER;
    l_principle_balance NUMBER := 0;
    --l_interim_cal_yn    BOOLEAN;

  	l_reamort	        VARCHAR2(30);
    l_request_id        NUMBER;
    l_trans_status      VARCHAR2(30);
    lx_rulv_rec		    Okl_Rule_Apis_Pvt.rulv_rec_type;
    e_rulv_rec		    Okl_Rule_Apis_Pvt.rulv_rec_type;

  	------------------------------------------------------------
  	-- Initialise constants
  	------------------------------------------------------------

  	l_def_desc	CONSTANT VARCHAR2(80)	    := 'Variable Interest Stream Billing';
  	l_line_code	CONSTANT VARCHAR2(30)	    := 'LINE';
  	l_final_status	CONSTANT VARCHAR2(30)	:= 'SUBMITTED';
  	l_trx_type_name	CONSTANT VARCHAR2(30)	:= 'Billing';
  	l_trx_type_lang	CONSTANT VARCHAR2(30)	:= 'US';
  	l_date_entered	CONSTANT DATE		    := SYSDATE;
  	l_zero_amount	CONSTANT NUMBER		    := 0;
  	l_first_line	CONSTANT NUMBER		    := 1;
  	l_line_step	CONSTANT NUMBER		        := 1;
  	l_def_no_val	CONSTANT NUMBER		    := -1;
  	l_null_kle_id	CONSTANT NUMBER		    := -2;

  	------------------------------------------------------------
  	-- Declare local variables used in the program
  	------------------------------------------------------------

    l_sty_id                        okl_strm_type_v.id%TYPE;

  	l_khr_id	okl_trx_ar_invoices_v.khr_id%TYPE;
  	l_bill_date	okl_trx_ar_invoices_v.date_invoiced%TYPE;
  	l_trx_type	okl_trx_ar_invoices_v.try_id%TYPE;
  	l_kle_id	okl_txl_ar_inv_lns_v.kle_id%TYPE;

    l_curr_code     okc_k_headers_b.currency_code%TYPE;
    l_ste_amount    okl_strm_elements.amount%type;


  	l_line_number	okl_txl_ar_inv_lns_v.line_number%TYPE;
  	l_detail_number	okl_txd_ar_ln_dtls_v.line_detail_number%TYPE;

  	l_header_amount	okl_trx_ar_invoices_v.amount%TYPE;
  	l_line_amount	okl_txl_ar_inv_lns_v.amount%TYPE;

  	l_header_id	okl_trx_ar_invoices_v.id%TYPE;
  	l_line_id	okl_txl_ar_inv_lns_v.id%TYPE;

  	l_stm_date  	                    DATE;
  	l_reamort_date  	                DATE;
  	l_period_start_date  	            DATE;
  	l_period_end_date  	              DATE;
  	l_due_date  	                    DATE;
    l_last_interest_cal_date          DATE;
    l_end_of_process                  BOOLEAN := FALSE;
  	l_next_reamort_date  	            DATE;

-- Cursor to evaluate contracts eligible for calculating Variable Interest depending on
--    Principal Payment streams are between the last interest calculation date and the date
--    user wants to run upto

    CURSOR c_contracts_csr ( l_contract_number VARCHAR2, p_to_date DATE )IS
                              SELECT distinct khr.id khr_id,
                                     khr.deal_type,
                                     khr.date_last_interim_interest_cal,
                                     chr.contract_number,
                                     chr.start_date start_date
                              FROM   okc_k_headers_b chr,
			                               okl_k_headers   khr,
      			                         okc_statuses_b  khs,
						                  			 okc_rules_b		rules,
                  									 okc_rule_groups_b	rgp
                              WHERE   CHR.CONTRACT_NUMBER = NVL(l_contract_number,CHR.CONTRACT_NUMBER)
              							  AND	khr.deal_type       IN ('LOAN','LEASEDF','LOAN-REVOLVING',
                                                            'LEASEST','LEASEOP')
    		                      AND	chr.id				= khr.id
    		                      AND	khs.code			= chr.sts_code
    		                      AND	khs.ste_code		= 'ACTIVE'
              							  AND	rules.dnz_chr_id	= chr.id
              							  AND	rules.rule_information_category	  = 'LAINTP'
              							  AND	rgp.id							  =	rules.rgp_id
              							  AND	rgp.chr_id						  = chr.id
              							  AND	rgp.rgd_code					  =	'LAIIND'
                              AND NVL(rules.rule_information1, 'N') = 'Y'
                              ORDER BY khr.deal_type, chr.contract_number;

    CURSOR c_strm_elements1(p_khr_id NUMBER, p_sty_id NUMBER) IS
        SELECT stm.id
        FROM   okl_streams stm
        WHERE  stm.khr_id = p_khr_id
        AND    stm.sty_id = p_sty_id;

    CURSOR c_stm_id_line_number(c_stm_id NUMBER) IS
    	SELECT SE_LINE_NUMBER
    	FROM   OKL_STRM_ELEMENTS_V
    	WHERE  stm_id = c_stm_id
    	ORDER BY SE_LINE_NUMBER DESC;

    CURSOR c_tran_num_csr IS
        SELECT  okl_sif_seq.nextval
        FROM    dual;

    --get next reamort date for a contract
    CURSOR l_next_reamort_date_csr(cp_khr_id IN NUMBER) IS
    SELECT add_months(NVL(date_last_interim_interest_cal, start_date), decode(pay_freq, 'M', 1, 'Q', 3, 'S', 6, 'A', 12, 1)) next_reamort_date
    FROM   okl_k_headers_full_v khr,
           (Select distinct rgp.dnz_chr_id khr_id
                  ,sll.object1_id1 Pay_freq
            from   okc_rules_b sll,
                   okc_rules_b slh,
                   okl_strm_type_b styp,
                   okc_rule_groups_b rgp
            where  to_number(sll.object2_id1) = slh.id
            and    sll.rule_information_category = 'LASLL'
            and    sll.dnz_chr_id  =  rgp.dnz_chr_id
            and    sll.rgp_id      = rgp.id
            and    slh.rule_information_category = 'LASLH'
            and    slh.dnz_chr_id  =  rgp.dnz_chr_id
            and    slh.rgp_id      = rgp.id
            and    slh.object1_id1 = styp.id
            and    styp.stream_type_purpose = 'RENT'
            and    rgp.rgd_code    = 'LALEVL'
            and    rgp.dnz_chr_id  = cp_khr_id
            ) pay
    where  khr.id = cp_khr_id
    and khr.id = pay.khr_id;

  	l_msg_count			number;

  	------------------------------------------------------------
  	-- Declare records: i - insert, u - update, r - result
  	------------------------------------------------------------

  	-- Transaction headers
  	i_taiv_rec	Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
  	u_taiv_rec	Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
  	r_taiv_rec	Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;

  	-- Transaction lines
  	i_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
  	u_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
  	r_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;

  	-- Transaction line details
  	i_tldv_rec	        Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
  	u_tldv_rec	        Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
    l_init_tldv_rec     Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
  	r_tldv_rec	        Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;

  	-- Stream elements
  	u_selv_rec	        Okl_Streams_Pub.selv_rec_type;
  	l_init_selv_rec	    Okl_Streams_Pub.selv_rec_type;
  	r_selv_rec	        Okl_Streams_Pub.selv_rec_type;

    ------------------------------------------------------------
    -- Declare records
    ------------------------------------------------------------
    l_interest_rec  interest_rec;
    lx_interest_rec interest_rec;
    e_interest_rec  interest_rec;
    l_selv_rec      Okl_Streams_Pub.selv_rec_type;
    lx_selv_rec     Okl_Streams_Pub.selv_rec_type;
    l_stmv_rec      Okl_Streams_Pub.stmv_rec_type;
    lx_stmv_rec     Okl_Streams_Pub.stmv_rec_type;
    l_taiv_rec	   Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
    lx_taiv_rec	   Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
    l_tilv_rec	   Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
    lx_tilv_rec	   Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
    l_tldv_rec	   Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
    lx_tldv_rec	   Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
    l_bpd_acc_rec   Okl_Acc_Call_Pub.bpd_acc_rec_type;
    l_ipm_rec	   OKL_IPM_PVT.ipm_rec_type;
    lx_ipm_rec	   OKL_IPM_PVT.ipm_rec_type;

  BEGIN

  	------------------------------------------------------------
   	-- Start processing
   	------------------------------------------------------------

  	x_return_status := OKL_API.G_RET_STS_SUCCESS;

   	l_return_status := OKL_API.START_ACTIVITY(
    		p_api_name	    => l_api_name,
       	p_pkg_name	    => g_pkg_name,
    		p_init_msg_list	=> p_init_msg_list,
    		l_api_version	=> l_api_version,
    		p_api_version	=> p_api_version,
    		p_api_type	    => '_PVT',
    		x_return_status	=> l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
   		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    	RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  	------------------------------------------------------------
  	-- Initialise local variables
  	------------------------------------------------------------

  	l_khr_id	:= l_def_no_val;
  	l_kle_id	:= l_def_no_val;
  	l_trx_type	:= get_trx_type (l_trx_type_name, l_trx_type_lang);

  	-- *****************************************************************
  	-- ** Get try_id (Added by STM) and stm_id (Added by RD)		   *
  	-- *****************************************************************

    -- **********************
    -- ** Process contracts *
    -- **********************

    print_debug('***Start of Processing***');
    print_debug('Contract Number: '||p_contract_number);
    FOR r_contracts_csr IN c_contracts_csr ( p_contract_number, p_to_date) LOOP
      print_debug ('--------------------------------------------------------------------------');
      print_debug ('--------------------------------------------------------------------------');
      print_debug ('Start Processing for Contract Number: ' ||r_contracts_csr.contract_number);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'--------------------------------------------------------------------------');
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'--------------------------------------------------------------------------');
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Start Processing for Contract Number: ' ||r_contracts_csr.contract_number);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Contract Start Date: ' || r_contracts_csr.start_date);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Last Interest Calculation Date: ' ||r_contracts_csr.date_last_interim_interest_cal);

      print_debug('Contract Number: '||r_contracts_csr.contract_number||' Contract Start Date: '||
                        r_contracts_csr.start_date||' Last Interest Calculation Date: '
                        ||r_contracts_csr.date_last_interim_interest_cal);


      -- Get sty_id for the contract
      Okl_Streams_Util.get_primary_stream_type(
		p_khr_id => r_contracts_csr.khr_id,
		p_primary_sty_purpose => 'VARIABLE_INTEREST',
		x_return_status => l_return_status,
		x_primary_sty_id => l_sty_id );

        IF 	(l_return_status = 'S' ) THEN
         	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream Id for purpose VARIABLE_INTEREST retrieved.');
         	print_debug ('        -- Stream Id for purpose VARIABLE_INTEREST retrieved.');
       	ELSE
         	FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Could not retrieve Stream Id for purpose VARIABLE_INTEREST.');
      	END IF;

      	IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        	RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        	RAISE Okl_Api.G_EXCEPTION_ERROR;
      	END IF;

      l_last_interest_cal_date := null;
      lx_rulv_rec := e_rulv_rec;  -- Initialize rule record
      --l_interim_cal_yn := FALSE;
      Okl_Bp_Rules.extract_rules(
           	    p_api_version      => p_api_version,
       	        p_init_msg_list    => p_init_msg_list,
        	   	 	p_khr_id           => r_contracts_csr.khr_id,
          			p_kle_id           => null,
          			p_rgd_code         => 'LAIIND',
          			p_rdf_code         => 'LAICLC',
          			x_return_status    => x_return_status,
          			x_msg_count        => x_msg_count,
          			x_msg_data         => x_msg_data,
          			x_rulv_rec         => lx_rulv_rec);
      l_reamort := lx_rulv_rec.rule_information5;

      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Method of Calculation: ' || l_reamort);

      if (r_contracts_csr.date_last_interim_interest_cal is not null
            and r_contracts_csr.date_last_interim_interest_cal > r_contracts_csr.start_date) THEN
            l_stm_date := r_contracts_csr.date_last_interim_interest_cal;
      elsif(lx_rulv_rec.rule_information4 is not null
                and FND_DATE.canonical_to_date(lx_rulv_rec.rule_information4) > r_contracts_csr.start_date) THEN
            l_stm_date := FND_DATE.canonical_to_date(lx_rulv_rec.rule_information4);
      else
            l_stm_date := r_contracts_csr.start_date;
      end if;


      if (r_contracts_csr.date_last_interim_interest_cal is not null
            and r_contracts_csr.date_last_interim_interest_cal > r_contracts_csr.start_date) THEN
            l_reamort_date := r_contracts_csr.date_last_interim_interest_cal;
      else
            l_reamort_date := null;
      end if;

      print_debug('Stream Start Date: '||l_stm_date);
      print_debug('ReAmort Date: '||l_reamort_date);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'ReAmort Date: '||l_reamort_date);

      l_end_of_process := FALSE;

      IF l_reamort = 'REAMORT' THEN
        FOR c_next_reamort_date_csr in l_next_reamort_date_csr(r_contracts_csr.khr_id) LOOP
          print_debug('Length of To Due Date: ' || length(p_to_date));
          print_debug('Next ReAmort Date: '||c_next_reamort_date_csr.next_reamort_date || ' To Due Date: ' || p_to_date);
          IF (trunc(c_next_reamort_date_csr.next_reamort_date) > trunc(nvl(p_to_date, sysdate)))  THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Reamort date or contract start date is past the provided end date.');
            x_return_status := okl_api.G_RET_STS_SUCCESS;
            l_end_of_process := TRUE;
          END IF;
        END LOOP;
      END IF;

      IF (l_reamort = 'REAMORT' and not(l_end_of_process)) THEN
        --l_interim_cal_yn := TRUE;
        print_debug('ReAmort Date: '||l_reamort_date);

        initiate_request
                (p_api_version	    => l_api_version
              	,p_init_msg_list	=> p_init_msg_list
                ,p_contract_number  => r_contracts_csr.contract_number
                ,p_from_date        => l_reamort_date
                ,p_to_date          => NULL
              	,x_return_status	=> l_return_status
              	,x_msg_count	    => x_msg_count
              	,x_msg_data	    	=> x_msg_data
            		,x_request_id       => l_request_id
            		,x_trans_status     => l_trans_status);
        IF ( x_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
        	    RAISE Fnd_Api.G_EXC_ERROR;
        ELSIF (X_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
    	       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

      ELSE
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Stream Start Date: '||l_stm_date);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Contract Id: '||r_contracts_csr.khr_id);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'To Date: '||p_to_date);

        print_debug('Stream Start Date: '||l_stm_date||' KHR ID: '||r_contracts_csr.khr_id||
                        ' To Date: '||p_to_date);

        l_last_interest_cal_date := r_contracts_csr.date_last_interim_interest_cal;

        l_end_of_process := FALSE;
        l_bill_date := null;
        l_due_date := null;
        LOOP
          If (r_contracts_csr.deal_type = 'LOAN' or r_contracts_csr.deal_type ='LOAN-REVOLVING') THEN

            OKL_STREAM_GENERATOR_PVT.get_next_billing_date(
                p_api_version            => p_api_version,
       	        p_init_msg_list          => p_init_msg_list,
        	   	 	p_khr_id                 => r_contracts_csr.khr_id,
                p_billing_date           => l_last_interest_cal_date,
                x_next_due_date          => l_due_date,
                x_next_period_start_date => l_period_start_date,
                x_next_period_end_date   => l_period_end_date,
          			x_return_status          => x_return_status,
          			x_msg_count              => x_msg_count,
          			x_msg_data               => x_msg_data);
          end if;

          If (trunc(l_due_date) = l_last_interest_cal_date or
              l_due_date is null or
              trunc(l_due_date) > trunc(sysdate) or
              trunc(l_due_date) > trunc(p_to_date)) THEN
              --EXIT;
              l_end_of_process := TRUE;
          end if;

          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Stream Element Date: '|| l_due_date);

          print_debug('Stream Element Date: '||l_due_date);

  	      x_return_status := OKL_API.G_RET_STS_SUCCESS;
          ----------------------------------------------------
          -- Create new transaction header for every
          -- contract and bill_date combination
          ----------------------------------------------------
          print_debug('Bill Date: '||l_due_date);
          print_debug('Bill Date: '||l_bill_date);

          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Stream Element Date: '||l_due_date|| ', Bill Date: '||l_bill_date);

          IF (l_bill_date is null OR
             l_bill_date	<> l_due_date OR
             (l_bill_date is not null and l_end_of_process)) THEN

            print_debug('Bill Date: '||l_bill_date);
            print_debug('In KHR: '||l_khr_id);
      			---------------------------------------------
      			-- Save previous header amount except first record
      			---------------------------------------------
            IF l_khr_id <> l_def_no_val THEN
              print_debug('In KHR: '||l_khr_id);

              u_taiv_rec.id	:= l_header_id;
              u_taiv_rec.amount	:= l_header_amount;

              Okl_Trx_Ar_Invoices_Pub.update_trx_ar_invoices
      					(p_api_version
      					,p_init_msg_list
      					,l_return_status
      					,x_msg_count
      					,x_msg_data
      					,u_taiv_rec
      					,r_taiv_rec);

              IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      					RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      					RAISE Okl_Api.G_EXCEPTION_ERROR;
              END IF;
              print_debug('Updated the TAI record successfully');
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Updated the TAI record successfully');
              COMMIT;
            END IF;

      			---------------------------------------------
      			-- Populate required columns
      			---------------------------------------------
            IF NOT(l_end_of_process) THEN
      			  i_taiv_rec.khr_id		    := r_contracts_csr.khr_id;
      			  i_taiv_rec.date_invoiced	:= l_due_date;
      			  i_taiv_rec.try_id		    := l_trx_type;
      			  i_taiv_rec.date_entered		:= l_date_entered;
      			  i_taiv_rec.description		:= l_def_desc;
      			  i_taiv_rec.trx_status_code	:= l_final_status;
      			  i_taiv_rec.amount		    := l_zero_amount;

  	          ------------------------------------------------------------
  	          -- Derive Organization and Set of Books
	            ------------------------------------------------------------

  	          SELECT CHR.currency_code
             	  ,CHR.authoring_org_id
                ,hru.set_of_books_id
              INTO
                   i_taiv_rec.currency_code
                  ,i_taiv_rec.org_id
                  ,i_taiv_rec.set_of_books_id
              FROM   okc_k_headers_b CHR
                  ,hr_operating_units hru
              WHERE  CHR.id =  r_contracts_csr.khr_id
              AND    hru.organization_id = CHR.authoring_org_id;

              print_debug('Before inserting into TAI');
      			  ---------------------------------------------
      			  -- Insert transaction header record
              ---------------------------------------------
      			  Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices
        				(p_api_version
        				,p_init_msg_list
        				,l_return_status
        				,x_msg_count
        				,x_msg_data
        				,i_taiv_rec
        				,r_taiv_rec);

              IF 	(l_return_status = 'S' ) THEN
         				FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Internal TXN Header Created.');
         				print_debug ('        -- Internal TXN Header Created.');
       			  ELSE
         				FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Creating Internal TXN Header.');
      			  END IF;

      			  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        				RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      			  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        				RAISE Okl_Api.G_EXCEPTION_ERROR;
      			  END IF;

      			  ---------------------------------------------
      			  -- Adjust header variables
      			  ---------------------------------------------
     		      print_debug ('Line Number: '||l_first_line);
      			  l_line_number	:= l_first_line;
      			  l_header_amount	:= l_zero_amount;
      			  l_header_id	    := r_taiv_rec.id;
              print_debug ('Line Number: '||l_line_number);
            END IF;
          END IF;


          ----------------------------------------------------
          -- Create new transaction line for every
          -- contract line and bill_date combination
          ----------------------------------------------------
          print_debug ('Bill Date xx: '||l_bill_date||' Equals : '||l_due_date);

          IF (l_bill_date is null  OR
              l_bill_date <> l_due_date OR
             (l_bill_date is not null and l_end_of_process)) THEN

            ---------------------------------------------
            -- Save previous line amount except first record
            ---------------------------------------------
            IF l_kle_id <> l_def_no_val THEN
      			  u_tilv_rec.id		:= l_line_id;
      			  u_tilv_rec.amount	:= l_line_amount;

      			  Okl_Txl_Ar_Inv_Lns_Pub.update_txl_ar_inv_lns
      					(p_api_version
      					,p_init_msg_list
      					,l_return_status
      					,x_msg_count
      					,x_msg_data
      					,u_tilv_rec
      					,r_tilv_rec);

              IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      					RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      			  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      					RAISE Okl_Api.G_EXCEPTION_ERROR;
      			  END IF;

            END IF;

      			---------------------------------------------
      			-- Populate required columns
      			---------------------------------------------
            ---------------------------------------------
            -- Insert transaction line record
            ---------------------------------------------

            IF NOT(l_end_of_process) THEN
              i_tilv_rec.org_id		            := i_taiv_rec.org_id;
      			  i_tilv_rec.line_number		        := l_line_number;
      			  i_tilv_rec.tai_id		            := l_header_id;
      			  i_tilv_rec.description		        := l_def_desc;
      			  i_tilv_rec.inv_receiv_line_code	    := l_line_code;
      			  i_tilv_rec.amount		            := l_zero_amount;
      			  i_tilv_rec.date_bill_period_start   := l_due_date;
              --i_tilv_rec.date_bill_period_end	    := l_oks_bill_rec.DATE_BILLED_TO;

      			  ---------------------------------------------
      			  -- Columns which are not used by stream billing
      			  ---------------------------------------------
      			  i_tilv_rec.til_id_reverses	:= NULL;
      			  i_tilv_rec.tpl_id		    := NULL;
      			  i_tilv_rec.acn_id_cost		:= NULL;
      			  i_tilv_rec.sty_id		    := NULL;
      			  i_tilv_rec.quantity		    := NULL;
      			  i_tilv_rec.amount_applied	:= NULL;
      			  i_tilv_rec.org_id		    := NULL;
      			  i_tilv_rec.receivables_invoice_id := NULL;

      			  ---------------------------------------------
      			  -- Insert transaction line record
      			  ---------------------------------------------
      			  Okl_Txl_Ar_Inv_Lns_Pub.insert_txl_ar_inv_lns
        				(p_api_version
        				,p_init_msg_list
        				,l_return_status
        				,x_msg_count
        				,x_msg_data
        				,i_tilv_rec
        				,r_tilv_rec);

              IF (l_return_status = 'S' ) THEN
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Internal TXN Line Created.');
                print_debug ('        -- Internal TXN Line Created.');
              ELSE
                FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Creating Internal TXN Line.');
      			  END IF;

      			  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        				RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      			  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        				RAISE Okl_Api.G_EXCEPTION_ERROR;
      			  END IF;

      			  ---------------------------------------------
      			  -- Adjust line variables
      			  ---------------------------------------------
       			  print_debug ('Line Number before TXD: '||l_first_line);
      			  l_detail_number	:= l_first_line;
      			  l_line_amount	:= l_zero_amount;
      			  l_line_id	    := r_tilv_rec.id;
              l_line_number	:= l_line_number + l_line_step;
            END IF;
          END IF;

          IF (l_end_of_process) THEN
            EXIT;
          END IF;

          ----------------------------------------------------
          -- Create new transaction line detail for every stream
          ----------------------------------------------------

      	  ------------------------------------------------------------
      	  -- Derive Period Interest Amount
      	  ------------------------------------------------------------

          lx_interest_rec := e_interest_rec;
          l_interest_rec := e_interest_rec;

          l_interest_rec.khr_id   := r_contracts_csr.khr_id;
          --l_interest_rec.kle_id   := r_strm_elements.kle_id;
    		  l_interest_rec.end_date := l_due_date;
          --l_interest_rec.Principle:= r_strm_elements.amount;


          interest_cal(
                p_api_version    =>     p_api_version,
                p_init_msg_list  =>     p_init_msg_list,
                x_return_status  =>     x_return_status,
                x_msg_count      =>     x_msg_count,
                x_msg_data       =>     x_msg_data,
                p_interest_rec   =>     l_interest_rec,
                x_interest_rec   =>     lx_interest_rec);

          l_ste_amount := lx_interest_rec.interest_amount;
          print_debug('Interest Amount Back: '||lx_interest_rec.interest_amount);
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Interest Amount Back: '||lx_interest_rec.interest_amount);
          print_debug('Interest Rate Back: '||lx_interest_rec.effective_rate);

          ------------------------------------------------------------
          -- Derive Stream Type
          ------------------------------------------------------------
          ------------------------------------------------------------
          -- Insert Stream Element
          ------------------------------------------------------------

          print_debug('KHR ID: '||r_contracts_csr.khr_id||
                                'STY ID: '|| l_sty_id);

          l_selv_rec.stm_id := NULL;

          OPEN c_strm_elements1 (r_contracts_csr.khr_id, l_sty_id);
          FETCH c_strm_elements1 INTO l_selv_rec.stm_id;
          CLOSE c_strm_elements1;

          IF l_selv_rec.stm_id IS NULL THEN

            print_debug('No Streams');

           	OPEN  c_tran_num_csr;
           	FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
            CLOSE c_tran_num_csr;
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'No Streams found.');
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Transaction Number : ' ||l_stmv_rec.transaction_number);
            print_debug('No Streams : '||l_stmv_rec.transaction_number);

            l_stmv_rec.sty_id                := l_sty_id;
            l_stmv_rec.khr_id                := r_contracts_csr.khr_id;
            l_stmv_rec.sgn_code              := 'MANL';
            l_stmv_rec.say_code              := 'CURR';
            l_stmv_rec.active_yn             := 'Y';
            l_stmv_rec.date_current          := sysdate;
            l_stmv_rec.comments              := 'Variable Interest';

            Okl_Streams_Pub.create_streams(
                    p_api_version    =>     p_api_version,
                    p_init_msg_list  =>     p_init_msg_list,
                    x_return_status  =>     x_return_status,
                    x_msg_count      =>     x_msg_count,
                    x_msg_data       =>     x_msg_data,
                    p_stmv_rec       =>     l_stmv_rec,
                    x_stmv_rec       =>     lx_stmv_rec);

            IF 	(x_return_status = 'S' ) THEN
       				print_debug ('        -- Success in Stream Creation.');
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'        -- Success in Stream Creation.');
       			ELSE
       				print_debug ('        -- Error: '||x_msg_data);
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'        -- Error: '||x_msg_data);
      			END IF;

       	    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        		    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          	   	    RAISE OKL_API.G_EXCEPTION_ERROR;
      	    END IF;

      			print_debug ('Stm ID: '||lx_stmv_rec.id);
            l_selv_rec.stm_id := lx_stmv_rec.id;
    		    print_debug ('Stm ID: '||l_selv_rec.stm_id);

          END IF;

          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Stream Id : '||to_char(l_selv_rec.stm_id));
          --FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Stream Type Id: '||to_char(l_tilv_rec.sty_id));

          l_selv_rec.accrued_yn   := 'N';
          l_selv_rec.comments     := 'Variable Interest';
          l_selv_rec.stream_element_date := l_due_date;
          l_selv_rec.date_billed := SYSDATE;
          l_selv_rec.amount := lx_interest_rec.interest_amount;

          ----------- added by bv to populate mandatory field in table Okl_Strm_Elements.
          l_selv_rec.se_line_number := NULL;
          OPEN  c_stm_id_line_number(l_selv_rec.stm_id);
          FETCH c_stm_id_line_number INTO l_selv_rec.se_line_number;
          if(c_stm_id_line_number%rowcount = 0) THEN
            l_selv_rec.se_line_number := 1;
          else
            l_selv_rec.se_line_number := l_selv_rec.se_line_number+1;
          end if;
          CLOSE c_stm_id_line_number;

          Okl_Streams_Pub.create_stream_elements(
                p_api_version    =>     p_api_version,
                p_init_msg_list  =>     p_init_msg_list,
                x_return_status  =>     x_return_status,
                x_msg_count      =>     x_msg_count,
                x_msg_data       =>     x_msg_data,
                p_selv_rec       =>     l_selv_rec,
                x_selv_rec       =>     lx_selv_rec);

          IF 	(x_return_status = 'S' ) THEN
       			print_debug ('        -- Success in Creating Stream Elements.');
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'        -- Success in Creating Stream Elements.');
  	      ELSE
      			print_debug ('        -- Error: '||x_msg_data);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,' -- Error in Creating Stream'||x_msg_data);
    		  END IF;


   	      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    		    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   	      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    		    RAISE OKL_API.G_EXCEPTION_ERROR;
   	      END IF;

          ---------------------------------------------
          -- Insert record in IPM
          ---------------------------------------------
          l_ipm_rec.source_table		:= 'OKL_TRX_AR_INVOICES_V';
          l_ipm_rec.source_id	        := r_taiv_rec.id;
          l_ipm_rec.param_name		:= 'VARIABLE_INT_RATE';
          l_ipm_rec.param_value	    := lx_interest_rec.effective_rate;
          print_debug('Interest Rate in IPM: '||l_ipm_rec.param_value);
          print_debug('TAI: '||r_taiv_rec.id);

  	      OKL_IPM_PVT.insert_row
    				(p_api_version  => p_api_version
    				,p_init_msg_list=> p_init_msg_list
    				,x_return_status=> x_return_status
    				,x_msg_count    => x_msg_count
    				,x_msg_data     => x_msg_data
    				,p_ipm_rec     => l_ipm_rec
    				,x_ipm_rec     => lx_ipm_rec);


          IF 	(x_return_status = 'S' ) THEN
            print_debug ('        -- IPM Inserted .');
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'        -- IPM Inserted .');
          ELSE
            print_debug ('        -- IPM Error: '||x_msg_data);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'        -- IPM Error.'||x_msg_data);
          END IF;
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'After Inserting into Trx Params - Status: '||x_return_status);

          ----------------------------------------------------
          -- Populate required columns
          ----------------------------------------------------
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Stream Type: '||l_sty_id);
          print_debug ('        -- line detail number: '||l_detail_number);

          i_tldv_rec.sty_id                   := l_sty_id;
          i_tldv_rec.amount			        := lx_interest_rec.interest_amount;
    		  i_tldv_rec.description		        := l_def_desc;
          --i_tldv_rec.sel_id			        := lx_selv_rec.id;
    		  i_tldv_rec.til_id_details	        := l_line_id;
    		  i_tldv_rec.line_detail_number		:= l_detail_number;
          i_tldv_rec.date_calculation		    := SYSDATE;
          --i_tldv_rec.org_id			        := i_taiv_rec.org_id;

          ----------------------------------------------------
     		  -- Insert transaction line detail record
    		  ----------------------------------------------------
          Okl_Txd_Ar_Ln_Dtls_Pub.insert_txd_ar_ln_dtls
      			(p_api_version
      			,p_init_msg_list
      			,l_return_status
      			,x_msg_count
      			,x_msg_data
      			,i_tldv_rec
      			,r_tldv_rec);

          IF (l_return_status = 'S' ) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Internal TXN Details Created.');
              print_debug ('        -- Internal TXN Details Created.');
          ELSE
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Internal TXN Details.');
              print_debug ('        -- ERROR: Creating Internal TXN Details.');
              FOR i in 1..x_msg_count
              LOOP
                FND_MSG_PUB.GET(
                      p_msg_index     => i,
                      p_encoded       => FND_API.G_FALSE,
                      p_data          => x_msg_data,
                      p_msg_index_out => l_msg_index_out
                     );
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||to_char(i)||': '||x_msg_data);
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Message Index: '||l_msg_index_out);
                print_debug('Error '||to_char(i)||': '||x_msg_data);
                print_debug('Message Index: '||l_msg_index_out);
              END LOOP;
          END IF;

          IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  			    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
  			    RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;

    		  l_bpd_acc_rec.id 		   := r_tldv_rec.id;
    		  l_bpd_acc_rec.source_table := 'OKL_TXD_AR_LN_DTLS_B';
    		  ----------------------------------------------------
    		  -- Create Accounting Distributions
    		  ----------------------------------------------------
          Okl_Acc_Call_Pub.CREATE_ACC_TRANS(
       			p_api_version
    		   ,p_init_msg_list
    		   ,x_return_status
    		   ,x_msg_count
    		   ,x_msg_data
  			   ,l_bpd_acc_rec);

   	      IF 	(x_return_status = 'S' ) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Accounting Distributions Created.');
              print_debug ('        -- Accounting Distributions Created.');
          ELSE
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Accounting Distributions NOT Created.');
              print_debug ('        -- ERROR: Accounting Distributions NOT Created.');
              FOR i in 1..x_msg_count
              LOOP
                FND_MSG_PUB.GET(
                      p_msg_index     => i,
                      p_encoded       => FND_API.G_FALSE,
                      p_data          => x_msg_data,
                      p_msg_index_out => l_msg_index_out
                     );
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||to_char(i)||': '||x_msg_data);
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Message Index: '||l_msg_index_out);
                print_debug('Error '||to_char(i)||': '||x_msg_data);
                print_debug('Message Index: '||l_msg_index_out);
              END LOOP;
          END IF;


          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      			RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     		  ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      			RAISE Okl_Api.G_EXCEPTION_ERROR;
    		  END IF;

    		  ----------------------------------------------------
    		  -- Adjust line variables
    		  ----------------------------------------------------

    		  l_khr_id 	    := r_contracts_csr.khr_id;
    		  l_bill_date	    := l_due_date;
    		  l_header_amount	:= l_header_amount + l_ste_amount;
    		  l_line_amount	:= l_line_amount   + l_ste_amount;
     		  l_detail_number	:= l_detail_number + l_line_step;



          FND_FILE.PUT_LINE (FND_FILE.LOG, '===============================================================================');

          UPDATE okl_k_headers khr
              SET khr.date_last_interim_interest_cal =  l_due_date
              where khr.id = r_contracts_csr.khr_id;

          l_last_interest_cal_date := l_due_date;
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'After Updating Contract Header : Status'||x_return_status);

        END LOOP;
--
--        ---------------------------------------------------
--        -- Commit the present record
--        ---------------------------------------------------
--        COMMIT;
--
      END IF;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'End Processing for Contract Number: ' ||r_contracts_csr.contract_number);
      print_debug ('End Processing for Contract Number: ' ||r_contracts_csr.contract_number);
    END LOOP;
    print_debug('***End of Processing***');

  	OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);

  EXCEPTION
    	------------------------------------------------------------
    	-- Exception handling
    	------------------------------------------------------------

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
  		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
    					p_api_name	=> l_api_name,
    					p_pkg_name	=> G_PKG_NAME,
    					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
    					x_msg_count	=> x_msg_count,
    					x_msg_data	=> x_msg_data,
    					p_api_type	=> '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
    					p_api_name	=> l_api_name,
    					p_pkg_name	=> G_PKG_NAME,
    					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
    					x_msg_count	=> x_msg_count,
    					x_msg_data	=> x_msg_data,
    					p_api_type	=> '_PVT');

    WHEN OTHERS THEN
   		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
    					p_api_name	=> l_api_name,
    					p_pkg_name	=> G_PKG_NAME,
    					p_exc_name	=> 'OTHERS',
    					x_msg_count	=> x_msg_count,
    					x_msg_data	=> x_msg_data,
    					p_api_type	=> '_PVT');

  END variable_interest_old;
*/

  ------------------------------------------------------------------------------
  -- Function GET_PRINT_LEAD_DAYS to extract lead days for invoice generation
  ------------------------------------------------------------------------------
  FUNCTION get_printing_lead_days
	(p_khr_id		NUMBER)
	RETURN		NUMBER IS

    -- Derive print lead days from the rules
    CURSOR c_lead_days(p_khr_id IN NUMBER) IS
	SELECT rule_information3
    FROM  okc_rules_b rule,
          okc_rule_groups_b rgp
    WHERE rgp.id = rule.rgp_id
    AND   rgp.dnz_chr_id = p_khr_id
    AND   rgd_code = 'LABILL'
    AND   rule_information_category = 'LAINVD';

    --Derive print lead days from receivables setup
    CURSOR c_default_lead_days(p_khr_id IN NUMBER) IS
	SELECT term.printing_lead_days
    FROM  okl_k_headers_full_v khr
         ,hz_customer_profiles cp
         ,ra_terms term
    WHERE khr.id = p_khr_id
    AND khr.bill_to_site_use_id = cp.site_use_id
    AND cp.standard_terms = term.term_id;

    l_printing_lead_days NUMBER := 0;
  BEGIN
    OPEN c_lead_days(p_khr_id);
    FETCH c_lead_days INTO l_printing_lead_days;
    CLOSE c_lead_days;

    IF (l_printing_lead_days IS NULL) THEN
      OPEN c_default_lead_days(p_khr_id);
      FETCH c_default_lead_days INTO l_printing_lead_days;
      CLOSE c_default_lead_days;
    END IF;

    RETURN NVL(l_printing_lead_days, 0);
  END get_printing_lead_days;

  ------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Function Name    get_prorated_principal_amt_line
    -- Description:     Derives the principal amount from the loan amount passed.
    -- Dependencies:
    -- Parameters:       contract line id, stream element date, loan amount, and the currency code
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  FUNCTION get_prorated_prin_amt_line (
            p_line_id             IN  NUMBER,
            p_stream_element_date IN  DATE,
            p_loan_amount         IN  NUMBER,
            p_currency_code       IN  VARCHAR2) RETURN NUMBER IS

  Cursor stream_element_interest_csr (p_line_id             NUMBER,
                                      p_stream_element_date DATE) IS
      SELECT nvl(sel_int_pmt.amount, 0) interest
      FROM   okl_strm_type_v sty_int_pmt
             ,okl_streams_v stm_int_pmt
             ,okl_strm_elements_v sel_int_pmt
       WHERE stm_int_pmt.kle_id = p_line_id
         AND stm_int_pmt.id = sel_int_pmt.stm_id
         AND sel_int_pmt.stream_element_date = p_stream_element_date
         AND stm_int_pmt.sty_id = sty_int_pmt.id
         AND stm_int_pmt.active_yn = 'Y'
         AND stm_int_pmt.say_code = 'CURR'
         AND sty_int_pmt.stream_type_purpose IN ('INTEREST_PAYMENT', 'VARIABLE_INTEREST');

  Cursor stream_element_principal_csr (p_line_id             NUMBER,
                                       p_stream_element_date DATE) IS
      SELECT nvl(sel_prin_pmt.amount, 0) principal
      FROM   okl_strm_type_v sty_prin_pmt
             ,okl_streams_v stm_prin_pmt
             ,okl_strm_elements_v sel_prin_pmt
       WHERE stm_prin_pmt.kle_id = p_line_id
         AND stm_prin_pmt.id = sel_prin_pmt.stm_id
         AND sel_prin_pmt.stream_element_date = p_stream_element_date
         AND stm_prin_pmt.sty_id = sty_prin_pmt.id
         AND stm_prin_pmt.active_yn = 'Y'
         AND stm_prin_pmt.say_code = 'CURR'
         AND sty_prin_pmt.stream_type_purpose = 'PRINCIPAL_PAYMENT';

  l_interest           okl_strm_elements_v.amount%TYPE;
  l_principal          okl_strm_elements_v.amount%TYPE;
  l_prorated_principal okl_strm_elements_v.amount%TYPE;
  BEGIN
    OPEN stream_element_interest_csr (p_line_id, p_stream_element_date);
    FETCH stream_element_interest_csr INTO l_interest;
    IF stream_element_interest_csr%NOTFOUND THEN
        l_interest := 0;
        l_prorated_principal := p_loan_amount;
        RETURN l_prorated_principal;
    END IF;
    CLOSE stream_element_interest_csr;

    OPEN stream_element_principal_csr (p_line_id, p_stream_element_date);
    FETCH stream_element_principal_csr INTO l_principal;
    IF stream_element_principal_csr%NOTFOUND THEN
        l_interest := 0;
        l_prorated_principal := p_loan_amount;
        RETURN l_prorated_principal;
    END IF;
    CLOSE stream_element_principal_csr;

    IF (( l_interest <> 0 ) AND (l_principal <> 0)) THEN
      l_prorated_principal :=  (p_loan_amount * l_principal) /(l_principal + l_interest);
      RETURN l_prorated_principal;
    ELSE
      RETURN p_loan_amount;
    END IF;
  EXCEPTION
      WHEN OTHERS THEN
      IF ( stream_element_interest_csr%ISOPEN ) THEN
         CLOSE stream_element_interest_csr;
      END IF;
      IF ( stream_element_principal_csr%ISOPEN ) THEN
         CLOSE stream_element_interest_csr;
      END IF;
      RETURN NULL;
  END;

  ------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Function Name    get_prorated_prin_amt_header
    -- Description:     Derives the principal amount from the loan amount passed.
    -- Dependencies:
    -- Parameters:      contract id, contract line id, stream element date, loan amount, and the currency code
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  FUNCTION get_prorated_prin_amt_header (
            p_contract_id         IN  NUMBER,
            p_line_id             IN  NUMBER,
            p_stream_element_date IN  DATE,
            p_loan_amount         IN  NUMBER,
            p_currency_code       IN  VARCHAR2) RETURN NUMBER IS

  Cursor strm_elem_int_line_csr (p_line_id             NUMBER,
                                 p_stream_element_date DATE) IS
      SELECT nvl(sel_int_pmt.amount, 0) interest
      FROM   okl_strm_type_v sty_int_pmt
             ,okl_streams_v stm_int_pmt
             ,okl_strm_elements_v sel_int_pmt
       WHERE stm_int_pmt.kle_id = p_line_id
         AND stm_int_pmt.id = sel_int_pmt.stm_id
         AND sel_int_pmt.stream_element_date = p_stream_element_date
         AND stm_int_pmt.sty_id = sty_int_pmt.id
         AND stm_int_pmt.active_yn = 'Y'
         AND stm_int_pmt.say_code = 'CURR'
         AND sty_int_pmt.stream_type_purpose IN ('INTEREST_PAYMENT', 'VARIABLE_INTEREST');

  Cursor strm_elem_prin_line_csr (p_line_id             NUMBER,
                                  p_stream_element_date DATE) IS
      SELECT nvl(sel_prin_pmt.amount, 0) principal
      FROM   okl_strm_type_v sty_prin_pmt
             ,okl_streams_v stm_prin_pmt
             ,okl_strm_elements_v sel_prin_pmt
       WHERE stm_prin_pmt.kle_id = p_line_id
         AND stm_prin_pmt.id = sel_prin_pmt.stm_id
         AND sel_prin_pmt.stream_element_date = p_stream_element_date
         AND stm_prin_pmt.sty_id = sty_prin_pmt.id
         AND stm_prin_pmt.active_yn = 'Y'
         AND stm_prin_pmt.say_code = 'CURR'
         AND sty_prin_pmt.stream_type_purpose = 'PRINCIPAL_PAYMENT';

  Cursor strm_elem_int_hdr_csr (p_khr_id             NUMBER,
                                p_stream_element_date DATE) IS
      SELECT nvl(sel_int_pmt.amount, 0) interest
      FROM   okl_strm_type_v sty_int_pmt
             ,okl_streams_v stm_int_pmt
             ,okl_strm_elements_v sel_int_pmt
       WHERE stm_int_pmt.khr_id = p_khr_id
         AND stm_int_pmt.id = sel_int_pmt.stm_id
         AND sel_int_pmt.stream_element_date = p_stream_element_date
         AND stm_int_pmt.sty_id = sty_int_pmt.id
         AND stm_int_pmt.active_yn = 'Y'
         AND stm_int_pmt.say_code = 'CURR'
         AND sty_int_pmt.stream_type_purpose IN ('INTEREST_PAYMENT', 'VARIABLE_INTEREST');

  Cursor strm_elem_prin_hdr_csr ( p_khr_id              NUMBER,
                                  p_stream_element_date DATE) IS
      SELECT nvl(sel_prin_pmt.amount, 0) principal
      FROM   okl_strm_type_v sty_prin_pmt
             ,okl_streams_v stm_prin_pmt
             ,okl_strm_elements_v sel_prin_pmt
       WHERE stm_prin_pmt.khr_id = p_khr_id
         AND stm_prin_pmt.id = sel_prin_pmt.stm_id
         AND sel_prin_pmt.stream_element_date = p_stream_element_date
         AND stm_prin_pmt.sty_id = sty_prin_pmt.id
         AND stm_prin_pmt.active_yn = 'Y'
         AND stm_prin_pmt.say_code = 'CURR'
         AND sty_prin_pmt.stream_type_purpose = 'PRINCIPAL_PAYMENT';

  l_interest           okl_strm_elements_v.amount%TYPE;
  l_principal          okl_strm_elements_v.amount%TYPE;
  l_prorated_principal okl_strm_elements_v.amount%TYPE;
  BEGIN
    IF (p_line_id IS NOT NULL) THEN
      OPEN strm_elem_int_line_csr (p_line_id, p_stream_element_date);
      FETCH strm_elem_int_line_csr INTO l_interest;
      IF strm_elem_int_line_csr%NOTFOUND THEN
        l_interest := 0;
        l_prorated_principal := p_loan_amount;
        RETURN l_prorated_principal;
      END IF;
      CLOSE strm_elem_int_line_csr;

      OPEN strm_elem_prin_line_csr (p_line_id, p_stream_element_date);
      FETCH strm_elem_prin_line_csr INTO l_principal;
      IF strm_elem_prin_line_csr%NOTFOUND THEN
        l_interest := 0;
        l_prorated_principal := p_loan_amount;
        RETURN l_prorated_principal;
      END IF;
      CLOSE strm_elem_prin_line_csr;

      IF (( l_interest <> 0 ) AND (l_principal <> 0)) THEN
        l_prorated_principal :=  (p_loan_amount * l_principal) /(l_principal + l_interest);
        RETURN l_prorated_principal;
      ELSE
        RETURN p_loan_amount;
      END IF;
    ELSE  /* p_line_id is NULL */
      OPEN strm_elem_int_hdr_csr (p_contract_id, p_stream_element_date);
      FETCH strm_elem_int_hdr_csr INTO l_interest;
      IF strm_elem_int_hdr_csr%NOTFOUND THEN
        l_interest := 0;
        l_prorated_principal := p_loan_amount;
        RETURN l_prorated_principal;
      END IF;
      CLOSE strm_elem_int_hdr_csr;

      OPEN strm_elem_prin_hdr_csr (p_contract_id, p_stream_element_date);
      FETCH strm_elem_prin_hdr_csr INTO l_principal;
      IF strm_elem_prin_hdr_csr%NOTFOUND THEN
        l_interest := 0;
        l_prorated_principal := p_loan_amount;
        RETURN l_prorated_principal;
      END IF;
      CLOSE strm_elem_prin_hdr_csr;

      IF (( l_interest <> 0 ) AND (l_principal <> 0)) THEN
        l_prorated_principal :=  (p_loan_amount * l_principal) /(l_principal + l_interest);
        RETURN l_prorated_principal;
      ELSE
        RETURN p_loan_amount;
      END IF;
    END IF;
  EXCEPTION
      WHEN OTHERS THEN
      IF ( strm_elem_int_line_csr%ISOPEN ) THEN
         CLOSE strm_elem_int_line_csr;
      END IF;
      IF ( strm_elem_prin_line_csr%ISOPEN ) THEN
         CLOSE strm_elem_prin_line_csr;
      END IF;
      IF ( strm_elem_int_hdr_csr%ISOPEN ) THEN
         CLOSE strm_elem_int_hdr_csr;
      END IF;
      IF ( strm_elem_prin_hdr_csr%ISOPEN ) THEN
         CLOSE strm_elem_prin_hdr_csr;
      END IF;

      RETURN NULL;
  END;

/*
  ------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    derive_principal_date_range_loan
    -- Description:      returns a PL/SQL table of records with following entries Start Date, End Date,
    --                   Receipt Amount, and Principal Balance
    -- Dependencies:
    -- Parameters:       contract id, date.
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  PROCEDURE principal_date_range_loan (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_line_id            IN  NUMBER,
            p_start_date         IN  DATE,
            p_due_date           IN  DATE,
            p_calling_program    IN  VARCHAR2,
            x_principal_balance_tbl OUT NOCOPY  principal_balance_tbl_typ)   IS

  l_api_name            CONSTANT    VARCHAR2(30) := 'DERIVE_PRINCIPAL_DATE_RANGE';
  l_api_version         CONSTANT    NUMBER       := 1.0;
  l_principal_basis     OKL_K_RATE_PARAMS.principal_basis_code%TYPE;
  l_effective_date      DATE := SYSDATE;
  l_principal_balance_tbl  principal_balance_tbl_typ ;
  l_contract_start_date DATE;
  l_start_date          DATE;
  l_principal_balance   NUMBER;
  l_counter             NUMBER := 0;
  l_receipt_counter     NUMBER := 0;
  l_revenue_recognition OKL_PRODUCT_PARAMETERS_V.revenue_recognition_method%TYPE;
  l_receipt_date        DATE;
  l_interest_calc_basis OKL_PRODUCT_PARAMETERS_V.interest_calculation_basis%TYPE;
  l_receipt_tbl         receipt_tbl_type;
  l_rcpt_tbl_count      NUMBER := 0;
  l_rcpt_tbl_index      NUMBER := 0;
  l_currency_code       OKL_K_HEADERS_FULL_V.currency_code%TYPE;
  l_prev_rcpt_date      DATE;
  l_current_rcpt_date   DATE;
  l_total_rcpt_prin_amt NUMBER;
  l_current_rcpt_prin_amt NUMBER;
  l_total_rcpt_loan_amt NUMBER;
  l_current_rcpt_loan_amt NUMBER;
  l_prin_bal_strm_element_date DATE;

  Cursor principal_basis_csr (p_contract_id NUMBER,
                              p_effective_date DATE) IS
      SELECT principal_basis_code
      FROM   okl_k_rate_params
      WHERE  khr_id = p_contract_id
      AND    p_effective_date BETWEEN effective_from_date and nvl(effective_to_date, SYSDATE)
      AND    parameter_type_code = 'ACTUAL';

  Cursor contract_csr (p_contract_id NUMBER) IS
      SELECT start_date, currency_code
      FROM   okl_k_headers_full_v
      WHERE  khr_id = p_contract_id;

  Cursor sch_asset_prin_bal_stream_csr (p_contract_id NUMBER,
                                        p_line_id     NUMBER,
                                        p_start_date  DATE) IS
      SELECT MAX(stream_element_date)
      FROM   OKL_ASSET_STREAMS_UV
      WHERE  contract_id = p_contract_id
        AND  line_id = p_line_id
        AND  stream_element_date < p_start_date
        AND  stream_type_purpose_code = 'PRINCIPAL_BALANCE';

  Cursor sch_ctr_prin_bal_stream_csr (p_contract_id NUMBER,
                                      p_start_date  DATE) IS
      SELECT MAX(stream_element_date)
      FROM   OKL_ASSET_STREAMS_UV
      WHERE  contract_id = p_contract_id
        AND  stream_element_date < p_start_date
        AND  stream_type_purpose_code = 'PRINCIPAL_BALANCE';

  Cursor sch_asset_prin_balance_csr (p_contract_id NUMBER,
                                     p_line_id     NUMBER,
                                     p_stream_element_date  DATE) IS
      SELECT amount
      FROM   OKL_ASSET_STREAMS_UV
      WHERE  contract_id = p_contract_id
        AND  line_id = p_line_id
        AND  stream_element_date = p_stream_element_date
        AND  stream_type_purpose_code = 'PRINCIPAL_BALANCE';

  Cursor sch_ctr_prin_balance_csr (p_contract_id NUMBER,
                                   p_stream_element_date  DATE) IS
      SELECT SUM(nvl(amount,0))
      FROM   OKL_ASSET_STREAMS_UV
      WHERE  contract_id = p_contract_id
        AND  stream_element_date = p_stream_element_date
        AND  stream_type_purpose_code = 'PRINCIPAL_BALANCE';

  Cursor revenue_recognition_csr (p_contract_id NUMBER) IS
      SELECT ppm.revenue_recognition_method,
             ppm.interest_calculation_basis
      FROM   okl_k_headers khr,
             okl_product_parameters_v ppm
       WHERE khr.pdt_id = ppm.id
         AND khr.id = p_contract_id;

  Cursor receipt_details_csr (p_contract_id NUMBER,
                              p_line_id     NUMBER,
                              p_start_date  DATE,
                              p_due_date    DATE) IS
        SELECT raa.apply_date receipt_date,
               sum(raa.amount_applied) principal_pmt_rcpt_amt
        FROM
             okl_cnsld_ar_strms_b lsm
             ,okl_cnsld_ar_lines_b lln
             ,okl_cnsld_ar_hdrs_b cnr
             ,ar_payment_schedules_all aps
             ,ar_receivable_applications_all raa
             ,ar_cash_receipts_all cra
             ,okl_strm_type_v sty
            WHERE  lsm.receivables_invoice_id > 0
              AND  lsm.lln_id = lln.id
              AND  lln.cnr_id = cnr.id
              AND  cnr.trx_status_code = 'PROCESSED'
              AND  lsm.khr_id = p_contract_id
              AND  lsm.kle_id = NVL(p_line_id, lsm.kle_id)
              AND  lsm.receivables_invoice_id = aps.customer_trx_id
              AND  raa.applied_customer_trx_id = aps.customer_trx_id
              AND  aps.class = 'INV'
              AND  (raa.application_type = 'CASH' or raa.application_type = 'CM')
              AND  raa.status = 'APP'
              AND  raa.apply_date BETWEEN p_start_date AND NVL(p_due_date, raa.apply_date)
              AND  raa.cash_receipt_id = cra.cash_receipt_id
              AND  lsm.sty_id = sty.id
              AND  sty.stream_type_purpose IN ('PRINCIPAL_PAYMENT', 'UNSCHEDULED_PRINCIPAL_PAYMENT', 'PRINCIPAL_CATCHUP')
       GROUP BY raa.apply_date
       ORDER BY raa.apply_date asc;

  Cursor rcpt_dtls_actual_strm_csr (p_contract_id NUMBER,
                              p_line_id     NUMBER,
                              p_start_date  DATE,
                              p_due_date    DATE) IS
        SELECT raa.apply_date receipt_date
              , lsm.kle_id
              , sel_ln_pmt.stream_element_date
              , sum(raa.amount_applied) loan_pmt_rcpt_amt
              , get_prorated_principal_amt(lsm.kle_id, sel_ln_pmt.stream_element_date,
                                           sum(raa.amount_applied), l_currency_code) principal_pmt_rcpt_amt
        FROM
              okl_cnsld_ar_strms_b lsm,
              okl_cnsld_ar_lines_b lln,
              okl_cnsld_ar_hdrs_b cnr,
              ar_payment_schedules_all aps,
              ar_receivable_applications_all raa,
              ar_cash_receipts_all cra,
              okl_strm_type_v sty_ln_pmt,
              okl_strm_elements_v sel_ln_pmt
        WHERE lsm.receivables_invoice_id > 0
          AND lsm.lln_id = lln.id
          AND lln.cnr_id = cnr.id
          AND cnr.trx_status_code = 'PROCESSED'
          AND lsm.khr_id = NVL(p_contract_id, lsm.khr_id)
          AND lsm.kle_id = NVL(p_line_id, lsm.kle_id)
          AND lsm.receivables_invoice_id = aps.customer_trx_id
          AND raa.applied_customer_trx_id = aps.customer_trx_id
          AND aps.class = 'INV'
          AND (raa.application_type = 'CASH' or raa.application_type = 'CM')
          AND raa.status = 'APP'
          AND raa.apply_date BETWEEN p_start_date AND NVL(p_due_date, raa.apply_date)
          AND raa.cash_receipt_id = cra.cash_receipt_id
          AND lsm.sty_id = sty_ln_pmt.id
          AND ( sty_ln_pmt.stream_type_purpose IN ('LOAN_PAYMENT', 'VARIABLE_LOAN_PAYMENT', 'UNSCHEDULED_LOAN_PAYMENT'))
          AND lsm.sel_id = sel_ln_pmt.id
        GROUP BY raa.apply_date
              , lsm.kle_id
              , sel_ln_pmt.stream_element_date
        ORDER BY raa.apply_date asc;

  BEGIN
    x_return_status     := OKL_API.G_RET_STS_SUCCESS;

    OPEN principal_basis_csr (p_contract_id, l_effective_date);
    FETCH principal_basis_csr INTO l_principal_basis;
    IF principal_basis_csr%NOTFOUND THEN
       CLOSE principal_basis_csr;
--     report exception;
    END IF;
    CLOSE principal_basis_csr;

    OPEN contract_csr (p_contract_id);
    FETCH contract_csr INTO l_contract_start_date, l_currency_code;
    IF (contract_csr%NOTFOUND) THEN
       CLOSE contract_csr;
--     raise exception;
    END IF;
    CLOSE contract_csr;

    -- Derive Principal Balance
    Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => 1.0,
                                    p_init_msg_list        => OKL_API.G_TRUE,
                                    x_return_status        => x_return_status,
                                    x_msg_count            => x_msg_count,
                                    x_msg_data             => x_msg_data,
                                    p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                    p_contract_id          => p_contract_id,
                                    p_line_id              => p_line_id,
                                    x_value               =>  l_principal_balance
                                   );

    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      NULL;
--       raise exception;
    END IF;


    IF (l_principal_basis = 'SCHEDULED') THEN
       IF (p_start_date = l_contract_start_date) THEN
          l_counter := l_counter + 1;
          l_principal_balance_tbl(l_counter).khr_id                 := p_contract_id;
          IF (p_line_id IS NOT NULL) THEN
             l_principal_balance_tbl(l_counter).kle_id              := p_line_id;
          ELSE
             l_principal_balance_tbl(l_counter).kle_id              := NULL;
          END IF;
          l_principal_balance_tbl(l_counter).from_date             := p_start_date;
          l_principal_balance_tbl(l_counter).to_date               := p_due_date;
          l_principal_balance_tbl(l_counter).principal_pmt_rcpt_amt := 0;
          l_principal_balance_tbl(l_counter).loan_pmt_rcpt_amt      := 0;
          l_principal_balance_tbl(l_counter).receipt_date           := NULL;
          l_principal_balance_tbl(l_counter).principal_balance      := l_principal_balance;
       ELSE

          IF (p_line_id IS NOT NULL) THEN
             OPEN sch_asset_prin_bal_stream_csr (p_contract_id, p_line_id, p_start_date);
             FETCH sch_asset_prin_bal_stream_csr INTO l_prin_bal_strm_element_date;
             IF (sch_asset_prin_bal_stream_csr % NOTFOUND) THEN
                CLOSE sch_asset_prin_bal_stream_csr;
--              raise exception;
             END IF;
             CLOSE sch_asset_prin_bal_stream_csr;

             OPEN sch_asset_prin_balance_csr (p_contract_id, p_line_id, l_prin_bal_strm_element_date);
             FETCH sch_asset_prin_balance_csr INTO l_principal_balance;
             IF (sch_asset_prin_balance_csr%NOTFOUND) THEN
                CLOSE sch_asset_prin_balance_csr;
--              raise exception;
             END IF;
             CLOSE sch_asset_prin_balance_csr;

          ELSE
             OPEN sch_ctr_prin_bal_stream_csr (p_contract_id, p_start_date);
             FETCH sch_ctr_prin_bal_stream_csr INTO l_prin_bal_strm_element_date;
             IF (sch_ctr_prin_bal_stream_csr % NOTFOUND) THEN
                CLOSE sch_ctr_prin_bal_stream_csr;
--              raise exception;
             END IF;
             CLOSE sch_ctr_prin_bal_stream_csr;

             OPEN sch_ctr_prin_balance_csr (p_contract_id, l_prin_bal_strm_element_date);
             FETCH sch_ctr_prin_balance_csr INTO l_principal_balance;
             IF (sch_ctr_prin_balance_csr%NOTFOUND) THEN
                CLOSE sch_ctr_prin_balance_csr;
--              raise exception;
             END IF;
             CLOSE sch_ctr_prin_balance_csr;
          END IF;
          l_counter := l_counter + 1;
          l_principal_balance_tbl(l_counter).khr_id                 := p_contract_id;
          IF (p_line_id IS NOT NULL) THEN
             l_principal_balance_tbl(l_counter).kle_id              := p_line_id;
          ELSE
             l_principal_balance_tbl(l_counter).kle_id              := NULL;
          END IF;
          l_principal_balance_tbl(l_counter).from_date             := p_start_date;
          l_principal_balance_tbl(l_counter).to_date               := p_due_date;
--          l_principal_balance_tbl(l_counter).principal_pmt_rcpt_amt := 0;
--          l_principal_balance_tbl(l_counter).loan_pmt_rcpt_amt      := 0;
          l_principal_balance_tbl(l_counter).receipt_date           := NULL;
          l_principal_balance_tbl(l_counter).principal_balance      := l_principal_balance;
       END IF;
    ELSIF (l_principal_basis = 'ACTUAL') THEN

       OPEN revenue_recognition_csr (p_contract_id);
       FETCH revenue_recognition_csr INTO l_revenue_recognition, l_interest_calc_basis;
       IF revenue_recognition_csr%NOTFOUND THEN
          CLOSE revenue_recognition_csr;
--     report exception;
       END IF;
       CLOSE revenue_recognition_csr;

       IF (l_revenue_recognition <> 'ACTUAL') THEN
          l_counter := 0;
          FOR current_receipt in receipt_details_csr (p_contract_id, p_line_id, p_start_date, p_due_date)
          LOOP
             l_counter                                       := l_counter + 1;
             l_receipt_tbl(l_counter).khr_id                 := p_contract_id;
             l_receipt_tbl(l_counter).kle_id                 := p_line_id;
             l_receipt_tbl(l_counter).receipt_date           := current_receipt.receipt_date;
             l_receipt_tbl(l_counter).principal_pmt_rcpt_amt := current_receipt.principal_pmt_rcpt_amt;
             l_receipt_tbl(l_counter).loan_pmt_rcpt_amt      := 0;
          END LOOP;
       ELSE
          l_prev_rcpt_date        := NULL;
          l_current_rcpt_date     := NULL;
          l_counter               := 0;
          l_total_rcpt_prin_amt   := 0;
          l_current_rcpt_prin_amt := 0;
          l_total_rcpt_loan_amt   := 0;
          l_current_rcpt_loan_amt := 0;
          FOR current_receipt in rcpt_dtls_actual_strm_csr (p_contract_id, p_line_id, p_start_date, p_due_date)
          LOOP
             l_current_rcpt_date     := current_receipt.receipt_date;
             l_current_rcpt_prin_amt := OKL_ACCOUNTING_UTIL.round_amount(current_receipt.principal_pmt_rcpt_amt, l_currency_code);
             l_current_rcpt_loan_amt := current_receipt.loan_pmt_rcpt_amt;
             IF (l_prev_rcpt_date = NULL) THEN
                l_prev_rcpt_date := l_current_rcpt_date;
             END IF;
             IF (l_current_rcpt_date = l_prev_rcpt_date) THEN
                l_total_rcpt_prin_amt := l_total_rcpt_prin_amt + l_current_rcpt_prin_amt;
                l_total_rcpt_loan_amt := l_total_rcpt_loan_amt + l_current_rcpt_loan_amt;
             ELSE
                l_counter                                       := l_counter + 1;
                l_receipt_tbl(l_counter).khr_id                 := p_contract_id;
                l_receipt_tbl(l_counter).kle_id                 := p_line_id;
                l_receipt_tbl(l_counter).receipt_date           := l_prev_rcpt_date;
                l_receipt_tbl(l_counter).principal_pmt_rcpt_amt := l_total_rcpt_prin_amt;
                l_receipt_tbl(l_counter).loan_pmt_rcpt_amt      := l_total_rcpt_loan_amt;
                l_total_rcpt_prin_amt                           := l_current_rcpt_prin_amt;
                l_total_rcpt_loan_amt                           := l_current_rcpt_loan_amt;
                l_prev_rcpt_date                                := l_current_rcpt_date;
             END IF;
          END LOOP;
          IF (l_prev_rcpt_date IS NOT NULL) THEN
             l_counter := l_counter + 1;
             l_receipt_tbl(l_counter).khr_id                 := p_contract_id;
             l_receipt_tbl(l_counter).kle_id                 := p_line_id;
             l_receipt_tbl(l_counter).receipt_date           := l_prev_rcpt_date;
             l_receipt_tbl(l_counter).principal_pmt_rcpt_amt := l_total_rcpt_prin_amt;
             l_receipt_tbl(l_counter).loan_pmt_rcpt_amt      := l_total_rcpt_loan_amt;
          END IF;

       END IF;

       l_start_date     := l_contract_start_date;
       l_counter        := 0;
       l_rcpt_tbl_count := l_receipt_tbl.COUNT;
       l_rcpt_tbl_index := l_receipt_tbl.FIRST;
       FOR l_rcpt_tbl_counter in 1 .. l_rcpt_tbl_count
       LOOP
          l_counter := l_counter + 1;
          l_principal_balance_tbl(l_counter).khr_id := p_contract_id;
          IF (p_line_id IS NOT NULL) THEN
             l_principal_balance_tbl(l_counter).kle_id := p_line_id;
          ELSE
             l_principal_balance_tbl(l_counter).kle_id := NULL;
          END IF;
          l_principal_balance_tbl(l_counter).from_date := l_start_date;
          IF (l_receipt_date > l_contract_start_date) THEN
             l_principal_balance_tbl(l_counter).to_date   := l_receipt_tbl(l_rcpt_tbl_index).receipt_date - 1;
          ELSE -- receipt date = contract start date
             l_principal_balance_tbl(l_counter).to_date   := l_receipt_tbl(l_rcpt_tbl_index).receipt_date;
          END IF;
          l_principal_balance_tbl(l_counter).principal_pmt_rcpt_amt := l_receipt_tbl(l_rcpt_tbl_index).principal_pmt_rcpt_amt;
          l_principal_balance_tbl(l_counter).loan_pmt_rcpt_amt := l_receipt_tbl(l_rcpt_tbl_index).loan_pmt_rcpt_amt;
          l_principal_balance_tbl(l_counter).receipt_date := l_receipt_tbl(l_rcpt_tbl_index).receipt_date;
          l_principal_balance_tbl(l_counter).principal_balance := l_principal_balance;

          l_start_date := l_receipt_tbl(l_rcpt_tbl_index).receipt_date;
          l_principal_balance := l_principal_balance - l_receipt_tbl(l_rcpt_tbl_index).principal_pmt_rcpt_amt;

          l_rcpt_tbl_index := l_receipt_tbl.NEXT(l_rcpt_tbl_index);

       END LOOP;

       IF (p_calling_program <> 'DAILY_INTEREST') THEN  --- check the exact value
          l_counter := l_counter + 1;
          l_principal_balance_tbl(l_counter).khr_id := p_contract_id;
          IF (p_line_id IS NOT NULL) THEN
             l_principal_balance_tbl(l_counter).kle_id := p_line_id;
          ELSE
             l_principal_balance_tbl(l_counter).kle_id := NULL;
          END IF;
          l_principal_balance_tbl(l_counter).from_date := l_start_date;
          l_principal_balance_tbl(l_counter).to_date   := p_due_date;
          l_principal_balance_tbl(l_counter).principal_pmt_rcpt_amt := 0;
          l_principal_balance_tbl(l_counter).loan_pmt_rcpt_amt := 0;
          l_principal_balance_tbl(l_counter).receipt_date := NULL;
          l_principal_balance_tbl(l_counter).principal_balance := l_principal_balance;
       END IF;

    END IF;
    x_principal_balance_tbl := l_principal_balance_tbl;


  EXCEPTION

     WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

  END principal_date_range_loan;

------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    derive_principal_date_range_loan
    -- Description:      returns a PL/SQL table of records with following entries Start Date, End Date,
    --                   Receipt Amount, and Principal Balance
    -- Dependencies:
    -- Parameters:       contract id, date.
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  PROCEDURE principal_date_range_rev_loan (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_line_id            IN  NUMBER,
            p_start_date         IN  DATE,
            p_due_date           IN  DATE,
            p_calling_program    IN  VARCHAR2,
            x_principal_balance_tbl OUT NOCOPY principal_balance_tbl_typ)   IS

  l_api_name            CONSTANT    VARCHAR2(30) := 'DERIVE_PRINCIPAL_DATE_RANGE';
  l_api_version         CONSTANT    NUMBER       := 1.0;
  l_principal_balance_tbl  principal_balance_tbl_typ ;
  l_contract_start_date DATE;
  l_start_date          DATE;
  l_principal_balance   NUMBER;
  l_counter             NUMBER := 0;
  l_revenue_recognition OKL_PRODUCT_PARAMETERS_V.revenue_recognition_method%TYPE;
  l_interest_calc_basis OKL_PRODUCT_PARAMETERS_V.interest_calculation_basis%TYPE;
  l_currency_code       OKL_K_HEADERS_FULL_V.currency_code%TYPE;
  l_current_txn_date    DATE;

  Cursor contract_csr (p_contract_id NUMBER) IS
      SELECT start_date, currency_code
      FROM   okl_k_headers_full_v
      WHERE  khr_id = p_contract_id;

  Cursor revenue_recognition_csr (p_contract_id NUMBER) IS
      SELECT ppm.revenue_recognition_method,
             ppm.interest_calculation_basis
      FROM   okl_k_headers khr,
             okl_product_parameters_v ppm
       WHERE khr.pdt_id = ppm.id
         AND khr.id = p_contract_id;

  -- sjalasut, modified the cursor to have khr_id referred from the lines table
  Cursor pymt_rcpt_details_var_int_csr (p_contract_id    NUMBER,
                                        p_start_date     DATE,
                                        p_due_date       DATE,
                                        p_rev_rec_method VARCHAR2) IS
    SELECT iph.check_date txn_date,
           sum(iph.amount) txn_amount,
           'P' txn_type
    FROM ap_invoices_all ap_inv,
         okl_trx_ap_invoices_b okl_inv,
         ap_invoice_payment_history_v iph
         ,okl_cnsld_ap_invs_all cnsld
         ,okl_txl_ap_inv_lns_all_b okl_inv_ln
         ,fnd_application fnd_app
    WHERE okl_inv.id = okl_inv_ln.tap_id
      AND okl_inv_ln.khr_id = p_contract_id
      AND ap_inv.application_id = fnd_app.application_id
      AND fnd_app.application_short_name = 'OKL'
      AND okl_inv_ln.cnsld_ap_inv_id = cnsld.cnsld_ap_inv_id
      AND cnsld.cnsld_ap_inv_id = to_number(ap_inv.reference_key1)
      AND okl_inv.funding_type_code = 'BORROWER_PAYMENT'
      AND ap_inv.invoice_id = iph.invoice_id
      AND iph.check_date BETWEEN p_start_date AND NVL(p_due_date, iph.check_date)
    GROUP BY iph.check_date
UNION
    SELECT raa.apply_date txn_date,
           sum(raa.amount_applied) txn_amount,
           'R' txn_date
    FROM   okl_cnsld_ar_strms_b lsm,
           okl_cnsld_ar_lines_b lln,
           okl_cnsld_ar_hdrs_b cnr,
           ar_payment_schedules_all aps,
           ar_receivable_applications_all raa,
           ar_cash_receipts_all cra,
           okl_strm_type_v sty
    WHERE  lsm.receivables_invoice_id > 0
      AND  lsm.lln_id = lln.id
      AND  lln.cnr_id = cnr.id
      AND  cnr.trx_status_code = 'PROCESSED'
      AND  lsm.khr_id = NVL(p_contract_id, lsm.khr_id)
      AND  lsm.receivables_invoice_id = aps.customer_trx_id
      AND  raa.applied_customer_trx_id = aps.customer_trx_id
      AND  aps.class = 'INV'
      AND  (raa.application_type = 'CASH' or raa.application_type = 'CM')
      AND  raa.status = 'APP'
      AND  raa.apply_date BETWEEN p_start_date AND NVL(p_due_date, raa.apply_date)
      AND  raa.cash_receipt_id = cra.cash_receipt_id
      AND  lsm.sty_id = sty.id
      AND  sty.stream_type_purpose = decode(p_rev_rec_method, 'ACTUAL', 'UNSCHEDULED_LOAN_PAYMENT','UNSCHEDULED_PRINCIPAL_PAYMENT')
    GROUP BY raa.apply_date
    ORDER BY txn_date asc;

  -- sjalasut, modified the cursor to have khr_id referred from okl_txl_ap_inv_lns_all_b
  Cursor pymt_rcpt_dtls_daily_int_csr (p_contract_id    NUMBER,
                                       p_start_date     DATE,
                                       p_due_date       DATE ) IS
    SELECT iph.check_date txn_date,
           sum(iph.amount) txn_amount,
           'P' txn_type
    FROM ap_invoices_all ap_inv,
         okl_trx_ap_invoices_v okl_inv,
         ap_invoice_payment_history_v iph
         ,okl_cnsld_ap_invs_all cnsld
         ,okl_txl_ap_inv_lns_all_b okl_inv_ln
         ,fnd_application fnd_app
    WHERE okl_inv.id = okl_inv_ln.tap_id
      AND okl_inv_ln.khr_id = p_contract_id
      AND ap_inv.application_id = fnd_app.application_id
      AND fnd_app.application_short_name = 'OKL'
      AND okl_inv_ln.cnsld_ap_inv_id = cnsld.cnsld_ap_inv_id
      AND cnsld.cnsld_ap_inv_id = to_number(ap_inv.reference_key1)
      AND okl_inv.funding_type_code = 'BORROWER_PAYMENT'
      AND ap_inv.invoice_id = iph.invoice_id
      AND iph.check_date BETWEEN p_start_date AND NVL(p_due_date, iph.check_date)
    GROUP BY iph.check_date
UNION
    SELECT raa.apply_date txn_date,
           sum(raa.amount_applied) txn_amount,
           'R' txn_date
    FROM   okl_cnsld_ar_strms_b lsm,
           okl_cnsld_ar_lines_b lln,
           okl_cnsld_ar_hdrs_b cnr,
           ar_payment_schedules_all aps,
           ar_receivable_applications_all raa,
           ar_cash_receipts_all cra,
           okl_strm_type_v sty
    WHERE  lsm.receivables_invoice_id > 0
      AND  lsm.lln_id = lln.id
      AND  lln.cnr_id = cnr.id
      AND  cnr.trx_status_code = 'PROCESSED'
      AND  lsm.khr_id = NVL(p_contract_id, lsm.khr_id)
      AND  lsm.receivables_invoice_id = aps.customer_trx_id
      AND  raa.applied_customer_trx_id = aps.customer_trx_id
      AND  aps.class = 'INV'
      AND  (raa.application_type = 'CASH' or raa.application_type = 'CM')
      AND  raa.status = 'APP'
      AND  raa.apply_date BETWEEN p_start_date AND NVL(p_due_date, raa.apply_date)
      AND  raa.cash_receipt_id = cra.cash_receipt_id
      AND  lsm.sty_id = sty.id
      AND  sty.stream_type_purpose IN ('VARIABLE_LOAN_PAYMENT','UNSCHEDULED_LOAN_PAYMENT')
    GROUP BY raa.apply_date
    ORDER BY txn_date asc;
  BEGIN
    x_return_status     := OKL_API.G_RET_STS_SUCCESS;

    OPEN contract_csr (p_contract_id);
    FETCH contract_csr INTO l_contract_start_date, l_currency_code;
    IF (contract_csr%NOTFOUND) THEN
       CLOSE contract_csr;
--     raise exception;
    END IF;
    CLOSE contract_csr;

    OPEN revenue_recognition_csr (p_contract_id);
    FETCH revenue_recognition_csr INTO l_revenue_recognition, l_interest_calc_basis;
    IF revenue_recognition_csr%NOTFOUND THEN
       CLOSE revenue_recognition_csr;
--     report exception;
    END IF;
    CLOSE revenue_recognition_csr;

    l_counter              := 0;
    l_start_date           := l_contract_start_date;
    l_principal_balance    := 0;
    l_current_txn_date     := NULL;

    IF (p_calling_program <> 'DAILY_INTEREST') THEN
          FOR current_txn in pymt_rcpt_details_var_int_csr (p_contract_id, p_start_date, p_due_date, l_revenue_recognition)
          LOOP
             l_counter          := l_counter + 1;
             l_current_txn_date := current_txn.txn_date;

             l_principal_balance_tbl(l_counter).khr_id     := p_contract_id;
             l_principal_balance_tbl(l_counter).kle_id     := NULL;
             l_principal_balance_tbl(l_counter).from_date := l_start_date;

             IF (l_current_txn_date > l_contract_start_date) THEN
                l_principal_balance_tbl(l_counter).to_date   := l_current_txn_date - 1;
             ELSE -- transaction date = contract start date
                l_principal_balance_tbl(l_counter).to_date   := l_current_txn_date ;
             END IF;
             l_principal_balance_tbl(l_counter).principal_pmt_rcpt_amt := 0;
             l_principal_balance_tbl(l_counter).loan_pmt_rcpt_amt      := 0;
             l_principal_balance_tbl(l_counter).receipt_date           := NULL;
             l_principal_balance_tbl(l_counter).principal_balance      := l_principal_balance;

             l_start_date := l_current_txn_date;
             IF (current_txn.txn_type = 'P') THEN
                l_principal_balance := l_principal_balance + current_txn.txn_amount;
             ELSE
                l_principal_balance := l_principal_balance - current_txn.txn_amount;
             END IF;
          END LOOP;

          l_counter := l_counter + 1;
          l_principal_balance_tbl(l_counter).khr_id := p_contract_id;
          l_principal_balance_tbl(l_counter).kle_id := NULL;
          l_principal_balance_tbl(l_counter).from_date := l_start_date;
          l_principal_balance_tbl(l_counter).to_date   := p_due_date;
          l_principal_balance_tbl(l_counter).principal_pmt_rcpt_amt := 0;
          l_principal_balance_tbl(l_counter).loan_pmt_rcpt_amt := 0;
          l_principal_balance_tbl(l_counter).receipt_date := NULL;
          l_principal_balance_tbl(l_counter).principal_balance := l_principal_balance;

    ELSE
          FOR current_txn in pymt_rcpt_details_var_int_csr (p_contract_id, p_start_date, p_due_date, l_revenue_recognition)
          LOOP
             l_counter          := l_counter + 1;
             l_current_txn_date := current_txn.txn_date;

             l_principal_balance_tbl(l_counter).khr_id     := p_contract_id;
             l_principal_balance_tbl(l_counter).kle_id     := NULL;
             l_principal_balance_tbl(l_counter).from_date := l_start_date;

             IF (l_current_txn_date > l_contract_start_date) THEN
                l_principal_balance_tbl(l_counter).to_date   := l_current_txn_date - 1;
             ELSE -- transaction date = contract start date
                l_principal_balance_tbl(l_counter).to_date   := l_current_txn_date ;
             END IF;
             l_principal_balance_tbl(l_counter).principal_pmt_rcpt_amt := 0;
             l_principal_balance_tbl(l_counter).loan_pmt_rcpt_amt      := 0;
             l_principal_balance_tbl(l_counter).receipt_date           := NULL;
             l_principal_balance_tbl(l_counter).principal_balance      := l_principal_balance;

             l_start_date := l_current_txn_date;
             IF (current_txn.txn_type = 'P') THEN
                l_principal_balance := l_principal_balance + current_txn.txn_amount;
             ELSE
                l_principal_balance := l_principal_balance - current_txn.txn_amount;
             END IF;
          END LOOP;

          l_counter := l_counter + 1;
          l_principal_balance_tbl(l_counter).khr_id := p_contract_id;
          l_principal_balance_tbl(l_counter).kle_id := NULL;
          l_principal_balance_tbl(l_counter).from_date := l_start_date;
          l_principal_balance_tbl(l_counter).to_date   := p_due_date;
          l_principal_balance_tbl(l_counter).principal_pmt_rcpt_amt := 0;
          l_principal_balance_tbl(l_counter).loan_pmt_rcpt_amt := 0;
          l_principal_balance_tbl(l_counter).receipt_date := NULL;
          l_principal_balance_tbl(l_counter).principal_balance := l_principal_balance;
    END IF;
    x_principal_balance_tbl := l_principal_balance_tbl;

  EXCEPTION

     WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

  END principal_date_range_rev_loan;
*/
------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    print_principal_date_range_tbl
    -- Description:      This procedure prints all the records in the principal date range buffer
    --
    -- Dependencies:
    -- Parameters:       .
    -- Version:          1.0
    -- End of Comments

------------------------------------------------------------------------------

  PROCEDURE print_principal_date_range_tbl ( p_principal_balance_tbl IN  principal_balance_tbl_typ) IS

  l_rec_count    NUMBER;
  l_index        NUMBER;
  l_counter      NUMBER := 0;
  BEGIN
       l_rec_count      := p_principal_balance_tbl.COUNT;
       IF (l_rec_count > 0) THEN
          l_index          := p_principal_balance_tbl.FIRST;
          print_debug('Principal Balance Table : ');
       ELSE
          print_debug('No records exist in the table');
       END IF;
       FOR l_rcpt_tbl_counter in 1 .. l_rec_count
       LOOP
          l_counter     := l_counter + 1;
          print_debug( 'Record : '|| l_counter );
		  print_debug( 'From Date : '|| p_principal_balance_tbl(l_index).from_date);
		  print_debug( 'TO Date : '|| p_principal_balance_tbl(l_index).to_date);
		  print_debug( 'Principal Balance : '|| p_principal_balance_tbl(l_index).principal_balance);

          l_index       := p_principal_balance_tbl.NEXT(l_index);
       END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
          Okl_Api.SET_MESSAGE(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => G_UNEXPECTED_ERROR,
                  p_token1       => G_SQLCODE_TOKEN,
                  p_token1_value => SQLCODE,
                  p_token2       => G_SQLERRM_TOKEN,
                  p_token2_value => SQLERRM);
  END;

------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    prin_date_range_loan_old
    -- Description:      This procedure is used by Variable Interest Calculation program for LOANS
    --                   Returns a PL/SQL table of records with following entries Start Date, End Date,
    --                   and Principal Balance
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- Version :         1.1 - Obsoleted this local procedure due to Billing Inline changes - Bug#5898792 - 23/2/2007
    -- End of Comments

------------------------------------------------------------------------------


------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    principal_date_range_var_int_loan
    -- Description:      This procedure is used by Variable Interest Calculation program for LOANS
    --                   Returns a PL/SQL table of records with following entries Start Date, End Date,
    --                   and Principal Balance
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  PROCEDURE prin_date_range_var_int_loan (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_line_id            IN  NUMBER,
            p_start_date         IN  DATE,
            p_due_date           IN  DATE,
            p_principal_basis    IN  VARCHAR2 DEFAULT NULL,
            x_principal_balance_tbl OUT	NOCOPY principal_balance_tbl_typ)   IS

  l_api_name                   CONSTANT    VARCHAR2(30) := 'PRIN_DATE_RANGE_VAR_INT_LOAN';
  l_api_version                CONSTANT    NUMBER       := 1.0;
  l_principal_basis            OKL_K_RATE_PARAMS.principal_basis_code%TYPE;
  l_effective_date             DATE := SYSDATE;
  l_principal_balance_tbl      principal_balance_tbl_typ ;
  l_principal_balance_tbl_tmp   principal_balance_tbl_typ ;
--  l_contract_start_date        DATE;
  l_start_date                 DATE;
  l_principal_balance          NUMBER;
  l_counter                    NUMBER := 0;
  l_counter_tmp                NUMBER := 0;
  l_receipt_counter            NUMBER := 0;
--  l_revenue_recognition        OKL_PRODUCT_PARAMETERS_V.revenue_recognition_method%TYPE;
  l_receipt_date               DATE;
--  l_interest_calc_basis        OKL_PRODUCT_PARAMETERS_V.interest_calculation_basis%TYPE;
  l_receipt_tbl                receipt_tbl_type;
  lx_receipt_tbl               receipt_tbl_type;
  l_rcpt_tbl_count             NUMBER := 0;
  l_rcpt_tbl_index             NUMBER := 0;
--  l_currency_code              OKL_K_HEADERS_FULL_V.currency_code%TYPE;
  l_prev_rcpt_date             DATE;
  l_current_rcpt_date          DATE;
  l_total_rcpt_prin_amt        NUMBER;
  l_current_rcpt_prin_amt      NUMBER;
  l_total_rcpt_loan_amt        NUMBER;
  l_current_rcpt_loan_amt      NUMBER;
  l_prin_bal_strm_element_date DATE;
  prin_date_range_loan_failed  EXCEPTION;
  l_previous_receipt_date      DATE;
/*
  Cursor principal_basis_csr (p_contract_id NUMBER,
                              p_effective_date DATE) IS
      SELECT nvl(principal_basis_code, 'ACTUAL')
      FROM   okl_k_rate_params
      WHERE  khr_id = p_contract_id
      AND    p_effective_date BETWEEN effective_from_date and nvl(effective_to_date, p_effective_date)
      AND    parameter_type_code = 'ACTUAL';

  Cursor contract_csr (p_contract_id NUMBER) IS
      SELECT start_date, currency_code
      FROM   okl_k_headers_full_v
      WHERE  id = p_contract_id;
*/
  Cursor sch_asset_prin_balance_csr (p_contract_id NUMBER,
                                     p_line_id     NUMBER,
                                     p_stream_element_date  DATE) IS

        SELECT sel.amount
        FROM
             okl_strm_elements sel
             ,okl_streams str
             ,okl_strm_type_v sty
            WHERE  sel.stm_id = str.id
              AND  str.khr_id = p_contract_id
              AND  str.kle_id = p_line_id
              AND  str.say_code = 'CURR'
              AND  str.active_yn = 'Y'
              AND  sel.stream_element_date = p_stream_element_date
              AND  str.sty_id = sty.id
              AND  sty.stream_type_purpose = 'PRINCIPAL_BALANCE';

  Cursor sch_ctr_prin_balance_csr (p_contract_id NUMBER,
                                   p_stream_element_date  DATE) IS
        SELECT SUM(amount)
        FROM
             okl_strm_elements sel
             ,okl_streams str
             ,okl_strm_type_v sty
            WHERE  sel.stm_id = str.id
              AND  str.khr_id = p_contract_id
              AND  str.say_code = 'CURR'
              AND  str.active_yn = 'Y'
              AND  sel.stream_element_date = p_stream_element_date
              AND  str.sty_id = sty.id
              AND  sty.stream_type_purpose = 'PRINCIPAL_BALANCE';

-- Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
       --Bug# 6819044: Fetch receipt applications correctly when
       --              contracts have multiple asset lines and
       --              invoices have lines from multiple contracts
       Cursor receipt_details_csr (p_contract_id NUMBER,
                              p_line_id     NUMBER,
                              p_start_date  DATE,
                              p_due_date    DATE) IS
       SELECT cra.receipt_date receipt_date
             ,SUM(nvl(ad.amount_cr,0))- SUM(nvl(ad.amount_dr,0)) principal_pmt_rcpt_amt -- 4884843, 4872370
       FROM  okl_txd_ar_ln_dtls_b tld,
             ra_customer_trx_lines_all ractrl,
             okl_txl_ar_inv_lns_b til,
             okl_trx_ar_invoices_b tai,
             ar_payment_schedules_all aps,
             ar_receivable_applications_all raa,
             ar_cash_receipts_all cra,
             okl_strm_type_b sty,
             ar_distributions_all ad
       WHERE tai.trx_status_code = 'PROCESSED'
         AND tai.khr_id = p_contract_id
         AND tld.khr_id = p_contract_id
         AND ractrl.customer_trx_id = aps.customer_trx_id
         AND raa.applied_customer_trx_id = aps.customer_trx_id
         AND aps.class = 'INV'
         AND raa.application_type IN ('CASH','CM')
         AND raa.status = 'APP'
         AND cra.receipt_date <= NVL(p_due_date, cra.receipt_date)
         AND raa.cash_receipt_id = cra.cash_receipt_id
         AND tld.sty_id = sty.id
         AND sty.stream_type_purpose IN ('PRINCIPAL_PAYMENT', 'UNSCHEDULED_PRINCIPAL_PAYMENT')
         AND to_char(tld.id) = ractrl.interface_line_attribute14
         AND tld.til_id_details = til.id
         AND til.tai_id = tai.id
         AND raa.receivable_application_id = ad.source_id
         AND ad.source_table = 'RA'
         AND ad.ref_customer_trx_Line_Id = ractrl.customer_trx_line_id
       GROUP BY cra.receipt_date
       UNION ALL
       SELECT cra.receipt_date receipt_date
              ,SUM(raa.line_applied) principal_pmt_rcpt_amt -- 4884843, 4872370
       FROM  okl_txd_ar_ln_dtls_b tld,
              ra_customer_trx_lines_all ractrl,
              okl_txl_ar_inv_lns_b til,
              okl_trx_ar_invoices_b tai,
              ar_payment_schedules_all aps,
              ar_receivable_applications_all raa,
              ar_cash_receipts_all cra,
              okl_strm_type_b sty
       WHERE tai.trx_status_code = 'PROCESSED'
         AND tai.khr_id = p_contract_id
         AND tld.khr_id = p_contract_id
         AND ractrl.customer_trx_id = aps.customer_trx_id
         AND raa.applied_customer_trx_id = aps.customer_trx_id
         AND aps.class = 'INV'
         AND raa.application_type IN ('CASH','CM')
         AND raa.status = 'APP'
         AND cra.receipt_date <= NVL(p_due_date, cra.receipt_date)
         AND raa.cash_receipt_id = cra.cash_receipt_id
         AND tld.sty_id = sty.id
         AND sty.stream_type_purpose IN ('PRINCIPAL_PAYMENT', 'UNSCHEDULED_PRINCIPAL_PAYMENT')
         AND to_char(tld.id) = ractrl.interface_line_attribute14
         AND tld.til_id_details = til.id
         AND til.tai_id = tai.id
         AND  EXISTS (SELECT 1
                      FROM ar_distributions_all ad
                      WHERE raa.receivable_application_id = ad.source_id
                      AND ad.source_table = 'RA'
                      AND ad.ref_customer_trx_Line_Id IS NULL)
       GROUP BY cra.receipt_date
       UNION
       SELECT ocb.termination_date receipt_date,
              sum(ocb.termination_value_amt) principal_pmt_rcpt_amt
       FROM   okl_contract_balances ocb
       WHERE  ocb.khr_id = p_contract_id
       AND    ocb.kle_id = NVL(p_line_id, kle_id)
       AND    ocb.termination_date BETWEEN p_start_date AND p_due_date
       GROUP BY ocb.termination_date
       UNION
        SELECT sel.stream_element_date receipt_date,
               sum(sel.amount) principal_pmt_rcpt_amt
        FROM
             okl_strm_elements sel
             ,okl_streams str
             ,okl_strm_type_v sty
            WHERE  sel.stm_id = str.id
              AND  str.khr_id = p_contract_id
              AND  str.kle_id = NVL(p_line_id, str.kle_id)
              AND  str.say_code = 'CURR'
              AND  str.active_yn = 'Y'
              AND  sel.stream_element_date BETWEEN p_start_date AND NVL(p_due_date, sel.stream_element_date)
              AND  str.sty_id = sty.id
              AND  sty.stream_type_purpose = 'PRINCIPAL_CATCHUP'
       GROUP BY sel.stream_element_date
       ORDER BY receipt_date asc;
-- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007

  Cursor rcpt_dtls_actual_strm_csr (p_contract_id NUMBER,
                              p_line_id     NUMBER,
                              p_start_date  DATE,
                              p_due_date    DATE) IS
        SELECT sel.stream_element_date receipt_date,
               sum(sel.amount) principal_pmt_rcpt_amt
        FROM
             okl_strm_elements sel
             ,okl_streams str
             ,okl_strm_type_v sty
            WHERE  sel.stm_id = str.id
              AND  str.khr_id = p_contract_id
              AND  str.kle_id = NVL(p_line_id, str.kle_id)
              AND  str.say_code = 'CURR'
              AND  str.active_yn = 'Y'
              AND  sel.stream_element_date <= NVL(p_due_date, sel.stream_element_date)
              AND  str.sty_id = sty.id
              AND  sty.stream_type_purpose = 'DAILY_INTEREST_PRINCIPAL'
       GROUP BY sel.stream_element_date
       ORDER BY receipt_date asc;


  BEGIN
    x_return_status     := OKL_API.G_RET_STS_SUCCESS;

    print_debug('Executing procedure PRIN_DATE_RANGE_VAR_INT_LOAN using following parameters : ');
    print_debug(' p_contract_id : '|| p_contract_id );
	print_debug(' p_line_id : '|| p_line_id );
    print_debug(' p_start_date : '|| to_char(p_start_date));
	print_debug(' p_due_date : '|| to_char(p_due_date));
	print_debug(' p_principal_basis : '|| p_principal_basis);

	Initialize_contract_params( p_api_version   => 1.0,
                                p_init_msg_list => OKL_API.G_FALSE,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_contract_id   => p_contract_id
                              );
    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS completed successfully');
    ELSIF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS returned unexpected error');
  	   print_error_message ('Procedure INITIALIZE_CONTRACT_PARAMS returned unexpected error');
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS returned exception');
	   print_error_message ('Procedure INITIALIZE_CONTRACT_PARAMS returned exception');
       RAISE prin_date_range_loan_failed;
    END IF;


	IF (p_principal_basis IS NOT NULL) THEN
      l_principal_basis := p_principal_basis;
    ELSE
/*
      OPEN principal_basis_csr (p_contract_id, l_effective_date);
      FETCH principal_basis_csr INTO l_principal_basis;
      IF principal_basis_csr%NOTFOUND THEN
       CLOSE principal_basis_csr;
       print_error_message (' Principal Basis not found for contract ID: '|| p_contract_id);
       RAISE prin_date_range_loan_failed;
      END IF;
      CLOSE principal_basis_csr;
*/
      l_principal_basis := G_PRINCIPAL_BASIS_CODE;
    END IF;


    print_debug('principal basis : '||l_principal_basis);
/*
    OPEN contract_csr (p_contract_id);
    FETCH contract_csr INTO l_contract_start_date, l_currency_code;
    IF (contract_csr%NOTFOUND) THEN
       CLOSE contract_csr;
       print_error_message('Contract Start Date not found for contract ID : '|| p_contract_id);
       RAISE prin_date_range_loan_failed;
    END IF;
    CLOSE contract_csr;
*/
--    l_contract_start_date := G_CONTRACT_START_DATE;
--	l_currency_code       := G_CURRENCY_CODE;

    print_debug('contract start date : '||G_CONTRACT_START_DATE );
	print_debug('currency code : '|| G_CURRENCY_CODE);

    IF (l_principal_basis = 'ACTUAL') THEN
/*
        -- Derive Principal Balance
        Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => 1.0,
                                        p_init_msg_list        => OKL_API.G_TRUE,
                                        x_return_status        => x_return_status,
                                        x_msg_count            => x_msg_count,
                                        x_msg_data             => x_msg_data,
                                        p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                        p_contract_id          => p_contract_id,
                                        p_line_id              => p_line_id,
                                        x_value               =>  l_principal_balance
                                       );

        IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
  	      print_debug ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE completed successfully');
        ELSIF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  	      print_debug ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned unexpected error');
  	      print_error_message ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned unexpected error');
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	      print_debug ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned exception');
	      print_error_message ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned exception');
          RAISE prin_date_range_loan_failed;
        END IF;
*/
      IF (p_line_id IS NULL) THEN
        get_contract_financed_amount (
            p_api_version       => 1.0,
            p_init_msg_list     => OKL_API.G_FALSE,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_contract_id       => p_contract_id,
			x_principal_balance => l_principal_balance);

        IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
  	      print_debug ('Procedure GET_CONTRACT_FINANCED_AMOUNT completed successfully');
        ELSIF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  	      print_debug ('Procedure GET_CONTRACT_FINANCED_AMOUNT returned unexpected error');
  	      print_error_message ('Procedure GET_CONTRACT_FINANCED_AMOUNT returned unexpected error');
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	      print_debug ('Procedure GET_CONTRACT_FINANCED_AMOUNT returned exception');
	      print_error_message ('Procedure GET_CONTRACT_FINANCED_AMOUNT returned exception');
          RAISE prin_date_range_loan_failed;
        END IF;
      ELSE
        get_asset_financed_amount (
            p_api_version       => 1.0,
            p_init_msg_list     => OKL_API.G_FALSE,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_contract_id       => p_contract_id,
            p_line_id           => p_line_id,
			x_principal_balance => l_principal_balance);

        IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
  	      print_debug ('Procedure GET_ASSET_FINANCED_AMOUNT completed successfully');
        ELSIF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  	      print_debug ('Procedure GET_ASSET_FINANCED_AMOUNT returned unexpected error');
  	      print_error_message ('Procedure GET_ASSET_FINANCED_AMOUNT returned unexpected error');
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	      print_debug ('Procedure GET_ASSET_FINANCED_AMOUNT returned exception');
	      print_error_message ('Procedure GET_ASSET_FINANCED_AMOUNT returned exception');
          RAISE prin_date_range_loan_failed;
        END IF;
      END IF;
    END IF;
    print_debug('principal balance : '||l_principal_balance);

    IF (l_principal_basis = 'SCHEDULED') THEN
          IF (p_line_id IS NOT NULL) THEN
             print_debug('Stream Element Date : '|| to_char(p_start_date));

             OPEN sch_asset_prin_balance_csr (p_contract_id, p_line_id, p_start_date);
             FETCH sch_asset_prin_balance_csr INTO l_principal_balance;
             IF (sch_asset_prin_balance_csr%NOTFOUND) THEN
                CLOSE sch_asset_prin_balance_csr;
                print_error_message('Scheduled Asset Principal Balance stream cursor did not return records for contract ID :' || p_contract_id);
                RAISE prin_date_range_loan_failed;
             END IF;
             CLOSE sch_asset_prin_balance_csr;

             print_debug(' Principal Balance : '|| l_principal_balance);

          ELSE
             print_debug('Stream Element Date : '|| to_char(p_start_date));

             OPEN sch_ctr_prin_balance_csr (p_contract_id, p_start_date);
             FETCH sch_ctr_prin_balance_csr INTO l_principal_balance;
             IF (sch_ctr_prin_balance_csr%NOTFOUND) THEN
               CLOSE sch_ctr_prin_balance_csr;
               print_error_message('Scheduled Contract Principal Balance cursor did not return records for contract ID :' || p_contract_id);
               RAISE prin_date_range_loan_failed;
             END IF;
             CLOSE sch_ctr_prin_balance_csr;

             print_debug(' Principal Balance : '|| l_principal_balance);
          END IF;

          l_counter := l_counter + 1;
          l_principal_balance_tbl(l_counter).khr_id                 := p_contract_id;

          IF (p_line_id IS NOT NULL) THEN
             l_principal_balance_tbl(l_counter).kle_id              := p_line_id;
          ELSE
             l_principal_balance_tbl(l_counter).kle_id              := NULL;
          END IF;
          l_principal_balance_tbl(l_counter).from_date             := p_start_date;
          l_principal_balance_tbl(l_counter).to_date               := p_due_date;
          l_principal_balance_tbl(l_counter).principal_balance      := l_principal_balance;

    ELSIF (l_principal_basis = 'ACTUAL') THEN

--       l_revenue_recognition := G_REVENUE_RECOGNITION_METHOD;
--	   l_interest_calc_basis := G_INTEREST_CALCULATION_BASIS;

       print_debug('revenue recognition method : '|| G_REVENUE_RECOGNITION_METHOD);
       print_debug('Interest calculation basis: '|| G_INTEREST_CALCULATION_BASIS);
       l_counter := 0;

	   IF (G_REVENUE_RECOGNITION_METHOD <> 'ACTUAL') THEN
          FOR current_receipt in receipt_details_csr (p_contract_id, p_line_id, G_CONTRACT_START_DATE, p_due_date)
          LOOP
             l_counter                                       := l_counter + 1;
             l_receipt_tbl(l_counter).khr_id                 := p_contract_id;
             l_receipt_tbl(l_counter).kle_id                 := p_line_id;
             l_receipt_tbl(l_counter).receipt_date           := current_receipt.receipt_date;
             l_receipt_tbl(l_counter).principal_pmt_rcpt_amt := current_receipt.principal_pmt_rcpt_amt;
             l_receipt_tbl(l_counter).loan_pmt_rcpt_amt      := 0;
          END LOOP;
       ELSE
          FOR current_receipt in rcpt_dtls_actual_strm_csr(p_contract_id, p_line_id, G_CONTRACT_START_DATE, p_due_date)
          LOOP
             l_counter                                       := l_counter + 1;
             l_receipt_tbl(l_counter).khr_id                 := p_contract_id;
             l_receipt_tbl(l_counter).kle_id                 := p_line_id;
             l_receipt_tbl(l_counter).receipt_date           := current_receipt.receipt_date;
             l_receipt_tbl(l_counter).principal_pmt_rcpt_amt := current_receipt.principal_pmt_rcpt_amt;
             l_receipt_tbl(l_counter).loan_pmt_rcpt_amt      := 0;
          END LOOP;
        END IF;

        -- Records before Consolidation
        l_counter := 0;
        l_rcpt_tbl_count := l_receipt_tbl.COUNT;

		Print_debug ('Contents of Receipts table before consolidation');

		FOR l_counter IN 1 .. l_rcpt_tbl_count
		LOOP
		  Print_debug('Record Number : '||l_counter);
		  Print_debug('Contract : '||l_receipt_tbl(l_counter).khr_id);
		  Print_debug('Line : '||l_receipt_tbl(l_counter).kle_id);
		  Print_debug('Receipt Date: '|| l_receipt_tbl(l_counter).receipt_date);
		  Print_debug('Principal Payment: '|| l_receipt_tbl(l_counter).principal_pmt_rcpt_amt);
		  Print_debug(' ');
		END LOOP;

		-- Consolidate the receipts posted after contract start date
        l_counter        := 0;
        l_rcpt_tbl_count := l_receipt_tbl.COUNT;
        l_previous_receipt_date  := NULL;
        lx_receipt_tbl.delete;

        FOR l_receipt_tbl_counter in 1 .. l_rcpt_tbl_count
        LOOP
          IF (l_receipt_tbl(l_receipt_tbl_counter).receipt_date <= G_CONTRACT_START_DATE) THEN
            l_counter                                        := l_counter + 1;
            lx_receipt_tbl(l_counter).khr_id                 := l_receipt_tbl(l_receipt_tbl_counter).khr_id;
            lx_receipt_tbl(l_counter).kle_id                 := l_receipt_tbl(l_receipt_tbl_counter).kle_id;
            lx_receipt_tbl(l_counter).receipt_date           := l_receipt_tbl(l_receipt_tbl_counter).receipt_date;
            lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
            lx_receipt_tbl(l_counter).loan_pmt_rcpt_amt      := l_receipt_tbl(l_receipt_tbl_counter).loan_pmt_rcpt_amt;
          ELSE
            IF (l_receipt_tbl(l_receipt_tbl_counter).receipt_date = l_previous_receipt_date ) THEN
              lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt + l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
              lx_receipt_tbl(l_counter).loan_pmt_rcpt_amt      := lx_receipt_tbl(l_counter).loan_pmt_rcpt_amt + l_receipt_tbl(l_receipt_tbl_counter).loan_pmt_rcpt_amt;
            ELSE
              l_counter                                        := l_counter + 1;
              lx_receipt_tbl(l_counter).khr_id                 := l_receipt_tbl(l_receipt_tbl_counter).khr_id;
              lx_receipt_tbl(l_counter).kle_id                 := l_receipt_tbl(l_receipt_tbl_counter).kle_id;
              lx_receipt_tbl(l_counter).receipt_date           := l_receipt_tbl(l_receipt_tbl_counter).receipt_date;
              lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
              lx_receipt_tbl(l_counter).loan_pmt_rcpt_amt      := l_receipt_tbl(l_receipt_tbl_counter).loan_pmt_rcpt_amt;
              l_previous_receipt_date :=  lx_receipt_tbl(l_counter).receipt_date;
            END IF;
          END IF;
        END LOOP;
        l_receipt_tbl := lx_receipt_tbl;


        -- Records after Consolidation
        l_counter := 0;
        l_rcpt_tbl_count := l_receipt_tbl.COUNT;

		Print_debug ('Contents of Receipts table after consolidation');

		FOR l_counter IN 1 .. l_rcpt_tbl_count
		LOOP
		  Print_debug('Record Number : '||l_counter);
		  Print_debug('Contract : '||l_receipt_tbl(l_counter).khr_id);
		  Print_debug('Line : '||l_receipt_tbl(l_counter).kle_id);
		  Print_debug('Receipt Date: '|| l_receipt_tbl(l_counter).receipt_date);
		  Print_debug('Principal Payment: '|| l_receipt_tbl(l_counter).principal_pmt_rcpt_amt);
		  Print_debug(' ');
		END LOOP;

        -- Process the receipts
        l_counter        := 0;
        l_rcpt_tbl_count := l_receipt_tbl.COUNT;
        lx_receipt_tbl.delete;

        FOR l_receipt_tbl_counter in 1 .. l_rcpt_tbl_count
        LOOP
          IF (l_receipt_tbl(l_receipt_tbl_counter).receipt_date <= G_CONTRACT_START_DATE) THEN
              l_principal_balance := l_principal_balance - l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
          ELSE
            l_counter                                        := l_counter + 1;
            lx_receipt_tbl(l_counter).khr_id                 := l_receipt_tbl(l_receipt_tbl_counter).khr_id;
            lx_receipt_tbl(l_counter).kle_id                 := l_receipt_tbl(l_receipt_tbl_counter).kle_id;
            lx_receipt_tbl(l_counter).receipt_date           := l_receipt_tbl(l_receipt_tbl_counter).receipt_date;
            lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
            lx_receipt_tbl(l_counter).loan_pmt_rcpt_amt      := l_receipt_tbl(l_receipt_tbl_counter).loan_pmt_rcpt_amt;
          END IF;
        END LOOP;

       l_receipt_tbl    := lx_receipt_tbl;
       l_start_date     := G_CONTRACT_START_DATE;
       l_counter        := 0;
       l_rcpt_tbl_count := l_receipt_tbl.COUNT;

       print_debug('No. of Consolidated Receipts after contract start date: '|| l_rcpt_tbl_count);

       IF (l_rcpt_tbl_count > 0) THEN
          l_rcpt_tbl_index := l_receipt_tbl.FIRST;
       END IF;

       FOR l_rcpt_tbl_counter in 1 .. l_rcpt_tbl_count
       LOOP
          l_counter := l_counter + 1;
          l_principal_balance_tbl(l_counter).khr_id := p_contract_id;
          IF (p_line_id IS NOT NULL) THEN
             l_principal_balance_tbl(l_counter).kle_id := p_line_id;
          ELSE
             l_principal_balance_tbl(l_counter).kle_id := NULL;
          END IF;

          l_principal_balance_tbl(l_counter).from_date := l_start_date;

          l_receipt_date := l_receipt_tbl(l_rcpt_tbl_index).receipt_date;

          l_principal_balance_tbl(l_counter).to_date   := l_receipt_tbl(l_rcpt_tbl_index).receipt_date - 1;
          l_principal_balance_tbl(l_counter).principal_balance := l_principal_balance;
          l_principal_balance := l_principal_balance - l_receipt_tbl(l_rcpt_tbl_index).principal_pmt_rcpt_amt;
          l_start_date := l_receipt_tbl(l_rcpt_tbl_index).receipt_date;
          l_rcpt_tbl_index := l_receipt_tbl.NEXT(l_rcpt_tbl_index);

       END LOOP;

       l_counter := l_counter + 1;
       l_principal_balance_tbl(l_counter).khr_id := p_contract_id;
       IF (p_line_id IS NOT NULL) THEN
          l_principal_balance_tbl(l_counter).kle_id := p_line_id;
       ELSE
          l_principal_balance_tbl(l_counter).kle_id := NULL;
       END IF;
       l_principal_balance_tbl(l_counter).from_date := l_start_date;
       l_principal_balance_tbl(l_counter).to_date   := p_due_date;
       l_principal_balance_tbl(l_counter).principal_balance := l_principal_balance;

    END IF;

    l_counter := l_principal_balance_tbl.first;
    LOOP
      EXIT WHEN l_counter IS NULL;
      IF ((p_start_date >= l_principal_balance_tbl(l_counter).from_date AND p_start_date <= l_principal_balance_tbl(l_counter).to_date) OR
          (p_due_date >= l_principal_balance_tbl(l_counter).from_date AND p_due_date <= l_principal_balance_tbl(l_counter).to_date) OR
          (l_principal_balance_tbl(l_counter).from_date >= p_start_date AND l_principal_balance_tbl(l_counter).to_date <= p_due_date)) THEN
        l_counter_tmp := l_counter_tmp + 1;
        l_principal_balance_tbl_tmp(l_counter_tmp) := l_principal_balance_tbl(l_counter);
        l_principal_balance_tbl_tmp(l_counter_tmp).from_date := GREATEST(l_principal_balance_tbl_tmp(l_counter_tmp).from_date, p_start_date);
        l_principal_balance_tbl_tmp(l_counter_tmp).to_date := LEAST(l_principal_balance_tbl_tmp(l_counter_tmp).to_date, p_due_date);
      END IF;
      l_counter := l_principal_balance_tbl.next(l_counter);
    END LOOP;

    x_principal_balance_tbl := l_principal_balance_tbl_tmp;

    print_principal_date_range_tbl (x_principal_balance_tbl);

  EXCEPTION
     WHEN prin_date_range_loan_failed THEN
       print_error_message('prin_date_range_loan_failed Exception Raised in procedure PRIN_DATE_RANGE_VAR_INT_LOAN ');
       x_return_status := OKL_API.G_RET_STS_ERROR;
     WHEN OTHERS THEN
       print_error_message('Exception Raised in procedure PRIN_DATE_RANGE_VAR_INT_LOAN ');
       Okl_Api.SET_MESSAGE(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_UNEXPECTED_ERROR,
               p_token1       => G_SQLCODE_TOKEN,
               p_token1_value => SQLCODE,
               p_token2       => G_SQLERRM_TOKEN,
               p_token2_value => SQLERRM);
       x_return_status := OKL_API.G_RET_STS_ERROR;
  END prin_date_range_var_int_loan;

------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    prin_date_range_var_int_rloan
    -- Description:      This procedure is called by Variable Interest Calculation for Revolving Loans
    --                   Returns a PL/SQL table of records with following entries Start Date, End Date,
    --                   and Principal Balance
    -- Dependencies:
    -- Parameters:       contract id, date.
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  PROCEDURE prin_date_range_var_int_rloan (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_line_id            IN  NUMBER,
            p_start_date         IN DATE,
            p_due_date           IN  DATE,
            x_principal_balance_tbl OUT NOCOPY principal_balance_tbl_typ)   IS

  l_api_name                    CONSTANT    VARCHAR2(30) := 'PRIN_DATE_RANGE_VAR_INT_RLOAN';
  l_api_version                 CONSTANT    NUMBER       := 1.0;
  l_principal_balance_tbl       principal_balance_tbl_typ ;
  l_principal_balance_tbl_tmp   principal_balance_tbl_typ ;
--  l_contract_start_date         DATE;
  l_start_date                  DATE;
  l_principal_balance           NUMBER;
  l_counter                     NUMBER := 0;
  l_counter_tmp                 NUMBER := 0;
--  l_currency_code               OKL_K_HEADERS_FULL_V.currency_code%TYPE;
--  l_revenue_recognition         OKL_PRODUCT_PARAMETERS_V.revenue_recognition_method%TYPE;
  l_current_txn_date            DATE;
  prin_date_range_rloan_failed EXCEPTION;
  l_receipt_tbl                receipt_tbl_type;
  lx_receipt_tbl               receipt_tbl_type;
  l_previous_receipt_date      DATE;
  l_rcpt_tbl_count             NUMBER := 0;
  l_rcpt_tbl_counter           NUMBER := 0;

/*
  Cursor contract_csr (p_contract_id NUMBER) IS
      SELECT start_date, currency_code
      FROM   okl_k_headers_full_v
      WHERE  id = p_contract_id;

  Cursor revenue_recognition_csr (p_contract_id NUMBER) IS
      SELECT ppm.revenue_recognition_method
      FROM   okl_k_headers khr,
             okl_product_parameters_v ppm
       WHERE khr.pdt_id = ppm.id
         AND khr.id = p_contract_id;
*/

  -- sjalasut, modified the cursor to have khr_id referred from
  -- okl_txl_ap_inv_lns_all_b
  Cursor pymt_rcpt_actual_var_int_csr (p_contract_id    NUMBER,
                                       p_due_date       DATE) IS
    SELECT iph.check_date txn_date,
           sum(iph.amount) txn_amount,
           'P' txn_type
    FROM ap_invoices_all ap_inv,
         okl_trx_ap_invoices_v okl_inv,
         ap_invoice_payment_history_v iph
         ,okl_cnsld_ap_invs_all cnsld
         ,okl_txl_ap_inv_lns_all_b okl_inv_ln
         ,fnd_application fnd_app
    WHERE okl_inv.id = okl_inv_ln.tap_id
      AND okl_inv_ln.khr_id = p_contract_id
      AND ap_inv.application_id = fnd_app.application_id
      AND fnd_app.application_short_name = 'OKL'
      AND okl_inv_ln.cnsld_ap_inv_id = cnsld.cnsld_ap_inv_id
      AND cnsld.cnsld_ap_inv_id = to_number(ap_inv.reference_key1)
      AND okl_inv.funding_type_code = 'BORROWER_PAYMENT'
      AND ap_inv.invoice_id = iph.invoice_id
      AND iph.check_date <= NVL(p_due_date, iph.check_date)
    GROUP BY iph.check_date
UNION
        SELECT sel.stream_element_date txn_date,
               sum(sel.amount) txn_amount,
               'R' txn_type
        FROM
             okl_strm_elements sel
             ,okl_streams str
             ,okl_strm_type_v sty
            WHERE  sel.stm_id = str.id
              AND  str.khr_id = p_contract_id
              AND  str.say_code = 'CURR'
              AND  str.active_yn = 'Y'
              AND  sel.stream_element_date <= NVL(p_due_date, sel.stream_element_date)
              AND  str.sty_id = sty.id
              AND  sty.stream_type_purpose = 'DAILY_INTEREST_PRINCIPAL'
       GROUP BY sel.stream_element_date
    ORDER BY txn_date asc, txn_type;

  -- sjalasut, modified the cursor to have khr_id referred from okl_txl_Ap_inv_lns_all_b
  -- Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
    Cursor pymt_rcpt_est_bill_var_int_csr (p_contract_id    NUMBER,
                                         p_due_date       DATE) IS
    SELECT iph.check_date txn_date,
           sum(iph.amount) txn_amount,
           'P' txn_type
    FROM ap_invoices_all ap_inv,
         okl_trx_ap_invoices_v okl_inv,
         ap_invoice_payment_history_v iph
         ,okl_cnsld_ap_invs_all cnsld
         ,okl_txl_ap_inv_lns_all_b okl_inv_ln
         ,fnd_application fnd_app
    WHERE okl_inv.id = okl_inv_ln.tap_id
      AND okl_inv_ln.khr_id = p_contract_id
      AND ap_inv.application_id = fnd_app.application_id
      AND fnd_app.application_short_name = 'OKL'
      AND okl_inv_ln.cnsld_ap_inv_id = cnsld.cnsld_ap_inv_id
      AND cnsld.cnsld_ap_inv_id = to_number(ap_inv.reference_key1)
      AND okl_inv.funding_type_code = 'BORROWER_PAYMENT'
      AND ap_inv.invoice_id = iph.invoice_id
      AND iph.check_date <= NVL(p_due_date, iph.check_date)
    GROUP BY iph.check_date
UNION
    SELECT cra.receipt_date txn_date,
           sum(raa.line_applied) txn_amount, -- 4884843, 4872370
           'R' txn_type
    FROM   okl_bpd_tld_ar_lines_v tld,
           ar_payment_schedules_all aps,
           ar_receivable_applications_all raa,
           ar_cash_receipts_all cra,
           okl_strm_type_v sty
    WHERE  tld.trx_status_code = 'PROCESSED'
      AND  tld.khr_id = NVL(p_contract_id, tld.khr_id)
      AND  tld.customer_trx_id = aps.customer_trx_id
      AND  raa.applied_customer_trx_id = aps.customer_trx_id
      AND  aps.class = 'INV'
      AND  (raa.application_type = 'CASH' or raa.application_type = 'CM')
      AND  raa.status = 'APP'
      AND  cra.receipt_date <= NVL(p_due_date, cra.receipt_date)
      AND  raa.cash_receipt_id = cra.cash_receipt_id
      AND  tld.sty_id = sty.id
      AND  sty.stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT'
    GROUP BY cra.receipt_date
    ORDER BY txn_date asc, txn_type;
-- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007


  BEGIN
    x_return_status     := OKL_API.G_RET_STS_SUCCESS;

    print_debug('Executing procedure PRIN_DATE_RANGE_VAR_INT_RLOAN using following parameters : ');
    print_debug(' p_contract_id : '|| p_contract_id);
	print_debug(' p_line_id : '|| p_line_id );
	print_debug(' p_due_date : '|| to_char(p_due_date));

	Initialize_contract_params( p_api_version   => 1.0,
                                p_init_msg_list => OKL_API.G_FALSE,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_contract_id   => p_contract_id
                              );
    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS completed successfully');
    ELSIF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS returned unexpected error');
  	   print_error_message ('Procedure INITIALIZE_CONTRACT_PARAMS returned unexpected error');
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS returned exception');
	   print_error_message ('Procedure INITIALIZE_CONTRACT_PARAMS returned exception');
       RAISE prin_date_range_rloan_failed;
    END IF;
/*
    OPEN contract_csr (p_contract_id);
    FETCH contract_csr INTO l_contract_start_date, l_currency_code;
    IF (contract_csr%NOTFOUND) THEN
      CLOSE contract_csr;
      print_error_message('Contract Cursor did not return records for contract ID :' || p_contract_id);
      RAISE prin_date_range_rloan_failed;
    END IF;
    CLOSE contract_csr;

    OPEN revenue_recognition_csr (p_contract_id);
    FETCH revenue_recognition_csr INTO l_revenue_recognition;
    IF revenue_recognition_csr%NOTFOUND THEN
      CLOSE revenue_recognition_csr;
      print_error_message('Revenue Recognition cursor did not return records for contract ID :' || p_contract_id);
      RAISE prin_date_range_rloan_failed;
    END IF;
    CLOSE revenue_recognition_csr;
*/

    print_debug('contract start date : '||G_CONTRACT_START_DATE );
	print_debug('currency code : '|| G_CURRENCY_CODE);
	print_debug ('Revenue Recognition method : '|| G_REVENUE_RECOGNITION_METHOD);

    l_counter              := 0;

    IF (G_REVENUE_RECOGNITION_METHOD = 'ACTUAL') THEN
      FOR current_txn in pymt_rcpt_actual_var_int_csr (p_contract_id, p_due_date)
      LOOP
        l_counter                                       := l_counter + 1;
        l_receipt_tbl(l_counter).khr_id                 := p_contract_id;
        l_receipt_tbl(l_counter).kle_id                 := NULL;
        l_receipt_tbl(l_counter).receipt_date           := current_txn.txn_date;
        l_receipt_tbl(l_counter).transaction_type       := current_txn.txn_type;
        l_receipt_tbl(l_counter).principal_pmt_rcpt_amt := current_txn.txn_amount;
        l_receipt_tbl(l_counter).loan_pmt_rcpt_amt      := 0;
      END LOOP;
    ELSE
      FOR current_txn in pymt_rcpt_est_bill_var_int_csr (p_contract_id, p_due_date)
      LOOP
        l_counter                                       := l_counter + 1;
        l_receipt_tbl(l_counter).khr_id                 := p_contract_id;
        l_receipt_tbl(l_counter).kle_id                 := NULL;
        l_receipt_tbl(l_counter).receipt_date           := current_txn.txn_date;
        l_receipt_tbl(l_counter).transaction_type       := current_txn.txn_type;
        l_receipt_tbl(l_counter).principal_pmt_rcpt_amt := current_txn.txn_amount;
        l_receipt_tbl(l_counter).loan_pmt_rcpt_amt      := 0;
      END LOOP;
    END IF;

    l_counter        := 0;
    l_rcpt_tbl_count := l_receipt_tbl.COUNT;

    Print_debug ('Contents of Receipts table before consolidation');

	FOR l_counter IN 1 .. l_rcpt_tbl_count
	LOOP
	  Print_debug('Record Number : '||l_counter);
	  Print_debug('Contract : '||l_receipt_tbl(l_counter).khr_id);
	  Print_debug('Receipt Date: '|| l_receipt_tbl(l_counter).receipt_date);
	  Print_debug('Type : '|| l_receipt_tbl(l_counter).transaction_type);
	  Print_debug('Principal Payment: '|| l_receipt_tbl(l_counter).principal_pmt_rcpt_amt);
	  Print_debug(' ');
	END LOOP;

	-- Consolidate the receipts posted after contract start date
    l_counter        := 0;
    l_rcpt_tbl_count := l_receipt_tbl.COUNT;
    l_previous_receipt_date  := NULL;
    lx_receipt_tbl.delete;

    FOR l_receipt_tbl_counter in 1 .. l_rcpt_tbl_count
    LOOP
      IF (l_receipt_tbl(l_receipt_tbl_counter).receipt_date <= G_CONTRACT_START_DATE) THEN
        l_counter                                        := 1;
        lx_receipt_tbl(l_counter).khr_id                 := l_receipt_tbl(l_receipt_tbl_counter).khr_id;
        lx_receipt_tbl(l_counter).receipt_date           := G_CONTRACT_START_DATE;
        IF (l_receipt_tbl(l_receipt_tbl_counter).transaction_type = 'P') THEN
          IF (nvl(lx_receipt_tbl(l_counter).transaction_type, 'P') = 'P') THEN
            lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := nvl(lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt,0) + l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
          ELSE
            lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := -1 * nvl(lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt,0) + l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
          END IF;
        ELSE -- 'R'
          IF (nvl(lx_receipt_tbl(l_counter).transaction_type, 'P') = 'P') THEN
            lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := nvl(lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt,0) - l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
          ELSE
            lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := -1 * nvl(lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt,0) - l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
          END IF;
        END IF;

		IF (lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt > 0) THEN
		  lx_receipt_tbl(l_counter).transaction_type := 'P';
		ELSE
		  lx_receipt_tbl(l_counter).transaction_type := 'R';
		  lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := abs(lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt);
		END IF;
      ELSE  -- receipt date > contract start date
        IF (l_receipt_tbl(l_receipt_tbl_counter).receipt_date = l_previous_receipt_date ) THEN
          IF (l_receipt_tbl(l_receipt_tbl_counter).transaction_type = 'P') THEN
            IF (nvl(lx_receipt_tbl(l_counter).transaction_type, 'P') = 'P') THEN
              lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := nvl(lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt,0) + l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
            ELSE
              lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := -1 * nvl(lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt,0) + l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
            END IF;
          ELSE -- transaction type = 'R'
            IF (nvl(lx_receipt_tbl(l_counter).transaction_type, 'P') = 'P') THEN
              lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := nvl(lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt,0) - l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
            ELSE
              lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := -1 * nvl(lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt,0) - l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
            END IF;
          END IF;

		  IF (lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt > 0) THEN
		    lx_receipt_tbl(l_counter).transaction_type := 'P';
		  ELSE
		    lx_receipt_tbl(l_counter).transaction_type := 'R';
		    lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := abs(lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt);
		  END IF;
        ELSE  -- receipt date <> previous receipt date
          l_counter                                        := l_counter + 1;
          lx_receipt_tbl(l_counter).khr_id                 := l_receipt_tbl(l_receipt_tbl_counter).khr_id;
          lx_receipt_tbl(l_counter).receipt_date           := l_receipt_tbl(l_receipt_tbl_counter).receipt_date;
          lx_receipt_tbl(l_counter).transaction_type       := l_receipt_tbl(l_receipt_tbl_counter).transaction_type;
          lx_receipt_tbl(l_counter).principal_pmt_rcpt_amt := l_receipt_tbl(l_receipt_tbl_counter).principal_pmt_rcpt_amt;
          l_previous_receipt_date :=  lx_receipt_tbl(l_counter).receipt_date;
        END IF;
      END IF;
    END LOOP;
    l_receipt_tbl := lx_receipt_tbl;

    l_counter        := 0;
    l_rcpt_tbl_count := l_receipt_tbl.COUNT;

    Print_debug ('Contents of Receipts table after consolidation');

	FOR l_counter IN 1 .. l_rcpt_tbl_count
	LOOP
	  Print_debug('Record Number : '||l_counter);
	  Print_debug('Contract : '||l_receipt_tbl(l_counter).khr_id);
	  Print_debug('Receipt Date: '|| l_receipt_tbl(l_counter).receipt_date);
	  Print_debug('Type : '|| l_receipt_tbl(l_counter).transaction_type);
	  Print_debug('Principal Payment: '|| l_receipt_tbl(l_counter).principal_pmt_rcpt_amt);
	  Print_debug(' ');
	END LOOP;

    l_counter              := 0;
    l_start_date           := G_CONTRACT_START_DATE;
    l_principal_balance    := 0;
    l_current_txn_date     := NULL;
    l_rcpt_tbl_count := l_receipt_tbl.COUNT;

    FOR l_rcpt_tbl_counter IN 1 .. l_rcpt_tbl_count
    LOOP
      l_current_txn_date := l_receipt_tbl(l_rcpt_tbl_counter).receipt_date;
      IF (l_current_txn_date > G_CONTRACT_START_DATE) THEN
        l_counter          := l_counter + 1;
--        l_current_txn_date := l_receipt_tbl(l_rcpt_tbl_counter).receipt_date;
        l_principal_balance_tbl(l_counter).khr_id     := p_contract_id;
        l_principal_balance_tbl(l_counter).kle_id     := NULL;
        l_principal_balance_tbl(l_counter).from_date := l_start_date;
        l_principal_balance_tbl(l_counter).to_date   := l_current_txn_date - 1;
        l_principal_balance_tbl(l_counter).principal_balance      := l_principal_balance;
        l_start_date := l_current_txn_date;

        IF (l_receipt_tbl(l_rcpt_tbl_counter).transaction_type = 'P') THEN
          l_principal_balance := l_principal_balance + l_receipt_tbl(l_rcpt_tbl_counter).principal_pmt_rcpt_amt;
        ELSE
          l_principal_balance := l_principal_balance - l_receipt_tbl(l_rcpt_tbl_counter).principal_pmt_rcpt_amt;
        END IF;
        print_debug ('l_principal_balance_tbl(l_counter).khr_id : '|| l_principal_balance_tbl(l_counter).khr_id);
        print_debug ('l_principal_balance_tbl(l_counter).from_date : '|| l_principal_balance_tbl(l_counter).from_date);
        print_debug ('l_principal_balance_tbl(l_counter).to_date : '|| l_principal_balance_tbl(l_counter).to_date);
        print_debug ('l_principal_balance_tbl(l_counter).principal_balance : '|| l_principal_balance_tbl(l_counter).principal_balance);

      ELSE
        l_principal_balance := l_principal_balance + l_receipt_tbl(l_rcpt_tbl_counter).principal_pmt_rcpt_amt;
      END IF;

    END LOOP;

    l_counter                                              := l_counter + 1;
    l_principal_balance_tbl(l_counter).khr_id              := p_contract_id;
    l_principal_balance_tbl(l_counter).kle_id              := NULL;
    l_principal_balance_tbl(l_counter).from_date           := l_start_date;
    l_principal_balance_tbl(l_counter).to_date             := p_due_date;
    l_principal_balance_tbl(l_counter).principal_balance   := l_principal_balance;

    print_debug ('l_principal_balance_tbl(l_counter).khr_id : '|| l_principal_balance_tbl(l_counter).khr_id);
    print_debug ('l_principal_balance_tbl(l_counter).from_date : '|| l_principal_balance_tbl(l_counter).from_date);
    print_debug ('l_principal_balance_tbl(l_counter).to_date : '|| l_principal_balance_tbl(l_counter).to_date);
    print_debug ('l_principal_balance_tbl(l_counter).principal_balance : '|| l_principal_balance_tbl(l_counter).principal_balance);


    l_counter := l_principal_balance_tbl.first;
    LOOP
      EXIT WHEN l_counter IS NULL;
      IF ((p_start_date >= l_principal_balance_tbl(l_counter).from_date AND p_start_date <= l_principal_balance_tbl(l_counter).to_date) OR
          (p_due_date >= l_principal_balance_tbl(l_counter).from_date AND p_due_date <= l_principal_balance_tbl(l_counter).to_date) OR
          (l_principal_balance_tbl(l_counter).from_date >= p_start_date AND l_principal_balance_tbl(l_counter).to_date <= p_due_date)) THEN
        l_counter_tmp := l_counter_tmp + 1;
        l_principal_balance_tbl_tmp(l_counter_tmp) := l_principal_balance_tbl(l_counter);
        l_principal_balance_tbl_tmp(l_counter_tmp).from_date := GREATEST(l_principal_balance_tbl_tmp(l_counter_tmp).from_date, p_start_date);
        l_principal_balance_tbl_tmp(l_counter_tmp).to_date := LEAST(l_principal_balance_tbl_tmp(l_counter_tmp).to_date, p_due_date);
      END IF;
      l_counter := l_principal_balance_tbl.next(l_counter);
    END LOOP;

    x_principal_balance_tbl := l_principal_balance_tbl_tmp;

    print_principal_date_range_tbl (x_principal_balance_tbl);

  EXCEPTION
     WHEN prin_date_range_rloan_failed THEN
       print_error_message('print_date_range_rloan_failed Exception raised inside procedure PRIN_DATE_RANGE_VAR_INT_RLOAN');
       x_return_status := OKL_API.G_RET_STS_ERROR;

     WHEN OTHERS THEN
       print_error_message('Exception raised inside procedure PRIN_DATE_RANGE_VAR_INT_RLOAN');
       Okl_Api.SET_MESSAGE(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_UNEXPECTED_ERROR,
               p_token1       => G_SQLCODE_TOKEN,
               p_token1_value => SQLCODE,
               p_token2       => G_SQLERRM_TOKEN,
               p_token2_value => SQLERRM);

       x_return_status := OKL_API.G_RET_STS_ERROR;

  END prin_date_range_var_int_rloan;

  ------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    prin_date_range_var_int_rl_old
    -- Description:      This procedure is called by Variable Interest Calculation for Revolving Loans
    --                   Returns a PL/SQL table of records with following entries Start Date, End Date,
    --                   and Principal Balance
    -- Dependencies:
    -- Parameters:       contract id, date.
    -- Version:          1.0
    --                   2.0 - Obsoleted this local procedure as part of Billing Inline changes- Bug#5898792 - varangan - 23/2/2007
    -- End of Comments

------------------------------------------------------------------------------

------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    prin_date_range_var_rate_ctr
    -- Description:      This procedure is called by Variable Interest Calculation
    --                   Returns a PL/SQL table of records with following entries Start Date, End Date,
    --                   and Principal Balance
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  PROCEDURE prin_date_range_var_rate_ctr (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_line_id            IN  NUMBER,
            p_start_date         IN  DATE,
            p_due_date           IN  DATE,
            p_principal_basis    IN  VARCHAR2 DEFAULT NULL,
            x_principal_balance_tbl OUT NOCOPY  principal_balance_tbl_typ)   IS

  l_api_name               CONSTANT    VARCHAR2(30) := 'PRIN_DATE_RANGE_VAR_RATE_CTR';
  l_api_version            CONSTANT    NUMBER       := 1.0;
  r_principal_balance_tbl  principal_balance_tbl_typ ;
  l_deal_type              OKL_K_HEADERS_FULL_V.deal_type%TYPE;
  prin_date_range_failed   EXCEPTION;


  Cursor contract_csr (p_contract_id NUMBER) IS
      SELECT deal_type
      FROM   okl_k_headers_full_v
      WHERE  id = p_contract_id;


  BEGIN
    x_return_status     := OKL_API.G_RET_STS_SUCCESS;

    print_debug('Executing procedure PRIN_DATE_RANGE_VAR_RATE_CTR using following parameters : ');
    print_debug(' p_contract_id : '|| p_contract_id );
	print_debug(' p_line_id : '|| p_line_id );
	print_debug(' p_start_date : '|| to_char(p_start_date));
	print_debug(' p_due_date : '|| to_char(p_due_date));

	print_debug(' G_CONTRACT_ID : '|| G_CONTRACT_ID );

    IF (p_contract_id = G_CONTRACT_ID) THEN
      l_deal_type := G_DEAL_TYPE;
    ELSE
      OPEN contract_csr (p_contract_id);
      FETCH contract_csr INTO l_deal_type;
      IF (contract_csr%NOTFOUND) THEN
        CLOSE contract_csr;
        print_error_message('Contract cursor did not return records for contract ID :' || p_contract_id);
        RAISE prin_date_range_failed;
      END IF;
      CLOSE contract_csr;
    END IF;

    print_debug('deal type : '|| l_deal_type);

    IF (l_deal_type = 'LOAN') THEN
       prin_date_range_var_int_loan (
                                     p_api_version           => 1.0,
                                     p_init_msg_list         => OKL_API.G_FALSE,
                                     x_return_status         => x_return_status,
                                     x_msg_count             => x_msg_count,
                                     x_msg_data              => x_msg_data,
                                     p_contract_id           => p_contract_id,
                                     p_line_id               => p_line_id,
                                     p_start_date            => p_start_date,
                                     p_due_date              => p_due_date,
                                     p_principal_basis       => p_principal_basis,
                                     x_principal_balance_tbl => r_principal_balance_tbl);

       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         print_error_message('Unexpected error raised in call to PRIN_DATE_RANGE_VAR_INT_LOAN');
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         print_error_message('Error raised in call to PRIN_DATE_RANGE_VAR_INT_LOAN');
         RAISE prin_date_range_failed;
       END IF;

    ELSIF (l_deal_type = 'LOAN-REVOLVING') THEN
       prin_date_range_var_int_rloan (
                                     p_api_version           => 1.0,
                                     p_init_msg_list         => OKL_API.G_FALSE,
                                     x_return_status         => x_return_status,
                                     x_msg_count             => x_msg_count,
                                     x_msg_data              => x_msg_data,
                                     p_contract_id           => p_contract_id,
                                     p_line_id               => p_line_id,
                                     p_start_date            => p_start_date,
                                     p_due_date              => p_due_date,
                                     x_principal_balance_tbl => r_principal_balance_tbl);
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         print_error_message('Unexpected error raised in call to PRIN_DATE_RANGE_VAR_INT_RLOAN');
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         print_error_message('Error raised in call to PRIN_DATE_RANGE_VAR_INT_LOAN');
         RAISE prin_date_range_failed;
       END IF;
    END IF;

    x_principal_balance_tbl := r_principal_balance_tbl;

  EXCEPTION
     WHEN prin_date_range_failed THEN
       print_error_message('prin_date_range_failed Exception raised in procedure PRIN_DATE_RANGE_VAR_INT_CTR');
       x_return_status := OKL_API.G_RET_STS_ERROR;

     WHEN OTHERS THEN
       print_error_message('Exception raised in procedure PRIN_DATE_RANGE_VAR_INT_CTR');
       Okl_Api.SET_MESSAGE(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_UNEXPECTED_ERROR,
               p_token1       => G_SQLCODE_TOKEN,
               p_token1_value => SQLCODE,
               p_token2       => G_SQLERRM_TOKEN,
               p_token2_value => SQLERRM);

       x_return_status := OKL_API.G_RET_STS_ERROR;

  END prin_date_range_var_rate_ctr;
------------------------------------------------------------------------------
FUNCTION get_last_int_calc_date(p_khr_id IN NUMBER) RETURN DATE IS
  l_ret_date DATE := NULL;

  CURSOR c_int_calc_date_csr(cp_khr_id NUMBER) IS SELECT (max(sel.stream_element_date) - 1) last_interest_calc_date
  FROM  okl_streams stm,
        okl_strm_elements sel,
        okl_strm_type_b sty
  WHERE stm.khr_id = cp_khr_id
  AND   stm.id = sel.stm_id
  AND   stm.sty_id = sty.id
  AND   (sty.stream_type_purpose = 'DAILY_INTEREST_PRINCIPAL' OR sty.stream_type_purpose = 'DAILY_INTEREST_INTEREST');

  CURSOR c_khr_start_date_csr(cp_khr_id NUMBER) IS SELECT start_date - 1
  FROM okc_k_headers_b
  WHERE id = cp_khr_id;

BEGIN
  OPEN c_int_calc_date_csr(p_khr_id);
  FETCH c_int_calc_date_csr INTO l_ret_date;
  CLOSE c_int_calc_date_csr;

  IF (l_ret_date IS NULL) THEN
    OPEN c_khr_start_date_csr(p_khr_id);
    FETCH c_khr_start_date_csr INTO l_ret_date;
    CLOSE c_khr_start_date_csr;
  END IF;

  RETURN l_ret_date;
END;
------------------------------------------------------------------------------
  PROCEDURE interest_date_range (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_start_date         IN  DATE,
            p_end_date           IN  DATE,
            p_process_flag       IN  VARCHAR2,
            p_rate_param_rowid   IN  ROWID,
            x_interest_rate_tbl OUT NOCOPY interest_rate_tbl_type)   IS

    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_name	        CONSTANT VARCHAR2(30)   := 'interest_date_range';
    l_return_status	VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;

    l_interest_rate_tbl interest_rate_tbl_type;
    l_start_date        DATE;
    l_end_date          DATE;
    l_int_tbl_row       NUMBER := 0;
    --specifies whether the rate is to be derived from interest index
    l_derive_rate_flag  VARCHAR2(1) := 'Y';

    l_rate_change_start_date DATE := NULL;
    l_next_rate_change_date DATE := NULL;

    ----------------------------------------------------------------
    -- Declare variable interest parameter cursor
    -----------------------------------------------------------------
    --dkagrawa changed query to use okl_prod_qlty_val_uv than okl_product_parameter_v for performance
    CURSOR c_int_param(cp_rate_param_rowid ROWID) IS
         SELECT krp.interest_index_id
              , NVL(krp.base_rate, 0) base_rate
              , NVL(krp.interest_start_date, chr.start_date) interest_start_date
              , NVL(krp.adder_rate, 0) adder_rate
              , NVL(krp.maximum_rate, 9999) maximum_rate
              , NVL(krp.minimum_rate, 0) minimum_rate
              , krp.rate_delay_code
              , NVL(krp.rate_delay_frequency, 0) rate_delay_frequency
              , NVL(krp.rate_change_start_date, chr.start_date) rate_change_start_date
              , NVL(krp.rate_change_frequency_code, 'DAILY') rate_change_frequency_code
              , NVL(krp.rate_change_value, 0) rate_change_value
              --if the calling process is Daily Interest, get the last int cal date from
              --the Daily Interest streams
              --for a REAMORT contract, if the calling process is Reamortization (initiate_request)
              --and it is being run for the first time for the contract, the last interest calc date
              --defaults to the start date (as there may be a previously derived value due to the fact
              --that the Reamort may not have completed in its entirety)
              --if it is called from any other process for a REAMORT contract, the last int calc date
              --defaults to start date minus 1
              --for all other types of contracts, the last int calc date
              --defaults to start date minus 1
              , decode(p_process_flag, 'DAILY_INTEREST', get_last_int_calc_date(chr.id),
                                   decode(ppm.quality_val, 'REAMORT', NVL(khr.date_last_interim_interest_cal,
                                               decode(OKL_VARIABLE_INTEREST_PVT.G_CALC_METHOD_CODE, 'REAMORT', chr.start_date, chr.start_date-1)), NVL(khr.date_last_interim_interest_cal, chr.start_date - 1))) date_last_interim_interest_cal
              , chr.start_date contract_start_date
              , chr.end_date contract_end_date
              , chr.id khr_id
              , ppm.quality_val interest_calculation_basis
              , NULL pay_freq
         FROM okl_k_rate_params krp
         , okl_k_headers khr
         , okc_k_headers_b chr
         , okl_prod_qlty_val_uv ppm
         WHERE krp.rowid = cp_rate_param_rowid
         AND krp.khr_id = khr.id
         AND khr.id = chr.id
         --AND TRUNC(SYSDATE) BETWEEN krp.effective_from_date and NVL(krp.effective_to_date, trunc(SYSDATE))
         --AND krp.parameter_type_code = 'ACTUAL'
         AND khr.pdt_id = ppm.pdt_id
         AND ppm.quality_name = 'INTEREST_CALCULATION_BASIS';

    TYPE int_param_tbl_type IS TABLE OF c_int_param%ROWTYPE INDEX BY BINARY_INTEGER;

    l_int_param_tbl int_param_tbl_type;
    l_param_tbl_row NUMBER := 0;
    x_eff_int_tbl interest_rate_tbl_type;
    l_eff_int_row   NUMBER := 0;

    ----------------------------------------------------------------
    -- Declare interest rate cursor
    -- used to derive interest rates from the interest parameter
    -- when interest dates are less than last int calc date
    -----------------------------------------------------------------
    CURSOR c_param_rate(cp_khr_id NUMBER, cp_start_date DATE, cp_end_date DATE, cp_process_flag IN VARCHAR2) IS
    SELECT vip.interest_rate VALUE,
           GREATEST(trunc(cp_start_date),interest_calc_start_date) VALID_FROM,
           LEAST(trunc(cp_end_date),NVL(interest_calc_end_date, trunc(sysdate))) VALID_UNTIL
    FROM okl_var_int_params vip
    WHERE   vip.khr_id = cp_khr_id
    AND   (cp_start_date BETWEEN vip.interest_calc_start_date AND nvl(vip.interest_calc_end_date, trunc(cp_start_date))
           OR    (cp_end_date BETWEEN vip.interest_calc_start_date AND nvl(vip.interest_calc_end_date, trunc(cp_end_date)))
           OR    (vip.interest_calc_start_date >= cp_start_date AND nvl(vip.interest_calc_end_date, trunc(sysdate + 9999)) <= cp_end_date) )
    AND   vip.calc_method_code = NVL(cp_process_flag, vip.calc_method_code)
    AND   vip.valid_yn = 'Y'
    ORDER BY VALID_FROM;

    ----------------------------------------------------------------
    -- Declare payment frequency cursor
    -----------------------------------------------------------------
    CURSOR c_pay_freq(cp_khr_id NUMBER) IS
    select sll_rulb.object1_id1 pay_freq
    from   okc_rules_b        sll_rulb,
      okc_rules_b        slh_rulb,
      okl_strm_type_b    styb,
      okc_rule_groups_b  rgpb
    where  sll_rulb.rgp_id                      = rgpb.id
    and    sll_rulb.rule_information_category   = 'LASLL'
    and    sll_rulb.dnz_chr_id                  = rgpb.dnz_chr_id
    and    sll_rulb.object2_id1                 = to_char(slh_rulb.id)
    and    slh_rulb.rgp_id                      = rgpb.id
    and    slh_rulb.rule_information_category   = 'LASLH'
    and    slh_rulb.dnz_chr_id                  = rgpb.dnz_chr_id
    and    styb.id                              = slh_rulb.object1_id1
    and    styb.stream_type_purpose             IN ('RENT', 'PRINCIPAL_PAYMENT')
    and    rgpb.dnz_chr_id                      = cp_khr_id
    and    rgpb.rgd_code                        = 'LALEVL'
    order by sll_rulb.rule_information1;

    /*Returns the interest rate from the interest index for inputted index id and date range*/
    PROCEDURE get_eff_int_rate(p_start_date IN DATE, p_end_date IN DATE, p_int_param_tbl IN int_param_tbl_type, x_eff_int_tbl IN OUT NOCOPY interest_rate_tbl_type) IS

      CURSOR c_int_rate(cp_index_id NUMBER, cp_start_date DATE, cp_end_date DATE) IS
      SELECT ive.value VALUE,
             GREATEST(trunc(cp_start_date),datetime_valid) VALID_FROM,
             LEAST(trunc(cp_end_date),NVL(datetime_invalid, trunc(sysdate))) VALID_UNTIL
      FROM okl_indices idx,
           okl_index_values ive
      WHERE   idx.id = cp_index_id
      AND idx.id = ive.idx_id
      AND   (cp_start_date BETWEEN ive.datetime_valid AND nvl(ive.datetime_invalid, trunc(cp_start_date))
             OR    (cp_end_date BETWEEN ive.datetime_valid AND nvl(ive.datetime_invalid, trunc(cp_end_date)))
             OR    (ive.datetime_valid >= cp_start_date AND nvl(ive.datetime_invalid, trunc(sysdate + 9999)) <= cp_end_date) )
      ORDER BY VALID_FROM;

      l_int_param_row NUMBER := 0;
      l_eff_int_row   NUMBER := 0;
      l_int_param_tbl int_param_tbl_type;
      l_eff_int_tbl   interest_rate_tbl_type;
    BEGIN
      l_int_param_tbl := p_int_param_tbl;
      l_eff_int_tbl.delete;

      l_int_param_row := l_int_param_tbl.first;
      l_eff_int_row := 0;

      print_debug('in procedure get_eff_int_rate for date range : ' || p_start_date || ' - ' || p_end_date);
      WHILE l_int_param_row IS NOT NULL
      LOOP
        FOR cur_int_rate IN c_int_rate(l_int_param_tbl(l_int_param_row).interest_index_id,
                                       p_start_date,
                                       p_end_date) LOOP
            l_eff_int_row := l_eff_int_row + 1;
            l_eff_int_tbl(l_eff_int_row).from_date := cur_int_rate.valid_from;
            l_eff_int_tbl(l_eff_int_row).to_date := cur_int_rate.valid_until;
            l_eff_int_tbl(l_eff_int_row).rate := cur_int_rate.value + l_int_param_tbl(l_int_param_row).adder_rate;
            l_eff_int_tbl(l_eff_int_row).derived_flag := 'Y';
            l_eff_int_tbl(l_eff_int_row).apply_tolerance := 'Y';
        END LOOP;
        l_int_param_row := l_int_param_tbl.next(l_int_param_row);
      END LOOP;

      print_debug('exit procedure get_eff_int_rate');
      x_eff_int_tbl := l_eff_int_tbl;
    EXCEPTION
      WHEN OTHERS THEN
        OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
    END get_eff_int_rate;

    /*returnd the next applicable rate change start date for a contract*/
    FUNCTION get_next_rate_change_date(p_rate_change_start_date DATE, p_int_param_tbl IN int_param_tbl_type) RETURN DATE IS
      l_int_param_tbl int_param_tbl_type;
      l_int_param_tbl_row NUMBER := 0;
      l_next_rate_change_date DATE;
      l_period_start_date DATE;
      l_period_end_date DATE;
      l_adder_months NUMBER;
      x_return_status VARCHAR2(1);
      x_msg_count NUMBER;
      x_msg_data VARCHAR2(4000);
    BEGIN
      print_debug('in function get_next_rate_change_date');
      print_debug('input parameters :-');
      print_debug('p_rate_change_start_date : ' || p_rate_change_start_date);

      l_int_param_tbl := p_int_param_tbl;
      l_int_param_tbl_row := l_int_param_tbl.first;

      IF (l_int_param_tbl(l_int_param_tbl_row).rate_change_frequency_code = 'MONTHLY') THEN
        l_next_rate_change_date := add_months(p_rate_change_start_date, 1);
      ELSIF (l_int_param_tbl(l_int_param_tbl_row).rate_change_frequency_code = 'QUARTERLY') THEN
        l_next_rate_change_date := add_months(p_rate_change_start_date, 3);
      ELSIF (l_int_param_tbl(l_int_param_tbl_row).rate_change_frequency_code = 'ANNUAL') THEN
        l_next_rate_change_date := add_months(p_rate_change_start_date, 12);
      ELSE -- (l_int_param_tbl(l_int_param_row).rate_change_frequency_code = 'BILLING_DATE' THEN
        IF (l_int_param_tbl(l_int_param_tbl_row).interest_calculation_basis = 'FLOAT') THEN
            OKL_STREAM_GENERATOR_PVT.get_next_billing_date(
                p_api_version            => p_api_version,
       	        p_init_msg_list          => p_init_msg_list,
        	   	 	p_khr_id                 => l_int_param_tbl(l_int_param_tbl_row).khr_id,
                p_billing_date           => p_rate_change_start_date,
                x_next_due_date          => l_next_rate_change_date,
                x_next_period_start_date => l_period_start_date,
                x_next_period_end_date   => l_period_end_date,
          			x_return_status          => x_return_status,
          			x_msg_count              => x_msg_count,
          			x_msg_data               => x_msg_data);
        ELSE
          IF (l_int_param_tbl(l_int_param_tbl_row).pay_freq = 'M') THEN
            l_adder_months := 1;
          ELSIF (l_int_param_tbl(l_int_param_tbl_row).pay_freq = 'Q') THEN
            l_adder_months := 3;
          ELSIF (l_int_param_tbl(l_int_param_tbl_row).pay_freq = 'S') THEN
            l_adder_months := 6;
          ELSIF (l_int_param_tbl(l_int_param_tbl_row).pay_freq = 'A') THEN
            l_adder_months := 12;
          ELSE
            l_adder_months := 1;
          END IF;
          l_next_rate_change_date := add_months(p_rate_change_start_date, l_adder_months);
        END IF;
      END IF;

      print_debug('l_next_rate_change_date : ' || l_next_rate_change_date);
      print_debug('exiting function get_next_rate_change_date');
      RETURN l_next_rate_change_date;
    EXCEPTION
      WHEN OTHERS THEN
        OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);

        RETURN l_next_rate_change_date;
    END get_next_rate_change_date;

    /*check the derived interest rates for tolerance*/
    PROCEDURE apply_tolerance(p_int_param_tbl IN int_param_tbl_type, p_eff_int_tbl IN interest_rate_tbl_type, x_eff_int_with_tol_tbl IN OUT NOCOPY interest_rate_tbl_type) IS
      l_int_param_row NUMBER := 0;
      l_eff_int_row   NUMBER := 0;
      l_eff_int_with_tol_row   NUMBER := 0;
      l_prev_eff_int_with_tol_row   NUMBER := 0;

      l_int_param_tbl int_param_tbl_type;
      l_eff_int_tbl   interest_rate_tbl_type;
      l_eff_int_with_tol_tbl interest_rate_tbl_type;

      l_first_row BOOLEAN := TRUE;
      l_compare_to_base BOOLEAN := TRUE;
      l_compare_to_min_max BOOLEAN := TRUE;

      cursor c_most_recent_rate(cp_khr_id IN NUMBER, cp_from_date IN DATE, cp_process_flag IN VARCHAR2) IS
      select interest_calc_start_date
            ,interest_calc_end_date
            ,interest_rate
      from (select vip.interest_calc_start_date
                  ,vip.interest_calc_end_date
                  ,vip.interest_rate
            from okl_var_int_params vip
            where vip.khr_id = cp_khr_id
            and   vip.interest_calc_end_date < cp_from_date
            AND   vip.calc_method_code = NVL(cp_process_flag, vip.calc_method_code)
            AND   vip.valid_yn = 'Y'
            order by vip.interest_calc_end_date desc)
      where rownum = 1;

    BEGIN
      print_debug('in procedure apply_tolerance');
      l_int_param_tbl := p_int_param_tbl;
      l_eff_int_tbl := p_eff_int_tbl;
      l_eff_int_with_tol_tbl.delete;

      l_int_param_row := l_int_param_tbl.first;
      l_eff_int_row := l_eff_int_tbl.first;
      WHILE l_eff_int_row IS NOT NULL
      LOOP
        l_prev_eff_int_with_tol_row := l_eff_int_with_tol_row;
        l_eff_int_with_tol_row := l_eff_int_with_tol_row + 1;
        l_eff_int_with_tol_tbl(l_eff_int_with_tol_row) := l_eff_int_tbl(l_eff_int_row);
        l_compare_to_min_max := TRUE;

        IF (l_eff_int_tbl(l_eff_int_row).apply_tolerance = 'Y') THEN
          --first row in the effective interest rates table
          IF (l_first_row) THEN
            --comparing to most recent rate
            FOR cur_most_recent_rate IN c_most_recent_rate(l_int_param_tbl(l_int_param_row).khr_id, l_eff_int_tbl(l_eff_int_row).from_date, p_process_flag) LOOP
              IF (ABS(l_eff_int_tbl(l_eff_int_row).rate - cur_most_recent_rate.interest_rate) < l_int_param_tbl(l_int_param_row).rate_change_value) THEN
                l_eff_int_with_tol_tbl(l_eff_int_with_tol_row).rate := cur_most_recent_rate.interest_rate;
                l_compare_to_min_max := FALSE;
              END IF;
              l_compare_to_base := FALSE;
            END LOOP;

            --compare to base rate
            IF (l_compare_to_base AND ABS(l_eff_int_tbl(l_eff_int_row).rate - l_int_param_tbl(l_int_param_row).base_rate) < l_int_param_tbl(l_int_param_row).rate_change_value) THEN
              l_eff_int_with_tol_tbl(l_eff_int_with_tol_row).rate := l_int_param_tbl(l_int_param_row).base_rate;
              l_compare_to_min_max := FALSE;
            END IF;

            l_first_row := FALSE;
          ELSE
            --compare to the previous entry in the rates table
            IF (ABS(l_eff_int_tbl(l_eff_int_row).rate - l_eff_int_with_tol_tbl(l_prev_eff_int_with_tol_row).rate) < l_int_param_tbl(l_int_param_row).rate_change_value) THEN
              l_eff_int_with_tol_tbl(l_eff_int_with_tol_row).rate := l_eff_int_with_tol_tbl(l_prev_eff_int_with_tol_row).rate;
              l_compare_to_min_max := FALSE;
            END IF;
          END IF;

          --compare to minimum and maximum
          IF (l_compare_to_min_max) THEN
            IF (l_eff_int_with_tol_tbl(l_eff_int_with_tol_row).rate < l_int_param_tbl(l_int_param_row).minimum_rate) THEN
              l_eff_int_with_tol_tbl(l_eff_int_with_tol_row).rate := l_int_param_tbl(l_int_param_row).minimum_rate;
            END IF;

            IF (l_eff_int_with_tol_tbl(l_eff_int_with_tol_row).rate > l_int_param_tbl(l_int_param_row).maximum_rate) THEN
              l_eff_int_with_tol_tbl(l_eff_int_with_tol_row).rate := l_int_param_tbl(l_int_param_row).maximum_rate;
            END IF;
          END IF;
        END IF;

        l_eff_int_row := l_eff_int_tbl.next(l_eff_int_row);
      END LOOP;

      x_eff_int_with_tol_tbl := l_eff_int_with_tol_tbl;
      print_debug('exiting procedure apply_tolerance');
    EXCEPTION
      WHEN OTHERS THEN
        OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
    END apply_tolerance;

    /*outputs the contents of tables passed to it*/
    PROCEDURE print_table_content(p_int_param_tbl IN int_param_tbl_type, p_eff_int_tbl IN interest_rate_tbl_type) IS
      l_int_param_row NUMBER := 0;
      l_eff_int_row   NUMBER := 0;
      l_out_str varchar2(2000);
    BEGIN

      print_debug('*****************************************');
      print_debug('****START CONTENTS OF P_INT_PARAM_TBL****');
      l_int_param_row := p_int_param_tbl.first;
      WHILE l_int_param_row IS NOT NULL
      LOOP
        print_debug('	interest_index_id : ' || p_int_param_tbl(l_int_param_row).interest_index_id);
        print_debug('	base_rate : ' || p_int_param_tbl(l_int_param_row).base_rate);
        print_debug('	interest_start_date	 : ' || 	p_int_param_tbl(l_int_param_row).interest_start_date);
        print_debug('	adder_rate                    	 : ' || 	p_int_param_tbl(l_int_param_row).adder_rate);
        print_debug('	maximum_rate	 : ' || 	p_int_param_tbl(l_int_param_row).maximum_rate);
        print_debug('	minimum_rate	 : ' || 	p_int_param_tbl(l_int_param_row).minimum_rate);
        print_debug('	rate_delay_code               	 : ' || 	p_int_param_tbl(l_int_param_row).rate_delay_code);
        print_debug('	rate_delay_frequency	 : ' || 	p_int_param_tbl(l_int_param_row).rate_delay_frequency);
        print_debug('	rate_change_start_date	 : ' || 	p_int_param_tbl(l_int_param_row).rate_change_start_date);
        print_debug('	rate_change_frequency_code    	 : ' || 	p_int_param_tbl(l_int_param_row).rate_change_frequency_code);
        print_debug('	rate_change_value	 : ' || 	p_int_param_tbl(l_int_param_row).rate_change_value);
        print_debug('	date_last_interim_interest_cal	 : ' || 	p_int_param_tbl(l_int_param_row).date_last_interim_interest_cal);
        print_debug('	contract_start_date	 : ' || 	p_int_param_tbl(l_int_param_row).contract_start_date);
        print_debug('	khr_id	 : ' || 	p_int_param_tbl(l_int_param_row).khr_id);
        print_debug('	interest_calculation_basis	 : ' || 	p_int_param_tbl(l_int_param_row).interest_calculation_basis);
        print_debug('	pay_freq	 : ' || 	p_int_param_tbl(l_int_param_row).pay_freq);

        l_int_param_row := p_int_param_tbl.next(l_int_param_row);
      END LOOP;
      print_debug('*****END CONTENTS OF P_INT_PARAM_TBL*****');
      print_debug('*****************************************');

      print_debug('*****START CONTENTS OF P_EFF_INT_TBL*****');
      l_eff_int_row := p_eff_int_tbl.first;
      l_out_str := rpad(' from_date', 14, ' ') || rpad('to_date', 15, ' ')
                     || rpad('rate', 15, ' ') || rpad('derived_flag', 15, ' ') || rpad('apply_tolerance', 15, ' ');
      print_debug(l_out_str);
      WHILE l_eff_int_row IS NOT NULL
      LOOP
        /*print_debug('	from_date : ' || p_eff_int_tbl(l_eff_int_row).from_date);
        print_debug('	to_date : ' || p_eff_int_tbl(l_eff_int_row).to_date);
        print_debug('	rate : ' || p_eff_int_tbl(l_eff_int_row).rate);
        print_debug('	derived_flag : ' || p_eff_int_tbl(l_eff_int_row).derived_flag);*/
        l_out_str := rpad(' ' ||  p_eff_int_tbl(l_eff_int_row).from_date, 14, ' ') ||
                     rpad( p_eff_int_tbl(l_eff_int_row).to_date, 15, ' ') ||
                     rpad(p_eff_int_tbl(l_eff_int_row).rate, 15, ' ') ||
                     rpad( p_eff_int_tbl(l_eff_int_row).derived_flag, 15, ' ') ||
                     rpad(p_eff_int_tbl(l_eff_int_row).apply_tolerance, 15, ' ');

        print_debug(l_out_str);
        l_eff_int_row := p_eff_int_tbl.next(l_eff_int_row);
      END LOOP;
      print_debug('******END CONTENTS OF P_EFF_INT_TBL******');
      print_debug('*****************************************');


    EXCEPTION
      WHEN OTHERS THEN
        print_debug('SQLCODE : ' || SQLCODE || ' SQLERRM : ' || SQLERRM);
    END print_table_content;

  BEGIN

    print_debug('in procedure interest_date_range');
    l_int_param_tbl.delete;
    l_param_tbl_row := 0;

    FOR cur_int_param IN c_int_param(p_rate_param_rowid) LOOP
      l_param_tbl_row := l_param_tbl_row + 1;
      l_int_param_tbl(l_param_tbl_row) := cur_int_param;

      FOR cur_pay_freq IN c_pay_freq(p_contract_id) LOOP
        l_int_param_tbl(l_param_tbl_row).pay_freq := cur_pay_freq.pay_freq;
        EXIT;
      END LOOP;

      l_interest_rate_tbl.delete;
      l_start_date := NVL(p_start_date, cur_int_param.contract_start_date);
      l_end_date := p_end_date;

      print_debug('cal start date : ' || l_start_date);
      print_debug('cal end   date : ' || l_end_date);
      print_debug('value of global variable okl_variable_interest_pvt.g_calc_method_code : ' || OKL_VARIABLE_INTEREST_PVT.G_CALC_METHOD_CODE);

      --check for interest start date
      print_debug('in procedure interest_date_range - check for interest start date');
      IF (cur_int_param.interest_start_date < l_start_date) THEN
        NULL;
      ELSE
        IF (cur_int_param.interest_start_date <= l_end_date) THEN
          l_start_date := cur_int_param.interest_start_date;
        ELSE
          RETURN;
        END IF;
      END IF;

      --check for date last interim interest calculated
      print_debug('in procedure interest_date_range - check for date last interim interest calculated');
      IF ((l_start_date <= cur_int_param.date_last_interim_interest_cal) AND
          (((cur_int_param.interest_calculation_basis = 'REAMORT') AND (OKL_VARIABLE_INTEREST_PVT.G_CALC_METHOD_CODE = 'REAMORT')) OR
           (cur_int_param.interest_calculation_basis <> 'REAMORT'))) THEN
          --check if the start date is before last int calc date and
          --if the proc is not called from the variable rate - initiate request
          --then derive the rates for the date range passed
          --else retrieve the previously derived rates
        IF (l_end_date <= cur_int_param.date_last_interim_interest_cal) THEN
          --get the interest rate for l_start_date to l_end_date from okl_var_int_params
          print_debug('in procedure interest_date_range - get the interest rate for l_start_date to l_end_date from okl_var_int_params');
          FOR cur_param_rate IN c_param_rate(p_contract_id, l_start_date, l_end_date, p_process_flag) LOOP
            l_int_tbl_row := l_int_tbl_row + 1;
            l_interest_rate_tbl(l_int_tbl_row).from_date := cur_param_rate.valid_from;
            l_interest_rate_tbl(l_int_tbl_row).to_date := cur_param_rate.valid_until;
            l_interest_rate_tbl(l_int_tbl_row).rate := cur_param_rate.value;
            l_interest_rate_tbl(l_int_tbl_row).derived_flag := 'N';
            l_interest_rate_tbl(l_int_tbl_row).apply_tolerance := 'N';
          END LOOP;

          print_table_content(l_int_param_tbl , l_interest_rate_tbl);
          l_derive_rate_flag := 'N';
        ELSE
          --get the interest rate for l_start_date to date last interim interest cal from okl_var_int_params
          print_debug('in procedure interest_date_range - get the interest rate for l_start_date to date last interim interest cal from okl_var_int_params');
          FOR cur_param_rate IN c_param_rate(p_contract_id, l_start_date, cur_int_param.date_last_interim_interest_cal, p_process_flag) LOOP
            l_int_tbl_row := l_int_tbl_row + 1;
            l_interest_rate_tbl(l_int_tbl_row).from_date := cur_param_rate.valid_from;
            l_interest_rate_tbl(l_int_tbl_row).to_date := cur_param_rate.valid_until;
            l_interest_rate_tbl(l_int_tbl_row).rate := cur_param_rate.value;
            l_interest_rate_tbl(l_int_tbl_row).derived_flag := 'N';
            l_interest_rate_tbl(l_int_tbl_row).apply_tolerance := 'N';
          END LOOP;

          print_table_content(l_int_param_tbl , l_interest_rate_tbl);
          l_start_date := cur_int_param.date_last_interim_interest_cal + 1;
          l_derive_rate_flag := 'Y';
        END IF;
      END IF;

      --no interest rate was available in the interest params table
      --therefore we need to derive the rates from the index
      print_debug('in procedure interest_date_range - no interest rate was available in the interest params table');
      print_debug('in procedure interest_date_range - therefore we need to derive the rates from the index');
      IF ((l_derive_rate_flag = 'N' AND NVL(l_interest_rate_tbl.count, 0) = 0) OR l_derive_rate_flag = 'Y') THEN
        --apply rate delay parameters to start date, end date, rate change start date
        print_debug('in procedure interest_date_range - apply rate delay parameters to start date, end date, rate change start date');
        l_rate_change_start_date := cur_int_param.rate_change_start_date;

        IF (cur_int_param.rate_delay_code = 'DAYS') THEN
          l_start_date := l_start_date - cur_int_param.rate_delay_frequency;
          l_end_date := l_end_date - cur_int_param.rate_delay_frequency;
          l_rate_change_start_date := l_rate_change_start_date - cur_int_param.rate_delay_frequency;
        ELSIF (cur_int_param.rate_delay_code = 'MONTHS') THEN
          l_start_date := add_months(l_start_date, -1 * cur_int_param.rate_delay_frequency);
          l_end_date := add_months(l_end_date, -1 * cur_int_param.rate_delay_frequency);
          l_rate_change_start_date := add_months(l_rate_change_start_date, -1 * cur_int_param.rate_delay_frequency);
        END IF;

        print_debug('in procedure interest_date_range - values after rate delay application');
        print_debug('in procedure interest_date_range - l_start_date: ' || l_start_date);
        print_debug('in procedure interest_date_range - l_end_date: ' || l_end_date);
        print_debug('in procedure interest_date_range - l_rate_change_start_date: ' || l_rate_change_start_date);

        --start dt LESS THAN RCSD
        print_debug('in procedure interest_date_range - start dt LESS THAN RCSD');
        IF (l_start_date <= l_rate_change_start_date) THEN
          --end dt LESS THAN RCSD
          print_debug('in procedure interest_date_range - end dt LESS THAN RCSD');
          IF(l_end_date < l_rate_change_start_date) THEN
            l_int_tbl_row := l_int_tbl_row + 1;
            l_interest_rate_tbl(l_int_tbl_row).from_date := l_start_date;
            l_interest_rate_tbl(l_int_tbl_row).to_date := l_end_date;
            l_interest_rate_tbl(l_int_tbl_row).rate := cur_int_param.base_rate;
            l_interest_rate_tbl(l_int_tbl_row).derived_flag := 'Y';
            l_interest_rate_tbl(l_int_tbl_row).apply_tolerance := 'N';

            print_table_content(l_int_param_tbl , l_interest_rate_tbl);
          ELSE
            --end dt NOT LESS THAN RCSD
            print_debug('in procedure interest_date_range - end dt NOT LESS THAN RCSD');
            IF (l_start_date < l_rate_change_start_date) THEN
              l_int_tbl_row := l_int_tbl_row + 1;
              l_interest_rate_tbl(l_int_tbl_row).from_date := l_start_date;
              l_interest_rate_tbl(l_int_tbl_row).to_date := l_rate_change_start_date - 1;
              l_interest_rate_tbl(l_int_tbl_row).rate := cur_int_param.base_rate;
              l_interest_rate_tbl(l_int_tbl_row).derived_flag := 'Y';
              l_interest_rate_tbl(l_int_tbl_row).apply_tolerance := 'N';
            END IF;

            --get daily rate if rate_change_frequency_code is Daily
            print_debug('in procedure interest_date_range - get daily rate if rate_change_frequency_code is Daily');
            IF (cur_int_param.rate_change_frequency_code = 'DAILY') THEN
              l_start_date := l_rate_change_start_date;
              print_debug('1 -> before calling get_eff_int_rate.');
              get_eff_int_rate(l_start_date, l_end_date, l_int_param_tbl , x_eff_int_tbl);
              l_eff_int_row := x_eff_int_tbl.first;
              WHILE (l_eff_int_row IS NOT NULL)
              LOOP
                l_int_tbl_row := l_int_tbl_row + 1;
                l_interest_rate_tbl(l_int_tbl_row).from_date := x_eff_int_tbl(l_eff_int_row).from_date;
                l_interest_rate_tbl(l_int_tbl_row).to_date := x_eff_int_tbl(l_eff_int_row).to_date;
                l_interest_rate_tbl(l_int_tbl_row).rate := x_eff_int_tbl(l_eff_int_row).rate;
                l_interest_rate_tbl(l_int_tbl_row).derived_flag := x_eff_int_tbl(l_eff_int_row).derived_flag;
                l_interest_rate_tbl(l_int_tbl_row).apply_tolerance := x_eff_int_tbl(l_eff_int_row).apply_tolerance;
                l_eff_int_row := x_eff_int_tbl.next(l_eff_int_row);
              END LOOP;
              print_table_content(l_int_param_tbl , l_interest_rate_tbl);
            ELSE
              print_debug('in procedure interest_date_range - get the next rate change date');
              --get the next rate change date
              --and so on and so forth
              l_next_rate_change_date := get_next_rate_change_date(l_rate_change_start_date, l_int_param_tbl);
              print_debug('in procedure interest_date_range - l_next_rate_change_date : ' || l_next_rate_change_date);
              --end dt LESS THAN NRCSD
              /*IF (l_end_date < l_next_rate_change_date) THEN
                get_eff_int_rate(l_rate_change_start_date, l_rate_change_start_date, l_int_param_tbl , x_eff_int_tbl);
                l_eff_int_row := x_eff_int_tbl.first;
                WHILE (l_eff_int_row IS NOT NULL)
                LOOP
                  l_int_tbl_row := l_int_tbl_row + 1;
                  l_interest_rate_tbl(l_int_tbl_row).from_date := l_rate_change_start_date;
                  l_interest_rate_tbl(l_int_tbl_row).to_date := l_end_date;
                  l_interest_rate_tbl(l_int_tbl_row).rate := x_eff_int_tbl(l_eff_int_row).rate;
                  l_interest_rate_tbl(l_int_tbl_row).derived_flag := x_eff_int_tbl(l_eff_int_row).derived_flag;
                  l_eff_int_row := x_eff_int_tbl.next(l_eff_int_row);
                END LOOP;
              ELSE*/
                --end dt NOT LESS THAN NRCSD
                print_debug('in procedure interest_date_range - end dt NOT LESS THAN NRCSD');
                LOOP
                  print_debug('2 -> before calling get_eff_int_rate.');
                  get_eff_int_rate(l_rate_change_start_date, l_rate_change_start_date, l_int_param_tbl , x_eff_int_tbl);
                  l_eff_int_row := x_eff_int_tbl.first;
                  WHILE (l_eff_int_row IS NOT NULL)
                  LOOP
                    l_int_tbl_row := l_int_tbl_row + 1;
                    l_interest_rate_tbl(l_int_tbl_row).from_date := l_rate_change_start_date;
                    IF (l_end_date < l_next_rate_change_date) THEN
                      l_interest_rate_tbl(l_int_tbl_row).to_date := l_end_date;
                    ELSE
                      IF (l_next_rate_change_date IS NOT NULL) THEN
                        l_interest_rate_tbl(l_int_tbl_row).to_date := l_next_rate_change_date - 1;
                      ELSE
                        l_interest_rate_tbl(l_int_tbl_row).to_date := cur_int_param.contract_end_date;
                      END IF;
                    END IF;
                    l_interest_rate_tbl(l_int_tbl_row).rate := x_eff_int_tbl(l_eff_int_row).rate;
                    l_interest_rate_tbl(l_int_tbl_row).derived_flag := x_eff_int_tbl(l_eff_int_row).derived_flag;
                    l_interest_rate_tbl(l_int_tbl_row).apply_tolerance := x_eff_int_tbl(l_eff_int_row).apply_tolerance;
                    l_eff_int_row := x_eff_int_tbl.next(l_eff_int_row);
                  END LOOP;

                  EXIT WHEN ((l_end_date < l_next_rate_change_date) OR
                             (l_rate_change_start_date = cur_int_param.contract_end_date));
                  l_rate_change_start_date := l_next_rate_change_date;
                  l_next_rate_change_date := get_next_rate_change_date(l_rate_change_start_date, l_int_param_tbl);
                  print_debug('1 -> l_rate_change_start_date : ' || l_rate_change_start_date);
                  print_debug('1 -> l_next_rate_change_date : ' || l_next_rate_change_date);
                END LOOP;
                print_table_content(l_int_param_tbl , l_interest_rate_tbl);
              --END IF;
            END IF;

          END IF;
        ELSE
          --start dt NOT LESS THAN RCSD
          IF (cur_int_param.rate_change_frequency_code = 'DAILY') THEN
            --l_start_date := l_rate_change_start_date;
            print_debug('3 -> before calling get_eff_int_rate.');
            get_eff_int_rate(l_start_date, l_end_date, l_int_param_tbl , x_eff_int_tbl);
            l_eff_int_row := x_eff_int_tbl.first;
            WHILE (l_eff_int_row IS NOT NULL)
            LOOP
              l_int_tbl_row := l_int_tbl_row + 1;
              l_interest_rate_tbl(l_int_tbl_row).from_date := x_eff_int_tbl(l_eff_int_row).from_date;
              l_interest_rate_tbl(l_int_tbl_row).to_date := x_eff_int_tbl(l_eff_int_row).to_date;
              l_interest_rate_tbl(l_int_tbl_row).rate := x_eff_int_tbl(l_eff_int_row).rate;
              l_interest_rate_tbl(l_int_tbl_row).derived_flag := x_eff_int_tbl(l_eff_int_row).derived_flag;
              l_interest_rate_tbl(l_int_tbl_row).apply_tolerance := x_eff_int_tbl(l_eff_int_row).apply_tolerance;
              l_eff_int_row := x_eff_int_tbl.next(l_eff_int_row);
            END LOOP;
            print_table_content(l_int_param_tbl , l_interest_rate_tbl);
          ELSE

            print_table_content(l_int_param_tbl , l_interest_rate_tbl);
            print_debug('in procedure interest_date_range - start dt NOT LESS THAN RCSD');
            l_next_rate_change_date := get_next_rate_change_date(l_rate_change_start_date, l_int_param_tbl);

            LOOP
              print_debug('l_start_date : ' || l_start_date);
              print_debug('l_next_rate_change_date : ' || l_next_rate_change_date);

              EXIT WHEN ((l_start_date < l_next_rate_change_date) OR
                         (l_rate_change_start_date = cur_int_param.contract_end_date));
              l_rate_change_start_date := l_next_rate_change_date;
              l_next_rate_change_date := get_next_rate_change_date(l_rate_change_start_date, l_int_param_tbl);
            END LOOP;

            --end dt LESS THAN NRCSD
            print_debug('in procedure interest_date_range - end dt LESS THAN NRCSD');
            IF (l_end_date < l_next_rate_change_date) THEN
              print_debug('4 -> before calling get_eff_int_rate.');
              get_eff_int_rate(l_rate_change_start_date, l_rate_change_start_date, l_int_param_tbl , x_eff_int_tbl);
              l_eff_int_row := x_eff_int_tbl.first;
              WHILE (l_eff_int_row IS NOT NULL)
              LOOP
                l_int_tbl_row := l_int_tbl_row + 1;
                l_interest_rate_tbl(l_int_tbl_row).from_date := l_start_date;
                l_interest_rate_tbl(l_int_tbl_row).to_date := l_end_date;
                l_interest_rate_tbl(l_int_tbl_row).rate := x_eff_int_tbl(l_eff_int_row).rate;
                l_interest_rate_tbl(l_int_tbl_row).derived_flag := x_eff_int_tbl(l_eff_int_row).derived_flag;
                l_interest_rate_tbl(l_int_tbl_row).apply_tolerance := x_eff_int_tbl(l_eff_int_row).apply_tolerance;
                l_eff_int_row := x_eff_int_tbl.next(l_eff_int_row);
              END LOOP;
              --end dt NOT LESS THAN NRCSD
              print_debug('in procedure interest_date_range - end dt NOT LESS THAN NRCSD');
              print_table_content(l_int_param_tbl , l_interest_rate_tbl);
            ELSE
              LOOP
                print_debug('5 -> before calling get_eff_int_rate.');
                get_eff_int_rate(l_rate_change_start_date, l_rate_change_start_date, l_int_param_tbl , x_eff_int_tbl);
                l_eff_int_row := x_eff_int_tbl.first;
                WHILE (l_eff_int_row IS NOT NULL)
                LOOP
                  l_int_tbl_row := l_int_tbl_row + 1;
                  IF (l_start_date >= l_rate_change_start_date) THEN
                    l_interest_rate_tbl(l_int_tbl_row).from_date := l_start_date;
                  ELSE
                    l_interest_rate_tbl(l_int_tbl_row).from_date := l_rate_change_start_date;
                  END IF;

                  IF (l_end_date < NVL(l_next_rate_change_date, l_end_date)) THEN
                    l_interest_rate_tbl(l_int_tbl_row).to_date := l_end_date;
                  ELSE
                    IF (l_next_rate_change_date IS NOT NULL) THEN
                      l_interest_rate_tbl(l_int_tbl_row).to_date := l_next_rate_change_date - 1;
                    ELSE
                      l_interest_rate_tbl(l_int_tbl_row).to_date := cur_int_param.contract_end_date;
                    END IF;
                  END IF;
                  l_interest_rate_tbl(l_int_tbl_row).rate := x_eff_int_tbl(l_eff_int_row).rate;
                  l_interest_rate_tbl(l_int_tbl_row).derived_flag := x_eff_int_tbl(l_eff_int_row).derived_flag;
                  l_interest_rate_tbl(l_int_tbl_row).apply_tolerance := x_eff_int_tbl(l_eff_int_row).apply_tolerance;
                  l_eff_int_row := x_eff_int_tbl.next(l_eff_int_row);
                END LOOP;

                EXIT WHEN ((l_end_date < l_next_rate_change_date) OR
                            (l_rate_change_start_date = cur_int_param.contract_end_date));
                l_rate_change_start_date := l_next_rate_change_date;
                l_next_rate_change_date := get_next_rate_change_date(l_rate_change_start_date, l_int_param_tbl);
                print_debug('2 -> l_rate_change_start_date : ' || l_rate_change_start_date);
                print_debug('2 -> l_next_rate_change_date : ' || l_next_rate_change_date);
              END LOOP;
              print_table_content(l_int_param_tbl , l_interest_rate_tbl);
            END IF;
          END IF;--here
        END IF;
      END IF;

    END LOOP;

    --unapply rate delay
    print_debug('in procedure interest_date_range - unapply rate delay');
    l_param_tbl_row := l_int_param_tbl.first;
    l_int_tbl_row := l_interest_rate_tbl.first;
    WHILE l_int_tbl_row IS NOT NULL
    LOOP
      IF (l_interest_rate_tbl(l_int_tbl_row).derived_flag = 'Y') THEN
        IF (l_int_param_tbl(l_param_tbl_row).rate_delay_code = 'DAYS') THEN
          l_interest_rate_tbl(l_int_tbl_row).from_date  := l_interest_rate_tbl(l_int_tbl_row).from_date + l_int_param_tbl(l_param_tbl_row).rate_delay_frequency;
          l_interest_rate_tbl(l_int_tbl_row).to_date := l_interest_rate_tbl(l_int_tbl_row).to_date + l_int_param_tbl(l_param_tbl_row).rate_delay_frequency;
        ELSIF (l_int_param_tbl(l_param_tbl_row).rate_delay_code = 'MONTHS') THEN
          l_interest_rate_tbl(l_int_tbl_row).from_date := add_months(l_interest_rate_tbl(l_int_tbl_row).from_date, l_int_param_tbl(l_param_tbl_row).rate_delay_frequency);
          l_interest_rate_tbl(l_int_tbl_row).to_date := add_months(l_interest_rate_tbl(l_int_tbl_row).to_date, l_int_param_tbl(l_param_tbl_row).rate_delay_frequency);
        END IF;
      END IF;
      l_int_tbl_row := l_interest_rate_tbl.next(l_int_tbl_row);
    END LOOP;
    print_table_content(l_int_param_tbl , l_interest_rate_tbl);

    --apply tolerance
    print_debug('in procedure interest_date_range - apply tolerance');
    apply_tolerance(l_int_param_tbl, l_interest_rate_tbl, x_interest_rate_tbl);
    print_table_content(l_int_param_tbl , x_interest_rate_tbl);

    print_debug('exiting procedure interest_date_range');
    x_return_status := l_return_status;
  Exception
   	WHEN OTHERS THEN
      print_debug('sqlcode : ' || sqlcode || ' $ sqlerrm : ' || sqlerrm);
   		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
    					p_api_name	=> l_api_name,
    					p_pkg_name	=> G_PKG_NAME,
    					p_exc_name	=> 'OTHERS',
    					x_msg_count	=> x_msg_count,
    					x_msg_data	=> x_msg_data,
    					p_api_type	=> '_PVT');

  END interest_date_range;

  ------------------------------------------------------------------------------

  PROCEDURE interest_date_range (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_start_date         IN  DATE,
            p_end_date           IN  DATE,
            p_process_flag       IN  VARCHAR2 ,
            x_interest_rate_tbl OUT NOCOPY interest_rate_tbl_type)   IS

    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_name	        CONSTANT VARCHAR2(30)   := 'interest_date_range';
    l_return_status	VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;

    l_interest_rate_tbl interest_rate_tbl_type;
    l_interest_rate_tbl_out interest_rate_tbl_type;
    l_int_tbl_row       NUMBER := 0;
    l_int_tbl_row_out   NUMBER := 0;

    CURSOR c_param_rate(cp_khr_id NUMBER, cp_start_date DATE, cp_end_date DATE) IS
    SELECT krp.rowid rate_param_rowid,
           GREATEST(trunc(cp_start_date),krp.effective_from_date) start_date,
           LEAST(trunc(cp_end_date),NVL(krp.effective_to_date, trunc(sysdate + 9999))) end_date
    FROM  okl_k_rate_params krp
    WHERE krp.khr_id = cp_khr_id
    AND   krp.parameter_type_code = 'ACTUAL'
    AND   (cp_start_date BETWEEN krp.effective_from_date AND nvl(krp.effective_to_date, trunc(cp_start_date))
           OR    (cp_end_date BETWEEN krp.effective_from_date AND nvl(krp.effective_to_date, trunc(cp_end_date)))
           OR    (krp.effective_from_date >= cp_start_date AND nvl(krp.effective_to_date, trunc(sysdate + 9999)) <= cp_end_date));

  BEGIN
    print_debug('entering procedure interest_date_range outer with the foll. parameters:-');
    print_debug('p_contract_id: ' || p_contract_id);
    print_debug('p_start_date: ' || p_start_date);
    print_debug('p_end_date: ' || p_end_date);
    print_debug('p_process_flag: ' || p_process_flag);

    l_interest_rate_tbl.delete;
    l_interest_rate_tbl_out.delete;
    l_int_tbl_row_out := 0;

    FOR cur_param_rate IN c_param_rate(p_contract_id, p_start_date, p_end_date) LOOP
      print_debug('calling procedure interest_date_range inner with foll. params:-');
      print_debug('p_contract_id: ' || p_contract_id);
      print_debug('start_date: ' || cur_param_rate.start_date);
      print_debug('end_date: ' || cur_param_rate.end_date);
      print_debug('rate_param_rowid: ' || cur_param_rate.rate_param_rowid);
      interest_date_range (
              p_api_version       => 1.0,
              p_init_msg_list     => OKL_API.G_FALSE,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              p_contract_id       => p_contract_id,
              p_start_date        => cur_param_rate.start_date,
              p_end_date          => cur_param_rate.end_date,
              p_process_flag      => p_process_flag,
              p_rate_param_rowid  => cur_param_rate.rate_param_rowid,
              x_interest_rate_tbl => l_interest_rate_tbl);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        print_error_message('Unexpected error raised in call to INTEREST_DATE_RANGE');
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        print_error_message('Error raised in call to INTEREST_DATE_RANGE');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      print_debug('count in l_interest_rate_tbl: ' || l_interest_rate_tbl.count);
      l_int_tbl_row := l_interest_rate_tbl.first;
      LOOP
        EXIT WHEN l_int_tbl_row IS NULL;
        l_int_tbl_row_out := l_int_tbl_row_out + 1;
        l_interest_rate_tbl_out(l_int_tbl_row_out) := l_interest_rate_tbl(l_int_tbl_row);

        l_int_tbl_row := l_interest_rate_tbl.next(l_int_tbl_row);
      END LOOP;
      print_debug('count in l_interest_rate_tbl_out: ' || l_interest_rate_tbl_out.count);
    END LOOP;

    x_interest_rate_tbl := l_interest_rate_tbl_out;
    x_return_status := l_return_status;
    print_debug('exiting procedure interest_date_range outer');
  Exception
   	WHEN OTHERS THEN
      print_debug('sqlcode : ' || sqlcode || ' $ sqlerrm : ' || sqlerrm);
   		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
    					p_api_name	=> l_api_name,
    					p_pkg_name	=> G_PKG_NAME,
    					p_exc_name	=> 'OTHERS',
    					x_msg_count	=> x_msg_count,
    					x_msg_data	=> x_msg_data,
    					p_api_type	=> '_PVT');

  END interest_date_range;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    calculate_interest
    -- Description:      This procedure is called by Variable Interest Calculation for Loans
    --                   Inputs :
    --                   Output : Interest Calculated
    -- Dependencies:
    -- Parameters:       Start Date, End Date, Interest Rate Range.
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  Function  calculate_interest (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_from_date          IN  DATE,
            p_to_date            IN  DATE,
            p_principal_amount   IN  NUMBER,
            p_currency_code      IN  VARCHAR2) RETURN NUMBER  IS

  l_api_name                  CONSTANT    VARCHAR2(30) := 'CALCULATE_INTEREST';
  l_api_version               CONSTANT    NUMBER       := 1.0;
  l_interest_rate_tbl         interest_rate_tbl_type;
  l_interest_rate_tbl_count   NUMBER;
  l_interest_rate_tbl_counter NUMBER;
  l_interest_rate_tbl_index   NUMBER;
  l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_from_date                 DATE;
  l_to_date                   DATE;
  l_interest_rate             NUMBER;
  l_calc_days                 NUMBER;
  l_year_days                 NUMBER;
  l_interest_amt              NUMBER := 0;
  l_total_interest_amt        NUMBER := 0;
  l_year_part                 NUMBER;
  l_interest_basis            OKL_K_RATE_PARAMS.interest_basis_code%TYPE;
  l_calculation_formula_id    OKL_K_RATE_PARAMS.calculation_formula_id%TYPE;
  l_derived_flag              VARCHAR2(1);
  calculate_interest_failed   EXCEPTION;


  BEGIN
    x_return_status     := OKL_API.G_RET_STS_SUCCESS;

    print_debug('Executing procedure CALCULATE_INTEREST using following parameters : ');
    print_debug(' p_contract_id : '|| p_contract_id );
	print_debug(' p_from_date : '|| to_char(p_from_date));
	print_debug(' p_to_date : '|| to_char(p_to_date));
	print_debug(' p_principal_amount: '|| p_principal_amount);
	print_debug(' p_currency_code : '|| p_currency_code);

    print_debug(' g_contract_id : '|| G_CONTRACT_ID );

	Initialize_contract_params( p_api_version   => 1.0,
                                p_init_msg_list => OKL_API.G_FALSE,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_contract_id   => p_contract_id
                              );
    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS completed successfully');
    ELSIF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS returned unexpected error');
  	   print_error_message ('Procedure INITIALIZE_CONTRACT_PARAMS returned unexpected error');
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS returned exception');
	   print_error_message ('Procedure INITIALIZE_CONTRACT_PARAMS returned exception');
       RAISE calculate_interest_failed;
    END IF;


    print_debug('Days in a month: '|| G_DAYS_IN_A_MONTH_CODE);
	print_debug('Days in a year: '|| G_DAYS_IN_A_YEAR_CODE);

     /* start prasjain bug#5645266
             Added the check condition as the interest is getting calculated for
             31 days if the interest rate changes on 31st of the month in a 30/360
             contract
        */
       IF G_DAYS_IN_A_MONTH_CODE = '30' AND to_char(p_to_date,'DD') = '31'
       THEN
    interest_date_range (
            p_api_version       => 1.0,
            p_init_msg_list     => OKL_API.G_FALSE,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_contract_id       => p_contract_id,
            p_start_date        => p_from_date,
            p_end_date          => p_to_date-1, /* pass the end date as 30 of the month */
            p_process_flag      => G_INTEREST_CALCULATION_BASIS, /* value is set in Calculate_total_interest_due */
            x_interest_rate_tbl => l_interest_rate_tbl);
ELSE
           interest_date_range (
               p_api_version       => 1.0,
               p_init_msg_list     => OKL_API.G_FALSE,
               x_return_status     => x_return_status,
               x_msg_count         => x_msg_count,
               x_msg_data          => x_msg_data,
               p_contract_id       => p_contract_id,
               p_start_date        => p_from_date,
               p_end_date          => p_to_date, /* if not 31 pass the actual date */
               p_process_flag      => G_INTEREST_CALCULATION_BASIS, /* value is set in Calculate_total_interest_due */
               x_interest_rate_tbl => l_interest_rate_tbl);
      END IF;

      -- end prasjain bug#5645266








    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      print_error_message('Unexpected error raised in call to INTEREST_DATE_RANGE');
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      print_error_message('Error raised in call to INTEREST_DATE_RANGE');
      RAISE calculate_interest_failed;
    END IF;

    l_interest_rate_tbl_count := l_interest_rate_tbl.COUNT;

    print_debug('No. of records in Interest Date Range TAble : '|| l_interest_rate_tbl_count);

    IF (l_interest_rate_tbl_count = 0) THEN
       RETURN 0;
    END IF;
    l_interest_rate_tbl_index := l_interest_rate_tbl.FIRST;

    FOR l_interest_rate_tbl_counter in 1 .. l_interest_rate_tbl_count
    LOOP
       l_from_date     := l_interest_rate_tbl(l_interest_rate_tbl_index).from_date;
       l_to_date       := l_interest_rate_tbl(l_interest_rate_tbl_index).to_date;
       l_interest_rate := l_interest_rate_tbl(l_interest_rate_tbl_index).rate;
       l_derived_flag  := l_interest_rate_tbl(l_interest_rate_tbl_index).derived_flag;

       print_debug('From Date: '|| l_from_date ||' To Date: '|| l_to_date||' Interest: '|| l_interest_rate || 'Derived flag: '|| l_derived_flag);

       IF (G_DAYS_IN_A_MONTH_CODE = '30') THEN
          -- gboomina modified for bug 7130132 - Start
          -- using correct day count logic from OKL_PRICING_UTILS_PVT
          l_calc_days := OKL_PRICING_UTILS_PVT.get_day_count( G_DAYS_IN_A_MONTH_CODE,
                                                              G_DAYS_IN_A_YEAR_CODE,
                                                              l_from_date,
                                                              l_to_date,
                                                              'Y',
                                                              x_return_status);
          -- gboomina modified for bug 7130132 - End
       ELSE
          l_calc_days := l_to_date - l_from_date + 1;
       END IF;

       print_debug('No. of calc Days : '|| l_calc_days);

       IF (G_DAYS_IN_A_YEAR_CODE = 'ACTUAL') THEN
          l_year_part := to_char(l_from_date, 'YYYY');
          l_year_days := (to_date(('01-01-'||(l_year_part+1)),'DD-MM-YYYY') - to_date(('01-01-'||l_year_part),
'DD-MM-YYYY'));
       ELSE
          l_year_days := G_DAYS_IN_A_YEAR_CODE;
       END IF;

       print_debug('No. of Days in the year: '|| l_year_days);

       l_interest_amt            := OKL_ACCOUNTING_UTIL.round_amount((p_principal_amount * l_interest_rate/100) * (
l_calc_days / l_year_days), p_currency_code);

       print_debug(' Interest : '|| l_interest_amt);
       l_total_interest_amt      := l_total_interest_amt + l_interest_amt;
       l_interest_rate_tbl_index := l_interest_rate_tbl.NEXT(l_interest_rate_tbl_index);

       print_debug ('g_request_id : '|| g_request_id);
       print_debug ('Concurrent Request ID : '|| fnd_global.conc_request_id);
       print_debug ('l_derived_flag : '|| l_derived_flag);

       IF ((g_request_id > 0) AND (l_derived_flag = 'Y'))THEN
           g_vir_tbl_counter                                     := nvl(g_vir_tbl_counter,0) + 1;
           g_vir_tbl(g_vir_tbl_counter).id                       := okc_p_util.raw_to_number(sys_guid());
           g_vir_tbl(g_vir_tbl_counter).khr_id                   := p_contract_id;
           IF (G_CALC_METHOD_CODE = 'DAILY_INTEREST') THEN
             g_vir_tbl(g_vir_tbl_counter).source_table           := 'OKL_STRM_ELEMENTS_B';
           ELSIF (G_CALC_METHOD_CODE = 'REAMORT') THEN
             g_vir_tbl(g_vir_tbl_counter).source_table           := 'OKL_VAR_INT_PROCESS_B';
           ELSE
             g_vir_tbl(g_vir_tbl_counter).source_table           := 'OKL_TRX_AR_INVOICES_V';
           END IF;
           g_vir_tbl(g_vir_tbl_counter).interest_rate            := l_interest_rate;
           g_vir_tbl(g_vir_tbl_counter).interest_calc_start_date := l_from_date;
           g_vir_tbl(g_vir_tbl_counter).interest_calc_end_date   := l_to_date;
           g_vir_tbl(g_vir_tbl_counter).calc_method_code         := G_CALC_METHOD_CODE;
           g_vir_tbl(g_vir_tbl_counter).principal_balance        := p_principal_amount;
           g_vir_tbl(g_vir_tbl_counter).valid_yn                 := 'Y';
           g_vir_tbl(g_vir_tbl_counter).object_version_number    := 1.0;
           g_vir_tbl(g_vir_tbl_counter).org_id                   := g_authoring_org_id;
           g_vir_tbl(g_vir_tbl_counter).request_id               := g_request_id;
           g_vir_tbl(g_vir_tbl_counter).program_application_id   := NULL;
           g_vir_tbl(g_vir_tbl_counter).program_id               := NULL;
           g_vir_tbl(g_vir_tbl_counter).program_update_date      := SYSDATE;
           g_vir_tbl(g_vir_tbl_counter).attribute_category       := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute1               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute2               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute3               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute4               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute5               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute6               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute7               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute8               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute9               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute10              := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute11              := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute12              := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute13              := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute14              := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute15              := NULL;
           g_vir_tbl(g_vir_tbl_counter).created_by               := FND_GLOBAL.user_id;
           g_vir_tbl(g_vir_tbl_counter).creation_date            := SYSDATE;
           g_vir_tbl(g_vir_tbl_counter).last_updated_by          := FND_GLOBAL.user_id;
           g_vir_tbl(g_vir_tbl_counter).last_update_date         := SYSDATE;
           g_vir_tbl(g_vir_tbl_counter).last_update_login        := FND_GLOBAL.login_id;
           g_vir_tbl(g_vir_tbl_counter).interest_amt             := l_interest_amt;
           g_vir_tbl(g_vir_tbl_counter).interest_calc_days       := l_calc_days;
       END IF;
    END LOOP;

    print_debug ('Total interest amount : '|| l_total_interest_amt);

    RETURN l_total_interest_amt;

  EXCEPTION
     WHEN calculate_interest_failed THEN
      print_error_message('Exception calculate_interest_failed raised in function CALCULATE_INTEREST');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN NULL;
     WHEN OTHERS THEN
      print_error_message('Exception raised in function CALCULATE_INTEREST');
       Okl_Api.SET_MESSAGE(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_UNEXPECTED_ERROR,
               p_token1       => G_SQLCODE_TOKEN,
               p_token1_value => SQLCODE,
               p_token2       => G_SQLERRM_TOKEN,
               p_token2_value => SQLERRM);
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RETURN NULL;

  END calculate_interest;

------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    Calc_Variable_Rate_Interest
    -- Description:      This procedure is called by Variable Interest Calculation for Loans
    -- Inputs :
    -- Output : Interest Calculated
    -- Dependencies:
    -- Parameters:       Start Date, End Date, Interest Rate Range.
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  Function  Calc_Variable_Rate_Interest (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_currency_code      IN  VARCHAR2,
            p_principal_balance_tbl IN  principal_balance_tbl_typ) RETURN NUMBER  IS

  l_api_name                  CONSTANT    VARCHAR2(30) := 'CALC_VARIABLE_RATE_INTEREST';
  l_api_version               CONSTANT    NUMBER       := 1.0;
  l_principal_balance_tbl     principal_balance_tbl_typ;
  l_principal_bal_tbl_count   NUMBER;
  l_principal_bal_tbl_counter NUMBER;
  l_principal_bal_tbl_index   NUMBER;
  l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_from_date                 DATE;
  l_to_date                   DATE;
  l_interest_amt              NUMBER := 0;
  l_total_interest_amt        NUMBER := 0;
  Calc_Var_Rate_Int_failed    EXCEPTION;

  BEGIN
    print_debug('Executing function CALC_VARIABLE_RATE_INTEREST using following parameters : ');
    print_debug('p_contract_id : '|| p_contract_id );
	print_debug('p_currency_code : '|| p_currency_code);

    x_return_status               := OKL_API.G_RET_STS_SUCCESS;
    l_principal_balance_tbl       := p_principal_balance_tbl;
    l_principal_bal_tbl_count     := l_principal_balance_tbl.COUNT;

    print_debug ('No. of records in Principal balance table: '|| l_principal_bal_tbl_count);
    IF (l_principal_bal_tbl_count = 0) THEN
       RETURN 0;
    END IF;
    l_principal_bal_tbl_index := l_principal_balance_tbl.FIRST;

    FOR l_principal_bal_tbl_counter in 1 .. l_principal_bal_tbl_count
    LOOP
       l_from_date := l_principal_balance_tbl(l_principal_bal_tbl_index).from_date;
       l_to_date   := l_principal_balance_tbl(l_principal_bal_tbl_index).to_date;

       IF (l_principal_balance_tbl(l_principal_bal_tbl_index).principal_balance > 0) THEN
         l_interest_amt := calculate_interest (
                                               p_api_version       => 1.0,
                                               p_init_msg_list     => OKL_API.G_FALSE,
                                               x_return_status     => x_return_status,
                                               x_msg_count         => x_msg_count,
                                               x_msg_data          => x_msg_data,
                                               p_contract_id       => p_contract_id,
                                               p_from_date         => l_from_date,
                                               p_to_date           => l_to_date,
                                               p_principal_amount  => l_principal_balance_tbl(l_principal_bal_tbl_index).principal_balance,
                                               p_currency_code     => p_currency_code);

         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           print_error_message('Unexpected error raised in call to CALCULATE_INTEREST');
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           print_error_message('Error raised in call to CALCULATE_INTEREST');
           RAISE Calc_Var_Rate_Int_failed;
         END IF;
       ELSE
	     l_interest_amt := 0;
	   END IF;

       l_total_interest_amt := l_total_interest_amt + l_interest_amt;
       l_principal_bal_tbl_index := l_principal_balance_tbl.NEXT(l_principal_bal_tbl_index);

    END LOOP;
    print_debug('Total Interest Amount: '|| l_total_interest_amt);

    RETURN l_total_interest_amt;

  EXCEPTION
    WHEN Calc_Var_Rate_Int_failed THEN
      print_error_message('Exception Calc_Var_Rate_Int_failed raised in function CALC_VARIABLE_RATE_INTEREST');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN NULL;

    WHEN OTHERS THEN
      print_error_message('Exception raised in function CALC_VARIABLE_RATE_INTEREST');
      Okl_Api.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => SQLCODE,
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN NULL;


  END Calc_Variable_Rate_Interest;

-- Start of comments
--
-- Procedure Name  : get_reporting_product
-- Description     : This procedure checks if there is a reporting product attached to the contract
-- Business Rules  :
-- Parameters      :  p_contract_id - Contract ID
-- Version         : 1.0
-- History         : SECHAWLA 20-feb-2009  MG Impact on var rate contracts - Created
-- End of comments
   PROCEDURE get_reporting_product(p_api_version           IN  	NUMBER,
           		 	              p_init_msg_list         IN  	VARCHAR2,
           			              x_return_status         OUT 	NOCOPY VARCHAR2,
           			              x_msg_count             OUT 	NOCOPY NUMBER,
           			              x_msg_data              OUT 	NOCOPY VARCHAR2,
                                  p_contract_id 		  IN 	NUMBER,
                                  x_rep_product           OUT   NOCOPY VARCHAR2,
								  x_rep_product_id        OUT   NOCOPY NUMBER) IS

  -- Get the financial product of the contract
  CURSOR l_get_fin_product(cp_khr_id IN NUMBER) IS
  SELECT a.start_date, a.contract_number, b.pdt_id
  FROM   okc_k_headers_b a, okl_k_headers b
  WHERE  a.id = b.id
  AND    a.id = cp_khr_id;

  SUBTYPE pdtv_rec_type IS OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
  SUBTYPE pdt_parameters_rec_type IS OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;

  l_fin_product_id          NUMBER;
  l_start_date              DATE;
  l_contract_number         VARCHAR2(120);
  lp_pdtv_rec               pdtv_rec_type;
  lp_empty_pdtv_rec         pdtv_rec_type;
  lx_pdt_parameter_rec      pdt_parameters_rec_type ;
  l_reporting_product       OKL_PRODUCTS_V.NAME%TYPE;
  l_reporting_product_id    NUMBER;

  lx_no_data_found          BOOLEAN;


  l_mg_rep_book             fa_book_controls.book_type_code%TYPE;
  mg_error                  EXCEPTION;




  BEGIN
    -- get the financial product of the contract
    OPEN  l_get_fin_product(p_contract_id);
    FETCH l_get_fin_product INTO l_start_date, l_contract_number, l_fin_product_id;
    CLOSE l_get_fin_product;

    lp_pdtv_rec.id := l_fin_product_id;

    -- check if the fin product has a reporting product
    OKL_SETUPPRODUCTS_PUB.Getpdt_parameters( p_api_version                  => p_api_version,
  				  			               p_init_msg_list                => OKC_API.G_FALSE,
						                   x_return_status                => x_return_status,
							               x_no_data_found                => lx_no_data_found,
							               x_msg_count                    => x_msg_count,
							               x_msg_data                     => x_msg_data,
							               p_pdtv_rec                     => lp_pdtv_rec,
							               p_product_date                 => l_start_date,
							               p_pdt_parameter_rec            => lx_pdt_parameter_rec);

    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        -- Error getting financial product parameters for contract CONTRACT_NUMBER.
        OKC_API.set_message(  p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_AM_FIN_PROD_PARAM_ERR',
                           p_token1        =>  'CONTRACT_NUMBER',
                           p_token1_value  =>  l_contract_number);



    ELSE

        x_rep_product := lx_pdt_parameter_rec.reporting_product;
        x_rep_product_id := lx_pdt_parameter_rec.reporting_pdt_id;

    END IF;

  EXCEPTION

      WHEN OTHERS THEN
         IF l_get_fin_product%ISOPEN THEN
            CLOSE l_get_fin_product;
         END IF;
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END get_reporting_product;

------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    Create_Stream_Invoice
    -- Description:      This procedure is called by Variable Interest Calculation for Loans
    --                   Inputs :
    --                   Output :
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  Procedure Create_Stream_Invoice (
            p_api_version             IN  NUMBER,
            p_init_msg_list           IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_contract_id             IN  NUMBER,
            p_line_id                 IN  NUMBER DEFAULT NULL,
            p_amount                  IN  NUMBER,
            p_due_date                IN  DATE,
            p_stream_type_purpose     IN  VARCHAR2,
            p_create_invoice_flag     IN  VARCHAR2 DEFAULT OKL_API.G_TRUE,
 	        p_process_flag            IN  VARCHAR2 DEFAULT NULL,
 	        p_parent_strm_element_id  IN  NUMBER DEFAULT NULL,
	        x_invoice_id              OUT NOCOPY NUMBER,
			x_stream_element_id       OUT NOCOPY NUMBER) IS

  l_api_name                   CONSTANT    VARCHAR2(30) := 'CREATE_STREAM_INVOICE';
  l_api_version                CONSTANT    NUMBER       := 1.0;
  l_return_status              VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);
  l_sty_id                     OKL_STRM_TYPE_V.id%TYPE;
  l_stream_exists              VARCHAR2(1) := '?';
  l_stmv_rec                   Okl_Streams_Pub.stmv_rec_type;
  lx_stmv_rec                  Okl_Streams_Pub.stmv_rec_type;
  l_selv_rec                   Okl_Streams_Pub.selv_rec_type;
  lx_selv_rec                  Okl_Streams_Pub.selv_rec_type;
  i_taiv_rec                   Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
  r_taiv_rec                   Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
  l_def_desc                   CONSTANT VARCHAR2(80) := 'Variable Interest Stream Billing';
  l_final_status               CONSTANT VARCHAR2(30) := 'SUBMITTED';
--  l_trx_type_name              CONSTANT VARCHAR2(30)	:= 'Billing';
  l_date_entered               CONSTANT DATE := SYSDATE;
--  l_trx_type_id                NUMBER;
  l_line_code                  CONSTANT VARCHAR2(30)    := 'LINE';

-- Begin - Billing Inline changes - Bug#5898792 - varangan - 28/2/2007
 /* i_tilv_rec                   Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
  r_tilv_rec                   Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
  i_tldv_rec                   Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
  r_tldv_rec                   Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type; */

  -----------------------------------------------------------
 -- Variables for billing API call
 -----------------------------------------------------------
    lp_taiv_rec        okl_tai_pvt.taiv_rec_type;
    lp_tilv_rec	       okl_til_pvt.tilv_rec_type;
    lp_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lp_tldv_rec        okl_tld_pvt.tldv_rec_type;
    lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type;

    lx_taiv_rec        okl_tai_pvt.taiv_rec_type;
    lx_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
-- End - Billing Inline changes - Bug#5898792 - varangan - 28/2/2007

  l_msg_index_out              NUMBER;
  l_bpd_acc_rec                Okl_Acc_Call_Pub.bpd_acc_rec_type;
  l_set_of_books_id            Hr_operating_units.set_of_books_id%TYPE;
  l_trxH_in_rec                Okl_Trx_Contracts_Pub.tcnv_rec_type;
  l_trxH_out_rec               Okl_Trx_Contracts_Pub.tcnv_rec_type;
  l_trxL_in_tbl                Okl_Trx_Contracts_Pub.tclv_tbl_type;
  l_trxL_out_tbl               Okl_Trx_Contracts_Pub.tclv_tbl_type;
  l_acc_gen_primary_key_tbl    Okl_Account_Generator_Pvt.primary_key_tbl;
  l_meaning                    FND_LOOKUPS.meaning%TYPE;
  l_description                FND_LOOKUPS.description%TYPE;

  l_stream_created             VARCHAR2(1) := OKL_API.G_FALSE;
  l_strm_element_created       VARCHAR2(1) := OKL_API.G_FALSE;
  l_okl_trx_created            VARCHAR2(1) := OKL_API.G_FALSE;
  create_stream_invoice_failed EXCEPTION;

-- 5033120
  l_trx_type_id                Okl_Trx_Types_V.id%TYPE;
  l_trx_try_id                 Okl_Trx_Types_V.try_id%TYPE;
  l_trx_desc                   Okl_Trx_Types_V.description%TYPE;

  l_tcn_type                   FND_LOOKUPS.lookup_code%TYPE;
  l_tcn_meaning                FND_LOOKUPS.meaning%TYPE;
  l_tcn_desc                   FND_LOOKUPS.description%TYPE;

  l_tcl_type                   FND_LOOKUPS.lookup_code%TYPE;
  l_tcl_meaning                FND_LOOKUPS.meaning%TYPE;
  l_tcl_desc                   FND_LOOKUPS.description%TYPE;

--  Bug 5964482 dpsingh SLA Uptake Project
   l_tcn_id NUMBER;
   l_tmpl_identify_tbl          Okl_Account_Dist_Pvt.tmpl_identify_tbl_type;
   l_dist_info_tbl              Okl_Account_Dist_Pvt.dist_info_tbl_type;
   l_ctxt_tbl                   Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
   l_acc_gen_tbl                Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
   l_template_out_tbl           Okl_Account_Dist_Pvt.avlv_out_tbl_type;
   l_amount_out_tbl             Okl_Account_Dist_Pvt.amount_out_tbl_type;
--END: Added by dpsingh for SLA Uptake, Bug 5964482

  CURSOR stream_csr(p_khr_id NUMBER, p_kle_id NUMBER, p_sty_id NUMBER) IS
     SELECT stm.id
     FROM   okl_streams stm
     WHERE  stm.khr_id = p_khr_id
     AND    nvl(stm.kle_id, -9999) = NVL(p_kle_id, -9999)
     AND    stm.say_code = 'CURR'
     AND    stm.active_yn = 'Y'
     AND    stm.sty_id = p_sty_id;

   --sechawla 20-feb-09 MG Impact on var rate
   CURSOR rep_stream_csr(p_khr_id NUMBER, p_kle_id NUMBER, p_rep_sty_id NUMBER) IS
     SELECT stm.id
     FROM   okl_streams stm
     WHERE  stm.khr_id = p_khr_id
     AND    nvl(stm.kle_id, -9999) = NVL(p_kle_id, -9999)
     AND    stm.say_code = 'CURR'
     AND    stm.active_yn = 'N'
     AND    stm.purpose_code = 'REPORT'
     AND    stm.sty_id = p_rep_sty_id;

  CURSOR tran_num_csr IS
     SELECT  okl_sif_seq.nextval
     FROM    dual;

  CURSOR c_stm_id_line_number(c_stm_id NUMBER) IS
     SELECT SE_LINE_NUMBER
     FROM   OKL_STRM_ELEMENTS_V
     WHERE  stm_id = c_stm_id
     ORDER BY SE_LINE_NUMBER DESC;


  CURSOR set_of_books_csr IS
     SELECT set_of_books_id
     FROM   OKL_SYS_ACCT_OPTS;


  CURSOR trx_type_csr (p_trx_name VARCHAR2) IS
     SELECT id, try_id, description
     FROM   okl_trx_types_v
     WHERE  name = p_trx_name;


  CURSOR fnd_lookup_csr (p_lookup_type VARCHAR2, p_lookup_code VARCHAR2) IS
     SELECT lookup_code, meaning, description
     FROM   fnd_lookups
     WHERE  lookup_code = p_lookup_code
     AND    lookup_type = p_lookup_type;

--Added by dpsingh for LE Uptake
CURSOR get_contract_number(p_khr_id NUMBER) IS
SELECT CONTRACT_NUMBER
FROM OKC_K_HEADERS_B
WHERE ID = p_khr_id ;

--Added by dpsingh for LE Uptake
-- Bug 5964482 dpsingh for AE signature Uptake  start
CURSOR get_dff_fields(p_khr_id NUMBER) IS
SELECT ATTRIBUTE_CATEGORY,
              ATTRIBUTE1,
              ATTRIBUTE2,
              ATTRIBUTE3,
              ATTRIBUTE4,
              ATTRIBUTE5,
              ATTRIBUTE6,
              ATTRIBUTE7,
              ATTRIBUTE8,
              ATTRIBUTE9,
              ATTRIBUTE10,
              ATTRIBUTE11,
              ATTRIBUTE12,
              ATTRIBUTE13,
              ATTRIBUTE14,
              ATTRIBUTE15
FROM OKL_K_HEADERS
WHERE ID = p_khr_id ;

--sechawla 20-feb-09 MG Impact on var rate

/*
-- Get secondary_rep_method
CURSOR l_sec_rep_method_csr IS
SELECT secondary_rep_method
FROM   okl_sys_acct_opts;

l_sec_rep_method				 VARCHAR2(30);
*/
l_rep_sty_id                     OKL_STRM_TYPE_V.id%TYPE;
l_rep_strm_element_created     	 VARCHAR2(1) := OKL_API.G_FALSE;
l_rep_stream_created             VARCHAR2(1) := OKL_API.G_FALSE;
lx_rep_product					 OKL_PRODUCTS_V.NAME%TYPE;
lx_rep_product_id				 NUMBER;



-- Bug 5964482 dpsingh for AE signature Uptake  end
l_legal_entity_id   NUMBER;
l_cntrct_number   			 OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
l_rep_stmv_rec             		 Okl_Streams_Pub.stmv_rec_type;
lx_rep_stmv_rec                  Okl_Streams_Pub.stmv_rec_type;
l_rep_selv_rec                   Okl_Streams_Pub.selv_rec_type;
lx_rep_selv_rec                  Okl_Streams_Pub.selv_rec_type;


  BEGIN
    print_debug('Executing procedure CREATE_STREAM_INVOICE using following parameters : ');
    print_debug(' p_contract_id : '|| p_contract_id );
	print_debug(' p_line_id : '|| p_line_id);
    print_debug(' p_amount : '|| p_amount );
	print_debug(' p_due_date: '|| p_due_date);
    print_debug(' p_stream_type_purpose : '||p_stream_type_purpose);
	print_debug(' p_create_invoice_flag: '|| p_create_invoice_flag);
    print_debug(' p_process_flag : '|| p_process_flag);
    print_debug(' p_parent_strm_element_id : '|| p_parent_strm_element_id);

    x_return_status               := OKL_API.G_RET_STS_SUCCESS;

    -- Get sty_id for the contract
    IF (p_stream_type_purpose = 'VARIABLE_INTEREST') THEN
      Okl_Streams_Util.get_primary_stream_type(
                           p_khr_id              => p_contract_id,
                           p_primary_sty_purpose => p_stream_type_purpose,
                           x_return_status       => x_return_status,
                           x_primary_sty_id      => l_sty_id
                          );
    ELSE
      Okl_Streams_Util.get_dependent_stream_type(
                           p_khr_id                => p_contract_id,
                           p_primary_sty_purpose   => 'RENT',
                           p_dependent_sty_purpose => p_stream_type_purpose,
                           x_return_status         => x_return_status,
                           x_dependent_sty_id      => l_sty_id
                          );
    END IF;

    IF (x_return_status = 'S' ) THEN
       print_debug ('        -- Stream Id for purpose '|| p_stream_type_purpose || 'retrieved.');
    ELSE
       print_debug( '        -- ERROR: Could not retrieve Stream Id for purpose '|| p_stream_type_purpose );
    END IF;

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      print_error_message('Unexpected error raised in call to Okl_Streams_Util.get_primary/dependent_stream_type');
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      print_error_message('Error raised in call to Okl_Streams_Util.get_primary/dependent_stream_type');
      RAISE create_stream_invoice_failed;
    END IF;

    l_selv_rec.stm_id := NULL;

    OPEN stream_csr (p_contract_id, p_line_id, l_sty_id);
    FETCH stream_csr INTO l_selv_rec.stm_id;
    IF (stream_csr%NOTFOUND) THEN
       NULL;
       print_debug('Stream Not Found : Creating a new stream');
    END IF;
    CLOSE stream_csr;

    IF (l_selv_rec.stm_id IS NULL) THEN
       OPEN  tran_num_csr;
       FETCH tran_num_csr INTO l_stmv_rec.transaction_number;
       CLOSE tran_num_csr;

       l_stmv_rec.sty_id                := l_sty_id;
       l_stmv_rec.khr_id                := p_contract_id;
       l_stmv_rec.kle_id                := p_line_id;
       l_stmv_rec.sgn_code              := 'INTC';
       l_stmv_rec.say_code              := 'CURR';
       l_stmv_rec.active_yn             := 'Y';
       l_stmv_rec.date_current          := sysdate;

       IF (p_process_flag = 'DAILY_INTEREST') THEN
          l_stmv_rec.comments              := 'Daily Interest';
       ELSE
          l_stmv_rec.comments              := 'Variable Interest';
       END IF;

       print_debug('Executing procedure OKL_STREAMS_PUB.CREATE_STREAMS');

       Okl_Streams_Pub.create_streams(
                                      p_api_version    =>     p_api_version,
                                      p_init_msg_list  =>     p_init_msg_list,
                                      x_return_status  =>     x_return_status,
                                      x_msg_count      =>     x_msg_count,
                                      x_msg_data       =>     x_msg_data,
                                      p_stmv_rec       =>     l_stmv_rec,
                                      x_stmv_rec       =>     lx_stmv_rec);


       IF (x_return_status = 'S' ) THEN
          print_debug ('        -- Success in Stream Creation.');
       ELSE
          print_debug ('        -- Error: '||x_msg_data);
       END IF;

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         print_error_message('Unexpected error raised in call to Okl_Streams_Pub.create_streams');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         print_error_message('Error raised in call to Okl_Streams_Pub.create_streams');
         RAISE create_stream_invoice_failed;
       END IF;

       l_stream_created := OKL_API.G_TRUE;

       print_debug ('Stm ID: '||lx_stmv_rec.id);
       l_selv_rec.stm_id := lx_stmv_rec.id;
       print_debug ('Stm ID: '||l_selv_rec.stm_id);

    END IF;

    --change on 16 Nov 2005 by pgomes for bug fix 4740008
    --setting the value of accrued_yn to NULL instead of 'N'
    l_selv_rec.accrued_yn          := NULL;
    l_selv_rec.stream_element_date := p_due_date;
    l_selv_rec.date_billed         := trunc(sysdate);
    l_selv_rec.amount              := p_amount;
    l_selv_rec.sel_id              := p_parent_strm_element_id;

    l_selv_rec.se_line_number      := NULL;
    OPEN  c_stm_id_line_number(l_selv_rec.stm_id);
    FETCH c_stm_id_line_number INTO l_selv_rec.se_line_number;
    IF (c_stm_id_line_number%NOTFOUND) THEN
        print_debug ('Stream Elements do not exist');
       l_selv_rec.se_line_number := 1;
    ELSE
       l_selv_rec.se_line_number := l_selv_rec.se_line_number + 1;
    END IF;
    CLOSE c_stm_id_line_number;

    IF (p_process_flag = 'DAILY_INTEREST') THEN
       l_selv_rec.comments              := 'Daily Interest';
    ELSE
       l_selv_rec.comments              := 'Variable Interest';
    END IF;


    print_debug('Executing procedure OKL_STREAMS_PUB.CREATE_STREAM_ELEMENTS');

    Okl_Streams_Pub.create_stream_elements(
                                           p_api_version    =>     p_api_version,
                                           p_init_msg_list  =>     p_init_msg_list,
                                           x_return_status  =>     x_return_status,
                                           x_msg_count      =>     x_msg_count,
                                           x_msg_data       =>     x_msg_data,
                                           p_selv_rec       =>     l_selv_rec,
                                           x_selv_rec       =>     lx_selv_rec);

    IF (x_return_status = 'S' ) THEN
       print_debug ('        -- Success in Creating Stream Elements.');
    ELSE
       print_debug ('        -- Error: '||x_msg_data);
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      print_error_message('Unexpected error raised in call to Okl_Streams_Pub.create_stream_elements');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      print_error_message('Error raised in call to Okl_Streams_Pub.create_stream_elements');
      RAISE create_stream_invoice_failed;
    END IF;

    l_strm_element_created := OKL_API.G_TRUE;

    x_stream_element_id :=   lx_selv_rec.id;

    ---------------sechawla 19-feb-09 MG Impact on Varibale Rate user story BEGIN ------------
    ---------------Create reporting streams for secondary representation ----------------
    --This procedure is modified to create reporting streams for the following types of variable rate contracts
	--and corresponding stream type purposes.

    --Float_Factor_Lease ---> stream_type_purpose 'FLOAT_FACTOR_ADJUSTMENT'
    --Loan-Float- Estimated and Billed ---> stream_type_purpose 'VARIABLE_INTEREST'
    --Catchup-Cleanup Streams ---> stream_type_purpose --> 'INTEREST_CATCHUP', 'PRINCIPAL_CATCHUP'

    --Reporitng streams will be created if the financial product has a reporting product and
    --and secondary_rep_method is 'Automated' for the OU

    IF p_stream_type_purpose IN ('FLOAT_FACTOR_ADJUSTMENT','VARIABLE_INTEREST','INTEREST_CATCHUP', 'PRINCIPAL_CATCHUP') THEN
    	--Check if financial product has a reporting product
    	get_reporting_product(
                                  p_api_version           => p_api_version,
           		 	              p_init_msg_list         => OKC_API.G_FALSE,
           			              x_return_status         => x_return_status,
           			              x_msg_count             => x_msg_count,
           			              x_msg_data              => x_msg_data,
                                  p_contract_id 		  => p_contract_id,
                                  x_rep_product           => lx_rep_product,
								  x_rep_product_id        => lx_rep_product_id);

    	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        	RAISE OKL_API.G_EXCEPTION_ERROR;
    	END IF;

    /*	--Check the secondary_rep_method
    	OPEN  l_sec_rep_method_csr ;
    	FETCH l_sec_rep_method_csr INTO l_sec_rep_method;
    	IF l_sec_rep_method_csr%NOTFOUND THEN
       		print_error_message('Secondary rep method cursor did not return any records');
	   		RAISE create_stream_invoice_failed;
    	END IF;
		CLOSE l_sec_rep_method_csr ;
	*/
	--	IF lx_rep_product IS NOT NULL AND l_sec_rep_method = 'AUTOMATED' THEN
     	IF lx_rep_product IS NOT NULL THEN

    	   	IF (p_stream_type_purpose = 'VARIABLE_INTEREST') THEN --will it also be primary purpose on rep product SGT ?
      		   	Okl_Streams_Util.get_primary_stream_type_rep(
                           p_khr_id              => p_contract_id,
                           p_primary_sty_purpose => p_stream_type_purpose,
                           x_return_status       => x_return_status,
                           x_primary_sty_id      => l_rep_sty_id
                          );

            ELSE
      			Okl_Streams_Util.get_dependent_stream_type_rep(
                           p_khr_id                => p_contract_id,
                           p_primary_sty_purpose   => 'RENT',
                           p_dependent_sty_purpose => p_stream_type_purpose,
                           x_return_status         => x_return_status,
                           x_dependent_sty_id      => l_rep_sty_id
                          );
       		END IF;

            IF (x_return_status = 'S' ) THEN
       			print_debug ('        -- Reporting Stream Id for purpose '|| p_stream_type_purpose || 'retrieved.');
    		ELSE
       			print_debug( '        -- ERROR: Could not retrieve Reporting Stream Id for purpose '|| p_stream_type_purpose );
    		END IF;

			IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      			print_error_message('Unexpected error raised in call to Okl_Streams_Util.get_primary/dependent_stream_type_rep');
      			RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      			print_error_message('Error raised in call to Okl_Streams_Util.get_primary/dependent_stream_type_rep');
      			RAISE create_stream_invoice_failed;
    		END IF;

			l_rep_selv_rec.stm_id := NULL;

    		OPEN rep_stream_csr (p_contract_id, p_line_id, l_rep_sty_id);
    		FETCH rep_stream_csr INTO l_rep_selv_rec.stm_id;
    		IF (rep_stream_csr%NOTFOUND) THEN
       			NULL;
       			print_debug('Reporting Stream Not Found : Creating a new stream');
    		END IF;
    		CLOSE rep_stream_csr;

			IF (l_rep_selv_rec.stm_id IS NULL) THEN
       			OPEN  tran_num_csr;
       			FETCH tran_num_csr INTO l_rep_stmv_rec.transaction_number;
       			CLOSE tran_num_csr;

       			l_rep_stmv_rec.sty_id                := l_rep_sty_id;
       			l_rep_stmv_rec.khr_id                := p_contract_id;
       			l_rep_stmv_rec.kle_id                := p_line_id;
       			l_rep_stmv_rec.sgn_code              := 'INTC'; --- wil it be this for reporting stream ?
       			l_rep_stmv_rec.say_code              := 'CURR';
       			l_rep_stmv_rec.active_yn             := 'N';
       			l_rep_stmv_rec.date_current          := sysdate;
       			l_rep_stmv_rec.purpose_code 		 := 'REPORT';
                l_rep_stmv_rec.comments              := 'Variable Interest';

                print_debug('Executing procedure OKL_STREAMS_PUB.CREATE_STREAMS');

       			Okl_Streams_Pub.create_streams(
                                      p_api_version    =>     p_api_version,
                                      p_init_msg_list  =>     p_init_msg_list,
                                      x_return_status  =>     x_return_status,
                                      x_msg_count      =>     x_msg_count,
                                      x_msg_data       =>     x_msg_data,
                                      p_stmv_rec       =>     l_rep_stmv_rec,
                                      x_stmv_rec       =>     lx_rep_stmv_rec);

                IF (x_return_status = 'S' ) THEN
          			print_debug ('        -- Success in Reporting Stream Creation.');
       			ELSE
          			print_debug ('        -- Error: '||x_msg_data);
       			END IF;

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         			print_error_message('Unexpected error raised in call to Okl_Streams_Pub.create_streams for reporting streams');
         			RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       			ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         			print_error_message('Error raised in call to Okl_Streams_Pub.create_streams for reporting streams');
         			RAISE create_stream_invoice_failed;
      			END IF;

				l_rep_stream_created := OKL_API.G_TRUE;

       			print_debug ('Stm ID: '||lx_rep_stmv_rec.id);
       			l_rep_selv_rec.stm_id := lx_rep_stmv_rec.id;
       			print_debug ('Stm ID: '||l_rep_selv_rec.stm_id);

    		END IF;

			--setting the value of accrued_yn to NULL instead of 'N'
    		l_rep_selv_rec.accrued_yn          := NULL;  --check
    		l_rep_selv_rec.stream_element_date := p_due_date;
    		l_rep_selv_rec.date_billed         := trunc(sysdate);
    		l_rep_selv_rec.amount              := p_amount;
    		l_rep_selv_rec.sel_id              := p_parent_strm_element_id; --what is this ?
    		l_rep_selv_rec.se_line_number      := NULL;

   			OPEN  c_stm_id_line_number(l_rep_selv_rec.stm_id);
    		FETCH c_stm_id_line_number INTO l_rep_selv_rec.se_line_number;
    		IF (c_stm_id_line_number%NOTFOUND) THEN
        		print_debug ('Reporting Stream Elements do not exist');
       			l_rep_selv_rec.se_line_number := 1;
    		ELSE
       			l_rep_selv_rec.se_line_number := l_rep_selv_rec.se_line_number + 1;
    		END IF;
    		CLOSE c_stm_id_line_number;

			l_rep_selv_rec.comments              := 'Variable Interest';


    		print_debug('Executing procedure OKL_STREAMS_PUB.CREATE_STREAM_ELEMENTS for reporting streams');

    		Okl_Streams_Pub.create_stream_elements(
                                           p_api_version    =>     p_api_version,
                                           p_init_msg_list  =>     p_init_msg_list,
                                           x_return_status  =>     x_return_status,
                                           x_msg_count      =>     x_msg_count,
                                           x_msg_data       =>     x_msg_data,
                                           p_selv_rec       =>     l_rep_selv_rec,
                                           x_selv_rec       =>     lx_rep_selv_rec);

    		IF (x_return_status = 'S' ) THEN
       			print_debug ('        -- Success in Creating Reporing Stream Elements.');
    		ELSE
       			print_debug ('        -- Error: '||x_msg_data);
    		END IF;

    		IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     			 print_error_message('Unexpected error raised in call to Okl_Streams_Pub.create_stream_elements for reporting streams');
      			 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      			 print_error_message('Error raised in call to Okl_Streams_Pub.create_stream_elements for reporting streams');
      			RAISE create_stream_invoice_failed;
    		END IF;

    		l_rep_strm_element_created := OKL_API.G_TRUE;

    	END IF;
    END IF;
    ---------------sechawla 19-feb-09 MG Impact on Varibale Rate user story END ------------



    OPEN set_of_books_csr;
    FETCH set_of_books_csr INTO l_set_of_books_id;
    IF (set_of_books_csr%NOTFOUND) THEN
      print_error_message('Set of books cursor did not return any records');
      RAISE create_stream_invoice_failed;
    END IF;
    CLOSE set_of_books_csr;

    IF (p_create_invoice_flag = OKL_API.G_TRUE) THEN
      IF (G_BILLING_TRX_TYPE_ID IS NULL) THEN
        OPEN trx_type_csr ('Billing');
        FETCH trx_type_csr INTO G_BILLING_TRX_TYPE_ID, G_BILLING_TRX_TRY_ID, G_BILLING_TRX_DESC;
        IF (trx_type_csr%NOTFOUND) THEN
          print_error_message('Transaction type cursor did not return any records');
          RAISE create_stream_invoice_failed;
        END IF;
        CLOSE trx_type_csr;
      END IF;

       print_debug('G_CONTRACT_ID : '|| G_CONTRACT_ID);
-- Begin - Billing Inline changes - Bug#5898792 - varangan - 28/2/2007
       lp_taiv_rec.khr_id             := p_contract_id;
       lp_taiv_rec.date_invoiced      := p_due_date;
       lp_taiv_rec.try_id             := G_BILLING_TRX_TYPE_ID;
       lp_taiv_rec.date_entered       := l_date_entered;
       lp_taiv_rec.description        := l_def_desc;
       lp_taiv_rec.trx_status_code    := l_final_status;
       lp_taiv_rec.amount             := p_amount;
       lp_taiv_rec.currency_code      := G_CURRENCY_CODE;
       lp_taiv_rec.org_id             := G_AUTHORING_ORG_ID;
       lp_taiv_rec.set_of_books_id    := l_set_of_books_id;
       lp_taiv_rec.OKL_SOURCE_BILLING_TRX := G_SOURCE_BILLING_TRX;
      -- Added by dpsingh for LE Uptake
            l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_contract_id) ;
            IF  l_legal_entity_id IS NOT NULL THEN
	        lp_taiv_rec.legal_entity_id :=  l_legal_entity_id;
            ELSE
                  -- get the contract number
                OPEN get_contract_number(p_contract_id);
                FETCH get_contract_number INTO l_cntrct_number;
                CLOSE get_contract_number;
		Okl_Api.set_message(p_app_name     => g_app_name,
                                                 p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			                         p_token1           =>  'CONTRACT_NUMBER',
			                         p_token1_value  =>  l_cntrct_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

       print_debug('Executing procedure OKL_TRX_AR_INVOICES_PUB.INSERT_TRX_AR_INVOICES');

     /*
       --Commenting the existing code by calling common Billing API
       Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices
                                           (p_api_version,
                                            p_init_msg_list,
                                            x_return_status,
                                            x_msg_count,
                                            x_msg_data,
                                            i_taiv_rec,
                                            r_taiv_rec);

       IF (x_return_status = 'S' ) THEN
          print_debug ('        -- Internal TXN Header Created.');
       ELSE
          print_debug( '        -- ERROR: Creating Internal TXN Header.');
       END IF;

       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         print_error_message('Unexpected error raised in call to Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices');
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         print_error_message('Error raised in call to Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices');
         RAISE create_stream_invoice_failed;
       END IF; */

 -- Populate the Line record
       lp_tilv_rec.org_id                   := G_AUTHORING_ORG_ID;
       lp_tilv_rec.line_number              := 1;
       lp_tilv_rec.kle_id                   := p_line_id;
--       x_invoice_id                        := r_taiv_rec.id;
       lp_tilv_rec.description              := l_def_desc;
       lp_tilv_rec.inv_receiv_line_code     := l_line_code;
       lp_tilv_rec.amount                   := p_amount;
       lp_tilv_rec.date_bill_period_start   := p_due_date;
       lp_tilv_rec.til_id_reverses          := NULL;
       lp_tilv_rec.tpl_id                   := NULL;
       lp_tilv_rec.acn_id_cost              := NULL;
       lp_tilv_rec.sty_id                   := NULL;
       lp_tilv_rec.quantity                 := NULL;
       lp_tilv_rec.amount_applied           := NULL;
       lp_tilv_rec.receivables_invoice_id   := NULL;
      --sosharma added txl_ar_line_number start changes
        lp_tilv_rec.txl_ar_line_number := 1;
      -- sosharma end changes
       lp_tilv_tbl(1) := lp_tilv_rec; -- Assign the line record in tilv_tbl structure

     /*
       --Commenting the existing code by calling common Billing API
       Okl_Txl_Ar_Inv_Lns_Pub.insert_txl_ar_inv_lns
                                                   (p_api_version,
                                                    p_init_msg_list,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data,
                                                    i_tilv_rec,
                                                    r_tilv_rec);

       IF (x_return_status = 'S' ) THEN
          print_debug ('        -- Internal TXN Line Created.');
       ELSE
          FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Creating Internal TXN Line.');
       END IF;

       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         print_error_message('Unexpected error raised in call to Okl_Txl_Ar_Inv_Lns_Pub.insert_txl_ar_inv_lns');
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         print_error_message('Error raised in call to Okl_Txl_Ar_Inv_Lns_Pub.insert_txl_ar_inv_lns');
         RAISE create_stream_invoice_failed;
       END IF; */

       lp_tldv_rec.sty_id             := l_sty_id;
       lp_tldv_rec.amount             := p_amount;
       lp_tldv_rec.description        := l_def_desc;
       lp_tldv_rec.sel_id             := lx_selv_rec.id;
       --i_tldv_rec.til_id_details     := r_tilv_rec.id;
       lp_tldv_rec.line_detail_number := 1;
       lp_tldv_rec.date_calculation   := SYSDATE;
       lp_tldv_rec.org_id             := G_AUTHORING_ORG_ID; --r_taiv_rec.org_id;
       --sosharma added for billing issues
        lp_tldv_rec.txl_ar_line_number := 1;
       lp_tldv_tbl(1) := lp_tldv_rec;

            ---------------------------------------------------------------------------
	    -- Call to Billing Centralized API
	    ---------------------------------------------------------------------------
		okl_internal_billing_pvt.create_billing_trx(p_api_version =>l_api_version,
							    p_init_msg_list =>p_init_msg_list,
							    x_return_status =>  x_return_status,
							    x_msg_count => x_msg_count,
							    x_msg_data => x_msg_data,
							    p_taiv_rec => lp_taiv_rec,
							    p_tilv_tbl => lp_tilv_tbl,
							    p_tldv_tbl => lp_tldv_tbl,
							    x_taiv_rec => lx_taiv_rec,
							    x_tilv_tbl => lx_tilv_tbl,
							    x_tldv_tbl => lx_tldv_tbl);

	       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 print_error_message('Unexpected error raised in call to okl_internal_billing_pvt.create_billing_trx');
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
	         print_error_message('Error raised in call to okl_internal_billing_pvt.create_billing_trx');
                 RAISE create_stream_invoice_failed;
               END IF;
              --sosharma added for billing changes
               x_invoice_id := lx_taiv_rec.id;
              --sosharma end


			/*   --Commenting the existing code by calling common Billing API
			     Okl_Txd_Ar_Ln_Dtls_Pub.insert_txd_ar_ln_dtls
									   (p_api_version,
									    p_init_msg_list,
									    x_return_status,
									    x_msg_count,
									    x_msg_data,
									    i_tldv_rec,
									    r_tldv_rec);
			       IF (x_return_status = 'S' ) THEN
				  print_debug ('        -- Internal TXN Details Created.');
			       ELSE
				  print_debug ('        -- ERROR: Creating Internal TXN Details.');

				  FOR i in 1..x_msg_count
				  LOOP
				     FND_MSG_PUB.GET(
						     p_msg_index     => i,
						     p_encoded       => FND_API.G_FALSE,
						     p_data          => x_msg_data,
						     p_msg_index_out => l_msg_index_out
						    );
				     print_debug('Error '||to_char(i)||': '||x_msg_data);
				     print_debug('Message Index: '||l_msg_index_out);
				  END LOOP;
			       END IF;

			       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
				 print_error_message('Unexpected error raised in call to Okl_Txd_Ar_Ln_Dtls_Pub.insert_txd_ar_ln_dtls');
				 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
			       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
				 print_error_message('Error raised in call to Okl_Txd_Ar_Ln_Dtls_Pub.insert_txd_ar_ln_dtls');
				 RAISE create_stream_invoice_failed;
			       END IF;

			       l_bpd_acc_rec.id           := r_tldv_rec.id;
			       l_bpd_acc_rec.source_table := 'OKL_TXD_AR_LN_DTLS_B';

			       Okl_Acc_Call_Pub.CREATE_ACC_TRANS(
								 p_api_version,
								 p_init_msg_list,
								 x_return_status,
								 x_msg_count,
								 x_msg_data,
								 l_bpd_acc_rec
								);

			      IF (x_return_status = 'S' ) THEN
				 print_debug ('        -- Accounting Distributions Created.');
			      ELSE
				 print_debug ('        -- ERROR: Accounting Distributions NOT Created.');

				 FOR i in 1..x_msg_count
				 LOOP
				    FND_MSG_PUB.GET(
						    p_msg_index     => i,
						    p_encoded       => FND_API.G_FALSE,
						    p_data          => x_msg_data,
						    p_msg_index_out => l_msg_index_out
						   );
				    print_debug('Error '||to_char(i)||': '||x_msg_data);
				    print_error_message ('Error'||to_char(i)||': '|| x_msg_data);
				    print_debug('Message Index: '||l_msg_index_out);
				    print_error_message('Message Index: '|| l_msg_index_out);
				 END LOOP;
			      END IF;

			      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
				print_error_message('Unexpected error raised in call to Okl_Acc_Call_Pub.CREATE_ACC_TRANS');
				RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
			      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
				print_error_message('Error raised in call to Okl_Acc_Call_Pub.CREATE_ACC_TRANS');
				RAISE create_stream_invoice_failed;
			      END IF;*/ -- end commenting existing code for common billing API call

    -- End - Billing Inline changes - Bug#5898792 - varangan - 28/2/2007

    END IF;

    IF (p_process_flag in ('DAILY_INTEREST', 'PRINCIPAL_CATCHUP')) THEN
       print_debug('Stream Type Purpose: '|| p_stream_type_purpose);
       IF (p_stream_type_purpose IN ('DAILY_INTEREST_PRINCIPAL', 'DAILY_INTEREST_INTEREST')) THEN
          ------------------------------------------------------------
          -- Create Contract Transaction Header and Line
          -- in Submitted Status
          ------------------------------------------------------------
          IF (G_RCPT_APP_TRX_TYPE_ID IS NULL) THEN
            OPEN trx_type_csr('Receipt Application');
            FETCH trx_type_csr INTO G_RCPT_APP_TRX_TYPE_ID, G_RCPT_APP_TRX_TRY_ID, G_RCPT_APP_TRX_DESC;
            IF (trx_type_csr%NOTFOUND) THEN
              CLOSE trx_type_csr;
              print_error_message('Transaction type cursor did not return any records');
              RAISE create_stream_invoice_failed;
            END IF;
            CLOSE trx_type_csr;
          END IF;
          l_trx_type_id := G_RCPT_APP_TRX_TYPE_ID;
          l_trx_try_id  := G_RCPT_APP_TRX_TRY_ID;
		  l_trx_desc    := G_RCPT_APP_TRX_DESC;

          IF (G_RAP_TCN_TYPE IS NULL) THEN
            OPEN fnd_lookup_csr('OKL_TCN_TYPE', 'RAP');
            FETCH fnd_lookup_csr INTO G_RAP_TCN_TYPE,G_RAP_TCN_MEANING, G_RAP_TCN_DESC;
            IF (fnd_lookup_csr%NOTFOUND) THEN
              CLOSE fnd_lookup_csr;
               print_error_message('FND lookup cursor did not return any records');
               RAISE create_stream_invoice_failed;
            END IF;
            CLOSE fnd_lookup_csr;
          END IF;

		  l_tcn_type    := G_RAP_TCN_TYPE;
		  l_tcn_meaning := G_RAP_TCN_MEANING;
		  l_tcn_desc    := G_RAP_TCN_DESC;
-- new
       ELSIF (p_stream_type_purpose IN ('PRINCIPAL_CATCHUP')) THEN
          ------------------------------------------------------------
          -- Create Contract Transaction Header and Line for Principal Adjustment
          -- in Submitted Status
          ------------------------------------------------------------
          IF (G_PAD_TRX_TYPE_ID IS NULL) THEN
            OPEN trx_type_csr('Principal Adjustment');
            FETCH trx_type_csr INTO G_PAD_TRX_TYPE_ID, G_PAD_TRX_TRY_ID, G_PAD_TRX_DESC;
            IF (trx_type_csr%NOTFOUND) THEN
              CLOSE trx_type_csr;
              print_error_message('Transaction type cursor did not return any records');
              RAISE create_stream_invoice_failed;
            END IF;
            CLOSE trx_type_csr;
          END IF;
          l_trx_type_id := G_PAD_TRX_TYPE_ID;
          l_trx_try_id  := G_PAD_TRX_TRY_ID;
		  l_trx_desc    := G_PAD_TRX_DESC;

          IF (G_PAD_TCN_TYPE IS NULL) THEN
            OPEN fnd_lookup_csr('OKL_TCN_TYPE', 'PAD');
            FETCH fnd_lookup_csr INTO G_PAD_TCN_TYPE,G_PAD_TCN_MEANING, G_PAD_TCN_DESC;
            IF (fnd_lookup_csr%NOTFOUND) THEN
              CLOSE fnd_lookup_csr;
               print_error_message('FND lookup cursor did not return any records');
               RAISE create_stream_invoice_failed;
            END IF;
            CLOSE fnd_lookup_csr;
          END IF;

		  l_tcn_type    := G_PAD_TCN_TYPE;
		  l_tcn_meaning := G_PAD_TCN_MEANING;
		  l_tcn_desc    := G_PAD_TCN_DESC;

       END IF; -- new

          print_debug('G_CONTRACT_ID : '|| G_CONTRACT_ID);
          print_debug('l_tcn_type: '|| l_tcn_type);
          print_debug('l_trx_desc: '|| l_trx_desc);
          print_debug('l_trx_type_id: '|| l_trx_type_id);

          l_trxH_in_rec.khr_id                     := p_contract_id;
          l_trxH_in_rec.pdt_id                     := G_PRODUCT_ID;
          l_trxH_in_rec.set_of_books_id            := l_set_of_books_id;
          l_trxH_in_rec.tsu_code                   := 'PROCESSED';
          l_trxH_in_rec.tcn_type                   := l_tcn_type; --G_RAP_TCN_TYPE;
          l_trxH_in_rec.description                := l_trx_desc; --G_RCPT_APP_TRX_DESC;
          l_trxH_in_rec.date_transaction_occurred  := p_due_date;
          l_trxH_in_rec.try_id                     := l_trx_type_id; --G_RCPT_APP_TRX_TYPE_ID;
          l_trxH_in_rec.amount                     := p_amount;
          l_trxH_in_rec.currency_code              := G_CURRENCY_CODE;
          l_trxH_in_rec.org_id                     := G_AUTHORING_ORG_ID;
          l_trxH_in_rec.request_id                 := g_request_id;
	  -- Bug 5964482 dpsingh for AE signature Uptake  start
         OPEN get_dff_fields(p_contract_id);
         FETCH get_dff_fields into l_trxH_in_rec.ATTRIBUTE_CATEGORY,
                                                l_trxH_in_rec.ATTRIBUTE1,
                                                l_trxH_in_rec.ATTRIBUTE2,
                                                l_trxH_in_rec.ATTRIBUTE3,
                                                l_trxH_in_rec.ATTRIBUTE4,
                                                l_trxH_in_rec.ATTRIBUTE5,
                                                l_trxH_in_rec.ATTRIBUTE6,
                                                l_trxH_in_rec.ATTRIBUTE7,
                                                l_trxH_in_rec.ATTRIBUTE8,
                                                l_trxH_in_rec.ATTRIBUTE9,
                                                l_trxH_in_rec.ATTRIBUTE10,
                                                l_trxH_in_rec.ATTRIBUTE11,
                                                l_trxH_in_rec.ATTRIBUTE12,
                                                l_trxH_in_rec.ATTRIBUTE13,
                                                l_trxH_in_rec.ATTRIBUTE14,
                                                l_trxH_in_rec.ATTRIBUTE15;
          CLOSE get_dff_fields;
	  -- Bug 5964482 dpsingh for AE signature Uptake  start
	 -- Added by dpsingh for LE Uptake
	  l_trxH_in_rec.legal_entity_id := l_legal_entity_id;

          IF (p_stream_type_purpose IN ('DAILY_INTEREST_PRINCIPAL', 'DAILY_INTEREST_INTEREST')) THEN

            IF (G_RAP_TCL_TYPE IS NULL) THEN
              OPEN fnd_lookup_csr('OKL_TCL_TYPE', 'RAP');
              FETCH fnd_lookup_csr INTO G_RAP_TCL_TYPE,G_RAP_TCL_MEANING, G_RAP_TCL_DESC;
              IF (fnd_lookup_csr%NOTFOUND) THEN
                CLOSE fnd_lookup_csr;
                print_error_message('FND lookup cursor did not return any records');
                RAISE create_stream_invoice_failed;
              END IF;
              CLOSE fnd_lookup_csr;
            END IF;
            l_tcl_type    := G_RAP_TCL_TYPE;
            l_tcl_meaning := G_RAP_TCL_MEANING;
            l_tcl_desc    := G_RAP_TCL_DESC;
          ELSIF (p_stream_type_purpose  = 'PRINCIPAL_CATCHUP') THEN
            IF (G_PAD_TCL_TYPE IS NULL) THEN
              OPEN fnd_lookup_csr('OKL_TCL_TYPE', 'PAD');
              FETCH fnd_lookup_csr INTO G_PAD_TCL_TYPE,G_PAD_TCL_MEANING, G_PAD_TCL_DESC;
              IF (fnd_lookup_csr%NOTFOUND) THEN
                CLOSE fnd_lookup_csr;
                print_error_message('FND lookup cursor did not return any records');
                RAISE create_stream_invoice_failed;
              END IF;
              CLOSE fnd_lookup_csr;
            END IF;
            l_tcl_type    := G_PAD_TCL_TYPE;
            l_tcl_meaning := G_PAD_TCL_MEANING;
            l_tcl_desc    := G_PAD_TCL_DESC;
          END IF;

          print_debug('l_tcl_type : '||l_tcl_type);
          print_debug('l_tcl_desc : '||l_tcl_desc);

          l_trxL_in_tbl(1).line_number             := 1;
          l_trxL_in_tbl(1).khr_id                  := p_contract_id;
          l_trxL_in_tbl(1).sty_id                  := l_sty_id;
          l_trxL_in_tbl(1).tcl_type                := l_tcl_type; --G_RAP_TCL_TYPE;
          l_trxL_in_tbl(1).description             := l_tcl_desc; --G_RAP_TCL_DESC;
          l_trxL_in_tbl(1).amount                  := p_amount;
          l_trxL_in_tbl(1).currency_code           := G_CURRENCY_CODE;

          FND_FILE.PUT_LINE (FND_FILE.LOG, 'Creating Contract Transaction.');
          Okl_Trx_Contracts_Pub.create_trx_contracts(
                  p_api_version      => l_api_version,
                  p_init_msg_list    => p_init_msg_list,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data,
                  p_tcnv_rec         => l_trxH_in_rec,
                  p_tclv_tbl         => l_trxL_in_tbl,
                  x_tcnv_rec         => l_trxH_out_rec,
			      x_tclv_tbl         => l_trxL_out_tbl);

          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            print_error_message('Unexpected error raised in call to Okl_Trx_Contracts_Pub.create_trx_contracts');
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
            print_error_message('Error raised in call to Okl_Trx_Contracts_Pub.create_trx_contracts');
            RAISE create_stream_invoice_failed;
          END IF;

          IF ((l_trxH_out_rec.id = OKL_API.G_MISS_NUM) OR
              (l_trxH_out_rec.id IS NULL) ) THEN
             OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'TRANSACTION_ID');
             print_error_message ('ERROR : OKL transaction ID is NULL');
             RAISE create_stream_invoice_failed;
          END IF;

          l_okl_trx_created := OKL_API.G_TRUE;

   	      ------------------------------------------------------------
  	      -- Derive and Insert Distribution Line
	      ------------------------------------------------------------

          FND_FILE.PUT_LINE ( FND_FILE.LOG, '      -- Creating Distributions. Supplied parameters:');

          ------------------ Accounting Engine Calls --------------------------
--START: Changes by dpsingh for SLA Uptake, Bug #5964482
Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen (
                                                                p_contract_id        => p_contract_id,
                                                                p_contract_line_id => p_line_id,
                                                                x_acc_gen_tbl      => l_acc_gen_primary_key_tbl,
                                                                x_return_status	 => x_return_status);

   print_debug('End Debug OKLRVARB.pls call Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen  ');
   IF ( x_return_status = okl_api.g_ret_sts_success) THEN
     FND_FILE.PUT_LINE (FND_FILE.LOG, '      -- Accounting engine called successfully  ');
   ELSE
     FND_FILE.PUT_LINE (FND_FILE.LOG, '*=> ERROR : Calling Accounting engine.');
     IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       print_error_message('Unexpected error raised in call to Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen');
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
        print_error_message('Error raised in call to Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen');
        RAISE create_stream_invoice_failed;
       END IF;
     END IF;
l_tcn_id := l_trxH_out_rec.id;
IF l_trxL_out_tbl.count >0 THEN
  FOR i IN l_trxL_out_tbl.FIRST..l_trxL_out_tbl.LAST
  LOOP
    l_acc_gen_tbl(i).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
    l_acc_gen_tbl(i).source_id := l_trxL_out_tbl(i).id;

    l_tmpl_identify_tbl(i).product_id             := G_PRODUCT_ID;
    l_tmpl_identify_tbl(i).transaction_type_id    := l_trx_type_id; --G_RCPT_APP_TRX_TYPE_ID;
    l_tmpl_identify_tbl(i).stream_type_id         := l_sty_id;
    l_tmpl_identify_tbl(i).ADVANCE_ARREARS        := NULL;
    l_tmpl_identify_tbl(i).FACTORING_SYND_FLAG    := NULL;
    l_tmpl_identify_tbl(i).SYNDICATION_CODE       := NULL;
    l_tmpl_identify_tbl(i).FACTORING_CODE         := NULL;
    l_tmpl_identify_tbl(i).MEMO_YN                := 'N';
    l_tmpl_identify_tbl(i).PRIOR_YEAR_YN          := 'N';

      -- 4872347 Modified the source table and source id
    l_dist_info_tbl(i).source_id		    	   := l_trxL_out_tbl(1).id;
    l_dist_info_tbl(i).source_table			   := 'OKL_TXL_CNTRCT_LNS';
    l_dist_info_tbl(i).accounting_date		   := p_due_date;
    l_dist_info_tbl(i).gl_reversal_flag		   := 'N';
    l_dist_info_tbl(i).post_to_gl			   := 'Y';
    l_dist_info_tbl(i).amount				   := p_amount;
    l_dist_info_tbl(i).currency_code			   := G_CURRENCY_CODE;
    l_dist_info_tbl(i).contract_id			   := p_contract_id;
    l_dist_info_tbl(i).contract_line_id     	   := p_line_id;
  END LOOP;
END IF;

          print_debug('Begin Debug OKLRVARB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');

       -- Call new signature
         Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
                                                                                         p_api_version        => p_api_version,
                                                                                         p_init_msg_list      => p_init_msg_list,
                                                                                         x_return_status      => x_return_status,
                                                                                         x_msg_count          => x_msg_count,
                                                                                         x_msg_data           => x_msg_data,
                                                                                         p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
                                                                                         p_dist_info_tbl      => l_dist_info_tbl,
                                                                                         p_ctxt_val_tbl       => l_ctxt_tbl,
                                                                                         p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                                                                         x_template_tbl       => l_template_out_tbl,
                                                                                         x_amount_tbl         => l_amount_out_tbl,
                                                                                         p_trx_header_id      => l_tcn_id);

 --END: Changes by dpsingh for SLA Uptake, Bug #5964482

          print_debug('End Debug OKLRVARB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');

	      IF ( x_return_status = okl_api.g_ret_sts_success) THEN
	         FND_FILE.PUT_LINE (FND_FILE.LOG, '      -- Accounting distributions created.  ');
	      ELSE
	         FND_FILE.PUT_LINE (FND_FILE.LOG, '*=> ERROR : Accounting distributions not created.'||x_msg_count || x_msg_data);
             IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
               print_error_message('Unexpected error raised in call to Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST');
               RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
               print_error_message('Error raised in call to Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST');
               RAISE create_stream_invoice_failed;
             END IF;
	      END IF;
--       END IF;

    -- Bug 7624242. SGIYER. Uncommented the MG Engine call for Variable Rate Contracts
    -- moved the call to MG engine here .. racheruv. Bug 7690456
   OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,P_TCNV_REC => l_trxH_out_rec
                           ,P_TCLV_TBL => l_trxL_out_tbl
                           ,p_ctxt_val_tbl => l_ctxt_tbl
                           ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        print_error_message('Unexpected error raised in call to OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX');
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        print_error_message('Error raised in call to OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
     -- end the call to MG engine .. racheruv. Bug 7690456
 END IF;


  EXCEPTION
    WHEN create_stream_invoice_failed THEN
      print_error_message('Exception create_stream_invoice_failed raised in procedure CREATE_STREAM_INVOICE');
      IF (stream_csr%ISOPEN) THEN
        CLOSE stream_csr;
      END IF;

      IF (trx_type_csr%ISOPEN) THEN
        CLOSE trx_type_csr;
      END IF;

      IF (set_of_books_csr%ISOPEN) THEN
        CLOSE set_of_books_csr;
      END IF;
      /*
      IF l_sec_rep_method_csr%ISOPEN THEN
        CLOSE l_sec_rep_method_csr;
      END IF;
      */
      IF rep_stream_csr%ISOPEN THEN
        CLOSE rep_stream_csr;
      END IF;

      -- Daily Interest calculation conc. program does not use savepoint. Delete the streams/Trx
      IF (p_process_flag = 'DAILY_INTEREST') THEN
        IF (l_strm_element_created = OKL_API.G_TRUE) THEN
          OKL_STREAMS_PUB.delete_stream_elements(
              p_api_version   => 1.0,
              p_init_msg_list => OKC_API.G_FALSE,
              x_return_status => x_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_selv_rec      => lx_selv_rec);
        END IF;
        IF (l_stream_created = OKL_API.G_TRUE) THEN
          OKL_STREAMS_PUB.delete_streams(
              p_api_version   => 1.0,
              p_init_msg_list => OKC_API.G_FALSE,
              x_return_status => x_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_stmv_rec      => lx_stmv_rec);
        END IF;

        IF (l_okl_trx_created = OKL_API.G_TRUE) THEN
          OKL_TRX_CONTRACTS_PUB.delete_trx_contracts(
              p_api_version   => 1.0,
              p_init_msg_list => OKC_API.G_FALSE,
              x_return_status => x_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_tcnv_rec      => l_trxH_out_rec);
        END IF;

      END IF;
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      print_error_message('Exception raised in procedure CREATE_STREAM_INVOICE');
      IF (stream_csr%ISOPEN) THEN
        CLOSE stream_csr;
      END IF;

      IF (trx_type_csr%ISOPEN) THEN
        CLOSE trx_type_csr;
      END IF;

      IF (set_of_books_csr%ISOPEN) THEN
        CLOSE set_of_books_csr;
      END IF;
      /*
      IF l_sec_rep_method_csr%ISOPEN THEN
        CLOSE l_sec_rep_method_csr;
      END IF;
      */
      IF rep_stream_csr%ISOPEN THEN
        CLOSE rep_stream_csr;
      END IF;
      -- Daily Interest calculation conc. program does not use savepoint. Delete the streams/Trx
      IF (p_process_flag = 'DAILY_INTEREST') THEN
        IF (l_strm_element_created = OKL_API.G_TRUE) THEN
          OKL_STREAMS_PUB.delete_stream_elements(
              p_api_version   => 1.0,
              p_init_msg_list => OKC_API.G_FALSE,
              x_return_status => x_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_selv_rec      => lx_selv_rec);
        END IF;
        IF (l_stream_created = OKL_API.G_TRUE) THEN
          OKL_STREAMS_PUB.delete_streams(
              p_api_version   => 1.0,
              p_init_msg_list => OKC_API.G_FALSE,
              x_return_status => x_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_stmv_rec      => lx_stmv_rec);
        END IF;

        IF (l_okl_trx_created = OKL_API.G_TRUE) THEN
          OKL_TRX_CONTRACTS_PUB.delete_trx_contracts(
              p_api_version   => 1.0,
              p_init_msg_list => OKC_API.G_FALSE,
              x_return_status => x_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_tcnv_rec      => l_trxH_out_rec);
        END IF;

      END IF;

      Okl_Api.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_ERROR;

  END Create_Stream_Invoice;

------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    UPD_VIR_PARAMS_WITH_INVOICE
    -- Description:      This procedure is called by Variable Interest Calculation for Loans
    --                   Inputs :
    --                   Output : Interest Calculated
    -- Dependencies:
    -- Parameters:       Start Date, End Date, Interest Rate Range.
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  Procedure upd_vir_params_with_invoice (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_source_id          IN  NUMBER,
            p_vir_tbl            IN  vir_tbl_type,
            x_vir_tbl            OUT NOCOPY vir_tbl_type) IS

  l_api_name                  CONSTANT    VARCHAR2(30) := 'UPD_VIR_PARAMS_WITH_INVOICE';
  l_api_version               CONSTANT    NUMBER       := 1.0;
  l_index                     NUMBER := 0;

  BEGIN
    x_return_status               := OKL_API.G_RET_STS_SUCCESS;
    x_vir_tbl                    := p_vir_tbl;

    print_debug('Executing procedure UPD_VIR_PARAMS_WITH_INVOICE using following parameters : ');
    print_debug(' p_source_id : '|| p_source_id );
    print_debug(' g_vir_tbl_counter : '|| g_vir_tbl_counter );
    -- 5034946
    IF (NVL(g_vir_tbl_counter,0) > 0 ) THEN
      FOR l_index in 1 .. g_vir_tbl_counter
      LOOP
        x_vir_tbl(l_index).source_id := p_source_id;
      END LOOP;
    END IF;

 EXCEPTION

     WHEN OTHERS THEN
       print_error_message('Exception raised in procedure UPD_VIR_PARAMS_WITH_INVOICE');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        Okl_Api.SET_MESSAGE(
            p_app_name     => G_APP_NAME,
            p_msg_name     => G_UNEXPECTED_ERROR,
            p_token1       => G_SQLCODE_TOKEN,
            p_token1_value => SQLCODE,
            p_token2       => G_SQLERRM_TOKEN,
            p_token2_value => SQLERRM);

  END upd_vir_params_with_invoice;

------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    print_g_vir_tbl
    -- Description:      This procedure prints all the records in the PL/SQL table g_vir_tbl
    --
    -- Dependencies:
    -- Parameters:       .
    -- Version:          1.0
    -- End of Comments

------------------------------------------------------------------------------

  PROCEDURE print_vir_tbl ( p_vir_tbl IN  vir_tbl_type) IS

  l_rec_count    NUMBER;
  l_index        NUMBER;
  l_counter      NUMBER := 0;
  BEGIN
       l_rec_count      := p_vir_tbl.COUNT;
       IF (l_rec_count > 0) THEN
          l_index          := p_vir_tbl.FIRST;
          print_debug('VIR Table : ');
       ELSE
          print_debug('No records exist in the table');
       END IF;
       FOR l_vir_tbl_counter in 1 .. l_rec_count
       LOOP
          l_counter     := l_counter + 1;
          print_debug( 'Record Number : '||l_counter);
		  print_debug( 'id : '||p_vir_tbl(l_index).id );
		  print_debug( 'khr_id : '||p_vir_tbl(l_index).khr_id);
          print_debug( 'source_table : '|| p_vir_tbl(l_index).source_table);
          print_debug( 'source_id : '|| p_vir_tbl(l_index).source_id);
          print_debug( 'interest_rate : '|| p_vir_tbl(l_index).interest_rate);
          print_debug( 'interest_calc_start_date : '|| p_vir_tbl(l_index).interest_calc_start_date);
          print_debug( 'interest_calc_end_date : '|| p_vir_tbl(l_index).interest_calc_end_date);
          print_debug( 'calc_method_code : '|| p_vir_tbl(l_index).calc_method_code);
          print_debug( 'principal_balance : '|| p_vir_tbl(l_index).principal_balance);
          print_debug( 'valid_yn : '|| p_vir_tbl(l_index).valid_yn);
          print_debug( 'Object_Version_Number : '|| p_vir_tbl(l_index).Object_Version_Number);
          print_debug( 'Org ID : '|| p_vir_tbl(l_index).Org_id);
          print_debug( 'request ID : '|| p_vir_tbl(l_index).request_id);
          print_debug( 'Program Application ID : '|| p_vir_tbl(l_index).program_application_id);
          print_debug( 'program ID : '|| p_vir_tbl(l_index).program_id);
          print_debug( 'Program Update date : '|| p_vir_tbl(l_index).program_update_date);
          print_debug( 'attribute category : '|| p_vir_tbl(l_index).attribute_category);
          print_debug( 'attribute1 : '|| p_vir_tbl(l_index).attribute1);
          print_debug( 'attribute2 : '|| p_vir_tbl(l_index).attribute2);
          print_debug( 'attribute3 : '|| p_vir_tbl(l_index).attribute3);
          print_debug( 'attribute4 : '|| p_vir_tbl(l_index).attribute4);
          print_debug( 'attribute5 : '|| p_vir_tbl(l_index).attribute5);
          print_debug( 'attribute6 : '|| p_vir_tbl(l_index).attribute6);
          print_debug( 'attribute7 : '|| p_vir_tbl(l_index).attribute7);
          print_debug( 'attribute8 : '|| p_vir_tbl(l_index).attribute8);
          print_debug( 'attribute9 : '|| p_vir_tbl(l_index).attribute9);
          print_debug( 'attribute10 : '|| p_vir_tbl(l_index).attribute10);
          print_debug( 'attribute11 : '|| p_vir_tbl(l_index).attribute11);
          print_debug( 'attribute12 : '|| p_vir_tbl(l_index).attribute12);
          print_debug( 'attribute13 : '|| p_vir_tbl(l_index).attribute13);
          print_debug( 'attribute14 : '|| p_vir_tbl(l_index).attribute14);
          print_debug( 'attribute15 : '|| p_vir_tbl(l_index).attribute15);
          print_debug( 'created_by : '|| p_vir_tbl(l_index).created_by);
          print_debug( 'creation_date : '|| p_vir_tbl(l_index).creation_date);
          print_debug( 'last_updated_by : '|| p_vir_tbl(l_index).last_updated_by);
          print_debug( 'last_update_date : '|| p_vir_tbl(l_index).last_update_date);
          print_debug( 'last_update_login : '|| p_vir_tbl(l_index).last_update_login);
          print_debug( 'interest_amt : '|| p_vir_tbl(l_index).interest_amt);
          print_debug( 'interest_calc_days : '|| p_vir_tbl(l_index).interest_calc_days);
          l_index       := p_vir_tbl.NEXT(l_index);
       END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
       print_error_message('Exception raised in procedure PRINT_VIR_TBL');
       Okl_Api.SET_MESSAGE(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_UNEXPECTED_ERROR,
               p_token1       => G_SQLCODE_TOKEN,
               p_token1_value => SQLCODE,
               p_token2       => G_SQLERRM_TOKEN,
               p_token2_value => SQLERRM);
  END;

------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    POPULATE_VIR_PARAMS
    -- Description:      This procedure is called by Variable Interest Calculation for Loans
    --                   Inputs :
    --                   Output : Interest Calculated
    -- Dependencies:
    -- Parameters:       Start Date, End Date, Interest Rate Range.
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  Procedure populate_vir_params(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_vir_tbl           IN  vir_tbl_type) IS

  l_api_name                  CONSTANT    VARCHAR2(30) := 'POPULATE_VIR_PARAMS';
  l_api_version               CONSTANT    NUMBER       := 1.0;
  l_index                     NUMBER := 0;

  BEGIN
    x_return_status               := OKL_API.G_RET_STS_SUCCESS;

    print_debug('Executing procedure POPULATE_VIR_PARAMS using following parameters : ');
    print_debug(' p_vir_tbl.count : '|| p_vir_tbl.COUNT );
    print_vir_tbl (p_vir_tbl);

    IF (p_vir_tbl.COUNT > 0) THEN
  	   FORALL l_index in p_vir_tbl.FIRST .. p_vir_tbl.LAST
  	   save exceptions
       INSERT INTO okl_var_int_params VALUES p_vir_tbl(l_index);

        print_debug ('Exception count : '|| sql%bulk_exceptions.count);
       IF sql%bulk_exceptions.count > 0 then
          for i in 1..sql%bulk_exceptions.count loop
              print_debug('while fetching, error ' || i || ' occurred during '||
                  'iteration ' || sql%bulk_exceptions(i).error_index);
              print_debug('oracle error is ' ||
                  sqlerrm(sql%bulk_exceptions(i).error_code));

          end loop;
        end if;
       print_debug ('No. of records inserted : '|| SQL%rowcount);

    END IF;

 EXCEPTION
     WHEN OTHERS THEN
       print_error_message('Exception raised in procedure POPULATE_VIR_PARAMS');
       print_debug ('Exception during bulk insert');
       print_debug ('Exception count : '|| sql%bulk_exceptions.count);
       IF sql%bulk_exceptions.count > 0 then
          for i in 1..sql%bulk_exceptions.count loop
              print_debug('while fetching, error ' || i || ' occurred during '||
                  'iteration ' || sql%bulk_exceptions(i).error_index);
              print_debug('oracle error is ' ||
                  sqlerrm(sql%bulk_exceptions(i).error_code));

          end loop;
       END IF;

       x_return_status := OKL_API.G_RET_STS_ERROR;
       Okl_Api.SET_MESSAGE(
           p_app_name     => G_APP_NAME,
           p_msg_name     => G_UNEXPECTED_ERROR,
           p_token1       => G_SQLCODE_TOKEN,
           p_token1_value => SQLCODE,
           p_token2       => G_SQLERRM_TOKEN,
           p_token2_value => SQLERRM);

  END populate_vir_params;

------------------------------------------------------------------------------

  FUNCTION calculate_from_khr_start_date(p_khr_id IN NUMBER,
            p_from_date IN DATE) RETURN VARCHAR2 IS

  l_return_value varchar2(10) := 'N';

  --checks for online rebook
  CURSOR l_rebook_csr(cp_khr_id NUMBER) IS
  SELECT 'Y' return_value
  FROM   okc_k_headers_b chrb,
         okc_k_headers_b chrb2,
          okl_trx_contracts ktrx
  WHERE  ktrx.khr_id_old = chrb.id
  AND    ktrx.tsu_code = 'PROCESSED'
  AND    ktrx.rbr_code IS NOT NULL
  AND    ktrx.tcn_type = 'TRBK'
  --rkuttiya added for 12.1.1 Multi GAAP
  AND    ktrx.representation_type = 'PRIMARY'
  --
  AND    chrb.id = cp_khr_id
  AND    chrb2.orig_system_source_code = 'OKL_REBOOK'
  AND    chrb2.id = ktrx.khr_id_new
  AND   NOT EXISTS (select 1 FROM OKL_VAR_PRINCIPAL_BAL_TXN vpb
                    WHERE vpb.khr_id = chrb.id
                    AND   vpb.source_table = 'OKL_TRX_CONTRACTS'
                    AND   vpb.int_cal_process = 'VARIABLE_INTEREST'
                    AND   vpb.source_id = ktrx.id);

  --checks if newly created Daily Interest - Principal stream elements exist
  --prior to date passed
  CURSOR l_daily_int_strm_csr(cp_khr_id NUMBER, cp_from_date DATE) IS
  SELECT 'Y' return_value
  FROM okl_streams     stm,
       okl_strm_type_b sty,
       okl_strm_elements sel
  WHERE	stm.khr_id = cp_khr_id
  AND	  stm.sty_id = sty.id
  AND   sty.stream_type_purpose = 'DAILY_INTEREST_PRINCIPAL'
  AND	  stm.id = sel.stm_id
  AND   sel.stream_element_date < cp_from_date
  AND   NOT EXISTS (select 1 FROM OKL_VAR_PRINCIPAL_BAL_TXN vpb
                    WHERE vpb.khr_id = stm.khr_id
                    AND   vpb.source_table = 'OKL_STRM_ELEMENTS_V'
                    AND   vpb.int_cal_process = 'VARIABLE_INTEREST'
                    AND   vpb.source_id = sel.id);

  --checks if newly created Principal Catchup stream elements exist
  --prior to date passed
  CURSOR l_prin_catch_strm_csr(cp_khr_id NUMBER, cp_from_date DATE) IS
  SELECT 'Y' return_value
  FROM okl_streams     stm,
       okl_strm_type_b sty,
       okl_strm_elements sel
  WHERE	stm.khr_id = cp_khr_id
  AND	  stm.sty_id = sty.id
  AND   sty.stream_type_purpose = 'PRINCIPAL_CATCHUP'
  AND	  stm.id = sel.stm_id
  AND   sel.stream_element_date < cp_from_date
  AND   NOT EXISTS (select 1 FROM OKL_VAR_PRINCIPAL_BAL_TXN vpb
                    WHERE vpb.khr_id = stm.khr_id
                    AND   vpb.source_table = 'OKL_STRM_ELEMENTS_V'
                    AND   vpb.int_cal_process = 'VARIABLE_INTEREST'
                    AND   vpb.source_id = sel.id);

  --checks if newly created Receipt Application to PRINCIPAL_PAYMENT, UNSCHEDULED_PRINCIPAL_PAYMENT exist
  --prior to date passed
 -- Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
--Bug# 6819044: Fetch receipt applications correctly when
--              invoices have lines from multiple contracts
CURSOR l_rcpt_app_csr(cp_khr_id NUMBER, cp_from_date DATE) IS
  SELECT 'Y' return_value
  FROM  okl_txd_ar_ln_dtls_b tld
       ,ra_customer_trx_lines_all ractrl
       ,okl_txl_ar_inv_lns_b til
       ,okl_trx_ar_invoices_b tai
       ,ar_payment_schedules_all aps
       ,ar_receivable_applications_all raa
       ,ar_cash_receipts_all cra
       ,okl_strm_type_b sty
  WHERE  tai.trx_status_code = 'PROCESSED'
  AND    tai.khr_id = cp_khr_id
  AND    tld.khr_id = cp_khr_id
  AND    ractrl.customer_trx_id = aps.customer_trx_id
  AND    raa.applied_customer_trx_id = aps.customer_trx_id
  AND    aps.class = 'INV'
  AND    raa.application_type IN ('CASH','CM')
  AND    raa.status = 'APP'
  AND    cra.receipt_date < cp_from_date
  AND    raa.cash_receipt_id = cra.cash_receipt_id
  AND    tld.sty_id = sty.id
  AND    sty.stream_type_purpose IN ('PRINCIPAL_PAYMENT', 'UNSCHEDULED_PRINCIPAL_PAYMENT')
  AND    to_char(tld.id) = ractrl.interface_line_attribute14
  AND    tld.til_id_details = til.id
  AND    til.tai_id = tai.id
  AND   NOT EXISTS (select 1 FROM OKL_VAR_PRINCIPAL_BAL_TXN vpb
                    WHERE vpb.khr_id = tld.khr_id
                    AND   vpb.source_table = 'AR_RECEIVABLE_APPLICATIONS_ALL'
                    AND   vpb.int_cal_process = 'VARIABLE_INTEREST'
                    AND   vpb.source_id = raa.receivable_application_id)
  AND    EXISTS (SELECT 1
                 FROM ar_distributions_all ad
                 WHERE raa.receivable_application_id = ad.source_id
                 AND ad.source_table = 'RA'
                 AND (ad.ref_customer_trx_Line_Id IS NULL OR
                      ad.ref_customer_trx_Line_Id = ractrl.customer_trx_line_id));
-- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007

  --checks if newly created Borrower Payment exist
  --prior to date passed
  -- sjalasut, modified the cursor to have khr_id be passed from okl_txl_ap_inv_lns_all_b
  CURSOR l_borrow_payment_csr(cp_khr_id NUMBER, cp_from_date DATE) IS
  SELECT 'Y' return_value
  FROM ap_invoices_all ap_inv,
       okl_trx_ap_invoices_v okl_inv,
       ap_invoice_payment_history_v iph
      ,okl_cnsld_ap_invs_all cnsld
      ,okl_txl_ap_inv_lns_all_b okl_inv_ln
      ,fnd_application fnd_app
    WHERE okl_inv.id = okl_inv_ln.tap_id
      AND okl_inv_ln.khr_id = cp_khr_id
      AND ap_inv.application_id = fnd_app.application_id
      AND fnd_app.application_short_name = 'OKL'
      AND okl_inv_ln.cnsld_ap_inv_id = cnsld.cnsld_ap_inv_id
      AND cnsld.cnsld_ap_inv_id = to_number(ap_inv.reference_key1)
      AND okl_inv.funding_type_code = 'BORROWER_PAYMENT'
      AND ap_inv.invoice_id = iph.invoice_id
      AND iph.check_date < cp_from_date
      AND NOT EXISTS (select 1 FROM OKL_VAR_PRINCIPAL_BAL_TXN vpb
                    WHERE vpb.khr_id = okl_inv_ln.khr_id
                    AND   vpb.source_table = 'AP_INVOICE_PAYMENTS_ALL'
                    AND   vpb.int_cal_process = 'VARIABLE_INTEREST'
                    AND   vpb.source_id = iph.invoice_payment_id);

  --checks if newly created records for okl_contract_balances which have the asset balances
  --as of the partial termination date exist prior to date passed
  CURSOR l_partial_term_csr(cp_khr_id NUMBER, cp_from_date DATE) IS
  SELECT 'Y' return_value
  FROM   okl_contract_balances ocb
  WHERE  ocb.khr_id = cp_khr_id
  AND    ocb.termination_date < cp_from_date
  AND   NOT EXISTS (select 1 FROM OKL_VAR_PRINCIPAL_BAL_TXN vpb
                    WHERE vpb.khr_id = ocb.khr_id
                    AND   vpb.source_table = 'OKL_CONTRACT_BALANCES'
                    AND   vpb.int_cal_process = 'VARIABLE_INTEREST'
                    AND   vpb.source_id = ocb.id);

  BEGIN
    print_debug('Executing function calculate_from_khr_start_date');

    print_debug('Before Checking for existence of Rebook Transactions');
    OPEN l_rebook_csr(p_khr_id);
    FETCH l_rebook_csr INTO l_return_value;
    CLOSE l_rebook_csr;
    print_debug('After Checking for existence of Rebook Transactions');


    IF (G_DEAL_TYPE = 'LOAN') THEN
      IF (G_INTEREST_CALCULATION_BASIS = G_INT_CALC_BASIS_FLOAT) THEN
        IF (G_REVENUE_RECOGNITION_METHOD = 'ACTUAL') THEN
          print_debug('Deal Type => ' || G_DEAL_TYPE || ' Int Calc Basis => ' || G_INTEREST_CALCULATION_BASIS || ' Rev Rec Method => ' || G_REVENUE_RECOGNITION_METHOD);
          print_debug('Before Checking for existence of Daily Interest streams');
          IF (NVL(l_return_value, 'N') = 'N') THEN
            OPEN l_daily_int_strm_csr(p_khr_id, p_from_date);
            FETCH l_daily_int_strm_csr INTO l_return_value;
            CLOSE l_daily_int_strm_csr;
          END IF;
          print_debug('After Checking for existence of Daily Interest streams');
        ELSE
          --rev rec method = ESTIMATED AND BILLED
          print_debug('Deal Type => ' || G_DEAL_TYPE || ' Int Calc Basis => ' || G_INTEREST_CALCULATION_BASIS || ' Rev Rec Method => ' || G_REVENUE_RECOGNITION_METHOD);
          print_debug('Before Checking for existence of Receipt Applications');
          IF (NVL(l_return_value, 'N') = 'N') THEN
            OPEN l_rcpt_app_csr(p_khr_id, p_from_date);
            FETCH l_rcpt_app_csr INTO l_return_value;
            CLOSE l_rcpt_app_csr;
          END IF;
          print_debug('After Checking for existence of Receipt Applications');

          print_debug('Before Checking for existence of Early Termination records');
          IF (NVL(l_return_value, 'N') = 'N') THEN
            OPEN l_partial_term_csr(p_khr_id, p_from_date);
            FETCH l_partial_term_csr INTO l_return_value;
            CLOSE l_partial_term_csr;
          END IF;
          print_debug('After Checking for existence of Early Termination records');
        END IF;
      ELSIF (G_INTEREST_CALCULATION_BASIS = G_INT_CALC_BASIS_CATCHUP) THEN
          print_debug('Deal Type => ' || G_DEAL_TYPE || ' Int Calc Basis => ' || G_INTEREST_CALCULATION_BASIS || ' Rev Rec Method => ' || G_REVENUE_RECOGNITION_METHOD);
          print_debug('Before Checking for existence of Receipt Applications');
          IF (NVL(l_return_value, 'N') = 'N') THEN
            OPEN l_rcpt_app_csr(p_khr_id, p_from_date);
            FETCH l_rcpt_app_csr INTO l_return_value;
            CLOSE l_rcpt_app_csr;
          END IF;
          print_debug('After Checking for existence of Receipt Applications');

          print_debug('Before Checking for existence of Early Termination records');
          IF (NVL(l_return_value, 'N') = 'N') THEN
            OPEN l_partial_term_csr(p_khr_id, p_from_date);
            FETCH l_partial_term_csr INTO l_return_value;
            CLOSE l_partial_term_csr;
          END IF;
          print_debug('After Checking for existence of Early Termination records');

          print_debug('Before Checking for existence of Principal Catchup streams');
          IF (NVL(l_return_value, 'N') = 'N') THEN
            OPEN l_prin_catch_strm_csr(p_khr_id, p_from_date);
            FETCH l_prin_catch_strm_csr INTO l_return_value;
            CLOSE l_prin_catch_strm_csr;
          END IF;
          print_debug('After Checking for existence of Principal Catchup streams');

          print_debug('Before Checking for existence of Catchup settlement code');
          IF (NVL(l_return_value, 'N') = 'N') THEN
            IF (G_CATCHUP_SETTLEMENT_CODE = 'NOT_ADJUST') THEN
              l_return_value := 'Y';
            END IF;
          END IF;
          print_debug('After Checking for existence of Catchup settlement code');

      END IF;
    ELSIF (G_DEAL_TYPE ='LOAN-REVOLVING') THEN
      IF (G_REVENUE_RECOGNITION_METHOD = 'ACTUAL') THEN
        print_debug('Deal Type => ' || G_DEAL_TYPE || ' Int Calc Basis => ' || G_INTEREST_CALCULATION_BASIS || ' Rev Rec Method => ' || G_REVENUE_RECOGNITION_METHOD);

        print_debug('Before Checking for existence of Borrower payments');
        IF (NVL(l_return_value, 'N') = 'N') THEN
          OPEN l_borrow_payment_csr(p_khr_id, p_from_date);
          FETCH l_borrow_payment_csr INTO l_return_value;
          CLOSE l_borrow_payment_csr;
        END IF;
        print_debug('After Checking for existence of Borrower payments');

        print_debug('Before Checking for existence of Daily Interest streams');
        IF (NVL(l_return_value, 'N') = 'N') THEN
          OPEN l_daily_int_strm_csr(p_khr_id, p_from_date);
          FETCH l_daily_int_strm_csr INTO l_return_value;
          CLOSE l_daily_int_strm_csr;
        END IF;
        print_debug('After Checking for existence of Daily Interest streams');
      ELSE
        --rev rec method = ESTIMATED AND BILLED
        print_debug('Deal Type => ' || G_DEAL_TYPE || ' Int Calc Basis => ' || G_INTEREST_CALCULATION_BASIS || ' Rev Rec Method => ' || G_REVENUE_RECOGNITION_METHOD);
        print_debug('Before Checking for existence of Borrower payments');
        IF (NVL(l_return_value, 'N') = 'N') THEN
          OPEN l_borrow_payment_csr(p_khr_id, p_from_date);
          FETCH l_borrow_payment_csr INTO l_return_value;
          CLOSE l_borrow_payment_csr;
        END IF;
        print_debug('After Checking for existence of Borrower payments');

        print_debug('Before Checking for existence of Receipt Applications');
        IF (NVL(l_return_value, 'N') = 'N') THEN
          OPEN l_rcpt_app_csr(p_khr_id, p_from_date);
          FETCH l_rcpt_app_csr INTO l_return_value;
          CLOSE l_rcpt_app_csr;
        END IF;
        print_debug('After Checking for existence of Receipt Applications');
      END IF;
    END IF;
    return NVL(l_return_value, 'N');
  EXCEPTION
    WHEN OTHERS THEN
      return l_return_value;
  END calculate_from_khr_start_date;

------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       pgomes
    -- Procedure Name    populate_txns
    -- Description:      This procedure populates g_vpb_tbl with Daily Interest
    --                   stream id, receipt app id, EOT id, Borrower payment id
    -- Dependencies:
    -- Parameters:       .
    -- Version:          1.0
    -- End of Comments

------------------------------------------------------------------------------

  PROCEDURE populate_txns ( p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_khr_id             IN NUMBER,
            p_from_date          IN DATE,
            p_to_date            IN DATE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2) IS

  l_api_name                  CONSTANT    VARCHAR2(30) := 'populate_txns';
  l_api_version               CONSTANT    NUMBER       := 1.0;
  L_FETCH_SIZE                CONSTANT    NUMBER := 100;
  l_source_id                 OKL_VAR_PRINCIPAL_BAL_TXN.source_id%TYPE;
  l_source_table              OKL_VAR_PRINCIPAL_BAL_TXN.source_table%TYPE;

  --get the id's of Rebook Transactions
  CURSOR l_rebook_csr(cp_khr_id NUMBER) IS
  SELECT ktrx.id source_id
        ,'OKL_TRX_CONTRACTS' source_table
  FROM   okc_k_headers_b chrb,
         okc_k_headers_b chrb2,
         okl_trx_contracts ktrx
  WHERE  ktrx.khr_id_old = chrb.id
  AND    ktrx.tsu_code = 'PROCESSED'
  AND    ktrx.rbr_code IS NOT NULL
  AND    ktrx.tcn_type = 'TRBK'
  --rkuttiya added for 12.1.1 Multi GAAP
 AND     ktrx.representation_type = 'PRIMARY'
  --
  AND    chrb.id = cp_khr_id
  AND    chrb2.orig_system_source_code = 'OKL_REBOOK'
  AND    chrb2.id = ktrx.khr_id_new
  AND   NOT EXISTS (select 1 FROM OKL_VAR_PRINCIPAL_BAL_TXN vpb
                    WHERE vpb.khr_id = chrb.id
                    AND   vpb.source_table = 'OKL_TRX_CONTRACTS'
                    AND   vpb.int_cal_process = 'VARIABLE_INTEREST'
                    AND   vpb.source_id = ktrx.id);

  --get the id's of Daily Interest - Principal stream elements
  CURSOR l_daily_int_strm_csr(cp_khr_id NUMBER, cp_from_date DATE, cp_to_date DATE) IS
  SELECT sel.id source_id
  , 'OKL_STRM_ELEMENTS_V' source_table
  FROM okl_streams     stm,
       okl_strm_type_b sty,
       okl_strm_elements sel
  WHERE	stm.khr_id = cp_khr_id
  AND	  stm.sty_id = sty.id
  AND   sty.stream_type_purpose = 'DAILY_INTEREST_PRINCIPAL'
  AND	  stm.id = sel.stm_id
  --AND   sel.stream_element_date BETWEEN cp_from_date AND cp_to_date
  AND   sel.stream_element_date <= cp_to_date
  AND   NOT EXISTS (select 1 FROM OKL_VAR_PRINCIPAL_BAL_TXN vpb
                    WHERE vpb.khr_id = stm.khr_id
                    AND   vpb.source_table = 'OKL_STRM_ELEMENTS_V'
                    AND   vpb.int_cal_process = 'VARIABLE_INTEREST'
                    AND   vpb.source_id = sel.id);

  --get the id's of Principal Catchup stream elements
  CURSOR l_prin_catch_strm_csr(cp_khr_id NUMBER, cp_from_date DATE, cp_to_date DATE) IS
  SELECT sel.id source_id
  , 'OKL_STRM_ELEMENTS_V' source_table
  FROM okl_streams     stm,
       okl_strm_type_b sty,
       okl_strm_elements sel
  WHERE	stm.khr_id = cp_khr_id
  AND	  stm.sty_id = sty.id
  AND   sty.stream_type_purpose = 'PRINCIPAL_CATCHUP'
  AND	  stm.id = sel.stm_id
  --AND   sel.stream_element_date BETWEEN cp_from_date AND cp_to_date
  AND   sel.stream_element_date <= cp_to_date
  AND   NOT EXISTS (select 1 FROM OKL_VAR_PRINCIPAL_BAL_TXN vpb
                    WHERE vpb.khr_id = stm.khr_id
                    AND   vpb.source_table = 'OKL_STRM_ELEMENTS_V'
                    AND   vpb.int_cal_process = 'VARIABLE_INTEREST'
                    AND   vpb.source_id = sel.id);

  --get the id's of Receipt Application to PRINCIPAL_PAYMENT, UNSCHEDULED_PRINCIPAL_PAYMENT
--Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
  --Bug# 6819044: Fetch receipt applications correctly when
  --              invoices have lines from multiple contracts
  --Bug# 7007130: Fetch unique receipt application ids for
  --              a contract
  CURSOR l_rcpt_app_csr(cp_khr_id NUMBER, cp_from_date DATE, cp_to_date DATE) IS
  SELECT DISTINCT raa.receivable_application_id source_id
  , 'AR_RECEIVABLE_APPLICATIONS_ALL' source_table
  FROM  okl_txd_ar_ln_dtls_b tld
       ,ra_customer_trx_lines_all ractrl
       ,okl_txl_ar_inv_lns_b til
       ,okl_trx_ar_invoices_b tai
       ,ar_payment_schedules_all aps
       ,ar_receivable_applications_all raa
       ,ar_cash_receipts_all cra
       ,okl_strm_type_b sty
  WHERE  tai.trx_status_code = 'PROCESSED'
  AND    tai.khr_id = cp_khr_id
  AND    tld.khr_id = cp_khr_id
  AND    ractrl.customer_trx_id  = aps.customer_trx_id
  AND    raa.applied_customer_trx_id = aps.customer_trx_id
  AND    aps.class = 'INV'
  AND    raa.application_type IN ('CASH','CM')
  AND    raa.status = 'APP'
  AND    cra.receipt_date <= cp_to_date
  AND    raa.cash_receipt_id = cra.cash_receipt_id
  AND    tld.sty_id  = sty.id
  AND    sty.stream_type_purpose IN ('PRINCIPAL_PAYMENT', 'UNSCHEDULED_PRINCIPAL_PAYMENT')
  AND    to_char(tld.id) = ractrl.interface_line_attribute14
  AND    tld.til_id_details = til.id
  AND    til.tai_id = tai.id
  AND   NOT EXISTS (select 1 FROM OKL_VAR_PRINCIPAL_BAL_TXN vpb
                    WHERE vpb.khr_id = tld.khr_id
                    AND   vpb.source_table = 'AR_RECEIVABLE_APPLICATIONS_ALL'
                    AND   vpb.int_cal_process = 'VARIABLE_INTEREST'
                    AND   vpb.source_id = raa.receivable_application_id)
  AND   EXISTS (SELECT 1
                FROM ar_distributions_all ad
                WHERE raa.receivable_application_id = ad.source_id
                AND ad.source_table = 'RA'
                AND (ad.ref_customer_trx_Line_Id IS NULL OR
                     ad.ref_customer_trx_Line_Id = ractrl.customer_trx_line_id));

-- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007

  --get the id's of Borrower Payment
  CURSOR l_borrow_payment_csr(cp_khr_id NUMBER, cp_from_date DATE, cp_to_date DATE) IS
  SELECT iph.invoice_payment_id source_id
  , 'AP_INVOICE_PAYMENTS_ALL' source_table
  FROM ap_invoices_all ap_inv,
       okl_trx_ap_invoices_v okl_inv,
       ap_invoice_payment_history_v iph
      ,okl_cnsld_ap_invs_all cnsld
      ,okl_txl_ap_inv_lns_all_b okl_inv_ln
      ,fnd_application fnd_app
 WHERE okl_inv.id = okl_inv_ln.tap_id
   AND okl_inv_ln.khr_id = cp_khr_id
   AND ap_inv.application_id = fnd_app.application_id
   AND fnd_app.application_short_name = 'OKL'
   AND okl_inv_ln.cnsld_ap_inv_id = cnsld.cnsld_ap_inv_id
   AND cnsld.cnsld_ap_inv_id = to_number(ap_inv.reference_key1)
   AND   okl_inv.funding_type_code = 'BORROWER_PAYMENT'
   AND   ap_inv.invoice_id = iph.invoice_id
  --AND   iph.check_date BETWEEN cp_from_date AND cp_to_date
   AND   iph.check_date <= cp_to_date
   AND   NOT EXISTS (select 1 FROM OKL_VAR_PRINCIPAL_BAL_TXN vpb
                    WHERE vpb.khr_id = okl_inv_ln.khr_id
                    AND   vpb.source_table = 'AP_INVOICE_PAYMENTS_ALL'
                    AND   vpb.int_cal_process = 'VARIABLE_INTEREST'
                    AND   vpb.source_id = iph.invoice_payment_id);

  --get the id's of records from okl_contract_balances which have the asset balances
  --as of the partial termination date
  CURSOR l_partial_term_csr(cp_khr_id NUMBER, cp_from_date DATE, cp_to_date DATE) IS
  SELECT ocb.id source_id
  , 'OKL_CONTRACT_BALANCES' source_table
  FROM   okl_contract_balances ocb
  WHERE  ocb.khr_id = cp_khr_id
  AND    ocb.termination_date BETWEEN cp_from_date AND cp_to_date
  AND   NOT EXISTS (select 1 FROM OKL_VAR_PRINCIPAL_BAL_TXN vpb
                    WHERE vpb.khr_id = ocb.khr_id
                    AND   vpb.source_table = 'OKL_CONTRACT_BALANCES'
                    AND   vpb.int_cal_process = 'VARIABLE_INTEREST'
                    AND   vpb.source_id = ocb.id);

  BEGIN
    x_return_status  := OKL_API.G_RET_STS_SUCCESS;
    print_debug('Executing procedure populate_txns');

    print_debug('Before fetching Rebook Transactions g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
    OPEN l_rebook_csr(p_khr_id);
    LOOP
      --FETCH l_rebook_csr INTO g_vpb_tbl(g_vpb_tbl_counter).source_id, g_vpb_tbl(g_vpb_tbl_counter).source_table;
      l_source_id := NULL;
      l_source_table := NULL;
      FETCH l_rebook_csr INTO l_source_id, l_source_table;
      EXIT WHEN l_rebook_csr%NOTFOUND;
      g_vpb_tbl_counter := g_vpb_tbl_counter + 1;
      g_vpb_tbl(g_vpb_tbl_counter).source_id := l_source_id;
      g_vpb_tbl(g_vpb_tbl_counter).source_table := l_source_table;
      g_vpb_tbl(g_vpb_tbl_counter).id := okc_p_util.raw_to_number(sys_guid());
      g_vpb_tbl(g_vpb_tbl_counter).khr_id := p_khr_id;
      g_vpb_tbl(g_vpb_tbl_counter).int_cal_process := 'VARIABLE_INTEREST';
      g_vpb_tbl(g_vpb_tbl_counter).OBJECT_VERSION_NUMBER := 1.0;
      g_vpb_tbl(g_vpb_tbl_counter).org_id                   := g_authoring_org_id;
      g_vpb_tbl(g_vpb_tbl_counter).request_id               := g_request_id;
      g_vpb_tbl(g_vpb_tbl_counter).program_application_id   := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).program_id               := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).program_update_date      := SYSDATE;
      g_vpb_tbl(g_vpb_tbl_counter).attribute_category       := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute1               := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute2               := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute3               := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute4               := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute5               := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute6               := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute7               := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute8               := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute9               := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute10              := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute11              := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute12              := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute13              := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute14              := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).attribute15              := NULL;
      g_vpb_tbl(g_vpb_tbl_counter).created_by               := FND_GLOBAL.USER_ID;
      g_vpb_tbl(g_vpb_tbl_counter).creation_date            := SYSDATE;
      g_vpb_tbl(g_vpb_tbl_counter).last_updated_by          := FND_GLOBAL.USER_ID;
      g_vpb_tbl(g_vpb_tbl_counter).last_update_date         := SYSDATE;
      g_vpb_tbl(g_vpb_tbl_counter).last_update_login        := FND_GLOBAL.LOGIN_ID;
    END LOOP;
    CLOSE l_rebook_csr;
    print_debug('After fetching Rebook Transactions g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);

    IF (G_DEAL_TYPE = 'LOAN') THEN
      IF (G_INTEREST_CALCULATION_BASIS = G_INT_CALC_BASIS_FLOAT) THEN
        IF (G_REVENUE_RECOGNITION_METHOD = 'ACTUAL') THEN
          print_debug('Deal Type => ' || G_DEAL_TYPE || ' Int Calc Basis => ' || G_INTEREST_CALCULATION_BASIS || ' Rev Rec Method => ' || G_REVENUE_RECOGNITION_METHOD);
          print_debug('Before fetching Daily Interest streams g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
          OPEN l_daily_int_strm_csr(p_khr_id, p_from_date, p_to_date);
          LOOP
            l_source_id := NULL;
            l_source_table := NULL;
            FETCH l_daily_int_strm_csr INTO l_source_id, l_source_table;
            EXIT WHEN l_daily_int_strm_csr%NOTFOUND;
            g_vpb_tbl_counter := g_vpb_tbl_counter + 1;
            g_vpb_tbl(g_vpb_tbl_counter).source_id := l_source_id;
            g_vpb_tbl(g_vpb_tbl_counter).source_table := l_source_table;
            g_vpb_tbl(g_vpb_tbl_counter).id := okc_p_util.raw_to_number(sys_guid());
            g_vpb_tbl(g_vpb_tbl_counter).khr_id := p_khr_id;
            g_vpb_tbl(g_vpb_tbl_counter).int_cal_process := 'VARIABLE_INTEREST';
            g_vpb_tbl(g_vpb_tbl_counter).OBJECT_VERSION_NUMBER := 1.0;
            g_vpb_tbl(g_vpb_tbl_counter).org_id                   := g_authoring_org_id;
            g_vpb_tbl(g_vpb_tbl_counter).request_id               := g_request_id;
            g_vpb_tbl(g_vpb_tbl_counter).program_application_id   := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).program_id               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).program_update_date      := SYSDATE;
            g_vpb_tbl(g_vpb_tbl_counter).attribute_category       := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute1               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute2               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute3               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute4               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute5               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute6               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute7               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute8               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute9               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute10              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute11              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute12              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute13              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute14              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute15              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).created_by               := FND_GLOBAL.USER_ID;
            g_vpb_tbl(g_vpb_tbl_counter).creation_date            := SYSDATE;
            g_vpb_tbl(g_vpb_tbl_counter).last_updated_by          := FND_GLOBAL.USER_ID;
            g_vpb_tbl(g_vpb_tbl_counter).last_update_date         := SYSDATE;
            g_vpb_tbl(g_vpb_tbl_counter).last_update_login        := FND_GLOBAL.LOGIN_ID;
          END LOOP;
          CLOSE l_daily_int_strm_csr;
          print_debug('After fetching Daily Interest streams g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
        ELSE
          --rev rec method = ESTIMATED AND BILLED
          IF (G_PRINCIPAL_BASIS_CODE = 'ACTUAL') THEN
            print_debug('Deal Type => ' || G_DEAL_TYPE || ' Int Calc Basis => ' || G_INTEREST_CALCULATION_BASIS || ' Rev Rec Method => ' || G_REVENUE_RECOGNITION_METHOD);
            print_debug('Before fetching Receipt Applications g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
            OPEN l_rcpt_app_csr(p_khr_id, p_from_date, p_to_date);
            LOOP
              l_source_id := NULL;
              l_source_table := NULL;
              FETCH l_rcpt_app_csr INTO l_source_id, l_source_table;
              EXIT WHEN l_rcpt_app_csr%NOTFOUND;
              g_vpb_tbl_counter := g_vpb_tbl_counter + 1;
              g_vpb_tbl(g_vpb_tbl_counter).source_id := l_source_id;
              g_vpb_tbl(g_vpb_tbl_counter).source_table := l_source_table;
              g_vpb_tbl(g_vpb_tbl_counter).id := okc_p_util.raw_to_number(sys_guid());
              g_vpb_tbl(g_vpb_tbl_counter).khr_id := p_khr_id;
              g_vpb_tbl(g_vpb_tbl_counter).int_cal_process := 'VARIABLE_INTEREST';
              g_vpb_tbl(g_vpb_tbl_counter).OBJECT_VERSION_NUMBER := 1.0;
              g_vpb_tbl(g_vpb_tbl_counter).org_id                   := g_authoring_org_id;
              g_vpb_tbl(g_vpb_tbl_counter).request_id               := g_request_id;
              g_vpb_tbl(g_vpb_tbl_counter).program_application_id   := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).program_id               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).program_update_date      := SYSDATE;
              g_vpb_tbl(g_vpb_tbl_counter).attribute_category       := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute1               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute2               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute3               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute4               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute5               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute6               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute7               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute8               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute9               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute10              := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute11              := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute12              := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute13              := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute14              := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute15              := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).created_by               := FND_GLOBAL.USER_ID;
              g_vpb_tbl(g_vpb_tbl_counter).creation_date            := SYSDATE;
              g_vpb_tbl(g_vpb_tbl_counter).last_updated_by          := FND_GLOBAL.USER_ID;
              g_vpb_tbl(g_vpb_tbl_counter).last_update_date         := SYSDATE;
              g_vpb_tbl(g_vpb_tbl_counter).last_update_login        := FND_GLOBAL.LOGIN_ID;
            END LOOP;
            CLOSE l_rcpt_app_csr;
            print_debug('After fetching Receipt Applications g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);

            print_debug('Before fetching Early Termination records g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
            OPEN l_partial_term_csr(p_khr_id, p_from_date, p_to_date);
            LOOP
              l_source_id := NULL;
              l_source_table := NULL;
              FETCH l_partial_term_csr INTO l_source_id, l_source_table;
              EXIT WHEN l_partial_term_csr%NOTFOUND;
              g_vpb_tbl_counter := g_vpb_tbl_counter + 1;
              g_vpb_tbl(g_vpb_tbl_counter).source_id := l_source_id;
              g_vpb_tbl(g_vpb_tbl_counter).source_table := l_source_table;
              g_vpb_tbl(g_vpb_tbl_counter).id := okc_p_util.raw_to_number(sys_guid());
              g_vpb_tbl(g_vpb_tbl_counter).khr_id := p_khr_id;
              g_vpb_tbl(g_vpb_tbl_counter).int_cal_process := 'VARIABLE_INTEREST';
              g_vpb_tbl(g_vpb_tbl_counter).OBJECT_VERSION_NUMBER := 1.0;
              g_vpb_tbl(g_vpb_tbl_counter).org_id                   := g_authoring_org_id;
              g_vpb_tbl(g_vpb_tbl_counter).request_id               := g_request_id;
              g_vpb_tbl(g_vpb_tbl_counter).program_application_id   := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).program_id               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).program_update_date      := SYSDATE;
              g_vpb_tbl(g_vpb_tbl_counter).attribute_category       := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute1               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute2               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute3               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute4               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute5               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute6               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute7               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute8               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute9               := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute10              := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute11              := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute12              := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute13              := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute14              := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).attribute15              := NULL;
              g_vpb_tbl(g_vpb_tbl_counter).created_by               := FND_GLOBAL.USER_ID;
              g_vpb_tbl(g_vpb_tbl_counter).creation_date            := SYSDATE;
              g_vpb_tbl(g_vpb_tbl_counter).last_updated_by          := FND_GLOBAL.USER_ID;
              g_vpb_tbl(g_vpb_tbl_counter).last_update_date         := SYSDATE;
              g_vpb_tbl(g_vpb_tbl_counter).last_update_login        := FND_GLOBAL.LOGIN_ID;
            END LOOP;
            CLOSE l_partial_term_csr;
            print_debug('After fetching Early Termination records g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
          END IF;
        END IF;
      ELSIF (G_INTEREST_CALCULATION_BASIS = G_INT_CALC_BASIS_CATCHUP) THEN
          print_debug('Deal Type => ' || G_DEAL_TYPE || ' Int Calc Basis => ' || G_INTEREST_CALCULATION_BASIS || ' Rev Rec Method => ' || G_REVENUE_RECOGNITION_METHOD);
          print_debug('Before fetching Receipt Applications g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
          OPEN l_rcpt_app_csr(p_khr_id, p_from_date, p_to_date);
          LOOP
            l_source_id := NULL;
            l_source_table := NULL;
            FETCH l_rcpt_app_csr INTO l_source_id, l_source_table;
            EXIT WHEN l_rcpt_app_csr%NOTFOUND;
            g_vpb_tbl_counter := g_vpb_tbl_counter + 1;
            g_vpb_tbl(g_vpb_tbl_counter).source_id := l_source_id;
            g_vpb_tbl(g_vpb_tbl_counter).source_table := l_source_table;
            g_vpb_tbl(g_vpb_tbl_counter).id := okc_p_util.raw_to_number(sys_guid());
            g_vpb_tbl(g_vpb_tbl_counter).khr_id := p_khr_id;
            g_vpb_tbl(g_vpb_tbl_counter).int_cal_process := 'VARIABLE_INTEREST';
            g_vpb_tbl(g_vpb_tbl_counter).OBJECT_VERSION_NUMBER := 1.0;
            g_vpb_tbl(g_vpb_tbl_counter).org_id                   := g_authoring_org_id;
            g_vpb_tbl(g_vpb_tbl_counter).request_id               := g_request_id;
            g_vpb_tbl(g_vpb_tbl_counter).program_application_id   := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).program_id               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).program_update_date      := SYSDATE;
            g_vpb_tbl(g_vpb_tbl_counter).attribute_category       := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute1               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute2               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute3               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute4               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute5               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute6               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute7               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute8               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute9               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute10              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute11              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute12              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute13              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute14              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute15              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).created_by               := FND_GLOBAL.USER_ID;
            g_vpb_tbl(g_vpb_tbl_counter).creation_date            := SYSDATE;
            g_vpb_tbl(g_vpb_tbl_counter).last_updated_by          := FND_GLOBAL.USER_ID;
            g_vpb_tbl(g_vpb_tbl_counter).last_update_date         := SYSDATE;
            g_vpb_tbl(g_vpb_tbl_counter).last_update_login        := FND_GLOBAL.LOGIN_ID;
          END LOOP;
          CLOSE l_rcpt_app_csr;
          print_debug('After fetching Receipt Applications g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);

          print_debug('Before fetching Early Termination records g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
          OPEN l_partial_term_csr(p_khr_id, p_from_date, p_to_date);
          LOOP
            l_source_id := NULL;
            l_source_table := NULL;
            FETCH l_partial_term_csr INTO l_source_id, l_source_table;
            EXIT WHEN l_partial_term_csr%NOTFOUND;
            g_vpb_tbl_counter := g_vpb_tbl_counter + 1;
            g_vpb_tbl(g_vpb_tbl_counter).source_id := l_source_id;
            g_vpb_tbl(g_vpb_tbl_counter).source_table := l_source_table;
            g_vpb_tbl(g_vpb_tbl_counter).id := okc_p_util.raw_to_number(sys_guid());
            g_vpb_tbl(g_vpb_tbl_counter).khr_id := p_khr_id;
            g_vpb_tbl(g_vpb_tbl_counter).int_cal_process := 'VARIABLE_INTEREST';
            g_vpb_tbl(g_vpb_tbl_counter).OBJECT_VERSION_NUMBER := 1.0;
            g_vpb_tbl(g_vpb_tbl_counter).org_id                   := g_authoring_org_id;
            g_vpb_tbl(g_vpb_tbl_counter).request_id               := g_request_id;
            g_vpb_tbl(g_vpb_tbl_counter).program_application_id   := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).program_id               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).program_update_date      := SYSDATE;
            g_vpb_tbl(g_vpb_tbl_counter).attribute_category       := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute1               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute2               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute3               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute4               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute5               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute6               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute7               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute8               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute9               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute10              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute11              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute12              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute13              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute14              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute15              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).created_by               := FND_GLOBAL.USER_ID;
            g_vpb_tbl(g_vpb_tbl_counter).creation_date            := SYSDATE;
            g_vpb_tbl(g_vpb_tbl_counter).last_updated_by          := FND_GLOBAL.USER_ID;
            g_vpb_tbl(g_vpb_tbl_counter).last_update_date         := SYSDATE;
            g_vpb_tbl(g_vpb_tbl_counter).last_update_login        := FND_GLOBAL.LOGIN_ID;
          END LOOP;
          CLOSE l_partial_term_csr;
          print_debug('After fetching Early Termination records g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);

          print_debug('Before fetching Principal Catchup streams g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
          OPEN l_prin_catch_strm_csr(p_khr_id, p_from_date, p_to_date);
          LOOP
            l_source_id := NULL;
            l_source_table := NULL;
            FETCH l_prin_catch_strm_csr INTO l_source_id, l_source_table;
            EXIT WHEN l_prin_catch_strm_csr%NOTFOUND;
            g_vpb_tbl_counter := g_vpb_tbl_counter + 1;
            g_vpb_tbl(g_vpb_tbl_counter).source_id := l_source_id;
            g_vpb_tbl(g_vpb_tbl_counter).source_table := l_source_table;
            g_vpb_tbl(g_vpb_tbl_counter).id := okc_p_util.raw_to_number(sys_guid());
            g_vpb_tbl(g_vpb_tbl_counter).khr_id := p_khr_id;
            g_vpb_tbl(g_vpb_tbl_counter).int_cal_process := 'VARIABLE_INTEREST';
            g_vpb_tbl(g_vpb_tbl_counter).OBJECT_VERSION_NUMBER := 1.0;
            g_vpb_tbl(g_vpb_tbl_counter).org_id                   := g_authoring_org_id;
            g_vpb_tbl(g_vpb_tbl_counter).request_id               := g_request_id;
            g_vpb_tbl(g_vpb_tbl_counter).program_application_id   := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).program_id               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).program_update_date      := SYSDATE;
            g_vpb_tbl(g_vpb_tbl_counter).attribute_category       := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute1               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute2               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute3               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute4               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute5               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute6               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute7               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute8               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute9               := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute10              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute11              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute12              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute13              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute14              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).attribute15              := NULL;
            g_vpb_tbl(g_vpb_tbl_counter).created_by               := FND_GLOBAL.USER_ID;
            g_vpb_tbl(g_vpb_tbl_counter).creation_date            := SYSDATE;
            g_vpb_tbl(g_vpb_tbl_counter).last_updated_by          := FND_GLOBAL.USER_ID;
            g_vpb_tbl(g_vpb_tbl_counter).last_update_date         := SYSDATE;
            g_vpb_tbl(g_vpb_tbl_counter).last_update_login        := FND_GLOBAL.LOGIN_ID;
          END LOOP;
          CLOSE l_prin_catch_strm_csr;
          print_debug('After fetching Principal Catchup streams g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
      END IF;
    ELSIF (G_DEAL_TYPE ='LOAN-REVOLVING') THEN
      IF (G_REVENUE_RECOGNITION_METHOD = 'ACTUAL') THEN
        print_debug('Deal Type => ' || G_DEAL_TYPE || ' Int Calc Basis => ' || G_INTEREST_CALCULATION_BASIS || ' Rev Rec Method => ' || G_REVENUE_RECOGNITION_METHOD);
        print_debug('Before fetching Borrower payments g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
        OPEN l_borrow_payment_csr(p_khr_id, p_from_date, p_to_date);
        LOOP
          l_source_id := NULL;
          l_source_table := NULL;
          FETCH l_borrow_payment_csr INTO l_source_id, l_source_table;
          EXIT WHEN l_borrow_payment_csr%NOTFOUND;
          g_vpb_tbl_counter := g_vpb_tbl_counter + 1;
          g_vpb_tbl(g_vpb_tbl_counter).source_id := l_source_id;
          g_vpb_tbl(g_vpb_tbl_counter).source_table := l_source_table;
          g_vpb_tbl(g_vpb_tbl_counter).id := okc_p_util.raw_to_number(sys_guid());
          g_vpb_tbl(g_vpb_tbl_counter).khr_id := p_khr_id;
          g_vpb_tbl(g_vpb_tbl_counter).int_cal_process := 'VARIABLE_INTEREST';
          g_vpb_tbl(g_vpb_tbl_counter).OBJECT_VERSION_NUMBER := 1.0;
          g_vpb_tbl(g_vpb_tbl_counter).org_id                   := g_authoring_org_id;
          g_vpb_tbl(g_vpb_tbl_counter).request_id               := g_request_id;
          g_vpb_tbl(g_vpb_tbl_counter).program_application_id   := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).program_id               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).program_update_date      := SYSDATE;
          g_vpb_tbl(g_vpb_tbl_counter).attribute_category       := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute1               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute2               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute3               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute4               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute5               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute6               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute7               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute8               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute9               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute10              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute11              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute12              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute13              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute14              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute15              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).created_by               := FND_GLOBAL.USER_ID;
          g_vpb_tbl(g_vpb_tbl_counter).creation_date            := SYSDATE;
          g_vpb_tbl(g_vpb_tbl_counter).last_updated_by          := FND_GLOBAL.USER_ID;
          g_vpb_tbl(g_vpb_tbl_counter).last_update_date         := SYSDATE;
          g_vpb_tbl(g_vpb_tbl_counter).last_update_login        := FND_GLOBAL.LOGIN_ID;
        END LOOP;
        CLOSE l_borrow_payment_csr;
        print_debug('After fetching Borrower payments g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);

        print_debug('Before fetching Daily Interest streams g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
        OPEN l_daily_int_strm_csr(p_khr_id, p_from_date, p_to_date);
        LOOP
          l_source_id := NULL;
          l_source_table := NULL;
          FETCH l_daily_int_strm_csr INTO l_source_id, l_source_table;
          EXIT WHEN l_daily_int_strm_csr%NOTFOUND;
          g_vpb_tbl_counter := g_vpb_tbl_counter + 1;
          g_vpb_tbl(g_vpb_tbl_counter).source_id := l_source_id;
          g_vpb_tbl(g_vpb_tbl_counter).source_table := l_source_table;
          g_vpb_tbl(g_vpb_tbl_counter).id := okc_p_util.raw_to_number(sys_guid());
          g_vpb_tbl(g_vpb_tbl_counter).khr_id := p_khr_id;
          g_vpb_tbl(g_vpb_tbl_counter).int_cal_process := 'VARIABLE_INTEREST';
          g_vpb_tbl(g_vpb_tbl_counter).OBJECT_VERSION_NUMBER := 1.0;
          g_vpb_tbl(g_vpb_tbl_counter).org_id                   := g_authoring_org_id;
          g_vpb_tbl(g_vpb_tbl_counter).request_id               := g_request_id;
          g_vpb_tbl(g_vpb_tbl_counter).program_application_id   := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).program_id               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).program_update_date      := SYSDATE;
          g_vpb_tbl(g_vpb_tbl_counter).attribute_category       := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute1               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute2               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute3               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute4               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute5               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute6               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute7               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute8               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute9               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute10              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute11              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute12              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute13              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute14              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute15              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).created_by               := FND_GLOBAL.USER_ID;
          g_vpb_tbl(g_vpb_tbl_counter).creation_date            := SYSDATE;
          g_vpb_tbl(g_vpb_tbl_counter).last_updated_by          := FND_GLOBAL.USER_ID;
          g_vpb_tbl(g_vpb_tbl_counter).last_update_date         := SYSDATE;
          g_vpb_tbl(g_vpb_tbl_counter).last_update_login        := FND_GLOBAL.LOGIN_ID;
        END LOOP;
        CLOSE l_daily_int_strm_csr;
        print_debug('After fetching Daily Interest streams g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
      ELSE
        --rev rec method = ESTIMATED AND BILLED
        print_debug('Deal Type => ' || G_DEAL_TYPE || ' Int Calc Basis => ' || G_INTEREST_CALCULATION_BASIS || ' Rev Rec Method => ' || G_REVENUE_RECOGNITION_METHOD);
        print_debug('Before fetching Borrower payments g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
        OPEN l_borrow_payment_csr(p_khr_id, p_from_date, p_to_date);
        LOOP
          l_source_id := NULL;
          l_source_table := NULL;
          FETCH l_borrow_payment_csr INTO l_source_id, l_source_table;
          EXIT WHEN l_borrow_payment_csr%NOTFOUND;
          g_vpb_tbl_counter := g_vpb_tbl_counter + 1;
          g_vpb_tbl(g_vpb_tbl_counter).source_id := l_source_id;
          g_vpb_tbl(g_vpb_tbl_counter).source_table := l_source_table;
          g_vpb_tbl(g_vpb_tbl_counter).id := okc_p_util.raw_to_number(sys_guid());
          g_vpb_tbl(g_vpb_tbl_counter).khr_id := p_khr_id;
          g_vpb_tbl(g_vpb_tbl_counter).int_cal_process := 'VARIABLE_INTEREST';
          g_vpb_tbl(g_vpb_tbl_counter).OBJECT_VERSION_NUMBER := 1.0;
          g_vpb_tbl(g_vpb_tbl_counter).org_id                   := g_authoring_org_id;
          g_vpb_tbl(g_vpb_tbl_counter).request_id               := g_request_id;
          g_vpb_tbl(g_vpb_tbl_counter).program_application_id   := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).program_id               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).program_update_date      := SYSDATE;
          g_vpb_tbl(g_vpb_tbl_counter).attribute_category       := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute1               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute2               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute3               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute4               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute5               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute6               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute7               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute8               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute9               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute10              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute11              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute12              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute13              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute14              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute15              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).created_by               := FND_GLOBAL.USER_ID;
          g_vpb_tbl(g_vpb_tbl_counter).creation_date            := SYSDATE;
          g_vpb_tbl(g_vpb_tbl_counter).last_updated_by          := FND_GLOBAL.USER_ID;
          g_vpb_tbl(g_vpb_tbl_counter).last_update_date         := SYSDATE;
          g_vpb_tbl(g_vpb_tbl_counter).last_update_login        := FND_GLOBAL.LOGIN_ID;
        END LOOP;
        CLOSE l_borrow_payment_csr;
        print_debug('After fetching Borrower payments g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);

        print_debug('Before fetching Receipt Applications g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
        OPEN l_rcpt_app_csr(p_khr_id, p_from_date, p_to_date);
        LOOP
          l_source_id := NULL;
          l_source_table := NULL;
          FETCH l_rcpt_app_csr INTO l_source_id, l_source_table;
          EXIT WHEN l_rcpt_app_csr%NOTFOUND;
          g_vpb_tbl_counter := g_vpb_tbl_counter + 1;
          g_vpb_tbl(g_vpb_tbl_counter).source_id := l_source_id;
          g_vpb_tbl(g_vpb_tbl_counter).source_table := l_source_table;
          g_vpb_tbl(g_vpb_tbl_counter).id := okc_p_util.raw_to_number(sys_guid());
          g_vpb_tbl(g_vpb_tbl_counter).khr_id := p_khr_id;
          g_vpb_tbl(g_vpb_tbl_counter).int_cal_process := 'VARIABLE_INTEREST';
          g_vpb_tbl(g_vpb_tbl_counter).OBJECT_VERSION_NUMBER := 1.0;
          g_vpb_tbl(g_vpb_tbl_counter).org_id                   := g_authoring_org_id;
          g_vpb_tbl(g_vpb_tbl_counter).request_id               := g_request_id;
          g_vpb_tbl(g_vpb_tbl_counter).program_application_id   := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).program_id               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).program_update_date      := SYSDATE;
          g_vpb_tbl(g_vpb_tbl_counter).attribute_category       := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute1               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute2               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute3               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute4               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute5               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute6               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute7               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute8               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute9               := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute10              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute11              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute12              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute13              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute14              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).attribute15              := NULL;
          g_vpb_tbl(g_vpb_tbl_counter).created_by               := FND_GLOBAL.USER_ID;
          g_vpb_tbl(g_vpb_tbl_counter).creation_date            := SYSDATE;
          g_vpb_tbl(g_vpb_tbl_counter).last_updated_by          := FND_GLOBAL.USER_ID;
          g_vpb_tbl(g_vpb_tbl_counter).last_update_date         := SYSDATE;
          g_vpb_tbl(g_vpb_tbl_counter).last_update_login        := FND_GLOBAL.LOGIN_ID;
        END LOOP;
        CLOSE l_rcpt_app_csr;
        print_debug('After fetching Receipt Applications g_vpb_tbl count is: '|| g_vpb_tbl.COUNT);
      END IF;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
       print_error_message('Exception raised in procedure POPULATE_TXNS');
       x_return_status  := OKL_API.G_RET_STS_UNEXP_ERROR;
       Okl_Api.SET_MESSAGE(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_UNEXPECTED_ERROR,
               p_token1       => G_SQLCODE_TOKEN,
               p_token1_value => SQLCODE,
               p_token2       => G_SQLERRM_TOKEN,
               p_token2_value => SQLERRM);
  END populate_txns;

------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       pgomes
    -- Procedure Name    print_vpb_tbl
    -- Description:      This procedure prints all the records in the PL/SQL table g_vpb_tbl
    --
    -- Dependencies:
    -- Parameters:       .
    -- Version:          1.0
    -- End of Comments

------------------------------------------------------------------------------

  PROCEDURE print_vpb_tbl ( p_vpb_tbl IN  vpb_tbl_type) IS

  l_index        NUMBER;
  BEGIN
       print_debug('Start => Contents of p_vpb_tbl');
       print_debug('******************************');
       l_index := p_vpb_tbl.first;
       LOOP
          EXIT when l_index IS NULL;
          print_debug( 'Record Number : '||l_index);
    		  print_debug( 'id : '||p_vpb_tbl(l_index).id );
    		  print_debug( 'khr_id : '||p_vpb_tbl(l_index).khr_id);
          print_debug( 'source_table : '|| p_vpb_tbl(l_index).source_table);
          print_debug( 'source_id : '|| p_vpb_tbl(l_index).source_id);
          print_debug( 'int_cal_process : '|| p_vpb_tbl(l_index).int_cal_process);
          print_debug( 'Object_Version_Number : '|| p_vpb_tbl(l_index).Object_Version_Number);
          print_debug( 'Org ID : '|| p_vpb_tbl(l_index).Org_id);
          print_debug( 'request ID : '|| p_vpb_tbl(l_index).request_id);
          print_debug( 'Program Application ID : '|| p_vpb_tbl(l_index).program_application_id);
          print_debug( 'program ID : '|| p_vpb_tbl(l_index).program_id);
          print_debug( 'Program Update date : '|| p_vpb_tbl(l_index).program_update_date);
          print_debug( 'attribute category : '|| p_vpb_tbl(l_index).attribute_category);
          print_debug( 'attribute1 : '|| p_vpb_tbl(l_index).attribute1);
          print_debug( 'attribute2 : '|| p_vpb_tbl(l_index).attribute2);
          print_debug( 'attribute3 : '|| p_vpb_tbl(l_index).attribute3);
          print_debug( 'attribute4 : '|| p_vpb_tbl(l_index).attribute4);
          print_debug( 'attribute5 : '|| p_vpb_tbl(l_index).attribute5);
          print_debug( 'attribute6 : '|| p_vpb_tbl(l_index).attribute6);
          print_debug( 'attribute7 : '|| p_vpb_tbl(l_index).attribute7);
          print_debug( 'attribute8 : '|| p_vpb_tbl(l_index).attribute8);
          print_debug( 'attribute9 : '|| p_vpb_tbl(l_index).attribute9);
          print_debug( 'attribute10 : '|| p_vpb_tbl(l_index).attribute10);
          print_debug( 'attribute11 : '|| p_vpb_tbl(l_index).attribute11);
          print_debug( 'attribute12 : '|| p_vpb_tbl(l_index).attribute12);
          print_debug( 'attribute13 : '|| p_vpb_tbl(l_index).attribute13);
          print_debug( 'attribute14 : '|| p_vpb_tbl(l_index).attribute14);
          print_debug( 'attribute15 : '|| p_vpb_tbl(l_index).attribute15);
          print_debug( 'created_by : '|| p_vpb_tbl(l_index).created_by);
          print_debug( 'creation_date : '|| p_vpb_tbl(l_index).creation_date);
          print_debug( 'last_updated_by : '|| p_vpb_tbl(l_index).last_updated_by);
          print_debug( 'last_update_date : '|| p_vpb_tbl(l_index).last_update_date);
          print_debug( 'last_update_login : '|| p_vpb_tbl(l_index).last_update_login);
          l_index       := p_vpb_tbl.NEXT(l_index);
       END LOOP;
       print_debug('****************************');
       print_debug('End => Contents of p_vpb_tbl');
  EXCEPTION
     WHEN OTHERS THEN
       print_error_message('Exception raised in procedure PRINT_VPB_TBL');
       Okl_Api.SET_MESSAGE(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_UNEXPECTED_ERROR,
               p_token1       => G_SQLCODE_TOKEN,
               p_token1_value => SQLCODE,
               p_token2       => G_SQLERRM_TOKEN,
               p_token2_value => SQLERRM);
  END print_vpb_tbl;

  ------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       pjgomes
    -- Procedure Name    populate_principal_bal_txn
    -- Description:      This procedure is called by Variable Interest Calculation for Loans
    --                   Inputs :
    --                   Output :
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  Procedure populate_principal_bal_txn(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_vpb_tbl           IN  vpb_tbl_type) IS

  l_api_name                  CONSTANT    VARCHAR2(30) := 'populate_principal_bal_txn';
  l_api_version               CONSTANT    NUMBER       := 1.0;
  l_index                     NUMBER := 0;

  BEGIN
    x_return_status               := OKL_API.G_RET_STS_SUCCESS;

    print_debug('Executing procedure populate_principal_bal_txn using following parameters : ');
    print_debug(' p_vpb_tbl.count : '|| p_vpb_tbl.COUNT );
    print_vpb_tbl (p_vpb_tbl);

    IF (p_vpb_tbl.COUNT > 0) THEN
  	   FORALL l_index in p_vpb_tbl.FIRST .. p_vpb_tbl.LAST
  	   save exceptions
       INSERT INTO OKL_VAR_PRINCIPAL_BAL_TXN VALUES p_vpb_tbl(l_index);

        print_debug ('Exception count : '|| sql%bulk_exceptions.count);
       IF sql%bulk_exceptions.count > 0 then
          for i in 1..sql%bulk_exceptions.count loop
              print_debug('while fetching, error ' || i || ' occurred during '||
                  'iteration ' || sql%bulk_exceptions(i).error_index);
              print_debug('oracle error is ' ||
                  sqlerrm(sql%bulk_exceptions(i).error_code));

          end loop;
        end if;
       print_debug ('No. of records inserted : '|| SQL%rowcount);

    END IF;

 EXCEPTION
     WHEN OTHERS THEN
       print_error_message('Exception raised in procedure populate_principal_bal_txn');
       print_debug ('Exception during bulk insert');
       print_debug ('Exception count : '|| sql%bulk_exceptions.count);
       IF sql%bulk_exceptions.count > 0 then
          for i in 1..sql%bulk_exceptions.count loop
              print_debug('while fetching, error ' || i || ' occurred during '||
                  'iteration ' || sql%bulk_exceptions(i).error_index);
              print_debug('oracle error is ' ||
                  sqlerrm(sql%bulk_exceptions(i).error_code));

          end loop;
       END IF;

       x_return_status := OKL_API.G_RET_STS_ERROR;
       Okl_Api.SET_MESSAGE(
           p_app_name     => G_APP_NAME,
           p_msg_name     => G_UNEXPECTED_ERROR,
           p_token1       => G_SQLCODE_TOKEN,
           p_token1_value => SQLCODE,
           p_token2       => G_SQLERRM_TOKEN,
           p_token2_value => SQLERRM);

  END populate_principal_bal_txn;

    PROCEDURE var_int_rent_level(
        p_api_version   IN  NUMBER,
        p_init_msg_list IN  VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_chr_id        IN NUMBER,
        p_trx_id        IN NUMBER,
        p_trx_status    IN VARCHAR2,
        p_rent_tbl      IN csm_periodic_expenses_tbl_type,
        p_csm_loan_level_tbl IN csm_loan_level_tbl_type,
        x_child_trx_id       OUT NOCOPY NUMBER) IS

    ------------------------------------------------------------
    -- Declare Process variables
    ------------------------------------------------------------

    l_api_name           VARCHAR2(35)    := 'var_int_rent_level';
    l_proc_name          VARCHAR2(35)    := 'var_int_rent_level';
    l_api_version        CONSTANT NUMBER := 1;
    l_msg_index_out             NUMBER;

    l_payment_type              VARCHAR2(100) := 'RENT';

    i                           NUMBER := 0;
    l_rent_count                NUMBER := 0;
    l_split_count               NUMBER := 0;
    --l_sequence                  NUMBER := 0;

    l_strm_lalevl_tbl           strm_lalevl_tbl;
    l_strm_lalevl_tbl_cntr      NUMBER := 0;
    l_rbk_tbl                   rbk_tbl;
    l_rbk_tbl_cntr              NUMBER := 0;
    l_rent_tbl                  csm_periodic_expenses_tbl_type;
    l_csm_loan_level_tbl        csm_loan_level_tbl_type;
    --l_split_asset_tbl           strm_lalevl_tbl;
    l_frequency                 okl_time_units_v.name%type;
    l_adder_months              NUMBER;
    l_payment_level_start_date  DATE;
    l_reamort_date              DATE;
    l_date_last_int_cal         DATE;
    l_vipv_rec                  vipv_rec;
    x_vipv_rec                  vipv_rec;
    x_strm_trx_tbl              strm_trx_tbl;
    l_child_trx_id              NUMBER := NULL;
    l_strm_lalevl_tbl_out       strm_lalevl_tbl;

    CURSOR l_vip_csr (p_trx_id in NUMBER) IS
    SELECT id
    FROM   okl_var_int_process_b
    WHERE  PARENT_TRX_ID = p_trx_id;

    --cursor to get existing payments
    Cursor l_pmt_csr (p_khr_id in number, p_cle_id in number) is
    select sll_rulb.dnz_chr_id                khr_id,
      rgpb.cle_id                            cle_id,
      --LASLL values
      sll_rulb.rule_information_category     sll_rule_information_category,
      to_number(sll_rulb.rule_information1)  seq, -- 4899594
      sll_rulb.rule_information2             start_date,
      sll_rulb.rule_information3             number_periods,
      sll_rulb.rule_information4             tuoms_per_period,
      sll_rulb.object1_id1                   Pay_freq,
      sll_rulb.rule_information5             structure,
      nvl( sll_rulb.rule_information10,'N')  advance_or_arrears,
      sll_rulb.rule_information6             amount,
      sll_rulb.rule_information7             stub_days,
      sll_rulb.rule_information8             stub_amount,
      sll_rulb.rule_information13            rate,
      sll_rulb.jtot_object1_code             time_unit_of_measure,
      sll_rulb.jtot_object2_code             stream_level_header,
      --LASLH values
      slh_rulb.rule_information_category     slh_rule_information_category,
      slh_rulb.jtot_object1_code             stream_type_source,
      slh_rulb.jtot_object2_code             time_value,
      slh_rulb.object1_id1                   sty_id,
      slh_rulb.rule_information1             billing_schedule_type,
      slh_rulb.rule_information2             rate_type
   from   okc_rules_b        sll_rulb,
      okc_rules_b        slh_rulb,
      okl_strm_type_b    styb,
      okc_rule_groups_b  rgpb
   where  sll_rulb.rgp_id                      = rgpb.id
   and    sll_rulb.rule_information_category   = 'LASLL'
   and    sll_rulb.dnz_chr_id                  = rgpb.dnz_chr_id
   and    sll_rulb.object2_id1                 = to_char(slh_rulb.id)
   and    slh_rulb.rgp_id                      = rgpb.id
   and    slh_rulb.rule_information_category   = 'LASLH'
   and    slh_rulb.dnz_chr_id                  = rgpb.dnz_chr_id
   and    styb.id                              = slh_rulb.object1_id1
   and    styb.stream_type_purpose             IN ('RENT', 'PRINCIPAL_PAYMENT')
   and    rgpb.dnz_chr_id                      = p_khr_id
   and    rgpb.cle_id                          = p_cle_id
   and    rgpb.rgd_code                        = 'LALEVL'
   order by to_number(sll_rulb.rule_information1); -- 4899594

   Cursor get_pmt_freq (l_freq in okl_time_units_v.name%type) is
   select id1 from okl_time_units_v
   where name = l_freq;

   CURSOR c_last_int_cur (p_contract_id NUMBER) IS
   SELECT NVL(date_last_interim_interest_cal, start_date) reamort_date
         ,currency_code
   FROM   okl_k_headers_full_v
   WHERE  id = p_chr_id;

   CURSOR c_freq_cur(p_contract_id NUMBER) IS
   select object1_id1 from okc_rules_b
   where dnz_chr_id = p_contract_id
   and rule_information_category = 'LASLL';

   l_pymt_rec l_pmt_csr%RowType;
   l_diff_in_periods   NUMBER;

   line_index Number := 0;
   l_source Number;
   l_kle_id NUMBER := NULL;
   l_prev_kle_id NUMBER := NULL;
   l_rent_tbl_cntr NUMBER := 0;
   l_csm_loan_level_tbl_cntr NUMBER := 0;
   l_index_number NUMBER;
   l_prev_index_number NUMBER;
   l_fetch_prior_periods BOOLEAN := TRUE;
   l_prior_periods NUMBER := 0;
   l_period_cntr NUMBER := 0;
   l_prior_level_date_start DATE;
   l_level_date_start DATE;
   l_sequence NUMBER := 0;
   l_time_unit_of_measure okc_rules_b.jtot_object1_code%type;
   l_stream_level_header okc_rules_b.jtot_object2_code%type;
   l_tuoms_per_period okc_rules_b.rule_information4%type;
   l_sll_rule_information_cat okc_rules_b.rule_information_category%type;
   l_structure okc_rules_b.rule_information5%type;

   l_stub_start_date DATE;
   l_stub_days NUMBER;
   l_stub_amount NUMBER;
   l_ret_val VARCHAR2(1);
   l_currency_code okc_k_headers_b.currency_code%type;

   --get the line id for the repriced rent from supertrump
   FUNCTION get_kle_id(p_trx_number IN NUMBER,
                       p_index_number IN NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER IS
     l_kle_id NUMBER := -9999;
   BEGIN
     OKL_STREAMS_UTIL.get_line_id(p_trx_number => p_trx_number
                                 ,p_index_number => p_index_number
                                 ,x_kle_id => l_kle_id
                                 ,x_return_status => x_return_status);
     RETURN l_kle_id;
   EXCEPTION
     WHEN OTHERS THEN
     print_debug('Error deriving the asset line id for Trx Number : ' || p_trx_number || ' and Index Number : ' || p_index_number);
     RETURN l_kle_id;
   END get_kle_id;

  PROCEDURE print_pmt_csr(p_pmt_rec IN l_pmt_csr%RowType) IS

    l_api_name	        CONSTANT VARCHAR2(30) := 'print_pmt_csr';
    l_pymt_rec l_pmt_csr%RowType;
  BEGIN
    l_pymt_rec := p_pmt_rec;
    print_debug('*****************************************');
    print_debug('*******START CONTENTS OF P_PMT_REC******');
    print_debug('khr_id : ' || set_value_null(l_pymt_rec.khr_id));
    print_debug('cle_id : ' || set_value_null(l_pymt_rec.cle_id));
    print_debug('LASLL VALUES');
    print_debug('============');
    print_debug('cle_id : ' || set_value_null(l_pymt_rec.cle_id));
    print_debug('seq : ' || set_value_null(l_pymt_rec.seq));
    print_debug('start_date : ' || set_value_null(l_pymt_rec.start_date));
    print_debug('number_periods : ' || set_value_null(l_pymt_rec.number_periods));
    print_debug('tuoms_per_period : ' || set_value_null(l_pymt_rec.tuoms_per_period));
    print_debug('Pay_freq : ' || set_value_null(l_pymt_rec.Pay_freq));
    print_debug('structure : ' || set_value_null(l_pymt_rec.structure));
    print_debug('advance_or_arrears : ' || set_value_null(l_pymt_rec.advance_or_arrears));
    print_debug('amount : ' || set_value_null(l_pymt_rec.amount));
    print_debug('stub_days : ' || set_value_null(l_pymt_rec.stub_days));
    print_debug('stub_amount : ' || set_value_null(l_pymt_rec.stub_amount));
    print_debug('rate : ' || set_value_null(l_pymt_rec.rate));
    print_debug('time_unit_of_measure : ' || set_value_null(l_pymt_rec.time_unit_of_measure));
    print_debug('stream_level_header : ' || set_value_null(l_pymt_rec.stream_level_header));
    print_debug('LASLH VALUES');
    print_debug('============');
    print_debug('slh_rule_information_category : ' || set_value_null(l_pymt_rec.slh_rule_information_category));
    print_debug('stream_type_source : ' || set_value_null(l_pymt_rec.stream_type_source));
    print_debug('time_value : ' || set_value_null(l_pymt_rec.time_value));
    print_debug('sty_id : ' || set_value_null(l_pymt_rec.sty_id));
    print_debug('billing_schedule_type : ' || set_value_null(l_pymt_rec.billing_schedule_type));
    print_debug('rate_type : ' || set_value_null(l_pymt_rec.rate_type));
    print_debug('*******END CONTENTS OF P_PMT_REC********');
    print_debug('*****************************************');

  Exception
   	WHEN OTHERS THEN
      print_debug('error in procedure print_pmt_csr');
      print_debug('sqlcode : ' || sqlcode || ' $ sqlerrm : ' || sqlerrm);
  END print_pmt_csr;

  --procedure to consolidate consecutive sll records if the the amounts are same incase of RENT
  --or if amounts and rates are same incase of PRINCIPAL PAYMENT
  PROCEDURE consolidate_sll(p_strm_lalevl_tbl IN strm_lalevl_tbl,
                            x_strm_lalevl_tbl OUT NOCOPY strm_lalevl_tbl) IS

    l_strm_lalevl_tbl strm_lalevl_tbl;
    l_strm_lalevl_tbl_cntr          NUMBER := 0;
    l_prev_strm_lalevl_tbl_cntr     NUMBER := 0;
    l_strm_lalevl_tbl_out_cntr      NUMBER := 0;
  BEGIN
    print_debug('*******START CONSOLIDATE_SLL********');

    l_strm_lalevl_tbl := p_strm_lalevl_tbl;
    l_strm_lalevl_tbl_cntr := l_strm_lalevl_tbl.first;
    print_debug('table count before consolidation :' || l_strm_lalevl_tbl.count);

    loop
      exit when l_strm_lalevl_tbl_cntr IS NULL;
      IF (l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information_category = 'LASLH') THEN
        l_strm_lalevl_tbl_out_cntr := l_strm_lalevl_tbl_out_cntr + 1;
        x_strm_lalevl_tbl(l_strm_lalevl_tbl_out_cntr) := l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr);
        l_prev_strm_lalevl_tbl_cntr := NULL;
      ELSIF (l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information_category = 'LASLL') THEN
        IF (l_prev_strm_lalevl_tbl_cntr IS NULL) THEN
          l_strm_lalevl_tbl_out_cntr := l_strm_lalevl_tbl_out_cntr + 1;
          x_strm_lalevl_tbl(l_strm_lalevl_tbl_out_cntr) := l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr);
          l_prev_strm_lalevl_tbl_cntr := l_strm_lalevl_tbl_cntr;
        ELSE

          IF (l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information6 IS NOT NULL AND l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information13 IS NULL) THEN
            --for RENT
            --IF (l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information7 IS NULL AND l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information8 IS NULL) THEN
              --for payment line (not a STUB)
              IF (l_strm_lalevl_tbl(l_prev_strm_lalevl_tbl_cntr).rule_information6 = l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information6) THEN
                --amounts are the same
                x_strm_lalevl_tbl(l_strm_lalevl_tbl_out_cntr).rule_information3 := x_strm_lalevl_tbl(l_strm_lalevl_tbl_out_cntr).rule_information3 + l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information3;
              ELSE
                --amounts are not the same
                l_strm_lalevl_tbl_out_cntr := l_strm_lalevl_tbl_out_cntr + 1;
                x_strm_lalevl_tbl(l_strm_lalevl_tbl_out_cntr) := l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr);
                l_prev_strm_lalevl_tbl_cntr := l_strm_lalevl_tbl_cntr;
              END IF;
            /*ELSE
              --line is a stub
              l_strm_lalevl_tbl_out_cntr := l_strm_lalevl_tbl_out_cntr + 1;
              x_strm_lalevl_tbl(l_strm_lalevl_tbl_out_cntr) := l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr);
              l_prev_strm_lalevl_tbl_cntr := l_strm_lalevl_tbl_cntr;
            END IF;*/
          ELSIF (l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information6 IS NOT NULL AND l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information13 IS NOT NULL) THEN
            --for PRINCIPAL PAYMENT
            --IF (l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information7 IS NULL AND l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information8 IS NULL) THEN
              --for payment line (not a STUB)

              --compare amount and rate
              IF (l_strm_lalevl_tbl(l_prev_strm_lalevl_tbl_cntr).rule_information6 = l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information6 AND
                  l_strm_lalevl_tbl(l_prev_strm_lalevl_tbl_cntr).rule_information13 = l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information13) THEN
                --amounts are the same
                x_strm_lalevl_tbl(l_strm_lalevl_tbl_out_cntr).rule_information3 := x_strm_lalevl_tbl(l_strm_lalevl_tbl_out_cntr).rule_information3 + l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information3;
              ELSE
                --amounts are not the same
                l_strm_lalevl_tbl_out_cntr := l_strm_lalevl_tbl_out_cntr + 1;
                x_strm_lalevl_tbl(l_strm_lalevl_tbl_out_cntr) := l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr);
                l_prev_strm_lalevl_tbl_cntr := l_strm_lalevl_tbl_cntr;
              END IF;
            /*ELSE
              --line is a stub
              l_strm_lalevl_tbl_out_cntr := l_strm_lalevl_tbl_out_cntr + 1;
              x_strm_lalevl_tbl(l_strm_lalevl_tbl_out_cntr) := l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr);
              l_prev_strm_lalevl_tbl_cntr := l_strm_lalevl_tbl_cntr;
            END IF;*/
          ELSIF (l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information6 IS NULL) THEN
            --line is a stub
            l_strm_lalevl_tbl_out_cntr := l_strm_lalevl_tbl_out_cntr + 1;
            x_strm_lalevl_tbl(l_strm_lalevl_tbl_out_cntr) := l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr);
            l_prev_strm_lalevl_tbl_cntr := l_strm_lalevl_tbl_cntr;
          ELSE
            print_debug('neither Rent nor Principal Payment');
          END IF;

        END IF;

      END IF;

      l_strm_lalevl_tbl_cntr := l_strm_lalevl_tbl.next(l_strm_lalevl_tbl_cntr);
    end loop;

    print_debug('table count after consolidation :' || x_strm_lalevl_tbl.count);
    print_debug('*******END CONSOLIDATE_SLL********');
  Exception
   	WHEN OTHERS THEN
      print_debug('error in procedure consolidate_sll');
      print_debug('sqlcode : ' || sqlcode || ' $ sqlerrm : ' || sqlerrm);
  END consolidate_sll;

  BEGIN -- main process begins here

    print_debug('****Entering procedure VAR_INT_RENT_LEVEL****');
    print_debug('****Start-Creating Rent Levels and ReBooking.');

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name	    => l_api_name,
  		p_init_msg_list	=> p_init_msg_list,
  		p_api_type  	=> '_PVT',
  		x_return_status	=> x_return_status);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
		  RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /*begin
      select pg_source_seq.NEXTVAL into l_source from dual;
    exception
      when others then
      null;
    end;*/
    print_debug('Contract ID: '||p_chr_id);
    print_debug('Trans Id: ' || p_trx_id);
    print_debug('Trans Status: ' || p_trx_status);


    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    --which is the kle id in this table
    l_rent_tbl := p_rent_tbl;
    l_csm_loan_level_tbl := p_csm_loan_level_tbl;


    print_debug('=======>Start - Input from Super Trump or initiate_request (for Principal Payment).');
    print_loan_tables(p_rent_tbl => l_rent_tbl,
                      p_csm_loan_level_tbl => l_csm_loan_level_tbl);
    print_debug('=======>End - Input from Super Trump or initiate_request (for Principal Payment).');


  	OPEN	c_last_int_cur (p_chr_id);
	  FETCH	c_last_int_cur INTO l_reamort_date, l_currency_code;
    CLOSE	c_last_int_cur;

    --print_debug('Last Interest Calculation Date: '||l_date_last_int_cal);
    print_debug('Reamort Date: '||l_reamort_date || ' Currency Code: ' || l_currency_code);


    /*IF (p_trx_id IS NOT NULL) THEN
      --need the below code just in case the frequency is 'T' for a stub payment
      l_rent_count := p_rent_tbl.first;
      LOOP
        EXIT WHEN l_rent_count IS NULL;
    	  OPEN	get_pmt_freq (p_rent_tbl(l_rent_count).period);
      	FETCH	get_pmt_freq INTO l_frequency;
      	CLOSE	get_pmt_freq;
        EXIT WHEN l_frequency IN ('M', 'Q', 'S', 'A');
        l_rent_count := p_rent_tbl.next(l_rent_count);
      END LOOP;
    ELSE
      l_rent_count := p_rent_tbl.first;
      LOOP
        EXIT WHEN l_rent_count IS NULL;
        l_frequency := p_rent_tbl(l_rent_count).period;
        EXIT WHEN l_frequency IN ('M', 'Q', 'S', 'A');
        l_rent_count := p_rent_tbl.next(l_rent_count);
      END LOOP;
    END IF;*/

    OPEN c_freq_cur(p_chr_id);
    FETCH c_freq_cur INTO l_frequency;
    CLOSE c_freq_cur;

    print_debug('l_frequency: '||l_frequency);

    if(l_frequency = 'M') THEN
              l_adder_months := 1;
    elsif(l_frequency = 'Q') THEN
              l_adder_months := 3;
    elsif(l_frequency = 'S') THEN
              l_adder_months := 6;
    elsif(l_frequency = 'A') THEN
              l_adder_months := 12;
    end if;
    print_debug('l_frequency: '||l_frequency || ' l_adder_months: ' || l_adder_months);

    l_rent_tbl_cntr := l_rent_tbl.first;
    LOOP
      EXIT WHEN l_rent_tbl_cntr IS NULL;
      --round the amount
      IF (l_rent_tbl(l_rent_tbl_cntr).amount IS NOT NULL) THEN
         l_rent_tbl(l_rent_tbl_cntr).amount := OKL_ACCOUNTING_UTIL.round_amount(l_rent_tbl(l_rent_tbl_cntr).amount, l_currency_code);
      END IF;

      l_rent_tbl_cntr := l_rent_tbl.next(l_rent_tbl_cntr);
    END LOOP;

    l_index_number := NULL;
    l_prev_index_number := NULL;
    l_kle_id := NULL;
    l_prev_kle_id := NULL;
    l_rbk_tbl_cntr := 0;
    l_strm_lalevl_tbl_cntr := 0;
    l_sequence := 0;
    l_fetch_prior_periods := TRUE;

    l_rent_tbl_cntr := l_rent_tbl.first;
    LOOP
      EXIT WHEN l_rent_tbl_cntr IS NULL;

      --get kle_id
      l_index_number := l_rent_tbl(l_rent_tbl_cntr).index_number;
      print_debug('l_index_number: '||l_index_number);

      --for contracts with payments in arrears, supertrum will add a period
      --to the payment start date. so we gotta reverse that
      /*IF (p_trx_id IS NOT NULL) THEN
        l_rent_tbl(l_rent_tbl_cntr).first_payment_date := add_months(l_rent_tbl(l_rent_tbl_cntr).first_payment_date, -1*l_adder_months);
      END IF;*/

      IF (p_trx_id IS NOT NULL AND l_index_number IS NOT NULL) THEN
        --for supertrump request
        IF (NVL(l_prev_index_number, -99) <> l_index_number) THEN
          print_debug('deriving kle id');
          l_kle_id := get_kle_id(p_trx_number => p_trx_id,
                       p_index_number => l_index_number,
                       x_return_status => x_return_status);

          IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            print_debug('Unable to derive kle_id from inbound supertrump call.');
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSE
            print_debug('l_kle_id: '||l_kle_id);
          END IF;
          l_sequence := 0;
          print_debug('l_sequence: '||l_sequence);
          l_prev_index_number := l_index_number;
        END IF;
      ELSE
        --for initiate request for Principal Payment
        l_kle_id := l_csm_loan_level_tbl(l_rent_tbl_cntr).kle_loan_id;
        l_sequence := 0;
        print_debug('l_sequence: '||l_sequence);
        print_debug('l_kle_id: '||l_kle_id);
      END IF;

      IF (NVL(l_prev_kle_id, -99) <> l_kle_id) THEN
        l_fetch_prior_periods := TRUE;
        print_debug('setting the l_fetch_prior_periods to true');
      END IF;

      IF (l_fetch_prior_periods) THEN
        print_debug('l_fetch_prior_periods is true: fecthing LASLL/LASLH info for kle : ' || l_kle_id);
        FOR l_pmt_cur IN l_pmt_csr (p_chr_id, l_kle_id) LOOP
          print_pmt_csr(p_pmt_rec => l_pmt_cur);

          --populate l_rbk_tbl table and LASLH information
          print_debug('previous kle_id : ' || l_prev_kle_id || '<-> current  kle_id : ' || l_kle_id);
          IF (NVL(l_prev_kle_id, -99) <> l_kle_id) THEN
            print_debug('populating l_rbk_tbl');
            l_rbk_tbl_cntr := l_rbk_tbl_cntr + 1;
            l_rbk_tbl(l_rbk_tbl_cntr).KHR_ID := p_chr_id;
            l_rbk_tbl(l_rbk_tbl_cntr).KLE_ID := l_kle_id;
            print_debug('done populating l_rbk_tbl');

            print_debug('populating l_strm_lalevl_tbl with LASLH information');
            l_strm_lalevl_tbl_cntr := l_strm_lalevl_tbl_cntr + 1;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Chr_Id := p_chr_id;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Cle_Id := l_kle_id;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).jtot_object1_code := l_pmt_cur.stream_type_source;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).jtot_object2_code := l_pmt_cur.time_value;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information1 := l_pmt_cur.billing_schedule_type;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).rule_information2 := l_pmt_cur.rate_type;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information_category := l_pmt_cur.slh_rule_information_category;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).object1_id1 := l_pmt_cur.sty_id;
            l_prev_kle_id := l_kle_id;
            l_time_unit_of_measure := l_pmt_cur.time_unit_of_measure;
            l_stream_level_header := l_pmt_cur.stream_level_header;
            l_sll_rule_information_cat := l_pmt_cur.sll_rule_information_category;
            l_tuoms_per_period := l_pmt_cur.tuoms_per_period;
            l_structure := l_pmt_cur.structure;
            print_debug('done populating l_strm_lalevl_tbl with LASLH information');
          END IF;

          l_prior_level_date_start := FND_DATE.canonical_to_date(l_pmt_cur.start_date);
          print_debug('l_prior_level_date_start : ' || l_prior_level_date_start);
          l_level_date_start := NULL;
          l_prior_periods := 0;
          FOR l_period_cntr IN 1..NVL(l_pmt_cur.number_periods, 1) LOOP
              IF (l_prior_level_date_start < l_reamort_date) THEN
                l_prior_periods := l_prior_periods + 1;

                IF (l_level_date_start IS NULL) THEN
                  l_level_date_start := l_prior_level_date_start;
                  print_debug('l_level_date_start : ' || l_level_date_start);
                END IF;
              END IF;
              l_prior_level_date_start := add_months(l_prior_level_date_start,  l_adder_months);
              print_debug('l_period_cntr :' || l_period_cntr || ' l_prior_level_date_start : ' || l_prior_level_date_start);
          END LOOP;
          print_debug('l_prior_level_date_start : ' || l_prior_level_date_start);
          print_debug('l_prior_periods : ' || l_prior_periods);

          IF (l_prior_periods > 0) THEN
            l_strm_lalevl_tbl_cntr := l_strm_lalevl_tbl_cntr + 1;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Chr_Id := p_chr_id;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Cle_Id := l_kle_id;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information3 := l_prior_periods;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Jtot_Object1_Code := l_pmt_cur.time_unit_of_measure;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Jtot_Object2_Code := l_pmt_cur.stream_level_header;
            l_stream_level_header := l_pmt_cur.stream_level_header;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Object1_id1 := l_pmt_cur.Pay_freq;
            l_sequence := l_sequence + 1;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information1 := l_sequence;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information2 := fnd_date.date_to_canonical(l_level_date_start);
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information4 := l_pmt_cur.tuoms_per_period;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information5 := l_structure;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information6 := l_pmt_cur.amount;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information7 := l_pmt_cur.stub_days;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information8 := l_pmt_cur.stub_amount;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information10 := l_pmt_cur.advance_or_arrears;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information_category := l_pmt_cur.sll_rule_information_category;
            l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information13 := l_pmt_cur.rate;

            print_debug('=>Start - Prior Periods Information in -> l_strm_lalevl_tbl.');
            print_var_int_tables(p_rbk_tbl => l_rbk_tbl,
                                 p_strm_lalevl_tbl => l_strm_lalevl_tbl);
            print_debug('=>End - Prior Periods Information in -> l_strm_lalevl_tbl.');
          END IF;
        END LOOP; --l_pmt_cur
        l_fetch_prior_periods := FALSE;
      END IF;

      l_strm_lalevl_tbl_cntr := l_strm_lalevl_tbl_cntr + 1;
      l_sequence := l_sequence + 1;
      l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Chr_Id := p_chr_id;
      l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Cle_Id := l_kle_id;
      l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Jtot_Object1_Code := l_time_unit_of_measure;
      l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Jtot_Object2_Code := l_stream_level_header;
      l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information_category := l_sll_rule_information_cat;
      l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information1 := l_sequence;
      l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information3 := l_rent_tbl(l_rent_tbl_cntr).number_of_periods;
      l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information4 := l_tuoms_per_period;
      l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information5 := l_structure;
      l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information6 := l_rent_tbl(l_rent_tbl_cntr).amount;

      --if the payment level is a stub
      IF (UPPER(l_rent_tbl(l_rent_tbl_cntr).period) IN ('STUB', 'T')) THEN
        print_debug('calling get_stub_info with p_kle_id => ' || l_kle_id || ' and p_start_date => ' || l_rent_tbl(l_rent_tbl_cntr).first_payment_date);
        l_ret_val := get_stub_info(p_kle_id => l_kle_id,
                     p_start_date => l_rent_tbl(l_rent_tbl_cntr).first_payment_date,
                     x_stub_start_date => l_stub_start_date,
                     x_stub_days => l_stub_days,
                     x_stub_amount => l_stub_amount);
        print_debug(' output of get_stub_info :');
        print_debug(' l_stub_start_date => ' || l_stub_start_date);
        print_debug(' l_stub_days => ' || l_stub_days);
        print_debug(' l_stub_amount => ' || l_stub_amount);

        l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information2 := fnd_date.date_to_canonical(l_stub_start_date);
        l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information3 := NULL;
        l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information6 := NULL;
        l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information7 := l_stub_days;
        --l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information8 := l_stub_amount;
        l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information8 := l_rent_tbl(l_rent_tbl_cntr).amount;
     ELSE
       l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information2 := fnd_date.date_to_canonical(l_rent_tbl(l_rent_tbl_cntr).first_payment_date);
     END IF;
      --start change by pjgomes
      --uncomment out the below lines when necessary changes are made
      --so that the l_rent_tbl structure has stub_days and stub_amount fields
      --l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information7 := l_rent_tbl(l_rent_tbl_cntr).stub_days;
      --l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information8 := l_rent_tbl(l_rent_tbl_cntr).stub_amount;
      --end change by pjgomes


      IF (p_trx_id IS NOT NULL) THEN
        l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information10 := l_rent_tbl(l_rent_tbl_cntr).advance_or_arrears;
      ELSE
        IF (NVL(l_rent_tbl(l_rent_tbl_cntr).advance_or_arrears, 'DODDLES') = 'ARREARS') THEN
          l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information10 := 'Y';
        ELSE
          l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information10 := 'N';
        END IF;
      END IF;

      --l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information10 := l_rent_tbl(l_rent_tbl_cntr).advance_or_arrears;
      l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Rule_Information13 := l_rent_tbl(l_rent_tbl_cntr).rate;
      l_strm_lalevl_tbl(l_strm_lalevl_tbl_cntr).Object1_id1 := l_frequency;
      print_debug('=>Start - Current and prior Periods Information in -> l_strm_lalevl_tbl.');
      print_var_int_tables(p_rbk_tbl => l_rbk_tbl,
                           p_strm_lalevl_tbl => l_strm_lalevl_tbl);
      print_debug('=>End - Current and prior Periods Information in -> l_strm_lalevl_tbl.');

      l_rent_tbl_cntr := l_rent_tbl.next(l_rent_tbl_cntr);
    END LOOP; --l_rent_tbl

    --FOR line_count IN 1..l_split_asset_tbl.COUNT
/*    i := 0;
    line_index := 0;
    l_split_count := l_split_asset_tbl.first;
    LOOP
       exit when l_split_count is null;

       IF(l_split_asset_tbl(l_split_count).rule_information_category = 'LASLH') THEN
         i := i + 1;
         l_strm_lalevl_tbl(i) := l_split_asset_tbl(l_split_count);
              print_debug('Record: '||l_split_asset_tbl(l_split_count).rule_information_category);
         l_sequence := 1;
       ELSE
         line_index := line_index + 1;
         l_rbk_tbl(line_index).KHR_ID := p_chr_id;
         l_rbk_tbl(line_index).KLE_ID := l_split_asset_tbl(l_split_count).cle_id;
         FOR r_pymt_csr IN get_pmt_csr(p_chr_id, l_split_asset_tbl(l_split_count).cle_id)
         LOOP
              print_debug('Flag from Split: '||l_split_asset_tbl(l_split_count).Rule_Information10);
              print_debug('CHR ID: '||p_chr_id||
                                    ' Cle ID: '||l_split_asset_tbl(l_split_count).cle_id
                                    ||' Sequence: '||l_sequence);
              print_debug('Count: '||l_split_count||
                                    ' Payment Old Start Date: '||r_pymt_csr.start_date||
                                    ' No. of Old Periods: '||r_pymt_csr.number_periods||
                                    ' Payment Start Date: '||l_reamort_date);
              print_debug('Payment Start Date from Split: '||l_split_asset_tbl(l_split_count).Rule_Information2);

              If (FND_DATE.canonical_to_date(r_pymt_csr.start_date) < l_reamort_date) Then
                i := i + 1;
                l_diff_in_periods := round(months_between(l_reamort_date,
                                                            FND_DATE.canonical_to_date(r_pymt_csr.start_date)));
                print_debug('Period Diff: '||l_diff_in_periods);
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Period Diff: '||l_diff_in_periods);
                If (l_diff_in_periods >= 1 and r_pymt_csr.number_periods > l_diff_in_periods)Then
                  l_strm_lalevl_tbl(i).Rule_Information3 := l_diff_in_periods;
                else
                  l_strm_lalevl_tbl(i).Rule_Information3 := r_pymt_csr.number_periods;
                end if;
                l_strm_lalevl_tbl(i).Chr_Id := p_chr_id;
                l_strm_lalevl_tbl(i).Cle_Id := r_pymt_csr.cle_id;
                l_strm_lalevl_tbl(i).Jtot_Object1_Code := 'OKL_TUOM';
                l_strm_lalevl_tbl(i).Jtot_Object2_Code := 'OKL_STRMHDR';
                l_strm_lalevl_tbl(i).Object1_id1 := r_pymt_csr.Pay_freq;
                l_strm_lalevl_tbl(i).Rule_Information1 := l_sequence;
                l_strm_lalevl_tbl(i).Rule_Information2 := r_pymt_csr.start_date;
                l_strm_lalevl_tbl(i).Rule_Information4 := r_pymt_csr.tuoms_per_period;
                l_strm_lalevl_tbl(i).Rule_Information6 := r_pymt_csr.amount;
                l_strm_lalevl_tbl(i).Rule_Information10 := r_pymt_csr.advance_or_arrears;
                l_strm_lalevl_tbl(i).Rule_Information_category := 'LASLL';
              END IF;
              l_sequence := l_sequence + 1;
         END LOOP;
         i := i + 1;
         -- Hard Coded the Flag as Split API is not returning it
         l_split_asset_tbl(l_split_count).Rule_Information1 := l_sequence;
         l_split_asset_tbl(l_split_count).Rule_Information10 := 'Y';
         l_strm_lalevl_tbl(i) := l_split_asset_tbl(l_split_count);
         l_sequence := l_sequence + 1;
       END IF;
       l_split_count := l_split_asset_tbl.next(l_split_count);
    END LOOP;

    print_debug('No. of Records for Mass Rebook: '||l_strm_lalevl_tbl.count);
--    print_debug('Before Mass Rebook: '||x_return_status);

    print_debug('COUNT: '||l_rbk_tbl.COUNT);
*/

    print_debug('');
    print_debug('=>Start - Before consolidating SLL, contents of l_rbk_tbl and l_strm_lalevl_tbl.');
    print_var_int_tables(p_rbk_tbl => l_rbk_tbl,
                         p_strm_lalevl_tbl => l_strm_lalevl_tbl);
    print_debug('=>End - Before consolidating SLL, contents of l_rbk_tbl and l_strm_lalevl_tbl.');

    consolidate_sll(p_strm_lalevl_tbl => l_strm_lalevl_tbl,
                    x_strm_lalevl_tbl => l_strm_lalevl_tbl_out);

   l_strm_lalevl_tbl := l_strm_lalevl_tbl_out;

    print_debug('');
    print_debug('=>Start - After consolidation of SLL, before passing to mass rebook, contents of l_rbk_tbl and l_strm_lalevl_tbl.');
    print_var_int_tables(p_rbk_tbl => l_rbk_tbl,
                         p_strm_lalevl_tbl => l_strm_lalevl_tbl);
    print_debug('=>End - After consolidation of SLL, before passing to mass rebook, contents of l_rbk_tbl and l_strm_lalevl_tbl.');


    OKL_MASS_REBOOK_PVT.apply_mass_rebook(
                     p_api_version          => p_api_version,
                     p_init_msg_list        => p_init_msg_list,
                     x_return_status        => x_return_status,
                     x_msg_count            => x_msg_count,
                     x_msg_data             => x_msg_data,
                     p_rbk_tbl              => l_rbk_tbl,
                     p_deprn_method_code    => NULL,
                     p_in_service_date      => NULL,
                     p_life_in_months       => NULL,
                     p_basic_rate           => NULL,
                     p_adjusted_rate        => NULL,
                     p_residual_value       => NULL,
                     p_strm_lalevl_tbl      =>  l_strm_lalevl_tbl,
                     p_transaction_date     =>  l_reamort_date,
                     x_stream_trx_tbl       =>  x_strm_trx_tbl
                     );

    print_debug('After Mass Rebook status: '||x_return_status||' Error: '||x_msg_data);
    print_debug('After Mass Rebook x_strm_trx_tbl.count: '|| x_strm_trx_tbl.count);
    FND_FILE.PUT_LINE (FND_FILE.LOG,'After mass rebook Stream Table count: '|| x_strm_trx_tbl.count);

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      FOR i in 1..x_msg_count
      LOOP
        FND_MSG_PUB.GET(
                        p_msg_index     => i,
                        p_encoded       => FND_API.G_FALSE,
                        p_data          => x_msg_data,
                        p_msg_index_out => l_msg_index_out
                       );
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error: '||to_char(i)||': '||x_msg_data);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Message Index: '||l_msg_index_out);
        print_debug('Error '||to_char(i)||': '||x_msg_data);
        print_debug('Message Index: '||l_msg_index_out);
      END LOOP;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
   	          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
   	          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE
      i := x_strm_trx_tbl.first;
      l_child_trx_id := x_strm_trx_tbl(i).trx_number;
      x_child_trx_id :=l_child_trx_id;

      print_debug('child trx number :' || l_child_trx_id);
      loop
        exit when i is null;
        print_debug('x_strm_trx_tbl - element # ' || i || ' : ' || x_strm_trx_tbl(i).trx_number);
        i := x_strm_trx_tbl.next(i);
      end loop;

      -- Updating the Interest Calculation Date

       print_debug('Khr id : ' || p_chr_id || ' Frequency : ' || l_frequency);
       print_debug('Before updating  date_last_interim_interest_cal');
       if(l_frequency = 'M') THEN
              UPDATE okl_k_headers khr
              SET khr.date_last_interim_interest_cal =  add_months(l_reamort_date,1)
              where khr.id = p_chr_id;
       elsif(l_frequency = 'Q') THEN
              UPDATE okl_k_headers khr
              SET khr.date_last_interim_interest_cal =  add_months(l_reamort_date,3)
              where khr.id = p_chr_id;
       elsif(l_frequency = 'S') THEN
              UPDATE okl_k_headers khr
              SET khr.date_last_interim_interest_cal =  add_months(l_reamort_date,6)
              where khr.id = p_chr_id;
       elsif(l_frequency = 'A') THEN
              UPDATE okl_k_headers khr
              SET khr.date_last_interim_interest_cal =  add_months(l_reamort_date,12)
              where khr.id = p_chr_id;
       end if;
       print_debug('After updating  date_last_interim_interest_cal');


       --only for inbound supertrump call
       IF (p_trx_id IS NOT NULL) THEN
         print_debug('Fetching Var Int Process Id for trx number: ' || p_trx_id);
         OPEN l_vip_csr(p_trx_id);
         FETCH l_vip_csr INTO l_vipv_rec.id;
         IF l_vip_csr%NOTFOUND THEN
                print_debug('Var Int Process Id not found for trx number: ' || p_trx_id);
         ELSE
                print_debug('Var Int Process Id found for trx number: ' || p_trx_id);
         END IF;
         CLOSE l_vip_csr;

         i := x_strm_trx_tbl.first;
         l_vipv_rec.child_trx_id             :=  x_strm_trx_tbl(i).trx_number;
         i := null;


         print_debug('Before updating okl_var_int_process_b');
         OKL_VIP_PVT.update_row(
                 p_api_version                        => p_api_version,
  	             p_init_msg_list                      => p_init_msg_list,
          		   x_return_status	   			            => x_return_status,
  						   x_msg_count	   			                => x_msg_count,
  						   x_msg_data	   		                    => x_msg_data,
                 p_vipv_rec                           => l_vipv_rec,
                 x_vipv_rec                           => x_vipv_rec);
         print_debug('After updating okl_var_int_process_b, Status => ' || x_return_status);
         print_debug('****End-Creating Rent Levels and ReBooking.');
         print_debug('****Exiting procedure VAR_INT_RENT_LEVEL****');


         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     	          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
     	          RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
   END IF;
  Exception
   	WHEN OTHERS THEN
      print_debug('sqlcode : ' || sqlcode || ' $ sqlerrm : ' || sqlerrm);
   		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
    					p_api_name	=> l_api_name,
    					p_pkg_name	=> G_PKG_NAME,
    					p_exc_name	=> 'OTHERS',
    					x_msg_count	=> x_msg_count,
    					x_msg_data	=> x_msg_data,
    					p_api_type	=> '_PVT');


  END var_int_rent_level;
------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    Create_Daily_Interest_Streams
    -- Description:      This procedure is called by Daily Interest Calculation program
    --                   Inputs :
    --                   Output :
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  Procedure Create_Daily_Interest_Streams (
            p_api_version             IN  NUMBER,
            p_init_msg_list           IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_contract_id             IN  NUMBER,
            p_line_id                 IN  NUMBER DEFAULT NULL, -- not currently used
            p_amount                  IN  NUMBER,
            p_due_date                IN  DATE,
            p_stream_type_purpose     IN  VARCHAR2,
            p_create_invoice_flag     IN  VARCHAR2 DEFAULT OKL_API.G_TRUE,
 	        p_process_flag            IN  VARCHAR2 DEFAULT NULL,
			p_currency_code           IN  VARCHAR2 DEFAULT NULL ) IS

  l_api_name                  CONSTANT    VARCHAR2(30) := 'CREATE_DAILY_INTEREST_STREAMS';
  l_api_version               CONSTANT    NUMBER       := 1.0;
  l_invoice_id                NUMBER;
  l_stream_element_id         OKL_STRM_ELEMENTS_V.id%TYPE;
  i_vir_tbl                   vir_tbl_type;
  r_vir_tbl                   vir_tbl_type;
  Create_Daily_Int_Str_failed EXCEPTION;
  l_asset_cost                NUMBER;
  l_total_asset_val           NUMBER := 0;
  l_asset_line_tbl            okl_kle_pvt.kle_tbl_type;
  l_line_index                NUMBER := 0;
  l_index                     NUMBER := 0;
  l_asset_line_tbl_count      NUMBER := 0;
  l_invoice_amt               NUMBER;
  l_prorated_invoice_amt      NUMBER := 0;


  CURSOR contract_line_csr (p_khr_id NUMBER, p_due_date DATE) IS
    SELECT id
    FROM   okl_k_lines_full_v
    WHERE  chr_id = p_khr_id
    AND    lse_id = G_FIN_LINE_LTY_ID
    AND    nvl(date_terminated, p_due_date + 1) > p_due_date
    ORDER BY id;


  BEGIN
    print_debug('Executing procedure CREATE_DAILY_INTEREST_STREAMS using following parameters : ');
    print_debug(' p_contract_id : '|| p_contract_id );
	print_debug(' p_line_id : '|| p_line_id);
    print_debug(' p_amount : '|| p_amount );
	print_debug(' p_due_date: '|| p_due_date);
    print_debug(' p_stream_type_purpose : '||p_stream_type_purpose);
	print_debug(' p_create_invoice_flag: '|| p_create_invoice_flag);
    print_debug(' p_process_flag : '|| p_process_flag);

    x_return_status               := OKL_API.G_RET_STS_SUCCESS;

	Initialize_contract_params( p_api_version   => 1.0,
                                p_init_msg_list => OKL_API.G_FALSE,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_contract_id   => p_contract_id
                              );
    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS completed successfully');
    ELSIF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS returned unexpected error');
  	   print_error_message ('Procedure INITIALIZE_CONTRACT_PARAMS returned unexpected error');
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS returned exception');
	   print_error_message ('Procedure INITIALIZE_CONTRACT_PARAMS returned exception');
       RAISE Create_Daily_Int_Str_failed;
    END IF;

    IF (p_stream_type_purpose = 'DAILY_INTEREST_INTEREST') THEN

      Create_Stream_Invoice (
             p_api_version            => 1.0,
             p_init_msg_list          => OKL_API.G_FALSE,
             x_return_status          => x_return_status,
             x_msg_count              => x_msg_count,
             x_msg_data               => x_msg_data,
             p_contract_id            => p_contract_id,
             p_line_id                => NULL,
             p_amount                 => p_amount,
             p_due_date               => p_due_date,
             p_stream_type_purpose    => p_stream_type_purpose,
             p_create_invoice_flag    => p_create_invoice_flag,
             p_process_flag           => p_process_flag,
             p_parent_strm_element_id => NULL,
		     x_invoice_id             => l_invoice_id,
			 x_stream_element_id      => l_stream_element_id);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        print_error_message('Unexpected error raised in call to CREATE_STREAM_INVOICE');
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        print_error_message('Error raised in call to CREATE_STREAM_INVOICE');
        RAISE Create_Daily_Int_Str_failed;
      END IF;

      i_vir_tbl := g_vir_tbl;

      upd_vir_params_with_invoice (
              p_api_version   => 1.0,
              p_init_msg_list => OKL_API.G_TRUE,
              x_return_status => x_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_source_id     => l_stream_element_id,
              p_vir_tbl       => i_vir_tbl,
              x_vir_tbl       => r_vir_tbl);
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        print_error_message('Unexpected error raised in call to UPD_VIR_PARAMS_WITH_INVOICE');
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        print_error_message('Error raised in call to UPD_VIR_PARAMS_WITH_INVOICE');
        RAISE Create_Daily_Int_Str_failed;
      END IF;

      g_vir_tbl := r_vir_tbl;

      populate_vir_params(
               p_api_version    => 1.0,
               p_init_msg_list  => OKL_API.G_TRUE,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_vir_tbl        => g_vir_tbl);
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        print_error_message('Unexpected error raised in call to POPULATE_VIR_PARAMS');
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        print_error_message('Error raised in call to POPULATE_VIR_PARAMS');
        RAISE Create_Daily_Int_Str_failed;
      END IF;

      g_vir_tbl.delete;
	  g_vir_tbl_counter := 0;

	ELSIF (p_stream_type_purpose = 'DAILY_INTEREST_PRINCIPAL') THEN
	  l_total_asset_val := 0;
	  FOR current_line in contract_line_csr(p_contract_id, p_due_date)
	  LOOP
        -- Derive Asset Cost
        Okl_Execute_Formula_Pub.EXECUTE(
		    p_api_version          => 1.0,
            p_init_msg_list        => OKL_API.G_FALSE,
            x_return_status        => x_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data,
            p_formula_name         => 'LINE_OEC',
            p_contract_id          => p_contract_id,
            p_line_id              => current_line.id,
            x_value               =>  l_asset_cost);
        IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	      print_debug ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE completed successfully');
        ELSIF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	      print_debug ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned unexpected error');
	      print_error_message ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned unexpected error');
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
  	      print_debug ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned exception');
	      print_error_message ('Procedure OKL_EXECUTE_FORMULA_PUB.EXECUTE returned exception');
          RAISE Create_Daily_Int_Str_failed;
        END IF;

        IF (l_asset_cost > 0) THEN
          l_line_index                          := l_line_index + 1;
          l_asset_line_tbl(l_line_index).id     := current_line.id;
          l_asset_line_tbl(l_line_index).amount := l_asset_cost;
          l_total_asset_val                     := l_total_asset_val + l_asset_cost;
          print_debug('Asset id :' || l_asset_line_tbl(l_line_index).id || ' Asset Cost :' || l_asset_cost);
        END IF;
	  END LOOP;

      l_asset_line_tbl_count := l_asset_line_tbl.COUNT;
      l_invoice_amt          := p_amount;

      IF (l_asset_line_tbl_count > 0) THEN
        print_debug('Creating DAILY_INTEREST_PRINCIPAL streams for assets.');

        FOR l_index in 1 .. l_asset_line_tbl_count
        LOOP
          l_prorated_invoice_amt := OKL_ACCOUNTING_UTIL.round_amount((l_asset_line_tbl(l_index).amount * l_invoice_amt / l_total_asset_val),p_currency_code);

          print_debug('Creating DAILY_INTEREST_PRINCIPAL streams for asset id : ' || l_asset_line_tbl(l_index).id || ' for Amount :' || l_prorated_invoice_amt);

          Create_Stream_Invoice (
                 p_api_version            => 1.0,
                 p_init_msg_list          => OKL_API.G_FALSE,
                 x_return_status          => x_return_status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data,
                 p_contract_id            => p_contract_id,
                 p_line_id                => l_asset_line_tbl(l_index).id,
                 p_amount                 => l_prorated_invoice_amt,
                 p_due_date               => p_due_date,
                 p_stream_type_purpose    => p_stream_type_purpose,
                 p_create_invoice_flag    => p_create_invoice_flag,
                 p_process_flag           => p_process_flag,
                 p_parent_strm_element_id => NULL,
       			 x_invoice_id             => l_invoice_id,
            	 x_stream_element_id      => l_stream_element_id);

          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            print_error_message('Unexpected error raised in call to CREATE_STREAM_INVOICE');
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            print_error_message('Error raised in call to CREATE_STREAM_INVOICE');
            RAISE Create_Daily_Int_Str_failed;
          END IF;
          print_debug('Successfully created DAILY_INTEREST_PRINCIPAL streams for asset id : ' || l_asset_line_tbl(l_index).id || ' for Amount :' || l_prorated_invoice_amt);
          l_invoice_amt     := l_invoice_amt - l_prorated_invoice_amt;
		  l_total_asset_val := l_total_asset_val - l_asset_line_tbl(l_index).amount;
        END LOOP;
      ELSE /* The contract is a revolving loan */
        print_debug('Creating DAILY_INTEREST_PRINCIPAL streams '|| ' for Amount :' || l_invoice_amt);

        Create_Stream_Invoice (
               p_api_version            => 1.0,
               p_init_msg_list          => OKL_API.G_FALSE,
               x_return_status          => x_return_status,
               x_msg_count              => x_msg_count,
               x_msg_data               => x_msg_data,
               p_contract_id            => p_contract_id,
               p_line_id                => NULL,
               p_amount                 => l_invoice_amt,
               p_due_date               => p_due_date,
               p_stream_type_purpose    => p_stream_type_purpose,
               p_create_invoice_flag    => p_create_invoice_flag,
               p_process_flag           => p_process_flag,
               p_parent_strm_element_id => NULL,
   			   x_invoice_id             => l_invoice_id,
               x_stream_element_id      => l_stream_element_id);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          print_error_message('Unexpected error raised in call to CREATE_STREAM_INVOICE');
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          print_error_message('Error raised in call to CREATE_STREAM_INVOICE');
          RAISE Create_Daily_Int_Str_failed;
        END IF;
        print_debug('Successfully created DAILY_INTEREST_PRINCIPAL streams ' || ' for Amount :' || l_invoice_amt);

      END IF;
    END IF;

  EXCEPTION
    WHEN Create_Daily_Int_Str_failed THEN
      print_error_message('Exception Create_Daily_Int_Str_failed raised in procedure CREATE_DAILY_INTEREST_STREAMS');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      print_error_message('Exception raised in procedure CREATE_DAILY_INTEREST_STREAMS');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      Okl_Api.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => SQLCODE,
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => SQLERRM);

  END Create_Daily_Interest_Streams;
------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    calculate_total_interest_due
    -- Description:      This procedure is called by Variable Interest Calculation for Loans
    --                   Inputs :
    --                   Output : Interest Calculated
    -- Dependencies:
    -- Parameters:       Start Date, End Date, Interest Rate Range.
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  FUNCTION calculate_total_interest_due(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_contract_id     IN  NUMBER,
            p_currency_code   IN  VARCHAR2,
            p_start_date      IN  DATE,
            p_due_date        IN  DATE,
            p_principal_basis IN  VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

  l_api_version             CONSTANT NUMBER := 1.0;
  l_api_name	            CONSTANT VARCHAR2(30) := 'CALCULATE_TOTAL_INTEREST_DUE';
  l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_interest_calculated     NUMBER := 0;
  r_principal_balance_tbl   principal_balance_tbl_typ;
--  l_interest_basis          OKL_K_RATE_PARAMS.interest_basis_code%TYPE;
--  l_formula_id              OKL_K_RATE_PARAMS.calculation_formula_id%TYPE;
  l_formula_name            OKL_FORMULAE_V.name%TYPE;
  calc_total_int_due_failed EXCEPTION;

/*
  Cursor interest_params_csr (p_contract_id NUMBER, p_effective_date DATE) IS
      SELECT interest_basis_code, calculation_formula_id
      FROM   okl_k_rate_params
      WHERE  khr_id = p_contract_id
      AND    p_effective_date BETWEEN effective_from_date and nvl(effective_to_date, p_effective_date)
      AND    parameter_type_code = 'ACTUAL';
*/

  Cursor formula_csr (p_formula_id NUMBER) IS
      SELECT name
      FROM   okl_formulae_v
      WHERE  id = p_formula_id;

/*
  Cursor interest_calc_basis_csr (p_contract_id NUMBER) IS
      SELECT ppm.interest_calculation_basis
      FROM   okl_k_headers khr,
             okl_product_parameters_v ppm
       WHERE khr.pdt_id = ppm.id
         AND khr.id = p_contract_id;
*/

  BEGIN
    ------------------------------------------------------------
    -- Start processing
    ------------------------------------------------------------

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    print_debug('Executing function CALCULATE_TOTAL_INTEREST_DUE using following parameters : ');
    print_debug('contract ID : '|| p_contract_id);
	print_debug('Currency Code : '|| p_currency_code);
	print_debug('start date : '|| p_start_date);
	print_Debug('Due date : '|| p_due_date);

	Initialize_contract_params( p_api_version   => 1.0,
                                p_init_msg_list => OKL_API.G_FALSE,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_contract_id   => p_contract_id
                              );
    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS completed successfully');
    ELSIF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
  	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS returned unexpected error');
  	   print_error_message ('Procedure INITIALIZE_CONTRACT_PARAMS returned unexpected error');
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	   print_debug ('Procedure INITIALIZE_CONTRACT_PARAMS returned exception');
	   print_error_message ('Procedure INITIALIZE_CONTRACT_PARAMS returned exception');
       RAISE calc_total_int_due_failed;
    END IF;

/*
    OPEN  interest_params_csr(p_contract_id, SYSDATE);
    FETCH interest_params_csr INTO l_interest_basis, l_formula_id;
    IF (interest_params_csr%NOTFOUND) THEN
      CLOSE interest_params_csr;
      print_error_message('Interest Params cursor did not return any records for contract ID: '|| p_contract_id);
      RAISE calc_total_int_due_failed;
    END IF;
    CLOSE interest_params_csr;

    OPEN  interest_calc_basis_csr(p_contract_id);
    FETCH interest_calc_basis_csr INTO g_interest_calculation_basis;
    IF (interest_calc_basis_csr%NOTFOUND) THEN
      CLOSE interest_calc_basis_csr;
      print_error_message('Interest calculation Basis cursor did not return any records for contract ID: '|| p_contract_id);
      RAISE calc_total_int_due_failed;
    END IF;
    CLOSE interest_calc_basis_csr;
*/

    print_debug('Interest Basis: '|| G_INTEREST_BASIS_CODE || ' formula ID :'|| G_CALCULATION_FORMULA_ID);

    IF (G_INTEREST_BASIS_CODE = 'SIMPLE') THEN

       prin_date_range_var_rate_ctr (
                                     p_api_version           => 1.0,
                                     p_init_msg_list         => OKL_API.G_FALSE,
                                     x_return_status         => x_return_status,
                                     x_msg_count             => x_msg_count,
                                     x_msg_data              => x_msg_data,
                                     p_contract_id           => p_contract_id,
                                     p_line_id               => NULL,
                                     p_start_date            => p_start_date,
                                     p_due_date              => p_due_date,
                                     p_principal_basis       => p_principal_basis,
                                     x_principal_balance_tbl => r_principal_balance_tbl);
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         print_error_message('Unexpected error raised in call to PRIN_DATE_RANGE_VAR_RATE_CTR');
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         print_error_message('Error raised in call to PRIN_DATE_RANGE_VAR_RATE_CTR');
         RAISE calc_total_int_due_failed;
       END IF;
       print_debug ('Before call to Calc_Variable_Rate_Interest');

       l_interest_calculated := Calc_Variable_Rate_Interest (
                                                             p_api_version           => p_api_version,
                                                             p_init_msg_list         => OKL_API.G_FALSE,
                                                             x_return_status         => x_return_status,
                                                             x_msg_count             => x_msg_count,
                                                             x_msg_data              => x_msg_data,
                                                             p_contract_id           => p_contract_id,
                                                             p_currency_code         => p_currency_code,
                                                             p_principal_balance_tbl => r_principal_balance_tbl);
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         print_error_message('Unexpected error raised in call to CALC_VARIABLE_RATE_INTEREST');
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         print_error_message('Error raised in call to CALC_VARIABLE_RATE_INTEREST');
         RAISE calc_total_int_due_failed;
       END IF;
    ELSE
       OPEN  formula_csr(G_CALCULATION_FORMULA_ID);
       FETCH formula_csr INTO l_formula_name;
       IF (formula_csr%NOTFOUND) THEN
         CLOSE formula_csr;
         print_error_message('Formula cursor did not return any records for formula ID: '|| G_CALCULATION_FORMULA_ID);
         RAISE calc_total_int_due_failed;
       END IF;
       CLOSE formula_csr;

       -- Derive Interest using formula
       Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => 1.0,
                                       p_init_msg_list        => OKL_API.G_TRUE,
                                       x_return_status        => x_return_status,
                                       x_msg_count            => x_msg_count,
                                       x_msg_data             => x_msg_data,
                                       p_formula_name         => l_formula_name,
                                       p_contract_id          => p_contract_id,
                                       p_line_id              => NULL,
                                       x_value               =>  l_interest_calculated
                                      );
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         print_error_message('Unexpected error raised in call to OKL_EXECUTE_FORMULA_PUB.EXECUTE');
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         print_error_message('Error raised in call to OKL_EXECUTE_FORMULA_PUB.EXECUTE');
         RAISE calc_total_int_due_failed;
       END IF;
    END IF;
    RETURN l_interest_calculated;
  EXCEPTION
    WHEN calc_total_int_due_failed THEN
      print_error_message('Exception calc_total_int_due_failed raised in function CALCULATE_TOTAL_INTEREST_DUE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN -1;
    WHEN OTHERS  THEN
      print_error_message('Exception raised in function CALCULATE_TOTAL_INTEREST_DUE');
      Okl_Api.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => SQLCODE,
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN -1;
  END calculate_total_interest_due;

  PROCEDURE initiate_request(p_api_version        IN  NUMBER,
			             p_init_msg_list      IN  VARCHAR2,
                   p_khr_id            IN  NUMBER,
--					         p_from_date          IN  DATE,
--					         p_to_date            IN  DATE,
					         x_return_status      OUT NOCOPY VARCHAR2,
					         x_msg_count          OUT NOCOPY NUMBER,
					         x_msg_data           OUT NOCOPY VARCHAR2)
					         --x_request_id         OUT NOCOPY NUMBER,
					         --x_trans_status       OUT NOCOPY VARCHAR2)
  IS


  l_vipv_rec                         vipv_rec;
  x_vipv_rec                         vipv_rec;
  l_skip_prc_engine                  VARCHAR2(1) := OKL_API.G_FALSE;
  --l_rents_tbl and l_rents_tbl_in used for lease processing
  l_rents_tbl                        Okl_Create_Streams_Pub.csm_periodic_expenses_tbl_type;
  l_rents_tbl_in                     Okl_Create_Streams_Pub.csm_periodic_expenses_tbl_type;
  --l_rents_prin_tbl used for loan processing
  l_rents_prin_tbl                   csm_periodic_expenses_tbl_type;
  l_csm_loan_header                  okl_create_streams_pvt.csm_loan_rec_type;
  l_csm_loan_lines_tbl               okl_create_streams_pvt.csm_loan_line_tbl_type;
  l_csm_loan_levels_tbl              okl_create_streams_pvt.csm_loan_level_tbl_type;
  l_csm_one_off_fee_tbl              Okl_Create_Streams_Pub.csm_one_off_fee_tbl_type;
  l_csm_periodic_expenses_tbl        Okl_Create_Streams_Pub.csm_periodic_expenses_tbl_type;
  l_csm_yields_tbl                   Okl_Create_Streams_Pub.csm_yields_tbl_type;
  l_csm_stream_types_tbl             Okl_Create_Streams_Pub.csm_stream_types_tbl_type;
  --p_csm_loan_levels_tbl              csm_loan_level_tbl_type;
  l_csm_loan_levels_tbl_in           csm_loan_level_tbl_type;
  l_csm_lease_header                 okl_create_streams_pvt.csm_lease_rec_type;
  l_csm_line_details_tbl             okl_create_streams_pvt.csm_line_details_tbl_type;
  l_req_stream_types_tbl             Okl_Create_Streams_Pub.csm_stream_types_tbl_type;

  l_index                         NUMBER := 0;
  l_return_status	                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_api_name	                    CONSTANT VARCHAR2(30) := 'initiate_request';
  l_api_version	                  CONSTANT NUMBER := 1;
  l_start_date	                  DATE;
  amount			                    NUMBER;
  tot_amount                      NUMBER;
  l_no_of_periods	                NUMBER;
  l_reamort_date	                DATE;
  chr_start_date	                DATE;
  --l_interest_rec                    interest_rec;
  lx_interest_rec                 interest_rec;
  --i	                              NUMBER:=1;
  --j	                              NUMBER:=1;
  l_deal_type	                    OKL_K_HEADERS.DEAL_TYPE%TYPE;
  l_msg_index_out                 NUMBER;
  l_term_duration	                NUMBER;
  l_tot_principal_amount          NUMBER := 0;
  l_frequency                     okc_rules_b.object1_id1%type;
  l_csm_line_details_ctr          NUMBER;
  l_first_row                     NUMBER;
  l_loan_levels_cntr              NUMBER;
  l_loan_levels_date_start        DATE;
  l_period_cntr                   NUMBER := 0;
  l_number_of_periods             NUMBER := 0;
  l_adder_months                  NUMBER := 0;
  l_interest_rate_tbl             interest_rate_tbl_type;
  l_interest_rate_tbl_count       NUMBER;
  l_interest_rate_tbl_index       NUMBER;
  l_contract_number               okc_k_headers_b.contract_number%type;
  l_principal_balance_tbl         okl_variable_interest_pvt.principal_balance_tbl_typ;
  l_total_lending                 NUMBER;

  l_rent_date_start               DATE;
  l_rent_cntr                     NUMBER;

  l_level_date_start              DATE;
  l_stub_level_date_start         DATE;

  l_super_trump_request_id        NUMBER;
  l_trans_status                  OKL_STREAM_INTERFACES.SIS_CODE%TYPE;

  l_request_id                    NUMBER;
  l_program_application_id        NUMBER;
  l_program_id                    NUMBER;
  l_program_update_date           DATE;
  l_sequence                      NUMBER := 0;
  l_prev_kle_id                   NUMBER := NULL;
  l_remaining_term_in_months      NUMBER;
  l_child_trx_id                  NUMBER := NULL;
  l_advance_or_arrears            VARCHAR2(100) := NULL;
  --l_made_super_trump_call         BOOLEAN := TRUE;
  initiate_request_failed         EXCEPTION;
  -- Added by prasjain bug# 6142095
  l_interest_rate                 okl_var_int_params.INTEREST_RATE%type;
  l_rebook_flag                   BOOLEAN := TRUE;
  l_interest_calc_end_date        DATE;
  -- End by prasjain bug# 6142095
  --dkagrawa changed query to use view okl_prod_qlty_val_uv than okl_product_parameters_v for performance
  CURSOR c_chr_id (cp_khr_id VARCHAR2) IS
  SELECT okc.contract_number
       , NVL(okl.date_last_interim_interest_cal, okc.start_date) start_date
       , okl.deal_type deal_type
       , ppm.quality_val interest_calculation_basis
       , okc.authoring_org_id
       , round(months_between(okc.end_date, okl.date_last_interim_interest_cal)) remaining_term_in_months
  FROM   okc_k_headers_b okc
       , okl_k_headers okl
       , okl_prod_qlty_val_uv ppm
  WHERE  okc.id = cp_khr_id
  AND    okl.id = okc.id
  AND    okl.pdt_id = ppm.pdt_id
  AND    ppm.quality_name = 'INTEREST_CALCULATION_BASIS';

  /*CURSOR c_terms_cur (p_contract_id NUMBER, p_reamort_date DATE) IS
  SELECT max(sel.stream_element_date)
  FROM    okl_strm_elements sel,
          okl_streams     stm,
  	      okl_strm_type_b sty,
          okc_k_headers_b   khr
  WHERE	stm.khr_id          = p_contract_id
  AND	stm.active_yn		= 'Y'
  AND	stm.say_code		= 'CURR'
  AND	sty.id				= stm.sty_id
  AND   sty.stream_type_purpose = 'PRINCIPAL_PAYMENT'
  AND	sty.billable_yn		= 'Y'
  AND	sel.stm_id          = stm.id
  and   sel.stream_element_date <= p_reamort_date
  and   stm.khr_id          = khr.id;*/

  CURSOR c_periods_cur(p_contract_id NUMBER, p_period_date DATE) IS
  SELECT (KHR.TERM_DURATION - round(months_between(nvl(p_period_date,K.START_DATE), K.START_DATE))) MTH,
         KHR.TERM_DURATION  term_duration
  FROM   OKC_K_HEADERS_B K, OKL_K_HEADERS KHR
  WHERE  K.id  = p_contract_id
  and    K.id = KHR.id;

  CURSOR c_freq_cur(p_contract_id NUMBER) IS
  select object1_id1 from okc_rules_b
  where dnz_chr_id = p_contract_id
  and rule_information_category = 'LASLL';

  -- Added by prasjain bug# 6142095
  CURSOR var_int_params_csr (p_contract_id NUMBER) IS
    SELECT interest_rate,interest_calc_end_date
      FROM okl_var_int_params
     WHERE khr_id                 = p_contract_id
       AND INTEREST_CALC_END_DATE = (SELECT max(INTEREST_CALC_END_DATE) FROM okl_var_int_params WHERE khr_id = p_contract_id);

  CURSOR c_last_int_cur (p_contract_id NUMBER) IS
    SELECT NVL(date_last_interim_interest_cal, start_date) reamort_date
      FROM okl_k_headers_full_v
     WHERE id = p_contract_id;
   -- End by prasjain bug# 6142095
--start |  19-May-08 cklee  fixed Bug 7043360                                       |
  l_line_id_buf okl_k_lines.id%type := -1;
--end |  19-May-08 cklee  fixed Bug 7043360                                       |

  BEGIN

  	x_return_status := OKL_API.G_RET_STS_SUCCESS;

    print_debug('****Entering procedure INITIATE_REQUEST****');
    FND_FILE.PUT_LINE (FND_FILE.LOG,'Initiating Super Trump Request');


    OPEN c_chr_id(p_khr_id);
    FETCH c_chr_id INTO l_contract_number, l_start_date, G_DEAL_TYPE, G_INTEREST_CALCULATION_BASIS, G_AUTHORING_ORG_ID, l_remaining_term_in_months;
    CLOSE c_chr_id;

    --Bug# 8756653
    -- Check if contract has been upgraded for effective dated rebook
    -- for all mass rebooks other than partial termination
    OKL_LLA_UTIL_PVT.check_rebook_upgrade
      (p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_chr_id          => p_khr_id);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE initiate_request_failed;
    END IF;

    /*if(p_from_date is null) THEN
            l_start_date := chr_start_date;
    else
        --I THINK WE DO NOT NEED THIS CODE
        --PLEASE CHECK
        OPEN c_terms_cur(p_khr_id, p_from_date);
        FETCH c_terms_cur INTO p_start_date;
        CLOSE c_terms_cur;
    end if;*/



    /*if (p_start_date is null) THEN
        p_start_date := p_from_date;
    end if;*/

    OPEN c_periods_cur(p_khr_id, l_start_date);
    FETCH c_periods_cur INTO l_no_of_periods, l_term_duration;
    CLOSE c_periods_cur;

    OPEN c_freq_cur(p_khr_id);
    FETCH c_freq_cur INTO l_frequency;
    CLOSE c_freq_cur;

    print_debug('From Date :'||l_start_date||' Interest Start Date: '||l_start_date||
                        ' Periods: '||l_no_of_periods);
    if(l_frequency = 'M') THEN
              l_no_of_periods := l_no_of_periods;
              l_adder_months := 1;
    elsif(l_frequency = 'Q') THEN
              l_no_of_periods := ROUND(l_no_of_periods/3);
              l_adder_months := 3;
    elsif(l_frequency = 'S') THEN
              l_no_of_periods := ROUND(l_no_of_periods/6);
              l_adder_months := 6;
    elsif(l_frequency = 'A') THEN
              l_no_of_periods := ROUND(l_no_of_periods/12);
              l_adder_months := 12;
    end if;

    --l_interest_rec.khr_id   := p_chr_id;
    --l_interest_rec.start_date := l_start_date;

    --CHANGE THIS CODE TO FETCH INTEREST RATE
    /*interest_cal(
                p_api_version    =>     p_api_version,
                p_init_msg_list  =>     p_init_msg_list,
                x_return_status  =>     x_return_status,
                x_msg_count      =>     x_msg_count,
                x_msg_data       =>     x_msg_data,
                p_interest_rec   =>     l_interest_rec,
                x_interest_rec   =>     lx_interest_rec);

    print_debug('From Date :'||l_start_date||' Interest Start Date: '||l_start_date||
                        ' Periods: '||l_no_of_periods);*/

    interest_date_range (
            p_api_version       => p_api_version,
            p_init_msg_list     => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_contract_id       => p_khr_id,
            p_start_date        => l_start_date,
            p_end_date          => l_start_date,
            p_process_flag      => G_INTEREST_CALCULATION_BASIS, /* value is set in Calculate_total_interest_due */
            x_interest_rate_tbl => l_interest_rate_tbl);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE initiate_request_failed;
    END IF;

    l_interest_rate_tbl_count := l_interest_rate_tbl.COUNT;

    print_debug('No. of records in Interest Date Range TAble : '|| l_interest_rate_tbl_count);

    IF (l_interest_rate_tbl_count = 0) THEN
       print_error_message('Interest rate unavailable.');
       RAISE initiate_request_failed;
    END IF;
    l_interest_rate_tbl_index := l_interest_rate_tbl.FIRST;

    -- Added by prasjain bug# 6142095
    OPEN var_int_params_csr(p_khr_id);
    FETCH var_int_params_csr INTO l_interest_rate,l_interest_calc_end_date;
    CLOSE var_int_params_csr;

    print_debug('Last interest rate calculated as  : '|| l_interest_rate);
    print_debug('Interest rate in Index  : '|| l_interest_rate_tbl(l_interest_rate_tbl_index).rate);

--start |  30-Apr-08 cklee  fixed Bug 6994233                                       |
    OPEN c_last_int_cur (p_khr_id);
    FETCH c_last_int_cur INTO l_reamort_date;
    CLOSE c_last_int_cur;
--end |  30-Apr-08 cklee  fixed Bug 6994233                                       |

    If l_interest_rate_tbl(l_interest_rate_tbl_index).rate = l_interest_rate then
--start |  30-Apr-08 cklee  fixed Bug 6994233                                       |
--       OPEN c_last_int_cur (p_khr_id);
--       FETCH c_last_int_cur INTO l_reamort_date;
--       CLOSE c_last_int_cur;
--end |  30-Apr-08 cklee  fixed Bug 6994233                                       |
       -- if l_interest_calc_end_date is equal to l_reamort_date
       -- means that ESG got failed last time and we need to rebook the contract
       If TRUNC(l_interest_calc_end_date) <> TRUNC(l_reamort_date) then
         print_debug('Both interest rates are same hence rebooking is not required');
        l_rebook_flag := FALSE;
       End if;
    End if;
    -- End by prasjain bug# 6142095

    /*FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'From Date: ' || l_start_date);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Interest Start Date: '||l_start_date);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Periods: '||l_no_of_periods);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Effective interest rate: '||lx_interest_rec.effective_rate);*/
    If l_rebook_flag  Then -- Added by prasjian bug# 6142095
    If (G_DEAL_TYPE = 'LOAN') THEN
      OKL_LA_STREAM_PUB.extract_params_loan_reamort(p_api_version               => p_api_version,
  	                             p_init_msg_list             => p_init_msg_list,
                                 p_chr_id                    => p_khr_id,
                    					   x_return_status             => x_return_status,
                						     x_msg_count                 => x_msg_count,
                                 x_msg_data                  => x_msg_data,
                    					   x_csm_loan_header           => l_csm_loan_header,
                    					   x_csm_loan_lines_tbl        => l_csm_loan_lines_tbl,
                    					   x_csm_loan_levels_tbl       => l_csm_loan_levels_tbl,
                    					   x_csm_one_off_fee_tbl       => l_csm_one_off_fee_tbl,
                    					   x_csm_periodic_expenses_tbl => l_csm_periodic_expenses_tbl,
                    					   x_csm_yields_tbl            => l_csm_yields_tbl,
                    					   x_csm_stream_types_tbl      => l_csm_stream_types_tbl);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     		RAISE initiate_request_failed;
     	END IF;

      print_debug('Contents of l_csm_loan_levels_tbl after call to OKL_LA_STREAM_PUB.extract_params_loan.');
      print_loan_tables(p_rent_tbl => l_rents_prin_tbl,
                        p_csm_loan_level_tbl => l_csm_loan_levels_tbl);

      l_csm_loan_header.orp_code := Okl_Create_Streams_Pub.G_ORP_CODE_VARIABLE_INTEREST;
      l_csm_stream_types_tbl.DELETE;
      l_total_lending := 0;
      l_rents_prin_tbl.delete;
      l_sequence := 0;

      --FOR i IN 1..l_csm_loan_levels_tbl.COUNT
      l_loan_levels_cntr := l_csm_loan_levels_tbl.first;
      LOOP
          EXIT WHEN l_loan_levels_cntr IS NULL;

          --CHECK FOR level_type = Okl_Create_Streams_Pub.G_SFE_LEVEL_PRINCIPAL
          --DO NOT MAKE A PRICING CALL IN THIS CASE
          --for Principal Payments only
          IF(l_csm_loan_levels_tbl(l_loan_levels_cntr).level_type = Okl_Create_Streams_Pub.G_SFE_LEVEL_PRINCIPAL)
             AND (l_csm_loan_levels_tbl(l_loan_levels_cntr).lock_level_step = 'false' OR l_csm_loan_levels_tbl(l_loan_levels_cntr).lock_level_step = OKC_API.G_MISS_CHAR) THEN
            --call var_int_rent_level passing the level payments and interest rate

            IF (l_csm_loan_levels_tbl(l_loan_levels_cntr).period = 'T') THEN
              l_loan_levels_date_start := get_pay_level_start_date(l_csm_loan_levels_tbl(l_loan_levels_cntr).kle_loan_id,
                                  l_csm_loan_levels_tbl(l_loan_levels_cntr).level_index_number - 1);
              print_debug('Fetched start date from SLL - l_loan_levels_date_start: ' || l_loan_levels_date_start);
            ELSE
              l_loan_levels_date_start := l_csm_loan_levels_tbl(l_loan_levels_cntr).date_start;
            END IF;
            l_level_date_start := NULL;
            l_number_of_periods := 0;
            FOR l_period_cntr IN 1..l_csm_loan_levels_tbl(l_loan_levels_cntr).number_of_periods LOOP
                IF (l_loan_levels_date_start >= l_start_date) THEN
                  l_number_of_periods := l_number_of_periods + 1;

                  IF (l_level_date_start IS NULL) THEN
                    IF (l_csm_loan_levels_tbl(l_loan_levels_cntr).period = 'T') THEN
                      --l_level_date_start := l_csm_loan_levels_tbl(l_loan_levels_cntr).date_start;
                      --when PRINCIPAL_PAYMENT is defined on a contract
                      --the payment levels are sent from initiate_request to var_int_rent_levels
                      --without making a pricing call
                      l_level_date_start := l_loan_levels_date_start;
                    ELSE
                      l_level_date_start := l_loan_levels_date_start;
                    END IF;
                  END IF;
                END IF;
                l_loan_levels_date_start := add_months(l_loan_levels_date_start,  l_adder_months);
            END LOOP;

            IF (l_number_of_periods > 0) THEN
              --WHEN I MAKE A CALL TO var_int_rent_level, PASSING l_rents_prin_tbl AS AN INPUT PARAMETER,
              --WILL THIS INFORMATION BE SUFFICIENT TO MAKE A REBOOK CALL
              --HOW DO I IDENTIFY THE LINE ID FROM TEH BELOW DATA?
              --CHECK WITH DEBDIP or ASHISH
              --l_rents_prin_tbl(l_loan_levels_cntr).description := l_csm_loan_levels_tbl(l_loan_levels_cntr).description;
              IF (NVl(l_prev_kle_id, -99) <> l_csm_loan_levels_tbl(l_loan_levels_cntr).kle_loan_id) THEN
                --reset the sequence for the level_index_number for each asset
                l_sequence := 1;
                l_prev_kle_id := l_csm_loan_levels_tbl(l_loan_levels_cntr).kle_loan_id;
              ELSE
                l_sequence := l_sequence + 1;
              END IF;
              --l_rents_prin_tbl(l_loan_levels_cntr).level_index_number := l_csm_loan_levels_tbl(l_loan_levels_cntr).level_index_number;
              l_rents_prin_tbl(l_loan_levels_cntr).level_index_number := l_sequence;
              l_rents_prin_tbl(l_loan_levels_cntr).number_of_periods := l_number_of_periods;
              l_rents_prin_tbl(l_loan_levels_cntr).level_type := l_csm_loan_levels_tbl(l_loan_levels_cntr).level_type;
              l_rents_prin_tbl(l_loan_levels_cntr).amount := l_csm_loan_levels_tbl(l_loan_levels_cntr).amount;
              l_rents_prin_tbl(l_loan_levels_cntr).advance_or_arrears := l_csm_loan_levels_tbl(l_loan_levels_cntr).advance_or_arrears;
              l_rents_prin_tbl(l_loan_levels_cntr).period := l_csm_loan_levels_tbl(l_loan_levels_cntr).period;
		          l_rents_prin_tbl(l_loan_levels_cntr).lock_level_step := Okl_Create_Streams_Pub.G_LOCK_RATE;
              l_rents_prin_tbl(l_loan_levels_cntr).first_payment_date := l_level_date_start;
  	          l_rents_prin_tbl(l_loan_levels_cntr).rate := l_interest_rate_tbl(l_interest_rate_tbl_index).rate;

/*              l_rents_prin_tbl(l_loan_levels_cntr).kle_asset_id := l_csm_loan_levels_tbl(l_loan_levels_cntr).kle_loan_id;
              l_rents_prin_tbl(l_loan_levels_cntr).income_or_expense := l_csm_loan_levels_tbl(l_loan_levels_cntr).income_or_expense;
              l_rents_prin_tbl(l_loan_levels_cntr).query_level_yn := Okl_Create_Streams_Pub.G_FND_YES;
              l_rents_prin_tbl(l_loan_levels_cntr).structure := l_csm_loan_levels_tbl(l_loan_levels_cntr).structure;
              l_rents_prin_tbl(l_loan_levels_cntr).days_in_month := l_csm_loan_levels_tbl(l_loan_levels_cntr).days_in_month;
              l_rents_prin_tbl(l_loan_levels_cntr).days_in_year := l_csm_loan_levels_tbl(l_loan_levels_cntr).days_in_year;
*/            END IF;
          --CHECK FOR RENT PAYMENT
          --for Rent and Unscheduled Principal Paydown
          ELSIF(l_csm_loan_levels_tbl(l_loan_levels_cntr).level_type = Okl_Create_Streams_Pub.G_SFE_LEVEL_PAYMENT)
            OR (l_csm_loan_levels_tbl(l_loan_levels_cntr).level_type = Okl_Create_Streams_Pub.G_SFE_LEVEL_PRINCIPAL AND
                l_csm_loan_levels_tbl(l_loan_levels_cntr).lock_level_step = Okl_Create_Streams_Pub.G_LOCK_AMOUNT) THEN
            --if(j = 1) THEN
            --l_loan_levels_date_start := l_csm_loan_levels_tbl(l_loan_levels_cntr).date_start;
            IF (l_csm_loan_levels_tbl(l_loan_levels_cntr).period = 'T') THEN
              l_loan_levels_date_start := get_pay_level_start_date(l_csm_loan_levels_tbl(l_loan_levels_cntr).kle_loan_id,
                                  l_csm_loan_levels_tbl(l_loan_levels_cntr).level_index_number - 1);
              print_debug('Fetched start date from SLL - l_loan_levels_date_start: ' || l_loan_levels_date_start);
            ELSE
              l_loan_levels_date_start := l_csm_loan_levels_tbl(l_loan_levels_cntr).date_start;
            END IF;

            l_level_date_start := NULL;
            l_number_of_periods := 0;
            FOR l_period_cntr IN 1..l_csm_loan_levels_tbl(l_loan_levels_cntr).number_of_periods LOOP
                IF (l_loan_levels_date_start >= l_start_date) THEN
                  l_number_of_periods := l_number_of_periods + 1;

                  IF (l_level_date_start IS NULL) THEN
                    --l_level_date_start := l_loan_levels_date_start;
                    IF (l_csm_loan_levels_tbl(l_loan_levels_cntr).period = 'T') THEN
                      l_level_date_start := l_csm_loan_levels_tbl(l_loan_levels_cntr).date_start;
                    ELSE
                      l_level_date_start := l_loan_levels_date_start;
                    END IF;
                  END IF;
                END IF;
                l_loan_levels_date_start := add_months(l_loan_levels_date_start,  l_adder_months);
            END LOOP;

            IF (l_number_of_periods > 0) THEN
              IF (NVl(l_prev_kle_id, -99) <> l_csm_loan_levels_tbl(l_loan_levels_cntr).kle_loan_id) THEN
                --reset the sequence for the level_index_number for each asset
                l_sequence := 1;
                l_prev_kle_id := l_csm_loan_levels_tbl(l_loan_levels_cntr).kle_loan_id;
              ELSE
                l_sequence := l_sequence + 1;
              END IF;

              l_csm_loan_levels_tbl_in(l_loan_levels_cntr) := l_csm_loan_levels_tbl(l_loan_levels_cntr);
              l_csm_loan_levels_tbl_in(l_loan_levels_cntr).level_index_number := l_sequence;
              l_csm_loan_levels_tbl_in(l_loan_levels_cntr).query_level_yn := Okl_Create_Streams_Pub.G_FND_YES;
  	          l_csm_loan_levels_tbl_in(l_loan_levels_cntr).rate := l_interest_rate_tbl(l_interest_rate_tbl_index).rate;
              IF (l_csm_loan_levels_tbl(l_loan_levels_cntr).level_type = Okl_Create_Streams_Pub.G_SFE_LEVEL_PAYMENT) THEN
		          l_csm_loan_levels_tbl_in(l_loan_levels_cntr).lock_level_step := Okl_Create_Streams_Pub.G_LOCK_RATE;
              ELSIF (l_csm_loan_levels_tbl(l_loan_levels_cntr).level_type = Okl_Create_Streams_Pub.G_SFE_LEVEL_PRINCIPAL) THEN
                  l_csm_loan_levels_tbl_in(l_loan_levels_cntr).lock_level_step := Okl_Create_Streams_Pub.G_LOCK_BOTH;
              END IF;
              l_csm_loan_levels_tbl_in(l_loan_levels_cntr).date_start := l_level_date_start;
              l_csm_loan_levels_tbl_in(l_loan_levels_cntr).number_of_periods := l_number_of_periods;
            END IF;
          ELSIF(l_csm_loan_levels_tbl(l_loan_levels_cntr).level_type = Okl_Create_Streams_Pub.G_SFE_LEVEL_FUNDING) THEN
            --is the below code OK
            --will this table, l_csm_loan_levels_tbl, have more than 1 row
            --looks like each row is being populated with the principal at the contract level and
            --not at the asset level
            --since I am changing the above code for PAYMENTS, does this code need to channge also?
            --THIS TABLE MUST BE POPULATED WITH ASSET LEVEL PRINCIPAL BALANCES
            --THERE WILL BE 1 ROW FOR EACH ASSET
            --ASSET IDENTIFIER kle_loan_id
            IF (NVl(l_prev_kle_id, -99) <> l_csm_loan_levels_tbl(l_loan_levels_cntr).kle_loan_id) THEN
              --reset the sequence for the level_index_number for each asset
              l_sequence := 1;
              l_prev_kle_id := l_csm_loan_levels_tbl(l_loan_levels_cntr).kle_loan_id;
            ELSE
              l_sequence := l_sequence + 1;
            END IF;

            l_csm_loan_levels_tbl_in(l_loan_levels_cntr) := l_csm_loan_levels_tbl(l_loan_levels_cntr);
            l_csm_loan_levels_tbl_in(l_loan_levels_cntr).level_index_number := l_sequence;
       		  l_csm_loan_levels_tbl_in(l_loan_levels_cntr).query_level_yn := Okl_Create_Streams_Pub.G_FND_YES;

            --if the level type is not Principal Paydown then
            --get the principal balance
            IF (NVL(l_csm_loan_levels_tbl_in(l_loan_levels_cntr).period, 'DMF') <> 'T') THEN
              l_csm_loan_levels_tbl_in(l_loan_levels_cntr).number_of_periods := l_no_of_periods;
  			      l_csm_loan_levels_tbl_in(l_loan_levels_cntr).date_start := l_start_date;

--start |  19-May-08 cklee  fixed Bug 7043360                                       |
-- note: Based on the API: prin_date_range_var_rate_ctr, we need to pass p_line_id only once to get the
-- the total principal balance. So we limit one p_line_id to pass to the following API.
-- Additionally, we assume the l_csm_loan_levels_tbl_in is group by kle_loan_id (p_line_id), otherwise
-- the follow if statement won't work properly to get the nly one p_line_id.
            IF l_line_id_buf <> l_csm_loan_levels_tbl_in(l_loan_levels_cntr).kle_loan_id then
--end |  19-May-08 cklee  fixed Bug 7043360                                       |
                  OKL_VARIABLE_INTEREST_PVT.prin_date_range_var_rate_ctr (
                          p_api_version        => p_api_version,
                          p_init_msg_list      => p_init_msg_list,
                          x_return_status      => x_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data,
                          p_contract_id        => p_khr_id,
                          p_line_id            => l_csm_loan_levels_tbl_in(l_loan_levels_cntr).kle_loan_id,
                          p_start_date         => l_start_date,
                          p_due_date           => l_start_date,
                          p_principal_basis    => NULL,
                          x_principal_balance_tbl => l_principal_balance_tbl);

                  IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
                    RAISE initiate_request_failed;
                  END IF;

                  --l_csm_loan_levels_tbl_in(l_loan_levels_cntr).amount := get_tot_principal_amt(p_khr_id, l_start_date);
                  l_csm_loan_levels_tbl_in(l_loan_levels_cntr).amount := l_principal_balance_tbl(l_principal_balance_tbl.COUNT).principal_balance;
                  l_total_lending := l_total_lending + l_csm_loan_levels_tbl_in(l_loan_levels_cntr).amount;

                  print_debug('Kle Id : ' || l_csm_loan_levels_tbl_in(l_loan_levels_cntr).kle_loan_id || 'Principal :'||l_csm_loan_levels_tbl_in(l_loan_levels_cntr).amount);
--start |  19-May-08 cklee  fixed Bug 7043360                                       |
              END IF;
              l_line_id_buf := l_csm_loan_levels_tbl_in(l_loan_levels_cntr).kle_loan_id;
--end |  19-May-08 cklee  fixed Bug 7043360                                       |
            END IF;
            --print_debug('Principal :'||l_csm_loan_levels_tbl_in(l_loan_levels_cntr).amount);
            --FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Principal: '||l_csm_loan_levels_tbl_in(l_loan_levels_cntr).amount);
          END IF;

        l_loan_levels_cntr := l_csm_loan_levels_tbl.next(l_loan_levels_cntr);
      END LOOP;

      l_tot_principal_amount := l_total_lending;
      l_csm_loan_header.date_start := l_start_date;
   	  l_csm_loan_header.date_payments_commencement := l_start_date;
      --l_csm_loan_header.total_lending := get_tot_principal_amt(p_khr_id, l_start_date);
      l_csm_loan_header.total_lending := l_total_lending;


      print_debug('==========================================');
      print_debug('Before pricing call or var_int_rent_level.');
      print_debug('==========================================');
      print_debug('Contents of l_csm_loan_header before pricing call or var_int_rent_level.');
      print_debug('Contract Principal : '||l_csm_loan_header.total_lending);
   	  l_csm_loan_header.lending_rate := l_interest_rate_tbl(l_interest_rate_tbl_index).rate;
      print_debug('Contract Rate : '|| l_csm_loan_header.lending_rate);

      print_debug('date_start :'||l_csm_loan_header.date_start);
      print_debug('date_payments_commencement :'||l_csm_loan_header.date_payments_commencement);
      print_debug('total_lending :'||l_csm_loan_header.total_lending);

      print_debug('# of rows in l_rents_prin_tbl :' || l_rents_prin_tbl.count);
      print_debug('# of rows in l_csm_loan_levels_tbl_in :' || l_csm_loan_levels_tbl_in.count);
      print_debug('# of rows in l_csm_loan_levels_tbl :' || l_csm_loan_levels_tbl.count);

      --put here temporarily during fix for bug 4887391
      --RETURN;

      IF(l_csm_loan_header.lending_rate <> 0) THEN
        IF (NVL(l_rents_prin_tbl.count, 0) = 0) THEN
          --RENT is defined on the contract payments

          --l_made_super_trump_call := TRUE;
          print_debug('Before pricing call.');
          print_loan_tables(p_rent_tbl => l_rents_prin_tbl,
                            p_csm_loan_level_tbl => l_csm_loan_levels_tbl_in);

        	Okl_Create_Streams_Pub.Create_Streams_Loan_Restr(p_api_version          => p_api_version,
                         p_init_msg_list                      => p_init_msg_list,
  										   p_skip_prc_engine                    => l_skip_prc_engine,
  										   p_csm_loan_header                    => l_csm_loan_header,
                         p_csm_loan_lines_tbl                 => l_csm_loan_lines_tbl,
  										   p_csm_loan_levels_tbl                => l_csm_loan_levels_tbl_in,
  										   p_csm_one_off_fee_tbl                => l_csm_one_off_fee_tbl,
  										   p_csm_periodic_expenses_tbl          => l_csm_periodic_expenses_tbl,
  										   p_csm_yields_tbl                     => l_csm_yields_tbl,
  										   p_csm_stream_types_tbl               => l_csm_stream_types_tbl,
  										   x_trans_id                           => l_super_trump_request_id,
  										   x_trans_status                       => l_trans_status,
  										   x_return_status	   			            => x_return_status,
  										   x_msg_count	   			                => x_msg_count,
  										   x_msg_data	   		                    => x_msg_data);
        	--l_return_status := x_return_status;
          print_debug('After pricing call, status :' || l_trans_status);
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
            RAISE initiate_request_failed;
          END IF;

          print_debug('Super trump request id:' || l_super_trump_request_id);
          print_debug('super trump transaction status:'|| l_trans_status);
          print_debug('x return :'||x_return_status);

        ELSE
          --PRINCIPAL PAYMENT is defined on the contract payments
          /*print_loan_tables(p_rent_tbl => l_rents_prin_tbl,
                            p_csm_loan_level_tbl => l_csm_loan_levels_tbl);*/

          --l_made_super_trump_call := FALSE;
          print_debug('Before calling var_int_rent_level.');
          print_loan_tables(p_rent_tbl => l_rents_prin_tbl,
                            p_csm_loan_level_tbl => l_csm_loan_levels_tbl);

          var_int_rent_level(
                  p_api_version   => p_api_version,
                  p_init_msg_list => p_init_msg_list,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_chr_id        => p_khr_id,
                  p_trx_id        => NULL,
                  p_trx_status    => NULL,
                  p_rent_tbl      => l_rents_prin_tbl,
                  p_csm_loan_level_tbl => l_csm_loan_levels_tbl,
                  x_child_trx_id => l_child_trx_id);

          print_debug('After calling var_int_rent_level, status :' || x_return_status);
          print_debug('Rebook child request id:' || l_child_trx_id);

          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
            RAISE initiate_request_failed;
          END IF;
        END IF;
      END IF;
    ELSE
      --G_DEAL_TYPE = LEASE

       --principal_amount := get_tot_principal_amt(p_khr_id, null);
       -- CAll Extraction API

       --FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Principal Balance: '||principal_amount);
       --print_debug('Principal Balance: '||principal_amount);

       OKL_LA_STREAM_PUB.EXTRACT_PARAMS_LEASE(
					p_api_version               => p_api_version,
          p_init_msg_list             => p_init_msg_list,
          p_chr_id                    => p_khr_id,
					x_return_status             => x_return_status,
					x_msg_count                 => x_msg_count,
 	        x_msg_data                  => x_msg_data,
					x_csm_lease_header          => l_csm_lease_header,
					x_csm_one_off_fee_tbl       => l_csm_one_off_fee_tbl,
					x_csm_periodic_expenses_tbl => l_csm_periodic_expenses_tbl,
					x_csm_yields_tbl            => l_csm_yields_tbl,
					x_req_stream_types_tbl      => l_req_stream_types_tbl,
					x_csm_line_details_tbl      => l_csm_line_details_tbl,
					x_rents_tbl                 => l_rents_tbl);
       FOR i in 1..x_msg_count
       LOOP
          FND_MSG_PUB.GET(
                      p_msg_index     => i,
                      p_encoded       => FND_API.G_FALSE,
                      p_data          => x_msg_data,
                      p_msg_index_out => l_msg_index_out
                     );
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||to_char(i)||': '||x_msg_data);
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Message Index: '||l_msg_index_out);
          print_debug('Error '||to_char(i)||': '||x_msg_data);
          print_debug('Message Index: '||l_msg_index_out);
       END LOOP;

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          print_error_message('Status after Extract params: '||x_return_status);
          print_error_message('Message after Extract params: '||x_msg_data);
 		      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          print_error_message('Status after Extract params: '||x_return_status);
          RAISE initiate_request_failed;
       END IF;
    	 --Fine tune the params
     	 --x_csm_lease_header
       print_debug('Status after Extract params: '||x_return_status);

       print_debug('Contents of l_rents_tbl and l_csm_line_details_tbl after call to Extract params.');
       print_lease_tables(p_rents_tbl_in => l_rents_tbl,
                          p_csm_line_details_tbl => l_csm_line_details_tbl);

       l_csm_lease_header.orp_code := OKL_CREATE_STREAMS_PUB.G_ORP_CODE_VARIABLE_INTEREST;
       l_csm_lease_header.implicit_interest_rate := l_interest_rate_tbl(l_interest_rate_tbl_index).rate;
   	   l_csm_lease_header.date_payments_commencement := l_start_date;
   	   l_csm_lease_header.date_delivery := l_start_date;
       l_csm_lease_header.term := l_remaining_term_in_months;

       --Check the following with Susan.
       --KEERTHI WILL CHECK THE VALIDITY OF BELOW 2 FIELDS
       --FIND OUT FROM PM'S, ALVARO/SUSAN
       l_csm_lease_header.adjust := 'Rent';
       l_csm_lease_header.adjustment_method := 'Proportional';

       print_debug('----------------------------------------------------');
       print_debug('l_csm_lease_header information');
       print_debug('orp_code :'||l_csm_lease_header.orp_code);
       print_debug('implicit_interest_rate :'||l_csm_lease_header.implicit_interest_rate);
       print_debug('adjust :'||l_csm_lease_header.adjust);
       print_debug('adjustment_method :'||l_csm_lease_header.adjustment_method);
       print_debug('date_payments_commencement :'||l_csm_lease_header.date_payments_commencement);
       print_debug('date_delivery :'||l_csm_lease_header.date_delivery);
       print_debug('term :'||l_csm_lease_header.term);

       --we are appending to the existing table below
       --is this correct?
       --CHECK WITH PM'S
       l_index                                 :=  l_csm_yields_tbl.COUNT + 1;
       l_csm_yields_tbl(l_index).siy_type      :=  OKL_SIY_PVT.G_SIY_TYPE_INTEREST_RATE;
       l_csm_yields_tbl(l_index).yield_name    :=  'Full term with residual';
       l_csm_yields_tbl(l_index).target_value  :=  l_interest_rate_tbl(l_interest_rate_tbl_index).rate;
       print_debug('l_csm_yields_tbl information');
       print_debug('siy_type :'||l_csm_yields_tbl(l_index).siy_type);
       print_debug('yield_name :'||l_csm_yields_tbl(l_index).yield_name);
       print_debug('target_value :'||l_csm_yields_tbl(l_index).target_value);


       --l_rents_tbl.delete;
       --Are the values being passed to the l_rents_tbl correct? specifically lock_level_step
       l_rents_tbl_in.delete;
       l_rent_cntr := l_rents_tbl.first;
       LOOP
         EXIT WHEN l_rent_cntr IS NULL;
         --l_rent_date_start := l_rents_tbl(l_rent_cntr).date_start;
         IF (l_rents_tbl(l_rent_cntr).period = 'T') THEN
           l_rent_date_start := get_pay_level_start_date(l_rents_tbl(l_rent_cntr).kle_asset_id,
                                l_rents_tbl(l_rent_cntr).level_index_number);
           print_debug('Fetched start date from SLL - l_rent_date_start: ' || l_rent_date_start);
         ELSE
           l_rent_date_start := l_rents_tbl(l_rent_cntr).date_start;
         END IF;

         l_number_of_periods := 0;
         l_level_date_start := NULL;
         FOR l_period_cntr IN 1..l_rents_tbl(l_rent_cntr).number_of_periods LOOP
           IF (l_rent_date_start  >= l_start_date) THEN
             l_number_of_periods := l_number_of_periods + 1;
             IF (l_level_date_start IS NULL) THEN
                --l_level_date_start := l_rent_date_start;
                IF (l_rents_tbl(l_rent_cntr).period = 'T') THEN
                  l_level_date_start := l_rents_tbl(l_rent_cntr).date_start;
                ELSE
                  l_level_date_start := l_rent_date_start;
                END IF;
             END IF;
           END IF;
           l_rent_date_start := add_months(l_rent_date_start,  l_adder_months);
         END LOOP;

         IF (l_number_of_periods > 0) THEN
           l_rents_tbl_in(l_rent_cntr) := l_rents_tbl(l_rent_cntr);
           l_rents_tbl_in(l_rent_cntr).number_of_periods := l_number_of_periods;
      	   --l_rents_tbl_in(l_rent_cntr).amount := 0;
           --REPLACE THE BELOW VALUE OF NULL WITH Okl_Create_Streams_Pub.G_LOCK_RATE
           l_rents_tbl_in(l_rent_cntr).lock_level_step := Okl_Create_Streams_Pub.G_LOCK_RATE;
           --Check the following with Susan
           --IN THE TABLE l_rents_tbl, OVERWRITE ONLY number_of_periods
           --AND DATE_START FOR THE FIRST PERIOD FROM WHICH REAMORT WILL
           --BE EFFECTIVE
           --l_rents_tbl(1).period := 'M';
           l_rents_tbl_in(l_rent_cntr).rate := l_interest_rate_tbl(l_interest_rate_tbl_index).rate;
           --l_rents_tbl(1).level_index_number := 1;
    	     --l_rents_tbl(1).level_type         := OKL_CREATE_STREAMS_PUB.G_SFE_LEVEL_PAYMENT;
      	   --l_rents_tbl(1).advance_or_arrears := OKL_CREATE_STREAMS_PUB.G_ARREARS;
      	   --l_rents_tbl(1).income_or_expense := OKL_CREATE_STREAMS_PUB.G_INCOME;
      	   l_rents_tbl_in(l_rent_cntr).date_start := l_level_date_start;
           --BELOW VALUE MUST BE SET TO 'Y'
      	   l_rents_tbl_in(l_rent_cntr).query_level_yn := Okl_Create_Streams_Pub.G_FND_YES;
           --l_sequence := l_sequence + 1;
           IF (NVl(l_prev_kle_id, -99) <> l_rents_tbl(l_rent_cntr).kle_asset_id) THEN
              --reset the sequence for the level_index_number for each asset
              l_sequence := 1;
              l_prev_kle_id := l_rents_tbl(l_rent_cntr).kle_asset_id;
           ELSE
              l_sequence := l_sequence + 1;
           END IF;
           l_rents_tbl_in(l_rent_cntr).level_index_number := l_sequence;
         END IF;

         --check to see if contract is in Advance or Arrears
         IF (l_advance_or_arrears IS NULL) THEN
           IF (l_rents_tbl(l_rent_cntr).advance_or_arrears = 'ARREARS') THEN
             l_advance_or_arrears := 'ARREARS';
           ELSE
             l_advance_or_arrears := 'ADVANCE';
           END IF;
         END IF;

         l_rent_cntr := l_rents_tbl.next(l_rent_cntr);
       END LOOP;

  	   --not required
  	   l_req_stream_types_tbl.delete;

       -- Get Principal balance
       --Are the values being passed to the l_csm_line_details_tbl correct?
       --should we maintain the original structure
       --POPULATE l_csm_line_details_tbl WITH ASSET LEVEL VALUES
       --l_first_row := l_row_counter;
/*       l_row_counter := l_csm_line_details_tbl.next(l_row_counter);
       loop
          exit when l_row_counter is null;
          l_csm_line_details_tbl(l_first_row).residual_amount := NVL(l_csm_line_details_tbl(l_first_row).residual_amount, 0) + NVL(l_csm_line_details_tbl(l_row_counter).residual_amount, 0);
          l_row_counter := l_csm_line_details_tbl.next(l_row_counter);
       end loop;
*/
       print_debug('====================================================');
       print_debug('Before Super Trump pricing call');
       l_csm_line_details_ctr := l_csm_line_details_tbl.first;
       LOOP
         EXIT WHEN l_csm_line_details_ctr IS NULL;
         l_csm_line_details_tbl(l_csm_line_details_ctr).asset_cost := get_tot_principal_amt(p_khr_id, l_csm_line_details_tbl(l_csm_line_details_ctr).kle_asset_id,l_start_date, l_advance_or_arrears);
         l_tot_principal_amount := l_tot_principal_amount + l_csm_line_details_tbl(l_csm_line_details_ctr).asset_cost;

         l_csm_line_details_tbl(l_csm_line_details_ctr).date_delivery := l_start_date;
         l_csm_line_details_tbl(l_csm_line_details_ctr).date_funding  := l_start_date;

         print_debug('Asset id: ' || l_csm_line_details_tbl(l_csm_line_details_ctr).kle_asset_id || ' Asset principal balance: ' ||l_csm_line_details_tbl(l_csm_line_details_ctr).asset_cost);
         print_debug('Residual amount : ' || l_csm_line_details_tbl(l_csm_line_details_ctr).residual_amount);
         print_debug('Date delivery : ' || l_csm_line_details_tbl(l_csm_line_details_ctr).date_delivery);
         print_debug('Date funding : ' || l_csm_line_details_tbl(l_csm_line_details_ctr).date_funding);
         --FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Residual amount : ' || l_csm_line_details_tbl(l_csm_line_details_ctr).residual_amount);

/*         l_row_counter := l_csm_line_details_tbl.next(l_first_row);
         loop
            exit when l_row_counter is null;
            l_csm_line_details_tbl.delete(l_row_counter);
            l_row_counter := l_csm_line_details_tbl.next(l_row_counter);
         end loop;
*/
         l_csm_line_details_ctr := l_csm_line_details_tbl.next(l_csm_line_details_ctr);
       END LOOP;

       --l_made_super_trump_call := TRUE;
       print_lease_tables(p_rents_tbl_in => l_rents_tbl_in,
                          p_csm_line_details_tbl => l_csm_line_details_tbl);

       --Call Supertrump API to submit request.
       Okl_Create_Streams_Pub.CREATE_STREAMS_LEASE_RESTR(
				p_api_version               => p_api_version,
        p_init_msg_list             => p_init_msg_list,
				x_return_status             => x_return_status,
				x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data,
				p_csm_lease_header          => l_csm_lease_header,
				p_csm_one_off_fee_tbl       => l_csm_one_off_fee_tbl,
				p_csm_periodic_expenses_tbl => l_csm_periodic_expenses_tbl,
				p_csm_yields_tbl            => l_csm_yields_tbl,
				p_csm_stream_types_tbl      => l_csm_stream_types_tbl,
				p_csm_line_details_tbl      => l_csm_line_details_tbl,
				p_rents_tbl                 => l_rents_tbl_in,
				x_trans_id	   	            => l_super_trump_request_id,
				x_trans_status	   	        => l_trans_status);

       print_debug('Super trump request id:' || l_super_trump_request_id);
       print_debug('super trump transaction status:'|| l_trans_status);
       print_debug('x return :'||x_return_status);

       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         print_error_message('Printing message stack.');
         FOR i in 1..x_msg_count
         LOOP
            FND_MSG_PUB.GET(
                        p_msg_index     => i,
                        p_encoded       => FND_API.G_FALSE,
                        p_data          => x_msg_data,
                        p_msg_index_out => l_msg_index_out
                       );
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||to_char(i)||': '||x_msg_data);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Message Index: '||l_msg_index_out);
            print_error_message('Error '||to_char(i)||': '||x_msg_data);
            print_error_message('Message Index: '||l_msg_index_out);
         END LOOP;
       END IF;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE initiate_request_failed;
       END IF;
    END IF;
    End IF; -- Added by prasjain bug# 6142095

    IF (l_super_trump_request_id IS NOT NULL OR l_child_trx_id IS NOT NULL) AND
        l_rebook_flag = TRUE THEN -- l_rebook_flag = TRUE added by prasjain bug# 6142095
      IF (l_super_trump_request_id IS NOT NULL) THEN
        l_vipv_rec.parent_trx_id        :=  l_super_trump_request_id;
      ELSIF (l_child_trx_id IS NOT NULL) THEN
        l_vipv_rec.parent_trx_id        :=  l_child_trx_id;
      ELSE
        l_vipv_rec.parent_trx_id        :=  null;
      END IF;

      l_vipv_rec.contract_number        :=  l_contract_number;


      print_debug('Updating OKL_VAR_INT_PROCESS_V');
      OKL_VIP_PVT.insert_row(
                             p_api_version                        => p_api_version,
    	                       p_init_msg_list                      => p_init_msg_list,
                      		   x_return_status	   			            => x_return_status,
              						   x_msg_count	   			                => x_msg_count,
              						   x_msg_data	   		                    => x_msg_data,
                             p_vipv_rec                           => l_vipv_rec,
                             x_vipv_rec                           => x_vipv_rec);


    	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
     		RAISE initiate_request_failed;
     	END IF;
      print_debug('Updating OKL_VAR_INT_PROCESS_V Successful');

    END IF; -- Added by prasjain bug# 6142095
    -- Added by prasjain bug# 6142095 to update date_last_interim_interest_cal in case where rebook flag is False
    -- For the cases where Rebook Flag is True the date_last_interim_interest_cal will be updated
    -- In the procedure var_int_rent_level

--start |  30-Apr-08 cklee  fixed Bug 6994233                                       |
--    If l_rebook_flag = FALSE Then
-- dev note:
-- We always need to update date_last_interim_interest_cal with the new l_reamort_date, for example:
-- we have index like follows:
------------------------------
--  Jan  Feb  Mar Apr ...
--  10   10   11  12
------------------------------
--  Say, if the 1st time when the l_reamort_date is Jan, then the index is 10 and system rebook the contract
--  and the 2nd time, system find that the rate is 10 (feb) so the system doesn't rebook the contract. However,
-- the 3rd time, the index shall advance to Mar (index is 11) so that the system will rebook the contract with the
-- proper rate for Jan, Feb, and Mar as well. So system always need to update l_reamort_date to refect the proper rate
-- month by month.
--end |  30-Apr-08 cklee  fixed Bug 6994233                                       |
              if(l_frequency = 'M') THEN
                 UPDATE okl_k_headers khr
                 SET khr.date_last_interim_interest_cal =  add_months(l_reamort_date,1)
                 where khr.id = p_khr_id;
          elsif(l_frequency = 'Q') THEN
                 UPDATE okl_k_headers khr
                 SET khr.date_last_interim_interest_cal =  add_months(l_reamort_date,3)
                 where khr.id = p_khr_id;
          elsif(l_frequency = 'S') THEN
                 UPDATE okl_k_headers khr
                 SET khr.date_last_interim_interest_cal =  add_months(l_reamort_date,6)
                 where khr.id = p_khr_id;
          elsif(l_frequency = 'A') THEN
                 UPDATE okl_k_headers khr
                 SET khr.date_last_interim_interest_cal =  add_months(l_reamort_date,12)
                 where khr.id = p_khr_id;
          end if;
--start |  30-Apr-08 cklee  fixed Bug 6994233                                       |
--    End if;
--end |  30-Apr-08 cklee  fixed Bug 6994233                                       |
    -- End By prasjain bug# 6142095

    -- Added by prasjain bug# 6142095
    IF (l_super_trump_request_id IS NOT NULL OR l_child_trx_id IS NOT NULL OR l_rebook_flag = FALSE) THEN
    -- End by prasjain bug# 6142095

      IF (l_interest_rate_tbl(l_interest_rate_tbl.first).derived_flag = 'Y')THEN
           print_debug('Updating OKL_VAR_INT_PARAMS');

           IF (NVL(g_vir_tbl_counter, 0) = 0) THEN
             g_vir_tbl_counter := NVL(g_vir_tbl_counter, 0) + 1;
           END IF;

      	   SELECT
      	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
      	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
      	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
      	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
      	   INTO
      	  	   l_request_id,
      	  	   l_program_application_id,
      	  	   l_program_id,
      	  	   l_program_update_date
      	   FROM dual;

           g_vir_tbl.delete;
           g_vir_tbl_counter                                     := g_vir_tbl_counter + 1;
           g_vir_tbl(g_vir_tbl_counter).id                       := okc_p_util.raw_to_number(sys_guid());
           g_vir_tbl(g_vir_tbl_counter).khr_id                   := p_khr_id;
           g_vir_tbl(g_vir_tbl_counter).source_table             := 'OKL_VAR_INT_PROCESS_B';
           g_vir_tbl(g_vir_tbl_counter).source_id                := x_vipv_rec.id;
           g_vir_tbl(g_vir_tbl_counter).interest_rate            := l_interest_rate_tbl(l_interest_rate_tbl.first).rate;
           g_vir_tbl(g_vir_tbl_counter).interest_calc_start_date := l_start_date;
           g_vir_tbl(g_vir_tbl_counter).interest_calc_end_date   := l_start_date;
           g_vir_tbl(g_vir_tbl_counter).calc_method_code         := G_CALC_METHOD_CODE;
           g_vir_tbl(g_vir_tbl_counter).principal_balance        := l_tot_principal_amount;
           g_vir_tbl(g_vir_tbl_counter).valid_yn                 := 'Y';
           g_vir_tbl(g_vir_tbl_counter).object_version_number    := 1.0;
           g_vir_tbl(g_vir_tbl_counter).org_id                   := g_authoring_org_id;
           g_vir_tbl(g_vir_tbl_counter).request_id               := l_request_id;
           g_vir_tbl(g_vir_tbl_counter).program_application_id   := l_program_application_id;
           g_vir_tbl(g_vir_tbl_counter).program_id               := l_program_id;
           g_vir_tbl(g_vir_tbl_counter).program_update_date      := SYSDATE;
           g_vir_tbl(g_vir_tbl_counter).attribute_category       := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute1               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute2               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute3               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute4               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute5               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute6               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute7               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute8               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute9               := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute10              := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute11              := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute12              := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute13              := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute14              := NULL;
           g_vir_tbl(g_vir_tbl_counter).attribute15              := NULL;
           g_vir_tbl(g_vir_tbl_counter).created_by               := FND_GLOBAL.USER_ID;
           g_vir_tbl(g_vir_tbl_counter).creation_date            := SYSDATE;
           g_vir_tbl(g_vir_tbl_counter).last_updated_by          := FND_GLOBAL.USER_ID;
           g_vir_tbl(g_vir_tbl_counter).last_update_date         := SYSDATE;
           g_vir_tbl(g_vir_tbl_counter).last_update_login        := FND_GLOBAL.LOGIN_ID;
           g_vir_tbl(g_vir_tbl_counter).interest_amt             := NULL;
           g_vir_tbl(g_vir_tbl_counter).interest_calc_days       := NULL;

           populate_vir_params(
              p_api_version        => p_api_version,
              p_init_msg_list      => p_init_msg_list,
              x_return_status      => x_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data,
              p_vir_tbl            => g_vir_tbl);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             print_error_message('Unexpected error raised in call to POPULATE_VIR_PARAMS');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             print_error_message('Error raised in call to POPULATE_VIR_PARAMS');
             RAISE initiate_request_failed;
           END IF;
           print_debug('Updating OKL_VAR_INT_PARAMS Successful');
           g_vir_tbl.delete;

      END IF;
    END IF;

    print_debug('****Exiting procedure INITIATE_REQUEST****');

  EXCEPTION
    WHEN initiate_request_failed THEN
      print_error_message ('Exception initiate_request_failed raised in procedure initiate_request');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS  THEN
      print_error_message ('Exception raised in procedure initiate_request');
      Okl_Api.SET_MESSAGE(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_ERROR;
  END initiate_request;
------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    variable_interest_float
    -- Description:      This procedure is called by Variable Interest Calculation for Loans / Revolving Loans
    --                   Inputs :
    --                   Output :
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------

  PROCEDURE variable_interest_float_old(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_contract_id     IN  NUMBER,
            p_principal_basis IN  VARCHAR2,
            p_rev_rec_method  IN  VARCHAR2,
            p_deal_type       IN  VARCHAR2,
            p_currency_code   IN  VARCHAR2,
            p_start_date      IN  DATE,
            p_due_date        IN  DATE) IS

    l_api_version             CONSTANT NUMBER := 1.0;
    l_api_name	              CONSTANT VARCHAR2(30) := 'VARIABLE_INTEREST_FLOAT';
    l_return_status	          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_index_out           NUMBER;
    l_principal_balance       NUMBER := 0;
    l_interest_calculated     NUMBER := 0;
    r_principal_balance_tbl   principal_balance_tbl_typ;
    l_total_loan_pmt          NUMBER := 0;
    l_total_principal_pmt     NUMBER := 0;
    l_scheduled_prin_pmnt_amt NUMBER := 0;
    l_invoice_id              NUMBER;
    l_invoice_amt             NUMBER := 0;
    l_interest_paid           NUMBER := 0;
    l_stream_type_purpose     OKL_STRM_TYPE_V.stream_type_purpose%TYPE;
    i_vir_tbl                 vir_tbl_type;
    r_vir_tbl                 vir_tbl_type;
    l_stream_element_id       OKL_STRM_ELEMENTS_v.id%TYPE;

    CURSOR loan_payment_amount_csr (p_khr_id NUMBER, p_due_date DATE, p_stream_type_purpose VARCHAR2) IS
       SELECT nvl(SUM(nvl(sel_prin_pmt.amount, 0)),0) pmt_amt
       FROM  okl_strm_type_v sty_prin_pmt,
             okl_streams_v stm_prin_pmt,
             okl_strm_elements_v sel_prin_pmt
       WHERE stm_prin_pmt.khr_id = p_khr_id
       AND   stm_prin_pmt.id = sel_prin_pmt.stm_id
       AND   sel_prin_pmt.stream_element_date <= p_due_date
       AND   stm_prin_pmt.sty_id = sty_prin_pmt.id
       AND   stm_prin_pmt.active_yn = 'Y'
       AND   stm_prin_pmt.say_code = 'CURR'
       AND   sty_prin_pmt.stream_type_purpose = p_stream_type_purpose ; -- 'PRINCIPAL_PAYMENT'

    CURSOR scheduled_prin_pmnt_amt_csr (p_khr_id NUMBER, p_due_date DATE, p_stream_type_purpose VARCHAR2) IS
       SELECT nvl(SUM(nvl(sel_prin_pmt.amount, 0)),0) pmt_amt
       FROM  okl_strm_type_v sty_prin_pmt,
             okl_streams_v stm_prin_pmt,
             okl_strm_elements_v sel_prin_pmt
       WHERE stm_prin_pmt.khr_id = p_khr_id
       AND   stm_prin_pmt.id = sel_prin_pmt.stm_id
       AND   sel_prin_pmt.stream_element_date = p_due_date
       AND   stm_prin_pmt.sty_id = sty_prin_pmt.id
       AND   stm_prin_pmt.active_yn = 'Y'
       AND   stm_prin_pmt.say_code = 'CURR'
       AND   sty_prin_pmt.stream_type_purpose = p_stream_type_purpose ; -- 'PRINCIPAL_PAYMENT'

  BEGIN
    ------------------------------------------------------------
    -- Start processing
    ------------------------------------------------------------

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    g_vir_tbl.delete;
	g_vir_tbl_counter := 0;

    l_interest_calculated :=  calculate_total_interest_due(
                                        p_api_version     => 1.0,
                                        p_init_msg_list   => OKL_API.G_FALSE,
                                        x_return_status   => x_return_status,
                                        x_msg_count       => x_msg_count,
                                        x_msg_data        => x_msg_data,
                                        p_contract_id     => p_contract_id,
                                        p_currency_code   => p_currency_code,
                                        p_start_date      => p_start_date,
                                        p_due_date        => p_due_date);
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;

       l_total_loan_pmt          := 0;
       l_total_principal_pmt     := 0;
       l_interest_paid           := 0;
       l_scheduled_prin_pmnt_amt := 0;

    IF (p_deal_type = 'LOAN') THEN
       IF (p_principal_basis = 'ACTUAL') THEN
          IF (p_rev_rec_method = 'ACTUAL') THEN
             OPEN  loan_payment_amount_csr (p_contract_id, p_due_date, 'VARIABLE_LOAN_PAYMENT');
             FETCH loan_payment_amount_csr INTO l_total_loan_pmt;
             IF (loan_payment_amount_csr%NOTFOUND) THEN
                l_total_loan_pmt := 0;
             END IF;
             CLOSE loan_payment_amount_csr;

             Print_debug ('Total Variable Loan Payment = '|| l_total_loan_pmt);

             OPEN  loan_payment_amount_csr (p_contract_id, p_due_date, 'PRINCIPAL_PAYMENT');
             FETCH loan_payment_amount_csr INTO l_total_principal_pmt;
             IF (loan_payment_amount_csr%NOTFOUND) THEN
                l_total_principal_pmt := 0;
             END IF;

             CLOSE loan_payment_amount_csr;

             Print_debug ('Total Principal Payment = '|| l_total_principal_pmt);

             l_invoice_amt := l_interest_calculated + l_total_principal_pmt - l_total_loan_pmt;

             Print_debug ('Invoice Amount = '|| l_invoice_amt);

          ELSE
             OPEN  loan_payment_amount_csr (p_contract_id, p_due_date, 'VARIABLE_INTEREST');
             FETCH loan_payment_amount_csr INTO l_interest_paid;
             IF (loan_payment_amount_csr%NOTFOUND) THEN
                l_interest_paid := 0;
             END IF;
             CLOSE loan_payment_amount_csr;

             l_invoice_amt := l_interest_calculated - l_interest_paid;

          END IF;
       ELSIF (p_principal_basis = 'SCHEDULED') THEN
          IF (p_rev_rec_method = 'ACTUAL') THEN
             OPEN   scheduled_prin_pmnt_amt_csr(p_contract_id, p_due_date, 'PRINCIPAL_PAYMENT');
             FETCH  scheduled_prin_pmnt_amt_csr INTO l_scheduled_prin_pmnt_amt;
             IF (scheduled_prin_pmnt_amt_csr%NOTFOUND) THEN
                l_scheduled_prin_pmnt_amt := 0;
             END IF;
             CLOSE  scheduled_prin_pmnt_amt_csr;
             l_invoice_amt := l_interest_calculated + l_scheduled_prin_pmnt_amt;
          ELSE
             l_invoice_amt := l_interest_calculated;
          END IF;
       END IF;

    ELSIF (p_deal_type = 'LOAN-REVOLVING') THEN  -- 'Revolving Loan'
       IF (p_principal_basis = 'ACTUAL') THEN
          IF (p_rev_rec_method = 'ACTUAL') THEN
             OPEN  loan_payment_amount_csr (p_contract_id, p_due_date, 'VARIABLE_LOAN_PAYMENT');
             FETCH loan_payment_amount_csr INTO l_total_loan_pmt;
             IF (loan_payment_amount_csr%NOTFOUND) THEN
                l_total_loan_pmt := 0;
             END IF;
             CLOSE loan_payment_amount_csr;

             l_invoice_amt := l_interest_calculated - l_total_loan_pmt;

          ELSE
             OPEN  loan_payment_amount_csr (p_contract_id, p_due_date, 'VARIABLE_INTEREST');
             FETCH loan_payment_amount_csr INTO l_interest_paid;
             IF (loan_payment_amount_csr%NOTFOUND) THEN
                l_interest_paid := 0;
             END IF;
             CLOSE loan_payment_amount_csr;

             l_invoice_amt := l_interest_calculated - l_interest_paid;

          END IF;
       END IF;
    END IF;

    IF (p_rev_rec_method = 'ACTUAL') THEN
       l_stream_type_purpose := 'VARIABLE_LOAN_PAYMENT';
    ELSE
       l_stream_type_purpose := 'VARIABLE_INTEREST';
    END IF;

    Create_Stream_Invoice (
                           p_api_version            => 1.0,
                           p_init_msg_list          => OKL_API.G_FALSE,
                           x_return_status          => x_return_status,
                           x_msg_count              => x_msg_count,
                           x_msg_data               => x_msg_data,
                           p_contract_id            => p_contract_id,
                           p_line_id                => NULL,
                           p_amount                 => l_invoice_amt,
                           p_due_date               => p_due_date,
                           p_stream_type_purpose    => l_stream_type_purpose,
                           p_create_invoice_flag    => OKL_API.G_TRUE,
                           p_parent_strm_element_id => NULL,
						   x_invoice_id             => l_invoice_id,
						   x_stream_element_id      => l_stream_element_id);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    i_vir_tbl := g_vir_tbl;

    upd_vir_params_with_invoice (
            p_api_version   => 1.0,
            p_init_msg_list => OKL_API.G_TRUE,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_source_id     => l_invoice_id,
            p_vir_tbl      => i_vir_tbl,
            x_vir_tbl      => r_vir_tbl);
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    g_vir_tbl := r_vir_tbl;

    populate_vir_params(
             p_api_version    => 1.0,
             p_init_msg_list  => OKL_API.G_TRUE,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_vir_tbl        => g_vir_tbl);
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      print_error_message('Unexpected error raised in call to POPULATE_VIR_PARAMS');
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      print_error_message('Error raised in call to POPULATE_VIR_PARAMS');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

  EXCEPTION
    WHEN OTHERS  THEN
      print_debug ('exception raised in variable_interest_float');
      Okl_Api.SET_MESSAGE(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_ERROR;

  END variable_interest_float_old;
------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    variable_interest_float
    -- Description:      This procedure is called by Variable Interest Calculation for Loans / Revolving Loans
    --                   Inputs :
    --                   Output :
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------

  PROCEDURE variable_interest_float(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_contract_id     IN  NUMBER,
            p_principal_basis IN  VARCHAR2,
            p_rev_rec_method  IN  VARCHAR2,
            p_deal_type       IN  VARCHAR2,
            p_currency_code   IN  VARCHAR2,
            p_start_date      IN  DATE,
            p_due_date        IN  DATE) IS

    l_api_version             CONSTANT NUMBER := 1.0;
    l_api_name	              CONSTANT VARCHAR2(30) := 'VARIABLE_INTEREST_FLOAT';
    l_return_status	          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_index_out           NUMBER;
    l_principal_balance       NUMBER := 0;
    l_interest_calculated     NUMBER := 0;
    r_principal_balance_tbl   principal_balance_tbl_typ;
    l_total_loan_pmt          NUMBER := 0;
    l_total_principal_pmt     NUMBER := 0;
    l_scheduled_prin_pmnt_amt NUMBER := 0;
    l_invoice_id              NUMBER;
    l_invoice_amt             NUMBER := 0;
    l_interest_paid           NUMBER := 0;
    l_stream_type_purpose     OKL_STRM_TYPE_V.stream_type_purpose%TYPE;
    i_vir_tbl                 vir_tbl_type;
    r_vir_tbl                 vir_tbl_type;
    l_stream_element_id       OKL_STRM_ELEMENTS_v.id%TYPE;
    l_kle_id                  OKL_K_LINES.id%TYPE;
    l_strm_element_date       OKL_STRM_ELEMENTS.stream_element_date%TYPE;
    l_parent_strm_element_id  OKL_STRM_ELEMENTS.id%TYPE;
    var_int_float_failed      EXCEPTION;

    CURSOR loan_payment_amount_csr (cp_khr_id NUMBER, cp_start_date DATE, cp_due_date DATE, cp_stream_type_purpose VARCHAR2) IS
       SELECT nvl(SUM(nvl(sel_prin_pmt.amount, 0)),0) pmt_amt
       FROM  okl_strm_type_v sty_prin_pmt,
             okl_streams_v stm_prin_pmt,
             okl_strm_elements_v sel_prin_pmt
       WHERE stm_prin_pmt.khr_id = cp_khr_id
       AND   stm_prin_pmt.id = sel_prin_pmt.stm_id
       AND   sel_prin_pmt.stream_element_date BETWEEN cp_start_date AND  cp_due_date
       AND   stm_prin_pmt.sty_id = sty_prin_pmt.id
       AND   stm_prin_pmt.active_yn = 'Y'
       AND   stm_prin_pmt.say_code = 'CURR'
       AND   sty_prin_pmt.stream_type_purpose = cp_stream_type_purpose ; -- 'PRINCIPAL_PAYMENT'

    -- Derive the interest billed for previous billing periods
    CURSOR Interest_payment_amount_csr (cp_khr_id NUMBER, cp_start_date DATE, cp_due_date DATE) IS
       SELECT nvl(SUM(nvl(sel_prin_pmt.amount, 0)),0) pmt_amt
       FROM  okl_strm_type_v sty_prin_pmt,
             okl_streams_v stm_prin_pmt,
             okl_strm_elements_v sel_prin_pmt
       WHERE stm_prin_pmt.khr_id = cp_khr_id
       AND   stm_prin_pmt.id = sel_prin_pmt.stm_id
       AND   sel_prin_pmt.stream_element_date BETWEEN cp_start_date AND  cp_due_date
       AND   stm_prin_pmt.sty_id = sty_prin_pmt.id
       AND   stm_prin_pmt.active_yn = 'Y'
       AND   stm_prin_pmt.say_code = 'CURR'
       AND   sel_prin_pmt.sel_id  IS NULL
       AND   sty_prin_pmt.stream_type_purpose = 'VARIABLE_LOAN_PAYMENT';

    CURSOR contract_line_csr (cp_khr_id NUMBER, cp_due_date DATE) IS
       SELECT id
	   FROM   okl_k_lines_full_v
	   WHERE  chr_id = cp_khr_id
	   AND    lse_id = G_FIN_LINE_LTY_ID
	   AND    nvl(date_terminated, cp_due_date + 1) > cp_due_date
	   ORDER BY id;

    CURSOR Principal_payment_streams_csr (cp_khr_id NUMBER, cp_kle_id NUMBER, cp_due_date DATE) IS
       SELECT sel.id,
	          sel.stream_element_date,
              sel.amount
	   FROM   okl_strm_type_v sty,
	          okl_streams str,
	          okl_strm_elements sel
	   WHERE  sel.stm_id = str.id
	   AND    str.khr_id = cp_khr_id
	   AND    str.kle_id = cp_kle_id
       AND    str.say_code = 'CURR'
       AND    str.active_yn = 'Y'
	   AND    sel.stream_element_date <= cp_due_date
	   AND    str.sty_id = sty.id
	   AND    sty.stream_type_purpose = 'PRINCIPAL_PAYMENT'
	   AND    NOT EXISTS (
	                       SELECT 'X'
	                       FROM   okl_strm_elements selc
	                       WHERE  selc.sel_id = sel.id)
	   ORDER BY stream_element_date;


    CURSOR scheduled_prin_pmnt_amt_csr (cp_khr_id NUMBER, cp_due_date DATE, cp_stream_type_purpose VARCHAR2) IS
       SELECT nvl(SUM(nvl(sel_prin_pmt.amount, 0)),0) pmt_amt
       FROM  okl_strm_type_v sty_prin_pmt,
             okl_streams_v stm_prin_pmt,
             okl_strm_elements_v sel_prin_pmt
       WHERE stm_prin_pmt.khr_id = cp_khr_id
       AND   stm_prin_pmt.id = sel_prin_pmt.stm_id
       AND   sel_prin_pmt.stream_element_date = cp_due_date
       AND   stm_prin_pmt.sty_id = sty_prin_pmt.id
       AND   stm_prin_pmt.active_yn = 'Y'
       AND   stm_prin_pmt.say_code = 'CURR'
       AND   sty_prin_pmt.stream_type_purpose = cp_stream_type_purpose ; -- 'PRINCIPAL_PAYMENT'

  BEGIN
    ------------------------------------------------------------
    -- Start processing
    ------------------------------------------------------------

    print_debug('Executing procedure VARIABLE_INTEREST_FLOAT using the foll. parameters:');
    print_debug('contract ID:                 '|| p_contract_id);
  	print_Debug('Principal Basis:             '|| p_principal_basis);
  	print_debug('Revenue Recognition Method:  '|| p_rev_rec_method);
  	print_debug('Deal Type:                   '|| p_deal_type);
  	Print_debug('Currency Code:               '|| p_currency_code);
  	print_debug('Start Date:                  '|| p_start_date);
  	print_debug('Due Date:                    '|| p_due_date);

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    g_vir_tbl.delete;
 	  g_vir_tbl_counter := 0;
    g_vpb_tbl.delete;
 	  g_vpb_tbl_counter := 0;

    populate_txns ( p_api_version => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                p_khr_id  => p_contract_id,
                p_from_date => p_start_date,
                p_to_date  => p_due_date,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data);

   IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
     print_error_message('Unexpected error raised in call to POPULATE_TXNS');
     RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
     print_error_message('Error raised in call to POPULATE_TXNS');
     RAISE var_int_float_failed;
   END IF;

    l_interest_calculated :=  calculate_total_interest_due(
                                        p_api_version     => 1.0,
                                        p_init_msg_list   => OKL_API.G_FALSE,
                                        x_return_status   => x_return_status,
                                        x_msg_count       => x_msg_count,
                                        x_msg_data        => x_msg_data,
                                        p_contract_id     => p_contract_id,
                                        p_currency_code   => p_currency_code,
                                        p_start_date      => p_start_date,
                                        p_due_date        => p_due_date);
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         print_error_message('Unexpected error raised in call to CALCULATE_TOTAL_INTEREST_DUE');
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         print_error_message('Error raised in call to CALCULATE_TOTAL_INTEREST_DUE');
         RAISE var_int_float_failed;
       END IF;

       l_total_loan_pmt          := 0;
       l_total_principal_pmt     := 0;
       l_interest_paid           := 0;
       l_scheduled_prin_pmnt_amt := 0;

    IF (p_deal_type = 'LOAN') THEN
       IF (p_principal_basis = 'ACTUAL') THEN
          IF (p_rev_rec_method = 'ACTUAL') THEN
             OPEN  interest_payment_amount_csr (p_contract_id, p_start_date, p_due_date);
             FETCH interest_payment_amount_csr INTO l_interest_paid;
             IF (interest_payment_amount_csr%NOTFOUND) THEN
                l_interest_paid := 0;
             END IF;

             CLOSE interest_payment_amount_csr;

             Print_debug ('Total Interest Payment = '|| l_interest_paid);

             l_invoice_amt := l_interest_calculated - l_interest_paid;

          ELSE  /* Estimated and Billed */
             OPEN  loan_payment_amount_csr (p_contract_id, p_start_date, p_due_date, 'VARIABLE_INTEREST');
             FETCH loan_payment_amount_csr INTO l_interest_paid;
             IF (loan_payment_amount_csr%NOTFOUND) THEN
                l_interest_paid := 0;
             END IF;
             CLOSE loan_payment_amount_csr;

             Print_debug ('Total Interest Payment = '|| l_interest_paid);

             l_invoice_amt := l_interest_calculated - l_interest_paid;

          END IF;
       ELSIF (p_principal_basis = 'SCHEDULED') THEN
/*          IF (p_rev_rec_method = 'ACTUAL') THEN  -- not applicable
             OPEN   scheduled_prin_pmnt_amt_csr(p_contract_id, p_due_date, 'PRINCIPAL_PAYMENT');
             FETCH  scheduled_prin_pmnt_amt_csr INTO l_scheduled_prin_pmnt_amt;
             IF (scheduled_prin_pmnt_amt_csr%NOTFOUND) THEN
                l_scheduled_prin_pmnt_amt := 0;
             END IF;
             CLOSE  scheduled_prin_pmnt_amt_csr;
             l_invoice_amt := l_interest_calculated + l_scheduled_prin_pmnt_amt;
          ELSE */
             l_invoice_amt := l_interest_calculated;
--          END IF;
       END IF;

    ELSIF (p_deal_type = 'LOAN-REVOLVING') THEN  -- 'Revolving Loan'
       IF (p_principal_basis = 'ACTUAL') THEN
          IF (p_rev_rec_method = 'ACTUAL') THEN
             OPEN  loan_payment_amount_csr (p_contract_id, p_start_date, p_due_date, 'VARIABLE_LOAN_PAYMENT');
             FETCH loan_payment_amount_csr INTO l_total_loan_pmt;
             IF (loan_payment_amount_csr%NOTFOUND) THEN
                l_total_loan_pmt := 0;
             END IF;
             CLOSE loan_payment_amount_csr;

             l_invoice_amt := l_interest_calculated - l_total_loan_pmt;

          ELSE
             OPEN  loan_payment_amount_csr (p_contract_id, p_start_date, p_due_date, 'VARIABLE_INTEREST');
             FETCH loan_payment_amount_csr INTO l_interest_paid;
             IF (loan_payment_amount_csr%NOTFOUND) THEN
                l_interest_paid := 0;
             END IF;
             CLOSE loan_payment_amount_csr;

             l_invoice_amt := l_interest_calculated - l_interest_paid;

          END IF;
       END IF;
    END IF;

    --sechawla : print the invoice amount
    Print_debug ('Invoice Amount : '|| l_invoice_amt);

    IF (p_rev_rec_method = 'ACTUAL') THEN
       l_stream_type_purpose := 'VARIABLE_LOAN_PAYMENT';
    ELSE
       l_stream_type_purpose := 'VARIABLE_INTEREST';
    END IF;

    IF (l_invoice_amt <> 0) THEN --sechawla : added this condition
       Create_Stream_Invoice (
                           p_api_version            => 1.0,
                           p_init_msg_list          => p_init_msg_list,
                           x_return_status          => x_return_status,
                           x_msg_count              => x_msg_count,
                           x_msg_data               => x_msg_data,
                           p_contract_id            => p_contract_id,
                           p_line_id                => NULL,
                           p_amount                 => l_invoice_amt,
                           p_due_date               => p_due_date,
                           p_stream_type_purpose    => l_stream_type_purpose,
                           p_create_invoice_flag    => OKL_API.G_TRUE,
                           p_parent_strm_element_id => NULL,
						   x_invoice_id             => l_invoice_id,
						   x_stream_element_id      => l_stream_element_id);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        print_error_message('Unexpected error raised in call to CREATE_STREAM_INVOICE');
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        print_error_message('Error raised in call to CREATE_STREAM_INVOICE');
        RAISE var_int_float_failed;
      END IF;
     i_vir_tbl := g_vir_tbl;

      --checkwhat does it do
      upd_vir_params_with_invoice (
            p_api_version   => 1.0,
            p_init_msg_list => OKL_API.G_TRUE,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_source_id     => l_invoice_id,
            p_vir_tbl      => i_vir_tbl,
            x_vir_tbl      => r_vir_tbl);
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        print_error_message('Unexpected error raised in call to UPD_VIR_PARAMS_WITH_INVOICE');
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        print_error_message('Error raised in call to UPD_VIR_PARAMS_WITH_INVOICE');
        RAISE var_int_float_failed;
      END IF;

      g_vir_tbl := r_vir_tbl;

      populate_vir_params(
              p_api_version    => 1.0,
             p_init_msg_list  => OKL_API.G_TRUE,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_vir_tbl        => g_vir_tbl);
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        print_error_message('Unexpected error raised in call to POPULATE_VIR_PARAMS');
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        print_error_message('Error raised in call to POPULATE_VIR_PARAMS');
        RAISE var_int_float_failed;
      END IF;

      populate_principal_bal_txn(
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_vpb_tbl        => g_vpb_tbl);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        print_error_message('Unexpected error raised in call to POPULATE_PRINCIPAL_BAL_TXN');
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        print_error_message('Error raised in call to POPULATE_PRINCIPAL_BAL_TXN');
        RAISE var_int_float_failed;
      END IF;

      g_vpb_tbl.delete;
 	  g_vpb_tbl_counter := 0;

    END IF; --sechawla

    --4731205
    IF (p_deal_type = 'LOAN' AND
        p_principal_basis = 'ACTUAL' AND
        p_rev_rec_method = 'ACTUAL') THEN
      FOR current_line in contract_line_csr(p_contract_id, p_due_date)
      LOOP
        l_kle_id := current_line.id;
        FOR current_stream_element in principal_payment_streams_csr (p_contract_id, l_kle_id, p_due_date)
    		LOOP
    		  l_stream_type_purpose    := 'VARIABLE_LOAN_PAYMENT';
    		  l_invoice_amt            := current_stream_element.amount;

    		  l_strm_element_date      := current_stream_element.stream_element_date;
    		  l_parent_strm_element_id := current_stream_element.id;

    		  --sechawla : print the invoice amount
              Print_debug ('Invoice Amount : '|| l_invoice_amt);

    		  IF (l_invoice_amt <> 0 )THEN --sechawla : added

                Create_Stream_Invoice (
                            p_api_version            => 1.0,
                            p_init_msg_list          => p_init_msg_list,
                            x_return_status          => x_return_status,
                            x_msg_count              => x_msg_count,
                            x_msg_data               => x_msg_data,
                            p_contract_id            => p_contract_id,
                            p_line_id                => l_kle_id,
                            p_amount                 => l_invoice_amt,
                            p_due_date               => l_strm_element_date,
                            p_stream_type_purpose    => l_stream_type_purpose,
                            p_create_invoice_flag    => OKL_API.G_TRUE,
                            p_parent_strm_element_id => l_parent_strm_element_id,
    	   			        x_invoice_id             => l_invoice_id,
    						x_stream_element_id      => l_stream_element_id);
                IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  print_error_message('Unexpected error raised in call to CREATE_STREAM_INVOICE');
                  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                  print_error_message('Error raised in call to CREATE_STREAM_INVOICE');
                  RAISE var_int_float_failed;
                END IF;

              END IF;  --sechawla
    		END LOOP;
      END LOOP;
    END IF;

  EXCEPTION
    WHEN var_int_float_failed THEN
      print_error_message ('Exception var_int_float_failed raised in procedure VARIABLE_INTEREST_FLOAT');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS  THEN
      print_error_message ('Exception raised in procedure VARIABLE_INTEREST_FLOAT');
      Okl_Api.SET_MESSAGE(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_ERROR;

  END variable_interest_float;
------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    variable_interest_float_factor
    -- Description:      This procedure is used to derive the interest and generate streams and invoice for
    --                   contracts with interest calculation basis of FLOAT FACTOR
    --                   Inputs :
    --                   Output :
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------
  PROCEDURE variable_interest_float_factor(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_contract_id     IN  NUMBER,
            p_from_date      IN  DATE,
            p_to_date        IN  DATE) IS

    l_api_version               CONSTANT NUMBER := 1.0;
    l_api_name	                CONSTANT VARCHAR2(30) := 'VARIABLE_INTEREST_FLOAT_FACTOR';
    l_return_status	            VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_stream_type_purpose       OKL_STRM_TYPE_V.stream_type_purpose%TYPE;
    l_invoice_amt               NUMBER := 0;
    l_formula_id                OKL_FORMULAE_V.id%TYPE;
    l_formula_name              OKL_FORMULAE_V.name%TYPE;
    l_line_id                   OKC_K_LINES_B.id%TYPE;
    l_stream_element_date       DATE;
    l_invoice_id                NUMBER;
    l_stream_element_id         OKL_STRM_ELEMENTS_V.id%TYPE;
    var_int_float_factor_failed EXCEPTION;

  Cursor formula_name_csr (p_formula_id NUMBER) IS
      SELECT fml.name
      FROM   okl_formulae_v fml
      WHERE  fml.id = p_formula_id;

  Cursor asset_billed_streams_csr (p_contract_id NUMBER, p_from_date DATE, p_to_date DATE) IS
      SELECT chrb.id contract_id, cleb.id kle_id,
             selb.stream_element_date, selb.amount amount
      FROM  okc_k_headers_b chrb, okc_k_lines_b cleb,
	        okc_line_styles_b lseb, okl_strm_type_b styb,
            okl_strm_elements selb, okl_streams stmb
      WHERE cleb.dnz_chr_id = chrb.id
      AND   cleb.chr_id = chrb.id
      AND   chrb.id = p_contract_id
      AND   cleb.lse_id = lseb.id
      AND   lseb.lty_code = 'FREE_FORM1'
      AND   stmb.khr_id = chrb.id
      AND   stmb.kle_id = cleb.id
      AND   stmb.sty_id = styb.id
      AND   selb.stm_id = stmb.id
      AND   chrb.id = stmb.khr_id
      AND   stmb.say_code = 'CURR'
      AND   stmb.active_yn = 'Y'
      AND   styb.stream_type_purpose = 'RENT'
      --fix for bug # 4940113
      --AND   selb.date_billed IS NOT NULL
      --change on 15 Nov 2005 by pgomes for bug fix 4740293
	    --AND   selb.stream_element_date BETWEEN p_from_date AND NVL(p_to_date,SYSDATE);
	  AND   (selb.stream_element_date > p_from_date AND  selb.stream_element_date <= NVL(p_to_date,trunc(SYSDATE)))
	  ORDER BY selb.stream_element_date, cleb.id; -- 4904798

  BEGIN
    ------------------------------------------------------------
    -- Start processing
    ------------------------------------------------------------

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    print_debug('Executing procedure VARIABLE_INTEREST_FLOAT_FACTOR using following parameters : ');
    print_debug('contract ID : '|| p_contract_id);
    print_debug('g_contract_id : '|| G_CONTRACT_ID);
	print_debug('From date : '|| p_from_date);
	print_Debug('To date : '|| p_to_date);

    print_debug ('G_CALCULATION_FORMULA_ID : '|| G_CALCULATION_FORMULA_ID);

    OPEN  formula_name_csr (G_CALCULATION_FORMULA_ID);
    FETCH formula_name_csr INTO l_formula_name;
    IF (formula_name_csr%NOTFOUND) THEN
       CLOSE formula_name_csr;
       Print_Debug( 'Unable to find formula for formula id :' || G_CALCULATION_FORMULA_ID);
       print_error_message('Interest Params cursor did not return any records for formula ID: '|| G_CALCULATION_FORMULA_ID);
       RAISE var_int_float_factor_failed;
    END IF;
    CLOSE formula_name_csr;

    Print_Debug( 'Formula Name : '|| l_formula_name);

    FOR current_stream IN asset_billed_streams_csr (p_contract_id, p_from_date, p_to_date)
    LOOP
       l_line_id     := current_stream.kle_id;
       l_invoice_amt := 0;
       l_stream_element_date := current_stream.stream_element_date;

       Print_debug( 'line id : '|| l_line_id);
       Print_debug('Stream Element Date: '|| l_stream_element_date);

       Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(1).NAME  := 'DUE_DATE';
       Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(1).VALUE := l_stream_element_date;

       -- Apply FLoat factor formula
       Okl_Execute_Formula_Pub.EXECUTE(
	       p_api_version          => 1.0,
           p_init_msg_list        => OKL_API.G_TRUE,
           x_return_status        => x_return_status,
           x_msg_count            => x_msg_count,
           x_msg_data             => x_msg_data,
           p_formula_name         => l_formula_name,
           p_contract_id          => p_contract_id,
           p_line_id              => l_line_id,
           x_value                => l_invoice_amt
        );

       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         print_error_message('Unexpected error raised in call to OKL_EXECUTE_FORMULA_PUB.EXECUTE');
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         print_error_message('Error raised in call to OKL_EXECUTE_FORMULA_PUB.EXECUTE');
         RAISE var_int_float_factor_failed;
       END IF;

       Print_debug ('Formula executed successfully');
       Print_debug (' Invoice Amount : '|| l_invoice_amt);

       l_stream_type_purpose := 'FLOAT_FACTOR_ADJUSTMENT';

       IF (l_invoice_amt <> 0) THEN
         Create_Stream_Invoice (
                p_api_version            => 1.0,
                p_init_msg_list          => p_init_msg_list,
                x_return_status          => x_return_status,
                x_msg_count              => x_msg_count,
                x_msg_data               => x_msg_data,
                p_contract_id            => p_contract_id,
                p_line_id                => l_line_id,
                p_amount                 => l_invoice_amt,
                p_due_date               => l_stream_element_date,
                p_stream_type_purpose    => l_stream_type_purpose,
                p_create_invoice_flag    => OKL_API.G_TRUE,
                p_parent_strm_element_id => NULL,
				x_invoice_id             => l_invoice_id,
			    x_stream_element_id      => l_stream_element_id);
         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           print_error_message('Unexpected error raised in call to CREATE_STREAM_INVOICE');
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           print_error_message('Error raised in call to CREATE_STREAM_INVOICE');
           RAISE var_int_float_factor_failed;
         END IF;
       END IF;

       UPDATE okl_k_headers
       SET    date_last_interim_interest_cal = l_stream_element_date
       WHERE  id = p_contract_id;

       COMMIT;

    END LOOP;

  EXCEPTION
    WHEN var_int_float_factor_failed THEN
      print_error_message('Exception var_int_float_factor_failed raised in procedure VARIABLE_INTEREST_FLOAT_FACTOR');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS  THEN
      print_error_message('Exception raised in procedure VARIABLE_INTEREST_FLOAT_FACTOR');
      Okl_Api.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => SQLCODE,
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_ERROR;

  END variable_interest_float_factor;
------------------------------------------------------------------------------
  FUNCTION get_next_catchup_date(p_khr_id IN NUMBER) RETURN DATE IS

    CURSOR c_khr_params(cp_khr_id IN NUMBER) IS
    select khr.date_last_interim_interest_cal date_last_interim_interest_cal
    , NVL(rpm.catchup_start_date, khr.start_date) catchup_start_date
    , NVL(rpm.catchup_frequency_code, 'MONTHLY') catchup_frequency_code
    , NVL(khr.date_terminated, khr.end_date) end_date
    from okl_k_headers_full_v khr
    , okl_k_rate_params rpm
    where khr.id = rpm.khr_id
    and khr.id = cp_khr_id;

    l_next_catchup_date DATE;
    l_mnth_adder NUMBER := 0;
    l_last_int_cal_date DATE;
    l_catchup_start_date DATE;
    l_catchup_frequency VARCHAR2(50);
    l_end_date DATE;
  BEGIN
    FOR cur_khr_params IN c_khr_params(p_khr_id) LOOP
      l_last_int_cal_date := cur_khr_params.date_last_interim_interest_cal;
      l_catchup_start_date := cur_khr_params.catchup_start_date;
      l_catchup_frequency := cur_khr_params.catchup_frequency_code;
      l_end_date := cur_khr_params.end_date;
      EXIT;
    END LOOP;

    if(UPPER(l_catchup_frequency) = 'ANNUAL') then
      l_mnth_adder := 12;
    elsif(UPPER(l_catchup_frequency) = 'SEMI_ANNUAL') then
      l_mnth_adder := 6;
    elsif(UPPER(l_catchup_frequency) = 'QUARTERLY') then
      l_mnth_adder := 3;
    elsif(UPPER(l_catchup_frequency) = 'MONTHLY') then
      l_mnth_adder := 1;
    else
      return null;
    end if;

    l_next_catchup_date := l_catchup_start_date;
    loop
      exit when l_next_catchup_date > NVL(l_last_int_cal_date, l_next_catchup_date - 1);
      --select add_months(l_next_date, l_mnth_adder) INTO l_next_date from dual;
      l_next_catchup_date := add_months(l_next_catchup_date, l_mnth_adder);
    end loop;

    --if next catchup date exceeds the contract end date
    if (l_next_catchup_date > l_end_date) then
      l_next_catchup_date := l_end_date;
    end if;

    return l_next_catchup_date;
  EXCEPTION
   	WHEN OTHERS THEN
    return l_next_catchup_date;
  END get_next_catchup_date;

  ------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ramesh Seela
    -- Procedure Name    variable_interest_catchup
    -- Description:      This procedure is called by Variable Interest Calculation for Loans / Revolving Loans
    --                   Inputs :
    --                   Output :
    -- Dependencies:
    -- Parameters:
    -- Version:          1.0
    -- End of Comments

  ------------------------------------------------------------------------------

  PROCEDURE variable_interest_catchup(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_contract_id     IN  NUMBER,
            p_principal_basis IN  VARCHAR2,
            p_rev_rec_method  IN  VARCHAR2,
            p_deal_type       IN  VARCHAR2,
            p_currency_code   IN  VARCHAR2,
            p_start_date      IN  DATE,
            p_due_date        IN  DATE) IS

    l_api_version             CONSTANT NUMBER := 1.0;
    l_api_name	              CONSTANT VARCHAR2(30) := 'VARIABLE_INTEREST_CATCHUP';
    l_return_status	          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_index_out           NUMBER;
    l_interest_calculated     NUMBER := 0;
    l_total_interest_billed   NUMBER := 0;
    l_principal_adjusted      NUMBER := 0;
--    l_catchup_settlement_code OKL_K_RATE_PARAMS.catchup_settlement_code%TYPE;
    l_invoice_amt             NUMBER := 0;
    l_stream_type_purpose     OKL_STRM_TYPE_V.stream_type_purpose%TYPE;
    l_invoice_id              NUMBER;
    l_principal_balance_tbl   principal_balance_tbl_typ;
    l_total_asset_val         NUMBER := 0;
    l_principal_balance       NUMBER := 0;
    l_asset_line_tbl          okl_kle_pvt.kle_tbl_type;
    l_line_index              NUMBER := 0;
    l_index                   NUMBER := 0;
    l_asset_line_tbl_count    NUMBER := 0;
    l_prorated_invoice_amt    NUMBER := 0;
    i_vir_tbl                 vir_tbl_type;
    r_vir_tbl                 vir_tbl_type;
    l_stream_element_id       OKL_STRM_ELEMENTS_V.id%TYPE;
    var_int_catchup_failed    EXCEPTION;

    CURSOR interest_payment_amount_csr (cp_khr_id NUMBER, cp_start_date DATE, cp_due_date DATE) IS
       SELECT nvl(SUM(nvl(sel_prin_pmt.amount, 0)),0) pmt_amt
       FROM  okl_strm_type_v sty_prin_pmt,
             okl_streams_v stm_prin_pmt,
             okl_strm_elements_v sel_prin_pmt
       WHERE stm_prin_pmt.khr_id = cp_khr_id
       AND   stm_prin_pmt.id = sel_prin_pmt.stm_id
       AND   sel_prin_pmt.stream_element_date BETWEEN cp_start_date AND cp_due_date
       AND   stm_prin_pmt.sty_id = sty_prin_pmt.id
       AND   stm_prin_pmt.active_yn = 'Y'
       AND   stm_prin_pmt.say_code = 'CURR'
       AND   sty_prin_pmt.stream_type_purpose in ('INTEREST_CATCHUP', 'INTEREST_PAYMENT') ; -- 'PRINCIPAL_PAYMENT'

    CURSOR int_pay_amt_end_date_csr (cp_khr_id NUMBER, cp_start_date DATE) IS
       SELECT nvl(SUM(nvl(sel_prin_pmt.amount, 0)),0) pmt_amt
       FROM  okl_strm_type_v sty_prin_pmt,
             okl_streams_v stm_prin_pmt,
             okl_strm_elements_v sel_prin_pmt
       WHERE stm_prin_pmt.khr_id = cp_khr_id
       AND   stm_prin_pmt.id = sel_prin_pmt.stm_id
       AND   sel_prin_pmt.stream_element_date >= cp_start_date
       AND   stm_prin_pmt.sty_id = sty_prin_pmt.id
       AND   stm_prin_pmt.active_yn = 'Y'
       AND   stm_prin_pmt.say_code = 'CURR'
       AND   sty_prin_pmt.stream_type_purpose in ('INTEREST_CATCHUP', 'INTEREST_PAYMENT') ; -- 'PRINCIPAL_PAYMENT'

    CURSOR principal_adjustment_csr (cp_khr_id NUMBER, cp_start_date DATE, cp_due_date DATE) IS
       SELECT nvl(SUM(nvl(sel_prin_pmt.amount, 0)),0) pmt_amt
       FROM  okl_strm_type_v sty_prin_pmt,
             okl_streams_v stm_prin_pmt,
             okl_strm_elements_v sel_prin_pmt
       WHERE stm_prin_pmt.khr_id = cp_khr_id
       AND   stm_prin_pmt.id = sel_prin_pmt.stm_id
       AND   sel_prin_pmt.stream_element_date BETWEEN cp_start_date AND cp_due_date
       AND   stm_prin_pmt.sty_id = sty_prin_pmt.id
       AND   stm_prin_pmt.active_yn = 'Y'
       AND   stm_prin_pmt.say_code = 'CURR'
       AND   sty_prin_pmt.stream_type_purpose = 'PRINCIPAL_CATCHUP' ;

/*
    CURSOR catchup_params_csr (p_khr_id NUMBER, p_effective_date DATE) IS
       SELECT catchup_settlement_code
       FROM   okl_k_rate_params
       WHERE  khr_id = p_khr_id
       AND    p_effective_date BETWEEN effective_from_date and nvl(effective_to_date, p_effective_date)
       AND    parameter_type_code = 'ACTUAL';
*/
    CURSOR contract_line_csr (p_khr_id NUMBER) IS
       SELECT id
	   FROM   okl_k_lines_full_v
	   WHERE  chr_id = p_khr_id
	   AND    lse_id = G_FIN_LINE_LTY_ID
	   ORDER BY id;
  BEGIN
    ------------------------------------------------------------
    -- Start processing
    ------------------------------------------------------------

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

  print_debug('Executing procedure VARIABLE_INTEREST_CATCHUP using following parameters : ');
  print_debug('contract ID:                 '|| p_contract_id);
	print_Debug('Principal Basis:             '|| p_principal_basis);
	print_debug('Revenue Recognition Method:  '|| p_rev_rec_method);
	print_debug('Deal Type:                   '|| p_deal_type);
	Print_debug('Currency Code:               '|| p_currency_code);
	print_debug('Start Date:                  '|| p_start_date);
	print_debug('Due Date:                    '|| p_due_date);

  g_vir_tbl.delete;
	g_vir_tbl_counter := 0;
  g_vpb_tbl.delete;
  g_vpb_tbl_counter := 0;

  populate_txns ( p_api_version => p_api_version,
              p_init_msg_list  => p_init_msg_list,
              p_khr_id  => p_contract_id,
              p_from_date => p_start_date,
              p_to_date  => p_due_date,
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data);

  IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
   print_error_message('Unexpected error raised in call to POPULATE_TXNS');
   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
   print_error_message('Error raised in call to POPULATE_TXNS');
   RAISE var_int_catchup_failed;
  END IF;

  l_interest_calculated :=  calculate_total_interest_due(
                                        p_api_version     => 1.0,
                                        p_init_msg_list   => OKL_API.G_FALSE,
                                        x_return_status   => x_return_status,
                                        x_msg_count       => x_msg_count,
                                        x_msg_data        => x_msg_data,
                                        p_contract_id     => p_contract_id,
                                        p_currency_code   => p_currency_code,
                                        p_start_date      => p_start_date,
                                        p_due_date        => p_due_date);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      print_error_message('Unexpected error raised in call to CALCULATE_TOTAL_INTEREST_DUE');
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      print_error_message('Error raised in call to CALCULATE_TOTAL_INTEREST_DUE');
      RAISE var_int_catchup_failed;
    END IF;

  	print_debug('Interest Calculated : ' || l_interest_calculated);
    l_total_interest_billed      := 0;

    IF (p_deal_type = 'LOAN') THEN
       IF (p_principal_basis = 'ACTUAL') THEN
          IF (p_rev_rec_method = 'STREAMS') THEN
             --fix for bug 5072399
             IF (p_due_date = G_CONTRACT_END_DATE) THEN
               OPEN  int_pay_amt_end_date_csr (p_contract_id, p_start_date);
               FETCH int_pay_amt_end_date_csr INTO l_total_interest_billed;
               IF (int_pay_amt_end_date_csr % NOTFOUND) THEN
                  l_total_interest_billed := 0;
               END IF;
               CLOSE int_pay_amt_end_date_csr;
             ELSE
               OPEN  interest_payment_amount_csr (p_contract_id, p_start_date, p_due_date);
               FETCH interest_payment_amount_csr INTO l_total_interest_billed;
               IF (interest_payment_amount_csr % NOTFOUND) THEN
                  l_total_interest_billed := 0;
               END IF;
               CLOSE interest_payment_amount_csr;
             END IF;

             print_debug('Interest Billed : ' || l_total_interest_billed);
             l_invoice_amt := OKL_ACCOUNTING_UTIL.round_amount(l_interest_calculated - l_total_interest_billed, p_currency_code);

             Print_debug ('Invoice Amount : '|| l_invoice_amt);


             IF (l_invoice_amt > 0) THEN
                l_stream_type_purpose := 'INTEREST_CATCHUP';
                Create_Stream_Invoice (
                       p_api_version         => 1.0,
                       p_init_msg_list       => p_init_msg_list,
                       x_return_status       => x_return_status,
                       x_msg_count           => x_msg_count,
                       x_msg_data            => x_msg_data,
                       p_contract_id         => p_contract_id,
                       p_line_id             => NULL,
                       p_amount              => l_invoice_amt,
                       p_due_date            => p_due_date,
                       p_stream_type_purpose => l_stream_type_purpose,
                       p_create_invoice_flag => OKL_API.G_TRUE,
                       p_parent_strm_element_id => NULL,
					   x_invoice_id          => l_invoice_id,
					   x_stream_element_id   => l_stream_element_id);
                IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  print_error_message('Unexpected error raised in call to CREATE_STREAM_INVOICE');
                  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                  print_error_message('Error raised in call to CREATE_STREAM_INVOICE');
                  RAISE var_int_catchup_failed;
                END IF;

                i_vir_tbl := g_vir_tbl;

                upd_vir_params_with_invoice (
                    p_api_version   => 1.0,
                    p_init_msg_list => OKL_API.G_TRUE,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data,
                    p_source_id     => l_invoice_id,
                    p_vir_tbl      => i_vir_tbl,
                    x_vir_tbl      => r_vir_tbl);
                IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  print_error_message('Unexpected error raised in call to UPD_VIR_PARAMS_WITH_INVOICE');
                  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                  print_error_message('Error raised in call to UPD_VIR_PARAMS_WITH_INVOICE');
                  RAISE var_int_catchup_failed;
                END IF;

                g_vir_tbl := r_vir_tbl;

                populate_vir_params(
                         p_api_version    => 1.0,
                         p_init_msg_list  => OKL_API.G_TRUE,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_vir_tbl        => g_vir_tbl);
                IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  print_error_message('Unexpected error raised in call to POPULATE_VIR_PARAMS');
                  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                  print_error_message('Error raised in call to POPULATE_VIR_PARAMS');
                  RAISE var_int_catchup_failed;
                END IF;

             ELSIF (l_invoice_amt < 0) THEN
/*
                OPEN  catchup_params_csr (p_contract_id, SYSDATE);
                FETCH catchup_params_csr INTO l_catchup_settlement_code;
                IF (catchup_params_csr%NOTFOUND) THEN
                   CLOSE catchup_params_csr;
                   RAISE var_int_catchup_failed;
                END IF;
                CLOSE catchup_params_csr;
*/
                print_debug (' catchup settlement code : '|| G_CATCHUP_SETTLEMENT_CODE);

                IF (G_CATCHUP_SETTLEMENT_CODE = 'CREDIT') THEN
                   l_stream_type_purpose := 'INTEREST_CATCHUP';
                   Create_Stream_Invoice (
                          p_api_version            => 1.0,
                          p_init_msg_list          => p_init_msg_list,
                          x_return_status          => x_return_status,
                          x_msg_count              => x_msg_count,
                          x_msg_data               => x_msg_data,
                          p_contract_id            => p_contract_id,
                          p_line_id                => NULL,
                          p_amount                 => l_invoice_amt,
                          p_due_date               => p_due_date,
                          p_stream_type_purpose    => l_stream_type_purpose,
                          p_create_invoice_flag    => OKL_API.G_TRUE,
                          p_parent_strm_element_id => NULL,
						  x_invoice_id             => l_invoice_id,
			  		      x_stream_element_id      => l_stream_element_id);

                   IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                     print_error_message('Unexpected error raised in call to CREATE_STREAM_INVOICE');
                     RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                     print_error_message('Error raised in call to CREATE_STREAM_INVOICE');
                     RAISE var_int_catchup_failed;
                   END IF;

                   i_vir_tbl := g_vir_tbl;

                   upd_vir_params_with_invoice (
                       p_api_version   => 1.0,
                       p_init_msg_list => OKL_API.G_TRUE,
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_source_id     => l_invoice_id,
                       p_vir_tbl       => i_vir_tbl,
                       x_vir_tbl       => r_vir_tbl);
                   IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                     print_error_message('Unexpected error raised in call to UPD_VIR_PARAMS_WITH_INVOICE');
                     RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                     print_error_message('Error raised in call to UPD_VIR_PARAMS_WITH_INVOICE');
                     RAISE var_int_catchup_failed;
                   END IF;

                   g_vir_tbl := r_vir_tbl;

                   populate_vir_params(
                            p_api_version    => 1.0,
                            p_init_msg_list  => OKL_API.G_TRUE,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_vir_tbl        => g_vir_tbl);
                   IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                     print_error_message('Unexpected error raised in call to POPULATE_VIR_PARAMS');
                     RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                     print_error_message('Error raised in call to POPULATE_VIR_PARAMS');
                     RAISE var_int_catchup_failed;
                   END IF;

                ELSIF (G_CATCHUP_SETTLEMENT_CODE = 'ADJUST') THEN
                   print_debug('Calculating PRINCIPAL_CATCHUP adjustment amounts for assets.');
                   l_stream_type_purpose := 'PRINCIPAL_CATCHUP';
                   l_line_index          := 0;
                   -- Identify the Assets
                   FOR current_line IN contract_line_csr(p_contract_id)
                   LOOP
                     prin_date_range_var_rate_ctr (
                          p_api_version           => 1.0,
                          p_init_msg_list         => OKL_API.G_FALSE,
                          x_return_status         => x_return_status,
                          x_msg_count             => x_msg_count,
                          x_msg_data              => x_msg_data,
                          p_contract_id           => p_contract_id,
                          p_line_id               => current_line.id,
                          p_start_date            => p_start_date,
                          p_due_date              => p_due_date,
                          p_principal_basis       => G_PRINCIPAL_BASIS_CODE,
                          x_principal_balance_tbl => l_principal_balance_tbl);
                     IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                       print_error_message('Unexpected error raised in call to PRIN_DATE_RANGE_VAR_RATE_CTR');
                       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                       print_error_message('Error raised in call to PRIN_DATE_RANGE_VAR_RATE_CTR');
                       RAISE var_int_catchup_failed;
                     END IF;

                     IF l_principal_balance_tbl.COUNT > 0 THEN
                        l_principal_balance := l_principal_balance_tbl(l_principal_balance_tbl.COUNT).principal_balance;
                        IF (l_principal_balance > 0) THEN
                           l_line_index                          := l_line_index + 1;
                           l_asset_line_tbl(l_line_index).id     := current_line.id;
                           l_asset_line_tbl(l_line_index).amount := l_principal_balance;
                           l_total_asset_val                     := l_total_asset_val + l_principal_balance;
                           print_debug('Asset id :' || l_asset_line_tbl(l_line_index).id || ' Principal bal :' || l_principal_balance);
                        END IF;
                     END IF;
                   END LOOP;
                   l_asset_line_tbl_count := l_asset_line_tbl.COUNT;
                   l_invoice_amt          := -1 * l_invoice_amt;

                   OPEN  principal_adjustment_csr (p_contract_id, p_start_date, p_due_date);
                   FETCH principal_adjustment_csr INTO l_principal_adjusted;
                   IF (principal_adjustment_csr % NOTFOUND) THEN
                     l_principal_adjusted := 0;
                   END IF;
                   CLOSE principal_adjustment_csr;

                   IF (l_principal_adjusted > 0) THEN
                     l_invoice_amt := l_invoice_amt - l_principal_adjusted;
                   END IF;

                   print_debug('Net Invoice amount after adjustment : '|| l_invoice_amt);

                   IF (l_asset_line_tbl_count > 0) THEN
                      print_debug('Creating PRINCIPAL_CATCHUP adjustment streams for assets.');

                      FOR l_index in 1 .. l_asset_line_tbl_count
                      LOOP
                         l_prorated_invoice_amt := OKL_ACCOUNTING_UTIL.round_amount((l_asset_line_tbl(l_index).amount * l_invoice_amt / l_total_asset_val),p_currency_code);

                         print_debug('Creating PRINCIPAL_CATCHUP adjustment streams for asset id : ' || l_asset_line_tbl(l_index).id || ' for Amount :' || l_prorated_invoice_amt);
                         Create_Stream_Invoice (
                                p_api_version            => 1.0,
                                p_init_msg_list          => p_init_msg_list,
                                x_return_status          => x_return_status,
                                x_msg_count              => x_msg_count,
                                x_msg_data               => x_msg_data,
                                p_contract_id            => p_contract_id,
                                p_line_id                => l_asset_line_tbl(l_index).id,
                                p_amount                 => l_prorated_invoice_amt,
                                p_due_date               => p_due_date,
                                p_stream_type_purpose    => l_stream_type_purpose,
                                p_create_invoice_flag    => OKL_API.G_FALSE,
                                p_process_flag           => 'PRINCIPAL_CATCHUP',
                                p_parent_strm_element_id => NULL,
        	    	   			x_invoice_id             => l_invoice_id,
            					x_stream_element_id      => l_stream_element_id);

                         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                           print_error_message('Unexpected error raised in call to CREATE_STREAM_INVOICE');
                           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                           print_error_message('Error raised in call to CREATE_STREAM_INVOICE');
                           RAISE var_int_catchup_failed;
                         END IF;
                         print_debug('Successfully created PRINCIPAL_CATCHUP adjustment streams for asset id : ' || l_asset_line_tbl(l_index).id || ' for Amount :' || l_prorated_invoice_amt);
                         l_invoice_amt := l_invoice_amt - l_prorated_invoice_amt;
                         l_total_asset_val := l_total_asset_val - l_asset_line_tbl(l_index).amount;

                      END LOOP;

                      i_vir_tbl := g_vir_tbl;

                      upd_vir_params_with_invoice (
                          p_api_version   => 1.0,
                          p_init_msg_list => OKL_API.G_TRUE,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_source_id     => l_stream_element_id,
                          p_vir_tbl       => i_vir_tbl,
                          x_vir_tbl      => r_vir_tbl);
                      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                        print_error_message('Unexpected error raised in call to UPD_VIR_PARAMS_WITH_INVOICE');
                         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                        print_error_message('Error raised in call to UPD_VIR_PARAMS_WITH_INVOICE');
                         RAISE var_int_catchup_failed;
                      END IF;

                      g_vir_tbl := r_vir_tbl;

                      populate_vir_params(
                               p_api_version    => 1.0,
                               p_init_msg_list  => OKL_API.G_TRUE,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_vir_tbl        => g_vir_tbl);
                      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                        print_error_message('Unexpected error raised in call to POPULATE_VIR_PARAMS');
                        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                        print_error_message('Error raised in call to POPULATE_VIR_PARAMS');
                        RAISE var_int_catchup_failed;
                      END IF;
                   END IF;
                END IF;
             END IF;
          END IF;
       END IF;
    END IF;

    populate_principal_bal_txn(
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_vpb_tbl        => g_vpb_tbl);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      print_error_message('Unexpected error raised in call to POPULATE_PRINCIPAL_BAL_TXN');
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      print_error_message('Error raised in call to POPULATE_PRINCIPAL_BAL_TXN');
      RAISE var_int_catchup_failed;
    END IF;

    g_vpb_tbl.delete;
 	  g_vpb_tbl_counter := 0;


  EXCEPTION
    WHEN var_int_catchup_failed THEN
      print_error_message ('Exception var_int_catchup_failed raised in procedure VARIABLE_INTEREST_CATCHUP');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS  THEN
      print_error_message ('Exception raised in procedure VARIABLE_INTEREST_CATCHUP');
      Okl_Api.SET_MESSAGE(
              p_app_name     => G_APP_NAME,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => SQLCODE,
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_ERROR;
  END variable_interest_catchup;

-----------------------------------------------------------------
  PROCEDURE variable_interest(
        p_api_version     IN  NUMBER,
        p_init_msg_list   IN  VARCHAR2,
        x_return_status   OUT NOCOPY VARCHAR2,
        x_msg_count       OUT NOCOPY NUMBER,
        x_msg_data        OUT NOCOPY VARCHAR2,
        p_contract_number IN VARCHAR2,
        P_to_date         IN  DATE)

    IS
    ------------------------------------------------------------
    -- Declare variables required by APIs
    ------------------------------------------------------------

    l_api_version                CONSTANT NUMBER := 1.0;
    l_api_name                   CONSTANT VARCHAR2(30) := 'VARIABLE_INTEREST';
    l_return_status	             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_data                   VARCHAR2(2000);
  	l_def_no_val	             CONSTANT NUMBER		    := -1;
  	l_bill_date	                 OKL_TRX_AR_INVOICES_V.date_invoiced%TYPE;
  	l_kle_id	                 OKL_TXL_AR_INV_LNS_V.kle_id%TYPE;
  	l_stm_date  	             DATE;
  	l_period_start_date  	     DATE;
  	l_period_end_date  	         DATE;
  	l_due_date  	             DATE;
    l_last_interest_cal_date     DATE;
    l_end_of_process             BOOLEAN := FALSE;
    l_int_params_exist           BOOLEAN := TRUE;
  	l_msg_count			         NUMBER;
    l_from_date                  DATE;
    l_to_date                    DATE;
    l_rate_change_value          OKL_K_RATE_PARAMS.rate_change_value%TYPE;
    l_catchup_date               DATE;
    l_termination_date           DATE;
    l_print_lead_days            NUMBER;
    l_vrc_report_tbl             vrc_tbl_type;
    variable_interest_failed     EXCEPTION;
    l_int_cal_start_date         DATE;
    l_calculate_from_khr_start   VARCHAR2(10) := 'Y';

    --Bug# 7277007
    l_counter                    NUMBER;
    l_contract_number            OKC_K_HEADERS_B.contract_number%TYPE;
    l_product_name               OKL_PRODUCTS.name%TYPE;

    CURSOR c_var_int_params_csr(p_chr_id IN NUMBER,
                                p_req_id IN NUMBER) IS
    SELECT 'Y'
    FROM   okl_var_int_params
    WHERE  khr_id = p_chr_id
    AND    request_id = p_req_id;

    l_var_int_params_found_yn VARCHAR2(1);
    --Bug# 7277007

    /* Cursor to evaluate contracts eligible for calculating Variable Interest depending on
    Principal Payment streams are between the last interest calculation date and the date
    user wants to run upto
    */
    CURSOR c_contracts_csr ( p_contract_number VARCHAR2, p_to_date DATE )IS
       SELECT distinct khr.id khr_id,
              khr.deal_type,
              khr.date_last_interim_interest_cal,
              chr.contract_number,
              chr.start_date start_date,
              chr.date_terminated termination_date,
              chr.end_date   end_date,
              chr.currency_code,
              ppm.interest_calculation_basis,
              ppm.revenue_recognition_method,
              chr.authoring_org_id,
              khr.pdt_id,
              --Bug# 7277007
              ppm.name product_name
       FROM   okc_k_headers_b chr,
              okl_k_headers   khr,
              okc_statuses_b  khs,
              okl_product_parameters_v ppm
       WHERE  CHR.CONTRACT_NUMBER = NVL(p_contract_number,CHR.CONTRACT_NUMBER)
       AND	  khr.deal_type IN ('LOAN','LEASEDF','LOAN-REVOLVING','LEASEST','LEASEOP')
       AND	  chr.id = khr.id
       AND	  khs.code = chr.sts_code
       AND    khs.ste_code = 'ACTIVE'
       AND    khr.pdt_id = ppm.id
       AND    ppm.interest_calculation_basis <> 'FIXED'
      ORDER BY khr.deal_type, chr.contract_number;


    CURSOR interest_params_csr (p_contract_id NUMBER,
                                p_effective_date DATE) IS
       SELECT interest_basis_code,
	          calculation_formula_id,
			  nvl(principal_basis_code, 'ACTUAL'),
              days_in_a_month_code,
              days_in_a_year_code,
              rate_change_value,
              catchup_settlement_code
       FROM   okl_k_rate_params
       WHERE  khr_id = p_contract_id
       AND    p_effective_date BETWEEN effective_from_date and nvl(effective_to_date, p_effective_date)
       AND    parameter_type_code = 'ACTUAL';

  BEGIN

    ------------------------------------------------------------
    -- Start processing
    ------------------------------------------------------------

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    g_request_id    := FND_GLOBAL.CONC_REQUEST_ID;

    print_debug ('g_request_id : '|| g_request_id);
    print_debug ('Concurrent Request ID : '|| FND_GLOBAL.CONC_REQUEST_ID);

    g_to_date           := p_to_date;

    ------------------------------------------------------------
    -- Initialise local variables
    ------------------------------------------------------------

  	l_kle_id	:= l_def_no_val;


    -- **********************
    -- ** Process contracts *
    -- **********************

    print_debug('***Start of Processing***');
    print_debug('Contract Number: '||p_contract_number);

    g_no_of_contracts_processed   := 0;
    g_no_of_rejected_contracts    := 0;
    g_no_of_successful_contracts  := 0;

    FOR r_contracts_csr IN c_contracts_csr ( p_contract_number, p_to_date) LOOP
      print_debug ('--------------------------------------------------------------------------');
      print_debug ('--------------------------------------------------------------------------');
      print_debug ('Start Processing for Contract Number: ' ||r_contracts_csr.contract_number);
      print_debug('Last Interest Calculation Date: ' ||r_contracts_csr.date_last_interim_interest_cal);

      G_CONTRACT_ID                := r_contracts_csr.khr_id;
      G_AUTHORING_ORG_ID           := r_contracts_csr.authoring_org_id;
      G_PRODUCT_ID                 := r_contracts_csr.pdt_id;
      G_DEAL_TYPE                  := r_contracts_csr.deal_type;
      G_CONTRACT_START_DATE        := r_contracts_csr.start_date;
      G_CONTRACT_END_DATE          := r_contracts_csr.end_date;
      G_CURRENCY_CODE              := r_contracts_csr.currency_code;
      G_INTEREST_CALCULATION_BASIS := r_contracts_csr.interest_calculation_basis;
      G_CALC_METHOD_CODE           := r_contracts_csr.interest_calculation_basis;
      G_REVENUE_RECOGNITION_METHOD := r_contracts_csr.revenue_recognition_method;
      G_CONTRACT_PRINCIPAL_BALANCE := NULL;
      l_termination_date           := r_contracts_csr.termination_date;
      l_last_interest_cal_date     := r_contracts_csr.date_last_interim_interest_cal;

      G_FIN_AST_LINE_ID            := NULL;
      G_ASSET_PRINCIPAL_BALANCE    := NULL;

      l_print_lead_days := get_printing_lead_days (G_CONTRACT_ID);

      --Bug# 7277007
      l_contract_number := r_contracts_csr.contract_number;
      l_product_name    := r_contracts_csr.product_name;
      --Bug# 7277007

      OPEN interest_params_csr (G_CONTRACT_ID, nvl(p_to_date,SYSDATE));
      FETCH interest_params_csr INTO G_INTEREST_BASIS_CODE, G_CALCULATION_FORMULA_ID,
			                         G_PRINCIPAL_BASIS_CODE, G_DAYS_IN_A_MONTH_CODE,
                                     G_DAYS_IN_A_YEAR_CODE, l_rate_change_value,
									 G_CATCHUP_SETTLEMENT_CODE;

      IF interest_params_csr%NOTFOUND THEN
        l_int_params_exist := FALSE;
        print_error_message('Interest Params cursor did not return any records for contract ID: '||G_CONTRACT_ID);
--       	RAISE variable_interest_failed;
      ELSE
        l_int_params_exist := TRUE;
      END IF;
      CLOSE interest_params_csr;

      IF (l_int_params_exist) THEN
        print_debug('Contract Number: '||r_contracts_csr.contract_number);
        print_debug('Contract ID: '|| G_CONTRACT_ID);
        print_debug('Authoring Org ID: '|| G_AUTHORING_ORG_ID);
        print_debug('Product ID: '|| G_PRODUCT_ID);
  	    print_debug('deal type :'|| G_DEAL_TYPE );
	    print_debug('Contract Start Date: '||G_CONTRACT_START_DATE);
	    print_debug('Contract End Date: '||G_CONTRACT_END_DATE);
	    print_debug('Currency code: '||G_CURRENCY_CODE);
	    print_debug('calculation basis : '|| G_INTEREST_CALCULATION_BASIS );
	    print_debug('revenue recognition method : '|| G_REVENUE_RECOGNITION_METHOD);
	    print_debug('Principal Balance : '|| G_CONTRACT_PRINCIPAL_BALANCE);
	    print_debug('Last Interest Calculation Date: ' ||r_contracts_csr.date_last_interim_interest_cal );

	    print_debug('Interest basis : '|| G_INTEREST_BASIS_CODE );
	    print_debug('Calculation Formula ID : '|| G_CALCULATION_FORMULA_ID);
	    print_debug('Principal Basis : '|| G_PRINCIPAL_BASIS_CODE);
	    print_debug('Days in a Month : '|| G_DAYS_IN_A_MONTH_CODE);
	    print_debug('Days in a Year  : '|| G_DAYS_IN_A_YEAR_CODE);
	    print_debug('Catchup Settlement Code  : '|| G_CATCHUP_SETTLEMENT_CODE);

      IF (G_INTEREST_CALCULATION_BASIS = G_INT_CALC_BASIS_FLOAT_FACTORS) THEN
        BEGIN
          l_from_date := nvl(l_last_interest_cal_date,G_CONTRACT_START_DATE);
          l_to_date   := nvl(p_to_date, trunc(SYSDATE));
          --change on 15 Nov 2005 by pgomes for bug fix 4740293
          --considering print lead days for obtaining end date of range
          IF (l_to_date > trunc(SYSDATE) + l_print_lead_days) THEN
            l_to_date := trunc(SYSDATE) + l_print_lead_days;
          END IF;

          print_debug ('contract id : '|| G_CONTRACT_ID );
          print_debug ('From Date : '|| l_from_date );
          print_debug ('To Date : '|| l_to_date);

          variable_interest_float_factor(
                   p_api_version    => 1.0,
                   p_init_msg_list  => OKL_API.G_TRUE,
                   x_return_status  => l_return_status,
                   x_msg_count      => l_msg_count,
                   x_msg_data       => l_msg_data,
                   p_contract_id    => G_CONTRACT_ID,
                   p_from_date      => l_from_date,
                   p_to_date        => l_to_date);
          IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            print_error_message('Unexpected error raised in call to VARIABLE_INTEREST_FLOAT_FACTOR');
     	    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            print_error_message('Error raised in call to VARIABLE_INTEREST_FLOAT_FACTOR');
      	    RAISE variable_interest_failed;
          END IF;
          print_debug('Variable interest calculation completed successfully for contract id : '|| G_CONTRACT_ID);

          g_no_of_successful_contracts := g_no_of_successful_contracts + 1;
        EXCEPTION
          WHEN OTHERS THEN
            g_no_of_rejected_contracts := g_no_of_rejected_contracts + 1;
            ROLLBACK;
            report_error (
              p_contract_number     => l_contract_number,
              p_product_name        => l_product_name,
              p_interest_calc_basis => G_INTEREST_CALCULATION_BASIS,
              p_last_int_calc_date  => l_last_interest_cal_date,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data);

            x_return_status := OKL_API.G_RET_STS_ERROR;
        END;
      ELSIF (G_INTEREST_CALCULATION_BASIS = G_INT_CALC_BASIS_REAMORT) THEN
        BEGIN
          print_debug ('contract id : '|| G_CONTRACT_ID );

          IF ((NVL(r_contracts_csr.date_last_interim_interest_cal, G_CONTRACT_START_DATE) > (trunc(sysdate) + l_print_lead_days)) OR
              ((NVL(r_contracts_csr.date_last_interim_interest_cal, G_CONTRACT_START_DATE) > nvl(p_to_date, trunc(SYSDATE)))) OR
              ((NVL(r_contracts_csr.date_last_interim_interest_cal, G_CONTRACT_START_DATE) > G_CONTRACT_END_DATE))) THEN
              print_error_message('Reamort Date is past the system date (with print lead days included) or is past the To Date or is past the Contract End Date.');
              print_debug('Reamort Date is past the system date (with print lead days included) or is past the To Date or is past the Contract End Date.');
          ELSE
            initiate_request(
                     p_api_version    => 1.0,
                     p_init_msg_list  => OKL_API.G_TRUE,
                     p_khr_id         => G_CONTRACT_ID,
                     x_return_status  => l_return_status,
                     x_msg_count      => l_msg_count,
                     x_msg_data       => l_msg_data);

            IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              print_error_message('Unexpected error raised in call to INITIATE_REQUEST');
       	    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              print_error_message('Error raised in call to INITIATE_REQUEST');
        	    RAISE variable_interest_failed;
            END IF;
            print_debug('Variable interest calculation completed successfully for contract id : '|| G_CONTRACT_ID);
            COMMIT;
            g_no_of_successful_contracts := g_no_of_successful_contracts + 1;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            g_no_of_rejected_contracts := g_no_of_rejected_contracts + 1;
            ROLLBACK;
            report_error (
              p_contract_number     => l_contract_number,
              p_product_name        => l_product_name,
              p_interest_calc_basis => G_INTEREST_CALCULATION_BASIS,
              p_last_int_calc_date  => l_last_interest_cal_date,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data);

            x_return_status := OKL_API.G_RET_STS_ERROR;
        END;
      ELSIF (G_INTEREST_CALCULATION_BASIS = G_INT_CALC_BASIS_FLOAT) THEN
         BEGIN
           IF (l_last_interest_cal_date is not null
               and l_last_interest_cal_date > G_CONTRACT_START_DATE) THEN
             l_stm_date := l_last_interest_cal_date;
           ELSE
             l_stm_date := G_CONTRACT_START_DATE;
           END IF;

           print_debug('Stream Start Date: '||l_stm_date);

           l_end_of_process := FALSE;
           l_calculate_from_khr_start := 'Y';

           print_debug ('Stream Start Date: '||l_stm_date);
           print_debug ('Contract Id: '||G_CONTRACT_ID);
           print_debug ('To Date: '||p_to_date);

           l_end_of_process := FALSE;
           l_bill_date := null;
           l_due_date := null;
           LOOP
             IF ((G_DEAL_TYPE = 'LOAN' or G_DEAL_TYPE ='LOAN-REVOLVING') AND
                 ( NOT(l_end_of_process))) THEN
                print_debug('Executing OKL_STREAM_GENERATOR_PVT.get_next_billing_date ');
                print_debug('Billing Date : '|| nvl(l_last_interest_cal_date, G_CONTRACT_START_DATE) );

                OKL_STREAM_GENERATOR_PVT.get_next_billing_date(
                    p_api_version            => p_api_version,
                    p_init_msg_list          => p_init_msg_list,
                    p_khr_id                 => G_CONTRACT_ID,
                    p_billing_date           => nvl(l_last_interest_cal_date, G_CONTRACT_START_DATE),
                    x_next_due_date          => l_due_date,
                    x_next_period_start_date => l_period_start_date,
                    x_next_period_end_date   => l_period_end_date,
                    x_return_status          => x_return_status,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data);

                IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                   print_error_message('Unexpected error raised in call to OKL_STREAM_GENERATOR_PVT.get_next_billing_date');
                   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                   print_error_message('Error raised in call to OKL_STREAM_GENERATOR_PVT.get_next_billing_date');
       		       RAISE variable_interest_failed;
                END IF;

                print_debug(' Next Due Date : '|| l_due_date );
        				print_debug(' Next Period Start Date : '|| l_period_start_date );
        				print_debug(' Next Period End Date : ' || l_period_end_date );
        				print_debug(' Last Interest calculation date : '|| l_last_interest_cal_date);

             END IF;

             IF (trunc(l_due_date) = l_last_interest_cal_date OR
                 l_due_date is null OR
                 trunc(l_due_date) > (trunc(sysdate)+ l_print_lead_days) OR
                 trunc(l_due_date) > trunc(p_to_date)) THEN
                 --EXIT;
                l_end_of_process := TRUE;
             END IF;

             print_debug('Stream Element Date: '||l_due_date);

             x_return_status := OKL_API.G_RET_STS_SUCCESS;
             ----------------------------------------------------
             -- Create new transaction header for every
             -- contract and bill_date combination
             ----------------------------------------------------
             print_debug('Bill Date: '||l_due_date);

             IF NOT(l_end_of_process) THEN
             ------------------------------------------------------------
                print_debug ('Executing procedure variable_interest_float');
                print_debug ('Contract ID : '|| G_CONTRACT_ID );
        				print_debug( 'Principal Basis : '|| G_PRINCIPAL_BASIS_CODE);
        				print_debug( 'Revenue Recognition Method : '|| G_REVENUE_RECOGNITION_METHOD );
        				print_debug( 'Calculation Basis : '|| G_INTEREST_CALCULATION_BASIS );
                print_debug( 'Deal Type : '|| G_DEAL_TYPE);
                print_debug( 'Currency Code : '|| G_CURRENCY_CODE );
                print_debug( 'Start Date : '|| G_CONTRACT_START_DATE );
                print_debug( 'Period Start Date : '|| l_period_start_date );
        				print_debug( 'Due Date : '|| l_due_date);

        				-- BUG 4748287
        				IF (G_PRINCIPAL_BASIS_CODE = 'SCHEDULED') THEN
        				   l_int_cal_start_date := l_period_start_date;
        				ELSE
                   l_calculate_from_khr_start := calculate_from_khr_start_date(p_khr_id => G_CONTRACT_ID,
                                                                               p_from_date => l_period_start_date);

        				   IF (l_calculate_from_khr_start = 'Y') THEN
                     l_int_cal_start_date := G_CONTRACT_START_DATE;
            				 print_debug('Float interest calculation will start from contract start date : ' || l_int_cal_start_date);
                   ELSE
                     l_int_cal_start_date := l_period_start_date;
            				 print_debug('Float interest calculation will start from billing period start date : ' || l_int_cal_start_date);
                   END IF;
        				END IF;

                variable_interest_float(
                         p_api_version     => 1.0,
                         p_init_msg_list   => OKL_API.G_TRUE,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_contract_id     => G_CONTRACT_ID,
                         p_principal_basis => G_PRINCIPAL_BASIS_CODE,
                         p_rev_rec_method  => G_REVENUE_RECOGNITION_METHOD,
                         p_deal_type       => G_DEAL_TYPE,
                         p_currency_code   => G_CURRENCY_CODE,
                         p_start_date      => l_int_cal_start_date,
                         p_due_date        => l_due_date);

                IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                   print_error_message('Unexpected error raised in call to VARIABLE_INTEREST_FLOAT');
         	       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                   print_error_message('Error raised in call to VARIABLE_INTEREST_FLOAT');
       		       RAISE variable_interest_failed;
                END IF;

                print_debug ('Variable interest Calculation completed successfully for Billing period : '|| l_due_date);
             ELSE
               EXIT;
             END IF;

             FND_FILE.PUT_LINE (FND_FILE.LOG, '===============================================================================');

             UPDATE okl_k_headers khr
             SET    khr.date_last_interim_interest_cal =  l_due_date
             WHERE  khr.id = G_CONTRACT_ID;

             l_last_interest_cal_date := l_due_date;

             COMMIT;

             Print_debug('Processing complete for due date : '|| l_due_date);
           END LOOP;
           g_no_of_successful_contracts := g_no_of_successful_contracts + 1;
         EXCEPTION
           WHEN OTHERS THEN
             g_no_of_rejected_contracts := g_no_of_rejected_contracts + 1;
             x_return_status := OKL_API.G_RET_STS_ERROR;
             l_end_of_process := TRUE;
             report_error (
               p_contract_number     => l_contract_number,
               p_product_name        => l_product_name,
               p_interest_calc_basis => G_INTEREST_CALCULATION_BASIS,
               p_last_int_calc_date  => l_last_interest_cal_date,
               x_msg_count           => x_msg_count,
               x_msg_data            => x_msg_data);
             ROLLBACK;
         END;
       ELSIF (G_INTEREST_CALCULATION_BASIS = G_INT_CALC_BASIS_CATCHUP) THEN
         BEGIN

           l_end_of_process := FALSE;
           l_catchup_date := get_next_catchup_date(G_CONTRACT_ID);
           l_calculate_from_khr_start := 'Y';

           Print_Debug ('Principal Basis : '|| G_PRINCIPAL_BASIS_CODE);
           Print_Debug ('Catchup Date : '|| l_catchup_date);

           --change by pgomes on 17 nov 2005 for bug fix 4739869
           --IF (NOT(l_last_interest_cal_date is NOT NULL AND
           --  l_last_interest_cal_date >= l_catchup_date)) THEN
             LOOP
               IF (l_catchup_date > NVL(l_last_interest_cal_date, l_catchup_date - 1) AND
                   l_catchup_date  <= (trunc(sysdate)+ l_print_lead_days) AND
                   l_catchup_date <= NVL(p_to_date, l_catchup_date)) THEN
                  l_end_of_process := FALSE;
               ELSE
                  l_end_of_process := TRUE;
               END IF;

               EXIT WHEN l_end_of_process = TRUE;

               l_period_start_date := NVL(l_last_interest_cal_date + 1, G_CONTRACT_START_DATE);

               l_calculate_from_khr_start := calculate_from_khr_start_date(p_khr_id => G_CONTRACT_ID,
                                                                           p_from_date => l_period_start_date);

    				   IF (l_calculate_from_khr_start = 'Y') THEN
                 l_int_cal_start_date := G_CONTRACT_START_DATE;
        				 print_debug('Catchup Cleanup interest calculation will start from contract start date : ' || l_int_cal_start_date);
               ELSE
                 l_int_cal_start_date := l_period_start_date;
        				 print_debug('Catchup Cleanup interest calculation will start from catchup period start date : ' || l_int_cal_start_date);
               END IF;

               VARIABLE_INTEREST_CATCHUP(
                        p_api_version     => p_api_version,
                        p_init_msg_list   => Okl_Api.G_TRUE,
                        x_return_status   => x_return_status,
                        x_msg_count       => x_msg_count,
                        x_msg_data        => x_msg_data,
                        p_contract_id     => G_CONTRACT_ID,
                        p_principal_basis => G_PRINCIPAL_BASIS_CODE,
                        p_rev_rec_method  => G_REVENUE_RECOGNITION_METHOD,
                        p_deal_type       => G_DEAL_TYPE,
                        p_currency_code   => G_CURRENCY_CODE,
                        p_start_date      => l_int_cal_start_date,
                        p_due_date        => l_catchup_date);

               IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  print_error_message('Unexpected error raised in call to VARIABLE_INTEREST_CATCHUP');
                  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                  print_error_message('Error raised in call to VARIABLE_INTEREST_CATCHUP');
       		      RAISE variable_interest_failed;
               END IF;

               print_debug ('Updating contract - id : '|| G_CONTRACT_ID || 'with interest calculation date : '|| l_catchup_date);

               UPDATE okl_k_headers khr
               SET    khr.date_last_interim_interest_cal =  l_catchup_date
               where  khr.id = G_CONTRACT_ID;

               l_last_interest_cal_date := l_catchup_date;

               COMMIT;

               /*IF (l_catchup_date >= nvl(l_termination_date, l_contract_end_date) OR
			       l_catchup_date > (trunc(sysdate)+ l_print_lead_days) OR
				   l_catchup_date > l_last_interest_cal_date) THEN
                  l_end_of_process := TRUE;
               ELSE*/
			      l_catchup_date := get_next_catchup_date(G_CONTRACT_ID);
  			   --END IF;
             END LOOP;
          --END IF;
          g_no_of_successful_contracts := g_no_of_successful_contracts + 1;
        EXCEPTION
           WHEN OTHERS THEN
             g_no_of_rejected_contracts := g_no_of_rejected_contracts + 1;
             x_return_status := OKL_API.G_RET_STS_ERROR;
             l_end_of_process := TRUE;
             report_error (
               p_contract_number     => l_contract_number,
               p_product_name        => l_product_name,
               p_interest_calc_basis => G_INTEREST_CALCULATION_BASIS,
               p_last_int_calc_date  => l_last_interest_cal_date,
               x_msg_count           => x_msg_count,
               x_msg_data            => x_msg_data);
             ROLLBACK;
        END;
      END IF;
      END IF;

      g_no_of_contracts_processed := g_no_of_contracts_processed + 1;

      l_vrc_report_tbl(g_no_of_contracts_processed).contract_number            := r_contracts_csr.contract_number;
      l_vrc_report_tbl(g_no_of_contracts_processed).contract_id                := G_CONTRACT_ID;
      l_vrc_report_tbl(g_no_of_contracts_processed).start_date                 := G_CONTRACT_START_DATE;
      l_vrc_report_tbl(g_no_of_contracts_processed).end_date                   := G_CONTRACT_END_DATE;
      l_vrc_report_tbl(g_no_of_contracts_processed).interest_calculation_basis := G_INTEREST_CALCULATION_BASIS;
      l_vrc_report_tbl(g_no_of_contracts_processed).days_in_a_month_code       := G_DAYS_IN_A_MONTH_CODE;
      l_vrc_report_tbl(g_no_of_contracts_processed).days_in_a_year_code        := G_DAYS_IN_A_YEAR_CODE;
      l_vrc_report_tbl(g_no_of_contracts_processed).rate_change_value          := l_rate_change_value;
      l_vrc_report_tbl(g_no_of_contracts_processed).process_status             := x_return_status;

      --Bug# 7277007
      IF (x_return_status = 'S') THEN

        l_var_int_params_found_yn := 'N';
        OPEN c_var_int_params_csr(p_chr_id => g_contract_id,
                                  p_req_id => g_request_id);
        FETCH c_var_int_params_csr INTO l_var_int_params_found_yn;
        CLOSE c_var_int_params_csr;

        IF (l_var_int_params_found_yn = 'Y') THEN
          IF g_rpt_summary_tbl.EXISTS(G_INTEREST_CALCULATION_BASIS) THEN
            g_rpt_summary_tbl(G_INTEREST_CALCULATION_BASIS).total_contract_num_success :=
            NVL(g_rpt_summary_tbl(G_INTEREST_CALCULATION_BASIS).total_contract_num_success,0) + 1;
          ELSE
            g_rpt_summary_tbl(G_INTEREST_CALCULATION_BASIS).total_contract_num_success := 1;
          END IF;

          l_counter := 1;
          IF g_rpt_success_icb_tbl.EXISTS(G_INTEREST_CALCULATION_BASIS) THEN
            l_counter := g_rpt_success_icb_tbl(G_INTEREST_CALCULATION_BASIS).LAST + 1;
          END IF;

          g_rpt_success_icb_tbl(G_INTEREST_CALCULATION_BASIS)(l_counter).contract_id          := G_CONTRACT_ID;
          g_rpt_success_icb_tbl(G_INTEREST_CALCULATION_BASIS)(l_counter).contract_number      := r_contracts_csr.contract_number;
          g_rpt_success_icb_tbl(G_INTEREST_CALCULATION_BASIS)(l_counter).days_in_a_month_code := G_DAYS_IN_A_MONTH_CODE;
          g_rpt_success_icb_tbl(G_INTEREST_CALCULATION_BASIS)(l_counter).days_in_a_year_code  := G_DAYS_IN_A_YEAR_CODE;
        END IF;
      END IF;
      --Bug# 7277007

      print_debug ('End Processing for Contract Number: ' ||r_contracts_csr.contract_number);

    END LOOP;
    print_debug('***Printing Report***');
    Print_Report(p_contract_number => p_contract_number);
    print_debug('***End of Processing***');


  EXCEPTION
    	------------------------------------------------------------
    	-- Exception handling
    	------------------------------------------------------------
    WHEN OTHERS THEN
      print_error_message('Exception raised in procedure VARIABLE_INTEREST');
      report_error (
        p_contract_number     => l_contract_number,
        p_product_name        => l_product_name,
        p_interest_calc_basis => G_INTEREST_CALCULATION_BASIS,
        p_last_int_calc_date  => l_last_interest_cal_date,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data);
      x_return_status := OKL_API.G_RET_STS_ERROR;
      ROLLBACK;
   END variable_interest;
END;

/
