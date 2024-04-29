--------------------------------------------------------
--  DDL for Package Body INV_SERIAL_PICK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SERIAL_PICK_PKG" AS
/* $Header: INVSNPIB.pls 120.2.12010000.2 2008/07/29 12:55:00 ptkumar ship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'INV_SERIAL_PICK_PKG';

PROCEDURE DEBUG(p_message       IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
--       inv_debug.message('wshtxn', p_message);
     IF (l_debug = 1) THEN
        inv_trx_util_pub.trace(p_message, 'SNPICK.', 1);
     END IF;
     --dbms_output.put_line(p_message);
-- null;

END;
procedure delete_move_order_reservations(
                            x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
                        ,x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
                        ,p_move_order_line_id NUMBER) IS

l_mtl_reservation_rec inv_reservation_global.mtl_reservation_rec_type;
l_original_serial_number inv_reservation_global.serial_number_tbl_type;
l_txn_source_line_id NUMBER;
l_msg_count  NUMBER;
CURSOR unstaged_reservations_csr(p_source_line_id NUMBER) IS
         SELECT reservation_id
           FROM mtl_reservations
           WHERE nvl(staged_flag,'N') = 'N'
           AND supply_source_type_id = 13
           AND demand_source_type_id in (2,8)
           AND demand_source_line_id = p_source_line_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   BEGIN
   select txn_source_line_id
   into l_txn_source_line_id
   from mtl_txn_request_lines
   where line_id = p_move_order_line_id;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
       IF (l_debug = 1) THEN
          debug('No move order find for line id'||to_char(p_move_order_line_id));
       END IF;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       return;
   END;
   IF (l_debug = 1) THEN
      debug('Cleaning reservations');
   END IF;
   FOR l_unstaged_reservation IN unstaged_reservations_csr(l_txn_source_line_id) LOOP
         l_mtl_reservation_rec.reservation_id := l_unstaged_reservation.reservation_id;

         IF (l_debug = 1) THEN
            debug('Deleting reservation: ' || l_unstaged_reservation.reservation_id);
         END IF;

         inv_reservation_pub.delete_reservation
           (p_api_version_number        => 1.0,
            p_init_msg_lst              => fnd_api.g_true,
            x_return_status             => x_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => x_msg_data,
            p_rsv_rec                   => l_mtl_reservation_rec,
            p_serial_number             => l_original_serial_number);

         IF (l_debug = 1) THEN
            debug('after delete reservation return status is ' || x_return_status);
            debug('Message'||x_msg_data);
         END IF;
         IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
END;


procedure delete_move_order_allocation(
			 x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
			,x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
			,p_move_order_line_id NUMBER) IS
l_txn_source_line_id  number;
l_msg_count   number;
l_return_status VARCHAR2(1);
l_msg_data VARCHAR2(2000);
l_unstaged_so_exists NUMBER := 0;
/*
l_mtl_reservation_rec inv_reservation_global.mtl_reservation_rec_type;
l_original_serial_number inv_reservation_global.serial_number_tbl_type;

CURSOR unstaged_reservations_csr(p_source_line_id NUMBER) IS
 	 SELECT reservation_id
	   FROM mtl_reservations
	   WHERE nvl(staged_flag,'N') = 'N'
	   AND supply_source_type_id = 13
	   AND demand_source_type_id in (2,8)
	   AND demand_source_line_id = p_source_line_id;
     */

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- clean up the marks for the serial numbers
   update mtl_serial_numbers
   set group_mark_id = null
   where serial_number in (select fm_serial_number
                           from mtl_serial_numbers_temp msnt,
                                mtl_transaction_lots_temp mtlt,
                                mtl_material_transactions_temp mmtt
                           where mmtt.move_order_line_id = p_move_order_line_id
                             and mtlt.transaction_temp_id = mmtt.transaction_temp_id
                             and msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
                           UNION
                           select fm_serial_number
                           from mtl_serial_numbers_temp msnt,
                                mtl_material_transactions_temp mmtt
                           where mmtt.move_order_line_id = p_move_order_line_id
                             and msnt.transaction_temp_id = mmtt.transaction_temp_id);

   delete from mtl_serial_numbers_temp
   where transaction_temp_id in (select transaction_temp_id
                                 from mtl_material_transactions_temp mmtt
                                 where mmtt.move_order_line_id = p_move_order_line_id
                                 UNION
                                 select mtlt.serial_transaction_temp_id
                                 from mtl_material_transactions_temp mmtt,
                                      mtl_transaction_lots_temp mtlt
                                 where mmtt.move_order_line_id = p_move_order_line_id
                                   and mtlt.transaction_temp_id = mmtt.transaction_temp_id);

   delete from mtl_transaction_lots_temp
   where transaction_temp_id in (select transaction_temp_id
                                 from mtl_material_transactions_temp mmtt
                                 where mmtt.move_order_line_id = p_move_order_line_id);

   delete from mtl_material_transactions_temp
   where move_order_line_id = p_move_order_line_id;
EXCEPTION
   WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
END;

procedure process_serial_picking(
			x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
			x_error_msg          OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
			p_initial_serial        IN  VARCHAR2,
			p_organization_id       IN  NUMBER,
			p_move_order_line_id    IN  NUMBER,
			p_serial_number         IN  VARCHAR2,
			p_inventory_item_id     IN  NUMBER,
			p_revision              IN  VARCHAR2,
			p_subinventory_code     IN  VARCHAR2,
			p_locator_id            IN  NUMBER,
			p_to_subinventory_code  IN  VARCHAR2,
			p_to_locator_id         IN  NUMBER,
			p_reason_id             IN  NUMBER,
			p_lot_number            IN  VARCHAR2,
			p_wms_installed         IN  VARCHAR2,
			p_transaction_action_id IN  NUMBER,
			p_transaction_type_id   IN  VARCHAR2,
			p_source_type_id        IN  NUMBER,
			p_user_id               IN  NUMBER
			) IS
  CURSOR MMTT_TEMP_ID is
     select transaction_temp_id,transaction_quantity
     from mtl_material_transactions_temp
     where move_order_line_id = p_move_order_line_id;

 l_mmtt_rec  mtl_material_transactions_temp%ROWTYPE;
 l_trx_temp_id  NUMBER;
 l_new_temp_id  NUMBER;
 l_serial_temp_id NUMBER;
 l_return_result NUMBER;
 l_status_allowed VARCHAR2(1);
 l_item_name   VARCHAR2(300);
 l_msg_count NUMBER;
 l_msg_data  VARCHAR2(2000);
 l_trx_source_line_id  NUMBER;
 l_trx_source_id NUMBER;

 l_is_revision_control BOOLEAN;
 l_is_lot_control      BOOLEAN;

 l_tree_mode           NUMBER := inv_quantity_tree_pub.g_transaction_mode;
 l_quantity_type       NUMBER := inv_quantity_tree_pvt.g_qoh;
 l_onhand_source       NUMBER := inv_quantity_tree_pvt.g_all_subs;
 l_qoh                 NUMBER;
 l_rqoh                NUMBER;
 l_qr                  NUMBER;
 l_qs                  NUMBER;
 l_att                 NUMBER;
 l_atr                 NUMBER;

 l_serial_number        VARCHAR2(30);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
 l_lot_number   	VARCHAR2(80);
 l_revision             VARCHAR2(30);
 l_locator_id     	NUMBER;
 l_to_locator_id        NUMBER;
 l_reason_id            NUMBER;
 l_lot_expiration_date  DATE;
 l_period_id            NUMBER;
 -- Bug 7190635
 l_ato_item                NUMBER  := 0;
 l_retain_ato_profile VARCHAR2(1)  := NVL(fnd_profile.VALUE('WSH_RETAIN_ATO_RESERVATIONS'),'N');
 l_rsv_rec                 inv_reservation_global.mtl_reservation_rec_type;
 l_rsv_tbl                 inv_reservation_global.mtl_reservation_tbl_type;
 l_update_rec              inv_reservation_global.mtl_reservation_rec_type;
 l_error_code              NUMBER;
 l_rsv_count               NUMBER;
 l_prim_quantity_to_delete NUMBER;
 l_return_status           VARCHAR2(1);
 l_dummy_sn                inv_reservation_global.serial_number_tbl_type;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 -- Bug 7190635, Adding new cursor to fetch reservation id based on move order line id.
 CURSOR mrsv_record is
 SELECT MRSV.*
 FROM   MTL_RESERVATIONS MRSV, MTL_TXN_REQUEST_LINES MTRL
 WHERE  MTRL.LINE_ID                        = P_MOVE_ORDER_LINE_ID
 AND    MTRL.TXN_SOURCE_LINE_ID             = MRSV.DEMAND_SOURCE_LINE_ID
 AND    Nvl(MRSV.inventory_item_id,'-9999') = Nvl(p_inventory_item_id,'-9999')
 AND    Nvl(MRSV.subinventory_code,'@@@@')  = Nvl(p_subinventory_code,'@@@@')
 AND    NVL(MRSV.locator_id,'-9999')        = NVL(l_locator_id,'-9999')
 AND    Nvl(MRSV.revision,'@@@@')           = Nvl(l_revision,'@@@@')
 AND    Nvl(MRSV.LOT_NUMBER,'@@@@')         = Nvl(l_lot_number,'@@@@')
 AND    ROWNUM=1;
 BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   if (p_serial_number = 'NULL') then l_serial_number :=null;
   else l_serial_number := p_serial_number; end if;
   if (p_lot_number = 'NULL') then l_lot_number :=null;
   else l_lot_number := p_lot_number; end if;
   if (p_revision = 'NULL') then l_revision := null;
   else l_revision := p_revision; end if;
   if (p_locator_id = 0) then l_locator_id :=null;
   else l_locator_id := p_locator_id; end if;
   if (p_to_locator_id = 0) then l_to_locator_id :=null;
   else l_to_locator_id := p_to_locator_id; end if;
   if (p_reason_id = 0) then l_reason_id :=null;
   else l_reason_id := p_reason_id; end if;

   IF (l_debug = 1) THEN
      debug('locator id:'||to_char(l_locator_id));
      debug ('1:' ||p_initial_serial);
      debug ('2:' ||p_organization_id);
      debug ('3:' ||p_move_order_line_id );
   	debug ('4:' ||p_serial_number       );
   	debug ('5:' ||p_inventory_item_id    );
   	debug ('6:' ||p_revision              );
   	debug ('7:' ||p_subinventory_code    );
   	debug ('8:' ||p_locator_id            );
   	debug ('9:' ||p_to_subinventory_code);
   	debug ('10:' ||p_to_locator_id       );
   	debug ('11:' ||p_reason_id            );
   	debug ('12:' ||p_lot_number         );
   	debug ('13:' ||p_wms_installed       );
   	debug ('14:' ||p_transaction_action_id);
   	debug ('15:' ||p_transaction_type_id   );
   	debug ('16:' ||p_source_type_id      );
   END IF;

   -- add the status checking and qty checking here

   -- Check if the serial number is available to be transacted for this transaction
/* this has been checked in the serial LOV
   l_status_allowed := inv_material_status_grp.is_status_applicable
                                   (p_wms_installed         => p_wms_installed,
                                    p_trx_status_enabled    => NULL,
                                    p_trx_type_id           => p_transaction_type_id,
                                    p_lot_status_enabled    => NULL,
                                    p_serial_status_enabled => NULL,
                                    p_organization_id       => p_organization_id,
                                    p_inventory_item_id     => p_inventory_item_id,
                                    p_sub_code              => p_subinventory_code,
                                    p_locator_id            => l_locator_id,
                                    p_lot_number            => l_lot_number,
                                    p_serial_number         => l_serial_number,
                                    p_object_type           => 'A');

   IF (l_debug = 1) THEN
      inv_log_util.trace('Status Allowed: ' || l_status_allowed, 'SNPICK');
   END IF;
   IF l_status_allowed <> 'Y' THEN
      select concatenated_segments
      into l_item_name
      from mtl_system_items_kfv
      where inventory_item_id = p_inventory_item_id
        and organization_id = p_organization_id;

      fnd_message.set_name('INV', 'INV_TRX_SER_NA_DUE_MS');
      fnd_message.set_token('TOKEN1', p_serial_number);
      fnd_message.set_token('TOKEN2', l_item_name);
      x_error_msg := fnd_message.get;
      RAISE fnd_api.g_exc_error;
   END IF;
  */

    SAVEPOINT process_serial;


   -- check lot expiration date. if it is already expired, can't pick it
   if (l_lot_number is not null ) then
     BEGIN
        SELECT expiration_date INTO l_lot_expiration_date
          FROM mtl_lot_numbers
          WHERE inventory_item_id = p_inventory_item_id
          AND organization_id = p_organization_id
          AND lot_number = l_lot_number;
        --
        IF l_lot_expiration_date IS NOT NULL
          AND l_lot_expiration_date < Sysdate THEN
           fnd_message.set_name('INV', 'INV_LOT_EXPIRED');
           x_error_msg := fnd_message.get;
           RAISE fnd_api.g_exc_error;
        END IF;
        --
     EXCEPTION
        WHEN NO_DATA_FOUND then
           fnd_message.set_name('INV','INVALID_LOT');
           x_error_msg := fnd_message.get;
        RAISE fnd_api.g_exc_error;
     END;
   END IF;


   -- reserve the first record to act as a base when inserting the record
   select * into l_mmtt_rec
   from mtl_material_transactions_temp
   where move_order_line_id = p_move_order_line_id
     and rownum = 1;



   -- check available qty to see if the location where serial is has the availability
 if (l_lot_number is not null ) then
    l_is_lot_control := TRUE;
    IF (l_debug = 1) THEN
       debug('Lot controlled');
    END IF;
 ELSE
    l_is_lot_control := FALSE;
 END IF;

 IF l_revision is not null THEN
     IF (l_debug = 1) THEN
        debug('revision controlled');
     END IF;
     l_is_revision_control := TRUE;
  ELSE
    l_is_revision_control := FALSE;
 END IF;

 -- Bug 7190635, The Reservation was getting deleted for ato items without check against the
 --   WSH: Retain ATO Reservation profile.Check if the profile is set to yes and if ATO item,
  --   the reservation needs to be updated

 --Checking whether item is ATO item for the profile option ATO RETAIN RESERVATION 7190635
 IF l_retain_ato_profile = 'Y' THEN
    BEGIN
       SELECT  1
         INTO  l_ato_item
         FROM  mtl_system_items msi
         WHERE msi.inventory_item_id = p_inventory_item_id
         AND   msi.organization_id = p_organization_id
         AND   msi.replenish_to_order_flag ='Y'
         AND   msi.bom_item_type = 4;
    EXCEPTION
       WHEN no_data_found then
           l_ato_item := 0;
    END;
 END IF;

 IF (l_debug = 1) THEN
    debug('l_ato_item is:'||l_ato_item);
 END IF;

 IF l_ato_item <> 1 THEN
 -- to make the ATT accurate, delete the reservation first
    if p_initial_serial = 'Y' then
            -- delete reservation and allocation
            for l_transaction_rec in MMTT_TEMP_ID   LOOP
                INV_MO_Cancel_PVT.reduce_rsv_allocation( x_return_status => x_return_status
                  ,x_msg_count => l_msg_count
                  ,x_msg_data  => x_error_msg
                  ,p_transaction_temp_id =>l_transaction_rec.transaction_temp_id
                  ,p_quantity_to_delete =>l_transaction_rec.transaction_quantity);
                if (x_return_status <> fnd_api.g_ret_sts_success) then
                     IF (l_debug = 1) THEN
                        debug('Error from reducing reservations');
                     END IF;
                     RAISE fnd_api.g_exc_unexpected_error;
                end if;
           end LOOP;
           -- clean up the qty tree cache so that the qty tree can be rebuild
           inv_quantity_tree_pub.clear_quantity_cache;
    end if; --p_initial_serial
 ELSIF l_ato_item = 1 THEN
    if p_initial_serial = 'Y' then
       FOR l_transaction_rec in MMTT_TEMP_ID   LOOP

          IF (l_debug = 1) THEN
             debug('Calling reduce_rsv_allocation for ato item for transaction_temp_id:'||l_transaction_rec.transaction_temp_id);
          END IF;
          -- Bug 7190635, Currently we are deleting entire reservations which is not correct for ATO items
          -- so we will not reduce reservation here. We will just delete entire allocations here
          -- and reduce the reservations at later.
          INV_MO_Cancel_PVT.reduce_rsv_allocation(
                     x_return_status       => x_return_status
                   , x_msg_count           => l_msg_count
                   , x_msg_data            => x_error_msg
                   , p_transaction_temp_id => l_transaction_rec.transaction_temp_id
                   , p_quantity_to_delete  => 0
                   , p_ato_serial_pick     =>'Y');
          if (x_return_status <> fnd_api.g_ret_sts_success) then
             IF (l_debug = 1) THEN
                debug('Error from reducing reservations');
             END IF;
             RAISE fnd_api.g_exc_unexpected_error;
          end if;
       END LOOP;
    END if;
 END IF; -- l_ato_item <> 1

    --  7190635 Reducing reservations for 1 qty. for an ATO item when the profile is set.
    --  Here reservation_id will be queried based on Demand Source Line Id and then will
    --  process so that only 1 qty of reservation will be reduced*/
    If l_ato_item = 1 then
       FOR l_reservation_rec in mrsv_record LOOP
          l_prim_quantity_to_delete          := 1;
          l_rsv_rec.reservation_id           := l_reservation_rec.reservation_id;
          IF (l_debug = 1) THEN
             DEBUG('query reservation');
          END IF;

          -- query reservation
          inv_reservation_pvt.query_reservation(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_true
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , p_query_input                => l_rsv_rec
          , x_mtl_reservation_tbl        => l_rsv_tbl
          , x_mtl_reservation_tbl_count  => l_rsv_count
          , x_error_code                 => l_error_code
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              DEBUG('Query reservation returned  error');
            END IF;
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              DEBUG('Query reservation returned unexpected error');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          l_update_rec                       := l_rsv_tbl(1);

          -- update detailed quantity
          IF l_update_rec.detailed_quantity > l_prim_quantity_to_delete THEN
            l_update_rec.detailed_quantity  := l_update_rec.detailed_quantity - l_prim_quantity_to_delete;
          ELSE
            l_update_rec.detailed_quantity  := 0;
          END IF;

          l_update_rec.reservation_quantity  := NULL;

          --set primary reservation quantity
          IF l_update_rec.primary_reservation_quantity > l_prim_quantity_to_delete THEN
            l_update_rec.primary_reservation_quantity  := l_update_rec.primary_reservation_quantity - l_prim_quantity_to_delete;
          ELSE -- delete entire reservation
            l_update_rec.primary_reservation_quantity  := 0;
          END IF;

          IF (l_debug = 1) THEN
            DEBUG('update reservation');
          END IF;

          -- update reservations
          inv_reservation_pub.update_reservation(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_true
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , p_original_rsv_rec           => l_rsv_tbl(1)
          , p_to_rsv_rec                 => l_update_rec
          , p_original_serial_number     => l_dummy_sn
          , p_to_serial_number           => l_dummy_sn
          , p_validation_flag            => fnd_api.g_true
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              DEBUG('Update reservation returned error');
            END IF;

            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              DEBUG('Update reservation returned unexpected error');
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END LOOP;
    END IF;
    -- End of Bug 7190635

IF (l_debug = 1) THEN
   debug('before Query Tree');
   debug ('p_organization_id:' ||p_organization_id);
   debug ('p_inventory_item_id:' ||p_inventory_item_id    );
   debug ('l_tree_mode:' ||l_tree_mode    );
   debug ('l_revision:' ||l_revision              );
   debug ('l_lot_number:' ||l_lot_number            );
   debug ('p_subinventory_code:' ||p_subinventory_code);
   debug ('l_locator_id:' ||l_locator_id       );
END IF;


 -- Query the quantity tree for available to transact quantity
 inv_quantity_tree_pub.query_quantities
   (p_api_version_number    =>   1.0,
    p_init_msg_lst          =>   fnd_api.g_false,
    x_return_status         =>   x_return_status,
    x_msg_count             =>   l_msg_count,
    x_msg_data              =>   l_msg_data,
    p_organization_id       =>   p_organization_id,
    p_inventory_item_id     =>   p_inventory_item_id,
    p_tree_mode             =>   l_tree_mode,
    p_is_revision_control   =>   l_is_revision_control,
    p_is_lot_control        =>   l_is_lot_control,
    p_is_serial_control     =>   TRUE,
--    p_demand_source_type_id =>   p_source_type_id,
--    p_demand_source_header_id => l_trx_source_id,
--    p_demand_source_line_id => l_trx_source_line_id,
    p_revision              =>   l_revision,
    p_lot_number            =>   l_lot_number,
    p_subinventory_code     =>   p_subinventory_code,
    p_locator_id            =>   l_locator_id,
    x_qoh                   =>   l_qoh,
    x_rqoh                  =>   l_rqoh,
    x_qr                    =>   l_qr,
    x_qs                    =>   l_qs,
    x_att                   =>   l_att,
    x_atr                   =>   l_atr);
IF (l_debug = 1) THEN
   debug('after query:');
   debug ('l_qoh:' ||l_qoh);
   debug ('l_rqoh:' ||l_rqoh);
   debug ('l_qr:' ||l_qr );
   debug ('l_qs:' ||l_qs       );
   debug ('l_att:' ||l_att    );
   debug ('l_atr:' ||l_atr              );
END IF;

 IF x_return_status <> fnd_api.g_ret_sts_success THEN
    FND_MESSAGE.set_name('INV', 'INV_ERR_CREATETREE');
    FND_MESSAGE.set_token('ROUTINE','INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
    x_error_msg := fnd_message.get;

    RAISE fnd_api.g_exc_unexpected_error;
END IF;
IF (l_debug = 1) THEN
   inv_log_util.trace('ATT: ' || l_att, 'SNPICK');
END IF;

IF l_att > 0 THEN
 -- Update the quantity tree so that the serial transaction is
 -- reflected in the available quantity
 inv_quantity_tree_pub.update_quantities
   (p_api_version_number        => 1.0,
    p_init_msg_lst              => fnd_api.g_false,
    x_return_status             => x_return_status,
    x_msg_count                 => l_msg_count,
    x_msg_data                  => l_msg_data,
    p_organization_id           => p_organization_id,
    p_inventory_item_id         => p_inventory_item_id,
    p_tree_mode                 => l_tree_mode,
    p_is_revision_control       => l_is_revision_control,
    p_is_lot_control            => l_is_lot_control,
    p_is_serial_control         => TRUE,
--    p_demand_source_type_id     => p_source_type_id,
--    p_demand_source_header_id => l_trx_source_id,
--    p_demand_source_line_id => l_trx_source_line_id,
    p_revision                  => l_revision,
    p_lot_number                => l_lot_number,
    p_subinventory_code         => p_subinventory_code,
    p_locator_id                => l_locator_id,
    p_primary_quantity          => -1,
    p_quantity_type             => l_quantity_type,
    p_onhand_source             => l_onhand_source,
    x_qoh                       => l_qoh,
    x_rqoh                      => l_rqoh,
    x_qr                        => l_qr,
    x_qs                        => l_qs,
    x_att                       => l_att,
    x_atr                       => l_atr);

 IF x_return_status <> fnd_api.g_ret_sts_success THEN
    FND_MESSAGE.set_name('INV', 'INV_ERR_CREATETREE');
    FND_MESSAGE.set_token('ROUTINE','INV_QUANTITY_TREE_PUB.UPDATE_QUANTITIES');
    x_error_msg := fnd_message.get;
    RAISE fnd_api.g_exc_unexpected_error;
 END IF;
 IF (l_debug = 1) THEN
    debug('ATT in source: ' || l_att);
 END IF;

 -- update the destionation qty   bug # 2470050
inv_quantity_tree_pub.update_quantities
   (p_api_version_number        => 1.0,
    p_init_msg_lst              => fnd_api.g_false,
    x_return_status             => x_return_status,
    x_msg_count                 => l_msg_count,
    x_msg_data                  => l_msg_data,
    p_organization_id           => p_organization_id,
    p_inventory_item_id         => p_inventory_item_id,
    p_tree_mode                 => l_tree_mode,
    p_is_revision_control       => l_is_revision_control,
    p_is_lot_control            => l_is_lot_control,
    p_is_serial_control         => TRUE,
--    p_demand_source_type_id     => p_source_type_id,
--    p_demand_source_header_id => l_trx_source_id,
--    p_demand_source_line_id => l_trx_source_line_id,
    p_revision                  => l_revision,
    p_lot_number                => l_lot_number,
    p_subinventory_code         => p_to_subinventory_code,
    p_locator_id                => l_to_locator_id,
    p_primary_quantity          => 1,
    p_quantity_type             => l_quantity_type,
    p_onhand_source             => l_onhand_source,
    x_qoh                       => l_qoh,
    x_rqoh                      => l_rqoh,
    x_qr                        => l_qr,
    x_qs                        => l_qs,
    x_att                       => l_att,
    x_atr                       => l_atr);

 IF x_return_status <> fnd_api.g_ret_sts_success THEN
    FND_MESSAGE.set_name('INV', 'INV_ERR_CREATETREE');
    FND_MESSAGE.set_token('ROUTINE','INV_QUANTITY_TREE_PUB.UPDATE_QUANTITIES');
    x_error_msg := fnd_message.get;
    RAISE fnd_api.g_exc_unexpected_error;
 END IF;

ELSE
  x_return_status := fnd_api.g_ret_sts_unexp_error;
  FND_MESSAGE.set_name('INV', 'INV_SERIAL_EXCEED_AVAILABLE');
  x_error_msg := fnd_message.get;
  RAISE fnd_api.g_exc_error;
END IF;

-- process the serial number

SELECT mtl_material_transactions_s.NEXTVAL
     INTO l_new_temp_id
     FROM  dual;

IF (l_debug = 1) THEN
   debug('serial number:'||p_serial_number);
END IF;

--Bug 3940938, getting the account_period_id for sysdate and stamping transaction_date
--as sysdate with the respective period_id on MMTT.
INV_INV_LOVS.tdatechk(p_org_id => p_organization_id,
	              p_transaction_date => sysdate,
	              x_period_id => l_period_id);

IF (l_debug = 1) THEN
   debug('l_period_id: '||l_period_id);
END IF;

IF (l_period_id = -1 or l_period_id = 0) THEN
   x_return_status := fnd_api.g_ret_sts_error;
   FND_MESSAGE.SET_NAME('INV', 'INV_NO_OPEN_PERIOD');
   x_error_msg := fnd_message.get;
   RAISE fnd_api.g_exc_error;
END IF;

-- insert a new record for the new serial number
INSERT INTO MTL_MATERIAL_TRANSACTIONS_TEMP
     (
       TRANSACTION_HEADER_ID
       , TRANSACTION_TEMP_ID
       , SOURCE_CODE
       , SOURCE_LINE_ID
       , TRANSACTION_MODE
       , LOCK_FLAG
       , LAST_UPDATE_DATE
       , LAST_UPDATED_BY
       , CREATION_DATE
       , CREATED_BY
       , LAST_UPDATE_LOGIN
       , REQUEST_ID
       , PROGRAM_APPLICATION_ID
       , PROGRAM_ID
       , PROGRAM_UPDATE_DATE
       , INVENTORY_ITEM_ID
       , REVISION
       , ORGANIZATION_ID
       , SUBINVENTORY_CODE
       , LOCATOR_ID
       , TRANSACTION_QUANTITY
       , PRIMARY_QUANTITY
       , TRANSACTION_UOM
       , TRANSACTION_COST
       , TRANSACTION_TYPE_ID
       , TRANSACTION_ACTION_ID
       , TRANSACTION_SOURCE_TYPE_ID
       , TRANSACTION_SOURCE_ID
       , TRANSACTION_SOURCE_NAME
       , TRANSACTION_DATE
       , ACCT_PERIOD_ID
       , DISTRIBUTION_ACCOUNT_ID
       , TRANSACTION_REFERENCE
       , REQUISITION_LINE_ID
       , REQUISITION_DISTRIBUTION_ID
       , REASON_ID
       , LOT_NUMBER
       , LOT_EXPIRATION_DATE
       , SERIAL_NUMBER
       , RECEIVING_DOCUMENT
       , DEMAND_ID
       , RCV_TRANSACTION_ID
       , MOVE_TRANSACTION_ID
       , COMPLETION_TRANSACTION_ID
       , WIP_ENTITY_TYPE
       , SCHEDULE_ID
       , REPETITIVE_LINE_ID
       , EMPLOYEE_CODE
       , PRIMARY_SWITCH
       , SCHEDULE_UPDATE_CODE
       , SETUP_TEARDOWN_CODE
       , ITEM_ORDERING
       , NEGATIVE_REQ_FLAG
       , OPERATION_SEQ_NUM
       , PICKING_LINE_ID
       , TRX_SOURCE_LINE_ID
       , TRX_SOURCE_DELIVERY_ID
       , PHYSICAL_ADJUSTMENT_ID
       , CYCLE_COUNT_ID
       , RMA_LINE_ID
       , CUSTOMER_SHIP_ID
       , CURRENCY_CODE
       , CURRENCY_CONVERSION_RATE
       , CURRENCY_CONVERSION_TYPE
       , CURRENCY_CONVERSION_DATE
       , USSGL_TRANSACTION_CODE
       , VENDOR_LOT_NUMBER
       , ENCUMBRANCE_ACCOUNT
       , ENCUMBRANCE_AMOUNT
       , SHIP_TO_LOCATION
       , SHIPMENT_NUMBER
       , TRANSFER_COST
       , TRANSPORTATION_COST
       , TRANSPORTATION_ACCOUNT
       , FREIGHT_CODE
       , CONTAINERS
       , WAYBILL_AIRBILL
       , EXPECTED_ARRIVAL_DATE
       , TRANSFER_SUBINVENTORY
       , TRANSFER_ORGANIZATION
       , TRANSFER_TO_LOCATION
       , NEW_AVERAGE_COST
       , VALUE_CHANGE
       , PERCENTAGE_CHANGE
       , MATERIAL_ALLOCATION_TEMP_ID
       , DEMAND_SOURCE_HEADER_ID
       , DEMAND_SOURCE_LINE
       , DEMAND_SOURCE_DELIVERY
       , ITEM_SEGMENTS
       , ITEM_DESCRIPTION
       , ITEM_TRX_ENABLED_FLAG
       , ITEM_LOCATION_CONTROL_CODE
       , ITEM_RESTRICT_SUBINV_CODE
       , ITEM_RESTRICT_LOCATORS_CODE
       , ITEM_REVISION_QTY_CONTROL_CODE
       , ITEM_PRIMARY_UOM_CODE
       , ITEM_UOM_CLASS
       , ITEM_SHELF_LIFE_CODE
       , ITEM_SHELF_LIFE_DAYS
       , ITEM_LOT_CONTROL_CODE
       , ITEM_SERIAL_CONTROL_CODE
       , ITEM_INVENTORY_ASSET_FLAG
       , ALLOWED_UNITS_LOOKUP_CODE
       , DEPARTMENT_ID
       , DEPARTMENT_CODE
       , WIP_SUPPLY_TYPE
       , SUPPLY_SUBINVENTORY
       , SUPPLY_LOCATOR_ID
       , VALID_SUBINVENTORY_FLAG
       , VALID_LOCATOR_FLAG
       , LOCATOR_SEGMENTS
       , CURRENT_LOCATOR_CONTROL_CODE
       , NUMBER_OF_LOTS_ENTERED
       , WIP_COMMIT_FLAG
       , NEXT_LOT_NUMBER
       , LOT_ALPHA_PREFIX
       , NEXT_SERIAL_NUMBER
       , SERIAL_ALPHA_PREFIX
       , SHIPPABLE_FLAG
       , POSTING_FLAG
       , REQUIRED_FLAG
       , PROCESS_FLAG
       , ERROR_CODE
       , ERROR_EXPLANATION
       , ATTRIBUTE_CATEGORY
       , ATTRIBUTE1
       , ATTRIBUTE2
       , ATTRIBUTE3
       , ATTRIBUTE4
       , ATTRIBUTE5
       , ATTRIBUTE6
       , ATTRIBUTE7
       , ATTRIBUTE8
       , ATTRIBUTE9
       , ATTRIBUTE10
       , ATTRIBUTE11
       , ATTRIBUTE12
       , ATTRIBUTE13
       , ATTRIBUTE14
       , ATTRIBUTE15
       , MOVEMENT_ID
       , RESERVATION_QUANTITY
       , SHIPPED_QUANTITY
       , TRANSACTION_LINE_NUMBER
       , TASK_ID
       , TO_TASK_ID
       , SOURCE_TASK_ID
       , PROJECT_ID
       , SOURCE_PROJECT_ID
       , PA_EXPENDITURE_ORG_ID
       , TO_PROJECT_ID
       , EXPENDITURE_TYPE
       , FINAL_COMPLETION_FLAG
       , TRANSFER_PERCENTAGE
       , TRANSACTION_SEQUENCE_ID
       , MATERIAL_ACCOUNT
       , MATERIAL_OVERHEAD_ACCOUNT
       , RESOURCE_ACCOUNT
       , OUTSIDE_PROCESSING_ACCOUNT
       , OVERHEAD_ACCOUNT
       , FLOW_SCHEDULE
       , COST_GROUP_ID
       , DEMAND_CLASS
       , QA_COLLECTION_ID
       , KANBAN_CARD_ID
       , OVERCOMPLETION_TRANSACTION_ID
       , OVERCOMPLETION_PRIMARY_QTY
       , OVERCOMPLETION_TRANSACTION_QTY
       , END_ITEM_UNIT_NUMBER
       , SCHEDULED_PAYBACK_DATE
       , LINE_TYPE_CODE
       , PARENT_TRANSACTION_TEMP_ID
       , PUT_AWAY_STRATEGY_ID
       , PUT_AWAY_RULE_ID
       , PICK_STRATEGY_ID
       , PICK_RULE_ID
       , COMMON_BOM_SEQ_ID
       , COMMON_ROUTING_SEQ_ID
       , COST_TYPE_ID
       , ORG_COST_GROUP_ID
       , MOVE_ORDER_LINE_ID
       , TASK_GROUP_ID
       , PICK_SLIP_NUMBER
       , RESERVATION_ID
       , TRANSACTION_STATUS
       , TRANSFER_COST_GROUP_ID
       , LPN_ID
       , transfer_lpn_id
       , content_lpn_id
       , cartonization_id
       , standard_operation_id
       , wms_task_type
       , task_priority
       , container_item_id
     ) VALUES
     (
      l_mmtt_rec.TRANSACTION_HEADER_ID
      , l_new_temp_id
      , l_mmtt_rec.SOURCE_CODE
      , l_mmtt_rec.SOURCE_LINE_ID
      , l_mmtt_rec.TRANSACTION_MODE
      , l_mmtt_rec.LOCK_FLAG
      , sysdate
      , p_user_id
      , sysdate
      , p_user_id
      , l_mmtt_rec.LAST_UPDATE_LOGIN
      , l_mmtt_rec.REQUEST_ID
      , l_mmtt_rec.PROGRAM_APPLICATION_ID
      , l_mmtt_rec.PROGRAM_ID
      , l_mmtt_rec.PROGRAM_UPDATE_DATE
      , l_mmtt_rec.INVENTORY_ITEM_ID
      , l_REVISION
      , P_ORGANIZATION_ID
      , P_SUBINVENTORY_CODE
      , decode(P_LOCATOR_ID,0,null, P_LOCATOR_ID)
      , 1
      , 1
      , l_mmtt_rec.TRANSACTION_UOM
      , l_mmtt_rec.TRANSACTION_COST
      , l_mmtt_rec.TRANSACTION_TYPE_ID
      , l_mmtt_rec.TRANSACTION_ACTION_ID
      , l_mmtt_rec.TRANSACTION_SOURCE_TYPE_ID
      , l_mmtt_rec.TRANSACTION_SOURCE_ID
      , l_mmtt_rec.TRANSACTION_SOURCE_NAME
      , sysdate --, l_mmtt_rec.TRANSACTION_DATE
      , l_period_id --l_mmtt_rec.ACCT_PERIOD_ID
     , l_mmtt_rec.DISTRIBUTION_ACCOUNT_ID
     , l_mmtt_rec.TRANSACTION_REFERENCE
     , l_mmtt_rec.REQUISITION_LINE_ID
     , l_mmtt_rec.REQUISITION_DISTRIBUTION_ID
     , l_REASON_ID
     , l_mmtt_rec.LOT_NUMBER
     , l_mmtt_rec.LOT_EXPIRATION_DATE
     , l_mmtt_rec.SERIAL_NUMBER
     , l_mmtt_rec.RECEIVING_DOCUMENT
     , l_mmtt_rec.DEMAND_ID
     , l_mmtt_rec.RCV_TRANSACTION_ID
     , l_mmtt_rec.MOVE_TRANSACTION_ID
     , l_mmtt_rec.COMPLETION_TRANSACTION_ID
     , l_mmtt_rec.WIP_ENTITY_TYPE
     , l_mmtt_rec.SCHEDULE_ID
     , l_mmtt_rec.REPETITIVE_LINE_ID
     , l_mmtt_rec.EMPLOYEE_CODE
     , l_mmtt_rec.PRIMARY_SWITCH
     , l_mmtt_rec.SCHEDULE_UPDATE_CODE
     , l_mmtt_rec.SETUP_TEARDOWN_CODE
     , l_mmtt_rec.ITEM_ORDERING
     , l_mmtt_rec.NEGATIVE_REQ_FLAG
       , l_mmtt_rec.OPERATION_SEQ_NUM
       , l_mmtt_rec.PICKING_LINE_ID
       , l_mmtt_rec.TRX_SOURCE_LINE_ID
       , l_mmtt_rec.TRX_SOURCE_DELIVERY_ID
       , l_mmtt_rec.PHYSICAL_ADJUSTMENT_ID
       , l_mmtt_rec.CYCLE_COUNT_ID
       , l_mmtt_rec.RMA_LINE_ID
       , l_mmtt_rec.CUSTOMER_SHIP_ID
       , l_mmtt_rec.CURRENCY_CODE
       , l_mmtt_rec.CURRENCY_CONVERSION_RATE
       , l_mmtt_rec.CURRENCY_CONVERSION_TYPE
       , l_mmtt_rec.CURRENCY_CONVERSION_DATE
       , l_mmtt_rec.USSGL_TRANSACTION_CODE
       , l_mmtt_rec.VENDOR_LOT_NUMBER
       , l_mmtt_rec.ENCUMBRANCE_ACCOUNT
       , l_mmtt_rec.ENCUMBRANCE_AMOUNT
       , l_mmtt_rec.SHIP_TO_LOCATION
       , l_mmtt_rec.SHIPMENT_NUMBER
       , l_mmtt_rec.TRANSFER_COST
       , l_mmtt_rec.TRANSPORTATION_COST
       , l_mmtt_rec.TRANSPORTATION_ACCOUNT
       , l_mmtt_rec.FREIGHT_CODE
       , l_mmtt_rec.CONTAINERS
       , l_mmtt_rec.WAYBILL_AIRBILL
       , l_mmtt_rec.EXPECTED_ARRIVAL_DATE
       , p_to_SUBINVENTORY_code
       , l_mmtt_rec.TRANSFER_ORGANIZATION
       , decode(p_to_locator_id,0,null,p_to_locator_id)
       , l_mmtt_rec.NEW_AVERAGE_COST
       , l_mmtt_rec.VALUE_CHANGE
       , l_mmtt_rec.PERCENTAGE_CHANGE
       , l_mmtt_rec.MATERIAL_ALLOCATION_TEMP_ID
       , l_mmtt_rec.DEMAND_SOURCE_HEADER_ID
       , l_mmtt_rec.DEMAND_SOURCE_LINE
       , l_mmtt_rec.DEMAND_SOURCE_DELIVERY
       , l_mmtt_rec.ITEM_SEGMENTS
       , l_mmtt_rec.ITEM_DESCRIPTION
       , l_mmtt_rec.ITEM_TRX_ENABLED_FLAG
       , l_mmtt_rec.ITEM_LOCATION_CONTROL_CODE
       , l_mmtt_rec.ITEM_RESTRICT_SUBINV_CODE
       , l_mmtt_rec.ITEM_RESTRICT_LOCATORS_CODE
       , l_mmtt_rec.ITEM_REVISION_QTY_CONTROL_CODE
       , l_mmtt_rec.ITEM_PRIMARY_UOM_CODE
       , l_mmtt_rec.ITEM_UOM_CLASS
       , l_mmtt_rec.ITEM_SHELF_LIFE_CODE
       , l_mmtt_rec.ITEM_SHELF_LIFE_DAYS
       , l_mmtt_rec.ITEM_LOT_CONTROL_CODE
       , l_mmtt_rec.ITEM_SERIAL_CONTROL_CODE
       , l_mmtt_rec.ITEM_INVENTORY_ASSET_FLAG
       , l_mmtt_rec.ALLOWED_UNITS_LOOKUP_CODE
       , l_mmtt_rec.DEPARTMENT_ID
       , l_mmtt_rec.DEPARTMENT_CODE
       , l_mmtt_rec.WIP_SUPPLY_TYPE
       , l_mmtt_rec.SUPPLY_SUBINVENTORY
       , l_mmtt_rec.SUPPLY_LOCATOR_ID
       , l_mmtt_rec.VALID_SUBINVENTORY_FLAG
       , l_mmtt_rec.VALID_LOCATOR_FLAG
       , l_mmtt_rec.LOCATOR_SEGMENTS
       , l_mmtt_rec.CURRENT_LOCATOR_CONTROL_CODE
       , l_mmtt_rec.NUMBER_OF_LOTS_ENTERED
       , l_mmtt_rec.WIP_COMMIT_FLAG
       , l_mmtt_rec.NEXT_LOT_NUMBER
       , l_mmtt_rec.LOT_ALPHA_PREFIX
       , l_mmtt_rec.NEXT_SERIAL_NUMBER
       , l_mmtt_rec.SERIAL_ALPHA_PREFIX
       , l_mmtt_rec.SHIPPABLE_FLAG
       , l_mmtt_rec.POSTING_FLAG
       , l_mmtt_rec.REQUIRED_FLAG
       , l_mmtt_rec.PROCESS_FLAG
       , l_mmtt_rec.ERROR_CODE
       , l_mmtt_rec.ERROR_EXPLANATION
       , l_mmtt_rec.ATTRIBUTE_CATEGORY
       , l_mmtt_rec.ATTRIBUTE1
       , l_mmtt_rec.ATTRIBUTE2
       , l_mmtt_rec.ATTRIBUTE3
       , l_mmtt_rec.ATTRIBUTE4
       , l_mmtt_rec.ATTRIBUTE5
       , l_mmtt_rec.ATTRIBUTE6
       , l_mmtt_rec.ATTRIBUTE7
       , l_mmtt_rec.ATTRIBUTE8
       , l_mmtt_rec.ATTRIBUTE9
       , l_mmtt_rec.ATTRIBUTE10
       , l_mmtt_rec.ATTRIBUTE11
       , l_mmtt_rec.ATTRIBUTE12
       , l_mmtt_rec.ATTRIBUTE13
       , l_mmtt_rec.ATTRIBUTE14
       , l_mmtt_rec.ATTRIBUTE15
       , l_mmtt_rec.MOVEMENT_ID
       , null   -- reservation quantity
       , l_mmtt_rec.SHIPPED_QUANTITY
       , l_mmtt_rec.TRANSACTION_LINE_NUMBER
       , l_mmtt_rec.TASK_ID
       , l_mmtt_rec.TO_TASK_ID
       , l_mmtt_rec.SOURCE_TASK_ID
       , l_mmtt_rec.PROJECT_ID
       , l_mmtt_rec.SOURCE_PROJECT_ID
       , l_mmtt_rec.PA_EXPENDITURE_ORG_ID
       , l_mmtt_rec.TO_PROJECT_ID
       , l_mmtt_rec.EXPENDITURE_TYPE
       , l_mmtt_rec.FINAL_COMPLETION_FLAG
       , l_mmtt_rec.TRANSFER_PERCENTAGE
       , l_mmtt_rec.TRANSACTION_SEQUENCE_ID
       , l_mmtt_rec.MATERIAL_ACCOUNT
       , l_mmtt_rec.MATERIAL_OVERHEAD_ACCOUNT
       , l_mmtt_rec.RESOURCE_ACCOUNT
       , l_mmtt_rec.OUTSIDE_PROCESSING_ACCOUNT
       , l_mmtt_rec.OVERHEAD_ACCOUNT
       , l_mmtt_rec.FLOW_SCHEDULE
       , l_mmtt_rec.COST_GROUP_ID
       , l_mmtt_rec.DEMAND_CLASS
       , l_mmtt_rec.QA_COLLECTION_ID
       , l_mmtt_rec.KANBAN_CARD_ID
       , l_mmtt_rec.OVERCOMPLETION_TRANSACTION_ID
       , l_mmtt_rec.OVERCOMPLETION_PRIMARY_QTY
       , l_mmtt_rec.OVERCOMPLETION_TRANSACTION_QTY
       , l_mmtt_rec.END_ITEM_UNIT_NUMBER
       , l_mmtt_rec.SCHEDULED_PAYBACK_DATE
       , l_mmtt_rec.LINE_TYPE_CODE
       , l_mmtt_rec.PARENT_TRANSACTION_TEMP_ID
       , l_mmtt_rec.PUT_AWAY_STRATEGY_ID
       , l_mmtt_rec.PUT_AWAY_RULE_ID
       , l_mmtt_rec.PICK_STRATEGY_ID
       , l_mmtt_rec.PICK_RULE_ID
       , l_mmtt_rec.COMMON_BOM_SEQ_ID
       , l_mmtt_rec.COMMON_ROUTING_SEQ_ID
       , l_mmtt_rec.COST_TYPE_ID
       , l_mmtt_rec.ORG_COST_GROUP_ID
       , l_mmtt_rec.MOVE_ORDER_LINE_ID
       , l_mmtt_rec.TASK_GROUP_ID
       , l_mmtt_rec.PICK_SLIP_NUMBER
       , null     -- reservation id
       , 3        -- TRANSACTION_STATUS
       , l_mmtt_rec.TRANSFER_COST_GROUP_ID
       , l_mmtt_rec.lpn_id
       , l_mmtt_rec.transfer_lpn_id
       , l_mmtt_rec.content_lpn_id
       , l_mmtt_rec.cartonization_id
       , l_mmtt_rec.standard_operation_id
       , l_mmtt_rec.wms_task_type
       , l_mmtt_rec.task_priority
       , l_mmtt_rec.container_item_id
     );


     IF (l_debug = 1) THEN
        debug('After inserting to the MMTT');
     END IF;

     l_serial_temp_id := l_new_temp_id;
     -- insert the lot number if it is not null
     if (l_lot_number is not null) then
	IF (l_debug = 1) THEN
	   debug('Inserting the lot '||p_lot_number);
	END IF;


	l_return_result := INV_TRX_UTIL_PUB.insert_lot_trx
	                           (p_trx_tmp_id  => l_new_temp_id,
				    p_user_id    => p_user_id,
				    p_lot_number => p_lot_number,
				    p_trx_qty    => 1,
				    p_pri_qty    => 1,
				    x_ser_trx_id => l_serial_temp_id,
				    x_proc_msg   => x_error_msg);

	if (l_return_result = 1) then
	   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   RAISE fnd_api.g_exc_unexpected_error;
	end if;
     end if;

     IF (l_debug = 1) THEN
        debug('Before inserting serial number, temp_id is '||to_char(l_new_temp_id));
     END IF;

     -- insert the serial number
     IF (l_debug = 1) THEN
        debug('serial number:'||p_serial_number);
     END IF;

     if (l_serial_number is not null ) then
	IF (l_debug = 1) THEN
	   debug('inserting serial number '||p_serial_number);
	END IF;

	l_return_result := inv_trx_util_pub.insert_ser_trx
	                                  (p_trx_tmp_id   => l_serial_temp_id,
					   p_user_id      => p_user_id,
         			           p_fm_ser_num   => p_serial_number,
         			           p_to_ser_num   => NULL,
         			           x_proc_msg     => x_error_msg);

         if (l_return_result = 1) then
            IF (l_debug = 1) THEN
               debug('failed to insert serial '||p_serial_number);
            END IF;
	    x_return_status := fnd_api.g_ret_sts_unexp_error;
	    RAISE fnd_api.g_exc_unexpected_error;
	 end if;
	 IF (l_debug = 1) THEN
   	 debug('inserted the serial number '||p_serial_number);
	 END IF;
     end if;


EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO PROCESS_SERIAL;
      x_return_status := fnd_api.g_ret_sts_error;
   WHEN OTHERS THEN
      ROLLBACK TO PROCESS_SERIAL;
      IF (l_debug = 1) THEN
         debug('Others error' || Sqlerrm);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END;

procedure backorder_nonpick_quantity(
              	x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
		x_error_msg          OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
		p_quantity           IN   NUMBER,
		p_move_order_line_id IN   NUMBER) IS
    l_source_header_id     NUMBER;
    l_source_line_id       NUMBER;
    l_delivery_detail_id   NUMBER;
    l_organization_id   NUMBER;
    l_sub_code   VARCHAR(30);
    l_locator_id    NUMBER;
    l_shipping_attr              WSH_INTERFACE.ChangedAttributeTabType;
    l_api_return_status          VARCHAR2(1);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    BEGIN
    select organization_id,from_subinventory_code,from_locator_id
    into l_organization_id,l_sub_code,l_locator_id
    from mtl_txn_request_lines
    where line_id = p_move_order_line_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
               debug('No move order line found');
            END IF;
            raise FND_API.G_EXC_ERROR;
    END;

    BEGIN
    select source_header_id,source_line_id,delivery_detail_id
    into l_source_header_id,l_source_line_id,l_delivery_detail_id
    from wsh_delivery_details
    where move_order_line_id = p_move_order_line_id
      and released_status = 'S';
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF (l_debug = 1) THEN
                   debug('No delivery detail found');
                END IF;
                raise FND_API.G_EXC_ERROR;
    END;

    -- update shipping to back order the quantity
    --Call Update_Shipping_Attributes to backorder detail line
  l_shipping_attr(1).source_header_id := l_source_header_id;
  l_shipping_attr(1).source_line_id := l_source_line_id;
  l_shipping_attr(1).ship_from_org_id := l_organization_id;
  l_shipping_attr(1).delivery_detail_id := l_delivery_detail_id;
  l_shipping_attr(1).action_flag := 'B';
  l_shipping_attr(1).cycle_count_quantity := p_quantity;
  l_shipping_attr(1).subinventory :=
		     l_sub_code;
  l_shipping_attr(1).locator_id := l_locator_id;


  WSH_INTERFACE.Update_Shipping_Attributes
    (p_source_code               => 'INV',
     p_changed_attributes        => l_shipping_attr,
     x_return_status             => l_api_return_status
    );
  if( l_api_return_status = FND_API.G_RET_STS_ERROR ) then
     IF (l_debug = 1) THEN
        debug('return error from update shipping attributes');
     END IF;
     raise FND_API.G_EXC_ERROR;
  elsif l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      IF (l_debug = 1) THEN
         debug('return error from update shipping attributes');
      END IF;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


    EXCEPTION
        WHEN others THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
END backorder_nonpick_quantity;

END INV_SERIAL_PICK_PKG;

/
