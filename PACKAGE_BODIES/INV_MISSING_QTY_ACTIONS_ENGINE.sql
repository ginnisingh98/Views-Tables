--------------------------------------------------------
--  DDL for Package Body INV_MISSING_QTY_ACTIONS_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MISSING_QTY_ACTIONS_ENGINE" AS
  /* $Header: INVMQAEB.pls 120.4.12010000.4 2009/10/12 09:31:14 ksivasa ship $ */

  -- Variables for Debug Messages
  g_pkg_name        CONSTANT VARCHAR2(50) := 'INV_MISSING_QTY_ACTIONS_ENGINE';
  g_version_printed          BOOLEAN      := FALSE;
  g_exception       CONSTANT NUMBER       := 1;
  g_error           CONSTANT NUMBER       := 3;
  g_info            CONSTANT NUMBER       := 5;

  PROCEDURE print_debug(p_message VARCHAR2, p_module VARCHAR2, p_level NUMBER) IS
  BEGIN
    IF NOT g_version_printed THEN
      inv_log_util.trace('$Header: INVMQAEB.pls 120.4.12010000.4 2009/10/12 09:31:14 ksivasa ship $', g_pkg_name);
      g_version_printed := TRUE;
    END IF;

    inv_log_util.trace(p_message, g_pkg_name || '.' || p_module, p_level);
  END print_debug;

  PROCEDURE get_item_controls(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_lot_control_code    OUT NOCOPY NUMBER
  , x_serial_control_code OUT NOCOPY NUMBER
  , p_transaction_temp_id            NUMBER
  , p_mo_line_id                     NUMBER
  ) IS
    CURSOR c_item_controls IS
      SELECT msi.lot_control_code, msi.serial_number_control_code
        FROM mtl_system_items msi, mtl_material_transactions_temp mmtt
       WHERE p_transaction_temp_id IS NOT NULL
         AND mmtt.transaction_temp_id = p_transaction_temp_id
         AND msi.inventory_item_id = mmtt.inventory_item_id
         AND msi.organization_id = mmtt.organization_id
      UNION ALL
      SELECT msi.lot_control_code, msi.serial_number_control_code
        FROM mtl_system_items msi, mtl_txn_request_lines mtrl
       WHERE p_transaction_temp_id IS NULL AND p_mo_line_id IS NOT NULL
         AND mtrl.line_id = p_mo_line_id
         AND msi.inventory_item_id = mtrl.inventory_item_id
         AND msi.organization_id = mtrl.organization_id;
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    OPEN c_item_controls;
    FETCH c_item_controls INTO x_lot_control_code, x_serial_control_code;
    IF c_item_controls%NOTFOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_item_controls;
  END get_item_controls;

  PROCEDURE fill_cycle_count_rsv_rec(
    x_rsv_rec            OUT NOCOPY inv_reservation_global.mtl_reservation_rec_type
  , p_organization_id               NUMBER
  , p_inventory_item_id             NUMBER
  , p_revision                      VARCHAR2
  , p_lot_number                    VARCHAR2
  , p_subinventory_code             VARCHAR2
  , p_locator_id                    NUMBER
  , p_primary_uom_code              VARCHAR2
  --INVCONV kkillams
  ,p_secondary_uom_code             VARCHAR2 DEFAULT NULL
  --END INVCONV kkillams
  ) IS
  BEGIN
    x_rsv_rec.inventory_item_id            := p_inventory_item_id;
    x_rsv_rec.organization_id              := p_organization_id;
    x_rsv_rec.revision                     := p_revision;
    x_rsv_rec.lot_number                   := p_lot_number;
    x_rsv_rec.subinventory_code            := p_subinventory_code;
    x_rsv_rec.locator_id                   := p_locator_id;
    x_rsv_rec.primary_uom_code             := p_primary_uom_code;
    x_rsv_rec.reservation_uom_code         := p_primary_uom_code;
    x_rsv_rec.supply_source_type_id        := inv_reservation_global.g_source_type_inv;
    x_rsv_rec.demand_source_type_id        := inv_reservation_global.g_source_type_cycle_count;
    x_rsv_rec.demand_source_header_id      := -1;
    x_rsv_rec.demand_source_line_id        := -1;

    -- Fill the Required Fields expected by Create Reservations API
    x_rsv_rec.reservation_id               := NULL;
    x_rsv_rec.reservation_quantity         := NULL;
    x_rsv_rec.primary_reservation_quantity := NULL;
    x_rsv_rec.detailed_quantity            := 0;
    x_rsv_rec.requirement_date             := trunc(SYSDATE);
    x_rsv_rec.primary_uom_id               := NULL;
    x_rsv_rec.reservation_uom_id           := NULL;
    x_rsv_rec.autodetail_group_id          := NULL;
    x_rsv_rec.external_source_code         := NULL;
    x_rsv_rec.external_source_line_id      := NULL;
    x_rsv_rec.demand_source_delivery       := NULL;
    x_rsv_rec.demand_source_name           := NULL;
    x_rsv_rec.supply_source_header_id      := NULL;
    x_rsv_rec.supply_source_line_id        := NULL;
    x_rsv_rec.supply_source_name           := NULL;
    x_rsv_rec.supply_source_line_detail    := NULL;
    x_rsv_rec.lot_number_id                := NULL;
    x_rsv_rec.subinventory_id              := NULL;
    x_rsv_rec.pick_slip_number             := NULL;
    x_rsv_rec.lpn_id                       := NULL;
    x_rsv_rec.attribute_category           := NULL;
    x_rsv_rec.attribute1                   := NULL;
    x_rsv_rec.attribute2                   := NULL;
    x_rsv_rec.attribute3                   := NULL;
    x_rsv_rec.attribute4                   := NULL;
    x_rsv_rec.attribute5                   := NULL;
    x_rsv_rec.attribute6                   := NULL;
    x_rsv_rec.attribute7                   := NULL;
    x_rsv_rec.attribute8                   := NULL;
    x_rsv_rec.attribute9                   := NULL;
    x_rsv_rec.attribute10                  := NULL;
    x_rsv_rec.attribute11                  := NULL;
    x_rsv_rec.attribute12                  := NULL;
    x_rsv_rec.attribute13                  := NULL;
    x_rsv_rec.attribute14                  := NULL;
    x_rsv_rec.attribute15                  := NULL;
    x_rsv_rec.ship_ready_flag              := NULL;
    --INVCONV kkillams
    x_rsv_rec.secondary_uom_code             :=  p_secondary_uom_code;
    x_rsv_rec.secondary_reservation_quantity := NULL;
    x_rsv_rec.secondary_uom_id               := NULL;
    --END INVCONV kkillams
  END fill_cycle_count_rsv_rec;


  PROCEDURE remove_confirmed(
    x_return_status       OUT NOCOPY VARCHAR2
  , p_transaction_temp_id            NUMBER
  , p_lot_control_code               NUMBER
  , p_serial_control_code            NUMBER
  ) IS
    l_api_name            VARCHAR2(30) := 'REMOVE_CONFIRM';
    l_debug               NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
    l_updated_count       NUMBER := 0;
    l_deleted_count       NUMBER := 0;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
      print_debug('Updating Temp table to remove Confirmed Lots/Serials', l_api_name, g_info);
    END IF;

    IF p_lot_control_code = 2 AND p_serial_control_code IN(1, 6) THEN
      UPDATE mtl_allocations_gtmp mat
         SET (primary_quantity, transaction_quantity,secondary_quantity)
              = (SELECT mat.primary_quantity - nvl(SUM(mtlt.primary_quantity),0)
                      , mat.transaction_quantity - nvl(SUM(mtlt.transaction_quantity),0)
                      , DECODE(NVL(mat.secondary_quantity,0) - NVL(SUM(mtlt.secondary_quantity),0)
                                 ,0,NULL,
                                 NVL(mat.secondary_quantity,0) - NVL(SUM(mtlt.secondary_quantity),0)
                               ) --INVCONV kkillams
                   FROM mtl_transaction_lots_temp mtlt
                  WHERE mtlt.transaction_temp_id = p_transaction_temp_id
                    AND mtlt.lot_number = mat.lot_number)

       WHERE mat.transaction_temp_id = p_transaction_temp_id;
      l_updated_count := SQL%ROWCOUNT;

      DELETE mtl_allocations_gtmp
        WHERE transaction_temp_id = p_transaction_temp_id AND primary_quantity <= 0;
      l_deleted_count := SQL%ROWCOUNT;
    ELSIF p_lot_control_code = 1 AND p_serial_control_code NOT IN(1, 6) THEN
      DELETE mtl_allocations_gtmp
       WHERE transaction_temp_id = p_transaction_temp_id
         AND serial_number IN(  SELECT msn.serial_number
                                  FROM mtl_serial_numbers msn
                                 WHERE msn.group_mark_id = p_transaction_temp_id);
      l_deleted_count := SQL%ROWCOUNT;
    ELSIF p_lot_control_code = 2 AND p_serial_control_code NOT IN(1, 6) THEN
      DELETE mtl_allocations_gtmp
        WHERE transaction_temp_id = p_transaction_temp_id
          AND serial_number IN( SELECT msn.serial_number
                                  FROM mtl_transaction_lots_temp mtlt, mtl_serial_numbers msn
                                 WHERE mtlt.transaction_temp_id = p_transaction_temp_id
                                   AND msn.group_mark_id = mtlt.serial_transaction_temp_id);
      l_deleted_count := SQL%ROWCOUNT;

      IF SQL%ROWCOUNT = 0 THEN
        UPDATE mtl_allocations_gtmp mat
           SET (primary_quantity, transaction_quantity,secondary_quantity)
                = (SELECT mat.primary_quantity - nvl(SUM(mtlt.primary_quantity),0)
                        , mat.transaction_quantity - nvl(SUM(mtlt.transaction_quantity),0)
                        , DECODE(NVL(mat.secondary_quantity,0) - NVL(SUM(mtlt.secondary_quantity),0)
                                 ,0,NULL,
                                 NVL(mat.secondary_quantity,0) - NVL(SUM(mtlt.secondary_quantity),0)
                                ) --INVCONV kkillams

                     FROM mtl_transaction_lots_temp mtlt
                    WHERE mtlt.transaction_temp_id = p_transaction_temp_id
                      AND mtlt.lot_number = mat.lot_number)
         WHERE mat.transaction_temp_id = p_transaction_temp_id;
        l_updated_count := SQL%ROWCOUNT;

        DELETE mtl_allocations_gtmp
          WHERE transaction_temp_id = p_transaction_temp_id AND primary_quantity <= 0;
        l_deleted_count := SQL%ROWCOUNT;
      END IF;
    END IF;

    IF l_debug = 1 THEN
      print_debug('Lot Control Code = ' || p_lot_control_code || ' : Serial Control Code = ' || p_serial_control_code, l_api_name, g_info);
      print_debug('# of Records Updated = ' || l_updated_count, l_api_name, g_info);
      print_debug('# of Records Deleted = ' || l_deleted_count, l_api_name, g_info);
      print_debug('Updated Temp Table to contain Unconfirmed Lots/Serials', l_api_name, g_info);
    END IF;
  END remove_confirmed;

  PROCEDURE backorder_only(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , p_transaction_temp_id            NUMBER
  , p_quantity                       NUMBER
  --INVCONV KKILLAMS
  , p_secondary_quantity             NUMBER DEFAULT NULL
  --END INVCONV KKILLAMS
  ) IS
    l_debug             NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_api_name          VARCHAR2(30) := 'BACKORDER_ONLY';
    l_from_rsv_rec      inv_reservation_global.mtl_reservation_rec_type;
    l_to_rsv_rec        inv_reservation_global.mtl_reservation_rec_type;
    l_dummy_sn          inv_reservation_global.serial_number_tbl_type;
    l_primary_qty       NUMBER  := p_quantity;
    l_rsv_primary_qty   NUMBER;
    l_rsv_detailed_qty  NUMBER;
    l_ato_item          NUMBER  := 0;
    l_mmtt_primary_qty_sum NUMBER := 0;      /*Bug.4539851*/
    --INVCONV KKILLAMS
    l_res_secondary_qty                 mtl_reservations.secondary_reservation_quantity%TYPE;
    l_sec_secondary_qty                 mtl_reservations.secondary_detailed_quantity%TYPE;
    --END INVCONV KKILLAMS

    CURSOR c_mmtt_info IS
      SELECT mmtt.inventory_item_id
           , mmtt.transaction_uom
           , mmtt.reservation_id
           , msi.primary_uom_code
           , msi.replenish_to_order_flag
           , msi.bom_item_type
           , msi.secondary_uom_code --INVCONV kkillams
         FROM mtl_material_transactions_temp mmtt, mtl_system_items msi
       WHERE mmtt.transaction_temp_id = p_transaction_temp_id
         AND msi.inventory_item_id = mmtt.inventory_item_id
         AND msi.organization_id = mmtt.organization_id;

    l_mmtt_info c_mmtt_info%ROWTYPE;

    CURSOR c_rsv_info IS
      SELECT primary_reservation_quantity, detailed_quantity
             ,secondary_reservation_quantity, secondary_detailed_quantity  --INVCONV kkillams
        FROM mtl_reservations
       WHERE reservation_id = l_mmtt_info.reservation_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_mmtt_info;
    FETCH c_mmtt_info INTO l_mmtt_info;
    CLOSE c_mmtt_info;

    IF l_mmtt_info.reservation_id IS NULL THEN
      RETURN;
    END IF;


    /*Bug:4539851.Getting the sum of primary_quantity of all the allocations for the given
      reservation_id*/
    BEGIN
      SELECT SUM(ABS(primary_quantity))
      INTO   l_mmtt_primary_qty_sum
      FROM   mtl_material_transactions_temp
      WHERE  reservation_id= l_mmtt_info.reservation_id;
    EXCEPTION
      WHEN OTHERS THEN
         RAISE fnd_api.g_exc_unexpected_error;
    END;

    print_debug('sum of all allocations ='||l_mmtt_primary_qty_sum,l_api_name,g_info);


    OPEN c_rsv_info;
    FETCH c_rsv_info INTO l_rsv_primary_qty, l_rsv_detailed_qty
                          ,l_res_secondary_qty    --INCONV KKILLAMS
                          ,l_sec_secondary_qty;    --INCONV KKILLAMS
    IF c_rsv_info%NOTFOUND THEN
      CLOSE c_rsv_info;
      fnd_message.set_name('INV','INV-ROW-NOT-FOUND');
      fnd_msg_pub.ADD;
      /*Bug:4700706. When the reservation record is deleted  somehow by this time we need not
        deal with the reservation.So we just return. */
      RETURN;
      --RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    CLOSE c_rsv_info;

    -- Bug#2621481: For ATO Item, Retain the Reservation Qty
    IF l_mmtt_info.bom_item_type = 4 AND l_mmtt_info.replenish_to_order_flag = 'Y' THEN
      l_ato_item  := 1;
    END IF;

    /*Bug:4539851. Removed the following code as we are directly getting the primary quantity
      from MMTT into l_mmtt_primary_qty_sum. */
    /*IF l_mmtt_info.transaction_uom <> l_mmtt_info.primary_uom_code THEN

      l_primary_qty :=
        inv_convert.inv_um_convert(l_mmtt_info.inventory_item_id, NULL, p_quantity,
              l_mmtt_info.transaction_uom, l_mmtt_info.primary_uom_code, NULL, NULL);

    END IF;
    */


    l_from_rsv_rec.reservation_id  := l_mmtt_info.reservation_id;
    /*Bug:4539851. Changed the logic to calculate l_to_rsv_rec.detailed_quantity
      by taking minimum of current detailed quantity and the sum of transaction quantity
      of all the allocations in MMTT of the Move Order line */
    --l_to_rsv_rec.detailed_quantity := l_rsv_detailed_qty - l_primary_qty;

      l_to_rsv_rec.detailed_quantity := least(l_rsv_detailed_qty , l_mmtt_primary_qty_sum);

      print_debug('Detailed Quantity :'||l_to_rsv_rec.detailed_quantity,l_api_name,g_info);

    IF l_ato_item <> 1 THEN
      --l_to_rsv_rec.primary_reservation_quantity := l_rsv_primary_qty - l_primary_qty;
      /*Bug:4539851. Changed the logic to calculate l_to_rsv_rec.primary_reservation_quantity
       by taking min of current reservation quantity of the MO line and the sum of transaction quantity
       of all the allocations in MMTT of the Move Order line */
      --l_to_rsv_rec.primary_reservation_quantity := l_rsv_primary_qty - l_primary_qty;

	 l_to_rsv_rec.primary_reservation_quantity := least(l_rsv_primary_qty , l_mmtt_primary_qty_sum);

       print_debug('Primary Reservation Qty:'||l_to_rsv_rec.primary_reservation_quantity,l_api_name,g_info);
    END IF;

   --INVCONV KKILLAMS
    l_to_rsv_rec.secondary_detailed_quantity    := NVL(l_sec_secondary_qty,0) - NVL(p_secondary_quantity,0);
    l_to_rsv_rec.secondary_reservation_quantity := NVL(l_res_secondary_qty,0) - NVL(p_secondary_quantity,0);
    IF l_to_rsv_rec.secondary_detailed_quantity = 0 THEN
       l_to_rsv_rec.secondary_detailed_quantity :=  NULL;
    END IF;
    IF l_to_rsv_rec.secondary_reservation_quantity = 0  THEN
       l_to_rsv_rec.secondary_reservation_quantity :=  NULL;
    END IF;
   --END INVCONV KKILLAMS


    inv_reservation_pvt.update_reservation(
      x_return_status          => x_return_status
    , x_msg_count              => x_msg_count
    , x_msg_data               => x_msg_data
    , p_api_version_number     => 1.0
    , p_original_rsv_rec       => l_from_rsv_rec
    , p_to_rsv_rec             => l_to_rsv_rec
    , p_original_serial_number => l_dummy_sn
    , p_to_serial_number       => l_dummy_sn
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('INV', 'INV_UPD_RSV_FAILED');
      fnd_msg_pub.ADD;
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
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'UNDO_PICK_RELEASE');
      END IF;
  END backorder_only;

  PROCEDURE split_allocation(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , x_new_txn_temp_id     OUT NOCOPY NUMBER
  , p_transaction_temp_id            NUMBER
  , p_split_quantity                 NUMBER
  , p_lot_control_code               NUMBER
  , p_serial_control_code            NUMBER
  --INVCONV kkillams
  , p_split_sec_quantity             NUMBER DEFAULT NULL
  --END INVCONV kkillams
  ) IS
    l_api_name           VARCHAR2(30) := 'SPLIT_ALLOCATE';
    l_debug              NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);

    l_txn_header_id      NUMBER;
    l_org_id             NUMBER;
    l_item_id            NUMBER;
    l_primary_uom        mtl_system_items.primary_uom_code%TYPE;
    l_txn_uom            mtl_system_items.primary_uom_code%TYPE;
    l_sec_uom_code       mtl_system_items.primary_uom_code%TYPE; --INVCONV kkillams
    l_rem_txn_qty        NUMBER;
    l_rem_pri_qty        NUMBER;
    l_lot_txn_qty        NUMBER;
    l_lot_pri_qty        NUMBER;
    l_serial_txn_temp_id NUMBER;
    l_insert_count       NUMBER;
    l_update_count       NUMBER;
    l_rem_sec_txn_qty    NUMBER; --INVCONV kkillams
    l_lot_sec_qty        NUMBER; --INVCONV kkillams

    CURSOR c_mmtt_info IS
      SELECT mmtt.transaction_header_id, mmtt.organization_id, mmtt.inventory_item_id, mmtt.transaction_uom, msi.primary_uom_code
            , msi.secondary_uom_code --INVCONV kkillams
        FROM mtl_material_transactions_temp mmtt, mtl_system_items msi
       WHERE mmtt.transaction_temp_id = p_transaction_temp_id
         AND msi.inventory_item_id    = mmtt.inventory_item_id
         AND msi.organization_id      = mmtt.organization_id;

    --Bug Number 3372238 added the group by clause
    CURSOR c_unconfirmed_lots IS
      SELECT lot_number, SUM(transaction_quantity) transaction_quantity ,SUM (primary_quantity) primary_quantity
             ,DECODE (SUM(NVL(secondary_quantity,0)),0,NULL,SUM(NVL(secondary_quantity,0))) secondary_quantity --INVCONV KKILLAMS
        FROM mtl_allocations_gtmp
       WHERE transaction_temp_id = p_transaction_temp_id
       GROUP BY lot_number;
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
      print_debug('Splitting the Current Allocation to create a new one for the Remaining Qty', l_api_name, g_info);
    END IF;

    OPEN c_mmtt_info;
    FETCH c_mmtt_info INTO l_txn_header_id, l_org_id, l_item_id, l_txn_uom, l_primary_uom,l_sec_uom_code;
    CLOSE c_mmtt_info;

    -- Converting TxnQty into PrimaryQty
    l_rem_txn_qty := p_split_quantity;
    l_rem_pri_qty := inv_convert.inv_um_convert(l_item_id, NULL, l_rem_txn_qty, l_txn_uom, l_primary_uom, NULL, NULL);

    --INVCONV kkillams
    l_rem_sec_txn_qty := p_split_sec_quantity;
    --END INVCONV kkillams

    -- Create a new MMTT from old MMTT
    inv_trx_util_pub.copy_insert_line_trx(
      x_return_status       => x_return_status
    , x_msg_data            => x_msg_data
    , x_msg_count           => x_msg_count
    , x_new_txn_temp_id     => x_new_txn_temp_id
    , p_transaction_temp_id => p_transaction_temp_id
    , p_organization_id     => l_org_id
    , p_txn_qty             => l_rem_txn_qty
    , p_primary_qty         => l_rem_pri_qty
    , p_sec_txn_qty         => l_rem_sec_txn_qty  --INVCONV KKILLAMS
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug = 1 THEN
        print_debug('Error: Cannot copy the MMTT - Error = ' || x_msg_data, l_api_name, g_error);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF l_debug = 1 THEN
      print_debug('The old Transaction Temp id id = '|| p_transaction_temp_id, l_api_name, g_info);
      print_debug('Created a new MMTT.The new Transaction Temp IS is = '|| x_new_txn_temp_id, l_api_name, g_info);
      print_debug('Transaction UOM = ' || l_txn_uom, l_api_name, g_info);
      print_debug('Primary UOM     = ' || l_primary_uom, l_api_name, g_info);
      print_debug('Transaction Qty = ' || l_rem_txn_qty, l_api_name, g_info);
      print_debug('Primary Qty     = ' || l_rem_pri_qty, l_api_name, g_info);
      print_debug('Secondary Qty   = ' || l_rem_sec_txn_qty, l_api_name, g_info); --INVCONV KKILLAMS
    END IF;

    -- If Lot Controlled, create Lot Records
    IF p_lot_control_code = 2 THEN
      FOR curr_lot IN c_unconfirmed_lots LOOP
        l_lot_txn_qty := curr_lot.transaction_quantity;
        l_lot_pri_qty := curr_lot.primary_quantity;
        l_lot_sec_qty := curr_lot.secondary_quantity;  --INVCONV kkillams
       IF l_debug = 1 THEN
       print_debug('The lot number from the cursor is '|| curr_lot.lot_number,l_api_name, g_info);
       print_debug('The transaction quantity is '|| curr_lot.transaction_quantity,l_api_name, g_info);
       print_debug('The primary quantity is '|| curr_lot.primary_quantity,l_api_name, g_info);
       print_debug('The remaining quantity is '|| l_rem_txn_qty,l_api_name, g_info);
       END IF;

        INSERT INTO mtl_transaction_lots_temp(
                      transaction_temp_id
                    , lot_number, transaction_quantity, primary_quantity
                    , serial_transaction_temp_id, group_header_id
                    , last_update_date, last_updated_by, creation_date, created_by
                    ,secondary_quantity  --INVCONV kkillams
                    )
               VALUES(
                      x_new_txn_temp_id
                    , curr_lot.lot_number,least(l_rem_txn_qty, l_lot_txn_qty), least(l_rem_pri_qty, l_lot_pri_qty)
                    , mtl_material_transactions_s.NEXTVAL, l_txn_header_id
                    , SYSDATE, fnd_global.user_id, SYSDATE, fnd_global.user_id
                    , DECODE(least(NVL(l_rem_sec_txn_qty,0), NVL(l_lot_sec_qty,0))
                                            ,0,NULL
                                            ,least(NVL(l_rem_sec_txn_qty,0), NVL(l_lot_sec_qty,0)))--INVCONV kkillams
                    )
            RETURNING serial_transaction_temp_id, transaction_quantity, primary_quantity
                      ,secondary_quantity --INVCONV kkillams
                 INTO l_serial_txn_temp_id, l_lot_txn_qty, l_lot_pri_qty
                      ,l_lot_sec_qty; --INVCONV kkillams

        IF l_debug = 1 THEN
          print_debug('Lot Controlled Item. So Inserting MTLT', l_api_name, g_info);
          print_debug('Lot Number          = ' || curr_lot.lot_number, l_api_name, g_info);
          print_debug('Lot Transaction Qty = ' || l_lot_txn_qty, l_api_name, g_info);
          print_debug('Lot Primary Qty     = ' || l_lot_pri_qty, l_api_name, g_info);
          print_debug('Lot Secondary Qty   = ' || l_lot_sec_qty, l_api_name, g_info);
        END IF;

        IF p_serial_control_code NOT IN (1,6) THEN
          INSERT INTO mtl_serial_numbers_temp(
                        transaction_temp_id
                      , fm_serial_number, to_serial_number, serial_prefix
                      , last_update_date, last_updated_by, creation_date, created_by
                      )
                 SELECT l_serial_txn_temp_id
                      , serial_number, serial_number, 1
                      , SYSDATE, fnd_global.user_id, SYSDATE, fnd_global.user_id
                   FROM mtl_allocations_gtmp
                  WHERE transaction_temp_id = p_transaction_temp_id
                    AND lot_number = curr_lot.lot_number
                    AND ROWNUM <= l_lot_pri_qty;
          l_insert_count := SQL%ROWCOUNT;

          --Bug #4929806
          --Need to set line_mark_id also since the user may change allocated serials
          --after splitting the allocation
          UPDATE mtl_serial_numbers
             SET group_mark_id = l_serial_txn_temp_id
               , line_mark_id = l_serial_txn_temp_id
           WHERE serial_number IN (SELECT fm_serial_number FROM mtl_serial_numbers_temp
                                    WHERE transaction_temp_id = l_serial_txn_temp_id)
             AND inventory_item_id = l_item_id;
          l_update_count := SQL%ROWCOUNT;

          IF l_debug = 1 THEN
            print_debug('Lot and Serial Controlled Item. So Inserting MSNT', l_api_name, g_info);
            print_debug('# of Serials Inserted into MSNT = ' || l_insert_count, l_api_name, g_info);
            print_debug('# of Serials Marked in MSN      = ' || l_update_count, l_api_name, g_info);
          END IF;
        END IF;

        l_rem_txn_qty     := l_rem_txn_qty - l_lot_txn_qty;
        l_rem_pri_qty     := l_rem_pri_qty - l_lot_pri_qty;
        l_rem_sec_txn_qty := NVL(l_rem_sec_txn_qty,0) - NVL(l_lot_sec_qty,0);  --INVCONV kkillams
        EXIT WHEN l_rem_txn_qty <= 0;
      END LOOP;
    ELSIF p_serial_control_code NOT IN (1,6) THEN
       -- If Serial Controlled, create Serial Records
       INSERT INTO mtl_serial_numbers_temp(
                     transaction_temp_id
                   , fm_serial_number, to_serial_number, serial_prefix
                   , last_update_date, last_updated_by, creation_date, created_by
                   )
              SELECT x_new_txn_temp_id
                   , serial_number, serial_number, 1
                   , SYSDATE, fnd_global.user_id, SYSDATE, fnd_global.user_id
                FROM mtl_allocations_gtmp
               WHERE transaction_temp_id = p_transaction_temp_id
                 AND ROWNUM <= l_rem_pri_qty;
       l_insert_count := SQL%ROWCOUNT;

       --Bug #4929806
       --Need to set line_mark_id also since the user may change allocated serials
       --after splitting the allocation
       UPDATE mtl_serial_numbers
          SET group_mark_id = x_new_txn_temp_id
            , line_mark_id= x_new_txn_temp_id
        WHERE serial_number IN (SELECT fm_serial_number FROM mtl_serial_numbers_temp
                                 WHERE transaction_temp_id = x_new_txn_temp_id)
          AND inventory_item_id = l_item_id;
       l_update_count := SQL%ROWCOUNT;

       IF l_debug = 1 THEN
         print_debug('Serial Controlled Item. So Inserting MSNT', l_api_name, g_info);
         print_debug('# of Serials Inserted into MSNT = ' || l_insert_count, l_api_name, g_info);
         print_debug('# of Serials Marked in MSN      = ' || l_update_count, l_api_name, g_info);
       END IF;
    END IF;

    IF l_debug = 1 THEN
      print_debug('Created a new Allocation: TxnTempID = ' || x_new_txn_temp_id, l_api_name, g_info);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      IF l_debug = 1 THEN
        print_debug('Exception: Unknown Error occurred: SQLCode = ' || SQLCODE, l_api_name, g_exception);
      END IF;
  END split_allocation;

  PROCEDURE get_availability(
   p_cc_rsv_rec inv_reservation_global.mtl_reservation_rec_type
  --INVCONV kkilams
  ,p_res_qty           OUT NOCOPY  NUMBER
  ,p_sec_qty           OUT NOCOPY  NUMBER
  --END INVCONV kkillams
  )  IS
    l_return_status       VARCHAR2(1);
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;

    l_qoh                 NUMBER;
    l_rqoh                NUMBER;
    l_qs                  NUMBER;
    l_atr                 NUMBER;
    l_att                 NUMBER;
    l_qr                  NUMBER;
    --INVCONV kkilams
    l_sqoh                 NUMBER;
    l_srqoh                NUMBER;
    l_sqs                  NUMBER;
    l_satr                 NUMBER;
    l_satt                 NUMBER;
    l_sqr                  NUMBER;
    -- END INVCONV kkilams
    l_api_name VARCHAR2(30) := 'REPORT_CYC_CNT';
    l_debug    NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    inv_quantity_tree_pub.query_quantities(
      x_return_status        => l_return_status
    , x_msg_count            => l_msg_count
    , x_msg_data             => l_msg_data
    , p_api_version_number   => 1.0
    , p_init_msg_lst         => fnd_api.g_false
    , p_organization_id      => p_cc_rsv_rec.organization_id
    , p_inventory_item_id    => p_cc_rsv_rec.inventory_item_id
    , p_tree_mode            => inv_quantity_tree_pub.g_reservation_mode
    , p_is_revision_control  => (p_cc_rsv_rec.revision IS NOT NULL)
    , p_is_lot_control       => (p_cc_rsv_rec.lot_number IS NOT NULL)
    , p_is_serial_control    => FALSE
    , p_revision             => p_cc_rsv_rec.revision
    , p_lot_number           => p_cc_rsv_rec.lot_number
    , p_lot_expiration_date  => SYSDATE
    , p_subinventory_code    => p_cc_rsv_rec.subinventory_code
    , p_locator_id           => p_cc_rsv_rec.locator_id
    , p_grade_code           => NULL
    , x_qoh                  => l_qoh
    , x_rqoh                 => l_rqoh
    , x_qr                   => l_qr
    , x_qs                   => l_qs
    , x_att                  => l_att
    , x_atr                  => l_atr
      --INVCONV kkilams
    , x_sqoh                 => l_sqoh              -- invConv change
    , x_srqoh                => l_srqoh             -- invConv change
    , x_sqr                  => l_sqr               -- invConv change
    , x_sqs                  => l_sqs               -- invConv change
    , x_satt                 => l_satt              -- invConv change
   ,  x_satr                 => l_satr              -- invConv change
     --END INVCONV kkilams
    );
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug = 1 THEN
        print_debug('Error: Querying the Quantity Tree errored out', l_api_name, g_error);
      END IF;
      fnd_message.set_name('INV','INV-CANNOT QUERY TREE');
      fnd_msg_pub.ADD;
      p_res_qty :=0;
      p_sec_qty :=0;
      RETURN;
    END IF;

    IF l_debug = 1 THEN
      print_debug('Queried the Quantity Tree', l_api_name, g_info);
      print_debug('  Onhand       = ' || l_qoh, l_api_name, g_info);
      print_debug('  Availability = ' || l_atr, l_api_name, g_info);
      print_debug(' Secondary Onhand       = ' || l_sqoh, l_api_name, g_info);
      print_debug(' Secondary Availability = ' || l_satr, l_api_name, g_info);
    END IF;
    --INVCONV kkillams
    p_res_qty   := l_atr;
    p_sec_qty   := l_satr;
    --INVCONV kkillams
  END get_availability;

  PROCEDURE create_cc_reservations(
    x_return_status       OUT NOCOPY VARCHAR2
  , p_organization_id      IN        NUMBER
  , p_inventory_item_id    IN        NUMBER
  , p_reservation_id       IN        NUMBER
  , p_revision             IN        VARCHAR2
  , p_lot_number           IN        VARCHAR2
  , p_subinventory_code    IN        VARCHAR2
  , p_locator_id           IN        NUMBER
  , p_primary_quantity     IN        NUMBER
  , p_primary_uom_code     IN        VARCHAR2
  --INVCONV KKILLAMS
  , p_secondary_quantity   IN        NUMBER
  , p_secondary_uom_code   IN        VARCHAR2
  --END INVCONV KKILLAMS
  ) IS
    l_cc_rsv_rec          inv_reservation_global.mtl_reservation_rec_type;
    l_existing_rsv_rec    inv_reservation_global.mtl_reservation_rec_type;
    l_reservations_tbl    inv_reservation_global.mtl_reservation_tbl_type;
    l_dummy_sn            inv_reservation_global.serial_number_tbl_type;
    l_reservation_count   NUMBER;
    l_update_rsv          BOOLEAN := FALSE;
    l_new_reservation_id  NUMBER;
    l_qty_reserved        NUMBER;
    l_api_error_code      NUMBER;
    l_available_qty       NUMBER;
    l_sec_available_qty   NUMBER; --INVCONV KKILLAMS
    l_sec_qty_reserved    NUMBER;


    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;

    l_api_name VARCHAR2(30) := 'REPORT_CYC_CNT';
    l_debug    NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
    /*Bug#3869184. Added the below 2 variables to hold the primary and
      secondary reservation quantities of the existing Cycle Count Reservation*/
    l_existing_cc_res_pri_qty   NUMBER := 0;
    l_existing_cc_res_sec_qty   NUMBER := 0;

    l_qoh                 NUMBER;
    l_rqoh                NUMBER;
    l_qs                  NUMBER;
    l_atr                 NUMBER;
    l_att                 NUMBER;
    l_qr                  NUMBER;
    l_sqoh                NUMBER;
    l_srqoh               NUMBER;
    l_sqs                 NUMBER;
    l_satr                NUMBER;
    l_satt                NUMBER;
    l_sqr                 NUMBER;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    fill_cycle_count_rsv_rec(
      x_rsv_rec            => l_cc_rsv_rec
    , p_organization_id    => p_organization_id
    , p_inventory_item_id  => p_inventory_item_id
    , p_revision           => p_revision
    , p_lot_number         => p_lot_number
    , p_subinventory_code  => p_subinventory_code
    , p_locator_id         => p_locator_id
    , p_primary_uom_code   => p_primary_uom_code
    , p_secondary_uom_code => p_secondary_uom_code  --INVCONV kkillams
    );


  /*  -- For a Lot Controlled Item, MTLT would have been updated and so we need to consider that
    -- while Querying for the Availability.
    IF p_lot_number IS NOT NULL THEN
      l_available_qty := l_available_qty - p_primary_quantity;
    END IF;*/

    IF l_debug = 1 THEN
      print_debug('Cycle Count Reservations will be created with...', l_api_name, g_info);
      print_debug('  Organization ID         = ' || p_organization_id, l_api_name, g_info);
      print_debug('  Inventory ID            = ' || p_inventory_item_id, l_api_name, g_info);
      print_debug('  Revision                = ' || p_revision, l_api_name, g_info);
      print_debug('  Lot Number              = ' || p_lot_number, l_api_name, g_info);
      print_debug('  Subinventory Code       = ' || p_subinventory_code, l_api_name, g_info);
      print_debug('  Locator ID              = ' || p_locator_id, l_api_name, g_info);
      print_debug('  Reservation ID          = ' || p_reservation_id, l_api_name, g_info);
      print_debug('  Reported Missing Qty    = ' || p_primary_quantity, l_api_name, g_info);
      print_debug('  Remaining Available Qty = ' || l_available_qty, l_api_name, g_info);
      print_debug('  Secondary Remaining Available Qty = ' || p_secondary_quantity, l_api_name, g_info);
    END IF;

    --Bug 8784069, need to call update_quantities in order to update the quantity
    --tree with the newly reserved quantity.
    inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => x_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_organization_id
            , p_inventory_item_id          => p_inventory_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_reservation_mode
            , p_is_revision_control        => (p_revision IS NOT NULL)
            , p_is_lot_control             => (p_lot_number IS NOT NULL)
            , p_is_serial_control          => FALSE
            , p_demand_source_type_id      => inv_reservation_global.g_source_type_cycle_count
            , p_demand_source_header_id    => -1
            , p_demand_source_line_id      => -1
            , p_demand_source_name         => NULL
            , p_revision                   => p_revision
            , p_lot_number                 => p_lot_number
            , p_lot_expiration_date        => SYSDATE
            , p_subinventory_code          => p_subinventory_code
            , p_locator_id                 => p_locator_id
            , p_primary_quantity           => p_primary_quantity
            , p_secondary_quantity         => p_secondary_quantity
            , p_quantity_type              => inv_quantity_tree_pub.g_qr_same_demand
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , p_grade_code                 => NULL
            , x_sqoh                       => l_sqoh
            , x_srqoh                      => l_srqoh
            , x_sqr                        => l_sqr
            , x_sqs                        => l_sqs
            , x_satt                       => l_satt
            , x_satr                       => l_satr
          );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug = 1 THEN
          print_debug('Error from update quantity tree', l_api_name, g_info);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    /* Querying MTR to check for any Reservation with the same values as that of the new
       Cycle Count Reservation record to be created */
    inv_reservation_pvt.query_reservation(
      p_api_version_number        => 1.0
    , p_init_msg_lst              => fnd_api.g_false
    , x_return_status             => x_return_status
    , x_msg_count                 => l_msg_count
    , x_msg_data                  => l_msg_data
    , p_query_input               => l_cc_rsv_rec
    , x_mtl_reservation_tbl       => l_reservations_tbl
    , x_mtl_reservation_tbl_count => l_reservation_count
    , x_error_code                => l_api_error_code
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug = 1 THEN
        print_debug('Error: Querying Reservations to check for any existing reservation failed', l_api_name, g_error);
      END IF;
      fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF l_debug = 1 THEN
      print_debug('Number of CC Reservations existing for Item = ' || l_reservation_count, l_api_name, g_info);
    END IF;

    IF l_reservation_count > 1 THEN
      IF l_debug = 1 THEN
        print_debug('Error: Query Reservation returned more than one record', l_api_name, g_error);
      END IF;
      fnd_message.set_name('INV', 'INV_NON_UNIQUE_RSV');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_update_rsv := (l_reservation_count = 1);

    -- Create a Cycle Count Reservation for the Quantity reported as Missing.
    IF l_debug = 1 THEN
      print_debug('Creating Cycle Count Reservations for the Quantity reported', l_api_name, g_info);
    END IF;
    /*Bug#3869184. If there is only one Cycle Count Reservation, capture the primary and secondary
      reservation quantities corresponding to that reservation in the newly added variables*/
    If (l_update_rsv AND (p_reservation_id IS NOT NULL)) Then
      l_existing_cc_res_pri_qty := l_reservations_tbl(1).primary_reservation_quantity;
      l_existing_cc_res_sec_qty := NVL(l_reservations_tbl(1).secondary_reservation_quantity, 0);
      IF l_debug = 1 THEN
        print_debug('l_existing_cc_res_pri_qty:'||l_existing_cc_res_pri_qty, l_api_name, g_info);
        print_debug('l_existing_cc_res_sec_qty:'||l_existing_cc_res_sec_qty, l_api_name, g_info);
      END IF;

    End If;

    -- If Reservation already exists, Transfer the existing Reservation. Otherwise Create a new one.
    IF p_reservation_id IS NOT NULL THEN -- Transfer the Reservation
      IF l_debug = 1 THEN
        print_debug('Transferring the existing Reservation to a Cycle Count Reservation', l_api_name, g_info);
      END IF;

      l_existing_rsv_rec.reservation_id         := p_reservation_id;
      l_cc_rsv_rec.primary_reservation_quantity := p_primary_quantity;
      --INVCONV kkillams
      l_cc_rsv_rec.secondary_reservation_quantity := p_secondary_quantity; --INCONV kkillams
      IF l_cc_rsv_rec.secondary_reservation_quantity = 0 THEN
         l_cc_rsv_rec.secondary_reservation_quantity :=  NULL;
      END IF;
      --END INVCONV kkillams
      inv_reservation_pvt.transfer_reservation(
        x_return_status              => x_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , x_reservation_id             => l_new_reservation_id
      , p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_true
      , p_original_rsv_rec           => l_existing_rsv_rec
      , p_to_rsv_rec                 => l_cc_rsv_rec
      , p_original_serial_number     => l_dummy_sn
      , p_validation_flag            => fnd_api.g_true
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug = 1 THEN
          print_debug('Call to Transfer Reservation API Failed', l_api_name, g_error);
        END IF;
        fnd_message.set_name('INV','INV_TRANSFER_RSV_FAILED');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- The Reservation created below will always be updated in the Reservation created now.
      l_cc_rsv_rec.reservation_id := l_new_reservation_id;

    ELSE -- Create a new Reservation
      /* Though MMTT doesnt have any Reservation ID, there may be someother record with
         the same Reservation parameters. Rather than creating a new reservation, the
         existing reservation is updated */
      IF l_update_rsv THEN
        l_cc_rsv_rec := l_reservations_tbl(1);
        l_cc_rsv_rec.primary_reservation_quantity := l_cc_rsv_rec.primary_reservation_quantity + p_primary_quantity;
        --INVCONV KKILLAMS
        l_cc_rsv_rec.secondary_reservation_quantity := NVL(l_cc_rsv_rec.secondary_reservation_quantity,0) + NVL(p_secondary_quantity,0);  --INVCONV kkillams
        IF l_cc_rsv_rec.secondary_reservation_quantity = 0 THEN
         l_cc_rsv_rec.secondary_reservation_quantity :=  NULL;
        END IF;
        --END INVCONV kkillams
        l_cc_rsv_rec.reservation_quantity         := NULL;
        inv_reservation_pvt.update_reservation(
          x_return_status              => x_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
        , p_original_rsv_rec           => l_reservations_tbl(1)
        , p_to_rsv_rec                 => l_cc_rsv_rec
        , p_original_serial_number     => l_dummy_sn
        , p_to_serial_number           => l_dummy_sn
        , p_validation_flag            => fnd_api.g_true
        );
        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name('INV','INV_UPDATE_RSV_FAILED');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE
        l_cc_rsv_rec.primary_reservation_quantity := p_primary_quantity;
        --INVCONV kkillams
        l_cc_rsv_rec.secondary_reservation_quantity := p_secondary_quantity;
        IF l_cc_rsv_rec.secondary_reservation_quantity = 0 THEN
         l_cc_rsv_rec.secondary_reservation_quantity :=  NULL;
        END IF;
      --END INVCONV kkillams
        inv_reservation_pvt.create_reservation(
          x_return_status              => x_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , x_reservation_id             => l_new_reservation_id
        , x_quantity_reserved          => l_qty_reserved
        , x_secondary_quantity_reserved=> l_sec_qty_reserved --INVCONV kkillams
        , p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_true
        , p_rsv_rec                    => l_cc_rsv_rec
        , p_serial_number              => l_dummy_sn
        , x_serial_number              => l_dummy_sn
        , p_validation_flag            => fnd_api.g_true
        , p_partial_reservation_flag   => fnd_api.g_false
        , p_force_reservation_flag     => fnd_api.g_false
        );
        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name('INV','INV_CREATE_RSV_FAILED');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        /* Since a new Reservation is created, the next Reservation created below should be
           updated in the Reservation created now */
        l_cc_rsv_rec.reservation_id := l_new_reservation_id;
      END IF;
    END IF;

   get_availability(l_cc_rsv_rec,
                    l_available_qty,
                    l_sec_available_qty); --INVCONV kkillams

    -- Create a Cycle Count Reservation for the remaining Available Quantity.
    IF l_available_qty > 0 THEN
      IF l_debug = 1 THEN
        print_debug('Creating Cycle Count Reservations for the remaining Availability', l_api_name, g_info);
      END IF;

      l_existing_rsv_rec                        := l_cc_rsv_rec;

      l_cc_rsv_rec.primary_reservation_quantity := l_cc_rsv_rec.primary_reservation_quantity + l_available_qty + l_existing_cc_res_pri_qty; --Bug#3869184
      --INVCONV kkillams
      l_cc_rsv_rec.secondary_reservation_quantity := NVL(l_cc_rsv_rec.secondary_reservation_quantity,0) + NVL(l_sec_available_qty,0) + l_existing_cc_res_sec_qty; --Bug#3869184
      IF l_cc_rsv_rec.secondary_reservation_quantity = 0 THEN
         l_cc_rsv_rec.secondary_reservation_quantity :=  NULL;
      END IF;
      --END INVCONV kkillams

      l_cc_rsv_rec.reservation_quantity         := NULL;
      inv_reservation_pvt.update_reservation(
        x_return_status              => x_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_false
      , p_original_rsv_rec           => l_existing_rsv_rec
      , p_to_rsv_rec                 => l_cc_rsv_rec
      , p_original_serial_number     => l_dummy_sn
      , p_to_serial_number           => l_dummy_sn
      , p_validation_flag            => fnd_api.g_true
      );
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('INV','INV_UPDATE_RSV_FAILED');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded=>fnd_api.g_false, p_data => l_msg_data, p_count => l_msg_count);
      IF l_debug = 1 THEN
        print_debug('Exception: Expected: Message = ' || l_msg_data, l_api_name, g_exception);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded=>fnd_api.g_false, p_data => l_msg_data, p_count => l_msg_count);
      IF l_debug = 1 THEN
        print_debug('Exception: Unexpected: Message = ' || l_msg_data, l_api_name, g_exception);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF l_debug = 1 THEN
        print_debug('Exception: Others: Message = ' || SQLERRM, l_api_name, g_exception);
      END IF;
  END create_cc_reservations;

  PROCEDURE report_cycle_count(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , p_transaction_temp_id            NUMBER
  , p_missing_quantity               NUMBER
  , p_lot_control_code               NUMBER
  , p_sec_missing_quantity           NUMBER  --INVCONV kkillams
  ) IS
    l_api_name VARCHAR2(30) := 'REPORT_CYC_CNT';
    l_debug    NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);

    CURSOR c_mmtt_info IS
      SELECT mmtt.organization_id
           , mmtt.inventory_item_id
           , mmtt.reservation_id
           , mmtt.revision
           , mmtt.subinventory_code
           , mmtt.locator_id
           , mmtt.transaction_uom
           , msi.primary_uom_code
           , msi.secondary_uom_code --INVCONV kkillams
        FROM mtl_material_transactions_temp mmtt, mtl_system_items msi
       WHERE mmtt.transaction_temp_id = p_transaction_temp_id
         AND msi.inventory_item_id    = mmtt.inventory_item_id
         AND msi.organization_id      = mmtt.organization_id;

    --Bug #3380708 - added the group by clause
     CURSOR c_unconfirmed_lots IS
      SELECT lot_number
            ,SUM(transaction_quantity) transaction_quantity
            ,SUM(primary_quantity) primary_quantity
            ,DECODE(SUM(NVL(secondary_quantity,0)),0,NULL,SUM(NVL(secondary_quantity,0))) secondary_quantity  --INVCONV kkillams
        FROM mtl_allocations_gtmp
       WHERE transaction_temp_id = p_transaction_temp_id
       GROUP BY lot_number;


    l_mmtt_info           c_mmtt_info%ROWTYPE;
    l_primary_missing_qty NUMBER;
    l_rem_missing_qty     NUMBER;
    l_primary_lot_qty     NUMBER;

    l_secondary_lot_qty   NUMBER; --INVCONV KKILLAMS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
      print_debug('Creating Cycle Count Reservation to report Missing Material', l_api_name, g_info);
    END IF;

    OPEN c_mmtt_info;
    FETCH c_mmtt_info INTO l_mmtt_info;
    IF c_mmtt_info%NOTFOUND THEN
      IF l_debug = 1 THEN
        print_debug('Error: No Records Found in MMTT for the given query criteria', l_api_name, g_info);
      END IF;
    END IF;

    l_primary_missing_qty := inv_convert.inv_um_convert(l_mmtt_info.inventory_item_id, NULL, p_missing_quantity, l_mmtt_info.transaction_uom, l_mmtt_info.primary_uom_code, NULL, NULL);


    IF p_lot_control_code = 1 THEN -- Not a Lot Controlled Item
      create_cc_reservations(
        x_return_status       => x_return_status
      , p_organization_id     => l_mmtt_info.organization_id
      , p_inventory_item_id   => l_mmtt_info.inventory_item_id
      , p_reservation_id      => l_mmtt_info.reservation_id
      , p_revision            => l_mmtt_info.revision
      , p_lot_number          => NULL
      , p_subinventory_code   => l_mmtt_info.subinventory_code
      , p_locator_id          => l_mmtt_info.locator_id
      , p_primary_quantity    => l_primary_missing_qty
      , p_primary_uom_code    => l_mmtt_info.primary_uom_code
      --INVCONV kkillams
      , p_secondary_quantity  => p_sec_missing_quantity
      , p_secondary_uom_code  => l_mmtt_info.secondary_uom_code
      --INVCONV kkillams
      );
    ELSE
      l_rem_missing_qty := l_primary_missing_qty;
      FOR curr_lot IN c_unconfirmed_lots LOOP
        l_primary_lot_qty := least(curr_lot.primary_quantity, l_primary_missing_qty);
        l_secondary_lot_qty := least(NVL(curr_lot.secondary_quantity,0), NVL(p_sec_missing_quantity,0)); --INVCONV
        IF l_secondary_lot_qty  = 0 THEN
           l_secondary_lot_qty  :=  NULL;
        END IF;
        create_cc_reservations(
          x_return_status       => x_return_status
        , p_organization_id     => l_mmtt_info.organization_id
        , p_inventory_item_id   => l_mmtt_info.inventory_item_id
        , p_reservation_id      => l_mmtt_info.reservation_id
        , p_revision            => l_mmtt_info.revision
        , p_lot_number          => curr_lot.lot_number
        , p_subinventory_code   => l_mmtt_info.subinventory_code
        , p_locator_id          => l_mmtt_info.locator_id
        , p_primary_quantity    => l_primary_lot_qty
        , p_primary_uom_code    => l_mmtt_info.primary_uom_code
      --INVCONV kkillams
       , p_secondary_quantity  => l_secondary_lot_qty
       , p_secondary_uom_code  => l_mmtt_info.secondary_uom_code
      --INVCONV kkillams
        );
        l_rem_missing_qty := l_rem_missing_qty - l_primary_lot_qty;
        EXIT WHEN l_rem_missing_qty <= 0;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END report_cycle_count;

  PROCEDURE populate_tt_lot(
    x_return_status        OUT NOCOPY VARCHAR2
  , p_transaction_temp_id  IN         NUMBER
  , p_mo_line_id                      NUMBER
  ) IS
    l_api_name  VARCHAR2(30) := 'POPULATE_TABLE';
    l_debug     NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
      print_debug('Populating Temp Table for a Lot Ctrl Item', l_api_name, g_info);
    END IF;

    INSERT INTO mtl_allocations_gtmp(transaction_temp_id, lot_number, transaction_quantity, primary_quantity
                ,secondary_quantity) --INVCONV kkillams
      SELECT p_transaction_temp_id, mtlt.lot_number, SUM(mtlt.transaction_quantity), SUM(mtlt.primary_quantity)
             ,DECODE(SUM(NVL(mtlt.secondary_quantity,0)),0,NULL,SUM(NVL(mtlt.secondary_quantity,0)))  --INVCONV kkillams
        FROM mtl_transaction_lots_temp mtlt
       WHERE p_transaction_temp_id IS NOT NULL
         AND mtlt.transaction_temp_id = p_transaction_temp_id
        GROUP BY mtlt.lot_number
      UNION ALL
      SELECT mmtt.transaction_temp_id, mtlt.lot_number, SUM(mtlt.transaction_quantity), SUM(mtlt.primary_quantity)
            ,DECODE(SUM(NVL(mtlt.secondary_quantity,0)),0,NULL,SUM(NVL(mtlt.secondary_quantity,0)))  --INVCONV kkillams
        FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
       WHERE p_transaction_temp_id IS NULL AND p_mo_line_id IS NOT NULL
         AND mmtt.move_order_line_id = p_mo_line_id
         AND mtlt.transaction_temp_id = mmtt.transaction_temp_id
        GROUP BY mmtt.transaction_temp_id, mtlt.lot_number;

    IF l_debug = 1 THEN
      print_debug('Allocations Temp Table populated with # of records = ' || SQL%ROWCOUNT, l_api_name, g_info);
    END IF;

    IF SQL%ROWCOUNT = 0 THEN
      IF l_debug = 1 THEN
        print_debug('Error: No Records Found for the Given Query Criteria', l_api_name, g_error);
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    IF l_debug = 1 THEN
      print_debug('Populated Temp Table with Lot Information', l_api_name, g_info);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      IF l_debug = 1 THEN
        print_debug('Exception: Unknown Error occurred: SQLCode = ' || SQLCODE, l_api_name, g_exception);
      END IF;
  END populate_tt_lot;

  PROCEDURE populate_tt_serial(
    x_return_status        OUT NOCOPY VARCHAR2
  , p_transaction_temp_id  IN         NUMBER
  , p_mo_line_id                      NUMBER
  ) IS
    l_api_name  VARCHAR2(30) := 'POPULATE_TABLE';
    l_debug     NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
      print_debug('Populating Temp Table for a Serial Ctrl Item', l_api_name, g_info);
    END IF;

    INSERT INTO mtl_allocations_gtmp(transaction_temp_id, serial_number)
      SELECT p_transaction_temp_id, msn.serial_number
        FROM mtl_serial_numbers msn
       WHERE p_transaction_temp_id IS NOT NULL
         AND msn.group_mark_id = p_transaction_temp_id
      UNION ALL
      SELECT mmtt.transaction_temp_id, msn.serial_number
        FROM mtl_material_transactions_temp mmtt, mtl_serial_numbers msn
       WHERE p_transaction_temp_id IS NULL AND p_mo_line_id IS NOT NULL
         AND mmtt.move_order_line_id = p_mo_line_id
         AND msn.group_mark_id = mmtt.transaction_temp_id;

    IF l_debug = 1 THEN
      print_debug('Allocations Temp Table populated with # of records = ' || SQL%ROWCOUNT, l_api_name, g_info);
      print_debug('Populated Temp Table with Serial Information', l_api_name, g_info);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      IF l_debug = 1 THEN
        print_debug('Exception: Unknown Error occurred: SQLCode = ' || SQLCODE, l_api_name, g_exception);
      END IF;
  END populate_tt_serial;

  PROCEDURE populate_tt_lot_serial(
    x_return_status        OUT NOCOPY VARCHAR2
  , p_transaction_temp_id  IN         NUMBER
  , p_mo_line_id                      NUMBER
  ) IS
    l_api_name  VARCHAR2(30) := 'POPULATE_TABLE';
    l_debug     NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
      print_debug('Populating Temp Table for a Lot and Serial Ctrl Item', l_api_name, g_info);
    END IF;

    INSERT INTO mtl_allocations_gtmp(transaction_temp_id, lot_number, serial_number, transaction_quantity, primary_quantity)
      SELECT p_transaction_temp_id, mtlt.lot_number, msn.serial_number, 1, 1
        FROM mtl_transaction_lots_temp mtlt, mtl_serial_numbers msn
       WHERE p_transaction_temp_id IS NOT NULL
         AND mtlt.transaction_temp_id = p_transaction_temp_id
         AND msn.group_mark_id        = mtlt.serial_transaction_temp_id
      UNION ALL
      SELECT mmtt.transaction_temp_id, mtlt.lot_number, msn.serial_number, 1, 1
        FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt, mtl_serial_numbers msn
       WHERE p_transaction_temp_id IS NULL and p_mo_line_id IS NOT NULL
         AND mmtt.move_order_line_id  = p_mo_line_id
         AND mtlt.transaction_temp_id = mmtt.transaction_temp_id
         AND msn.group_mark_id        = mtlt.serial_transaction_temp_id;

    IF l_debug = 1 THEN
      print_debug('Allocations Temp Table populated with # of records = ' || SQL%ROWCOUNT, l_api_name, g_info);
    END IF;

    IF SQL%ROWCOUNT = 0 THEN
      IF l_debug = 1 THEN
        print_debug('No Serial Allocations found. Querying again only for Lot', l_api_name, g_info);
      END IF;
      populate_tt_lot(x_return_status, p_transaction_temp_id, p_mo_line_id);
    END IF;

    IF l_debug = 1 THEN
      print_debug('Populated Temp Table with Lot and Serial Information', l_api_name, g_info);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      IF l_debug = 1 THEN
        print_debug('Exception: Unknown Error occurred: SQLCode = ' || SQLCODE, l_api_name, g_exception);
      END IF;
  END populate_tt_lot_serial;

  PROCEDURE populate_table(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , p_transaction_temp_id            NUMBER
  , p_mo_line_id                     NUMBER
  , p_lot_control_code               NUMBER
  , p_serial_control_code            NUMBER
  ) IS
    l_api_name            VARCHAR2(30) := 'POPULATE_TABLE';
    l_debug               NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
    l_lot_control_code    NUMBER  := p_lot_control_code;
    l_serial_control_code NUMBER  := p_serial_control_code;
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    -- Printing the Input Parameters.
    IF l_debug = 1 THEN
      print_debug('Populating the Allocations Temp Table with Suggested Lots/Serials', l_api_name, g_info);
      print_debug('Transaction Temp ID = ' || p_transaction_temp_id, l_api_name, g_info);
      print_debug('Move Order Line ID  = ' || p_mo_line_id, l_api_name, g_info);
      print_debug('Lot Control Code    = ' || p_lot_control_code, l_api_name, g_info);
      print_debug('Serial Control Code = ' || p_serial_control_code, l_api_name, g_info);
    END IF;

    -- Either Transaction Temp ID or Move Order Line ID has to be passed.
    IF p_transaction_temp_id IS NULL AND p_mo_line_id IS NULL THEN
      IF l_debug = 1 THEN
        print_debug('Error: Either TxnTmpID or MOLineID has to be passed', l_api_name, g_error);
      END IF;
      fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Determining the Item Controls.
    IF p_lot_control_code IS NULL OR p_serial_control_code IS NULL THEN
      get_item_controls(
        x_return_status       => x_return_status
      , x_lot_control_code    => l_lot_control_code
      , x_serial_control_code => l_serial_control_code
      , p_transaction_temp_id => p_transaction_temp_id
      , p_mo_line_id          => p_mo_line_id
      );
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug = 1 THEN
          print_debug('Error: Cannot determine the Item Controls', l_api_name, g_error);
        END IF;
        fnd_message.set_name('INV','INV_INVALID_ITEM_ORG');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- First clear Allocations Temp Table.
    DELETE mtl_allocations_gtmp;

    IF l_lot_control_code = 2 AND l_serial_control_code IN(1, 6) THEN
      populate_tt_lot(x_return_status, p_transaction_temp_id, p_mo_line_id);
    ELSIF l_lot_control_code = 1 AND l_serial_control_code NOT IN(1, 6) THEN
      populate_tt_serial(x_return_status, p_transaction_temp_id, p_mo_line_id);
    ELSIF l_lot_control_code = 2 AND l_serial_control_code NOT IN(1, 6) THEN
      populate_tt_lot_serial(x_return_status, p_transaction_temp_id, p_mo_line_id);
    END IF;
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug = 1 THEN
        print_debug('Error: Not able to Populate the Allocations Temp Table', l_api_name, g_error);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF l_debug = 1 THEN
      print_debug('Allocations Temp Table Populated with the Suggested Lots/Serials', l_api_name, g_info);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
        print_debug('Exception: Expected Error occurred', l_api_name, g_exception);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
        print_debug('Exception: UnExpected Error occurred', l_api_name, g_exception);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      IF l_debug = 1 THEN
        print_debug('Exception: Unknown Error occurred: SQLCode = ' || SQLCODE, l_api_name, g_exception);
      END IF;
  END populate_table;

  PROCEDURE process_action(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , x_new_record_id       OUT NOCOPY NUMBER
  , p_action                         NUMBER
  , p_transaction_temp_id            NUMBER
  , p_remaining_quantity             NUMBER
  , p_remaining_secondary_quantity   NUMBER  --INVCONV KKILLALMS
  , p_lot_control_code               NUMBER
  , p_serial_control_code            NUMBER
  ) AS
    l_api_name            VARCHAR2(30) := 'PROCESS_ACTION';
    l_debug               NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
    l_lot_control_code    NUMBER       := p_lot_control_code;
    l_serial_control_code NUMBER       := p_serial_control_code;
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    -- Printing the Input Parameters.
    IF l_debug = 1 THEN
      print_debug('Processing Missing Qty Action', l_api_name, g_info);
      print_debug('Transaction Temp ID = ' || p_transaction_temp_id, l_api_name, g_info);
      print_debug('Remaining Qty       = ' || p_remaining_quantity, l_api_name, g_info);
      print_debug('Action              = ' || p_action, l_api_name, g_info);
      print_debug('Lot Control Code    = ' || p_lot_control_code, l_api_name, g_info);
      print_debug('Serial Control Code = ' || p_serial_control_code, l_api_name, g_info);
    END IF;

    -- If Missing Qty is Zero then just return.
    IF nvl(p_remaining_quantity, 0) = 0 THEN
      RETURN;
    END IF;

    -- Check whether Transaction Temp ID is not null
    IF p_transaction_temp_id IS NULL THEN
      IF l_debug = 1 THEN
        print_debug('Error: Transaction Temp ID cannot be NULL', l_api_name, g_error);
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Determining the Item Controls.
    IF p_lot_control_code IS NULL OR p_serial_control_code IS NULL THEN
      get_item_controls(
        x_return_status       => x_return_status
      , x_lot_control_code    => l_lot_control_code
      , x_serial_control_code => l_serial_control_code
      , p_transaction_temp_id => p_transaction_temp_id
      , p_mo_line_id          => NULL
      );
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug = 1 THEN
          print_debug('Error: Cannot determine the Item Controls', l_api_name, g_error);
        END IF;
        fnd_message.set_name('INV','INV_INVALID_ITEM_ORG');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    remove_confirmed(
      x_return_status         => x_return_status
    , p_transaction_temp_id   => p_transaction_temp_id
    , p_lot_control_code      => l_lot_control_code
    , p_serial_control_code   => l_serial_control_code
    );

    IF p_action = g_action_backorder THEN
      backorder_only(
        x_return_status       => x_return_status
      , x_msg_data            => x_msg_data
      , x_msg_count           => x_msg_count
      , p_transaction_temp_id => p_transaction_temp_id
      , p_quantity            => p_remaining_quantity
      , p_secondary_quantity  => p_remaining_secondary_quantity --INVCONV kkillams
      );
    ELSIF p_action = g_action_split_allocation THEN
      split_allocation(
        x_return_status       => x_return_status
      , x_msg_data            => x_msg_data
      , x_msg_count           => x_msg_count
      , x_new_txn_temp_id     => x_new_record_id
      , p_transaction_temp_id => p_transaction_temp_id
      , p_split_quantity      => p_remaining_quantity
      , p_lot_control_code    => l_lot_control_code
      , p_serial_control_code => l_serial_control_code
      , p_split_sec_quantity  => p_remaining_secondary_quantity --INVCONV kkillams
      );
    ELSIF p_action = g_action_cycle_count THEN
      report_cycle_count(
        x_return_status        => x_return_status
      , x_msg_data             => x_msg_data
      , x_msg_count            => x_msg_count
      , p_transaction_temp_id  => p_transaction_temp_id
      , p_missing_quantity     => p_remaining_quantity
      , p_lot_control_code     => l_lot_control_code
      , p_sec_missing_quantity => p_remaining_secondary_quantity --INVCONV kkillams
      );
    END IF;
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
        print_debug('Exception: Expected Error occurred', l_api_name, g_exception);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
        print_debug('Exception: Unexpected Error occurred', l_api_name, g_exception);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      IF l_debug = 1 THEN
        print_debug('Exception: Unknown Error occurred: SQLCode = ' || SQLCODE, l_api_name, g_exception);
      END IF;
  END process_action;

PROCEDURE update_allocation_qty
   (
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , p_transaction_temp_id            NUMBER
  , p_confirmed_quantity             NUMBER
  , p_transaction_uom                VARCHAR2
  --INVCONV kkillams
  , p_sec_confirmed_quantity         NUMBER
  , p_secondary_uom_code             VARCHAR2
 --INVCONV kkillams
  )
  IS
l_api_name            VARCHAR2(30) := 'UPDATE_ALLOCATION_QTY';
l_debug               NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
l_confirmed_quantity_primary NUMBER;
l_primary_uom         VARCHAR2(30);
l_inventory_item_id   NUMBER;
l_organization_id     NUMBER;

BEGIN
   x_return_status  := fnd_api.g_ret_sts_success;

   IF l_debug = 1 THEN
      print_debug('Updating Allocation Qty', l_api_name, g_info);
      print_debug('Transaction Temp ID = ' || p_transaction_temp_id, l_api_name, g_info);
      print_debug('Confirmed_quantity       = ' || p_confirmed_quantity, l_api_name, g_info);
    END IF;

   SELECT inventory_item_id, organization_id INTO l_inventory_item_id,l_organization_id
   FROM mtl_material_transactions_temp WHERE transaction_temp_id = p_transaction_temp_id;

   SELECT primary_uom_code INTO l_primary_uom FROM mtl_system_items
   WHERE inventory_item_id =l_inventory_item_id
   AND organization_id =l_organization_id;


   IF l_primary_uom <> p_transaction_uom THEN
      l_confirmed_quantity_primary :=
        inv_convert.inv_um_convert(
                         item_id                    =>    null
                       , precision                  =>    null
                       , from_quantity              =>    p_confirmed_quantity
                       , from_unit                  =>    p_transaction_uom
                       , to_unit	                   =>    l_primary_uom
                       , from_name                  =>    null
                       , to_name	                   =>    null
                       );
      IF ( l_confirmed_quantity_primary < 0 )THEN
        fnd_message.set_name('INV','INV_UOM_CONV_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

   ELSE
    l_confirmed_quantity_primary:=p_confirmed_quantity;
   END IF;

   UPDATE mtl_material_transactions_temp SET transaction_quantity =p_confirmed_quantity
                                             , primary_quantity= l_confirmed_quantity_primary
                                             --INVCONV kkillams
                                             , secondary_uom_code             = p_secondary_uom_code
                                             , secondary_transaction_quantity =  p_sec_confirmed_quantity
                                             --END INVCONV kkillams
                                             WHERE  transaction_temp_id = p_transaction_temp_id;



   EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
        print_debug('Exception: Expected Error occurred', l_api_name, g_exception);
      END IF;
     WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
        print_debug('Exception: Unknown Error occurred: SQLCode = ' || SQLCODE, l_api_name, g_exception);
      END IF;

END update_allocation_qty;

END inv_missing_qty_actions_engine;

/
