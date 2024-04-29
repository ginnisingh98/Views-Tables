--------------------------------------------------------
--  DDL for Package Body INV_MO_BACKORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MO_BACKORDER_PVT" AS
  /* $Header: INVMOBOB.pls 120.3.12010000.2 2008/11/11 12:16:04 ksivasa ship $ */

  --  Global constant holding the package name
  g_pkg_name  CONSTANT VARCHAR2(30) := 'INV_MO_BACKORDER_PVT';
  g_version_printed    BOOLEAN      := FALSE;
  g_retain_ato_profile VARCHAR2(1)  := fnd_profile.VALUE('WSH_RETAIN_ATO_RESERVATIONS');

  PROCEDURE DEBUG(p_message IN VARCHAR2, p_module IN VARCHAR2) IS
  BEGIN
    IF NOT g_version_printed THEN
      inv_log_util.trace('$Header: INVMOBOB.pls 120.3.12010000.2 2008/11/11 12:16:04 ksivasa ship $',g_pkg_name, 9);
      g_version_printed := TRUE;
    END IF;
    inv_log_util.trace(p_message, g_pkg_name || '.' || p_module, 9);
  END;

  PROCEDURE backorder_source(
    x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_move_order_type             NUMBER
  , p_mo_line_rec                 inv_move_order_pub.trolin_rec_type
  ) IS
    l_shipping_attr      wsh_interface.changedattributetabtype;
    l_released_status    VARCHAR2(1);
    l_delivery_detail_id NUMBER;
    l_source_header_id   NUMBER;
    l_source_line_id     NUMBER;
    l_qty_to_backorder   NUMBER      := 0;
    l_second_qty_to_backorder   NUMBER;           --INVCONV dont default to zero

    CURSOR c_wsh_info IS
      SELECT delivery_detail_id, oe_header_id, oe_line_id, released_status
        FROM wsh_inv_delivery_details_v
       WHERE move_order_line_id = p_mo_line_rec.line_id
         AND move_order_line_id IS NOT NULL
         AND released_status = 'S';

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status    := fnd_api.g_ret_sts_success;
    l_qty_to_backorder := NVL(p_mo_line_rec.quantity, 0) - NVL(p_mo_line_rec.quantity_delivered, 0);
    DEBUG('l_qty_to_backorder' || l_qty_to_backorder, 'BACKORDER_SOURCE');

    /*Bug#5505709. Added the below If statement to set 'l_qty_to_backorder' to 0
      when overpicking has been done.*/
    IF (l_qty_to_backorder < 0 ) THEN
      l_qty_to_backorder := 0;
    END IF;
    -- INVCONV BEGIN
    IF p_mo_line_rec.secondary_uom is not null and p_mo_line_rec.secondary_uom <> FND_API.G_MISS_CHAR THEN
      l_second_qty_to_backorder :=
        NVL(p_mo_line_rec.secondary_quantity, 0) - NVL(p_mo_line_rec.secondary_quantity_delivered, 0);
      DEBUG('l_second_qty_to_backorder' || l_second_qty_to_backorder, 'BACKORDER_SOURCE');
   END IF;
    -- INVCONV END

    IF p_move_order_type = inv_globals.g_move_order_pick_wave THEN
       DEBUG('in mo type pick wabve' , 'BACKORDER_SOURCE');
      OPEN c_wsh_info;
      FETCH c_wsh_info INTO l_delivery_detail_id, l_source_header_id, l_source_line_id, l_released_status;
      IF c_wsh_info%NOTFOUND THEN
        CLOSE c_wsh_info;
        DEBUG('NOTFOUND c_wsh_info' , 'BACKORDER_SOURCE');
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE c_wsh_info;

        DEBUG('finished fetching' , 'BACKORDER_SOURCE');
      --Call Update_Shipping_Attributes to backorder detail line
      l_shipping_attr(1).source_header_id      := l_source_header_id;
      l_shipping_attr(1).source_line_id        := l_source_line_id;
      l_shipping_attr(1).ship_from_org_id      := p_mo_line_rec.organization_id;
      l_shipping_attr(1).released_status       := l_released_status;
      l_shipping_attr(1).delivery_detail_id    := l_delivery_detail_id;
      l_shipping_attr(1).action_flag           := 'B';
      l_shipping_attr(1).cycle_count_quantity  := l_qty_to_backorder;
      l_shipping_attr(1).cycle_count_quantity2 := l_second_qty_to_backorder;  -- INVCONV
      l_shipping_attr(1).subinventory          := p_mo_line_rec.from_subinventory_code;
      l_shipping_attr(1).locator_id            := p_mo_line_rec.from_locator_id;

      IF (l_debug = 1) THEN
        DEBUG('Calling Update Shipping Attributes', 'BACKORDER_SOURCE');
        DEBUG('  Source Header ID   = ' || l_shipping_attr(1).source_header_id, 'BACKORDER_SOURCE');
        DEBUG('  Source Line ID     = ' || l_shipping_attr(1).source_line_id, 'BACKORDER_SOURCE');
        DEBUG('  Ship From Org ID   = ' || l_shipping_attr(1).ship_from_org_id, 'BACKORDER_SOURCE');
        DEBUG('  Released Status    = ' || l_shipping_attr(1).released_status, 'BACKORDER_SOURCE');
        DEBUG('  Delivery Detail ID = ' || l_shipping_attr(1).delivery_detail_id, 'BACKORDER_SOURCE');
        DEBUG('  Action Flag        = ' || l_shipping_attr(1).action_flag, 'BACKORDER_SOURCE');
        DEBUG('  Cycle Count Qty    = ' || l_shipping_attr(1).cycle_count_quantity, 'BACKORDER_SOURCE');
        DEBUG('  Sec Cycle Count Qty= ' || l_shipping_attr(1).cycle_count_quantity2, 'BACKORDER_SOURCE'); --INVCONV
        DEBUG('  Subinventory       = ' || l_shipping_attr(1).subinventory, 'BACKORDER_SOURCE');
        DEBUG('  Locator ID         = ' || l_shipping_attr(1).locator_id, 'BACKORDER_SOURCE');
      END IF;

      wsh_interface.update_shipping_attributes(
        p_source_code        => 'INV'
      , p_changed_attributes => l_shipping_attr
      , x_return_status      => x_return_status
      );

      IF (l_debug = 1) THEN
        DEBUG('Updated Shipping Attributes - Return Status = ' || x_return_status, 'BACKORDER_SOURCE');
      END IF;

      IF (x_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

    ELSIF p_move_order_type = inv_globals.g_move_order_mfg_pick THEN
      IF l_debug = 1 THEN
        debug('Calling Unallocate WIP Material', 'BACKORDER_SOURCE');
        debug('  WIP Entity ID     = ' || p_mo_line_rec.txn_source_id, 'BACKORDER_SOURCE');
        debug('  Operation Seq Num = ' || p_mo_line_rec.txn_source_line_id, 'BACKORDER_SOURCE');
        debug('  Inventory Item ID = ' || p_mo_line_rec.inventory_item_id, 'BACKORDER_SOURCE');
        debug('  Repetitive Sch ID = ' || p_mo_line_rec.reference_id, 'BACKORDER_SOURCE');
        debug('  Primary Qty       = ' || l_qty_to_backorder, 'BACKORDER_SOURCE');
      END IF;
      wip_picking_pub.unallocate_material(
        x_return_status          => x_return_status
      , x_msg_data               => x_msg_data
      , p_wip_entity_id          => p_mo_line_rec.txn_source_id
      , p_operation_seq_num      => p_mo_line_rec.txn_source_line_id
      , p_inventory_item_id      => p_mo_line_rec.inventory_item_id
      , p_repetitive_schedule_id => p_mo_line_rec.reference_id
      , p_primary_quantity       => l_qty_to_backorder
      );
      IF (l_debug = 1) THEN
        DEBUG('Unallocated WIP Material  - Return Status = ' || x_return_status, 'BACKORDER_SOURCE');
      END IF;

      IF (x_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
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
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'BACKORDER_SOURCE');
      END IF;
  END backorder_source;

  PROCEDURE backorder(
    p_line_id       IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  ) IS
    l_mo_line_rec        inv_move_order_pub.trolin_rec_type;
    l_mold_tbl           inv_mo_line_detail_util.g_mmtt_tbl_type;
    l_mo_type            NUMBER;
    l_allow_backordering VARCHAR2(1) := 'Y';

    CURSOR c_allow_backordering IS
      SELECT 'N' FROM DUAL
       WHERE EXISTS( SELECT 1
                       FROM wms_dispatched_tasks wdt, mtl_material_transactions_temp mmtt
                      WHERE mmtt.move_order_line_id = l_mo_line_rec.line_id
                        AND wdt.transaction_temp_id = nvl(mmtt.parent_line_id, mmtt.transaction_temp_id)
                        AND wdt.status IN (4,9));

    CURSOR c_mo_type IS
      SELECT mtrh.move_order_type
        FROM mtl_txn_request_headers mtrh, mtl_txn_request_lines mtrl
       WHERE mtrl.line_id = l_mo_line_rec.line_id
         AND mtrh.header_id = mtrl.header_id;

    -- INVCONV - Incorporate secondary transaction quantity below
    CURSOR c_mmtt_info IS
      SELECT mmtt.transaction_temp_id
           , ABS(mmtt.primary_quantity) primary_quantity
           , ABS(mmtt.transaction_quantity) transaction_quantity
           , ABS(mmtt.secondary_transaction_quantity) secondary_transaction_quantity
           , mmtt.reservation_id
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.move_order_line_id = p_line_id
         AND NOT EXISTS (SELECT 1 FROM mtl_material_transactions_temp t
                          WHERE t.parent_line_id = mmtt.transaction_temp_id)
         FOR UPDATE NOWAIT;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    -- Set savepoint
    SAVEPOINT inv_start_proc;
    IF (l_debug = 1) THEN
      DEBUG('Backordering for MO Line ID = ' || p_line_id, 'BACKORDER');
    END IF;

    l_mo_line_rec := inv_trolin_util.query_row(p_line_id);

    -- Querying the Move Order Type of the Line.
    OPEN c_mo_type;
    FETCH c_mo_type INTO l_mo_type;
    CLOSE c_mo_type;

    IF (inv_install.adv_inv_installed(l_mo_line_rec.organization_id)) THEN
      OPEN c_allow_backordering;
      FETCH c_allow_backordering INTO l_allow_backordering;
      CLOSE c_allow_backordering;
    END IF;

    IF (l_debug = 1) THEN
      DEBUG('Allow BackOrdering = ' || l_allow_backordering, 'BACKORDER');
    END IF;

    IF (l_allow_backordering = 'Y') THEN
      IF NVL(l_mo_line_rec.quantity_detailed, 0) - NVL(l_mo_line_rec.quantity_delivered, 0) > 0 THEN
      DEBUG('Before for loop.. l_mmtt_info ' , 'BACKORDER');

        FOR l_mmtt_info IN c_mmtt_info LOOP
           DEBUG('In for loop.. l_mmtt_info ' , 'BACKORDER');
           DEBUG('l_mmtt_info.transaction_temp_id.. ' || l_mmtt_info.transaction_temp_id , 'BACKORDER');
           DEBUG('p_line_id.. ' || p_line_id, 'BACKORDER');
           DEBUG('l_mmtt_info.reservation_id.. ' || l_mmtt_info.reservation_id, 'BACKORDER');
           DEBUG('l_mmtt_info.transaction_quantity.. ' || l_mmtt_info.transaction_quantity, 'BACKORDER');
           DEBUG('l_mmtt_info.secondary_transaction_quantity.. ' || l_mmtt_info.secondary_transaction_quantity, 'BACKORDER'); -- INVCONV
           DEBUG('l_mmtt_info.primary_quantity.. ' || l_mmtt_info.primary_quantity, 'BACKORDER');
          -- INVCONV - add a parameter for secondary_quantity
          delete_details(
            x_return_status              => x_return_status
          , x_msg_data                   => x_msg_data
          , x_msg_count                  => x_msg_count
          , p_transaction_temp_id        => l_mmtt_info.transaction_temp_id
          , p_move_order_line_id         => p_line_id
          , p_reservation_id             => l_mmtt_info.reservation_id
          , p_transaction_quantity       => l_mmtt_info.transaction_quantity
          , p_primary_trx_qty            => l_mmtt_info.primary_quantity
          , p_secondary_trx_qty          => l_mmtt_info.secondary_transaction_quantity
          );

           dEBUG('x_return_status : ' || x_return_status, 'BACKORDER');
          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END LOOP;
      END IF;
      dEBUG('Before calling backorder_source ', 'BACKORDER');
      dEBUG('l_mo_type' || l_mo_type, 'BACKORDER');

      backorder_source(
        x_return_status   => x_return_status
      , x_msg_data        => x_msg_data
      , x_msg_count       => x_msg_count
      , p_move_order_type => l_mo_type
      , p_mo_line_rec     => l_mo_line_rec
      );
      dEBUG('x_return_status ' || x_return_status, 'BACKORDER');
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_debug = 1 THEN
        debug('Updating Move Order Line to set Status = 5 and Qty Detailed = ' || l_mo_line_rec.quantity_delivered, 'BACKORDER');
        debug('Updating Move Order Line Quantity = ' || l_mo_line_rec.quantity_delivered, 'BACKORDER');
        debug('Updating Move Order Line Secondary Qty = ' || l_mo_line_rec.secondary_quantity_delivered, 'BACKORDER'); -- INVCONV
      END IF;
      -- INVCONV BEGIN
      -- Fork the update statement below according to whether item tracks dual qty or not
      IF l_mo_line_rec.secondary_uom IS NULL THEN
        -- INVCONV Tracking in primary only
        UPDATE mtl_txn_request_lines
           SET line_status = 5
             , quantity_detailed = NVL(quantity_delivered,0)
	     , quantity = NVL(quantity_delivered,0)
         WHERE line_id = p_line_id;
      ELSE
        -- INVCONV Tracking in primary and secondary
        UPDATE mtl_txn_request_lines
           SET line_status = 5
             , quantity_detailed = NVL(quantity_delivered,0)
             , secondary_quantity_detailed = NVL(secondary_quantity_delivered,0)
	     , quantity = NVL(quantity_delivered,0)
	     , secondary_quantity = NVL(secondary_quantity_delivered,0)
        , status_date =sysdate   --BUG 6932648
         WHERE line_id = p_line_id;
      END IF;
      -- INVCONV END
    END IF; -- quantity detailed >= 0

    dEBUG('check MO type ' || l_mo_type, 'BACKORDER');
    IF l_mo_type = inv_globals.g_move_order_pick_wave THEN
    dEBUG('before calling inv_transfer_order_pvt.clean_reservations '  || l_mo_line_rec.txn_source_line_id, 'BACKORDER');
      inv_transfer_order_pvt.clean_reservations(
        p_source_line_id             => l_mo_line_rec.txn_source_line_id
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      );
    dEBUG('x_return_status ' || x_return_status, 'BACKORDER');
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Clean Reservations - Expected Error occurred', 'BACKORDER');
        END IF;
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Clean Reservations - Unexpected Error occurred', 'BACKORDER');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF l_allow_backordering = 'N' THEN
      fnd_message.set_name('WMS', 'WMS_ACTIVE_LOADED_TASKS_EXIST');
      fnd_message.set_token('LINE_ID', p_line_id);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded=> 'F');

      IF l_allow_backordering = 'Y' THEN
        ROLLBACK TO inv_start_proc;
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded=> 'F');
      ROLLBACK TO inv_start_proc;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'BACKORDER');
      END IF;

      ROLLBACK TO inv_start_proc;
  END backorder;

  PROCEDURE delete_details(
    p_transaction_temp_id  IN            NUMBER
  , p_move_order_line_id   IN            NUMBER
  , p_reservation_id       IN            NUMBER
  , p_transaction_quantity IN            NUMBER
  , p_primary_trx_qty      IN            NUMBER
  , p_secondary_trx_qty    IN            NUMBER
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  ) IS
    l_mtl_reservation_tbl       inv_reservation_global.mtl_reservation_tbl_type;
    l_mtl_reservation_rec       inv_reservation_global.mtl_reservation_rec_type;
    l_mtl_reservation_tbl_count NUMBER;
    l_original_serial_number    inv_reservation_global.serial_number_tbl_type;
    l_to_serial_number          inv_reservation_global.serial_number_tbl_type;
    l_error_code                NUMBER;
    l_count                     NUMBER;
    l_success                   BOOLEAN;
    l_umconvert_trans_quantity  NUMBER                                          := 0;
    l_mmtt_rec                  inv_mo_line_detail_util.g_mmtt_rec;
    l_primary_uom               VARCHAR2(10);
    l_ato_item                  NUMBER                                          := 0;
    l_debug                     NUMBER                                  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    l_rsv_detailed_qty NUMBER;
    l_rsv_secondary_detailed_qty NUMBER;         -- INVCONV
    l_rsv_reservation_qty NUMBER;
    l_rsv_pri_reservation_qty NUMBER;
    l_rsv_sec_reservation_qty NUMBER;            -- INVCONV

  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    IF (l_debug = 1) THEN
      DEBUG('Transaction Temp ID = ' || p_transaction_temp_id, 'DELETE_DETAILS');
      DEBUG('Move Order Line ID  = ' || p_move_order_line_id, 'DELETE_DETAILS');
      DEBUG('Transaction Qty     = ' || p_transaction_quantity, 'DELETE_DETAILS');
      DEBUG('Secondary Qty       = ' || p_secondary_trx_qty, 'DELETE_DETAILS');
      DEBUG('Reservation ID      = ' || p_reservation_id, 'DELETE_DETAILS');
    END IF;

    IF p_reservation_id IS NOT NULL THEN
      l_mtl_reservation_rec.reservation_id  := p_reservation_id;
      inv_reservation_pub.query_reservation(
        p_api_version_number         => 1.0
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_query_input                => l_mtl_reservation_rec
      , x_mtl_reservation_tbl        => l_mtl_reservation_tbl
      , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
      , x_error_code                 => l_error_code
      );

      DEBUG('x_return_status = ' || x_return_status, 'DELETE_DETAILS');
      DEBUG('l_error_code = ' || l_error_code, 'DELETE_DETAILS');
      DEBUG('l_mtl_reservation_tbl_count = ' || l_mtl_reservation_tbl_count, 'DELETE_DETAILS');
      IF (x_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      ELSIF(x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_mtl_reservation_tbl_count > 0 THEN
        -- Bug#2621481: If reservations exist, check if the item is an ATO Item
        --   only if the profile WSH_RETAIN_ATO_RESERVATIONS = 'Y'

        IF g_retain_ato_profile = 'Y' THEN
          DEBUG('g_retain_ato_profile = Y', 'DELETE_DETAILS');
         BEGIN
          SELECT 1, primary_uom_code
            INTO l_ato_item, l_primary_uom
            FROM mtl_system_items
           WHERE replenish_to_order_flag = 'Y'
             AND bom_item_type = 4
             AND inventory_item_id = l_mtl_reservation_tbl(1).inventory_item_id
             AND organization_id = l_mtl_reservation_tbl(1).organization_id;
         EXCEPTION
         WHEN OTHERS THEN
           l_ato_item := 0;
         END;
        END IF;

          DEBUG('l_ato_item = ' || l_ato_item, 'DELETE_DETAILS');

         /* Bug# 2925113 */
         l_rsv_detailed_qty := NVL(l_mtl_reservation_tbl(1).detailed_quantity,0);
         l_rsv_secondary_detailed_qty := l_mtl_reservation_tbl(1).secondary_detailed_quantity; -- INVCONV - do not use NVL
         l_rsv_reservation_qty := NVL(l_mtl_reservation_tbl(1).reservation_quantity,0);
         l_rsv_pri_reservation_qty := NVL(l_mtl_reservation_tbl(1).primary_reservation_quantity,0);
         l_rsv_sec_reservation_qty := l_mtl_reservation_tbl(1).secondary_reservation_quantity;  -- INVCONV - do not use NVL
         /* End  of 2925113 */


        IF l_ato_item = 1 THEN
          DEBUG('l_ato_item = 1', 'DELETE_DETAILS');
          -- If item is ato item, reduce the detailed quantity by the transaction
          -- quantity and retain the reservation. Convert to primary uom before
          -- reducing detailed quantity.
          l_mmtt_rec                                  := inv_mo_line_detail_util.query_row(p_transaction_temp_id);
          l_umconvert_trans_quantity                  := p_transaction_quantity;


          IF l_mmtt_rec.inventory_item_id IS NOT NULL
             AND l_mmtt_rec.transaction_uom IS NOT NULL THEN
             DEBUG('UOM Convert = ', 'DELETE_DETAILS');
            l_umconvert_trans_quantity  :=
              inv_convert.inv_um_convert(
                item_id                      => l_mmtt_rec.inventory_item_id
              , PRECISION                    => NULL
              , from_quantity                => p_transaction_quantity
              , from_unit                    => l_mmtt_rec.transaction_uom
              , to_unit                      => l_primary_uom
              , from_name                    => NULL
              , to_name                      => NULL
              );
          END IF;

          l_mtl_reservation_rec  := l_mtl_reservation_tbl(1);
          /* Bug# 2925113 */
          IF(l_rsv_detailed_qty > ABS(l_umconvert_trans_quantity)) THEN
             l_mtl_reservation_tbl(1).detailed_quantity  :=
                 l_rsv_detailed_qty - ABS(l_umconvert_trans_quantity);
            -- INVCONV BEGIN
            -- For dual control items, compute the secondary detailed
            IF l_mmtt_rec.secondary_uom_code is NOT NULL  and l_mmtt_rec.secondary_uom_code <> FND_API.G_MISS_CHAR THEN
              l_mtl_reservation_tbl(1).secondary_detailed_quantity  :=
                 l_rsv_secondary_detailed_qty - ABS(p_secondary_trx_qty);
            END IF;
            -- INVCONV END
          ELSE
             l_mtl_reservation_tbl(1).detailed_quantity  := 0;
            -- INVCONV BEGIN
            IF l_mmtt_rec.secondary_uom_code is NOT NULL THEN
              l_mtl_reservation_tbl(1).secondary_detailed_quantity  := 0;
            END IF;
            -- INVCONV END
          END IF;
          /* End of Bug# 2925113 */


          DEBUG('call inv_reservation_pub.update_reservation = ', 'DELETE_DETAILS');
          inv_reservation_pub.update_reservation(
            p_api_version_number         => 1.0
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_original_rsv_rec           => l_mtl_reservation_rec
          , p_to_rsv_rec                 => l_mtl_reservation_tbl(1)
          , p_original_serial_number     => l_original_serial_number
          , p_to_serial_number           => l_to_serial_number
          );

          DEBUG('x_return_status' || x_return_status, 'DELETE_DETAILS');
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSIF(x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE
          l_mtl_reservation_rec := l_mtl_reservation_tbl(1);
          l_mmtt_rec            := inv_mo_line_detail_util.query_row(p_transaction_temp_id);
          DEBUG('Allocation UOM  = ' || l_mmtt_rec.transaction_uom, 'DELETE_DETAILS');
          DEBUG('Reservation UOM = ' || l_mtl_reservation_rec.reservation_uom_code, 'DELETE_DETAILS');

          IF l_mmtt_rec.transaction_uom <> l_mtl_reservation_rec.reservation_uom_code THEN
            l_umconvert_trans_quantity  :=
              inv_convert.inv_um_convert(
                item_id                      => l_mmtt_rec.inventory_item_id
              , PRECISION                    => NULL
              , from_quantity                => ABS(p_transaction_quantity)
              , from_unit                    => l_mmtt_rec.transaction_uom
              , to_unit                      => l_mtl_reservation_rec.reservation_uom_code
              , from_name                    => NULL
              , to_name                      => NULL
              );

            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSIF(x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          ELSE
            l_umconvert_trans_quantity  := ABS(p_transaction_quantity);
          END IF;

          DEBUG('After UOM Conversion TxnQty = ' || l_umconvert_trans_quantity, 'DELETE_DETAILS');

          /* Bug# 2925113 */
          IF(l_rsv_detailed_qty > ABS(p_transaction_quantity)) THEN
            l_mtl_reservation_tbl(1).detailed_quantity :=
                l_rsv_detailed_qty - ABS(p_transaction_quantity);
            -- INVCONV BEGIN
            -- For dual control items, compute the secondary detailed
            IF l_mmtt_rec.secondary_uom_code is NOT NULL  and l_mmtt_rec.secondary_uom_code <> FND_API.G_MISS_CHAR THEN
              l_mtl_reservation_tbl(1).secondary_detailed_quantity  :=
                l_rsv_secondary_detailed_qty - ABS(p_secondary_trx_qty);
            END IF;
            -- INVCONV END
          ELSE
             l_mtl_reservation_tbl(1).detailed_quantity := 0;
            -- INVCONV BEGIN
            -- For dual control items, zero the secondary detailed
            IF l_mmtt_rec.secondary_uom_code is NOT NULL  and l_mmtt_rec.secondary_uom_code <> FND_API.G_MISS_CHAR THEN
              l_mtl_reservation_tbl(1).secondary_detailed_quantity  := 0;
            END IF;
            -- INVCONV END
          END IF;

          IF(l_rsv_reservation_qty > ABS(l_umconvert_trans_quantity)) THEN
             l_mtl_reservation_tbl(1).reservation_quantity :=
                l_rsv_reservation_qty - ABS(l_umconvert_trans_quantity);
            -- INVCONV BEGIN
            -- For dual control items, compute the secondary reservation qty
            IF l_mmtt_rec.secondary_uom_code is NOT NULL  and l_mmtt_rec.secondary_uom_code <> FND_API.G_MISS_CHAR THEN
              l_mtl_reservation_tbl(1).secondary_reservation_quantity :=
                l_rsv_sec_reservation_qty - ABS(p_secondary_trx_qty);
            END IF;
            -- INVCONV END
          ELSE
            l_mtl_reservation_tbl(1).reservation_quantity := 0;
            -- INVCONV BEGIN
            -- For dual control items, zero the secondary reservation qty
            IF l_mmtt_rec.secondary_uom_code is NOT NULL  and l_mmtt_rec.secondary_uom_code <> FND_API.G_MISS_CHAR THEN
              l_mtl_reservation_tbl(1).secondary_reservation_quantity := 0;
            END IF;
            -- INVCONV END
          END IF;

          IF(l_rsv_pri_reservation_qty > ABS(p_primary_trx_qty)) THEN
             l_mtl_reservation_tbl(1).primary_reservation_quantity :=
                l_rsv_pri_reservation_qty - ABS(p_primary_trx_qty);
          ELSE
             l_mtl_reservation_tbl(1).primary_reservation_quantity := 0;
          END IF;
          /* End of Bug# 2925113 */

          inv_reservation_pub.update_reservation(
            p_api_version_number         => 1.0
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_original_rsv_rec           => l_mtl_reservation_rec
          , p_to_rsv_rec                 => l_mtl_reservation_tbl(1)
          , p_original_serial_number     => l_original_serial_number
          , p_to_serial_number           => l_to_serial_number
          );

          DEBUG('x_return_status from inv_reservation_pub.update_reservation ' || x_return_status , 'DELETE_DETAILS');
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSIF(x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF; -- reservation count > 0
      END IF; -- ato item check
    END IF;

    /* Bug 5474441 Commenting out the revert locator capacity as updation of locator          does not happen during pic release  */
    /*
    -- Bug 5361517
        debug('l_mmtt_rec.transaction_action_id = ' || l_mmtt_rec.transaction_action_id,'delete_details');
        debug('l_mmtt_rec.transaction_status = ' || l_mmtt_rec.transaction_status,'delete_details');

    IF ((l_mmtt_rec.transaction_status = 2)
       AND (l_mmtt_rec.transaction_action_id = INV_GLOBALS.G_ACTION_STGXFR))
    THEN

         inv_loc_wms_utils.revert_loc_suggested_capacity
              (
                 x_return_status              => x_return_status
               , x_msg_count                  => x_msg_count
               , x_msg_data                   => x_msg_data
               , p_organization_id            => l_mmtt_rec.organization_id
               , p_inventory_location_id      => l_mmtt_rec.transfer_to_location
               , p_inventory_item_id          => l_mmtt_rec.inventory_item_id
               , p_primary_uom_flag           => 'Y'
               , p_transaction_uom_code       => NULL
               , p_quantity                   => p_transaction_quantity
               );
        IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
    END IF;

    -- End  Bug 5361517
      */
      /* End of Bug 5474441 */

    DEBUG('call inv_trx_util_pub.delete_transaction ' , 'DELETE_DETAILS');
    inv_trx_util_pub.delete_transaction(
      x_return_status       => x_return_status
    , x_msg_data            => x_msg_data
    , x_msg_count           => x_msg_count
    , p_transaction_temp_id => p_transaction_temp_id
    );

    DEBUG('x_return_status ' || x_return_status , 'DELETE_DETAILS');
    IF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    ELSIF(x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
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
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'DELETE_DETAILS');
      END IF;
  END delete_details;

END inv_mo_backorder_pvt;

/
