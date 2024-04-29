--------------------------------------------------------
--  DDL for Package OKL_AM_CREATE_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_CREATE_QUOTE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCQTS.pls 120.3.12010000.2 2009/06/15 21:58:55 sechawla ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_CREATE_QUOTE_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_INVALID_VALUE        CONSTANT VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_INVALID_VALUE1       CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE'; -- SECHAWLA 2699412 02-DEC-03 Moved from okl_am_util_pvt
  G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := okc_api.G_REQUIRED_VALUE; -- SECHAWLA 28-FEB-03 Bug # 2757175 : Added
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
  G_COL_NAME_TOKEN	     CONSTANT VARCHAR2(200)	:= OKC_API.G_COL_NAME_TOKEN;

  G_YES                  CONSTANT VARCHAR2(1)   := 'Y';
  G_NO                   CONSTANT VARCHAR2(1)   := 'N';

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE  quot_rec_type IS OKL_TRX_QUOTES_PUB.qtev_rec_type;
  SUBTYPE  tqlv_tbl_type IS OKL_TXL_QUOTE_LINES_PUB.tqlv_tbl_type;
  SUBTYPE  qpyv_tbl_type IS OKL_QUOTE_PARTIES_PUB.qpyv_tbl_type;

  G_EMPTY_QPYV_TBL	qpyv_tbl_type;

  TYPE assn_rec_type IS RECORD (
     p_asset_id           NUMBER        := OKC_API.G_MISS_NUM,
     p_asset_number       VARCHAR2(200) := OKC_API.G_MISS_CHAR,
     p_asset_qty          NUMBER,
     p_quote_qty          NUMBER,
     p_split_asset_number OKC_K_LINES_V.name%TYPE := OKC_API.G_MISS_CHAR); -- RMUNJULU 2757312 Added

  TYPE assn_tbl_type IS TABLE OF assn_rec_type INDEX BY BINARY_INTEGER;

  -- SECHAWLA 02-JAN-03 2699412 Added the following declarations as part of moving procedure advance_contract_search from
  -- okl_am_util_pvt to create quote API



  -- Record structure for contract details search.
  TYPE achr_rec_type IS RECORD (
       asset_number     OKC_K_LINES_TL.NAME%TYPE := NULL,
       serial_number    CSI_ITEM_INSTANCES.SERIAL_NUMBER%TYPE := NULL,
       chr_id           OKC_K_HEADERS_B.ID%TYPE := NULL,
       contract_number  OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE := NULL,
       from_start_date  OKC_K_HEADERS_B.START_DATE%TYPE := NULL,
       to_start_date    OKC_K_HEADERS_B.START_DATE%TYPE := NULL,
       from_end_date    OKC_K_HEADERS_B.END_DATE%TYPE := NULL,
       to_end_date      OKC_K_HEADERS_B.END_DATE%TYPE := NULL,
       sts_code         OKC_K_HEADERS_B.STS_CODE%TYPE := NULL,
       sts_meaning      OKC_STATUSES_TL.MEANING%TYPE := NULL,
       org_id           OKC_K_HEADERS_B.AUTHORING_ORG_ID%TYPE := NULL,
       party_name       HZ_PARTIES.PARTY_NAME%TYPE := NULL);

  TYPE achr_tbl_type IS TABLE OF achr_rec_type
            INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  -- To do the advance search for a given contract details.
  PROCEDURE advance_contract_search(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_achr_rec             IN achr_rec_type,
            x_achr_tbl             OUT NOCOPY achr_tbl_type);
  -- SECHAWLA 02-JAN-03 2699412  end new declarations

  PROCEDURE quote_effectivity(
    p_quot_rec			IN quot_rec_type,
    p_rule_chr_id		IN NUMBER DEFAULT NULL,
    x_quote_eff_days		OUT NOCOPY NUMBER,
    x_quote_eff_max_days	OUT NOCOPY NUMBER,
    x_return_status		OUT NOCOPY VARCHAR2);

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
	p_term_from_intf    IN VARCHAR2 DEFAULT 'N'); --Added new parameter : sechawla bug 7383445

  -- RMUNJULU 2757312 Added
  -- Function to return if asset_number exists
  FUNCTION asset_number_exists(p_asset_number IN VARCHAR2,
                               p_control      IN VARCHAR2 DEFAULT NULL,   -- RMUNJULU 3241502 Added p_control
                               x_asset_exists OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2;

  -- PAGARG Bug 4102565 Brought out the procedure to spec as it is now called
  -- from OKL_AM_TERMNT_QUOTE_PVT
  PROCEDURE get_net_gain_loss(
            p_quote_rec         IN quot_rec_type,
            p_chr_id            IN NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_net_gain_loss     OUT NOCOPY NUMBER);

  --RKUTTIYA Added for Sprint 2 of Loans Repossession
  -- Function to check whether Repossession
  FUNCTION check_repo_quote(p_quote_id IN VARCHAR2,
                             x_return_status  OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

END OKL_AM_CREATE_QUOTE_PVT;

/
