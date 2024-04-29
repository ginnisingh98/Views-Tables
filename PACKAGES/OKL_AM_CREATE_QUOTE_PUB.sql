--------------------------------------------------------
--  DDL for Package OKL_AM_CREATE_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_CREATE_QUOTE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCQTS.pls 120.6.12010000.2 2009/06/15 21:55:39 sechawla ship $ */
/*#
 * Create Termination Quote API allows users to create a termination quote
 * @rep:scope internal
 * @rep:product OKL
 * @rep:displayname Create Termination Quote API
 * @rep:category BUSINESS_ENTITY OKL_TERMINATION_QUOTE
 * @rep:businessevent oracle.apps.okl.am.sendquote
 * @rep:businessevent oracle.apps.okl.am.manualquote
 * @rep:lifecycle active
 * @rep:compatibility S
 */



  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_CREATE_QUOTE_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  SUBTYPE assn_tbl_type IS OKL_AM_CREATE_QUOTE_PVT.assn_tbl_type;
  SUBTYPE quot_rec_type IS OKL_AM_CREATE_QUOTE_PVT.quot_rec_type;
  SUBTYPE tqlv_tbl_type IS OKL_AM_CREATE_QUOTE_PVT.tqlv_tbl_type;
  SUBTYPE qpyv_tbl_type IS OKL_AM_CREATE_QUOTE_PVT.qpyv_tbl_type;

  -- SECHAWLA  02-JAN-03 2699412   -- new declarations
  SUBTYPE achr_rec_type IS OKL_AM_CREATE_QUOTE_PVT.achr_rec_type;
  SUBTYPE achr_tbl_type IS OKL_AM_CREATE_QUOTE_PVT.achr_tbl_type;


  G_EMPTY_QPYV_TBL	qpyv_tbl_type;



  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  -- SECHAWLA 02-JAN-03 2699412  new procedure call
  -- To do the advance search for a given contract details.
  PROCEDURE advance_contract_search(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_achr_rec             IN achr_rec_type,
            x_achr_tbl             OUT NOCOPY achr_tbl_type);


/*#
 * Create Termination Quote API creates the termination quote.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param p_quot_rec Record type of termination quote details
 * @param p_assn_tbl Table of records of assets on termination quote
 * @param p_qpyv_tbl Table of records of parties on termination quote
 * @param x_quot_rec Record type of termination quote details
 * @param x_tqlv_tbl Table of records of  termination quote lines
 * @param x_assn_tbl Table of records of assets on termination quote
 * @param p_term_from_intf  To identify whether the quote is to be auto approved or not from Termination Interface
 * @rep:displayname Create Termination Quote
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 */
  PROCEDURE create_terminate_quote(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_quot_rec			IN  quot_rec_type,
    p_assn_tbl			IN  assn_tbl_type,
    p_qpyv_tbl			IN  qpyv_tbl_type DEFAULT G_EMPTY_QPYV_TBL,
    x_quot_rec			OUT NOCOPY quot_rec_type,
    x_tqlv_tbl			OUT NOCOPY tqlv_tbl_type,
    x_assn_tbl			OUT NOCOPY assn_tbl_type,
    p_term_from_intf    IN VARCHAR2 DEFAULT 'N'); --Added parameter by sechawla for bug 7383445



END OKL_AM_CREATE_QUOTE_PUB;

/
