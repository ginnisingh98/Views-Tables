--------------------------------------------------------
--  DDL for Package OKL_AM_ASSET_DISPOSE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_ASSET_DISPOSE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPADPS.pls 120.5 2006/11/22 18:37:47 rravikir noship $ */

----------------------------------------------------------------------------
   --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

   G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_ASSET_DISPOSE_PUB';
   G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';





  PROCEDURE dispose_asset (	p_api_version           IN  	NUMBER,
           			p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status         OUT 	NOCOPY VARCHAR2,
                                x_msg_count             OUT 	NOCOPY NUMBER,
           			x_msg_data              OUT 	NOCOPY VARCHAR2,
				p_financial_asset_id    IN      NUMBER,
                                p_quantity              IN      NUMBER,
                                p_proceeds_of_sale      IN      NUMBER,
                                p_quote_eff_date        IN      DATE DEFAULT NULL, -- rmunjulu EDAT
                                p_quote_accpt_date      IN      DATE DEFAULT NULL, -- rmunjulu EDAT
                                p_legal_entity_id       IN      NUMBER);      -- RRAVIKIR Legal Entity Changes

  --  SECHAWLA 21-OCT-04 3924244   : changed p_order_header_id to p_order_line_id
  PROCEDURE dispose_asset (	p_api_version           IN  	NUMBER,
           			p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status         OUT 	NOCOPY VARCHAR2,
                                x_msg_count             OUT 	NOCOPY NUMBER,
           			x_msg_data              OUT 	NOCOPY VARCHAR2,
				p_order_line_id         IN      NUMBER) ;

   PROCEDURE undo_retirement(	p_api_version           IN  	NUMBER,
           			p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status         OUT 	NOCOPY VARCHAR2,
                                x_msg_count             OUT 	NOCOPY NUMBER,
           			x_msg_data              OUT 	NOCOPY VARCHAR2,
				p_retirement_id         IN      NUMBER);

   PROCEDURE expire_item (
		p_api_version		IN  NUMBER,
		p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
		x_msg_count	    	OUT NOCOPY NUMBER,
		x_msg_data		    OUT NOCOPY VARCHAR2,
		x_return_status		OUT NOCOPY VARCHAR2,
		p_instance_id		IN  NUMBER,
		p_end_date		    IN  DATE);

END OKL_AM_ASSET_DISPOSE_PUB;

/
