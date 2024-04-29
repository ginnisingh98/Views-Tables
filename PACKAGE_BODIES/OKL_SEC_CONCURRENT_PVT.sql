--------------------------------------------------------
--  DDL for Package Body OKL_SEC_CONCURRENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SEC_CONCURRENT_PVT" AS
/* $Header: OKLRSZOB.pls 120.8 2007/12/21 14:11:06 kthiruva noship $ */
----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------

 G_POC_STS_NEW          CONSTANT VARCHAR2(10) := Okl_Pool_Pvt.G_POC_STS_NEW;
 G_POC_STS_ACTIVE       CONSTANT VARCHAR2(10) := Okl_Pool_Pvt.G_POC_STS_ACTIVE;
 G_POC_STS_INACTIVE     CONSTANT VARCHAR2(10) := Okl_Pool_Pvt.G_POC_STS_INACTIVE;

 G_BUYBACK_AGREEMENT_HEAD    CONSTANT VARCHAR2(30) := 'OKL_BUYBACK_AGREEMENT';

 G_SET_OF_BOOKS              CONSTANT VARCHAR2(30) := 'OKL_SET_OF_BOOKS';
 G_OPERATING_UNIT            CONSTANT VARCHAR2(30) := 'OKL_OPERATING_UNIT';

 G_INVESTOR_AGREEMENT_NUMBER CONSTANT VARCHAR2(30) := 'OKL_INVESTOR_AGREEMENT_NUMBER';
 G_POOL_NUMBER               CONSTANT VARCHAR2(15) := 'OKL_POOL_NUMBER';
 G_BUYBACK_DATE              CONSTANT VARCHAR2(30) := 'OKL_BUYBACK_DATE';

 G_CURRENCY                  CONSTANT VARCHAR2(20) := 'OKL_AGN_RPT_CURRENCY';
 G_PROGRAM_RUN_DATE          CONSTANT VARCHAR2(30) := 'OKL_PROGRAM_RUN_DATE';

 G_DETAILS                   CONSTANT VARCHAR2(15) := 'OKL_DETAILS';
 G_ROW_NUMBER                CONSTANT VARCHAR2(14) := 'OKL_ROW_NUMBER';
 G_CONTRACT_NUMBER           CONSTANT VARCHAR2(25) := 'OKL_GLP_RPT_CTR_NUM_TITLE';
 G_ASSET_NUMBER              CONSTANT VARCHAR2(16) := 'OKL_ASSET_NUMBER';
 G_INVESTOR                  CONSTANT VARCHAR2(15) := 'OKL_INVESTOR';
 G_STREAM_TYPE_SUBCLASS      CONSTANT VARCHAR2(30) := 'OKL_STREAM_TYPE_SUBCLASS';
 G_STREAMS_AMOUNT            CONSTANT VARCHAR2(20) := 'OKL_STREAMS_AMOUNT';
 G_BUYBACK_AMOUNT            CONSTANT VARCHAR2(20) := 'OKL_BUYBACK_AMOUNT';

 G_ERRORS                    CONSTANT VARCHAR2(30) := 'OKL_POOL_CLEANUP_ERRORS';
 G_NONE                      CONSTANT VARCHAR2(30) := 'OKL_NONE';

----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------
  PROCEDURE get_error_message(p_all_message OUT nocopy error_message_type)
  IS
    l_msg_text VARCHAR2(2000);
    l_msg_count NUMBER ;
  BEGIN
    l_msg_count := fnd_msg_pub.count_msg;
    FOR i IN 1..l_msg_count
	LOOP
      fnd_msg_pub.get
        (p_data => p_all_message(i),
        p_msg_index_out => l_msg_count,
	    p_encoded => fnd_api.g_false,
	    p_msg_index => fnd_msg_pub.g_next
        );
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
	  NULL;
  END get_error_message;

  -- mvasudev
  FUNCTION get_message(p_current_api IN VARCHAR2
				      ,p_called_api IN VARCHAR2
                      ,p_msg_token IN VARCHAR2)
  RETURN VARCHAR2
  IS

  BEGIN
    RETURN (G_PKG_NAME || '.' || p_current_api || '::' ||
	        p_called_api || ':: ' ||
	       FND_MESSAGE.GET_STRING(G_APP_NAME,p_msg_token));

  END get_message;


 ----------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : BUYBACK_AGREEMENT
 -- Description     : This is a wrapper procedure for concurrent program to call private API
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------

 PROCEDURE buyback_agreement(x_errbuf OUT  NOCOPY VARCHAR2
                            ,x_retcode OUT NOCOPY NUMBER
                            ,p_khr_id IN VARCHAR2)
 IS

  -- Set of Books
  CURSOR l_okl_set_of_books_csr
  IS
  SELECT okls.set_of_books_id set_of_books_id
        ,glsb.name            set_of_books_name
  FROM   GL_LEDGERS_PUBLIC_V  glsb
        ,OKL_SYS_ACCT_OPTS okls
  WHERE  glsb.ledger_id =  okls.set_of_books_id;

  -- Operating Unit
  CURSOR l_okl_operating_unit_csr
  IS
  SELECT name
  FROM   hr_operating_units
  WHERE  organization_id = mo_global.get_current_org_id();

  -- Agreement Number, Pool Number
  CURSOR l_okl_pol_khr_csr(p_khr_id IN NUMBER)
  IS
  SELECT chrb.contract_number agreement_number
        ,polb.pool_number pool_number
	,polb.currency_code currency_code
  FROM  okl_pools polb
       ,okc_k_headers_b chrb
  WHERE polb.khr_id = chrb.id
  AND   polb.khr_id = p_khr_id;


  -- Pool Contents for this Agreement
  CURSOR l_okl_pocs_csr(p_khr_id IN NUMBER,p_effective_date DATE)
  IS
  SELECT pocb.id id
        ,chrb.contract_number contract_number
		,clet.name asset_number
		,styv.name stream_type_name
  FROM   okl_pool_contents pocb
        ,okl_pools polb
		,okc_k_headers_b chrb
		,okc_k_lines_tl clet
		,okl_strm_type_v styv
  WHERE  pocb.pol_id = polb.id
  AND    polb.khr_id = p_khr_id
  AND    pocb.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE
  AND    pocb.streams_to_date > p_effective_date
  AND    pocb.khr_id = chrb.id
  AND    pocb.kle_id = clet.id
  AND    pocb.sty_id = styv.id;
  --Fixed Bug #5484903
  CURSOR l_okl_investor_names_csr(p_id IN NUMBER)
  IS
  SELECT okxv.name
        ,chrb.currency_code
  FROM   OKX_PARTIES_V okxv
        ,okc_k_headers_all_b chrb
        ,okc_k_lines_b cleb
        ,okc_k_party_roles_b cplb
  WHERE  cleb.id = p_id
  AND    cleb.dnz_chr_id = chrb.id
  AND    cplb.cle_id = cleb.id
  AND    cplb.dnz_chr_id = cleb.dnz_chr_id
  AND    okxv.id1 = cplb.object1_id1
  AND    okxv.id2 = cplb.object1_id2;

  -- All Lease Contracts associated to this Agreement
  CURSOR l_okl_dnz_chrs_csr (p_khr_id IN NUMBER)
  IS
  SELECT DISTINCT
         pocb.khr_id dnz_chr_id
  FROM   okl_pool_contents pocb
        ,okl_pools polb
  WHERE  pocb.pol_id = polb.id
  AND    polb.khr_id = p_khr_id
  AND    pocb.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE;

  -- Cursor
  CURSOR l_okl_pol_csr
  IS
  SELECT DISTINCT
         pocb.pol_id
        ,pocb.khr_id
		,styb.stream_type_subclass
  FROM   okl_pool_contents pocb
        ,okl_pools polb
        ,okl_strm_type_b styb
  WHERE  pocb.pol_id = polb.id
  AND    polb.khr_id = p_khr_id
  AND    pocb.sty_id = styb.id
  AND    pocb.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE --Added by VARANGAN -Pool Contents Impact(Bug#6658065)
  ORDER BY pocb.khr_id,styb.stream_type_subclass;


  -- Cursor
  CURSOR l_okl_poc_csr(p_pol_id IN NUMBER)
  IS
  SELECT pol_id
        ,khr_id
		,contract_number
		,sty_subclass_code
		,sty_subclass
        ,streams_amount
		,currency_code
  FROM   okl_sec_buyback_streams_uv
  WHERE  pol_id = p_pol_id;


  l_api_name          CONSTANT VARCHAR2(40) := 'BUYBACK_AGREEMENT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  p_api_version       CONSTANT NUMBER 	    := 1.0;
  l_init_msg_list     VARCHAR2(1) := 'T';

  l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_error_msg_rec     Error_message_Type;

  lp_effective_date DATE := SYSDATE;

  -- report related fields
  l_row_num_len      NUMBER := 6;
  l_contract_num_len NUMBER := 30;
/*  l_asset_num_len    NUMBER := 15;
  l_investor_len     NUMBER := 40;
  l_sty_name_len     NUMBER := 15;*/
  l_sty_subclass_len     NUMBER := 25;
  l_amount_len       NUMBER := 15;
  l_max_len          NUMBER := 120;
  l_prompt_len       NUMBER := 35;

  l_content          VARCHAR2(1000);
  l_header_len       NUMBER;
  l_filler           VARCHAR2(5) := RPAD(' ',5,' ');
  l_total_rec_count    NUMBER := 0;
  l_buyback_amount NUMBER;

 BEGIN

    x_retcode := 0;
    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => l_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'OKL_API.START_ACTIVITY',G_UNEXPECTED_ERROR));
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'OKL_API.START_ACTIVITY',G_EXPECTED_ERROR));
      RAISE G_EXCEPTION_ERROR;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'OKL_API.START_ACTIVITY',G_CONFIRM_PROCESS));
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    -- Printing the values in the log file.

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_khr_id : ' || p_khr_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_START));

    -- Header
    l_content :=     FND_MESSAGE.GET_STRING(G_APP_NAME,G_BUYBACK_AGREEMENT_HEAD);
	l_header_len := LENGTH(l_content);
	l_content :=    RPAD(LPAD(l_content,l_max_len/2),l_max_len/2);    -- center align header
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

	l_content := RPAD('=',l_header_len,'=');                           -- underline header
	l_content := RPAD(LPAD(l_content,l_max_len/2),l_max_len/2,'=');    -- center align
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

	-- Set of Books, Operating Unit
	FOR l_okl_set_of_books_rec IN l_okl_set_of_books_csr
	LOOP
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_SET_OF_BOOKS),l_prompt_len) || ' : ' || l_okl_set_of_books_rec.set_of_books_name);
	END LOOP;
	FOR l_okl_operating_unit_rec IN l_okl_operating_unit_csr
	LOOP
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_OPERATING_UNIT),l_prompt_len) || ' : ' || l_okl_operating_unit_rec.name);
	END LOOP;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

	-- Investor Agreement Number, Pool Number, Buyback Date
	FOR l_okl_pol_khr_rec IN l_okl_pol_khr_csr(p_khr_id)
	LOOP
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_INVESTOR_AGREEMENT_NUMBER),l_prompt_len) || ' : ' || l_okl_pol_khr_rec.agreement_number);
	  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_POOL_NUMBER),l_prompt_len) || ' : ' || l_okl_pol_khr_rec.pool_number);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_BUYBACK_DATE),l_prompt_len) || ' : ' || lp_effective_date);

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_CURRENCY),l_prompt_len) || ' : ' || l_okl_pol_khr_rec.currency_code);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_PROGRAM_RUN_DATE),l_prompt_len) || ' : ' || SYSDATE);
	END LOOP;

	-- sub head (Details)
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_DETAILS);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=',LENGTH(l_content),'='));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');



	l_total_rec_count := 0;
	FOR l_okl_pol_rec IN l_okl_pol_csr
	LOOP
	    FOR l_okl_poc_rec IN l_okl_poc_csr(l_okl_pol_rec.pol_id)
		LOOP
				l_total_rec_count := l_total_rec_count + 1;
				IF l_total_rec_count = 1 THEN
					l_content :=    RPAD('-',l_row_num_len-1,'-') || ' '
					             || RPAD('-',l_contract_num_len-1,'-') || ' '
								 || RPAD('-',l_sty_subclass_len-1,'-') || ' '
								 || RPAD('-',l_amount_len,'-') || ' '
								 || RPAD('-',l_amount_len,'-');

				    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

				    l_content :=    RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_ROW_NUMBER),l_row_num_len-1) || ' '
					                || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_CONTRACT_NUMBER),l_contract_num_len-1) || ' '
				                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAM_TYPE_SUBCLASS),l_sty_subclass_len-1) || ' '
				                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAMS_AMOUNT),l_amount_len) || ' '
				                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_BUYBACK_AMOUNT),l_amount_len);

				     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

					l_content :=    RPAD('-',l_row_num_len-1,'-') || ' '
					             || RPAD('-',l_contract_num_len-1,'-') || ' '
								 || RPAD('-',l_sty_subclass_len-1,'-') || ' '
								 || RPAD('-',l_amount_len,'-') || ' '
								 || RPAD('-',l_amount_len,'-');

				    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

				END IF; -- l_total_rec_count

                Okl_Securitization_Pvt.calculate_buyback_amount(p_api_version         => l_api_version
                                                              ,p_init_msg_list       => l_init_msg_list
                                                              ,x_return_status       => l_return_status
                                                              ,x_msg_count           => l_msg_count
                                                              ,x_msg_data            => l_msg_data
                                                              ,p_khr_id              => l_okl_poc_rec.khr_id
                                                              ,p_pol_id              => l_okl_poc_rec.pol_id
															  ,p_stream_type_subclass => l_okl_poc_rec.sty_subclass_code
															  ,x_buyback_amount       => l_buyback_amount);



    			 l_content :=    RPAD(l_total_rec_count,l_row_num_len)
                          || RPAD(l_okl_poc_rec.contract_number ,l_contract_num_len)
                          || RPAD(l_okl_poc_rec.sty_subclass ,l_sty_subclass_len)
                          || LPAD(okl_accounting_util.format_amount(l_okl_poc_rec.streams_amount,l_okl_poc_rec.currency_code),l_amount_len)
                          || LPAD(okl_accounting_util.format_amount(l_buyback_amount,l_okl_poc_rec.currency_code),l_amount_len);

			    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

				l_buyback_amount := NULL;

                Okl_Securitization_Pvt.buyback_pool_contents(p_api_version         => l_api_version
                                                              ,p_init_msg_list       => l_init_msg_list
                                                              ,x_return_status       => l_return_status
                                                              ,x_msg_count           => l_msg_count
                                                              ,x_msg_data            => l_msg_data
                                                              ,p_khr_id              => l_okl_poc_rec.khr_id
                                                              ,p_pol_id              => l_okl_poc_rec.pol_id
															  ,p_stream_type_subclass => l_okl_poc_rec.sty_subclass_code
                                                              ,p_effective_date      => lp_effective_date);

            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Securitization_Pvt.buyback_pool_contents',G_UNEXPECTED_ERROR));
              RAISE G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Securitization_Pvt.buyback_pool_contents',G_EXPECTED_ERROR));
              RAISE G_EXCEPTION_ERROR;
            END IF;


		 END LOOP; -- l_okl_poc_csr
	END LOOP; -- l_okl_pol_csr
	/*
	FOR l_okl_poc_rec IN l_okl_pocs_csr(p_khr_id,lp_effective_date)
	LOOP

                Okl_Securitization_Pvt.buyback_investor_shares(p_api_version         => l_api_version
                                                              ,p_init_msg_list       => l_init_msg_list
                                                              ,x_return_status       => l_return_status
                                                              ,x_msg_count           => l_msg_count
                                                              ,x_msg_data            => l_msg_data
                                                              ,p_poc_id              => l_okl_poc_rec.id
                                                              ,p_effective_date      => lp_effective_date
					                                          ,x_investor_shares_tbl => lx_investor_shares_tbl);

            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Securitization_Pvt.BUYBACK_POOL_CONTENT',G_UNEXPECTED_ERROR));
              RAISE G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Securitization_Pvt.BUYBACK_POOL_CONTENT',G_EXPECTED_ERROR));
              RAISE G_EXCEPTION_ERROR;
            END IF;

           FOR l_row_count IN 1..lx_investor_shares_tbl.COUNT
           LOOP
		      -- Print Table Header only the first time
		      IF l_total_rec_count = 0 THEN
				-- Table Header
				l_content :=    RPAD('-',l_row_num_len-1,'-') || ' '
				             || RPAD('-',l_contract_num_len-1,'-') || ' '
							 || RPAD('-',l_asset_num_len-1,'-') || ' '
							 || RPAD('-',l_sty_name_len-1,'-') || ' '
							 || RPAD('-',l_investor_len-1,'-') || ' '
							 || RPAD('-',l_amount_len,'-');

			    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

			    l_content :=    RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_ROW_NUMBER),l_row_num_len-1) || ' '
				                || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_CONTRACT_NUMBER),l_contract_num_len-1) || ' '
						        || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_ASSET_NUMBER),l_asset_num_len-1) || ' '
			                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAM_TYPE),l_sty_name_len-1) || ' '
			                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_INVESTOR),l_investor_len-1) || ' '
			                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_AMOUNT_DUE),l_amount_len);

			     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

				l_content :=    RPAD('-',l_row_num_len-1,'-') || ' '
				             || RPAD('-',l_contract_num_len-1,'-') || ' '
							 || RPAD('-',l_asset_num_len-1,'-') || ' '
							 || RPAD('-',l_sty_name_len-1,'-') || ' '
							 || RPAD('-',l_investor_len-1,'-') || ' '
							 || RPAD('-',l_amount_len,'-');

			    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

			 END IF; -- l_total_rec_count

             l_total_rec_count := l_total_rec_count+1;
			 l_content :=    RPAD(l_total_rec_count,l_row_num_len)
                          || RPAD(l_okl_poc_rec.contract_number ,l_contract_num_len)
                          || RPAD(l_okl_poc_rec.asset_number ,l_asset_num_len)
                          || RPAD(l_okl_poc_rec.stream_type_name ,l_sty_name_len);

             FOR l_okl_investor_names_rec IN l_okl_investor_names_csr(lx_investor_shares_tbl(l_row_count).investor_id)
             LOOP
               l_content := l_content || RPAD(l_okl_investor_names_rec.name ,l_investor_len)
			                          || LPAD(okl_accounting_util.format_amount(lx_investor_shares_tbl(l_row_count).amount,l_okl_investor_names_rec.currency_code),l_amount_len);
             END LOOP; -- 		l_okl_investor_names_csr

             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_content);

		   END LOOP; -- lx_investor_shares_tbl

     END LOOP; -- l_okl_pocs_csr


	 IF l_total_rec_count = 0 THEN
       -- "No Records"
	   l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_NONE);
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_filler || l_content);
	 ELSE
        FOR l_okl_dnz_chrs_rec IN l_okl_dnz_chrs_csr(p_khr_id)
        LOOP
          okl_accrual_sec_pvt.cancel_streams(p_api_version           => l_api_version
                                      ,p_init_msg_list         => l_init_msg_list
                                      ,x_return_status         => l_return_status
                                      ,x_msg_count             => l_msg_count
                                      ,x_msg_data              => l_msg_data
                                      ,p_khr_id                => l_okl_dnz_chrs_rec.dnz_chr_id
                                      ,p_cancel_date           => lp_effective_date);


		   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'okl_accrual_sec_pvt.cancel_streams',G_UNEXPECTED_ERROR));
		     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
		   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'okl_accrual_sec_pvt.cancel_streams',G_EXPECTED_ERROR));
		     RAISE OKL_API.G_EXCEPTION_ERROR;
		   END IF;
       END LOOP; -- l_okl_dnz_chrs_csr

	 END IF; -- l_total_rec_count
*/
    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_END));

	-- Errors
	-- sub head
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_ERRORS);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=',LENGTH(l_content),'='));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');


    OKL_API.END_ACTIVITY(l_msg_count, l_msg_data);
    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'OKL_API.END_ACTIVITY',G_CONFIRM_PROCESS));

    -- "No Errors"
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_NONE);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_filler || l_content);

    x_retcode := 0;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_retcode := 2;
      l_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> l_msg_count,
												   x_msg_data	=> l_msg_data,
												   p_api_type	=> G_API_TYPE);

        GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
          END LOOP;
        END IF;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_retcode := 2;
      l_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> l_msg_count,
												   x_msg_data	=> l_msg_data,
												   p_api_type	=> G_API_TYPE);

      GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
          END LOOP;
        END IF;
    WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;
      l_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> l_msg_count,
												   x_msg_data	=> l_msg_data,
												   p_api_type	=> G_API_TYPE);

      GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
          END LOOP;
        END IF;

 END buyback_agreement;

-- fmiao bug: 4748514 start
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : activate_agreement_ui
-- Description     : Activate Investor agreement
--                   This is a wrapper procedure for concurrent program call from jsp/UI
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

PROCEDURE activate_agreement_ui(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.g_false
   ,x_return_status                OUT nocopy VARCHAR2
   ,x_msg_count                    OUT nocopy NUMBER
   ,x_msg_data                     OUT nocopy VARCHAR2
   ,x_request_id                   OUT nocopy NUMBER
   -- agreement id --
   ,p_chr_id                       IN NUMBER)
AS
  l_api_name VARCHAR2(30) := 'activate_agreement_ui';
  l_api_version  NUMBER := 1.0;
  l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_date       VARCHAR2(20) ;

BEGIN

  x_return_status := G_RET_STS_SUCCESS;

  l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;

    -- Bug#4562312, fmiao, 31/10/2005
    --call concurrent program
    FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
    x_request_id := Fnd_Request.SUBMIT_REQUEST(
                             application  => 'OKL'
                             ,program     => 'OKL_ACTIVATE_INV_AGREEMENT'
                             ,argument1   => TO_CHAR(p_chr_id)
							 );

    -- Added these validations to check to see if the request has been submitted successfully.
    IF x_request_id = 0 THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_CONC_REQ_ERROR',
                           p_token1   => 'PROG_NAME',
                           p_token1_value => 'OKL Activate Investor Agreement',
                           p_token2   => 'REQUEST_ID',
                           p_token2_value => x_request_id);

       RAISE G_EXCEPTION_ERROR;
    END IF;

    OKL_API.end_activity(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
END activate_agreement_ui;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : activate_agreement
  -- Description     : This is a wrapper procedure to call the activate agreement API
  --                   to activate the agreement.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------


PROCEDURE activate_agreement(x_errbuf OUT  NOCOPY VARCHAR2
                            ,x_retcode OUT NOCOPY NUMBER
                            ,p_chr_id IN VARCHAR2)
IS

  l_api_name          CONSTANT VARCHAR2(40) := 'ACTIVATE_AGREEMENT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  p_api_version       CONSTANT NUMBER 	    := 1.0;
  l_init_msg_list     VARCHAR2(1) := 'T';
  l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_error_msg_rec     Error_message_Type;

  l_chr_id            NUMBER;

  --Added by kthiruva on 19-Dec-2007
  --Call the relevant api to activate the investor agreement
  --or the add contracts request
  --Bug 6691554 - Start of Changes
  CURSOR get_ia_status_csr(p_chr_id NUMBER)
  IS
  SELECT chrb.sts_code
  FROM OKC_K_HEADERS_ALL_B CHRB
  WHERE CHRB.ID = p_chr_id;

  l_status_code      OKC_K_HEADERS_ALL_B.STS_CODE%TYPE;
  --Bug 6691554 - End of Changes

BEGIN

    x_retcode := 0;
    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => l_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);


    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'OKL_API.START_ACTIVITY',G_UNEXPECTED_ERROR));
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'OKL_API.START_ACTIVITY',G_EXPECTED_ERROR));
      RAISE G_EXCEPTION_ERROR;
    END IF;

	FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'OKL_API.START_ACTIVITY',G_CONFIRM_PROCESS));
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    -- Printing the values in the log file.

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_chr_id : ' || p_chr_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_START));

	l_chr_id := TO_NUMBER(p_chr_id);

	--Bug 6691554 - Start of Changes
	FOR get_ia_status_rec IN get_ia_status_csr(l_chr_id)
	LOOP
	  l_status_code := get_ia_status_rec.sts_code;
	END LOOP;

	IF l_status_code = 'ACTIVE' THEN
	    okl_sec_agreement_pvt.activate_add_request(
          			   p_api_version     => l_api_version
				      ,p_init_msg_list   => l_init_msg_list
			          ,x_return_status   => l_return_status
			          ,x_msg_count       => l_msg_count
			          ,x_msg_data        => l_msg_data
			          ,p_khr_id          => l_chr_id
					  );

       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Sec_Concurrent_Pvt.Activate_Agreement',G_UNEXPECTED_ERROR));
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Sec_Concurrent_Pvt.Activate_Agreement',G_EXPECTED_ERROR));
         RAISE G_EXCEPTION_ERROR;
       END IF;

	ELSE
       okl_sec_agreement_pvt.activate_sec_agreement(
          			   p_api_version     => l_api_version
				      ,p_init_msg_list   => l_init_msg_list
			          ,x_return_status   => l_return_status
			          ,x_msg_count       => l_msg_count
			          ,x_msg_data        => l_msg_data
			          ,p_khr_id          => l_chr_id
					  );

       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Sec_Concurrent_Pvt.Activate_Agreement',G_UNEXPECTED_ERROR));
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Sec_Concurrent_Pvt.Activate_Agreement',G_EXPECTED_ERROR));
         RAISE G_EXCEPTION_ERROR;
       END IF;

    END IF;
    --Bug 6691554 - End of Changes
	FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_END));

	Okl_Api.END_ACTIVITY(l_msg_count, l_msg_data);
    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'OKL_API.END_ACTIVITY',G_CONFIRM_PROCESS));

    x_retcode := 0;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_retcode := 2;

      l_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> l_msg_count,
												   x_msg_data	=> l_msg_data,
												   p_api_type	=> G_API_TYPE);

      -- print the error message in the log file

      GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
          END LOOP;
        END IF;

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_retcode := 2;

      l_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> l_msg_count,
												   x_msg_data	=> l_msg_data,
												   p_api_type	=> G_API_TYPE);
      -- print the error message in the log file
      GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
          END LOOP;
        END IF;

    WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;

      l_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> l_msg_count,
												   x_msg_data	=> l_msg_data,
												   p_api_type	=> G_API_TYPE);

     -- print the error message in the log file
      GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
          END LOOP;
        END IF;

END activate_agreement;
-- fmiao bug: 4748514 end



END Okl_Sec_Concurrent_Pvt;

/
