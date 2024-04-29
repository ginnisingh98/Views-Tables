--------------------------------------------------------
--  DDL for Package OKL_AM_CUSTOM_RMK_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_CUSTOM_RMK_ASSET_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCRES.pls 120.1 2005/10/30 04:02:26 appldev noship $ */

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
  G_PKG_NAME		                CONSTANT VARCHAR2(200) := 'OKL_AM_CUSTOM_RMK_ASSET_PVT';
  G_APP_NAME		                CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;




PROCEDURE validate_item_info(
     p_api_version           IN  	NUMBER,
     p_init_msg_list         IN  	VARCHAR2 DEFAULT OKL_API.G_FALSE,
     p_asset_return_id       IN     NUMBER,
     p_item_number           IN     VARCHAR2,
     p_Item_Description      IN     VARCHAR2,
     p_Item_Price            IN     NUMBER DEFAULT OKL_API.G_MISS_NUM,
     p_quantity              IN     NUMBER DEFAULT 1,
     x_inv_org_id            OUT    NOCOPY NUMBER,
     x_inv_org_name          OUT    NOCOPY VARCHAR2,
     x_subinv_code           OUT    NOCOPY VARCHAR2,
     x_sys_date              OUT    NOCOPY DATE,
     x_price_list_id		 OUT    NOCOPY NUMBER,
     x_item_templ_id         OUT    NOCOPY NUMBER,
     x_return_status         OUT 	NOCOPY VARCHAR2,
     x_msg_count             OUT 	NOCOPY NUMBER,
     x_msg_data              OUT 	NOCOPY VARCHAR2);


PROCEDURE create_inv_item
(  p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
   p_asset_return_id      IN  NUMBER,
   p_Organization_Id      IN  NUMBER,
   p_organization_name    IN  VARCHAR2
 , p_Item_Description     IN  VARCHAR2
 , p_subinventory         IN  VARCHAR2
 , p_sysdate              IN  DATE
 -- SECHAWLA 05-OCT-04 3924244 : p_item_number may be populated for the master org (if user entered item no.)
 , p_item_number          IN  VARCHAR2   --SECHAWLA Bug# 2679812 : Added new parameter
 , p_item_templ_id        IN  NUMBER
 , x_New_Item_Number      OUT NOCOPY VARCHAR2
 , x_New_Item_Id          OUT NOCOPY NUMBER
 , x_Return_Status        OUT NOCOPY VARCHAR2
 , x_msg_count            OUT NOCOPY NUMBER
 , x_msg_data             OUT NOCOPY VARCHAR2);


PROCEDURE Create_Inv_Misc_Receipt
(    p_api_version          IN  NUMBER,
     p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
     p_Inventory_Item_id    IN NUMBER
  ,  p_Subinv_Code          IN VARCHAR2
  ,  p_Organization_Id      IN NUMBER
  ,  p_quantity             IN NUMBER
  ,  p_trans_type_id        IN NUMBER
  ,  p_sysdate              IN DATE
  ,  x_Return_Status        OUT NOCOPY VARCHAR2
  ,  x_msg_count            OUT NOCOPY NUMBER
  ,  x_msg_data             OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Item_Price_List
(   p_api_version       IN  NUMBER
  , p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
  , p_Price_List_id     IN  NUMBER
  , p_Item_Id           IN  NUMBER
  , p_Item_Price        IN  NUMBER
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT NOCOPY NUMBER
  , x_msg_data          OUT NOCOPY VARCHAR2
);



END OKL_AM_CUSTOM_RMK_ASSET_PVT;

 

/
