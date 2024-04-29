--------------------------------------------------------
--  DDL for Package OKL_PROP_TAX_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROP_TAX_ADJ_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLREPRS.pls 120.2 2005/10/30 04:02:31 appldev noship $ */

  G_PKG_NAME	CONSTANT VARCHAR2(30)  := 'OKL_PROP_TAX_ADJ_PVT';

  PROCEDURE create_adjustment_invoice
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
    ,p_asset_number     IN  VARCHAR2	DEFAULT NULL);


END OKL_PROP_TAX_ADJ_PVT;

 

/
