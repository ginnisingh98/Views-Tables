--------------------------------------------------------
--  DDL for Package Body INV_QUANTITY_TREE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_QUANTITY_TREE_GRP" as
/* $Header: INVGQTTB.pls 120.0 2005/05/25 05:13:16 appldev noship $*/

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_Quantity_Tree_GRP';

-- synonyms used in this program
--     qoh          quantity on hand
--     rqoh         reservable quantity on hand
--     qr           quantity reserved
--     qs           quantity suggested
--     att          available to transact
--     atr          available to reserve
--    sqoh          secondary quantity on hand                  -- invConv change
--    srqoh         secondary reservable quantity on hand       -- invConv change
--    sqr           secondary quantity reserved                 -- invConv change
--    sqs           secondare quantity suggested                -- invConv change
--    satt          secondary available to transact             -- invConv change
--    satr          secondary available to reserve              -- invConv change

-- Procedure
--   clear_quantity_cache
-- Description
--   Delete all quantity trees in the memory. Should be called when you call
--   rollback. Otherwise the trees in memory may not be in sync with the data
--   in the corresponding database tables
PROCEDURE clear_quantity_cache
  IS
BEGIN
   inv_quantity_tree_pvt.clear_quantity_cache;
END clear_quantity_cache;

-- Procedure
--   create_tree
-- Description
--   Create a quantity tree, if it does not exist, in memory based on the input
--   and return the tree id
PROCEDURE create_tree
  (  p_api_version_number       IN  NUMBER
   , p_init_msg_lst             IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   , p_organization_id          IN  NUMBER
   , p_inventory_item_id        IN  NUMBER
   , p_tree_mode                IN  INTEGER
   , p_is_revision_control      IN  BOOLEAN
   , p_is_lot_control           IN  BOOLEAN
   , p_is_serial_control        IN  BOOLEAN
   , p_grade_code               IN  VARCHAR2 DEFAULT NULL         -- invConv change
   , p_asset_sub_only           IN  BOOLEAN  DEFAULT FALSE
   , p_include_suggestion       IN  BOOLEAN  DEFAULT FALSE
   , p_demand_source_type_id    IN  NUMBER   DEFAULT -9999
   , p_demand_source_header_id  IN  NUMBER   DEFAULT -9999
   , p_demand_source_line_id    IN  NUMBER   DEFAULT -9999
   , p_demand_source_name       IN  VARCHAR2 DEFAULT NULL
   , p_lot_expiration_date      IN  DATE     DEFAULT NULL
   , p_onhand_source		IN  NUMBER DEFAULT inv_quantity_tree_pvt.g_all_subs
   , x_tree_id                  OUT NOCOPY INTEGER
   ) IS
      l_api_version_number        CONSTANT NUMBER       := 1.0;
      l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Tree';
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

   inv_quantity_tree_pvt.create_tree
     (
        p_api_version_number      => 1.0
      , p_init_msg_lst            => fnd_api.g_false
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
      , p_asset_sub_only          => p_asset_sub_only
      , p_include_suggestion      => p_include_suggestion
      , p_demand_source_type_id   => p_demand_source_type_id
      , p_demand_source_header_id => p_demand_source_header_id
      , p_demand_source_line_id   => p_demand_source_line_id
      , p_demand_source_name      => p_demand_source_name
      , p_lot_expiration_date     => p_lot_expiration_date
      , p_onhand_source		  => p_onhand_source
      , x_tree_id                 => x_tree_id
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

END create_tree;

-- Procedure
--   query_tree
-- Description
--   Query a quantity tree for quantity information at the level
--   specified by the input
PROCEDURE query_tree
  (  p_api_version_number   IN  NUMBER
   , p_init_msg_lst         IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status        OUT NOCOPY VARCHAR2
   , x_msg_count            OUT NOCOPY NUMBER
   , x_msg_data             OUT NOCOPY VARCHAR2
   , p_tree_id              IN  INTEGER
   , p_revision             IN  VARCHAR2
   , p_lot_number           IN  VARCHAR2
   , p_subinventory_code    IN  VARCHAR2
   , p_locator_id           IN  NUMBER
   , x_qoh                  OUT NOCOPY NUMBER
   , x_rqoh                 OUT NOCOPY NUMBER
   , x_qr                   OUT NOCOPY NUMBER
   , x_qs                   OUT NOCOPY NUMBER
   , x_att                  OUT NOCOPY NUMBER
   , x_atr                  OUT NOCOPY NUMBER
   , p_transfer_subinventory_code IN  VARCHAR2
   , p_cost_group_id        IN  NUMBER DEFAULT NULL
   , p_lpn_id               IN  NUMBER DEFAULT NULL
   , p_transfer_locator_id  IN  NUMBER DEFAULT NULL
   ) IS

l_sqoh   NUMBER;
l_srqoh  NUMBER;
l_sqr    NUMBER;
l_sqs    NUMBER;
l_satt   NUMBER;
l_satr   NUMBER;

BEGIN

-- invConv changes begin:
-- Calling the new signature API.
inv_quantity_tree_grp.query_tree
   ( p_api_version_number   => p_api_version_number
   , p_init_msg_lst         => p_init_msg_lst
   , x_return_status        => x_return_status
   , x_msg_count            => x_msg_count
   , x_msg_data             => x_msg_data
   , p_tree_id              => p_tree_id
   , p_revision             => p_revision
   , p_lot_number           => p_lot_number
   , p_subinventory_code    => p_subinventory_code
   , p_locator_id           => p_locator_id
   , x_qoh                  => x_qoh
   , x_rqoh                 => x_rqoh
   , x_qr                   => x_qr
   , x_qs                   => x_qs
   , x_att                  => x_att
   , x_atr                  => x_atr
   , x_sqoh                 => l_sqoh                 -- invConv change
   , x_srqoh                => l_srqoh                -- invConv change
   , x_sqr                  => l_sqr                  -- invConv change
   , x_sqs                  => l_sqs                  -- invConv change
   , x_satt                 => l_satt                 -- invConv change
   , x_satr                 => l_satr                 -- invConv change
   , p_transfer_subinventory_code => p_transfer_subinventory_code
   , p_cost_group_id        => p_cost_group_id
   , p_lpn_id               => p_lpn_id
   , p_transfer_locator_id  => p_transfer_locator_id
   );

END query_tree;

-- invConv changes begin
PROCEDURE query_tree
  (  p_api_version_number   IN  NUMBER
   , p_init_msg_lst         IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status        OUT NOCOPY VARCHAR2
   , x_msg_count            OUT NOCOPY NUMBER
   , x_msg_data             OUT NOCOPY VARCHAR2
   , p_tree_id              IN  INTEGER
   , p_revision             IN  VARCHAR2
   , p_lot_number           IN  VARCHAR2
   , p_subinventory_code    IN  VARCHAR2
   , p_locator_id           IN  NUMBER
   , x_qoh                  OUT NOCOPY NUMBER
   , x_rqoh                 OUT NOCOPY NUMBER
   , x_qr                   OUT NOCOPY NUMBER
   , x_qs                   OUT NOCOPY NUMBER
   , x_att                  OUT NOCOPY NUMBER
   , x_atr                  OUT NOCOPY NUMBER
   , x_sqoh                 OUT NOCOPY NUMBER         -- invConv change
   , x_srqoh                OUT NOCOPY NUMBER         -- invConv change
   , x_sqr                  OUT NOCOPY NUMBER         -- invConv change
   , x_sqs                  OUT NOCOPY NUMBER         -- invConv change
   , x_satt                 OUT NOCOPY NUMBER         -- invConv change
   , x_satr                 OUT NOCOPY NUMBER         -- invConv change
   , p_transfer_subinventory_code IN  VARCHAR2
   , p_cost_group_id        IN  NUMBER DEFAULT NULL
   , p_lpn_id               IN  NUMBER DEFAULT NULL
   , p_transfer_locator_id  IN  NUMBER DEFAULT NULL
   ) IS
      l_api_version_number        CONSTANT NUMBER       := 1.0;
      l_api_name                  CONSTANT VARCHAR2(30) := 'Query_Tree';
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

   inv_quantity_tree_pvt.query_tree
     (
        p_api_version_number  => 1.0
      , p_init_msg_lst        => fnd_api.g_false
      , x_return_status       => l_return_status
      , x_msg_count           => x_msg_count
      , x_msg_data            => x_msg_data
      , p_tree_id             => p_tree_id
      , p_revision            => p_revision
      , p_lot_number          => p_lot_number
      , p_subinventory_code   => p_subinventory_code
      , p_locator_id          => p_locator_id
      , x_qoh                 => x_qoh
      , x_rqoh                => x_rqoh
      , x_qr                  => x_qr
      , x_qs                  => x_qs
      , x_att                 => x_att
      , x_atr                 => x_atr
      , x_sqoh                => x_sqoh               -- invConv change
      , x_srqoh               => x_srqoh              -- invConv change
      , x_sqr                 => x_sqr                -- invConv change
      , x_sqs                 => x_sqs                -- invConv change
      , x_satt                => x_satt               -- invConv change
      , x_satr                => x_satr               -- invConv change
      , p_transfer_subinventory_code => p_transfer_subinventory_code
      , p_cost_group_id	      => p_cost_group_id
      , p_lpn_id	      => p_lpn_id
      , p_transfer_locator_id => p_transfer_locator_id
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

END query_tree;

-- Procedure
--   update_quantities
-- Description
--   Update quantity at the level specified by the input and
--   return the quantities at the level after the update
PROCEDURE update_quantities
  (  p_api_version_number    IN  NUMBER
   , p_init_msg_lst          IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
   , p_tree_id               IN  INTEGER
   , p_revision              IN  VARCHAR2 DEFAULT NULL
   , p_lot_number            IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code     IN  VARCHAR2 DEFAULT NULL
   , p_locator_id            IN  NUMBER   DEFAULT NULL
   , p_primary_quantity      IN  NUMBER
   , p_quantity_type         IN  INTEGER
   , x_qoh                   OUT NOCOPY NUMBER
   , x_rqoh                  OUT NOCOPY NUMBER
   , x_qr                    OUT NOCOPY NUMBER
   , x_qs                    OUT NOCOPY NUMBER
   , x_att                   OUT NOCOPY NUMBER
   , x_atr                   OUT NOCOPY NUMBER
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_cost_group_id	     IN  NUMBER   DEFAULT NULL
   , p_containerized	     IN  NUMBER   DEFAULT inv_quantity_tree_pvt.g_containerized_false
   , p_lpn_id	  	     IN  NUMBER   DEFAULT NULL
   , p_transfer_locator_id   IN  NUMBER   DEFAULT NULL
   )  IS

l_sqoh   NUMBER;
l_srqoh  NUMBER;
l_sqr    NUMBER;
l_sqs    NUMBER;
l_satt   NUMBER;
l_satr   NUMBER;
l_secondary_quantity NUMBER;

BEGIN

-- invConv changes begin : calling the overload procedure
update_quantities
  (  p_api_version_number    => p_api_version_number
   , p_init_msg_lst          => p_init_msg_lst
   , x_return_status         => x_return_status
   , x_msg_count             => x_msg_count
   , x_msg_data              => x_msg_data
   , p_tree_id               => p_tree_id
   , p_revision              => p_revision
   , p_lot_number            => p_lot_number
   , p_subinventory_code     => p_subinventory_code
   , p_locator_id            => p_locator_id
   , p_primary_quantity      => p_primary_quantity
   , p_secondary_quantity    => l_secondary_quantity     -- invConv change
   , p_quantity_type         => p_quantity_type
   , x_qoh                   => x_qoh
   , x_rqoh                  => x_rqoh
   , x_qr                    => x_qr
   , x_qs                    => x_qs
   , x_att                   => x_att
   , x_atr                   => x_atr
   , x_sqoh                   => l_sqoh                -- invConv change
   , x_srqoh                  => l_srqoh               -- invConv change
   , x_sqr                    => l_sqr                 -- invConv change
   , x_sqs                    => l_sqs                 -- invConv change
   , x_satt                   => l_satt                -- invConv change
   , x_satr                   => l_satr                -- invConv change
   , p_transfer_subinventory_code => p_transfer_subinventory_code
   , p_cost_group_id	     => p_cost_group_id
   , p_containerized	     => p_containerized
   , p_lpn_id	  	     => p_lpn_id
   , p_transfer_locator_id   => p_transfer_locator_id
   );
-- invConv changes end.

END update_quantities;

-- invConv changes begin : overload
PROCEDURE update_quantities
  (  p_api_version_number    IN  NUMBER
   , p_init_msg_lst          IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
   , p_tree_id               IN  INTEGER
   , p_revision              IN  VARCHAR2 DEFAULT NULL
   , p_lot_number            IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code     IN  VARCHAR2 DEFAULT NULL
   , p_locator_id            IN  NUMBER   DEFAULT NULL
   , p_primary_quantity      IN  NUMBER
   , p_secondary_quantity    IN  NUMBER                     -- invConv change
   , p_quantity_type         IN  INTEGER
   , x_qoh                   OUT NOCOPY NUMBER
   , x_rqoh                  OUT NOCOPY NUMBER
   , x_qr                    OUT NOCOPY NUMBER
   , x_qs                    OUT NOCOPY NUMBER
   , x_att                   OUT NOCOPY NUMBER
   , x_atr                   OUT NOCOPY NUMBER
   , x_sqoh                  OUT NOCOPY NUMBER               -- invConv change
   , x_srqoh                 OUT NOCOPY NUMBER               -- invConv change
   , x_sqr                   OUT NOCOPY NUMBER               -- invConv change
   , x_sqs                   OUT NOCOPY NUMBER               -- invConv change
   , x_satt                  OUT NOCOPY NUMBER               -- invConv change
   , x_satr                  OUT NOCOPY NUMBER               -- invConv change
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_cost_group_id	     IN  NUMBER   DEFAULT NULL
   , p_containerized	     IN  NUMBER   DEFAULT inv_quantity_tree_pvt.g_containerized_false
   , p_lpn_id	  	     IN  NUMBER   DEFAULT NULL
   , p_transfer_locator_id   IN  NUMBER   DEFAULT NULL
   )  IS
      l_api_version_number        CONSTANT NUMBER       := 1.0;
      l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Quantities';
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

   inv_quantity_tree_pvt.update_quantities
     (
        p_api_version_number  => 1.0
      , p_init_msg_lst        => fnd_api.g_false
      , x_return_status       => l_return_status
      , x_msg_count           => x_msg_count
      , x_msg_data            => x_msg_data
      , p_tree_id             => p_tree_id
      , p_revision            => p_revision
      , p_lot_number          => p_lot_number
      , p_subinventory_code   => p_subinventory_code
      , p_locator_id          => p_locator_id
      , p_primary_quantity    => p_primary_quantity
      , p_secondary_quantity  => p_secondary_quantity  -- invConv change
      , p_quantity_type       => p_quantity_type
      , x_qoh                 => x_qoh
      , x_rqoh                => x_rqoh
      , x_qr                  => x_qr
      , x_qs                  => x_qs
      , x_att                 => x_att
      , x_atr                 => x_atr
      , x_sqoh                 => x_sqoh               -- invConv change
      , x_srqoh                => x_srqoh              -- invConv change
      , x_sqr                  => x_sqr                -- invConv change
      , x_sqs                  => x_sqs                -- invConv change
      , x_satt                 => x_satt               -- invConv change
      , x_satr                 => x_satr               -- invConv change
      , p_transfer_subinventory_code => p_subinventory_code
      , p_cost_group_id       => p_cost_group_id
      , p_containerized       => p_containerized
      , p_lpn_id              => p_lpn_id
      , p_transfer_locator_id => p_transfer_locator_id
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

END update_quantities;

-- Procedure
--   do_check
-- Description
--   check whether the updates done in a tree so far are still valid
-- Return
--   x_no_violation = true if no violation has found
--   , otherwise = false
PROCEDURE do_check
  (  p_api_version_number  IN  NUMBER
   , p_init_msg_lst        IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   , p_tree_id             IN  INTEGER
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

   inv_quantity_tree_pvt.do_check
     (
        p_api_version_number  => 1.0
      , p_init_msg_lst        => fnd_api.g_false
      , x_return_status       => l_return_status
      , x_msg_count           => x_msg_count
      , x_msg_data            => x_msg_data
      , p_tree_id             => p_tree_id
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

   inv_quantity_tree_pvt.do_check
     (
        p_api_version_number  => 1.0
      , p_init_msg_lst        => fnd_api.g_false
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

-- Procedure
--   free_tree
-- Description
--   Free a tree when no longer needed.
-- Warning
--   If you have called update_quantities to change quantity on the tree
--   but have not make corresponding changes to the underlying database
--   tables, these changes are lost when you call free_tree.
PROCEDURE free_tree
  (  p_api_version_number  IN  NUMBER
   , p_init_msg_lst        IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   , p_tree_id             IN  INTEGER
   )  IS
      l_api_version_number        CONSTANT NUMBER       := 1.0;
      l_api_name                  CONSTANT VARCHAR2(30) := 'Free_Tree';
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

   inv_quantity_tree_pvt.free_tree
     (
        p_api_version_number  => 1.0
      , p_init_msg_lst        => fnd_api.g_false
      , x_return_status       => l_return_status
      , x_msg_count           => x_msg_count
      , x_msg_data            => x_msg_data
      , p_tree_id             => p_tree_id
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

END free_tree;

-- Procedure
--   backup_tree
-- Description
--   backup the current state of a tree
-- Note
--   This is only a one level backup. Calling it twice will
--   overwrite the previous backup
PROCEDURE backup_tree
  (
     x_return_status OUT NOCOPY VARCHAR2
   , p_tree_id       IN  INTEGER
   ) IS
BEGIN
   inv_quantity_tree_pvt.backup_tree(x_return_status, p_tree_id);
END backup_tree;

-- Procedure
--   restore_tree
-- Description
--   restore the current state of a tree to the state
--   at the last time when savepoint_tree is called
-- Note
--   This is only a one level restore. Calling it more than once
--   has the same effect as calling it once.
PROCEDURE restore_tree
  (
     x_return_status OUT NOCOPY VARCHAR2
   , p_tree_id       IN  INTEGER
   ) IS
BEGIN
   inv_quantity_tree_pvt.restore_tree(x_return_status, p_tree_id);
END restore_tree;

END inv_quantity_tree_grp;

/
