--------------------------------------------------------
--  DDL for Package OKL_AM_CALC_QUOTE_STREAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_CALC_QUOTE_STREAM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCQSS.pls 120.4 2007/04/10 10:14:54 akrangan noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE qtev_rec_type	IS okl_trx_quotes_pub.qtev_rec_type;
  SUBTYPE tqlv_rec_type	IS okl_txl_quote_lines_pub.tqlv_rec_type;
  SUBTYPE tqlv_tbl_type	IS okl_txl_quote_lines_pub.tqlv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  -- Line style from Lease Authoring APIs

  -- Sell Service Line Style
  G_SERVICE_STYLE	CONSTANT VARCHAR2(30)	:= 'SOLD_SERVICE';
  -- Link Service Asset Line Style
  G_SERVICE_LINK_STYLE	CONSTANT VARCHAR2(30)	:= 'LINK_SERV_ASSET';
  -- Fee Line Style
  G_FEE_STYLE		CONSTANT VARCHAR2(30)	:= 'FEE';
  -- Link Fee Asset Line Style
  G_FEE_LINK_STYLE	CONSTANT VARCHAR2(30)	:= 'LINK_FEE_ASSET';

  -- Separator for the list of processed line styles
  G_SEP			CONSTANT VARCHAR2(30)	:= ':';

  -- Default Formula for calculating Service and Fees
  G_DEFAULT_FORMULA	CONSTANT VARCHAR2(30)	:= 'LINE_UNBILLED_STREAMS';

  -- A parameter to be passed to formula calculation API
  G_FORMULA_PARAM_1	CONSTANT VARCHAR2(30)	:= 'STREAM TYPE';

  --SECHAWLA 21-APR-03 2925120 : Added this global constant to store the prorate ratio for Service and Fee lines
  G_PRORATE_RATIO   CONSTANT NUMBER := 1;
  --akrangan Bug 5495474 start
  --similar to the above, for Contractual Fee, Unbilled Receivables
  G_CONTRACTUAL_FEE_DONE VARCHAR2(3):='N';
  G_UNBILLED_RECEIVABLES_DONE VARCHAR2(3):='N';
  --akrangan Bug 5495474 end
  -- Validation for missing fields
  G_MISS_NUM		CONSTANT NUMBER		:= OKL_API.G_MISS_NUM;
  G_MISS_CHAR		CONSTANT VARCHAR2(1)	:= OKL_API.G_MISS_CHAR;
  G_MISS_DATE		CONSTANT DATE		:= OKL_API.G_MISS_DATE;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS FOR ERROR HANDLING
  ---------------------------------------------------------------------------

  G_APP_NAME		CONSTANT VARCHAR2(3)	:=  OKL_API.G_APP_NAME;
  G_API_VERSION		CONSTANT NUMBER		:= 1;
  G_PKG_NAME		CONSTANT VARCHAR2(200)	:=
					'OKL_AM_CALC_QUOTE_STREAM_PVT';

  G_SQLCODE_TOKEN	CONSTANT VARCHAR2(200)	:= 'SQLCODE';
  G_SQLERRM_TOKEN	CONSTANT VARCHAR2(200)	:= 'SQLERRM';
  G_UNEXPECTED_ERROR	CONSTANT VARCHAR2(200)	:=
					 'OKL_CONTRACTS_UNEXPECTED_ERROR';

  -- rmunjulu 4996136 :
  -- set in OKL_AM_CALCULATE_QUOTE_PVT.process_top_formula_new() and
  -- checked in OKL_AM_CALC_QUOTE_STREAM_PVT.process_outstanding_balances( )
  -- to prevent duplicate of OUTSTANDING_BALANCE
  G_OUTSTANDING_BAL_DONE VARCHAR2(3):='N';

  -- rmunjulu 16-mar-06 5066471 : similar to the above, for SERVICE AND MAINTANCE
  G_SERVICE_BAL_DONE VARCHAR2(3):='N';

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  -- The main body of the calculate quote by stream type
  PROCEDURE calc_stream_type_operand (
		p_operand	IN VARCHAR2,
		p_qtev_rec	IN qtev_rec_type,
		p_cle_id	IN NUMBER,
		p_formula_name	IN VARCHAR2 DEFAULT NULL,
		px_tqlv_tbl	IN OUT NOCOPY tqlv_tbl_type,
		x_operand_total	OUT NOCOPY NUMBER,
		x_return_status	OUT NOCOPY VARCHAR2);

END OKL_AM_CALC_QUOTE_STREAM_PVT;

/
