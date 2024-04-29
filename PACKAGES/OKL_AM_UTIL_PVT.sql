--------------------------------------------------------
--  DDL for Package OKL_AM_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAMUS.pls 120.14 2007/10/15 08:45:53 prasjain noship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE   p_bind_var_tbl       IS  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
  SUBTYPE   p_bind_val_tbl       IS  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
  SUBTYPE   p_bind_type_tbl      IS  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
  SUBTYPE   qtev_rec_type	 IS  okl_trx_quotes_pub.qtev_rec_type;

  TYPE	where_rec_type		IS RECORD (
	column_name		VARCHAR2(30),
	operation		VARCHAR2(30) DEFAULT '=',
	condition_value		VARCHAR2(80));

  TYPE	jtf_object_rec_type	IS RECORD (
	object_code		VARCHAR2(80),
	id1			VARCHAR2(80),
	id2			VARCHAR2(80),
	name			VARCHAR2(320),
	description		VARCHAR2(2000),
	other_values		VARCHAR2(4000));

  TYPE	select_tbl_type		IS TABLE OF VARCHAR2(2000)
				INDEX BY BINARY_INTEGER;

  TYPE	where_tbl_type		IS TABLE OF where_rec_type
				INDEX BY BINARY_INTEGER;

  TYPE	jtf_object_tbl_type	IS TABLE OF jtf_object_rec_type
				INDEX BY BINARY_INTEGER;

  TYPE recipient_tbl IS TABLE OF VARCHAR2(100)
				INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  g_empty_select_tbl	select_tbl_type;
  g_empty_where_tbl	where_tbl_type;
  G_DELIM		CONSTANT VARCHAR2(1)	:= ';';

  G_DEBUG_LEVEL		CONSTANT NUMBER	:= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_NORMAL_LEVEL	CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS FOR ERROR HANDLING
  ---------------------------------------------------------------------------

  G_APP_NAME		CONSTANT VARCHAR2(3)	:= OKL_API.G_APP_NAME;
  G_APP2_NAME		CONSTANT VARCHAR2(3)	:= OKC_API.G_APP_NAME;
  G_PKG_NAME		CONSTANT VARCHAR2(200)	:= 'OKL_AM_UTIL_PVT';
  G_API_VERSION		CONSTANT NUMBER		:= 1;
  G_API_NAME		CONSTANT VARCHAR2(30)	:= 'OKL_AM_UTIL_PVT';
  G_UNEXPECTED_ERROR	CONSTANT VARCHAR2(200)	:= 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_INVALID_VALUE	CONSTANT VARCHAR2(200)	:= okl_api.G_INVALID_VALUE;
  G_INVALID_VALUE1      CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_COL_NAME_TOKEN	CONSTANT VARCHAR2(200)	:= OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	CONSTANT VARCHAR2(200)	:= Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN 	CONSTANT VARCHAR2(200)	:= Okl_Api.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD	CONSTANT VARCHAR2(200)	:= 'OKL_NO_PARENT_RECORD';
  G_SQLERRM_TOKEN	CONSTANT VARCHAR2(200)	:= 'SQLERRM';
  G_SQLCODE_TOKEN 	CONSTANT VARCHAR2(200)	:= 'SQLCODE';
  G_REQUIRED_VALUE	CONSTANT VARCHAR2(200)	:= OKC_API.G_REQUIRED_VALUE;
  G_LEN_CHK		CONSTANT VARCHAR2(200)	:= 'OKC_LENGTH_EXCEEDS';
  G_NOTFOUND		CONSTANT VARCHAR2(200)	:= 'OKC_VIEW_NOT_FOUND';
  G_VIEW_TOKEN		CONSTANT VARCHAR2(200)	:= 'G_VIEW_TOKEN';
  G_EXCEPTION_HALT_PROCESS	 EXCEPTION;
  G_REQUIRED_VALUE  CONSTANT VARCHAR2(200)	:= okc_api.G_REQUIRED_VALUE;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  -- Return asset quantity
  FUNCTION get_asset_quantity (p_cle_id IN NUMBER) RETURN NUMBER;

  -- Depending on Quote Type, returns contract_id
  -- of either Lease contract or its Program
  FUNCTION get_rule_chr_id (p_qtev_rec IN qtev_rec_type) RETURN NUMBER;

  -- Initialize transaction record for Installed Base calls
  PROCEDURE initialize_txn_rec (
	px_txn_rec IN OUT NOCOPY csi_datastructures_pub.transaction_rec);

  -- Return system org_id
  FUNCTION get_okl_org_id RETURN NUMBER;

  -- Return contract org_id
  FUNCTION get_chr_org_id (p_chr_id IN NUMBER) RETURN NUMBER;

  -- Return contract currency_code
  FUNCTION get_chr_currency (p_chr_id IN NUMBER) RETURN VARCHAR2;

  -- Gets information about currency
  PROCEDURE get_currency_info (
	p_currency_code		IN VARCHAR2,
	x_precision		OUT NOCOPY NUMBER,
	x_min_acc_unit		OUT NOCOPY NUMBER);

  -- Gets the transaction type id for the transaction name
  PROCEDURE get_transaction_id (
	p_try_name		IN VARCHAR2,
	p_language		IN VARCHAR2 DEFAULT 'US',
	x_return_status		OUT NOCOPY VARCHAR2,
	x_try_id		OUT NOCOPY NUMBER);

  -- Gets stream type id for stream type code
  PROCEDURE get_stream_type_id (
	p_sty_code		IN VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_sty_id		OUT NOCOPY NUMBER);

  -- Returns Bill_To Site_Use record
  PROCEDURE get_bill_to_address (
	p_contract_id		IN NUMBER,
	p_message_yn		IN BOOLEAN DEFAULT TRUE,
	x_bill_to_address_rec	OUT NOCOPY okx_cust_site_uses_v%ROWTYPE,
	x_return_status		OUT NOCOPY VARCHAR2);

  -- Return full descriptions for message tokens
  FUNCTION set_token (
	p_token1_type		IN VARCHAR2,
	p_token1_value		IN VARCHAR2,
	p_token2_type		IN VARCHAR2 DEFAULT NULL,
	p_token2_value		IN VARCHAR2 DEFAULT NULL,
	p_token2_new_value	IN VARCHAR2 DEFAULT NULL)
	RETURN			VARCHAR2;

  -- Put messages on stack
  PROCEDURE set_message (
	p_app_name		IN VARCHAR2 DEFAULT OKL_API.G_APP_NAME,
	p_msg_name		IN VARCHAR2,
	p_msg_level		IN NUMBER   DEFAULT G_NORMAL_LEVEL,
	p_token1		IN VARCHAR2 DEFAULT NULL,
	p_token1_value		IN VARCHAR2 DEFAULT NULL,
	p_token2		IN VARCHAR2 DEFAULT NULL,
	p_token2_value		IN VARCHAR2 DEFAULT NULL,
	p_token3		IN VARCHAR2 DEFAULT NULL,
	p_token3_value		IN VARCHAR2 DEFAULT NULL,
	p_token4		IN VARCHAR2 DEFAULT NULL,
	p_token4_value		IN VARCHAR2 DEFAULT NULL,
	p_token5		IN VARCHAR2 DEFAULT NULL,
	p_token5_value		IN VARCHAR2 DEFAULT NULL,
	p_token6		IN VARCHAR2 DEFAULT NULL,
	p_token6_value		IN VARCHAR2 DEFAULT NULL,
	p_token7		IN VARCHAR2 DEFAULT NULL,
	p_token7_value		IN VARCHAR2 DEFAULT NULL,
	p_token8		IN VARCHAR2 DEFAULT NULL,
	p_token8_value		IN VARCHAR2 DEFAULT NULL,
	p_token9		IN VARCHAR2 DEFAULT NULL,
	p_token9_value		IN VARCHAR2 DEFAULT NULL,
	p_token10		IN VARCHAR2 DEFAULT NULL,
	p_token10_value		IN VARCHAR2 DEFAULT NULL);

  -- Add message indicating invalid rule setup
  PROCEDURE set_invalid_rule_message (
		p_rgd_code	IN VARCHAR2,
		p_rdf_code	IN VARCHAR2);

  -- Get rule information for a rule
  PROCEDURE get_rule_record (
		p_rgd_code	IN VARCHAR2,
		p_rdf_code	IN VARCHAR2,
		p_chr_id	IN NUMBER,
		p_cle_id	IN NUMBER,
		p_rgd_id	IN NUMBER DEFAULT NULL,
		p_message_yn	IN BOOLEAN DEFAULT TRUE,
		x_rulv_rec	OUT NOCOPY okl_rule_pub.rulv_rec_type,
		x_return_status	OUT NOCOPY VARCHAR2);

  -- Get rule information for a rule and return message stack
  PROCEDURE get_rule_record (
		p_rgd_code	IN VARCHAR2,
		p_rdf_code	IN VARCHAR2,
		p_chr_id	IN NUMBER,
		p_cle_id	IN NUMBER,
		p_message_yn	IN BOOLEAN DEFAULT TRUE,
		x_rulv_rec	OUT NOCOPY okl_rule_pub.rulv_rec_type,
		x_return_status	OUT NOCOPY VARCHAR2,
		x_msg_count	OUT NOCOPY VARCHAR2,
		x_msg_data	OUT NOCOPY VARCHAR2);

  -- Request Formula Engine to execute a formula
  PROCEDURE get_formula_value (
		p_formula_name	IN  OKL_FORMULAE_B.name%TYPE,
		p_chr_id	IN  OKC_K_HEADERS_B.id%TYPE,
		p_cle_id	IN  OKL_K_LINES.id%TYPE,
		p_additional_parameters IN
		okl_execute_formula_pub.ctxt_val_tbl_type DEFAULT
		okl_execute_formula_pub.g_additional_parameters_null,
		x_formula_value	OUT NOCOPY NUMBER,
		x_return_status	OUT NOCOPY VARCHAR2);

  -- Return formula string of a formula
  -- It can be used for validation - if NULL is returned,
  -- then a formula does not exist or can not be evaluated
  FUNCTION get_formula_string (
	p_formula_name		IN VARCHAR2)
	RETURN			VARCHAR2;

  -- Save messages from stack into transaction message table
  PROCEDURE process_messages(
	p_trx_source_table	IN OKL_TRX_MSGS.trx_source_table%TYPE,
	p_trx_id		IN OKL_TRX_MSGS.trx_id%TYPE,
	x_return_status		OUT NOCOPY VARCHAR2);

  -- Return details of JTF object
  PROCEDURE get_object_details (
	p_object_code		IN VARCHAR2,
	p_object_id1		IN VARCHAR2 DEFAULT NULL,
	p_object_id2		IN VARCHAR2 DEFAULT '#',
	p_check_status		IN VARCHAR2 DEFAULT 'N',
	p_other_select		IN select_tbl_type DEFAULT g_empty_select_tbl,
	p_other_where		IN where_tbl_type  DEFAULT g_empty_where_tbl,
	x_object_tbl		OUT NOCOPY jtf_object_tbl_type,
	x_return_status		OUT NOCOPY VARCHAR2);

  -- Return Name of JTF Object
  FUNCTION get_jtf_object_name (
	p_object_code		IN VARCHAR2,
	p_object_id1		IN VARCHAR2,
	p_object_id2		IN VARCHAR2 DEFAULT '#')
	RETURN			VARCHAR2;

  -- Return a value of a column in JTF Object
  FUNCTION get_jtf_object_column (
	p_column		IN VARCHAR2,
	p_object_code		IN VARCHAR2,
	p_object_id1		IN VARCHAR2,
	p_object_id2		IN VARCHAR2 DEFAULT '#')
	RETURN			VARCHAR2;

  -- Return Name of JTF Object pointed by Contract Rule
  FUNCTION get_rule_field_value (
	p_rgd_code	IN VARCHAR2,
	p_rdf_code	IN VARCHAR2,
	p_chr_id	IN NUMBER,
	p_cle_id	IN NUMBER,
	p_object_type	IN VARCHAR2 DEFAULT 'OBJECT1')
	RETURN		VARCHAR2;

  -- Return contract program partner
  FUNCTION get_program_partner (p_chr_id IN NUMBER) RETURN VARCHAR2;

  -- Execute a fulfillment request
  PROCEDURE EXECUTE_FULFILLMENT_REQUEST(
      p_api_version                  IN  NUMBER
    , p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    , x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
    , p_ptm_code                     IN  VARCHAR2
    , p_agent_id                     IN  NUMBER
    , p_transaction_id               IN  NUMBER
    , p_recipient_type               IN  VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
    , p_recipient_id                 IN  VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
    , p_expand_roles                 IN  VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
    , p_subject_line                 IN  VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
    , p_sender_email                 IN  VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
    , p_recipient_email              IN  VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
    , p_pt_bind_names                IN p_bind_var_tbl
    , p_pt_bind_values               IN p_bind_val_tbl
    , p_pt_bind_types                IN p_bind_type_tbl
  ) ;

  -- Procedure to add a view for checking length into global table - from OKC_UTIL
  Procedure  add_view(
    p_view_name                    IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2);

  --  checks length of a varchar2 column - from OKC_UTIL
  Procedure  check_length(
    p_view_name                    IN VARCHAR2,
    p_col_name	                   IN VARCHAR2,
    p_col_value                    IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2);

  --  checks length of a number column - from OKC_UTIL
 Procedure  check_length(
    p_view_name                    IN VARCHAR2,
    p_col_name                     IN VARCHAR2,
    p_col_value                    IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2);

  -- Return Lookup Meaning - Check Status and Date only if p_validate_yn is 'Y'
  FUNCTION get_lookup_meaning (
	p_lookup_type		IN VARCHAR2,
	p_lookup_code		IN VARCHAR2,
	p_validate_yn		IN VARCHAR2 DEFAULT 'N')
	RETURN			VARCHAR2;

  -- Return attribute label
  FUNCTION get_ak_attribute (
	p_code			IN VARCHAR2)
	RETURN			VARCHAR2;

  -- Indicates if any messages exist
  FUNCTION get_trx_msgs_yn (
	p_trx_table		IN VARCHAR2,
	p_trx_id		IN NUMBER)
	RETURN			VARCHAR2;

  -- Return quote amount
  FUNCTION get_quote_amount (
	p_quote_id		IN NUMBER)
	RETURN			NUMBER;

  -- Return WorkFlow event name
  FUNCTION get_wf_event_name(
    p_wf_process_type            	IN VARCHAR2,
    p_wf_process_name            	IN VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;


  -- RMUNJULU -- Bug # 2484327 Added these rec types, tbl types and procedures
  -- for asset level termination

  -- RMUNJULU 30-DEC-02 2484327 Added consolidated_yn
  TYPE quote_rec_type IS RECORD (
    id                NUMBER,
	  quote_number		  NUMBER,
    contract_number   VARCHAR2(30),
    partial_yn        VARCHAR2(1),
    consolidated_yn   VARCHAR2(1), -- RMUNJULU 30-DEC-02 2699412 Added
	  qst_code  		    VARCHAR2(30),
	  qtp_code    		  VARCHAR2(30));

  TYPE quote_tbl_type IS TABLE OF quote_rec_type INDEX BY BINARY_INTEGER;


  TYPE trn_rec_type IS RECORD (
    id                NUMBER,
	  trx_number   		  NUMBER,
    tsu_code          VARCHAR2(30),
    tcn_type          VARCHAR2(30),
    quote_number      NUMBER,
    contract_number   VARCHAR2(30),
    partial_yn        VARCHAR2(1),
	  qst_code  		    VARCHAR2(30),
	  qtp_code    		  VARCHAR2(30));

  TYPE trn_tbl_type IS TABLE OF trn_rec_type INDEX BY BINARY_INTEGER;

  -- Return accepted quotes for the Contract
  PROCEDURE get_contract_quotes (
   p_khr_id        IN  NUMBER,
   x_quote_tbl     OUT NOCOPY quote_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2);

  -- Return accepted quotes for the Asset
  PROCEDURE get_line_quotes (
   p_kle_id        IN  NUMBER,
   x_quote_tbl     OUT NOCOPY quote_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2);

  -- Return unprocessed termination transactions for the Contract
  PROCEDURE get_contract_transactions (
   p_khr_id        IN  NUMBER,
   x_trn_tbl       OUT NOCOPY trn_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2);

  -- Return unprocessed termination transactions for the Asset
  PROCEDURE get_line_transactions (
   p_kle_id        IN  NUMBER,
   x_trn_tbl       OUT NOCOPY trn_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2);

  -- Return accepted non transaction quotes for the Contract
  PROCEDURE get_non_trn_contract_quotes (
   p_khr_id        IN  NUMBER,
   x_quote_tbl     OUT NOCOPY quote_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2);


  -- DAPATEL -- Bug # 2484327 Added these procedures for multi-currency

  -- Return functional currency code
  FUNCTION get_functional_currency RETURN VARCHAR2;

  -- Return currency code for a given ORG ID
  FUNCTION get_currency_code(p_org_id IN NUMBER) RETURN VARCHAR2;

  -- Return the functional currency code and ORG ID
  PROCEDURE get_func_currency_org(x_org_id OUT NOCOPY NUMBER
                                 ,x_currency_code OUT NOCOPY VARCHAR2);

  -- Return the contract currency code and ORG ID for a given Contract ID
  PROCEDURE get_chr_currency_org(p_chr_id IN NUMBER
                                ,x_org_id OUT NOCOPY NUMBER
                                ,x_currency_code OUT NOCOPY VARCHAR2);

  -- This function returns the user profile option name for a profile
  FUNCTION get_user_profile_option_name(p_profile_option_name IN VARCHAR2,
                 x_return_status       OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

  -- DAPATEL 23-DEC-02 2667636 - Created for multi-currency
  -- This function converts an amount to the contract currency
  FUNCTION convert_to_contract_currency(p_khr_id IN NUMBER,
                                        p_trx_date IN DATE,
                                        p_amount IN NUMBER)  RETURN NUMBER;
--
  -- RMUNJULU 30-DEC-02 2484327 Added
  -- Return all termination quotes for the Asset
  PROCEDURE get_all_term_quotes_for_line (
   p_kle_id        IN  NUMBER,
   x_quote_tbl     OUT NOCOPY quote_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2) ;

  -- SECHAWLA 14-FEB-03 2749690 Added this function to calculate the net investment value
  FUNCTION get_net_investment( p_khr_id         IN  NUMBER,
                               p_kle_id         IN  NUMBER DEFAULT NULL,
                               p_quote_id       IN  NUMBER, -- rmunjulu LOANS_ENHANCEMENT
                               p_message_yn     IN  BOOLEAN,
                               p_proration_factor IN NUMBER DEFAULT NULL, -- added : Bug 6030917 : prasjain
                               x_return_status  OUT NOCOPY VARCHAR2) RETURN NUMBER;

  -- BAKUCHIB 19-FEB-03 2757368 Added this function to get the party name
  --for a given contract id and Role code. Line id is optional
  FUNCTION get_party_name(
            p_chr_id    IN  OKC_K_HEADERS_B.ID%TYPE,
            p_rle_code  IN  OKC_K_PARTY_ROLES_B.RLE_CODE%TYPE,
            p_kle_id    IN  OKL_K_HEADERS.ID%TYPE DEFAULT NULL)
  RETURN VARCHAR2;

  -- SPILLAIP 06-OCT-03 3115478 Added
  -- ALL EXISTING QUOTES MUST BE INVALIDATED WHEN A CONTRACT IS REBOOKED
  PROCEDURE get_all_term_qte_for_contract (
   p_khr_id        IN  NUMBER,
   x_quote_tbl     OUT NOCOPY quote_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2) ;

  -- RMUNJULU 3510740
  FUNCTION get_actual_asset_residual (
   p_khr_id        IN  NUMBER,
   p_kle_id        IN  NUMBER) RETURN NUMBER;

  -- rmunjulu EDAT -- new function to get sum of anticipated billing
  FUNCTION get_anticipated_bill (p_qte_id IN NUMBER) RETURN NUMBER ;

  -- rmunjulu 4299668 Added
  FUNCTION get_asset_net_book_value (
   p_kle_id           IN  NUMBER,
   p_transaction_date IN  DATE DEFAULT NULL) RETURN NUMBER;

  -- rmunjulu Sales_Tax_Enhancement
  -- This function returns the tax amount for the tax TRX_ID
  -- TRX_ID can be quote_id, ar_inv_trx_id
  FUNCTION get_tax_amount (
      p_tax_trx_id           IN  NUMBER) RETURN NUMBER;

  -- rmunjulu LOANS_ENHANCEMENTS get product details
  PROCEDURE get_contract_product_details (
   p_khr_id         IN  NUMBER,
   x_deal_type      OUT NOCOPY VARCHAR2,
   x_rev_rec_method OUT NOCOPY VARCHAR2,
   x_int_cal_basis  OUT NOCOPY VARCHAR2,
   x_tax_owner      OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2);

  -- rmunjulu LOANS_ENHANCEMENTS get excess loan payment amount
  FUNCTION get_excess_loan_payment (
   p_khr_id         IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2) RETURN NUMBER;

  -- rmunjulu BUYOUT_2 check full termination transaction being processed.
  FUNCTION check_full_term_in_progress (
   p_khr_id         IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2) RETURN VARCHAR2;
--asawanka added
FUNCTION get_latest_alc_tax (
   p_top_line_id  IN  NUMBER) RETURN NUMBER;
FUNCTION get_latest_alc_serialized_flag (
   p_top_line_id  IN  NUMBER) RETURN VARCHAR2;
 FUNCTION get_latest_alc_req_id (
   p_top_line_id  IN  NUMBER) RETURN NUMBER;
 FUNCTION get_latest_alc_eff_date (
   p_top_line_id  IN  NUMBER) RETURN DATE;
 FUNCTION get_latest_alc_req_sts (
   p_top_line_id  IN  NUMBER) RETURN VARCHAR2;
 FUNCTION get_latest_alc_trx_id (
   p_top_line_id  IN  NUMBER) RETURN NUMBER;


--rbruno bug 6185552 start

  FUNCTION get_fa_nbv (
    p_chr_id   IN OKC_K_HEADERS_B.ID%TYPE
   ,p_asset_id IN  NUMBER
   ) RETURN NUMBER;

--rbruno bug 6185552 end

END OKL_AM_UTIL_PVT;

/
