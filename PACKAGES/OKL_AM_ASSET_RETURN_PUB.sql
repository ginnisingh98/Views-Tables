--------------------------------------------------------
--  DDL for Package OKL_AM_ASSET_RETURN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_ASSET_RETURN_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPARRS.pls 120.2 2005/10/30 04:21:34 appldev noship $ */
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_ASSET_RETURN_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

  SUBTYPE artv_rec_type IS OKL_AM_ASSET_RETURN_PVT.artv_rec_type;
  SUBTYPE artv_tbl_type IS OKL_AM_ASSET_RETURN_PVT.artv_tbl_type;

  PROCEDURE create_asset_return(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_artv_rec			  	IN artv_rec_type,
    x_artv_rec			   	OUT NOCOPY artv_rec_type,
    p_quote_id                          IN NUMBER DEFAULT NULL);

  PROCEDURE update_asset_return(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_artv_rec					   	IN artv_rec_type,
    x_artv_rec					   	OUT NOCOPY artv_rec_type);

  PROCEDURE create_asset_return(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_artv_tbl			   	IN artv_tbl_type,
    x_artv_tbl			   	OUT NOCOPY artv_tbl_type,
    p_quote_id                          IN NUMBER DEFAULT NULL);

  PROCEDURE update_asset_return(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_artv_tbl					   	IN artv_tbl_type,
    x_artv_tbl					   	OUT NOCOPY artv_tbl_type);

END OKL_AM_ASSET_RETURN_PUB;

 

/
