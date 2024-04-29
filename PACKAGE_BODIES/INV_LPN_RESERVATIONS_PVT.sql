--------------------------------------------------------
--  DDL for Package Body INV_LPN_RESERVATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LPN_RESERVATIONS_PVT" AS
  /* $Header: INVRSVLB.pls 120.4.12010000.4 2010/09/13 08:59:48 avuppala ship $*/

  g_pkg_name VARCHAR2(30) := 'inv_lpn_reservations_pvt';
  g_debug NUMBER;

  --Create_LPN_Reservations
  --
  -- This API is designed to be called from the Reservations Form.
  -- This procedure will create a separate reservation for each lot and
  -- revision in that LPN.

  PROCEDURE debug_print(p_message IN VARCHAR2, p_level IN NUMBER := 9) IS
    --l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    inv_log_util.TRACE(p_message, g_pkg_name, p_level);
  --  dbms_output.put_line(p_message);
  END debug_print;

  /***************************************************************************
   * Bug#2402957:                                                            *
   * Function is_lpn_reserved() checks if the lpn passed is reserved         *
   *  against any other demand than the one passed.                          *
   *  1. If demand is Sales/Internal Order or RMA then check if the LPN is   *
   *     reserved against a demand other than the current demand line id     *
   *  2. If the demand is Account/Account Alias check if the LPN is reserved *
   *     against a demand other than the current header id.                  *
   *  3. If the demand is Inventory/User defined. then check if the LPN is   *
   *     reserved against a demand other than the current demand name.       *
   ***************************************************************************/
  FUNCTION is_lpn_reserved(
                           p_item_id                 IN NUMBER
                          ,p_org_id                  IN NUMBER
                          ,p_demand_source_type_id   IN NUMBER
                          ,p_demand_source_header_id IN NUMBER
                          ,p_demand_source_line_id   IN NUMBER
                          ,p_demand_source_name      IN VARCHAR2
                          ,p_lpn_id                  IN NUMBER
                          ) RETURN BOOLEAN IS
     l_result NUMBER := 0;
  BEGIN
     IF p_demand_source_type_id IN (2,8,12) THEN
        SELECT 1
          INTO l_result
          FROM dual
         WHERE EXISTS (
                       SELECT 1
                         FROM mtl_reservations
                        WHERE organization_id = p_org_id
                          AND inventory_item_id = p_item_id
                          AND (demand_source_line_id <> p_demand_source_line_id
                               OR demand_source_line_id IS NULL)
                          AND lpn_id = p_lpn_id
                       );
     ELSIF p_demand_source_type_id IN (3,6) THEN
        SELECT 1
          INTO l_result
          FROM dual
         WHERE EXISTS (
                       SELECT 1
                         FROM mtl_reservations
                        WHERE organization_id = p_org_id
                          AND inventory_item_id = p_item_id
                          AND (demand_source_header_id <> p_demand_source_header_id
                               OR demand_source_header_id IS NULL)
                          AND lpn_id = p_lpn_id
                       );
     ELSE
        SELECT 1
          INTO l_result
          FROM dual
         WHERE EXISTS (
                       SELECT 1
                         FROM mtl_reservations
                        WHERE organization_id = p_org_id
                          AND inventory_item_id = p_item_id
                          AND (demand_source_name <> p_demand_source_name
                               OR demand_source_name IS NULL)
                          AND lpn_id = p_lpn_id
                      );
     END IF;
     IF l_result = 0 THEN
        RETURN FALSE;
     ELSE
        RETURN TRUE;
     END IF;
  EXCEPTION
     WHEN no_data_found THEN
        RETURN FALSE;
  END is_lpn_reserved;

  PROCEDURE create_lpn_reservations(
    x_return_status           OUT NOCOPY    VARCHAR2
  , x_msg_count               OUT NOCOPY    NUMBER
  , x_msg_data                OUT NOCOPY    VARCHAR2
  , p_organization_id         IN            NUMBER
  , p_inventory_item_id       IN            NUMBER
  , p_demand_source_type_id   IN            NUMBER
  , p_demand_source_header_id IN            NUMBER
  , p_demand_source_line_id   IN            NUMBER
  , p_demand_source_name      IN            VARCHAR2
  , p_need_by_date            IN            DATE
  , p_lpn_id                  IN            NUMBER
  ) IS
    l_api_name              VARCHAR2(30)                                    := 'create_lpn_reservations';
    l_revision              VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number            VARCHAR2(80);
    l_subinventory_code     VARCHAR2(10);
    l_locator_id            NUMBER;
    l_quantity              NUMBER;
    l_secondary_quantity    NUMBER;              -- INVCONV
    l_increase_quantity     NUMBER;
    l_increase_secondary    NUMBER;              -- INVCONV
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(240);
    l_query_rec             inv_reservation_global.mtl_reservation_rec_type;
    l_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
    l_dummy_sn              inv_reservation_global.serial_number_tbl_type;
    l_rsv_count             NUMBER;
    l_rsv_tbl               inv_reservation_global.mtl_reservation_tbl_type;
    l_error_code            NUMBER;
    l_primary_uom_code      VARCHAR2(3);
    l_secondary_uom_code    VARCHAR2(3);   -- INVCONV
    l_tracking_quantity_ind VARCHAR2(30);  -- INVCONV
    l_quantity_reserved     NUMBER;
    l_secondary_quantity_reserved NUMBER;  -- INVCONV
    l_reservation_id        NUMBER;
    l_total_rsv_qty         NUMBER;
    l_total_secondary_rsv_qty  NUMBER;     -- INVCONV
    l_revision_control_code NUMBER;
    l_lot_control_code      NUMBER;
    l_revision_control      BOOLEAN;
    l_lot_control           BOOLEAN;
    l_tree_id               NUMBER;
    l_qoh                   NUMBER;
    l_rqoh                  NUMBER;
    l_qr                    NUMBER;
    l_qs                    NUMBER;
    l_atr                   NUMBER;
    l_att                   NUMBER;
    l_sqoh                  NUMBER;       -- INVCONV
    l_srqoh                 NUMBER;       -- INVCONV
    l_sqr                   NUMBER;       -- INVCONV
    l_sqs                   NUMBER;       -- INVCONV
    l_satr                  NUMBER;       -- INVCONV
    l_satt                  NUMBER;       -- INVCONV
    l_reserved_qty          NUMBER;
    l_ordered_qty           NUMBER;
    l_ord_qty               NUMBER;
    l_order_qty_uom         VARCHAR2(3);
    l_lpn_reserved_qty      NUMBER;
    l_lpn_already_resv      BOOLEAN;

    CURSOR c_item_controls IS
      SELECT revision_qty_control_code
           , lot_control_code
           , primary_uom_code
           , secondary_uom_code    -- INVCONV
           , tracking_quantity_ind -- INVCONV
        FROM mtl_system_items
       WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = p_organization_id;

    CURSOR c_lpn_contents IS
      SELECT   revision
             , lot_number
             , subinventory_code
             , locator_id
             , SUM(primary_transaction_quantity)
             , SUM(secondary_transaction_quantity)    -- INVCONV
          FROM mtl_onhand_quantities_detail
         WHERE lpn_id = p_lpn_id
      GROUP BY revision, lot_number, subinventory_code, locator_id;

    --bug#2402957. added the cursor c_lpn_qty.
    CURSOR c_lpn_qty IS
    SELECT SUM(primary_transaction_quantity)
      FROM mtl_onhand_quantities_detail
     WHERE lpn_id = p_lpn_id;

    l_debug NUMBER  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      debug_print('Enter Create_LPN_Reservations');
      debug_print('OrgID = ' || p_organization_id || ' : ItemID = ' || p_inventory_item_id || ' : LPN ID = ' || p_lpn_id);
      debug_print('Demand Source - Header ID  = ' || p_demand_source_header_id || ' : Line ID = ' || p_demand_source_line_id || ' : Name = ' || p_demand_source_name || ' : Type = ' || p_demand_source_type_id);
    END IF;
    SAVEPOINT entire_lpn;
    --validate input values
    IF p_organization_id IS NULL
       OR p_inventory_item_id IS NULL
       OR p_demand_source_type_id IS NULL
       OR p_lpn_id IS NULL THEN
      IF (l_debug = 1) THEN
        debug_print('Missing input parameters');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --bug#2402957. call is_lpn_reserved to see if lpn is reserved for some other demand.
    l_lpn_already_resv := is_lpn_reserved(
                            p_org_id                  => p_organization_id
                          , p_item_id                 => p_inventory_item_id
                          , p_demand_source_type_id   => p_demand_source_type_id
                          , p_demand_source_header_id => p_demand_source_header_id
                          , p_demand_source_line_id   => p_demand_source_line_id
                          , p_demand_source_name      => p_demand_source_name
                          , p_lpn_id                  => p_lpn_id
                          );
    IF l_lpn_already_resv THEN
       IF (l_debug = 1) THEN
         debug_print('Error: LPN is reserved for some other demand line');
       END IF;
       fnd_message.set_name('INV', 'INV_CANNOT_RESERVE_LPN');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    OPEN c_item_controls;
    -- INVCONV - incorporate secondary uom and tracking quantity below
    FETCH c_item_controls INTO l_revision_control_code, l_lot_control_code,
                               l_primary_uom_code, l_secondary_uom_code, l_tracking_quantity_ind;
    CLOSE c_item_controls;

    IF l_revision_control_code = 2 THEN
      l_revision_control  := TRUE;
    ELSE
      l_revision_control  := FALSE;
    END IF;

    IF l_lot_control_code = 2 THEN
      l_lot_control  := TRUE;
    ELSE
      l_lot_control  := FALSE;
    END IF;

    --bug#2402957. get orderline qty, current reservation qty for the order line and current qty
    --reserved for the orderline by the current lpn.
    BEGIN
      SELECT nvl(ordered_quantity,0),order_quantity_uom
        INTO l_ord_qty,l_order_qty_uom
        FROM oe_order_lines_all
       WHERE line_id = p_demand_source_line_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_ord_qty := 0;
    END;
    --convert ordered qty into primary UOM.
    IF l_ord_qty <> 0 THEN
       l_ordered_qty := nvl(inv_convert.inv_um_convert(
                            item_id                      => p_inventory_item_id
                          , PRECISION                    => NULL
                          , from_quantity                => l_ord_qty
                          , from_unit                    => l_order_qty_uom
                          , to_unit                      => l_primary_uom_code
                          , from_name                    => NULL
                          , to_name                      => NULL
                          ), 0);
    END IF;

    -- {{
    -- R12: Create an LPN reservation for a sales order line that
    -- is not pick released, using an LPN that is fully available
    --
    -- Create an LPN reservation for a sales order line that is
    -- not pick released, using an LPN that is partially crossdock-
    -- pegged to another order line - should fail
    --
    -- Create an LPN reservation for a sales order line that is
    -- that is partially pegged to an LPN.  Should be able to
    -- peg the remaining order qty to the remaining LPN qty }}
    --
    SELECT nvl(sum(primary_reservation_quantity),0)
      INTO l_reserved_qty
      FROM mtl_reservations
     WHERE demand_source_line_id = p_demand_source_line_id
       AND organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id;

    SELECT nvl(sum(primary_reservation_quantity),0)
      INTO l_lpn_reserved_qty
      FROM mtl_reservations
     WHERE demand_source_line_id = p_demand_source_line_id
       AND lpn_id = p_lpn_id
       AND organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id
       AND demand_source_line_detail IS NULL;

    OPEN c_lpn_qty;
    FETCH c_lpn_qty INTO l_quantity;
    CLOSE c_lpn_qty;

    IF (l_debug = 1) THEN
      debug_print('Order Qty in Order UOM          = ' || l_ord_qty);
      debug_print('Order Qty in Primary UOM        = ' || l_ordered_qty);
      debug_print('LPN Qty in Primary UOM          = ' || l_quantity);
      debug_print('Reserved Qty in Primary UOM     = ' || l_reserved_qty);
      debug_print('LPN Reserved Qty in Primary UOM = ' || l_lpn_reserved_qty);
    END IF;

    --bug#2402957. if the reservation is for a sales/internal order. order qty will be > 0.
    IF l_ordered_qty <> 0 then
       IF l_ordered_qty = l_reserved_qty THEN
          --show error that the order is completely reserved.
          IF (l_debug = 1) THEN
            debug_print('Error: Order Line completely reserved');
          END IF;
          fnd_message.set_name('INV', 'INV_CANNOT_CREATE_RESERVATION');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
       ELSIF (l_ordered_qty - l_reserved_qty + l_lpn_reserved_qty < l_quantity)  THEN
          --error as lpn has more qty than order line.
         IF (l_debug = 1) THEN
           debug_print('Error: LPN Qty > Order Line Qty');
         END IF;
         fnd_message.set_name('INV', 'INV_LPN_QTY_GREATER');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
       END IF;
    END IF;

    -- create the quantity tree
    inv_quantity_tree_pvt.create_tree(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_true
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_organization_id            => p_organization_id
    , p_inventory_item_id          => p_inventory_item_id
    , p_tree_mode                  => inv_quantity_tree_pvt.g_reservation_mode
    , p_is_revision_control        => l_revision_control
    , p_is_lot_control             => l_lot_control
    , p_is_serial_control          => FALSE
    , p_asset_sub_only             => FALSE
    , p_include_suggestion         => TRUE
    , p_demand_source_type_id      => p_demand_source_type_id
    , p_demand_source_header_id    => p_demand_source_header_id
    , p_demand_source_line_id      => p_demand_source_line_id
    , p_demand_source_name         => p_demand_source_name
    , p_demand_source_delivery     => NULL
    , p_lot_expiration_date        => SYSDATE -- Bug#2716563
    , x_tree_id                    => l_tree_id
    );

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      IF (l_debug = 1) THEN
        debug_print('Error creating quantity tree');
      END IF;

      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF (l_debug = 1) THEN
        debug_print('Unexpected error creating quantity tree');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    OPEN c_lpn_contents;

    IF (l_debug = 1) THEN
      debug_print('Looping through each LPN contents');
    END IF;

    --for each content record in the lpn
    LOOP
      -- INVCONV - secondary_quantity below
      FETCH c_lpn_contents INTO l_revision, l_lot_number, l_subinventory_code, l_locator_id,
                                l_quantity, l_secondary_quantity;
      EXIT WHEN c_lpn_contents%NOTFOUND;

      IF (l_debug = 1) THEN
        debug_print('Fetched a LPN Record');
        debug_print(' --> Revision       : '|| l_revision);
        debug_print(' --> Lot Number     : '|| l_lot_number);
        debug_print(' --> SubInventory   : '|| l_subinventory_code);
        debug_print(' --> Locator ID     : '|| l_locator_id);
        debug_print(' --> Current Qty    : '|| l_quantity);
        debug_print(' --> Secondary Qty  : '|| l_secondary_quantity);
      END IF;

      --Query to see if this reservation already exists
      l_query_rec.organization_id           := p_organization_id;
      l_query_rec.inventory_item_id         := p_inventory_item_id;
      l_query_rec.demand_source_type_id     := p_demand_source_type_id;
      l_query_rec.demand_source_header_id   := p_demand_source_header_id;
      l_query_rec.demand_source_line_id     := p_demand_source_line_id;
      l_query_rec.demand_source_name        := p_demand_source_name;
      l_query_rec.revision                  := l_revision;
      l_query_rec.lot_number                := l_lot_number;
      l_query_rec.subinventory_code         := l_subinventory_code;
      l_query_rec.locator_id                := l_locator_id;
      l_query_rec.lpn_id                    := p_lpn_id;
      l_query_rec.demand_source_line_detail := NULL;

      IF (l_debug = 1) THEN
        debug_print('Querying for existing reservations');
      END IF;

      inv_reservation_pvt.query_reservation(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_query_input                => l_query_rec
      , x_mtl_reservation_tbl        => l_rsv_tbl
      , x_mtl_reservation_tbl_count  => l_rsv_count
      , x_error_code                 => l_error_code
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          debug_print('Error in query_reservation');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          debug_print('Unexpected error in query_reservation');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- If reservation exists
      IF l_rsv_count >= 1 THEN
        IF (l_debug = 1) THEN
          debug_print('Reservation exists');
        END IF;

        l_total_rsv_qty := 0;
        FOR l_count IN 1 .. l_rsv_count LOOP
          l_total_rsv_qty  := l_total_rsv_qty + l_rsv_tbl(l_count).primary_reservation_quantity;
          -- INVCONV BEGIN
          IF l_tracking_quantity_ind = 'PS' THEN
            l_total_secondary_rsv_qty :=
              NVL(l_total_secondary_rsv_qty,0) + l_rsv_tbl(l_count).secondary_reservation_quantity;
          END IF;
          -- INVCONV END
        END LOOP;
        l_increase_quantity  := l_quantity - l_total_rsv_qty;
        -- INVCONV BEGIN
        IF l_tracking_quantity_ind = 'PS' THEN
          l_increase_secondary := l_secondary_quantity - l_total_secondary_rsv_qty;
        END IF;
        -- INVCONV END

        -- If not all the quantity is reserved, increase reservation quantity
        IF l_increase_quantity > 0 THEN
          IF (l_debug = 1) THEN
            debug_print('Trying to increase the Reservation Qty by '|| l_increase_quantity);
            debug_print('Trying to increase the Secondary Rsv Qty by '|| l_increase_secondary); -- INVCONV
          END IF;

          --query quantity tree to make sure quantity is available to increase reservations
          inv_quantity_tree_pvt.query_tree(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_true
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , p_tree_id                    => l_tree_id
          , p_revision                   => l_revision
          , p_lot_number                 => l_lot_number
          , p_subinventory_code          => l_subinventory_code
          , p_locator_id                 => l_locator_id
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          , x_sqoh                       => l_sqoh    -- INVCONV
          , x_srqoh                      => l_srqoh   -- INVCONV
          , x_sqr                        => l_sqr     -- INVCONV
          , x_sqs                        => l_sqs     -- INVCONV
          , x_satt                       => l_satt    -- INVCONV
          , x_satr                       => l_satr    -- INVCONV
          , p_transfer_subinventory_code => NULL
          , p_cost_group_id              => NULL
          , p_lpn_id                     => p_lpn_id
          , p_transfer_locator_id        => NULL
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              debug_print('Error from query_tree');
            END IF;

            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              debug_print('Unexpected error from query_tree');
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          --Bug#2402957:
          --  If (ATR + AlreadyReserved) <> LPN Qty => LPN is reserved for some other demand, so error.
          --  This is possible only when there are Higher Level Reservations. Otherwise it will
          --  be caught at is_lpn_reserved
          IF (l_quantity <> (l_atr + l_total_rsv_qty)) THEN
             --show error that lpn is reserved for some other demand.
             IF (l_debug = 1) THEN
               debug_print('Error: LPN is reserved for some other demand line');
             END IF;
             fnd_message.set_name('INV', 'INV_CANNOT_RESERVE_LPN');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
          END IF;

          l_increase_quantity := l_atr + l_rsv_tbl(1).primary_reservation_quantity;
          -- INVCONV BEGIN
          IF l_tracking_quantity_ind = 'PS' THEN
            l_increase_secondary := l_satr + l_rsv_tbl(1).secondary_reservation_quantity;
          END IF;
          -- INVCONV END
          IF (l_debug = 1) THEN
            debug_print('New Reservation Qty = '|| l_increase_quantity);
            debug_print('New Secondary Reservation Qty = '|| l_increase_secondary);
          END IF;
          IF l_increase_quantity > 0 THEN
            l_rsv_rec                               := l_rsv_tbl(1);
            l_rsv_rec.primary_reservation_quantity  := l_increase_quantity;
            l_rsv_rec.reservation_quantity          := NULL;
            l_rsv_rec.secondary_reservation_quantity := l_increase_secondary;  -- INVCONV

            -- Call update reservation to increase quantity
            IF (l_debug = 1) THEN
              debug_print('Calling Update Reservation');
            END IF;

            inv_reservation_pvt.update_reservation(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , p_original_rsv_rec           => l_rsv_tbl(1)
            , p_to_rsv_rec                 => l_rsv_rec
            , p_original_serial_number     => l_dummy_sn
            , p_to_serial_number           => l_dummy_sn
            , p_validation_flag            => fnd_api.g_true
            );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                debug_print('Error from update_reservation');
              END IF;

              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                debug_print('Unexpected error from update_reservation');
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF; -- if new increase quantity > 0
        END IF; -- if increase quantity > 0
      ELSE --Else, create new reservation
        IF (l_debug = 1) THEN
          debug_print('Reservation doesnt exists');
        END IF;

        inv_quantity_tree_pvt.query_tree(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_true
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_tree_id                    => l_tree_id
        , p_revision                   => l_revision
        , p_lot_number                 => l_lot_number
        , p_subinventory_code          => l_subinventory_code
        , p_locator_id                 => l_locator_id
        , x_qoh                        => l_qoh
        , x_rqoh                       => l_rqoh
        , x_qr                         => l_qr
        , x_qs                         => l_qs
        , x_att                        => l_att
        , x_atr                        => l_atr
        , p_transfer_subinventory_code => NULL
        , p_cost_group_id              => NULL
        , p_lpn_id                     => p_lpn_id
        , p_transfer_locator_id        => NULL
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            debug_print('Error in query_tree');
          END IF;

          RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
            debug_print('Unexpected error in query_tree');
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        --Bug#2402957:
        --  If ATR <> LPN Qty => LPN is also reserved for some other demand, so error.
        --  This is possible only when there are Higher Level Reservations. Otherwise it will
        --  be caught at is_lpn_reserved
        IF l_quantity <> l_atr THEN
           --show error that lpn is reserved for some other demand.
           IF (l_debug = 1) THEN
             debug_print('Error: LPN is reserved for some other order line');
           END IF;
           fnd_message.set_name('INV', 'INV_CANNOT_RESERVE_LPN');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
         END IF;

        IF (l_debug = 1) THEN
          debug_print('New Reservation Qty = '|| l_quantity);
          debug_print('Secondary Reservation Qty = '|| l_secondary_quantity);
        END IF;
        IF l_quantity > 0 THEN
          --create reservation for available quantity
          l_rsv_rec.reservation_id                := NULL; -- cannot know
          l_rsv_rec.requirement_date              := p_need_by_date;
          l_rsv_rec.organization_id               := p_organization_id;
          l_rsv_rec.inventory_item_id             := p_inventory_item_id;
          l_rsv_rec.demand_source_type_id         := p_demand_source_type_id;
          l_rsv_rec.demand_source_name            := p_demand_source_name;
          l_rsv_rec.demand_source_header_id       := p_demand_source_header_id;
          l_rsv_rec.demand_source_line_id         := p_demand_source_line_id;
          l_rsv_rec.demand_source_delivery        := NULL;
          l_rsv_rec.primary_uom_code              := l_primary_uom_code;
          l_rsv_rec.primary_uom_id                := NULL;
          l_rsv_rec.secondary_uom_code            := l_secondary_uom_code;  -- INVCONV
          l_rsv_rec.secondary_uom_id              := NULL;                  -- INVCONV
          l_rsv_rec.reservation_uom_code          := l_primary_uom_code;
          l_rsv_rec.reservation_uom_id            := NULL;
          l_rsv_rec.primary_reservation_quantity  := l_quantity;
          l_rsv_rec.secondary_reservation_quantity:= l_secondary_quantity;
          l_rsv_rec.reservation_quantity          := l_quantity;
          l_rsv_rec.autodetail_group_id           := NULL;
          l_rsv_rec.external_source_code          := NULL;
          l_rsv_rec.external_source_line_id       := NULL;
          l_rsv_rec.supply_source_type_id         := inv_reservation_global.g_source_type_inv;
          l_rsv_rec.supply_source_header_id       := NULL;
          l_rsv_rec.supply_source_line_id         := NULL;
          l_rsv_rec.supply_source_name            := NULL;
          l_rsv_rec.supply_source_line_detail     := NULL;
          l_rsv_rec.revision                      := l_revision;
          l_rsv_rec.lot_number                    := l_lot_number;
          l_rsv_rec.subinventory_code             := l_subinventory_code;
          l_rsv_rec.subinventory_id               := NULL;
          l_rsv_rec.locator_id                    := l_locator_id;
          l_rsv_rec.lot_number_id                 := NULL;
          l_rsv_rec.pick_slip_number              := NULL;
          l_rsv_rec.lpn_id                        := p_lpn_id;
          l_rsv_rec.attribute_category            := NULL;
          l_rsv_rec.attribute1                    := NULL;
          l_rsv_rec.attribute2                    := NULL;
          l_rsv_rec.attribute3                    := NULL;
          l_rsv_rec.attribute4                    := NULL;
          l_rsv_rec.attribute5                    := NULL;
          l_rsv_rec.attribute6                    := NULL;
          l_rsv_rec.attribute7                    := NULL;
          l_rsv_rec.attribute8                    := NULL;
          l_rsv_rec.attribute9                    := NULL;
          l_rsv_rec.attribute10                   := NULL;
          l_rsv_rec.attribute11                   := NULL;
          l_rsv_rec.attribute12                   := NULL;
          l_rsv_rec.attribute13                   := NULL;
          l_rsv_rec.attribute14                   := NULL;
          l_rsv_rec.attribute15                   := NULL;
          l_rsv_rec.ship_ready_flag               := NULL;
          l_rsv_rec.detailed_quantity             := 0;
          -- INVCONV BEGIN
          IF l_tracking_quantity_ind = 'PS' THEN
            l_rsv_rec.secondary_detailed_quantity := 0;
          END IF;
          -- INVCONV END

          IF (l_debug = 1) THEN
            debug_print('Calling create_reservation');
          END IF;

          -- INVCONV - Upgrade call for Inventory Convergence
          inv_reservation_pvt.create_reservation(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , p_rsv_rec                    => l_rsv_rec
          , p_serial_number              => l_dummy_sn
          , x_serial_number              => l_dummy_sn
          , p_partial_reservation_flag   => fnd_api.g_true
          , p_force_reservation_flag     => fnd_api.g_false
          , p_validation_flag            => fnd_api.g_true
          , x_quantity_reserved          => l_quantity_reserved
          , x_secondary_quantity_reserved => l_secondary_quantity_reserved --INVCONV
          , x_reservation_id             => l_reservation_id
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              debug_print('Error in create_reservation');
            END IF;

            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              debug_print('Unexpected error in create_reservation');
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF; -- if quantity > 0
      END IF; -- if reservation count > 0
    END LOOP;

    CLOSE c_lpn_contents;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      debug_print('Exit Create_LPN_Reservations');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO entire_lpn;  --bug#2402957.
      IF (l_debug = 1) THEN
        debug_print('Error in Create_LPN_Reservations');
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded=> 'F');
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        debug_print('Unexpected error in Create_LPN_Reservations');
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded=> 'F');
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        debug_print('Other error in Create_LPN_Reservations');
      END IF;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded=> 'F');
  END create_lpn_reservations;

  --Transfer_LPN_Reservations
  --
  -- This API is designed to be called from the mobile subinventory transfer
  -- and putaway forms.  This procedure will transfer all the reservations
  -- for a given LPN from the current subinventory and locator to a new
  -- subinventory and locator.  This is useful for moving reserved LPNs around
  -- the warehouse.
  PROCEDURE transfer_lpn_reservations(
    x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_organization_id      IN            NUMBER
  , p_inventory_item_id    IN            NUMBER DEFAULT NULL
  , p_lpn_id               IN            NUMBER
  , p_to_subinventory_code IN            VARCHAR2
  , p_to_locator_id        IN            NUMBER
  , p_system_task_type     IN            NUMBER DEFAULT NULL -- 9794776
  ) IS
    l_api_name VARCHAR2(30) := 'transfer_lpn_reservations';
    l_debug    NUMBER;
     l_reservable_type  NUMBER;   --Bug 6007873
    l_lpn_controlled_flag  NUMBER;  --Bug 6007873
  BEGIN
    IF (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
        debug_print('In transfer_lpn_reservations');
        debug_print('p_organization_id = ' || p_organization_id);
        debug_print('p_inventory_item_id = ' || p_inventory_item_id);
        debug_print('p_lpn_id = ' || p_lpn_id);
        debug_print('p_to_subinventory_code = ' || p_to_subinventory_code);
        debug_print('p_to_locator_id = ' || p_to_locator_id);
    END IF;

    --Bug 6007873
-- 9794776	added condition for cycle count reservations

  SELECT reservable_type,lpn_controlled_flag
  INTO l_reservable_type, l_lpn_controlled_flag
  FROM mtl_secondary_inventories
  WHERE secondary_inventory_name LIKE (p_to_subinventory_code)
  AND organization_id = p_organization_id;

  IF (l_debug = 1) THEN
     debug_print('transfer_lpn_reservations:: l_reservable_type '|| l_reservable_type);
     debug_print('transfer_lpn_reservations:: l_lpn_controlled_flag '|| l_lpn_controlled_flag);
  END IF;

  ----Bug 6007873 Added if
  IF l_reservable_type = 1 THEN --transfer Sub is reservable, keep the reservation record
    IF l_lpn_controlled_flag = 1 THEN --transfer Sub is LPN controlled, keep the lpn_id stamping
	IF p_inventory_item_id IS NOT NULL THEN
	   UPDATE mtl_reservations
           SET subinventory_code = p_to_subinventory_code,
	   locator_id = p_to_locator_id
           WHERE organization_id = p_organization_id
           AND inventory_item_id = p_inventory_item_id
           AND lpn_id IN (SELECT lpn_id
                          FROM wms_license_plate_numbers
                          WHERE outermost_lpn_id = p_lpn_id OR lpn_id = p_lpn_id)
		   AND demand_source_type_id not in decode(p_system_task_type,3,null,9);  --NESTED LPN ER 7307189
        ELSE
           UPDATE mtl_reservations
           SET subinventory_code = p_to_subinventory_code,
	   locator_id = p_to_locator_id
           WHERE organization_id = p_organization_id
           AND lpn_id IN (SELECT lpn_id
                          FROM wms_license_plate_numbers
                          WHERE outermost_lpn_id = p_lpn_id OR lpn_id = p_lpn_id)
		   AND demand_source_type_id not in decode(p_system_task_type,3,null,9);  --NESTED LPN ER 7307189
       END IF;
     ELSE --transfer Sub is Non-LPN controlled, null out the lpn_id stamping as LPN will be unpacked.
	IF p_inventory_item_id IS NOT NULL THEN
	   UPDATE mtl_reservations
	   SET subinventory_code = p_to_subinventory_code,
	   locator_id = p_to_locator_id,
	   lpn_id = NULL
	   WHERE organization_id = p_organization_id
	   AND inventory_item_id = p_inventory_item_id
	   AND lpn_id IN (SELECT lpn_id
			  FROM wms_license_plate_numbers
			  WHERE outermost_lpn_id = p_lpn_id OR lpn_id = p_lpn_id)
	   AND demand_source_type_id not in decode(p_system_task_type,3,null,9);   --NESTED LPN ER 7307189
	ELSE
	   UPDATE mtl_reservations
	   SET subinventory_code = p_to_subinventory_code,
	   locator_id = p_to_locator_id,
	   lpn_id = NULL
	   WHERE organization_id = p_organization_id
	   AND lpn_id IN (SELECT lpn_id
			  FROM wms_license_plate_numbers
			  WHERE outermost_lpn_id = p_lpn_id OR lpn_id = p_lpn_id)
	   AND demand_source_type_id not in decode(p_system_task_type,3,null,9);   --NESTED LPN ER 7307189
       END IF;
     END IF;
  ELSE --Bug 6007873
   -- sub is non-reservable
   --need to delete the reservations
	IF p_inventory_item_id IS NOT NULL THEN
	      DELETE FROM mtl_reservations
	       WHERE organization_id = p_organization_id
		 AND inventory_item_id = p_inventory_item_id
		 AND lpn_id IN (SELECT lpn_id
				FROM wms_license_plate_numbers
				WHERE outermost_lpn_id = p_lpn_id OR lpn_id = p_lpn_id)
		 AND demand_source_type_id not in decode(p_system_task_type,3,null,9);   --NESTED LPN ER 7307189
	ELSE
	    DELETE FROM mtl_reservations
	    WHERE organization_id = p_organization_id
	    AND lpn_id IN (SELECT lpn_id
	                   FROM wms_license_plate_numbers
                           WHERE outermost_lpn_id = p_lpn_id OR lpn_id = p_lpn_id )
		AND demand_source_type_id not in decode(p_system_task_type,3,null,9);  --NESTED LPN  ER 7307189
	  END IF;
    END IF;

    /*** {{ R12 Enhanced reservations code changes ***/
    -- call inv_reservation_pvt.transfer_serial_rsv_in_LPN to
    -- and pass the outermost_lpn_id to transfer any serial
    -- reservations with no lpn in the same reservation in that lpn.
    inv_reservation_pvt.transfer_serial_rsv_in_LPN
       (
          x_return_status        => x_return_status
        , x_msg_count            => x_msg_count
        , x_msg_data             => x_msg_data
        , p_organization_id      => p_organization_id
        , p_inventory_item_id    => p_inventory_item_id
        , p_lpn_id               => null
        , p_outermost_lpn_id     => p_lpn_id
        , p_to_subinventory_code => p_to_subinventory_code
        , p_to_locator_id        => p_to_locator_id
       );

    IF (x_return_status = fnd_api.g_ret_sts_error) THEN
        IF (l_debug = 1) THEN
            debug_print('Error return status from transfer_serial_rsv_in_LPN');
        END IF;

        RAISE fnd_api.g_exc_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        IF (l_debug = 1) THEN
            debug_print('Unexpected return status from transfer_serial_rsv_in_LPN');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    /*** End R12 }} ***/

    inv_quantity_tree_pvt.clear_quantity_cache;

    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END transfer_lpn_reservations;


 -- ER 7307189 changes start

  --transfer_reserved_lpn_contents
  --
  -- This API is designed to be called from the mobile Move any LPN (transfer contents scenario) .
  -- This procedure will transfer all the reservations
  -- from lpn to transfer lpn ,current subinventory and locator to a new
  -- subinventory and locator.  This is useful for moving reserved LPNs around
  -- the warehouse.
  PROCEDURE transfer_reserved_lpn_contents(
    x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_organization_id      IN            NUMBER
  , p_inventory_item_id    IN            NUMBER DEFAULT NULL
  , p_lpn_id               IN            NUMBER
  , p_transfer_lpn_id      IN            NUMBER
  , p_to_subinventory_code IN            VARCHAR2
  , p_to_locator_id        IN            NUMBER
  , p_system_task_type     IN            NUMBER DEFAULT NULL -- 9794776
  ) IS
    l_api_name VARCHAR2(30) := 'transfer_reserved_lpn_contents';
    l_debug    NUMBER;
    l_reservable_type  NUMBER;
    l_lpn_controlled_flag  NUMBER;
  BEGIN
    IF (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
        debug_print('In transfer_reserved_lpn_contents');
        debug_print('transfer_reserved_lpn_contents:p_organization_id = ' || p_organization_id);
        debug_print('transfer_reserved_lpn_contents:p_lpn_id = ' || p_lpn_id);
        debug_print('transfer_reserved_lpn_contents:p_to_subinventory_code = ' || p_to_subinventory_code);
        debug_print('transfer_reserved_lpn_contents:p_to_locator_id = ' || p_to_locator_id);
        debug_print('transfer_reserved_lpn_contents:p_transfer_lpn_id = ' || p_transfer_lpn_id);
        debug_print('transfer_reserved_lpn_contents:p_inventory_item_id = ' || p_inventory_item_id);
    END IF;

	  SELECT reservable_type,lpn_controlled_flag
	  INTO l_reservable_type, l_lpn_controlled_flag
	  FROM mtl_secondary_inventories
	  WHERE secondary_inventory_name LIKE (p_to_subinventory_code)
	  AND organization_id = p_organization_id;

	  IF (l_debug = 1) THEN
	     debug_print('transfer_reserved_lpn_contents:: l_reservable_type '|| l_reservable_type);
	     debug_print('transfer_reserved_lpn_contents:: l_lpn_controlled_flag '|| l_lpn_controlled_flag);
	  END IF;


	  IF l_reservable_type = 1 THEN --transfer Sub is reservable, keep the reservation record
	    IF l_lpn_controlled_flag = 1 THEN --transfer Sub is LPN controlled, keep the lpn_id stamping
		 IF p_inventory_item_id IS NOT NULL THEN
		      UPDATE mtl_reservations
					SET subinventory_code = p_to_subinventory_code
					  , locator_id = p_to_locator_id
					  , lpn_id=p_transfer_lpn_id
				      WHERE organization_id = p_organization_id
				      AND inventory_item_id = p_inventory_item_id
				      AND lpn_id IN (SELECT lpn_id
							  FROM wms_license_plate_numbers
							WHERE outermost_lpn_id = p_lpn_id OR lpn_id = p_lpn_id )    --nested lpn
				    AND demand_source_line_detail IS NULL
					AND demand_source_type_id not in decode(p_system_task_type,3,null,9);
		 ELSE
				  UPDATE mtl_reservations
					SET subinventory_code = p_to_subinventory_code
					  , locator_id = p_to_locator_id
					  , lpn_id=p_transfer_lpn_id
				      WHERE organization_id = p_organization_id
				      AND lpn_id IN (SELECT lpn_id
							  FROM wms_license_plate_numbers
							WHERE outermost_lpn_id = p_lpn_id OR lpn_id = p_lpn_id )    --nested lpn
				    AND demand_source_line_detail IS NULL
					AND demand_source_type_id not in decode(p_system_task_type,3,null,9);
		  END IF;
	     ELSE --transfer Sub is Non-LPN controlled, null out the lpn_id stamping as LPN will be unpacked.
		 IF p_inventory_item_id IS NOT NULL THEN
				UPDATE mtl_reservations
					    SET subinventory_code = p_to_subinventory_code
					      , locator_id = p_to_locator_id
					      , lpn_id=NULL
					  WHERE organization_id = p_organization_id
					  AND inventory_item_id = p_inventory_item_id
					  AND lpn_id IN (SELECT lpn_id
							      FROM wms_license_plate_numbers
							    WHERE outermost_lpn_id = p_lpn_id OR lpn_id = p_lpn_id )    --nested lpn
					  AND demand_source_line_detail IS NULL
					  AND demand_source_type_id not in decode(p_system_task_type,3,null,9);
		 ELSE
				UPDATE mtl_reservations
					    SET subinventory_code = p_to_subinventory_code
					      , locator_id = p_to_locator_id
					      , lpn_id=NULL
					  WHERE organization_id = p_organization_id
					  AND lpn_id IN (SELECT lpn_id
							      FROM wms_license_plate_numbers
							    WHERE outermost_lpn_id = p_lpn_id OR lpn_id = p_lpn_id )    --nested lpn
					  AND demand_source_line_detail IS NULL
					  AND demand_source_type_id not in decode(p_system_task_type,3,null,9);
		 END IF;
	     END IF;
	  ELSE
		   -- sub is non-reservable
		   --need to delete the reservations
		 IF p_inventory_item_id IS NOT NULL THEN
				    DELETE FROM mtl_reservations
				    WHERE organization_id = p_organization_id
				    AND inventory_item_id = p_inventory_item_id
				    AND lpn_id IN (SELECT lpn_id
						  FROM wms_license_plate_numbers
						WHERE outermost_lpn_id = p_lpn_id OR lpn_id = p_lpn_id )
						AND demand_source_type_id not in decode(p_system_task_type,3,null,9);    --nested lpn
		 ELSE
				    DELETE FROM mtl_reservations
				    WHERE organization_id = p_organization_id
				    AND lpn_id IN (SELECT lpn_id
						  FROM wms_license_plate_numbers
						WHERE outermost_lpn_id = p_lpn_id OR lpn_id = p_lpn_id )
						AND demand_source_type_id not in decode(p_system_task_type,3,null,9);    --nested lpn
		 END IF;
	   END IF;



    -- call inv_reservation_pvt.transfer_serial_rsv_in_LPN to
    -- and pass the outermost_lpn_id to transfer any serial
    -- reservations with no lpn in the same reservation in that lpn.
    inv_reservation_pvt.transfer_serial_rsv_in_LPN
       (
          x_return_status        => x_return_status
        , x_msg_count            => x_msg_count
        , x_msg_data             => x_msg_data
        , p_organization_id      => p_organization_id
        , p_inventory_item_id    => p_inventory_item_id
        , p_lpn_id               => null
        , p_outermost_lpn_id     => p_transfer_lpn_id
        , p_to_subinventory_code => p_to_subinventory_code
        , p_to_locator_id        => p_to_locator_id
       );

    IF (x_return_status = fnd_api.g_ret_sts_error) THEN
        IF (l_debug = 1) THEN
            debug_print('transfer_reserved_lpn_contents:Error return status from transfer_serial_rsv_in_LPN');
        END IF;

        RAISE fnd_api.g_exc_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        IF (l_debug = 1) THEN
            debug_print('transfer_reserved_lpn_contents:Unexpected return status from transfer_serial_rsv_in_LPN');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    inv_quantity_tree_pvt.clear_quantity_cache;

    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END transfer_reserved_lpn_contents;

-- ER 7307189 changes end

END inv_lpn_reservations_pvt;

/
