--------------------------------------------------------
--  DDL for Package AHL_UC_UTILIZATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_UTILIZATION_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUCUS.pls 115.3 2004/01/27 03:03:03 jeli noship $ */

-------------------------------------------------
-- Define Record Type for Utilization Details. --
-------------------------------------------------
TYPE utilization_rec_type IS RECORD (
      ORGANIZATION_CODE	          VARCHAR2(3),
      ITEM_NUMBER                 VARCHAR2(2000),
      ORGANIZATION_ID             NUMBER,
      INVENTORY_ITEM_ID           NUMBER,
      SERIAL_NUMBER               VARCHAR2(30),
      CSI_ITEM_INSTANCE_ID        NUMBER,
      CSI_ITEM_INSTANCE_NUMBER    VARCHAR2(30),
      UOM_CODE		          VARCHAR2(3),
      RULE_CODE	                  VARCHAR2(30),
      RULE_MEANING                VARCHAR2(80),
      READING_VALUE               NUMBER,
      READING_DATE                DATE,
      COUNTER_NAME                VARCHAR2(30),
      COUNTER_ID                  NUMBER,
      CASCADE_FLAG                VARCHAR2(1) := 'N',
      DELTA_FLAG                  VARCHAR2(1) := 'N'
);

--G_MISS_Utilization_Rec   Utilization_Rec_Type;

----------------------------------------------
-- Define Table Types for record structures --
----------------------------------------------
TYPE utilization_tbl_type IS TABLE OF utilization_rec_type INDEX BY BINARY_INTEGER;

-----------------------------------------
-- Declare Procedure for Utilization  --
-----------------------------------------

PROCEDURE Update_Utilization(p_api_version       IN          NUMBER,
                             p_init_msg_list     IN          VARCHAR2  := FND_API.G_FALSE,
                             p_commit            IN          VARCHAR2  := FND_API.G_FALSE,
                             p_validation_level  IN          NUMBER    := FND_API.G_VALID_LEVEL_FULL,
                             p_Utilization_tbl   IN          AHL_UC_Utilization_PVT.utilization_tbl_type,
                             x_return_status     OUT  NOCOPY VARCHAR2,
                             x_msg_count         OUT  NOCOPY NUMBER,
                             x_msg_data          OUT  NOCOPY VARCHAR2);
-- Start of Comments --
--  Procedure name    : Update_Utilization
--  Type        : Private
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
--        1.  COUNTER_ID
--        2.  COUNTER_NAME
--        3.  UOM_CODE
--
--      Reading_Value                 IN   Required.
--      This will be the value of the counter reading.
--
--      cascade_flag    -- Can take values Y and N. Y indicates that the counter updates will cascade down the hierarchy
--                      beginning at the item number passed. Ift its value is N then only the item counter will be updated.
--      delta_flag      -- Can take values Y and N. Y indicates that the counter reading values refer to the delta and the
--                      N means the reading value is current value
--
-- NOTES
--   1. p_reading_value can be delta reading or net_reading depending on delta_flag. And the delta reading
--      can either be positive(ascending counter) or negative(descending counter). The net_reading can be
--      greater or less than its current reading value.
--   2. For parameters counter_id, counter_name and UOM_code, one and only one can be provided each time.
--   3. If counter_id is provided, then just update the specific counter_id, p_cascade_flag doesn't apply
--      at all.
--   4. If counter_name is provided, then if the counter doesn't exist for the start instance, and reading
--      value is net reading then raise error and stop, but if the reading_value is delta reading and cascade_flag = 'Y',
--      then get all of the highest component instances of the start instance which have the counter associated but all their
--      ancestors don't. Loop through all of these component instances and the specific counter.
--   5. If UOM_code is provided, then if delta_flag='Y', then get all of the distinct counters which associated with the start
--      instance and all of its component instance, otherwise just get all of the distinct counters which associated with the
--      the start instance only. Then loop through these counters like the above step.
-- End of Comments --

END AHL_UC_Utilization_PVT;

 

/
