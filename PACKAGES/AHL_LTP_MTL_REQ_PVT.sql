--------------------------------------------------------
--  DDL for Package AHL_LTP_MTL_REQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_MTL_REQ_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVLMRS.pls 115.1 2003/12/02 19:30:56 jaramana noship $ */

---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
TYPE Route_Mtl_Req_Rec_Type IS RECORD (
        ROUTE_OPERATION_ID      NUMBER,
        INVENTORY_ITEM_ID       NUMBER,
        INV_MASTER_ORG_ID       NUMBER,
        ITEM_GROUP_ID           NUMBER,
        QUANTITY                NUMBER,
        UOM_CODE                VARCHAR2(3),
        RT_OPER_MATERIAL_ID     NUMBER,
        POSITION_PATH_ID        NUMBER,
        RELATIONSHIP_ID         NUMBER,
        ITEM_COMP_DETAIL_ID     NUMBER
        );


----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE Route_Mtl_Req_Tbl_Type IS TABLE OF Route_Mtl_Req_Rec_Type INDEX BY BINARY_INTEGER;


------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Get_Route_Mtl_Req
--  Type              : Private
--  Function          : Private API to get the Material requirements for a Route.
--                      For FORECAST request type, it aggregates requirements at the
--                      route level (across operations), and gets the highest priority item
--                      ignoring the inventory org. Also, a disposition list requirement is
--                      considered for FORECAST only if the REPLACE_PERCENT = 100%.
--                      For PLANNED, no aggregation is done, NO specific item is obtained
--                      within an item group and the REPLACE_PERCENT is not considered.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Get_Route_Mtl_Req Parameters:
--      p_route_id                      IN      NUMBER       Not Required only if p_mr_route_id is not null
--         The Id of Route for which to determine the material requirements
--      p_mr_route_id                   IN      NUMBER       Not Required only if p_route_id is not null
--         The Id of MR Route for which to determine the material requirements
--      p_item_instance_id              IN      NUMBER       Required
--         The Id of Instance for which to plan the material requirements
--      p_requirement_date              IN      DATE         Not Required
--         The date when the materials are required. If provided, the positions of Master Configs
--         (for position path based disposition list requirement) are validated against this date.
--      p_request_type                  IN      VARCHAR2     Required
--         Should be either 'FORECAST' or 'PLANNED'
--      x_route_mtl_req_tbl             OUT     AHL_LTP_MTL_REQ_PVT.Route_Mtl_Req_Tbl  Required
--         The Table of records containing the material requirements for the route
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Get_Route_Mtl_Req
(
   p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
   p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   x_return_status         OUT  NOCOPY   VARCHAR2,
   x_msg_count             OUT  NOCOPY   NUMBER,
   x_msg_data              OUT  NOCOPY   VARCHAR2,
   p_route_id              IN            NUMBER,
   p_mr_route_id           IN            NUMBER,
   p_item_instance_id      IN            NUMBER,
   p_requirement_date      IN            DATE      := null,
   p_request_type          IN            VARCHAR2,
   x_route_mtl_req_tbl     OUT  NOCOPY   AHL_LTP_MTL_REQ_PVT.Route_Mtl_Req_Tbl_Type
);

-- Start of Comments --
--  Function name     : Get_Primary_UOM_Qty
--  Type              : Private
--  Function          : Private helper function to convert a quantity of an item from one
--                      UOM to the Primary UOM. The inputs are the item id, the quantity
--                      and the source UOM. The output is the quantity in the primary uom.
--  Pre-reqs    :
--  Parameters  :
--
--
--  Get_Primary_UOM_Qty Parameters:
--      p_inventory_item_id             IN      NUMBER       Required
--         The Id of Inventory item. If this is null, this function returns null.
--      p_source_uom_code               IN      VARCHAR2     Required
--         The code of the UOM in which the quantity is currently mentioned.
--         If this is null, this function returns null.
--      p_quantity                      IN      NUMBER       Required
--         The quantity of the item in the indicated UOM.
--         If this is null, this function returns null.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

FUNCTION Get_Primary_UOM_Qty
(
   p_inventory_item_id     IN  NUMBER,
   p_source_uom_code       IN  VARCHAR2,
   p_quantity              IN  NUMBER
) RETURN NUMBER;

-- Start of Comments --
--  Function name     : Get_Primary_UOM
--  Type              : Private
--  Function          : Private helper function to get the Primary UOM of an item
--                      The inputs are the item id and the inventory org id.
--  Pre-reqs    :
--  Parameters  :
--
--
--  Get_Primary_UOM Parameters:
--      p_inventory_item_id             IN      NUMBER       Required
--         The Id of Inventory item. If this is null, this function returns null.
--      p_inventory_org_id              IN      NUMBER       Required
--         The inventory org id of the item. If this is null, this function returns null.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

FUNCTION Get_Primary_UOM
(
   p_inventory_item_id     IN  NUMBER,
   p_inventory_org_id      IN  NUMBER
) RETURN VARCHAR2;

End AHL_LTP_MTL_REQ_PVT;

 

/
