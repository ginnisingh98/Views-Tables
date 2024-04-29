--------------------------------------------------------
--  DDL for Package OKL_AM_REMARKET_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_REMARKET_ASSET_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRMKS.pls 120.3 2005/10/30 04:36:18 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP		                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_REQUIRED_VALUE                  CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE	                CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN	                CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	            CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	            CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD                CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR                CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN                   CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN                   CONSTANT VARCHAR2(200) := 'SQLcode';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME		                CONSTANT VARCHAR2(200) := 'OKL_AM_REMARKET_ASSET_PVT';
  G_APP_NAME		                CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;





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

-- remove item from inventory
-- SECHAWLA 21-OCT-04 3924244 : changed p_order_header_id to p_order_line_Id
PROCEDURE remove_rmk_item
(    p_api_version           IN  	NUMBER,
     p_init_msg_list         IN  	VARCHAR2 DEFAULT OKL_API.G_FALSE,
     p_order_line_Id         IN     NUMBER ,
     x_return_status         OUT 	NOCOPY VARCHAR2,
     x_msg_count             OUT 	NOCOPY NUMBER,
     x_msg_data              OUT 	NOCOPY VARCHAR2

);


END OKL_AM_REMARKET_ASSET_PVT;

 

/
