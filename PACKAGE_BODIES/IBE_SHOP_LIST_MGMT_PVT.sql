--------------------------------------------------------
--  DDL for Package Body IBE_SHOP_LIST_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_SHOP_LIST_MGMT_PVT" AS
/* $Header: IBEVQOCSLB.pls 120.0.12010000.5 2010/04/14 13:52:51 ukalaiah noship $ */
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
   x_sl_header_id             OUT NOCOPY NUMBER                               ,
   p_item_type_code           IN JTF_Varchar2_Table_100
) IS

l_sl_line_tbl                 IBE_Shop_List_PVT.SL_Line_Tbl_Type
                                    := IBE_Shop_List_PVT.G_MISS_SL_LINE_TBL;
   l_sl_line_rel_tbl             IBE_Shop_List_PVT.SL_Line_Rel_Tbl_Type
           := IBE_Shop_List_PVT.G_MISS_SL_LINE_REL_TBL;
   L_ORG_ID      CONSTANT NUMBER       := FND_Profile.Value('ORG_ID');
BEGIN
        FOR i IN 1..p_inventory_item_id.COUNT LOOP
        BEGIN
          l_sl_line_tbl(i).inventory_item_id           := p_inventory_item_id(i);
          l_sl_line_tbl(i).quantity                    := p_qty;
          l_sl_line_tbl(i).uom_code                    := p_uom(i);
          l_sl_line_tbl(i).organization_id             := p_org_id;
          l_sl_line_tbl(i).org_id                      := L_ORG_ID;
          l_sl_line_tbl(i).item_type_code              := p_item_type_code(i);
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
          END;
        END LOOP;

      IBE_Shop_List_PVT.Save(
         p_api_version         =>  p_api_version,
         p_init_msg_list       =>  p_init_msg_list,
         p_commit              =>  p_commit,
         x_return_status       =>  x_return_status,
         x_msg_count           =>  x_msg_count,
         x_msg_data            =>  x_msg_data,
         p_combine_same_item   =>  p_combine_same_item,
         p_sl_header_rec       =>  p_sl_header_rec,
         p_sl_line_tbl         =>  l_sl_line_tbl,
         p_sl_line_rel_tbl     =>  l_sl_line_rel_tbl,
         x_sl_header_id        =>  x_sl_header_id
      );
end Save_New_ShopList;


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

   x_sl_header_id             OUT NOCOPY NUMBER            ,
   p_item_type_code        IN JTF_Varchar2_Table_100
) IS
p_sl_header_rec   IBE_Shop_List_PVT.SL_Header_Rec_Type := IBE_Shop_List_PVT.G_MISS_SL_HEADER_REC;


BEGIN

        p_sl_header_rec.party_id			:= p_party_id;
        p_sl_header_rec.cust_account_id		:= p_cust_account_id;
        p_sl_header_rec.shopping_list_name	:= p_shopping_list_name;
        p_sl_header_rec.description			:= p_list_description;


      IBE_Shop_List_MGMT_PVT.Save_New_ShopList(
	     p_api_version              => p_api_version                  ,
	     p_init_msg_list            => p_init_msg_list     ,
	     p_commit                   => p_commit    ,
	     x_return_status            => x_return_status	,
	     x_msg_count                => x_msg_count      ,
	     x_msg_data                 => x_msg_data       ,
	     p_inventory_item_id        => p_inventory_item_id    ,
	     p_org_id                   => p_org_id        ,
	     p_qty 						=> p_qty       ,
	     p_uom          			=> p_uom       ,
	     p_minisite_id              => p_minisite_id ,
	     p_last_update_date         => p_last_update_date ,
	     p_mode                     => p_mode            ,
	     p_combine_same_item        => p_combine_same_item ,
	     p_sl_header_rec            => p_sl_header_rec     ,
	     x_sl_header_id             => x_sl_header_id     ,
       p_item_type_code           => p_item_type_code
      );

end Save_New_ShopList;

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

   x_sl_header_id             OUT NOCOPY NUMBER,
   p_shp_list_id             IN  NUMBER         ,
   p_item_type_code        IN JTF_Varchar2_Table_100

) IS
p_sl_header_rec   IBE_Shop_List_PVT.SL_Header_Rec_Type := IBE_Shop_List_PVT.G_MISS_SL_HEADER_REC;


BEGIN

        p_sl_header_rec.party_id			:= p_party_id;
        p_sl_header_rec.cust_account_id		:= p_cust_account_id;
        --p_sl_header_rec.shopping_list_name	:= p_shopping_list_name;
        p_sl_header_rec.description			:= p_list_description;
        p_sl_header_rec.shp_list_id			:= p_shp_list_id;


      IBE_Shop_List_MGMT_PVT.Save_New_ShopList(
	     p_api_version              => p_api_version                  ,
	     p_init_msg_list            => p_init_msg_list     ,
	     p_commit                   => p_commit    ,
	     x_return_status            => x_return_status	,
	     x_msg_count                => x_msg_count      ,
	     x_msg_data                 => x_msg_data       ,
	     p_inventory_item_id        => p_inventory_item_id    ,
	     p_org_id                   => p_org_id        ,
	     p_qty 						=> p_qty       ,
	     p_uom          			=> p_uom       ,
	     p_minisite_id              => p_minisite_id ,
	     p_last_update_date         => p_last_update_date ,
	     p_mode                     => p_mode            ,
	     p_combine_same_item        => p_combine_same_item ,
	     p_sl_header_rec            => p_sl_header_rec     ,
	     x_sl_header_id             => x_sl_header_id      ,
       p_item_type_code           => p_item_type_code
       );
end Add_Item_to_ShopList;

END IBE_Shop_List_MGMT_PVT;

/
