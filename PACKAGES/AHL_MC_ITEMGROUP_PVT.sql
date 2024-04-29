--------------------------------------------------------
--  DDL for Package AHL_MC_ITEMGROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_ITEMGROUP_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVIGPS.pls 115.11 2003/10/23 11:41:35 tamdas noship $ */


---------------------------------------
-- Define Record Type for Item Group --
---------------------------------------
TYPE Item_group_Rec_Type IS RECORD (
        ITEM_GROUP_ID           NUMBER         ,
        NAME                    VARCHAR2(80)   ,
        SOURCE_ITEM_GROUP_ID          NUMBER,
        STATUS_CODE             VARCHAR2(30),
        STATUS_MEANING           VARCHAR2(80)  ,
        TYPE_CODE            VARCHAR2(30),
        TYPE_MEANING     VARCHAR2(80)  ,
        DESCRIPTION             VARCHAR2(240)  ,
        OBJECT_VERSION_NUMBER   NUMBER         ,
        ATTRIBUTE_CATEGORY      VARCHAR2(30)   ,
        ATTRIBUTE1              VARCHAR2(150)   ,
        ATTRIBUTE2              VARCHAR2(150)   ,
        ATTRIBUTE3              VARCHAR2(150)   ,
        ATTRIBUTE4              VARCHAR2(150)   ,
        ATTRIBUTE5              VARCHAR2(150)   ,
        ATTRIBUTE6              VARCHAR2(150)   ,
        ATTRIBUTE7              VARCHAR2(150)   ,
        ATTRIBUTE8              VARCHAR2(150)   ,
        ATTRIBUTE9              VARCHAR2(150)   ,
        ATTRIBUTE10             VARCHAR2(150)   ,
        ATTRIBUTE11             VARCHAR2(150)   ,
        ATTRIBUTE12             VARCHAR2(150)   ,
        ATTRIBUTE13             VARCHAR2(150)   ,
        ATTRIBUTE14             VARCHAR2(150)   ,
        ATTRIBUTE15             VARCHAR2(150)   ,
        OPERATION_FLAG          VARCHAR2(1)
);



----------------------------------------------
-- Define Record Type for Item Associations --
----------------------------------------------
TYPE Item_Association_Rec_Type IS RECORD (
        ITEM_ASSOCIATION_ID             NUMBER        ,
        ITEM_GROUP_NAME                 VARCHAR2(80)  ,
        ITEM_GROUP_ID                   NUMBER        ,
	SOURCE_ITEM_ASSOCIATION_ID      NUMBER        ,
        INVENTORY_ORG_CODE              VARCHAR2(3)    ,
        INVENTORY_ORG_ID                NUMBER        ,
        INVENTORY_ITEM_NAME             VARCHAR2(2000) ,
        INVENTORY_ITEM_ID               NUMBER        ,
        REVISION                        VARCHAR2(3)   ,
        PRIORITY                        NUMBER        ,
        UOM_CODE                        VARCHAR2(3)   ,
        QUANTITY                        NUMBER        ,
        INTERCHANGE_TYPE_MEANING        VARCHAR2(80)  ,
        INTERCHANGE_TYPE_CODE           VARCHAR2(30)  ,
        INTERCHANGE_REASON      	VARCHAR2(2000),
        OBJECT_VERSION_NUMBER           NUMBER        ,
        ATTRIBUTE_CATEGORY              VARCHAR2(30)  ,
        ATTRIBUTE1                      VARCHAR2(150)  ,
        ATTRIBUTE2                      VARCHAR2(150)  ,
        ATTRIBUTE3                      VARCHAR2(150)  ,
        ATTRIBUTE4                      VARCHAR2(150)  ,
        ATTRIBUTE5                      VARCHAR2(150)  ,
        ATTRIBUTE6                      VARCHAR2(150)  ,
        ATTRIBUTE7                      VARCHAR2(150)  ,
        ATTRIBUTE8                      VARCHAR2(150)  ,
        ATTRIBUTE9                      VARCHAR2(150)  ,
        ATTRIBUTE10                     VARCHAR2(150)  ,
        ATTRIBUTE11                     VARCHAR2(150)  ,
        ATTRIBUTE12                     VARCHAR2(150) ,
        ATTRIBUTE13                     VARCHAR2(150) ,
        ATTRIBUTE14                     VARCHAR2(150) ,
        ATTRIBUTE15                     VARCHAR2(150) ,
        OPERATION_FLAG                  VARCHAR2(1)   := NULL
);

----------------------------------------------
-- Define Table Type for Item Associations --
----------------------------------------------

TYPE Item_Association_Tbl_Type IS TABLE OF Item_Association_Rec_Type INDEX BY BINARY_INTEGER;


-----------------------------------------
-- Declare Procedures for Item Groups  --
-----------------------------------------

-- Start of Comments --
--  Procedure name    : Create_Item_group
--  Type        : Private
--  Function    : Creates Item Group for Master Configuration in ahl_item_groups_b and TL tables.
--                Also creates item-group association in ahl_item_associations table.
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
--  Item Group Record :
--      Name                     Required.
--      Language                 Required.
--      Source Language          Required.
--  Item Associations Record :
--      Inventory_item_id        Required and present and trackable in mtl_system_items_b.
--      priority                 Required.
--      Operation_code           Required to be 'C'.(Create)
-- End of Comments --


PROCEDURE Create_Item_group (p_api_version       IN            NUMBER,
                             p_init_msg_list     IN            VARCHAR2  := FND_API.G_FALSE,
                             p_validation_level  IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
                             x_return_status     OUT NOCOPY            VARCHAR2,
                             x_msg_count         OUT NOCOPY            NUMBER,
                             x_msg_data          OUT NOCOPY            VARCHAR2,
                             p_x_item_group_rec  IN OUT NOCOPY AHL_MC_ITEMGROUP_PVT.Item_Group_Rec_Type,
                             p_x_items_tbl       IN OUT NOCOPY AHL_MC_ITEMGROUP_PVT.Item_Association_Tbl_Type
                             );



-- Start of Comments --
--  Procedure name    : Modify_Item_group
--  Type        : Private
--  Function    : Modifies Item Group for Master Configuration in ahl_item_groups_b and TL tables. Also creates/deletes/modifies item-group association in ahl_item_associations table.
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
--  Item Group Record :
--      Item_Group_id            Required.
--      Name                     Required.
--      Language                 Required.
--      Source Language          Required.
--  Item Associations Record :
--      Item_association_id      Required.
--      Item_group_id            Required.
--      Inventory_item_id        Required and present in mtl_system_items_b.
--      priority                 Required.
--      Operation_flag           Required. (C = Create, M = Modify, D = Delete).
-- End of Comments --

PROCEDURE Modify_Item_group (p_api_version       IN            NUMBER,
                             p_init_msg_list     IN            VARCHAR2  := FND_API.G_FALSE,
                             --p_commit            IN            VARCHAR2  := FND_API.G_FALSE,
                             p_validation_level  IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
                             x_return_status     OUT NOCOPY            VARCHAR2,
                             x_msg_count         OUT NOCOPY            NUMBER,
                             x_msg_data          OUT NOCOPY            VARCHAR2,
                             p_item_group_rec    IN            AHL_MC_ITEMGROUP_PVT.Item_Group_Rec_Type,
                             p_x_items_tbl       IN OUT NOCOPY AHL_MC_ITEMGROUP_PVT.Item_Association_Tbl_Type
                             );


-- Start of Comments --
--  Procedure name    : Remove_Item_group
--  Type        : Private
--  Function    : Deletes an Item Group from ahl_item_groups_b/ahl_item_groups_tl and all the associated
--                item associations from ahl_item_associations_b/TL tables.
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
--  Item Group Record :
--      Item_Group_id            Required.
--      Object_version_number    Required.
--      Name                     Optional.
--
-- End of Comments --

PROCEDURE Remove_Item_group (p_api_version       IN            NUMBER,
                             p_init_msg_list     IN            VARCHAR2  := FND_API.G_FALSE,
                             p_validation_level  IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
                             x_return_status     OUT NOCOPY            VARCHAR2,
                             x_msg_count         OUT NOCOPY            NUMBER,
                             x_msg_data          OUT NOCOPY            VARCHAR2,
                             p_item_group_rec    IN            AHL_MC_ITEMGROUP_PVT.Item_Group_Rec_Type
                             );



-- Start of Comments --
--  Procedure name    : Initiate_Itemgroup_Appr
--  Type        : Private
--  Function    : Intiates Approval Process for Item groups
--  Version     : Added for 115.10
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
--
--      Source_Item_Group_id            Required.
--      Object_version_number    Required.
--      Approval type            Required.
--
--
-- End of Comments --

PROCEDURE Initiate_Itemgroup_Appr (
    p_api_version         IN NUMBER,
    p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_DEFAULT             IN         VARCHAR2   := FND_API.G_FALSE,
    P_MODULE_TYPE         IN         VARCHAR2,
    x_return_status       OUT NOCOPY        VARCHAR2,
    x_msg_count           OUT NOCOPY        NUMBER,
    x_msg_data            OUT NOCOPY        VARCHAR2,
    p_source_item_group_id       IN NUMBER,
    p_object_version_number    IN NUMBER,
    P_Approval_Type IN         VARCHAR2
);


-- Start of Comments --
--  Procedure name    : Create_ItemGroup_Revision
--  Type        : Private
--  Function    : To  create a New Revision of Item group
--  Version     : Added for 115.10
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

--      Source_Item_Group_id            Required.
--      Object_version_number    Required.
--
--
-- End of Comments --


PROCEDURE Create_ItemGroup_Revision (
    p_api_version           IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN         VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN         NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_DEFAULT               IN         VARCHAR2  := FND_API.G_FALSE,
    P_MODULE_TYPE           IN         VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_source_ItemGroup_id   IN         NUMBER,
    p_object_version_number IN         NUMBER,
    x_ItemGroup_id          OUT NOCOPY NUMBER
);


-- Start of Comments --
--  Procedure name    : Approve_ItemGroups
--  Type        : Private
--  Function    : To  Approve Item group will be called by approval package
--  Version     : Added for 115.10
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

--      P_appr_status            Required.
--      Item_Group_id            Required.
--      Object_version_number    Required.
--
--
-- End of Comments --


PROCEDURE Approve_ItemGroups (
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
 p_ItemGroups_id             IN          NUMBER,
 p_object_version_number     IN          NUMBER);


PROCEDURE Modify_Position_Assos
(
	p_api_version           IN         	NUMBER,
	p_init_msg_list         IN         	VARCHAR2  := FND_API.G_FALSE,
	p_commit                IN         	VARCHAR2  := FND_API.G_FALSE,
	p_validation_level      IN         	NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	p_module_type           IN         	VARCHAR2,
	x_return_status         OUT 	NOCOPY  VARCHAR2,
	x_msg_count             OUT 	NOCOPY  NUMBER,
	x_msg_data              OUT 	NOCOPY  VARCHAR2,
	p_item_group_id		IN		NUMBER,
	p_object_version_number	IN		NUMBER,
	p_nodes_tbl		IN		AHL_MC_Node_PVT.Node_Tbl_Type
);

FUNCTION Fork_Or_Merge
(
	p_item_group_id in number
)
RETURN NUMBER;



End AHL_MC_ITEMGROUP_PVT;

 

/
