--------------------------------------------------------
--  DDL for Package OKL_POOLCONC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_POOLCONC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSZCS.pls 120.5 2008/01/04 08:50:23 dpsingh ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- Record type which holds the account generator rule lines.
  G_FND_APP			        CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(30) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_EXPECTED_ERROR		    CONSTANT VARCHAR2(28) := 'OKL_CONTRACTS_EXPECTED_ERROR';
  G_CONFIRM_PROCESS	    	CONSTANT VARCHAR2(19) := 'OKL_CONFIRM_PROCESS';
  G_PROCESS_START		    CONSTANT VARCHAR2(17) := 'OKL_PROCESS_START';
  G_PROCESS_END 		    CONSTANT VARCHAR2(15) := 'OKL_PROCESS_END';
  G_TOTAL_ROWS_PROCESSED	CONSTANT VARCHAR2(24) := 'OKL_TOTAL_ROWS_PROCESSED';
  G_RECONCILE_ERROR             CONSTANT VARCHAR2(20) := 'OKL_RECONCILE_ERROR';

  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_POOLCONC_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
  G_EXCEPTION_ERROR		 EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;

  -- list of request statuses
  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
  G_API_TYPE	CONSTANT VARCHAR(4) := '_PVT';

  G_OKL_TITLE                 CONSTANT VARCHAR2(9) := 'OKL_TITLE';
  G_POOL_CLEANUP_HEAD         CONSTANT VARCHAR2(20) := 'OKL_POOL_CLEANUP';
  G_POOL_CLEANUP_REPORT       CONSTANT VARCHAR2(30) := 'OKL_POOL_CLEANUP_REPORT';
  G_POOL_CLEANUP_REMOVE       CONSTANT VARCHAR2(30) := 'OKL_POOL_CLEANUP_REMOVE';
  G_SET_OF_BOOKS              CONSTANT VARCHAR2(30) := 'OKL_SET_OF_BOOKS';
  G_OPERATING_UNIT            CONSTANT VARCHAR2(30) := 'OKL_OPERATING_UNIT';

  G_POOL_NUMBER                CONSTANT VARCHAR2(15) := 'OKL_POOL_NUMBER';
  G_POOL_STATUS                CONSTANT VARCHAR2(15) := 'OKL_POOL_STATUS';
  G_DATE_CREATED               CONSTANT VARCHAR2(30) := 'OKL_CREATION_DATE';
  G_LAST_UPDATE_DATE           CONSTANT VARCHAR2(30) := 'OKL_LAST_UPDATE_DATE';
  G_DATE_LAST_RECONCILED       CONSTANT VARCHAR2(30) := 'OKL_DATE_LAST_RECONCILED';
  G_VALUE_OF_STREAMS           CONSTANT VARCHAR2(30) := 'OKL_VALUE_OF_STREAMS';
  G_TOTAL_ASSET_NET_INVESTMENT CONSTANT VARCHAR2(30) := 'OKL_TOTAL_ASSET_NET_INVESTMENT';
  G_DATE_LAST_CALCULATED       CONSTANT VARCHAR2(30) := 'OKL_DATE_LAST_CALCULATED';

  G_CURRENCY                  CONSTANT VARCHAR2(20) := 'OKL_AGN_RPT_CURRENCY';
  G_PROGRAM_RUN_DATE          CONSTANT VARCHAR2(30) := 'OKL_PROGRAM_RUN_DATE';
  G_ROW_NUMBER                CONSTANT VARCHAR2(14) := 'OKL_ROW_NUMBER';
  G_CONTRACT_NUMBER           CONSTANT VARCHAR2(25) := 'OKL_GLP_RPT_CTR_NUM_TITLE';
  G_ASSET_NUMBER              CONSTANT VARCHAR2(16) := 'OKL_ASSET_NUMBER';
  G_LESSEE                    CONSTANT VARCHAR2(10) := 'OKL_LESSEE';
  G_STREAM_TYPE               CONSTANT VARCHAR2(20) := 'OKL_MGP_REP_STY_TYPE';
  -- mvasudev, 09/28/2004, Bug#3909240
  G_STREAM_TYPE_PURPOSE  CONSTANT VARCHAR2(30) := 'OKL_STREAM_TYPE_PURPOSE';
  G_TOTAL_AMOUNT              CONSTANT VARCHAR2(16) := 'OKL_TOTAL_AMOUNT';

  G_SEARCH_PARAMETERS         CONSTANT VARCHAR2(30) := 'OKL_SEARCH_PARAMETERS' ;
  G_RESULTS                   CONSTANT VARCHAR2(15) := 'OKL_RESULTS';
  G_ERRORS                    CONSTANT VARCHAR2(30) := 'OKL_POOL_CLEANUP_ERRORS';

  -- Bug#2843163, mvasudev, 03/14/2003
  G_CUSTOMERS CONSTANT VARCHAR2(30) := 'OKL_CUSTOMERS';
  G_CONTRACTS CONSTANT VARCHAR2(30) := 'OKL_CONTRACTS';
  G_STREAMS   CONSTANT VARCHAR2(30) := 'OKL_STREAMS';
  G_NONE      CONSTANT VARCHAR2(30) := 'OKL_NONE';

  G_CUSTOMER CONSTANT VARCHAR2(30) := 'OKL_CUSTOMER';
  G_CUSTOMER_INDUSTRY_CODE CONSTANT VARCHAR2(30) := 'OKL_CUSTOMER_INDUSTRY_CODE';
  G_PTY_FROM CONSTANT VARCHAR2(30) := 'OKL_PRE_TAX_YIELD_FROM';
  G_PTY_TO CONSTANT VARCHAR2(30) := 'OKL_PRE_TAX_YIELD_TO';
  G_BOOK_CLASS CONSTANT VARCHAR2(30) := 'OKL_CONTRACT_DEAL_TYPE';
  G_TAX_OWNER CONSTANT VARCHAR2(30) := 'OKL_TAX_OWNER';
  G_START_FROM_DATE CONSTANT VARCHAR2(30) := 'OKL_START_FROM_DATE';
  G_START_TO_DATE CONSTANT VARCHAR2(30) := 'OKL_START_TO_DATE';
  G_END_FROM_DATE CONSTANT VARCHAR2(30) := 'OKL_END_FROM_DATE';
  G_END_TO_DATE CONSTANT VARCHAR2(30) := 'OKL_END_TO_DATE';
  G_PRODUCT CONSTANT VARCHAR2(30) := 'OKL_PRODUCT';
  G_ITEM_NUMBER CONSTANT VARCHAR2(30) := 'OKL_ITEM_NUMBER';
  G_MODEL_NUMBER CONSTANT VARCHAR2(30) := 'OKL_MODEL_NUMBER';
  G_MANUFACTURER CONSTANT VARCHAR2(30) := 'OKL_MANUFACTURER_NAME';
  G_VENDOR CONSTANT VARCHAR2(30) := 'OKL_VENDOR';
  G_ASSET_COST_FROM CONSTANT VARCHAR2(30) := 'OKL_ASSET_COST_FROM';
  G_ASSET_COST_TO CONSTANT VARCHAR2(30) := 'OKL_ASSET_COST_TO';
  G_RESIDUAL_PERCENTAGE CONSTANT VARCHAR2(30) := 'OKL_RESIDUAL_PERCENTAGE';
  G_STREAMS_FROM_DATE CONSTANT VARCHAR2(30) := 'OKL_STREAMS_FROM_DATE';
  G_STREAMS_TO_DATE CONSTANT VARCHAR2(30) := 'OKL_STREAMS_TO_DATE';


  G_STREAM_TYPE_SUBCLASS CONSTANT VARCHAR2(25) := 'OKL_STREAM_TYPE_SUBCLASS';
  G_CUST_CRDT_CLASSIFICATION CONSTANT VARCHAR2(30) := 'OKL_CUST_CRDT_CLASSIFICATION';
  G_FINAL_DATE CONSTANT DATE := TO_DATE('1','j');
  G_DATE_FORMAT_MASK VARCHAR2(30) := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');

  TYPE error_message_type IS TABLE OF VARCHAR2(2000)
  INDEX BY BINARY_INTEGER;

  SUBTYPE polsrch_rec_type IS Okl_Pool_Pvt.polsrch_rec_type;
  SUBTYPE pocv_rec_type    IS Okl_Pool_Pvt.pocv_rec_type;
  SUBTYPE pocv_tbl_type    IS Okl_Pool_Pvt.pocv_tbl_type;
  SUBTYPE poc_uv_rec_type  IS Okl_Pool_Pvt.poc_uv_rec_type;
  SUBTYPE poc_uv_tbl_type  IS Okl_Pool_Pvt.poc_uv_tbl_type;

 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
 ----------------------------------------------------------------------------
 -- Global Exception
 ----------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ----------------------------------------------------------------------------
 -- Procedures and Functions
 ------------------------------------------------------------------------------
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
                                ,p_stream_type_subclass                IN VARCHAR2 DEFAULT NULL
                                --Bug # 6691554 ssdeshpa Start
                                ,p_cust_crd_clf_code                   IN VARCHAR2 DEFAULT NULL
                                --Bug # 6691554 ssdeshpa End
                                );

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
   ,p_multi_org                    IN VARCHAR2 DEFAULT OKL_API.G_FALSE);

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
                             ,p_pool_number IN okl_pools.POOL_NUMBER%TYPE DEFAULT NULL);

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
   ,p_pool_number IN okl_pools.POOL_NUMBER%TYPE DEFAULT NULL);

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
                                  ,p_pool_number IN okl_pools.POOL_NUMBER%TYPE DEFAULT NULL);

----------------------------------------------------------------------------------

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
                                  ,p_pool_number IN okl_pools.POOL_NUMBER%TYPE DEFAULT NULL);

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : reconcile_pool_contents
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
   ,x_request_id                   OUT NOCOPY NUMBER);

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
				,p_stream_type_subclass IN VARCHAR2 DEFAULT NULL
				-- end, mvasudev, 11.5.10
                                --Bug # 6691554 ssdeshpa Start
                                ,p_cust_crd_clf_code                   IN VARCHAR2 DEFAULT NULL
                                --Bug # 6691554 ssdeshpa End
				);


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
   ,p_stream_type_subclass        IN VARCHAR2 DEFAULT NULL
   -- end, mvasudev, 11.5.10
   ,p_multi_org                    IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,p_action_code                  IN VARCHAR2);


END Okl_Poolconc_Pvt;

/
