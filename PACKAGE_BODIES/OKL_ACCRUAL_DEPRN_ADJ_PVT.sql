--------------------------------------------------------
--  DDL for Package Body OKL_ACCRUAL_DEPRN_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCRUAL_DEPRN_ADJ_PVT" AS
/* $Header: OKLRADAB.pls 120.9.12010000.2 2008/09/09 20:04:28 rkuttiya ship $ */

  FUNCTION GET_PERIOD_NAME(p_date IN DATE) RETURN VARCHAR2 IS

    l_period_name      VARCHAR2(2000);
	l_period_set_name  VARCHAR2(2000);
	l_user_period_type VARCHAR2(2000);
    l_sob_id           NUMBER;

    -- cursor to select period details
	CURSOR period_details_csr(p_sob_id NUMBER) IS
	SELECT period_set_name, accounted_period_type
	FROM GL_LEDGERS_PUBLIC_V
	WHERE ledger_id = p_sob_id;

    -- cursor to select period name
    CURSOR period_name_csr(p_current_date DATE, p_period_set_name VARCHAR2, p_user_period_type VARCHAR2) IS
    SELECT period_name
	FROM gl_periods
    WHERE start_date <= p_current_date
	AND end_date >= p_current_date
    AND period_set_name = p_period_set_name
    AND period_type = p_user_period_type;

  BEGIN
    -- get sob id
	l_sob_id := OKL_ACCOUNTING_UTIL.get_set_of_books_id;

	--validate sob id
    IF l_sob_id IS NULL OR l_sob_id = OKL_API.G_MISS_NUM THEN
      okl_api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_AGN_SOB_ID_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN period_details_csr(l_sob_id);
    FETCH period_details_csr INTO l_period_set_name, l_user_period_type;
    IF period_details_csr%NOTFOUND THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'l_sob_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE period_details_csr;

    OPEN period_name_csr(p_date, l_period_set_name, l_user_period_type);
    FETCH period_name_csr INTO l_period_name;
    IF period_name_csr%NOTFOUND THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'l_period_set_name');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
	CLOSE period_name_csr;

    RETURN l_period_name;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF period_details_csr%ISOPEN THEN
        CLOSE period_details_csr;
      END IF;

      IF period_name_csr%ISOPEN THEN
        CLOSE period_name_csr;
      END IF;

      RETURN NULL;

    WHEN OTHERS THEN
      IF period_details_csr%ISOPEN THEN
        CLOSE period_details_csr;
      END IF;

      IF period_name_csr%ISOPEN THEN
        CLOSE period_name_csr;
      END IF;

      RETURN NULL;

  END GET_PERIOD_NAME;


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

  -- Function to call the GENERATE_ACCRUALS Procedure
  FUNCTION SUBMIT_DEPRN_ADJUSTMENT(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_batch_name IN VARCHAR2,
    p_date_from IN DATE,
    p_date_to IN DATE ) RETURN NUMBER IS

    x_request_id            NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_api_name              VARCHAR2(2000) := 'SUBMIT_DEPRN_ADJUSTMENT';
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

    -- Bug 3130551
    -- check if period from date is missing
    IF (p_date_from IS NULL OR p_date_from = Okl_Api.G_MISS_DATE) THEN
       Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_MGP_PERIOD_FROM_ERROR');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSE
      l_date_from := FND_DATE.DATE_TO_CANONICAL(p_date_from);
    END IF;

    -- Bug 3130551
    -- check if period to date is missing
    IF (p_date_to IS NULL OR p_date_from = Okl_Api.G_MISS_DATE) THEN
       Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_MGP_PERIOD_TO_ERROR');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSE
      l_date_to := FND_DATE.DATE_TO_CANONICAL(p_date_to);
    END IF;

    -- Submit Concurrent Program Request
    x_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'OKL',
                                               program => 'OKLADACALC',
                                               argument1 => p_batch_name,
                                               argument2 => l_date_from,
                                               argument3 => l_date_to);

    IF x_request_id = 0 THEN
    -- Handle submission error
    -- Raise Error if the request has not been submitted successfully.
      Okl_Api.SET_MESSAGE(G_APP_NAME, 'OKL_ERROR_SUB_CONC_PROG', 'CONC_PROG', 'OKL Depreciation Adjustment for Accrual');
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
  END SUBMIT_DEPRN_ADJUSTMENT;

  --This is the main accruals deprn adjustment procedure.

  PROCEDURE ADJUST_DEPRECIATION(errbuf OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY NUMBER
                               ,p_batch_name IN VARCHAR2
							   ,p_period_from IN VARCHAR2
							   ,p_period_to IN VARCHAR2) IS

    -- declare local variables
	l_contract_id		    OKL_K_HEADERS_FULL_V.id%TYPE;
	l_contract_number       OKL_K_HEADERS_FULL_V.contract_number%TYPE;
	l_currency_code         OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
	l_sob_id                OKL_SYS_ACCT_OPTS.set_of_books_id%TYPE;
    l_sob_name              VARCHAR2(2000);
	l_sysdate               DATE := SYSDATE;
	l_api_version           CONSTANT NUMBER := 1.0;
	p_api_version           CONSTANT NUMBER := 1.0;
	l_api_name              CONSTANT VARCHAR2(30) := 'ADJUST_DEPRECIATION';
	l_init_msg_list         VARCHAR2(4000) := OKL_API.G_FALSE;
	l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(2000);
    l_outer_error_msg_tbl   Okl_Accounting_Util.Error_Message_Type;
    l_org_id                NUMBER;
    --l_org_name              VARCHAR2(100);
    --Bug# 2706328
    l_org_name              VARCHAR2(240);
	l_count                 NUMBER := 1;
    l_asset_deprn_tbl       asset_deprn_tbl_type;
    l_securitized_yn        VARCHAR2(1);
	l_period_from           DATE := FND_DATE.CANONICAL_TO_DATE(p_period_from);
	l_period_to             DATE := FND_DATE.CANONICAL_TO_DATE(p_period_to);
    l_sty_id                OKL_STRM_TYPE_V.ID%TYPE;

	-- Cursor to select contracts for accrual processing
	-- commenting where condition for Evergreen contracts processing
    CURSOR select_contracts_csr IS
    SELECT chr.id,
           chr.contract_number
    FROM OKC_K_HEADERS_B chr,
         OKL_K_HEADERS khr
    WHERE chr.scs_code = 'LEASE'
    AND chr.id = khr.id
	AND chr.sts_code IN ('BOOKED','EVERGREEN') --bug 3448057. Removing approved and under revision status
	AND khr.deal_type = 'LEASEOP';
	--AND l_sysdate <= NVL(end_date, l_sysdate) --Bug 3078971



    -- Cursor to select transactions which have been non-accrued or caught-up
	-- and corresponding total depreciation amounts by category
    CURSOR asset_deprn_csr(p_khr_id NUMBER) IS
    SELECT fad.asset_category_id,
           trx.accrual_activity,
           trx.date_accrual,
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
	   FA_DEPRN_PERIODS fdp
 --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
	WHERE trx.tsu_code = 'PROCESSED'
	AND trx.tcn_type = 'ACL'
	AND trx.accrual_activity IN ('CATCH-UP','NON-ACCRUAL')
	AND trx.khr_id = p_khr_id
--rkuttiya added for 12.1.1 Multi GAAP Project
    AND trx.representation_type = 'PRIMARY'
--
    AND trx.date_transaction_occurred BETWEEN l_period_from AND l_period_to -- Bug 3130551
	AND cle.dnz_chr_id = trx.khr_id
    AND cle.id = cli.cle_id
    AND cle.dnz_chr_id = p_khr_id
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
    AND fdp.period_name = GET_PERIOD_NAME(trx.date_accrual)
	GROUP BY fad.asset_category_id,trx.date_accrual,trx.accrual_activity;

    -- Bug 3130551
    CURSOR get_revenue_share_csr(p_inv_id NUMBER) IS
    SELECT SUM(kleb_rv.percent_stake) percent_stake
    FROM okl_k_lines kleb_rv,
         okc_k_lines_b cles_rv,
         okc_line_styles_b lseb_rv,
         okl_strm_type_b styb_rv,
         okc_k_lines_b cles_iv,
         okc_line_styles_b lseb_iv
    WHERE cles_iv.dnz_chr_id = p_inv_id
    AND cles_iv.lse_id = lseb_iv.id
    AND lseb_iv.lty_code = 'INVESTMENT'
    AND cles_rv.cle_id = cles_iv.id
    AND cles_rv.lse_id = lseb_rv.id
    AND lseb_rv.lty_code = 'REVENUE_SHARE'
    AND kleb_rv.id = cles_rv.id
    AND kleb_rv.sty_id = styb_rv.id
    AND styb_rv.code ='RENT';

    -- Cursor to get org name
    CURSOR org_name_csr(p_org_id NUMBER) IS
    SELECT name
    FROM hr_operating_units
    WHERE organization_id = p_org_id;

    -- Cursor to get sty id
    CURSOR sty_id_csr IS
    SELECT id
    FROM OKL_STRM_TYPE_B
    WHERE code = 'RENT';

    -- cursor to select agreement number
    CURSOR agr_num_csr(p_agr_id NUMBER) IS
    SELECT contract_number
    FROM OKC_K_HEADERS_B
	WHERE id = p_agr_id;

    TYPE depr_contracts_rec_type IS RECORD
	                (contract_id OKL_K_HEADERS_FULL_V.ID%TYPE,
                     contract_number OKL_K_HEADERS_FULL_V.CONTRACT_NUMBER%TYPE);
    TYPE depr_contracts_tbl_type IS TABLE OF depr_contracts_rec_type INDEX BY BINARY_INTEGER;

	l_depr_contracts_tbl depr_contracts_tbl_type;

  BEGIN

    -- Find set of books id
    l_sob_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID;
    IF (l_sob_id IS NULL OR l_sob_id = OKL_API.G_MISS_NUM) THEN
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
                          p_token1_value => 'l_org_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN org_name_csr(l_org_id);
    FETCH org_name_csr INTO l_org_name;
    IF org_name_csr%NOTFOUND THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'l_org_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	CLOSE org_name_csr;


    -- Find currency code for the set of books id
    l_currency_code := Okl_Accounting_Util.GET_FUNC_CURR_CODE;
    IF (l_currency_code IS NULL) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_CURR_CODE_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Create report header
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                                      '||
	                            FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_TITLE'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                                      '||
	                            FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_TITLE_UNDERLINE'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_SOB_TITLE')
	                  ||' '||RPAD(l_sob_name, 65)
					  ||FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_OU_TITLE')
					  ||' '||l_org_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_CURR_TITLE')
	                  ||' '||RPAD(l_currency_code,58)||FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_BATCH_NAME')
					  ||' '||p_batch_name);
    -- Bug 3130551
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_MGP_RPT_DATE_RANGE')||' '||l_period_from||' '||FND_MESSAGE.GET_STRING('OKL','OKL_MGP_RPT_TO_FIELD')||' '||l_period_to);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');

    -- Create Report Content
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_AST_CAT_PROMPT'),35)
					 ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_PRD_NAME_PROMPT'),20)
		             ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ACTIVITY'),23)
					 ||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_TITLE'),18));

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_AST_CAT_UNDERLINE'),35)
					 ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_PRD_NAME_UNDERLINE'),20)
		             ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_ACTIVITY_UNDERLINE'),23)
					 ||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_LINE'),18));

    -- Open cursor to select contracts for accrual processing
    -- commenting code below for bug# 3377730. This from or bul collect
	-- does not seem to work on 8i environment. Works brilliantly on 9i environments
	-- Re-enable commented code in 11ix
    --OPEN select_contracts_csr;
	--FETCH select_contracts_csr BULK COLLECT INTO l_depr_contracts_tbl;
	--CLOSE select_contracts_csr;

	FOR x in select_contracts_csr
	LOOP
	  l_depr_contracts_tbl(select_contracts_csr%ROWCOUNT).contract_id := x.id;
	  l_depr_contracts_tbl(select_contracts_csr%ROWCOUNT).contract_number := x.contract_number;
	END LOOP;

    OPEN sty_id_csr;
	FETCH sty_id_csr INTO l_sty_id;
    IF sty_id_csr%NOTFOUND THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'l_sty_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
	CLOSE sty_id_csr;

    IF l_depr_contracts_tbl.COUNT > 0 THEN

	FOR i IN l_depr_contracts_tbl.FIRST..l_depr_contracts_tbl.LAST
    LOOP
      l_contract_id := l_depr_contracts_tbl(i).contract_id;
      l_contract_number := l_depr_contracts_tbl(i).contract_number;

      DECLARE
        -- Declare local variables which need to be re-initialized to null for each contract
		l_error_msg_tbl 		Okl_Accounting_Util.Error_Message_Type;
		l_record_status         VARCHAR2(10);
        l_deprn_amount           NUMBER := 0;
        l_agreement_id           OKL_K_HEADERS_FULL_V.id%TYPE;
        l_agreement_number       OKL_K_HEADERS_FULL_V.contract_number%TYPE;
        l_revenue_share         NUMBER := 0;

        -- Begin a new PL/SQL block to trap errors related to a praticular contract and to move on to the next contract
      BEGIN

        -- Bug 3130551
	    OKL_SECURITIZATION_PVT.check_sty_securitized(
           p_api_version             => l_api_version
          ,p_init_msg_list           => l_init_msg_list
          ,x_return_status           => l_return_status
          ,x_msg_count               => l_msg_count
          ,x_msg_data                => l_msg_data
          ,p_khr_id                  => l_contract_id
          ,p_effective_date          => l_period_from
          ,p_effective_date_operator => OKL_SECURITIZATION_PVT.G_GREATER_THAN_EQUAL_TO
          ,p_sty_id                  => l_sty_id
          ,x_value                   => l_securitized_yn
          ,x_inv_agmt_chr_id         => l_agreement_id);

        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        IF l_securitized_yn = 'T' THEN
		  -- check if agreement id is available. if not throw error.
          IF l_agreement_id IS NULL THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_ADA_AGR_ID_ERROR',
							    p_token1       => G_CONTRACT_NUMBER_TOKEN,
							    p_token1_value => l_contract_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
	      END IF;

          OPEN agr_num_csr(l_agreement_id);
		  FETCH agr_num_csr INTO l_agreement_number;
          IF agr_num_csr%NOTFOUND THEN
            -- store SQL error message on message stack for caller
            okl_api.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_NO_MATCHING_RECORD,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'contract id');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
		  CLOSE agr_num_csr;

          -- get revenue share
          OPEN get_revenue_share_csr(l_agreement_id);
          FETCH get_revenue_share_csr INTO l_revenue_share;
          IF get_revenue_share_csr%NOTFOUND OR l_revenue_share = 0 THEN
            -- store SQL error message on message stack for caller
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_ADA_REV_SHARE_ERROR',
								p_token1       => 'AGREEMENT_NUMBER',
								p_token1_value => l_agreement_number);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
          CLOSE get_revenue_share_csr;

        END IF; --IF l_securitized_yn = 'T' THEN

        -- Open cursor asset_deprn_csr
	    FOR i IN asset_deprn_csr(l_contract_id)
		LOOP

          IF l_securitized_yn = 'T' THEN
            l_deprn_amount := ROUND((i.deprn_amount*l_revenue_share/100),2);
          ELSE
		    l_deprn_amount := i.deprn_amount;
          END IF;

          IF l_asset_deprn_tbl.COUNT > 0 THEN
            l_record_status := 'NOT-ADDED';
		    -- records exist in the pl/sql table
		    FOR x IN l_asset_deprn_tbl.FIRST..l_asset_deprn_tbl.LAST
			LOOP
              IF l_record_status <> 'ADDED' THEN
                IF l_asset_deprn_tbl(x).category_name = GET_CATEGORY_NAME(i.asset_category_id) THEN
                  --asset category is the same
	              IF l_asset_deprn_tbl(x).period_name = GET_PERIOD_NAME(i.date_accrual) THEN
                    -- period is the same
                    IF i.accrual_activity = 'CATCH-UP' THEN
                      l_asset_deprn_tbl(x).deprn_amount := l_asset_deprn_tbl(x).deprn_amount + l_deprn_amount;
                      l_record_status := 'ADDED';
                    ELSIF i.accrual_activity = 'NON-ACCRUAL' THEN
                      l_asset_deprn_tbl(x).deprn_amount := l_asset_deprn_tbl(x).deprn_amount - l_deprn_amount;
                      l_record_status := 'ADDED';
                    END IF; -- IF i.accrual_activity = 'CATCH-UP' THEN
			      END IF; --IF l_asset_deprn_tbl(x).period_name = GET_PERIOD_NAME(i.date_accrual) THEN
			    END IF; -- IF l_asset_deprn_tbl(x).category_name = GET_CATEGORY_NAME
              END IF; -- IF record status
	  		END LOOP; --FOR x IN l_asset_deprn_tbl.FIRST..l_asset_deprn_tbl.LAST

            IF l_record_status <> 'ADDED' THEN
              -- since record was not added, add the record to the table. Bug 2807825
              l_asset_deprn_tbl(l_count).category_name := get_category_name(i.asset_category_id);
              -- 11-mar-04. If record not added add record with correct sign of amount.
              IF i.accrual_activity = 'CATCH-UP' THEN
                l_asset_deprn_tbl(l_count).deprn_amount := l_deprn_amount;
              ELSE
                l_asset_deprn_tbl(l_count).deprn_amount := 0 - l_deprn_amount;
		      END IF;
              l_asset_deprn_tbl(l_count).period_name := GET_PERIOD_NAME(i.date_accrual);
              l_count := l_count+1;
              l_record_status := 'ADDED';
            END IF;
          ELSE
            -- no records in table, so create first record
            --Bug 2754236. Add record to table based on accrual activity.
            l_asset_deprn_tbl(l_count).category_name := get_category_name(i.asset_category_id);
            IF i.accrual_activity = 'CATCH-UP' THEN
              l_asset_deprn_tbl(l_count).deprn_amount := l_deprn_amount;
            ELSE
              l_asset_deprn_tbl(l_count).deprn_amount := 0 - l_deprn_amount;
			END IF;
            l_asset_deprn_tbl(l_count).period_name := GET_PERIOD_NAME(i.date_accrual);
            l_count := l_count+1;
          END IF; -- IF l_asset_deprn_tbl.COUNT > 0 THEN
        END LOOP; --FOR i IN asset_deprn_csr(l_contract_id)

      EXCEPTION
        WHEN Okl_Api.G_EXCEPTION_ERROR THEN

        --close open cursors
          IF agr_num_csr%ISOPEN THEN
            CLOSE agr_num_csr;
          END IF;

          IF get_revenue_share_csr%ISOPEN THEN
            CLOSE get_revenue_share_csr;
          END IF;

          l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

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

          l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

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
          -- Select the contract for error reporting
          OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                             ,p_msg_name      => g_unexpected_error
                             ,p_token1        => g_sqlcode_token
                             ,p_token1_value  => SQLCODE
                             ,p_token2        => g_sqlerrm_token
                             ,p_token2_value  => SQLERRM);

          l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

          Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_tbl);
          IF (l_error_msg_tbl.COUNT > 0) THEN
            FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
            LOOP
              IF l_error_msg_tbl(i) IS NOT NULL THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,l_error_msg_tbl(i));
              END IF;
	        END LOOP;
          END IF;
      END; -- END of sub PL/SQL Block

    END LOOP;
	END IF;

	IF l_asset_deprn_tbl.COUNT > 0 THEN
      FOR j IN l_asset_deprn_tbl.FIRST..l_asset_deprn_tbl.LAST
      LOOP
        IF SIGN(l_asset_deprn_tbl(j).deprn_amount) = -1 THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_asset_deprn_tbl(j).category_name,35)||
                            RPAD(l_asset_deprn_tbl(j).period_name,20)||
                            RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_ROLLBACK_DEPRN'),23)||
                            LPAD(ABS(l_asset_deprn_tbl(j).deprn_amount),18));
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_asset_deprn_tbl(j).category_name,35)||
                            RPAD(l_asset_deprn_tbl(j).period_name,20)||
                            RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_ADA_RPT_ADD_DEPRN'),23)||
                            LPAD(ABS(l_asset_deprn_tbl(j).deprn_amount),18));
        END IF;
      END LOOP;
	END IF;

    retcode := 0;
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      --close open cursors
      IF org_name_csr%ISOPEN THEN
        CLOSE org_name_csr;
      END IF;

      IF sty_id_csr%ISOPEN THEN
        CLOSE sty_id_csr;
      END IF;

      -- set return status needed in report
      l_return_status := Okl_Api.G_RET_STS_ERROR;

      -- print the error message in the log file
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
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
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      -- print the error message in the log file
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0) THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
          IF l_outer_error_msg_tbl(i) IS NOT NULL THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_outer_error_msg_tbl(i));
          END IF;
        END LOOP;
      END IF;

      errbuf := SQLERRM;
      retcode := 2;
      FND_FILE.PUT_LINE(FND_FILE.LOG,errbuf);

  END ADJUST_DEPRECIATION;

END OKL_ACCRUAL_DEPRN_ADJ_PVT;

/
