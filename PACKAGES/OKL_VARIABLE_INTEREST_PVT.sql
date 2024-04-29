--------------------------------------------------------
--  DDL for Package OKL_VARIABLE_INTEREST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VARIABLE_INTEREST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRVARS.pls 120.14.12010000.4 2008/10/13 05:55:28 rpillay ship $ */
     --------------------------------------------------------------------------
     -- Global Variables
     --------------------------------------------------------------------------

     G_PKG_NAME                     CONSTANT VARCHAR2(200)  := 'OKL_VARIABLE_INTEREST_PVT';
     G_APP_NAME                     CONSTANT VARCHAR2(3)    :=  OKC_API.G_APP_NAME;
     G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200)  := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
     G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200)  := 'ERROR_CODE';
     G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200)  := 'ERROR_MESSAGE';
     G_LLA_CHR_ID                   CONSTANT VARCHAR2(1000) := 'OKL_LLA_CHR_ID';
     G_INVALID_VALUE                CONSTANT VARCHAR2(1000) := 'OKL_INVALID_VALUE';
     G_CAPITAL_AMT_ERROR            CONSTANT VARCHAR2(1000) := 'OKL_LLA_CAPITAL_AMT_ERROR';
     G_CALC_METHOD_CODE             VARCHAR2(30);
     G_INT_CALC_BASIS_FLOAT_FACTORS CONSTANT VARCHAR2(1000) := 'FLOAT_FACTORS';
     G_INT_CALC_BASIS_REAMORT       CONSTANT VARCHAR2(1000) := 'REAMORT';
     G_INT_CALC_BASIS_FLOAT         CONSTANT VARCHAR2(1000) := 'FLOAT';
     G_INT_CALC_BASIS_CATCHUP       CONSTANT VARCHAR2(1000) := 'CATCHUP/CLEANUP';
     G_REQUEST_ID                   NUMBER;

--  Package level contract specific variables
    G_CONTRACT_ID                NUMBER;
    G_AUTHORING_ORG_ID           NUMBER;
    G_PRODUCT_ID                 NUMBER;
    G_DEAL_TYPE                  OKL_K_HEADERS_FULL_V.deal_type%TYPE;
    G_CONTRACT_START_DATE        OKL_K_HEADERS_FULL_V.start_date%TYPE;
    G_CONTRACT_END_DATE          OKL_K_HEADERS_FULL_V.end_date%TYPE;
    G_CURRENCY_CODE              OKL_K_HEADERS_FULL_V.currency_code%TYPE;
    G_CONTRACT_PRINCIPAL_BALANCE NUMBER;
    G_INTEREST_BASIS_CODE        OKL_K_RATE_PARAMS.interest_basis_code%TYPE;
    G_CALCULATION_FORMULA_ID     OKL_K_RATE_PARAMS.calculation_formula_id%TYPE;
    G_PRINCIPAL_BASIS_CODE       OKL_K_RATE_PARAMS.principal_basis_code%TYPE;
    G_DAYS_IN_A_MONTH_CODE       OKL_K_RATE_PARAMS.days_in_a_month_code%TYPE;
    G_DAYS_IN_A_YEAR_CODE        OKL_K_RATE_PARAMS.days_in_a_year_code%TYPE;
    G_CATCHUP_SETTLEMENT_CODE    OKL_K_RATE_PARAMS.catchup_settlement_code%TYPE;
    G_INTEREST_CALCULATION_BASIS OKL_PRODUCT_PARAMETERS_V.INTEREST_CALCULATION_BASIS%TYPE;
    G_REVENUE_RECOGNITION_METHOD OKL_PRODUCT_PARAMETERS_V.REVENUE_RECOGNITION_METHOD%TYPE;

-- Line Specific Variables
    G_FIN_AST_LINE_ID            NUMBER;
	G_ASSET_PRINCIPAL_BALANCE    NUMBER;

-- Billing Transction types
    G_BILLING_TRX_TYPE_ID            OKL_TRX_TYPES_V.id%TYPE;
    G_BILLING_TRX_TRY_ID             OKL_TRX_TYPES_V.try_id%TYPE;
    G_BILLING_TRX_DESC               OKL_TRX_TYPES_V.description%TYPE;

-- Receipt App Transction types
    G_RCPT_APP_TRX_TYPE_ID           OKL_TRX_TYPES_V.id%TYPE;
    G_RCPT_APP_TRX_TRY_ID            OKL_TRX_TYPES_V.try_id%TYPE;
    G_RCPT_APP_TRX_DESC              OKL_TRX_TYPES_V.description%TYPE;

-- Receipt App Transaction Lookups
    G_RAP_TCN_TYPE                   FND_LOOKUPS.lookup_code%TYPE;
  	G_RAP_TCN_MEANING                FND_LOOKUPS.meaning%TYPE;
  	G_RAP_TCN_DESC                   FND_LOOKUPS.description%TYPE;

-- Receipt App Transaction Line Lookups
    G_RAP_TCL_TYPE                   FND_LOOKUPS.lookup_code%TYPE;
  	G_RAP_TCL_MEANING                FND_LOOKUPS.meaning%TYPE;
  	G_RAP_TCL_DESC                   FND_LOOKUPS.description%TYPE;

-- Fix for bug 5033120
-- Principal Adjust Transction types
    G_PAD_TRX_TYPE_ID                OKL_TRX_TYPES_V.id%TYPE;
    G_PAD_TRX_TRY_ID                 OKL_TRX_TYPES_V.try_id%TYPE;
    G_PAD_TRX_DESC                   OKL_TRX_TYPES_V.description%TYPE;

-- Principal Adjust Transaction Lookups
    G_PAD_TCN_TYPE                   FND_LOOKUPS.lookup_code%TYPE;
  	G_PAD_TCN_MEANING                FND_LOOKUPS.meaning%TYPE;
  	G_PAD_TCN_DESC                   FND_LOOKUPS.description%TYPE;

-- Principal Adjust Transaction Line Lookups
    G_PAD_TCL_TYPE                   FND_LOOKUPS.lookup_code%TYPE;
  	G_PAD_TCL_MEANING                FND_LOOKUPS.meaning%TYPE;
  	G_PAD_TCL_DESC                   FND_LOOKUPS.description%TYPE;

     TYPE interest_rec is  RECORD
        (khr_id             NUMBER := 0
        ,Kle_id             NUMBER := 0
        ,Principle          NUMBER := 0
        ,start_date         DATE
        ,end_date           DATE
        ,effective_rate      NUMBER(5,2) := 0
        ,interest_amount    NUMBER := 0
        ,days_in_year       VARCHAR2(20)
        ,variable_rate      VARCHAR2(1)
        ,variable_method    VARCHAR2(100)
        ,interest_method    VARCHAR2(100)
        ,index_name         VARCHAR2(100)
        ,base_rate          NUMBER(5,2) := 0
        ,minimum_rate       NUMBER(5,2) := 0
        ,maximum_rate       NUMBER(5,2) := 0
        ,tolerance          NUMBER(5,2) := 0);

    TYPE date_rate_rec IS  RECORD ( from_date  DATE
                                   ,to_date    DATE
                                   ,rate       NUMBER(5,2)
                                  );

    TYPE date_rate_tbl IS TABLE OF date_rate_rec INDEX BY BINARY_INTEGER;

    TYPE principal_balance_rec_type IS RECORD (
         khr_id                 OKL_K_HEADERS.id%TYPE,
         kle_id                 OKL_K_LINES.id%TYPE,
         from_date              DATE,
         to_date                DATE,
         Principal_balance      OKL_STRM_ELEMENTS.amount%TYPE);

   TYPE  principal_balance_tbl_typ is TABLE of principal_balance_rec_type INDEX BY BINARY_INTEGER;

    TYPE receipt_rec_type IS RECORD (
         khr_id                 OKL_K_HEADERS.id%TYPE,
         kle_id                 OKL_K_LINES.id%TYPE,
         transaction_type       Varchar2(1),
         receipt_date           DATE,
         receipt_amount         NUMBER,
         principal_pmt_rcpt_amt OKL_STRM_ELEMENTS.amount%TYPE,
         loan_pmt_rcpt_amt      OKL_STRM_ELEMENTS.amount%TYPE);

    TYPE receipt_tbl_type IS TABLE of receipt_rec_type INDEX BY BINARY_INTEGER;

    TYPE interest_rate_rec_type IS  RECORD ( from_date  DATE
                                  ,to_date    DATE
                                  ,rate       NUMBER
                                  ,derived_flag VARCHAR2(1) DEFAULT 'Y'
                                  ,apply_tolerance VARCHAR2(1) DEFAULT 'Y'
                                 );

    TYPE interest_rate_tbl_type IS TABLE OF interest_rate_rec_type INDEX BY BINARY_INTEGER;

    TYPE vpb_rec_type IS RECORD (
      ID	OKL_VAR_PRINCIPAL_BAL_TXN.ID%TYPE
      ,KHR_ID	OKL_VAR_PRINCIPAL_BAL_TXN.KHR_ID%TYPE
      ,SOURCE_TABLE	OKL_VAR_PRINCIPAL_BAL_TXN.SOURCE_TABLE%TYPE
      ,SOURCE_ID	OKL_VAR_PRINCIPAL_BAL_TXN.SOURCE_ID%TYPE
      ,INT_CAL_PROCESS	OKL_VAR_PRINCIPAL_BAL_TXN.INT_CAL_PROCESS%TYPE
      ,OBJECT_VERSION_NUMBER	OKL_VAR_PRINCIPAL_BAL_TXN.OBJECT_VERSION_NUMBER%TYPE
      ,ORG_ID	OKL_VAR_PRINCIPAL_BAL_TXN.ORG_ID%TYPE
      ,REQUEST_ID	OKL_VAR_PRINCIPAL_BAL_TXN.REQUEST_ID%TYPE
      ,PROGRAM_APPLICATION_ID	OKL_VAR_PRINCIPAL_BAL_TXN.PROGRAM_APPLICATION_ID%TYPE
      ,PROGRAM_ID	OKL_VAR_PRINCIPAL_BAL_TXN.PROGRAM_ID%TYPE
      ,PROGRAM_UPDATE_DATE	OKL_VAR_PRINCIPAL_BAL_TXN.PROGRAM_UPDATE_DATE%TYPE
      ,ATTRIBUTE_CATEGORY	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE_CATEGORY%TYPE
      ,ATTRIBUTE1	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE1%TYPE
      ,ATTRIBUTE2	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE2%TYPE
      ,ATTRIBUTE3	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE3%TYPE
      ,ATTRIBUTE4	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE4%TYPE
      ,ATTRIBUTE5	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE5%TYPE
      ,ATTRIBUTE6	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE6%TYPE
      ,ATTRIBUTE7	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE7%TYPE
      ,ATTRIBUTE8	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE8%TYPE
      ,ATTRIBUTE9	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE9%TYPE
      ,ATTRIBUTE10	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE10%TYPE
      ,ATTRIBUTE11	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE11%TYPE
      ,ATTRIBUTE12	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE12%TYPE
      ,ATTRIBUTE13	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE13%TYPE
      ,ATTRIBUTE14	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE14%TYPE
      ,ATTRIBUTE15	OKL_VAR_PRINCIPAL_BAL_TXN.ATTRIBUTE15%TYPE
      ,CREATED_BY	OKL_VAR_PRINCIPAL_BAL_TXN.CREATED_BY%TYPE
      ,CREATION_DATE	OKL_VAR_PRINCIPAL_BAL_TXN.CREATION_DATE%TYPE
      ,LAST_UPDATED_BY	OKL_VAR_PRINCIPAL_BAL_TXN.LAST_UPDATED_BY%TYPE
      ,LAST_UPDATE_DATE	OKL_VAR_PRINCIPAL_BAL_TXN.LAST_UPDATE_DATE%TYPE
      ,LAST_UPDATE_LOGIN	OKL_VAR_PRINCIPAL_BAL_TXN.LAST_UPDATE_LOGIN%TYPE);

    TYPE vpb_tbl_type IS TABLE OF vpb_rec_type INDEX BY BINARY_INTEGER;


    SUBTYPE csm_periodic_expenses_tbl_type IS okl_process_streams_pvt.srlv_tbl_type;
    SUBTYPE strm_lalevl_tbl IS OKL_MASS_REBOOK_PVT.strm_lalevl_tbl_type;
    SUBTYPE rbk_tbl IS OKL_MASS_REBOOK_PVT.rbk_tbl_type;
    SUBTYPE strm_trx_tbl IS OKL_MASS_REBOOK_PVT.strm_trx_tbl_type;
    SUBTYPE csm_loan_level_tbl_type IS okl_create_streams_pvt.csm_loan_level_tbl_type;
    SUBTYPE vipv_rec IS OKL_VIP_PVT.vipv_rec_type;

    G_NET_INVESTMENT_DF           CONSTANT VARCHAR2(50) := 'CONTRACT_NET_INVESTMENT_DF';
    G_NET_INVESTMENT_OP           CONSTANT VARCHAR2(50) := 'CONTRACT_NET_INVESTMENT_OP';

    G_DEAL_TYPE_LEASEDF           CONSTANT VARCHAR2(30) := 'LEASEDF';
    G_DEAL_TYPE_LEASEOP           CONSTANT VARCHAR2(30) := 'LEASEOP';
    ---------------------------------------------------------------------------
    -- Procedures and Functions
    ---------------------------------------------------------------------------

    PROCEDURE variable_interest(
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2,
        p_contract_number   IN VARCHAR2,
        P_to_date           IN  DATE);

    PROCEDURE var_int_rent_level(
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2,
        p_chr_id            IN NUMBER,
        p_trx_id            IN NUMBER,
        p_trx_status        IN VARCHAR2,
        p_rent_tbl          IN csm_periodic_expenses_tbl_type,
        p_csm_loan_level_tbl IN csm_loan_level_tbl_type,
        x_child_trx_id       OUT NOCOPY NUMBER);

    PROCEDURE initiate_request(
        p_api_version       IN  NUMBER,
   	 	p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
        p_khr_id            IN  NUMBER,
        x_return_status     OUT NOCOPY VARCHAR2,
  	    x_msg_count         OUT NOCOPY NUMBER,
  	    x_msg_data          OUT NOCOPY VARCHAR2);

  FUNCTION get_prorated_prin_amt_line (
            p_line_id             IN  NUMBER,
            p_stream_element_date IN  DATE,
            p_loan_amount         IN  NUMBER,
            p_currency_code       IN  VARCHAR2) RETURN NUMBER;

  FUNCTION get_prorated_prin_amt_header (
            p_contract_id         IN  NUMBER,
            p_line_id             IN  NUMBER,
            p_stream_element_date IN  DATE,
            p_loan_amount         IN  NUMBER,
            p_currency_code       IN  VARCHAR2) RETURN NUMBER;

 FUNCTION get_last_int_calc_date(p_khr_id IN NUMBER) RETURN DATE;

 PRAGMA RESTRICT_REFERENCES (get_prorated_prin_amt_line, WNDS);
 PRAGMA RESTRICT_REFERENCES (get_prorated_prin_amt_header, WNDS);
 PRAGMA RESTRICT_REFERENCES (get_last_int_calc_date, WNDS);

 PROCEDURE prin_date_range_var_rate_ctr (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_line_id            IN  NUMBER,
            p_start_date         IN  DATE,
            p_due_date           IN  DATE,
            p_principal_basis    IN  VARCHAR2 DEFAULT NULL,
            x_principal_balance_tbl OUT NOCOPY principal_balance_tbl_typ);

  FUNCTION calculate_total_interest_due(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_contract_id     IN  NUMBER,
            p_currency_code   IN  VARCHAR2,
            p_start_date      IN  DATE,
            p_due_date        IN  DATE,
            p_principal_basis IN  VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  PROCEDURE interest_date_range (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_start_date         IN  DATE,
            p_end_date           IN  DATE,
            p_process_flag       IN  VARCHAR2 ,
            x_interest_rate_tbl OUT NOCOPY interest_rate_tbl_type);

  Function  calculate_interest (
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_contract_id        IN  NUMBER,
            p_from_date          IN  DATE,
            p_to_date            IN  DATE,
            p_principal_amount   IN  NUMBER,
            p_currency_code      IN  VARCHAR2) RETURN NUMBER;

  Procedure Create_Stream_Invoice (
            p_api_version             IN  NUMBER,
            p_init_msg_list           IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_contract_id             IN  NUMBER,
            p_line_id                 IN  NUMBER DEFAULT NULL,
            p_amount                  IN  NUMBER,
            p_due_date                IN  DATE,
            p_stream_type_purpose     IN  VARCHAR2,
            p_create_invoice_flag     IN  VARCHAR2 DEFAULT OKL_API.G_TRUE,
            p_process_flag            IN  VARCHAR2 DEFAULT NULL,
            p_parent_strm_element_id  IN  NUMBER   DEFAULT NULL,
			x_invoice_id              OUT NOCOPY NUMBER,
			x_stream_element_id       OUT NOCOPY NUMBER);

  Procedure Create_Daily_Interest_Streams (
            p_api_version             IN  NUMBER,
            p_init_msg_list           IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_contract_id             IN  NUMBER,
            p_line_id                 IN  NUMBER DEFAULT NULL,
            p_amount                  IN  NUMBER,
            p_due_date                IN  DATE,
            p_stream_type_purpose     IN  VARCHAR2,
            p_create_invoice_flag     IN  VARCHAR2 DEFAULT OKL_API.G_TRUE,
            p_process_flag            IN  VARCHAR2 DEFAULT NULL,
			p_currency_code           IN  VARCHAR2 DEFAULT NULL);

END;

/
