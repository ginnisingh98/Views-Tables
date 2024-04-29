--------------------------------------------------------
--  DDL for Package Body INV_QUANTITY_TREE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_QUANTITY_TREE_PUB" as
/* $Header: INVPQTTB.pls 120.5.12010000.2 2009/06/12 06:07:46 ksivasa ship $*/

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_Quantity_Tree_PUB';

-- Procedure
--   clear_quantity_cache
-- Description
--   Delete all quantity trees in the memory. Should be called when you call
--   rollback. Otherwise the trees in memory may not be in sync with the data
--   in the corresponding database tables
PROCEDURE clear_quantity_cache
  IS
BEGIN
   inv_quantity_tree_grp.clear_quantity_cache;
END clear_quantity_cache;

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
  ) IS

l_grade_code          VARCHAR2(150);   -- invConv change
l_sqoh                NUMBER;    -- invConv change
l_srqoh               NUMBER;    -- invConv change
l_sqr                 NUMBER;    -- invConv change
l_sqs                 NUMBER;    -- invConv change
l_satt                NUMBER;    -- invConv change
l_satr                NUMBER;    -- invConv change

BEGIN
-- invConv changes begin:
-- calling the new API
query_quantities
  (  p_api_version_number   	=> p_api_version_number
   , p_init_msg_lst         	=> p_init_msg_lst
   , x_return_status        	=> x_return_status
   , x_msg_count            	=> x_msg_count
   , x_msg_data             	=> x_msg_data
   , p_organization_id          => p_organization_id
   , p_inventory_item_id        => p_inventory_item_id
   , p_tree_mode                => p_tree_mode
   , p_is_revision_control      => p_is_revision_control
   , p_is_lot_control           => p_is_lot_control
   , p_is_serial_control        => p_is_serial_control
   , p_grade_code               => l_grade_code
   , p_demand_source_type_id    => p_demand_source_type_id
   , p_demand_source_header_id  => p_demand_source_header_id
   , p_demand_source_line_id    => p_demand_source_line_id
   , p_demand_source_name       => p_demand_source_name
   , p_lot_expiration_date      => p_lot_expiration_date
   , p_revision             	=> p_revision
   , p_lot_number           	=> p_lot_number
   , p_subinventory_code    	=> p_subinventory_code
   , p_locator_id           	=> p_locator_id
   , p_onhand_source		=> p_onhand_source
   , x_qoh                  	=> x_qoh
   , x_rqoh                 	=> x_rqoh
   , x_qr                   	=> x_qr
   , x_qs                   	=> x_qs
   , x_att                  	=> x_att
   , x_atr                  	=> x_atr
   , x_sqoh                  	=> l_sqoh
   , x_srqoh                 	=> l_srqoh
   , x_sqr                   	=> l_sqr
   , x_sqs                   	=> l_sqs
   , x_satt                  	=> l_satt
   , x_satr                  	=> l_satr
   , p_transfer_subinventory_code => p_transfer_subinventory_code
   , p_cost_group_id		=> p_cost_group_id
   , p_lpn_id			=> p_lpn_id
   , p_transfer_locator_id	=> p_transfer_locator_id);
-- invConv changes end.

END query_quantities;

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
   , p_grade_code               IN  VARCHAR2       -- invConv change
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
   , x_sqoh                  	OUT NOCOPY NUMBER    -- invConv change
   , x_srqoh                 	OUT NOCOPY NUMBER    -- invConv change
   , x_sqr                   	OUT NOCOPY NUMBER    -- invConv change
   , x_sqs                   	OUT NOCOPY NUMBER    -- invConv change
   , x_satt                  	OUT NOCOPY NUMBER    -- invConv change
   , x_satr                  	OUT NOCOPY NUMBER    -- invConv change
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_cost_group_id		IN  NUMBER DEFAULT NULL
   , p_lpn_id			IN  NUMBER DEFAULT NULL
   , p_transfer_locator_id	IN  NUMBER DEFAULT NULL
  ) IS

     l_api_version_number       CONSTANT NUMBER       := 1.0;
     l_api_name                 CONSTANT VARCHAR2(30) := 'Query_Quantities';
     l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_tree_id                  INTEGER;

BEGIN

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   inv_quantity_tree_grp.create_tree
     (
        p_api_version_number      => 1.0
      , p_init_msg_lst            => p_init_msg_lst
      , x_return_status           => l_return_status
      , x_msg_count               => x_msg_count
      , x_msg_data                => x_msg_data
      , p_organization_id         => p_organization_id
      , p_inventory_item_id       => p_inventory_item_id
      , p_tree_mode               => p_tree_mode
      , p_is_revision_control     => p_is_revision_control
      , p_is_lot_control          => p_is_lot_control
      , p_is_serial_control       => p_is_serial_control
      , p_grade_code              => p_grade_code
      , p_demand_source_type_id   => p_demand_source_type_id
      , p_demand_source_header_id => p_demand_source_header_id
      , p_demand_source_line_id   => p_demand_source_line_id
      , p_demand_source_name      => p_demand_source_name
      , p_lot_expiration_date     => p_lot_expiration_date
      , p_onhand_source		  => p_onhand_source
      , x_tree_id                 => l_tree_id
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   inv_quantity_tree_grp.query_tree
     (
        p_api_version_number      => 1.0
      , p_init_msg_lst            => p_init_msg_lst
      , x_return_status           => l_return_status
      , x_msg_count               => x_msg_count
      , x_msg_data                => x_msg_data
      , p_tree_id                 => l_tree_id
      , p_revision                => p_revision
      , p_lot_number              => p_lot_number
      , p_subinventory_code       => p_subinventory_code
      , p_locator_id              => p_locator_id
      , x_qoh                     => x_qoh
      , x_rqoh                    => x_rqoh
      , x_qr                      => x_qr
      , x_qs                      => x_qs
      , x_att                     => x_att
      , x_atr                     => x_atr
      , x_sqoh                    => x_sqoh      -- invConv change
      , x_srqoh                   => x_srqoh     -- invConv change
      , x_sqr                     => x_sqr       -- invConv change
      , x_sqs                     => x_sqs       -- invConv change
      , x_satt                    => x_satt      -- invConv change
      , x_satr                    => x_satr      -- invConv change
      , p_transfer_subinventory_code => p_transfer_subinventory_code
      , p_cost_group_id		  => p_cost_group_id
      , p_lpn_id		  => p_lpn_id
      , p_transfer_locator_id	  => p_transfer_locator_id
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END query_quantities;

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
   , p_cost_group_id		IN  NUMBER  DEFAULT NULL
   , p_containerized		IN  NUMBER  DEFAULT inv_quantity_tree_pvt.g_containerized_false
   , p_lpn_id			IN  NUMBER  DEFAULT NULL
   , p_transfer_locator_id	IN  NUMBER  DEFAULT NULL
  ) IS

l_sqoh    NUMBER;    -- invConv change
l_srqoh   NUMBER;    -- invConv change
l_sqr     NUMBER;    -- invConv change
l_sqs     NUMBER;    -- invConv change
l_satt    NUMBER;    -- invConv change
l_satr    NUMBER;    -- invConv change
l_secondary_quantity    NUMBER;    -- invConv change

BEGIN

-- invConv changes begin :
-- calling the new API
update_quantities
  (  p_api_version_number    	=> p_api_version_number
   , p_init_msg_lst          	=> p_init_msg_lst
   , x_return_status         	=> x_return_status
   , x_msg_count             	=> x_msg_count
   , x_msg_data              	=> x_msg_data
   , p_organization_id          => p_organization_id
   , p_inventory_item_id        => p_inventory_item_id
   , p_tree_mode                => p_tree_mode
   , p_is_revision_control      => p_is_revision_control
   , p_is_lot_control           => p_is_lot_control
   , p_is_serial_control        => p_is_serial_control
   , p_demand_source_type_id    => p_demand_source_type_id
   , p_demand_source_header_id  => p_demand_source_header_id
   , p_demand_source_line_id    => p_demand_source_line_id
   , p_demand_source_name       => p_demand_source_name
   , p_lot_expiration_date      => p_lot_expiration_date
   , p_revision              	=> p_revision
   , p_lot_number            	=> p_lot_number
   , p_subinventory_code     	=> p_subinventory_code
   , p_locator_id            	=> p_locator_id
   , p_grade_code            	=> NULL                        -- invConv change
   , p_primary_quantity         => p_primary_quantity
   , p_quantity_type            => p_quantity_type
   , p_secondary_quantity       => l_secondary_quantity        -- invConv change
   , p_onhand_source            => p_onhand_source
   , x_qoh                      => x_qoh
   , x_rqoh                     => x_rqoh
   , x_qr                       => x_qr
   , x_qs                       => x_qs
   , x_att                      => x_att
   , x_atr                      => x_atr
   , x_sqoh                     => l_sqoh     -- invConv change
   , x_srqoh                    => l_srqoh    -- invConv change
   , x_sqr                      => l_sqr      -- invConv change
   , x_sqs                      => l_sqs      -- invConv change
   , x_satt                     => l_satt     -- invConv change
   , x_satr                     => l_satr     -- invConv change
   , p_transfer_subinventory_code => p_transfer_subinventory_code
   , p_cost_group_id            => p_cost_group_id
   , p_containerized            => p_containerized
   , p_lpn_id                   => p_lpn_id
   , p_transfer_locator_id      => p_transfer_locator_id);
-- invConv changes end.


END  update_quantities;

-- invConv changes begin: overload
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
   , p_grade_code            	IN  VARCHAR2 DEFAULT NULL    -- invConv change
   , p_primary_quantity      	IN  NUMBER
   , p_quantity_type         	IN  INTEGER
   , p_secondary_quantity      	IN  NUMBER                -- invConv change
   , p_onhand_source		IN  NUMBER DEFAULT inv_quantity_tree_pvt.g_all_subs
   , x_qoh                   	OUT NOCOPY NUMBER
   , x_rqoh                  	OUT NOCOPY NUMBER
   , x_qr                    	OUT NOCOPY NUMBER
   , x_qs                    	OUT NOCOPY NUMBER
   , x_att                   	OUT NOCOPY NUMBER
   , x_atr                   	OUT NOCOPY NUMBER
   , x_sqoh                   	OUT NOCOPY NUMBER          -- invConv change
   , x_srqoh                  	OUT NOCOPY NUMBER          -- invConv change
   , x_sqr                    	OUT NOCOPY NUMBER          -- invConv change
   , x_sqs                    	OUT NOCOPY NUMBER          -- invConv change
   , x_satt                   	OUT NOCOPY NUMBER          -- invConv change
   , x_satr                   	OUT NOCOPY NUMBER          -- invConv change
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_cost_group_id		IN  NUMBER  DEFAULT NULL
   , p_containerized		IN  NUMBER  DEFAULT inv_quantity_tree_pvt.g_containerized_false
   , p_lpn_id			IN  NUMBER  DEFAULT NULL
   , p_transfer_locator_id	IN  NUMBER  DEFAULT NULL
  ) IS

     l_api_version_number       CONSTANT NUMBER       := 1.0;
     l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Quantities';
     l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_tree_id                  INTEGER;
     l_qoh                   	NUMBER;
     l_rqoh                  	NUMBER;
     l_qr                    	NUMBER;
     l_qs                    	NUMBER;
     l_att                   	NUMBER;
     l_atr                   	NUMBER;
     l_sqoh                   	NUMBER;               -- invConv change
     l_srqoh                  	NUMBER;               -- invConv change
     l_sqr                    	NUMBER;               -- invConv change
     l_sqs                    	NUMBER;               -- invConv change
     l_satt                   	NUMBER;               -- invConv change
     l_satr                   	NUMBER;               -- invConv change
     /*Bug:5209598. Following three variables have been added as part of this bug. */
     l_override_neg_for_backflush NUMBER := 2;
     l_neg_inv_rcpt               NUMBER := 0;
BEGIN

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   inv_quantity_tree_grp.create_tree
     (
        p_api_version_number      => 1.0
      , p_init_msg_lst            => p_init_msg_lst
      , x_return_status           => l_return_status
      , x_msg_count               => x_msg_count
      , x_msg_data                => x_msg_data
      , p_organization_id         => p_organization_id
      , p_inventory_item_id       => p_inventory_item_id
      , p_tree_mode               => p_tree_mode
      , p_is_revision_control     => p_is_revision_control
      , p_is_lot_control          => p_is_lot_control
      , p_is_serial_control       => p_is_serial_control
      , p_grade_code              => p_grade_code
      , p_demand_source_type_id   => p_demand_source_type_id
      , p_demand_source_header_id => p_demand_source_header_id
      , p_demand_source_line_id   => p_demand_source_line_id
      , p_demand_source_name      => p_demand_source_name
      , p_lot_expiration_date     => p_lot_expiration_date
      , p_onhand_source		  => p_onhand_source
      , x_tree_id                 => l_tree_id
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   inv_quantity_tree_grp.query_tree
     (
        p_api_version_number      => 1.0
      , p_init_msg_lst            => p_init_msg_lst
      , x_return_status           => l_return_status
      , x_msg_count               => x_msg_count
      , x_msg_data                => x_msg_data
      , p_tree_id                 => l_tree_id
      , p_revision                => p_revision
      , p_lot_number              => p_lot_number
      , p_subinventory_code       => p_subinventory_code
      , p_locator_id              => p_locator_id
      , x_qoh                     => l_qoh
      , x_rqoh                    => l_rqoh
      , x_qr                      => l_qr
      , x_qs                      => l_qs
      , x_att                     => l_att
      , x_atr                     => l_atr
      , x_sqoh                    => l_sqoh        -- invConv change
      , x_srqoh                   => l_srqoh       -- invConv change
      , x_sqr                     => l_sqr         -- invConv change
      , x_sqs                     => l_sqs         -- invConv change
      , x_satt                    => l_satt        -- invConv change
      , x_satr                    => l_satr        -- invConv change
      , p_transfer_subinventory_code => p_transfer_subinventory_code
      , p_cost_group_id		  => p_cost_group_id
      , p_lpn_id		  => p_lpn_id
      , p_transfer_locator_id     => p_transfer_locator_id
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   /*Bug:5209598. Added the follwing code to get the profile values.
   IF (p_demand_source_type_id = inv_globals.G_SOURCETYPE_WIP) THEN
     l_override_neg_for_backflush := NVL(fnd_profile.value('INV_OVERRIDE_NEG_FOR_BACKFLUSH'), 2);
   END IF;*/

   --Bug 8571657
   l_override_neg_for_backflush := NVL(fnd_profile.value('INV_OVERRIDE_NEG_FOR_BACKFLUSH'), 2);
   BEGIN
     SELECT NEGATIVE_INV_RECEIPT_CODE
     INTO   l_neg_inv_rcpt
     FROM   MTL_PARAMETERS
     WHERE  ORGANIZATION_ID = p_organization_id;
   EXCEPTION
     WHEN OTHERS THEN
       l_neg_inv_rcpt := 2;
   END;


   /*Bug:5209598. Following condition has been modified to not error out in the case where
     we are trying to complete an assembly that has a component with
     transaction_quantity(p_primary_quantity of the component) less than 0,
     abs(transaction_quantity)< ATT and there exists a reservation for this component,
     eventhough the profile 'INV_OVERRIDE_RSV_FOR_BACKFLUSH' is set to 'YES'.
     Now the following condition is modified to allow this transaction by checking the profile */

   --Bug 1641063
   --Check for sufficient qty when transaction mode was wrong
   /*Bug 5451638. Modified the following condition to check only for profile
     l_override_neg_for_backflush only ignoring l_override_rsv_for_backflush
     for WIP transactions*/
   IF (p_tree_mode = g_reservation_mode
       AND p_primary_quantity > 0
       AND p_primary_quantity > l_atr )
   OR (p_tree_mode = g_transaction_mode
       AND p_quantity_type = g_qoh
       AND p_primary_quantity < 0
       AND abs(p_primary_quantity) > l_att
       AND NOT( ( p_demand_source_type_id = inv_globals.G_SOURCETYPE_WIP AND
                  l_override_neg_for_backflush = 1 )
                      OR
                (l_neg_inv_rcpt = 1)
              )
       AND l_att > 0)
     THEN
      fnd_message.set_name('INV', 'INV_QTY_LESS_OR_EQUAL');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;

   inv_quantity_tree_grp.update_quantities
     (
        p_api_version_number      => 1.0
      , p_init_msg_lst            => p_init_msg_lst
      , x_return_status           => l_return_status
      , x_msg_count               => x_msg_count
      , x_msg_data                => x_msg_data
      , p_tree_id                 => l_tree_id
      , p_revision                => p_revision
      , p_lot_number              => p_lot_number
      , p_subinventory_code       => p_subinventory_code
      , p_locator_id              => p_locator_id
      , p_primary_quantity        => p_primary_quantity
      , p_quantity_type           => p_quantity_type
      , p_secondary_quantity      => p_secondary_quantity       -- invConv change
      , x_qoh                     => l_qoh
      , x_rqoh                    => l_rqoh
      , x_qr                      => l_qr
      , x_qs                      => l_qs
      , x_att                     => l_att
      , x_atr                     => l_atr
      , x_sqoh                    => l_sqoh        -- invConv change
      , x_srqoh                   => l_srqoh       -- invConv change
      , x_sqr                     => l_sqr         -- invConv change
      , x_sqs                     => l_sqs         -- invConv change
      , x_satt                    => l_satt        -- invConv change
      , x_satr                    => l_satr        -- invConv change
      , p_transfer_subinventory_code => p_transfer_subinventory_code
      , p_cost_group_id		  => p_cost_group_id
      , p_containerized		  => p_containerized
      , p_lpn_id		  => p_lpn_id
      , p_transfer_locator_id	  => p_transfer_locator_id
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_qoh   := l_qoh;
   x_rqoh  := l_rqoh;
   x_qr    := l_qr;
   x_qs    := l_qs;
   x_att   := l_att;
   x_atr   := l_atr;
   x_sqoh  := l_sqoh;
   x_srqoh := l_srqoh;
   x_sqr   := l_sqr;
   x_sqs   := l_sqs;
   x_satt  := l_satt;
   x_satr  := l_satr;
   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END update_quantities;

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
   ) IS
      l_api_version_number        CONSTANT NUMBER       := 1.0;
      l_api_name                  CONSTANT VARCHAR2(30) := 'Do_Check';
      l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;
BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   inv_quantity_tree_grp.do_check
     (
        p_api_version_number  => 1.0
      , p_init_msg_lst        => p_init_msg_lst
      , x_return_status       => l_return_status
      , x_msg_count           => x_msg_count
      , x_msg_data            => x_msg_data
      , x_no_violation        => x_no_violation
     );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

END do_check;

END inv_quantity_tree_pub;

/
