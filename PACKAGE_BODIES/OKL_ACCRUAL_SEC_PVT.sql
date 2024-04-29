--------------------------------------------------------
--  DDL for Package Body OKL_ACCRUAL_SEC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCRUAL_SEC_PVT" AS
/* $Header: OKLRASCB.pls 120.16.12010000.3 2009/06/12 11:07:05 racheruv ship $ */
------------------------------------------------------------------------------------
-- GLOBAL OKL MESSAGES
------------------------------------------------------------------------------------
  G_COL_NAME_TOKEN          CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR        CONSTANT  VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_REQUIRED_VALUE          CONSTANT  VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE           CONSTANT  VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_NO_MATCHING_RECORD      CONSTANT  VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_DB_ERROR                CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN         CONSTANT VARCHAR2(9)   := 'PROG_NAME';

 --sosharma 14-12-2007 ,Added pending status
    G_PC_STS_PENDING         CONSTANT VARCHAR2(10)  := 'PENDING';

------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibhotla
-- Procedure Name       : create_lease_streams
-- Description          : Generates Investor Agreement streams when rebook Lease Contract
-- Business Rules       : This a overloaded procedure for create_streams to generate
--                        investor agreement streams when a lease contract is rebooked.
-- Parameters           : p_khr_id, p_scs_code
-- Version              : 1.0
-- History              : BAKUCHIB  12-FEB-2004 - 3426071 created
--                        sechawla  09-mar-09 MG Impact on IA : regenerate the Investor Accrual
--                                            streams upon rebook
-- End of Commnets
--------------------------------------------------------------------------------
  PROCEDURE create_lease_streams(p_api_version          IN NUMBER,
                                 p_init_msg_list        IN VARCHAR2,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_msg_count            OUT NOCOPY NUMBER,
                                 x_msg_data             OUT NOCOPY VARCHAR2,
                                 p_khr_id               IN NUMBER,
                                 p_mode                 IN VARCHAR2 DEFAULT NULL)
    IS
    l_api_name                     CONSTANT VARCHAR2(30)   := 'CREATE_LEASE_STREAMS';
/*
    l_investor_rental_accrual      CONSTANT VARCHAR2(2000) := 'INVESTOR RENTAL ACCRUAL';
    l_investor_pre_tax_income      CONSTANT VARCHAR2(2000) := 'INVESTOR PRE-TAX INCOME';
    l_investor_interest_income     CONSTANT VARCHAR2(2000) := 'INVESTOR INTEREST INCOME';
    l_investor_variable_interest   CONSTANT VARCHAR2(2000) := 'INVESTOR VARIABLE INTEREST';
    l_rental_accrual               CONSTANT VARCHAR2(2000) := 'RENTAL ACCRUAL';
    l_pre_tax_income               CONSTANT VARCHAR2(2000) := 'PRE-TAX INCOME';
    l_interest_income              CONSTANT VARCHAR2(2000) := 'INTEREST INCOME';
    l_variable_income              CONSTANT VARCHAR2(2000) := 'VARIABLE INCOME ACCRUAL';
*/
    l_investor_rental_accrual      CONSTANT VARCHAR2(2000) := 'INVESTOR_RENTAL_ACCRUAL';
    l_investor_pre_tax_income      CONSTANT VARCHAR2(2000) := 'INVESTOR_PRETAX_INCOME';
    l_investor_interest_income     CONSTANT VARCHAR2(2000) := 'GENERAL';
    l_investor_variable_interest   CONSTANT VARCHAR2(2000) := 'INVESTOR_VARIABLE_INTEREST';
    l_rental_accrual               CONSTANT VARCHAR2(2000) := 'RENT_ACCRUAL';
    l_pre_tax_income               CONSTANT VARCHAR2(2000) := 'LEASE_INCOME';
    l_interest_income              CONSTANT VARCHAR2(2000) := 'INTEREST_INCOME';
    l_variable_income              CONSTANT VARCHAR2(2000) := 'ACCOUNTING';
 /* ankushar , 16-01-2008 Bug 6740000
    Added new Stream Type purpose for a Loan product
  */
    l_inv_interest_income_accrual         CONSTANT VARCHAR2(2000) := 'INVESTOR_INTEREST_INCOME';

    l_count                                 NUMBER := 1;
    l_period_end_date                       DATE;
    l_total_records                         NUMBER;
    l_sysdate                               DATE := TRUNC(SYSDATE);
    l_trx_number                            NUMBER;
    l_revenue_share                         NUMBER := 0;
    l_sty_id                                NUMBER;
    l_inv_id                                NUMBER;
    l_return_status			   VARCHAR2(1);
    stream_type_purpose                    VARCHAR2(30);

/* ankushar , 16-01-2008 Bug 6740000
   Modified cursors to fetch based on stream type for a Loan product
   Start Changes
*/
    -- cursor to select Lease contract id for a given Investor agreement
    CURSOR securitized_contracts_csr (p_inv_id NUMBER,
                                      p_khr_id NUMBER)
    IS
    SELECT DISTINCT opc.khr_id khr_id,
           opc.streams_to_date end_date,
           khr.deal_type deal_type
    FROM okl_pool_contents opc,
         okl_pools op,
         okl_k_headers khr,
-- Changed for User Defined Streams
         --okl_strm_type_tl stytl
		 okl_strm_type_b stytl
    WHERE op.khr_id = p_inv_id
    AND opc.khr_id = p_khr_id
    AND op.id = opc.pol_id
    AND opc.khr_id = khr.id
    AND opc.sty_id = stytl.id
    --AND stytl.name = 'RENT'
    AND stytl.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
    AND opc.status_code IN (Okl_Pool_Pvt.G_POC_STS_ACTIVE, Okl_Pool_Pvt.G_POC_STS_NEW);
    --AND stytl.language = USERENV('LANG');

    -- cursor to get first kle_id and earliest stream element date
    CURSOR get_kle_id_csr(p_khr_id NUMBER)
    IS
    SELECT opc.kle_id kle_id,
         MIN(opc.streams_from_date) start_date
    FROM okl_pool_contents opc,
         okl_strm_type_b sty
    WHERE opc.khr_id = p_khr_id
    AND opc.sty_id = sty.id
    --AND sty.code = 'RENT'
    AND sty.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
    AND   opc.status_code IN (Okl_Pool_Pvt.G_POC_STS_ACTIVE, Okl_Pool_Pvt.G_POC_STS_NEW)
    AND ROWNUM < 2
    GROUP BY opc.kle_id;

    /* sosharma ,14-12-2007
        Bug 6691554
        Added cursors for generating streams for transient pool
        Start Changes*/


    -- cursor to select Lease contract id for a given Investor agreement
    CURSOR securitized_contracts_pend_csr (p_inv_id NUMBER,
                                      p_khr_id NUMBER)
    IS
    SELECT DISTINCT opc.khr_id khr_id,
           opc.streams_to_date end_date,
           khr.deal_type deal_type
    FROM okl_pool_contents opc,
         okl_pools op,
         okl_k_headers khr,
-- Changed for User Defined Streams
         --okl_strm_type_tl stytl
		 okl_strm_type_b stytl
    WHERE op.khr_id = p_inv_id
    AND opc.khr_id = p_khr_id
    AND op.id = opc.pol_id
    AND opc.khr_id = khr.id
    AND opc.sty_id = stytl.id
    --AND stytl.name = 'RENT'
    AND stytl.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
    AND opc.status_code = G_PC_STS_PENDING; --Okl_Pool_Pvt.G_POC_STS_PENDING;
    --AND stytl.language = USERENV('LANG');

    -- cursor to get first kle_id and earliest stream element date

    CURSOR get_kle_id_pend_csr(p_khr_id NUMBER)
    IS
    SELECT opc.kle_id kle_id,
         MIN(opc.streams_from_date) start_date
    FROM okl_pool_contents opc,
         okl_strm_type_b sty
    WHERE opc.khr_id = p_khr_id
    AND opc.sty_id = sty.id
    --AND sty.code = 'RENT'
    AND sty.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
    AND   opc.status_code = G_PC_STS_PENDING --Okl_Pool_Pvt.G_POC_STS_PENDING
    AND ROWNUM < 2
    GROUP BY opc.kle_id;

    CURSOR get_inv_pend_csr (p_khr_id NUMBER)
    IS
    SELECT DISTINCT op.khr_id
    FROM okl_pool_contents opc,
         okl_pools op,
         okl_strm_type_b sty
    WHERE op.id = opc.pol_id
    AND opc.khr_id = p_khr_id
    AND opc.sty_id = sty.id
    --AND sty.code = 'RENT';
    AND sty.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
    AND opc.status_code = G_PC_STS_PENDING;--Okl_Pool_Pvt.G_POC_STS_PENDING ;

    /* sosharma end changes*/

    -- cursor to get advance/arrears and frequency for rent stream type
    CURSOR get_adv_arr_csr(p_khr_id NUMBER,
                           p_kle_id NUMBER)
    IS
    SELECT DECODE(sll.rule_information10, NULL, 'N', 'Y', 'Y', 'N') arrears_yn,
           DECODE(sll.object1_id1, 'A',12,'S',6,'Q',3,'M',1) frequency
    FROM okc_k_headers_b k,
         okc_rule_groups_b rg,
         okc_rules_b slh,
         okc_rules_b sll,
         okl_strm_type_b strm
    WHERE slh.rule_information_category = 'LASLH'
    AND slh.rgp_id = rg.id
    AND sll.object2_id1 = to_char(slh.id)
    AND sll.rgp_id = rg.id
    AND slh.object1_id1 = to_char(strm.id)
    --AND strm.code = 'RENT'
	AND strm.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
    AND rg.dnz_chr_id = k.id
    AND rg.chr_id IS NULL
    AND rg.rgd_code = 'LALEVL'
    AND rg.cle_id = p_kle_id
    AND k.id = p_khr_id;
    -- cursor to get stream type id
    CURSOR get_sty_id_csr (p_sty_name VARCHAR2)
    IS
    SELECT id
    FROM okl_strm_type_tl
    WHERE name = p_sty_name
    AND language = USERENV('LANG');

 /* ankushar , 25-01-2008 Bug 6773285
    Modified Cursor to add parameter for Stream type subclass
    Start Changes
  */
    -- the revenue shares for the investor
    CURSOR get_revenue_share_csr(p_inv_id NUMBER, p_stream_type_subclass VARCHAR2)
    IS
    SELECT kleb_rv.percent_stake percent_stake
    FROM okl_k_lines kleb_rv,
         okc_k_lines_b cles_rv,
         okc_line_styles_b lseb_rv
    WHERE
    cles_rv.dnz_chr_id = p_inv_id
    AND cles_rv.lse_id = lseb_rv.id
    AND lseb_rv.lty_code = 'REVENUE_SHARE'
    AND kleb_rv.id = cles_rv.id
    AND kleb_rv.stream_type_subclass = p_stream_type_subclass;
 /* ankushar , 25-01-2008 Bug 6773285
    End Changes
  */
    -- cursor to get contract number
    CURSOR contract_number_csr (p_khr_id NUMBER)
    IS
    SELECT contract_number
    FROM okc_k_headers_b
    WHERE id = p_khr_id
    AND scs_code = 'LEASE';
    -- cursor to get investor Agreement contract id
    -- for a given Lease contract id
    CURSOR get_inv_csr (p_khr_id NUMBER)
    IS
    SELECT DISTINCT op.khr_id
    FROM okl_pool_contents opc,
         okl_pools op,
         okl_strm_type_b sty
    WHERE op.id = opc.pol_id
    AND opc.khr_id = p_khr_id
    AND opc.sty_id = sty.id
    --AND sty.code = 'RENT';
    AND sty.stream_type_purpose = 'RENT'
    AND opc.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE ; --Added by VARANGAN -Pool Contents Impact(Bug#6658065)


    l_contracts_csr                         securitized_contracts_csr%ROWTYPE;
    CURSOR stream_id_csr (p_khr_id NUMBER,
                          p_sty_id NUMBER,
                          p_say_code VARCHAR2,
						  p_purpose_code VARCHAR2)--sechawla 9-mar-09 MG Impact on IA : added
    IS
      select id from okl_streams
      where khr_id=p_khr_id
      and  sty_id=p_sty_id
      and  say_code=p_say_code
	  and  nvl(purpose_code,'XXX') =  nvl(p_purpose_code,'XXX') ; --sechawla 9-mar-09 MG Impact on IA : added


    l_id_tbl okl_streams_util.NumberTabTyp;
    j                  NUMBER := 0;

   -- declaration of a parameterized cursor by zrehman on 12-Sep-2006
   --sechawla 9-mar-09 MG Impact on IA: prefixed curosr parameters with cp, to avoid conflict with column names
   --cursor was not picking any data because old parameter name khr_id was conflicting with column name khr_id
   CURSOR strm_csr (cp_khr_id NUMBER,
                    cp_final_start_date DATE,
                    cp_end_date DATE,
                    cp_stream_type_purpose VARCHAR2)
   IS
      select ste.stream_element_date stream_element_date,ste.amount amount
      FROM okl_strm_type_b sty, okl_streams stm, okl_strm_elements ste
      WHERE
      stm.sty_id = sty.id
      AND ste.stm_id = stm.id
      AND stm.active_yn = 'Y'
      AND stm.say_code = 'CURR'
      AND stm.khr_id = cp_khr_id
      AND ste.stream_element_date BETWEEN cp_final_start_date AND cp_end_date
      AND sty.stream_type_purpose = cp_stream_type_purpose
      ORDER BY ste.stream_element_date;


    --sechawla 9-mar-09 MG Impact on IA
    -- Get secondary_rep_method

    CURSOR rep_strm_csr (cp_khr_id NUMBER,
                    cp_final_start_date DATE,
                    cp_end_date DATE,
                    cp_stream_type_purpose VARCHAR2)
   IS
      select ste.stream_element_date stream_element_date,ste.amount amount
      FROM okl_strm_type_b sty, okl_streams stm, okl_strm_elements ste
      WHERE
      stm.sty_id = sty.id
      AND ste.stm_id = stm.id
      AND stm.active_yn = 'N'
      AND stm.say_code = 'CURR'
      AND stm.purpose_code = 'REPORT'
      AND stm.khr_id = cp_khr_id
      AND ste.stream_element_date BETWEEN cp_final_start_date AND cp_end_date
      AND sty.stream_type_purpose = cp_stream_type_purpose
      ORDER BY ste.stream_element_date;

   /* CURSOR l_sec_rep_method_csr IS
    SELECT secondary_rep_method
	FROM   okl_sys_acct_opts;
	l_sec_rep_method				 VARCHAR2(30);
	*/
	lx_rep_product					 OKL_PRODUCTS_V.NAME%TYPE;
	lx_rep_product_id				 NUMBER;
    lx_rep_deal_type                 okl_product_parameters_v.deal_type%TYPE;
    l_rep_sty_id					 NUMBER;
    rep_stream_type_purpose          VARCHAR2(30);
    l_api_version                    CONSTANT NUMBER := 1.0;
    l_rep_id_tbl 					 okl_streams_util.NumberTabTyp;

  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
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
    -- validate in parameters
    IF p_khr_id IS NULL OR
       p_khr_id = OKL_API.G_MISS_NUM THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_khr_id');
      RAISE okl_api.g_exception_error;
    END IF;
    -- cursor to get investor Agreement contract id
    -- for a given Lease contract id
/* sosharma ,14-12-2007
Bug 6691554
Modified to pick different cursor for pending contents in case p_mode is not null
Start Changes*/


  -- This procedure is called from On-line and Mass Rebook (during activation of rebook)
  -- p_khr_id is the contract_id of the original lease contract that is being rebooked.
  -- This procedure regenerates Investor Accrual streams that are created for the contract, when IA was activated
  -- Rebook process then compares the old and new Investor accrual streams to calculate Investor accrual adjustment

  --sechawla 09-mar-09 : MG Impact on Investor Agreement - Modify create_lease_streams to regenerate the
  --                     Investor Accrual streams upon rebook

  IF p_mode IS NULL THEN
    OPEN  get_inv_csr (p_khr_id => p_khr_id); --ID of lease contract
    FETCH get_inv_csr INTO l_inv_id; --sechawla : ID if Investor Agreement
    IF get_inv_csr%NOTFOUND THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_khr_id');
      RAISE okl_api.g_exception_error;
    END IF;
    CLOSE get_inv_csr;
  ELSE
    OPEN  get_inv_pend_csr (p_khr_id => p_khr_id); --ID of lease contract
    FETCH get_inv_pend_csr INTO l_inv_id; --sechawla : ID if Investor Agreement
    IF get_inv_pend_csr%NOTFOUND THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_khr_id');
      RAISE okl_api.g_exception_error;
    END IF;
    CLOSE get_inv_pend_csr;
  END IF;

  /* sosharma end changes*/

/* sosharma ,14-12-2007
Bug 6691554
Modified to pick different cursor for pending contents in case p_mode is not null
Start Changes*/
 IF p_mode IS NULL THEN
    OPEN securitized_contracts_csr (l_inv_id,
                                    p_khr_id);
    FETCH securitized_contracts_csr INTO l_contracts_csr;
    IF securitized_contracts_csr%NOTFOUND THEN
      okl_api.set_message(p_app_name => g_app_name,
                          p_msg_name => 'OKL_ASC_REV_SHARE_ERROR');
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE securitized_contracts_csr;
  ELSE
      OPEN securitized_contracts_pend_csr (l_inv_id,
                                    p_khr_id);
    FETCH securitized_contracts_pend_csr INTO l_contracts_csr;
    IF securitized_contracts_pend_csr%NOTFOUND THEN
      okl_api.set_message(p_app_name => g_app_name,
                          p_msg_name => 'OKL_ASC_REV_SHARE_ERROR');
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE securitized_contracts_pend_csr;
  END IF;
/* sosharma end changes */

    DECLARE
      TYPE ref_cursor IS REF CURSOR;
      TYPE element_type IS RECORD (stream_element_date DATE,
                                   amount NUMBER);
      l_stmv_rec                   OKL_STREAMS_PUB.stmv_rec_type;
      l_selv_tbl                   OKL_STREAMS_PUB.selv_tbl_type;
      x_stmv_rec                   OKL_STREAMS_PUB.stmv_rec_type;
      x_selv_tbl                   OKL_STREAMS_PUB.selv_tbl_type;
      l_difference                 NUMBER := 0;
      l_counter                    NUMBER := 1;
      l_line_number                NUMBER := 1;
      --l_stmt                       VARCHAR2(5000);
      --l_where                      VARCHAR2(2000) := ' ';
      l_kle_id                     NUMBER;
      l_start_date                 DATE;
      l_final_start_date           DATE;
      ln_days                      NUMBER := 0;
      l_arrears                    VARCHAR2(1);
      l_frequency                  NUMBER;
      l_contract_number            VARCHAR2(2000);
      --strm_csr                     ref_cursor;
      l_elements                   element_type;

      --sechawla 09-mar-09 : MG Impact on Investor Agreement
      l_rep_stmv_rec                   OKL_STREAMS_PUB.stmv_rec_type;
      l_rep_selv_tbl                   OKL_STREAMS_PUB.selv_tbl_type;
      x_rep_stmv_rec                   OKL_STREAMS_PUB.stmv_rec_type;
      x_rep_selv_tbl                   OKL_STREAMS_PUB.selv_tbl_type;
      l_rep_elements                   element_type;
      l_rep_counter                    NUMBER := 1;
      l_rep_line_number                NUMBER := 1;
    BEGIN
    OPEN contract_number_csr(l_contracts_csr.khr_id);
      FETCH contract_number_csr INTO l_contract_number; --lease contract
      IF contract_number_csr%NOTFOUND THEN
        okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Lease Contract id');
        RAISE okl_api.g_exception_error;
      END IF;
      CLOSE contract_number_csr;

      /* sosharma ,14-12-2007
        Bug 6691554
        Modified to pick different cursor for pending contents in case p_mode is not null
        Start Changes*/
       IF p_mode IS NULL THEN
           OPEN get_kle_id_csr(l_contracts_csr.khr_id);
           FETCH get_kle_id_csr INTO l_kle_id, l_start_date;
           IF get_kle_id_csr%NOTFOUND THEN
             okl_api.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_NO_MATCHING_RECORD,
                                 p_token1       => G_COL_NAME_TOKEN,
                                 p_token1_value => 'Lease contract id');
             RAISE okl_api.g_exception_error;
           END IF;
           CLOSE get_kle_id_csr;
       ELSE
           OPEN get_kle_id_pend_csr(l_contracts_csr.khr_id);
           FETCH get_kle_id_pend_csr INTO l_kle_id, l_start_date;
           IF get_kle_id_pend_csr%NOTFOUND THEN
             okl_api.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_NO_MATCHING_RECORD,
                                 p_token1       => G_COL_NAME_TOKEN,
                                 p_token1_value => 'Lease contract id');
             RAISE okl_api.g_exception_error;
           END IF;
           CLOSE get_kle_id_pend_csr;
       END IF;
/* sosharma end changes */

      IF l_kle_id IS NULL OR
         l_kle_id = OKL_API.G_MISS_NUM THEN
        okl_api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_ASC_KLE_ID_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => l_contract_number);
        RAISE okl_api.g_exception_error;
      END IF;
      IF l_start_date IS NULL OR
         l_start_date = okl_api.g_miss_date THEN
        okl_api.set_message(p_app_name => g_app_name,
                            p_msg_name => 'OKL_ASC_START_DATE_ERROR');
        RAISE okl_api.g_exception_error;
      END IF;
      OPEN  get_adv_arr_csr(l_contracts_csr.khr_id, l_kle_id);
      FETCH get_adv_arr_csr INTO l_arrears, l_frequency;
      IF get_adv_arr_csr%NOTFOUND THEN
        okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Lease Contract id and contract Line id');
        RAISE okl_api.g_exception_error;
      END IF;
      CLOSE get_adv_arr_csr;
      IF l_frequency IS NULL THEN
        okl_api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_ASC_FREQUENCY_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => l_contract_number);
        RAISE okl_api.g_exception_error;
      END IF;
      IF l_arrears = 'Y' THEN
        ln_days := OKL_STREAM_GENERATOR_PVT.get_day_count (
                                 p_start_date     => ADD_MONTHS(l_start_date, -l_frequency),
                                 p_end_date       => l_start_date,
                                 p_arrears        => l_arrears,
                                 x_return_status  => x_return_status);
        IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (x_return_Status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
        l_final_start_date := l_start_date - ln_days;
      ELSIF NVL(l_arrears,'N') = 'N' THEN
        l_final_start_date := l_start_date;
      END IF;
      -- commenting as all accrual streams are generated
      -- at contract level. Will remove comments after super trump fix is provided
      -- for stream generation at asset level.Ref cursor will be needed later.
      --IF l_contracts_csr.deal_type IN ('LEASEOP','LEASEDF','LEASEST') THEN
     -- Commented for SQL Literals on 12-09-2006
     /* l_stmt := 'SELECT ste.stream_element_date stream_element_date,
                        ste.amount amount
                 FROM okl_strm_type_b sty,
                      okl_streams stm,
                      okl_strm_elements ste
                 WHERE 1 = 1
                 AND stm.sty_id = sty.id
                 AND ste.stm_id = stm.id
                 AND stm.active_yn = '||''''||'Y'||''''||'
                 AND stm.say_code = '||''''||'CURR'||'''' ;
      l_where := l_where ||' AND stm.khr_id = ' || l_contracts_csr.khr_id
                         ||' AND ste.stream_element_date BETWEEN '|| '''' ||l_final_start_date|| '''' ||' AND '|| '''' ||l_contracts_csr.end_date|| '''';
      */
      --get sty_id for the contract based on deal type

 /* ankushar , 25-01-2008 Bug 6773285
    Added code to generate new Stream Types for a Loan product on an Investor Agreement
    Start Changes
  */

      --------------sechawla 09-mar-09 : MG Impact on Investor Agreement begin--------------
      okl_accounting_util.get_reporting_product(
                                  p_api_version           => l_api_version,
           		 	              p_init_msg_list         => p_init_msg_list,
           			              x_return_status         => l_return_status,
           			              x_msg_count             => x_msg_count,
           			              x_msg_data              => x_msg_data,
                                  p_contract_id 		  => p_khr_id,
                                  x_rep_product           => lx_rep_product,
								  x_rep_product_id        => lx_rep_product_id,
								  x_rep_deal_type         => lx_rep_deal_type);

      IF    (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    	RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

	/*  --Check the secondary_rep_method
      OPEN  l_sec_rep_method_csr ;
      FETCH l_sec_rep_method_csr INTO l_sec_rep_method;
      IF l_sec_rep_method_csr%NOTFOUND THEN
     	  okl_api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_NO_SEC_REP_METHOD' --> seed this ''Secondary rep method cursor did not return any records''
                                  );
          RAISE okl_api.g_exception_error;
      END IF;
	  CLOSE l_sec_rep_method_csr ;
	*/
	  --------------sechawla 09-mar-09 : MG Impact on Investor Agreement end --------------


      IF l_contracts_csr.deal_type = 'LEASEOP' THEN -- deal type of primary product of the contract
         OKL_STREAMS_UTIL.get_primary_stream_type
         (
           p_khr_id => l_contracts_csr.khr_id,
           p_primary_sty_purpose => l_investor_rental_accrual,
           x_return_status => l_return_status,
            x_primary_sty_id => l_sty_id
         );
         IF l_return_status <> 'S' THEN
            okl_api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                                p_token1       => 'STREAM_NAME',
                                p_token1_value => l_investor_rental_accrual);
            RAISE okl_api.g_exception_error;
         END IF;
          -- calculate total revenue share
          FOR get_revenue_share_rec IN get_revenue_share_csr(l_inv_id, 'RENT') LOOP
              l_revenue_share := l_revenue_share + get_revenue_share_rec.percent_stake;
          END LOOP;
          IF l_revenue_share IS NULL OR
             l_revenue_share = 0 THEN
            -- store SQL error message on message stack for caller
            okl_api.set_message(p_app_name => g_app_name,
                                p_msg_name => 'OKL_ASC_REV_SHARE_ERROR');
            RAISE okl_api.G_EXCEPTION_ERROR;
          END IF;
          stream_type_purpose := l_rental_accrual; ---- Rental Accrual for primary product
			 -- sechawla : This is the 'Rental Accrual' stream, generated when OP lease contract is first Booked
			 -- sechawla : This stream is used to generate Investor Rental Accrual Stream, upon rebook

		  --------------sechawla 09-mar-09 : MG Impact on Investor Agreement begin ----
		  ---generate Investor Rental Accrual / Pre Tax Income streams for reporting product
          --IF lx_rep_product IS NOT NULL AND l_sec_rep_method = 'AUTOMATED' THEN
          IF lx_rep_product IS NOT NULL  THEN
                IF    lx_rep_deal_type = 'LEASEOP' THEN
                      OKL_STREAMS_UTIL.get_primary_stream_type_rep
             			(
               				p_khr_id => l_contracts_csr.khr_id,
               				p_primary_sty_purpose => l_investor_rental_accrual,
			   				--sechawla : INVESTOR_RENTAL_ACCRUAL is the primary stream type purpose on the SGT of reporing product(OP lease)
			   				--sechawla : Investor Arental Accrual stream is generated upon rebook
               				x_return_status => l_return_status,
               				x_primary_sty_id => l_rep_sty_id
             			);
             		   IF l_return_status <> 'S' THEN
               			   okl_api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR_REP', --> seed this
                                  p_token1       => 'STREAM_NAME',
                                  p_token1_value => l_investor_rental_accrual);
               			   RAISE okl_api.g_exception_error;

             		   END IF;

             		   rep_stream_type_purpose := l_rental_accrual; -- Rental Accrual for reporting product
             		   --Rental Accrual stream is also generated for the reporting product (if OP Lease), when contract
             		   --is Booked. This stream is used to generate Investor Rental Accrual Stream for reporting product, upon rebook
                ELSIF lx_rep_deal_type IN ('LEASEDF', 'LEASEST') THEN
                       OKL_STREAMS_UTIL.get_primary_stream_type_rep
             			(
               				p_khr_id => l_contracts_csr.khr_id,
               				p_primary_sty_purpose => l_investor_pre_tax_income,
               				--INVESTOR_PRE_TAX_INCOME is the primary stream type purpose on the SGT of reporting product (DF/ST)
			   				--Investor Pre Tax Income stream is generated upon rebook
               				x_return_status => l_return_status,
               				x_primary_sty_id => l_rep_sty_id
             			);

              			IF l_return_status <> 'S' THEN
                 			okl_api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR_REP', --> seed this
                                     p_token1       => 'STREAM_NAME',
                                     p_token1_value => l_investor_pre_tax_income);
                 			RAISE okl_api.g_exception_error;
              			END IF;

              			rep_stream_type_purpose := l_pre_tax_income; -- Pre Tax Income for reporting product
              			--Pre Tax income stream is also generated for the reporting product (if DF/ST Lease), when contract
             		    --is Booked. This stream is used to generate Investor Pre Tax Income Stream for reporting product, upon rebook
                END IF;
          END IF;
          --------------sechawla 09-mar-09 : MG Impact on Investor Agreement end -----


       ELSIF l_contracts_csr.deal_type IN ('LEASEDF', 'LEASEST') THEN -- deal type of primary product of the contract
          OKL_STREAMS_UTIL.get_primary_stream_type
          (
             p_khr_id => l_contracts_csr.khr_id,
             p_primary_sty_purpose => l_investor_pre_tax_income,
             --INVESTOR_PRE_TAX_INCOME is the primary stream type purpose on the SGT of DF/ST lease contract
			 --Investor Pre Tax Income stream is generated upon rebook
             x_return_status => l_return_status,
             x_primary_sty_id => l_sty_id
          );
          IF l_return_status <> 'S' THEN
             okl_api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                              p_token1       => 'STREAM_NAME',
                              p_token1_value => l_investor_pre_tax_income);
             RAISE okl_api.g_exception_error;
          END IF;
          -- calculate total revenue share
          FOR get_revenue_share_rec IN get_revenue_share_csr(l_inv_id, 'RENT') LOOP
              l_revenue_share := l_revenue_share + get_revenue_share_rec.percent_stake;
          END LOOP;
          IF l_revenue_share IS NULL OR
             l_revenue_share = 0 THEN
            -- store SQL error message on message stack for caller
            okl_api.set_message(p_app_name => g_app_name,
                                p_msg_name => 'OKL_ASC_REV_SHARE_ERROR');
            RAISE okl_api.G_EXCEPTION_ERROR;
          END IF;
          stream_type_purpose := l_pre_tax_income;--Pre Tax Income for Primary product
             -- sechawla : This is the 'Pre Tax Income' stream, generated when DF/ST lease contract is Booked
     		 -- sechawla : This stream is used to generate Investor Pre Tax Income Stream, upon rebook

		  --------------sechawla 09-mar-09 : MG Impact on Investor Agreement begin ----
		  ---generate Investor Rental Accrual / Pre Tax Income streams for reporting product
         -- IF lx_rep_product IS NOT NULL AND l_sec_rep_method = 'AUTOMATED' THEN
          IF lx_rep_product IS NOT NULL  THEN
                IF    lx_rep_deal_type = 'LEASEOP' THEN
                      OKL_STREAMS_UTIL.get_primary_stream_type_rep
             			(
               				p_khr_id => l_contracts_csr.khr_id,
               				p_primary_sty_purpose => l_investor_rental_accrual,
			   				--sechawla : INVESTOR_RENTAL_ACCRUAL is the primary stream type purpose on the SGT of reporing product(OP lease)
			   				--sechawla : Investor Arental Accrual stream is generated upon rebook
               				x_return_status => l_return_status,
               				x_primary_sty_id => l_rep_sty_id
             			);
             		   IF l_return_status <> 'S' THEN
               			   okl_api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR_REP', --> seed this
                                  p_token1       => 'STREAM_NAME',
                                  p_token1_value => l_investor_rental_accrual);
               			   RAISE okl_api.g_exception_error;

             		   END IF;

             		   rep_stream_type_purpose := l_rental_accrual; -- Rental Accrual for reporting product
             		   --Rental Accrual stream is generated for the reporting product (if OP Lease), when contract
             		   --is Booked. This stream is used to generate Investor Rental Accrual Stream for reporting product, upon IA activation
                ELSIF lx_rep_deal_type IN ('LEASEDF', 'LEASEST') THEN
                       OKL_STREAMS_UTIL.get_primary_stream_type_rep
             			(
               				p_khr_id => l_contracts_csr.khr_id,
               				p_primary_sty_purpose => l_investor_pre_tax_income,
               				--INVESTOR_PRE_TAX_INCOME is the primary stream type purpose on the SGT of reporting product (DF/ST)
			   				--Investor Pre Tax Income stream is generated upon rebook
               				x_return_status => l_return_status,
               				x_primary_sty_id => l_rep_sty_id
             			);

              			IF l_return_status <> 'S' THEN
                 			okl_api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR_REP', --> seed this
                                     p_token1       => 'STREAM_NAME',
                                     p_token1_value => l_investor_pre_tax_income);
                 			RAISE okl_api.g_exception_error;
              			END IF;

              			rep_stream_type_purpose := l_pre_tax_income; -- Pre Tax Income for reporting product
              			--Pre Tax income stream is also generated for the reporting product (if DF/ST Lease), when contract
             		    --is Booked. This stream is used to generate Investor Pre Tax Income Stream for reporting product, upon rebook
                END IF;
          END IF;
          --------------sechawla 09-mar-09 : MG Impact on Investor Agreement end -----

 /* ankushar , 25-01-2008 Bug 6773285
    End Changes
  */

/* ankushar , 16-01-2008 Bug 6740000
   Added condition for fetching stream type for a Loan product
   Start Changes
*/
       ---sechawla 09-mar-09 : MG Impact on Investor Agreement : No impacts on Loans
       ELSIF l_contracts_csr.deal_type IN ('LOAN', 'LOAN-REVOLVING') THEN
          OKL_STREAMS_UTIL.get_primary_stream_type
          (
            p_khr_id => l_contracts_csr.khr_id,
            p_primary_sty_purpose => l_inv_interest_income_accrual,
            x_return_status => l_return_status,
            x_primary_sty_id => l_sty_id
          );
          IF l_return_status <> 'S' THEN
             okl_api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                            p_token1       => 'STREAM_NAME',
                            p_token1_value => l_inv_interest_income_accrual);
             RAISE okl_api.g_exception_error;
          END IF;
          -- calculate total revenue share
          FOR get_revenue_share_rec IN get_revenue_share_csr(l_inv_id, 'LOAN_PAYMENT') LOOP
            l_revenue_share := l_revenue_share + get_revenue_share_rec.percent_stake;
          END LOOP;
          IF l_revenue_share IS NULL OR
             l_revenue_share = 0 THEN
            -- store SQL error message on message stack for caller
            okl_api.set_message(p_app_name => g_app_name,
                                p_msg_name => 'OKL_ASC_REV_SHARE_ERROR');
            RAISE okl_api.G_EXCEPTION_ERROR;
          END IF;
         stream_type_purpose := l_interest_income;
/* ankushar , 16-01-2008 Bug 6691554
   End Changes
*/
      END IF;

      --Populate streams structure for primary product
      SELECT okl_sif_seq.NEXTVAL INTO l_trx_number FROM dual;
      -- populate stream header record
      l_stmv_rec.sty_id := l_sty_id;
      l_stmv_rec.khr_id := l_contracts_csr.khr_id;
      l_stmv_rec.sgn_code := 'MANL';
      l_stmv_rec.say_code := 'WORK';

      l_stmv_rec.transaction_number := l_trx_number;
      l_stmv_rec.active_yn := 'N';

      l_stmv_rec.date_working :=  l_sysdate;
      -- create final l_stmt
      --l_stmt := l_stmt || l_where;
      --OPEN strm_csr FOR l_stmt;


      ---------------sechawla 09-mar-09 : MG Impact on Investor Agreement : begin ------------
      IF l_rep_sty_id IS NOT NULL THEN
          		--Populate streams structure for reporting product
          		SELECT okl_sif_seq.NEXTVAL INTO l_trx_number FROM dual;
          		-- populate stream header record
          		l_rep_stmv_rec.sty_id := l_rep_sty_id;
          		l_rep_stmv_rec.khr_id := l_contracts_csr.khr_id;
          		l_rep_stmv_rec.sgn_code := 'MANL';
          		l_rep_stmv_rec.say_code := 'WORK';
          		l_rep_stmv_rec.transaction_number := l_trx_number;
          		l_rep_stmv_rec.active_yn := 'N';
          		l_rep_stmv_rec.purpose_code := 'REPORT';
          		l_rep_stmv_rec.date_current :=  l_sysdate;
          	--	l_rep_stmv_rec.source_id :=  p_khr_id;
          	--	l_rep_stmv_rec.source_table := 'OKL_K_HEADERS';
     END IF;
     -----------------sechawla 09-mar-09 : MG Impact on Investor Agreement : end ------------

	 --Create stream element structure for primary product
      -- use of a parameterized cursor by zrehman on 12-Sep-2006
      OPEN strm_csr(l_contracts_csr.khr_id, l_final_start_date, l_contracts_csr.end_date, stream_type_purpose);
      LOOP
        --re-initialize period end date
        l_period_end_date := NULL;
        FETCH strm_csr INTO l_elements;
        EXIT WHEN strm_csr%NOTFOUND;
        l_period_end_date := trunc(last_day(l_elements.stream_element_date));
        --populate stream elements tbl
        -- manipulate first record
        IF strm_csr%ROWCOUNT = 1 THEN

       -- If start date is last day of the month, do nothing.
          IF TRUNC(l_final_start_date) <> TRUNC(LAST_DAY(l_final_start_date)) THEN
          -- If start date is the same as first day of the month then take whole amount.
            IF TRUNC(l_final_start_date) = TRUNC((ADD_MONTHS(LAST_DAY(l_final_start_date), -1) + 1)) THEN
              l_selv_tbl(l_counter).amount := ROUND((l_elements.amount*l_revenue_share/100),2);
              l_selv_tbl(l_counter).stream_element_date := l_period_end_date;
              l_selv_tbl(l_counter).se_line_number := l_line_number;
              l_line_number := l_line_number + 1;
              l_counter := l_counter + 1;
            ELSE
              -- start date is not first or last day of the month. so prorate.
              l_difference := ABS(TRUNC(l_elements.stream_element_date) - TRUNC(l_final_start_date));
              l_selv_tbl(l_counter).amount := ROUND((((l_difference/30)*l_elements.amount)*l_revenue_share/100),2);
              l_selv_tbl(l_counter).stream_element_date := l_period_end_date;
              l_selv_tbl(l_counter).se_line_number := l_line_number;
              l_line_number := l_line_number + 1;
              l_counter := l_counter + 1;
            END IF;
          END IF;
        ELSE
          l_selv_tbl(l_counter).amount := ROUND((l_elements.amount*l_revenue_share/100),2);
          l_selv_tbl(l_counter).stream_element_date := l_period_end_date;
          l_selv_tbl(l_counter).se_line_number := l_line_number;
          l_line_number := l_line_number + 1;
          l_counter := l_counter + 1;
        END IF;
      END LOOP;
      CLOSE strm_csr;
      IF l_selv_tbl.COUNT > 0 THEN
        -- call streams api
        okl_streams_pub.create_streams(
                        p_api_version    => p_api_version,
                        p_init_msg_list  => p_init_msg_list,
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data,
                        p_stmv_rec       => l_stmv_rec,
                        p_selv_tbl       => l_selv_tbl,
                        x_stmv_rec       => x_stmv_rec,
                        x_selv_tbl       => x_selv_tbl);
        IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (x_return_Status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
      END IF;
      ---------------sechawla 09-mar-09 : MG Impact on Investor Agreement : begin ------------
      --Create stream element structure for reporting product
	  OPEN rep_strm_csr(l_contracts_csr.khr_id, l_final_start_date, l_contracts_csr.end_date, rep_stream_type_purpose);
      LOOP
            --re-initialize period end date
            l_period_end_date := NULL;
            FETCH rep_strm_csr INTO l_rep_elements;
            EXIT WHEN rep_strm_csr%NOTFOUND;
            l_period_end_date := trunc(last_day(l_rep_elements.stream_element_date));
            --populate stream elements tbl
            -- manipulate first record
            IF rep_strm_csr%ROWCOUNT = 1 THEN
              -- If start date is last day of the month, do nothing.
              IF TRUNC(l_final_start_date) <> TRUNC(LAST_DAY(l_final_start_date)) THEN
                -- If start date is the same as first day of the month then take whole amount.
                IF TRUNC(l_final_start_date) = TRUNC((ADD_MONTHS(LAST_DAY(l_final_start_date), -1) + 1)) THEN
                  l_rep_selv_tbl(l_rep_counter).amount := ROUND((l_rep_elements.amount*l_revenue_share/100),2);
                  l_rep_selv_tbl(l_rep_counter).stream_element_date := l_period_end_date;
                  l_rep_selv_tbl(l_rep_counter).se_line_number := l_rep_line_number;
                  l_rep_line_number := l_rep_line_number + 1;
                  l_rep_counter := l_rep_counter + 1;
                ELSE
                  -- start date is not first or last day of the month. so prorate.
                  l_difference := ABS(TRUNC(l_rep_elements.stream_element_date) - TRUNC(l_final_start_date));
                  l_rep_selv_tbl(l_rep_counter).amount := ROUND((((l_difference/30)*l_rep_elements.amount)*l_revenue_share/100),2);
                  l_rep_selv_tbl(l_rep_counter).stream_element_date := l_period_end_date;
                  l_rep_selv_tbl(l_rep_counter).se_line_number := l_rep_line_number;
                  l_rep_line_number := l_rep_line_number + 1;
                  l_rep_counter := l_rep_counter + 1;
                END IF;
              END IF;
            ELSE
              l_rep_selv_tbl(l_rep_counter).amount := ROUND((l_rep_elements.amount*l_revenue_share/100),2);
              l_rep_selv_tbl(l_rep_counter).stream_element_date := l_period_end_date;
              l_rep_selv_tbl(l_rep_counter).se_line_number := l_rep_line_number;
              l_rep_line_number := l_rep_line_number + 1;
              l_rep_counter := l_rep_counter + 1;
            END IF;
      END LOOP;
      CLOSE rep_strm_csr;
      IF l_rep_selv_tbl.COUNT > 0 THEN
            -- call streams api
            OKL_STREAMS_PUB.create_streams(
                            p_api_version    => l_api_version
                            ,p_init_msg_list  => p_init_msg_list
                            ,x_return_status  => l_return_status
                            ,x_msg_count      => x_msg_count
                            ,x_msg_data       => x_msg_data
                            ,p_stmv_rec       => l_rep_stmv_rec
                            ,p_selv_tbl       => l_rep_selv_tbl
                            ,x_stmv_rec       => x_rep_stmv_rec
                            ,x_selv_tbl       => x_rep_selv_tbl );
            IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
      END IF;

      ---------------sechawla 09-mar-09 : MG Impact on Investor Agreement : end ---------------

      --call link api

      --sechawla 09-mar-09 : MG Impact on Investor Agreement : Modified API below to update reporting
      --Investor streams created during rebook, with trx_id and link_hist_stream_id
      OKL_CONTRACT_REBOOK_PVT.link_inv_accrual_streams(
                               p_api_version    => p_api_version
                               ,p_init_msg_list  => p_init_msg_list
                               ,x_return_status  => l_return_status
                               ,x_msg_count      => x_msg_count
                               ,x_msg_data       => x_msg_data
                               ,p_khr_id         =>l_contracts_csr.khr_id
                            );
       IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                  RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;

       -- Update the status of primary streams from 'CURR' to 'HIST'

       j:=0;
       l_id_tbl.delete;

       FOR  stream_id_rec IN  stream_id_csr(p_khr_id => l_contracts_csr.khr_id
                                                 ,p_sty_id=>l_sty_id
                                                 ,p_say_code=>'CURR'
												 , p_purpose_code => Null)
       LOOP
               j := j + 1;
                   l_id_tbl(j)  :=stream_id_rec.id;
       END LOOP;

        IF (l_id_tbl.COUNT > 0) THEN

              BEGIN

                    FORALL i IN l_id_tbl.FIRST..l_id_tbl.LAST
                             UPDATE OKL_STREAMS
                              SET         say_code = 'HIST',
                       active_yn = 'N',
                              date_history = sysdate
                       WHERE         ID = l_id_tbl(i);

                      EXCEPTION
                              WHEN OTHERS THEN
                             okl_api.set_message (p_app_name     => G_APP_NAME,
                                      p_msg_name     => G_DB_ERROR,
                                      p_token1       => G_PROG_NAME_TOKEN,
                                      p_token1_value => l_api_name,
                                      p_token2       => G_SQLCODE_TOKEN,
                                      p_token2_value => sqlcode,
                                      p_token3       => G_SQLERRM_TOKEN,
                                      p_token3_value => sqlerrm);
                  l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
                          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               END;
       END IF;

      ---------------sechawla 09-mar-09 : MG Impact on Investor Agreement : begin
      --update the status of reporting streams from 'CURR' to 'HIST'

       j:=0;
       l_rep_id_tbl.delete;

       FOR  stream_id_rec IN  stream_id_csr(p_khr_id => l_contracts_csr.khr_id
                                                 ,p_sty_id=>l_rep_sty_id
                                                 ,p_say_code=>'CURR'
												 ,p_purpose_code =>'REPORT')
       LOOP
               j := j + 1;
                   l_rep_id_tbl(j)  :=stream_id_rec.id;
       END LOOP;

          IF (l_rep_id_tbl.COUNT > 0) THEN

              BEGIN

                    FORALL i IN l_rep_id_tbl.FIRST..l_rep_id_tbl.LAST
                             UPDATE OKL_STREAMS
                              SET   say_code = 'HIST',
                       				active_yn = 'N',
                              		date_history = sysdate
                       		  WHERE ID = l_rep_id_tbl(i);

                      EXCEPTION
                              WHEN OTHERS THEN
                             okl_api.set_message (p_app_name     => G_APP_NAME,
                                      p_msg_name     => G_DB_ERROR,
                                      p_token1       => G_PROG_NAME_TOKEN,
                                      p_token1_value => l_api_name,
                                      p_token2       => G_SQLCODE_TOKEN,
                                      p_token2_value => sqlcode,
                                      p_token3       => G_SQLERRM_TOKEN,
                                      p_token3_value => sqlerrm);
                  l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
                          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               END;
       END IF;
       ---------------sechawla 09-mar-09 : MG Impact on Investor Agreement : end

      --------------------------------------------
       -- Update the status of 'WORK' to 'CURR' for primary streams
       ----------------------------------
       j:=0;
       l_id_tbl.delete;
       FOR  stream_id_rec IN  stream_id_csr(p_khr_id => l_contracts_csr.khr_id
                                                 ,p_sty_id=>l_sty_id
                                                 ,p_say_code=>'WORK'
												 ,p_purpose_code => Null)
         LOOP
               j := j + 1;
                   l_id_tbl(j)  :=stream_id_rec.id;
         END LOOP;

          IF (l_id_tbl.COUNT > 0) THEN

              BEGIN

                    FORALL i IN l_id_tbl.FIRST..l_id_tbl.LAST
                             UPDATE OKL_STREAMS
                              SET         say_code = 'CURR',
                       active_yn = 'Y',
                              date_current = sysdate
                       WHERE         ID = l_id_tbl(i);

                      EXCEPTION
                              WHEN OTHERS THEN
                             okl_api.set_message (p_app_name     => G_APP_NAME,
                                      p_msg_name     => G_DB_ERROR,
                                      p_token1       => G_PROG_NAME_TOKEN,
                                      p_token1_value => l_api_name,
                                      p_token2       => G_SQLCODE_TOKEN,
                                      p_token2_value => sqlcode,
                                      p_token3       => G_SQLERRM_TOKEN,
                                      p_token3_value => sqlerrm);
                  l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
                          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               END;
       END IF;



         ---------------sechawla 09-mar-09 : MG Impact on Investor Agreement
         --------------------------------------------
         -- Update the status of 'WORK' to 'CURR' for secondary streams
         ----------------------------------
         j:=0;
         l_rep_id_tbl.delete;
         FOR  stream_id_rec IN  stream_id_csr(p_khr_id => l_contracts_csr.khr_id
                                                 ,p_sty_id=>l_rep_sty_id
                                                 ,p_say_code=>'WORK'
												 ,p_purpose_code => 'REPORT')
         LOOP
               j := j + 1;
                   l_rep_id_tbl(j)  :=stream_id_rec.id;
         END LOOP;

          IF (l_rep_id_tbl.COUNT > 0) THEN

              BEGIN

                    FORALL i IN l_rep_id_tbl.FIRST..l_rep_id_tbl.LAST
                             UPDATE OKL_STREAMS
                              SET    say_code = 'CURR',
                                     active_yn = 'N',
                                     date_current = sysdate
                             WHERE   ID = l_rep_id_tbl(i);

                      EXCEPTION
                              WHEN OTHERS THEN
                             okl_api.set_message (p_app_name     => G_APP_NAME,
                                      p_msg_name     => G_DB_ERROR,
                                      p_token1       => G_PROG_NAME_TOKEN,
                                      p_token1_value => l_api_name,
                                      p_token2       => G_SQLCODE_TOKEN,
                                      p_token2_value => sqlcode,
                                      p_token3       => G_SQLERRM_TOKEN,
                                      p_token3_value => sqlerrm);
                  l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
                          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               END;
         END IF;




    EXCEPTION
        WHEN okl_api.g_exception_error THEN
          IF contract_number_csr%ISOPEN THEN
            CLOSE contract_number_csr;
          END IF;
          IF get_kle_id_csr%ISOPEN THEN
            CLOSE get_kle_id_csr;
          END IF;
          IF get_adv_arr_csr%ISOPEN THEN
            CLOSE get_adv_arr_csr;
          END IF;
          IF get_sty_id_csr%ISOPEN THEN
            CLOSE get_sty_id_csr;
          END IF;
          IF strm_csr%ISOPEN THEN
            CLOSE strm_csr;
          END IF;
          x_return_status := okl_api.handle_exceptions(l_api_name,
                                                       g_pkg_name,
                                                       'OKL_API.G_RET_STS_ERROR',
                                                       x_msg_count,
                                                       x_msg_data,
                                                       '_PVT');
        WHEN okl_api.g_exception_unexpected_error THEN
          IF contract_number_csr%ISOPEN THEN
            CLOSE contract_number_csr;
          END IF;
          IF get_kle_id_csr%ISOPEN THEN
            CLOSE get_kle_id_csr;
          END IF;
          IF get_adv_arr_csr%ISOPEN THEN
            CLOSE get_adv_arr_csr;
          END IF;
          IF get_sty_id_csr%ISOPEN THEN
            CLOSE get_sty_id_csr;
          END IF;
          IF strm_csr%ISOPEN THEN
            CLOSE strm_csr;
          END IF;
          x_return_status := okl_api.handle_exceptions(l_api_name,
                                                       g_pkg_name,
                                                       'OKL_API.G_RET_STS_UNEXP_ERROR',
                                                       x_msg_count,
                                                       x_msg_data,
                                                       '_PVT');
        WHEN OTHERS THEN
          IF contract_number_csr%ISOPEN THEN
            CLOSE contract_number_csr;
          END IF;
          IF get_kle_id_csr%ISOPEN THEN
            CLOSE get_kle_id_csr;
          END IF;
          IF get_adv_arr_csr%ISOPEN THEN
            CLOSE get_adv_arr_csr;
          END IF;
          IF get_sty_id_csr%ISOPEN THEN
            CLOSE get_sty_id_csr;
          END IF;
          IF strm_csr%ISOPEN THEN
            CLOSE strm_csr;
          END IF;
          x_return_status := okl_api.handle_exceptions(l_api_name,
                                                       g_pkg_name,
                                                       'OTHERS',
                                                       x_msg_count,
                                                       x_msg_data,
                                                       '_PVT');
      END;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF contract_number_csr%ISOPEN THEN
        CLOSE contract_number_csr;
      END IF;
      IF get_kle_id_csr%ISOPEN THEN
        CLOSE get_kle_id_csr;
      END IF;
      IF get_adv_arr_csr%ISOPEN THEN
        CLOSE get_adv_arr_csr;
      END IF;
      IF get_sty_id_csr%ISOPEN THEN
        CLOSE get_sty_id_csr;
      END IF;
      IF securitized_contracts_csr%ISOPEN THEN
        CLOSE securitized_contracts_csr;
      END IF;
      IF get_revenue_share_csr%ISOPEN THEN
        CLOSE get_revenue_share_csr;
      END IF;
      IF get_inv_csr%ISOPEN THEN
        CLOSE get_inv_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF contract_number_csr%ISOPEN THEN
        CLOSE contract_number_csr;
      END IF;
      IF get_kle_id_csr%ISOPEN THEN
        CLOSE get_kle_id_csr;
      END IF;
      IF get_adv_arr_csr%ISOPEN THEN
        CLOSE get_adv_arr_csr;
      END IF;
      IF get_sty_id_csr%ISOPEN THEN
        CLOSE get_sty_id_csr;
      END IF;
      IF securitized_contracts_csr%ISOPEN THEN
        CLOSE securitized_contracts_csr;
      END IF;
      IF get_revenue_share_csr%ISOPEN THEN
        CLOSE get_revenue_share_csr;
      END IF;
      IF get_inv_csr%ISOPEN THEN
        CLOSE get_inv_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      IF contract_number_csr%ISOPEN THEN
        CLOSE contract_number_csr;
      END IF;
      IF get_kle_id_csr%ISOPEN THEN
        CLOSE get_kle_id_csr;
      END IF;
      IF get_adv_arr_csr%ISOPEN THEN
        CLOSE get_adv_arr_csr;
      END IF;
      IF get_sty_id_csr%ISOPEN THEN
        CLOSE get_sty_id_csr;
      END IF;
      IF securitized_contracts_csr%ISOPEN THEN
        CLOSE securitized_contracts_csr;
      END IF;
      IF get_revenue_share_csr%ISOPEN THEN
        CLOSE get_revenue_share_csr;
      END IF;
      IF get_inv_csr%ISOPEN THEN
        CLOSE get_inv_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END create_lease_streams;
--------------------------------------------------------------------------------
  PROCEDURE CREATE_STREAMS(p_api_version    IN  NUMBER,
                           p_init_msg_list   IN  VARCHAR2,
                           x_return_status   OUT NOCOPY VARCHAR2,
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2,
                           p_khr_id          IN NUMBER,
--sosharma added Bug 6691554, Added for generating streams on transient pool submission
                           p_mode             IN VARCHAR2 DEFAULT NULL)
  IS

    l_count                      NUMBER := 1;
    l_api_version                CONSTANT NUMBER := 1.0;
    l_api_name                   CONSTANT VARCHAR2(30) := 'CREATE_STREAMS';
    l_init_msg_list              VARCHAR2(4000) := OKL_API.G_FALSE;
    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    l_period_end_date            DATE;
    l_total_records              NUMBER;
    l_sysdate                    DATE := TRUNC(SYSDATE);
    l_trx_number                 NUMBER;
    l_revenue_share              NUMBER := 0;
    l_sty_id                     NUMBER;

    stream_type_purpose            VARCHAR2(30);
    l_khr_num                    OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE := NULL;
    l_scs_code                   OKC_K_HEADERS_B.SCS_CODE%TYPE := NULL;
/*
    l_investor_rental_accrual    CONSTANT VARCHAR2(2000) := 'INVESTOR RENTAL ACCRUAL';
    l_investor_pre_tax_income    CONSTANT VARCHAR2(2000) := 'INVESTOR PRE-TAX INCOME';
    l_investor_interest_income   CONSTANT VARCHAR2(2000) := 'INVESTOR INTEREST INCOME';
    l_investor_variable_interest CONSTANT VARCHAR2(2000) := 'INVESTOR VARIABLE INTEREST';
    l_rental_accrual             CONSTANT VARCHAR2(2000) := 'RENTAL ACCRUAL';
    l_pre_tax_income             CONSTANT VARCHAR2(2000) := 'PRE-TAX INCOME';
    l_interest_income            CONSTANT VARCHAR2(2000) := 'INTEREST INCOME';
    l_variable_income            CONSTANT VARCHAR2(2000) := 'VARIABLE INCOME ACCRUAL';
*/
    l_investor_rental_accrual      CONSTANT VARCHAR2(2000) := 'INVESTOR_RENTAL_ACCRUAL';
    l_investor_pre_tax_income      CONSTANT VARCHAR2(2000) := 'INVESTOR_PRETAX_INCOME';
    l_investor_interest_income     CONSTANT VARCHAR2(2000) := 'GENERAL';
    l_investor_variable_interest   CONSTANT VARCHAR2(2000) := 'INVESTOR_VARIABLE_INTEREST';
    l_rental_accrual               CONSTANT VARCHAR2(2000) := 'RENT_ACCRUAL';
    l_pre_tax_income               CONSTANT VARCHAR2(2000) := 'LEASE_INCOME';
    l_interest_income              CONSTANT VARCHAR2(2000) := 'INTEREST_INCOME';
    l_variable_income              CONSTANT VARCHAR2(2000) := 'ACCOUNTING';
 /* ankushar , 16-01-2008 Bug 6740000
    Added new Stream Type purpose for a Loan product
  */
    l_inv_interest_income_accrual         CONSTANT VARCHAR2(2000) := 'INVESTOR_INTEREST_INCOME';

/* ankushar , 16-01-2008 Bug 6740000
   Modified cursors to fetch based on stream type for a Loan product
   Start Changes
*/
    -- cursor to select contracts belonging to a pool(investor agreement)
    CURSOR securitized_contracts_csr (p_inv_id NUMBER)
    IS
    SELECT DISTINCT opc.khr_id khr_id,
           opc.streams_to_date end_date,
           khr.deal_type deal_type
    FROM OKL_POOL_CONTENTS opc,
         OKL_POOLS op,
         OKL_K_HEADERS khr,
         OKL_STRM_TYPE_B stytl
    WHERE op.khr_id = p_inv_id
    AND op.id = opc.pol_id
    AND opc.khr_id = khr.id
    AND opc.sty_id = stytl.id
    --AND stytl.code = 'RENT'
	AND stytl.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
    AND   opc.status_code IN (Okl_Pool_Pvt.G_POC_STS_ACTIVE, Okl_Pool_Pvt.G_POC_STS_NEW)
    GROUP BY opc.khr_id, opc.streams_from_date, opc.streams_to_date, khr.deal_type;

    -- cursor to get first kle_id and earliest stream element date
    CURSOR get_kle_id_csr(p_khr_id NUMBER)
    IS
    SELECT opc.kle_id kle_id,
           MIN(opc.streams_from_date) start_date
    FROM OKL_POOL_CONTENTS opc,
         OKL_STRM_TYPE_B sty
    WHERE opc.khr_id = p_khr_id
    AND opc.sty_id = sty.id
    --AND sty.code = 'RENT'
	AND sty.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
    AND    opc.status_code IN (Okl_Pool_Pvt.G_POC_STS_ACTIVE, Okl_Pool_Pvt.G_POC_STS_NEW)
    AND ROWNUM < 2
    GROUP BY opc.kle_id;

/* sosharma ,14-12-2007
Bug 6691554
Cursors to pick up pools contents in pending status
Start Changes*/

    CURSOR securitized_contracts_pend_csr (p_inv_id NUMBER)
    IS
    SELECT DISTINCT opc.khr_id khr_id,
           opc.streams_to_date end_date,
           khr.deal_type deal_type
    FROM OKL_POOL_CONTENTS opc,
         OKL_POOLS op,
         OKL_K_HEADERS khr,
         OKL_STRM_TYPE_B stytl
    WHERE op.khr_id = p_inv_id
    AND op.id = opc.pol_id
    AND opc.khr_id = khr.id
    AND opc.sty_id = stytl.id
    --AND stytl.code = 'RENT'
	AND stytl.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
    AND   opc.status_code = G_PC_STS_PENDING  --Okl_Pool_Pvt.G_POC_STS_PENDING
    GROUP BY opc.khr_id, opc.streams_from_date, opc.streams_to_date, khr.deal_type;

    -- cursor to get first kle_id and earliest stream element date
    CURSOR get_kle_id_pend_csr(p_khr_id NUMBER)
    IS
    SELECT opc.kle_id kle_id,
           MIN(opc.streams_from_date) start_date
    FROM OKL_POOL_CONTENTS opc,
         OKL_STRM_TYPE_B sty
    WHERE opc.khr_id = p_khr_id
    AND opc.sty_id = sty.id
    --AND sty.code = 'RENT'
	AND sty.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
    AND    opc.status_code = G_PC_STS_PENDING --Okl_Pool_Pvt.G_POC_STS_PENDING
    AND ROWNUM < 2
    GROUP BY opc.kle_id;

/* sosharma end changes*/

    -- cursor to get advance/arrears and frequency for rent stream type
    CURSOR get_adv_arr_csr(p_khr_id NUMBER, p_kle_id NUMBER)
    IS
    SELECT decode(sll.rule_information10, NULL, 'N', 'Y', 'Y', 'N') arrears_yn,
           decode(sll.object1_id1, 'A',12,'S',6,'Q',3,'M',1) frequency
    FROM OKC_K_HEADERS_B K,
         OKC_RULE_GROUPS_B RG,
         OKC_RULES_B SLH,
         OKC_RULES_B SLL,
         OKL_STRM_TYPE_B STRM
    WHERE slh.rule_information_category = 'LASLH'
    AND slh.rgp_id = rg.id
    AND sll.object2_id1 = to_char(slh.id)
    AND sll.rgp_id = rg.id
    AND slh.object1_id1 = to_char(strm.id)
    --AND strm.code = 'RENT'
	AND strm.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
    AND rg.dnz_chr_id = k.id
    AND rg.chr_id IS NULL
    AND rg.rgd_code = 'LALEVL'
    AND rg.cle_id = p_kle_id
    AND k.id = p_khr_id;

    -- cursor to get stream type id
    CURSOR get_sty_id_csr (p_sty_name VARCHAR2)
    IS
    SELECT id
    FROM OKL_STRM_TYPE_B
    WHERE code = p_sty_name;

    -- list of all investors for the agreement
    CURSOR get_investors_csr(p_khr_id IN NUMBER)
    IS
    SELECT clet.id id
    FROM OKC_K_LINES_B clet
         ,OKC_LINE_STYLES_B lseb
    WHERE clet.dnz_chr_id = p_khr_id
    AND clet.lse_id = lseb.id
    AND lseb.lty_code = 'INVESTMENT';

-- ankushar Added stream_type_subclass parameter to the cursor
    -- the revenue shares for the investor
    CURSOR get_revenue_share_csr(p_tl_id NUMBER, p_stream_type_subclass VARCHAR2)
    IS
    SELECT kleb.percent_stake percent_stake
    FROM OKL_K_LINES kleb
         ,OKC_K_LINES_B cles
         ,OKC_LINE_STYLES_B lseb
    WHERE kleb.id = cles.id
    AND cles.cle_id = p_tl_id
    AND cles.lse_id = lseb.id
    AND lseb.lty_code = 'REVENUE_SHARE'
    AND kleb.stream_type_subclass = p_stream_type_subclass;

/* ankushar , 16-01-2008 Bug 6740000
   End Changes
*/
    -- cursor to get contract number
    CURSOR contract_number_csr (p_khr_id NUMBER) IS
    SELECT contract_number,
    scs_code
    FROM OKC_K_HEADERS_B
    WHERE id = p_khr_id;

    --sechawla 9-mar-09 MG Impact on IA
    -- Get secondary_rep_method
  /*  CURSOR l_sec_rep_method_csr IS
    SELECT secondary_rep_method
	FROM   okl_sys_acct_opts;
	l_sec_rep_method				 VARCHAR2(30);
*/
	lx_rep_product					 OKL_PRODUCTS_V.NAME%TYPE;
	lx_rep_product_id				 NUMBER;
    lx_rep_deal_type                 okl_product_parameters_v.deal_type%TYPE;
    l_rep_sty_id					 NUMBER;
    rep_stream_type_purpose          VARCHAR2(30);

    l_contracts_csr                  securitized_contracts_csr%ROWTYPE;



    -- declaration of a parameterized cursor by zrehman on 12-Sep-2006
    CURSOR strm_csr (p_khr_id NUMBER,
                    p_final_start_date DATE,
                    p_end_date DATE,
                    p_stream_type_purpose VARCHAR2)
    IS
      select ste.stream_element_date stream_element_date,ste.amount amount
      FROM okl_strm_type_b sty, okl_streams stm, okl_strm_elements ste
      WHERE
      stm.sty_id = sty.id
      AND ste.stm_id = stm.id
      AND stm.active_yn = 'Y'
      AND stm.say_code = 'CURR'
      AND stm.khr_id = p_khr_id
      AND ste.stream_element_date BETWEEN p_final_start_date AND p_end_date
      AND sty.stream_type_purpose = p_stream_type_purpose
      ORDER BY ste.stream_element_date;

    --sechawla 9-mar-09 : MG Impact on IA
    CURSOR rep_strm_csr (p_khr_id NUMBER,
                    p_final_start_date DATE,
                    p_end_date DATE,
                    p_rep_stream_type_purpose VARCHAR2)
    IS
      select ste.stream_element_date stream_element_date,ste.amount amount
      FROM okl_strm_type_b sty, okl_streams stm, okl_strm_elements ste
      WHERE
      stm.sty_id = sty.id
      AND ste.stm_id = stm.id
      AND stm.active_yn = 'N'
      AND stm.say_code = 'CURR'
      AND stm.purpose_code = 'REPORT'
      AND stm.khr_id = p_khr_id
      AND ste.stream_element_date BETWEEN p_final_start_date AND p_end_date
      AND sty.stream_type_purpose = p_rep_stream_type_purpose
      ORDER BY ste.stream_element_date;

  BEGIN
    -- Set save point
    l_return_status := OKL_API.START_ACTIVITY(
                               p_api_name      => l_api_name,
                               p_pkg_name      => G_PKG_NAME,
                               p_init_msg_list => p_init_msg_list,
                               l_api_version   => l_api_version,
                               p_api_version   => p_api_version,
                               p_api_type      => '_PVT',
                               x_return_status => l_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    OPEN contract_number_csr(p_khr_id);
    FETCH contract_number_csr INTO l_khr_num,
                                   l_scs_code;
    CLOSE contract_number_csr;


    IF l_scs_code = 'LEASE' THEN
      -- If the contract is lease contract then we call create_lease_streams
      -- This procedure is called from On-line and Mass Rebook (during activation of rebook)
  	  -- p_khr_id is the contract_id of the original lease contract that is being rebooked.
	  -- This procedure regenerates Investor Accrual streams that are created for the contract, when IA was activated
	  -- Rebook process then compares the old and new Investor accrual streams to calculate Investor accrual adjustment

	  --sechawla 09-mar-09 : MG Impact on Investor Agreement - Modify create_lease_streams to regenerate the
	  --                     Investor Accrual streams upon rebook
      create_lease_streams(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => l_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_khr_id         => p_khr_id,
                           p_mode           => p_mode);
      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
    -- If the contract is Investor contract then we call the below
    ELSIF l_scs_code = 'INVESTOR' THEN
      -- validate in parameters
      IF p_khr_id IS NULL OR
         p_khr_id = OKL_API.G_MISS_NUM THEN
        -- store SQL error message on message stack for caller
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_ASC_KHR_ID_ERROR');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;



    IF p_mode IS NULL THEN --sechawla : This part of the code generates streams for the new IA which is getting activated
      OPEN securitized_contracts_csr (p_khr_id);  --ID of Investor Agreement
      LOOP
         /* sosharma 06-02-2007
         Initilized the local variable l_revenue_share
         Start changes
         */
         l_revenue_share := 0;
         /*
         sosharma end changes
         */
        FETCH securitized_contracts_csr INTO l_contracts_csr;
        EXIT WHEN securitized_contracts_csr%NOTFOUND;
        DECLARE
          TYPE ref_cursor IS REF CURSOR;
          TYPE element_type IS RECORD (stream_element_date DATE, amount NUMBER);
          l_stmv_rec                   OKL_STREAMS_PUB.stmv_rec_type;
          l_selv_tbl                   OKL_STREAMS_PUB.selv_tbl_type;
          x_stmv_rec                   OKL_STREAMS_PUB.stmv_rec_type;
          x_selv_tbl                   OKL_STREAMS_PUB.selv_tbl_type;
          l_difference                 NUMBER := 0;
          l_counter                    NUMBER := 1;
          l_line_number                NUMBER := 1;
          --l_stmt                       VARCHAR2(5000);
          --l_where                      VARCHAR2(2000) := ' ';
          l_kle_id                     NUMBER;
          l_start_date                 DATE;
          l_final_start_date           DATE;
          ln_days                      NUMBER := 0;
          l_arrears                    VARCHAR2(1);
          l_frequency                  NUMBER;
          l_contract_number            VARCHAR2(2000);
          --strm_csr                     ref_cursor;
	      l_elements                   element_type;

	      --sechawla : 9-mar-2009 MG Impact on IA
	      l_rep_stmv_rec               OKL_STREAMS_PUB.stmv_rec_type;
          l_rep_selv_tbl               OKL_STREAMS_PUB.selv_tbl_type;
          x_rep_stmv_rec               OKL_STREAMS_PUB.stmv_rec_type;
          x_rep_selv_tbl               OKL_STREAMS_PUB.selv_tbl_type;
          l_rep_elements               element_type;
          l_rep_line_number            NUMBER := 1;
          l_rep_counter                NUMBER := 1;
        BEGIN
          OPEN contract_number_csr(l_contracts_csr.khr_id);
          FETCH contract_number_csr INTO l_contract_number, l_scs_code; -- Lease contract in the pool
          CLOSE contract_number_csr;

          OPEN get_kle_id_csr(l_contracts_csr.khr_id);
          FETCH get_kle_id_csr INTO l_kle_id, l_start_date;
          CLOSE get_kle_id_csr;

          IF l_kle_id IS NULL OR
             l_kle_id = OKL_API.G_MISS_NUM THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_ASC_KLE_ID_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_contract_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          IF l_start_date IS NULL OR l_start_date = OKL_API.G_MISS_DATE THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_ASC_START_DATE_ERROR');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          OPEN get_adv_arr_csr(l_contracts_csr.khr_id, l_kle_id);
          FETCH get_adv_arr_csr INTO l_arrears, l_frequency;
          CLOSE get_adv_arr_csr;

          IF l_frequency IS NULL THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_ASC_FREQUENCY_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_contract_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          IF l_arrears = 'Y' THEN
            ln_days := okl_stream_generator_pvt.get_day_count (
                                     p_start_date     => ADD_MONTHS(l_start_date, -l_frequency),
                                     p_end_date       => l_start_date,
                                     p_arrears        => l_arrears,
                                     x_return_status  => l_return_status);
            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
              RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_Status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
            END IF;
            l_final_start_date := l_start_date - ln_days;
          ELSIF NVL(l_arrears,'N') = 'N' THEN
            l_final_start_date := l_start_date;
          END IF;

          --------------sechawla 09-mar-09 : MG Impact on Investor Agreement begin--------------
          okl_accounting_util.get_reporting_product(
                                  p_api_version           => l_api_version,
           		 	              p_init_msg_list         => p_init_msg_list,
           			              x_return_status         => l_return_status,
           			              x_msg_count             => x_msg_count,
           			              x_msg_data              => x_msg_data,
                                  p_contract_id 		  => l_contracts_csr.khr_id,
                                  x_rep_product           => lx_rep_product,
								  x_rep_product_id        => lx_rep_product_id,
								  x_rep_deal_type         => lx_rep_deal_type);

          IF    (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    		RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

	  	/*
	  	--Check the secondary_rep_method
      	OPEN  l_sec_rep_method_csr ;
      	FETCH l_sec_rep_method_csr INTO l_sec_rep_method;
      	IF l_sec_rep_method_csr%NOTFOUND THEN
     	  okl_api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_NO_SEC_REP_METHOD' --> seed this ''Secondary rep method cursor did not return any records''
                                  );
          RAISE okl_api.g_exception_error;
      	END IF;
	  	CLOSE l_sec_rep_method_csr ;
	  	*/
	  	--------------sechawla 09-mar-09 : MG Impact on Investor Agreement end --------------



          -- commenting as all accrual streams are generated
          -- at contract level. Will remove comments after super trump fix is provided
          -- for stream generation at asset level.Ref cursor will be needed later.
          --IF l_contracts_csr.deal_type IN ('LEASEOP','LEASEDF','LEASEST') THEN

	  -- SQL Literals Change on 12/09/2006
	  /*l_stmt := 'SELECT ste.stream_element_date stream_element_date
                            ,ste.amount amount
                     FROM OKL_STRM_TYPE_B sty
                          ,OKL_STREAMS stm
                          ,OKL_STRM_ELEMENTS ste
                     WHERE 1 = 1
                     AND stm.sty_id = sty.id
                     AND ste.stm_id = stm.id
                     AND stm.active_yn = '||''''||'Y'||''''||'
                     AND stm.say_code = '||''''||'CURR'||'''' ;
          l_where := l_where || ' AND stm.khr_id = ' || l_contracts_csr.khr_id ||' AND ste.stream_element_date BETWEEN '|| '''' ||l_final_start_date|| '''' ||' AND '|| '''' ||l_contracts_csr.end_date|| ''''; */

 /* ankushar , 25-01-2008 Bug 6773285
    Added code to generate new Stream Types for a Loan product on an Investor Agreement
    Start Changes
  */
          --get sty_id for the contract based on deal type
          IF l_contracts_csr.deal_type = 'LEASEOP' THEN -- deal type of primary product of the contract
             OKL_STREAMS_UTIL.get_primary_stream_type
             (
               p_khr_id => l_contracts_csr.khr_id,
               p_primary_sty_purpose => l_investor_rental_accrual,
			   --sechawla : INVESTOR_RENTAL_ACCRUAL is the primary stream type purpose on the SGT of OP lease contract
			   --sechawla : Investor Arental Accrual stream is generated when IA is activated
               x_return_status => l_return_status,
               x_primary_sty_id => l_sty_id
             );
             IF l_return_status <> 'S' THEN
               okl_api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                                  p_token1       => 'STREAM_NAME',
                                  p_token1_value => l_investor_rental_accrual);
               RAISE okl_api.g_exception_error;

             END IF;

             -- calculate total revenue share
             FOR x IN get_investors_csr(p_khr_id) LOOP
                 FOR y IN get_revenue_share_csr(x.id, 'RENT') LOOP
                     l_revenue_share := l_revenue_share + y.percent_stake;
                 END LOOP;
             END LOOP;

             IF l_revenue_share IS NULL OR l_revenue_share = 0 THEN
             -- store SQL error message on message stack for caller
               Okl_Api.set_message(p_app_name     => g_app_name,
                                   p_msg_name     => 'OKL_ASC_REV_SHARE_ERROR');
               RAISE Okl_Api.G_EXCEPTION_ERROR;
             END IF;
            --Modified by kthiruva on 19-Oct-2005 . The stream type purpose needs to be bound instead
            --of the stream type code
            --Bug 4228708 - Start of Changes
           -- l_where := l_where ||' AND sty.stream_type_purpose = '|| '''' ||l_rental_accrual|| '''' ||' ORDER BY ste.stream_element_date';


             stream_type_purpose := l_rental_accrual; ---- Rental Accrual for primary product
			 -- sechawla : This is the 'Rental Accrual' stream, generated when OP lease contract is Booked
			 -- sechawla : This stream is used to generate Investor Rental Accrual Stream, upon IA activation

			 --------------sechawla 09-mar-09 : MG Impact on Investor Agreement begin ----
			 ---generate Investor Rental Accrual / Pre Tax Income streams for reporting product
            -- IF lx_rep_product IS NOT NULL AND l_sec_rep_method = 'AUTOMATED' THEN
             IF lx_rep_product IS NOT NULL THEN
                IF    lx_rep_deal_type = 'LEASEOP' THEN
                      OKL_STREAMS_UTIL.get_primary_stream_type_rep
             			(
               				p_khr_id => l_contracts_csr.khr_id,
               				p_primary_sty_purpose => l_investor_rental_accrual,
			   				--sechawla : INVESTOR_RENTAL_ACCRUAL is the primary stream type purpose on the SGT of reporing product(OP lease)
			   				--sechawla : Investor Arental Accrual stream is generated when IA is activated
               				x_return_status => l_return_status,
               				x_primary_sty_id => l_rep_sty_id
             			);
             		   IF l_return_status <> 'S' THEN
               			   okl_api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR_REP', --> seed this
                                  p_token1       => 'STREAM_NAME',
                                  p_token1_value => l_investor_rental_accrual);
               			   RAISE okl_api.g_exception_error;

             		   END IF;

             		   rep_stream_type_purpose := l_rental_accrual; -- Rental Accrual for reporting product
             		   --Rental Accrual stream is also generated for the reporting product (if OP Lease), when contract
             		   --is Booked. This stream is used to generate Investor Rental Accrual Stream for reporting product, upon IA activation
                ELSIF lx_rep_deal_type IN ('LEASEDF', 'LEASEST') THEN
                       OKL_STREAMS_UTIL.get_primary_stream_type_rep
             			(
               				p_khr_id => l_contracts_csr.khr_id,
               				p_primary_sty_purpose => l_investor_pre_tax_income,
               				--INVESTOR_PRE_TAX_INCOME is the primary stream type purpose on the SGT of reporting product (DF/ST)
			   				--Investor Pre Tax Income stream is generated when IA is activated
               				x_return_status => l_return_status,
               				x_primary_sty_id => l_rep_sty_id
             			);

              			IF l_return_status <> 'S' THEN
                 			okl_api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR_REP', --> seed this
                                     p_token1       => 'STREAM_NAME',
                                     p_token1_value => l_investor_pre_tax_income);
                 			RAISE okl_api.g_exception_error;
              			END IF;

              			rep_stream_type_purpose := l_pre_tax_income; -- Pre Tax Income for reporting product
              			--Pre Tax income stream is also generated for the reporting product (if DF/ST Lease), when contract
             		    --is Booked. This stream is used to generate Investor Pre Tax Income Stream for reporting product, upon IA activation
                END IF;
             END IF;
             --------------sechawla 09-mar-09 : MG Impact on Investor Agreement end -----


            --Bug 4228708 - End of ChangesB
          ELSIF l_contracts_csr.deal_type IN ('LEASEDF', 'LEASEST') THEN -- deal type of primary product of the contract
             OKL_STREAMS_UTIL.get_primary_stream_type
             (
               p_khr_id => l_contracts_csr.khr_id,
               p_primary_sty_purpose => l_investor_pre_tax_income,
               --INVESTOR_PRE_TAX_INCOME is the primary stream type purpose on the SGT of DF/ST lease contract
			   --Investor Pre Tax Income stream is generated when IA is activated
               x_return_status => l_return_status,
               x_primary_sty_id => l_sty_id
             );

              IF l_return_status <> 'S' THEN
                 okl_api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                                     p_token1       => 'STREAM_NAME',
                                     p_token1_value => l_investor_pre_tax_income);
                 RAISE okl_api.g_exception_error;
              END IF;

             -- calculate total revenue share
             FOR x IN get_investors_csr(p_khr_id) LOOP
                 FOR y IN get_revenue_share_csr(x.id, 'RENT') LOOP
                     l_revenue_share := l_revenue_share + y.percent_stake;
                 END LOOP;
             END LOOP;

             IF l_revenue_share IS NULL OR l_revenue_share = 0 THEN
             -- store SQL error message on message stack for caller
                Okl_Api.set_message(p_app_name     => g_app_name,
                                    p_msg_name     => 'OKL_ASC_REV_SHARE_ERROR');
                RAISE Okl_Api.G_EXCEPTION_ERROR;
             END IF;
             stream_type_purpose := l_pre_tax_income; --Pre Tax Income for Primary product
             -- sechawla : This is the 'Pre Tax Income' stream, generated when DF/ST lease contract is Booked
     		 -- sechawla : This stream is used to generate Investor Pre Tax Income Stream, upon IA activation

     		 --------------sechawla 09-mar-09 : MG Impact on Investor Agreement begin ----
			 ---generate Investor Rental Accrual / Pre Tax Income streams for reporting product
            -- IF lx_rep_product IS NOT NULL AND l_sec_rep_method = 'AUTOMATED' THEN
             IF lx_rep_product IS NOT NULL THEN
                IF    lx_rep_deal_type = 'LEASEOP' THEN
                      OKL_STREAMS_UTIL.get_primary_stream_type_rep
             			(
               				p_khr_id => l_contracts_csr.khr_id,
               				p_primary_sty_purpose => l_investor_rental_accrual,
			   				--sechawla : INVESTOR_RENTAL_ACCRUAL is the primary stream type purpose on the SGT of reporing product(OP lease)
			   				--sechawla : Investor Arental Accrual stream is generated when IA is activated
               				x_return_status => l_return_status,
               				x_primary_sty_id => l_rep_sty_id
             			);
             		   IF l_return_status <> 'S' THEN
               			   okl_api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR_REP', --> seed this
                                  p_token1       => 'STREAM_NAME',
                                  p_token1_value => l_investor_rental_accrual);
               			   RAISE okl_api.g_exception_error;

             		   END IF;

             		   rep_stream_type_purpose := l_rental_accrual; -- Rental Accrual for reporting product
             		   --Rental Accrual stream is generated for the reporting product (if OP Lease), when contract
             		   --is Booked. This stream is used to generate Investor Rental Accrual Stream for reporting product, upon IA activation
                ELSIF lx_rep_deal_type IN ('LEASEDF', 'LEASEST') THEN
                       OKL_STREAMS_UTIL.get_primary_stream_type_rep
             			(
               				p_khr_id => l_contracts_csr.khr_id,
               				p_primary_sty_purpose => l_investor_pre_tax_income,
               				--INVESTOR_PRE_TAX_INCOME is the primary stream type purpose on the SGT of reporting product (DF/ST)
			   				--Investor Pre Tax Income stream is generated when IA is activated
               				x_return_status => l_return_status,
               				x_primary_sty_id => l_rep_sty_id
             			);

              			IF l_return_status <> 'S' THEN
                 			okl_api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR_REP', --> seed this
                                     p_token1       => 'STREAM_NAME',
                                     p_token1_value => l_investor_pre_tax_income);
                 			RAISE okl_api.g_exception_error;
              			END IF;

              			rep_stream_type_purpose := l_pre_tax_income; -- Pre Tax Income for reporting product
              			--Pre Tax income stream is also generated for the reporting product (if DF/ST Lease), when contract
             		    --is Booked. This stream is used to generate Investor Pre Tax Income Stream for reporting product, upon IA activation
                END IF;
             END IF;
             --------------sechawla 09-mar-09 : MG Impact on Investor Agreement end -----

 /* ankushar , 25-01-2008 Bug 6773285
    End Changes
  */
/* ankushar , 16-01-2008 Bug 6740000
   Added condition for fetching stream type for a Loan product
   Start Changes
*/
          ---sechawla 09-mar-09 : MG Impact on Investor Agreement : No impacts on Loans
          ELSIF l_contracts_csr.deal_type IN ('LOAN', 'LOAN-REVOLVING') THEN
             OKL_STREAMS_UTIL.get_primary_stream_type
             (
               p_khr_id => l_contracts_csr.khr_id,
               p_primary_sty_purpose => l_inv_interest_income_accrual,
               x_return_status => l_return_status,
               x_primary_sty_id => l_sty_id
              );
             IF l_return_status <> 'S' THEN
                 okl_api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                                     p_token1       => 'STREAM_NAME',
                                     p_token1_value => l_inv_interest_income_accrual);
                 RAISE okl_api.g_exception_error;
              END IF;

              -- calculate total revenue share
              FOR x IN get_investors_csr(p_khr_id) LOOP
                  FOR y IN get_revenue_share_csr(x.id, 'LOAN_PAYMENT') LOOP
                      l_revenue_share := l_revenue_share + y.percent_stake;
                  END LOOP;
              END LOOP;

              IF l_revenue_share IS NULL OR l_revenue_share = 0 THEN
              -- store SQL error message on message stack for caller
                 Okl_Api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_ASC_REV_SHARE_ERROR');
                 RAISE Okl_Api.G_EXCEPTION_ERROR;
              END IF;

              stream_type_purpose := l_interest_income;
/* ankushar , 16-01-2008 Bug 6740000
   End Changes
*/
          END IF; -- ELSIF

          --Populate streams structure for primary product
          SELECT okl_sif_seq.NEXTVAL INTO l_trx_number FROM dual;
          -- populate stream header record
          l_stmv_rec.sty_id := l_sty_id;
          l_stmv_rec.khr_id := l_contracts_csr.khr_id;
          l_stmv_rec.sgn_code := 'MANL';
          l_stmv_rec.say_code := 'CURR';
          l_stmv_rec.transaction_number := l_trx_number;
          l_stmv_rec.active_yn := 'Y';
          l_stmv_rec.date_current :=  l_sysdate;
          l_stmv_rec.source_id :=  p_khr_id;
          l_stmv_rec.source_table := 'OKL_K_HEADERS';


          ---------------sechawla 09-mar-09 : MG Impact on Investor Agreement : begin ------------
          IF l_rep_sty_id IS NOT NULL THEN
          		--Populate streams structure for reporting product
          		SELECT okl_sif_seq.NEXTVAL INTO l_trx_number FROM dual;
          		-- populate stream header record
          		l_rep_stmv_rec.sty_id := l_rep_sty_id;
          		l_rep_stmv_rec.khr_id := l_contracts_csr.khr_id;
          		l_rep_stmv_rec.sgn_code := 'MANL';
          		l_rep_stmv_rec.say_code := 'CURR';
          		l_rep_stmv_rec.transaction_number := l_trx_number;
          		l_rep_stmv_rec.active_yn := 'N';
          		l_rep_stmv_rec.purpose_code := 'REPORT';
          		l_rep_stmv_rec.date_current :=  l_sysdate;
          		l_rep_stmv_rec.source_id :=  p_khr_id;
          		l_rep_stmv_rec.source_table := 'OKL_K_HEADERS';
         END IF;
         -----------------sechawla 09-mar-09 : MG Impact on Investor Agreement : end ------------


          -- create final l_stmt
          --l_stmt := l_stmt || l_where;
          --OPEN strm_csr FOR l_stmt;
	  -- use of a parameterized cursor by zrehman on 12-Sep-2006
	  --Create stream element structure for primary product
	  OPEN strm_csr(l_contracts_csr.khr_id, l_final_start_date, l_contracts_csr.end_date, stream_type_purpose);
          LOOP
            --re-initialize period end date
            l_period_end_date := NULL;
            FETCH strm_csr INTO l_elements;
            EXIT WHEN strm_csr%NOTFOUND;
            l_period_end_date := trunc(last_day(l_elements.stream_element_date));
            --populate stream elements tbl
            -- manipulate first record
            IF strm_csr%ROWCOUNT = 1 THEN
              -- If start date is last day of the month, do nothing.
              IF TRUNC(l_final_start_date) <> TRUNC(LAST_DAY(l_final_start_date)) THEN
                -- If start date is the same as first day of the month then take whole amount.
                IF TRUNC(l_final_start_date) = TRUNC((ADD_MONTHS(LAST_DAY(l_final_start_date), -1) + 1)) THEN
                  l_selv_tbl(l_counter).amount := ROUND((l_elements.amount*l_revenue_share/100),2);
                  l_selv_tbl(l_counter).stream_element_date := l_period_end_date;
                  l_selv_tbl(l_counter).se_line_number := l_line_number;
                  l_line_number := l_line_number + 1;
                  l_counter := l_counter + 1;
                ELSE
                  -- start date is not first or last day of the month. so prorate.
                  l_difference := ABS(TRUNC(l_elements.stream_element_date) - TRUNC(l_final_start_date));
                  l_selv_tbl(l_counter).amount := ROUND((((l_difference/30)*l_elements.amount)*l_revenue_share/100),2);
                  l_selv_tbl(l_counter).stream_element_date := l_period_end_date;
                  l_selv_tbl(l_counter).se_line_number := l_line_number;
                  l_line_number := l_line_number + 1;
                  l_counter := l_counter + 1;
                END IF;
              END IF;
            ELSE
              l_selv_tbl(l_counter).amount := ROUND((l_elements.amount*l_revenue_share/100),2);
              l_selv_tbl(l_counter).stream_element_date := l_period_end_date;
              l_selv_tbl(l_counter).se_line_number := l_line_number;
              l_line_number := l_line_number + 1;
              l_counter := l_counter + 1;
            END IF;
          END LOOP;
          CLOSE strm_csr;
          IF l_selv_tbl.COUNT > 0 THEN
            -- call streams api
            OKL_STREAMS_PUB.create_streams(
                            p_api_version    => l_api_version
                            ,p_init_msg_list  => l_init_msg_list
                            ,x_return_status  => l_return_status
                            ,x_msg_count      => l_msg_count
                            ,x_msg_data       => l_msg_data
                            ,p_stmv_rec       => l_stmv_rec
                            ,p_selv_tbl       => l_selv_tbl
                            ,x_stmv_rec       => x_stmv_rec
                            ,x_selv_tbl       => x_selv_tbl );
            IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
          END IF;

          ---------------sechawla 09-mar-09 : MG Impact on Investor Agreement : begin ------------
          --Create stream element structure for reporting product
	      OPEN rep_strm_csr(l_contracts_csr.khr_id, l_final_start_date, l_contracts_csr.end_date, rep_stream_type_purpose);
          LOOP
            --re-initialize period end date
            l_period_end_date := NULL;
            FETCH rep_strm_csr INTO l_rep_elements;
            EXIT WHEN rep_strm_csr%NOTFOUND;
            l_period_end_date := trunc(last_day(l_rep_elements.stream_element_date));
            --populate stream elements tbl
            -- manipulate first record
            IF rep_strm_csr%ROWCOUNT = 1 THEN
              -- If start date is last day of the month, do nothing.
              IF TRUNC(l_final_start_date) <> TRUNC(LAST_DAY(l_final_start_date)) THEN
                -- If start date is the same as first day of the month then take whole amount.
                IF TRUNC(l_final_start_date) = TRUNC((ADD_MONTHS(LAST_DAY(l_final_start_date), -1) + 1)) THEN
                  l_rep_selv_tbl(l_rep_counter).amount := ROUND((l_rep_elements.amount*l_revenue_share/100),2);
                  l_rep_selv_tbl(l_rep_counter).stream_element_date := l_period_end_date;
                  l_rep_selv_tbl(l_rep_counter).se_line_number := l_rep_line_number;
                  l_rep_line_number := l_rep_line_number + 1;
                  l_rep_counter := l_rep_counter + 1;
                ELSE
                  -- start date is not first or last day of the month. so prorate.
                  l_difference := ABS(TRUNC(l_rep_elements.stream_element_date) - TRUNC(l_final_start_date));
                  l_rep_selv_tbl(l_rep_counter).amount := ROUND((((l_difference/30)*l_rep_elements.amount)*l_revenue_share/100),2);
                  l_rep_selv_tbl(l_rep_counter).stream_element_date := l_period_end_date;
                  l_rep_selv_tbl(l_rep_counter).se_line_number := l_rep_line_number;
                  l_rep_line_number := l_rep_line_number + 1;
                  l_rep_counter := l_rep_counter + 1;
                END IF;
              END IF;
            ELSE
              l_rep_selv_tbl(l_rep_counter).amount := ROUND((l_rep_elements.amount*l_revenue_share/100),2);
              l_rep_selv_tbl(l_rep_counter).stream_element_date := l_period_end_date;
              l_rep_selv_tbl(l_rep_counter).se_line_number := l_rep_line_number;
              l_rep_line_number := l_rep_line_number + 1;
              l_rep_counter := l_rep_counter + 1;
            END IF;
          END LOOP;
          CLOSE rep_strm_csr;
          IF l_rep_selv_tbl.COUNT > 0 THEN
            -- call streams api
            OKL_STREAMS_PUB.create_streams(
                            p_api_version    => l_api_version
                            ,p_init_msg_list  => l_init_msg_list
                            ,x_return_status  => l_return_status
                            ,x_msg_count      => l_msg_count
                            ,x_msg_data       => l_msg_data
                            ,p_stmv_rec       => l_rep_stmv_rec
                            ,p_selv_tbl       => l_rep_selv_tbl
                            ,x_stmv_rec       => x_rep_stmv_rec
                            ,x_selv_tbl       => x_rep_selv_tbl );
            IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
          END IF;

          ---------------sechawla 09-mar-09 : MG Impact on Investor Agreement : end ---------------
        EXCEPTION
          WHEN Okl_Api.G_EXCEPTION_ERROR THEN
            l_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                                         ,g_pkg_name
                                                         ,'OKL_API.G_RET_STS_ERROR'
                                                         ,x_msg_count
                                                         ,x_msg_data
                                                         ,'_PVT');
          WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                                         ,g_pkg_name
                                                         ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                         ,x_msg_count
                                                         ,x_msg_data
                                                         ,'_PVT');
          WHEN OTHERS THEN
            IF get_kle_id_csr%ISOPEN THEN
              CLOSE get_kle_id_csr;
            END IF;
            IF get_adv_arr_csr%ISOPEN THEN
              CLOSE get_adv_arr_csr;
            END IF;

            IF get_sty_id_csr%ISOPEN THEN
              CLOSE get_sty_id_csr;
            END IF;

            IF strm_csr%ISOPEN THEN
              CLOSE strm_csr;
            END IF;
            l_return_status :=Okl_Api.HANDLE_EXCEPTIONS (l_api_name,
                                                         G_PKG_NAME,
                                                         'OTHERS',
                                                         x_msg_count,
                                                         x_msg_data,
                                                         '_PVT');
          END;
      END LOOP;
      CLOSE securitized_contracts_csr;

  ELSE  --sechawla : p_mode is not null (ACTIVE) : This section of the code handles stream generation
        --only for the newly added pool contents, that are added after IA was activated
      OPEN securitized_contracts_pend_csr (p_khr_id);
      LOOP
        FETCH securitized_contracts_pend_csr INTO l_contracts_csr;
        EXIT WHEN securitized_contracts_pend_csr%NOTFOUND;
        DECLARE
          TYPE ref_cursor IS REF CURSOR;
          TYPE element_type IS RECORD (stream_element_date DATE, amount NUMBER);
          l_stmv_rec                   OKL_STREAMS_PUB.stmv_rec_type;
          l_selv_tbl                   OKL_STREAMS_PUB.selv_tbl_type;
          x_stmv_rec                   OKL_STREAMS_PUB.stmv_rec_type;
          x_selv_tbl                   OKL_STREAMS_PUB.selv_tbl_type;
          l_difference                 NUMBER := 0;
          l_counter                    NUMBER := 1;
          l_line_number                NUMBER := 1;
          --l_stmt                       VARCHAR2(5000);
          --l_where                      VARCHAR2(2000) := ' ';
          l_kle_id                     NUMBER;
          l_start_date                 DATE;
          l_final_start_date           DATE;
          ln_days                      NUMBER := 0;
          l_arrears                    VARCHAR2(1);
          l_frequency                  NUMBER;
          l_contract_number            VARCHAR2(2000);
          --strm_csr                     ref_cursor;
         l_elements                   element_type;

         --sechawla : 9-mar-2009 MG Impact on IA
	      l_rep_stmv_rec               OKL_STREAMS_PUB.stmv_rec_type;
          l_rep_selv_tbl               OKL_STREAMS_PUB.selv_tbl_type;
          x_rep_stmv_rec               OKL_STREAMS_PUB.stmv_rec_type;
          x_rep_selv_tbl               OKL_STREAMS_PUB.selv_tbl_type;
          l_rep_elements               element_type;
          l_rep_line_number            NUMBER := 1;
          l_rep_counter                NUMBER := 1;

        BEGIN
          OPEN contract_number_csr(l_contracts_csr.khr_id);
          FETCH contract_number_csr INTO l_contract_number,
                                         l_scs_code;
          CLOSE contract_number_csr;

          OPEN get_kle_id_pend_csr(l_contracts_csr.khr_id);
          FETCH get_kle_id_pend_csr INTO l_kle_id, l_start_date;
          CLOSE get_kle_id_pend_csr;

          IF l_kle_id IS NULL OR
             l_kle_id = OKL_API.G_MISS_NUM THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_ASC_KLE_ID_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_contract_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          IF l_start_date IS NULL OR l_start_date = OKL_API.G_MISS_DATE THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_ASC_START_DATE_ERROR');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          OPEN get_adv_arr_csr(l_contracts_csr.khr_id, l_kle_id);
          FETCH get_adv_arr_csr INTO l_arrears, l_frequency;
          CLOSE get_adv_arr_csr;

          IF l_frequency IS NULL THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_ASC_FREQUENCY_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_contract_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          IF l_arrears = 'Y' THEN
            ln_days := okl_stream_generator_pvt.get_day_count (
                                     p_start_date     => ADD_MONTHS(l_start_date, -l_frequency),
                                     p_end_date       => l_start_date,
                                     p_arrears        => l_arrears,
                                     x_return_status  => l_return_status);
            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
              RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_Status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
            END IF;
            l_final_start_date := l_start_date - ln_days;
          ELSIF NVL(l_arrears,'N') = 'N' THEN
            l_final_start_date := l_start_date;
          END IF;

                    --------------sechawla 09-mar-09 : MG Impact on Investor Agreement begin--------------
          okl_accounting_util.get_reporting_product(
                                  p_api_version           => l_api_version,
           		 	              p_init_msg_list         => p_init_msg_list,
           			              x_return_status         => l_return_status,
           			              x_msg_count             => x_msg_count,
           			              x_msg_data              => x_msg_data,
                                  p_contract_id 		  => l_contracts_csr.khr_id,
                                  x_rep_product           => lx_rep_product,
								  x_rep_product_id        => lx_rep_product_id,
								  x_rep_deal_type         => lx_rep_deal_type);

          IF    (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    		RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

	  	/*
	  	--Check the secondary_rep_method
      	OPEN  l_sec_rep_method_csr ;
      	FETCH l_sec_rep_method_csr INTO l_sec_rep_method;
      	IF l_sec_rep_method_csr%NOTFOUND THEN
     	  okl_api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_NO_SEC_REP_METHOD' --> seed this ''Secondary rep method cursor did not return any records''
                                  );
          RAISE okl_api.g_exception_error;
      	END IF;
	  	CLOSE l_sec_rep_method_csr ;
	  	*/
	  	--------------sechawla 09-mar-09 : MG Impact on Investor Agreement end --------------
          -- commenting as all accrual streams are generated
          -- at contract level. Will remove comments after super trump fix is provided
          -- for stream generation at asset level.Ref cursor will be needed later.
          --IF l_contracts_csr.deal_type IN ('LEASEOP','LEASEDF','LEASEST') THEN


          --get sty_id for the contract based on deal type
 /* ankushar , 25-01-2008 Bug 6773285
    Added code to generate new Stream Types for a Loan product on an Investor Agreement
    Start Changes
  */
          --get sty_id for the contract based on deal type
          IF l_contracts_csr.deal_type = 'LEASEOP' THEN -- deal type of primary product of the contract
             OKL_STREAMS_UTIL.get_primary_stream_type
             (
               p_khr_id => l_contracts_csr.khr_id,
               p_primary_sty_purpose => l_investor_rental_accrual,
               --sechawla : INVESTOR_RENTAL_ACCRUAL is the primary stream type purpose on the SGT of OP lease contract
			   --sechawla : Investor Arental Accrual stream is generated when IA is activated
               x_return_status => l_return_status,
               x_primary_sty_id => l_sty_id
             );
             IF l_return_status <> 'S' THEN
               okl_api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                                  p_token1       => 'STREAM_NAME',
                                  p_token1_value => l_investor_rental_accrual);
               RAISE okl_api.g_exception_error;

             END IF;
             -- calculate total revenue share
             FOR x IN get_investors_csr(p_khr_id) LOOP
                 FOR y IN get_revenue_share_csr(x.id, 'RENT') LOOP
                     l_revenue_share := l_revenue_share + y.percent_stake;
                 END LOOP;
             END LOOP;

             IF l_revenue_share IS NULL OR l_revenue_share = 0 THEN
             -- store SQL error message on message stack for caller
               Okl_Api.set_message(p_app_name     => g_app_name,
                                   p_msg_name     => 'OKL_ASC_REV_SHARE_ERROR');
               RAISE Okl_Api.G_EXCEPTION_ERROR;
             END IF;
            --Modified by kthiruva on 19-Oct-2005 . The stream type purpose needs to be bound instead
            --of the stream type code
            --Bug 4228708 - Start of Changes
           -- l_where := l_where ||' AND sty.stream_type_purpose = '|| '''' ||l_rental_accrual|| '''' ||' ORDER BY ste.stream_element_date';
              stream_type_purpose := l_rental_accrual;---- Rental Accrual for primary product
			 -- sechawla : This is the 'Rental Accrual' stream, generated when OP lease contract is Booked
			 -- sechawla : This stream is used to generate Investor Rental Accrual Stream, upon IA activation

            --Bug 4228708 - End of Changes


            --------------sechawla 09-mar-09 : MG Impact on Investor Agreement begin ----
			 ---generate Investor Rental Accrual / Pre Tax Income streams for reporting product
             --IF lx_rep_product IS NOT NULL AND l_sec_rep_method = 'AUTOMATED' THEN
             IF lx_rep_product IS NOT NULL THEN
                IF    lx_rep_deal_type = 'LEASEOP' THEN
                      OKL_STREAMS_UTIL.get_primary_stream_type_rep
             			(
               				p_khr_id => l_contracts_csr.khr_id,
               				p_primary_sty_purpose => l_investor_rental_accrual,
			   				--sechawla : INVESTOR_RENTAL_ACCRUAL is the primary stream type purpose on the SGT of reporing product(OP lease)
			   				--sechawla : Investor Arental Accrual stream is generated when IA is activated
               				x_return_status => l_return_status,
               				x_primary_sty_id => l_rep_sty_id
             			);
             		   IF l_return_status <> 'S' THEN
               			   okl_api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR_REP', --> seed this
                                  p_token1       => 'STREAM_NAME',
                                  p_token1_value => l_investor_rental_accrual);
               			   RAISE okl_api.g_exception_error;

             		   END IF;

             		   rep_stream_type_purpose := l_rental_accrual; -- Rental Accrual for reporting product
             		   --Rental Accrual stream is also generated for the reporting product (if OP Lease), when contract
             		   --is Booked. This stream is used to generate Investor Rental Accrual Stream for reporting product, upon IA activation
                ELSIF lx_rep_deal_type IN ('LEASEDF', 'LEASEST') THEN
                       OKL_STREAMS_UTIL.get_primary_stream_type_rep
             			(
               				p_khr_id => l_contracts_csr.khr_id,
               				p_primary_sty_purpose => l_investor_pre_tax_income,
               				--INVESTOR_PRE_TAX_INCOME is the primary stream type purpose on the SGT of reporting product (DF/ST)
			   				--Investor Pre Tax Income stream is generated when IA is activated
               				x_return_status => l_return_status,
               				x_primary_sty_id => l_rep_sty_id
             			);

              			IF l_return_status <> 'S' THEN
                 			okl_api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR_REP', --> seed this
                                     p_token1       => 'STREAM_NAME',
                                     p_token1_value => l_investor_pre_tax_income);
                 			RAISE okl_api.g_exception_error;
              			END IF;

              			rep_stream_type_purpose := l_pre_tax_income; -- Pre Tax Income for reporting product
              			--Pre Tax income stream is also generated for the reporting product (if DF/ST Lease), when contract
             		    --is Booked. This stream is used to generate Investor Pre Tax Income Stream for reporting product, upon IA activation
                END IF;
             END IF;
             --------------sechawla 09-mar-09 : MG Impact on Investor Agreement end -----

          ELSIF l_contracts_csr.deal_type IN ('LEASEDF', 'LEASEST') THEN -- deal type of primary product of the contract
             OKL_STREAMS_UTIL.get_primary_stream_type
             (
               p_khr_id => l_contracts_csr.khr_id,
               p_primary_sty_purpose => l_investor_pre_tax_income,
               --INVESTOR_PRE_TAX_INCOME is the primary stream type purpose on the SGT of DF/ST lease contract
			   --Investor Pre Tax Income stream is generated when IA is activated
               x_return_status => l_return_status,
               x_primary_sty_id => l_sty_id
             );

              IF l_return_status <> 'S' THEN
                 okl_api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                                     p_token1       => 'STREAM_NAME',
                                     p_token1_value => l_investor_pre_tax_income);
                 RAISE okl_api.g_exception_error;
              END IF;

             -- calculate total revenue share
             FOR x IN get_investors_csr(p_khr_id) LOOP
                 FOR y IN get_revenue_share_csr(x.id, 'RENT') LOOP
                     l_revenue_share := l_revenue_share + y.percent_stake;
                 END LOOP;
             END LOOP;

             IF l_revenue_share IS NULL OR l_revenue_share = 0 THEN
             -- store SQL error message on message stack for caller
                Okl_Api.set_message(p_app_name     => g_app_name,
                                    p_msg_name     => 'OKL_ASC_REV_SHARE_ERROR');
                RAISE Okl_Api.G_EXCEPTION_ERROR;
             END IF;
             stream_type_purpose := l_pre_tax_income;--Pre Tax Income for Primary product
             -- sechawla : This is the 'Pre Tax Income' stream, generated when DF/ST lease contract is Booked
     		 -- sechawla : This stream is used to generate Investor Pre Tax Income Stream, upon IA activation


     		 --------------sechawla 09-mar-09 : MG Impact on Investor Agreement begin ----
			 ---generate Investor Rental Accrual / Pre Tax Income streams for reporting product
             --IF lx_rep_product IS NOT NULL AND l_sec_rep_method = 'AUTOMATED' THEN
              IF lx_rep_product IS NOT NULL  THEN
                IF    lx_rep_deal_type = 'LEASEOP' THEN
                      OKL_STREAMS_UTIL.get_primary_stream_type_rep
             			(
               				p_khr_id => l_contracts_csr.khr_id,
               				p_primary_sty_purpose => l_investor_rental_accrual,
			   				--sechawla : INVESTOR_RENTAL_ACCRUAL is the primary stream type purpose on the SGT of reporing product(OP lease)
			   				--sechawla : Investor Arental Accrual stream is generated when IA is activated
               				x_return_status => l_return_status,
               				x_primary_sty_id => l_rep_sty_id
             			);
             		   IF l_return_status <> 'S' THEN
               			   okl_api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR_REP', --> seed this
                                  p_token1       => 'STREAM_NAME',
                                  p_token1_value => l_investor_rental_accrual);
               			   RAISE okl_api.g_exception_error;

             		   END IF;

             		   rep_stream_type_purpose := l_rental_accrual; -- Rental Accrual for reporting product
             		   --Rental Accrual stream is generated for the reporting product (if OP Lease), when contract
             		   --is Booked. This stream is used to generate Investor Rental Accrual Stream for reporting product, upon IA activation
                ELSIF lx_rep_deal_type IN ('LEASEDF', 'LEASEST') THEN
                       OKL_STREAMS_UTIL.get_primary_stream_type_rep
             			(
               				p_khr_id => l_contracts_csr.khr_id,
               				p_primary_sty_purpose => l_investor_pre_tax_income,
               				--INVESTOR_PRE_TAX_INCOME is the primary stream type purpose on the SGT of reporting product (DF/ST)
			   				--Investor Pre Tax Income stream is generated when IA is activated
               				x_return_status => l_return_status,
               				x_primary_sty_id => l_rep_sty_id
             			);

              			IF l_return_status <> 'S' THEN
                 			okl_api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR_REP', --> seed this
                                     p_token1       => 'STREAM_NAME',
                                     p_token1_value => l_investor_pre_tax_income);
                 			RAISE okl_api.g_exception_error;
              			END IF;

              			rep_stream_type_purpose := l_pre_tax_income; -- Pre Tax Income for reporting product
              			--Pre Tax income stream is also generated for the reporting product (if DF/ST Lease), when contract
             		    --is Booked. This stream is used to generate Investor Pre Tax Income Stream for reporting product, upon IA activation
                END IF;
             END IF;
             --------------sechawla 09-mar-09 : MG Impact on Investor Agreement end -----


 /* ankushar , 25-01-2008 Bug 6773285
    End Changes
  */
/* ankushar , 16-01-2008 Bug 6740000
   Added condition for fetching stream type for a Loan product
   Start Changes
*/
          ---sechawla 09-mar-09 : MG Impact on Investor Agreement : No impacts on Loans
          ELSIF l_contracts_csr.deal_type IN ('LOAN', 'LOAN-REVOLVING') THEN
             OKL_STREAMS_UTIL.get_primary_stream_type
             (
               p_khr_id => l_contracts_csr.khr_id,
               p_primary_sty_purpose => l_inv_interest_income_accrual,
               x_return_status => l_return_status,
               x_primary_sty_id => l_sty_id
              );
             IF l_return_status <> 'S' THEN
                 okl_api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                                     p_token1       => 'STREAM_NAME',
                                     p_token1_value => l_inv_interest_income_accrual);
                 RAISE okl_api.g_exception_error;
              END IF;

              -- calculate total revenue share
              FOR x IN get_investors_csr(p_khr_id) LOOP
                  FOR y IN get_revenue_share_csr(x.id, 'LOAN_PAYMENT') LOOP
                      l_revenue_share := l_revenue_share + y.percent_stake;
                  END LOOP;
              END LOOP;

              IF l_revenue_share IS NULL OR l_revenue_share = 0 THEN
              -- store SQL error message on message stack for caller
                 Okl_Api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_ASC_REV_SHARE_ERROR');
                 RAISE Okl_Api.G_EXCEPTION_ERROR;
              END IF;

              stream_type_purpose := l_interest_income;
/* ankushar , 16-01-2008 Bug 6740000
   End Changes
*/
          END IF;

          --Populate streams structure for primary product
          SELECT okl_sif_seq.NEXTVAL INTO l_trx_number FROM dual;
          -- populate stream header record
          l_stmv_rec.sty_id := l_sty_id;
          l_stmv_rec.khr_id := l_contracts_csr.khr_id;
          l_stmv_rec.sgn_code := 'MANL';
          l_stmv_rec.say_code := 'CURR';
          l_stmv_rec.transaction_number := l_trx_number;
          l_stmv_rec.active_yn := 'Y';
          l_stmv_rec.date_current :=  l_sysdate;
          l_stmv_rec.source_id :=  p_khr_id;
          l_stmv_rec.source_table := 'OKL_K_HEADERS';
          -- create final l_stmt
          --l_stmt := l_stmt || l_where;
          --OPEN strm_csr FOR l_stmt;
	      -- use of a parameterized cursor by zrehman on 12-Sep-2006

	      ---------------sechawla 09-mar-09 : MG Impact on Investor Agreement : begin ------------
          IF l_rep_sty_id IS NOT NULL THEN
          		--Populate streams structure for reporting product
          		SELECT okl_sif_seq.NEXTVAL INTO l_trx_number FROM dual;
          		-- populate stream header record
          		l_rep_stmv_rec.sty_id := l_rep_sty_id;
          		l_rep_stmv_rec.khr_id := l_contracts_csr.khr_id;
          		l_rep_stmv_rec.sgn_code := 'MANL';
          		l_rep_stmv_rec.say_code := 'CURR';
          		l_rep_stmv_rec.transaction_number := l_trx_number;
          		l_rep_stmv_rec.active_yn := 'N';
          		l_rep_stmv_rec.purpose_code := 'REPORT';
          		l_rep_stmv_rec.date_current :=  l_sysdate;
          		l_rep_stmv_rec.source_id :=  p_khr_id;
          		l_rep_stmv_rec.source_table := 'OKL_K_HEADERS';
         END IF;
         -----------------sechawla 09-mar-09 : MG Impact on Investor Agreement : end ------------

	  OPEN strm_csr(l_contracts_csr.khr_id, l_final_start_date, l_contracts_csr.end_date, stream_type_purpose);
          LOOP
            --re-initialize period end date
            l_period_end_date := NULL;
            FETCH strm_csr INTO l_elements;
            EXIT WHEN strm_csr%NOTFOUND;
            l_period_end_date := trunc(last_day(l_elements.stream_element_date));
            --populate stream elements tbl
            -- manipulate first record
            IF strm_csr%ROWCOUNT = 1 THEN
              -- If start date is last day of the month, do nothing.
              IF TRUNC(l_final_start_date) <> TRUNC(LAST_DAY(l_final_start_date)) THEN
                -- If start date is the same as first day of the month then take whole amount.
                IF TRUNC(l_final_start_date) = TRUNC((ADD_MONTHS(LAST_DAY(l_final_start_date), -1) + 1)) THEN
                  l_selv_tbl(l_counter).amount := ROUND((l_elements.amount*l_revenue_share/100),2);
                  l_selv_tbl(l_counter).stream_element_date := l_period_end_date;
                  l_selv_tbl(l_counter).se_line_number := l_line_number;
                  l_line_number := l_line_number + 1;
                  l_counter := l_counter + 1;
                ELSE
                  -- start date is not first or last day of the month. so prorate.
                  l_difference := ABS(TRUNC(l_elements.stream_element_date) - TRUNC(l_final_start_date));
                  l_selv_tbl(l_counter).amount := ROUND((((l_difference/30)*l_elements.amount)*l_revenue_share/100),2);
                  l_selv_tbl(l_counter).stream_element_date := l_period_end_date;
                  l_selv_tbl(l_counter).se_line_number := l_line_number;
                  l_line_number := l_line_number + 1;
                  l_counter := l_counter + 1;
                END IF;
              END IF;
            ELSE
              l_selv_tbl(l_counter).amount := ROUND((l_elements.amount*l_revenue_share/100),2);
              l_selv_tbl(l_counter).stream_element_date := l_period_end_date;
              l_selv_tbl(l_counter).se_line_number := l_line_number;
              l_line_number := l_line_number + 1;
              l_counter := l_counter + 1;
            END IF;
          END LOOP;
          CLOSE strm_csr;
          IF l_selv_tbl.COUNT > 0 THEN
            -- call streams api
            OKL_STREAMS_PUB.create_streams(
                            p_api_version    => l_api_version
                            ,p_init_msg_list  => l_init_msg_list
                            ,x_return_status  => l_return_status
                            ,x_msg_count      => l_msg_count
                            ,x_msg_data       => l_msg_data
                            ,p_stmv_rec       => l_stmv_rec
                            ,p_selv_tbl       => l_selv_tbl
                            ,x_stmv_rec       => x_stmv_rec
                            ,x_selv_tbl       => x_selv_tbl );
            IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
          END IF;

          ---------------sechawla 09-mar-09 : MG Impact on Investor Agreement : begin ------------
          --Create stream element structure for reporting product
	      OPEN rep_strm_csr(l_contracts_csr.khr_id, l_final_start_date, l_contracts_csr.end_date, rep_stream_type_purpose);
          LOOP
            --re-initialize period end date
            l_period_end_date := NULL;
            FETCH rep_strm_csr INTO l_rep_elements;
            EXIT WHEN rep_strm_csr%NOTFOUND;
            l_period_end_date := trunc(last_day(l_rep_elements.stream_element_date));
            --populate stream elements tbl
            -- manipulate first record
            IF rep_strm_csr%ROWCOUNT = 1 THEN
              -- If start date is last day of the month, do nothing.
              IF TRUNC(l_final_start_date) <> TRUNC(LAST_DAY(l_final_start_date)) THEN
                -- If start date is the same as first day of the month then take whole amount.
                IF TRUNC(l_final_start_date) = TRUNC((ADD_MONTHS(LAST_DAY(l_final_start_date), -1) + 1)) THEN
                  l_rep_selv_tbl(l_rep_counter).amount := ROUND((l_rep_elements.amount*l_revenue_share/100),2);
                  l_rep_selv_tbl(l_rep_counter).stream_element_date := l_period_end_date;
                  l_rep_selv_tbl(l_rep_counter).se_line_number := l_rep_line_number;
                  l_rep_line_number := l_rep_line_number + 1;
                  l_rep_counter := l_rep_counter + 1;
                ELSE
                  -- start date is not first or last day of the month. so prorate.
                  l_difference := ABS(TRUNC(l_rep_elements.stream_element_date) - TRUNC(l_final_start_date));
                  l_rep_selv_tbl(l_rep_counter).amount := ROUND((((l_difference/30)*l_rep_elements.amount)*l_revenue_share/100),2);
                  l_rep_selv_tbl(l_rep_counter).stream_element_date := l_period_end_date;
                  l_rep_selv_tbl(l_rep_counter).se_line_number := l_rep_line_number;
                  l_rep_line_number := l_rep_line_number + 1;
                  l_rep_counter := l_rep_counter + 1;
                END IF;
              END IF;
            ELSE
              l_rep_selv_tbl(l_rep_counter).amount := ROUND((l_rep_elements.amount*l_revenue_share/100),2);
              l_rep_selv_tbl(l_rep_counter).stream_element_date := l_period_end_date;
              l_rep_selv_tbl(l_rep_counter).se_line_number := l_rep_line_number;
              l_rep_line_number := l_rep_line_number + 1;
              l_rep_counter := l_rep_counter + 1;
            END IF;
          END LOOP;
          CLOSE rep_strm_csr;
          IF l_rep_selv_tbl.COUNT > 0 THEN
            -- call streams api
            OKL_STREAMS_PUB.create_streams(
                            p_api_version    => l_api_version
                            ,p_init_msg_list  => l_init_msg_list
                            ,x_return_status  => l_return_status
                            ,x_msg_count      => l_msg_count
                            ,x_msg_data       => l_msg_data
                            ,p_stmv_rec       => l_rep_stmv_rec
                            ,p_selv_tbl       => l_rep_selv_tbl
                            ,x_stmv_rec       => x_rep_stmv_rec
                            ,x_selv_tbl       => x_rep_selv_tbl );
            IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
          END IF;

          ---------------sechawla 09-mar-09 : MG Impact on Investor Agreement : end ---------------

        EXCEPTION
          WHEN Okl_Api.G_EXCEPTION_ERROR THEN
            l_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                                         ,g_pkg_name
                                                         ,'OKL_API.G_RET_STS_ERROR'
                                                         ,x_msg_count
                                                         ,x_msg_data
                                                         ,'_PVT');
          WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                                         ,g_pkg_name
                                                         ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                         ,x_msg_count
                                                         ,x_msg_data
                                                         ,'_PVT');
          WHEN OTHERS THEN
            IF get_kle_id_csr%ISOPEN THEN
              CLOSE get_kle_id_csr;
            END IF;
            IF get_adv_arr_csr%ISOPEN THEN
              CLOSE get_adv_arr_csr;
            END IF;

            IF get_sty_id_csr%ISOPEN THEN
              CLOSE get_sty_id_csr;
            END IF;

            IF strm_csr%ISOPEN THEN
              CLOSE strm_csr;
            END IF;
            l_return_status :=Okl_Api.HANDLE_EXCEPTIONS (l_api_name,
                                                         G_PKG_NAME,
                                                         'OTHERS',
                                                         x_msg_count,
                                                         x_msg_data,
                                                         '_PVT');
          END;
      END LOOP;
      CLOSE securitized_contracts_pend_csr;

  END IF;
 END IF;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data	  => x_msg_data);
                         x_return_status := l_return_status;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    /*
    --sechawla 9-mar-09
    IF l_sec_rep_method_csr%ISOPEN THEN
	    CLOSE l_sec_rep_method_csr;
    END IF;
    */
    IF rep_strm_csr%ISOPEN THEN
        CLOSE rep_strm_csr;
    END IF;

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                                   ,g_pkg_name
                                                   ,'OKL_API.G_RET_STS_ERROR'
                                                   ,x_msg_count
                                                   ,x_msg_data
                                                   ,'_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    /*	--sechawla 9-mar-09
    	IF l_sec_rep_method_csr%ISOPEN THEN
	    	CLOSE l_sec_rep_method_csr;
   		END IF;
    */
    	IF rep_strm_csr%ISOPEN THEN
        	CLOSE rep_strm_csr;
    	END IF;
     	x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                                   ,g_pkg_name
                                                   ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                   ,x_msg_count
                                                   ,x_msg_data
                                                   ,'_PVT');
    WHEN OTHERS THEN
      	IF securitized_contracts_csr%ISOPEN THEN
        	CLOSE securitized_contracts_csr;
      	END IF;
      	--sechawla 9-mar-09
      /*	IF l_sec_rep_method_csr%ISOPEN THEN
	    	CLOSE l_sec_rep_method_csr;
     	END IF;
    */
      	IF rep_strm_csr%ISOPEN THEN
        	CLOSE rep_strm_csr;
      	END IF;
      	x_return_status :=Okl_Api.HANDLE_EXCEPTIONS (l_api_name,
                                                   G_PKG_NAME,
                                                   'OTHERS',
                                                   x_msg_count,
                                                   x_msg_data,
                                                   '_PVT');

  END CREATE_STREAMS;

  -- procedure to cancel accrual securitization streams for LEASE contracts.
  -- this procedure is being updated. Instead of deleting stream elements physically
  -- accrued_yn flag will be updated to N. Generate accruals picks only those amounts
  -- which are marked as NULL.

  --sechawla 10-mar-09 MG Impacts on IA : update accrual flag for reporting streams as well
  PROCEDURE CANCEL_STREAMS(p_api_version     IN  NUMBER,
                           p_init_msg_list   IN  VARCHAR2,
                           x_return_status   OUT NOCOPY VARCHAR2,
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2,
					       p_khr_id          IN NUMBER,
                           p_cancel_date     IN DATE) IS

	l_api_version                CONSTANT NUMBER := 1.0;
	l_api_name                   CONSTANT VARCHAR2(30) := 'CANCEL_STREAMS';
/*
	l_investor_rental_accrual    CONSTANT VARCHAR2(2000) := 'INVESTOR RENTAL ACCRUAL';
	l_investor_pre_tax_income    CONSTANT VARCHAR2(2000) := 'INVESTOR PRE-TAX INCOME';
	l_investor_interest_income   CONSTANT VARCHAR2(2000) := 'INVESTOR INTEREST INCOME';
	l_investor_variable_interest CONSTANT VARCHAR2(2000) := 'INVESTOR VARIABLE INTEREST';
*/
    l_investor_rental_accrual      CONSTANT VARCHAR2(2000) := 'INVESTOR_RENTAL_ACCRUAL';
    l_investor_pre_tax_income      CONSTANT VARCHAR2(2000) := 'INVESTOR_PRETAX_INCOME';
    l_investor_interest_income     CONSTANT VARCHAR2(2000) := 'GENERAL';
    l_investor_variable_interest   CONSTANT VARCHAR2(2000) := 'INVESTOR_VARIABLE_INTEREST';
/* ankushar , 16-01-2008 Bug 6691554
   Added new Stream Type purpose for a Loan product
 */
    l_inv_interest_income_accrual         CONSTANT VARCHAR2(2000) := 'INVESTOR_INTEREST_INCOME';

 	l_init_msg_list              VARCHAR2(4000) := OKL_API.G_FALSE;
	l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_msg_count                  NUMBER;
	l_msg_data                   VARCHAR2(2000);
    l_deal_type                  VARCHAR2(2000);
    l_selv_tbl                   OKL_STREAMS_PUB.selv_tbl_type;
    x_selv_tbl                   OKL_STREAMS_PUB.selv_tbl_type;

    --sechawla 10-mar-09 MG impacts
    l_sec_rep_method				 VARCHAR2(30);
	lx_rep_product					 OKL_PRODUCTS_V.NAME%TYPE;
	lx_rep_product_id				 NUMBER;
    lx_rep_deal_type                 okl_product_parameters_v.deal_type%TYPE;
    l_rep_selv_tbl                   OKL_STREAMS_PUB.selv_tbl_type;
    x_rep_selv_tbl                   OKL_STREAMS_PUB.selv_tbl_type;

    -- cursor to get deal type of lease contract.
    CURSOR get_deal_type_csr(p_khr_id NUMBER) IS
    SELECT deal_type
    FROM OKL_K_HEADERS
    WHERE id = p_khr_id;

    CURSOR non_accrued_streams_csr(p_khr_id NUMBER, p_sty_code VARCHAR2, p_date DATE) IS
    SELECT ste.id
    FROM OKL_STRM_TYPE_B sty,
         OKL_STREAMS stm,
         OKL_STRM_ELEMENTS ste
    WHERE stm.khr_id = p_khr_id
    AND stm.sty_id = sty.id
    --AND sty.code = p_sty_code
	AND sty.stream_type_purpose = p_sty_code
    AND stm.id = ste.stm_id
    AND stm.active_yn ='Y'
    AND stm.say_code= 'CURR'
    AND ste.stream_element_date >= p_date
    AND ste.accrued_yn IS NULL;

    --sechawla 10-mar-09 MG Impact
    CURSOR rep_non_accrued_streams_csr(p_khr_id NUMBER, p_sty_code VARCHAR2, p_date DATE) IS
    SELECT ste.id
    FROM OKL_STRM_TYPE_B sty,
         OKL_STREAMS stm,
         OKL_STRM_ELEMENTS ste
    WHERE stm.khr_id = p_khr_id
    AND stm.sty_id = sty.id
    --AND sty.code = p_sty_code
	AND sty.stream_type_purpose = p_sty_code
    AND stm.id = ste.stm_id
    AND stm.active_yn ='N'
    AND stm.say_code= 'CURR'
    AND stm.purpose_code = 'REPORT'
    AND ste.stream_element_date >= p_date
    AND ste.accrued_yn IS NULL;

    --sechawla 10-mar-09 MG Impact
    CURSOR l_sec_rep_method_csr IS
    SELECT secondary_rep_method
	FROM   okl_sys_acct_opts;


    CURSOR accrued_streams_csr(p_khr_id NUMBER, p_sty_code VARCHAR2, p_date DATE) IS
    SELECT ste.id
    FROM OKL_STRM_TYPE_B sty,
         OKL_STREAMS stm,
         OKL_STRM_ELEMENTS ste
    WHERE stm.khr_id = p_khr_id
    AND stm.sty_id = sty.id
    --AND sty.code = p_sty_code
	AND sty.stream_type_purpose = p_sty_code
    AND stm.id = ste.stm_id
    AND stm.active_yn ='Y'
    AND stm.say_code= 'CURR'
    AND ste.stream_element_date >= p_date
    AND ste.accrued_yn IS NULL;

  BEGIN

    -- Set save point
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_return_status);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- validate in parameters
	IF p_khr_id IS NULL OR p_khr_id = OKL_API.G_MISS_NUM THEN
      -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_ASC_KHR_ID_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

	IF p_cancel_date IS NULL OR p_cancel_date = OKL_API.G_MISS_DATE THEN
      -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_ASC_CANCEL_DATE_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    -- get deal type
    OPEN get_deal_type_csr(p_khr_id);
	FETCH get_deal_type_csr INTO l_deal_type;
	CLOSE get_deal_type_csr;

    -- get non accrued stream elements based on deal type for deletion.
    IF l_deal_type = 'LEASEOP' THEN

      FOR x IN non_accrued_streams_csr(p_khr_id, l_investor_rental_accrual, p_cancel_date)
      LOOP
        l_selv_tbl(non_accrued_streams_csr%ROWCOUNT).id := x.id;
        l_selv_tbl(non_accrued_streams_csr%ROWCOUNT).accrued_yn := 'N';
      END LOOP;
    ELSIF l_deal_type IN ('LEASEDF', 'LEASEST') THEN

      FOR x IN non_accrued_streams_csr(p_khr_id, l_investor_pre_tax_income, p_cancel_date)
      LOOP
        l_selv_tbl(non_accrued_streams_csr%ROWCOUNT).id := x.id;
        l_selv_tbl(non_accrued_streams_csr%ROWCOUNT).accrued_yn := 'N';
      END LOOP;
/* ankushar , 16-01-2008 Bug 6691554
   Added condition for fetching stream type for a Loan product
   Start Changes
*/
    ELSIF l_deal_type IN ('LOAN', 'LOAN-REVOLVING') THEN

      FOR x IN non_accrued_streams_csr(p_khr_id, l_inv_interest_income_accrual, p_cancel_date)
      LOOP
        l_selv_tbl(non_accrued_streams_csr%ROWCOUNT).id := x.id;
        l_selv_tbl(non_accrued_streams_csr%ROWCOUNT).accrued_yn := 'N';
      END LOOP;
/* ankushar , 16-01-2008 Bug 6691554
   End Changes
*/

    END IF;

    -- call delete stream elements API.
    IF l_selv_tbl.COUNT > 0 THEN

      OKL_STREAMS_PUB.update_stream_elements(
                      p_api_version => l_api_version
                     ,p_init_msg_list => l_init_msg_list
                     ,x_return_status => l_return_status
                     ,x_msg_count => l_msg_count
                     ,x_msg_data => l_msg_data
                     ,p_selv_tbl => l_selv_tbl
                     ,x_selv_tbl => x_selv_tbl);
      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    --------------sechawla 09-mar-09 : MG Impacts begin------------------
    --Cancel streams (update accrual flag) on reporting streams as well
      okl_accounting_util.get_reporting_product(
                                  p_api_version           => l_api_version,
           		 	              p_init_msg_list         => p_init_msg_list,
           			              x_return_status         => l_return_status,
           			              x_msg_count             => x_msg_count,
           			              x_msg_data              => x_msg_data,
                                  p_contract_id 		  => p_khr_id,
                                  x_rep_product           => lx_rep_product,
								  x_rep_product_id        => lx_rep_product_id,
								  x_rep_deal_type         => lx_rep_deal_type);

      IF    (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    	RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

	  --Check the secondary_rep_method
      OPEN  l_sec_rep_method_csr ;
      FETCH l_sec_rep_method_csr INTO l_sec_rep_method;
      IF l_sec_rep_method_csr%NOTFOUND THEN
     	  okl_api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_NO_SEC_REP_METHOD' --> seed this ''Secondary rep method cursor did not return any records''
                               );
          RAISE okl_api.g_exception_error;
      END IF;
	  CLOSE l_sec_rep_method_csr ;

	  IF lx_rep_product IS NOT NULL AND l_sec_rep_method = 'AUTOMATED' THEN
	     -- get non accrued stream elements based on deal type for deletion.
   		 IF lx_rep_deal_type = 'LEASEOP' THEN

      		FOR x_rep IN rep_non_accrued_streams_csr(p_khr_id, l_investor_rental_accrual, p_cancel_date) LOOP
        		l_rep_selv_tbl(rep_non_accrued_streams_csr%ROWCOUNT).id := x_rep.id;
        		l_rep_selv_tbl(rep_non_accrued_streams_csr%ROWCOUNT).accrued_yn := 'N';
      		END LOOP;
    	ELSIF lx_rep_deal_type IN ('LEASEDF', 'LEASEST') THEN

      		FOR x_rep IN rep_non_accrued_streams_csr(p_khr_id, l_investor_pre_tax_income, p_cancel_date) LOOP
        		l_rep_selv_tbl(rep_non_accrued_streams_csr%ROWCOUNT).id := x_rep.id;
        		l_rep_selv_tbl(rep_non_accrued_streams_csr%ROWCOUNT).accrued_yn := 'N';
      		END LOOP;

	    ELSIF lx_rep_deal_type IN ('LOAN', 'LOAN-REVOLVING') THEN

      		FOR x_rep IN rep_non_accrued_streams_csr(p_khr_id, l_inv_interest_income_accrual, p_cancel_date) LOOP
        		l_rep_selv_tbl(rep_non_accrued_streams_csr%ROWCOUNT).id := x_rep.id;
        		l_rep_selv_tbl(rep_non_accrued_streams_csr%ROWCOUNT).accrued_yn := 'N';
      		END LOOP;

    	END IF;

    	-- call delete stream elements API.
    	IF l_rep_selv_tbl.COUNT > 0 THEN

      		OKL_STREAMS_PUB.update_stream_elements(
                      p_api_version => l_api_version
                     ,p_init_msg_list => l_init_msg_list
                     ,x_return_status => l_return_status
                     ,x_msg_count 	=> l_msg_count
                     ,x_msg_data => l_msg_data
                     ,p_selv_tbl => l_rep_selv_tbl
                     ,x_selv_tbl => x_rep_selv_tbl);

      		IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      		ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
        		RAISE Okl_Api.G_EXCEPTION_ERROR;
      		END IF;

    	END IF;


	  END IF;

	  --------------sechawla 09-mar-09 : MG Impact on Investor Agreement end --------------


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN

     --sechawla 10-mar-09 MG Impact
     IF rep_non_accrued_streams_csr%ISOPEN THEN
        CLOSE rep_non_accrued_streams_csr;
     END IF;

     IF l_sec_rep_method_csr%ISOPEN THEN
        CLOSE l_sec_rep_method_csr;
     END IF;

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN

      --sechawla 10-mar-09 MG Impact
     IF rep_non_accrued_streams_csr%ISOPEN THEN
        CLOSE rep_non_accrued_streams_csr;
     END IF;

     IF l_sec_rep_method_csr%ISOPEN THEN
        CLOSE l_sec_rep_method_csr;
     END IF;
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN OTHERS THEN
      IF get_deal_type_csr%ISOPEN THEN
        CLOSE get_deal_type_csr;
      END IF;

      --sechawla 10-mar-09 MG Impact
     IF rep_non_accrued_streams_csr%ISOPEN THEN
        CLOSE rep_non_accrued_streams_csr;
     END IF;

     IF l_sec_rep_method_csr%ISOPEN THEN
        CLOSE l_sec_rep_method_csr;
     END IF;

      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END CANCEL_STREAMS;
/*Commented as T_A requirement has changed
  PROCEDURE Create_Adjustment_Streams(
                           p_api_version     IN NUMBER
                          ,p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE
                          ,x_return_status   OUT NOCOPY VARCHAR2
                          ,x_msg_count       OUT NOCOPY NUMBER
                          ,x_msg_data        OUT NOCOPY VARCHAR2
                          ,p_contract_id     IN NUMBER
                          ,p_line_id_tbl     IN p_line_id_tbl_type
                          ,p_adjustment_date IN DATE) IS
*/
  PROCEDURE Get_Accrual_Adjustment(
                           p_api_version     IN NUMBER
                          ,p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE
                          ,x_return_status   OUT NOCOPY VARCHAR2
                          ,x_msg_count       OUT NOCOPY NUMBER
                          ,x_msg_data        OUT NOCOPY VARCHAR2
                          ,p_contract_id     IN NUMBER
                          ,p_line_id_tbl     IN p_line_id_tbl_type
                          ,p_adjustment_date IN DATE
						  ,x_accrual_adjustment_tbl    OUT NOCOPY p_accrual_adjustment_tbl_type
                          ,p_product_id      IN NUMBER DEFAULT NULL) IS -- MGAAP

/*
  CURSOR l_line_rec_csr(chrid NUMBER, lnetype VARCHAR2)
  IS
  SELECT kle.id,
         kle.amount,
         kle.start_date,
         kle.end_date,
         kle.fee_type,
         kle.initial_direct_cost,
         tl.item_description,
         tl.name,
         sts.ste_code
  FROM okl_k_lines_full_v kle,
       okc_line_styles_b lse,
       okc_k_lines_tl tl,
       okc_statuses_b sts
  WHERE kle.lse_id = lse.id
  AND lse.lty_code = lnetype
  AND tl.id = kle.id
  AND tl.language = userenv('LANG')
  AND kle.dnz_chr_id = chrid
  AND sts.code = kle.sts_code
  AND sts.ste_code not in ('HOLD', 'EXPIRED', 'CANCELLED');
*/
  CURSOR l_line_rec_csr(chrid NUMBER, kleid NUMBER)
  IS
  SELECT
         kle.amount,
         kle.start_date,
         kle.end_date,
         kle.fee_type,
         kle.initial_direct_cost,
         tl.item_description,
         tl.name,
         sts.ste_code,
		 lse.lty_code
  FROM okl_k_lines_full_v kle,
       okc_line_styles_b lse,
       okc_k_lines_tl tl,
       okc_statuses_b sts
  WHERE kle.lse_id = lse.id
  AND tl.id = kle.id
  AND tl.language = userenv('LANG')
  AND kle.dnz_chr_id = chrid
  AND kle.id = kleid
  AND sts.code = kle.sts_code
  AND sts.ste_code not in ('HOLD', 'EXPIRED', 'CANCELLED');

  CURSOR link_rollover_csr(cleId NUMBER)
  IS
  SELECT okc.id id,
         okc.chr_id chr_id,
       	 okc.cle_id cle_id,
       	 okc.dnz_chr_id dnz_chr_id,
       	 kle.capital_amount capital_amount,
       	 kle.amount amount,
       	 lse.lty_code lty_code
  FROM   okc_k_lines_b okc,
       	 okl_k_lines kle ,
       	 okc_line_styles_b lse
  WHERE  okc.cle_id = cleId
  AND    okc.lse_id = lse.id
  AND    okc.id = kle.id
  AND    lty_code = 'LINK_FEE_ASSET';

  CURSOR l_strm_for_line_csr(chrid NUMBER, kleid NUMBER)
  IS
  SELECT
       str.sty_id sty_id
  FROM okl_streams str,
       okl_strm_type_b sty
  WHERE str.sty_id = sty.id
  AND str.say_code = 'CURR'
  AND str.khr_id = chrid
  AND str.kle_id = kleid;


  CURSOR l_accrued_amt_csr(chrid NUMBER, kleid NUMBER,tadate DATE, strmPurpose VARCHAR2)
  IS
  SELECT
       sum(ste.amount) amount,
	   str.sty_id sty_id
  --FROM okl_streams str,
  FROM okl_streams_rep_v str, -- MGAAP 7263041
       okl_strm_elements ste,
       okl_strm_type_b sty
  WHERE ste.stm_id = str.id
  AND str.sty_id = sty.id
  AND str.say_code = 'CURR'
  AND str.khr_id = chrid
  AND str.kle_id = kleid
  AND ste.stream_element_date <= last_day(tadate)
  AND sty.stream_type_purpose = strmPurpose
  GROUP BY str.sty_id;

  CURSOR l_accrued_amt_sty_csr(chrid NUMBER, kleid NUMBER,tadate DATE, styid NUMBER)
  IS
  SELECT
       sum(ste.amount) amount,
	   str.sty_id sty_id
  --FROM okl_streams str,
  FROM okl_streams_rep_v str, -- MGAAP 7263041
       okl_strm_elements ste,
       okl_strm_type_b sty
  WHERE ste.stm_id = str.id
  AND str.sty_id = sty.id
  AND str.say_code = 'CURR'
  AND str.khr_id = chrid
  AND str.kle_id = kleid
  AND ste.stream_element_date <= last_day(tadate)
  AND sty.id = styid
  GROUP BY str.sty_id;


  CURSOR l_bill_amt_csr(chrid NUMBER, kleid NUMBER,tadate DATE, strmPurpose VARCHAR2)
  IS
  SELECT
       sum(ste.amount)
  --FROM okl_streams str,
  FROM okl_streams_rep_v str, -- MGAAP 7263041
       okl_strm_elements ste,
       okl_strm_type_b sty
  WHERE ste.stm_id = str.id
  AND str.sty_id = sty.id
  AND str.say_code = 'CURR'
  AND str.khr_id = chrid
  AND str.kle_id = kleid
  AND ste.stream_element_date <= tadate
  AND sty.stream_type_purpose = strmPurpose;

  CURSOR l_bill_pmt_sty_csr(chrid NUMBER, kleid NUMBER, styid NUMBER, tadate DATE)
  IS
  SELECT
       sum(ste.amount)
  --FROM okl_streams str,
  FROM okl_streams_rep_v str, -- MGAAP 7263041
       okl_strm_elements ste,
       okl_strm_type_b sty
  WHERE ste.stm_id = str.id
  AND str.sty_id = sty.id
  AND str.say_code = 'CURR'
  AND str.khr_id = chrid
  AND str.kle_id = kleid
  AND sty.id = styid
  AND ste.stream_element_date <= tadate;

  CURSOR l_pmt_sty_csr(rgcode okc_rule_groups_b.rgd_code%TYPE,
                   rlcat  okc_rules_b.rule_information_category%TYPE,
                   chrId NUMBER,
                   cleId NUMBER)
  IS
  SELECT crl.id slh_id,
         crl.object1_id1
  FROM okc_rule_groups_b crg,
       okc_rules_b crl
  WHERE crl.rgp_id = crg.id
  AND crg.rgd_code = rgcode
  AND crl.rule_information_category = rlcat
  AND crg.dnz_chr_id = chrId
  AND crg.cle_id = cleId
  ORDER BY crl.rule_information1;

  CURSOR l_rl_csr2(rgcode okc_rule_groups_b.rgd_code%TYPE,
                   rlcat  okc_rules_b.rule_information_category%TYPE,
                   chrId NUMBER,
                   cleId NUMBER)
  IS
  SELECT crl.id slh_id,
         crl.object1_id1,
         crl.rule_information1,
         crl.rule_information2,
         crl.rule_information3,
         crl.rule_information5,
         crl.rule_information6,
         crl.rule_information7,
         crl.rule_information8,
         crl.rule_information13,
         crl.rule_information10
  FROM okc_rule_groups_b crg,
       okc_rules_b crl
  WHERE crl.rgp_id = crg.id
  AND crg.rgd_code = rgcode
  AND crl.rule_information_category = rlcat
  AND crg.dnz_chr_id = chrId
  AND crg.cle_id = cleId
  ORDER BY crl.rule_information1;

  CURSOR l_pdt_accrual_csr(chrId NUMBER)
  IS
  SELECT sty.id sty_id
  FROM OKL_STRM_TYPE_B sty,
       OKL_PROD_STRM_TYPES psty,
       OKL_K_HEADERS khr
  WHERE khr.id = chrId
  --AND khr.pdt_id = psty.pdt_id
  AND psty.pdt_id = NVL(p_product_id, khr.pdt_id) -- MGAAP 7263041
  AND psty.sty_id = sty.id
  AND psty.accrual_yn = 'Y';

  l_accrual_amt l_accrued_amt_csr%ROWTYPE;
  l_strm_for_line_rec l_strm_for_line_csr%ROWTYPE;
  l_pdt_accrual_rec l_pdt_accrual_csr%ROWTYPE;
  l_line_rec l_line_rec_csr%ROWTYPE;
  l_rl_rec2 l_rl_csr2%ROWTYPE;
  l_pmt_sty_rec l_pmt_sty_csr%ROWTYPE;


  TYPE p_pdt_accrual_rec_type IS RECORD(
        sty_id OKL_STRM_TYPE_B.ID%TYPE);

  TYPE p_pdt_accrual_tbl_type IS TABLE OF p_pdt_accrual_rec_type
        INDEX BY BINARY_INTEGER;

  l_pdt_accrual_tbl p_pdt_accrual_tbl_type;
  l_strm_for_line_tbl p_pdt_accrual_tbl_type;
  x_strm_for_line_tbl p_pdt_accrual_tbl_type;

  m BINARY_INTEGER := 0;
  n BINARY_INTEGER := 0;
  i BINARY_INTEGER := 0;
  j BINARY_INTEGER := 0;
  l_strm_exist VARCHAR2(1);
  l_passthrough_percent NUMBER := 0;
  l_pdt_accrual_sty NUMBER := 0;
  l_fee_or_service VARCHAR2(50);
  l_fee_type VARCHAR2(100);
  l_adjustment_amt NUMBER := 0;
  l_bill_amt NUMBER := 0;
  l_idc_bill_amt NUMBER := 0;
  l_exp_bill_amt NUMBER := 0;

  l_api_version                CONSTANT NUMBER := 1.0;
  l_api_name                   CONSTANT VARCHAR2(30) := 'GET_ACCRUAL_ADJUSTMENT';
  l_init_msg_list              VARCHAR2(4000) := OKL_API.G_FALSE;
  l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);



  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
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

    -- Get the stream marked for accrual at product level
    FOR l_pdt_accrual_rec IN l_pdt_accrual_csr(p_contract_id) LOOP
	  i := i + 1;
	  l_pdt_accrual_tbl(i).sty_id := l_pdt_accrual_rec.sty_id;
	END LOOP;


    IF p_line_id_tbl.COUNT > 0 THEN
      FOR i IN p_line_id_tbl.FIRST..p_line_id_tbl.LAST LOOP
	    l_strm_exist := 'N';
	    OPEN l_line_rec_csr(p_contract_id , p_line_id_tbl(i).id);
		FETCH l_line_rec_csr INTO l_line_rec;
		l_fee_or_service := l_line_rec.lty_code;
		l_fee_type := l_line_rec.fee_type;
		IF (l_fee_or_service = 'FEE') THEN
   -- Get all the streams generated for a particular fee line
	      j := 0;
		  FOR l_strm_for_line_rec IN l_strm_for_line_csr(p_contract_id,p_line_id_tbl(i).id) LOOP
		    j := j + 1;
		    l_strm_for_line_tbl(j).sty_id := l_strm_for_line_rec.sty_id;
		  END LOOP;
   -- Get those stream which has been generated for a line and marked for accrual at product
		  IF l_pdt_accrual_tbl.COUNT > 0 THEN
		    IF l_strm_for_line_tbl.COUNT > 0 THEN
			  FOR k IN l_strm_for_line_tbl.FIRST..l_strm_for_line_tbl.LAST LOOP
			    FOR l IN l_pdt_accrual_tbl.FIRST..l_pdt_accrual_tbl.LAST LOOP
				  IF l_strm_for_line_tbl(k).sty_id = l_pdt_accrual_tbl(l).sty_id THEN
				    n := n + 1;
					x_strm_for_line_tbl(n).sty_id := l_strm_for_line_tbl(k).sty_id;

				  END IF;
				END LOOP;
			  END LOOP;
			END IF;
		  END IF;
          IF x_strm_for_line_tbl.COUNT > 0 THEN
		    IF (l_fee_type = 'FINANCED') THEN

		      FOR p IN x_strm_for_line_tbl.FIRST..x_strm_for_line_tbl.LAST LOOP

		        OPEN l_accrued_amt_sty_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, x_strm_for_line_tbl(p).sty_id);
		        FETCH l_accrued_amt_sty_csr INTO l_accrual_amt;
		        CLOSE l_accrued_amt_sty_csr;
			    /*
		        OPEN l_accrued_amt_csr(chrid, p_line_id_tbl(i).id, tadate, 'LEASE_INCOME');
		        FETCH l_accrued_amt_csr INTO l_accrual_amt;
		        CLOSE l_accrued_amt_csr;
                */
		        OPEN l_bill_amt_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, 'INTEREST_PAYMENT');
		        FETCH l_bill_amt_csr INTO l_bill_amt;
		        CLOSE l_bill_amt_csr;
                l_adjustment_amt := l_accrual_amt.amount - l_bill_amt;

			    m:= m + 1;
			    x_accrual_adjustment_tbl(m).line_id := p_line_id_tbl(i).id;
			    x_accrual_adjustment_tbl(m).sty_id  := l_accrual_amt.sty_id;
			    x_accrual_adjustment_tbl(m).amount  := l_adjustment_amt;
		  	  END LOOP;
		    ELSIF (l_fee_type = 'ROLLOVER') THEN
			  FOR p IN x_strm_for_line_tbl.FIRST..x_strm_for_line_tbl.LAST LOOP

		        OPEN l_accrued_amt_sty_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, x_strm_for_line_tbl(p).sty_id);
		        FETCH l_accrued_amt_sty_csr INTO l_accrual_amt;
		        CLOSE l_accrued_amt_sty_csr;
                /*
		        OPEN l_accrued_amt_csr(chrid, p_line_id_tbl(i).id, tadate, 'LEASE_INCOME');
		        FETCH l_accrued_amt_csr INTO l_accrual_amt;
		        CLOSE l_accrued_amt_csr;
                */
		        OPEN l_bill_amt_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, 'INTEREST_PAYMENT');
		        FETCH l_bill_amt_csr INTO l_bill_amt;
		        CLOSE l_bill_amt_csr;
                l_adjustment_amt := l_accrual_amt.amount - l_bill_amt;

			    m:= m + 1;
			    x_accrual_adjustment_tbl(m).line_id := p_line_id_tbl(i).id;
			    x_accrual_adjustment_tbl(m).sty_id  := l_accrual_amt.sty_id;
			    x_accrual_adjustment_tbl(m).amount  := l_adjustment_amt;
			  END LOOP;

		    ELSIF ((l_fee_type = 'MISCELLANEOUS') OR (l_fee_type = 'EXPENSE')) THEN
		      IF (nvl(l_line_rec.initial_direct_cost,0) > 0) THEN
			    IF  NVL(l_line_rec.amount,0) <> NVL(l_line_rec.initial_direct_cost,0) THEN

		          OPEN l_accrued_amt_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, 'AMORTIZED_FEE_EXPENSE');
		          FETCH l_accrued_amt_csr INTO l_accrual_amt;
		          CLOSE l_accrued_amt_csr;

				  IF l_accrual_amt.sty_id IS NOT NULL THEN
			        FOR l IN l_pdt_accrual_tbl.FIRST..l_pdt_accrual_tbl.LAST LOOP
				      IF l_accrual_amt.sty_id = l_pdt_accrual_tbl(l).sty_id THEN
                        l_strm_exist := 'Y';
				      END IF;
				    END LOOP;
				  END IF;

			      IF l_strm_exist = 'Y' THEN
                    OKL_FUNDING_PVT.contract_fee_canbe_funded(
                                         p_api_version    => l_api_version
                                        ,p_init_msg_list  => l_init_msg_list
                                        ,x_return_status  => l_return_status
                                        ,x_msg_count      => l_msg_count
                                        ,x_msg_data       => l_msg_data
                                        ,x_value          => l_bill_amt
                                        ,p_contract_id    => p_contract_id
                                        ,p_fee_line_id    => p_line_id_tbl(i).id
                                        ,p_effective_date => p_adjustment_date
                                         );

                    l_idc_bill_amt := l_bill_amt*(l_line_rec.initial_direct_cost/l_line_rec.amount);
				    l_exp_bill_amt := l_bill_amt - l_idc_bill_amt;
                    l_adjustment_amt := l_accrual_amt.amount - l_idc_bill_amt;

			        m:= m + 1;
			        x_accrual_adjustment_tbl(m).line_id := p_line_id_tbl(i).id;
			        x_accrual_adjustment_tbl(m).sty_id  := l_accrual_amt.sty_id;
			        x_accrual_adjustment_tbl(m).amount  := l_adjustment_amt;
	              END IF;

-- Code for expense fee
                  l_strm_exist := 'N';

		          OPEN l_accrued_amt_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, 'ACCRUED_FEE_EXPENSE');
		          FETCH l_accrued_amt_csr INTO l_accrual_amt;
		          CLOSE l_accrued_amt_csr;

				  IF l_accrual_amt.sty_id IS NOT NULL THEN
			        FOR l IN l_pdt_accrual_tbl.FIRST..l_pdt_accrual_tbl.LAST LOOP
				      IF l_accrual_amt.sty_id = l_pdt_accrual_tbl(l).sty_id THEN
                        l_strm_exist := 'Y';
				      END IF;
				    END LOOP;
				  END IF;

				  IF l_strm_exist = 'Y' THEN
				    l_adjustment_amt := l_accrual_amt.amount - l_exp_bill_amt;
			        m:= m + 1;
			        x_accrual_adjustment_tbl(m).line_id := p_line_id_tbl(i).id;
			        x_accrual_adjustment_tbl(m).sty_id  := l_accrual_amt.sty_id;
			        x_accrual_adjustment_tbl(m).amount  := l_adjustment_amt;
				  END IF;
			    ELSE
				  l_strm_exist := 'N';
		          OPEN l_accrued_amt_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, 'AMORTIZED_FEE_EXPENSE');
		          FETCH l_accrued_amt_csr INTO l_accrual_amt;
		          CLOSE l_accrued_amt_csr;

				  IF l_accrual_amt.sty_id IS NOT NULL THEN
			        FOR l IN l_pdt_accrual_tbl.FIRST..l_pdt_accrual_tbl.LAST LOOP
				      IF l_accrual_amt.sty_id = l_pdt_accrual_tbl(l).sty_id THEN
                        l_strm_exist := 'Y';
				      END IF;
				    END LOOP;
				  END IF;

				  IF l_strm_exist = 'Y' THEN
                    OKL_FUNDING_PVT.contract_fee_canbe_funded(
                                         p_api_version    => l_api_version
                                        ,p_init_msg_list  => l_init_msg_list
                                        ,x_return_status  => l_return_status
                                        ,x_msg_count      => l_msg_count
                                        ,x_msg_data       => l_msg_data
                                        ,x_value          => l_bill_amt
                                        ,p_contract_id    => p_contract_id
                                        ,p_fee_line_id    => p_line_id_tbl(i).id
                                        ,p_effective_date => p_adjustment_date
                                         );

                    l_idc_bill_amt := l_bill_amt;

                    l_adjustment_amt := l_accrual_amt.amount - l_idc_bill_amt;
			        m:= m + 1;
			        x_accrual_adjustment_tbl(m).line_id := p_line_id_tbl(i).id;
			        x_accrual_adjustment_tbl(m).sty_id  := l_accrual_amt.sty_id;
			        x_accrual_adjustment_tbl(m).amount  := l_adjustment_amt;
				  END IF;

			    END IF;
			  ELSE
			    l_strm_exist := 'N';
                OPEN l_accrued_amt_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, 'ACCRUED_FEE_EXPENSE');
		        FETCH l_accrued_amt_csr INTO l_accrual_amt;
		        CLOSE l_accrued_amt_csr;

				IF l_accrual_amt.sty_id IS NOT NULL THEN
			      FOR l IN l_pdt_accrual_tbl.FIRST..l_pdt_accrual_tbl.LAST LOOP
				    IF l_accrual_amt.sty_id = l_pdt_accrual_tbl(l).sty_id THEN
                       l_strm_exist := 'Y';
				    END IF;
				  END LOOP;
				END IF;

				IF l_strm_exist = 'Y' THEN
                    OKL_FUNDING_PVT.contract_fee_canbe_funded(
                                         p_api_version    => l_api_version
                                        ,p_init_msg_list  => l_init_msg_list
                                        ,x_return_status  => l_return_status
                                        ,x_msg_count      => l_msg_count
                                        ,x_msg_data       => l_msg_data
                                        ,x_value          => l_bill_amt
                                        ,p_contract_id    => p_contract_id
                                        ,p_fee_line_id    => p_line_id_tbl(i).id
                                        ,p_effective_date => p_adjustment_date
                                         );


		          l_adjustment_amt := l_accrual_amt.amount - l_bill_amt;
			      m:= m + 1;
			      x_accrual_adjustment_tbl(m).line_id := p_line_id_tbl(i).id;
			      x_accrual_adjustment_tbl(m).sty_id  := l_accrual_amt.sty_id;
			      x_accrual_adjustment_tbl(m).amount  := l_adjustment_amt;
				END IF;
			  END IF;
			  IF (l_fee_type = 'MISCELLANEOUS') THEN
			    l_strm_exist := 'N';
                OPEN l_pmt_sty_csr('LALEVL','LASLH',p_contract_id, p_line_id_tbl(i).id);
		        FETCH l_pmt_sty_csr INTO l_pmt_sty_rec;
		        CLOSE l_pmt_sty_csr;

		        OPEN l_accrued_amt_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, 'ACCRUED_FEE_INCOME');
		        FETCH l_accrued_amt_csr INTO l_accrual_amt;
		        CLOSE l_accrued_amt_csr;

				IF l_accrual_amt.sty_id IS NOT NULL THEN
			      FOR l IN l_pdt_accrual_tbl.FIRST..l_pdt_accrual_tbl.LAST LOOP
				    IF l_accrual_amt.sty_id = l_pdt_accrual_tbl(l).sty_id THEN
                       l_strm_exist := 'Y';
				    END IF;
				  END LOOP;
				END IF;

                IF l_strm_exist = 'Y' THEN
		          OPEN l_bill_pmt_sty_csr(p_contract_id, p_line_id_tbl(i).id, l_pmt_sty_rec.object1_id1,p_adjustment_date);
		          FETCH l_bill_pmt_sty_csr INTO l_bill_amt;
		          CLOSE l_bill_pmt_sty_csr;
                  l_adjustment_amt := l_accrual_amt.amount - l_bill_amt;
			      m:= m + 1;
			      x_accrual_adjustment_tbl(m).line_id := p_line_id_tbl(i).id;
			      x_accrual_adjustment_tbl(m).sty_id  := l_accrual_amt.sty_id;
			      x_accrual_adjustment_tbl(m).amount  := l_adjustment_amt;
		        END IF;
		      END IF;


		    ELSIF (l_fee_type = 'INCOME' ) THEN

              OPEN l_pmt_sty_csr('LALEVL','LASLH',p_contract_id, p_line_id_tbl(i).id);
		      FETCH l_pmt_sty_csr INTO l_pmt_sty_rec;
		      CLOSE l_pmt_sty_csr;

		      OPEN l_accrued_amt_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, 'AMORTIZE_FEE_INCOME');
		      FETCH l_accrued_amt_csr INTO l_accrual_amt;
		      CLOSE l_accrued_amt_csr;

			  IF l_accrual_amt.sty_id IS NOT NULL THEN
			    FOR l IN l_pdt_accrual_tbl.FIRST..l_pdt_accrual_tbl.LAST LOOP
				  IF l_accrual_amt.sty_id = l_pdt_accrual_tbl(l).sty_id THEN
                     l_strm_exist := 'Y';
				  END IF;
				END LOOP;
			  END IF;

			  IF l_strm_exist = 'Y' THEN
		        OPEN l_bill_pmt_sty_csr(p_contract_id, p_line_id_tbl(i).id, l_pmt_sty_rec.object1_id1,p_adjustment_date);
		        FETCH l_bill_pmt_sty_csr INTO l_bill_amt;
		        CLOSE l_bill_pmt_sty_csr;
                l_adjustment_amt := l_accrual_amt.amount - l_bill_amt;

			    m:= m + 1;
			    x_accrual_adjustment_tbl(m).line_id := p_line_id_tbl(i).id;
			    x_accrual_adjustment_tbl(m).sty_id  := l_accrual_amt.sty_id;
			    x_accrual_adjustment_tbl(m).amount  := l_adjustment_amt;
			  END IF;

		    ELSIF (l_fee_type = 'PASSTHROUGH'  ) THEN
		      OPEN  l_rl_csr2 ( 'LAPSTH', 'LAPTPR', TO_NUMBER(p_contract_id), p_line_id_tbl(i).id );
              FETCH l_rl_csr2 INTO l_rl_rec2;
              CLOSE l_rl_csr2;
			  l_passthrough_percent := nvl( l_rl_rec2.rule_information1, 100.0 );
			  IF l_passthrough_percent < 100 THEN

                OPEN l_pmt_sty_csr('LALEVL','LASLH',p_contract_id, p_line_id_tbl(i).id);
		        FETCH l_pmt_sty_csr INTO l_pmt_sty_rec;
		        CLOSE l_pmt_sty_csr;

		        OPEN l_accrued_amt_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, 'PASS_THRU_REV_ACCRUAL');
		        FETCH l_accrued_amt_csr INTO l_accrual_amt;
		        CLOSE l_accrued_amt_csr;

			    IF l_accrual_amt.sty_id IS NOT NULL THEN
			      FOR l IN l_pdt_accrual_tbl.FIRST..l_pdt_accrual_tbl.LAST LOOP
				    IF l_accrual_amt.sty_id = l_pdt_accrual_tbl(l).sty_id THEN
                       l_strm_exist := 'Y';
				    END IF;
				  END LOOP;
			    END IF;

				IF l_strm_exist = 'Y' THEN

  		          OPEN l_bill_pmt_sty_csr(p_contract_id, p_line_id_tbl(i).id, l_pmt_sty_rec.object1_id1,p_adjustment_date);
		          FETCH l_bill_pmt_sty_csr INTO l_bill_amt;
		          CLOSE l_bill_pmt_sty_csr;
                  l_adjustment_amt := l_accrual_amt.amount - l_bill_amt;

			      m:= m + 1;
			      x_accrual_adjustment_tbl(m).line_id := p_line_id_tbl(i).id;
			      x_accrual_adjustment_tbl(m).sty_id  := l_accrual_amt.sty_id;
			      x_accrual_adjustment_tbl(m).amount  := l_adjustment_amt;
	            END IF;

				l_strm_exist := 'N';
		        OPEN l_accrued_amt_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, 'PASS_THRU_EXP_ACCRUAL');
		        FETCH l_accrued_amt_csr INTO l_accrual_amt;
		        CLOSE l_accrued_amt_csr;

			    IF l_accrual_amt.sty_id IS NOT NULL THEN
			      FOR l IN l_pdt_accrual_tbl.FIRST..l_pdt_accrual_tbl.LAST LOOP
				    IF l_accrual_amt.sty_id = l_pdt_accrual_tbl(l).sty_id THEN
                       l_strm_exist := 'Y';
				    END IF;
				  END LOOP;
			    END IF;
			    IF l_strm_exist = 'Y' THEN
			      l_bill_amt := l_bill_amt * l_passthrough_percent/100 ;
                  l_adjustment_amt := l_accrual_amt.amount - l_bill_amt;

			      m:= m + 1;
			      x_accrual_adjustment_tbl(m).line_id := p_line_id_tbl(i).id;
			      x_accrual_adjustment_tbl(m).sty_id  := l_accrual_amt.sty_id;
			      x_accrual_adjustment_tbl(m).amount  := l_adjustment_amt;
				END IF;
              END IF;


            END IF;
		    --ELSIF (l_fee_type =   ) THEN
		  END IF;
		ELSIF (l_fee_or_service = 'SOLD_SERVICE') THEN

          OPEN l_pmt_sty_csr('LALEVL','LASLH',p_contract_id, p_line_id_tbl(i).id);
		  FETCH l_pmt_sty_csr INTO l_pmt_sty_rec;
		  CLOSE l_pmt_sty_csr;

		  OPEN l_accrued_amt_csr(p_contract_id, p_line_id_tbl(i).id, p_adjustment_date, 'SERVICE_INCOME');
		  FETCH l_accrued_amt_csr INTO l_accrual_amt;
		  CLOSE l_accrued_amt_csr;

		  IF l_accrual_amt.sty_id IS NOT NULL THEN
		    FOR l IN l_pdt_accrual_tbl.FIRST..l_pdt_accrual_tbl.LAST LOOP
			  IF l_accrual_amt.sty_id = l_pdt_accrual_tbl(l).sty_id THEN
                l_strm_exist := 'Y';
			  END IF;
		    END LOOP;
		  END IF;

		  IF l_strm_exist = 'Y' THEN
		    OPEN l_bill_pmt_sty_csr(p_contract_id, p_line_id_tbl(i).id, l_pmt_sty_rec.object1_id1,p_adjustment_date);
		    FETCH l_bill_pmt_sty_csr INTO l_bill_amt;
		    CLOSE l_bill_pmt_sty_csr;
            l_adjustment_amt := l_accrual_amt.amount - l_bill_amt;

			m:= m + 1;
			x_accrual_adjustment_tbl(m).line_id := p_line_id_tbl(i).id;
			x_accrual_adjustment_tbl(m).sty_id  := l_accrual_amt.sty_id;
			x_accrual_adjustment_tbl(m).amount  := l_adjustment_amt;
		  END IF;

		END IF;
		CLOSE l_line_rec_csr;

	  END LOOP;
	END IF;
    --NULL;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
          IF l_line_rec_csr%ISOPEN THEN
            CLOSE l_line_rec_csr;
          END IF;
          IF l_strm_for_line_csr%ISOPEN THEN
            CLOSE l_strm_for_line_csr;
          END IF;
          IF l_accrued_amt_csr%ISOPEN THEN
            CLOSE l_accrued_amt_csr;
          END IF;
          IF l_accrued_amt_sty_csr%ISOPEN THEN
            CLOSE l_accrued_amt_sty_csr;
          END IF;
          IF l_bill_amt_csr%ISOPEN THEN
            CLOSE l_bill_amt_csr;
          END IF;
          IF l_bill_pmt_sty_csr%ISOPEN THEN
            CLOSE l_bill_pmt_sty_csr;
          END IF;
          IF l_pmt_sty_csr%ISOPEN THEN
            CLOSE l_pmt_sty_csr;
          END IF;
          IF l_rl_csr2%ISOPEN THEN
            CLOSE l_rl_csr2;
          END IF;
          IF l_pdt_accrual_csr%ISOPEN THEN
            CLOSE l_pdt_accrual_csr;
          END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          IF l_line_rec_csr%ISOPEN THEN
            CLOSE l_line_rec_csr;
          END IF;
          IF l_strm_for_line_csr%ISOPEN THEN
            CLOSE l_strm_for_line_csr;
          END IF;
          IF l_accrued_amt_csr%ISOPEN THEN
            CLOSE l_accrued_amt_csr;
          END IF;
          IF l_accrued_amt_sty_csr%ISOPEN THEN
            CLOSE l_accrued_amt_sty_csr;
          END IF;
          IF l_bill_amt_csr%ISOPEN THEN
            CLOSE l_bill_amt_csr;
          END IF;
          IF l_bill_pmt_sty_csr%ISOPEN THEN
            CLOSE l_bill_pmt_sty_csr;
          END IF;
          IF l_pmt_sty_csr%ISOPEN THEN
            CLOSE l_pmt_sty_csr;
          END IF;
          IF l_rl_csr2%ISOPEN THEN
            CLOSE l_rl_csr2;
          END IF;
          IF l_pdt_accrual_csr%ISOPEN THEN
            CLOSE l_pdt_accrual_csr;
          END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
          IF l_line_rec_csr%ISOPEN THEN
            CLOSE l_line_rec_csr;
          END IF;
          IF l_strm_for_line_csr%ISOPEN THEN
            CLOSE l_strm_for_line_csr;
          END IF;
          IF l_accrued_amt_csr%ISOPEN THEN
            CLOSE l_accrued_amt_csr;
          END IF;
          IF l_accrued_amt_sty_csr%ISOPEN THEN
            CLOSE l_accrued_amt_sty_csr;
          END IF;
          IF l_bill_amt_csr%ISOPEN THEN
            CLOSE l_bill_amt_csr;
          END IF;
          IF l_bill_pmt_sty_csr%ISOPEN THEN
            CLOSE l_bill_pmt_sty_csr;
          END IF;
          IF l_pmt_sty_csr%ISOPEN THEN
            CLOSE l_pmt_sty_csr;
          END IF;
          IF l_rl_csr2%ISOPEN THEN
            CLOSE l_rl_csr2;
          END IF;
          IF l_pdt_accrual_csr%ISOPEN THEN
            CLOSE l_pdt_accrual_csr;
          END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END get_accrual_adjustment;
END OKL_ACCRUAL_SEC_PVT;

/
