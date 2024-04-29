--------------------------------------------------------
--  DDL for Package Body INV_MO_CANCEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MO_CANCEL_PVT" AS
  /* $Header: INVMOCNB.pls 120.8.12010000.4 2010/02/25 11:31:32 mporecha ship $ */

  g_version_printed  BOOLEAN         := FALSE;
  g_pkg_name         VARCHAR2(50)    := 'INV_MO_CANCEL_PVT';
  g_auto_del_alloc   VARCHAR2(1);    --ER3969328: CI project
  g_conv_precision   CONSTANT NUMBER := 5;


  PROCEDURE DEBUG(p_message IN VARCHAR2, p_module IN VARCHAR2) IS
  BEGIN
    IF NOT g_version_printed THEN
      inv_log_util.trace('$Header: INVMOCNB.pls 120.8.12010000.4 2010/02/25 11:31:32 mporecha ship $',g_pkg_name, 3);
      g_version_printed := TRUE;
    END IF;

   inv_log_util.trace(p_message, g_pkg_name || '.' || p_module, 9);
  END;


  /**
    * Cancels a Move Order line and sets the status to Closed or Cancelled by Source.
    * 1. Undetailed reservations are deleted.
    * 2. Detailed reservations are delinked from the allocations.
    * 3. Allocation is deleted for a WMS Organization.
    * 4. Move Order Line is updated.
    * For more info... see the documentation given in the Spec.
    */
  PROCEDURE cancel_move_order_line
  ( x_return_status         OUT NOCOPY   VARCHAR2
  , x_msg_count             OUT NOCOPY   NUMBER
  , x_msg_data              OUT NOCOPY   VARCHAR2
  , p_line_id               IN           NUMBER
  , p_delete_reservations   IN           VARCHAR2
  , p_txn_source_line_id    IN           NUMBER    DEFAULT NULL
  , p_delete_alloc          IN           VARCHAR2  DEFAULT NULL -- ER3969328: CI project
  , p_delivery_detail_id    IN           NUMBER    DEFAULT NULL -- Planned Crossdocking project
  ) IS

    l_line_status               NUMBER;
    l_org_id                    NUMBER;
    l_is_wms_org                BOOLEAN;
    l_txn_source_line_id        NUMBER;
    l_quantity                  NUMBER;
    l_quantity_detailed         NUMBER;
    l_quantity_to_delete        NUMBER;
    l_deleted_quantity          NUMBER;
    l_max_delete_quantity       NUMBER;
    l_transaction_temp_id       NUMBER;
    l_primary_quantity          NUMBER;
    l_parent_line_id            NUMBER;
    l_task_status               NUMBER;
    l_reservation_id            NUMBER;
    l_delete_reservations       VARCHAR2(1);
    l_task_dispatched           VARCHAR2(1);
    l_rsv_count                 NUMBER;
    l_rsv_rec                   inv_reservation_global.mtl_reservation_rec_type;
    l_rsv_tbl                   inv_reservation_global.mtl_reservation_tbl_type;
    l_update_rec                inv_reservation_global.mtl_reservation_rec_type;
    l_dummy_sn                  inv_reservation_global.serial_number_tbl_type;
    l_error_code                NUMBER;
    l_alloc_flag                VARCHAR2(1);   --ER3969328: CI project
    l_flag                      BOOLEAN;       --ER3969328: CI project
    l_count                     NUMBER;        --ER3969328: CI project
    l_count_alloc               NUMBER;        --ER3969328: CI project
    l_sec_quantity              NUMBER;        --INVCONV
    l_sec_quantity_detailed     NUMBER;        --INVCONV
    l_sec_quantity_to_delete    NUMBER;        --INVCONV
    l_max_delete_sec_quantity   NUMBER;        --INVCONV
    l_sec_deleted_quantity      NUMBER;        --INVCONV
    l_secondary_quantity        NUMBER;        --INVCONV
    l_move_order_type           NUMBER;
    l_total_rsv_quantity        NUMBER;
    l_total_wdd_req_qty         NUMBER;
    l_extra_rsv_quantity        NUMBER;
    -- INVCONV - Added Qty2
    l_extra_rsv_quantity2       NUMBER;
    l_total_rsv_quantity2       NUMBER;
    l_total_wdd_sec_req_qty     NUMBER;
    l_rsv_index                 NUMBER;

    l_debug                     NUMBER;
    l_dummy                     VARCHAR2(1);
    l_api_return_status         VARCHAR2(1);

    l_serial_tbl                inv_reservation_global.serial_number_tbl_type;

    TYPE xdock_rsv_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_xdock_rsv_tbl             xdock_rsv_tbl;

    record_locked          EXCEPTION;
    PRAGMA EXCEPTION_INIT  (record_locked, -54);

    -- INVCONV -Use NVL with secondary_quantity_detailed similar to Qty1
    CURSOR c_line_info IS
      SELECT quantity
           , NVL(quantity_detailed, 0)
           , secondary_quantity
           , NVL(secondary_quantity_detailed,0)
           , organization_id
           , txn_source_line_id
        FROM mtl_txn_request_lines
       WHERE line_id = p_line_id
         FOR UPDATE NOWAIT;

    CURSOR c_reservations IS
      SELECT mr.reservation_id
        FROM mtl_reservations  mr
       WHERE mr.demand_source_type_id   IN (2, 8)
         AND nvl(mr.staged_flag,'N')    <> 'Y'
         AND demand_source_line_detail  IS NULL
         AND mr.demand_source_line_id = l_txn_source_line_id
         AND mr.primary_reservation_quantity > NVL(mr.detailed_quantity, 0);

    CURSOR c_mmtt_info IS
      SELECT mmtt.transaction_temp_id
           , ABS(mmtt.primary_quantity)
           , ABS(mmtt.secondary_transaction_quantity) --INVCONV
           , mmtt.reservation_id
           , mmtt.parent_line_id
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.move_order_line_id = p_line_id
         AND NOT EXISTS (SELECT 1 FROM mtl_material_transactions_temp t
                          WHERE t.parent_line_id = mmtt.transaction_temp_id)
       ORDER BY mmtt.transaction_quantity ASC
         FOR UPDATE NOWAIT;

    CURSOR c_dispatched_task IS
      SELECT status
        FROM wms_dispatched_tasks
       WHERE (l_parent_line_id IS NULL AND transaction_temp_id = l_transaction_temp_id)
          OR (l_parent_line_id IS NOT NULL AND transaction_temp_id = l_parent_line_id);

    -- INVCONV - Added Qty2
    CURSOR c_primary_rsv_qty IS
     SELECT sum(primary_reservation_quantity),
            sum(secondary_reservation_quantity)
     FROM mtl_reservations
     WHERE reservation_id IN (SELECT DISTINCT reservation_id
                            FROM mtl_material_transactions_temp
                            WHERE move_order_line_id = p_line_id);

    CURSOR c_wdd_requested_qty is
     SELECT sum(requested_quantity), sum(requested_quantity2)--INVCONV
     FROM wsh_delivery_details
     WHERE move_order_line_id = p_line_id
     AND released_status ='S';

    --
    -- ER3969328: CI project. Added this cursor
    -- to pick only those allocations which are
    -- currently not being transacted.
    --
    CURSOR c_mmtt IS
     SELECT mmtt.transaction_temp_id
     FROM mtl_material_transactions_temp mmtt
     WHERE mmtt.move_order_line_id = p_line_id
     AND nvl(mmtt.transaction_status,1) = 2
     FOR UPDATE NOWAIT;

    CURSOR c_xdock_rsv
    ( p_wdd_id  IN  NUMBER
    ) IS
      SELECT mr.reservation_id
        FROM mtl_reservations  mr
       WHERE mr.demand_source_line_detail = p_wdd_id
         AND mr.demand_source_type_id    IN (2,8)
         AND NVL(mr.crossdock_flag,'N')   = 'Y'
         FOR UPDATE NOWAIT;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    SAVEPOINT cancelmo_sp;

    -- {{
    -- BEGIN cancel_move_order_line }}
    --
    IF (l_debug = 1) THEN
      DEBUG('Entered with parameters: '
             || '  p_line_id: '             ||  to_char(p_line_id)
             || ', p_delete_reservations: ' ||  p_delete_reservations
             || ', p_txn_source_line_id: '  ||  to_char(p_txn_source_line_id)
             || ', p_delete_alloc: '        ||  p_delete_alloc
             || ', p_delivery_detail_id: '  ||  to_char(p_delivery_detail_id)
           ,'CANCEL_MOVE_ORDER_LINE');
    END IF;

    -- Initializations
    l_deleted_quantity     := 0;
    l_flag                 := FALSE;
    l_count                := 0;
    l_count_alloc          := 0;
    l_sec_deleted_quantity := 0;
    l_total_rsv_quantity   := 0;
    l_total_wdd_req_qty    := -1;
    l_extra_rsv_quantity   := 0;
    l_extra_rsv_quantity2  := 0;
    l_total_rsv_quantity2  := 0;
    l_debug                := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    IF p_line_id IS NOT NULL
    THEN
    -- {
       BEGIN
          SELECT NVL(mtrh.move_order_type,0)
            INTO l_move_order_type
            FROM mtl_txn_request_lines    mtrl
               , mtl_txn_request_headers  mtrh
           WHERE mtrl.line_id   = p_line_id
             AND mtrh.header_id = mtrl.header_id;

          IF (l_debug = 1) THEN
             DEBUG('Move order type: ' || to_char(l_move_order_type)
                  ,'CANCEL_MOVE_ORDER_LINE');
          END IF;

          IF l_move_order_type <= 0
          THEN
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;

       EXCEPTION
          WHEN OTHERS THEN
             IF (l_debug = 1) THEN
                DEBUG('Unxexpected error querying MO type: '
                       || sqlerrm ,'CANCEL_MOVE_ORDER_LINE');
             END IF;
             RAISE fnd_api.g_exc_unexpected_error;
       END;

       IF l_move_order_type <> INV_GLOBALS.G_MOVE_ORDER_PUT_AWAY
       THEN
       -- {
          -- {{
          -- Verify that cancel API works as before for non-putaway
          -- (sales/internal order, WIP) move order lines }}
          --
          -- Query Move Order Line info
          OPEN c_line_info;
          FETCH c_line_info
           INTO l_quantity
              , l_quantity_detailed
              , l_sec_quantity
              , l_sec_quantity_detailed
              , l_org_id
              , l_txn_source_line_id;  --INVCONV
          IF c_line_info%NOTFOUND THEN
             IF (l_debug = 1) THEN
                DEBUG('Error: Could not find the Move Order Line'
                     ,'CANCEL_MOVE_ORDER_LINE');
             END IF;
             fnd_message.set_name('INV','INV_MO_LINE_NOT_FOUND');
             fnd_message.set_token('LINE_ID',p_line_id);
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
          END IF;
          CLOSE c_line_info;

          l_is_wms_org := inv_install.adv_inv_installed(l_org_id);

          --
          -- If not all of the move order quantity is detailed, we may
          -- need to delete some outstanding reservations here.  If this API
          -- is called with the delete rsvs flag set to Yes, then we must reduce
          -- reservation quantity by the same amount that we reduce move order
          -- quantity.  The reservations which are eligible to be updated at this
          -- point are the reservations where rsv quantity > detailed quantity.
          --
          IF p_delete_reservations IS NULL OR p_delete_reservations <> 'Y'
          THEN
             l_delete_reservations  := 'N';
          ELSE
             l_delete_reservations  := 'Y';
          END IF;

          IF (l_debug = 1) THEN
             DEBUG('Delete Reservations (Y/N) = '
                    || l_delete_reservations, 'CANCEL_MOVE_ORDER_LINE');
          END IF;

          IF l_delete_reservations = 'Y' AND l_quantity > l_quantity_detailed
          THEN
          -- {
             l_quantity_to_delete      := l_quantity - l_quantity_detailed;
             l_sec_quantity_to_delete  := l_sec_quantity - l_sec_quantity_detailed;  --INVCONV
             IF (l_debug = 1) THEN
                DEBUG('Deleting Reservations for undetailed qty = '
                      || l_quantity_to_delete, 'Cancel_Move_Order_Line');
                DEBUG('Deleting Reservations for secondary undetailed qty = '
                      || l_sec_quantity_to_delete, 'Cancel_Move_Order_Line');
             END IF;

             -- we query by the sales order line id.  If that value is not
             -- passed in, we need to get it from shipping table
             IF p_txn_source_line_id IS NOT NULL THEN
                l_txn_source_line_id  := p_txn_source_line_id;
             END IF;

             IF (l_debug = 1) THEN
                DEBUG('Source Line ID = ' || l_txn_source_line_id
                     ,'CANCEL_MOVE_ORDER_LINE');
             END IF;

             -- find all reservations where reservation quantity exceeds
             -- detailed quantity.
             OPEN c_reservations;
             LOOP
             -- {
                EXIT WHEN l_quantity_to_delete <= 0;
                FETCH c_reservations INTO l_reservation_id;
                EXIT WHEN c_reservations%NOTFOUND;

                l_rsv_rec.reservation_id := l_reservation_id;

                IF (l_debug = 1) THEN
                   DEBUG('Reservation ID = ' || l_reservation_id
                        ,'CANCEL_MOVE_ORDER_LINE');
                END IF;

                -- query reservation
                l_api_return_status := fnd_api.g_ret_sts_success;
                inv_reservation_pvt.query_reservation
                ( p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
                , x_return_status              => l_api_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_query_input                => l_rsv_rec
                , x_mtl_reservation_tbl        => l_rsv_tbl
                , x_mtl_reservation_tbl_count  => l_rsv_count
                , x_error_code                 => l_error_code
                );

                IF l_api_return_status = fnd_api.g_ret_sts_success THEN
                   IF (l_debug = 1) THEN
                      DEBUG('query_reservation returned success','CANCEL_MOVE_ORDER_LINE');
                   END IF;
                ELSE
                   IF (l_debug = 1) THEN
                      DEBUG('Error: Query Reservations return status: '
                             || l_api_return_status
                           ,'CANCEL_MOVE_ORDER_LINE');
                   END IF;
                   fnd_message.set_name('INV','INV_QRY_RSV_FAILED');
                   fnd_msg_pub.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF l_rsv_count <= 0 THEN
                   IF (l_debug = 1) THEN
                      DEBUG('Error: Query Reservations returned Reservation Count 0'
                           ,'CANCEL_MOVE_ORDER_LINE');
                   END IF;
                   fnd_message.set_name('INV','INV_NO_RSVS_FOUND');
                   fnd_msg_pub.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                l_update_rec := l_rsv_tbl(1);
                l_update_rec.reservation_quantity := NULL;

                -- Reservation Qty can be reduced by a Maximum of
                -- either Primary Rsv Qty or Detailed Qty.
                l_max_delete_quantity
                  := l_update_rec.primary_reservation_quantity
                     - l_update_rec.detailed_quantity;
                l_max_delete_sec_quantity
                  := l_update_rec.secondary_reservation_quantity
                     - l_update_rec.secondary_detailed_quantity; --INVCONV

                IF l_max_delete_quantity > l_quantity_to_delete
                THEN
                   l_update_rec.primary_reservation_quantity
                     := l_update_rec.primary_reservation_quantity - l_quantity_to_delete;
                   l_quantity_to_delete := 0;
                   l_update_rec.secondary_reservation_quantity
                     := l_update_rec.secondary_reservation_quantity
                        - l_sec_quantity_to_delete; --INVCONV
                   l_sec_quantity_to_delete := 0; --INVCONV
                ELSE
                   l_quantity_to_delete
                     := l_quantity_to_delete - l_max_delete_quantity;
                   l_update_rec.primary_reservation_quantity
                     := l_update_rec.primary_reservation_quantity - l_max_delete_quantity;
                   l_sec_quantity_to_delete
                     := l_quantity_to_delete - l_max_delete_quantity; --INVCONV
                   l_update_rec.secondary_reservation_quantity
                     := l_update_rec.secondary_reservation_quantity
                        - l_max_delete_sec_quantity; --INVCONV
                END IF;

                IF (l_debug = 1) THEN
                   DEBUG('New Reservation Qty = '
                          || l_update_rec.primary_reservation_quantity
                        ,'CANCEL_MOVE_ORDER_LINE');
                   DEBUG('New seconday Reservation Qty = '
                          || l_update_rec.secondary_reservation_quantity
                        ,'CANCEL_MOVE_ORDER_LINE');
                END IF;

                -- update reservation
                -- INVCONV - Make sure Qty2 are NULL if nor present
                IF (l_update_rec.secondary_uom_code IS NULL)
                THEN
                   l_update_rec.secondary_reservation_quantity := NULL;
                   l_update_rec.secondary_detailed_quantity    := NULL;
                END IF;

                l_api_return_status := fnd_api.g_ret_sts_success;
                inv_reservation_pub.update_reservation
                ( p_api_version_number     => 1.0
                , p_init_msg_lst           => fnd_api.g_false
                , x_return_status          => l_api_return_status
                , x_msg_count              => x_msg_count
                , x_msg_data               => x_msg_data
                , p_original_rsv_rec       => l_rsv_tbl(1)
                , p_to_rsv_rec             => l_update_rec
                , p_original_serial_number => l_dummy_sn
                , p_to_serial_number       => l_dummy_sn
                , p_validation_flag        => fnd_api.g_true
                );

                IF l_api_return_status = fnd_api.g_ret_sts_success THEN
                   IF (l_debug = 1) THEN
                      DEBUG('update_reservation returned success'
                           ,'CANCEL_MOVE_ORDER_LINE');
                   END IF;
                ELSE
                   IF (l_debug = 1) THEN
                      DEBUG('Error: Update Reservations return status: '
                             || l_api_return_status, 'CANCEL_MOVE_ORDER_LINE');
                   END IF;

                   fnd_message.set_name('INV','INV_UPDATE_RSV_FAILED');
                   fnd_msg_pub.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;
             -- }
             END LOOP;

             CLOSE c_reservations;
          -- }
          END IF;

          -- Reduce Move Order Line Qty to include only existing allocations.
          IF l_quantity > l_quantity_detailed
          THEN
             l_quantity  := l_quantity_detailed;
             l_sec_quantity  := l_sec_quantity_detailed; --INVCONV
          END IF;

          -- If no allocations exist, close move order line
          IF l_quantity <= 0 OR l_quantity_detailed <= 0
          THEN
             l_quantity     := 0;
             l_sec_quantity := 0; -- INVCONV
             l_line_status  := 5;

             IF (l_debug = 1) THEN
                DEBUG('No allocations. Closing MO line', 'CANCEL_MOVE_ORDER_LINE');
             END IF;
          ELSE
          -- {
            IF (l_debug = 1) THEN
               DEBUG('If the MOL Detailed quantity is more than'
                      ||' requested quantity then need to delete'
                    ,'CANCEL_MOVE_ORDER_LINE');
               DEBUG(' extra reservations','CANCEL_MOVE_ORDER_LINE');
            END IF;

            IF l_quantity_detailed > l_quantity
            THEN
            -- {
               IF (l_debug = 1) THEN
                  DEBUG('Qty detailed is greater than qty..calculating extra rsved qty'
                       ,'CANCEL_MOVE_ORDER_LINE');
               END IF;

               OPEN c_primary_rsv_qty;
               -- HW INVCONV - Added Qty2
               FETCH c_primary_rsv_qty INTO l_total_rsv_quantity,l_total_rsv_quantity2;
               CLOSE c_primary_rsv_qty;

               IF (l_debug =1) THEN
                  DEBUG('The total unstaged reservation for the Move Order line is '
                         || l_total_rsv_quantity,'CANCEL_MOVE_ORDER_LINE');
                  DEBUG('The total unstaged secondary reservation for the Move Order line is '
                         || l_total_rsv_quantity2,'CANCEL_MOVE_ORDER_LINE');
               END IF;

               IF (l_total_rsv_quantity > 0)
               THEN
               -- {
                  OPEN c_wdd_requested_qty;
                  FETCH c_wdd_requested_qty INTO l_total_wdd_req_qty, l_total_wdd_sec_req_qty;
                  CLOSE c_wdd_requested_qty;

                  IF (l_debug=1) THEN
                     DEBUG('The total unstaged wdd requested quantity'
                            || l_total_wdd_req_qty,'CANCEL_MOVE_ORDER_LINE');
                  END IF;

                  IF (l_total_wdd_req_qty >= 0)
                  THEN
                     l_extra_rsv_quantity := l_total_rsv_quantity - l_total_wdd_req_qty;
                     -- INVCONV -Added Qty2
                     l_extra_rsv_quantity := l_total_rsv_quantity - l_total_wdd_req_qty;
                     l_extra_rsv_quantity2 := l_total_rsv_quantity2 - l_total_wdd_sec_req_qty;
                  END IF;
                  IF (l_debug=1) THEN
                    DEBUG('The extra reserved quantity that needs to be deleted'
                           || l_extra_rsv_quantity,'CANCEL_MOVE_ORDER_LINE');
                    -- INVCONV - Added Qty2
                    DEBUG('The extra reserved quantity2 that needs to be deleted'
                           || l_extra_rsv_quantity2,'CANCEL_MOVE_ORDER_LINE');
                  END IF;
               -- }
               END IF;
            -- }
            END IF;
          -- }
          END IF;

          -- query all allocations
          OPEN c_mmtt_info;

          IF (l_debug = 1) THEN
             DEBUG('Fetching tasks', 'CANCEL_MOVE_ORDER_LINE');
          END IF;

          -- INVCONV - Added qty2
          LOOP
          -- {
             FETCH c_mmtt_info INTO l_transaction_temp_id, l_primary_quantity,
                   l_secondary_quantity, l_reservation_id, l_parent_line_id;
             EXIT WHEN c_mmtt_info%NOTFOUND;

             IF (l_debug = 1) THEN
                DEBUG('Transaction Temp ID  = ' || l_transaction_temp_id
                     ,'CANCEL_MOVE_ORDER_LINE');
                DEBUG('Primary Quantity     = ' || l_primary_quantity
                     ,'CANCEL_MOVE_ORDER_LINE');
                -- INVCONV - Added Qty2
                DEBUG('Secondary Quantity   = ' || l_secondary_quantity
                     ,'CANCEL_MOVE_ORDER_LINE');
                DEBUG('Reservation ID       = ' || l_reservation_id
                     ,'CANCEL_MOVE_ORDER_LINE');
                DEBUG('Parent Line ID       = ' || l_parent_line_id
                     ,'CANCEL_MOVE_ORDER_LINE');
             END IF;

             -- if the allocation corresponds to a reservation, we need to update
             -- the reservation to reduce detailed_quantity and possibly
             -- reservation quantity
             IF l_reservation_id IS NOT NULL
             THEN
             -- {
                l_rsv_rec.reservation_id  := l_reservation_id;
                l_api_return_status := fnd_api.g_ret_sts_success;
                inv_reservation_pvt.query_reservation
                ( p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
                , x_return_status              => l_api_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_query_input                => l_rsv_rec
                , x_mtl_reservation_tbl        => l_rsv_tbl
                , x_mtl_reservation_tbl_count  => l_rsv_count
                , x_error_code                 => l_error_code
                );

                IF l_api_return_status = fnd_api.g_ret_sts_success THEN
                   IF (l_debug = 1) THEN
                      DEBUG('query_reservation returned success'
                           ,'CANCEL_MOVE_ORDER_LINE');
                   END IF;
                ELSE
                   IF (l_debug = 1) THEN
                      DEBUG('Error: Query Reservations returned '
                             || l_api_return_status, 'CANCEL_MOVE_ORDER_LINE');
                   END IF;
                   fnd_message.set_name('INV','INV_QRY_RSV_FAILED');
                   fnd_msg_pub.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF l_rsv_count <= 0
                THEN
                   IF (l_debug = 1) THEN
                      DEBUG('Error: Query Reservations returned Reservation Count 0'
                           ,'CANCEL_MOVE_ORDER_LINE');
                   END IF;
                   fnd_message.set_name('INV','INV_NO_RSVS_FOUND');
                   fnd_msg_pub.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                l_update_rec              := l_rsv_tbl(1);

                -- update detailed quantity
                IF l_update_rec.detailed_quantity > l_primary_quantity
                THEN
                   l_update_rec.detailed_quantity
                     := l_update_rec.detailed_quantity - l_primary_quantity;
                   -- INVCONV - Update Sec. Qty
                   l_update_rec.secondary_detailed_quantity
                     := l_update_rec.secondary_detailed_quantity - l_secondary_quantity;
                ELSE
                   l_update_rec.detailed_quantity  := 0;
                   -- INVCONV - Added Qty2
                   l_update_rec.secondary_detailed_quantity  := 0;
                END IF;

                IF (l_debug = 1) THEN
                    DEBUG('New Detailed Qty = ' || l_update_rec.detailed_quantity
                         ,'CANCEL_MOVE_ORDER_LINE');
                    -- INVCONV - Added Qty2
                    DEBUG('New Detailed Qty1 = ' || l_update_rec.secondary_detailed_quantity
                         ,'CANCEL_MOVE_ORDER_LINE');
                END IF;

                -- if delete reservations = Yes, then update rsv quantity
                IF l_delete_reservations = 'Y' OR l_extra_rsv_quantity > 0
                THEN
                -- {
                  l_update_rec.reservation_quantity  := NULL;
                  -- INVCONV - Need to initialize secondary_qty
                  l_update_rec.secondary_reservation_quantity  := NULL;

                  IF l_update_rec.primary_reservation_quantity > l_primary_quantity
                  THEN
                    l_update_rec.primary_reservation_quantity
                      := l_update_rec.primary_reservation_quantity - l_primary_quantity;
                    -- INVCONV - Added Qty2
                    l_update_rec.secondary_reservation_quantity
                      := l_update_rec.secondary_reservation_quantity - l_secondary_quantity;

                    IF (l_extra_rsv_quantity > 0)
                    THEN
                       l_extra_rsv_quantity :=  l_extra_rsv_quantity - l_primary_quantity;
                       -- INVCONV -Added Qty2
                       l_extra_rsv_quantity2 :=  l_extra_rsv_quantity2 - l_secondary_quantity;

                       IF (l_debug=1) THEN
                          DEBUG('New remaning extra rsv quantity'
                                 || l_extra_rsv_quantity,'CANCEL_MOVE_ORDER_LINE');
                          -- INVCONV -Qty2
                          DEBUG('New remaning extra rsv quantity2'
                                 || l_extra_rsv_quantity2,'CANCEL_MOVE_ORDER_LINE');
                       END IF;
                    END IF;
                  ELSIF (l_delete_reservations ='N'
                         AND
                         (l_update_rec.primary_reservation_quantity >= l_extra_rsv_quantity))
                  THEN
                    IF (l_debug=1) THEN
                       DEBUG('need to reduce reservation quantity only for the extra qty'
                              || l_extra_rsv_quantity,'CANCEL_MOVE_ORDER_LINE');
                       END IF;
                       l_update_rec.primary_reservation_quantity
                         := l_update_rec.primary_reservation_quantity - l_extra_rsv_quantity;
                       l_extra_rsv_quantity :=0;
                       -- INVCONV -Qty2
                       l_update_rec.secondary_reservation_quantity
                         := l_update_rec.secondary_reservation_quantity - l_extra_rsv_quantity2;
                       l_extra_rsv_quantity2 := 0;

                       IF (l_debug=1) THEN
                          DEBUG('Primary reserervation quantity is '
                                 || l_update_rec.primary_reservation_quantity
                               ,'CANCEL_MOVE_ORDER_LINE');
                       END IF;
                  ELSE
                     IF (l_extra_rsv_quantity > 0
                         AND
                         l_extra_rsv_quantity >= l_update_rec.primary_reservation_quantity)
                     THEN
                        l_extra_rsv_quantity
                          := l_extra_rsv_quantity - l_update_rec.primary_reservation_quantity;
                        -- INVCONV -Qty2
                        l_extra_rsv_quantity2
                          := l_extra_rsv_quantity2 - l_update_rec.secondary_reservation_quantity;
                     ELSE
                        l_extra_rsv_quantity := 0;
                        -- INVCONV -Qty2
                        l_extra_rsv_quantity2 := 0;
                     END IF;

                     IF (l_debug=1) THEN
                        DEBUG('Extra rsv quantity is ' || l_extra_rsv_quantity
                             ,'CANCEL_MOVE_ORDER_LINE');
                        DEBUG('Primary reservation quantity'
                               || l_update_rec.primary_reservation_quantity
                             ,'CANCEL_MOVE_ORDER_LINE');
                        -- INVCONV -Qty2
                        DEBUG('Extra rsv quantity2 is '
                               || l_extra_rsv_quantity2,'CANCEL_MOVE_ORDER_LINE');
                        DEBUG('Secondary reservation quantity'
                               || l_update_rec.secondary_reservation_quantity
                              ,'CANCEL_MOVE_ORDER_LINE');
                     END IF;

                     l_update_rec.primary_reservation_quantity := 0;
                     -- INVCONV -Qty2
                     l_update_rec.secondary_reservation_quantity  := 0;
                  END IF; -- rsv qty > task qty

                  IF (l_debug = 1) THEN
                     DEBUG('New rsv qty = '
                            || l_update_rec.primary_reservation_quantity
                          ,'Cancel_Move_Order_Line');
                     DEBUG('New sec rsv qty = '
                            || l_update_rec.secondary_reservation_quantity
                          ,'Cancel_Move_Order_Line');
                  END IF;
                -- }
                END IF; -- delete reservations

                -- INVCONV - Make sure Qty2 are NULL if nor present
                IF ( l_update_rec.secondary_uom_code IS NULL )
                THEN
                   l_update_rec.secondary_reservation_quantity := NULL;
                   l_update_rec.secondary_detailed_quantity    := NULL;
                END IF;

                -- update reservations
                l_api_return_status := fnd_api.g_ret_sts_success;
                inv_reservation_pub.update_reservation
                ( p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
                , x_return_status              => l_api_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_original_rsv_rec           => l_rsv_tbl(1)
                , p_to_rsv_rec                 => l_update_rec
                , p_original_serial_number     => l_dummy_sn
                , p_to_serial_number           => l_dummy_sn
                , p_validation_flag            => fnd_api.g_true
                , p_over_reservation_flag      => 2  -- Bug 5158514
                );

                IF l_api_return_status = fnd_api.g_ret_sts_success THEN
                   IF (l_debug = 1) THEN
                      DEBUG('update_reservation returned success'
                           ,'CANCEL_MOVE_ORDER_LINE');
                   END IF;
                ELSE
                   IF (l_debug = 1) THEN
                      DEBUG('Error: Update Reservations returned '
                             || l_api_return_status, 'CANCEL_MOVE_ORDER_LINE');
                   END IF;

                   fnd_message.set_name('INV','INV_UPDATE_RSV_FAILED');
                   fnd_msg_pub.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;
             -- }
             END IF; -- reservation id is not null

             -- Check if WMS is installed
             IF l_is_wms_org THEN
             -- {
                OPEN c_dispatched_task;
                FETCH c_dispatched_task INTO l_task_status;

                IF c_dispatched_task%NOTFOUND OR l_task_status NOT IN(4, 9)
                THEN
                   IF (l_debug = 1) THEN
                      DEBUG('Task is not yet Loaded or is not Active'
                           ,'CANCEL_MOVE_ORDER_LINE');
                   END IF;

                   l_deleted_quantity := l_deleted_quantity + l_primary_quantity;
                   -- INVCONV -Qty2
                   l_sec_deleted_quantity := l_sec_deleted_quantity + l_secondary_quantity;

                   l_api_return_status := fnd_api.g_ret_sts_success;
                   inv_trx_util_pub.delete_transaction
                   ( x_return_status       => l_api_return_status
                   , x_msg_data            => x_msg_data
                   , x_msg_count           => x_msg_count
                   , p_transaction_temp_id => l_transaction_temp_id
                   );

                   IF l_api_return_status = fnd_api.g_ret_sts_success THEN
                      IF (l_debug = 1) THEN
                         DEBUG('delete_transaction returned success'
                              ,'CANCEL_MOVE_ORDER_LINE');
                      END IF;
                   ELSE
                      IF (l_debug = 1) THEN
                         DEBUG('Error: delete_transaction return status: '
                               || l_api_return_status
                              ,'CANCEL_MOVE_ORDER_LINE');
                      END IF;
                      fnd_message.set_name('INV','INV_DELETE_TXN_FAILED');
                      fnd_message.set_token('TXN_TEMP_ID',l_transaction_temp_id);
                      fnd_msg_pub.ADD;
                      RAISE fnd_api.g_exc_error;
                   END IF;
                ELSE
                   IF (l_debug = 1) THEN
                      DEBUG('Task is Loaded or Active - Not deleting the Allocation'
                           ,'CANCEL_MOVE_ORDER_LINE');
                   END IF;
                END IF; -- task is not dispatched

                CLOSE c_dispatched_task;
             -- }
             END IF; -- wms installed
          -- }
          END LOOP; -- loop through each task

          CLOSE c_mmtt_info;

          -- NULL out the Reservation ID in MMTT.
          -- This delinks the Reservations from Allocations.
          UPDATE mtl_material_transactions_temp
             SET reservation_id = NULL
           WHERE move_order_line_id = p_line_id;

          -- If all of the quantity for the move order line was deleted,
          -- close the move order line
          IF l_deleted_quantity >= l_quantity
          THEN
             l_quantity     := 0;
             l_line_status  := 5;
             -- INVCONV -Qty2
             l_sec_quantity := 0;
          ELSE
             l_quantity     := l_quantity - l_deleted_quantity;
             l_line_status  := 9;
             -- INVCONV -Qty2
             l_sec_quantity := l_sec_quantity - l_sec_deleted_quantity;
          END IF;

          IF (l_debug = 1) THEN
            DEBUG('MO Line - New Status   = '
                   || l_line_status, 'CANCEL_MOVE_ORDER_LINE');
            DEBUG('MO Line - New Quantity = '
                   || l_quantity, 'CANCEL_MOVE_ORDER_LINE');
            DEBUG('MO Line - New Secondary Quantity = '
                   || l_sec_quantity, 'CANCEL_MOVE_ORDER_LINE');
          END IF;

          --  Update line status, quantity, and required_quantity
          -- INVCONV -Qty2
          UPDATE mtl_txn_request_lines
             SET quantity           = l_quantity
               , required_quantity  = 0
               , line_status        = l_line_status
               , secondary_quantity = l_sec_quantity
               , secondary_required_quantity
                                    = decode(l_sec_quantity, NULL, NULL, 0)
               , status_date =sysdate   --BUG 6932648
           WHERE line_id = p_line_id;

          --
          -- ER3969328: CI project. The following changes made for CI project ER.
          -- Check first if this API was called with a value passed to p_delete_alloc.
          -- If this is null pick the org level parameter setting. Check if the option
          -- 'Auto Delete Allocations at Move Order Cancel' is set Yes. If Yes then
          -- the allocations should be deleted and the move order line closed.
          -- The variable g_auto_del_alloc is cached.
          --

          IF p_delete_alloc IS NULL
          THEN
             IF g_auto_del_alloc is null
             THEN
                select NVL(auto_del_alloc_flag,'N')
                  into g_auto_del_alloc
                  from mtl_parameters
                 where organization_id = l_org_id;
             END IF;
             l_alloc_flag := g_auto_del_alloc;
          ELSE
             l_alloc_flag := p_delete_alloc;
          END IF;

          --
          -- ER3969328: CI project.Check the total number of allocations
          -- for this move_order_line_id
          --
          select count(*)
            into l_count_alloc
            from mtl_material_transactions_temp
           where move_order_line_id = p_line_id;

          --
          -- ER3969328: CI project.Only if this flag is set to 'Y'
          -- will the delete allocations API be called.
          --
          IF (l_alloc_flag = 'Y'  and l_is_wms_org = FALSE)
          THEN
          -- {
             for c_mmtt_rec in c_mmtt
             LOOP
                 l_count := l_count + 1; --counter
                 l_api_return_status := fnd_api.g_ret_sts_success;
                 inv_mo_line_detail_util.delete_allocations
                 ( x_return_status       => l_api_return_status
                 , x_msg_data            => x_msg_count
                 , x_msg_count           => x_msg_data
                 , p_mo_line_id          => p_line_id
                 , p_transaction_temp_id => c_mmtt_rec.transaction_temp_id
                 );
                 IF l_api_return_status = fnd_api.g_ret_sts_success THEN
                    IF (l_debug = 1) THEN
                       DEBUG('delete_allocations returned success'
                            ,'Cancel_Move_Order_Line');
                    END IF;
                    l_flag := TRUE;
                 ELSE
                    IF (l_debug = 1) THEN
                       DEBUG('Error: delete_allocations return status: '
                              || l_api_return_status
                            ,'Cancel_Move_Order_Line');
                    END IF;
                    l_flag := FALSE;
                    RAISE fnd_api.g_exc_error;
                 END IF;
             END LOOP;

             --
             -- ER3969328: CI project.After deleting allocations successfully
             -- close the move order line.
             --
             IF (l_flag and l_count = l_count_alloc)
             THEN
                update mtl_txn_request_lines
                   set line_status = 5
                     , status_date =sysdate   --BUG 6932648
                 where line_id = p_line_id;
             END IF;
          -- }
          END IF; -- g_auto_del_alloc = 'Y' and l_is_wms_org = FALSE
       -- }
       ELSE -- MO type putaway
       -- {
          -- {{
          -- Cancel sales/internal order where a xdock peg
          -- exists, with material in Receiving.  The operation
          -- plan should get cancelled, and material should not
          -- be staged }}
          --
          -- Lock the putaway move order line
          BEGIN
             SELECT 'x'
               INTO l_dummy
               FROM mtl_txn_request_lines  mtrl
              WHERE mtrl.line_id = p_line_id
                FOR UPDATE NOWAIT;
          EXCEPTION
             WHEN record_locked THEN
                DEBUG('Unable to lock the putaway MO line'
                     ,'CANCEL_MOVE_ORDER_LINE');
                fnd_message.set_name('WMS', 'INV_PUTAWAY_MOL_LOCK_FAIL');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
          END;

          wms_xdock_utils_pvt.g_demand_triggered := TRUE;

          l_api_return_status := fnd_api.g_ret_sts_success;
          inv_rcv_integration_pvt.call_atf_api
          ( x_return_status          => l_api_return_status
          , x_msg_data               => x_msg_data
          , x_msg_count              => x_msg_count
          , x_error_code             => l_error_code
          , p_source_task_id         => NULL
          , p_activity_type_id       => 1
          , p_mol_id                 => p_line_id
          , p_atf_api_name           => inv_rcv_integration_pvt.g_atf_api_cancel
          , p_mmtt_error_code        => 'INV_XDK_DEMAND_CHG'
          , p_mmtt_error_explanation => NULL
          , p_retain_mmtt            => 'Y'
          );

          wms_xdock_utils_pvt.g_demand_triggered := FALSE;

          IF l_api_return_status = fnd_api.g_ret_sts_success THEN
             IF (l_debug = 1)
             THEN
                DEBUG('inv_rcv_integration_pvt.call_atf_api returned success'
                     ,'CANCEL_MOVE_ORDER_LINE');
             END IF;
          ELSE
             IF (l_debug = 1)
             THEN
                DEBUG('inv_rcv_integration_pvt.call_atf_api returned an error status: '
                       || l_api_return_status, 'CANCEL_MOVE_ORDER_LINE');
                DEBUG('l_error_code: ' || l_error_code
                     ,'CANCEL_MOVE_ORDER_LINE');
             END IF;

             IF l_api_return_status = fnd_api.g_ret_sts_error
             THEN
                RAISE fnd_api.g_exc_error;
             ELSE
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          END IF;
       -- }
       END IF;
    -- }
    ELSE -- line ID is NULL
    -- {
       IF p_delivery_detail_id IS NULL
       THEN
          IF (l_debug = 1) THEN
             DEBUG('Both p_line_id and p_delivery_detail_id are null!'
                  ,'CANCEL_MOVE_ORDER_LINE');
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
       -- {{
       -- Cancellation of sales/internal order where a xdock peg
       -- exists, before material is received.  The reservations
       -- should get deleted }}
       --
       l_xdock_rsv_tbl.DELETE;
       BEGIN
          OPEN c_xdock_rsv (p_delivery_detail_id);
          FETCH c_xdock_rsv BULK COLLECT INTO l_xdock_rsv_tbl;
          CLOSE c_xdock_rsv;
       EXCEPTION
          WHEN record_locked THEN
             IF (l_debug = 1) THEN
                DEBUG('Unable to lock xdock rsv record(s)'
                     ,'CANCEL_MOVE_ORDER_LINE');
             END IF;
             IF c_xdock_rsv%ISOPEN
             THEN
                CLOSE c_xdock_rsv;
             END IF;
             fnd_message.set_name('WMS', 'INV_RSV_LOCK_FAIL');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
       END;

       wms_xdock_utils_pvt.g_demand_triggered := TRUE;

       l_rsv_index := l_xdock_rsv_tbl.FIRST;
       LOOP
       -- {
          IF (l_xdock_rsv_tbl.COUNT = 0) THEN
             IF (l_debug = 1) THEN
                DEBUG('No xdock rsv records to process','CANCEL_MOVE_ORDER_LINE');
             END IF;
             EXIT;
          END IF;

          l_rsv_rec.reservation_id := l_xdock_rsv_tbl(l_rsv_index);
          IF (l_debug = 1) THEN
             DEBUG('About to delete reservation ID: '
                    || to_char(l_rsv_rec.reservation_id)
                  ,'CANCEL_MOVE_ORDER_LINE');
          END IF;

          l_api_return_status := fnd_api.g_ret_sts_success;
          inv_reservation_pub.delete_reservation
          ( p_api_version_number => 1.0
          , p_init_msg_lst       => fnd_api.g_false
          , x_return_status      => l_api_return_status
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          , p_rsv_rec            => l_rsv_rec
          , p_serial_number      => l_serial_tbl
          );

          IF l_api_return_status = fnd_api.g_ret_sts_success THEN
             IF (l_debug = 1)
             THEN
                DEBUG('inv_reservation_pub.delete_reservation returned success'
                     ,'CANCEL_MOVE_ORDER_LINE');
             END IF;
          ELSE
             IF (l_debug = 1)
             THEN
                DEBUG('inv_reservation_pub.delete_reservation returned an error status: '
                       || l_api_return_status, 'CANCEL_MOVE_ORDER_LINE');
             END IF;

             IF l_api_return_status = fnd_api.g_ret_sts_error
             THEN
                RAISE fnd_api.g_exc_error;
             ELSE
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          END IF;

          EXIT WHEN l_rsv_index = l_xdock_rsv_tbl.LAST;
          l_rsv_index := l_xdock_rsv_tbl.NEXT(l_rsv_index);
       -- }
       END LOOP;

       wms_xdock_utils_pvt.g_demand_triggered := FALSE;

       l_xdock_rsv_tbl.DELETE;
    -- }
    END IF;

    -- {{
    -- END cancel_move_order_line }}
    --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO cancelmo_sp;
      wms_xdock_utils_pvt.g_demand_triggered := FALSE;
      fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data,
                                p_encoded => 'F');
      x_return_status := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
         DEBUG('Return status = ' || x_return_status ||
               ', x_msg_data = '  || x_msg_data
              ,'CANCEL_MOVE_ORDER_LINE');
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO cancelmo_sp;
      wms_xdock_utils_pvt.g_demand_triggered := FALSE;
      fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data,
                                p_encoded => 'F');
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
         DEBUG('Return status = ' || x_return_status ||
               ', x_msg_data = '  || x_msg_data
              ,'CANCEL_MOVE_ORDER_LINE');
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO cancelmo_sp;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      --ER: CI project. Setting the fields x_msg_count and x_msg_data correctly.
      x_msg_count      := SQLCODE;
      x_msg_data       := SQLERRM;

      IF (l_debug = 1) THEN
         DEBUG('Other error: Code = ' || SQLCODE || ' : Msg = ' || SQLERRM
              ,'CANCEL_MOVE_ORDER_LINE');
      END IF;

  END cancel_move_order_line;


  --Procedure
  --   Reduce_Move_Order_Quantity
  --Description
  --   This procedure is called from Shipping when the quantity on a
  -- sales order line is reduced, leading to the quantity on a delivery
  -- detail being reduced.  This procedure reduces the required_quantity
  -- column on the move order line by p_reduction_quantity. The required
  -- quantity is the quantity needed by shipping to fulfill the sales order.
  -- Any quantity transacted for this move order line in excess of the
  -- required_quantity will be moved to staging, but will not be
  -- reserved or shipped to the customer. Since the
  -- sales order line quantity has been reduced, the reservation quantity
  -- for the sales order should also be reduced. Some reservations are
  -- reduced here, and some are reduced in Finalize_Pick_Confirm
  -- (INVVTROB.pls).
  --    If WMS is installed, undispatched tasks may be deleted, since these
  -- tasks are no longer necessary.
  -- Parameters
  --   p_line_id: The move order line id to be reduced
  --   p_reduction_quantity:  How much to reduce the required
  --       quantity by, in the UOM of the move order line
  --   p_txn_source_line_Id:  The sales order line id.  If this
  --      parameter is not passed in, we get it from the delivery detail.
  --   p_delivery_detail_id: Added for Planned Crossdocking in Release 12.0
  --      Shipping passes in delivery detail ID if the WDD record is pegged
  --      to a supply source (via reservations) and the supply has not been
  --      received.  After receipt reductions are not allowed so this API
  --      should not be called to reduce qty on a putaway move order line

  PROCEDURE reduce_move_order_quantity
  ( x_return_status           OUT NOCOPY   VARCHAR2
  , x_msg_count               OUT NOCOPY   NUMBER
  , x_msg_data                OUT NOCOPY   VARCHAR2
  , p_line_id                 IN           NUMBER
  , p_reduction_quantity      IN           NUMBER
  , p_sec_reduction_quantity  IN           NUMBER DEFAULT NULL
  , p_txn_source_line_id      IN           NUMBER DEFAULT NULL
  , p_delivery_detail_id      IN           NUMBER DEFAULT NULL -- planned crossdocking project
  ) IS
    l_quantity                  NUMBER;
    l_quantity_detailed         NUMBER;
    l_organization_id           NUMBER;
    l_transaction_temp_id       NUMBER;
    l_task_qty                  NUMBER;
    l_return_status             VARCHAR2(1);
    l_deleted_quantity          NUMBER;
    l_reservation_id            NUMBER;
    l_primary_quantity          NUMBER;
    l_rsv_rec                   inv_reservation_global.mtl_reservation_rec_type;
    l_rsv_rec2                  inv_reservation_global.mtl_reservation_rec_type;
    l_rsv_tbl                   inv_reservation_global.mtl_reservation_tbl_type;
    l_update_rec                inv_reservation_global.mtl_reservation_rec_type;
    l_serial_tbl                inv_reservation_global.serial_number_tbl_type;
    l_rsv_count                 NUMBER;
    l_rsv_index                 NUMBER;
    l_dummy_sn                  inv_reservation_global.serial_number_tbl_type;
    l_quantity_to_delete        NUMBER;
    l_sec_quantity_to_delete    NUMBER; --INVCONV
    l_sec_deleted_quantity      NUMBER; --INVCONV
    l_sec_quantity              NUMBER; --INVCONV
    l_sec_quantity_detailed     NUMBER; --INVCONV
    l_sec_reduction_quantity    NUMBER; --INVCONV
    l_sec_qty                   NUMBER; --INVCONV
    l_max_delete_sec_quantity   NUMBER; --INVCONV
    l_sec_qty_to_delete         NUMBER; --INVCONV
    l_max_delete_quantity       NUMBER;
    l_txn_source_line_id        NUMBER;
    l_reduction_quantity        NUMBER;
    l_error_code                NUMBER;
    l_mo_uom_code               VARCHAR2(3);
    l_primary_uom_code          VARCHAR2(3);
    l_inventory_item_id         NUMBER;
    l_prim_quantity_to_delete   NUMBER;
    l_move_order_type           NUMBER;
    l_reduc_qty_conv            NUMBER;
    l_conv_rate                 NUMBER;
    l_sec_reduc_qty_conv        NUMBER;
    l_prim_qty_conv             NUMBER;

    l_debug                     NUMBER;
    l_required_quantity         NUMBER; --Bug#5095840.
    l_sec_required_quantity     NUMBER; --Bug#5095840.

    TYPE xdock_rsv_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_xdock_rsv_tbl             xdock_rsv_tbl;

    record_locked               EXCEPTION;
    PRAGMA EXCEPTION_INIT       (record_locked, -54);

   /*Bug#5095840. In the below cursor, the columns, 'Required_quantity' and
     'secnodary_required_quantity' are also selected.*/
    CURSOR c_line_info IS
      SELECT quantity
            ,NVL(required_quantity, quantity)
            , NVL(quantity_detailed, 0)
            , secondary_quantity
            , NVL(secondary_required_quantity, secondary_quantity) --INVCONV
            , secondary_quantity_detailed        --INVCONV
            , organization_id
            , inventory_item_id
            , uom_code
            , txn_source_line_id
        FROM mtl_txn_request_lines
       WHERE line_id = p_line_id
         FOR UPDATE;

    CURSOR c_primary_uom IS
      SELECT primary_uom_code
        FROM mtl_system_items
       WHERE organization_id = l_organization_id
         AND inventory_item_id = l_inventory_item_id;

    /*Bug#5095840. Added the below cursor to fetch the source line id
      if 'p_txn_source_line_id' is passed as NULL.*/
    CURSOR c_txn_source_line IS
      SELECT source_line_id
      FROM wsh_delivery_details
      WHERE move_order_line_id IS NOT NULL
        AND move_order_line_id = p_line_id
	AND released_status = 'S';

    CURSOR c_reservations IS
      SELECT mr.reservation_id
        FROM mtl_reservations  mr
       WHERE mr.demand_source_type_id  IN (2,8)
         AND NVL(mr.staged_flag,'N')   <> 'Y'
         AND mr.demand_source_line_id   = l_txn_source_line_id
         AND mr.demand_source_line_detail IS NULL
         AND mr.primary_reservation_quantity > NVL(mr.detailed_quantity, 0);

    CURSOR c_undispatched_tasks IS
      SELECT mmtt.transaction_temp_id
           , ABS(mmtt.transaction_quantity)
           , ABS(mmtt.secondary_transaction_quantity)
           , ABS(mmtt.primary_quantity)
           , mmtt.reservation_id
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.move_order_line_id = p_line_id
         AND NOT EXISTS( SELECT 'Y'
                           FROM wms_dispatched_tasks wdt
                          WHERE wdt.transaction_temp_id
                                = nvl( mmtt.parent_line_id
                                     , mmtt.transaction_temp_id
                                     )
                       )
       ORDER BY mmtt.transaction_quantity ASC;

    CURSOR c_xdock_rsv
    ( p_wdd_id  IN  NUMBER
    ) IS
      SELECT mr.reservation_id
        FROM mtl_reservations  mr
       WHERE mr.demand_source_line_detail = p_wdd_id
         AND mr.demand_source_type_id    IN (2,8)
         AND NVL(mr.crossdock_flag,'N')   = 'Y'
         FOR UPDATE NOWAIT;

    CURSOR c_lock_wdd
    ( p_wdd_id  IN  NUMBER
    ) IS
      SELECT wdd.delivery_detail_id
           , wdd.requested_quantity
           , wdd.requested_quantity_uom
           , wdd.requested_quantity2
           , wdd.requested_quantity_uom2
        FROM wsh_delivery_details  wdd
       WHERE wdd.delivery_detail_id = p_wdd_id
         FOR UPDATE NOWAIT;

    l_wdd_rec    c_lock_wdd%ROWTYPE;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    SAVEPOINT reducemo_sp;

    -- {{
    -- BEGIN reduce_move_order_quantity }}
    --
    l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    IF (l_debug = 1) THEN
       DEBUG('Entered with parameters: '
              || '  p_line_id: '                || to_char(p_line_id)
              || ', p_reduction_quantity: '     || to_char(p_reduction_quantity)
              || ', p_sec_reduction_quantity: ' || to_char(p_sec_reduction_quantity)
              || ', p_txn_source_line_id: '     || to_char(p_txn_source_line_id)
              || ', p_delivery_detail_id: '     || to_char(p_delivery_detail_id)
            ,'Reduce_Move_Order_Quantity');
    END IF;

    IF p_reduction_quantity <= 0 THEN
       RETURN;
    END IF;

    l_deleted_quantity       := 0;
    l_sec_deleted_quantity   := 0; --INVCONV
    l_reduction_quantity     := p_reduction_quantity;
    l_sec_reduction_quantity := p_sec_reduction_quantity; --INVCONV

    IF p_line_id IS NOT NULL
    THEN
    -- {
       -- {{
       -- Verify that reduce API works as before for non-putaway
       -- (sales/internal order) move order lines }}
       --
       BEGIN
          SELECT NVL(mtrh.move_order_type,0)
            INTO l_move_order_type
            FROM mtl_txn_request_lines    mtrl
               , mtl_txn_request_headers  mtrh
           WHERE mtrl.line_id   = p_line_id
             AND mtrh.header_id = mtrl.header_id;

          IF (l_debug = 1) THEN
             DEBUG('Move order type: ' || to_char(l_move_order_type),'Reduce_Move_Order_Quantity');
          END IF;

          IF l_move_order_type <= 0
          THEN
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;

       EXCEPTION
          WHEN OTHERS THEN
             IF (l_debug = 1) THEN
                DEBUG('Unxexpected error querying MO type: '|| sqlerrm ,'Reduce_Move_Order_Quantity');
             END IF;
             RAISE fnd_api.g_exc_unexpected_error;
       END;

       -- {{
       -- Reduce API must return an error if called after
       -- pegged material is in Receiving }}
       --
       IF l_move_order_type = INV_GLOBALS.G_MOVE_ORDER_PUT_AWAY
       THEN
          IF (l_debug = 1) THEN
             DEBUG('Cannot reduce putaway MO line qty','Reduce_Move_Order_Quantity');
          END IF;
          fnd_message.set_name('WMS', 'INV_MOL_PUTAWAY_QTY_NOCHG');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
       END IF;

       -- query mo line info
       OPEN c_line_info;
       FETCH c_line_info
        INTO l_quantity
           , l_required_quantity /*Bug#5095840*/
           , l_quantity_detailed
           , l_sec_quantity
           , l_sec_required_quantity /*Bug#5095840*/
           , l_sec_quantity_detailed
           , l_organization_id
           , l_inventory_item_id
           , l_mo_uom_code
           , l_txn_source_line_id; --INVCONV

        IF (l_debug = 1) THEN
          DEBUG('Move order line details are:', 'Reduce_Move_Order_Quantity');
          DEBUG('l_quantity:'||l_quantity||' l_required_quantity:'||l_required_quantity, 'Reduce_Move_Order_Quantity');
          DEBUG('l_quantity_detailed : ' || l_quantity_detailed, 'Reduce_Move_Order_Quantity');
          DEBUG('l_organization_id : ' || l_organization_id, 'Reduce_Move_Order_Quantity');
          DEBUG('l_inventory_item_id : ' || l_inventory_item_id, 'Reduce_Move_Order_Quantity');
          DEBUG('l_mo_uom_code : ' || l_mo_uom_code, 'Reduce_Move_Order_Quantity');
          DEBUG('l_txn_source_line_id : ' || l_txn_source_line_id, 'Reduce_Move_Order_Quantity');
        END IF;

       IF c_line_info%NOTFOUND
       THEN
          IF (l_debug = 1) THEN
             DEBUG('Move order line not found', 'Reduce_Move_Order_Quantity');
          END IF;
          CLOSE c_line_info;
          RAISE fnd_api.g_exc_error;
       END IF;

       IF c_line_info%ISOPEN
       THEN
          CLOSE c_line_info;
       END IF;

       -- Call Cancel MO Line when Reduction Quantity > Quantity
       /*Bug#5095840. In the below IF statement, added the comparision of
         l_reduction_quantity with l_required_quantity as well.*/
       IF l_reduction_quantity >= l_quantity OR
          l_reduction_quantity >= l_required_quantity
       THEN
          cancel_move_order_line
          ( x_return_status       => l_return_status
          , x_msg_count           => x_msg_count
          , x_msg_data            => x_msg_data
          , p_line_id             => p_line_id
          , p_delete_reservations => 'Y'
          , p_txn_source_line_id  => p_txn_source_line_id
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

       --
       -- If not all of the move order quantity is detailed, we must reduce
       -- reservation quantity by the same amount that we reduce move order
       -- quantity.  The reservations which are eligible to be updated at this
       -- point are the reservations where rsv quantity > detailed quantity.
       --
       IF l_quantity > l_quantity_detailed
       THEN
       -- {
          l_quantity_to_delete := l_quantity - l_quantity_detailed;
          l_sec_quantity_to_delete := l_sec_quantity - l_sec_quantity_detailed; --INVCONV
          IF l_reduction_quantity < l_quantity_to_delete
          THEN
             l_quantity_to_delete     := l_reduction_quantity;
             l_sec_quantity_to_delete := l_sec_reduction_quantity; --INVCONV
             l_reduction_quantity     := 0;
             l_sec_reduction_quantity := 0; --INVCONV
          ELSE
             l_reduction_quantity     := l_reduction_quantity - l_quantity_to_delete;
             l_sec_reduction_quantity := l_sec_reduction_quantity - l_sec_quantity_to_delete; --INVCONV
          END IF;

          IF (l_debug = 1) THEN
            DEBUG('l_reduction_quantity :  ' || l_reduction_quantity, 'Reduce_Move_Order_Quantity');
            DEBUG('l_quantity_to_delete :  ' || l_quantity_to_delete, 'Reduce_Move_Order_Quantity');
          END IF;
          --Bug 9212270: No need to update l_quantity here
          --l_quantity := l_quantity - l_quantity_to_delete; /*Bug#5095840*/
          -- find primary qty to delete
          OPEN c_primary_uom;
          FETCH c_primary_uom INTO l_primary_uom_code;
          IF c_primary_uom%NOTFOUND THEN
             IF (l_debug = 1) THEN
                DEBUG('Item not found', 'Reduce_Move_Order_Quantity');
             END IF;
            CLOSE c_primary_uom;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
          CLOSE c_primary_uom;

          IF l_primary_uom_code <> l_mo_uom_code
          THEN
             l_prim_quantity_to_delete := inv_convert.inv_um_convert
                                          ( l_inventory_item_id
                                          , NULL
                                          , l_quantity_to_delete
                                          , l_mo_uom_code
                                          , l_primary_uom_code
                                          , NULL
                                          , NULL
                                          );
             IF (l_prim_quantity_to_delete = -99999)
             THEN
                IF (l_debug = 1) THEN
                   DEBUG('Cannot convert uom to primary uom', 'Reduce_Move_Order_Quantity');
                END IF;

                fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
                fnd_message.set_token('UOM', l_primary_uom_code);
                fnd_message.set_token('ROUTINE', 'Reduce Move Order Quantity');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          ELSE
             l_prim_quantity_to_delete := l_quantity_to_delete;
          END IF;

          l_sec_qty_to_delete := l_sec_quantity_to_delete; --INVCONV

          IF (l_debug = 1) THEN
            DEBUG('l_prim_quantity_to_delete: ' || l_prim_quantity_to_delete, 'Reduce_Move_Order_Quantity');
            DEBUG('l_txn_source_line_id: ' || l_txn_source_line_id, 'Reduce_Move_Order_Quantity');
          END IF;

          -- we query by the sales order line id.  If that value is not
          -- passed in, we need to get it from shipping table
          IF p_txn_source_line_id IS NOT NULL THEN
             l_txn_source_line_id := p_txn_source_line_id;
          ELSE /*Bug#5095840. Added this ELSE part*/
             OPEN c_txn_source_line;
             FETCH c_txn_source_line INTO l_txn_source_line_id;
             IF c_txn_source_line%NOTFOUND THEN
               CLOSE c_txn_source_line;
               IF ( l_debug = 1) THEN
                 DEBUG('Did Not Find Any Sales Order Line', 'Reduce_Move_Order_Quantity');
               END IF;
               RAISE No_Data_Found;
             END IF;
            CLOSE c_txn_source_line;
          END IF;

          OPEN c_reservations;
          LOOP
          -- {
             EXIT WHEN l_prim_quantity_to_delete <= 0;
             FETCH c_reservations INTO l_reservation_id;
             EXIT WHEN c_reservations%NOTFOUND;
             l_rsv_rec.reservation_id := l_reservation_id;

             -- query reservation
             inv_reservation_pvt.query_reservation
             ( p_api_version_number        => 1.0
             , p_init_msg_lst              => fnd_api.g_false
             , x_return_status             => l_return_status
             , x_msg_count                 => x_msg_count
             , x_msg_data                  => x_msg_data
             , p_query_input               => l_rsv_rec
             , x_mtl_reservation_tbl       => l_rsv_tbl
             , x_mtl_reservation_tbl_count => l_rsv_count
             , x_error_code                => l_error_code
             );

             IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('Query reservation returned error','Reduce_Move_Order_Quantity');
                END IF;
                RAISE fnd_api.g_exc_error;
             ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
             THEN
                IF (l_debug = 1) THEN
                   DEBUG('Query reservation returned unexpected error','Reduce_Move_Order_Quantity');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;

             l_update_rec := l_rsv_tbl(1);
             l_update_rec.reservation_quantity := NULL;

             -- INVCONV - Need to initialize secondary_qty
             l_update_rec.secondary_reservation_quantity := NULL;
             l_max_delete_quantity := l_update_rec.primary_reservation_quantity - l_update_rec.detailed_quantity;
             l_max_delete_sec_quantity := l_update_rec.secondary_reservation_quantity
                                         - l_update_rec.secondary_detailed_quantity; --INVCONV

             IF (l_debug = 1) THEN
                DEBUG('l_max_delete_quantity::' || l_max_delete_quantity, 'Reduce_Move_Order_Quantity');
              END IF;

             -- determine new reservation quantity
             IF l_max_delete_quantity > l_prim_quantity_to_delete
             THEN
                l_update_rec.primary_reservation_quantity := l_update_rec.primary_reservation_quantity
                                                            - l_prim_quantity_to_delete;
                l_prim_quantity_to_delete := 0;
                l_sec_qty_to_delete       := 0; --INVCONV
                l_update_rec.secondary_reservation_quantity := l_update_rec.secondary_reservation_quantity
                                                            - l_sec_quantity_to_delete; --INVCONV
             ELSE
                l_prim_quantity_to_delete := l_prim_quantity_to_delete - l_max_delete_quantity;
                l_update_rec.primary_reservation_quantity := l_update_rec.primary_reservation_quantity
                                                            - l_max_delete_quantity;
                l_sec_qty_to_delete := l_sec_qty_to_delete - l_max_delete_sec_quantity; --INVCONV
                l_update_rec.secondary_reservation_quantity := l_update_rec.secondary_reservation_quantity
                                                           - l_max_delete_sec_quantity;  --INVCONV
             END IF;

             -- INVCONV - Make sure Qty2 are NULL if not present
             IF ( l_update_rec.secondary_uom_code IS NULL ) THEN
                l_update_rec.secondary_reservation_quantity := NULL;
                l_update_rec.secondary_detailed_quantity    := NULL;
             END IF;

             IF (l_debug = 1) THEN
               DEBUG('l_update_rec.primary_reservation_quantity::' || l_update_rec.primary_reservation_quantity,
                     'Reduce_Move_Order_Quantity');
               DEBUG('l_update_rec.detailed_quantity::' || l_update_rec.detailed_quantity, 'Reduce_Move_Order_Quantity');
             END IF;

             -- update reservation
             inv_reservation_pub.update_reservation
             ( p_api_version_number     => 1.0
             , p_init_msg_lst           => fnd_api.g_false
             , x_return_status          => l_return_status
             , x_msg_count              => x_msg_count
             , x_msg_data               => x_msg_data
             , p_original_rsv_rec       => l_rsv_tbl(1)
             , p_to_rsv_rec             => l_update_rec
             , p_original_serial_number => l_dummy_sn
             , p_to_serial_number       => l_dummy_sn
             , p_validation_flag        => fnd_api.g_true
             );

             IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                   DEBUG('Update reservation returned error','Reduce_Move_Order_Quantity');
                END IF;
                RAISE fnd_api.g_exc_error;
             ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
             THEN
                IF (l_debug = 1) THEN
                   DEBUG('Update reservation returned unexpected error','Reduce_Move_Order_Quantity');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          -- }
          END LOOP;

          CLOSE c_reservations;
       -- }
       END IF;

       IF l_reduction_quantity > 0
       THEN
       -- {
          -- Check if WMS is installed
          IF inv_install.adv_inv_installed(l_organization_id)
          THEN
          -- {
             OPEN c_undispatched_tasks;
             LOOP
             -- {
                EXIT WHEN l_reduction_quantity <= 0;
                FETCH c_undispatched_tasks
                 INTO l_transaction_temp_id
                    , l_task_qty
                    , l_sec_qty
                    , l_primary_quantity
                    , l_reservation_id;
                IF (l_debug = 1) THEN
                  DEBUG('l_task_qty: ' || l_task_qty, 'Reduce_Move_Order_Quantity');
                  DEBUG('l_transaction_temp_id: ' || l_transaction_temp_id, 'Reduce_Move_Order_Quantity');
                  DEBUG('l_primary_quantity: ' || l_primary_quantity, 'Reduce_Move_Order_Quantity');
                  DEBUG('l_reservation_id: ' || l_reservation_id, 'Reduce_Move_Order_Quantity');
                END IF;
                EXIT WHEN c_undispatched_tasks%NOTFOUND;

                IF l_task_qty > l_reduction_quantity THEN
                   l_quantity_to_delete := l_reduction_quantity;
                   l_sec_quantity_to_delete := l_sec_reduction_quantity; --INVCONV
                ELSE
                   l_quantity_to_delete := l_task_qty;
                   l_sec_quantity_to_delete := l_sec_qty; --INVCONV
                END IF;

                l_reduction_quantity := l_reduction_quantity
                                        - l_quantity_to_delete;
                l_sec_reduction_quantity := l_sec_reduction_quantity
                                            - l_sec_quantity_to_delete; --INVCONV

                IF (l_debug = 1) THEN
                  DEBUG('calling reduce_rsv_allocation with l_reduction_quantity: ' || l_reduction_quantity, 'Reduce_Move_Order_Quantity');
                  DEBUG('l_quantity_to_delete: ' || l_quantity_to_delete, 'Reduce_Move_Order_Quantity');
                  DEBUG('l_transaction_temp_id: ' || l_transaction_temp_id, 'Reduce_Move_Order_Quantity');
                END IF;
                -- Removing reservation and allocation for this task
                reduce_rsv_allocation
                ( x_return_status          => l_return_status
                , x_msg_count              => x_msg_count
                , x_msg_data               => x_msg_data
                , p_transaction_temp_id    => l_transaction_temp_id
                , p_quantity_to_delete     => l_quantity_to_delete
                , p_sec_quantity_to_delete => l_sec_quantity_to_delete
                );

                l_deleted_quantity := l_deleted_quantity
                                      + l_quantity_to_delete;
                l_sec_deleted_quantity := l_sec_deleted_quantity
                                          + l_sec_quantity_to_delete; --INCONV
             -- }
                IF (l_debug = 1) THEN
                  DEBUG('l_deleted_quantity: ' || l_deleted_quantity, 'Reduce_Move_Order_Quantity');
                  DEBUG('l_reduction_quantity: ' || l_reduction_quantity, 'Reduce_Move_Order_Quantity');
                END IF;
             END LOOP; -- loop through each task

             CLOSE c_undispatched_tasks;
          -- }
          END IF; -- wms installed
       -- }
       END IF; -- allocations exists

       --
       -- No matter what happens above, we want to reduce the shipping
       -- quantity by the original reduction quantity.  We know shipping qty
       -- is greater than reduction quantity, since we checked that at the
       -- beginning of the procedure.
       --

       l_required_quantity := l_required_quantity - p_reduction_quantity; /*Bug#5095840*/
       --Bug 9212270: corrected computation for sec_req_qty
       l_sec_required_quantity := l_sec_required_quantity - p_sec_reduction_quantity; /*Bug#5095840*/
       l_quantity := l_quantity - l_deleted_quantity;/*Bug#5095840*/
       l_sec_quantity := l_sec_quantity - l_sec_deleted_quantity; --INVCONV/*Bug#5095840*/

       --Bug 5054658
       --Decremented quantity_detailed in addition to quantity
       --and update the move order line with the decremented quantity
       --Bug 9212270: Commented since we do not update detailed_quantity
       /*IF (NVL(l_quantity_detailed, 0) > 0) THEN
         IF l_quantity_detailed > p_reduction_quantity THEN
           l_quantity_detailed := l_quantity_detailed - p_reduction_quantity;
         END IF;
       ELSE
         l_quantity_detailed := 0;
       END IF;

       IF (NVL(l_sec_quantity_detailed, 0) > 0) THEN
         IF l_sec_quantity_detailed > p_sec_reduction_quantity THEN
           l_sec_quantity_detailed := l_sec_quantity_detailed - p_sec_reduction_quantity;
         END IF;
       ELSE
         l_sec_quantity_detailed := 0;
       END IF;*/

       IF (l_debug = 1) THEN
         DEBUG(' update MTRL with quantity:  ' || l_quantity ||
               ', quantity_detailed: ' || l_quantity_detailed ||', l_required_quantity: '||l_required_quantity
               , 'Reduce_Move_Order_Quantity');
       END IF;

       --  Update line status, quantity, and required_quantity
       /*Bug#5095840. Modified the below UPDATE statement to update
         the 'required_quantity' and 'secondary_required_quantity' with
         'l_required_quantity' and 'l_sec_required_quantity' respectively
         rather than with NULL. Also updation of 'quantity_detailed' is
         commented.*/
       --Bug 9212270: Do not update sec_qty_det
       UPDATE mtl_txn_request_lines
          SET quantity           = l_quantity
            , required_quantity  = l_required_quantity
            , secondary_quantity = l_sec_quantity --INVCONV
            , secondary_required_quantity = l_sec_required_quantity  --INVCONV
--            , quantity_detailed = l_quantity_detailed
            --, secondary_quantity_detailed = l_sec_quantity_detailed
        WHERE line_id = p_line_id;

    -- }
    ELSE -- MO line is null, so process xdock reservations
    -- {
       -- {{
       -- Reduce quantity on a sales/internal order line
       -- that is pegged to material not yet received
       -- Reservations are reduced or deleted }}
       --
       BEGIN
          OPEN c_lock_wdd (p_delivery_detail_id);
          FETCH c_lock_wdd INTO l_wdd_rec;
          CLOSE c_lock_wdd;
       EXCEPTION
          WHEN record_locked THEN
             IF (l_debug = 1)
             THEN
                DEBUG('Unable to lock WDD: ' || to_char(p_delivery_detail_id)
                     ,'Reduce_Move_Order_Quantity');
             END IF;
             IF c_lock_wdd%ISOPEN
             THEN
                CLOSE c_lock_wdd;
             END IF;
             fnd_message.set_name('INV', 'INV_WDD_LOCK_FAIL');
             fnd_msg_pub.ADD;
             fnd_msg_pub.count_and_get
             ( p_count   => x_msg_count
             , p_data    => x_msg_data
             , p_encoded => 'F'
             );
             RAISE fnd_api.g_exc_error;
       END;

       IF (l_debug = 1)
       THEN
          DEBUG('Locked WDD: ' || to_char(p_delivery_detail_id)
               ,'Reduce_Move_Order_Quantity');
       END IF;

       --
       -- Lock and fetch reservations for the WDD record
       -- For each record:
       --   If rsv qty (after conv to WDD UOM) >
       --   remaining qty to reduce
       --      Reduce qty and exit
       --   else
       --      Delete rsv, decrement remaining reduction qty
       --
       l_xdock_rsv_tbl.DELETE;
       BEGIN
          OPEN c_xdock_rsv (p_delivery_detail_id);
          FETCH c_xdock_rsv BULK COLLECT INTO l_xdock_rsv_tbl;
          CLOSE c_xdock_rsv;
       EXCEPTION
          WHEN record_locked THEN
             DEBUG('Unable to lock xdock rsv record(s)'
                  ,'Reduce_Move_Order_Quantity');
             IF c_xdock_rsv%ISOPEN
             THEN
                CLOSE c_xdock_rsv;
             END IF;
             fnd_message.set_name('WMS', 'INV_RSV_LOCK_FAIL');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
       END;

       wms_xdock_utils_pvt.g_demand_triggered := TRUE;

       l_rsv_index := l_xdock_rsv_tbl.FIRST;
       LOOP
       -- {
          IF (l_xdock_rsv_tbl.COUNT = 0) THEN
             IF (l_debug = 1) THEN
                DEBUG('No xdock rsv records to process'
                     ,'Reduce_Move_Order_Quantity');
             END IF;
             EXIT;
          END IF;

          EXIT WHEN l_reduction_quantity <= 0;

          l_rsv_rec.reservation_id := l_xdock_rsv_tbl(l_rsv_index);

          IF (l_debug = 1) THEN
             DEBUG('Reservation ID = ' || to_char(l_rsv_rec.reservation_id)
                  ,'Reduce_Move_Order_Quantity');
          END IF;

          -- query reservation
          inv_reservation_pvt.query_reservation
          ( p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_query_input                => l_rsv_rec
          , x_mtl_reservation_tbl        => l_rsv_tbl
          , x_mtl_reservation_tbl_count  => l_rsv_count
          , x_error_code                 => l_error_code
          );

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
             IF (l_debug = 1) THEN
                DEBUG('Error: Query Reservations returned '
                       || x_return_status
                     ,'Reduce_Move_Order_Quantity');
             END IF;
             IF x_return_status = fnd_api.g_ret_sts_error
             THEN
                fnd_message.set_name('INV','INV_QRY_RSV_FAILED');
                fnd_msg_pub.ADD;
                fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                                          p_data    => x_msg_data,
                                          p_encoded => 'F');
                RAISE fnd_api.g_exc_error;
             ELSE
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          END IF;

          IF l_rsv_count <= 0 THEN
             IF (l_debug = 1) THEN
                DEBUG('Error: Query Reservations returned Reservation Count 0'
                     ,'Reduce_Move_Order_Quantity');
             END IF;
             fnd_message.set_name('INV','INV_NO_RSVS_FOUND');
             fnd_msg_pub.ADD;

             fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                                       p_data    => x_msg_data,
                                       p_encoded => 'F');
             RAISE fnd_api.g_exc_error;
          END IF;

          l_rsv_rec2 := l_rsv_tbl(1);

          -- Convert reduction qty to current RSV UOM
          IF l_wdd_rec.requested_quantity_uom
             = l_rsv_rec2.reservation_uom_code
          THEN
             l_reduc_qty_conv := l_reduction_quantity;
          ELSE
             inv_convert.inv_um_conversion
             ( from_unit => l_wdd_rec.requested_quantity_uom
             , to_unit   => l_rsv_rec2.reservation_uom_code
             , item_id   => l_rsv_rec2.inventory_item_id
             , uom_rate  => l_conv_rate
             );
             IF (NVL(l_conv_rate,0) <= 0)
             THEN
                IF (l_debug = 1)
                THEN
                   DEBUG('Invalid conversion factor: ' || l_conv_rate
                        ,'Reduce_Move_Order_Quantity');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
             ELSE
                l_reduc_qty_conv := ROUND( l_conv_rate * l_reduction_quantity
                                         , g_conv_precision
                                         );
             END IF;
          END IF;

          IF l_rsv_rec2.reservation_quantity > l_reduc_qty_conv
          THEN
          -- {
             -- Determine primary qty to reduce
             IF l_wdd_rec.requested_quantity_uom
                = l_rsv_rec2.primary_uom_code
             THEN
                l_prim_qty_conv := l_reduction_quantity;
             ELSE
                inv_convert.inv_um_conversion
                ( from_unit => l_wdd_rec.requested_quantity_uom
                , to_unit   => l_rsv_rec2.primary_uom_code
                , item_id   => l_rsv_rec2.inventory_item_id
                , uom_rate  => l_conv_rate
                );
                IF (NVL(l_conv_rate,0) <= 0)
                THEN
                   IF (l_debug = 1)
                   THEN
                      DEBUG('Invalid conversion factor: ' || l_conv_rate
                           ,'Reduce_Move_Order_Quantity');
                   END IF;
                   RAISE fnd_api.g_exc_unexpected_error;
                ELSE
                   l_prim_qty_conv := ROUND( l_conv_rate * l_reduction_quantity
                                           , g_conv_precision
                                           );
                END IF;
             END IF;

             -- Convert secondary qty if required
             IF NVL(l_sec_reduction_quantity,0) > 0
                AND
                l_wdd_rec.requested_quantity_uom2 IS NOT NULL
             THEN
                IF l_wdd_rec.requested_quantity_uom2
                   = l_rsv_rec2.secondary_uom_code
                THEN
                   l_sec_reduc_qty_conv := l_sec_reduction_quantity;
                ELSE
                   inv_convert.inv_um_conversion
                   ( from_unit => l_wdd_rec.requested_quantity_uom2
                   , to_unit   => l_rsv_rec2.secondary_uom_code
                   , item_id   => l_rsv_rec2.inventory_item_id
                   , uom_rate  => l_conv_rate
                   );
                   IF (NVL(l_conv_rate,0) <= 0)
                   THEN
                      IF (l_debug = 1)
                      THEN
                         DEBUG('Invalid conversion factor: ' || l_conv_rate
                              ,'Reduce_Move_Order_Quantity');
                      END IF;
                      RAISE fnd_api.g_exc_unexpected_error;
                   ELSE
                      l_sec_reduc_qty_conv := ROUND( l_conv_rate * l_sec_reduction_quantity
                                                   , g_conv_precision
                                                   );
                   END IF;
                END IF;
             END IF; -- end IF secondary UOM specified

             l_update_rec := l_rsv_tbl(1);
             l_update_rec.reservation_quantity
               := l_update_rec.reservation_quantity - l_reduc_qty_conv;
             l_update_rec.primary_reservation_quantity
               := l_update_rec.primary_reservation_quantity - l_prim_qty_conv;

             IF l_update_rec.secondary_uom_code IS NOT NULL
             THEN
                l_update_rec.secondary_reservation_quantity
                  := l_update_rec.secondary_reservation_quantity
                       - l_sec_reduc_qty_conv;
             END IF;

             inv_reservation_pub.update_reservation
             ( p_api_version_number     => 1.0
             , p_init_msg_lst           => fnd_api.g_false
             , x_return_status          => x_return_status
             , x_msg_count              => x_msg_count
             , x_msg_data               => x_msg_data
             , p_original_rsv_rec       => l_rsv_tbl(1)
             , p_to_rsv_rec             => l_update_rec
             , p_original_serial_number => l_dummy_sn
             , p_to_serial_number       => l_dummy_sn
             , p_validation_flag        => fnd_api.g_true
             );

             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                IF (l_debug = 1) THEN
                   DEBUG('Error: Update Reservations returned '
                          || x_return_status
                        ,'Reduce_Move_Order_Quantity');
                END IF;
                IF x_return_status = fnd_api.g_ret_sts_error
                THEN
                   fnd_message.set_name('INV','INV_UPDATE_RSV_FAILED');
                   fnd_msg_pub.ADD;
                   fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                                             p_data    => x_msg_data,
                                             p_encoded => 'F');
                   RAISE fnd_api.g_exc_error;
                ELSE
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;

             l_reduction_quantity := 0;
             l_sec_reduction_quantity := 0;
          -- }
          ELSE -- RSV qty <= qty to reduce, so delete RSV
          -- {
             IF l_rsv_rec2.reservation_quantity = l_reduc_qty_conv
             THEN
                l_reduction_quantity := 0;
                l_sec_reduction_quantity := 0;
             ELSE
             -- {
                -- Convert RSV qty to WDD UOM
                IF l_wdd_rec.requested_quantity_uom
                   = l_rsv_rec2.reservation_uom_code
                THEN
                   l_reduction_quantity := l_reduction_quantity
                                             - l_rsv_rec2.reservation_quantity;
                ELSE
                   inv_convert.inv_um_conversion
                   ( from_unit => l_rsv_rec2.reservation_uom_code
                   , to_unit   => l_wdd_rec.requested_quantity_uom
                   , item_id   => l_rsv_rec2.inventory_item_id
                   , uom_rate  => l_conv_rate
                   );
                   IF (NVL(l_conv_rate,0) <= 0)
                   THEN
                      IF (l_debug = 1)
                      THEN
                         DEBUG('Invalid conversion factor: ' || l_conv_rate
                              ,'Reduce_Move_Order_Quantity');
                      END IF;
                      RAISE fnd_api.g_exc_unexpected_error;
                   ELSE
                      l_reduction_quantity := l_reduction_quantity
                                              - ROUND( l_conv_rate
                                                       * l_rsv_rec2.reservation_quantity
                                                     , g_conv_precision
                                                     );
                   END IF;
                END IF;

                -- Convert secondary qty if required
                IF NVL(l_sec_reduction_quantity,0) > 0
                   AND
                   l_wdd_rec.requested_quantity_uom2 IS NOT NULL
                THEN
                   IF l_wdd_rec.requested_quantity_uom2
                      = l_rsv_rec2.secondary_uom_code
                   THEN
                      l_sec_reduction_quantity
                        := l_sec_reduction_quantity
                             - l_rsv_rec2.secondary_reservation_quantity;
                   ELSE
                      inv_convert.inv_um_conversion
                      ( from_unit => l_rsv_rec2.secondary_uom_code
                      , to_unit   => l_wdd_rec.requested_quantity_uom2
                      , item_id   => l_rsv_rec2.inventory_item_id
                      , uom_rate  => l_conv_rate
                      );
                      IF (NVL(l_conv_rate,0) <= 0)
                      THEN
                         IF (l_debug = 1)
                         THEN
                            DEBUG('Invalid conversion factor: ' || l_conv_rate
                                 ,'Reduce_Move_Order_Quantity');
                         END IF;
                         RAISE fnd_api.g_exc_unexpected_error;
                      ELSE
                         l_sec_reduction_quantity := l_sec_reduction_quantity
                                                     - ROUND( l_conv_rate
                                                              * l_rsv_rec2.secondary_reservation_quantity
                                                            , g_conv_precision
                                                            );
                      END IF;
                   END IF; -- end IF secondary UOMs match
                END IF; -- end IF secondary UOM specified
             -- }
             END IF;

             IF (l_debug = 1) THEN
                DEBUG('About to delete reservation ID: '
                       || to_char(l_rsv_rec2.reservation_id)
                     ,'Reduce_Move_Order_Quantity');
             END IF;

             inv_reservation_pub.delete_reservation
             ( p_api_version_number => 1.0
             , p_init_msg_lst       => fnd_api.g_false
             , x_return_status      => x_return_status
             , x_msg_count          => x_msg_count
             , x_msg_data           => x_msg_data
             , p_rsv_rec            => l_rsv_rec2
             , p_serial_number      => l_serial_tbl
             );

             IF x_return_status <> fnd_api.g_ret_sts_success
             THEN
                IF (l_debug = 1)
                THEN
                   DEBUG('inv_reservation_pub.delete_reservation returned an error status: '
                          || x_return_status, 'Reduce_Move_Order_Quantity');
                END IF;

                IF x_return_status = fnd_api.g_ret_sts_error
                THEN
                   fnd_msg_pub.count_and_get
                   ( p_count   => x_msg_count
                   , p_data    => x_msg_data
                   , p_encoded => 'F'
                   );
                   IF (l_debug = 1)
                   THEN
                      DEBUG('x_msg_data: ' || x_msg_data
                           ,'Reduce_Move_Order_Quantity');
                   END IF;
                   RAISE fnd_api.g_exc_error;
                ELSE
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;
             ELSE
                IF (l_debug = 1)
                THEN
                   DEBUG('inv_reservation_pub.delete_reservation returned success'
                        ,'Reduce_Move_Order_Quantity');
                END IF;
             END IF;
          -- }
          END IF;

          EXIT WHEN l_rsv_index = l_xdock_rsv_tbl.LAST;
          l_rsv_index := l_xdock_rsv_tbl.NEXT(l_rsv_index);
       -- }
       END LOOP;

       wms_xdock_utils_pvt.g_demand_triggered := FALSE;

       l_xdock_rsv_tbl.DELETE;
    -- }
    END IF;

    -- {{
    -- END reduce_move_order_quantity }}
    --

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO reducemo_sp;
      wms_xdock_utils_pvt.g_demand_triggered := FALSE;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
      ( p_count   => x_msg_count
      , p_data    => x_msg_data
      , p_encoded => 'F'
      );
      IF (l_debug = 1)
      THEN
         DEBUG('x_msg_data: ' || x_msg_data
              ,'Reduce_Move_Order_Quantity');
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO reducemo_sp;
      wms_xdock_utils_pvt.g_demand_triggered := FALSE;
      IF (l_debug = 1) THEN
         DEBUG('Others error' || SQLERRM
              ,'Reduce_Move_Order_Quantity');
      END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

  END reduce_move_order_quantity;


  --Procedure
  --reduce_rsv_allocation
  --Description
  -- This procedure is called from WMSTSKUB.pls and
  --inv_mo_cancel_pvt.reduce_move_order_quantity .Given the
  --transaction_temp_id AND quantity TO DELETE it deletes/reduces allocations

  PROCEDURE reduce_rsv_allocation(
    x_return_status          OUT NOCOPY    VARCHAR2
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , p_transaction_temp_id     IN            NUMBER
  , p_quantity_to_delete      IN            NUMBER
  , p_sec_quantity_to_delete  IN            NUMBER  DEFAULT NULL --INVCONV
  , p_ato_serial_pick         IN            VARCHAR2 DEFAULT NULL --7190635 Added to check whether the call is for ATO serial picking
  ) IS
    l_reservation_id          NUMBER;
    l_transaction_temp_id     NUMBER;
    l_task_qty                NUMBER;
    l_primary_quantity        NUMBER;
    l_rsv_rec                 inv_reservation_global.mtl_reservation_rec_type;
    l_rsv_tbl                 inv_reservation_global.mtl_reservation_tbl_type;
    l_update_rec              inv_reservation_global.mtl_reservation_rec_type;
    l_rsv_count               NUMBER;
    l_dummy_sn                inv_reservation_global.serial_number_tbl_type;
    l_quantity_to_delete      NUMBER;
    l_sec_quantity_to_delete  NUMBER;  --INVCONV
    l_sec_qty                 NUMBER;  --INVCONV
    l_sec_deleted_quantity    NUMBER;  --INVCONV
    l_sec_qty_to_delete       NUMBER;  --INVCONV
    l_mo_uom_code             VARCHAR2(3);
    l_primary_uom_code        VARCHAR2(3);
    l_inventory_item_id       NUMBER;
    l_prim_quantity_to_delete NUMBER;
    l_organization_id         NUMBER;
    l_deleted_quantity        NUMBER;
    l_return_status           VARCHAR2(1);
    l_error_code              NUMBER;
    l_ato_serial_pick         VARCHAR2(1); -- Bug 7190635
    l_retain_ato_profile VARCHAR2(1)  := NVL(fnd_profile.VALUE('WSH_RETAIN_ATO_RESERVATIONS'),'N'); --Bug 7190635

    CURSOR c_primary_uom IS
      SELECT primary_uom_code
        FROM mtl_system_items
       WHERE organization_id = l_organization_id
         AND inventory_item_id = l_inventory_item_id;

    l_debug                   NUMBER                                          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      DEBUG('Setting Savepoint', 'reduce_rsv_allocation');
    END IF;

    SAVEPOINT del_rsv_all_sp;
    l_transaction_temp_id      := p_transaction_temp_id;
    l_deleted_quantity         := 0;
    l_quantity_to_delete       := p_quantity_to_delete;
    l_sec_deleted_quantity     := 0; --INVCONV
    l_sec_quantity_to_delete   := p_sec_quantity_to_delete; --INVCONV
    l_ato_serial_pick          := NVL(p_ato_serial_pick,'N'); --Bug 7190635

    IF (l_debug = 1) THEN
      DEBUG(' transaction_temp_id:' || l_transaction_temp_id, 'reduce_rsv_allocation');
      DEBUG('quantity_to_delete:' || l_quantity_to_delete, 'reduce_rsv_allocation');
      DEBUG('sec_quantity_to_delete:' || l_sec_quantity_to_delete, 'reduce_rsv_allocation');
    END IF;

    SELECT ABS(mmtt.transaction_quantity)
         , ABS(mmtt.primary_quantity)
         , ABS(mmtt.secondary_transaction_quantity) --INVCONV
         , mmtt.reservation_id
         , mmtt.organization_id
         , mmtt.inventory_item_id
         , mtrl.uom_code
-- INVCONV correcting the orders
      INTO l_task_qty
         , l_primary_quantity
         , l_sec_qty    --INVCONV
         , l_reservation_id
         , l_organization_id
         , l_inventory_item_id
         , l_mo_uom_code
      FROM mtl_material_transactions_temp mmtt, mtl_txn_request_lines mtrl
     WHERE mmtt.transaction_temp_id = l_transaction_temp_id
       AND mmtt.move_order_line_id = mtrl.line_id;

    -- find quantity to delete in primary UOM
    OPEN c_primary_uom;
    FETCH c_primary_uom INTO l_primary_uom_code;

    IF c_primary_uom%NOTFOUND THEN
      IF (l_debug = 1) THEN
        DEBUG('Move order line not found', 'reduce_rsv_allocation');
      END IF;

      CLOSE c_primary_uom;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    CLOSE c_primary_uom;

    IF (l_debug = 1) THEN
      DEBUG('before uom check', 'reduce_rsv_allocation');
    END IF;

    IF l_primary_uom_code <> l_mo_uom_code THEN
      l_prim_quantity_to_delete  :=
                 inv_convert.inv_um_convert(l_inventory_item_id, NULL, l_quantity_to_delete, l_mo_uom_code, l_primary_uom_code, NULL, NULL);

      IF (l_prim_quantity_to_delete = -99999) THEN
        IF (l_debug = 1) THEN
          DEBUG('Cannot convert uom to primary uom', 'reduce_rsv_allocation');
        END IF;

        fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
        fnd_message.set_token('UOM', l_primary_uom_code);
        fnd_message.set_token('ROUTINE', 'reduce_rsv_allocation');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE
      l_prim_quantity_to_delete  := l_quantity_to_delete;
    END IF;
      l_sec_qty_to_delete := l_sec_quantity_to_delete; --INVCONV
    -- if the allocation corresponds to a reservation, we need to update
    -- the reservation
   IF l_ato_serial_pick = 'N' THEN   --Bug 7190635
    IF l_reservation_id IS NOT NULL THEN
      l_rsv_rec.reservation_id           := l_reservation_id;

      IF (l_debug = 1) THEN
        DEBUG('query reservation', 'reduce_rsv_allocation');
      END IF;

      -- query reservation
      inv_reservation_pvt.query_reservation(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_query_input                => l_rsv_rec
      , x_mtl_reservation_tbl        => l_rsv_tbl
      , x_mtl_reservation_tbl_count  => l_rsv_count
      , x_error_code                 => l_error_code
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Query reservation returned  error', 'reduce_rsv_allocation');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Query reservation returned unexpected error', 'reduce_rsv_allocation');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_update_rec                       := l_rsv_tbl(1);

      -- update detailed quantity
      IF l_update_rec.detailed_quantity > l_prim_quantity_to_delete THEN
        l_update_rec.detailed_quantity  := l_update_rec.detailed_quantity - l_prim_quantity_to_delete;
        l_update_rec.secondary_detailed_quantity  := l_update_rec.secondary_detailed_quantity - l_sec_qty_to_delete; --INCONV
      ELSE
        l_update_rec.detailed_quantity  := 0;
        l_update_rec.secondary_detailed_quantity  := 0; --INCONV
      END IF;


      l_update_rec.reservation_quantity  := NULL;

      --set primary reservation quantity
      IF l_update_rec.primary_reservation_quantity > l_prim_quantity_to_delete THEN
        l_update_rec.primary_reservation_quantity  := l_update_rec.primary_reservation_quantity - l_prim_quantity_to_delete;
        l_update_rec.secondary_reservation_quantity  := l_update_rec.secondary_reservation_quantity - l_sec_qty_to_delete; --INVCONV
      ELSE -- delete entire reservation
        l_update_rec.primary_reservation_quantity  := 0;
        l_update_rec.secondary_reservation_quantity  := 0; --INVCONV
      END IF; -- rsv qty > task qty

      IF (l_debug = 1) THEN
        DEBUG('update reservation', 'reduce_rsv_allocation');
      END IF;

-- INVCONV - Make sure Qty2 are NULL if nor present
        IF (  l_update_rec.secondary_uom_code IS NULL ) THEN
              l_update_rec.secondary_reservation_quantity := NULL;
              l_update_rec.secondary_detailed_quantity    := NULL;
        END IF;

      -- update reservations
      inv_reservation_pub.update_reservation(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_original_rsv_rec           => l_rsv_tbl(1)
      , p_to_rsv_rec                 => l_update_rec
      , p_original_serial_number     => l_dummy_sn
      , p_to_serial_number           => l_dummy_sn
      , p_validation_flag            => fnd_api.g_true
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Update reservation returned error', 'reduce_rsv_allocation');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Update reservation returned unexpected error', 'reduce_rsv_allocation');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- reservation id is not null
   END IF; --Bug 7190635, l_ato_serial_pick is 'N'

      IF (l_debug = 1) THEN
         DEBUG('Retain ATO reservation:'||l_retain_ato_profile, 'reduce_rsv_allocation');
         DEBUG('Quantity to delete:'||l_quantity_to_delete, 'reduce_rsv_allocation');
         DEBUG('reservation id:'||l_reservation_id, 'reduce_rsv_allocation');
      END IF;
            -- If we are deleting entire allocation
    --Bug 7190635, we are deleting entire allocation for ATO serial picking

    IF l_quantity_to_delete = l_task_qty
        OR (l_retain_ato_profile = 'Y'  AND l_ato_serial_pick='Y') THEN
      l_deleted_quantity  := l_deleted_quantity + l_task_qty;
      l_sec_deleted_quantity  := l_sec_deleted_quantity + l_sec_qty; --INVCONV

      inv_trx_util_pub.delete_transaction(
        x_return_status       => l_return_status
      , x_msg_data            => x_msg_data
      , x_msg_count           => x_msg_count
      , p_transaction_temp_id => l_transaction_temp_id
      );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF (l_debug = 1) THEN
          DEBUG('Error occurred while Deleting the Transaction', 'reduce_rsv_allocation');
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE -- reduce the quantity on the allocation
      IF (l_debug = 1) THEN
        DEBUG('reducing quantity on the allocation', 'reduce_rsv_allocation');
      END IF;

      l_deleted_quantity  := l_deleted_quantity + l_quantity_to_delete;
      l_sec_deleted_quantity  := l_sec_deleted_quantity + l_sec_quantity_to_delete; --INVCONV
      inv_mo_line_detail_util.reduce_allocation_quantity(
        x_return_status       => l_return_status
      , p_transaction_temp_id => l_transaction_temp_id
      , p_quantity            => l_quantity_to_delete
      , p_secondary_quantity  => l_sec_quantity_to_delete --INVCONV
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Reduce allocation returned error', 'reduce_rsv_allocation');
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          DEBUG('Reduce allocation returned unexpected error', 'reduce_rsv_allocation');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- det. quantity = task qty

    x_return_status        := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO del_rsv_all_sp;
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN OTHERS THEN
      ROLLBACK TO del_rsv_all_sp;

      IF (l_debug = 1) THEN
        DEBUG('Others error' || SQLERRM, 'reduce_rsv_allocation');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END reduce_rsv_allocation;


  /* The following procedure is called by shipping to update carton group id whenever
     shipping unassign a wdd line from a delivery */
  PROCEDURE update_mol_carton_group
  ( x_return_status       OUT NOCOPY   VARCHAR2
  , x_msg_cnt             OUT NOCOPY   NUMBER
  , x_msg_data            OUT NOCOPY   VARCHAR2
  , p_line_id             IN           NUMBER
  , p_carton_grouping_id  IN           NUMBER
  ) IS

    l_debug    NUMBER;
    l_mo_type  NUMBER;

    CURSOR c_get_mo_type
    ( p_mo_line_id  IN  NUMBER
    ) IS
      SELECT mtrh.move_order_type
        FROM mtl_txn_request_lines    mtrl
           , mtl_txn_request_headers  mtrh
       WHERE mtrl.line_id   = p_mo_line_id
         AND mtrh.header_id = mtrl.header_id;

  BEGIN
    IF (l_debug = 1) THEN
       DEBUG('move order line id: ' || p_line_id, 'update_mol_carton_group');
       DEBUG('carton group id: ' || p_carton_grouping_id, 'update_mol_carton_group');
       DEBUG('before update statement...', 'update_mol_carton_group');
    END IF;

    l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    x_return_status  := fnd_api.g_ret_sts_success;

    -- {{
    -- BEGIN update_mol_carton_group }}
    --
    OPEN c_get_mo_type(p_line_id);
    FETCH c_get_mo_type INTO l_mo_type;
    CLOSE c_get_mo_type;

    IF l_mo_type <> INV_GLOBALS.G_MOVE_ORDER_PUT_AWAY
    THEN
       -- {{
       -- Unassign a pick released delivery detail from
       -- the delivery.  Carton grouping ID must get updated }}
       --
       UPDATE mtl_txn_request_lines
          SET carton_grouping_id = p_carton_grouping_id
        WHERE line_id = p_line_id;

       -- {{
       -- Unassign a cross dock pegged delivery detail from
       -- the delivery, with material already received.
       -- Carton grouping ID column stays as is }}
       --
       IF SQL%NOTFOUND THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;

         IF (l_debug = 1) THEN
            DEBUG('can not find move order line', 'update_mol_carton_group');
         END IF;

         fnd_message.set_name('INV', 'INV_PP_INPUT_LINE_NOT_FOUND');
         fnd_msg_pub.ADD;
       END IF;

       IF (l_debug = 1) THEN
          DEBUG('after update statement', 'update_mol_carton_group');
       END IF;
    END IF;

    -- {{
    -- END update_mol_carton_group }}
    --

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
         DEBUG('Exception: ' || sqlerrm, 'update_mol_carton_group');
      END IF;

      fnd_message.set_name('INV', 'FAIL_TO_UPDATE_CARTON_GROUP'); --  need new msg
      fnd_msg_pub.ADD;
  END update_mol_carton_group;

END inv_mo_cancel_pvt;

/
