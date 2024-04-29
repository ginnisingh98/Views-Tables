--------------------------------------------------------
--  DDL for Package AHL_MC_ITEM_COMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_ITEM_COMP_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVICXS.pls 115.0 2003/08/05 16:33:57 sjayacha noship $ */

--The Header_Rec_Type record

TYPE Header_Rec_Type IS RECORD (
	ITEM_COMPOSITION_ID  	     NUMBER,
	INVENTORY_ITEM_ID  	     NUMBER,
	INVENTORY_ITEM_NAME          VARCHAR2(2000),
	INVENTORY_ORG_ID             NUMBER,
	INVENTORY_ORG_CODE           VARCHAR2(3)    ,
	INVENTORY_MASTER_ORG_ID      NUMBER,
	DRAFT_FLAG 		     VARCHAR2(1),
	STATUS_CODE 		     VARCHAR2(30),
	EFFECTIVE_END_DATE 	     DATE,
	OBJECT_VERSION_NUMBER	     NUMBER := 1,
	ATTRIBUTE_CATEGORY 	     VARCHAR2 (30),
	ATTRIBUTE1              VARCHAR2 (150),
	ATTRIBUTE2              VARCHAR2 (150),
	ATTRIBUTE3              VARCHAR2 (150),
	ATTRIBUTE4              VARCHAR2 (150),
	ATTRIBUTE5              VARCHAR2 (150),
	ATTRIBUTE6              VARCHAR2 (150),
	ATTRIBUTE7              VARCHAR2 (150),
	ATTRIBUTE8              VARCHAR2 (150),
	ATTRIBUTE9              VARCHAR2 (150),
	ATTRIBUTE10             VARCHAR2 (150),
	ATTRIBUTE11             VARCHAR2 (150),
	ATTRIBUTE12             VARCHAR2 (150),
	ATTRIBUTE13             VARCHAR2 (150),
	ATTRIBUTE14             VARCHAR2 (150),
	ATTRIBUTE15             VARCHAR2 (150),
	OPERATION_FLAG		  VARCHAR2(1) := NULL
);

--The Detail_Rec_Type record

TYPE Detail_Rec_Type IS RECORD (
	ITEM_COMP_DETAIL_ID  	 NUMBER,
	ITEM_COMPOSITION_ID      NUMBER,
	ITEM_GROUP_ID  	         NUMBER,
	ITEM_GROUP_NAME          VARCHAR2(80),
	INVENTORY_ITEM_ID  	 NUMBER,
	INVENTORY_ITEM_NAME      VARCHAR2(2000),
	INVENTORY_ORG_ID             NUMBER,
	INVENTORY_ORG_CODE       VARCHAR2(3)    ,
	INVENTORY_MASTER_ORG_ID  NUMBER,
	UOM_CODE		 VARCHAR2(30),
	QUANTITY  		 NUMBER,
	EFFECTIVE_END_DATE 	 DATE,
	LINK_COMP_DETL_ID  	 NUMBER,
	OBJECT_VERSION_NUMBER	 NUMBER := 1,
	ATTRIBUTE_CATEGORY 	 VARCHAR2 (30),
	ATTRIBUTE1              VARCHAR2 (150),
	ATTRIBUTE2              VARCHAR2 (150),
	ATTRIBUTE3              VARCHAR2 (150),
	ATTRIBUTE4              VARCHAR2 (150),
	ATTRIBUTE5              VARCHAR2 (150),
	ATTRIBUTE6              VARCHAR2 (150),
	ATTRIBUTE7              VARCHAR2 (150),
	ATTRIBUTE8              VARCHAR2 (150),
	ATTRIBUTE9              VARCHAR2 (150),
	ATTRIBUTE10             VARCHAR2 (150),
	ATTRIBUTE11             VARCHAR2 (150),
	ATTRIBUTE12             VARCHAR2 (150),
	ATTRIBUTE13             VARCHAR2 (150),
	ATTRIBUTE14             VARCHAR2 (150),
	ATTRIBUTE15             VARCHAR2 (150),
	OPERATION_FLAG		  VARCHAR2(1) := NULL
);

TYPE Det_Tbl_Type is TABLE of Detail_Rec_Type index by BINARY_INTEGER;

-----------------------------------------
-- Declare Procedures for Item Composition  --
-----------------------------------------

-- Start of Comments --
--  Procedure name    : Create_Item_Composition
--  Type        : Private
--  Function    : Creates Item Composition for Trackable Items in ahl_item_compositions.
--                Also creates item-group and Non-Trackable Item  association in ahl_comp_details table.
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--  Item Header Composition Record :
--	inventory_item_id        required.
--	inventory_item_name      required.
--	inventory_org_id         required.
--	inventory_org_code       required.
--      operation_flag           required to be 'C'.(Create)
--  Item Associations Record :
--	item_group_id  	         Required. ( If inventory_item_id Non Trackable Item is NUll)
--	item_group_name          Required.
--	inventory_item_id  	 Required. ( If item group is NUll) Item Should be non trackable.
--	inventory_item_name      Required.
--	inventory_org_id         Required.
--	inventory_org_code       Required.
--      operation_flag           Required to be 'C'.(Create)
-- End of Comments --


PROCEDURE Create_Item_Composition(
	p_api_version         IN NUMBER,
	p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
	p_commit              IN VARCHAR2  := FND_API.G_FALSE,
	p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status       OUT NOCOPY        VARCHAR2,
	x_msg_count           OUT NOCOPY        NUMBER,
	x_msg_data            OUT NOCOPY        VARCHAR2,
	p_x_ic_header_rec     IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Header_Rec_Type,
	p_x_det_tbl           IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Det_Tbl_Type
);

-----------------------------------------
-- Declare Procedures for Item Composition  --
-----------------------------------------

-- Start of Comments --
--  Procedure name    : Modify_Item_Composition
--  Type        : Private
--  Function    : Modifies Item Composition for Trackable Items in ahl_item_compositions.
--                Also creates,modifies item-group and Non-Trackable Item  association in ahl_comp_details table.
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--  Item Header Composition Record :
--	inventory_item_id        required.
--	inventory_item_name      required.
--	inventory_org_id         required.
--	inventory_org_code       required.
--      operation_flag           required to be 'M'.(Create)
--  Item Associations Record :
--	item_group_id  	         Required. ( If inventory_item_id Non Trackable Item is NUll)
--	item_group_name          Required.
--	inventory_item_id  	 Required. ( If item group is NUll) Item Should be non trackable.
--	inventory_item_name      Required.
--	inventory_org_id         Required.
--	inventory_org_code       Required.
--      operation_flag           Required to be 'C'.(Create)
-- End of Comments --

PROCEDURE Modify_Item_Composition(
	p_api_version         IN NUMBER,
	p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
	p_commit              IN VARCHAR2  := FND_API.G_FALSE,
	p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status       OUT NOCOPY        VARCHAR2,
	x_msg_count           OUT NOCOPY        NUMBER,
	x_msg_data            OUT NOCOPY        VARCHAR2,
	p_x_ic_header_rec     IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Header_Rec_Type,
	p_x_det_tbl           IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Det_Tbl_Type
);
-----------------------------------------
-- Declare Procedures for Item Composition  --
-----------------------------------------

-- Start of Comments --
--  Procedure name    : Delete_Item_Composition
--  Type        : Private
--  Function    : Deletes Item Composition for Trackable Items in ahl_item_compositions.
--                Also deletes association in ahl_comp_details table.
--                Incase of Complete status Item Composition it Expires it.
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--  Item Header Composition Record :
--       p_item_composition_ID  Required
--       p_object_version_number Required.
-- End of Comments --

PROCEDURE Delete_Item_Composition (
	p_api_version         IN NUMBER,
	p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
	p_commit              IN VARCHAR2  := FND_API.G_FALSE,
	p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status       OUT NOCOPY        VARCHAR2,
	x_msg_count           OUT NOCOPY        NUMBER,
	x_msg_data            OUT NOCOPY        VARCHAR2,
	p_item_composition_ID IN NUMBER ,
	p_object_version_number IN NUMBER

);

-----------------------------------------
-- Declare Procedures for Item Composition  --
-----------------------------------------

-- Start of Comments --
--  Procedure name    : Reopen_Item_Composition
--  Type        : Private
--  Function    : Re-Open'ss Item Composition for Trackable Items in ahl_item_compositions.
--
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--  Item Header Composition Record :
--       p_item_composition_ID  Required
--       p_object_version_number Required.
-- End of Comments --


PROCEDURE Reopen_Item_Composition (
	p_api_version         IN NUMBER,
	p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
	p_commit              IN VARCHAR2  := FND_API.G_FALSE,
	p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status       OUT NOCOPY        VARCHAR2,
	x_msg_count           OUT NOCOPY        NUMBER,
	x_msg_data            OUT NOCOPY        VARCHAR2,
	p_item_composition_ID IN NUMBER ,
	p_object_version_number IN NUMBER

);

-----------------------------------------
-- Declare Procedures for Item Composition  --
-----------------------------------------

-- Start of Comments --
--  Procedure name    : Create_Item_Comp_Revision
--  Type        : Private
--  Function    : Creates new revision of existing  Item Composition
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--  Item Header Composition Record :
--      IN Parameter
--       p_item_composition_ID  Required
--       p_object_version_number Required.
--      OUT Parameter
--       x_Item_comp_id
-- End of Comments --


PROCEDURE Create_Item_Comp_Revision (
    p_api_version           IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN         VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN         NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_DEFAULT               IN         VARCHAR2  := FND_API.G_FALSE,
    P_MODULE_TYPE           IN         VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_Item_comp_id   IN         NUMBER,
    p_object_version_number IN         NUMBER,
    x_Item_comp_id          OUT NOCOPY NUMBER
);
-----------------------------------------
-- Declare Procedures for Item Composition  --
-----------------------------------------

-- Start of Comments --
--  Procedure name    : Initiate_Item_Comp_Approval
--  Type        : Private
--  Function    : Initiate approval for Item Composition for Trackable Items
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--  Item Header Composition Record :
--      IN Parameter
--       p_item_composition_ID  Required
--       p_object_version_number Required.
--       p_approval_type Required.
-- End of Comments --


PROCEDURE Initiate_Item_Comp_Approval (
	p_api_version           IN NUMBER,
	p_init_msg_list         IN VARCHAR2  := FND_API.G_FALSE,
	p_commit                IN VARCHAR2  := FND_API.G_FALSE,
	p_validation_level      IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status         OUT NOCOPY        VARCHAR2,
	x_msg_count             OUT NOCOPY        NUMBER,
	x_msg_data              OUT NOCOPY        VARCHAR2,
	p_Item_Composition_id   IN NUMBER,
	p_object_version_number IN NUMBER,
        p_approval_type         IN         VARCHAR2
);
-----------------------------------------
-- Declare Procedures for Item Composition  --
-----------------------------------------

-- Start of Comments --
--  Procedure name    : Approve_Item_Composiiton
--  Type        : Private
--  Function    : To update the exitinf Item Composition with newly approved (revision of Item Compostiion)
--                Used by approval package.
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--  IN Parameter
-- 	p_Item_comp_id           Required.
-- 	p_object_version_number  Required.
-- End of Comments --



PROCEDURE Approve_Item_Composiiton (
 p_api_version               IN         NUMBER,
 p_init_msg_list             IN         VARCHAR2  := FND_API.G_FALSE,
 p_commit                    IN         VARCHAR2  := FND_API.G_FALSE,
 p_validation_level          IN         NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 P_DEFAULT                   IN         VARCHAR2  := FND_API.G_FALSE,
 P_MODULE_TYPE               IN         VARCHAR2,
 x_return_status             OUT NOCOPY  VARCHAR2,
 x_msg_count                 OUT NOCOPY  NUMBER,
 x_msg_data                  OUT NOCOPY  VARCHAR2,
 p_appr_status               IN          VARCHAR2,
 p_Item_comp_id             IN          NUMBER,
 p_object_version_number     IN          NUMBER);

End AHL_MC_ITEM_COMP_PVT;

 

/
