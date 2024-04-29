--------------------------------------------------------
--  DDL for Package AHL_OSP_SERV_ITEM_RELS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_SERV_ITEM_RELS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVOSRS.pls 120.0 2005/07/06 15:53:18 jeli noship $ */
/*#
 * This package Contains Record types and public procedures to process shipment headers, and lines that are related to OSP Orders.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Process OSP Inv Itm Service Itm Relations
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_OSP_ORDER
 */

---------------------------------
-- Define Record Type for Node --
---------------------------------

TYPE Inv_Serv_Item_Rels_Rec_Type IS RECORD
(   inv_ser_item_rel_id     NUMBER
,   obj_ver_num             NUMBER
,   inv_item_id             NUMBER
,   inv_item_name           VARCHAR2(240)
,   inv_org_id              NUMBER
,   inv_org_name            VARCHAR2(240)
,   service_item_id         NUMBER
,   service_item_name       VARCHAR2(240)
,   rank                    NUMBER
,   active_start_date       DATE
,   active_end_date         DATE
,   for_all_org_flag        VARCHAR(1) := 'N'  -- possible values Y,N
,   operation_flag          VARCHAR2(1) -- possible values C,U,D
);


------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : PROCESS_SERV_ITM_RELS
--  Type              : Public
--  Function          : For creating/updating relationship between Inv Item and Service Item.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY     VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY     NUMBER               Required
--      x_msg_data                      OUT NOCOPY     VARCHAR2             Required
--
--  Process Order Parameters:
--       p_x_Inv_serv_item_rec          IN OUT NOCOPY  Inv_Serv_Item_Rels_Rec_Type    Required
--         All parameters for Inv Item Service Item relationship
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
/*#
 * This procedure is used to process a Shipment order related to an OSP Order.
 * @param p_api_version API Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module_type Module type of the caller
 * @param p_x_Inv_serv_item_rec Contains the attributes of the Shipment header, of type AHL_OSP_SHIPMENT_PUB.Ship_Header_Rec_Type
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Inv Item Service Item Relations
 */
PROCEDURE PROCESS_SERV_ITM_RELS (
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN        VARCHAR2  := NULL,
    p_x_Inv_serv_item_rec   IN OUT NOCOPY   AHL_OSP_SERV_ITEM_RELS_PVT.Inv_Serv_Item_Rels_Rec_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2);




End AHL_OSP_SERV_ITEM_RELS_PVT;

 

/
