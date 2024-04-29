--------------------------------------------------------
--  DDL for Package Body WMS_UNLOAD_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_UNLOAD_UTILS_PVT" AS
  /* $Header: WMSUNLDB.pls 120.3.12010000.2 2009/08/31 11:13:28 schiluve ship $ */
  g_pkg_name      CONSTANT VARCHAR2(30) := 'WMS_UNLOAD_UTILS_PVT';
  g_pkg_body_ver  CONSTANT VARCHAR2(100) := '$Header: WMSUNLDB.pls 120.3.12010000.2 2009/08/31 11:13:28 schiluve ship $';
  g_newline       CONSTANT VARCHAR2(10)  := fnd_global.newline;


  PROCEDURE mydebug(msg IN VARCHAR2) IS
  BEGIN
    inv_log_util.trace(msg, g_pkg_name, 3);
  END mydebug;



  PROCEDURE print_version_info
    IS
  BEGIN
    mydebug ('Package body: ' || g_pkg_body_ver);
  END print_version_info;



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
    l_sec_del_quantity           NUMBER       := 0; -- Added for bug 8703085
    l_quantity                   NUMBER       := 0;
    l_sec_quantity               NUMBER       := 0; -- Added for bug 8703085
    mol_id                       NUMBER       := NULL;
    line_status                  NUMBER       := NULL;
    v_lot_control_code           NUMBER       := NULL;
    v_serial_control_code        NUMBER       := NULL;
    v_allocate_serial_flag       VARCHAR2(1)  := NULL;
    l_msg_count                  NUMBER;
    l_return_status              VARCHAR2(1);
    l_msg_data                   VARCHAR2(100);
    -- bug 2091680
    l_transfer_lpn_id            NUMBER;
    l_wms_task_types             NUMBER;
    l_content_lpn_id             NUMBER;
    l_count                      NUMBER;
    l_fm_serial_number           VARCHAR2(30);
    l_to_serial_number           VARCHAR2(30);
    l_serial_transaction_temp_id NUMBER;
    l_lpn                    WMS_CONTAINER_PUB.LPN;
    l_lpn_context             NUMBER;

    CURSOR mmtt_to_del(mol_id NUMBER) IS
      SELECT mmtt.transaction_temp_id
           , ABS(mmtt.transaction_quantity) --mmtt.primary_quantity
	   , ABS(mmtt.secondary_transaction_quantity) -- Added for bug 8703085
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

    CURSOR c_fm_to_lot_serial_number (p_sn_temp_id  IN  NUMBER) IS
      SELECT fm_serial_number
           , to_serial_number
        FROM mtl_serial_numbers_temp msnt
       WHERE msnt.transaction_temp_id = p_sn_temp_id;

    CURSOR c_lot_allocations IS
      SELECT serial_transaction_temp_id
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_temp_id;

    l_debug                      NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  BEGIN
    IF (l_debug = 1) THEN
      mydebug(' in unload_task ');
    END IF;

    print_version_info;

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
        FETCH mmtt_to_del INTO l_temp_id, l_quantity,l_sec_quantity; -- Added for bug 8703085
        EXIT WHEN mmtt_to_del%NOTFOUND;

        IF (l_debug = 1) THEN
          mydebug('deleting allocations l_temp_id:' || l_temp_id || ' l_quantity:' || l_quantity|| ' l_sec_quantity:' || l_sec_quantity);
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
	  l_sec_del_quantity  := l_sec_del_quantity + l_sec_quantity; -- Added for bug 8703085
        END IF;
      END LOOP;

      IF (l_debug = 1) THEN
        mydebug(' alloc quantity deleted ' || l_del_quantity);
	mydebug(' alloc quantity deleted ' || l_sec_del_quantity);
      END IF;

      UPDATE mtl_txn_request_lines
         SET quantity_detailed =(quantity_detailed - l_del_quantity),
	 secondary_quantity_detailed =(secondary_quantity_detailed - l_sec_del_quantity)
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
           , mmtt.serial_allocated_flag
        INTO v_lot_control_code
           , v_serial_control_code
           , v_allocate_serial_flag
        FROM mtl_system_items                msi
           , mtl_material_transactions_temp  mmtt
       WHERE msi.inventory_item_id    = mmtt.inventory_item_id
         AND msi.organization_id      = mmtt.organization_id
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
            OPEN c_fm_to_lot_serial_number (l_serial_transaction_temp_id);

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
	l_lpn.lpn_id      := l_content_lpn_id;
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
           , wms_task_status = 1 -- Bug4185621: update mmtt task status back to pending
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

	    IF l_lpn_context <> 1 AND  l_lpn_context IS NOT NULL THEN


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
  EXCEPTION
    WHEN OTHERS THEN
      x_ret_value  := 0;

      IF (l_debug = 1) THEN
        mydebug(' In exception unload_task x_ret' || x_ret_value);
      END IF;

      fnd_msg_pub.count_and_get(p_count => msg_cnt, p_data => x_message);
  END unload_task;



  PROCEDURE unload_bulk_task
  ( x_next_temp_id   OUT NOCOPY  NUMBER
  , x_return_status  OUT NOCOPY  VARCHAR2
  , p_txn_temp_id    IN          NUMBER
  ) IS
    l_count                      NUMBER       := 0;
    l_line_type                  VARCHAR2(20) := NULL;
    l_temp_id                    NUMBER       := NULL;
    l_org_id                     NUMBER       := NULL;
    l_item_id                    NUMBER       := NULL;
    l_quantity                   NUMBER       := 0;
    l_txn_uom                    VARCHAR2(3)  := NULL;
    l_mo_line_uom                VARCHAR2(3)  := NULL;
    l_conv_qty                   NUMBER       := 0;
    l_mo_line_id                 NUMBER       := NULL;
    v_lot_control_code           NUMBER       := NULL;
    v_serial_control_code        NUMBER       := NULL;
    v_allocate_serial_flag       VARCHAR2(1)  := NULL;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    l_return_status              VARCHAR2(1);
    -- bug 2091680
    l_transfer_lpn_id            NUMBER;
    l_content_lpn_id             NUMBER;
    l_fm_serial_number           VARCHAR2(30);
    l_to_serial_number           VARCHAR2(30);
    l_serial_transaction_temp_id NUMBER;
    l_lpn                    WMS_CONTAINER_PUB.LPN;
    l_lpn_context               NUMBER;

    CURSOR c_cncl_ovrpick_lines (p_temp_id  IN  NUMBER) IS
      SELECT 'CANCELLED'
           , mmtt.transaction_temp_id
           , ABS(mmtt.transaction_quantity)
           , mmtt.transaction_uom
           , mmtt.move_order_line_id
           , mtrl.uom_code
        FROM mtl_material_transactions_temp  mmtt
           , mtl_txn_request_lines           mtrl
       WHERE mmtt.parent_line_id = p_temp_id
         AND mtrl.line_id        = mmtt.move_order_line_id
         AND mtrl.line_status    = 9
       UNION ALL
      SELECT 'OVERPICKED'
           , mmtt.transaction_temp_id
           , ABS(mmtt.transaction_quantity)
           , mmtt.transaction_uom
           , to_number(NULL)
           , to_char(NULL)
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.parent_line_id        = p_temp_id
         AND mmtt.transaction_temp_id  <> mmtt.parent_line_id
         AND mmtt.transaction_action_id = 2
         AND mmtt.move_order_line_id   IS NULL;


    CURSOR msnt_to_del (p_temp_id  IN  NUMBER) IS
      SELECT serial_transaction_temp_id
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_temp_id;


    CURSOR c_fm_to_serial_number (p_temp_id  IN  NUMBER) IS
      SELECT fm_serial_number
           , to_serial_number
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = p_temp_id;


    CURSOR c_fm_to_lot_serial_number (p_sn_temp_id  IN  NUMBER) IS
      SELECT fm_serial_number
           , to_serial_number
        FROM mtl_serial_numbers_temp msnt
       WHERE msnt.transaction_temp_id = p_sn_temp_id;


    CURSOR c_lot_allocations (p_temp_id  IN  NUMBER) IS
      SELECT serial_transaction_temp_id
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_temp_id;


    CURSOR c_next_temp_id
    ( p_xfer_lpn_id  IN  NUMBER
    , p_temp_id      IN  NUMBER
    ) IS
    -- Material packed into content LPNs
    SELECT m.transaction_temp_id
         , 1                      dummy_sort
      FROM wms_dispatched_tasks            w
         , mtl_material_transactions_temp  m
     WHERE m.transfer_lpn_id      = p_xfer_lpn_id
       AND m.transaction_temp_id <> p_temp_id
       AND m.transaction_temp_id  = m.parent_line_id
       AND w.transaction_temp_id  = m.transaction_temp_id
       AND w.status               = 4
       AND EXISTS
         ( SELECT 'x'
             FROM mtl_material_transactions_temp  m2
            WHERE m2.transfer_lpn_id      = m.transfer_lpn_id
              AND m2.organization_id      = m.organization_id
              AND m2.transaction_temp_id  = m2.parent_line_id
              AND m2.transaction_temp_id <> m.transaction_temp_id
              AND m2.transaction_temp_id <> p_temp_id
              AND m2.content_lpn_id       = m.transfer_lpn_id
         )
     UNION ALL
    -- Content LPNs
    SELECT m.transaction_temp_id
         , 2                      dummy_sort
      FROM wms_dispatched_tasks            w
         , mtl_material_transactions_temp  m
     WHERE m.transfer_lpn_id      = p_xfer_lpn_id
       AND m.transaction_temp_id <> p_temp_id
       AND m.transaction_temp_id  = m.parent_line_id
       AND w.transaction_temp_id  = m.transaction_temp_id
       AND w.status               = 4
       AND m.content_lpn_id      IS NOT NULL
     UNION ALL
    -- Material unpacked from content LPNs
    SELECT m.transaction_temp_id
         , 3                      dummy_sort
      FROM wms_dispatched_tasks            w
         , mtl_material_transactions_temp  m
     WHERE m.transfer_lpn_id      = p_xfer_lpn_id
       AND m.transaction_temp_id <> p_temp_id
       AND m.transaction_temp_id  = m.parent_line_id
       AND w.transaction_temp_id  = m.transaction_temp_id
       AND w.status               = 4
       AND EXISTS
         ( SELECT 'x'
             FROM mtl_material_transactions_temp  m2
            WHERE m2.transfer_lpn_id      = m.transfer_lpn_id
              AND m2.organization_id      = m.organization_id
              AND m2.transaction_temp_id  = m2.parent_line_id
              AND m2.transaction_temp_id <> m.transaction_temp_id
              AND m2.transaction_temp_id <> p_temp_id
              AND m2.content_lpn_id       = m.lpn_id
         )
     UNION ALL
    -- All other picked material
    SELECT m.transaction_temp_id
         , 4                      dummy_sort
      FROM wms_dispatched_tasks            w
         , mtl_material_transactions_temp  m
     WHERE m.transfer_lpn_id      = p_xfer_lpn_id
       AND m.transaction_temp_id <> p_temp_id
       AND m.transaction_temp_id  = m.parent_line_id
       AND w.transaction_temp_id  = m.transaction_temp_id
       AND w.status               = 4
       AND m.content_lpn_id      IS NULL
       AND ( (m.lpn_id           IS NOT NULL
              AND NOT EXISTS
                ( SELECT 'x'
                    FROM mtl_material_transactions_temp  m2
                   WHERE m2.transfer_lpn_id      = m.transfer_lpn_id
                     AND m2.organization_id      = m.organization_id
                     AND m2.transaction_temp_id  = m2.parent_line_id
                     AND m2.transaction_temp_id <> m.transaction_temp_id
                     AND m2.transaction_temp_id <> p_temp_id
                     AND m2.content_lpn_id       = m.lpn_id
                )
             )
             OR m.lpn_id         IS NULL
           )
       AND NOT EXISTS
           ( SELECT 'x'
             FROM mtl_material_transactions_temp  m3
            WHERE m3.transfer_lpn_id      = m.transfer_lpn_id
              AND m3.organization_id      = m.organization_id
              AND m3.transaction_temp_id  = m3.parent_line_id
              AND m3.transaction_temp_id <> m.transaction_temp_id
              AND m3.transaction_temp_id <> p_temp_id
              AND m3.content_lpn_id       = m.transfer_lpn_id
           )
     ORDER BY dummy_sort;


    l_debug           NUMBER  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_parent_deleted  BOOLEAN := FALSE;
    l_dum_sort        NUMBER;

  BEGIN

    IF l_debug = 1 THEN
       mydebug
       ( 'Entered with parameters: ' || g_newline          ||
         'p_txn_temp_id => '         || to_char(p_txn_temp_id)
       );
    END IF;

    print_version_info;

    x_return_status := fnd_api.g_ret_sts_success;
    x_next_temp_id  := NULL;

    SAVEPOINT unload_bulk_sp;

    BEGIN
      SELECT organization_id
           , inventory_item_id
           , content_lpn_id
           , transfer_lpn_id
        INTO l_org_id
           , l_item_id
           , l_content_lpn_id
           , l_transfer_lpn_id
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_txn_temp_id;

      IF (l_debug = 1) THEN
        mydebug('Org_id: '         || to_char(l_org_id)          ||
                ', item_id: '      || to_char(l_item_id)         ||
                ', content LPN: '  || to_char(l_content_lpn_id)  ||
                ', transfer LPN: ' || to_char(l_transfer_lpn_id)
               );
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug(' No data found in mtl_material_transactions_temp ');
        END IF;
    END;

    IF l_content_lpn_id IS NOT NULL THEN
       IF (l_debug = 1) THEN
          mydebug('Set lpn context to resides in INV for lpn_ID: ' ||
                   to_char(l_content_lpn_id)
                 );
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

    OPEN c_cncl_ovrpick_lines (p_txn_temp_id);
    LOOP
      FETCH c_cncl_ovrpick_lines
       INTO l_line_type
          , l_temp_id
          , l_quantity
          , l_txn_uom
          , l_mo_line_id
          , l_mo_line_uom;
      EXIT WHEN c_cncl_ovrpick_lines%NOTFOUND;

      IF (l_debug = 1) THEN
         mydebug('Deleting l_temp_id: ' || to_char(l_temp_id)    ||
                 ', l_quantity: '       || to_char(l_quantity)   ||
                 ', l_txn_uom: '        || l_txn_uom             ||
                 ', l_mo_line_id: '     || to_char(l_mo_line_id) ||
                 ', l_mo_line_uom: '    || l_mo_line_uom         ||
                 ', l_line_type: '      || l_line_type
                );
      END IF;

      l_return_status := fnd_api.g_ret_sts_success;

      IF l_line_type = 'CANCELLED'
      THEN
         inv_mo_cancel_pvt.reduce_rsv_allocation
         ( x_return_status       => l_return_status
         , x_msg_count           => l_msg_count
         , x_msg_data            => l_msg_data
         , p_transaction_temp_id => l_temp_id
         , p_quantity_to_delete  => l_quantity
         );
      ELSIF l_line_type = 'OVERPICKED'
      THEN
         inv_trx_util_pub.delete_transaction
         ( x_return_status       => l_return_status
         , x_msg_data            => l_msg_data
         , x_msg_count           => l_msg_count
         , p_transaction_temp_id => l_temp_id
         , p_update_parent       => TRUE
         );
      END IF;

      IF (l_return_status <> fnd_api.g_ret_sts_success)
      THEN
         IF (l_debug = 1) THEN
            mydebug('Error returned from API for deleting transaction');
            mydebug(l_msg_data);
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF l_mo_line_id IS NOT NULL
      THEN
         IF l_mo_line_uom <> l_txn_uom
         THEN
            l_conv_qty := inv_convert.inv_um_convert
                          ( item_id       => l_item_id
                          , PRECISION     => NULL
                          , from_quantity => l_quantity
                          , from_unit     => l_txn_uom
                          , to_unit       => l_mo_line_uom
                          , from_name     => NULL
                          , to_name       => NULL
                          );
         ELSE
            l_conv_qty := l_quantity;
         END IF;

         UPDATE mtl_txn_request_lines
            SET quantity_detailed = (quantity_detailed - l_conv_qty)
          WHERE line_id = l_mo_line_id;

         IF (l_debug = 1) THEN
            mydebug('Updated mol: ' || to_char(l_mo_line_id));
         END IF;

         SELECT COUNT(transaction_temp_id)
           INTO l_count
           FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.move_order_line_id = l_mo_line_id;

         IF (l_count = 0) THEN
            IF (l_debug = 1) THEN
               mydebug('No more allocations for mo line ' || to_char(l_mo_line_id));
            END IF;

           UPDATE mtl_txn_request_lines
              SET line_status = inv_globals.g_to_status_closed
            WHERE line_id = l_mo_line_id;
         ELSE
           IF (l_debug = 1) THEN
              mydebug('Allocations left: ' || to_char(l_count));
           END IF;
         END IF;
      END IF; -- end if move order line ID is not null
    END LOOP;

    --
    -- Proceed only if parent still exists
    --
    BEGIN
      SELECT msi.lot_control_code
           , msi.serial_number_control_code
           , mmtt.serial_allocated_flag
        INTO v_lot_control_code
           , v_serial_control_code
           , v_allocate_serial_flag
        FROM mtl_system_items                msi
           , mtl_material_transactions_temp  mmtt
       WHERE msi.inventory_item_id    = mmtt.inventory_item_id
         AND msi.organization_id      = mmtt.organization_id
         AND mmtt.transaction_temp_id = p_txn_temp_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
           mydebug('Parent MMTT deleted when cancelled child tasks were processed');
        END IF;
        l_parent_deleted := TRUE;

      WHEN OTHERS THEN
        RAISE;
    END;

    IF NOT l_parent_deleted THEN
       IF (l_debug = 1) THEN
          mydebug(' lot code ' || v_lot_control_code);
          mydebug(' ser_code ' || v_serial_control_code);
          mydebug(' alloc ser flag' || v_allocate_serial_flag);
       END IF;

       IF (v_allocate_serial_flag <> 'Y') THEN
          IF (l_debug = 1) THEN
             mydebug('Alloc serial flag is not y ');
          END IF;

          IF (v_lot_control_code = 1
             AND v_serial_control_code NOT IN(1, 6))
          THEN
             IF (l_debug = 1) THEN
                mydebug('Serial controlled only.');
             END IF;

             --
             -- Update group_mark_id for Serial controlled
             --
             OPEN c_fm_to_serial_number (p_txn_temp_id);
             LOOP
               FETCH c_fm_to_serial_number INTO l_fm_serial_number, l_to_serial_number;
               EXIT WHEN c_fm_to_serial_number%NOTFOUND;

               UPDATE mtl_serial_numbers
                  SET group_mark_id = NULL
                WHERE serial_number BETWEEN l_fm_serial_number AND l_to_serial_number
                  AND current_organization_id = l_org_id
                  AND inventory_item_id = l_item_id;

               IF (l_debug = 1) THEN
                  mydebug('Unmarked serials between ' || l_fm_serial_number ||
                          ' and '                     || l_to_serial_number ||
                          '.  Now deleting MSNT '     || to_char(p_txn_temp_id)
                         );
               END IF;
             END LOOP;

             CLOSE c_fm_to_serial_number;

             DELETE mtl_serial_numbers_temp
              WHERE transaction_temp_id = p_txn_temp_id;

          ELSIF(v_lot_control_code = 2
               AND v_serial_control_code NOT IN(1, 6))
          THEN
             /** Both lot and serial controlled **/
             IF (l_debug = 1) THEN
                mydebug('Lot and serial controlled ');
             END IF;

             OPEN c_lot_allocations (p_txn_temp_id);
             LOOP
               FETCH c_lot_allocations INTO l_serial_transaction_temp_id;
               EXIT WHEN c_lot_allocations%NOTFOUND;

               --
               -- Update group_mark_id for lot and serial controlled
               --
               OPEN c_fm_to_lot_serial_number (l_serial_transaction_temp_id);
               LOOP
                 FETCH c_fm_to_lot_serial_number INTO l_fm_serial_number, l_to_serial_number;
                 EXIT WHEN c_fm_to_lot_serial_number%NOTFOUND;

                 UPDATE mtl_serial_numbers
                    SET group_mark_id = NULL
                  WHERE serial_number BETWEEN l_fm_serial_number AND l_to_serial_number
                    AND current_organization_id = l_org_id
                    AND inventory_item_id = l_item_id;
               END LOOP;

               CLOSE c_fm_to_lot_serial_number;

               IF (l_debug = 1) THEN
                  mydebug('Unmarked serials between ' || l_fm_serial_number ||
                          ' and '                     || l_to_serial_number ||
                          '.  Now deleting MSNT '     || to_char(l_serial_transaction_temp_id)
                         );
               END IF;

               DELETE FROM mtl_serial_numbers_temp
                WHERE transaction_temp_id = l_serial_transaction_temp_id;
             END LOOP;
             CLOSE c_lot_allocations;

             UPDATE mtl_transaction_lots_temp
                SET serial_transaction_temp_id = NULL
              WHERE transaction_temp_id = p_txn_temp_id;

             IF (l_debug = 1) THEN
                mydebug('Updated MTLT');
             END IF;
          END IF; -- end if lot/serial controlled
       END IF; -- end if serial not allocated

       IF (l_debug = 1) THEN
          mydebug('deleting WDT with temp_id: ' || to_char(p_txn_temp_id));
       END IF;

       DELETE wms_dispatched_tasks
        WHERE transaction_temp_id = p_txn_temp_id;

       --
       -- The lpn ids must be set to null for this task
       -- for both parent and child records
       --
       UPDATE mtl_material_transactions_temp
          SET lpn_id          = NULL
            , content_lpn_id  = NULL
            , transfer_lpn_id = NULL
            , wms_task_status = 1 -- Bug4185621: update mmtt task status back to pending
        WHERE parent_line_id = p_txn_temp_id;

    END IF; -- end if parent not deleted

    l_count := 0;
    SELECT COUNT(*)
      INTO l_count
      FROM mtl_material_transactions_temp
     WHERE transfer_lpn_id = l_transfer_lpn_id;

    IF l_count = 0 THEN
       --
       -- no more rows and the current row is the
       -- last allocation
       --
       IF l_content_lpn_id IS NULL THEN
           BEGIN
	      SELECT lpn_context INTO l_lpn_context
		FROM wms_license_plate_numbers
		WHERE lpn_id = l_transfer_lpn_id;
	   EXCEPTION
	      WHEN no_data_found THEN
		 l_lpn_context := NULL;
	   END;

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
    ELSE
       OPEN c_next_temp_id (l_transfer_lpn_id, p_txn_temp_id);
       FETCH c_next_temp_id INTO x_next_temp_id, l_dum_sort;
       CLOSE c_next_temp_id;
    END IF;

    IF (l_debug = 1) THEN
       mydebug('Done with unload_bulk_task');
    END IF;

    --
    -- Explicit commit required
    --
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO unload_bulk_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
         mydebug('Exception unload_bulk_task: ' || sqlerrm);
      END IF;
  END unload_bulk_task;

END WMS_UNLOAD_UTILS_PVT;

/
