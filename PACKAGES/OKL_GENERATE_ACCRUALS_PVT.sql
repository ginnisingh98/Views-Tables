--------------------------------------------------------
--  DDL for Package OKL_GENERATE_ACCRUALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_GENERATE_ACCRUALS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRACRS.pls 120.14.12010000.4 2009/12/15 09:58:01 racheruv ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

-- commenting stream_type_name as not needed. SGIYER 27-APR-2005
  TYPE stream_rec_type IS RECORD (
    stream_type_id      OKL_STRM_TYPE_V.id%TYPE,
    stream_type_name    OKL_STRM_TYPE_V.name%TYPE,
    stream_id           OKL_STREAMS_V.id%TYPE,
    stream_element_id   OKL_STRM_ELEMENTS_V.id%TYPE,
    stream_amount       OKL_STRM_ELEMENTS_V.amount%TYPE,
    kle_id              OKL_STREAMS.KLE_ID%TYPE);

  TYPE accrual_rec_type IS RECORD (
    contract_id                    OKL_K_HEADERS_FULL_V.ID%TYPE,
	sty_id                         OKL_TXL_CNTRCT_LNS.sty_id%TYPE,
    set_of_books_id                OKL_TRX_CONTRACTS.SET_OF_BOOKS_ID%TYPE,
    reverse_date_to                DATE,
    accrual_date                   DATE,
	trx_date                       DATE,
    contract_number                OKL_K_HEADERS_FULL_V.CONTRACT_NUMBER%TYPE,
    rule_result                    OKL_TRX_CONTRACTS.ACCRUAL_STATUS_YN%TYPE,
    override_status                OKL_TRX_CONTRACTS.UPDATE_STATUS_YN%TYPE,
    description                    OKL_TRX_CONTRACTS.DESCRIPTION%TYPE,
	amount                         OKL_TRX_CONTRACTS.AMOUNT%TYPE,
	currency_code                  OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE,
	currency_conversion_type       OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_TYPE%TYPE,
	currency_conversion_rate       OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_RATE%TYPE,
	currency_conversion_date       OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_DATE%TYPE,
    product_id                     OKL_PRODUCTS_V.ID%TYPE,
    trx_type_id                    OKL_TRX_TYPES_V.ID%TYPE,
    advance_arrears                OKL_AE_TEMPLATES.ADVANCE_ARREARS%TYPE,
    factoring_synd_flag            OKL_AE_TEMPLATES.FACTORING_SYND_FLAG%TYPE,
	post_to_gl                     VARCHAR2(1),
	gl_reversal_flag               VARCHAR2(1),
	memo_yn                        VARCHAR2(1),
	accrual_activity               OKL_TRX_CONTRACTS.ACCRUAL_ACTIVITY%TYPE,
    accrual_rule_yn                VARCHAR2(1),
    source_trx_id                  OKL_TRX_CONTRACTS.SOURCE_TRX_ID%TYPE,
    source_trx_type                OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE,
    -- Bug 5707866 Added by dpsingh
    accrual_reversal_date  OKL_TRX_CONTRACTS.ACCRUAL_REVERSAL_DATE%TYPE,
    trx_number                     OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE,
    primary_rep_trx_id             OKL_TRX_CONTRACTS.PRIMARY_REP_TRX_ID%TYPE);
  -- Added new field accelerate_from_date by akrangan for bug 5526955
  TYPE acceleration_rec_type IS RECORD (
    khr_id               OKL_K_HEADERS_FULL_V.id%TYPE,
    kle_id               OKL_K_LINES_FULL_V.id%TYPE,
    sty_id               OKL_STRM_TYPE_V.id%TYPE,
    acceleration_date    DATE,
    accelerate_till_date DATE,
    description          OKL_TRX_CONTRACTS.description%TYPE,
    accrual_rule_yn      OKL_TXL_CNTRCT_LNS.accrual_rule_yn%TYPE,
    accelerate_from_date DATE DEFAULT NULL,
    trx_number  OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE DEFAULT NULL); --MGAAP 7263041

  TYPE adjust_accrual_rec_type IS RECORD(
    contract_id                    OKL_K_HEADERS_FULL_V.ID%TYPE,
    accrual_date                   OKL_TRX_CONTRACTS.DATE_ACCRUAL%TYPE,
    description                    OKL_TRX_CONTRACTS.DESCRIPTION%TYPE,
    source_trx_id                  OKL_TRX_CONTRACTS.SOURCE_TRX_ID%TYPE,
    source_trx_type                OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE,
    trx_number                     OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE);

  TYPE stream_tbl_type IS TABLE OF stream_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE acceleration_tbl_type IS TABLE OF acceleration_rec_type
    INDEX BY BINARY_INTEGER;

 -- Bug 9191475
  TYPE trxnum_tbl_type is table of okl_trx_contracts.trx_number%TYPE
    index by varchar2(20);

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_CHILD_TABLE_TOKEN;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_CONTRACT_NUMBER_TOKEN CONSTANT VARCHAR2(200) := 'CONTRACT_NUMBER';
  G_STREAM_NAME_TOKEN CONSTANT VARCHAR2(200) := 'STREAM_NAME';
  G_NO_MATCHING_RECORD      CONSTANT  VARCHAR2(2000) := 'OKL_LLA_NO_MATCHING_RECORD';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			    CONSTANT VARCHAR2(200) := 'OKL_GENERATE_ACCRUALS_PVT';
  G_APP_NAME			    CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
  G_COMMIT_CYCLE            CONSTANT NUMBER        :=  500;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  FUNCTION SUBMIT_ACCRUALS(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_accrual_date IN DATE,
    p_batch_name IN VARCHAR2) RETURN NUMBER;


  FUNCTION CALCULATE_OPERAND_VALUE(p_ctr_id IN OKL_K_HEADERS_FULL_V.ID%TYPE
                                  ,p_operand_code IN VARCHAR2) RETURN NUMBER;

  PROCEDURE GET_ACCRUAL_STREAMS(x_return_status OUT NOCOPY VARCHAR2
                               ,x_stream_tbl OUT NOCOPY stream_tbl_type
                               ,p_khr_id IN OKL_K_HEADERS.ID%TYPE
							   ,p_product_id IN OKL_PRODUCTS_V.ID%TYPE
                               ,p_ctr_start_date IN DATE
                               ,p_period_end_date IN DATE
                               ,p_accrual_rule_yn IN VARCHAR2);

  PROCEDURE VALIDATE_ACCRUAL_RULE(x_return_status OUT NOCOPY VARCHAR2
                                 ,x_result OUT NOCOPY VARCHAR2
                                 ,p_ctr_id IN OKL_K_HEADERS.id%TYPE);

  FUNCTION CALCULATE_CNTRCT_REC(p_ctr_id IN NUMBER) RETURN NUMBER;

  FUNCTION GET_SYNDICATE_FLAG(p_contract_id	IN NUMBER,
                              x_syndicate_flag	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

  FUNCTION GET_FACTORING_FLAG(p_contract_id	IN NUMBER,
                              x_factoring_flag	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

  FUNCTION CHECK_DATE_ACCRUED_TILL(p_khr_id IN OKL_K_HEADERS_FULL_V.ID%TYPE
                                  ,p_date IN DATE) RETURN VARCHAR2;

  PROCEDURE GENERATE_ACCRUALS(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY NUMBER
                             ,p_accrual_date IN VARCHAR2
                             ,p_batch_name IN VARCHAR2
                             ,p_contract_number IN VARCHAR2
                             ,p_rev_rec_method IN VARCHAR2);

  PROCEDURE GENERATE_ACCRUALS_PARALLEL
                             (errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY NUMBER
                             ,p_accrual_date IN VARCHAR2
                             ,p_batch_name IN VARCHAR2
                             ,p_worker_id IN VARCHAR2
                             ,p_rev_rec_method IN VARCHAR2);

  PROCEDURE CATCHUP_ACCRUALS (
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_catchup_rec IN accrual_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY'); --MGAAP 7263041

  PROCEDURE REVERSE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    p_reverse_rec IN accrual_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY'); --MGAAP 7263041

  PROCEDURE REVERSE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_khr_id IN NUMBER,
    p_reversal_date IN DATE,
    p_accounting_date IN DATE,
    p_reverse_from IN DATE,
    p_reverse_to IN DATE,
    p_tcn_type IN VARCHAR2);

  PROCEDURE REVERSE_ALL_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    p_khr_id IN NUMBER,
    p_reverse_date IN DATE,
    p_description IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2);


  PROCEDURE REVERSE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    p_reverse_rec IN accrual_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_rev_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_rev_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    x_memo_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_memo_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY'
  );

  PROCEDURE ACCELERATE_ACCRUALS (
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
	p_acceleration_rec IN acceleration_rec_type,
        p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY', --MGAAP 7263041
        x_trx_number OUT NOCOPY OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE); --MGAAP 7263041

  PROCEDURE ADJUST_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    --x_trx_number OUT NOCOPY VARCHAR2,
	x_trx_tbl  IN OUT NOCOPY trxnum_tbl_type,
    p_accrual_rec IN adjust_accrual_rec_type,
	p_stream_tbl IN stream_tbl_type,
	p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY');

  PROCEDURE GENERATE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_accrual_rec IN adjust_accrual_rec_type);

END OKL_GENERATE_ACCRUALS_PVT;

/
