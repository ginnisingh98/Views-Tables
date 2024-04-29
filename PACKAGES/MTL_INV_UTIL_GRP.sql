--------------------------------------------------------
--  DDL for Package MTL_INV_UTIL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_INV_UTIL_GRP" AUTHID CURRENT_USER AS
/* $Header: INVGIVUS.pls 120.1.12010000.1 2008/07/24 01:33:32 appldev ship $ */

-- Gets the item cost for a specific item.
PROCEDURE get_item_cost
  ( p_api_version        IN           NUMBER                                    ,
    p_init_msg_list      IN           VARCHAR2 DEFAULT 'FND_API.G_FALSE'        ,
    p_commit             IN           VARCHAR2 DEFAULT 'FND_API.G_FALSE'        ,
    p_validation_level   IN           NUMBER DEFAULT FND_API.g_valid_level_full ,
    x_return_status      OUT  NOCOPY  VARCHAR2                                  ,
    x_msg_count          OUT  NOCOPY  NUMBER                                    ,
    x_msg_data           OUT  NOCOPY  VARCHAR2                                  ,
    p_organization_id    IN           NUMBER                                    ,
    p_inventory_item_id  IN           NUMBER                                    ,
    p_locator_id         IN           NUMBER DEFAULT NULL                       ,
    x_item_cost          OUT  NOCOPY  NUMBER);

-- calculate the system quantity of an given item
PROCEDURE calculate_systemquantity
  ( p_api_version            IN          NUMBER                                   ,
    p_init_msg_list          IN          VARCHAR2 DEFAULT FND_API.g_false         ,
    p_commit                 IN          VARCHAR2 DEFAULT FND_API.g_false         ,
    p_validation_level       IN          NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT  NOCOPY VARCHAR2                                 ,
    x_msg_count              OUT  NOCOPY NUMBER                                   ,
    x_msg_data               OUT  NOCOPY VARCHAR2                                 ,
    p_organization_id        IN          NUMBER                                   ,
    p_inventory_item_id      IN          NUMBER                                   ,
    p_subinventory           IN          VARCHAR2                                 ,
    p_lot_number             IN          VARCHAR2                                 ,
    p_revision               IN          VARCHAR2                                 ,
    p_locator_id             IN          NUMBER                                   ,
    p_cost_group_id          IN          NUMBER DEFAULT NULL                      ,
    p_serial_number          IN          VARCHAR2                                 ,
    p_serial_number_control  IN          NUMBER                                   ,
    p_serial_count_option    IN          NUMBER                                   ,
    x_system_quantity        OUT  NOCOPY NUMBER);

-- BEGIN INVCONV
-- Overloaded procedure to return secondary quantity
PROCEDURE calculate_systemquantity
  ( p_api_version            IN          NUMBER                                   ,
    p_init_msg_list          IN          VARCHAR2 DEFAULT FND_API.g_false         ,
    p_commit                 IN          VARCHAR2 DEFAULT FND_API.g_false         ,
    p_validation_level       IN          NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT  NOCOPY VARCHAR2                                 ,
    x_msg_count              OUT  NOCOPY NUMBER                                   ,
    x_msg_data               OUT  NOCOPY VARCHAR2                                 ,
    p_organization_id        IN          NUMBER                                   ,
    p_inventory_item_id      IN          NUMBER                                   ,
    p_subinventory           IN          VARCHAR2                                 ,
    p_lot_number             IN          VARCHAR2                                 ,
    p_revision               IN          VARCHAR2                                 ,
    p_locator_id             IN          NUMBER                                   ,
    p_cost_group_id          IN          NUMBER DEFAULT NULL                      ,
    p_serial_number          IN          VARCHAR2                                 ,
    p_serial_number_control  IN          NUMBER                                   ,
    p_serial_count_option    IN          NUMBER                                   ,
    x_system_quantity        OUT  NOCOPY NUMBER                                   ,
    x_sec_system_quantity    OUT  NOCOPY NUMBER);
-- END INVCONV

FUNCTION CHECK_SERIAL_NUMBER_LOCATION
  ( p_serial_number        IN   VARCHAR2,
    p_item_id              IN   NUMBER,
    p_organization_id      IN   NUMBER,
    p_serial_number_type   IN   NUMBER,
    p_serial_control       IN   NUMBER,
    p_revision             IN   VARCHAR2,
    p_lot_number           IN   VARCHAR2,
    p_subinventory         IN   VARCHAR2,
    p_locator_id           IN   NUMBER,
    p_issue_receipt        IN   VARCHAR2 -- R -receipt I - issue
    ) RETURN BOOLEAN;

-- Calculate system quantity from a LPN
PROCEDURE Get_LPN_Item_SysQty
  ( p_api_version		   IN  	      NUMBER                      ,
    p_init_msg_lst		IN  	      VARCHAR2 := fnd_api.g_false ,
    p_commit		      IN	         VARCHAR2 := fnd_api.g_false ,
    x_return_status		OUT NOCOPY 	VARCHAR2                    ,
    x_msg_count		   OUT NOCOPY	NUMBER                      ,
    x_msg_data		      OUT NOCOPY	VARCHAR2                    ,
    p_organization_id   IN	         NUMBER                      ,
    p_lpn_id		      IN	         NUMBER                      ,
    p_inventory_item_id IN	         NUMBER                      ,
    p_lot_number		   IN	         VARCHAR2                    ,
    p_revision		      IN	         VARCHAR2                    ,
    p_serial_number		IN	         VARCHAR2                    ,
    p_cost_group_id		IN	         NUMBER DEFAULT NULL         ,
    x_lpn_systemqty 	   OUT NOCOPY  NUMBER);

-- BEGIN INVCONV
-- Overloaded procedure to return secondary quantity
PROCEDURE Get_LPN_Item_SysQty
  ( p_api_version		IN  	    NUMBER                      ,
    p_init_msg_lst		IN  	    VARCHAR2 := fnd_api.g_false ,
    p_commit		        IN	    VARCHAR2 := fnd_api.g_false ,
    x_return_status		OUT  NOCOPY VARCHAR2                    ,
    x_msg_count		        OUT  NOCOPY NUMBER                      ,
    x_msg_data		        OUT  NOCOPY VARCHAR2                    ,
    p_organization_id    	IN	    NUMBER                      ,
    p_lpn_id		        IN	    NUMBER                      ,
    p_inventory_item_id	        IN	    NUMBER                      ,
    p_lot_number		IN	    VARCHAR2                    ,
    p_revision		        IN	    VARCHAR2                    ,
    p_serial_number		IN	    VARCHAR2                    ,
    p_cost_group_id		IN	    NUMBER DEFAULT NULL         ,
    x_lpn_systemqty 	        OUT  NOCOPY NUMBER                      ,
    x_lpn_sec_systemqty         OUT  NOCOPY NUMBER);
-- END INVCONV

FUNCTION Exists_CC_Entries
  ( p_organization_id	        IN	NUMBER              ,
    p_parent_lpn_id		IN	NUMBER              ,
    p_inventory_item_id	        IN 	NUMBER              ,
    p_cost_group_id		IN 	NUMBER DEFAULT NULL ,
    p_lot_number		IN	VARCHAR2            ,
    p_revision		        IN	VARCHAR2            ,
    p_serial_number		IN	VARCHAR2
    ) RETURN BOOLEAN;

FUNCTION Exists_CC_Items
  ( p_cc_header_id		IN 	VARCHAR2 ,
    p_inventory_item_id	        IN	NUMBER
    ) RETURN BOOLEAN;

--R12 Procedure to purge the mtl_item_bulkload_recs table
PROCEDURE purge_bulkloadrecs_table
  ( p_request_id NUMBER                   ,
    p_commit     BOOLEAN DEFAULT TRUE
   );

END MTL_INV_UTIL_GRP;

/
