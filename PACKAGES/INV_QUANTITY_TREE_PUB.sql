--------------------------------------------------------
--  DDL for Package INV_QUANTITY_TREE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_QUANTITY_TREE_PUB" AUTHID CURRENT_USER as
/* $Header: INVPQTTS.pls 120.0 2005/05/24 19:19:41 appldev noship $*/

-- synonyms used in this program
--     qoh          quantity on hand
--     rqoh         reservable quantity on hand
--     qr           quantity reserved
--     qs           quantity suggested
--     att          available to transact
--     atr          available to reserve
--
-- Constant Definition
--
-- Tree mode constants
--   Users can call create_tree() in two mode, reservation mode and
--   transaction mode
g_reservation_mode CONSTANT INTEGER := inv_quantity_tree_pvt.g_reservation_mode;
g_transaction_mode CONSTANT INTEGER := inv_quantity_tree_pvt.g_transaction_mode;
g_loose_only_mode CONSTANT INTEGER := inv_quantity_tree_pvt.g_loose_only_mode;
g_no_lpn_rsvs_mode CONSTANT INTEGER :=
			inv_quantity_tree_pvt.g_no_lpn_rsvs_mode;
--
--
-- Quantity type constants
--   User can call update_quantities to change quantities at a given level.
--   Quantity type constans should be used to specify which quantity the user
--   intents to change: quantity onhand, or quantity reserved for the (same) demand
--   source that was used to create the tree, and in the future, quantity suggested
--   when quantity suggestion is implemented.
g_qoh              CONSTANT INTEGER := inv_quantity_tree_pvt.g_qoh;
-- quantity reserved by same demand source
g_qr_same_demand   CONSTANT INTEGER := inv_quantity_tree_pvt.g_qr_same_demand;
-- quantity for suggested reservation
g_qs_rsv          CONSTANT INTEGER := inv_quantity_tree_pvt.g_qs_rsv;
-- quantity for suggested transaction
g_qs_txn          CONSTANT INTEGER := inv_quantity_tree_pvt.g_qs_txn;

-- Procedure
--   clear_quantity_cache
-- Description
--   Delete all quantity trees in the memory. Should be called when you call
--   rollback. Otherwise the trees in memory may not be in sync with the data
--   in the corresponding database tables
PROCEDURE clear_quantity_cache;

-- Procedure
--   query_quantities
-- Description
--   Query quantities at a level
--   specified by the input
PROCEDURE query_quantities
  (  p_api_version_number   	IN  NUMBER
   , p_init_msg_lst         	IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status        	OUT NOCOPY VARCHAR2
   , x_msg_count            	OUT NOCOPY NUMBER
   , x_msg_data             	OUT NOCOPY VARCHAR2
   , p_organization_id          IN  NUMBER
   , p_inventory_item_id        IN  NUMBER
   , p_tree_mode                IN  INTEGER
   , p_is_revision_control      IN  BOOLEAN
   , p_is_lot_control           IN  BOOLEAN
   , p_is_serial_control        IN  BOOLEAN
   , p_demand_source_type_id    IN  NUMBER   DEFAULT -9999
   , p_demand_source_header_id  IN  NUMBER   DEFAULT -9999
   , p_demand_source_line_id    IN  NUMBER   DEFAULT -9999
   , p_demand_source_name       IN  VARCHAR2 DEFAULT NULL
   , p_lot_expiration_date      IN  DATE     DEFAULT NULL
   , p_revision             	IN  VARCHAR2
   , p_lot_number           	IN  VARCHAR2
   , p_subinventory_code    	IN  VARCHAR2
   , p_locator_id           	IN  NUMBER
   , p_onhand_source		IN  NUMBER DEFAULT inv_quantity_tree_pvt.g_all_subs
   , x_qoh                  	OUT NOCOPY NUMBER
   , x_rqoh                 	OUT NOCOPY NUMBER
   , x_qr                   	OUT NOCOPY NUMBER
   , x_qs                   	OUT NOCOPY NUMBER
   , x_att                  	OUT NOCOPY NUMBER
   , x_atr                  	OUT NOCOPY NUMBER
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_cost_group_id		IN  NUMBER DEFAULT NULL
   , p_lpn_id			IN  NUMBER DEFAULT NULL
   , p_transfer_locator_id	IN  NUMBER DEFAULT NULL
   );

-- invConv changes begin : overload
PROCEDURE query_quantities
  (  p_api_version_number   	IN  NUMBER
   , p_init_msg_lst         	IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status        	OUT NOCOPY VARCHAR2
   , x_msg_count            	OUT NOCOPY NUMBER
   , x_msg_data             	OUT NOCOPY VARCHAR2
   , p_organization_id          IN  NUMBER
   , p_inventory_item_id        IN  NUMBER
   , p_tree_mode                IN  INTEGER
   , p_is_revision_control      IN  BOOLEAN
   , p_is_lot_control           IN  BOOLEAN
   , p_is_serial_control        IN  BOOLEAN
   , p_grade_code               IN  VARCHAR2                 -- invConv change
   , p_demand_source_type_id    IN  NUMBER   DEFAULT -9999
   , p_demand_source_header_id  IN  NUMBER   DEFAULT -9999
   , p_demand_source_line_id    IN  NUMBER   DEFAULT -9999
   , p_demand_source_name       IN  VARCHAR2 DEFAULT NULL
   , p_lot_expiration_date      IN  DATE     DEFAULT NULL
   , p_revision             	IN  VARCHAR2
   , p_lot_number           	IN  VARCHAR2
   , p_subinventory_code    	IN  VARCHAR2
   , p_locator_id           	IN  NUMBER
   , p_onhand_source		IN  NUMBER DEFAULT inv_quantity_tree_pvt.g_all_subs
   , x_qoh                  	OUT NOCOPY NUMBER
   , x_rqoh                 	OUT NOCOPY NUMBER
   , x_qr                   	OUT NOCOPY NUMBER
   , x_qs                   	OUT NOCOPY NUMBER
   , x_att                  	OUT NOCOPY NUMBER
   , x_atr                  	OUT NOCOPY NUMBER
   , x_sqoh                  	OUT NOCOPY NUMBER         -- invConv change
   , x_srqoh                 	OUT NOCOPY NUMBER         -- invConv change
   , x_sqr                   	OUT NOCOPY NUMBER         -- invConv change
   , x_sqs                   	OUT NOCOPY NUMBER         -- invConv change
   , x_satt                  	OUT NOCOPY NUMBER         -- invConv change
   , x_satr                  	OUT NOCOPY NUMBER         -- invConv change
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_cost_group_id		IN  NUMBER DEFAULT NULL
   , p_lpn_id			IN  NUMBER DEFAULT NULL
   , p_transfer_locator_id	IN  NUMBER DEFAULT NULL
   );
-- invConv changes end.

-- Procedure
--   update_quantities
-- Description
--   Update quantity at the level specified by the input and
--   return the quantities at the level after the update
PROCEDURE update_quantities
  (  p_api_version_number    	IN  NUMBER
   , p_init_msg_lst          	IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status         	OUT NOCOPY VARCHAR2
   , x_msg_count             	OUT NOCOPY NUMBER
   , x_msg_data              	OUT NOCOPY VARCHAR2
   , p_organization_id          IN  NUMBER
   , p_inventory_item_id        IN  NUMBER
   , p_tree_mode                IN  INTEGER
   , p_is_revision_control      IN  BOOLEAN
   , p_is_lot_control           IN  BOOLEAN
   , p_is_serial_control        IN  BOOLEAN
   , p_demand_source_type_id    IN  NUMBER   DEFAULT -9999
   , p_demand_source_header_id  IN  NUMBER   DEFAULT -9999
   , p_demand_source_line_id    IN  NUMBER   DEFAULT -9999
   , p_demand_source_name       IN  VARCHAR2 DEFAULT NULL
   , p_lot_expiration_date      IN  DATE     DEFAULT NULL
   , p_revision              	IN  VARCHAR2 DEFAULT NULL
   , p_lot_number            	IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code     	IN  VARCHAR2 DEFAULT NULL
   , p_locator_id            	IN  NUMBER   DEFAULT NULL
   , p_primary_quantity      	IN  NUMBER
   , p_quantity_type         	IN  INTEGER
   , p_onhand_source		IN  NUMBER DEFAULT inv_quantity_tree_pvt.g_all_subs
   , x_qoh                   	OUT NOCOPY NUMBER
   , x_rqoh                  	OUT NOCOPY NUMBER
   , x_qr                    	OUT NOCOPY NUMBER
   , x_qs                    	OUT NOCOPY NUMBER
   , x_att                   	OUT NOCOPY NUMBER
   , x_atr                   	OUT NOCOPY NUMBER
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_cost_group_id		IN  NUMBER DEFAULT NULL
   , p_containerized		IN  NUMBER DEFAULT inv_quantity_tree_pvt.g_containerized_false
   , p_lpn_id			IN  NUMBER DEFAULT NULL
   , p_transfer_locator_id	IN  NUMBER DEFAULT NULL
   ) ;

-- invConv changes begin : overload
PROCEDURE update_quantities
  (  p_api_version_number    	IN  NUMBER
   , p_init_msg_lst          	IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status         	OUT NOCOPY VARCHAR2
   , x_msg_count             	OUT NOCOPY NUMBER
   , x_msg_data              	OUT NOCOPY VARCHAR2
   , p_organization_id          IN  NUMBER
   , p_inventory_item_id        IN  NUMBER
   , p_tree_mode                IN  INTEGER
   , p_is_revision_control      IN  BOOLEAN
   , p_is_lot_control           IN  BOOLEAN
   , p_is_serial_control        IN  BOOLEAN
   , p_demand_source_type_id    IN  NUMBER   DEFAULT -9999
   , p_demand_source_header_id  IN  NUMBER   DEFAULT -9999
   , p_demand_source_line_id    IN  NUMBER   DEFAULT -9999
   , p_demand_source_name       IN  VARCHAR2 DEFAULT NULL
   , p_lot_expiration_date      IN  DATE     DEFAULT NULL
   , p_revision              	IN  VARCHAR2 DEFAULT NULL
   , p_lot_number            	IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code     	IN  VARCHAR2 DEFAULT NULL
   , p_locator_id            	IN  NUMBER   DEFAULT NULL
   , p_grade_code            	IN  VARCHAR2 DEFAULT NULL         -- invConv change
   , p_primary_quantity      	IN  NUMBER
   , p_quantity_type         	IN  INTEGER
   , p_secondary_quantity      	IN  NUMBER              -- invConv change
   , p_onhand_source		IN  NUMBER DEFAULT inv_quantity_tree_pvt.g_all_subs
   , x_qoh                   	OUT NOCOPY NUMBER
   , x_rqoh                  	OUT NOCOPY NUMBER
   , x_qr                    	OUT NOCOPY NUMBER
   , x_qs                    	OUT NOCOPY NUMBER
   , x_att                   	OUT NOCOPY NUMBER
   , x_atr                   	OUT NOCOPY NUMBER
   , x_sqoh                   	OUT NOCOPY NUMBER       -- invConv change
   , x_srqoh                  	OUT NOCOPY NUMBER       -- invConv change
   , x_sqr                    	OUT NOCOPY NUMBER       -- invConv change
   , x_sqs                    	OUT NOCOPY NUMBER       -- invConv change
   , x_satt                   	OUT NOCOPY NUMBER       -- invConv change
   , x_satr                   	OUT NOCOPY NUMBER       -- invConv change
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_cost_group_id		IN  NUMBER DEFAULT NULL
   , p_containerized		IN  NUMBER DEFAULT inv_quantity_tree_pvt.g_containerized_false
   , p_lpn_id			IN  NUMBER DEFAULT NULL
   , p_transfer_locator_id	IN  NUMBER DEFAULT NULL
   ) ;
-- invConv changes end.


-- Procedure
--   do_check
-- Description
--   check whether the updates done in all trees so far are still valid
-- Return
--   x_no_violation = true if no violation has found
--   , otherwise = false
PROCEDURE do_check
  (  p_api_version_number  IN  NUMBER
   , p_init_msg_lst        IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   , x_no_violation        OUT NOCOPY BOOLEAN
   );

END inv_quantity_tree_pub;

 

/
