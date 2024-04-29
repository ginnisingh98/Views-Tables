--------------------------------------------------------
--  DDL for Package Body INV_TRANSFER_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRANSFER_ORDER_PVT" AS
  /* $Header: INVVTROB.pls 120.34.12010000.11 2010/01/06 09:20:13 jianxzhu ship $ */

  --  Global constant holding the package name
  g_pkg_name       CONSTANT VARCHAR2(30)            := 'INV_Transfer_Order_PVT';
  isdebug                   BOOLEAN                 := TRUE;
     debug_mode                NUMBER                  := 1;
  g_is_pickrelease_set         NUMBER;
  g_debug                      NUMBER;

  g_retain_ato_profile VARCHAR2(1) := FND_PROFILE.VALUE('WSH_RETAIN_ATO_RESERVATIONS');
  --Bug 1620576
  --These tables are needed in Finalize_Pick_Confirm for overpicking.
  TYPE mo_picked_quantity_rec IS RECORD(
    picked_quantity               NUMBER
  , primary_picked_quantity       NUMBER
  , picked_uom                    VARCHAR2(3) --Bug5950172
  , sec_picked_quantity           NUMBER
  );

  TYPE rsv_picked_quantity_rec IS RECORD(
    picked_quantity               NUMBER
  , sec_picked_quantity           NUMBER
  );

  -- Bug 5535030: PICK RELEASE PERFORMANCE ISSUES
  TYPE sub_reservable_rec_type IS RECORD(
    reservable_type   NUMBER
  , org_id            NUMBER
  , subinventory_code VARCHAR2(10)
  );

  TYPE mo_picked_quantity_tbl IS TABLE OF mo_picked_quantity_rec
    INDEX BY BINARY_INTEGER;

  TYPE rsv_picked_quantity_tbl IS TABLE OF rsv_picked_quantity_rec
    INDEX BY BINARY_INTEGER;

  -- Bug 5535030: PICK RELEASE PERFORMANCE ISSUES
  TYPE sub_reservable_type IS TABLE OF sub_reservable_rec_type
    INDEX BY BINARY_INTEGER;

  g_mo_picked_quantity_tbl  mo_picked_quantity_tbl;
  g_rsv_picked_quantity_tbl rsv_picked_quantity_tbl;

  -- Bug 5535030: PICK RELEASE PERFORMANCE ISSUES
  g_is_sub_reservable       sub_reservable_type;

  --Bug :4994950(Actual bug #4762505)
  --Caching MMTT records that were already processed for this MO line
  --This will be used to close the move order line
  TYPE mmtt_tbl_tp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_mmtt_cache_tbl mmtt_tbl_tp;

  -- Bug 5074402
  g_omh_installed               NUMBER;
  PROCEDURE DEBUG(p_message IN VARCHAR2, p_module IN VARCHAR2) IS
    --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF  isdebug AND debug_mode = 1 THEN
      --inv_debug.message(p_message);
      --null;
      --inv_trx_util_pub.trace(p_message, p_module, 3);
      inv_pick_wave_pick_confirm_pub.tracelog(p_message, p_module);
      gmi_reservation_util.println(p_module||p_message);
    ELSIF  isdebug AND debug_mode = 2 THEN
      --dbms_output.put_line(p_message);
      NULL;
    END IF;
  END;

  PROCEDURE increment_max_line_number IS
  BEGIN
    inv_globals.g_max_line_num  := NVL(inv_globals.g_max_line_num, 0) + 1;
  --debug('Line Num:'||to_char(Inv_Globals.g_max_line_num));
  END increment_max_line_number;

  PROCEDURE reset_max_line_number IS
  BEGIN
    inv_globals.g_max_line_num  := NULL;
  --debug('Line Num:'||to_char(Inv_Globals.g_max_line_num));
  END reset_max_line_number;

  FUNCTION get_next_header_id(p_organization_id NUMBER := NULL)
    RETURN NUMBER IS
    l_header_id         NUMBER;
    l_dummy             VARCHAR2(1);
    l_request_number_ok BOOLEAN     := FALSE;
  BEGIN
    WHILE NOT l_request_number_ok LOOP
      SELECT mtl_txn_request_headers_s.NEXTVAL
        INTO l_header_id
        FROM DUAL;

      BEGIN
        SELECT 'X'
          INTO l_dummy
          FROM mtl_txn_request_headers
         WHERE request_number = TO_CHAR(l_header_id)
           AND organization_id = NVL(p_organization_id, organization_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_request_number_ok  := TRUE;
      END;
    END LOOP;

    RETURN l_header_id;
  END get_next_header_id;

  FUNCTION unique_order(p_organization_id IN NUMBER, p_request_number IN VARCHAR2)
    RETURN BOOLEAN IS
    l_dummy VARCHAR2(1);
  BEGIN
    SELECT 'X'
      INTO l_dummy
      FROM mtl_txn_request_headers
     WHERE request_number = p_request_number
       AND organization_id = p_organization_id;

    RETURN FALSE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN TRUE;
  END unique_order;

  FUNCTION unique_line(p_organization_id IN NUMBER, p_header_id IN NUMBER, p_line_number IN NUMBER)
    RETURN BOOLEAN IS
    l_dummy VARCHAR2(1);
  BEGIN
    SELECT 'X'
      INTO l_dummy
      FROM mtl_txn_request_lines
     WHERE header_id = p_header_id
       AND organization_id = p_organization_id
       AND line_number = p_line_number;

    RETURN FALSE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN TRUE;
  END unique_line;

  FUNCTION get_primary_quantity(p_item_id IN NUMBER, p_organization_id IN NUMBER, p_from_quantity IN NUMBER, p_from_unit IN VARCHAR2)
    RETURN NUMBER IS
    l_primary_uom      VARCHAR2(3);
    l_primary_quantity NUMBER;
  BEGIN
    SELECT primary_uom_code
      INTO l_primary_uom
      FROM mtl_system_items
     WHERE organization_id = p_organization_id
       AND inventory_item_id = p_item_id;

    l_primary_quantity  := inv_convert.inv_um_convert(item_id => p_item_id, PRECISION => NULL, from_quantity => p_from_quantity, from_unit => p_from_unit, to_unit => l_primary_uom, from_name => NULL, to_name => NULL);
    RETURN l_primary_quantity;
  END get_primary_quantity;

  PROCEDURE delete_troldt(x_return_status OUT NOCOPY VARCHAR2, x_msg_data OUT NOCOPY VARCHAR2, x_msg_count OUT NOCOPY NUMBER, p_troldt_tbl IN inv_mo_line_detail_util.g_mmtt_tbl_type, p_move_order_type IN NUMBER) IS
    l_troldt_tbl            inv_mo_line_detail_util.g_mmtt_tbl_type;
    l_mtl_reservation       inv_reservation_global.mtl_reservation_tbl_type;
    l_mtl_reservation_count NUMBER;
    l_rsv_temp_rec          inv_reservation_global.mtl_reservation_rec_type;
    l_to_rsv_rec            inv_reservation_global.mtl_reservation_rec_type;
    l_dummy_sn              inv_reservation_global.serial_number_tbl_type;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_error_code            NUMBER;
    l_return_status         VARCHAR2(1);
    l_success               BOOLEAN;
  BEGIN
    l_troldt_tbl     := p_troldt_tbl;

    FOR l_counter IN 1 .. l_troldt_tbl.COUNT LOOP
      -- if this is a pick wave move order, update the reservation first
      IF (p_move_order_type = 3) THEN
        l_rsv_temp_rec.reservation_id   := l_troldt_tbl(l_counter).reservation_id;
        inv_reservation_pub.query_reservation(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_true
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_query_input                => l_rsv_temp_rec
        , x_mtl_reservation_tbl        => l_mtl_reservation
        , x_mtl_reservation_tbl_count  => l_mtl_reservation_count
        , x_error_code                 => l_error_code
        );

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        l_rsv_temp_rec                  := l_mtl_reservation(1);
        l_to_rsv_rec                    := l_mtl_reservation(1);
        l_to_rsv_rec.detailed_quantity  := l_to_rsv_rec.detailed_quantity - l_troldt_tbl(l_counter).transaction_quantity;


--INVCONV - Make sure Qty2 are NULL if nor present
        IF (  l_to_rsv_rec.secondary_uom_code IS NULL ) THEN
              l_to_rsv_rec.secondary_reservation_quantity := NULL;
              l_to_rsv_rec.secondary_detailed_quantity    := NULL;
        END IF;

        inv_reservation_pub.update_reservation(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_true
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_original_rsv_rec           => l_rsv_temp_rec
        , p_to_rsv_rec                 => l_to_rsv_rec
        , p_original_serial_number     => l_dummy_sn
        , p_to_serial_number           => l_dummy_sn
        , p_validation_flag            => fnd_api.g_true
        );

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      BEGIN
        inv_replenish_detail_pub.clear_record(p_trx_tmp_id => l_troldt_tbl(l_counter).transaction_temp_id,
                                              p_success => l_success);
        if( not l_success ) then
          raise FND_API.G_EXC_ERROR;
        end if;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END;
      inv_mo_line_detail_util.delete_row(x_return_status => l_return_status, p_line_id => l_troldt_tbl(l_counter).move_order_line_id, p_line_detail_id => l_troldt_tbl(l_counter).transaction_temp_id);
    END LOOP;

    x_return_status  := l_return_status;
    x_msg_data       := l_msg_data;
    x_msg_count      := l_msg_count;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RAISE;
    WHEN fnd_api.g_exc_unexpected_error THEN
      RAISE;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Trolins');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END delete_troldt;

  PROCEDURE update_lots_temp(
    x_return_status    OUT NOCOPY VARCHAR2
  , x_msg_data         OUT NOCOPY VARCHAR2
  , x_msg_count        OUT NOCOPY NUMBER
  , p_operation            VARCHAR2
  , p_item_id              NUMBER
  , p_org_id               NUMBER
  , p_trx_temp_id          NUMBER
  , p_cancel_qty           NUMBER
  , p_trx_uom              VARCHAR2
  , p_primary_uom          VARCHAR2
  , p_last_updated_by      NUMBER
  , p_last_update_date     DATE
  , p_creation_date        DATE
  , p_created_by           NUMBER
  ) IS
    l_mtlt_cancel_qty  NUMBER;
    l_mtlt_trx_qty     NUMBER;
    l_mtlt_sec_trx_qty NUMBER; --INVCONV
    l_lot_count        NUMBER;
    l_mtlt_primary_qty NUMBER;
    l_lot_number       VARCHAR2(80);
    l_tracking_quantity_ind VARCHAR2(30);
    l_secondary_uom_code VARCHAR2(10);
    l_sec_quantity_cancel NUMBER;

    CURSOR c_mtlt IS
      SELECT        transaction_quantity,
                    secondary_quantity         --INVCONV
                    , lot_number -- nsinghi bug#5724815.
               FROM mtl_transaction_lots_temp
              WHERE transaction_temp_id = p_trx_temp_id
           ORDER BY creation_date
      FOR UPDATE OF transaction_temp_id;

    -- nsinghi bug#5724815 Added new cursor to fetch the secondary uom code for item
    CURSOR c_get_sec_uom IS
      SELECT tracking_quantity_ind, secondary_uom_code
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = p_item_id
      AND    organization_id = p_org_id;

    l_debug number;
  BEGIN
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF p_operation = 'DELETE' THEN -- when cancel qty >sum(mmtt trx qty)
      IF (l_debug = 1) THEN
         DEBUG('Deleting the row in mtlt ', 'UPDATE LOTS TEMP');
      END IF;

      DELETE FROM mtl_transaction_lots_temp
            WHERE transaction_temp_id = p_trx_temp_id;
    ELSIF p_operation = 'UPDATE' THEN -- when cancel qty < sum(mmtt trx qty)
      SELECT COUNT(*)
        INTO l_lot_count
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_trx_temp_id;

      -- nsinghi bug#5724815
      OPEN c_get_sec_uom;
      FETCH c_get_sec_uom INTO l_tracking_quantity_ind, l_secondary_uom_code;
      CLOSE c_get_sec_uom;

      OPEN c_mtlt;
      l_mtlt_cancel_qty  := p_cancel_qty;

      FOR i IN 1 .. l_lot_count LOOP
--        FETCH c_mtlt INTO l_mtlt_trx_qty, l_mtlt_sec_trx_qty;
        FETCH c_mtlt INTO l_mtlt_trx_qty, l_mtlt_sec_trx_qty, l_lot_number;

        IF l_mtlt_trx_qty <= l_mtlt_cancel_qty THEN
          l_mtlt_cancel_qty  := l_mtlt_cancel_qty - l_mtlt_trx_qty;
          IF (l_debug = 1) THEN
             DEBUG('Delete current row ', 'UPDATE LOTS TEMP');
          END IF;

          -- Delete the current row from mtlt since mtlt cancel qty > mtlt trx qty
          DELETE FROM mtl_transaction_lots_temp
                WHERE  CURRENT OF c_mtlt;
        ELSIF l_mtlt_trx_qty > l_mtlt_cancel_qty THEN
          IF (l_debug = 1) THEN
             DEBUG('Update current row ', 'UPDATE LOTS TEMP');
          END IF;
          -- update the mtlt row from mtlt since mtlt cancel qty < mtlt trx qty
          l_mtlt_trx_qty      := l_mtlt_trx_qty - l_mtlt_cancel_qty;
          -- nsinghi bug#5724815 Determine the secondary qty to be deducted from mtlt
          -- START
          IF NVL(l_tracking_quantity_ind, 'P') = 'PS' AND l_mtlt_sec_trx_qty IS NOT NULL THEN
            l_sec_quantity_cancel := inv_convert.inv_um_convert
                            (       item_id => p_item_id,
                                    lot_number => l_lot_number,
                                    organization_id => p_org_id,
                                    PRECISION => NULL,
                                    from_quantity => l_mtlt_cancel_qty,
                                    from_unit => p_trx_uom,
                                    to_unit => l_secondary_uom_code,
                                    from_name => NULL,
                                    to_name => NULL
                            );
            IF (l_sec_quantity_cancel = -99999) THEN
              IF (l_debug = 1) THEN
                 DEBUG('Cannot convert uom to secondary uom', 'UPDATE LOTS TEMP');
              END IF;
              fnd_message.set_name('INV', 'INV_INVALID_UOM_CONV');
              fnd_message.set_token('VALUE1', l_secondary_uom_code);
              fnd_message.set_token('VALUE2', p_trx_uom);
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_mtlt_sec_trx_qty := l_mtlt_sec_trx_qty - l_sec_quantity_cancel;
            IF l_mtlt_sec_trx_qty < 0 THEN
               l_mtlt_sec_trx_qty := 0;
            END IF;
          END IF;
          -- END

          l_mtlt_primary_qty  := inv_convert.inv_um_convert(item_id => p_item_id, PRECISION => NULL, from_quantity => l_mtlt_trx_qty, from_unit => p_trx_uom, to_unit => p_primary_uom, from_name => NULL, to_name => NULL);

          UPDATE mtl_transaction_lots_temp
             SET transaction_quantity = l_mtlt_trx_qty
               , secondary_quantity = l_mtlt_sec_trx_qty -- INVCONV
               , primary_quantity = l_mtlt_primary_qty
               , last_update_date = p_last_update_date
               , last_updated_by = p_last_updated_by
               , creation_date = p_creation_date
               , created_by = p_created_by
           WHERE  CURRENT OF c_mtlt;

          l_mtlt_cancel_qty   := 0;
        END IF;

        IF l_mtlt_cancel_qty <= 0 THEN
          RETURN;
        END IF;
      END LOOP;
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
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'update lots temp');
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END update_lots_temp;

  -- bug 2195303

  PROCEDURE update_serial_temp(x_return_status OUT NOCOPY VARCHAR2, x_msg_data OUT NOCOPY VARCHAR2, x_msg_count OUT NOCOPY NUMBER, p_operation VARCHAR2, p_trx_temp_id NUMBER, p_cancel_qty NUMBER) IS
    l_serial_temp_id        NUMBER;
    l_serial_count          NUMBER;
    del_serial_number       NUMBER       := 0;
    l_header_id             NUMBER       := -1;
    unmarked_value          NUMBER       := -1;
    l_fm_serial_number      VARCHAR2(10);
    l_to_serial_number      VARCHAR2(10);
    l_transaction_header_id NUMBER;

    CURSOR serial_temp_csr IS
      SELECT        fm_serial_number
                  , to_serial_number
                  , group_header_id
               FROM mtl_serial_numbers_temp
              WHERE transaction_temp_id = p_trx_temp_id
           ORDER BY fm_serial_number DESC
      FOR UPDATE OF transaction_temp_id;
  BEGIN
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    IF p_operation = 'DELETE' THEN -- when cancel qty >sum(mmtt trx qty)
      DELETE FROM mtl_serial_numbers_temp
            WHERE transaction_temp_id = p_trx_temp_id;
    ELSIF p_operation = 'UPDATE' THEN -- when cancel qty < sum(mmtt trx qty)
      SELECT transaction_header_id
        INTO l_transaction_header_id
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_trx_temp_id;

      SELECT COUNT(*)
        INTO l_serial_count
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = p_trx_temp_id;

      IF (l_serial_count > 0) THEN
        -- dbms_output.put_line('inside serial count> 0');
        FOR i IN 1 .. l_serial_count LOOP
          OPEN serial_temp_csr;
          FETCH serial_temp_csr INTO l_fm_serial_number, l_to_serial_number, l_header_id;

          IF l_to_serial_number IS NOT NULL THEN
            IF l_to_serial_number = l_fm_serial_number THEN
              --ranges individually assigned ranges
              DELETE FROM mtl_serial_numbers_temp
                    WHERE  CURRENT OF serial_temp_csr;

             /*** {{ R12 Enhanced reservations code changes,
              *** call serial_check.inv_unmark_rsv_serial instead of update msn directly
              UPDATE mtl_serial_numbers
                 SET line_mark_id = unmarked_value
                   , group_mark_id = unmarked_value
                   , lot_line_mark_id = unmarked_value
               WHERE group_mark_id IN (p_trx_temp_id, l_transaction_header_id)
                 AND serial_number >= NVL(l_fm_serial_number, serial_number)
                 AND serial_number <= NVL(l_to_serial_number, NVL(l_fm_serial_number, serial_number))
                 AND LENGTH(serial_number) = LENGTH(NVL(l_fm_serial_number, serial_number));
              *** End R12 }} ***/

             /*** {{ R12 Enhanced reservations code changes ***/
              serial_check.inv_unmark_rsv_serial
                 (from_serial_number   => l_fm_serial_number
                 ,to_serial_number     => l_to_serial_number
                 ,serial_code          => null
                 ,hdr_id               => l_transaction_header_id
                 ,temp_id              => p_trx_temp_id
                 ,p_update_reservation => fnd_api.g_true);
             /*** End R12 }} ***/

              del_serial_number  := del_serial_number + 1;

              --dbms_output.put_line('Del serial number'||Del_serial_number);

              IF del_serial_number = p_cancel_qty THEN
                --dbms_output.put_line('Del serial number = cancel_qty'||Del_serial_number);
                RETURN;
              END IF;
            END IF; -- end if range individually assigned serials
          END IF; -- end if l_to_serial number null check

          CLOSE serial_temp_csr;
        END LOOP;
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
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'update serial temp');
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END update_serial_temp;

  PROCEDURE update_troldt(
    x_return_status   OUT    NOCOPY VARCHAR2
  , x_msg_data        OUT    NOCOPY VARCHAR2
  , x_msg_count       OUT    NOCOPY NUMBER
  , p_trolin_rec      IN     inv_move_order_pub.trolin_rec_type
  , p_old_trolin_rec  IN     inv_move_order_pub.trolin_rec_type
  , p_troldt_tbl      IN     inv_mo_line_detail_util.g_mmtt_tbl_type
  , p_move_order_type IN     NUMBER
  , x_trolin_rec      IN OUT    NOCOPY inv_move_order_pub.trolin_rec_type
  , p_delete_mmtt     IN     VARCHAR2 DEFAULT 'YES'  --Added bug3524130
  ) IS
    l_troldt_tbl            inv_mo_line_detail_util.g_mmtt_tbl_type;
    l_trolin_rec            inv_move_order_pub.trolin_rec_type;
    l_old_trolin_rec        inv_move_order_pub.trolin_rec_type;
    l_quantity_cancel       NUMBER;
    l_mtl_reservation       inv_reservation_global.mtl_reservation_tbl_type;
    l_mtl_reservation_count NUMBER;
    l_rsv_temp_rec          inv_reservation_global.mtl_reservation_rec_type;
    l_to_rsv_rec            inv_reservation_global.mtl_reservation_rec_type;
    l_dummy_sn              inv_reservation_global.serial_number_tbl_type;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_error_code            NUMBER;
    l_return_status         VARCHAR2(1);
    --    l_move_order_type             NUMBER;
    l_rsv_quantity          NUMBER;
    l_transaction_qty       NUMBER;
    l_transaction_uom       VARCHAR2(3);
    l_primary_qty           NUMBER;
    l_primary_uom           VARCHAR2(3);
    l_lot_control_code      NUMBER;
    l_serial_control_code   NUMBER;
    l_debug number;
    l_success               BOOLEAN;
    l_secondary_uom_qty     NUMBER;
    l_sec_quantity_cancel   NUMBER;
  BEGIN
    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    l_trolin_rec      := p_trolin_rec;
    l_old_trolin_rec  := p_old_trolin_rec;
    l_troldt_tbl      := p_troldt_tbl;

    -- if the update is update quantity and decrease the quantity
    IF (l_trolin_rec.quantity < l_old_trolin_rec.quantity) THEN
      IF (l_trolin_rec.quantity <= 0) THEN
        l_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
      END IF;

      l_quantity_cancel               := l_old_trolin_rec.quantity - l_trolin_rec.quantity;

      IF (l_quantity_cancel > (l_trolin_rec.quantity - l_trolin_rec.quantity_delivered)) THEN
        l_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
      END IF;

      l_trolin_rec.quantity_detailed  := l_trolin_rec.quantity_detailed - l_quantity_cancel;
      -- nsinghi bug#5724815 Update the secondary_quantity_detailed also. Fetch l_quantity_cancel in sec uom and deduct from secondary_quantity_detailed.
      -- START
      IF l_old_trolin_rec.secondary_uom IS NOT NULL THEN
        l_sec_quantity_cancel := inv_convert.inv_um_convert
                        (       item_id => l_old_trolin_rec.inventory_item_id,
                                PRECISION => NULL,
                                from_quantity => l_quantity_cancel,
                                from_unit => l_trolin_rec.uom_code,
                                to_unit => l_old_trolin_rec.secondary_uom,
                                from_name => NULL,
                                to_name => NULL
                        );

        IF (l_sec_quantity_cancel = -99999) THEN
          IF (l_debug = 1) THEN
             DEBUG('Cannot convert uom to secondary uom', 'UPDATE TROLNDT ');
          END IF;
          fnd_message.set_name('INV', 'INV_INVALID_UOM_CONV');
          fnd_message.set_token('VALUE1', l_old_trolin_rec.secondary_uom);
          fnd_message.set_token('VALUE2', l_trolin_rec.uom_code);
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        IF l_trolin_rec.secondary_quantity_detailed IS NOT NULL THEN
           l_trolin_rec.secondary_quantity_detailed := l_trolin_rec.secondary_quantity_detailed - l_sec_quantity_cancel;
	   IF l_trolin_rec.secondary_quantity_detailed < 0 THEN
	      l_trolin_rec.secondary_quantity_detailed := 0;
	   END IF;
        END IF;
      END IF;
      -- END

      IF (l_debug = 1) THEN
         DEBUG(l_quantity_cancel, 'UPDATE TROLNDT ');
      END IF;
    END IF;

    IF (l_old_trolin_rec.quantity <> l_trolin_rec.quantity
        OR l_old_trolin_rec.quantity_detailed <> l_trolin_rec.quantity_detailed
        OR l_old_trolin_rec.line_status <> l_trolin_rec.line_status
       ) THEN
      FOR l_counter IN 1 .. l_troldt_tbl.COUNT LOOP -- Start of FOR LOOP
        -- get the reservation record if this is a pick wave move order
        IF (l_debug = 1) THEN
           DEBUG('inside the loop', 'UPDATE TROLNDT');
        END IF;

        SELECT lot_control_code
             , serial_number_control_code
          INTO l_lot_control_code
             , l_serial_control_code
          FROM mtl_system_items
         WHERE inventory_item_id = l_troldt_tbl(l_counter).inventory_item_id
           AND organization_id = l_troldt_tbl(l_counter).organization_id;

        IF (l_debug = 1) THEN
           DEBUG('Lot control code '|| TO_CHAR(l_lot_control_code), 'UPDATE TROLNDT');
        END IF;

        IF (p_move_order_type = 3) THEN
          l_rsv_temp_rec.reservation_id  := l_troldt_tbl(l_counter).reservation_id;
          inv_reservation_pub.query_reservation(
            p_api_version_number         => 1.0
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , p_query_input                => l_rsv_temp_rec
          , x_mtl_reservation_tbl        => l_mtl_reservation
          , x_mtl_reservation_tbl_count  => l_mtl_reservation_count
          , x_error_code                 => l_error_code
          );

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          l_to_rsv_rec                   := l_mtl_reservation(1);
          l_rsv_temp_rec                 := l_mtl_reservation(1);
        END IF;

        IF (l_trolin_rec.quantity < l_old_trolin_rec.quantity) THEN
          IF (l_debug = 1) THEN
             DEBUG('inside the decrease quantity condition', 'UPDATE TROLNDT');
          END IF;

          /* decrease quantity request on the move order line
          we need to see if any detail exists for this move order line,
          if detail exist, we need to delete the line detail for the delta quantity
          and update the detailed_qty on reservation if it exist for the particular detail record */
          IF (l_troldt_tbl(l_counter).transaction_quantity <= l_quantity_cancel) THEN
            IF (l_debug = 1) THEN
               DEBUG('delete detail row', 'UPDATE TROLNDT');
            END IF;

            IF l_lot_control_code = 2 THEN
              update_lots_temp(
                x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
              , p_operation                  => 'DELETE'
              , p_item_id                    => l_troldt_tbl(l_counter).inventory_item_id
              , p_org_id                     => l_troldt_tbl(l_counter).organization_id
              , p_trx_temp_id                => l_troldt_tbl(l_counter).transaction_temp_id
              , p_cancel_qty                 => l_quantity_cancel
              , p_trx_uom                    => l_troldt_tbl(l_counter).transaction_uom
              , p_primary_uom                => l_troldt_tbl(l_counter).item_primary_uom_code
              , p_last_updated_by            => l_troldt_tbl(l_counter).last_updated_by
              , p_last_update_date           => l_troldt_tbl(l_counter).last_update_date
              , p_creation_date              => l_troldt_tbl(l_counter).creation_date
              , p_created_by                 => l_troldt_tbl(l_counter).created_by
              );

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;

            -- bug 2195303
            IF l_serial_control_code IN (2, 5) THEN
              update_serial_temp(x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data, p_operation => 'DELETE', p_trx_temp_id => l_troldt_tbl(l_counter).transaction_temp_id, p_cancel_qty => l_quantity_cancel);

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;

            l_quantity_cancel  := l_quantity_cancel - l_troldt_tbl(l_counter).transaction_quantity;
            l_rsv_quantity     := l_troldt_tbl(l_counter).transaction_quantity;
            BEGIN
              inv_replenish_detail_pub.clear_record(
                                              p_trx_tmp_id => l_troldt_tbl(l_counter).transaction_temp_id,
                                              p_success => l_success);
              if( not l_success ) then
                raise FND_API.G_EXC_ERROR;
              end if;
            EXCEPTION
              WHEN OTHERS THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END;
            IF p_delete_mmtt = 'YES' THEN --Added bug3524130
            inv_mo_line_detail_util.delete_row(x_return_status => l_return_status, p_line_id => l_trolin_rec.line_id, p_line_detail_id => l_troldt_tbl(l_counter).transaction_temp_id);
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSIF (l_troldt_tbl(l_counter).transaction_quantity > l_quantity_cancel) THEN
            IF (l_debug = 1) THEN
               DEBUG('only need to update the line detail', 'UPDATE TROLNDT ');
            END IF;

            IF l_lot_control_code = 2 THEN
              update_lots_temp(
                x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
              , p_operation                  => 'UPDATE'
              , p_item_id                    => l_troldt_tbl(l_counter).inventory_item_id
              , p_org_id                     => l_troldt_tbl(l_counter).organization_id
              , p_trx_temp_id                => l_troldt_tbl(l_counter).transaction_temp_id
              , p_cancel_qty                 => l_quantity_cancel
              , p_trx_uom                    => l_troldt_tbl(l_counter).transaction_uom
              , p_primary_uom                => l_troldt_tbl(l_counter).item_primary_uom_code
              , p_last_updated_by            => l_troldt_tbl(l_counter).last_updated_by
              , p_last_update_date           => l_troldt_tbl(l_counter).last_update_date
              , p_creation_date              => l_troldt_tbl(l_counter).creation_date
              , p_created_by                 => l_troldt_tbl(l_counter).created_by
              );

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;

            -- bug 2195303
            IF l_serial_control_code IN (2, 5) THEN
              update_serial_temp(x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data, p_operation => 'DELETE', p_trx_temp_id => l_troldt_tbl(l_counter).transaction_temp_id, p_cancel_qty => l_quantity_cancel);

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;

            l_troldt_tbl(l_counter).transaction_quantity  := l_troldt_tbl(l_counter).transaction_quantity - l_quantity_cancel;
            l_transaction_qty                             := l_troldt_tbl(l_counter).transaction_quantity;
            l_transaction_uom                             := l_troldt_tbl(l_counter).transaction_uom;
            l_primary_uom                                 := l_troldt_tbl(l_counter).item_primary_uom_code;
            l_primary_qty                                 :=
                     inv_convert.inv_um_convert(item_id => l_troldt_tbl(l_counter).inventory_item_id, PRECISION => NULL, from_quantity => l_transaction_qty, from_unit => l_transaction_uom, to_unit => l_primary_uom, from_name => NULL, to_name => NULL);
            l_troldt_tbl(l_counter).primary_quantity      := l_primary_qty;
            -- nsinghi bug#5724815 Update the secondary qty too in MMTT record.
            -- START
            IF l_troldt_tbl(l_counter).secondary_uom_code IS NOT NULL THEN
              l_secondary_uom_qty                         := inv_convert.inv_um_convert
                        (       item_id => l_troldt_tbl(l_counter).inventory_item_id,
                                PRECISION => NULL,
                                from_quantity => l_transaction_qty,
                                from_unit => l_transaction_uom,
                                to_unit => l_troldt_tbl(l_counter).secondary_uom_code,
                                from_name => NULL,
                                to_name => NULL
                        );
              IF (l_secondary_uom_qty = -99999) THEN
                IF (l_debug = 1) THEN
                   DEBUG('Cannot convert uom to secondary uom', 'UPDATE TROLNDT ');
                END IF;
                fnd_message.set_name('INV', 'INV_INVALID_UOM_CONV');
                fnd_message.set_token('VALUE1', l_troldt_tbl(l_counter).secondary_uom_code);
                fnd_message.set_token('VALUE2', l_transaction_uom);
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
	      IF l_secondary_uom_qty < 0 THEN
	         l_secondary_uom_qty := 0;
	      END IF;
              l_troldt_tbl(l_counter).secondary_transaction_quantity  := l_secondary_uom_qty;
            END IF;
            -- END

            l_rsv_quantity                                := l_quantity_cancel;
            inv_mo_line_detail_util.update_row(x_return_status => l_return_status, p_mo_line_detail_rec => l_troldt_tbl(l_counter));

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            l_quantity_cancel                             := 0;
          END IF;

          IF (p_move_order_type = 3) THEN
            l_to_rsv_rec.detailed_quantity  := l_to_rsv_rec.detailed_quantity - l_rsv_quantity;

--INVCONV - Make sure Qty2 are NULL if nor present
        IF (  l_to_rsv_rec.secondary_uom_code IS NULL ) THEN
              l_to_rsv_rec.secondary_reservation_quantity := NULL;
              l_to_rsv_rec.secondary_detailed_quantity    := NULL;
        END IF;
            inv_reservation_pub.update_reservation(
              p_api_version_number         => 1.0
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , p_original_rsv_rec           => l_rsv_temp_rec
            , p_to_rsv_rec                 => l_to_rsv_rec
            , p_original_serial_number     => l_dummy_sn
            , p_to_serial_number           => l_dummy_sn
            , p_validation_flag            => fnd_api.g_true
            );

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          IF (l_quantity_cancel <= 0) THEN
            EXIT;
          END IF;
        ELSIF (l_trolin_rec.line_status <> l_old_trolin_rec.line_status
               AND l_trolin_rec.line_status = 6
              ) THEN
          --l_trolin_rec.return_status := l_return_status;
          IF (l_debug = 1) THEN
             DEBUG('change status', 'UPDATE TROLNDT');
          END IF;

          IF (p_move_order_type = 3) THEN
            l_to_rsv_rec                    := l_mtl_reservation(1);
            l_rsv_temp_rec                  := l_mtl_reservation(1);
            l_to_rsv_rec.detailed_quantity  := l_to_rsv_rec.detailed_quantity - l_troldt_tbl(l_counter).transaction_quantity;

--INVCONV - Make sure Qty2 are NULL if nor present
        IF (  l_to_rsv_rec.secondary_uom_code IS NULL ) THEN
              l_to_rsv_rec.secondary_reservation_quantity := NULL;
              l_to_rsv_rec.secondary_detailed_quantity    := NULL;
        END IF;
            inv_reservation_pub.update_reservation(
              p_api_version_number         => 1.0
            , x_return_status              => l_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_original_rsv_rec           => l_rsv_temp_rec
            , p_to_rsv_rec                 => l_to_rsv_rec
            , p_original_serial_number     => l_dummy_sn
            , p_to_serial_number           => l_dummy_sn
            , p_validation_flag            => fnd_api.g_true
            );

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          BEGIN
            inv_replenish_detail_pub.clear_record(
                                              p_trx_tmp_id => l_troldt_tbl(l_counter).transaction_temp_id,
                                              p_success => l_success);
            if( not l_success ) then
              raise FND_API.G_EXC_ERROR;
            end if;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE fnd_api.g_exc_unexpected_error;
          END;
          inv_mo_line_detail_util.delete_row(x_return_status => l_return_status, p_line_id => l_trolin_rec.line_id, p_line_detail_id => l_troldt_tbl(l_counter).transaction_temp_id);

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END LOOP;
    END IF;

    x_trolin_rec      := l_trolin_rec;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RAISE;
    WHEN fnd_api.g_exc_unexpected_error THEN
      RAISE;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Trolins');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END update_troldt;

  PROCEDURE trohdr(
    p_validation_level IN     NUMBER
  , p_control_rec      IN     inv_globals.control_rec_type
  , p_trohdr_rec       IN     inv_move_order_pub.trohdr_rec_type
  , p_trohdr_val_rec   IN     inv_move_order_pub.trohdr_val_rec_type
  , p_old_trohdr_rec   IN     inv_move_order_pub.trohdr_rec_type
  , x_trohdr_rec       IN OUT    NOCOPY inv_move_order_pub.trohdr_rec_type
  , x_old_trohdr_rec   IN OUT    NOCOPY inv_move_order_pub.trohdr_rec_type
  ) IS
    l_return_status  VARCHAR2(1);
    l_control_rec    inv_globals.control_rec_type;
    l_trohdr_rec     inv_move_order_pub.trohdr_rec_type := p_trohdr_rec;
--Bug# 4554438, this var will be used to avoid NOCOPY issues
    l_tmp_trohdr_rec     inv_move_order_pub.trohdr_rec_type;
    l_old_trohdr_rec inv_move_order_pub.trohdr_rec_type := p_old_trohdr_rec;
    l_trohdr_val_rec inv_move_order_pub.trohdr_val_rec_type;

  BEGIN


    --  Load API control record
    l_control_rec               := inv_globals.init_control_rec(p_operation => l_trohdr_rec.operation, p_control_rec => p_control_rec);
    --  Set record return status.
    l_trohdr_rec.return_status  := fnd_api.g_ret_sts_success;

    --  Prepare record.
    IF l_trohdr_rec.operation = inv_globals.g_opr_create THEN
      l_trohdr_rec.db_flag  := fnd_api.g_false;
      --  Set missing old record elements to NULL.
      l_old_trohdr_rec      := inv_trohdr_util.convert_miss_to_null(l_old_trohdr_rec);
    ELSIF l_trohdr_rec.operation = inv_globals.g_opr_update
          OR l_trohdr_rec.operation = inv_globals.g_opr_delete THEN
      l_trohdr_rec.db_flag  := fnd_api.g_true;

      --  Query Old if missing
      IF l_old_trohdr_rec.header_id = fnd_api.g_miss_num THEN
        l_old_trohdr_rec  := inv_trohdr_util.query_row(p_header_id => l_trohdr_rec.header_id);
      ELSE
        --  Set missing old record elements to NULL.
        l_old_trohdr_rec  := inv_trohdr_util.convert_miss_to_null(l_old_trohdr_rec);
      END IF;

      --  Complete new record from old
      l_trohdr_rec          := inv_trohdr_util.complete_record(p_trohdr_rec => l_trohdr_rec, p_old_trohdr_rec => l_old_trohdr_rec);
    END IF;

   	--Bug 4756455 (11.5.10 bug 4755172 )
	--Reverted change of Bug 4329971 here and removed the code

    IF (l_trohdr_rec.operation = inv_globals.g_opr_update
        OR l_trohdr_rec.operation = inv_globals.g_opr_create
        OR l_trohdr_rec.operation = inv_globals.g_opr_delete)
    THEN
      --  Attribute level validation.
      IF l_control_rec.default_attributes
         OR l_control_rec.change_attributes THEN
        --  Default missing attributes

--Bug# 4554438.Start
-- l_tmp_trohdr_rec is passed as there is NOCOPY for x_trohdr_rec
--        inv_default_trohdr.ATTRIBUTES(p_trohdr_rec => l_trohdr_rec, x_trohdr_rec => l_trohdr_rec);
        inv_default_trohdr.ATTRIBUTES(p_trohdr_rec => l_trohdr_rec, x_trohdr_rec => l_tmp_trohdr_rec);
        l_trohdr_rec := l_tmp_trohdr_rec;

--Bug# 4554438.End

        IF p_validation_level > fnd_api.g_valid_level_none THEN
          -- Bug#2536932: Setting Missing elements of P_TROHDR_VAL_REC to NULL values.
          l_trohdr_val_rec := inv_trohdr_util.convert_miss_to_null(p_trohdr_val_rec);
          inv_validate_trohdr.ATTRIBUTES(x_return_status => l_return_status, p_trohdr_rec => l_trohdr_rec, p_trohdr_val_rec => l_trohdr_val_rec, p_old_trohdr_rec => l_old_trohdr_rec);

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      --  Clear dependent attributes.

      IF l_control_rec.change_attributes THEN
        inv_trohdr_util.clear_dependent_attr(p_trohdr_rec => l_trohdr_rec, p_old_trohdr_rec => l_old_trohdr_rec, x_trohdr_rec => l_trohdr_rec);
      END IF;

      --  Apply attribute changes
      IF l_control_rec.default_attributes
         OR l_control_rec.change_attributes THEN
        --debug('Apply Attr');
        inv_trohdr_util.apply_attribute_changes(p_trohdr_rec => l_trohdr_rec, p_old_trohdr_rec => l_old_trohdr_rec, x_trohdr_rec => l_trohdr_rec);
      END IF;

      --  Entity level validation.
      IF l_control_rec.validate_entity THEN
        IF l_trohdr_rec.operation = inv_globals.g_opr_delete THEN
          inv_validate_trohdr.entity_delete(x_return_status => l_return_status, p_trohdr_rec => l_trohdr_rec);
        ELSE
          inv_validate_trohdr.entity(x_return_status => l_return_status, p_trohdr_rec => l_trohdr_rec, p_old_trohdr_rec => l_old_trohdr_rec);
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      --  Step 4. Write to DB
      IF l_control_rec.write_to_db THEN
        IF l_trohdr_rec.operation = inv_globals.g_opr_delete THEN
          inv_trohdr_util.delete_row(p_header_id => l_trohdr_rec.header_id);
        ELSE
          --  Get Who Information
          l_trohdr_rec.last_update_date   := SYSDATE;
          l_trohdr_rec.last_updated_by    := fnd_global.user_id;
          l_trohdr_rec.last_update_login  := fnd_global.login_id;

          IF l_trohdr_rec.operation = inv_globals.g_opr_update THEN
            inv_trohdr_util.update_row(l_trohdr_rec);
          ELSIF l_trohdr_rec.operation = inv_globals.g_opr_create THEN
            l_trohdr_rec.creation_date  := SYSDATE;
            l_trohdr_rec.created_by     := fnd_global.user_id;
            inv_trohdr_util.insert_row(l_trohdr_rec);
          END IF;
        END IF;
      END IF;
    END IF;

    --  Load OUT parameters
    --debug(l_trohdr_rec.header_id);
    x_trohdr_rec                := l_trohdr_rec;
    --debug(l_trohdr_rec.header_id);
    x_old_trohdr_rec            := l_old_trohdr_rec;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      l_trohdr_rec.return_status  := fnd_api.g_ret_sts_error;
      x_trohdr_rec                := l_trohdr_rec;
      x_old_trohdr_rec            := l_old_trohdr_rec;
      RAISE;
    WHEN fnd_api.g_exc_unexpected_error THEN
      l_trohdr_rec.return_status  := fnd_api.g_ret_sts_unexp_error;
      x_trohdr_rec                := l_trohdr_rec;
      x_old_trohdr_rec            := l_old_trohdr_rec;
      RAISE;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Trohdr');
      END IF;

      l_trohdr_rec.return_status  := fnd_api.g_ret_sts_unexp_error;
      x_trohdr_rec                := l_trohdr_rec;
      x_old_trohdr_rec            := l_old_trohdr_rec;
      RAISE fnd_api.g_exc_unexpected_error;
  END trohdr;

  --  Trolins

  PROCEDURE trolins(
    p_validation_level IN        NUMBER
  , p_control_rec      IN        inv_globals.control_rec_type
  , p_trolin_tbl       IN        inv_move_order_pub.trolin_tbl_type
  , p_trolin_val_tbl   IN        inv_move_order_pub.trolin_val_tbl_type
  , p_old_trolin_tbl   IN        inv_move_order_pub.trolin_tbl_type
  , p_move_order_type  IN        NUMBER
  , x_trolin_tbl       IN OUT    NOCOPY inv_move_order_pub.trolin_tbl_type
  , x_old_trolin_tbl   IN OUT    NOCOPY inv_move_order_pub.trolin_tbl_type
  , p_delete_mmtt      IN        VARCHAR2 DEFAULT 'YES' --Added bug3524130
  ) IS
    l_return_status         VARCHAR2(1);
    l_control_rec           inv_globals.control_rec_type;
    l_trolin_rec            inv_move_order_pub.trolin_rec_type;
    --Bug #4347016
    l_tmp_trolin_rec        inv_move_order_pub.trolin_rec_type;
    l_trolin_val_rec        inv_move_order_pub.trolin_val_rec_type;
    l_trolin_tbl            inv_move_order_pub.trolin_tbl_type;
    l_old_trolin_rec        inv_move_order_pub.trolin_rec_type;
    l_old_trolin_tbl        inv_move_order_pub.trolin_tbl_type;
    l_troldt_tbl            inv_mo_line_detail_util.g_mmtt_tbl_type;
    l_quantity_cancel       NUMBER;
    l_mtl_reservations      inv_reservation_global.mtl_reservation_tbl_type;
    l_mtl_reservation_count NUMBER;
    l_rsv_temp_rec          inv_reservation_global.mtl_reservation_rec_type;
    l_to_rsv_rec            inv_reservation_global.mtl_reservation_rec_type;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_move_order_type       NUMBER;
    l_trohdr_rec            inv_move_order_pub.trohdr_rec_type;
    l_failed_ship_set_id    NUMBER   := NULL;
    l_marked_failed_shipset BOOLEAN  := FALSE;
    l_count                 NUMBER;
    l_current_ship_set_id   NUMBER   := NULL;
    l_debug number;
    l_cur_mfg_org_id        NUMBER;  --Bug #5204255
    l_cur_line_org_id       NUMBER;
  BEGIN
    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    --  Init local table variables.
    l_trolin_tbl      := p_trolin_tbl;
    l_old_trolin_tbl  := p_old_trolin_tbl;

    FOR i IN 1 .. l_trolin_tbl.COUNT LOOP
      BEGIN
        --  Load local records.
        l_trolin_rec                := l_trolin_tbl(i);

	/* Fix for Bug# 3409435. Calling the INV_Validate_Trolin.init procedure
	   to initialize the global variables used in  inv_validate_trolin package */
	   INV_Validate_Trolin.init;

        /* Bug 2504964: Tracking Ship Set : Code Starts */
        IF  l_trolin_rec.ship_set_id IS NOT NULL
            AND l_trolin_rec.ship_set_id <> NVL(l_current_ship_set_id, -99) THEN
          l_current_ship_set_id    := l_trolin_rec.ship_set_id;
          SAVEPOINT MO_SHIPSET;
          l_marked_failed_shipset  := FALSE;
          l_failed_ship_set_id     := NULL;
        END IF;

        IF NVL(l_trolin_rec.ship_set_id, -99) = NVL(l_failed_ship_set_id, -999) THEN
          DEBUG('MO Line failed due to Ship Set validation: ' || to_char(l_trolin_rec.line_id),  'Inv_Transfer_Order_PVT.Trolins');
          RAISE fnd_api.g_exc_error;
        END IF;

        /* Bug 2504964: Tracking Ship Set : Code Ends */

        IF p_trolin_val_tbl.EXISTS(i) THEN
          l_trolin_val_rec  := p_trolin_val_tbl(i);
          -- Bug#2536932: Setting Missing Values as NULL.
          l_trolin_val_rec  := inv_trolin_util.convert_miss_to_null(l_trolin_val_rec);
        ELSE
          l_trolin_val_rec  := NULL;
        END IF;

        IF l_old_trolin_tbl.EXISTS(i) THEN
          l_old_trolin_rec  := l_old_trolin_tbl(i);
        ELSE
          l_old_trolin_rec  := inv_move_order_pub.g_miss_trolin_rec;
        END IF;

        --  Load API control record
        l_control_rec               := inv_globals.init_control_rec(p_operation => l_trolin_rec.operation, p_control_rec => p_control_rec);
              -- load header information record
              --l_trohdr_rec := inv_trohdr_util.query_row(l_trolin_tbl(I).header_id);
        --l_move_order_type :=  l_trohdr_rec.move_order_type;

        --  Set record return status.
        l_trolin_rec.return_status  := fnd_api.g_ret_sts_success;
        --  Prepare record.
        IF (l_debug = 1) THEN
           DEBUG('Trolin operation:'|| l_trolin_rec.operation, 'Inv_Transfer_Order_PVT.Trolins');
        END IF;

        IF l_trolin_rec.operation = inv_globals.g_opr_create THEN
          l_trolin_rec.db_flag  := fnd_api.g_false;
          --  Set missing old record elements to NULL.
          --debug('Trolin convert');
          IF (l_debug = 1) THEN
             DEBUG('Trolin convert', 'Inv_Transfer_Order_PVT.Trolins');
          END IF;
          l_old_trolin_rec      := inv_trolin_util.convert_miss_to_null(l_old_trolin_rec);
        ELSIF l_trolin_rec.operation = inv_globals.g_opr_update
              OR l_trolin_rec.operation = inv_globals.g_opr_delete THEN
          l_trolin_rec.db_flag  := fnd_api.g_true;

          --  Query Old if missing
          IF l_old_trolin_rec.line_id = fnd_api.g_miss_num THEN
            --debug('Trolin line_id miss num');
            IF (l_debug = 1) THEN
               DEBUG('Trolin line_id miss num', 'Inv_Transfer_Order_PVT.Trolins');
            END IF;
            l_old_trolin_rec  := inv_trolin_util.query_row(p_line_id => l_trolin_rec.line_id);
          ELSE
            --  Set missing old record elements to NULL.
            l_old_trolin_rec  := inv_trolin_util.convert_miss_to_null(l_old_trolin_rec);
          END IF;

          --  Complete new record from old
          l_trolin_rec          := inv_trolin_util.complete_record(p_trolin_rec => l_trolin_rec, p_old_trolin_rec => l_old_trolin_rec);
        END IF;

	      --Bug 4756455 (11.5.10 bug 4755172 )
	      --Reverted change of Bug 4329971here and removed the code

	      -- bug 4662395 set the profile mfg_organization_id so
        -- the call to PJM_PROJECTS_V will return data.
        -- The call to PJM_PROJECTS_V is made indirectly through
        -- inv_default_trolin.ATTRIBUTES and inv_validate_trolin.ATTRIBUTES
        -- both of which can be found in the next few lines of code.

        --Bug #5204255
        --We should set the profile value only if it is NULL/G_MISS_NUM
        --and the current line's organization_id is not NULL/G_MISS_NUM
        l_cur_mfg_org_id  := TO_NUMBER(FND_PROFILE.VALUE('MFG_ORGANIZATION_ID'));
        l_cur_line_org_id := l_trolin_rec.organization_id;

        IF ( ( (l_cur_mfg_org_id IS NULL) OR
               (l_cur_mfg_org_id IS NOT NULL AND l_cur_mfg_org_id = FND_API.G_MISS_NUM)
             ) AND
             (l_cur_line_org_id IS NOT NULL AND l_cur_line_org_id <> FND_API.G_MISS_NUM)
           ) THEN
          FND_PROFILE.put('MFG_ORGANIZATION_ID',l_trolin_rec.organization_id);
        END IF;

        --  Attribute level validation.
        IF l_control_rec.default_attributes
           OR l_control_rec.change_attributes THEN
                --  Default missing attributes
          --debug('default missing attributes');
          IF (l_debug = 1) THEN
             DEBUG('default missing attributes', 'Inv_Transfer_Order_PVT.Trolins');
          END IF;

          --Bug #4347016 - Creating a temp variable to store output record
          --as there is a NOCOPY in inv_default_trolin.ATTRIBUTES
          inv_default_trolin.ATTRIBUTES(
                      p_trolin_rec => l_trolin_rec
                    , x_trolin_rec => l_tmp_trolin_rec);

          l_trolin_rec := l_tmp_trolin_rec;

          IF p_validation_level > fnd_api.g_valid_level_none THEN
      inv_validate_trolin.ATTRIBUTES(x_return_status => l_return_status, p_trolin_rec => l_trolin_rec, p_trolin_val_rec => l_trolin_val_rec, p_old_trolin_rec => l_old_trolin_rec);

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              --debug('error in validate_attributes');
              IF (l_debug = 1) THEN
                DEBUG('error in validate_attributes', 'Inv_Transfer_Order_PVT.Trolins');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                DEBUG('exc error in validate_attributes', 'Inv_Transfer_Order_PVT.Trolins');
              END IF;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
        END IF;

        --debug(l_trolin_rec.line_id);
            --  Clear dependent attributes.
        IF l_control_rec.change_attributes THEN
          --debug('calling clear dependent attr');
          IF (l_debug = 1) THEN
            DEBUG('calling clear dependent attr', 'Inv_Transfer_Order_PVT.Trolins');
          END IF;
          inv_trolin_util.clear_dependent_attr(p_trolin_rec => l_trolin_rec, p_old_trolin_rec => l_old_trolin_rec, x_trolin_rec => l_trolin_rec);
        --debug('after calling dependent attr');
        END IF;

        --  Apply attribute changes
        IF l_control_rec.default_attributes
           OR l_control_rec.change_attributes THEN
          --debug('Trolin Apply attr');
          IF (l_debug = 1) THEN
            DEBUG('Trolin Apply attr',  'Inv_Transfer_Order_PVT.Trolins');
          END IF;
          inv_trolin_util.apply_attribute_changes(p_trolin_rec => l_trolin_rec, p_old_trolin_rec => l_old_trolin_rec, x_trolin_rec => l_trolin_rec);
        END IF;

        --debug('AFter Trolin APply attr');

        --  Entity level validation.
        IF l_control_rec.validate_entity THEN
          IF l_trolin_rec.operation = inv_globals.g_opr_delete THEN
            inv_validate_trolin.entity_delete(x_return_status => l_return_status, p_trolin_rec => l_trolin_rec);
          ELSE
            --debug('Trolin Validate Entity');
            IF (l_debug = 1) THEN
              DEBUG('Trolin Validate Entity', 'Inv_Transfer_Order_PVT.Trolins');
            END IF;
            inv_validate_trolin.entity(x_return_status => l_return_status, p_trolin_rec => l_trolin_rec, p_old_trolin_rec => l_old_trolin_rec, p_move_order_type => p_move_order_type);
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            l_trolin_rec.return_status  := l_return_status;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            l_trolin_rec.return_status  := l_return_status;
            IF (l_debug = 1) THEN
              DEBUG('Error from Trolin Validate Entity', 'Inv_Transfer_Order_PVT.Trolins');
            END IF;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

                --debug('AFter Trolin Validate Entity');
        -- populate primary quantity
        IF (l_trolin_rec.inventory_item_id IS NOT NULL
            AND l_trolin_rec.quantity IS NOT NULL
            AND l_trolin_rec.uom_code IS NOT NULL
           ) THEN

           --Bug3467711. The quantity field should should have a precision
           --of 5 irrespective of the value passed.
	  /*6971965: Adding if condition for WIP generated MO*/
	  IF (l_debug = 1) THEN
            DEBUG('Transaction_type_id: '||to_char(l_trolin_rec.transaction_type_id),'Inv_Transfer_Order_PVT.Trolins');
          END IF;
	  IF l_trolin_rec.transaction_type_id = 35 THEN
            l_trolin_rec.quantity          := ROUND(l_trolin_rec.quantity , 6);
          ELSE
	    l_trolin_rec.quantity          := ROUND(l_trolin_rec.quantity , 5);
          END IF;
          /*l_trolin_rec.quantity          := ROUND(l_trolin_rec.quantity , 5);*/
          l_trolin_rec.primary_quantity  := get_primary_quantity(p_item_id => l_trolin_rec.inventory_item_id, p_organization_id => l_trolin_rec.organization_id, p_from_quantity => l_trolin_rec.quantity, p_from_unit => l_trolin_rec.uom_code);
          -- nsinghi bug#5724815 need to populate the secondary qty too for dual items.
          -- START
          /*Bug#8240056 secondary qty passed can not be overwriten so changin the below condition
           to have the recalculation only when the new secondaty qty is null */
          IF l_old_trolin_rec.secondary_uom IS NOT NULL AND l_trolin_rec.secondary_quantity IS NULL THEN
            l_trolin_rec.secondary_quantity := inv_convert.inv_um_convert
                      (       item_id => l_trolin_rec.inventory_item_id,
                              lot_number => l_trolin_rec.lot_number,
                              organization_id          => l_trolin_rec.organization_id,
                              PRECISION => NULL,
                              from_quantity => l_trolin_rec.quantity,
                              from_unit => l_trolin_rec.uom_code,
                              to_unit => l_old_trolin_rec.secondary_uom,
                              from_name => NULL,
                              to_name => NULL
                      );

            IF (l_trolin_rec.secondary_quantity = -99999) THEN
              IF (l_debug = 1) THEN
                 DEBUG('Cannot convert uom to secondary uom', 'Inv_Transfer_Order_PVT.Trolins');
              END IF;
              fnd_message.set_name('INV', 'INV_INVALID_UOM_CONV');
              fnd_message.set_token('VALUE1', l_old_trolin_rec.secondary_uom);
              fnd_message.set_token('VALUE2', l_trolin_rec.uom_code);
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;
          -- END

          IF (l_debug = 1) THEN
            DEBUG('Populated primary quantity: ' || to_char(l_trolin_rec.primary_quantity),  'Inv_Transfer_Order_PVT.Trolins');
          END IF;
        END IF;

        --  Step 4. Write to DB
        IF l_control_rec.write_to_db THEN
          IF l_trolin_rec.operation = inv_globals.g_opr_delete THEN
            --debug('Calling inv_mold_query_rows');
            IF (l_debug = 1) THEN
              DEBUG('Calling inv_mold_query_rows for Line Id: ' || to_char(l_trolin_rec.line_id), 'Inv_Transfer_Order_PVT.Trolins');
            END IF;
            l_troldt_tbl  := inv_mo_line_detail_util.query_rows(p_line_id => l_trolin_rec.line_id);

            IF (l_troldt_tbl.COUNT > 0) THEN
              IF (l_debug = 1) THEN
                 DEBUG('Calling Delete_Troldt', 'Inv_Transfer_Order_PVT.Trolins');
              END IF;
              delete_troldt(x_return_status => l_return_status, x_msg_data => l_msg_data, x_msg_count => l_msg_count, p_troldt_tbl => l_troldt_tbl, p_move_order_type => l_move_order_type);

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                l_trolin_rec.return_status  := l_return_status;
                RAISE fnd_api.g_exc_unexpected_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                l_trolin_rec.return_status  := l_return_status;
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;

            inv_trolin_util.delete_row(p_line_id => l_trolin_rec.line_id);
          ELSIF l_trolin_rec.operation = inv_globals.g_opr_update THEN
            --  Get Who Information
	    -- Bug 3030538. Creation_date becomes null when both an update and
	    -- create are done in move orders form

            l_trolin_rec.creation_date      := l_old_trolin_rec.creation_date;
	    l_trolin_rec.created_by         := l_old_trolin_rec.created_by;
            l_trolin_rec.last_update_date   := SYSDATE;
            l_trolin_rec.last_updated_by    := fnd_global.user_id;
            l_trolin_rec.last_update_login  := fnd_global.login_id;
            IF (l_debug = 1) THEN
               DEBUG(l_trolin_rec.quantity, 'Inv_Transfer_Order_PVT.Trolins');
               DEBUG(l_old_trolin_rec.quantity, 'Inv_Transfer_Order_PVT.Trolins');
               DEBUG(l_trolin_rec.quantity_detailed, 'Inv_Transfer_Order_PVT.Trolins');
               DEBUG(l_old_trolin_rec.quantity_detailed, 'Inv_Transfer_Order_PVT.Trolins');
               DEBUG(l_trolin_rec.line_status, 'Inv_Transfer_Order_PVT.Trolins');
               DEBUG(l_old_trolin_rec.line_status, 'Inv_Transfer_Order_PVT.Trolins');
               DEBUG('l_trolin_Rec.required_quantity'|| l_trolin_rec.required_quantity, 'Inv_Transfer_Order_PVT.Trolins');
               DEBUG('l_old_trolin_Rec.required_quantity'|| l_old_trolin_rec.required_quantity, 'Inv_Transfer_Order_PVT.Trolins');
            END IF;

            IF l_old_trolin_rec.required_quantity IS NOT NULL THEN
              l_trolin_rec.required_quantity  := l_old_trolin_rec.required_quantity;
            END IF;

            IF (l_old_trolin_rec.quantity <> l_trolin_rec.quantity
                OR l_old_trolin_rec.line_status <> l_trolin_rec.line_status
                OR l_old_trolin_rec.quantity_detailed <> l_trolin_rec.quantity_detailed
               ) THEN
              IF (l_debug = 1) THEN
                 DEBUG('calling mold query rows', 'Inv_Transfer_Order_PVT.Trolins');
              END IF;
              l_troldt_tbl  := inv_mo_line_detail_util.query_rows(p_line_id => l_trolin_rec.line_id);
              IF (l_debug = 1) THEN
                 DEBUG('after mold query rows', 'Inv_Transfer_Order_PVT.Trolins');
              END IF;

              IF (l_troldt_tbl.COUNT > 0) THEN
                IF (l_debug = 1) THEN
                   DEBUG('calling update troldt', 'Inv_Transfer_Order_PVT.Trolins');
                END IF;
                update_troldt(
                  x_return_status              => l_return_status
                , x_msg_data                   => l_msg_data
                , x_msg_count                  => l_msg_count
                , p_trolin_rec                 => l_trolin_rec
                , p_old_trolin_rec             => l_old_trolin_rec
                , p_troldt_tbl                 => l_troldt_tbl
                , p_move_order_type            => p_move_order_type
                , x_trolin_rec                 => l_trolin_rec
		, p_delete_mmtt                => p_delete_mmtt  --Added bug 3524130
                );

                IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                     DEBUG('got error', 'Inv_Transfer_Order_PVT.Trolins');
                  END IF;
                  l_trolin_rec.return_status  := l_return_status;
                  RAISE fnd_api.g_exc_unexpected_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  l_trolin_rec.return_status  := l_return_status;
                  RAISE fnd_api.g_exc_error;
                END IF;
              END IF;
            END IF;

            IF (l_debug = 1) THEN
               DEBUG('calling update row', 'Inv_Transfer_Order_PVT.Trolins');
               DEBUG(l_trolin_rec.line_id, 'Inv_Transfer_Order_PVT.Trolins');
            END IF;
            inv_trolin_util.update_row(l_trolin_rec);
            IF (l_debug = 1) THEN
               DEBUG('after update row', 'Inv_Transfer_Order_PVT.Trolins');
            END IF;
          ELSIF l_trolin_rec.operation = inv_globals.g_opr_create THEN
            l_trolin_rec.creation_date      := SYSDATE;
            l_trolin_rec.created_by         := fnd_global.user_id;
            l_trolin_rec.last_update_date   := SYSDATE;
            l_trolin_rec.last_updated_by    := fnd_global.user_id;
            l_trolin_rec.last_update_login  := fnd_global.login_id;
            IF (l_debug = 1) THEN
               DEBUG('create row', 'Inv_Transfer_Order_PVT.Trolins');
            END IF;
            /*Bug#5764123. Added the below line to convert the MISSING data
              to NULL.*/
            l_trolin_rec := inv_trolin_util.convert_miss_to_null(l_trolin_rec);
            inv_trolin_util.insert_row(l_trolin_rec);
          END IF;
        END IF;

        IF (l_debug = 1) THEN
           DEBUG('AFter Trolin Write to db', 'Inv_Transfer_Order_PVT.Trolins');
        END IF;
        --  Load tables.
        l_trolin_tbl(i)             := l_trolin_rec;
        l_old_trolin_tbl(i)         := l_old_trolin_rec;
      --  For loop exception handler.
      EXCEPTION
        WHEN fnd_api.g_exc_error THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
          l_trolin_tbl(i)             := l_trolin_rec;
          l_old_trolin_tbl(i)         := l_old_trolin_rec;

          /* Bug 2504964: One of the MO Lines in the ShipSet failed.
             Mark all the MO Lines belonging to that ShipSet as Failed.
             Note this is not done again for the same ShipSet later. All are done atonce*/
          IF  l_trolin_rec.ship_set_id IS NOT NULL AND NOT l_marked_failed_shipset THEN
            l_failed_ship_set_id     := l_trolin_rec.ship_set_id;
            ROLLBACK TO MO_SHIPSET;
            IF (l_debug = 1) THEN
              DEBUG('MO Lines in ShipSet failure', 'Inv_Transfer_Order_PVT.Trolins');
            END IF;

            FOR l_count IN 1 .. l_trolin_tbl.COUNT LOOP
              IF l_trolin_tbl(l_count).ship_set_id = NVL(l_failed_ship_set_id, -99) THEN
                l_trolin_tbl(l_count).return_status  := fnd_api.g_ret_sts_error;
              END IF;
            END LOOP;

            l_marked_failed_shipset  := TRUE;
          END IF;


	  --Bug 4756455 (11.5.10 bug 4755172 )
	  --Reverted change of Bug 4329971,4699505 here and removed the code


        WHEN fnd_api.g_exc_unexpected_error THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_unexp_error;
          l_trolin_tbl(i)             := l_trolin_rec;
          l_old_trolin_tbl(i)         := l_old_trolin_rec;
          RAISE fnd_api.g_exc_unexpected_error;
        WHEN OTHERS THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_unexp_error;
          l_trolin_tbl(i)             := l_trolin_rec;
          l_old_trolin_tbl(i)         := l_old_trolin_rec;

          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, 'Trolins');
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
      END;
    END LOOP;

    --  Load OUT parameters

    x_trolin_tbl      := l_trolin_tbl;
    x_old_trolin_tbl  := l_old_trolin_tbl;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RAISE;
    WHEN fnd_api.g_exc_unexpected_error THEN
      RAISE;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Trolins');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END trolins;

  /*Procedure Get_Reservations(
      x_return_status OUT VARCHAR2,
      x_msg_count     OUT NUMBER,
      x_msg_data      OUT VARCHAR2,
      p_source_header_id  IN NUMBER,
      p_source_line_id    IN NUMBER,
      p_source_delivery_id        IN NUMBER,
      p_organization_id   IN NUMBER,
      p_inventory_item_id IN NUMBER,
      p_subinventory_code IN VARCHAR2 := FND_API.G_MISS_CHAR,
      p_locator_id        IN NUMBER := FND_API.G_MISS_NUM,
      p_revision          IN VARCHAR2 := FND_API.G_MISS_CHAR,
      p_lot_number        IN VARCHAR2 := FND_API.G_MISS_CHAR,
      p_serial_number     IN VARCHAR2 := FND_API.G_MISS_CHAR,
      x_mtl_reservation_tbl OUT INV_RESERVATION_GLOBAL.MTL_RESERVATION_TBL_TYPE
  )
  IS
      l_rsv_temp_rec INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE;
      l_mtl_reservation INV_RESERVATION_GLOBAL.MTL_RESERVATION_TBL_TYPE;
      l_mtl_reservation_count NUMBER;
      l_rsv_result_tbl INV_RESERVATION_GLOBAL.MTL_RESERVATION_TBL_TYPE;
  BEGIN
      l_rsv_temp_rec.demand_source_header_id := p_source_header_id;
      l_rsv_temp_Rec.demand_source_line_id := p_source_line_id;
      l_rsv_temp_rec.demand_source_delivery := p_source_delivery_id;
      l_rsv_temp_rec.inventory_item_id := p_inventory_item_id;
      l_rsv_temp_rec.organization_id := p_organization_id;

      INV_RESERVATION_PUB.Query_Reservation
      (
           p_api_version_number => 1.0,
           x_return_status => l_return_status,
           x_msg_count => x_msg_count,
           x_msg_data  => x_msg_data,
           p_query_input => l_rsv_temp_rec,
           x_mtl_reservation_tbl => l_mtl_reservation,
           x_mtl_reservation_tbl_count => l_mtl_reservation_count,
           x_error_code => l_error_code
       );*/
     /*  if( l_mtl_reservation_count > 0 ) then
           for l_count in 1 ..l_mtl_reservation_count LOOP
                  l_rsv_temp_rec := l_mtl_reservation(l_count);
                  if( l_mtl_reservation(l_count).subinventory_code is null ) then
                      if( l_mtl_reservation(l_count).locator_id is null) then
                          if(l_mtl_reservation(l_count).revision is null ) then
                             if( l_mtl_reservation(l_count).lot_number is null) then
                                  if( l_mtl_reservation(l_count).serial_number is null) then
                                      l_rsv_result_tbl(l_count) := l_mtl_reservation(l_count);
                                  elsif( p_serial_number <> FND_API.G_MISS_CHAR AND l_mtl_reservation(l_count).serial_number =p_serial_number) then
                                      l_rsv_result_tbl(l_count) := l_mtl_reservation(l_count);
                                  end if;
                             elsif( p_lot_number <> FND_API.G_MISS_CHAR AND l_mtl_reservation(l_count).lot_number =p_lot_number) then
                                  l_rsv_result_tbl(l_count) := l_mtl_reservation(l_count);
                             end if;
                          elsif( p_revision <> FND_API.G_MISS_CHAR AND l_mtl_reservation(l_count).revision =p_revision) then
                             l_rsv_result_tbl(l_count) := l_mtl_reservation(l_count);
                          end if;
                      elsif( p_locator_id <> FND_API.G_MISS_NUM AND l_mtl_reservation(l_count).locator_id =p_locator_id) then
                             l_rsv_result_tbl(l_count) := l_mtl_reservation(l_count);
                      end if;
                  elsif( p_subinventory_code <> FND_API.G_MISS_CHAR AND l_mtl_reservation(l_count).subinventory_code =p_subinventory_code) then
                      l_rsv_result_tbl(l_count) := l_mtl_reservation(l_count);
                  end if;
           end loop;
       end if;    */
  /*     x_mtl_reservation_tbl := l_rsv_result_tbl;
  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
          RAISE;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          RAISE;

      WHEN OTHERS THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
              (   G_PKG_NAME
              ,   'Trolins'
              );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Get_Reservations;*/

  --  Start of Comments
  --  API name    Process_Transfer_Order
  --  Type        Private
  --  Function
  --
  --  Pre-reqs
  --
  --  Parameters
  --
  --  Version     Current version = 1.0
  --              Initial version = 1.0
  --
  --  Notes
  --
  --  End of Comments

  PROCEDURE process_transfer_order(
    p_api_version_number IN     NUMBER
  , p_init_msg_list      IN     VARCHAR2 := fnd_api.g_false
  , p_commit             IN     VARCHAR2 := fnd_api.g_false
  , p_validation_level   IN     NUMBER := fnd_api.g_valid_level_full
  , p_control_rec        IN     inv_globals.control_rec_type := inv_globals.g_miss_control_rec
  , x_return_status      OUT    NOCOPY VARCHAR2
  , x_msg_count          OUT    NOCOPY NUMBER
  , x_msg_data           OUT    NOCOPY VARCHAR2
  , p_trohdr_rec         IN     inv_move_order_pub.trohdr_rec_type := inv_move_order_pub.g_miss_trohdr_rec
  , p_trohdr_val_rec     IN     inv_move_order_pub.trohdr_val_rec_type := inv_move_order_pub.g_miss_trohdr_val_rec
  , p_old_trohdr_rec     IN     inv_move_order_pub.trohdr_rec_type := inv_move_order_pub.g_miss_trohdr_rec
  , p_trolin_tbl         IN     inv_move_order_pub.trolin_tbl_type := inv_move_order_pub.g_miss_trolin_tbl
  , p_trolin_val_tbl     IN     inv_move_order_pub.trolin_val_tbl_type := inv_move_order_pub.g_miss_trolin_val_tbl
  , p_old_trolin_tbl     IN     inv_move_order_pub.trolin_tbl_type := inv_move_order_pub.g_miss_trolin_tbl
  , x_trohdr_rec         IN OUT    NOCOPY inv_move_order_pub.trohdr_rec_type
  , x_trolin_tbl         IN OUT    NOCOPY inv_move_order_pub.trolin_tbl_type
  , p_delete_mmtt        IN      VARCHAR2 DEFAULT 'YES' --Added bug3524130
  ) IS
    l_api_version_number CONSTANT NUMBER                             := 1.0;
    l_api_name           CONSTANT VARCHAR2(30)                       := 'Process_Transfer_Order';
    l_return_status               VARCHAR2(1);
    l_control_rec                 inv_globals.control_rec_type;
    l_trohdr_rec                  inv_move_order_pub.trohdr_rec_type := p_trohdr_rec;
    l_old_trohdr_rec              inv_move_order_pub.trohdr_rec_type := p_old_trohdr_rec;
    l_trolin_rec                  inv_move_order_pub.trolin_rec_type;
    l_trolin_tbl                  inv_move_order_pub.trolin_tbl_type;
    l_old_trolin_rec              inv_move_order_pub.trolin_rec_type;
    l_old_trolin_tbl              inv_move_order_pub.trolin_tbl_type;
    l_debug number;
  BEGIN
    --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number, p_api_version_number, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --  Initialize message list.

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    --  Init local table variables.
    l_trolin_tbl      := p_trolin_tbl;
    l_old_trolin_tbl  := p_old_trolin_tbl;

    --  Trohdr
    IF (p_control_rec.process_entity = inv_globals.g_entity_all
        OR p_control_rec.process_entity = inv_globals.g_entity_trohdr
       ) THEN
      trohdr(
        p_validation_level           => p_validation_level
      , p_control_rec                => p_control_rec
      , p_trohdr_rec                 => l_trohdr_rec
      , p_trohdr_val_rec             => p_trohdr_val_rec
      , p_old_trohdr_rec             => l_old_trohdr_rec
      , x_trohdr_rec                 => l_trohdr_rec
      , x_old_trohdr_rec             => l_old_trohdr_rec
      );
    END IF;

    IF (l_debug = 1) THEN
       DEBUG(l_trohdr_rec.header_id, 'Inv_Transfer_Order_PVT.Process_Transfer_Orders');
    END IF;
    --  Load parent key if missing and operation is create.
    IF (l_debug = 1) THEN
       DEBUG('Calling trolin 1', 'Inv_Transfer_Order_PVT.Process_Transfer_Orders');
    END IF;

    FOR i IN 1 .. l_trolin_tbl.COUNT LOOP
      l_trolin_rec  := l_trolin_tbl(i);

      IF  l_trolin_rec.operation = inv_globals.g_opr_create
          AND (l_trolin_rec.header_id IS NULL
               OR l_trolin_rec.header_id = fnd_api.g_miss_num
              ) THEN
        --  Copy parent_id.
        IF (l_debug = 1) THEN
           DEBUG('Header:'|| TO_CHAR(l_trohdr_rec.header_id), 'Inv_Transfer_Order_PVT.Process_Transfer_Orders');
        END IF;
        l_trolin_tbl(i).header_id  := l_trohdr_rec.header_id;
      --l_trolin_Tbl(I).grouping_rule_id := l_trohdr_Rec.grouping_rule_id;
      END IF;
    END LOOP;

    --  Trolins

    IF (p_control_rec.process_entity = inv_globals.g_entity_all
        OR p_control_rec.process_entity = inv_globals.g_entity_trolin
       ) THEN
      trolins(
        p_validation_level           => p_validation_level
      , p_control_rec                => p_control_rec
      , p_trolin_tbl                 => l_trolin_tbl
      , p_trolin_val_tbl             => p_trolin_val_tbl
      , p_old_trolin_tbl             => l_old_trolin_tbl
      , p_move_order_type            => p_trohdr_rec.move_order_type
      , x_trolin_tbl                 => l_trolin_tbl
      , x_old_trolin_tbl             => l_old_trolin_tbl
      , p_delete_mmtt                => p_delete_mmtt  --Added bug 3524130
      );
    END IF;

     --debug('AFter trolins 2');
    --  Done processing, load OUT parameters.
    x_trohdr_rec      := l_trohdr_rec;
    --debug(x_trohdr_rec.header_id);
    x_trolin_tbl      := l_trolin_tbl;
     --debug('AFter trolins 4');
    --  Derive return status.
    x_return_status   := fnd_api.g_ret_sts_success;


    --Bug #4777248
    --Modified both the if loops by removing p_control_rec.process from the condition
    IF  (p_control_rec.process_entity = inv_globals.g_entity_all
             OR p_control_rec.process_entity = inv_globals.g_entity_trohdr
            ) THEN
      IF l_trohdr_rec.return_status = fnd_api.g_ret_sts_error THEN
        x_return_status  := fnd_api.g_ret_sts_error;
      END IF;
    END IF;

    IF (p_control_rec.process_entity = inv_globals.g_entity_all
             OR p_control_rec.process_entity = inv_globals.g_entity_trolin
            ) THEN
      FOR i IN 1 .. l_trolin_tbl.COUNT LOOP
        --debug('In Loop :'||to_char(I));
        IF l_trolin_tbl(i).return_status = fnd_api.g_ret_sts_error THEN
          x_return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END LOOP;
    END IF;
    --End Bug #4777248

    --  Get message count and data
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Process_Transfer_Order');
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END process_transfer_order;

  --  Start of Comments
  --  API name    Lock_Transfer_Order
  --  Type        Private
  --  Function
  --
  --  Pre-reqs
  --
  --  Parameters
  --
  --  Version     Current version = 1.0
  --              Initial version = 1.0
  --
  --  Notes
  --
  --  End of Comments

  PROCEDURE lock_transfer_order(
    p_api_version_number IN     NUMBER
  , p_init_msg_list      IN     VARCHAR2 := fnd_api.g_false
  , x_return_status      OUT    NOCOPY VARCHAR2
  , x_msg_count          OUT    NOCOPY NUMBER
  , x_msg_data           OUT    NOCOPY VARCHAR2
  , p_trohdr_rec         IN     inv_move_order_pub.trohdr_rec_type := inv_move_order_pub.g_miss_trohdr_rec
  , p_trolin_tbl         IN     inv_move_order_pub.trolin_tbl_type := inv_move_order_pub.g_miss_trolin_tbl
  , x_trohdr_rec         IN OUT    NOCOPY inv_move_order_pub.trohdr_rec_type
  , x_trolin_tbl         IN OUT    NOCOPY inv_move_order_pub.trolin_tbl_type
  ) IS
    l_api_version_number CONSTANT NUMBER                             := 1.0;
    l_api_name           CONSTANT VARCHAR2(30)                       := 'Lock_Transfer_Order';
    l_return_status               VARCHAR2(1)                        := fnd_api.g_ret_sts_success;
    l_trolin_rec                  inv_move_order_pub.trolin_rec_type;
  BEGIN
    --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number, p_api_version_number, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Set Savepoint
    SAVEPOINT lock_transfer_order_pvt;

    --  Lock trohdr
    IF p_trohdr_rec.operation = inv_globals.g_opr_lock THEN
      inv_trohdr_util.lock_row(p_trohdr_rec => p_trohdr_rec, x_trohdr_rec => x_trohdr_rec, x_return_status => l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    --  Lock trolin
    FOR i IN 1 .. p_trolin_tbl.COUNT LOOP
      IF p_trolin_tbl(i).operation = inv_globals.g_opr_lock THEN
        inv_trolin_util.lock_row(p_trolin_rec => p_trolin_tbl(i), x_trolin_rec => l_trolin_rec, x_return_status => l_return_status);

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        x_trolin_tbl(i)  := l_trolin_rec;
      END IF;
    END LOOP;

    --  Set return status
    x_return_status  := fnd_api.g_ret_sts_success;
    --  Get message count and data
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --  Rollback
      ROLLBACK TO lock_transfer_order_pvt;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --  Rollback
      ROLLBACK TO lock_transfer_order_pvt;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Lock_Transfer_Order');
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --  Rollback
      ROLLBACK TO lock_transfer_order_pvt;
  END lock_transfer_order;

  --  Start of Comments
  --  API name    Get_Transfer_Order
  --  Type        Private
  --  Function
  --
  --  Pre-reqs
  --
  --  Parameters
  --
  --  Version     Current version = 1.0
  --              Initial version = 1.0
  --
  --  Notes
  --
  --  End of Comments

  PROCEDURE get_transfer_order(
    p_api_version_number IN     NUMBER
  , p_init_msg_list      IN     VARCHAR2 := fnd_api.g_false
  , x_return_status      OUT    NOCOPY VARCHAR2
  , x_msg_count          OUT    NOCOPY NUMBER
  , x_msg_data           OUT    NOCOPY VARCHAR2
  , p_header_id          IN     NUMBER
  , x_trohdr_rec         OUT    NOCOPY inv_move_order_pub.trohdr_rec_type
  , x_trolin_tbl         OUT    NOCOPY inv_move_order_pub.trolin_tbl_type
  ) IS
    l_api_version_number CONSTANT NUMBER                             := 1.0;
    l_api_name           CONSTANT VARCHAR2(30)                       := 'Get_Transfer_Order';
    l_trohdr_rec                  inv_move_order_pub.trohdr_rec_type;
    l_trolin_tbl                  inv_move_order_pub.trolin_tbl_type;
  BEGIN
    --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number, p_api_version_number, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Get trohdr ( parent = trohdr )
    l_trohdr_rec     := inv_trohdr_util.query_row(p_header_id => p_header_id);
     --  Get trolin ( parent = trohdr )
    --debug('TRO : in get_transfer_order '||to_char(p_header_id)||' '||to_char(l_trohdr_rec.header_id));
    l_trolin_tbl     := inv_trolin_util.query_rows(p_header_id => l_trohdr_rec.header_id);
    --  Load out parameters
    x_trohdr_rec     := l_trohdr_rec;
    x_trolin_tbl     := l_trolin_tbl;
    --  Set return status
    x_return_status  := fnd_api.g_ret_sts_success;
    --  Get message count and data
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Get_Transfer_Order');
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_transfer_order;

  FUNCTION validate_from_subinventory(p_from_subinventory_code IN VARCHAR2, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_transaction_type_id IN NUMBER, p_restrict_subinventories_code IN NUMBER)
    RETURN BOOLEAN IS
    l_org                inv_validate.org;
    l_item               inv_validate.item;
    l_acct_txn           NUMBER;
    l_return             NUMBER;
    l_result             BOOLEAN;
    l_error_msg          VARCHAR2(2000);
    l_txn_action_id      NUMBER;
    l_txn_source_type_id NUMBER;
  BEGIN
    g_from_sub.secondary_inventory_name  := p_from_subinventory_code;
    l_org.organization_id                := p_organization_id;
    l_item.organization_id               := p_organization_id;
    l_item.inventory_item_id             := p_inventory_item_id;
    l_item.restrict_subinventories_code  := p_restrict_subinventories_code;

    IF (inv_validate.transaction_type(p_transaction_type_id, l_txn_action_id, l_txn_source_type_id) = inv_validate.t) THEN
      IF (l_txn_action_id = 1) THEN
        l_acct_txn  := 1;
      ELSE
        l_acct_txn  := 0;
      END IF;
    ELSE
      RETURN FALSE;
    END IF;

    l_return                             := inv_validate.from_subinventory(g_from_sub, l_org, l_item, l_acct_txn);

    IF (l_return = inv_validate.f) THEN
      l_result  := FALSE;
    ELSE
      l_result  := TRUE;
    END IF;

    RETURN l_result;
  END validate_from_subinventory;

  FUNCTION validate_to_subinventory(
    p_to_subinventory_code         IN VARCHAR2
  , p_organization_id              IN NUMBER
  , p_inventory_item_id            IN NUMBER
  , p_transaction_type_id          IN NUMBER
  , p_restrict_subinventories_code IN NUMBER
  , p_asset_item                   IN VARCHAR2
  , p_from_sub_asset               IN NUMBER
  )
    RETURN BOOLEAN IS
    l_org      inv_validate.org;
    l_item     inv_validate.item;
    l_sub      inv_validate.sub;
    l_acct_txn NUMBER;
    l_return   NUMBER;
    l_result   BOOLEAN;
  BEGIN
    l_sub.secondary_inventory_name       := p_to_subinventory_code;
    l_org.organization_id                := p_organization_id;
    l_item.organization_id               := p_organization_id;
    l_item.inventory_item_id             := p_inventory_item_id;
    l_item.restrict_subinventories_code  := p_restrict_subinventories_code;

    IF (p_transaction_type_id = 63) THEN
      l_acct_txn  := 1;
    ELSE
      l_acct_txn  := 0;
    END IF;

    l_item.inventory_asset_flag          := p_asset_item;
    --  g_from_sub.asset_inventory := p_from_sub_asset;
    l_return                             := inv_validate.to_subinventory(l_sub, l_org, l_item, g_from_sub, l_acct_txn);

    IF (l_return = inv_validate.f) THEN
      --l_error_msg := FND_MSG_PUB.GET(p_encoded => FND_API.G_FALSE);
      l_result  := FALSE;
    ELSE
      l_result  := TRUE;
    END IF;

    RETURN l_result;
  END validate_to_subinventory;

  --Update_Txn_Source_Line
  --
  -- This procedure updates the move order line indicated by p_line_id
  -- with a new transaction source line id (p_new_source_line_id).
  -- It also updates all of the allocation lines with the new source line id.
  -- This procedure is called from Shipping when the delivery detail is split
  -- after pick release has occurred, but before pick confirm.
  -- This procedure also transfers the detailed portion of the
  -- reservations from the old order line to the new order line
  PROCEDURE update_txn_source_line(p_line_id IN NUMBER,
				   p_new_source_line_id IN NUMBER)
    IS
       l_debug number;

       CURSOR cur_mmtt IS
	  SELECT reservation_id, transaction_quantity, primary_quantity
	    FROM mtl_material_transactions_temp
	    WHERE move_order_line_id = p_line_id;

       l_original_reservation_rec    inv_reservation_global.mtl_reservation_rec_type;
       l_new_reservation_rec         inv_reservation_global.mtl_reservation_rec_type;

       l_mtl_reservation_tbl         inv_reservation_global.mtl_reservation_tbl_type;
       l_mtl_reservation_tbl_count   NUMBER;
       l_reservation_id              NUMBER;
       l_original_serial_number      inv_reservation_global.serial_number_tbl_type;

       l_msg_count                   NUMBER;
       l_msg_data                    VARCHAR2(2000);
       l_return_status               VARCHAR2(1);
       l_error_code                  NUMBER;

  BEGIN
     -- Use cache to get value for l_debug
     IF g_is_pickrelease_set IS NULL THEN
        g_is_pickrelease_set := 2;
        IF INV_CACHE.is_pickrelease THEN
           g_is_pickrelease_set := 1;
        END IF;
     END IF;
     IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;

     l_debug := g_debug;

     UPDATE mtl_txn_request_lines
       SET txn_source_line_id = p_new_source_line_id
       WHERE line_id = p_line_id;

     UPDATE mtl_material_transactions_temp
       SET trx_source_line_id = p_new_source_line_id
       WHERE move_order_line_id = p_line_id;

     /* Rolling back changes made for bug 2919186.
     IF wsh_code_control.get_code_release_level >= '110509' THEN
	FOR rec_mmtt IN cur_mmtt LOOP
	   IF (rec_mmtt.reservation_id IS NOT NULL) THEN
	      l_original_reservation_rec.reservation_id  := rec_mmtt.reservation_id;

	      IF (l_debug = 1) THEN
		 debug('About to call inv_reservation_pub.query_reservations', 'update_txn_source_line');
	      END IF;

	      -- Query the reservation record corresponding to the allocation line
	      inv_reservation_pub.query_reservation
		(p_api_version_number         => 1.0,
		 x_return_status              => l_return_status,
		 x_msg_count                  => l_msg_count,
		 x_msg_data                   => l_msg_data,
		 p_query_input                => l_original_reservation_rec,
		 x_mtl_reservation_tbl        => l_mtl_reservation_tbl,
		 x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count,
		 x_error_code                 => l_error_code);

	      IF l_return_status = fnd_api.g_ret_sts_error THEN

		 IF (l_debug = 1) THEN
		    debug('Error from query_reservations', 'update_txn_source_line');
		 END IF;

		 RAISE fnd_api.g_exc_error;
	       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

		 IF (l_debug = 1) THEN
		    debug('Error from query_reservations', 'update_txn_source_line');
		 END IF;

		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;

	      IF (l_debug = 1) THEN
		 debug('Original Reservation_ID: ' || rec_mmtt.reservation_id, 'update_txn_source_line');
	      END IF;

	      -- Transfer reservation for the transaction quantity. Make sure
	      -- that the new reservation record has the appropriate quantity detailed
	      l_new_reservation_rec.demand_source_line_id         := p_new_source_line_id;
	      l_new_reservation_rec.primary_reservation_quantity  := Least(l_mtl_reservation_tbl(1).primary_reservation_quantity,
									   rec_mmtt.primary_quantity);
	      l_new_reservation_rec.reservation_quantity          := Least(l_mtl_reservation_tbl(1).reservation_quantity,
									   rec_mmtt.transaction_quantity);
	      l_new_reservation_rec.detailed_quantity             := Least(l_mtl_reservation_tbl(1).reservation_quantity,
									   rec_mmtt.transaction_quantity);

	      inv_reservation_pub.transfer_reservation
		(p_api_version_number         => 1.0,
		 p_init_msg_lst               => fnd_api.g_false,
		 x_return_status              => l_return_status,
		 x_msg_count                  => l_msg_count,
		 x_msg_data                   => l_msg_data,
		 p_original_rsv_rec           => l_mtl_reservation_tbl(1),
		 p_to_rsv_rec                 => l_new_reservation_rec,
		 p_original_serial_number     => l_original_serial_number,
		 p_to_serial_number           => l_original_serial_number,
		 p_validation_flag            => fnd_api.g_false,
		 x_to_reservation_id          => l_reservation_id);

	      IF l_return_status = fnd_api.g_ret_sts_error THEN
		 IF (l_debug = 1) THEN
		    debug('Return from transfer_reservation with error E', 'Finalize_Pick_Confirm');
		 END IF;

		 RAISE fnd_api.g_exc_error;
	       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

		 IF (l_debug = 1) THEN
		    debug('Return from transfer_reservation with error U', 'Finalize_Pick_Confirm');
		 END IF;

		 RAISE fnd_api.g_exc_unexpected_error;
	      END IF;

	      IF (l_debug = 1) THEN
		 debug('New Reservation_ID: '|| l_reservation_id, 'Finalize_Pick_Confirm');
		 debug('l_return_status is '|| l_return_status, 'Finalize_Pick_Confirm');
	      END IF;

	   END IF;
	END LOOP;
     END IF;
       */
  END update_txn_source_line;

  -- Bug 1620576
  -- This procedure is called from inltpu to delete the table
  -- mo_picked_quantity_tbl;
  -- This procedure is called everytime mmtt records are deleted in
  -- inltpu.
  PROCEDURE clear_picked_quantity IS
  BEGIN
    g_mo_picked_quantity_tbl.DELETE;
    g_rsv_picked_quantity_tbl.DELETE;
    g_mmtt_cache_tbl.DELETE;   --Bug: 4994950 (Actual bug #4762505)
  END clear_picked_quantity;

  -- This procedure deletes any unstaged reservations for a sales order if
  -- there are only staged or shipped line delivery detail lines for that order
  PROCEDURE clean_reservations
  ( p_source_line_id  IN  NUMBER
  , x_return_status   OUT NOCOPY  VARCHAR2
  , x_msg_count       OUT NOCOPY  NUMBER
  , x_msg_data        OUT NOCOPY  VARCHAR2
  ) IS
    -- bug 2115082
    -- should only delete reservations for supply type inventory
    CURSOR unstaged_reservations_csr IS
      SELECT reservation_id
        FROM mtl_reservations
       WHERE NVL(staged_flag, 'N') = 'N'
         AND supply_source_type_id = 13
         AND demand_source_type_id IN (2, 8)
         AND demand_source_line_id = p_source_line_id
         AND demand_source_line_detail IS NULL;

    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_unstaged_so_exists     NUMBER                                          := 0;
    l_mtl_reservation_rec    inv_reservation_global.mtl_reservation_rec_type;
    l_original_serial_number inv_reservation_global.serial_number_tbl_type;
    l_ato_item number := 0 ;
    l_debug number;
  BEGIN
    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    x_return_status  := fnd_api.g_ret_sts_success;
    IF (l_debug = 1) THEN
       DEBUG('Cleaning reservations', 'Clean_Reservations');
    END IF;

    -- If this is the last allocation line for the last move order
    -- line for the sales order then delete all the unstaged
    -- reservations for this record. This will also delete
    -- reservations which are against the backordered lines(except for
    -- ato items where the reservations are not deleted )

   -- Bug2621481 , Reservations are retained for ATO items.In case any
   -- reservations exist and delivery detail is in Backordered status then the
   -- reservations remain for ATO. All other cases where the item is not
   -- ATO and if there are no backordered delivery details process normally
   -- The profile WSH_RETAIN_ATO_RESERVATIONS is checked and if the value
   -- is set to Y and if the item is ATO then the reservations are not
   -- relieved.
   IF g_retain_ato_profile = 'Y' Then
   BEGIN
    SELECT     1
    INTO  l_ato_item
    FROM dual
    WHERE EXISTS (SELECT msi.inventory_item_id
                  FROM mtl_system_items msi, mtl_Reservations mtr
                  WHERE msi.inventory_item_id = mtr.inventory_item_id
                  AND msi.organization_id = mtr.organization_id
                  AND bom_item_type = 4
                  AND replenish_to_order_flag = 'Y'
                  AND mtr.demand_source_line_id  =  p_source_line_id
                  AND mtr.demand_source_line_detail IS NULL);
     EXCEPTION
     WHEN OTHERS THEN
       IF (l_debug = 1) THEN
          DEBUG('Not an ATO item ', 'Clean_Reservations');
       END IF;
       l_ato_item := 0;
    END;
   END IF;
   -- If l_ato_item = 1 then item is ATO item  and proceed to check if
   -- backordered or  'R' and 'S' delivery details exist
   -- The reservations against these lines are not relieved and the
   -- value of l_unstaged_so_exists is set to 1
    IF l_ato_item = 1 THEN
             BEGIN
              SELECT 1
              INTO  l_unstaged_so_exists
              FROM dual
              WHERE EXISTS ( SELECT delivery_Detail_id
                             FROM wsh_delivery_Details
                             WHERE source_line_id = p_source_line_id
                             AND released_status in ( 'B','R','S'));
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  IF (l_debug = 1) THEN
                     DEBUG('No Backordered ATO reservation', 'Clean_Reservations');
                  END IF;
                  l_unstaged_so_exists := 0;
             END;
    ELSE

    --Bug#2666971. Reservations were not being cleared for
    --orders that were in status 'D'(Cancelled) or 'X'(Not Applicable)
    --Changed the below sql. the earlier condition was
    --AND (released_status <> 'Y' AND released_status <> 'C'
    --AND released_status <> 'B'

    --Bug 6264551, Adding 'B' to retain reservation for backordered lines as well
    --this is to retain the manually created reservations prior to pick release.

     BEGIN

        SELECT 1
          INTO l_unstaged_so_exists
          FROM DUAL
         WHERE EXISTS( SELECT /*+ index(wsh_delivery_details WSH_DELIVERY_DETAILS_N3) */ delivery_detail_id
                         FROM wsh_delivery_details
                        WHERE source_line_id = p_source_line_id
                          AND (released_status IN ('B','R','S')));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
           DEBUG('No unstaged SO', 'Clean_Reservations');
        END IF;
        l_unstaged_so_exists  := 0;
    END;
 END IF;

    IF NVL(l_unstaged_so_exists, 0) <> 1 THEN
      -- The current line was the last move order line for the
      -- sales order
      FOR l_unstaged_reservation IN unstaged_reservations_csr LOOP
        l_mtl_reservation_rec.reservation_id  := l_unstaged_reservation.reservation_id;
        IF (l_debug = 1) THEN
           DEBUG('Deleting reservation: '|| l_unstaged_reservation.reservation_id, 'Clean_Reservations');
        END IF;
        -- {{
        -- Create a crossdock peg for a partial qty of sales order line
        -- and pick release the rest from inventory.  Before receipt
        -- of crossdock material, stage the move order line from Inventory.
        -- Ensure that the crossdock peg is not deleted }}
        inv_reservation_pub.delete_reservation(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_true
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_rsv_rec                    => l_mtl_reservation_rec
        , p_serial_number              => l_original_serial_number
        );
        IF (l_debug = 1) THEN
           DEBUG('after delete reservation return status is '|| l_return_status, 'Clean_Reservations');
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Clean Reservations');
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END clean_reservations;

  --
  -- Finalize pick confirm processes the move orders that are being
  -- picked. In case of pick wave move orders it handles the reservations and
  -- updates the shipping attributes.
  PROCEDURE finalize_pick_confirm
           (p_init_msg_list IN VARCHAR2 := fnd_api.g_false
           , x_return_status OUT NOCOPY VARCHAR2
           , x_msg_count OUT NOCOPY NUMBER
           , x_msg_data OUT NOCOPY VARCHAR2
           , p_transaction_temp_id IN NUMBER
           , p_transaction_id IN NUMBER
           , p_xfr_transaction_id NUMBER DEFAULT NULL
           )
  IS
    l_api_name    CONSTANT VARCHAR2(30) := 'Finalize_Pick_Confirm';

    l_mtl_reservation_tbl         inv_reservation_global.mtl_reservation_tbl_type;
    l_query_reservation_rec       inv_reservation_global.mtl_reservation_rec_type;
    l_mtl_reservation_rec         inv_reservation_global.mtl_reservation_rec_type;
    l_mtl_reservation_rec2        inv_reservation_global.mtl_reservation_rec_type;
    l_mtl_reservation_rec3        inv_reservation_global.mtl_reservation_rec_type;
    l_mtl_reservation_tbl_count   NUMBER;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_error_code                  NUMBER;
    l_trolin_rec                  inv_move_order_pub.trolin_rec_type;
    l_mmtt_rec                    inv_mo_line_detail_util.g_mmtt_rec;
    l_mmtt_count                  NUMBER;
    l_reservation_id              NUMBER;
    l_original_serial_number      inv_reservation_global.serial_number_tbl_type;
    l_to_serial_number            inv_reservation_global.serial_number_tbl_type;
    l_shipping_attr               wsh_interface.changedattributetabtype;
    l_source_header_id            NUMBER;
    l_source_line_id              NUMBER;
    l_delivery_detail_id          NUMBER;
    l_move_order_type             NUMBER;
    l_quantity_reserved           NUMBER;
    l_message                     VARCHAR2(2000);
    l_released_status             VARCHAR2(1);
    l_customer_item_id            NUMBER;
    l_subinventory                VARCHAR2(20);
    l_locator_id                  NUMBER;
    l_lot_count                   NUMBER;
    l_lot_control_code            NUMBER;
    l_serial_control_code         NUMBER;
    l_serial_trx_temp_id          NUMBER;
    l_transaction_temp_id         NUMBER;
    l_lot_number                  VARCHAR2(80);
    l_previous_lot_number         VARCHAR2(80) := '@';
    l_lot_primary_quantity        NUMBER;
    l_lot_transaction_quantity    NUMBER;
    l_lot_secondary_quantity      NUMBER;
    l_lot_secondary_uom           VARCHAR2(25);
    l_serial_number               VARCHAR2(30);
    l_serial_secondary_quantity   NUMBER;
    l_reservable_type             NUMBER;
    l_reservable_type_item        NUMBER;
    l_action_flag                 VARCHAR2(1);
    l_transaction_quantity        NUMBER;
    l_pending_quantity            NUMBER;
    l_primary_pending_quantity    NUMBER;
    l_mmt_transaction_quantity    NUMBER;
    l_rsv_primary_quantity        NUMBER;
    l_rsv_detailed_quantity       NUMBER;
    l_mmtt_rsv_quantity           NUMBER;
    l_rsv_changed                 BOOLEAN;
    l_remaining_quantity          NUMBER;
    l_unalloc_quantity            NUMBER;

    l_sec_transaction_quantity        NUMBER;
    l_sec_pending_quantity            NUMBER;
    l_sec_mmt_transaction_quantity    NUMBER;
    l_sec_rsv_quantity                NUMBER;
    l_sec_rsv_detailed_quantity       NUMBER;
    l_sec_mmtt_rsv_quantity           NUMBER;
    l_sec_rsv_changed                 BOOLEAN;
    l_sec_remaining_quantity          NUMBER;
    l_sec_unalloc_quantity            NUMBER;
    l_grade_code		      VARCHAR2(150);
    l_reservable_type_lot             NUMBER;

    -- Contains the portion of the quantity in the current MMTT line, which
    -- will be used to update shipping attributes and reservations. This is required
    -- for reduction in the sales order quantity
    l_shipping_quantity           NUMBER                                          := 0;
    l_primary_shipping_quantity   NUMBER                                          := 0;
    l_lot_shipping_quantity       NUMBER                                          := 0;
    l_lot_prim_shipping_quantity  NUMBER                                          := 0;
    l_remaining_shipping_quantity NUMBER                                          := 0;

    l_sec_shipping_quantity           NUMBER                                          := 0;
    l_sec_lot_shipping_quantity       NUMBER                                          := 0;
    l_sec_remaining_shp_quantity      NUMBER                                          := 0;

    l_ser_prim_shipping_quantity  NUMBER                                          := 0;
    l_serial_quantity             NUMBER                                          := 0;
    l_unstaged_so_exists          NUMBER                                          := 0;
    l_update_shipping             BOOLEAN;
    l_lpn_id                      NUMBER;
    l_serial_transaction_temp_id  NUMBER;
    l_dummy_num                   NUMBER;
    l_container_name		  VARCHAR2(30);
    l_new_container_name          VARCHAR2(30);
    l_status_code                 VARCHAR2(3);
    l_container_delivery_det_id   NUMBER;
    l_container_rec               wsh_container_grp.changedattributetabtype;
    l_InvPCInRecType              wsh_integration.invpcinrectype;
    l_wms_org_flag                BOOLEAN;
    l_omh_installed               NUMBER;
    l_catch_weight_enabled        VARCHAR(30);
    l_organization_id             NUMBER;            --For Bug#3153166
    l_return_value                BOOLEAN := TRUE;   --For Bug#3153166
    l_primary_uom_code            VARCHAR2(3); --INVCONV
    l_secondary_uom_code          VARCHAR2(3); --INVCONV
    l_tracking_quantity_ind       VARCHAR2(30); --INVCONV
    l_wip_entity_type             NUMBER; --INVCONV
    l_hash_value                  NUMBER; -- Bug 5535030
    /*** {{ R12 Enhanced reservations code changes ***/
    l_serial_count                NUMBER;
    /*** End R12 }} ***/

--INVCONV
    CURSOR  get_item_details (l_org_id NUMBER, l_item_id NUMBER) IS
      SELECT primary_uom_code, secondary_uom_code, tracking_quantity_ind
      FROM   mtl_system_items
      WHERE  inventory_item_id = l_item_id
      AND    organization_id   = l_org_id;
--INVCONV
    CURSOR lot_csr(l_trx_temp_id NUMBER) IS
      SELECT lot_number
           , primary_quantity
           , transaction_quantity
           , secondary_quantity
           , secondary_unit_of_measure
           , serial_transaction_temp_id
           , grade_code
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = l_trx_temp_id
       ORDER BY lot_number;

    CURSOR serial_csr(l_trx_temp_id NUMBER, l_lot_control_code NUMBER, l_ser_trx_temp_id NUMBER,
                      l_org_id NUMBER, l_item_id NUMBER) IS
      SELECT msn.serial_number
        FROM mtl_serial_numbers msn, mtl_serial_numbers_temp msnt
       WHERE msnt.transaction_temp_id = DECODE(l_lot_control_code, 1, l_trx_temp_id, l_ser_trx_temp_id)
         AND msn.current_organization_id = l_org_id
         AND msn.inventory_item_id = l_item_id
         AND msn.serial_number BETWEEN msnt.fm_serial_number AND NVL(msnt.to_serial_number, msnt.fm_serial_number)
         AND length(msn.serial_number) = length(msnt.fm_serial_number);

    CURSOR reservations_csr IS
      SELECT reservation_id
           , primary_reservation_quantity
           , detailed_quantity
        FROM mtl_reservations
       WHERE demand_source_line_id = l_trolin_rec.txn_source_line_id
         AND NVL(detailed_quantity, 0) > 0
         AND NVL(staged_flag, 'N') = 'N'
         AND demand_source_line_detail IS NULL;

    CURSOR unstaged_reservations_csr IS
      SELECT reservation_id
        FROM mtl_reservations
       WHERE NVL(staged_flag, 'N') = 'N'
         AND demand_source_line_id = l_trolin_rec.txn_source_line_id
         AND demand_source_line_detail IS NULL;


    /*** {{ R12 Enhanced reservations code changes ***/
    CURSOR serial_reserved_csr(l_trx_temp_id NUMBER, l_reservation_id NUMBER) IS
      SELECT msn.serial_number
        FROM mtl_serial_numbers msn, mtl_serial_numbers_temp msnt
       WHERE msnt.transaction_temp_id = l_trx_temp_id
         AND msn.serial_number BETWEEN msnt.fm_serial_number AND NVL(msnt.to_serial_number, msnt.fm_serial_number)
         AND length(msn.serial_number) = length(msnt.fm_serial_number)
         AND msn.reservation_id = l_reservation_id;
    /*** End R12 }} ***/

    Cursor get_wip_entity_type is
      Select entity_type
      From wip_entities
      Where wip_entity_id = l_trolin_rec.txn_source_id;

   -- Bug5950172.Added following cursor
   CURSOR mmtt_pending_qty_csr (  p_mo_line_id NUMBER) IS
       SELECT  ABS(transaction_quantity) , mmtt.transaction_uom, ABS(primary_quantity), NVL(ABS(secondary_transaction_quantity), 0)
         FROM mtl_material_transactions_temp mmtt
       WHERE move_order_line_id = p_mo_line_id;

      l_curr_mmtt_txn_uom   VARCHAR2(3) ; -- Bug5950172
      l_curr_mmtt_txn_qty   NUMBER;  -- Bug5950172
      l_curr_mmtt_pri_qty   NUMBER;  -- Bug5950172
      l_curr_mmtt_sec_qty   NUMBER;  -- Bug5950172

    l_debug number;
    l_other_mmtt_rec              NUMBER;
    l_mo_line_closed_flag         BOOLEAN := FALSE;           --Bug 4994950

  BEGIN
    -- Use cache to get value for l_debug
    IF g_is_pickrelease_set IS NULL THEN
       g_is_pickrelease_set := 2;
       IF INV_CACHE.is_pickrelease THEN
          g_is_pickrelease_set := 1;
       END IF;
    END IF;
    IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
       DEBUG('Call to Finalize_Pick_Confirm trxtmpid='||p_transaction_temp_id||' trxid='||p_transaction_id||' xfrtxnid='||p_xfr_transaction_id, 'Finalize Pick Confirm');
    END IF;

    IF p_transaction_temp_id IS NULL THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- query the move order line detail for the move order line
    -- detail id passed in
    l_mmtt_rec                          := inv_mo_line_detail_util.query_row(p_transaction_temp_id);
--INVCONV
    OPEN get_item_details (l_mmtt_rec.organization_id, l_mmtt_rec.inventory_item_id);
    FETCH get_item_details INTO l_primary_uom_code, l_secondary_uom_code, l_tracking_quantity_ind;
    CLOSE get_item_details;
--INVCONV

    IF (l_debug = 1) THEN
       DEBUG('after calling mold_query_row', 'Finalize_Pick_Confirm');
       DEBUG('move order line id is '|| l_mmtt_rec.move_order_line_id, 'Finalize_Pick_Confirm');
    END IF;
    -- query the move order line for that move order line detail
    l_trolin_rec                        := inv_trolin_util.query_row(l_mmtt_rec.move_order_line_id);
    IF (l_debug = 1) THEN
       DEBUG('after calling trolin query row', 'Finalize_Pick_Confirm');
       DEBUG('transaction_quantity is '|| l_mmtt_rec.transaction_quantity, 'Finalize_Pick_Confirm');
       DEBUG('quantity detailed '|| l_trolin_rec.quantity_detailed, 'Finalize_Pick_Confirm');
       DEBUG('quantity required '|| l_trolin_rec.required_quantity, 'Finalize_Pick_Confirm');
       DEBUG('secondary quantity detailed '|| l_trolin_rec.secondary_quantity_detailed, 'Finalize_Pick_Confirm');
       DEBUG('secondary quantity required '|| l_trolin_rec.secondary_required_quantity, 'Finalize_Pick_Confirm');
    END IF;

    -- Cannot transact a closed move order line
    IF l_trolin_rec.line_status = 5 THEN
       fnd_message.set_name('INV', 'INV_CANNOT_TRX_CLOSED_MO');
       x_return_status  := fnd_api.g_ret_sts_error;
       RAISE fnd_api.g_exc_error;
    END IF;

    -- update the quantity delivered in the move order line record
    IF l_trolin_rec.uom_code = l_mmtt_rec.transaction_uom
    THEN
       l_trolin_rec.quantity_delivered := NVL(l_trolin_rec.quantity_delivered, 0)
                                          + ABS(l_mmtt_rec.transaction_quantity);
    ELSE
       l_trolin_rec.quantity_delivered := NVL(l_trolin_rec.quantity_delivered, 0)
                                          + ABS( inv_convert.inv_um_convert
                                                 ( item_id       => l_mmtt_rec.inventory_item_id
                                                 , precision     => NULL
                                                 , from_quantity => l_mmtt_rec.transaction_quantity
                                                 , from_unit     => l_mmtt_rec.transaction_uom
                                                 , to_unit       => l_trolin_rec.uom_code
                                                 , from_name     => NULL
                                                 , to_name       => NULL
                                                 )
                                               );
    END IF;

--INVCONV
    IF l_tracking_quantity_ind <> 'P' THEN
       l_trolin_rec.secondary_quantity_delivered := NVL(l_trolin_rec.secondary_quantity_delivered, 0)
                                          + ABS(l_mmtt_rec.secondary_transaction_quantity);
    END IF;
--INVCONV
    IF (l_debug = 1) THEN
       DEBUG('quantity_delivered = '|| l_trolin_rec.quantity_delivered, 'Finalize_Pick_Confirm');
       DEBUG('secondary_quantity_delivered = '|| l_trolin_rec.secondary_quantity_delivered, 'Finalize_Pick_Confirm');
    END IF;

    SELECT moh.move_order_type
      INTO l_move_order_type
      FROM mtl_txn_request_headers moh, mtl_txn_request_lines mol
     WHERE mol.line_id = l_trolin_rec.line_id
       AND mol.header_id = moh.header_id;

    IF (l_debug = 1) THEN
       DEBUG('after get move_order_type '|| l_move_order_type, 'Finalize_Pick_Confirm');
    END IF;

    -- Check if the organization is a WMS organization
    --for Bug#3153166: Performace Issue, Will Check the cache before
    --calling inv_install.adv_inv_installed, to check wms installed
    --or not.
    /*l_wms_org_flag := wms_install.check_install
      (x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_organization_id => l_trolin_rec.organization_id);*/

    l_organization_id := l_trolin_rec.organization_id;
    l_return_value := INV_CACHE.set_wms_installed(l_organization_id);
    If NOT l_return_value Then
          RAISE fnd_api.g_exc_unexpected_error;
    End If;
    l_wms_org_flag := INV_CACHE.wms_installed;

    -- End of Changes for Bug#3153166

    -- Cannot overpick in a WMS organization in Release I and belw.Feature enabled in J:Bug 3415741
    IF  (INV_CONTROL.G_CURRENT_RELEASE_LEVEL < INV_RELEASE.G_J_RELEASE_LEVEL) THEN
      IF (l_debug = 1) THEN
        DEBUG('Patchset Level I:Overpicking not allowed for WMS orgs', 'Finalize_Pick_Confirm');
      END IF;
      IF l_wms_org_flag AND l_move_order_type = 3
        AND l_trolin_rec.quantity_delivered > l_trolin_rec.quantity THEN
        fnd_message.set_name('INV', 'INV_CANNOT_OVERPICK_WMS_SO');
        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    -- Bug 2666620: BackFlush MO Type Removed
    IF l_move_order_type IN (3, 5) THEN -- Pick wave or WIP move order
      -- If the current MMTT line is the one that causes the quantity
      -- delivered > required quantity, store this information. We will update
      -- the reservations and the delivery details appropriately with this
      -- Also if the required quantity is not less than quantity we allow overpicking
      If l_move_order_type = 5 then   -- try to see if it is WIP or GME
        Open get_wip_entity_type;
        Fetch get_wip_entity_type into l_wip_entity_type;
        Close get_wip_entity_type;
      End if;
      IF  (l_trolin_rec.quantity_delivered >= NVL(l_trolin_rec.required_quantity, l_trolin_rec.quantity))
          AND (NVL(l_trolin_rec.required_quantity, l_trolin_rec.quantity) < l_trolin_rec.quantity) THEN
        l_shipping_quantity       := NVL(l_trolin_rec.required_quantity, l_trolin_rec.quantity)
                                      - (l_trolin_rec.quantity_delivered - ABS(l_mmtt_rec.transaction_quantity));
        l_sec_shipping_quantity   := NVL(l_trolin_rec.secondary_required_quantity, l_trolin_rec.secondary_quantity)
                                      - (l_trolin_rec.secondary_quantity_delivered - ABS(l_mmtt_rec.secondary_transaction_quantity));
        l_trolin_rec.line_status  := 9; -- Set the move order status to cancelled
        l_trolin_rec.status_date  := SYSDATE; -- Bug 8563083

        IF l_shipping_quantity < 0 THEN
          l_shipping_quantity          := 0;
          l_sec_shipping_quantity      := 0;
          l_primary_shipping_quantity  := 0;
        ELSE
          IF l_mmtt_rec.transaction_uom <> l_mmtt_rec.item_primary_uom_code THEN
            l_primary_shipping_quantity  := inv_convert.inv_um_convert(
                                              item_id                      => l_mmtt_rec.inventory_item_id
                                            , PRECISION                    => NULL
                                            , from_quantity                => l_shipping_quantity
                                            , from_unit                    => l_mmtt_rec.transaction_uom
                                            , to_unit                      => l_mmtt_rec.item_primary_uom_code
                                            , from_name                    => NULL
                                            , to_name                      => NULL
                                            );

            IF (l_primary_shipping_quantity = -99999) THEN
              IF (l_debug = 1) THEN
                 DEBUG('Cannot convert uom to primary uom', 'Finalize_Pick_Confirm');
              END IF;
              fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
              fnd_message.set_token('UOM', l_mtl_reservation_rec.primary_uom_code);
              fnd_message.set_token('ROUTINE', 'Pick Confirm process');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          ELSE
            l_primary_shipping_quantity  := l_shipping_quantity;
          END IF;
        END IF;
      ELSE
        l_shipping_quantity          := ABS(l_mmtt_rec.transaction_quantity);
        l_sec_shipping_quantity      := ABS(l_mmtt_rec.secondary_transaction_quantity);
        l_primary_shipping_quantity  := ABS(l_mmtt_rec.primary_quantity);
      END IF;

      IF (l_debug = 1) THEN
         DEBUG('Shipping Quantity: '|| l_shipping_quantity, 'Finalize_Pick_Confirm');
         DEBUG('sec Shipping Quantity: '|| l_sec_shipping_quantity, 'Finalize_Pick_Confirm');
      END IF;

      -- Query MMTT to get the quantity remaining to be picked for this line;
      -- Pending quantity includes the current transaction;
      -- Remaining quantity does not include the current transaction.
      -- Pending quantity is used to update shipping;
      -- primary_pending_quantity is used to update reservations;
      -- remaining_quantity is used to update move orders.

      /*Bug5950712. start of fix */
      l_primary_pending_quantity := 0 ;
      l_pending_quantity         := 0 ;
      l_sec_pending_quantity     := 0 ;
      OPEN mmtt_pending_qty_csr(l_trolin_rec.line_id);
       LOOP
         FETCH   mmtt_pending_qty_csr INTO l_curr_mmtt_txn_qty, l_curr_mmtt_txn_uom , l_curr_mmtt_pri_qty, l_curr_mmtt_sec_qty ;
         EXIT WHEN mmtt_pending_qty_csr%NOTFOUND;
         l_primary_pending_quantity := l_primary_pending_quantity +  l_curr_mmtt_pri_qty ;
         l_sec_pending_quantity   :=   l_sec_pending_quantity + l_curr_mmtt_sec_qty ;
         IF ( l_mmtt_rec.transaction_uom <> l_curr_mmtt_txn_uom ) THEN
             l_curr_mmtt_txn_qty :=  inv_convert.inv_um_convert(
                                              item_id                      => l_mmtt_rec.inventory_item_id
                                            , precision                    => NULL
                                            , from_quantity                => l_curr_mmtt_txn_qty
                                            , from_unit                    => l_curr_mmtt_txn_uom
                                            , to_unit                      => l_mmtt_rec.transaction_uom
                                            , from_name                    => NULL
                                            , to_name                      => NULL );

             IF (l_curr_mmtt_txn_qty  = -99999) THEN
               IF (l_debug = 1) THEN
                  DEBUG('Cannot convert uom of other MMTTs to current transaction_uom uom', 'Finalize_Pick_Confirm');
               END IF;
               fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
               fnd_message.set_token('UOM1', l_curr_mmtt_txn_uom);
               fnd_message.set_token('UOM2', l_mmtt_rec.transaction_uom);
               fnd_message.set_token('ROUTINE', 'Pick Confirm process');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_unexpected_error;
             END IF;
         END IF;

         l_pending_quantity := l_pending_quantity + l_curr_mmtt_txn_qty ;
      END LOOP;
      CLOSE  mmtt_pending_qty_csr;
      /*Bug5950172. End of fix */

     /*5950172.Commented the following
      SELECT NVL(SUM(ABS(transaction_quantity)), 0)
           , NVL(SUM(ABS(primary_quantity)), 0)
           , NVL(SUM(ABS(secondary_transaction_quantity)), 0)
        INTO l_pending_quantity
           , l_primary_pending_quantity
           , l_sec_pending_quantity
        FROM mtl_material_transactions_temp
       WHERE move_order_line_id = l_trolin_rec.line_id; */

      IF (l_debug = 1) THEN
         DEBUG('Pending Quantity from MMTT: '|| l_pending_quantity, 'Finalize_Pick_Confirm');
         DEBUG('Pending Sec Quantity from MMTT: '|| l_sec_pending_quantity, 'Finalize_Pick_Confirm');
      END IF;

      --Because MMTT records are deleted after all of the records
      -- are processed for a transaction_header_Id, it's possible
      -- that records exist in MMTT which are no longer pending -
      -- finalize_pick_confirm has already been called on these records.
      -- So we don't overcount the pending quantity, we keep track
      -- of the quantity we've already picked in a global table.  The
      -- table gets deleted when MMTT records are deleted.
      IF g_mo_picked_quantity_tbl.EXISTS(l_trolin_rec.line_id) THEN
        IF (l_debug = 1) THEN
           DEBUG('Cached picked quantity: '|| g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_quantity, 'Finalize_Pick_Confirm');
           DEBUG('Cached sec picked quantity: '|| g_mo_picked_quantity_tbl(l_trolin_rec.line_id).sec_picked_quantity, 'Finalize_Pick_Confirm');
           DEBUG('Cached primary picked quantity: '|| g_mo_picked_quantity_tbl(l_trolin_rec.line_id).primary_picked_quantity, 'Finalize_Pick_Confirm');
           DEBUG('Cached picked uom: '|| g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_uom, 'Finalize_Pick_Confirm');
        END IF;

	--Bug5950172. Fix starts
	IF (g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_uom <> l_mmtt_rec.transaction_uom ) THEN
          g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_quantity :=  inv_convert.inv_um_convert(
                                             item_id                      => l_mmtt_rec.inventory_item_id
                                           , precision                    => NULL
                                           , from_quantity                => g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_quantity
                                           , from_unit                    => g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_uom
                                           , to_unit                      => l_mmtt_rec.transaction_uom
                                           , from_name                    => NULL
                                           , to_name                      => NULL );
            IF (g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_quantity  = -99999) THEN
              IF (l_debug = 1) THEN
                 DEBUG('Cannot convert uom of cached qty to current transaction_uom ', 'Finalize_Pick_Confirm');
              END IF;
              fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
              fnd_message.set_token('UOM1', g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_uom );
              fnd_message.set_token('UOM2', l_mmtt_rec.transaction_uom);
              fnd_message.set_token('ROUTINE', 'Pick Confirm process');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
	   g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_uom      := l_mmtt_rec.transaction_uom ;
	END If;
      	--Bug5950172. Fix Ends

        l_pending_quantity                                                      := l_pending_quantity - g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_quantity;
        l_sec_pending_quantity                                                  := l_sec_pending_quantity - g_mo_picked_quantity_tbl(l_trolin_rec.line_id).sec_picked_quantity;
        l_primary_pending_quantity                                              := l_primary_pending_quantity - g_mo_picked_quantity_tbl(l_trolin_rec.line_id).primary_picked_quantity;
        g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_quantity          := g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_quantity + ABS(l_mmtt_rec.transaction_quantity);
        g_mo_picked_quantity_tbl(l_trolin_rec.line_id).sec_picked_quantity      := g_mo_picked_quantity_tbl(l_trolin_rec.line_id).sec_picked_quantity + ABS(l_mmtt_rec.secondary_transaction_quantity);
        g_mo_picked_quantity_tbl(l_trolin_rec.line_id).primary_picked_quantity  := g_mo_picked_quantity_tbl(l_trolin_rec.line_id).primary_picked_quantity + ABS(l_mmtt_rec.primary_quantity);
      ELSE
        g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_quantity          := ABS(l_mmtt_rec.transaction_quantity);
        g_mo_picked_quantity_tbl(l_trolin_rec.line_id).sec_picked_quantity      := ABS(l_mmtt_rec.secondary_transaction_quantity);
        g_mo_picked_quantity_tbl(l_trolin_rec.line_id).primary_picked_quantity  := ABS(l_mmtt_rec.primary_quantity);
	g_mo_picked_quantity_tbl(l_trolin_rec.line_id).picked_uom               := l_mmtt_rec.transaction_uom ; --Bug5950172
      END IF;

      l_remaining_quantity  := l_pending_quantity - ABS(l_mmtt_rec.transaction_quantity);
      l_sec_remaining_quantity  := l_sec_pending_quantity - ABS(l_mmtt_rec.secondary_transaction_quantity);
      IF (l_debug = 1) THEN
         DEBUG('Remaining Quantity: '|| l_remaining_quantity, 'Finalize_Pick_Confirm');
         DEBUG('Sec Remaining Quantity: '|| l_sec_remaining_quantity, 'Finalize_Pick_Confirm');
      END IF;

      IF NVL(l_trolin_rec.required_quantity, l_trolin_rec.quantity) < l_trolin_rec.quantity THEN
        l_pending_quantity  := LEAST(l_pending_quantity, l_trolin_rec.required_quantity - l_trolin_rec.quantity_delivered + l_shipping_quantity);
        l_sec_pending_quantity  := LEAST(l_sec_pending_quantity, l_trolin_rec.secondary_required_quantity - l_trolin_rec.secondary_quantity_delivered + l_sec_shipping_quantity);

        IF l_pending_quantity < 0 THEN
          l_pending_quantity  := 0;
          l_sec_pending_quantity  := 0;
        END IF;
      END IF;

      IF (l_debug = 1) THEN
         DEBUG('Pending Quantity: '|| l_pending_quantity, 'Finalize_Pick_Confirm');
         DEBUG('Sec Pending Quantity: '|| l_sec_pending_quantity, 'Finalize_Pick_Confirm');
      END IF;

      IF  (l_mmtt_rec.transaction_uom <> l_mmtt_rec.item_primary_uom_code)
          AND l_pending_quantity <> 0 THEN
        l_primary_pending_quantity  := inv_convert.inv_um_convert(
                                         item_id                      => l_mmtt_rec.inventory_item_id
                                       , PRECISION                    => NULL
                                       , from_quantity                => l_pending_quantity
                                       , from_unit                    => l_mmtt_rec.transaction_uom
                                       , to_unit                      => l_mmtt_rec.item_primary_uom_code
                                       , from_name                    => NULL
                                       , to_name                      => NULL
                                       );

        IF (l_primary_pending_quantity = -99999) THEN
          IF (l_debug = 1) THEN
             DEBUG('Cannot convert uom to primary uom', 'Finalize_Pick_Confirm');
          END IF;
          fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
          fnd_message.set_token('UOM', l_mtl_reservation_rec.primary_uom_code);
          fnd_message.set_token('ROUTINE', 'Pick Confirm process');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE
        l_primary_pending_quantity  := l_pending_quantity;
      END IF;

      IF l_shipping_quantity = ABS(l_mmtt_rec.transaction_quantity) THEN
        l_remaining_shipping_quantity  := l_remaining_quantity;
      ELSE
        l_remaining_shipping_quantity  := 0;
      END IF;

      IF (l_debug = 1) THEN
         DEBUG('remaining shipping quantity = '|| l_remaining_shipping_quantity, 'Finalize_Pick_Confirm');
      END IF;

      IF l_mmtt_rec.reservation_id IS NOT NULL THEN
        SELECT NVL(SUM(ABS(primary_quantity)), 0)
            ,  NVL(SUM(ABS(secondary_transaction_quantity)), 0)
          INTO l_rsv_primary_quantity
            ,  l_sec_rsv_quantity
          FROM mtl_material_transactions_temp
         WHERE reservation_id = l_mmtt_rec.reservation_id;

        IF g_rsv_picked_quantity_tbl.EXISTS(l_mmtt_rec.reservation_id) THEN
          l_rsv_primary_quantity
                    := l_rsv_primary_quantity
                          - g_rsv_picked_quantity_tbl(l_mmtt_rec.reservation_id).picked_quantity;
          l_sec_rsv_quantity
                    := l_sec_rsv_quantity
                          - g_rsv_picked_quantity_tbl(l_mmtt_rec.reservation_id).sec_picked_quantity;
          g_rsv_picked_quantity_tbl(l_mmtt_rec.reservation_id).picked_quantity
                    := g_rsv_picked_quantity_tbl(l_mmtt_rec.reservation_id).picked_quantity
                             + ABS(l_mmtt_rec.primary_quantity);
          g_rsv_picked_quantity_tbl(l_mmtt_rec.reservation_id).sec_picked_quantity
                    := g_rsv_picked_quantity_tbl(l_mmtt_rec.reservation_id).sec_picked_quantity
                             + ABS(l_mmtt_rec.secondary_transaction_quantity);
        ELSE
          g_rsv_picked_quantity_tbl(l_mmtt_rec.reservation_id).picked_quantity
                    := ABS(l_mmtt_rec.primary_quantity);
          g_rsv_picked_quantity_tbl(l_mmtt_rec.reservation_id).sec_picked_quantity
                    := ABS(l_mmtt_rec.secondary_transaction_quantity);
        END IF;
      ELSE
        l_rsv_primary_quantity  := 0;
        l_sec_rsv_quantity  := 0;
      END IF;

      IF (l_debug = 1) THEN
         DEBUG('pending quantity = '|| l_pending_quantity, 'Finalize_Pick_Confirm');
         DEBUG('sec pending quantity = '|| l_sec_pending_quantity, 'Finalize_Pick_Confirm');
         DEBUG('prim pending quantity = '|| l_primary_pending_quantity, 'Finalize_Pick_Confirm');
         DEBUG('remaining quantity = '|| l_remaining_quantity, 'Finalize_Pick_Confirm');
         DEBUG('sec remaining quantity = '|| l_sec_remaining_quantity, 'Finalize_Pick_Confirm');
         DEBUG('total allocatd rsv quantity = '|| l_rsv_primary_quantity, 'Finalize_Pick_Confirm');
         DEBUG('total sec allocatd rsv quantity = '|| l_sec_rsv_quantity, 'Finalize_Pick_Confirm');
      END IF;
    END IF; -- Move order type IN 3,5

    -- The move order lines are closed when
    -- a.  for pick wave and WIP move orders, the pending quantity = 0
    -- b.  for all other move orders, when quantity delivered >
    --     quantity requested
    -- Bug 2666620: BackFlush MO Type Removed
    IF (l_move_order_type IN (3, 5) AND l_remaining_quantity = 0)
       OR (l_move_order_type NOT IN (3, 5) AND l_trolin_rec.quantity_delivered >= l_trolin_rec.quantity)
    THEN
      -- If it is a WIP move order, and the line has been underpicked,
      -- unallocate the balance
      -- Bug 2666620: BackFlush MO Type Removed
      IF l_move_order_type = 5 and l_wip_entity_type not in (9,10) THEN   -- only for WIP not for GME
        l_unalloc_quantity  := l_trolin_rec.quantity - l_trolin_rec.quantity_delivered;

        IF l_unalloc_quantity > 0 THEN
          IF l_trolin_rec.uom_code <> l_mmtt_rec.item_primary_uom_code THEN
            l_unalloc_quantity  := inv_convert.inv_um_convert(
                                     item_id                      => l_mmtt_rec.inventory_item_id
                                   , PRECISION                    => NULL
                                   , from_quantity                => l_unalloc_quantity
                                   , from_unit                    => l_mmtt_rec.transaction_uom
                                   , to_unit                      => l_mmtt_rec.item_primary_uom_code
                                   , from_name                    => NULL
                                   , to_name                      => NULL
                                   );

            IF (l_unalloc_quantity = -99999) THEN
              IF (l_debug = 1) THEN
                 DEBUG('Calculating unalloc qty: cannot convert uom to primary uom', 'Finalize_Pick_Confirm');
              END IF;
              fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
              fnd_message.set_token('UOM', l_mmtt_rec.item_primary_uom_code);
              fnd_message.set_token('ROUTINE', 'Pick Confirm process');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF; -- if UOM code not primary UOM

          IF (l_debug = 1) THEN
             DEBUG(
               'Calling wip_picking_pub.unallocate_material with '
            || 'WIP entity ID='
            || TO_CHAR(l_trolin_rec.txn_source_id)
            || ', oper seq num='
            || TO_CHAR(l_trolin_rec.txn_source_line_id)
            || ', item ID='
            || TO_CHAR(l_trolin_rec.inventory_item_id)
            || ', rep sch ID='
            || TO_CHAR(l_trolin_rec.reference_id)
            || ', unalloc qty='
            || TO_CHAR(l_unalloc_quantity)
          , 'Finalize_Pick_Confirm'
          );
          END IF;
          wip_picking_pub.unallocate_material(
            p_wip_entity_id              => l_trolin_rec.txn_source_id
          , p_operation_seq_num          => l_trolin_rec.txn_source_line_id
          , p_inventory_item_id          => l_trolin_rec.inventory_item_id
          , p_repetitive_schedule_id     => l_trolin_rec.reference_id
          , p_primary_quantity           => l_unalloc_quantity
          , x_return_status              => l_return_status
          , x_msg_data                   => l_msg_data
          );

          IF l_return_status = 'L' THEN
            IF (l_debug = 1) THEN
               DEBUG('Error from wip_picking_pub.unallocate_material', 'Finalize_Pick_Confirm');
               DEBUG('Unable to lock the work order line for update', 'Finalize_Pick_Confirm');
            END IF;
            fnd_message.set_name('INV', 'INV_WIP_WORK_ORDER_LOCKED');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF (l_debug = 1) THEN
               DEBUG('Error from wip_picking_pub.unallocate_material', 'Finalize_Pick_Confirm');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF; -- if unalloc qty > 0
      END IF; -- if WIP move order (MO type is 5 or 7)

      IF (l_debug = 1) THEN
         DEBUG('old line_status is '|| l_trolin_rec.line_status, 'Finalize_Pick_Confirm');
         DEBUG('MO Line ID:'||TO_CHAR(l_trolin_rec.line_id)
               ||' TxnTmpID:'||TO_CHAR(l_mmtt_rec.transaction_temp_id), 'Finalize_Pick_Confirm');
      END IF;
      --
      -- Start Bug 4756651
      --
      BEGIN
       --
       SELECT COUNT(*)
       INTO l_other_mmtt_rec
       FROM mtl_material_transactions_temp
       WHERE move_order_line_id = l_trolin_rec.line_id
       AND transaction_temp_id <> l_mmtt_rec.transaction_temp_id;
       --
      EXCEPTION
       --
       WHEN NO_DATA_FOUND THEN
        l_other_mmtt_rec := 0;
      END;
      --
      IF (l_move_order_type = 2 AND l_other_mmtt_rec > 0) THEN
        IF (l_debug = 1) THEN
           DEBUG('Other allocations exist. Do not close the MO Line yet.', 'Finalize_Pick_Confirm');
        END IF;
      ELSE
        /* Bug:4994950(Actual bug is 4762505). Added the complete logic in the following IF condition
         * to consider the g_mmtt_cache table to close the move order line.
         */
        -- If there are pending allocations do not close the move order line
        IF (l_move_order_type <> 2 AND l_other_mmtt_rec > 0) THEN
          --Bug 4994950 :Start of code changes
          IF (g_mmtt_cache_tbl.EXISTS(l_trolin_rec.line_id) AND g_mmtt_cache_tbl(l_trolin_rec.line_id) > 0) THEN
            IF (l_debug = 1) THEN
              DEBUG('Other MMTT Count: ' || l_other_mmtt_rec, 'Finalize_Pick_Confirm');
              DEBUG('Processed MMTT Count: ' || g_mmtt_cache_tbl(l_trolin_rec.line_id), 'Finalize_Pick_Confirm');
            END IF;
            IF (l_other_mmtt_rec <> g_mmtt_cache_tbl(l_trolin_rec.line_id)) THEN
              IF (l_debug = 1) THEN
                DEBUG('There are other pending MMTTs yet to be processed. Do not close MO line', 'Finalize_Pick_Confirm');
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                DEBUG('All other MMTTs processed. Set MO line status to closed', 'Finalize_Pick_Confirm');
              END IF;
              l_trolin_rec.line_status  := 5;
              l_trolin_rec.status_date  := SYSDATE; -- Bug 8563083
              l_mo_line_closed_flag  :=TRUE;
              g_mmtt_cache_tbl.DELETE(l_trolin_rec.line_id);
            END IF;   --END IF l_other_mmtt_rec <> g_mmtt_cache_tbl.COUNT
          ELSE
            IF (l_debug = 1) THEN
              DEBUG('There are other pending MMTTs yet to be processed and cache is empty. Do not close MO line', 'Finalize_Pick_Confirm');
            END IF;
          END IF;   --END IF g_mmtt_cache_tbl.COUNT > 0
        --Bug 4994950 : End of code changes
        --No other pending allocations
        ELSE
          l_trolin_rec.line_status  := 5;
          l_trolin_rec.status_date  := SYSDATE; -- Bug 8563083
          l_mo_line_closed_flag :=TRUE;      --Bug:4994950
          IF (l_debug = 1) THEN
           DEBUG('Closing move order line', 'Finalize_Pick_Confirm');
          END IF;
          g_mmtt_cache_tbl.DELETE(l_trolin_rec.line_id);  --Bug:4994950
        END IF;
      END IF;
      --
      -- End Bug 4756651
      --
      -- For pick wave move orders, if we underpick, update the
      -- requested quantity of the move order line to reflect the actual
      -- quantity moved
      IF l_trolin_rec.quantity > l_trolin_rec.quantity_delivered THEN
        l_trolin_rec.quantity  := l_trolin_rec.quantity_delivered;
      END IF;

    END IF;

    l_trolin_rec.transaction_header_id  := l_mmtt_rec.transaction_header_id;
    -- Update the Move Order line
    IF (l_debug = 1) THEN
       DEBUG('calling update_row', 'Finalize_Pick_Confirm');
    END IF;
    inv_trolin_util.update_row(l_trolin_rec);

    /* Bug:4994950( Actual Bug 4762505). First checking if the current mo_line_id is closed or not.
     * Then checking if the  record count exists for the current line_id.
     * If exists then increment the mmtt record count.
     * Else initialize the count for the current mo_line_id to 1
     */
    --Bug 4994950: Start of code changes
      -- Bug 5059984, Added condition so that g_mmtt_cache_tbl is not updated for requisition move orders

    if (l_mo_line_closed_flag = FALSE ) then
      if (l_move_order_type <> 2) then
        IF (g_mmtt_cache_tbl.EXISTS(l_trolin_rec.line_id) ) THEN
          g_mmtt_cache_tbl(l_trolin_rec.line_id) :=  g_mmtt_cache_tbl(l_trolin_rec.line_id) + 1;
        ELSE
          g_mmtt_cache_tbl(l_trolin_rec.line_id) := 1 ;
        END IF;
      else
        IF (l_debug = 1) THEN
          DEBUG('Replenishment Move Order will not update g_mmtt_cache_tbl', 'Finalize_Pick_Confirm');
        END IF;
      end if; -- end if check move order type

    end if;   -- end if mo_line_closed_flag
    --Bug 4994950: End of code changes


    IF (l_debug = 1) THEN
       DEBUG('reservation id = '|| l_mmtt_rec.reservation_id, 'Finalize_Pick_Confirm');
    END IF;

    /*
       Start of bug# 5643004
       Moved the below query before unmarking serials since,
       Unmarking serials requires l_lot_control_code and
       l_serial_controlled_code to be initialized.
    */

    SELECT lot_control_code
           , serial_number_control_code
           , reservable_type
        INTO l_lot_control_code
           , l_serial_control_code
           , l_reservable_type_item
        FROM mtl_system_items
       WHERE inventory_item_id = l_mmtt_rec.inventory_item_id
         AND organization_id = l_mmtt_rec.organization_id;

      IF (l_debug = 1) THEN
         DEBUG('After select lot_control_code = '|| l_lot_control_code, 'Finalize_Pick_confirm');
         DEBUG('After select l_serial_control_code = '|| l_serial_control_code, 'Finalize_Pick_Confirm');
      END IF;

    -- Unmark all the serials
    IF  (l_move_order_type <> 3 OR l_shipping_quantity <= 0 )
        AND l_mmtt_rec.transaction_action_id = 28 THEN
      IF (l_debug = 1) THEN
         DEBUG('Unmarking Serials ', 'Finalize_Pick_Confirm');
      END IF;

      IF (l_lot_control_code > 1 AND l_serial_control_code NOT IN (1, 6)) THEN
        -- Lot and serial controlled
        OPEN lot_csr (p_transaction_temp_id);

        LOOP
          FETCH lot_csr INTO l_lot_number, l_lot_primary_quantity, l_lot_transaction_quantity,
                             l_lot_secondary_quantity, l_lot_secondary_uom, l_serial_trx_temp_id,l_grade_code;
          EXIT WHEN lot_csr%NOTFOUND;
          OPEN serial_csr(p_transaction_temp_id, l_lot_control_code, l_serial_trx_temp_id,
                          l_mmtt_rec.organization_id, l_mmtt_rec.inventory_item_id);

          LOOP
            FETCH serial_csr INTO l_serial_number;
            EXIT WHEN serial_csr%NOTFOUND;
            IF (l_debug = 1) THEN
               DEBUG('serial number:'|| l_serial_number, 'Finalize_Pick_Confirm');
            END IF;

           /*** {{ R12 Enhanced reservations code changes,
            *** call serial_check.inv_unmark_rsv_serial instead of update msn directly
            UPDATE mtl_serial_numbers
               SET group_mark_id = NULL
             WHERE serial_number = l_serial_number
               AND inventory_item_id = l_mmtt_rec.inventory_item_id;
            *** End R12 }} ***/

           /*** {{ R12 Enhanced reservations code changes ***/
            serial_check.inv_unmark_rsv_serial
                (from_serial_number   => l_serial_number
                ,to_serial_number     => null
                ,serial_code          => null
                ,hdr_id               => null
                ,p_inventory_item_id  => l_mmtt_rec.inventory_item_id
                ,p_update_reservation => fnd_api.g_true);
           /*** End R12 }} ***/
          END LOOP;

          CLOSE serial_csr;
        END LOOP;

        CLOSE lot_csr;
      ELSIF  l_lot_control_code = 1
             AND l_serial_control_code NOT IN (1, 6) THEN
        -- Only Serial controlled
        OPEN serial_csr(p_transaction_temp_id, l_lot_control_code, l_serial_trx_temp_id,
                        l_mmtt_rec.organization_id, l_mmtt_rec.inventory_item_id);

        LOOP
          FETCH serial_csr INTO l_serial_number;
          EXIT WHEN serial_csr%NOTFOUND;
          IF (l_debug = 1) THEN
             DEBUG('serial number:'|| l_serial_number, 'Finalize_Pick_Confirm');
          END IF;

         /*** {{ R12 Enhanced reservations code changes,
          *** call serial_check.inv_unmark_rsv_serial instead of update msn directly
          UPDATE mtl_serial_numbers
             SET group_mark_id = NULL
           WHERE serial_number = l_serial_number
             AND inventory_item_id = l_mmtt_rec.inventory_item_id;
          *** End R12 }} ***/

         /*** {{ R12 Enhanced reservations code changes ***/
          serial_check.inv_unmark_rsv_serial
                (from_serial_number   => l_serial_number
                ,to_serial_number     => null
                ,serial_code          => null
                ,hdr_id               => null
                ,p_inventory_item_id  => l_mmtt_rec.inventory_item_id
                ,p_update_reservation => fnd_api.g_true);
         /*** End R12 }} ***/
        END LOOP;

        CLOSE serial_csr;
      END IF;
    END IF;

    IF (l_move_order_type = 3 AND l_shipping_quantity > 0) THEN
      IF (l_debug = 1) THEN
         DEBUG('inside l_move_ordeR_ytpe = 3', 'Finalize_Pick_Confirm');
      END IF;

      -- Bug 5535030: cache subinventory reservable type
      l_hash_value := DBMS_UTILITY.get_hash_value
                      ( NAME      => to_char(l_mmtt_rec.organization_id)
                                     ||'-'|| l_mmtt_rec.transfer_subinventory
                      , base      => 1
                      , hash_size => POWER(2, 25)
                      );
      IF g_is_sub_reservable.EXISTS(l_hash_value) AND
         g_is_sub_reservable(l_hash_value).org_id = l_mmtt_rec.organization_id AND
         g_is_sub_reservable(l_hash_value).subinventory_code = l_mmtt_rec.transfer_subinventory
      THEN
         l_reservable_type := g_is_sub_reservable(l_hash_value).reservable_type;
      ELSE
      -- Bug 9146725
         SELECT reservable_type
           INTO l_reservable_type
           FROM mtl_secondary_inventories
          WHERE organization_id = l_mmtt_rec.organization_id
            AND secondary_inventory_name = to_char(l_mmtt_rec.transfer_subinventory);
         g_is_sub_reservable(l_hash_value).reservable_type := l_reservable_type;
         g_is_sub_reservable(l_hash_value).org_id := l_mmtt_rec.organization_id;
         g_is_sub_reservable(l_hash_value).subinventory_code := l_mmtt_rec.transfer_subinventory;
      END IF;

      -- Bug 1620576 - Overpicking
      -- Look at remaining quantity, instead of quantity delivered to set
      -- action flag
      -- Action flag meanings:
      -- M: updates for lot control or serial control
      -- S: this update is not the last update, so shipping will have
      --    to split the delivery line
      -- U: this is the last update to shipping, so shipping can just
      --    update the existing delivery detail without splitting
      -- If (l_trolin_rec.quantity_delivered < l_trolin_rec.quantity ) Then

      IF l_remaining_shipping_quantity > 0 THEN
        IF (l_lot_control_code > 1 OR NVL(l_serial_control_code, 1) NOT IN (1, 6)) THEN
          l_action_flag  := 'M';
        ELSE
          l_action_flag  := 'S';
        END IF;
      ELSE
        IF (l_lot_control_code > 1 OR NVL(l_serial_control_code, 1) NOT IN (1, 6)) THEN
          l_action_flag  := 'M';
        ELSE
          l_action_flag  := 'U';
        END IF;
      END IF;

      IF (l_debug = 1) THEN
         DEBUG('l_action_flag is  = '|| l_action_flag, 'Finalize_Pick_confirm');
      END IF;
      l_mtl_reservation_tbl_count            := 0;

      IF (l_mmtt_rec.reservation_id IS NOT NULL) THEN
        l_query_reservation_rec.reservation_id  := l_mmtt_rec.reservation_id;
        IF (l_debug = 1) THEN
           DEBUG('about to call inv_reservation_pub.query_reservations ', 'Finalize_Pick_confirm');
        END IF;
        inv_reservation_pub.query_reservation(
          p_api_version_number         => 1.0
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_query_input                => l_query_reservation_rec
        , x_mtl_reservation_tbl        => l_mtl_reservation_tbl
        , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
        , x_error_code                 => l_error_code
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
             DEBUG('Error from query_reservations', 'Finalize_Pick_Confirm');
          END IF;
          RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
             DEBUG('Error from query_reservations', 'Finalize_Pick_Confirm');
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF (l_debug = 1) THEN
           DEBUG('reservation count = '|| l_mtl_reservation_tbl.COUNT, 'Finalize_Pick_Confirm');
           DEBUG('after query_reservation', 'Finalize_Pick_Confirm');
        END IF;
            -- We need to handle case here where reservation count = 0
            -- i.e. the reservation id on the MMTT record is now invalid
            -- currently, if reservation count = 0, we raise no data found
            -- when we try to get the first record of the reservation table.
            -- To solve this problem, add end if and then a new if stmt
            -- to make sure query returned a record.  If rec count = 0,
            -- create a new reservation on the staging sub.
      END IF;

      l_lpn_id                               := NVL(l_mmtt_rec.content_lpn_id, l_mmtt_rec.transfer_lpn_id);

      IF l_mtl_reservation_tbl_count > 0 THEN
        l_mtl_reservation_rec  := l_mtl_reservation_tbl(1);
        IF (l_debug = 1) THEN
           DEBUG('lot number in the original reservation is '|| l_mtl_reservation_rec.lot_number, 'Finalize_Pick_Confirm');
        END IF;

        -- Bug 1620576 - Overpicking
        -- To support overpicking, we have to increase the reservation
        -- quantity when the user enters a transaction quantity which
        -- is greater than the requested quantity.
        -- We increase the reservation before transferring it to the
        -- staging subinventory.

        IF l_rsv_primary_quantity > l_mtl_reservation_rec.primary_reservation_quantity THEN
          IF (l_debug = 1) THEN
             DEBUG('Increasing reservation quantity for overpicking', 'Finalize_Pick_Confirm');
             DEBUG('Old rsv prim. quantity: '|| l_mtl_reservation_rec.primary_reservation_quantity, 'Finalize_Pick_Confirm');
             DEBUG('New rsv prim. quantity: '|| l_rsv_primary_quantity, 'Finalize_Pick_Confirm');
          END IF;
          l_mtl_reservation_rec.primary_reservation_quantity     := l_rsv_primary_quantity;
          l_mtl_reservation_rec.detailed_quantity                := l_rsv_primary_quantity;
          /*Bug 5436227/5436033 Pass only primary qty and let reservation apis calculate secondary qty
          This is beacuse we do not know whether the reservation is a High level or lot level and
          hence the uom conversion to be used i.e lot or item conversion, will be determined by reservation api*/
          --l_mtl_reservation_rec.secondary_reservation_quantity   := l_sec_rsv_quantity;
          --l_mtl_reservation_rec.secondary_detailed_quantity      := l_sec_rsv_quantity;
          l_mtl_reservation_rec.secondary_reservation_quantity   := NULL;
          l_mtl_reservation_rec.secondary_detailed_quantity      := NULL;
          l_mtl_reservation_rec.reservation_quantity             := NULL;

--INVCONV - Make sure Qty2 are NULL if nor present
        IF (  l_mtl_reservation_rec.secondary_uom_code IS NULL ) THEN
              l_mtl_reservation_rec.secondary_reservation_quantity := NULL;
              l_mtl_reservation_rec.secondary_detailed_quantity    := NULL;
        END IF;
          inv_reservation_pub.update_reservation(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
          , p_to_rsv_rec                 => l_mtl_reservation_rec
          , p_original_serial_number     => l_original_serial_number
          , p_to_serial_number           => l_to_serial_number
          , p_validation_flag            => fnd_api.g_true -- Explicitly set the validation flag to true with respect to the Bug 4004597
          , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
	  );
          IF (l_debug = 1) THEN
             DEBUG('after update reservation return status is '|| l_return_status, 'Finalize_Pick_Confirm');
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          --requery reservation to reflect updated data
          inv_reservation_pub.query_reservation(
            p_api_version_number         => 1.0
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , p_query_input                => l_query_reservation_rec
          , x_mtl_reservation_tbl        => l_mtl_reservation_tbl
          , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
          , x_error_code                 => l_error_code
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
               DEBUG('Error from query_reservations', 'Finalize_Pick_Confirm');
            END IF;
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
               DEBUG('Error from query_reservations', 'Finalize_Pick_Confirm');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

        -- Create a new reservation on a staging sub
        -- for the transaction_quantity;
        -- initialize l_mtl_reservation_rec with the record transacted.
        -- change the the value of changed attributes
        -- in l_mtl_reservation_rec
        IF (l_debug = 1) THEN
           DEBUG('l_mmtt_rec.transaction_temp_id is '|| l_mmtt_rec.transaction_temp_id, 'Finalize_Pick_confirm');
        END IF;

        SELECT COUNT(*) INTO l_lot_count
          FROM mtl_transaction_lots_temp
         WHERE transaction_temp_id = p_transaction_temp_id;

        IF (l_debug = 1) THEN
           DEBUG('l_lot_count is '|| l_lot_count, 'Finalize_Pick_Confirm');
        END IF;


        /*** {{ R12 Enhanced reservations code changes ***/
        -- If we delete/update reservation for unreservable subinventory, and serial number
        -- is reserved for the reservation, we want to null out the reservation_id for
        -- the serial number in MSN but retain the marked group_mark_id
        -- therefore we will null out the reservation_id in MSN before calling update_reservation
        -- so that the reservation API will not null out both reservation_id and group_mark_id.
        -- For reservable subinventory, there is no need to retain the reservation_id of
        -- the serial number after we finalize pick confirm because the reserved serials are
        -- being moved to staging sub, but we still want to retain group_mark_id
        -- the reservation_id will be null out for the reserved serial number
        -- when we transfer to staging sub to reduce the complexity of handling
        -- reserved serial number after staging
        IF (l_mtl_reservation_tbl(1).reservation_id is not NULL) THEN
           IF (l_lot_count > 0 AND l_serial_control_code NOT IN (1, 6)) THEN
              -- lot and serial controlled

              l_serial_count := 0;

              OPEN lot_csr(p_transaction_temp_id);

              LOOP
                FETCH lot_csr INTO l_lot_number, l_lot_primary_quantity, l_lot_transaction_quantity,
                                   l_lot_secondary_quantity, l_lot_secondary_uom, l_serial_trx_temp_id, l_grade_code;
                EXIT WHEN lot_csr%NOTFOUND;


                OPEN serial_reserved_csr(l_serial_trx_temp_id, l_mtl_reservation_tbl(1).reservation_id);

                LOOP
                  FETCH serial_reserved_csr INTO l_serial_number;
                  EXIT WHEN serial_reserved_csr%NOTFOUND;
                  IF (l_debug = 1) THEN
                     DEBUG('serial number:'|| l_serial_number, 'Finalize_Pick_Confirm');
                  END IF;

                  UPDATE mtl_serial_numbers
                  SET    reservation_id = null
                  WHERE  reservation_id = l_mtl_reservation_tbl(1).reservation_id
                  AND    serial_number = l_serial_number;

                  l_serial_count := SQL%ROWCOUNT + l_serial_count;
                END LOOP;

                CLOSE serial_reserved_csr;

              END LOOP;

              CLOSE lot_csr;

              IF (l_debug = 1) THEN
                 DEBUG('serial count with updated null reservation_id = ' || l_serial_count, 'Finalize_Pick_Confirm');
              END IF;

              IF (l_serial_count > 0) THEN
                  UPDATE mtl_reservations
                  SET    serial_reservation_quantity = serial_reservation_quantity - l_serial_count
                  WHERE  reservation_id = l_mtl_reservation_tbl(1).reservation_id;
              END IF;

           ELSIF (l_lot_control_code = 1 AND l_serial_control_code NOT IN (1, 6)) THEN
              -- serial controlled only
              l_serial_count := 0;

              OPEN serial_reserved_csr(p_transaction_temp_id, l_mtl_reservation_tbl(1).reservation_id);

              LOOP
                FETCH serial_reserved_csr INTO l_serial_number;
                EXIT WHEN serial_reserved_csr%NOTFOUND;
                IF (l_debug = 1) THEN
                   DEBUG('serial number:'|| l_serial_number, 'Finalize_Pick_Confirm');
                END IF;

                UPDATE mtl_serial_numbers
                SET    reservation_id = null
                WHERE  reservation_id = l_mtl_reservation_tbl(1).reservation_id
                AND    serial_number = l_serial_number;

                l_serial_count := SQL%ROWCOUNT + l_serial_count;
              END LOOP;

              CLOSE serial_reserved_csr;

              IF (l_debug = 1) THEN
                 DEBUG('serial count with updated null reservation_id = ' || l_serial_count, 'Finalize_Pick_Confirm');
              END IF;

              IF (l_serial_count > 0) THEN
                  UPDATE mtl_reservations
                  SET    serial_reservation_quantity = serial_reservation_quantity - l_serial_count
                  WHERE  reservation_id = l_mtl_reservation_tbl(1).reservation_id;
              END IF;
           END IF;
        END IF;
        /*** End R12 }} ***/

        IF (l_reservable_type = 2) THEN
          IF (l_debug = 1) THEN
             DEBUG('not reservable staging subinventory, '|| 'delete org wide reservation', 'Finalize_Pick_Confirm');
          END IF;
          l_mtl_reservation_rec                       := l_mtl_reservation_tbl(1);
          -- reservation quantity should be NULL; it will be
          -- determined based on primary quantity
          l_mtl_reservation_rec.reservation_quantity  := NULL;

          IF NVL(l_mtl_reservation_rec.primary_reservation_quantity, 0) > ABS(l_mmtt_rec.primary_quantity) THEN
            l_mtl_reservation_rec.primary_reservation_quantity
                             := NVL(l_mtl_reservation_rec.primary_reservation_quantity, 0)
                                      - ABS(l_mmtt_rec.primary_quantity);
            l_mtl_reservation_rec.secondary_reservation_quantity
                             := NVL(l_mtl_reservation_rec.secondary_reservation_quantity, 0)
                                      - ABS(l_mmtt_rec.secondary_transaction_quantity);
          ELSE -- if qty > rsv qty, delete reservation
            l_mtl_reservation_rec.primary_reservation_quantity  := 0;
            l_mtl_reservation_rec.secondary_reservation_quantity  := 0;
          END IF;

          --need to decrement from detailed quantity
          IF NVL(l_mtl_reservation_rec.detailed_quantity, 0) > ABS(l_mmtt_rec.primary_quantity) THEN
            l_mtl_reservation_rec.detailed_quantity
                             := NVL(l_mtl_reservation_rec.detailed_quantity, 0)
                                      - ABS(l_mmtt_rec.primary_quantity);
            l_mtl_reservation_rec.secondary_detailed_quantity
                             := NVL(l_mtl_reservation_rec.secondary_detailed_quantity, 0)
                                      - ABS(l_mmtt_rec.secondary_transaction_quantity);
          ELSE
            l_mtl_reservation_rec.detailed_quantity  := 0;
            l_mtl_reservation_rec.secondary_detailed_quantity  := 0;
          END IF;

          IF (l_debug = 1) THEN
             DEBUG('primary reservation quantity is '|| l_mtl_reservation_rec.primary_reservation_quantity, 'Finalize_Pick_Confirm');
          END IF;

--INVCONV - Make sure Qty2 are NULL if nor present
          IF (  l_mtl_reservation_rec.secondary_uom_code IS NULL ) THEN
                l_mtl_reservation_rec.secondary_reservation_quantity := NULL;
                l_mtl_reservation_rec.secondary_detailed_quantity    := NULL;
          END IF;

          inv_reservation_pub.update_reservation(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
          , p_to_rsv_rec                 => l_mtl_reservation_rec
          , p_original_serial_number     => l_original_serial_number
          , p_to_serial_number           => l_to_serial_number
          , p_validation_flag            => fnd_api.g_true
          , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
          );
          IF (l_debug = 1) THEN
             DEBUG('after update reservation return status is '|| l_return_status, 'Finalize_Pick_Confirm');
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
             DEBUG('reservable staging subinventory, '|| 'transfer reservation to staging', 'Finalize_Pick_Confirm');
          END IF;

          IF (l_lot_count > 0) THEN
            l_transaction_temp_id         := l_mmtt_rec.transaction_temp_id;
            l_lot_shipping_quantity       := 0;
            l_lot_prim_shipping_quantity  := 0;
            OPEN lot_csr(p_transaction_temp_id);

            LOOP
              FETCH lot_csr
              INTO l_lot_number
                 , l_lot_primary_quantity
                 , l_lot_transaction_quantity
                 , l_lot_secondary_quantity
                 , l_lot_secondary_uom
                 , l_serial_trx_temp_id
                 , l_grade_code;
              l_lot_shipping_quantity       := l_lot_shipping_quantity + l_lot_transaction_quantity;
              l_sec_lot_shipping_quantity   := l_sec_lot_shipping_quantity + l_lot_secondary_quantity;
              l_lot_prim_shipping_quantity  := l_lot_prim_shipping_quantity + l_lot_primary_quantity;

              IF l_lot_shipping_quantity > l_shipping_quantity THEN
                l_lot_transaction_quantity  := l_lot_transaction_quantity
                                               - (l_lot_shipping_quantity - l_shipping_quantity);
                l_lot_primary_quantity      := l_lot_primary_quantity
                                               - (l_lot_prim_shipping_quantity - l_primary_shipping_quantity);
                l_lot_secondary_quantity  := l_lot_secondary_quantity
                                               - (l_sec_lot_shipping_quantity - l_sec_shipping_quantity);
              END IF;

              EXIT WHEN lot_csr%NOTFOUND
                     OR l_lot_transaction_quantity <= 0;
              IF (l_debug = 1) THEN
                 DEBUG('lot number is '|| l_mtl_reservation_rec.lot_number, 'Finalize_Pick_Confirm');
              END IF;
              l_mtl_reservation_rec.reservation_id                := NULL;

              -- bug 3703983
              --l_mtl_reservation_rec.requirement_date              := SYSDATE;
              l_mtl_reservation_rec.primary_reservation_quantity  := ABS(l_lot_primary_quantity);
              l_mtl_reservation_rec.reservation_quantity          := ABS(l_lot_transaction_quantity);
              l_mtl_reservation_rec.reservation_uom_code          := l_mmtt_rec.transaction_uom;
              l_mtl_reservation_rec.subinventory_code             := l_mmtt_rec.transfer_subinventory;
              l_mtl_reservation_rec.detailed_quantity             := 0;
              -- bug 5354515, lgao blank out the qty2 and uom 2 if not tracked by PS
              if l_tracking_quantity_ind <> 'P' then   -- dual uom tracked
                 l_mtl_reservation_rec.secondary_reservation_quantity  := ABS(l_lot_secondary_quantity);
                 l_mtl_reservation_rec.secondary_uom_code            := l_mmtt_rec.secondary_uom_code;
                 l_mtl_reservation_rec.secondary_detailed_quantity   := 0;
              else   -- primary tracked
                 l_mtl_reservation_rec.secondary_reservation_quantity  := null;
                 l_mtl_reservation_rec.secondary_uom_code            := '';
                 l_mtl_reservation_rec.secondary_detailed_quantity   := null;
              end if;
              l_mtl_reservation_rec.locator_id                    := l_mmtt_rec.transfer_to_location;
              l_mtl_reservation_rec.ship_ready_flag               := 1;
              l_mtl_reservation_rec.lot_number                    := l_lot_number;
              l_mtl_reservation_rec.revision                      := l_mmtt_rec.revision;

              -- bug 3703983
              l_mtl_reservation_rec.staged_flag                   := 'Y';

              --don't reserve LPN in staging sub unless LPN was
              -- reserved on original reservation
              IF l_mtl_reservation_tbl(1).lpn_id IS NOT NULL THEN
                l_mtl_reservation_rec.lpn_id  := l_lpn_id;
              END IF;

              inv_reservation_pub.transfer_reservation(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
              , p_to_rsv_rec                 => l_mtl_reservation_rec
              , p_original_serial_number     => l_to_serial_number
              , p_to_serial_number           => l_to_serial_number
              , p_validation_flag            => fnd_api.g_false
              , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
              , x_to_reservation_id          => l_reservation_id
              );
              IF (l_debug = 1) THEN
                 DEBUG('new reservation id is '|| l_reservation_id, 'Finalize_Pick_Confirm');
                 DEBUG('after create new  reservation', 'Finalize_Pick_Confirm');
                 DEBUG('l_return_status is '|| l_return_status, 'Finalize_Pick_Confirm');
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('return from transfer_reservation with error E', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('return from transfer_reservation with error U', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              -- bug 3703983
              -- inv_staged_reservation_util.update_staged_flag(x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data, p_reservation_id => l_reservation_id, p_staged_flag => 'Y');

              --IF l_return_status = fnd_api.g_ret_sts_error THEN
              -- (l_debug = 1) THEN
              --    DEBUG('Error in update_staged_flag', 'Finalize_Pick_Confirm');
              -- END IF;
              -- RAISE fnd_api.g_exc_error;
              --ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              -- IF (l_debug = 1) THEN
              --    DEBUG('Unexpected error in update_staged_flag', 'Finalize_Pick_Confirm');
              -- END IF;
              -- RAISE fnd_api.g_exc_unexpected_error;
              --END IF;
            END LOOP;

            IF (l_debug = 1) THEN
               DEBUG('after end loop', 'Finalize_Pick_Confirm');
            END IF;
            CLOSE lot_csr;
          ELSE
            IF (l_debug = 1) THEN
               DEBUG('no lot records', 'Finalize_Pick_Confirm');
            END IF;
            l_mtl_reservation_rec.reservation_id                := NULL;
            -- bug 3703983
            --l_mtl_reservation_rec.requirement_date              := SYSDATE;
            l_mtl_reservation_rec.primary_reservation_quantity  := l_primary_shipping_quantity;
            l_mtl_reservation_rec.reservation_quantity          := l_shipping_quantity;
            l_mtl_reservation_rec.reservation_uom_code          := l_mmtt_rec.transaction_uom;
            -- bug 5354515, lgao blank out the qty2 and uom 2 if not tracked by PS
            if l_tracking_quantity_ind <> 'P' then   -- dual uom tracked
              l_mtl_reservation_rec.secondary_reservation_quantity  := l_sec_shipping_quantity;
              l_mtl_reservation_rec.secondary_uom_code            := l_mmtt_rec.secondary_uom_code;
            else   -- primary tracked
              l_mtl_reservation_rec.secondary_reservation_quantity  := null;
              l_mtl_reservation_rec.secondary_uom_code            := '';
            end if;
            l_mtl_reservation_rec.subinventory_code             := l_mmtt_rec.transfer_subinventory;
            l_mtl_reservation_rec.detailed_quantity             := NULL;
            l_mtl_reservation_rec.secondary_detailed_quantity   := NULL;
            l_mtl_reservation_rec.locator_id                    := l_mmtt_rec.transfer_to_location;
            l_mtl_reservation_rec.ship_ready_flag               := 1;
            l_mtl_reservation_rec.revision                      := l_mmtt_rec.revision;
            -- bug 3703983
            l_mtl_reservation_rec.staged_flag                   := 'Y';

            --don't reserve LPN in staging sub unless LPN was
            -- reserved on original reservation
            IF l_mtl_reservation_tbl(1).lpn_id IS NOT NULL THEN
              l_mtl_reservation_rec.lpn_id  := l_lpn_id;
            END IF;

            IF (l_debug = 1) THEN
               DEBUG('l_primary_shipping_quantity: '|| l_primary_shipping_quantity, 'Finalize_Pick_Confirm');
            END IF;

            inv_reservation_pub.transfer_reservation(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
            , p_to_rsv_rec                 => l_mtl_reservation_rec
            , p_original_serial_number     => l_to_serial_number
            , p_to_serial_number           => l_to_serial_number
            , p_validation_flag            => fnd_api.g_false
            , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
            , x_to_reservation_id          => l_reservation_id
            );

            IF (l_debug = 1) THEN
               DEBUG('new reservation id is '|| l_reservation_id, 'Finalize_Pick_Confirm');
               DEBUG('after create new reservation', 'Finalize_Pick_Confirm');
               DEBUG('l_return_status is '|| l_return_status, 'Finalize_Pick_Confirm');
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                 DEBUG('return from transfer_reservation with error E', 'Finalize_Pick_Confirm');
              END IF;
              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                 DEBUG('return from transfer_reservation with error U', 'Finalize_Pick_Confirm');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (l_debug = 1) THEN
               DEBUG('still inside if no lot records', 'Finalize_Pick_Confirm');
            END IF;

            -- bug 3703983
            --inv_staged_reservation_util.update_staged_flag(x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data, p_reservation_id => l_reservation_id, p_staged_flag => 'Y');

            --IF l_return_status = fnd_api.g_ret_sts_error THEN
            --  IF (l_debug = 1) THEN
            --     DEBUG('Error in update_staged_flag', 'Finalize_Pick_Confirm');
            --  END IF;
            --  RAISE fnd_api.g_exc_error;
            --ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            --  IF (l_debug = 1) THEN
            --     DEBUG('Unexpected error in update_staged_flag', 'Finalize_Pick_Confirm');
            --  END IF;
            --  RAISE fnd_api.g_exc_unexpected_error;
            --END IF;
          END IF; -- lot or not lot control
        END IF; -- reservable or not
      ELSE -- query reservation returns 0 records
        -- Reservation does not exist, we need to create one if the
        -- staging sub is reservable and item is reservable
        IF  l_reservable_type = 1 AND l_reservable_type_item = 1 THEN
          -- If the staging subinventory  is reservable
          l_mtl_reservation_rec.reservation_id             := NULL; -- cannot know
          l_mtl_reservation_rec.organization_id            := l_mmtt_rec.organization_id;
          l_mtl_reservation_rec.inventory_item_id          := l_mmtt_rec.inventory_item_id;
          l_mtl_reservation_rec.demand_source_type_id      := l_mmtt_rec.transaction_source_type_id;
          l_mtl_reservation_rec.demand_source_name         := NULL;
          l_mtl_reservation_rec.demand_source_header_id    := l_mmtt_rec.transaction_source_id;
          l_mtl_reservation_rec.demand_source_line_id      := TO_NUMBER(l_mmtt_rec.trx_source_line_id);
          l_mtl_reservation_rec.demand_source_delivery     := NULL;
          l_mtl_reservation_rec.primary_uom_code           := l_mmtt_rec.item_primary_uom_code;
          l_mtl_reservation_rec.secondary_uom_code         := l_mmtt_rec.secondary_uom_code;
          l_mtl_reservation_rec.primary_uom_id             := NULL;
          l_mtl_reservation_rec.secondary_uom_id           := NULL;
          l_mtl_reservation_rec.reservation_uom_code       := l_mmtt_rec.transaction_uom;
          l_mtl_reservation_rec.reservation_uom_id         := NULL;
          l_mtl_reservation_rec.autodetail_group_id        := NULL;
          l_mtl_reservation_rec.external_source_code       := NULL;
          l_mtl_reservation_rec.external_source_line_id    := NULL;
          l_mtl_reservation_rec.supply_source_type_id      := inv_reservation_global.g_source_type_inv;
          l_mtl_reservation_rec.supply_source_header_id    := NULL;
          l_mtl_reservation_rec.supply_source_line_id      := NULL;
          l_mtl_reservation_rec.supply_source_name         := NULL;
          l_mtl_reservation_rec.supply_source_line_detail  := NULL;
          l_mtl_reservation_rec.revision                   := l_mmtt_rec.revision;
          l_mtl_reservation_rec.subinventory_code          := l_mmtt_rec.transfer_subinventory;
          l_mtl_reservation_rec.subinventory_id            := NULL;
          l_mtl_reservation_rec.locator_id                 := l_mmtt_rec.transfer_to_location;
          l_mtl_reservation_rec.lot_number_id              := NULL;
          l_mtl_reservation_rec.pick_slip_number           := NULL;
          --we reserve LPN only on user created reservations
          l_mtl_reservation_rec.lpn_id                     := NULL;
          l_mtl_reservation_rec.attribute_category         := NULL;
          l_mtl_reservation_rec.attribute1                 := NULL;
          l_mtl_reservation_rec.attribute2                 := NULL;
          l_mtl_reservation_rec.attribute3                 := NULL;
          l_mtl_reservation_rec.attribute4                 := NULL;
          l_mtl_reservation_rec.attribute5                 := NULL;
          l_mtl_reservation_rec.attribute6                 := NULL;
          l_mtl_reservation_rec.attribute7                 := NULL;
          l_mtl_reservation_rec.attribute8                 := NULL;
          l_mtl_reservation_rec.attribute9                 := NULL;
          l_mtl_reservation_rec.attribute10                := NULL;
          l_mtl_reservation_rec.attribute11                := NULL;
          l_mtl_reservation_rec.attribute12                := NULL;
          l_mtl_reservation_rec.attribute13                := NULL;
          l_mtl_reservation_rec.attribute14                := NULL;
          l_mtl_reservation_rec.attribute15                := NULL;
          l_mtl_reservation_rec.ship_ready_flag            := 1;
          l_mtl_reservation_rec.detailed_quantity          := 0;
          l_mtl_reservation_rec.secondary_detailed_quantity := 0;

          IF l_lot_control_code = 2 THEN
            --Lot control
            l_transaction_temp_id         := l_mmtt_rec.transaction_temp_id;
            l_lot_shipping_quantity       := 0;
            l_lot_prim_shipping_quantity  := 0;
            OPEN lot_csr(p_transaction_temp_id);

            LOOP
              FETCH lot_csr
              INTO l_lot_number
                 , l_lot_primary_quantity
                 , l_lot_transaction_quantity
                 , l_lot_secondary_quantity
                 , l_lot_secondary_uom
                 , l_serial_trx_temp_id
                 , l_grade_code;
              l_lot_shipping_quantity           := l_lot_shipping_quantity + l_lot_transaction_quantity;
              l_sec_lot_shipping_quantity       := l_sec_lot_shipping_quantity + l_lot_secondary_quantity;
              l_lot_prim_shipping_quantity      := l_lot_prim_shipping_quantity + l_lot_primary_quantity;

              IF l_lot_shipping_quantity > l_shipping_quantity THEN
                l_lot_transaction_quantity  := l_lot_transaction_quantity - (l_lot_shipping_quantity - l_shipping_quantity);
                l_lot_secondary_quantity    := l_lot_secondary_quantity - (l_sec_lot_shipping_quantity - l_sec_shipping_quantity);
                l_lot_primary_quantity      := l_lot_primary_quantity - (l_lot_prim_shipping_quantity - l_primary_shipping_quantity);
              END IF;

              EXIT WHEN lot_csr%NOTFOUND
                     OR l_lot_transaction_quantity <= 0;
              l_mtl_reservation_rec.lot_number  := l_lot_number;
              -- query to see whether a record with the key
              -- attributes already exists
              -- if there is, use update instead of create
              inv_reservation_pub.query_reservation(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_query_input                => l_mtl_reservation_rec
              , p_lock_records               => fnd_api.g_true
              , x_mtl_reservation_tbl        => l_mtl_reservation_tbl
              , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
              , x_error_code                 => l_error_code
              );

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              IF l_mtl_reservation_tbl_count > 0 THEN
                l_mtl_reservation_rec.primary_reservation_quantity  := l_mtl_reservation_tbl(1).primary_reservation_quantity + ABS(l_lot_primary_quantity);
                l_mtl_reservation_rec.reservation_quantity          := l_mtl_reservation_tbl(1).reservation_quantity + ABS(l_lot_transaction_quantity);
                l_mtl_reservation_rec.secondary_reservation_quantity
                       := l_mtl_reservation_tbl(1).secondary_reservation_quantity + ABS(l_lot_secondary_quantity);
                l_mtl_reservation_rec.requirement_date              := SYSDATE;

--INVCONV - Make sure Qty2 are NULL if nor present
        IF (  l_mtl_reservation_rec.secondary_uom_code IS NULL ) THEN
              l_mtl_reservation_rec.secondary_reservation_quantity := NULL;
              l_mtl_reservation_rec.secondary_detailed_quantity    := NULL;
        END IF;
                inv_reservation_pub.update_reservation(
                  p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
                , x_return_status              => l_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
                , p_to_rsv_rec                 => l_mtl_reservation_rec
                , p_original_serial_number     => l_original_serial_number
                , p_to_serial_number           => l_to_serial_number
                , p_validation_flag            => fnd_api.g_true
                , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
                );
                IF (l_debug = 1) THEN
                   DEBUG('after update reservation return status is '|| l_return_status, 'Finalize_Pick_Confirm');
                END IF;

                IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;
              ELSE

               -- check to see the lot is reservable...
               -- Bug 8560030
               BEGIN
                SELECT reservable_type
                  INTO l_reservable_type_lot
                  FROM mtl_lot_numbers
                 WHERE inventory_item_id = l_mtl_reservation_rec.inventory_item_id
                   AND organization_id = l_mtl_reservation_rec.organization_id
                   AND lot_number = l_mtl_reservation_rec.lot_number;
               EXCEPTION
                WHEN OTHERS THEN
                  l_reservable_type_lot := 1;
               END;

               IF (l_reservable_type_lot <> 1) THEN
                  IF (l_debug = 1) THEN
                    DEBUG('Lot is not reservable, skip creating Staging Reservations', 'Finalize_Pick_Confirm');
                  END IF;
               END IF;

               IF (l_reservable_type_lot = 1) THEN

                l_mtl_reservation_rec.primary_reservation_quantity  := ABS(l_lot_primary_quantity);
                l_mtl_reservation_rec.reservation_quantity          := ABS(l_lot_transaction_quantity);
                l_mtl_reservation_rec.secondary_reservation_quantity := ABS(l_lot_secondary_quantity);
                l_mtl_reservation_rec.requirement_date              := SYSDATE;
                inv_reservation_pub.create_reservation(
                  p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
                , x_return_status              => l_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_rsv_rec                    => l_mtl_reservation_rec
                , p_serial_number              => l_to_serial_number
                , x_serial_number              => l_to_serial_number
                , p_partial_reservation_flag   => fnd_api.g_true
                , p_force_reservation_flag     => fnd_api.g_false
                , p_validation_flag            => fnd_api.g_true
                , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
                , x_quantity_reserved          => l_quantity_reserved
                , x_reservation_id             => l_reservation_id
                );
                IF (l_debug = 1) THEN
                   DEBUG('Quantity reserved: '|| l_quantity_reserved, 'Finalize_Pick_Confirm');
                   DEBUG('Reservation ID: '|| l_reservation_id, 'Finalize_Pick_Confirm');
                END IF;

                IF l_return_status = fnd_api.g_ret_sts_error THEN
                  IF (l_debug = 1) THEN
                     DEBUG('Error in creating reservation for lot', 'Finalize_Pick_Confirm');
                  END IF;
                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                     DEBUG('Unexpected error in creating reservation for lot', 'Finalize_Pick_Confirm');
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                --bug 1402436 - set the reservations staged flag
                inv_staged_reservation_util.update_staged_flag(x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data, p_reservation_id => l_reservation_id, p_staged_flag => 'Y');

                IF l_return_status = fnd_api.g_ret_sts_error THEN
                  IF (l_debug = 1) THEN
                     DEBUG('Error in update_staged_flag', 'Finalize_Pick_Confirm');
                  END IF;
                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                     DEBUG('Unexpected error in update_staged_flag', 'Finalize_Pick_Confirm');
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;
               END IF; --IF (l_reservable_type_lot = 1)
              END IF; -- Create or Update
            END LOOP; -- Lot loop

            IF (l_debug = 1) THEN
               DEBUG('after end of lot loop...', 'Finalize_Pick_Confirm');
            END IF;
            CLOSE lot_csr;
          ELSE
            --No Lot control
            l_mtl_reservation_rec.lot_number  := NULL;
            -- query to see whether a record with the key
            -- attributes already exists
            -- if there is, use update instead of create
            inv_reservation_pub.query_reservation(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_query_input                => l_mtl_reservation_rec
            , p_lock_records               => fnd_api.g_true
            , x_mtl_reservation_tbl        => l_mtl_reservation_tbl
            , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
            , x_error_code                 => l_error_code
            );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF l_mtl_reservation_tbl_count > 0 THEN
              l_mtl_reservation_rec.primary_reservation_quantity  := l_mtl_reservation_tbl(1).primary_reservation_quantity + l_primary_shipping_quantity;
              l_mtl_reservation_rec.reservation_quantity          := l_mtl_reservation_tbl(1).reservation_quantity + l_shipping_quantity;
              l_mtl_reservation_rec.secondary_reservation_quantity
                                := l_mtl_reservation_tbl(1).secondary_reservation_quantity + l_sec_shipping_quantity;
              l_mtl_reservation_rec.requirement_date              := SYSDATE;

--INVCONV - Make sure Qty2 are NULL if nor present
        IF (  l_mtl_reservation_rec.secondary_uom_code IS NULL ) THEN
              l_mtl_reservation_rec.secondary_reservation_quantity := NULL;
              l_mtl_reservation_rec.secondary_detailed_quantity    := NULL;
        END IF;
              inv_reservation_pub.update_reservation(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
              , p_to_rsv_rec                 => l_mtl_reservation_rec
              , p_original_serial_number     => l_original_serial_number
              , p_to_serial_number           => l_to_serial_number
              , p_validation_flag            => fnd_api.g_true
              , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
              );
              IF (l_debug = 1) THEN
                 DEBUG('after update reservation return status is '|| l_return_status, 'Finalize_Pick_Confirm');
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            ELSE
              l_mtl_reservation_rec.primary_reservation_quantity  := l_primary_shipping_quantity;
              l_mtl_reservation_rec.reservation_quantity          := l_shipping_quantity;
              l_mtl_reservation_rec.secondary_reservation_quantity  := l_sec_shipping_quantity;
              l_mtl_reservation_rec.requirement_date              := SYSDATE;
              inv_reservation_pub.create_reservation(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_rsv_rec                    => l_mtl_reservation_rec
              , p_serial_number              => l_to_serial_number
              , x_serial_number              => l_to_serial_number
              , p_partial_reservation_flag   => fnd_api.g_true
              , p_force_reservation_flag     => fnd_api.g_false
              , p_validation_flag            => fnd_api.g_true
              , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
              , x_quantity_reserved          => l_quantity_reserved
              , x_reservation_id             => l_reservation_id
              );
              IF (l_debug = 1) THEN
                 DEBUG('Quantity reserved: '|| l_quantity_reserved, 'Finalize_Pick_Confirm');
                 DEBUG('Reservation ID: '|| l_reservation_id, 'Finalize_Pick_Confirm');
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('Error in creating reservation for lot', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('Unexpected error in creating reservation for lot', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              --bug 1402436 - set the reservations staged flag
              inv_staged_reservation_util.update_staged_flag
                    (x_return_status        => l_return_status
                    , x_msg_count           => x_msg_count
                    , x_msg_data            => x_msg_data
                    , p_reservation_id      => l_reservation_id
                    , p_staged_flag         => 'Y'
                    );

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('Error in update_staged_flag', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('Unexpected error in update_staged_flag', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            END IF; -- Create or Update
          END IF; -- Lot control or not
        END IF; -- Staging sub reservable or not
      END IF; -- if reservation exists

      -- Call update shipping for the record transacted
      -- assign the changed attribute to shipping attribute.
      IF (l_debug = 1) THEN
         DEBUG('before select delivery_detail_id', 'Finalize_Pick_Confirm');
      END IF;

      BEGIN
        /* BUG 5570553 added the index hint with the suggestion of apps performance team */
        SELECT /*+index (WDD WSH_DELIVERY_DETAILS_N7)*/
                  delivery_detail_id, source_header_id, source_line_id
              INTO l_delivery_detail_id, l_source_header_id, l_source_line_id
              FROM wsh_delivery_details WDD
             WHERE WDD.move_order_line_id = l_mmtt_rec.move_order_line_id
               AND WDD.move_order_line_id IS NOT NULL
               AND WDD.released_status = 'S'
        FOR UPDATE NOWAIT;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INV_DELIV_INFO_MISSING');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        WHEN OTHERS THEN
          --could not lock row
          IF SQLCODE = -54 THEN
            fnd_message.set_name('INV', 'INV_DELIV_INFO_LOCKED');
            fnd_message.set_token('LINEID', l_trolin_rec.line_id);
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
      END;

      if (l_return_status = FND_API.G_RET_STS_ERROR) then
        RAISE FND_API.G_EXC_ERROR;
      elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      -- When calling shipping, pending quantity should be the total
      -- quantity remaining that Shipping has not been updated with
      IF (l_debug = 1) THEN
         DEBUG('after select delivery_detail_id', 'Finalize_Pick_Confirm');
         DEBUG('delivery_detail_id = '|| l_delivery_detail_id, 'Finalize_Pick_Confirm');
         DEBUG('p_xfr_transaction_id '||p_xfr_transaction_id,'Finalize_Pick_Confirm');
      END IF;
--bug 2678601 pass Transaction_id to shipping


      IF (l_debug = 1) THEN
        DEBUG('delivery_detail_id = '|| l_delivery_detail_id, 'Finalize_Pick_Confirm');
      END IF;
      l_InvPCInRecType.transaction_id :=p_xfr_transaction_id;
      l_InvPCInRecType.source_code :='INV';
      l_InvPCInRecType.api_version_number :=1.0;
      WSH_INTEGRATION.Set_Inv_PC_Attributes
	( p_in_attributes         =>   l_InvPCInRecType,
	  x_return_status         =>  l_return_status,
	  x_msg_count             =>   l_msg_count,
	  x_msg_data             =>    l_msg_data );
        IF  (l_debug = 1) THEN
         DEBUG('after Set_Inv_PC_Attributes Ret status'||l_return_status, 'Finalize_Pick_Confirm');        END IF;

              IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                IF (l_debug = 1) THEN
                  DEBUG('return error E from Set_Inv_PC_Attributes', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                  DEBUG('return error U from Set_Inv_PC_Attributes', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

      l_shipping_attr(1).source_header_id    := l_source_header_id;
      l_shipping_attr(1).source_line_id      := l_source_line_id;
      l_shipping_attr(1).ship_from_org_id    := l_mmtt_rec.organization_id;
      l_shipping_attr(1).subinventory        := l_mmtt_rec.transfer_subinventory;
      l_shipping_attr(1).revision            := l_mmtt_rec.revision;
      l_shipping_attr(1).locator_id          := l_mmtt_rec.transfer_to_location;
      l_shipping_attr(1).released_status     := 'Y';
      l_shipping_attr(1).delivery_detail_id  := l_delivery_detail_id;

      IF (l_mmtt_rec.content_lpn_id IS NOT NULL) THEN
        l_shipping_attr(1).transfer_lpn_id  := l_mmtt_rec.content_lpn_id;
      ELSE
        l_shipping_attr(1).transfer_lpn_id  := l_mmtt_rec.transfer_lpn_id;
      END IF;

        -- jaysingh
	-- we need to re-name already used container
	-- so that we can use it again
	/* part of bug fix 2640966 */


   ---- ** Commented below code againt ER : 6845650
/*
	    BEGIN

		 -- first get the container name
		 SELECT license_plate_number
		 INTO l_container_name
		 FROM wms_license_plate_numbers
		 WHERE organization_id= l_mmtt_rec.organization_id
		 AND lpn_id=l_shipping_attr(1).transfer_lpn_id;

		  SELECT wdd.released_status,wdd.delivery_detail_id
		  INTO l_status_code,l_container_delivery_det_id
		  FROM   wsh_delivery_details wdd
		  WHERE wdd.container_name =l_container_name
          AND wdd.released_status = 'X';  -- ER : 6845650

		  if l_status_code ='C' then
                  /* Release 12: LPN Synchronization
                     Uniqueness constraint on WDD.container_name is removed
                     So it is not required to append characters to the LPNs
                     to get a new containers name
                     Removed the following call to get_container_name */
                  /* l_new_container_name:=wms_shipping_transaction_pub.get_container_name(l_container_name);
                     l_container_rec(1).container_name:=l_new_container_name; */
/*                     l_container_rec(1).container_name:=l_container_name;
                     l_container_rec(1).delivery_detail_id:=l_container_delivery_det_id;
                     l_container_rec(1).lpn_id:=NULL;
                     l_container_rec(1).container_flag:='Y';
                     --Bug:2701925:REplaced the direct update statement with the call to the API

		     IF (l_debug = 1) THEN
   		     debug('BF CONTAINER EXISTS, Renamed to : ' || l_new_container_name,'Finalize_Pick_Confirm');
		     END IF;
                     WSH_CONTAINER_GRP.Update_Container(
                          p_api_version => 1.0,
                          p_init_msg_list => FND_API.G_FALSE,
             	          p_commit =>FND_API.G_FALSE,
	                  p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                          x_return_status =>  x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_container_rec => l_container_rec
                         );
                    IF( x_return_status in (FND_API.G_RET_STS_ERROR) ) THEN
                      IF (l_debug = 1) THEN
                         debug('WSH_Container_Grp.Update_Containers returns error','Finalize Pick Confirm');
                      END IF;
                      RAISE FND_API.G_EXC_ERROR;
                    ELSIF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
                     IF (l_debug = 1) THEN
                        debug('WSH_Container_Grp.Update_Containers returns success','Finalize Pick Confirm');
                     END IF;
                     RAISE  fnd_api.g_exc_unexpected_error;
                    ELSE
                      IF (l_debug = 1) THEN
                         debug(' AF CONTAINER EXISTS, Renamed to : ' || l_new_container_name,'Finalize Pick Confirm');
                      END IF;
                    END IF;


		    /*UPDATE WSH_DELIVERY_DETAILS
		    SET CONTAINER_NAME=l_new_container_name,
				       lpn_id=NULL,
				       last_update_date=sysdate,
				       last_updated_by=fnd_global.user_id,
				       last_update_login=fnd_global.login_id
		    WHERE container_name =  l_container_name ;
		      */
           /*
           IF (l_debug = 1) THEN
              debug('CONTAINER EXISTS, Renamed to : ' || l_new_container_name,'Finalize_Pick_Confirm');
           END IF;
            */
/*		  else
		    IF (l_debug = 1) THEN
   		    debug('LPN with status '|| l_status_code || 'found in wdd. Check for data corruption', 'Finalize_Pick_Confirm');
		    END IF;
		  end if;
	    EXCEPTION
	       WHEN NO_DATA_FOUND THEN
		null;
	    END;
*/
	/* end of bug fix 2640966 */

      l_shipping_attr(1).action_flag         := l_action_flag;
      IF (l_debug = 1) THEN
         DEBUG('l_source_header_id'|| l_source_header_id, 'Finalize_Pick_Confirm');
         DEBUG('l_source_line_id '|| l_source_line_id, 'Finalize_Pick_Confirm');
         DEBUG('l_organization_id '|| l_shipping_attr(1).ship_from_org_id, 'Finalize_Pick_Confirm');
         DEBUG('subinventory '|| l_shipping_attr(1).subinventory, 'Finalize_Pick_Confirm');
         DEBUG('revision '|| l_shipping_attr(1).revision, 'Finalize_Pick_Confirm');
         DEBUG('lot_number '|| l_shipping_attr(1).lot_number, 'Finalize_Pick_Confirm');
         DEBUG('locator_id '|| l_shipping_attr(1).locator_id, 'Finalize_Pick_Confirm');
         DEBUG('release status = '|| l_shipping_attr(1).released_status, 'Finalize_Pick_Confirm');
         DEBUG('delivery_detail_id '|| l_shipping_attr(1).delivery_detail_id, 'Finalize_Pick_Confirm');
         DEBUG('action flag is '|| l_shipping_attr(1).action_flag, 'Finalize_Pick_Confirm');
         DEBUG('about to call update shipping attributes', 'Finalize_Pick_Confirm');
      END IF;

      --initalizing l_InvPCInRecType to use for updating wdd with transaction_temp_id
      --l_InvPCInRecType.transaction_id needs to be preserved for each call to Set_Inv_PC_Attributes
      l_InvPCInRecType.source_code :='INV';
      l_InvPCInRecType.api_version_number :=1.0;

      IF ( (l_mmtt_rec.transaction_source_type_id = INV_GLOBALS.G_SourceType_SalesOrder) AND
           (l_mmtt_rec.transaction_action_id = INV_GLOBALS.G_Action_Stgxfr) ) THEN
        -- Call to new api to check if item is catch weight enabled.
        l_catch_weight_enabled := WMS_CATCH_WEIGHT_PVT.Get_Ont_Pricing_Qty_Source (
                                    p_api_version       => 1.0
                                  , x_return_status     => x_return_status
                                  , x_msg_count         => x_msg_count
                                  , x_msg_data          => x_msg_data
                                  , p_organization_id   => l_mmtt_rec.organization_id
                                  , p_inventory_item_id => l_mmtt_rec.inventory_item_id );
        IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
          fnd_message.set_name('INV', 'WMS_GET_CATCH_WEIGHT_ATT_FAIL');
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF  (l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY AND (NVL(l_lpn_id,-1)<=0)) THEN
          fnd_message.set_name('INV', 'WMS_CATCH_WEIGHT_NO_LPN_ERR');
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF;

      IF ( l_wms_org_flag ) THEN
        -- The check for this table is included to determine if the env is at wms I level
        IF ( G_WMS_I_OR_ABOVE IS NULL ) THEN
          BEGIN
            SELECT 1 INTO l_dummy_num
            FROM fnd_tables
            WHERE table_name = 'WMS_OP_PLANS_B'
            AND rownum < 2;
            G_WMS_I_OR_ABOVE := TRUE;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              G_WMS_I_OR_ABOVE := FALSE;
          END;
        END IF;
      ELSE -- Inventory only organization
        G_WMS_I_OR_ABOVE := FALSE;

        -- Check if OM at H level is installed flag is set meaning
        -- that shipping serial range enhancement should be used
        -- BUG 5074402 - cached this value for performance
        if g_omh_installed IS  NULL THEN
           g_omh_installed := NVL(FND_PROFILE.VALUE('INV_OMFPC2_INSTALLED'), 2);
        end if;
        l_omh_installed := g_omh_installed;
      END IF;

      IF (l_debug = 1) THEN
         DEBUG('om h installed: ' || l_omh_installed, 'Finalize_Pick_Confirm');
      END IF;

      IF ( l_lot_control_code > 1 AND l_serial_control_code NOT IN (1, 6) ) THEN
        -- Lot and serial controlled
        l_lot_shipping_quantity       := 0;
        l_lot_prim_shipping_quantity  := 0;
        l_ser_prim_shipping_quantity  := 0;
        l_serial_quantity             := 1;
        OPEN lot_csr(p_transaction_temp_id);

        LOOP
          FETCH lot_csr
          INTO l_lot_number
              , l_lot_primary_quantity
              , l_lot_transaction_quantity
              , l_lot_secondary_quantity
              , l_lot_secondary_uom
              , l_serial_trx_temp_id
              , l_grade_code;
          EXIT WHEN lot_csr%NOTFOUND;
          l_update_shipping  := TRUE;

          -- If this item is catch weight enabled, check to see if any other MTLT lines for
          -- this LPN.  If any do not have secondary quantity defined, do not populate
          -- picked_quantity2
          IF ( l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY AND
               l_lot_number <> l_previous_lot_number ) THEN
            l_previous_lot_number := l_lot_number;

            BEGIN
              SELECT WMS_CATCH_WEIGHT_PVT.G_PRICE_PRIMARY INTO l_catch_weight_enabled FROM DUAL
              WHERE EXISTS (
                SELECT 1
                FROM mtl_material_transactions_temp mmtt,
                     mtl_transaction_lots_temp mtlt
                WHERE mmtt.organization_id = l_mmtt_rec.organization_id
                AND   mmtt.inventory_item_id = l_mmtt_rec.inventory_item_id
                AND   NVL(mmtt.revision, '@') = NVL(l_mmtt_rec.revision, '@')
                AND   mmtt.transaction_source_type_id = INV_GLOBALS.G_SourceType_SalesOrder
                AND   mmtt.transaction_action_id = INV_GLOBALS.G_Action_Stgxfr
                AND   NVL(mmtt.content_lpn_id, mmtt.transfer_lpn_id) = l_lpn_id
                AND   mtlt.transaction_temp_id = mmtt.transaction_temp_id
                AND   mtlt.lot_number = l_lot_number
                AND   (mtlt.secondary_quantity IS NULL OR mtlt.secondary_unit_of_measure IS NULL) );
            EXCEPTION
              WHEN OTHERS THEN
                l_catch_weight_enabled := WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY;
            END;
            IF (l_debug = 1) THEN
              DEBUG('itemid='||l_mmtt_rec.inventory_item_id||' rev='||l_mmtt_rec.revision||' lot='||l_lot_number||' lpnid='||l_lpn_id||' cwe='||l_catch_weight_enabled, 'Finalize_Pick_Confirm');
            END IF;
          END IF;

          -- Only enable shipping serial range enhancement for WMS.I or non wms orgs with profile set
          IF ( ( G_WMS_I_OR_ABOVE OR ( NOT l_wms_org_flag AND l_omh_installed = 1 )  ) AND
               l_lot_primary_quantity <> 1 ) THEN
            --Serial numbers not stored in WDD, handle as a non sn controlled item
            IF l_lot_shipping_quantity > l_shipping_quantity THEN
              l_lot_transaction_quantity  := l_lot_transaction_quantity - (l_lot_shipping_quantity - l_shipping_quantity);
              l_lot_secondary_quantity  := l_lot_secondary_quantity - (l_sec_lot_shipping_quantity - l_sec_shipping_quantity);
              l_lot_primary_quantity      := l_lot_primary_quantity - (l_lot_prim_shipping_quantity - l_primary_shipping_quantity);
            END IF;

            EXIT WHEN l_lot_transaction_quantity <= 0;
            l_shipping_attr(1).serial_number     := NULL;
            l_shipping_attr(1).lot_number        := l_lot_number;
            l_shipping_attr(1).preferred_grade   := l_grade_code;
            l_shipping_attr(1).picked_quantity   := ABS(l_lot_primary_quantity);
            l_shipping_attr(1).picked_quantity2  := ABS(l_lot_secondary_quantity);
            --update pending quantity to reflect new pending quantity
            l_primary_pending_quantity           := l_primary_pending_quantity - ABS(l_lot_primary_quantity);
            l_sec_pending_quantity               := l_sec_pending_quantity - ABS(l_lot_secondary_quantity);
            l_shipping_attr(1).pending_quantity  := l_primary_pending_quantity;
            l_shipping_attr(1).pending_quantity2 := l_sec_pending_quantity;
            l_return_status                      := '';
            IF ( l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY ) THEN
              l_shipping_attr(1).picked_quantity2 := ABS(l_lot_secondary_quantity);
              l_shipping_attr(1).ordered_quantity_uom2 := l_lot_secondary_uom;
            END IF;

            --Use Set_Inv_PC_Attributes to set trx temp id to be populated in wdd
            --Fix for dependency issue on shipping's WSHDDINS.pls 115.64

            --Bug #3306493
            --Pass the serial_transaction_temp_id from MTLT stored in l_serial_trx_temp_id
            --when setting the transaction_temp_id attribute in INVPCInRecType
            --l_InvPCInRecType.transaction_temp_id := l_serial_transaction_temp_id;
            l_InvPCInRecType.transaction_temp_id := l_serial_trx_temp_id;

            IF (l_debug = 1) THEN
              DEBUG('Calling Set_Inv_PC_Attributes with trxid='||l_InvPCInRecType.transaction_id||' sertrxtmpid='||l_InvPCInRecType.transaction_temp_id, 'Finalize Pick Confirm');
            END IF;

            WSH_INTEGRATION.Set_Inv_PC_Attributes
            ( p_in_attributes         =>   l_InvPCInRecType,
              x_return_status         =>   l_return_status,
              x_msg_count             =>   l_msg_count,
              x_msg_data              =>   l_msg_data );
            IF (l_return_status = fnd_api.g_ret_sts_error) THEN
              IF (l_debug = 1) THEN
                DEBUG('return error E from Set_Inv_PC_Attributes', 'Finalize Pick Confirm');
              END IF;
              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                DEBUG('return error U from Set_Inv_PC_Attributes', 'Finalize Pick Confirm');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (l_debug = 1) THEN
               DEBUG('Calling Update Shipping Attributes for a serial range of lot items', 'Finalize Pick Confirm');
               DEBUG('Lot number  : '|| l_shipping_attr(1).lot_number, 'Finalize_Pick_Confirm');
               DEBUG('Picked qty  : '|| ABS(l_lot_primary_quantity), 'Finalize_Pick_Confirm');
               DEBUG('Picked qty2 : '|| l_shipping_attr(1).picked_quantity2, l_api_name);
               DEBUG('Ordered uom2: '|| l_shipping_attr(1).ordered_quantity_uom2, l_api_name);
               DEBUG('Pending qty : '|| l_shipping_attr(1).pending_quantity, 'Finalize_Pick_Confirm');
            END IF;

            --Check to see if it is the case of overpicking, if yes, then adjust the serials in MSNT
            IF  (l_trolin_rec.quantity_delivered > NVL(l_trolin_rec.required_quantity, l_trolin_rec.quantity)) THEN
              --Bug #3306493
              --Adjust_serial_numbers_in_MSNT(l_serial_transaction_temp_id,l_lot_primary_quantity);
              Adjust_serial_numbers_in_MSNT(l_serial_trx_temp_id,l_lot_primary_quantity);
            END IF;

            wsh_interface.update_shipping_attributes(p_source_code => 'INV', p_changed_attributes => l_shipping_attr, x_return_status => l_return_status);
            IF (l_debug = 1) THEN
               DEBUG('after update shipping attributes', 'Finalize_Pick_Confirm');
            END IF;

            IF (l_return_status = fnd_api.g_ret_sts_error) THEN
              IF (l_debug = 1) THEN
                 DEBUG('return error from update shipping attributes', 'Finalize_Pick_Confirm');
              END IF;
              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                 DEBUG('return error from update shipping attributes', 'Finalize_Pick_Confirm');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          ELSE -- Either only a single serial item or not WMS.I process the old way
            IF ( l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY ) THEN
              -- Calculate the secondary quantity for a single serial number
              l_serial_secondary_quantity := l_lot_secondary_quantity*(1/l_lot_primary_quantity);
            END IF;

            OPEN serial_csr(p_transaction_temp_id, l_lot_control_code, l_serial_trx_temp_id,
                            l_mmtt_rec.organization_id, l_mmtt_rec.inventory_item_id);
            LOOP
              FETCH serial_csr INTO l_serial_number;
              EXIT WHEN serial_csr%NOTFOUND;
              IF (l_debug = 1) THEN
                 DEBUG('serial number:'|| l_serial_number, 'Finalize_Pick_Confirm');
              END IF;
              --bug 2123867
              -- ser_prim_shipping_quantity was being incremented
              -- even when serial_csr returned no data found.  Only half
              -- of the serial numbers were being passed to shipping.
              -- Moved Exit condition of notfound before increment.
              l_ser_prim_shipping_quantity  := l_ser_prim_shipping_quantity + 1;

              IF l_ser_prim_shipping_quantity > l_primary_shipping_quantity THEN
                IF (l_debug = 1) THEN
                   DEBUG('Serial quantity > shipping quantity', 'Finalize_Pick_Confirm');
                   DEBUG('Serial Qty: '|| l_ser_prim_shipping_quantity, 'Finalize_Pick_Confirm');
                END IF;
                l_serial_quantity  := 0;
                l_update_shipping  := FALSE;
              END IF;

              IF l_update_shipping = TRUE THEN
                l_shipping_attr(1).serial_number     := l_serial_number;
                l_shipping_attr(1).lot_number        := l_lot_number;
                l_shipping_attr(1).preferred_grade   := l_grade_code;
                l_shipping_attr(1).picked_quantity   := 1;
                l_shipping_attr(1).picked_quantity2  := null;
                --update pending quantity to reflect new pending quantity
                l_primary_pending_quantity           := l_primary_pending_quantity - 1;
                l_shipping_attr(1).pending_quantity  := l_primary_pending_quantity;
                l_shipping_attr(1).pending_quantity2 := null;
                l_return_status                      := '';

                IF ( l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY ) THEN
                  l_shipping_attr(1).picked_quantity2 := l_serial_secondary_quantity;
                  l_shipping_attr(1).ordered_quantity_uom2 := l_lot_secondary_uom;
                END IF;

                --Use Set_Inv_PC_Attributes to set trx temp id to be populated in wdd
                --Fix for dependency issue on shipping's WSHDDINS.pls 115.64
                l_InvPCInRecType.transaction_temp_id := NULL;

                IF (l_debug = 1) THEN
                  DEBUG('Calling Set_Inv_PC_Attributes with trxid='||l_InvPCInRecType.transaction_id||' trxtmpid='||l_InvPCInRecType.transaction_temp_id, 'Finalize Pick Confirm');
                END IF;

                WSH_INTEGRATION.Set_Inv_PC_Attributes
                ( p_in_attributes         =>   l_InvPCInRecType,
                  x_return_status         =>   l_return_status,
                  x_msg_count             =>   l_msg_count,
                  x_msg_data              =>   l_msg_data );
                IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                  IF (l_debug = 1) THEN
                    DEBUG('return error E from Set_Inv_PC_Attributes', 'Finalize Pick Confirm');
                  END IF;
                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                    DEBUG('return error U from Set_Inv_PC_Attributes', 'Finalize Pick Confirm');
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF (l_debug = 1) THEN
                   DEBUG('Calling Update Shipping Attributes', 'Finalize Pick Confirm');
                   DEBUG('Lot number  : '|| l_shipping_attr(1).lot_number, 'Finalize_Pick_Confirm');
                   DEBUG('Picked qty  : '|| l_shipping_attr(1).picked_quantity, 'Finalize_Pick_Confirm');
                   DEBUG('Picked qty2 : '|| l_shipping_attr(1).picked_quantity2, l_api_name);
                   DEBUG('Ordered uom2: '|| l_shipping_attr(1).ordered_quantity_uom2, l_api_name);
                   DEBUG('Pending qty : '|| l_shipping_attr(1).pending_quantity, 'Finalize_Pick_Confirm');
                END IF;
                wsh_interface.update_shipping_attributes(p_source_code => 'INV', p_changed_attributes => l_shipping_attr, x_return_status => l_return_status);
                IF (l_debug = 1) THEN
                   DEBUG('after update shipping attributes', 'Finalize_Pick_Confirm');
                END IF;

                IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                  IF (l_debug = 1) THEN
                     DEBUG('return error from update shipping attributes', 'Finalize_Pick_Confirm');
                  END IF;
                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                     DEBUG('return error from update shipping attributes', 'Finalize_Pick_Confirm');
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;
              ELSE
                -- Unmark the remaining serials
               /*** {{ R12 Enhanced reservations code changes,
                *** call serial_check.inv_unmark_rsv_serial instead of update msn directly
                UPDATE mtl_serial_numbers
                   SET group_mark_id = NULL
                 WHERE serial_number = l_serial_number
                   AND inventory_item_id = l_mmtt_rec.inventory_item_id;
                *** End R12 }} ***/

               /*** {{ R12 Enhanced reservations code changes ***/
                serial_check.inv_unmark_rsv_serial
                   (from_serial_number   => l_serial_number
                   ,to_serial_number     => null
                   ,serial_code          => null
                   ,hdr_id               => null
                   ,p_inventory_item_id  => l_mmtt_rec.inventory_item_id
                   ,p_update_reservation => fnd_api.g_true);
               /*** End R12 }} ***/
              END IF;
            END LOOP;
            CLOSE serial_csr;

            IF ( l_lot_primary_quantity <> 1 ) THEN
              -- MSNT records need to be deleted since TM does not
              DELETE FROM mtl_serial_numbers_temp
              WHERE transaction_temp_id = l_serial_trx_temp_id;
            END IF;
          END IF;
        END LOOP;

        CLOSE lot_csr;
      ELSIF ( l_lot_control_code = 1 AND l_serial_control_code NOT IN (1, 6) ) THEN
        -- If this item is catch weight enabled, check to see if any other MMTT lines for
        -- this LPN.  If any do not have secondary quantity defined, do not populate
        -- picked_quantity2
        IF ( l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY ) THEN
          BEGIN
            SELECT WMS_CATCH_WEIGHT_PVT.G_PRICE_PRIMARY INTO l_catch_weight_enabled FROM DUAL
            WHERE EXISTS (
              SELECT 1
              FROM mtl_material_transactions_temp mmtt
              WHERE mmtt.organization_id = l_mmtt_rec.organization_id
              AND   mmtt.inventory_item_id = l_mmtt_rec.inventory_item_id
              AND   NVL(mmtt.revision, '@') = NVL(l_mmtt_rec.revision, '@')
              AND   mmtt.transaction_source_type_id = INV_GLOBALS.G_SourceType_SalesOrder
              AND   mmtt.transaction_action_id = INV_GLOBALS.G_Action_Stgxfr
              AND   NVL(mmtt.content_lpn_id, mmtt.transfer_lpn_id) = l_lpn_id
              AND   (mmtt.secondary_transaction_quantity IS NULL OR mmtt.secondary_uom_code IS NULL) );
          EXCEPTION
            WHEN OTHERS THEN
              l_catch_weight_enabled := WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY;
          END;
          IF (l_debug = 1) THEN
            DEBUG('itemid='||l_mmtt_rec.inventory_item_id||' rev='||l_mmtt_rec.revision||' lot='||l_lot_number||' lpnid='||l_lpn_id||' cwe='||l_catch_weight_enabled, l_api_name);
          END IF;
        END IF;

        -- Only enable shipping serial range enhancement for WMS.I or non wms orgs with profile set
          IF ( ( G_WMS_I_OR_ABOVE OR ( NOT l_wms_org_flag AND l_omh_installed = 1 )  ) AND
               l_primary_shipping_quantity <> 1 )THEN
          --Serial numbers not stored in WDD, handle as a non sn controlled item
          l_shipping_attr(1).serial_number     := NULL;
          l_shipping_attr(1).picked_quantity   := l_primary_shipping_quantity;
          l_shipping_attr(1).picked_quantity2  := l_sec_shipping_quantity;
          --update pending quantity to reflect new pending quantity
          l_primary_pending_quantity           := l_primary_pending_quantity - l_primary_shipping_quantity;
          l_sec_pending_quantity               := l_sec_pending_quantity - l_sec_shipping_quantity;
          l_shipping_attr(1).pending_quantity  := l_primary_pending_quantity;
          l_shipping_attr(1).pending_quantity2 := l_sec_pending_quantity;
          l_return_status                      := '';
          IF ( l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY ) THEN
            l_shipping_attr(1).picked_quantity2 := l_mmtt_rec.secondary_transaction_quantity;
            l_shipping_attr(1).ordered_quantity_uom2 := l_mmtt_rec.secondary_uom_code;
          END IF;

          --Use Set_Inv_PC_Attributes to set trx temp id to be populated in wdd
          --Fix for dependency issue on shipping's WSHDDINS.pls 115.64
          l_InvPCInRecType.transaction_temp_id := p_transaction_temp_id;

          IF (l_debug = 1) THEN
            DEBUG('Calling Set_Inv_PC_Attributes with trxid='||l_InvPCInRecType.transaction_id||' trxtmpid='||l_InvPCInRecType.transaction_temp_id, 'Finalize Pick Confirm');
          END IF;

          WSH_INTEGRATION.Set_Inv_PC_Attributes
          ( p_in_attributes         =>   l_InvPCInRecType,
            x_return_status         =>   l_return_status,
            x_msg_count             =>   l_msg_count,
            x_msg_data              =>   l_msg_data );
          IF (l_return_status = fnd_api.g_ret_sts_error) THEN
            IF (l_debug = 1) THEN
              DEBUG('return error E from Set_Inv_PC_Attributes', 'Finalize Pick Confirm');
            END IF;
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              DEBUG('return error U from Set_Inv_PC_Attributes', 'Finalize Pick Confirm');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          IF (l_debug = 1) THEN
             DEBUG('Calling Update Shipping Attributes for a serial range', 'Finalize Pick Confirm');
             DEBUG('Picked qty  : '|| l_shipping_attr(1).picked_quantity, 'Finalize_Pick_Confirm');
             DEBUG('Picked qty2 : '|| l_shipping_attr(1).picked_quantity2, l_api_name);
             DEBUG('Ordered uom2: '|| l_shipping_attr(1).ordered_quantity_uom2, l_api_name);
             DEBUG('Pending qty : '|| l_shipping_attr(1).pending_quantity, 'Finalize_Pick_Confirm');
          END IF;

          --Check to see if it is the case of overpicking, if yes, then adjust the serials in MSNT
          IF  (l_trolin_rec.quantity_delivered > NVL(l_trolin_rec.required_quantity, l_trolin_rec.quantity)) THEN
                 Adjust_serial_numbers_in_MSNT(p_transaction_temp_id,l_shipping_attr(1).picked_quantity);
          END IF;

          wsh_interface.update_shipping_attributes(p_source_code => 'INV', p_changed_attributes => l_shipping_attr, x_return_status => l_return_status);
          IF (l_debug = 1) THEN
             DEBUG('after update shipping attributes', 'Finalize_Pick_Confirm');
          END IF;

          IF (l_return_status = fnd_api.g_ret_sts_error) THEN
            IF (l_debug = 1) THEN
               DEBUG('return error from update shipping attributes', 'Finalize_Pick_Confirm');
            END IF;
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
               DEBUG('return unexpected error from update shipping attributes', 'Finalize_Pick_Confirm');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE -- Either only a single serial item or not WMS.I process the old way
          l_serial_trx_temp_id          := 0;
          l_ser_prim_shipping_quantity  := 0;
          l_serial_quantity             := 1;
          l_update_shipping             := TRUE;
          IF ( l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY ) THEN
            -- Calculate the secondary quantity for a single serial number
            l_serial_secondary_quantity := l_mmtt_rec.secondary_transaction_quantity*(1/l_primary_shipping_quantity);
          END IF;

          OPEN serial_csr(p_transaction_temp_id, l_lot_control_code, l_serial_trx_temp_id,
                          l_mmtt_rec.organization_id, l_mmtt_rec.inventory_item_id);
          LOOP
            FETCH serial_csr INTO l_serial_number;
            EXIT WHEN serial_csr%NOTFOUND;
            IF (l_debug = 1) THEN
               DEBUG('serial number:'|| l_serial_number, 'Finalize_Pick_Confirm');
            END IF;
            l_ser_prim_shipping_quantity  := l_ser_prim_shipping_quantity + 1;

            IF l_ser_prim_shipping_quantity > l_primary_shipping_quantity THEN
              IF (l_debug = 1) THEN
                 DEBUG('Serial quantity > shipping quantity', 'Finalize_Pick_Confirm');
                 DEBUG('Serial Qty: '|| l_ser_prim_shipping_quantity, 'Finalize_Pick_Confirm');
              END IF;
              l_serial_quantity  := 0;
              l_update_shipping  := FALSE;
            END IF;

            IF l_update_shipping = TRUE THEN
              l_shipping_attr(1).serial_number     := l_serial_number;
              l_shipping_attr(1).picked_quantity   := 1;
              l_shipping_attr(1).picked_quantity2  := null;
              --update pending quantity to reflect new pending quantity
              l_primary_pending_quantity           := l_primary_pending_quantity - 1;
              l_shipping_attr(1).pending_quantity  := l_primary_pending_quantity;
              l_shipping_attr(1).pending_quantity2 := null;
              l_return_status                      := '';
              IF ( l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY ) THEN
                l_shipping_attr(1).picked_quantity2 := l_serial_secondary_quantity;
            	l_shipping_attr(1).ordered_quantity_uom2 := l_mmtt_rec.secondary_uom_code;
              END IF;

              --Use Set_Inv_PC_Attributes to set trx temp id to be populated in wdd
              --Fix for dependency issue on shipping's WSHDDINS.pls 115.64
              l_InvPCInRecType.transaction_temp_id := NULL;

              IF (l_debug = 1) THEN
                DEBUG('Calling Set_Inv_PC_Attributes with trxid='||l_InvPCInRecType.transaction_id||' trxtmpid='||l_InvPCInRecType.transaction_temp_id, 'Finalize Pick Confirm');
              END IF;

              WSH_INTEGRATION.Set_Inv_PC_Attributes
              ( p_in_attributes         =>   l_InvPCInRecType,
                x_return_status         =>   l_return_status,
                x_msg_count             =>   l_msg_count,
                x_msg_data              =>   l_msg_data );
              IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                IF (l_debug = 1) THEN
                  DEBUG('return error E from Set_Inv_PC_Attributes', 'Finalize Pick Confirm');
                END IF;
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                  DEBUG('return error U from Set_Inv_PC_Attributes', 'Finalize Pick Confirm');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              IF (l_debug = 1) THEN
                 DEBUG('Calling Update Shipping Attributes', 'Finalize Pick Confirm');
                 DEBUG('Picked qty  : '|| l_shipping_attr(1).picked_quantity, 'Finalize_Pick_Confirm');
                 DEBUG('Picked qty2 : '|| l_shipping_attr(1).picked_quantity2, l_api_name);
                 DEBUG('Ordered uom2: '|| l_shipping_attr(1).ordered_quantity_uom2, l_api_name);
                 DEBUG('Pending qty : '|| l_shipping_attr(1).pending_quantity, 'Finalize_Pick_Confirm');
              END IF;
              wsh_interface.update_shipping_attributes(p_source_code => 'INV', p_changed_attributes => l_shipping_attr, x_return_status => l_return_status);
              IF (l_debug = 1) THEN
                 DEBUG('after update shipping attributes', 'Finalize_Pick_Confirm');
              END IF;

              IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                IF (l_debug = 1) THEN
                   DEBUG('return error from update shipping attributes', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('return error from update shipping attributes', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            ELSE
              -- Unmark the remaining serials
             /*** {{ R12 Enhanced reservations code changes,
              *** call serial_check.inv_unmark_rsv_serial instead of update msn directly
              UPDATE mtl_serial_numbers
                 SET group_mark_id = NULL
               WHERE serial_number = l_serial_number
                 AND inventory_item_id = l_mmtt_rec.inventory_item_id;
              *** End R12 }} ***/

             /*** {{ R12 Enhanced reservations code changes ***/
              serial_check.inv_unmark_rsv_serial
                 (from_serial_number   => l_serial_number
                 ,to_serial_number     => null
                 ,serial_code          => null
                 ,hdr_id               => null
                 ,p_inventory_item_id  => l_mmtt_rec.inventory_item_id
                 ,p_update_reservation => fnd_api.g_true);
             /*** End R12 }} ***/
            END IF;
          END LOOP;
          CLOSE serial_csr;

          IF ( l_primary_shipping_quantity <> 1 ) THEN
            -- MSNT records need to be deleted since TM does not
            DELETE FROM mtl_serial_numbers_temp
            WHERE transaction_temp_id = p_transaction_temp_id;
          END IF;
        END IF;
      ELSIF ( l_lot_control_code > 1 AND l_serial_control_code IN (1, 6)) THEN
        -- Only lot controlled
        l_lot_shipping_quantity       := 0;
        l_lot_prim_shipping_quantity  := 0;
        OPEN lot_csr(p_transaction_temp_id);

        LOOP
          FETCH lot_csr INTO l_lot_number, l_lot_primary_quantity, l_lot_transaction_quantity,
                             l_lot_secondary_quantity, l_lot_secondary_uom, l_serial_trx_temp_id, l_grade_code;
          EXIT WHEN lot_csr%NOTFOUND;

          -- If this item is catch weight enabled, check to see if any other MTLT lines for
          -- this LPN.  If any do not have secondary quantity defined, do not populate
          -- picked_quantity2
          IF ( l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY AND
               l_lot_number <> l_previous_lot_number ) THEN
            l_previous_lot_number := l_lot_number;

            BEGIN
              SELECT WMS_CATCH_WEIGHT_PVT.G_PRICE_PRIMARY INTO l_catch_weight_enabled FROM DUAL
              WHERE EXISTS (
                SELECT 1
                FROM mtl_material_transactions_temp mmtt,
                     mtl_transaction_lots_temp mtlt
                WHERE mmtt.organization_id = l_mmtt_rec.organization_id
                AND   mmtt.inventory_item_id = l_mmtt_rec.inventory_item_id
                AND   NVL(mmtt.revision, '@') = NVL(l_mmtt_rec.revision, '@')
                AND   mmtt.transaction_source_type_id = INV_GLOBALS.G_SourceType_SalesOrder
                AND   mmtt.transaction_action_id = INV_GLOBALS.G_Action_Stgxfr
                AND   NVL(mmtt.content_lpn_id, mmtt.transfer_lpn_id) = l_lpn_id
                AND   mtlt.transaction_temp_id = mmtt.transaction_temp_id
                AND   mtlt.lot_number = l_lot_number
                AND   (mtlt.secondary_quantity IS NULL OR mtlt.secondary_unit_of_measure IS NULL) );
            EXCEPTION
              WHEN OTHERS THEN
                l_catch_weight_enabled := WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY;
            END;
            IF (l_debug = 1) THEN
              DEBUG('itemid='||l_mmtt_rec.inventory_item_id||' rev='||l_mmtt_rec.revision||' lot='||l_lot_number||' lpnid='||l_lpn_id||' cwe='||l_catch_weight_enabled, l_api_name);
            END IF;
          END IF;

          l_lot_shipping_quantity              := l_lot_shipping_quantity + l_lot_transaction_quantity;
          l_lot_prim_shipping_quantity         := l_lot_prim_shipping_quantity + l_lot_primary_quantity;

          IF l_lot_shipping_quantity > l_shipping_quantity THEN
            l_lot_transaction_quantity  := l_lot_transaction_quantity - (l_lot_shipping_quantity - l_shipping_quantity);
            l_lot_primary_quantity      := l_lot_primary_quantity - (l_lot_prim_shipping_quantity - l_primary_shipping_quantity);
          END IF;

          EXIT WHEN l_lot_transaction_quantity <= 0;
          l_shipping_attr(1).lot_number        := l_lot_number;
          l_shipping_attr(1).preferred_grade   := l_grade_code;
          l_shipping_attr(1).picked_quantity   := ABS(l_lot_primary_quantity);
          l_shipping_attr(1).picked_quantity2  := ABS(l_lot_secondary_quantity);
          --update pending quantity to reflect new pending quantity
          l_primary_pending_quantity           := l_primary_pending_quantity - ABS(l_lot_primary_quantity);
          l_sec_pending_quantity               := l_sec_pending_quantity - ABS(l_lot_secondary_quantity);
          l_shipping_attr(1).pending_quantity  := l_primary_pending_quantity;
          l_shipping_attr(1).pending_quantity2 := l_sec_pending_quantity;
          l_return_status                      := '';
          IF ( l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY ) THEN
            l_shipping_attr(1).picked_quantity2 := ABS(l_lot_secondary_quantity);
            l_shipping_attr(1).ordered_quantity_uom2 := l_lot_secondary_uom;
          END IF;

          --Use Set_Inv_PC_Attributes to set trx temp id to be populated in wdd
          --Fix for dependency issue on shipping's WSHDDINS.pls 115.64
          l_InvPCInRecType.transaction_temp_id := NULL;

          IF (l_debug = 1) THEN
            DEBUG('Calling Set_Inv_PC_Attributes with trxid='||l_InvPCInRecType.transaction_id||' trxtmpid='||l_InvPCInRecType.transaction_temp_id, 'Finalize Pick Confirm');
          END IF;

          WSH_INTEGRATION.Set_Inv_PC_Attributes
          ( p_in_attributes         =>   l_InvPCInRecType,
            x_return_status         =>   l_return_status,
            x_msg_count             =>   l_msg_count,
            x_msg_data              =>   l_msg_data );
          IF (l_return_status = fnd_api.g_ret_sts_error) THEN
            IF (l_debug = 1) THEN
              DEBUG('return error E from Set_Inv_PC_Attributes', 'Finalize Pick Confirm');
            END IF;
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              DEBUG('return error U from Set_Inv_PC_Attributes', 'Finalize Pick Confirm');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          IF (l_debug = 1) THEN
             DEBUG('Calling Update Shipping Attributes', 'Finalize Pick Confirm');
             DEBUG('Picked qty  : '|| ABS(l_lot_primary_quantity), 'Finalize_Pick_Confirm');
             DEBUG('Picked qty2 : '|| l_shipping_attr(1).picked_quantity2, l_api_name);
             DEBUG('Ordered uom2: '|| l_shipping_attr(1).ordered_quantity_uom2, l_api_name);
             DEBUG('Pending qty : '|| l_primary_pending_quantity, 'Finalize_Pick_Confirm');
          END IF;
          wsh_interface.update_shipping_attributes(p_source_code => 'INV', p_changed_attributes => l_shipping_attr, x_return_status => l_return_status);
          IF (l_debug = 1) THEN
             DEBUG('after update shipping attributes', 'Finalize_Pick_Confirm');
          END IF;

          IF (l_return_status = fnd_api.g_ret_sts_error) THEN
            IF (l_debug = 1) THEN
               DEBUG('return error from update shipping attributes', 'Finalize_Pick_Confirm');
            END IF;
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
               DEBUG('return error from update shipping attributes', 'Finalize_Pick_Confirm');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END LOOP;

        CLOSE lot_csr;
      ELSE
        -- No lot or serial control
        -- If this item is catch weight enabled, check to see if any other MMTT lines for
        -- this LPN.  If any do not have secondary quantity defined, do not populate
        -- picked_quantity2
        IF ( l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY ) THEN
          BEGIN
            SELECT WMS_CATCH_WEIGHT_PVT.G_PRICE_PRIMARY INTO l_catch_weight_enabled FROM DUAL
            WHERE EXISTS (
              SELECT 1
              FROM mtl_material_transactions_temp mmtt
              WHERE mmtt.organization_id = l_mmtt_rec.organization_id
              AND   mmtt.inventory_item_id = l_mmtt_rec.inventory_item_id
              AND   NVL(mmtt.revision, '@') = NVL(l_mmtt_rec.revision, '@')
              AND   mmtt.transaction_source_type_id = INV_GLOBALS.G_SourceType_SalesOrder
              AND   mmtt.transaction_action_id = INV_GLOBALS.G_Action_Stgxfr
              AND   NVL(mmtt.content_lpn_id, mmtt.transfer_lpn_id) = l_lpn_id
              AND   (mmtt.secondary_transaction_quantity IS NULL OR mmtt.secondary_uom_code IS NULL) );
          EXCEPTION
            WHEN OTHERS THEN
              l_catch_weight_enabled := WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY;
          END;
          IF (l_debug = 1) THEN
            DEBUG('itemid='||l_mmtt_rec.inventory_item_id||' rev='||l_mmtt_rec.revision||' lot='||l_lot_number||' lpnid='||l_lpn_id||' cwe='||l_catch_weight_enabled, l_api_name);
          END IF;
        END IF;

        l_shipping_attr(1).picked_quantity   := l_primary_shipping_quantity;
        l_shipping_attr(1).picked_quantity2  := l_sec_shipping_quantity;
        --update pending quantity to reflect new pending quantity
        l_primary_pending_quantity           := l_primary_pending_quantity - l_primary_shipping_quantity;
        l_sec_pending_quantity               := l_sec_pending_quantity - l_sec_shipping_quantity;
        l_shipping_attr(1).pending_quantity  := l_primary_pending_quantity;
        l_shipping_attr(1).pending_quantity2 := l_sec_pending_quantity;
        l_return_status                      := '';
        IF ( l_catch_weight_enabled = WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY ) THEN
          l_shipping_attr(1).picked_quantity2 := ABS(l_mmtt_rec.secondary_transaction_quantity);
          l_shipping_attr(1).ordered_quantity_uom2 := l_mmtt_rec.secondary_uom_code;
        END IF;

        --Use Set_Inv_PC_Attributes to set trx temp id to be populated in wdd
        --Fix for dependency issue on shipping's WSHDDINS.pls 115.64
        l_InvPCInRecType.transaction_temp_id := NULL;

        IF (l_debug = 1) THEN
          DEBUG('Calling Set_Inv_PC_Attributes with trxid='||l_InvPCInRecType.transaction_id||' trxtmpid='||l_InvPCInRecType.transaction_temp_id, 'Finalize Pick Confirm');
        END IF;

        WSH_INTEGRATION.Set_Inv_PC_Attributes
        ( p_in_attributes         =>   l_InvPCInRecType,
          x_return_status         =>   l_return_status,
          x_msg_count             =>   l_msg_count,
          x_msg_data              =>   l_msg_data );
        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          IF (l_debug = 1) THEN
            DEBUG('return error E from Set_Inv_PC_Attributes', 'Finalize Pick Confirm');
          END IF;
          RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
            DEBUG('return error U from Set_Inv_PC_Attributes', 'Finalize Pick Confirm');
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF (l_debug = 1) THEN
           DEBUG('Calling Update Shipping Attributes', 'Finalize Pick Confirm');
           DEBUG('Picked qty  : '|| l_primary_shipping_quantity, 'Finalize_Pick_Confirm');
           DEBUG('Picked qty2 : '|| l_shipping_attr(1).picked_quantity2, l_api_name);
           DEBUG('Ordered uom2: '|| l_shipping_attr(1).ordered_quantity_uom2, l_api_name);
           DEBUG('Pending qty : '|| l_primary_pending_quantity, 'Finalize_Pick_Confirm');
        END IF;
        wsh_interface.update_shipping_attributes(p_source_code => 'INV', p_changed_attributes => l_shipping_attr, x_return_status => l_return_status);
        IF (l_debug = 1) THEN
           DEBUG('after update shipping attributes', 'Finalize_Pick_Confirm');
        END IF;

        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          IF (l_debug = 1) THEN
             DEBUG('return error from update shipping attributes', 'Finalize_Pick_Confirm');
          END IF;
          RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
             DEBUG('return unexpected error from update shipping attributes', 'Finalize_Pick_Confirm');
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF; -- lot control and serial control

      IF l_trolin_rec.line_status = 5 THEN
        -- If this is the last allocation line for the last move order
        -- line for the sales order then delete all the unstaged
        -- reservations for this record. This will also delete
        -- reservations which are against the backordered lines.
        clean_reservations(p_source_line_id => l_trolin_rec.txn_source_line_id, x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data);

        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          IF (l_debug = 1) THEN
             DEBUG('return error from clean reservations', 'Finalize_Pick_Confirm');
          END IF;
          RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
             DEBUG('return unexpected error from clean reservations', 'Finalize_Pick_Confirm');
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Bug 1838450
        -- Fix the detailed quantity on all reservations for this
        --  sales order line. Necessary for underpicking.
        IF (l_debug = 1) THEN
           DEBUG('Cleaning up reservations', 'Finalize_Pick_Confirm');
        END IF;
        OPEN reservations_csr;

        LOOP
          FETCH reservations_csr INTO l_reservation_id, l_rsv_primary_quantity, l_rsv_detailed_quantity;
          EXIT WHEN reservations_csr%NOTFOUND;
          IF (l_debug = 1) THEN
             DEBUG('Found first reservation: '|| l_reservation_id, 'Finalize_Pick_Confirm');
          END IF;

          --for each reservation, check to see what the actual
          --allocated quantity is
          SELECT NVL(SUM(ABS(primary_quantity)), 0)
              ,  NVL(SUM(ABS(secondary_transaction_quantity)), 0)
            INTO l_mmtt_rsv_quantity
              ,  l_sec_mmtt_rsv_quantity
            FROM mtl_material_transactions_temp
           WHERE reservation_id = l_reservation_id;

          -- need to subtract from the mmtt rsv quantity the
          --  quantity of the reservations that have already been
          --  picked, since the rsv's detailed quantity does not
          --  include this quantity
          IF g_rsv_picked_quantity_tbl.EXISTS(l_reservation_id) THEN
            l_mmtt_rsv_quantity  := l_mmtt_rsv_quantity - g_rsv_picked_quantity_tbl(l_reservation_id).picked_quantity;
	    l_sec_mmtt_rsv_quantity  := l_sec_mmtt_rsv_quantity - g_rsv_picked_quantity_tbl(l_reservation_id).sec_picked_quantity;--Added for bug 8926143
          END IF;

          -- Update reservation if necessary
          IF l_mmtt_rsv_quantity < l_rsv_detailed_quantity THEN
            --call update reservation
            l_mtl_reservation_rec2.reservation_id     := l_reservation_id;
            l_mtl_reservation_rec3.reservation_id     := l_reservation_id;
            l_mtl_reservation_rec3.detailed_quantity  := l_mmtt_rsv_quantity;
            l_mtl_reservation_rec3.secondary_detailed_quantity  := l_sec_mmtt_rsv_quantity;
            IF (l_debug = 1) THEN
               DEBUG('reservation id is '|| l_mtl_reservation_rec2.reservation_id, 'Finalize_Pick_Confirm');
               DEBUG('primary_reservation quantity is '|| l_mtl_reservation_rec3.primary_reservation_quantity, 'Finalize_Pick_Confirm');
               DEBUG('detailed quantity is '|| l_mtl_reservation_rec3.detailed_quantity, 'Finalize_Pick_Confirm');
	       DEBUG('secondary detailed quantity is '|| l_mtl_reservation_rec3.secondary_detailed_quantity, 'Finalize_Pick_Confirm');
            END IF;

--INVCONV - Make sure Qty2 are NULL if nor present
        IF (  l_mtl_reservation_rec.secondary_uom_code IS NULL ) THEN
              l_mtl_reservation_rec.secondary_reservation_quantity := NULL;
              l_mtl_reservation_rec.secondary_detailed_quantity    := NULL;
        END IF;
            inv_reservation_pub.update_reservation(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_original_rsv_rec           => l_mtl_reservation_rec2
            , p_to_rsv_rec                 => l_mtl_reservation_rec3
            , p_original_serial_number     => l_original_serial_number
            , p_to_serial_number           => l_to_serial_number
            , p_validation_flag            => fnd_api.g_true
            , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
            );
            IF (l_debug = 1) THEN
               DEBUG('after update reservation return status is '|| l_return_status, 'Finalize_Pick_Confirm');
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF; -- if allocated quantity < detailed rsv quantity
        END LOOP;
        IF reservations_csr%ISOPEN THEN
          CLOSE reservations_csr;
        END IF;
      END IF; -- line status = 5
    END IF; -- if move order type = 3

    If l_move_order_type = 5 and l_wip_entity_type in (9,10) then -- GME move orders
      IF (l_debug = 1) THEN
         DEBUG('inside l_move_order_ytpe = 5, and GME move orders', 'Finalize_Pick_Confirm');
      END IF;

      SELECT lot_control_code
           , serial_number_control_code
           , reservable_type
        INTO l_lot_control_code
           , l_serial_control_code
           , l_reservable_type_item
        FROM mtl_system_items
       WHERE inventory_item_id = l_mmtt_rec.inventory_item_id
         AND organization_id = l_mmtt_rec.organization_id;

      IF (l_debug = 1) THEN
         DEBUG('After select lot_control_code = '|| l_lot_control_code, 'Finalize_Pick_confirm');
         DEBUG('After select l_serial_control_code = '|| l_serial_control_code, 'Finalize_Pick_Confirm');
      END IF;

      -- Bug 5535030: cache subinventory reservable type
      l_hash_value := DBMS_UTILITY.get_hash_value
                      ( NAME      => to_char(l_mmtt_rec.organization_id)
                                     ||'-'|| l_mmtt_rec.transfer_subinventory
                      , base      => 1
                      , hash_size => POWER(2, 25)
                      );
      IF g_is_sub_reservable.EXISTS(l_hash_value) AND
         g_is_sub_reservable(l_hash_value).org_id = l_mmtt_rec.organization_id AND
         g_is_sub_reservable(l_hash_value).subinventory_code = l_mmtt_rec.transfer_subinventory
      THEN
         l_reservable_type := g_is_sub_reservable(l_hash_value).reservable_type;
      ELSE
         SELECT reservable_type
           INTO l_reservable_type
           FROM mtl_secondary_inventories
          WHERE organization_id = l_mmtt_rec.organization_id
            AND secondary_inventory_name = l_mmtt_rec.transfer_subinventory;
         g_is_sub_reservable(l_hash_value).reservable_type := l_reservable_type;
         g_is_sub_reservable(l_hash_value).org_id := l_mmtt_rec.organization_id;
         g_is_sub_reservable(l_hash_value).subinventory_code := l_mmtt_rec.transfer_subinventory;
      END IF;

      l_mtl_reservation_tbl_count            := 0;

      IF (l_mmtt_rec.reservation_id IS NOT NULL) THEN
        l_query_reservation_rec.reservation_id  := l_mmtt_rec.reservation_id;
        IF (l_debug = 1) THEN
           DEBUG('reservation_id is  = '|| l_mmtt_rec.reservation_id, 'Finalize_Pick_confirm');
           DEBUG('about to call inv_reservation_pub.query_reservations ', 'Finalize_Pick_confirm');
        END IF;
        inv_reservation_pub.query_reservation(
          p_api_version_number         => 1.0
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_query_input                => l_query_reservation_rec
        , x_mtl_reservation_tbl        => l_mtl_reservation_tbl
        , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
        , x_error_code                 => l_error_code
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
             DEBUG('Error from query_reservations', 'Finalize_Pick_Confirm');
          END IF;
          RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
             DEBUG('Error from query_reservations', 'Finalize_Pick_Confirm');
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF (l_debug = 1) THEN
           DEBUG('reservation count = '|| l_mtl_reservation_tbl.COUNT, 'Finalize_Pick_Confirm');
           DEBUG('after query_reservation', 'Finalize_Pick_Confirm');
        END IF;
      END IF;

      l_lpn_id := NVL(l_mmtt_rec.content_lpn_id, l_mmtt_rec.transfer_lpn_id);

      IF l_mtl_reservation_tbl_count > 0 THEN
        l_mtl_reservation_rec  := l_mtl_reservation_tbl(1);
        IF (l_debug = 1) THEN
           DEBUG('Reservation exist total #'|| l_mtl_reservation_tbl_count, 'Finalize_Pick_Confirm');
           DEBUG('lot number in the original reservation is '|| l_mtl_reservation_rec.lot_number, 'Finalize_Pick_Confirm');
        END IF;

        -- To support overpicking, we have to increase the reservation
        -- quantity when the user enters a transaction quantity which
        -- is greater than the requested quantity.
        -- We increase the reservation before transferring it to the
        -- staging subinventory.

        IF l_rsv_primary_quantity > l_mtl_reservation_rec.primary_reservation_quantity THEN
          IF (l_debug = 1) THEN
             DEBUG('Increasing reservation quantity for overpicking', 'Finalize_Pick_Confirm');
             DEBUG('Old rsv prim. quantity: '|| l_mtl_reservation_rec.primary_reservation_quantity, 'Finalize_Pick_Confirm');
             DEBUG('New rsv prim. quantity: '|| l_rsv_primary_quantity, 'Finalize_Pick_Confirm');
          END IF;
          l_mtl_reservation_rec.primary_reservation_quantity     := l_rsv_primary_quantity;
          l_mtl_reservation_rec.detailed_quantity                := l_rsv_primary_quantity;
          l_mtl_reservation_rec.secondary_reservation_quantity   := l_sec_rsv_quantity;
          l_mtl_reservation_rec.secondary_detailed_quantity      := l_sec_rsv_quantity;
          l_mtl_reservation_rec.reservation_quantity             := NULL;
          IF (  l_mtl_reservation_rec.secondary_uom_code IS NULL ) THEN
              l_mtl_reservation_rec.secondary_reservation_quantity := NULL;
              l_mtl_reservation_rec.secondary_detailed_quantity    := NULL;
          END IF;
          inv_reservation_pub.update_reservation(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
          , p_to_rsv_rec                 => l_mtl_reservation_rec
          , p_original_serial_number     => l_original_serial_number
          , p_to_serial_number           => l_to_serial_number
          , p_validation_flag            => fnd_api.g_true -- Explicitly set the validation flag to true with respect to the Bug 4004597
          , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
          );
          IF (l_debug = 1) THEN
             DEBUG('after update reservation return status is '|| l_return_status, 'Finalize_Pick_Confirm');
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          --requery reservation to reflect updated data
          inv_reservation_pub.query_reservation(
            p_api_version_number         => 1.0
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , p_query_input                => l_query_reservation_rec
          , x_mtl_reservation_tbl        => l_mtl_reservation_tbl
          , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
          , x_error_code                 => l_error_code
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
               DEBUG('Error from query_reservations', 'Finalize_Pick_Confirm');
            END IF;
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
               DEBUG('Error from query_reservations', 'Finalize_Pick_Confirm');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

        -- Create a new reservation on a staging sub
        -- for the transaction_quantity;
        -- initialize l_mtl_reservation_rec with the record transacted.
        -- change the the value of changed attributes
        -- in l_mtl_reservation_rec
        IF (l_debug = 1) THEN
           DEBUG('l_mmtt_rec.transaction_temp_id is '|| l_mmtt_rec.transaction_temp_id, 'Finalize_Pick_confirm');
        END IF;

        SELECT COUNT(*) INTO l_lot_count
          FROM mtl_transaction_lots_temp
         WHERE transaction_temp_id = p_transaction_temp_id;

        IF (l_debug = 1) THEN
           DEBUG('l_lot_count is '|| l_lot_count, 'Finalize_Pick_Confirm');
        END IF;

        IF (l_reservable_type = 2) THEN
          IF (l_debug = 1) THEN
             DEBUG('not reservable staging subinventory, '|| 'delete org wide reservation', 'Finalize_Pick_Confirm');
          END IF;
          l_mtl_reservation_rec                       := l_mtl_reservation_tbl(1);
          -- reservation quantity should be NULL; it will be
          -- determined based on primary quantity
          l_mtl_reservation_rec.reservation_quantity  := NULL;

          IF NVL(l_mtl_reservation_rec.primary_reservation_quantity, 0) > ABS(l_mmtt_rec.primary_quantity) THEN
            l_mtl_reservation_rec.primary_reservation_quantity
                             := NVL(l_mtl_reservation_rec.primary_reservation_quantity, 0)
                                      - ABS(l_mmtt_rec.primary_quantity);
            l_mtl_reservation_rec.secondary_reservation_quantity
                             := NVL(l_mtl_reservation_rec.secondary_reservation_quantity, 0)
                                      - ABS(l_mmtt_rec.secondary_transaction_quantity);
          ELSE -- if qty > rsv qty, delete reservation
            l_mtl_reservation_rec.primary_reservation_quantity  := 0;
            l_mtl_reservation_rec.secondary_reservation_quantity  := 0;
          END IF;

          --need to decrement from detailed quantity
          IF NVL(l_mtl_reservation_rec.detailed_quantity, 0) > ABS(l_mmtt_rec.primary_quantity) THEN
            l_mtl_reservation_rec.detailed_quantity
                             := NVL(l_mtl_reservation_rec.detailed_quantity, 0)
                                      - ABS(l_mmtt_rec.primary_quantity);
            l_mtl_reservation_rec.secondary_detailed_quantity
                             := NVL(l_mtl_reservation_rec.secondary_detailed_quantity, 0)
                                      - ABS(l_mmtt_rec.secondary_transaction_quantity);
          ELSE
            l_mtl_reservation_rec.detailed_quantity  := 0;
            l_mtl_reservation_rec.secondary_detailed_quantity  := 0;
          END IF;

          IF (l_debug = 1) THEN
             DEBUG('primary reservation quantity is '|| l_mtl_reservation_rec.primary_reservation_quantity, 'Finalize_Pick_Confirm');
          END IF;
          IF (  l_mtl_reservation_rec.secondary_uom_code IS NULL ) THEN
              l_mtl_reservation_rec.secondary_reservation_quantity := NULL;
              l_mtl_reservation_rec.secondary_detailed_quantity    := NULL;
          END IF;
          inv_reservation_pub.update_reservation(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
          , p_to_rsv_rec                 => l_mtl_reservation_rec
          , p_original_serial_number     => l_original_serial_number
          , p_to_serial_number           => l_to_serial_number
          , p_validation_flag            => fnd_api.g_true
          , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
          );
          IF (l_debug = 1) THEN
             DEBUG('after update reservation return status is '|| l_return_status, 'Finalize_Pick_Confirm');
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE   -- reservable type <> 2
          IF (l_debug = 1) THEN
             DEBUG('reservable staging subinventory, '|| 'transfer reservation to staging', 'Finalize_Pick_Confirm');
          END IF;

          IF (l_lot_count > 0) THEN
             IF (l_debug = 1) THEN
                 DEBUG('Lot records exist l_lot_count '|| l_lot_count, 'Finalize_Pick_Confirm');
             END IF;
            l_transaction_temp_id         := l_mmtt_rec.transaction_temp_id;
            l_lot_shipping_quantity       := 0;
            l_lot_prim_shipping_quantity  := 0;
            OPEN lot_csr(p_transaction_temp_id);

            LOOP
              FETCH lot_csr
              INTO l_lot_number
                 , l_lot_primary_quantity
                 , l_lot_transaction_quantity
                 , l_lot_secondary_quantity
                 , l_lot_secondary_uom
                 , l_serial_trx_temp_id
                 , l_grade_code;
              l_lot_shipping_quantity       := l_lot_shipping_quantity + l_lot_transaction_quantity;
              l_sec_lot_shipping_quantity   := l_sec_lot_shipping_quantity + l_lot_secondary_quantity;
              l_lot_prim_shipping_quantity  := l_lot_prim_shipping_quantity + l_lot_primary_quantity;
              IF l_lot_shipping_quantity > l_shipping_quantity THEN
                l_lot_transaction_quantity  := l_lot_transaction_quantity
                                               - (l_lot_shipping_quantity - l_shipping_quantity);
                l_lot_primary_quantity      := l_lot_primary_quantity
                                               - (l_lot_prim_shipping_quantity - l_primary_shipping_quantity);
                l_lot_secondary_quantity  := l_lot_secondary_quantity
                                               - (l_sec_lot_shipping_quantity - l_sec_shipping_quantity);
              END IF;
              EXIT WHEN lot_csr%NOTFOUND
                     OR l_lot_transaction_quantity <= 0;
              IF (l_debug = 1) THEN
                 DEBUG('lot number is '|| l_mtl_reservation_rec.lot_number, 'Finalize_Pick_Confirm');
              END IF;
              l_mtl_reservation_rec.reservation_id                := NULL;

              -- bug 3703983
              --l_mtl_reservation_rec.requirement_date              := SYSDATE;
              l_mtl_reservation_rec.primary_reservation_quantity  := ABS(l_lot_primary_quantity);
              l_mtl_reservation_rec.reservation_quantity          := ABS(l_lot_transaction_quantity);
              l_mtl_reservation_rec.reservation_uom_code          := l_mmtt_rec.transaction_uom;
              l_mtl_reservation_rec.subinventory_code             := l_mmtt_rec.transfer_subinventory;
              l_mtl_reservation_rec.detailed_quantity             := 0;
              l_mtl_reservation_rec.secondary_reservation_quantity  := ABS(l_lot_secondary_quantity);
              l_mtl_reservation_rec.secondary_uom_code            := l_mmtt_rec.secondary_uom_code;
              l_mtl_reservation_rec.secondary_detailed_quantity   := 0;
              l_mtl_reservation_rec.locator_id                    := l_mmtt_rec.transfer_to_location;
              l_mtl_reservation_rec.ship_ready_flag               := 1;
              l_mtl_reservation_rec.lot_number                    := l_lot_number;
              l_mtl_reservation_rec.revision                      := l_mmtt_rec.revision;

              -- bug 3703983
              l_mtl_reservation_rec.staged_flag                   := 'Y';

              --don't reserve LPN in staging sub unless LPN was
              -- reserved on original reservation
              IF l_mtl_reservation_tbl(1).lpn_id IS NOT NULL THEN
                l_mtl_reservation_rec.lpn_id  := l_lpn_id;
              END IF;

              IF (l_debug = 1) THEN
                 DEBUG('Transfering reservations', 'Finalize_Pick_Confirm');
              end if;
              inv_reservation_pub.transfer_reservation(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
              , p_to_rsv_rec                 => l_mtl_reservation_rec
              , p_original_serial_number     => l_to_serial_number
              , p_to_serial_number           => l_to_serial_number
              , p_validation_flag            => fnd_api.g_false
              , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
              , x_to_reservation_id          => l_reservation_id
              );
              IF (l_debug = 1) THEN
                 DEBUG('new reservation id is '|| l_reservation_id, 'Finalize_Pick_Confirm');
                 DEBUG('after create new  reservation', 'Finalize_Pick_Confirm');
                 DEBUG('l_return_status is '|| l_return_status, 'Finalize_Pick_Confirm');
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('return from transfer_reservation with error E', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('return from transfer_reservation with error U', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              -- bug 3703983
              -- inv_staged_reservation_util.update_staged_flag(x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data, p_reservation_id => l_reservation_id, p_staged_flag => 'Y');

              --IF l_return_status = fnd_api.g_ret_sts_error THEN
              -- (l_debug = 1) THEN
              --    DEBUG('Error in update_staged_flag', 'Finalize_Pick_Confirm');
              -- END IF;
              -- RAISE fnd_api.g_exc_error;
              --ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              -- IF (l_debug = 1) THEN
              --    DEBUG('Unexpected error in update_staged_flag', 'Finalize_Pick_Confirm');
              -- END IF;
              -- RAISE fnd_api.g_exc_unexpected_error;
              --END IF;
            END LOOP;

            IF (l_debug = 1) THEN
               DEBUG('after end loop', 'Finalize_Pick_Confirm');
            END IF;
            CLOSE lot_csr;
          ELSE
            IF (l_debug = 1) THEN
               DEBUG('no lot records', 'Finalize_Pick_Confirm');
            END IF;
            l_mtl_reservation_rec.reservation_id                := NULL;
            l_mtl_reservation_rec.primary_reservation_quantity  := l_primary_shipping_quantity;
            l_mtl_reservation_rec.reservation_quantity          := l_shipping_quantity;
            l_mtl_reservation_rec.reservation_uom_code          := l_mmtt_rec.transaction_uom;
            l_mtl_reservation_rec.secondary_reservation_quantity  := l_sec_shipping_quantity;
            l_mtl_reservation_rec.secondary_uom_code            := l_mmtt_rec.secondary_uom_code;
            l_mtl_reservation_rec.subinventory_code             := l_mmtt_rec.transfer_subinventory;
            l_mtl_reservation_rec.detailed_quantity             := NULL;
            l_mtl_reservation_rec.secondary_detailed_quantity   := NULL;
            l_mtl_reservation_rec.locator_id                    := l_mmtt_rec.transfer_to_location;
            l_mtl_reservation_rec.ship_ready_flag               := 1;
            l_mtl_reservation_rec.revision                      := l_mmtt_rec.revision;
            l_mtl_reservation_rec.staged_flag                   := 'Y';

            --don't reserve LPN in staging sub unless LPN was
            -- reserved on original reservation
            IF l_mtl_reservation_tbl(1).lpn_id IS NOT NULL THEN
              l_mtl_reservation_rec.lpn_id  := l_lpn_id;
            END IF;

            IF (l_debug = 1) THEN
               DEBUG('Transfering reservation ', 'Finalize_Pick_Confirm');
               DEBUG('l_primary_shipping_quantity: '|| l_primary_shipping_quantity, 'Finalize_Pick_Confirm');
            END IF;
            inv_reservation_pub.transfer_reservation(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
            , p_to_rsv_rec                 => l_mtl_reservation_rec
            , p_original_serial_number     => l_to_serial_number
            , p_to_serial_number           => l_to_serial_number
            , p_validation_flag            => fnd_api.g_false
            , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
            , x_to_reservation_id          => l_reservation_id
            );
            IF (l_debug = 1) THEN
               DEBUG('new reservation id is '|| l_reservation_id, 'Finalize_Pick_Confirm');
               DEBUG('after create new reservation', 'Finalize_Pick_Confirm');
               DEBUG('l_return_status is '|| l_return_status, 'Finalize_Pick_Confirm');
            END IF;
            IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                 DEBUG('return from transfer_reservation with error E', 'Finalize_Pick_Confirm');
              END IF;
              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                 DEBUG('return from transfer_reservation with error U', 'Finalize_Pick_Confirm');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            IF (l_debug = 1) THEN
               DEBUG('still inside if no lot records', 'Finalize_Pick_Confirm');
            END IF;
          END IF; -- lot or not lot control
        END IF; -- reservable or not
      ELSE -- query reservation returns 0 records
        DEBUG('NO reservations exist for this line', 'Finalize_Pick_Confirm');
        -- Reservation does not exist, we need to create one if the
        -- staging sub is reservable and item is reservable
        -- check the function to see if sub/locator is reservable, lot is later
        IF  l_reservable_type = 1 AND l_reservable_type_item = 1 THEN
          -- If the staging subinventory  is reservable
          l_mtl_reservation_rec.reservation_id             := NULL; -- cannot know
          l_mtl_reservation_rec.organization_id            := l_mmtt_rec.organization_id;
          l_mtl_reservation_rec.inventory_item_id          := l_mmtt_rec.inventory_item_id;
          --l_mtl_reservation_rec.demand_source_type_id      := l_mmtt_rec.transaction_source_type_id;
          l_mtl_reservation_rec.demand_source_type_id      := 5 ; --l_mmtt_rec.transaction_source_type_id;
          l_mtl_reservation_rec.demand_source_name         := NULL;
          l_mtl_reservation_rec.demand_source_header_id    := l_mmtt_rec.transaction_source_id;
          l_mtl_reservation_rec.demand_source_line_id      := TO_NUMBER(l_mmtt_rec.trx_source_line_id);
          l_mtl_reservation_rec.demand_source_delivery     := NULL;
          l_mtl_reservation_rec.primary_uom_code           := l_mmtt_rec.item_primary_uom_code;
          l_mtl_reservation_rec.secondary_uom_code         := l_mmtt_rec.secondary_uom_code;
          l_mtl_reservation_rec.primary_uom_id             := NULL;
          l_mtl_reservation_rec.secondary_uom_id           := NULL;
          l_mtl_reservation_rec.reservation_uom_code       := l_mmtt_rec.transaction_uom;
          l_mtl_reservation_rec.reservation_uom_id         := NULL;
          l_mtl_reservation_rec.autodetail_group_id        := NULL;
          l_mtl_reservation_rec.external_source_code       := NULL;
          l_mtl_reservation_rec.external_source_line_id    := NULL;
          l_mtl_reservation_rec.supply_source_type_id      := inv_reservation_global.g_source_type_inv;
          l_mtl_reservation_rec.supply_source_header_id    := NULL;
          l_mtl_reservation_rec.supply_source_line_id      := NULL;
          l_mtl_reservation_rec.supply_source_name         := NULL;
          l_mtl_reservation_rec.supply_source_line_detail  := NULL;
          l_mtl_reservation_rec.revision                   := l_mmtt_rec.revision;
          l_mtl_reservation_rec.subinventory_code          := l_mmtt_rec.transfer_subinventory;
          l_mtl_reservation_rec.subinventory_id            := NULL;
          l_mtl_reservation_rec.locator_id                 := l_mmtt_rec.transfer_to_location;
          l_mtl_reservation_rec.lot_number_id              := NULL;
          l_mtl_reservation_rec.pick_slip_number           := NULL;
          --we reserve LPN only on user created reservations
          l_mtl_reservation_rec.lpn_id                     := NULL;
          l_mtl_reservation_rec.attribute_category         := NULL;
          l_mtl_reservation_rec.attribute1                 := NULL;
          l_mtl_reservation_rec.attribute2                 := NULL;
          l_mtl_reservation_rec.attribute3                 := NULL;
          l_mtl_reservation_rec.attribute4                 := NULL;
          l_mtl_reservation_rec.attribute5                 := NULL;
          l_mtl_reservation_rec.attribute6                 := NULL;
          l_mtl_reservation_rec.attribute7                 := NULL;
          l_mtl_reservation_rec.attribute8                 := NULL;
          l_mtl_reservation_rec.attribute9                 := NULL;
          l_mtl_reservation_rec.attribute10                := NULL;
          l_mtl_reservation_rec.attribute11                := NULL;
          l_mtl_reservation_rec.attribute12                := NULL;
          l_mtl_reservation_rec.attribute13                := NULL;
          l_mtl_reservation_rec.attribute14                := NULL;
          l_mtl_reservation_rec.attribute15                := NULL;
          l_mtl_reservation_rec.ship_ready_flag            := 1;
          l_mtl_reservation_rec.detailed_quantity          := 0;
          l_mtl_reservation_rec.secondary_detailed_quantity := 0;

          IF (l_debug = 1) THEN
             DEBUG('Dest sub '|| l_mtl_reservation_rec.subinventory_code, 'Finalize_Pick_Confirm');
             DEBUG('Dest locator '|| l_mtl_reservation_rec.locator_id, 'Finalize_Pick_Confirm');
          END IF;
          IF l_lot_control_code = 2 THEN
            --Lot control
            l_transaction_temp_id         := l_mmtt_rec.transaction_temp_id;
            l_lot_shipping_quantity       := 0;
            l_lot_prim_shipping_quantity  := 0;
            OPEN lot_csr(p_transaction_temp_id);

            LOOP
              FETCH lot_csr
              INTO l_lot_number
                 , l_lot_primary_quantity
                 , l_lot_transaction_quantity
                 , l_lot_secondary_quantity
                 , l_lot_secondary_uom
                 , l_serial_trx_temp_id
                 , l_grade_code;
              l_lot_shipping_quantity           := l_lot_shipping_quantity + l_lot_transaction_quantity;
              l_sec_lot_shipping_quantity       := l_sec_lot_shipping_quantity + l_lot_secondary_quantity;
              l_lot_prim_shipping_quantity      := l_lot_prim_shipping_quantity + l_lot_primary_quantity;

              IF l_lot_shipping_quantity > l_shipping_quantity THEN
                l_lot_transaction_quantity  := l_lot_transaction_quantity - (l_lot_shipping_quantity - l_shipping_quantity);
                l_lot_secondary_quantity    := l_lot_secondary_quantity - (l_sec_lot_shipping_quantity - l_sec_shipping_quantity);
                l_lot_primary_quantity      := l_lot_primary_quantity - (l_lot_prim_shipping_quantity - l_primary_shipping_quantity);
              END IF;

              EXIT WHEN lot_csr%NOTFOUND
                     OR l_lot_transaction_quantity <= 0;
              l_mtl_reservation_rec.lot_number  := l_lot_number;
              -- query to see whether a record with the key
              -- attributes already exists
              -- if there is, use update instead of create
              inv_reservation_pub.query_reservation(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_query_input                => l_mtl_reservation_rec
              , p_lock_records               => fnd_api.g_true
              , x_mtl_reservation_tbl        => l_mtl_reservation_tbl
              , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
              , x_error_code                 => l_error_code
              );

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
              IF (l_debug = 1) THEN
                 DEBUG('Query reservation get count '|| l_mtl_reservation_tbl_count, 'Finalize_Pick_Confirm');
              END IF;

              IF l_mtl_reservation_tbl_count > 0 THEN
                l_mtl_reservation_rec.primary_reservation_quantity  := l_mtl_reservation_tbl(1).primary_reservation_quantity + ABS(l_lot_primary_quantity);
                l_mtl_reservation_rec.reservation_quantity          := l_mtl_reservation_tbl(1).reservation_quantity + ABS(l_lot_transaction_quantity);
                l_mtl_reservation_rec.secondary_reservation_quantity
                       := l_mtl_reservation_tbl(1).secondary_reservation_quantity + ABS(l_lot_secondary_quantity);
                l_mtl_reservation_rec.requirement_date              := SYSDATE;
                IF (  l_mtl_reservation_rec.secondary_uom_code IS NULL ) THEN
                    l_mtl_reservation_rec.secondary_reservation_quantity := NULL;
                    l_mtl_reservation_rec.secondary_detailed_quantity    := NULL;
                END IF;
                IF (l_debug = 1) THEN
                    DEBUG('Update reservation id '|| l_mtl_reservation_rec.reservation_id, 'Finalize_Pick_Confirm');
                END IF;
                inv_reservation_pub.update_reservation(
                  p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
                , x_return_status              => l_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
                , p_to_rsv_rec                 => l_mtl_reservation_rec
                , p_original_serial_number     => l_original_serial_number
                , p_to_serial_number           => l_to_serial_number
                , p_validation_flag            => fnd_api.g_true
                , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
                );
                IF (l_debug = 1) THEN
                   DEBUG('after update reservation return status is '|| l_return_status, 'Finalize_Pick_Confirm');
                END IF;

                IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;
              ELSE
               -- check to see the lot is reservable...
               -- Bug 8560030
               BEGIN
                SELECT reservable_type
                 INTO l_reservable_type_lot
                 FROM mtl_lot_numbers
                WHERE inventory_item_id = l_mtl_reservation_rec.inventory_item_id
                  AND organization_id = l_mtl_reservation_rec.organization_id
                  AND lot_number = l_mtl_reservation_rec.lot_number;
               EXCEPTION
                WHEN OTHERS THEN
                  l_reservable_type_lot := 1;
               END;

               IF (l_reservable_type_lot <> 1) THEN
                  IF (l_debug = 1) THEN
                    DEBUG('Lot is not reservable, skip creating Staging Rreservations', 'Finalize_Pick_Confirm');
                  END IF;
               END IF;

               IF (l_reservable_type_lot = 1) THEN
                --Bug 8560030, lot is reservable create reservation
                l_mtl_reservation_rec.primary_reservation_quantity  := ABS(l_lot_primary_quantity);
                l_mtl_reservation_rec.reservation_quantity          := ABS(l_lot_transaction_quantity);
                l_mtl_reservation_rec.secondary_reservation_quantity := ABS(l_lot_secondary_quantity);
                l_mtl_reservation_rec.requirement_date              := SYSDATE;
                inv_reservation_pub.create_reservation(
                  p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
                , x_return_status              => l_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_rsv_rec                    => l_mtl_reservation_rec
                , p_serial_number              => l_to_serial_number
                , x_serial_number              => l_to_serial_number
                , p_partial_reservation_flag   => fnd_api.g_true
                , p_force_reservation_flag     => fnd_api.g_false
                , p_validation_flag            => fnd_api.g_true
                , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
                , x_quantity_reserved          => l_quantity_reserved
                , x_reservation_id             => l_reservation_id
                );
                IF (l_debug = 1) THEN
                   DEBUG('Create reservation ', 'Finalize_Pick_Confirm');
                   DEBUG('Quantity reserved: '|| l_quantity_reserved, 'Finalize_Pick_Confirm');
                   DEBUG('Reservation ID: '|| l_reservation_id, 'Finalize_Pick_Confirm');
                END IF;

                IF l_return_status = fnd_api.g_ret_sts_error THEN
                  IF (l_debug = 1) THEN
                     DEBUG('Error in creating reservation for lot', 'Finalize_Pick_Confirm');
                  END IF;
                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                     DEBUG('Unexpected error in creating reservation for lot', 'Finalize_Pick_Confirm');
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                --bug 1402436 - set the reservations staged flag
                inv_staged_reservation_util.update_staged_flag(x_return_status => l_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data, p_reservation_id => l_reservation_id, p_staged_flag => 'Y');

                IF l_return_status = fnd_api.g_ret_sts_error THEN
                  IF (l_debug = 1) THEN
                     DEBUG('Error in update_staged_flag', 'Finalize_Pick_Confirm');
                  END IF;
                  RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                     DEBUG('Unexpected error in update_staged_flag', 'Finalize_Pick_Confirm');
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;
               END IF; -- l_reservable_type_lot = 1
              END IF; -- Create or Update
            END LOOP; -- Lot loop

            IF (l_debug = 1) THEN
               DEBUG('after end of lot loop...', 'Finalize_Pick_Confirm');
            END IF;
            CLOSE lot_csr;
          ELSE
            --No Lot control
            IF (l_debug = 1) THEN
               DEBUG('No lot control', 'Finalize_Pick_Confirm');
            END IF;
            l_mtl_reservation_rec.lot_number  := NULL;
            -- query to see whether a record with the key
            -- attributes already exists
            -- if there is, use update instead of create
            inv_reservation_pub.query_reservation(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_query_input                => l_mtl_reservation_rec
            , p_lock_records               => fnd_api.g_true
            , x_mtl_reservation_tbl        => l_mtl_reservation_tbl
            , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
            , x_error_code                 => l_error_code
            );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF l_mtl_reservation_tbl_count > 0 THEN
              l_mtl_reservation_rec.primary_reservation_quantity  := l_mtl_reservation_tbl(1).primary_reservation_quantity + l_primary_shipping_quantity;
              l_mtl_reservation_rec.reservation_quantity          := l_mtl_reservation_tbl(1).reservation_quantity + l_shipping_quantity;
              l_mtl_reservation_rec.secondary_reservation_quantity
                                := l_mtl_reservation_tbl(1).secondary_reservation_quantity + l_sec_shipping_quantity;
              l_mtl_reservation_rec.requirement_date              := SYSDATE;
              IF (  l_mtl_reservation_rec.secondary_uom_code IS NULL ) THEN
                 l_mtl_reservation_rec.secondary_reservation_quantity := NULL;
                 l_mtl_reservation_rec.secondary_detailed_quantity    := NULL;
              END IF;
              inv_reservation_pub.update_reservation(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
              , p_to_rsv_rec                 => l_mtl_reservation_rec
              , p_original_serial_number     => l_original_serial_number
              , p_to_serial_number           => l_to_serial_number
              , p_validation_flag            => fnd_api.g_true
              , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
              );
              IF (l_debug = 1) THEN
                 DEBUG('after update reservation return status is '|| l_return_status, 'Finalize_Pick_Confirm');
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            ELSE
              l_mtl_reservation_rec.primary_reservation_quantity  := l_primary_shipping_quantity;
              l_mtl_reservation_rec.reservation_quantity          := l_shipping_quantity;
              l_mtl_reservation_rec.secondary_reservation_quantity  := l_sec_shipping_quantity;
              l_mtl_reservation_rec.requirement_date              := SYSDATE;
              IF (l_debug = 1) THEN
                 DEBUG('create reservation demand source'|| l_mtl_reservation_rec.demand_source_type_id, 'Finalize_Pick_Confirm');
              END IF;
              inv_reservation_pub.create_reservation(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_rsv_rec                    => l_mtl_reservation_rec
              , p_serial_number              => l_to_serial_number
              , x_serial_number              => l_to_serial_number
              , p_partial_reservation_flag   => fnd_api.g_true
              , p_force_reservation_flag     => fnd_api.g_false
              , p_validation_flag            => fnd_api.g_true
              , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
              , x_quantity_reserved          => l_quantity_reserved
              , x_reservation_id             => l_reservation_id
              );
              IF (l_debug = 1) THEN
                 DEBUG('Quantity reserved: '|| l_quantity_reserved, 'Finalize_Pick_Confirm');
                 DEBUG('Reservation ID: '|| l_reservation_id, 'Finalize_Pick_Confirm');
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('Error in creating reservation for lot', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('Unexpected error in creating reservation for lot', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              --bug 1402436 - set the reservations staged flag
              inv_staged_reservation_util.update_staged_flag
                    (x_return_status        => l_return_status
                    , x_msg_count           => x_msg_count
                    , x_msg_data            => x_msg_data
                    , p_reservation_id      => l_reservation_id
                    , p_staged_flag         => 'Y'
                    );

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('Error in update_staged_flag', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('Unexpected error in update_staged_flag', 'Finalize_Pick_Confirm');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            END IF; -- Create or Update
          END IF; -- Lot control or not
        END IF; -- Staging sub reservable or not
      END IF; -- if reservation exists

      IF (l_debug = 1) THEN
         DEBUG('interact with GME if neccesary', 'Finalize_Pick_Confirm');
      END IF;

      IF l_trolin_rec.line_status = 5 THEN
        -- If this is the last allocation line for the last move order
        -- line for the sales order then delete all the unstaged
        -- reservations for this record. This will also delete
        -- reservations which are against the backordered lines.

        --clean_reservations(p_source_line_id => l_trolin_rec.txn_source_line_id, x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data);

        --IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        --  IF (l_debug = 1) THEN
        --     DEBUG('return error from clean reservations', 'Finalize_Pick_Confirm');
        --  END IF;
        --  RAISE fnd_api.g_exc_error;
        --ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        --  IF (l_debug = 1) THEN
        --     DEBUG('return unexpected error from clean reservations', 'Finalize_Pick_Confirm');
        --  END IF;
        --  RAISE fnd_api.g_exc_unexpected_error;
        --END IF;

        -- Fix the detailed quantity on all reservations for this
        --  sales order line. Necessary for underpicking.
        IF (l_debug = 1) THEN
           DEBUG('Cleaning up reservations', 'Finalize_Pick_Confirm');
        END IF;

        OPEN reservations_csr;
        LOOP
          FETCH reservations_csr INTO l_reservation_id, l_rsv_primary_quantity, l_rsv_detailed_quantity;
          EXIT WHEN reservations_csr%NOTFOUND;
          IF (l_debug = 1) THEN
             DEBUG('Found first reservation: '|| l_reservation_id, 'Finalize_Pick_Confirm');
          END IF;

          --for each reservation, check to see what the actual
          --allocated quantity is
          SELECT NVL(SUM(ABS(primary_quantity)), 0)
              ,  NVL(SUM(ABS(secondary_transaction_quantity)), 0)
            INTO l_mmtt_rsv_quantity
              ,  l_sec_mmtt_rsv_quantity
            FROM mtl_material_transactions_temp
           WHERE reservation_id = l_reservation_id;

          -- L.G. Logic might need to be put here is reservations are not used but
          -- user manually allocated the line, which the mmtt still may have the reservation_id as null
          -- but the reservations still need to be updated.

          -- need to subtract from the mmtt rsv quantity the
          --  quantity of the reservations that have already been
          --  picked, since the rsv's detailed quantity does not
          --  include this quantity
          IF g_rsv_picked_quantity_tbl.EXISTS(l_reservation_id) THEN
            l_mmtt_rsv_quantity  := l_mmtt_rsv_quantity - g_rsv_picked_quantity_tbl(l_reservation_id).picked_quantity;
	    l_sec_mmtt_rsv_quantity  := l_sec_mmtt_rsv_quantity - g_rsv_picked_quantity_tbl(l_reservation_id).sec_picked_quantity;--Added for bug 8926143
          END IF;

          -- Update reservation if necessary
          IF l_mmtt_rsv_quantity < l_rsv_detailed_quantity THEN
            --call update reservation
            l_mtl_reservation_rec2.reservation_id     := l_reservation_id;
            l_mtl_reservation_rec3.reservation_id     := l_reservation_id;
            l_mtl_reservation_rec3.detailed_quantity  := l_mmtt_rsv_quantity;
            l_mtl_reservation_rec3.secondary_detailed_quantity  := l_sec_mmtt_rsv_quantity;
            IF (l_debug = 1) THEN
               DEBUG('reservation id is '|| l_mtl_reservation_rec2.reservation_id, 'Finalize_Pick_Confirm');
               DEBUG('primary_reservation quantity is '|| l_mtl_reservation_rec3.primary_reservation_quantity, 'Finalize_Pick_Confirm');
               DEBUG('detailed quantity is '|| l_mtl_reservation_rec3.detailed_quantity, 'Finalize_Pick_Confirm');
	       DEBUG('secondary detailed quantity is '|| l_mtl_reservation_rec3.secondary_detailed_quantity, 'Finalize_Pick_Confirm');
            END IF;
            IF (  l_mtl_reservation_rec.secondary_uom_code IS NULL ) THEN
              l_mtl_reservation_rec.secondary_reservation_quantity := NULL;
              l_mtl_reservation_rec.secondary_detailed_quantity    := NULL;
            END IF;
            inv_reservation_pub.update_reservation(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_original_rsv_rec           => l_mtl_reservation_rec2
            , p_to_rsv_rec                 => l_mtl_reservation_rec3
            , p_original_serial_number     => l_original_serial_number
            , p_to_serial_number           => l_to_serial_number
            , p_validation_flag            => fnd_api.g_true
            , p_over_reservation_flag      => 3  -- Bug 4997704, Passing p_over_reservation_flag to reservation API to handle overpicking scenarios
            );
            IF (l_debug = 1) THEN
               DEBUG('after update reservation return status is '|| l_return_status, 'Finalize_Pick_Confirm');
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF; -- if allocated quantity < detailed rsv quantity
        END LOOP;
        IF reservations_csr%ISOPEN THEN
          CLOSE reservations_csr;
        END IF;
      END IF; -- line status = 5
    End if;   -- if move order type = 5 and wip entity type is GME

    IF (l_debug = 1) THEN
       DEBUG('before return', 'Finalize_Pick_Confirm');
    END IF;
    x_return_status                     := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Pick Confirm');
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END finalize_pick_confirm;

  -- Bug 2640757: Fill Kill Enhancement
  PROCEDURE kill_move_order(
      x_return_status         OUT NOCOPY VARCHAR2
    , x_msg_count             OUT NOCOPY NUMBER
    , x_msg_data              OUT NOCOPY VARCHAR2
    , p_transaction_header_id     NUMBER) IS

     -- Bug 5059984, Adding cursor c_rep_mo_mmtt.

     CURSOR c_rep_mo_mmtt IS
 	       SELECT DISTINCT move_order_line_id
 	         FROM mtl_material_transactions_temp a
 	         WHERE transaction_header_id = p_transaction_header_id
 	         AND transaction_source_type_id = 4
 	         AND transaction_action_id = 2
 	         AND move_order_line_id IS NOT NULL
 	         AND nvl(transaction_status, 1) <> 2
 	         AND process_flag = 'Y'
 	         AND NOT EXISTS ( SELECT 1
 	                          FROM mtl_material_transactions_temp b
 	                          WHERE b.move_order_line_id = a.move_order_line_id
 	                          AND (nvl(transaction_status,1) = 2 OR error_code IS NOT NULL));

     CURSOR c_mo_lines IS
        SELECT DISTINCT move_order_line_id
          FROM mtl_material_transactions_temp a
         WHERE transaction_header_id = p_transaction_header_id
           AND move_order_line_id IS NOT NULL
           AND nvl(transaction_status,1) <> 2
           AND process_flag = 'Y'
           AND NOT EXISTS ( SELECT 1
                              FROM mtl_material_transactions_temp b
                             WHERE b.move_order_line_id = a.move_order_line_id
                               AND (nvl(transaction_status,1) = 2 OR error_code IS NOT NULL));

     CURSOR c_mo_type (p_mo_line_id NUMBER) IS
        SELECT mtrh.move_order_type
          FROM mtl_txn_request_headers mtrh
             , mtl_txn_request_lines mtrl
         WHERE mtrl.line_id = p_mo_line_id
           AND mtrh.header_id = mtrl.header_id;

     l_mo_type NUMBER;
     l_return_status VARCHAR2(1) ;
     l_msg_data VARCHAR2(240);
     l_msg_count NUMBER;
     l_debug number;
     l_kill_mo_profile NUMBER := NVL(FND_PROFILE.VALUE_WNPS('INV_KILL_MOVE_ORDER'),2);
     l_trolin_rec inv_move_order_pub.trolin_rec_type; -- Bug 5059984
  BEGIN
     x_return_status  := FND_API.G_RET_STS_SUCCESS;

     -- Use cache to get value for l_debug
     IF g_is_pickrelease_set IS NULL THEN
        g_is_pickrelease_set := 2;
        IF INV_CACHE.is_pickrelease THEN
           g_is_pickrelease_set := 1;
        END IF;
     END IF;
     IF (g_is_pickrelease_set <> 1) OR (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;

     l_debug := g_debug;

     IF (l_debug = 1) THEN
        DEBUG('Fill Kill Profile  = ' || l_kill_mo_profile,'INV_TRANSFER_ORDER_PVT.KILL_MOVE_ORDER');
        DEBUG('Transaction Hdr ID = ' || p_transaction_header_id,'INV_TRANSFER_ORDER_PVT.KILL_MOVE_ORDER');
     END IF;

     -- Check the Profile Fill Kill before doing anything.
     IF l_kill_mo_profile = 2 THEN
        -- Bug 5059984,  Added following code to handle replenishment move orders
        --   Replenishment move order lines with two or more allocations are not closed by
 	      --   finalize_pick_confirm. If Fill Kill profile is No, then we need to close them here.

        -- Fetch move order transfer MMTT records
 	      FOR l_rep_mmtt_rec IN  c_rep_mo_mmtt LOOP
 	        IF (l_debug = 1) THEN
 	          DEBUG('Fill Kill profile is No. MO line ID: ' || l_rep_mmtt_rec.move_order_line_id, 'Finalize_Pick_Confirm');
          END IF;
 	        OPEN c_mo_type(l_rep_mmtt_rec.move_order_line_id);
 	        FETCH c_mo_type INTO l_mo_type;
 	        IF c_mo_type%NOTFOUND THEN
 	          IF (l_debug = 1) THEN
 	            DEBUG('MO Header not found for the MO Line = ' || l_rep_mmtt_rec.move_order_line_id,'INV_TRANSFER_ORDER_PVT.KILL_MOVE_ORDER');
 	          END IF;
 	          CLOSE c_mo_type;
 	          RAISE FND_API.G_EXC_ERROR;
 	        END IF;
 	        CLOSE c_mo_type;

          IF (l_debug = 1) THEN
 	          DEBUG('Move Order Type = ' || l_mo_type,'INV_TRANSFER_ORDER_PVT.KILL_MOVE_ORDER');
 	        END IF;
 	        --If it is a replenishment move order, then check quantities and close it
 	        IF (l_mo_type = 2) THEN
 	          l_trolin_rec := inv_trolin_util.query_row(l_rep_mmtt_rec.move_order_line_id);
 	          --If the line is not closed, check quantity_delivered against quantity
 	          --If it is greater, then close the move order line

            IF l_trolin_rec.line_status NOT IN (5, 6) THEN
 	            IF (NVL(l_trolin_rec.quantity_delivered, 0) >= l_trolin_rec.quantity) THEN
 	              l_trolin_rec.line_status := 5;
 	              l_trolin_rec.status_date  := SYSDATE; -- Bug 8563083
                  IF (l_debug = 1) THEN
 	                DEBUG('Closing the replenishment move order','INV_TRANSFER_ORDER_PVT.KILL_MOVE_ORDER');
 	              END IF;
 	              inv_trolin_util.update_row(l_trolin_rec);
 	            END IF;   --END IF quantity_delivered > quantity
 	          END IF;   --END IF line_status not closed, cancelled
 	        END IF;   --END IF move_order_type = 2
 	      END LOOP;
 	   --Fill Kill profile is "Yes"
     ELSE

       -- Loop thru all the Move Order Line IDs from MMTT for the passed Transaction Header ID
       FOR l_mo_line IN c_mo_lines
       LOOP
         IF (l_debug = 1) THEN
           DEBUG('For Kill Move Order = yes, Move Order Line = ' || l_mo_line.move_order_line_id,'INV_TRANSFER_ORDER_PVT.KILL_MOVE_ORDER');
         END IF;

         -- Getting the Move Order Type.
         OPEN c_mo_type(l_mo_line.move_order_line_id);
         FETCH c_mo_type INTO l_mo_type;
         IF c_mo_type%NOTFOUND THEN
           IF (l_debug = 1) THEN
             DEBUG('MO Header not found for the MO Line = ' || l_mo_line.move_order_line_id,'INV_TRANSFER_ORDER_PVT.KILL_MOVE_ORDER');
           END IF;
           CLOSE c_mo_type;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE c_mo_type;

         IF (l_debug = 1) THEN
           DEBUG('Move Order Type = ' || l_mo_type,'INV_TRANSFER_ORDER_PVT.KILL_MOVE_ORDER');
         END IF;

         -- Proceed only if Move Order Type is Replenishment
         IF l_mo_type = 2 THEN
           IF (l_debug = 1) THEN
             DEBUG('Replenishment Move Order... Closing the Move Order','INV_TRANSFER_ORDER_PVT.KILL_MOVE_ORDER');
           END IF;
           INV_MO_ADMIN_PUB.close_line(1.0,'F','F','F',l_mo_line.move_order_line_id,l_msg_count,l_msg_data,l_return_status);

           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF; -- end if check mo_type = 2
       END LOOP;
     END IF; -- end if check fill kill profile

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        IF (l_debug = 1) THEN
           DEBUG('Expected error while closing the Line','INV_TRANSFER_ORDER_PVT.KILL_MOVE_ORDER');
        END IF;
        x_return_status  := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (l_debug = 1) THEN
           DEBUG('Unexpected error while closing the Line','INV_TRANSFER_ORDER_PVT.KILL_MOVE_ORDER');
        END IF;
        x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN OTHERS THEN
        x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_msg_pub.add_exc_msg(g_pkg_name, 'KILL_MOVE_ORDER');
        END IF;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END kill_move_order;


--As part of fix for bug 2867490, we need to create the following procedure
 --This procedure does the needful to adjust the serial numbers in MSNT
 --in case of overpicking. It could either update/delete MSNT range
 --or delete the single serial number from MSNT
 --INPUT parameters are
 --p_transaction_temp_id (if lot+serial then serial_txn_temp_id)
 --p_qty is the picked quantity corresponding to txn_temp_id



  PROCEDURE adjust_serial_numbers_in_MSNT(p_transaction_temp_id IN NUMBER,
                                              p_qty IN NUMBER) IS

    CURSOR serial_cursor IS
           SELECT a.rowid
                 ,a.FM_SERIAL_NUMBER
                 ,a.TO_SERIAL_NUMBER
                 ,b.organization_id
                 ,b.inventory_item_id
           FROM   mtl_Serial_numbers_temp a, mtl_material_transactions_temp b
           where  a.transaction_temp_id= p_transaction_temp_id
           and   a.transaction_temp_id = b.transaction_temp_id;

    l_Serial_cursor serial_cursor%ROWTYPE;
    qty_count NUMBER := 0;
    delete_remaining_serial BOOLEAN := FALSE;
    x_PREFIX              VARCHAR2(100);
    x_QUANTITY            VARCHAR2(100);
    l_FROM_NUMBER         VARCHAR2(100);
    l_TO_NUMBER           VARCHAR2(100);
    l_new_num             NUMBER;
    l_new_num_update      NUMBER;
    x_errorcode           NUMBER;
    l_new_NUM_str         VARCHAR2(100);
    l_new_NUM_str_update  VARCHAR2(100);
    l_counter             NUMBER := 0;
    diff_qty              NUMBER := 0;
    l_debug               NUMBER;
    x_return_status       VARCHAR2(10);
    x_msg_count           NUMBER;
    been_here             BOOLEAN := FALSE;
    x_msg_data            VARCHAR2(200);

  BEGIN
    IF (l_debug = 1) THEN
      DEBUG('adjust_serial_numbers_in_MMTT p_transaction_temp_id='||p_transaction_temp_id||' p_qty= '||p_qty,'INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
    END IF;

    FOR l_serial_cursor IN serial_cursor LOOP
    EXIT WHEN serial_cursor%NOTFOUND;


    --determine the number of serial numbers associated with this temp id

      diff_qty := INV_SERIAL_NUMBER_PUB.GET_SERIAL_DIFF(l_serial_cursor.fm_Serial_number,l_serial_cursor.to_serial_number);
      qty_count := qty_count + diff_qty;
      l_counter := l_counter+1;

      IF (l_debug = 1) THEN
        DEBUG('p_qty= '||p_qty||' diff_qty= '||diff_qty||' qty_count= '||qty_count||' l_counter='||l_counter,'INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
      END IF;

      if (qty_count>p_qty AND NOT delete_remaining_Serial) then
    	--get rid of xtra serial numbers from msnt
	--(qty_count-p_qty) serials
	--if the diff_qty>(qty_count-p_qty)
	--if range then reduce this range
	--following logic will derive the to_Serial_number
        --If range

        IF (l_debug = 1) THEN
          DEBUG('p_qty= '||p_qty||' diff_qty= '||diff_qty||' qty_count= '||qty_count,'INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
        END IF;

        IF (l_Serial_cursor.fm_serial_number <> l_Serial_cursor.to_serial_number ) THEN

        --if range then we have to either update the range or delete the whole range
          if (diff_qty = qty_count-p_qty) then
              --delete the whole range
        IF (l_debug = 1) THEN
          DEBUG('Inside if p_qty= '||p_qty||' diff_qty= '||diff_qty||' qty_count= '||qty_count||' fm_Serial='||l_Serial_cursor.fm_serial_number||' to_ser='||l_serial_cursor.to_serial_number,'INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
        END IF;

              delete from mtl_Serial_numbers_temp
              where transaction_temp_id = p_transaction_temp_id
              and fm_Serial_number = l_Serial_cursor.fm_serial_number
              and to_Serial_number = l_Serial_cursor.to_serial_number;

             /*** {{ R12 Enhanced reservations code changes,
              *** call serial_check.inv_unmark_rsv_serial instead of update msn directly
              update mtl_Serial_numbers
              set group_mark_id = null
              where current_organization_id = l_serial_cursor.organization_id
              and inventory_item_id = l_Serial_cursor.inventory_item_id
              and serial_number between l_Serial_cursor.fm_Serial_number and l_serial_cursor.to_Serial_number;
              *** End R12 }} ***/

             /*** {{ R12 Enhanced reservations code changes ***/
              serial_check.inv_unmark_rsv_serial
                 (from_serial_number   => l_Serial_cursor.fm_Serial_number
                 ,to_serial_number     => l_serial_cursor.to_Serial_number
                 ,serial_code          => null
                 ,hdr_id               => null
                 ,p_inventory_item_id  => l_Serial_cursor.inventory_item_id
                 ,p_update_reservation => fnd_api.g_true);
             /*** End R12 }} ***/

              delete_remaining_serial := TRUE;
            been_here := TRUE;
          else

              --update the range

            IF (l_debug = 1) THEN
               DEBUG('Inside ifelse p_qty= '||p_qty||' diff_qty= '||diff_qty||' qty_count= '||qty_count,'INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
               DEBUG(' fm_Ser_num= '||l_Serial_cursor.fm_serial_number ||' to_Ser_num= '||l_Serial_cursor.to_serial_number ,'INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
            END IF;

        	IF NOT mtl_serial_check.INV_SERIAL_INFO
	            (p_from_serial_number  =>  l_Serial_cursor.fm_serial_number ,
                 p_to_serial_number    =>  l_Serial_cursor.to_serial_number ,
    	         x_prefix              =>  x_prefix,
                 x_quantity            =>  x_quantity,
                 x_from_number         =>  l_from_number,
                 x_to_number           =>  l_to_number,
                 x_errorcode           =>  x_errorcode) THEN
	       RAISE FND_API.G_EXC_ERROR;
           END IF;

           l_new_num:=l_from_number+(diff_qty-((qty_count-p_qty)+1));
           l_new_num_update:=l_from_number+(diff_qty-((qty_count-p_qty)+1))+1;
           IF (l_debug = 1) THEN
             DEBUG('l_new_num= '||l_new_num||' l_new_num_update='||l_new_num_update,'INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
           END IF;

           if (length(l_new_num)<length(l_from_number)) then
    	       l_new_num_str:=lpad(l_new_num,length(l_from_number),'0');
    	       l_new_num_str_update:=lpad(l_new_num_update,length(l_from_number),'0');
           end if;
           IF (l_debug = 1) THEN
             DEBUG('l_new_num_Str= '||l_new_num_str||' l_new_num_Str_update='||l_new_num_str_update,'INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
           END IF;


           update mtl_serial_numbers_temp
           set fm_Serial_number = l_Serial_cursor.fm_serial_number
           ,to_Serial_number = x_prefix||l_new_num_str
           where fm_Serial_number = l_Serial_cursor.fm_serial_number
           and to_Serial_number = l_Serial_cursor.to_serial_number
           and transaction_temp_id = p_transaction_temp_id;

           IF (l_debug = 1) THEN
             DEBUG('after update l_new_num_Str= '||l_new_num_str,'INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
           END IF;
    	   --set a flag to delete the subsequent records from MSNT

           --unmark these serial numbers in MSN
          /*** {{ R12 Enhanced reservations code changes,
           *** call serial_check.inv_unmark_rsv_serial instead of update msn directly
           update mtl_serial_numbers
           set group_mark_id = null
           where current_organization_id = l_serial_cursor.organization_id
           and inventory_item_id = l_serial_cursor.inventory_item_id
           and serial_number between x_prefix||l_new_num_str_update and l_Serial_cursor.to_serial_number;
           *** End R12 }} ***/

          /*** {{ R12 Enhanced reservations code changes ***/
           serial_check.inv_unmark_rsv_serial
              (from_serial_number   => x_prefix||l_new_num_str_update
              ,to_serial_number     => l_serial_cursor.to_serial_number
              ,serial_code          => null
              ,hdr_id               => null
              ,p_inventory_item_id  => l_serial_cursor.inventory_item_id
              ,p_update_reservation => fnd_api.g_true);
          /*** End R12 }} ***/

           delete_remaining_serial := TRUE;
            been_here := TRUE;
          end if;
        else   --END of range
            IF (l_debug = 1) THEN
               DEBUG('after update fm_Serial_num= '||l_Serial_cursor.fm_serial_number||' to_Ser_num= '||l_serial_cursor.to_serial_number,'INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
            END IF;

            delete from mtl_serial_numbers_temp
            where fm_Serial_number = l_Serial_cursor.fm_serial_number
            and to_serial_number = l_serial_cursor.to_serial_number
            and transaction_temp_id = p_transaction_Temp_id;

           /*** {{ R12 Enhanced reservations code changes,
            *** call serial_check.inv_unmark_rsv_serial instead of update msn directly
            update mtl_serial_numbers
            set group_mark_id = null
            where current_organization_id = l_serial_cursor.organization_id
            and inventory_item_id = l_serial_cursor.inventory_item_id
            and serial_number = l_Serial_cursor.fm_serial_number;
            *** End R12 }} ***/

           /*** {{ R12 Enhanced reservations code changes ***/
            serial_check.inv_unmark_rsv_serial
               (from_serial_number   => l_Serial_cursor.fm_serial_number
               ,to_serial_number     => null
               ,serial_code          => null
               ,hdr_id               => null
               ,p_inventory_item_id  => l_serial_cursor.inventory_item_id
               ,p_update_reservation => fnd_api.g_true);
           /*** End R12 }} ***/

            delete_remaining_serial := TRUE;
            been_here := TRUE;

        end if;
      end if;

      if (delete_remaining_serial and l_counter > 1 and NOT been_here) then
            IF (l_debug = 1) THEN
              DEBUG('After update fm_Serial_num= '||l_Serial_cursor.fm_serial_number||' to_Ser_num= '||l_serial_cursor.to_serial_number,'INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
            END IF;

            delete from mtl_serial_numbers_temp
            where fm_Serial_number = l_Serial_cursor.fm_serial_number
            and to_serial_number = l_serial_cursor.to_serial_number
            and transaction_temp_id = p_transaction_Temp_id;


           /*** {{ R12 Enhanced reservations code changes,
            *** call serial_check.inv_unmark_rsv_serial instead of update msn directly
            update mtl_serial_numbers
            set group_mark_id = null
            where current_organization_id = l_serial_cursor.organization_id
            and inventory_item_id = l_serial_cursor.inventory_item_id
            and serial_number = l_Serial_cursor.to_serial_number;
            *** End R12 }} ***/

           /*** {{ R12 Enhanced reservations code changes ***/
            serial_check.inv_unmark_rsv_serial
               (from_serial_number   => l_Serial_cursor.to_serial_number
               ,to_serial_number     => null
               ,serial_code          => null
               ,hdr_id               => null
               ,p_inventory_item_id  => l_serial_cursor.inventory_item_id
               ,p_update_reservation => fnd_api.g_true);
           /*** End R12 }} ***/

      end if;

            been_here :=FALSE;
    END LOOP;

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        IF (l_debug = 1) THEN
           DEBUG('Expected error while closing the Line','INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
        END IF;
        x_return_status  := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (l_debug = 1) THEN
           DEBUG('Unexpected error while closing the Line','INV_TRANSFER_ORDER_PVT.adjust_serial_numbers_in_MMTT');
        END IF;
        x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN OTHERS THEN
        x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_msg_pub.add_exc_msg(g_pkg_name, 'adjust_serial_numbers_in_MMTT');
        END IF;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END adjust_serial_numbers_in_MSNT;

END inv_transfer_order_pvt;

/
