--------------------------------------------------------
--  DDL for Package OKL_AM_CALC_QUOTE_PYMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_CALC_QUOTE_PYMNT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCQPS.pls 120.3 2005/10/30 04:32:44 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_CALC_QUOTE_PYMNT_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_INVALID_VALUE        CONSTANT VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_INVALID_VALUE1       CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := okc_api.G_REQUIRED_VALUE;
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
  G_COL_NAME_TOKEN	     CONSTANT VARCHAR2(200)	:= OKC_API.G_COL_NAME_TOKEN;


  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  G_CURRENT_STATUS              CONSTANT VARCHAR2(30) := 'CURRENT';
  G_PROPOSED_STATUS             CONSTANT VARCHAR2(30) := 'PROPOSED';

  G_CASH_FLOW_TYPE              CONSTANT VARCHAR2(30) := 'PAYMENT_SCHEDULE';

  G_LINKED_SERVICE_LINE_TYPE    CONSTANT VARCHAR2(30) := 'LINK_SERV_ASSET';

  G_CONTRACT_OBJ_TYPE           CONSTANT VARCHAR2(30) := 'LEASE_CONTRACT';
  G_FIN_ASSET_OBJ_TYPE          CONSTANT VARCHAR2(30) := 'FINANCIAL_ASSET_LINE';
  G_SERVICE_LINE_OBJ_TYPE       CONSTANT VARCHAR2(30) := 'SERVICE_LINE';
  G_FEE_LINE_OBJ_TYPE           CONSTANT VARCHAR2(30) := 'FEE_LINE';
  G_SERV_ASSET_OBJ_TYPE         CONSTANT VARCHAR2(30) := 'SERVICED_ASSET_LINE';

  G_OBJECT_SRC_TABLE            CONSTANT VARCHAR2(30) := 'OKL_TRX_QUOTES_B';

  --Bug #3921591: pagarg +++ Rollover +++
  -- constants for linked fee line type and fee asset line cash flow object type
  G_LINKED_FEE_LINE_TYPE        CONSTANT VARCHAR2(15) := 'LINK_FEE_ASSET';
  G_FEE_ASSET_OBJ_TYPE          CONSTANT VARCHAR2(15) := 'FEE_ASSET_LINE';

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/


  TYPE pymt_smry_uv_rec_type IS RECORD (

--PAGARG Bug 4299668: Define Stream type id also.
     p_strm_type_id     NUMBER,
     p_strm_type_code   VARCHAR2(150),
     p_curr_total       NUMBER ,
     p_prop_total       NUMBER);

  TYPE pymt_smry_uv_tbl_type IS TABLE OF pymt_smry_uv_rec_type INDEX BY BINARY_INTEGER;



/*========================================================================
 | PUBLIC PROCEDURE get_payment_summary
 |
 | DESCRIPTION
 |     This procedure is used by the first payment screen to display payment
 |     summary information
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_qte_id                IN      Quote ID
 |      x_pymt_smry_tbl         OUT     Payment Summary Table
 |      x_pymt_smry_tbl_count   OUT     Payment Summary Table Count
 |      x_total_curr_amt        OUT     Total Curernt Amount
 |      x_total_prop_amt        OUT     Total proposed Amount
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 14-OCT-2003           SECHAWLA          Created
 |
 *=======================================================================*/

  PROCEDURE get_payment_summary(
    p_api_version		     IN  NUMBER,
	p_init_msg_list  	     IN  VARCHAR2,
	x_msg_count	         	 OUT NOCOPY NUMBER,
	x_msg_data		         OUT NOCOPY VARCHAR2,
	x_return_status  	     OUT NOCOPY VARCHAR2,
    p_qte_id                 IN  NUMBER,
    x_pymt_smry_tbl          OUT NOCOPY pymt_smry_uv_tbl_type,
    x_pymt_smry_tbl_count    OUT NOCOPY NUMBER,
    x_total_curr_amt         OUT NOCOPY NUMBER,
    x_total_prop_amt         OUT NOCOPY NUMBER) ;


  /*========================================================================
 | PUBLIC PROCEDURE calc_quote_payments
 |
 | DESCRIPTION
 |    This procedure calculates the revised payments for a partial
 |    termination quote
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_quote_id              IN      Quote ID
 |
 | CALLS
 |      get_current_payments, calc_proposed_payments
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 14-OCT-2003           SECHAWLA          Created
 |
 *=======================================================================*/
  PROCEDURE calc_quote_payments(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_quote_id          IN  NUMBER);


END OKL_AM_CALC_QUOTE_PYMNT_PVT;

 

/
