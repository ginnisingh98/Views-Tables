--------------------------------------------------------
--  DDL for Package OKL_LIKE_KIND_EXCHANGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LIKE_KIND_EXCHANGE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPLKXS.pls 115.1 2002/07/12 19:29:16 sgiyer noship $*/

  SUBTYPE rep_asset_rec_type     IS OKL_LIKE_KIND_EXCHANGE_PVT.rep_asset_rec_type;
  SUBTYPE req_asset_rec_type     IS OKL_LIKE_KIND_EXCHANGE_PVT.req_asset_rec_type;
  SUBTYPE req_asset_tbl_type     IS OKL_LIKE_KIND_EXCHANGE_PVT.req_asset_tbl_type;
  SUBTYPE rep_asset_tbl_type     IS OKL_LIKE_KIND_EXCHANGE_PVT.rep_asset_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_LIKE_KIND_EXCHANGE_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 ------------------------------------------------------------------------------

 -- Function to retrieve total match amount
 FUNCTION GET_TOTAL_MATCH_AMT (p_asset_id IN NUMBER,
                                p_tax_book IN VARCHAR2) RETURN NUMBER;

 -- Function to retrieve balance sale proceeds
 FUNCTION GET_BALANCE_SALE_PROCEEDS (p_asset_id IN NUMBER,
                                    p_tax_book IN VARCHAR2) RETURN NUMBER;

 -- Function to retrieve deferred gain
 FUNCTION GET_DEFERRED_GAIN (p_asset_id IN VARCHAR2,
                            p_tax_book IN VARCHAR2) RETURN NUMBER;

 -- this procedure is used create a like kind exchange transaction
 PROCEDURE CREATE_LIKE_KIND_EXCHANGE(
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,p_corporate_book       IN  VARCHAR2
             ,p_tax_book             IN  VARCHAR2
             ,p_comments             IN  VARCHAR2
			 ,p_rep_asset_rec        IN  rep_asset_rec_type
             ,p_req_asset_tbl        IN  req_asset_tbl_type);

END OKL_LIKE_KIND_EXCHANGE_PUB;

 

/
