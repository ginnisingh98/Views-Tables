--------------------------------------------------------
--  DDL for Package OKL_AM_REMARKET_ASSET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_REMARKET_ASSET_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRMKS.pls 120.3 2005/10/30 03:34:19 appldev noship $ */


---------------------------------------------------------------------------
   --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

   G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_REMARKET_ASSET_PUB';
   G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';




  -- create item for remarketing
PROCEDURE create_rmk_item
(    p_api_version           IN  	NUMBER,
     p_init_msg_list         IN  	VARCHAR2 DEFAULT OKL_API.G_FALSE,
     p_item_number           IN     VARCHAR2, -- 04-OCT-04 SECHAWLA  3924244 : added new parameter
     p_Item_Description      IN     VARCHAR2,
     p_Item_Price            IN     NUMBER DEFAULT OKL_API.G_MISS_NUM,
     p_quantity              IN     NUMBER DEFAULT 1,
     x_return_status         OUT 	NOCOPY VARCHAR2,
     x_msg_count             OUT 	NOCOPY NUMBER,
     x_msg_data              OUT 	NOCOPY VARCHAR2,
     x_new_item_number       OUT    NOCOPY VARCHAR2,
     x_new_item_id           OUT    NOCOPY NUMBER
);


-- remove item
PROCEDURE remove_rmk_item
(    p_api_version           IN  	NUMBER,
     p_init_msg_list         IN  	VARCHAR2 DEFAULT OKL_API.G_FALSE,
     --  SECHAWLA 21-OCT-04 3924244   : changed p_order_header_id to p_order_line_id
     p_order_line_Id         IN     NUMBER ,
     x_return_status         OUT 	NOCOPY VARCHAR2,
     x_msg_count             OUT 	NOCOPY NUMBER,
     x_msg_data              OUT 	NOCOPY VARCHAR2

);



END OKL_AM_REMARKET_ASSET_PUB;

 

/
