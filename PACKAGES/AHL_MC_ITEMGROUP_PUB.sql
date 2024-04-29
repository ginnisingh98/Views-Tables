--------------------------------------------------------
--  DDL for Package AHL_MC_ITEMGROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_ITEMGROUP_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPIGPS.pls 120.0 2005/05/26 01:00:15 appldev noship $ */
/*#
 * This is the public package that creates and modifies the Item groups and item-group associations for Master Configuration
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Item Group Association
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MASTER_CONFIG
 */


-----------------------------------------
-- Declare Procedures for Item Groups  --
-----------------------------------------
/*#
 * It Creates and Modifies Item groups and associated Items.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_FALSE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module_type whether 'API'or 'JSP', default value NULL
 * @param x_return_status Return status, Standard API parameter
 * @param x_msg_count Return message count,Standard API parameter
 * @param x_msg_data Return message data, Standard API parameter
 * @param p_x_item_group_rec Item Group record of type AHL_MC_ItemGroup_Pvt.Item_Group_Rec_Type
 * @param p_x_items_tbl Items table of type AHL_MC_ItemGroup_Pvt.Item_Association_Tbl_Type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Item Group
 */
PROCEDURE PROCESS_ITEM_GROUP (p_api_version      IN            NUMBER,
                             p_init_msg_list     IN            VARCHAR2  := FND_API.G_FALSE,
                             p_commit            IN            VARCHAR2  := FND_API.G_FALSE,
                             p_validation_level  IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
                             p_module_type       IN            VARCHAR2  := NULL,
                             x_return_status     OUT NOCOPY          VARCHAR2,
                             x_msg_count         OUT NOCOPY          NUMBER,
                             x_msg_data          OUT NOCOPY          VARCHAR2,
                             p_x_item_group_rec  IN OUT NOCOPY AHL_MC_ItemGroup_Pvt.Item_Group_Rec_Type,
                             p_x_items_tbl       IN OUT NOCOPY AHL_MC_ItemGroup_Pvt.Item_Association_Tbl_Type
                             );

-- Start of Comments --
--  Procedure name    : Process_Item_Group
--  Type        : Public
--  Function    : Creates,Modifies and Deletes Item Group for Master Configuration in ahl_item_groups_b and TL tables.
--                   Also Creates,Modifies and Deletes item-group association in ahl_item_associations_b/TL table.
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN      VARCHAR2     Default  NULL,
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--      This parameter indicates the front-end form interface. The default value is 'JSP'. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values based
--      on which the Id's are populated.
--  Item Group Record :
--      Name or item_group_id           Required.
--      operation_flag                  if record needs to be created (C) or modified (M) or deleted.(D)
--  Item Associations Record :
--      Inventory_item_id        Required and present and trackable in mtl_system_items_b.
--      priority                 Required.
--      Operation_code           Required to be 'C'.(Create) or 'M' (Update) or 'D' (Delete)
-- End of Comments --




End AHL_MC_ITEMGROUP_PUB;

 

/
