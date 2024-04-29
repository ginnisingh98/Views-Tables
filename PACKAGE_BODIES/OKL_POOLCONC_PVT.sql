--------------------------------------------------------
--  DDL for Package Body OKL_POOLCONC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POOLCONC_PVT" AS
/* $Header: OKLRSZCB.pls 120.17 2008/01/04 08:48:18 dpsingh noship $ */
----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------

 G_POOL_NO_MODIFY   CONSTANT VARCHAR2(18) := 'OKL_POOL_NO_MODIFY';
 G_POC_STS_NEW          CONSTANT VARCHAR2(10) := Okl_Pool_Pvt.G_POC_STS_NEW;
 G_POC_STS_ACTIVE       CONSTANT VARCHAR2(10) := Okl_Pool_Pvt.G_POC_STS_ACTIVE;
 G_POC_STS_INACTIVE     CONSTANT VARCHAR2(10) := Okl_Pool_Pvt.G_POC_STS_INACTIVE;
 G_POC_STS_PENDING     CONSTANT VARCHAR2(10) := Okl_Pool_Pvt.G_POC_STS_PENDING;
  G_POOL_ADD_REPORT       CONSTANT VARCHAR2(30) := 'OKL_POOL_ADD_REPORT';
  G_POOL_ELIGIBILITY_CRITERIA       CONSTANT VARCHAR2(30) := 'OKL_POOL_ELIGIBILITY_CRITERIA';
  G_POOL_ADD_TBL_HDR       CONSTANT VARCHAR2(30) := 'OKL_POOL_ADD_TBL_HDR';
  G_REJECT_REASON_CODE CONSTANT VARCHAR2(25) := 'OKL_REJECT_REASON_CODE';
  G_REJECT_REASON_CODES CONSTANT VARCHAR2(25) := 'OKL_REJECT_REASON_CODES';

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
-- Procedure Name  : add_pool_contents
-- Description     : creates pool contents based on passed in search criteria
--                   This is a wrapper procedure for concurrent program to call private API
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
-- Create by Search Criteria:	Query Streams from contracts + Create

 PROCEDURE add_pool_contents(x_errbuf OUT  NOCOPY VARCHAR2
                             ,x_retcode OUT NOCOPY NUMBER
                                ,p_pol_id IN VARCHAR2
                                ,p_currency_code IN VARCHAR2
                                ,p_multi_org                    IN VARCHAR2 DEFAULT OKL_API.G_FALSE
                                ,p_cust_object1_id1 IN VARCHAR2 DEFAULT NULL -- customer_id
                                ,p_sic_code IN VARCHAR2 DEFAULT NULL
                                ,p_dnz_chr_id IN VARCHAR2 DEFAULT NULL -- dnz_chr_id
                                ,p_pre_tax_yield_from IN VARCHAR2 DEFAULT NULL
                                ,p_pre_tax_yield_to IN VARCHAR2 DEFAULT NULL
                                ,p_book_classification IN VARCHAR2 DEFAULT NULL
                                ,p_tax_owner IN VARCHAR2 DEFAULT NULL
                                ,p_pdt_id IN VARCHAR2 DEFAULT NULL
                                ,p_start_from_date IN VARCHAR2 DEFAULT NULL
                                ,p_start_to_date IN VARCHAR2 DEFAULT NULL
                                ,p_end_from_date IN VARCHAR2 DEFAULT NULL
                                ,p_end_to_date IN VARCHAR2 DEFAULT NULL
                                ,p_asset_id IN VARCHAR2 DEFAULT NULL
                                ,p_item_id1 IN VARCHAR2 DEFAULT NULL
                                ,p_model_number IN VARCHAR2 DEFAULT NULL
                                ,p_manufacturer_name IN VARCHAR2 DEFAULT NULL
                                ,p_vendor_id1 IN VARCHAR2 DEFAULT NULL
                                ,p_oec_from IN VARCHAR2 DEFAULT NULL
                                ,p_oec_to IN VARCHAR2 DEFAULT NULL
                                ,p_residual_percentage IN VARCHAR2 DEFAULT NULL
                                ,p_sty_id1 IN VARCHAR2 DEFAULT NULL
                                ,p_sty_id2 IN VARCHAR2 DEFAULT NULL
                                ,p_streams_from_date IN VARCHAR2 DEFAULT NULL
                                ,p_streams_to_date IN VARCHAR2 DEFAULT NULL
                                ,p_stream_element_payment_freq IN VARCHAR2 DEFAULT NULL
                                ,p_stream_type_subclass        IN VARCHAR2 DEFAULT NULL
                                ,p_cust_crd_clf_code           IN VARCHAR2 DEFAULT NULL)
IS

  -- Bug#2829983, v115.13
  CURSOR l_okl_pol_status_csr(p_pol_id IN NUMBER)
  IS
  SELECT status_code
  FROM   okl_pools
  WHERE  id = p_pol_id;

  -- /* Following Cursors for Report purposes */
  CURSOR l_okl_pol_csr IS
  SELECT polv.pool_number               pool_number
        ,psts.meaning                   pool_status
  FROM   OKL_POOLS polv -- to take care of org_id
        ,okc_statuses_tl psts
  WHERE  polv.id = p_pol_id
  AND    polv.status_code = psts.code
  AND    psts.LANGUAGE = USERENV('LANG');

  CURSOR l_okl_set_of_books_csr
  IS
  SELECT okls.set_of_books_id set_of_books_id
        ,glsb.name            set_of_books_name
  FROM   GL_LEDGERS_PUBLIC_V  glsb
        ,OKL_SYS_ACCT_OPTS okls
  WHERE  glsb.ledger_id =  okls.set_of_books_id;

  CURSOR l_okl_operating_unit_csr
  IS
  SELECT name
  FROM   hr_operating_units
  WHERE  organization_id = mo_global.get_current_org_id();

  CURSOR l_okl_customer_csr
  IS
  SELECT name
  FROM   OKX_PARTIES_V
  WHERE  id1 = p_cust_object1_id1;

  CURSOR l_okl_sic_csr
  IS
  SELECT name
  FROM   OKL_POOL_CUST_INDUSTRY_UV
  WHERE  code = p_sic_code;

  CURSOR l_okl_chr_csr
  IS
  SELECT contract_number
  FROM   OKC_K_HEADERS_V
  WHERE  id = p_dnz_chr_id;

  CURSOR l_okl_book_class_csr
  IS
  SELECT meaning
  FROM   FND_LOOKUPS
  WHERE lookup_type='OKL_BOOK_CLASS'
  AND NVL(start_date_active,SYSDATE) <=SYSDATE
  AND NVL(end_date_active,SYSDATE+1) > SYSDATE
  AND enabled_flag = 'Y'
  AND lookup_code = p_book_classification;

  CURSOR l_okl_tax_owner_csr
  IS
  SELECT meaning
  FROM   FND_LOOKUPS
  WHERE lookup_type='OKL_TAX_OWNER'
  AND NVL(start_date_active,SYSDATE) <=SYSDATE
  AND NVL(end_date_active,SYSDATE+1) > SYSDATE
  AND enabled_flag = 'Y'
  AND lookup_code = p_tax_owner;

  CURSOR l_okl_pdt_csr
  IS
  SELECT name
  FROM   OKL_PRODUCTS
  WHERE  id = p_pdt_id;

  CURSOR l_okl_sty_subclass_csr
  IS
  SELECT meaning
  FROM   fnd_lookups
  WHERE  lookup_type = 'OKL_STREAM_TYPE_SUBCLASS'
  AND    lookup_code = p_stream_type_subclass;

 --Added ssdeshpa
  CURSOR l_okl_cust_crdt_clsf_csr
  IS
   SELECT MEANING AS CREDITCXLSSFCTN
   FROM   AR_LOOKUPS fndlup
   WHERE  LOOKUP_TYPE = 'AR_CMGT_CREDIT_CLASSIFICATION'
   AND LOOKUP_CODE = p_cust_crd_clf_code
   AND ENABLED_FLAG = 'Y'
   AND    SYSDATE BETWEEN NVL   (fndlup.start_date_active,sysdate)
                  AND     NVL(fndlup.end_date_active,sysdate);

   l_cust_crd_clf VARCHAR2(80);

  /*
  CURSOR l_okl_reject_codes_csr
  IS
  SELECT lookup_code,
	     meaning
  FROM   fnd_lookups
  WHERE LOOKUP_TYPE LIKE 'OKL_POOL_REJECT_REASON'
  ORDER BY LOOKUP_CODE;
  */

  l_api_name          CONSTANT VARCHAR2(40) := 'add_pool_contents';
  l_api_version       CONSTANT NUMBER       := 1.0;
  p_api_version       CONSTANT NUMBER 	    := 1.0;
  l_init_msg_list     VARCHAR2(1) := 'T';
  l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_msg_count         NUMBER;
  l_row_count         NUMBER;
  l_amount            NUMBER;

  l_msg_data          VARCHAR2(2000);
  l_RecordsProcessed NUMBER := 0;
  l_error_msg_rec     Error_message_Type;

  -- report related fields
  l_row_num_len      NUMBER := 6;
  l_contract_num_len NUMBER := 30;
  l_asset_num_len    NUMBER := 15;
  l_lessee_len       NUMBER := 40;
  l_sty_subclass_len NUMBER := 25;
  l_reject_code_len  NUMBER := 20;
  l_max_len          NUMBER := 150;
  l_prompt_len       NUMBER := 35;


  l_str_row_num      VARCHAR2(5);
  l_str_contract_num VARCHAR2(30);
  l_str_lessee       VARCHAR2(50);
  l_content          VARCHAR2(1000);
  l_header_len       NUMBER;

  -- Search Parameters
  l_customer          VARCHAR2(360);
  l_customer_industry VARCHAR2(80);
  l_contract_number   VARCHAR2(120);
  l_book_class        VARCHAR2(80);
  l_tax_owner         VARCHAR2(80);
  l_product           VARCHAR2(150);
  l_stream_type_subclass  VARCHAR2(150);

  l_filler            VARCHAR2(5) := RPAD(' ',5,' ');

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
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_currency_code : ' || p_currency_code);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_pol_id : ' || p_pol_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_multi_org : ' || p_multi_org);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_cust_object1_id1 : ' || p_cust_object1_id1);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_sic_code : ' || p_sic_code);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_khr_id : ' || p_dnz_chr_id);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_pre_tax_yield_from : ' || p_pre_tax_yield_from);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_pre_tax_yield_to : ' || p_pre_tax_yield_to);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_book_classification : ' || p_book_classification);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_tax_owner : ' || p_tax_owner);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_pdt_id : ' || p_pdt_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_start_date_from : ' || p_start_from_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_start_date_to : ' || p_start_to_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_end_date_from : ' || p_end_from_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_end_date_to : ' || p_end_to_date);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_asset_id : ' || p_asset_id);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_item_id1 : ' || p_item_id1);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_model_number : ' || p_model_number);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_manufacturer_name : ' || p_manufacturer_name);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_vendor_id1 : ' || p_vendor_id1);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_oec_from : ' || p_oec_from);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_oec_to : ' || p_oec_to);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_residual_percentage : ' || p_residual_percentage);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_sty_id1 : ' || p_sty_id1);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_sty_id2 : ' || p_sty_id2);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_stream_element_from_date : ' || p_streams_from_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_stream_element_to_date : ' || p_streams_to_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_stream_element_payment_freq : ' || p_stream_element_payment_freq);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_stream_type_subclass : ' || p_stream_type_subclass);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_cust_crd_clf_code : ' || p_cust_crd_clf_code);
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_START));

    -- Bug#2829983, v115.13
    FOR l_okl_pol_status_rec IN l_okl_pol_status_csr(p_pol_id)
    LOOP
      IF l_okl_pol_status_rec.status_code NOT IN (Okl_Pool_Pvt.G_POL_STS_NEW,Okl_Pool_Pvt.G_POL_STS_ACTIVE)
      THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_POOL_NO_MODIFY));
        RAISE G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

    -- Product Title
    l_content :=     FND_MESSAGE.GET_STRING(G_APP_NAME,G_OKL_TITLE);
	l_header_len := LENGTH(l_content);
	l_content :=    RPAD(LPAD(l_content,l_max_len/2),l_max_len/2);    -- center align header
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
	l_content := RPAD('-',l_header_len,'-');                           -- underline header
	l_content := RPAD(LPAD(l_content,l_max_len/2),l_max_len/2,'=');    -- center align
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

	-- Header
    l_content :=     FND_MESSAGE.GET_STRING(G_APP_NAME,G_POOL_ADD_REPORT);
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
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_PROGRAM_RUN_DATE),l_prompt_len) || ' : ' || SYSDATE);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

	-- Pool Details
	FOR l_okl_pol_rec IN l_okl_pol_csr
	LOOP
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_POOL_NUMBER),l_prompt_len) || ' : ' || l_okl_pol_rec.pool_number);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_POOL_STATUS),l_prompt_len) || ' : ' || l_okl_pol_rec.pool_status);
	END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_CURRENCY),l_prompt_len) || ' : ' || p_currency_code);

	-- Search Parameters
	-- sub head
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_POOL_ELIGIBILITY_CRITERIA);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=',LENGTH(l_content),'='));

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_CUSTOMERS);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-',LENGTH(l_content),'-'));

    -- Customer related parameters
    FOR l_okl_customer_rec IN l_okl_customer_csr
    LOOP
      l_customer := l_okl_customer_rec.name;
    END LOOP;
    FOR l_okl_sic_rec IN l_okl_sic_csr
    LOOP
       l_customer_industry := l_okl_sic_rec.name;
    END LOOP;
    --added ssdeshpa
    FOR l_okl_cust_crdt_clsf_rec IN l_okl_cust_crdt_clsf_csr
    LOOP
       l_cust_crd_clf := l_okl_cust_crdt_clsf_rec.CREDITCXLSSFCTN;
    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_CUSTOMER),l_prompt_len) || ' : ' || l_customer);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_CUSTOMER_INDUSTRY_CODE),l_prompt_len) || ' : ' || l_customer_industry);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_CUST_CRDT_CLASSIFICATION),l_prompt_len) || ' : ' || l_cust_crd_clf);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_CONTRACTS);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-',LENGTH(l_content),'-'));

	-- Contract related Parameters
    FOR l_okl_chr_rec IN l_okl_chr_csr
	LOOP
	  l_contract_number := l_okl_chr_rec.contract_number;
	END LOOP;
	FOR l_okl_book_class_rec IN l_okl_book_class_csr
	LOOP
	  l_book_class := l_okl_book_class_rec.meaning;
	END LOOP;
	FOR l_okl_tax_owner_rec IN l_okl_tax_owner_csr
	LOOP
	  l_tax_owner := l_okl_tax_owner_rec.meaning;
	END LOOP;
	FOR l_okl_pdt_rec IN l_okl_pdt_csr
	LOOP
	  l_product := l_okl_pdt_rec.name;
	END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_CONTRACT_NUMBER),l_prompt_len) || ' : ' || l_contract_number);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_PTY_FROM),l_prompt_len) || ' : ' || p_pre_tax_yield_from);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_PTY_TO),l_prompt_len) || ' : ' || p_pre_tax_yield_to);
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_BOOK_CLASS),l_prompt_len) || ' : ' || l_book_class);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_TAX_OWNER),l_prompt_len) || ' : ' || l_tax_owner);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_START_FROM_DATE),l_prompt_len) || ' : ' || p_start_from_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_START_TO_DATE),l_prompt_len) || ' : ' || p_start_to_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_END_FROM_DATE),l_prompt_len) || ' : ' || p_end_from_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_END_TO_DATE),l_prompt_len) || ' : ' || p_end_to_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_PRODUCT),l_prompt_len) || ' : ' || l_product);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAMS);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-',LENGTH(l_content),'-'));

	-- Stream related  Parameters
	IF p_stream_type_subclass IS NOT NULL THEN
          FOR l_okl_sty_subclass_rec IN l_okl_sty_subclass_csr
          LOOP
            l_stream_type_subclass := l_okl_sty_subclass_rec.meaning;
          END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAM_TYPE_SUBCLASS),l_prompt_len) || ' : ' || l_stream_type_subclass);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAMS_FROM_DATE),l_prompt_len) || ' : ' || p_streams_from_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAMS_TO_DATE),l_prompt_len) || ' : ' || p_streams_to_date);

	/*
    -- Note preceding Table Header
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING(G_APP_NAME,G_POOL_ADD_TBL_HDR));

	-- Table header
		l_content :=    RPAD('-',l_row_num_len-1,'-') || ' '
	             || RPAD('-',l_contract_num_len-1,'-') || ' '
	             || RPAD('-',l_asset_num_len-1,'-') || ' '
				 || RPAD('-',l_lessee_len-1,'-') || ' '
				 || RPAD('-',l_sty_subclass_len-1,'-') || ' '
				 || RPAD('-',l_reject_code_len-1,'-');

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

       l_content :=    RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_ROW_NUMBER),l_row_num_len-1) || ' '
	                || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_CONTRACT_NUMBER),l_contract_num_len-1) || ' '
	                || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_ASSET_NUMBER),l_asset_num_len-1) || ' '
                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_LESSEE),l_lessee_len-1) || ' '
                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAM_TYPE_SUBCLASS),l_sty_subclass_len-1) || ' '
                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_REJECT_REASON_CODE),l_reject_code_len-1);

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

		l_content :=    RPAD('-',l_row_num_len-1,'-') || ' '
	             || RPAD('-',l_contract_num_len-1,'-') || ' '
	             || RPAD('-',l_asset_num_len-1,'-') || ' '
				 || RPAD('-',l_lessee_len-1,'-') || ' '
				 || RPAD('-',l_sty_subclass_len-1,'-') || ' '
				 || RPAD('-',l_reject_code_len-1,'-');

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

   	*/
    Okl_Pool_Pvt.add_pool_contents(
          			      p_api_version     => l_api_version
				      ,p_init_msg_list   => l_init_msg_list
			            ,x_return_status   => l_return_status
			            ,x_msg_count       => l_msg_count
			            ,x_msg_data        => l_msg_data
			            ,x_row_count       => l_row_count
                             ,p_multi_org             => p_multi_org
                             ,p_currency_code         => p_currency_code
                             ,p_pol_id                => TO_NUMBER(p_pol_id)
                             ,p_cust_object1_id1      => TO_NUMBER(p_cust_object1_id1)
                             ,p_sic_code              => p_sic_code
                             ,p_khr_id                => TO_NUMBER(p_dnz_chr_id)
                             ,p_pre_tax_yield_from    => TO_NUMBER(p_pre_tax_yield_from)
                             ,p_pre_tax_yield_to      => TO_NUMBER(p_pre_tax_yield_to)
                             ,p_book_classification   => p_book_classification
                             ,p_tax_owner             => p_tax_owner
                             ,p_pdt_id                => TO_NUMBER(p_pdt_id)
                             ,p_start_date_from       => fnd_date.canonical_to_date(p_start_from_date)
                             ,p_start_date_to         => fnd_date.canonical_to_date(p_start_to_date)
                             ,p_end_date_from         => fnd_date.canonical_to_date(p_end_from_date)
                             ,p_end_date_to           => fnd_date.canonical_to_date(p_end_to_date)
                             ,p_asset_id              => TO_NUMBER(p_asset_id)
                             ,p_item_id1              => TO_NUMBER(p_item_id1)
                             ,p_model_number          => p_model_number
                             ,p_manufacturer_name     => p_manufacturer_name
                             ,p_vendor_id1            => TO_NUMBER(p_vendor_id1)
                             ,p_oec_from              => TO_NUMBER(p_oec_from)
                             ,p_oec_to                => TO_NUMBER(p_oec_to)
                             ,p_residual_percentage   => TO_NUMBER(p_residual_percentage)
                             ,p_sty_id1               => TO_NUMBER(p_sty_id1)
                             ,p_sty_id2               => TO_NUMBER(p_sty_id2)
                             ,p_stream_element_from_date => fnd_date.canonical_to_date(p_streams_from_date)
                             ,p_stream_element_to_date   => fnd_date.canonical_to_date(p_streams_to_date)
                             ,p_stream_element_payment_freq => p_stream_element_payment_freq
                             ,p_stream_type_subclass => p_stream_type_subclass
                             ,p_cust_crd_clf_code    => p_cust_crd_clf_code);


    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_TOTAL_ROWS_PROCESSED) || l_row_count);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.ADD_POOL_CONTENTS',G_UNEXPECTED_ERROR));
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.ADD_POOL_CONTENTS',G_EXPECTED_ERROR));
      RAISE G_EXCEPTION_ERROR;
    END IF;
	/*
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING(G_APP_NAME,G_REJECT_REASON_CODES));

    -- Listing Reason Code Meaning-s
	FOR l_okl_reject_codes_rec IN l_okl_reject_codes_csr
	LOOP
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_filler || l_okl_reject_codes_rec.lookup_code
	                                                  || ' => '
													  || l_okl_reject_codes_rec.meaning);
	END LOOP;		*/


	/* v115.16, mvasudev
--
-- update total principal amount at okl_pools
--
    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message('Okl_Pool_Pvt.GET_TOT_PRINCIPAL_AMT','',G_PROCESS_START));

    Okl_Pool_Pvt.recal_tot_princ_amt(
          			      p_api_version     => l_api_version
				      ,p_init_msg_list   => l_init_msg_list
			            ,x_return_status   => l_return_status
			            ,x_msg_count       => l_msg_count
			            ,x_msg_data        => l_msg_data
                              ,x_value           => l_amount
                             ,p_pol_id          => p_pol_id);


            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Okl_Pool_Pvt.GET_TOT_PRINCIPAL_AMT:: p_pol_id : ' || p_pol_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Okl_Pool_Pvt.GET_TOT_PRINCIPAL_AMT:: x_value : ' || l_amount);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECAL_TOT_PRINC_AMT',G_UNEXPECTED_ERROR));
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECAL_TOT_PRINC_AMT',G_EXPECTED_ERROR));
      RAISE G_EXCEPTION_ERROR;
    END IF;
   */

	FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_END));

	-- Errors
	-- sub head
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_ERRORS);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=',LENGTH(l_content),'='));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

  Okl_Api.END_ACTIVITY(l_msg_count, l_msg_data);
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
END add_pool_contents;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : add_pool_contents_ui
-- Description     : creates pool contents based on passed in search criteria
--                   This is a wrapper procedure for concurrent program call from jsp/UI
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE add_pool_contents_ui(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.g_false
   ,x_return_status                OUT nocopy VARCHAR2
   ,x_msg_count                    OUT nocopy NUMBER
   ,x_msg_data                     OUT nocopy VARCHAR2
   ,x_request_id                   OUT nocopy NUMBER
   ,p_polsrch_rec                  IN polsrch_rec_type
   ,p_sty_id1                      IN NUMBER DEFAULT NULL
   ,p_sty_id2                      IN NUMBER DEFAULT NULL
   ,p_stream_type_subclass                 IN VARCHAR2 DEFAULT NULL
   ,p_multi_org                    IN VARCHAR2 DEFAULT OKL_API.G_FALSE)
AS
  l_api_name VARCHAR2(30) := 'add_pool_contents_ui';
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

    -- Bug#2838721, mvasudev, 03/11/2003
    --call concurrent program
    FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request

    x_request_id := Fnd_Request.SUBMIT_REQUEST(
                             application  => 'OKL'
                             ,program     => 'OKL_ADD_POOL_CONTENTS'
                             ,argument1   => TO_CHAR(p_polsrch_rec.pol_id)
                             ,argument2   => p_polsrch_rec.currency_code
                             ,argument3   => p_multi_org
                             ,argument4   => TO_CHAR(p_polsrch_rec.cust_object1_id1)
                             ,argument5   => p_polsrch_rec.sic_code
                             ,argument6   => TO_CHAR(p_polsrch_rec.dnz_chr_id)
                             ,argument7  =>  TO_CHAR(p_polsrch_rec.pre_tax_yield_from)
                             ,argument8  =>  TO_CHAR(p_polsrch_rec.pre_tax_yield_to)
                             ,argument9  =>  p_polsrch_rec.book_classification
                             ,argument10  => p_polsrch_rec.tax_owner
                             ,argument11  => TO_CHAR(p_polsrch_rec.pdt_id)
                             ,argument12  => FND_DATE.DATE_TO_CANONICAL(p_polsrch_rec.start_from_date)
                             ,argument13  => FND_DATE.DATE_TO_CANONICAL(p_polsrch_rec.start_to_date)
                             ,argument14  => FND_DATE.DATE_TO_CANONICAL(p_polsrch_rec.end_from_date)
                             ,argument15  => FND_DATE.DATE_TO_CANONICAL(p_polsrch_rec.end_to_date)
                             ,argument16  => TO_CHAR(p_polsrch_rec.asset_id)
                             ,argument17  => TO_CHAR(p_polsrch_rec.item_id1)
                             ,argument18  => p_polsrch_rec.model_number
                             ,argument19  => p_polsrch_rec.manufacturer_name
                             ,argument20  => TO_CHAR(p_polsrch_rec.vendor_id1)
                             ,argument21  => TO_CHAR(p_polsrch_rec.oec_from)
                             ,argument22  => TO_CHAR(p_polsrch_rec.oec_to)
                             ,argument23  => TO_CHAR(p_polsrch_rec.residual_percentage)
                             ,argument24  => TO_CHAR(p_sty_id1)
                             ,argument25  => TO_CHAR(p_sty_id2)
                             ,argument26  => FND_DATE.DATE_TO_CANONICAL(p_polsrch_rec.streams_from_date)
                             ,argument27  => FND_DATE.DATE_TO_CANONICAL(p_polsrch_rec.streams_to_date)
                             ,argument28  => p_polsrch_rec.stream_element_payment_freq
                             ,argument29  => p_stream_type_subclass
                             ,argument30  => p_polsrch_rec.cust_crd_clf_code
                             );

-- Added these validations to check to see if the request has been submitted successfully.
    IF x_request_id = 0 THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_CONC_REQ_ERROR',
                           p_token1   => 'PROG_NAME',
                           p_token1_value => 'OKL ADD Pool CONTENTS',
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
END add_pool_contents_ui;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : recal_tot_princ_amt
-- Description     : update asset principal amount from pool contents by okl_pools.id to okl_pools.TOTAL_PRINCIPAL_AMOUNT
--                   This is a wrapper procedure for concurrent program to call private API
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE recal_tot_princ_amt(x_errbuf OUT  NOCOPY VARCHAR2
                             ,x_retcode OUT NOCOPY NUMBER
                             ,p_pool_number IN okl_pools.POOL_NUMBER%TYPE)
IS
  l_api_name          CONSTANT VARCHAR2(40) := 'recal_tot_princ_amt';
  l_api_version       CONSTANT NUMBER       := 1.0;
  p_api_version       CONSTANT NUMBER 	    := 1.0;
  l_init_msg_list     VARCHAR2(1) := 'T';
  l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_msg_count         NUMBER;
  l_row_count         NUMBER;
  l_amount            NUMBER;
  i                   NUMBER;
  l_pol_id           okl_pools.id%TYPE;

  l_msg_data          VARCHAR2(2000);
  l_RecordsProcessed NUMBER := 0;
  l_error_msg_rec     Error_message_Type;

CURSOR c_pol IS
  SELECT pol.id
FROM okl_pools pol
WHERE EXISTS
       (SELECT '1'
        FROM   okl_pool_contents poc
        WHERE  poc.pol_id = pol.id
        AND    poc.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE))
;

CURSOR c_pool IS
  SELECT pol.id
FROM okl_pools pol
WHERE pol.pool_number = p_pool_number
;

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
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_pool_number : ' || p_pool_number);
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');


    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_START));

    IF (p_pool_number IS NOT NULL) THEN

      OPEN c_pool;
      FETCH c_pool INTO l_pol_id;
      CLOSE c_pool;

      Okl_Pool_Pvt.recal_tot_princ_amt(
          			      p_api_version     => l_api_version
                         ,p_init_msg_list   => l_init_msg_list
			             ,x_return_status   => l_return_status
			             ,x_msg_count       => l_msg_count
                         ,x_msg_data        => l_msg_data
                         ,x_value           => l_amount
                         ,p_pol_id          => l_pol_id);

            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECAL_TOT_PRINC_AMT',G_UNEXPECTED_ERROR));
              RAISE G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECAL_TOT_PRINC_AMT',G_EXPECTED_ERROR));
              RAISE G_EXCEPTION_ERROR;
            END IF;

            i := 1; -- default
            FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME || '.' || l_api_name || ':: p_pol_id : ' || l_pol_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME || '.' || l_api_name || ':: x_value : ' || l_amount);

    ELSE
      OPEN c_pol;
      i := 0;
      LOOP

        FETCH c_pol INTO
                       l_pol_id;

        EXIT WHEN c_pol%NOTFOUND;

        Okl_Pool_Pvt.recal_tot_princ_amt(
          			      p_api_version     => l_api_version
				      ,p_init_msg_list   => l_init_msg_list
			            ,x_return_status   => l_return_status
			            ,x_msg_count       => l_msg_count
			            ,x_msg_data        => l_msg_data
                              ,x_value           => l_amount
                             ,p_pol_id          => l_pol_id);

            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECAL_TOT_PRINC_AMT',G_UNEXPECTED_ERROR));
              RAISE G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECAL_TOT_PRINC_AMT',G_EXPECTED_ERROR));
              RAISE G_EXCEPTION_ERROR;
            END IF;

            FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME || '.' || l_api_name || ':: p_pol_id : ' || l_pol_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME || '.' || l_api_name || ':: x_value : ' || l_amount);

        i := i+1;
      END LOOP;
      CLOSE c_pol;

    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_TOTAL_ROWS_PROCESSED) || i);
    --FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_TOTAL_ROWS_PROCESSED));
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
END recal_tot_princ_amt;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : recal_tot_princ_amt_ui
-- Description     : update asset principal amount from pool contents by okl_pools.id to okl_pools.TOTAL_PRINCIPAL_AMOUNT
--                   This is a wrapper procedure for concurrent program call from jsp/UI
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE recal_tot_princ_amt_ui(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
-- concurent out parameter
   ,x_request_id                   OUT NOCOPY NUMBER
   ,p_pool_number                  IN okl_pools.POOL_NUMBER%TYPE)
AS
  l_api_name VARCHAR2(30) := 'recal_tot_princ_amt_ui';
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

  --call concurrent program
  FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request

  x_request_id := Fnd_Request.SUBMIT_REQUEST(
                             application  => 'OKL'
                             ,program     => 'OKL_RECAL_POOL_PRINC_AMT'
                             ,argument1   => p_pool_number);

   -- Added these validations to check to see if the request has been submitted successfully.
    IF x_request_id = 0 THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_CONC_REQ_ERROR',
                           p_token1   => 'PROG_NAME',
                           p_token1_value => 'OKL_RECAL_POOL_PRINC_AMT',
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
END recal_tot_princ_amt_ui;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : reconcile_pool_contents
-- Description     : Reconcile Pool Contents
--                   This is a wrapper procedure for concurrent program to call private API
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE reconcile_pool_contents(x_errbuf OUT  NOCOPY VARCHAR2
                                  ,x_retcode OUT NOCOPY NUMBER
                                  ,p_pool_number IN okl_pools.POOL_NUMBER%TYPE DEFAULT NULL)
 IS
  -- Bug#2837819, 03/10/2003
  -- mvasudev, modified to take care of null khrs in pools
  CURSOR l_okl_pols_csr
  IS
  SELECT polb.id
  FROM   okl_pools polb
  WHERE EXISTS
        (SELECT '1'
         FROM   okl_pool_contents pocb
         WHERE  pocb.pol_id = polb.id
         AND    pocb.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
         -- Bug#2829983
         AND    polb.status_code = 'NEW'
        );

  -- Bug#2837819, 03/10/2003
  -- mvasudev, modified to take care of null khrs in pools
  CURSOR l_okl_pol_csr(p_pool_number IN VARCHAR2)
  IS
  SELECT polb.id
  FROM   okl_pools polb
  WHERE  polb.pool_number = p_pool_number
         -- Bug#2829983
  AND    polb.status_code = 'NEW';

  l_api_name          CONSTANT VARCHAR2(40) := 'reconcile_pool_contents';
  l_api_version       CONSTANT NUMBER       := 1.0;
  p_api_version       CONSTANT NUMBER 	    := 1.0;
  l_init_msg_list     VARCHAR2(1) := 'T';

  l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_msg_count         NUMBER;
  l_reconciled        VARCHAR2(1);
  i                   NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_error_msg_rec     Error_message_Type;

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
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_pool_number : ' || p_pool_number);
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_START));


    -- Reconcile the specified Pool
    IF (p_pool_number IS NOT NULL) THEN

	  i :=0;

	  FOR l_okl_pol_rec IN l_okl_pol_csr(p_pool_number)
	  LOOP
                Okl_Pool_Pvt.reconcile_contents(p_api_version     => l_api_version
		                                ,p_init_msg_list   => l_init_msg_list
		                                ,p_pol_id          => l_okl_pol_rec.id
		                                ,x_return_status   => l_return_status
		                                ,x_msg_count       => l_msg_count
		                                ,x_msg_data        => l_msg_data
		                                ,x_reconciled      => l_reconciled);

            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECONCILE_CONTENTS',G_UNEXPECTED_ERROR));
              RAISE G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECONCILE_CONTENTS',G_EXPECTED_ERROR));
              RAISE G_EXCEPTION_ERROR;
            END IF;

            FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME || '.' || l_api_name || ':: p_pol_id : ' || l_okl_pol_rec.id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME || '.' || l_api_name || ':: x_reconciled : ' || l_reconciled);

			i := i + 1;
	  END LOOP;

	  IF  i = 0 THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_RECONCILE_ERROR));
              RAISE G_EXCEPTION_ERROR;
	  END IF;
    -- Reconcile all non-attached Pools
    ELSE
       i := 0;
       FOR l_okl_pols_rec IN l_okl_pols_csr
       LOOP
                Okl_Pool_Pvt.reconcile_contents(p_api_version     => l_api_version
		                                ,p_init_msg_list   => l_init_msg_list
		                                ,p_pol_id          => l_okl_pols_rec.id
		                                ,x_return_status   => l_return_status
		                                ,x_msg_count       => l_msg_count
		                                ,x_msg_data        => l_msg_data
		                                ,x_reconciled      => l_reconciled);

            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECONCILE_CONTENTS',G_UNEXPECTED_ERROR));
              RAISE G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECONCILE_CONTENTS',G_EXPECTED_ERROR));
              RAISE G_EXCEPTION_ERROR;
            END IF;

            FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME || '.' || l_api_name || ':: p_pol_id : ' || l_okl_pols_rec.id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME || '.' || l_api_name || ':: x_reconciled : ' || l_reconciled);

            i := i + 1;
       END LOOP;
    END IF;

    --FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_TOTAL_ROWS_PROCESSED) || i);
    --FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_TOTAL_ROWS_PROCESSED));
    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_END));

    Okl_Api.END_ACTIVITY(l_msg_count, l_msg_data);
    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'OKL_API.END_ACTIVITY',G_CONFIRM_PROCESS));

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

 END reconcile_pool_contents;

 ----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : recon_pnd_pool_con
-- Description     : Reconcile Pending Pool Contents
--                   This is a wrapper procedure for concurrent program to call private API
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE recon_pnd_pool_con(x_errbuf OUT  NOCOPY VARCHAR2
                                  ,x_retcode OUT NOCOPY NUMBER
                                  ,p_pool_number IN okl_pools.POOL_NUMBER%TYPE DEFAULT NULL)
 IS
  -- Bug#2837819, 03/10/2003
  -- mvasudev, modified to take care of null khrs in pools
  CURSOR l_okl_pols_csr
  IS
  SELECT polb.id
  FROM   okl_pools polb
  WHERE EXISTS
        (SELECT '1'
         FROM   okl_pool_contents pocb
         WHERE  pocb.pol_id = polb.id
         AND    pocb.status_code = G_POC_STS_PENDING
         AND    polb.status_code = 'ACTIVE'
        );

  -- Bug#2837819, 03/10/2003
  -- mvasudev, modified to take care of null khrs in pools
  CURSOR l_okl_pol_csr(p_pool_number IN VARCHAR2)
  IS
  SELECT polb.id
  FROM   okl_pools polb
  WHERE  polb.pool_number = p_pool_number
  AND    polb.status_code = 'ACTIVE';

  l_api_name          CONSTANT VARCHAR2(40) := 'recon_pnd_pool_con';
  l_api_version       CONSTANT NUMBER       := 1.0;
  p_api_version       CONSTANT NUMBER 	    := 1.0;
  l_init_msg_list     VARCHAR2(1) := 'T';

  l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_msg_count         NUMBER;
  l_reconciled        VARCHAR2(1);
  i                   NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_error_msg_rec     Error_message_Type;

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
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_pool_number : ' || p_pool_number);
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_START));


    -- Reconcile the specified Pool
    IF (p_pool_number IS NOT NULL) THEN

	  i :=0;

	  FOR l_okl_pol_rec IN l_okl_pol_csr(p_pool_number)
	  LOOP
                IF l_okl_pol_csr%NOTFOUND THEN
                     FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'','OKL_NO_PENDING_POC'));
		ELSE
		  Okl_Pool_Pvt.reconcile_contents(p_api_version     => l_api_version
		                                ,p_init_msg_list   => l_init_msg_list
		                                ,p_pol_id          => l_okl_pol_rec.id
                                                ,p_mode          => 'ACTIVE'
		                                ,x_return_status   => l_return_status
		                                ,x_msg_count       => l_msg_count
		                                ,x_msg_data        => l_msg_data
		                                ,x_reconciled      => l_reconciled);

              IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECONCILE_CONTENTS',G_UNEXPECTED_ERROR));
                RAISE G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECONCILE_CONTENTS',G_EXPECTED_ERROR));
                RAISE G_EXCEPTION_ERROR;
              END IF;

              FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME || '.' || l_api_name || ':: p_pol_id : ' || l_okl_pol_rec.id);
              FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME || '.' || l_api_name || ':: x_reconciled : ' || l_reconciled);

			i := i + 1;
              END IF;
	  END LOOP;

	  IF  i = 0 THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_RECONCILE_ERROR));
              RAISE G_EXCEPTION_ERROR;
	  END IF;
    -- Reconcile all non-attached Pools
    ELSE
       i := 0;
       FOR l_okl_pols_rec IN l_okl_pols_csr
       LOOP
             IF l_okl_pol_csr%NOTFOUND THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'','OKL_NO_PENDING_POC'));
	     ELSE
                Okl_Pool_Pvt.reconcile_contents(p_api_version     => l_api_version
		                                ,p_init_msg_list   => l_init_msg_list
		                                ,p_pol_id          => l_okl_pols_rec.id
						,p_mode          => 'ACTIVE'
		                                ,x_return_status   => l_return_status
		                                ,x_msg_count       => l_msg_count
		                                ,x_msg_data        => l_msg_data
		                                ,x_reconciled      => l_reconciled);

            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECONCILE_CONTENTS',G_UNEXPECTED_ERROR));
              RAISE G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECONCILE_CONTENTS',G_EXPECTED_ERROR));
              RAISE G_EXCEPTION_ERROR;
            END IF;

            FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME || '.' || l_api_name || ':: p_pol_id : ' || l_okl_pols_rec.id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME || '.' || l_api_name || ':: x_reconciled : ' || l_reconciled);

            i := i + 1;
	    END IF;
       END LOOP;
    END IF;

    --FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_TOTAL_ROWS_PROCESSED) || i);
    --FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_TOTAL_ROWS_PROCESSED));
    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_END));

    Okl_Api.END_ACTIVITY(l_msg_count, l_msg_data);
    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'OKL_API.END_ACTIVITY',G_CONFIRM_PROCESS));

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

 END recon_pnd_pool_con;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : reconcile_pool_contents_ui
-- Description     : Reconcile Pool Contents - to be called from UI
--                   This is a wrapper procedure for concurrent program call from jsp/UI
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE reconcile_pool_contents_ui(
    p_api_version                  IN  NUMBER
   ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,p_pool_number                  IN  okl_pools.POOL_NUMBER%TYPE DEFAULT NULL
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_request_id                   OUT NOCOPY NUMBER)
 IS
  l_api_name VARCHAR2(30) := 'reconcile_pool_contents_ui';
  l_api_version  NUMBER := 1.0;
  l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;

BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
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
    FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
    --call concurrent program
    x_request_id := Fnd_Request.SUBMIT_REQUEST(
                             application  => 'OKL'
                             ,program     => 'OKL_RECONCILE_POOL'
                             ,argument1   => p_pool_number);

    -- Added these validations to check to see if the request has been submitted successfully.
    IF x_request_id = 0 THEN

       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_CONC_REQ_ERROR',
                           p_token1   => 'PROG_NAME',
                           p_token1_value => 'OKL Reconcile Pool CONTENTS',
                           p_token2   => 'REQUEST_ID',
                           p_token2_value => x_request_id);

       RAISE G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

	x_return_status := l_return_status;

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


 END reconcile_pool_contents_ui;

 -- Bug#2843163, mvasudev, 03/14/2003

 ----------------------------------------------------------------------------------
 -- Start of comments
 -- mvasudev
 -- Procedure Name  : cleanup_pool_contents
 -- Description     : CleanUp Pool Contents based on passed in search criteria
 --                   This is a wrapper procedure for concurrent program to call private API
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------

 PROCEDURE cleanup_pool_contents(x_errbuf OUT  NOCOPY VARCHAR2
                                ,x_retcode OUT NOCOPY NUMBER
                                ,p_pol_id IN VARCHAR2
                                ,p_currency_code IN VARCHAR2
                                ,p_multi_org                    IN VARCHAR2 DEFAULT OKL_API.G_FALSE
                                ,p_cust_object1_id1 IN VARCHAR2 DEFAULT NULL -- customer_id
                                ,p_sic_code IN VARCHAR2 DEFAULT NULL
                                ,p_dnz_chr_id IN VARCHAR2 DEFAULT NULL -- dnz_chr_id
                                ,p_pre_tax_yield_from IN VARCHAR2 DEFAULT NULL
                                ,p_pre_tax_yield_to IN VARCHAR2 DEFAULT NULL
                                ,p_book_classification IN VARCHAR2 DEFAULT NULL
                                ,p_tax_owner IN VARCHAR2 DEFAULT NULL
                                ,p_pdt_id IN VARCHAR2 DEFAULT NULL
                                ,p_start_from_date IN VARCHAR2 DEFAULT NULL
                                ,p_start_to_date IN VARCHAR2 DEFAULT NULL
                                ,p_end_from_date IN VARCHAR2 DEFAULT NULL
                                ,p_end_to_date IN VARCHAR2 DEFAULT NULL
                                ,p_asset_id IN VARCHAR2 DEFAULT NULL
                                ,p_item_id1 IN VARCHAR2 DEFAULT NULL
                                ,p_model_number IN VARCHAR2 DEFAULT NULL
                                ,p_manufacturer_name IN VARCHAR2 DEFAULT NULL
                                ,p_vendor_id1 IN VARCHAR2 DEFAULT NULL
                                ,p_oec_from IN VARCHAR2 DEFAULT NULL
                                ,p_oec_to IN VARCHAR2 DEFAULT NULL
                                ,p_residual_percentage IN VARCHAR2 DEFAULT NULL
                                ,p_sty_id IN VARCHAR2 DEFAULT NULL
                                ,p_streams_from_date IN VARCHAR2 DEFAULT NULL
                                ,p_streams_to_date IN VARCHAR2 DEFAULT NULL
                                ,p_action_code IN VARCHAR2
                                -- mvasudev, 11.5.10
                                ,p_stream_type_subclass        IN VARCHAR2 DEFAULT NULL
	                        -- end, mvasudev, 11.5.10
	                        ,p_cust_crd_clf_code           IN VARCHAR2 DEFAULT NULL
                                )
  IS

  -- Bug#2829983, v115.13
  CURSOR l_okl_pol_status_csr(p_pol_id IN NUMBER)
  IS
  SELECT status_code
  FROM   okl_pools
  WHERE  id = p_pol_id;

  CURSOR l_okl_pol_csr IS
  SELECT polv.pool_number               pool_number
        ,psts.meaning                   pool_status
        ,polv.date_created              date_created
		,polv.date_last_updated         date_last_updated
		,polv.date_last_reconciled      date_last_reconciled
		,polv.total_principal_amount    total_net_asset_net_investment
		,polv.date_total_principal_calc date_last_calculated
  FROM   OKL_POOLS polv -- to take care of org_id
        ,okc_statuses_tl psts
  WHERE  polv.id = p_pol_id
  AND    polv.status_code = psts.code
  AND    psts.LANGUAGE = USERENV('LANG');

  CURSOR l_okl_set_of_books_csr
  IS
  SELECT okls.set_of_books_id set_of_books_id
        ,glsb.name            set_of_books_name
  FROM   GL_LEDGERS_PUBLIC_V  glsb
        ,OKL_SYS_ACCT_OPTS okls
  WHERE  glsb.ledger_id =  okls.set_of_books_id;

  CURSOR l_okl_operating_unit_csr
  IS
  SELECT name
  FROM   hr_operating_units
  WHERE  organization_id = mo_global.get_current_org_id();

  CURSOR l_okl_customer_csr
  IS
  SELECT name
  FROM   OKX_PARTIES_V
  WHERE  id1 = p_cust_object1_id1;

  CURSOR l_okl_sic_csr
  IS
  SELECT name
  FROM   OKL_POOL_CUST_INDUSTRY_UV
  WHERE  code = p_sic_code;

  CURSOR l_okl_chr_csr
  IS
  SELECT contract_number
  FROM   OKC_K_HEADERS_V
  WHERE  id = p_dnz_chr_id;

  CURSOR l_okl_book_class_csr
  IS
  SELECT meaning
  FROM   FND_LOOKUPS
  WHERE lookup_type='OKL_BOOK_CLASS'
  AND NVL(start_date_active,SYSDATE) <=SYSDATE
  AND NVL(end_date_active,SYSDATE+1) > SYSDATE
  AND enabled_flag = 'Y'
  AND lookup_code = p_book_classification;

  CURSOR l_okl_tax_owner_csr
  IS
  SELECT meaning
  FROM   FND_LOOKUPS
  WHERE lookup_type='OKL_TAX_OWNER'
  AND NVL(start_date_active,SYSDATE) <=SYSDATE
  AND NVL(end_date_active,SYSDATE+1) > SYSDATE
  AND enabled_flag = 'Y'
  AND lookup_code = p_tax_owner;

  CURSOR l_okl_pdt_csr
  IS
  SELECT name
  FROM   OKL_PRODUCTS
  WHERE  id = p_pdt_id;

  CURSOR l_okl_asset_csr
  IS
  SELECT asset_number
  FROM   OKL_POOL_ASSETS_LOV_UV
  WHERE  asset_id = p_asset_id;

  CURSOR l_okl_item_csr
  IS
  SELECT name
  FROM  OKX_SYSTEM_ITEMS_V
  WHERE ID2 = OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID)
  AND   id1 = p_item_id1;

  CURSOR l_okl_vendor_csr
  IS
  SELECT name
  FROM OKX_VENDORS_V
  WHERE id1 = p_vendor_id1;

  /*
  CURSOR l_okl_strm_type_csr
  IS
  SELECT name
  FROM   okl_strm_type_v
  WHERE id = p_sty_id;
  */

  CURSOR l_okl_sty_subclass_csr
  IS
  SELECT meaning
  FROM   fnd_lookups
  WHERE  lookup_type = 'OKL_STREAM_TYPE_SUBCLASS'
  AND    lookup_code = p_stream_type_subclass;

  --Added ssdeshpa
  CURSOR l_okl_cust_crdt_clsf_csr
  IS
   SELECT MEANING AS CREDITCXLSSFCTN
   FROM   AR_LOOKUPS fndlup
   WHERE  LOOKUP_TYPE = 'AR_CMGT_CREDIT_CLASSIFICATION'
   AND LOOKUP_CODE = p_cust_crd_clf_code
   AND ENABLED_FLAG = 'Y'
   AND    SYSDATE BETWEEN NVL   (fndlup.start_date_active,sysdate)
                  AND     NVL(fndlup.end_date_active,sysdate);

  l_cust_crd_clf VARCHAR2(80);

  l_api_name          CONSTANT VARCHAR2(40) := 'cleanup_pool_contents';
  l_api_version       CONSTANT NUMBER       := 1.0;
  p_api_version       CONSTANT NUMBER 	    := 1.0;
  l_init_msg_list     VARCHAR2(1) := 'T';
  l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_msg_count         NUMBER;

  l_msg_data          VARCHAR2(2000);
  l_RecordsProcessed NUMBER := 0;
  l_error_msg_rec     Error_message_Type;

  lp_pocv_tbl   pocv_tbl_type;
  lx_poc_uv_tbl poc_uv_tbl_type;
  l_amount         NUMBER;

  -- report related fields
  l_row_num_len      NUMBER := 6;
  l_contract_num_len NUMBER := 30;
  l_asset_num_len    NUMBER := 15;
  l_lessee_len       NUMBER := 40;
  l_sty_name_len     NUMBER := 15;
  l_amount_len       NUMBER := 15;
  l_max_len          NUMBER := 150;
  l_prompt_len       NUMBER := 35;
  l_sty_subclass_len NUMBER := 25;
  -- mvasudev, 09/28/2004, Bug#3909240
  l_sty_purpose_len  NUMBER := 35;


  l_str_row_num      VARCHAR2(5);
  l_str_contract_num VARCHAR2(30);
  l_str_asset_num    VARCHAR2(15);
  l_str_lessee       VARCHAR2(50);
  l_str_sty_name     VARCHAR2(25);
  l_str_amount       VARCHAR2(15);
  l_content          VARCHAR2(1000);
  l_header_len       NUMBER;
  -- mvasudev, 09/28/2004, Bug#3909240
  l_str_sty_purpose     VARCHAR2(35);

  -- Search Parameters
  l_customer          VARCHAR2(360);
  l_customer_industry VARCHAR2(80);
  l_contract_number   VARCHAR2(120);
  l_book_class        VARCHAR2(80);
  l_tax_owner         VARCHAR2(80);
  l_product           VARCHAR2(150);
  --  l_asset_number      VARCHAR2(15);
  --  l_item              VARCHAR2(240);
  --  l_vendor            VARCHAR2(80);
  l_stream_type_subclass  VARCHAR2(150);

  l_filler            VARCHAR2(5) := RPAD(' ',5,' ');

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
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_pol_id : ' || p_pol_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_multi_org : ' || p_multi_org);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_cust_object1_id1 : ' || p_cust_object1_id1);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_sic_code : ' || p_sic_code);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dnz_chr_id : ' || p_dnz_chr_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_pre_tax_yield_from : ' || p_pre_tax_yield_from);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_pre_tax_yield_to : ' || p_pre_tax_yield_to);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_book_classification : ' || p_book_classification);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_tax_owner : ' || p_tax_owner);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_start_from_date : ' || p_start_from_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_start_to_date : ' || p_start_to_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_end_from_date : ' || p_end_from_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_end_to_date : ' || p_end_to_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_asset_id : ' || p_asset_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_item_id1 : ' || p_item_id1);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_model_number : ' || p_model_number);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_manufacturer_name : ' || p_manufacturer_name);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_vendor_id1 : ' || p_vendor_id1);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_oec_from : ' || p_oec_from);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_oec_to : ' || p_oec_to);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_residual_percentage : ' || p_residual_percentage);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_sty_id : ' || p_sty_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_stream_type_subclass : ' || p_stream_type_subclass);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_streams_from_date : ' || p_streams_from_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_streams_to_date : ' || p_streams_to_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_action_code : ' || p_action_code);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_cust_crd_clf_code : ' || p_cust_crd_clf_code);
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');


    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_START));

    -- Bug#2829983, v115.13
    FOR l_okl_pol_status_rec IN l_okl_pol_status_csr(p_pol_id)
    LOOP
      --Included 'Active' status to allow clean up adjustment pool contents -- varangan-29-11-2007
      IF l_okl_pol_status_rec.status_code NOT IN (Okl_Pool_Pvt.G_POL_STS_NEW,Okl_Pool_Pvt.G_POL_STS_ACTIVE)
      THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_POOL_NO_MODIFY));
        RAISE G_EXCEPTION_ERROR;
      END IF;
    END LOOP;

    -- Header
    l_content :=     FND_MESSAGE.GET_STRING(G_APP_NAME,G_POOL_CLEANUP_HEAD) || ' : ';
    IF p_action_code = Okl_Pool_Pvt.G_ACTION_REPORT THEN
      l_content :=   l_content ||  FND_MESSAGE.GET_STRING(G_APP_NAME,G_POOL_CLEANUP_REPORT);
	ELSIF p_action_code = Okl_Pool_Pvt.G_ACTION_REMOVE THEN
      l_content :=   l_content ||  FND_MESSAGE.GET_STRING(G_APP_NAME,G_POOL_CLEANUP_REMOVE);
	END IF;
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

	-- Pool Details
	FOR l_okl_pol_rec IN l_okl_pol_csr
	LOOP
       IF l_okl_pol_rec.pool_status = OKL_POOL_PVT.G_POL_STS_ACTIVE THEN
	         Okl_Pool_Pvt.get_tot_recei_amt_pend(p_api_version   => l_api_version
	                                       ,p_init_msg_list => l_init_msg_list
	                                       ,x_return_status => l_return_status
	                                       ,x_msg_count     => l_msg_count
	                                       ,x_msg_data      => l_msg_data
	                                       ,x_value         => l_amount
	                                       ,p_pol_id        => p_pol_id);
       ELSE
          Okl_Pool_Pvt.get_tot_recei_amt(p_api_version   => l_api_version
	                                       ,p_init_msg_list => l_init_msg_list
	                                       ,x_return_status => l_return_status
	                                       ,x_msg_count     => l_msg_count
	                                       ,x_msg_data      => l_msg_data
	                                       ,x_value         => l_amount
	                                       ,p_pol_id        => p_pol_id);
				   END IF;
        IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.get_tot_recei_amt',G_UNEXPECTED_ERROR));
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.get_tot_recei_amt',G_EXPECTED_ERROR));
          RAISE G_EXCEPTION_ERROR;
        END IF;

          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_POOL_NUMBER),l_prompt_len) || ' : ' || l_okl_pol_rec.pool_number);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_POOL_STATUS),l_prompt_len) || ' : ' || l_okl_pol_rec.pool_status);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_DATE_CREATED),l_prompt_len) || ' : ' || l_okl_pol_rec.date_created);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_LAST_UPDATE_DATE),l_prompt_len) || ' : ' || l_okl_pol_rec.date_last_updated);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_DATE_LAST_RECONCILED),l_prompt_len) || ' : ' || l_okl_pol_rec.date_last_reconciled);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_VALUE_OF_STREAMS),l_prompt_len) || ' : ' || Okl_Accounting_Util.format_amount(l_amount,p_currency_code));

		  -- mvasudev, 4/29/2003, v115.15, Bug#2924696
		  -- "Total Asset Net Investment" , "Date Last Calculated" not displayed any more
          --FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_TOTAL_ASSET_NET_INVESTMENT),l_prompt_len) || ' : ' || okl_accounting_util.format_amount(l_okl_pol_rec.total_net_asset_net_investment,p_currency_code));
          --FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_DATE_LAST_CALCULATED),l_prompt_len) || ' : ' || l_okl_pol_rec.date_last_calculated);
	END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_CURRENCY),l_prompt_len) || ' : ' || p_currency_code);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_PROGRAM_RUN_DATE),l_prompt_len) || ' : ' || SYSDATE);

	-- Search Parameters
	-- sub head
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_SEARCH_PARAMETERS);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=',LENGTH(l_content),'='));

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_CUSTOMERS);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-',LENGTH(l_content),'-'));

    -- Customer related parameters
    FOR l_okl_customer_rec IN l_okl_customer_csr
    LOOP
        l_customer := l_okl_customer_rec.name;
    END LOOP;
    FOR l_okl_sic_rec IN l_okl_sic_csr
    LOOP
        l_customer_industry := l_okl_sic_rec.name;
    END LOOP;
    --added ssdeshpa
    FOR l_okl_cust_crdt_clsf_rec IN l_okl_cust_crdt_clsf_csr
    LOOP
       l_cust_crd_clf := l_okl_cust_crdt_clsf_rec.CREDITCXLSSFCTN;
    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_CUSTOMER),l_prompt_len) || ' : ' || l_customer);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_CUSTOMER_INDUSTRY_CODE),l_prompt_len) || ' : ' || l_customer_industry);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_CUSTOMER_INDUSTRY_CODE),l_prompt_len) || ' : ' || l_cust_crd_clf);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_CONTRACTS);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-',LENGTH(l_content),'-'));

	-- Contract related Parameters
    FOR l_okl_chr_rec IN l_okl_chr_csr
	LOOP
	  l_contract_number := l_okl_chr_rec.contract_number;
	END LOOP;
	FOR l_okl_book_class_rec IN l_okl_book_class_csr
	LOOP
	  l_book_class := l_okl_book_class_rec.meaning;
	END LOOP;
	FOR l_okl_tax_owner_rec IN l_okl_tax_owner_csr
	LOOP
	  l_tax_owner := l_okl_tax_owner_rec.meaning;
	END LOOP;
	FOR l_okl_pdt_rec IN l_okl_pdt_csr
	LOOP
	  l_product := l_okl_pdt_rec.name;
	END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_CONTRACT_NUMBER),l_prompt_len) || ' : ' || l_contract_number);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_PTY_FROM),l_prompt_len) || ' : ' || p_pre_tax_yield_from);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_PTY_TO),l_prompt_len) || ' : ' || p_pre_tax_yield_to);
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_BOOK_CLASS),l_prompt_len) || ' : ' || l_book_class);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_TAX_OWNER),l_prompt_len) || ' : ' || l_tax_owner);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_START_FROM_DATE),l_prompt_len) || ' : ' || p_start_from_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_START_TO_DATE),l_prompt_len) || ' : ' || p_start_to_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_END_FROM_DATE),l_prompt_len) || ' : ' || p_end_from_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_END_TO_DATE),l_prompt_len) || ' : ' || p_end_to_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_PRODUCT),l_prompt_len) || ' : ' || l_product);

    /*
	-- Asset related Parameters
	FOR l_okl_asset_rec IN l_okl_asset_csr
	LOOP
	  l_asset_number := l_okl_asset_rec.asset_number;
    END LOOP;
	FOR l_okl_item_rec IN l_okl_item_csr
	LOOP
	  l_item := l_okl_item_rec.name;
    END LOOP;
	FOR l_okl_vendor_rec IN l_okl_vendor_csr
	LOOP
	  l_vendor := l_okl_vendor_rec.name;
    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_ASSET_NUMBER),l_prompt_len) || ' : ' || l_asset_number);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_ITEM_NUMBER),l_prompt_len) || ' : ' || l_item);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_MODEL_NUMBER),l_prompt_len) || ' : ' || p_model_number);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_MANUFACTURER),l_prompt_len) || ' : ' || p_manufacturer_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_VENDOR),l_prompt_len) || ' : ' || l_vendor);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_ASSET_COST_FROM),l_prompt_len) || ' : ' || okl_accounting_util.format_amount(p_oec_from,p_currency_code));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_ASSET_COST_TO),l_prompt_len) || ' : ' || okl_accounting_util.format_amount(p_oec_to,p_currency_code));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_RESIDUAL_PERCENTAGE),l_prompt_len) || ' : ' || p_residual_percentage);
	*/

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAMS);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-',LENGTH(l_content),'-'));
	-- Stream related  Parameters
	/*
	FOR l_okl_strm_type_rec IN l_okl_strm_type_csr
	LOOP
	  l_stream_type := l_okl_strm_type_rec.name;
	END LOOP;
	*/

	IF p_stream_type_subclass IS NOT NULL THEN
          FOR l_okl_sty_subclass_rec IN l_okl_sty_subclass_csr
          LOOP
            l_stream_type_subclass := l_okl_sty_subclass_rec.meaning;
          END LOOP;
    END IF;

    --FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAM_TYPE),l_prompt_len) || ' : ' || l_stream_type);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAM_TYPE_SUBCLASS),l_prompt_len) || ' : ' || l_stream_type_subclass);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAMS_FROM_DATE),l_prompt_len) || ' : ' || p_streams_from_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_filler || FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAMS_TO_DATE),l_prompt_len) || ' : ' || p_streams_to_date);

	-- Results
	-- sub head
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_RESULTS);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=',LENGTH(l_content),'='));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	-- count

      Okl_Pool_Pvt.cleanup_pool_contents(p_api_version         => l_api_version
                                     ,p_init_msg_list         => l_init_msg_list
                                     ,x_return_status         => l_return_status
                                     ,x_msg_count             => l_msg_count
                                     ,x_msg_data              => l_msg_data
                                     ,p_multi_org             => p_multi_org
                                     ,p_currency_code         => p_currency_code
                                     ,p_pol_id                => TO_NUMBER(p_pol_id)
                                     ,p_cust_object1_id1      => TO_NUMBER(p_cust_object1_id1)
                                     ,p_sic_code              => p_sic_code
                                     ,p_dnz_chr_id            => TO_NUMBER(p_dnz_chr_id)
                                     ,p_pre_tax_yield_from    => TO_NUMBER(p_pre_tax_yield_from)
                                     ,p_pre_tax_yield_to      => TO_NUMBER(p_pre_tax_yield_to)
                                     ,p_book_classification   => p_book_classification
                                     ,p_tax_owner             => p_tax_owner
                                     ,p_pdt_id                => TO_NUMBER(p_pdt_id)
                                     ,p_start_from_date       => fnd_date.canonical_to_date(p_start_from_date)
                                     ,p_start_to_date         => fnd_date.canonical_to_date(p_start_to_date)
                                     ,p_end_from_date         => fnd_date.canonical_to_date(p_end_from_date)
                                     ,p_end_to_date           => fnd_date.canonical_to_date(p_end_to_date)
                                     ,p_asset_id              => TO_NUMBER(p_asset_id)
                                     ,p_item_id1              => TO_NUMBER(p_item_id1)
                                     ,p_model_number          => p_model_number
                                     ,p_manufacturer_name     => p_manufacturer_name
                                     ,p_vendor_id1            => TO_NUMBER(p_vendor_id1)
                                     ,p_oec_from              => TO_NUMBER(p_oec_from)
                                     ,p_oec_to                => TO_NUMBER(p_oec_to)
                                     ,p_residual_percentage   => TO_NUMBER(p_residual_percentage)
                                     ,p_sty_id                => TO_NUMBER(p_sty_id)
                                     -- mvasudev, 11.5.10
                                     ,p_stream_type_subclass  => p_stream_type_subclass
                                     -- end, mvasudev, 11.5.10
                                     ,p_streams_from_date     => fnd_date.canonical_to_date(p_streams_from_date)
                                     ,p_streams_to_date     => fnd_date.canonical_to_date(p_streams_to_date)
                                     ,p_action_code           => p_action_code
                                     ,x_poc_uv_tbl            => lx_poc_uv_tbl
                                     ,p_cust_crd_clf_code  => p_cust_crd_clf_code);

      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.CLEANUP_POOL_CONTENTS',G_UNEXPECTED_ERROR));
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.CLEANUP_POOL_CONTENTS',G_EXPECTED_ERROR));
        RAISE G_EXCEPTION_ERROR;
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(fnd_message.get_string(G_APP_NAME,G_TOTAL_ROWS_PROCESSED),l_prompt_len) || ' : ' || lx_poc_uv_tbl.COUNT);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

      IF lx_poc_uv_tbl.COUNT > 0 THEN


    	l_content :=    RPAD('-',l_row_num_len-1,'-') || ' '
	             || RPAD('-',l_contract_num_len-1,'-') || ' '
				 || RPAD('-',l_asset_num_len-1,'-') || ' '
				 || RPAD('-',l_lessee_len-1,'-') || ' '
				 || RPAD('-',l_sty_subclass_len-1,'-') || ' '
				 || RPAD('-',l_sty_name_len-1,'-') || ' '
				 || RPAD('-',l_sty_purpose_len-1,'-') || ' '
				 || RPAD('-',l_amount_len,'-');

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

       l_content :=    RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_ROW_NUMBER),l_row_num_len-1) || ' '
	                || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_CONTRACT_NUMBER),l_contract_num_len-1) || ' '

			        || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_ASSET_NUMBER),l_asset_num_len-1) || ' '
                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_LESSEE),l_lessee_len-1) || ' '
                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAM_TYPE_SUBCLASS),l_sty_subclass_len-1) || ' '
                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAM_TYPE),l_sty_name_len-1) || ' '
                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_STREAM_TYPE_PURPOSE),l_sty_purpose_len-1) || ' '
                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,G_TOTAL_AMOUNT),l_amount_len);

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

       l_content :=    RPAD('-',l_row_num_len-1,'-') || ' '
                    || RPAD('-',l_contract_num_len-1,'-') || ' '
                    || RPAD('-',l_asset_num_len-1,'-') || ' '
                    || RPAD('-',l_lessee_len-1,'-') || ' '
                    || RPAD('-',l_sty_subclass_len-1,'-') || ' '
                    || RPAD('-',l_sty_name_len-1,'-') || ' '
                    || RPAD('-',l_sty_purpose_len-1,'-') || ' '
                    || RPAD('-',l_amount_len,'-');

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);


       FOR l_row_count IN 1..lx_poc_uv_tbl.COUNT
       LOOP
        	l_content :=    RPAD(l_row_count,l_row_num_len)
                         || RPAD(lx_poc_uv_tbl(l_row_count).contract_number ,l_contract_num_len)
                         || RPAD(lx_poc_uv_tbl(l_row_count).asset_number ,l_asset_num_len)
                         || RPAD(lx_poc_uv_tbl(l_row_count).lessee ,l_lessee_len)
                         || RPAD(lx_poc_uv_tbl(l_row_count).sty_subclass ,l_sty_subclass_len)
                         || RPAD(lx_poc_uv_tbl(l_row_count).stream_type_name ,l_sty_name_len)
                         || RPAD(lx_poc_uv_tbl(l_row_count).stream_type_purpose ,l_sty_purpose_len)
                         || LPAD(Okl_Accounting_Util.format_amount(lx_poc_uv_tbl(l_row_count).pool_amount,p_currency_code),l_amount_len);

            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_content);

        END LOOP;

		/* v115.16 , mvasudev
        IF p_action_code = Okl_Pool_Pvt.G_ACTION_REMOVE THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, get_message('Okl_Pool_Pvt.GET_TOT_PRINCIPAL_AMT','',G_PROCESS_START));
          Okl_Pool_Pvt.recal_tot_princ_amt(p_api_version     => l_api_version
                                      ,p_init_msg_list   => l_init_msg_list
                                      ,x_return_status   => l_return_status
                                      ,x_msg_count       => l_msg_count
                                      ,x_msg_data        => l_msg_data
                                      ,x_value           => l_amount
                                      ,p_pol_id          => p_pol_id);

          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Okl_Pool_Pvt.GET_TOT_PRINCIPAL_AMT:: p_pol_id : ' || p_pol_id);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Okl_Pool_Pvt.GET_TOT_PRINCIPAL_AMT:: x_value : ' || okl_accounting_util.format_amount(l_amount,p_currency_code));

          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECAL_TOT_PRINC_AMT',G_UNEXPECTED_ERROR));
            RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'Okl_Pool_Pvt.RECAL_TOT_PRINC_AMT',G_EXPECTED_ERROR));
            RAISE G_EXCEPTION_ERROR;
          END IF; -- status

        END IF; -- action_code
       */
      END IF; -- count > 0

    FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_TOTAL_ROWS_PROCESSED) || ' : ' || lx_poc_uv_tbl.COUNT);
	FND_FILE.PUT_LINE(FND_FILE.LOG, get_message(l_api_name,'',G_PROCESS_END));


	-- Errors
	-- sub head
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,G_ERRORS);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=',LENGTH(l_content),'='));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

  Okl_Api.END_ACTIVITY(l_msg_count, l_msg_data);
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

      -- print the error message in the log file

      GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_error_msg_rec(i));
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
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_error_msg_rec(i));
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
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_error_msg_rec(i));
          END LOOP;
        END IF;

  END cleanup_pool_contents;


 ----------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : cleanup_pool_contents_ui
 -- Description     : CleanUp pool contents based on passed in search criteria
 --                   This is a wrapper procedure for concurrent program call from jsp/UI
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------

 PROCEDURE cleanup_pool_contents_ui(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.g_false
   ,x_return_status                OUT nocopy VARCHAR2
   ,x_msg_count                    OUT nocopy NUMBER
   ,x_msg_data                     OUT nocopy VARCHAR2
   ,x_request_id                   OUT nocopy NUMBER
   ,p_polsrch_rec                  IN polsrch_rec_type
   -- mvasudev, 11.5.10
   ,p_stream_type_subclass         IN VARCHAR2 DEFAULT NULL
   -- end. mvaudev, 11.5.10
   ,p_multi_org                    IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,p_action_code                  IN VARCHAR2)
 IS
  l_api_name VARCHAR2(30) := 'cleanup_pool_contents_ui';
  l_api_version  NUMBER := 1.0;
  l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;

 BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
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

    -- Bug#2838721, mvasudev, 03/11/2003
    --call concurrent program
    FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request

    x_request_id := Fnd_Request.SUBMIT_REQUEST(
                             application  => 'OKL'
                             ,program     => 'OKL_CLEANUP_POOL'
                             ,argument1   => TO_CHAR(p_polsrch_rec.pol_id)
                             ,argument2   => p_polsrch_rec.currency_code
                             ,argument3   => p_multi_org
                             ,argument4   => TO_CHAR(p_polsrch_rec.cust_object1_id1)
                             ,argument5   => p_polsrch_rec.sic_code
                             ,argument6   => TO_CHAR(p_polsrch_rec.dnz_chr_id)
                             ,argument7  =>  TO_CHAR(p_polsrch_rec.pre_tax_yield_from)
                             ,argument8  =>  TO_CHAR(p_polsrch_rec.pre_tax_yield_to)
                             ,argument9  =>  p_polsrch_rec.book_classification
                             ,argument10  => p_polsrch_rec.tax_owner
                             ,argument11  => TO_CHAR(p_polsrch_rec.pdt_id)
                             ,argument12  => TO_CHAR(p_polsrch_rec.start_from_date)
                             ,argument13  => TO_CHAR(p_polsrch_rec.start_to_date)
                             ,argument14  => TO_CHAR(p_polsrch_rec.end_from_date)
                             ,argument15  => TO_CHAR(p_polsrch_rec.end_to_date)
                             ,argument16  => TO_CHAR(p_polsrch_rec.asset_id)
                             ,argument17  => TO_CHAR(p_polsrch_rec.item_id1)
                             ,argument18  => p_polsrch_rec.model_number
                             ,argument19  => p_polsrch_rec.manufacturer_name
                             ,argument20  => TO_CHAR(p_polsrch_rec.vendor_id1)
                             ,argument21  => TO_CHAR(p_polsrch_rec.oec_from)
                             ,argument22  => TO_CHAR(p_polsrch_rec.oec_to)
                             ,argument23  => TO_CHAR(p_polsrch_rec.residual_percentage)
                             ,argument24  => TO_CHAR(p_polsrch_rec.sty_id)
                             ,argument25  => TO_CHAR(p_polsrch_rec.streams_from_date)
                             ,argument26  => TO_CHAR(p_polsrch_rec.streams_to_date)
                             ,argument27  => p_action_code
			     ,argument28  => p_stream_type_subclass
			     ,argument29  => p_polsrch_rec.cust_crd_clf_code);

    -- Added these validations to check to see if the request has been submitted successfully.
    IF x_request_id = 0 THEN

       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_CONC_REQ_ERROR',
                           p_token1   => 'PROG_NAME',
                           p_token1_value => 'OKL CleanUp Pool CONTENTS',
                           p_token2   => 'REQUEST_ID',
                           p_token2_value => x_request_id);

       RAISE G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

	x_return_status := l_return_status;

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


  END cleanup_pool_contents_ui;

END Okl_Poolconc_Pvt;

/
