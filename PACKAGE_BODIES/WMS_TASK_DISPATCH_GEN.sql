--------------------------------------------------------
--  DDL for Package Body WMS_TASK_DISPATCH_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TASK_DISPATCH_GEN" AS
  /* $Header: WMSTASKB.pls 120.18.12010000.13 2011/10/19 12:28:31 abasheer ship $ */


  --  Global constant holding the package name

  g_pkg_name    CONSTANT VARCHAR2(30)  := 'WMS_Task_Dispatch_Gen';
  g_pkg_version CONSTANT VARCHAR2(100) := '$Header: WMSTASKB.pls 120.18.12010000.13 2011/10/19 12:28:31 abasheer ship $';

--Replenishment Project --6681109
  g_ordered_psr           wms_replenishment_pvt.psrTabTyp;

  PROCEDURE call_workflow(
    p_rsn_id          IN            NUMBER
  , p_calling_program IN            VARCHAR2
  , p_org_id          IN            NUMBER
  , p_tmp_id          IN            NUMBER DEFAULT NULL
  , p_quantity_picked IN            NUMBER DEFAULT NULL
  , p_dest_sub        IN            VARCHAR2 DEFAULT NULL
  , p_dest_loc        IN            NUMBER DEFAULT NULL
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
  , x_wf              OUT NOCOPY    NUMBER  ); -- Bug2924823 H to I

  -- If you need to make any changes in the spec of create_mo, then make
    -- changes both in wms_task_dispatch_put_away.create_mo and in
    -- wms_task_dispatch_gen.create_mo

  PROCEDURE create_mo(
    p_org_id                     IN            NUMBER
  , p_inventory_item_id          IN            NUMBER
  , p_qty                        IN            NUMBER
  , p_uom                        IN            VARCHAR2
  , p_lpn                        IN            NUMBER
  , p_project_id                 IN            NUMBER
  , p_task_id                    IN            NUMBER
  , p_reference                  IN            VARCHAR2
  , p_reference_type_code        IN            NUMBER
  , p_reference_id               IN            NUMBER
  , p_lot_number                 IN            VARCHAR2
  , p_revision                   IN            VARCHAR2
  , p_header_id                  IN OUT NOCOPY NUMBER
  , p_sub                        IN            VARCHAR
  , p_loc                        IN            NUMBER
  , x_line_id                    OUT NOCOPY    NUMBER
  , p_inspection_status          IN            NUMBER
  , p_txn_source_id              IN            NUMBER
  , p_transaction_type_id        IN            NUMBER
  , p_transaction_source_type_id IN            NUMBER
  , p_wms_process_flag           IN            NUMBER
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_count                  OUT NOCOPY    NUMBER
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  , p_from_cost_group_id         IN            NUMBER
  , p_transfer_org_id            IN            NUMBER
  ) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    wms_task_dispatch_put_away.create_mo(
      p_org_id                     => p_org_id
    , p_inventory_item_id          => p_inventory_item_id
    , p_qty                        => p_qty
    , p_uom                        => p_uom
    , p_lpn                        => p_lpn
    , p_project_id                 => p_project_id
    , p_task_id                    => p_task_id
    , p_reference                  => p_reference
    , p_reference_type_code        => p_reference_type_code
    , p_reference_id               => p_reference_id
    , p_lot_number                 => p_lot_number
    , p_revision                   => p_revision
    , p_header_id                  => p_header_id
    , p_sub                        => p_sub
    , p_loc                        => p_loc
    , x_line_id                    => x_line_id
    , p_inspection_status          => p_inspection_status
    , p_txn_source_id              => p_txn_source_id
    , p_transaction_type_id        => p_transaction_type_id
    , p_transaction_source_type_id => p_transaction_source_type_id
    , p_wms_process_flag           => p_wms_process_flag
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_from_cost_group_id         => p_from_cost_group_id
    , p_transfer_org_id            => p_transfer_org_id
    );
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        mydebug('create_mo: call to WMS_Task_Dispatch_put_away.create_mo failed');
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        mydebug('create_mo: call to WMS_Task_Dispatch_put_away.create_mo failed');
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_mo;

  PROCEDURE insert_task(
    p_org_id        IN            NUMBER
  , p_user_id       IN            NUMBER
  , p_eqp_ins       IN            VARCHAR2
  , p_temp_id       IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  ) IS
    l_org_id        NUMBER;
    l_temp_id       NUMBER;
    l_person_id     NUMBER;
    l_eqp_id        NUMBER;
    l_eqp_ins       VARCHAR2(30);
    l_per_res_id    NUMBER;
    l_mac_res_id    NUMBER;
    l_return_status VARCHAR2(1);
    l_task_id       NUMBER;
    l_debug         NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_return_status  := fnd_api.g_ret_sts_success;
    l_org_id         := p_org_id;
    l_temp_id        := p_temp_id;
    l_person_id      := p_user_id;
    l_eqp_id         := 1111;
    l_eqp_ins        := p_eqp_ins;
    l_per_res_id     := 1113;
    l_mac_res_id     := 1001;

    /*   SELECT resource_id INTO l_mac_res_id
         FROM bom_resource_equipments
         WHERE organization_id=l_org_id
         AND inventory_item_id=l_eqp_id;


       SELECT resource_id INTO l_per_res_id
         FROM bom_resource_employees
         WHERE organization_id=l_org_id
         AND person_id=l_emp_id;
    */
    SELECT wms_dispatched_tasks_s.NEXTVAL
      INTO l_task_id
      FROM DUAL;

    INSERT INTO wms_dispatched_tasks
                (
                 task_id
               , transaction_temp_id
               , organization_id
               , user_task_type
               , person_id
               , effective_start_date
               , effective_end_date
               , equipment_id
               , equipment_instance
               , person_resource_id
               , machine_resource_id
               , status
               , dispatched_time
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , task_type
               , priority
               , operation_plan_id
               , move_order_line_id
                )
      (SELECT l_task_id
            , transaction_temp_id
            , organization_id
            , NVL(standard_operation_id, 2)
            , l_person_id
            , SYSDATE
            , SYSDATE
            , l_eqp_id
            , l_eqp_ins
            , l_per_res_id
            , l_mac_res_id
            , 4
            , SYSDATE
            , SYSDATE
            , l_person_id
            , SYSDATE
            , l_person_id
            , NVL(wms_task_type, 1)
            , task_priority
            , operation_plan_id
            , move_order_line_id
         FROM mtl_material_transactions_temp
        WHERE transaction_temp_id = l_temp_id);

    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('WMS', 'WMS_TD_INSERT_TASK');
      fnd_msg_pub.ADD;
  END insert_task;

  PROCEDURE next_task(
    p_sign_on_emp_id        IN            NUMBER
  , p_sign_on_org_id        IN            NUMBER
  , p_sign_on_zone          IN            VARCHAR2
  , p_sign_on_equipment_id  IN            NUMBER
  , p_sign_on_equipment_srl IN            VARCHAR2
  , p_task_type             IN            VARCHAR2
  , x_nbr_tasks             OUT NOCOPY    NUMBER
  , p_lpn_id                IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_task_type             OUT NOCOPY    NUMBER
  , p_sign_on_device_id     IN            NUMBER := NULL
  , x_avail_device_id       OUT NOCOPY    NUMBER
  ) IS
    l_cartonization_id   NUMBER                                := NULL;
    task_rec             wms_task_dispatch_gen.task_rec_tp;
    l_task_cur           wms_task_dispatch_gen.task_rec_cur_tp;
    l_user_id            NUMBER;
    l_emp_id             NUMBER;
    l_org_id             NUMBER;
    l_zone               VARCHAR2(10);
    l_eqp_id             NUMBER;
    l_eqp_ins            VARCHAR2(30);
    l_task_type          VARCHAR2(30);
    l_c_rows             NUMBER;
    l_next_task_id       NUMBER;
    l_per_res_id         NUMBER;
    l_mac_res_id         NUMBER;
    l_std_op_id          NUMBER;
    l_move_order_line_id NUMBER;
    l_operation_plan_id  NUMBER;
    l_priority           NUMBER;
    l_wms_task_type      NUMBER;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_return_status      VARCHAR2(1);
    l_request_msg        VARCHAR2(200);
    l_lpn_id             NUMBER;
    l_tsks               NUMBER;
    l_device_id          NUMBER                                := NULL;
    l_temp_device_id     NUMBER                                := NULL;
    l_assignment_temp_id NUMBER;
    l_avail_device_id    NUMBER                                := NULL;
    l_need_dispatch      BOOLEAN                               := TRUE;
    l_task_type_n        NUMBER;
    l_task_id            NUMBER;
    l_device_invoked     VARCHAR2(1);
    l_invoked_device_id  NUMBER;
    l_first_task         BOOLEAN;
    l_period_id          NUMBER;
    l_open_past_period   BOOLEAN;
    l_request_id         NUMBER                                := NULL;

    CURSOR following_device_list(p_emp_id NUMBER, p_current_device_temp_id NUMBER) IS
      SELECT   wdat.device_id
             , wdat.assignment_temp_id
             , wdb.subinventory_code
          FROM wms_device_assignment_temp wdat, wms_devices_b wdb
         WHERE wdat.assignment_temp_id >= p_current_device_temp_id
           AND wdat.employee_id = p_emp_id
           AND wdat.device_id = wdb.device_id
      ORDER BY wdat.assignment_temp_id;

    CURSOR front_device_list(p_emp_id NUMBER, p_current_device_temp_id NUMBER) IS
      SELECT   wdat.device_id
             , wdat.assignment_temp_id
             , wdb.subinventory_code
          FROM wms_device_assignment_temp wdat, wms_devices_b wdb
         WHERE wdat.assignment_temp_id < p_current_device_temp_id
           AND wdat.employee_id = p_emp_id
           AND wdat.device_id = wdb.device_id
      ORDER BY wdat.assignment_temp_id;

    l_txn_hdr_id         NUMBER;
    l_debug              NUMBER                                := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('In next task:');
    END IF;

    SAVEPOINT sp_td_gen_next_task;
    l_return_status  := fnd_api.g_ret_sts_success;
    l_user_id        := p_sign_on_emp_id;
    l_org_id         := p_sign_on_org_id;
    l_zone           := p_sign_on_zone;
    l_eqp_id         := p_sign_on_equipment_id;
    l_eqp_ins        := p_sign_on_equipment_srl;
    l_task_type      := p_task_type;
    l_c_rows         := 0;
    l_next_task_id   := 0;
    -- l_per_res_id:=111;
    -- l_mac_res_id:=111;
    l_std_op_id      := 1;
    l_priority       := 1;
    l_wms_task_type  := 1;
    l_lpn_id         := p_lpn_id;
    l_device_id      := p_sign_on_device_id;

    IF l_device_id = 0 THEN
      l_device_id  := NULL;
    END IF;

    l_emp_id         := l_user_id;
    l_tsks           := 0;
    x_task_type      := 0;

    IF (l_debug = 1) THEN
      mydebug('next_task : Need to check if the period is open');
    END IF;

    invttmtx.tdatechk(org_id => l_org_id, transaction_date => SYSDATE, period_id => l_period_id, open_past_period => l_open_past_period);

    IF l_period_id = -1 THEN
      IF (l_debug = 1) THEN
        mydebug('next_task: Period is invalid');
      END IF;

      fnd_message.set_name('INV', 'INV_NO_OPEN_PERIOD');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('next_task: Check to see if there are tasks in wms_disp_tasks already..');
    END IF;

    /* 3189172 */

    IF l_task_type = 'EXPPICK' THEN
      SELECT COUNT(*) tsk
        INTO l_tsks
        FROM wms_dispatched_tasks wdt
       WHERE wdt.person_id = l_user_id
         AND wdt.organization_id = l_org_id
         AND wdt.task_type IN(1, 3, 4, 5, 6)
         AND wms_express_pick_task.is_express_pick_task(task_id) = 'S'
         AND wdt.status <= 3
   AND    ((wdt.task_type = 3
            AND exists
             (SELECT NVL(cycle_count_entry_id,-1)
              --Bug 3808770- Added the table mtl_cycle_count_headers in the from clause
              FROM   mtl_cycle_count_entries mcce,mtl_cycle_count_headers mcch
              WHERE  mcce.cycle_count_entry_id = wdt.transaction_temp_id
         AND    mcce.organization_id = wdt.organization_id
         AND    mcce.subinventory  = nvl(p_sign_on_zone,mcce.subinventory) --Added bug3771517
         AND    mcce.entry_status_code in (1,3)
         --Bug 3808770 Added the following conditions to select only those tasks whose cycle count is not disabled.
         AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                   AND NVL(mcch.disable_date,sysdate+1)> sysdate
         --End of fix for Bug 3808770
         )
            )
      OR (wdt.task_type IN (1, 4, 5, 6)
          AND EXISTS
          (SELECT Nvl(mmtt.transaction_temp_id, -1)
           FROM   mtl_material_transactions_temp mmtt
           WHERE  mmtt.transaction_temp_id = wdt.transaction_temp_id
           AND    mmtt.subinventory_code  = nvl(p_sign_on_zone,mmtt.subinventory_code) --Added bug3771517
           AND    mmtt.organization_id = wdt.organization_id))
           );

      ELSE

      SELECT count(*) TSK
   INTO   l_tsks
   FROM   wms_dispatched_tasks wdt
   WHERE  wdt.person_id = l_user_id
   AND    wdt.organization_id = l_org_id
   AND    wdt.task_type IN (1, 3, 4, 5, 6)
   AND    wdt.status <= 3
   AND    ((wdt.task_type = 3
            AND exists
        (SELECT NVL(cycle_count_entry_id,-1)
         FROM   mtl_cycle_count_entries mcce ,mtl_cycle_count_headers mcch
         WHERE  mcce.cycle_count_entry_id = wdt.transaction_temp_id
         AND    mcce.subinventory  = nvl(p_sign_on_zone,mcce.subinventory) --Added bug3771517
         AND    mcce.organization_id = wdt.organization_id
         and    mcce.entry_status_code in (1,3)
         --Bug 3808770 Added the following conditions to select only those tasks whose cycle count is not disabled.
           AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
           AND NVL(mcch.disable_date,sysdate+1)> sysdate
         --End of fix for Bug 3808770
        )
            )
      OR (wdt.task_type IN (1, 4, 5, 6)
          AND EXISTS
          (SELECT Nvl(mmtt.transaction_temp_id, -1)
           FROM   mtl_material_transactions_temp mmtt
           WHERE  mmtt.transaction_temp_id = wdt.transaction_temp_id
           AND    mmtt.subinventory_code  = nvl(p_sign_on_zone,mmtt.subinventory_code) --Added bug3771517
           AND    mmtt.organization_id = wdt.organization_id))
           );

    END IF;

    IF (l_debug = 1) THEN
      mydebug('next_task: l_device_id: ' || l_device_id);
    END IF;

    IF l_tsks <> 0
       AND l_device_id IS NULL THEN
      IF (l_debug = 1) THEN
        mydebug('next_task: There are tasks in wms_disp_tasks already');
      END IF;

      l_c_rows         := -999;
      x_return_status  := fnd_api.g_ret_sts_success;

      -- Also set the task type value even if tasks have
      -- already been dispatched
      IF l_task_type = 'EXPPICK' THEN
       SELECT wt.task_type
       INTO   x_task_type
       FROM   (SELECT wdt.task_type
           , wdt.priority
                     , wdt.task_id       task_id
                     , sub.picking_order sub_picking_order
                     , loc.picking_order loc_picking_order
                FROM mtl_material_transactions_temp mmtt, wms_dispatched_tasks wdt, mtl_item_locations loc, mtl_secondary_inventories sub
                WHERE wdt.person_id = l_user_id
                  AND wdt.organization_id = l_org_id
                  AND wdt.status <= 3
                  AND wdt.task_type IN (1, 4, 5, 6)
                  AND WMS_EXPRESS_PICK_TASK.IS_EXPRESS_PICK_TASK(wdt.TASK_ID) = 'S'
                  AND wdt.transaction_temp_id = mmtt.transaction_temp_id
        AND mmtt.subinventory_code  = nvl(p_sign_on_zone,mmtt.subinventory_code) --Added bug3771517
                  AND sub.organization_id = mmtt.organization_id
                  AND sub.secondary_inventory_name = mmtt.subinventory_code
                  AND loc.organization_id = mmtt.organization_id
                  AND loc.inventory_location_id = mmtt.locator_id
      UNION
                SELECT wdt.task_type
           , wdt.priority
                     , wdt.task_id       task_id
                     , sub.picking_order sub_picking_order
                     , loc.picking_order loc_picking_order
                --Bug 3808770 -Added the table mtl_cycle_count_headers in the FROM clause
                FROM mtl_cycle_count_entries mcce, wms_dispatched_tasks wdt, mtl_item_locations loc, mtl_secondary_inventories sub
                     ,mtl_cycle_count_headers mcch
                WHERE wdt.person_id = l_user_id
                  AND wdt.organization_id = l_org_id
                  AND wdt.status <= 3
                  AND wdt.task_type = 3
                  AND WMS_EXPRESS_PICK_TASK.IS_EXPRESS_PICK_TASK(wdt.TASK_ID) = 'S'
                  AND wdt.transaction_temp_id = mcce.cycle_count_entry_id
                  AND sub.organization_id = mcce.organization_id
        AND mcce.subinventory  = nvl(p_sign_on_zone,mcce.subinventory) --Added bug3771517
                  AND sub.secondary_inventory_name = mcce.subinventory
                  AND loc.organization_id = mcce.organization_id
                  AND loc.inventory_location_id = mcce.locator_id
                  --Bug 3808770 Added the following conditions to select only those tasks whose cycle count is not disabled.
        AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
        AND NVL(mcch.disable_date,sysdate+1)> sysdate ) wt
        --End of fix for Bug 3808770
         WHERE ROWNUM = 1
         order by wt.priority,wt.sub_picking_order, wt.loc_picking_order, wt.task_id ;

     ELSE
       SELECT wt.task_type
       INTO   x_task_type
       FROM   (SELECT wdt.task_type
           , wdt.priority
                     , wdt.task_id       task_id
                     , sub.picking_order sub_picking_order
                     , loc.picking_order loc_picking_order
                FROM mtl_material_transactions_temp mmtt, wms_dispatched_tasks wdt, mtl_item_locations loc, mtl_secondary_inventories sub
                WHERE wdt.person_id = l_user_id
                  AND wdt.organization_id = l_org_id
                  AND wdt.status <= 3
                  AND wdt.task_type IN (1, 4, 5, 6)
                  AND wdt.transaction_temp_id = mmtt.transaction_temp_id
                  AND sub.organization_id = mmtt.organization_id
                  AND sub.secondary_inventory_name = mmtt.subinventory_code
        AND mmtt.subinventory_code  = nvl(p_sign_on_zone,mmtt.subinventory_code) --Added bug3771517
                  AND loc.organization_id = mmtt.organization_id
                  AND loc.inventory_location_id = mmtt.locator_id
      UNION
                SELECT wdt.task_type
           , wdt.priority
                     , wdt.task_id       task_id
                     , sub.picking_order sub_picking_order
                     , loc.picking_order loc_picking_order
                --Bug 3808770 -Added the table mtl_cycle_count_headers in the FROM clause
                FROM mtl_cycle_count_entries mcce, wms_dispatched_tasks wdt, mtl_item_locations loc, mtl_secondary_inventories sub
                   , mtl_cycle_count_headers mcch
                WHERE wdt.person_id = l_user_id
                  AND wdt.organization_id = l_org_id
                  AND wdt.status <= 3
                  AND wdt.task_type = 3
                  AND wdt.transaction_temp_id = mcce.cycle_count_entry_id
                  AND sub.organization_id = mcce.organization_id
        AND mcce.subinventory  = nvl(p_sign_on_zone,mcce.subinventory) --Added bug3771517
                  AND sub.secondary_inventory_name = mcce.subinventory
                  AND loc.organization_id = mcce.organization_id
                  AND loc.inventory_location_id = mcce.locator_id
                 --Bug 3808770 Added the following conditions to select only those tasks whose cycle count is not disabled.
        AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
        AND NVL(mcch.disable_date,sysdate+1)> sysdate )wt
        --End of fix for Bug 3808770
         WHERE ROWNUM = 1
         order by wt.priority,wt.sub_picking_order, wt.loc_picking_order, wt.task_id;

      END IF;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('next_task: There are no tasks in wms_disp_tasks or device signed on');
      END IF;

      -- SELECT employee_id INTO l_emp_id FROM fnd_user WHERE user_id=l_user_id;

      IF l_eqp_id = -999 THEN
        l_eqp_id  := NULL;
      END IF;

      IF l_lpn_id = 0 THEN
        l_lpn_id  := NULL;
      END IF;

      IF l_device_id IS NOT NULL THEN
        SELECT wdat.assignment_temp_id
             , wd.subinventory_code
          INTO l_assignment_temp_id
             , l_zone
          FROM wms_device_assignment_temp wdat, wms_devices_vl wd
         WHERE wdat.device_id = l_device_id
           AND wdat.device_id = wd.device_id
           AND employee_id = l_emp_id;
      END IF;

      --IF l_eqp_id IS NOT NULL THEN
      --SELECT resource_id INTO l_mac_res_id
      --FROM bom_resource_equipments
      --WHERE organization_id=l_org_id
      --AND inventory_item_id=l_eqp_id;
      --END IF;

      --SELECT resource_id INTO l_per_res_id
      --FROM bom_resource_employees
      --WHERE organization_id=l_org_id
      --AND person_id=l_emp_id;

      IF (l_debug = 1) THEN
        mydebug('next_task: TaskType' || l_task_type);
      END IF;

      IF l_lpn_id = fnd_api.g_miss_num THEN
        l_lpn_id  := NULL;
      END IF;

      IF (l_device_id IS NOT NULL) THEN
        OPEN following_device_list(l_emp_id, l_assignment_temp_id);
        OPEN front_device_list(l_emp_id, l_assignment_temp_id);
      END IF;

      LOOP
        IF l_device_id IS NOT NULL THEN

          <<search_device_loop>>
          LOOP -- loop to find the available task and check if we need to dispatch task to some devices
            FETCH following_device_list INTO l_temp_device_id, l_assignment_temp_id, l_zone;

            IF (following_device_list%NOTFOUND) THEN
              FETCH front_device_list INTO l_temp_device_id, l_assignment_temp_id, l_zone;

              IF (front_device_list%NOTFOUND) THEN
                CLOSE following_device_list;
                CLOSE front_device_list;
                l_need_dispatch  := FALSE;
                EXIT search_device_loop;
              END IF;
            END IF;

            BEGIN
              SELECT   transaction_temp_id
                     , task_type
                     , device_invoked
                  INTO l_task_id
                     , l_task_type_n
                     , l_device_invoked
                  FROM wms_dispatched_tasks
                 WHERE person_id = l_user_id
                   AND organization_id = l_org_id
                   AND device_id = l_temp_device_id
                   AND task_type IN(1, 3, 4, 5, 6)
                   AND status <= 3
                   AND ROWNUM = 1
              ORDER BY 1;

              IF (l_device_invoked = 'Y'
                  AND l_avail_device_id IS NULL) THEN
                l_avail_device_id  := l_temp_device_id;
                x_task_type        := l_task_type_n;
              ELSIF l_device_invoked = 'N' THEN
                wms_device_integration_pvt.device_request(
                  p_bus_event                  => wms_device_integration_pvt.wms_be_pick_load
                , p_call_ctx                   => wms_device_integration_pvt.dev_req_auto
                , p_task_trx_id                => l_task_id
                , p_org_id                     => l_org_id
                , x_request_msg                => l_request_msg
                , x_return_status              => l_return_status
                , x_msg_count                  => l_msg_count
                , x_msg_data                   => l_msg_data
                , p_request_id                 => l_request_id
                );

                -- always dispatch the task whether invoking device successfully or not
                -- So update the table always

                UPDATE wms_dispatched_tasks
                   SET device_invoked = 'Y'
                     , device_request_id = l_request_id
                 WHERE transaction_temp_id = l_task_id;

                IF l_invoked_device_id IS NULL THEN
                  l_invoked_device_id  := l_temp_device_id;
                END IF;

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  IF (l_debug = 1) THEN
                    mydebug('next_task:failed to invoke device ' || TO_CHAR(l_temp_device_id));
                  END IF;
                END IF;
              END IF;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_need_dispatch  := TRUE;
                EXIT search_device_loop;
            END;
          END LOOP;
        END IF;

        EXIT WHEN l_need_dispatch = FALSE;

        IF (l_debug = 1) THEN
          mydebug('next_task: Before Calling TD Engine');
        END IF;

   if (l_eqp_id is null and l_eqp_ins is null) then
      IF (l_debug = 1) THEN
         mydebug('l_eqp_id is null and l_eqp_ins is null');
      end if;
      l_eqp_ins := 'NONE';
   end if;

   IF (l_debug = 1) THEN
      mydebug('l_eqp_id='||l_eqp_id);
      mydebug('l_eqp_ins='||l_eqp_ins);
   end if;

        wms_task_dispatch_engine.dispatch_task(
          p_api_version                => 1.0
        , p_init_msg_list              => 'F'
        , p_commit                     => NULL
        , p_sign_on_emp_id             => l_emp_id
        , p_sign_on_org_id             => l_org_id
        , p_sign_on_zone               => l_zone
        , p_sign_on_equipment_id       => l_eqp_id
        , p_sign_on_equipment_srl      => l_eqp_ins
        , p_task_type                  => l_task_type
        , x_task_cur                   => l_task_cur
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_cartonization_id           => l_lpn_id
        );

        IF (l_debug = 1) THEN
          mydebug('next_task: Ret Status' || l_return_status);
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_success THEN
          IF (l_debug = 1) THEN
            mydebug('in here');
          END IF;

          l_first_task  := TRUE;

          LOOP
            FETCH l_task_cur INTO task_rec;

            IF (l_debug = 1) THEN
              mydebug('before l_task_cur');
            END IF;

            EXIT WHEN l_task_cur%NOTFOUND;
            l_c_rows  := l_c_rows + 1;

            IF (l_debug = 1) THEN
              mydebug('next_task: TaskID:' || task_rec.task_id);
            END IF;

            IF (l_debug = 1) THEN
              mydebug('next_task: getting Resource ID....');
            END IF;

            IF (task_rec.task_type <> 3) THEN
              -- Picking, Putaway, or Replenishment task
              SELECT bremp.resource_id role_id
                   , t.wms_task_type
                   , t.standard_operation_id
                   , t.operation_plan_id
                   , t.move_order_line_id
                INTO l_per_res_id
                   , l_wms_task_type
                   , l_std_op_id
                   , l_operation_plan_id
                   , l_move_order_line_id
                FROM mtl_material_transactions_temp t, bom_std_op_resources bsor, bom_resources bremp
               WHERE t.transaction_temp_id = task_rec.task_id
                 AND t.standard_operation_id = bsor.standard_operation_id
                 AND bsor.resource_id = bremp.resource_id
                 AND bremp.resource_type = 2
                 AND ROWNUM < 2;
            ELSE
              -- Cycle counting task
              SELECT bremp.resource_id role_id
                   , 3
                   , mcce.standard_operation_id
                INTO l_per_res_id
                   , l_wms_task_type
                   , l_std_op_id
                --Bug 3808770- Added the table mtl_cycle_count_headers in the FROM clause
                FROM mtl_cycle_count_entries mcce, bom_std_op_resources bsor, bom_resources bremp,mtl_cycle_count_headers mcch
               WHERE mcce.cycle_count_entry_id = task_rec.task_id
                 AND mcce.standard_operation_id = bsor.standard_operation_id
                 AND bsor.resource_id = bremp.resource_id
                 AND bremp.resource_type = 2
                 AND ROWNUM < 2
                 AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                 AND NVL(mcch.disable_date,sysdate+1)> sysdate;
            END IF;

            IF (l_debug = 1) THEN
              mydebug('next_task: After getting Resource ID....');
            END IF;

            IF l_eqp_id IS NOT NULL THEN
              -- bug fix 1772907, lezhang

              SELECT resource_id
                INTO l_mac_res_id
                FROM bom_resource_equipments
               WHERE inventory_item_id = l_eqp_id
                 AND ROWNUM < 2;
            --select  breqp.resource_id equip_type_id
            --INTO l_mac_res_id
            --from mtl_material_transactions_temp t,
            --bom_std_op_resources bsor,
            --bom_resources breqp
            --where t.transaction_temp_id = task_rec.task_id
            --and t.standard_operation_id = bsor.standard_operation_id
            --and bsor.resource_id = breqp.resource_id
            --and breqp.resource_type = 1
            --and rownum<2;

            END IF;

            SELECT mtl_material_transactions_s.NEXTVAL txnhdrid
              INTO l_txn_hdr_id
              FROM DUAL;

            UPDATE mtl_material_transactions_temp
               SET transaction_header_id = l_txn_hdr_id
             WHERE transaction_temp_id = task_rec.task_id;

            -- Insert into WMS_DISPATCHED_TASKS for this user

            SELECT wms_dispatched_tasks_s.NEXTVAL
              INTO l_next_task_id
              FROM DUAL;

            INSERT INTO wms_dispatched_tasks
                        (
                         task_id
                       , transaction_temp_id
                       , organization_id
                       , user_task_type
                       , person_id
                       , effective_start_date
                       , effective_end_date
                       , equipment_id
                       , equipment_instance
                       , person_resource_id
                       , machine_resource_id
                       , status
                       , dispatched_time
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , task_type
                       , priority
                       , operation_plan_id
                       , move_order_line_id
                        )
                 VALUES (
                         l_next_task_id
                       , task_rec.task_id
                       , l_org_id
                       , NVL(l_std_op_id, 2)
                       , l_user_id
                       , SYSDATE
                       , SYSDATE
                       , l_eqp_id
                       , l_eqp_ins
                       , l_per_res_id
                       , l_mac_res_id
                       , 3
                       , SYSDATE
                       , SYSDATE
                       , l_emp_id
                       , SYSDATE
                       , l_emp_id
                       , l_wms_task_type
                       , task_rec.task_priority
                       , l_operation_plan_id
                       , l_move_order_line_id
                        );

            IF (l_debug = 1) THEN
              mydebug('next_task: After Insert into WMSDT');
            END IF;

            -- If LPN has been provided, exit, since we only want the first
            --task
            IF l_lpn_id IS NULL
               OR l_lpn_id = fnd_api.g_miss_num THEN
              IF (l_debug = 1) THEN
                mydebug('next_task: LPN was not provided');
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('next_task: LPN was provided - pick by label');
              END IF;

              EXIT;
            END IF;

            IF l_temp_device_id IS NOT NULL THEN
              IF (l_debug = 1) THEN
                mydebug('next_task: temp_device_id');
              END IF;

              UPDATE wms_dispatched_tasks
                 SET device_id = l_temp_device_id
                   , device_invoked = 'N'
               WHERE task_id = l_next_task_id;

              IF l_first_task THEN -- invoke the device
                wms_device_integration_pvt.device_request(
                  p_bus_event                  => wms_device_integration_pvt.wms_be_pick_load
                , p_call_ctx                   => wms_device_integration_pvt.dev_req_auto
                , p_task_trx_id                => task_rec.task_id
                , p_org_id                     => l_org_id
                , x_request_msg                => l_request_msg
                , x_return_status              => l_return_status
                , x_msg_count                  => l_msg_count
                , x_msg_data                   => l_msg_data
                , p_request_id                 => l_request_id
                );

                -- always dispatch the task whether invoking device successfully or not
                -- So update the table always


                UPDATE wms_dispatched_tasks
                   SET device_invoked = 'Y'
                     , device_request_id = l_request_id
                 WHERE task_id = l_next_task_id;

                IF l_invoked_device_id IS NULL THEN
                  l_invoked_device_id  := l_temp_device_id;
                END IF;

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  IF (l_debug = 1) THEN
                    mydebug('next_task:failed to invoke device ' || TO_CHAR(l_temp_device_id));
                  END IF;
                END IF;

                l_first_task  := FALSE;
              END IF;
            END IF;
          END LOOP;

          --********************
          DELETE FROM wms_skip_task_exceptions
                WHERE task_id = task_rec.task_id
                  AND task_id IN(
                       SELECT wste.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ABS((SYSDATE - wste.creation_date) * 24 * 60) > mp.skip_task_waiting_minutes
                          AND wste.task_id = task_rec.task_id
                          AND wste.organization_id = mp.organization_id);

          --************************

          -- Set the output task type parameter equals to the last
          -- task type returned since they should all be of the same type
          x_task_type   := l_wms_task_type;

          -- Committing these tasks to this user
          IF (l_debug = 1) THEN
            mydebug('before commiting');
          END IF;

          COMMIT;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          fnd_message.set_name('WMS', 'WMS_TD_TDENG_ERROR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            mydebug('next_task: Setting status to S');
          END IF;

          l_return_status  := fnd_api.g_ret_sts_success;
        -- l_c_rows:=0;
        END IF;

        IF l_device_id IS NULL THEN
          l_need_dispatch  := FALSE;
        END IF;
      END LOOP; -- end loop of the devices

      IF l_avail_device_id IS NOT NULL THEN
        x_avail_device_id  := l_avail_device_id;
        l_c_rows           := 1; -- to indicate there are tasks already
      ELSIF l_invoked_device_id IS NOT NULL THEN
        x_avail_device_id  := l_invoked_device_id;
        l_c_rows           := 1; -- to indicate there are tasks already

        SELECT task_type
          INTO x_task_type
          FROM wms_dispatched_tasks
         WHERE device_id = x_avail_device_id
           AND device_invoked = 'Y'
           AND person_id = l_user_id
           AND status <= 3
           AND task_type IN(1, 3, 4, 5, 6);
      ELSIF l_device_id IS NOT NULL THEN
        l_c_rows  := 0;
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('next_tasks: number of tasks: ' || l_c_rows);
      mydebug('next_task: done with API');
    END IF;

    x_nbr_tasks      := l_c_rows;
    x_return_status  := fnd_api.g_ret_sts_success;
    COMMIT;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO sp_td_gen_next_task;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO sp_td_gen_next_task;
  END next_task;

  -- Cluster Picking Enhancments.
  -- This procedure will call task dispatching for Cluster Pick
  PROCEDURE next_cluster_pick_task(
    p_sign_on_emp_id        IN            NUMBER
  , p_sign_on_org_id        IN            NUMBER
  , p_sign_on_zone          IN            VARCHAR2
  , p_sign_on_equipment_id  IN            NUMBER
  , p_sign_on_equipment_srl IN            VARCHAR2
  , p_task_type             IN            VARCHAR2
  , x_nbr_tasks             OUT NOCOPY    NUMBER
  , p_lpn_id                IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_task_type             OUT NOCOPY    NUMBER
  , p_sign_on_device_id     IN            NUMBER
  , x_avail_device_id       OUT NOCOPY    NUMBER
  , p_max_clusters          IN            NUMBER
  , x_deliveries_list       OUT NOCOPY    VARCHAR2
  , x_cartons_list          OUT NOCOPY    VARCHAR2
  ) IS
    l_cartonization_id   NUMBER                                := NULL;
    task_rec             wms_task_dispatch_gen.task_rec_tp;
    l_task_cur           wms_task_dispatch_gen.task_rec_cur_tp;
    l_user_id            NUMBER;
    l_emp_id             NUMBER;
    l_org_id             NUMBER;
    l_zone               VARCHAR2(10);
    l_eqp_id             NUMBER;
    l_eqp_ins            VARCHAR2(30);
    l_task_type          VARCHAR2(30);
    l_c_rows             NUMBER;
    l_next_task_id       NUMBER;
    l_per_res_id         NUMBER;
    l_mac_res_id         NUMBER;
    l_std_op_id          NUMBER;
    l_move_order_line_id NUMBER;
    l_operation_plan_id  NUMBER;
    l_priority           NUMBER;
    l_wms_task_type      NUMBER;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_return_status      VARCHAR2(1);
    l_request_msg        VARCHAR2(200);
    l_lpn_id             NUMBER;
    l_tsks               NUMBER;
    l_device_id          NUMBER                                := NULL;
    l_temp_device_id     NUMBER                                := NULL;
    l_assignment_temp_id NUMBER;
    l_avail_device_id    NUMBER                                := NULL;
    l_need_dispatch      BOOLEAN                               := TRUE;
    l_task_type_n        NUMBER;
    l_task_id            NUMBER;
    l_device_invoked     VARCHAR2(1);
    l_invoked_device_id  NUMBER;
    l_first_task         BOOLEAN;
    l_period_id          NUMBER;
    l_open_past_period   BOOLEAN;
    l_request_id         NUMBER                                := NULL;

    CURSOR following_device_list(p_emp_id NUMBER, p_current_device_temp_id NUMBER) IS
      SELECT   wdat.device_id
             , wdat.assignment_temp_id
             , wdb.subinventory_code
          FROM wms_device_assignment_temp wdat, wms_devices_b wdb
         WHERE wdat.assignment_temp_id >= p_current_device_temp_id
           AND wdat.employee_id = p_emp_id
           AND wdat.device_id = wdb.device_id
      ORDER BY wdat.assignment_temp_id;

    CURSOR front_device_list(p_emp_id NUMBER, p_current_device_temp_id NUMBER) IS
      SELECT   wdat.device_id
             , wdat.assignment_temp_id
             , wdb.subinventory_code
          FROM wms_device_assignment_temp wdat, wms_devices_b wdb
         WHERE wdat.assignment_temp_id < p_current_device_temp_id
           AND wdat.employee_id = p_emp_id
           AND wdat.device_id = wdb.device_id
      ORDER BY wdat.assignment_temp_id;

    l_txn_hdr_id         NUMBER;
    l_debug              NUMBER                                := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('In next task:');
    END IF;

    SAVEPOINT sp_td_gen_next_cp_task;
    l_return_status  := fnd_api.g_ret_sts_success;
    l_user_id        := p_sign_on_emp_id;
    l_org_id         := p_sign_on_org_id;
    l_zone           := p_sign_on_zone;
    l_eqp_id         := p_sign_on_equipment_id;
    l_eqp_ins        := p_sign_on_equipment_srl;
    l_task_type      := p_task_type;
    l_c_rows         := 0;
    l_next_task_id   := 0;
    -- l_per_res_id:=111;
    -- l_mac_res_id:=111;
    l_std_op_id      := 1;
    l_priority       := 1;
    l_wms_task_type  := 1;
    l_lpn_id         := p_lpn_id;
    l_device_id      := p_sign_on_device_id;

    IF l_device_id = 0 THEN
      l_device_id  := NULL;
    END IF;

    l_emp_id         := l_user_id;
    l_tsks           := 0;
    x_task_type      := 0;

    IF (l_debug = 1) THEN
      mydebug('next_CP_task : Need to check if the period is open');
    END IF;

    invttmtx.tdatechk(org_id => l_org_id, transaction_date => SYSDATE, period_id => l_period_id, open_past_period => l_open_past_period);

    IF l_period_id = -1 THEN
      IF (l_debug = 1) THEN
        mydebug('next_CP_task: Period is invalid');
      END IF;

      fnd_message.set_name('INV', 'INV_NO_OPEN_PERIOD');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('next_CP_task: done with open period check');
    END IF;

    IF l_eqp_id = -999 THEN
      l_eqp_id  := NULL;
    END IF;

    IF l_lpn_id = 0 THEN
      l_lpn_id  := NULL;
    END IF;

    IF l_device_id IS NOT NULL THEN
      SELECT wdat.assignment_temp_id
           , wd.subinventory_code
        INTO l_assignment_temp_id
           , l_zone
        FROM wms_device_assignment_temp wdat, wms_devices_vl wd
       WHERE wdat.device_id = l_device_id
         AND wdat.device_id = wd.device_id
         AND employee_id = l_emp_id;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('next_CP_task: TaskType' || l_task_type);
    END IF;

    IF l_lpn_id = fnd_api.g_miss_num THEN
      l_lpn_id  := NULL;
    END IF;

    IF (l_device_id IS NOT NULL) THEN
      OPEN following_device_list(l_emp_id, l_assignment_temp_id);
      OPEN front_device_list(l_emp_id, l_assignment_temp_id);
    END IF;

    LOOP
      IF l_device_id IS NOT NULL THEN

        <<search_device_loop>>
        LOOP -- loop to find the available task and check if we need to dispatch task to some devices
          FETCH following_device_list INTO l_temp_device_id, l_assignment_temp_id, l_zone;

          IF (following_device_list%NOTFOUND) THEN
            FETCH front_device_list INTO l_temp_device_id, l_assignment_temp_id, l_zone;

            IF (front_device_list%NOTFOUND) THEN
              CLOSE following_device_list;
              CLOSE front_device_list;
              l_need_dispatch  := FALSE;
              EXIT search_device_loop;
            END IF;
          END IF;

          BEGIN
            SELECT   transaction_temp_id
                   , task_type
                   , device_invoked
                INTO l_task_id
                   , l_task_type_n
                   , l_device_invoked
                FROM wms_dispatched_tasks
               WHERE person_id = l_user_id
                 AND organization_id = l_org_id
                 AND device_id = l_temp_device_id
                 AND task_type IN(1, 3, 4, 5, 6)
                 AND status <= 3
                 AND ROWNUM = 1
            ORDER BY 1;

            IF (l_device_invoked = 'Y'
                AND l_avail_device_id IS NULL) THEN
              l_avail_device_id  := l_temp_device_id;
              x_task_type        := l_task_type_n;
            ELSIF l_device_invoked = 'N' THEN
              wms_device_integration_pvt.device_request(
                p_bus_event                  => wms_device_integration_pvt.wms_be_pick_load
              , p_call_ctx                   => wms_device_integration_pvt.dev_req_auto
              , p_task_trx_id                => l_task_id
              , p_org_id                     => l_org_id
              , x_request_msg                => l_request_msg
              , x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
              , p_request_id                 => l_request_id
              );

              -- always dispatch the task whether invoking device successfully or not
              -- So update the table always

              UPDATE wms_dispatched_tasks
                 SET device_invoked = 'Y'
                   , device_request_id = l_request_id
               WHERE transaction_temp_id = l_task_id;

              IF l_invoked_device_id IS NULL THEN
                l_invoked_device_id  := l_temp_device_id;
              END IF;

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                IF (l_debug = 1) THEN
                  mydebug('next_CP_task:failed to invoke device ' || TO_CHAR(l_temp_device_id));
                END IF;
              END IF;
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_need_dispatch  := TRUE;
              EXIT search_device_loop;
          END;
        END LOOP;
      END IF;

      EXIT WHEN l_need_dispatch = FALSE;

      IF (l_debug = 1) THEN
        mydebug('next_CP_task: Before Calling TD Engine');
      END IF;

      wms_task_dispatch_engine.dispatch_task(
        p_api_version                => 1.0
      , p_init_msg_list              => 'F'
      , p_commit                     => NULL
      , p_sign_on_emp_id             => l_emp_id
      , p_sign_on_org_id             => l_org_id
      , p_sign_on_zone               => l_zone
      , p_sign_on_equipment_id       => l_eqp_id
      , p_sign_on_equipment_srl      => l_eqp_ins
      , p_task_type                  => l_task_type
      , x_task_cur                   => l_task_cur
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_cartonization_id           => l_lpn_id
      , p_max_clusters               => p_max_clusters
      , x_deliveries_list            => x_deliveries_list
      , x_cartons_list               => x_cartons_list
      );

      IF (l_debug = 1) THEN
        mydebug('next_CP_task: Ret Status' || l_return_status);
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_success THEN
        IF (l_debug = 1) THEN
          mydebug('Task dispatch is sucess for cluster pick');
        END IF;

        l_first_task  := TRUE;

        LOOP
          FETCH l_task_cur INTO task_rec;

          IF (l_debug = 1) THEN
            mydebug('before l_task_cur');
          END IF;

          EXIT WHEN l_task_cur%NOTFOUND;
          l_c_rows  := l_c_rows + 1;

          IF (l_debug = 1) THEN
            mydebug('next_CP_task: TaskID:' || task_rec.task_id);
          END IF;

          IF (l_debug = 1) THEN
            mydebug('next_CP_task: getting Resource ID....');
          END IF;

          IF (task_rec.task_type <> 3) THEN
            -- Picking, Putaway, or Replenishment task
            SELECT bremp.resource_id role_id
                 , t.wms_task_type
                 , t.standard_operation_id
                 , t.operation_plan_id
                 , t.move_order_line_id
              INTO l_per_res_id
                 , l_wms_task_type
                 , l_std_op_id
                 , l_operation_plan_id
                 , l_move_order_line_id
              FROM mtl_material_transactions_temp t, bom_std_op_resources bsor, bom_resources bremp
             WHERE t.transaction_temp_id = task_rec.task_id
               AND t.standard_operation_id = bsor.standard_operation_id
               AND bsor.resource_id = bremp.resource_id
               AND bremp.resource_type = 2
               AND ROWNUM < 2;
          /*ELSE
            -- Cycle counting task
            SELECT
        bremp.resource_id role_id,
        3,
        mcce.standard_operation_id
        INTO
        l_per_res_id,
        l_wms_task_type,
        l_std_op_id
        FROM
        mtl_cycle_count_entries mcce,
        bom_std_op_resources bsor,
        bom_resources bremp
        where mcce.cycle_count_entry_id = task_rec.task_id
        and mcce.standard_operation_id = bsor.standard_operation_id
        and bsor.resource_id = bremp.resource_id
        and bremp.resource_type = 2
        and rownum<2;
          */
          END IF;

          IF (l_debug = 1) THEN
            mydebug('next_CP_task: After getting Resource ID....');
          END IF;

          IF l_eqp_id IS NOT NULL THEN
            SELECT resource_id
              INTO l_mac_res_id
              FROM bom_resource_equipments
             WHERE inventory_item_id = l_eqp_id
               AND ROWNUM < 2;
          END IF;

          SELECT mtl_material_transactions_s.NEXTVAL txnhdrid
            INTO l_txn_hdr_id
            FROM DUAL;

          UPDATE mtl_material_transactions_temp
             SET transaction_header_id = l_txn_hdr_id
           WHERE transaction_temp_id = task_rec.task_id;

          -- Insert into WMS_DISPATCHED_TASKS for this user
          SELECT wms_dispatched_tasks_s.NEXTVAL
            INTO l_next_task_id
            FROM DUAL;

          INSERT INTO wms_dispatched_tasks
                      (
                       task_id
                     , transaction_temp_id
                     , organization_id
                     , user_task_type
                     , person_id
                     , effective_start_date
                     , effective_end_date
                     , equipment_id
                     , equipment_instance
                     , person_resource_id
                     , machine_resource_id
                     , status
                     , dispatched_time
                     , last_update_date
                     , last_updated_by
                     , creation_date
                     , created_by
                     , task_type
                     , priority
                     , operation_plan_id
                     , move_order_line_id
                      )
               VALUES (
                       l_next_task_id
                     , task_rec.task_id
                     , l_org_id
                     , NVL(l_std_op_id, 2)
                     , l_user_id
                     , SYSDATE
                     , SYSDATE
                     , l_eqp_id
                     , l_eqp_ins
                     , l_per_res_id
                     , l_mac_res_id
                     , 3
                     , SYSDATE
                     , SYSDATE
                     , l_emp_id
                     , SYSDATE
                     , l_emp_id
                     , l_wms_task_type
                     , task_rec.task_priority
                     , l_operation_plan_id
                     , l_move_order_line_id
                      );

          IF (l_debug = 1) THEN
            mydebug('next_CP_task: After Insert into WMSDT');
          END IF;

          -- If LPN has been provided, exit, since we only want the first
          --task
          IF l_lpn_id IS NULL
             OR l_lpn_id = fnd_api.g_miss_num THEN
            IF (l_debug = 1) THEN
              mydebug('next_CP_task: LPN was not provided');
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('next_CP_task: LPN was provided - pick by label');
            END IF;

            EXIT;
          END IF;

          IF l_temp_device_id IS NOT NULL THEN
            IF (l_debug = 1) THEN
              mydebug('next_CP_task: temp_device_id');
            END IF;

            UPDATE wms_dispatched_tasks
               SET device_id = l_temp_device_id
                 , device_invoked = 'N'
             WHERE task_id = l_next_task_id;

            IF l_first_task THEN -- invoke the device
              wms_device_integration_pvt.device_request(
                p_bus_event                  => wms_device_integration_pvt.wms_be_pick_load
              , p_call_ctx                   => wms_device_integration_pvt.dev_req_auto
              , p_task_trx_id                => task_rec.task_id
              , p_org_id                     => l_org_id
              , x_request_msg                => l_request_msg
              , x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
              , p_request_id                 => l_request_id
              );

              -- always dispatch the task whether invoking device successfully or not
              -- So update the table always


              UPDATE wms_dispatched_tasks
                 SET device_invoked = 'Y'
                   , device_request_id = l_request_id
               WHERE task_id = l_next_task_id;

              IF l_invoked_device_id IS NULL THEN
                l_invoked_device_id  := l_temp_device_id;
              END IF;

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                IF (l_debug = 1) THEN
                  mydebug('next_CP_task:failed to invoke device ' || TO_CHAR(l_temp_device_id));
                END IF;
              END IF;

              l_first_task  := FALSE;
            END IF;
          END IF;
        END LOOP;

        --********************
        DELETE FROM wms_skip_task_exceptions
              WHERE task_id = task_rec.task_id
                AND task_id IN(
                     SELECT wste.task_id
                       FROM wms_skip_task_exceptions wste, mtl_parameters mp
                      WHERE ABS((SYSDATE - wste.creation_date) * 24 * 60) > mp.skip_task_waiting_minutes
                        AND wste.task_id = task_rec.task_id
                        AND wste.organization_id = mp.organization_id);

        --************************

        -- Set the output task type parameter equals to the last
        -- task type returned since they should all be of the same type
        x_task_type   := l_wms_task_type;

        -- Committing these tasks to this user
        IF (l_debug = 1) THEN
          mydebug('before commiting');
        END IF;

        COMMIT;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_TDENG_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          mydebug('next_CP_task: Setting status to S');
        END IF;

        l_return_status  := fnd_api.g_ret_sts_success;
      -- l_c_rows:=0;
      END IF;

      IF l_device_id IS NULL THEN
        l_need_dispatch  := FALSE;
      END IF;
    END LOOP; -- end loop of the devices

    IF l_avail_device_id IS NOT NULL THEN
      x_avail_device_id  := l_avail_device_id;
      l_c_rows           := 1; -- to indicate there are tasks already
    ELSIF l_invoked_device_id IS NOT NULL THEN
      x_avail_device_id  := l_invoked_device_id;
      l_c_rows           := 1; -- to indicate there are tasks already

      SELECT task_type
        INTO x_task_type
        FROM wms_dispatched_tasks
       WHERE device_id = x_avail_device_id
         AND device_invoked = 'Y'
         AND person_id = l_user_id
         AND status <= 3
         AND task_type IN(1, 3, 4, 5, 6);
    ELSIF l_device_id IS NOT NULL THEN
      l_c_rows  := 0;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('next_CP_task: number of tasks: ' || l_c_rows);
      mydebug('next_CP_task: done with API');
    END IF;

    x_nbr_tasks      := l_c_rows;
    x_return_status  := fnd_api.g_ret_sts_success;
    COMMIT;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO sp_td_gen_next_cp_task;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO sp_td_gen_next_cp_task;
  END next_cluster_pick_task;

  --p_loc, p_sub are user inputs
  PROCEDURE complete_pick(
    p_lpn               IN            VARCHAR2
  , p_container_item_id IN            NUMBER
  , p_org_id            IN            NUMBER
  , p_temp_id           IN            NUMBER
  , p_loc               IN            NUMBER
  , p_sub               IN            VARCHAR2
  , p_from_lpn_id       IN            NUMBER
  , p_txn_hdr_id        IN            NUMBER
  , p_user_id           IN            NUMBER
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  , p_ok_to_process     OUT NOCOPY    VARCHAR2
  ) IS
    l_msg_cnt             NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_return_status       VARCHAR2(240);
    l_lpn_id              NUMBER;
    l_lpn                 VARCHAR2(30);
    l_exist_lpn           NUMBER;
    l_txn_ret             NUMBER;
    l_loc                 NUMBER;
    l_from_lpn_id         NUMBER;
    l_content_lpn_id      NUMBER;
    l_mmtt_from_lpn_id    NUMBER;
    l_transfer_lpn_id     NUMBER;
    l_outermost_lpn_id    NUMBER;
    -- Stuff for pick confirm

    l_orig_sub            VARCHAR2(10);
    l_orig_loc            NUMBER;
    l_tran_type_id        NUMBER;
    l_orig_txn_header_id  NUMBER;
    l_item_id             NUMBER;
    l_qty                 NUMBER;
    l_uom                 VARCHAR2(10);
    l_from_sub            VARCHAR2(30);
    l_from_loc            NUMBER;
    l_serial_code         NUMBER;
    l_lot_code            NUMBER;
    l_is_lot_control      VARCHAR2(5)    := 'false';
    l_is_serial_control   VARCHAR2(5)    := 'false';
    l_is_revision_control VARCHAR2(5)    := 'false';
    l_sub_reservable_type NUMBER;
    l_rev                 VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number          VARCHAR2(80);

    CURSOR mtlt_csr IS
      SELECT mtlt.lot_number
           , mtlt.transaction_quantity
        FROM mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id = p_temp_id;

    l_debug               NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_return_status  := fnd_api.g_ret_sts_success;
    l_lpn            := p_lpn;
    l_loc            := p_loc;
    l_exist_lpn      := NULL;
    l_lpn_id         := NULL;
    l_from_lpn_id    := p_from_lpn_id;
    p_ok_to_process  := 'true';

    IF (l_loc = 0) THEN
      l_loc  := NULL;
    END IF;

    SELECT NVL(content_lpn_id, 0)
         , NVL(lpn_id, 0)
         , transfer_lpn_id
         , transfer_subinventory
         , transfer_to_location
         , transaction_type_id
         , transaction_header_id
      INTO l_content_lpn_id
         , l_mmtt_from_lpn_id
         , l_transfer_lpn_id
         , l_orig_sub
         , l_orig_loc
         , l_tran_type_id
         , l_orig_txn_header_id
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = p_temp_id;

    IF (l_loc <> l_orig_loc)
       OR(p_sub <> l_orig_sub) THEN
      IF (l_debug = 1) THEN
        mydebug('complete_pick: User entered a different sub');
      END IF;

      UPDATE mtl_material_transactions_temp
         SET transfer_subinventory = p_sub
           , transfer_to_location = l_loc
       WHERE transaction_temp_id = p_temp_id;
    END IF;

    IF (p_sub <> l_orig_sub) THEN
      SELECT msi.reservable_type
        INTO l_sub_reservable_type
        FROM mtl_secondary_inventories msi
       WHERE msi.secondary_inventory_name = p_sub
         AND msi.organization_id = p_org_id;

      IF l_sub_reservable_type = 2 THEN
        IF (l_debug = 1) THEN
          mydebug('complete_pick: Transfer Sub is non-reservable');
        END IF;

        SELECT mmtt.inventory_item_id
             , mmtt.transaction_quantity
             , mmtt.transaction_uom
             , mmtt.subinventory_code
             , mmtt.locator_id
             , mmtt.revision
          INTO l_item_id
             , l_qty
             , l_uom
             , l_from_sub
             , l_from_loc
             , l_rev
          FROM mtl_material_transactions_temp mmtt
         WHERE mmtt.transaction_temp_id = p_temp_id;

        SELECT msi.serial_number_control_code
             , msi.lot_control_code
          INTO l_serial_code
             , l_lot_code
          FROM mtl_system_items msi
         WHERE msi.inventory_item_id = l_item_id
           AND msi.organization_id = p_org_id;

        IF (l_serial_code > 1
            AND l_serial_code <> 6) THEN
          l_is_serial_control  := 'true';
        END IF;

        IF l_rev IS NOT NULL THEN
          l_is_revision_control  := 'true';
        END IF;

        IF l_lot_code > 1 THEN
          l_is_lot_control  := 'true';

          IF (l_debug = 1) THEN
            mydebug('complete_pick: Lot controlled');
          END IF;

          OPEN mtlt_csr;

          LOOP
            FETCH mtlt_csr INTO l_lot_number, l_qty;
            EXIT WHEN mtlt_csr%NOTFOUND;
            inv_txn_validations.check_loose_and_packed_qty(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => l_item_id
            , p_is_revision_control        => l_is_revision_control
            , p_is_lot_control             => l_is_lot_control
            , p_is_serial_control          => l_is_serial_control
            , p_revision                   => l_rev
            , p_lot_number                 => l_lot_number
            , p_transaction_quantity       => l_qty
            , p_transaction_uom            => l_uom
            , p_subinventory_code          => l_from_sub
            , p_locator_id                 => l_from_loc
            , p_transaction_temp_id        => p_temp_id
            , p_ok_to_process              => p_ok_to_process
            , p_transfer_subinventory      => p_sub
            );
          END LOOP;

          CLOSE mtlt_csr;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('complete_pick: Not lot controlled');
          END IF;

          inv_txn_validations.check_loose_and_packed_qty(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => l_item_id
          , p_is_revision_control        => l_is_revision_control
          , p_is_lot_control             => l_is_lot_control
          , p_is_serial_control          => l_is_serial_control
          , p_revision                   => l_rev
          , p_lot_number                 => NULL
          , p_transaction_quantity       => l_qty
          , p_transaction_uom            => l_uom
          , p_subinventory_code          => l_from_sub
          , p_locator_id                 => l_from_loc
          , p_transaction_temp_id        => p_temp_id
          , p_ok_to_process              => p_ok_to_process
          , p_transfer_subinventory      => p_sub
          );

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              mydebug('complete_pick: unexpected error in check_loose_and_packed_qty');
            END IF;

            p_ok_to_process  := 'false';
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              mydebug('complete_pick: error in check_and_packed_loose_qty');
            END IF;

            p_ok_to_process  := 'false';
            RAISE fnd_api.g_exc_error;
          END IF;

          IF p_ok_to_process = 'false' THEN
            IF (l_debug = 1) THEN
              mydebug('complete_pick: After quantity validation. Quantity not enough. Cannot process');
            END IF;

            x_return_status  := fnd_api.g_ret_sts_success;
            RETURN;
          END IF;
        END IF;
      END IF;
    END IF;

    -- Check to see if LPN exists

    IF (l_lpn IS NULL
        OR l_lpn = '') THEN
      l_lpn_id  := NULL;

      IF (l_debug = 1) THEN
        mydebug('complete_pick: No LPN was passed');
      END IF;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('complete_pick:  LPN was passed');
      END IF;

      l_exist_lpn  := 0;

      BEGIN
        SELECT 1
          INTO l_exist_lpn
          FROM DUAL
         WHERE EXISTS(SELECT 1
                        FROM wms_license_plate_numbers
                       WHERE license_plate_number = l_lpn
                         AND organization_id = p_org_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_exist_lpn  := 0;
      END;

      IF (l_exist_lpn = 0) THEN
        -- LPN does not exist, create it
        -- Call Suresh's Create LPN API
        IF (l_debug = 1) THEN
          mydebug('complete_pick: Creating LPN');
        END IF;

        wms_container_pub.create_lpn(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_cnt
        , x_msg_data                   => l_msg_data
        , p_lpn                        => l_lpn
        , p_organization_id            => p_org_id
        , p_container_item_id          => p_container_item_id
        , p_lot_number                 => NULL
        , p_revision                   => NULL
        , p_serial_number              => NULL
        , p_subinventory               => p_sub
        , p_locator_id                 => l_loc
        , p_source                     => WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED --Bug#4864812.
        , p_cost_group_id              => NULL
        , x_lpn_id                     => l_lpn_id
        );
        fnd_msg_pub.count_and_get(p_count => l_msg_cnt, p_data => l_msg_data);

        IF (l_msg_cnt = 0) THEN
          IF (l_debug = 1) THEN
            mydebug('complete_pick: Successful');
          END IF;
        ELSIF(l_msg_cnt = 1) THEN
          IF (l_debug = 1) THEN
            mydebug('complete_pick: Not Successful');
            mydebug(REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('complete_pick: Not Successful2');
          END IF;

          FOR i IN 1 .. l_msg_cnt LOOP
            l_msg_data  := fnd_msg_pub.get(i, 'F');

            IF (l_debug = 1) THEN
              mydebug(REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
            END IF;
          END LOOP;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE
        -- LPN exists. Get LPN ID
        SELECT lpn_id
          INTO l_lpn_id
          FROM wms_license_plate_numbers
         WHERE license_plate_number = l_lpn
           AND organization_id = p_org_id;
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('complete_pick: Updating MMTT');
    END IF;

    IF (WMS_CONTROL.get_current_release_level >=
        INV_RELEASE.get_j_release_level)
    THEN
       --
       -- Bug 3362939:
       -- Do not update transaction_batch_seq
       -- In patchset J this is done in
       -- wms_pick_drop_pvt.pick_drop
       --
       IF (l_content_lpn_id IS NULL
           OR l_content_lpn_id <> l_transfer_lpn_id) THEN
         UPDATE mtl_material_transactions_temp mmtt
            SET transaction_status    = 3
              , transaction_header_id = p_txn_hdr_id
              , last_update_date      = SYSDATE
              , last_updated_by       = p_user_id
              , transaction_batch_id  = p_txn_hdr_id
          WHERE mmtt.transaction_temp_id = p_temp_id;
       ELSIF(l_content_lpn_id = l_transfer_lpn_id) THEN
         -- We are transferring the entire lpn
         UPDATE mtl_material_transactions_temp mmtt
            SET transaction_status    = 3
              , transaction_header_id = p_txn_hdr_id
              , transfer_lpn_id       = NULL
              , last_update_date      = SYSDATE
              , last_updated_by       = p_user_id
              , transaction_batch_id  = p_txn_hdr_id
          WHERE mmtt.transaction_temp_id = p_temp_id;
       END IF;
    ELSE
       IF (l_content_lpn_id IS NULL
           OR l_content_lpn_id <> l_transfer_lpn_id) THEN
         UPDATE mtl_material_transactions_temp mmtt
            SET transaction_status    = 3
              , transaction_header_id = p_txn_hdr_id
              , last_update_date      = SYSDATE
              , last_updated_by       = p_user_id
              , transaction_batch_id  = p_txn_hdr_id
              , transaction_batch_seq = p_temp_id
          WHERE mmtt.transaction_temp_id = p_temp_id;
       ELSIF(l_content_lpn_id = l_transfer_lpn_id) THEN
         -- We are transferring the entire lpn
         UPDATE mtl_material_transactions_temp mmtt
            SET transaction_status    = 3
              , transaction_header_id = p_txn_hdr_id
              , transfer_lpn_id       = NULL
              , last_update_date      = SYSDATE
              , last_updated_by       = p_user_id
              , transaction_batch_id  = p_txn_hdr_id
              , transaction_batch_seq = p_temp_id
          WHERE mmtt.transaction_temp_id = p_temp_id;
       END IF;
    END IF;

    IF l_tran_type_id = 35 THEN
       IF (l_debug = 1) THEN
          mydebug('complete_pick: WIP issue: update txn qty and primary qty to -ve');
       END IF;

       --
       -- For 11.5.10 or higher do not set process_flag to 'W'
       --
       IF (WMS_CONTROL.get_current_release_level >=
           INV_RELEASE.get_j_release_level)
       THEN
          UPDATE mtl_material_transactions_temp
             SET transaction_quantity = -1 * ABS(transaction_quantity)
               , primary_quantity     = -1 * ABS(primary_quantity)
           WHERE transaction_temp_id = p_temp_id
             AND organization_id     = p_org_id;
       ELSE
          UPDATE mtl_material_transactions_temp
             SET transaction_quantity = -1 * ABS(transaction_quantity)
               , primary_quantity     = -1 * ABS(primary_quantity)
               , process_flag         = 'W'
           WHERE transaction_temp_id = p_temp_id
             AND organization_id     = p_org_id;
       END IF;
    END IF;

    -- Have to update WMS_Exceptions so that any exceptions already
    -- recorded for this MMTT line will now be updated with the new txn
    -- header_id
    UPDATE wms_exceptions
       SET transaction_header_id = p_txn_hdr_id
     WHERE transaction_header_id = l_orig_txn_header_id;

    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END complete_pick;

  FUNCTION get_primary_quantity(p_item_id IN NUMBER, p_organization_id IN NUMBER, p_from_quantity IN NUMBER, p_from_unit IN VARCHAR2)
    RETURN NUMBER IS
    l_primary_uom      VARCHAR2(3);
    l_primary_quantity NUMBER;
    l_debug            NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    SELECT primary_uom_code
      INTO l_primary_uom
      FROM mtl_system_items
     WHERE organization_id = p_organization_id
       AND inventory_item_id = p_item_id;

    l_primary_quantity  :=
      inv_convert.inv_um_convert(
        item_id                      => p_item_id
      , PRECISION                    => NULL
      , from_quantity                => p_from_quantity
      , from_unit                    => p_from_unit
      , to_unit                      => l_primary_uom
      , from_name                    => NULL
      , to_name                      => NULL
      );
    RETURN l_primary_quantity;
  END get_primary_quantity;

  PROCEDURE process_lot_serial(
    p_org_id        IN            NUMBER
  , p_user_id       IN            NUMBER
  , p_temp_id       IN            NUMBER
  , p_item_id       IN            NUMBER
  , p_qty           IN            NUMBER
  , p_uom           IN            VARCHAR2
  , p_lot           IN            VARCHAR2
  , p_fm_serial     IN            VARCHAR2
  , p_to_serial     IN            VARCHAR2
  , p_action        IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  ) IS
    l_org_id      NUMBER;
    l_temp_id     NUMBER;
    l_item_id     NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot         VARCHAR2(80);
    l_fm_serial   VARCHAR2(30);
    l_to_serial   VARCHAR2(30);
    l_qty         NUMBER;
    l_uom         VARCHAR2(3);
    l_action      NUMBER;
    l_exp_date    DATE;
    l_pr_qty      NUMBER;
    l_user_id     NUMBER;
    l_ser_seq     NUMBER;
    l_cnt         NUMBER;
    l_lot_ser_seq NUMBER       := 0;
    l_debug       NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    l_from_ser_number NUMBER;
    l_to_ser_number   NUMBER;
    l_temp_prefix     VARCHAR2(30);
    l_range_numbers   NUMBER;
    l_ser_num_length  NUMBER;
    l_prefix_length   NUMBER;
    l_cur_ser_num     NUMBER;
    l_cur_serial_number    mtl_serial_numbers.serial_number%type;

    --Bug #2966531 - Cursor to store serial attributes from MSN
    CURSOR c_msn_attributes(  v_serial_number VARCHAR2
                            , v_inventory_item_id NUMBER) IS
      SELECT  vendor_serial_number, vendor_lot_number, parent_serial_number
      , origination_date, end_item_unit_number, territory_code, time_since_new, cycles_since_new
      , time_since_overhaul, cycles_since_overhaul, time_since_repair, cycles_since_repair
      , time_since_visit, cycles_since_visit, time_since_mark, cycles_since_mark
      , number_of_repairs, serial_attribute_category, c_attribute1, c_attribute2
      , c_attribute3, c_attribute4, c_attribute5, c_attribute6, c_attribute7
      , c_attribute8, c_attribute9, c_attribute10, c_attribute11, c_attribute12
      , c_attribute13, c_attribute14, c_attribute15, c_attribute16, c_attribute17, c_attribute18
      , c_attribute19, c_attribute20, d_attribute1, d_attribute2, d_attribute3
      , d_attribute4, d_attribute5, d_attribute6, d_attribute7, d_attribute8
      , d_attribute9, d_attribute10, n_attribute1, n_attribute2, n_attribute3
      , n_attribute4, n_attribute5, n_attribute6, n_attribute7, n_attribute8
      , n_attribute9, n_attribute10
      FROM    mtl_serial_numbers
      WHERE   serial_number = v_serial_number
      AND     inventory_item_id = v_inventory_item_id;

  TYPE msn_attribute_rec_tp IS RECORD (
    vendor_serial_number  mtl_serial_numbers.vendor_serial_number%type,
    vendor_lot_number     mtl_serial_numbers.vendor_lot_number%type,
    parent_serial_number  mtl_serial_numbers.parent_serial_number%type,
    origination_date      mtl_serial_numbers.origination_date%type,
    end_item_unit_number  mtl_serial_numbers.end_item_unit_number%type,
    territory_code        mtl_serial_numbers.territory_code%type,
    time_since_new        mtl_serial_numbers.time_since_new%type,
    cycles_since_new      mtl_serial_numbers.cycles_since_new%type,
    time_since_overhaul   mtl_serial_numbers.time_since_overhaul%type,
    cycles_since_overhaul mtl_serial_numbers.cycles_since_overhaul%type,
    time_since_repair     mtl_serial_numbers.time_since_repair%type,
    cycles_since_repair   mtl_serial_numbers.cycles_since_repair%type,
    time_since_visit      mtl_serial_numbers.time_since_visit%type,
    cycles_since_visit    mtl_serial_numbers.cycles_since_visit%type,
    time_since_mark       mtl_serial_numbers.time_since_mark%type,
    cycles_since_mark     mtl_serial_numbers.cycles_since_mark%type,
    number_of_repairs     mtl_serial_numbers.number_of_repairs%type,
    serial_attribute_category  mtl_serial_numbers.serial_attribute_category%type,
    c_attribute1          mtl_serial_numbers.c_attribute1%type,
    c_attribute2          mtl_serial_numbers.c_attribute2%type,
    c_attribute3          mtl_serial_numbers.c_attribute3%type,
    c_attribute4          mtl_serial_numbers.c_attribute4%type,
    c_attribute5          mtl_serial_numbers.c_attribute5%type,
    c_attribute6          mtl_serial_numbers.c_attribute6%type,
    c_attribute7          mtl_serial_numbers.c_attribute7%type,
    c_attribute8          mtl_serial_numbers.c_attribute8%type,
    c_attribute9          mtl_serial_numbers.c_attribute9%type,
    c_attribute10         mtl_serial_numbers.c_attribute10%type,
    c_attribute11         mtl_serial_numbers.c_attribute11%type,
    c_attribute12         mtl_serial_numbers.c_attribute12%type,
    c_attribute13         mtl_serial_numbers.c_attribute13%type,
    c_attribute14         mtl_serial_numbers.c_attribute14%type,
    c_attribute15         mtl_serial_numbers.c_attribute15%type,
    c_attribute16         mtl_serial_numbers.c_attribute16%type,
    c_attribute17         mtl_serial_numbers.c_attribute17%type,
    c_attribute18         mtl_serial_numbers.c_attribute18%type,
    c_attribute19         mtl_serial_numbers.c_attribute19%type,
    c_attribute20         mtl_serial_numbers.c_attribute20%type,
    d_attribute1          mtl_serial_numbers.d_attribute1%type,
    d_attribute2          mtl_serial_numbers.d_attribute2%type,
    d_attribute3          mtl_serial_numbers.d_attribute3%type,
    d_attribute4          mtl_serial_numbers.d_attribute4%type,
    d_attribute5          mtl_serial_numbers.d_attribute5%type,
    d_attribute6          mtl_serial_numbers.d_attribute6%type,
    d_attribute7          mtl_serial_numbers.d_attribute7%type,
    d_attribute8          mtl_serial_numbers.d_attribute8%type,
    d_attribute9          mtl_serial_numbers.d_attribute9%type,
    d_attribute10         mtl_serial_numbers.d_attribute10%type,
    n_attribute1          mtl_serial_numbers.n_attribute1%type,
    n_attribute2          mtl_serial_numbers.n_attribute2%type,
    n_attribute3          mtl_serial_numbers.n_attribute3%type,
    n_attribute4          mtl_serial_numbers.n_attribute4%type,
    n_attribute5          mtl_serial_numbers.n_attribute5%type,
    n_attribute6          mtl_serial_numbers.n_attribute6%type,
    n_attribute7          mtl_serial_numbers.n_attribute7%type,
    n_attribute8          mtl_serial_numbers.n_attribute8%type,
    n_attribute9          mtl_serial_numbers.n_attribute9%type,
    n_attribute10         mtl_serial_numbers.n_attribute10%type );

    l_msn_attribute_rec   msn_attribute_rec_tp;
  BEGIN
    l_org_id         := p_org_id;
    l_temp_id        := p_temp_id;
    l_item_id        := p_item_id;
    l_lot            := p_lot;
    l_fm_serial      := p_fm_serial;
    l_to_serial      := p_to_serial;
    l_qty            := p_qty;
    l_uom            := p_uom;
    l_action         := p_action;
    l_user_id        := p_user_id;
    l_cnt            := 0;

    IF (l_debug = 1) THEN
      mydebug('process_lot_serial: In Process Lot Serial');
    END IF;

    -- Calculate Primary Quantity

    l_pr_qty         :=
      wms_task_dispatch_gen.get_primary_quantity(p_item_id => l_item_id, p_organization_id => l_org_id, p_from_quantity => l_qty
      , p_from_unit                  => l_uom);

    IF (l_debug = 1) THEN
      mydebug('process_lot_serial: after prim qty');
      mydebug('process_lot_serial: prim qty' || l_pr_qty);
      mydebug('process_lot_serial:  qty' || l_qty);
      mydebug('process_lot_serial: Lot' || l_lot);
      mydebug('process_lot_serial: TempId:' || l_temp_id);
    END IF;

    IF (l_action <> 3) THEN
      -- Lot controlled. Get expiration date
      SELECT expiration_date
        INTO l_exp_date
        FROM mtl_lot_numbers
       WHERE organization_id = l_org_id
         AND inventory_item_id = l_item_id
         AND lot_number = l_lot;
    END IF;

    IF (l_action = 1) THEN
      -- Lot Controlled only
      -- Insert into mtl_transaction_lot
      IF (l_debug = 1) THEN
        mydebug('process_lot_serial: Inserting Lots');
      END IF;

      UPDATE mtl_transaction_lots_temp
         SET transaction_quantity = l_qty
           , primary_quantity = l_pr_qty
           , last_update_date = SYSDATE
           , last_updated_by = l_user_id
       WHERE transaction_temp_id = l_temp_id
         AND lot_number = l_lot;

      IF (l_debug = 1) THEN
        mydebug('process_lot_serial: After lot update');
      END IF;
    ELSIF(l_action = 2) THEN
      -- Lot and serial controlled
      -- Get sequence for serial tran id

      SELECT NVL(serial_transaction_temp_id, 0)
        INTO l_lot_ser_seq
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = l_temp_id
         AND lot_number = l_lot;

      IF l_lot_ser_seq = 0 THEN
        SELECT mtl_material_transactions_s.NEXTVAL
          INTO l_ser_seq
          FROM DUAL;
      ELSE
        l_ser_seq  := l_lot_ser_seq;
      END IF;

      --mydebug('process_lot_serial: Inserting Lots and.....');
      UPDATE mtl_transaction_lots_temp
         SET transaction_quantity = l_qty
           , primary_quantity = l_pr_qty
           , serial_transaction_temp_id = l_ser_seq
           , last_update_date = SYSDATE
           , last_updated_by = l_user_id
       WHERE transaction_temp_id = l_temp_id
         AND lot_number = l_lot;

    /* Bug #2966531
       * For each serial number in the range between from serial and to serial
       *    Open the cursor and fetch the attributes for the current serial number
       *    Create one MSNT record for each serial number and set the attributes from the cursor
       */

      --get the numeric part of the from serial #
      inv_validate.number_from_sequence(l_fm_serial, l_temp_prefix, l_from_ser_number);

      --get the numeric part of the to serial #
      inv_validate.number_from_sequence(l_to_serial, l_temp_prefix, l_to_ser_number);

      l_range_numbers := l_to_ser_number - l_from_ser_number + 1;
      l_ser_num_length := length(l_fm_serial);
      l_prefix_length := length(l_temp_prefix);

      --For each serial number in the range, fetch the attributes from MSN
      --and insert a record into MSNT
      FOR i IN 1 .. l_range_numbers LOOP
        l_cur_ser_num := l_from_ser_number + i - 1;

        --Get the serial number by concatenating the character and the string part
        l_cur_serial_number := l_temp_prefix ||
          LPAD(l_cur_ser_num, l_ser_num_length - NVL(l_prefix_length,0), '0');

mydebug('cir ser num: ' || l_cur_serial_number);

        OPEN c_msn_attributes(l_cur_serial_number, l_item_id);
        FETCH c_msn_attributes INTO l_msn_attribute_rec;
        CLOSE c_msn_attributes;

        INSERT INTO mtl_serial_numbers_temp
            ( TRANSACTION_TEMP_ID
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , CREATION_DATE
           , CREATED_BY
           , fm_serial_number
           , to_serial_number
           , vendor_serial_number
           , vendor_lot_number
           , parent_serial_number
           , origination_date
           , end_item_unit_number
           , territory_code
           , time_since_new
           , cycles_since_new
           , time_since_overhaul
           , cycles_since_overhaul
           , time_since_repair
           , cycles_since_repair
           , time_since_visit
           , cycles_since_visit
           , time_since_mark
           , cycles_since_mark
           , number_of_repairs
           , serial_attribute_category
           , c_attribute1
           , c_attribute2
           , c_attribute3
           , c_attribute4
           , c_attribute5
           , c_attribute6
           , c_attribute7
           , c_attribute8
           , c_attribute9
           , c_attribute10
           , c_attribute11
           , c_attribute12
           , c_attribute13
           , c_attribute14
           , c_attribute15
           , c_attribute16
           , c_attribute17
           , c_attribute18
           , c_attribute19
           , c_attribute20
           , d_attribute1
           , d_attribute2
           , d_attribute3
           , d_attribute4
           , d_attribute5
           , d_attribute6
           , d_attribute7
           , d_attribute8
           , d_attribute9
           , d_attribute10
           , n_attribute1
           , n_attribute2
           , n_attribute3
           , n_attribute4
           , n_attribute5
           , n_attribute6
           , n_attribute7
           , n_attribute8
           , n_attribute9
           , n_attribute10
           )
            VALUES (
             l_ser_seq
           , Sysdate
           , l_user_id
           , Sysdate
           , l_user_id
           , l_fm_serial
           , l_to_serial
           , l_msn_attribute_rec.vendor_serial_number
           , l_msn_attribute_rec.vendor_lot_number
           , l_msn_attribute_rec.parent_serial_number
           , l_msn_attribute_rec.origination_date
           , l_msn_attribute_rec.end_item_unit_number
           , l_msn_attribute_rec.territory_code
           , l_msn_attribute_rec.time_since_new
           , l_msn_attribute_rec.cycles_since_new
           , l_msn_attribute_rec.time_since_overhaul
           , l_msn_attribute_rec.cycles_since_overhaul
           , l_msn_attribute_rec.time_since_repair
           , l_msn_attribute_rec.cycles_since_repair
           , l_msn_attribute_rec.time_since_visit
           , l_msn_attribute_rec.cycles_since_visit
           , l_msn_attribute_rec.time_since_mark
           , l_msn_attribute_rec.cycles_since_mark
           , l_msn_attribute_rec.number_of_repairs
           , l_msn_attribute_rec.serial_attribute_category
           , l_msn_attribute_rec.c_attribute1
           , l_msn_attribute_rec.c_attribute2
           , l_msn_attribute_rec.c_attribute3
           , l_msn_attribute_rec.c_attribute4
           , l_msn_attribute_rec.c_attribute5
           , l_msn_attribute_rec.c_attribute6
           , l_msn_attribute_rec.c_attribute7
           , l_msn_attribute_rec.c_attribute8
           , l_msn_attribute_rec.c_attribute9
           , l_msn_attribute_rec.c_attribute10
           , l_msn_attribute_rec.c_attribute11
           , l_msn_attribute_rec.c_attribute12
           , l_msn_attribute_rec.c_attribute13
           , l_msn_attribute_rec.c_attribute14
           , l_msn_attribute_rec.c_attribute15
           , l_msn_attribute_rec.c_attribute16
           , l_msn_attribute_rec.c_attribute17
           , l_msn_attribute_rec.c_attribute18
           , l_msn_attribute_rec.c_attribute19
           , l_msn_attribute_rec.c_attribute20
           , l_msn_attribute_rec.d_attribute1
           , l_msn_attribute_rec.d_attribute2
           , l_msn_attribute_rec.d_attribute3
           , l_msn_attribute_rec.d_attribute4
           , l_msn_attribute_rec.d_attribute5
           , l_msn_attribute_rec.d_attribute6
           , l_msn_attribute_rec.d_attribute7
           , l_msn_attribute_rec.d_attribute8
           , l_msn_attribute_rec.d_attribute9
           , l_msn_attribute_rec.d_attribute10
           , l_msn_attribute_rec.n_attribute1
           , l_msn_attribute_rec.n_attribute2
           , l_msn_attribute_rec.n_attribute3
           , l_msn_attribute_rec.n_attribute4
           , l_msn_attribute_rec.n_attribute5
           , l_msn_attribute_rec.n_attribute6
           , l_msn_attribute_rec.n_attribute7
           , l_msn_attribute_rec.n_attribute8
           , l_msn_attribute_rec.n_attribute9
           , l_msn_attribute_rec.n_attribute10
          );
      END LOOP;   --END for each serial number
      -- Insert into serial
      --mydebug('process_lot_serial: Inserting Serials');
      /*INSERT INTO mtl_serial_numbers_temp
                  (
                   transaction_temp_id
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , fm_serial_number
                 , to_serial_number
                  )
           VALUES (
                   l_ser_seq
                 , SYSDATE
                 , l_user_id
                 , SYSDATE
                 , l_user_id
                 , l_fm_serial
                 , l_to_serial
                  );*/
    ELSIF(l_action = 3) THEN
      -- Serial controlled only

      IF (l_debug = 1) THEN
        mydebug('process_lot_serial: Inserting Serials Only');
      END IF;

       /* Bug #2966531
       * For each serial number in the range between from serial and to serial
       *    Open the cursor and fetch the attributes for the current serial number
       *    Create one MSNT record for each serial number and set the attributes from the cursor
       */

      --get the numeric part of the from serial #
      inv_validate.number_from_sequence(l_fm_serial, l_temp_prefix, l_from_ser_number);

      --get the numeric part of the to serial #
      inv_validate.number_from_sequence(l_to_serial, l_temp_prefix, l_to_ser_number);

      l_range_numbers := l_to_ser_number - l_from_ser_number + 1;
      l_ser_num_length := length(l_fm_serial);
      l_prefix_length := length(l_temp_prefix);

      --For each serial number in the range, fetch the attributes from MSN
      --and insert a record into MSNT
      FOR i IN 1 .. l_range_numbers LOOP
        l_cur_ser_num := l_from_ser_number + i - 1;
        --Get the serial number by concatenating the character and the string part
        l_cur_serial_number := l_temp_prefix ||
          LPAD(l_cur_ser_num, l_ser_num_length - NVL(l_prefix_length,0), '0');

        OPEN c_msn_attributes(l_cur_serial_number, l_item_id);
        FETCH c_msn_attributes INTO l_msn_attribute_rec;
        CLOSE c_msn_attributes;

        INSERT INTO mtl_serial_numbers_temp
            ( TRANSACTION_TEMP_ID
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , CREATION_DATE
           , CREATED_BY
           , fm_serial_number
           , to_serial_number
           , vendor_serial_number
           , vendor_lot_number
           , parent_serial_number
           , origination_date
           , end_item_unit_number
           , territory_code
           , time_since_new
           , cycles_since_new
           , time_since_overhaul
           , cycles_since_overhaul
           , time_since_repair
           , cycles_since_repair
           , time_since_visit
           , cycles_since_visit
           , time_since_mark
           , cycles_since_mark
           , number_of_repairs
           , serial_attribute_category
           , c_attribute1
           , c_attribute2
           , c_attribute3
           , c_attribute4
           , c_attribute5
           , c_attribute6
           , c_attribute7
           , c_attribute8
           , c_attribute9
           , c_attribute10
           , c_attribute11
           , c_attribute12
           , c_attribute13
           , c_attribute14
           , c_attribute15
           , c_attribute16
           , c_attribute17
           , c_attribute18
           , c_attribute19
           , c_attribute20
           , d_attribute1
           , d_attribute2
           , d_attribute3
           , d_attribute4
           , d_attribute5
           , d_attribute6
           , d_attribute7
           , d_attribute8
           , d_attribute9
           , d_attribute10
           , n_attribute1
           , n_attribute2
           , n_attribute3
           , n_attribute4
           , n_attribute5
           , n_attribute6
           , n_attribute7
           , n_attribute8
           , n_attribute9
           , n_attribute10
         )
      VALUES (
             l_temp_id
           , Sysdate
           , l_user_id
           , Sysdate
           , l_user_id
           , l_fm_serial
           , l_to_serial
           , l_msn_attribute_rec.vendor_serial_number
           , l_msn_attribute_rec.vendor_lot_number
           , l_msn_attribute_rec.parent_serial_number
           , l_msn_attribute_rec.origination_date
           , l_msn_attribute_rec.end_item_unit_number
           , l_msn_attribute_rec.territory_code
           , l_msn_attribute_rec.time_since_new
           , l_msn_attribute_rec.cycles_since_new
           , l_msn_attribute_rec.time_since_overhaul
           , l_msn_attribute_rec.cycles_since_overhaul
           , l_msn_attribute_rec.time_since_repair
           , l_msn_attribute_rec.cycles_since_repair
           , l_msn_attribute_rec.time_since_visit
           , l_msn_attribute_rec.cycles_since_visit
           , l_msn_attribute_rec.time_since_mark
           , l_msn_attribute_rec.cycles_since_mark
           , l_msn_attribute_rec.number_of_repairs
           , l_msn_attribute_rec.serial_attribute_category
           , l_msn_attribute_rec.c_attribute1
           , l_msn_attribute_rec.c_attribute2
           , l_msn_attribute_rec.c_attribute3
           , l_msn_attribute_rec.c_attribute4
           , l_msn_attribute_rec.c_attribute5
           , l_msn_attribute_rec.c_attribute6
           , l_msn_attribute_rec.c_attribute7
           , l_msn_attribute_rec.c_attribute8
           , l_msn_attribute_rec.c_attribute9
           , l_msn_attribute_rec.c_attribute10
           , l_msn_attribute_rec.c_attribute11
           , l_msn_attribute_rec.c_attribute12
           , l_msn_attribute_rec.c_attribute13
           , l_msn_attribute_rec.c_attribute14
           , l_msn_attribute_rec.c_attribute15
           , l_msn_attribute_rec.c_attribute16
           , l_msn_attribute_rec.c_attribute17
           , l_msn_attribute_rec.c_attribute18
           , l_msn_attribute_rec.c_attribute19
           , l_msn_attribute_rec.c_attribute20
           , l_msn_attribute_rec.d_attribute1
           , l_msn_attribute_rec.d_attribute2
           , l_msn_attribute_rec.d_attribute3
           , l_msn_attribute_rec.d_attribute4
           , l_msn_attribute_rec.d_attribute5
           , l_msn_attribute_rec.d_attribute6
           , l_msn_attribute_rec.d_attribute7
           , l_msn_attribute_rec.d_attribute8
           , l_msn_attribute_rec.d_attribute9
           , l_msn_attribute_rec.d_attribute10
           , l_msn_attribute_rec.n_attribute1
           , l_msn_attribute_rec.n_attribute2
           , l_msn_attribute_rec.n_attribute3
           , l_msn_attribute_rec.n_attribute4
           , l_msn_attribute_rec.n_attribute5
           , l_msn_attribute_rec.n_attribute6
           , l_msn_attribute_rec.n_attribute7
           , l_msn_attribute_rec.n_attribute8
           , l_msn_attribute_rec.n_attribute9
           , l_msn_attribute_rec.n_attribute10
        );
      END LOOP;   --END for each each serial

/*      INSERT INTO mtl_serial_numbers_temp
                  (
                   transaction_temp_id
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , fm_serial_number
                 , to_serial_number
                  )
           VALUES (
                   l_temp_id
                 , SYSDATE
                 , l_user_id
                 , SYSDATE
                 , l_user_id
                 , l_fm_serial
                 , l_to_serial
                  );*/
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END process_lot_serial;

  -- Given a lot_number, this returns the qty for the specific lpn and the lot_number

  FUNCTION get_lpn_lot_qty(p_lot_number IN VARCHAR2)
    RETURN NUMBER IS
    l_lpn_qty NUMBER := -1;
    i         NUMBER;
    l_debug   NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    FOR i IN 1 .. t_lpn_lot_qty_table.COUNT LOOP
      IF (t_lpn_lot_qty_table(i).lot_number = p_lot_number) THEN
        l_lpn_qty  := t_lpn_lot_qty_table(i).qty;
        RETURN l_lpn_qty;
      END IF;
    END LOOP;

    RETURN -1;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END get_lpn_lot_qty;

  /*
     The following table gives the conditions checked by LPN Match
     and its return values

     Condition                            x_match    x_return_status
     =================================================================
     LPN already picked                       7               E
     LPN location is invalid                  6               E
     LPN SUB is null                         10               E
     LPN already staged for another SO       12               E
     Item/Lot/Revision is not in LPN          5               E
     LPN has multiple items                   2               S
     The user has to manually confirm the LPN
     LPN has requested item but quantity is   4               S
     more that the allocated quantity
     The user has to manually confirm the LPN
     Serial number is not valid for this     11               E
     transaction.
     LPN has requested item with sufficient   8               E
     quantity but LPN content status is
     invalid
     Serial Allocation was requested for the  9               E
     item but it is not allowed/there
     Everything allright and exact quantity   1               S
     match
     Everything allright and quantity in LPN  3               S
     is less than requested quantity

     Although x_match is being set even for error conditions
     it is used by the calling code ONLY in case of success

  */
  PROCEDURE lpn_match(
    p_lpn                 IN            NUMBER
  , p_org_id              IN            NUMBER
  , p_item_id             IN            NUMBER
  , p_rev                 IN            VARCHAR2
  , p_lot                 IN            VARCHAR2
  , p_qty                 IN            NUMBER
  , p_uom                 IN            VARCHAR2
  , x_match               OUT NOCOPY    NUMBER
  , x_sub                 OUT NOCOPY    VARCHAR2
  , x_loc                 OUT NOCOPY    VARCHAR2
  , x_qty                 OUT NOCOPY    NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_temp_id             IN            NUMBER
  , p_wms_installed       IN            VARCHAR2
  , p_transaction_type_id IN            NUMBER
  , p_cost_group_id       IN            NUMBER
  , p_is_sn_alloc         IN            VARCHAR2
  , p_action              IN            NUMBER
  , x_temp_id             OUT NOCOPY    NUMBER
  , x_loc_id              OUT NOCOPY    NUMBER
  , x_lpn_lot_vector      OUT NOCOPY    VARCHAR2
  , x_lpn_qty             OUT NOCOPY    NUMBER  --Added bug 3946813
  ) IS
    l_msg_cnt                NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(240);
    l_exist_qty              NUMBER;
    l_item_cnt               NUMBER;
    l_rev_cnt                NUMBER;
    l_lot_cnt                NUMBER;
    l_item_cnt2              NUMBER;
    l_cg_cnt                 NUMBER;
    l_sub                    VARCHAR2(60);
    l_loc                    VARCHAR2(60);
    l_loaded                 NUMBER         := 0;
    l_allocate_serial_flag   NUMBER         := 0;
    l_temp_serial_trans_temp NUMBER         := 0;
    l_serial_number          VARCHAR2(50);
    l_lpn_qty                NUMBER;
    l_lpn_uom                VARCHAR2(3);
    l_txn_uom                VARCHAR2(3);
    l_primary_uom            VARCHAR2(3);
    l_lot_code               NUMBER;
    l_serial_code            NUMBER;
    l_mmtt_qty               NUMBER;
    l_out_temp_id            NUMBER         := 0;
    l_serial_exist_cnt       NUMBER         := 0;
    l_total_serial_cnt       NUMBER         := 0;
    l_so_cnt                 NUMBER         := 0;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_mtlt_lot_number        VARCHAR2(80);
    l_mtlt_primary_qty       NUMBER;
    l_wlc_quantity           NUMBER;
    l_wlc_uom_code           VARCHAR2(3);
    l_lot_match              NUMBER;
    l_ok_to_process          VARCHAR2(5);
    l_is_revision_control    VARCHAR2(5);
    l_is_lot_control         VARCHAR2(5);
    l_is_serial_control      VARCHAR2(5);
    b_is_revision_control    BOOLEAN;
    b_is_lot_control         BOOLEAN;
    b_is_serial_control      BOOLEAN;
    l_from_lpn               VARCHAR2(30);
    l_loc_id                 NUMBER;
    l_lpn_context            NUMBER;
    l_lpn_exists             NUMBER;
    l_qoh                    NUMBER;
    l_rqoh                   NUMBER;
    l_qr                     NUMBER;
    l_qs                     NUMBER;
    l_att                    NUMBER;
    l_atr                    NUMBER;
    l_allocated_lpn_id       NUMBER;
    l_table_index            NUMBER         := 0;
    l_table_total            NUMBER         := 0;
    l_table_count            NUMBER;
    l_lpn_include_lpn        NUMBER;
    l_xfr_sub_code           VARCHAR2(30);
    l_sub_active             NUMBER         := 0;
    l_loc_active             NUMBER         := 0;
    l_mmtt_proj_id NUMBER ;  --  2774506/2905646
    l_mmtt_task_id NUMBER ;
    l_locator_id NUMBER;
    l_organization_id NUMBER;
    l_mil_proj_id NUMBER ;
    l_mil_task_id NUMBER ;   -- 2774506/2905646

    CURSOR ser_csr IS
      SELECT serial_number
        FROM mtl_serial_numbers
       WHERE lpn_id = p_lpn
         AND inventory_item_id = p_item_id
         AND NVL(lot_number, -999) = NVL(p_lot, -999);

    CURSOR lot_csr IS
      SELECT mtlt.primary_quantity
           , mtlt.lot_number
        FROM mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id = p_temp_id;

    l_debug                  NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('lpn_match: In lpn Match');
    END IF;

    l_lpn_qty          := p_qty;
    x_return_status    := fnd_api.g_ret_sts_success;
    l_lpn_exists       := 0;
    --clear the PL/SQL table each time come in
    t_lpn_lot_qty_table.DELETE;

    BEGIN
      SELECT 1
           , lpn_context
        INTO l_lpn_exists
           , l_lpn_context
        FROM wms_license_plate_numbers wlpn
       WHERE wlpn.organization_id = p_org_id
         AND wlpn.lpn_id = p_lpn;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug('lpn_match: lpn does not exist in org');
        END IF;

        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    IF l_lpn_exists = 0
       OR p_lpn = 0
       OR l_lpn_context <> wms_container_pub.lpn_context_inv THEN
      IF (l_debug = 1) THEN
        mydebug('lpn_match: lpn does not exist in org');
      END IF;

      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('lpn_match: Checking if lpn has been picked already');
    END IF;

    x_match            := 0;

    BEGIN
      -- Bug#2742860 The from LPN should not be loaded,
      -- this check should not be restricted to that particular transaction header id


      SELECT 1
        INTO l_loaded
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM mtl_material_transactions_temp
                     WHERE (transfer_lpn_id = p_lpn
                            OR content_lpn_id = p_lpn));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_loaded  := 0;
    END;

    IF l_loaded > 0 THEN
      x_match  := 7;
      fnd_message.set_name('WMS', 'WMS_LOADED_ERROR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Check if locator is valid
    IF (l_debug = 1) THEN
      mydebug('lpn_match: Fetch sub/loc for LPN ');
    END IF;

    BEGIN
      -- WMS PJM Integration, Selecting the resolved concatenated segments instead of concatenated segments
      SELECT w.subinventory_code
           , inv_project.get_locsegs(w.locator_id, w.organization_id)
           , w.license_plate_number
           , w.locator_id
           , w.lpn_context
        INTO l_sub
           , l_loc
           , l_from_lpn
           , l_loc_id
           , l_lpn_context
        FROM wms_license_plate_numbers w
       WHERE w.lpn_id = p_lpn
         AND w.locator_id IS NOT NULL;

      IF l_sub IS NULL THEN
        -- The calling java code treats this condition as an error

        x_match  := 10;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      -- bug 2398247
      -- verify if sub is active
      SELECT COUNT(*)
        INTO l_sub_active
        FROM mtl_secondary_inventories
       WHERE NVL(disable_date, SYSDATE + 1) > SYSDATE
         AND organization_id = p_org_id
         AND secondary_inventory_name = l_sub;

      IF l_sub_active = 0 THEN
        x_match  := 10;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      -- verify if locator is active
      SELECT COUNT(*)
        INTO l_loc_active
        FROM mtl_item_locations_kfv
       WHERE NVL(disable_date, SYSDATE + 1) > SYSDATE
         AND organization_id = p_org_id
         AND subinventory_code = l_sub
         AND inventory_location_id = l_loc_id;

      IF l_loc_active = 0 THEN
        x_match  := 10;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOC');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
       -- Begin fix for 2774506


       SELECT locator_id,organization_id  INTO l_locator_id, l_organization_id
        from mtl_material_transactions_temp
        where transaction_temp_id = p_temp_id;

         select nvl(project_id ,-999) , nvl(task_id ,-999)
        into  l_mmtt_proj_id , l_mmtt_task_id
        from  mtl_item_locations
        where inventory_location_id = l_locator_id
        and organization_id = l_organization_id ;

      select nvl(project_id, -999) , nvl(task_id ,-999)
        into l_mil_proj_id , l_mil_task_id
        from mtl_item_locations
        where inventory_location_id = l_loc_id
        and organization_id = p_org_id ;

      mydebug('mmtt project id =  '||l_mmtt_proj_id);
      mydebug('mmtt task id =  '||l_mmtt_task_id);
      mydebug('mil project id =  '||l_mil_proj_id);
      mydebug('mil task id =  '||l_mil_task_id);

         if ((l_mil_proj_id <> l_mmtt_proj_id ) or ( l_mil_task_id <> l_mmtt_task_id )) then
         mydebug('lpn : the project/tak information does not match');
         FND_MESSAGE.SET_NAME('WMS','WMS_CONT_INVALID_LPN');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
      end if ;

     -- End fix for 2774506


      x_sub     := l_sub;
      x_loc     := l_loc;
      x_loc_id  := l_loc_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_match  := 6;
        fnd_message.set_name('WMS', 'WMS_TD_LPN_LOC_NOT_FOUND');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    IF (l_debug = 1) THEN
      mydebug('lpn_match: sub is ' || l_sub);
      mydebug('lpn_match: loc is ' || l_loc);
    END IF;

    -- Check if LPN has already been allocated for any Sales order
    -- If LPN has been picked for a sales order then it cannot be picked

    IF (l_debug = 1) THEN
      mydebug('lpn_match: Checking SO for lpn');
    END IF;

    BEGIN
      SELECT 1
        INTO l_so_cnt
        FROM wms_license_plate_numbers
       WHERE lpn_context = 11
         AND lpn_id = p_lpn
         AND organization_id = p_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_so_cnt  := 0;
    END;

    IF l_so_cnt > 0 THEN
      x_match  := 12;
      fnd_message.set_name('WMS', 'WMS_LPN_STAGED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    SELECT primary_uom_code
         , lot_control_code
         , serial_number_control_code
      INTO l_primary_uom
         , l_lot_code
         , l_serial_code
      FROM mtl_system_items
     WHERE organization_id = p_org_id
       AND inventory_item_id = p_item_id;

    SELECT mmtt.transfer_subinventory
      INTO l_xfr_sub_code
      FROM mtl_material_transactions_temp mmtt
     WHERE mmtt.transaction_temp_id = p_temp_id;

    -- Check to see if the item is in the LPN
    IF (l_debug = 1) THEN
      mydebug('lpn_match: Checking to see if required  item,cg,rev,lot exist in lpn..');
    END IF;

    l_item_cnt         := 0;

    IF (l_debug = 1) THEN
      mydebug('lpn_match: item' || p_item_id || 'LPN' || p_lpn || 'Org' || p_org_id || ' lot' || p_lot || ' Rev' || p_rev);
    END IF;

    BEGIN
      SELECT 1
        INTO l_item_cnt
        FROM DUAL
       WHERE EXISTS(
               SELECT 1
                 FROM wms_lpn_contents wlc
                WHERE wlc.parent_lpn_id = p_lpn
                  AND wlc.organization_id = p_org_id
                  AND wlc.inventory_item_id = p_item_id
                  AND NVL(wlc.revision, '-999') = NVL(p_rev, '-999'));
    EXCEPTION
      -- Item/lot/rev combo does not exist in LPN

      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug('lpn_match: item lot rev combo does not exist');
        END IF;

        x_match  := 5;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    IF l_item_cnt > 0
       AND l_lot_code > 1 THEN
      --Do this only for lot controlled items

      BEGIN
        SELECT 1
          INTO l_item_cnt
          FROM DUAL
         WHERE EXISTS(
                 SELECT 1
                   FROM wms_lpn_contents wlc, mtl_transaction_lots_temp mtlt
                  WHERE wlc.parent_lpn_id = p_lpn
                    AND wlc.organization_id = p_org_id
                    AND wlc.inventory_item_id = p_item_id
                    AND NVL(wlc.revision, '-999') = NVL(p_rev, '-999')
                    AND(mtlt.transaction_temp_id = p_temp_id
                        AND mtlt.lot_number = wlc.lot_number));
      EXCEPTION
        -- Item/lot/rev combo does not exist in LPN

        WHEN NO_DATA_FOUND THEN
          IF (l_debug = 1) THEN
            mydebug('lpn_match:lot rev combo for the item does not exist');
          END IF;

          x_match  := 5;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOT_LPN');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    -- Item with the correct lot/revision exists in LPN
    IF p_is_sn_alloc = 'Y'
       AND p_action = 4 THEN
      b_is_serial_control  := TRUE;
      l_is_serial_control  := 'true';
    ELSE
      b_is_serial_control  := FALSE;
      l_is_serial_control  := 'false';
    END IF;

    IF l_lot_code > 1 THEN
      b_is_lot_control  := TRUE;
      l_is_lot_control  := 'true';
    ELSE
      b_is_lot_control  := FALSE;
      l_is_lot_control  := 'false';
    END IF;

    IF p_rev IS NULL THEN
      b_is_revision_control  := FALSE;
      l_is_revision_control  := 'false';
    ELSE
      b_is_revision_control  := TRUE;
      l_is_revision_control  := 'true';
    END IF;

    IF (l_debug = 1) THEN
      mydebug('lpn_match: is_serial_control:' || l_is_serial_control);
      mydebug('lpn_match: is_lot_control:' || l_is_lot_control);
      mydebug('lpn_match: is_revision_control:' || l_is_revision_control);
    END IF;

    BEGIN
      SELECT allocated_lpn_id
        INTO l_allocated_lpn_id
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_temp_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug('lpn_match: transaction does not exist in mmtt');
        END IF;

        fnd_message.set_name('INV', 'INV_INVALID_TRANSACTION');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    -- clear quantity cache before we create qty tree.
    inv_quantity_tree_pub.clear_quantity_cache;

    -- Check if LPN has items other than the one requested

    IF (l_debug = 1) THEN
      mydebug('lpn_match: lpn has the requested item ');
    END IF;

    l_item_cnt2        := 0;
    l_lot_cnt          := 0;
    l_rev_cnt          := 0;
    l_cg_cnt           := 0;
    l_item_cnt2        := 0;
    l_lot_cnt          := 0;
    l_rev_cnt          := 0;
    l_cg_cnt           := 0;
    l_lpn_include_lpn  := 0;

    SELECT COUNT(DISTINCT inventory_item_id)
         , COUNT(DISTINCT lot_number)
         , COUNT(DISTINCT revision)
         , COUNT(DISTINCT cost_group_id)
      INTO l_item_cnt2
         , l_lot_cnt
         , l_rev_cnt
         , l_cg_cnt
      FROM wms_lpn_contents
     WHERE parent_lpn_id = p_lpn
       AND organization_id = p_org_id;

    SELECT COUNT(*)
      INTO l_lpn_include_lpn
      FROM wms_license_plate_numbers
     WHERE outermost_lpn_id = p_lpn
       AND organization_id = p_org_id;

    IF l_item_cnt2 > 1
       OR l_rev_cnt > 1
       OR l_lpn_include_lpn > 1 THEN
      -- LPN has multiple items
      -- Such LPN's can be picked but in such cases the user has to
      -- manually confirm the LPN.
      -- No validation for LPN contents in such a case.

      IF (l_debug = 1) THEN
        mydebug('lpn_match:  lpn has items other than requested item ');
      END IF;

      x_match  := 2;

      IF l_lot_code > 1 THEN
        l_lpn_qty  := 0;
        OPEN lot_csr;

        LOOP
          FETCH lot_csr INTO l_mtlt_primary_qty, l_mtlt_lot_number;
          EXIT WHEN lot_csr%NOTFOUND;

          IF (l_debug = 1) THEN
            mydebug('l_mtlt_lot_number : ' || l_mtlt_lot_number);
            mydebug('l_mtlt_primary_qty: ' || l_mtlt_primary_qty);
          END IF;

          /*BEGIN
             SELECT
         1,
         wlc.quantity,
         wlc.uom_code
         INTO
         l_lot_match,
         l_wlc_quantity,
         l_wlc_uom_code
         FROM
         wms_lpn_contents wlc
         WHERE  wlc.parent_lpn_id = p_lpn
         AND    wlc.inventory_item_id = p_item_id
         AND    wlc.organization_id = p_org_id
         AND    nvl(wlc.revision,'-999') = nvl(p_rev,'-999')
         AND    wlc.lot_number = l_mtlt_lot_number;

          EXCEPTION WHEN no_data_found THEN
             IF (l_debug = 1) THEN
               mydebug('lpn_match: LPN does not have lot ' || l_mtlt_lot_number);
             END IF;

             l_wlc_quantity := 0;
          END;



          IF l_wlc_quantity <> 0 THEN

             IF l_mtlt_primary_qty >= wms_task_dispatch_gen.get_primary_quantity(p_item_id,p_org_id,l_wlc_quantity,l_wlc_uom_code) THEN

          l_lpn_qty := l_lpn_qty +
            wms_task_dispatch_gen.get_primary_quantity(p_item_id,p_org_id,l_wlc_quantity,l_wlc_uom_code);

        ELSE

          l_lpn_qty := l_lpn_qty + l_mtlt_primary_qty;

             END IF;

          END IF;*/
          IF NVL(l_allocated_lpn_id, 0) = p_lpn THEN
            --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
            -- in order to get correct att.
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => -l_mtlt_primary_qty
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , p_lpn_id                     => p_lpn
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('lpn_match: after update qty tree for lpn l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('lpn_match: calling update qty tree with lpn 1st time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => -l_mtlt_primary_qty
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('lpn_match: after update qty tree without lpn l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('lpn_match: calling update qty tree back without lpn 1st time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          inv_quantity_tree_pub.query_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => TRUE
          , p_is_serial_control          => b_is_serial_control
          , p_demand_source_type_id      => -9999
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => l_mtlt_lot_number
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          , p_lpn_id                     => p_lpn
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_att > 0) THEN
              l_table_index  := l_table_index + 1;

              IF (l_mtlt_primary_qty >= l_att) THEN
                IF (l_debug = 1) THEN
                  mydebug('lpn_match: l_table_index:' || l_table_index || ' lot_number:' || l_mtlt_lot_number || ' qty: ' || l_att);
                END IF;

                l_lpn_qty                                      := l_lpn_qty + l_att;
                t_lpn_lot_qty_table(l_table_index).lpn_id      := p_lpn;
                t_lpn_lot_qty_table(l_table_index).lot_number  := l_mtlt_lot_number;
                t_lpn_lot_qty_table(l_table_index).qty         := l_att;
              ELSE
                IF (l_debug = 1) THEN
                  mydebug('lpn_match: l_table_index:' || l_table_index || ' lot_number:' || l_mtlt_lot_number || ' qty: '
                    || l_mtlt_primary_qty);
                END IF;

                l_lpn_qty                                      := l_lpn_qty + l_mtlt_primary_qty;
                t_lpn_lot_qty_table(l_table_index).lpn_id      := p_lpn;
                t_lpn_lot_qty_table(l_table_index).lot_number  := l_mtlt_lot_number;
                t_lpn_lot_qty_table(l_table_index).qty         := l_mtlt_primary_qty;
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('lpn_match: LPN does not have lot ' || l_mtlt_lot_number);
              END IF;
            /*mydebug('lpn_match: l_table_index:'||l_table_index||' lot_number:'||l_mtlt_lot_number||' qty: 0 ');
            t_lpn_lot_qty_table(l_table_index).lpn_id := p_lpn;
            t_lpn_lot_qty_table(l_table_index).lot_number := l_mtlt_lot_number;
            t_lpn_lot_qty_table(l_table_index).qty := l_mtlt_primary_qty;*/
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('lpn_match: calling qty tree 1st time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          IF NVL(l_allocated_lpn_id, 0) = p_lpn THEN
            --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
            -- in order to get correct att.
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => l_mtlt_primary_qty
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , p_lpn_id                     => p_lpn
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('lpn_match: after update qty tree back for lpn l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('lpn_match: calling update qty tree back with lpn 1st time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => l_mtlt_primary_qty
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('lpn_match: after update qty tree back without lpn l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('lpn_match: calling update qty tree back without lpn 1st time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
        END LOOP;

        CLOSE lot_csr;
      ELSIF p_is_sn_alloc = 'Y'
            AND p_action = 4 THEN
        IF (l_debug = 1) THEN
          mydebug('lpn_match: SN control and SN allocation on');
        END IF;

        SELECT COUNT(fm_serial_number)
          INTO l_serial_exist_cnt
          FROM mtl_serial_numbers_temp msnt
         WHERE msnt.transaction_temp_id = p_temp_id
           AND msnt.fm_serial_number IN(
                                        SELECT serial_number
                                          FROM mtl_serial_numbers
                                         WHERE lpn_id = p_lpn
                                           AND inventory_item_id = p_item_id
                                           AND NVL(revision, '-999') = NVL(p_rev, '-999'));

        IF (l_debug = 1) THEN
          mydebug('lpn_match: SN exist count' || l_serial_exist_cnt);
        END IF;

        IF (l_serial_exist_cnt = 0) THEN
          IF (l_debug = 1) THEN
            mydebug('lpn_match: LPN does not have the allocated serials ');
          END IF;

          -- Serial numbers missing for the transaction
          x_match  := 9;
          fnd_message.set_name('INV', 'INV_INT_SERMISEXP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        SELECT COUNT(fm_serial_number)
          INTO l_total_serial_cnt
          FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
         WHERE mtlt.transaction_temp_id = p_temp_id
           AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;

        IF (l_debug = 1) THEN
          mydebug('lpn_match: SN tot count' || l_total_serial_cnt);
        END IF;

        IF (l_total_serial_cnt = l_serial_exist_cnt) THEN
          IF (l_debug = 1) THEN
            mydebug('lpn_match: LPN matches exactly');
          END IF;

          x_match  := 1;
        ELSIF(l_total_serial_cnt > l_serial_exist_cnt) THEN
          IF (l_debug = 1) THEN
            mydebug('lpn_match: LPN has less');
          END IF;

          x_match    := 3;
          l_lpn_qty  := l_serial_exist_cnt;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('lpn_match: LPN has extra serials');
          END IF;

          x_match  := 4;
        END IF;
      ELSE -- Plain item OR REVISION controlled item
        IF (l_debug = 1) THEN
          mydebug('lpn_match: Getting total qty in user entered uom..');
        END IF;

        /*SELECT SUM ( INV_Convert.INV_UM_Convert(wlc.inventory_item_id,
                  null,
                  wlc.quantity,
                  wlc.uom_code,
                  p_uom,
                  null,
                  null) )
    INTO   l_lpn_qty
    FROM   wms_lpn_contents wlc
    WHERE  wlc.parent_lpn_id = p_lpn
    AND    wlc.inventory_item_id = p_item_id
    AND    Nvl(wlc.revision, '-999') = Nvl(p_rev, '-999');   -- bug fix 2123096  */
        IF (l_debug = 1) THEN
          mydebug('lpn_match: Getting total qty in user entered uom..');
        END IF;

        IF NVL(l_allocated_lpn_id, 0) = p_lpn THEN
          --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
          -- in order to get correct att.
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => -p_qty
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          , p_lpn_id                     => p_lpn
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: update qty tree with lpn 2nd time: l_att:' || l_att);
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('lpn_match: calling update qty tree with lpn 2nd time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSE
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => -p_qty
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: update qty tree without lpn 2nd time:l_att:' || l_att);
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('lpn_match: calling update qty tree back without lpn 2nd time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        inv_quantity_tree_pub.query_quantities(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_cnt
        , x_msg_data                   => l_msg_data
        , p_organization_id            => p_org_id
        , p_inventory_item_id          => p_item_id
        , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
        , p_is_revision_control        => b_is_revision_control
        , p_is_lot_control             => FALSE
        , p_is_serial_control          => b_is_serial_control
        , p_demand_source_type_id      => -9999
        , p_revision                   => NVL(p_rev, NULL)
        , p_lot_number                 => NULL
        , p_subinventory_code          => l_sub
        , p_locator_id                 => l_loc_id
        , x_qoh                        => l_qoh
        , x_rqoh                       => l_rqoh
        , x_qr                         => l_qr
        , x_qs                         => l_qs
        , x_att                        => l_att
        , x_atr                        => l_atr
        , p_lpn_id                     => p_lpn
        , p_transfer_subinventory_code => l_xfr_sub_code
        );

        IF (l_return_status = fnd_api.g_ret_sts_success) THEN
          l_lpn_qty  := l_att;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('lpn_match: calling qty tree 2nd time failed ');
          END IF;

          fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
          fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF NVL(l_allocated_lpn_id, 0) = p_lpn THEN
          --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
          -- in order to get correct att.
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => p_qty
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          , p_lpn_id                     => p_lpn
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: update qty tree back with lpn 2nd time: l_att:' || l_att);
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('lpn_match: calling update qty tree with lpn 2nd time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSE
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => p_qty
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: update qty tree back without lpn 2nd time:l_att:' || l_att);
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('lpn_match: calling update qty tree back without lpn 2nd time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;
    ELSE
      -- LPN has just the item requested
      -- See if quantity/details it has will match the quantity allocated
      -- Find out if the item is lot/serial controlled and UOM of item
      -- and compare with transaction details

      IF (l_debug = 1) THEN
        mydebug('lpn_match:  lpn has only the requested item ');
      END IF;

      SELECT primary_quantity
           , transaction_uom
        INTO l_mmtt_qty
           , l_txn_uom
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_temp_id;

      -- If item is lot controlled then validate the lots

      IF l_lot_code > 1 THEN
        IF (l_debug = 1) THEN
          mydebug('lpn_match:  item is lot controlled');
        END IF;

        -- If item is also serial controlled and serial allocation is
        -- on then count the number of serials allocated which exist
        -- in the LPN.
        -- If the count is 0 then raise an error

        IF p_is_sn_alloc = 'Y'
           AND p_action = 4 THEN
          IF (l_debug = 1) THEN
            mydebug('lpn_match: SN control and SN allocation on');
          END IF;

          SELECT COUNT(fm_serial_number)
            INTO l_serial_exist_cnt
            FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
           WHERE mtlt.transaction_temp_id = p_temp_id
             AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
             AND msnt.fm_serial_number IN(
                                        SELECT serial_number
                                          FROM mtl_serial_numbers
                                         WHERE lpn_id = p_lpn
                                           AND inventory_item_id = p_item_id
                                           AND NVL(revision, '-999') = NVL(p_rev, '-999'));

          IF (l_debug = 1) THEN
            mydebug('lpn_match: SN exist count' || l_serial_exist_cnt);
          END IF;

          IF (l_serial_exist_cnt = 0) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: No serial allocations have occured or LPN does not have the allocated serials ');
            END IF;

            -- Serial numbers missing for the transaction
            x_match  := 9;
            fnd_message.set_name('INV', 'INV_INT_SERMISEXP');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        -- Check whether the Lots allocated are all in the LPN
        -- An LPN can have many lots and items/revisions, check if the
        -- lots allocated for the item exist in the LPN and if any of
        -- them has quantity less/more than what was suggested.

        IF (l_debug = 1) THEN
          mydebug('lpn_match: Check whether the LPN has any lot whose quantity exceeds allocated quantity');
        END IF;

        l_lpn_qty  := 0;
        OPEN lot_csr;

        LOOP
          FETCH lot_csr INTO l_mtlt_primary_qty, l_mtlt_lot_number;
          EXIT WHEN lot_csr%NOTFOUND;
          l_lot_match  := 0;

          IF (l_debug = 1) THEN
            mydebug('lpn_match: l_mtlt_lot_number : ' || l_mtlt_lot_number);
            mydebug('lpn_match: l_mtlt_primary_qty: ' || l_mtlt_primary_qty);
          END IF;

          l_lot_cnt    := l_lot_cnt - 1;

          /*BEGIN
             SELECT
         1,
         wlc.quantity,
         wlc.uom_code
         INTO
         l_lot_match,
         l_wlc_quantity,
         l_wlc_uom_code
         FROM
         wms_lpn_contents wlc
         WHERE  wlc.parent_lpn_id = p_lpn
         AND    wlc.inventory_item_id = p_item_id
         AND    wlc.organization_id = p_org_id
         AND    nvl(wlc.revision,'-999') = nvl(p_rev,'-999')
         AND    wlc.lot_number = l_mtlt_lot_number;

          EXCEPTION WHEN no_data_found THEN
             IF (l_debug = 1) THEN
               mydebug('lpn_match: LPN does not have lot ' || l_mtlt_lot_number);
             END IF;

             IF x_match <> 4 THEN

          x_match := 3;
             END IF;

             l_lot_match := 0;
             l_wlc_quantity := 0;
             l_lot_cnt := l_lot_cnt + 1;
          END;

          IF l_wlc_quantity <> 0 THEN

             IF l_mtlt_primary_qty >= wms_task_dispatch_gen.get_primary_quantity(p_item_id,p_org_id,l_wlc_quantity,l_wlc_uom_code) THEN

          l_lpn_qty := l_lpn_qty + wms_task_dispatch_gen.get_primary_quantity(p_item_id,p_org_id,l_wlc_quantity,l_wlc_uom_code);

        ELSE

          l_lpn_qty := l_lpn_qty + l_mtlt_primary_qty;

             END IF;

          END IF;

          IF l_lot_match <> 0 AND x_match <> 4 THEN

             IF l_mtlt_primary_qty < wms_task_dispatch_gen.get_primary_quantity(p_item_id,p_org_id,l_wlc_quantity,l_wlc_uom_code) THEN

          IF (l_debug = 1) THEN
            mydebug('lpn_match: Qty in LPN for lot ' || l_mtlt_lot_number || ' more than transaction qty for that lot');
          END IF;
          x_match := 4;

        ELSIF  l_mtlt_primary_qty > wms_task_dispatch_gen.get_primary_quantity(p_item_id,p_org_id,l_wlc_quantity,l_wlc_uom_code) THEN

          IF (l_debug = 1) THEN
            mydebug('lpn_match: Qty in LPN for lot ' || l_mtlt_lot_number || ' less than transaction qty for that lot');
          END IF;
          x_match := 3;

        ELSE

          IF x_match <> 3 THEN

             IF (l_debug = 1) THEN
               mydebug('lpn_match: qty in LPN for lot ' || l_mtlt_lot_number || ' equal to transaction qty for that lot');
             END IF;
             x_match := 1;
          END IF;

             END IF;

          END IF;*/
          IF NVL(l_allocated_lpn_id, 0) = p_lpn THEN
            --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
            -- in order to get correct att.
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => -l_mtlt_primary_qty
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , p_lpn_id                     => p_lpn
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('lpn_match: update qty tree 3rd time for lpn l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('lpn_match: calling update qty tree with lpn 3rd time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => -l_mtlt_primary_qty
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('lpn_match: after update without lpn 3rd time l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('lpn_match: calling update qty tree back 3rd time without lpn 3rd time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          inv_quantity_tree_pub.query_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => TRUE
          , p_is_serial_control          => b_is_serial_control
          , p_demand_source_type_id      => -9999
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => l_mtlt_lot_number
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          , p_lpn_id                     => p_lpn
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            l_lot_match  := 1;

            IF (l_att > 0) THEN
              l_table_index  := l_table_index + 1;

              IF (l_mtlt_primary_qty >= l_att) THEN
                l_lpn_qty                                      := l_lpn_qty + l_att;

                IF (l_debug = 1) THEN
                  mydebug('lpn_match: l_table_index:' || l_table_index || ' lot_number:' || l_mtlt_lot_number || ' qty:' || l_att);
                END IF;

                t_lpn_lot_qty_table(l_table_index).lpn_id      := p_lpn;
                t_lpn_lot_qty_table(l_table_index).lot_number  := l_mtlt_lot_number;
                t_lpn_lot_qty_table(l_table_index).qty         := l_att;
              ELSE
                l_lpn_qty                                      := l_lpn_qty + l_mtlt_primary_qty;

                IF (l_debug = 1) THEN
                  mydebug('lpn_match: l_table_index:' || l_table_index || ' lot_number:' || l_mtlt_lot_number || ' qty:'
                    || l_mtlt_primary_qty);
                END IF;

                t_lpn_lot_qty_table(l_table_index).lpn_id      := p_lpn;
                t_lpn_lot_qty_table(l_table_index).lot_number  := l_mtlt_lot_number;
                t_lpn_lot_qty_table(l_table_index).qty         := l_mtlt_primary_qty;
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('lpn_match: LPN does not have lot ' || l_mtlt_lot_number);
              END IF;

              /*mydebug('lpn_match: l_table_index:'||l_table_index||' lot_number:'||l_mtlt_lot_number||' qty:0');
  t_lpn_lot_qty_table(l_table_index).lpn_id := p_lpn;
  t_lpn_lot_qty_table(l_table_index).lot_number := l_mtlt_lot_number;
              t_lpn_lot_qty_table(l_table_index).qty := 0; */
              IF x_match <> 4 THEN
                x_match  := 3;
              END IF;

              l_lot_match  := 0;
              l_lot_cnt    := l_lot_cnt + 1;
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('lpn_match: calling qty tree 3rd time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_lot_match <> 0
             AND x_match <> 4 THEN
            IF l_mtlt_primary_qty < l_att THEN
              IF (l_debug = 1) THEN
                mydebug('lpn_match: Qty in LPN for lot ' || l_mtlt_lot_number || ' more than transaction qty for that lot');
              END IF;

              x_match  := 4;
            ELSIF l_mtlt_primary_qty > l_att THEN
              IF l_qoh = l_att THEN
                IF (l_debug = 1) THEN
                  mydebug('lpn_match: Qty in LPN for lot ' || l_mtlt_lot_number || ' less than transaction qty for that lot');
                END IF;

                x_match  := 3;
              ELSE
                IF (l_debug = 1) THEN
                  mydebug(
                       'lpn_match: Qty in LPN for lot '
                    || l_mtlt_lot_number
                    || ' less than transaction qty for that lot and lpn is for multiple task'
                  );
                END IF;

                x_match  := 4;
              END IF;
            ELSE
              IF x_match <> 3 THEN
                IF (l_debug = 1) THEN
                  mydebug('lpn_match: qty in LPN for lot ' || l_mtlt_lot_number || ' equal to transaction qty for that lot');
                END IF;

                IF l_qoh = l_att THEN
                  IF (l_debug = 1) THEN
                    mydebug('lpn_match: lpn qoh is equal to att. Exact match');
                  END IF;

                  x_match  := 1;
                ELSE
                  IF (l_debug = 1) THEN
                    mydebug('lpn_match: lpn qoh is great than att. part of lpn is match');
                  END IF;

                  x_match  := 4;
                END IF;
              END IF;
            END IF;
          END IF;

          IF NVL(l_allocated_lpn_id, 0) = p_lpn THEN
            --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
            -- in order to get correct att.
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => l_mtlt_primary_qty
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , p_lpn_id                     => p_lpn
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('lpn_match: update qty tree back 3rd time for lpn l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('lpn_match: calling update qty tree with lpn 3rd time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => l_mtlt_primary_qty
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('lpn_match: after update qty tree back without lpn 3rd time l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('lpn_match: calling update qty tree back without lpn 3rd time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
        END LOOP;

        CLOSE lot_csr;

        IF l_lot_cnt > 0 THEN
          x_match  := 4;
        END IF;

        -- Now that all the lots have been validated, check whether the serial
        -- numbers allocated match the ones in the lpn.

        IF p_is_sn_alloc = 'Y'
           AND p_action = 4
           AND(x_match = 1
               OR x_match = 3) THEN
          SELECT COUNT(fm_serial_number)
            INTO l_total_serial_cnt
            FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
           WHERE mtlt.transaction_temp_id = p_temp_id
             AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;

          IF (l_debug = 1) THEN
            mydebug('lpn_match: SN tot count' || l_total_serial_cnt);
          END IF;

          IF (l_total_serial_cnt = l_serial_exist_cnt) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: LPN matches exactly');
            END IF;

            x_match  := 1;
          ELSIF(l_total_serial_cnt > l_serial_exist_cnt) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: LPN has less');
            END IF;

            x_match  := 3;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('lpn_match: LPN has extra serials');
            END IF;

            x_match  := 4;
          END IF;
        END IF;
      ELSE -- Item is not lot controlled
        IF (l_debug = 1) THEN
          mydebug('lpn_match: Not Lot controlled ..');
        END IF;

        -- Check serial numbers if serial controlled and serial
        -- allocation is turned on

        IF p_is_sn_alloc = 'Y'
           AND p_action = 4 THEN
          IF (l_debug = 1) THEN
            mydebug('lpn_match: SN control and SN allocation on');
          END IF;

          SELECT COUNT(fm_serial_number)
            INTO l_serial_exist_cnt
            FROM mtl_serial_numbers_temp msnt
           WHERE msnt.transaction_temp_id = p_temp_id
             AND msnt.fm_serial_number IN(
                                        SELECT serial_number
                                          FROM mtl_serial_numbers
                                         WHERE lpn_id = p_lpn
                                           AND inventory_item_id = p_item_id
                                           AND NVL(revision, '-999') = NVL(p_rev, '-999'));

          IF (l_debug = 1) THEN
            mydebug('lpn_match: SN exist count' || l_serial_exist_cnt);
          END IF;

          IF (l_serial_exist_cnt = 0) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: LPN does not have the allocated serials ');
            END IF;

            -- Serial numbers missing for the transaction
            x_match  := 9;
            fnd_message.set_name('INV', 'INV_INT_SERMISEXP');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        -- Get qty
        IF (l_debug = 1) THEN
          mydebug('lpn_match:  get lpn quantity ');
        END IF;

        /*SELECT
          quantity,
          uom_code
          INTO
          l_exist_qty,
          l_lpn_uom
          FROM   wms_lpn_contents
          WHERE  parent_lpn_id = p_lpn
          AND    organization_id = p_org_id
          AND    inventory_item_id = p_item_id
          AND    Nvl(cost_group_id,'-999') = Nvl(p_cost_group_id,'-999')
          AND    Nvl(revision,'-999') = Nvl(p_rev,'-999');

        IF (l_debug = 1) THEN
          mydebug('lpn_match: lpn quantity = ' || l_exist_qty );
        END IF;

        IF l_lpn_uom <> l_primary_uom THEN

           l_exist_qty := wms_task_dispatch_gen.get_primary_quantity
       (p_item_id         => p_item_id,
        p_organization_id => p_org_id,
        p_from_quantity   => l_exist_qty,
        p_from_unit       => l_lpn_uom);
        END IF;

        IF (l_debug = 1) THEN
          mydebug('lpn_match:  lpn quantity in correct UOM = ' || l_exist_qty );
          mydebug('lpn_match:  allocated quantity = ' || l_exist_qty );
        END IF;

        IF l_mmtt_qty = l_exist_qty THEN
           -- LPN is a match!
           IF (l_debug = 1) THEN
             mydebug('lpn_match: LPN matched');
           END IF;
           x_match := 1;

         ELSIF l_mmtt_qty > l_exist_qty THEN

           x_match := 3;
           l_lpn_qty := l_exist_qty;

         ELSE

           x_match := 4;

        END IF;*/
        IF NVL(l_allocated_lpn_id, 0) = p_lpn THEN
          --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
          -- in order to get correct att.
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => -l_mmtt_qty
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          , p_lpn_id                     => p_lpn
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: update qty tree with lpn 4th time: l_att:' || l_att);
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('lpn_match: calling update qty tree with lpn 4th time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSE
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => -l_mmtt_qty
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: update qty tree without lpn 4th time:l_att:' || l_att);
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('lpn_match: calling update qty tree without lpn 4th time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        inv_quantity_tree_pub.query_quantities(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_cnt
        , x_msg_data                   => l_msg_data
        , p_organization_id            => p_org_id
        , p_inventory_item_id          => p_item_id
        , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode --??
        , p_is_revision_control        => b_is_revision_control
        , p_is_lot_control             => FALSE
        , p_is_serial_control          => b_is_serial_control
        , p_demand_source_type_id      => -9999
        , p_revision                   => NVL(p_rev, NULL)
        , p_lot_number                 => NULL
        , p_subinventory_code          => l_sub
        , p_locator_id                 => l_loc_id
        , x_qoh                        => l_qoh
        , x_rqoh                       => l_rqoh
        , x_qr                         => l_qr
        , x_qs                         => l_qs
        , x_att                        => l_att
        , x_atr                        => l_atr
        , p_lpn_id                     => p_lpn
        , p_transfer_subinventory_code => l_xfr_sub_code
        );

        IF (l_return_status = fnd_api.g_ret_sts_success) THEN
          IF (l_debug = 1) THEN
            mydebug('lpn_match: lpn quantity ATT= ' || l_att);
       mydebug('lpn_match: lpn quantity QOH= ' || l_qoh);
          END IF;
     x_lpn_qty := l_qoh; --Added bug 3946813

          IF l_mmtt_qty = l_att THEN
            IF l_qoh = l_att THEN
              -- LPN is a match!
              IF (l_debug = 1) THEN
                mydebug('lpn_match: LPN matched');
              END IF;

              x_match  := 1;
            ELSE
              -- LPN is for multiple task
              IF (l_debug = 1) THEN
                mydebug('lpn_match: LPN has multiple task.');
              END IF;

              x_match  := 4;
            END IF;
          ELSIF l_mmtt_qty > l_att THEN
            IF l_qoh = l_att THEN
              IF (l_debug = 1) THEN
                mydebug('lpn_match: lpn has less requested qty and lpn is whole allocation');
              END IF;

              x_match  := 3;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('lpn_match: lpn has less than requested qty and lpn is partial allocation');
              END IF;

              x_match  := 4;
            END IF;

            l_lpn_qty  := l_att;
          ELSE
            x_match  := 4;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('lpn_match: calling qty tree 4th time failed');
          END IF;

          fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
          fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF NVL(l_allocated_lpn_id, 0) = p_lpn THEN
          --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
          -- in order to get correct att.
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => l_mmtt_qty
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          , p_lpn_id                     => p_lpn
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: update qty tree back with lpn 4th time: l_att:' || l_att);
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('lpn_match: calling update qty tree back with lpn 4th time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSE
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => l_mmtt_qty
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: update qty tree back without lpn 4th time:l_att:' || l_att);
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('lpn_match: calling update qty tree back without lpn 4th time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        -- If the LPN quantity exactly matches/ has less than, the requested
        -- quantity then match the serial numbers also

        IF p_is_sn_alloc = 'Y'
           AND p_action = 4
           AND(x_match = 1
               OR x_match = 3) THEN
          SELECT COUNT(fm_serial_number)
            INTO l_total_serial_cnt
            FROM mtl_serial_numbers_temp msnt
           WHERE msnt.transaction_temp_id = p_temp_id;

          IF (l_debug = 1) THEN
            mydebug('lpn_match: SN tot count' || l_total_serial_cnt);
          END IF;

          IF (l_total_serial_cnt = l_serial_exist_cnt) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: LPN matches exactly');
            END IF;

            x_match  := 1;
          ELSIF(l_total_serial_cnt > l_serial_exist_cnt) THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: LPN has less');
            END IF;

            x_match    := 3;
            l_lpn_qty  := l_serial_exist_cnt;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('lpn_match: LPN has extra serials');
            END IF;

            x_match  := 4;
          END IF;
        END IF;

        IF (l_debug = 1) THEN
          mydebug('lpn_match: After 4');
        END IF;
      END IF; -- lot control check
    END IF; -- lpn has only one item

    IF x_match = 1
       OR x_match = 3 THEN
      IF p_action = 4 THEN
        -- serial controlled - CHECK serial status
        IF (l_debug = 1) THEN
          mydebug('lpn_match:  x_match is ' || x_match || ' and item is serial controlled ');
        END IF;

        OPEN ser_csr;

        LOOP
          FETCH ser_csr INTO l_serial_number;
          EXIT WHEN ser_csr%NOTFOUND;

          IF inv_material_status_grp.is_status_applicable(
               p_wms_installed              => p_wms_installed
             , p_trx_status_enabled         => NULL
             , p_trx_type_id                => p_transaction_type_id
             , p_lot_status_enabled         => NULL
             , p_serial_status_enabled      => NULL
             , p_organization_id            => p_org_id
             , p_inventory_item_id          => p_item_id
             , p_sub_code                   => x_sub
             , p_locator_id                 => NULL
             , p_lot_number                 => p_lot
             , p_serial_number              => l_serial_number
             , p_object_type                => 'A'
             ) = 'N' THEN
            IF (l_debug = 1) THEN
              mydebug('lpn_match: After 6');
            END IF;

            x_match  := 11;
            CLOSE ser_csr;
            fnd_message.set_name('INV', 'INV_SER_STATUS_NA');
            fnd_message.set_token('TOKEN', l_serial_number);
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END LOOP;

        CLOSE ser_csr;
      ELSE
        l_serial_number  := NULL;

        -- Check whether the LPN status is applicable for this transaction
        IF inv_material_status_grp.is_status_applicable(
             p_wms_installed              => p_wms_installed
           , p_trx_status_enabled         => NULL
           , p_trx_type_id                => p_transaction_type_id
           , p_lot_status_enabled         => NULL
           , p_serial_status_enabled      => NULL
           , p_organization_id            => p_org_id
           , p_inventory_item_id          => p_item_id
           , p_sub_code                   => x_sub
           , p_locator_id                 => NULL
           , p_lot_number                 => p_lot
           , p_serial_number              => l_serial_number
           , p_object_type                => 'A'
           ) = 'N' THEN
          x_match  := 8;
          -- LPN status is invalid for this operation

          fnd_message.set_name('INV', 'INV_INVALID_LPN_STATUS');
          fnd_message.set_token('TOKEN1', TO_CHAR(p_lpn));
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('lpn_match: x_match : ' || x_match);
      mydebug('lpn_match: p_is_sn_alloc : ' || p_is_sn_alloc);
      mydebug('lpn_match: p_action : ' || p_action);
    END IF;

    /*
       -- Check if Serial Numbers are allocated
       -- Why do you need p_action ?? Wouldn't p_is_sn_alloc suffice ??

       IF (x_match = 1 OR x_match=3) AND p_is_sn_alloc = 'Y' AND p_action = 4 THEN

          l_allocate_serial_flag := 0;

          IF (l_debug = 1) THEN
             mydebug('lpn_match: Before calling SN allocation checking API');
          END IF;
          -- Check if serial numbers are allocated

          OPEN ser_alloc;
          LOOP

             EXIT WHEN ser_alloc%NOTFOUND;

             l_temp_serial_trans_temp := 0;

             FETCH ser_alloc INTO l_temp_serial_trans_temp;

             IF l_temp_serial_trans_temp IS NOT NULL THEN

                IF (l_debug = 1) THEN
                   mydebug('lpn_match: l_temp_serial_trans_temp is not null');
                END IF;
                SELECT 1
                INTO   l_allocate_serial_flag
                FROM   mtl_serial_numbers_temp msnt,
                       mtl_serial_numbers msn
                WHERE  msnt.transaction_temp_id = l_temp_serial_trans_temp
                AND    msn.serial_number = msnt.fm_serial_number
                AND    msn.lpn_id = p_lpn
                AND    ROWNUM = 1;

             ELSE

                IF (l_debug = 1) THEN
                   mydebug('lpn_match: l_temp_serial_trans_temp is null');
                END IF;
                SELECT 1
                INTO   l_allocate_serial_flag
                FROM   mtl_material_transactions_temp mmtt,
                       mtl_serial_numbers_temp msnt,
                       mtl_serial_numbers msn
                WHERE  mmtt.transaction_temp_id = p_temp_id
                AND    mmtt.organization_id = p_org_id
                AND    mmtt.inventory_item_id = p_item_id
                AND    msnt.transaction_temp_id = mmtt.transaction_temp_id
                AND    msn.serial_number = msnt.fm_serial_number
                AND    msn.inventory_item_id = mmtt.inventory_item_id
                AND    msn.lpn_id = p_lpn
                AND    ROWNUM = 1;

             END IF;

          END LOOP;
          CLOSE ser_alloc;

          -- Here we are not checking for the actual number
          -- of serials allocated against the requested quantity.
          -- Just existance of serials is checked.

          IF l_allocate_serial_flag = 0 THEN

             -- Serial records missing for this transaction

             IF (l_debug = 1) THEN
                mydebug('lpn_match: Serial numbers should not be allocated');
             END IF;
             x_match := 9;
             FND_MESSAGE.SET_NAME('INV','INV_INT_SERMISEXP');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;

          END IF;

       END IF;
    */

    -- Call multiple_pick only for lot and serial items. For plain items, it
    -- will anyways be called during load_pick
    IF x_match = 1
       AND(l_lot_code > 1
           OR(p_is_sn_alloc = 'Y'
              AND p_action = 4)) THEN
      IF (l_debug = 1) THEN
        mydebug('lpn_match: MMTT lines need to be split..');
        mydebug('lpn_match: Calling multiple_pick API..');
      END IF;

      /* moved to the begining
      IF p_is_sn_alloc = 'Y' AND p_action = 4 THEN
   l_is_serial_control := 'true';
       ELSE
   l_is_serial_control := 'false';
      END IF;

      IF l_lot_code > 1 THEN
   l_is_lot_control := 'true';
       ELSE
   l_is_lot_control := 'false';
      END IF;

      IF p_rev IS NULL THEN
   l_is_revision_control := 'false';
       ELSE
   l_is_revision_control := 'true';
      END IF;*/
      IF (l_debug = 1) THEN
        mydebug('lpn_match: just before multiple_pick');
      END IF;

      wms_task_dispatch_gen.multiple_pick(
        p_pick_qty                   => p_qty
      , p_org_id                     => p_org_id
      , p_temp_id                    => p_temp_id
      , x_return_status              => l_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_sn_allocated_flag          => p_is_sn_alloc
      , p_act_uom                    => p_uom
      , p_from_lpn                   => l_from_lpn
      , p_from_lpn_id                => p_lpn
      , p_to_lpn                     => '-999'
      , p_ok_to_process              => l_ok_to_process
      , p_is_revision_control        => l_is_revision_control
      , p_is_lot_control             => l_is_lot_control
      , p_is_serial_control          => l_is_serial_control
      , p_act_rev                    => p_rev
      , p_lot                        => NULL
      , p_act_sub                    => l_sub
      , p_act_loc                    => l_loc_id
      , p_container_item_id          => 0
      , p_entire_lpn                 => 'Y'
      , p_pick_qty_remaining         => 0
      , x_temp_id                    => l_out_temp_id
      , p_serial_number              => NULL
      );

      IF (l_debug = 1) THEN
        mydebug('lpn_match: just after multiple_pick: ' || l_return_status);
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          mydebug('lpn_match: Unexpected error in call to multiple_pick');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          mydebug('lpn_match: Error in call to multiple_pick');
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    IF x_match = 3 THEN
      IF (l_debug = 1) THEN
        mydebug('lpn_match: MMTT lines need to be split..');
        mydebug('lpn_match: Calling multiple lpn picking..');
      END IF;

      wms_task_dispatch_gen.multiple_lpn_pick(
        p_lpn_id                     => p_lpn
      , p_lpn_qty                    => l_lpn_qty
      , p_org_id                     => p_org_id
      , p_temp_id                    => p_temp_id
      , x_temp_id                    => l_out_temp_id
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_cnt
      , x_msg_data                   => l_msg_data
      , p_sn_allocated_flag          => p_is_sn_alloc
      , p_uom_code                   => p_uom
      , p_to_lpn_id                  => p_lpn
      , p_entire_lpn                 => 'Y'
      );

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_MULT_LPN_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_MULT_LPN_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug = 1) THEN
        mydebug('lpn_match: AFTER Calling multiple lpn picking..');
      END IF;
    END IF;

    /*IF nvl(l_allocated_lpn_id, 0) = p_lpn THEN
          --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
          -- in order to get correct att.
          inv_quantity_tree_pub.update_quantities
         (  p_api_version_number    =>   1.0
          , p_init_msg_lst          =>   fnd_api.g_false
          , x_return_status         =>   l_return_status
          , x_msg_count             =>   l_msg_cnt
          , x_msg_data              =>   l_msg_data
          , p_organization_id       =>   p_org_id
          , p_inventory_item_id     =>   p_item_id
          , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
          , p_is_revision_control   =>   b_is_revision_control
          , p_is_lot_control        =>   b_is_lot_control
          , p_is_serial_control     =>   b_is_serial_control
          --, p_demand_source_type_id =>   NULL
          , p_revision              =>   p_rev
          , p_lot_number            =>   p_lot
          , p_subinventory_code     =>   l_sub
          , p_locator_id            =>   l_loc_id
          , p_primary_quantity      =>   p_qty
          , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                   =>   l_qoh
          , x_rqoh        =>   l_rqoh
          , x_qr        =>   l_qr
          , x_qs        =>   l_qs
          , x_att         =>   l_att
          , x_atr         =>   l_atr
          , p_lpn_id                =>   p_lpn
              , p_transfer_subinventory_code => l_xfr_sub_code
        );
       ELSE
          inv_quantity_tree_pub.update_quantities
       (  p_api_version_number    =>   1.0
        , p_init_msg_lst          =>   fnd_api.g_false
        , x_return_status         =>   l_return_status
        , x_msg_count             =>   l_msg_cnt
        , x_msg_data              =>   l_msg_data
        , p_organization_id       =>   p_org_id
        , p_inventory_item_id     =>   p_item_id
        , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
        , p_is_revision_control   =>   b_is_revision_control
        , p_is_lot_control        =>   b_is_lot_control
        , p_is_serial_control     =>   b_is_serial_control
      --, p_demand_source_type_id =>   NULL
        , p_revision              =>   p_rev
        , p_lot_number            =>   p_lot
        , p_subinventory_code     =>   l_sub
        , p_locator_id            =>   l_loc_id
        , p_primary_quantity      =>   p_qty
        , p_quantity_type         =>   inv_quantity_tree_pvt.g_qs_txn
        , x_qoh                   =>   l_qoh
        , x_rqoh        =>   l_rqoh
        , x_qr        =>   l_qr
        , x_qs        =>   l_qs
        , x_att         =>   l_att
        , x_atr         =>   l_atr
          --  , p_lpn_id                =>   p_lpn      withour lpn_id, only to locator level
              , p_transfer_subinventory_code => l_xfr_sub_code
        );
    END IF;*/
    l_table_total      := t_lpn_lot_qty_table.COUNT;

    IF l_table_total > 0 THEN
      IF (l_debug = 1) THEN
        mydebug('lpn_match:  building lpn lot vector for ' || l_table_total || ' records');
      END IF;

      FOR l_table_count IN 1 .. l_table_total LOOP
        IF (l_debug = 1) THEN
          mydebug('lpn_match: index is : ' || l_table_count);
        END IF;

        x_lpn_lot_vector  :=
            x_lpn_lot_vector || t_lpn_lot_qty_table(l_table_count).lot_number || '@@@@@' || t_lpn_lot_qty_table(l_table_count).qty
            || '&&&&&';
      END LOOP;
    ELSE
      x_lpn_lot_vector  := NULL;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('lpn_match: LPN QTY ' || l_lpn_qty);
      mydebug('lpn_match: x_temp_id: ' || l_out_temp_id);
    END IF;

    x_temp_id          := l_out_temp_id;
    x_qty              := LEAST(l_lpn_qty, p_qty);
    x_return_status    := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('lpn_match: Match ' || x_match);
    END IF;

    -- added following for bug fix 2769358

    IF x_match = 3 THEN
      IF (l_debug = 1) THEN
        mydebug('Set lpn context to packing for lpn_ID : ' || p_lpn);
      END IF;

      -- Bug5659809: update last_update_date and last_update_by as well
      UPDATE wms_license_plate_numbers
         SET lpn_context = wms_container_pub.lpn_context_packing
           , last_update_date = SYSDATE
           , last_updated_by = fnd_global.user_id
       WHERE lpn_id = p_lpn;
    END IF;
  -- end 2769358

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF (l_debug = 1) THEN
        mydebug('lpn_match:  Exception raised');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('lpn_match: Other exception raised : ' || SQLERRM);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END lpn_match;

  FUNCTION can_pickdrop(txn_temp_id IN NUMBER) RETURN VARCHAR2 IS
    l_ret       VARCHAR2(1) := 'X';
    l_debug     NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    CURSOR c_cancelled_tasks IS
      SELECT decode(mmtt.transaction_type_id, 35,'N',51,'N','Y')
        FROM mtl_material_transactions_temp mmtt, mtl_txn_request_lines mol
       WHERE (mmtt.transaction_temp_id = txn_temp_id OR mmtt.parent_line_id = txn_temp_id)
         AND mmtt.move_order_line_id = mol.line_id
         AND mol.line_status = inv_globals.g_to_status_cancel_by_source
         AND ROWNUM = 1;
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('In CAN_PICKDROP for Transaction Temp ID = ' || txn_temp_id);
    END IF;

    OPEN c_cancelled_tasks;
    FETCH c_cancelled_tasks INTO l_ret;
    IF c_cancelled_tasks%NOTFOUND THEN
      IF l_debug = 1 THEN
        mydebug('Found no Cancelled Task');
      END IF;
      RETURN 'X';
    ELSE
      IF l_debug = 1 THEN
        mydebug('Found Cancelled Tasks');
      END IF;
      RETURN l_ret;
    END IF;
    CLOSE c_cancelled_tasks;
  END;

  PROCEDURE load_pick(
    p_to_lpn              IN            VARCHAR2
  , p_container_item_id   IN            NUMBER
  , p_org_id              IN            NUMBER
  , p_temp_id             IN            NUMBER
  , p_from_lpn            IN            VARCHAR2
  , p_from_lpn_id         IN            NUMBER
  , p_act_sub             IN            VARCHAR2
  , p_act_loc             IN            NUMBER
  , p_entire_lpn          IN            VARCHAR2
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_loc_rsn_id          IN            NUMBER
  , p_qty_rsn_id          IN            NUMBER
  , p_sn_allocated_flag   IN            VARCHAR2
  , p_task_id             IN            NUMBER
  , p_user_id             IN            NUMBER
  , p_qty                 IN            NUMBER
  , p_qty_uom             IN            VARCHAR2
  , p_is_revision_control IN            VARCHAR2
  , p_is_lot_control      IN            VARCHAR2
  , p_is_serial_control   IN            VARCHAR2
  , p_item_id             IN            NUMBER
  , p_act_rev             IN            VARCHAR2
  , p_lot                 IN            VARCHAR2
  , p_ok_to_process       OUT NOCOPY    VARCHAR2
  , p_pick_qty_remaining  IN            NUMBER
  , x_temp_id             OUT NOCOPY    NUMBER
  , p_lots_to_delete      IN            VARCHAR2
  , p_mmtt_to_update      IN            VARCHAR2
  , p_serial_number       IN            VARCHAR2
  , x_out_lpn             OUT NOCOPY    NUMBER
  ) IS
    l_temp_id               NUMBER;
    l_msg_cnt               NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_status         VARCHAR2(240);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot                   VARCHAR2(80);
    l_item_id               NUMBER;
    l_user_id               NUMBER;
    l_to_sub                VARCHAR2(10);
    l_to_loc                NUMBER;
    l_txn_hdr_id            NUMBER;
    l_new_txn_hdr_id        NUMBER;
    l_qty_picked            NUMBER;
    l_qty_uom               VARCHAR2(3);
    l_wf                    NUMBER  := 0;
    l_tabtype               inv_utilities.vector_tabtype;
    l_counter               NUMBER;
    l_transfer_lpn_id       NUMBER;
    l_content_lpn_id        NUMBER;
    l_lpn_id                NUMBER;
    l_to_lpn_id             NUMBER;
    l_to_lpn_exists         NUMBER;
    l_label_status          VARCHAR2(300);
    l_content_parent_lpn_id NUMBER;

    CURSOR mmtt_csr IS
      SELECT mmtt2.transaction_temp_id
           , mmtt1.transaction_uom
           , mmtt2.transaction_uom
           , mmtt2.transaction_quantity
           , mmtt2.primary_quantity
        FROM mtl_material_transactions_temp mmtt1, mtl_material_transactions_temp mmtt2
       WHERE mmtt1.transaction_temp_id = p_temp_id
         AND mmtt1.transaction_header_id = l_txn_hdr_id
         AND mmtt1.organization_id = p_org_id
         AND mmtt2.transaction_header_id = mmtt1.transaction_header_id
         AND mmtt2.organization_id = mmtt1.organization_id
         AND mmtt2.transaction_temp_id <> mmtt1.transaction_temp_id
         AND mmtt2.move_order_line_id = mmtt1.move_order_line_id
         AND NVL(mmtt2.reservation_id, 0) = NVL(mmtt1.reservation_id, 0)
         AND mmtt2.inventory_item_id = mmtt1.inventory_item_id
         AND mmtt2.subinventory_code = mmtt1.subinventory_code
         AND mmtt2.locator_id = mmtt1.locator_id
         AND NVL(mmtt2.transfer_lpn_id, 0) = NVL(mmtt1.transfer_lpn_id, 0)
         AND NVL(mmtt2.content_lpn_id, 0) = NVL(mmtt1.content_lpn_id, 0)
         AND NVL(mmtt2.lpn_id, 0) = NVL(mmtt1.lpn_id, 0);

    l_mmtt2_txn_temp_id     NUMBER;
    l_mmtt1_txn_uom         VARCHAR2(10);
    l_mmtt2_txn_uom         VARCHAR2(10);
    l_mmtt2_txn_qty         NUMBER;
    l_mmtt2_primary_qty     NUMBER;
    l_business_flow_code    NUMBER;
    l_tran_type_id          NUMBER;
    l_tran_source_type_id   NUMBER;
    l_to_lpn_context        NUMBER                       := wms_container_pub.lpn_context_packing;
    l_loaded                NUMBER                       := 0;

    CURSOR mmtt_csr2(p_transaction_header_id NUMBER) IS
      SELECT mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_header_id = p_transaction_header_id;


   l_move_order_line_id         NUMBER; --Bug2924823 H to I
   l_mmtt_transaction_uom       VARCHAR(3);
   l_transaction_qty            NUMBER;
 --l_reservation_id             NUMBER;
   l_mol_uom                    VARCHAR2(3);
   l_mol_delta_qty              NUMBER;
   l_primary_qty                NUMBER;
 --l_detailed_quantity          NUMBER;
   l_debug              NUMBER   :=NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),0);
   l_bulk_pick_flag NUMBER := 0;
  BEGIN
    l_return_status   := fnd_api.g_ret_sts_success;
    x_return_status   := l_return_status;

    mydebug('load_pick : Entered Load Pick');
    l_qty_picked      := p_qty;
    l_qty_uom         := p_qty_uom;
    l_lot             := p_lot;
    l_item_id         := p_item_id;
    l_user_id         := p_user_id;
    -- Initialize p_ok_to_process to TRUE
    p_ok_to_process   := 'true';
    l_to_lpn_exists   := 0;

    SELECT transfer_subinventory
         , transfer_to_location
      INTO l_to_sub
         , l_to_loc
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = p_temp_id;

    BEGIN
      SELECT 1
        INTO l_to_lpn_exists
        FROM wms_license_plate_numbers
       WHERE license_plate_number = p_to_lpn
         AND organization_id = p_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_to_lpn_exists  := 0;
    END;

    IF (l_debug = 1) THEN
      mydebug('load_pick: l_to_lpn_exists : ' || l_to_lpn_exists);
    END IF;

    IF (l_to_lpn_exists = 0) THEN
      -- LPN does not exist, create it
      -- Call Suresh's Create LPN API
      IF (l_debug = 1) THEN
        mydebug('load_pick: Creating LPN. LPN does not exist');
      END IF;

      wms_container_pub.create_lpn(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_cnt
      , x_msg_data                   => l_msg_data
      , p_lpn                        => p_to_lpn
      , p_organization_id            => p_org_id
      , p_container_item_id          => 0
      , p_lot_number                 => l_lot
      , p_revision                   => p_act_rev
      , p_serial_number              => p_serial_number
      , p_subinventory               => l_to_sub
      , p_locator_id                 => l_to_loc
      , p_source                     => 8
      , p_cost_group_id              => NULL
      , x_lpn_id                     => l_to_lpn_id
      );
      fnd_msg_pub.count_and_get(p_count => l_msg_cnt, p_data => l_msg_data);

      IF (l_msg_cnt = 0) THEN
        IF (l_debug = 1) THEN
          mydebug('load_pick: Successful');
        END IF;
      ELSIF(l_msg_cnt = 1) THEN
        IF (l_debug = 1) THEN
          mydebug('load_pick: Not Successful');
          mydebug(REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          mydebug('load_pick: Not Successful2');
        END IF;

        FOR i IN 1 .. l_msg_cnt LOOP
          l_msg_data  := fnd_msg_pub.get(i, 'F');

          IF (l_debug = 1) THEN
            mydebug(REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
          END IF;
        END LOOP;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('load_pick: LPN exists');
      END IF;

      --Check whether the from LPN is loaded already
      --bug 2803936  We should only do the
      --loaded check if entire LPN was picked. Also, we should discount
      -- current temp id

      IF p_entire_lpn = 'Y' THEN -- bug 2803936

                                  --Check whether the from LPN is loaded already
        BEGIN
          SELECT 0
            INTO l_loaded
            FROM DUAL
           WHERE NOT EXISTS(SELECT 1
                              FROM mtl_material_transactions_temp
                             WHERE content_lpn_id = p_from_lpn_id
                               AND transaction_temp_id<>p_temp_id);

          IF (l_debug = 1) THEN
            mydebug('load_pick: LPN ' || p_from_lpn_id || ' hasnot been loaded already');
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            l_loaded  := 1;

            IF (l_debug = 1) THEN
              mydebug('load_pick: LPN ' || p_from_lpn_id || ' has been already loaded so error out');
            END IF;

            fnd_message.set_name('WMS', 'WMS_LPN_LOADED_ERROR');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
        END;
      END IF;

      -- LPN exists. Get LPN ID
      SELECT lpn_id
           , lpn_context
        INTO l_to_lpn_id
           , l_to_lpn_context
        FROM wms_license_plate_numbers
       WHERE license_plate_number = p_to_lpn
         AND organization_id = p_org_id;
    END IF;

    x_out_lpn         := l_to_lpn_id;

    -- Removed following check for bug 2769358
--    IF l_to_lpn_context = wms_container_pub.lpn_context_pregenerated THEN
      --
      -- Update the context to "Packing context" (8)
      --
      -- Bug5659809: update last_update_date and last_update_by as well
      UPDATE wms_license_plate_numbers
         SET lpn_context = wms_container_pub.lpn_context_packing
           , last_update_date = SYSDATE
           , last_updated_by = fnd_global.user_id
       WHERE lpn_id = l_to_lpn_id;
--    END IF;

    IF p_is_lot_control = 'true'
       OR p_is_serial_control = 'true' THEN
      IF (l_debug = 1) THEN
        mydebug('load_pick : Either lot or serial control. Will not call multiple_pick');
      END IF;

      x_temp_id  := p_temp_id;
      inv_utilities.parse_vector(vector_in => p_mmtt_to_update, delimiter => ':', table_of_strings => l_tabtype);

      FOR l_counter IN 0 ..(l_tabtype.COUNT - 1) LOOP
        IF (l_debug = 1) THEN
          mydebug('load_pick : MMTT about to update' || l_tabtype(l_counter) || ':');
        END IF;

        IF p_from_lpn_id <> 0 THEN
          IF p_entire_lpn = 'Y' THEN
            IF (l_debug = 1) THEN
              mydebug('load_pick : Entire LPN');
            END IF;

            l_transfer_lpn_id  := l_to_lpn_id;
            l_lpn_id           := NULL;
            l_content_lpn_id   := p_from_lpn_id;

            -- for nested LPNs selected for picking items from:start
            IF (l_debug = 1) THEN
              mydebug('load_pick: getting outermost LPN for selected lpn ON PKLP');
            END IF;

            SELECT parent_lpn_id
              INTO l_content_parent_lpn_id
              FROM wms_license_plate_numbers
             WHERE lpn_id = p_from_lpn_id
               AND organization_id = p_org_id;

            IF (l_debug = 1) THEN
              mydebug('load_pick: outermost LPN for the selected LPN::' || l_content_parent_lpn_id);
            END IF;

            IF (l_content_parent_lpn_id <> p_from_lpn_id) THEN
              IF (l_debug = 1) THEN
                mydebug('load_pick: setting lpn_id in MMTT to outermost LPN for nested LPN from PKLP');
              END IF;

              l_lpn_id  := l_content_parent_lpn_id; --TM will take care of this
            END IF;
          -- for nested LPNs selected for picking items from:ends

          ELSE
            IF (l_debug = 1) THEN
              mydebug('load_pick : Partial LPN');
            END IF;

            l_transfer_lpn_id  := l_to_lpn_id;
            l_content_lpn_id   := NULL;
            l_lpn_id           := p_from_lpn_id;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('load_pick : Picked loose');
          END IF;

          l_transfer_lpn_id  := l_to_lpn_id;
          l_content_lpn_id   := NULL;
          l_lpn_id           := NULL;
        END IF;

        IF (l_debug = 1) THEN
          mydebug('load_pick : transfer_lpn_id :' || l_transfer_lpn_id);
          mydebug('load_pick : lpn_id :' || l_lpn_id);
          mydebug('load_pick : content_lpn_id :' || l_content_lpn_id);
        END IF;

        -- added following for bug fix 2769358

        IF l_content_lpn_id IS NOT NULL THEN
          IF (l_debug = 1) THEN
            mydebug('Set lpn context to packing for lpn_ID : ' || l_content_lpn_id);
          END IF;

          -- Bug5659809: update last_update_date and last_update_by as well
          UPDATE wms_license_plate_numbers
             SET lpn_context = wms_container_pub.lpn_context_packing
               , last_update_date = SYSDATE
               , last_updated_by = fnd_global.user_id
           WHERE lpn_id = l_content_lpn_id;
        END IF;

        -- end bug fix 2769358

        UPDATE mtl_material_transactions_temp
           SET transfer_lpn_id = l_transfer_lpn_id
             , content_lpn_id = l_content_lpn_id
             , lpn_id = l_lpn_id
         WHERE transaction_temp_id = l_tabtype(l_counter);

        -- Also update WDT to loaded status

        UPDATE wms_dispatched_tasks
           SET status = 4
             , loaded_time = SYSDATE
             , --loaded_time=to_date(to_char(sysdate,'DD-MON-YYYY HH:MI:SS'),'DD-MON-YYYY HH:MI:SS'),
               last_update_date = SYSDATE
             , last_updated_by = l_user_id
         WHERE transaction_temp_id = l_tabtype(l_counter);
      END LOOP;
    ELSE
      IF (l_qty_picked = 0) THEN
        IF (l_debug = 1) THEN
          mydebug('load_pick :Picked qty is 0, doesnot need to call multiple_pick');
        END IF;

        x_temp_id        := p_temp_id;
        p_ok_to_process  := 'true';
      ELSE
        IF (l_debug = 1) THEN
          mydebug('load_pick : Neither lot nor serial control. Calling multiple_pick');
        END IF;

        wms_task_dispatch_gen.multiple_pick(
          p_pick_qty                   => l_qty_picked
        , p_org_id                     => p_org_id
        , p_temp_id                    => p_temp_id
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_sn_allocated_flag          => p_sn_allocated_flag
        , p_act_uom                    => p_qty_uom
        , p_from_lpn                   => p_from_lpn
        , p_from_lpn_id                => p_from_lpn_id
        , p_to_lpn                     => p_to_lpn
        , p_ok_to_process              => p_ok_to_process
        , p_is_revision_control        => p_is_revision_control
        , p_is_lot_control             => p_is_lot_control
        , p_is_serial_control          => p_is_serial_control
        , p_act_rev                    => p_act_rev
        , p_lot                        => p_lot
        , p_act_sub                    => p_act_sub
        , p_act_loc                    => p_act_loc
        , p_container_item_id          => p_container_item_id
        , p_entire_lpn                 => p_entire_lpn
        , p_pick_qty_remaining         => p_pick_qty_remaining
        , x_temp_id                    => x_temp_id
        , p_serial_number              => p_serial_number
        );

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    IF p_ok_to_process = 'false' THEN
      x_temp_id  := 0;
      RETURN;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('Load_Pick:user id before' || l_user_id);
    END IF;

    SELECT transaction_header_id
         , --last_updated_by,Bug 2672785:Wrong value being fetched for user_id
           inventory_item_id
         , lot_number
         , transaction_type_id
         , transaction_source_type_id
      INTO l_txn_hdr_id
         , --l_user_id,
           l_item_id
         , l_lot
         , l_tran_type_id
         , l_tran_source_type_id
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = x_temp_id;

    IF (l_debug = 1) THEN
      mydebug('load_pick : Transaction_temp_id : ' || x_temp_id);
      mydebug('load_pick : Transaction_header_id: ' || l_txn_hdr_id);
      mydebug('Load_Pick: User id: ' || l_user_id);
    END IF;

    -- Log Exception

    IF p_qty_rsn_id > 0 THEN
      IF (l_debug = 1) THEN
        mydebug('load_pick : Qty Discrepancy exists');
      END IF;

      wms_txnrsn_actions_pub.log_exception(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_cnt
      , x_msg_data                   => l_msg_data
      , p_organization_id            => p_org_id
      , p_mmtt_id                    => l_txn_hdr_id
      , p_task_id                    => l_txn_hdr_id
      , p_reason_id                  => p_qty_rsn_id
      , p_subinventory_code          => p_act_sub
      , p_locator_id                 => p_act_loc
      , p_discrepancy_type           => 1
      , p_user_id                    => l_user_id
      , p_item_id                    => l_item_id
      , p_revision                   => p_act_rev
      , p_lot_number                 => l_lot
      );

      IF (l_debug = 1) THEN
        mydebug('after logging exception for qty discrepancy');
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    IF p_loc_rsn_id > 0 THEN
      IF (l_debug = 1) THEN
        mydebug('load_pick : Loc Discrepancy exists');
        mydebug('Load_pick : user id' || l_user_id);
      END IF;

      wms_txnrsn_actions_pub.log_exception(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_cnt
      , x_msg_data                   => l_msg_data
      , p_organization_id            => p_org_id
      , p_mmtt_id                    => l_txn_hdr_id
      , p_task_id                    => l_txn_hdr_id
      , p_reason_id                  => p_loc_rsn_id
      , p_subinventory_code          => p_act_sub
      , p_locator_id                 => p_act_loc
      , p_discrepancy_type           => 1
      , p_user_id                    => l_user_id
      , p_item_id                    => l_item_id
      , p_revision                   => p_act_rev
      , p_lot_number                 => l_lot
      , p_is_loc_desc           => TRUE  --Added bug 3989684
      );

      IF (l_debug = 1) THEN
        mydebug('after logging exception for loc discrepancy');
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    l_wf              := 0;

    BEGIN
      SELECT 1
        INTO l_wf
        FROM mtl_transaction_reasons
       WHERE reason_id = p_qty_rsn_id
         AND workflow_name IS NOT NULL
         AND workflow_name <> ' '
         AND workflow_process IS NOT NULL
         AND workflow_process <> ' ';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_wf  := 0;
    END;

    IF l_wf > 0 THEN
      IF (l_debug = 1) THEN
        mydebug(' load_pick : WF exists for this reason code');
        mydebug(' load_pick : Before Calling WF Wrapper for Qty  Discrepancy ');
      END IF;

      -- Calling Workflow

      IF p_qty_rsn_id > 0 THEN
        IF (l_debug = 1) THEN
          mydebug('load_pick: Calling Jefri... workflow wrapper');
        END IF;

        wms_workflow_wrappers.wf_wrapper(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_cnt
        , x_msg_data                   => l_msg_data
        , p_org_id                     => p_org_id
        , p_rsn_id                     => p_qty_rsn_id
        , p_calling_program            => 'wms_task_dispatch_gen.load_pick'
        , p_tmp_id                     => p_temp_id
        , p_quantity_picked            => l_qty_picked
        , p_dest_sub                   => p_act_sub
        , p_dest_loc                   => p_act_loc
        );
      END IF;

      IF (l_debug = 1) THEN
        mydebug('load_pick : After Calling WF Wrapper');
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          mydebug('load_pick : Error callinf WF wrapper');
        END IF;

        fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          mydebug('load_pick : Error calling WF wrapper');
        END IF;

        fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Clean up code. Have to delete MMTT, MTLT, MSNT, WDT, if picked less
    -- and update move order line

    IF p_is_lot_control = 'true' THEN
      IF (l_debug = 1) THEN
        mydebug('load_pick : lot controlled');
      END IF;

      inv_utilities.parse_vector(vector_in => p_lots_to_delete, delimiter => ':', table_of_strings => l_tabtype);

      FOR l_counter IN 0 ..(l_tabtype.COUNT - 1) LOOP
        IF (l_debug = 1) THEN
          mydebug('load_pick : ' || l_tabtype(l_counter));
        END IF;

        IF p_is_serial_control = 'true' THEN
          UPDATE mtl_serial_numbers
             SET group_mark_id = NULL
           WHERE inventory_item_id = l_item_id
             AND current_organization_id = p_org_id
             AND serial_number IN(SELECT fm_serial_number
                                    FROM mtl_serial_numbers_temp
                                   WHERE transaction_temp_id IN(SELECT transaction_temp_id
                                                                  FROM mtl_transaction_lots_temp
                                                                 WHERE lot_number = l_tabtype(l_counter)
                                                                   AND transaction_temp_id = p_temp_id));

          DELETE FROM mtl_serial_numbers_temp
                WHERE transaction_temp_id IN(SELECT transaction_temp_id
                                               FROM mtl_transaction_lots_temp
                                              WHERE lot_number = l_tabtype(l_counter)
                                                AND transaction_temp_id = p_temp_id);
        END IF;

        DELETE FROM mtl_transaction_lots_temp
              WHERE lot_number = l_tabtype(l_counter)
                AND transaction_temp_id = p_temp_id;
      END LOOP;
    END IF;

    IF p_is_serial_control = 'true' THEN
      IF p_qty_rsn_id > 0 THEN
        -- Deleting serials which have not been picked

        UPDATE mtl_serial_numbers msn
           SET msn.group_mark_id = NULL
         WHERE msn.inventory_item_id = l_item_id
           AND msn.current_organization_id = p_org_id
           AND msn.group_mark_id = p_temp_id
           AND msn.serial_number IN(SELECT msnt.fm_serial_number
                                      FROM mtl_serial_numbers_temp msnt
                                     WHERE msnt.transaction_temp_id = p_temp_id);

        DELETE FROM mtl_serial_numbers_temp msnt
              WHERE msnt.transaction_temp_id = p_temp_id
                AND msnt.fm_serial_number IN(
                            SELECT msn.serial_number
                              FROM mtl_serial_numbers msn
                             WHERE msn.inventory_item_id = l_item_id
                               AND msn.current_organization_id = p_org_id
                               AND msn.group_mark_id IS NULL);
      END IF;
    END IF;

    -- Find if bulk pick task or not. If bulk pick task we will have to
    -- loop thru the move orer lines AND decrement quantity one BY one
    l_bulk_pick_flag  := 0;

    BEGIN
      SELECT 1
        INTO l_bulk_pick_flag
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM mtl_material_transactions_temp mmtt
                     WHERE mmtt.parent_line_id = p_temp_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_bulk_pick_flag  := 0;
    END;

    -- Code to merge MMTT line if all qty has been picked
    -- Note: Merging MMTT only for same reservation IDs. Will not work for
    -- detailed reseravtion

    IF p_pick_qty_remaining = 0 THEN
      IF (l_debug = 1) THEN
        mydebug('load_pick: About to merge MMTT lines');
      END IF;

      OPEN mmtt_csr;

      LOOP
        FETCH mmtt_csr INTO l_mmtt2_txn_temp_id, l_mmtt1_txn_uom, l_mmtt2_txn_uom, l_mmtt2_txn_qty, l_mmtt2_primary_qty;
        EXIT WHEN mmtt_csr%NOTFOUND;

        IF (l_debug = 1) THEN
          mydebug('load_pick: About to merge MMTT ' || l_mmtt2_txn_temp_id || ' with MMTT ' || p_temp_id);
        END IF;

        IF l_mmtt1_txn_uom <> l_mmtt2_txn_uom THEN
          l_mmtt2_txn_qty  :=
            inv_convert.inv_um_convert(
              item_id                      => l_item_id
            , PRECISION                    => NULL
            , from_quantity                => l_mmtt2_txn_qty
            , from_unit                    => l_mmtt2_txn_uom
            , to_unit                      => l_mmtt1_txn_uom
            , from_name                    => NULL
            , to_name                      => NULL
            );
        END IF;

        -- Merge MMTT, MTLT, MSNT

        UPDATE mtl_material_transactions_temp
           SET transaction_quantity = transaction_quantity + l_mmtt2_txn_qty
             , primary_quantity = primary_quantity + l_mmtt2_primary_qty
         WHERE transaction_temp_id = p_temp_id;

        IF p_is_lot_control = 'true' THEN
          UPDATE mtl_transaction_lots_temp
             SET transaction_temp_id = p_temp_id
           WHERE transaction_temp_id = l_mmtt2_txn_temp_id;
        ELSIF p_is_serial_control = 'true' THEN
          UPDATE mtl_serial_numbers_temp
             SET transaction_temp_id = p_temp_id
           WHERE transaction_temp_id = l_mmtt2_txn_temp_id;
        END IF;

        DELETE FROM mtl_material_transactions_temp
              WHERE transaction_temp_id = l_mmtt2_txn_temp_id;

        DELETE FROM wms_dispatched_tasks
              WHERE transaction_temp_id = l_mmtt2_txn_temp_id;
      END LOOP;

      CLOSE mmtt_csr;

      IF l_bulk_pick_flag <> 0 THEN
        bulk_pick(
          p_temp_id                    => p_temp_id
        , p_txn_hdr_id                 => l_txn_hdr_id
        , p_org_id                     => p_org_id
        , p_pick_qty_remaining         => p_pick_qty_remaining
        , p_user_id                    => p_user_id
        , x_new_txn_hdr_id             => l_new_txn_hdr_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
   , p_reason_id                  => p_qty_rsn_id  --Added bug 3765153
        );

        IF x_return_status = 'U' THEN
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status = 'E' THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        l_txn_hdr_id  := l_new_txn_hdr_id;
      END IF;
    END IF;

   IF p_pick_qty_remaining <> 0 THEN
     IF (l_debug = 1) THEN
       mydebug('load_pick: Updating move order line with reduced quantity');
     END IF;

     IF l_bulk_pick_flag = 0 THEN
       -- Not a bulk pick task Bug 2924823 H to I

                 BEGIN
                   SELECT transaction_uom
                         ,transaction_quantity
                         ,move_order_line_id
                    INTO  l_mmtt_transaction_uom
                         ,l_transaction_qty
                         , l_move_order_line_id
                    FROM  mtl_material_transactions_temp
                   WHERE  transaction_temp_id = p_temp_id;

                   mydebug('load_pick:
transaction_uom:'||l_mmtt_transaction_uom);
                   EXCEPTION
                     WHEN OTHERS THEN
                    l_mmtt_transaction_uom := null;
                    l_move_order_line_id := null;
                    mydebug('load_pick: others exception encounted in selecting
mmtt transaction uom code ');
                END;

                 if l_move_order_line_id is not null then




                 BEGIN
                  SELECT uom_code INTO  l_mol_uom
                  FROM  mtl_txn_request_lines
                  WHERE line_id = l_move_order_line_id;

                  mydebug('load_pick: l_mol_uom_code: '||l_mol_uom);
                 EXCEPTION
                    WHEN OTHERS THEN
                    l_mol_uom := null;
                   mydebug('load_pick: others exception enchounted in selecting move order uom code');
                END;

                 if (l_mmtt_transaction_uom is not null) and (l_mol_uom is not null ) then
                    mydebug('l_mmtt_transaction_uom and l_mol_uom both are not null');
                   if (l_mmtt_transaction_uom <> l_mol_uom ) then
                      mydebug('load_pick: mmtt transaction uom is different from mol uom');
                  l_mol_delta_qty := INV_Convert.inv_um_convert
                      (item_id         => l_item_id,
                       precision       => null,
                        from_quantity   => l_transaction_qty,
                       from_unit       => l_mmtt_transaction_uom,
                       to_unit         => l_mol_uom,
                       from_name       => null,
                       to_name         => null);
             else
                mydebug('load_pick: mmtt transaction uom is the same as mol');
                  l_mol_delta_qty := l_transaction_qty;
                   end if;
                      mydebug('load_pick: l_mol_detal_qty:'||l_mol_delta_qty);
             else
               mydebug('load_pick: either l_mmtt_transaction_uom or l_mol_uom
null');
              end if;
             else
               mydebug('load_pick: l_move_order_line_id is null');
            end if;

            mydebug('load_pick: Deleting MMTT');
-- merging from H

       DELETE FROM mtl_material_transactions_temp
        WHERE transaction_temp_id = p_temp_id;

           mydebug('load_pick: Updating move order line with reduced quantity');

                mydebug('load_pick: Updating move order line with reduced
quantity');

                update mtl_txn_request_lines
                   set quantity_detailed = quantity_detailed - l_mol_delta_qty
                 where line_id = l_move_order_line_id;

                mydebug('load_pick: after updating move order line detailed
quantity');
                DELETE FROM wms_dispatched_tasks
                WHERE transaction_temp_id = p_temp_id;


     ELSE
       DELETE FROM mtl_material_transactions_temp
        WHERE transaction_temp_id = p_temp_id;

            update mtl_material_transactions_temp
            set transaction_temp_id=p_temp_id
            where transaction_temp_id=x_temp_id;    --Added bug 3765153

       bulk_pick(
     p_temp_id                    => p_temp_id
        , p_txn_hdr_id                 => l_txn_hdr_id
        , p_org_id                     => p_org_id
        , p_pick_qty_remaining         => p_pick_qty_remaining
        , p_user_id                    => p_user_id
        , x_new_txn_hdr_id             => l_new_txn_hdr_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
   , p_reason_id                  => p_qty_rsn_id  --Added bug 3765153
        );

        IF x_return_status = 'U' THEN
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status = 'E' THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        l_txn_hdr_id  := l_new_txn_hdr_id;

      IF (l_debug = 1) THEN
        mydebug('load_pick: archiving task');
      END IF;

      DELETE FROM wms_dispatched_tasks
            WHERE transaction_temp_id = p_temp_id;
    END IF;
 END IF;
    IF (l_debug = 1) THEN
      mydebug('load_pick : Calling the label printing API');
    END IF;

    BEGIN
      l_business_flow_code  := inv_label.wms_bf_pick_load;

      IF l_tran_type_id = 52 THEN -- Picking for sales order
        l_business_flow_code  := inv_label.wms_bf_pick_load;
      ELSIF l_tran_type_id = 35 THEN -- WIP issue
        l_business_flow_code  := inv_label.wms_bf_wip_pick_load;
      ELSIF l_tran_type_id = 51
            AND l_tran_source_type_id = 13 THEN --Backflush
        l_business_flow_code  := inv_label.wms_bf_wip_pick_load;
      ELSIF l_tran_type_id = 64
            AND l_tran_source_type_id = 4 THEN --Replenishment
        l_business_flow_code  := inv_label.wms_bf_replenishment_load;
      END IF;
/*Added if else  for 3451284. We will print labels for only this transaction temp id , except in the case of bulk pick
where will continue with the old code of using transaction header id*/
      IF (l_bulk_pick_flag = 0) THEN --if its not a bulk pick task only print lable for the transaction temp id.

      /*Bug#4113235. we need to call  the label printing api with the transaction_temp_id of the new
         MMTT created after splitting the original MMTT in case of short pick */
        IF (l_debug = 1) THEN
          mydebug('load_pick: Calling label printing for transaction:' || x_temp_id);
        END IF;

        inv_label.print_label_wrap(
          x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , x_label_status               => l_label_status
        , p_business_flow_code         => l_business_flow_code
        , p_transaction_id             => x_temp_id  --Changed bug#4113235.
        );

        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
          IF (l_debug = 1) THEN
            mydebug('load_pick: Label printing failed. Continue');
          END IF;
        END IF;
      ELSE -- old code print labels based on heade id.
      OPEN mmtt_csr2(l_txn_hdr_id);

      LOOP
        FETCH mmtt_csr2 INTO l_temp_id;
        EXIT WHEN mmtt_csr2%NOTFOUND;

        IF (l_debug = 1) THEN
          mydebug('load_pick: Calling label printing for transaction:' || l_temp_id);
        END IF;

        inv_label.print_label_wrap(
          x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , x_label_status               => l_label_status
        , p_business_flow_code         => l_business_flow_code
        , p_transaction_id             => l_temp_id
        );

        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
          IF (l_debug = 1) THEN
            mydebug('load_pick: Label printing failed. Continue');
          END IF;
        END IF;
      END LOOP;

      CLOSE mmtt_csr2;
    END IF;--end onf bulk pick or not bulk pick.
    END;

    IF (l_debug = 1) THEN
      mydebug('load_pick: End of load_pick');
    END IF;

    x_return_status   := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug(' p_ok_to_process: ' || p_ok_to_process);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('load_pick: Error in load_pick API: ' || SQLERRM);
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('load_pick: Unexpected Error in load_pick API: ' || SQLERRM);
      END IF;
  END load_pick;

  PROCEDURE insert_mmtt_pack(
    p_temp_id           IN            NUMBER
  , p_lpn_id            IN            NUMBER
  , p_transfer_lpn      IN            VARCHAR2
  , p_container_item_id IN            NUMBER
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  ) IS
    l_mmtt_rec          inv_mo_line_detail_util.g_mmtt_rec;
    l_temp_id           NUMBER;
    l_lpn_id            NUMBER;
    l_transfer_lpn_id   NUMBER;
    l_new_temp_id       NUMBER;
    l_lpn               VARCHAR2(30);
    l_exist_lpn         NUMBER;
    l_cost_group_id     NUMBER;
    l_container_item_id NUMBER;
    l_org_id            NUMBER;
    l_msg_cnt           NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_return_status     VARCHAR2(1);
    l_rows              NUMBER;
    l_loc               NUMBER;
    l_sub               VARCHAR2(10);
    l_debug             NUMBER                             := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_return_status      := fnd_api.g_ret_sts_success;
    l_temp_id            := p_temp_id;
    l_lpn_id             := p_lpn_id;
    l_lpn                := p_transfer_lpn;
    l_container_item_id  := p_container_item_id;

    IF l_container_item_id = 0 THEN
      l_container_item_id  := NULL;
    END IF;

    -- Check to see if LPN exists

    IF (l_lpn IS NULL
        OR l_lpn = '') THEN
      l_lpn_id  := NULL;

      IF (l_debug = 1) THEN
        mydebug('insert_mmtt_pack: No LPN was passed');
      END IF;
    ELSE
      SELECT transfer_cost_group_id
           , organization_id
           , transfer_subinventory
           , transfer_to_location
        INTO l_cost_group_id
           , l_org_id
           , l_sub
           , l_loc
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = l_temp_id;

      l_exist_lpn  := 0;

      /* SELECT COUNT(*)  INTO l_exist_lpn
   FROM WMS_LICENSE_PLATE_NUMBERS
   WHERE license_plate_number=l_lpn
   AND organization_id=l_org_id;*/
      BEGIN
        SELECT 1
          INTO l_exist_lpn
          FROM DUAL
         WHERE EXISTS(SELECT 1
                        FROM wms_license_plate_numbers
                       WHERE license_plate_number = l_lpn
                         AND organization_id = l_org_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_exist_lpn  := 0;
      END;

      IF (l_exist_lpn = 0) THEN
        -- LPN does not exist, create it
        -- Call Suresh's Create LPN API
        IF (l_debug = 1) THEN
          mydebug('insert_mmtt_pack: Creating LPN');
        END IF;

        wms_container_pub.create_lpn(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_cnt
        , x_msg_data                   => l_msg_data
        , p_lpn                        => l_lpn
        , p_organization_id            => l_org_id
        , p_container_item_id          => l_container_item_id
        , p_lot_number                 => NULL
        , p_revision                   => NULL
        , p_serial_number              => NULL
        , p_subinventory               => l_sub
        , p_locator_id                 => l_loc
        , p_source                     => 1
        , p_cost_group_id              => NULL
        , x_lpn_id                     => l_transfer_lpn_id
        );
        fnd_msg_pub.count_and_get(p_count => l_msg_cnt, p_data => l_msg_data);

        IF (l_msg_cnt = 0) THEN
          IF (l_debug = 1) THEN
            mydebug('insert_mmtt_pack: Successful');
          END IF;
        ELSIF(l_msg_cnt = 1) THEN
          IF (l_debug = 1) THEN
            mydebug('insert_mmtt_pack: Not Successful');
            mydebug(REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('insert_mmtt_pack: Not Successful2');
          END IF;

          FOR i IN 1 .. l_msg_cnt LOOP
            l_msg_data  := fnd_msg_pub.get(i, 'F');

            IF (l_debug = 1) THEN
              mydebug(REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
            END IF;
          END LOOP;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE
        -- LPN exists. Get LPN ID
        SELECT lpn_id
          INTO l_transfer_lpn_id
          FROM wms_license_plate_numbers
         WHERE license_plate_number = l_lpn
           AND organization_id = l_org_id;
      END IF;
    END IF;

    SELECT mtl_material_transactions_s.NEXTVAL
      INTO l_new_temp_id
      FROM DUAL;

    INSERT INTO mtl_material_transactions_temp
                (
                 transaction_header_id
               , transaction_temp_id
               , source_code
               , source_line_id
               , transaction_mode
               , lock_flag
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , request_id
               , program_application_id
               , program_id
               , program_update_date
               , inventory_item_id
               , revision
               , organization_id
               , subinventory_code
               , locator_id
               , transaction_quantity
               , primary_quantity
               , transaction_uom
               , transaction_cost
               , transaction_type_id
               , transaction_action_id
               , transaction_source_type_id
               , transaction_source_id
               , transaction_source_name
               , transaction_date
               , acct_period_id
               , distribution_account_id
               , transaction_reference
               , requisition_line_id
               , requisition_distribution_id
               , reason_id
               , lot_number
               , lot_expiration_date
               , serial_number
               , receiving_document
               , demand_id
               , rcv_transaction_id
               , move_transaction_id
               , completion_transaction_id
               , wip_entity_type
               , schedule_id
               , repetitive_line_id
               , employee_code
               , primary_switch
               , schedule_update_code
               , setup_teardown_code
               , item_ordering
               , negative_req_flag
               , operation_seq_num
               , picking_line_id
               , trx_source_line_id
               , trx_source_delivery_id
               , physical_adjustment_id
               , cycle_count_id
               , rma_line_id
               , customer_ship_id
               , currency_code
               , currency_conversion_rate
               , currency_conversion_type
               , currency_conversion_date
               , ussgl_transaction_code
               , vendor_lot_number
               , encumbrance_account
               , encumbrance_amount
               , ship_to_location
               , shipment_number
               , transfer_cost
               , transportation_cost
               , transportation_account
               , freight_code
               , containers
               , waybill_airbill
               , expected_arrival_date
               , transfer_subinventory
               , transfer_organization
               , transfer_to_location
               , new_average_cost
               , value_change
               , percentage_change
               , material_allocation_temp_id
               , demand_source_header_id
               , demand_source_line
               , demand_source_delivery
               , item_segments
               , item_description
               , item_trx_enabled_flag
               , item_location_control_code
               , item_restrict_subinv_code
               , item_restrict_locators_code
               , item_revision_qty_control_code
               , item_primary_uom_code
               , item_uom_class
               , item_shelf_life_code
               , item_shelf_life_days
               , item_lot_control_code
               , item_serial_control_code
               , item_inventory_asset_flag
               , allowed_units_lookup_code
               , department_id
               , department_code
               , wip_supply_type
               , supply_subinventory
               , supply_locator_id
               , valid_subinventory_flag
               , valid_locator_flag
               , locator_segments
               , current_locator_control_code
               , number_of_lots_entered
               , wip_commit_flag
               , next_lot_number
               , lot_alpha_prefix
               , next_serial_number
               , serial_alpha_prefix
               , shippable_flag
               , posting_flag
               , required_flag
               , process_flag
               , ERROR_CODE
               , error_explanation
               , attribute_category
               , attribute1
               , attribute2
               , attribute3
               , attribute4
               , attribute5
               , attribute6
               , attribute7
               , attribute8
               , attribute9
               , attribute10
               , attribute11
               , attribute12
               , attribute13
               , attribute14
               , attribute15
               , movement_id
               , reservation_quantity
               , shipped_quantity
               , transaction_line_number
               , task_id
               , to_task_id
               , source_task_id
               , project_id
               , source_project_id
               , pa_expenditure_org_id
               , to_project_id
               , expenditure_type
               , final_completion_flag
               , transfer_percentage
               , transaction_sequence_id
               , material_account
               , material_overhead_account
               , resource_account
               , outside_processing_account
               , overhead_account
               , flow_schedule
               , cost_group_id
               , demand_class
               , qa_collection_id
               , kanban_card_id
               , overcompletion_transaction_id
               , overcompletion_primary_qty
               , overcompletion_transaction_qty
               , end_item_unit_number
               , scheduled_payback_date
               , line_type_code
               , parent_transaction_temp_id
               , put_away_strategy_id
               , put_away_rule_id
               , pick_strategy_id
               , pick_rule_id
               , common_bom_seq_id
               , common_routing_seq_id
               , cost_type_id
               , org_cost_group_id
               , move_order_line_id
               , task_group_id
               , pick_slip_number
               , reservation_id
               , transaction_status
               , transfer_cost_group_id
               , lpn_id
               , transfer_lpn_id
               , content_lpn_id
               , operation_plan_id
               , transaction_batch_id
               , transaction_batch_seq
                )
      (SELECT transaction_header_id
            , l_new_temp_id
            , source_code
            , source_line_id
            , transaction_mode
            , lock_flag
            , last_update_date
            , last_updated_by
            , creation_date
            , created_by
            , last_update_login
            , request_id
            , program_application_id
            , program_id
            , program_update_date
            , inventory_item_id
            , revision
            , organization_id
            , transfer_subinventory
            , transfer_to_location
            , 1
            , 1
            , transaction_uom
            , transaction_cost
            , inv_globals.g_type_container_pack
            , 50
            , 13
            , NULL
            , NULL
            , SYSDATE
            , acct_period_id
            , distribution_account_id
            , transaction_reference
            , requisition_line_id
            , requisition_distribution_id
            , reason_id
            , lot_number
            , lot_expiration_date
            , serial_number
            , receiving_document
            , demand_id
            , rcv_transaction_id
            , move_transaction_id
            , completion_transaction_id
            , wip_entity_type
            , schedule_id
            , repetitive_line_id
            , employee_code
            , primary_switch
            , schedule_update_code
            , setup_teardown_code
            , item_ordering
            , negative_req_flag
            , operation_seq_num
            , picking_line_id
            , trx_source_line_id
            , trx_source_delivery_id
            , physical_adjustment_id
            , cycle_count_id
            , rma_line_id
            , customer_ship_id
            , currency_code
            , currency_conversion_rate
            , currency_conversion_type
            , currency_conversion_date
            , ussgl_transaction_code
            , vendor_lot_number
            , encumbrance_account
            , encumbrance_amount
            , ship_to_location
            , shipment_number
            , transfer_cost
            , transportation_cost
            , transportation_account
            , freight_code
            , containers
            , waybill_airbill
            , expected_arrival_date
            , transfer_subinventory
            , transfer_organization
            , transfer_to_location
            , new_average_cost
            , value_change
            , percentage_change
            , material_allocation_temp_id
            , demand_source_header_id
            , demand_source_line
            , demand_source_delivery
            , item_segments
            , item_description
            , item_trx_enabled_flag
            , item_location_control_code
            , item_restrict_subinv_code
            , item_restrict_locators_code
            , item_revision_qty_control_code
            , item_primary_uom_code
            , item_uom_class
            , item_shelf_life_code
            , item_shelf_life_days
            , item_lot_control_code
            , item_serial_control_code
            , item_inventory_asset_flag
            , allowed_units_lookup_code
            , department_id
            , department_code
            , wip_supply_type
            , supply_subinventory
            , supply_locator_id
            , valid_subinventory_flag
            , valid_locator_flag
            , locator_segments
            , current_locator_control_code
            , number_of_lots_entered
            , wip_commit_flag
            , next_lot_number
            , lot_alpha_prefix
            , next_serial_number
            , serial_alpha_prefix
            , shippable_flag
            , posting_flag
            , required_flag
            , process_flag
            , ERROR_CODE
            , error_explanation
            , attribute_category
            , attribute1
            , attribute2
            , attribute3
            , attribute4
            , attribute5
            , attribute6
            , attribute7
            , attribute8
            , attribute9
            , attribute10
            , attribute11
            , attribute12
            , attribute13
            , attribute14
            , attribute15
            , movement_id
            , reservation_quantity
            , shipped_quantity
            , transaction_line_number
            , task_id
            , to_task_id
            , source_task_id
            , project_id
            , source_project_id
            , pa_expenditure_org_id
            , to_project_id
            , expenditure_type
            , final_completion_flag
            , transfer_percentage
            , transaction_sequence_id
            , material_account
            , material_overhead_account
            , resource_account
            , outside_processing_account
            , overhead_account
            , flow_schedule
            , cost_group_id
            , demand_class
            , qa_collection_id
            , kanban_card_id
            , overcompletion_transaction_id
            , overcompletion_primary_qty
            , overcompletion_transaction_qty
            , end_item_unit_number
            , scheduled_payback_date
            , line_type_code
            , parent_transaction_temp_id
            , put_away_strategy_id
            , put_away_rule_id
            , pick_strategy_id
            , pick_rule_id
            , common_bom_seq_id
            , common_routing_seq_id
            , cost_type_id
            , org_cost_group_id
            , NULL
            , task_group_id
            , pick_slip_number
            , NULL
            , transaction_status
            , transfer_cost_group_id
            , lpn_id
            , l_transfer_lpn_id
            , l_lpn_id
            , operation_plan_id
            , transaction_header_id
            , l_new_temp_id
         FROM mtl_material_transactions_temp
        WHERE transaction_temp_id = l_temp_id);

    x_return_status      := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END insert_mmtt_pack;

  PROCEDURE change_lpn(
    p_org_id        IN            NUMBER
  , p_container     IN            NUMBER
  , p_lpn_name      IN            VARCHAR2 --New LPN
  , p_sug_lpn_name  IN            VARCHAR2
  , x_ret           OUT NOCOPY    NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  ) IS
    l_org_id         NUMBER;
    l_container      NUMBER;
    l_lpn_name       VARCHAR2(60);
    l_sug_lpn_name   VARCHAR2(60);
    l_ret            NUMBER;
    l_exist_lpn      NUMBER;
    l_exist_lpn2     NUMBER;
    l_lpn_id         NUMBER;
    l_return_status  VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_cnt        NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_exist_contents NUMBER;
    b_can_modify     BOOLEAN;
    l_sug_lpn_id     NUMBER;
    l_debug          NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('In change lpn');
    END IF;

    l_org_id          := p_org_id;
    l_container       := p_container;
    l_lpn_name        := p_lpn_name;
    l_sug_lpn_name    := p_sug_lpn_name;
    l_ret             := 0;
    l_exist_lpn       := 0;
    l_exist_lpn2      := 0;
    l_exist_contents  := 0;
    b_can_modify      := TRUE;

    /*
       -- get sug lpn id
          SELECT lpn_id  INTO l_sug_lpn_id
      FROM WMS_LICENSE_PLATE_NUMBERS
      WHERE license_plate_number=l_sug_lpn_name
      AND organization_id=l_org_id;
    */
       --Bug#2095232
       -- get new lpn id instead of suggested one
    SELECT lpn_id
      INTO l_lpn_id
      FROM wms_license_plate_numbers
     WHERE license_plate_number = l_lpn_name
       AND organization_id = l_org_id;

    IF (l_lpn_name IS NULL) THEN
      IF (l_debug = 1) THEN
        mydebug('license plate number not changed');
      END IF;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('license plate number changed');
      END IF;

      l_exist_lpn  := 0;

      /* SELECT COUNT(*)  INTO l_exist_lpn
   FROM WMS_LICENSE_PLATE_NUMBERS
   WHERE license_plate_number=l_lpn_name
   AND organization_id=l_org_id
   AND lpn_context<>wms_container_pub.lpn_context_packing;*/
      BEGIN
        SELECT 1
          INTO l_exist_lpn
          FROM DUAL
         WHERE EXISTS(
                 SELECT 1
                   FROM wms_license_plate_numbers
                  WHERE license_plate_number = l_lpn_name
                    AND organization_id = l_org_id
                    AND lpn_context <> wms_container_pub.lpn_context_packing);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_exist_lpn  := 0;
      END;

      IF (l_exist_lpn > 0) THEN
        -- LPN exists.Cannot use
        b_can_modify  := FALSE;
        l_ret         := 2;
      ELSE
        -- Check to see if the suggested lpn has contents already
        -- if yes, we cannot modify
        l_exist_lpn2  := 0;

        /* SELECT COUNT(*)  INTO l_exist_lpn2
           FROM wms_license_plate_numbers w, wms_lpn_contents c
           WHERE w.license_plate_number=l_sug_lpn_name
           AND w.organization_id=l_org_id
           AND w.lpn_id=c.parent_lpn_id;*/
        BEGIN
          SELECT 1
            INTO l_exist_lpn2
            FROM DUAL
           WHERE EXISTS(SELECT 1
                          FROM wms_license_plate_numbers w, wms_lpn_contents c
                         WHERE w.license_plate_number = l_sug_lpn_name
                           AND w.organization_id = l_org_id
                           AND w.lpn_id = c.parent_lpn_id);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_exist_lpn2  := 0;
        END;

        IF (l_exist_lpn2 > 0) THEN
          -- Sug LPN has contents.Cannot modify, treat as new
          b_can_modify  := FALSE;
          l_ret         := 1;
        END IF;
      END IF;
    END IF;

    -- Only need to call


    IF (b_can_modify) THEN
      -- LPN does not exist,we can update it
      IF (l_debug = 1) THEN
        mydebug('Modifying LPN: b_can_modify = TRUE');
      END IF;

      wms_container_pub.modify_lpn_wrapper(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_cnt
      , x_msg_data                   => l_msg_data
      , p_lpn_id                     => l_lpn_id
      , --Bug#2095232
        p_license_plate_number       => l_lpn_name
      , p_inventory_item_id          => l_container
      , p_weight_uom_code            => NULL
      , p_gross_weight               => NULL
      , p_volume_uom_code            => NULL
      , p_content_volume             => NULL
      , p_status_id                  => NULL
      , p_lpn_context                => wms_container_pub.lpn_context_packing
      , p_sealed_status              => NULL
      , p_organization_id            => l_org_id
      , p_subinventory               => NULL
      , p_locator_id                 => NULL
      , p_source_type_id             => NULL
      , p_source_header_id           => NULL
      , p_source_name                => NULL
      , p_source_line_id             => NULL
      , p_source_line_detail_id      => NULL
      );

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_MODIFY_LPN_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_MODIFY_LPN_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    x_ret             := l_ret;
    x_return_status   := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END change_lpn;

  PROCEDURE multiple_lpn_pick(
    p_lpn_id            IN            NUMBER
  , p_lpn_qty           IN            NUMBER
  , p_org_id            IN            NUMBER
  , p_temp_id           IN            NUMBER
  , x_temp_id           OUT NOCOPY    NUMBER
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  , p_sn_allocated_flag IN            VARCHAR2
  , p_uom_code          IN            VARCHAR2
  , p_to_lpn_id         IN            NUMBER
  , p_entire_lpn        IN            VARCHAR2
  ) IS
    l_lpn_id                NUMBER;
    l_org_id                NUMBER;
    l_temp_id               NUMBER;
    l_msg_cnt               NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_status         VARCHAR2(1);
    l_rows                  NUMBER;
    l_cost_group_id         NUMBER;
    l_loc                   NUMBER;
    l_sub                   VARCHAR2(10);
    l_user_loc              NUMBER;
    l_user_sub              VARCHAR2(10);
    l_from_lpn_id           NUMBER;
    l_ser_temp_id           VARCHAR2(30);
    l_serial_number         VARCHAR2(30);
    l_qty                   NUMBER;
    l_uom                   VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot                   VARCHAR2(80);
    l_pr_qty                NUMBER;
    l_item_id               NUMBER;
    l_lot_code              NUMBER;
    l_serial_code           NUMBER;
    l_ser_seq               NUMBER;
    l_user_id               NUMBER;
    l_mo_line_id            NUMBER;
    l_orig_qty              NUMBER;
    l_new_temp_id           NUMBER;
    l_next_task_id          NUMBER;
    l_lpn_cnt               NUMBER;
    l_txn_header_id         NUMBER;

    CURSOR lpn_ser_cur(v_lot_number VARCHAR2) IS
      SELECT serial_number
        FROM mtl_serial_numbers
       WHERE lpn_id = p_lpn_id
         AND NVL(lot_number, 'NONE') = NVL(v_lot_number, 'NONE');

    CURSOR lpn_lot_cur IS
      SELECT lot_number
           , quantity
           , uom_code
        FROM wms_lpn_contents
       WHERE parent_lpn_id = p_lpn_id;

    CURSOR mtlt_lot_cur(v_lot_number VARCHAR2) IS
      SELECT *
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_temp_id
         AND lot_number = v_lot_number;

-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lpn_lot_number        VARCHAR2(80);
    l_lpn_lot_qty           NUMBER;
    l_lpn_lot_primary_qty   NUMBER;
    l_lpn_uom_code          VARCHAR2(3);
    l_lot_primary_qty       NUMBER;
    l_mtlt_rec              mtl_transaction_lots_temp%ROWTYPE;
    l_allocate_serial_flag  NUMBER                              := 0;
    l_new_serial_temp_id    NUMBER;
    l_lot_serial_temp_id    NUMBER;
    l_temp_lpn_id           NUMBER;
    l_transfer_lpn_id       NUMBER;
    l_content_lpn_id        NUMBER;
    l_to_lpn_id             NUMBER;
    l_test_qty              NUMBER;
    l_content_parent_lpn_id NUMBER;
    l_debug                 NUMBER                              := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_lpn_sub  VARCHAR2(30);                   --Added bug3765153
    l_lpn_loc  NUMBER;               --Added bug3765153
  BEGIN
    SAVEPOINT sp_multiple_lpn_pick;
    l_return_status  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('multiple_lpn_pick: p_lpn_id = ' || p_lpn_id);
      mydebug('multiple_lpn_pick: p_temp_id = ' || p_temp_id);
      mydebug('multiple_lpn_pick: p_org_id = ' || p_org_id);
      mydebug('multiple_lpn_pick: p_lpn_qty = ' || p_lpn_qty);
      mydebug('multiple_lpn_pick: p_uom_code = ' || p_uom_code);
      mydebug('multiple_lpn_pick: p_sn_allocated_flag = ' || p_sn_allocated_flag);
    END IF;

    l_lpn_id         := p_lpn_id;
    l_org_id         := p_org_id;
    l_temp_id        := p_temp_id;
    l_to_lpn_id      := p_to_lpn_id;

    IF p_entire_lpn = 'Y' THEN
      -- for nested LPNs selected for picking items from:start
      IF (l_debug = 1) THEN
        mydebug('multiple_lpn_pick: getting outermost LPN for selected lpn ON PKLP');
      END IF;

      --Modifying the below sql to also get the data of sub and loc from the LPN in case of multiple pick bug3765153
      SELECT parent_lpn_id,subinventory_code,locator_id
        INTO l_content_parent_lpn_id,l_lpn_sub,l_lpn_loc
        FROM wms_license_plate_numbers
       WHERE lpn_id = l_lpn_id
         AND organization_id = p_org_id;

      IF (l_debug = 1) THEN
        mydebug('multiple_lpn_pick: outermost LPN for the selected LPN::' || l_content_parent_lpn_id);
      END IF;

      IF (l_content_parent_lpn_id <> l_lpn_id) THEN
        IF (l_debug = 1) THEN
          mydebug('multiple_lpn_pick: setting lpn_id in MMTT to outermost LPN for nested LPN from PKLP');
        END IF;

        l_lpn_id  := l_content_parent_lpn_id; --TM will take care of this
      END IF;

      -- for nested LPNs selected for picking items from:end

      l_temp_lpn_id      := NULL;
      l_transfer_lpn_id  := l_lpn_id;
      l_content_lpn_id   := l_lpn_id;
    ELSE
      l_temp_lpn_id      := l_lpn_id;
      l_transfer_lpn_id  := l_to_lpn_id;
      l_content_lpn_id   := NULL;
    END IF;

    SELECT transfer_cost_group_id
         , transfer_subinventory
         , transfer_to_location
         , lot_number
         , transaction_quantity
         , transaction_uom
         , inventory_item_id
         , last_updated_by
         , move_order_line_id
      INTO l_cost_group_id
         , l_sub
         , l_loc
         , l_lot
         , l_orig_qty
         , l_uom
         , l_item_id
         , l_user_id
         , l_mo_line_id
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = l_temp_id;

    IF l_uom = p_uom_code THEN
      l_qty  := p_lpn_qty;
    ELSE
      l_qty  :=
        inv_convert.inv_um_convert(
          item_id                      => l_item_id
        , PRECISION                    => NULL
        , from_quantity                => p_lpn_qty
        , from_unit                    => p_uom_code
        , to_unit                      => l_uom
        , from_name                    => NULL
        , to_name                      => NULL
        );

      IF (l_debug = 1) THEN
        mydebug('multiple_lpn_pick: l_qty = ' || l_qty);
      END IF;
    END IF;

    -- Calculate Primary Quantity

    l_pr_qty         :=
      wms_task_dispatch_gen.get_primary_quantity(p_item_id => l_item_id, p_organization_id => l_org_id, p_from_quantity => l_qty
      , p_from_unit                  => l_uom);

    IF (l_debug = 1) THEN
      mydebug('multiple_lpn_pick: l_pr_qty = ' || l_pr_qty);
    END IF;

    -- Create new MMTT line with qty and primary qty in the LPN, content_lpn_id, transfer_lpn_id

    SELECT mtl_material_transactions_s.NEXTVAL
      INTO l_new_temp_id
      FROM DUAL;

    IF (l_debug = 1) THEN
      mydebug('multiple_lpn_pick: l_new_temp_id = ' || l_new_temp_id);
    END IF;

    INSERT INTO mtl_material_transactions_temp
                (
                 transaction_header_id
               , transaction_temp_id
               , source_code
               , source_line_id
               , transaction_mode
               , lock_flag
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , request_id
               , program_application_id
               , program_id
               , program_update_date
               , inventory_item_id
               , revision
               , organization_id
               , subinventory_code
               , locator_id
               , transaction_quantity
               , primary_quantity
               , transaction_uom
               , transaction_cost
               , transaction_type_id
               , transaction_action_id
               , transaction_source_type_id
               , transaction_source_id
               , transaction_source_name
               , transaction_date
               , acct_period_id
               , distribution_account_id
               , transaction_reference
               , requisition_line_id
               , requisition_distribution_id
               , reason_id
               , lot_number
               , lot_expiration_date
               , serial_number
               , receiving_document
               , demand_id
               , rcv_transaction_id
               , move_transaction_id
               , completion_transaction_id
               , wip_entity_type
               , schedule_id
               , repetitive_line_id
               , employee_code
               , primary_switch
               , schedule_update_code
               , setup_teardown_code
               , item_ordering
               , negative_req_flag
               , operation_seq_num
               , picking_line_id
               , trx_source_line_id
               , trx_source_delivery_id
               , physical_adjustment_id
               , cycle_count_id
               , rma_line_id
               , customer_ship_id
               , currency_code
               , currency_conversion_rate
               , currency_conversion_type
               , currency_conversion_date
               , ussgl_transaction_code
               , vendor_lot_number
               , encumbrance_account
               , encumbrance_amount
               , ship_to_location
               , shipment_number
               , transfer_cost
               , transportation_cost
               , transportation_account
               , freight_code
               , containers
               , waybill_airbill
               , expected_arrival_date
               , transfer_subinventory
               , transfer_organization
               , transfer_to_location
               , new_average_cost
               , value_change
               , percentage_change
               , material_allocation_temp_id
               , demand_source_header_id
               , demand_source_line
               , demand_source_delivery
               , item_segments
               , item_description
               , item_trx_enabled_flag
               , item_location_control_code
               , item_restrict_subinv_code
               , item_restrict_locators_code
               , item_revision_qty_control_code
               , item_primary_uom_code
               , item_uom_class
               , item_shelf_life_code
               , item_shelf_life_days
               , item_lot_control_code
               , item_serial_control_code
               , item_inventory_asset_flag
               , allowed_units_lookup_code
               , department_id
               , department_code
               , wip_supply_type
               , supply_subinventory
               , supply_locator_id
               , valid_subinventory_flag
               , valid_locator_flag
               , locator_segments
               , current_locator_control_code
               , number_of_lots_entered
               , wip_commit_flag
               , next_lot_number
               , lot_alpha_prefix
               , next_serial_number
               , serial_alpha_prefix
               , shippable_flag
               , posting_flag
               , required_flag
               , process_flag
               , ERROR_CODE
               , error_explanation
               , attribute_category
               , attribute1
               , attribute2
               , attribute3
               , attribute4
               , attribute5
               , attribute6
               , attribute7
               , attribute8
               , attribute9
               , attribute10
               , attribute11
               , attribute12
               , attribute13
               , attribute14
               , attribute15
               , movement_id
               , reservation_quantity
               , shipped_quantity
               , transaction_line_number
               , task_id
               , to_task_id
               , source_task_id
               , project_id
               , source_project_id
               , pa_expenditure_org_id
               , to_project_id
               , expenditure_type
               , final_completion_flag
               , transfer_percentage
               , transaction_sequence_id
               , material_account
               , material_overhead_account
               , resource_account
               , outside_processing_account
               , overhead_account
               , flow_schedule
               , cost_group_id
               , demand_class
               , qa_collection_id
               , kanban_card_id
               , overcompletion_transaction_id
               , overcompletion_primary_qty
               , overcompletion_transaction_qty
               , end_item_unit_number
               , scheduled_payback_date
               , line_type_code
               , parent_transaction_temp_id
               , put_away_strategy_id
               , put_away_rule_id
               , pick_strategy_id
               , pick_rule_id
               , common_bom_seq_id
               , common_routing_seq_id
               , cost_type_id
               , org_cost_group_id
               , move_order_line_id
               , task_group_id
               , pick_slip_number
               , reservation_id
               , transaction_status
               , transfer_cost_group_id
               , lpn_id
               , transfer_lpn_id
               , content_lpn_id
               , cartonization_id
               , standard_operation_id
               , wms_task_type
               , task_priority
               , container_item_id
               , operation_plan_id
                )
      (SELECT transaction_header_id
            , l_new_temp_id
            , source_code
            , source_line_id
            , transaction_mode
            , lock_flag
            , SYSDATE
            , l_user_id
            , SYSDATE
            , l_user_id
            , last_update_login
            , request_id
            , program_application_id
            , program_id
            , program_update_date
            , inventory_item_id
            , revision
            , organization_id
            , l_lpn_sub                  --, subinventory_code changed to LPN's sub bug3765153
            , l_lpn_loc                  --, locator_id changed to LPN's sub bug3765153
            , l_qty
            , l_pr_qty
            , transaction_uom
            , transaction_cost
            , transaction_type_id
            , transaction_action_id
            , transaction_source_type_id
            , transaction_source_id
            , transaction_source_name
            , transaction_date
            , acct_period_id
            , distribution_account_id
            , transaction_reference
            , requisition_line_id
            , requisition_distribution_id
            , reason_id
            , lot_number
            , lot_expiration_date
            , serial_number
            , receiving_document
            , demand_id
            , rcv_transaction_id
            , move_transaction_id
            , completion_transaction_id
            , wip_entity_type
            , schedule_id
            , repetitive_line_id
            , employee_code
            , primary_switch
            , schedule_update_code
            , setup_teardown_code
            , item_ordering
            , negative_req_flag
            , operation_seq_num
            , picking_line_id
            , trx_source_line_id
            , trx_source_delivery_id
            , physical_adjustment_id
            , cycle_count_id
            , rma_line_id
            , customer_ship_id
            , currency_code
            , currency_conversion_rate
            , currency_conversion_type
            , currency_conversion_date
            , ussgl_transaction_code
            , vendor_lot_number
            , encumbrance_account
            , encumbrance_amount
            , ship_to_location
            , shipment_number
            , transfer_cost
            , transportation_cost
            , transportation_account
            , freight_code
            , containers
            , waybill_airbill
            , expected_arrival_date
            , transfer_subinventory
            , transfer_organization
            , transfer_to_location
            , new_average_cost
            , value_change
            , percentage_change
            , material_allocation_temp_id
            , demand_source_header_id
            , demand_source_line
            , demand_source_delivery
            , item_segments
            , item_description
            , item_trx_enabled_flag
            , item_location_control_code
            , item_restrict_subinv_code
            , item_restrict_locators_code
            , item_revision_qty_control_code
            , item_primary_uom_code
            , item_uom_class
            , item_shelf_life_code
            , item_shelf_life_days
            , item_lot_control_code
            , item_serial_control_code
            , item_inventory_asset_flag
            , allowed_units_lookup_code
            , department_id
            , department_code
            , wip_supply_type
            , supply_subinventory
            , supply_locator_id
            , valid_subinventory_flag
            , valid_locator_flag
            , locator_segments
            , current_locator_control_code
            , number_of_lots_entered
            , wip_commit_flag
            , next_lot_number
            , lot_alpha_prefix
            , next_serial_number
            , serial_alpha_prefix
            , shippable_flag
            , posting_flag
            , required_flag
            , process_flag
            , ERROR_CODE
            , error_explanation
            , attribute_category
            , attribute1
            , attribute2
            , attribute3
            , attribute4
            , attribute5
            , attribute6
            , attribute7
            , attribute8
            , attribute9
            , attribute10
            , attribute11
            , attribute12
            , attribute13
            , attribute14
            , attribute15
            , movement_id
            , reservation_quantity
            , shipped_quantity
            , transaction_line_number
            , task_id
            , to_task_id
            , source_task_id
            , project_id
            , source_project_id
            , pa_expenditure_org_id
            , to_project_id
            , expenditure_type
            , final_completion_flag
            , transfer_percentage
            , transaction_sequence_id
            , material_account
            , material_overhead_account
            , resource_account
            , outside_processing_account
            , overhead_account
            , flow_schedule
            , cost_group_id
            , demand_class
            , qa_collection_id
            , kanban_card_id
            , overcompletion_transaction_id
            , overcompletion_primary_qty
            , overcompletion_transaction_qty
            , end_item_unit_number
            , scheduled_payback_date
            , line_type_code
            , parent_transaction_temp_id
            , put_away_strategy_id
            , put_away_rule_id
            , pick_strategy_id
            , pick_rule_id
            , common_bom_seq_id
            , common_routing_seq_id
            , cost_type_id
            , org_cost_group_id
            , move_order_line_id
            , task_group_id
            , pick_slip_number
            , reservation_id
            , transaction_status
            , transfer_cost_group_id
            , l_temp_lpn_id
            , l_transfer_lpn_id
            , l_content_lpn_id
            , cartonization_id
            , standard_operation_id
            , wms_task_type
            , task_priority
            , container_item_id
            , operation_plan_id
         FROM mtl_material_transactions_temp
        WHERE transaction_temp_id = l_temp_id);

    -- Update original MMTT with the remaining transaction and primary qty

    UPDATE mtl_material_transactions_temp
       SET transaction_quantity = transaction_quantity - l_qty
         , primary_quantity = primary_quantity - l_pr_qty
     WHERE transaction_temp_id = l_temp_id;

    IF (l_debug = 1) THEN
      mydebug('multiple_lpn_pick: after updating mmtt ');
    END IF;

    SELECT lot_control_code
         , serial_number_control_code
      INTO l_lot_code
         , l_serial_code
      FROM mtl_system_items
     WHERE organization_id = l_org_id
       AND inventory_item_id = l_item_id;

    IF (l_debug = 1) THEN
      mydebug('multiple_lpn_pick: l_lot_code = ' || l_lot_code);
      mydebug('multiple_lpn_pick: l_serial_code = ' || l_serial_code);
    END IF;

    IF l_lot_code > 1 THEN -- lot controlled
      IF (l_debug = 1) THEN
        mydebug('multiple_lpn_pick: Inserting Lots');
      END IF;

      IF (l_serial_code > 1
          AND l_serial_code <> 6) -- lot serial controlled
         AND p_sn_allocated_flag = 'Y' -- and allocate to serial ON
                                       THEN
        IF (l_debug = 1) THEN
          mydebug('multiple_lpn_pick: lot/serial controlled and allocate to serial ON');
        END IF;

        OPEN lpn_lot_cur;

        LOOP -- loop through all lot numbers within this LPN
          FETCH lpn_lot_cur INTO l_lpn_lot_number, l_lpn_lot_qty, l_lpn_uom_code;
          EXIT WHEN lpn_lot_cur%NOTFOUND;

          IF (l_debug = 1) THEN
            mydebug('multiple_lpn_pick: Lpn Record: ');
          END IF;

          IF (l_debug = 1) THEN
            mydebug('multiple_lpn_pick: l_lpn_lot_number = ' || l_lpn_lot_number);
            mydebug('multiple_lpn_pick: l_lpn_lot_qty = ' || l_lpn_lot_qty);
            mydebug('multiple_lpn_pick: l_lpn_uom_code = ' || l_lpn_uom_code);
          END IF;

          OPEN mtlt_lot_cur(l_lpn_lot_number);

          LOOP -- loop through mtlt for the lot number in this lpn contents
            FETCH mtlt_lot_cur INTO l_mtlt_rec;
            l_lot_primary_qty      := l_mtlt_rec.primary_quantity;
            l_lot_serial_temp_id   := l_mtlt_rec.serial_transaction_temp_id;
            EXIT WHEN mtlt_lot_cur%NOTFOUND;

            IF (l_debug = 1) THEN
              mydebug('multiple_lpn_pick: MTLT Record: ');
              mydebug('multiple_lpn_pick: l_lot_primary_qty = ' || l_lot_primary_qty);
            END IF;

            l_lpn_lot_primary_qty  :=
              wms_task_dispatch_gen.get_primary_quantity(p_item_id => l_item_id, p_organization_id => l_org_id
              , p_from_quantity              => l_lpn_lot_qty, p_from_unit => l_lpn_uom_code);

            IF (l_debug = 1) THEN
              mydebug('multiple_lpn_pick: l_lpn_lot_primary_qty = ' || l_lpn_lot_primary_qty);
            END IF;

            IF l_lot_primary_qty > l_lpn_lot_primary_qty THEN
              -- need to create a new mtlt record and link it to the new mmtt
              IF (l_debug = 1) THEN
                mydebug('multiple_lpn_pick:  create new mtlt');
              END IF;

              l_mtlt_rec.transaction_temp_id         := l_new_temp_id;
              l_mtlt_rec.primary_quantity            := l_lpn_lot_primary_qty;
              l_mtlt_rec.transaction_quantity        := l_lpn_lot_primary_qty *(l_qty / l_pr_qty);

              -- get new serial_transaction_id

              SELECT mtl_material_transactions_s.NEXTVAL
                INTO l_new_serial_temp_id
                FROM DUAL;

              l_mtlt_rec.serial_transaction_temp_id  := l_new_serial_temp_id;

              IF (l_debug = 1) THEN
                mydebug('multiple_lpn_pick: l_new_temp_id = ' || l_new_temp_id);
                mydebug('multiple_lpn_pick: primary_quantity = ' || l_mtlt_rec.primary_quantity);
                mydebug('multiple_lpn_pick: transaction_quantity = ' || l_mtlt_rec.transaction_quantity);
                mydebug('multiple_lpn_pick: l_new_serial_temp_id = ' || l_new_serial_temp_id);
              END IF;

              inv_rcv_common_apis.insert_mtlt(l_mtlt_rec);
              OPEN lpn_ser_cur(l_mtlt_rec.lot_number);

              LOOP
                FETCH lpn_ser_cur INTO l_serial_number;
                EXIT WHEN lpn_ser_cur%NOTFOUND;

                UPDATE mtl_serial_numbers_temp
                   SET transaction_temp_id = l_new_serial_temp_id
                 WHERE transaction_temp_id = l_lot_serial_temp_id
                   AND fm_serial_number = l_serial_number
                   AND to_serial_number = l_serial_number;
              END LOOP;

              CLOSE lpn_ser_cur;

              -- also update the original mtlt record with remaining qty

              UPDATE mtl_transaction_lots_temp
                 SET primary_quantity = primary_quantity - l_mtlt_rec.primary_quantity
                   , transaction_quantity = transaction_quantity - l_mtlt_rec.transaction_quantity
               WHERE transaction_temp_id = p_temp_id
                 AND lot_number = l_lpn_lot_number;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('multiple_lpn_pick:  link original mtlt to new mmtt');
              END IF;

              -- link the original mtlt to new mmtt
              UPDATE mtl_transaction_lots_temp
                 SET transaction_temp_id = l_new_temp_id
               WHERE transaction_temp_id = p_temp_id
                 AND lot_number = l_lpn_lot_number;
            END IF;
          END LOOP;

          CLOSE mtlt_lot_cur;
        END LOOP;

        CLOSE lpn_lot_cur;
      ELSE    -- lot controlled only OR lot seial controlled but Allocate to
           --    serial OFF
        IF (l_debug = 1) THEN
          mydebug('multiple_lpn_pick: lot controlled only OR lot seial controlled but Allocate to serial OFF');
        END IF;

        OPEN lpn_lot_cur;

        LOOP -- loop through all lot numbers within this LPN
          FETCH lpn_lot_cur INTO l_lpn_lot_number, l_lpn_lot_qty, l_lpn_uom_code;
          EXIT WHEN lpn_lot_cur%NOTFOUND;

          IF (l_debug = 1) THEN
            mydebug('multiple_lpn_pick: Lpn Record');
          END IF;

          IF (l_debug = 1) THEN
            mydebug('multiple_lpn_pick: l_lpn_lot_number = ' || l_lpn_lot_number);
            mydebug('multiple_lpn_pick: l_lpn_lot_qty = ' || l_lpn_lot_qty);
            mydebug('multiple_lpn_pick: l_lpn_uom_code = ' || l_lpn_uom_code);
          END IF;

          OPEN mtlt_lot_cur(l_lpn_lot_number);

          LOOP -- loop through mtlt for the lot number in this lpn contents
            FETCH mtlt_lot_cur INTO l_mtlt_rec;
            l_lot_primary_qty      := l_mtlt_rec.primary_quantity;
            l_lot_serial_temp_id   := l_mtlt_rec.serial_transaction_temp_id;
            EXIT WHEN mtlt_lot_cur%NOTFOUND;

            IF (l_debug = 1) THEN
              mydebug('multiple_lpn_pick: MTLT Record');
              mydebug('multiple_lpn_pick: l_lot_primary_qty = ' || l_lot_primary_qty);
            END IF;

            l_lpn_lot_primary_qty  :=
              wms_task_dispatch_gen.get_primary_quantity(p_item_id => l_item_id, p_organization_id => l_org_id
              , p_from_quantity              => l_lpn_lot_qty, p_from_unit => l_lpn_uom_code);

            IF (l_debug = 1) THEN
              mydebug('multiple_lpn_pick: l_lpn_lot_primary_qty = ' || l_lpn_lot_primary_qty);
            END IF;

            IF l_lot_primary_qty > l_lpn_lot_primary_qty THEN
              IF (l_debug = 1) THEN
                mydebug('multiple_lpn_pick: need to create a new mtlt record and link it to the new mmtt');
              END IF;

              /* Moved the selection of serial temp id here */
              IF (l_serial_code > 1
                  AND l_serial_code <> 6) THEN
                SELECT mtl_material_transactions_s.NEXTVAL
                  INTO l_new_serial_temp_id
                  FROM DUAL;

                l_mtlt_rec.serial_transaction_temp_id  := l_new_serial_temp_id;
              ELSE
                l_new_serial_temp_id  := NULL;
              END IF;

              IF (l_debug = 1) THEN
                mydebug('multiple_lpn_pick:  create new mtlt');
              END IF;

              l_mtlt_rec.transaction_temp_id   := l_new_temp_id;
              l_mtlt_rec.primary_quantity      := l_lpn_lot_primary_qty;
              l_mtlt_rec.transaction_quantity  := l_lpn_lot_primary_qty *(l_qty / l_pr_qty);

              IF (l_debug = 1) THEN
                mydebug('multiple_lpn_pick: l_new_temp_id = ' || l_new_temp_id);
                mydebug('multiple_lpn_pick: primary_quantity = ' || l_mtlt_rec.primary_quantity);
                mydebug('multiple_lpn_pick: transaction_quantity = ' || l_mtlt_rec.transaction_quantity);
              END IF;

              inv_rcv_common_apis.insert_mtlt(l_mtlt_rec);

              IF (l_debug = 1) THEN
                mydebug('multiple_lpn_pick: l_new_serial_temp_id = ' || l_new_serial_temp_id);
              END IF;

              -- also update the original mtlt record with remaining

              IF (l_debug = 1) THEN
                mydebug('multiple_lpn_pick: PriMQty' || l_mtlt_rec.primary_quantity);
              END IF;

              UPDATE mtl_transaction_lots_temp
                 SET primary_quantity = primary_quantity - l_mtlt_rec.primary_quantity
                   , transaction_quantity = transaction_quantity - l_mtlt_rec.transaction_quantity
               WHERE transaction_temp_id = p_temp_id
                 AND lot_number = l_lpn_lot_number;

              /* AND Nvl(serial_transaction_temp_id,0) = Nvl(l_new_serial_temp_id,Nvl(serial_transaction_temp_id,0));
       */
              IF (l_serial_code > 1
                  AND l_serial_code <> 6) THEN
                IF (l_debug = 1) THEN
                  mydebug('multiple_lpn_pick: Lot/Ser controlled, allocate to serial OFF');
                END IF;

                OPEN lpn_ser_cur(l_lpn_lot_number);

                LOOP
                  FETCH lpn_ser_cur INTO l_serial_number;
                  EXIT WHEN lpn_ser_cur%NOTFOUND;

                  INSERT INTO mtl_serial_numbers_temp
                              (
                               transaction_temp_id
                             , last_update_date
                             , last_updated_by
                             , creation_date
                             , created_by
                             , fm_serial_number
                             , to_serial_number
                              )
                       VALUES (
                               l_new_serial_temp_id
                             , SYSDATE
                             , l_user_id
                             , SYSDATE
                             , l_user_id
                             , l_serial_number
                             , l_serial_number
                              );
                END LOOP;

                CLOSE lpn_ser_cur;
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('multiple_lpn_pick:  link original mtlt to new mmtt');
              END IF;

              IF (l_serial_code > 1
                  AND l_serial_code <> 6) THEN
                SELECT mtl_material_transactions_s.NEXTVAL
                  INTO l_new_serial_temp_id
                  FROM DUAL;
              ELSE
                l_new_serial_temp_id  := NULL;
              END IF;

              -- link the original mtlt to new mmtt
              UPDATE mtl_transaction_lots_temp
                 SET transaction_temp_id = l_new_temp_id
                   , serial_transaction_temp_id = NVL(l_new_serial_temp_id, serial_transaction_temp_id)
               WHERE transaction_temp_id = p_temp_id
                 AND lot_number = l_lpn_lot_number;

              /* AS: Need to insert Serial Numbers here also*/
              IF (l_serial_code > 1
                  AND l_serial_code <> 6) THEN
                IF (l_debug = 1) THEN
                  mydebug('multiple_lpn_pick: Lot/Ser controlled, allocate to serial OFF');
                END IF;

                OPEN lpn_ser_cur(l_lpn_lot_number);

                LOOP
                  FETCH lpn_ser_cur INTO l_serial_number;
                  EXIT WHEN lpn_ser_cur%NOTFOUND;

                  INSERT INTO mtl_serial_numbers_temp
                              (
                               transaction_temp_id
                             , last_update_date
                             , last_updated_by
                             , creation_date
                             , created_by
                             , fm_serial_number
                             , to_serial_number
                              )
                       VALUES (
                               l_new_serial_temp_id
                             , SYSDATE
                             , l_user_id
                             , SYSDATE
                             , l_user_id
                             , l_serial_number
                             , l_serial_number
                              );
                END LOOP;

                CLOSE lpn_ser_cur;
              END IF;
            END IF;
          END LOOP;

          CLOSE mtlt_lot_cur;
        END LOOP;

        CLOSE lpn_lot_cur;
      END IF; -- End Serial Loop
    ELSIF (l_serial_code > 1
           AND l_serial_code <> 6) -- serial controlled only
          AND p_sn_allocated_flag = 'Y' THEN -- and allocate to serial ON
      IF (l_debug = 1) THEN
        mydebug('multiple_lpn_pick: Serial Controlled Only and SN allocate ON');
      END IF;

      OPEN lpn_ser_cur(NULL);

      LOOP
        FETCH lpn_ser_cur INTO l_serial_number;
        EXIT WHEN lpn_ser_cur%NOTFOUND;

        UPDATE mtl_serial_numbers_temp
           SET transaction_temp_id = l_new_temp_id
         WHERE transaction_temp_id = p_temp_id
           AND fm_serial_number = l_serial_number
           AND to_serial_number = l_serial_number;
      END LOOP;

      CLOSE lpn_ser_cur;
    ELSIF(l_serial_code > 1
          AND l_serial_code <> 6) THEN -- serial controlled only and allocate to serial OFF
      IF (l_debug = 1) THEN
        mydebug('multiple_lpn_pick: Serial controlled, allocate to serial OFF');
      END IF;

      OPEN lpn_ser_cur(NULL);

      LOOP
        FETCH lpn_ser_cur INTO l_serial_number;
        EXIT WHEN lpn_ser_cur%NOTFOUND;

        INSERT INTO mtl_serial_numbers_temp
                    (
                     transaction_temp_id
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , fm_serial_number
                   , to_serial_number
                    )
             VALUES (
                     l_new_temp_id
                   , SYSDATE
                   , l_user_id
                   , SYSDATE
                   , l_user_id
                   , l_serial_number
                   , l_serial_number
                    );
      END LOOP;

      CLOSE lpn_ser_cur;
    END IF;

    -- Insert into tasks table

    --Get value from sequence for next task id
    SELECT wms_dispatched_tasks_s.NEXTVAL
      INTO l_next_task_id
      FROM DUAL;

    IF (l_debug = 1) THEN
      mydebug('multiple_lpn_pick: Before Insert into WMSDT');
    END IF;

    INSERT INTO wms_dispatched_tasks
                (
                 task_id
               , transaction_temp_id
               , organization_id
               , user_task_type
               , person_id
               , effective_start_date
               , effective_end_date
               , equipment_id
               , equipment_instance
               , person_resource_id
               , machine_resource_id
               , status
               , dispatched_time
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , task_type
               , loaded_time
               , operation_plan_id
               , move_order_line_id
                )
      (SELECT l_next_task_id
            , l_new_temp_id
            , organization_id
            , user_task_type
            , person_id
            , effective_start_date
            , effective_end_date
            , equipment_id
            , equipment_instance
            , person_resource_id
            , machine_resource_id
            , 4
            , dispatched_time
            , last_update_date
            , last_updated_by
            , creation_date
            , created_by
            , task_type
            , SYSDATE
            , operation_plan_id
            , move_order_line_id
         --to_date(to_char(sysdate,'DD-MON-YYYY HH:MI:SS'),'DD-MON-YYYY HH:MI:SS')
       FROM   wms_dispatched_tasks
        WHERE transaction_temp_id = l_temp_id);

    IF (l_debug = 1) THEN
      mydebug('multiple_lpn_pick: Update WMSDT as loaded');
    END IF;

    x_temp_id        := l_new_temp_id;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('multiple_lpn_pick: Complete  x_temp_id = ' || x_temp_id);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF lpn_ser_cur%ISOPEN THEN
        CLOSE lpn_ser_cur;
      END IF;

      IF lpn_lot_cur%ISOPEN THEN
        CLOSE lpn_lot_cur;
      END IF;

      IF mtlt_lot_cur%ISOPEN THEN
        CLOSE mtlt_lot_cur;
      END IF;

      ROLLBACK TO sp_multiple_lpn_pick;

      IF (l_debug = 1) THEN
        mydebug('multiple_lpn_pick: raise FND_API.G_EXC_ERROR');
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF lpn_ser_cur%ISOPEN THEN
        CLOSE lpn_ser_cur;
      END IF;

      IF lpn_lot_cur%ISOPEN THEN
        CLOSE lpn_lot_cur;
      END IF;

      IF mtlt_lot_cur%ISOPEN THEN
        CLOSE mtlt_lot_cur;
      END IF;

      ROLLBACK TO sp_multiple_lpn_pick;

      IF (l_debug = 1) THEN
        mydebug('multiple_lpn_pick: raise OTHER exception');
      END IF;
  END multiple_lpn_pick;



  PROCEDURE validate_pick_to_lpn
  ( p_api_version_number IN            NUMBER
  , p_init_msg_lst       IN            VARCHAR2
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , p_organization_id    IN            NUMBER
  , p_pick_to_lpn        IN            VARCHAR2
  , p_temp_id            IN            NUMBER
  , p_project_id         IN            NUMBER
  , p_task_id            IN            NUMBER
  ) IS

    l_api_version_number CONSTANT NUMBER                      := 1.0;
    l_api_name           CONSTANT VARCHAR2(30)                := 'validate_pick_to_lpn';
    l_pick_to_lpn_exists          BOOLEAN                     := FALSE;
    l_current_mmtt_delivery_id    NUMBER                      := NULL;
    l_pick_to_lpn_delivery_id     NUMBER                      := NULL;
    l_pick_to_lpn_delivery_id2    NUMBER                      := -999;
    l_outermost_lpn_id            NUMBER                      := NULL;

    --Added for PJM Integration
    l_project_id                  NUMBER                      := NULL;
    l_task_id                     NUMBER                      := NULL;

    -- ********************* Start of bug fix 2078002 ********************
    l_mmtt_mo_type                NUMBER                      := NULL;
    l_mo_type_in_lpn              NUMBER                      := NULL;
    l_mmtt_wip_entity_type        NUMBER;
    l_mmtt_txn_type_id            NUMBER;
    l_wip_entity_type_in_lpn      NUMBER;
    -- ********************* End of bug fix 2078002 ********************

    l_xfr_sub                     VARCHAR2(30);
    l_xfr_to_location             NUMBER;
    l_lpn_controlled_flag         NUMBER;
    l_count                       NUMBER                      := 0;
    l_item_id                     NUMBER;
    l_operation_plan_id           NUMBER;
    l_current_carton_grouping_id  NUMBER                      := -999;
    l_carton_grouping_id          NUMBER                      := -999;
    l_debug                       NUMBER                      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_line_rows                   WSH_UTIL_CORE.id_tab_type;  --Bug#4440585
    l_grouping_rows               WSH_UTIL_CORE.id_tab_type;  --Bug#4440585
    l_same_carton_grouping        BOOLEAN := FALSE;           --Bug#4440585
    l_return_status               VARCHAR2(2) ;

    TYPE lpn_rectype IS RECORD
    ( lpn_id           wms_license_plate_numbers.lpn_id%TYPE
    , lpn_context      wms_license_plate_numbers.lpn_context%TYPE
    , outermost_lpn_id wms_license_plate_numbers.outermost_lpn_id%TYPE
    );

    pick_to_lpn_rec               lpn_rectype;

    TYPE pjm_rectype IS RECORD
    ( prj_id mtl_item_locations.project_id%TYPE
    , tsk_id mtl_item_locations.task_id%TYPE
    );

    mtl_pjm_prj_tsk_rec           pjm_rectype;
    lpn_pjm_prj_tsk_rec           pjm_rectype;

    CURSOR others_in_mmtt_delivery_cursor(l_lpn_id IN NUMBER) IS
      SELECT wda.delivery_id
        FROM wsh_delivery_assignments_v        wda
           , wsh_delivery_details            wdd
           , mtl_material_transactions_temp  mmtt
       WHERE mmtt.transfer_lpn_id   = l_lpn_id
         AND wda.delivery_detail_id = wdd.delivery_detail_id
         AND wdd.move_order_line_id = mmtt.move_order_line_id
         AND wdd.organization_id    = mmtt.organization_id;

    CURSOR pick_to_lpn_cursor IS
      SELECT lpn_id
           , lpn_context
           , outermost_lpn_id
        FROM wms_license_plate_numbers
       WHERE license_plate_number = p_pick_to_lpn;

    CURSOR child_lpns_cursor(l_lpn_id IN NUMBER) IS
      SELECT lpn_id
      FROM   wms_license_plate_numbers
      START  WITH lpn_id = l_lpn_id
      CONNECT BY parent_lpn_id = PRIOR lpn_id;

    child_lpns_rec  child_lpns_cursor%ROWTYPE;

    CURSOR current_delivery_cursor IS
      SELECT wda.delivery_id
        FROM wsh_delivery_assignments_v        wda
           , wsh_delivery_details            wdd
           , mtl_material_transactions_temp  mmtt
       WHERE wda.delivery_detail_id   = wdd.delivery_detail_id
         AND wdd.move_order_line_id   = mmtt.move_order_line_id
         AND wdd.organization_id      = mmtt.organization_id
         AND mmtt.transaction_temp_id = p_temp_id
         AND mmtt.organization_id     = p_organization_id;

    CURSOR drop_delivery_cursor(l_lpn_id IN NUMBER) IS
      SELECT wda.delivery_id
        FROM wsh_delivery_assignments_v wda, wsh_delivery_details wdd
       WHERE wda.parent_delivery_detail_id = wdd.delivery_detail_id
         AND wdd.lpn_id = l_lpn_id
         AND wdd.released_status = 'X'   -- For LPN reuse ER : 6845650
         AND wdd.organization_id = p_organization_id;

    --
    -- This cursor gets the project and task id fo the lpn to be
    -- loaded into
    --
    CURSOR lpn_project_task_cursor IS
      SELECT NVL(mil.project_id, -1)
           , NVL(mil.task_id, -1)
        FROM mtl_item_locations mil, mtl_material_transactions_temp mmtt
       WHERE mil.inventory_location_id = mmtt.transfer_to_location
         AND mil.organization_id       = mmtt.organization_id
         AND mmtt.transfer_lpn_id      = p_pick_to_lpn
         AND mmtt.organization_id      = p_organization_id;

    --
    -- This cursor gets the project and task id of the task that is about
    -- to be packed
    --
    CURSOR mtl_project_task_cursor IS
      SELECT NVL(mil.project_id, -1)
           , NVL(mil.task_id, -1)
        FROM mtl_item_locations mil, mtl_material_transactions_temp mmtt
       WHERE mil.inventory_location_id = mmtt.transfer_to_location
         AND mil.organization_id       = mmtt.organization_id
         AND mmtt.organization_id      = p_organization_id
         AND mmtt.transaction_temp_id  = p_temp_id;

    CURSOR current_carton_grouping_cursor IS
      SELECT mol.carton_grouping_id
        FROM mtl_txn_request_lines mol, mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id
         AND mmtt.organization_id     = mol.organization_id
         AND mmtt.move_order_line_id  = mol.line_id;

    CURSOR others_carton_grouping_cursor(p_lpn_id IN NUMBER) IS
      SELECT DISTINCT mol.carton_grouping_id
                 FROM mtl_txn_request_lines mol, mtl_material_transactions_temp mmtt
                WHERE mmtt.transfer_lpn_id = p_lpn_id
                  AND mmtt.organization_id = mol.organization_id
                  AND mmtt.move_order_line_id = mol.line_id;
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('validate_pick_to_lpn: Start Validate_pick_to_lpn.');
    END IF;

    --
    -- Standard call to check for call compatibility
    --
    IF NOT fnd_api.compatible_api_call(l_api_version_number, p_api_version_number, l_api_name, g_pkg_name) THEN
       fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    --
    --  Initialize message list.
    --
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
       fnd_msg_pub.initialize;
    END IF;

    --
    -- Initialize API return status to success
    --
    x_return_status        := fnd_api.g_ret_sts_success;

    --
    -- Begin validation process:
    -- Check if drop lpn exists by trying to retrieve its lpn ID.
    -- If it does not exist, no further validations required
    -- so return success.
    --
    OPEN pick_to_lpn_cursor;
    FETCH pick_to_lpn_cursor INTO pick_to_lpn_rec;

    IF pick_to_lpn_cursor%NOTFOUND THEN
       l_pick_to_lpn_exists  := FALSE;
    ELSE
       l_pick_to_lpn_exists  := TRUE;
    END IF;

    CLOSE pick_to_lpn_cursor;

    IF NOT l_pick_to_lpn_exists THEN
       IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Drop LPN is a new LPN, no checking required.');
       END IF;
       RETURN;
    END IF;

    wms_task_dispatch_gen.check_pack_lpn
    ( p_lpn            => p_pick_to_lpn
    , p_org_id         => p_organization_id
    , x_return_status  => x_return_status
    , x_msg_count      => x_msg_count
    , x_msg_data       => x_msg_data
    );



    IF x_return_status = fnd_api.g_ret_sts_unexp_error
       OR x_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
    END IF;



    --
    -- If the drop lpn was pre-generated, no validations required
    -- Changed the context to be updated to 8 instead of 1 as done earlier
    --
    IF pick_to_lpn_rec.lpn_context = wms_container_pub.lpn_context_pregenerated THEN
       --
       -- Update the context to "Packing Context" (8)
       --
       -- Bug5659809: update last_update_date and last_update_by as well
       UPDATE wms_license_plate_numbers
          SET lpn_context = wms_container_pub.lpn_context_packing
            , last_update_date = SYSDATE
            , last_updated_by = fnd_global.user_id
        WHERE lpn_id = pick_to_lpn_rec.lpn_id;

       IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Drop LPN is pre-generated, no checking required.');
       END IF;

       RETURN;
    END IF;


    --
    -- *********************Start of bug fix 2078002,2095080 ********************
    -- Check if the task that is about to pack into the LPN has the same
    -- move order type as the tasks already packed into the same LPN
    --
    SELECT mtrh.move_order_type
         , mmtt.transaction_type_id
         , mmtt.wip_entity_type
      INTO l_mmtt_mo_type
         , l_mmtt_txn_type_id
         , l_mmtt_wip_entity_type
      FROM mtl_txn_request_headers         mtrh
         , mtl_txn_request_lines           mtrl
         , mtl_material_transactions_temp  mmtt
     WHERE mtrh.header_id           = mtrl.header_id
       AND mtrl.line_id             = mmtt.move_order_line_id
       AND mmtt.transaction_temp_id = p_temp_id;



    BEGIN
       SELECT mtrh.move_order_type
         , mmtt.wip_entity_type
    INTO l_mo_type_in_lpn
         , l_wip_entity_type_in_lpn
    FROM mtl_txn_request_headers         mtrh
         , mtl_txn_request_lines           mtrl
         , mtl_material_transactions_temp  mmtt
    WHERE mtrh.header_id       = mtrl.header_id
    AND mtrl.line_id         = mmtt.move_order_line_id
    AND mmtt.transfer_lpn_id = pick_to_lpn_rec.lpn_id
    AND ROWNUM < 2;
    EXCEPTION
       WHEN no_data_found THEN
     NULL;
    END;



    IF l_mo_type_in_lpn <> l_mmtt_mo_type THEN
       IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Picked LPN and current MMTT have different MO type.');
          mydebug('  p_temp_id => ' || p_temp_id);
          mydebug('  lpn_id => ' || pick_to_lpn_rec.lpn_id);
          mydebug('  l_mmtt_mo_type => ' || l_mmtt_mo_type);
          mydebug('  l_mo_type_in_lpn => ' || l_mo_type_in_lpn);
       END IF;
       fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_MO_TYPE');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    ELSIF l_mmtt_txn_type_id = 35
          OR l_mmtt_txn_type_id = 51 THEN -- Mfg pick
          IF l_mmtt_wip_entity_type <> l_wip_entity_type_in_lpn THEN
             IF (l_debug = 1) THEN
                mydebug('validate_pick_to_lpn: This is a manufacturing component pick.');
                mydebug('WIP entity type IS NOT the same AS that OF the old mmtt RECORD');
             END IF;
             fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_MFG_MODE');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
          END IF;
    END IF;
    -- *********************End of bug fix 2078002,2095080 ********************



    --
    -- Bug 2355453: Check to see if the LPN is already going to some other lpn
    -- controlled sub. In that case, do not allow material to be picked into
    -- this LPN
    --
    IF (l_debug = 1) THEN
       mydebug('validate_pick_to_lpn: Check to see if LPN is already going to some other sub/loc');
    END IF;

    SELECT mmtt.transfer_subinventory
         , mmtt.transfer_to_location
         , mmtt.inventory_item_id
         , mmtt.operation_plan_id
      INTO l_xfr_sub
         , l_xfr_to_location
         , l_item_id
         , l_operation_plan_id
      FROM mtl_material_transactions_temp mmtt
     WHERE mmtt.transaction_temp_id = p_temp_id;

    l_lpn_controlled_flag  := wms_globals.g_non_lpn_controlled_sub;

    IF l_xfr_sub IS NOT NULL THEN
       SELECT lpn_controlled_flag
         INTO l_lpn_controlled_flag
         FROM mtl_secondary_inventories
        WHERE organization_id = p_organization_id
          AND secondary_inventory_name = l_xfr_sub;
    END IF;

    IF l_xfr_sub IS NOT NULL
       AND l_lpn_controlled_flag = wms_globals.g_lpn_controlled_sub THEN
       IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Transfer Sub is LPN Controlled');
       END IF;

       --
       -- Ensure that all remaining picks on the LPN are also for the same sub
       --
       l_count  := 0;

       BEGIN
          SELECT COUNT(*)
            INTO l_count
            FROM mtl_material_transactions_temp mmtt
           WHERE mmtt.transaction_temp_id <> p_temp_id
             AND mmtt.transfer_lpn_id = pick_to_lpn_rec.lpn_id
             AND ( NVL(mmtt.transfer_subinventory, 0) <> l_xfr_sub
                   OR
                   NVL(mmtt.transfer_to_location, 0)  <> l_xfr_to_location
                 );
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               l_count  := 0;
       END;

       IF l_count > 0 THEN
          IF (l_debug = 1) THEN
             mydebug('validate_pick_to_lpn: Drop LPN is going to an LPN controlled sub');
             mydebug('validate_pick_to_lpn: Cannot add picks not going to the same sub');
          END IF;

          fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_SUBINV');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
       END IF;
    ELSE
       --
       -- Current temp ID has a NULL xfer sub (issue txn)
       -- or the xfer sub is non LPN-controlled.
       -- Ensure that no other picks on the same LPN are to
       -- LPN controlled subs
       --

       IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Transfer Sub is non LPN Controlled or null.');
       END IF;

       l_count  := 0;
       BEGIN
          SELECT 1
            INTO l_count
            FROM DUAL
           WHERE EXISTS
               ( SELECT 'x'
                   FROM mtl_material_transactions_temp  mmtt
                      , mtl_secondary_inventories       msi
                  WHERE mmtt.transaction_temp_id    <> p_temp_id
                    AND mmtt.transfer_lpn_id         = pick_to_lpn_rec.lpn_id
                    AND msi.organization_id          = p_organization_id
                    AND msi.secondary_inventory_name = mmtt.transfer_subinventory
                    AND msi.lpn_controlled_flag      = wms_globals.g_lpn_controlled_sub
               );
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               l_count  := 0;
       END;

       IF l_count > 0 THEN
          IF (l_debug = 1) THEN
             mydebug('validate_pick_to_lpn: Drop LPN has pick(s) for an LPN-controlled sub');
          END IF;

          fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_SUBINV');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
       END IF;
    END IF;

    --
    IF (l_debug = 1) THEN
       mydebug('validate_pick_to_lpn: Check to see if LPN is associated with material' ||
               ' FOR a different operation plan');
    END IF;

    l_count := 0;
    BEGIN
      SELECT COUNT(1)
        INTO l_count
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id <> p_temp_id
         AND mmtt.transfer_lpn_id      = pick_to_lpn_rec.lpn_id
         AND mmtt.operation_plan_id   <> l_operation_plan_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_count := 0;
    END;

    IF l_count > 0 THEN
       IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Drop LPN is associated with material FOR a different operation plan');
       END IF;

       fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_OPER_PLAN');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;


    --
    -- No further checks required if LPN contains manufacturing picks
    -- The checks after this are related to delivery ID and PJM orgs
    --
    IF l_mmtt_mo_type = 5 THEN
       RETURN;
    END IF;

    -- Now check if the picked LPN
    -- belongs to delivery which is different from current delivery
    --
    OPEN current_delivery_cursor;

    LOOP
      FETCH current_delivery_cursor INTO l_current_mmtt_delivery_id;
      EXIT WHEN l_current_mmtt_delivery_id IS NOT NULL
            OR current_delivery_cursor%NOTFOUND;
    END LOOP;

    CLOSE current_delivery_cursor;

    IF (l_debug = 1) THEN
      mydebug('validate_pick_to_lpn: l_current_mmtt_delivery_id:' || l_current_mmtt_delivery_id);
    END IF;

    --
    -- If the current MMTT is not associated with a delivery yet
    -- then no further checking required, return success
    --
    IF l_current_mmtt_delivery_id IS NULL THEN
      IF (l_debug = 1) THEN
        mydebug('validate_pick_to_lpn: Current MMTT is not associated with a delivery');
      END IF;

      OPEN current_carton_grouping_cursor;
      FETCH current_carton_grouping_cursor INTO l_current_carton_grouping_id;
      CLOSE current_carton_grouping_cursor;

      IF (l_current_carton_grouping_id = -999) THEN
        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: can NOT find move order line for current task');
        END IF;

        fnd_message.set_name('WMS', 'WMS_NO_MOL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_current_carton_grouping_id IS NOT NULL THEN -- found carton_grouping_id
        OPEN others_carton_grouping_cursor(pick_to_lpn_rec.lpn_id);

        LOOP
          FETCH others_carton_grouping_cursor INTO l_carton_grouping_id;
          EXIT WHEN l_current_carton_grouping_id = NVL(l_carton_grouping_id, 0)
                OR others_carton_grouping_cursor%NOTFOUND;
        END LOOP;

        CLOSE others_carton_grouping_cursor;

        IF l_carton_grouping_id = -999 THEN -- it is the first task in the lpn
          mydebug('validate_pick_to_lpn: This is the first task for the lpn ' ||
                  'and the task without delivery, so ok..');
          RETURN;
        END IF;

        IF l_carton_grouping_id IS NOT NULL THEN
          IF l_carton_grouping_id = l_current_carton_grouping_id THEN --the same carton_grouping_id
            IF (l_debug = 1) THEN
              mydebug('validate_pick_to_lpn: found the task in lpn which has ' ||
                      'the same carton_grouping_id as current task');
            END IF;

            OPEN others_in_mmtt_delivery_cursor(pick_to_lpn_rec.lpn_id);
            l_pick_to_lpn_delivery_id  := -999;

            LOOP
              FETCH others_in_mmtt_delivery_cursor INTO l_pick_to_lpn_delivery_id;
              EXIT WHEN l_pick_to_lpn_delivery_id IS NULL
                    OR others_in_mmtt_delivery_cursor%NOTFOUND;
            END LOOP;

            CLOSE others_in_mmtt_delivery_cursor;

            IF l_pick_to_lpn_delivery_id = -999 THEN --there is mol, but no wdd or wda, raise error
              IF (l_debug = 1) THEN
                mydebug('validate_pick_to_lpn: can NOT find either wdd or wda for tasks in the lpn');
              END IF;

              fnd_message.set_name('WMS', 'WMS_NO_WDD_WDA');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;

            IF l_pick_to_lpn_delivery_id IS NULL THEN
              IF (l_debug = 1) THEN
                mydebug('validate_pick_to_lpn: found a task which has ' ||
                        'the same carton_grouping_id as current task, and also no delivery.');
              END IF;

              RETURN;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('validate_pick_to_lpn: other tasks in lpn have different deliveries');
              END IF;

              fnd_message.set_name('WMS', 'WMS_PICK_TO_LPN_DIFF_DELIV');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE -- they have different carton_grouping_id
            IF (l_debug = 1) THEN
              mydebug('validate_pick_to_lpn: other tasks in lpn have different carton grouping id');
            END IF;

            --Bug#4440585. Added this block
            BEGIN
          SELECT wdd.delivery_detail_id INTO  l_line_rows(1)
               FROM wsh_delivery_details    wdd
                   , mtl_material_transactions_temp  mmtt
               WHERE mmtt.transaction_temp_id = p_temp_id
               AND wdd.move_order_line_id = mmtt.move_order_line_id
               AND wdd.organization_id    = mmtt.organization_id;

               SELECT wdd.delivery_detail_id  INTO  l_line_rows(2)
               FROM wsh_delivery_details  wdd
                    , mtl_material_transactions_temp  mmtt
               WHERE mmtt.transfer_lpn_id   = pick_to_lpn_rec.lpn_id
               AND wdd.move_order_line_id = mmtt.move_order_line_id
               AND wdd.organization_id    = mmtt.organization_id
               AND rownum<2;
               IF (l_debug = 1) THEN
                  mydebug('validate_pick_to_lpn: Before calling WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping() to decide if we can load into this LPN');
        mydebug('Parameters : delivery_detail_id(1):'|| l_line_rows(1) ||' , delivery_detail_id(2) :'||l_line_rows(2));
               END IF;
              --call to the shipping API.
              WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping(
                           p_line_rows      => l_line_rows,
                           x_grouping_rows  => l_grouping_rows,
                      x_return_status  => l_return_status);

               IF (l_return_status = FND_API.G_RET_STS_SUCCESS
                   AND l_grouping_rows (1) = l_grouping_rows(2) )  THEN
                     l_same_carton_grouping := TRUE;
               ELSE
                     l_same_carton_grouping := FALSE;
               END IF;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                    mydebug('No Data found Exception raised when matching delivery grouping attributes');
                    l_same_carton_grouping := FALSE;
               END IF;
            WHEN OTHERS THEN
              IF (l_debug = 1) THEN
                   mydebug('Other Exception raised when matching for delivery grouping attributes');
                   l_same_carton_grouping := FALSE;
              END IF;
            END;
            IF (l_same_carton_grouping = FALSE) then
               fnd_message.set_name('WMS', 'WMS_DIFF_CARTON_GROUP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
            END IF;  --End of fix for bug#4440585.

         END IF;
        ELSE -- some of carton_grouping_id is null
          IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: some of tasks in lpn have NULL carton_grouping_id');
          END IF;

          fnd_message.set_name('WMS', 'WMS_CARTON_GROUP_NULL');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE --carton_grouping_id is null
        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: carton_grouping_id of current task is null');
        END IF;
       --bug3481923 only fail if it is not requisition on repl mo
      if (l_mmtt_mo_type not in(1,2)) then
        fnd_message.set_name('WMS', 'WMS_CARTON_GROUP_NULL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      end if;
      END IF;
    END IF;

    -- Check if picked LPN has been picked_to in previous tasks, tasks that
    -- are still IN MMTT and shipping tables do not have the drop lpn yet

    OPEN others_in_mmtt_delivery_cursor(pick_to_lpn_rec.lpn_id);

    LOOP
      FETCH others_in_mmtt_delivery_cursor INTO l_pick_to_lpn_delivery_id2;
      EXIT WHEN l_pick_to_lpn_delivery_id2 IS NOT NULL
            OR others_in_mmtt_delivery_cursor%NOTFOUND;
    END LOOP;

    CLOSE others_in_mmtt_delivery_cursor;

    IF (l_debug = 1) THEN
      mydebug('validate_pick_to_lpn: l_pick_to_lpn_delivery_id2' || l_pick_to_lpn_delivery_id2);
    END IF;

    IF l_pick_to_lpn_delivery_id2 IS NOT NULL THEN
      IF (l_pick_to_lpn_delivery_id2 <> l_current_mmtt_delivery_id AND
   l_pick_to_lpn_delivery_id2 <> -999 ) THEN
        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Picked LPN and current MMTT go to different deliveries.');
        END IF;

        fnd_message.set_name('WMS', 'WMS_PICK_TO_LPN_DIFF_DELIV');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSIF l_pick_to_lpn_delivery_id2 IS NULL THEN
      IF (l_debug = 1) THEN
        mydebug('validate_pick_to_lpn: Picked LPN does not have deliveries.');
      END IF;

      IF l_current_mmtt_delivery_id IS NOT NULL THEN
        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Current task has delivery.');
          mydebug('validate_pick_to_lpn: Picked LPN does not have delivery and current task has delivery.');
        END IF;

        fnd_message.set_name('WMS', 'WMS_PICK_TO_LPN_DIFF_DELIV');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSIF l_pick_to_lpn_delivery_id2 = -999 THEN
      IF (l_debug = 1) THEN
        mydebug('validate_pick_to_lpn: LPN does not contain other tasks. This is the first task, so ok.');
      END IF;
    END IF;

    IF pick_to_lpn_rec.outermost_lpn_id IS NOT NULL THEN
      -- We need to check delivery for outermost lpn or drill down if needed
      l_outermost_lpn_id  := pick_to_lpn_rec.outermost_lpn_id;
    ELSE
      -- We need to check delivery for pick_to_lpn or drill down if needed
      l_outermost_lpn_id  := pick_to_lpn_rec.lpn_id;
    END IF;

    --
    -- Find the outermost LPN's delivery ID
    --
    OPEN drop_delivery_cursor(l_outermost_lpn_id);
    FETCH drop_delivery_cursor INTO l_pick_to_lpn_delivery_id;
    CLOSE drop_delivery_cursor;

    IF l_pick_to_lpn_delivery_id IS NOT NULL THEN
      IF l_pick_to_lpn_delivery_id <> l_current_mmtt_delivery_id THEN
        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Picked LPN and current MMTT go to different deliveries.');
        END IF;

        fnd_message.set_name('WMS', 'WMS_PICK_TO_LPN_DIFF_DELIV');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        --
        -- Picked LPN and current MMTT are on the same delivery
        -- return success
        --
        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Picked LPN and current MMTT go to same delivery: ' ||
                   l_pick_to_lpn_delivery_id);
        END IF;

        RETURN;
      END IF;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('validate_pick_to_lpn: Drop LPN does not have a delivery ID, checking child LPNs');
      END IF;

      OPEN child_lpns_cursor(l_outermost_lpn_id);

      LOOP
        FETCH child_lpns_cursor INTO child_lpns_rec;
        EXIT WHEN child_lpns_cursor%NOTFOUND;

        IF child_lpns_cursor%FOUND THEN
          OPEN drop_delivery_cursor(child_lpns_rec.lpn_id);
          FETCH drop_delivery_cursor INTO l_pick_to_lpn_delivery_id;
          CLOSE drop_delivery_cursor;
        END IF;

        EXIT WHEN l_pick_to_lpn_delivery_id IS NOT NULL;
      END LOOP;

      CLOSE child_lpns_cursor;

      --
      -- If the child LPNs also don't have a delivery ID
      -- then ok to deposit
      --
      IF l_pick_to_lpn_delivery_id IS NOT NULL THEN
        IF l_pick_to_lpn_delivery_id <> l_current_mmtt_delivery_id THEN
          IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: LPNs are on diff deliveries.');
          END IF;

          fnd_message.set_name('WMS', 'WMS_PICK_TO_LPN_DIFF_DELIV');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          --
          -- Child LPN has the  delivery as the current MMTT, return success
          --
          IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: A child LPN is on the same delivery ' ||
                    'as that OF the CURRENT MMTT, return success.');
          END IF;

          RETURN;
        END IF;
      ELSE
        --
        -- No child LPNs have a delivery ID yet
        -- return success
        --
        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Child LPNs do not have a delivery ID either, return success.');
        END IF;

        RETURN;
      END IF;
    END IF;

    --
    -- Fetch the Project/Task id associated with the LPN passed
    --
    -- PJM Integration:
    -- Check if the task that is about to pack into the LPN has the same
    -- transfer project_id and task_id as the lpn to which it is going to
    -- be loaded into.
    -- If yes, proceed, else return
    --
    IF (p_project_id IS NOT NULL) THEN
      OPEN lpn_project_task_cursor;

      LOOP
        FETCH lpn_project_task_cursor INTO lpn_pjm_prj_tsk_rec;
        EXIT WHEN lpn_project_task_cursor%NOTFOUND;
        OPEN mtl_project_task_cursor;

        LOOP
          FETCH mtl_project_task_cursor INTO mtl_pjm_prj_tsk_rec;
          EXIT WHEN mtl_project_task_cursor%NOTFOUND;

          IF ((mtl_pjm_prj_tsk_rec.prj_id <> lpn_pjm_prj_tsk_rec.prj_id)
              AND(mtl_pjm_prj_tsk_rec.tsk_id <> lpn_pjm_prj_tsk_rec.tsk_id)) THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END LOOP;

        CLOSE mtl_project_task_cursor;
      END LOOP;

      CLOSE lpn_project_task_cursor;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('validate_pick_to_lpn: @' || x_msg_data || '@');
      END IF;

      IF others_in_mmtt_delivery_cursor%ISOPEN THEN
        CLOSE others_in_mmtt_delivery_cursor;
      END IF;

      IF pick_to_lpn_cursor%ISOPEN THEN
        CLOSE pick_to_lpn_cursor;
      END IF;

      IF child_lpns_cursor%ISOPEN THEN
        CLOSE child_lpns_cursor;
      END IF;

      IF current_delivery_cursor%ISOPEN THEN
        CLOSE current_delivery_cursor;
      END IF;

      IF drop_delivery_cursor%ISOPEN THEN
        CLOSE drop_delivery_cursor;
      END IF;

      IF lpn_project_task_cursor%ISOPEN THEN
        CLOSE lpn_project_task_cursor;
      END IF;

      IF mtl_project_task_cursor%ISOPEN THEN
        CLOSE mtl_project_task_cursor;
      END IF;

      IF current_carton_grouping_cursor%ISOPEN THEN
        CLOSE current_carton_grouping_cursor;
      END IF;

      IF others_carton_grouping_cursor%ISOPEN THEN
        CLOSE others_carton_grouping_cursor;
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF others_in_mmtt_delivery_cursor%ISOPEN THEN
        CLOSE others_in_mmtt_delivery_cursor;
      END IF;

      IF pick_to_lpn_cursor%ISOPEN THEN
        CLOSE pick_to_lpn_cursor;
      END IF;

      IF child_lpns_cursor%ISOPEN THEN
        CLOSE child_lpns_cursor;
      END IF;

      IF current_delivery_cursor%ISOPEN THEN
        CLOSE current_delivery_cursor;
      END IF;

      IF drop_delivery_cursor%ISOPEN THEN
        CLOSE drop_delivery_cursor;
      END IF;

      IF lpn_project_task_cursor%ISOPEN THEN
        CLOSE lpn_project_task_cursor;
      END IF;

      IF mtl_project_task_cursor%ISOPEN THEN
        CLOSE mtl_project_task_cursor;
      END IF;

      IF current_carton_grouping_cursor%ISOPEN THEN
        CLOSE current_carton_grouping_cursor;
      END IF;

      IF others_carton_grouping_cursor%ISOPEN THEN
        CLOSE others_carton_grouping_cursor;
      END IF;

      IF (l_debug = 1) THEN
        mydebug('validate_pick_to_lpn: @' || x_msg_data || '@');
      END IF;
  END validate_pick_to_lpn;

  PROCEDURE multiple_pick(
    p_pick_qty            IN            NUMBER
  , p_org_id              IN            NUMBER
  , p_temp_id             IN            NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_sn_allocated_flag   IN            VARCHAR2
  , p_act_uom             IN            VARCHAR2
  , p_from_lpn            IN            VARCHAR2
  , p_from_lpn_id         IN            NUMBER
  , p_to_lpn              IN            VARCHAR2
  , p_ok_to_process       OUT NOCOPY    VARCHAR2
  , p_is_revision_control IN            VARCHAR2
  , p_is_lot_control      IN            VARCHAR2
  , p_is_serial_control   IN            VARCHAR2
  , p_act_rev             IN            VARCHAR2
  , p_lot                 IN            VARCHAR2
  , p_act_sub             IN            VARCHAR2
  , p_act_loc             IN            NUMBER
  , p_container_item_id   IN            NUMBER
  , p_entire_lpn          IN            VARCHAR2
  , p_pick_qty_remaining  IN            NUMBER
  , x_temp_id             OUT NOCOPY    NUMBER
  , p_serial_number       IN            VARCHAR2
  ) IS
    l_temp_id                   NUMBER;
    l_msg_cnt                   NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_return_status             VARCHAR2(1);
    l_sug_loc                   NUMBER;
    l_sug_sub                   VARCHAR2(10);
    l_act_loc                   NUMBER;
    l_act_sub                   VARCHAR2(10);
    l_to_sub                    VARCHAR2(10);
    l_to_loc                    NUMBER;
    l_sug_uom                   VARCHAR2(3);
    l_sug_rev                   VARCHAR2(10);
    l_fm_serial                 VARCHAR2(30);
    l_to_serial                 VARCHAR2(30);
    l_qty                       NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot                       VARCHAR2(80);
    l_pr_qty                    NUMBER;
    l_item_id                   NUMBER;
    l_lot_code                  NUMBER;
    l_serial_code               NUMBER;
    l_user_id                   NUMBER;
    l_mo_line_id                NUMBER;
    l_new_temp_id               NUMBER;
    l_next_task_id              NUMBER;
    l_txn_header_id             NUMBER;
    l_new_serial_temp_id        NUMBER;
    l_lot_ser_seq               NUMBER;
    l_from_lpn_id               NUMBER;
    l_to_lpn_id                 NUMBER;
    l_to_lpn_exists             NUMBER;
    l_to_lpn_context            NUMBER;
    l_reservation_id            NUMBER;
    l_is_conf_sub_reservable    BOOLEAN;
    if_detailed_reservation     BOOLEAN;
    l_res_sub                   VARCHAR2(10);
    l_to_reservation_id         NUMBER;
    l_mtl_reservation_tbl       inv_reservation_global.mtl_reservation_tbl_type;
    l_mtl_reservation_rec       inv_reservation_global.mtl_reservation_rec_type;
    l_to_serial_number          inv_reservation_global.serial_number_tbl_type;
    l_mtl_reservation_tbl_count NUMBER;
    l_error_code                NUMBER;
    l_pick_qty_remaining        NUMBER;
    l_mtlt_rec                  mtl_transaction_lots_temp%ROWTYPE;
    l_local_temp_id             NUMBER;
    l_orig_txn_qty              NUMBER;
    l_orig_primary_qty          NUMBER;
    l_content_parent_lpn_id     NUMBER;
    l_progress                  VARCHAR2(4);
    l_lpn_exact_match           VARCHAR2(1)                                     := 'N';
    l_lpn_id                    NUMBER;
    l_debug                     NUMBER                                          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_serial_prefix             NUMBER;
    l_real_serial_prefix        VARCHAR2(30);
    l_serial_numeric_frm        NUMBER;
    l_serial_numeric_to         NUMBER;
    l_serial_count              NUMBER := 0 ; --Added for bug 4245565
    l_res_loc                   NUMBER; --Bug#4339517
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('multiple_pick: begins');
    END IF;

    SAVEPOINT sp_multiple_pick;
    l_progress            := '10';
    l_return_status       := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('multiple_pick: p_temp_id = ' || p_temp_id);
      mydebug('multiple_pick: p_org_id = ' || p_org_id);
      mydebug('multiple_pick: p_pick_qty = ' || p_pick_qty);
      mydebug('multiple_pick: p_uom_code = ' || p_act_uom);
      mydebug('multiple_pick: p_sn_allocated_flag = ' || p_sn_allocated_flag);
      mydebug('multiple_pick: p_from_lpn = ' || p_from_lpn);
      mydebug('multiple_pick: p_to_lpn = ' || p_to_lpn);
    END IF;

    l_temp_id             := p_temp_id;
    l_from_lpn_id         := p_from_lpn_id;
    l_pick_qty_remaining  := p_pick_qty_remaining;
    l_act_sub             := p_act_sub;
    l_act_loc             := p_act_loc;
    -- initialize the p_ok_to_process
    p_ok_to_process       := 'true';

    IF l_act_loc = 0 THEN
      l_act_loc  := NULL;
    END IF;

    l_fm_serial           := p_serial_number;
    l_to_serial           := p_serial_number;
    l_lot                 := p_lot;
    l_local_temp_id       := l_temp_id;
    l_progress            := '20';

    SELECT transaction_header_id
         , subinventory_code
         , locator_id
         , transfer_subinventory
         , transfer_to_location
         , revision
         , transaction_quantity
         , primary_quantity
         , transaction_uom
         , inventory_item_id
         , last_updated_by
         , move_order_line_id
         , reservation_id
      INTO l_txn_header_id
         , l_sug_sub
         , l_sug_loc
         , l_to_sub
         , l_to_loc
         , l_sug_rev
         , l_orig_txn_qty
         , l_orig_primary_qty
         , l_sug_uom
         , l_item_id
         , l_user_id
         , l_mo_line_id
         , l_reservation_id
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = l_temp_id;

    l_to_reservation_id   := l_reservation_id;
    l_progress            := '30';

    SELECT lot_control_code
         , serial_number_control_code
      INTO l_lot_code
         , l_serial_code
      FROM mtl_system_items
     WHERE organization_id = p_org_id
       AND inventory_item_id = l_item_id;

    IF (l_debug = 1) THEN
      mydebug('multiple_pick: l_lot_code = ' || l_lot_code);
      mydebug('multiple_pick: l_serial_code = ' || l_serial_code);
    END IF;

    l_progress            := '40';

    IF l_sug_uom = p_act_uom THEN
      l_qty  := p_pick_qty;
    ELSE
      l_qty  :=
        inv_convert.inv_um_convert(
          item_id                      => l_item_id
        , PRECISION                    => NULL
        , from_quantity                => p_pick_qty
        , from_unit                    => p_act_uom
        , to_unit                      => l_sug_uom
        , from_name                    => NULL
        , to_name                      => NULL
        );

      IF (l_debug = 1) THEN
        mydebug('multiple_pick: l_qty = ' || l_qty);
      END IF;
    END IF;

    l_progress            := '50';
    -- Calculate Primary Quantity

    l_pr_qty              :=
      wms_task_dispatch_gen.get_primary_quantity(p_item_id => l_item_id, p_organization_id => p_org_id, p_from_quantity => l_qty
      , p_from_unit                  => l_sug_uom);
    l_progress            := '60';

    IF (l_debug = 1) THEN
      mydebug('multiple_pick: l_pr_qty = ' || l_pr_qty);
    END IF;

    IF (l_from_lpn_id <= 0
        OR l_from_lpn_id IS NULL) THEN
      IF (l_debug = 1) THEN
        mydebug('multiple_pick: Loose items were picked and not LPN');
        mydebug('multiple_pick: Validating loose Quantity');
      END IF;

      inv_txn_validations.check_loose_quantity(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_organization_id            => p_org_id
      , p_inventory_item_id          => l_item_id
      , p_is_revision_control        => p_is_revision_control
      , p_is_lot_control             => p_is_lot_control
      , p_is_serial_control          => p_is_serial_control
      , p_revision                   => p_act_rev
      , p_lot_number                 => p_lot
      , p_transaction_quantity       => p_pick_qty
      , p_transaction_uom            => p_act_uom
      , p_subinventory_code          => p_act_sub
      , p_locator_id                 => l_act_loc
      , p_transaction_temp_id        => l_temp_id
      , p_ok_to_process              => p_ok_to_process
      , p_transfer_subinventory      => l_to_sub
      );
      l_progress  := '70';

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: unexpected error in check_loose_qty');
        END IF;

        p_ok_to_process  := 'false';
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: error in check_loose_qty');
        END IF;

        p_ok_to_process  := 'false';
        RAISE fnd_api.g_exc_error;
      END IF;

      IF p_ok_to_process = 'false' THEN
        x_temp_id        := 0;
        l_temp_id        := 0;

        IF (l_debug = 1) THEN
          mydebug('multiple_pick: After quantity validation. Quantity not enough. Cannot process');
        END IF;

        x_return_status  := fnd_api.g_ret_sts_success;
        RETURN;
      END IF;
    ELSE
      IF (l_sug_loc <> l_act_loc
          OR l_sug_sub <> l_act_sub) THEN
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: LPN was picked. Validating qty');
        END IF;

        inv_txn_validations.check_loose_and_packed_qty(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_organization_id            => p_org_id
        , p_inventory_item_id          => l_item_id
        , p_is_revision_control        => p_is_revision_control
        , p_is_lot_control             => p_is_lot_control
        , p_is_serial_control          => p_is_serial_control
        , p_revision                   => p_act_rev
        , p_lot_number                 => p_lot
        , p_transaction_quantity       => p_pick_qty
        , p_transaction_uom            => p_act_uom
        , p_subinventory_code          => p_act_sub
        , p_locator_id                 => l_act_loc
        , p_transaction_temp_id        => l_temp_id
        , p_ok_to_process              => p_ok_to_process
        , p_transfer_subinventory      => l_to_sub
        );
        l_progress  := '71';

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
            mydebug('multiple_pick: unexpected error in check_loose_and_packed_qty');
          END IF;

          p_ok_to_process  := 'false';
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            mydebug('multiple_pick: error in check_and_packed_loose_qty');
          END IF;

          p_ok_to_process  := 'false';
          RAISE fnd_api.g_exc_error;
        END IF;

        IF p_ok_to_process = 'false' THEN
          x_temp_id        := 0;
          l_temp_id        := 0;

          IF (l_debug = 1) THEN
            mydebug('multiple_pick: After quantity validation. Quantity not enough. Cannot process');
          END IF;

          x_return_status  := fnd_api.g_ret_sts_success;
          RETURN;
        END IF;
      END IF;
    END IF;

    /*
     Bug #2075166.
     If check_loose_quantity returns p_ok_to_process as 'warning'
     then retain it. Else set it to true
    */
    IF p_ok_to_process <> 'warning' THEN
      p_ok_to_process  := 'true';
    END IF;

    l_to_lpn_exists       := 0;
    l_progress            := '80';

    BEGIN
      SELECT 1
        INTO l_to_lpn_exists
        FROM wms_license_plate_numbers
       WHERE license_plate_number = p_to_lpn
         AND organization_id = p_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_to_lpn_exists  := 0;
    END;

    IF (l_debug = 1) THEN
      mydebug('multiple_pick: l_to_lpn_exists : ' || l_to_lpn_exists);
    END IF;

    l_progress            := '90';

    IF (l_to_lpn_exists = 0
        AND p_to_lpn <> '-999') THEN
        -- LPN does not exist, create it
      -- Call Suresh's Create LPN API
      IF (l_debug = 1) THEN
        mydebug('multiple_pick: Creating LPN');
        mydebug('multiple_pick: LPN does not exist');
      END IF;

      wms_container_pub.create_lpn(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_cnt
      , x_msg_data                   => l_msg_data
      , p_lpn                        => p_to_lpn
      , p_organization_id            => p_org_id
      , p_container_item_id          => p_container_item_id
      , p_lot_number                 => l_lot
      , p_revision                   => p_act_rev
      , p_serial_number              => l_fm_serial
      , p_subinventory               => l_to_sub
      , p_locator_id                 => l_to_loc
      , p_source                     => 8
      , p_cost_group_id              => NULL
      , x_lpn_id                     => l_to_lpn_id
      );
      fnd_msg_pub.count_and_get(p_count => l_msg_cnt, p_data => l_msg_data);

      IF (l_msg_cnt = 0) THEN
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: Successful');
        END IF;
      ELSIF(l_msg_cnt = 1) THEN
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: Not Successful');
          mydebug(REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: Not Successful2');
        END IF;

        FOR i IN 1 .. l_msg_cnt LOOP
          l_msg_data  := fnd_msg_pub.get(i, 'F');

          IF (l_debug = 1) THEN
            mydebug(REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
          END IF;
        END LOOP;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSIF p_to_lpn <> '-999' THEN
      IF (l_debug = 1) THEN
        mydebug('multiple_pick: LPN exists');
      END IF;

      l_progress  := '100';

      -- LPN exists. Get LPN ID
      SELECT lpn_id
           , lpn_context
        INTO l_to_lpn_id
           , l_to_lpn_context
        FROM wms_license_plate_numbers
       WHERE license_plate_number = p_to_lpn
         AND organization_id = p_org_id;
    ELSE
      l_to_lpn_id  := NULL;
    END IF;

    l_progress            := '110';

    -- Handle reservations in case of location discrepancy

    IF ((l_sug_loc <> l_act_loc
         OR l_sug_sub <> l_act_sub)
        AND l_reservation_id IS NOT NULL) THEN
      IF (l_debug = 1) THEN
        mydebug('multiple_pick: Sub/Loc discrepancy: Handling reservations');
      END IF;

      l_progress  := '120';

      SELECT subinventory_code,locator_id  --Bug#4339517 . Added locator_id
        INTO l_res_sub,l_res_loc           --Bug#4339517 . Added l_res_loc
        FROM mtl_reservations
       WHERE reservation_id = l_reservation_id
         AND organization_id = p_org_id
         AND inventory_item_id = l_item_id;

      l_progress  := '130';

      IF (l_res_sub = ''
          OR l_res_sub IS NULL) THEN
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: No detailed reservation  ' || l_res_sub);
        END IF;

        if_detailed_reservation  := FALSE;

      --Bug#4339517.Begin
      ELSIF ( (l_res_loc ='' OR l_res_loc is null) and l_res_sub=l_act_sub ) THEN
         IF (l_debug = 1) THEN
            mydebug('multiple_pick:reservation locator is null and subinv matches. So allow transaction');
    END IF;
         if_detailed_reservation  := FALSE;
      --End of fix for bug#4339517.
      ELSE
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: There is detailed reservation  ' || l_res_sub);
        END IF;

        if_detailed_reservation  := TRUE;
      END IF;

      l_progress  := '140';

      IF (if_detailed_reservation = TRUE) THEN
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: Detailed reservation exists. Cannot pick FROM ANY other location');
        END IF;

        /*
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: transfer detailed reservations');
        END IF;

        wms_task_dispatch_gen.check_is_reservable_sub
          (x_return_status     => l_return_status,
           p_organization_id   => p_org_id,
           p_subinventory_code => l_act_sub,
           x_is_reservable_sub => l_is_conf_sub_reservable);

        l_progress := '150';

        IF (l_is_conf_sub_reservable = TRUE) THEN

           IF (l_debug = 1) THEN
             mydebug('multiple_pick: Confirmed sub is reservable');
           END IF;

           l_mtl_reservation_rec.reservation_id := l_reservation_id;

           inv_reservation_pub.query_reservation
             (p_api_version_number        => 1.0,
              x_return_status             => l_return_status,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data,
              p_query_input               => l_mtl_reservation_rec,
              x_mtl_reservation_tbl       => l_mtl_reservation_tbl,
              x_mtl_reservation_tbl_count => l_mtl_reservation_tbl_count,
              x_error_code                => l_error_code);

           l_mtl_reservation_rec := l_mtl_reservation_tbl(1);

           l_progress := '160';

           IF l_pick_qty_remaining > l_mtl_reservation_tbl(1).primary_reservation_quantity THEN
              FND_MESSAGE.SET_NAME('INV','INV_INSUFF_QTY_RSV');
              FND_MSG_PUB.Add;
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;

           --Update loc, sub and locator in new reservation
           l_mtl_reservation_rec.locator_id                   := l_act_loc;
           l_mtl_reservation_rec.subinventory_code            := l_act_sub;
           l_mtl_reservation_rec.revision                     := p_act_rev;
           l_mtl_reservation_rec.reservation_quantity         := l_qty;
           l_mtl_reservation_rec.primary_reservation_quantity := l_pr_qty;

           inv_reservation_pub.transfer_reservation
             (p_api_version_number        => 1.0,
              p_init_msg_lst              => fnd_api.g_false,
              x_return_status             => l_return_status,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data,
              p_original_rsv_rec          => l_mtl_reservation_tbl(1),
              p_to_rsv_rec                => l_mtl_reservation_rec,
              p_original_serial_number    => l_to_serial_number,
              p_to_serial_number          => l_to_serial_number,
              x_to_reservation_id         => l_to_reservation_id);

           l_progress := '170';

           -- Return an error if the transfer reservations call failed
           IF l_return_status <> fnd_api.g_ret_sts_success THEN
              FND_MESSAGE.SET_NAME('INV','INV_TRANSFER_RSV_FAILED');
              FND_MSG_PUB.Add;
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;

         ELSE

           IF (l_debug = 1) THEN
             mydebug('multiple_pick: Confirmed sub is not reservable');
           END IF;

           IF l_pick_qty_remaining <> 0 THEN

              IF (l_debug = 1) THEN
                mydebug('multiple_pick: Cannot transfer detailed reservation as confirmed sub is NOT reservable. cannot pick FROM NEW location. throw error');
              END IF;

              FND_MESSAGE.SET_NAME('INV','INV_TRANSFER_RSV_FAILED');
              FND_MSG_PUB.ADD;
              RAISE FND_API.g_exc_unexpected_error;

           END IF;

           END IF;
          */
        fnd_message.set_name('INV', 'INV_TRANSFER_RSV_FAILED');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --Call any location discrepancy workflow or any other workflow

    --Create MMTT if more quantity needs to be picked
    l_progress            := '200';

    IF (l_pick_qty_remaining <> 0) THEN
      IF (l_debug = 1) THEN
        mydebug('multiple_pick: User has confirmed less quantity');
        mydebug('multiple_pick: MMTT lines need to be split..');
      END IF;

      -- Create new MMTT line with qty and primary qty picked

      SELECT mtl_material_transactions_s.NEXTVAL
        INTO l_new_temp_id
        FROM DUAL;

      l_progress       := '210';
      l_local_temp_id  := l_new_temp_id;

      IF (l_debug = 1) THEN
        mydebug('multiple_pick: l_new_temp_id = ' || l_new_temp_id);
      END IF;

      -- Create new MMTT line

      l_progress       := '270';

      INSERT INTO mtl_material_transactions_temp
                  (
                   transaction_header_id
                 , transaction_temp_id
                 , source_code
                 , source_line_id
                 , transaction_mode
                 , lock_flag
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , last_update_login
                 , request_id
                 , program_application_id
                 , program_id
                 , program_update_date
                 , inventory_item_id
                 , revision
                 , organization_id
                 , subinventory_code
                 , locator_id
                 , transaction_quantity
                 , primary_quantity
                 , transaction_uom
                 , transaction_cost
                 , transaction_type_id
                 , transaction_action_id
                 , transaction_source_type_id
                 , transaction_source_id
                 , transaction_source_name
                 , transaction_date
                 , acct_period_id
                 , distribution_account_id
                 , transaction_reference
                 , requisition_line_id
                 , requisition_distribution_id
                 , reason_id
                 , lot_number
                 , lot_expiration_date
                 , serial_number
                 , receiving_document
                 , demand_id
                 , rcv_transaction_id
                 , move_transaction_id
                 , completion_transaction_id
                 , wip_entity_type
                 , schedule_id
                 , repetitive_line_id
                 , employee_code
                 , primary_switch
                 , schedule_update_code
                 , setup_teardown_code
                 , item_ordering
                 , negative_req_flag
                 , operation_seq_num
                 , picking_line_id
                 , trx_source_line_id
                 , trx_source_delivery_id
                 , physical_adjustment_id
                 , cycle_count_id
                 , rma_line_id
                 , customer_ship_id
                 , currency_code
                 , currency_conversion_rate
                 , currency_conversion_type
                 , currency_conversion_date
                 , ussgl_transaction_code
                 , vendor_lot_number
                 , encumbrance_account
                 , encumbrance_amount
                 , ship_to_location
                 , shipment_number
                 , transfer_cost
                 , transportation_cost
                 , transportation_account
                 , freight_code
                 , containers
                 , waybill_airbill
                 , expected_arrival_date
                 , transfer_subinventory
                 , transfer_organization
                 , transfer_to_location
                 , new_average_cost
                 , value_change
                 , percentage_change
                 , material_allocation_temp_id
                 , demand_source_header_id
                 , demand_source_line
                 , demand_source_delivery
                 , item_segments
                 , item_description
                 , item_trx_enabled_flag
                 , item_location_control_code
                 , item_restrict_subinv_code
                 , item_restrict_locators_code
                 , item_revision_qty_control_code
                 , item_primary_uom_code
                 , item_uom_class
                 , item_shelf_life_code
                 , item_shelf_life_days
                 , item_lot_control_code
                 , item_serial_control_code
                 , item_inventory_asset_flag
                 , allowed_units_lookup_code
                 , department_id
                 , department_code
                 , wip_supply_type
                 , supply_subinventory
                 , supply_locator_id
                 , valid_subinventory_flag
                 , valid_locator_flag
                 , locator_segments
                 , current_locator_control_code
                 , number_of_lots_entered
                 , wip_commit_flag
                 , next_lot_number
                 , lot_alpha_prefix
                 , next_serial_number
                 , serial_alpha_prefix
                 , shippable_flag
                 , posting_flag
                 , required_flag
                 , process_flag
                 , ERROR_CODE
                 , error_explanation
                 , attribute_category
                 , attribute1
                 , attribute2
                 , attribute3
                 , attribute4
                 , attribute5
                 , attribute6
                 , attribute7
                 , attribute8
                 , attribute9
                 , attribute10
                 , attribute11
                 , attribute12
                 , attribute13
                 , attribute14
                 , attribute15
                 , movement_id
                 , reservation_quantity
                 , shipped_quantity
                 , transaction_line_number
                 , task_id
                 , to_task_id
                 , source_task_id
                 , project_id
                 , source_project_id
                 , pa_expenditure_org_id
                 , to_project_id
                 , expenditure_type
                 , final_completion_flag
                 , transfer_percentage
                 , transaction_sequence_id
                 , material_account
                 , material_overhead_account
                 , resource_account
                 , outside_processing_account
                 , overhead_account
                 , flow_schedule
                 , cost_group_id
                 , demand_class
                 , qa_collection_id
                 , kanban_card_id
                 , overcompletion_transaction_id
                 , overcompletion_primary_qty
                 , overcompletion_transaction_qty
                 , end_item_unit_number
                 , scheduled_payback_date
                 , line_type_code
                 , parent_transaction_temp_id
                 , put_away_strategy_id
                 , put_away_rule_id
                 , pick_strategy_id
                 , pick_rule_id
                 , common_bom_seq_id
                 , common_routing_seq_id
                 , cost_type_id
                 , org_cost_group_id
                 , move_order_line_id
                 , task_group_id
                 , pick_slip_number
                 , reservation_id
                 , transaction_status
                 , transfer_cost_group_id
                 , lpn_id
                 , transfer_lpn_id
                 , content_lpn_id
                 , cartonization_id
                 , standard_operation_id
                 , wms_task_type
                 , task_priority
                 , container_item_id
                 , operation_plan_id
                  )
        (SELECT transaction_header_id
              , l_new_temp_id
              , source_code
              , source_line_id
              , transaction_mode
              , lock_flag
              , SYSDATE
              , l_user_id
              , SYSDATE
              , l_user_id
              , last_update_login
              , request_id
              , program_application_id
              , program_id
              , program_update_date
              , inventory_item_id
              , revision
              , organization_id
              , subinventory_code
              , locator_id
              , l_qty
              , l_pr_qty
              , transaction_uom
              , transaction_cost
              , transaction_type_id
              , transaction_action_id
              , transaction_source_type_id
              , transaction_source_id
              , transaction_source_name
              , transaction_date
              , acct_period_id
              , distribution_account_id
              , transaction_reference
              , requisition_line_id
              , requisition_distribution_id
              , reason_id
              , lot_number
              , lot_expiration_date
              , serial_number
              , receiving_document
              , demand_id
              , rcv_transaction_id
              , move_transaction_id
              , completion_transaction_id
              , wip_entity_type
              , schedule_id
              , repetitive_line_id
              , employee_code
              , primary_switch
              , schedule_update_code
              , setup_teardown_code
              , item_ordering
              , negative_req_flag
              , operation_seq_num
              , picking_line_id
              , trx_source_line_id
              , trx_source_delivery_id
              , physical_adjustment_id
              , cycle_count_id
              , rma_line_id
              , customer_ship_id
              , currency_code
              , currency_conversion_rate
              , currency_conversion_type
              , currency_conversion_date
              , ussgl_transaction_code
              , vendor_lot_number
              , encumbrance_account
              , encumbrance_amount
              , ship_to_location
              , shipment_number
              , transfer_cost
              , transportation_cost
              , transportation_account
              , freight_code
              , containers
              , waybill_airbill
              , expected_arrival_date
              , transfer_subinventory
              , transfer_organization
              , transfer_to_location
              , new_average_cost
              , value_change
              , percentage_change
              , material_allocation_temp_id
              , demand_source_header_id
              , demand_source_line
              , demand_source_delivery
              , item_segments
              , item_description
              , item_trx_enabled_flag
              , item_location_control_code
              , item_restrict_subinv_code
              , item_restrict_locators_code
              , item_revision_qty_control_code
              , item_primary_uom_code
              , item_uom_class
              , item_shelf_life_code
              , item_shelf_life_days
              , item_lot_control_code
              , item_serial_control_code
              , item_inventory_asset_flag
              , allowed_units_lookup_code
              , department_id
              , department_code
              , wip_supply_type
              , supply_subinventory
              , supply_locator_id
              , valid_subinventory_flag
              , valid_locator_flag
              , locator_segments
              , current_locator_control_code
              , number_of_lots_entered
              , wip_commit_flag
              , next_lot_number
              , lot_alpha_prefix
              , next_serial_number
              , serial_alpha_prefix
              , shippable_flag
              , posting_flag
              , required_flag
              , process_flag
              , ERROR_CODE
              , error_explanation
              , attribute_category
              , attribute1
              , attribute2
              , attribute3
              , attribute4
              , attribute5
              , attribute6
              , attribute7
              , attribute8
              , attribute9
              , attribute10
              , attribute11
              , attribute12
              , attribute13
              , attribute14
              , attribute15
              , movement_id
              , reservation_quantity
              , shipped_quantity
              , transaction_line_number
              , task_id
              , to_task_id
              , source_task_id
              , project_id
              , source_project_id
              , pa_expenditure_org_id
              , to_project_id
              , expenditure_type
              , final_completion_flag
              , transfer_percentage
              , transaction_sequence_id
              , material_account
              , material_overhead_account
              , resource_account
              , outside_processing_account
              , overhead_account
              , flow_schedule
              , cost_group_id
              , demand_class
              , qa_collection_id
              , kanban_card_id
              , overcompletion_transaction_id
              , overcompletion_primary_qty
              , overcompletion_transaction_qty
              , end_item_unit_number
              , scheduled_payback_date
              , line_type_code
              , parent_transaction_temp_id
              , put_away_strategy_id
              , put_away_rule_id
              , pick_strategy_id
              , pick_rule_id
              , common_bom_seq_id
              , common_routing_seq_id
              , cost_type_id
              , org_cost_group_id
              , move_order_line_id
              , task_group_id
              , pick_slip_number
              , l_to_reservation_id -- This is the new reservation ID
              , transaction_status
              , transfer_cost_group_id
              , NULL -- lpn_id is null for loose
              , l_to_lpn_id -- transfer_lpn_id is toLPN for loose
              , NULL -- content_lpn_id is NULL for loose
              , cartonization_id
              , standard_operation_id
              , wms_task_type
              , task_priority
              , container_item_id
              , operation_plan_id
           FROM mtl_material_transactions_temp
          WHERE transaction_temp_id = l_temp_id);

      l_progress       := '280';

      -- Update original MMTT with the remaining transaction and primary qty

      UPDATE mtl_material_transactions_temp
         SET transaction_quantity = transaction_quantity - l_qty
           , primary_quantity = primary_quantity - l_pr_qty
           , lpn_id = null         --bug 4046834
           , content_lpn_id = null
           , transfer_lpn_id = null
           , last_update_date = SYSDATE
           , last_updated_by = l_user_id
       WHERE transaction_temp_id = l_temp_id;

      IF (l_debug = 1) THEN
        mydebug('multiple_pick: After updating original mmtt ');
      END IF;

      l_progress       := '290';

      ----Put the code for lot/serial items here

      IF l_lot_code > 1 THEN -- lot controlled
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: Inserting Lots');
        END IF;

        SELECT *
          INTO l_mtlt_rec
          FROM mtl_transaction_lots_temp
         WHERE transaction_temp_id = l_temp_id
           AND lot_number = p_lot;

        l_progress                       := '300';

        IF (l_serial_code > 1
            AND l_serial_code <> 6) -- lot serial controlled
           AND p_sn_allocated_flag = 'Y' -- and allocate to serial ON
                                         THEN
          IF (l_debug = 1) THEN
            mydebug('multiple_pick: lot/serial controlled and allocate to serial ON');
          END IF;

          SELECT mtl_material_transactions_s.NEXTVAL
            INTO l_new_serial_temp_id
            FROM DUAL;

          l_progress                             := '310';

          UPDATE mtl_serial_numbers_temp
             SET transaction_temp_id = l_new_serial_temp_id
           WHERE transaction_temp_id = l_mtlt_rec.serial_transaction_temp_id
             AND fm_serial_number = l_fm_serial
             AND to_serial_number = l_to_serial;

          l_progress                             := '320';
          l_mtlt_rec.serial_transaction_temp_id  := l_new_serial_temp_id;
        ELSIF (l_serial_code > 1
               AND l_serial_code <> 6) -- lot serial controlled
              AND p_sn_allocated_flag = 'N' -- and allocate to serial ON
                                            THEN
          IF (l_debug = 1) THEN
            mydebug('multiple_pick: lot controlled only OR lot/serial controlled but Allocate to serial OFF');
          END IF;

          SELECT mtl_material_transactions_s.NEXTVAL
            INTO l_new_serial_temp_id
            FROM DUAL;

          l_progress                             := '330';
          l_mtlt_rec.serial_transaction_temp_id  := l_new_serial_temp_id;
        END IF;

        l_mtlt_rec.transaction_temp_id   := l_new_temp_id;
        l_mtlt_rec.primary_quantity      := l_pr_qty;
        l_mtlt_rec.transaction_quantity  := l_qty;

        IF (l_debug = 1) THEN
          mydebug('multiple_pick: Inserting into MTLT');
          mydebug('multiple_pick: primary_quantity = ' || l_mtlt_rec.primary_quantity);
          mydebug('multiple_pick: transaction_quantity = ' || l_mtlt_rec.transaction_quantity);
          mydebug('multiple_pick: serial_transaction_temp_id = ' || l_mtlt_rec.serial_transaction_temp_id);
        END IF;

        l_progress                       := '340';
        -- Insert new line into MTLT
        inv_rcv_common_apis.insert_mtlt(l_mtlt_rec);
        l_progress                       := '350';

        UPDATE mtl_transaction_lots_temp
           SET primary_quantity = primary_quantity - l_mtlt_rec.primary_quantity
             , transaction_quantity = transaction_quantity - l_mtlt_rec.transaction_quantity
             , last_update_date = SYSDATE
             , last_updated_by = l_user_id
         WHERE transaction_temp_id = l_temp_id
           AND lot_number = p_lot;

        l_progress                       := '360';

        IF (l_debug = 1) THEN
          mydebug('multiple_pick: After lot update');
        END IF;

        --Cleaning original MTLT if txn qty is zero

        DELETE FROM mtl_transaction_lots_temp
              WHERE transaction_quantity = 0
                AND lot_number = p_lot
                AND transaction_temp_id = p_temp_id;

        l_progress                       := '370';
      ELSIF(l_serial_code > 1
            AND l_serial_code <> 6) THEN
        -- serial controlled only

        IF p_sn_allocated_flag = 'Y' THEN
          IF (l_debug = 1) THEN
            mydebug('multiple_pick: Serial Controlled Only and SN allocate ON');
          END IF;

          l_progress  := '380';

          UPDATE mtl_serial_numbers_temp
             SET transaction_temp_id = l_new_temp_id
           WHERE transaction_temp_id = l_temp_id
             AND fm_serial_number = l_fm_serial
             AND to_serial_number = l_to_serial;

          l_progress  := '390';
        END IF;
      END IF;

      -- Insert into tasks table

      l_progress       := '400';

      --Get value from sequence for next task id
      SELECT wms_dispatched_tasks_s.NEXTVAL
        INTO l_next_task_id
        FROM DUAL;

      l_progress       := '410';

      IF (l_debug = 1) THEN
        mydebug('multiple_pick: Before Insert into WMSDT');
      END IF;

      INSERT INTO wms_dispatched_tasks
                  (
                   task_id
                 , transaction_temp_id
                 , organization_id
                 , user_task_type
                 , person_id
                 , effective_start_date
                 , effective_end_date
                 , equipment_id
                 , equipment_instance
                 , person_resource_id
                 , machine_resource_id
                 , status
                 , dispatched_time
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , task_type
                 , loaded_time
                 , operation_plan_id
                 , move_order_line_id
                  )
        (SELECT l_next_task_id
              , l_new_temp_id
              , organization_id
              , user_task_type
              , person_id
              , effective_start_date
              , effective_end_date
              , equipment_id
              , equipment_instance
              , person_resource_id
              , machine_resource_id
              , 3
              , dispatched_time
              , last_update_date
              , last_updated_by
              , creation_date
              , created_by
              , task_type
              , SYSDATE
              , operation_plan_id
              , move_order_line_id
           --to_date(to_char(sysdate,'DD-MON-YYYY HH:MI:SS'),'DD-MON-YYYY HH:MI:SS')
         FROM   wms_dispatched_tasks
          WHERE transaction_temp_id = l_temp_id);
    END IF;

    l_progress            := '420';

    IF (l_from_lpn_id <> 0
        AND l_from_lpn_id IS NOT NULL) THEN
      IF (l_debug = 1) THEN
        mydebug('multiple_pick: LPN has been picked');
      END IF;

      IF (l_pick_qty_remaining = 0) THEN
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: User has picked entire requested quantity. This is packed');
        END IF;

        l_local_temp_id  := l_temp_id;

        IF (l_lot = ''
            OR l_lot IS NULL) THEN
          /* If LPN is an exact match, the multiple pick API is being
          called WITH NULL FOR lot AND serial. hence am checking here. If
            this IS the CASE, we DO NOT need TO INSERT INTO mtlt OR msnt */
          l_lpn_exact_match  := 'Y';
        END IF;
      END IF;

      IF (l_debug = 1) THEN
        mydebug('multiple_pick: l_local_temp_id : ' || l_local_temp_id);
      END IF;

      SELECT subinventory_code
           , locator_id
        INTO l_act_sub
           , l_act_loc
        FROM wms_license_plate_numbers
       WHERE lpn_id = l_from_lpn_id;

      l_progress  := '430';

      IF (p_entire_lpn = 'Y') THEN
        -- for nested LPNs selected for picking items from:start
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: getting outermost LPN for selected lpn ON PKLP');
        END IF;

        SELECT parent_lpn_id
          INTO l_content_parent_lpn_id
          FROM wms_license_plate_numbers
         WHERE lpn_id = l_from_lpn_id
           AND organization_id = p_org_id;

        IF (l_debug = 1) THEN
          mydebug('multiple_pick: outermost LPN for the selected LPN::' || l_content_parent_lpn_id);
        END IF;

        IF (l_content_parent_lpn_id <> l_from_lpn_id) THEN
          IF (l_debug = 1) THEN
            mydebug('multiple_pick: setting lpn_id in MMTT to outermost LPN for nested LPN from PKLP');
          END IF;

          l_lpn_id  := l_content_parent_lpn_id; --TM will take care of this
        ELSE
          l_lpn_id  := NULL;
        END IF;

        -- for nested LPNs selected for picking items from:end

        UPDATE mtl_material_transactions_temp
           SET content_lpn_id = l_from_lpn_id
             , transfer_lpn_id = l_to_lpn_id
             , lpn_id = l_lpn_id
             , subinventory_code = l_act_sub
             , locator_id = l_act_loc
             , transaction_uom = p_act_uom
             , last_update_date = SYSDATE
             , last_updated_by = l_user_id
         WHERE transaction_temp_id = l_local_temp_id;
      ELSE
        UPDATE mtl_material_transactions_temp
           SET transfer_lpn_id = l_to_lpn_id
             , lpn_id = l_from_lpn_id
             , content_lpn_id = NULL
             , subinventory_code = l_act_sub
             , locator_id = l_act_loc
             , transaction_uom = p_act_uom
             , last_update_date = SYSDATE
             , last_updated_by = l_user_id
         WHERE transaction_temp_id = l_local_temp_id;
      END IF;

      l_progress  := '440';

      IF (l_lot_code > 1
          AND l_lpn_exact_match = 'N') THEN
        l_new_serial_temp_id  := NULL;

        IF (l_serial_code > 1
            AND l_serial_code <> 6) THEN
          SELECT NVL(serial_transaction_temp_id, 0)
            INTO l_lot_ser_seq
            FROM mtl_transaction_lots_temp
           WHERE transaction_temp_id = l_local_temp_id
             AND lot_number = l_lot;

          l_progress  := '450';

          IF l_lot_ser_seq = 0 THEN
            SELECT mtl_material_transactions_s.NEXTVAL
              INTO l_new_serial_temp_id
              FROM DUAL;
          ELSE
            l_new_serial_temp_id  := l_lot_ser_seq;
          END IF;

          l_progress  := '460';

          IF p_sn_allocated_flag = 'N' THEN
            INSERT INTO mtl_serial_numbers_temp
                        (
                         transaction_temp_id
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , fm_serial_number
                       , to_serial_number
                        )
                 VALUES (
                         l_new_serial_temp_id
                       , SYSDATE
                       , l_user_id
                       , SYSDATE
                       , l_user_id
                       , l_fm_serial
                       , l_to_serial
                        );
          END IF;

          l_progress  := '470';

          IF (l_debug = 1) THEN
            mydebug('multiple_pick: updating msn for l_new_serial_temp_id = ' || l_new_serial_temp_id);
          END IF;

          UPDATE mtl_serial_numbers
             SET group_mark_id = l_txn_header_id
           WHERE inventory_item_id = l_item_id
             AND current_organization_id = p_org_id
             AND serial_number IN(SELECT fm_serial_number
                                    FROM mtl_serial_numbers_temp msnt
                                   WHERE msnt.transaction_temp_id = l_new_serial_temp_id);

   --Added bug#4245565.Check if any other MSNT records are there for this serial number.
        SELECT count(MSNT.transaction_temp_id)
   INTO   l_serial_count
   FROM   Mtl_Serial_Numbers_Temp MSNT
   WHERE  MSNT.fm_serial_number = l_fm_serial;

   /*Bug#3957819.IF the serial number is already used , throw an error*/
        IF l_serial_count > 1 THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
         END IF;
         /*End of fix for Bug#3957819 */

          l_progress  := '480';
        END IF;

        l_progress            := '490';

        BEGIN
          UPDATE mtl_transaction_lots_temp
             SET transaction_quantity = l_qty
               , primary_quantity = l_pr_qty
               , serial_transaction_temp_id = l_new_serial_temp_id
               , last_update_date = SYSDATE
               , last_updated_by = l_user_id
           WHERE transaction_temp_id = l_local_temp_id
             AND lot_number = p_lot;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
              mydebug('multiple_pick: MTLT did not get updated. Lot number NOT passed');
            END IF;
        END;

        l_progress            := '500';
      ELSIF(l_serial_code > 1
            AND l_serial_code <> 6) THEN
        -- serial controlled only
        l_progress  := '510';

        IF p_sn_allocated_flag = 'N' THEN
          l_real_serial_prefix  := RTRIM(l_fm_serial, '0123456789');
          l_serial_numeric_frm  := TO_NUMBER(SUBSTR(l_fm_serial, NVL(LENGTH(l_real_serial_prefix), 0) + 1));
          l_serial_numeric_to   := TO_NUMBER(SUBSTR(l_to_serial, NVL(LENGTH(l_real_serial_prefix), 0) + 1));
          l_serial_prefix       := (l_serial_numeric_to - l_serial_numeric_frm) + 1;
          mydebug('SERIAL_PREFIX IS :' || l_serial_prefix);

          INSERT INTO mtl_serial_numbers_temp
                      (
                       transaction_temp_id
                     , last_update_date
                     , last_updated_by
                     , creation_date
                     , created_by
                     , fm_serial_number
                     , to_serial_number
                     , serial_prefix
                      )
               VALUES (
                       l_local_temp_id
                     , SYSDATE
                     , l_user_id
                     , SYSDATE
                     , l_user_id
                     , l_fm_serial
                     , l_to_serial
                     , l_serial_prefix
                      );
        END IF;

        l_progress  := '520';

        UPDATE mtl_serial_numbers
           SET group_mark_id = l_txn_header_id
         WHERE inventory_item_id = l_item_id
           AND current_organization_id = p_org_id
           AND serial_number IN(SELECT fm_serial_number
                                  FROM mtl_serial_numbers_temp msnt
                                 WHERE msnt.transaction_temp_id = l_local_temp_id);

       --Added bug#4245565.Check if any other MSNT records are there for this serial number.
        SELECT count(MSNT.transaction_temp_id)
   INTO   l_serial_count
   FROM   Mtl_Serial_Numbers_Temp MSNT
   WHERE  MSNT.fm_serial_number = l_fm_serial;


   /*Bug#3957819.IF the serial number is already used , throw an error*/
        IF l_serial_count > 1 THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
         END IF;
         /*End of fix for Bug#3957819 */

   l_progress  := '530';
      END IF;
    ELSE
      l_progress  := '540';

      IF (l_debug = 1) THEN
        mydebug('multiple_pick: Picked loose');
      END IF;

      IF (l_pick_qty_remaining = 0) THEN
        IF (l_debug = 1) THEN
          mydebug('multiple_pick: User has picked entire requested quantity. This is loose');
        END IF;

        IF (l_debug = 1) THEN
          mydebug('multiple_pick: l_temp_id:' || l_temp_id);
          mydebug('multiple_pick: l_to_lpn_id:' || l_to_lpn_id);
        END IF;

        l_local_temp_id  := l_temp_id;
      END IF;

      UPDATE mtl_material_transactions_temp
         SET transfer_lpn_id = l_to_lpn_id
           , lpn_id = NULL
           , content_lpn_id = NULL
           , subinventory_code = l_act_sub
           , locator_id = l_act_loc
           , last_update_date = SYSDATE
           , last_updated_by = l_user_id
       WHERE transaction_temp_id = l_local_temp_id;

      l_progress  := '550';

      IF l_lot_code > 1 THEN
        IF (l_serial_code > 1
            AND l_serial_code <> 6) THEN
          SELECT NVL(serial_transaction_temp_id, 0)
            INTO l_lot_ser_seq
            FROM mtl_transaction_lots_temp
           WHERE transaction_temp_id = l_local_temp_id
             AND lot_number = l_lot;

          l_progress  := '560';

          IF l_lot_ser_seq = 0 THEN
            SELECT mtl_material_transactions_s.NEXTVAL
              INTO l_new_serial_temp_id
              FROM DUAL;
          ELSE
            l_new_serial_temp_id  := l_lot_ser_seq;
          END IF;

          IF p_sn_allocated_flag = 'N' THEN
            INSERT INTO mtl_serial_numbers_temp
                        (
                         transaction_temp_id
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , fm_serial_number
                       , to_serial_number
                        )
                 VALUES (
                         l_new_serial_temp_id
                       , SYSDATE
                       , l_user_id
                       , SYSDATE
                       , l_user_id
                       , l_fm_serial
                       , l_to_serial
                        );
          END IF;

          l_progress  := '570';

          UPDATE mtl_serial_numbers
             SET group_mark_id = l_txn_header_id
           WHERE inventory_item_id = l_item_id
             AND current_organization_id = p_org_id
             AND serial_number IN(SELECT fm_serial_number
                                    FROM mtl_serial_numbers_temp
                                   WHERE transaction_temp_id = l_new_serial_temp_id);

        --Added bug#4245565.Check if any other MSNT records are there for this serial number.
        SELECT count(MSNT.transaction_temp_id)
   INTO   l_serial_count
   FROM   Mtl_Serial_Numbers_Temp MSNT
   WHERE  MSNT.fm_serial_number = l_fm_serial;

   /*Bug#3957819.IF the serial number is already used , throw an error*/
        IF l_serial_count > 1 THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
         END IF;
         /*End of fix for Bug#3957819 */

          l_progress  := '580';
        END IF;

        UPDATE mtl_transaction_lots_temp
           SET transaction_quantity = l_qty
             , primary_quantity = l_pr_qty
             , serial_transaction_temp_id = l_new_serial_temp_id
             , last_update_date = SYSDATE
             , last_updated_by = l_user_id
         WHERE transaction_temp_id = l_local_temp_id
           AND lot_number = p_lot;

        l_progress  := '590';
      ELSIF(l_serial_code > 1
            AND l_serial_code <> 6) THEN
        -- serial controlled only

        l_progress  := '600';

        IF p_sn_allocated_flag = 'N' THEN
          l_real_serial_prefix  := RTRIM(l_fm_serial, '0123456789');
          l_serial_numeric_frm  := TO_NUMBER(SUBSTR(l_fm_serial, NVL(LENGTH(l_real_serial_prefix), 0) + 1));
          l_serial_numeric_to   := TO_NUMBER(SUBSTR(l_to_serial, NVL(LENGTH(l_real_serial_prefix), 0) + 1));
          l_serial_prefix       := (l_serial_numeric_to - l_serial_numeric_frm) + 1;
          mydebug('SERIAL_PREFIX IS :' || l_serial_prefix);

          INSERT INTO mtl_serial_numbers_temp
                      (
                       transaction_temp_id
                     , last_update_date
                     , last_updated_by
                     , creation_date
                     , created_by
                     , fm_serial_number
                     , to_serial_number
                     , serial_prefix
                      )
               VALUES (
                       l_local_temp_id
                     , SYSDATE
                     , l_user_id
                     , SYSDATE
                     , l_user_id
                     , l_fm_serial
                     , l_to_serial
                     , NVL(l_serial_prefix, 1)
                      );
        END IF;

        l_progress  := '610';

        UPDATE mtl_serial_numbers
           SET group_mark_id = l_txn_header_id
         WHERE inventory_item_id = l_item_id
           AND current_organization_id = p_org_id
           AND serial_number IN(SELECT fm_serial_number
                                  FROM mtl_serial_numbers_temp
                                 WHERE transaction_temp_id = l_local_temp_id);

   --Added bug#4245565.Check if any other MSNT records are there for this serial number.
        SELECT count(MSNT.transaction_temp_id)
   INTO   l_serial_count
   FROM   Mtl_Serial_Numbers_Temp MSNT
   WHERE  MSNT.fm_serial_number = l_fm_serial;

   /*Bug#3957819.IF the serial number is already used , throw an error*/
        IF l_serial_count > 1 THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
         END IF;
        /*End of fix for Bug#3957819 */

        l_progress  := '620';
      END IF;
    END IF;

    l_progress            := '630';

    IF p_is_serial_control = 'true'
       OR p_is_lot_control = 'true' THEN
      IF (l_debug = 1) THEN
        mydebug('multiple_pick: Lot or serial controlled. Do not updated wmsdt AS loaded');
      END IF;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('multiple_pick: Plain item. Update WMSDT as loaded');
      END IF;

      UPDATE wms_dispatched_tasks
         SET status = 4
           , loaded_time = SYSDATE
           , --to_date(to_char(sysdate,'DD-MON-YYYY HH:MI:SS'),'DD-MON-YYYY HH:MI:SS'),
             last_update_date = SYSDATE
           , last_updated_by = l_user_id
       WHERE transaction_temp_id = l_local_temp_id;
    END IF;

    l_progress            := '640';

    IF (l_debug = 1) THEN
      mydebug('multiple_pick: Before checking for pregenerated LPNs');
    END IF;

    -- If the pick-to LPN was pregenerated (context = 5),
    -- Changed the context to be updated to 8 instead of 1 as done earlier

    IF l_to_lpn_context = wms_container_pub.lpn_context_pregenerated THEN
      -- Bug5659809: update last_update_date and last_update_by as well
      UPDATE wms_license_plate_numbers
         SET lpn_context = wms_container_pub.lpn_context_packing
           , last_update_date = SYSDATE
           , last_updated_by = fnd_global.user_id
       WHERE lpn_id = l_to_lpn_id;
    END IF;

    l_progress            := '650';
    x_temp_id             := l_local_temp_id;
    x_return_status       := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('multiple_pick: End of multiple_pick');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO sp_multiple_pick;

      IF (l_debug = 1) THEN
        mydebug('multiple_pick : raise FND_API.G_EXC_ERROR: ' || SQLERRM);
        mydebug('l_progress = ' || l_progress);
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO sp_multiple_pick;

      IF (l_debug = 1) THEN
        mydebug('multiple_pick : raise OTHER exception: ' || SQLERRM);
        mydebug('l_progress = ' || l_progress);
      END IF;
  END multiple_pick;

  PROCEDURE create_lpn(
    p_organization_id               NUMBER
  , p_lpn             IN            VARCHAR2
  , p_lpn_id          OUT NOCOPY    NUMBER
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
  ) IS
    l_lpn_rec       wms_container_pub.lpn;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_exist         NUMBER;
    l_debug         NUMBER                := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_exist                         := 0;
    l_return_status                 := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('In create LPN..');
    END IF;

    l_lpn_rec.license_plate_number  := p_lpn;
    l_exist                         := 0;

    /* SELECT COUNT(*) INTO l_exist FROM wms_license_plate_numbers
     WHERE license_plate_number=p_lpn;*/
    BEGIN
      SELECT 1
        INTO l_exist
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM wms_license_plate_numbers
                     WHERE license_plate_number = p_lpn);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_exist  := 0;
    END;

    IF l_exist = 0 THEN
      IF (l_debug = 1) THEN
        mydebug('LPN Does not exist..');
      END IF;

      wms_container_pub.create_lpn(
        p_api_version                => 1.0
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => x_msg_data
      , p_lpn                        => p_lpn
      , p_organization_id            => p_organization_id
      , x_lpn_id                     => p_lpn_id
      , p_source                     => 3
      );
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => x_msg_data);

      IF (l_msg_count = 0) THEN
        IF (l_debug = 1) THEN
          mydebug('Successful');
        END IF;
      ELSIF(l_msg_count = 1) THEN
        IF (l_debug = 1) THEN
          mydebug('Not Successful');
          mydebug(REPLACE(x_msg_data, fnd_global.local_chr(0), ' '));
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          mydebug('Not Successful2');
        END IF;

        FOR i IN 1 .. l_msg_count LOOP
          x_msg_data  := fnd_msg_pub.get(i, 'F');

          IF (l_debug = 1) THEN
            mydebug(REPLACE(x_msg_data, fnd_global.local_chr(0), ' '));
          END IF;
        END LOOP;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE -- lpn exists
      SELECT lpn_id
        INTO p_lpn_id
        FROM wms_license_plate_numbers
       WHERE license_plate_number = p_lpn;
    END IF;

    x_return_status                 := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_lpn;

  -- p sub, p_loc are user entered values
  -- p_orig_sub, p_orig_loc are system suggested values
  PROCEDURE pick_drop(
    p_temp_id       IN            NUMBER
  , p_txn_header_id IN            NUMBER
  , p_org_id        IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_from_lpn_id   IN            NUMBER
  , p_drop_lpn      IN            VARCHAR2
  , p_loc_reason_id IN            NUMBER
  , p_sub           IN            VARCHAR
  , p_loc           IN            NUMBER
  , p_orig_sub      IN            VARCHAR
  , p_orig_loc      IN            VARCHAR
  , p_user_id       IN            NUMBER
  , p_task_type     IN            NUMBER
  , p_commit        IN            VARCHAR2
  ) IS
    l_temp_id                  NUMBER;
    l_org_id                   NUMBER;
    l_cnt                      NUMBER;
    l_return_status            VARCHAR2(1);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(5000);
    l_mmtt_line_id             NUMBER;
    l_mmtt_qty                 NUMBER;
    l_txn_header_id            NUMBER;
    l_txn_ret                  NUMBER;
    l_transfer_sub             VARCHAR2(10);
    l_transfer_loc             NUMBER;
    l_content_lpn_id           NUMBER;
    l_lpn_id                   NUMBER;
    l_transfer_lpn_id          NUMBER;
    l_tran_type_id             NUMBER;
    l_flow                     NUMBER;
    l_label_status             NUMBER;
    l_del_det_id               NUMBER;
    l_mo_line_id               NUMBER;
    l_label_transaction_id     NUMBER;
    l_period_id                NUMBER;
    l_open_past_period         BOOLEAN;
    l_isdroplpnentered         BOOLEAN;
    l_xfrlpnid                 NUMBER;
    l_lpn_context              NUMBER;
	l_from_lpn_context         NUMBER;  -- Added for bug 12853197
 	l_update_frm_lpn           BOOLEAN:= FALSE;  -- Added for bug 12853197
    l_tran_source_type_id      NUMBER;
    l_tran_action_id           NUMBER;
    -- local variables for workflow
    l_wf                       NUMBER;
    l_sub                      VARCHAR(30);
    l_loc                      NUMBER;
    l_orig_sub                 VARCHAR2(30);
    l_orig_loc                 NUMBER;
    l_loc_reason_id            NUMBER;
    l_user_id                  NUMBER;
    l_task_type                NUMBER;
    l_inventory_item_id        NUMBER;
    l_from_sub                 VARCHAR2(30);
    l_from_loc                 NUMBER;
    l_shipped_wdd_count_in_lpn NUMBER;
    l_open_wdd_count_in_lpn    NUMBER;
    l_is_transfer_sub_lpn NUMBER; /* 3150462*/
    l_check_tasks              NUMBER :=0; --Bug 5318552



    CURSOR mmtt_csr IS
      SELECT mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_header_id = l_txn_header_id
         AND mmtt.organization_id = l_org_id;

    -- VARAJAGO for bug 5222498, added to fetch the group_mark_id details of MSN
    CURSOR msn_stg_mov_csr (lpnid_in_msn NUMBER) IS
           SELECT serial_number
                , organization_id
                , inventory_item_id
                , transaction_temp_id, lpn_id
           FROM wms_wsh_wdd_gtemp WHERE lpn_id = lpnid_in_msn;

    -- DHERRING additional cursor to find all nested LPNs
    CURSOR child_lpns_csr IS
           SELECT lpn_id
           FROM   wms_license_plate_numbers
           START  WITH lpn_id = l_xfrlpnid
           CONNECT BY PRIOR lpn_id = parent_lpn_id;

    -- End of changes for 5222498
    l_debug                    NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    --==================================================
    --R12.1 Replenishment Project (6681109) Starts

    l_index NUMBER;
    l_b_index NUMBER;

    L_ORDER_ID_SORT           VARCHAR2(4) := NULL;
    L_INVOICE_VALUE_SORT      VARCHAR2(4) := NULL;
    L_SCHEDULE_DATE_SORT      VARCHAR2(4) := NULL;
    L_TRIP_STOP_DATE_SORT     VARCHAR2(4) := NULL;
    L_SHIPMENT_PRI_SORT       VARCHAR2(4) := NULL;


    l_detail_info_tab             WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
    l_in_rec                      WSH_INTERFACE_EXT_GRP.detailInRecType;
    l_out_rec                     WSH_INTERFACE_EXT_GRP.detailOutRecType;

    l_detail_id_tab               WSH_UTIL_CORE.id_tab_type;
    l_action_prms                 WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
    l_action_out_rec              WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;
    l_rsv_tbl_tmp    inv_reservation_global.mtl_reservation_tbl_type;

    L_delivery_detail_id NUMBER;
    l_req_quantity_uom VARCHAR2(3);
    L_SHIP_SET_ID NUMBER;
    L_SHIP_MODEL_ID NUMBER;
    l_exists_in_wrd NUMBER;
    l_not_mmtt_row NUMBER;

    l_prev_mol  NUMBER;
    l_wrd_pri_quantity NUMBER;
    l_requested_quantity NUMBER;
    l_demand_pri_qty NUMBER;
    l_primary_uom VARCHAR(3);
    l_repl_type   NUMBER;
    l_repl_level  NUMBER := 1; -- TO DECIDE WHETHER TO PICK_RELEASE DEMAND OR allocate repl MO FOR LEVEL > 1
    l_batch_id    NUMBER;
    l_prev_batch_id NUMBER;
    l_batch_id_tab num_tab;
    l_pick_rel_tab  pick_release_tab;
    j NUMBER;

    L_REMAINING_MMTT_QTY NUMBER;
    l_release_sequence_rule_id NUMBER;
    l_demand_type_id NUMBER;
    l_demand_header_id   NUMBER;
    l_demand_line_id     NUMBER;

    l_attr1 NUMBER;
    l_attr2 NUMBER;
    l_attr3 NUMBER;
    l_attr4 NUMBER;
    l_attr5 NUMBER;


    CURSOR c_mark_demand_rc_csr(p_mo_line_id NUMBER) IS
       SELECT WDD.DELIVERY_DETAIL_ID,
	 MTRL.SHIP_SET_ID,
	 MTRL.SHIP_MODEL_ID,
	 WRD.primary_quantity WRD_PRI_QUANTITY,
	 Nvl(WDD.requested_quantity,0) REQUESTED_QUANTITY,
	 WRD.primary_uom,
	 wrd.repl_type,
	 wrd.repl_level, -- TO DECIDE WHETHER TO PICK_RELEASE DEMAND OR allocate repl MO FOR LEVEL > 1
	 wdd.batch_id,
	 wrd.demand_type_id
	 FROM
	 wms_replenishment_details WRD,
	 MTL_TXN_REQUEST_LINES MTRL,
	 WSH_DELIVERY_DETAILS WDD
	 WHERE WRD.ORGANIZATION_ID = P_ORG_ID
	 AND WRD.SOURCE_LINE_ID    = p_mo_line_id
	 AND wrd.demand_type_id <> 4 -- true only for first level of REPL
	 AND WRD.SOURCE_LINE_ID    = MTRL.LINE_ID
	 AND WRD.SOURCE_HEADER_ID  = MTRL.HEADER_ID
	 AND WRD.ORGANIZATION_ID   = MTRL.ORGANIZATION_ID
	 AND WRD.INVENTORY_ITEM_ID = MTRL.INVENTORY_ITEM_ID
	 AND WRD.DEMAND_LINE_DETAIL_ID  = WDD.delivery_detail_id
	 AND WRD.ORGANIZATION_ID = WDD.organization_id
	 ORDER BY wdd.batch_id, DEMAND_SORT_ORDER;

    CURSOR c_multi_level_repl_alloc(p_mo_line_id NUMBER) IS
       SELECT wrd.demand_header_id,
	 wrd.demand_line_id,
	 WRD.primary_quantity WRD_PRI_QUANTITY,
	 wrd.repl_level, -- TO DECIDE WHETHER TO PICK_RELEASE DEMAND OR allocate repl MO FOR LEVEL > 1
	 wrd.demand_type_id
	 FROM
	 wms_replenishment_details WRD,
	 MTL_TXN_REQUEST_LINES MTRL
	 WHERE WRD.ORGANIZATION_ID = P_ORG_ID
	 AND WRD.SOURCE_LINE_ID    = p_mo_line_id
	 AND wrd.demand_type_id = 4  -- true for multi level repl (>1)
	 AND WRD.SOURCE_LINE_ID    = MTRL.LINE_ID
	 AND WRD.SOURCE_HEADER_ID  = MTRL.HEADER_ID
	 AND WRD.ORGANIZATION_ID   = MTRL.ORGANIZATION_ID
	 AND WRD.INVENTORY_ITEM_ID = MTRL.inventory_item_id
	 ORDER BY DEMAND_SORT_ORDER;

    --bug 9356579 : Since we are tracking all the MO created here through the WRD table,
	--there will not be any situation in which we will end up move order lines that are not part of the WRD table.
	--Even for those MO lines that we did not create ourself rather they were existing and
	--we are netting demand lines against them, we are tracking them in WRD table as well. So Following changes is NOT needed anymore.
	--Blocking this cursor and the usage of the cursor in this code.

 /*	cursor c_untracked_dmd_repl_cur will consider only those demands that are not tracked in WRD table but we have created replenishment move orders for them */

  /*  CURSOR c_untracked_dmd_repl_cur(P_ITEM_ID NUMBER) IS
       SELECT
	 WDD.DELIVERY_DETAIL_ID,
	 wdd.requested_quantity AS PRIMARY_QUANTITY,  -- this is always stored in primary UOM
	   wdd.requested_quantity_uom,

	   -- get for sort_attribute1
	   To_number(DECODE(l_release_sequence_rule_id,
	          null,
                  null,
                  DECODE(g_ordered_psr(1).attribute_name,
                         'ORDER_NUMBER',
                         DECODE(L_ORDER_ID_SORT,
                                'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
			       NULL),
			 'INVOICE_VALUE',
                         wms_replenishment_pvt.GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
                                 'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         wms_replenishment_pvt.GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute1,

           -- get for sort_attribute2
            To_number(DECODE(l_release_sequence_rule_id,
                  null,
                  null,
                  DECODE(g_ordered_psr(2).attribute_name,
                         'ORDER_NUMBER',
			 DECODE(L_ORDER_ID_SORT,
				'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
				NULL),
                         'INVOICE_VALUE',
                         wms_replenishment_pvt.GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
				'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         wms_replenishment_pvt.GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute2,

           -- get for sort_attribute3
            To_number(DECODE(l_release_sequence_rule_id,
                  null,
                  null,
                  DECODE(g_ordered_psr(3).attribute_name,
                         'ORDER_NUMBER',
			 DECODE(L_ORDER_ID_SORT,
				'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
				NULL),
                         'INVOICE_VALUE',
                         wms_replenishment_pvt.GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
				'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         wms_replenishment_pvt.GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute3,

           -- get for sort_attribute4
            To_number(DECODE(l_release_sequence_rule_id,
                  null,
                  null,
                  DECODE(g_ordered_psr(4).attribute_name,
                         'ORDER_NUMBER',
			 DECODE(L_ORDER_ID_SORT,
				'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
				NULL),
			 'INVOICE_VALUE',
                         wms_replenishment_pvt.GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
				'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         wms_replenishment_pvt.GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute4,

           -- get for sort_attribute5
            To_number(DECODE(l_release_sequence_rule_id,
                  null,
                  null,
                  DECODE(g_ordered_psr(5).attribute_name,
                         'ORDER_NUMBER',
			 DECODE(L_ORDER_ID_SORT,
				'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
				null),
                         'INVOICE_VALUE',
                         wms_replenishment_pvt.GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
				'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         wms_replenishment_pvt.GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
			   NULL))) as sort_attribute5

	 FROM
	WSH_DELIVERY_DETAILS wdd
	WHERE
	wdd.source_code = 'OE'
	AND wdd.requested_quantity > 0
	And WDD.ORGANIZATION_ID = L_ORG_ID
	AND WDD.INVENTORY_ITEM_ID = P_ITEM_ID
	-- original status demand lines only
	AND wdd.released_status in ('R','B') and replenishment_status is NULL --9356579
	 AND wdd.subinventory IS NULL  -- since push_repl conc program does not consider forward pick sub either
	  -- these demands should not be part of WRD
	  AND NOT EXISTS (select wrd.demand_line_detail_id
			  from WMS_REPLENISHMENT_DETAILS wrd
			  where wrd.demand_line_detail_id = wdd.delivery_detail_id
			  and wrd.demand_line_id = wdd.source_line_id
			  and wrd.organization_id = wdd.organization_id)
	ORDER BY organization_id, sort_attribute1, sort_attribute2, sort_attribute3, sort_attribute4, sort_attribute5;

Bug 9356579 cursor c_untracked_dmd_repl_cur ends here so unblock */

	-- CURSOR TO GET ALL MMTT LINES ASSOCIATED WITH DROP LPN
	CURSOR C_DROP_LPN_MMTT_LINE_CSR IS
	   SELECT organization_id, TRANSACTION_TEMP_ID, MOVE_ORDER_LINE_ID, INVENTORY_ITEM_ID, PRIMARY_QUANTITY
	     FROM mtl_material_transactions_temp mmtt
	     WHERE TRANSACTION_HEADER_ID = l_txn_header_id
	     AND mmtt.organization_id = l_org_id
	     ORDER BY move_order_line_id asc,primary_quantity desc  ;


	--pl/sql table to store information about mmtt lines that are going to be dropped
	TYPE drop_lpn_item_tbl IS TABLE OF C_DROP_LPN_MMTT_LINE_CSR%ROWTYPE INDEX BY BINARY_INTEGER;
	l_drop_lpn_item_tbl         drop_lpn_item_tbl;


	 --R12 Replenishment Project (6681109) ends



  BEGIN
    IF (l_debug = 1) THEN
      mydebug('In Pick_Drop'||g_pkg_version);
      mydebug('tmpid='||p_temp_id||' hdrid='||p_txn_header_id||' org='||p_org_id||' fmlpn='||p_from_lpn_id||' dplpn='||p_drop_lpn||' locrsn='||p_loc_reason_id);
      mydebug('sub='||p_sub||' loc='||p_loc||' origsub='||p_orig_sub||' origloc='||p_orig_loc||' user='||p_user_id||' tsktyp='||p_task_type||' cmt='||p_commit);
    END IF;

    l_temp_id           := p_temp_id;
    l_org_id            := p_org_id;
    l_return_status     := fnd_api.g_ret_sts_success;
    l_txn_ret           := 0;
    l_txn_header_id     := p_txn_header_id;
    l_cnt               := 0;
    l_isdroplpnentered  := TRUE;
    -- setting local variables for workflow and logging exceptions
    l_wf                := 0;
    l_sub               := p_sub;
    l_loc               := p_loc;
    l_orig_sub          := p_orig_sub;
    l_loc_reason_id     := p_loc_reason_id;

    IF (l_debug = 1) THEN
      mydebug('pick_drop: ' || p_orig_loc || ' : ' || l_orig_sub || ' : ' || l_org_id);
    END IF;

    l_user_id           := p_user_id;
    l_task_type         := p_task_type;

	-- Added for bug 12853197
	SELECT lpn_id
	  , content_lpn_id
	  , transfer_lpn_id
	  , subinventory_code
	  , locator_id
	  , transfer_subinventory
	  , transfer_to_location
	  , transaction_type_id
	  , move_order_line_id
	  , transaction_source_type_id
	  , inventory_item_id
	  , transaction_action_id
    INTO l_lpn_id
	  , l_content_lpn_id
	  , l_transfer_lpn_id
	  , l_from_sub
	  , l_from_loc
	  , l_transfer_sub
	  , l_transfer_loc
	  , l_tran_type_id
	  , l_mo_line_id
	  , l_tran_source_type_id
	  , l_inventory_item_id
	  , l_tran_action_id
    FROM mtl_material_transactions_temp
    WHERE transaction_temp_id = l_temp_id
	AND organization_id = l_org_id;

    IF (p_drop_lpn = ''
        OR p_drop_lpn IS NULL) THEN
      l_isdroplpnentered  := FALSE;

      IF (l_debug = 1) THEN
        mydebug('pick_drop: no drop LPN entered');
      END IF;
    ELSE
      l_isdroplpnentered  := TRUE;

      IF (l_tran_action_id <> 2 OR l_tran_source_type_id NOT IN(4, 13) OR  l_task_type = 7) THEN -- Added for bug 12853197

		  IF (l_debug = 1) THEN
			mydebug('pick_drop: Creating final row for packing. Calling insert_mmtt_pack');
		  END IF;

		  wms_task_dispatch_gen.insert_mmtt_pack(
			p_temp_id                    => p_temp_id
		  , p_lpn_id                     => p_from_lpn_id
		  , p_transfer_lpn               => p_drop_lpn
		  , p_container_item_id          => 0
		  , x_return_status              => l_return_status
		  , x_msg_count                  => l_msg_count
		  , x_msg_data                   => l_msg_data
		  );

		  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
			IF (l_debug = 1) THEN
			  mydebug('pick_drop: Insert MMTT pack Unexpected error');
			END IF;

			fnd_msg_pub.ADD;
			RAISE fnd_api.g_exc_unexpected_error;
		  ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
			IF (l_debug = 1) THEN
			  mydebug('pick_drop: Insert MMTT pack error');
			END IF;

			fnd_msg_pub.ADD;
			RAISE fnd_api.g_exc_error;
		  END IF;
	  END IF; -- Added for bug 12853197
    END IF;

    IF (l_debug = 1) THEN
      mydebug('pick_drop: After call to insert_mmtt_pack');
    END IF;

    /* Commented for bug 12853197
	SELECT lpn_id
         , content_lpn_id
         , transfer_lpn_id
         , subinventory_code
         , locator_id
         , transfer_subinventory
         , transfer_to_location
         , transaction_type_id
         , move_order_line_id
         , transaction_source_type_id
         , inventory_item_id
         , transaction_action_id
      INTO l_lpn_id
         , l_content_lpn_id
         , l_transfer_lpn_id
         , l_from_sub
         , l_from_loc
         , l_transfer_sub
         , l_transfer_loc
         , l_tran_type_id
         , l_mo_line_id
         , l_tran_source_type_id
         , l_inventory_item_id
         , l_tran_action_id
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = l_temp_id
       AND organization_id = l_org_id; */

    BEGIN
       SELECT LPN_CONTROLLED_FLAG
         INTO l_is_transfer_sub_lpn
         FROM mtl_secondary_inventories
        WHERE ORGANIZATION_ID = p_org_id
          AND SECONDARY_INVENTORY_NAME = l_transfer_sub;
    EXCEPTION
       WHEN OTHERS THEN
          l_is_transfer_sub_lpn := 1;
    END;

    IF (l_debug = 1) THEN
        mydebug('l_transfer_sub_lpn :' || l_is_transfer_sub_lpn);
    END IF;

    IF (WMS_CONTROL.get_current_release_level <
        INV_RELEASE.get_j_release_level)
    THEN
       BEGIN
         SELECT 1
           INTO l_cnt
           FROM DUAL
          WHERE EXISTS(SELECT 1
                         FROM mtl_material_transactions_temp
                        WHERE parent_line_id = l_temp_id);
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_cnt  := 0;
       END;

       IF l_cnt > 0 THEN
          IF (l_debug = 1) THEN
             mydebug('pick_drop: Bulk pick line..');
          END IF;

          -- This is a bulk pick consolidated line. We have to update the
          -- child lines with the txn header id

          -- Get the lpn info

          IF l_content_lpn_id IS NULL THEN
             -- User did not pick a complete LPN
             IF (l_debug = 1) THEN
                mydebug('pick_drop: User did not pick entire lpn');
             END IF;

             UPDATE mtl_material_transactions_temp
                SET transaction_header_id = l_txn_header_id
                  , lpn_id                = l_lpn_id
                  , transfer_lpn_id       = l_transfer_lpn_id
                  , transaction_status    = 3
              WHERE parent_line_id  = l_temp_id
                AND organization_id = l_org_id;
          ELSE
             -- User picked a complete LPN
             IF (l_debug = 1) THEN
                mydebug('pick_drop: User picked entire lpn');
             END IF;

             -- Set lpn_id and transfer_lpn_id to be the same
             -- so that the txn manager does not pack or unpack it
             -- We have to do this as kind of a hack because we basically
             -- are picking one complete lpn but fulfilling multiple
             -- mmtt lines

             UPDATE mtl_material_transactions_temp
                SET transaction_header_id = l_txn_header_id
                  , lpn_id                = l_content_lpn_id
                  , transfer_lpn_id       = l_content_lpn_id
                  , content_lpn_id        = NULL
                  , transaction_status    = 3
              WHERE parent_line_id  = l_temp_id
                AND organization_id = l_org_id;

             -- Now update the loc of the LPN

             -- Bug5659809: update last_update_date and last_update_by as well
             UPDATE wms_license_plate_numbers
                SET subinventory_code = l_transfer_sub
                  , locator_id        = l_transfer_loc
                  , last_update_date = SYSDATE
                  , last_updated_by = fnd_global.user_id
              WHERE lpn_id          = l_content_lpn_id
                AND organization_id = l_org_id;
          END IF;

          IF (l_debug = 1) THEN
             mydebug('pick_drop: Deleting orig mmtt bulk pick line..');
          END IF;

          -- Get rid of the original MMTT line (which was a bogus line created
          -- for bulk picking
          DELETE  mtl_material_transactions_temp
            WHERE transaction_temp_id = l_temp_id;
       END IF;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('pick_drop: Determining business flow code...');
    END IF;

    l_flow              := inv_label.wms_bf_pick_drop;

    IF l_tran_type_id = 52 THEN -- Picking for sales order
      l_flow  := inv_label.wms_bf_pick_drop;
    ELSIF l_tran_type_id = 35 THEN -- WIP issue
      l_flow  := inv_label.wms_bf_wip_pick_drop;
    ELSIF l_tran_type_id = 51
          AND l_tran_source_type_id = 13 THEN --Backflush
      l_flow  := inv_label.wms_bf_wip_pick_drop;
    ELSIF l_tran_action_id = 2
          AND l_tran_source_type_id IN(4, 13) THEN --Replenishment
      l_flow  := inv_label.wms_bf_replenishment_drop;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('pick_drop: l_txn_header_id= ' || l_txn_header_id);
      mydebug('pick_drop: l_flow= ' || l_flow);
    END IF;

    IF (l_debug = 1) THEN
      mydebug('pick_drop: Need to check if account period is open before calling TM');
    END IF;

    invttmtx.tdatechk
    ( org_id           => l_org_id
    , transaction_date => SYSDATE
    , period_id        => l_period_id
    , open_past_period => l_open_past_period
    );

    IF l_period_id <> -1 THEN
      IF (l_debug = 1) THEN
        mydebug('pick_drop: Need to update the account period in MMTT');
      END IF;

      UPDATE mtl_material_transactions_temp
         SET acct_period_id = l_period_id
       WHERE transaction_header_id = l_txn_header_id
         AND organization_id = l_org_id;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('pick_drop: Period is invalid');
      END IF;

      fnd_message.set_name('INV', 'INV_NO_OPEN_PERIOD');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- call workflow for location discrepancy
    IF (l_debug = 1) THEN
      mydebug('pick_drop: l_loc_reason_id ' || l_loc_reason_id);
    END IF;

    l_wf                := 0;

    IF (l_loc_reason_id > 0) THEN
      --Log exception
      IF (l_debug = 1) THEN
        mydebug('pick_drop: Logging exceptions for loc discrepancy');
        mydebug('pick_drop: txn_header_id: ' || l_txn_header_id);
        mydebug('l_from_sub: ' || l_from_sub);
        mydebug('l_from_loc: ' || l_from_loc);
        mydebug('l_task type: ' || l_task_type);
        mydebug('l_item id' || l_inventory_item_id);
      END IF;

      FOR rec_mmtt IN mmtt_csr loop
         -- right now we give the from_sub and from_loc until
         -- wms control board is enhanced.
         wms_txnrsn_actions_pub.log_exception
           (p_api_version_number         => 1.0,
            p_init_msg_lst               => fnd_api.g_false,
            p_commit                     => fnd_api.g_false,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data,
            p_organization_id            => l_org_id,
            p_mmtt_id                    => rec_mmtt.transaction_temp_id,
            p_task_id                    => rec_mmtt.transaction_temp_id,
            p_reason_id                  => l_loc_reason_id,
            p_subinventory_code          => l_from_sub,
            p_locator_id                 => l_from_loc,
            p_discrepancy_type           => l_task_type,
            p_user_id                    => l_user_id,
            p_item_id                    => l_inventory_item_id,
            p_revision                   => NULL,
            p_lot_number                 => NULL,
       p_is_loc_desc     => TRUE);  --Added bug 3989684

         IF (l_debug = 1) THEN
            mydebug('pick_drop: after logging exception for temp_id: ' || rec_mmtt.transaction_temp_id);
         END IF;

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;

      END LOOP;

      -- bug 2782039
      -- we now pass in the suggested locator ID directly
      BEGIN
        l_orig_loc  := TO_NUMBER(p_orig_loc);
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            mydebug('pick_drop: converting p_orig_loc : ' || p_orig_loc || '   to l_orig_loc throws exception.');
          END IF;
      END;

      IF (l_debug = 1) THEN
        mydebug('pick_drop: l_orig_loc: ' || l_orig_loc);
      END IF;

      BEGIN
        SELECT 1
          INTO l_wf
          FROM mtl_transaction_reasons
         WHERE reason_id = l_loc_reason_id
           AND workflow_name IS NOT NULL
           AND workflow_name <> ' '
           AND workflow_process IS NOT NULL
           AND workflow_process <> ' ';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_wf  := 0;
      END;

      IF l_wf > 0 THEN
        IF (l_debug = 1) THEN
          mydebug('pick_drop : WF exists for this reason code: ' || l_loc_reason_id);
          mydebug('pick_drop : Calling workflow wrapper FOR location');
        END IF;

        -- Calling Workflow
        wms_workflow_wrappers.wf_wrapper(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_org_id                     => l_org_id
        , p_rsn_id                     => l_loc_reason_id
        , p_calling_program            => 'pick_drop - for loc discrepancy'
        , p_tmp_id                     => l_temp_id
        , p_quantity_picked            => NULL
        , p_dest_sub                   => l_orig_sub
        , p_dest_loc                   => l_orig_loc
        );

        IF (l_debug = 1) THEN
          mydebug('pick_drop : After Calling WF Wrapper');
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
            mydebug('pick_drop : Error callinf WF wrapper');
          END IF;

          fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            mydebug('pick_drop : Error calling WF wrapper');
          END IF;

          fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('pick_drop: Insert WDT History');
    END IF;

    OPEN mmtt_csr;

    LOOP
       FETCH mmtt_csr INTO l_temp_id;
       EXIT WHEN mmtt_csr%NOTFOUND;
       wms_task_dispatch_put_away.archive_task
	 (  p_temp_id                    => l_temp_id
	    , p_org_id                     => l_org_id
	    , x_return_status              => l_return_status
	    , x_msg_count                  => l_msg_count
	    , x_msg_data                   => l_msg_data
	    , p_delete_mmtt_flag           => 'N'
	    , p_txn_header_id              => l_txn_header_id
	    , p_transfer_lpn_id            => NVL(l_transfer_lpn_id, l_content_lpn_id)
	    );
    END LOOP;

    CLOSE mmtt_csr;

    -- Now need to update LPN context appropriately
    IF l_isdroplpnentered = TRUE THEN
       SELECT lpn_id
	 INTO l_xfrlpnid
	 FROM wms_license_plate_numbers
	 WHERE license_plate_number = p_drop_lpn;
     ELSE
       l_xfrlpnid  := p_from_lpn_id;
    END IF;

    l_lpn_context       := wms_container_pub.lpn_context_picked;


    IF l_tran_type_id = 35 THEN -- WIP issue
       l_lpn_context  := wms_container_pub.lpn_context_pregenerated;

     ELSIF l_tran_type_id = 51 AND l_tran_source_type_id = 13 THEN --Backflush
       -- Bug 3954141
       -- If destination subinventory is not lpn controlled
       -- lpn context should be set to defined but not used
       --
       IF (l_is_transfer_sub_lpn = 2)
	 THEN
	  l_lpn_context := wms_container_pub.lpn_context_pregenerated;
	ELSE
	  l_lpn_context  := wms_container_pub.lpn_context_inv;
       END IF;

     ELSIF l_tran_action_id = 2
       AND l_tran_source_type_id IN (13)
       AND l_task_type IN (7) THEN --Staging move
       l_lpn_context  := wms_container_pub.lpn_context_picked;

     ELSIF l_tran_action_id = 2
      AND l_tran_source_type_id IN(4, 13) THEN --Replenishment

	  -- Modified for bug 12853197

	  SELECT count(transaction_temp_id)
			   INTO l_check_tasks
			  FROM mtl_material_transactions_temp mmtt
			 WHERE transfer_lpn_id = l_transfer_lpn_id
			   AND transaction_header_id <> l_txn_header_id;


	  IF (l_is_transfer_sub_lpn = 2)
	   THEN
	     IF (l_debug = 1) THEN
			mydebug('pick_drop: In the condition for l_trs_sub');
			mydebug('pick_drop: Values of l_temp_id:' || l_temp_id);
			mydebug('pick_drop: Values of l_transfer_lpn_id:' || l_transfer_lpn_id);
			mydebug('pick_drop: Values of l_transfer_sub:' || l_transfer_sub);
			mydebug('pick_drop: Values of l_transfer_loc:' || l_transfer_loc);
	     END IF;

		 IF l_check_tasks = 0 THEN
			l_lpn_context := wms_container_pub.LPN_CONTEXT_PREGENERATED;
		 ELSE
			l_lpn_context := wms_container_pub.LPN_CONTEXT_PACKING;
		 END IF;

		 UPDATE mtl_material_transactions_temp
		   SET transfer_lpn_id = NULL
		 WHERE transaction_header_id = l_txn_header_id;

	  ELSE

		IF l_xfrlpnid<>l_transfer_lpn_id THEN

			l_lpn_context  := wms_container_pub.lpn_context_inv;

			UPDATE mtl_material_transactions_temp
			  SET transfer_lpn_id = l_xfrlpnid
			WHERE transaction_header_id = l_txn_header_id;

			IF (l_check_tasks=0) THEN
				l_from_lpn_context := wms_container_pub.LPN_CONTEXT_PREGENERATED;
			ELSE
				l_from_lpn_context := wms_container_pub.LPN_CONTEXT_PACKING;
			END IF;

			l_update_frm_lpn :=TRUE;

		ELSE

			IF l_check_tasks>0 THEN

			l_lpn_context  := wms_container_pub.LPN_CONTEXT_PACKING;

			UPDATE mtl_material_transactions_temp
			  SET transfer_lpn_id = null
			WHERE transaction_header_id = l_txn_header_id;

			ELSE
			   l_lpn_context  := wms_container_pub.lpn_context_inv;
			END IF;
		END IF;

	  END IF;
	  /*
       l_lpn_context  := wms_container_pub.lpn_context_inv;

       --
       -- Bug 3160462:
       -- If its a no lpn controlled transfer
       -- sub xfer lpn should go to define but not used
       --
       IF (l_is_transfer_sub_lpn = 2) THEN

          IF (l_debug = 1) THEN
             mydebug('pick_drop: In the condition for l_trs_sub');
             mydebug('pick_drop: Values of l_temp_id:' || l_temp_id);
             mydebug('pick_drop: Values of l_transfer_lpn_id:' || l_transfer_lpn_id);
             mydebug('pick_drop: Values of l_transfer_sub:' || l_transfer_sub);
             mydebug('pick_drop: Values of l_transfer_loc:' || l_transfer_loc);
	  END IF;

	  --Bug 5318552
	  -- Only if the LPN being dropped does not have any more pending DROPS
	  -- that its context should be set to pregenerated, otherwise to Packing
	  -- (as it was before drop)

	  SELECT count(transaction_temp_id)
	    INTO l_check_tasks
	    FROM mtl_material_transactions_temp mmtt
	    WHERE transfer_lpn_id = l_transfer_lpn_id
	    AND transaction_temp_id <> l_temp_id ;
	  IF l_check_tasks = 0 THEN
	     l_lpn_context := wms_container_pub.LPN_CONTEXT_PREGENERATED;
	   ELSE
	     l_lpn_context := wms_container_pub.LPN_CONTEXT_PACKING;
	  END IF;

	  --End of fix for Bug 5318552

       END IF; */
     ELSIF wms_task_utils_pvt.can_drop(p_lpn_id => p_from_lpn_id) = 'W'  THEN
       -- Sales order cancelled
       l_lpn_context  := wms_container_pub.lpn_context_inv;
    END IF;

    --Bug # 2275770
    --Update mmtt.transaction_date to sysdate
    UPDATE mtl_material_transactions_temp
      SET transaction_date = SYSDATE
      WHERE transaction_header_id = l_txn_header_id;

    -- Now call the txn processor...

    IF (l_debug = 1) THEN
       mydebug('pick_drop: Before Calling txn proc');
    END IF;

    IF l_tran_type_id = 35 THEN
       --
       -- WIP issue
       --
       IF (WMS_CONTROL.get_current_release_level >= INV_RELEASE.get_j_release_level)
	 THEN
          l_txn_ret := inv_lpn_trx_pub.process_lpn_trx
	    ( p_trx_hdr_id         => l_txn_header_id
	      , p_commit             => fnd_api.g_false
	      , p_proc_mode          => 1
	      , x_proc_msg           => l_msg_data
	      , p_business_flow_code => l_flow
	      );

          IF (l_debug = 1) THEN
             mydebug('pick_drop: After Calling txn proc');
             mydebug('pick_drop: Txn proc ret' || l_txn_ret);
          END IF;

          IF l_txn_ret <> 0 THEN
             fnd_message.set_name('WMS', 'WMS_TD_TXNMGR_ERROR');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
	ELSE
          --
          -- Bug 2747945 : Added business flow code to the call to the wip processor.
          --
          IF (l_debug = 1) THEN
             mydebug('pick_drop:seperate call for WIP issue');
          END IF;

          wms_wip_integration.wip_processor
          ( p_txn_hdr_id         => l_txn_header_id
          , p_business_flow_code => l_flow
          , x_return_status      => l_return_status
          );

          IF (l_debug = 1) THEN
             mydebug('pick_drop: After Calling WIP txn proc STATUS' || l_return_status);
          END IF;

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
             fnd_message.set_name('WMS', 'WMS_TD_TXNMGR_ERROR');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF; -- end if release J
    ELSE
      --
      -- Not a WIP issue task
      --
      -- bug 2760062
      -- for Staing move task type
      -- if the LPN contains any WDD line that has been ship-confirmed
      -- do NOT call TM.

       IF l_task_type = 7 THEN
           -- 8714995 added released_status 'X' condition
	 SELECT COUNT(wdd2.lpn_id)
           INTO l_open_wdd_count_in_lpn
           FROM wsh_delivery_details wdd1
              , wsh_delivery_details wdd2
              , wsh_delivery_assignments_v wda
              , wms_license_plate_numbers wlpn
          WHERE wdd2.released_status          = 'X'
            AND wda.parent_delivery_detail_id = wdd2.delivery_detail_id
	    AND wda.delivery_detail_id        = wdd1.delivery_detail_id
            AND wdd2.lpn_id                   = wlpn.lpn_id
            AND wlpn.outermost_lpn_id         = l_content_lpn_id;

	  SELECT COUNT(wdd2.lpn_id)
	    INTO l_shipped_wdd_count_in_lpn
	    FROM wsh_delivery_details wdd1
	    , wsh_delivery_details wdd2
	    , wsh_delivery_assignments_v wda
	    , wms_license_plate_numbers wlpn
	    WHERE wdd1.released_status          = 'C'
            AND wda.delivery_detail_id        = wdd1.delivery_detail_id
            AND wda.parent_delivery_detail_id = wdd2.delivery_detail_id
            AND wdd2.lpn_id                   = wlpn.lpn_id
            AND wlpn.outermost_lpn_id         = l_content_lpn_id;

	  IF (l_open_wdd_count_in_lpn = 0 and l_shipped_wdd_count_in_lpn > 0) THEN
	     IF (l_debug = 1) THEN
		mydebug('pick_drop: this LPN ' || l_content_lpn_id ||
			' contains delivery details lines that have been ship confirmed.');
	     END IF;

	     fnd_message.set_name('WMS', 'WMS_STG_MV_LPN_SHIPPED');
	     fnd_msg_pub.ADD;
	     RAISE fnd_api.g_exc_unexpected_error;
	  END IF;
       END IF;

       -- VARAJAGO for bug 5222498, inserting the serial_number's group_mark_id into the temp table
       -- DHERRING added to change to include nested LPN solution.

      DELETE wms_wsh_wdd_gtemp;
      IF l_tran_type_id = 2 AND l_tran_action_id = 2 AND l_tran_source_type_id = 13
	AND l_lpn_context = 11 THEN -- only for the staging xfer transaction

         FOR rec_child_lpns_csr IN child_lpns_csr LOOP
	    IF (l_debug = 1) THEN
	       mydebug('pick_drop: Xfer LPN id : ' || l_xfrlpnid );
	       mydebug('pick_drop: l_lpn_id : ' || rec_child_lpns_csr.lpn_id );
	       mydebug('pick_drop: p_from_lpn_id : ' || p_from_lpn_id );
	    END IF;

	    INSERT INTO wms_wsh_wdd_gtemp
	      (SERIAL_NUMBER
	       , organization_id
	       , INVENTORY_ITEM_ID
	       , transaction_temp_id
	       , LPN_ID)
	      SELECT serial_number
	      , current_organization_id
	      , inventory_item_id
	      , group_mark_id
	      , lpn_id
	      FROM mtl_serial_numbers
	      WHERE lpn_id = rec_child_lpns_csr.lpn_id;

         END LOOP;
      END IF;
      -- VARAJAGO End of code for bug 5222498.


      --===================================================
      --R12.1 Replenishment Project 6681109 STARTS
      --Store all the Items and qty that are going to be dropped along with this drop LPN
      --Query the MMTT based on the transaction_header_id and get all Item_id and quantity and save them in a PL/SQL table.
      -- Assuming that at the end of the TM processing all these lines will be trnsacted.
      -- Once the TM is called all MMTT will be deleted. So we have to store all this information in a PL/SQL table before the TM call.

      IF l_task_type = 4  THEN -- replenishemnt drop tasks
	 -- BULK UPLOAD ALL cursor records into l_DROP_LPN_ITEM_TBL HERE
	 IF (l_debug = 1) THEN
	    mydebug('Store All mmtt records being dropped for replenishment');
	 END IF;

	 OPEN C_DROP_LPN_MMTT_LINE_CSR;
	 FETCH C_DROP_LPN_MMTT_LINE_CSR BULK COLLECT INTO l_drop_lpn_item_tbl ;
	 CLOSE C_DROP_LPN_MMTT_LINE_CSR;

	 IF (l_debug = 1) THEN
	    mydebug('Repl MMTT records selected - Count :'||l_drop_lpn_item_tbl.COUNT() );
	 END IF;

      END IF;

      --R12.1 Replenishment Project 6681109 ENDS
      --===================================================



      -- Release 12 Shipping Content Enhancement 4645826
      -- For Pick Drop, call label printing after TM, do not pass business flow to TM
      -- For other business flow, call labels through TM

      IF l_flow = inv_label.wms_bf_pick_drop THEN
	 l_txn_ret := inv_lpn_trx_pub.process_lpn_trx
	   ( p_trx_hdr_id         => l_txn_header_id
	     , p_commit             => fnd_api.g_false
	     , p_proc_mode          => 1
	     , x_proc_msg           => l_msg_data
	     , p_business_flow_code => null
	     );
       ELSE
	 -- TM call for Replenishment Drop will come here
	 IF (l_debug = 1) THEN
	    mydebug('TEST: Going to call TM for Replenishment Drop................ ');
	 END IF;
	 l_txn_ret := inv_lpn_trx_pub.process_lpn_trx
	   ( p_trx_hdr_id         => l_txn_header_id
	     , p_commit             => fnd_api.g_false
	     , p_proc_mode          => 1
	     , x_proc_msg           => l_msg_data
	     , p_business_flow_code => l_flow
	     );
      END IF;
      -- End 4645826


      IF (l_debug = 1) THEN
	 mydebug('pick_drop: After Calling txn proc');
	 mydebug('pick_drop: Txn proc ret' || l_txn_ret);
      END IF;

      IF l_txn_ret <> 0 THEN
	 fnd_message.set_name('WMS', 'WMS_TD_TXNMGR_ERROR');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- for l_tran_type_id <> 35


    --===================================================
    -- R12.1 replenishment Project 6681109  STARTS -----

    IF  l_txn_ret = 0 AND l_task_type = 4  THEN -- replenishment drop task
       IF (l_debug = 1) THEN
	  mydebug('Consume replenishment related demands..STARTS....HERE ');
       END IF;


       FOR CNT IN 1..l_DROP_LPN_ITEM_TBL.COUNT() LOOP
	  IF (l_debug = 1) THEN
	     mydebug('Processing Item_Id :'|| L_DROP_LPN_ITEM_TBL(CNT).inventory_item_id||', Qty :'
		     || L_DROP_LPN_ITEM_TBL(CNT).primary_quantity||', MO_Line_ID :'
		     || L_DROP_LPN_ITEM_TBL(CNT).move_order_line_id);
	  END IF;

	  L_REMAINING_MMTT_QTY:= L_DROP_LPN_ITEM_TBL(CNT).PRIMARY_QUANTITY;

	  IF L_REMAINING_MMTT_QTY > 0 THEN

	     -- See it the move order line is part of WRD table
	     -- Existance check only if the MOL changes from the previous MMTT record
	     IF l_prev_mol IS NULL OR l_prev_mol <>
	       L_DROP_LPN_ITEM_TBL(CNT).move_order_line_id THEN

               BEGIN
		  SELECT 1, demand_type_id INTO l_exists_in_wrd, l_demand_type_id
		    FROM  wms_replenishment_details wrd
		    WHERE WRD.ORGANIZATION_ID = P_ORG_ID
		    AND WRD.SOURCE_LINE_ID =  L_DROP_LPN_ITEM_TBL(CNT).MOVE_ORDER_LINE_ID
		    AND WRD.INVENTORY_ITEM_ID = L_DROP_LPN_ITEM_TBL(CNT).INVENTORY_ITEM_ID
		    AND ROWNUM = 1;

	       EXCEPTION
		  WHEN no_data_found THEN
		     IF (l_debug = 1) THEN
			mydebug('Move Order Line NOT found in WRD');
		     END IF;
		     l_exists_in_wrd := 0;
		  WHEN OTHERS THEN
		     l_exists_in_wrd := 0;
	       END;

	     END IF; --   IF l_prev_mol IS NULL OR l_prev_mol <>

	     IF (l_debug = 1) THEN
		mydebug('IF the MOL exists in WRD :' ||l_exists_in_wrd);
		mydebug('MOL demand_type_id       :' ||l_demand_type_id);
	     END IF;


	     IF l_exists_in_wrd = 1 THEN -- consume demand from WRD table

		IF l_demand_type_id = 4 THEN -- means multi level repl
		   -- code will come here only for repl_level > 1 based on l_demand_type_id
		   -- find all associated demand move order lines and allocate them

		   OPEN c_multi_level_repl_alloc(L_DROP_LPN_ITEM_TBL(CNT).move_order_line_id) ;
		   LOOP
		      FETCH  c_multi_level_repl_alloc INTO l_demand_header_id,l_demand_line_id,
			l_wrd_pri_quantity,l_repl_level, l_demand_type_id;

		      EXIT WHEN c_multi_level_repl_alloc%NOTFOUND;

		      IF (l_debug = 1) THEN
			 mydebug('Move Order Header                :' || l_demand_header_id);
			 mydebug('Replenishment Level              :' || l_repl_level);
			 mydebug('Demand Type Id                   :' || l_demand_type_id);
			 mydebug('Primary MO Quantity              :' || l_wrd_pri_quantity);
			 mydebug('Calling Allocation Engine for MO :' || l_demand_line_id);
		      END IF;

		      -- Call Allocation engine for allocate MO
		      WMS_Engine_PVT.create_suggestions(
							p_api_version    => 1.0,
							p_init_msg_list  => fnd_api.g_false,
							p_commit         => fnd_api.g_false,
							p_validation_level => fnd_api.g_valid_level_none,
							x_return_status => l_return_status,
							x_msg_count     => l_msg_count,
							x_msg_data      => l_msg_data,
							p_transaction_temp_id => l_demand_line_id,
							p_reservations   => l_rsv_tbl_tmp, --No rsv FOR repl MO
							p_suggest_serial => fnd_api.g_false,
							p_plan_tasks     =>	FALSE
							);

		      IF l_return_status <> fnd_api.g_ret_sts_success THEN
			 IF (l_debug = 1) THEN
			    mydebug('Move Order Allocation Failed, Move to next one');
			 END IF;
			 -- do nothing, skip this

		       ELSE  -- Move order got allocated successfully
			 -- remove the record from the WRD table

			 DELETE FROM  WMS_REPLENISHMENT_DETAILS
			   WHERE organization_id = p_org_id
			   AND demand_type_id = 4
			   AND demand_header_id = l_demand_header_id
			   AND demand_line_id = l_demand_line_id;


		      END IF;

		   END LOOP;
		   CLOSE c_multi_level_repl_alloc;

		 ELSE --means l_demand_type_id <> 4; demand is WDD

			 -- code will come here only for repl_level = 1
		   -- Mark RC to demand lines that are part of C_MARK_DEMAND_RC_CSR
		   -- And pick release these lines if part of dynamic repl
		   l_index   := 0;
		   l_b_index := 0;
		   OPEN  c_mark_demand_rc_csr(L_DROP_LPN_ITEM_TBL(CNT).move_order_line_id) ;
		   LOOP
		      FETCH  c_mark_demand_rc_csr INTO l_delivery_detail_id, L_SHIP_SET_ID,
			l_SHIP_MODEL_ID,
			l_wrd_pri_quantity,l_REQUESTED_QUANTITY,
			l_primary_uom, l_repl_type,l_repl_level, l_batch_id,l_demand_type_id;

		      EXIT WHEN c_mark_demand_rc_csr%notfound;

		      IF (l_debug = 1) THEN
			 mydebug('Currently Consuming REPL MO for Repl Level :'||l_repl_level);
			 mydebug('l_demand_type_id :'||l_demand_type_id);
		      END IF;

		      -- Verify level of replenishment
		      IF l_repl_level = 1 THEN  -- replenishment for original demand
			 IF l_wrd_pri_quantity <= l_requested_quantity THEN
			    l_demand_pri_qty :=  l_wrd_pri_quantity;
			  ELSE
			    l_demand_pri_qty :=  l_requested_quantity;
			 END IF;

		       ELSE -- invalid value of repl level
			 IF (l_debug = 1) THEN
			    mydebug('Invalid Value of Replenishment Level, skip this demand');
			 END IF;

		      END IF;

		      IF L_REMAINING_MMTT_QTY >= L_DEMAND_PRI_QTY THEN
			 IF (l_debug = 1) THEN
			    mydebug('repl completion qty is greater  than tied up demand qty');
			    mydebug('Mark the delivery detail to RC - detail_id :' ||l_delivery_detail_id);
			 END IF;

			 -- CALL SHIPPING API TO MARK THESE DELIVERY DETAILS AS 'RC' based on
			 --l_delivery_detail_id

			 wms_replenishment_pvt.update_wdd_repl_status
			   (p_deliv_detail_id   =>  l_delivery_detail_id
			    , p_repl_status     => 'C' -- for completed status
			    , x_return_status   => l_return_status
			    );

			 IF l_return_status <> fnd_api.g_ret_sts_success THEN
			    -- do nothing, skip this
			    GOTO next_repl_demand;
			 END IF;


			 --Remove the entry from the WRD table
			 DELETE FROM  WMS_REPLENISHMENT_DETAILS
			   WHERE  organization_id = p_org_id
			   AND DEMAND_LINE_DETAIL_ID= l_delivery_detail_id;

			 -- Decrease the current MMTT qty
			 L_REMAINING_MMTT_QTY := L_REMAINING_MMTT_QTY - L_DEMAND_PRI_QTY;


		       ELSE --  means (l_demand_pri_qty > l_remaining_mmtt_qty )

			 IF (l_debug = 1) THEN
			    mydebug('repl completion qty is LESS than tied up demand qty');
			    mydebug('SPLIT the delivery line');
			 END IF;

			 -- Split the original deamand line
			 -- the newly created demand line will have qty =(L_DEMAND_PRI_QTY - L_REMAINING_MMTT_QTY)
			 -- WITH original 'RR" status . The shipping API with 'SPLIT-LINE' action in turn calls
			 -- the wms_replenishment_pvt.update_delivery_detail() API that insert the newly created
			 --  record with RR status in the WRD table AND updates the qty to l_remaining_mmtt_qty
			 -- for the old delivery_detail record in the WRD table

			 -- So after calling for the split-line action, I need to call shipping
			 -- AND mark the original delivery detail line to 'RC' and delete this WRD record


			 l_detail_id_tab.DELETE;
			 l_action_prms := NULL;
			 l_detail_id_tab(1) := l_delivery_detail_id;
			 -- Caller needs to be WSH_PUB in order for shipping to allow this action
			 l_action_prms.caller := 'WSH_PUB';
			 l_action_prms.action_code := 'SPLIT-LINE';
			 l_action_prms.split_quantity := (L_DEMAND_PRI_QTY - L_REMAINING_MMTT_QTY) ;

			 WSH_INTERFACE_GRP.Delivery_Detail_Action
			   (p_api_version_number  => 1.0,
			    p_init_msg_list       => fnd_api.g_false,
			    p_commit              => fnd_api.g_false,
			    x_return_status       => l_return_status,
			    x_msg_count           => x_msg_count,
			    x_msg_data            => x_msg_data,
			    p_detail_id_tab       => l_detail_id_tab,
			    p_action_prms         => l_action_prms,
			    x_action_out_rec      => l_action_out_rec
			    );

			 IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
			    IF (l_debug = 1) THEN
			       mydebug('Error returned from Split Delivery_Detail_Action API..skip this demand');
			    END IF;
			       -- do nothing, skip this demand line
			    GOTO next_repl_demand;

			  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
			    IF (l_debug = 1) THEN
			       mydebug('Unexpected errror from Split Delivery_Detail_Action API..skip this demand');
			    END IF;
			    -- do nothing, skip this demand line
			    GOTO next_repl_demand;
			 END IF;

			 -- At this point the new delivery is already inserted in the WRD table.
			 -- AND the qty for original delivery has been updated
			 -- TO l_remaining_mmtt_qty IN WRD as above api calls
			 -- wms_replenishment_pvt.update_delivery_detail() internally.
			 -- SO JUST MARK original delivery replenishment_status  RC
			 -- and then delete the original record from the WRD table

			 wms_replenishment_pvt.update_wdd_repl_status
			   (p_deliv_detail_id   =>  l_delivery_detail_id
			    , p_repl_status     => 'C' -- for completed status
			    , x_return_status   => l_return_status
			    );

			 IF l_return_status <> fnd_api.g_ret_sts_success THEN
			    IF (l_debug = 1) THEN
			       mydebug('Errror from Delivery_Detail_Action api to mark RC...skip this demand');
			    END IF;
			    -- do nothing, skip this demand line
			    GOTO next_repl_demand;
			 END IF;


			 -- delete the original demand as it was marked RC
			 -- nwely created delviery will be in WRD as 'RR'
			 DELETE FROM  WMS_REPLENISHMENT_DETAILS
			   WHERE DEMAND_LINE_DETAIL_ID= l_delivery_detail_id;

			 L_REMAINING_MMTT_QTY := 0;

		      END IF; -- for L_REMAINING_MMTT_QTY >= L_DEMAND_PRI_QTY


		      -- Pick Release associated demand lines as well only FOR repl_level = 1
		      -- Store all these delivery_detail_ids and release in bulk per batch_id
		      IF l_repl_type = 2 THEN -- pick release only if part of dynamic replenishment
			 IF L_SHIP_SET_ID IS NULL and L_SHIP_MODEL_ID IS NULL THEN

			    IF (l_debug = 1) THEN
			       mydebug('NOT part OF ship Set/Model Pick Releasing delivery Detail :'||l_delivery_detail_id);
			       mydebug('Current Batch_id :'||l_batch_id);
			    END IF;
			    -- Store all deliv_detail_ids

			    l_index:= l_index +1;
			    l_pick_rel_tab(l_index).delivery_detail_id := l_delivery_detail_id;
			    l_pick_rel_tab(l_index).batch_id           := l_batch_id;

			    IF (l_prev_batch_id IS NULL) OR l_prev_batch_id <> l_batch_id THEN
			       IF (l_debug = 1) THEN
				  mydebug('Got distinct batch, adding to the TABLE :'||l_batch_id);
			       END IF;
			       l_b_index := l_b_index +1;
			       l_batch_id_tab(l_b_index) := l_batch_id;
			    END IF;

			  ELSE  -- means ship set or ship model exists
			    -- check if this is the last RC status move_order line in the batch of ship set / ship model;
			    -- If Yes, then pick release all move_orders lines in the batch
			    -- We are postponing the support for ship set / ship model for later release ???
			    IF (l_debug = 1) THEN
				  mydebug('DO NOT Pick Release Demand Lines. Part OF ship Set/Model ');
			    END IF;
			 END IF;-- means ship set or ship model
		      END IF; -- for  IF l_repl_type = 2

		      EXIT WHEN L_REMAINING_MMTT_QTY= 0;

		      <<next_repl_demand>>
			l_prev_batch_id := l_batch_id;
		   END LOOP;
		   CLOSE c_mark_demand_rc_csr;
		END IF; -- for l_demand_type_id = 4
	     END IF;  -- for l_exists_in_wrd = 1


-- Bug 9356579 call of cursor c_untracked_dmd_repl_cur so blocking the below code as it is no more reqd. Read comment given during cursor definition.
/*	     IF (l_debug = 1) THEN
		mydebug('Check if REPL MOL is not tracked in WRD to replenish wdd demand Lines');
	     END IF;

	     -- in general all records for MO line should have same value OF l_repl_level FOR a move order
	     -- taking default l_repl_level value unless it gets overwritten by value of
	     -- last rcord IN above loop
	     IF (l_repl_level =1 AND (l_exists_in_wrd <> 1)  OR
		 (l_repl_level =1 AND l_exists_in_wrd = 1 AND L_REMAINING_MMTT_QTY > 0 )) THEN
		-- Either some remaining qty after consuming demand from WRD OR move order line is not part of WRD table

		IF (l_debug = 1) THEN
		   mydebug('Either MO is not part od WRD OR Qty left out exhausting qty IN wrd tracked MO Lines ');
		   mydebug('Related Demand lines will NOT be released...');
		END IF;

                BEGIN
		   select pick_sequence_rule_id
		     INTO l_release_sequence_rule_id
		     from wsh_shipping_parameters
		     where organization_id = l_org_id;
		EXCEPTION
		   WHEN no_data_found THEN
		      l_release_sequence_rule_id := NULL;
		END;

		IF (l_debug = 1) THEN
		   mydebug('PICK SEQUENCE RULE ID FOR THE ORG :'||l_release_sequence_rule_id);
		END IF;

		-- Get the Order By Clause based on Pick Release Rule
		--initialize gloabl variables
		-- delete old value
		g_ordered_psr.DELETE;
		wms_replenishment_pvt.init_rules
		  (p_pick_seq_rule_id    =>  l_release_sequence_rule_id,
		   x_order_id_sort       =>  l_ORDER_ID_SORT,
		   x_INVOICE_VALUE_SORT  =>  l_INVOICE_VALUE_SORT,
		   x_SCHEDULE_DATE_SORT  =>  l_SCHEDULE_DATE_SORT,
		   x_trip_stop_date_sort =>  l_TRIP_STOP_DATE_SORT,
		   x_SHIPMENT_PRI_SORT   =>  l_shipment_pri_sort,
		   x_ordered_psr         =>  g_ordered_psr,
		   x_api_status          =>  l_return_status );

		IF (l_debug = 1) THEN
		   mydebug('Status after calling init_rules'||l_return_status);
		END IF;

		IF (l_return_status = fnd_api.g_ret_sts_success) THEN
		   IF (l_debug = 1) THEN
		      mydebug('init_rules returned Success, Processing untracked demand lines');
		   END IF;

		     -- Mark RC to demand lines that are part of c_untracked_dmd_repl_cur
		     -- DO NOT PICK RELEASE THESE LINES
		     OPEN c_untracked_dmd_repl_cur(L_DROP_LPN_ITEM_TBL(CNT).inventory_item_id);
		   LOOP
		      FETCH c_untracked_dmd_repl_cur INTO
			l_delivery_detail_id, l_demand_pri_qty, l_req_quantity_uom,
			l_attr1,l_attr2,l_attr3,l_attr4,l_attr5 ;
		      EXIT WHEN c_untracked_dmd_repl_cur%NOTFOUND;

		      IF (l_debug = 1) THEN
			 mydebug('Currently processing detail_id :'||l_delivery_detail_id);
		      END IF;


		      IF L_REMAINING_MMTT_QTY >= L_DEMAND_PRI_QTY THEN
			 IF (l_debug = 1) THEN
			    mydebug('MO Qty >= Demand Qty; Mark demand as RC ');
			 END IF;

			 wms_replenishment_pvt.update_wdd_repl_status
			   (p_deliv_detail_id   =>  l_delivery_detail_id
			    , p_repl_status     => 'C' -- for completed status
			    , x_return_status   => l_return_status
			    );

			 IF l_return_status <> fnd_api.g_ret_sts_success THEN
			    IF (l_debug = 1) THEN
			       mydebug('Errror from Delivery_Detail_Action api to mark RC...skip this demand');
			    END IF;
			    -- DO NOTHING, SKIP THIS DEMAND LINE
			    GOTO next_untrkd_dmd;
			 END IF;

			 -- Nothing in the WRD table ot start with
			 -- Just decrease the current MMTT qty
			 L_REMAINING_MMTT_QTY := L_REMAINING_MMTT_QTY -  L_DEMAND_PRI_QTY;


		       ELSE -- means mmtt qty is less than demand qty
			 IF (l_debug = 1) THEN
			    mydebug('MO Qty < Demand Qty; Split the demand.... ');
			 END IF;

			 -- Split the original deamand line
			 -- the newly created demand line will have qty =(L_DEMAND_PRI_QTY - L_REMAINING_MMTT_QTY) WITH
			 -- original status . The shipping API with 'SPLIT-LINE' action in turn calls
			 -- the wms_replenishment_pvt.update_delivery_detail()
			 -- API but in this case since original
			 -- delivery_detial was NOT tracked in the WRD table
			 -- to start with, nothing happens there. In shipping,
			 -- we have a new split WDD though

			 -- So after calling for the split-line action, I need to call shipping
			 -- AND mark the original delivery detail line to 'RC' and delete this WRD record

			 l_detail_id_tab.DELETE;
			 l_action_prms := NULL;
			 l_detail_id_tab(1) := l_delivery_detail_id;
			 -- Caller needs to be WSH_PUB in order for shipping to allow this action
			 l_action_prms.caller := 'WSH_PUB';
			 l_action_prms.action_code := 'SPLIT-LINE';
			 l_action_prms.split_quantity := (L_DEMAND_PRI_QTY - L_REMAINING_MMTT_QTY) ;

			 WSH_INTERFACE_GRP.Delivery_Detail_Action
			   (p_api_version_number  => 1.0,
			    p_init_msg_list       => fnd_api.g_false,
			    p_commit              => fnd_api.g_false,
			    x_return_status       => l_return_status,
			    x_msg_count           => x_msg_count,
			    x_msg_data            => x_msg_data,
			    p_detail_id_tab       => l_detail_id_tab,
			    p_action_prms         => l_action_prms,
			    x_action_out_rec      => l_action_out_rec
			    );

			 IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
			    IF (l_debug = 1) THEN
			       mydebug('Error returned from Split Delivery_Detail_Action API..skip this demand Line');
			    END IF;
			    -- DO NOTHING, SKIP THIS DEMAND LINE
			    GOTO next_untrkd_dmd;
			  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
			    IF (l_debug = 1) THEN
			       mydebug('Unexpected errror from Split Delivery_Detail_Action API..skip this demand Line');
			    END IF;
			    -- DO NOTHING, SKIP THIS DEMAND LINE
			    GOTO next_untrkd_dmd;
			 END IF;

			 -- At this point the new delivery is already inserted in the WRD table.
			 -- AND the qty for original delivery has been updated
			 -- TO l_remaining_mmtt_qty IN WRD as above api calls
			 -- wms_replenishment_pvt.update_delivery_detail() internally.
			 -- SO JUST MARK original delviery replenishment_status  RC
			 -- and then delete the original record from the WRD table

			 wms_replenishment_pvt.update_wdd_repl_status
			   (p_deliv_detail_id   =>  l_delivery_detail_id
			    , p_repl_status     => 'C' -- for completed status
			    , x_return_status   => l_return_status
			    );

			 IF l_return_status <> fnd_api.g_ret_sts_success THEN
			    -- DO NOTHING, SKIP THIS DEMAND LINE
			    GOTO next_untrkd_dmd;
			 END IF;

			 -- In this case the original delivery was NOT tracked
			 -- in the WRD table. So no need to delete WRD

			 L_REMAINING_MMTT_QTY := 0;


		      END IF; -- for L_REMAINING_MMTT_QTY => L_DEMAND_PRI_QTY

		      EXIT WHEN L_REMAINING_MMTT_QTY =0;

		      <<next_untrkd_dmd>>
			NULL;

		   END LOOP;
		   CLOSE c_untracked_dmd_repl_cur;

		 ELSE --init_rules returned error

			 IF (l_debug = 1) THEN
			    mydebug('init_rules returned Error, Can NOT mark demand lines RC');
			 END IF	;

		END IF; -- for init_rules returned success

	     END IF; --for IF (l_repl_level =1 AND (l_exists_in_wrd <> 1)

	end of code-block done as a part of fix for bug 9356579*/


	  END IF; -- FOR L_REMAINING_MMTT_QTY > 0

	  l_prev_mol :=  L_DROP_LPN_ITEM_TBL(CNT).move_order_line_id;
       END LOOP; -- for L_DROP_LPN_ITEM_TBL.COUNT

    END IF; -- l_task_type = 4
    -- R12.1 replenishment Project 6681109 ENDS -----
    --===================================================


    -- VARAJAGO for bug 5222498, getting the grup_mark_id for the serial_number from temp table
    -- and update MSN.
    IF l_tran_type_id = 2 AND l_tran_action_id = 2 AND l_tran_source_type_id = 13
                AND l_lpn_context = 11 THEN -- only for staging move tranasction
		mydebug('pick_drop: INSIDE IF');
           FOR rec_child_lpns_csr IN child_lpns_csr LOOP -- for the Nested LPNs.
		mydebug('pick_drop: INSIDE FOR rec_child_lpns_csr : ' || rec_child_lpns_csr.lpn_id);
               FOR rec_msn_stg_mov_csr IN msn_stg_mov_csr(rec_child_lpns_csr.lpn_id) LOOP -- for the SNs matching the lpn_id
			mydebug('pick_drop: INSIDE FOR rec_msn_stg_mov_csr');
                   IF (l_debug = 1) THEN
                           mydebug('pick_drop: serial_number :' || rec_msn_stg_mov_csr.serial_number);
                           mydebug('pick_drop: group_mark_id :' || rec_msn_stg_mov_csr.transaction_temp_id);
                           mydebug('pick_drop: lpn_id :' || rec_msn_stg_mov_csr.lpn_id);
                   END IF;

                   UPDATE mtl_serial_numbers
                   SET mtl_serial_numbers.group_mark_id = rec_msn_stg_mov_csr.transaction_temp_id
                   WHERE mtl_serial_numbers.serial_number = rec_msn_stg_mov_csr.serial_number
                   AND mtl_serial_numbers.current_organization_id = rec_msn_stg_mov_csr.organization_id
                   AND mtl_serial_numbers.inventory_item_id = rec_msn_stg_mov_csr.inventory_item_id
                   AND mtl_serial_numbers.lpn_id = rec_msn_stg_mov_csr.lpn_id;

               END LOOP;

           END LOOP;

    END IF;
    -- End of changes for 5222498
	--12595055 adding for LPN context remains packing context when dropped to non lpn controlled sub after lot substitution..
	IF (l_is_transfer_sub_lpn = 2 AND l_tran_action_id = 2 AND l_tran_source_type_id IN(4, 13)) THEN
	  SELECT count(transaction_temp_id)
	    INTO l_check_tasks
	    FROM mtl_material_transactions_temp mmtt
	    WHERE transfer_lpn_id = l_transfer_lpn_id
	    AND transaction_temp_id <> l_temp_id ;
	  IF l_check_tasks = 0 THEN
	     l_lpn_context := wms_container_pub.LPN_CONTEXT_PREGENERATED;
	   ELSE
	     l_lpn_context := wms_container_pub.LPN_CONTEXT_PACKING;
	  END IF;
	END IF;
	  --12595055 End

    IF (l_debug = 1) THEN
      mydebug('pick_drop: call to modify_lpn_wrapper with lpn_context of ' || l_lpn_context);
	  mydebug('coming to my debug to print the value of l_check_tasks ' || l_check_tasks);
	  mydebug('coming to my debug to print the value of l_temp_id ' || l_temp_id);
	  mydebug('coming to my debug to print the value of l_transfer_lpn_id ' || l_transfer_lpn_id);
    END IF;

    -- Bug 4238917 no longer update lpn_context to 11 outside of TM
    IF ( l_lpn_context <> wms_container_pub.lpn_context_picked ) THEN
      wms_container_pub.modify_lpn_wrapper
      ( p_api_version   => 1.0
      , x_return_status => l_return_status
      , x_msg_count     => l_msg_count
      , x_msg_data      => l_msg_data
      , p_lpn_id        => l_xfrlpnid
      , p_lpn_context   => l_lpn_context
      );

      -- Added for bug 12853197
	  IF l_update_frm_lpn=TRUE THEN

        IF ( l_from_lpn_context <> wms_container_pub.lpn_context_picked ) THEN
          wms_container_pub.modify_lpn_wrapper
          ( p_api_version   => 1.0
          , x_return_status => l_return_status
          , x_msg_count     => l_msg_count
          , x_msg_data      => l_msg_data
          , p_lpn_id        => l_transfer_lpn_id
          , p_lpn_context   => l_from_lpn_context

          );
        ELSE
        /*Bug#6677616. For picked LPN, we will call the below API inorder to update shipping
          about the weight, volume etc of LPN so that it gets reflected in shipping tables.*/
        wms_container_pub.modify_lpn_wrapper
          ( p_api_version   => 1.0
          , x_return_status => l_return_status
          , x_msg_count     => l_msg_count
          , x_msg_data      => l_msg_data
          , p_lpn_id        => l_transfer_lpn_id
          );
        END IF;

      END IF;
   ELSE
    /*Bug#6712364. For picked LPN, we will call the below API(wihout hcnaging anything) inorder to
     update shipping about the weight, volume etc of LPN so that it gets reflected in shipping tables.*/
     wms_container_pub.modify_lpn_wrapper
      ( p_api_version   => 1.0
      , x_return_status => l_return_status
      , x_msg_count     => l_msg_count
      , x_msg_data      => l_msg_data
      , p_lpn_id        => l_xfrlpnid
      );
   END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          mydebug('pick_drop: modify_lpn_wrapper Unexpected error');
        END IF;

        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          mydebug('pick_drop: modify_lpn_wrapper error');
        END IF;

        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      -- Bug 4238917 no longer update lpn_context to 11 outside of TM
      /*
      -- IF droplpngenerated and lpn_context = PICKED then update the
      -- lpn_context of the from_lpn also.
      IF l_isdroplpnentered = TRUE THEN
        IF l_lpn_context = wms_container_pub.lpn_context_picked THEN
          wms_container_pub.modify_lpn_wrapper(
            p_api_version                => 1.0
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , p_lpn_id                     => p_from_lpn_id
          , p_lpn_context                => l_lpn_context
          );
        END IF;
      END IF; */
    --END IF;

    -- Release 12 Shipping Content Enhancement 4645826
    -- For Pick Drop, call label printing after TM,
    IF (l_debug = 1) THEN
       mydebug('Pick Drop, calling label printing API with l_lpn_id '||nvl(l_xfrlpnid,nvl(l_transfer_lpn_id, l_content_lpn_id)));
    END IF;
    IF l_flow = inv_label.wms_bf_pick_drop THEN
       INV_LABEL.PRINT_LABEL_MANUAL_WRAP(
          x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , x_msg_data            => l_msg_data
        , x_label_status        => l_label_status
        , p_business_flow_code  => l_flow
        , p_lpn_id              => nvl(l_xfrlpnid,nvl(l_transfer_lpn_id, l_content_lpn_id))
       );
    END IF;
    -- End 4645826

    IF p_commit = 'Y'
    THEN
       COMMIT;
    END IF;

    --===================================================
    -- R12.1 replenishment Project 6681109 STARTS  -----

    -- WE NEED TO COMMIT ONCE SO THAT PICK RELEASE CONCURRENT PROGRAM BELOW
    -- CAN SEE MOVED MATERIAL FOR DROPPED TASKS.
    IF  l_txn_ret = 0 AND l_task_type = 4  THEN -- replenishment drop task

       IF (l_debug = 1) THEN
	  mydebug('Processing Pick Release of Dmd Lines in batch...');
	  mydebug('Number of batch_ids processed togather :'||l_batch_id_tab.count());
       END IF;

       -- Call the Pick release per batch_id
       -- l_batch_id_tab stores only UNIQUE batch_id
       -- l_pick_rel_tab stores unique delivery_detail_id with respective batch_id

       FOR i IN 1 .. l_batch_id_tab.count() LOOP
	  l_detail_id_tab.DELETE;
	  l_action_prms := NULL;
	  l_cnt := 0;
	  IF (l_debug = 1) THEN
	     mydebug('****** Calling Pick Release with Batch_id :' ||l_batch_id_tab(i));
	  END IF;

	  <<inner>>
	    FOR j IN 1 .. l_pick_rel_tab.count() LOOP
	       IF l_batch_id_tab(i) = l_pick_rel_tab(j).batch_id THEN
		  l_cnt := l_cnt +1;
		  l_detail_id_tab(l_cnt) := l_pick_rel_tab(j).delivery_detail_id;
	       END IF;
	       EXIT inner WHEN l_pick_rel_tab(j).batch_id > l_batch_id_tab(i);
	       -- Since inserted records has alredy been ordered by batch_id
	    END LOOP;

	    -- Call the pick release with l_batch_id_tab(i) AND l_detail_id_tab
	    IF (l_debug = 1) THEN
	       mydebug('Number of delivery details in this batch :'||l_detail_id_tab.COUNT());
	    END IF;

	    l_action_prms.caller := 'WSH_PUB';
	    l_action_prms.batch_id := l_batch_id_tab(i);
	    l_action_prms.action_code :=  'PICK-RELEASE';

	    WSH_INTERFACE_GRP.Delivery_Detail_Action
	      (p_api_version_number  => 1.0,
	       p_init_msg_list       => fnd_api.g_false,
	       p_commit              => fnd_api.g_false,
	       x_return_status       => l_return_status,
	       x_msg_count           => x_msg_count,
	       x_msg_data            => x_msg_data,
	       p_detail_id_tab       => l_detail_id_tab,
	       p_action_prms         => l_action_prms,
	       x_action_out_rec      => l_action_out_rec
	       );

	    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	       IF (l_debug = 1) THEN
		  mydebug('Error from Split Delivery_Detail_Action API..nothing TO be done');
	       END IF;
	     ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	       IF (l_debug = 1) THEN
		  mydebug('Unexpected error Split Delivery_Detail_Action API....nothing TO be done');
	       END IF;
	    END IF;

       END LOOP;

       --clear tables
       l_batch_id_tab.DELETE;
       l_pick_rel_tab.DELETE;

       IF (l_debug = 1) THEN
	  mydebug('AFTER Calling Repl Pick Release (in Batch) Status :'||l_return_status );
       END IF;

    END IF; --  IF  l_txn_ret = 0 AND l_task_type = 4


    IF p_commit = 'Y'
      THEN
       COMMIT;
    END IF;
    -- R12.1 replenishment Project 6681109 ENDS -----
    --===================================================


    x_return_status     := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('pick_drop: done WITH Pick Drop API');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        mydebug('pick_drop: Error in pick_drop API: ' || SQLERRM);
      END IF;

      fnd_message.set_name('WMS', 'WMS_TD_PICK_DROP_FAIL');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        mydebug('pick_drop: Unexpected Error in pick_drop API: ' || SQLERRM);
      END IF;

      fnd_message.set_name('WMS', 'WMS_TD_PICK_DROP_FAIL');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END pick_drop;

  PROCEDURE pick_by_label(
    p_sign_on_emp_id        IN            NUMBER
  , p_sign_on_org_id        IN            NUMBER
  , p_sign_on_zone          IN            VARCHAR2
  , p_sign_on_equipment_id  IN            NUMBER
  , p_sign_on_equipment_srl IN            VARCHAR2
  , p_task_type             IN            VARCHAR2
  , x_nbr_tasks             OUT NOCOPY    NUMBER
  , p_lpn_id                IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  ) IS
    l_cartonization_id   NUMBER                                := NULL;
    task_rec             wms_task_dispatch_gen.task_rec_tp;
    l_task_cur           wms_task_dispatch_gen.task_rec_cur_tp;
    l_user_id            NUMBER;
    l_emp_id             NUMBER;
    l_org_id             NUMBER;
    l_zone               VARCHAR2(10);
    l_eqp_id             NUMBER;
    l_eqp_ins            VARCHAR2(30);
    l_task_type          VARCHAR2(30);
    l_c_rows             NUMBER;
    l_next_task_id       NUMBER;
    l_per_res_id         NUMBER;
    l_mac_res_id         NUMBER;
    l_std_op_id          NUMBER;
    l_operation_plan_id  NUMBER;
    l_move_order_line_id NUMBER;
    l_priority           NUMBER;
    l_wms_task_type      NUMBER;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(4000);
    l_return_status      VARCHAR2(1);
    l_lpn_id             NUMBER;
    l_mmtt_rowcnt        NUMBER;
    l_wdt_rowcnt         NUMBER;
    l_undispatched_picks NUMBER;
    l_txn_hdr_id         NUMBER;
    l_debug              NUMBER                                := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('pick_by_label: In Pick By Label API');
    END IF;

    l_return_status  := fnd_api.g_ret_sts_success;
    l_user_id        := p_sign_on_emp_id;
    l_org_id         := p_sign_on_org_id;
    l_zone           := p_sign_on_zone;
    l_eqp_id         := p_sign_on_equipment_id;
    l_eqp_ins        := p_sign_on_equipment_srl;
    l_task_type      := p_task_type;
    l_c_rows         := 0;
    l_next_task_id   := 0;
    l_std_op_id      := 1;
    l_priority       := 1;
    l_wms_task_type  := 1;
    l_lpn_id         := p_lpn_id;

    IF (l_debug = 1) THEN
      mydebug('pick_by_label: get employee id');
    END IF;

    l_emp_id         := l_user_id;

    IF (l_debug = 1) THEN
      mydebug('pick_by_label: emp id:' || l_emp_id);
    END IF;

    l_mmtt_rowcnt    := 0;
    l_wdt_rowcnt     := 0;

    IF l_eqp_id = -999 THEN
      l_eqp_id  := NULL;
    END IF;

    IF l_lpn_id = 0 THEN
      l_lpn_id  := NULL;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('pick_by_label: Getting undispatched MMTT rows for this lpn..');
    END IF;

    SELECT COUNT(*)
      INTO l_mmtt_rowcnt
      FROM mtl_material_transactions_temp m
     WHERE m.cartonization_id IS NOT NULL
       AND m.cartonization_id = l_lpn_id
       AND parent_line_id IS NULL;

    IF (l_debug = 1) THEN
      mydebug('pick_by_label: MMTT rows' || l_mmtt_rowcnt);
    END IF;

    IF l_mmtt_rowcnt > 0 THEN
      -- There are MMTT tasks for this LPN
      SELECT COUNT(*)
        INTO l_wdt_rowcnt
        FROM mtl_material_transactions_temp m, wms_dispatched_tasks t
       WHERE m.cartonization_id = l_lpn_id
         AND t.transaction_temp_id = m.transaction_temp_id
         AND t.status = 4;

      IF (l_debug = 1) THEN
        mydebug('pick_by_label: WDT rows' || l_wdt_rowcnt);
      END IF;

      l_undispatched_picks  := l_mmtt_rowcnt - l_wdt_rowcnt;

      IF (l_debug = 1) THEN
        mydebug('pick_by_label: Undispatched Picks' || l_undispatched_picks);
      END IF;

      IF l_undispatched_picks > 0 THEN
        -- There are undispatched picks!

        -- Need to call the TD engine here primarily to ensure user
        -- is eligible for task



        IF (l_debug = 1) THEN
          mydebug('pick_by_label: Before Calling TD Engine');
        END IF;

        IF l_lpn_id = fnd_api.g_miss_num THEN
          l_lpn_id  := NULL;
        END IF;

        --TEST have TO change eqpid to not null later
        --Call Lei's TD Engine
        wms_task_dispatch_engine.dispatch_task(
          p_api_version                => 1.0
        , p_init_msg_list              => 'F'
        , p_commit                     => NULL
        , p_sign_on_emp_id             => l_emp_id
        , p_sign_on_org_id             => l_org_id
        , p_sign_on_zone               => l_zone
        , p_sign_on_equipment_id       => l_eqp_id
        , p_sign_on_equipment_srl      => l_eqp_ins
        , p_task_type                  => 'ALL'
        , x_task_cur                   => l_task_cur
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_cartonization_id           => l_lpn_id
        );

        IF (l_debug = 1) THEN
          mydebug('pick_by_label: Ret Stst11' || l_return_status);
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_success THEN
          LOOP
            FETCH l_task_cur INTO task_rec;
            EXIT WHEN l_task_cur%NOTFOUND;
            l_c_rows  := l_c_rows + 1;

            IF (l_debug = 1) THEN
              mydebug('pick_by_label: TaskID:' || task_rec.task_id);
            END IF;

            IF (l_debug = 1) THEN
              mydebug('pick_by_label: getting Resource ID....');
            END IF;

            SELECT bremp.resource_id role_id
                 , t.wms_task_type
                 , t.standard_operation_id
                 , t.operation_plan_id
                 , t.move_order_line_id
              INTO l_per_res_id
                 , l_wms_task_type
                 , l_std_op_id
                 , l_operation_plan_id
                 , l_move_order_line_id
              FROM mtl_material_transactions_temp t, bom_std_op_resources bsor, bom_resources bremp
             WHERE t.transaction_temp_id = task_rec.task_id
               AND t.standard_operation_id = bsor.standard_operation_id
               AND bsor.resource_id = bremp.resource_id
               AND bremp.resource_type = 2
               AND ROWNUM < 2;

            IF (l_debug = 1) THEN
              mydebug('pick_by_label: After getting Resource ID....');
            END IF;

            IF l_eqp_id IS NOT NULL THEN
              -- bug fix 1772907, lezhang

              SELECT resource_id
                INTO l_mac_res_id
                FROM bom_resource_equipments
               WHERE inventory_item_id = l_eqp_id
                 AND ROWNUM < 2;
            /*
            select  breqp.resource_id equip_type_id
              INTO l_mac_res_id
              from mtl_material_transactions_temp t,
              bom_std_op_resources bsor,
              bom_resources breqp
              where t.transaction_temp_id = task_rec.task_id
              and t.standard_operation_id = bsor.standard_operation_id
              and bsor.resource_id = breqp.resource_id
              and breqp.resource_type = 1
              and rownum<2;
              */
            END IF;

            SELECT mtl_material_transactions_s.NEXTVAL txnhdrid
              INTO l_txn_hdr_id
              FROM DUAL;

            UPDATE mtl_material_transactions_temp
               SET transaction_header_id = l_txn_hdr_id
             WHERE transaction_temp_id = task_rec.task_id;

            -- Insert into WMS_DISPATCHED_TASKS for this user

            --Get value from sequence for next task id
            SELECT wms_dispatched_tasks_s.NEXTVAL
              INTO l_next_task_id
              FROM DUAL;

            --mydebug('pick_by_label: Before Insert into WMSDT');


            INSERT INTO wms_dispatched_tasks
                        (
                         task_id
                       , transaction_temp_id
                       , organization_id
                       , user_task_type
                       , person_id
                       , effective_start_date
                       , effective_end_date
                       , equipment_id
                       , equipment_instance
                       , person_resource_id
                       , machine_resource_id
                       , status
                       , dispatched_time
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , task_type
                       , priority
                       , operation_plan_id
                       , move_order_line_id
                        )
                 VALUES (
                         l_next_task_id
                       , task_rec.task_id
                       , l_org_id
                       , NVL(l_std_op_id, 2)
                       , l_user_id
                       , SYSDATE
                       , SYSDATE
                       , l_eqp_id
                       , l_eqp_ins
                       , l_per_res_id
                       , l_mac_res_id
                       , 3
                       , SYSDATE
                       , SYSDATE
                       , l_emp_id
                       , SYSDATE
                       , l_emp_id
                       , l_wms_task_type
                       , task_rec.task_priority
                       , l_operation_plan_id
                       , l_move_order_line_id
                        );

            IF (l_debug = 1) THEN
              mydebug('pick_by_label: After Insert into WMSDT');
            END IF;
       /* BUG3209582 Pick By Label should dispatch all the tasks belonging to the
         Cartonized LPN to the same user else all the tasks are not dispatched to
         user continuously
            -- If LPN has been provided, exit, since we only want the first
            --task
            IF l_lpn_id IS NULL
               OR l_lpn_id = fnd_api.g_miss_num THEN
              IF (l_debug = 1) THEN
                mydebug('pick_by_label: LPN was not provided');
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('pick_by_label: LPN was provided - pick by label');
              END IF;

              -- Setting nbr of tasks
              x_nbr_tasks  := l_undispatched_picks;
              EXIT;
            END IF; */
          END LOOP;
      x_nbr_tasks  := l_undispatched_picks;--bug3209582

          -- Committing these tasks to this user
          IF (l_debug = 1) THEN
            mydebug('pick_by_label: before commiting');
          END IF;

          COMMIT;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          fnd_message.set_name('WMS', 'WMS_TD_TDENG_ERROR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            mydebug('pick_by_label: Setting status to S');
          END IF;

          l_return_status  := fnd_api.g_ret_sts_success;

          -- TD Engine brought back 0 tasks.
          -- Since there are undispatched tasks for this LPN,
          -- it means that this user is not eligible for this task
          IF (l_debug = 1) THEN
            mydebug('pick_by_label: Ineligible USer');
          END IF;

          x_nbr_tasks      := -1;
        END IF;
      ELSE
        -- There are no undipatched tasks, hence user can drop off the task
        x_nbr_tasks  := 0;
      END IF; -- l_undispatched_picks>0 end if
    ELSE -- l_mmtt_rowcnt>0  if
      IF (l_debug = 1) THEN
        mydebug('pick_by_label: There are no mmtt rows for this LPN');
      END IF;

      x_nbr_tasks  := -1;
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END pick_by_label;

  PROCEDURE manual_pick(
    p_sign_on_emp_id        IN            NUMBER
  , p_sign_on_org_id        IN            NUMBER
  , p_sign_on_zone          IN            VARCHAR2 := NULL
  , p_sign_on_equipment_id  IN            NUMBER := NULL
  , p_sign_on_equipment_srl IN            VARCHAR2 := NULL
  , p_task_type             IN            VARCHAR2 := 'PICKING'
  , p_pick_slip_id          IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  ) IS
    task_rec             wms_task_dispatch_gen.task_rec_tp;
    l_task_cur           wms_task_dispatch_gen.task_rec_cur_tp;
    l_user_id            NUMBER;
    l_emp_id             NUMBER;
    l_org_id             NUMBER;
    l_zone               VARCHAR2(10);
    l_eqp_id             NUMBER;
    l_eqp_ins            VARCHAR2(30);
    l_task_type          VARCHAR2(30);
    l_c_rows             NUMBER;
    l_next_task_id       NUMBER;
    l_per_res_id         NUMBER;
    l_mac_res_id         NUMBER;
    l_std_op_id          NUMBER;
    l_operation_plan_id  NUMBER;
    l_move_order_line_id NUMBER;
    l_priority           NUMBER;
    l_wms_task_type      NUMBER;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(4000);
    l_return_status      VARCHAR2(1);
    l_pick_slip_id       NUMBER;
    l_mmtt_rowcnt        NUMBER;
    l_wdt_rowcnt         NUMBER;
    l_undispatched_picks NUMBER;
    l_txn_hdr_id         NUMBER;
    l_debug              NUMBER                                := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  /*6009436 Begin */
    CURSOR c_fm_to_serial_number IS
        SELECT
          msnt.fm_serial_number,
          msnt.to_serial_number
          FROM  mtl_serial_numbers_temp msnt
          WHERE msnt.transaction_temp_id = p_pick_slip_id;

     CURSOR c_fm_to_lot_serial_number IS
        SELECT
          msnt.fm_serial_number,
          msnt.to_serial_number
          FROM
          mtl_serial_numbers_temp msnt,
          mtl_transaction_lots_temp mtlt
          WHERE mtlt.transaction_temp_id = p_pick_slip_id
          AND   msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;

    l_item_id            NUMBER := NULL;
    l_serial_ctrl_code   NUMBER;
    l_lot_ctrl_code      NUMBER ;
    l_fm_serial_number   MTL_SERIAL_NUMBERS_TEMP.FM_SERIAL_NUMBER%TYPE;
    l_to_serial_number   MTL_SERIAL_NUMBERS_TEMP.TO_SERIAL_NUMBER%TYPE;
   /*6009436 End */

  BEGIN
    IF (l_debug = 1) THEN
      mydebug('manual_pick: In Manual Pick API');
    END IF;

    l_return_status  := fnd_api.g_ret_sts_success;
    l_user_id        := p_sign_on_emp_id;
    l_org_id         := p_sign_on_org_id;
    l_zone           := p_sign_on_zone;
    l_eqp_id         := p_sign_on_equipment_id;
    l_eqp_ins        := p_sign_on_equipment_srl;
    l_task_type      := p_task_type;
    l_c_rows         := 0;
    l_next_task_id   := 0;
    l_std_op_id      := 1;
    l_priority       := 1;
    l_wms_task_type  := 1;
    l_pick_slip_id   := p_pick_slip_id;

    IF (l_debug = 1) THEN
      mydebug('manual_pick: get employee id');
    END IF;

    l_emp_id         := l_user_id;

    IF (l_debug = 1) THEN
      mydebug('manual_pick: emp id:' || l_emp_id);
    END IF;

    l_mmtt_rowcnt    := 0;
    l_wdt_rowcnt     := 0;

    IF l_eqp_id = -999 THEN
      l_eqp_id  := NULL;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('manual_pick: Getting  MMTT rows for this pick_Slip_id..');
    END IF;

-- bug 2729509 :Restricting the user not to load the child task
-- which are merged using bulk pick. Added the condition parent_line_id
-- not null for the same.

    BEGIN
      SELECT 1
        INTO l_mmtt_rowcnt
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM mtl_material_transactions_temp
                     WHERE transaction_temp_id = l_pick_slip_id
                     AND parent_line_id is NULL);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug('manual_pick: No mmtt rows found for pick slip' || l_pick_slip_id);
        END IF;

        l_mmtt_rowcnt  := 0;
        fnd_message.set_name('WMS', 'WMS_INVALID_PICKID');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    IF (l_debug = 1) THEN
      mydebug('manual_pick: MMTT rows' || l_mmtt_rowcnt);
    END IF;

    IF l_mmtt_rowcnt > 0 THEN
      -- Check if this line has been sent to somebody else

      BEGIN
        SELECT 1
          INTO l_wdt_rowcnt
          FROM DUAL
         WHERE EXISTS(SELECT 1
                        FROM wms_dispatched_tasks t
                       WHERE t.transaction_temp_id = l_pick_slip_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_wdt_rowcnt  := 0;
      END;

      IF l_wdt_rowcnt > 0 THEN
        IF (l_debug = 1) THEN
          mydebug('manual_pick: WDT rows' || l_wdt_rowcnt);
          mydebug('manual_pick: Task has been assigned to somebody else');
        END IF;

        fnd_message.set_name('WMS', 'WMS_TASK_UNAVAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        IF (l_debug = 1) THEN
          mydebug('manual_pick: getting Resource ID....');
        END IF;

        BEGIN
          SELECT bremp.resource_id role_id
               , t.wms_task_type
               , t.standard_operation_id
               , t.operation_plan_id
               , t.move_order_line_id
               , t.inventory_item_id  --Bug#6009436
            INTO l_per_res_id
               , l_wms_task_type
               , l_std_op_id
               , l_operation_plan_id
               , l_move_order_line_id
               , l_item_id            --Bug6009436
            FROM mtl_material_transactions_temp t, bom_std_op_resources bsor, bom_resources bremp
           WHERE t.transaction_temp_id = l_pick_slip_id
             AND t.standard_operation_id = bsor.standard_operation_id
             AND bsor.resource_id = bremp.resource_id
             AND bremp.resource_type = 2
             AND t.organization_id = l_org_id  --Bug # 3704626
             AND ROWNUM < 2;

          IF (l_debug = 1) THEN
            mydebug('manual_pick: After getting Resource ID....');
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
              mydebug('manual_pick: No Person Resource ID found');
            END IF;

            RAISE fnd_api.g_exc_error;
        END;

        IF l_eqp_id IS NOT NULL THEN
          BEGIN
            -- bug fix 1772907, lezhang

            SELECT resource_id
              INTO l_mac_res_id
              FROM bom_resource_equipments
             WHERE inventory_item_id = l_eqp_id
               AND ROWNUM < 2;
          /*
          select  breqp.resource_id equip_type_id
      INTO l_mac_res_id
      from mtl_material_transactions_temp t,
      bom_std_op_resources bsor,
      bom_resources breqp
      where t.transaction_temp_id = task_rec.task_id
      and t.standard_operation_id = bsor.standard_operation_id
      and bsor.resource_id = breqp.resource_id
      and breqp.resource_type = 1
      and rownum<2;
      */
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                mydebug('manual_pick: No Machine Resource ID found');
              END IF;

              RAISE fnd_api.g_exc_error;
          END;
        END IF;

        -- Insert into WMS_DISPATCHED_TASKS for this user

        --Get value from sequence for next task id
        SELECT wms_dispatched_tasks_s.NEXTVAL
          INTO l_next_task_id
          FROM DUAL;

        --mydebug('manual_pick: Before Insert into WMSDT');

        SELECT mtl_material_transactions_s.NEXTVAL txnhdrid
          INTO l_txn_hdr_id
          FROM DUAL;

        UPDATE mtl_material_transactions_temp
           SET transaction_header_id = l_txn_hdr_id
         WHERE transaction_temp_id = l_pick_slip_id;

         --Bug6009436.Begin
	SELECT msi.serial_number_control_code
             , msi.lot_control_code
          INTO l_serial_ctrl_code
             , l_lot_ctrl_code
         FROM mtl_system_items msi
	 WHERE msi.inventory_item_id = l_item_id
         AND msi.organization_id =p_sign_on_org_id ;

	  IF (l_debug = 1) THEN
               mydebug('manual_pick:serial control code:'||l_serial_ctrl_code || ',lot control code :'||l_lot_ctrl_code);
           END IF;

	 IF (l_serial_ctrl_code NOT IN (1,6)  ) THEN  --Serial controlled item
          BEGIN
	   IF (l_lot_ctrl_code > 1 ) THEN             --Serial and lot controlled item
   	     OPEN c_fm_to_lot_serial_number;
             LOOP
                FETCH c_fm_to_lot_serial_number
                INTO l_fm_serial_number,l_to_serial_number;
                EXIT WHEN c_fm_to_lot_serial_number%NOTFOUND;

	        UPDATE MTL_SERIAL_NUMBERS msn
	        SET  GROUP_MARK_ID=l_txn_hdr_id
	        WHERE msn.current_organization_id=p_sign_on_org_id
	        AND msn.inventory_item_id= l_item_id
	        AND msn.SERIAL_NUMBER BETWEEN l_fm_serial_number AND
	 	                                l_to_serial_number;
	     END LOOP;
	     CLOSE c_fm_to_lot_serial_number;

	     UPDATE mtl_serial_numbers_temp
	     SET group_header_id= l_txn_hdr_id
	     WHERE transaction_temp_id in ( SELECT serial_transaction_temp_id
	                                   FROM mtl_transaction_lots_temp
					   WHERE transaction_temp_id= l_pick_slip_id );
           ELSE                            --Non-Lot item

  	     OPEN c_fm_to_serial_number;
             LOOP
                FETCH c_fm_to_serial_number
                INTO l_fm_serial_number,l_to_serial_number;
                EXIT WHEN c_fm_to_serial_number%NOTFOUND;

                UPDATE MTL_SERIAL_NUMBERS msn
                SET  GROUP_MARK_ID=l_txn_hdr_id
	        WHERE msn.current_organization_id=p_sign_on_org_id
	        AND msn.inventory_item_id= l_item_id
	        AND msn.SERIAL_NUMBER BETWEEN l_fm_serial_number AND
		                                l_to_serial_number;
	     END LOOP;
	     CLOSE c_fm_to_serial_number;

	     UPDATE mtl_serial_numbers_temp
	     SET group_header_id= l_txn_hdr_id
             WHERE transaction_temp_id=l_pick_slip_id ;

         END IF;

      IF (l_debug = 1) THEN
              mydebug('manual_pick: Updated MSNT');
      END IF;

      EXCEPTION
         WHEN OTHERS THEN
           IF (l_debug = 1) THEN
               mydebug('manual_pick:EXCEPTION!!! while updating MSNT');
           END IF;
	   raise fnd_api.g_exc_error;
      END ;
    END IF;
    --Bug6009436.End

        INSERT INTO wms_dispatched_tasks
                    (
                     task_id
                   , transaction_temp_id
                   , organization_id
                   , user_task_type
                   , person_id
                   , effective_start_date
                   , effective_end_date
                   , equipment_id
                   , equipment_instance
                   , person_resource_id
                   , machine_resource_id
                   , status
                   , dispatched_time
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , task_type
                   , operation_plan_id
                   , move_order_line_id
                    )
             VALUES (
                     l_next_task_id
                   , l_pick_slip_id
                   , l_org_id
                   , NVL(l_std_op_id, 2)
                   , l_user_id
                   , SYSDATE
                   , SYSDATE
                   , l_eqp_id
                   , l_eqp_ins
                   , l_per_res_id
                   , l_mac_res_id
                   , 3
                   , SYSDATE
                   , SYSDATE
                   , l_emp_id
                   , SYSDATE
                   , l_emp_id
                   , l_wms_task_type
                   , l_operation_plan_id
                   , l_move_order_line_id
                    );

        IF (l_debug = 1) THEN
          mydebug('manual_pick: After Insert into WMSDT');
        END IF;
      END IF;
    END IF; --mmtt rowcount if

    COMMIT;
    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END manual_pick;

  PROCEDURE check_carton(
    p_carton_id     IN            NUMBER
  , p_org_id        IN            NUMBER
  , x_nbr_tasks     OUT NOCOPY    NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  ) IS
    l_cartonization_id   NUMBER         := NULL;
    l_c_rows             NUMBER;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(4000);
    l_return_status      VARCHAR2(1);
    l_lpn_id             NUMBER;
    l_org_id             NUMBER;
    l_mmtt_rowcnt        NUMBER;
    l_wdt_rowcnt         NUMBER;
    l_undispatched_picks NUMBER;
    l_debug              NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('check_carton: In check carton API');
    END IF;

    l_return_status  := fnd_api.g_ret_sts_success;
    l_org_id         := p_org_id;
    l_c_rows         := 0;
    l_lpn_id         := p_carton_id;
    l_mmtt_rowcnt    := 0;
    l_wdt_rowcnt     := 0;

    IF (l_debug = 1) THEN
      mydebug('check_carton: Getting undispatched MMTT rows for this lpn..');
    END IF;

    SELECT COUNT(*)
      INTO l_mmtt_rowcnt
      FROM mtl_material_transactions_temp m
     WHERE m.cartonization_id IS NOT NULL
       AND m.cartonization_id = l_lpn_id
       AND parent_line_id IS NULL;

    IF (l_debug = 1) THEN
      mydebug('check_carton: MMTT rows' || l_mmtt_rowcnt);
    END IF;

    IF l_mmtt_rowcnt > 0 THEN
      -- There are MMTT tasks for this LPN
      SELECT COUNT(*)
        INTO l_wdt_rowcnt
        FROM mtl_material_transactions_temp m, wms_dispatched_tasks t
       WHERE m.cartonization_id = l_lpn_id
         AND t.transaction_temp_id = m.transaction_temp_id
         AND t.status = 4;

      IF (l_debug = 1) THEN
        mydebug('check_carton: WDT rows' || l_wdt_rowcnt);
      END IF;

      l_undispatched_picks  := l_mmtt_rowcnt - l_wdt_rowcnt;

      IF (l_debug = 1) THEN
        mydebug('check_carton: Undispatched Picks' || l_undispatched_picks);
      END IF;

      x_nbr_tasks           := l_undispatched_picks;
    ELSE -- l_mmtt_rowcnt>0  if
      IF (l_debug = 1) THEN
        mydebug('check_carton: There are no mmtt rows for this LPN');
      END IF;

      x_nbr_tasks  := -1;
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END check_carton;



  PROCEDURE check_pack_lpn
  ( p_lpn           IN            VARCHAR2
  , p_org_id        IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  ) IS
    lpn_cont        NUMBER         := 0;
    create_lpn      VARCHAR2(1)    := 'N';
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_exist         NUMBER;
    p_lpn_id        NUMBER;
    l_org_id        NUMBER;
    l_debug         NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('check_pack_lpn: check_pack_lpn begins');
    END IF;

    l_return_status  := fnd_api.g_ret_sts_success;

    IF ((p_lpn IS NULL)
        OR(p_lpn = '')) THEN
      x_return_status  := fnd_api.g_ret_sts_success;
      RETURN;
    END IF;

    BEGIN
      SELECT lpn_context
           , organization_id
        INTO lpn_cont
           , l_org_id
        FROM wms_license_plate_numbers
       WHERE license_plate_number = p_lpn;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        create_lpn  := 'Y';
    END;

    IF (
        create_lpn = 'N'
        AND(
            (
             lpn_cont = wms_container_pub.lpn_context_wip
             OR lpn_cont = wms_container_pub.lpn_context_rcv
             OR lpn_cont = wms_container_pub.lpn_context_stores
             OR lpn_cont = wms_container_pub.lpn_context_intransit
             OR lpn_cont = wms_container_pub.lpn_context_vendor
             OR lpn_cont = wms_container_pub.lpn_loaded_for_shipment
             OR lpn_cont = wms_container_pub.lpn_prepack_for_wip
             OR lpn_cont = wms_container_pub.lpn_context_picked
	     OR lpn_cont = wms_container_pub.lpn_context_inv --Bug 5038228
            )
            OR l_org_id <> p_org_id
           )
       ) THEN
      IF (l_debug = 1) THEN
        mydebug('check_pack_lpn: LPN already exists but with different context or Org');
	END IF;--bug9165521
	fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_CNTXT_ORG');
        fnd_msg_pub.ADD;


      x_return_status  := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    IF create_lpn = 'Y' THEN
      IF (l_debug = 1) THEN
        mydebug('check_pack_lpn: calling wms_container_pub.create_lpn');
      END IF;

      wms_container_pub.create_lpn
      ( p_api_version                => 1.0
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => x_msg_data
      , p_lpn                        => p_lpn
      , p_organization_id            => p_org_id
      , x_lpn_id                     => p_lpn_id
      , p_source                     => 8
      );

      IF (l_msg_count = 0) THEN
        IF (l_debug = 1) THEN
          mydebug('check_pack_lpn: Successful');
        END IF;
      ELSIF(l_msg_count = 1) THEN
        IF (l_debug = 1) THEN
          mydebug('check_pack_lpn: Not Successful');
          mydebug(REPLACE(x_msg_data, fnd_global.local_chr(0), ' '));
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          mydebug('check_pack_lpn: Not Successful2');
        END IF;

        FOR i IN 1 .. l_msg_count LOOP
          x_msg_data  := fnd_msg_pub.get(i, 'F');

          IF (l_debug = 1) THEN
            mydebug(REPLACE(x_msg_data, fnd_global.local_chr(0), ' '));
          END IF;
        END LOOP;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error
         OR l_return_status = fnd_api.g_ret_sts_error THEN
         fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('check_pack_lpn: check_pack_lpn ends');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END check_pack_lpn;

  PROCEDURE mydebug(msg IN VARCHAR2) IS
    l_msg   VARCHAR2(5100);
    l_ts    VARCHAR2(30);
    l_debug NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    --   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;
    --   l_msg:=l_ts||'  '||msg;

    l_msg  := msg;
    inv_mobile_helper_functions.tracelog(p_err_msg => l_msg, p_module => 'WMS_Task_Dispatch_Gen', p_level => 4);
    --dbms_output.put_line(l_msg);

    NULL;
  END;

  -- Procedure
  --  check_is_reservable_sub
  -- Description
  --  check from db tables whether the sub specified in
  --  the input is a reservable sub or not.
  PROCEDURE check_is_reservable_sub(
    x_return_status     OUT NOCOPY    VARCHAR2
  , p_organization_id   IN            VARCHAR2
  , p_subinventory_code IN            VARCHAR2
  , x_is_reservable_sub OUT NOCOPY    BOOLEAN
  ) IS
    l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_reservable_type NUMBER;
    l_debug           NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    SELECT reservable_type
      INTO l_reservable_type
      FROM mtl_secondary_inventories
     WHERE organization_id = p_organization_id
       AND secondary_inventory_name = p_subinventory_code;

    IF (l_reservable_type = 1) THEN
      x_is_reservable_sub  := TRUE;
    ELSE
      x_is_reservable_sub  := FALSE;
    END IF;

    x_return_status  := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Check_Is_Reservable_SUB');
      END IF;
  END check_is_reservable_sub;
   -- Bug 2924823 H to I added delete allocation

 PROCEDURE delete_allocation
  (
   p_temp_id                IN    NUMBER,
   p_lot_control_code       IN    NUMBER,
   p_serial_control_code    IN    NUMBER,
   p_serial_allocate_flag   IN    VARCHAR2,
   p_item_id                IN    NUMBER,
   p_org_id                 IN    NUMBER
   )

  IS
     l_fm_serial_number VARCHAR2(30);
     l_to_serial_number VARCHAR2(30);

     CURSOR c_fm_to_serial_number IS
        SELECT
          msnt.fm_serial_number,
          msnt.to_serial_number
          FROM  mtl_serial_numbers_temp msnt
          WHERE msnt.transaction_temp_id = p_temp_id;

     CURSOR c_fm_to_lot_serial_number IS
        SELECT
          msnt.fm_serial_number,
          msnt.to_serial_number
          FROM
          mtl_serial_numbers_temp msnt,
          mtl_transaction_lots_temp mtlt
          WHERE mtlt.transaction_temp_id = p_temp_id
          AND   msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;

 BEGIN
 DELETE FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = p_temp_id;

   DELETE FROM wms_dispatched_tasks
     WHERE transaction_temp_id = p_temp_id;

   IF p_lot_control_code > 1 THEN

      -- Lot controlled item

      IF p_serial_control_code NOT IN (1,6) AND
        p_serial_allocate_flag = 'Y' THEN

         -- Lot and Serial controlled item
         OPEN c_fm_to_lot_serial_number;
         LOOP
            FETCH c_fm_to_lot_serial_number
              INTO l_fm_serial_number,l_to_serial_number;
            EXIT WHEN c_fm_to_serial_number%NOTFOUND;

            UPDATE mtl_serial_numbers
              SET  group_mark_id = NULL
              WHERE inventory_item_id         = p_item_id
              AND   current_organization_id   = p_org_id
              AND   serial_number BETWEEN l_fm_serial_number AND
l_to_serial_number;

         END LOOP;
         CLOSE c_fm_to_lot_serial_number;

         DELETE FROM mtl_serial_numbers_temp msnt
           WHERE msnt.transaction_temp_id IN
           (SELECT mtlt.serial_transaction_temp_id
            FROM  mtl_transaction_lots_temp mtlt
             WHERE mtlt.transaction_temp_id = p_temp_id);

            END IF;

            DELETE FROM mtl_transaction_lots_temp mtlt
              WHERE mtlt.transaction_temp_id = p_temp_id;

   END IF;

END delete_allocation;


  PROCEDURE cleanup_task(
    p_temp_id       IN            NUMBER
  , p_qty_rsn_id    IN            NUMBER
  , p_user_id       IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  ) IS
    l_txn_hdr_id        NUMBER;
    l_txn_temp_id       NUMBER;
    l_org_id            NUMBER;
    l_item_id           NUMBER;
    l_sub               VARCHAR2(10);
    l_loc               NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot               VARCHAR2(80);
    l_rev               VARCHAR2(3);
    l_txn_qty           NUMBER;
    l_other_mmtt_count  NUMBER;
    l_mo_line_id        NUMBER;
    l_mo_type           NUMBER;
    l_mol_qty           NUMBER;
    l_mol_qty_delivered NUMBER;
    l_mol_src_id        NUMBER;
    l_mol_src_line_id   NUMBER;
    l_mol_reference_id  NUMBER;
    l_mol_status        NUMBER;--bug3139307
    l_debug             NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_wf                NUMBER;
    l_mmtt_transaction_uom    VARCHAR2(3);
    l_mtrl_uom                VARCHAR2(3);
    l_primary_quantity        NUMBER;
    l_kill_mo_profile   NUMBER := NVL(FND_PROFILE.VALUE_WNPS('INV_KILL_MOVE_ORDER'),2);
    l_return_status     VARCHAR2(1);

    CURSOR c_mmtt_info IS
      SELECT mmtt.transaction_header_id
           , mmtt.transaction_temp_id
           , mmtt.inventory_item_id
           , mmtt.organization_id
           , mmtt.revision
           , mmtt.lot_number
           , mmtt.subinventory_code
           , mmtt.locator_id
           , mmtt.move_order_line_id
           , mmtt.transaction_quantity
           , mmtt.transaction_uom
           , mmtt.primary_quantity
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id
         AND NOT EXISTS(SELECT 1
                          FROM mtl_material_transactions_temp t1
                         WHERE t1.parent_line_id = mmtt.transaction_temp_id)
      UNION ALL
      SELECT mmtt.transaction_header_id
           , mmtt.transaction_temp_id
           , mmtt.inventory_item_id
           , mmtt.organization_id
           , mmtt.revision
           , mmtt.lot_number
           , mmtt.subinventory_code
           , mmtt.locator_id
           , mmtt.move_order_line_id
           , mmtt.transaction_quantity
           , mmtt.transaction_uom
           , mmtt.primary_quantity
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.parent_line_id = p_temp_id;

    CURSOR c_mo_line_info IS
      SELECT mtrh.move_order_type
           , mtrl.txn_source_id
           , mtrl.txn_source_line_id
           , mtrl.reference_id
           , mtrl.quantity
           , mtrl.uom_code
           , nvl(mtrl.quantity_delivered,0)
           , mtrl.line_status --bug3139307
        FROM mtl_txn_request_headers mtrh, mtl_txn_request_lines mtrl
       WHERE mtrl.line_id = l_mo_line_id
         AND mtrh.header_id = mtrl.header_id;

    CURSOR c_get_other_mmtt IS
      SELECT COUNT(*)
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.move_order_line_id = l_mo_line_id
         AND mmtt.transaction_temp_id <> l_txn_temp_id
         AND NOT EXISTS(SELECT 1
                          FROM mtl_material_transactions_temp t1
                         WHERE t1.parent_line_id = mmtt.transaction_temp_id);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('CLEANUP_TASK: Cleaning up the Task with Temp ID = ' || p_temp_id);
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;

    OPEN c_mmtt_info;
    LOOP
      FETCH c_mmtt_info INTO l_txn_hdr_id
                           , l_txn_temp_id
                           , l_item_id
                           , l_org_id
                           , l_rev
                           , l_lot
                           , l_sub
                           , l_loc
                           , l_mo_line_id
                           , l_txn_qty
                           , l_mmtt_transaction_uom
                           , l_primary_quantity;
      EXIT WHEN c_mmtt_info%NOTFOUND;

      IF (l_debug = 1) THEN
        mydebug('CLEANUP_TASK: Logging Exceptions with Reason ID = ' || p_qty_rsn_id || ' and TxnTempID = ' || l_txn_temp_id);
      END IF;

      wms_txnrsn_actions_pub.log_exception(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_organization_id            => l_org_id
      , p_item_id                    => l_item_id
      , p_revision                   => l_rev
      , p_lot_number                 => l_lot
      , p_subinventory_code          => l_sub
      , p_locator_id                 => l_loc
      , p_mmtt_id                    => l_txn_hdr_id
      , p_task_id                    => l_txn_temp_id
      , p_reason_id                  => p_qty_rsn_id
      , p_discrepancy_type           => 1
      , p_user_id                    => p_user_id
      );

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      mydebug('CLEANUP_TASK : Calling WorkFlow with Calling Program as **cleanup_task: Pick zero**');
      BEGIN
        call_workflow(
          p_rsn_id                     => p_qty_rsn_id
        , p_calling_program            => 'cleanup_task: Pick zero'
        , p_org_id                     => l_org_id
        , p_tmp_id                     => l_txn_temp_id
        , p_quantity_picked            => l_txn_qty
        , p_dest_sub                   => l_sub
        , p_dest_loc                   => l_loc
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
         , x_wf                         => l_wf
        );

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          mydebug('CLEANUP_TASK : Workflow Call is not successful');
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          mydebug('CLEANUP_TASK : Call to WorkFlow ended up in Exceptions');
          NULL;
      END;
    -- Called c_get_other_mmtt later after c_mo_line_info
     OPEN  c_mo_line_info;
      FETCH c_mo_line_info INTO l_mo_type, l_mol_src_id, l_mol_src_line_id,
l_mol_reference_id, l_mol_qty, l_mtrl_uom, l_mol_qty_delivered,l_mol_status;
--bug3139307
      CLOSE c_mo_line_info;
       mydebug('cleanup_task: transaction_uom:'||l_mmtt_transaction_uom);
      mydebug('cleanup_task: move order line uom :'|| l_mtrl_uom);
     -- Bug 2924823 H to I
      if (l_mtrl_uom <> l_mmtt_transaction_uom) then
            mydebug('cleanup_task: move order line uom is different from mmtt
transaction uom');
            l_txn_qty := INV_Convert.inv_um_convert
                               (item_id         => l_item_id,
                                precision       => null,
                                from_quantity   => l_txn_qty,
                                from_unit       => l_mmtt_transaction_uom,
                                to_unit         => l_mtrl_uom,
                                from_name       => null,
                                to_name         => null);
      end if;


      OPEN c_get_other_mmtt;
      FETCH c_get_other_mmtt INTO l_other_mmtt_count;
      CLOSE c_get_other_mmtt;

      IF (l_debug = 1) THEN
        mydebug('CLEANUP_TASK: Number of MMTTs other than this MMTT : ' || l_other_mmtt_count);
      END IF;

      IF l_other_mmtt_count > 0 THEN
        IF (l_debug = 1) THEN
          mydebug('CLEANUP_TASK: Other MMTT lines exist too. So cant close MO Line');
        END IF;

        inv_trx_util_pub.delete_transaction(
          x_return_status       => x_return_status
        , x_msg_data            => x_msg_data
        , x_msg_count           => x_msg_count
        , p_transaction_temp_id => l_txn_temp_id
        , p_update_parent       => FALSE  --Added bug 3765153
        );

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          IF l_debug = 1 THEN
            mydebug('CLEANUP_TASK: Error occurred while deleting MMTT');
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;
        -- Bug 2924823 H to I
         if (l_wf <= 0) or (p_qty_rsn_id <= 0) then
        UPDATE mtl_txn_request_lines
           SET quantity_detailed = quantity_detailed - l_txn_qty
         WHERE line_id = l_mo_line_id;
         end if;
      ELSE
        IF (l_debug = 1) THEN
          mydebug('CLEANUP_TASK: Just one MMTT line exists. Close MO');
        END IF;

      /*  OPEN c_mo_line_info;
          FETCH c_mo_line_info INTO l_mo_type, l_mol_src_id, l_mol_src_line_id, l_mol_reference_id, l_mol_qty, l_mol_qty_delivered;
        CLOSE c_mo_line_info;
      */
        IF (l_mo_type = INV_GLOBALS.G_MOVE_ORDER_PICK_WAVE) THEN
          DELETE FROM wms_dispatched_tasks WHERE transaction_temp_id = p_temp_id;

           /*bug3139307 suggest_alternate_location API in wms_txnrsn_actions_pub
         would call INV_Replenish_Detail_PUB.Line_Details_PUB . When there is
         no  quantity to allocate the sales order would be automatically
         backordered  and move order is closed. So we need not call
         backorder API here again. */
         IF l_mol_status <> 5 THEN --bug3139307 bug 2924823 H to I
          inv_mo_backorder_pvt.backorder(
            p_line_id       => l_mo_line_id
          , x_return_status => x_return_status
          , x_msg_count     => x_msg_count
          , x_msg_data      => x_msg_data
          );

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              mydebug('CLEANUP_TASK: Unexpected error occurrend while calling BackOrder API');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              mydebug('CLEANUP_TASK: Expected error occurrend while calling BackOrder API');
            END IF;
            RAISE fnd_api.g_exc_error;
         END IF;

          IF (l_debug = 1) THEN
            mydebug('CLEANUP_TASK: Calling API to clean up reservations');
          END IF;

          inv_transfer_order_pvt.clean_reservations(
            p_source_line_id => l_mol_src_line_id
          , x_return_status  => x_return_status
          , x_msg_count      => x_msg_count
          , x_msg_data       => x_msg_data
          );

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              mydebug('CLEANUP_TASK: Unexpected error occurred while Cleaning up Reservations');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              mydebug('CLEANUP_TASK: Expected error occurred while Cleaning up Reservations');
            END IF;
            RAISE fnd_api.g_exc_error;
          END IF;

          ELSE -- if mol.status = 5 --bug3139307
             /*Need to delete the MMTT as the suggest_alternate-location
            procedure in WMSTRSAB.pls would set the MMTT transaction qty. primary
            transaction qty to zero before calling pick release. When Pick rellease
            backorders  the mo line it does not clean up the taks. This
           has to  be done here.*/

          INV_TRX_UTIL_PUB.delete_transaction(
            x_return_status       => x_return_status
          , x_msg_data            => x_msg_data
          , x_msg_count           => x_msg_count
          , p_transaction_temp_id => l_txn_temp_id
          , p_update_parent       => FALSE  --Added bug 3765153
          );

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_debug = 1 THEN
              mydebug('CLEANUP_TASK: Error occurred while deleting MMTT');
            END IF;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF; --bug3139307 bug 2924823 H to I
         /* IF l_mo_type = INV_GLOBALS.G_MOVE_ORDER_MFG_PICK THEN */
          ELSIF l_mo_type IN (5,7)THEN    -- wip picking bug 2924823 H to I
          UPDATE mtl_txn_request_lines
             SET quantity_detailed = quantity_delivered
               , line_status = 5
           WHERE line_id = l_mo_line_id;

          wip_picking_pub.unallocate_material(
            p_wip_entity_id              => l_mol_src_id
          , p_operation_seq_num          => l_mol_src_line_id
          , p_inventory_item_id          => l_item_id
          , p_repetitive_schedule_id     => l_mol_reference_id
          , p_primary_quantity           => l_mol_qty - l_mol_qty_delivered
          , x_return_status              => x_return_status
          , x_msg_data                   => x_msg_data
          );

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              mydebug('CLEANUP_TASK: Unexpected error occurred while Unallocating WIP Material');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              mydebug('CLEANUP_TASK: Expected error occurred while Unallocating WIP Material');
            END IF;
            RAISE fnd_api.g_exc_error;
          END IF;

          inv_trx_util_pub.delete_transaction(
            x_return_status       => x_return_status
          , x_msg_data            => x_msg_data
          , x_msg_count           => x_msg_count
          , p_transaction_temp_id => l_txn_temp_id
          , p_update_parent       => FALSE --Added bug3765153
          );

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_debug = 1 THEN
              mydebug('CLEANUP_TASK: Error occurred while deleting MMTT');
            END IF;
            RAISE fnd_api.g_exc_error;
          END IF;
          -- Bug 2924823 H to I
         if (l_wf <= 0) or (p_qty_rsn_id <= 0) then
                  UPDATE mtl_txn_request_lines
                     SET quantity_detailed = quantity_detailed - l_txn_qty,
                         line_status = 5
                   WHERE line_id = l_mo_line_id;
          end if;
        ELSIF l_mo_type IN (INV_GLOBALS.G_MOVE_ORDER_REQUISITION, INV_GLOBALS.G_MOVE_ORDER_REPLENISHMENT) THEN
          UPDATE mtl_txn_request_lines
             SET quantity_detailed = quantity_delivered
           WHERE line_id = l_mo_line_id;

          inv_trx_util_pub.delete_transaction(
            x_return_status       => x_return_status
          , x_msg_data            => x_msg_data
          , x_msg_count           => x_msg_count
          , p_transaction_temp_id => l_txn_temp_id
          );

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_debug = 1 THEN
              mydebug('CLEANUP_TASK: Error occurred while deleting MMTT');
            END IF;
            RAISE fnd_api.g_exc_error;
          END IF;

     /* 3926046 */
     IF (l_kill_mo_profile = 1) and (l_mo_type =  INV_GLOBALS.G_MOVE_ORDER_REPLENISHMENT) THEN

          IF (l_debug = 1) THEN
                  mydebug('Replenishment Move Order... pending task count :'|| l_other_mmtt_count);
                  mydebug('Replenishment Move Order... quantity delivered :'|| l_mol_qty_delivered);
          END IF;

          IF ((l_other_mmtt_count = 0) and (l_mol_qty_delivered > 0)) THEN
              IF (l_debug = 1) THEN
                      mydebug('Replenishment Move Order... Closing the Move Order');
                   END IF;
                   INV_MO_ADMIN_PUB.close_line(1.0,'F','F','F',l_mo_line_id,x_msg_count,x_msg_data,l_return_status);

                   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
                   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
          END IF;
     END IF;

           -- Bug 2924823 H to I
           if (l_wf <= 0) or (p_qty_rsn_id <= 0) then
             UPDATE mtl_txn_request_lines
                SET quantity_detailed = quantity_delivered
              WHERE line_id = l_mo_line_id;
           end if;
         END IF;
        END IF;
    END LOOP;

    CLOSE c_mmtt_info;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF c_mmtt_info%ISOPEN THEN
        CLOSE c_mmtt_info;
      END IF;
      IF (l_debug = 1) THEN
        mydebug('CLEANUP_TASK: Exception Occurred = ' || SQLERRM);
      END IF;
  END cleanup_task;

  PROCEDURE get_td_lot_lov_count(
    x_lot_num_lov_count   OUT NOCOPY    NUMBER
  , p_organization_id     IN            NUMBER
  , p_item_id             IN            NUMBER
  , p_lot_number          IN            VARCHAR2
  , p_transaction_type_id IN            NUMBER
  , p_wms_installed       IN            VARCHAR2
  , p_lpn_id              IN            NUMBER
  , p_subinventory_code   IN            VARCHAR2
  , p_locator_id          IN            NUMBER
  , p_txn_temp_id         IN            NUMBER
  ) IS
    l_negative_rcpt_code NUMBER;
    l_debug              NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    SELECT negative_inv_receipt_code
      INTO l_negative_rcpt_code
      FROM mtl_parameters
     WHERE organization_id = p_organization_id;

    IF (l_negative_rcpt_code = 1) THEN
      -- Negative inventory balances allowed

      IF (p_lpn_id IS NULL
          OR p_lpn_id = 0) THEN
        SELECT COUNT(*)
          INTO x_lot_num_lov_count
          FROM mtl_lot_numbers_all_v mln, mtl_transaction_lots_temp mtlt
         WHERE mln.organization_id = p_organization_id
           AND mln.inventory_item_id = p_item_id
           AND mln.lot_number LIKE(p_lot_number || '%')
           AND mtlt.lot_number = mln.lot_number
           AND mtlt.transaction_temp_id = p_txn_temp_id
           AND inv_material_status_grp.is_status_applicable(
                p_wms_installed
              , NULL
              , p_transaction_type_id
              , NULL
              , NULL
              , p_organization_id
              , p_item_id
              , NULL
              , NULL
              , mln.lot_number
              , NULL
              , 'O'
              ) = 'Y';
      ELSE
        -- It however remains same for LPNs
        SELECT COUNT(*)
          INTO x_lot_num_lov_count
          FROM mtl_onhand_quantities_detail moq, mtl_lot_numbers_all_v mln, mtl_transaction_lots_temp mtlt, wms_lpn_contents wlc
         WHERE mln.organization_id = p_organization_id
           AND mln.inventory_item_id = p_item_id
           AND mln.lot_number LIKE(p_lot_number || '%')
           AND moq.lot_number = mln.lot_number
           AND moq.inventory_item_id = mln.inventory_item_id
           AND moq.organization_id = mln.organization_id
           AND mtlt.lot_number = mln.lot_number
           AND mtlt.transaction_temp_id = p_txn_temp_id
           AND moq.containerized_flag = 1
           AND wlc.parent_lpn_id = p_lpn_id
           AND wlc.lot_number = mln.lot_number
           AND wlc.inventory_item_id = p_item_id
           AND wlc.organization_id = p_organization_id
           AND moq.subinventory_code = NVL(p_subinventory_code, moq.subinventory_code)
           AND NVL(moq.locator_id, -1) = NVL(NVL(p_locator_id, moq.locator_id), -1)
           AND inv_material_status_grp.is_status_applicable(
                p_wms_installed
              , NULL
              , p_transaction_type_id
              , NULL
              , NULL
              , p_organization_id
              , p_item_id
              , NULL
              , NULL
              , mln.lot_number
              , NULL
              , 'O'
              ) = 'Y';
      END IF;
    ELSE
      -- Negative inventory balances not allowed

      IF (p_lpn_id IS NULL
          OR p_lpn_id = 0) THEN
        SELECT COUNT(*)
          INTO x_lot_num_lov_count
          FROM mtl_onhand_quantities_detail moq, mtl_lot_numbers_all_v mln, mtl_transaction_lots_temp mtlt
         WHERE mln.organization_id = p_organization_id
           AND mln.inventory_item_id = p_item_id
           AND mln.lot_number LIKE(p_lot_number || '%')
           AND moq.lot_number = mln.lot_number
           AND moq.inventory_item_id = mln.inventory_item_id
           AND moq.organization_id = mln.organization_id
           AND mtlt.lot_number = mln.lot_number
           AND mtlt.transaction_temp_id = p_txn_temp_id
           AND moq.containerized_flag = 2
           AND moq.subinventory_code = NVL(p_subinventory_code, moq.subinventory_code)
           AND NVL(moq.locator_id, -1) = NVL(NVL(p_locator_id, moq.locator_id), -1)
           AND inv_material_status_grp.is_status_applicable(
                p_wms_installed
              , NULL
              , p_transaction_type_id
              , NULL
              , NULL
              , p_organization_id
              , p_item_id
              , NULL
              , NULL
              , mln.lot_number
              , NULL
              , 'O'
              ) = 'Y';
      ELSE
        SELECT COUNT(*)
          INTO x_lot_num_lov_count
          FROM mtl_onhand_quantities_detail moq, mtl_lot_numbers_all_v mln, mtl_transaction_lots_temp mtlt, wms_lpn_contents wlc
         WHERE mln.organization_id = p_organization_id
           AND mln.inventory_item_id = p_item_id
           AND mln.lot_number LIKE(p_lot_number || '%')
           AND moq.lot_number = mln.lot_number
           AND moq.inventory_item_id = mln.inventory_item_id
           AND moq.organization_id = mln.organization_id
           AND mtlt.lot_number = mln.lot_number
           AND mtlt.transaction_temp_id = p_txn_temp_id
           AND moq.containerized_flag = 1
           AND wlc.parent_lpn_id = p_lpn_id
           AND wlc.lot_number = mln.lot_number
           AND wlc.inventory_item_id = p_item_id
           AND wlc.organization_id = p_organization_id
           AND moq.subinventory_code = NVL(p_subinventory_code, moq.subinventory_code)
           AND NVL(moq.locator_id, -1) = NVL(NVL(p_locator_id, moq.locator_id), -1)
           AND inv_material_status_grp.is_status_applicable(
                p_wms_installed
              , NULL
              , p_transaction_type_id
              , NULL
              , NULL
              , p_organization_id
              , p_item_id
              , NULL
              , NULL
              , mln.lot_number
              , NULL
              , 'O'
              ) = 'Y';
      END IF;
    END IF;
  END get_td_lot_lov_count;

  PROCEDURE validate_sub_loc_status(
    p_wms_installed    IN            VARCHAR2
  , p_temp_id          IN            NUMBER
  , p_confirmed_sub    IN            VARCHAR2
  , p_confirmed_loc_id IN            NUMBER
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  , x_result           OUT NOCOPY    NUMBER
  ) IS
    l_transaction_type_id NUMBER;
    l_org_id              NUMBER;
    l_item_id             NUMBER;
    l_debug               NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('validate_sub_loc_status: validate_sub_loc_status begins');
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;

    SELECT mmtt.transaction_type_id
         , mmtt.organization_id
         , mmtt.inventory_item_id
      INTO l_transaction_type_id
         , l_org_id
         , l_item_id
      FROM mtl_material_transactions_temp mmtt
     WHERE mmtt.transaction_temp_id = p_temp_id;

    IF inv_material_status_grp.is_status_applicable(
         p_wms_installed              => p_wms_installed
       , p_trx_status_enabled         => NULL
       , p_trx_type_id                => l_transaction_type_id
       , p_lot_status_enabled         => NULL
       , p_serial_status_enabled      => NULL
       , p_organization_id            => l_org_id
       , p_inventory_item_id          => l_item_id
       , p_sub_code                   => p_confirmed_sub
       , p_locator_id                 => p_confirmed_loc_id
       , p_lot_number                 => NULL
       , p_serial_number              => NULL
       , p_object_type                => 'Z'
       ) = 'Y'
       AND inv_material_status_grp.is_status_applicable(
            p_wms_installed              => p_wms_installed
          , p_trx_status_enabled         => NULL
          , p_trx_type_id                => l_transaction_type_id
          , p_lot_status_enabled         => NULL
          , p_serial_status_enabled      => NULL
          , p_organization_id            => l_org_id
          , p_inventory_item_id          => l_item_id
          , p_sub_code                   => p_confirmed_sub
          , p_locator_id                 => p_confirmed_loc_id
          , p_lot_number                 => NULL
          , p_serial_number              => NULL
          , p_object_type                => 'L'
          ) = 'Y' THEN
      x_result  := 1;

      IF (l_debug = 1) THEN
        mydebug('validate_sub_loc_status: Material status is correct. x_result = 1');
      END IF;
    ELSE
      x_result  := 0;

      IF (l_debug = 1) THEN
        mydebug('validate_sub_loc_status: Material status is incorrect. x_result = 0');
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('validate_sub_loc_status: End of validate_sub_loc_status');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        mydebug('validate_sub_loc_status: Error - ' || SQLERRM);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        mydebug('validate_sub_loc_status: Unexpected Error - ' || SQLERRM);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END validate_sub_loc_status;

  PROCEDURE validate_pick_drop_sub(
    p_temp_id            IN            NUMBER
  , p_confirmed_drop_sub IN            VARCHAR2
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  ) IS
    l_xfr_lpn_id          NUMBER;
    l_lpn_controlled_flag NUMBER;
    l_count               NUMBER       := 0;
    l_orig_xfr_sub        VARCHAR2(30);
    l_mmtt_mo_type        NUMBER       := NULL;
    l_debug               NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_wms_task_type       NUMBER;
    --Bug#9659710
    l_txn_source_id NUMBER;
    l_wip_entity_type NUMBER;
    Cursor get_wip_entity_type is
      select entity_type
      from wip_entities
      where wip_entity_id = l_txn_source_id;

  BEGIN
    IF (l_debug = 1) THEN
      mydebug('validate_pick_drop_sub: validate_pick_drop_sub begins ');
      mydebug(' p_temp_id = ' || p_temp_id);
      mydebug(' p_confirmed_drop_sub = ' || p_confirmed_drop_sub);
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;

    -- bug fix 2805229
    SELECT wms_task_type
      INTO l_wms_task_type
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = p_temp_id;

    IF l_wms_task_type = 7 THEN -- staging move
      IF (l_debug = 1) THEN
        mydebug('Skip further validation because l_wms_task_type = ' || l_wms_task_type);
      END IF;

      RETURN;
    END IF;

    -- end bug fix 2805229



    SELECT mtrh.move_order_type,
           mtrl.txn_source_id
      INTO l_mmtt_mo_type,
           l_txn_source_id --Bug#9659710
      FROM mtl_txn_request_headers mtrh, -- mo header for the new task
                                         mtl_txn_request_lines mtrl, mtl_material_transactions_temp mmtt
     WHERE mtrh.header_id = mtrl.header_id
       AND mtrl.line_id = mmtt.move_order_line_id
       AND mmtt.transaction_temp_id = p_temp_id;

    IF (l_debug = 1) THEN
      mydebug('validate_pick_drop_sub :  l_mmtt_mo_type = ' || l_mmtt_mo_type);
    END IF;

    SELECT msi.lpn_controlled_flag
         , mmtt.transfer_lpn_id
         , mmtt.transfer_subinventory
      INTO l_lpn_controlled_flag
         , l_xfr_lpn_id
         , l_orig_xfr_sub
      FROM mtl_material_transactions_temp mmtt, mtl_secondary_inventories msi
     WHERE mmtt.transaction_temp_id = p_temp_id
       AND mmtt.organization_id = msi.organization_id
       AND msi.secondary_inventory_name = p_confirmed_drop_sub;

    IF l_lpn_controlled_flag = wms_globals.g_lpn_controlled_sub THEN
      IF (l_mmtt_mo_type = 5) THEN
        /*Bug#9659710 for GME batches, the validation should not be there as it allows the move order transfer
	to a LPN controlled subinventory and allowd the material consumption from the same later */
        OPEN get_wip_entity_type;
	FETCH get_wip_entity_type INTO l_wip_entity_type;
	CLOSE get_wip_entity_type;
	IF (l_wip_entity_type not in (9,10)) THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
	END IF;
      END IF;

      IF (l_debug = 1) THEN
        mydebug('validate_pick_drop_sub: Transfer Sub is LPN Controlled');
      END IF;

      l_count  := 0;

      BEGIN
        SELECT 1
          INTO l_count
          FROM DUAL
         WHERE EXISTS(
                 SELECT 1
                   FROM mtl_material_transactions_temp mmtt
                  WHERE mmtt.transaction_temp_id <> p_temp_id
                    AND mmtt.transfer_lpn_id = l_xfr_lpn_id
                    AND mmtt.transfer_subinventory <> p_confirmed_drop_sub
                    AND mmtt.transfer_subinventory <> l_orig_xfr_sub);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count  := 0;
      END;

      IF l_count > 0 THEN
        IF (l_debug = 1) THEN
          mydebug('validate_pick_drop_sub: Drop LPN is going to a different sub');
        END IF;

        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('validate_pick_drop_sub: End of validate_pick_drop_sub');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        mydebug('validate_pick_drop_sub: Error - ' || SQLERRM);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        mydebug('validate_pick_drop_sub: Unexpected Error - ' || SQLERRM);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END validate_pick_drop_sub;

  -- Added for bug 12853197
  PROCEDURE validate_pick_drop_sub(
	 p_temp_id             IN            NUMBER
   , p_confirmed_drop_sub  IN            VARCHAR2
   , x_return_status       OUT NOCOPY    VARCHAR2
   , x_msg_count           OUT NOCOPY    NUMBER
   , x_msg_data            OUT NOCOPY    VARCHAR2
   , x_lpn_controlled_flag OUT NOCOPY    VARCHAR2
   ) IS
	 l_xfr_lpn_id          NUMBER;
	 l_lpn_controlled_flag NUMBER;
	 l_count               NUMBER       := 0;
	 l_orig_xfr_sub        VARCHAR2(30);
	 l_mmtt_mo_type        NUMBER       := NULL;
	 l_debug               NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
	 l_wms_task_type       NUMBER;
  BEGIN
	IF (l_debug = 1) THEN
	   mydebug('validate_pick_drop_sub: validate_pick_drop_sub begins ');
	   mydebug(' p_temp_id = ' || p_temp_id);
	   mydebug(' p_confirmed_drop_sub = ' || p_confirmed_drop_sub);
	END IF;

	x_return_status  := fnd_api.g_ret_sts_success;

	-- bug fix 2805229
	SELECT wms_task_type
	   INTO l_wms_task_type
	   FROM mtl_material_transactions_temp
	  WHERE transaction_temp_id = p_temp_id;

	IF l_wms_task_type = 7 THEN -- staging move
	   IF (l_debug = 1) THEN
		 mydebug('Skip further validation because l_wms_task_type = ' || l_wms_task_type);
	   END IF;

	   RETURN;
	END IF;

	 -- end bug fix 2805229



	SELECT mtrh.move_order_type
	   INTO l_mmtt_mo_type
	   FROM mtl_txn_request_headers mtrh, -- mo header for the new task
										  mtl_txn_request_lines mtrl, mtl_material_transactions_temp mmtt
	  WHERE mtrh.header_id = mtrl.header_id
		AND mtrl.line_id = mmtt.move_order_line_id
		AND mmtt.transaction_temp_id = p_temp_id;

	IF (l_debug = 1) THEN
	   mydebug('validate_pick_drop_sub :  l_mmtt_mo_type = ' || l_mmtt_mo_type);
	END IF;

	SELECT msi.lpn_controlled_flag
		  , mmtt.transfer_lpn_id
		  , mmtt.transfer_subinventory
	   INTO l_lpn_controlled_flag
		  , l_xfr_lpn_id
		  , l_orig_xfr_sub
	   FROM mtl_material_transactions_temp mmtt, mtl_secondary_inventories msi
	  WHERE mmtt.transaction_temp_id = p_temp_id
		AND mmtt.organization_id = msi.organization_id
		AND msi.secondary_inventory_name = p_confirmed_drop_sub;

	x_lpn_controlled_flag:=l_lpn_controlled_flag;

	IF l_lpn_controlled_flag = wms_globals.g_lpn_controlled_sub THEN
	  IF (l_mmtt_mo_type = 5) THEN
		fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
		fnd_msg_pub.ADD;
		RAISE fnd_api.g_exc_error;
	  END IF;

	  IF (l_debug = 1) THEN
		mydebug('validate_pick_drop_sub: Transfer Sub is LPN Controlled');
	  END IF;

	  l_count  := 0;

	  BEGIN
		 SELECT 1
		   INTO l_count
		   FROM DUAL
		  WHERE EXISTS(
				  SELECT 1
					FROM mtl_material_transactions_temp mmtt
				   WHERE mmtt.transaction_temp_id <> p_temp_id
					 AND mmtt.transfer_lpn_id = l_xfr_lpn_id
					 AND mmtt.transfer_subinventory <> p_confirmed_drop_sub
					 AND mmtt.transfer_subinventory <> l_orig_xfr_sub);
	  EXCEPTION
		WHEN NO_DATA_FOUND THEN
		   l_count  := 0;
	  END;

	  IF l_count > 0 THEN
		IF (l_debug = 1) THEN
		   mydebug('validate_pick_drop_sub: Drop LPN is going to a different sub');
		END IF;

		fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
		fnd_msg_pub.ADD;
		RAISE fnd_api.g_exc_error;
	  END IF;
	END IF;

	IF (l_debug = 1) THEN
	   mydebug('validate_pick_drop_sub: End of validate_pick_drop_sub');
	END IF;
  EXCEPTION
	WHEN fnd_api.g_exc_error THEN
	  x_return_status  := fnd_api.g_ret_sts_error;

	  IF (l_debug = 1) THEN
		 mydebug('validate_pick_drop_sub: Error - ' || SQLERRM);
	  END IF;

	  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
	WHEN OTHERS THEN
	  x_return_status  := fnd_api.g_ret_sts_unexp_error;

	  IF (l_debug = 1) THEN
		 mydebug('validate_pick_drop_sub: Unexpected Error - ' || SQLERRM);
	  END IF;

	  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END validate_pick_drop_sub;

  PROCEDURE create_lock_mmtt_temp_id(lock_name IN VARCHAR2, x_return_status OUT NOCOPY VARCHAR2) IS
    l_lock_id   VARCHAR2(50);
    lock_result NUMBER;
    l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('Inside create_lock_mmtt_temp_id');
    END IF;

    DBMS_LOCK.allocate_unique(lockname => lock_name, lockhandle => l_lock_id);
    lock_result  :=
          DBMS_LOCK.request --EXCLUSIVE LOCK
                            (lockhandle  => l_lock_id, lockmode => 6, TIMEOUT => 5, -- 5 seconds ???
            release_on_commit            => TRUE);

    IF (l_debug = 1) THEN
      mydebug('dbms_lock,lock_result:' || lock_result);
    END IF;

    IF (lock_result = 0) THEN
      IF (l_debug = 1) THEN
        mydebug('creating lock mmtt.temp_id, to be used in CTRLBD is successful');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_success;
    ELSIF lock_result IN(1, 2) THEN
      IF (l_debug = 1) THEN
        mydebug('timeout for the creation of user lock or deadlock');
      END IF;

      fnd_message.set_name('WMS', 'WMS_RECORD_BEING_CHANGED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        mydebug('lock_mmtt_temp_id - ' || SQLERRM);
      END IF;
  END create_lock_mmtt_temp_id;

  /*
  -- This procedure will be used for distributing the quantity
  -- picked (in one or more parent MMTT lines) to the original
  -- child MMTT lines (again one or more)
  */
  PROCEDURE bulk_pick(
    p_temp_id            IN            NUMBER
  , p_txn_hdr_id         IN            NUMBER
  , p_org_id             IN            NUMBER
  , p_pick_qty_remaining IN            NUMBER
  , p_user_id            IN            NUMBER
  , x_new_txn_hdr_id     OUT NOCOPY    NUMBER
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , p_reason_id          IN            NUMBER --Added bug 3765153
  ) IS
    CURSOR c_parent_mmtt_lines IS
      SELECT   mmtt.transaction_temp_id
             , mmtt.inventory_item_id
             , mmtt.subinventory_code
             , mmtt.locator_id
             , NVL(mmtt.content_lpn_id, mmtt.lpn_id)
             , mmtt.transfer_lpn_id
             , mmtt.transaction_uom
             , mmtt.transaction_quantity
             , mmtt.primary_quantity
          FROM mtl_material_transactions_temp mmtt
         WHERE mmtt.transaction_header_id = p_txn_hdr_id
           AND mmtt.organization_id = p_org_id
           AND mmtt.transaction_quantity > 0
      AND mmtt.parent_line_id is NULL  --Added bug3765153 to ensure only parent line are picked
      ORDER BY mmtt.transaction_quantity DESC;

    CURSOR c_child_mmtt_lines IS
      SELECT   mmtt.transaction_temp_id
             , mmtt.transaction_uom
             , mmtt.transaction_quantity
             , mmtt.primary_quantity
          FROM mtl_material_transactions_temp mmtt
         WHERE mmtt.parent_line_id = p_temp_id
           AND mmtt.organization_id = p_org_id
      ORDER BY mmtt.transaction_quantity DESC;

     CURSOR unpicked_child_mmtt_lines(p_parent_line_id NUMBER,p_org_id NUMBER) IS
      SELECT mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.organization_id = p_org_id
            AND mmtt.parent_line_id = p_parent_line_id;  --Added bug3765153 to determine and back order unpicked lines

    l_parent_txn_qty     NUMBER;
    l_child_txn_qty      NUMBER := 0; --bug3765153 defaulted to 0
    l_parent_pri_qty     NUMBER;
    l_child_pri_qty      NUMBER;
    l_parent_uom         VARCHAR2(10);
    l_child_uom          VARCHAR2(10);
    l_parent_txn_temp_id NUMBER;
    l_child_txn_temp_id  NUMBER;
    l_item_id            NUMBER;
    l_parent_sub_code    VARCHAR2(30);
    l_parent_loc_id      NUMBER;
    l_lpn_id             NUMBER;
    l_transfer_lpn_id    NUMBER;
    l_debug              NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_new_temp_id        NUMBER;  --Added bug3765153
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
      mydebug('Dispatching Bulk Pick Tasks for TxnHdrID = ' || p_txn_hdr_id || ' : TxnTempID = ' || p_temp_id);
    END IF;

    SELECT mtl_material_transactions_s.NEXTVAL
      INTO x_new_txn_hdr_id
      FROM DUAL;

    OPEN c_parent_mmtt_lines;

    LOOP
      FETCH c_parent_mmtt_lines INTO l_parent_txn_temp_id
     , l_item_id
     , l_parent_sub_code
     , l_parent_loc_id
     , l_lpn_id
     , l_transfer_lpn_id
     , l_parent_uom
     , l_parent_txn_qty
     , l_parent_pri_qty;
      EXIT WHEN c_parent_mmtt_lines%NOTFOUND;
      OPEN c_child_mmtt_lines;

      LOOP
        IF l_child_txn_qty = 0 THEN  --Added bug3765153
      IF l_debug = 1 THEN
        mydebug('Bulk Pick:Fethcing new child record');
      END IF;
           FETCH c_child_mmtt_lines INTO l_child_txn_temp_id, l_child_uom, l_child_txn_qty, l_child_pri_qty;
      EXIT WHEN c_child_mmtt_lines%NOTFOUND;
   END IF;

        IF l_debug = 1 THEN
          mydebug('Child Temp ID = ' || l_child_txn_temp_id);
          mydebug('Current Parent Qty = ' || l_parent_txn_qty || ' : Child Qty = ' || l_child_txn_qty);
        END IF;

        IF l_parent_uom <> l_child_uom THEN
          l_child_txn_qty  :=
            inv_convert.inv_um_convert(
              item_id                      => l_item_id
            , PRECISION                    => NULL
            , from_quantity                => l_child_txn_qty
            , from_unit                    => l_child_uom
            , to_unit                      => l_parent_uom
            , from_name                    => NULL
            , to_name                      => NULL
            );
        END IF;

        IF l_parent_txn_qty >= l_child_txn_qty THEN
          UPDATE mtl_material_transactions_temp mmtt
             SET mmtt.transaction_header_id = x_new_txn_hdr_id
               , mmtt.transfer_lpn_id = l_transfer_lpn_id
               , mmtt.lpn_id = l_lpn_id
               , mmtt.parent_line_id = l_parent_txn_temp_id --Modified from NULL bug3765153
               , mmtt.subinventory_code = l_parent_sub_code
               , mmtt.locator_id = l_parent_loc_id
               , mmtt.transaction_uom = l_parent_uom
               , mmtt.last_update_date = SYSDATE
               , mmtt.last_updated_by = p_user_id
           WHERE mmtt.transaction_temp_id = l_child_txn_temp_id;

          l_parent_txn_qty  := l_parent_txn_qty - l_child_txn_qty;
          l_parent_pri_qty  := l_parent_pri_qty - l_child_pri_qty;
     l_child_txn_qty := 0;
     l_child_pri_qty := 0;
          EXIT WHEN l_parent_txn_qty = 0;
        ELSE -- Current Child Qty is greater than Parent Picked Qty

   select mtl_material_transactions_s.NEXTVAL
   into l_new_temp_id
   from dual; --Added bug3765153

          INSERT INTO mtl_material_transactions_temp
                      (
                       transaction_header_id
                     , transaction_temp_id
                     , source_code
                     , source_line_id
                     , transaction_mode
                     , lock_flag
                     , last_update_date
                     , last_updated_by
                     , creation_date
                     , created_by
                     , last_update_login
                     , request_id
                     , program_application_id
                     , program_id
                     , program_update_date
                     , inventory_item_id
                     , revision
                     , organization_id
                     , subinventory_code
                     , locator_id
                     , transaction_quantity
                     , primary_quantity
                     , transaction_uom
                     , transaction_cost
                     , transaction_type_id
                     , transaction_action_id
                     , transaction_source_type_id
                     , transaction_source_id
                     , transaction_source_name
                     , transaction_date
                     , acct_period_id
                     , distribution_account_id
                     , transaction_reference
                     , requisition_line_id
                     , requisition_distribution_id
                     , reason_id
                     , lot_number
                     , lot_expiration_date
                     , serial_number
                     , receiving_document
                     , demand_id
                     , rcv_transaction_id
                     , move_transaction_id
                     , completion_transaction_id
                     , wip_entity_type
                     , schedule_id
                     , repetitive_line_id
                     , employee_code
                     , primary_switch
                     , schedule_update_code
                     , setup_teardown_code
                     , item_ordering
                     , negative_req_flag
                     , operation_seq_num
                     , picking_line_id
                     , trx_source_line_id
                     , trx_source_delivery_id
                     , physical_adjustment_id
                     , cycle_count_id
                     , rma_line_id
                     , customer_ship_id
                     , currency_code
                     , currency_conversion_rate
                     , currency_conversion_type
                     , currency_conversion_date
                     , ussgl_transaction_code
                     , vendor_lot_number
                     , encumbrance_account
                     , encumbrance_amount
                     , ship_to_location
                     , shipment_number
                     , transfer_cost
                     , transportation_cost
                     , transportation_account
                     , freight_code
                     , containers
                     , waybill_airbill
                     , expected_arrival_date
                     , transfer_subinventory
                     , transfer_organization
                     , transfer_to_location
                     , new_average_cost
                     , value_change
                     , percentage_change
                     , material_allocation_temp_id
                     , demand_source_header_id
                     , demand_source_line
                     , demand_source_delivery
                     , item_segments
                     , item_description
                     , item_trx_enabled_flag
                     , item_location_control_code
                     , item_restrict_subinv_code
                     , item_restrict_locators_code
                     , item_revision_qty_control_code
                     , item_primary_uom_code
                     , item_uom_class
                     , item_shelf_life_code
                     , item_shelf_life_days
                     , item_lot_control_code
                     , item_serial_control_code
                     , item_inventory_asset_flag
                     , allowed_units_lookup_code
                     , department_id
                     , department_code
                     , wip_supply_type
                     , supply_subinventory
                     , supply_locator_id
                     , valid_subinventory_flag
                     , valid_locator_flag
                     , locator_segments
                     , current_locator_control_code
                     , number_of_lots_entered
                     , wip_commit_flag
                     , next_lot_number
                     , lot_alpha_prefix
                     , next_serial_number
                     , serial_alpha_prefix
                     , shippable_flag
                     , posting_flag
                     , required_flag
                     , process_flag
                     , ERROR_CODE
                     , error_explanation
                     , attribute_category
                     , attribute1
                     , attribute2
                     , attribute3
                     , attribute4
                     , attribute5
                     , attribute6
                     , attribute7
                     , attribute8
                     , attribute9
                     , attribute10
                     , attribute11
                     , attribute12
                     , attribute13
                     , attribute14
                     , attribute15
                     , movement_id
                     , reservation_quantity
                     , shipped_quantity
                     , transaction_line_number
                     , task_id
                     , to_task_id
                     , source_task_id
                     , project_id
                     , source_project_id
                     , pa_expenditure_org_id
                     , to_project_id
                     , expenditure_type
                     , final_completion_flag
                     , transfer_percentage
                     , transaction_sequence_id
                     , material_account
                     , material_overhead_account
                     , resource_account
                     , outside_processing_account
                     , overhead_account
                     , flow_schedule
                     , cost_group_id
                     , demand_class
                     , qa_collection_id
                     , kanban_card_id
                     , overcompletion_transaction_id
                     , overcompletion_primary_qty
                     , overcompletion_transaction_qty
                     , end_item_unit_number
                     , scheduled_payback_date
                     , line_type_code
                     , parent_transaction_temp_id
                     , put_away_strategy_id
                     , put_away_rule_id
                     , pick_strategy_id
                     , pick_rule_id
                     , common_bom_seq_id
                     , common_routing_seq_id
                     , cost_type_id
                     , org_cost_group_id
                     , move_order_line_id
                     , task_group_id
                     , pick_slip_number
                     , reservation_id
                     , transaction_status
                     , transfer_cost_group_id
                     , lpn_id
                     , transfer_lpn_id
                     , content_lpn_id
                     , cartonization_id
                     , standard_operation_id
                     , wms_task_type
                     , task_priority
                     , container_item_id
                     , operation_plan_id
                     , parent_line_id
                      )
            (SELECT transaction_header_id
             , l_new_temp_id      --Changed from mtl_material_transactions_s.NEXTVAL bug3765153
                  , source_code
                  , source_line_id
                  , transaction_mode
                  , lock_flag
                  , SYSDATE
                  , last_updated_by
                  , SYSDATE
                  , created_by
                  , last_update_login
                  , request_id
                  , program_application_id
                  , program_id
                  , program_update_date
                  , inventory_item_id
                  , revision
                  , organization_id
                  , subinventory_code
                  , locator_id
                  , l_child_pri_qty - l_parent_pri_qty
                  , l_child_txn_qty - l_parent_txn_qty
                  , l_parent_uom
                  , transaction_cost
                  , transaction_type_id
                  , transaction_action_id
                  , transaction_source_type_id
                  , transaction_source_id
                  , transaction_source_name
                  , transaction_date
                  , acct_period_id
                  , distribution_account_id
                  , transaction_reference
                  , requisition_line_id
                  , requisition_distribution_id
                  , reason_id
                  , lot_number
                  , lot_expiration_date
                  , serial_number
                  , receiving_document
                  , demand_id
                  , rcv_transaction_id
                  , move_transaction_id
                  , completion_transaction_id
                  , wip_entity_type
                  , schedule_id
                  , repetitive_line_id
                  , employee_code
                  , primary_switch
                  , schedule_update_code
                  , setup_teardown_code
                  , item_ordering
                  , negative_req_flag
                  , operation_seq_num
                  , picking_line_id
                  , trx_source_line_id
                  , trx_source_delivery_id
                  , physical_adjustment_id
                  , cycle_count_id
                  , rma_line_id
                  , customer_ship_id
                  , currency_code
                  , currency_conversion_rate
                  , currency_conversion_type
                  , currency_conversion_date
                  , ussgl_transaction_code
                  , vendor_lot_number
                  , encumbrance_account
                  , encumbrance_amount
                  , ship_to_location
                  , shipment_number
                  , transfer_cost
                  , transportation_cost
                  , transportation_account
                  , freight_code
                  , containers
                  , waybill_airbill
                  , expected_arrival_date
                  , transfer_subinventory
                  , transfer_organization
                  , transfer_to_location
                  , new_average_cost
                  , value_change
                  , percentage_change
                  , material_allocation_temp_id
                  , demand_source_header_id
                  , demand_source_line
                  , demand_source_delivery
                  , item_segments
                  , item_description
                  , item_trx_enabled_flag
                  , item_location_control_code
                  , item_restrict_subinv_code
                  , item_restrict_locators_code
                  , item_revision_qty_control_code
                  , item_primary_uom_code
                  , item_uom_class
                  , item_shelf_life_code
                  , item_shelf_life_days
                  , item_lot_control_code
                  , item_serial_control_code
                  , item_inventory_asset_flag
                  , allowed_units_lookup_code
                  , department_id
                  , department_code
                  , wip_supply_type
                  , supply_subinventory
                  , supply_locator_id
                  , valid_subinventory_flag
                  , valid_locator_flag
                  , locator_segments
                  , current_locator_control_code
                  , number_of_lots_entered
                  , wip_commit_flag
                  , next_lot_number
                  , lot_alpha_prefix
                  , next_serial_number
                  , serial_alpha_prefix
                  , shippable_flag
                  , posting_flag
                  , required_flag
                  , process_flag
                  , ERROR_CODE
                  , error_explanation
                  , attribute_category
                  , attribute1
                  , attribute2
                  , attribute3
                  , attribute4
                  , attribute5
                  , attribute6
                  , attribute7
                  , attribute8
                  , attribute9
                  , attribute10
                  , attribute11
                  , attribute12
                  , attribute13
                  , attribute14
                  , attribute15
                  , movement_id
                  , reservation_quantity
                  , shipped_quantity
                  , transaction_line_number
                  , task_id
                  , to_task_id
                  , source_task_id
                  , project_id
                  , source_project_id
                  , pa_expenditure_org_id
                  , to_project_id
                  , expenditure_type
                  , final_completion_flag
                  , transfer_percentage
                  , transaction_sequence_id
                  , material_account
                  , material_overhead_account
                  , resource_account
                  , outside_processing_account
                  , overhead_account
                  , flow_schedule
                  , cost_group_id
                  , demand_class
                  , qa_collection_id
                  , kanban_card_id
                  , overcompletion_transaction_id
                  , overcompletion_primary_qty
                  , overcompletion_transaction_qty
                  , end_item_unit_number
                  , scheduled_payback_date
                  , line_type_code
                  , parent_transaction_temp_id
                  , put_away_strategy_id
                  , put_away_rule_id
                  , pick_strategy_id
                  , pick_rule_id
                  , common_bom_seq_id
                  , common_routing_seq_id
                  , cost_type_id
                  , org_cost_group_id
                  , move_order_line_id
                  , task_group_id
                  , pick_slip_number
                  , reservation_id
                  , transaction_status
                  , transfer_cost_group_id
                  , lpn_id
                  , transfer_lpn_id
                  , content_lpn_id
                  , cartonization_id
                  , standard_operation_id
                  , wms_task_type
                  , task_priority
                  , container_item_id
                  , operation_plan_id
                  , parent_line_id
               FROM mtl_material_transactions_temp
              WHERE transaction_temp_id = l_child_txn_temp_id);

          UPDATE mtl_material_transactions_temp mmtt
             SET mmtt.transaction_header_id = x_new_txn_hdr_id
               , mmtt.transaction_quantity = l_parent_txn_qty
               , mmtt.primary_quantity = l_parent_pri_qty
               , mmtt.parent_line_id = NULL  --l_parent_txn_temp_id --Modified from NULL bug3765153
               , mmtt.transfer_lpn_id = l_transfer_lpn_id
               , mmtt.lpn_id = l_lpn_id
               , mmtt.subinventory_code = l_parent_sub_code
               , mmtt.locator_id = l_parent_loc_id
               , mmtt.transaction_uom = l_parent_uom
               , mmtt.last_update_date = SYSDATE
               , mmtt.last_updated_by = p_user_id
           WHERE mmtt.transaction_temp_id = l_child_txn_temp_id;

     --Added bug 3765153
     l_child_txn_temp_id  := l_new_temp_id;
          l_child_pri_qty   := l_child_pri_qty - l_parent_pri_qty;
          l_child_txn_qty   := l_child_txn_qty - l_parent_txn_qty;
          l_parent_txn_qty  := 0;
          l_parent_pri_qty  := 0;

     IF l_debug = 1 THEN
        mydebug('BULK_PICK:new MMTT tmp id:'||l_new_temp_id);
        mydebug('BULK_PICK:new child pri qty:'||l_child_pri_qty);
        mydebug('BULK_PICK:new child txn qty:'||l_child_txn_qty);
     END IF;
     --end bug 3765153
          EXIT;
        END IF;
      END LOOP;

      CLOSE c_child_mmtt_lines;
    END LOOP;

    CLOSE c_parent_mmtt_lines;

    IF l_debug = 1 THEN
      mydebug('Dispatching Child Tasks');
    END IF;

    -- Dispatching Picked Child Tasks
    INSERT INTO wms_dispatched_tasks
                (
                 task_id
               , transaction_temp_id
               , organization_id
               , user_task_type
               , person_id
               , effective_start_date
               , effective_end_date
               , equipment_id
               , equipment_instance
               , person_resource_id
               , machine_resource_id
               , status
               , dispatched_time
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , task_type
               , loaded_time
               , operation_plan_id
               , move_order_line_id
                )
      (SELECT wms_dispatched_tasks_s.NEXTVAL
            , mmtt.transaction_temp_id
            , mmtt.organization_id
            , wdt.user_task_type
            , wdt.person_id
            , wdt.effective_start_date
            , wdt.effective_end_date
            , wdt.equipment_id
            , wdt.equipment_instance
            , wdt.person_resource_id
            , wdt.machine_resource_id
            , 4
            , wdt.dispatched_time
            , SYSDATE
            , p_user_id
            , SYSDATE
            , p_user_id
            , wdt.task_type
            , SYSDATE
            , mmtt.operation_plan_id
            , mmtt.move_order_line_id
         FROM wms_dispatched_tasks wdt, mtl_material_transactions_temp mmtt
        WHERE wdt.transaction_temp_id = p_temp_id
          AND mmtt.transaction_header_id = x_new_txn_hdr_id);

   DELETE FROM wms_dispatched_tasks wdt
          WHERE wdt.transaction_temp_id IN(SELECT mmtt.transaction_temp_id
                                             FROM mtl_material_transactions_temp mmtt
                                            WHERE mmtt.transaction_header_id = p_txn_hdr_id
                                              AND mmtt.organization_id = p_org_id);

   --Added bug 3765153 to clean up lines with remaining qty
    IF p_pick_qty_remaining > 0 THEN
       for mmtt_rec in unpicked_child_mmtt_lines(p_temp_id,p_org_id) LOOP
           mydebug('BULK_PICK:calling cleanup_task for mmtt line:'||mmtt_rec.transaction_temp_id);
           cleanup_task(
                p_temp_id => mmtt_rec.transaction_temp_id
                , p_qty_rsn_id => p_reason_id
                , p_user_id   => p_user_id
                , x_return_status  => x_return_status
                , x_msg_count           => x_msg_count
                , x_msg_data            => x_msg_data
            );

           IF x_return_status <> fnd_api.g_ret_sts_success THEN
           IF l_debug = 1 THEN
            mydebug('BULK_PICK: Error occurred while calling cleanup tasK ');
           END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

       END LOOP;
    END IF;
    --End bug3765153

    IF l_debug = 1 THEN
      mydebug('Deleting the Parent Task and Parent Line');
    END IF;

    -- Deleting Parent Tasks. Once loaded, only Child Tasks are considered.

    DELETE FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.transaction_header_id = p_txn_hdr_id
            AND mmtt.organization_id = p_org_id;

    -- nullify the parent_line_id for the children lines
    -- since the parent lines are gone  Bug3765153
    update mtl_material_transactions_temp
    set parent_line_id = null
    where transaction_header_id = x_new_txn_hdr_id;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('Unexpected Error occurred - ' || SQLERRM);
      END IF;
  END bulk_pick;

  PROCEDURE call_workflow(
    p_rsn_id          IN            NUMBER
  , p_calling_program IN            VARCHAR2
  , p_org_id          IN            NUMBER
  , p_tmp_id          IN            NUMBER DEFAULT NULL
  , p_quantity_picked IN            NUMBER DEFAULT NULL
  , p_dest_sub        IN            VARCHAR2 DEFAULT NULL
  , p_dest_loc        IN            NUMBER DEFAULT NULL
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
  , x_wf                    OUT NOCOPY NUMBER
  ) IS
    l_wf NUMBER := 0;
  BEGIN
    mydebug('call_workflow :in ');
    x_return_status  := fnd_api.g_ret_sts_success;

    BEGIN
      SELECT 1
        INTO l_wf
        FROM mtl_transaction_reasons
       WHERE reason_id = p_rsn_id
         AND workflow_name IS NOT NULL
         AND workflow_name <> ' '
         AND workflow_process IS NOT NULL
         AND workflow_process <> ' ';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_wf  := 0;
    END;

    mydebug('call_workflow- p_rsn_id: ' || p_rsn_id || ':l_wf: ' || l_wf);
      x_wf := l_wf; -- Bug 2924823 H to I
    IF l_wf > 0 THEN
      mydebug(' call workflow : WF exists for this reason id : ' || p_rsn_id || ':');
      mydebug(' call workflow : Before Calling WF Wrapper for Qty  Discrepancy ');

      -- Calling Workflow

      IF p_rsn_id > 0 THEN
        mydebug('call workflow: Calling ... workflow wrapper');
        wms_workflow_wrappers.wf_wrapper(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_org_id                     => p_org_id
        , p_rsn_id                     => p_rsn_id
        , p_calling_program            => p_calling_program
        , p_tmp_id                     => p_tmp_id
        , p_quantity_picked            => p_quantity_picked
        , p_dest_sub                   => p_dest_sub
        , p_dest_loc                   => p_dest_loc
        );

      mydebug('call_workflow : After Calling WF Wrapper');
     -- Bug 2924823 H to I
         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                         mydebug('call_workflow : Error callinf WF wrapper');
                         FND_MESSAGE.SET_NAME('WMS','WMS_WORK_FLOW_FAIL');
                         FND_MSG_PUB.ADD;
                         RAISE FND_API.g_exc_unexpected_error;

                 ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                         mydebug('call_workflow : Error calling WF wrapper');
                         FND_MESSAGE.SET_NAME('WMS','WMS_WORK_FLOW_FAIL');
                         FND_MSG_PUB.ADD;
                         RAISE FND_API.G_EXC_ERROR;
                 END IF;
     END IF;
    END IF;
  END call_workflow;

/*Added to validate cost group comingle bug3813165*/
procedure validate_loaded_lpn_cg( p_organization_id       IN  NUMBER,
              p_inventory_item_id     IN  NUMBER,
              p_subinventory_code     IN  VARCHAR2,
              p_locator_id            IN  NUMBER,
              p_revision              IN  VARCHAR2,
              p_lot_number            IN  VARCHAR2,
              p_lpn_id                IN  NUMBER,
              p_transfer_lpn_id       IN  NUMBER,
              p_lot_control           IN  NUMBER,
              p_revision_control       IN  NUMBER,
              x_commingle_exist       OUT nocopy VARCHAR2,
              x_return_status         OUT nocopy VARCHAR2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_cur_cost_group_id NUMBER := NULL;
    l_exist_cost_group_id NUMBER := NULL;
    l_sub VARCHAR2(20);
    l_loc NUMBER;
    l_rev VARCHAR2(4);
    l_lpn NUMBER;
    l_ser VARCHAR2(20);
    l_lot VARCHAR2(20);
BEGIN
   IF (l_debug = 1) THEN
      mydebug( 'In check_cg_commingle... ');
      mydebug('p_organization_id'||p_organization_id);
      mydebug('p_inventory_item_id'||p_inventory_item_id);
      mydebug('p_subinventory_code'||p_subinventory_code);
      mydebug('p_locator_id'||p_locator_id);
      mydebug('p_revision'||p_revision);
      mydebug('p_lot_number'||p_lot_number);
      mydebug('p_transfer_lpn_id'||p_transfer_lpn_id);
      mydebug('p_lpn_id'||p_lpn_id);
      mydebug('p_lot_control'||p_lot_control);
      mydebug('p_revision_control'||p_revision_control);
   END IF;

   x_return_status  := fnd_api.g_ret_sts_success;
   x_commingle_exist := 'N';

      IF p_lot_control = 1 THEN
         select mmtt.subinventory_code,
         mmtt.locator_id,
         mmtt.revision,
         mmtt.lpn_id,
         null,
         null
         INTO l_sub,l_loc,l_rev,l_lpn,l_ser,l_lot
         from mtl_material_Transactions_temp mmtt
         where mmtt.inventory_item_id = p_inventory_item_id
         and mmtt.organization_id = p_organization_id
         and mmtt.transfer_lpn_id = p_transfer_lpn_id
         and mmtt.content_lpn_id is null
         and decode(p_revision_control,2,mmtt.revision,1,'~~') = nvl(p_revision,'~~')
         and rownum<2;
      ELSE
         select mmtt.subinventory_code,
         mmtt.locator_id,
         mmtt.revision,
         mmtt.lpn_id,
         null,
         mtlt.lot_number
         INTO l_sub,l_loc,l_rev,l_lpn,l_ser,l_lot
         from mtl_material_Transactions_temp mmtt,
         mtl_transaction_lots_temp mtlt
         where mmtt.inventory_item_id = p_inventory_item_id
         and mmtt.organization_id = p_organization_id
         and mmtt.transfer_lpn_id = p_transfer_lpn_id
         and mmtt.content_lpn_id is null
            and decode(p_revision_control,2,mmtt.revision,1,'~~') = nvl(p_revision,'~~')
         and mmtt.transaction_temp_id = mtlt.transaction_temp_id
         and mtlt.lot_number = p_lot_number
         and rownum<2;
      END IF;

      IF (l_debug = 1) THEN
       mydebug( 'Loaded LPN data From MMTT');
       mydebug('l_subinventory_code'||l_sub);
       mydebug('l_locator_id'||l_loc);
       mydebug('l_revision'||l_rev);
       mydebug('l_lot_number'||l_lot);
       mydebug('l_serial_number'||l_ser);
       mydebug('l_lpn_id'||l_lpn);
      END IF;

     inv_cost_group_update.proc_get_costgroup(
              p_organization_id       => p_organization_id,
              p_inventory_item_id     => p_inventory_item_id,
              p_subinventory_code     => p_subinventory_code,
              p_locator_id            => p_locator_id,
              p_revision              => p_revision,
              p_lot_number            => p_lot_number,
              p_serial_number         => null,
              p_containerized_flag    => null,
              p_lpn_id                => p_lpn_id,
              p_transaction_action_id => null,
              x_cost_group_id         => l_cur_cost_group_id,
                 x_return_status         => x_return_status);
     IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     inv_cost_group_update.proc_get_costgroup(
                             p_organization_id       => p_organization_id,
                 p_inventory_item_id     => p_inventory_item_id,
                 p_subinventory_code     => l_sub,
                 p_locator_id            => l_loc,
                 p_revision              => l_rev,
                 p_lot_number            => l_lot,
                 p_serial_number         => l_ser,
                 p_containerized_flag    => null,
                 p_lpn_id                => l_lpn,
                 p_transaction_action_id => null,
                 x_cost_group_id         => l_exist_cost_group_id,
              x_return_status         => x_return_status);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
             RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF l_exist_cost_group_id <> l_cur_cost_group_id THEN
   x_return_status := fnd_api.g_ret_sts_success;
   x_commingle_exist := 'Y';
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF (l_debug = 1) THEN
       mydebug('First record being loaded into LPN');
   END IF;
   x_return_status := fnd_api.g_ret_sts_success;
   x_commingle_exist := 'N';
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_commingle_exist := 'Y';
END validate_loaded_lpn_cg;


-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
FUNCTION validate_pick_drop_lpn
(  p_api_version_number    IN   NUMBER                       ,
   p_init_msg_lst          IN   VARCHAR2 := fnd_api.g_false  ,
   p_pick_lpn_id           IN   NUMBER                       ,
   p_organization_id       IN   NUMBER                       ,
   p_drop_lpn              IN   VARCHAR2,
   p_drop_sub              IN   VARCHAR2,
   p_drop_loc              IN   NUMBER)
-- Added sub and loc for validation
  RETURN NUMBER

  IS
   l_dummy        VARCHAR2(1) := NULL;

   l_api_version_number  CONSTANT NUMBER        := 1.0;
   l_api_name            CONSTANT VARCHAR2(30)  := 'Validate_Pick_Drop_Lpn';
   l_return_status       VARCHAR2(1)            := fnd_api.g_ret_sts_success;

   l_drop_lpn_exists          BOOLEAN := FALSE;
   l_drop_lpn_has_picked_inv  BOOLEAN := FALSE;
   l_pick_lpn_delivery_id     NUMBER  := NULL;
   l_drop_lpn_delivery_id     NUMBER  := NULL;
   l_line_rows                WSH_UTIL_CORE.id_tab_type;  -- Added for bug#4106176
   l_grouping_rows            WSH_UTIL_CORE.id_tab_type;  -- Added for bug#4106176

   TYPE lpn_rectype is RECORD
   (
    lpn_id       wms_license_plate_numbers.lpn_id%TYPE,
    lpn_context  wms_license_plate_numbers.lpn_context%TYPE,
    subinventory_code  wms_license_plate_numbers.subinventory_code%TYPE,
    locator_id  wms_license_plate_numbers.locator_id%TYPE
   );
   drop_lpn_rec lpn_rectype;

   CURSOR drop_lpn_cursor IS
   SELECT lpn_id,
     lpn_context,
     subinventory_code,
     locator_id
     FROM wms_license_plate_numbers
    WHERE license_plate_number = p_drop_lpn
      AND organization_id      = p_organization_id;

   CURSOR pick_delivery_cursor IS
   SELECT wda.delivery_id
     FROM wsh_delivery_assignments        wda,
          wsh_delivery_details            wdd,
          mtl_material_transactions_temp  temp
    WHERE wda.delivery_detail_id  = wdd.delivery_detail_id
      AND wdd.move_order_line_id  = temp.move_order_line_id
      AND wdd.organization_id     = temp.organization_id
      AND temp.transfer_lpn_id    = p_pick_lpn_id
      AND temp.organization_id    = p_organization_id ;

   CURSOR drop_delivery_cursor(l_lpn_id IN NUMBER) IS
   SELECT wda.delivery_id
     FROM wsh_delivery_assignments        wda,
          wsh_delivery_details            wdd,
          wms_license_plate_numbers lpn
     WHERE wda.parent_delivery_detail_id = wdd.delivery_detail_id
      AND wdd.lpn_id                     = lpn.lpn_id
      AND wdd.released_status = 'X'   -- For LPN reuse ER : 6845650
      AND lpn.outermost_lpn_id           = l_lpn_id
      AND wdd.organization_id            = p_organization_id ;

   l_delivery_match_flag NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      mydebug ('Start Validate_Pick_Drop_Lpn.');
   END IF;

   --
   -- Initialize API return status to success
   --
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   l_delivery_match_flag := -1;

   --
   -- Begin validation process:
   -- Check if drop lpn exists by trying to retrieve
   -- its lpn ID.  If it does not exist,
   -- no further validations required - return success.
   --
   OPEN drop_lpn_cursor;
   FETCH drop_lpn_cursor INTO drop_lpn_rec;
   IF drop_lpn_cursor%NOTFOUND THEN
      l_drop_lpn_exists := FALSE;
   ELSE
      l_drop_lpn_exists := TRUE;
   END IF;

   IF NOT l_drop_lpn_exists THEN
      IF (l_debug = 1) THEN
         mydebug ('Drop LPN is a new LPN, no checking required.');
      END IF;
      RETURN 1;
   END IF;

   --
   -- If the drop lpn was pre-generated, no validations required
   --

   IF drop_lpn_rec.lpn_context =
      WMS_Container_PUB.LPN_CONTEXT_PREGENERATED THEN
      --
      -- Update the context to "Resides in Inventory" (1)
      --
   /*   UPDATE wms_license_plate_numbers
         SET lpn_context = WMS_Container_PUB.LPN_CONTEXT_INV
      WHERE lpn_id = drop_lpn_rec.lpn_id;*/

      IF (l_debug = 1) THEN
         mydebug ('Drop LPN is pre-generated, no checking required.');
      END IF;
    RETURN 1;

    ELSIF drop_lpn_rec.lpn_context = WMS_Container_PUB.lpn_context_picked THEN
      IF drop_lpn_rec.subinventory_code <>  p_drop_sub or
   drop_lpn_rec.locator_id <> p_drop_loc THEN
    IF (l_debug = 1) THEN
       mydebug ('Drop LPN does not belong to the same sub and loc.');
    END IF;
    RETURN 2; -- Drop LPN resides in another Staging Lane
      END IF;
   END IF;

   IF drop_lpn_rec.lpn_context =
         WMS_Container_PUB.LPN_LOADED_FOR_SHIPMENT THEN
         IF (l_debug = 1) THEN
            mydebug ('Drop LPN is loaded to dock door already');
         END IF;
         RETURN 4; -- Drop LPN is loaded  to dock door already
   END IF;

   --
   -- Drop LPN cannot be the same as the picked LPN
   --
   IF drop_lpn_rec.lpn_id = p_pick_lpn_id THEN
      IF (l_debug = 1) THEN
         mydebug ('Drop LPN cannot be the picked LPN.');
      END IF;
      RETURN 3; -- Drop LPN Cannot be the same as Pick LPN
   END IF;


   --
   -- Now check if the picked LPN and drop LPN
   -- belong to different deliveries
   --
   OPEN pick_delivery_cursor;
   LOOP
      FETCH pick_delivery_cursor INTO l_pick_lpn_delivery_id;
      EXIT WHEN l_pick_lpn_delivery_id IS NOT NULL OR pick_delivery_cursor%NOTFOUND;
   END LOOP;
   CLOSE pick_delivery_cursor;

   --
   -- If the picked LPN is not associated with a delivery yet
   -- then no further checking required, return success
   --
   IF l_pick_lpn_delivery_id is NULL THEN

      /*Bug#4106176.The following block is added.*/
      BEGIN
        SELECT delivery_detail_id
   INTO l_line_rows(1)
        FROM wsh_delivery_details
   WHERE lpn_id =  drop_lpn_rec.lpn_id
   AND rownum = 1 ;

       SELECT wdd.delivery_detail_id
       INTO l_line_rows(2)
       FROM wsh_delivery_details wdd, Mtl_material_transactions_temp mmtt
       WHERE mmtt.move_order_line_id = wdd.move_order_line_id
       AND wdd.organization_id = mmtt.organization_id
       AND mmtt.organization_id= p_organization_id
       AND mmtt.transfer_lpn_id= p_pick_lpn_id
       AND rownum = 1 ;

      --call to the shipping API.
      WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping( p_line_rows     => l_line_rows,
                                    x_grouping_rows => l_grouping_rows,
                x_return_status => l_return_status);
      IF (l_debug = 1) THEN
         mydebug ('parameters : l_line_rows(1) :'||l_line_rows(1) ||',l_line_rows(2) :' || l_line_rows(2) );
         mydebug('count l_grp_rows'|| l_grouping_rows.count);
         mydebug('l_grp_rows(1) : '||l_grouping_rows(1) ||',l_grp_rows(2) : '||l_grouping_rows(2) );
      END IF;

      IF (l_return_status = FND_API.G_RET_STS_SUCCESS AND l_grouping_rows(1) = l_grouping_rows(2) ) THEN
           IF (l_debug = 1) THEN
            mydebug('The LPN with LPN_ID ' || p_pick_lpn_id || ' can be dropped into LPN_ID '||drop_lpn_rec.lpn_id);
           END IF;
           RETURN 1; --Validated both LPNs , so return success.
      ELSE
           IF (l_debug = 1) THEN
                  mydebug('Picked LPN does not belong to same delivery as Drop LPN. So cannot be dropped');
           END IF;
      RETURN 0;
       END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
           mydebug('No Data found Exception raised when checking for delivery grouping');
           mydebug('Picked LPN is not associated with a delivery, so dont show ANY lpn.');
        END IF;
        RETURN 0;
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          mydebug('Other Exception raised when checking for delivery grouping');
          mydebug('Picked LPN is not associated with a delivery, so dont show ANY lpn.');
        END IF;
        RETURN 0;
    END; --End of Fix for bug#4106176
  END IF;

   --
   -- Find the drop LPN's delivery ID
   --

   OPEN drop_delivery_cursor(drop_lpn_rec.lpn_id);
   LOOP
      FETCH drop_delivery_cursor INTO l_drop_lpn_delivery_id;
      EXIT WHEN drop_delivery_cursor%notfound OR l_delivery_match_flag = 0;

      IF l_drop_lpn_delivery_id is NOT NULL THEN

    IF l_drop_lpn_delivery_id <> l_pick_lpn_delivery_id THEN
       IF (l_debug = 1) THEN
          mydebug('Picked and drop LPNs are on different deliveries.');
       END IF;

       l_delivery_match_flag := 0;
     ELSE
       --
       -- Drop LPN and picked LPN are on the same delivery
       -- return success
       --
       IF (l_debug = 1) THEN
          mydebug('Drop and pick LPNs are on the same delivery: '||l_drop_lpn_delivery_id);
       END IF;

       l_delivery_match_flag := 1;
    END IF;
      END IF;

   END LOOP;
   CLOSE drop_delivery_cursor;

   IF l_delivery_match_flag = 0 OR l_delivery_match_flag = -1 THEN

      RETURN 0;

    ELSIF l_delivery_match_flag = 1 THEN

      RETURN 1;

   END IF;

   IF l_return_status =FND_API.g_ret_sts_success THEN
      RETURN 1;
    ELSE
      RETURN 0;
   END IF;

EXCEPTION
    WHEN fnd_api.g_exc_error THEN

       RETURN 0;

    WHEN OTHERS THEN

       RETURN 0;

END validate_pick_drop_lpn;


 PROCEDURE  default_pick_drop_lpn
  (  p_api_version_number    IN   NUMBER                   ,
  p_init_msg_lst          IN   VARCHAR2 := fnd_api.g_false  ,
  p_pick_lpn_id           IN   NUMBER                       ,
  p_organization_id       IN   NUMBER                       ,
  x_lpn_number           OUT   nocopy VARCHAR2)

  IS

  l_api_version_number  CONSTANT NUMBER        := 1.0;
  l_api_name            CONSTANT VARCHAR2(30)  :=
                        'default_pick_drop_lpn';
  l_return_status       VARCHAR2(1)            :=
    fnd_api.g_ret_sts_success;
  l_delivery_id NUMBER;
  l_drop_sub   VARCHAR2(10);
  l_drop_loc   NUMBER;
  l_lpn_id     NUMBER;


  CURSOR pick_delivery_cursor IS
  SELECT wda.delivery_id
  FROM wsh_delivery_assignments        wda,
  wsh_delivery_details            wdd,
  mtl_material_transactions_temp  temp
  WHERE wda.delivery_detail_id   = wdd.delivery_detail_id
  AND wdd.move_order_line_id  = temp.move_order_line_id
  AND wdd.organization_id     = temp.organization_id
  AND temp.transfer_lpn_id    = p_pick_lpn_id
  AND temp.organization_id    = p_organization_id;

  CURSOR drop_delivery_cursor (l_delivery_id_c IN NUMBER,
                l_drop_sub_c IN VARCHAR2,
                l_drop_loc_c IN NUMBER ) IS
  --Bug Fix 4622935 Added hint as suggested by Ben Chihaoui
  SELECT /*+ index(wda WSH_DELIVERY_ASSIGNMENTS_N1) ORDERED USE_NL (WDA WDD WLPN) */ wlpn.outermost_lpn_id
  FROM wsh_delivery_assignments        wda,
  wsh_delivery_details            wdd,
  wms_license_plate_numbers       wlpn
  WHERE  wda.delivery_id               = l_delivery_id_c
  AND wda.parent_delivery_detail_id = wdd.delivery_detail_id
  AND wdd.organization_id           = p_organization_id
    AND wdd.lpn_id                    = wlpn.lpn_id
  AND wlpn.subinventory_code        = l_drop_sub_c
  AND wlpn.locator_id               = l_drop_loc_c
  AND wlpn.lpn_context              = 11
    ORDER BY wda.CREATION_DATE DESC ;


  delivery_id_rec pick_delivery_cursor%ROWTYPE;
  license_plate_rec drop_delivery_cursor%ROWTYPE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN


  IF NOT fnd_api.compatible_api_call (l_api_version_number
  , p_api_version_number
  , l_api_name
  , G_PKG_NAME
  ) THEN
     FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
       FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  l_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  --  Initialize message list.
  --

  IF fnd_api.to_boolean(p_init_msg_lst) THEN
  fnd_msg_pub.initialize;
  END IF;


  BEGIN
     Select transfer_subinventory, transfer_to_location into l_drop_sub,
       l_drop_loc
  from mtl_material_transactions_temp
  where transfer_lpn_id    = p_pick_lpn_id
  AND organization_id    = p_organization_id;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
  l_delivery_id := NULL;

  WHEN OTHERS THEN
  l_delivery_id := NULL;
  END;

  -- Select the Delivery for the LPN that is being picked

  FOR delivery_id_rec IN pick_delivery_cursor
    LOOP
       l_delivery_id := delivery_id_rec.delivery_id;
    EXIT WHEN delivery_id_rec.delivery_id IS NOT NULL OR pick_delivery_cursor%NOTFOUND;
  END LOOP;


  -- Find the drop LPN's delivery ID
  FOR license_plate_rec IN drop_delivery_cursor
    (l_delivery_id,l_drop_sub,l_drop_loc )
  LOOP
     l_lpn_id  := license_plate_rec.outermost_lpn_id;
     EXIT WHEN  license_plate_rec.outermost_lpn_id IS NOT NULL OR drop_delivery_cursor%NOTFOUND;
  END LOOP;


  BEGIN
  SELECT license_plate_number INTO x_lpn_number FROM
    wms_license_plate_numbers WHERE lpn_id = l_lpn_id;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
   x_lpn_number := NULL;

     WHEN OTHERS THEN
        x_lpn_number := NULL;
  END;

  END default_pick_drop_lpn;


END wms_task_dispatch_gen;

/
