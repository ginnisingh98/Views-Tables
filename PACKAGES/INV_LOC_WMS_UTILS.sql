--------------------------------------------------------
--  DDL for Package INV_LOC_WMS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOC_WMS_UTILS" AUTHID CURRENT_USER AS
/* $Header: INVLCPYS.pls 120.0.12010000.4 2010/02/16 19:05:26 sfulzele ship $ */

--Return values for x_retcode(standard for concurrent programs)

RETCODE_SUCCESS         CONSTANT     VARCHAR2(1)  := '0';
RETCODE_WARNING         CONSTANT     VARCHAR2(1)  := '1';
RETCODE_ERROR           CONSTANT     VARCHAR2(1)  := '2';

-- This API returns the current and suggested volume, weight, and units capacity of a
-- given locator
PROCEDURE get_locator_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    x_location_maximum_units    OUT NOCOPY NUMBER,   -- max number of units that can be stored in locator
    x_location_current_units    OUT NOCOPY NUMBER,   -- current number of units in locator
    x_location_suggested_units  OUT NOCOPY NUMBER,   -- suggested number of units to be put into locator
    x_location_available_units  OUT NOCOPY NUMBER,   -- number of units that can still be put into locator
    x_location_weight_uom_code  OUT NOCOPY VARCHAR2, -- the locator's unit of measure for weight
    x_max_weight                OUT NOCOPY NUMBER,   -- max weight the locator can take
    x_current_weight            OUT NOCOPY NUMBER,   -- current weight in the locator
    x_suggested_weight          OUT NOCOPY NUMBER,   -- suggested weight to be put into locator
    x_available_weight          OUT NOCOPY NUMBER,   -- weight the locator can still take
    x_volume_uom_code           OUT NOCOPY VARCHAR2, -- the locator's unit of measure for volume
    x_max_cubic_area            OUT NOCOPY NUMBER,   -- max volume the locator can take
    x_current_cubic_area        OUT NOCOPY NUMBER,   -- current volume in the locator
    x_suggested_cubic_area      OUT NOCOPY NUMBER,   -- suggested volume to be put into locator
    x_available_cubic_area      OUT NOCOPY NUMBER,   -- volume the locator can still take
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER    -- identifier of locator
  );

-- This API only returns the current and suggested unit capacity of a
-- given locator
PROCEDURE get_locator_unit_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    x_location_maximum_units    OUT NOCOPY NUMBER,   -- max number of units that can be stored in locator
    x_location_current_units    OUT NOCOPY NUMBER,   -- current number of units in locator
    x_location_suggested_units  OUT NOCOPY NUMBER,   -- suggested number of units to be put into locator
    x_location_available_units  OUT NOCOPY NUMBER,   -- number of units that can still be put into locator
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER    -- identifier of locator
  );

-- This API only returns the current and suggested weight capacity of a
-- given locator
PROCEDURE get_locator_weight_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    x_location_weight_uom_code  OUT NOCOPY VARCHAR2, -- the locator's unit of measure for weight
    x_max_weight                OUT NOCOPY NUMBER,   -- max weight the locator can take
    x_current_weight            OUT NOCOPY NUMBER,   -- current weight in the locator
    x_suggested_weight          OUT NOCOPY NUMBER,   -- suggested weight to be put into locator
    x_available_weight          OUT NOCOPY NUMBER,   -- weight the locator can still take
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER    -- identifier of locator
    );

-- This API only returns the current and suggested volume capacity of a
-- given locator
PROCEDURE get_locator_volume_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    x_volume_uom_code           OUT NOCOPY VARCHAR2,   -- the locator's unit of measure for volume
    x_max_cubic_area            OUT NOCOPY NUMBER,   -- max volume the locator can take
    x_current_cubic_area        OUT NOCOPY NUMBER,   -- current volume in the locator
    x_suggested_cubic_area      OUT NOCOPY NUMBER,   -- suggested volume to be put into locator
    x_available_cubic_area      OUT NOCOPY NUMBER,   -- volume the locator can still take
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER    -- identifier of locator
    );


-- This API updates the current volume, weight and units capacity of a locator when items are
-- issued or received in the locator
PROCEDURE update_loc_current_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER,   -- identifier of locator
    p_inventory_item_id         IN         NUMBER,   -- identifier of item
    p_primary_uom_flag          IN         VARCHAR2, -- 'Y' - transaction was in item's primary UOM
                                                     -- 'N' - transaction was NOT in item's primary UOM
                                                     --       or the information is not known
    p_transaction_uom_code      IN         VARCHAR2, -- UOM of the transacted material that causes the
                                                     -- locator capacity to get updat d
    p_quantity                  IN         NUMBER,   -- transaction quantity in p_transaction_uom_code
    p_issue_flag                IN         VARCHAR2  -- 'Y' - Issue transaction
                                                     -- 'N' - Receipt transaction
  );

-- This API updates the current volume, weight and units capacity of a locator when items are
-- issued or received in the locator
-- It doesn't do an autonomous commit
PROCEDURE update_loc_curr_capacity_nauto
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER,   -- identifier of locator
    p_inventory_item_id         IN         NUMBER,   -- identifier of item
    p_primary_uom_flag          IN         VARCHAR2, -- 'Y' - transaction was in item's primary UOM
                                                     -- 'N' - transaction was NOT in item's primary UOM
                                                     --       or the information is not known
    p_transaction_uom_code      IN         VARCHAR2, -- UOM of the transacted material that causes the
                                                     -- locator capacity to get updat d
    p_quantity                  IN         NUMBER,   -- transaction quantity in p_transaction_uom_code
    p_issue_flag                IN         VARCHAR2  -- 'Y' - Issue transaction
                                                     -- 'N' - Receipt transaction
  );

-- This API updates the suggested volume, weight and units capacity of a locator when items are
-- received in the locator
-- all suggestions are receipt suggestions
PROCEDURE update_loc_suggested_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER,   -- identifier of locator
    p_inventory_item_id         IN         NUMBER,   -- identifier of item
    p_primary_uom_flag          IN         VARCHAR2, -- 'Y' - transaction was in item's primary UOM
                                                     -- 'N' - transaction was NOT in item's primary UOM
                                                     --       or the information is not known
    p_transaction_uom_code      IN         VARCHAR2, -- UOM of the transacted material that causes the
                                                     -- locator capacity to get updated
                                                     -- Note: can be NULL if p_primary_uom_flag = 'Y'
    p_quantity                  IN         NUMBER    -- transaction quantity in p_transaction_uom_code

  );

-- This API updates the suggested volume, weight and units capacity of a locator when
-- drop off locator is suggested.
-- THIS API DOES NOT UPDATE EMPTY FLAG OF THE LOCATOR.

PROCEDURE update_loc_sugg_cap_wo_empf
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER,   -- identifier of locator
    p_inventory_item_id         IN         NUMBER,   -- identifier of item
    p_primary_uom_flag          IN         VARCHAR2, -- 'Y' - transaction was in item's primary UOM
    -- 'N' - transaction was NOT in item's primary UOM
    --       or the information is not known
    p_transaction_uom_code      IN         VARCHAR2, -- UOM of the transacted material that causes the
    -- locator capacity to get updated
    -- Note: can be NULL if p_primary_uom_flag = 'Y'
    p_quantity                  IN         NUMBER    -- transaction quantity in p_transaction_uom_code

  );


-- This API updates the suggested volume, weight and units capacity of a locator when items are
-- received in the locator.
-- all suggestions are receipt suggestions
-- It doesn't do an autonomous commit.
PROCEDURE update_loc_sugg_capacity_nauto
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER,   -- identifier of locator
    p_inventory_item_id         IN         NUMBER,   -- identifier of item
    p_primary_uom_flag          IN         VARCHAR2, -- 'Y' - transaction was in item's primary UOM
                                                     -- 'N' - transaction was NOT in item's primary UOM
                                                     --       or the information is not known
    p_transaction_uom_code      IN         VARCHAR2, -- UOM of the transacted material that causes the
                                                     -- locator capacity to get updated
                                                     -- Note: can be NULL if p_primary_uom_flag = 'Y'
    p_quantity                  IN         NUMBER    -- transaction quantity in p_transaction_uom_code
  );

-- This API reverts the updates of the suggested  volume, weight and units capacity of a locator
-- when a receipt happens.
-- In other words, this API can be considered as issue suggestions.
PROCEDURE revert_loc_suggested_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER,   -- identifier of locator
    p_inventory_item_id         IN         NUMBER,   -- identifier of item
    p_primary_uom_flag          IN         VARCHAR2, -- 'Y' - transaction was in item's primary UOM
                                                     -- 'N' - transaction was NOT in item's primary UOM
                                                     --       or the information is not known
    p_transaction_uom_code      IN         VARCHAR2, -- UOM of the transacted material that causes the
                                                     -- locator capacity to get updated
                                                     -- Note: can be NULL if p_primary_uom_flag = 'Y'
    p_quantity                  IN         NUMBER,    -- transaction quantity in p_transaction_uom_code
    p_content_lpn_id            IN         NUMBER   DEFAULT NUlL --bug#9159019 FPing fix for #8944467
  );


-- This API reverts the updates of the suggested  volume, weight and units capacity of a locator
-- when a receipt happens.
-- In other words, this API can be considered as issue suggestions.
-- THIS API DOES NOT HAVE AUTONOMOUS COMMIT
PROCEDURE revert_loc_suggested_cap_nauto
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER,   -- identifier of locator
    p_inventory_item_id         IN         NUMBER,   -- identifier of item
    p_primary_uom_flag          IN         VARCHAR2, -- 'Y' - transaction was in item's primary UOM
                                                     -- 'N' - transaction was NOT in item's primary UOM
                                                     --       or the information is not known
    p_transaction_uom_code      IN         VARCHAR2, -- UOM of the transacted material that causes the
                                                     -- locator capacity to get updated
                                                     -- Note: can be NULL if p_primary_uom_flag = 'Y'
    p_quantity                  IN         NUMBER,    -- transaction quantity in p_transaction_uom_code
    p_content_lpn_id            IN         NUMBER   DEFAULT NUlL --bug#9159019 FPing fix for #8944467
  );

-- This is an upgrade script that updates the locator's capacity information corresponding to
-- each onhand quantity record
PROCEDURE locators_capacity_cleanup
  ( x_return_status             OUT NOCOPY VARCHAR2 -- return status (success/error/unexpected_error)
    ,x_msg_count                OUT NOCOPY NUMBER   -- number of messages in the message queue
    ,x_msg_data                 OUT NOCOPY VARCHAR2 -- message text when x_msg_count>0
    ,p_organization_id          IN         NUMBER
    ,p_mixed_flag               IN         VARCHAR2 DEFAULT NULL
    ,p_subinventory             IN         VARCHAR2 DEFAULT NULL
    ,p_locator_id               IN         NUMBER   DEFAULT NULL
  );

-- This procedure initiates the upgrade thru concurrent request

PROCEDURE launch_upgrade(
    x_errorbuf          OUT  NOCOPY VARCHAR2
    ,x_retcode          OUT  NOCOPY VARCHAR2
    ,p_organization_id  IN          NUMBER
    ,p_subinventory     IN          VARCHAR2 DEFAULT NULL
    ,p_mixed_items_flag IN          NUMBER DEFAULT NULL
    );

PROCEDURE print_message(dummy IN VARCHAR2 DEFAULT NULL);

-- This API updates the current volume, weight capacity of a locator considering the LPN's
-- weight and volume

-- bug#2876849. Added the two new parameters from org id and from loc id. These are needed
-- for a transfer transaction to decrement the capacity from the souce locator.
PROCEDURE update_lpn_loc_curr_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER,   -- identifier of locator
    p_inventory_item_id         IN         NUMBER,   -- identifier of item
    p_primary_uom_FLAG          IN         VARCHAR2, -- iF Y primary UOM
    p_transaction_uom_code      IN         VARCHAR2, -- UOM of the transacted material that causes the
                                                     -- locator capacity to get updated
    p_transaction_action_id	  IN         NUMBER,   -- transaction action id for pack,unpack,issue,receive,
                                                     -- transfer
    p_lpn_id                    IN         NUMBER,   -- lpn id
    p_transfer_lpn_id		     IN         NUMBER,   -- transfer_lpn_id
    p_content_lpn_id		        IN         NUMBER,   -- content_lpn_id
    p_quantity                  IN         NUMBER,   -- transaction quantity in p_transaction_uom_code
    p_container_item_id         IN         NUMBER DEFAULT NULL,
    p_cartonization_id          IN         NUMBER DEFAULT NULL,
    p_from_org_id               IN         NUMBER DEFAULT NULL,
    p_from_loc_id               IN         NUMBER DEFAULT NULL
  );

-- This API updates the current volume, weight capacity of a locator considering the LPN's
-- weight and volume .This does not do an autonomous commit

-- bug#2876849. Added the two new parameters from org id and from loc id. These are needed
-- for a transfer transaction to decrement the capacity from the souce locator.
PROCEDURE upd_lpn_loc_curr_cpty_nauto
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER,   -- identifier of locator
    p_inventory_item_id         IN         NUMBER,   -- identifier of item
    p_primary_uom_FLAG          IN         VARCHAR2, -- iF Y primary UOM
    p_transaction_uom_code      IN         VARCHAR2, -- UOM of the transacted material that causes the
                                                     -- locator capacity to get updated
    p_transaction_action_id	  IN         NUMBER,   -- transaction action id for pack,unpack,issue,receive,
                                                     -- transfer
    p_lpn_id                    IN         NUMBER,   -- lpn id
    p_transfer_lpn_id		     IN         NUMBER,   -- transfer_lpn_id
    p_content_lpn_id		        IN         NUMBER,   -- content_lpn_id
    p_quantity                  IN         NUMBER,   -- transaction quantity in p_transaction_uom_code
    p_container_item_id         IN         NUMBER DEFAULT NULL,
    p_cartonization_id          IN         NUMBER DEFAULT NULL,
    p_from_org_id               IN         NUMBER DEFAULT NULL,
    p_from_loc_id               IN         NUMBER DEFAULT NULL
  );
-- This is an upgrade script that updates the locator's capacity information considering the LPn's weight and volume
PROCEDURE lpn_loc_capacity_clean_up(x_return_status    OUT NOCOPY VARCHAR2 --return status
                                    ,x_msg_count       OUT NOCOPY NUMBER   --number of messages in message queue
                                    ,x_msg_data        OUT NOCOPY VARCHAR2 --message text when x_msg_count>0
                                    ,p_organization_id IN         NUMBER   -- identier for the organization
                                    ,p_mixed_flag      IN         VARCHAR2 DEFAULT NULL
                                    ) ;
--This API is used to fetch the attributes of the item which is used
-- in calculation of locator capacity updation considering the LPN's weight and volume

PROCEDURE item_attributes(
              x_return_status           OUT NOCOPY VARCHAR2,--return status
              x_msg_data                OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,  --Count of messages in the Message queue
              x_item_weight_uom_code    OUT NOCOPY VARCHAR2,--Item's weight UOM_code
              x_item_unit_weight        OUT NOCOPY NUMBER,  --Item's unit weight
              x_item_volume_uom_code    OUT NOCOPY VARCHAR2,--Item's Volume UOM_Code
              x_item_unit_volume        OUT NOCOPY NUMBER,  --Item's unit volume
              x_item_xacted_weight      OUT NOCOPY NUMBER,  --Transacted weight of item
              x_item_xacted_volume      OUT NOCOPY NUMBER,  --Transacted volume of item
              p_inventory_item_id       IN         NUMBER,  -- Identifier of Item
              p_transaction_uom_code    IN         VARCHAR2 default null,--UOM of the transacted material
              p_primary_uom_flag        IN         VARCHAR2 default null,--Y if Primary_UOM
              p_locator_weight_uom_code IN         VARCHAR2 default null,--Locator's weight_UOM_Code
              p_locator_volume_uom_code IN         VARCHAR2 default null,--Locator's Volume_UOM_Code
              p_quantity                IN         NUMBER   default null,--Transaction quantity
              p_organization_id         IN         NUMBER,  -- Identier of the Organization
              p_container_item          IN         VARCHAR2 DEFAULT 'N'--Flag which indicates the item passed
                                                                       -- is a container item.
                                                                       --Y if the item is a container item
                                                                       -- N if the item is not a container item
                      );

--This API is used to fetch the attributes of the LPN which is used
-- in calculation of locator capacity updation considering the LPN's weight and volume
PROCEDURE lpn_attributes (
           x_return_status             OUT NOCOPY VARCHAR2, -- Return status
           x_msg_data                  OUT NOCOPY VARCHAR2, --message text when x_msg_count>0
           x_msg_count                 OUT NOCOPY NUMBER,   -- Count iof message in the message queue
           x_gross_weight_uom_code     OUT NOCOPY VARCHAR2, --Gross_Weight_UOM_Code of the LPN
           x_content_volume_uom_code   OUT NOCOPY VARCHAR2, --Content_Volume_UOM_Code of the LPN
           x_gross_weight              OUT NOCOPY NUMBER,   --Gross Weight of the LPN
           x_content_volume            OUT NOCOPY NUMBER,   --Content_Volume of the LPN
           x_container_item_weight     OUT NOCOPY NUMBER,   -- Container item's weight (in terms of Gross_weight_UOM_code)
                                                            -- associated with the LPN
           x_container_item_vol        OUT NOCOPY NUMBER,   -- Container item Volume's (in terms of Content_Volume_UOM_code)
                                                            -- associated with the LPN
           x_lpn_exists_in_locator     OUT NOCOPY VARCHAR2, --Flag indicates if Transfer LPN exists in Locator.
                                                            -- Y if the Transfer LPN exists in locator.
                                                            -- N if the Transfer LPN does not exists in locator
           p_lpn_id                    IN NUMBER,           --Identifier of the LPN
           p_org_id                    IN NUMBER            --Identifier of the Organization
                        ) ;

--This API is used to calculate the Locator's Current_Cubic_Area which is used
-- in calculation of locator capacity updation considering the LPN's weight and volume

PROCEDURE cal_locator_current_volume(
                x_return_status               OUT NOCOPY VARCHAR2,--return status
                x_msg_data                    OUT NOCOPY VARCHAR2,--message text when x_msg_count>0
                x_msg_count                   OUT NOCOPY NUMBER,--number of messages in message queue
                x_locator_current_volume      OUT NOCOPY NUMBER,--locator's current_cubic_area
                p_trn_lpn_container_item_vol  IN NUMBER,--container item volume associated with transfer LPN
                p_trn_lpn_content_volume      IN NUMBER,--Content volume of the Transfer LPN
                p_cnt_lpn_container_item_vol  IN NUMBER,--container item volume associated with content LPN
                p_cnt_lpn_content_volume      IN NUMBER,--Content volume of the Content LPN
                p_lpn_container_item_vol      IN NUMBER,--container item volume associated with LPN
                p_lpn_content_volume          IN NUMBER,--Content volume of the LPN
                p_xacted_volume               IN NUMBER,-- Transacted volume
                p_locator_current_cubic_area  IN NUMBER,--locator's current_cubic_area
                p_transaction_action_id       IN NUMBER,-- transaction action id for pack,unpack,issue,receive,Transfer
                p_transfer_lpn_id             IN NUMBER,--Transfer_LPN_ID
                p_content_lpn_id              IN NUMBER,--Content LPN_ID
                p_lpn_id                      IN NUMBER,--LPN_ID
                p_trn_lpn_exists_in_loc       IN VARCHAR2--Flag indicates if Transfer LPN exists in Locator.
                                                         -- Y if the Transfer LPN exists in locator.
                                                         -- N if the Transfer LPN does not exists in locator
                                              );
-- This API updates the empty flag,Mixed_Items_Flag and the inventory_item_id column in MTL_ITEM_LOCATIONS table
-- No autonomous commit
PROCEDURE LOC_EMPTY_MIXED_FLAG(  X_RETURN_STATUS          OUT NOCOPY VARCHAR2
                                ,X_MSG_COUNT              OUT NOCOPY NUMBER
                                ,X_MSG_DATA               OUT NOCOPY VARCHAR2
                                ,P_ORGANIZATION_ID        IN  NUMBER
                                ,P_INVENTORY_LOCATION_ID  IN  NUMBER
                                ,P_INVENTORY_ITEM_ID      IN  NUMBER
                                ,P_TRANSACTION_ACTION_ID  IN  NUMBER
                                ,P_TRANSFER_ORGANIZATION  IN  NUMBER
                                ,P_TRANSFER_LOCATION_ID   IN  NUMBER
                                ,P_SOURCE                 IN  VARCHAR2 DEFAULT NULL
                                                 );
-- This API returns values for empty_flag,Mixed_Items_Flag and the inventory_item_id column in MTL_ITEM_LOCATIONS table
-- for issue transactions
procedure inv_loc_issues  (x_return_status     OUT NOCOPY VARCHAR2
                           ,X_MSG_COUNT        OUT NOCOPY NUMBER
                           ,X_MSG_DATA         OUT NOCOPY VARCHAR2
                           ,X_EMPTY_FLAG       OUT NOCOPY VARCHAR2
                           ,X_MIXED_FLAG       OUT NOCOPY VARCHAR2
                           ,X_ITEM_ID          OUT NOCOPY NUMBER
                           ,P_ORG_ID           IN NUMBER
                           ,P_LOCATOR_ID       IN NUMBER
                           ,P_INVENTORY_ITEM_ID IN NUMBER
                           ,P_SOURCE           IN VARCHAR2 DEFAULT NULL
                           );
-- This API returns values for empty_flag,Mixed_Items_Flag and the inventory_item_id column in MTL_ITEM_LOCATIONS table
-- for receipt transactions
procedure inv_loc_receipt (x_return_status     OUT NOCOPY VARCHAR2
                           ,X_MSG_COUNT         OUT NOCOPY NUMBER
                           ,X_MSG_DATA          OUT NOCOPY VARCHAR2
                           ,X_EMPTY_FLAG        OUT NOCOPY VARCHAR2
                           ,X_MIXED_FLAG        OUT NOCOPY VARCHAR2
                           ,X_ITEM_ID           OUT NOCOPY NUMBER
                           ,P_LOCATOR_ID        IN NUMBER
                           ,P_ORG_ID            IN NUMBER
                           ,P_INVENTORY_ITEM_ID IN NUMBER
                           );

PROCEDURE lpn_loc_cleanup_mmtt(x_return_status   OUT NOCOPY varchar2 --return status
                              ,x_msg_count       OUT NOCOPY NUMBER --number of messages in message queue
                              ,x_msg_data        OUT NOCOPY varchar2 --message text when x_msg_count>0
                              ,p_organization_id IN NUMBER -- identier for the organization
                              ,p_mixed_flag      IN VARCHAR2 DEFAULT NULL
                          );
PROCEDURE LPN_LOC_CURRENT_CAPACITY (
                                x_return_status   OUT NOCOPY varchar2 --return status
                               ,x_msg_count       OUT NOCOPY NUMBER --number of messages in message queue
                               ,x_msg_data        OUT NOCOPY varchar2 --message text when x_msg_count>0
                               ,p_organization_id IN NUMBER -- identier for the organization
                               ,p_mixed_flag      IN VARCHAR2 DEFAULT NULL
                                   ) ;

-- This API updates the empty flag,Mixed_Items_Flag and the inventory_item_id column in MTL_ITEM_LOCATIONS table
-- This does an autonomous commit.The P_source parameter will have a value Null when called from the database trigger and
-- will have 'CONCURRENT' when called from the Launch Upgrade concurrent program.
PROCEDURE LOC_EMPTY_MIXED_FLAG_AUTO(  X_RETURN_STATUS          OUT NOCOPY VARCHAR2
                                ,X_MSG_COUNT              OUT NOCOPY NUMBER
                                ,X_MSG_DATA               OUT NOCOPY VARCHAR2
                                ,P_ORGANIZATION_ID        IN  NUMBER
                                ,P_INVENTORY_LOCATION_ID  IN  NUMBER
                                ,P_INVENTORY_ITEM_ID      IN  NUMBER
                                ,P_TRANSACTION_ACTION_ID  IN  NUMBER
                                ,P_TRANSFER_ORGANIZATION  IN  NUMBER
                                ,P_TRANSFER_LOCATION_ID   IN  NUMBER
                                ,P_SOURCE                 IN  VARCHAR2 DEFAULT NULL
                                                 );

procedure upd_empty_mixed_flag_rcv_loc ( x_return_status      OUT NOCOPY VARCHAR2
					 ,x_msg_count         OUT NOCOPY NUMBER
					 ,x_msg_data          OUT NOCOPY VARCHAR2
					 ,p_subinventory      IN VARCHAR2
					 ,p_locator_id        IN NUMBER
					 ,p_org_id            IN NUMBER
					 );

   TYPE LocatorRec IS RECORD (
                              l_locator_weight_uom_code         VARCHAR2(3),
                              l_locator_volume_uom_code         VARCHAR2(3),
                              l_locator_max_weight              NUMBER,
                              l_locator_suggested_weight        NUMBER := 0,
                              l_locator_suggested_cubic_area    NUMBER := 0,
                              l_locator_current_weight          NUMBER := 0,
                              l_locator_available_weight        NUMBER,
                              l_locator_max_cubic_area          NUMBER,
                              l_locator_current_cubic_area      NUMBER := 0,
                              l_locator_available_cubic_area    NUMBER,
                              l_locator_available_units         NUMBER,
                              l_locator_current_units           NUMBER := 0,
                              l_locator_suggested_units         NUMBER := 0,
                              l_locator_maximum_units           NUMBER
                             );

   TYPE ItemRec IS RECORD (
                           l_item_primary_uom_code           VARCHAR2(3),
                           l_item_weight_uom_code            VARCHAR2(3),
                           l_item_unit_weight                NUMBER := 0,
                           l_item_volume_uom_code            VARCHAR2(3),
                           l_item_unit_volume                NUMBER := 0,
                           l_item_xacted_weight              NUMBER := 0,
                           l_item_xacted_volume              NUMBER := 0
                          );

   TYPE LpnRec IS RECORD (
                          l_gross_weight_uom_code       varchar2(3),
                          l_content_volume_uom_code     varchar2(3),
                          l_gross_weight                NUMBER := 0,
                          l_content_volume              NUMBER := 0,
                          l_container_item_weight       NUMBER := 0,
                          l_container_item_vol          NUMBER := 0,
                          l_organization_id             NUMBER,
                          l_locator_id                  NUMBER,
                          l_lpn_exists_in_locator       VARCHAR2(1)
                         );

--Added following procedure for bug #6523490
procedure get_locator_id ( x_locator_id OUT NOCOPY NUMBER ,
                           p_locator IN VARCHAR2 ,
                           p_org_id  IN NUMBER  );

-- 8721026
PROCEDURE get_source_type
  ( x_source              OUT NOCOPY VARCHAR2,
    p_locator_id          IN NUMBER,
    p_organization_id     IN  NUMBER,
    p_inventory_item_id   IN NUMBER,
    p_content_lpn_id      IN NUMBER,
    p_transaction_action_id  IN NUMBER,
    p_primary_quantity     IN NUMBER
  );



END inv_loc_wms_utils;


/
