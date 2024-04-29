--------------------------------------------------------
--  DDL for Package OKL_AM_CALCULATE_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_CALCULATE_QUOTE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCQUS.pls 120.4.12010000.2 2009/06/02 10:38:40 racheruv ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

--  SECHAWLA - Bug 2680542 - Changed the asset_tbl_type to subtype from OKL_AM_CREATE_QUOTE_PVT.assn_tbl_type
  SUBTYPE	asset_tbl_type IS OKL_AM_CREATE_QUOTE_PVT.assn_tbl_type;

  TYPE	qlt_tbl_type IS TABLE OF VARCHAR2(30); -- quote line type

  SUBTYPE qtev_rec_type	IS okl_trx_quotes_pub.qtev_rec_type;
  SUBTYPE tqlv_tbl_type	IS okl_txl_quote_lines_pub.tqlv_tbl_type;
  SUBTYPE rulv_rec_type	IS okl_rule_pub.rulv_rec_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  -- SECHAWLA 24-FEB-03 Bug # 2817025 : Added a global for sysdate
  G_SYSDATE         DATE;

  -- Miscellaneous quote line type
  G_MISC_QLT		CONSTANT VARCHAR2(30)	:= 'AMCMIS';

  -- Used to store transaction warning messages
  G_QUOTE_HEADER_TABLE	CONSTANT VARCHAR2(30)	:= 'OKL_TRX_QUOTES_V';

  -- Used for quote line type validation
  G_QUOTE_LINE_LOOKUP	CONSTANT VARCHAR2(30)	:= 'OKL_QUOTE_LINE_TYPE';

  -- Generic proration formula
  --SECHAWLA 20-FEB-03 Bug # 2757368 : Use CONTRACT_OEC instead of QUOTE_GENERIC_LINE_PRORATION for prorating the
  --quote line amounts (general proration using TC prorate option)
  G_GENERIC_PRORATE	CONSTANT VARCHAR2(30) := 'CONTRACT_OEC';

  -- Element proration formula consists of element rule name plus
  -- this variable. For example, Purchase Option Formula has a
  -- rule "AMBPOC". Its proration formula is "AMBPOC Proration".
  G_PRORATE_SUFFIX	CONSTANT VARCHAR2(30) := '_PRORATION';

  -- Tax formula
  G_TAX_FORMULA		CONSTANT VARCHAR2(30)	:= 'QUOTE_TAX_CALCULATION';

  -- Tax quote line type
  G_TAX_QLT		CONSTANT VARCHAR2(30)	:= 'AMCTAX';

  -- Parameter name for the amount to be taxed
  G_TAX_AMT_PARAM	CONSTANT VARCHAR2(30)	:= 'TAXABLE AMOUNT';

  -- Financial Asset Line Style
  G_FIN_ASSET_STYLE	CONSTANT VARCHAR2(30)	:= 'FREE_FORM1';

  -- Empty tables to be used for defaults in procedure parameters
  G_EMPTY_TQLV_TBL	tqlv_tbl_type;
  G_EMPTY_ASSET_TBL	asset_tbl_type;

  -- SECHAWLA 21-APR-03 - Bug 2925120 : Unbilled Receivebles amounts not getting Unit Prorated.
  -- Declared a Global variable G_ASSET_TBL to store the original asset table, which has the quoted assets along with the asset and
  -- quote quantities. Currently, when process_operand is evaluating the first operand (AMBCOC - Contarct Obligation),
  -- it sends an empty asset table to get_operand_value procedure. This empty table is then passed to process_top_formula
  -- and process_operand for AMCTUR (stream type) operand. Since process_stream_type_operand procedure gets an empty
  -- asset table, t_tqlv_tbl (returned by calc_quote_stream API) can not be updated with quantities. l_tqlv_tbl is
  -- then passed to append_quote_line, which looks for the not null values in asset and quote quantities for doing
  -- Unit proration. Stored the asset table in the global variable and used it to update quantities in l_tqlv_tbl,
  -- before it is passed to append_quote_line.

  G_ASSET_TBL       asset_tbl_type;

  -- Validation for missing fields
  G_MISS_NUM		CONSTANT NUMBER		:= OKL_API.G_MISS_NUM;
  G_MISS_CHAR		CONSTANT VARCHAR2(1)	:= OKL_API.G_MISS_CHAR;
  G_MISS_DATE		CONSTANT DATE		:= OKL_API.G_MISS_DATE;

  -- Should a message be logged in case of missing ORG_ID
  G_ORG_ID_MISSING_MSG	BOOLEAN			:= TRUE;

  -- Bug 3061765 MDOKAL
  -- global to hold flag for indicating if contractual fee has been calculated.
  G_CONT_FEE_CALC_DONE  BOOLEAN         := FALSE;
  -- Bug 3061765 MDOKAL
  -- variable to hold flag to indicate if a formula name is found during
  -- get_operand value, if not found then append_quote_line is not called.
  G_FORMULA_VALUE_FOUND BOOLEAN         := FALSE;
  -- Bug 3061765 MDOKAL
  -- flag to identfiy if the contract fee rule is set against early or EOT
  -- rule group and then to ensure the new fee lines are not appended
  -- when processing manaual quote lines. Default processing is to perform
  -- contract fee calculation
  G_PERFORM_CONT_FEE_CALC BOOLEAN       := TRUE;

  --sechawla 30-apr-09 7575939 : begin
  G_FIN_FEE_CALC_DONE   BOOLEAN              := FALSE;
  G_ABS_FEE_CALC_DONE   BOOLEAN              := FALSE;
  G_EXP_FEE_CALC_DONE   BOOLEAN              := FALSE;
  G_GEN_FEE_CALC_DONE   BOOLEAN              := FALSE;
  G_IN_FEE_CALC_DONE    BOOLEAN              := FALSE;
  G_MISC_FEE_CALC_DONE  BOOLEAN              := FALSE;
  G_PASS_FEE_CALC_DONE  BOOLEAN              := FALSE;
  G_ROLL_FEE_CALC_DONE  BOOLEAN              := FALSE;
  --sechawla 30-apr-09 7575939 : end

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS FOR ERROR HANDLING
  ---------------------------------------------------------------------------

  G_APP_NAME		CONSTANT VARCHAR2(3)	:=  OKL_API.G_APP_NAME;
  G_API_VERSION		CONSTANT NUMBER		    :=  1;
  G_PKG_NAME		CONSTANT VARCHAR2(200)	:=	'OKL_AM_CALCULATE_QUOTE_PVT';

  G_SQLCODE_TOKEN	CONSTANT VARCHAR2(200)	:= 'SQLCODE';
  G_SQLERRM_TOKEN	CONSTANT VARCHAR2(200)	:= 'SQLERRM';
  G_UNEXPECTED_ERROR	CONSTANT VARCHAR2(200)	:= 'OKL_CONTRACTS_UNEXPECTED_ERROR';

  G_OKC_APP_NAME	CONSTANT VARCHAR2(3)	:= OKC_API.G_APP_NAME;
  G_INVALID_VALUE	CONSTANT VARCHAR2(200)	:= OKC_API.G_INVALID_VALUE;
  G_REQUIRED_VALUE	CONSTANT VARCHAR2(200)	:= OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN	CONSTANT VARCHAR2(200)	:= OKC_API.G_COL_NAME_TOKEN;
--akrangan added for bug 5568328  fix begin
  -- global variable for proration logic - bug 5568328

G_AMBCOC NUMBER :=0;
G_AMCQDR NUMBER :=0;
G_AMCQFE NUMBER :=0;
G_AMCRFE NUMBER :=0;
G_AMCRIN NUMBER :=0;
G_AMCSDD NUMBER :=0;
G_AMCTPE NUMBER :=0;
G_AMPRTX NUMBER :=0;
G_AMBPOC NUMBER :=0;
G_AMBCOC_OPTION VARCHAR2(30) :='LINE_CALCULATION';
G_AMCQDR_OPTION VARCHAR2(30) :='LINE_CALCULATION';
G_AMCQFE_OPTION VARCHAR2(30) :='LINE_CALCULATION';
G_AMCRFE_OPTION VARCHAR2(30) :='LINE_CALCULATION';
G_AMCRIN_OPTION VARCHAR2(30) :='LINE_CALCULATION';
G_AMCSDD_OPTION VARCHAR2(30) :='LINE_CALCULATION';
G_AMCTPE_OPTION VARCHAR2(30) :='LINE_CALCULATION';
G_AMPRTX_OPTION VARCHAR2(30) :='LINE_CALCULATION';
G_AMBPOC_OPTION VARCHAR2(30) :='LINE_CALCULATION';

--akrangan added for bug fix end



  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  -- The main body of the calculate quote process
  PROCEDURE generate (
		p_api_version	IN  NUMBER,
		p_init_msg_list	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
		x_msg_count	OUT NOCOPY NUMBER,
		x_msg_data	OUT NOCOPY VARCHAR2,
		x_return_status	OUT NOCOPY VARCHAR2,
		p_qtev_rec	IN  qtev_rec_type,
		p_asset_tbl	IN  asset_tbl_type,
		x_tqlv_tbl	OUT NOCOPY tqlv_tbl_type);

  -- PAGARG Bug 4102565 Brought the procedure into Spec to use it from OKL_AM_TERMNT_QUOTE_PVT
  PROCEDURE get_operand_value(
               p_rgd_code        IN VARCHAR2,
               p_operand         IN VARCHAR2,
               p_qtev_rec        IN qtev_rec_type,
               p_rule_cle_id     IN NUMBER,
               p_formul_cle_id   IN NUMBER,
               p_head_rgd_code   IN VARCHAR2,
               p_line_rgd_code   IN VARCHAR2,
               p_asset_tbl       IN asset_tbl_type,
               px_sub_tqlv_tbl   IN OUT NOCOPY tqlv_tbl_type,
               x_operand_value   OUT NOCOPY NUMBER,
               x_return_status   OUT NOCOPY VARCHAR2,
               x_min_value       OUT NOCOPY NUMBER,
               x_max_value       OUT NOCOPY NUMBER);

END OKL_AM_CALCULATE_QUOTE_PVT;

/
