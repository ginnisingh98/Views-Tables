--------------------------------------------------------
--  DDL for Package OKL_POOL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_POOL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSZPS.pls 120.9 2007/12/26 10:14:52 sosharma ship $ */
 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_POOL_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

 G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
 G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
 G_RET_STS_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
 G_EXCEPTION_ERROR		 EXCEPTION;
 G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;

 G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
 G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

 -- mvasudev
  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
  G_API_TYPE	CONSTANT VARCHAR(4) := '_PVT';

-- cklee
 G_NET_INVESTMENT_DF           CONSTANT VARCHAR2(50) := 'CONTRACT_NET_INVESTMENT_DF';
 G_NET_INVESTMENT_LOAN         CONSTANT VARCHAR2(50) := 'CONTRACT_NET_INVESTMENT_LOAN';
 G_NET_INVESTMENT_OP           CONSTANT VARCHAR2(50) := 'CONTRACT_NET_INVESTMENT_OP';
 G_NET_INVESTMENT_OTHERS       CONSTANT VARCHAR2(50) := 'OTHERS';

 G_DEAL_TYPE_LEASEDF           CONSTANT VARCHAR2(30) := 'LEASEDF';
 G_DEAL_TYPE_LEASEOP           CONSTANT VARCHAR2(30) := 'LEASEOP';
 G_DEAL_TYPE_LEASEST           CONSTANT VARCHAR2(30) := 'LEASEST';
 G_DEAL_TYPE_LOAN              CONSTANT VARCHAR2(30) := 'LOAN';

 -- mvasudev
 G_DEFAULT_NUM  CONSTANT NUMBER := 0;
 G_DEFAULT_CHAR CONSTANT VARCHAR2(1) := 'X';
 G_DEFAULT_DATE CONSTANT DATE := TO_DATE('1111','YYYY');
 G_FINAL_DATE   CONSTANT    DATE    	:= TO_DATE('1','j') + 5300000;

 G_ACTION_REPORT CONSTANT VARCHAR2(3) := 'REP';
 G_ACTION_REMOVE CONSTANT VARCHAR2(3) := 'REM';

/* ankushar 26-JUL-2007
    Bug#6000531
    start changes
 */
 G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
 G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
/* ankushar end changes 26-Jul-2007*/

 -- Bug#2829983
 G_POL_STS_NEW      CONSTANT VARCHAR2(3)  := 'NEW';
 G_POL_STS_ACTIVE   CONSTANT VARCHAR2(6)  := 'ACTIVE';
 G_POL_STS_INACTIVE CONSTANT VARCHAR2(8)  := 'INACTIVE';
 -- cklee 04/15/03
 G_POL_STS_EXPIRED CONSTANT VARCHAR2(10)  := 'EXPIRED';

 -- cklee 04/15/03
 G_POC_STS_NEW      CONSTANT VARCHAR2(3)  := 'NEW';
 G_POC_STS_ACTIVE   CONSTANT VARCHAR2(6)  := 'ACTIVE';
 G_POC_STS_INACTIVE CONSTANT VARCHAR2(8)  := 'INACTIVE';
 G_POC_STS_EXPIRED CONSTANT VARCHAR2(10)  := 'EXPIRED';
  --Added by kthiruva for Bug 6640050
 G_POC_STS_PENDING CONSTANT VARCHAR2(10)  := 'PENDING';
/*
Direct Finance Lease and Sales Type Lease - CONTRACT_NET_INVESTMENT_DF

Loan contracts - CONTRACT_NET_INVESTMENT_LOAN

Operating Leases - CONTRACT_NET_INVESTMENT_OP
*/
 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
 SUBTYPE polv_rec_type IS OKL_POL_PVT.polv_rec_type;
 SUBTYPE polv_tbl_type IS OKL_POL_PVT.polv_tbl_type;
 SUBTYPE pocv_rec_type IS OKL_POC_PVT.pocv_rec_type;
 SUBTYPE pocv_tbl_type IS OKL_POC_PVT.pocv_tbl_type;
 SUBTYPE poxv_rec_type IS OKL_POX_PVT.poxv_rec_type;
 SUBTYPE poxv_tbl_type IS OKL_POX_PVT.poxv_tbl_type;

  TYPE polsrch_rec_type IS RECORD (
CUST_OBJECT1_ID1                           hz_parties.PARTY_ID%TYPE := NULL --NUMBER(15)
,LESSEE                                    hz_parties.PARTY_NAME%TYPE := NULL --VARCHAR2(360)
,SIC_CODE                                  hz_parties.SIC_CODE%TYPE := NULL --VARCHAR2(30)
,DNZ_CHR_ID                                OKC_K_HEADERS_B.ID%TYPE := NULL --NUMBER
,CONTRACT_NUMBER                           OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE := NULL --VARCHAR2(120)
,PRE_TAX_YIELD_FROM                        OKL_K_HEADERS.PRE_TAX_YIELD%TYPE := NULL--NUMBER
,PRE_TAX_YIELD_TO                          OKL_K_HEADERS.PRE_TAX_YIELD%TYPE := NULL--NUMBER
,BOOK_CLASSIFICATION                       OKL_K_HEADERS.DEAL_TYPE%TYPE := NULL --VARCHAR2(30)
,PDT_ID                                    OKL_K_HEADERS.PDT_ID%TYPE := NULL--NUMBER
,START_FROM_DATE                           OKC_K_HEADERS_B.START_DATE%TYPE := NULL --DATE
,START_TO_DATE                             OKC_K_HEADERS_B.START_DATE%TYPE := NULL --DATE
,END_FROM_DATE                             OKC_K_HEADERS_B.END_DATE%TYPE := NULL --DATE
,END_TO_DATE                               OKC_K_HEADERS_B.END_DATE%TYPE := NULL --DATE
,OPERATING_UNIT                            OKC_K_HEADERS_B.AUTHORING_ORG_ID%TYPE := NULL--NUMBER
,CURRENCY_CODE                             OKC_K_HEADERS_B.CURRENCY_CODE%TYPE := NULL --VARCHAR2(15)
,TAX_OWNER                                 okc_rules_b.RULE_INFORMATION1%TYPE := NULL --VARCHAR2(450)
,KLE_ID                                    okc_k_lines_b.ID%TYPE := NULL--NUMBER
,ASSET_ID                                  okx_assets_v.ASSET_ID%TYPE := NULL--NUMBER(15)
,ASSET_NUMBER                              okx_assets_v.ASSET_NUMBER%TYPE := NULL --VARCHAR2(15)
,MODEL_NUMBER                              okx_assets_v.MODEL_NUMBER%TYPE := NULL --VARCHAR2(40)
,MANUFACTURER_NAME                         okx_assets_v.MANUFACTURER_NAME%TYPE := NULL --VARCHAR2(30)
,LOCATION_ID                               okx_ast_dst_hst_v.LOCATION_ID%TYPE := NULL--NUMBER(15)
,ITEM_ID1                                  okx_system_items_v.ID1%TYPE := NULL--NUMBER
,VENDOR_ID1                                okx_vendors_v.ID1%TYPE := NULL--NUMBER
,OEC_FROM                                  okl_k_lines.OEC%TYPE := NULL--NUMBER(14,3)
,OEC_TO                                    okl_k_lines.OEC%TYPE := NULL--NUMBER(14,3)
,RESIDUAL_PERCENTAGE                       okl_k_lines.residual_percentage%TYPE := NULL--NUMBER(5,2)
,STY_ID                                    okl_streams.STY_ID%TYPE := NULL--NUMBER
,STREAM_TYPE_CODE                          okl_strm_type_v.CODE%TYPE := NULL --VARCHAR2(150)
,STREAM_TYPE_NAME                          okl_strm_type_v.NAME%TYPE := NULL --VARCHAR2(150)
,STREAM_SAY_CODE                           okl_streams.SAY_CODE%TYPE := NULL --VARCHAR2(30)
,STREAM_ACTIVE_YN                          okl_streams.ACTIVE_YN%TYPE := NULL --VARCHAR2(3)
,STREAM_ELEMENT_FROM_DATE                  okl_strm_elements.STREAM_ELEMENT_DATE%TYPE := NULL --DATE
,STREAM_ELEMENT_TO_DATE                    okl_strm_elements.STREAM_ELEMENT_DATE%TYPE := NULL --DATE
,STREAM_ELEMENT_AMOUNT                     okl_strm_elements.AMOUNT%TYPE := NULL--NUMBER(14,3)
,POL_ID                                    OKL_POOL_CONTENTS.POL_ID%TYPE --NUMBER
-- use the following column STREAMS_FROM_DATE, STREAMS_TO_DATE for the okl_pool_contents_uv.STREAMS_FROM_DATE range search
,STREAMS_FROM_DATE                         OKL_POOL_CONTENTS.STREAMS_FROM_DATE%TYPE := NULL --DATE
,STREAMS_TO_DATE                           OKL_POOL_CONTENTS.STREAMS_TO_DATE%TYPE := NULL --DATE
,STREAM_ELEMENT_PAYMENT_FREQ               okl_time_units_v.NAME%TYPE := NULL -- VARCHAR2(80)
,CUST_CRD_CLF_CODE                         AR_LOOKUPS.LOOKUP_CODE%TYPE := NULL --VARCHAR2(80)
);

  TYPE polsrch_tbl_type IS TABLE OF polsrch_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE poc_uv_rec_type IS RECORD
  (
    poc_id            NUMBER := OKC_API.G_MISS_NUM
   ,contract_number   OKL_POOL_CONTENTS_UV.CONTRACT_NUMBER%TYPE  := OKC_API.G_MISS_CHAR
   ,asset_number      OKL_POOL_CONTENTS_UV.ASSET_NUMBER%TYPE     := OKC_API.G_MISS_CHAR
   ,lessee            OKL_POOL_CONTENTS_UV.LESSEE%TYPE           := OKC_API.G_MISS_CHAR
   ,stream_type_name  OKL_POOL_CONTENTS_UV.STREAM_TYPE_NAME%TYPE := OKC_API.G_MISS_CHAR
   ,pool_amount       NUMBER := OKC_API.G_MISS_NUM
   ,sty_subclass_code OKL_POOL_CONTENTS_UV.STY_SUBCLASS_CODE%TYPE := OKC_API.G_MISS_CHAR
   ,sty_subclass      OKL_POOL_CONTENTS_UV.STY_SUBCLASS%TYPE := OKC_API.G_MISS_CHAR
   -- mvasudev, 09/28/2004, Bug#3909240
   ,stream_type_purpose OKL_POOL_CONTENTS_UV.STREAM_TYPE_PURPOSE%TYPE := OKC_API.G_MISS_CHAR
  );

  TYPE poc_uv_tbl_type IS TABLE OF poc_uv_rec_type
        INDEX BY BINARY_INTEGER;

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
-- Procedure Name  : create_pool
-- Description     : wrapper api for create pool
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_pool(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_polv_rec                     IN polv_rec_type
   ,x_polv_rec                     OUT NOCOPY polv_rec_type
 );
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_pool
-- Description     : wrapper api for update pool
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_polv_rec                     IN polv_rec_type
   ,x_polv_rec                     OUT NOCOPY polv_rec_type
 );
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_pool
-- Description     : wrapper api for delete pool
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_pool(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_polv_rec                     IN polv_rec_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_pool_contents
-- Description     : wrapper api for create pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pocv_rec                     IN pocv_rec_type
   ,x_pocv_rec                     OUT NOCOPY pocv_rec_type
 );
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_pool_contents
-- Description     : wrapper api for create pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pocv_tbl                     IN pocv_tbl_type
   ,x_pocv_tbl                     OUT NOCOPY pocv_tbl_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_pool_contents
-- Description     : wrapper api for update pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pocv_rec                     IN pocv_rec_type
   ,x_pocv_rec                     OUT NOCOPY pocv_rec_type
 );
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_pool_contents
-- Description     : wrapper api for update pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pocv_tbl                     IN pocv_tbl_type
   ,x_pocv_tbl                     OUT NOCOPY pocv_tbl_type
 );


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_pool_contents
-- Description     : wrapper api for delele pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pocv_rec                     IN pocv_rec_type
 );
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_pool_contents
-- Description     : wrapper api for delele pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE delete_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pocv_tbl                     IN pocv_tbl_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_pool_transaction
-- Description     : wrapper api for create pool transaction
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_pool_transaction(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_poxv_rec                     IN poxv_rec_type
   ,x_poxv_rec                     OUT NOCOPY poxv_rec_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_pool_transaction
-- Description     : wrapper api for update pool transaction
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool_transaction(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_poxv_rec                     IN poxv_rec_type
   ,x_poxv_rec                     OUT NOCOPY poxv_rec_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_pool_transaction
-- Description     : wrapper api for delete pool transaction
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_pool_transaction(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_poxv_rec                     IN poxv_rec_type
 );

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_pool_stream_amout
-- Description     : get stream elements amount from pool contents by okl_pool_contents.id
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_pool_stream_amout(
  p_poc_id IN okl_pool_contents.id%TYPE
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (get_pool_stream_amout, TRUST);
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_tot_receivable_amt
-- Description     : get stream elements amount from pool contents by okl_pools.id
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_tot_receivable_amt(
  p_pol_id IN okl_pools.id%TYPE
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (get_tot_receivable_amt, TRUST);

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_tot_receivable_amt
-- Description     : wrapper api for get_tot_receivable_amt
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE get_tot_recei_amt(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY NUMBER
   ,p_pol_id                       IN  okl_pools.id%TYPE
 );
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_tot_receivable_amt
-- Description     : wrapper api for get_tot_receivable_amt by investor agreement ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE get_tot_receivable_amt(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY NUMBER
   ,p_khr_id                       IN  okc_k_headers_b.id%TYPE
 );
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_tot_principal_amt
-- Description     : get asset principal amount from pool contents by okl_pools.id
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_tot_principal_amt(
  p_pol_id IN okl_pools.id%TYPE
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (get_tot_principal_amt, TRUST);
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : recal_tot_principal_amt
-- Description     : wrapper api for get_tot_principal_amt
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE recal_tot_princ_amt(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY NUMBER
   ,p_pol_id                       IN  okl_pools.id%TYPE
 );
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : recal_tot_principal_amt
-- Description     : wrapper api for get_tot_principal_amt by investor agreement ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0

-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE recal_tot_principal_amt(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY NUMBER
   ,p_khr_id                       IN  okc_k_headers_b.id%TYPE
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : add_pool_contents
-- Description     : creates pool contents based on passed in search criteria
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
-- Create by Search Criteria:	Query Streams from contracts + Create

 PROCEDURE add_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_row_count                    OUT NOCOPY NUMBER
   ,p_currency_code                IN VARCHAR2
   ,p_pol_id                       IN NUMBER
   ,p_multi_org                    IN VARCHAR2 DEFAULT okl_api.g_true
   ,p_cust_object1_id1             IN NUMBER DEFAULT NULL
   ,p_sic_code                     IN VARCHAR2 DEFAULT NULL
   ,p_khr_id                       IN NUMBER DEFAULT NULL
   ,p_pre_tax_yield_from           IN NUMBER DEFAULT NULL
   ,p_pre_tax_yield_to             IN NUMBER DEFAULT NULL
   ,p_book_classification          IN VARCHAR2 DEFAULT NULL
   ,p_tax_owner                    IN VARCHAR2 DEFAULT NULL
   ,p_pdt_id                       IN NUMBER DEFAULT NULL
   ,p_start_date_from              IN DATE DEFAULT NULL
   ,p_start_date_to                IN DATE DEFAULT NULL
   ,p_end_date_from                IN DATE DEFAULT NULL
   ,p_end_date_to                  IN DATE DEFAULT NULL
   ,p_asset_id                     IN NUMBER DEFAULT NULL
   ,p_item_id1                     IN NUMBER DEFAULT NULL
   ,p_model_number                 IN VARCHAR2 DEFAULT NULL
   ,p_manufacturer_name            IN VARCHAR2 DEFAULT NULL
   ,p_vendor_id1                   IN NUMBER DEFAULT NULL
   ,p_oec_from                     IN NUMBER DEFAULT NULL
   ,p_oec_to                       IN NUMBER DEFAULT NULL
   ,p_residual_percentage          IN NUMBER DEFAULT NULL
   ,p_sty_id1                      IN NUMBER DEFAULT NULL
   ,p_sty_id2                      IN NUMBER DEFAULT NULL
-- start added by cklee 08/06/03
   ,p_stream_type_subclass         IN VARCHAR2 DEFAULT NULL
-- end added by cklee 08/06/03
   ,p_stream_element_from_date     IN DATE DEFAULT NULL
   ,p_stream_element_to_date       IN DATE DEFAULT NULL
   ,p_stream_element_payment_freq  IN VARCHAR2 DEFAULT NULL
/* ankushar 26-JUL-2007 Bug#6000531 start changes */
   ,p_log_message 	               IN VARCHAR2 DEFAULT 'Y'
 /* ankushar end changes 26-Jul-2007*/
  ,p_cust_crd_clf_code            IN VARCHAR2 DEFAULT NULL);
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : cleanup_pool_contents
-- Description     : removes pool contents based on passed in search criteria
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
-- Create by Search Criteria:	Query Streams from contracts + Create

  PROCEDURE cleanup_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_currency_code                IN VARCHAR2
   ,p_pol_id                       IN  NUMBER
   ,p_multi_org                    IN VARCHAR2 DEFAULT okl_api.g_true
   ,p_cust_object1_id1             IN NUMBER DEFAULT NULL
   ,p_sic_code                     IN VARCHAR2 DEFAULT NULL
   ,p_dnz_chr_id                   IN NUMBER DEFAULT NULL
   ,p_pre_tax_yield_from           IN NUMBER DEFAULT NULL
   ,p_pre_tax_yield_to             IN NUMBER DEFAULT NULL
   ,p_book_classification          IN VARCHAR2 DEFAULT NULL
   ,p_tax_owner                    IN VARCHAR2 DEFAULT NULL
   ,p_pdt_id                       IN NUMBER DEFAULT NULL
   ,p_start_from_date              IN DATE DEFAULT NULL
   ,p_start_to_date                IN DATE DEFAULT NULL
   ,p_end_from_date                IN DATE DEFAULT NULL
   ,p_end_to_date                  IN DATE DEFAULT NULL
   ,p_asset_id                     IN NUMBER DEFAULT NULL
   ,p_item_id1                     IN NUMBER DEFAULT NULL
   ,p_model_number                 IN VARCHAR2 DEFAULT NULL
   ,p_manufacturer_name            IN VARCHAR2 DEFAULT NULL
   ,p_vendor_id1                   IN NUMBER DEFAULT NULL
   ,p_oec_from                     IN NUMBER DEFAULT NULL
   ,p_oec_to                       IN NUMBER DEFAULT NULL
   ,p_residual_percentage          IN NUMBER DEFAULT NULL
   ,p_sty_id                       IN NUMBER DEFAULT NULL
-- start added by cklee 08/06/03
   ,p_stream_type_subclass IN VARCHAR2 DEFAULT NULL
-- end added by cklee 08/06/03
   ,p_streams_from_date            IN DATE DEFAULT NULL
   ,p_streams_to_date              IN DATE DEFAULT NULL
   ,p_action_code                  IN VARCHAR2 DEFAULT G_ACTION_REPORT
   ,x_poc_uv_tbl                   OUT NOCOPY poc_uv_tbl_type
   ,p_cust_crd_clf_code            IN VARCHAR2 DEFAULT NULL);
----------------------------------------------------------------------------------
-- Start of comments
-- mvasudev
-- Procedure Name  : reconcile_contents
-- Description     : reconcile pool contents based on the pool
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE reconcile_contents(p_api_version                  IN NUMBER
                              ,p_init_msg_list                IN VARCHAR2
                              ,p_pol_id                       IN NUMBER
                              ,p_mode                         IN VARCHAR2 DEFAULT NULL
                              ,x_return_status                OUT NOCOPY VARCHAR2
                              ,x_msg_count                    OUT NOCOPY NUMBER
                              ,x_msg_data                     OUT NOCOPY VARCHAR2
                              ,x_reconciled                   OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_pool_status_active
-- Description     : updates a pool header, and contents' status.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool_status_active(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pol_id                       IN okl_pools.id%TYPE);

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_pool_status_expired
-- Description     : updates a pool header, and contents' status.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool_status_expired(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pol_id                       IN okl_pools.id%TYPE);

----------------------------------------------------------------------------------
-- Start of comments
--  mvasudev
-- Procedure Name  : get_total_stream_amount
-- Description     : Gets the Total Stream Amount for a given POC using the stm_id
--                   regardless of its status
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE get_total_stream_amount(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_poc_id                       IN  okl_pool_contents.id%TYPE
   ,p_stm_id                       IN okl_streams.id%TYPE
   ,x_amount                       OUT NOCOPY NUMBER
 );

----------------------------------------------------------------------------------
-- Start of comments
--  ankushar
-- Procedure Name  : validate_pool
-- Description     : Validates the pool when called from the public API OKL_POOL_PUB
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
/**

/* ankushar 26-JUL-2007
    Bug#6000531
    start changes
 */
   PROCEDURE validate_pool(
     p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2
    ,p_api_name 	         	    IN VARCHAR2
    ,p_polv_rec                     IN polv_rec_type
    ,p_action                       IN VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    );
/* ankushar end changes 26-Jul-2007*/

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_tot_recei_amt_pend
-- Description     : wrapper api for get_tot_receivable_amt_for_pend by investor agreement ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE get_tot_recei_amt_pend(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY NUMBER
   ,p_pol_id                       IN  okl_pools.id%TYPE
 );
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_tot_recv_amt_for_pend
-- Description     : get asset principal amount from pool contents by okl_pools.id
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_tot_recv_amt_for_pend(
  p_pol_id IN okl_pools.id%TYPE
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (get_tot_recv_amt_for_pend, TRUST);

END Okl_Pool_Pvt;

/
