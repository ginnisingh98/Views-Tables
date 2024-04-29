--------------------------------------------------------
--  DDL for Package OKL_AM_REPURCHASE_ASSET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_REPURCHASE_ASSET_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRQUS.pls 115.0 2002/03/26 18:56:52 pkm ship       $ */


  SUBTYPE  qtev_rec_type IS OKL_AM_REPURCHASE_ASSET_PVT.qtev_rec_type;
  SUBTYPE  tqlv_tbl_type IS OKL_AM_REPURCHASE_ASSET_PVT.tqlv_tbl_type;

  ---------------------------------------------------------------------------
  --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

   G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_REPURCHASE_ASSET_PUB';
   G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

   G_EXCEPTION_HALT_PROCESS          EXCEPTION;
  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  PROCEDURE create_repurchase_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_qtev_rec                      IN qtev_rec_type,
    p_tqlv_tbl					   	IN tqlv_tbl_type,
    x_qtev_rec                      OUT NOCOPY qtev_rec_type,
    x_tqlv_tbl					   	OUT NOCOPY tqlv_tbl_type);

  PROCEDURE update_repurchase_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_qtev_rec                      IN qtev_rec_type,
    p_tqlv_tbl					   	IN tqlv_tbl_type,
    x_qtev_rec                      OUT NOCOPY qtev_rec_type,
    x_tqlv_tbl					   	OUT NOCOPY tqlv_tbl_type);

END OKL_AM_REPURCHASE_ASSET_PUB;

 

/
