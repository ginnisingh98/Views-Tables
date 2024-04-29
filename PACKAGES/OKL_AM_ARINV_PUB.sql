--------------------------------------------------------
--  DDL for Package OKL_AM_ARINV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_ARINV_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPARVS.pls 115.2 2002/07/19 18:44:01 rmunjulu noship $ */

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_ARINV_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

  SUBTYPE ariv_tbl_type IS OKL_AM_ARINV_PVT.ariv_tbl_type;

  PROCEDURE create_asset_repair_invoice
    ( p_api_version                  IN  NUMBER
    , p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    , x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
    , p_ariv_tbl                     IN  ariv_tbl_type) ;

PROCEDURE Approve_Asset_Repair (
	p_api_version  	IN  NUMBER,
	p_init_msg_list	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count   	OUT NOCOPY NUMBER,
	x_msg_data    	OUT NOCOPY VARCHAR2,
	p_ariv_tbl	    IN  ariv_tbl_type,
	x_ariv_tbl	    OUT NOCOPY ariv_tbl_type);

END OKL_AM_ARINV_PUB;

 

/
