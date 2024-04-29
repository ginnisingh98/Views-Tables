--------------------------------------------------------
--  DDL for Package OKL_AM_RESTRUCTURE_RENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_RESTRUCTURE_RENTS_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKLRRSRS.pls 115.5 2002/08/15 18:27:39 rdraguil noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

  G_APP_NAME		CONSTANT VARCHAR2(3)	:=  OKL_API.G_APP_NAME;
  G_API_VERSION		CONSTANT NUMBER		:= 1;
  G_PKG_NAME		CONSTANT VARCHAR2(30)	:= 'OKL_AM_RESTRUCTURE_RENTS_PVT';

  G_UNEXPECTED_ERROR	CONSTANT VARCHAR2(200)	:= 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN	CONSTANT VARCHAR2(200)	:= 'SQLerrm';
  G_SQLCODE_TOKEN	CONSTANT VARCHAR2(200)	:= 'SQLcode';
  G_REQUIRED_VALUE	CONSTANT VARCHAR2(200)	:= OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE	CONSTANT VARCHAR2(200)	:= OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN	CONSTANT VARCHAR2(200)	:= OKL_API.G_COL_NAME_TOKEN;

  G_YES			CONSTANT VARCHAR2(1)	:= 'Y';
  G_NO			CONSTANT VARCHAR2(1)	:= 'N';

  G_MISS_NUM		CONSTANT NUMBER		:= OKL_API.G_MISS_NUM;
  G_MISS_CHAR		CONSTANT VARCHAR2(1)	:= OKL_API.G_MISS_CHAR;
  G_MISS_DATE		CONSTANT DATE		:= OKL_API.G_MISS_DATE;

  G_RENTS_LINE		CONSTANT VARCHAR2(30)	:= 'RES_RENTS';
  G_YIELDS_LINE		CONSTANT VARCHAR2(30)	:= 'RES_YIELDS';

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  SUBTYPE csm_lease_rec_type		IS  OKL_CREATE_STREAMS_PUB.csm_lease_rec_type;
  SUBTYPE csm_one_off_fee_tbl_type	IS  OKL_CREATE_STREAMS_PUB.csm_one_off_fee_tbl_type;
  SUBTYPE csm_periodic_expenses_tbl_type IS  OKL_CREATE_STREAMS_PUB.csm_periodic_expenses_tbl_type;
  SUBTYPE csm_yields_tbl_type		IS  OKL_CREATE_STREAMS_PUB.csm_yields_tbl_type;
  SUBTYPE csm_stream_types_tbl_type	IS  OKL_CREATE_STREAMS_PUB.csm_stream_types_tbl_type;
  SUBTYPE csm_line_details_tbl_type	IS  OKL_CREATE_STREAMS_PUB.csm_line_details_tbl_type;

  SUBTYPE srlv_tbl_type			IS  OKL_PROCESS_STREAMS_PVT.srlv_tbl_type;
  SUBTYPE yields_tbl_type		IS  OKL_PROCESS_STREAMS_PVT.yields_tbl_type;

  SUBTYPE tqlv_tbl_type			IS okl_txl_quote_lines_pub.tqlv_tbl_type;
  SUBTYPE tqlv_rec_type			IS okl_txl_quote_lines_pub.tqlv_rec_type;
  SUBTYPE qtev_rec_type			IS okl_trx_quotes_pub.qtev_rec_type;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------
  PROCEDURE initiate_request(
	p_api_version               IN  NUMBER,
	p_init_msg_list             IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	p_quote_id                  IN  OKL_TRX_QUOTES_B.ID%TYPE,
	x_return_status             OUT NOCOPY VARCHAR2,
	x_msg_count                 OUT NOCOPY NUMBER,
	x_msg_data                  OUT NOCOPY VARCHAR2,
	x_request_id                OUT NOCOPY NUMBER,
	x_trans_status              OUT NOCOPY VARCHAR2);

  PROCEDURE process_results(
              p_api_version         IN  NUMBER,
              p_init_msg_list       IN  VARCHAR2,
              p_generation_context  IN  VARCHAR2,
              p_jtot_object1_code   IN  VARCHAR2,
              p_object1_id1         IN  VARCHAR2,
              p_chr_id              IN  NUMBER,
              p_rent_tbl            IN  srlv_tbl_type,
              p_yield_tbl           IN  yields_tbl_type,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_msg_count           OUT NOCOPY NUMBER,
              x_msg_data            OUT NOCOPY VARCHAR2);

END OKL_AM_RESTRUCTURE_RENTS_PVT;

 

/
