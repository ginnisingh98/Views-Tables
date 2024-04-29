--------------------------------------------------------
--  DDL for Package INV_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVITMS.pls 120.1.12010000.1 2008/07/24 01:52:01 appldev ship $ */

-- =============================================================================
--                                  Global types
-- =============================================================================

-- =============================================================================
--                         Global variables and constants
-- =============================================================================

-- =============================================================================
--                                Procedure specs
-- =============================================================================

/*------------------------------ Lock_Org_Items ------------------------------*/

PROCEDURE Lock_Org_Items
(
    p_Item_ID         IN   NUMBER
,   p_Org_ID          IN   NUMBER
,   p_lock_Master     IN   VARCHAR2   :=  FND_API.g_TRUE
,   p_lock_Orgs       IN   VARCHAR2   :=  FND_API.g_FALSE
,   x_return_status   OUT  NOCOPY VARCHAR2
);


/*----------------------------- Update_Org_Items -----------------------------*/

PROCEDURE Update_Org_Items
(
    p_init_msg_list        IN   VARCHAR2       :=  FND_API.g_FALSE
,   p_commit               IN   VARCHAR2       :=  FND_API.g_FALSE
,   p_lock_rows            IN   VARCHAR2       :=  FND_API.g_TRUE
,   p_validation_level     IN   NUMBER         :=  FND_API.g_VALID_LEVEL_FULL
,   p_Item_rec             IN   INV_Item_API.Item_rec_type
,   p_update_changes_only  IN   VARCHAR2       :=  FND_API.g_FALSE
,   p_validate_Master      IN   VARCHAR2       :=  FND_API.g_TRUE
,   x_return_status        OUT  NOCOPY VARCHAR2
,   x_msg_count            OUT  NOCOPY NUMBER
,   x_msg_data             OUT  NOCOPY VARCHAR2
);


/*------------------------------- Get_Org_Item -------------------------------*/

PROCEDURE Get_Org_Item
(
    p_init_msg_list    IN   VARCHAR2       :=  FND_API.g_FALSE
,   p_Item_ID          IN   NUMBER
,   p_Org_ID           IN   NUMBER
,   p_Language         IN   VARCHAR2       :=  FND_API.g_MISS_CHAR
,   x_Item_rec         OUT  NOCOPY  INV_Item_API.Item_rec_type
,   x_return_status    OUT  NOCOPY VARCHAR2
,   x_msg_count        OUT  NOCOPY NUMBER
,   x_msg_data         OUT  NOCOPY VARCHAR2
);


/*------------------------------ Validate_Item -------------------------------*/

-- Item record validation is currently performed within Update_Org_Items.

/*
PROCEDURE Validate_Item
(
    p_validation_level  IN   NUMBER         :=  FND_API.g_VALID_LEVEL_FULL
,   p_Item_rec          IN   INV_Item_API.Item_rec_type
,   x_return_status     OUT  VARCHAR2
,   x_msg_count         OUT  NUMBER
,   x_msg_data          OUT  VARCHAR2
);
*/

PROCEDURE Check_Item_Number (
 P_Segment_Rec            IN     INV_ITEM_API.Item_rec_type
,P_Item_Id                IN OUT NOCOPY MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
,P_Description            IN OUT NOCOPY MTL_SYSTEM_ITEMS.DESCRIPTION%TYPE
,P_unit_of_measure        IN OUT NOCOPY MTL_SYSTEM_ITEMS.PRIMARY_UNIT_OF_MEASURE%TYPE
,P_Item_Catalog_Group_Id  IN OUT NOCOPY MTL_SYSTEM_ITEMS.ITEM_CATALOG_GROUP_ID%TYPE
);

PROCEDURE Create_Item(
 P_Item_Rec                 IN     INV_ITEM_API.Item_rec_type
,P_Item_Category_Struct_Id  IN     NUMBER
,P_Inv_Install              IN     NUMBER
,P_Master_Org_Id            IN     MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
,P_Category_Set_Id          IN     NUMBER
,P_Item_Category_Id         IN     NUMBER
,P_Event                    IN     VARCHAR2 DEFAULT 'INSERT'
,x_row_Id                   OUT    NOCOPY ROWID
,P_Default_Move_Order_Sub_Inv IN VARCHAR2 -- Item Transaction Defaults for 11.5.9
,P_Default_Receiving_Sub_Inv  IN VARCHAR2
,P_Default_Shipping_Sub_Inv   IN VARCHAR2
);

PROCEDURE Update_Item(
 P_Item_Rec                 IN  INV_ITEM_API.Item_rec_type
,P_Item_Category_Struct_Id  IN  NUMBER
,P_Inv_Install              IN  NUMBER
,P_Master_Org_Id            IN  MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
,P_Category_Set_Id          IN  NUMBER
,P_Item_Category_Id         IN  NUMBER
,P_Mode                     IN  VARCHAR2
,P_Updateble_Item           IN  VARCHAR2
,P_Cost_Txn                 IN  VARCHAR2
,P_Item_Cost_Details        IN  VARCHAR2
,P_Inv_Item_status_old      IN  MTL_SYSTEM_ITEMS_FVL.INVENTORY_ITEM_STATUS_CODE%TYPE
,P_Default_Move_Order_Sub_Inv IN VARCHAR2 -- Item Transaction Defaults for 11.5.9
,P_Default_Receiving_Sub_Inv  IN VARCHAR2
,P_Default_Shipping_Sub_Inv   IN VARCHAR2
);

PROCEDURE Lock_Item( P_Item_Rec  IN  INV_ITEM_API.Item_rec_type);

PROCEDURE DELETE_ROW;

PROCEDURE UPDATE_NLS_TO_ORG(
   X_INVENTORY_ITEM_ID IN VARCHAR2,
   X_ORGANIZATION_ID   IN VARCHAR2,
   X_LANGUAGE          IN VARCHAR2,
   X_DESCRIPTION       IN VARCHAR2,
   X_LONG_DESCRIPTION  IN VARCHAR2);

PROCEDURE ADD_LANGUAGE;

--Sync iM index after item creation,updation and org assignment.
PROCEDURE SYNC_IM_INDEX;

-- Added as part of Bug Fix 3623450
PROCEDURE Check_Master_Record_Locked( P_Item_Rec  IN  INV_ITEM_API.Item_rec_type);

--Enabled in spec for bug:3899614
PROCEDURE Delete_Cost_Details(
 P_Item_Id             IN MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE
,P_Org_Id              IN MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE
,P_Asset_Flag          IN MTL_SYSTEM_ITEMS_B.INVENTORY_ASSET_FLAG%TYPE
,P_Cost_Txn            IN NUMBER
,P_Last_Updated_By     IN MTL_SYSTEM_ITEMS_B.LAST_UPDATED_BY%TYPE
,P_Last_Updated_Login  IN MTL_SYSTEM_ITEMS_B.LAST_UPDATE_LOGIN%TYPE);


FUNCTION  Get_Is_Master_Attr_Modified RETURN VARCHAR2;    --Business Event Related Changes 5236170


PROCEDURE Set_Is_Master_Attr_Modified(p_is_master_attr_modified VARCHAR2); --Business Event Related Changes 5236170


END INV_ITEM_PVT;

/
