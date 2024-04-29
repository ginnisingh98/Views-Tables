--------------------------------------------------------
--  DDL for Package GMF_ITEMCOST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_ITEMCOST_PVT" AUTHID CURRENT_USER AS
/* $Header: GMFVCSTS.pls 120.3.12000000.1 2007/01/17 16:53:38 appldev ship $ */
  PROCEDURE Create_Item_Cost
  (
  p_api_version                   IN          NUMBER,
  p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN          VARCHAR2 := FND_API.G_FALSE,
  x_return_status                 OUT NOCOPY  VARCHAR2,
  x_msg_count                     OUT NOCOPY  NUMBER,
  x_msg_data                      OUT NOCOPY  VARCHAR2,
  p_header_rec                    IN          GMF_ItemCost_PUB.Header_Rec_Type,
  p_this_level_dtl_tbl            IN          GMF_ItemCost_PUB.This_Level_Dtl_Tbl_Type,
  p_lower_level_dtl_Tbl           IN          GMF_ItemCost_PUB.Lower_Level_Dtl_Tbl_Type,
  p_user_id                       IN          fnd_user.user_id%TYPE,
  x_costcmpnt_ids                 OUT NOCOPY  GMF_ItemCost_PUB.costcmpnt_ids_tbl_type
  );

  PROCEDURE Update_Item_Cost
  (
  p_api_version                   IN          NUMBER,
  p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN          VARCHAR2 := FND_API.G_FALSE,
  x_return_status                 OUT NOCOPY  VARCHAR2,
  x_msg_count                     OUT NOCOPY  NUMBER,
  x_msg_data                      OUT NOCOPY  VARCHAR2,
  p_header_rec                    IN           GMF_ItemCost_PUB.Header_Rec_Type,
  p_this_level_dtl_tbl            IN           GMF_ItemCost_PUB.This_Level_Dtl_Tbl_Type,
  p_lower_level_dtl_Tbl           IN           GMF_ItemCost_PUB.Lower_Level_Dtl_Tbl_Type,
  p_user_id                       IN           fnd_user.user_id%TYPE
  );

  PROCEDURE Get_Item_Cost
  (
  p_api_version                   IN          NUMBER,
  p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN          VARCHAR2 := FND_API.G_FALSE,
  x_return_status                 OUT NOCOPY  VARCHAR2,
  x_msg_count                     OUT NOCOPY  NUMBER,
  x_msg_data                      OUT NOCOPY  VARCHAR2,
  p_header_rec                    IN          GMF_ItemCost_PUB.Header_Rec_Type,
  x_this_level_dtl_tbl            OUT NOCOPY  GMF_ItemCost_PUB.This_Level_Dtl_Tbl_Type,
  x_lower_level_dtl_Tbl           OUT NOCOPY  GMF_ItemCost_PUB.Lower_Level_Dtl_Tbl_Type
  );

END GMF_ITEMCOST_PVT;

 

/
