--------------------------------------------------------
--  DDL for Package Body OKL_LOSS_PROV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LOSS_PROV_PVT" AS
/* $Header: OKLRLPVB.pls 120.28.12010000.3 2008/09/05 22:46:35 smereddy ship $ */

-- Bug 5935176  dpsingh for AE signature Uptake  start
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
-- Bug 5935176  dpsingh for AE signature Uptake  end
  -- this function is used to calculate net book value for a contract
  FUNCTION calculate_cntrct_nbv (p_cntrct_id IN  NUMBER) RETURN NUMBER
  IS
  l_asset_id                   OKX_ASSET_LINES_V.ASSET_ID%TYPE;
  l_original_cost              OKX_ASSET_LINES_V.ORIGINAL_COST%TYPE;
  l_deprn_amount               NUMBER := 0;
  l_asset_book_value           NUMBER := 0;
  l_net_book_value             NUMBER := 0;
  l_asset_number               OKX_ASSET_LINES_V.ASSET_NUMBER%TYPE;
  l_corporate_book             OKX_ASSET_LINES_V.CORPORATE_BOOK%TYPE;

  /* cursor for getting the assets and their original cost */
  CURSOR okl_cntrct_assets_csr(p_khr_id IN NUMBER) IS
  SELECT asset_id, original_cost, asset_number, corporate_book
  FROM okx_asset_lines_v ast
  WHERE ast.dnz_chr_id = p_khr_id;

  /* cursor to get the depreciation amount */
  CURSOR depr_csr(p_asset_id NUMBER, p_book_type_code VARCHAR2) IS
  SELECT MAX(dpr.deprn_reserve)
  FROM OKX_AST_DPRTNS_V dpr
  WHERE asset_id = p_asset_id
  AND book_type_code = p_book_type_code;

  BEGIN

       /* loop for assets for a contract */
       FOR cntrct_assets_rec IN okl_cntrct_assets_csr(p_cntrct_id)
       LOOP
          /* get the asset id and original cost */
          l_asset_id := cntrct_assets_rec.asset_id;
          l_original_cost := cntrct_assets_rec.original_cost;
          l_asset_number := cntrct_assets_rec.asset_number;
          l_corporate_book := cntrct_assets_rec.corporate_book;

          /* retrieve the depreciation amount */
          OPEN depr_csr(l_asset_id, l_corporate_book);
          FETCH depr_csr INTO l_deprn_amount;
          CLOSE depr_csr;
          IF l_deprn_amount IS NULL THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_GLP_DEPR_ERROR',
                                  p_token1       => 'ASSET_NUMBER',
								  p_token1_value => l_asset_number);
			  RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          /* calculate the asset book value */
          l_asset_book_value := NVL(l_original_cost,0) - NVL(l_deprn_amount,0);

          /* add the asset book value to the contract net book value */
          l_net_book_value := l_net_book_value + l_asset_book_value;

       END LOOP; /* end of loop for assets for a contract */

      /* return the calculated net book value */
      RETURN(l_net_book_value);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     -- return null because of error
	 RETURN(NULL);

     WHEN OTHERS THEN
     IF depr_csr%ISOPEN THEN
       CLOSE depr_csr;
     END IF;
     -- return null because of error
	 RETURN(NULL);
  END calculate_cntrct_nbv;


  -- this function is used to calculate total reserve amount for a contract
  FUNCTION calculate_cntrct_rsrv_amt (p_cntrct_id IN  NUMBER) RETURN NUMBER
  IS
  l_tot_rsrv_amt             NUMBER := 0;

  /* cursor to get the total reserve amount */
  CURSOR rsrv_amt_csr(p_khr_id NUMBER) IS
  SELECT SUM(NVL(AMOUNT,0)) tot_res_amt
  FROM OKL_TRX_CONTRACTS
  WHERE KHR_ID = p_khr_id
  AND tcn_type = 'PSP'
  --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
  AND tsu_code = 'PROCESSED'
  -- SGIYER.MGAAP Changes for Bug 7263041
  AND representation_type = 'PRIMARY';

  BEGIN

      /* retrieve the residual amount */
      OPEN rsrv_amt_csr(p_cntrct_id);
      FETCH rsrv_amt_csr INTO l_tot_rsrv_amt;
      CLOSE rsrv_amt_csr;

      RETURN(l_tot_rsrv_amt);

  EXCEPTION
     WHEN OTHERS THEN
      IF rsrv_amt_csr%ISOPEN THEN
        CLOSE rsrv_amt_csr;
      END IF;
      /* return null because of error */
      RETURN(NULL);

  END calculate_cntrct_rsrv_amt;

  -- this function is used to calculate net investment value for a contract
  FUNCTION calculate_cntrct_niv (
        p_cntrct_id       IN  NUMBER
       ,p_loss_date       IN  DATE) RETURN NUMBER
  IS
  l_formula_name           CONSTANT VARCHAR2(30) := 'LP_NET_INVESTMENT_VALUE';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_init_msg_list          VARCHAR2(20) DEFAULT Okl_Api.G_FALSE;
  l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_net_invest_value       NUMBER := 0;
  l_ctxt_val_tbl           Okl_Account_Dist_Pub.ctxt_val_tbl_type;

  BEGIN

    l_ctxt_val_tbl(1).NAME := 'p_provision_date';
    l_ctxt_val_tbl(1).VALUE := TO_CHAR(p_loss_date, 'MM/DD/YYYY');

    /* use the formula engine for the calculation */
    Okl_Execute_Formula_Pub.EXECUTE
      (p_api_version           => l_api_version
      ,p_init_msg_list         => l_init_msg_list
      ,x_return_status         => l_return_status
      ,x_msg_count             => l_msg_count
      ,x_msg_data              => l_msg_data
      ,p_formula_name          => l_formula_name
      ,p_contract_id           => p_cntrct_id
      ,p_line_id               => NULL
      ,p_additional_parameters => l_ctxt_val_tbl
      ,x_value                 => l_net_invest_value);

    -- store the highest degree of error
    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      -- need to leave
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSE
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;


      /* return the calculated net book value */
      RETURN(l_net_invest_value);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       -- return null because of error
       RETURN(NULL);
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       -- return null because of error
       RETURN(NULL);

     WHEN OTHERS THEN
       -- return null because of error
       RETURN(NULL);

  END calculate_cntrct_niv;

 FUNCTION get_contract_principal_balance(p_cntrct_id IN NUMBER,
                                         p_period_start_date IN DATE,
                                         p_period_end_date   IN DATE)
          RETURN NUMBER IS

    l_period_start_date   DATE := p_period_start_date;
    l_period_end_date     DATE := p_period_end_date;
    l_principal_bal       NUMBER;
    l_contract_number     VARCHAR2(2000);
    l_last_int_calc_date  DATE;
    l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_kle_id              NUMBER;
    l_prin_bal_id         NUMBER;

    -- cursor to get the contract number
    CURSOR contract_num_csr IS
    SELECT contract_number
      FROM OKC_K_HEADERS_B
     WHERE id = p_cntrct_id;

  CURSOR principal_bal_csr(p_ctr_id NUMBER, p_start_date DATE, p_end_date DATE, p_prin_bal_id NUMBER) IS
     SELECT SUM(ste.amount)
       FROM OKL_STRM_TYPE_B sty,
            OKL_STREAMS stm,
            OKL_STRM_ELEMENTS ste
     WHERE stm.khr_id = p_ctr_id
       AND stm.active_yn = 'Y'
       AND stm.say_code = 'CURR'
       AND sty.id = p_prin_bal_id
       AND stm.sty_id = sty.id
       AND ste.stm_id = stm.id
       AND ste.stream_element_date BETWEEN p_start_date AND p_end_date;

-- cursor for retrieveing earlier principal balance amount if principal balance
-- for given period is not found
  CURSOR prior_prin_bal_csr(p_ctr_id NUMBER, p_start_date DATE, p_prin_bal_id NUMBER) IS
     SELECT SUM(ste.amount)
     FROM OKL_STRM_TYPE_B sty,
          OKL_STREAMS stm,
          OKL_STRM_ELEMENTS ste
    WHERE stm.khr_id = p_ctr_id
      AND stm.active_yn = 'Y'
      AND stm.say_code = 'CURR'
      AND sty.id = p_prin_bal_id
      AND stm.sty_id = sty.id
      AND ste.stm_id = stm.id
      AND ste.stream_element_date = (SELECT MAX(stream_element_date)
                                       FROM OKL_STRM_TYPE_B sty,
                                            OKL_STREAMS stm,
                                            OKL_STRM_ELEMENTS ste
                                      WHERE stm.khr_id = p_ctr_id
                                        AND stm.active_yn = 'Y'
                                        AND stm.say_code = 'CURR'
                                        AND sty.id = p_prin_bal_id
                                        AND stm.sty_id = sty.id
                                        AND ste.stm_id = stm.id
                                        AND stream_element_date < p_start_date);

  BEGIN

    FOR i IN contract_num_csr
    LOOP
      l_contract_number := i.contract_number;
    END LOOP;

    IF l_contract_number IS NULL THEN
      Okl_Api.set_message(p_app_name => g_app_name,
                          p_msg_name => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_period_end_date IS NULL THEN
        Okl_Api.Set_Message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_FE_PERD_END_DATE');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    IF l_period_start_date IS NULL THEN
        Okl_Api.Set_Message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_FE_PERD_START_DATE');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    OKL_STREAMS_UTIL.get_dependent_stream_type(
                                      p_khr_id                => p_cntrct_id,
                                      p_primary_sty_purpose   => 'RENT',
                                      p_dependent_sty_purpose => 'PRINCIPAL_BALANCE',
                                      x_return_status         => l_return_status,
                                      x_dependent_sty_id      => l_prin_bal_id);

         IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
             Okl_Api.set_message(p_app_name     => g_app_name,
                                 p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                                 p_token1       => 'STREAM_NAME',
                                 p_token1_value => 'PRINCIPAL BALANCE');
             RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;

    OPEN principal_bal_csr (p_cntrct_id, l_period_start_date, l_period_end_date, l_prin_bal_id);
    FETCH principal_bal_csr INTO l_principal_bal;
    CLOSE principal_bal_csr;

      -- If principal balance not found for date range, get prior principal balance.
      -- As per MMITTAL.
	  IF l_principal_bal IS NULL THEN
         OPEN prior_prin_bal_csr(p_cntrct_id, l_period_start_date,l_prin_bal_id);
         FETCH prior_prin_bal_csr INTO l_principal_bal;
         CLOSE prior_prin_bal_csr;

         IF l_principal_bal IS NULL THEN
           Okl_Api.Set_Message(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_AGN_FE_PRIN_BAL',
                               p_token1       => 'CONTRACT_NUMBER',
                               p_token1_value => l_contract_number);
           RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    RETURN l_principal_bal;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      RETURN NULL;

    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
      RETURN NULL;
  END get_contract_principal_balance;

  -- this function is used to calculate principal balance for a contract
  FUNCTION calculate_cntrct_prin_bal (
        p_cntrct_id         IN  NUMBER
       ,p_period_start_date IN  DATE
	   ,p_period_end_date   IN  DATE ) RETURN NUMBER
  IS
    l_ctxt_val_tbl      Okl_Execute_Formula_Pub.ctxt_val_tbl_type;
    l_principal_balance NUMBER;
  BEGIN
    --changed pl/sql table structure from l_ctxt_val_tbl to g_additional_parameters
    -- Bug 3348162. Added format mask.
    Okl_Execute_Formula_Pub.g_additional_parameters(1).name := 'p_period_start_date';
    Okl_Execute_Formula_Pub.g_additional_parameters(1).value := TO_CHAR(p_period_start_date, 'MM/DD/YYYY');
    Okl_Execute_Formula_Pub.g_additional_parameters(2).name := 'p_period_end_date';
    Okl_Execute_Formula_Pub.g_additional_parameters(2).value := TO_CHAR(p_period_end_date, 'MM/DD/YYYY');

	l_principal_balance := OKL_SEEDED_FUNCTIONS_PVT.CONTRACT_PRINCIPAL_BALANCE
	                       (p_khr_id => p_cntrct_id,
						    p_kle_id => NULL);

    RETURN l_principal_balance;

  EXCEPTION
     WHEN OTHERS THEN
      /* return null because of error */
      RETURN NULL;

  END calculate_cntrct_prin_bal;


  -- this function is used to calculate net book value or net investment value
  -- or principal balance for a contract based on the deal type provided.
  FUNCTION calculate_capital_balance(p_cntrct_id IN  NUMBER
                                ,p_deal_type IN VARCHAR2) RETURN NUMBER
  IS

    l_oper_lease             CONSTANT OKL_K_HEADERS.DEAL_TYPE%TYPE         := 'LEASEOP';
    l_df_lease               CONSTANT OKL_K_HEADERS.DEAL_TYPE%TYPE         := 'LEASEDF';
    l_sales_lease            CONSTANT OKL_K_HEADERS.DEAL_TYPE%TYPE         := 'LEASEST';
    l_loan_lease             CONSTANT OKL_K_HEADERS.DEAL_TYPE%TYPE         := 'LOAN';
    l_capital_bal            NUMBER := 0;
    l_original_amt           NUMBER := 0;
    l_converted_amt          NUMBER := 0;
    l_loss_date              DATE := TRUNC(sysdate);
    l_period_start_date      DATE;
    l_period_end_date        DATE;
    l_period_name            VARCHAR2(2000);
    l_func_currency_code     OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
    l_khr_currency_code      OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
    x_contract_currency	     OKL_K_HEADERS_FULL_V.currency_code%TYPE;
    x_currency_conversion_type OKL_K_HEADERS_FULL_V.currency_conversion_type%TYPE;
    x_currency_conversion_rate OKL_K_HEADERS_FULL_V.currency_conversion_rate%TYPE;
    x_currency_conversion_date OKL_K_HEADERS_FULL_V.currency_conversion_date%TYPE;

    -- Cursor to select currency information for the contract. Bug 2712001
    CURSOR currency_info_csr(p_khr_id NUMBER) IS
    SELECT currency_code
    FROM OKC_K_HEADERS_B
    WHERE id = p_khr_id;

	-- cursor to get the rev rec method .. racheruv. Bug 6342556
    CURSOR get_rev_rec_method_csr(p_chr_id NUMBER) IS
    SELECT pdt.quality_val revenue_recognition_method
    FROM OKL_PROD_QLTY_VAL_UV pdt,
         OKL_K_HEADERS_FULL_V khr
    WHERE khr.id = p_chr_id
    AND   khr.pdt_id = pdt.pdt_id
    AND   pdt.quality_name = 'REVENUE_RECOGNITION_METHOD';

	-- cursor to get the last interest calc date .. racheruv. Bug 6342556
	CURSOR last_int_date_csr IS
	SELECT TRUNC(DATE_LAST_INTERIM_INTEREST_CAL)
	FROM OKL_K_HEADERS
	WHERE ID = p_cntrct_id;

    l_last_int_calc_date    date;
    l_rev_rec_method_code   varchar2(30);

  BEGIN
    /* calculate the nbv loss if contract is an operating lease */
    IF p_deal_type = l_oper_lease THEN

    OPEN currency_info_csr(p_cntrct_id);
	FETCH currency_info_csr INTO l_khr_currency_code;
    CLOSE currency_info_csr;
    IF l_khr_currency_code IS NULL THEN
	  RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    -- retrieve the functional currency code
    l_func_currency_code := Okl_Accounting_Util.GET_FUNC_CURR_CODE;
    IF l_func_currency_code IS NULL THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_original_amt := calculate_cntrct_nbv (p_cntrct_id => p_cntrct_id);

    -- convert NBV to contract currency. Bug 2712001
	IF l_func_currency_code <> l_khr_currency_code THEN
      OKL_ACCOUNTING_UTIL.convert_to_contract_currency
                 (p_khr_id  		  	=> p_cntrct_id,
                  p_from_currency   	=> l_func_currency_code,
                  p_transaction_date 	=> l_loss_date,
                  p_amount 			    => l_original_amt,
                  x_contract_currency	=> x_contract_currency,
                  x_currency_conversion_type => x_currency_conversion_type,
                  x_currency_conversion_rate => x_currency_conversion_rate,
                  x_currency_conversion_date => x_currency_conversion_date,
                  x_converted_amount 	=> l_converted_amt);
      IF l_converted_amt IS NULL THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      ELSE
        l_capital_bal := l_converted_amt;
      END IF;
    ELSE
      l_capital_bal := l_original_amt;
    END IF;

  /* calculate the niv loss if contract is a direct finance lease or sales lease */
  ELSIF p_deal_type = l_df_lease OR p_deal_type = l_sales_lease THEN
       l_capital_bal  := calculate_cntrct_niv (p_cntrct_id => p_cntrct_id
                                              ,p_loss_date => l_loss_date);

   /* calculate the pb loss loss if contract is loan */
  ELSIF p_deal_type = l_loan_lease THEN
    -- get the rev rec method
    OPEN get_rev_rec_method_csr(p_cntrct_id);
    FETCH get_rev_rec_method_csr INTO l_rev_rec_method_code;
    CLOSE get_rev_rec_method_csr;

    -- if rev_rec_method is 'STREAMS' then use the period start and end dates else use
    -- the last interest calc date and get the principal balance.. racheruv. Bug 6342556
    IF l_rev_rec_method_code = 'STREAMS' THEN
       -- Get period end date for principal balance
       Okl_Accounting_Util.GET_PERIOD_INFO(l_loss_date,l_period_name,l_period_start_date,l_period_end_date);
       l_capital_bal := get_contract_principal_balance(p_cntrct_id => p_cntrct_id
                                                      ,p_period_start_date => l_period_start_date
                                                      ,p_period_end_date => l_period_end_date);

    ELSIF l_rev_rec_method_code in ('ESTIMATED_AND_BILLED', 'ACTUAL') THEN
       -- get the last interest calc date.
       OPEN last_int_date_csr;
       FETCH last_int_date_csr into l_last_int_calc_date;
       CLOSE last_int_date_csr;

       Okl_Execute_Formula_Pub.g_additional_parameters(1).name := 'p_last_int_calc_date';
       Okl_Execute_Formula_Pub.g_additional_parameters(1).value := TO_CHAR(l_last_int_calc_date, 'MM/DD/YYYY');

	   l_capital_bal := OKL_SEEDED_FUNCTIONS_PVT.CONTRACT_PRINCIPAL_BALANCE
	                              (p_khr_id => p_cntrct_id,
						           p_kle_id => NULL);
    END IF;

  END IF;

  /* return the calculated net book value */
  RETURN(l_capital_bal);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
      /* return null because of error */
      RETURN(NULL);

     WHEN OTHERS THEN
       IF currency_info_csr%ISOPEN THEN
         CLOSE currency_info_csr;
       END IF;
      /* return null because of error */
      RETURN(NULL);

  END calculate_capital_balance;

  PROCEDURE GET_ACCOUNT_GEN_DETAILS(
    p_contract_id  IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_acc_gen_primary_key_tbl OUT NOCOPY Okl_Account_Dist_Pub.acc_gen_primary_key) IS

    -- Get Contract Salesperson
    -- 30-Apr-2004. Bug 3596651. Cursor provided by Sarvanan.
    CURSOR l_salesperson_csr (cp_chr_id IN NUMBER) IS
    SELECT con.object1_id1
    FROM OKC_K_HEADERS_B  CHR,
         OKC_CONTACT_SOURCES cso,
         OKC_K_PARTY_ROLES_B kpr,
         OKC_CONTACTS  con
    WHERE CHR.id   = cp_chr_id
    AND cso.cro_code  = 'SALESPERSON'
    AND cso.rle_code  = 'LESSOR'
    AND cso.buy_or_sell  = CHR.buy_or_sell
    AND kpr.chr_id  = CHR.id
    AND kpr.dnz_chr_id  = CHR.id
    AND kpr.rle_code  = cso.rle_code
    AND con.cpl_id  = kpr.id
    AND con.dnz_chr_id  = CHR.id
    AND con.cro_code  = cso.cro_code
    AND con.jtot_object1_code = cso.jtot_object_code;

    CURSOR l_fin_sys_parms_csr IS
    SELECT mo_global.get_current_org_id()
    FROM dual;

	-- Get Receivables Transaction Type
	CURSOR	l_cust_trx_type_csr IS
    SELECT	ctt.cust_trx_type_id
    FROM	ra_cust_trx_types	ctt
    WHERE	ctt.name		= 'Invoice-OKL';

    -- cursor to get bill-to-site of customer at contract level
    CURSOR chr_bill_to_site_csr (p_chr_id NUMBER) IS
    SELECT bill_to_site_use_id
    FROM OKC_K_HEADERS_B
    WHERE id = p_chr_id;

    l_sales_person_id              OKC_CONTACTS_V.OBJECT1_ID1%TYPE;
    l_counter                      NUMBER := 1;
    l_org_id                       NUMBER;
    l_receivables_trx_type         VARCHAR2(2000);
    l_bill_to_site                 VARCHAR2(2000);

  BEGIN

	x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Bug 3596651
    -- **************************************************
    -- Populate the account generator table with Contract Salesperson
    -- **************************************************

    OPEN  l_salesperson_csr (p_contract_id);
    FETCH l_salesperson_csr INTO l_sales_person_id;
    CLOSE l_salesperson_csr;

    IF l_sales_person_id IS NOT NULL THEN
      x_acc_gen_primary_key_tbl(l_counter).source_table := 'JTF_RS_SALESREPS_MO_V';
      x_acc_gen_primary_key_tbl(l_counter).primary_key_column := l_sales_person_id;
      l_counter := l_counter + 1;
    END IF;

    -- Bug 3596651
    -- **************************************************
    -- Populate the account generator table with Operating Unit Identifier
    -- **************************************************

    OPEN l_fin_sys_parms_csr;
    FETCH l_fin_sys_parms_csr INTO l_org_id;
    CLOSE l_fin_sys_parms_csr;

    IF l_org_id IS NOT NULL THEN
      x_acc_gen_primary_key_tbl(l_counter).source_table:= 'FINANCIALS_SYSTEM_PARAMETERS';
      x_acc_gen_primary_key_tbl(l_counter).primary_key_column := to_char(l_org_id);
      l_counter := l_counter + 1;
    END IF;

	-- ********************************
	-- Get Receivables Transaction Type
	-- ********************************

	OPEN	l_cust_trx_type_csr;
	FETCH	l_cust_trx_type_csr INTO l_receivables_trx_type;
	CLOSE	l_cust_trx_type_csr;

	IF l_receivables_trx_type IS NOT NULL THEN
		x_acc_gen_primary_key_tbl(l_counter).source_table:= 'RA_CUST_TRX_TYPES';
		x_acc_gen_primary_key_tbl(l_counter).primary_key_column := l_receivables_trx_type;
        l_counter := l_counter + 1;
	END IF;

    OPEN	chr_bill_to_site_csr(p_contract_id);
    FETCH	chr_bill_to_site_csr INTO l_bill_to_site;
    CLOSE	chr_bill_to_site_csr;

    IF l_bill_to_site IS NOT NULL THEN
       x_acc_gen_primary_key_tbl(l_counter).source_table:= 'AR_SITE_USES_V';
       x_acc_gen_primary_key_tbl(l_counter).primary_key_column := l_bill_to_site;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF l_salesperson_csr%ISOPEN THEN
        CLOSE l_salesperson_csr;
      END IF;

      IF l_fin_sys_parms_csr%ISOPEN THEN
        CLOSE l_fin_sys_parms_csr;
      END IF;

      IF l_cust_trx_type_csr%ISOPEN THEN
        CLOSE l_cust_trx_type_csr;
      END IF;

      IF chr_bill_to_site_csr%ISOPEN THEN
        CLOSE chr_bill_to_site_csr;
      END IF;


      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

  END GET_ACCOUNT_GEN_DETAILS;

  PROCEDURE CREATE_GEN_LOSS_TRX(
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_contract_id IN OKL_K_HEADERS_FULL_V.ID%TYPE,
    p_contract_number IN OKL_K_HEADERS_FULL_V.CONTRACT_NUMBER%TYPE,
    p_fact_synd_code IN VARCHAR2,
    p_inv_acct_code IN VARCHAR2,
    p_tcnv_rec IN OKL_TRX_CONTRACTS_PUB.tcnv_rec_type,
    p_tclv_tbl IN OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    x_tcnv_rec OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_rec_type,
    x_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type) IS

    --local variables
    l_api_name                  VARCHAR2(20) := 'CREATE_GEN_LOSS_TRX';
    l_api_version               CONSTANT NUMBER := 1.0;
    l_tmpl_identify_rec         Okl_Account_Dist_Pub.tmpl_identify_rec_type;
    l_dist_info_rec             Okl_Account_Dist_Pub.dist_info_rec_type;
    l_ctxt_val_tbl              Okl_Account_Dist_Pub.ctxt_val_tbl_type;
    l_template_tbl              Okl_Account_Dist_Pub.avlv_tbl_type;
    l_amount_tbl                Okl_Account_Dist_Pub.amount_tbl_type;
    l_source_table           CONSTANT OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := 'OKL_TXL_CNTRCT_LNS';
    l_acc_gen_primary_key_tbl   Okl_Account_Dist_Pub.acc_gen_primary_key;
    --START: Added by nikshah 19-Feb-2007 for SLA Uptake, Bug #5707866
    l_tcn_id NUMBER;
    l_tmpl_identify_tbl          Okl_Account_Dist_Pvt.tmpl_identify_tbl_type;
    l_dist_info_tbl              Okl_Account_Dist_Pvt.dist_info_tbl_type;
    l_ctxt_tbl                   Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
    l_acc_gen_tbl                Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
    l_template_out_tbl           Okl_Account_Dist_Pvt.avlv_out_tbl_type;
    l_amount_out_tbl             Okl_Account_Dist_Pvt.amount_out_tbl_type;
    --END: Added by nikshah 19-Feb-2007 for SLA Uptake, Bug #5707866


  BEGIN

    -- Set save point
    x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Call Transaction Public API to insert transaction header and line records
    Okl_Trx_Contracts_Pub.create_trx_contracts
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,p_tcnv_rec => p_tcnv_rec
                           ,p_tclv_tbl => p_tclv_tbl
                           ,x_tcnv_rec => x_tcnv_rec
                           ,x_tclv_tbl => x_tclv_tbl );
    -- store the highest degree of error
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      -- need to leave
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_contract_number);
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_contract_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    --get acc gen sources and value. Bug 3596651
    GET_ACCOUNT_GEN_DETAILS(
        p_contract_id => p_contract_id,
        x_return_status => x_return_status,
        x_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl);
    --check for error
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_ACC_GEN_ERROR',
                          p_token1       => g_contract_number_token,
                          p_token1_value => p_contract_number);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    --START: Changes by nikshah 19-Feb-2007 for SLA Uptake, Bug #5707866
    l_tcn_id := x_tcnv_rec.id;

    -- Build Accounting Record for creating actual entries for the catchup transactions
    FOR i IN x_tclv_tbl.FIRST..x_tclv_tbl.LAST
    LOOP
      l_acc_gen_tbl(i).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
      l_acc_gen_tbl(i).source_id := x_tclv_tbl(i).id;

      l_tmpl_identify_tbl(i).product_id := x_tcnv_rec.pdt_id;
      l_tmpl_identify_tbl(i).stream_type_id := x_tclv_tbl(i).sty_id;
      l_tmpl_identify_tbl(i).transaction_type_id := x_tcnv_rec.try_id;
      l_tmpl_identify_tbl(i).advance_arrears := NULL;
      l_tmpl_identify_tbl(i).prior_year_yn := 'N';
      l_tmpl_identify_tbl(i).memo_yn := 'N';
      l_tmpl_identify_tbl(i).factoring_synd_flag := p_fact_synd_code;
      l_tmpl_identify_tbl(i).investor_code := p_inv_acct_code;

      l_dist_info_tbl(i).amount := x_tclv_tbl(i).amount;
      l_dist_info_tbl(i).accounting_date := x_tcnv_rec.date_transaction_occurred;
      l_dist_info_tbl(i).source_table := l_source_table;
      l_dist_info_tbl(i).currency_code := x_tcnv_rec.currency_code;
      l_dist_info_tbl(i).currency_conversion_type := x_tcnv_rec.currency_conversion_type;
      l_dist_info_tbl(i).currency_conversion_rate := x_tcnv_rec.currency_conversion_rate;
      l_dist_info_tbl(i).currency_conversion_date := x_tcnv_rec.currency_conversion_date;
      l_dist_info_tbl(i).source_id := x_tclv_tbl(i).id;
      l_dist_info_tbl(i).post_to_gl := 'Y';
      l_dist_info_tbl(i).gl_reversal_flag := 'N';

    END LOOP;

      -- Call Okl_Account_Dist_Pub API to create accounting entries for this transaction
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

      -- store the highest degree of error
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_CRE_DIST_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          -- record that there was an error
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_CRE_DIST_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      --END: Changes by nikshah 19-Feb-2007 for SLA Uptake, Bug #5707866

      OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,P_TCNV_REC => x_tcnv_rec
                           ,P_TCLV_TBL => x_tclv_tbl
                           ,p_ctxt_val_tbl => l_ctxt_tbl
                           ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END CREATE_GEN_LOSS_TRX;

  -- Function to call the General Loss Provisions Procedure
  FUNCTION SUBMIT_GENERAL_LOSS(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_glpv_rec IN glpv_rec_type
 ) RETURN NUMBER IS

    x_request_id                NUMBER;
    l_api_version               CONSTANT NUMBER := 1;
    l_api_name                  VARCHAR2(2000) := 'SUBMIT_GENERAL_LOSS';
    l_product_id                VARCHAR2(2000);
	l_sty_id                    VARCHAR2(2000);
	l_bucket_id                 VARCHAR2(2000);
	l_entry_date                VARCHAR2(2000);
	l_tax_deductible_local      VARCHAR2(2000);
	l_tax_deductible_corporate  VARCHAR2(2000);
	l_description               VARCHAR2(2000);
	l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);
    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_Status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    -- validate input parameters
    IF (p_glpv_rec.product_id = OKL_API.G_MISS_NUM OR
        p_glpv_rec.product_id is NULL) THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_GLP_PDT_ERROR');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSE
      l_product_id := to_char(p_glpv_rec.product_id);
    END IF;

-- Bug 4110239. sty_id is not supported from 11.5.10+ version
--
--     IF (p_glpv_rec.sty_id = OKL_API.G_MISS_NUM OR
--         p_glpv_rec.sty_id is NULL) THEN
--         Okl_Api.set_message(p_app_name     => g_app_name,
--                             p_msg_name     => 'OKL_GLP_PVN_ERROR');
--         RAISE OKL_API.G_EXCEPTION_ERROR;
--     ELSE
--       l_sty_id := to_char(p_glpv_rec.sty_id);
--     END IF;

    IF (p_glpv_rec.bucket_id = OKL_API.G_MISS_NUM OR
        p_glpv_rec.bucket_id is NULL) THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_GLP_BKT_ERROR');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSE
      l_bucket_id := to_char(p_glpv_rec.bucket_id);
    END IF;

    IF (p_glpv_rec.entry_date = OKL_API.G_MISS_DATE OR
        p_glpv_rec.entry_date IS NULL) THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_GLP_DATE_ERROR');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSE
      l_entry_date := FND_DATE.DATE_TO_CANONICAL(p_glpv_rec.entry_date);
    END IF;

    IF (p_glpv_rec.tax_deductible_local = OKL_API.G_MISS_CHAR OR
        p_glpv_rec.tax_deductible_local is NULL) THEN
      l_tax_deductible_local := 'N';
    ELSE
      l_tax_deductible_local := p_glpv_rec.tax_deductible_local;
    END IF;

    IF (p_glpv_rec.tax_deductible_corporate = OKL_API.G_MISS_CHAR OR
        p_glpv_rec.tax_deductible_corporate is NULL) THEN
      l_tax_deductible_corporate := 'N';
    ELSE
      l_tax_deductible_corporate := p_glpv_rec.tax_deductible_corporate;
    END IF;

    l_description := p_glpv_rec.description;

    -- Bug 4110239. sty_id is not supported from 11.5.10+ version
    -- Submit Concurrent Program Request

    FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request

    x_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'OKL',
                                               program => 'OKLGLPCALC',
                                               argument1 => l_product_id,
                                               --argument2 => l_sty_id,
                                               argument3 => l_bucket_id,
                                               argument4 => l_entry_date,
                                               argument5 => l_tax_deductible_local,
                                               argument6 => l_tax_deductible_corporate,
                                               argument7 => l_description);

    IF x_request_id = 0 THEN
    -- Handle submission error
    -- Raise Error if the request has not been submitted successfully.
      Okl_Api.SET_MESSAGE(G_APP_NAME, 'OKL_ERROR_SUB_CONC_PROG', 'CONC_PROG', 'General Loss Provision');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSE
     --set return status
      x_return_status := l_return_status;
      RETURN x_request_id;
    END IF;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
      RETURN x_request_id;

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
	  				  	 		,g_pkg_name
                                ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                ,x_msg_count
                                ,x_msg_data
                                ,'_PVT');
      RETURN x_request_id;
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
      RETURN x_request_id;
  END SUBMIT_GENERAL_LOSS;

  -- Bug 4110239. p_sty_id is not supported from 11.5.10+ version
  -- Removing p_sty_id parameter as API is not published.
  PROCEDURE GENERAL_LOSS_PROVISION ( errbuf OUT NOCOPY VARCHAR2
                                    ,retcode OUT NOCOPY NUMBER
                                    ,p_product_id IN  VARCHAR2
                                    --,p_sty_id IN  VARCHAR2
                                    ,p_bucket_id IN  VARCHAR2
                                    ,p_entry_date IN  VARCHAR2
                                    ,p_tax_deductible_local IN  VARCHAR2
                                    ,p_tax_deductible_corporate IN VARCHAR2
                                    ,p_description IN VARCHAR2)
  IS

	  --   constants
	  l_api_name               CONSTANT VARCHAR2(40) := 'GENERAL_LOSS_PROVISION';
	  l_api_version            CONSTANT NUMBER       := 1.0;
	  l_try_name               CONSTANT OKL_TRX_TYPES_V.NAME%TYPE           := 'General Loss Provision';
	  l_tcn_type               CONSTANT OKL_TRX_CONTRACTS.TCN_TYPE%TYPE   := 'PGL';
	  l_tcl_type               CONSTANT OKL_TXL_CNTRCT_LNS.TCL_TYPE%TYPE  := 'PGL';
	  ----Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
	  l_tsu_code               CONSTANT OKL_TRX_CONTRACTS.TSU_CODE%TYPE   := 'PROCESSED';
	  l_oper_lease             CONSTANT OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE := 'LEASEOP';
	  l_df_lease               CONSTANT OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE := 'LEASEDF';
	  l_sales_lease            CONSTANT OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE := 'LEASEST';
	  l_loan_lease             CONSTANT OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE := 'LOAN';
	  l_sysdate                DATE := SYSDATE;
	  l_init_msg_list          VARCHAR2(2000) := OKL_API.G_FALSE;
	  l_sob_name               VARCHAR2(2000);
	  l_org_id                 NUMBER;
	  l_org_name               VARCHAR2(2000);
	  l_product_id             OKL_TRX_CONTRACTS.PDT_ID%TYPE := to_number(p_product_id);
	  l_product_name           OKL_PRODUCTS_V.NAME%TYPE;
	  l_bucket_id              OKX_AGING_BUCKETS_V.AGING_BUCKET_ID%TYPE := to_number(p_bucket_id);
	  l_entry_date             DATE := FND_DATE.CANONICAL_TO_DATE(p_entry_date);
	  l_cntrct_id              OKL_K_HEADERS_FULL_V.ID%TYPE;
	  l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
	  l_try_id                 OKL_TRX_TYPES_V.ID%TYPE;
	  l_deal_type              OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE;
	  l_least_bucket_rate      OKL_BUCKETS_V.LOSS_RATE%TYPE;
	  l_func_currency_code     OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
	  l_khr_currency_code      OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
	  l_currency_conv_type     OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_TYPE%TYPE;
	  l_currency_conv_rate     OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_RATE%TYPE;
	  l_currency_conv_date     OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_DATE%TYPE;
	  l_set_of_books_id        OKL_SYS_ACCT_OPTS.SET_OF_BOOKS_ID%TYPE;
	  l_error_cnt              NUMBER :=1;
	  l_period_start_date      DATE;
	  l_period_end_date        DATE;
	  l_period_name            VARCHAR2(2000);
	  l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	  l_precision              VARCHAR2(2000);
	  l_period_status          VARCHAR2(1);
	  l_product_subclass       VARCHAR2(2000);
	  l_counter                NUMBER := 1;
      l_fact_sync_code         VARCHAR2(2000);
      l_inv_acct_code          VARCHAR2(2000);
	  -- last interest calculation date .. racheruv. Bug 6342556
	  l_last_int_calc_date     DATE;
	  l_rev_rec_method_code    VARCHAR2(30);

	  --   record and table structure variables
	  TYPE contract_error_tbl_type IS TABLE OF okl_k_headers_full_v.CONTRACT_NUMBER%TYPE INDEX BY BINARY_INTEGER;
	  --   Bug# 3020763
	  TYPE pdt_contracts_rec_type IS RECORD (
	         contract_id               OKL_K_HEADERS_FULL_V.ID%TYPE
	        ,contract_number           OKL_K_HEADERS_FULL_V.CONTRACT_NUMBER%TYPE
	        ,deal_type                 OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE
	        ,currency_code             OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE
	        ,currency_conversion_type  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_TYPE%TYPE
	        ,currency_conversion_rate  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_RATE%TYPE
	        ,currency_conversion_date  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_DATE%TYPE);

	  TYPE pool_contents_rec_type is RECORD(
	         lease_contract_id         OKL_K_HEADERS_FULL_V.ID%TYPE
	        ,sty_id                    OKL_STRM_TYPE_V.ID%TYPE
	        ,sty_subclass              OKL_STRM_TYPE_V.STREAM_TYPE_SUBCLASS%TYPE
	        ,streams_to_date           OKL_POOL_CONTENTS_V.streams_to_date%TYPE);

	  TYPE pdt_contracts_tbl_type IS TABLE OF pdt_contracts_rec_type INDEX BY BINARY_INTEGER;
	  TYPE pool_contents_tbl_type IS TABLE OF pool_contents_rec_type INDEX BY BINARY_INTEGER;

	  TYPE date_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
	  l_int_calc_date_tbl      date_tbl_type;

	  l_contract_error_tbl     contract_error_tbl_type;
	  l_outer_error_msg_tbl    Okl_Accounting_Util.ERROR_MESSAGE_TYPE;
	  l_bktv_tbl               bucket_tbl_type;
	  l_pdt_contracts_rec      pdt_contracts_rec_type;
	  l_pdt_contracts_tbl      pdt_contracts_tbl_type;
	  pool_contents_tbl        pool_contents_tbl_type;
	  --Added by dpsingh for LE Uptake
	  l_legal_entity_id          NUMBER;

	--    cursor for getting contracts belonging to a lease product
	--    29-MAY-02 sgiyer  added where clause to select only active contracts
	--    13-DEC-02 sgiyer  added where clause to select lease contracts only
	--                      changed where clause for performance
	--                      and added multi-currency columns in select criteria
	--    bug 3448020. removing under revision status
	   CURSOR okl_pdt_cntrcts_csr (p_pdt_id OKL_TRX_CONTRACTS.PDT_ID%TYPE) IS
	   SELECT chr.id
	         ,chr.contract_number
	         ,khr.deal_type
	         ,chr.currency_code
	         ,khr.currency_conversion_type
	         ,khr.currency_conversion_rate
	         ,khr.currency_conversion_date
			 -- get the last interest calc date .. racheruv. Bug 6342556
			 ,TRUNC(nvl(khr.date_last_interim_interest_cal, chr.start_date)) last_int_calc_date
	   FROM OKC_K_HEADERS_B chr, OKL_K_HEADERS khr
	   WHERE khr.pdt_id = p_pdt_id
	   AND chr.id = khr.id
	   AND sts_code IN ('BOOKED','EVERGREEN')
	   AND chr.scs_code = 'LEASE';


	  -- cursor for getting a contract belonging to a Investor product
	   CURSOR investor_cntrcts_csr (p_pdt_id OKL_TRX_CONTRACTS.PDT_ID%TYPE) IS
	   SELECT chr.id
	         ,chr.contract_number
	         ,khr.deal_type
	         ,chr.currency_code
	         ,khr.currency_conversion_type
	         ,khr.currency_conversion_rate
	         ,khr.currency_conversion_date
	   FROM OKC_K_HEADERS_B chr, OKL_K_HEADERS khr
	   WHERE khr.pdt_id = p_pdt_id
	   AND chr.id = khr.id
	   AND sts_code = 'ACTIVE'
	   AND chr.scs_code = 'INVESTOR';


	  -- cursor to retrieve the aging bucket lines
	  CURSOR bucket_lines_csr (l_bucket_id OKX_AGING_BUCKETS_V.AGING_BUCKET_ID%TYPE) IS
	  SELECT okx.aging_bucket_line_id, bkt.id bkt_id, okx.bucket_name, okx.days_start, okx.days_to, bkt.loss_rate
	  FROM OKX_AGING_BUCKETS_V okx, OKL_BUCKETS_V bkt
	  WHERE okx.aging_bucket_id = l_bucket_id
	  AND okx.aging_bucket_line_id = bkt.ibc_id
	  AND bkt.end_date IS NULL
	  ORDER by okx.bucket_sequence_num;

	  -- cursor to get transaction type id
	  CURSOR trx_types_csr IS
	  SELECT id
	  FROM OKL_TRX_TYPES_TL
	  WHERE NAME = l_try_name
	  AND LANGUAGE = 'US';

	  -- cursor to get stream type name
-- 	  CURSOR sty_type_csr IS
-- 	  SELECT stytl.NAME
-- 	  FROM OKL_STRM_TYPE_TL stytl
-- 	  WHERE stytl.id = l_sty_id
-- 	  AND stytl.LANGUAGE = USERENV('LANG');

	  -- cursor to get the least loss rate for the bucket
	  CURSOR least_rate_csr (p_aging_bucket_line_id OKX_AGING_BUCKETS_V.AGING_BUCKET_LINE_ID%TYPE) IS
	  SELECT loss_rate
	  FROM OKL_BUCKETS_V
	  WHERE IBC_ID = p_aging_bucket_line_id
	  AND end_date IS NULL;

	  -- cursor to get product name
	  --Used base tables in query for performance by dkagrawa
          CURSOR pdt_csr IS
          SELECT pdt.name name, pqy.name product_subclass
          FROM okl_products pdt,
               okl_pdt_pqy_vals pqv,
               okl_pdt_qualitys pqy,
               okl_pqy_values qve
          WHERE pdt.id = pqv.pdt_id
          AND pqv.qve_id = qve.id
          AND qve.pqy_id = pqy.id
          AND pqy.name IN ('LEASE','INVESTOR')
          AND pdt.id = l_product_id;

	  -- cursor to get precision
	  CURSOR precision_csr(p_curr_code FND_CURRENCIES_VL.currency_code%TYPE) IS
	  SELECT PRECISION
	  FROM fnd_currencies_vl
	  WHERE currency_code = p_curr_code
	  AND enabled_flag = 'Y'
	  AND NVL(start_date_active, l_sysdate) <= l_sysdate
	  AND NVL(end_date_active, l_sysdate) >= l_sysdate;

	  -- Cursor to select currency conversion information
	--   CURSOR currency_conv_csr(p_conversion_type VARCHAR2, p_from_currency VARCHAR2, p_to_currency VARCHAR2, p_conversion_date DATE) IS
	--   SELECT conversion_rate
	--   FROM GL_DAILY_RATES
	--   WHERE conversion_type = p_conversion_type
	--   AND conversion_date = p_conversion_date
	--   AND from_currency = p_from_currency
	--   AND to_currency = p_to_currency
	--   AND status_code = 'C';

	  -- cursor to check whether the contract has a specific loss
	  CURSOR sp_loss_trx_csr (p_khr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
	  SELECT  'Y'
	  FROM OKL_TRX_CONTRACTS
	  WHERE khr_id = p_khr_id
	  AND tcn_type = 'PSP'
	  AND tsu_code = l_tsu_code
          AND representation_type = 'PRIMARY'; -- SGIYER MGAAP Changes Bug 7263041

	  -- cursor to check whether the contract has a general loss
	  CURSOR gen_loss_trx_csr (p_khr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
	  SELECT  'Y'
	  FROM OKL_TRX_CONTRACTS
	  WHERE khr_id = p_khr_id
	  AND tcn_type = 'PGL'
	  AND tsu_code = l_tsu_code
          AND representation_type = 'PRIMARY'; -- SGIYER MGAAP Changes Bug 7263041

	  -- cursor for retrieving the unpaid invoices for a contract
	  --Bug 2969989. Not all outstanding invoices need to be considered.Consider
	  --only those less than or equal to provision date.
	  -- Bug 4058948. Changing view from okl_bpd_leasing_payment_trx_v to okl_bpd_contract_invoices_v.
	  -- Also adding new where condition to exclude invoices subject to cash receipt.
	  CURSOR cntrct_invcs_csr (p_khr_id OKL_K_HEADERS_FULL_V.ID%TYPE, p_entry_date DATE) IS
	  SELECT amount_due_remaining, due_date
	  FROM okl_bpd_contract_invoices_v
	  WHERE contract_id = p_khr_id
	  AND status = 'OP'
	  AND amount_due_remaining > 0
	  AND revenue_rec_basis <> 'CASH_RECEIPT'
	  AND due_date <= p_entry_date;

	  -- Cursor to select lease contracts within a pool for an investor agreement.
	  CURSOR pool_contents_csr (p_agr_id NUMBER) IS
	  SELECT chr.id chr_id,
	         sty.id sty_id,
	         sty.stream_type_subclass sty_subclass,
	         poc.streams_to_date streams_to_date
	  FROM OKL_POOLS pol,
		   OKL_POOL_CONTENTS poc,
	       OKL_STRM_TYPE_B sty,
	       OKC_K_HEADERS_B chr,
	       OKL_K_HEADERS khr
	  WHERE pol.khr_id = p_agr_id
	  AND pol.id = poc.pol_id
	  AND poc.status_code = 'ACTIVE'
	  AND poc.sty_id = sty.id
	  --Bug 6740000 ssdeshpa Impact for Loan Contracts added into the pool start
	  AND sty.stream_type_subclass IN ('RENT', 'RESIDUAL', 'LOAN_PAYMENT')
	  --Bug 6740000 ssdeshpa End
	  AND poc.khr_id = chr.id
	  AND chr.id = khr.id;


	  -- GSCC validation error. Removing hardcoded schema name APPS
	  -- cursor to select open items for a contract
	  -- Bug 4058948. Changing view from okl_bpd_leasing_payment_trx_v to okl_bpd_contract_invoices_v.
	  -- Also adding new where condition to exclude invoices subject to cash receipt.
	  CURSOR open_items_csr (p_khr_id NUMBER, p_sty_id NUMBER) IS
	  SELECT amount_due_remaining, due_date
	  FROM okl_bpd_contract_invoices_v
	  WHERE contract_id = p_khr_id
	  AND status = 'OP'
	  AND amount_due_remaining > 0
	  AND revenue_rec_basis <> 'CASH_RECEIPT'
	  AND due_date <= l_entry_date
	  AND stream_type_id = p_sty_id;

	  -- cursor to select residual value amount
	  CURSOR residual_value_csr (p_khr_id NUMBER, p_sty_id NUMBER) IS
	  SELECT ste.amount
	  FROM OKL_STRM_TYPE_B sty,
	       OKL_STREAMS stm,
	       OKL_STRM_ELEMENTS ste
	  WHERE stm.khr_id = p_khr_id
	  AND stm.sty_id = sty.id
	  AND sty.id = p_sty_id
	  AND stm.id = ste.stm_id
	  AND stm.active_yn = 'Y'
	  AND stm.say_code = 'CURR';

	  -- cursor to get org name
	  CURSOR org_name_csr(p_org_id NUMBER) IS
	  SELECT name
	  FROM hr_operating_units
	  WHERE organization_id = p_org_id;

      -- cursor to get the revenue recognition method.. racheruv. Bug 6342556
	CURSOR get_rev_rec_method_csr(p_chr_id NUMBER) IS
    SELECT pdt.quality_val revenue_recognition_method
      FROM OKL_PROD_QLTY_VAL_UV pdt,
           OKL_K_HEADERS_FULL_V khr
     WHERE khr.id = p_chr_id
       AND khr.pdt_id = pdt.pdt_id
       AND pdt.quality_name = 'REVENUE_RECOGNITION_METHOD';

  BEGIN

    -- get the set of books id
    l_set_of_books_id := OKL_ACCOUNTING_UTIL.GET_SET_OF_BOOKS_ID;
    IF (l_set_of_books_id IS NULL) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_SOB_ID_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Find set of books name for report
    l_sob_name := Okl_Accounting_Util.GET_SET_OF_BOOKS_NAME(l_set_of_books_id);

    -- Find org name for report
    l_org_id := mo_global.get_current_org_id();
    IF l_org_id IS NULL THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'l_org_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN org_name_csr(l_org_id);
    FETCH org_name_csr INTO l_org_name;
    CLOSE org_name_csr;
    IF l_org_name IS NULL THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'ORG_ID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    -- Get Period info for PB
    Okl_Accounting_Util.GET_PERIOD_INFO(l_entry_date,l_period_name,l_period_start_date,l_period_end_date);
    IF l_period_name IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_PERIOD_END_DATE');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --Bug# 2781593
	-- check for open period
    l_period_status := Okl_Accounting_Util.GET_OKL_PERIOD_STATUS(l_period_name);
    IF l_period_status IS NULL THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_PERIOD_STATUS_ERROR',
							p_token1       => 'PERIOD_NAME',
							p_token1_value => l_period_name);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF l_period_status NOT IN('O','F') THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_OPEN_PERIOD_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Find product details
    OPEN pdt_csr;
	FETCH pdt_csr INTO l_product_name, l_product_subclass;
    CLOSE pdt_csr;
    IF l_product_name IS NULL THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'l_product_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_product_subclass IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_GLP_PDT_SUBCLASS');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Find currency code for the set of books id
    l_func_currency_code := Okl_Accounting_Util.GET_FUNC_CURR_CODE;
    IF (l_func_currency_code IS NULL) THEN
      -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_CURR_CODE_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- retrieve the transaction type id
    OPEN trx_types_csr;
    FETCH trx_types_csr INTO l_try_id;
    CLOSE trx_types_csr;
    IF l_try_id IS NULL THEN
      -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_TRX_TYPE_ERROR',
	                      p_token1       => 'TRANSACTION_TYPE',
						  p_token1_value => l_try_name);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- retrieve the bucket lines
	FOR i IN bucket_lines_csr(l_bucket_id)
	LOOP
      l_bktv_tbl(l_counter).aging_bucket_line_id := i.aging_bucket_line_id;
	  l_bktv_tbl(l_counter).bkt_id := i.bkt_id;
	  l_bktv_tbl(l_counter).bucket_name := i.bucket_name;
	  l_bktv_tbl(l_counter).days_start := i.days_start;
	  l_bktv_tbl(l_counter).days_to := i.days_to;
	  l_bktv_tbl(l_counter).loss_rate := i.loss_rate;
      l_counter := l_counter + 1;
    END LOOP;

    IF l_bktv_tbl.COUNT = 0 THEN
      -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_GLP_BKT_NULL_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Bug 3557647. Invalid cursor error. Forgot to close cursor
    -- find the loss rate for the lowest bucket
    OPEN least_rate_csr(l_bktv_tbl(1).aging_bucket_line_id);
    FETCH least_rate_csr INTO l_least_bucket_rate;
    CLOSE least_rate_csr;
    IF l_least_bucket_rate IS NULL THEN
      -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_GLP_LOSS_RATE_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    l_counter := 1;
    IF l_product_subclass = 'LEASE' THEN
    -- loop for contracts for a product
    --  Bug# 3020763 Looping and fetching into tbl to avoid rollback segment error.
      FOR pdt_cntrcts_rec IN okl_pdt_cntrcts_csr(l_product_id) LOOP
        l_pdt_contracts_tbl(l_counter).contract_id := pdt_cntrcts_rec.id;
        l_pdt_contracts_tbl(l_counter).deal_type := pdt_cntrcts_rec.deal_type;
        l_pdt_contracts_tbl(l_counter).contract_number := pdt_cntrcts_rec.contract_number;
        l_pdt_contracts_tbl(l_counter).currency_code := pdt_cntrcts_rec.currency_code;
        l_pdt_contracts_tbl(l_counter).currency_conversion_type := pdt_cntrcts_rec.currency_conversion_type;
        l_pdt_contracts_tbl(l_counter).currency_conversion_date := pdt_cntrcts_rec.currency_conversion_date;
        l_pdt_contracts_tbl(l_counter).currency_conversion_rate := pdt_cntrcts_rec.currency_conversion_rate;
		l_int_calc_date_tbl(l_counter) := pdt_cntrcts_rec.last_int_calc_date;
        l_counter := l_counter + 1;
      END LOOP;

    ELSIF l_product_subclass = 'INVESTOR' THEN

      -- Bug 3557647. Fixed invalid cursor error.
	  FOR pdt_cntrcts_rec IN investor_cntrcts_csr(l_product_id)
      LOOP

        l_pdt_contracts_tbl(l_counter).contract_id := pdt_cntrcts_rec.id;
        l_pdt_contracts_tbl(l_counter).deal_type := pdt_cntrcts_rec.deal_type;
        l_pdt_contracts_tbl(l_counter).contract_number := pdt_cntrcts_rec.contract_number;
        l_pdt_contracts_tbl(l_counter).currency_code := pdt_cntrcts_rec.currency_code;
        l_pdt_contracts_tbl(l_counter).currency_conversion_type := pdt_cntrcts_rec.currency_conversion_type;
        l_pdt_contracts_tbl(l_counter).currency_conversion_date := pdt_cntrcts_rec.currency_conversion_date;
        l_pdt_contracts_tbl(l_counter).currency_conversion_rate := pdt_cntrcts_rec.currency_conversion_rate;
        l_counter := l_counter + 1;
      END LOOP;

    ELSE
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_GLP_INVALID_SUBCLASS');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;


    -- Create report header
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                                      '||FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_HEADER'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                                      '||FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_HEADER_LINE'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_SOB_TITLE')
	                  ||' '||RPAD(l_sob_name, 65)
					  ||FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_OU_TITLE')
					  ||' '||l_org_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_PROG_DATE_TITLE')
	                  ||' '||RPAD(l_sysdate, 61)||FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_PROV_DATE_TITLE')
					  ||' '||l_entry_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_CURR_TITLE')
	                  ||' '||RPAD(l_func_currency_code,65));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');

    -- Create Report Content
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_PROD_TITLE')||' '||l_product_name);
    --FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_STY_TITLE')||' '||l_sty_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');

    IF l_product_subclass = 'LEASE' THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_CTR_NUM_TITLE'),28)
	                  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_TRX_NUM_TITLE'),22)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_TAXLOCAL_TITLE'),23)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_TAXCORP_TITLE'),26)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURRENCY'),9)
					  ||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_TITLE'),17));
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AGR_NUM_TITLE'),28)
	                  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_TRX_NUM_TITLE'),22)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_TAXLOCAL_TITLE'),23)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_TAXCORP_TITLE'),26)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURRENCY'),9)
					  ||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_TITLE'),17));
	END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_CTR_LINE'),28)
	                  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_TRX_LINE'),22)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_TAXLOCAL_LINE'),23)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_TAXCORP_LINE'),26)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURR_UNDERLINE'),9)
					  ||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_LINE'),17));


	IF l_pdt_contracts_tbl.COUNT > 0 THEN
    -- Bug# 3020763 Processing within a pl/sql tbl instead of within the cursor itself.
	FOR x IN l_pdt_contracts_tbl.FIRST..l_pdt_contracts_tbl.LAST
	LOOP

      l_cntrct_id := l_pdt_contracts_tbl(x).contract_id;
      l_deal_type := l_pdt_contracts_tbl(x).deal_type;
      l_cntrct_number := l_pdt_contracts_tbl(x).contract_number;
      l_khr_currency_code := l_pdt_contracts_tbl(x).currency_code;
      l_currency_conv_type := l_pdt_contracts_tbl(x).currency_conversion_type;
      l_currency_conv_date := l_pdt_contracts_tbl(x).currency_conversion_date;
      l_currency_conv_rate := l_pdt_contracts_tbl(x).currency_conversion_rate;

      DECLARE
        -- Declare local variables which need to be re-initialized to null for each contract
        l_return_status            VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
        l_init_msg_list            VARCHAR2(2000) := OKL_API.G_FALSE;
        x_msg_count                NUMBER;
        x_msg_data                 VARCHAR2(2000);
        l_net_book_value           NUMBER;
        l_net_invest_value         NUMBER;
        l_principal_balance        NUMBER;
        l_nbv_loss_amt             NUMBER := 0;
        l_niv_loss_amt             NUMBER := 0;
        l_pb_loss_amt              NUMBER := 0;
        l_residual_loss_amt        NUMBER := 0;
        l_residual_amt             NUMBER := 0;
        l_total_residual_amt       NUMBER := 0;
        l_line_count    		   NUMBER := 1;
        l_due_date                 DATE;
        l_sp_loss_fnd              VARCHAR2(1) := 'N';
        l_gen_loss_fnd             VARCHAR2(1) := 'N';
        l_no_of_days               NUMBER;
        l_due_amt                  NUMBER;
        l_inv_loss_amt             NUMBER :=0;
        l_loss_rate                OKL_BUCKETS_V.LOSS_RATE%TYPE;
        l_trx_header_total         OKL_TRX_CONTRACTS.AMOUNT%TYPE := 0;
        l_converted_net_book_value NUMBER;
        l_sty_id                   OKL_TXL_CNTRCT_LNS.STY_ID%TYPE; --:= to_number(p_sty_id);
        l_sty_name                 OKL_STRM_TYPE_V.NAME%TYPE;


        -- creating variable required by okl_accounting_util.convert_to_contract_currency
		-- these variables not used anywhere.
        x_contract_currency	       OKL_K_HEADERS_FULL_V.currency_code%TYPE;
        x_currency_conversion_type OKL_K_HEADERS_FULL_V.currency_conversion_type%TYPE;
        x_currency_conversion_rate OKL_K_HEADERS_FULL_V.currency_conversion_rate%TYPE;
        x_currency_conversion_date OKL_K_HEADERS_FULL_V.currency_conversion_date%TYPE;

        --   record and table structure variables
        l_tcnv_rec               OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
        l_tclv_tbl               OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
        x_tcnv_rec               OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
        x_tclv_tbl               OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
        l_lprv_rec               OKL_REV_LOSS_PROV_PUB.lprv_rec_type;
        l_error_msg_tbl          Okl_Accounting_Util.ERROR_MESSAGE_TYPE;

        -- Begin a new PL/SQL block to trap errors related to a praticular contract and to move on to the next contract
      BEGIN

	    OKL_STREAMS_UTIL.get_primary_stream_type(
	      p_khr_id  		   	=> l_cntrct_id,
	      p_primary_sty_purpose => 'GENERAL_LOSS_PROVISION',
	      x_return_status		=> l_return_status,
	      x_primary_sty_id 		=> l_sty_id);

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
          -- store SQL error message on message stack for caller and entry in log file
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                              p_token1       => g_stream_name_token,
	                          p_token1_value => 'General Loss Provision');
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

-- Bug 4110239. No need for sty_name
-- 	    -- get the stream type name
-- 	    OPEN sty_type_csr;
-- 	    FETCH sty_type_csr INTO l_sty_name;
-- 	    CLOSE sty_type_csr;
-- 	    IF l_sty_name IS NULL THEN
-- 	      -- store SQL error message on message stack for caller
-- 	      okl_api.set_message(p_app_name       => G_APP_NAME,
-- 	                            p_msg_name     => G_NO_MATCHING_RECORD,
-- 	                            p_token1       => G_COL_NAME_TOKEN,
-- 	                            p_token1_value => 'l_sty_id');
-- 	      RAISE OKL_API.G_EXCEPTION_ERROR;
-- 	    END IF;

        -- Check contract currency against functional currency
        IF l_func_currency_code <> l_khr_currency_code THEN
          --validate data
          IF l_currency_conv_type IS NULL THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_CURR_TYPE_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_cntrct_number);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
          IF l_currency_conv_date IS NULL THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_CURR_DATE_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_cntrct_number);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
		  END IF;
          IF l_currency_conv_type = 'User' THEN
            IF l_currency_conv_rate IS NULL THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_CURR_USER_RATE_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_cntrct_number);
              RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
          ELSE
--             OPEN currency_conv_csr(l_currency_conv_type, l_khr_currency_code, l_func_currency_code, l_currency_conv_date);
--             FETCH currency_conv_csr INTO l_currency_conv_rate;
--             IF currency_conv_csr%NOTFOUND THEN
-- 			  CLOSE currency_conv_csr;
--               Okl_Api.set_message(p_app_name     => g_app_name,
--                                   p_msg_name     => 'OKL_AGN_CURR_RATE_ERROR',
--                                   p_token1       => 'CONVERSION_TYPE',
--                                   p_token1_value => l_currency_conv_type,
--                                   p_token2       => 'FROM_CURRENCY',
--                                   p_token2_value => l_khr_currency_code,
--                                   p_token3       => 'TO_CURRENCY',
--                                   p_token3_value => l_func_currency_code
-- 								  );
--               RAISE Okl_Api.G_EXCEPTION_ERROR;
--             END IF;
-- 			CLOSE currency_conv_csr;
            l_currency_conv_rate := OKL_ACCOUNTING_UTIL.get_curr_con_rate
                                    (p_from_curr_code => l_khr_currency_code,
                                     p_to_curr_code => l_func_currency_code,
                                     p_con_date => l_entry_date,--Bug 6970675
                                     p_con_type => l_currency_conv_type);
            IF l_currency_conv_rate IS NULL THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_CURR_RATE_ERROR',
                                  p_token1       => 'FROM_CURRENCY',
                                  p_token1_value => l_khr_currency_code,
                                  p_token2       => 'TO_CURRENCY',
                                  p_token2_value => l_func_currency_code,
                                  p_token3       => 'CONVERSION_TYPE',
                                  p_token3_value => l_currency_conv_type
								  );
              RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
            l_currency_conv_date := l_entry_date; -- Bug 6970675
          END IF;
        END IF;

        -- Find precision for the currency code
        OPEN precision_csr(l_khr_currency_code);
        FETCH precision_csr INTO l_precision;
        CLOSE precision_csr;

        IF l_precision IS NULL THEN
          -- store SQL error message on message stack for caller
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_GLP_PRECISION_ERROR',
	                          p_token1       => 'CURRENCY_CODE',
			    			  p_token1_value => l_khr_currency_code);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


		-- check if the contract id has a specific loss trx
        OPEN sp_loss_trx_csr(l_cntrct_id);
        FETCH sp_loss_trx_csr INTO l_sp_loss_fnd;
        CLOSE sp_loss_trx_csr;

        -- proceed if there were no transactions for specific loss provision
        IF l_sp_loss_fnd='N' THEN
          IF l_product_subclass = 'LEASE' THEN
            -- calculate the nbv loss if contract is an operating lease
            IF l_deal_type = l_oper_lease THEN
              l_net_book_value := calculate_cntrct_nbv (p_cntrct_id => l_cntrct_id);
              IF l_net_book_value IS NULL THEN
                Okl_Api.set_message(p_app_name     => g_app_name,
                                    p_msg_name     => 'OKL_NET_BOOK_VALUE_ERROR',
                                    p_token1       => g_contract_number_token,
                                    p_token1_value => l_cntrct_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              -- convert NBV to contract currency. Bug 2712001
              IF l_net_book_value <> 0 THEN
                IF l_func_currency_code <> l_khr_currency_code THEN
                  OKL_ACCOUNTING_UTIL.convert_to_contract_currency
                   (p_khr_id  		  	=> l_cntrct_id,
                    p_from_currency   	=> l_func_currency_code,
                    p_transaction_date 	=> l_entry_date,
                    p_amount 			    => l_net_book_value,
                    x_contract_currency	=> x_contract_currency,
                    x_currency_conversion_type => x_currency_conversion_type,
                    x_currency_conversion_rate => x_currency_conversion_rate,
                    x_currency_conversion_date => x_currency_conversion_date,
                    x_converted_amount 	=> l_converted_net_book_value);

                  IF l_converted_net_book_value IS NULL THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CONV_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_cntrct_number);
                    RAISE Okl_Api.G_EXCEPTION_ERROR;
                  END IF;
                l_nbv_loss_amt := l_converted_net_book_value * l_least_bucket_rate/100;
                ELSE
                  l_nbv_loss_amt := l_net_book_value * l_least_bucket_rate/100;
	    		END IF;
              END IF;

            -- calculate the niv loss if contract is a direct finance lease or sales lease
            ELSIF l_deal_type IN (l_df_lease,l_sales_lease) THEN
              l_net_invest_value := calculate_cntrct_niv (p_cntrct_id => l_cntrct_id
                                                       ,p_loss_date => l_entry_date);
              IF l_net_invest_value IS NULL THEN
                Okl_Api.set_message(p_app_name     => g_app_name,
                                    p_msg_name     => 'OKL_NET_INVEST_VALUE_ERROR',
                                    p_token1       => g_contract_number_token,
                                    p_token1_value => l_cntrct_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              IF l_net_invest_value <> 0 THEN
                l_niv_loss_amt := l_net_invest_value * l_least_bucket_rate/100;
              END IF;

            -- calculate the pb loss loss if contract is loan
            ELSIF l_deal_type = l_loan_lease THEN
			  -- get the rev rec method .. racheruv. Bug 6342556
              OPEN get_rev_rec_method_csr(l_cntrct_id);
			  FETCH get_rev_rec_method_csr INTO l_rev_rec_method_code;
			  CLOSE get_rev_rec_method_csr;

			  -- if rev rec method is 'Streams' then use the period start and end dates
			  -- else use the last interest calculation date to obtain contract principal balance.
			  IF l_rev_rec_method_code = 'STREAMS' THEN

                 l_principal_balance := get_contract_principal_balance
                                           (p_cntrct_id => l_cntrct_id
				                           ,p_period_start_date => l_period_start_date
                                           ,p_period_end_date   => l_period_end_date);

              ELSIF l_rev_rec_method_code IN ('ESTIMATED_AND_BILLED', 'ACTUAL') THEN
	             l_last_int_calc_date := l_int_calc_date_tbl(x);
                 Okl_Execute_Formula_Pub.g_additional_parameters(1).name := 'p_last_int_calc_date';
                 Okl_Execute_Formula_Pub.g_additional_parameters(1).value := TO_CHAR(l_last_int_calc_date, 'MM/DD/YYYY');
	              l_principal_balance := OKL_SEEDED_FUNCTIONS_PVT.CONTRACT_PRINCIPAL_BALANCE
	                                                              (p_khr_id => l_cntrct_id,
						                                           p_kle_id => NULL);
			  END IF;

              IF l_principal_balance IS NULL THEN
                Okl_Api.set_message(p_app_name     => g_app_name,
                                    p_msg_name     => 'OKL_PRIN_BAL_VALUE_ERROR',
                                    p_token1       => g_contract_number_token,
                                    p_token1_value => l_cntrct_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              IF l_principal_balance <> 0 THEN
                l_pb_loss_amt := l_principal_balance * l_least_bucket_rate/100;
	  		  END IF;

            END IF;
          END IF; -- IF l_product_subclass = 'LEASE'

          -- check if the contract id has a general loss trx
          OPEN gen_loss_trx_csr(l_cntrct_id);
          FETCH gen_loss_trx_csr INTO l_gen_loss_fnd;
          CLOSE gen_loss_trx_csr;

          -- if there was a transaction for general loss
          IF l_gen_loss_fnd = 'Y' THEN
            l_lprv_rec.cntrct_num := l_cntrct_number;
            l_lprv_rec.reversal_type := 'PGL';
            l_lprv_rec.reversal_date := l_entry_date;

            -- reverse the general loss trx
            OKL_REV_LOSS_PROV_PUB.REVERSE_LOSS_PROVISIONS (
                                  p_api_version    => l_api_version
                                 ,p_init_msg_list  => l_init_msg_list
                                 ,x_return_status  => l_return_status
                                 ,x_msg_count      => x_msg_count
                                 ,x_msg_data       => x_msg_data
                                 ,p_lprv_rec        => l_lprv_rec);
            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_GLP_REV_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_cntrct_number);
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_GLP_REV_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_cntrct_number);
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF; -- IF l_gen_loss_fnd = 'Y'

          -- initialize
          FOR x IN l_bktv_tbl.FIRST..l_bktv_tbl.LAST
	      LOOP
            l_bktv_tbl(x).loss_amount := 0;
		  END LOOP;

          IF l_product_subclass = 'LEASE' THEN
            -- loop for unpaid invoices for a contract
            -- Bug 2969989. Pass provision date to cursor.
            FOR cntrct_invcs_rec IN cntrct_invcs_csr(l_cntrct_id, l_entry_date)
            LOOP
              -- get the invoice details from the cursor
              l_due_amt  := cntrct_invcs_rec.amount_due_remaining;
              l_due_date := cntrct_invcs_rec.due_date;
              -- calculate unpaid days
              -- Bug 2969989. Unpaid days is provision date less due date.
              l_no_of_days := l_entry_date - l_due_date;
              --calculate total loss amount for each bucket
    	      FOR l_count IN l_bktv_tbl.FIRST..l_bktv_tbl.LAST
              LOOP
                IF l_no_of_days BETWEEN l_bktv_tbl(l_count).days_start AND l_bktv_tbl(l_count).days_to THEN
                  --calculate loss amount
				  l_inv_loss_amt := l_due_amt * l_bktv_tbl(l_count).loss_rate/100;
                  -- total up loss amount
				  l_bktv_tbl(l_count).loss_amount := l_bktv_tbl(l_count).loss_amount + l_inv_loss_amt;
                  l_trx_header_total := l_trx_header_total + l_inv_loss_amt;
			    END IF;
			  END LOOP;
            END LOOP; -- end of loop for unpaid invoices for a contract

            -- add the nbv loss if the contract is operating lease
            IF l_deal_type = l_oper_lease THEN
              l_trx_header_total := l_trx_header_total + l_nbv_loss_amt;
              -- add the niv loss if the contract is a direct finance lease
            ELSIF l_deal_type = l_df_lease OR l_deal_type = l_sales_lease THEN
              l_trx_header_total := l_trx_header_total + l_niv_loss_amt;
              -- add the pb loss if the contract is a loan
            ELSIF l_deal_type = l_loan_lease THEN
              l_trx_header_total := l_trx_header_total + l_pb_loss_amt;
            END IF;

          ELSIF l_product_subclass = 'INVESTOR' THEN
            -- commenting below code for bug 3377730
			-- uncomment and use in 11ix
            --OPEN pool_contents_csr (l_cntrct_id);
            --FETCH pool_contents_csr BULK COLLECT INTO pool_contents_tbl;
            --CLOSE pool_contents_csr;

            l_counter := 1;
            FOR i IN pool_contents_csr(l_cntrct_id)
			LOOP
              pool_contents_tbl(l_counter).lease_contract_id := i.chr_id;
              pool_contents_tbl(l_counter).sty_id := i.sty_id;
              pool_contents_tbl(l_counter).sty_subclass := i.sty_subclass;
              pool_contents_tbl(l_counter).streams_to_date := i.streams_to_date;
              l_counter := l_counter + 1;
			END LOOP;

            IF pool_contents_tbl.COUNT > 0 THEN
              FOR i IN pool_contents_tbl.FIRST..pool_contents_tbl.LAST
	      LOOP
                IF pool_contents_tbl(i).sty_subclass IN ('RENT','LOAN_PAYMENT') THEN
                  -- for each lease contractid fetch open items
	              FOR j IN open_items_csr(pool_contents_tbl(i).lease_contract_id, pool_contents_tbl(i).sty_id)
                  LOOP
                    -- get the invoice details from the cursor
                    l_due_amt  := j.amount_due_remaining;
                    l_due_date := j.due_date;
                    -- calculate unpaid days
                    l_no_of_days := l_entry_date - l_due_date;

                    --calculate total loss amount for each bucket
    	            FOR l_count IN l_bktv_tbl.FIRST..l_bktv_tbl.LAST
                    LOOP

                      IF l_no_of_days BETWEEN l_bktv_tbl(l_count).days_start AND l_bktv_tbl(l_count).days_to THEN
                        --calculate loss amount
	    			    l_inv_loss_amt := l_due_amt * l_bktv_tbl(l_count).loss_rate/100;
                        -- total up loss amount
                        l_bktv_tbl(l_count).loss_amount := l_bktv_tbl(l_count).loss_amount + l_inv_loss_amt;
                        l_trx_header_total := l_trx_header_total + l_inv_loss_amt;
                      END IF;
                    END LOOP; -- FOR l_count IN l_bktv_tbl.FIRST..l_bktv_tbl.LAST

                  END LOOP; -- FOR j IN open_items_csr(pool_contents_tbl(i).lease_contract_id, pool_contents_tbl(i).stream_type_id)

                ELSIF pool_contents_tbl(i).sty_subclass = 'RESIDUAL' THEN
                  IF (pool_contents_tbl(i).streams_to_date IS NULL OR pool_contents_tbl(i).streams_to_date >= l_entry_date) THEN

                    FOR x IN residual_value_csr (pool_contents_tbl(i).lease_contract_id, pool_contents_tbl(i).sty_id)
                    LOOP
                      l_residual_amt := x.amount;
                      l_total_residual_amt := l_total_residual_amt + l_residual_amt;
                    END LOOP;

                    l_residual_loss_amt := l_total_residual_amt * l_least_bucket_rate/100;
                    l_trx_header_total := l_trx_header_total + l_residual_loss_amt;

                  END IF;
                END IF; -- IF pool_contents_tbl(i).sty_subclass = 'RENT' THEN

	      END LOOP; -- FOR i IN pool_contents_tbl.FIRST..pool_contents_tbl.LAST

            END IF; -- IF pool_contents_tbl.COUNT > 0 THEN

          END IF; -- ELSIF l_product_subclass = 'INVESTOR' THEN

          -- populate the transaction structure
          -- 28-MAY-2002 added if condition to avoid pl/sql numeric or value error while
		  -- creating transaction
          IF (l_trx_header_total IS NOT NULL AND l_trx_header_total > 0) THEN
            l_tcnv_rec.tcn_type                  := l_tcn_type;
            l_tcnv_rec.khr_id                    := l_cntrct_id;
            l_tcnv_rec.tsu_code                  := l_tsu_code;
            l_tcnv_rec.pdt_id                    := l_product_id;
            l_tcnv_rec.try_id                    := l_try_id;
            l_tcnv_rec.tax_deductible_local      := p_tax_deductible_local;
            l_tcnv_rec.tax_deductible_corporate  := p_tax_deductible_corporate;
            l_tcnv_rec.amount                    := ROUND(l_trx_header_total,l_precision);
            l_tcnv_rec.currency_code             := l_khr_currency_code;
            l_tcnv_rec.currency_conversion_type  := l_currency_conv_type;
            l_tcnv_rec.currency_conversion_rate  := l_currency_conv_rate;
            l_tcnv_rec.currency_conversion_date  := l_currency_conv_date;
            l_tcnv_rec.set_of_books_id           := l_set_of_books_id;
            l_tcnv_rec.description               := p_description;
            l_tcnv_rec.date_transaction_occurred := l_entry_date;
	    -- Bug 5935176  dpsingh for AE signature Uptake  start
	    OPEN get_dff_fields(l_tcnv_rec.khr_id);
            FETCH get_dff_fields into l_tcnv_rec.ATTRIBUTE_CATEGORY,
                                                   l_tcnv_rec.ATTRIBUTE1,
                                                   l_tcnv_rec.ATTRIBUTE2,
                                                   l_tcnv_rec.ATTRIBUTE3,
                                                   l_tcnv_rec.ATTRIBUTE4,
                                                   l_tcnv_rec.ATTRIBUTE5,
                                                   l_tcnv_rec.ATTRIBUTE6,
                                                   l_tcnv_rec.ATTRIBUTE7,
                                                   l_tcnv_rec.ATTRIBUTE8,
                                                   l_tcnv_rec.ATTRIBUTE9,
                                                   l_tcnv_rec.ATTRIBUTE10,
                                                   l_tcnv_rec.ATTRIBUTE11,
                                                   l_tcnv_rec.ATTRIBUTE12,
                                                   l_tcnv_rec.ATTRIBUTE13,
                                                   l_tcnv_rec.ATTRIBUTE14,
                                                   l_tcnv_rec.ATTRIBUTE15;
              CLOSE get_dff_fields;
	   -- Bug 5935176  dpsingh for AE signature Uptake  end
	    --Added by dpsingh for LE Uptake
            l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_cntrct_id) ;
            IF  l_legal_entity_id IS NOT NULL THEN
                l_tcnv_rec.legal_entity_id :=  l_legal_entity_id;
            ELSE
                Okl_Api.set_message(p_app_name     => g_app_name,
                                                 p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			                         p_token1           =>  'CONTRACT_NUMBER',
			                         p_token1_value  =>  l_cntrct_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

            FOR x IN l_bktv_tbl.FIRST..l_bktv_tbl.LAST
            LOOP
              IF l_bktv_tbl(x).loss_amount > 0 THEN
                -- populate the transaction line structure
                l_tclv_tbl(l_line_count).line_number    := l_line_count;
                l_tclv_tbl(l_line_count).khr_id         := l_cntrct_id;
                l_tclv_tbl(l_line_count).description    := p_description;
                l_tclv_tbl(l_line_count).amount         := ROUND(l_bktv_tbl(x).loss_amount,l_precision);
                l_tclv_tbl(l_line_count).currency_code  := l_khr_currency_code;
                l_tclv_tbl(l_line_count).tcl_type       := l_tcl_type;
                l_tclv_tbl(l_line_count).bkt_id         := l_bktv_tbl(x).bkt_id;
                l_tclv_tbl(l_line_count).sty_id         := l_sty_id;
                l_line_count := l_line_count+1;
              END IF;
            END LOOP;

            IF l_product_subclass = 'LEASE' THEN
              IF l_deal_type = l_oper_lease THEN
                IF l_nbv_loss_amt IS NOT NULL AND l_nbv_loss_amt > 0 THEN
                  l_tclv_tbl(l_line_count).amount       := ROUND(l_nbv_loss_amt,l_precision);
                  l_tclv_tbl(l_line_count).line_number    := l_line_count;
                  l_tclv_tbl(l_line_count).khr_id         := l_cntrct_id;
                  l_tclv_tbl(l_line_count).description    := p_description;
                  l_tclv_tbl(l_line_count).currency_code  := l_khr_currency_code;
                  l_tclv_tbl(l_line_count).bkt_id         := l_bktv_tbl(1).bkt_id;
                  l_tclv_tbl(l_line_count).sty_id         := l_sty_id;
                  l_tclv_tbl(l_line_count).tcl_type       := l_tcl_type;
	            END IF;
              ELSIF (l_deal_type = l_df_lease OR l_deal_type = l_sales_lease) THEN
                IF l_niv_loss_amt IS NOT NULL AND l_niv_loss_amt > 0 THEN
                  l_tclv_tbl(l_line_count).amount      := ROUND(l_niv_loss_amt,l_precision);
                  l_tclv_tbl(l_line_count).line_number    := l_line_count;
                  l_tclv_tbl(l_line_count).khr_id         := l_cntrct_id;
                  l_tclv_tbl(l_line_count).description    := p_description;
                  l_tclv_tbl(l_line_count).currency_code  := l_khr_currency_code;
                  l_tclv_tbl(l_line_count).bkt_id         := l_bktv_tbl(1).bkt_id;
                  l_tclv_tbl(l_line_count).sty_id         := l_sty_id;
                  l_tclv_tbl(l_line_count).tcl_type       := l_tcl_type;
                END IF;
              ELSIF l_deal_type = l_loan_lease THEN
                IF l_pb_loss_amt IS NOT NULL AND l_pb_loss_amt > 0 THEN
                  l_tclv_tbl(l_line_count).amount      := ROUND(l_pb_loss_amt,l_precision);
                  l_tclv_tbl(l_line_count).line_number    := l_line_count;
                  l_tclv_tbl(l_line_count).khr_id         := l_cntrct_id;
                  l_tclv_tbl(l_line_count).description    := p_description;
                  l_tclv_tbl(l_line_count).currency_code  := l_khr_currency_code;
                  l_tclv_tbl(l_line_count).bkt_id         := l_bktv_tbl(1).bkt_id;
                  l_tclv_tbl(l_line_count).sty_id         := l_sty_id;
                  l_tclv_tbl(l_line_count).tcl_type       := l_tcl_type;
                END IF;
              END IF;

              --Bug 4622198.
              OKL_SECURITIZATION_PVT.check_khr_ia_associated(
                p_api_version                  => l_api_version
               ,p_init_msg_list                => l_init_msg_list
               ,x_return_status                => l_return_status
               ,x_msg_count                    => x_msg_count
               ,x_msg_data                     => x_msg_data
               ,p_khr_id                       => l_cntrct_id
               ,p_scs_code                     => l_product_subclass
               ,p_trx_date                     => l_entry_date
               ,x_fact_synd_code               => l_fact_sync_code
               ,x_inv_acct_code                => l_inv_acct_code
                );

              -- store the highest degree of error
              IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                -- need to leave
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;

            ELSIF l_product_subclass = 'INVESTOR' THEN
              IF l_residual_loss_amt IS NOT NULL AND l_residual_loss_amt > 0 THEN
                  l_tclv_tbl(l_line_count).amount      := ROUND(l_residual_loss_amt,l_precision);
                  l_tclv_tbl(l_line_count).line_number    := l_line_count;
                  l_tclv_tbl(l_line_count).khr_id         := l_cntrct_id;
                  l_tclv_tbl(l_line_count).description    := p_description;
                  l_tclv_tbl(l_line_count).currency_code  := l_khr_currency_code;
                  l_tclv_tbl(l_line_count).bkt_id         := l_bktv_tbl(1).bkt_id;
                  l_tclv_tbl(l_line_count).sty_id         := l_sty_id;
                  l_tclv_tbl(l_line_count).tcl_type       := l_tcl_type;
              END IF;
              --Bug 4622198.
              OKL_SECURITIZATION_PVT.check_khr_ia_associated(
                p_api_version                  => l_api_version
               ,p_init_msg_list                => l_init_msg_list
               ,x_return_status                => l_return_status
               ,x_msg_count                    => x_msg_count
               ,x_msg_data                     => x_msg_data
               ,p_khr_id                       => l_cntrct_id
               ,p_scs_code                     => l_product_subclass
               ,p_trx_date                     => l_entry_date
               ,x_fact_synd_code               => l_fact_sync_code
               ,x_inv_acct_code                => l_inv_acct_code
                );

              -- store the highest degree of error
              IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                -- need to leave
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;

            END IF; -- IF l_product_subclass = 'LEASE'


            -- create transaction and transaction lines
            CREATE_GEN_LOSS_TRX(
                         p_api_version    => l_api_version
                        ,p_init_msg_list  => l_init_msg_list
                        ,x_return_status  => l_return_status
                        ,x_msg_count      => x_msg_count
                        ,x_msg_data       => x_msg_data
                        ,p_contract_id    => l_cntrct_id
                        ,p_contract_number=> l_cntrct_number
                        ,p_fact_synd_code => l_fact_sync_code
                        ,p_inv_acct_code  => l_inv_acct_code
                        ,p_tcnv_rec       => l_tcnv_rec
                        ,p_tclv_tbl       => l_tclv_tbl
                        ,x_tcnv_rec       => x_tcnv_rec
                        ,x_tclv_tbl       => x_tclv_tbl);

            IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                            p_msg_name     => 'OKL_GLP_TRX_CRE_ERROR',
                                            p_token1       => g_contract_number_token,
                                            p_token1_value => l_cntrct_number);
              RAISE OKL_API.G_EXCEPTION_ERROR;
            ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                            p_msg_name     => 'OKL_GLP_TRX_CRE_ERROR',
                                            p_token1       => g_contract_number_token,
                                            p_token1_value => l_cntrct_number);
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;

            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_cntrct_number,28)||
	                                     RPAD(x_tcnv_rec.trx_number,22)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',x_tcnv_rec.tax_deductible_local,0,0),23)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',x_tcnv_rec.tax_deductible_corporate,0,0),26)||
	                                     RPAD(x_tcnv_rec.currency_code,9)||
                                         -- Bug# 2774187. Commenting precision as accounting util takes care of formatting.
                                         --LPAD(x_tcnv_rec.amount,17));
                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(x_tcnv_rec.amount,x_tcnv_rec.currency_code),17));
          END IF;
      END IF; -- end if for contract did not have a specific loss trx
    EXCEPTION

      WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        l_return_status := Okl_Api.G_RET_STS_ERROR;
        -- Select the contract for error reporting
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_cntrct_number||', '||'Error Status: '||l_return_status);
        l_contract_error_tbl(l_error_cnt) := l_cntrct_number;
		l_error_cnt := l_error_cnt + 1;        Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_tbl);
        IF (l_error_msg_tbl.COUNT > 0) THEN
          FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
          LOOP
            IF l_error_msg_tbl(i) IS NOT NULL THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,l_error_msg_tbl(i));
            END IF;
		  END LOOP;
          FND_FILE.PUT_LINE(FND_FILE.LOG,'');
        END IF;

      WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
        -- Select the contract for error reporting
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_cntrct_number||', '||'Error Status: '||l_return_status);
        l_contract_error_tbl(l_error_cnt) := l_cntrct_number;
		l_error_cnt := l_error_cnt + 1;
        Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_tbl);
        IF (l_error_msg_tbl.COUNT > 0) THEN
          FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
          LOOP
            IF l_error_msg_tbl(i) IS NOT NULL THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,l_error_msg_tbl(i));
            END IF;
          END LOOP;
          FND_FILE.PUT_LINE(FND_FILE.LOG,'');
        END IF;

      WHEN OTHERS THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
--         IF currency_conv_csr%ISOPEN THEN
-- 		  CLOSE currency_conv_csr;
-- 		END IF;

        IF precision_csr%ISOPEN THEN
		  CLOSE precision_csr;
		END IF;

        IF sp_loss_trx_csr%ISOPEN THEN
		  CLOSE sp_loss_trx_csr;
		END IF;

        IF gen_loss_trx_csr%ISOPEN THEN
		  CLOSE gen_loss_trx_csr;
		END IF;

        -- Select the contract for error reporting
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_cntrct_number||', '||'Error Status: '||l_return_status);
        l_contract_error_tbl(l_error_cnt) := l_cntrct_number;
		l_error_cnt := l_error_cnt + 1;
        Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_tbl);
        IF (l_error_msg_tbl.COUNT > 0) THEN
          FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
          LOOP
            IF l_error_msg_tbl(i) IS NOT NULL THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,l_error_msg_tbl(i));
            END IF;
          END LOOP;
          FND_FILE.PUT_LINE(FND_FILE.LOG,'');
        END IF;
    END;

  END LOOP; -- for contracts within a product
  END IF; -- 	IF l_pdt_contracts_tbl.COUNT > 0 THEN

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
  IF l_product_subclass = 'LEASE' THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CNTRCT_ERROR_TITLE'));
  ELSE
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AGR_ERROR_TITLE'));
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CNT_ERR_UNDERLINE'));
  IF l_contract_error_tbl.COUNT > 0 THEN
    FOR x IN l_contract_error_tbl.FIRST..l_contract_error_tbl.LAST
    LOOP
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_contract_error_tbl(x));
    END LOOP;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ADD_INFO'));
  END IF;
  retcode := 0;

  EXCEPTION

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      l_return_status := Okl_Api.G_RET_STS_ERROR;

      -- print the overall status in the log file
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Overall Program Status = '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0) THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
          IF l_outer_error_msg_tbl(i) IS NOT NULL THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_outer_error_msg_tbl(i));
          END IF;
        END LOOP;
      END IF;
      retcode := 2;

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      -- print the overall status in the log file
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Overall Program Status = '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0) THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
          IF l_outer_error_msg_tbl(i) IS NOT NULL THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_outer_error_msg_tbl(i));
          END IF;
        END LOOP;
      END IF;
      retcode := 2;

    WHEN OTHERS THEN
      IF org_name_csr%ISOPEN THEN
	    CLOSE org_name_csr;
      END IF;

      IF pdt_csr%ISOPEN THEN
	    CLOSE pdt_csr;
      END IF;

      IF trx_types_csr%ISOPEN THEN
	    CLOSE trx_types_csr;
      END IF;

--       IF sty_type_csr%ISOPEN THEN
-- 	    CLOSE sty_type_csr;
--       END IF;

      IF least_rate_csr%ISOPEN THEN
	    CLOSE least_rate_csr;
      END IF;

      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      errbuf := SQLERRM;
      retcode := 2;
      -- print the overall status in the log file
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Overall Program Status = '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0) THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
          IF l_outer_error_msg_tbl(i) IS NOT NULL THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_outer_error_msg_tbl(i));
          END IF;
        END LOOP;
      END IF;

  END GENERAL_LOSS_PROVISION;

   -- this procedure is used create a transaction for specific loss provision
  PROCEDURE SPECIFIC_LOSS_PROVISION(
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,p_slpv_rec             IN slpv_rec_type)

  IS
  l_return_status          VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  l_try_id                 OKL_TRX_TYPES_V.ID%TYPE;
  l_dummy_var              VARCHAR2(1) := '?';
  l_dummy2_var             VARCHAR2(1) := '?';
  l_line_count             NUMBER := 0;

  -- constants
  l_api_name               CONSTANT VARCHAR2(40) := 'SPECIFIC_LOSS_PROVISION';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_tcn_type               CONSTANT OKL_TRX_CONTRACTS.TCN_TYPE%TYPE      := 'PSP';
  l_try_name               CONSTANT OKL_TRX_TYPES_TL.NAME%TYPE            := 'Specific Loss Provision';
  l_tcl_type               CONSTANT OKL_TXL_CNTRCT_LNS.TCL_TYPE%TYPE     := 'PSP';
  l_source_table           CONSTANT OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := 'OKL_TXL_CNTRCT_LNS';
  --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
  l_tsu_code               CONSTANT OKL_TRX_CONTRACTS.TSU_CODE%TYPE      := 'PROCESSED';

  --variables
  l_func_currency_code     OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
  l_khr_currency_code      OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
  l_currency_conv_type     OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_TYPE%TYPE;
  l_currency_conv_rate     OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_RATE%TYPE;
  l_currency_conv_date     OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_DATE%TYPE;
  l_set_of_books_id        OKL_SYS_ACCT_OPTS.SET_OF_BOOKS_ID%TYPE;
  l_product_id             OKL_K_HEADERS_FULL_V.PDT_ID%TYPE;
  l_sty_id                 OKL_STRM_TYPE_V.ID%TYPE;
  l_sysdate                DATE := SYSDATE;
  l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_period_start_date      DATE;
  l_period_end_date        DATE;
  l_period_name            VARCHAR2(2000);
  l_period_status          VARCHAR2(1);
  l_fact_sync_code         VARCHAR2(2000);
  l_inv_acct_code          VARCHAR2(2000);
  l_scs_code               VARCHAR2(2000);

  -- record and table structure variables
  l_tcnv_rec                   OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
  l_tclv_tbl                   OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
  x_tcnv_rec                   OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
  x_tclv_tbl                   OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
  l_lprv_rec                   OKL_REV_LOSS_PROV_PUB.lprv_rec_type;
  l_tmpl_identify_rec          Okl_Account_Dist_Pub.tmpl_identify_rec_type;
  l_dist_info_rec              Okl_Account_Dist_Pub.dist_info_rec_type;
  l_ctxt_val_tbl               Okl_Account_Dist_Pub.ctxt_val_tbl_type;
  l_template_tbl               Okl_Account_Dist_Pub.avlv_tbl_type;
  l_amount_tbl                 Okl_Account_Dist_Pub.amount_tbl_type;
  l_acc_gen_primary_key_tbl    Okl_Account_Dist_Pub.acc_gen_primary_key;

 --Added by dpsingh for LE Uptake
  l_legal_entity_id   NUMBER;

  --Added by kthiruva for SLA Uptake on 14-Feb-2007
  --Bug 5707866 - Start of Changes
  l_tmpl_identify_tbl          Okl_Account_Dist_Pvt.tmpl_identify_tbl_type;
  l_dist_info_tbl              Okl_Account_Dist_Pvt.dist_info_tbl_type;
  l_ctxt_tbl                   Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
  l_template_out_tbl           Okl_Account_Dist_Pvt.avlv_out_tbl_type;
  l_amount_out_tbl             Okl_Account_Dist_Pvt.amount_out_tbl_type;
  l_acc_gen_tbl                Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
  l_tcn_id                     NUMBER;
  --Bug 5707866 - End of Changes

  -- cursor to get transaction type id
  CURSOR trx_types_csr IS
  SELECT id
  FROM OKL_TRX_TYPES_TL
  WHERE NAME = l_try_name
  AND LANGUAGE = 'US';

  -- cursor to get scs_code
  CURSOR scs_code_csr IS
  SELECT scs_code
  FROM OKL_K_HEADERS_FULL_V
  WHERE id = p_slpv_rec.khr_id;


  -- Cursor to verify if the stream type selected is the same as used earlier
--   CURSOR sty_id_csr(p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
--   SELECT DISTINCT sty.id id
--   FROM OKL_STRM_TYPE_B sty, OKL_TRX_CONTRACTS_V trx, OKL_TXL_CNTRCT_LNS_V txl
--   WHERE trx.khr_id = p_ctr_id
--   AND trx.tcn_type = 'PSP'
--   AND trx.tsu_code = l_tsu_code
--   AND trx.id = txl.tcn_id
--   AND txl.sty_id = sty.id;

  -- cursor to check whether the contract has a general loss
  CURSOR gen_loss_trx_csr (p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
  SELECT  'Y'
  FROM OKL_TRX_CONTRACTS
  WHERE khr_id = p_ctr_id
  AND tcn_type = 'PGL'
  AND tsu_code = l_tsu_code
  AND representation_type='PRIMARY';

  -- cursor to check whether the contract has a specific loss
  CURSOR spec_loss_trx_csr (p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
  SELECT  'Y'
  FROM OKL_TRX_CONTRACTS
  WHERE khr_id = p_ctr_id
  AND tcn_type = 'PSP'
  AND tsu_code = l_tsu_code
  AND representation_type='PRIMARY';

  -- cursor to get the contract number
  CURSOR contract_num_csr (p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
  SELECT  contract_number
  FROM OKL_K_HEADERS_FULL_V
  WHERE id = p_ctr_id;

  -- cursor to get the product id for the given contract id
  CURSOR pdt_id_csr(p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
  SELECT pdt_id
  FROM OKL_K_HEADERS_FULL_V
  WHERE id = p_ctr_id;

  -- Cursor to select currency information for the contract
  CURSOR currency_info_csr(p_khr_id NUMBER) IS
  SELECT chr.currency_code currency_code,
         khr.currency_conversion_type currency_conversion_type,
		 khr.currency_conversion_date currency_conversion_date,
		 khr.currency_conversion_rate currency_conversion_rate
  FROM OKC_K_HEADERS_B chr, OKL_K_HEADERS khr
  WHERE chr.id = p_khr_id
  AND chr.id = khr.id;


  -- Cursor to select currency conversion information
--   CURSOR currency_conv_csr(p_conversion_type VARCHAR2, p_from_currency VARCHAR2, p_to_currency VARCHAR2, p_conversion_date DATE) IS
--   SELECT conversion_rate
--   FROM GL_DAILY_RATES
--   WHERE conversion_type = p_conversion_type
--   AND conversion_date = p_conversion_date
--   AND from_currency = p_from_currency
--   AND to_currency = p_to_currency
--   AND status_code = 'C';

  BEGIN

       l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- validate input parameters
       IF (p_slpv_rec.sty_id IS NULL OR p_slpv_rec.sty_id = OKL_API.G_MISS_NUM) THEN
           Okl_Api.set_message(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_GLP_PVN_ERROR');
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF (p_slpv_rec.khr_id IS NULL OR p_slpv_rec.khr_id = OKL_API.G_MISS_NUM) THEN
           Okl_Api.set_message(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_REV_LPV_CNTRCT_ERROR');
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF (p_slpv_rec.amount IS NULL OR p_slpv_rec.amount = OKL_API.G_MISS_NUM) THEN
           Okl_Api.set_message(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_SLP_AMOUNT_ERROR');
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF (p_slpv_rec.provision_date IS NULL OR p_slpv_rec.provision_date = OKL_API.G_MISS_DATE) THEN
           Okl_Api.set_message(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_SLP_PROV_DATE_ERROR');
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- get the contract number
       OPEN contract_num_csr(p_slpv_rec.khr_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
       IF l_cntrct_number IS NULL THEN
         Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- 01-Apr-04. Discussed with Vikas.
       -- Removing validation. Product Management requires that SLP be created for
       -- contracts using different provision types.
       --IF (p_slpv_rec.reverse_flag = 'N' OR p_slpv_rec.reverse_flag IS NULL) THEN
       --  -- validate sty_id to make sure provision used is same as this trx is an addition
       --  FOR x IN sty_id_csr(p_slpv_rec.khr_id)
	   --  LOOP
       --    IF p_slpv_rec.sty_id <> x.id THEN
       --      Okl_Api.set_message(p_app_name     => g_app_name,
       --                          p_msg_name     => 'OKL_SLP_PVN_TYPE_ERROR');
       --      RAISE OKL_API.G_EXCEPTION_ERROR;
       --    END IF;
	   --  END LOOP;
       --END IF;

       -- get period info
       Okl_Accounting_Util.GET_PERIOD_INFO(p_slpv_rec.provision_date,l_period_name,l_period_start_date,l_period_end_date);
       IF l_period_name IS NULL THEN
         Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_AGN_PERIOD_END_DATE');
         RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;

       -- check for open period
       l_period_status := Okl_Accounting_Util.GET_OKL_PERIOD_STATUS(l_period_name);
       IF l_period_status IS NULL THEN
         Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_AGN_PERIOD_STATUS_ERROR',
			                 p_token1       => 'PERIOD_NAME',
							 p_token1_value => l_period_name);
         RAISE Okl_Api.G_EXCEPTION_ERROR;
	   END IF;

       IF l_period_status NOT IN('O','F') THEN
         Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_AGN_OPEN_PERIOD_ERROR');
         RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;

       -- get the set of books id
       l_set_of_books_id := OKL_ACCOUNTING_UTIL.GET_SET_OF_BOOKS_ID;
       IF l_set_of_books_id IS NULL THEN
         Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_SOB_ID_ERROR');
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- get scs_code
       FOR x IN scs_code_csr
	   LOOP
         l_scs_code := x.scs_code;
       END LOOP;
       IF l_scs_code IS NULL THEN
         OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SCS_CODE');
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- retrieve the functional currency code
       l_func_currency_code := Okl_Accounting_Util.GET_FUNC_CURR_CODE;
       IF l_func_currency_code IS NULL THEN
         Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_AGN_CURR_CODE_ERROR');
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- retrieve the currency code for the contract
	   -- bug 2712001. Chneged from functional currency to contract currency.
       OPEN currency_info_csr(p_slpv_rec.khr_id);
       FETCH currency_info_csr INTO l_khr_currency_code,l_currency_conv_type,l_currency_conv_date,l_currency_conv_rate;
       CLOSE currency_info_csr;
       IF l_khr_currency_code IS NULL THEN
         Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_SLP_CURR_CODE_ERROR',
                             p_token1       => g_contract_number_token,
                             p_token1_value => l_cntrct_number);
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

        -- bug 2712001. Enabled Multi Currency changes
        -- Check contract currency against functional currency
        IF l_func_currency_code <> l_khr_currency_code THEN
          --validate data
          IF l_currency_conv_type IS NULL THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_CURR_TYPE_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_cntrct_number);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
          IF l_currency_conv_date IS NULL THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_CURR_DATE_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_cntrct_number);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
		  END IF;
          IF l_currency_conv_type = 'User' THEN
            IF l_currency_conv_rate IS NULL THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_CURR_USER_RATE_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_cntrct_number);
              RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
          ELSE
--             OPEN currency_conv_csr(l_currency_conv_type, l_khr_currency_code, l_func_currency_code, l_currency_conv_date);
--             FETCH currency_conv_csr INTO l_currency_conv_rate;
--             IF currency_conv_csr%NOTFOUND THEN
-- 			  CLOSE currency_conv_csr;
--               Okl_Api.set_message(p_app_name     => g_app_name,
--                                   p_msg_name     => 'OKL_AGN_CURR_RATE_ERROR',
--                                   p_token1       => 'FROM_CURRENCY',
--                                   p_token1_value => l_khr_currency_code,
--                                   p_token2       => 'TO_CURRENCY',
--                                   p_token2_value => l_func_currency_code,
--                                   p_token3       => 'CONVERSION_TYPE',
--                                   p_token3_value => l_currency_conv_type
-- 								  );
--               RAISE Okl_Api.G_EXCEPTION_ERROR;
--             END IF;
-- 			CLOSE currency_conv_csr;
            l_currency_conv_rate := OKL_ACCOUNTING_UTIL.get_curr_con_rate
			                (p_from_curr_code => l_khr_currency_code,
                                         p_to_curr_code => l_func_currency_code,
                                         p_con_date => p_slpv_rec.provision_date, -- Bug 6970654
                                         p_con_type => l_currency_conv_type);

            IF l_currency_conv_rate IS NULL THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_CURR_RATE_ERROR',
                                  p_token1       => 'FROM_CURRENCY',
                                  p_token1_value => l_khr_currency_code,
                                  p_token2       => 'TO_CURRENCY',
                                  p_token2_value => l_func_currency_code,
                                  p_token3       => 'CONVERSION_TYPE',
                                  p_token3_value => l_currency_conv_type
								  );
              RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
            l_currency_conv_date := p_slpv_rec.provision_date;--Bug 6970654
          END IF;
        END IF;

       -- retrieve the transaction type id
       OPEN trx_types_csr;
       FETCH trx_types_csr INTO l_try_id;
       CLOSE trx_types_csr;
       IF l_try_id IS NULL THEN
          -- store SQL error message on message stack for caller
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TRX_TYPE_ERROR',
							p_token1       => 'TRANSACTION_TYPE',
							p_token1_value => l_try_name);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- get the product id for the contract
	   OPEN pdt_id_csr(p_slpv_rec.khr_id);
	   FETCH pdt_id_csr INTO l_product_id;
       CLOSE pdt_id_csr;
	   IF l_product_id IS NULL THEN
         Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_SLP_PDT_ID_ERROR',
                             p_token1       => g_contract_number_token,
                             p_token1_value => l_cntrct_number);
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- check if the contract id has a general loss trx
       OPEN gen_loss_trx_csr(p_slpv_rec.khr_id);
       FETCH gen_loss_trx_csr INTO l_dummy_var;
       CLOSE gen_loss_trx_csr;

       -- if there was a transaction for general loss
       IF l_dummy_var = 'Y' THEN
          l_lprv_rec.cntrct_num := l_cntrct_number;
		  l_lprv_rec.reversal_type := 'PGL';
          l_lprv_rec.reversal_date := p_slpv_rec.provision_date;

          -- reverse the general loss trx
          OKL_REV_LOSS_PROV_PUB.REVERSE_LOSS_PROVISIONS (
                                 p_api_version    => l_api_version
                                ,p_init_msg_list  => p_init_msg_list
                                ,x_return_status  => l_return_status
                                ,x_msg_count      => x_msg_count
                                ,x_msg_data       => x_msg_data
                                ,p_lprv_rec        => l_lprv_rec);

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_GLP_REV_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_cntrct_number);
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_GLP_REV_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_cntrct_number);
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END IF;

       -- reverse all previous specific loss transactions as this is a new trx with new provision type
       IF p_slpv_rec.reverse_flag = 'Y' THEN
         -- check is specific loss exists and make a call for reversal only if exists
	     OPEN spec_loss_trx_csr(p_slpv_rec.khr_id);
         FETCH spec_loss_trx_csr INTO l_dummy2_var;
         CLOSE spec_loss_trx_csr;

		 IF l_dummy2_var = 'Y' THEN
          -- initialize variables
          l_lprv_rec.cntrct_num := l_cntrct_number;
		  l_lprv_rec.reversal_type := 'PSP';
          l_lprv_rec.reversal_date := p_slpv_rec.provision_date;

          -- reverse the spec loss trx
          OKL_REV_LOSS_PROV_PUB.REVERSE_LOSS_PROVISIONS (
                           p_api_version    => p_api_version
                          ,p_init_msg_list  => p_init_msg_list
                          ,x_return_status  => l_return_status
                          ,x_msg_count      => x_msg_count
                          ,x_msg_data       => x_msg_data
                          ,p_lprv_rec       => l_lprv_rec);

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_SLP_REV_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_cntrct_number);
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_SLP_REV_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_cntrct_number);
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
         END IF; -- for l_dummy2_var
       END IF;

       --Added by dpsingh for LE Uptake
            l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_slpv_rec.khr_id) ;
            IF  l_legal_entity_id IS NOT NULL THEN
                l_tcnv_rec.legal_entity_id :=  l_legal_entity_id;
            ELSE
                Okl_Api.set_message(p_app_name     => g_app_name,
                                                 p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			                         p_token1           =>  'CONTRACT_NUMBER',
			                         p_token1_value  =>  l_cntrct_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

       -- populate the transaction structure
       l_tcnv_rec.tcn_type                  := l_tcn_type;
       l_tcnv_rec.tsu_code                  := l_tsu_code;
       l_tcnv_rec.khr_id                    := p_slpv_rec.khr_id;
       l_tcnv_rec.description               := p_slpv_rec.description;
       l_tcnv_rec.try_id                    := l_try_id;
       l_tcnv_rec.tax_deductible_local      := p_slpv_rec.tax_deductible_local;
       l_tcnv_rec.tax_deductible_corporate  := p_slpv_rec.tax_deductible_corporate;
       l_tcnv_rec.amount                    := p_slpv_rec.amount;
       l_tcnv_rec.currency_code             := l_khr_currency_code;
       l_tcnv_rec.currency_conversion_type  := l_currency_conv_type;
       l_tcnv_rec.currency_conversion_rate  := l_currency_conv_rate;
       l_tcnv_rec.currency_conversion_date  := l_currency_conv_date;
       l_tcnv_rec.set_of_books_id           := l_set_of_books_id;
       l_tcnv_rec.description               := p_slpv_rec.description;
       l_tcnv_rec.date_transaction_occurred := p_slpv_rec.provision_date;
       -- Bug 5935176  dpsingh for AE signature Uptake  start
       OPEN get_dff_fields(l_tcnv_rec.khr_id);
       FETCH get_dff_fields into l_tcnv_rec.ATTRIBUTE_CATEGORY,
                                                   l_tcnv_rec.ATTRIBUTE1,
                                                   l_tcnv_rec.ATTRIBUTE2,
                                                   l_tcnv_rec.ATTRIBUTE3,
                                                   l_tcnv_rec.ATTRIBUTE4,
                                                   l_tcnv_rec.ATTRIBUTE5,
                                                   l_tcnv_rec.ATTRIBUTE6,
                                                   l_tcnv_rec.ATTRIBUTE7,
                                                   l_tcnv_rec.ATTRIBUTE8,
                                                   l_tcnv_rec.ATTRIBUTE9,
                                                   l_tcnv_rec.ATTRIBUTE10,
                                                   l_tcnv_rec.ATTRIBUTE11,
                                                   l_tcnv_rec.ATTRIBUTE12,
                                                   l_tcnv_rec.ATTRIBUTE13,
                                                   l_tcnv_rec.ATTRIBUTE14,
                                                   l_tcnv_rec.ATTRIBUTE15;
         CLOSE get_dff_fields;
       -- Bug 5935176  dpsingh for AE signature Uptake  end
       -- populate the transaction line structure
       l_tclv_tbl(1).khr_id         := p_slpv_rec.khr_id;
       l_tclv_tbl(1).line_number    := 1;
       l_tclv_tbl(1).description    := p_slpv_rec.description;
       l_tclv_tbl(1).amount         := p_slpv_rec.amount;
       l_tclv_tbl(1).currency_code  := l_khr_currency_code;
       l_tclv_tbl(1).tcl_type       := l_tcl_type;
       l_tclv_tbl(1).sty_id         := p_slpv_rec.sty_id;

       -- create transaction and transaction lines
       OKL_TRX_CONTRACTS_PUB.create_trx_contracts(
                         p_api_version    => p_api_version
                        ,p_init_msg_list  => p_init_msg_list
                        ,x_return_status  => l_return_status
                        ,x_msg_count      => x_msg_count
                        ,x_msg_data       => x_msg_data
                        ,p_tcnv_rec       => l_tcnv_rec
                        ,p_tclv_tbl       => l_tclv_tbl
                        ,x_tcnv_rec       => x_tcnv_rec
                        ,x_tclv_tbl       => x_tclv_tbl);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_cntrct_number);
             RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_cntrct_number);
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       --get acc gen sources and value. Bug 3596651
       GET_ACCOUNT_GEN_DETAILS(
           p_contract_id => p_slpv_rec.khr_id,
           x_return_status => l_return_status,
           x_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl);
       --check for error
       IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
         Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_AGN_ACC_GEN_ERROR',
                             p_token1       => g_contract_number_token,
                             p_token1_value => l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;


       --Bug 4622198.
       OKL_SECURITIZATION_PVT.check_khr_ia_associated(
        p_api_version                  => p_api_version
       ,p_init_msg_list                => p_init_msg_list
       ,x_return_status                => l_return_status
       ,x_msg_count                    => x_msg_count
       ,x_msg_data                     => x_msg_data
       ,p_khr_id                       => p_slpv_rec.khr_id
       ,p_scs_code                     => l_scs_code
       ,p_trx_date                     => p_slpv_rec.provision_date
       ,x_fact_synd_code               => l_fact_sync_code
       ,x_inv_acct_code                => l_inv_acct_code
       );

      -- store the highest degree of error
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      --Added by kthiruva for SLA Uptake
      --Bug 5707866 - Start of Changes
      FOR i IN x_tclv_tbl.FIRST..x_tclv_tbl.LAST
      LOOP
        --Assigning the account generator table
		l_acc_gen_tbl(i).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
		l_acc_gen_tbl(i).source_id :=  x_tclv_tbl(i).id;

        l_tmpl_identify_tbl(i).product_id := l_product_id;
        l_tmpl_identify_tbl(i).stream_type_id := x_tclv_tbl(i).sty_id;
        l_tmpl_identify_tbl(i).transaction_type_id := l_try_id;
        l_tmpl_identify_tbl(i).advance_arrears := NULL;
        l_tmpl_identify_tbl(i).prior_year_yn := 'N';
        l_tmpl_identify_tbl(i).memo_yn := 'N';
        --Bug 4622198.
        l_tmpl_identify_tbl(i).factoring_synd_flag := l_fact_sync_code;
        l_tmpl_identify_tbl(i).investor_code := l_inv_acct_code;

        l_dist_info_tbl(i).amount := x_tclv_tbl(i).amount;
        l_dist_info_tbl(i).accounting_date := x_tcnv_rec.date_transaction_occurred;
        l_dist_info_tbl(i).source_table := l_source_table;
        l_dist_info_tbl(i).currency_code := x_tcnv_rec.currency_code;
        l_dist_info_tbl(i).currency_conversion_type := x_tcnv_rec.currency_conversion_type;
        l_dist_info_tbl(i).currency_conversion_rate := x_tcnv_rec.currency_conversion_rate;
        l_dist_info_tbl(i).currency_conversion_date := x_tcnv_rec.currency_conversion_date;
        l_dist_info_tbl(i).source_id := x_tclv_tbl(i).id;
        l_dist_info_tbl(i).post_to_gl := 'Y';
        l_dist_info_tbl(i).gl_reversal_flag := 'N';
      END LOOP;

      l_tcn_id := x_tcnv_rec.id;
      -- Calling the new Accounting Engine Signature
      Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
                                  p_api_version        => l_api_version,
                                  p_init_msg_list      => p_init_msg_list,
                                  x_return_status      => l_return_status,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
                                  p_dist_info_tbl      => l_dist_info_tbl,
                                  p_ctxt_val_tbl           => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl        => l_acc_gen_tbl,
                                  x_template_tbl       => l_template_out_tbl,
                                  x_amount_tbl         => l_amount_out_tbl,
				  p_trx_header_id      => l_tcn_id);

      -- store the highest degree of error
      IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_CRE_DIST_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => l_cntrct_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSE
          -- record that there was an error
          Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_CRE_DIST_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => l_cntrct_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      --Bug 5707866 - End of Changes

      -- SGIYER - MGAAP BUG 7263041
      OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,P_TCNV_REC => x_tcnv_rec
                           ,P_TCLV_TBL => x_tclv_tbl
                           ,p_ctxt_val_tbl => l_ctxt_tbl
                           ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

       -- set the return status
       x_return_status := l_return_status;

       OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN OTHERS THEN
      IF pdt_id_csr%ISOPEN THEN
        CLOSE pdt_id_csr;
      END IF;

      IF contract_num_csr%ISOPEN THEN
        CLOSE contract_num_csr;
      END IF;

      IF currency_info_csr%ISOPEN THEN
        CLOSE currency_info_csr;
      END IF;

      IF trx_types_csr%ISOPEN THEN
        CLOSE trx_types_csr;
      END IF;

      IF gen_loss_trx_csr%ISOPEN THEN
        CLOSE gen_loss_trx_csr;
      END IF;

      IF spec_loss_trx_csr%ISOPEN THEN
        CLOSE spec_loss_trx_csr;
      END IF;

      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status := OKL_API.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END SPECIFIC_LOSS_PROVISION;

END OKL_LOSS_PROV_PVT;

/
