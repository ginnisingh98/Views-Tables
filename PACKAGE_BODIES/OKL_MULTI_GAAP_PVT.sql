--------------------------------------------------------
--  DDL for Package Body OKL_MULTI_GAAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MULTI_GAAP_PVT" AS
/* $Header: OKLRGAPB.pls 120.12.12010000.3 2008/11/20 07:32:48 racheruv ship $ */

  -- Function to return the asset category to be used in the report
  FUNCTION GET_CATEGORY_NAME(p_category_id IN NUMBER) RETURN VARCHAR2 IS

    l_category_name VARCHAR2(2000);

	-- cursor to get get category name
    CURSOR category_name_csr(p_category_id NUMBER) IS
    SELECT CONCATENATED_SEGMENTS
	FROM FA_CATEGORIES_B_KFV
	WHERE category_id = p_category_id;

  BEGIN
    OPEN category_name_csr(p_category_id);
	FETCH category_name_csr INTO l_category_name;
	IF category_name_csr%NOTFOUND THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_category_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE category_name_csr;

	RETURN l_category_name;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF category_name_csr%ISOPEN THEN
        CLOSE category_name_csr;
      END IF;

      RETURN NULL;

    WHEN OTHERS THEN
      IF category_name_csr%ISOPEN THEN
        CLOSE category_name_csr;
      END IF;

      RETURN NULL;

  END GET_CATEGORY_NAME;

  -- Function to check whether contract is a multi gaap contract.
  FUNCTION CHECK_MULTI_GAAP(p_khr_id IN NUMBER) RETURN VARCHAR2 IS

    -- cursor to check whether contract is a multi gaap contract.
    CURSOR check_multi_gaap(p_ctr_id NUMBER) IS
    SELECT 'Y' FROM OKL_K_HEADERS khr
    WHERE khr.id = p_ctr_id
    AND khr.multi_gaap_yn = 'Y';

    l_flag_value    VARCHAR2(1) :='N';

  BEGIN

	OPEN check_multi_gaap(p_khr_id);
    FETCH check_multi_gaap INTO l_flag_value;
	IF check_multi_gaap%NOTFOUND THEN
      -- if value in column is NULl return N
      l_flag_value := 'N';
    END IF;
	CLOSE check_multi_gaap;

	RETURN l_flag_value;

  EXCEPTION

    WHEN OTHERS THEN
      IF check_multi_gaap%ISOPEN THEN
        CLOSE check_multi_gaap;
      END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);

      RETURN NULL;

  END CHECK_MULTI_GAAP;

  PROCEDURE GET_TEMPLATE_LINES(p_pdt_name IN VARCHAR2
                              ,p_sty_name IN VARCHAR2
					          ,p_accrual_activity IN VARCHAR2
							  ,x_ae_lines_tbl OUT NOCOPY ae_lines_tbl_type) IS
 --start changed by abhsaxen for Bug#617448
    CURSOR get_ae_lines(p_product VARCHAR2, p_stream_type VARCHAR2, p_memo_yn VARCHAR2) IS
	SELECT code_combination_id,
	       ae_line_type,
		   crd_code
	FROM OKL_AE_TMPT_LNES
	WHERE avl_id IN (SELECT avl.id
	                 FROM okl_ae_templates avl,okl_trx_types_v try,okl_strm_type_v sty
					 WHERE aes_id IN
	                      (SELECT avl.aes_id FROM okl_products_v WHERE avl.name = p_product)
                     AND try.name = 'Accrual'
                     AND sty.name= p_stream_type
                     AND avl.sty_id = sty.id
                     AND avl.try_id = try.id
		     AND avl.memo_yn= p_memo_yn
		     AND avl.prior_year_yn is NULL
                     AND avl.factoring_synd_flag IS NULL);
--end changed by abhsaxen for Bug#6174484
/*    SELECT code_combination_id,
	       ae_line_type,
		   crd_code
	FROM OKL_AE_TMPT_LNES
	WHERE avl_id IN (SELECT id
	                 FROM okl_Ae_templates_uv
					 WHERE aes_id IN
	                      (SELECT aes_id FROM okl_products_v WHERE name = p_product)
                     AND try_name = 'Accrual'
                     AND sty_name = p_stream_type
					 AND memo_yn = p_memo_yn
					 AND prior_year_yn is NULL
                     AND FACTORING_SYND_FLAG IS NULL);
*/					 -- commenting for later use in securitization
					 --and NVL(FACTORING_SYND_FLAG,'xxx') = NVL(p_fac_synd,'xxx'));

    l_memo_yn VARCHAR2(1);
    l_pdt_name VARCHAR2(2000) := p_pdt_name;
    l_sty_name VARCHAR2(2000) := p_sty_name;
    x get_ae_lines%ROWTYPE;

  BEGIN
    IF p_accrual_activity = 'ACCRUAL' THEN
	  l_memo_yn := 'N';
	ELSIF p_accrual_activity = 'NON-ACCRUAL' THEN
	  l_memo_yn := 'Y';
	END IF;

    OPEN get_ae_lines(l_pdt_name,l_sty_name,l_memo_yn);
	LOOP
	  FETCH get_ae_lines INTO x;
	  IF get_ae_lines%FOUND THEN
      x_ae_lines_tbl(get_ae_lines%ROWCOUNT).ccid := x.code_combination_id;
      x_ae_lines_tbl(get_ae_lines%ROWCOUNT).line_type := x.ae_line_type;
      x_ae_lines_tbl(get_ae_lines%ROWCOUNT).crd_code := x.crd_code;
	  END IF;
	  EXIT WHEN get_ae_lines%NOTFOUND;
    END LOOP;
	CLOSE get_ae_lines;

  EXCEPTION
    WHEN OTHERS THEN
      IF get_ae_lines%ISOPEN THEN
        CLOSE get_ae_lines;
      END IF;

      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);



  END GET_TEMPLATE_LINES;

  -- Function to call the MULTI GAAP Procedure
  FUNCTION SUBMIT_MULTI_GAAP(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_date_from IN DATE,
    p_date_to IN DATE,
    p_batch_name IN VARCHAR2 ) RETURN NUMBER IS

    x_request_id            NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_api_name              VARCHAR2(2000) := 'SUBMIT_MULTI_GAAP';
    l_api_version           CONSTANT NUMBER := 1.0;
	l_init_msg_list         VARCHAR2(20) DEFAULT Okl_Api.G_FALSE;
    l_date_from             VARCHAR2(2000);
    l_date_to               VARCHAR2(2000);
  BEGIN
    -- Set save point
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,l_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- validate period from date
    IF (p_date_from IS NULL OR p_date_from = Okl_Api.G_MISS_DATE) THEN
       Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_MGP_PERIOD_FROM_ERROR');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSE
      l_date_from := FND_DATE.DATE_TO_CANONICAL(p_date_from);
    END IF;

    -- validate period to date
    IF (p_date_to IS NULL OR p_date_from = Okl_Api.G_MISS_DATE) THEN
       Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_MGP_PERIOD_TO_ERROR');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSE
      l_date_to := FND_DATE.DATE_TO_CANONICAL(p_date_to);
    END IF;

    -- Submit Concurrent Program Request
    FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
    x_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'OKL',
                                               program => 'OKLGAPCALC',
                                               argument1 => l_date_from,
                                               argument2 => l_date_to,
                                               argument3 => p_batch_name);

    IF x_request_id = 0 THEN
    -- Handle submission error
    -- Raise Error if the request has not been submitted successfully.
      Okl_Api.SET_MESSAGE(G_APP_NAME, 'OKL_ERROR_SUB_CONC_PROG', 'CONC_PROG', 'Multi GAAP Adjustment Support');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSE
     --set return status
      x_return_status := l_return_status;
      RETURN x_request_id;
    END IF;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
      RETURN x_request_id;
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
      RETURN x_request_id;
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
      RETURN x_request_id;
  END SUBMIT_MULTI_GAAP;


  PROCEDURE MULTI_GAAP_SUPPORT(errbuf OUT NOCOPY VARCHAR2
                              ,retcode OUT NOCOPY NUMBER
                              ,p_period_from IN VARCHAR2
                              ,p_period_to IN VARCHAR2
                              ,p_batch_name IN VARCHAR2) IS

    -- declare local variables
	l_contract_id		    OKL_K_HEADERS_FULL_V.id%TYPE;
	l_contract_number       OKL_K_HEADERS_FULL_V.contract_number%TYPE;
	l_product_id            OKL_K_HEADERS_FULL_V.pdt_id%TYPE;
    l_product_name          OKL_PRODUCTS_V.name%TYPE;
	l_rep_product_id        OKL_PRODUCTS_V.reporting_pdt_id%TYPE;
    l_rep_product_name      OKL_PRODUCTS_V.name%TYPE;
	l_deal_type             OKL_K_HEADERS.DEAL_TYPE%TYPE;
    l_rep_deal_type         OKL_K_HEADERS_FULL_V.deal_type%TYPE;
	l_currency_code         OKL_TRX_CONTRACTS.currency_code%TYPE;
	l_sob_id                OKL_SYS_ACCT_OPTS.set_of_books_id%TYPE;
    l_book_type_code        OKL_TXD_ASSETS_V.tax_book%TYPE;
    l_contract_currency     OKC_K_HEADERS_B.currency_code%TYPE;
	l_api_name              CONSTANT VARCHAR2(2000) := 'MULTI_GAAP_SUPPORT';
	l_api_version           CONSTANT NUMBER := 1.0;
	p_api_version           CONSTANT NUMBER := 1.0;
    l_sob_name              VARCHAR2(2000);
    l_cr_dr_flag            VARCHAR2(2000);
    l_concat_desc           VARCHAR2(2000);
    l_fac_synd_flag         VARCHAR2(2000);
	l_init_msg_list         VARCHAR2(2000) := OKL_API.G_FALSE;
	l_msg_data              VARCHAR2(2000);
    l_org_name              VARCHAR2(2000);
	l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_msg_count             NUMBER;
    l_org_id                NUMBER;
    l_contract_error_count  NUMBER := 1;
	l_count                 NUMBER := 1;
	l_count2                NUMBER := 1;
	l_count3                NUMBER := 1;
	l_sysdate               DATE := SYSDATE;
	l_period_from           DATE := FND_DATE.CANONICAL_TO_DATE(p_period_from);
	l_period_to             DATE := FND_DATE.CANONICAL_TO_DATE(p_period_to);
    l_ae_lines_tbl          ae_lines_tbl_type;
    l_asset_deprn_tbl       asset_deprn_tbl_type;
    l_report_deprn_tbl      asset_deprn_tbl_type;
    l_outer_error_msg_tbl 	Okl_Accounting_Util.Error_Message_Type;
    l_pdtv_rec              OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
    l_pdt_parameters_rec    OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
    l_rep_summary_tbl       rep_prd_summary_tbl_type;

    -- cursor to select the contracts eligible for multi-gaap
    CURSOR gaap_contracts_csr IS
    SELECT khr.id khr_id,
		   chr.contract_number,
           pdt.id pdt_id,
           pdt.name pdt_name,
		   pdt.reporting_pdt_id,
		   khr.deal_type,
		   chr.currency_code
    FROM OKC_K_HEADERS_B chr, OKL_K_HEADERS khr, OKL_PRODUCTS pdt
    WHERE chr.id = khr.id
    AND chr.scs_code = 'LEASE'
	AND chr.sts_code IN ('BOOKED','EVERGREEN') -- Bug 3448049. removed approved and under revision statuses
    AND khr.pdt_id = pdt.id
	AND khr.multi_gaap_yn = 'Y'
    ORDER BY pdt_name;

    -- cursor to identify income accrued/non-accrued
    -- Bug 3498903. Added language clause.
    CURSOR accrual_trx_csr(p_khr_id NUMBER,p_date_from DATE,p_date_to DATE) IS
    SELECT stytl.name stream_type,
           decode(trx.accrual_activity,'NON-ACCRUAL','NON-ACCRUAL','ACCRUAL') accrual_activity,
           sum(txl.amount) total_amount
    FROM okl_trx_contracts trx, okl_txl_cntrct_lns txl, okl_strm_type_tl stytl
    WHERE trx.khr_id = p_khr_id
 --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
    AND trx.tsu_code = 'PROCESSED'
--rkuttiya added for 12.1.1 Multi GAAP
    AND trx.representation_type = 'PRIMARY'
--
    AND trx.tcn_type='ACL'
    AND trx.accrual_activity in ('ACCRUAL','NON-ACCRUAL','CATCH-UP')
    AND trx.date_transaction_occurred BETWEEN p_date_from AND p_date_to
    AND trx.id = txl.tcn_id
    AND txl.sty_id = stytl.id
    AND stytl.language = USERENV('LANG')
    GROUP BY stytl.name, decode(trx.accrual_activity,'NON-ACCRUAL','NON-ACCRUAL','ACCRUAL');

    -- cursor to identify depreciation booked/rolled back
    CURSOR local_deprn_csr(p_khr_id NUMBER, p_start_date DATE, p_end_date DATE) IS
    SELECT fad.asset_category_id,
           decode(trx.accrual_activity,'NON-ACCRUAL','NON-ACCRUAL','ACCRUAL') accrual_activity,
           SUM(fds.deprn_amount) deprn_amount
	FROM
       OKL_TRX_CONTRACTS trx,
	   OKC_K_ITEMS cli,
	   OKC_K_LINES_B cle,
	   OKC_LINE_STYLES_B cls,
       FA_BOOKS fab,
	   FA_ADDITIONS_B fad,
       FA_BOOK_CONTROLS fbc,
	   FA_CATEGORIES_B fcb,
	   FA_DEPRN_SUMMARY fds,
	   FA_DEPRN_PERIODS fdp,
	   FA_CALENDAR_PERIODS fcp
	WHERE trx.khr_id = p_khr_id
 --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
	AND trx.tsu_code = 'PROCESSED'
  --rkuttiya added for 12.1.1 Multi GAAP Project
        AND trx.representation_type = 'PRIMARY'
  --
	AND trx.tcn_type = 'ACL'
	AND trx.accrual_activity IN ('ACCRUAL','CATCH-UP','NON-ACCRUAL')
	AND trx.khr_id = cle.dnz_chr_id
    AND cle.id = cli.cle_id
    AND cli.dnz_chr_id = cle.dnz_chr_id
    AND cle.lse_id = cls.id
    AND cls.lty_code = 'FIXED_ASSET'
	AND fad.asset_id = TO_NUMBER(cli.object1_id1)
    AND fad.asset_category_id = fcb.category_id
    AND fad.asset_id = fab.asset_id
    AND fab.book_type_code = fbc.book_type_code
    AND fab.transaction_header_id_out is null
    AND NVL(fbc.date_ineffective,sysdate+1) > sysdate
    AND fbc.book_class = 'CORPORATE'
    AND fds.asset_id = fad.asset_id
	AND fds.book_type_code = fab.book_type_code
	AND fds.book_type_code = fdp.book_type_code
    AND fds.period_counter = fdp.period_counter
    AND fdp.period_name = fcp.period_name
	AND fcp.start_date BETWEEN p_start_date AND p_end_date
	AND fcp.end_date BETWEEN p_start_date AND p_end_date
	AND trx.date_accrual BETWEEN p_start_date and p_end_date
	GROUP BY fad.asset_category_id,decode(trx.accrual_activity,'NON-ACCRUAL','NON-ACCRUAL','ACCRUAL');

    -- cursor to select reporting stream amounts to be accrued
    --Bug# 2753128. Adding currency code to cursor.
    --Bug# 2870483. Adding say_code='CURR' to cursor to restrict query to only current stream amounts and not history.
    -- Bug 3498903. Added language clause.
    CURSOR reporting_streams_csr(p_khr_id NUMBER, p_accrue_from_date DATE, p_accrue_till_date DATE) IS
    SELECT stytl.name stream_type,
           sty.accrual_yn,
           chr.currency_code,
           ABS(SUM(ste.amount)) total_amount
    FROM OKL_STRM_TYPE_TL stytl,
         OKL_STRM_TYPE_B sty,
         OKL_STREAMS stm,
         OKL_STRM_ELEMENTS ste,
         OKL_PROD_STRM_TYPES psty,
		 OKL_K_HEADERS khr,
		 OKC_K_HEADERS_B chr,
		 OKL_PRODUCTS pdt
    WHERE stm.khr_id = p_khr_id
    AND khr.id = chr.id
    AND khr.id = stm.khr_id
    AND stm.active_yn = 'N'
    AND stm.purpose_code = 'REPORT'
    AND stm.say_code='CURR'
    AND stm.sty_id = stytl.id
    AND stytl.id = sty.id
    AND stytl.language = USERENV('LANG')
    AND stytl.id = psty.sty_id
    AND psty.pdt_id = pdt.reporting_pdt_id
	AND pdt.id = khr.pdt_id
    AND psty.accrual_yn = 'Y'
    AND stm.id = ste.stm_id
    AND ste.stream_element_date BETWEEN p_accrue_from_date AND p_accrue_till_date
    GROUP BY stytl.name, sty.accrual_yn, chr.currency_code;

    -- cursor to ascertain reporting depreciation to be booked
    CURSOR reporting_deprn_csr(p_khr_id NUMBER, p_start_date DATE, p_end_date DATE, p_book_type_code VARCHAR2) IS
    SELECT fad.asset_category_id,
           SUM(fds.deprn_amount) deprn_amount
	FROM
	   OKC_K_ITEMS cli,
	   OKC_K_LINES_B cle,
	   OKC_LINE_STYLES_B cls,
       FA_BOOKS fab,
	   FA_ADDITIONS_B fad,
       FA_BOOK_CONTROLS fbc,
	   FA_CATEGORIES_B fcb,
	   FA_DEPRN_SUMMARY fds,
	   FA_DEPRN_PERIODS fdp,
	   FA_CALENDAR_PERIODS fcp
	WHERE cle.dnz_chr_id = p_khr_id
    AND cle.id = cli.cle_id
    AND cli.dnz_chr_id = cle.dnz_chr_id
    AND cle.lse_id = cls.id
    AND cls.lty_code = 'FIXED_ASSET'
	AND fad.asset_id = TO_NUMBER(cli.object1_id1)
    AND fad.asset_category_id = fcb.category_id
    AND fad.asset_id = fab.asset_id
    AND fab.book_type_code = p_book_type_code
    AND fab.book_type_code = fbc.book_type_code
    AND fab.transaction_header_id_out is null
    AND NVL(fbc.date_ineffective,sysdate+1) > sysdate
    AND fbc.book_class = 'TAX'
    AND fds.asset_id = fad.asset_id
	AND fds.book_type_code = fab.book_type_code
	AND fds.book_type_code = fdp.book_type_code
    AND fds.period_counter = fdp.period_counter
    AND fdp.period_name = fcp.period_name
	AND fcp.start_date BETWEEN p_start_date AND p_end_date
	AND fcp.end_date BETWEEN p_start_date AND p_end_date
	GROUP BY fad.asset_category_id;

    -- cursor to select income accrued/non-accrued grouped by product and stream type
    -- grouping by currency code for bug# 2753128
    -- Bug 3498903. Added language clause.
    CURSOR product_summary_csr(p_from_date DATE, p_to_date DATE) IS
    SELECT pdt.name product_name,
           chr.currency_code,
           stytl.name stream_type,
           decode(trx.accrual_activity,'NON-ACCRUAL','NON-ACCRUAL','ACCRUAL') accrual_activity,
           SUM(txl.amount) total_amount
    FROM OKL_STRM_TYPE_TL stytl,
         OKL_K_HEADERS khr,
		 OKC_K_HEADERS_B chr,
		 OKL_PRODUCTS pdt,
		 OKL_TRX_CONTRACTS trx,
		 OKL_TXL_CNTRCT_LNS txl
    WHERE chr.id = khr.id
    AND pdt.id = khr.pdt_id
    AND khr.multi_gaap_yn = 'Y'
    AND khr.id = trx.khr_id
 --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
    AND trx.tsu_code = 'PROCESSED'
   --rkuttiya added for 12.1.1 Multi GAAP
    AND representation_type = 'PRIMARY'
   --
    AND trx.tcn_type='ACL'
    AND trx.accrual_activity in ('ACCRUAL','NON-ACCRUAL','CATCH-UP')
    AND trx.date_transaction_occurred BETWEEN p_from_date AND p_to_date
    AND trx.id = txl.tcn_id
    AND txl.sty_id = stytl.id
    AND stytl.language = USERENV('LANG')
    GROUP BY pdt.name, chr.currency_code, stytl.name,decode(trx.accrual_activity,'NON-ACCRUAL','NON-ACCRUAL','ACCRUAL');

    -- Cursor to get org name
    CURSOR org_name_csr(p_org_id NUMBER) IS
    SELECT name
    FROM hr_operating_units
    WHERE organization_id = p_org_id;

    -- Cursor to check override status
    CURSOR override_status_csr(p_khr_id NUMBER) IS
    SELECT generate_accrual_override_yn
    FROM okl_k_headers
    WHERE id = p_khr_id;

	TYPE contract_error_tbl_type IS TABLE OF okl_k_headers_full_v.CONTRACT_NUMBER%TYPE
	INDEX BY BINARY_INTEGER;

    TYPE gaap_contracts_rec_type IS RECORD(
      contract_id                  OKL_K_HEADERS_FULL_V.ID%TYPE,
      contract_number              OKL_K_HEADERS_FULL_V.CONTRACT_NUMBER%TYPE,
	  product_id                   OKL_K_HEADERS_FULL_V.PDT_ID%TYPE,
	  product_name                 OKL_PRODUCTS_V.NAME%TYPE,
	  rep_product_id               OKL_K_HEADERS_FULL_V.PDT_ID%TYPE,
      deal_type                    OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE,
      khr_currency_code            OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE);

    TYPE gaap_contracts_tbl_type IS TABLE OF gaap_contracts_rec_type
	INDEX BY BINARY_INTEGER;

	l_gaap_contracts_tbl    gaap_contracts_tbl_type; -- Bug# 3020763
    l_product_summary       product_summary_csr%ROWTYPE;
    l_contract_error_tbl    contract_error_tbl_type;

	-- get the secondary rep method .. bug 7584164
    cursor get_sec_rep_method is
	select secondary_rep_method
	  from okl_sys_acct_opts;

    l_sec_rep_method        okl_sys_acct_opts.secondary_rep_method%TYPE;

  BEGIN

	-- get the accounting method for secondary representation
	open  get_sec_rep_method;
	fetch get_sec_rep_method into l_sec_rep_method;
	close get_sec_rep_method;

    -- Find set of books id
    l_sob_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID;
    IF (l_sob_id IS NULL) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_SOB_ID_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Find set of books name
    l_sob_name := Okl_Accounting_Util.GET_SET_OF_BOOKS_NAME(l_sob_id);

    -- Find org name for report
    l_org_id := mo_global.get_current_org_id();
    IF l_org_id IS NULL THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'ORG_ID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN org_name_csr(l_org_id);
    FETCH org_name_csr INTO l_org_name;
    IF org_name_csr%NOTFOUND THEN
      CLOSE org_name_csr;
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'ORG_ID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	CLOSE org_name_csr;

    -- Find the reporting asset book
	l_book_type_code := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);
	-- verify the reporting book only for secondary rep method of 'Report'. Bug 7584164
    IF (l_book_type_code IS NULL and l_sec_rep_method = 'REPORT') THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_MGP_ASSET_BOOK_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Find functional currency code for the set of books id
    l_currency_code := Okl_Accounting_Util.GET_FUNC_CURR_CODE;
    IF (l_currency_code IS NULL) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_CURR_CODE_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Create report header
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                                             '||FND_MESSAGE.GET_STRING('OKL', 'OKL_MGP_REP_TITLE'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                                             '||FND_MESSAGE.GET_STRING('OKL', 'OKL_MGP_REP_TITLE_UNDERLINE'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_SOB_TITLE')
	                  ||' '||RPAD(l_sob_name, 65)
					  ||FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_OU_TITLE')
					  ||' '||l_org_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_PROG_DATE_TITLE')
	                  ||' '||RPAD(l_sysdate, 61)||FND_MESSAGE.GET_STRING('OKL','OKL_MGP_RPT_DATE_RANGE')
					  ||' '||l_period_from||' '||FND_MESSAGE.GET_STRING('OKL','OKL_MGP_RPT_TO_FIELD')
					  ||' '||l_period_to);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_CURR_TITLE')
	                  ||' '||RPAD(l_currency_code,58)||FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_BATCH_NAME')
					  ||' '||p_batch_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');

	-- if the secondary representation method is not report abort the run. Bug 7584164
	if l_sec_rep_method <> 'REPORT' then
      fnd_file.put_line(FND_FILE.OUTPUT, FND_MESSAGE.GET_STRING('OKL','OKL_SEC_REP_METHOD') ||' '||
	                  OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING('OKL_SEC_REP_METHOD',l_sec_rep_method,540,0));
      fnd_file.put_line(FND_FILE.OUTPUT, FND_MESSAGE.GET_STRING('OKL','OKL_SEC_REP_METHOD_INVALID'));
      return;
	end if;

    -- process contracts
    FOR i IN gaap_contracts_csr
    LOOP
      l_gaap_contracts_tbl(gaap_contracts_csr%ROWCOUNT).contract_id := i.khr_id;
      l_gaap_contracts_tbl(gaap_contracts_csr%ROWCOUNT).contract_number := i.contract_number;
	  l_gaap_contracts_tbl(gaap_contracts_csr%ROWCOUNT).product_id := i.pdt_id;
	  l_gaap_contracts_tbl(gaap_contracts_csr%ROWCOUNT).rep_product_id := i.reporting_pdt_id;
      l_gaap_contracts_tbl(gaap_contracts_csr%ROWCOUNT).product_name := i.pdt_name;
      l_gaap_contracts_tbl(gaap_contracts_csr%ROWCOUNT).deal_type := i.deal_type;
      l_gaap_contracts_tbl(gaap_contracts_csr%ROWCOUNT).khr_currency_code := i.currency_code;
    END LOOP;

	IF l_gaap_contracts_tbl.COUNT > 0 THEN
      FOR x IN l_gaap_contracts_tbl.FIRST..l_gaap_contracts_tbl.LAST
      LOOP

      l_contract_id := l_gaap_contracts_tbl(x).contract_id;
      l_contract_number := l_gaap_contracts_tbl(x).contract_number;
	  l_product_id := l_gaap_contracts_tbl(x).product_id;
	  l_rep_product_id := l_gaap_contracts_tbl(x).rep_product_id;
      l_product_name := l_gaap_contracts_tbl(x).product_name;
      l_deal_type := l_gaap_contracts_tbl(x).deal_type;
      l_contract_currency := l_gaap_contracts_tbl(x).khr_currency_code;

      DECLARE
        -- Declare local variables which need to be re-initialized to null for each contract
        l_error_msg_tbl 		 Okl_Accounting_Util.Error_Message_Type;
		l_accrual_activity       OKL_TRX_CONTRACTS.ACCRUAL_ACTIVITY%TYPE;
		l_deprn_accrual_activity OKL_TRX_CONTRACTS.ACCRUAL_ACTIVITY%TYPE;
		l_record_status          VARCHAR2(10);
		l_record_status2         VARCHAR2(10);
		l_record_status3         VARCHAR2(10);
        l_contract_verified      VARCHAR2(3);
		l_rule_result            VARCHAR2(1);
        l_no_data_found          BOOLEAN;
		l_override_status        VARCHAR2(1);

      BEGIN

        -- create report body content
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_CTR_NUM_TITLE')||': '||l_contract_number);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURRENCY')||': '||l_contract_currency);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||FND_MESSAGE.GET_STRING('OKL','OKL_MGP_LOCAL_PRODUCT')||': '||l_product_name);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||FND_MESSAGE.GET_STRING('OKL','OKL_MGP_LOCAL_BK_CLASS')||': '||OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING('OKL_BOOK_CLASS',l_deal_type,540,0));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REVERSE_REVENUE')||':');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_STY_TYPE'),35)||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_ACTIVITY'),15)||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_TITLE'),20));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_STY_LINE'),35)||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_ACT_LINE'),15)||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_LINE'),20));

        -- For each contract identify the income accrued or non-accrued
        FOR x IN accrual_trx_csr(l_contract_id,l_period_from, l_period_to)
        LOOP
          -- Print the accrual/non-accrual data onto the report file for audit trail
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||RPAD(x.stream_type,35)||RPAD(x.accrual_activity,15)||LPAD(x.total_amount,20));
        END LOOP;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REVERSE_DEPR')||':');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURRENCY')||': '||l_currency_code);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_AST_CAT_PROMPT'),35)||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_ACTIVITY'),15)||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_TITLE'),20));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_AST_CAT_UNDERLINE'),35)||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_ACT_LINE'),15)||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_LINE'),20));

        -- Open cursor local_deprn_csr
		FOR i IN local_deprn_csr(l_contract_id, l_period_from, l_period_to)
		LOOP

          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||RPAD(GET_CATEGORY_NAME(i.asset_category_id),35)||RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY',i.accrual_activity),15)||LPAD(NVL(i.deprn_amount,0),20));

          IF l_asset_deprn_tbl.COUNT > 0 THEN
            l_record_status := 'NOT-ADDED';
		    -- records exist in the pl/sql table
		    FOR x IN l_asset_deprn_tbl.FIRST..l_asset_deprn_tbl.LAST
			LOOP
              IF l_record_status <> 'ADDED' THEN
                IF l_asset_deprn_tbl(x).category_name = GET_CATEGORY_NAME(i.asset_category_id) THEN
                  --asset category is the same
                   IF i.accrual_activity = 'ACCRUAL' THEN

                      l_asset_deprn_tbl(x).deprn_amount := l_asset_deprn_tbl(x).deprn_amount + i.deprn_amount;
                      l_record_status := 'ADDED';
                    ELSIF i.accrual_activity = 'NON-ACCRUAL' THEN

                      l_asset_deprn_tbl(x).deprn_amount := l_asset_deprn_tbl(x).deprn_amount - i.deprn_amount;
                      l_record_status := 'ADDED';
                    END IF;
			    END IF;
              END IF;
	  		END LOOP;

            IF l_record_status <> 'ADDED' THEN
              -- category is not the same, create a new record
              l_asset_deprn_tbl(l_count).category_name := get_category_name(i.asset_category_id);
              IF i.accrual_activity = 'NON-ACCRUAL' THEN
                l_asset_deprn_tbl(l_count).deprn_amount := 0 - i.deprn_amount;
              ELSE
			    l_asset_deprn_tbl(l_count).deprn_amount := i.deprn_amount;
			  END IF;
                l_count := l_count+1;
                l_record_status := 'ADDED';
			END IF;
          ELSE
            -- no records in table, so create first record
            l_asset_deprn_tbl(l_count).category_name := get_category_name(i.asset_category_id);
            IF i.accrual_activity = 'NON-ACCRUAL' THEN
              l_asset_deprn_tbl(l_count).deprn_amount := 0 - i.deprn_amount;
			ELSE
			  l_asset_deprn_tbl(l_count).deprn_amount := i.deprn_amount;
			END IF;
            l_count := l_count+1;
          END IF;
        END LOOP;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');

          l_pdtv_rec.id := l_rep_product_id;
          OKL_SETUPPRODUCTS_PUB.Getpdt_parameters
                             (p_api_version        => l_api_version,
  				  			  p_init_msg_list      => l_init_msg_list,
						      x_return_status      => l_return_status,
							  x_no_data_found      => l_no_data_found,
							  x_msg_count          => l_msg_count,
							  x_msg_data           => l_msg_data,
							  p_pdtv_rec           => l_pdtv_rec,
							  p_pdt_parameter_rec  => l_pdt_parameters_rec);
          -- store the highest degree of error
          IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_MGP_REP_PDT_ERROR',
                                  p_token1       => 'PRODUCT_NAME',
                                  p_token1_value => l_product_name);

              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_MGP_REP_PDT_ERROR',
                                  p_token1       => 'PRODUCT_NAME',
                                  p_token1_value => l_product_name);
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

        -- Bug# 2824234. Adding currency code for reporting streams.
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURRENCY')||': '||l_contract_currency);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REPORT_PRODUCT')||': '||l_pdt_parameters_rec.name);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REPORT_BK_CLASS')||': '||OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING('OKL_BOOK_CLASS',l_pdt_parameters_rec.deal_type,540,0));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||FND_MESSAGE.GET_STRING('OKL','OKL_MGP_ACCOUNT_REVENUE')||':');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_STY_TYPE'),35)||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_ACTIVITY'),15)||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_TITLE'),20));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_STY_LINE'),35)||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_ACT_LINE'),15)||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_LINE'),20));

        l_contract_verified := 'NO';

        -- open reporting streams cursor
		FOR j IN reporting_streams_csr(l_contract_id, l_period_from, l_period_to)
        LOOP
          -- ER 2872216 Need to validate contract against accrual rule only if
          -- stream type is subject to accrual rule. Validation done only once for contract
          IF l_contract_verified = 'NO' THEN
            -- Bug 4054047
            IF j.accrual_yn = 'ACRL_WITH_RULE' THEN
              OKL_GENERATE_ACCRUALS_PUB.VALIDATE_ACCRUAL_RULE
		                    (x_return_status => l_return_status
                            ,x_msg_count => l_msg_count
							,x_msg_data => l_msg_data
                            ,x_result => l_rule_result
                            ,p_ctr_id => l_contract_id);
              -- store the highest degree of error
              IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_RULE_VALD_ERROR',
                                      p_token1       => 'CONTRACT_NUMBER',
                                      p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_RULE_VALD_ERROR',
                                      p_token1       => 'CONTRACT_NUMBER',
                                      p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;

              IF l_rule_result = 'Y' THEN
                l_accrual_activity := 'ACCRUAL';
              ELSIF l_rule_result = 'N' THEN
                l_accrual_activity := 'NON-ACCRUAL';
              ELSE
                Okl_Api.set_message(p_app_name     => g_app_name,
                                    p_msg_name     => 'OKL_AGN_RULE_VALD_ERROR',
                                    p_token1       => 'CONTRACT_NUMBER',
                                    p_token1_value => l_contract_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              -- get override status
              OPEN override_status_csr(l_contract_id);
              FETCH override_status_csr INTO l_override_status;
              CLOSE override_status_csr;

              -- check override status
              IF l_override_status = 'Y' THEN
                l_accrual_activity := 'NON-ACCRUAL';
              END IF;
              l_contract_verified := 'YES';

              -- need to store original accrual activity for depreciation reporting
              l_deprn_accrual_activity := l_accrual_activity;
            -- Bug 4054047
            ELSIF j.accrual_yn = 'ACRL_WITHOUT_RULE' THEN
              l_accrual_activity := 'ACCRUAL';
              l_contract_verified := 'YES';
            ELSE
              -- store SQL error message on message stack for caller
              okl_api.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_INVALID_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'ACCRUAL_YN');
              RAISE OKL_API.G_EXCEPTION_ERROR;

            END IF; --IF j.accrual_yn = 'Y' THEN

          ELSIF l_contract_verified = 'YES' THEN
            -- Bug 4054047
            IF j.accrual_yn = 'ACRL_WITH_RULE' THEN
              IF l_rule_result = 'Y' THEN
                l_accrual_activity := 'ACCRUAL';
              ELSIF l_rule_result = 'N' THEN
                l_accrual_activity := 'NON-ACCRUAL';
              ELSE
                Okl_Api.set_message(p_app_name     => g_app_name,
                                    p_msg_name     => 'OKL_AGN_RULE_VALD_ERROR',
                                    p_token1       => 'CONTRACT_NUMBER',
                                    p_token1_value => l_contract_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
              -- check override status
              IF l_override_status = 'Y' THEN
                l_accrual_activity := 'NON-ACCRUAL';
              END IF;
            -- Bug 4054047
            ELSIF j.accrual_yn = 'ACRL_WITHOUT_RULE' THEN
              l_accrual_activity := 'ACCRUAL';

            ELSE
              -- store SQL error message on message stack for caller
              okl_api.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_INVALID_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'ACCRUAL_YN');
              RAISE OKL_API.G_EXCEPTION_ERROR;

            END IF; --IF j.accrual_yn='Y'
          END IF; --IF l_contract_verified = 'NO' THEN

          -- Print the accrual/non-accrual data onto the report file
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||RPAD(j.stream_type,35)||
          RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY',l_accrual_activity),15)||
          LPAD(j.total_amount,20));

          IF l_rep_summary_tbl.COUNT > 0 THEN
            l_record_status3 := 'NOT-ADDED';

		    -- records exist in the pl/sql table
		    FOR k IN l_rep_summary_tbl.FIRST..l_rep_summary_tbl.LAST
			LOOP
              IF l_record_status3 <> 'ADDED' THEN
                IF l_rep_summary_tbl(k).product_name = l_pdt_parameters_rec.name THEN
                  --product is the same
	              IF l_rep_summary_tbl(k).stream_type = j.stream_type THEN
                    -- stream type is the same
                    IF l_rep_summary_tbl(k).currency_code = j.currency_code THEN
                    -- currency code is the same
                      IF l_rep_summary_tbl(k).accrual_activity = l_accrual_activity THEN
                      --accrual activity is the same
                        l_rep_summary_tbl(k).total_amount := l_rep_summary_tbl(k).total_amount + j.total_amount;
                        l_record_status3 := 'ADDED';
					  END IF;
					END IF;
			      END IF;
			    END IF;
              END IF; -- IF l_record_status3 <> 'ADDED' THEN
	  		END LOOP;

            IF l_record_status3 <> 'ADDED' THEN
              l_rep_summary_tbl(l_count3).product_name := l_pdt_parameters_rec.name;
              l_rep_summary_tbl(l_count3).stream_type := j.stream_type;
              --Bug# 2753128. Adding currency code.
              l_rep_summary_tbl(l_count3).currency_code := j.currency_code;
              l_rep_summary_tbl(l_count3).accrual_activity := l_accrual_activity;
              l_rep_summary_tbl(l_count3).total_amount := j.total_amount;
              l_count3 := l_count3+1;
              l_record_status3 := 'ADDED';
			END IF;

          ELSE
            -- no records in table, so create first record
            l_rep_summary_tbl(l_count3).product_name := l_pdt_parameters_rec.name;
            l_rep_summary_tbl(l_count3).stream_type := j.stream_type;
            --Bug# 2753128. Adding currency code.
            l_rep_summary_tbl(l_count3).currency_code := j.currency_code;
            l_rep_summary_tbl(l_count3).accrual_activity := l_accrual_activity;
            l_rep_summary_tbl(l_count3).total_amount := j.total_amount;
            l_count3 := l_count3+1;
          END IF; -- IF l_rep_summary_tbl.COUNT > 0 THEN
		END LOOP;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||FND_MESSAGE.GET_STRING('OKL','OKL_MGP_ACCOUNT_DEPR')||':');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURRENCY')||': '||l_currency_code);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_AST_CAT_PROMPT'),35)||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_ACTIVITY'),15)||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_TITLE'),20));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_AST_CAT_UNDERLINE'),35)||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_ACT_LINE'),15)||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_LINE'),20));

        --open reporting deprn cursor
		FOR i IN reporting_deprn_csr(l_contract_id, l_period_from, l_period_to, l_book_type_code)
		LOOP

          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    '||RPAD(NVL(GET_CATEGORY_NAME(i.asset_category_id),' '),35)||RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY',l_deprn_accrual_activity),15)||LPAD(NVL(i.deprn_amount,0),20));

          IF l_report_deprn_tbl.COUNT > 0 THEN
            l_record_status2 := 'NOT-ADDED';
		    -- records exist in the pl/sql table
		    FOR z IN l_report_deprn_tbl.FIRST..l_report_deprn_tbl.LAST
			LOOP
              IF l_record_status2 <> 'ADDED' THEN
                IF l_report_deprn_tbl(z).category_name = GET_CATEGORY_NAME(i.asset_category_id) THEN
                  --asset category is the same
                   IF l_deprn_accrual_activity = 'ACCRUAL' THEN
                      l_report_deprn_tbl(z).deprn_amount := l_report_deprn_tbl(z).deprn_amount + i.deprn_amount;
                      l_record_status2 := 'ADDED';
                    ELSIF l_deprn_accrual_activity = 'NON-ACCRUAL' THEN
                      l_report_deprn_tbl(z).deprn_amount := l_report_deprn_tbl(z).deprn_amount - i.deprn_amount;
                      l_record_status2 := 'ADDED';
                    END IF; -- IF l.accrual_activity = 'CATCH-UP' THEN
			    END IF;
              END IF; -- IF record status
	  		END LOOP;
              IF l_record_status2 <> 'ADDED' THEN
                -- category is not the same, create a new record
                l_report_deprn_tbl(l_count2).category_name := get_category_name(i.asset_category_id);
                IF l_deprn_accrual_activity = 'NON-ACCRUAL' THEN
                  l_report_deprn_tbl(l_count2).deprn_amount := 0 - i.deprn_amount;
			    ELSE
     			  l_report_deprn_tbl(l_count2).deprn_amount := i.deprn_amount;
		    	END IF;
                l_count2 := l_count2+1;
                l_record_status2 := 'ADDED';
			  END IF;
          ELSE
            -- no records in table, so create first record
            l_report_deprn_tbl(l_count2).category_name := get_category_name(i.asset_category_id);
            IF l_deprn_accrual_activity = 'NON-ACCRUAL' THEN
              l_report_deprn_tbl(l_count2).deprn_amount := 0 - i.deprn_amount;
			ELSE
			  l_report_deprn_tbl(l_count2).deprn_amount := i.deprn_amount;
			END IF;
            l_count2 := l_count2+1;
          END IF;
        END LOOP; --FOR i IN local_deprn_csr(l_contract_id)
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');


        EXCEPTION
	      WHEN Okl_Api.G_EXCEPTION_ERROR THEN
            l_return_status := Okl_Api.G_RET_STS_ERROR;
            -- Select the contract for error reporting
            l_contract_error_tbl(l_contract_error_count) := l_contract_number;
            l_contract_error_count := l_contract_error_count + 1;
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_contract_number||', '||
			                  FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ERROR_STATUS')||' '||
							  l_return_status);
            Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_tbl);
            IF (l_error_msg_tbl.COUNT > 0) THEN
              FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
              LOOP
                IF l_error_msg_tbl(i) IS NOT NULL THEN
                  FND_FILE.PUT_LINE(FND_FILE.LOG,l_error_msg_tbl(i));
                END IF;
              END LOOP;
            END IF;

	      WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
            -- Select the contract for error reporting
            l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

            -- Select the contract for error reporting
            l_contract_error_tbl(l_contract_error_count) := l_contract_number;
            l_contract_error_count := l_contract_error_count + 1;
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_contract_number||', '||
			                  FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ERROR_STATUS')||' '||
                              l_return_status);
            Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_tbl);
            IF (l_error_msg_tbl.COUNT > 0) THEN
              FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
              LOOP
                IF l_error_msg_tbl(i) IS NOT NULL THEN
                  FND_FILE.PUT_LINE(FND_FILE.LOG,l_error_msg_tbl(i));
                END IF;
              END LOOP;
            END IF;

	      WHEN OTHERS THEN
            IF override_status_csr%ISOPEN THEN
              CLOSE override_status_csr;
            END IF;

            -- Select the contract for error reporting
            l_return_status := Okl_Api.G_RET_STS_ERROR;
            -- Select the contract for error reporting
            l_contract_error_tbl(l_contract_error_count) := l_contract_number;
            l_contract_error_count := l_contract_error_count + 1;
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_contract_number||', '||
			                  FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ERROR_STATUS')||' '||
                              l_return_status);
            Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_tbl);
            IF (l_error_msg_tbl.COUNT > 0) THEN
              FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
              LOOP
                IF l_error_msg_tbl(i) IS NOT NULL THEN
                  FND_FILE.PUT_LINE(FND_FILE.LOG,l_error_msg_tbl(i));
                END IF;
              END LOOP;
            END IF;

         END;

         END LOOP;
		 END IF;

        -- Print summary for each product onto the report
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_LOCAL_PRD_SUMRY')||':');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');


        -- Print summary for each product onto the report
        OPEN product_summary_csr(l_period_from, l_period_to);
        LOOP
        EXIT WHEN product_summary_csr%NOTFOUND;
        FETCH product_summary_csr INTO l_product_summary;
        IF product_summary_csr%FOUND THEN
          l_product_name := l_product_summary.product_name;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_PRD_NAME')||'        : '||l_product_summary.product_name);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_STY_TYPE')||'         : '||l_product_summary.stream_type);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURRENCY')||'            : '||l_product_summary.currency_code);
          IF l_product_summary.accrual_activity = 'ACCRUAL' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_AMT_ACCRUED')||'      : '||l_product_summary.total_amount);
          ELSIF l_product_summary.accrual_activity = 'NON-ACCRUAL' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_AMT_NON_ACCRUED')||'  : '||l_product_summary.total_amount);
          END IF;

          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_ACCOUNTS'));
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_ACCOUNTS_LINE'));
          GET_TEMPLATE_LINES(l_product_summary.product_name
                            ,l_product_summary.stream_type
					        ,l_product_summary.accrual_activity
							,l_ae_lines_tbl);
          IF l_ae_lines_tbl.COUNT >0 THEN
          FOR i IN l_ae_lines_tbl.FIRST..l_ae_lines_tbl.LAST
		  LOOP
            l_concat_desc := okl_accounting_util.get_concat_segments(l_ae_lines_tbl(i).ccid);
            l_cr_dr_flag := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING('CR_DR',l_ae_lines_tbl(i).crd_code,101,101);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_cr_dr_flag||' '||l_ae_lines_tbl(i).line_type||' '||l_concat_desc);
          END LOOP;
		  END IF;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
		END IF;
        END LOOP;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REPORT_PRD_SUMRY')||':');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');

        -- Print reporting summary for each product
        IF l_rep_summary_tbl.COUNT > 0 THEN
        FOR i IN l_rep_summary_tbl.FIRST..l_rep_summary_tbl.LAST
        LOOP
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_PRD_NAME')||'                          : '||l_rep_summary_tbl(i).product_name);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REP_STY_TYPE')||'                           : '||l_rep_summary_tbl(i).stream_type);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURRENCY')||'                              : '||l_rep_summary_tbl(i).currency_code);
          IF l_rep_summary_tbl(i).accrual_activity = 'ACCRUAL' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_AMT_ACCOUNT')||'     : '||l_rep_summary_tbl(i).total_amount);
          ELSIF l_rep_summary_tbl(i).accrual_activity = 'NON-ACCRUAL' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_AMT_NON_ACCOUNT')||' : '||l_rep_summary_tbl(i).total_amount);
          END IF;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_ACCOUNTS'));
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_ACCOUNTS_LINE'));
          GET_TEMPLATE_LINES(l_rep_summary_tbl(i).product_name
                            ,l_rep_summary_tbl(i).stream_type
					        ,l_rep_summary_tbl(i).accrual_activity
							,l_ae_lines_tbl);
          IF l_ae_lines_tbl.COUNT >0 THEN
          FOR i IN l_ae_lines_tbl.FIRST..l_ae_lines_tbl.LAST
		  LOOP
            l_concat_desc := okl_accounting_util.get_concat_segments(l_ae_lines_tbl(i).ccid);
            l_cr_dr_flag := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING('CR_DR',l_ae_lines_tbl(i).crd_code,101,101);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_cr_dr_flag||' '||l_ae_lines_tbl(i).line_type||' '||l_concat_desc);
          END LOOP;
		  END IF;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        END LOOP;
		END IF;

        -- print local depreciation summary
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_LOCAL_DEPR_SUMRY'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        -- Create Report Content
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURRENCY')||': '||l_currency_code);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_AST_CAT_PROMPT'),35)
                     ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ACTIVITY'),23)
					 ||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_TITLE'),18));

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_AST_CAT_UNDERLINE'),35)
                     ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_ACTIVITY_UNDERLINE'),23)
					 ||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_LINE'),18));

		IF l_asset_deprn_tbl.COUNT > 0 THEN
		  FOR j IN l_asset_deprn_tbl.FIRST..l_asset_deprn_tbl.LAST
		  LOOP
            IF SIGN(l_asset_deprn_tbl(j).deprn_amount) = -1 THEN
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_asset_deprn_tbl(j).category_name,35)||
              RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NON-ACCRUAL'),23)||
              LPAD(ABS(l_asset_deprn_tbl(j).deprn_amount),18));
            ELSE
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_asset_deprn_tbl(j).category_name,35)||
              RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','ACCRUAL'),23)||
              LPAD(ABS(l_asset_deprn_tbl(j).deprn_amount),18));
			END IF;
		  END LOOP;
		END IF;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        -- print reporting depreciation summary
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_REPORT_DEPR_SUMRY'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
        -- Create Report Content
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURRENCY')||': '||l_currency_code);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_AST_CAT_PROMPT'),35)
                     ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ACTIVITY'),23)
					 ||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_TITLE'),18));

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_AST_CAT_UNDERLINE'),35)
                     ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_ACTIVITY_UNDERLINE'),23)
					 ||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_LINE'),18));

		IF l_report_deprn_tbl.COUNT > 0 THEN
		  FOR k IN l_report_deprn_tbl.FIRST..l_report_deprn_tbl.LAST
		  LOOP
            IF SIGN(l_report_deprn_tbl(k).deprn_amount) = -1 THEN
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_report_deprn_tbl(k).category_name,35)||
              RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NON-ACCRUAL'),23)||
              LPAD(ABS(l_report_deprn_tbl(k).deprn_amount),18));
            ELSE
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_report_deprn_tbl(k).category_name,35)||
              RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','ACCRUAL'),23)||
              LPAD(ABS(l_report_deprn_tbl(k).deprn_amount),18));
			END IF;
		  END LOOP;
		END IF;

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CNTRCT_ERROR_TITLE'));
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
       l_return_status := OKL_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      l_return_status := Okl_Api.G_RET_STS_ERROR;

      -- print the error message in the log file
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0) THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
          IF l_outer_error_msg_tbl(i) IS NOT NULL THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, l_outer_error_msg_tbl(i));
          END IF;
        END LOOP;
      END IF;
    retcode := 0;

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      -- print the error message in the log file
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
        IF (l_outer_error_msg_tbl.COUNT > 0) THEN
          FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
          LOOP
            IF l_outer_error_msg_tbl(i) IS NOT NULL THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_outer_error_msg_tbl(i));
            END IF;
          END LOOP;
        END IF;

      retcode := 2;

    WHEN OTHERS THEN

      IF org_name_csr%ISOPEN THEN
        CLOSE org_name_csr;
      END IF;

      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      -- print the error message in the log file
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
        IF (l_outer_error_msg_tbl.COUNT > 0) THEN
          FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
          LOOP
            IF l_outer_error_msg_tbl(i) IS NOT NULL THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_outer_error_msg_tbl(i));
            END IF;
          END LOOP;
        END IF;

       errbuf := SQLERRM;
       retcode := 2;


  END MULTI_GAAP_SUPPORT;

END OKL_MULTI_GAAP_PVT;

/
