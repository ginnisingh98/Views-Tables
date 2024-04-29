--------------------------------------------------------
--  DDL for Package Body WMS_TASK_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TASK_UTILS_PVT" AS
  /* $Header: WMSTSKUB.pls 120.8.12000000.2 2007/04/17 02:55:38 mchemban ship $ */
  g_pkg_name CONSTANT VARCHAR2(30) := 'WMS_TASK_UTILS_PVT';

  PROCEDURE mydebug(msg IN VARCHAR2) IS
  BEGIN
    inv_trx_util_pub.trace(msg, 'WMS_TASK_UTILS_PVT', 3);
  END mydebug;

  FUNCTION can_drop(p_lpn_id IN NUMBER)
    RETURN VARCHAR2 IS
    txn_temp_id NUMBER      := NULL;
    txn_type_id NUMBER      := NULL;
    mol_id      NUMBER      := NULL;
    ln_status   NUMBER      := NULL;
    l_ret       VARCHAR2(1) := 'Y';

    CURSOR c_tasks IS
      SELECT mmtt.transaction_temp_id
           , mmtt.transaction_type_id
           , mmtt.move_order_line_id
           , mol.line_status
        FROM mtl_material_transactions_temp  mmtt
           , mtl_txn_request_lines           mol
       WHERE mmtt.transfer_lpn_id    = p_lpn_id
         AND mmtt.move_order_line_id = mol.line_id
         AND mol.line_status         = inv_globals.g_to_status_cancel_by_source;

    l_debug     NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('In CAN_DROP for LPN = ' || p_lpn_id);
    END IF;

    OPEN c_tasks;
    FETCH c_tasks INTO txn_temp_id
                     , txn_type_id
                     , mol_id
                     , ln_status;

    IF c_tasks%FOUND
    THEN
      IF (l_debug = 1) THEN
         mydebug(' Found cancelled task ' || txn_temp_id);
      END IF;

      IF txn_type_id IN (35, 51)
      THEN
        l_ret := 'N';
        IF (l_debug = 1) THEN
           mydebug('Cannot Drop a Cancelled WIP Task: ' || txn_temp_id);
        END IF;
      ELSE
        l_ret  := 'W';
      END IF;
    ELSE
      l_ret  := 'Y';
    END IF;

    IF c_tasks%ISOPEN
    THEN
       CLOSE c_tasks;
    END IF;

    IF (l_debug = 1) THEN
       mydebug('Return Status = ' || l_ret);
    END IF;

    RETURN l_ret;

  EXCEPTION
    WHEN OTHERS THEN
       mydebug('Exception occurred: ' || sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;



  PROCEDURE unload_task
  ( x_ret_value  OUT NOCOPY  NUMBER
  , x_message    OUT NOCOPY  VARCHAR2
  , p_temp_id    IN  NUMBER
  ) IS
    msg_cnt                      NUMBER;
    cnt                          NUMBER       := -1;
    l_temp_id                    NUMBER       := NULL;
    l_ser_temp_id                NUMBER       := NULL;
    l_org_id                     NUMBER       := NULL;
    l_item_id                    NUMBER       := NULL;
    l_del_quantity               NUMBER       := 0;
    l_quantity                   NUMBER       := 0;
    mol_id                       NUMBER       := NULL;
    line_status                  NUMBER       := NULL;
    v_lot_control_code           NUMBER       := NULL;
    v_serial_control_code        NUMBER       := NULL;
    v_allocate_serial_flag       VARCHAR2(1)  := NULL;
    l_msg_count                  NUMBER;
    l_return_status              VARCHAR2(1);
    -- bug 2091680
    l_transfer_lpn_id            NUMBER;
    l_wms_task_types             NUMBER;
    l_content_lpn_id             NUMBER;
    l_count                      NUMBER;
    l_fm_serial_number           VARCHAR2(30);
    l_to_serial_number           VARCHAR2(30);
    l_serial_transaction_temp_id NUMBER;
    l_lpn                    WMS_CONTAINER_PUB.LPN;
    l_lpn_context            NUMBER;
    l_msg_data               VARCHAR2(100);

    CURSOR mmtt_to_del(mol_id NUMBER) IS
      SELECT mmtt.transaction_temp_id
           , ABS(mmtt.transaction_quantity) --mmtt.primary_quantity
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.move_order_line_id = mol_id
         AND NOT EXISTS(
              SELECT wdt.transaction_temp_id
                FROM wms_dispatched_tasks wdt
               WHERE wdt.transaction_temp_id = mmtt.transaction_temp_id
                 AND wdt.transaction_temp_id IS NOT NULL
                 AND wdt.transaction_temp_id <> p_temp_id);

    CURSOR msnt_to_del(p_tmp_id NUMBER) IS
      SELECT serial_transaction_temp_id
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_tmp_id;

    CURSOR c_fm_to_serial_number IS
      SELECT fm_serial_number
           , to_serial_number
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = p_temp_id;

    CURSOR c_fm_to_lot_serial_number IS
      SELECT fm_serial_number
           , to_serial_number
        FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id = p_temp_id
         AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;

    CURSOR c_lot_allocations IS
      SELECT serial_transaction_temp_id
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_temp_id;

    l_debug                      NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug(' in unload_task ');
    END IF;

    IF (WMS_CONTROL.GET_CURRENT_RELEASE_LEVEL >=
        INV_RELEASE.GET_J_RELEASE_LEVEL)
    THEN
       WMS_UNLOAD_UTILS_PVT.unload_task
       ( x_ret_value => x_ret_value
       , x_message   => x_message
       , p_temp_id   => p_temp_id
       );

       IF (l_debug = 1) THEN
          mydebug('WMS_UNLOAD_UTILS_PVT.unload task returned value ' || x_ret_value);
          mydebug('Message: ' || x_message);
       END IF;
    ELSE
       x_ret_value  := 0;

       SELECT COUNT(transaction_temp_id)
         INTO cnt
         FROM wms_dispatched_tasks
        WHERE transaction_temp_id = p_temp_id;

       IF (cnt IN(0, -1)) THEN
         x_ret_value  := 0;
         x_message    := ' NO TASK TO UNLOAD ';
         RETURN;
       ELSIF(cnt > 1) THEN
         x_ret_value  := 0;
         x_message    := ' MULTIPLE TASKS IN WDT FOR ' || p_temp_id;
         RETURN;
       END IF;

       IF (l_debug = 1) THEN
         mydebug(' in unload_task past 1 ');
       END IF;

       BEGIN
         SELECT move_order_line_id
              , organization_id
              , inventory_item_id
              , content_lpn_id
              , transfer_lpn_id
              , wms_task_type
           INTO mol_id
              , l_org_id
              , l_item_id
              , l_content_lpn_id
              , l_transfer_lpn_id
              , l_wms_task_types
           FROM mtl_material_transactions_temp
          WHERE transaction_temp_id = p_temp_id;

         IF (l_debug = 1) THEN
           mydebug(' mol_id ' || mol_id);
           mydebug(' org_id ' || l_org_id);
           mydebug(' item_id ' || l_item_id);
         END IF;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           IF (l_debug = 1) THEN
             mydebug(' No data found in mtl_material_transactions_temp ');
           END IF;

           mol_id  := -1;
       END;

       IF (l_debug = 1) THEN
         mydebug(' mol id :' || mol_id);
       END IF;

       IF (mol_id IS NOT NULL) THEN
         BEGIN
           SELECT line_status
             INTO line_status
             FROM mtl_txn_request_lines
            WHERE line_id = mol_id;

           IF (l_debug = 1) THEN
             mydebug(' Status ' || line_status);
           END IF;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             IF (l_debug = 1) THEN
               mydebug('No data found in mtl_txn_request_lines');
             END IF;

             line_status  := -1;
         END;
       END IF;

       IF (l_debug = 1) THEN
         mydebug(' move order line status ' || line_status);
       END IF;

       IF (line_status = inv_globals.g_to_status_cancel_by_source) THEN
         IF (l_debug = 1) THEN
           mydebug(' move order line cancelled ');
         END IF;

         IF (l_debug = 1) THEN
           mydebug('deleting allocations ');
         END IF;

         OPEN mmtt_to_del(mol_id);

         LOOP
           FETCH mmtt_to_del INTO l_temp_id, l_quantity;
           EXIT WHEN mmtt_to_del%NOTFOUND;

           IF (l_debug = 1) THEN
             mydebug('deleting allocations l_temp_id:' || l_temp_id || ' l_quantity:' || l_quantity);
           END IF;

           inv_mo_cancel_pvt.reduce_rsv_allocation(
             x_return_status              => l_return_status
           , x_msg_count                  => l_msg_count
           , x_msg_data                   => x_message
           , p_transaction_temp_id        => l_temp_id
           , p_quantity_to_delete         => l_quantity
           );

           IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
             IF (l_debug = 1) THEN
               mydebug(' error returned from inv_mo_cancel_pvt.reduce_rsv_allocation');
               mydebug(x_message);
             END IF;

             RAISE fnd_api.g_exc_error;
           ELSE
             IF (l_debug = 1) THEN
               mydebug(' Successful from inv_mo_cancel_pvt.reduce_rsv_allocation Call');
             END IF;

             l_del_quantity  := l_del_quantity + l_quantity;
           END IF;
         END LOOP;

         IF (l_debug = 1) THEN
           mydebug(' alloc quantity deleted ' || l_del_quantity);
         END IF;

         UPDATE mtl_txn_request_lines
            SET quantity_detailed =(quantity_detailed - l_del_quantity)
          WHERE line_id = mol_id;

         IF (l_debug = 1) THEN
           mydebug('updated mol:' || mol_id);
         END IF;

         DELETE      wms_dispatched_tasks
               WHERE transaction_temp_id = p_temp_id;

         IF (l_debug = 1) THEN
           mydebug('deleted from wms_dispatched_tasks ');
         END IF;

         SELECT COUNT(transaction_temp_id)
           INTO cnt
           FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.move_order_line_id = mol_id;

         IF (cnt = 0) THEN
           IF (l_debug = 1) THEN
             mydebug('No more allocations in mmtt left for this mo line ' || mol_id);
             mydebug(' so closing the mo line ' || mol_id);
           END IF;

           UPDATE mtl_txn_request_lines
              SET line_status = inv_globals.g_to_status_closed
            WHERE line_id = mol_id;

           IF (l_debug = 1) THEN
             mydebug(' updated the mo line status to ' || inv_globals.g_to_status_closed);
           END IF;
         ELSE
           IF (l_debug = 1) THEN
             mydebug(' allocations in mmtt left for this mo line - count ' || mol_id || ' - ' || cnt);
             mydebug(' so not closing the mo line ' || mol_id);
           END IF;
         END IF;
       ELSE
         IF (l_debug = 1) THEN
           mydebug(' move order line not cancelled ');
         END IF;

         SELECT msi.lot_control_code
              , msi.serial_number_control_code
           INTO v_lot_control_code
              , v_serial_control_code
           FROM mtl_system_items msi, mtl_material_transactions_temp mmtt
          WHERE msi.inventory_item_id = mmtt.inventory_item_id
            AND msi.organization_id = mmtt.organization_id
            AND mmtt.transaction_temp_id = p_temp_id;

         SELECT nvl(mp.allocate_serial_flag,'N')  /*Bug#4003553.Added NVL function*/
           INTO v_allocate_serial_flag
           FROM mtl_parameters mp, mtl_material_transactions_temp mmtt
          WHERE mp.organization_id = mmtt.organization_id
            AND mmtt.transaction_temp_id = p_temp_id;

         IF l_wms_task_types IN(wms_globals.g_wms_task_type_stg_move) THEN
           -- We need to do this for staging move as staging move will
           -- have no MSNT/MTLT lines
           v_lot_control_code     := 0;
           v_serial_control_code  := 0;
         END IF;

         IF (l_debug = 1) THEN
           mydebug(' lot code ' || v_lot_control_code);
           mydebug(' ser_code ' || v_serial_control_code);
           mydebug(' alloc ser flag' || v_allocate_serial_flag);
         END IF;

         IF (v_allocate_serial_flag <> 'Y') THEN
           IF (l_debug = 1) THEN
             mydebug(' alloc serial flag is not y ');
           END IF;

           IF (v_lot_control_code = 1
               AND v_serial_control_code NOT IN(1, 6)) THEN
             IF (l_debug = 1) THEN
               mydebug(' serial controlled only ');
             END IF;

             IF (l_debug = 1) THEN
               mydebug(' deleting msnt with temp id ' || p_temp_id);
             END IF;

             --UPDATE GROUP_MARK_ID for Serial controlled

             OPEN c_fm_to_serial_number;

             LOOP
               FETCH c_fm_to_serial_number INTO l_fm_serial_number, l_to_serial_number;
               EXIT WHEN c_fm_to_serial_number%NOTFOUND;

               UPDATE mtl_serial_numbers
                  SET group_mark_id = NULL
   	      WHERE serial_number BETWEEN l_fm_serial_number AND l_to_serial_number
   	      --Bug 2940878 fix added org and item restriction
   	      AND current_organization_id = l_org_id
   	      AND inventory_item_id = l_item_id;
             END LOOP;

             CLOSE c_fm_to_serial_number;

             /**Serial Controlled only ****/
             DELETE      mtl_serial_numbers_temp
                   WHERE transaction_temp_id = p_temp_id;
           ELSIF(v_lot_control_code = 2
                 AND v_serial_control_code NOT IN(1, 6)) THEN
             /** Both lot and serial controlled **/
             IF (l_debug = 1) THEN
               mydebug(' lot and serial controlled ');
             END IF;

             IF (l_debug = 1) THEN
               mydebug(' deleting msnt ');
             END IF;

             OPEN c_lot_allocations;

             LOOP
               FETCH c_lot_allocations INTO l_serial_transaction_temp_id;
               EXIT WHEN c_lot_allocations%NOTFOUND;
               --UPDATE GROUP_MARK_ID for Lot and serial Controlled
               OPEN c_fm_to_lot_serial_number;

               LOOP
                 FETCH c_fm_to_lot_serial_number INTO l_fm_serial_number, l_to_serial_number;
                 EXIT WHEN c_fm_to_lot_serial_number%NOTFOUND;

                 UPDATE mtl_serial_numbers
                    SET group_mark_id = NULL
   		WHERE serial_number BETWEEN l_fm_serial_number AND l_to_serial_number
   		--Bug 2940878 fix added org and item restriction
   	      AND current_organization_id = l_org_id
   	      AND inventory_item_id = l_item_id;
               END LOOP;

               CLOSE c_fm_to_lot_serial_number;

               DELETE FROM mtl_serial_numbers_temp
                     WHERE transaction_temp_id = l_serial_transaction_temp_id;
             END LOOP;

             CLOSE c_lot_allocations;

             DELETE      mtl_serial_numbers_temp
                   WHERE transaction_temp_id IN(SELECT mtlt.serial_transaction_temp_id
                                                  FROM mtl_transaction_lots_temp mtlt
                                                 WHERE mtlt.transaction_temp_id = p_temp_id);

             IF (l_debug = 1) THEN
               mydebug(' updating  mtlt ');
             END IF;

             UPDATE mtl_transaction_lots_temp
                SET serial_transaction_temp_id = NULL
              WHERE transaction_temp_id = p_temp_id;

             IF (l_debug = 1) THEN
               mydebug(' update done ');
             END IF;
           END IF;
         END IF;

         IF (l_debug = 1) THEN
           mydebug('deleting WDT with temp_id ' || p_temp_id);
         END IF;

         -- added following for bug fix 2769358

         IF l_content_lpn_id IS NOT NULL THEN
           IF (l_debug = 1) THEN
             mydebug('Set lpn context to packing for lpn_ID : ' || l_content_lpn_id);
           END IF;

	   --bug 4411814
	   l_lpn.lpn_id      :=  l_content_lpn_id;
	   l_lpn.organization_id := l_org_id;
	   l_lpn.lpn_context := wms_container_pub.lpn_context_inv;

	   wms_container_pvt.Modify_LPN
	     (
	       p_api_version             => 1.0
	       , p_validation_level      => fnd_api.g_valid_level_none
	       , x_return_status         => l_return_status
	       , x_msg_count             => l_msg_count
	       , x_msg_data              => l_msg_data
	       , p_lpn                   => l_lpn
	       ) ;

	   l_lpn := NULL;


         END IF;

         --The lpn ids must be set to null for this task
         UPDATE mtl_material_transactions_temp
            SET lpn_id = NULL
              , content_lpn_id = NULL
              , transfer_lpn_id = NULL
          WHERE transaction_temp_id = p_temp_id;

         DELETE      wms_dispatched_tasks
               WHERE transaction_temp_id = p_temp_id;

         IF (l_debug = 1) THEN
           mydebug('deleted WDT with temp_id ' || p_temp_id);
         END IF;

         IF l_wms_task_types IN(wms_globals.g_wms_task_type_stg_move) THEN
           DELETE FROM mtl_material_transactions_temp
                 WHERE transaction_temp_id = p_temp_id;
         END IF;
       END IF;

       -- Bug 2091680 . Update the LPN context to defined but not used if the
       -- lpn is unloaded with a context of packaging and update the context to
       -- inventory if the entire lpn is picked
       -- this happens only if there are no more allocations for that lpn and
       -- the last line IS being unloaded
       IF l_wms_task_types IN ( wms_globals.g_wms_task_type_pick
                              , wms_globals.g_wms_task_type_replenish
                              , wms_globals.g_wms_task_type_moxfer
                              )
       THEN
         SELECT COUNT(1)
           INTO l_count
           FROM mtl_material_transactions_temp
          WHERE transfer_lpn_id = l_transfer_lpn_id;

         IF l_count = 0 THEN                        -- no more rows and the current row is the
                             --last allocation
            BEGIN
	       SELECT lpn_context INTO l_lpn_context
		 FROM wms_license_plate_numbers
		 WHERE lpn_id = l_transfer_lpn_id;
	    EXCEPTION
	       WHEN no_data_found THEN
		  l_lpn_context := NULL;
	    END;

	    IF l_content_lpn_id IS NOT NULL
	      AND l_content_lpn_id = l_transfer_lpn_id THEN


	       IF l_lpn_context <> 1 AND l_lpn_context IS NOT NULL THEN

		  --bug 4411814
		  l_lpn.lpn_id      := l_transfer_lpn_id;
		  l_lpn.organization_id := l_org_id;
		  l_lpn.lpn_context := 1;

		  wms_container_pvt.Modify_LPN
		    (
		      p_api_version             => 1.0
		      , p_validation_level      => fnd_api.g_valid_level_none
		      , x_return_status         => l_return_status
		      , x_msg_count             => l_msg_count
		      , x_msg_data              => l_msg_data
		      , p_lpn                   => l_lpn
		      ) ;

		  l_lpn := NULL;
	       END IF;

	     ELSE

	       IF l_lpn_context = 8  THEN

		  --bug 4411814
		  l_lpn.lpn_id      :=  l_transfer_lpn_id;
		  l_lpn.organization_id := l_org_id;
		  l_lpn.lpn_context := 5;

		  wms_container_pvt.Modify_LPN
		    (
		      p_api_version             => 1.0
		      , p_validation_level      => fnd_api.g_valid_level_none
		      , x_return_status         => l_return_status
		      , x_msg_count             => l_msg_count
		      , x_msg_data              => l_msg_data
		      , p_lpn                   => l_lpn
		      ) ;

		  l_lpn := NULL;

	       END IF;

	    END IF;

         END IF;

	ELSIF l_wms_task_types = wms_globals.g_wms_task_type_stg_move THEN

	  IF (l_debug = 1) THEN
	     mydebug('Calling wms_container_pvt.Modify_LPN_Wrapper for staging move. p_lpn_id = '||l_content_lpn_id);
	     mydebug('p_lpn_context = '|| wms_container_pub.LPN_CONTEXT_PICKED );
	  END IF;

	  wms_container_pub.Modify_LPN_Wrapper
	    ( p_api_version    =>  1.0
	      ,x_return_status =>  l_return_status
	      ,x_msg_count     =>  l_msg_count
	      ,x_msg_data      =>  x_message
	      ,p_lpn_id        =>  l_content_lpn_id
	      ,p_lpn_context   =>  wms_container_pub.lpn_context_picked
	      );

	  IF (l_debug = 1) THEN
	     mydebug('wms_container_pvt.Modify_LPN_Wrapper x_return_status = '||l_return_status);
	  END IF;

       END IF;

       x_ret_value  := 1;

       IF (l_debug = 1) THEN
         mydebug('done unload_task x_ret ' || x_ret_value);
       END IF;

       -- Doing an explicit commit
       -- HERE

       COMMIT;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_ret_value  := 0;

      IF (l_debug = 1) THEN
        mydebug(' In exception unload_task x_ret' || x_ret_value);
      END IF;

      fnd_msg_pub.count_and_get(p_count => msg_cnt, p_data => x_message);
  END unload_task;

  PROCEDURE is_task_processed(x_processed OUT NOCOPY VARCHAR2, p_header_id IN NUMBER) IS
    l_processed    VARCHAR2(1) := 'Y';
    l_err_status   NUMBER      := NULL;
    l_process_flag VARCHAR2(1) := NULL;
    l_debug        NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- If there are more than one row for this putaway tasks' transaction
    -- header id , returning an error status of M to discontinue work
    -- flow processing

    IF (l_debug = 1) THEN
      mydebug('in Is_task_processed with header is :' || p_header_id);
    END IF;

    l_processed  := NULL;

    BEGIN
      SELECT 'E'
        INTO l_processed
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM mtl_material_transactions_temp
                     WHERE transaction_header_id = p_header_id
                       AND process_flag = 'E');

      IF (l_debug = 1) THEN
        mydebug('transaction status ' || l_err_status);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    IF l_processed = 'E' THEN
      IF (l_debug = 1) THEN
        mydebug('transaction has errored out so ret E');
      END IF;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('Before the select:');
      END IF;

      SELECT 'Y'
        INTO l_processed
        FROM DUAL
       WHERE EXISTS(SELECT transaction_set_id
                      FROM mtl_material_transactions
                     WHERE transaction_set_id = p_header_id);

      IF (l_debug = 1) THEN
        mydebug('After the select: l_processed ' || l_processed);
      END IF;
    END IF;

    x_processed  := l_processed;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (l_debug = 1) THEN
        mydebug('in no data found');
      END IF;

      x_processed  := 'N';
    WHEN TOO_MANY_ROWS THEN
      IF (l_debug = 1) THEN
        mydebug('in too many rows');
      END IF;

      x_processed  := 'M';
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('IN OTHERS');
      END IF;

      x_processed  := 'O';
  END is_task_processed;


  FUNCTION check_qty_avail(
    mmtt_row               IN mmtt_type
  , lot_row                IN mtlt_type
  , ser_row                IN msnt_type
  , p_is_revision_control  IN VARCHAR2
  , p_is_lot_control       IN VARCHAR2
  , p_is_serial_control    IN VARCHAR2
  , p_allocate_serial_flag IN VARCHAR2
)
    RETURN BOOLEAN IS
    l_ret                         BOOLEAN        := TRUE;
    l_msg_count                   VARCHAR2(100);
    l_msg_data                    VARCHAR2(1000);
    l_is_revision_control         BOOLEAN        := FALSE;
    l_is_lot_control              BOOLEAN        := FALSE;
    l_is_serial_control           BOOLEAN        := FALSE;
    l_tree_mode                   NUMBER;
    l_api_version_number CONSTANT NUMBER         := 1.0;
    l_api_name           CONSTANT VARCHAR2(30)   := 'check_qty_avail';
    l_return_status               VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_tree_id                     INTEGER;
    l_rqoh                        NUMBER;
    l_qr                          NUMBER;
    l_qs                          NUMBER;
    l_atr                         NUMBER;
    l_qoh                         NUMBER;
    l_att                         NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number                  VARCHAR2(80);
    l_qty                         NUMBER         := NULL;
    l_already_used                VARCHAR2(1)    := 'N';
    l_debug                       NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('Enter check_qty_avail');
    END IF;

    inv_quantity_tree_pub.clear_quantity_cache;

    IF (l_debug = 1) THEN
      mydebug('rev control' || p_is_revision_control);
    END IF;

    IF p_is_revision_control = 'Y' THEN
      l_is_revision_control  := TRUE;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('lot control' || p_is_lot_control);
    END IF;

    IF p_is_lot_control = 'Y' THEN
      l_is_lot_control  := TRUE;
      l_lot_number      := lot_row.lot_number;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('ser control' || p_is_serial_control);
    END IF;

    IF p_is_serial_control = 'Y' THEN
      l_is_serial_control  := TRUE;
    END IF;

    l_tree_mode  := inv_quantity_tree_pub.g_transaction_mode;

    IF (l_debug = 1) THEN
      mydebug('querying quantity tree');
    END IF;

    inv_quantity_tree_pub.query_quantities(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_false
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_organization_id            => mmtt_row.organization_id
    , p_inventory_item_id          => mmtt_row.inventory_item_id
    , p_tree_mode                  => l_tree_mode
    , p_is_revision_control        => l_is_revision_control
    , p_is_lot_control             => l_is_lot_control
    , p_is_serial_control          => l_is_serial_control
    , p_revision                   => mmtt_row.revision
    , p_lot_number                 => l_lot_number
    , p_lot_expiration_date        => NULL --for bug# 2219136
    , p_subinventory_code          => mmtt_row.subinventory_code
    , p_locator_id                 => mmtt_row.locator_id
    , p_cost_group_id              => mmtt_row.cost_group_id
    , p_lpn_id                     => mmtt_row.allocated_lpn_id -- bug 4230494
    , x_qoh                        => l_qoh
    , x_rqoh                       => l_rqoh
    , x_qr                         => l_qr
    , x_qs                         => l_qs
    , x_att                        => l_att
    , x_atr                        => l_atr
    );

    ---WHY DOESNT THE QTY TREE API HAVE A PARAM FOR SERIAL
    IF (l_debug = 1) THEN
      mydebug('qty tree ret status' || l_return_status);
      mydebug('qty tree ret msg' || l_msg_data);
    END IF;

    IF (l_debug = 1) THEN
      mydebug('qty tree ret x_qoh' || l_qoh);
      mydebug('qty tree ret x_rqoh' || l_rqoh);
      mydebug('qty tree ret x_qr' || l_qr);
      mydebug('qty tree ret x_qs' || l_qs);
      mydebug('qty tree ret x_att' || l_att);
      mydebug('qty tree ret x_atr' || l_atr);
    END IF;

    IF (p_is_lot_control = 'Y') THEN
      l_qty  := lot_row.primary_quantity;
    ELSE
      l_qty  := mmtt_row.primary_quantity;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('qty we are checking for' || l_qty);
    END IF;

    IF (l_att < l_qty) THEN
      IF (l_debug = 1) THEN
        mydebug('check_qty_avail ret FALSE');
      END IF;

      l_ret  := FALSE;
     ELSE
       /** 2706001 fix removed group mark check from here **/
       IF (l_debug = 1) THEN
	  mydebug('quantities match');
       END IF;
       l_ret  := TRUE;
    END IF;

    RETURN l_ret;
  EXCEPTION
     WHEN fnd_api.g_exc_unexpected_error THEN
      IF (l_debug = 1) THEN
        mydebug('unexpected error in check_qty_avail');
      END IF;

      l_ret  := FALSE;
      RAISE fnd_api.g_exc_unexpected_error;
      RETURN l_ret;
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('Exception in check_qty_avail');
      END IF;

      l_ret  := FALSE;
      RETURN l_ret;
  END check_qty_avail;

  PROCEDURE get_temp_tables(p_set_id IN NUMBER, x_mmtt OUT NOCOPY mmtt_tb, x_mtlt OUT NOCOPY mtlt_tb, x_msnt OUT NOCOPY msnt_tb) IS
    v_lot_control_code     NUMBER      := -1;
    v_serial_control_code  NUMBER      := -1;
    cnt                    NUMBER      := 1;
    v_allocate_serial_flag VARCHAR2(1) := 'X';

    CURSOR mmt(p_set_id NUMBER) IS
      SELECT *
        FROM mtl_material_transactions
       WHERE transaction_set_id = p_set_id;

    CURSOR mtln(p_set_id NUMBER) IS
      SELECT *
        FROM mtl_transaction_lot_numbers
       WHERE transaction_id IN(SELECT transaction_id
                                 FROM mtl_material_transactions
                                WHERE transaction_set_id = p_set_id);

    CURSOR mut1(p_set_id NUMBER) IS
      SELECT *
        FROM mtl_unit_transactions
       WHERE transaction_id IN(SELECT transaction_id
                                 FROM mtl_material_transactions
                                WHERE transaction_set_id = p_set_id);

    CURSOR mut2(p_set_id NUMBER) IS
      SELECT *
        FROM mtl_unit_transactions
       WHERE transaction_id IN(SELECT serial_transaction_id
                                 FROM mtl_transaction_lot_numbers
                                WHERE transaction_id IN(SELECT transaction_id
                                                          FROM mtl_material_transactions
                                                         WHERE transaction_set_id = p_set_id));

    mmtt_table             mmtt_tb;
    mmtt_row               mmtt_type;
    mtlt_row               mtlt_type;
    mtlt_table             mtlt_tb;
    msnt_row               msnt_type;
    msnt_table             msnt_tb;
    mmt_row                mmt_type;
    mtln_row               mtln_type;
    mut_row                mut_type;
    l_item_id              NUMBER;
    l_org_id               NUMBER;
    l_debug                NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    l_lpn_control_flag     NUMBER; -- bug 4230494
    l_item_uom_code        VARCHAR2(3); --Bug#5010991
    l_lpn_ctx              NUMBER ; --Bug#5984021
  BEGIN
    IF (l_debug = 1) THEN
      mydebug(' entering get_temp_tables');
    END IF;

    cnt     := 1;
    OPEN mmt(p_set_id);

    LOOP
      IF (l_debug = 1) THEN
        mydebug(' inside mmt loop ');
      END IF;

      FETCH mmt INTO mmt_row;
      EXIT WHEN mmt%NOTFOUND;

      IF (l_debug = 1) THEN
        mydebug(' transaction id ' || mmt_row.transaction_id);
      END IF;

      l_item_id                                := mmt_row.inventory_item_id;
      l_org_id                                 := mmt_row.organization_id;

      --Bug#5010991. Get the PRIMARY_UOM_CODE for the item.
      SELECT msi.primary_uom_code INTO l_item_uom_code
      FROM mtl_system_items msi
      WHERE msi.inventory_item_id=l_item_id
      AND msi.organization_id=l_org_id;


      IF (l_debug = 1) THEN
	mydebug(' item id ' || l_item_id ||' , primary uom:'||l_item_uom_code);
      END IF;

      mmtt_row.transaction_temp_id             := mmt_row.transaction_id;
      mmtt_row.last_update_date                := mmt_row.last_update_date;
      mmtt_row.last_updated_by                 := mmt_row.last_updated_by;
      mmtt_row.creation_date                   := mmt_row.creation_date;
      mmtt_row.created_by                      := mmt_row.created_by;
      mmtt_row.last_update_login               := mmt_row.last_update_login;
      mmtt_row.request_id                      := mmt_row.request_id;
      mmtt_row.program_application_id          := mmt_row.program_application_id;
      mmtt_row.program_id                      := mmt_row.program_id;
      mmtt_row.program_update_date             := mmt_row.program_update_date;
      mmtt_row.inventory_item_id               := mmt_row.inventory_item_id;

      mmtt_row.item_primary_uom_code           := l_item_uom_code;      --Bug#5010991.Add PRIMARY_UOM_CODE to MMTT.
      mmtt_row.revision                        := mmt_row.revision;
      mmtt_row.organization_id                 := mmt_row.organization_id;
      mmtt_row.subinventory_code               := mmt_row.subinventory_code;
      mmtt_row.locator_id                      := mmt_row.locator_id;
      mmtt_row.transaction_type_id             := mmt_row.transaction_type_id;
      mmtt_row.transaction_action_id           := mmt_row.transaction_action_id;
      mmtt_row.transaction_source_type_id      := mmt_row.transaction_source_type_id;
      mmtt_row.transaction_source_id           := mmt_row.transaction_source_id;
      mmtt_row.transaction_source_name         := mmt_row.transaction_source_name;
      mmtt_row.transaction_quantity            := mmt_row.transaction_quantity;
      mmtt_row.transaction_uom                 := mmt_row.transaction_uom;
      mmtt_row.primary_quantity                := mmt_row.primary_quantity;
      mmtt_row.transaction_date                := mmt_row.transaction_date;
      --VARIANCE_AMOUNT               ,      ;
      mmtt_row.acct_period_id                  := mmt_row.acct_period_id;
      mmtt_row.transaction_reference           := mmt_row.transaction_reference;
      mmtt_row.reason_id                       := mmt_row.reason_id;
      mmtt_row.distribution_account_id         := mmt_row.distribution_account_id;
      mmtt_row.encumbrance_account             := mmt_row.encumbrance_account;
      mmtt_row.encumbrance_amount              := mmt_row.encumbrance_amount;
      --COST_UPDATE_ID                   ;
      --COSTED_FLAG                      ;
      --INVOICED_FLAG                    ;
      --ACTUAL_COST                      ;
--      mmtt_row.transaction_cost                := mmt_row.transaction_cost;bug#4011886 transaction cost copying
									   --would resultin orphan reocrds in MTL_CST_TXN_COST_DETAILS
      --PRIOR_COST                       ;
      --NEW_COST                         ;
      mmtt_row.currency_code                   := mmt_row.currency_code;
      mmtt_row.currency_conversion_rate        := mmt_row.currency_conversion_rate;
      mmtt_row.currency_conversion_type        := mmt_row.currency_conversion_type;
      mmtt_row.currency_conversion_date        := mmt_row.currency_conversion_date;
      mmtt_row.ussgl_transaction_code          := mmt_row.ussgl_transaction_code;
      --QUANTITY_ADJUSTED                ;
      mmtt_row.employee_code                   := mmt_row.employee_code;
      mmtt_row.department_id                   := mmt_row.department_id;
      mmtt_row.operation_seq_num               := mmt_row.operation_seq_num;
      --MASTER_SCHEDULE_UPDATE_CODE      ;
      mmtt_row.receiving_document              := mmt_row.receiving_document;
      mmtt_row.picking_line_id                 := mmt_row.picking_line_id;
      mmtt_row.trx_source_line_id              := mmt_row.trx_source_line_id;
      mmtt_row.trx_source_delivery_id          := mmt_row.trx_source_delivery_id;
      mmtt_row.repetitive_line_id              := mmt_row.repetitive_line_id;
      mmtt_row.physical_adjustment_id          := mmt_row.physical_adjustment_id;
      mmtt_row.cycle_count_id                  := mmt_row.cycle_count_id;
      mmtt_row.rma_line_id                     := mmt_row.rma_line_id;
      --TRANSFER_TRANSACTION_ID          ;
      --TRANSACTION_SET_ID               ;
      mmtt_row.rcv_transaction_id              := mmt_row.rcv_transaction_id;
      mmtt_row.move_transaction_id             := mmt_row.move_transaction_id;
      mmtt_row.completion_transaction_id       := mmt_row.completion_transaction_id;
      mmtt_row.source_code                     := mmt_row.source_code;
      mmtt_row.source_line_id                  := mmt_row.source_line_id;
      mmtt_row.vendor_lot_number               := mmt_row.vendor_lot_number;
      --Bug 5218617
      --mmtt_row.transfer_organization           := mmt_row.transfer_organization_id;
      mmtt_row.transfer_subinventory           := mmt_row.transfer_subinventory;
      mmtt_row.transfer_to_location            := mmt_row.transfer_locator_id;
      mmtt_row.shipment_number                 := mmt_row.shipment_number;
      mmtt_row.transfer_cost                   := mmt_row.transfer_cost;
      --TRANSPORTATION_DIST_ACCOUNT      ;
      mmtt_row.transportation_cost             := mmt_row.transportation_cost;
      --TRANSFER_COST_DIST_ACCOUNT       ;
      mmtt_row.waybill_airbill                 := mmt_row.waybill_airbill;
      mmtt_row.freight_code                    := mmt_row.freight_code;
      --NUMBER_OF_CONTAINERS             ;
      mmtt_row.value_change                    := mmt_row.value_change;
      mmtt_row.percentage_change               := mmt_row.percentage_change;
      mmtt_row.attribute_category              := mmt_row.attribute_category;
      mmtt_row.attribute1                      := mmt_row.attribute1;
      mmtt_row.attribute2                      := mmt_row.attribute2;
      mmtt_row.attribute3                      := mmt_row.attribute3;
      mmtt_row.attribute4                      := mmt_row.attribute4;
      mmtt_row.attribute5                      := mmt_row.attribute5;
      mmtt_row.attribute6                      := mmt_row.attribute6;
      mmtt_row.attribute7                      := mmt_row.attribute7;
      mmtt_row.attribute8                      := mmt_row.attribute8;
      mmtt_row.attribute9                      := mmt_row.attribute9;
      mmtt_row.attribute10                     := mmt_row.attribute10;
      mmtt_row.attribute11                     := mmt_row.attribute11;
      mmtt_row.attribute12                     := mmt_row.attribute12;
      mmtt_row.attribute13                     := mmt_row.attribute13;
      mmtt_row.attribute14                     := mmt_row.attribute14;
      mmtt_row.attribute15                     := mmt_row.attribute15;
      mmtt_row.movement_id                     := mmt_row.movement_id;
      --TRANSACTION_GROUP_ID             ;
      mmtt_row.task_id                         := mmt_row.task_id;
      mmtt_row.to_task_id                      := mmt_row.to_task_id;
      mmtt_row.project_id                      := mmt_row.project_id;
      mmtt_row.to_project_id                   := mmt_row.to_project_id;
      mmtt_row.source_project_id               := mmt_row.source_project_id;
      mmtt_row.pa_expenditure_org_id           := mmt_row.pa_expenditure_org_id;
      mmtt_row.source_task_id                  := mmt_row.source_task_id;
      mmtt_row.expenditure_type                := mmt_row.expenditure_type;
      mmtt_row.ERROR_CODE                      := mmt_row.ERROR_CODE;
      mmtt_row.error_explanation               := mmt_row.error_explanation;
      --PRIOR_COSTED_QUANTITY            ;
      mmtt_row.final_completion_flag           := mmt_row.final_completion_flag;
      --PM_COST_COLLECTED                ;
      --PM_COST_COLLECTOR_GROUP_ID       ;
      --SHIPMENT_COSTED                  ;
      mmtt_row.transfer_percentage             := mmt_row.transfer_percentage;
      mmtt_row.material_account                := mmt_row.material_account;
      mmtt_row.material_overhead_account       := mmt_row.material_overhead_account;
      mmtt_row.resource_account                := mmt_row.resource_account;
      mmtt_row.outside_processing_account      := mmt_row.outside_processing_account;
      mmtt_row.overhead_account                := mmt_row.overhead_account;
      --BUG 2698630 fix no need to put cost groups on the new task
      --They will be determined by the cost  group api while processing the
      --transaction
      mmtt_row.cost_group_id                   := NULL;--mmt_row.cost_group_id;
      mmtt_row.transfer_cost_group_id          := NULL;--mmt_row.transfer_cost_group_id;
      mmtt_row.flow_schedule                   := mmt_row.flow_schedule;
      --TRANSFER_PRIOR_COSTED_QUANTITY   ;
      --SHORTAGE_PROCESS_CODE            ;
      mmtt_row.qa_collection_id                := mmt_row.qa_collection_id;
      mmtt_row.overcompletion_transaction_qty  := mmt_row.overcompletion_transaction_qty;
      mmtt_row.overcompletion_primary_qty      := mmt_row.overcompletion_primary_qty;
      mmtt_row.overcompletion_transaction_id   := mmt_row.overcompletion_transaction_id;
      --MVT_STAT_STATUS                         ;
      mmtt_row.common_bom_seq_id               := mmt_row.common_bom_seq_id;
      mmtt_row.common_routing_seq_id           := mmt_row.common_routing_seq_id;
      mmtt_row.org_cost_group_id               := mmt_row.org_cost_group_id;
      mmtt_row.cost_type_id                    := mmt_row.cost_type_id;
      --PERIODIC_PRIMARY_QUANTITY               ;
      mmtt_row.move_order_line_id              := mmt_row.move_order_line_id;
      mmtt_row.task_group_id                   := mmt_row.task_group_id;
      mmtt_row.pick_slip_number                := mmt_row.pick_slip_number;
      --mmtt_row.LPN_ID                    := mmt_row.LPN_ID        ;
      --mmtt_row.TRANSFER_LPN_ID           := mmt_row.TRANSFER_LPN_ID         ;

      mmtt_row.lpn_id                          := NULL;
      mmtt_row.transfer_lpn_id                 := NULL;
      mmtt_row.pick_strategy_id                := mmt_row.pick_strategy_id;
      mmtt_row.pick_rule_id                    := mmt_row.pick_rule_id;
      mmtt_row.put_away_strategy_id            := mmt_row.put_away_strategy_id;
      mmtt_row.put_away_rule_id                := mmt_row.put_away_rule_id;
      --mmtt_row.CONTENT_LPN_ID              := mmt_row.CONTENT_LPN_ID;
      mmtt_row.content_lpn_id                  := NULL;
      mmtt_row.pick_slip_date                  := mmt_row.pick_slip_date;
      --COST_CATEGORY_ID                    ;

      --For the BUG No. 2172959, Since reservation_id is of no use in mmt
      --mmtt_row.RESERVATION_ID                := mmt_row.RESERVATION_ID;
      mmtt_row.reservation_id                  := NULL;
      mmtt_row.organization_type               := mmt_row.organization_type;
      mmtt_row.transfer_organization_type      := mmt_row.transfer_organization_type;
      mmtt_row.owning_organization_id          := mmt_row.owning_organization_id;
      mmtt_row.owning_tp_type                  := mmt_row.owning_tp_type;
      mmtt_row.xfr_owning_organization_id      := mmt_row.xfr_owning_organization_id;
      mmtt_row.transfer_owning_tp_type         := mmt_row.transfer_owning_tp_type;
      mmtt_row.planning_organization_id        := mmt_row.planning_organization_id;
      mmtt_row.planning_tp_type                := mmt_row.planning_tp_type;
      mmtt_row.xfr_planning_organization_id    := mmt_row.xfr_planning_organization_id;
      mmtt_row.transfer_planning_tp_type       := mmt_row.transfer_planning_tp_type;
      mmtt_row.secondary_uom_code              := mmt_row.secondary_uom_code;
      mmtt_row.secondary_transaction_quantity  := mmt_row.secondary_transaction_quantity;

     IF ( mmtt_row.primary_quantity < 0 ) THEN  --Bug#5984021
      -- bug 4230494
      SELECT lpn_controlled_flag
	INTO l_lpn_control_flag
	FROM mtl_secondary_inventories
	WHERE organization_id = mmt_row.organization_id
	AND secondary_inventory_name = Nvl(mmt_row.transfer_subinventory, mmt_row.subinventory_code);
     ELSE
        SELECT lpn_controlled_flag
	INTO l_lpn_control_flag
	FROM mtl_secondary_inventories
	WHERE organization_id = mmt_row.organization_id
	AND secondary_inventory_name = Nvl(mmt_row.subinventory_code, mmt_row.transfer_subinventory);
    END IF;


    IF(l_lpn_control_flag = 1)THEN
	 IF (l_debug = 1) THEN
	    mydebug('Populate LPN ID '|| Nvl(Nvl(mmt_row.content_lpn_id, mmt_row.transfer_lpn_id), mmt_row.lpn_id)||' into mmtt.allocated_lpn_id. ');
	 END IF;

	 mmtt_row.allocated_lpn_id                := Nvl(mmt_row.content_lpn_id, mmt_row.transfer_lpn_id);

	 --Bug#5984021.If LPN is empty, no need of stamping it on MMTT.
         IF ( NVL(mmtt_row.allocated_lpn_id , 0 )  > 0  ) THEN
              SELECT wlpn.lpn_context INTO l_lpn_ctx
              FROM WMS_LICENSE_PLATE_NUMBERS wlpn
	      WHERE wlpn.lpn_id =  mmtt_row.allocated_lpn_id ;

             IF (l_debug = 1) THEN
                   mydebug('LPN id : '||mmtt_row.allocated_lpn_id ||', context:' ||  l_lpn_ctx );
	     END IF;

	     IF ( l_lpn_ctx = WMS_Container_PUB.LPN_CONTEXT_PREGENERATED ) THEN
	          mmtt_row.allocated_lpn_id := NULL ;
		  IF (l_debug = 1) THEN
                      mydebug('LPN has context 5, so null it out in MMTTT' );
                  END IF;
	     END IF;
         END IF;
	--Bug#5984021.End of fix.
    END IF;
      -- bug 4230494

      mmtt_table(cnt)                          := mmtt_row;
      cnt                                      := cnt + 1;
      mmtt_row                                 := NULL;
    END LOOP;

    IF (l_debug = 1) THEN
      mydebug('after creating mmtt_table');
      mydebug(' Item id ' || l_item_id);
      mydebug(' org id ' || l_org_id);
    END IF;

    SELECT lot_control_code
         , serial_number_control_code
      INTO v_lot_control_code
         , v_serial_control_code
      FROM mtl_system_items
     WHERE inventory_item_id = l_item_id
       AND organization_id = l_org_id;

    IF (l_debug = 1) THEN
      mydebug(' lot code ' || v_lot_control_code);
      mydebug(' ser code ' || v_serial_control_code);
    END IF;

    SELECT allocate_serial_flag
      INTO v_allocate_serial_flag
      FROM mtl_parameters
     WHERE organization_id = l_org_id;

    /*****LOT controlled only **********/
    cnt     := 1;

    IF (v_lot_control_code = 2) THEN
      OPEN mtln(p_set_id);

      LOOP
        FETCH mtln INTO mtln_row;
        EXIT WHEN mtln%NOTFOUND;
        mtlt_row.transaction_temp_id         := mtln_row.transaction_id;
        mtlt_row.last_update_date            := mtln_row.last_update_date;
        mtlt_row.last_updated_by             := mtln_row.last_updated_by;
        mtlt_row.creation_date               := mtln_row.creation_date;
        mtlt_row.created_by                  := mtln_row.created_by;
        mtlt_row.last_update_login           := mtln_row.last_update_login;
        --mtlt_row.INVENTORY_ITEM_ID  := l_item_id;
        --mtlt_row.ORGANIZATION_ID    := l_org_id;
        --mtlt_row.TRANSACTION_DATE   := l_txn_date;
        --mtlt_row.transaction_source_id := l_txn_source_id;
        --mtlt_row.transaction_source_type_id := l_txn_source_type_id;
        --mtlt_row.TRANSACTION_SOURCE_NAME  := l_txn_source_name;

        mtlt_row.transaction_quantity        := mtln_row.transaction_quantity;
        mtlt_row.primary_quantity            := mtln_row.primary_quantity;
        mtlt_row.lot_number                  := mtln_row.lot_number;
        mtlt_row.serial_transaction_temp_id  := mtln_row.serial_transaction_id;
        mtlt_row.description                 := mtln_row.description;
        mtlt_row.vendor_name                 := mtln_row.vendor_name;
        mtlt_row.supplier_lot_number         := mtln_row.supplier_lot_number;
        mtlt_row.origination_date            := mtln_row.origination_date;
        mtlt_row.date_code                   := mtln_row.date_code;
        mtlt_row.grade_code                  := mtln_row.grade_code;
        mtlt_row.change_date                 := mtln_row.change_date;
        mtlt_row.maturity_date               := mtln_row.maturity_date;
        mtlt_row.status_id                   := mtln_row.status_id;
        mtlt_row.retest_date                 := mtln_row.retest_date;
        mtlt_row.age                         := mtln_row.age;
        mtlt_row.item_size                   := mtln_row.item_size;
        mtlt_row.color                       := mtln_row.color;
        mtlt_row.volume                      := mtln_row.volume;
        mtlt_row.volume_uom                  := mtln_row.volume_uom;
        mtlt_row.place_of_origin             := mtln_row.place_of_origin;
        mtlt_row.best_by_date                := mtln_row.best_by_date;
        mtlt_row.LENGTH                      := mtln_row.LENGTH;
        mtlt_row.length_uom                  := mtln_row.length_uom;
        mtlt_row.width                       := mtln_row.width;
        mtlt_row.width_uom                   := mtln_row.width_uom;
        mtlt_row.recycled_content            := mtln_row.recycled_content;
        mtlt_row.thickness                   := mtln_row.thickness;
        mtlt_row.thickness_uom               := mtln_row.thickness_uom;
        mtlt_row.curl_wrinkle_fold           := mtln_row.curl_wrinkle_fold;
        mtlt_row.lot_attribute_category      := mtln_row.lot_attribute_category;
        mtlt_row.c_attribute1                := mtln_row.c_attribute1;
        mtlt_row.c_attribute2                := mtln_row.c_attribute2;
        mtlt_row.c_attribute3                := mtln_row.c_attribute3;
        mtlt_row.c_attribute4                := mtln_row.c_attribute4;
        mtlt_row.c_attribute5                := mtln_row.c_attribute5;
        mtlt_row.c_attribute6                := mtln_row.c_attribute6;
        mtlt_row.c_attribute7                := mtln_row.c_attribute7;
        mtlt_row.c_attribute8                := mtln_row.c_attribute8;
        mtlt_row.c_attribute9                := mtln_row.c_attribute9;
        mtlt_row.c_attribute10               := mtln_row.c_attribute10;
        mtlt_row.c_attribute11               := mtln_row.c_attribute11;
        mtlt_row.c_attribute12               := mtln_row.c_attribute12;
        mtlt_row.c_attribute13               := mtln_row.c_attribute13;
        mtlt_row.c_attribute14               := mtln_row.c_attribute14;
        mtlt_row.c_attribute15               := mtln_row.c_attribute15;
        mtlt_row.c_attribute16               := mtln_row.c_attribute16;
        mtlt_row.c_attribute17               := mtln_row.c_attribute17;
        mtlt_row.c_attribute18               := mtln_row.c_attribute18;
        mtlt_row.c_attribute19               := mtln_row.c_attribute19;
        mtlt_row.c_attribute20               := mtln_row.c_attribute20;
        mtlt_row.d_attribute1                := mtln_row.d_attribute1;
        mtlt_row.d_attribute2                := mtln_row.d_attribute2;
        mtlt_row.d_attribute3                := mtln_row.d_attribute3;
        mtlt_row.d_attribute4                := mtln_row.d_attribute4;
        mtlt_row.d_attribute5                := mtln_row.d_attribute5;
        mtlt_row.d_attribute6                := mtln_row.d_attribute6;
        mtlt_row.d_attribute7                := mtln_row.d_attribute7;
        mtlt_row.d_attribute8                := mtln_row.d_attribute8;
        mtlt_row.d_attribute9                := mtln_row.d_attribute9;
        mtlt_row.d_attribute10               := mtln_row.d_attribute10;
        mtlt_row.n_attribute1                := mtln_row.n_attribute1;
        mtlt_row.n_attribute2                := mtln_row.n_attribute2;
        mtlt_row.n_attribute3                := mtln_row.n_attribute3;
        mtlt_row.n_attribute4                := mtln_row.n_attribute4;
        mtlt_row.n_attribute5                := mtln_row.n_attribute5;
        mtlt_row.n_attribute6                := mtln_row.n_attribute6;
        mtlt_row.n_attribute7                := mtln_row.n_attribute7;
        mtlt_row.n_attribute8                := mtln_row.n_attribute8;
        mtlt_row.n_attribute9                := mtln_row.n_attribute9;
        mtlt_row.n_attribute10               := mtln_row.n_attribute10;
        mtlt_row.vendor_id                   := mtln_row.vendor_id;
        mtlt_row.territory_code              := mtln_row.territory_code;
        mtlt_table(cnt)                      := mtlt_row;
        cnt                                  := cnt + 1;
        mtlt_row                             := NULL;
      END LOOP;

      IF (l_debug = 1) THEN
        mydebug('after creating mtlt_table');
      END IF;
    END IF;
    /********* serial Controlled  **************/
    IF((v_serial_control_code NOT IN(1, 6))
          AND(v_lot_control_code IN(1, 2))) THEN

       cnt  := 1;

       /**2706001 conditionally opening cursors **/
       IF(v_lot_control_code = 1 AND v_serial_control_code NOT IN
	  (1,6) ) THEN
	  OPEN mut1(p_set_id);
	ELSIF(v_lot_control_code = 2 AND v_serial_control_code NOT IN
	      (1,6)) THEN
	  OPEN mut2(p_set_id);
       END IF;


      LOOP
        IF (v_lot_control_code = 1
            AND v_serial_control_code NOT IN(1, 6)) THEN
          FETCH mut1 INTO mut_row;
          EXIT WHEN mut1%NOTFOUND;
        ELSIF(v_lot_control_code = 2
              AND v_serial_control_code NOT IN(1, 6)) THEN
	     FETCH mut2 INTO mut_row;
	     /**2706001 earlier mut1%notfound **/
	     EXIT WHEN mut2%NOTFOUND;
        ELSE
          EXIT;
        END IF;

        msnt_row.transaction_temp_id        := mut_row.transaction_id;
        msnt_row.last_update_date           := mut_row.last_update_date;
        msnt_row.last_updated_by            := mut_row.last_updated_by;
        msnt_row.creation_date              := mut_row.creation_date;
        msnt_row.created_by                 := mut_row.created_by;
        msnt_row.last_update_login          := mut_row.last_update_login;
        msnt_row.fm_serial_number           := mut_row.serial_number;
        msnt_row.to_serial_number           := mut_row.serial_number;
        --msnt_row.INVENTORY_ITEM_ID := l_item_id;
        --msnt_row.ORGANIZATION_ID   := l_org_id;
        --msnt_row.SUBINVENTORY_CODE  := l_sub_code;
        --msnt_row.LOCATOR_ID         := l_loc_id;
        --msnt_row.TRANSACTION_DATE    :=  l_txn_date;
        --msnt_row.TRANSACTION_SOURCE_ID := l_txn_source_id;
        --msnt_row.transaction_source_type_id := l_txn_source_type_id;
        --msnt_row.TRANSACTION_SOURCE_NAME  := l_txn_source_name;
        --msnt_row.RECEIPT_ISSUE_TYPE                 := mut_row.;
        --msnt_row.CUSTOMER_ID                                := mut_row.;
        --msnt_row.SHIP_ID                                    := mut_row.;
        msnt_row.serial_attribute_category  := mut_row.serial_attribute_category;
        msnt_row.origination_date           := mut_row.origination_date;
        msnt_row.c_attribute1               := mut_row.c_attribute1;
        msnt_row.c_attribute2               := mut_row.c_attribute2;
        msnt_row.c_attribute3               := mut_row.c_attribute3;
        msnt_row.c_attribute4               := mut_row.c_attribute4;
        msnt_row.c_attribute5               := mut_row.c_attribute5;
        msnt_row.c_attribute6               := mut_row.c_attribute6;
        msnt_row.c_attribute7               := mut_row.c_attribute7;
        msnt_row.c_attribute8               := mut_row.c_attribute8;
        msnt_row.c_attribute9               := mut_row.c_attribute9;
        msnt_row.c_attribute10              := mut_row.c_attribute10;
        msnt_row.c_attribute11              := mut_row.c_attribute11;
        msnt_row.c_attribute12              := mut_row.c_attribute12;
        msnt_row.c_attribute13              := mut_row.c_attribute13;
        msnt_row.c_attribute14              := mut_row.c_attribute14;
        msnt_row.c_attribute15              := mut_row.c_attribute15;
        msnt_row.c_attribute16              := mut_row.c_attribute16;
        msnt_row.c_attribute17              := mut_row.c_attribute17;
        msnt_row.c_attribute18              := mut_row.c_attribute18;
        msnt_row.c_attribute19              := mut_row.c_attribute19;
        msnt_row.c_attribute20              := mut_row.c_attribute20;
        msnt_row.d_attribute1               := mut_row.d_attribute1;
        msnt_row.d_attribute2               := mut_row.d_attribute2;
        msnt_row.d_attribute3               := mut_row.d_attribute3;
        msnt_row.d_attribute4               := mut_row.d_attribute4;
        msnt_row.d_attribute5               := mut_row.d_attribute5;
        msnt_row.d_attribute6               := mut_row.d_attribute6;
        msnt_row.d_attribute7               := mut_row.d_attribute7;
        msnt_row.d_attribute8               := mut_row.d_attribute8;
        msnt_row.d_attribute9               := mut_row.d_attribute9;
        msnt_row.d_attribute10              := mut_row.d_attribute10;
        msnt_row.n_attribute1               := mut_row.n_attribute1;
        msnt_row.n_attribute2               := mut_row.n_attribute2;
        msnt_row.n_attribute3               := mut_row.n_attribute3;
        msnt_row.n_attribute4               := mut_row.n_attribute4;
        msnt_row.n_attribute5               := mut_row.n_attribute5;
        msnt_row.n_attribute6               := mut_row.n_attribute6;
        msnt_row.n_attribute7               := mut_row.n_attribute7;
        msnt_row.n_attribute8               := mut_row.n_attribute8;
        msnt_row.n_attribute9               := mut_row.n_attribute9;
        msnt_row.n_attribute10              := mut_row.n_attribute10;
        msnt_row.status_id                  := mut_row.status_id;
        msnt_row.territory_code             := mut_row.territory_code;
        msnt_row.time_since_new             := mut_row.time_since_new;
        msnt_row.cycles_since_new           := mut_row.cycles_since_new;
        msnt_row.time_since_overhaul        := mut_row.time_since_overhaul;
        msnt_row.cycles_since_overhaul      := mut_row.cycles_since_overhaul;
        msnt_row.time_since_repair          := mut_row.time_since_repair;
        msnt_row.cycles_since_repair        := mut_row.cycles_since_repair;
        msnt_row.time_since_visit           := mut_row.time_since_visit;
        msnt_row.cycles_since_visit         := mut_row.cycles_since_visit;
        msnt_row.time_since_mark            := mut_row.time_since_mark;
        msnt_row.cycles_since_mark          := mut_row.cycles_since_mark;
        msnt_row.number_of_repairs          := mut_row.number_of_repairs;
        msnt_table(cnt)                     := msnt_row;
        cnt                                 := cnt + 1;
        msnt_row                            := NULL;
      END LOOP;

      IF (l_debug = 1) THEN
        mydebug('after creating msnt_table');
      END IF;
    END IF;

    x_mmtt  := mmtt_table;
    x_mtlt  := mtlt_table;
    x_msnt  := msnt_table;

    IF (l_debug = 1) THEN
      mydebug('end of get_temp_tables');
    END IF;
  END get_temp_tables;

  PROCEDURE generate_next_task(
    x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , x_ret_code      OUT NOCOPY    VARCHAR2
  , p_old_header_id IN            NUMBER
  , p_mo_line_id    IN            NUMBER
  , p_old_sub_code  IN            VARCHAR2
  , p_old_loc_id    IN            NUMBER
  , p_wms_task_type IN            NUMBER
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'GENERATE_NEXT_TASK';
    l_api_version  CONSTANT NUMBER       := 1.0;
    mmtt_table              mmtt_tb;
    mmtt_row                mmtt_type;
    lot_row                 mtlt_type;
    mtlt_table              mtlt_tb;
    ser_row                 msnt_type;
    msnt_table              msnt_tb;
    mmt_row                 mmtt_type;
    mtln_row                mtln_type;
    mut_row                 mut_type;
    cnt                     NUMBER       := 0;
    new_txn_temp_id         NUMBER;
    new_txn_header_id       NUMBER;
    ser_transaction_temp_id NUMBER;
    v_rev_control_code      NUMBER       := -1;
    v_lot_control_code      NUMBER       := -1;
    v_serial_control_code   NUMBER       := -1;
    v_allocate_serial_flag  VARCHAR2(1)  := 'X';
    l_rev_ctrl              VARCHAR2(1)  := 'N';
    l_alloc_ser             VARCHAR2(1)  := 'N';
    --Bug 2561167 fix
    l_crossdocked           VARCHAR2(1)  := 'N';
    l_already_used VARCHAR2(1) := 'N';
    --BUG 2698630 fix
    l_trohdr_rec            INV_Move_Order_PUB.Trohdr_Rec_Type;
    l_trolin_tbl            INV_Move_Order_PUB.Trolin_Tbl_Type;
    l_trolin_val_tbl        INV_Move_Order_PUB.Trolin_Val_Tbl_Type;
    l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_line_num              Number := 0;
    l_uom                   VARCHAR2(60);
    l_trohdr_val_rec        INV_Move_Order_PUB.Trohdr_Val_Rec_Type;
    l_ref VARCHAR2(240);
    l_ref_type NUMBER;
    l_ref_id NUMBER;
     l_req_msg                VARCHAR2(30)   := NULL;
    --BUG 2698630 fix

    CURSOR mtlt(txn_tmp_id NUMBER) IS
      SELECT *
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = txn_tmp_id;

    CURSOR msnt(txn_tmp_id NUMBER) IS
      SELECT *
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = txn_tmp_id;

    l_debug                 NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    SAVEPOINT generate_next_task;
    x_ret_code  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('In generate_next_task');
    END IF;

    IF (l_debug = 1) THEN
      mydebug(' p_old_header_id  is ' || p_old_header_id);
    END IF;

    IF (l_debug = 1) THEN
      mydebug(' p_mo_line_id is ' || p_mo_line_id);
    END IF;

    IF (l_debug = 1) THEN
      mydebug(' p_old_sub_CODE is ' || p_old_sub_code);
    END IF;

    IF (l_debug = 1) THEN
      mydebug(' p_old_loc_id is  ' || p_old_loc_id);
    END IF;

    IF (l_debug = 1) THEN
      mydebug(' p_wms_task_type is  ' || p_wms_task_type);
    END IF;

    --Bug 2561167 fix

    IF (p_wms_task_type = 2 OR p_wms_task_type = -1
	OR p_wms_task_type = 5 -- bug fix 4230494
	) THEN
      --2697301 fix earlier doing p_wms_task_type = 6
      IF (l_debug = 1) THEN
        mydebug('Putaway task');
      END IF;

      l_crossdocked  := 'N';

      BEGIN
        SELECT 'Y'
          INTO l_crossdocked
          FROM DUAL
         WHERE EXISTS(
                 SELECT mtrl.line_id
                   FROM mtl_txn_request_lines mtrl, mtl_material_transactions mmt
                  WHERE mtrl.line_id = mmt.move_order_line_id
                    AND mtrl.backorder_delivery_detail_id IS NOT NULL
                    AND mmt.transaction_set_id = p_old_header_id);
      EXCEPTION
        WHEN OTHERS THEN
          l_crossdocked  := 'N';

          IF (l_debug = 1) THEN
            mydebug('Not cross docked');
          END IF;
      END;

      IF l_crossdocked = 'Y' THEN
        IF (l_debug = 1) THEN
          mydebug('crossdocked - so dont generate next task');
        END IF;

        RETURN;
      END IF;
    ELSIF p_wms_task_type = 4 THEN
      IF (l_debug = 1) THEN
        mydebug('Replenishment task - ok ');
      END IF;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('not repl or putaway task - so dont generate next task');
      END IF;

      RETURN;
    END IF;

    --Bug 2561167 fix



    wms_task_utils_pvt.get_temp_tables(p_set_id => p_old_header_id, x_mmtt => mmtt_table, x_mtlt => mtlt_table, x_msnt => msnt_table);

    IF (l_debug = 1) THEN
      mydebug('After calling get_temp_tables ');
    END IF;

    SELECT mtl_material_transactions_s.NEXTVAL
      INTO new_txn_header_id
      FROM DUAL;

    IF (l_debug = 1) THEN
      mydebug('New Txn Hdr id is ' || new_txn_header_id);
    END IF;

    /*   IF mmtt_table.COUNT > 1 THEN

          IF (l_debug = 1) THEN
             mydebug('ERROR - Number of rows for this header are more than one ');
             mydebug('Raising an unexpected error ');
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;

      END IF;
      */
    FOR cnt IN 1 .. mmtt_table.COUNT LOOP
      mmtt_row  := mmtt_table(cnt);

      IF ((mmtt_row.subinventory_code = p_old_sub_code)
          AND(mmtt_row.locator_id = p_old_loc_id)) THEN
        IF (l_debug = 1) THEN
          mydebug(' source and destination sub location is same ');
          mydebug(' hence new task is not created ');
        END IF;
      ELSIF mmtt_row.primary_quantity <= 0 THEN
        IF (l_debug = 1) THEN
          mydebug(' ignoring the Replenishment task with negative quntity ');
        END IF;

        -- We should always skip the negative quantity one, whenever two
        -- txns are created for the putaway( in case of a po receipt
        -- only one txn gets submitted)
        -- For a replenishment tasks, two rows will be created in MMT
        -- one with a positive quantity corresponding to the movement of
        -- material to the destination
        -- one with negative quantity corresponding to the issue of
        -- material from the source location
        -- so ignoring te negative line here , +ve line is picked up in
        -- the else next

        IF (l_debug = 1) THEN
          mydebug(' ignoring the Replenishment task with negative quntity ');
        END IF;
      ELSIF mmtt_row.transaction_action_id = 50 THEN
        --Bug 2561167 fix
        IF (l_debug = 1) THEN
          mydebug(' ignoring the pack transaction ');
        END IF;
      --Bug 2561167 fix
      ELSE
        IF (l_debug = 1) THEN
          mydebug(' source and destination sub location are not same ');
        END IF;

        SELECT mtl_material_transactions_s.NEXTVAL
          INTO new_txn_temp_id
          FROM DUAL;

        IF (l_debug = 1) THEN
          mydebug('New Txn Temp id is ' || new_txn_temp_id);
        END IF;

        IF (l_debug = 1) THEN
          mydebug('updating the new task ');
        END IF;

        --mmtt_row.transaction_temp_id := new_txn_temp_id;
        mmtt_row.transaction_header_id       := new_txn_header_id;
        -- Always the second task is a replenishment task

        mmtt_row.wms_task_type               := 4;
        mmtt_row.move_order_line_id          := p_mo_line_id;
        mmtt_row.transaction_source_type_id  := inv_globals.g_sourcetype_moveorder; -- bug 4230494
        mmtt_row.transaction_type_id         := 64; -- bug 4230494 move order xfer
        mmtt_row.transaction_action_id       := inv_globals.g_action_subxfr;
        mmtt_row.process_flag                := 'Y';
        mmtt_row.transaction_status          := 2;
        mmtt_row.transfer_subinventory       := p_old_sub_code;
        mmtt_row.transfer_to_location        := p_old_loc_id;
        mmtt_row.posting_flag                := 'Y';

        IF (l_debug = 1) THEN
          mydebug(' mmtt_row.wms_task_type ' || mmtt_row.wms_task_type);
          mydebug(' mmtt_row.mmtt_row.move_order_line_id  ' || mmtt_row.move_order_line_id);
          mydebug(' mmtt_row.transaction_source_type_id ' || mmtt_row.transaction_source_type_id);
          mydebug(' mmtt_row.transaction_type_id ' || mmtt_row.transaction_type_id);
          mydebug(' mmtt_row.transaction_action_id ' || mmtt_row.transaction_action_id);
          mydebug(' mmtt_row.process_flag ' || mmtt_row.process_flag);
          mydebug(' mmtt_row.transaction_status ' || mmtt_row.transaction_status);
          mydebug(' mmtt_row.transfer_subinventory ' || mmtt_row.transfer_subinventory);
          mydebug(' mmtt_row.transfer_to_location ' || mmtt_row.transfer_to_location);
          mydebug(' mmtt_row.primary_quantity ' || mmtt_row.primary_quantity);
          mydebug(' mmtt_row.transaction_quantity ' || mmtt_row.transaction_quantity);
          mydebug('sub ' || mmtt_row.subinventory_code);
          mydebug('loc ' || mmtt_row.locator_id);
          mydebug('t sub ' || mmtt_row.transfer_subinventory);
          mydebug('t loc ' || mmtt_row.transfer_to_location);
        END IF;

	BEGIN
	   SELECT revision_qty_control_code
             , lot_control_code
             , serial_number_control_code
	     , primary_uom_code
	     INTO v_rev_control_code
             , v_lot_control_code
             , v_serial_control_code
	     , l_uom
	     FROM mtl_system_items
	     WHERE inventory_item_id = mmtt_table(cnt).inventory_item_id
	     AND organization_id = mmtt_table(cnt).organization_id;
	EXCEPTION
	   WHEN OTHERS THEN
	      mydebug('Exception getting the item information');
	      RAISE fnd_api.g_exc_unexpected_error;
	END;

	/***** Bug 2999296 Updating locator capacity ***********/

	   mydebug('Updating locator capacity of loc '||mmtt_row.transfer_to_location);

	inv_loc_wms_utils.update_loc_sugg_capacity_nauto
	  ( x_return_status                => l_return_status
	    , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , p_organization_id            => mmtt_row.organization_id
            , p_inventory_location_id      => mmtt_row.transfer_to_location
            , p_inventory_item_id          => mmtt_row.inventory_item_id
            , p_primary_uom_flag           => 'Y'
            , p_transaction_uom_code       => NULL
            , p_quantity                   => mmtt_row.primary_quantity
            );

	IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	       mydebug('Unexpected error in update_loc_suggested_capacity');
	       -- Bug 5393727: do not raise an exception if revert API returns an error
	       -- RAISE fnd_api.g_exc_unexpected_error;
	 ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
	       mydebug('Error in update_loc_suggested_capacity');
	       -- Bug 5393727: do not raise an exception if revert API returns an error
	   -- RAISE fnd_api.g_exc_error;
	END IF;

	/***** Bug 2999296 Updating locator capacity ***********/

	/******* BUG 2698630 fix creating move order*/

	BEGIN
	   SELECT reference,reference_type_code,reference_id
	     INTO l_ref,l_ref_type, l_ref_id
	     FROM mtl_txn_request_lines
	     WHERE
	     line_id = mmtt_row.move_order_line_id;
	EXCEPTION
	   WHEN others THEN
	      mydebug('Exception getting the move order line information');
	      RAISE fnd_api.g_exc_unexpected_error;
	END;

	l_trohdr_rec.request_number             :=  FND_API.G_MISS_CHAR ; --5984021
	l_trohdr_rec.header_id                  :=  FND_API.G_MISS_NUM;
	l_trohdr_rec.created_by                 :=  FND_GLOBAL.USER_ID;
	l_trohdr_rec.creation_date              :=  sysdate;
	l_trohdr_rec.date_required              :=  sysdate;
	l_trohdr_rec.from_subinventory_code     :=  mmtt_row.subinventory_code;
	l_trohdr_rec.header_status     :=  INV_Globals.G_TO_STATUS_PREAPPROVED;
	l_trohdr_rec.last_updated_by            :=   FND_GLOBAL.USER_ID;
	l_trohdr_rec.last_update_date           :=   sysdate;
	l_trohdr_rec.last_update_login          :=   FND_GLOBAL.USER_ID;
	l_trohdr_rec.organization_id            :=   mmtt_row.organization_id;
	l_trohdr_rec.status_date                :=   sysdate;
	l_trohdr_rec.to_subinventory_code       :=   mmtt_row.transfer_subinventory;
	l_trohdr_rec. move_order_type           :=   INV_GLOBALS.g_move_order_replenishment;
	l_trohdr_rec.db_flag                    :=   FND_API.G_TRUE;
	l_trohdr_rec.operation                  :=   INV_GLOBALS.G_OPR_CREATE;

	l_line_num := 1;
	l_trolin_tbl(1).header_id           := l_trohdr_rec.header_id;
	l_trolin_tbl(1).created_by          := FND_GLOBAL.USER_ID;
	l_trolin_tbl(1).creation_date       := sysdate;
	l_trolin_tbl(1).date_required       := sysdate;
	l_trolin_tbl(1).from_subinventory_code  := mmtt_row.subinventory_code;
	l_trolin_tbl(1).from_locator_id   := mmtt_row.locator_id;
	l_trolin_tbl(1).inventory_item_id  := mmtt_row.inventory_item_id;
	l_trolin_tbl(1).last_updated_by    := FND_GLOBAL.USER_ID;
	l_trolin_tbl(1).last_update_date   := sysdate;
	l_trolin_tbl(1).last_updated_by    := FND_GLOBAL.USER_ID;
	l_trolin_tbl(1).last_update_date   := sysdate;
	l_trolin_tbl(1).last_update_login  := FND_GLOBAL.LOGIN_ID;
	l_trolin_tbl(1).line_id            := FND_API.G_MISS_NUM;
	l_trolin_tbl(1).line_number        := l_line_num;
	l_trolin_tbl(1).line_status        := INV_Globals.G_TO_STATUS_PREAPPROVED;
	l_trolin_tbl(1).organization_id    := mmtt_row.organization_id;
	l_trolin_tbl(1).quantity           := mmtt_row.primary_quantity;
	l_trolin_tbl(1).quantity_detailed  := mmtt_row.primary_quantity;
	--Bug 4593622 stamping mmtt_row.primary_quantity as quantity_detailed

	l_trolin_tbl(1).status_date        := sysdate;
	l_trolin_tbl(1).to_subinventory_code   := mmtt_row.transfer_subinventory;
	l_trolin_tbl(1).uom_code               := l_uom;
	l_trolin_tbl(1).db_flag                := FND_API.G_TRUE;
	l_trolin_tbl(1).operation              := INV_GLOBALS.G_OPR_CREATE;

	l_trolin_tbl(1).lpn_id   :=  NULL;
	l_trolin_tbl(1).reference:=l_ref;
	l_trolin_tbl(1).reference_type_code:=l_ref_type;
	l_trolin_tbl(1).reference_id:=l_ref_id;
	l_trolin_tbl(1).project_id:=NULL;
	l_trolin_tbl(1).task_id:=NULL;
	l_trolin_tbl(1).lot_number:=NULL;
	l_trolin_tbl(1).revision:=mmtt_row.revision;
	l_trolin_tbl(1).transaction_type_id:=mmtt_row.transaction_type_id;
	l_trolin_tbl(1).transaction_source_type_id:=mmtt_row.transaction_source_type_id;
	l_trolin_tbl(1).inspection_status:=NULL;
	l_trolin_tbl(1).wms_process_flag:=NULL;
	l_trolin_tbl(1).to_organization_id:=mmtt_row.transfer_organization;
	l_trolin_tbl(1).txn_source_id:=mmtt_row.transaction_source_id;
	l_trolin_tbl(1).from_cost_group_id:=mmtt_row.cost_group_id;
	l_trolin_tbl(1).to_cost_group_id:=mmtt_row.transfer_cost_group_id;

	INV_Move_Order_PUB.Process_Move_Order
	  (  p_api_version_number       => 1.0 ,
	     p_init_msg_list            => 'F',
	     p_commit                   => FND_API.G_FALSE,
	     x_return_status            => l_return_status,
	     x_msg_count                => l_msg_count,
	     x_msg_data                 => l_msg_data,
	     p_trohdr_rec               => l_trohdr_rec,
	     p_trohdr_val_rec           => l_trohdr_val_rec,
	     p_trolin_tbl               => l_trolin_tbl,
	     p_trolin_val_tbl           => l_trolin_val_tbl,
	     x_trohdr_rec               => l_trohdr_rec,
	     x_trohdr_val_rec           => l_trohdr_val_rec,
	     x_trolin_tbl               => l_trolin_tbl,
	     x_trolin_val_tbl           => l_trolin_val_tbl
	     );


	fnd_msg_pub.count_and_get
	  (  p_count  => l_msg_count
	     , p_data   => l_msg_data
	     );
	IF (l_msg_count = 0) THEN
	   IF (l_debug = 1) THEN
	      mydebug('create_mo: Successful');
	   END IF;
	 ELSIF (l_msg_count = 1) THEN
	   IF (l_debug = 1) THEN
	      mydebug('create_mo: Not Successful');
	      mydebug('create_mo: ' || replace(l_msg_data,fnd_global.local_chr(0),' '));
	   END IF;
	 ELSE
	   IF (l_debug = 1) THEN
	      mydebug('create_mo: Not Successful2');
	   END IF;
	   For I in 1..l_msg_count LOOP
	      l_msg_data := fnd_msg_pub.get(I,'F');
	      IF (l_debug = 1) THEN
		 mydebug('create_mo: ' || replace(l_msg_data,fnd_global.local_chr(0),' '));
	      END IF;
	   END LOOP;
	END IF;


	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   FND_MESSAGE.SET_NAME('WMS','WMS_TD_MO_ERROR' );
	   FND_MSG_PUB.ADD;
	   RAISE FND_API.g_exc_unexpected_error;

	 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   FND_MESSAGE.SET_NAME('WMS','WMS_TD_MO_ERROR');
	   FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;


       /* Get header and line ids */
	IF (l_debug = 1) THEN
	   mydebug('create_mo: Header'||l_trohdr_rec.header_id);
	   mydebug('create_mo: line'||l_trolin_tbl(1).line_id);
	   mydebug('create_mo: ' || l_trolin_tbl(1).organization_id);
	END IF;

	mmtt_row.move_order_line_id                := l_trolin_tbl(1).line_id;
	mmtt_row.trx_source_line_id                := l_trolin_tbl(1).line_id; -- bug 4230494
	/******* BUG 2698630 fix creating move order*/

        /*************NOW Updating MTLT and MSNT *************************/


        IF v_rev_control_code = 2 THEN
          l_rev_ctrl  := 'Y';
        ELSE
          l_rev_ctrl  := 'N';
        END IF;

        SELECT allocate_serial_flag
          INTO v_allocate_serial_flag
          FROM mtl_parameters
         WHERE organization_id = mmtt_table(cnt).organization_id;

        IF v_allocate_serial_flag = 'Y' THEN
          l_alloc_ser  := 'Y';
        ELSE
          l_alloc_ser  := 'N';
        END IF;

        /*****LOT controlled only **********/
        IF (v_lot_control_code = 2
            AND v_serial_control_code IN(1, 6)) THEN
          IF (l_debug = 1) THEN
            mydebug(' LOT controlled only ');
          END IF;

          FOR cnt2 IN 1 .. mtlt_table.COUNT LOOP
            lot_row  := mtlt_table(cnt2);

            IF lot_row.transaction_temp_id = mmtt_row.transaction_temp_id THEN
              IF (l_debug = 1) THEN
                mydebug('child row with temp id ' || lot_row.transaction_temp_id);
              END IF;

              IF NOT check_qty_avail(
                      mmtt_row                     => mmtt_row
                    , lot_row                      => lot_row
                    , ser_row                      => NULL
                    , p_is_revision_control        => l_rev_ctrl
                    , p_is_lot_control             => 'Y'
                    , p_is_serial_control          => 'N'
                    , p_allocate_serial_flag       => l_alloc_ser
                    ) THEN
                IF (l_debug = 1) THEN
                  mydebug('failed quantity check ');
                END IF;

                RAISE g_qty_not_avail;
              END IF;

              lot_row.transaction_temp_id  := new_txn_temp_id;
              inv_rcv_common_apis.insert_mtlt(lot_row);
              lot_row                      := NULL;
            END IF;
          END LOOP;
        /********* serial Controlled only **************/
        ELSIF(v_lot_control_code = 1
              AND v_serial_control_code NOT IN(1, 6)) THEN
          IF (l_debug = 1) THEN
            mydebug(' Serial controlled only ');
          END IF;

          IF (v_allocate_serial_flag = 'Y') THEN
            IF (l_debug = 1) THEN
              mydebug(' allocate_serial_flag is Y ');
            END IF;
	    /**2706001 checking the avail outside loop **/
	    IF NOT check_qty_avail(mmtt_row => mmtt_row,
				   lot_row => null,
				   ser_row => null,
				   p_is_revision_control => l_rev_ctrl,
				   p_is_lot_control => 'N',
				   p_is_serial_control => 'Y',
				   p_allocate_serial_flag => l_alloc_ser) THEN
	       mydebug('failed quantity check ');
	       RAISE g_qty_not_avail;
	    END IF;

            FOR cnt3 IN 1 .. msnt_table.COUNT LOOP
              ser_row  := msnt_table(cnt3);

              IF ser_row.transaction_temp_id = mmtt_row.transaction_temp_id THEN
                IF (l_debug = 1) THEN
                  mydebug('child row with temp id ' || ser_row.transaction_temp_id);
                END IF;

		/**2706001 checking group mark ids here **/
		l_already_used := 'N';
             	BEGIN
		   SELECT 'Y' INTO l_already_used FROM dual WHERE exists
		     (SELECT 1
		      FROM mtl_serial_numbers
		      WHERE
		      --Bug 2940878 fix added current_organization_id ,
		      --inventory_item_id in the query
		      -- also changed the condition on group_mark_id
		      current_organization_id = mmtt_row.organization_id AND
		      inventory_item_id = mmtt_row.inventory_item_id AND
		      serial_number >= ser_row.fm_serial_number AND
		      serial_number <= ser_row.to_serial_number AND
		      --group_mark_id IS NOT NULL
		      Nvl(group_mark_id, -1) <> -1
		      );
		EXCEPTION
		   WHEN no_data_found THEN
		      l_already_used := 'N';
		   WHEN OTHERS THEN
		      mydebug('Error occurred '||Sqlerrm);
		      l_already_used := NULL;
		      RAISE fnd_api.g_exc_unexpected_error;
		END;

		IF l_already_used = 'Y' then
		   mydebug('failed quantity check ');
		   RAISE g_qty_not_avail;
		END IF;
		/**2706001 checking group mark ids here **/
                ser_row.transaction_temp_id  := new_txn_temp_id;
                inv_rcv_common_apis.insert_msnt(ser_row);
                ser_row                      := NULL;
              END IF;
            END LOOP;
          END IF;
        /********* LOT and serial Controlled  **************/
        ELSIF(v_lot_control_code = 2
              AND v_serial_control_code NOT IN(1, 6)) THEN
          IF (l_debug = 1) THEN
            mydebug(' Both lot and Serial controlled  ');
          END IF;

          IF (v_allocate_serial_flag = 'N') THEN
            /*******************same as LOT CONTROLLED ONLY***********/
            FOR cnt4 IN 1 .. mtlt_table.COUNT LOOP
              lot_row  := mtlt_table(cnt4);

              IF lot_row.transaction_temp_id = mmtt_row.transaction_temp_id THEN
                IF (l_debug = 1) THEN
                  mydebug('child row with temp id ' || lot_row.transaction_temp_id);
                END IF;

                IF NOT check_qty_avail(
                        mmtt_row                     => mmtt_row
                      , lot_row                      => lot_row
                      , ser_row                      => NULL
                      , p_is_revision_control        => l_rev_ctrl
                      , p_is_lot_control             => 'Y'
                      , p_is_serial_control          => 'Y'
                      , p_allocate_serial_flag       => l_alloc_ser
                      ) THEN
                  IF (l_debug = 1) THEN
                    mydebug('failed quantity check ');
                  END IF;

                  RAISE g_qty_not_avail;
                END IF;

                lot_row.serial_transaction_temp_id  := NULL;
                lot_row.transaction_temp_id         := new_txn_temp_id;
                inv_rcv_common_apis.insert_mtlt(lot_row);
                lot_row                             := NULL;
              END IF;
            END LOOP;
          --END IF;
          ELSE
            /*Need to insert both lot and serial tables*/
            IF (l_debug = 1) THEN
              mydebug(' allocate_serial_flag is Y ');
            END IF;

            FOR cnt5 IN 1 .. mtlt_table.COUNT LOOP
              lot_row  := mtlt_table(cnt5);

              /***********Serial Stuff *****************************/
              IF lot_row.transaction_temp_id = mmtt_row.transaction_temp_id THEN
                IF (l_debug = 1) THEN
                  mydebug('child lot row with temp id ' || lot_row.transaction_temp_id);
                END IF;
		/**2706001 checking avail qty outside loop **/
		IF NOT check_qty_avail(mmtt_row => mmtt_row,
				       lot_row => lot_row,
				       ser_row => null,
				       p_is_revision_control => l_rev_ctrl,
				       p_is_lot_control => 'Y',
				       p_is_serial_control => 'Y',
				       p_allocate_serial_flag => l_alloc_ser) THEN
		   mydebug('failed quantity check ');
		   RAISE g_qty_not_avail;
		END IF;

		/**2706001 moved this out of below loop **/
		SELECT mtl_material_transactions_s.NEXTVAL
		  INTO ser_transaction_temp_id
		  FROM dual;

		/**2706001 was using cnt6 earlier **/
                FOR cnt6 IN 1 .. msnt_table.COUNT LOOP
		   ser_row  := msnt_table(cnt6);

		   IF ser_row.transaction_temp_id = lot_row.serial_transaction_temp_id THEN
		      /**2706001 checking group mark ids here **/
		      l_already_used := 'N';
               	      BEGIN
			 SELECT 'Y' INTO l_already_used FROM dual WHERE exists
			   (SELECT 1
			    FROM mtl_serial_numbers
			    WHERE
			    --Bug 2940878 fix added current_organization_id ,
			    --inventory_item_id in the query
			    -- also changed the condition on group_mark_id
			    current_organization_id = mmtt_row.organization_id AND
			    inventory_item_id = mmtt_row.inventory_item_id AND
			    serial_number >= ser_row.fm_serial_number AND
			    serial_number <= ser_row.to_serial_number AND
			    --group_mark_id IS NOT NULL
			    Nvl(group_mark_id, -1) <> -1
			    );
		      EXCEPTION
			 WHEN no_data_found THEN
			    l_already_used := 'N';
			 WHEN OTHERS THEN
			    mydebug('Error occurred '||Sqlerrm);
			    l_already_used := NULL;
			    RAISE fnd_api.g_exc_unexpected_error;
		      END;

		      IF l_already_used = 'Y' then
			 mydebug('failed quantity check ');
			 RAISE g_qty_not_avail;
		      END IF;
		      /**2706001 checking group mark ids here **/

		      ser_row.transaction_temp_id:= ser_transaction_temp_id;
		      inv_rcv_common_apis.insert_msnt(ser_row);
		      ser_row                             := NULL;
		      --lot_row.serial_transaction_temp_id  := ser_row.transaction_temp_id;
                  END IF;
                END LOOP;

                /***********Serial Stuff *****************************/
		/**2706001 moved this assignment out of the loop **/
		lot_row.serial_transaction_temp_id := ser_transaction_temp_id;

		lot_row.transaction_temp_id  := new_txn_temp_id;
                inv_rcv_common_apis.insert_mtlt(lot_row);
                lot_row                      := NULL;
              END IF;
            END LOOP;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('vanilla item');
          END IF;

          IF NOT check_qty_avail(
                  mmtt_row                     => mmtt_row
                , lot_row                      => NULL
                , ser_row                      => NULL
                , p_is_revision_control        => l_rev_ctrl
                , p_is_lot_control             => 'N'
                , p_is_serial_control          => 'N'
                , p_allocate_serial_flag       => l_alloc_ser
                ) THEN
            IF (l_debug = 1) THEN
              mydebug('failed quantity check ');
            END IF;

            RAISE g_qty_not_avail;
          END IF;
        END IF;

        IF (l_debug = 1) THEN
          mydebug(' inserting the new row into mmtt using ' || 'wms_task_dispatch_engine.insert_mmtt ');
        END IF;

        mmtt_row.transaction_temp_id         := new_txn_temp_id;


	--//***************//

	  --Add code here
	  IF wms_device_integration_pvt.wms_call_device_request IS NULL THEN
	     wms_device_integration_pvt.is_device_set_up(mmtt_row.organization_id,wms_device_integration_pvt.WMS_BE_MO_TASK_ALLOC,l_return_status);
	  END IF;

	  --Insert records into WMS_DEVICE_REQUESTS TABLE
	  wms_cartnzn_pub.insert_device_request_rec(mmtt_row);



	  -- Call Device Integration API to send the details of this
	  -- Move Order Task Allocation to devices, if it is a WMS organization.
	  -- Note: We don't check for the return condition of this API as
	  -- we let the Allocation  process succee irrespective of
	  -- DeviceIntegration succeed or fail.

	     WMS_DEVICE_INTEGRATION_PVT.device_request
	       (p_bus_event      => WMS_DEVICE_INTEGRATION_PVT.WMS_BE_MO_TASK_ALLOC,
		p_call_ctx       => WMS_Device_integration_pvt.DEV_REQ_AUTO,
		p_task_trx_id    => NULL,
		x_request_msg    => l_req_msg,
		x_return_status  => l_return_status,
		x_msg_count      => l_msg_count,
		x_msg_data       => l_msg_data
		);

	     IF (l_debug = 1) THEN
		mydebug('Device_API: return stat:'||l_return_status);
	     END IF;

	  --//**************//


        wms_task_dispatch_engine.insert_mmtt(l_mmtt_rec => mmtt_row);

        IF (l_debug = 1) THEN
          mydebug(' calling  wms_rule_pvt.assigntt ');
        END IF;

        wms_rule_pvt.assigntt(
          p_api_version                => 1.0
        , p_task_id                    => new_txn_temp_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

	IF (l_debug = 1) THEN
	   mydebug('After calling wms_rule_pvt.assigntt l_return_status :'||x_return_status||' new_txn_temp_id :'||new_txn_temp_id);
	END IF;

        IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
          IF (l_debug = 1) THEN
            mydebug(' error returned from wms_rule_pvt.assigntt ');
            mydebug(x_msg_data);
          END IF;

          RAISE fnd_api.g_exc_error;
        ELSE
          IF (l_debug = 1) THEN
            mydebug(' success returned from wms_rule_pvt.assigntt ');
          END IF;
        END IF;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN g_qty_not_avail THEN
      ROLLBACK TO generate_next_task;
      x_return_status  := fnd_api.g_ret_sts_error;
      x_ret_code       := 'QTY_NOT_AVAIL';
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    --      IF (x_msg_count = 0) THEN
    --   dbms_output.put_line('Successful');
    --       ELSIF (x_msg_count = 1) THEN
    --   dbms_output.put_line ('Not Successful');
    --   dbms_output.put_line (replace(x_msg_data,chr(0),' '));
    --       ELSE
    --   dbms_output.put_line ('Not Successful2');
    --   For I in 1..x_msg_count LOOP
    --      x_msg_data := fnd_msg_pub.get(I,'F');
    --      dbms_output.put_line(replace(x_msg_data,chr(0),' '));
    --   END LOOP;
    --      END IF;

    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO generate_next_task;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    --      IF (x_msg_count = 0) THEN
    --   dbms_output.put_line('Successful');
    --       ELSIF (x_msg_count = 1) THEN
    --   dbms_output.put_line ('Not Successful');
    --   dbms_output.put_line (replace(x_msg_data,chr(0),' '));
    --       ELSE
    --   dbms_output.put_line ('Not Successful2');
    --   For I in 1..x_msg_count LOOP
    --      x_msg_data := fnd_msg_pub.get(I,'F');
    --      dbms_output.put_line(replace(x_msg_data,chr(0),' '));
    --   END LOOP;
    --      END IF;


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO generate_next_task;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO generate_next_task;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END generate_next_task;

  PROCEDURE cancel_task(
    x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_emp_id        IN            NUMBER
  , p_temp_id       IN            NUMBER
  , p_previous_task_status   IN            NUMBER := -1/*added for 3602199*/

  ) IS
    l_dev_temp_id          NUMBER         := 0;
    l_dev_request_id       NUMBER         := 0;
    l_dev_request_msg      VARCHAR2(1000);
    l_mo_line_id           NUMBER         := NULL;
    l_mmtt_count           NUMBER;
    l_txn_temp_id          NUMBER         := NULL;
    l_txn_quantity         NUMBER         := 0;
    l_deleted_quantity     NUMBER         := 0;

    CURSOR c_wdt_dispatched IS
      SELECT transaction_temp_id, device_request_id
        FROM wms_dispatched_tasks
       WHERE person_id = p_emp_id
         AND(status <= 3 OR status = 9)
         AND device_request_id IS NOT NULL;

    CURSOR c_mo_line_id IS
      SELECT mtrl.line_id
        FROM mtl_material_transactions_temp mmtt
           , mtl_txn_request_lines mtrl
       WHERE (mmtt.transaction_temp_id = p_temp_id OR mmtt.parent_line_id = p_temp_id)
         AND mtrl.line_id = mmtt.move_order_line_id
         AND mtrl.line_status = INV_GLOBALS.G_TO_STATUS_CANCEL_BY_SOURCE;

    CURSOR c_mmtt_to_del IS
      SELECT mmtt.transaction_temp_id, mmtt.primary_quantity
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.move_order_line_id = l_mo_line_id
         AND NOT EXISTS(SELECT 1
                          FROM mtl_material_transactions_temp t1
                         WHERE t1.parent_line_id = mmtt.transaction_temp_id)
         AND NOT EXISTS(SELECT 1
                          FROM wms_dispatched_tasks wdt
                         WHERE wdt.transaction_temp_id = mmtt.transaction_temp_id);

    CURSOR c_get_mmtt_count IS
       SELECT count(*)
         FROM mtl_material_transactions_temp mmtt
        WHERE mmtt.move_order_line_id = l_mo_line_id
          AND NOT EXISTS ( SELECT 1
                             FROM mtl_material_transactions_temp t1
                            WHERE t1.parent_line_id = mmtt.transaction_temp_id);

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('Cancelling the Task: TxnTempID = ' || p_temp_id || ' : EmployeeID = ' || p_emp_id);
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;

    -- Call device request for task cancel
    OPEN c_wdt_dispatched;
    LOOP
      FETCH c_wdt_dispatched INTO l_dev_temp_id, l_dev_request_id;
      EXIT WHEN c_wdt_dispatched%NOTFOUND;

      IF l_dev_request_id IS NOT NULL THEN
        IF (l_debug = 1) THEN
          mydebug('Calling device Request for Device Temp ID = ' || l_dev_temp_id);
        END IF;

        wms_device_integration_pvt.device_request(
          p_bus_event                  => wms_device_integration_pvt.wms_be_task_cancel
        , p_call_ctx                   => 'U'
        , p_task_trx_id                => l_dev_temp_id
        , x_request_msg                => l_dev_request_msg
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_request_id                 => l_dev_request_id
        );
      END IF;
    END LOOP;
    CLOSE c_wdt_dispatched;

    ROLLBACK; --bug#2458131

    -- Making all dispatched and active (Patchset I) tasks  to pending tasks assigned to this user
    -- bug 3602199 keep queued tasks as queued and dont delete wdt
    -- DELETE FROM wms_dispatched_tasks WHERE person_id = p_emp_id AND status IN(3, 9);
    if(p_previous_task_status = 2/*queued*/) then
	DELETE FROM wms_dispatched_tasks WHERE person_id = p_emp_id AND status IN(3, 9) and transaction_temp_id <> p_temp_id;
	update  wms_dispatched_tasks set status = 2 where transaction_temp_id = p_temp_id and person_id = p_emp_id;
/*	mydebug('Rows update in wdt 3602199' || SQL%ROWCOUNT);*/
    else/*old code*/
    DELETE FROM wms_dispatched_tasks where person_id = p_emp_id and status in (3,9);
/*	mydebug('All rows deleted from wdt' || SQL%ROWCOUNT);*/
    end if;

    OPEN c_mo_line_id;

    LOOP
      FETCH c_mo_line_id INTO l_mo_line_id;
      EXIT WHEN c_mo_line_id%NOTFOUND;
      IF (l_debug = 1) THEN
        mydebug('Cancelling Tasks for MO Line ID = ' || l_mo_line_id);
      END IF;
      l_deleted_quantity  := 0;

      OPEN c_mmtt_to_del;
      LOOP
        FETCH c_mmtt_to_del INTO l_txn_temp_id, l_txn_quantity;
        EXIT WHEN c_mmtt_to_del%NOTFOUND;

        inv_trx_util_pub.delete_transaction(
          x_return_status       => x_return_status
        , x_msg_data            => x_msg_data
        , x_msg_count           => x_msg_count
        , p_transaction_temp_id => l_txn_temp_id
        );
        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          IF l_debug = 1 THEN
            mydebug('Not able to delete the Txn = ' || l_txn_temp_id);
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        l_deleted_quantity  := l_deleted_quantity + l_txn_quantity;
      END LOOP;
      CLOSE c_mmtt_to_del;

      OPEN c_get_mmtt_count;
      FETCH c_get_mmtt_count INTO l_mmtt_count;
      CLOSE c_get_mmtt_count;

      UPDATE mtl_txn_request_lines
         SET quantity_detailed =(quantity_detailed - l_deleted_quantity)
           , line_status = DECODE(l_mmtt_count, 0, INV_GLOBALS.G_TO_STATUS_CLOSED, line_status)
       WHERE line_id = l_mo_line_id;
    END LOOP;
    CLOSE c_mo_line_id;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'CANCEL_TASK');
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END cancel_task;

  /*****************************************************************/
  --This function is called from the currentTasksFListener on pressing
  --the Unload button,
  --returns Y if you can continue with the unload,
  --returns E,U if an error occurred in this api
  --returns N if you cannot unload and puts the appropriate error in the stack
  --returns M if you cannot unload because lpn has multiple allocations
  /*****************************************************************/
  FUNCTION can_unload(p_temp_id IN NUMBER)
    RETURN VARCHAR2 IS
    l_transfer_lpn_id NUMBER      := NULL;
    l_multiple_rows   VARCHAR2(1) := NULL;
    l_debug           NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug(' In CAN_UNLOAD for transaction_temp_id ' || p_temp_id);
    END IF;

    IF (p_temp_id IS NULL) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    BEGIN
      IF (l_debug = 1) THEN
        mydebug(' checking if the row has same lpn_id and content_lpn_id ');
      END IF;

      SELECT transfer_lpn_id
        INTO l_transfer_lpn_id
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_temp_id
         AND content_lpn_id = transfer_lpn_id;

      IF (l_debug = 1) THEN
        mydebug(' lpn_id and content_lpn_id are the same ' || l_transfer_lpn_id);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug(' lpn_id and content_lpn_id are different ');
        END IF;

        RETURN 'Y';
    END;

    IF (l_transfer_lpn_id IS NULL) THEN
      IF (l_debug = 1) THEN
        mydebug('ERROR: transfer_lpn passed is null');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
      mydebug(' checking if the lpn has multiple allocations ');
    END IF;

    BEGIN
      SELECT 'Y'
        INTO l_multiple_rows
        FROM DUAL
       WHERE EXISTS(SELECT transaction_temp_id
                      FROM mtl_material_transactions_temp
                     WHERE transfer_lpn_id = l_transfer_lpn_id
                       AND transaction_temp_id <> p_temp_id);

      IF (l_debug = 1) THEN
        mydebug(' lpn has multiple allocations ' || l_multiple_rows);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug(' lpn has single allocation ');
        END IF;

        RETURN 'Y';
    END;

    fnd_message.set_name('WMS', 'WMS_LPN_MULTIPLE_ALLOC_ERR');
    fnd_msg_pub.ADD;
    RETURN 'M';
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      fnd_message.set_name('WMS', 'WMS_CAN_UNLOAD_ERROR');
      fnd_msg_pub.ADD;
      RETURN fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_message.set_name('WMS', 'WMS_CAN_UNLOAD_ERROR');
      fnd_msg_pub.ADD;
      RETURN fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('Exception occurred in can_unload api' || SQLERRM);
      END IF;

      fnd_message.set_name('WMS', 'WMS_CAN_UNLOAD_ERROR');
      fnd_msg_pub.ADD;
      RETURN fnd_api.g_ret_sts_unexp_error;
  END can_unload;

/* over loaded the procedure can_unload to resolve the JDBC error */
PROCEDURE can_unload(x_can_unload out  NOCOPY VARCHAR2, p_temp_id IN NUMBER)
IS
BEGIN
    x_can_unload := can_unload(p_temp_id);
END;

END wms_task_utils_pvt;

/
