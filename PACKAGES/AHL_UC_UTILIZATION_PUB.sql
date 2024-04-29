--------------------------------------------------------
--  DDL for Package AHL_UC_UTILIZATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_UTILIZATION_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPUCUS.pls 120.0 2005/05/26 00:16:08 appldev noship $ */
/*#
 * This package provides the APIs for updating the Utilization on a Unit Configuration.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Unit Configuration Utilization
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_UNIT_CONFIG
 */



-----------------------------------------
-- Define Procedure for Utilization  --
-----------------------------------------
/*#
 * This API is used to update the Utilization based on the counter  rules
 * defined in the Master Configuration node. The update is done based on
 * the details of an item/counter id/counter name,uom_code.
 * Cascades the updates down to all children if the p_cascade_flag is set to 'Y'.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_Utilization_tbl Table of the type AHL_UC_Utilization_PVT.Utilization_Tbl_Type
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Unit Utilization
 */
PROCEDURE Update_Utilization(p_api_version       IN            NUMBER,
                             p_init_msg_list     IN            VARCHAR2  := FND_API.G_FALSE,
                             p_commit            IN            VARCHAR2  := FND_API.G_FALSE,
                             p_validation_level  IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
                             p_Utilization_tbl   IN            AHL_UC_Utilization_PVT.Utilization_Tbl_Type,
                             x_return_status     OUT  NOCOPY   VARCHAR2,
                             x_msg_count         OUT  NOCOPY   NUMBER,
                             x_msg_data          OUT  NOCOPY   VARCHAR2 );


-- Start of Comments --
--  Procedure name    : Update_Utilization
--  Type        : Public
--  Function    : Updates the utilization based on the counter rules defined in the master configuration
--                given the details of an item/counter id/counter name/uom_code.
--                Casacades the updates down to all the children if the p_cascade_flag is set to 'Y'.
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--    p_api_version                   IN      NUMBER                Required
--    p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--    p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--    p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--    x_return_status                 OUT     VARCHAR2               Required
--    x_msg_count                     OUT     NUMBER                 Required
--    x_msg_data                      OUT     VARCHAR2               Required
--
--  Update_Utilization Parameters:
--
--    p_Utilization_tbl                IN      Required.
--      For each record, at any given time only one of the following combinations is valid to identify the
--      item instance to be updated:
--        1.  Organization id and Inventory_item_id    AND  Serial Number.
--            This information will identify the part number and serial number of a configuration.
--        2.  Counter ID -- if this is passed a specific counter ONLY will be updated irrespective of the value
--            of p_cascade_flag.
--        3.  CSI_ITEM_INSTANCE_ID -- if this is passed, then this item instance and items down the hierarchy (depends on
--            the value p_cascade_flag) will be updated.
--      At any given time only one of the following combinations is valid to identify the type of item counters to be
--      updated:
--        1.  UOM_CODE
--        2.  COUNTER_NAME
--
--      Reading_Value                 IN   Required.
--      This will be the value of the counter reading.
--
--      cascade_flag    -- Can take values Y and N. Y indicates that the counter updates will cascade down the hierarchy
--                      beginning at the item number passed. Ift its value is N then only the item counter will be updated.
--

-- End of Comments --

END AHL_UC_Utilization_PUB;

 

/
