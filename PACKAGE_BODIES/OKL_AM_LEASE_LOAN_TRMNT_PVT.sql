--------------------------------------------------------
--  DDL for Package Body OKL_AM_LEASE_LOAN_TRMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_LEASE_LOAN_TRMNT_PVT" AS
/* $Header: OKLRLLTB.pls 120.42.12010000.4 2009/12/15 10:00:05 racheruv ship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_STATEMENT            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_lease_loan_trmnt_pvt.';

  -- Start of comments
  --
  -- Function Name	: check_int_calc_done.
  -- Description    : Returns 'Y' if last int calc was after last scheduled calculation
  -- Business Rules	: Called from OKL_AM_CREATE_QUOTE_PVT, OKL_AM_TERMNT_QUOTE_PVT and OKL_AM_LEASE_TRMNT_PVT
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU LOANS_ENHACEMENT
  --                : SECHAWLA 20-JAN-06 4970009 : Added the interest calculation check for lease contracts
  --                       with int calc basis ('FLOAT_FACTORS','REAMORT')
  --                  SECHAWLA 24-JAN-05 4970009 : Modified check_int_calc_done to compare last_int_calc_till_date
  --                       with termination  date instead of last_sch_int_calc_date, to determine if
  --                       variable rate processing has been done completely
  --                  RMUNJULU 20-FEB-06 5050158 : Modified the check based on contract end date
  --
  -- End of comments
  FUNCTION check_int_calc_done(
               p_contract_id         IN NUMBER,
               p_contract_number     IN VARCHAR2,
               p_quote_number        IN NUMBER DEFAULT NULL,
               p_source              IN VARCHAR2,
               p_trn_date            IN DATE) RETURN VARCHAR2 IS

	  -- rmunjulu BUG 5050158
      CURSOR get_contract_end_date_csr (p_contract_id IN NUMBER ) IS
        SELECT end_date
        FROM   okc_k_headers_b
        WHERE  id = p_contract_id;

      l_last_int_calc_till_date DATE;
      l_last_sch_int_calc_date DATE;
      l_return_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
      l_deal_type VARCHAR2(300);
      l_rev_rec_method VARCHAR2(300);
	     l_int_cal_basis VARCHAR2(300);
  	   l_tax_owner VARCHAR2(300);
      l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_int_calc_done';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
      is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
      is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

	  -- rmunjulu BUG 5050158
		l_contract_end_date DATE;

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_id: '|| p_contract_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_number: '|| p_contract_number);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_quote_number: '|| p_quote_number);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_source: '|| p_source);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_trn_date: '|| p_trn_date);
     END IF;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_contract_product_details');
      END IF;
      -- Get the contract product details
      OKL_AM_UTIL_PVT.get_contract_product_details(
                      p_khr_id           => p_contract_id,
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

	  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   	  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 	 RAISE OKL_API.G_EXCEPTION_ERROR;
   	  END IF;

     -- only for loans check int calc
     -- rmunjulu LOANS_ENHANCEMENT added condition to check for only some cases
     IF ( (l_deal_type LIKE 'LOAN%' AND l_int_cal_basis IN ('FLOAT','REAMORT','CATCHUP/CLEANUP'))
	       OR --SECHAWLA 20-JAN-06 4970009 :Added the following condition to cover certain type of leases
		  (l_deal_type LIKE 'LEASE%' AND l_int_cal_basis IN ('FLOAT_FACTORS','REAMORT') ) -- SECHAWLA 20-JAN-06 4970009 : added
		) THEN

         IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_VARIABLE_INT_UTIL_PVT.get_last_interim_int_calc_date');
         END IF;
         -- get last interest calculation till date
         l_last_int_calc_till_date := OKL_VARIABLE_INT_UTIL_PVT.get_last_interim_int_calc_date(
                                       x_return_status    => l_return_status,
                                       p_khr_id           => p_contract_id);
         IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_VARIABLE_INT_UTIL_PVT.get_last_interim_int_calc_date , return status: ' || l_return_status);
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_last_int_calc_till_date: ' || l_last_int_calc_till_date);
         END IF;

   	     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   	     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 	    RAISE OKL_API.G_EXCEPTION_ERROR;
   	     END IF;

		 -- SECHAWLA 24-JAN-05 4970009 :  comparing  l_last_int_calc_till_date with
		 -- l_last_sch_int_calc_date won't work. e.g K1 (15-Jul-04 - 14-Oct-04)
		 -- ran variable rate procesing. It runs for 1 month at a time, starting from
		 -- the begining/last run date.
		 -- At the end of 1st run, l_last_int_calc_till_date = 15-AUG-04, l_last_sch_int_calc_date = 15-SEP-04
		 -- ran variable rate procesing 2nd time
		 -- At the end of 2nd run, l_last_int_calc_till_date = 15-SEP-04, l_last_sch_int_calc_date = 15-SEP-04
		 -- So our check ( l_last_int_calc_till_date < l_last_sch_int_calc_date) will fail and we will
		 -- allow termination. This is wrong. Variable rate processing needs to run for 1 more month (till the
		 -- contract end date). So we should compare l_last_int_calc_till_date with p_trn_date
		 -- Run variable rate processing for the 3rd time.
		 -- At the end of 3rd run, l_last_int_calc_till_date = 15-OCT-04, l_last_sch_int_calc_date = 15-SEP-04
		 -- Now l_last_int_calc_till_date > p_trn_date (termination date) and it is ok to terminate at this point

		  -- rmunjulu BUG 5050158 WE NEED THE CHECK FOR LAST SCHEDULED INTEREST CALCULATION OR ELSE
		  -- IF USER TRIES TO DO TERMINATION ON 20-AUG, AND SCHEDULED IS 15-AUG, IT ERRORS.

         -- get last scheduled interest calculation date before termination date

         IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_VARIABLE_INT_UTIL_PVT.get_last_sch_int_calc_date');
         END IF;
         l_last_sch_int_calc_date := OKL_VARIABLE_INT_UTIL_PVT.get_last_sch_int_calc_date(
                                       x_return_status    => l_return_status,
                                       p_khr_id           => p_contract_id,
                                       p_effective_date   => p_trn_date);
         IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_VARIABLE_INT_UTIL_PVT.get_last_sch_int_calc_date , return status: ' || l_return_status);
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_last_sch_int_calc_date: ' || l_last_sch_int_calc_date);
         END IF;

   	     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   	     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 	    RAISE OKL_API.G_EXCEPTION_ERROR;
   	     END IF;

    	 -- rmunjulu BUG 5050158 derive contract end date
   	     --OPEN get_contract_end_date_csr (p_contract_id);
   	     --FETCH get_contract_end_date_csr INTO l_contract_end_date;
   	     --CLOSE get_contract_end_date_csr;

    	 -- rmunjulu BUG 5050158 Final logic
    	 -- If last int calc till date is NULL or last int calc till date < last scheduled int calc then
		     -- throw error

     	 -- rmunjulu BUG 5050158
   	     --IF trunc(l_contract_end_date) < trunc(p_trn_date) THEN --  rmunjulu BUG 5050158 termination after contract end date

	     -- if last int calc date is less than last scheduled int calculation then throw error
         IF l_last_int_calc_till_date IS NULL
		 OR (trunc(l_last_int_calc_till_date) < trunc(l_last_sch_int_calc_date)) THEN --SECHAWLA 24-JAN-05 4970009
		   --OR (trunc(l_last_int_calc_till_date) < trunc(p_trn_date)  --SECHAWLA 24-JAN-05 4970009
		   --AND trunc(l_last_int_calc_till_date) < trunc(l_contract_end_date)) THEN -- rmunjulu BUG 5050158 Add condition to catch last calc

           -- If quote_number passed then give quote message
           IF p_source = 'CREATE' THEN

              -- Termination quote cannot be created. Please process interest calculation
              -- for contract CONTRACT_NUMBER up to the quote effective from date.
              OKL_API.set_message (
         			           p_app_name  	  => 'OKL',
              		    	   p_msg_name  	  => 'OKL_AM_CREATE_TQ_RUN_INT_CALC',
                               p_token1       => 'CONTRACT_NUMBER',
                               p_token1_value => p_contract_number);

              RETURN 'N';

           ELSIF p_quote_number IS NOT NULL AND p_source = 'UPDATE' THEN

              -- Quote QUOTE_NUMBER can not be accepted. Please process interest calculation
              -- for contract CONTRACT_NUMBER up to the quote effective from date.
              OKL_API.set_message (
         			           p_app_name  	  => 'OKL',
              		    	   p_msg_name  	  => 'OKL_AM_UPD_TQ_RUN_INT_CALC',
                               p_token1       => 'QUOTE_NUMBER',
                               p_token1_value => p_quote_number,
                               p_token2       => 'CONTRACT_NUMBER',
                               p_token2_value => p_contract_number);

              RETURN 'N';

           ELSIF p_source = 'TERMINATE' THEN

              -- Contract CONTRACT_NUMBER can not be terminated. Please process Regular Stream Billing
              -- for contract up to the termination date TERMINATION_DATE.
              OKL_API.set_message (
         			           p_app_name  	  => 'OKL',
              		    	   p_msg_name  	  => 'OKL_AM_TERMT_RUN_INT_CALC',
                               p_token1       => 'CONTRACT_NUMBER',
                               p_token1_value => p_contract_number,
                               p_token2       => 'TERMINATION_DATE',
                               p_token2_value => p_trn_date);

              RETURN 'N';

           END IF;
        END IF;
		  /*
		ELSE -- rmunjulu BUG 5050158 termination before contract end date (use old logic)

	     -- if last int calc date is less than last scheduled int calculation then throw error
         IF l_last_int_calc_till_date IS NULL
		 OR trunc(l_last_int_calc_till_date) < trunc(l_last_sch_int_calc_date) THEN

           -- If quote_number passed then give quote message
           IF p_source = 'CREATE' THEN

              -- Termination quote cannot be created. Please process interest calculation
              -- for contract CONTRACT_NUMBER up to the quote effective from date.
              OKL_API.set_message (
         			           p_app_name  	  => 'OKL',
              		    	   p_msg_name  	  => 'OKL_AM_CREATE_TQ_RUN_INT_CALC',
                               p_token1       => 'CONTRACT_NUMBER',
                               p_token1_value => p_contract_number);

              RETURN 'N';

           ELSIF p_quote_number IS NOT NULL AND p_source = 'UPDATE' THEN

              -- Quote QUOTE_NUMBER can not be accepted. Please process interest calculation
              -- for contract CONTRACT_NUMBER up to the quote effective from date.
              OKL_API.set_message (
         			           p_app_name  	  => 'OKL',
              		    	   p_msg_name  	  => 'OKL_AM_UPD_TQ_RUN_INT_CALC',
                               p_token1       => 'QUOTE_NUMBER',
                               p_token1_value => p_quote_number,
                               p_token2       => 'CONTRACT_NUMBER',
                               p_token2_value => p_contract_number);

              RETURN 'N';

           ELSIF p_source = 'TERMINATE' THEN

              -- Contract CONTRACT_NUMBER can not be terminated. Please process Regular Stream Billing
              -- for contract up to the termination date TERMINATION_DATE.
              OKL_API.set_message (
         			           p_app_name  	  => 'OKL',
              		    	   p_msg_name  	  => 'OKL_AM_TERMT_RUN_INT_CALC',
                               p_token1       => 'CONTRACT_NUMBER',
                               p_token1_value => p_contract_number,
                               p_token2       => 'TERMINATION_DATE',
                               p_token2_value => p_trn_date);

              RETURN 'N';

           END IF;

		 END IF;

		 END IF;  -- rmunjulu BUG 5050158
		     */
      END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning Y');
     END IF;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
     END IF;

      RETURN 'Y';

  EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;
        RETURN NULL;

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;
        RETURN NULL;

      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        OKL_API.set_message(
                   p_app_name      => OKC_API.G_APP_NAME,
                   p_msg_name      => G_UNEXPECTED_ERROR,
                   p_token1        => G_SQLCODE_TOKEN,
                   p_token1_value  => SQLCODE,
                   p_token2        => G_SQLERRM_TOKEN,
                   p_token2_value  => SQLERRM);

        RETURN NULL;

  END check_int_calc_done;

-- Start of Commnets
-- Procedure Name       : get_last_run
-- Description          : Gets the last run of TRX_MSGS
-- Business Rules       :
-- Parameters           : P_Trx_Id
-- Version              : 1.0
-- History              : RMUNJULU 24-SEP-03 3018641 created
-- End of Commnets
  PROCEDURE get_last_run(
                         p_trx_id         IN  NUMBER,
                         x_last_run       OUT NOCOPY NUMBER) IS

     -- Get the last run for TRX_MSGS
     CURSOR get_last_run_csr ( p_trx_id IN NUMBER) IS
         SELECT NVL(MAX(TMG.tmg_run),0) last_run
         FROM   OKL_TRX_MSGS TMG
         WHERE  TMG.trx_id = p_trx_id;

     l_last_run NUMBER := 0;
      l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_last_run';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
      is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
      is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_trx_id: '|| p_trx_id);
     END IF;

     -- Get the last run
     FOR get_last_run_rec IN get_last_run_csr(p_trx_id) LOOP

       l_last_run := get_last_run_rec.last_run;

     END LOOP;

    x_last_run := l_last_run;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
       IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
       END IF;
       -- Set the oracle error message
       OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => SQLCODE,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => SQLERRM);
       x_last_run := NULL;

  END get_last_run;


-- Start of Commnets
-- Procedure Name       : get_set_tmg_run
-- Description          : Gets the last run of TRX_MSGS and increments by 1 and sets TMG_RUN
-- Business Rules       :
-- Parameters           : P_Trx_Id
-- Version              : 1.0
-- History              : RMUNJULU 24-SEP-03 3018641 created
-- End of Commnets
  PROCEDURE get_set_tmg_run(
                         p_trx_id         IN  NUMBER,
                         x_return_status  OUT NOCOPY VARCHAR2) IS


     -- Get the unfilled TMG_RUN rows for the trx_id
     CURSOR get_empty_tmg_run_csr ( p_trx_id IN NUMBER) IS
         SELECT TMG.id,
                TMG.object_version_number
         FROM   OKL_TRX_MSGS TMG
         WHERE  TMG.trx_id = p_trx_id
         AND    TMG.tmg_run IS NULL;

     l_last_run         NUMBER;
     lp_tmgv_tbl		OKL_TRX_MSGS_PUB.tmgv_tbl_type;
	 lx_tmgv_tbl		OKL_TRX_MSGS_PUB.tmgv_tbl_type;

	 l_return_status    VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

	 l_api_version		CONSTANT NUMBER	:= 1;
	 l_msg_count		NUMBER		:= OKL_API.G_MISS_NUM;
	 l_msg_data		    VARCHAR2(2000);
     i NUMBER := 1;
     l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_set_tmg_run';
     is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
     is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
     is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_trx_id: '|| p_trx_id);
     END IF;

     -- Get the last run
     get_last_run(
                  p_trx_id        => p_trx_id,
                  x_last_run      => l_last_run);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called get_last_run , l_last_run: ' || l_last_run);
      END IF;

     -- increment the last run
     l_last_run := l_last_run + 1;

     -- get the rows which needs to be update with last run
     FOR get_empty_tmg_run_rec IN get_empty_tmg_run_csr(p_trx_id) LOOP

        lp_tmgv_tbl(i).id := get_empty_tmg_run_rec.id;
        lp_tmgv_tbl(i).object_version_number := get_empty_tmg_run_rec.object_version_number;
        lp_tmgv_tbl(i).tmg_run :=  l_last_run;

        i := i + 1;

     END LOOP;

     -- Update the TMG_RUN of OKL_TRX_MSGS with l_last_run+1 for the TRX_ID with null TMG_RUN
	IF (lp_tmgv_tbl.COUNT > 0) THEN

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TRX_MSGS_PUB.update_trx_msgs');
        END IF;
		OKL_TRX_MSGS_PUB.update_trx_msgs (
			p_api_version	=> l_api_version,
			p_init_msg_list	=> OKL_API.G_FALSE,
			x_return_status	=> l_return_status,
			x_msg_count	    => l_msg_count,
			x_msg_data   	=> l_msg_data,
			p_tmgv_tbl	    => lp_tmgv_tbl,
			x_tmgv_tbl	    => lx_tmgv_tbl);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_TRX_MSGS_PUB.update_trx_msgs , return status: ' || l_return_status);
        END IF;

		IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
			RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
			RAISE OKL_API.G_EXCEPTION_ERROR;
		END IF;

	END IF;

    x_return_status := l_return_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
     END IF;
     x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF (is_debug_exception_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
     END IF;
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
       IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
       END IF;
       -- Set the oracle error message
       OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => SQLCODE,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => SQLERRM);
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_set_tmg_run;


  -- ++++++++++++++++++++  service contract integration begin ++++++++++++++++++

  -- Start of comments
  --
  -- Function Name	: check_service_link.
  -- Description    : If a link exists, the service contract information is returned back.
  --                  If no link exists, it returns NULL to service contract out variables.
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU 3061751 27-AUG-2003 Created
  --
  -- End of comments
  PROCEDURE check_service_link (
                                p_api_version             IN  NUMBER,
                                p_init_msg_list           IN  VARCHAR2,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2,
                                p_lease_asset_id          IN  OKC_K_LINES_V.ID%TYPE,
                                x_service_contract_id     OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               ) IS

  l_api_name    VARCHAR2(35)    := 'check_service_link';
  l_proc_name   VARCHAR2(35)    := 'CHECK_SERVICE_LINK';
  l_api_version CONSTANT NUMBER := 1;
  l_okl_chr_id OKC_K_HEADERS_V.ID%TYPE;
  l_oks_chr_id OKC_K_HEADERS_V.ID%TYPE;
  l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_service_link';
  is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
  is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
  is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  G_API_TYPE VARCHAR2(20) := '_PVT';


  -- Check if the Financial asset is serviced thru OKS - Will return the OKL Contract
  CURSOR link_csr (p_kle_id OKC_K_LINES_V.ID%TYPE) IS
      SELECT KREL.chr_id   okl_contract_id
      FROM   OKC_K_HEADERS_B   OKS_CHRB,
             OKC_LINE_STYLES_B OKS_COV_PD_LSE,
             OKC_K_LINES_B     OKS_COV_PD_CLEB,
             OKC_K_REL_OBJS    KREL,
             OKC_LINE_STYLES_B LNK_SRV_LSE,
             OKC_STATUSES_B    LNK_SRV_STS,
             OKC_K_LINES_B     LNK_SRV_CLEB,
             OKC_K_ITEMS       LNK_SRV_CIM
      WHERE  OKS_CHRB.scs_code             = 'SERVICE'
      AND    OKS_CHRB.id                   = OKS_COV_PD_CLEB.dnz_chr_id
      AND    OKS_COV_PD_CLEB.lse_id        = OKS_COV_PD_LSE.id
      AND    OKS_COV_PD_LSE.lty_code       = 'COVER_PROD'
      AND    '#'                           = KREL.object1_id2
      AND    OKS_COV_PD_CLEB.id            = KREL.object1_id1
      AND    KREL.rty_code                 = 'OKLSRV'
      AND    KREL.cle_id                   = LNK_SRV_CLEB.id
      AND    LNK_SRV_CLEB.lse_id           = LNK_SRV_LSE.id
      AND    LNK_SRV_LSE.lty_code          = 'LINK_SERV_ASSET'
      AND    LNK_SRV_CLEB.sts_code         = LNK_SRV_STS.code
      AND    LNK_SRV_CLEB.id               = LNK_SRV_CIM.cle_id
      AND    LNK_SRV_CIM.jtot_object1_code = 'OKX_COVASST'
      AND    LNK_SRV_CIM.object1_id2       = '#'
      AND    LNK_SRV_CIM.object1_id1       = p_kle_id;

  BEGIN -- main process begins here
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_lease_asset_id: '|| p_lease_asset_id);
     END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Check if the Financial Asset is Serviced thru OKS
      FOR link_rec IN link_csr(p_lease_asset_id) LOOP
        l_okl_chr_id := link_rec.okl_contract_id;
      END LOOP;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_SERVICE_INTEGRATION_PVT.check_service_link');
      END IF;
      -- Get the Service Contract for the Leased Contract
      OKL_SERVICE_INTEGRATION_PVT.check_service_link (
                   p_api_version           => p_api_version,
                   p_init_msg_list         => OKL_API.G_FALSE,
                   x_return_status         => x_return_status,
                   x_msg_count             => x_msg_count,
                   x_msg_data              => x_msg_data,
                   p_lease_contract_id     => l_okl_chr_id ,
                   x_service_contract_id   => l_oks_chr_id);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_SERVICE_INTEGRATION_PVT.check_service_link , return status: ' || x_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_oks_chr_id: ' || l_oks_chr_id);
      END IF;

      x_service_contract_id := l_oks_chr_id;

      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);
      IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
      END IF;

  EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
         IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
         END IF;
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
         END IF;
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
         END IF;
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END check_service_link;

  -- Start of comments
  --
  -- Function Name	: check_true_partial_quote.
  -- Description    : Returns Y if TRUE partial quote(some more assets); else N or NULL
  -- Business Rules	: CALLED FROM OKL_AM_LEASE_LOAN_TRMNT_PVT, OKL_AM_TERMNT_QUOTE_PVT
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU 3061751 27-AUG-2003 Created
  --
  -- End of comments
  FUNCTION check_true_partial_quote(
               p_quote_id     IN NUMBER,
               p_contract_id  IN NUMBER) RETURN VARCHAR2 IS

      -- Get the quote assets count
      CURSOR get_quote_assets_no_csr (p_qte_id IN NUMBER) IS
      SELECT COUNT(TQL.id) no_of_quote_assets
      FROM   OKL_TXL_QUOTE_LINES_B TQL
      WHERE  TQL.qlt_code = 'AMCFIA'
      AND    TQL.qte_id = p_qte_id;

      -- Get the contract assets count - All NON Terminated Financial Assets
      -- rmunjulu INVESTOR_DISB_ADJ
      -- get assets with same status as contract
      CURSOR get_contract_assets_no_csr (p_khr_id IN NUMBER) IS
      SELECT COUNT(CLE.id) no_of_contract_assets
      FROM   OKC_K_LINES_B CLE,
             OKC_LINE_STYLES_B LSE,
             --OKC_STATUSES_B STS,
             OKC_K_HEADERS_B CHR
      WHERE  CLE.lse_id = LSE.id
      AND    LSE.lty_code = 'FREE_FORM1'
      --AND    CLE.sts_code = STS.code
      AND    CLE.sts_code = CHR.sts_code
      AND    CHR.id = CLE.dnz_chr_id
      --AND    STS.ste_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED') --OKC STATUSES
      AND    CLE.dnz_chr_id = p_khr_id;

      -- Get the quote assets details
      CURSOR get_asset_qty_csr (p_qte_id IN NUMBER) IS
      SELECT TQL.kle_id,
             TQL.asset_quantity,
             TQL.quote_quantity
      FROM   OKL_TXL_QUOTE_LINES_B TQL
      WHERE  TQL.qlt_code = 'AMCFIA'
      AND    TQL.qte_id = p_qte_id;

      l_quote_assets_no NUMBER;
      l_contract_assets_no NUMBER;
      l_true_partial_quote VARCHAR2(1) := 'N';
      l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_true_partial_quote';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
      is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
      is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_quote_id: '|| p_quote_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_id: '|| p_contract_id);
     END IF;

      -- Get the no of assets in quote
      FOR get_quote_assets_no_rec
      IN  get_quote_assets_no_csr(p_quote_id) LOOP
          l_quote_assets_no := get_quote_assets_no_rec.no_of_quote_assets;
      END LOOP;

      -- Get the no of assets in contract - non terminated
      FOR get_contract_assets_no_rec
      IN  get_contract_assets_no_csr(p_contract_id) LOOP
          l_contract_assets_no := get_contract_assets_no_rec.no_of_contract_assets;
      END LOOP;

      -- If quoted assets no = contract assets no
      IF l_quote_assets_no = l_contract_assets_no THEN

          -- For Each Quote Asset Check Corresponding contract asset quantity
          -- If do not match then l_true_partial_quote = 'Y'
          FOR get_asset_qty_rec
          IN  get_asset_qty_csr(p_quote_id) LOOP

              -- Should not have any upgrade issues (when asset_qty
              -- and quote_qty are not filled) In those cases its always
              -- full_termination and wont get inside below IF

              -- If asset_qty > quote_qty then TRUE PARTIAL
              IF get_asset_qty_rec.asset_quantity > get_asset_qty_rec.quote_quantity THEN

                  l_true_partial_quote := 'Y';

              END IF;

          END LOOP;

      ELSE -- assets number for quote and contract do not match -- so TRUE PARTIAL

          l_true_partial_quote := 'Y';

      END IF;
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning l_true_partial_quote: '||l_true_partial_quote);
      END IF;
      IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
      END IF;

      RETURN l_true_partial_quote;

  EXCEPTION

      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        OKL_API.set_message(
                   p_app_name      => OKC_API.G_APP_NAME,
                   p_msg_name      => G_UNEXPECTED_ERROR,
                   p_token1        => G_SQLCODE_TOKEN,
                   p_token1_value  => SQLCODE,
                   p_token2        => G_SQLERRM_TOKEN,
                   p_token2_value  => SQLERRM);

	    RETURN NULL;

  END check_true_partial_quote;

  -- Start of comments
  --
  -- Function Name	: check_true_partial_quote.
  -- Description    : Returns Y if TRUE partial quote(some more assets); else N or NULL
  -- Business Rules	: CALLED FROM OKL_AM_LEASE_LOAN_TRMNT_PVT
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : rmunjulu bug 4997075
  --
  -- End of comments
  FUNCTION check_true_partial_quote_yn(
               p_quote_id     IN NUMBER,
               p_contract_id  IN NUMBER) RETURN VARCHAR2 IS

      -- Get the quote assets details
      CURSOR get_asset_qty_csr (p_qte_id IN NUMBER) IS
      SELECT TQL.kle_id,
             TQL.asset_quantity,
             TQL.quote_quantity
      FROM   OKL_TXL_QUOTE_LINES_B TQL
      WHERE  TQL.qlt_code = 'AMCFIA'
      AND    TQL.qte_id = p_qte_id;

       -- get any additional assets on contract which are non terminated and not in quote
      CURSOR get_additional_assets_csr (p_khr_id IN NUMBER, p_qte_id IN NUMBER) IS
      SELECT 1
      FROM   OKC_K_LINES_B CLE,
             OKC_LINE_STYLES_B LSE,
             OKC_K_HEADERS_B CHR
      WHERE  CLE.lse_id = LSE.id
      AND    LSE.lty_code = 'FREE_FORM1'
      AND    CLE.sts_code = CHR.sts_code
      AND    CHR.id = CLE.dnz_chr_id
      AND    CLE.dnz_chr_id = p_khr_id
      AND    CLE.id NOT IN
                    (SELECT kle_id
                     FROM   OKL_TXL_QUOTE_LINES_B
                     WHERE  qte_id = p_qte_id
                     AND    qlt_code = 'AMCFIA');

      l_quote_assets_no NUMBER;
      l_contract_assets_no NUMBER;
      l_true_partial_quote VARCHAR2(1) := 'N';
      l_additional_assets_yn VARCHAR2(3);
      l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_true_partial_quote_yn';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
      is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
      is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN
      IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
      END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_quote_id: '|| p_quote_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_id: '|| p_contract_id);
     END IF;

      -- Check if any more assets exist in contract which have not been quoted
      FOR get_additional_assets_rec IN get_additional_assets_csr (p_contract_id,p_quote_id) LOOP
         l_additional_assets_yn := 'Y';
      END LOOP;

      IF nvl(l_additional_assets_yn,'N')  = 'N' THEN -- no more assets exist in contract which has not been quoted

          -- For Each Quote Asset Check Corresponding contract asset quantity
          -- If do not match then l_true_partial_quote = 'Y'
          FOR get_asset_qty_rec
          IN  get_asset_qty_csr(p_quote_id) LOOP

              -- Should not have any upgrade issues (when asset_qty
              -- and quote_qty are not filled) In those cases its always
              -- full_termination and wont get inside below IF

              -- If asset_qty > quote_qty then TRUE PARTIAL
              IF get_asset_qty_rec.asset_quantity > get_asset_qty_rec.quote_quantity THEN

                  l_true_partial_quote := 'Y';

              END IF;

          END LOOP;

      ELSE -- some more assets exist for the contract which have not been quoted so - TRUE PARTIAL

          l_true_partial_quote := 'Y';

      END IF;
      IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
      END IF;
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning l_true_partial_quote: '||l_true_partial_quote);
      END IF;

      RETURN l_true_partial_quote;

  EXCEPTION

      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        OKL_API.set_message(
                   p_app_name      => OKC_API.G_APP_NAME,
                   p_msg_name      => G_UNEXPECTED_ERROR,
                   p_token1        => G_SQLCODE_TOKEN,
                   p_token1_value  => SQLCODE,
                   p_token2        => G_SQLERRM_TOKEN,
                   p_token2_value  => SQLERRM);

	    RETURN NULL;

  END check_true_partial_quote_yn;


  -- Start of comments
  --
  -- Function Name	: check_service_k_int_needed.
  -- Description    : Returns Y if Service Intergration needed; else N or NULL
  -- Business Rules	: Called from OKL_AM_LEASE_LOAN_TRMNT_PVT
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU 3061751 27-AUG-2003 Created
  --                  RMUNJULU 05-JAN-04 SERVICE K UPDATES
  --
  -- End of comments
  FUNCTION check_service_k_int_needed(
               p_term_rec     IN term_rec_type DEFAULT G_TERM_REC_EMPTY,
               p_tcnv_rec     IN tcnv_rec_type DEFAULT G_TCNV_REC_EMPTY,
               p_partial_yn   IN VARCHAR2 DEFAULT NULL,
               p_asset_id     IN NUMBER DEFAULT NULL,
               p_source       IN VARCHAR2) RETURN VARCHAR2 IS

      l_service_integration_needed VARCHAR2(1) := 'N';
      l_true_partial_quote VARCHAR2(1) := 'N';
      l_oks_chr_id NUMBER;
      l_return_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;

      l_api_version CONSTANT NUMBER := 1;
      l_msg_count NUMBER := OKL_API.G_MISS_NUM;
      l_msg_data VARCHAR2(2000);
      l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_service_k_int_needed';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
      is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
      is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_partial_yn: '|| p_partial_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_asset_id: '|| p_asset_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_source: '|| p_source);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_id: '|| p_term_rec.p_contract_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_recycle_yn: '||p_tcnv_rec.tmt_recycle_yn);
     END IF;

      -- IF SOURCE = 'TERMINATION'
      --   If Recycle YN = 'N'  AND Linked Lease AND Full Termination THEN
      --     RETURN Y
      --   End if ;
      -- IF SOURCE = 'DISPOSE'
      --   If linked lease THEN
      --     RETURN Y
      -- IF SOURCE = 'RETURN'
      --   If linked lease THEN
      --     RETURN Y

      -- Check Source
      IF p_source = 'TERMINATION' THEN -- Termination, so p_term_rec, p_tcnv_rec and p_partial_yn will be filled

-- RMUNJULU 05-JAN-04 Removed condition to check only if non recycle as this can be done in recycle too
-- we now check that the contract is terminated to say that service int is needed
-- since this procedure is called before the termination we cannot check contract is terminated or not here
-- so we will check that in service_k_intergration procedure.
          -- If Recycle_YN = N
--          IF NVL(p_tcnv_rec.tmt_recycle_yn,'N') = 'N'
--          OR p_tcnv_rec.tmt_recycle_yn = OKL_API.G_MISS_CHAR THEN

              -- Get the linked lease details
              IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_SERVICE_INTEGRATION_PVT.check_service_link');
              END IF;
              OKL_SERVICE_INTEGRATION_PVT.check_service_link (
                                p_api_version           => l_api_version,
                                p_init_msg_list         => OKL_API.G_FALSE,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data,
                                p_lease_contract_id     => p_term_rec.p_contract_id ,
                                x_service_contract_id   => l_oks_chr_id);

              IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_SERVICE_INTEGRATION_PVT.check_service_link , return status: ' || l_return_status);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_oks_chr_id: ' || l_oks_chr_id);
              END IF;
              -- If linked Lease
              IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
              AND l_oks_chr_id IS NOT NULL THEN

                  -- Find if Full Termination
                  IF p_partial_yn = 'Y' THEN

                      -- need to check if no more assets (This case p_quote_id is Always populated)
                      l_true_partial_quote := check_true_partial_quote_yn( -- rmunjulu 4997075
                                                 p_quote_id     => p_term_rec.p_quote_id,
                                                 p_contract_id  => p_term_rec.p_contract_id);
                      IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called check_true_partial_quote_yn , l_true_partial_quote: ' || l_true_partial_quote);
                      END IF;

                  ELSE -- Partial_YN = 'N'

                      l_true_partial_quote := 'N';

                  END IF;

                  -- If TRUE partial termination then
                  IF l_true_partial_quote = 'N' THEN

                     l_service_integration_needed := 'Y';

                  END IF;
              ELSE -- Not Linked Lease

                  l_service_integration_needed := 'N';

              END IF;
--          ELSE -- Recycle YN = Y

--              l_service_integration_needed := 'N';

--          END IF;
      ELSIF p_source IN ('DISPOSE','RETURN') THEN -- DISPOSE or RETURN, so p_asset_id will be filled

          -- Get the linked lease details   -- ***
          --OKL_SERVICE_INTEGRATION_PVT.check_service_link (
          check_service_link(
                                p_api_version           => l_api_version,
                                p_init_msg_list         => OKL_API.G_FALSE,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data,
                                p_lease_asset_id        => p_asset_id ,
                                x_service_contract_id   => l_oks_chr_id);
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called check_service_link , l_oks_chr_id: ' || l_oks_chr_id);
           END IF;

          -- If linked Lease
          IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
          AND l_oks_chr_id IS NOT NULL THEN

              l_service_integration_needed := 'Y';

          ELSE -- Not linked lease -- no integration needed

              l_service_integration_needed := 'N';

          END IF;

      END IF;
      IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
      END IF;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning l_service_integration_needed: '||l_service_integration_needed);
      END IF;
      -- Set the RETURN value
      RETURN l_service_integration_needed;

  EXCEPTION

      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        OKL_API.set_message(
                   p_app_name      => OKC_API.G_APP_NAME,
                   p_msg_name      => G_UNEXPECTED_ERROR,
                   p_token1        => G_SQLCODE_TOKEN,
                   p_token1_value  => SQLCODE,
                   p_token2        => G_SQLERRM_TOKEN,
                   p_token2_value  => SQLERRM);

	    RETURN NULL;

  END check_service_k_int_needed;

  -- Start of comments
  --
  -- Procedure Name	: service_k_integration
  -- Desciption     : Do the service contract integration steps (checks + notifications)
  -- Business Rules	: Called from OKL_AM_LEASE_LOAN_TRMNT_PVT, OKL_AM_ASSET_DISPOSE_PVT, OKL_AM_ASSET_RETURN_PVT
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU 3061751 27-AUG-2003 Created
  --                : RMUNJULU 3061751 14-OCT-2003 Added code to get delink_yn from table
  --                : RMUNJULU 3061751 16-OCT-2003 Changed code to get delink_yn from OKL_SYSTEM_PARAMS_ALL_V
  --                : RMUNJULU 23-DEC-03 SERVICE K UPDATES
  --                : RMUNJULU 05-JAN-04 SERVICE K UPDATES
  --
  -- End of comments
  PROCEDURE service_k_integration(
               p_term_rec                   IN term_rec_type DEFAULT G_TERM_REC_EMPTY,
               p_transaction_id             IN NUMBER DEFAULT NULL,
               p_transaction_date           IN DATE DEFAULT NULL,
               p_source                     IN VARCHAR2,
               p_service_integration_needed IN VARCHAR2)  IS

      -- Get the quote acceptance date
      CURSOR get_quote_acc_dt_csr (p_qte_id IN NUMBER) IS
      SELECT QTE.date_accepted
      FROM   OKL_TRX_QUOTES_B QTE
      WHERE  QTE.id = p_qte_id;

      -- Get the delink_yn value set for the org
      CURSOR get_setup_values_csr IS
      SELECT SYP.delink_yn
      FROM   OKL_SYSTEM_PARAMS SYP;

      l_delink_needed VARCHAR2(1) := 'N';
      l_return_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
      l_wf_source VARCHAR2(20);
      l_termination_date DATE;
      l_quote_id NUMBER := NULL;
      l_module_name VARCHAR2(500) := G_MODULE_NAME || 'service_k_integration';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
      is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
      is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

      l_api_version CONSTANT NUMBER := 1;
      l_msg_count NUMBER := OKL_API.G_MISS_NUM;
      l_msg_data VARCHAR2(2000);

      -- RMUNJULU 23-DEC-03 SERVICE K UPDATES
      l_oks_chr_id NUMBER;

      -- RMUNJULU 05-JAN-04 new cursor to get the contract status
      -- Get the sts_code for the contract
      CURSOR get_k_sts_csr (p_chr_id IN NUMBER) IS
      SELECT CHR.sts_code
      FROM   OKC_K_HEADERS_B CHR
      WHERE  CHR.id = p_chr_id;

      -- RMUNJULU 05-JAN-04 Added variable
      l_sts_code OKC_K_HEADERS_B.sts_code%TYPE;

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_transaction_id: '|| p_transaction_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_transaction_date: '|| p_transaction_date);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_source: '|| p_source);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_service_integration_needed: '|| p_service_integration_needed);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_id: '|| p_term_rec.p_contract_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
     END IF;

      -- If Service Integration Needed
      IF NVL(p_service_integration_needed,'N') = 'Y' THEN

          -- Request from Termination
          IF  p_source = 'TERMINATION' THEN

              -- p_term_rec is passed in this case

              -- RMUNJULU 05-JAN-04 get contract status
              FOR get_k_sts_rec IN get_k_sts_csr (p_term_rec.p_contract_id) LOOP
                 l_sts_code := get_k_sts_rec.sts_code;
              END LOOP;

              -- RMUNJULU 05-JAN-04 added condition that contract is terminated/expired
              -- only then do delink (if needed) and notifications
              IF l_sts_code IN ('TERMINATED','EXPIRED' ) THEN

                 -- RMUNJULU 3061751 14-OCT-2003 Added code to get delink_yn value
                 -- Check from setup if de-link needed
                 FOR get_setup_values_rec IN get_setup_values_csr LOOP
                    l_delink_needed := get_setup_values_rec.delink_yn;
                 END LOOP;

                 -- If de-link needed
                 IF NVL(l_delink_needed,'N') = 'Y' THEN

                     -- RMUNJULU 23-DEC-03 SERVICE K UPDATES
                     -- Get the OKS contract ID before delink since after delink we loose that info
                     IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_SERVICE_INTEGRATION_PVT.check_service_link');
                     END IF;
                     OKL_SERVICE_INTEGRATION_PVT.check_service_link (
                                p_api_version           => l_api_version,
                                p_init_msg_list         => OKL_API.G_FALSE,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data,
                                p_lease_contract_id     => p_term_rec.p_contract_id ,
                                x_service_contract_id   => l_oks_chr_id);
                     IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_SERVICE_INTEGRATION_PVT.check_service_link , return status: ' || l_return_status);
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_oks_chr_id: ' || l_oks_chr_id);
                     END IF;

                     IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_SERVICE_INTEGRATION_PVT.delink_service_contract');
                     END IF;
                     -- De-link Lease from Service
                     OKL_SERVICE_INTEGRATION_PVT.delink_service_contract(
                                    p_api_version     => l_api_version,
                                    p_init_msg_list   => OKL_API.G_FALSE,
                                    x_return_status   => l_return_status,
                                    x_msg_count       => l_msg_count,
                                    x_msg_data        => l_msg_data,
                                    p_okl_chr_id      => p_term_rec.p_contract_id);
                     IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_SERVICE_INTEGRATION_PVT.delink_service_contract , return status: ' || l_return_status);
                     END IF;
                     -- If De-link successful
                     IF  l_return_status = OKL_API.G_RET_STS_SUCCESS THEN -- SUCCESS
                         l_wf_source := 'SUCCESS';
                     ELSE -- De-link error -- ERROR
                         l_wf_source := 'ERROR';
                     END IF;
                 ELSE -- de-link not needed -- TERMINATION
                     l_wf_source := 'TERMINATION';
                 END IF;

                 -- Set the termination date
                 -- If Quote Exists then Termination date = Acceptance Date
                 -- Else Termination date = Sysdate (ideal - do this after termination - get trn date)
                 IF  p_term_rec.p_quote_id IS NOT NULL
                 AND p_term_rec.p_quote_id <> OKL_API.G_MISS_NUM THEN

                     -- Get the quote acceptance date
                     FOR get_quote_acc_dt_rec
                     IN  get_quote_acc_dt_csr(p_term_rec.p_quote_id) LOOP

                         l_termination_date := get_quote_acc_dt_rec.date_accepted;

                     END LOOP;
                 ELSE -- No quote get trn date

                     -- Get the TRN DATE, FOR NOW TRN DATE IS NOT AVAILABLE, SO SYSDATE
                     l_termination_date := SYSDATE;
                 END IF;

                 -- Set the Quote Id if termination request is from Quote
                 IF  p_term_rec.p_quote_id IS NOT NULL
                 AND p_term_rec.p_quote_id <> OKL_API.G_MISS_NUM THEN

                     l_quote_id := p_term_rec.p_quote_id;

                 END IF;

                 -- Raise event to launch the service k integration workflow
                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_SERVICE_K_INT_WF.raise_service_k_int_event');
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_term_rec.p_contract_id : ' || p_term_rec.p_contract_id);
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_wf_source : ' || l_wf_source);
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_quote_id : ' || l_quote_id);
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_oks_chr_id : ' || l_oks_chr_id);
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_termination_date : ' || l_termination_date);
                 END IF;
                 OKL_AM_SERVICE_K_INT_WF.raise_service_k_int_event(
                                   p_transaction_id   => p_term_rec.p_contract_id,
                                   p_source           => l_wf_source,
                                   p_quote_id         => l_quote_id,
                                   p_oks_contract     => l_oks_chr_id, -- RMUNJULU 23-DEC-03 SERVICE K UPDATES Pass OKS contract to WF
                                   p_transaction_date => l_termination_date);
                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_SERVICE_K_INT_WF.raise_service_k_int_event');
                 END IF;

              END IF;
          ELSIF p_source = 'RETURN' THEN -- Request from Asset Return

              -- p_transaction_id and p_transaction_date will be passed
              -- p_transaction_id is ASSET_ID in this case
              -- p_transaction_date is RETURN DATE in this case

              l_wf_source := 'RETURN';

                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_SERVICE_K_INT_WF.raise_service_k_int_event');
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_transaction_id : ' || p_transaction_id);
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_wf_source : ' || l_wf_source);
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_transaction_date : ' || p_transaction_date);
                 END IF;
              -- Raise event to launch the service k integration workflow
              OKL_AM_SERVICE_K_INT_WF.raise_service_k_int_event(
                                   p_transaction_id   => p_transaction_id,
                                   p_source           => l_wf_source,
                                   p_transaction_date => p_transaction_date);
                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_SERVICE_K_INT_WF.raise_service_k_int_event');
                 END IF;


          ELSIF p_source = 'DISPOSE_1' THEN -- Request from Asset Dispose_1

              -- DISPOSE_1 when request from Term_with_purchase_Qte/Scrapped/Repurchase_Qte
              -- procedure of Asset_Dispose API. Asset is Sold/Scrapped/Sold in these cases.

              -- p_transaction_id and p_transaction_date will be passed
              -- p_transaction_id is ASSET_ID in this case
              -- p_transaction_date is DISPOSE DATE in this case

              l_wf_source := 'DISPOSE';

                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_SERVICE_K_INT_WF.raise_service_k_int_event');
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_transaction_id : ' || p_transaction_id);
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_wf_source : ' || l_wf_source);
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_transaction_date : ' || p_transaction_date);
                 END IF;
              -- Raise event to launch the service k integration workflow
              OKL_AM_SERVICE_K_INT_WF.raise_service_k_int_event(
                                   p_transaction_id   => p_transaction_id,
                                   p_source           => l_wf_source,
                                   p_transaction_date => p_transaction_date);
                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_SERVICE_K_INT_WF.raise_service_k_int_event');
                 END IF;

          ELSIF p_source = 'DISPOSE_2' THEN -- Request from Asset Dispose_2

              -- DISPOSE_2 when request from Remarketing Dispose procedure of
              -- Asset_Dispose API. Asset is Sold in this case.

              -- p_transaction_id and p_transaction_date will be passed
              -- p_transaction_id is ASSET_ID in this case
              -- p_transaction_date is DISPOSE DATE in this case

              l_wf_source := 'DISPOSE';
                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_SERVICE_K_INT_WF.raise_service_k_int_event');
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_transaction_id : ' || p_transaction_id);
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_wf_source : ' || l_wf_source);
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_transaction_date : ' || p_transaction_date);
                 END IF;
              -- Raise event to launch the service k integration workflow
              OKL_AM_SERVICE_K_INT_WF.raise_service_k_int_event(
                                   p_transaction_id   => p_transaction_id,
                                   p_source           => l_wf_source,
                                   p_transaction_date => p_transaction_date);
                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_SERVICE_K_INT_WF.raise_service_k_int_event');
                 END IF;
          END IF;
      END IF;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
     END IF;

  EXCEPTION

      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        OKL_API.set_message(
                   p_app_name      => OKC_API.G_APP_NAME,
                   p_msg_name      => G_UNEXPECTED_ERROR,
                   p_token1        => G_SQLCODE_TOKEN,
                   p_token1_value  => SQLCODE,
                   p_token2        => G_SQLERRM_TOKEN,
                   p_token2_value  => SQLERRM);

  END service_k_integration;

  -- Start of comments
  --
  -- Function Name	: check_billing_done.
  -- Description    : Returns 'Y' if BILLING DONE, Else 'N' or NULL
  -- Business Rules	: Called from OKL_AM_TERMNT_QUOTE_PVT and OKL_AM_LEASE_TRMNT_PVT
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU 3061751 23-SEP-2003 Created
  --                  RMUNJULU 05-JAN-04 SERVICE K UPDATES
  --                  rmunjulu 6795295 modified the signature to pass
  --  p_rev_rec_method, p_int_cal_basis, p_oks_chr_id, p_sts_code
  --
  -- End of comments
  FUNCTION check_billing_done(
               p_contract_id         IN NUMBER DEFAULT NULL,
               p_contract_number     IN VARCHAR2 DEFAULT NULL,
               p_quote_number        IN NUMBER DEFAULT NULL,
               p_trn_date            IN DATE DEFAULT NULL,
               p_rev_rec_method      IN VARCHAR2 DEFAULT NULL, -- rmunjulu 6795295
               p_int_cal_basis       IN VARCHAR2 DEFAULT NULL, -- rmunjulu 6795295
               p_oks_chr_id          IN NUMBER DEFAULT NULL, -- rmunjulu 6795295
               p_sts_code            IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS -- rmunjulu 6795295

      l_service_contract VARCHAR2(300);
      l_oks_chr_id NUMBER;
      l_api_version NUMBER := 1;
      l_msg_count NUMBER := OKL_API.G_MISS_NUM;
      l_msg_data VARCHAR2(2000);
      l_bill_stat_tbl OKL_BILL_STATUS_PUB.bill_stat_tbl_type; -- RMUNJULU 05-JAN-04 BPD Changed the API name
      l_bill_counter NUMBER;
      l_return_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
      l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_billing_done';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
      is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
      is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_id: '|| p_contract_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_number: '|| p_contract_number);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_quote_number: '|| p_quote_number);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_trn_date: '|| p_trn_date);
     END IF;

      -- Process Codes and Types decided on
      -- =================================================
      -- Process Type               Process Code
      -- =================================================
      --1. RENTAL                   RENTAL
      --2. SERVICE                  SERVICE
      --3. VARIABLE INTEREST        VARIABLE_INTEREST
      --4. UBB                      UBB
      --5. LATE CHARGES             LATE_CHARGES
      --6. LATE INTEREST            LATE_INTEREST
      --7. EVERGREEN                EVERGREEN
      --=================================================
      -- Limitations --
      -- For now coded for RENTAL and SERVICE billing. Will need to expand once
      -- other billing checks introduced

      -- BPD Now provides a API which tells till when the billing was done, use that
      -- RMUNJULU 05-JAN-04 BPD Changed the API name
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_BILL_STATUS_PUB.billing_status');
      END IF;
      OKL_BILL_STATUS_PUB.billing_status(
                                p_api_version           => l_api_version,
                                p_init_msg_list         => OKL_API.G_FALSE,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data,
                                x_bill_stat_tbl         => l_bill_stat_tbl,
                                p_khr_id                => p_contract_id,
                                p_transaction_date      => p_trn_date);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_BILL_STATUS_PUB.billing_status , return status: ' || l_return_status);
      END IF;

      IF l_bill_stat_tbl.COUNT > 0 THEN -- [1]

          -- loop thru the bill_statuses table
          FOR l_bill_counter IN l_bill_stat_tbl.FIRST..l_bill_stat_tbl.LAST LOOP

              -- For regular stream billing ie RENT billing
              IF l_bill_stat_tbl(l_bill_counter).transaction_type = 'RENTAL' THEN --[2]

                  -- Raise error if the last_bill_date is NULL
                  -- or if the last scheduled billing date > last billing run date
                  IF l_bill_stat_tbl(l_bill_counter).last_bill_date IS NULL
                  OR (TRUNC(l_bill_stat_tbl(l_bill_counter).last_schedule_bill_date) >
                      TRUNC(l_bill_stat_tbl(l_bill_counter).last_bill_date)) THEN --[3]

                      -- If quote_number passed then give quote message
                      IF p_quote_number IS NOT NULL THEN --[4]

                          IF  p_rev_rec_method = 'STREAMS'
                          AND p_int_cal_basis = 'FIXED'
                          AND p_oks_chr_id IS NULL
                          AND p_sts_code = 'BOOKED' THEN -- rmunjulu 6795295

                              -- message will be set in calling procedure
                              RETURN 'N';

                          ELSE   -- throw message and return N

                             -- Quote QUOTE_NUMBER can not be accepted. Please process Regular Stream billing
                             -- for contract CONTRACT_NUMBER up to the quote effective from date.
                             OKL_API.set_message (
                 			           p_app_name  	  => 'OKL',
                     		    	   p_msg_name  	  => 'OKL_AM_ACCEPT_TQ_RUN_BILLING',
                               p_token1       => 'QUOTE_NUMBER',
                               p_token1_value => p_quote_number,
                               p_token2       => 'CONTRACT_NUMBER',
                               p_token2_value => p_contract_number);

                             RETURN 'N';
                          END IF;
                      ELSE -- Give contract message

                          -- Contract CONTRACT_NUMBER can not be terminated. Please process Regular Stream Billing
                          -- for contract up to the termination date TERMINATION_DATE.
                          OKL_API.set_message (
         			           p_app_name  	  => 'OKL',
              		    	   p_msg_name  	  => 'OKL_AM_RUN_BILLING',
                               p_token1       => 'CONTRACT_NUMBER',
                               p_token1_value => p_contract_number,
                               p_token2       => 'TERMINATION_DATE',
                               p_token2_value => p_trn_date);

                          RETURN 'N';

                      END IF; --[-4]
                   END IF; --[-3]
              END IF; --[-2]
          END LOOP;
      END IF; --[-1]

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
                                p_lease_contract_id     => p_contract_id,
                                x_service_contract_id   => l_oks_chr_id);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_SERVICE_INTEGRATION_PVT.check_service_link , return status: ' || l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_oks_chr_id : ' || l_oks_chr_id);
      END IF;

      -- If linked Lease
      IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
      AND l_oks_chr_id IS NOT NULL THEN --[1]

          -- Check if OKS Billing Done
          IF l_bill_stat_tbl.COUNT > 0 THEN --[2]

              -- loop thru the bill_statuses table
              FOR l_bill_counter IN l_bill_stat_tbl.FIRST..l_bill_stat_tbl.LAST LOOP

                  -- For Service billing
                  IF l_bill_stat_tbl(l_bill_counter).transaction_type = 'SERVICE' THEN --[3]

                      -- Raise error if the last_bill_date is NULL
                      -- or if the last scheduled billing date > last billing run date
                      IF l_bill_stat_tbl(l_bill_counter).last_bill_date IS NULL
                      OR (TRUNC(l_bill_stat_tbl(l_bill_counter).last_schedule_bill_date) >
                          TRUNC(l_bill_stat_tbl(l_bill_counter).last_bill_date)) THEN --[4]

                          -- If quote_number passed then give quote message
                          IF p_quote_number IS NOT NULL THEN --[5]

                              -- Quote QUOTE_NUMBER can not be accepted. Please process service billing
                              -- for contract CONTRACT_NUMBER up to the quote effective from date.
                              OKL_API.set_message (
             			           p_app_name  	  => 'OKL',
                 		    	   p_msg_name  	  => 'OKL_AM_ACCEPT_TQ_RUN_SRV_BILL',
                                   p_token1       => 'QUOTE_NUMBER',
                                   p_token1_value => p_quote_number,
                                   p_token2       => 'CONTRACT_NUMBER',
                                   p_token2_value => p_contract_number);

                              RETURN 'N';

                          ELSE -- Give contract message

                              -- Contract CONTRACT_NUMBER can not be terminated. Please process
                              -- service billing for contract up to the termination date TERMINATION_DATE.
                              OKL_API.set_message (
         			               p_app_name  	  => 'OKL',
              		    	       p_msg_name  	  => 'OKL_AM_RUN_SRV_BILLING',
                                   p_token1       => 'CONTRACT_NUMBER',
                                   p_token1_value => p_contract_number,
                                   p_token2       => 'TERMINATION_DATE',
                                   p_token2_value => p_trn_date);

                              RETURN 'N';

                          END IF; --[-5]
                      END IF; --[-4]
                  END IF; --[-3]
              END LOOP;
          END IF; --[-2]
       END IF; --[-1]
      IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
      END IF;
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning Y');
      END IF;

      RETURN 'Y';

  EXCEPTION

      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        OKL_API.set_message(
                   p_app_name      => OKC_API.G_APP_NAME,
                   p_msg_name      => G_UNEXPECTED_ERROR,
                   p_token1        => G_SQLCODE_TOKEN,
                   p_token1_value  => SQLCODE,
                   p_token2        => G_SQLERRM_TOKEN,
                   p_token2_value  => SQLERRM);

        RETURN NULL;

  END check_billing_done;


  -- Start of comments
  --
  -- Function Name	: check_stream_billing_done.
  -- Description    : Returns 'Y' if STREAM BASED BILLING DONE, Else 'N' or NULL
  -- Business Rules	: Called from OKL_AM_TERMNT_QUOTE_PVT
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU bug 6736148  09-JAN-2008 Created
  --
  -- End of comments
  FUNCTION check_stream_billing_done(
               p_contract_id         IN NUMBER DEFAULT NULL,
               p_contract_number     IN VARCHAR2 DEFAULT NULL,
               p_quote_number        IN NUMBER DEFAULT NULL,
               p_trn_date            IN DATE DEFAULT NULL) RETURN VARCHAR2 IS

      l_service_contract VARCHAR2(300);
      l_oks_chr_id NUMBER;
      l_api_version NUMBER := 1;
      l_msg_count NUMBER := OKL_API.G_MISS_NUM;
      l_msg_data VARCHAR2(2000);
      l_bill_stat_tbl OKL_BILL_STATUS_PUB.bill_stat_tbl_type;
      l_bill_counter NUMBER;
      l_return_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
      l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_stream_billing_done';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
      is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
      is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_id: '|| p_contract_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_number: '|| p_contract_number);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_quote_number: '|| p_quote_number);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_trn_date: '|| p_trn_date);
     END IF;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_BILL_STATUS_PUB.billing_status');
      END IF;
      OKL_BILL_STATUS_PUB.billing_status(
                                p_api_version           => l_api_version,
                                p_init_msg_list         => OKL_API.G_FALSE,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data,
                                x_bill_stat_tbl         => l_bill_stat_tbl,
                                p_khr_id                => p_contract_id,
                                p_transaction_date      => p_trn_date);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_BILL_STATUS_PUB.billing_status , return status: ' || l_return_status);
      END IF;

      IF l_bill_stat_tbl.COUNT > 0 THEN -- [1]

          -- loop thru the bill_statuses table
          FOR l_bill_counter IN l_bill_stat_tbl.FIRST..l_bill_stat_tbl.LAST LOOP

              -- For regular stream billing ie RENT billing
              IF l_bill_stat_tbl(l_bill_counter).transaction_type = 'RENTAL' THEN --[2]

                  -- Raise error if the last_bill_date is NULL
                  -- or if the last scheduled billing date > last billing run date
                  IF l_bill_stat_tbl(l_bill_counter).last_bill_date IS NULL
                  OR (TRUNC(l_bill_stat_tbl(l_bill_counter).last_schedule_bill_date) >
                      TRUNC(l_bill_stat_tbl(l_bill_counter).last_bill_date)) THEN --[3]

                      -- If quote_number passed then give quote message
                      IF p_quote_number IS NOT NULL THEN --[4]

                          RETURN 'N';

                      ELSE -- Give contract message

                          RETURN 'N';

                      END IF; --[-4]
                   END IF; --[-3]
              END IF; --[-2]
          END LOOP;
      END IF; --[-1]

      IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
      END IF;
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning Y');
      END IF;

      RETURN 'Y';

  EXCEPTION

      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        OKL_API.set_message(
                   p_app_name      => OKC_API.G_APP_NAME,
                   p_msg_name      => G_UNEXPECTED_ERROR,
                   p_token1        => G_SQLCODE_TOKEN,
                   p_token1_value  => SQLCODE,
                   p_token2        => G_SQLERRM_TOKEN,
                   p_token2_value  => SQLERRM);

        RETURN NULL;

  END check_stream_billing_done;

  -- +++++++++++++++++++++ service contract integration end   ++++++++++++++++++

-- Start of comments
--
-- Procedure Name	: validate_contract
-- Description		: checks the validity of the contract
--                  Throws the proper error message if the contract found to be
--                  in the wrong status. p_control_flag decides which logic need
--                  to be applied for checking contract status
--                  The various controls this cater to are
--                  ------------------------------------------------------------
--                     P_Control_Flag value       When Checking from
--                  ------------------------------------------------------------
--                  1. CONTRACT_TERMINATE_SCRN -- Request termination screen
--                  2. TRMNT_QUOTE_CREATE      -- Termination quote create
--                  3. RESTR_QUOTE_CREATE      -- Resturcture quote create
--                  4. REPUR_QUOTE_CREATE      -- Repurchase quote create
--                  5. TRMNT_QUOTE_UPDATE      -- Termination quote update
--                  6. RESTR_QUOTE_UPDATE      -- Resturcture quote update
--                  7. REPUR_QUOTE_UPDATE      -- Repurchase quote update
--                  8. BATCH_PROCESS           -- Batch process
--                  9. ASSET_RETURN_CREATE     -- Asset return create
--                  10.ASSET_RETURN_UPDATE     -- Asset return update
--                  11.BATCH_PROCESS_CHR       -- Single request from batch
-- Business Rules	:
-- Parameters		  : api version, init msg list, return status, msg count,
--                  msg data, contract id, control flag, status code
-- Version		    : 1.0
-- History        : RMUNJULU -- 11-DEC-02: Bug # 2484327 : Added code in
--                  TRMNT_QUOTE_CREATE condition to check for termination trns
--                : RMUNJULU 18-DEC-02 2484327. Added code in CONTRACT_TERMINATE_SCRN
--                  condition to check for term trn and if no accepted qte
--                : RMUNJULU 2724951 02-JAN-02 Changed the if for checks in
--                  condition CONTRACT_TERMINATE_SCRN
--                : RMUNJULU 25-FEB-03 2818866 Changed code for condition
--                  BATCH_PROCESS removed contract status check
--                : RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
-- End of comments

  PROCEDURE validate_contract(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_contract_id                 IN  NUMBER,
           p_control_flag                IN  VARCHAR2,
           x_contract_status             OUT NOCOPY VARCHAR2)  IS

   -- Cursor to get the contract details
   -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
   CURSOR  k_header_csr IS
    SELECT chr.id,
           chr.contract_number,
           chr.template_yn,
           chr.end_date,
           khr.deal_type,
           chr.scs_code,
           chr.sts_code,
           sts.meaning
    FROM   OKC_K_HEADERS_V  chr,
           OKC_STATUSES_V   sts,
           OKL_K_HEADERS_V  khr
    WHERE  chr.id       = p_contract_id
    AND    chr.sts_code   = sts.code
    AND    chr.id = khr.id;

    -- This cursor is used by the Create Asset Return process to make
    -- sure that the contract has a logical post
    -- booking status.
   CURSOR  k_contractstatus_csr IS
   SELECT  khr.contract_number, sts.ste_code, sts.meaning
   FROM    okc_k_headers_b khr, okc_statuses_v sts
   WHERE   khr.sts_code = sts.code
   AND     khr.id = p_contract_id;

   -- Cursor to check if contract locked
   CURSOR  k_locks_csr IS
    SELECT 'x'
    FROM   OKC_K_PROCESSES v
    WHERE  v.chr_id        = p_contract_id
    AND    v.in_process_yn = 'Y';

   -- Cursor to get the service requests of contract
   CURSOR  k_service_request_csr IS
    SELECT 'x'
    FROM   OKX_INCIDENT_STATUSES_V xis,
           OKC_K_LINES_B           cle
    WHERE  cle.id          = xis.contract_service_id
     AND   cle.dnz_chr_id  = p_contract_id
     AND   xis.status_code IN ('OPEN');


   -- Cursor to get accepted quotes for contract
   CURSOR    k_accepted_quote_csr IS
     SELECT  'x'
     FROM    OKL_TRX_QUOTES_V
     WHERE   khr_id      =  p_contract_id
     AND     qst_code    =  'ACCEPTED'
     AND     (qtp_code LIKE 'TER%' OR qtp_code LIKE 'RES%');



    k_header_rec             k_header_csr%ROWTYPE;
    l_return_status          VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_chg_request_in_process VARCHAR2(1)  := '?';
    l_service_request        VARCHAR2(1)  := '?';
    l_quotes_exist           VARCHAR2(1)  := '?';
    l_tsu_code               VARCHAR2(30) := '?';
    l_sys_date               DATE;
    l_invalid_contract       EXCEPTION;
    l_ste_code               VARCHAR2(30);
    l_contract_number        VARCHAR2(120);
    l_meaning                VARCHAR2(90);
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'validate_contract';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


    -- RMUNJULU -- 11-DEC-02 Bug # 2484327 -- Added variables for checking
    -- related to asset level termination
    lx_trn_tbl  OKL_AM_UTIL_PVT.trn_tbl_type;
    i  NUMBER;

    -- RMUNJULU 18-DEC-02 2484327 -- Added variable for checking
    -- related to asset level termination
    lx_quote_tbl OKL_AM_UTIL_PVT.quote_tbl_type;



  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_id: '|| p_contract_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_control_flag: '|| p_control_flag);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    SELECT SYSDATE INTO l_sys_date FROM DUAL;

    OPEN  k_header_csr;
    FETCH k_header_csr INTO k_header_rec;
    CLOSE k_header_csr;

    OPEN  k_contractstatus_csr;
    FETCH k_contractstatus_csr INTO l_contract_number,l_ste_code, l_meaning;
    CLOSE k_contractstatus_csr;

    -- Check contract id passed is valid
    IF k_header_rec.id IS NULL OR k_header_rec.contract_number IS NULL THEN

      OKL_API.set_message( p_app_name     => OKC_API.G_APP_NAME,
                           p_msg_name     => OKC_API.G_INVALID_VALUE,
                           p_token1       => OKC_API.G_COL_NAME_TOKEN,
                           p_token1_value => 'contract id');

      RAISE l_invalid_contract;
    END IF;

    -- Check Lease or Loan
    IF NOT  (   (k_header_rec.scs_code = 'LOAN')          -- Loan
             OR (k_header_rec.scs_code = 'LEASE'
                 AND k_header_rec.deal_type LIKE 'LOAN%') -- Loan
             OR (k_header_rec.scs_code = 'LEASE'
                 AND k_header_rec.deal_type LIKE 'LEASE%')-- Lease
            ) THEN
      -- Contract CONTRACT_NUMBER is neither a Lease nor a Loan.
      OKL_API.set_message( p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_AM_K_TYPE_ERROR',
                          p_token1        => 'CONTRACT_NUMBER',
                          p_token1_value  => k_header_rec.contract_number);
      RAISE l_invalid_contract;
    END IF;


/* -- rmunjulu PERF
    OPEN  k_locks_csr;
    FETCH k_locks_csr INTO l_chg_request_in_process;
    CLOSE k_locks_csr;

    OPEN  k_service_request_csr;
    FETCH k_service_request_csr INTO l_service_request;
    CLOSE k_service_request_csr;

    OPEN  k_accepted_quote_csr;
    FETCH k_accepted_quote_csr INTO l_quotes_exist;
    CLOSE k_accepted_quote_csr;
*/


    --******************************
    -- CONTRACT_TERMINATE_SCRN
    --******************************

    -- If from contract termination screen
    IF (p_control_flag = 'CONTRACT_TERMINATE_SCRN') THEN

-- rmunjulu PERF -- start
    OPEN  k_locks_csr;
    FETCH k_locks_csr INTO l_chg_request_in_process;
    CLOSE k_locks_csr;

    OPEN  k_service_request_csr;
    FETCH k_service_request_csr INTO l_service_request;
    CLOSE k_service_request_csr;
-- rmunjulu PERF -- End

      -- Check if template
      IF k_header_rec.template_yn = OKL_API.G_TRUE THEN
        -- Message: This operation is not allowed on contract template-(NUMBER).
        OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                            p_msg_name      => 'OKC_K_TEMPLATE',
                            p_token1        => 'NUMBER',
                            p_token1_value  => k_header_rec.contract_number);
        RAISE l_invalid_contract;
      END IF;

      -- Check if locked
      IF l_chg_request_in_process = 'x' THEN
        -- Message: You cannot modify this contract now because a
        -- change request is active. Please try later.
        OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                            p_msg_name      => 'OKC_K_LOCKED');
        RAISE l_invalid_contract;
      END IF;

      -- Check if service requests found
      IF l_service_request = 'x' THEN
        -- Message: You cannot terminate this contract/line because a service
        --request is pending against this contract/line. Please try again later.
        OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                            p_msg_name      => 'OKC_SR_PENDING');
        RAISE l_invalid_contract;
      END IF;



      --  Check user status
      IF (k_header_rec.sts_code NOT IN ('BOOKED', 'EVERGREEN')) THEN
        -- Message: Contract (CONTRACT_NUMBER) is (STATUS).
        OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_CONTRACT_INACTIVE',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => k_header_rec.contract_number,
                            p_token2        => 'STATUS',
                            p_token2_value  => k_header_rec.meaning);
        RAISE l_invalid_contract;
      END IF;

      -- RMUNJULU 18-DEC-02 2484327 -- START --

      -- *****************
      -- IF unprocessed termination trn exists for the contract then error
      -- *****************


      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_contract_transactions');
      END IF;
      -- Get all the unprocessed transactions for the contract
      OKL_AM_UTIL_PVT.get_contract_transactions (
           p_khr_id        => k_header_rec.id,
           x_trn_tbl       => lx_trn_tbl,
           x_return_status => l_return_status);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.get_contract_transactions , return status: ' || l_return_status);
      END IF;


      -- Check the return status
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

         -- Error occured in util proc, message set by util proc raise exp
         RAISE l_invalid_contract;

      END IF;


      -- Check if termination transaction exists for the contract
      IF lx_trn_tbl.COUNT > 0 THEN

         -- A termination transaction for the contract CONTRACT_NUMBER
         -- is already in progress.
         OKL_API.set_message (
         			       p_app_name  	  => 'OKL',
              			 p_msg_name  	  => 'OKL_AM_K_PENDING_TRN_ERROR',
                     p_token1       => 'CONTRACT_NUMBER',
                     p_token1_value => k_header_rec.contract_number);

         RAISE l_invalid_contract;

      END IF;


      -- *****************
      -- IF NO accepted quote with no trn exists for contract then error
      -- *****************

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_non_trn_contract_quotes');
      END IF;
      -- Get accepted quote for contract with no trn
      OKL_AM_UTIL_PVT.get_non_trn_contract_quotes (
           p_khr_id        => k_header_rec.id,
           x_quote_tbl     => lx_quote_tbl,
           x_return_status => l_return_status);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.get_non_trn_contract_quotes , return status: ' || l_return_status);
      END IF;

      -- Check the return status
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

          -- Error occured in util proc, message set by util proc raise exp
          RAISE l_invalid_contract;

      END IF;

      -- Check if accepted quote exists for the contract or contract reached end
      -- RMUNJULU 02-JAN-03 2724951 Changed OR to AND in the IF
      IF lx_quote_tbl.COUNT = 0
      AND k_header_rec.end_date > l_sys_date THEN

          -- Cannot terminate contract CONTRACT_NUMBER since no
          -- accepted quotes exists nor contract has reached its end date.
          OKL_API.set_message (
         			 p_app_name  	  => G_APP_NAME,
         			 p_msg_name  	  => 'OKL_AM_QTE_EXIST_NOT_REACH_END',
               p_token1       => 'CONTRACT_NUMBER',
               p_token1_value => k_header_rec.contract_number);


          RAISE l_invalid_contract;

      END IF;

      -- RMUNJULU 18-DEC-02 2484327 -- END --

    --******************************
    -- TRMNT_QUOTE_CREATE
    --******************************

    -- If from create termination quote
    ELSIF (p_control_flag = 'TRMNT_QUOTE_CREATE') THEN

      --  Check user status
      IF k_header_rec.sts_code NOT IN ('BOOKED', 'EVERGREEN', 'BANKRUPTCY_HOLD',
                                     'LITIGATION_HOLD', 'TERMINATION_HOLD') THEN
        -- Message: Contract (CONTRACT_NUMBER) is (STATUS).
        OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_CONTRACT_INACTIVE',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => k_header_rec.contract_number,
                            p_token2        => 'STATUS',
                            p_token2_value  => k_header_rec.meaning);
        RAISE l_invalid_contract;
      END IF;


      -- RMUNJULU -- 11-DEC-02 Bug # 2484327 -- Added code to check based on
      -- asset level termination changes

      -- *****************
      -- IF unprocessed FULL termination trn exists for the contract then error
      -- *****************

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_contract_transactions');
      END IF;
      -- Get all the unprocessed transactions for the contract
      OKL_AM_UTIL_PVT.get_contract_transactions (
           p_khr_id        => k_header_rec.id,
           x_trn_tbl       => lx_trn_tbl,
           x_return_status => l_return_status);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.get_contract_transactions , return status: ' || l_return_status);
      END IF;

      -- Check the return status
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

         -- Error occured in util proc, message set by util proc raise exp
         RAISE l_invalid_contract;

      END IF;

      -- Check if termination transaction exists for the contract
      IF lx_trn_tbl.COUNT > 0 THEN

          -- Check if unprocessed FULL termination trn exists
          i := lx_trn_tbl.FIRST;

          LOOP

             --IF lx_trn_tbl(i).tcn_type = 'TMT' THEN -- FULL termination
               IF lx_trn_tbl(i).tcn_type in ('TMT', 'EVG') THEN -- akrangan bug 5354501 fix added 'EVG'
                -- A termination transaction for the contract CONTRACT_NUMBER
                -- is already in progress.
                OKL_API.set_message (
         			       p_app_name  	  => 'OKL',
              			 p_msg_name  	  => 'OKL_AM_K_PENDING_TRN_ERROR',
                     p_token1       => 'CONTRACT_NUMBER',
                     p_token1_value => k_header_rec.contract_number);

                RAISE l_invalid_contract;

             END IF;

             EXIT WHEN (i = lx_trn_tbl.LAST);
             i := lx_trn_tbl.NEXT(i);

          END LOOP;

      END IF;


    --******************************
    -- RESTR_QUOTE_CREATE
    --******************************

    -- If from create restructure quote
    ELSIF (p_control_flag = 'RESTR_QUOTE_CREATE') THEN

      --  Check user status
      IF k_header_rec.sts_code NOT IN ( 'BOOKED', 'BANKRUPTCY_HOLD',
                                        'LITIGATION_HOLD') THEN
        -- Message: Contract (CONTRACT_NUMBER) is (STATUS).
        OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_CONTRACT_INACTIVE',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => k_header_rec.contract_number,
                            p_token2        => 'STATUS',
                            p_token2_value  => k_header_rec.meaning);
        RAISE l_invalid_contract;
      END IF;

    --******************************
    -- REPUR_QUOTE_CREATE
    --******************************

    -- If from create repurchase quote
    ELSIF (p_control_flag = 'REPUR_QUOTE_CREATE') THEN

      --  Check user status
      IF k_header_rec.sts_code NOT IN ( 'TERMINATED','EXPIRED') THEN
        -- Message: Contract CONTRACT_NUMBER is still STATUS.
        -- Unable to generate the quote until the contract
        -- has been terminated or expired.
        OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_CONTRACT_STILL_ACTIVE',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => k_header_rec.contract_number,
                            p_token2        => 'STATUS',
                            p_token2_value  => k_header_rec.meaning);
        RAISE l_invalid_contract;
      END IF;

    --******************************
    -- TRMNT_QUOTE_UPDATE
    --******************************

    -- If from update termination quote
    ELSIF (p_control_flag = 'TRMNT_QUOTE_UPDATE') THEN

      --  Check user status
      IF k_header_rec.sts_code NOT IN ('BOOKED', 'EVERGREEN', 'BANKRUPTCY_HOLD',
                                     'LITIGATION_HOLD', 'TERMINATION_HOLD') THEN
        -- Message: Contract (CONTRACT_NUMBER) is (STATUS).
        OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_CONTRACT_INACTIVE',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => k_header_rec.contract_number,
                            p_token2        => 'STATUS',
                            p_token2_value  => k_header_rec.meaning);
        RAISE l_invalid_contract;
      END IF;

    --******************************
    -- RESTR_QUOTE_UPDATE
    --******************************

    -- If from update restructure quote
    ELSIF (p_control_flag = 'RESTR_QUOTE_UPDATE') THEN

      --  Check user status
      IF k_header_rec.sts_code NOT IN ( 'BOOKED',
                                        'BANKRUPTCY_HOLD',
                                        'LITIGATION_HOLD') THEN
        -- Message: Contract (CONTRACT_NUMBER) is (STATUS).
        OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_CONTRACT_INACTIVE',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => k_header_rec.contract_number,
                            p_token2        => 'STATUS',
                            p_token2_value  => k_header_rec.meaning);
        RAISE l_invalid_contract;
      END IF;

    --******************************
    -- REPUR_QUOTE_UPDATE
    --******************************

    -- If from update repurchase quote
    ELSIF (p_control_flag = 'REPUR_QUOTE_UPDATE') THEN

      --  Check user status
      IF k_header_rec.sts_code NOT IN ( 'TERMINATED','EXPIRED') THEN
        -- Message: Contract CONTRACT_NUMBER is still STATUS.
        -- Unable to generate the quote until the contract
        -- has been terminated or expired.
        OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_CONTRACT_STILL_ACTIVE',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => k_header_rec.contract_number,
                            p_token2        => 'STATUS',
                            p_token2_value  => k_header_rec.meaning);
        RAISE l_invalid_contract;
      END IF;

    --******************************
    -- BATCH_PROCESS
    --******************************

    -- If from batch process
    ELSIF (p_control_flag = 'BATCH_PROCESS') THEN

      -- Check if template
      IF k_header_rec.template_yn = OKL_API.G_TRUE THEN
        -- Message: This operation is not allowed on contract template-(NUMBER).
        OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                            p_msg_name      => 'OKC_K_TEMPLATE',
                            p_token1        => 'NUMBER',
                            p_token1_value  => k_header_rec.contract_number);
        RAISE l_invalid_contract;
      END IF;

/*-- rmunjulu PERF -- Not required
      -- Check if locked
      IF l_chg_request_in_process = 'x' THEN
        -- Message: You cannot modify this contract now because a
        -- change request is active. Please try later.
        OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                            p_msg_name      => 'OKC_K_LOCKED');
        RAISE l_invalid_contract;
      END IF;

      --Check if service requests found
      IF l_service_request = 'x' THEN
        -- Message: You cannot terminate this contract/line because a service
        --request is pending against this contract/line. Please try again later.
        OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                            p_msg_name      => 'OKC_SR_PENDING');
        RAISE l_invalid_contract;
      END IF;
*/


    --******************************
    -- BATCH_PROCESS_CHR
    --******************************

    -- If from batch process for single contract request
    ELSIF (p_control_flag = 'BATCH_PROCESS_CHR') THEN

      -- Check if template
      IF k_header_rec.template_yn = OKL_API.G_TRUE THEN
        -- Message: This operation is not allowed on contract template-(NUMBER).
        OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                            p_msg_name      => 'OKC_K_TEMPLATE',
                            p_token1        => 'NUMBER',
                            p_token1_value  => k_header_rec.contract_number);
        RAISE l_invalid_contract;
      END IF;

/*-- rmunjulu PERF -- Not required
      -- Check if locked
      IF l_chg_request_in_process = 'x' THEN
        -- Message: You cannot modify this contract now because a
        -- change request is active. Please try later.
        OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                            p_msg_name      => 'OKC_K_LOCKED');
        RAISE l_invalid_contract;
      END IF;

      --Check if service requests found
      IF l_service_request = 'x' THEN
        -- Message: You cannot terminate this contract/line because a service
        --request is pending against this contract/line. Please try again later.
        OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                            p_msg_name      => 'OKC_SR_PENDING');
        RAISE l_invalid_contract;
      END IF;
*/

/*
      --  Check user status
      IF k_header_rec.sts_code <> 'BOOKED' THEN
        -- Message: Contract (CONTRACT_NUMBER) is (STATUS).
        OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_CONTRACT_INACTIVE',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => k_header_rec.contract_number,
                            p_token2        => 'STATUS',
                            p_token2_value  => k_header_rec.meaning);
        RAISE l_invalid_contract;
      END IF;
*/

-- rmunjulu PERF -- Moved cursor open here
    OPEN  k_accepted_quote_csr;
    FETCH k_accepted_quote_csr INTO l_quotes_exist;
    CLOSE k_accepted_quote_csr;

      --   Check if accepted quote exists
      IF (l_quotes_exist = 'x')  THEN
        -- Message: Cannot terminate contract (CONTRACT_NUMBER) since
        -- accepted quote exists.
        OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_QUOTES_EXIST',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => k_header_rec.contract_number);
        RAISE l_invalid_contract;
      END IF;

    --******************************
    -- ASSET_RETURN_CREATE
    --******************************

    -- If from create asset return
    ELSIF (p_control_flag = 'ASSET_RETURN_CREATE') THEN

      --  Check contract status
      IF l_ste_code IS NOT NULL AND l_ste_code IN ('ENTERED','SIGNED','CANCELLED') THEN
        -- Message: Contract CONTRACT_NUMBER has invalid post-booking status - STATUS.
        -- Unable to create asset return for this contract.

        OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_K_INVALID_STATUS',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => l_contract_number,
                            p_token2        => 'STATUS',
                            p_token2_value  => l_meaning);
        RAISE l_invalid_contract;
      END IF;

    --******************************
    -- ASSET_RETURN_UPDATE
    --******************************

    -- If from update asset return
    ELSIF (p_control_flag = 'ASSET_RETURN_UPDATE') THEN

      --  Check user status
      IF k_header_rec.sts_code NOT IN ( 'TERMINATED','EXPIRED') THEN
        --Message: Contract CONTRACT_NUMBER is still STATUS.
        -- Unable to return assets for this contract.
        OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_K_INVALID_FOR_ART_ERR',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => k_header_rec.contract_number,
                            p_token2        => 'STATUS',
                            p_token2_value  => k_header_rec.meaning);
        RAISE l_invalid_contract;
      END IF;

    --******************************
    -- Default checking (Control flag is null)
    --******************************

    ELSE -- Default checking (Control flag is null)

      --  Check user status
      IF k_header_rec.sts_code <> 'BOOKED' THEN
        -- Message: Contract (CONTRACT_NUMBER) is (STATUS).
        OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_AM_CONTRACT_INACTIVE',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => k_header_rec.contract_number,
                            p_token2        => 'STATUS',
                            p_token2_value  => k_header_rec.meaning);
        RAISE l_invalid_contract;
      END IF;
    END IF;

    -- Set the current contract status
    x_contract_status := k_header_rec.sts_code;

    -- Set the return status
    x_return_status   :=  l_return_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
    END IF;
  EXCEPTION
    WHEN l_invalid_contract THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'l_invalid_contract');
      END IF;
      IF k_header_csr%ISOPEN THEN
         CLOSE k_header_csr;
      END IF;
      IF k_contractstatus_csr%ISOPEN THEN
         CLOSE k_contractstatus_csr;
      END IF;
      IF k_locks_csr%ISOPEN THEN
         CLOSE k_locks_csr;
      END IF;
      IF k_service_request_csr%ISOPEN THEN
         CLOSE k_service_request_csr;
      END IF;
      IF k_accepted_quote_csr%ISOPEN THEN
         CLOSE k_accepted_quote_csr;
      END IF;


   	  -- notify caller of EXPECTED error
	    x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      IF k_header_csr%ISOPEN THEN
         CLOSE k_header_csr;
      END IF;
      IF k_contractstatus_csr%ISOPEN THEN
         CLOSE k_contractstatus_csr;
      END IF;
      IF k_locks_csr%ISOPEN THEN
         CLOSE k_locks_csr;
      END IF;
      IF k_service_request_csr%ISOPEN THEN
         CLOSE k_service_request_csr;
      END IF;
      IF k_accepted_quote_csr%ISOPEN THEN
         CLOSE k_accepted_quote_csr;
      END IF;

      -- store SQL error message on message stack for caller
  	  OKL_API.SET_MESSAGE (
			 p_app_name	        => OKC_API.G_APP_NAME
			,p_msg_name	        => G_UNEXPECTED_ERROR
			,p_token1	          => G_SQLCODE_TOKEN
			,p_token1_value	    => sqlcode
			,p_token2	          => G_SQLERRM_TOKEN
			,p_token2_value	    => sqlerrm);

   	  -- notify caller of an UNEXPECTED error
	    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   END validate_contract;


  -- Start of comments
  --
  -- Procedure Name	: check_lease_loan_type
  -- Desciption     : Checks if contract is lease or loan
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
  --
  -- End of comments
  PROCEDURE check_lease_loan_type(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           x_lease_loan_type             OUT NOCOPY VARCHAR2)  IS

   -- Get the K details
   CURSOR k_header_csr is
   SELECT  id,
           object_version_number,
		   sts_code,
           scs_code
    FROM   OKC_K_HEADERS_B
    WHERE  id = p_term_rec.p_contract_id;

   -- Get the K deal_type
   -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
   CURSOR k_deal_type_csr is
   SELECT  deal_type
    FROM   OKL_K_HEADERS_V
    WHERE  id = p_term_rec.p_contract_id;

    k_header_rec         k_header_csr%ROWTYPE;
    l_lease_loan_type    VARCHAR2(30) := '$';
    l_api_name           VARCHAR2(30) := 'check_lease_loan_type';
    l_deal_type          VARCHAR2(30) := '$';
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_lease_loan_type';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_id: '|| p_term_rec.p_contract_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_number: '|| p_term_rec.p_contract_number);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_modifier: '|| p_term_rec.p_contract_modifier);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
    END IF;
    x_return_status   := OKL_API.G_RET_STS_SUCCESS;
    x_lease_loan_type := l_lease_loan_type;

    OPEN k_header_csr;
    FETCH k_header_csr INTO k_header_rec;
    IF k_header_csr%NOTFOUND THEN
      OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                          p_msg_name      => 'OKC_K_CHANGED',
                          p_token1        => 'NUMBER',
                          p_token1_value  =>  p_term_rec.p_contract_number,
                          p_token2        => 'MODIFIER',
                          p_token2_value  =>  p_term_rec.p_contract_modifier);
      CLOSE k_header_csr;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN k_deal_type_csr;
    FETCH k_deal_type_csr INTO l_deal_type;
    CLOSE k_deal_type_csr;

    -- Set the lease or loan type
    -- (If scs_code = Lease and deal_type = Loan then Loan)
    IF k_header_rec.scs_code = 'LEASE'
    AND NVL(l_deal_type,'?') LIKE 'LOAN%' THEN
      l_lease_loan_type := 'LOAN';
    ELSIF k_header_rec.scs_code = 'LEASE'
    AND NVL(l_deal_type,'?') LIKE 'LEASE%' THEN
      l_lease_loan_type := 'LEASE';
    ELSIF k_header_rec.scs_code = 'LOAN' THEN
      l_lease_loan_type := 'LOAN';
    END IF;
    CLOSE k_header_csr;

    x_lease_loan_type := l_lease_loan_type;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;
      IF k_header_csr%ISOPEN THEN
        CLOSE k_header_csr;
      END IF;
      IF k_deal_type_csr%ISOPEN THEN
        CLOSE k_deal_type_csr;
      END IF;
      x_lease_loan_type := '$';
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;
      IF k_header_csr%ISOPEN THEN
        CLOSE k_header_csr;
      END IF;
      IF k_deal_type_csr%ISOPEN THEN
        CLOSE k_deal_type_csr;
      END IF;
      x_lease_loan_type := '$';
      x_return_status :=OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      IF k_header_csr%ISOPEN THEN
        CLOSE k_header_csr;
      END IF;
      IF k_deal_type_csr%ISOPEN THEN
        CLOSE k_deal_type_csr;
      END IF;
      x_lease_loan_type := '$';
      OKL_API.set_message(p_app_name      => okc_api.g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END check_lease_loan_type;

  ----------------------------------------------------------------------------
  -- PROCEDURE : process_non_batch
  ----------------------------------------------------------------------------
  PROCEDURE process_non_batch(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           x_tcnv_rec                    OUT NOCOPY tcnv_rec_type,
           x_can_terminate               OUT NOCOPY VARCHAR2) IS

      l_quote_found         VARCHAR2(1) := 'N';
      l_trn_exists          VARCHAR2(1) := 'N';
      l_can_terminate       VARCHAR2(1) := 'Y';
      lp_tcnv_rec           tcnv_rec_type;
      lx_tcnv_rec           tcnv_rec_type;
      lx_contract_status      VARCHAR2(200);
      l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_non_batch';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
      is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
      is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_id: '|| p_term_rec.p_contract_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_number: '|| p_term_rec.p_contract_number);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_modifier: '|| p_term_rec.p_contract_modifier);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_control_flag: '|| p_term_rec.p_control_flag);
     END IF;

     -- Validate the contract
     validate_contract(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   p_init_msg_list,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_contract_id                 =>   p_term_rec.p_contract_id,
           p_control_flag                =>   p_term_rec.p_control_flag,
           x_contract_status             =>   lx_contract_status);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called validate_contract , return status: ' || l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'lx_contract_status : ' || lx_contract_status);
      END IF;

     -- If error abort this contract
     IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       RAISE G_EXCEPTION_HALT;
     END IF;

     -- get transaction if exists
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_BTCH_EXP_LEASE_LOAN_PVT.get_trn_rec');
     END IF;
     OKL_AM_BTCH_EXP_LEASE_LOAN_PVT.get_trn_rec(
           p_contract_id                => p_term_rec.p_contract_id,
           x_return_status              => l_return_status,
           x_trn_exists                 => l_trn_exists,
           x_tcnv_rec                   => lp_tcnv_rec);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_BTCH_EXP_LEASE_LOAN_PVT.get_trn_rec , return status: ' || l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_trn_exists : ' || l_trn_exists);
      END IF;

     -- if error then abort this contract
     IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       RAISE G_EXCEPTION_HALT;
     END IF;

     -- If trn exists then set the out tcnv_rec
     -- (have to do this or else tcnv_rec set wrong)
     IF (l_trn_exists = 'Y' ) THEN
        lx_tcnv_rec  :=    lp_tcnv_rec;
        x_tcnv_rec   :=    lx_tcnv_rec;
     END IF;

    x_return_status       :=   l_return_status;
    x_can_terminate       :=   l_can_terminate;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
    END IF;
  EXCEPTION

    WHEN G_EXCEPTION_HALT THEN
        IF (is_debug_exception_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_HALT');
        END IF;
        x_return_status       :=   OKL_API.G_RET_STS_ERROR;
        x_can_terminate       :=   'N';

    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        x_return_status       :=   OKL_API.G_RET_STS_ERROR;
        x_can_terminate       :=   'N';
  END process_non_batch;





  -- Start of comments
  --
  -- Procedure Name	: lease_loan_termination
  -- Desciption     : method to terminate the lease or loan
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  -- History        : RMUNJULU -- 26-NOV-02: Bug # 2484327 : Added call to
  --                  OKL_AM_CNTRCT_LN_TRMNT_PVT if partial quote, Changed
  --                  l_accepted_qte_csr cursor.
  --                  RMUNJULU 18-DEC-02 2484327 Changed IF to get qte_id properly
  --                : RMUNJULU 02-JAN-03 2699412 Set the okc context
  --
  -- End of comments
  PROCEDURE lease_loan_termination(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_tcnv_rec                    IN  tcnv_rec_type) IS


   -- Get the accepted quote if exists for the contract
   -- RMUNJULU Bug # 2484327 : Added partial_yn to cursor to get the value
   -- of the quote whether partial yn
   -- RMUNJULU 18-DEC-02 2484327 commented --


   -- RMUNJULU 18-DEC-02 2484327 added cursor
   -- Get the quote details
   CURSOR l_qte_csr ( p_qte_id IN NUMBER) IS
     SELECT QTE.id,
            QTE.partial_yn
     FROM   OKL_TRX_QUOTES_V QTE
     WHERE  QTE.id = p_qte_id;


   l_return_status         VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
   l_api_name              CONSTANT VARCHAR2(30) := 'lease_loan_termination';
   l_lease_or_loan         VARCHAR2(200);
   l_tcnv_rec              tcnv_rec_type := p_tcnv_rec;
   l_trn_exists            VARCHAR2(1) := 'N';
   l_can_terminate         VARCHAR2(1) := 'Y';
   lp_term_rec             term_rec_type := p_term_rec;
   --l_accepted_qte_rec      l_accepted_qte_csr%ROWTYPE;
   l_module_name VARCHAR2(500) := G_MODULE_NAME || 'lease_loan_termination';
   is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
   is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
   is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

   -- RMUNJULU Bug # 2484327 : To get the value of the quote whether partial yn
   l_partial_yn            VARCHAR2(1) := 'N';

   -- RMUNJULU 18-DEC-02 2484327
   l_qte_rec l_qte_csr%ROWTYPE;
   lx_quote_tbl OKL_AM_UTIL_PVT.quote_tbl_type;

   -- RMUNJULU 3061751 27-AUG-2003
   l_service_integration_needed   VARCHAR2(3) := 'N';

  BEGIN
   IF (is_debug_procedure_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_id: '|| p_term_rec.p_contract_id);
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_number: '|| p_term_rec.p_contract_number);
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_modifier: '|| p_term_rec.p_contract_modifier);
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_control_flag: '|| p_term_rec.p_control_flag);
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_recycle_yn: '||p_tcnv_rec.tmt_recycle_yn);
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.qte_id: '||p_tcnv_rec.qte_id);
   END IF;

   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   -- if not batch process then check if can be terminated
   IF NVL(lp_term_rec.p_control_flag,'?') NOT IN ('BATCH_PROCESS','BATCH_PROCESS_CHR') THEN


     process_non_batch(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   p_init_msg_list,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_term_rec                    =>   lp_term_rec,
           x_tcnv_rec                    =>   l_tcnv_rec,
           x_can_terminate               =>   l_can_terminate);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called process_non_batch , return status: ' || l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_can_terminate : ' || l_can_terminate);
      END IF;


     -- If error abort this contract
     IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     IF (l_can_terminate <> 'Y') THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

   END IF;



   -- check if lease/loan exists and type
   check_lease_loan_type(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   p_init_msg_list,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_term_rec                    =>   lp_term_rec,
           x_lease_loan_type             =>   l_lease_or_loan);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called check_lease_loan_type , return status: ' || l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_lease_or_loan : ' || l_lease_or_loan);
      END IF;



   -- If error abort this contract
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;



   -- Set the quote parameter if accepted quote exists and not already populated
   -- RMUNJULU Bug # 2484327 : cannot have the below if since if quote id
   -- passed then will not set partial_yn



   -- RMUNJULU 18-DEC-02 2484327 -- START --
   -- Changed the if logic to get the correct qte_id

   -- NOTE: If this IF does not return any quote then the partial_yn is not set to 'Y'
   -- and it is a full termination

   -- Check if quote id passed to p_term_rec get partial_yn if yes
   IF  lp_term_rec.p_quote_id IS NOT NULL
   AND lp_term_rec.p_quote_id <> OKL_API.G_MISS_NUM THEN


     -- This condition is from termination quotes
     OPEN  l_qte_csr ( lp_term_rec.p_quote_id);
     FETCH l_qte_csr INTO l_qte_rec;
     IF l_qte_csr%FOUND THEN
       l_partial_yn := l_qte_rec.partial_yn;
     END IF;
     CLOSE l_qte_csr;


   -- else check if quote id passed to p_tcnv_rec get partial_yn if yes
   ELSIF  l_tcnv_rec.qte_id IS NOT NULL
   AND l_tcnv_rec.qte_id <> OKL_API.G_MISS_NUM THEN

     -- This condition is from batch recycled trns which originated from qte
     OPEN  l_qte_csr ( l_tcnv_rec.qte_id);
     FETCH l_qte_csr INTO l_qte_rec;
     IF l_qte_csr%FOUND THEN
       l_partial_yn := l_qte_rec.partial_yn;
       lp_term_rec.p_quote_id := l_tcnv_rec.qte_id;
     END IF;
     CLOSE l_qte_csr;


   -- else get the accepted quote for contract and get partial_yn
   ELSE

     -- This condition is from contract term. scrn when quote exists with no trn

     -- *****************
     -- Get accepted quote with no trn if exists for contract
     -- *****************

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_non_trn_contract_quotes');
     END IF;
     -- Get accepted quote for contract with no trn
     OKL_AM_UTIL_PVT.get_non_trn_contract_quotes (
           p_khr_id        => lp_term_rec.p_contract_id,
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

     -- Check if accepted quote with no trn exists for the contract
     IF lx_quote_tbl.COUNT > 0 THEN

        lp_term_rec.p_quote_id := lx_quote_tbl(lx_quote_tbl.FIRST).id;
        l_partial_yn := lx_quote_tbl(lx_quote_tbl.FIRST).partial_yn;

     END IF;

   END IF;

   -- RMUNJULU 18-DEC-02 2484327 -- END --


   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'setting okc org context');
   END IF;
   -- RMUNJULU 02-JAN-03 2699412 Set the okc context
   OKL_CONTEXT.set_okc_org_context(p_chr_id => lp_term_rec.p_contract_id);

  -- ++++++++++++++++++++  service contract integration begin ++++++++++++++++++

   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling check_service_k_int_needed');
   END IF;
   -- RMUNJULU 3061751 27-AUG-2003
   -- Checks and sets service_integration_needed flag
   -- Need to do this before lines terminated else will not know
   -- if TRUE FULL termination or not (FULL Termination or PARTIAL Termination
   -- but no more assets)
   l_service_integration_needed := check_service_k_int_needed(
                                       p_term_rec     => lp_term_rec,
                                       p_tcnv_rec     => l_tcnv_rec,
                                       p_partial_yn   => l_partial_yn,
                                       p_source       => 'TERMINATION');
   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called check_service_k_int_needed');
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_service_integration_needed : ' || l_service_integration_needed);
   END IF;

  -- +++++++++++++++++++++ service contract integration end   ++++++++++++++++++


   -- RMUNJULU Bug # 2484327 -- Will first check if partial termination and call
   -- OKL_AM_CONTRACT_LINE_TRMNT_PVT API or else check for lease or loan and
   -- call appropriate API.

   -- rmunjulu Added condition to check if truely partial
   IF (l_partial_yn = 'Y') THEN

      -- need to check if no more assets (This case p_quote_id is Always populated)
      l_partial_yn := check_true_partial_quote_yn( -- rmunjulu 4997075
                                 p_quote_id     => lp_term_rec.p_quote_id,
                                 p_contract_id  => lp_term_rec.p_contract_id);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called check_true_partial_quote_yn');
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_partial_yn : ' || l_partial_yn);
      END IF;
   END IF;

   -- Call the lease/loan termination api
   IF (l_partial_yn = 'Y') THEN

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_CNTRCT_LN_TRMNT_PVT.asset_level_termination');
     END IF;

     OKL_AM_CNTRCT_LN_TRMNT_PVT.asset_level_termination(
           p_api_version       =>   p_api_version,
           p_init_msg_list     =>   p_init_msg_list,
           p_term_rec          =>   lp_term_rec,
           p_tcnv_rec          =>   l_tcnv_rec,
           x_msg_count         =>   x_msg_count,
           x_msg_data          =>   x_msg_data,
           x_return_status     =>   l_return_status);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_CNTRCT_LN_TRMNT_PVT.asset_level_termination , return status: ' || l_return_status);
     END IF;

     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

   ELSIF (l_lease_or_loan = 'LEASE') THEN

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.lease_termination');
     END IF;
     OKL_AM_LEASE_TRMNT_PVT.lease_termination(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   p_init_msg_list,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_term_rec                    =>   lp_term_rec,
           p_tcnv_rec                    =>   l_tcnv_rec);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.lease_termination , return status: ' || l_return_status);
     END IF;

     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

   ELSIF (l_lease_or_loan = 'LOAN') THEN

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LOAN_TRMNT_PVT.loan_termination');
     END IF;
     OKL_AM_LOAN_TRMNT_PVT.loan_termination(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   p_init_msg_list,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_term_rec                    =>   lp_term_rec,
           p_tcnv_rec                    =>   l_tcnv_rec);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LOAN_TRMNT_PVT.loan_termination , return status: ' || l_return_status);
     END IF;

     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

   ELSIF (l_lease_or_loan = '$') THEN

     -- type not found
     -- set message and raise exception
     -- Contract type, whether Lease or Loan could not be
     -- determined for Contract CONTRACT_NUMBER.
     OKL_API.set_message(p_app_name       => G_APP_NAME,
                          p_msg_name      => 'OKL_AM_K_TYPE_NOT_FOUND',
                          p_token1        => 'CONTRACT_NUMBER',
                          p_token1_value  => lp_term_rec.p_contract_number);

     RAISE OKL_API.G_EXCEPTION_ERROR;

   ELSE

     -- neither lease or loan
     -- set message and raise exception
     -- Contract CONTRACT_NUMBER is neither a Lease nor a Loan.
     OKL_API.set_message( p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_AM_K_TYPE_ERROR',
                          p_token1        => 'CONTRACT_NUMBER',
                          p_token1_value  => lp_term_rec.p_contract_number);

     RAISE OKL_API.G_EXCEPTION_ERROR;

   END IF;


  -- ++++++++++++++++++++  service contract integration begin ++++++++++++++++++

   -- RMUNJULU 3061751 27-AUG-2003 Do the Service_Integration Steps, Launches SERVICE INT WF if needed
   service_k_integration(
               p_term_rec                   => lp_term_rec,
               p_source                     => 'TERMINATION',
               p_service_integration_needed => l_service_integration_needed);
   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called service_k_integration');
   END IF;

  -- +++++++++++++++++++++ service contract integration end   ++++++++++++++++++

   x_return_status := l_return_status;
   IF (is_debug_procedure_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
   END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;

      -- RMUNJULU 18-DEC-02 2484327
      IF l_qte_csr%ISOPEN THEN
        CLOSE l_qte_csr;
      END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      -- RMUNJULU 18-DEC-02 2484327
      IF l_qte_csr%ISOPEN THEN
        CLOSE l_qte_csr;
      END IF;


      x_return_status :=OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

      -- RMUNJULU 18-DEC-02 2484327
      IF l_qte_csr%ISOPEN THEN
        CLOSE l_qte_csr;
      END IF;


      OKL_API.set_message(p_app_name      => okc_api.g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END lease_loan_termination;

  ----------------------------------------------------------------------------
  -- PROCEDURE : lease_loan_termination
  -- method to terminate multiple leases and loans
  -- Call this method from the Contract Termination Screen
  ----------------------------------------------------------------------------
  PROCEDURE lease_loan_termination(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_tbl                    IN  term_tbl_type,
           p_tcnv_tbl                    IN  tcnv_tbl_type) IS

    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                        NUMBER := 0;
    l_overall_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_version            CONSTANT NUMBER := 1;
    l_api_name               CONSTANT VARCHAR2(30) := 'lease_loan_termination';
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'lease_loan_termination';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
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

    --OKL_API.init_msg_list(p_init_msg_list);
    -- Initialize return_status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Initialize p_init_msg_list to True so that every time the message stack
    -- is set or else the messages for the successfull terminated contracts
    -- will come here which is not desired
    -- This method is called from Contract Termination screen
    -- The screen will rollback if even one of the contracts failed to terminate
    -- Skip out of the loop as soon as the first contract is failed
    IF (p_term_tbl.COUNT > 0) THEN
      i := p_term_tbl.FIRST;
      LOOP
        lease_loan_termination (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_TRUE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_term_rec                     => p_term_tbl(i),
          p_tcnv_rec                     => p_tcnv_tbl(i));
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called lease_loan_termination , return status: ' || l_return_status);
      END IF;

        -- rollback if terminating contract failed
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        EXIT WHEN (i = p_term_tbl.LAST);
        i := p_term_tbl.NEXT(i);
      END LOOP;

    END IF;


    x_return_status := l_return_status;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
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
  END lease_loan_termination;

    -- Start of comments
    --
    -- Procedure Name : get_set_quote_dates
    -- Desciption     : gets the quote eff dates and sets global variables with those
    -- Business Rules :
    -- Parameters	  :
    -- Version		  : 1.0
    -- History        : RMUNJULU EDAT created
    --
    -- End of comments
   PROCEDURE get_set_quote_dates(
          p_qte_id              IN NUMBER,
          p_trn_date            IN DATE DEFAULT NULL,
          x_return_status       OUT NOCOPY VARCHAR2) IS

      -- get the quote dates
      CURSOR quote_dates_csr (p_quote_id IN NUMBER) IS
      SELECT trunc(qte.date_effective_from),
             trunc(qte.date_accepted)
      FROM   okl_trx_quotes_b qte
      WHERE  qte.id = p_quote_id;

      l_eff_from DATE;
      l_accpt DATE;

      l_trn_date DATE;
      l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_set_quote_dates';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
      is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
      is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

   BEGIN
      IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
      END IF;
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qte_id: '|| p_qte_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_trn_date: '|| p_trn_date);
      END IF;

      x_return_status := OKL_API.g_ret_sts_success;

      SELECT SYSDATE INTO l_trn_date FROM DUAL;

      -- if quote_id exists then
      IF  p_qte_id IS NOT NULL
      AND p_qte_id <> OKL_API.G_MISS_NUM THEN

         -- get quote dates
         OPEN  quote_dates_csr (p_qte_id);
         FETCH quote_dates_csr INTO l_eff_from, l_accpt;
         CLOSE quote_dates_csr;

         -- set global variables
         g_quote_eff_from_date := l_eff_from;
         g_quote_accept_date   := l_accpt;
         g_quote_exists        := 'Y';

      ELSE -- quote does not exist

         g_quote_exists        := 'N';

         IF p_trn_date IS NOT NULL THEN
            g_transaction_date    := p_trn_date;
         ELSE
            g_transaction_date    := l_trn_date;
         END IF;

      END IF;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
     END IF;

   EXCEPTION

      WHEN OTHERS THEN
         IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                || sqlcode || ' , SQLERRM : ' || sqlerrm);
         END IF;

         x_return_status := OKL_API.g_ret_sts_error;

         -- Set the oracle error message
         OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

   END  get_set_quote_dates;

  -- Start of comments
  --
  -- Procedure Name	: process_discount_subsidy
  -- Desciption     : method to handle subsidy and discount refund
  -- Business Rules	:
  -- Parameters	    :
  -- Version	    : 1.0
  -- History        : RMUNJULU 26-NOV-03 2484327 Added code to get accrual_stream_type_id and pass to accrual_api
  --                  Added Code to pass set_of_books_id to create AP invoice
  --                : RMUNJULU 08-DEC-03 3280473 Changed code to get the subsidy subline amount
  --                  used for refund, instead of subsidy amount for the whole financial
  --                  line
  --                : rmunjulu EDAT Added code to get the quote eff date and quote accpt date
  --                  and set the dates accordingly
  --                : rmunjulu EDAT Changed code to set quote_eff dates using termination date if no quote
  --                : rmunjulu 4399352 changed to get subsidy income accrual sty id from stream generation template
  --                :sosharma build R12 replaced the procedure calls to create AP header,lines and accounting with
  --                 a single call to disbursement API OKL_CREATE_DISB_TRANS_PVT.create_disb_trx
  -- End of comments
  PROCEDURE process_discount_subsidy(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_call_origin                 IN  VARCHAR2 DEFAULT NULL,
           p_termination_date            IN DATE) IS

            p_asset_tbl_k   OKL_AM_LEASE_TRMNT_PVT.klev_tbl_type;
            l_asset_tbl_l   OKL_AM_CNTRCT_LN_TRMNT_PVT.klev_tbl_type;
            l_asset_tbl     OKL_AM_LEASE_TRMNT_PVT.klev_tbl_type;
            l_asbv_tbl    okl_subsidy_process_pvt.asbv_tbl_type;
            l_sty_id      NUMBER;
            l_parent_line_id      NUMBER;
            l_date_accepted       DATE;
            l_subsidy_end_date    DATE;
            l_contract_end_date   DATE;
            l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_discount_subsidy';
            is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
            is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
            is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
            /* sosharma 12-jan-2007
             Build: R12
             declared table of type okl_tpl_pvt.tplv_tbl_type to be passed as an input to the
             OKL_CREATE_DISB_TRANS_PVT. create_disb_trx
             Start changes
             */
             l_tplv_tbl   okl_tpl_pvt.tplv_tbl_type;
             x_tplv_tbl   okl_tpl_pvt.tplv_tbl_type;
             /*
             sosharma End changes
             */
            l_sub_sty_id         NUMBER;    -- SMODUGA for subsidy stream type id
             --**SMODUGA added for ap_invoice lines
            l_currency_conversion_type  okl_k_headers.currency_conversion_type%TYPE;
            l_currency_conversion_date okl_k_headers.currency_conversion_date%TYPE;
            l_currency_conversion_rate okl_k_headers.currency_conversion_rate%TYPE;
             --**SMODUGA added for ap_invoice lines
            l_quote_number        NUMBER;
            l_api_name CONSTANT VARCHAR2(30) := 'process_discount_subsidy';
            l_api_version         CONSTANT NUMBER := 1;
            l_acceleration_rec   OKL_GENERATE_ACCRUALS_PVT.acceleration_rec_type;
            l_tapv_rec           okl_tap_pvt.tapv_rec_type ;
            x_tapv_rec           okl_tap_pvt.tapv_rec_type ;
            --**SMODUGA added for ap_invoice lines
            l_tplv_rec              okl_tpl_pvt.tplv_rec_type;
            x_tplv_rec             okl_tpl_pvt.tplv_rec_type;
            -- ** END SMODUGA added for ap_invoice lines
            lx_subsidy_amount   NUMBER;
            l_app_id            NUMBER;
            l_trx_type_ID       NUMBER;
            l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
            lx_dbseqnm          VARCHAR2(2000):= '';
            lx_dbseqid          NUMBER(38):= NULL;
            l_formula_name      VARCHAR2(150);
            l_return_status      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
            l_msg_count NUMBER := OKL_API.G_MISS_NUM;
            l_msg_data VARCHAR2(2000);

        --akrangan for Bug 5669097 Fix Start
        v_flag              varchar2(1) :='N';
        indx                 number :=1;
        TYPE l_acceleration_tbl_type IS TABLE OF
	OKL_GENERATE_ACCRUALS_PVT.acceleration_rec_type
	INDEX BY BINARY_INTEGER;
        l_acceleration_tbl l_acceleration_tbl_type;
        --akrangan for Bug 5669097 Fix End
    -- Get all active subsidies for this contract
    -- RMUNJULU *** Added code to get accrual_stream_type_id
    -- SMODUGA *** Added code to get subsidy_line_id
    CURSOR c_active_subsidies(c_parent_line_id NUMBER,c_contract_id NUMBER)IS
    select KLE1.amount,sub.stream_type_id, sub.refund_formula_id,
           sub.subsidy_calc_basis, sub.recourse_yn,
           sub.termination_refund_basis, sub.receipt_method_code,
           sub.accounting_method_code accounting_method_code,sub.effective_to_date,
           sub.vendor_id,sub.currency_code,
           -- to_number(sgn.VALUE) accrual_stream_type_id,  --RMUNJULU *** --rmunjulu bug 4399352
           cle1.id subsidy_line_id, -- smoduga ***
           nvl(kle1.subsidy_override_amount,nvl(kle1.amount,0)) subsidy_amount  -- RMUNJULU 3280473
    from OKL_K_LINES KLE1,
         OKC_K_LINES_B CLE1,
         OKC_LINE_STYLES_B LS1,
         okl_subsidies_b SUB,
         okl_subsidies_tl  subt,
         OKC_STATUSES_V STS1
         -- ,okl_sgn_translations sgn --RMUNJULU *** --rmunjulu bug 4399352
    where KLE1.ID = CLE1.ID
      AND CLE1.LSE_ID = LS1.ID
      AND LS1.LTY_CODE ='SUBSIDY'
      AND cle1.dnz_chr_id = c_contract_id
      AND CLE1.STS_CODE = STS1.CODE
      AND CLE1.STS_CODE <> 'ABANDONED'
      AND cle1.cle_id= c_parent_line_id
      AND SUB.ID = KLE1.SUBSIDY_ID
      AND SUBT.ID = SUB.ID
      And subt.language  =   userenv('LANG') ;
      --AND sgn.jtot_object1_code = 'OKL_STRMTYP'  --RMUNJULU *** --rmunjulu bug 4399352
      --AND sgn.object1_id1 = to_char(sub.stream_type_id); --RMUNJULU *** --rmunjulu bug 4399352


    -- get accepted date for the termination quote
   cursor c_term_quote(c_quote_id number) is
   select quote_number
   from okl_trx_quotes_v
   where id = c_quote_id
         AND accepted_yn ='Y';

    -- get contract_end_date
   cursor c_contract_eff_to(c_contract_id number) is
   select end_date
   from okc_k_headers_b
   where id = c_contract_id;

    --**SMODUGA added for currency conversion info
    -- get currency conversion info
    cursor c_currency_conversion (c_contract_id number) is
    select CURRENCY_CONVERSION_TYPE,CURRENCY_CONVERSION_RATE,
           CURRENCY_CONVERSION_DATE
    from okl_k_headers
    where id = c_contract_id;
    --**END SMODUGA added for currency conversion info

    -- getting App ID
   CURSOR c_app_info  IS
      SELECT APPLICATION_ID
      FROM FND_APPLICATION
      WHERE APPLICATION_SHORT_NAME = 'OKL' ;

    -- ***SMODUGA***--
    --changed to get vendor_id and vendor site id for generating AP invoice
    -- getting vendor site id
    CURSOR c_vendor_info (p_subsidy_line_id NUMBER) IS
    SELECT pay.vendor_id,
       pay.pay_site_id
    FROM   okl_party_payment_dtls_v pay,
       okc_k_party_roles_v  party
    WHERE  pay.cpl_id = party.id
    AND    party.cle_id = p_subsidy_line_id ;

    -- *** END SMODUGA***--

    --**SMODUGA added for contract product
    --getting contract product id
    CURSOR pdt_id_csr ( p_khr_id NUMBER ) IS
         SELECT khr.pdt_id
         FROM okl_k_headers khr
         WHERE khr.id =  p_khr_id;
   --**END SMODUGA added for contract product

    --    Transaction type
    CURSOR c_trx_type (c_name VARCHAR2, c_language VARCHAR2) IS
        SELECT  id
        FROM    okl_trx_types_tl
        WHERE   name      = c_name
        AND     language  = c_language;

    -- GET formula name
    CURSOR c_formula (c_refund_formula_id   NUMBER) IS
        SELECT NAME
        FROM OKL_FORMULAE_V
        WHERE ID = c_refund_formula_id;

    -- SMODUGA added for getting acceleration till date
    -- get acceleration till date

    CURSOR get_accel_till_csr (c_khr_id IN NUMBER, c_accrual_sty_id IN NUMBER) IS
     SELECT max(stream_element_date) accelerate_till_date
     FROM   okl_strm_elements_v sel,
            okl_streams         stm
     where  SEL.STM_ID = STM.ID
     and    STM.STY_ID = c_accrual_sty_id
     and    STM.khr_id = c_khr_id
     AND    STM.active_yn   = 'Y'
     AND    STM.say_code = 'CURR';

    -- END SMODUGA --
    l_sub_rec   c_active_subsidies%ROWTYPE;
    l_sob_id number; -- RMUNJULU *** Added

    -- rmunjulu EDAT
    l_quote_accpt_date DATE;
    l_quote_eff_date DATE;
    l_valid_gl_date DATE;
    --Bug# 3999921: pagarg +++ T and A ++++
    l_release_basis VARCHAR2(30);

    l_accrual_sty_id NUMBER;  -- rmunjulu 4399352
    l_accrual_sty_id_rep NUMBER;  -- MGAAP 7263041
    l_trx_number OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE;  -- MGAAP 7263041

    -- rmunjulu 4622198
    CURSOR khr_dtls_csr ( p_khr_id NUMBER ) IS
         SELECT chr.scs_code
         FROM okc_k_headers_b chr
         WHERE chr.id =  p_khr_id;

      -- rmunjulu 4622198
      l_scs_code OKC_K_HEADERS_B.scs_code%TYPE;
      l_fact_synd_code FND_LOOKUPS.lookup_code%TYPE;
      l_inv_acct_code OKC_RULES_B.rule_information1%TYPE;
     --akrangan Bug 5526955 fix start
      CURSOR check_accrual_previous_csr IS
      SELECT NVL(CHK_ACCRUAL_PREVIOUS_MNTH_YN,'N')
      FROM OKL_SYSTEM_PARAMS;

      l_accrual_previous_mnth_yn VARCHAR2(3);
     --akrangan Bug 5526955 fix start
    FUNCTION get_invoice_number(
                            p_app_id IN NUMBER,
                            p_cat_code IN VARCHAR2,
                            p_sob_id IN NUMBER,
                            p_met_code IN VARCHAR2,
                            p_trx_date IN DATE,
                            p_dbseqnum IN OUT NOCOPY VARCHAR2,
                            p_dbseqid IN OUT NOCOPY NUMBER
                             ) RETURN NUMBER IS
                    l_row_notfound                 BOOLEAN := TRUE;
                    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_invoice_number';
                    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
                    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
                    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
                    BEGIN
                           IF (is_debug_procedure_on) THEN
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
                           END IF;
                           IF (is_debug_statement_on) THEN
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_app_id: '|| p_app_id);
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cat_code: '|| p_cat_code);
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_sob_id: '|| p_sob_id);
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_met_code: '|| p_met_code);
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_trx_date: '|| p_trx_date);
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_dbseqnum: '|| p_dbseqnum);
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_dbseqid: '|| p_dbseqid);
                           END IF;
                            l_tapv_rec.Invoice_Number := fnd_seqnum.get_next_sequence
                                                        (appid      =>  p_app_id,
                                                         cat_code    =>  p_cat_code,
                                                         sobid       =>  p_sob_id,
                                                         met_code    =>  p_met_code,
                                                         trx_date    =>  p_trx_date,
                                                         dbseqnm     =>  p_dbseqnum,
                                                         dbseqid     =>  p_dbseqid);
                            IF (is_debug_procedure_on) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
                            END IF;
                            IF (is_debug_statement_on) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning l_tapv_rec.Invoice_Number: '||l_tapv_rec.Invoice_Number);
                            END IF;
                            RETURN  l_tapv_rec.Invoice_Number;

                      EXCEPTION
                       WHEN OTHERS THEN
                            IF (is_debug_exception_on) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		                                                       || sqlcode || ' , SQLERRM : ' || sqlerrm);
                            END IF;
                            OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                                                p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                                                p_token1        => 'OKL_SQLCODE',
                                                p_token1_value  => SQLCODE,
                                                p_token2        => 'OKL_SQLERRM',
                                                p_token2_value  => SQLERRM);
                     END get_invoice_number;
  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_call_origin: '|| p_call_origin);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_termination_date: '|| p_termination_date);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_id: '|| p_term_rec.p_contract_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_number: '|| p_term_rec.p_contract_number);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_modifier: '|| p_term_rec.p_contract_modifier);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_control_flag: '|| p_term_rec.p_control_flag);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_type: '|| p_term_rec.p_quote_type);
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


    -- Initialize return_status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

      -- rmunjulu EDAT
      -- If quote exists then accnting date is quote accept date else sysdate
      IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN

          l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
          l_quote_eff_date := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;

      ELSE

          l_quote_accpt_date := p_termination_date;
          l_quote_eff_date :=  p_termination_date;

      END IF;

      -- rmunjulu EDAT
      -- get valid GL Date for acceptance date
      l_valid_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date( p_gl_date => l_quote_accpt_date);


    -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++


    -- Determine call origin
    IF p_call_origin = 'PARTIAL' THEN -- [1]

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_CNTRCT_LN_TRMNT_PVT.get_lines');
      END IF;
        -- get line details from OKL_AM_CNTRCT_LN_TRMNT
        OKL_AM_CNTRCT_LN_TRMNT_PVT.get_lines(
                              p_term_rec     => p_term_rec,
                              x_klev_tbl        => l_asset_tbl_l,
                              x_return_status   => l_return_status);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_CNTRCT_LN_TRMNT_PVT.get_lines , return status: ' || l_return_status);
      END IF;

        IF  l_asset_tbl_l.count > 0 THEN --[2]
            -- populate local table
            FOR i in l_asset_tbl_l.first..l_asset_tbl_l.last LOOP --[ L1 ]
                l_asset_tbl(i).p_kle_id     := l_asset_tbl_l(i).p_kle_id;
                l_asset_tbl(i).p_asset_name := l_asset_tbl_l(i).p_asset_name;
            END LOOP; -- [ L1 ]

        END IF; -- [2]


       ELSE  -- Full Termination

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.get_contract_lines');
      END IF;
        -- get line details from OKL_AM_LEASE_TRMNT_PVT
        OKL_AM_LEASE_TRMNT_PVT.get_contract_lines(
                                           p_api_version      => p_api_version,
                                           p_init_msg_list    => OKL_API.G_FALSE,
                                           x_return_status    => l_return_status,
                                           x_msg_count        => l_msg_count,
                                           x_msg_data         => l_msg_data,
                                           p_term_rec         => p_term_rec,
                                           x_klev_tbl         => l_asset_tbl);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.get_contract_lines , return status: ' || l_return_status);
      END IF;

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;   -- [1]

    -- rmunjulu 4622198 SPECIAL_ACCNT Get contract details
    OPEN khr_dtls_csr (p_term_rec.p_contract_id);
    FETCH khr_dtls_csr INTO l_scs_code;
    CLOSE khr_dtls_csr;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_SECURITIZATION_PVT.check_khr_ia_associated');
      END IF;
    -- rmunjulu 4622198 SPECIAL_ACCNT Get special accounting details
    OKL_SECURITIZATION_PVT.check_khr_ia_associated(
        p_api_version                  => l_api_version
       ,p_init_msg_list                => OKL_API.G_FALSE
       ,x_return_status                => l_return_status
       ,x_msg_count                    => l_msg_count
       ,x_msg_data                     => l_msg_data
       ,p_khr_id                       => p_term_rec.p_contract_id
       ,p_scs_code                     => l_scs_code
       ,p_trx_date                     => l_quote_accpt_date
       ,x_fact_synd_code               => l_fact_synd_code
       ,x_inv_acct_code                => l_inv_acct_code
       );
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_SECURITIZATION_PVT.check_khr_ia_associated , return status: ' || l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_fact_synd_code : ' || l_fact_synd_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_inv_acct_code : ' || l_inv_acct_code);
      END IF;

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    -- Loop through each asset and process
    IF l_asset_tbl.count > 0 THEN
        FOR i in l_asset_tbl.FIRST..l_asset_tbl.LAST LOOP --[ L2 ]

           -- Get the subsidy lines for the financial asset line sent
           -- Check all active subsidies for the asset
           FOR l_sub_rec in c_active_subsidies(l_asset_tbl(i).p_kle_id,p_term_rec.p_contract_id) LOOP --[L3]

            --Bug# 3999921: pagarg +++ T and A +++++++ Start ++++++++++
            --Check for release basis to either accelerate accruals or create AP invoice
            --for TER_RELEASE_WO_PURCHASE
            IF p_term_rec.p_quote_type = 'TER_RELEASE_WO_PURCHASE'
            THEN
               IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_SUBSIDY_PROCESS_PVT.GET_RELK_TERMN_BASIS');
               END IF;
               OKL_SUBSIDY_PROCESS_PVT.GET_RELK_TERMN_BASIS(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => OKL_API.G_FALSE,
                         x_return_status  => l_return_status,
                         x_msg_count      => l_msg_count,
                         x_msg_data       => l_msg_data,
                         p_chr_id         => p_term_rec.p_contract_id,
                         p_subsidy_id     => l_sub_rec.subsidy_line_id,
                         x_release_basis  => l_release_basis);
               IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_SUBSIDY_PROCESS_PVT.GET_RELK_TERMN_BASIS , return status: ' || l_return_status);
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_release_basis : ' || l_release_basis);
               END IF;

               IF l_sub_rec.accounting_method_code = 'AMORTIZE'
               THEN
                 IF l_release_basis = 'ACCELERATE'
                 THEN

                    IF (is_debug_statement_on) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_STREAMS_UTIL.get_dependent_stream_type');
                    END IF;
                    -- SECHAWLA 29-DEC-05 4911502 : moved from above : begin
                    -- rmunjulu 4399352 Added the following for bug  4399352 - start
                    OKL_STREAMS_UTIL.get_dependent_stream_type(
                    p_khr_id                => p_term_rec.p_contract_id,
                    p_primary_sty_id        => l_sub_rec.stream_type_id,
                    p_dependent_sty_purpose => 'SUBSIDY_INCOME',
                    x_return_status         => l_return_status,
                    x_dependent_sty_id      => l_accrual_sty_id);
                    IF (is_debug_statement_on) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_STREAMS_UTIL.get_dependent_stream_type , return status : ' || l_return_status);
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_accrual_sty_id : ' || l_accrual_sty_id);
                    END IF;

              		IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              		ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 		RAISE OKL_API.G_EXCEPTION_ERROR;
              		END IF;
           			-- rmunjulu 4399352 Added the following for bug  4399352 - end
                    -- SECHAWLA 29-DEC-05 4911502 : moved from above : end

                    -- Fetch stream type id for subsidy and accrual streams
                    l_sty_id := l_accrual_sty_id; -- rmunjulu 4399352
                    --akrangan for bug 5669097 fix start
                    IF l_acceleration_tbl.COUNT>0 THEN
	              FOR c IN l_acceleration_tbl.first .. l_acceleration_tbl.last
	              LOOP
		        IF (l_acceleration_tbl(c).khr_id = p_term_rec.p_contract_id
                        AND l_acceleration_tbl(c).sty_id =l_sty_id
                        AND l_acceleration_tbl(c).kle_id =l_asset_tbl(i).p_kle_id )
			THEN
		          v_flag                  :='Y';
			  EXIT;
		        ELSE
			  v_flag :='N';
 	                END IF;
                      END LOOP;
                    END IF;
                    l_acceleration_tbl(indx).khr_id :=p_term_rec.p_contract_id;
                    l_acceleration_tbl(indx).sty_id :=l_sty_id;
                    l_acceleration_tbl(indx).kle_id :=l_asset_tbl(i).p_kle_id ;
                    indx := indx + 1;
                    -- akrangan for bug 5669097 fix end
                    OPEN get_accel_till_csr(p_term_rec.p_contract_id, l_sty_id);
                    FETCH get_accel_till_csr INTO l_acceleration_rec.accelerate_till_date;
                    CLOSE get_accel_till_csr ;
		  --Bug 5852720 by srsreeni starts
 	          -- fix for bug -- 5610960 -- added below condition
 	          -- If quote exists then cancelation date is quote eff from date else sysdate
 	                IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN
 	           --Bug 5852720 by srsreeni ends
                   --akrangan Bug 5526955 fix start
                   --Based on CHK_ACCRUAL_PREVIOUS_MNTH_YN setup
		   --check accruals till quote eff date OR previous month last date
                   OPEN  check_accrual_previous_csr;
                   FETCH check_accrual_previous_csr INTO l_accrual_previous_mnth_yn;
                   CLOSE check_accrual_previous_csr;

                   IF nvl(l_accrual_previous_mnth_yn,'N') = 'N' THEN
                     l_acceleration_rec.accelerate_from_date := TRUNC(LAST_DAY(l_quote_eff_date) + 1);
                   ELSE
                     l_acceleration_rec.accelerate_from_date := LAST_DAY(TRUNC(l_quote_eff_date, 'MONTH')-1)+1;
                   END IF;
                   --akrangan Bug 5526955 fix end
		   --Bug 5852720 by srsreeni starts
 	           ELSE
 	            l_acceleration_rec.accelerate_from_date := TRUNC(LAST_DAY(l_quote_eff_date) + 1);
 	           END IF;
 	            --Bug 5852720 by srsreeni ends
                    --pre populate the accrual rec
                    l_acceleration_rec.khr_id := p_term_rec.p_contract_id; -- Id of the contract whose stream type needs to be accelerated
                    l_acceleration_rec.sty_id := l_sty_id;-- Id of the stream type which needs to be accelerated
                    l_acceleration_rec.acceleration_date := l_valid_gl_date; -- Date of acceleration (Transaction date)
                    l_acceleration_rec.kle_id := l_asset_tbl(i).p_kle_id; --added for handling partial terminations.

                    -- Termination quote number
                    OPEN c_term_quote(p_term_rec.p_quote_id);
                    FETCH c_term_quote INTO l_quote_number;
                      IF c_term_quote%FOUND
                      THEN
                        l_acceleration_rec.description := 'Accrual acceleration for Asset number '
                                                        ||l_asset_tbl(i).p_asset_name||
                                                        'and Contract number '||p_term_rec.p_contract_number ||
                                                        'upon acceptance of ' || l_quote_number;
                      ELSE
                        l_acceleration_rec.description := 'Accrual acceleration for Asset number '
                                                        ||l_asset_tbl(i).p_asset_name||
                                                        'and Contract number '||p_term_rec.p_contract_number;
                      END IF;
                    CLOSE c_term_quote;

                    l_acceleration_rec.accrual_rule_yn := 'N';

                    --Accelerate Income Recognization
		    -- akrangan for bug 5669097 start
 	            IF  v_flag ='N' THEN
                    IF (is_debug_statement_on) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals');
                    END IF;
 	            -- akrangan for bug 5669097 End
                    OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals (
                                                    p_api_version       => p_api_version,
                                                    p_init_msg_list     => OKL_API.G_FALSE,
                                                    x_return_status     => l_return_status,
                                                    x_msg_count         => l_msg_count,
                                                    x_msg_data          => l_msg_data,
                                                    p_acceleration_rec  => l_acceleration_rec,
                                                    x_trx_number  => l_trx_number);
                    IF (is_debug_statement_on) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals , return status : ' || l_return_status);
                    END IF;

                    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                       OKL_API.set_message(
                             p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_SUBSIDY_INC_RECOG',
                             p_token1        => 'ASSET_NUMBER',
                             p_token1_value  => l_asset_tbl(i).p_asset_name,
                             p_token2        => 'CONTRACT_NUMBER',
                             p_token2_value  => p_term_rec.p_contract_number);
                    END IF;

                    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    -- Start MGAAP 7263041
                    OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
                    OKL_STREAMS_UTIL.get_dependent_stream_type_rep(
                    p_khr_id                => p_term_rec.p_contract_id,
                    p_primary_sty_id        => l_sub_rec.stream_type_id,
                    p_dependent_sty_purpose => 'SUBSIDY_INCOME',
                    x_return_status         => l_return_status,
                    x_dependent_sty_id      => l_accrual_sty_id_rep);
                    IF (is_debug_statement_on) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_STREAMS_UTIL.get_dependent_stream_type , return status : ' || l_return_status);
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_accrual_sty_id_rep : ' || l_accrual_sty_id_rep);
                    END IF;

              	    IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
                      l_acceleration_rec.sty_id := l_accrual_sty_id_rep;
                      l_acceleration_rec.trx_number := l_trx_number;

                      OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals (
                                                    p_api_version       => p_api_version,
                                                    p_init_msg_list     => OKL_API.G_FALSE,
                                                    x_return_status     => l_return_status,
                                                    x_msg_count         => l_msg_count,
                                                    x_msg_data          => l_msg_data,
                                                    p_acceleration_rec  => l_acceleration_rec,
                                                    p_representation_type  => 'SECONDARY',
                                                    x_trx_number  => l_trx_number);
                      OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;

                      IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals , return status : ' || l_return_status);
                      END IF;

                      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                         OKL_API.set_message(
                             p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_SUBSIDY_INC_RECOG',
                             p_token1        => 'ASSET_NUMBER',
                             p_token1_value  => l_asset_tbl(i).p_asset_name,
                             p_token2        => 'CONTRACT_NUMBER',
                             p_token2_value  => p_term_rec.p_contract_number);
                      END IF;

                      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

              	    END IF;
                    -- end MGAAP 7263041

                  -- akrangan for bug 5669097 start
 	            END IF;
 	          -- akrangan for bug 5669097 End
                 ELSE -- l_release_basis = 'ACCELERATE'
                  -------------------------------------------------
                  --Gathering data for creating Invoice
                  -------------------------------------------------
                  l_sub_sty_id := l_sub_rec.stream_type_id;
                  l_sob_id := okl_accounting_util.get_set_of_books_id;
                  -- get  currency conversion information
                  OPEN c_currency_conversion(p_term_rec.p_contract_id);
                  FETCH c_currency_conversion INTO l_currency_conversion_type,
                                                   l_currency_conversion_rate,
                                                   l_currency_conversion_date;
                  CLOSE c_currency_conversion ;

                  -- Get Application Info
                  OPEN c_app_info ;
                  FETCH c_app_info INTO l_app_id;
                    IF(c_app_info%NOTFOUND)
                    THEN
                      -- Change Message
                      Okc_Api.set_message(G_APP_NAME, 'OKL_NO_TRANSACTION',
                                          G_COL_NAME_TOKEN,'Billing');
                      x_return_status := OKC_API.G_RET_STS_ERROR ;
                    CLOSE c_app_info ;
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                    END if ;
                  CLOSE c_app_info;

                  -- get Vendor site Id
                  OPEN c_vendor_info (l_sub_rec.subsidy_line_id);
                  FETCH c_vendor_info INTO l_tapv_rec.vendor_id, l_tapv_rec.IPVS_ID;
                    IF(c_vendor_info%NOTFOUND) THEN
                      -- Change Message
                      Okc_Api.set_message(G_APP_NAME, 'OKL_NO_VENDOR_SITE');
                      x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_vendor_info ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                    END if ;
                  CLOSE c_vendor_info;

                  l_tapv_rec.sfwt_flag := 'N' ;
                  l_tapv_rec.TRX_STATUS_CODE  := 'ENTERED' ;
                  l_tapv_rec.currency_code := l_sub_rec.currency_code;

                  l_tapv_rec.CURRENCY_CONVERSION_TYPE := l_currency_conversion_type;
                  l_tapv_rec.CURRENCY_CONVERSION_RATE := l_currency_conversion_rate;
                  l_tapv_rec.CURRENCY_CONVERSION_DATE := l_currency_conversion_date;
                  l_tapv_rec.SET_OF_BOOKS_ID := l_sob_id;

                  -- GET TRANSACTION TYPE
                  OPEN c_trx_type ('Disbursement', 'US');
                  FETCH c_trx_type INTO l_trx_type_ID;
                    IF(c_trx_type%NOTFOUND)
                    THEN
                      Okc_Api.set_message(G_APP_NAME, 'OKL_NO_TRANSACTION',
                                          G_COL_NAME_TOKEN,'Disbursement');
                      x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_trx_type ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                    END if ;
                  CLOSE c_trx_type ;
                  l_tapv_rec.TRY_ID :=  l_trx_type_ID;
                  l_tapv_rec.AMOUNT :=  lx_subsidy_amount;
                  l_tapv_rec.invoice_type := 'STANDARD';
                  IF (is_debug_statement_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Getting invoice number');
                  END IF;
                  l_tapv_rec.Invoice_number := get_invoice_number(
                                                        p_app_id => l_app_id,
                                                        p_cat_code =>l_document_category,
                                                        p_sob_id =>l_tapv_rec.SET_OF_BOOKS_ID,
                                                        p_met_code => 'A',
                                                        p_trx_date => SYSDATE,
                                                        p_dbseqnum => lx_dbseqnm,
                                                        p_dbseqid => lx_dbseqid);

                  l_tapv_rec.WORKFLOW_YN := 'N';
                  l_tapv_rec.CONSOLIDATE_YN  := 'N';
                  l_tapv_rec.WAIT_VENDOR_INVOICE_YN := 'N';

                  -- setting all three dates to termination date instead of SYSDATE
                  l_tapv_rec.DATE_INVOICED := l_quote_accpt_date;
                  l_tapv_rec.DATE_GL :=  l_quote_accpt_date;
                  l_tapv_rec.DATE_ENTERED := l_quote_accpt_date;
                  l_tapv_rec.object_version_number := 1;
--20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
                  l_tapv_rec.legal_entity_id :=OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_term_rec.p_contract_id);

                  SELECT DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
                         DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
                         DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
                         DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
                         mo_global.get_current_org_id() INTO l_tapv_rec.REQUEST_ID,
                                                          l_tapv_rec.PROGRAM_APPLICATION_ID,
                                                          l_tapv_rec.PROGRAM_ID,
                                                          l_tapv_rec.PROGRAM_UPDATE_DATE,
                                                          l_tapv_rec.ORG_ID
                  FROM dual;


                  ----------------------------------------------------
                  -- Populate internal AP invoice Lines Record
                  ----------------------------------------------------

                   /* sosharma 17-01-2007,added assignment of khr_id to l_tapv_rec
                   Start Changes
                   */
                  l_tplv_rec.KHR_ID :=  p_term_rec.p_contract_id;
                  /* End changes */
                  l_tplv_rec.amount := l_tapv_rec.amount;
                  l_tplv_rec.sty_id := l_sub_sty_id;
                  l_tplv_rec.inv_distr_line_code := 'MANUAL';
                  l_tplv_rec.line_number := 1;
                  l_tplv_rec.org_id := l_tapv_rec.org_id;
                  l_tplv_rec.disbursement_basis_code := 'BILL_DATE';
                  /* sosharma 16-01-2007
                  Assigned the record l_tplv_rec to table
                  Start Changes */
                  l_tplv_tbl(0):=l_tplv_rec;
                  /* sosharma
                  End changes
                  */
                  /*sosharma 12-jan-07
                   Build:R12
                   Added the call to disbursement procedure ,which is having the consolidated functionality of creating AP lines,header and AP accounting
                   */
                   IF (is_debug_statement_on) THEN
                     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_CREATE_DISB_TRANS_PVT.create_disb_trx');
                   END IF;
                   OKL_CREATE_DISB_TRANS_PVT.create_disb_trx(p_api_version   =>    l_api_version
                            ,p_init_msg_list      =>      OKL_API.G_FALSE
                            ,x_return_status      =>      l_return_status
                            ,x_msg_count          =>      x_msg_count
                            ,x_msg_data           =>      x_msg_data
                            ,p_tapv_rec           =>      l_tapv_rec
                            ,p_tplv_tbl           =>      l_tplv_tbl
                            ,x_tapv_rec           =>      x_tapv_rec
                            ,x_tplv_tbl           =>      x_tplv_tbl
                            );
                   IF (is_debug_statement_on) THEN
                     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_CREATE_DISB_TRANS_PVT.create_disb_trx , return status : ' || l_return_status);
                   END IF;
                         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                           RAISE OKL_API.G_EXCEPTION_ERROR;
                         END IF;

      x_tplv_rec := x_tplv_tbl(x_tplv_tbl.FIRST);

                   /*End Changes sosharma */

                 END IF; -- l_release_basis = 'ACCELERATE'
               END IF ; -- Accounting method
            ELSE -- quote type condition for TER_RELEASE_WO_PURCHASE
            --Bug# 3999921: pagarg +++ T and A +++++++ End ++++++++++
            --Current processing for quote type other than TER_RELEASE_WO_PURCHASE
              -- Fetch stream type id for subsidy and accrual streams
              l_sub_sty_id := l_sub_rec.stream_type_id; -- ***SMODUGA  Subsidy stream type for invoice generation***

              --SECHAWLA 29-DEC-05 4911502 : commenetd out
              --l_sty_id := l_accrual_sty_id;  --RMUNJULU *** Changed to pass accrual_stream_type_id -- rmunjulu 4399352

              l_sob_id := okl_accounting_util.get_set_of_books_id; --RMUNJULU *** Added code to get set of books id

              --check accounting method
              IF l_sub_rec.accounting_method_code = 'NET' THEN --[3]

                 null;   -- close sub line

              ELSIF l_sub_rec.accounting_method_code = 'AMORTIZE'THEN

                   IF (is_debug_statement_on) THEN
                     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_STREAMS_UTIL.get_dependent_stream_type');
                   END IF;
					 -- SECHAWLA 29-DEC-05 4911502 : added begin
                     OKL_STREAMS_UTIL.get_dependent_stream_type(
                      p_khr_id                => p_term_rec.p_contract_id,
                      p_primary_sty_id        => l_sub_rec.stream_type_id,
                      p_dependent_sty_purpose => 'SUBSIDY_INCOME', -- ***** confirm
                      x_return_status         => l_return_status,
                      x_dependent_sty_id      => l_accrual_sty_id);
                   IF (is_debug_statement_on) THEN
                     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_STREAMS_UTIL.get_dependent_stream_type , return status : ' || l_return_status);
                   END IF;

                     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                         RAISE OKL_API.G_EXCEPTION_ERROR;
                     END IF;

                     l_sty_id := l_accrual_sty_id; --l_sub_rec.accrual_stream_type_id;  --RMUNJULU *** Changed to pass accrual_stream_type_id
                    -- SECHAWLA 29-DEC-05 4911502 : added end


                    --Accelerate Income Recognization
                    -- get contract_end_date
                    OPEN c_contract_eff_to(p_term_rec.p_contract_id);
                    FETCH c_contract_eff_to INTO l_contract_end_date ;
                    CLOSE c_contract_eff_to ;

                     -- **SMODUGA added
                     -- get  currency conversion information
                    OPEN c_currency_conversion(p_term_rec.p_contract_id);
                    FETCH c_currency_conversion INTO l_currency_conversion_type,
                                                     l_currency_conversion_rate,
                                                     l_currency_conversion_date;
                    CLOSE c_currency_conversion ;

                    -- akrangan for bug 5669097 start
 	            IF l_acceleration_tbl.COUNT>0 THEN
 	              FOR c IN l_acceleration_tbl.first .. l_acceleration_tbl.last
 	              LOOP
 	                IF (l_acceleration_tbl(c).khr_id = p_term_rec.p_contract_id
			    AND l_acceleration_tbl(c).sty_id =l_sty_id
			    AND l_acceleration_tbl(c).kle_id =l_asset_tbl(i).p_kle_id )
			THEN
 	                  v_flag :='Y';
 	                  EXIT;
 	                ELSE
 	                  v_flag :='N';
 	                END IF;
 	              END LOOP;
 	            END IF;
 	            l_acceleration_tbl(indx).khr_id :=p_term_rec.p_contract_id;
 	            l_acceleration_tbl(indx).sty_id :=l_sty_id;
 	            l_acceleration_tbl(indx).kle_id :=l_asset_tbl(i).p_kle_id ;
 	            indx := indx + 1;
 	            -- akrangan for bug 5669097 End
                    OPEN get_accel_till_csr(p_term_rec.p_contract_id,l_sty_id);
                    FETCH get_accel_till_csr INTO l_acceleration_rec.accelerate_till_date;
                    CLOSE get_accel_till_csr ;

                    -- **END SMODUGA added
	            --akrangan Bug 5526955 fix start
 	            --Based on CHK_ACCRUAL_PREVIOUS_MNTH_YN setup check accruals till quote eff date OR previous month last date
 	            OPEN  check_accrual_previous_csr;
 	            FETCH check_accrual_previous_csr INTO l_accrual_previous_mnth_yn;
 	            CLOSE check_accrual_previous_csr;
                    --Bug 5852720 by akrangan starts
 	            -- fix for bug -- 5610960 -- added below condition
 	             -- If quote exists then cancelation date is quote eff from date else sysdate
 	                 IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN
 	             --Bug 5852720 by akrangan  ends
 	            IF nvl(l_accrual_previous_mnth_yn,'N') = 'N' THEN
                      l_acceleration_rec.accelerate_from_date := TRUNC(LAST_DAY(l_quote_eff_date) + 1);
 	            ELSE
                      l_acceleration_rec.accelerate_from_date := LAST_DAY(TRUNC(l_quote_eff_date, 'MONTH')-1)+1;
 	            END IF;
 	            --akrangan Bug 5526955 fix end
                    --Bug 5852720 by srsreeni starts
 	            ELSE
 	              l_acceleration_rec.accelerate_from_date := TRUNC(LAST_DAY(l_quote_eff_date) + 1);
 	            END IF;
 	            --Bug 5852720 by srsreeni ends
                    --pre populate the accraual rec
                    l_acceleration_rec.khr_id           := p_term_rec.p_contract_id; -- Id of the contract whose stream type needs to be accelerated
                    l_acceleration_rec.sty_id           := l_sty_id;-- Id of the stream type which needs to be accelerated
                    l_acceleration_rec.acceleration_date := l_valid_gl_date; -- Date of acceleration (Transaction date) - -rmunjulu EDAT

                    l_acceleration_rec.kle_id := l_asset_tbl(i).p_kle_id; --Smoduga added for handling partial terminations.
                    -- Termination quote number
                    OPEN c_term_quote(p_term_rec.p_quote_id);
                    FETCH c_term_quote INTO l_quote_number;
                    IF c_term_quote%FOUND THEN
                    l_acceleration_rec.description := 'Accrual acceleration for Asset number '
                                                        ||l_asset_tbl(i).p_asset_name||
                                                        'and Contract number '||p_term_rec.p_contract_number ||
                                                        'upon acceptance of ' || l_quote_number;
                    ELSE
                     l_acceleration_rec.description := 'Accrual acceleration for Asset number '
                                                        ||l_asset_tbl(i).p_asset_name||
                                                        'and Contract number '||p_term_rec.p_contract_number;
                    END IF;
                    CLOSE c_term_quote;

                    l_acceleration_rec.accrual_rule_yn := 'N';

                    -- check for recourse
                    IF l_sub_rec.recourse_yn <> 'Y' THEN --[7]
	              -- akrangan for bug 5669097 start
 	              IF  v_flag ='N' THEN
 	              -- akrangan for bug 5669097 End
                       -- accelerate income recognition
                        IF (is_debug_statement_on) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals');
                        END IF;
                         OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals (
                                                    p_api_version       => p_api_version,
                                                    p_init_msg_list     => OKL_API.G_FALSE,
                                                    x_return_status     => l_return_status,
                                                    x_msg_count         => l_msg_count,
                                                    x_msg_data          => l_msg_data,
                                                    p_acceleration_rec  => l_acceleration_rec,
                                                    x_trx_number  => l_trx_number);
                        IF (is_debug_statement_on) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals , return status : ' || l_return_status);
                        END IF;

                         IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                           OKL_API.set_message(
                             p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_SUBSIDY_INC_RECOG',
                             p_token1        => 'ASSET_NUMBER',
                             p_token1_value  => l_asset_tbl(i).p_asset_name,
                             p_token2        => 'CONTRACT_NUMBER',
                             p_token2_value  => p_term_rec.p_contract_number);

                         END IF;

                         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                           RAISE OKL_API.G_EXCEPTION_ERROR;
                         END IF;
		      -- akrangan for bug 5669097 start
                    -- Start MGAAP 7263041
                    OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
                    OKL_STREAMS_UTIL.get_dependent_stream_type_rep(
                    p_khr_id                => p_term_rec.p_contract_id,
                    p_primary_sty_id        => l_sub_rec.stream_type_id,
                    p_dependent_sty_purpose => 'SUBSIDY_INCOME',
                    x_return_status         => l_return_status,
                    x_dependent_sty_id      => l_accrual_sty_id_rep);
                    IF (is_debug_statement_on) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_STREAMS_UTIL.get_dependent_stream_type , return status : ' || l_return_status);
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_accrual_sty_id_rep : ' || l_accrual_sty_id_rep);
                    END IF;

              	    IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
                      l_acceleration_rec.sty_id := l_accrual_sty_id_rep;
                      l_acceleration_rec.trx_number := l_trx_number;

                      OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals (
                                                    p_api_version       => p_api_version,
                                                    p_init_msg_list     => OKL_API.G_FALSE,
                                                    x_return_status     => l_return_status,
                                                    x_msg_count         => l_msg_count,
                                                    x_msg_data          => l_msg_data,
                                                    p_acceleration_rec  => l_acceleration_rec,
                                                    p_representation_type  => 'SECONDARY',
                                                    x_trx_number  => l_trx_number);
                      OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;

                      IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals , return status : ' || l_return_status);
                      END IF;

                      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                         OKL_API.set_message(
                             p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_SUBSIDY_INC_RECOG',
                             p_token1        => 'ASSET_NUMBER',
                             p_token1_value  => l_asset_tbl(i).p_asset_name,
                             p_token2        => 'CONTRACT_NUMBER',
                             p_token2_value  => p_term_rec.p_contract_number);
                      END IF;

                      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

              	    END IF;
                    -- end MGAAP 7263041
 	               END IF;
 	              -- akrangan for bug 5669097 End

                    ELSE -- Recourse

                       -- calculation basis FULL
                       IF l_sub_rec.TERMINATION_REFUND_BASIS = 'ALL' THEN  --[9]

                          -- AMORTIZE = Y ,RECOURSE =Y ,CALC basis = FULL,Billing Method = Invoice
                          IF l_sub_rec.receipt_method_code = 'BILL'
                          OR l_sub_rec.receipt_method_code = 'FUND' THEN  --[10]

                             -- RMUNJULU 3280473 Get the subsidy subline amount which should be refunded
                             lx_subsidy_amount := l_sub_rec.subsidy_amount;

                          END IF;   --[10]
                          -- adagur for bug 5669097 start
 	                  IF    v_flag ='N' THEN
 	                  -- adagur for bug 5669097 End
                           IF (is_debug_statement_on) THEN
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_GENERATE_ACCRUALS_PVT.ACCELERATE_ACCRUALS');
                           END IF;
                          -- accelerate income recognition
                            OKL_GENERATE_ACCRUALS_PVT.ACCELERATE_ACCRUALS(
                                                    p_api_version       => p_api_version,
                                                    p_init_msg_list     => OKL_API.G_FALSE,
                                                    x_return_status     => l_return_status,
                                                    x_msg_count         => l_msg_count,
                                                    x_msg_data          => l_msg_data,
                                                    p_acceleration_rec  => l_acceleration_rec,
                                                    x_trx_number  => l_trx_number);
                           IF (is_debug_statement_on) THEN
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_GENERATE_ACCRUALS_PVT.ACCELERATE_ACCRUALS , return status : ' || l_return_status);
                           END IF;

                            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                           	OKL_API.set_message(
                         		p_app_name      => G_APP_NAME,
                         		p_msg_name      => 'OKL_AM_SUBSIDY_INC_RECOG',
                         		p_token1        => 'ASSET_NUMBER',
                         		p_token1_value  => l_asset_tbl(i).p_asset_name,
                         		p_token2        => 'CONTRACT_NUMBER',
                         		p_token2_value  => p_term_rec.p_contract_number);

                            END IF;

                            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_ERROR;
                            END IF;
                          -- akrangan for bug 5669097 start
                    -- Start MGAAP 7263041
                    OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
                    OKL_STREAMS_UTIL.get_dependent_stream_type_rep(
                    p_khr_id                => p_term_rec.p_contract_id,
                    p_primary_sty_id        => l_sub_rec.stream_type_id,
                    p_dependent_sty_purpose => 'SUBSIDY_INCOME',
                    x_return_status         => l_return_status,
                    x_dependent_sty_id      => l_accrual_sty_id_rep);
                    IF (is_debug_statement_on) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_STREAMS_UTIL.get_dependent_stream_type , return status : ' || l_return_status);
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_accrual_sty_id_rep : ' || l_accrual_sty_id_rep);
                    END IF;

              	    IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
                      l_acceleration_rec.sty_id := l_accrual_sty_id_rep;
                      l_acceleration_rec.trx_number := l_trx_number;

                      OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals (
                                                    p_api_version       => p_api_version,
                                                    p_init_msg_list     => OKL_API.G_FALSE,
                                                    x_return_status     => l_return_status,
                                                    x_msg_count         => l_msg_count,
                                                    x_msg_data          => l_msg_data,
                                                    p_acceleration_rec  => l_acceleration_rec,
                                                    p_representation_type  => 'SECONDARY',
                                                    x_trx_number  => l_trx_number);
                      OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;

                      IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals , return status : ' || l_return_status);
                      END IF;

                      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                         OKL_API.set_message(
                             p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_SUBSIDY_INC_RECOG',
                             p_token1        => 'ASSET_NUMBER',
                             p_token1_value  => l_asset_tbl(i).p_asset_name,
                             p_token2        => 'CONTRACT_NUMBER',
                             p_token2_value  => p_term_rec.p_contract_number);
                      END IF;

                      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

              	    END IF;
                    -- end MGAAP 7263041
 	                  END IF;
 	                  -- akrangan for bug 5669097 End
                      ELSIF l_sub_rec.TERMINATION_REFUND_BASIS = 'FORMULA' THEN

                         -- get Formula name
                         OPEN c_formula(l_sub_rec.refund_formula_id);
                         FETCH c_formula INTO l_formula_name ;
                         CLOSE c_formula ;

                         IF l_sub_rec.receipt_method_code = 'BILL'
                         OR l_sub_rec.receipt_method_code = 'FUND' THEN --A/P invoice --[13]

                           IF (is_debug_statement_on) THEN
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_EXECUTE_FORMULA_PUB.execute');
                           END IF;
                           -- get subsidy amount
                           OKL_EXECUTE_FORMULA_PUB.execute(
                                             p_api_version       => p_api_version,
                                             p_init_msg_list     => OKL_API.G_FALSE,
                                             x_return_status     => l_return_status,
                                             x_msg_count         => l_msg_count,
                                             x_msg_data          => l_msg_data,
                                             p_formula_name      => l_formula_name,
                                             p_contract_id       => p_term_rec.p_contract_id,
                                             p_line_id           => l_asset_tbl(i).p_kle_id,
                                             p_additional_parameters => okl_execute_formula_pub.G_ADDITIONAL_PARAMETERS_NULL,
                                             x_value             =>lx_subsidy_amount);
                           IF (is_debug_statement_on) THEN
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_EXECUTE_FORMULA_PUB.execute , return status : ' || l_return_status);
                           END IF;

                           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_ERROR;
                           END IF;
                         END IF; -- [13]
                      END IF; --[9]
                         -------------------------------------------------
                         --Gathering data for creating Invoice
                         -------------------------------------------------
                         -- Get Application Info
                            OPEN c_app_info ;
                                FETCH c_app_info INTO l_app_id;
                                IF(c_app_info%NOTFOUND) THEN
                                -- Change Message
                                Okc_Api.set_message(G_APP_NAME, 'OKL_NO_TRANSACTION',
                                                    G_COL_NAME_TOKEN,'Billing');
                                x_return_status := OKC_API.G_RET_STS_ERROR ;
                            CLOSE c_app_info ;
                                RAISE OKC_API.G_EXCEPTION_ERROR;
                                END if ;

                            CLOSE c_app_info;

                            -- **SMODUGA added for AP  invoice creation
                            --l_tapv_rec.vendor_id := l_sub_rec.vendor_id;
                            -- ** END SMODUGA added for AP  invoice creation

                            -- get Vendor site Id
                            OPEN c_vendor_info (l_sub_rec.subsidy_line_id);
                            FETCH c_vendor_info INTO l_tapv_rec.vendor_id,l_tapv_rec.IPVS_ID;
                                IF(c_vendor_info%NOTFOUND) THEN
                                -- Change Message
                                Okc_Api.set_message(G_APP_NAME, 'OKL_NO_VENDOR_SITE');
                                x_return_status := OKC_API.G_RET_STS_ERROR ;
                            CLOSE c_vendor_info ;
                                RAISE OKC_API.G_EXCEPTION_ERROR;
                                END if ;

                            CLOSE c_vendor_info;

                            l_tapv_rec.sfwt_flag := 'N' ;
                            l_tapv_rec.TRX_STATUS_CODE  := 'ENTERED' ;
                            l_tapv_rec.currency_code := l_sub_rec.currency_code;

                            -- **SMODUGA added for creation of  AP invoice
                            l_tapv_rec.CURRENCY_CONVERSION_TYPE := l_currency_conversion_type;
                            l_tapv_rec.CURRENCY_CONVERSION_RATE := l_currency_conversion_rate;
                            l_tapv_rec.CURRENCY_CONVERSION_DATE := l_currency_conversion_date;
                            -- ** END SMODUGA added for AP  invoice creation

                            l_tapv_rec.SET_OF_BOOKS_ID := l_sob_id; --RMUNJULU *** Set the set_of_books_id

                             -- GET TRANSACTION TYPE
                             OPEN c_trx_type ('Disbursement', 'US');
                             FETCH c_trx_type INTO l_trx_type_ID;
                                IF(c_trx_type%NOTFOUND) THEN
                                    Okc_Api.set_message(G_APP_NAME, 'OKL_NO_TRANSACTION',
                                                        G_COL_NAME_TOKEN,'Disbursement');
                                                        x_return_status := OKC_API.G_RET_STS_ERROR ;
                            CLOSE c_trx_type ;
                                RAISE OKC_API.G_EXCEPTION_ERROR;
                                END if ;
                            CLOSE c_trx_type ;

                            l_tapv_rec.TRY_ID :=  l_trx_type_ID;
                            l_tapv_rec.AMOUNT :=  lx_subsidy_amount;
                            --20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
                            l_tapv_rec.legal_entity_id :=OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_term_rec.p_contract_id);
                            --** SMODUGA Added for invoice generation
                            l_tapv_rec.invoice_type           := 'STANDARD';
                            --** END SMODUGA Added for invoice generation
                           IF (is_debug_statement_on) THEN
                             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Getting invoice number');
                           END IF;

                            l_tapv_rec.Invoice_number := get_invoice_number(
                                                        p_app_id => l_app_id,
                                                        p_cat_code =>l_document_category,
                                                        p_sob_id =>l_tapv_rec.SET_OF_BOOKS_ID,
                                                        p_met_code => 'A',
                                                        p_trx_date => SYSDATE,
                                                        p_dbseqnum => lx_dbseqnm,
                                                        p_dbseqid => lx_dbseqid
                                                        );


                            l_tapv_rec.WORKFLOW_YN := 'N';
                            l_tapv_rec.CONSOLIDATE_YN  := 'N';
                            l_tapv_rec.WAIT_VENDOR_INVOICE_YN := 'N';

                            -- SMODUGA
                            -- setting all three dates to termination date
                            -- instead of SYSDATE

                            l_tapv_rec.DATE_INVOICED := l_quote_accpt_date; -- rmunjulu EDAT
                            l_tapv_rec.DATE_GL :=  l_quote_accpt_date; -- rmunjulu EDAT
                            l_tapv_rec.DATE_ENTERED := l_quote_accpt_date; -- rmunjulu EDAT

                            -- END SMODUGA

                            l_tapv_rec.object_version_number := 1;

                            SELECT DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
                                           DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
                                           DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
                                           DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
                                           mo_global.get_current_org_id()  INTO l_tapv_rec.REQUEST_ID,
                                                                       l_tapv_rec.PROGRAM_APPLICATION_ID,
                                                                       l_tapv_rec.PROGRAM_ID,
                                                                       l_tapv_rec.PROGRAM_UPDATE_DATE,
                                                                       l_tapv_rec.ORG_ID FROM dual;

                             --**SMODUGA Added for invoice lines ** --
                             ----------------------------------------------------
                             -- Populate internal AP invoice Lines Record
                             ------------------------------------------------------
                             /* sosharma 17-01-2007,added assignment of khr_id to l_tapv_rec
                             Start Changes
                             */
                             l_tplv_rec.KHR_ID :=  p_term_rec.p_contract_id;
                             /* End Changes */
                             l_tplv_rec.amount  :=  l_tapv_rec.amount;
                             l_tplv_rec.sty_id  :=  l_sub_sty_id; --smoduga changed to subsidy stream type
                             l_tplv_rec.inv_distr_line_code :=  'MANUAL';
                             l_tplv_rec.line_number  :=  1;
                             l_tplv_rec.org_id  :=  l_tapv_rec.org_id;
                             l_tplv_rec.disbursement_basis_code :=  'BILL_DATE';

                                /*sosharma 12-jan-07
                                  Build:R12
                                  Added the call to disbursement procedure ,which is having the consolidated functionality of creating AP lines,header and AP accounting
                                  */
                                  l_tplv_tbl(0):=l_tplv_rec;
                                  IF (is_debug_statement_on) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_CREATE_DISB_TRANS_PVT.create_disb_trx');
                                  END IF;
                                  OKL_CREATE_DISB_TRANS_PVT.create_disb_trx(p_api_version   =>    l_api_version
                                           ,p_init_msg_list     =>       OKL_API.G_FALSE
                                           ,x_return_status     =>       l_return_status
                                           ,x_msg_count         =>       x_msg_count
                                           ,x_msg_data          =>       x_msg_data
                                           ,p_tapv_rec          =>       l_tapv_rec
                                           ,p_tplv_tbl          =>       l_tplv_tbl
                                           ,x_tapv_rec          =>       x_tapv_rec
                                           ,x_tplv_tbl          =>       x_tplv_tbl
                                           );
                                  IF (is_debug_statement_on) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_CREATE_DISB_TRANS_PVT.create_disb_trx , return status : ' || l_return_status);
                                  END IF;
                                        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_ERROR;
                                        END IF;

                     x_tplv_rec := x_tplv_tbl(x_tplv_tbl.FIRST);

                                  /*End Changes sosharma */


                END IF; -- recourse --[7]
            END IF ; -- Accounting method  --[3]
                 -- close sub line
          END IF; -- quote type checking for TER_RELEASE_WO_PURCHASE
        END LOOP; -- subsidies --[L3]
    END LOOP; -- Main --[L2]
    END IF;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
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

 END process_discount_subsidy;

  -- Start of comments
  -- Procedure Name	: process_adjustments
  -- Desciption     : method to handle accrual adjustments
  -- Business Rules	:
  -- Parameters	    :
  -- Version	    : 1.0
  -- History        : 08 Nov 2004 PAGARG Bug# 3999921 (T and A)created
  --                : 14-Dec-04 rmunjulu TNA Modified to set return status properly and other changes
  --                : 14-Dec-04 rmunjulu TNA Additional changes as called API signature has changed
  --                : 14-Dec-04 rmunjulu TNA Close cursors in exception block
  --                : 20-Dec-04 rmunjulu TNA Added p_tcnv_rec since trn_id is needed
  --                : 20-Dec-04 rmunjulu TNA Added condition to check if advance_rent present
  --                : 10-Feb-05 PAGARG Bug 4177025 Create accounting distributions
  --                : after creating invoice lines
  --                : 21-Feb-05 rmunjulu Bug 4177025 Handle Return status properly
  -- End of comments
  PROCEDURE process_adjustments(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_tcnv_rec                    IN  tcnv_rec_type, -- rmunjulu TNA Added since trn_id is needed
           p_call_origin                 IN  VARCHAR2 DEFAULT NULL,
           p_termination_date            IN  DATE) IS

    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_adjustments';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    l_api_name         CONSTANT VARCHAR2(30) := 'process_adjustments';
    l_api_version      CONSTANT NUMBER := 1;
    l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS; -- rmunjulu TNA Defaulted
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    lx_asset_tbl       OKL_AM_LEASE_TRMNT_PVT.klev_tbl_type;
    l_taiv_rec         taiv_rec_type;
    lx_taiv_rec        taiv_rec_type;
    l_tilv_rec         tilv_rec_type;
    lx_tilv_rec        tilv_rec_type;
    l_cm_try_id        NUMBER;
    l_counter          NUMBER;
    l_asset_ref_amt    NUMBER;

    l_quote_accpt_date DATE;
    l_quote_eff_date   DATE;

    CURSOR l_qte_dtls_csr (p_qte_id IN NUMBER) IS
      SELECT qte.currency_code currency_code,
             qte.currency_conversion_type currency_conversion_type,
             qte.currency_conversion_rate currency_conversion_rate,
             qte.currency_conversion_date currency_conversion_date
      FROM okl_trx_quotes_b qte
      WHERE qte.id = p_qte_id;

    -- Cursor to obtain refund asset remaining amount
    CURSOR l_ref_asset_amt_csr(p_khr_id IN NUMBER, p_kle_id IN NUMBER, p_date IN DATE) IS
      SELECT stm.sty_id,
             SUM(ste.amount) amount
      FROM okl_streams       stm
          ,okl_strm_type_b   sty
          ,okc_k_lines_b     kle
          ,okc_statuses_b    kls
          ,okl_strm_elements ste
      WHERE stm.khr_id              = p_khr_id
        AND stm.active_yn           = 'Y'
        AND stm.say_code            = 'CURR'
        AND ste.stm_id              = stm.id
        AND sty.id                  = stm.sty_id
        AND sty.billable_yn         = 'Y'
        AND kle.id                  = stm.kle_id
        AND kls.code                = kle.sts_code
        AND kls.ste_code            = 'ACTIVE'
        AND ste.date_billed         IS NULL
        AND trunc(ste.stream_element_date) > trunc(p_date)
        AND kle.id                  = p_kle_id
        AND STY.STREAM_TYPE_PURPOSE = 'ADVANCE_RENT'
      GROUP BY stm.sty_id;

    -- rmunjulu TNA Get the FEE and SERVICE Top Lines
    CURSOR p_chr_lines_csr(p_chr_id IN NUMBER) IS
     SELECT CLE.ID
     FROM   OKC_k_LINES_B CLE,
            OKC_LINE_STYLES_B LTY
     WHERE  CLE.LSE_ID = LTY.ID
       AND  LTY.LTY_CODE IN ('FEE', 'SOLD_SERVICE') -- rmunjulu TNA Give the proper Alias
       AND  CLE.CHR_ID = p_chr_id; -- rmunjulu TNA Give the proper Alias

    l_sty_id              NUMBER;
    l_line_id_tbl         OKL_ACCRUAL_SEC_PVT.p_line_id_tbl_type;
    lx_accrual_adjustment_tbl OKL_ACCRUAL_SEC_PVT.p_accrual_adjustment_tbl_type;
    lx_trx_number         VARCHAR2(30) := null; -- MGAAP 7263041
    l_accrual_rec         OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type; -- rmunjulu TNA additional changes -- Changed
    l_stream_tbl          OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type;
    l_valid_gl_date       DATE;
    l_trmnt_try_id        NUMBER;

    -- rmunjulu TNA declared
    l_empty_taiv_rec    taiv_rec_type;
    l_empty_tilv_rec    tilv_rec_type;

    -- Bug 4177025 PAGARG 10-Feb-2005 declare record for creating accounting distributions
    l_bpd_acc_rec       okl_acc_call_pub.bpd_acc_rec_type;

    --rmunjulu 4769094
    CURSOR check_accrual_previous_csr IS
    SELECT NVL(CHK_ACCRUAL_PREVIOUS_MNTH_YN,'N')
    FROM OKL_SYSTEM_PARAMS;

    --rmunjulu 4769094
    l_accrual_previous_mnth_yn VARCHAR2(3);
    l_accrual_adjst_date DATE;

 -- ansethur  27-FEB-07  R12B Added for Billing Enhancement Project   Start Changes
    l_tldv_tbl          okl_tld_pvt.tldv_tbl_type;
    lx_tldv_tbl         okl_tld_pvt.tldv_tbl_type;

    l_tilv_tbl          okl_txl_ar_inv_lns_pub.tilv_tbl_type;
    lx_tilv_tbl         okl_txl_ar_inv_lns_pub.tilv_tbl_type;
 -- ansethur  27-FEB-07  R12B Added for Billing Enhancement Project  End Changes

    -- MGAAP start 7263041
    CURSOR check_csr(p_chr_id NUMBER) IS
    SELECT A.MULTI_GAAP_YN,
           B.REPORTING_PDT_ID
    FROM   OKL_K_HEADERS A,
           OKL_PRODUCTS B
    WHERE  A.ID = p_chr_id
    AND    A.PDT_ID = B.ID;
    l_multi_gaap_yn okl_k_headers.multi_gaap_yn%TYPE;
    l_reporting_pdt_id okl_products.REPORTING_PDT_ID%TYPE;
    -- MGAAP end 7263041

	-- bug 9191475 .. start
	l_trxnum_tbl      okl_generate_accruals_pvt.trxnum_tbl_type;
	-- bug 9191475 .. end

 BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_call_origin: '|| p_call_origin);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_termination_date: '|| p_termination_date);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_id: '|| p_term_rec.p_contract_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_number: '|| p_term_rec.p_contract_number);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_modifier: '|| p_term_rec.p_contract_modifier);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_control_flag: '|| p_term_rec.p_control_flag);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_type: '|| p_term_rec.p_quote_type);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.id: '||p_tcnv_rec.id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_recycle_yn: '||p_tcnv_rec.tmt_recycle_yn);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.qte_id: '||p_tcnv_rec.qte_id);
    END IF;

    l_msg_count := x_msg_count;
    l_msg_data := x_msg_data;

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

    -- MGAAP start 7263041
    OPEN check_csr(p_term_rec.p_contract_id);
    FETCH check_csr INTO
          l_multi_gaap_yn,
          l_reporting_pdt_id;
    CLOSE check_csr;
    -- MGAAP end 7263041

    -- Full Termination for TER_RELEASE_WO_PURCHASE quote
    IF  p_term_rec.p_quote_type = 'TER_RELEASE_WO_PURCHASE'
    AND p_call_origin = 'FULL'
    THEN
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.get_contract_lines');
       END IF;
       -- get line details from OKL_AM_LEASE_TRMNT_PVT
       OKL_AM_LEASE_TRMNT_PVT.get_contract_lines(
                              p_api_version     => p_api_version,
                              p_init_msg_list   => OKL_API.G_FALSE,
                              x_return_status   => l_return_status,
                              x_msg_count       => l_msg_count,
                              x_msg_data        => l_msg_data,
                              p_term_rec        => p_term_rec,
                              x_klev_tbl        => lx_asset_tbl);
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.get_contract_lines , return status : ' || l_return_status);
       END IF;

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
       THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
       THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- If quote exists then accnting date is quote accept date else sysdate
       IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
       THEN
          l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
          l_quote_eff_date := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;
       ELSE
          l_quote_accpt_date := p_termination_date;
          l_quote_eff_date :=  p_termination_date;
       END IF;

       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_transaction_id');
       END IF;
       okl_am_util_pvt.get_transaction_id (
          p_try_name        => 'CREDIT MEMO',
          x_return_status   => l_return_status,
          x_try_id          => l_cm_try_id);
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_transaction_id , return status : ' || l_return_status);
       END IF;

       IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
       OR NVL (l_cm_try_id, OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM
       THEN
          l_return_status := OKL_API.G_RET_STS_ERROR;
          OKC_API.SET_MESSAGE (
             p_app_name      => G_APP_NAME,
             p_msg_name      => G_INVALID_VALUE,
             p_token1        => G_COL_NAME_TOKEN,
             p_token1_value  => 'Transaction Type');
       END IF;

        -- rmunjulu TNA Handle return status
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


       IF lx_asset_tbl.count > 0
       THEN
          FOR l_counter IN lx_asset_tbl.FIRST..lx_asset_tbl.LAST
          LOOP

            -- rmunjulu TNA Initialize the variables
            l_asset_ref_amt := 0;
            l_taiv_rec := l_empty_taiv_rec;
            l_tilv_rec := l_empty_tilv_rec;

             OPEN l_qte_dtls_csr(p_term_rec.p_quote_id);
             FETCH l_qte_dtls_csr INTO l_taiv_rec.currency_code,
                                       l_taiv_rec.currency_conversion_type,
                                       l_taiv_rec.currency_conversion_rate,
                                       l_taiv_rec.currency_conversion_date;
             CLOSE l_qte_dtls_csr; -- rmunjulu TNA Close the cursor
             OPEN l_ref_asset_amt_csr(p_khr_id => p_term_rec.p_contract_id,
                                      p_kle_id => lx_asset_tbl(l_counter).p_kle_id,
                                      p_date   => l_quote_eff_date);
             FETCH l_ref_asset_amt_csr INTO l_sty_id, l_asset_ref_amt;
             CLOSE l_ref_asset_amt_csr;

             l_taiv_rec.try_id := l_cm_try_id;
             l_taiv_rec.khr_id := p_term_rec.p_contract_id;
             l_taiv_rec.date_invoiced := l_quote_accpt_date;
             l_taiv_rec.date_entered := l_quote_accpt_date;
             l_taiv_rec.amount := l_asset_ref_amt;

             l_taiv_rec.qte_id := p_term_rec.p_quote_id;
             l_taiv_rec.description := p_term_rec.p_quote_type;
             l_taiv_rec.trx_status_code := 'SUBMITTED'; -- RMUNJULU CHANGED 21-NOV-05
             --20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
              l_taiv_rec.legal_entity_id :=OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_term_rec.p_contract_id);
             -- rmunjulu TNA Added this IF
             IF l_asset_ref_amt <> 0 THEN

 --ansethur  27-FEB-2007  Added for R12 B Billing Architecture  Start Changes
 -- Included call to Enhanced Billing API in the place of the calls to Billing Header,Lines and Distributions
             l_taiv_rec.okl_source_billing_trx := 'TERMINATION';
             l_tilv_rec.line_number   := l_counter;
             l_tilv_rec.kle_id        := lx_asset_tbl(l_counter).p_kle_id;
             l_tilv_rec.description   := 'Adjustment for Advanced Rent';
             l_tilv_rec.sty_id        := l_sty_id;
             l_tilv_rec.amount        := l_asset_ref_amt;
             l_tilv_rec.inv_receiv_line_code := 'LINE';

             l_tilv_tbl(0)            := l_tilv_rec; -- Assign the line record in tilv_tbl structure

                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_internal_billing_pvt.create_billing_trx');
                 END IF;
                 okl_internal_billing_pvt.create_billing_trx(p_api_version   => l_api_version,
                                                             p_init_msg_list => p_init_msg_list,
                                                             x_return_status => x_return_status,
                                                             x_msg_count     => x_msg_count,
                                                             x_msg_data      => x_msg_data,
                                                             p_taiv_rec      => l_taiv_rec,
                                                             p_tilv_tbl      => l_tilv_tbl,
                                                             p_tldv_tbl      => l_tldv_tbl,
                                                             x_taiv_rec      => lx_taiv_rec,
                                                             x_tilv_tbl      => lx_tilv_tbl,
                                                             x_tldv_tbl      => lx_tldv_tbl);
                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_internal_billing_pvt.create_billing_trx , return status : ' || x_return_status);
                 END IF;

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

/* --ansethur  23-FEB-2007  commented for R12 B Billing Architecture  Begins

             okl_trx_ar_invoices_pub.insert_trx_ar_invoices (
                    p_api_version   => P_api_version,
                    p_init_msg_list => OKL_API.G_FALSE,
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data,
                    p_taiv_rec      => l_taiv_rec,
                    x_taiv_rec      => lx_taiv_rec);

           -- rmunjulu TNA Handle return status
              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

             l_tilv_rec.line_number   := l_counter;
             l_tilv_rec.kle_id        := lx_asset_tbl(l_counter).p_kle_id;
             l_tilv_rec.description   := 'Adjustment for Advanced Rent';
             l_tilv_rec.sty_id        := l_sty_id;
             l_tilv_rec.amount        := l_asset_ref_amt;
             l_tilv_rec.tai_id        := lx_taiv_rec.id;
             l_tilv_rec.inv_receiv_line_code := 'LINE';

             -- Create Invoice Line
             okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns (
                  p_api_version   => l_api_version,
                  p_init_msg_list => OKL_API.G_FALSE,
                  x_return_status => l_return_status,
                  x_msg_count     => l_msg_count,
                  x_msg_data      => l_msg_data,
                  p_tilv_rec      => l_tilv_rec,
                  x_tilv_rec      => lx_tilv_rec);

           -- rmunjulu TNA Handle return status
              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

             -- Bug 4177025 PAGARG 10-Feb-2005 Fix start
             -- Added the call to create accounting distributions for the invoice lines
             IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
                l_bpd_acc_rec.id            := lx_tilv_rec.id;
                l_bpd_acc_rec.source_table  := 'OKL_TXL_AR_INV_LNS_B';

                -- Create Accounting Distribution
                okl_acc_call_pub.create_acc_trans(
                        p_api_version   => l_api_version,
                        p_init_msg_list => OKL_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        p_bpd_acc_rec   => l_bpd_acc_rec);

                -- rmunjulu Bug 4177025 Handle Return status properly
                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

             END IF;

             -- Bug 4177025 PAGARG 10-Feb-2005 Fix end
 --ansethur  27-FEB-2007  commented for R12 B Billing Architecture Ends
*/
 --ansethur  27-FEB-2007  Added for R12 B Billing Architecture  End Changes

             END IF; -- rmunjulu TNA End of New IF to check amt there for invoicing
          END LOOP;
       END IF; -- asset table count

       --Bug# 3999921 14-Dec-2004 PAGARG Fix Start
       --Instead of calling create_accrual_adjustments, call get_accrual_adjustments
       --and generate accruals.
       --Populate lines table with id of contract top line for fee and sold service
       l_counter := 0;

       -- rmunjulu TNA Get the FEE and SERVICE TOP lines
       FOR p_chr_lines_rec in p_chr_lines_csr(p_term_rec.p_contract_id)
       LOOP
          l_counter := l_counter + 1;
          l_line_id_tbl(l_counter).id := p_chr_lines_rec.id;
       END LOOP;

       -- rmunjulu 4769094 Based on CHK_ACCRUAL_PREVIOUS_MNTH_YN setup check accruals till quote eff date OR previous month last date
       OPEN  check_accrual_previous_csr;
       FETCH check_accrual_previous_csr INTO l_accrual_previous_mnth_yn;
       CLOSE check_accrual_previous_csr;

       IF nvl(l_accrual_previous_mnth_yn,'N') = 'N' THEN -- rmunjulu 4769094 continue with current adjustment date as quote effective date
       l_accrual_adjst_date :=  l_quote_eff_date;
    ELSE -- rmunjulu 4769094 new check adjustment date is quote eff dates previous month last date
       l_accrual_adjst_date :=  LAST_DAY(TRUNC(l_quote_eff_date, 'MONTH')-1);
    END IF;

       -- rmunjulu TNA Get the accrual adjustment streams and amounts for FEE and SERVICE lines
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_ACCRUAL_SEC_PVT.Get_Accrual_Adjustment');
       END IF;

       OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS; -- MGAAP 7263041
       OKL_ACCRUAL_SEC_PVT.Get_Accrual_Adjustment(
             p_api_version     => p_api_version,
             p_init_msg_list   => OKL_API.G_FALSE,
             x_return_status   => l_return_status,
             x_msg_count       => l_msg_count,
             x_msg_data        => l_msg_data,
             p_contract_id     => p_term_rec.p_contract_id,
             p_line_id_tbl     => l_line_id_tbl,
             p_adjustment_date => l_accrual_adjst_date, -- rmunjulu 4769094
             x_accrual_adjustment_tbl => lx_accrual_adjustment_tbl);
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_ACCRUAL_SEC_PVT.Get_Accrual_Adjustment , return status : ' || l_return_status);
       END IF;

        -- rmunjulu TNA Handle return status
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

       -- rmunjulu TNA check if table has value before looping thru table and calling the other API
       IF lx_accrual_adjustment_tbl.COUNT > 0 THEN

          -- rmunjulu TNA Brought the below code into this IF
/* -- rmunjulu TNA Not needed
          okl_am_util_pvt.get_transaction_id (
             p_try_name        => 'TERMINATION',
             x_return_status   => l_return_status,
             x_try_id          => l_trmnt_try_id);

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
          OR NVL (l_trmnt_try_id, OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM THEN

             l_return_status := OKL_API.G_RET_STS_ERROR;

             OKC_API.SET_MESSAGE (
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_INVALID_VALUE,
                p_token1        => G_COL_NAME_TOKEN,
                p_token1_value  => 'Transaction Type');
          END IF;

          -- rmunjulu TNA Handle return status
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
*/
          --Populate online accrual rec type -- rmunjulu TNA set all the values for p_accrual_rec at one place
          l_accrual_rec.contract_id := p_term_rec.p_contract_id;
          l_accrual_rec.accrual_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_gl_date => l_quote_accpt_date);
          l_accrual_rec.source_trx_id := p_tcnv_rec.id; -- rmunjulu TNA Changed
          l_accrual_rec.source_trx_type := 'TCN';
          --l_accrual_rec.ignore_accrual_rule_yn := 'Y'; -- rmunjulu TNA Additional changes -- Removed
          --l_accrual_rec.stream_source_value := 'PROVIDED'; -- rmunjulu TNA Additional changes -- Removed

          -- rmunjulu TNA Set the p_stream_tbl values
          FOR l_counter IN lx_accrual_adjustment_tbl.FIRST..lx_accrual_adjustment_tbl.LAST LOOP

   l_stream_tbl(l_counter).stream_type_id := lx_accrual_adjustment_tbl(l_counter).sty_id;
            l_stream_tbl(l_counter).stream_amount  := lx_accrual_adjustment_tbl(l_counter).amount;
            l_stream_tbl(l_counter).kle_id         := lx_accrual_adjustment_tbl(l_counter).line_id;
          END LOOP;

          -- rmunjulu TNA Create the accounting transactions for the accrual adjustments
          -- rmunjulu TNA Additional Changes -- Changed the procedure name
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_GENERATE_ACCRUALS_PVT.adjust_accruals');
          END IF;
          OKL_GENERATE_ACCRUALS_PVT.adjust_accruals(
             p_api_version     => p_api_version,
             p_init_msg_list   => OKL_API.G_FALSE,
             x_return_status   => l_return_status,
             x_msg_count       => l_msg_count,
             x_msg_data        => l_msg_data,
             --x_trx_number      => lx_trx_number,-- bug 9191475
			 x_trx_tbl         => l_trxnum_tbl, -- bug 9191475
             p_accrual_rec     => l_accrual_rec,
             p_stream_tbl      => l_stream_tbl);
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_GENERATE_ACCRUALS_PVT.adjust_accruals , return status : ' || l_return_status);
          END IF;

         -- rmunjulu TNA Handle return status
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

       --14-Dec-2004 Bug# 3999921 PAGARG Fix end
       END IF; -- Check for tbl has records

       -- MGAAP start 7263041
       IF (l_multi_gaap_yn = 'Y') THEN
         IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_ACCRUAL_SEC_PVT.Get_Accrual_Adjustment for SECONDARY');
         END IF;

         OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS; -- MGAAP 7263041

         OKL_ACCRUAL_SEC_PVT.Get_Accrual_Adjustment(
               p_api_version     => p_api_version,
               p_init_msg_list   => OKL_API.G_FALSE,
               x_return_status   => l_return_status,
               x_msg_count       => l_msg_count,
               x_msg_data        => l_msg_data,
               p_contract_id     => p_term_rec.p_contract_id,
               p_line_id_tbl     => l_line_id_tbl,
               p_adjustment_date => l_accrual_adjst_date, -- rmunjulu 4769094
               x_accrual_adjustment_tbl => lx_accrual_adjustment_tbl,
               p_product_id      => l_reporting_pdt_id); -- MGAAP 7263041

         OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS; -- MGAAP 7263041

         IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_ACCRUAL_SEC_PVT.Get_Accrual_Adjustment , return status : ' || l_return_status);
         END IF;

          -- rmunjulu TNA Handle return status
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

         -- rmunjulu TNA check if table has value before looping thru table and calling the other API
         IF lx_accrual_adjustment_tbl.COUNT > 0 THEN

            --Populate online accrual rec type -- rmunjulu TNA set all the values for p_accrual_rec at one place
            l_accrual_rec.contract_id := p_term_rec.p_contract_id;
            l_accrual_rec.accrual_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_gl_date => l_quote_accpt_date);
            l_accrual_rec.source_trx_id := p_tcnv_rec.id; -- rmunjulu TNA Changed
            l_accrual_rec.source_trx_type := 'TCN';
            --l_accrual_rec.ignore_accrual_rule_yn := 'Y'; -- rmunjulu TNA Additional changes -- Removed
            --l_accrual_rec.stream_source_value := 'PROVIDED'; -- rmunjulu TNA Additional changes -- Removed
            --l_accrual_rec.trx_number := lx_trx_number; -- MGAAP 726304 --commented for 9191475

            -- rmunjulu TNA Set the p_stream_tbl values
            FOR l_counter IN lx_accrual_adjustment_tbl.FIRST..lx_accrual_adjustment_tbl.LAST LOOP

     l_stream_tbl(l_counter).stream_type_id := lx_accrual_adjustment_tbl(l_counter).sty_id;
              l_stream_tbl(l_counter).stream_amount  := lx_accrual_adjustment_tbl(l_counter).amount;
              l_stream_tbl(l_counter).kle_id         := lx_accrual_adjustment_tbl(l_counter).line_id;
            END LOOP;

            -- rmunjulu TNA Create the accounting transactions for the accrual adjustments
            -- rmunjulu TNA Additional Changes -- Changed the procedure name
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_GENERATE_ACCRUALS_PVT.adjust_accruals');
            END IF;
            OKL_GENERATE_ACCRUALS_PVT.adjust_accruals(
               p_api_version     => p_api_version,
               p_init_msg_list   => OKL_API.G_FALSE,
               x_return_status   => l_return_status,
               x_msg_count       => l_msg_count,
               x_msg_data        => l_msg_data,
               --x_trx_number      => lx_trx_number, --bug 9191475
			   x_trx_tbl         => l_trxnum_tbl, -- bug 9191475
               p_accrual_rec     => l_accrual_rec,
               p_stream_tbl      => l_stream_tbl,
               p_representation_type      => 'SECONDARY'); -- MGAAP 7263041
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_GENERATE_ACCRUALS_PVT.adjust_accruals , return status : ' || l_return_status);
            END IF;

           -- rmunjulu TNA Handle return status
           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

         --14-Dec-2004 Bug# 3999921 PAGARG Fix end
         END IF; -- Check for tbl has records

       END IF;
       -- MGAAP end 7263041

    END IF;

    -- rmunjulu TNA Set the return status properly
    x_return_status := l_return_status;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;
      -- rmunjulu TNA Close cursors in exception block
      IF l_qte_dtls_csr%ISOPEN THEN
         CLOSE l_qte_dtls_csr;
      END IF;
      IF l_ref_asset_amt_csr%ISOPEN THEN
         CLOSE l_ref_asset_amt_csr;
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
      -- rmunjulu TNA Close cursors in exception block
      IF l_qte_dtls_csr%ISOPEN THEN
         CLOSE l_qte_dtls_csr;
      END IF;
      IF l_ref_asset_amt_csr%ISOPEN THEN
         CLOSE l_ref_asset_amt_csr;
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
      -- rmunjulu TNA Close cursors in exception block
      IF l_qte_dtls_csr%ISOPEN THEN
         CLOSE l_qte_dtls_csr;
      END IF;
      IF l_ref_asset_amt_csr%ISOPEN THEN
         CLOSE l_ref_asset_amt_csr;
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
  END process_adjustments;

  -- Start of comments
  -- Procedure Name : process_loan_refunds
  -- Desciption     : Do refund of loans (additional amount billed but not paid above outstanding balance) if expiration
  -- Business Rules :
  -- Parameters     :
  -- Version     : 1.0
  -- History        : rmunjulu LOANS_ENHANCEMENTS
  -- End of comments
  PROCEDURE process_loan_refunds(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_tcnv_rec                    IN  tcnv_rec_type,
           p_call_origin                 IN  VARCHAR2 DEFAULT NULL,
           p_termination_date            IN  DATE) IS

     l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_loan_refunds';
     is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
     is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
     is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
     l_api_name         CONSTANT VARCHAR2(30) := 'process_loan_refunds';
     l_api_version      CONSTANT NUMBER := 1;
     l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_msg_count        NUMBER;
     l_msg_data         VARCHAR2(2000);
     l_taiv_rec         taiv_rec_type;
     lx_taiv_rec        taiv_rec_type;
     l_tilv_rec         tilv_rec_type;
     lx_tilv_rec        tilv_rec_type;
     l_cm_try_id        NUMBER;
     l_counter          NUMBER := 1;
     l_quote_accpt_date DATE;
     l_quote_eff_date   DATE;
     l_sty_id           NUMBER;
     l_bpd_acc_rec      OKL_ACC_CALL_PUB.bpd_acc_rec_type;
     l_currency_code    OKC_K_HEADERS_B.currency_code%TYPE;
     l_loan_refund_amount  NUMBER;
     l_functional_currency_code VARCHAR2(15);
     l_contract_currency_code VARCHAR2(15);
     l_currency_conversion_type VARCHAR2(30);
     l_currency_conversion_rate NUMBER;
     l_currency_conversion_date DATE;
     l_converted_amount NUMBER;

     -- Since we do not use the amount or converted amount
     -- set a hardcoded value for the amount (and pass to to
     -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
     -- conversion values )
     l_hard_coded_amount NUMBER := 100;

 -- ansethur  23-FEB-07  R12B Added for Billing Enhancement Project   Start Changes
      l_tldv_tbl          okl_tld_pvt.tldv_tbl_type;
      lx_tldv_tbl         okl_tld_pvt.tldv_tbl_type;

      l_tilv_tbl          okl_txl_ar_inv_lns_pub.tilv_tbl_type;
      lx_tilv_tbl         okl_txl_ar_inv_lns_pub.tilv_tbl_type;
 -- ansethur  23-FEB-07  R12B Added for Billing Enhancement Project  End Changes

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_call_origin: '|| p_call_origin);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_termination_date: '|| p_termination_date);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_id: '|| p_term_rec.p_contract_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_number: '|| p_term_rec.p_contract_number);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_modifier: '|| p_term_rec.p_contract_modifier);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: '|| p_term_rec.p_quote_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_control_flag: '|| p_term_rec.p_control_flag);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_type: '|| p_term_rec.p_quote_type);
    END IF;

    l_msg_count := x_msg_count;
    l_msg_data := x_msg_data;

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

    -- expiration
    IF  nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'N' THEN

       -- If quote exists then accnting date is quote accept date else sysdate
       IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
       THEN
          l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
          l_quote_eff_date := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;
       ELSE
          l_quote_accpt_date := p_termination_date;
          l_quote_eff_date :=  p_termination_date;
       END IF;

       -- get excess loan payment amount
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_excess_loan_payment');
       END IF;
       l_loan_refund_amount := OKL_AM_UTIL_PVT.get_excess_loan_payment(
                                     x_return_status    => l_return_status,
                                     p_khr_id           => p_term_rec.p_contract_id);
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.get_excess_loan_payment , return status : ' || l_return_status);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_loan_refund_amount : ' || l_loan_refund_amount);
       END IF;

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       l_loan_refund_amount := nvl(l_loan_refund_amount,0) * -1;

       IF l_loan_refund_amount <> 0 THEN

            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_transaction_id');
            END IF;
            OKL_AM_UTIL_PVT.get_transaction_id (
               p_try_name        => 'CREDIT MEMO',
               x_return_status   => l_return_status,
               x_try_id          => l_cm_try_id);
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.get_transaction_id , return status : ' || l_return_status);
            END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
            OR NVL (l_cm_try_id, OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM
            THEN

              OKC_API.SET_MESSAGE (
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_INVALID_VALUE,
                p_token1        => G_COL_NAME_TOKEN,
                p_token1_value  => 'Transaction Type');

               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             END IF;

             l_functional_currency_code := OKL_AM_UTIL_PVT.get_functional_currency();

              IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_ACCOUNTING_UTIL.convert_to_functional_currency');
              END IF;
             -- Get the currency conversion details from ACCOUNTING_Util
             OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id                   => p_term_rec.p_contract_id,
                     p_to_currency              => l_functional_currency_code,
                     p_transaction_date         => l_quote_accpt_date,
                     p_amount                   => l_hard_coded_amount,
                     x_return_status            => l_return_status,
                     x_contract_currency        => l_contract_currency_code,
                     x_currency_conversion_type => l_currency_conversion_type,
                     x_currency_conversion_rate => l_currency_conversion_rate,
                     x_currency_conversion_date => l_currency_conversion_date,
                     x_converted_amount         => l_converted_amount);
              IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_ACCOUNTING_UTIL.convert_to_functional_currency , return status : ' || l_return_status);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_contract_currency_code : ' || l_contract_currency_code);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_currency_conversion_type : ' || l_currency_conversion_type);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_currency_conversion_rate : ' || l_currency_conversion_rate);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_currency_conversion_date : ' || l_currency_conversion_date);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_converted_amount : ' || l_converted_amount);
              END IF;

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

              IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_streams_util.get_dependent_stream_type');
              END IF;
            --Bug 6266134 veramach start
            okl_streams_util.get_dependent_stream_type(
              p_khr_id                     => p_term_rec.p_contract_id,
              p_primary_sty_purpose        => 'RENT',
              p_dependent_sty_purpose      => 'EXCESS_LOAN_PAYMENT_PAID',
              x_return_status              => l_return_status,
              x_dependent_sty_id           => l_sty_id
            );
            --Bug 6266134 veramach end
              IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_streams_util.get_dependent_stream_type , return status : ' || l_return_status);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_sty_id : ' || l_sty_id);
              END IF;

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

       l_taiv_rec.currency_code := l_contract_currency_code;
       l_taiv_rec.currency_conversion_type := l_currency_conversion_type;
       l_taiv_rec.currency_conversion_rate := l_currency_conversion_rate;
       l_taiv_rec.currency_conversion_date := l_currency_conversion_date;
             l_taiv_rec.try_id := l_cm_try_id;
             l_taiv_rec.khr_id := p_term_rec.p_contract_id;
             l_taiv_rec.date_invoiced := l_quote_accpt_date;
             l_taiv_rec.date_entered := l_quote_accpt_date;
             l_taiv_rec.amount := l_loan_refund_amount;
             l_taiv_rec.description := 'Loan Refund Amount on Expiration';
             l_taiv_rec.trx_status_code := 'SUBMITTED'; -- RMUNJULU CHANGED 21-NOV-05

 --20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
             l_taiv_rec.legal_entity_id :=OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_term_rec.p_contract_id);

 --ansethur  27-FEB-2007  Added for R12 B Billing Architecture  Start Changes
 --Included call to Enhanced Billing API in the place of the calls to Billing Header,Lines and Distributions
             l_taiv_rec.okl_source_billing_trx := 'TERMINATION';
             l_tilv_rec.line_number   := l_counter;
             l_tilv_rec.description   := 'Loan Refund Amount on Expiration';
             l_tilv_rec.sty_id        := l_sty_id;
             l_tilv_rec.amount        := l_loan_refund_amount;
             l_tilv_rec.inv_receiv_line_code := 'LINE';

             l_tilv_tbl(0)            := l_tilv_rec; -- Assign the line record in tilv_tbl structure

              IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_internal_billing_pvt.create_billing_trx');
              END IF;
                 okl_internal_billing_pvt.create_billing_trx(p_api_version   => l_api_version,
                                                             p_init_msg_list => p_init_msg_list,
                                                             x_return_status => x_return_status,
                                                             x_msg_count     => x_msg_count,
                                                             x_msg_data      => x_msg_data,
                                                             p_taiv_rec      => l_taiv_rec,
                                                             p_tilv_tbl      => l_tilv_tbl,
                                                             p_tldv_tbl      => l_tldv_tbl,
                                                             x_taiv_rec      => lx_taiv_rec,
                                                             x_tilv_tbl      => lx_tilv_tbl,
                                                             x_tldv_tbl      => lx_tldv_tbl);
              IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_internal_billing_pvt.create_billing_trx , return status : ' || x_return_status);
              END IF;

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

/*  --ansethur  27-FEB-2007  commented for R12 B Billing Architecture  Begins
             -- create invoice header
             OKL_TRX_AR_INVOICES_PUB.insert_trx_ar_invoices (
                    p_api_version   => P_api_version,
                    p_init_msg_list => OKL_API.G_FALSE,
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data,
                    p_taiv_rec      => l_taiv_rec,
                    x_taiv_rec      => lx_taiv_rec);

              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

             l_tilv_rec.line_number   := l_counter;
             l_tilv_rec.description   := 'Loan Refund Amount on Expiration';
             l_tilv_rec.sty_id        := l_sty_id;
             l_tilv_rec.amount        := l_loan_refund_amount;
             l_tilv_rec.tai_id        := lx_taiv_rec.id;
             l_tilv_rec.inv_receiv_line_code := 'LINE';

             -- Create Invoice Line
             OKL_TXL_AR_INV_LNS_PUB.insert_txl_ar_inv_lns (
                  p_api_version   => l_api_version,
                  p_init_msg_list => OKL_API.G_FALSE,
                  x_return_status => l_return_status,
                  x_msg_count     => l_msg_count,
                  x_msg_data      => l_msg_data,
                  p_tilv_rec      => l_tilv_rec,
                  x_tilv_rec      => lx_tilv_rec);

              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

             l_bpd_acc_rec.id            := lx_tilv_rec.id;
             l_bpd_acc_rec.source_table  := 'OKL_TXL_AR_INV_LNS_B';

             -- Create Accounting Distribution
             OKL_ACC_CALL_PUB.create_acc_trans(
                        p_api_version   => l_api_version,
                        p_init_msg_list => OKL_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        p_bpd_acc_rec   => l_bpd_acc_rec);

              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

--ansethur  23-FEB-2007  commented for R12 B Billing Architecture  Ends
*/
 --ansethur  27-FEB-2007  Added for R12 B Billing Architecture  End Changes
          END IF;
       END IF;

       x_return_status := l_return_status;

       -- end the transaction
       OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
       IF (is_debug_procedure_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name,'End(-)');
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
  END process_loan_refunds;

END OKL_AM_LEASE_LOAN_TRMNT_PVT;

/
