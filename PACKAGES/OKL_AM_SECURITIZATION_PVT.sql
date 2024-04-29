--------------------------------------------------------
--  DDL for Package OKL_AM_SECURITIZATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_SECURITIZATION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRASZS.pls 120.4 2008/02/01 06:24:36 sosharma ship $ */

/*=======================================================================+
 |  GLOBAL VARIABLES
 +=======================================================================*/

  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_SECURITIZATION_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(50)   :=  OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_INVALID_VALUE        CONSTANT VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_INVALID_VALUE1       CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := okc_api.G_REQUIRED_VALUE;
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
  G_COL_NAME_TOKEN	     CONSTANT VARCHAR2(200)	:= OKC_API.G_COL_NAME_TOKEN;

  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(100)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(100)   := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(100)   := OKL_API.G_RET_STS_UNEXP_ERROR;

  G_NO                   CONSTANT VARCHAR2(1)    := 'N';
  G_API_TYPE	         CONSTANT VARCHAR(4) := '_PVT';

  -- new globals to support changes to OKL_STREAMS table
  G_INV_AGG_ID           NUMBER;
  G_SOURCE_TABLE         CONSTANT VARCHAR2(100):= 'OKL_K_HEADERS';

/*=======================================================================+
 |  GLOBAL DATASTRUCTURES
 +=======================================================================*/

  SUBTYPE  quot_rec_type IS OKL_TRX_QUOTES_PUB.qtev_rec_type;
  SUBTYPE  tqlv_tbl_type IS OKL_TXL_QUOTE_LINES_PUB.tqlv_tbl_type;


  TYPE qte_asset_type IS RECORD (
     p_khr_id           NUMBER,
     p_kle_id           NUMBER,
     p_sty_id           NUMBER,
     p_amount           NUMBER,
     p_qlt_code         VARCHAR2(30),
     p_secured          VARCHAR2(1));


  TYPE asset_tbl_type IS TABLE OF qte_asset_type INDEX BY BINARY_INTEGER;

/*=======================================================================+
 |  PROCEDURES
 +=======================================================================*/


/*========================================================================
 | PUBLIC PROCEDURE PROCESS_SECURITIZED_STREAMS
 |
 | DESCRIPTION
 |      Main procedure, determines if securitized items existif so,
 |      disbursements are created.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Called externally from Termination Quote Acceptance workflow (OKLAMPPT).
 |      The associated workflow PACKAGE.procedure name is,
 |      OKL_AM_QUOTES_WF.chk_securitization.
 |
 |      Called externally from Asset Dsiposition PACKAGE.procedure name is,
 |      OKL_AM_ASSET_DISPOSE_PVT.dispose_asset.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_api_version    IN     Standard in parameter
 |      p_init_msg_list  IN     Standard in parameter
 |      x_return_status  OUT    Standard out parameter
 |      x_msg_count      OUT    Standard out parameter
 |      x_msg_data       OUT    Standard out parameter
 |      p_quote_id       IN     Termination Quote Identifier when called from
 |                              termincation quote acceptance.
 |      p_kle_id         IN     Asset Line identifier pased when called from
 |                              asset disposition.
 |      p_khr_id         IN     Contract Header identifier passed when called
 |                              from asset disposition
 |      p_sale_price     IN     Disposition Amount passed when called from
 |                              asset disposition.
 |      p_call_origin    IN     Used internally to identify where the has been
 |                              made from.
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 | 09-OCT-2003           MDokal            Created.
 | 06-Oct-2004           rmunjulu          EDAT Added Parameters to get transaction
 |                                         date and effective date and do processing
 |                                         based on those
 |
 *=======================================================================*/
  PROCEDURE process_securitized_streams(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_quote_id			IN  NUMBER DEFAULT NULL,
    p_kle_id            IN  NUMBER DEFAULT NULL,
    p_khr_id            IN  NUMBER DEFAULT NULL,
    p_sale_price        IN  NUMBER DEFAULT NULL,
    p_effective_date    IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_transaction_date  IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_call_origin       IN  VARCHAR2);

/*========================================================================
 | PUBLIC PROCEDURE DISBURSE_INVESTOR_RENT
 |
 | DESCRIPTION
 |      Processes invester disbursement for rent.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Called from PROCESS_SECURITIZED_STREAMS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_api_version    IN     Standard in parameter
 |      p_init_msg_list  IN     Standard in parameter
 |      x_return_status  OUT    Standard out parameter
 |      x_msg_count      OUT    Standard out parameter
 |      x_msg_data       OUT    Standard out parameter
 |      p_asset_tbl      IN     Table of asset(s) records for processing
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 | 09-OCT-2003           MDokal            Created.
 | 24-Sep-2004           rmunjulu          3910833 Set p_ia_id as parameter
 | 06-Oct-2004           rmunjulu          EDAT Added Parameters to get transaction
 |                                         date and effective date and do processing
 |                                         based on those
 |
 *=======================================================================*/
  PROCEDURE disburse_investor_rent(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ia_id             IN  NUMBER, -- rmunjulu 3910833
    p_effective_date    IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_transaction_date  IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_asset_tbl			IN  asset_tbl_type);

/*========================================================================
 | PUBLIC PROCEDURE DISBURSE_INVESTOR_RV
 |
 | DESCRIPTION
 |      Processes invester disbursement for residual value.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Called from PROCESS_SECURITIZED_STREAMS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_api_version    IN     Standard in parameter
 |      p_init_msg_list  IN     Standard in parameter
 |      x_return_status  OUT    Standard out parameter
 |      x_msg_count      OUT    Standard out parameter
 |      x_msg_data       OUT    Standard out parameter
 |      p_kle_id         IN     Asset Line identifier
 |      p_khr_id         IN     Contract Header identifier
 |      p_sale_price     IN     Disposition Amount
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 | 09-OCT-2003           MDokal            Created.
 | 24-Sep-2004           rmunjulu          3910833 Set p_ia_id as parameter
 | 06-Oct-2004           rmunjulu          EDAT Added Parameters to get transaction
 |                                         date and effective date and do processing
 |                                         based on those
 |
 *=======================================================================*/
  PROCEDURE disburse_investor_rv(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_khr_id            IN  NUMBER,
    p_kle_id            IN  NUMBER,
    p_ia_id             IN  NUMBER, -- rmunjulu 3910833
    p_effective_date    IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_transaction_date  IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_sale_price       IN  NUMBER );

/*========================================================================
 | PUBLIC PROCEDURE CREATE_POOL_TRANSACTION
 |
 | DESCRIPTION
 |      Create the pool transaction and makes pool modifications
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Called from PROCESS_SECURITIZED_STREAMS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_api_version    IN     Standard in parameter
 |      p_init_msg_list  IN     Standard in parameter
 |      x_return_status  OUT    Standard out parameter
 |      x_msg_count      OUT    Standard out parameter
 |      x_msg_data       OUT    Standard out parameter
 |      p_asset_tbl      IN     Contains a list of assets for pool transactions
 |      p_transaction_reason IN Reason required for creating pool transaction
 |      p_kle_id         IN     Asset for pool transaction
 |      p_khr_id         IN     Contract for pool transaction
 |      p_disb_type      IN     Identifies the subclass, RESIDUAL or RENT
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 | 09-OCT-2003           MDokal            Created.
 | 06-Oct-2004           rmunjulu          EDAT Added Parameters to get transaction
 |                                         date and effective date and do processing
 |                                         based on those
 |
 *=======================================================================*/
  PROCEDURE create_pool_transaction(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_asset_tbl			IN  asset_tbl_type,
    p_transaction_reason	IN  VARCHAR2,
    p_khr_id            IN  NUMBER,
    p_kle_id            IN  NUMBER,
    p_effective_date    IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_transaction_date  IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_disb_type         IN  VARCHAR2);

     /*   sosharma 17-01-2008
          modifications to include loans in Investor agreement
          Start Changes
      */

   PROCEDURE disburse_investor_loan_payment(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ia_id             IN  NUMBER,
    p_effective_date    IN  DATE DEFAULT NULL,
    p_transaction_date  IN  DATE DEFAULT NULL,
    p_asset_tbl          IN  asset_tbl_type);

/* sosharma end changes*/


END OKL_AM_SECURITIZATION_PVT;

/
