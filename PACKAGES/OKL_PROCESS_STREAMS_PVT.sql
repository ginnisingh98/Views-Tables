--------------------------------------------------------
--  DDL for Package OKL_PROCESS_STREAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_STREAMS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPSRS.pls 120.5 2005/11/23 11:21:52 kthiruva noship $ */
  G_UNEXPECTED_ERROR                CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN                   CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN                   CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_PKG_NAME                        CONSTANT VARCHAR2(200) := 'OKL_PROCESS_STREAMS_PVT' ;
  G_APP_NAME                        CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
  G_FALSE				            CONSTANT VARCHAR2(1)   :=  OKL_API.G_FALSE;
  G_EXC_NAME_ERROR		            CONSTANT VARCHAR2(50)  := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	        CONSTANT VARCHAR2(50)  := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	                CONSTANT VARCHAR2(6) := 'OTHERS';
  G_RET_STS_SUCCESS		            CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		            CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		        CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
  G_EXCEPTION_ERROR			  		EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;
  G_EXCEPTION_EXCEPTION_DATA		EXCEPTION;
-- The value for this constant is from FND LOOKUPs where Lookup Type = OKL_STREAM_GENERATOR
G_STREAM_GENERATOR CONSTANT VARCHAR2(4) := 'STMP';
G_STREAM_GENERATOR_MANL CONSTANT VARCHAR2(4) := 'MANL';
-- by default the Activity of a stream is 'Working';
G_STREAM_ACTIVITY_WORK CONSTANT VARCHAR2(4) := 'WORK';
G_STREAM_ACTIVITY_HIST CONSTANT VARCHAR2(4) := 'HIST';
-- by deafult a stream is inactive
G_STREAM_ACTIVE_YN CONSTANT VARCHAR2(3) := 'N';
-- message name defined in FND MESSAGES for NO STREAM DATA FOUND
G_NO_STREAM_DATA_MSG_NAME CONSTANT VARCHAR2(40) := 'OKL_STREAMS_INTERFACE_NO_DATA';
G_EXCEPTION_DATA_MSG_NAME CONSTANT VARCHAR2(40) := 'OKL_STRMS_INTR_EXCEPTION_DATA';
-- New line chanracter
G_NEW_LINE CONSTANT VARCHAR2(40) := FND_GLOBAL.NEWLINE;
--smahapat 11/10/02 multi-gaap - addition
G_PURPOSE_CODE_REPORT VARCHAR2(10) := 'REPORT';
  SUBTYPE selv_tbl_type IS Okl_Streams_Pub.selv_tbl_type;
  SUBTYPE stmv_rec_type IS Okl_Streams_Pub.stmv_rec_type;
  SUBTYPE stmv_tbl_type IS Okl_Streams_Pub.stmv_tbl_type;
  SUBTYPE sirv_rec_type IS okl_sir_pvt.sirv_rec_type;
  SUBTYPE LOG_MSG_TBL_TYPE IS OKL_STREAMS_UTIL.LOG_MSG_TBL;
  SUBTYPE srlv_tbl_type IS okl_srl_pvt.okl_sif_ret_levels_v_tbl_type;
  --SUBTYPE siyv_tbl_type IS okl_srl_pvt.siyv_tbl_type;
  SUBTYPE trqv_rec_type IS okl_trq_pvt.trqv_rec_type;
  SUBTYPE pdtv_rec_type      IS okl_setupproducts_pvt.pdtv_rec_type;
  SUBTYPE pdt_param_rec_type IS okl_setupproducts_pvt.pdt_parameters_rec_type;
  -- for Principal Paydown
  SUBTYPE payment_rec_type IS okl_cs_principal_paydown_pvt.payment_rec_type;
  SUBTYPE payment_tbl_type IS okl_cs_principal_paydown_pvt.payment_tbl_type;

  TYPE yields_rec_type IS RECORD (
    yield_name                     OKL_SIF_YIELDS.YIELD_NAME%TYPE ,-- := OKC_API.G_MISS_CHAR,
--    effective_pre_tax_yield        OKL_SIF_RETS_V.EFFECTIVE_PRE_TAX_YIELD%TYPE := OKC_API.G_MISS_NUM,
--	effective_after_tax_yield        OKL_SIF_RETS_V.EFFECTIVE_AFTER_TAX_YIELD%TYPE := OKC_API.G_MISS_NUM,
--	nominal_pre_tax_yield          OKL_SIF_RETS_V.NOMINAL_PRE_TAX_YIELD%TYPE := OKC_API.G_MISS_NUM,
--	nominal_after_tax_yield          OKL_SIF_RETS_V.NOMINAL_AFTER_TAX_YIELD%TYPE := OKC_API.G_MISS_NUM,
	value                          OKL_SIF_RETS_V.EFFECTIVE_PRE_TAX_YIELD%TYPE := OKC_API.G_MISS_NUM,
    implicit_interest_rate         OKL_SIF_RETS_V.IMPLICIT_INTEREST_RATE%TYPE := OKC_API.G_MISS_NUM,
    method                         OKL_SIF_YIELDS_V.METHOD%TYPE := OKC_API.G_MISS_CHAR,
    array_type                     OKL_SIF_YIELDS_V.ARRAY_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    roe_type                       OKL_SIF_YIELDS_V.ROE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    roe_base                       OKL_SIF_YIELDS_V.ROE_BASE%TYPE := OKC_API.G_MISS_CHAR,
    compounded_method              OKL_SIF_YIELDS_V.COMPOUNDED_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    target_value                   NUMBER := OKC_API.G_MISS_NUM,
    index_number                   NUMBER := OKC_API.G_MISS_NUM,
    nominal_yn                     OKL_SIF_YIELDS_V.NOMINAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    pre_tax_yn                      OKL_SIF_YIELDS_V.PRE_TAX_YN%TYPE := OKC_API.G_MISS_CHAR);
  TYPE yields_tbl_type IS TABLE OF yields_rec_type INDEX BY BINARY_INTEGER;
  -- 04/29/2002 , MVASUDEV
  G_MSG_TYPE CONSTANT VARCHAR2(3) := 'XML';
  G_MSG_STD CONSTANT VARCHAR2(3) := 'W3C';
  G_PROTOCOL_TYPE CONSTANT VARCHAR2(4) := 'http';
  G_PROTOCOL_ADDRESS CONSTANT VARCHAR2(100) := 'http://www.oracle.com';
  G_INBOUND_QUEUE     CONSTANT VARCHAR2(11) := 'ECX_INBOUND';
  G_TRANSACTION_QUEUE CONSTANT VARCHAR2(15) := 'ECX_TRANSACTION';
-- INFO:
--  This Procedure gets the STREAMS from RETURN INTERFACE TABLES and insert into OKL STREAMS TABLE
--  Updates Yields at Contract Header and Updates Transaction Status in Interface Tables
-- END INFO
PROCEDURE PROCESS_STREAM_RESULTS(p_api_version        IN     NUMBER
                                ,p_init_msg_list      IN     VARCHAR2
	                        ,p_transaction_number IN     NUMBER
                                ,x_return_status      OUT    NOCOPY VARCHAR2
                                ,x_msg_count          OUT    NOCOPY NUMBER
                                ,x_msg_data           OUT    NOCOPY VARCHAR2);
  PROCEDURE PROCESS_REST_STRM_RESLTS(p_api_version        IN     NUMBER
                                        ,p_init_msg_list      IN     VARCHAR2
	                                    ,p_transaction_number IN     NUMBER
                                        ,x_return_status      OUT    NOCOPY VARCHAR2
                                        ,x_msg_count          OUT    NOCOPY NUMBER
                                        ,x_msg_data           OUT    NOCOPY VARCHAR2);
-- INFO:
--  This Procedure updates the SAY_CODE of existing Streams for a Contract to HISTORY from WORKING
-- END INFO
PROCEDURE UPDATE_STREAMS_ACTIVITY(p_api_version        IN    NUMBER
                                 ,p_init_msg_list      IN     VARCHAR2
                                 ,x_return_status      OUT    NOCOPY VARCHAR2
                                 ,x_msg_count          OUT    NOCOPY NUMBER
                                 ,x_msg_data           OUT    NOCOPY VARCHAR2
	                             ,p_khr_id             IN     NUMBER);
  FUNCTION calculate_present_value(p_future_amount    IN NUMBER,
                                   p_discount_rate    IN NUMBER,
                                   p_periods_per_year IN NUMBER,
                                   p_total_periods    IN NUMBER) RETURN NUMBER;
-- INFO:
--  This Procedure creates Service Line Streams;
-- END INFO
  PROCEDURE GEN_SERV_MAIN_LINE_STRMS(p_api_version        IN     NUMBER
                                   ,p_init_msg_list      IN     VARCHAR2
								   ,p_khr_id             IN NUMBER
                                   ,p_transaction_number IN NUMBER
								   ,p_reporting_streams  IN VARCHAR2
                                   ,x_return_status      OUT NOCOPY VARCHAR2
                                   ,x_msg_count          OUT NOCOPY NUMBER
                                   ,x_msg_data           OUT NOCOPY VARCHAR2);
  PROCEDURE PROCESS_RENW_STRM_RESLTS(p_api_version        IN     NUMBER
                                        ,p_init_msg_list      IN     VARCHAR2
	                                    ,p_transaction_number IN     NUMBER
                                        ,x_return_status      OUT    NOCOPY VARCHAR2
                                        ,x_msg_count          OUT    NOCOPY NUMBER
                                        ,x_msg_data           OUT    NOCOPY VARCHAR2);
  PROCEDURE PROCESS_QUOT_STRM_RESLTS(p_api_version        IN     NUMBER
                                        ,p_init_msg_list      IN     VARCHAR2
	                                    ,p_transaction_number IN     NUMBER
                                        ,x_return_status      OUT    NOCOPY VARCHAR2
                                        ,x_msg_count          OUT    NOCOPY NUMBER
                                        ,x_msg_data           OUT    NOCOPY VARCHAR2);
  PROCEDURE PROCESS_VIRP_STRM_RESLTS(p_api_version        IN     NUMBER
                                        ,p_init_msg_list      IN     VARCHAR2
	                                    ,p_transaction_number IN     NUMBER
                                        ,x_return_status      OUT    NOCOPY VARCHAR2
                                        ,x_msg_count          OUT    NOCOPY NUMBER
                                        ,x_msg_data           OUT    NOCOPY VARCHAR2);
  PROCEDURE ENQUEUE_MESSAGE(  p_transaction_type IN varchar2,
			    p_transaction_subtype IN varchar2,
			    p_doc_number IN varchar2,
			    p_prc_eng_url IN VARCHAR2,
			    x_return_status OUT NOCOPY varchar2);
END OKL_PROCESS_STREAMS_PVT;

 

/
