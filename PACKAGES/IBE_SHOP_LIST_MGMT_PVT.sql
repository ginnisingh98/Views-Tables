--------------------------------------------------------
--  DDL for Package IBE_SHOP_LIST_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_SHOP_LIST_MGMT_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVQOCSLS.pls 120.0.12010000.4 2010/04/08 12:10:48 ukalaiah noship $ */

PROCEDURE Save_New_ShopList(
   p_api_version              IN  NUMBER   := 1                  ,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status            OUT NOCOPY VARCHAR2                       ,
   x_msg_count                OUT NOCOPY NUMBER                         ,
   x_msg_data                 OUT NOCOPY VARCHAR2                       ,
   p_inventory_item_id          IN  JTF_Number_Table                         ,
   p_org_id          IN  NUMBER                         ,
   p_qty IN  NUMBER                         ,
   p_uom          IN  JTF_Varchar2_Table_100                        ,
   p_minisite_id              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_last_update_date         IN  DATE     := FND_API.G_MISS_DATE,
   p_mode                     IN  VARCHAR2 := 'MERGE'            ,
   p_combine_same_item        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_sl_header_rec            IN  IBE_Shop_List_PVT.SL_Header_Rec_Type             ,
   x_sl_header_id             OUT NOCOPY NUMBER                      ,
   p_item_type_code           IN JTF_Varchar2_Table_100
);

PROCEDURE Save_New_ShopList(
   p_api_version              IN  NUMBER   := 1                  ,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status            OUT NOCOPY VARCHAR2                       ,
   x_msg_count                OUT NOCOPY NUMBER                         ,
   x_msg_data                 OUT NOCOPY VARCHAR2                       ,
   p_inventory_item_id          IN  JTF_Number_Table                         ,
   p_org_id          IN  NUMBER                         ,
   p_qty IN  NUMBER                         ,
   p_uom          IN  JTF_Varchar2_Table_100                        ,
   p_minisite_id              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_last_update_date         IN  DATE     := FND_API.G_MISS_DATE,
   p_mode                     IN  VARCHAR2 := 'MERGE'            ,
   p_combine_same_item        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_party_id				  IN  NUMBER                         ,
   p_cust_account_id		  IN  NUMBER                         ,
   p_shopping_list_name	      IN  VARCHAR2                       ,
   p_list_description		  IN  VARCHAR2 := FND_API.G_MISS_CHAR,

   x_sl_header_id             OUT NOCOPY NUMBER                  ,
   p_item_type_code           IN JTF_Varchar2_Table_100
);

PROCEDURE Add_Item_to_ShopList(
   p_api_version              IN  NUMBER   := 1                  ,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status            OUT NOCOPY VARCHAR2                       ,
   x_msg_count                OUT NOCOPY NUMBER                         ,
   x_msg_data                 OUT NOCOPY VARCHAR2                       ,
   p_inventory_item_id          IN  JTF_Number_Table                         ,
   p_org_id          IN  NUMBER                         ,
   p_qty IN  NUMBER                         ,
   p_uom          IN  JTF_Varchar2_Table_100                        ,
   p_minisite_id              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_last_update_date         IN  DATE     := FND_API.G_MISS_DATE,
   p_mode                     IN  VARCHAR2 := 'MERGE'            ,
   p_combine_same_item        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_party_id				  IN  NUMBER                         ,
   p_cust_account_id		  IN  NUMBER                         ,
   p_shopping_list_name	      IN  VARCHAR2                       ,
   p_list_description		  IN  VARCHAR2 := FND_API.G_MISS_CHAR,

   x_sl_header_id             OUT NOCOPY NUMBER                  ,
   p_shp_list_id             IN  NUMBER                          ,
   p_item_type_code           IN JTF_Varchar2_Table_100
);

END IBE_Shop_List_MGMT_PVT;


/
