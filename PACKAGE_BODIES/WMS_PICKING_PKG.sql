--------------------------------------------------------
--  DDL for Package Body WMS_PICKING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PICKING_PKG" AS
  /* $Header: WMSPLPDB.pls 120.37.12010000.7 2010/04/02 09:26:07 kjujjuru ship $ */

  g_trace_on                  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  g_group_sequence_number     NUMBER := 1;
  g_max_group_sequence_number NUMBER := -1;  -- Bug#5185031
  g_period_id                 NUMBER;

  --for UCC128, same as in WMSUCCSB.pls
  g_gtin_cross_ref_type VARCHAR2(25) := fnd_profile.value('INV:GTIN_CROSS_REFERENCE_TYPE');
  g_gtin_code_length NUMBER := 14;

  g_cartonization_ids numset_tabType; --Bug: 7254397  Store LPNs for ClusterPickByLabel
  g_cartonization_ids_inx NUMBER := 0; --Bug: 7254397

  --Added for Case Picking Project start
  g_order_numbers numset_tabType;
  g_order_numbers_inx NUMBER := 0;

  g_pick_slip_numbers numset_tabType;
  g_pick_slip_numbers_inx NUMBER := 0;
  --Added for Case Picking Project end

  PROCEDURE mydebug(p_msg IN VARCHAR2, p_api_name IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF g_trace_on = 1 THEN
       inv_mobile_helper_functions.tracelog( p_err_msg => p_msg
                                           , p_module  => 'WMS_PICKING_PKG.' || p_api_name
                                           , p_level   => 4
                                           );
    END IF;
  END;
  -- Bug: 7254397
  PROCEDURE insert_cartonization_id (
     p_lpn_id                   IN NUMBER,
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2)
  IS
  l_api_name                    VARCHAR2(30)   := 'insert_cartonization_id';
  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('Enter:', l_api_name);
       mydebug('p_lpn_id: ' || TO_CHAR(p_lpn_id), l_api_name);
    END IF;
    g_cartonization_ids_inx := g_cartonization_ids_inx + 1;
    g_cartonization_ids(g_cartonization_ids_inx) := p_lpn_id;
    x_return_status := 'S';
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='U';
      IF (l_debug = 1) THEN
        mydebug('Unknown Exception occurred: ' || SQLERRM,'insert_cartonization_id');
      END IF;
  END;

  -- Bug: 7254397
  FUNCTION list_cartonization_id RETURN numset_t PIPELINED
  IS
    l_api_name                    VARCHAR2(30)   := 'list_cartonization_id';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_count NUMBER;
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('Enter:', l_api_name);
    END IF;
    l_count := g_cartonization_ids.COUNT;
    FOR i IN 1..l_count LOOP
      PIPE ROW(g_cartonization_ids(i));
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('Unknown Exception occurred: ' || SQLERRM,'list_cartonization_id');
      END IF;
      RETURN;
  END;
  -- Bug: 7254397
  PROCEDURE clear_cartonization_id(
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2)
  IS
    l_api_name                    VARCHAR2(30)   := 'clear_cartonization_id';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('Enter:', l_api_name);
    END IF;
    g_cartonization_ids.DELETE;
    g_cartonization_ids_inx := 0;
    x_return_status :='S';
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='U';
      IF (l_debug = 1) THEN
        mydebug('Unknown Exception occurred: ' || SQLERRM,'clear_cartonization_id');
      END IF;
  END;

  FUNCTION get_total_lpns RETURN NUMBER IS
  BEGIN
    RETURN g_cartonization_ids_inx;
  END;

  --Added for Case Picking Project start
  PROCEDURE insert_order_numbers (
     p_order_number             IN NUMBER,
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2)
  IS
  l_api_name                    VARCHAR2(30)   := 'insert_order_numbers';
  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('Enter:', l_api_name);
       mydebug('p_order_number: ' || TO_CHAR(p_order_number), l_api_name);
    END IF;
    g_order_numbers_inx := g_order_numbers_inx + 1;
    g_order_numbers(g_order_numbers_inx) := p_order_number;
    x_return_status := 'S';
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='U';
      IF (l_debug = 1) THEN
        mydebug('Unknown Exception occurred: ' || SQLERRM,'insert_order_numbers');
      END IF;
  END;

  FUNCTION list_order_numbers RETURN numset_t PIPELINED
  IS
    l_api_name                    VARCHAR2(30)   := 'list_order_numbers';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_count NUMBER;
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('Enter:', l_api_name);
    END IF;
    l_count := g_order_numbers.COUNT;
    mydebug('l_count'||l_count, l_api_name);
    FOR i IN 1..l_count LOOP
      PIPE ROW(g_order_numbers(i));
    END LOOP;
    RETURN;
  EXCEPTION
  WHEN NO_DATA_NEEDED THEN
      IF (l_debug = 1) THEN
        mydebug('NO_DATA_NEEDED Exception occurred: ' || SQLERRM,'list_order_numbers');
      END IF;
  WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('Unknown Exception occurred: ' || SQLERRM,'list_order_numbers');
      END IF;
      RETURN;
  END;

  PROCEDURE clear_order_numbers(
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2)
  IS
    l_api_name                    VARCHAR2(30)   := 'clear_order_numbers';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('Enter:', l_api_name);
    END IF;
    g_order_numbers.DELETE;
    g_order_numbers_inx := 0;
    x_return_status :='S';
  EXCEPTION
  WHEN OTHERS THEN
      x_return_status :='U';
      IF (l_debug = 1) THEN
        mydebug('Unknown Exception occurred: ' || SQLERRM,'clear_order_numbers');
      END IF;
  END;

    PROCEDURE insert_pick_slip_number (
     p_pick_slip_number             IN NUMBER,
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2)
  IS
  l_api_name                    VARCHAR2(30)   := 'insert_pick_slip_number';
  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('Enter:', l_api_name);
       mydebug('p_pick_slip_number: ' || TO_CHAR(p_pick_slip_number), l_api_name);
    END IF;
    g_pick_slip_numbers_inx := g_pick_slip_numbers_inx + 1;
    g_pick_slip_numbers(g_pick_slip_numbers_inx) := p_pick_slip_number;
    x_return_status := 'S';
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='U';
      IF (l_debug = 1) THEN
        mydebug('Unknown Exception occurred: ' || SQLERRM,'insert_pick_slip_number');
      END IF;
  END;

  FUNCTION list_pick_slip_numbers RETURN numset_t PIPELINED
  IS
    l_api_name                    VARCHAR2(30)   := 'list_pick_slip_numbers';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_count NUMBER;
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('Enter:', l_api_name);
    END IF;
    l_count := g_pick_slip_numbers.COUNT;
    mydebug('l_count'||l_count, l_api_name);
    FOR i IN 1..l_count LOOP
      PIPE ROW(g_pick_slip_numbers(i));
    END LOOP;
    RETURN;
  EXCEPTION
  WHEN NO_DATA_NEEDED THEN
      IF (l_debug = 1) THEN
        mydebug('NO_DATA_NEEDED Exception occurred: ' || SQLERRM,'clear_order_numbers');
      END IF;

  WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('Unknown Exception occurred: ' || SQLERRM,'list_pick_slip_numbers');
      END IF;
      RETURN;
  END;

  PROCEDURE clear_pick_slip_number(
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2)
  IS
    l_api_name                    VARCHAR2(30)   := 'clear_pick_slip_number';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('Enter:', l_api_name);
    END IF;
    g_pick_slip_numbers.DELETE;
    g_pick_slip_numbers_inx := 0;
    x_return_status :='S';
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='U';
      IF (l_debug = 1) THEN
        mydebug('Unknown Exception occurred: ' || SQLERRM,'clear_pick_slip_number');
      END IF;
  END;


 --Added for Case Picking Project end



  PROCEDURE change_task_to_active(p_transaction_temp_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2) IS
  --PRAGMA AUTONOMOUS_TRANSACTION;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    UPDATE wms_dispatched_tasks
       SET status = 9
     WHERE transaction_temp_id = p_transaction_temp_id;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;
  END;

  --
  -- Name
  --   PROCEDURE GET_NEXT_TASK_INFO
  --
  -- Purpose
  --   Gets the task information.
  --
  -- Input Parameters
  --   p_sign_on_emp_id       => Employee ID
  --   p_sign_on_org_id       => Organization ID
  --   p_transaction_temp_id  => Transaction Temp ID (For Manual Pick)
  --   p_cartonization_id     => Cartonization ID (For Label Picking)
  --   p_device_id            => Device ID
  --   p_is_cluster_pick      => Cluster Pick or not
  --   p_cartons_list         => Carton Grouping ID List (For Cluster Picking)
  --
  -- Output Parameters
  --   x_task_info            => Ref Cursor containing the Task Information
  --   x_return_status        => FND_API.G_RET_STS_SUCESSS or
  --                             FND_API.G_RET_STS_ERROR
  --   x_error_code           => Code indicating the error message.
  --   x_error_mesg           => Error Messages
  --   x_mesg_count           => Error Messages Count
  PROCEDURE get_next_task_info(
    p_sign_on_emp_id      IN            NUMBER
  , p_sign_on_org_id      IN            NUMBER
  , p_transaction_temp_id IN            NUMBER := NULL
  , p_cartonization_id    IN            NUMBER := NULL
  , p_device_id           IN            NUMBER := NULL
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_error_code          OUT NOCOPY    NUMBER
  , x_mesg_count          OUT NOCOPY    NUMBER
  , x_error_mesg          OUT NOCOPY    VARCHAR2
  , x_task_info           OUT NOCOPY    t_genref
  , p_is_cluster_pick     IN            VARCHAR2
  , p_cartons_list        IN            VARCHAR2
  , p_is_manifest_pick    IN            VARCHAR2 --Added for Case Picking Project
  ) IS

    cursor  c_lot_csr(p_temp_id  NUMBER) is
           select lot_number
           from mtl_transaction_lots_temp
           where transaction_temp_id = p_temp_id;

    cursor  c_same_lot_csr(p_temp_id NUMBER, p_lot VARCHAR2) is
             select primary_quantity, transaction_quantity, serial_transaction_temp_id
             from mtl_transaction_lots_temp
             where transaction_temp_id = p_temp_id
             and   lot_number = p_lot;

--OVPK Start 1

    l_check_overpick_passed VARCHAR2(1);
    l_is_bulk_picked_task   VARCHAR2(1);
    l_move_order_type       NUMBER;
    l_temp                  VARCHAR2(1);

--OVPK End 1

    l_api_name                     VARCHAR2(30)   := 'GET_NEXT_TASK_INFO';
    l_transaction_temp_id          NUMBER;
    l_task_id                      NUMBER;
    l_org_id                       NUMBER;
    l_inventory_item_id            NUMBER;
    l_cartonization_id             NUMBER;
    l_allocated_lpn_id             NUMBER;
    l_serial_number_control_code   NUMBER;
    l_lot_control_code             NUMBER;
    l_sl_alloc_flag                VARCHAR2(1)    := 'N';
    l_serial_temp_id               NUMBER         := -999;
    l_carton_name                  VARCHAR2(30);
    l_carton_item_id               NUMBER         := -999;
    l_carton_item_name             VARCHAR2(40)   := '';
    l_allocated_lpn_name           VARCHAR2(30)   := '';
    l_allocated_outermost_lpn_name VARCHAR2(30)   := '';
    l_nbr_tasks                    NUMBER         := -999;
    l_sql                          VARCHAR2(20000);
    l_task_cur                     t_genref;
    b_is_cluster_pick              BOOLEAN        := FALSE;
    l_cartons_list                 VARCHAR2(4000) := ' (-999) ';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_same_lot_rec_cnt      NUMBER;
    l_same_lot_pri_qty      NUMBER;
    l_same_lot_tra_qty      NUMBER;
    l_sum_same_lot_pri_qty  NUMBER;
    l_sum_same_lot_tra_qty  NUMBER;
    l_mtlt_rec        mtl_transaction_lots_temp%ROWTYPE;
    l_lot                   VARCHAR2(2000);  --Bug 6148865
    l_old_lot               VARCHAR2(2000);  --Bug 6148865
    l_new_serial_temp_id    NUMBER;
    l_delivery_id           NUMBER;
    l_carton_grouping_id    NUMBER;
    l_cluster_key           VARCHAR2(80);
    l_transaction_action_id NUMBER;

    --For UCC128
    l_item_type VARCHAR2(1);

    --Start Bug 6682436
    l_honor_case_pick_flag VARCHAR2(1) := 'N';
    l_template_name VARCHAR2(128) := NULL;
    --End Bug 6682436

    -- Start Bug 4434111
    CURSOR c_get_serials(p_transaction_temp_id NUMBER) IS
    SELECT msnt.fm_serial_number,
           msnt.to_serial_number
    FROM mtl_serial_numbers_temp msnt
    WHERE msnt.transaction_temp_id = p_transaction_temp_id;
    --
    l_serial_alloc_flag mtl_material_transactions_temp.serial_allocated_flag%TYPE := 'N';
    l_user_id           NUMBER;
    l_fm_serial_number  VARCHAR2(30);
    l_to_serial_number  VARCHAR2(30);
    --
    CURSOR c_get_serialLots(p_transaction_temp_id NUMBER) IS
    SELECT msnt.fm_serial_number, msnt.to_serial_number
    FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
    WHERE msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
    AND mtlt.transaction_temp_id = p_transaction_temp_id;
    -- End Bug 4434111
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('Enter to GET_NEXT_TASK_INFO procedure', l_api_name);
    END IF;
    x_error_code     := 0;
    x_mesg_count     := 0;
    x_error_mesg     := '';
    x_return_status  := fnd_api.g_ret_sts_success;
    IF (l_debug = 1) THEN
       mydebug('Get the transaction temp id which will be the next task to be processed', l_api_name);
    END IF;
    SAVEPOINT next_task_inquiry;

    IF p_is_cluster_pick = 'Y'
       OR p_is_cluster_pick = 'y' THEN
     --{
      IF (l_debug = 1) THEN
         mydebug('Cluster pick task', l_api_name);
      END IF;
     --}
    ELSE -- not a cluster pick task
     --{
      IF (p_transaction_temp_id IS NOT NULL) THEN
        IF (l_debug = 1) THEN
           mydebug('Get the relevant info for transaction temp id: '|| p_transaction_temp_id, l_api_name);
        END IF;

        BEGIN
          SELECT mmtt.transaction_temp_id
               , wdt.task_id
               , mmtt.organization_id
               , mmtt.inventory_item_id
               , mmtt.cartonization_id
               , mmtt.allocated_lpn_id
               , mmtt.transaction_action_id
               , DECODE (mmtt.parent_line_id, mmtt.transaction_temp_id, 'Y', 'N')
               , mmtt.serial_allocated_flag -- Bug 4434111
            INTO l_transaction_temp_id
               , l_task_id
               , l_org_id
               , l_inventory_item_id
               , l_cartonization_id
               , l_allocated_lpn_id
               , l_transaction_action_id
               , l_is_bulk_picked_task
               , l_serial_alloc_flag -- Bug 4434111
            FROM mtl_material_transactions_temp mmtt, wms_dispatched_tasks wdt
           WHERE wdt.person_id = p_sign_on_emp_id
             AND wdt.organization_id = p_sign_on_org_id
             AND wdt.status <= 3
             AND wdt.task_type IN (1, 4, 5, 6)
             AND wdt.transaction_temp_id = mmtt.transaction_temp_id
             AND mmtt.transaction_temp_id = p_transaction_temp_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_error_code  := 1;
            RAISE fnd_api.g_exc_unexpected_error;
        END;
      ELSIF (p_cartonization_id IS NOT NULL) THEN
        IF (l_debug = 1) THEN
           mydebug('Get the relevant info for carton id:'|| p_cartonization_id, l_api_name);
        END IF;

        BEGIN
           --bugfix 2961842. Changed the SQL into a subquery so that ORDER BY is evaluated before filtering the first task
           SELECT   tt.transaction_temp_id
                 , tt.task_id
                 , tt.organization_id
                 , tt.inventory_item_id
                 , tt.cartonization_id
                 , tt.allocated_lpn_id
                 , tt.serial_allocated_flag -- Bug 4434111
              INTO l_transaction_temp_id
                 , l_task_id
                 , l_org_id
                 , l_inventory_item_id
                 , l_cartonization_id
                 , l_allocated_lpn_id
                 , l_serial_alloc_flag -- Bug 4434111
              FROM
              (
                SELECT mmtt.transaction_temp_id transaction_temp_id
                     , wdt.task_id              task_id
                     , mmtt.organization_id     organization_id
                     , mmtt.inventory_item_id   inventory_item_id
                     , mmtt.cartonization_id    cartonization_id
                     , mmtt.allocated_lpn_id    allocated_lpn_id
                     , mmtt.serial_allocated_flag serial_allocated_flag
                FROM mtl_material_transactions_temp mmtt, wms_dispatched_tasks wdt, mtl_item_locations loc, mtl_secondary_inventories sub
                WHERE wdt.person_id = p_sign_on_emp_id
                  AND wdt.organization_id = p_sign_on_org_id
                  AND wdt.status <= 3
                  AND (wdt.task_type IN (1, 4, 5, 6))
                  AND wdt.transaction_temp_id = mmtt.transaction_temp_id
                  AND mmtt.cartonization_id = p_cartonization_id
                  AND sub.organization_id = mmtt.organization_id
                  AND sub.secondary_inventory_name = mmtt.subinventory_code
                  AND loc.organization_id = mmtt.organization_id
                  AND loc.inventory_location_id = mmtt.locator_id
                ORDER BY wdt.priority, sub.picking_order, -- for task resequencing in the pick load page
                          loc.picking_order, wdt.task_id

              ) tt
             WHERE ROWNUM < 2;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_error_code  := 1;
            RAISE fnd_api.g_exc_unexpected_error;
        END;
      ELSIF (p_device_id IS NOT NULL) THEN
        IF (l_debug = 1) THEN
           mydebug('Get the relevant info for device id:'|| p_device_id, l_api_name);
        END IF;

        BEGIN
          --bugfix 2961842. Changed the SQL into a subquery so that ORDER BY is evaluated before filtering the first task
           SELECT   tt.transaction_temp_id
                 , tt.task_id
                 , tt.organization_id
                 , tt.inventory_item_id
                 , tt.cartonization_id
                 , tt.allocated_lpn_id
                 , tt.serial_allocated_flag -- Bug 4434111
              INTO l_transaction_temp_id
                 , l_task_id
                 , l_org_id
                 , l_inventory_item_id
                 , l_cartonization_id
                 , l_allocated_lpn_id
                 , l_serial_alloc_flag -- Bug 4434111
              FROM
              (
                SELECT mmtt.transaction_temp_id transaction_temp_id
                     , wdt.task_id              task_id
                     , mmtt.organization_id     organization_id
                     , mmtt.inventory_item_id   inventory_item_id
                     , mmtt.cartonization_id    cartonization_id
                     , mmtt.allocated_lpn_id    allocated_lpn_id
                     , mmtt.serial_allocated_flag serial_allocated_flag
                FROM mtl_material_transactions_temp mmtt, wms_dispatched_tasks wdt, mtl_item_locations loc, mtl_secondary_inventories sub
                WHERE wdt.person_id = p_sign_on_emp_id
                  AND wdt.organization_id = p_sign_on_org_id
                  AND wdt.status <= 3
                  AND (wdt.task_type IN (1, 4, 5, 6))
                  AND wdt.transaction_temp_id = mmtt.transaction_temp_id
                  AND wdt.device_id = p_device_id
                  AND wdt.device_invoked = 'Y'
                  AND sub.organization_id = mmtt.organization_id
                  AND sub.secondary_inventory_name = mmtt.subinventory_code
                  AND loc.organization_id = mmtt.organization_id
                  AND loc.inventory_location_id = mmtt.locator_id
                ORDER BY wdt.priority, sub.picking_order, -- for task resequencing in the pick load page
                                                   loc.picking_order, wdt.task_id
             )tt
             WHERE ROWNUM < 2;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_error_code  := 1;
            RAISE fnd_api.g_exc_unexpected_error;
        END;
      ELSE
        IF (l_debug = 1) THEN
           mydebug('Open cursor eligible_tasks', l_api_name);
        END IF;

        BEGIN
          --bugfix 2961842. Changed the SQL into a subquery so that ORDER BY is evaluated before filtering the first task
           SELECT   tt.transaction_temp_id
                 , tt.task_id
                 , tt.organization_id
                 , tt.inventory_item_id
                 , tt.cartonization_id
                 , tt.allocated_lpn_id
                 , tt.serial_allocated_flag -- Bug 4434111
              INTO l_transaction_temp_id
                 , l_task_id
                 , l_org_id
                 , l_inventory_item_id
                 , l_cartonization_id
                 , l_allocated_lpn_id
                 , l_serial_alloc_flag -- Bug 4434111
              FROM
              (
                SELECT mmtt.transaction_temp_id transaction_temp_id
                     , wdt.task_id              task_id
                     , mmtt.organization_id     organization_id
                     , mmtt.inventory_item_id   inventory_item_id
                     , mmtt.cartonization_id    cartonization_id
                     , mmtt.allocated_lpn_id    allocated_lpn_id
                     , mmtt.serial_allocated_flag serial_allocated_flag
                FROM mtl_material_transactions_temp mmtt, wms_dispatched_tasks wdt, mtl_item_locations loc, mtl_secondary_inventories sub
                WHERE wdt.person_id = p_sign_on_emp_id
                  AND wdt.organization_id = p_sign_on_org_id
                  AND wdt.status <= 3
                  AND (wdt.task_type IN (1, 4, 5, 6))
                  AND wdt.transaction_temp_id = mmtt.transaction_temp_id
                  AND sub.organization_id = mmtt.organization_id
                  AND sub.secondary_inventory_name = mmtt.subinventory_code
                  AND loc.organization_id = mmtt.organization_id
                  AND loc.inventory_location_id = mmtt.locator_id
                ORDER BY wdt.priority, sub.picking_order, -- for task resequencing in the pick load page
                         loc.picking_order, wdt.task_id
             )tt
             WHERE ROWNUM < 2;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_error_code  := 1;
            RAISE fnd_api.g_exc_unexpected_error;
        END;
      END IF;
      --}
    END IF; -- cluster pick check

    -- Bug# 4185621: update child line posting flag to 'N' for bulking picking task
    IF (l_is_bulk_picked_task = 'Y') THEN
        UPDATE mtl_material_transactions_temp mmtt
           SET posting_flag = 'N'
         WHERE parent_line_id = p_transaction_temp_id
           AND parent_line_id <> transaction_temp_id;
    END IF;
    -- Bug# 4185621: end change

    IF (l_debug = 1) THEN
       mydebug('Get the next task to be performed. temp id:'|| l_transaction_temp_id, l_api_name);
    END IF;

    SELECT serial_number_control_code
         , lot_control_code
      INTO l_serial_number_control_code
         , l_lot_control_code
      FROM mtl_system_items_b
     WHERE inventory_item_id = l_inventory_item_id
       AND organization_id = l_org_id;

    IF (l_debug = 1) THEN
       mydebug('Serial control code : '|| l_serial_number_control_code, l_api_name);
       mydebug('Lot control code    : '|| l_lot_control_code, l_api_name);
    END IF;

    IF  l_serial_number_control_code <> 1
        AND l_serial_number_control_code <> 6 THEN
      IF (l_debug = 1) THEN
         mydebug('Check if the serial numbers are already allocated or not', l_api_name);
      END IF;

      BEGIN
        IF l_lot_control_code = 1 THEN -- not lot controlled
          SELECT msnt.transaction_temp_id
            INTO l_serial_temp_id
            FROM mtl_serial_numbers_temp msnt
           WHERE msnt.transaction_temp_id = l_transaction_temp_id
             AND ROWNUM < 2;
        ELSE -- lot controlled
          --Bug 9473783 Modified the where clause
          SELECT msnt.transaction_temp_id
            INTO l_serial_temp_id
            FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt, mtl_material_transactions_temp mmtt
           WHERE ((msnt.transaction_temp_id = NVL(mtlt.serial_transaction_temp_id, -1)
                 AND mtlt.transaction_temp_id = l_transaction_temp_id)
              OR (msnt.transaction_temp_id = l_transaction_temp_id
                  AND mmtt.transaction_temp_id = l_transaction_temp_id AND mmtt.lot_number IS NOT NULL ))
             AND ROWNUM < 2;
        END IF;

        l_sl_alloc_flag  := 'Y';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_sl_alloc_flag  := 'N';
      END;
    END IF;

    -- Start bug 4434111
    IF (NVL(l_serial_alloc_flag,'N') = 'N' )
        AND l_sl_alloc_flag = 'Y'
    THEN
     --{
     l_sl_alloc_flag := 'N';
     l_user_id := fnd_global.user_id;

     IF l_lot_control_code = 1 THEN
      --{
      -- Only serial controlled item
      --
      OPEN c_get_serials(l_transaction_temp_id);
      LOOP
       --{
       EXIT WHEN c_get_serials%NOTFOUND;
       FETCH c_get_serials INTO
             l_fm_serial_number, l_to_serial_number;
       --
       IF (l_debug = 1) THEN
        mydebug('Not a lot controlled item, just serial', l_api_name);
        mydebug('From Serial Number = ' || l_fm_serial_number, l_api_name);
        mydebug('To Serial Number = ' || l_to_serial_number, l_api_name);
        mydebug('Inventory Item ID = ' || l_inventory_item_id, l_api_name);
        mydebug('Org ID = ' || l_org_id, l_api_name);
       END IF;
       --
       UPDATE mtl_serial_numbers
       SET group_mark_id       = NULL,
           last_update_date    = Sysdate,
           last_updated_by     = l_user_id
       WHERE serial_number     >= l_fm_serial_number
       AND   serial_number     <= l_to_serial_number
       AND inventory_item_id    = l_inventory_item_id
       AND current_organization_id = l_org_id;

       IF (l_debug = 1) THEN
          mydebug('Rows updated ' || sql%rowcount, l_api_name);
       END IF;
       --}
      END LOOP;
      CLOSE c_get_serials;
      --
      DELETE FROM mtl_serial_numbers_temp
      WHERE transaction_temp_id = l_transaction_temp_id;
      --
      IF (l_debug = 1) THEN
        mydebug('Rows deleted ' || sql%rowcount, l_api_name);
      END IF;
      --}
    ELSE
     --{
     -- Lot and serial controlled item
     --
     OPEN c_get_serialLots(l_transaction_temp_id);
     LOOP
       --{
       EXIT WHEN c_get_serialLots%NOTFOUND;
       FETCH c_get_serialLots INTO
             l_fm_serial_number, l_to_serial_number;
       --
       IF (l_debug = 1) THEN
        mydebug('Lot and serial controlled item', l_api_name);
        mydebug('From Serial Number = ' || l_fm_serial_number, l_api_name);
        mydebug('To Serial Number = ' || l_to_serial_number, l_api_name);
        mydebug('Inventory Item ID = ' || l_inventory_item_id, l_api_name);
        mydebug('Org ID = ' || l_org_id, l_api_name);
       END IF;
       --
       UPDATE mtl_serial_numbers
       SET group_mark_id       = NULL,
           last_update_date    = Sysdate,
           last_updated_by     = l_user_id
       WHERE serial_number     >= l_fm_serial_number
       AND   serial_number     <= l_to_serial_number
       AND inventory_item_id    = l_inventory_item_id
       AND current_organization_id = l_org_id;

       IF (l_debug = 1) THEN
          mydebug('Rows updated ' || sql%rowcount, l_api_name);
       END IF;
       --}
      END LOOP;
      CLOSE c_get_serialLots;
      --
      DELETE FROM mtl_serial_numbers_temp
      WHERE transaction_temp_id IN
       (
        SELECT serial_transaction_temp_id
        FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
        WHERE msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
        AND   mtlt.transaction_temp_id = l_transaction_temp_id
       );
      --
      IF (l_debug = 1) THEN
        mydebug('Rows deleted ' || sql%rowcount, l_api_name);
      END IF;
     --}
    END IF;
    --}
    END IF;
    -- End bug 4434111

    --bug 2755138.  Consolidate mtlt if there are multi record for the same lot number
    -- if it is not exact lpn match and item is lot controlled
    -- then check to see if need to consolidate of mtlt table in case there are multi record for the same lot number,
    -- we need to consolidate them before continue

    IF  (l_lot_control_code > 1)  THEN

         open c_lot_csr(l_transaction_temp_id);
         l_old_lot := null;
         loop
             fetch  c_lot_csr into l_lot;
             exit when c_lot_csr%NOTFOUND;

             IF (l_debug = 1) THEN
                   mydebug('consolidate mtlt 00 : lot number:'|| l_lot, l_api_name);
             END IF;

             if l_lot <> nvl(l_old_lot, '-999') then
                begin
                  select count(*),sum(primary_quantity),sum(transaction_quantity)
                  into l_same_lot_rec_cnt,  l_sum_same_lot_pri_qty, l_sum_same_lot_tra_qty
                  from mtl_transaction_lots_temp
                  where transaction_temp_id = l_transaction_temp_id
                  and   lot_number = l_lot;
                exception
                  when NO_DATA_FOUND  then
                    IF (l_debug = 1) THEN
                           mydebug('consolidate mtlt 11: there is no mtlt record for the lot:'|| l_lot, l_api_name);
                    END IF;
                    l_same_lot_rec_cnt :=0;
                  when others  then
                    IF (l_debug = 1) THEN
                       mydebug(' consolidate mtlt 11: there is an exception', l_api_name);
                    END IF;
                    l_same_lot_rec_cnt :=0;
                end;

                IF (l_debug = 1) THEN
                    mydebug('consolidate mtlt 22 : record count for the lot number:'|| l_lot||' is :' ||l_same_lot_rec_cnt, l_api_name);
                END IF;

                if nvl(l_same_lot_rec_cnt,0) > 1 then
                  select *
                  into l_mtlt_rec
                  from  mtl_transaction_lots_temp
                  where transaction_temp_id = l_transaction_temp_id
                  and   lot_number = l_lot
                  and   rownum = 1;

                  IF (l_serial_number_control_code >1 AND l_serial_number_control_code <>6)  -- lot serial controlled
                         AND l_sl_alloc_flag = 'Y' -- and allocate to serial ON

                  THEN
                        IF (l_debug = 1) THEN
                            mydebug('consolidate mtlt 33: lot/serial controlled and allocate to serial ON', l_api_name);
                        END IF;
                          SELECT mtl_material_transactions_s.NEXTVAL
                            INTO l_new_serial_temp_id
                            FROM  dual;
                          l_mtlt_rec.serial_transaction_temp_id := l_new_serial_temp_id;
                          l_sum_same_lot_pri_qty := 0;
                          l_sum_same_lot_tra_qty := 0;
                          open  c_same_lot_csr(l_transaction_temp_id, l_lot);
                          loop
                              fetch  c_same_lot_csr into  l_same_lot_pri_qty, l_same_lot_tra_qty,  l_serial_temp_id;
                              exit when c_same_lot_csr%NOTFOUND;
                              l_sum_same_lot_pri_qty := l_sum_same_lot_pri_qty + l_same_lot_pri_qty;
                              l_sum_same_lot_tra_qty := l_sum_same_lot_tra_qty + l_same_lot_tra_qty;

                               UPDATE mtl_serial_numbers
                                  SET group_mark_id = l_new_serial_temp_id
                                WHERE current_organization_id = l_org_id
                                  AND inventory_item_id = l_inventory_item_id
                                  AND serial_number in (select fm_serial_number
                                                         from  mtl_serial_numbers_temp
                                                         where transaction_temp_id = l_serial_temp_id);
                               UPDATE  mtl_serial_numbers_temp
                                  SET  transaction_temp_id = l_new_serial_temp_id
                                WHERE  transaction_temp_id = l_serial_temp_id;

                          end loop;
                          close  c_same_lot_csr;
                  ELSIF (l_serial_number_control_code >1 AND l_serial_number_control_code <>6)  -- lot serial controlled
                             AND l_sl_alloc_flag = 'N' -- and allocate to serial OFF
                         THEN
                         IF (l_debug = 1) THEN
                            mydebug('consolidate mtlt 44: lot controlled only OR lot/serial controlled but Allocate to serial OFF', l_api_name);
                         END IF;
                         SELECT mtl_material_transactions_s.NEXTVAL
                         INTO l_new_serial_temp_id
                         FROM  dual;
                         l_mtlt_rec.serial_transaction_temp_id := l_new_serial_temp_id;
                         begin
                            select sum(primary_quantity), sum(transaction_quantity)
                            into   l_sum_same_lot_pri_qty, l_sum_same_lot_tra_qty
                            from   mtl_transaction_lots_temp
                            where  transaction_temp_id = l_transaction_temp_id
                             and   lot_number = l_lot;
                         exception
                            when NO_DATA_FOUND  then
                                IF (l_debug = 1) THEN
                                     mydebug(' consolidate mtlt 50: there is no mtlt record for lot:'||l_lot, l_api_name);
                                END IF;
                            when others  then
                                IF (l_debug = 1) THEN
                                     mydebug(' consolidate mtlt 50: there is an exception', l_api_name);
                                END IF;
                         end;
                  END IF;   -- if l_serial_conde > 1 adn l_serial_code <> 6 and p_sn_allocated_flag = 'Y'
                  l_mtlt_rec.transaction_temp_id := l_transaction_temp_id;
                  l_mtlt_rec.primary_quantity := l_sum_same_lot_pri_qty;
                  l_mtlt_rec.transaction_quantity := l_sum_same_lot_tra_qty;
                  IF (l_debug = 1) THEN
                          mydebug(' consolidate mtlt  55: Inserting into MTLT', l_api_name);
                          mydebug(' consolidate mtlt  55: primary_quantity = ' || l_mtlt_rec.primary_quantity, l_api_name);
                          mydebug(' consolidate mtlt  55 :transaction_quantity = ' || l_mtlt_rec.transaction_quantity, l_api_name);
                          mydebug(' consolidate mtlt  55 :serial_transaction_temp_id = ' || l_mtlt_rec.serial_transaction_temp_id, l_api_name);
                  END IF;
                  delete mtl_transaction_lots_temp
                  where transaction_temp_id = l_transaction_temp_id
                  and   lot_number = l_lot;
                  -- Insert new line into MTLT
                  inv_rcv_common_apis.insert_mtlt(l_mtlt_rec);

                  begin
                   select count(*)
                     into l_same_lot_rec_cnt
                    from  mtl_transaction_lots_temp
                    where transaction_temp_id = l_transaction_temp_id
                    and   lot_number = l_lot;
                  exception
                   when NO_DATA_FOUND  then
                        IF (l_debug = 1) THEN
                            mydebug(' consolidate mtlt 66: there is no mtlt record for mmtt', l_api_name);
                        END IF;
                        l_same_lot_rec_cnt :=0;
                   when others  then
                        IF (l_debug = 1) THEN
                            mydebug(' consolidate mtlt 77: there is an exception', l_api_name);
                        END IF;
                        l_same_lot_rec_cnt :=0;
                  end;

                  IF (l_debug = 1) THEN
                     mydebug('consolidate mtlt 66 : record count for lot number:'||l_lot||' is: '|| l_same_lot_rec_cnt, l_api_name);
                  END IF;

               end if;   -- if l_same_lot_rec_cnt > 1
             end if;  -- if l_lot <> nvl(l_old_lot, '-999');
             l_old_lot := l_lot;
         end loop;
         close c_lot_csr;

   END IF;  -- if  l_lot_control_code > 1

   --end of bug 2755138.

    IF (l_allocated_lpn_id IS NOT NULL) THEN
      IF (l_debug = 1) THEN
         mydebug('Get the allocated LPN info', l_api_name);
      END IF;

      SELECT wlpn1.license_plate_number
           , wlpn2.license_plate_number
        INTO l_allocated_lpn_name
           , l_allocated_outermost_lpn_name
        FROM wms_license_plate_numbers wlpn1, wms_license_plate_numbers wlpn2
       WHERE wlpn1.lpn_id = l_allocated_lpn_id
         AND wlpn1.outermost_lpn_id = wlpn2.lpn_id;
    END IF;

    IF (l_cartonization_id IS NOT NULL) THEN

      IF (l_debug = 1) THEN
         mydebug('Get carton information', l_api_name);
      END IF;

      -- Bug : 6682436 Start
      -- To handle the case for pick slip cartonization
      SELECT license_plate_number
        INTO l_carton_name
        FROM wms_license_plate_numbers
       WHERE lpn_id = l_cartonization_id;

      BEGIN
         SELECT l.license_plate_number lpn
              , l.inventory_item_id itemid
              , k.concatenated_segments item
           INTO l_carton_name
              , l_carton_item_id
              , l_carton_item_name
           FROM wms_license_plate_numbers l, mtl_system_items_vl k /* Bug 5581528 */
          WHERE l.lpn_id = l_cartonization_id
            AND l.inventory_item_id = k.inventory_item_id
            AND l.organization_id = k.organization_id;

      EXCEPTION
      WHEN OTHERS THEN
         NULL;
      END;
      -- Bug : 6682436 End

      IF (l_debug = 1) THEN
         mydebug('Check to see how many unloaded tasks are there for this carton', l_api_name);
      END IF;
      wms_task_dispatch_gen.check_carton(
        p_carton_id                  => l_cartonization_id
      , p_org_id                     => l_org_id
      , x_nbr_tasks                  => l_nbr_tasks
      , x_return_status              => x_return_status
      , x_msg_count                  => x_mesg_count
      , x_msg_data                   => x_error_mesg
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        x_error_code  := 3;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    -- get the cluster key for the cluster picking   ---patchset J APL cluster picking
    IF p_cartons_list is not null THEN
        IF (l_debug = 1) THEN
            mydebug('Start query the cluster key', l_api_name);
        END IF;
        l_delivery_id := null;
        IF l_transaction_action_id = 28 THEN -- SO/IO
          SELECT
                 wda.delivery_id,mtrl.carton_grouping_id
            INTO l_delivery_id,l_carton_grouping_id
            FROM
                 mtl_material_transactions_temp mmtt
               , mtl_txn_request_lines mtrl
               , wsh_delivery_details wdd
               , wsh_delivery_assignments_v wda
           WHERE mmtt.transaction_temp_id = l_transaction_temp_id
               AND mmtt.move_order_line_id = mtrl.line_id
             AND wdd.move_order_line_id  = mtrl.line_id
             AND wda.delivery_detail_id = wdd.delivery_detail_id
             AND wdd.released_status='S';
        ELSE  -- WIP picking or others
          SELECT
                 mtrl.carton_grouping_id
            INTO l_carton_grouping_id
            FROM
                 mtl_material_transactions_temp mmtt
               , mtl_txn_request_lines mtrl
           WHERE mmtt.transaction_temp_id = l_transaction_temp_id
             AND mmtt.move_order_line_id = mtrl.line_id;
        END IF;
        IF l_delivery_id is not null THEN
            l_cluster_key := l_delivery_id || 'D';
        ELSE
            l_cluster_key := l_carton_grouping_id || 'C';
        END IF;
        IF (l_debug = 1) THEN
            mydebug('Cluster key :'||l_cluster_key, l_api_name);
        END IF;
    END IF;


            --Added for Case Picking Project start
	IF p_is_manifest_pick ='Y' THEN
		l_delivery_id := null;
		l_carton_grouping_id:=null;
		IF (l_debug = 1) THEN
			mydebug('l_transaction_temp_id:'||l_transaction_temp_id, l_api_name);
		END IF;
	     IF l_transaction_action_id = 28 THEN -- SO/IO
		BEGIN
			SELECT  wda.delivery_id,mtrl.carton_grouping_id
			INTO    l_delivery_id,l_carton_grouping_id
			FROM mtl_material_transactions_temp mmtt
			, mtl_txn_request_lines mtrl
			, wsh_delivery_details wdd
			, wsh_delivery_assignments_v wda
			WHERE mmtt.transaction_temp_id = l_transaction_temp_id
			AND mmtt.move_order_line_id = mtrl.line_id
			AND wdd.move_order_line_id  = mtrl.line_id
			AND wda.delivery_detail_id = wdd.delivery_detail_id
			AND wdd.released_status='S';
		EXCEPTION
		WHEN OTHERS THEN
			IF (l_debug = 1) THEN
			   mydebug('In exception block of OTHERS', l_api_name);
		        END IF;
			SELECT mtrl.carton_grouping_id
			INTO l_carton_grouping_id
			FROM mtl_material_transactions_temp mmtt
			, mtl_txn_request_lines mtrl
			WHERE mmtt.transaction_temp_id = l_transaction_temp_id
			AND mmtt.move_order_line_id = mtrl.line_id;
		END;

		IF l_delivery_id is not null THEN
			l_cluster_key := l_delivery_id || 'D';
		ELSIF l_carton_grouping_id is not null THEN
			l_cluster_key := l_carton_grouping_id || 'C';
                ELSE
		        l_cluster_key :=NULL;
		END IF;

		IF (l_debug = 1) THEN
			mydebug('Cluster key :'||l_cluster_key, l_api_name);
			mydebug('l_delivery_id :'||l_delivery_id, l_api_name);
			mydebug('l_carton_grouping_id :'||l_carton_grouping_id, l_api_name);
		END IF;
	    END IF;
	END IF;
	--Added for Case Picking Project end


--OVPK Start 2
    IF (l_debug = 1) THEN
       mydebug('OVPK:WMSPLPDB:Checking if it is a Bulk Picked task...',l_api_name);
       mydebug('OVPK:WMSPLPDB:l_transaction_temp_id = ' || l_transaction_temp_id, l_api_name);
       mydebug('OVPK:WMSPLPDB:l_is_bulk_picked_task = '||l_is_bulk_picked_task, l_api_name);
    END IF;

    --Check if it is a bulk picked task
/*
    SELECT DECODE (parent_line_id, transaction_temp_id, 'Y', 'N')
      INTO l_is_bulk_picked_task
      FROM mtl_material_transactions_temp mmtt
     WHERE transaction_temp_id = l_transaction_temp_id;
*/

    -- If Yes then set l_check_overpick_passed to 'Y'
    IF (l_is_bulk_picked_task = 'Y') THEN
       l_check_overpick_passed := 'Y';

       IF (l_debug = 1) THEN
          mydebug('OVPK:WMSPLPDB:It IS a bulk picked task', l_api_name);
          mydebug('OVPK:WMSPLPDB:NOT calling any OVPK code', l_api_name);
          mydebug('OVPK:WMSPLPDB:l_check_overpick_passed = '||l_check_overpick_passed, l_api_name);
       END IF;

    ELSE
       -- Else make some minimal checks to allow/disallow overpicking
       IF (l_debug = 1) THEN
          mydebug('OVPK:WMSPLPDB:It is NOT a bulk picked task', l_api_name);
          mydebug('OVPK:WMSPLPDB:Need to make some minimal checks to allow/disallow overpicking', l_api_name);
          mydebug('OVPK:WMSPLPDB:l_transaction_temp_id             = ' || l_transaction_temp_id, l_api_name);
       END IF;
/*
       inv_replenish_detail_pub.check_overpick_minimal(
         p_transaction_temp_id    => l_transaction_temp_id
       , x_check_overpick_passed      => l_check_overpick_passed
       , x_return_status              => x_return_status
       , x_msg_count                  => x_mesg_count
       , x_msg_data                   => x_error_mesg
       );
*/
       --Resolve move_order_type from l_transaction_temp_id
       SELECT mtrh.move_order_type
         INTO l_move_order_type
         FROM mtl_txn_request_headers mtrh,
              mtl_txn_request_lines mtrl,
              mtl_material_transactions_temp mmtt
        WHERE mmtt.move_order_line_id = mtrl.line_id
          AND mtrl.header_id = mtrh.header_id
          AND mmtt.transaction_temp_id = l_transaction_temp_id;

         IF l_debug = 1 THEN
           mydebug('OVPK: l_org_id          = '||l_org_id, l_api_name);
           mydebug('OVPK: l_move_order_type = '||l_move_order_type, l_api_name);
         END IF;

         --If the MO is of type replenishment / requisition
         IF (l_move_order_type IN
             (inv_globals.g_move_order_replenishment,
              inv_globals.g_move_order_requisition)
            ) THEN

         SELECT OVPK_TRANSFER_ORDERS_ENABLED
           INTO l_temp
           FROM mtl_parameters
          WHERE organization_id = l_org_id;
         l_check_overpick_passed := NVL(l_temp, 'Y');

         IF l_debug = 1 THEN
            mydebug('OVPK: l_temp for replenishment/requisition MO                  = '||l_temp, l_api_name);
            mydebug('OVPK: l_check_overpick_passed for replenishment/requisition MO = '||l_check_overpick_passed, l_api_name);
         END IF;

       ELSIF (l_move_order_type = inv_globals.g_move_order_mfg_pick) THEN

        SELECT wip_overpick_enabled
           INTO l_temp
           FROM mtl_parameters
          WHERE organization_id = l_org_id;
       l_check_overpick_passed := NVL(l_temp, 'N');

         IF l_debug = 1 THEN
            mydebug('OVPK: l_temp for WIP MO                  = '||l_temp, l_api_name);
            mydebug('OVPK: l_check_overpick_passed for WIP MO = '||l_check_overpick_passed, l_api_name);
         END IF;

       ELSIF (l_move_order_type = inv_globals.g_move_order_pick_wave) THEN

         l_check_overpick_passed := NVL(fnd_profile.VALUE('WSH_OVERPICK_ENABLED'), 'N');

         IF l_debug = 1 THEN
            mydebug('OVPK: l_check_overpick_passed for PickWave MO = '||l_check_overpick_passed, l_api_name);
         END IF;

       END IF;

    END IF; -- Not Bulk Picked task


--OVPK End 2
    IF (l_debug = 1) THEN
            mydebug('get the item type for ucc128', l_api_name);
    END IF;

    BEGIN
       SELECT 'C'
       INTO l_item_type
       FROM mtl_material_transactions_temp mmtt,
            mtl_cross_references mcr
      WHERE mmtt.transaction_temp_id = l_transaction_temp_id
        AND mmtt.inventory_item_id     = mcr.inventory_item_id
        AND mcr.cross_reference_type   = g_gtin_cross_ref_type
        AND (mcr.organization_id     = mmtt.organization_id
           OR mcr.org_independent_flag = 'Y')
        AND rownum = 1;

      IF (l_debug = 1) THEN
          mydebug('After the Query for item_type :'||l_item_type,l_api_name);
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
         l_item_type := NULL;
    END;

	--Start Bug 6682436
	IF WMS_CONTROL.G_CURRENT_RELEASE_LEVEL >= 120001 THEN
		IF (l_debug = 1) THEN
			mydebug('Fetching the values of user task attributes', l_api_name);
		END IF;

		BEGIN
			SELECT  wutta.honor_case_pick_flag, pgvl.template_name into l_honor_case_pick_flag, l_template_name
			FROM mtl_material_transactions_temp mmtt, wms_user_task_type_attributes wutta , wms_page_templates_tl pgtl, WMS_PAGE_TEMPLATES_VL pgvl
			WHERE mmtt.transaction_temp_id = l_transaction_temp_id
			AND mmtt.standard_operation_id = wutta.user_task_type_id
			AND mmtt.organization_id = wutta.organization_id
			AND pgtl.template_id = wutta.pick_load_page_template_id
			AND pgtl.template_id = pgvl.template_id
			AND pgtl.language = userenv('LANG');
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			l_honor_case_pick_flag := 'N';
			l_template_name := '-999';
		END;

		IF (l_debug = 1) THEN
			mydebug('Before opening the ref cursor for WMS_CONTROL.G_CURRENT_RELEASE_LEVEL' || WMS_CONTROL.G_CURRENT_RELEASE_LEVEL, l_api_name);
			mydebug('l_honor_case_pick_flag ' || l_honor_case_pick_flag, l_api_name);
			mydebug('l_template_name ' || l_template_name, l_api_name);
		END IF;

		OPEN x_task_info FOR
		SELECT mmtt.cartonization_id
		, mmtt.container_item_id
		, mmtt.inventory_item_id
		, mmtt.lot_number
		, mmtt.revision
		, mmtt.transaction_quantity
		, mmtt.transaction_uom
		, mmtt.locator_id locator_id
		, mmtt.subinventory_code
		, inv_project.get_locsegs(mmtt.locator_id, mmtt.organization_id) loc
		-- 11
		, msik.concatenated_segments item
		, mmtt.transaction_temp_id
		, mmtt.transfer_subinventory
		, mmtt.transfer_to_location
		, NVL(msik.lot_control_code, 1) lot_code
		, NVL(msik.serial_number_control_code, 1) serial_code
		, mmtt.transaction_type_id
		, NVL(msik.restrict_subinventories_code, 2) subrest
		, NVL(msik.restrict_locators_code, 2) locrest
		, NVL(msik.location_control_code, 1) loccode
		--21
		, msik.primary_uom_code
		, NVL(msik.allowed_units_lookup_code, 2) allunits
		, NVL(revision_qty_control_code, 1) revcode
		, wdt.task_id
		, mmtt.cost_group_id
		, mmtt.transaction_header_id
		, mp.allocate_serial_flag
		, mtrl.txn_source_id
		, mmtt.wip_entity_type
		, wdt.task_type
		--31
		, mmtt.transaction_source_type_id
		, NVL(mmtt.allocated_lpn_id, 0)
		, mmtt.pick_slip_number
		, inv_project.get_project_id
		, inv_project.get_task_id
		, inv_project.get_project_number
		, inv_project.get_task_number
		, mmtt.transaction_action_id
		, wdt.device_request_id
		, l_sl_alloc_flag
		--41
		, l_serial_temp_id
		, l_allocated_lpn_name
		, l_allocated_outermost_lpn_name
		, l_carton_name
		, l_carton_item_id
		, l_carton_item_name
		, l_nbr_tasks
		, l_cluster_key cluster_key   -- patchset J APL changed cluster id to cluster key
		, mmtt.parent_line_id
		, msi.lpn_controlled_flag
		--51
		, msik.tracking_quantity_ind
		, msik.ont_pricing_qty_source
		, msik.secondary_default_ind
		, msik.secondary_uom_code
		, msik.dual_uom_deviation_high
		, msik.dual_uom_deviation_low
		, mmtt.trx_source_line_id
		, l_check_overpick_passed  --OVPK
		, Sysdate
		, mp.negative_inv_receipt_code
		--61
		, l_item_type
		, msik.description
		, inv_ui_item_lovs.get_conversion_rate(mmtt.transaction_uom,
		mmtt.organization_id,
		mmtt.inventory_item_id)
		-- Bug# 4141928
		-- For OPM convegence
		-- Fetching the sec txn qty and the additional Item attributes
		--64
		, mmtt.secondary_uom_code
		, mmtt.secondary_transaction_quantity
		, nvl(msik.lot_divisible_flag,'Y')
		/* Added for LMS project */
		, wdt.user_task_type
		, mmtt.operation_plan_id
		/* end for LMS project */

		, l_honor_case_pick_flag --69
		, l_template_name --70

		FROM wms_dispatched_tasks wdt
		, mtl_material_transactions_temp mmtt
		, mtl_system_items_vl msik /* Bug 5581528 */
		, mtl_parameters mp
		, mtl_txn_request_lines mtrl
		, mtl_secondary_inventories msi
		WHERE mmtt.transaction_temp_id = l_transaction_temp_id
		AND wdt.transaction_temp_id = mmtt.transaction_temp_id
		AND mp.organization_id = wdt.organization_id
		AND mmtt.organization_id = msik.organization_id
		AND mmtt.inventory_item_id = msik.inventory_item_id
		AND mmtt.move_order_line_id = mtrl.line_id (+)
		AND mmtt.subinventory_code = msi.secondary_inventory_name
		AND mmtt.organization_id = msi.organization_id;

		IF (l_debug = 1) THEN
			mydebug('After opening the ref cursor', l_api_name);
		END IF;
	--End Bug 6682436
	ELSE
		IF (l_debug = 1) THEN
			mydebug('Before opening the ref cursor', l_api_name);
		END IF;

		OPEN x_task_info FOR
		SELECT mmtt.cartonization_id
		, mmtt.container_item_id
		, mmtt.inventory_item_id
		, mmtt.lot_number
		, mmtt.revision
		, mmtt.transaction_quantity
		, mmtt.transaction_uom
		, mmtt.locator_id locator_id
		, mmtt.subinventory_code
		, inv_project.get_locsegs(mmtt.locator_id, mmtt.organization_id) loc
		-- 11
		, msik.concatenated_segments item
		, mmtt.transaction_temp_id
		, mmtt.transfer_subinventory
		, mmtt.transfer_to_location
		, NVL(msik.lot_control_code, 1) lot_code
		, NVL(msik.serial_number_control_code, 1) serial_code
		, mmtt.transaction_type_id
		, NVL(msik.restrict_subinventories_code, 2) subrest
		, NVL(msik.restrict_locators_code, 2) locrest
		, NVL(msik.location_control_code, 1) loccode
		--21
		, msik.primary_uom_code
		, NVL(msik.allowed_units_lookup_code, 2) allunits
		, NVL(revision_qty_control_code, 1) revcode
		, wdt.task_id
		, mmtt.cost_group_id
		, mmtt.transaction_header_id
		, mp.allocate_serial_flag
		, mtrl.txn_source_id
		, mmtt.wip_entity_type
		, wdt.task_type
		--31
		, mmtt.transaction_source_type_id
		, NVL(mmtt.allocated_lpn_id, 0)
		, mmtt.pick_slip_number
		, inv_project.get_project_id
		, inv_project.get_task_id
		, inv_project.get_project_number
		, inv_project.get_task_number
		, mmtt.transaction_action_id
		, wdt.device_request_id
		, l_sl_alloc_flag
		--41
		, l_serial_temp_id
		, l_allocated_lpn_name
		, l_allocated_outermost_lpn_name
		, l_carton_name
		, l_carton_item_id
		, l_carton_item_name
		, l_nbr_tasks
		, l_cluster_key cluster_key   -- patchset J APL changed cluster id to cluster key
		, mmtt.parent_line_id
		, msi.lpn_controlled_flag
		--51
		, msik.tracking_quantity_ind
		, msik.ont_pricing_qty_source
		, msik.secondary_default_ind
		, msik.secondary_uom_code
		, msik.dual_uom_deviation_high
		, msik.dual_uom_deviation_low
		, mmtt.trx_source_line_id
		, l_check_overpick_passed  --OVPK
		, Sysdate
		, mp.negative_inv_receipt_code
		--61
		, l_item_type
		, msik.description
		, inv_ui_item_lovs.get_conversion_rate(mmtt.transaction_uom,
		mmtt.organization_id,
		mmtt.inventory_item_id)
		-- Bug# 4141928
		-- For OPM convegence
		-- Fetching the sec txn qty and the additional Item attributes
		--64
		, mmtt.secondary_uom_code
		, mmtt.secondary_transaction_quantity
		, nvl(msik.lot_divisible_flag,'Y')
		/* Added for LMS project */
		, wdt.user_task_type
		, mmtt.operation_plan_id
		/* end for LMS project */
		FROM wms_dispatched_tasks wdt
		, mtl_material_transactions_temp mmtt
		, mtl_system_items_vl msik /* Bug 5581528 */
		, mtl_parameters mp
		, mtl_txn_request_lines mtrl
		, mtl_secondary_inventories msi
		WHERE mmtt.transaction_temp_id = l_transaction_temp_id
		AND wdt.transaction_temp_id = mmtt.transaction_temp_id
		AND mp.organization_id = wdt.organization_id
		AND mmtt.organization_id = msik.organization_id
		AND mmtt.inventory_item_id = msik.inventory_item_id
		AND mmtt.move_order_line_id = mtrl.line_id (+)
		AND mmtt.subinventory_code = msi.secondary_inventory_name
		AND mmtt.organization_id = msi.organization_id;

		IF (l_debug = 1) THEN
			mydebug('After opening the ref cursor', l_api_name);
		END IF;
  END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO next_task_inquiry;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_mesg_count, p_data => x_error_mesg);
      IF (l_debug = 1) THEN
         mydebug('Error ! SQL Code : '|| SQLCODE, l_api_name);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO next_task_inquiry;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_mesg_count, p_data => x_error_mesg);
      IF (l_debug = 1) THEN
         mydebug('Unexpected Error ! SQL Code : '|| SQLCODE, l_api_name);
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO next_task_inquiry;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg('WMS_PICKING_PKG', 'GET_NEXT_TASK_INFO');
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_mesg_count, p_data => x_error_mesg);
      IF (l_debug = 1) THEN
         mydebug('Other Error ! SQL Code : '|| SQLCODE, l_api_name);
      END IF;
  END get_next_task_info;

  --
  -- Name
  --   PROCEDURE HANDLE_BULK_PICKING
  --
  -- Purpose
  --   If the LPN has any Bulk Picked Line, then the Parent MMTT record is deleted and the
  --   Txn Header ID, Transfer LPN ID and LPN ID of the Parent MMTT record are stamped in
  --   each Child MMTT record.
  --   Added as part of Bug#2666620. Refer it for any information.
  --
  -- Input Parameters
  --   p_organization_id   => Organization ID
  --   p_transfer_lpn_id   => LPN ID
  --
  -- Output Parameters
  --   x_return_status     => FND_API.G_RET_STS_UNEXP_ERROR or
  --                          FND_API.G_RET_STS_SUCCESS

  PROCEDURE handle_bulk_picking(
    x_return_status OUT NOCOPY VARCHAR2
  , p_organization_id NUMBER
  , p_transfer_lpn_id NUMBER
  ) IS
     CURSOR c_get_bulk_txn(p_org_id IN NUMBER, p_lpn_id IN NUMBER) IS
        SELECT transaction_temp_id, transaction_header_id, lpn_id, transfer_lpn_id
          FROM mtl_material_transactions_temp t1
         WHERE transfer_lpn_id = p_lpn_id
           AND organization_id = p_org_id
           AND parent_line_id IS NULL
           AND EXISTS(
                      SELECT 1
                        FROM mtl_material_transactions_temp t2
                       WHERE t2.parent_line_id = t1.transaction_temp_id
                         AND t2.organization_id = t1.organization_id
                     );
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
     -- For each transaction returned by the cursor update the Child Records and delete the Parent.
     FOR v_rec IN c_get_bulk_txn(p_organization_id, p_transfer_lpn_id) LOOP
        -- Updating the Child Records.
        UPDATE mtl_material_transactions_temp
           SET transaction_header_id = v_rec.transaction_header_id
             , transfer_lpn_id       = v_rec.transfer_lpn_id
             , lpn_id                = v_rec.lpn_id
             , parent_line_id        = NULL
         WHERE parent_line_id        = v_rec.transaction_temp_id
           AND organization_id       = p_organization_id;

        -- Deleting the Parent Record.
        DELETE FROM mtl_material_transactions_temp
           WHERE transaction_temp_id = v_rec.transaction_temp_id;
     END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF (l_debug = 1) THEN
           mydebug('Unknown Exception occurred: ' || SQLERRM,'HANDLE_BULK_PICKING');
        END IF;
  END handle_bulk_picking;

  --
  -- Name
  --   PROCEDURE GET_TASKS
  --
  -- Purpose
  --   Gets a list of Tasks given the LPN and Organization.
  --   Changed as part of Bug#2666620. Refer it for any information.
  --
  -- Input Parameters
  --   p_organization_id   => Organization ID
  --   p_transfer_lpn_id   => LPN ID
  --
  -- Output Parameters
  --   x_tasks             => Ref Cursor containing the Tasks
  --   x_drop_type         => Either MFG or OTHERS depending on whether LPN has Mfg Picks or not
  --   x_multiple_drops    => Whether or not there are multiple drops on LPN
  --   x_drop_lpn_option   => Drop LPN Option
  --   x_return_status     => FND_API.G_RET_STS_SUCESSS or
  --                          FND_API.G_RET_STS_ERROR   or "W" (warning)

  PROCEDURE get_tasks(
    x_tasks           OUT NOCOPY    t_genref
  , x_drop_type       OUT NOCOPY    VARCHAR2
  , x_multiple_drops  OUT NOCOPY    VARCHAR2
  , x_drop_lpn_option OUT NOCOPY    NUMBER
  , x_return_status   OUT NOCOPY    VARCHAR2
  , p_organization_id IN            NUMBER
  , p_transfer_lpn_id IN            NUMBER
  ) IS

    l_api_name      VARCHAR2(30)  := 'GET_TASKS';
    l_return_status VARCHAR2(1);
    l_message       VARCHAR2(400);

    CURSOR c_det_pick_type(p_org_id IN NUMBER, p_lpn_id IN NUMBER) IS
       SELECT DECODE (mtrh.move_order_type
                     , inv_globals.g_move_order_mfg_pick, 'MFG'
                     , 'OTHERS')
         FROM mtl_material_transactions_temp  mmtt
            , mtl_txn_request_lines           mtrl
            , mtl_txn_request_headers         mtrh
        WHERE mmtt.organization_id = p_org_id
          AND mmtt.transfer_lpn_id = p_lpn_id
          AND mtrl.line_id         = mmtt.move_order_line_id
          AND mtrh.header_id       = mtrl.header_id
          AND rownum               = 1;

    CURSOR c_get_mfg_drop_details(p_org_id IN NUMBER, p_lpn_id IN NUMBER) IS
       SELECT nvl(mmtt.transfer_subinventory,0)  transfer_subinventory
            , nvl(mmtt.transfer_to_location,0)   transfer_to_location
            , mmtt.transaction_type_id
            , mtrl.txn_source_id
            , mtrl.txn_source_line_id
            , mtrl.reference_id
         FROM mtl_material_transactions_temp  mmtt
            , mtl_txn_request_lines           mtrl
        WHERE mmtt.organization_id = p_org_id
          AND mmtt.transfer_lpn_id = p_lpn_id
          AND mtrl.line_id         = mmtt.move_order_line_id;

    mfg_drop_rec       c_get_mfg_drop_details%ROWTYPE;
    mfg_orig_drop_rec  c_get_mfg_drop_details%ROWTYPE;

    b_multiple_drops   BOOLEAN := FALSE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- This API just update transfer_locator of each MMTT record for
    -- passed transfer_lpn_id.  In case it fails, MMTT will not be updated
    -- and pick drop will continue.
    wms_op_runtime_pub_apis.update_drop_locator_for_task(
      x_return_status              => l_return_status
    , x_message                    => l_message
    , x_drop_lpn_option            => x_drop_lpn_option
    , p_transfer_lpn_id            => p_transfer_lpn_id
    );

    x_return_status  := l_return_status;
    x_drop_type      := 'OTHERS';
    x_multiple_drops := 'FALSE';

    -- Determine whether the LPN has Manufacturing Picks or Other Pick Types
    OPEN c_det_pick_type(p_organization_id, p_transfer_lpn_id);
    FETCH c_det_pick_type INTO x_drop_type;
    CLOSE c_det_pick_type;

    IF x_drop_type = 'MFG' THEN
      -- Handling the case of Bulk Picked Lines in the LPN.
      handle_bulk_picking(x_return_status, p_organization_id, p_transfer_lpn_id);
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Determine if the LPN has multiple drop destinations
      OPEN c_get_mfg_drop_details(p_organization_id, p_transfer_lpn_id);
      FETCH c_get_mfg_drop_details INTO mfg_drop_rec;

      IF c_get_mfg_drop_details%FOUND THEN
        mfg_orig_drop_rec := mfg_drop_rec;
        LOOP
          FETCH c_get_mfg_drop_details INTO mfg_drop_rec;
          EXIT WHEN c_get_mfg_drop_details%NOTFOUND;

          IF ( mfg_drop_rec.transaction_type_id          = INV_Globals.G_TYPE_XFER_ORDER_WIP_ISSUE
               AND mfg_orig_drop_rec.transaction_type_id = INV_Globals.G_TYPE_XFER_ORDER_WIP_ISSUE
               AND(( mfg_drop_rec.txn_source_id          <> mfg_orig_drop_rec.txn_source_id)
                    OR ( mfg_drop_rec.txn_source_line_id <> mfg_orig_drop_rec.txn_source_line_id)
                    OR ( mfg_drop_rec.reference_id       <> mfg_orig_drop_rec.reference_id)))
          OR ( mfg_drop_rec.transaction_type_id          = INV_Globals.G_TYPE_XFER_ORDER_REPL_SUBXFR
               AND mfg_orig_drop_rec.transaction_type_id = INV_Globals.G_TYPE_XFER_ORDER_REPL_SUBXFR
               AND (( mfg_drop_rec.transfer_subinventory <> mfg_orig_drop_rec.transfer_subinventory)
                 OR ( mfg_drop_rec.transfer_to_location  <> mfg_orig_drop_rec.transfer_to_location)))
          OR ( mfg_drop_rec.transaction_type_id          <> mfg_orig_drop_rec.transaction_type_id)
          THEN
            b_multiple_drops := TRUE;
          ELSE
            mfg_orig_drop_rec := mfg_drop_rec;
          END IF;

          EXIT WHEN b_multiple_drops;
        END LOOP;
      END IF;

      CLOSE c_get_mfg_drop_details;

      IF b_multiple_drops THEN
         x_multiple_drops := 'TRUE';
      END IF;

      -- For Mfg drops, sub xfers are first followed by component issues,
      -- so drops are ordered by txn action descending order
      -- (action id of 2 = sub xfer, action id of 1 = comp issue)
      OPEN x_tasks FOR
        SELECT   mmtt.transaction_action_id
               , mmtt.transaction_temp_id
               , mmtt.inventory_item_id            item_id
               , msik.concatenated_segments        item
               , msik.revision_qty_control_code
               , msik.lot_control_code
               , msik.serial_number_control_code
               , mmtt.revision
               , mmtt.primary_quantity
               , msik.primary_uom_code
               , mmtt.transfer_subinventory                          transfer_sub
               , NVL(msi.dropping_order, 0)                          sub_dropping_order
               , NVL(msi.picking_order, 0)                           sub_picking_order
               , inv_project.get_locsegs(mmtt.transfer_to_location,
                                         mmtt.organization_id)       transfer_loc
               , NVL(mil.dropping_order, 0)                          loc_dropping_order
               , NVL(mil.picking_order, 0)                           loc_picking_order
               , mmtt.transaction_type_id
               , mmtt.wip_entity_type
               , wdt.priority
               , wdt.task_id    taskid
               , wdt.task_type
               , inv_project.get_project_id
               , inv_project.get_project_number
               , inv_project.get_task_id
               , inv_project.get_task_number
               , 0                            wip_entity_id
               , 0                            repetitive_schedule_id
               , 0                            operation_seq_num
               , mmtt.transfer_to_location  --Bug#2756609
            FROM mtl_material_transactions_temp  mmtt
               , mtl_secondary_inventories       msi
               , mtl_item_locations              mil
               , wms_dispatched_tasks            wdt
               , mtl_system_items_vl             msik /* Bug 5581528 */
           WHERE mmtt.organization_id          = p_organization_id
             AND mmtt.transfer_lpn_id          = p_transfer_lpn_id
             AND mmtt.transaction_source_type_id = inv_globals.g_sourcetype_inventory
             AND mmtt.transaction_action_id    = inv_globals.g_action_subxfr
             AND msi.organization_id           = mmtt.organization_id
             AND msi.secondary_inventory_name  = mmtt.transfer_subinventory
             AND mmtt.organization_id          = mil.organization_id
             AND mmtt.transfer_subinventory    = mil.subinventory_code
             AND mmtt.transfer_to_location     = mil.inventory_location_id
             AND wdt.organization_id           = mmtt.organization_id
             AND wdt.transaction_temp_id       = mmtt.transaction_temp_id
             AND wdt.status IN (3, 4)
             AND wdt.task_type                 = 1
             AND msik.organization_id          = mmtt.organization_id
             AND msik.inventory_item_id        = mmtt.inventory_item_id
        UNION ALL
        SELECT   mmtt.transaction_action_id
               , mmtt.transaction_temp_id
               , mmtt.inventory_item_id item_id
               , msik.concatenated_segments item
               , msik.revision_qty_control_code
               , msik.lot_control_code
               , msik.serial_number_control_code
               , mmtt.revision
               , mmtt.primary_quantity
               , msik.primary_uom_code
               , to_char(NULL)            transfer_sub
               , to_number(NULL)          sub_dropping_order
               , to_number(NULL)          sub_picking_order
               , to_char(NULL)            transfer_loc
               , to_number(NULL)          loc_dropping_order
               , to_number(NULL)          loc_picking_order
               , mmtt.transaction_type_id
               , mmtt.wip_entity_type
               , wdt.priority
               , wdt.task_id              taskid
               , wdt.task_type
               , to_char(NULL)
               , to_char(NULL)
               , to_char(NULL)
               , to_char(NULL)
               , mtrl.txn_source_id       wip_entity_id
               , mtrl.reference_id        repetitive_schedule_id
               , mtrl.txn_source_line_id  operation_seq_num
               , to_number(NULL)          transfer_to_location --Bug#2756609
            FROM mtl_material_transactions_temp  mmtt
               , mtl_txn_request_lines           mtrl
               , wms_dispatched_tasks            wdt
               , mtl_system_items_vl             msik /* Bug 5581528 */
           WHERE mmtt.organization_id          = p_organization_id
             AND mmtt.transfer_lpn_id          = p_transfer_lpn_id
             AND mmtt.transaction_source_type_id = inv_globals.g_sourcetype_wip
             AND mmtt.transaction_action_id    = inv_globals.g_action_issue
             AND mtrl.line_id                  = mmtt.move_order_line_id
             AND wdt.organization_id           = mmtt.organization_id
             AND wdt.transaction_temp_id       = mmtt.transaction_temp_id
             AND wdt.status IN (3, 4)
             AND wdt.task_type                 = 1
             AND msik.organization_id          = mmtt.organization_id
             AND msik.inventory_item_id        = mmtt.inventory_item_id
        ORDER BY transaction_action_id DESC
               , sub_dropping_order
               , sub_picking_order
               , transfer_sub
               , loc_dropping_order
               , loc_picking_order
               , transfer_loc
               , wip_entity_id
               , repetitive_schedule_id
               , operation_seq_num
               , item_id
               , revision
               , priority
               , taskid;
    ELSE
      x_drop_type := 'OTHERS';
      OPEN x_tasks FOR
        SELECT   mmtt.inventory_item_id
               , mmtt.lot_number
               , mmtt.revision
               , mmtt.transaction_quantity
               , mmtt.transaction_uom
               , mmtt.locator_id
               , mmtt.subinventory_code
               , nvl(inv_project.get_locsegs(mmtt.transfer_to_location, mmtt.organization_id),'') loc
               , msik.concatenated_segments item
               , mmtt.transaction_temp_id
               , mmtt.transfer_subinventory
               , mmtt.transfer_to_location
               , mmtt.transaction_type_id
               , mmtt.wip_entity_type
               , mmtt.transaction_source_type_id
               , wdt.priority priority
               , wdt.task_id taskid
               , wdt.task_type task_type
               , inv_project.get_project_id
               , inv_project.get_project_number
               , inv_project.get_task_id
               , inv_project.get_task_number
            FROM wms_dispatched_tasks wdt, mtl_material_transactions_temp mmtt, mtl_system_items_vl msik /* Bug 5581528 */
           WHERE wdt.organization_id = p_organization_id
             AND wdt.status IN (3, 4)
             AND wdt.task_type IN (1, 4, 5, 7)
             AND wdt.transaction_temp_id = mmtt.transaction_temp_id
             AND mmtt.transfer_lpn_id    = p_transfer_lpn_id
             AND mmtt.organization_id    = msik.organization_id
             AND mmtt.inventory_item_id  = msik.inventory_item_id
        ORDER BY subinventory_code, loc, priority, taskid;
    END IF; -- x_drop_type = 'MFG'

  EXCEPTION
     WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
     WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_error;
        IF (l_debug = 1) THEN
           mydebug('Unknown exception occurred: ' || SQLERRM, l_api_name);
        END IF;
  END get_tasks;

  --
  -- Name
  --   PROCEDURE GET_LOT_NUMBER_INFO
  --
  -- Purpose
  --   Gets the list of all Lots and its Quantity for the passed in list of Transaction Temp IDs.
  --   Added as part of Bug#2666620. Refer it for any information.
  --
  -- Input Parameters
  --   p_txn_temp_id_list  => Comma delimited Transaction Temp ID List
  --
  -- Output Parameters
  --   x_return_status     => FND_API.G_RET_STS_SUCESSS or
  --                          FND_API.G_RET_STS_ERROR
  --   x_lot_num_list      => Comma delimited Lot Number List
  --   x_lot_qty_list      => Comma delimited Lot Qty List
  --   x_display_serials   => Whether Serials are associated with the Txn Temp ID list.

  PROCEDURE get_lot_number_info(
    x_return_status    OUT NOCOPY    VARCHAR2
  , x_lot_num_list     OUT NOCOPY    VARCHAR2
  , x_lot_qty_list     OUT NOCOPY    VARCHAR2
  , x_display_serials  OUT NOCOPY    VARCHAR2
  , p_txn_temp_id_list IN            VARCHAR2
  ) IS
    l_api_name          VARCHAR2(30)                 := 'GET_LOT_NUMBER_INFO';
    l_temp_lot_num_tbl  inv_globals.varchar_tbl_type;
    l_temp_lot_qty_tbl  inv_globals.number_tbl_type;
    l_lot_num_tbl       inv_globals.varchar_tbl_type;
    l_lot_qty_tbl       inv_globals.number_tbl_type;
    l_start             NUMBER;
    l_end               NUMBER;
    l_txn_temp_id       NUMBER;
    l_found             BOOLEAN;

    CURSOR c_lot_list(p_txn_temp_id IN NUMBER) IS
      SELECT lot_number, SUM(primary_quantity)
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_txn_temp_id
       GROUP BY lot_number;

    CURSOR c_display_serials(p_txn_temp_id IN NUMBER) IS
      SELECT DECODE(COUNT(serial_transaction_temp_id), 0, 'N', 'Y')
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_txn_temp_id;
   BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF (g_trace_on = 1) THEN
       mydebug('Txn Temp ID List = '||p_txn_temp_id_list, l_api_name);
    END IF;

    l_start := 1;
    LOOP
       l_end := INSTR(p_txn_temp_id_list,',',l_start);
       IF l_end = 0 THEN
          l_end := LENGTH(p_txn_temp_id_list) + 1;
       END IF;
       -- Get the next Transaction Temp ID.
       l_txn_temp_id := TO_NUMBER(SUBSTR(p_txn_temp_id_list, l_start, l_end - l_start));

       -- For each Transaction Temp ID fetch the lots associated with it.
       OPEN c_lot_list(l_txn_temp_id);
       FETCH c_lot_list BULK COLLECT INTO l_temp_lot_num_tbl, l_temp_lot_qty_tbl;
       CLOSE c_lot_list;

       IF l_temp_lot_num_tbl.COUNT > 0 THEN
          -- If the Lot Number already Exists, then add the Quantity. Otherwise create a new record.
          FOR j IN l_temp_lot_num_tbl.FIRST .. l_temp_lot_num_tbl.LAST LOOP
            IF l_lot_num_tbl.COUNT = 0 THEN
               l_lot_num_tbl(1) := l_temp_lot_num_tbl(j);
               l_lot_qty_tbl(1) := l_temp_lot_qty_tbl(j);
            ELSE
               l_found := FALSE;
               FOR k IN l_lot_num_tbl.FIRST..l_lot_num_tbl.LAST LOOP
                  IF l_lot_num_tbl(k) = l_temp_lot_num_tbl(j) THEN
                     l_lot_qty_tbl(k) := l_lot_qty_tbl(k) + l_temp_lot_qty_tbl(j);
                     l_found          := TRUE;
                     EXIT;
                  END IF;
               END LOOP;
               IF l_found = FALSE THEN
                  l_lot_num_tbl(l_lot_num_tbl.COUNT + 1) := l_temp_lot_num_tbl(j);
                  l_lot_qty_tbl(l_lot_qty_tbl.COUNT + 1) := l_temp_lot_qty_tbl(j);
               END IF;
            END IF;
          END LOOP;
       END IF;

       EXIT WHEN l_end = LENGTH(p_txn_temp_id_list) + 1;
       l_start := l_end + 1;
    END LOOP;

    -- Converting the PLSQL records into a comma separated String.
    IF l_lot_num_tbl.COUNT > 0 THEN
       x_lot_num_list := l_lot_num_tbl(1);
       x_lot_qty_list := l_lot_qty_tbl(1);
       FOR i IN 2..l_lot_num_tbl.LAST LOOP
          x_lot_num_list := x_lot_num_list || ',' || l_lot_num_tbl(i);
          x_lot_qty_list := x_lot_qty_list || ',' || l_lot_qty_tbl(i);
       END LOOP;
    ELSE
       IF (g_trace_on = 1) THEN
          mydebug('No Lots retrieved for the current Query Criteria', l_api_name);
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
    END IF;

    -- Determine whether the Item is Serial Controlled or not.
    OPEN c_display_serials(l_txn_temp_id);
    FETCH c_display_serials INTO x_display_serials;
    CLOSE c_display_serials;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_lot_list%ISOPEN THEN
         CLOSE c_lot_list;
      END IF;
      IF c_display_serials%ISOPEN THEN
         CLOSE c_display_serials;
      END IF;
      IF (g_trace_on = 1) THEN
         mydebug('Exception while getting the Lots: ' || SQLERRM, l_api_name);
      END IF;
      x_return_status  := fnd_api.g_ret_sts_error;
  END get_lot_number_info;

  --
  -- Name
  --   PROCEDURE GET_SERIAL_NUMBERS
  --
  -- Purpose
  --   Gets the list of all Serials for the passed in list of Transaction Temp IDs. If Lot is given
  --   the list contains Serials belonging to that Lot alone.
  --   Added as part of Bug#2666620. Refer it for any information.
  --
  -- Input Parameters
  --   p_txn_temp_id_list  => Comma delimited Transaction Temp ID List
  --   p_lot_number        => Lot Number
  --
  -- Output Parameters
  --   x_return_status     => FND_API.G_RET_STS_SUCESSS or
  --                          FND_API.G_RET_STS_ERROR
  --   x_serial_list       => Comma delimited Serial List.

  PROCEDURE get_serial_numbers(
    x_return_status    OUT NOCOPY    VARCHAR2
  , x_serial_list      OUT NOCOPY    VARCHAR2
  , p_txn_temp_id_list IN            VARCHAR2
  , p_lot_number       IN            VARCHAR2
  ) IS
    l_api_name VARCHAR2(30) := 'GET_SERIAL_NUMBERS';
    l_temp_serial_list  inv_globals.varchar_tbl_type;
    l_start             NUMBER;
    l_end               NUMBER;
    l_txn_temp_id       NUMBER;

    CURSOR c_serial_list(p_txn_temp_id IN NUMBER, p_lot_num IN VARCHAR2) IS
      SELECT msnt.fm_serial_number
        FROM mtl_transaction_lots_temp mtlt, mtl_serial_numbers_temp msnt
       WHERE p_lot_num IS NOT NULL
         AND mtlt.transaction_temp_id = p_txn_temp_id
         AND mtlt.lot_number = p_lot_num
         AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
      UNION ALL
      SELECT msnt.fm_serial_number
        FROM mtl_serial_numbers_temp msnt
       WHERE p_lot_num IS NULL
         AND msnt.transaction_temp_id = p_txn_temp_id
      ORDER BY 1;
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF (g_trace_on = 1) THEN
       mydebug('Txn Temp ID List = '||p_txn_temp_id_list||' : Lot Number = '||p_lot_number, l_api_name);
    END IF;

    l_start := 1;
    LOOP
       l_end := INSTR(p_txn_temp_id_list,',',l_start);
       IF l_end = 0 THEN
          l_end := LENGTH(p_txn_temp_id_list) + 1;
       END IF;
       -- Get the next Transaction Temp ID.
       l_txn_temp_id := TO_NUMBER(SUBSTR(p_txn_temp_id_list, l_start, l_end - l_start));

       -- Fetch the Serials associated with the Transaction Temp ID and Lot Number (If Lot Ctrl).
       OPEN c_serial_list(l_txn_temp_id,p_lot_number);
       FETCH c_serial_list BULK COLLECT INTO l_temp_serial_list;
       CLOSE c_serial_list;

       -- Converting the PLSQL records into a comma separated String
       IF l_temp_serial_list.COUNT > 0 THEN
          IF x_serial_list IS NULL THEN
             x_serial_list := l_temp_serial_list(1);
          ELSE
             x_serial_list := x_serial_list || ',' || l_temp_serial_list(1);
          END IF;
          FOR ii IN 2..l_temp_serial_list.LAST LOOP
             x_serial_list := x_serial_list || ',' || l_temp_serial_list(ii);
          END LOOP;
       END IF;
       l_start := l_end + 1;
       EXIT WHEN l_end = LENGTH(p_txn_temp_id_list) + 1;
    END LOOP;

    IF x_serial_list IS NULL THEN
       IF (g_trace_on = 1) THEN
          mydebug('No Serials retrieved for the given Query Criteria',l_api_name);
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_serial_list%ISOPEN THEN
        CLOSE c_serial_list;
      END IF;
      IF (g_trace_on = 1) THEN
         mydebug('Exception on getting the Serials : '|| SQLERRM, l_api_name);
      END IF;
      x_return_status  := fnd_api.g_ret_sts_error;
  END get_serial_numbers;

  PROCEDURE manual_pick
    (p_employee_id           IN          NUMBER,
     p_effective_start_date  IN          DATE,
     p_effective_end_date    IN          DATE,
     p_organization_id       IN          NUMBER,
     p_subinventory_code     IN          VARCHAR2,
     p_equipment_id          IN          NUMBER,
     p_equipment_serial      IN          VARCHAR2,
     p_transaction_temp_id   IN          NUMBER,
     p_allow_unreleased_task    IN VARCHAR2     :='Y', -- for manual picking only bug 4718145
     x_task_type_id          OUT NOCOPY  NUMBER,
     x_return_status         OUT NOCOPY  VARCHAR2,
     x_msg_count             OUT NOCOPY  NUMBER,
     x_msg_data              OUT NOCOPY  VARCHAR2) IS

    l_person_resource_id         NUMBER;
    l_machine_resource_id        NUMBER;
    l_standard_operation_id      NUMBER;
    l_operation_plan_id          NUMBER;
    l_move_order_line_id         NUMBER;
    l_user_id                    NUMBER;
    l_mmtt_rowcnt        NUMBER;
    l_wdt_rowcnt         NUMBER;
    l_undispatched_picks NUMBER;
    l_equipment_serial         WMS_DISPATCHED_TASKS.EQUIPMENT_INSTANCE%TYPE;
    l_debug              NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_status             NUMBER ;  --Bug#5157839.

    /*6009436 Begin */
    CURSOR c_fm_to_serial_number IS
        SELECT
          msnt.fm_serial_number,
          msnt.to_serial_number
          FROM  mtl_serial_numbers_temp msnt
          WHERE msnt.transaction_temp_id = p_transaction_temp_id;

     CURSOR c_fm_to_lot_serial_number IS
        SELECT
          msnt.fm_serial_number,
          msnt.to_serial_number
          FROM
          mtl_serial_numbers_temp msnt,
          mtl_transaction_lots_temp mtlt
          WHERE mtlt.transaction_temp_id = p_transaction_temp_id
          AND   msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;

    l_item_id            NUMBER := NULL;
    l_serial_ctrl_code   NUMBER;
    l_lot_ctrl_code      NUMBER ;
    l_fm_serial_number   MTL_SERIAL_NUMBERS_TEMP.FM_SERIAL_NUMBER%TYPE;
    l_to_serial_number   MTL_SERIAL_NUMBERS_TEMP.TO_SERIAL_NUMBER%TYPE;
    l_txn_hdr_id         NUMBER;
   /*6009436 End */

  BEGIN

     IF (l_debug = 1) THEN
        mydebug('MANUAL_PICK: In Manual Pick API', 'MANUAL_PICK');
        mydebug('p_allow_unreleased_task is : ' || p_allow_unreleased_task, 'MANUAL_PICK');
     END IF;

     -- Bug #4090630 - inserting NULL into WMS_DISPATCHED_TASKS.equipement_instance
     -- if p_equipment_serial is NONE
     l_equipment_serial := p_equipment_serial;
     IF (p_equipment_serial = 'NONE') then
   	IF (l_debug = 1) THEN
   		mydebug('l_equipment_serial is null', 'MANUAL_PICK');
   	END IF;
  		l_equipment_serial := NULL;
     END IF;

     x_return_status  := fnd_api.g_ret_sts_success;

     l_mmtt_rowcnt    := 0;
     l_wdt_rowcnt     := 0;


     -- Restricting the user not to load the child task
     -- that are merged using bulk pick. Added the condition parent_line_id
     -- not null for the same.
     BEGIN
        IF nvl(p_allow_unreleased_task,'Y') = 'Y' THEN
          SELECT 1
            INTO l_mmtt_rowcnt
            FROM dual
            WHERE exists (SELECT 1
                          FROM mtl_material_transactions_temp
                          WHERE transaction_temp_id = p_transaction_temp_id
                          AND organization_id = p_organization_id
                          AND (parent_line_id is NULL  -- regular task
                               OR parent_line_id = transaction_temp_id)); -- bulk task
        ELSE
          SELECT 1
            INTO l_mmtt_rowcnt
            FROM dual
            WHERE exists (SELECT 1
                          FROM mtl_material_transactions_temp
                          WHERE transaction_temp_id = p_transaction_temp_id
                          AND organization_id = p_organization_id
                          AND wms_task_status <>  8  -- unreleased
                          AND (
                               parent_line_id is NULL  -- regular task
                               OR parent_line_id = transaction_temp_id)); -- bulk task

        END IF;
    EXCEPTION
        WHEN no_data_found THEN
           IF (l_debug = 1) THEN
              mydebug('MANUAL_PICK: No mmtt rows found for pick slip' || p_transaction_temp_id, 'MANUAL_PICK');
           END IF;

           l_mmtt_rowcnt  := 0;
           fnd_message.set_name('WMS', 'WMS_INVALID_PICKID');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
     END;

     IF (l_debug = 1) THEN
        mydebug('MANUAL_PICK: MMTT record is available', 'MANUAL_PICK');
     END IF;

    IF l_mmtt_rowcnt > 0 THEN
      -- Check if this line has been sent to somebody else

      BEGIN
         SELECT 1
           INTO l_wdt_rowcnt
           FROM dual
           WHERE exists (SELECT 1
                         FROM wms_dispatched_tasks t
                         WHERE t.transaction_temp_id = p_transaction_temp_id
                         AND person_id <> p_employee_id);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_wdt_rowcnt  := 0;
      END;

      IF l_wdt_rowcnt > 0 THEN
         IF (l_debug = 1) THEN
            mydebug('MANUAL_PICK: Task has been assigned to somebody else', 'MANUAL_PICK');
         END IF;

         fnd_message.set_name('WMS', 'WMS_TASK_UNAVAIL');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      ELSE
       BEGIN   --bug#5157839.Start fix
            SELECT wdt.status  INTO l_status FROM wms_dispatched_tasks wdt
            WHERE wdt.transaction_temp_id = p_transaction_temp_id;

            IF l_status NOT  IN (1,2,3) THEN
               IF (l_debug = 1) THEN
                  mydebug('MANUAL_PICK: The WDT has status other than 1 or 2 ', 'MANUAL_PICK');
               END IF;
               fnd_message.set_name('WMS', 'WMS_INVALID_PICKID');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            END IF;
         EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
               mydebug('MANUAL_PICK: The WDT is not present', 'MANUAL_PICK');
            END IF;
         END;  --bug#5157839.End of fix

         IF (l_debug = 1) THEN
            mydebug('MANUAL_PICK: WDT record is available', 'MANUAL_PICK');
         END IF;

         -- Update MMTT record with a new header
         l_user_id := fnd_global.user_id;

         SELECT mtl_material_transactions_s.NEXTVAL txnhdrid
          INTO l_txn_hdr_id
         FROM DUAL;

         UPDATE mtl_material_transactions_temp
           SET transaction_header_id = l_txn_hdr_id ,
               last_update_date      = Sysdate,
               last_updated_by       = l_user_id,
               creation_date         = Sysdate,
               created_by            = l_user_id
             , posting_flag = 'Y' -- Bug4185621: this will change the parent posting flag to 'Y' for bulking picking
                                  -- If not bulking picking, this has not effect
           WHERE transaction_temp_id = p_transaction_temp_id
           returning wms_task_type INTO x_task_type_id;




         BEGIN
            SELECT 1
              INTO l_wdt_rowcnt
              FROM dual
              WHERE exists (SELECT 1
                            FROM wms_dispatched_tasks t
                            WHERE t.transaction_temp_id = p_transaction_temp_id);

            g_previous_task_status(p_transaction_temp_id) := 2;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_wdt_rowcnt  := 0;
               g_previous_task_status(p_transaction_temp_id) := 1;
         END;

         IF l_wdt_rowcnt = 0 THEN
            BEGIN
               SELECT bremp.resource_id role_id,
                      t.wms_task_type,
                      t.standard_operation_id,
                      t.operation_plan_id,
                      t.move_order_line_id,
                      t.inventory_item_id
                 INTO l_person_resource_id,
                      x_task_type_id,
                      l_standard_operation_id,
                      l_operation_plan_id,
                      l_move_order_line_id,
                      l_item_id
                 FROM mtl_material_transactions_temp t, bom_std_op_resources bsor, bom_resources bremp
                 WHERE t.transaction_temp_id = p_transaction_temp_id
                 AND t.standard_operation_id = bsor.standard_operation_id
                 AND bsor.resource_id = bremp.resource_id
                 AND bremp.resource_type = 2
                 AND ROWNUM < 2;

               IF (l_debug = 1) THEN
                  mydebug('MANUAL_PICK: After getting Resource ID....', 'MANUAL_PICK');
               END IF;

            EXCEPTION
               WHEN no_data_found THEN
                  IF (l_debug = 1) THEN
                     mydebug('MANUAL_PICK: No Person Resource ID found', 'MANUAL_PICK');
                  END IF;

                  RAISE fnd_api.g_exc_error;
            END;

            IF p_equipment_id IS NOT NULL AND
               p_equipment_id <> -999 THEN
               BEGIN
                  -- bug fix 1772907, lezhang

                  SELECT resource_id
                    INTO l_machine_resource_id
                    FROM bom_resource_equipments
                    WHERE inventory_item_id = p_equipment_id
                    AND ROWNUM < 2;
               EXCEPTION
                  WHEN no_data_found THEN
                     IF (l_debug = 1) THEN
                        mydebug('MANUAL_PICK: No Machine Resource ID found', 'MANUAL_PICK');
                     END IF;

                     RAISE fnd_api.g_exc_error;
               END;
            END IF;

       --Bug6009436.Begin
	SELECT msi.serial_number_control_code
             , msi.lot_control_code
          INTO l_serial_ctrl_code
             , l_lot_ctrl_code
         FROM mtl_system_items msi
	 WHERE msi.inventory_item_id = l_item_id
         AND msi.organization_id =p_organization_id ;

	  IF (l_debug = 1) THEN
               mydebug('manual_pick:serial control code:'||l_serial_ctrl_code || ',lot control code :'||l_lot_ctrl_code,'MANUAL_PICK');
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
	        WHERE msn.current_organization_id=p_organization_id
	        AND msn.inventory_item_id= l_item_id
	        AND msn.SERIAL_NUMBER BETWEEN l_fm_serial_number AND
	 	                                l_to_serial_number;
	     END LOOP;
	     CLOSE c_fm_to_lot_serial_number;

	     UPDATE mtl_serial_numbers_temp
	     SET group_header_id= l_txn_hdr_id
	     WHERE transaction_temp_id in ( SELECT serial_transaction_temp_id
	                                   FROM mtl_transaction_lots_temp
					   WHERE transaction_temp_id= p_transaction_temp_id );
           ELSE                            --Non-Lot item

  	     OPEN c_fm_to_serial_number;
             LOOP
                FETCH c_fm_to_serial_number
                INTO l_fm_serial_number,l_to_serial_number;
                EXIT WHEN c_fm_to_serial_number%NOTFOUND;

                UPDATE MTL_SERIAL_NUMBERS msn
                SET  GROUP_MARK_ID=l_txn_hdr_id
	        WHERE msn.current_organization_id=p_organization_id
	        AND msn.inventory_item_id= l_item_id
	        AND msn.SERIAL_NUMBER BETWEEN l_fm_serial_number AND
		                                l_to_serial_number;
	     END LOOP;
	     CLOSE c_fm_to_serial_number;

	     UPDATE mtl_serial_numbers_temp
	     SET group_header_id= l_txn_hdr_id
             WHERE transaction_temp_id=p_transaction_temp_id ;

         END IF;

      IF (l_debug = 1) THEN
              mydebug('manual_pick: Updated MSNT', 'MANUAL_PICK');
      END IF;

      EXCEPTION
         WHEN OTHERS THEN
           IF (l_debug = 1) THEN
               mydebug('manual_pick:EXCEPTION!!! while updating MSNT', 'MANUAL_PICK');
           END IF;
	   raise fnd_api.g_exc_error;
      END ;
    END IF;
    --Bug6009436.End

            -- Insert into WMS_DISPATCHED_TASKS for this user
            INSERT INTO wms_dispatched_tasks
              (task_id,
               transaction_temp_id,
               organization_id,
               user_task_type,
               person_id,
               effective_start_date,
               effective_end_date,
               equipment_id,
               equipment_instance,
               person_resource_id,
               machine_resource_id,
               status,
               dispatched_time,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               task_type,
               operation_plan_id,
               move_order_line_id)
              VALUES
              (wms_dispatched_tasks_s.NEXTVAL,
               p_transaction_temp_id,
               p_organization_id,
               l_standard_operation_id,
               p_employee_id,
               p_effective_start_date,
               p_effective_end_date,
               p_equipment_id,
               l_equipment_serial,
               l_person_resource_id,
               l_machine_resource_id,
               3, -- Dispatched
               SYSDATE,
               SYSDATE,
               l_user_id,
               SYSDATE,
               l_user_id,
               x_task_type_id,
               l_operation_plan_id,
               l_move_order_line_id);

            IF (l_debug = 1) THEN
               mydebug('MANUAL_PICK: After Insert into WDT', 'MANUAL_PICK');
            END IF;
         END IF;
      END IF;
    END IF; --mmtt rowcount if

    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END manual_pick;


  PROCEDURE get_next_task_in_group
    (p_employee_id              IN NUMBER,
     p_organization_id          IN NUMBER,
     p_subinventory_code        IN VARCHAR2,
     p_device_id                IN NUMBER,
     p_grouping_document_type   IN VARCHAR2,
     p_grouping_document_number IN NUMBER,
     p_grouping_source_type_id  IN NUMBER,
     x_task_id                  OUT nocopy NUMBER,
     x_transaction_temp_id      OUT nocopy NUMBER,
     x_task_type_id             OUT nocopy NUMBER,
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_data                 OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER)
    IS
  BEGIN
     IF (g_trace_on = 1) THEN
        mydebug('Inside get_next_task_in_group', 'GET_NEXT_TASK_IN_GROUP');
        mydebug('Device ID: ' || p_device_id, 'GET_NEXT_TASK_IN_GROUP');
        mydebug('Grouping Document Type: ' || p_grouping_document_type, 'GET_NEXT_TASK_IN_GROUP');
        mydebug('Grouping Document Number: ' || p_grouping_document_number, 'GET_NEXT_TASK_IN_GROUP');
        mydebug('Grouping Source Type ID: ' || p_grouping_source_type_id, 'GET_NEXT_TASK_IN_GROUP');
     END IF;

     BEGIN
        g_group_sequence_number := g_group_sequence_number + 1;

        IF (g_trace_on = 1) THEN
           mydebug('Looking for task with Group Sequence Number: ' || g_group_sequence_number, 'GET_NEXT_TASK_IN_GROUP');
        END IF;

        IF p_grouping_document_type = 'PICK_SLIP' THEN

           SELECT wdt.task_id, mmtt.transaction_temp_id, wdt.task_type
             INTO x_task_id, x_transaction_temp_id, x_task_type_id
             FROM wms_dispatched_tasks wdt,
                  mtl_material_transactions_temp mmtt
             WHERE wdt.person_id = p_employee_id
             AND wdt.organization_id = p_organization_id
             AND wdt.task_type in (1,4) -- Picking,Replenishment bug#8770642
	     AND wdt.status = 3
             AND Nvl(wdt.device_id, -1) = Nvl(p_device_id, -1)
             AND Decode(wdt.device_id, NULL, 'Y', wdt.device_invoked) = 'Y'
             AND wdt.transaction_temp_id = mmtt.transaction_temp_id
             AND Decode(p_subinventory_code, NULL, mmtt.subinventory_code, p_subinventory_code) = mmtt.subinventory_code
             AND mmtt.pick_slip_number = p_grouping_document_number
             AND wdt.task_group_id = g_group_sequence_number;

         ELSIF p_grouping_document_type = 'ORDER' THEN

           SELECT wdt.task_id, mmtt.transaction_temp_id, wdt.task_type
             INTO x_task_id, x_transaction_temp_id, x_task_type_id
             FROM wms_dispatched_tasks wdt,
                  mtl_material_transactions_temp mmtt
             WHERE wdt.person_id = p_employee_id
             AND wdt.organization_id = p_organization_id
             AND wdt.task_type = 1 -- Picking
             AND wdt.status = 3
             AND Nvl(wdt.device_id, -1) = Nvl(p_device_id, -1)
             AND Decode(wdt.device_id, NULL, 'Y', wdt.device_invoked) = 'Y'
             AND wdt.transaction_temp_id = mmtt.transaction_temp_id
             AND Decode(p_subinventory_code, NULL, mmtt.subinventory_code, p_subinventory_code) = mmtt.subinventory_code
             AND mmtt.transaction_source_type_id = p_grouping_source_type_id
             AND mmtt.transaction_source_id = p_grouping_document_number
             AND wdt.task_group_id = g_group_sequence_number;

         ELSIF p_grouping_document_type = 'CARTON'  THEN

           SELECT wdt.task_id, mmtt.transaction_temp_id, wdt.task_type
             INTO x_task_id, x_transaction_temp_id, x_task_type_id
             FROM wms_dispatched_tasks wdt,
                  mtl_material_transactions_temp mmtt
             WHERE wdt.person_id = p_employee_id
             AND wdt.organization_id = p_organization_id
             AND wdt.task_type = 1 -- Picking
             AND wdt.status = 3
             AND Nvl(wdt.device_id, -1) = Nvl(p_device_id, -1)
             AND Decode(wdt.device_id, NULL, 'Y', wdt.device_invoked) = 'Y'
             AND wdt.transaction_temp_id = mmtt.transaction_temp_id
             AND Decode(p_subinventory_code, NULL, mmtt.subinventory_code, p_subinventory_code) = mmtt.subinventory_code
             AND mmtt.cartonization_id = p_grouping_document_number
             AND wdt.task_group_id = g_group_sequence_number;
        --Bug: 7254397 added for ClusterPickByLabel
        ELSIF p_grouping_document_type = 'CLUSTERPICKBYLABEL'  THEN

           SELECT wdt.task_id, mmtt.transaction_temp_id, wdt.task_type
             INTO x_task_id, x_transaction_temp_id, x_task_type_id
             FROM wms_dispatched_tasks wdt,
                  mtl_material_transactions_temp mmtt
             WHERE wdt.person_id = p_employee_id
             AND wdt.organization_id = p_organization_id
             AND wdt.task_type = 1 -- Picking
             AND wdt.status = 3
             AND Nvl(wdt.device_id, -1) = Nvl(p_device_id, -1)
             AND Decode(wdt.device_id, NULL, 'Y', wdt.device_invoked) = 'Y'
             AND wdt.transaction_temp_id = mmtt.transaction_temp_id
             AND Decode(p_subinventory_code, NULL, mmtt.subinventory_code, p_subinventory_code) = mmtt.subinventory_code
             --AND mmtt.cartonization_id = p_grouping_document_number
             AND mmtt.cartonization_id IN (SELECT * FROM TABLE(list_cartonization_id))
             AND wdt.task_group_id = g_group_sequence_number;
         ELSIF p_grouping_document_type = 'CLUSTER' THEN    -- for cluster picking

           SELECT task_id, transaction_temp_id, task_type
             INTO x_task_id, x_transaction_temp_id, x_task_type_id
             FROM (select wdt.task_id, mmtt.transaction_temp_id, wdt.task_type
                     FROM wms_dispatched_tasks wdt,
                          mtl_material_transactions_temp mmtt,
                          mtl_secondary_inventories msi,
                          mtl_item_locations mil
                     WHERE wdt.person_id = p_employee_id
                       AND wdt.organization_id = p_organization_id
                       AND wdt.task_type = 1 -- Picking
                       AND wdt.status = 3
                       AND wdt.transaction_temp_id = mmtt.transaction_temp_id
                       AND Decode(p_subinventory_code, NULL, mmtt.subinventory_code,
                        p_subinventory_code) = mmtt.subinventory_code
                       AND mmtt.subinventory_code = msi.secondary_inventory_name
                       AND mmtt.organization_id = msi.organization_id
                       AND mmtt.locator_id = mil.inventory_location_id
                       AND mmtt.organization_id = mil.organization_id
                       AND wdt.task_method = 'CLUSTER'
                   ORDER BY msi.picking_order, mil.picking_order, wdt.priority, wdt.status, wdt.task_id
                  )
            WHERE rownum <2;
	 --Added for Case Picking Project start
	 ELSIF ( p_grouping_document_type = 'MANIFESTORDER' ) THEN

	        IF (g_trace_on = 1) THEN
			mydebug('MANIFESTORDER ' || g_group_sequence_number, 'GET_NEXT_TASK_IN_GROUP');
		END IF;

		SELECT     task_id            ,
			   transaction_temp_id,
			   task_type
		INTO       x_task_id            ,
			   x_transaction_temp_id,
			   x_task_type_id
		FROM (
			SELECT     wdt.task_id             ,
				   mmtt.transaction_temp_id,
				   wdt.task_type
			FROM       wms_dispatched_tasks wdt           ,
				   mtl_material_transactions_temp mmtt,
				   mtl_secondary_inventories msi      ,
				   mtl_item_locations mil
			WHERE  wdt.person_id                                                                 = p_employee_id
			   AND wdt.organization_id                                                           = p_organization_id
			   AND wdt.task_type                                                                 = 1 -- Picking
			   AND wdt.status                                                                    = 3
			   AND NVL(wdt.device_id, -1)                                                        = NVL(p_device_id, -1)
			   AND DECODE(wdt.device_id, NULL, 'Y', wdt.device_invoked)                          ='Y'
			   AND wdt.transaction_temp_id                                                       = mmtt.transaction_temp_id
			   AND DECODE(p_subinventory_code, NULL, mmtt.subinventory_code,p_subinventory_code) = mmtt.subinventory_code
			   AND mmtt.subinventory_code                                                        = msi.secondary_inventory_name
			   AND mmtt.organization_id                                                          = msi.organization_id
			   AND mmtt.locator_id                                                               = mil.inventory_location_id
			   AND mmtt.organization_id                                                          = mil.organization_id
			   AND wdt.task_method                                                               = 'MANIFESTORDER'
			   AND mmtt.transaction_source_type_id                                               = p_grouping_source_type_id
			   AND mmtt.transaction_source_id IN  ( SELECT  *  FROM    TABLE(list_order_numbers)   )
			   AND wdt.task_group_id = g_group_sequence_number
			   AND mmtt.parent_line_id IS NULL  -- Added for bulk task
			ORDER BY msi.picking_order, mil.picking_order, wdt.priority , wdt.status , wdt.task_id
		      )
		WHERE  rownum <2;

		IF (g_trace_on = 1) THEN
			mydebug('MANIFESTORDER x_task_id' || x_task_id, 'GET_NEXT_TASK_IN_GROUP');
			mydebug('MANIFESTORDER x_transaction_temp_id' || x_transaction_temp_id, 'GET_NEXT_TASK_IN_GROUP');
			mydebug('MANIFESTORDER x_task_type_id' || x_task_type_id, 'GET_NEXT_TASK_IN_GROUP');
		END IF;

	ELSIF ( p_grouping_document_type = 'MANIFESTPICKSLIP' ) THEN

		IF (g_trace_on = 1) THEN
			mydebug('Looking for task with Group Sequence Number: ' || g_group_sequence_number, 'GET_NEXT_TASK_IN_GROUP');
		END IF;

		SELECT     task_id            ,
			   transaction_temp_id,
			   task_type
		INTO       x_task_id            ,
			   x_transaction_temp_id,
			   x_task_type_id
		FROM (
			SELECT     wdt.task_id             ,
				   mmtt.transaction_temp_id,
				   wdt.task_type
			FROM       wms_dispatched_tasks wdt           ,
				   mtl_material_transactions_temp mmtt,
				   mtl_secondary_inventories msi      ,
				   mtl_item_locations mil
			WHERE  wdt.person_id                                                                 = p_employee_id
			   AND wdt.organization_id                                                           = p_organization_id
			   AND wdt.task_type                                                                 = 1 -- Picking
			   AND wdt.status                                                                    = 3
			   AND NVL(wdt.device_id, -1)                                                        = NVL(p_device_id, -1)
			   AND DECODE(wdt.device_id, NULL, 'Y', wdt.device_invoked)                          ='Y'
			   AND wdt.transaction_temp_id                                                       = mmtt.transaction_temp_id
			   AND DECODE(p_subinventory_code, NULL, mmtt.subinventory_code,p_subinventory_code) = mmtt.subinventory_code
			   AND mmtt.subinventory_code                                                        = msi.secondary_inventory_name
			   AND mmtt.organization_id                                                          = msi.organization_id
			   AND mmtt.locator_id                                                               = mil.inventory_location_id
			   AND mmtt.organization_id                                                          = mil.organization_id
			   AND wdt.task_method                                                               = 'MANIFESTPICKSLIP'
			   AND mmtt.pick_slip_number IN (SELECT * FROM    TABLE(list_pick_slip_numbers) )
			   AND wdt.task_group_id = g_group_sequence_number
			   AND mmtt.parent_line_id IS NULL  -- Added for bulk task
			ORDER BY msi.picking_order, mil.picking_order, wdt.priority , wdt.status , wdt.task_id
		     )
		WHERE  rownum <2;

	      IF (g_trace_on = 1) THEN
		      mydebug('MANIFESTPICKSLIP x_task_id' || x_task_id, 'GET_NEXT_TASK_IN_GROUP');
		      mydebug('MANIFESTPICKSLIP x_transaction_temp_id' || x_transaction_temp_id, 'GET_NEXT_TASK_IN_GROUP');
		      mydebug('MANIFESTPICKSLIP x_task_type_id' || x_task_type_id, 'GET_NEXT_TASK_IN_GROUP');
	      END IF;
	  --Added for Case Picking Project start

        END IF;
     EXCEPTION
        WHEN no_data_found THEN
           NULL;
     END;
  END get_next_task_in_group;

  PROCEDURE next_task
    (p_employee_id              IN NUMBER,
     p_effective_start_date     IN DATE,
     p_effective_end_date       IN DATE,
     p_organization_id          IN NUMBER,
     p_subinventory_code        IN VARCHAR2,
     p_equipment_id             IN NUMBER,
     p_equipment_serial         IN VARCHAR2,
     p_number_of_devices        IN NUMBER,
     p_device_id                IN NUMBER,
     p_task_filter              IN VARCHAR2,
     p_task_method              IN VARCHAR2,
     p_prioritize_dispatched_tasks IN VARCHAR2 := 'N', -- 4560814
     p_retain_dispatch_task	IN VARCHAR2	:= 'N', -- 4560814
     p_allow_unreleased_task    IN VARCHAR2     :='Y', -- for manual picking only bug 4718145
     p_max_clusters             IN NUMBER := null, -- added for cluster picking
     p_dispatch_needed          IN VARCHAR2 := 'Y', -- added for cluster picking
     x_grouping_document_type   IN OUT nocopy VARCHAR2,
     x_grouping_document_number IN OUT nocopy NUMBER,
     x_grouping_source_type_id  IN OUT nocopy NUMBER,
     x_is_changed_group         IN OUT nocopy VARCHAR2,
     x_task_info                OUT nocopy t_genref,
     x_task_number              OUT nocopy NUMBER,
     x_num_of_tasks             OUT nocopy NUMBER,
     x_task_type_id             OUT nocopy NUMBER,
     x_avail_device_id          OUT nocopy NUMBER,
     x_device_request_id        OUT nocopy NUMBER,
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2)
    IS
       l_cartonization_id         NUMBER;
       l_device_id                NUMBER := p_device_id;
       l_equipment_id             NUMBER := p_equipment_id;
       l_equipment_serial         WMS_DISPATCHED_TASKS.EQUIPMENT_INSTANCE%TYPE;
       l_subinventory_code        VARCHAR2(10) := p_subinventory_code;
       l_assignment_temp_id       NUMBER;
       l_loop_device_id           NUMBER;

       l_task_id                  NUMBER;
       l_transaction_temp_id      NUMBER;
       l_next_transaction_temp_id NUMBER;
       l_device_invoked           VARCHAR2(1);

       task_record                task_record_type;
       l_task_cursor              task_cursor_type;

       l_request_msg              VARCHAR2(200);

       l_error_code               NUMBER;

       l_task_from_group          BOOLEAN := FALSE;
       l_need_dispatch            BOOLEAN := TRUE;
       l_invoked_device_id        NUMBER;
       l_first_task               VARCHAR2(1);

       l_open_past_period         BOOLEAN;
       l_request_id               NUMBER;

       l_group_sequence_number    NUMBER;
       l_deliveries_list          VARCHAR2(2000);
       l_cartons_list             VARCHAR2(2000);
       l_user_id                  NUMBER := fnd_global.user_id;
       l_count                    NUMBER := 0;
       I                          NUMBER :=0;
       J                          NUMBER :=NULL;

-- Following variables were added for bug fix 4507435
       l_task_method_wdt		VARCHAR2(15);
       l_count_wdt			NUMBER;
       l_cluster_size_wdt		NUMBER;
       l_return_status		VARCHAR2(1);
       l_pick_slip_number	NUMBER;
       l_is_manifest_pick         VARCHAR2(1); --Added for Case Picking Project
       l_is_cluster_pick          VARCHAR2(1);


    CURSOR following_device_list(p_emp_id NUMBER, p_current_device_temp_id NUMBER) IS
      SELECT wdat.device_id,
             wdat.assignment_temp_id,
             wdb.subinventory_code
      FROM wms_device_assignment_temp wdat, wms_devices_b wdb
      WHERE wdat.assignment_temp_id >= p_current_device_temp_id
        AND wdat.employee_id = p_emp_id
        AND wdb.device_type_id <> 100
        AND wdat.device_id = wdb.device_id
      ORDER BY wdat.assignment_temp_id;

    CURSOR preceding_device_list(p_emp_id NUMBER, p_current_device_temp_id NUMBER) IS
      SELECT wdat.device_id,
             wdat.assignment_temp_id,
             wdb.subinventory_code
      FROM wms_device_assignment_temp wdat, wms_devices_b wdb
      WHERE wdat.assignment_temp_id < p_current_device_temp_id
        AND wdat.employee_id = p_emp_id
        AND wdb.device_type_id <> 100
        AND wdat.device_id = wdb.device_id
      ORDER BY wdat.assignment_temp_id;

	-- Following cursor is for 4507435, to count the dispatched cluster size
      CURSOR cluster_size_wdt IS SELECT mmtt.transaction_source_id, count (*)
	FROM wms_dispatched_tasks wdt, mtl_material_transactions_temp mmtt
	WHERE mmtt.transaction_temp_id = wdt.transaction_temp_id
	AND wdt.status = 3
	AND wdt.person_id = p_employee_id
	AND wdt.organization_id = p_organization_id
	AND wdt.task_method = 'CLUSTER'
	GROUP BY mmtt.transaction_source_id;

     --Bug#5188179.Cursor for task filter
      CURSOR c_task_filter(v_filter_name VARCHAR2) IS
      SELECT task_filter_source, task_filter_value
        FROM wms_task_filter_b wtf, wms_task_filter_dtl wtfd
        WHERE task_filter_name = v_filter_name
        AND wtf.task_filter_id = wtfd.task_filter_id;

    l_task_status           NUMBER; -- bug 4310093

    l_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_api_name              VARCHAR2(30) := 'WMS_PICKING_PKG.NEXT_TASK';
    --
    -- Bug 4722574
    --
    l_ignore_equipment      NUMBER;
    --
    l_max_seq_number        NUMBER :=0; -- Bug#5185031

    --Bug#5188179
    l_so_allowed            NUMBER  := 0;
    l_io_allowed            NUMBER  := 0;
    l_wip_allowed           NUMBER  := 0;
    l_mot_allowed           NUMBER  := 0;
    l_rep_allowed           NUMBER  := 0;
    l_moi_allowed           NUMBER  := 0;
    --Bug#5188179

    l_wdt_count							NUMBER; -- Bug# 5599049

     --Bug#8322661
    l_dup_task              BOOLEAN := FALSE;
    l_first_task_id         NUMBER;
    l_task_type_id          NUMBER;
  BEGIN

     IF (l_debug = 1) THEN
        mydebug('- - - - - - - - -', l_api_name);
     END IF;

     -- Establish a savepoint
     SAVEPOINT next_task_sp;

     x_return_status  := fnd_api.g_ret_sts_success;

     IF (l_debug = 1) THEN
        mydebug('Need to check if the period is open', l_api_name);
     END IF;

     -- Clear the message stack
     fnd_msg_pub.delete_msg;

     -- Check if the period is open
     -- TODO: Cache this
     IF g_period_id IS NULL THEN
        invttmtx.tdatechk(org_id           => p_organization_id,
                          transaction_date => SYSDATE,
                          period_id        => g_period_id,
                          open_past_period => l_open_past_period);
     END IF;

     IF g_period_id <= 0 THEN
        IF (l_debug = 1) THEN
           mydebug('Period is invalid', l_api_name);
        END IF;

        fnd_message.set_name('INV', 'INV_NO_OPEN_PERIOD');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     -- Ignore devices if multiple device signon and task methods not in
     -- discrete/wave
     IF p_number_of_devices > 1 AND p_task_method NOT IN ('DISCRETE', 'WAVE') THEN
        l_device_id := NULL;
     END IF;

     IF l_device_id = 0 THEN
        l_device_id := NULL;
     END IF;

     IF l_equipment_id = 0 THEN
        l_equipment_id  := NULL;
     END IF;

     -- Bug #4090630 - passing NONE to the task dispatching engine if
     -- p_equipment_serial is NULL
     l_equipment_serial := p_equipment_serial;
     IF (l_equipment_id is null and l_equipment_serial is null) then
   	IF (l_debug = 1) THEN
   		mydebug('l_equipment_id is null and l_equipment_serial is null', l_api_name);
   	END IF;
        --
        -- Start Bug 4722574
        --
        l_ignore_equipment := NVL(fnd_profile.VALUE('WMS_IGNORE_EQUIPMENT'), 1);
        IF l_ignore_equipment = 2 THEN
         l_equipment_serial := 'NONE';
        END IF;
        --
        -- End Bug 4722574
        --
     END IF;


     IF x_grouping_document_type IS NULL THEN
        IF p_task_method = 'DISCRETE' THEN
           x_grouping_document_type := 'PICK_SLIP';
         ELSIF p_task_method = 'ORDERPICK' THEN
           x_grouping_document_type := 'ORDER';
         ELSIF p_task_method = 'PICKBYLABEL' THEN
           x_grouping_document_type := 'CARTON';
         ELSIF p_task_method = 'CLUSTER' THEN
           x_grouping_document_type := 'CLUSTER';   -- for cluster picking
         ELSIF p_task_method = 'MANUAL' THEN
           x_grouping_document_type := 'TRANSACTION_TEMP_ID';
        END IF;
     END IF;

     IF x_grouping_document_number = 0 THEN
        x_grouping_document_number := NULL;
     END IF;

     IF x_grouping_document_type = 'CARTON' THEN
        l_cartonization_id := x_grouping_document_number;
      ELSIF x_grouping_document_type = 'CYCLE_COUNT' THEN
        x_grouping_document_number := NULL;
     END IF;

     x_num_of_tasks := 0;

     IF (l_debug = 1) THEN
        mydebug('Device ID: ' || l_device_id, l_api_name);
        mydebug('Equipment ID: ' || l_equipment_id, l_api_name);
        mydebug('Equipment Instance:'|| l_equipment_serial, l_api_name);
        mydebug('Grouping Document Type: ' || x_grouping_document_type, l_api_name);
        mydebug('Grouping Document Number: ' || x_grouping_document_number, l_api_name);
        mydebug('Task Method: ' || p_task_method, l_api_name);

        mydebug('Current Group Sequence Number: ' || g_group_sequence_number, l_api_name);
        mydebug('Maximum Group Sequence Number: ' || g_max_group_sequence_number, l_api_name);
     END IF;

     --viks selecting temp-ids form pl/sql table for the split task when start_over
   --button is pressed

       l_count := g_start_over_tempid.COUNT;

       IF      l_count > 0 THEN


        IF (l_debug = 1) THEN
         FOR I in g_start_over_tempid.FIRST .. g_start_over_tempid.LAST LOOP
          mydebug('Tempid in I loop : ', g_start_over_tempid(I));
          IF SQL%NOTFOUND THEN
          mydebug ('Tempid  not found ',I );
          END IF;
         END LOOP;
        END IF;


        l_next_transaction_temp_id := g_start_over_tempid(g_start_over_tempid.FIRST);
        IF (l_debug = 1) THEN
         mydebug('Tempid count ' || l_count ,l_next_transaction_temp_id);
        mydebug ('First Index is ' , g_start_over_tempid.FIRST);
        END IF;

        UPDATE mtl_material_transactions_temp
        SET transaction_header_id = mtl_material_transactions_s.NEXTVAL,
                       last_update_date      = Sysdate,
                       last_updated_by       = l_user_id
        WHERE transaction_temp_id = l_next_transaction_temp_id
        returning wms_task_type INTO x_task_type_id;
        IF (l_debug = 1) THEN
        mydebug('Tempid in table to be deleted viks : ', l_next_transaction_temp_id );
        END IF;

        g_start_over_tempid.DELETE(g_start_over_tempid.FIRST);

      END IF; --viks changes end

    -- BugFix #4507435
     IF(p_prioritize_dispatched_tasks = 'Y') THEN -- default 'N'

	IF (l_debug = 1) THEN
	 mydebug('Before fetching from MMTT...','');
         mydebug('PRIORITIZE_DISPATCHED_TASK: ' || p_prioritize_dispatched_tasks, '');
	 mydebug('GROUPING DOCUMENT NUMBER: '|| x_grouping_document_number,'');
	 mydebug('GROUPING SOURCE TYPE ID: '|| x_grouping_source_type_id,'');
        END IF;
        BEGIN

	       --Bug#5188179.The dispatched tasks should be filtered as per task_filter.
               FOR task_filter_rec IN c_task_filter(p_task_filter) LOOP
                      IF (l_debug = 1) THEN
                        mydebug('Task Filter Source: ' || task_filter_rec.task_filter_source, '');
                        mydebug('Task Filter Value: ' || task_filter_rec.task_filter_value, '');
                      END IF;

                     IF task_filter_rec.task_filter_value = 'Y' THEN
                         IF task_filter_rec.task_filter_source = 1 THEN -- Internal Order
                              l_io_allowed        := 1;
                         ELSIF task_filter_rec.task_filter_source = 2 THEN -- Move Order Issue
                              l_moi_allowed       := 1;
                         ELSIF task_filter_rec.task_filter_source = 3 THEN -- Move Order Transfer
                              l_mot_allowed       := 1;
                         ELSIF task_filter_rec.task_filter_source = 4 THEN -- Replenishment
                              l_rep_allowed       := 1;
                         ELSIF task_filter_rec.task_filter_source = 5 THEN -- Sales Order
                              l_so_allowed        := 1;
                         ELSIF task_filter_rec.task_filter_source = 6 THEN -- Work Order
                              l_wip_allowed       := 1;
                         END IF;
                    END IF;
                END LOOP; --Bug#5188179.End of fix.


	       -- Bug#5185031 Fetched the value for l_max_seq_number.
	       select wdt.task_method, count(*),  max(wdt.task_group_id)
	        into l_task_method_wdt, l_count_wdt ,l_max_seq_number
                from wms_dispatched_tasks wdt, mtl_material_transactions_temp mmtt
		where mmtt.transaction_temp_id = wdt.transaction_temp_id
		and wdt.status = 3
		and wdt.person_id = p_employee_id
		and wdt.organization_id = p_organization_id
                and Decode(mmtt.transaction_source_type_id,   /*Bug5188179. Apply task filter*/
                             2, l_so_allowed,
                             4, Decode(mmtt.transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)),
                             5, Decode(mmtt.transaction_type_id, 35, l_wip_allowed),
                             8, l_io_allowed,
                             13, Decode(mmtt.transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(mmtt.transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1

		group by wdt.task_method;

	        IF (l_debug = 1) THEN
	           mydebug(l_task_method_wdt|| ' : ' || l_count_wdt,'');
                END IF;

		IF l_count_wdt > 0 AND p_task_method <> l_task_method_wdt THEN
			mydebug('Dispatched tasks need be completed first. Use the picking method used before','');
			x_return_status := 'E';
			x_msg_data := l_task_method_wdt;
			RETURN;
		END IF;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		mydebug('No Tasks in WDT','');
	END;

	IF l_task_method_wdt = 'CLUSTER' THEN
		l_cluster_size_wdt := 0;
		for rec in cluster_size_wdt loop
			l_cluster_size_wdt := l_cluster_size_wdt + 1;
		end loop;
		IF l_cluster_size_wdt <> p_max_clusters THEN
			mydebug('Dispatched cluster size and input cluster size doesnt match','');
			l_return_status := 'W';
			x_msg_data := l_cluster_size_wdt;
		ELSE
			mydebug('Dispatched cluster size and input cluster size matches','');
		END IF;
	END IF;
	-- check if any dispatched tasks in WDT
	-- fetch the document number, source type id
	IF l_count_wdt > 0 AND x_grouping_source_type_id IS NULL AND ( x_grouping_document_number IS NULL OR
		( x_grouping_document_number IS NOT NULL AND x_grouping_document_type = 'CARTON') ) THEN
		-- Bug 4597257, Changed the condition since for cartonized tasks, the grouping_document_number wont be null
	     BEGIN


                -- bug 5266450
		-- Change select pending tasks as sub-query with order by first
		-- Move rownum clause out of the order by query to ensure the lowerest
		-- row is selected from the pending tasks
		--
		-- bug 5094839
		-- Restore task_goup_id in the select statement to
		-- (task_group_id - 1) for getting the correct task_group_id

		select transaction_source_id, transaction_source_type_id, device_id,
		       (task_group_id - 1), pick_slip_number, cartonization_id

		INTO x_grouping_document_number, x_grouping_source_type_id, l_device_id,
		     g_group_sequence_number, l_pick_slip_number, l_cartonization_id

		From
		( select mmtt.transaction_source_id, mmtt.transaction_source_type_id, wdt.device_id,
			wdt.task_group_id, mmtt.pick_slip_number, mmtt.cartonization_id

		  from mtl_material_transactions_temp mmtt, wms_dispatched_tasks wdt
		  where mmtt.transaction_temp_id = wdt.transaction_temp_id
		  and wdt.status = 3
		  and wdt.person_id = p_employee_id
		  and wdt.organization_id = p_organization_id
		  and Decode(mmtt.transaction_source_type_id,   /*Bug5188179. Apply task filter*/
                             2, l_so_allowed,
                             4, Decode(mmtt.transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)),
                             5, Decode(mmtt.transaction_type_id, 35, l_wip_allowed),
                             8, l_io_allowed,
                             13, Decode(mmtt.transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(mmtt.transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
		  order by wdt.task_group_id, wdt.transaction_temp_id )-- 4584860
		  Where rownum = 1;  -- bug 5264450


		IF x_grouping_document_type = 'PICK_SLIP' THEN -- Added this for 4580273
			x_grouping_document_number := l_pick_slip_number;
		ELSIF x_grouping_document_type = 'CARTON' THEN
			x_grouping_document_number := l_cartonization_id;
		END IF;

		IF (l_debug = 1) THEN
		 mydebug('After fetching from MMTT...','');
		 mydebug('PRIORITIZE_DISPATCHED_TASK: ' || p_prioritize_dispatched_tasks, '');
		 mydebug('GROUPING DOCUMENT NUMBER: '|| x_grouping_document_number,'');
		 mydebug('GROUPING SOURCE TYPE ID: '|| x_grouping_source_type_id,'');
		END IF;
		-- If the above select doesnt return any rows, just fetch it from MMTT as usual
		EXCEPTION WHEN NO_DATA_FOUND THEN
			mydebug('No Task in WDT, so fetching from MMTT: ','');
	    END;
	END IF;
    END IF;
    -- End of Code #4507435

    --Bug#5185031 Added the IF block.
    IF g_max_group_sequence_number <= 0 THEN
       g_max_group_sequence_number := l_max_seq_number;
    END IF;

    -- Get next task in group

    IF (l_next_transaction_temp_id IS NULL) THEN

     IF (p_task_method NOT IN ('MANUAL') AND
         x_grouping_document_number IS NOT NULL AND
         (g_group_sequence_number <= g_max_group_sequence_number) AND
         (p_number_of_devices <= 1 OR l_device_id IS null))
           OR (p_task_method = 'CLUSTER' AND p_dispatch_needed = 'N') -- cluster picking
	   OR (p_task_method = 'CLUSTERPICKBYLABEL') -- cluster pick by label
     THEN
        get_next_task_in_group
          (p_employee_id              => p_employee_id,
           p_organization_id          => p_organization_id,
           p_subinventory_code        => p_subinventory_code,
           p_device_id                => l_device_id,
           p_grouping_document_type   => x_grouping_document_type,
           p_grouping_document_number => x_grouping_document_number,
           p_grouping_source_type_id  => x_grouping_source_type_id,
           x_task_id                  => l_task_id,
           x_transaction_temp_id      => l_next_transaction_temp_id,
           x_task_type_id             => x_task_type_id,
           x_return_status            => x_return_status,
           x_msg_data                 => x_msg_data,
           x_msg_count                => x_msg_count);

        IF (l_debug = 1) THEN
           mydebug('Return Status from get_next_task_in_group: ' || x_return_status,l_api_name);
        END IF;

        IF x_return_status = 'U' THEN
           RAISE fnd_api.g_exc_unexpected_error;
         ELSIF x_return_status = 'E' THEN
           RAISE fnd_api.g_exc_error;
        END IF;

        IF l_next_transaction_temp_id IS NOT NULL THEN
           x_num_of_tasks := 1;
           l_task_from_group := TRUE;
        END IF;

      ELSIF p_task_method = 'MANUAL' THEN
        manual_pick
          (p_employee_id           =>  p_employee_id,
           p_effective_start_date  =>  p_effective_start_date,
           p_effective_end_date    =>  p_effective_end_date,
           p_organization_id       =>  p_organization_id,
           p_subinventory_code     =>  p_subinventory_code,
           p_equipment_id          =>  p_equipment_id,
           p_equipment_serial      =>  l_equipment_serial,
           p_transaction_temp_id   =>  x_grouping_document_number,
           p_allow_unreleased_task =>  p_allow_unreleased_task,
           x_task_type_id          =>  x_task_type_id,
           x_return_status         =>  x_return_status,
           x_msg_count             =>  x_msg_count,
           x_msg_data              =>  x_msg_data);

        IF (l_debug = 1) THEN
           mydebug('Return Status from manual_pick: ' || x_return_status,l_api_name);
        END IF;

        IF x_return_status = 'U' THEN
           RAISE fnd_api.g_exc_unexpected_error;
         ELSIF x_return_status = 'E' THEN
           RAISE fnd_api.g_exc_error;
        END IF;

        l_next_transaction_temp_id := x_grouping_document_number;
        x_num_of_tasks := 1;

        g_max_group_sequence_number := 1;
        g_group_sequence_number := 1;
     END IF;
    END IF;

     IF g_group_sequence_number > g_max_group_sequence_number THEN
        x_is_changed_group := 'Y';
      ELSE
        x_is_changed_group := 'N';
     END IF;

     IF (l_debug = 1) THEN
        mydebug('Next Transaction Temp ID: ' || l_next_transaction_temp_id, l_api_name);
     END IF;

     IF l_next_transaction_temp_id IS NULL and (p_dispatch_needed IS NULL
                                                OR p_dispatch_needed <>'N')  THEN

        x_is_changed_group := 'Y';

        IF l_device_id IS NOT NULL THEN
           -- Get the subinventory and the assignment temp ID
           SELECT wdat.assignment_temp_id, wd.subinventory_code
             INTO l_assignment_temp_id, l_subinventory_code
             FROM wms_device_assignment_temp wdat, wms_devices_b wd
             WHERE wdat.device_id = l_device_id
             AND wdat.device_id = wd.device_id
             AND wdat.employee_id = p_employee_id;

           IF p_number_of_devices <= 1 OR
             p_task_method IN ('DISCRETE', 'WAVE') THEN
              OPEN following_device_list(p_employee_id, l_assignment_temp_id);
              OPEN preceding_device_list(p_employee_id, l_assignment_temp_id);
            ELSE
              l_device_id := NULL;
           END IF;
        END IF;

        IF (l_debug = 1) THEN
           mydebug('Device ID: ' || l_device_id, l_api_name);
        END IF;
        LOOP
           IF l_device_id IS NOT NULL THEN

              <<search_device_loop>>
                -- loop to find the available task and check if we need to dispatch task to some devices
                LOOP
                   FETCH following_device_list INTO l_loop_device_id, l_assignment_temp_id, l_subinventory_code;

                   IF (following_device_list%NOTFOUND) THEN
                      FETCH preceding_device_list INTO l_loop_device_id, l_assignment_temp_id, l_subinventory_code;

                      IF (preceding_device_list%NOTFOUND) THEN
                         CLOSE following_device_list;
                         CLOSE preceding_device_list;

                         l_need_dispatch := FALSE;
                         EXIT search_device_loop;
                      END IF;
                   END IF;

                   IF (l_debug = 1) THEN
                      mydebug('Loop Device ID: ' || l_loop_device_id, l_api_name);
                      mydebug('Subinventory: ' || l_subinventory_code, l_api_name);
                   END IF;

                   BEGIN
                      SELECT transaction_temp_id, task_type,
                             device_invoked, device_request_id
                        INTO l_transaction_temp_id, x_task_type_id,
                             l_device_invoked, l_request_id
                        FROM wms_dispatched_tasks
                        WHERE person_id = p_employee_id
                        AND organization_id = p_organization_id
                        AND device_id = l_loop_device_id
                        AND task_type IN(1, 3, 4, 5, 6)
                        AND status = 3
                        AND ROWNUM = 1
                        ORDER BY 1;

                      IF (l_debug = 1) THEN
                         mydebug('Transaction Temp ID: ' || l_transaction_temp_id, l_api_name);
                         mydebug('Device Invoked: ' || l_device_invoked, l_api_name);
                      END IF;

                      IF l_device_invoked = 'N' AND x_task_type_id <> 3 THEN
                         wms_device_integration_pvt.device_request
                           (p_bus_event      => wms_device_integration_pvt.wms_be_pick_load,
                            p_call_ctx       => wms_device_integration_pvt.dev_req_auto,
                            p_task_trx_id    => l_transaction_temp_id,
                            p_org_id         => p_organization_id,
                            x_request_msg    => l_request_msg,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_request_id     => l_request_id);

                         -- always dispatch the task whether invoking device successfully or not
                         -- So update the table always

                         UPDATE wms_dispatched_tasks
                           SET device_invoked = 'Y',
                               device_request_id = l_request_id
                           WHERE transaction_temp_id = l_transaction_temp_id;

                         IF x_return_status <> fnd_api.g_ret_sts_success THEN
                            IF (l_debug = 1) THEN
                               mydebug('Failed to invoke device ' || TO_CHAR(l_loop_device_id), l_api_name);
                            END IF;
                         END IF;
                      END IF;


                      IF x_avail_device_id IS NULL THEN
                         x_avail_device_id := l_loop_device_id;
                         l_next_transaction_temp_id := l_transaction_temp_id;
                         x_device_request_id := l_request_id;
                      END IF;

                   EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                         l_need_dispatch  := TRUE;
                         EXIT search_device_loop;
                   END;
                END LOOP;
           END IF;

           EXIT WHEN l_need_dispatch = FALSE;

	   LOOP  --Bug#8322661

		   IF (l_debug = 1) THEN
		      mydebug('Before Calling TD Engine', l_api_name);
		   END IF;

		   -- Remove any rows from wms_ordered_tasks
		   DELETE FROM wms_ordered_tasks;

		   IF (p_task_method = 'CLUSTER') THEN  -- call for the overloaded dispatch_task

		     IF (l_debug = 1) THEN
			 mydebug('calling task_dispatch for cluster picking',l_api_name);
		     END IF;

		     wms_task_dispatch_engine.dispatch_task(
		       p_api_version                => 1.0
		     , p_init_msg_list              => 'F'
		     , p_commit                     => NULL
		     , p_sign_on_emp_id             => p_employee_id
		     , p_sign_on_org_id             => p_organization_id
		     , p_sign_on_zone               => l_subinventory_code
		     , p_sign_on_equipment_id       => p_equipment_id
		     , p_sign_on_equipment_srl      => l_equipment_serial
		     , p_task_type                  => 'ALL'
		     , p_task_filter                => p_task_filter
		     , x_task_cur                   => l_task_cursor
		     , x_return_status              => x_return_status
		     , x_msg_count                  => x_msg_count
		     , x_msg_data                   => x_msg_data
		     , p_cartonization_id           => null
		     , p_max_clusters               => p_max_clusters
		     , x_deliveries_list            => l_deliveries_list
		     , x_cartons_list               => l_cartons_list
		     );


		    ELSE

		     IF (l_debug = 1) THEN
			 mydebug('calling task_dispatch for non cluster picking',l_api_name);
		     END IF;

		     wms_task_dispatch_engine.dispatch_task
		       (p_api_version                => 1.0,
			p_init_msg_list              => 'F',
			p_commit                     => NULL,
			p_sign_on_emp_id             => p_employee_id,
			p_sign_on_org_id             => p_organization_id,
			p_sign_on_zone               => l_subinventory_code,
			p_sign_on_equipment_id       => p_equipment_id,
			p_sign_on_equipment_srl      => l_equipment_serial,
			p_task_filter                => p_task_filter,
			p_task_method                => p_task_method,
			x_grouping_document_type     => x_grouping_document_type,
			x_grouping_document_number   => x_grouping_document_number,
			x_grouping_source_type_id    => x_grouping_source_type_id,
			x_task_cur                   => l_task_cursor,
			x_return_status              => x_return_status,
			x_msg_count                  => x_msg_count,
			x_msg_data                   => x_msg_data);
		   END IF;

		   IF (l_debug = 1) THEN
		      mydebug('Task Dispatching Engine returned: ' || x_return_status, l_api_name);
		   END IF;

		   IF x_return_status = 'S' THEN
		      IF (l_debug = 1) THEN
			 mydebug('Grouping Document Type: ' || x_grouping_document_type, l_api_name);
			 mydebug('Grouping Document Number: ' || x_grouping_document_number, l_api_name);
		      END IF;

		      l_first_task  := 'Y';
		      l_group_sequence_number := 1;
		      g_group_sequence_number := 1;
		      l_dup_task := FALSE;  --Bug#8322661

		      LOOP
			 FETCH l_task_cursor INTO task_record;

			 EXIT WHEN l_task_cursor%NOTFOUND;

			 x_num_of_tasks := x_num_of_tasks + 1;

									--Bug#5599049: We need to make sure that the task is not being performed by other users.
						SELECT count(1) INTO l_wdt_count
						FROM wms_dispatched_tasks WDT
						WHERE WDT.transaction_temp_id = task_record.transaction_temp_id
						AND   WDT.person_id <> p_employee_id
						AND   WDT.status in (3,9);

						IF l_wdt_count > 0  then
					IF (l_debug = 1) THEN
			     mydebug('ERROR...This task has been dispatched to some other user.', l_api_name);
					END IF;

					fnd_message.set_name('WMS', 'WMS_TASK_LOCKED');
					fnd_msg_pub.ADD;
					RAISE fnd_api.g_exc_unexpected_error;
						END IF;
							--Bug#5599049 .Fix ends.

			 IF l_group_sequence_number = 1 AND
			   l_next_transaction_temp_id IS NULL THEN
			    -- bug 5368659
			    IF (p_task_method <> 'CLUSTER') THEN
				l_next_transaction_temp_id := task_record.transaction_temp_id;
			    END IF;

			    l_next_transaction_temp_id := task_record.transaction_temp_id;
			    x_avail_device_id := l_loop_device_id;
			    x_task_type_id := task_record.task_type;

			    IF x_task_type_id = 3 THEN
			       x_grouping_document_number := task_record.transaction_temp_id;
			    END IF;
			 END IF;

			 IF (l_debug = 1) THEN
			    mydebug('Transaction Temp ID: ' || task_record.transaction_temp_id, l_api_name);
			 END IF;

			 l_request_id := NULL;

			 /* IF l_first_task = 'Y' AND x_task_type_id <> 3 THEN -- invoke the device  --Bug#8322661 Moved below
			    wms_device_integration_pvt.device_request
			      (p_bus_event         => wms_device_integration_pvt.wms_be_pick_load,
			       p_call_ctx          => wms_device_integration_pvt.dev_req_auto,
			       p_task_trx_id       => task_record.transaction_temp_id,
			       p_org_id            => p_organization_id,
			       x_request_msg       => l_request_msg,
			       x_return_status     => x_return_status,
			       x_msg_count         => x_msg_count,
			       x_msg_data          => x_msg_data,
			       p_request_id        => l_request_id);

			    IF x_return_status <> fnd_api.g_ret_sts_success THEN
			       IF (l_debug = 1) THEN
				  mydebug('Failed to invoke device ' || TO_CHAR(l_loop_device_id), l_api_name);
			       END IF;
			    END IF;

			    IF x_device_request_id IS NULL THEN
			       x_device_request_id := l_request_id;
			    END IF;

			 END IF;

			 IF (l_debug = 1) THEN
			    mydebug('Device Request ID: ' || l_request_id, l_api_name);
			 END IF; */

			 UPDATE mtl_material_transactions_temp
			   SET transaction_header_id = mtl_material_transactions_s.NEXTVAL
			     , last_update_date      = Sysdate
			     , last_updated_by       = l_user_id
			     , posting_flag = 'Y' -- Bug4185621: this will change the parent posting flag to 'Y' for bulking picking
						  -- If not bulking picking, this has not effect
			   WHERE transaction_temp_id = task_record.transaction_temp_id;

			 BEGIN --bug 4310093
			 -- Check if this record already exists in WDD
			 -- and the task status
			 SELECT STATUS
			 INTO l_task_Status
			 FROM wms_dispatched_tasks
			 WHERE transaction_temp_id = task_record.transaction_temp_id;

			-- Bug 4507435, if retain_dispatch_Task is null.
			 IF ((l_task_status <> 3) OR ( l_task_status = 3 AND p_retain_dispatch_task = 'Y')) THEN
			 mydebug('Updating Temp ID in WDT: ' || task_record.transaction_temp_id, l_api_name);
			    UPDATE wms_dispatched_tasks
			      SET status                = 3, -- Dispatched
				  task_group_id         = l_group_sequence_number,
				  device_id             = l_loop_device_id,
				  device_invoked        = Decode(l_loop_device_id, NULL, To_char(NULL),
							      Decode(l_first_task, 'Y', 'Y', 'N')),
				  device_request_id     = l_request_id,
				  -- Bugfix 4101378
				  equipment_id          = p_equipment_id,
				  equipment_instance    = p_equipment_serial,
				  machine_resource_id   = task_record.machine_resource_id,
				  -- End of code Bugfix 4101378
				  last_update_date      = Sysdate,
				  last_updated_by       = l_user_id,
				  task_method           = p_task_method
			      WHERE transaction_temp_id = task_record.transaction_temp_id;

			    g_previous_task_status(task_record.transaction_temp_id) := 2;

			 ELSE
			     g_previous_task_status(task_record.transaction_temp_id):=1;                      -- dispatched to return back to pending
			 END IF;

			 -- If the above update did not find any WDD record, insert a new record into WDD
			 EXCEPTION  --bug 4310093
			    WHEN NO_DATA_FOUND THEN

			    g_previous_task_status(task_record.transaction_temp_id) := 1;

			    BEGIN  --Bug#8322661 Kept the INSERT in a BEGIN-END block

			    -- Insert into WMS_DISPATCHED_TASKS for this user
				    INSERT INTO wms_dispatched_tasks
				      (task_id,
				       transaction_temp_id,
				       organization_id,
				       user_task_type,
				       person_id,
				       effective_start_date,
				       effective_end_date,
				       equipment_id,
				       equipment_instance,
				       person_resource_id,
				       machine_resource_id,
				       status,
				       dispatched_time,
				       last_update_date,
				       last_updated_by,
				       creation_date,
				       created_by,
				       task_type,
				       priority,
				       operation_plan_id,
				       move_order_line_id,
				       device_id,
				       device_invoked,
				       device_request_id,
				       task_group_id,
				       task_method)     -- add for cluster picking but others can use it too
				      VALUES
				      (wms_dispatched_tasks_s.NEXTVAL,
				       task_record.transaction_temp_id,
				       p_organization_id,
				       NVL(task_record.standard_operation_id, 2),
				       p_employee_id,
				       sysdate , --task_record.effective_start_date, --bug#6409956
				       sysdate , --task_record.effective_end_date,   --bug#6409956
				       p_equipment_id,
				       p_equipment_serial,
				       task_record.person_resource_id,
				       task_record.machine_resource_id,
				       3, -- Dispatched
				       Sysdate,
				       Sysdate,
				       l_user_id,
				       Sysdate,
				       l_user_id,
				       task_record.task_type,
				       task_record.priority,
				       task_record.operation_plan_id,
				       task_record.move_order_line_id,
				       l_loop_device_id,
				       Decode(l_loop_device_id, NULL, To_char(NULL), Decode(l_first_task, 'Y', 'Y', 'N')),
				       l_request_id,
				       l_group_sequence_number,
				       p_task_method);   -- add for cluster picking

			       EXCEPTION
				WHEN DUP_VAL_ON_INDEX THEN
				 l_dup_task := TRUE;
			       END;  --Bug#8322661

			    IF (l_debug = 1) THEN
			       mydebug('Inserted into WDT', l_api_name);
			    END IF;
			 END;  -- end the begin for updating and inserting to WDT4310093

			 -- Increment the group sequence number by 1
			 l_group_sequence_number := l_group_sequence_number + 1;

			 IF x_avail_device_id IS NULL AND l_loop_device_id IS NOT NULL THEN
			    x_avail_device_id := l_loop_device_id;
			    x_device_request_id := l_request_id;
			 END IF;

			 IF l_first_task = 'Y' THEN -- invoke the device
			    l_first_task := 'N';
			    l_first_task_id := task_record.transaction_temp_id;  --Bug#8322661
			    l_task_type_id  := task_record.task_type;  --Bug#8322661
			 END IF;

		      END LOOP;

		      IF l_task_type_id <> 3 THEN -- invoke the device  --Bug#8322661 Moved here from above
			     wms_device_integration_pvt.device_request
			       (p_bus_event         => wms_device_integration_pvt.wms_be_pick_load,
				p_call_ctx          => wms_device_integration_pvt.dev_req_auto,
				p_task_trx_id       => l_first_task_id,
				p_org_id            => p_organization_id,
				x_request_msg       => l_request_msg,
				x_return_status     => x_return_status,
				x_msg_count         => x_msg_count,
				x_msg_data          => x_msg_data,
				p_request_id        => l_request_id);

			     IF x_return_status <> fnd_api.g_ret_sts_success THEN
				IF (l_debug = 1) THEN
				   mydebug('Failed to invoke device ' || TO_CHAR(l_loop_device_id), l_api_name);
				END IF;
			     END IF;

			     IF x_device_request_id IS NULL THEN
				x_device_request_id := l_request_id;
			     END IF;

		      END IF;

		      IF (l_debug = 1) THEN
			 mydebug('Device Request ID: ' || l_request_id, l_api_name);
		      END IF;  --Bug#8322661

		      -- bug 5368659
		      IF l_next_transaction_temp_id IS NULL and p_task_method='CLUSTER' THEN
			  get_next_task_in_group
			      (p_employee_id              => p_employee_id,
			       p_organization_id          => p_organization_id,
			       p_subinventory_code        => p_subinventory_code,
			       p_device_id                => l_device_id,
			       p_grouping_document_type   => x_grouping_document_type,
			       p_grouping_document_number => x_grouping_document_number,
			       p_grouping_source_type_id  => x_grouping_source_type_id,
			       x_task_id                  => l_task_id,
			       x_transaction_temp_id      => l_next_transaction_temp_id,
			       x_task_type_id             => x_task_type_id,
			       x_return_status            => x_return_status,
			       x_msg_data                 => x_msg_data,
			       x_msg_count                => x_msg_count);

			   IF (l_debug = 1) THEN
			       mydebug('Return Status from get_next_task_in_group: ' || x_return_status,l_api_name);
			   END IF;

			   IF x_return_status = 'U' THEN
			      RAISE fnd_api.g_exc_unexpected_error;
			   ELSIF x_return_status = 'E' THEN
			      RAISE fnd_api.g_exc_error;
			   END IF;

			   IF l_next_transaction_temp_id IS NOT NULL THEN
			      x_num_of_tasks := 1;
			      l_task_from_group := TRUE;
			   END IF;

		      END IF;
		      -- end bug 5368659


		    ELSIF x_return_status = 'U' THEN
		      fnd_message.set_name('WMS', 'WMS_TD_TDENG_ERROR');
		      fnd_msg_pub.ADD;
		      RAISE fnd_api.g_exc_unexpected_error;
		    ELSIF x_return_status = 'E' THEN
		      IF (l_debug = 1) THEN
			 mydebug('Setting status as S', l_api_name);
		      END IF;
		      x_return_status  := fnd_api.g_ret_sts_success;
		   END IF;

		EXIT WHEN l_dup_task = FALSE;  --Bug#8322661
 	   END LOOP;  --Bug#8322661

           -- If there are no devices then get out of the loop
           IF l_device_id IS NULL THEN
              l_need_dispatch  := FALSE;
           END IF;
        END LOOP; -- end loop of the devices


        IF l_next_transaction_temp_id IS NOT NULL AND Nvl(x_num_of_tasks, 0) <= 0 THEN
           x_num_of_tasks := 1;
        END IF;

        IF (l_debug = 1) THEN
           mydebug('Number of tasks: ' || x_num_of_tasks, l_api_name);
        END IF;

        g_max_group_sequence_number := x_num_of_tasks;
     END IF; -- If there are more tasks in the group

     IF l_next_transaction_temp_id IS NOT NULL THEN

        IF x_task_type_id <> 3 THEN
           IF (p_task_method = 'CLUSTER') THEN
                l_cartons_list := ' '; -- make it not null to be used in the following API
           END IF;

	     --Added for Case Picking Project start
	     IF (p_task_method = 'MANIFESTORDER' OR  p_task_method = 'MANIFESTPICKSLIP') THEN
		  l_is_manifest_pick := 'Y';
	     ELSE
		  l_is_manifest_pick := 'N';
	     END IF;
	     --Added for Case Picking Project end

           x_num_of_tasks := g_max_group_sequence_number;
           x_task_number := g_group_sequence_number;

           -- Need to get detailed information for the next task
           get_next_task_info
             (p_sign_on_emp_id       => p_employee_id,
              p_sign_on_org_id       => p_organization_id,
              p_transaction_temp_id  => l_next_transaction_temp_id,
              p_cartonization_id     => l_cartonization_id,
              p_device_id            => x_avail_device_id,
              x_return_status        => x_return_status,
              x_error_code           => l_error_code,
              x_mesg_count           => x_msg_count,
              x_error_mesg           => x_msg_data,
              x_task_info            => x_task_info,
              p_is_cluster_pick      => 'N',
              p_cartons_list         => l_cartons_list,
	      p_is_manifest_pick     => l_is_manifest_pick); --Added for Case Picking Project


           mydebug('get_next_task_info returned: ' || x_return_status, l_api_name);

           IF x_return_status <> 'S' THEN
              fnd_message.set_name('WMS', 'WMS_TD_TDENG_ERROR');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;

           l_request_id := NULL;
                -- viks For start over button pressed l_count >0 for multiple device

           IF ((l_task_from_group OR p_task_method = 'MANUAL') OR l_count >0) THEN

              IF x_avail_device_id IS NULL THEN
                 IF p_device_id = 0 THEN
                    x_avail_device_id := NULL;
                  ELSE
                    x_avail_device_id := p_device_id;
                 END IF;
              END IF;

              wms_device_integration_pvt.device_request
                (p_bus_event      => wms_device_integration_pvt.wms_be_pick_load,
                 p_call_ctx       => wms_device_integration_pvt.dev_req_auto,
                 --p_task_trx_id    => l_transaction_temp_id,
                 p_task_trx_id    => l_next_transaction_temp_id,
                 p_org_id         => p_organization_id,
                 x_request_msg    => l_request_msg,
                 x_return_status  => x_return_status,
                 x_msg_count      => x_msg_count,
                 x_msg_data       => x_msg_data,
                 p_request_id     => l_request_id);

              x_device_request_id := l_request_id;

              -- always dispatch the task whether invoking device successfully or not
              -- So update the table always

              IF x_return_status <> fnd_api.g_ret_sts_success THEN
                 IF (l_debug = 1) THEN
                    mydebug('Failed to invoke device ' || TO_CHAR(l_loop_device_id), l_api_name);
                 END IF;
              END IF;
           END IF;

           UPDATE wms_dispatched_tasks
             SET status            = 9, -- Active
                 device_id         = x_avail_device_id,
                 device_invoked    = Decode(x_avail_device_id, NULL, To_char(NULL), 'Y'),
                 device_request_id = x_device_request_id,
                 last_update_date      = Sysdate,
                 last_updated_by       = l_user_id
             WHERE transaction_temp_id = l_next_transaction_temp_id;
         ELSE-- cycle count task
          mydebug('Updated Cycle count task to active: '||l_next_transaction_temp_id, l_api_name);
          UPDATE wms_dispatched_tasks
          SET status                = 9, -- Active
              last_update_date      = Sysdate,
              last_updated_by       = l_user_id
          WHERE transaction_temp_id = l_next_transaction_temp_id;
          x_grouping_document_number := l_next_transaction_temp_id;
        END IF; -- Not a cycle count task

        -- Delete from the skip tasks exceptions table
        DELETE FROM wms_skip_task_exceptions
          WHERE task_id = task_record.transaction_temp_id
          AND task_id IN (SELECT wste.task_id
                          FROM wms_skip_task_exceptions wste, mtl_parameters mp
                          WHERE ABS((SYSDATE - wste.creation_date) * 24 * 60) > mp.skip_task_waiting_minutes
                          AND wste.task_id = task_record.transaction_temp_id
                          AND wste.organization_id = mp.organization_id);

        -- Committing these tasks to this user
        COMMIT;

        IF (l_debug = 1) THEN
           mydebug('Committed tasks to the user', l_api_name);

           mydebug('Current Group Sequence Number: ' || g_group_sequence_number, l_api_name);
           mydebug('Maximum Group Sequence Number: ' || g_max_group_sequence_number, l_api_name);
        END IF;

     END IF;

     inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

     x_return_status := fnd_api.g_ret_sts_success;

     IF x_return_status = 'S' AND l_return_status = 'W' THEN -- Bug 4507435
		mydebug('Good One','');
		x_return_status := 'W';
     END IF;


  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
        IF (l_debug = 1) THEN
           mydebug('Error', l_api_name);
        END IF;
        x_return_status := 'E';

        inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

        ROLLBACK TO next_task_sp;
     WHEN OTHERS THEN
        IF (l_debug = 1) THEN
           mydebug('Unexpected Error: ' || Sqlerrm, l_api_name);
        END IF;
        x_return_status := 'U';

        inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

        ROLLBACK TO next_task_sp;
  END next_task;

--Start Bug 6682436
PROCEDURE split_mmtt_lpn(
    p_transaction_temp_id   IN  NUMBER
  , p_line_quantity         IN  NUMBER
  , p_transaction_UOM       IN  VARCHAR2
  , p_lpn_id		    IN	NUMBER
  , l_transaction_temp_id   OUT	NOCOPY NUMBER
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
  )
  IS
  qty_tbl                       wms_Task_mgmt_pub.TASK_QTY_TBL_TYPE;
  l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_resultant_task_details      wms_Task_mgmt_pub.TASK_DETAIL_TBL_TYPE;
  l_resultant_tasks             wms_Task_mgmt_pub.TASK_TAB_TYPE;
  l_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN

   mydebug('inside split_mmtt_lpn  p_transaction_temp_id' || p_transaction_temp_id, 'split_mmtt_lpn');
   mydebug('inside split_mmtt_lpn  p_line_quantity' || p_line_quantity, 'split_mmtt_lpn');
   mydebug('inside split_mmtt_lpn  p_transaction_UOM' || p_transaction_UOM, 'split_mmtt_lpn');
   mydebug('inside split_mmtt_lpn  p_lpn_id' || p_lpn_id, 'split_mmtt_lpn');

   qty_tbl(1).quantity := p_line_quantity;
   qty_tbl(1).uom := p_transaction_UOM;

   IF WMS_CONTROL.G_CURRENT_RELEASE_LEVEL >= 120001 THEN

	   wms_picking_pkg.split_task(
		    p_source_transaction_number    => p_transaction_temp_id
	          , p_split_quantities             => qty_tbl
		  , p_commit                       => FND_API.G_FALSE
	          , x_resultant_tasks              => l_resultant_tasks
		  , x_resultant_task_details       => l_resultant_task_details
	          , x_return_status                => l_return_status
		  , x_msg_count                    => x_msg_count
	          , x_msg_data                     => x_msg_data
		  );

	   mydebug('l_resultant_tasks.COUNT' || l_resultant_tasks.COUNT , 'split_mmtt_lpn');
	   if( l_resultant_tasks.COUNT > 0 ) THEN
		mydebug('l_resultant_tasks(1).task_id ' || l_resultant_tasks(1).task_id, 'split_mmtt_lpn');
		l_transaction_temp_id := l_resultant_tasks(1).task_id;

		--Modified for bug 6717052
      update mtl_material_transactions_temp
		set transfer_lpn_id = p_lpn_id
		where transaction_temp_id = l_resultant_tasks(1).task_id;

		x_return_status := fnd_api.g_ret_sts_success;
	    ELSE
		l_transaction_temp_id := -9999;
		x_return_status := 'E';
	    END IF;
   END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (l_debug = 1) THEN
		mydebug('sqlerrm' || SQLERRM, 'split_mmtt_lpn');
		mydebug('sqlcode ' || SQLCODE, 'split_mmtt_lpn');
	END IF;
	--fnd_message.set_name('WMS', 'WMS_PRINT_LABEL_FAIL');
	fnd_msg_pub.ADD;
END split_mmtt_lpn;

PROCEDURE split_task( p_source_transaction_number IN NUMBER DEFAULT NULL ,
		      p_split_quantities IN wms_Task_mgmt_pub.TASK_QTY_TBL_TYPE ,
		      p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE ,
		      x_resultant_tasks OUT NOCOPY WMS_TASK_MGMT_PUB.task_tab_type ,
		      x_resultant_task_details OUT NOCOPY wms_Task_mgmt_pub.TASK_DETAIL_TBL_TYPE ,
		      x_return_status OUT NOCOPY VARCHAR2 ,
		      x_msg_count OUT NOCOPY NUMBER ,
		      x_msg_data OUT NOCOPY VARCHAR2 ) IS

        CURSOR mtlt_changed (p_ttemp_id IN NUMBER)
        IS
                SELECT  *
                FROM    mtl_transaction_lots_temp
                WHERE   transaction_temp_id = p_ttemp_id
                ORDER BY lot_number;
        l_mtlt_row MTL_TRANSACTION_LOTS_TEMP%ROWTYPE;
        --      l_split_uom_quantities               qty_changed_tbl_type;
        l_task_tbl_qty_count        NUMBER          := p_split_quantities.COUNT;
        l_decimal_precision         CONSTANT NUMBER := 5;
        l_task_tbl_primary_qty      NUMBER;
        l_task_tbl_transaction_qty  NUMBER;
        l_sum_tbl_transaction_qty   NUMBER := 0;
        l_sum_tbl_primary_qty       NUMBER := 0;
        l_new_mol_id                NUMBER;
        l_orig_mol_id               NUMBER;
        l_new_transaction_temp_id   NUMBER;
        l_new_transaction_header_id NUMBER;
        l_new_task_id               NUMBER;
        l_remaining_primary_qty     NUMBER := 0;
        l_remaining_transaction_qty NUMBER := 0;
        l_mol_num                   NUMBER;
        l_serial_control_code       NUMBER;
        l_lot_control_code          NUMBER;
        l_index                     NUMBER;
        l_new_tasks_output WMS_TASK_MGMT_PUB.task_tab_type;
        l_new_tasks_tbl WMS_TASK_MGMT_PUB.task_tab_type;
        x_task_table WMS_TASK_MGMT_PUB.task_tab_type;
        l_return_status          VARCHAR2(10);
        l_msg_count              NUMBER;
        l_msg_data               VARCHAR(200);
        l_validation_status      VARCHAR2(10);
        l_error_msg              VARCHAR2(1000);
        l_task_return_status     VARCHAR2(10);
        l_mmtt_return_status     VARCHAR2(1);
        l_wdt_return_status      VARCHAR2(1);
        l_lot_ser_return_status  VARCHAR2(1);
        l_serial_return_status   VARCHAR2(1);
        l_mtlt_transaction_qty   NUMBER;
        l_msnt_transaction_qty   NUMBER;
        l_val_task_ret_status    VARCHAR2(1);
        l_mmtt_inventory_item_id NUMBER;
        l_mmtt_task_status       NUMBER;
        l_mmtt_organization_id   NUMBER;
        l_split_uom_quantities WMS_TASK_MGMT_PUB.QTY_CHANGED_TBL_TYPE;
        l_val_qty_ret_status   VARCHAR2(1);
        l_invalid_task         EXCEPTION;
        l_invalid_quantities   EXCEPTION;
        l_unexpected_error     EXCEPTION;
        l_query_task_exception EXCEPTION;

	g_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
        IF g_debug = 1 THEN
                mydebug(  'In Split Task ', 'split_task');
        END IF;
        x_return_status := 'S';
        new_task_table.delete;
        /*validate_task( p_transaction_temp_id => p_source_transaction_number , x_return_status => x_return_status , x_error_msg => l_error_msg , x_msg_data => x_msg_data , x_msg_count => x_msg_count );
        IF g_debug                           = 1 THEN
                mydebug(  ' Validate task return status : '|| x_return_status);
        END IF;
        IF NVL(x_return_status,'E') <> 'S' THEN
                RAISE l_invalid_task;
        END IF;
	*/
        validate_quantities(
		p_transaction_temp_id => p_source_transaction_number ,
		p_split_quantities => p_split_quantities ,
		x_lot_control_code => l_lot_control_code ,
		x_serial_control_code => l_serial_control_code ,
		x_split_uom_quantities => l_split_uom_quantities ,
		x_return_status => x_return_status ,
		x_msg_data => x_msg_data ,
		x_msg_count => x_msg_count );
        IF NVL(x_return_status,'E')               <> 'S' THEN
                RAISE l_invalid_quantities;
        END IF;
        IF g_debug     = 1 THEN
                FOR i in l_split_uom_quantities.FIRST .. l_split_uom_quantities.LAST
                LOOP
                        mydebug(' l_split_uom_quantities('||i|| ').primary_quantity: '||l_split_uom_quantities(i).primary_quantity , 'split_task');
                        mydebug(' l_split_uom_quantities('||i|| ').transaction_quantity: '||l_split_uom_quantities(i).transaction_quantity, 'split_task');
                END LOOP;
        END IF;
        SAVEPOINT wms_split_task;
        IF g_debug = 1 THEN
                mydebug(' SAVEPOINT wms_split_task established', 'split_task');
        END IF;
        FOR i IN l_split_uom_quantities.FIRST .. l_split_uom_quantities.LAST
        LOOP
                SELECT  mtl_material_transactions_s.NEXTVAL
                INTO    l_new_transaction_header_id
                FROM    dual;
                SELECT  mtl_material_transactions_s.NEXTVAL
                INTO    l_new_transaction_temp_id
                FROM    dual;
                SELECT wms_dispatched_tasks_s.NEXTVAL INTO l_new_task_id FROM dual;
                IF g_debug = 1 THEN
                        mydebug(  ' Calling split_mmtt for Txn. temp id : '||p_source_transaction_number,'split_task');
                END IF;
                split_mmtt(
			p_orig_transaction_temp_id => p_source_transaction_number ,
			p_new_transaction_temp_id => l_new_transaction_temp_id ,
			p_new_transaction_header_id => l_new_transaction_header_id ,
			p_new_mol_id => l_orig_mol_id ,
			p_transaction_qty_to_split => l_split_uom_quantities(i).transaction_quantity ,
			p_primary_qty_to_split => l_split_uom_quantities(i).primary_quantity ,
			x_return_status => x_return_status ,
			x_msg_data => x_msg_data ,
			x_msg_count => x_msg_count );
                IF g_debug                             = 1 THEN
                        mydebug(  ' x_return_status : ' || x_return_status, 'split_task');
                END IF;
                IF NVL(x_return_status, 'E') <> 'S' THEN
                        IF g_debug            = 1 THEN
                                mydebug( ' Unable to split MMTT, unexpected error has occurred', 'split_task');
                        END IF;
                        RAISE l_unexpected_error;
                END IF;
                BEGIN
                        SELECT  status
                        INTO    l_mmtt_task_status
                        FROM    wms_dispatched_tasks
                        WHERE   transaction_temp_id = p_source_transaction_number;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        l_mmtt_task_status := -9999;
                        NULL;
                END;
                IF g_debug = 1 THEN
                        mydebug(   'l_mmtt_task_status :  '|| l_mmtt_task_status, 'split_task');
                END IF;
                --IF l_mmtt_task_status            = 2 THEN
                        split_wdt(
				p_new_task_id => l_new_task_id ,
				p_new_transaction_temp_id => l_new_transaction_temp_id ,
				p_new_mol_id => l_orig_mol_id ,
				p_orig_transaction_temp_id => p_source_transaction_number ,
				x_return_status => x_return_status ,
				x_msg_data => x_msg_data ,
				x_msg_count => x_msg_count );
                        IF g_debug               = 1 THEN
                                mydebug(  ' x_return_status : '||x_return_status, 'split_task');
                        END IF;
                        IF NVL(x_return_status, 'E') <> 'S' THEN
                                IF g_debug            = 1 THEN
                                        mydebug( ' Unable to split WDT, unexpected error has occurred', 'split_task');
                                END IF;
                                RAISE l_unexpected_error;
                        END IF;
                --END IF;
                IF (l_lot_control_code = 2 AND l_serial_control_code IN (2,5)) OR (l_lot_control_code = 2 AND l_serial_control_code NOT IN (2,5)) THEN
                        split_lot_serial(
				p_source_transaction_number ,
				l_new_transaction_temp_id ,
				l_split_uom_quantities(i).transaction_quantity ,
				l_split_uom_quantities(i).primary_quantity ,
				l_mmtt_inventory_item_id ,
				l_mmtt_organization_id ,
				x_return_status ,
				x_msg_data ,
				x_msg_count );

                        IF g_debug = 1 THEN
                                mydebug(  ' x_return_status : ' || x_return_status, 'split_task');
                        END IF;
                        IF NVL(x_return_status, 'E') <> 'S' THEN
                                IF g_debug            = 1 THEN
                                        mydebug( ' Was not able to split lot serial', 'split_task');
                                END IF;
                                RAISE l_unexpected_error;
                        END IF;
                ELSIF l_lot_control_code                         = 1 AND l_serial_control_code IN (2,5) THEN
                        split_serial(
				p_orig_transaction_temp_id => p_source_transaction_number ,
				p_new_transaction_temp_id => l_new_transaction_temp_id ,
				p_transaction_qty_to_split => l_split_uom_quantities(i).transaction_quantity ,
				p_primary_qty_to_split => l_split_uom_quantities(i).primary_quantity ,
				p_inventory_item_id => l_mmtt_inventory_item_id ,
				p_organization_id => l_mmtt_organization_id ,
				x_return_status => x_return_status ,
				x_msg_data => x_msg_data ,
				x_msg_count => x_msg_count );

                        IF g_debug                               = 1 THEN
                                mydebug(  ' x_return_status : '||x_return_status, 'split_task');
                        END IF;
                        IF NVL(x_return_status, 'E') <> 'S' THEN
                                IF g_debug            = 1 THEN
                                        mydebug( ' Was not able to split serials', 'split_task');
                                END IF;
                                RAISE l_unexpected_error;
                        END IF;
                END IF;
                -- Update the original row
                BEGIN
                        UPDATE mtl_material_transactions_temp
                        SET     primary_quantity     = primary_quantity     - l_split_uom_quantities(i).primary_quantity     ,
                                transaction_quantity = transaction_quantity - l_split_uom_quantities(i).transaction_quantity ,
                                last_updated_by      = FND_GLOBAL.USER_ID
                        WHERE   transaction_temp_id  = p_source_transaction_number;
                EXCEPTION
                WHEN OTHERS THEN
                        IF g_debug = 1 THEN
                                mydebug(  ' Error Code : '|| SQLCODE || ' Error Message :'||SUBSTR(SQLERRM,1,100), 'split_task');
                        END IF;
                        RAISE l_unexpected_error;
                END;
                IF g_debug = 1 THEN
                        mydebug( ' Updated original txn. temp id :'||p_source_transaction_number, 'split_task');
                END IF;
                l_index                                     := new_task_table.count + 1;
                new_task_table(l_index).transaction_temp_id := l_new_transaction_temp_id;
        END LOOP;
        l_index                                     := new_task_table.count + 1;
        new_task_table(l_index).transaction_temp_id := p_source_transaction_number;
        IF g_debug                                   = 1 THEN
                mydebug( ' Split done sucessfully for txn. temp id :'||p_source_transaction_number, 'split_task');
        END IF;
        IF g_debug = 1 THEN
                mydebug( ' lot control code :'||l_lot_control_code ||  ' serial control code : '|| l_serial_control_code, 'split_task');
        END IF;
        IF g_debug = 1 THEN
                mydebug( '***********New Task Table***********', 'split_task');
                mydebug( '*** Transaction temp id ***', 'split_task');
                FOR i IN new_task_table.FIRST .. new_task_table.LAST
                LOOP
                        mydebug(   '   '|| new_task_table(i).transaction_temp_id, 'split_task');
                END LOOP;
        END IF;
        IF g_debug = 1 THEN
                mydebug( 'Inserting Lot/Serial details of the new tasks in X_RESULTANT_TASK_DETAILS', 'split_task');
        END IF;
        IF l_lot_control_code = 2 THEN
                FOR i        IN new_task_table.FIRST .. new_task_table.LAST
                LOOP
                        OPEN mtlt_changed(new_task_table(i).transaction_temp_id);
                        LOOP
                                FETCH mtlt_changed INTO l_mtlt_row;
                                EXIT
                        WHEN mtlt_changed%NOTFOUND;
                                l_index                                                    := x_resultant_task_details.count + 1;
                                x_resultant_task_details(l_index).parent_task_id           := l_mtlt_row.transaction_temp_id;
                                x_resultant_task_details(l_index).lot_number               := l_mtlt_row.lot_number;
                                x_resultant_task_details(l_index).lot_expiration_date      := l_mtlt_row.lot_expiration_date;
                                x_resultant_task_details(l_index).lot_primary_quantity     := l_mtlt_row.primary_quantity;
                                x_resultant_task_details(l_index).lot_transaction_quantity := l_mtlt_row.transaction_quantity;
                                IF l_mtlt_row.serial_transaction_temp_id IS NOT NULL THEN
                                        x_resultant_task_details(l_index).number_of_serials := l_mtlt_row.primary_quantity;
                                        SELECT  MIN(FM_SERIAL_NUMBER) ,
                                                MAX(FM_SERIAL_NUMBER) ,
                                                MAX(status_id)
                                        INTO    x_resultant_task_details(l_index).from_serial_number ,
                                                x_resultant_task_details(l_index).to_serial_number   ,
                                                x_resultant_task_details(l_index).serial_status_id
                                        FROM    mtl_serial_numbers_temp
                                        WHERE   transaction_temp_id = l_mtlt_row.serial_transaction_temp_id;
                                END IF;
                        END LOOP;
                        CLOSE mtlt_changed;
                END LOOP;
        ELSIF l_serial_control_code IN (2,5) THEN
                FOR i               IN new_task_table.FIRST .. new_task_table.LAST
                LOOP
                        l_index                                          := x_resultant_task_details.count + 1;
                        x_resultant_task_details(l_index).parent_task_id := new_task_table(i).transaction_temp_id;
                        SELECT  MIN(FM_SERIAL_NUMBER) ,
                                MAX(FM_SERIAL_NUMBER) ,
                                MAX(status_id)        ,
                                COUNT(*)
                        INTO    x_resultant_task_details(l_index).from_serial_number ,
                                x_resultant_task_details(l_index).to_serial_number   ,
                                x_resultant_task_details(l_index).serial_status_id   ,
                                x_resultant_task_details(l_index).number_of_serials
                        FROM    mtl_serial_numbers_temp
                        WHERE   transaction_temp_id = new_task_table(i).transaction_temp_id;
                END LOOP;
        END IF;
        IF g_debug                                = 1 THEN
                IF x_resultant_task_details.COUNT > 0 THEN
                        mydebug( 'Task Id    Lot    quantity  fm_serial   to_serial   num_of_serials', 'split_task');
                        FOR i IN x_resultant_task_details.FIRST .. x_resultant_task_details.LAST
                        LOOP
                           mydebug(x_resultant_task_details(i).parent_task_id ||' '|| x_resultant_task_details(i).lot_number ||' '||x_resultant_task_details(i).lot_primary_quantity, 'split_task');
			   mydebug(x_resultant_task_details(i).from_serial_number||' '||x_resultant_task_details(i).to_serial_number||' '||x_resultant_task_details(i).number_of_serials, 'split_task');
                        END LOOP;
                ELSE
                        mydebug('Table x_resultant_task_details is empty, item is not serial or lot controlled', 'split_task');
                END IF;
        END IF;
        FOR i IN new_task_table.FIRST .. new_task_table.LAST
        LOOP
		x_resultant_tasks(i).task_id := new_task_table(i).transaction_temp_id;
        END LOOP;


        IF g_debug                         = 1 THEN
                IF x_resultant_tasks.COUNT > 0 THEN
                        mydebug( 'Task Id   item_id  sub   locator   Qty', 'split_task');
                        FOR i IN x_resultant_tasks.FIRST .. x_resultant_tasks.LAST
                        LOOP
                           mydebug( x_resultant_tasks(i).task_id ||' '||x_resultant_tasks(i).inventory_item_id||' '||x_resultant_tasks(i).subinventory||' '||x_resultant_tasks(i).locator||' '||x_resultant_tasks(i).transaction_quantity, 'split_task');
                        END LOOP;
                ELSE
                        mydebug( 'Table x_resultant_tasks is empty', 'split_task');
                END IF;
        END IF;
        IF p_commit        = FND_API.G_TRUE THEN
                IF g_debug = 1 THEN
                        mydebug( ' p_commit is TRUE, so COMMITING the transactions.', 'split_task');
                END IF;
                COMMIT;
        ELSE
                IF g_debug = 1 THEN
                        mydebug( ' p_commit is FALSE, so not COMMITING the transactions.', 'split_task');
                END IF;
        END IF;
        x_return_status := 'S';
EXCEPTION
WHEN OTHERS THEN
        IF g_debug = 1 THEN
                mydebug('EXCEPTION BLOCK  : Unexpected error has occured, ROLLING BACK THE TRANSACTIONS', 'split_task');
        END IF;
        x_return_status := 'E';
        ROLLBACK TO wms_split_task;
        fnd_message.set_name('WMS', 'WMS_UNEXPECTED_ERROR');
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status                  := 'E';
        IF g_debug                        = 1 THEN
                mydebug(  'EXCEPTION BLOCK  :  Error Code : '|| SQLCODE || 'EXCEPTION BLOCK  :  Error Message :'||SQLERRM, 'split_task');
        END IF;
END split_task;

PROCEDURE validate_quantities( p_transaction_temp_id IN NUMBER ,
			       p_split_quantities IN wms_Task_mgmt_pub.task_qty_tbl_type ,
			       x_lot_control_code OUT NOCOPY NUMBER ,
			       x_serial_control_code OUT NOCOPY NUMBER ,
			       x_split_uom_quantities OUT NOCOPY wms_Task_mgmt_pub.qty_changed_tbl_type ,
			       x_return_status OUT NOCOPY VARCHAR2 ,
			       x_msg_data OUT NOCOPY VARCHAR2 ,
			       x_msg_count OUT NOCOPY VARCHAR2 ) IS

        l_mmtt_inventory_item_id     NUMBER;
        l_mmtt_primary_quantity      NUMBER;
        l_mmtt_transaction_quantity  NUMBER;
        l_mmtt_transaction_uom_code  NUMBER;
        l_mmtt_organization_id       NUMBER;
        l_mmtt_transaction_uom       VARCHAR2(3);
        l_mmtt_item_primary_uom_code VARCHAR2(3);
        l_lot_control_code           NUMBER;
        l_serial_control_code        NUMBER;
        l_decimal_precision          CONSTANT NUMBER := 5;
        l_mtlt_transaction_qty       NUMBER          := 0;
        l_msnt_transaction_qty       NUMBER          := 0;
        l_task_tbl_transaction_qty   NUMBER          := 0;
        l_task_tbl_primary_qty       NUMBER          := 0;
        l_sum_tbl_transaction_qty    NUMBER          := 0;
        l_sum_tbl_primary_qty        NUMBER          := 0;
        l_remaining_primary_qty      NUMBER          := 0;
        l_remaining_transaction_qty  NUMBER          := 0;
	g_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
        x_return_status := 'E';
        IF g_debug       = 1 THEN
                mydebug( 'Entered','validate_quantities');
        END IF;
        IF p_split_quantities.COUNT = 0 THEN
                x_return_status    := 'E';
                IF g_debug          = 1 THEN
                        mydebug( 'Quantities table is empty, exiting', 'validate_quantities');
                END IF;
                RETURN;
        END IF;
        SELECT  transaction_uom       ,
                inventory_item_id     ,
                primary_quantity      ,
                transaction_quantity  ,
                item_primary_uom_code ,
                transaction_uom       ,
                organization_id
        INTO    l_mmtt_transaction_uom       ,
                l_mmtt_inventory_item_id     ,
                l_mmtt_primary_quantity      ,
                l_mmtt_transaction_quantity  ,
                l_mmtt_item_primary_uom_code ,
                l_mmtt_transaction_uom       ,
                l_mmtt_organization_id
        FROM    mtl_material_transactions_temp
        WHERE   transaction_temp_id = p_transaction_temp_id;
        SELECT  lot_control_code ,
                serial_number_control_code
        INTO    l_lot_control_code ,
                l_serial_control_code
        FROM    mtl_system_items_b
        WHERE   inventory_item_id = l_mmtt_inventory_item_id
            AND organization_id   = l_mmtt_organization_id;
        x_lot_control_code       := l_lot_control_code;
        x_serial_control_code    := l_serial_control_code;
        IF g_debug                = 1 THEN
                FOR i            IN p_split_quantities.FIRST .. p_split_quantities.LAST
                LOOP
                        mydebug(' Inside For loop i = ' || i ||' Task :'||p_transaction_temp_id||' Quantity : '||p_split_quantities(i).quantity || ' Suggested UOM :' || p_split_quantities(i).uom, 'validate_quantities');
			mydebug(' MMTT transaction UOM :' ||l_mmtt_transaction_uom, 'validate_quantities');
                END LOOP;
        END IF;
        FOR i IN p_split_quantities.FIRST .. p_split_quantities.LAST
        LOOP
                IF p_split_quantities(i).uom IS NULL THEN
                        IF g_debug = 1 THEN
                                mydebug( 'UOM cannot be passed as NULL', 'validate_quantities');
                        END IF;
                        x_return_status := 'E';
                        RETURN;
                END IF;
                --Bug 6924526
                /*IF RTRIM(LTRIM(p_split_quantities(i).uom)) NOT IN (l_mmtt_item_primary_uom_code,l_mmtt_transaction_uom) THEN
                        x_return_status                        := 'E';
                        IF g_debug                              = 1 THEN
                                mydebug( 'UOM validation failed, only primary or transaction UOM allowed :', 'validate_quantities');
                        END IF;
                        RETURN;
                END IF;*/
                -- All UOMs are same
                IF l_mmtt_transaction_uom                               = l_mmtt_item_primary_uom_code THEN
                        x_split_uom_quantities(i).primary_quantity     := p_split_quantities(i).quantity;
                        x_split_uom_quantities(i).transaction_quantity := p_split_quantities(i).quantity;
                ELSE
                        IF l_mmtt_transaction_uom = p_split_quantities(i).uom THEN
                                IF g_debug        = 1 THEN
                                        mydebug( ' mmtt transaction UOM is same as UOM in quantity table', 'validate_quantities');
                                END IF;
                                l_task_tbl_transaction_qty                     := p_split_quantities(i).quantity;
                                x_split_uom_quantities(i).transaction_quantity := p_split_quantities(i).quantity;
                        ELSE
                                IF g_debug = 1 THEN
                                        mydebug( ' mmtt transaction UOM quantity table UOM are not same, calling inv_convert.inv_um_convert with :', 'validate_quantities');
                                        mydebug(  ' item_id  : '||l_mmtt_inventory_item_id, 'validate_quantities');
                                        mydebug(  ' PRECISION : '|| l_decimal_precision, 'validate_quantities');
                                        mydebug( ' from_quantity :'|| p_split_quantities(i).quantity, 'validate_quantities');
                                        mydebug( ' from_unit :'||p_split_quantities(i).uom, 'validate_quantities');
                                        mydebug( ' to_unit :'||l_mmtt_transaction_uom, 'validate_quantities');
                                END IF;
                                l_task_tbl_transaction_qty   := inv_convert.inv_um_convert(
									item_id => l_mmtt_inventory_item_id ,
									PRECISION => l_decimal_precision ,
									from_quantity => p_split_quantities(i).quantity ,
									from_unit => p_split_quantities(i).uom ,
									to_unit => l_mmtt_transaction_uom ,
									from_name => NULL ,
									to_name => NULL );

                                IF l_task_tbl_transaction_qty = -9999 THEN
                                        IF g_debug            = 1 THEN
                                                mydebug( ' No conversion defined from :'||p_split_quantities(i).uom|| ' to :'|| l_mmtt_transaction_uom || ' , or UOM does not exist.', 'validate_quantities');
                                        END IF;
                                        x_return_status := 'E';
                                        RETURN;
                                END IF;
                                x_split_uom_quantities(i).transaction_quantity := l_task_tbl_transaction_qty;
                        END IF;
                        IF l_mmtt_item_primary_uom_code = p_split_quantities(i).uom THEN
                                IF g_debug              = 1 THEN
                                        mydebug( ' primary UOM is same as UOM in quantity table', 'validate_quantities');
                                END IF;
                                l_task_tbl_primary_qty                     := p_split_quantities(i).quantity;
                                x_split_uom_quantities(i).primary_quantity := p_split_quantities(i).quantity;
                        ELSE
                                IF g_debug = 1 THEN
                                        mydebug( ' primary UOM not same as UOM in quantity table', 'validate_quantities');
                                        mydebug(  ' For primary quantity ', 'validate_quantities');
                                        mydebug(  ' item_id  : '||l_mmtt_inventory_item_id, 'validate_quantities');
                                        mydebug(  ' PRECISION : '|| l_decimal_precision, 'validate_quantities');
                                        mydebug( ' from_quantity :'|| p_split_quantities(i).quantity, 'validate_quantities');
                                        mydebug( ' from_unit :'||p_split_quantities(i).uom, 'validate_quantities');
                                        mydebug( ' to_unit :'||l_mmtt_transaction_uom, 'validate_quantities');
                                END IF;
                                l_task_tbl_primary_qty := inv_convert.inv_um_convert(
									item_id => l_mmtt_inventory_item_id ,
									PRECISION => l_decimal_precision ,
									from_quantity => p_split_quantities(i).quantity ,
									from_unit => p_split_quantities(i).uom ,
									to_unit => l_mmtt_item_primary_uom_code ,
									from_name => NULL ,
									to_name => NULL);

                                IF l_task_tbl_transaction_qty = -9999 THEN
                                        IF g_debug            = 1 THEN
                                                mydebug( ' No conversion defined from :'||p_split_quantities(i).uom|| ' to :'|| l_mmtt_transaction_uom || ' , or UOM does not exist.', 'validate_quantities');
                                        END IF;
                                        x_return_status := 'E';
                                        RETURN;
                                END IF;
                                x_split_uom_quantities(i).primary_quantity := l_task_tbl_primary_qty;
                        END IF;
                END IF;
                IF x_split_uom_quantities(i).transaction_quantity <= 0 OR x_split_uom_quantities(i).primary_quantity <= 0 THEN
                        IF g_debug                                 = 1 THEN
                                mydebug('Negative and zero quantities are not allowed in quantities table, exiting.', 'validate_quantities');
                        END IF;
                        x_return_status := 'E';
                        RETURN;
                END IF;
                l_sum_tbl_transaction_qty := l_sum_tbl_transaction_qty + x_split_uom_quantities(i).transaction_quantity;
                l_sum_tbl_primary_qty     := l_sum_tbl_primary_qty     + x_split_uom_quantities(i).primary_quantity;
        END LOOP;
        IF g_debug = 1 THEN
                mydebug( 'l_sum_tbl_transaction_qty : '||l_sum_tbl_transaction_qty, 'validate_quantities');
                mydebug( 'l_sum_tbl_primary_qty : '||l_sum_tbl_primary_qty, 'validate_quantities');
        END IF;
        IF l_sum_tbl_transaction_qty >= l_mmtt_transaction_quantity THEN
                IF g_debug            = 1 THEN
                        mydebug('Sum of qty table :'|| l_sum_tbl_transaction_qty || 'should be less than the mmtt line quantity:'||l_mmtt_transaction_quantity , 'validate_quantities');
                END IF;
                x_return_status := 'E';
                RETURN;
        END IF;
        --Validate lot/serial quantity
        IF g_debug = 1 THEN
                mydebug('Validating lot/serial if allocations are present', 'validate_quantities');
               mydebug( 'lot_control_code : '|| l_lot_control_code, 'validate_quantities');
                mydebug( 'serial_control_code : '|| l_serial_control_code, 'validate_quantities');
        END IF;
        IF l_lot_control_code = 2 AND l_serial_control_code IN (2,5) THEN
                BEGIN
                        --Lot quantity
                        SELECT  sum(transaction_quantity)
                        INTO    l_mtlt_transaction_qty
                        FROM    mtl_transaction_lots_temp
                        WHERE   transaction_temp_id = p_transaction_temp_id;
                        IF g_debug                  = 1 THEN
                                mydebug( 'l_mtlt_transaction_qty : '||l_mtlt_transaction_qty|| ' l_mmtt_transaction_quantity : '||l_mmtt_transaction_quantity, 'validate_quantities');
                        END IF;
                        IF l_mtlt_transaction_qty <> l_mmtt_transaction_quantity THEN
                                x_return_status   := 'E';
                                IF g_debug         = 1 THEN
                                        mydebug('Mismatch in MMTT and MTLT quantity', 'validate_quantities');
                                END IF;
                                RETURN;
                        END IF;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := 'E';
                        IF g_debug       = 1 THEN
                                mydebug('No Data Found : Mismatch in MMTT and MTLT quantity', 'validate_quantities');
                        END IF;
                        RETURN;
                END;
                BEGIN
                        --serial quantity
                        SELECT  sum(1)
                        INTO    l_msnt_transaction_qty
                        FROM    mtl_serial_numbers_temp
                        WHERE   transaction_temp_id IN
                                (SELECT serial_transaction_temp_id
                                FROM    mtl_transaction_lots_temp
                                WHERE   transaction_temp_id = p_transaction_temp_id
                                );
                        IF l_msnt_transaction_qty <> l_mmtt_transaction_quantity THEN
                                x_return_status   := 'E';
                                IF g_debug         = 1 THEN
                                        mydebug('Mismatch in MMTT and MSNT quantity', 'validate_quantities');
                                END IF;
                                RETURN;
                        END IF;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := 'E';
                        IF g_debug       = 1 THEN
                                mydebug('No Data Found :Mismatch in MMTT and MSNT quantity', 'validate_quantities');
                        END IF;
                        RETURN;
                END;
        ELSIF l_lot_control_code = 2 AND l_serial_control_code NOT IN (2,5) THEN
                BEGIN
                        --Lot quantity
                        SELECT  sum(transaction_quantity)
                        INTO    l_mtlt_transaction_qty
                        FROM    mtl_transaction_lots_temp
                        WHERE   transaction_temp_id = p_transaction_temp_id;
                        IF l_mtlt_transaction_qty  <> l_mmtt_transaction_quantity THEN
                                x_return_status    := 'E';
                                IF g_debug          = 1 THEN
                                        mydebug('Mismatch in MMTT and MTLT quantity', 'validate_quantities');
                                END IF;
                                RETURN;
                        END IF;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := 'E';
                        IF g_debug       = 1 THEN
                                mydebug('No Data Found :Mismatch in MMTT and MTLT quantity', 'validate_quantities');
                        END IF;
                        RETURN;
                END;
        ELSIF l_lot_control_code = 1 AND l_serial_control_code IN (2,5) THEN
                BEGIN
                        IF g_debug = 1 THEN
                                mydebug('Checking for MMTT and MSNT quantity', 'validate_quantities');
                        END IF;
                        --Serial quantity
                        SELECT  sum(1)
                        INTO    l_msnt_transaction_qty
                        FROM    mtl_serial_numbers_temp
                        WHERE   transaction_temp_id = p_transaction_temp_id;
                        IF l_msnt_transaction_qty  <> l_mmtt_transaction_quantity THEN
                                x_return_status    := 'E';
                                IF g_debug          = 1 THEN
                                        mydebug('Mismatch in MMTT and MSNT quantity', 'validate_quantities');
                                END IF;
                                RETURN;
                        END IF;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := 'E';
                        IF g_debug       = 1 THEN
                                mydebug('No Data Found :Mismatch in MMTT and MSNT quantity', 'validate_quantities');
                        END IF;
                        RETURN;
                END;
        END IF;
        IF g_debug = 1 THEN
                mydebug( 'l_mmtt_primary_quantity  -  l_sum_tbl_primary_qty '||l_mmtt_primary_quantity ||  ' - '||l_sum_tbl_transaction_qty, 'validate_quantities');
        END IF;
        x_return_status := 'S';
EXCEPTION
WHEN OTHERS THEN
        x_return_status := 'E';
END validate_quantities;

PROCEDURE split_mmtt( p_orig_transaction_temp_id IN NUMBER ,
		      p_new_transaction_temp_id IN NUMBER ,
		      p_new_transaction_header_id IN NUMBER ,
		      p_new_mol_id IN NUMBER ,
		      p_transaction_qty_to_split IN NUMBER ,
		      p_primary_qty_to_split IN NUMBER ,
		      x_return_status OUT NOCOPY VARCHAR2 ,
		      x_msg_data OUT NOCOPY VARCHAR2 ,
		      x_msg_count OUT NOCOPY VARCHAR2 ) IS

        l_sysdate DATE                := SYSDATE;
	g_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
        x_return_status := 'E';
        IF g_debug       = 1 THEN
                mydebug(  ' Entered ', 'split_mmtt');
        END IF;
        INSERT
        INTO    mtl_material_transactions_temp
                (
                        currency_conversion_date       ,
                        shipment_number                ,
                        org_cost_group_id              ,
                        cost_type_id                   ,
                        transaction_status             ,
                        standard_operation_id          ,
                        task_priority                  ,
                        wms_task_type                  ,
                        parent_line_id                 ,
                        source_lot_number              ,
                        transfer_cost_group_id         ,
                        lpn_id                         ,
                        transfer_lpn_id                ,
                        wms_task_status                ,
                        content_lpn_id                 ,
                        container_item_id              ,
                        cartonization_id               ,
                        pick_slip_date                 ,
                        rebuild_item_id                ,
                        rebuild_serial_number          ,
                        rebuild_activity_id            ,
                        rebuild_job_name               ,
                        organization_type              ,
                        transfer_organization_type     ,
                        owning_organization_id         ,
                        owning_tp_type                 ,
                        xfr_owning_organization_id     ,
                        transfer_owning_tp_type        ,
                        planning_organization_id       ,
                        planning_tp_type               ,
                        xfr_planning_organization_id   ,
                        transfer_planning_tp_type      ,
                        secondary_uom_code             ,
                        secondary_transaction_quantity ,
                        allocated_lpn_id               ,
                        schedule_number                ,
                        scheduled_flag                 ,
                        class_code                     ,
                        schedule_group                 ,
                        build_sequence                 ,
                        bom_revision                   ,
                        routing_revision               ,
                        bom_revision_date              ,
                        routing_revision_date          ,
                        alternate_bom_designator       ,
                        alternate_routing_designator   ,
                        transaction_batch_id           ,
                        transaction_batch_seq          ,
                        operation_plan_id              ,
                        intransit_account              ,
                        fob_point                      ,
                        transaction_header_id          ,
                        transaction_temp_id            ,
                        source_code                    ,
                        source_line_id                 ,
                        transaction_mode               ,
                        lock_flag                      ,
                        last_update_date               ,
                        last_updated_by                ,
                        creation_date                  ,
                        created_by                     ,
                        last_update_login              ,
                        request_id                     ,
                        program_application_id         ,
                        program_id                     ,
                        program_update_date            ,
                        inventory_item_id              ,
                        revision                       ,
                        organization_id                ,
                        subinventory_code              ,
                        locator_id                     ,
                        transaction_quantity           ,
                        primary_quantity               ,
                        transaction_uom                ,
                        transaction_cost               ,
                        transaction_type_id            ,
                        transaction_action_id          ,
                        transaction_source_type_id     ,
                        transaction_source_id          ,
                        transaction_source_name        ,
                        transaction_date               ,
                        acct_period_id                 ,
                        distribution_account_id        ,
                        transaction_reference          ,
                        requisition_line_id            ,
                        requisition_distribution_id    ,
                        reason_id                      ,
                        lot_number                     ,
                        lot_expiration_date            ,
                        serial_number                  ,
                        receiving_document             ,
                        demand_id                      ,
                        rcv_transaction_id             ,
                        move_transaction_id            ,
                        completion_transaction_id      ,
                        wip_entity_type                ,
                        schedule_id                    ,
                        repetitive_line_id             ,
                        employee_code                  ,
                        primary_switch                 ,
                        schedule_update_code           ,
                        setup_teardown_code            ,
                        item_ordering                  ,
                        negative_req_flag              ,
                        operation_seq_num              ,
                        picking_line_id                ,
                        trx_source_line_id             ,
                        trx_source_delivery_id         ,
                        physical_adjustment_id         ,
                        cycle_count_id                 ,
                        rma_line_id                    ,
                        customer_ship_id               ,
                        currency_code                  ,
                        currency_conversion_rate       ,
                        currency_conversion_type       ,
                        ship_to_location               ,
                        move_order_header_id           ,
                        serial_allocated_flag          ,
                        trx_flow_header_id             ,
                        logical_trx_type_code          ,
                        original_transaction_temp_id   ,
                        vendor_lot_number              ,
                        encumbrance_account            ,
                        encumbrance_amount             ,
                        transfer_cost                  ,
                        transportation_cost            ,
                        transportation_account         ,
                        freight_code                   ,
                        containers                     ,
                        waybill_airbill                ,
                        expected_arrival_date          ,
                        transfer_subinventory          ,
                        transfer_organization          ,
                        transfer_to_location           ,
                        new_average_cost               ,
                        value_change                   ,
                        percentage_change              ,
                        material_allocation_temp_id    ,
                        demand_source_header_id        ,
                        demand_source_line             ,
                        demand_source_delivery         ,
                        item_segments                  ,
                        item_description               ,
                        item_trx_enabled_flag          ,
                        item_location_control_code     ,
                        item_restrict_subinv_code      ,
                        item_restrict_locators_code    ,
                        item_revision_qty_control_code ,
                        item_primary_uom_code          ,
                        item_uom_class                 ,
                        item_shelf_life_code           ,
                        item_shelf_life_days           ,
                        item_lot_control_code          ,
                        item_serial_control_code       ,
                        item_inventory_asset_flag      ,
                        allowed_units_lookup_code      ,
                        department_id                  ,
                        department_code                ,
                        wip_supply_type                ,
                        supply_subinventory            ,
                        supply_locator_id              ,
                        valid_subinventory_flag        ,
                        valid_locator_flag             ,
                        locator_segments               ,
                        current_locator_control_code   ,
                        number_of_lots_entered         ,
                        wip_commit_flag                ,
                        next_lot_number                ,
                        lot_alpha_prefix               ,
                        next_serial_number             ,
                        serial_alpha_prefix            ,
                        shippable_flag                 ,
                        posting_flag                   ,
                        required_flag                  ,
                        process_flag                   ,
                        ERROR_CODE                     ,
                        error_explanation              ,
                        attribute_category             ,
                        attribute1                     ,
                        attribute2                     ,
                        attribute3                     ,
                        attribute4                     ,
                        attribute5                     ,
                        attribute6                     ,
                        attribute7                     ,
                        attribute8                     ,
                        attribute9                     ,
                        attribute10                    ,
                        attribute11                    ,
                        attribute12                    ,
                        attribute13                    ,
                        attribute14                    ,
                        attribute15                    ,
                        movement_id                    ,
                        reservation_quantity           ,
                        shipped_quantity               ,
                        transaction_line_number        ,
                        task_id                        ,
                        to_task_id                     ,
                        source_task_id                 ,
                        project_id                     ,
                        source_project_id              ,
                        pa_expenditure_org_id          ,
                        to_project_id                  ,
                        expenditure_type               ,
                        final_completion_flag          ,
                        transfer_percentage            ,
                        transaction_sequence_id        ,
                        material_account               ,
                        material_overhead_account      ,
                        resource_account               ,
                        outside_processing_account     ,
                        overhead_account               ,
                        flow_schedule                  ,
                        cost_group_id                  ,
                        demand_class                   ,
                        qa_collection_id               ,
                        kanban_card_id                 ,
                        overcompletion_transaction_qty ,
                        overcompletion_primary_qty     ,
                        overcompletion_transaction_id  ,
                        end_item_unit_number           ,
                        scheduled_payback_date         ,
                        line_type_code                 ,
                        parent_transaction_temp_id     ,
                        put_away_strategy_id           ,
                        put_away_rule_id               ,
                        pick_strategy_id               ,
                        pick_rule_id                   ,
                        move_order_line_id             ,
                        task_group_id                  ,
                        pick_slip_number               ,
                        reservation_id                 ,
                        common_bom_seq_id              ,
                        common_routing_seq_id          ,
                        ussgl_transaction_code
                )
        SELECT  currency_conversion_date       ,
                shipment_number                ,
                org_cost_group_id              ,
                cost_type_id                   ,
                transaction_status             ,
                standard_operation_id          ,
                task_priority                  ,
                wms_task_type                  ,
                parent_line_id                 ,
                source_lot_number              ,
                transfer_cost_group_id         ,
                lpn_id                         ,
                transfer_lpn_id                ,
                wms_task_status                ,
                content_lpn_id                 ,
                container_item_id              ,
                cartonization_id               ,
                pick_slip_date                 ,
                rebuild_item_id                ,
                rebuild_serial_number          ,
                rebuild_activity_id            ,
                rebuild_job_name               ,
                organization_type              ,
                transfer_organization_type     ,
                owning_organization_id         ,
                owning_tp_type                 ,
                xfr_owning_organization_id     ,
                transfer_owning_tp_type        ,
                planning_organization_id       ,
                planning_tp_type               ,
                xfr_planning_organization_id   ,
                transfer_planning_tp_type      ,
                secondary_uom_code             ,
                secondary_transaction_quantity ,
                allocated_lpn_id               ,
                schedule_number                ,
                scheduled_flag                 ,
                class_code                     ,
                schedule_group                 ,
                build_sequence                 ,
                bom_revision                   ,
                routing_revision               ,
                bom_revision_date              ,
                routing_revision_date          ,
                alternate_bom_designator       ,
                alternate_routing_designator   ,
                transaction_batch_id           ,
                transaction_batch_seq          ,
                operation_plan_id              ,
                intransit_account              ,
                fob_point                      ,
                p_new_transaction_header_id --TRANSACTION_HEADER_ID
                ,
                p_new_transaction_temp_id --TRANSACTION_TEMP_ID
                ,
                source_code      ,
                source_line_id   ,
                transaction_mode ,
                lock_flag        ,
                l_sysdate --LAST_UPDATE_DATE
                ,
                FND_GLOBAL.USER_ID ,
                l_sysdate --CREATION_DATE
                ,
                FND_GLOBAL.USER_ID     ,
                last_update_login      ,
                request_id             ,
                program_application_id ,
                program_id             ,
                program_update_date    ,
                inventory_item_id      ,
                revision               ,
                organization_id        ,
                subinventory_code      ,
                locator_id             ,
                p_transaction_qty_to_split --TRANSACTION_QUANTITY
                ,
                p_primary_qty_to_split --PRIMARY_QUANTITY
                ,
                transaction_uom                ,
                transaction_cost               ,
                transaction_type_id            ,
                transaction_action_id          ,
                transaction_source_type_id     ,
                transaction_source_id          ,
                transaction_source_name        ,
                transaction_date               ,
                acct_period_id                 ,
                distribution_account_id        ,
                transaction_reference          ,
                requisition_line_id            ,
                requisition_distribution_id    ,
                reason_id                      ,
                lot_number                     ,
                lot_expiration_date            ,
                serial_number                  ,
                receiving_document             ,
                demand_id                      ,
                rcv_transaction_id             ,
                move_transaction_id            ,
                completion_transaction_id      ,
                wip_entity_type                ,
                schedule_id                    ,
                repetitive_line_id             ,
                employee_code                  ,
                primary_switch                 ,
                schedule_update_code           ,
                setup_teardown_code            ,
                item_ordering                  ,
                negative_req_flag              ,
                operation_seq_num              ,
                picking_line_id                ,
                trx_source_line_id             ,
                trx_source_delivery_id         ,
                physical_adjustment_id         ,
                cycle_count_id                 ,
                rma_line_id                    ,
                customer_ship_id               ,
                currency_code                  ,
                currency_conversion_rate       ,
                currency_conversion_type       ,
                ship_to_location               ,
                move_order_header_id           ,
                serial_allocated_flag          ,
                trx_flow_header_id             ,
                logical_trx_type_code          ,
                original_transaction_temp_id   ,
                vendor_lot_number              ,
                encumbrance_account            ,
                encumbrance_amount             ,
                transfer_cost                  ,
                transportation_cost            ,
                transportation_account         ,
                freight_code                   ,
                containers                     ,
                waybill_airbill                ,
                expected_arrival_date          ,
                transfer_subinventory          ,
                transfer_organization          ,
                transfer_to_location           ,
                new_average_cost               ,
                value_change                   ,
                percentage_change              ,
                material_allocation_temp_id    ,
                demand_source_header_id        ,
                demand_source_line             ,
                demand_source_delivery         ,
                item_segments                  ,
                item_description               ,
                item_trx_enabled_flag          ,
                item_location_control_code     ,
                item_restrict_subinv_code      ,
                item_restrict_locators_code    ,
                item_revision_qty_control_code ,
                item_primary_uom_code          ,
                item_uom_class                 ,
                item_shelf_life_code           ,
                item_shelf_life_days           ,
                item_lot_control_code          ,
                item_serial_control_code       ,
                item_inventory_asset_flag      ,
                allowed_units_lookup_code      ,
                department_id                  ,
                department_code                ,
                wip_supply_type                ,
                supply_subinventory            ,
                supply_locator_id              ,
                valid_subinventory_flag        ,
                valid_locator_flag             ,
                locator_segments               ,
                current_locator_control_code   ,
                number_of_lots_entered         ,
                wip_commit_flag                ,
                next_lot_number                ,
                lot_alpha_prefix               ,
                next_serial_number             ,
                serial_alpha_prefix            ,
                shippable_flag                 ,
                posting_flag                   ,
                required_flag                  ,
                process_flag                   ,
                ERROR_CODE                     ,
                error_explanation              ,
                attribute_category             ,
                attribute1                     ,
                attribute2                     ,
                attribute3                     ,
                attribute4                     ,
                attribute5                     ,
                attribute6                     ,
                attribute7                     ,
                attribute8                     ,
                attribute9                     ,
                attribute10                    ,
                attribute11                    ,
                attribute12                    ,
                attribute13                    ,
                attribute14                    ,
                attribute15                    ,
                movement_id                    ,
                reservation_quantity           ,
                shipped_quantity               ,
                transaction_line_number        ,
                task_id                        ,
                to_task_id                     ,
                source_task_id                 ,
                project_id                     ,
                source_project_id              ,
                pa_expenditure_org_id          ,
                to_project_id                  ,
                expenditure_type               ,
                final_completion_flag          ,
                transfer_percentage            ,
                transaction_sequence_id        ,
                material_account               ,
                material_overhead_account      ,
                resource_account               ,
                outside_processing_account     ,
                overhead_account               ,
                flow_schedule                  ,
                cost_group_id                  ,
                demand_class                   ,
                qa_collection_id               ,
                kanban_card_id                 ,
                overcompletion_transaction_qty ,
                overcompletion_primary_qty     ,
                overcompletion_transaction_id  ,
                end_item_unit_number           ,
                scheduled_payback_date         ,
                line_type_code                 ,
                parent_transaction_temp_id     ,
                put_away_strategy_id           ,
                put_away_rule_id               ,
                pick_strategy_id               ,
                pick_rule_id                   ,
                move_order_line_id             ,
                task_group_id                  ,
                pick_slip_number               ,
                reservation_id                 ,
                common_bom_seq_id              ,
                common_routing_seq_id          ,
                ussgl_transaction_code
        FROM    mtl_material_transactions_temp
        WHERE   transaction_temp_id = p_orig_transaction_temp_id;
        x_return_status            := 'S';
EXCEPTION
WHEN OTHERS THEN
        x_return_status := 'E';
        IF g_debug       = 1 THEN
                mydebug(  ' Error Code : '|| SQLCODE || ' Error Message :'||SQLERRM , 'split_mmtt');
        END IF;
        RETURN;
END split_mmtt;

PROCEDURE split_wdt( p_new_task_id IN NUMBER ,
		     p_new_transaction_temp_id IN NUMBER ,
		     p_new_mol_id IN NUMBER ,
		     p_orig_transaction_temp_id IN NUMBER ,
		     x_return_status OUT NOCOPY VARCHAR2 ,
		     x_msg_data OUT NOCOPY VARCHAR2 ,
		     x_msg_count OUT NOCOPY VARCHAR2 ) IS

        l_sysdate DATE                := SYSDATE;
	g_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
        x_return_status := 'E';
        IF g_debug       = 1 THEN
                mydebug(  ' Entered ','SPLIT_WDT');
        END IF;
        INSERT
        INTO    wms_dispatched_tasks
                (
                        op_plan_instance_id         ,
                        task_method                 ,
                        task_id                     ,
                        transaction_temp_id         ,
                        organization_id             ,
                        user_task_type              ,
                        person_id                   ,
                        effective_start_date        ,
                        effective_end_date          ,
                        equipment_id                ,
                        equipment_instance          ,
                        person_resource_id          ,
                        machine_resource_id         ,
                        status                      ,
                        dispatched_time             ,
                        loaded_time                 ,
                        drop_off_time               ,
                        last_update_date            ,
                        last_updated_by             ,
                        creation_date               ,
                        created_by                  ,
                        last_update_login           ,
                        attribute_category          ,
                        attribute1                  ,
                        attribute2                  ,
                        attribute3                  ,
                        attribute4                  ,
                        attribute5                  ,
                        attribute6                  ,
                        attribute7                  ,
                        attribute8                  ,
                        attribute9                  ,
                        attribute10                 ,
                        attribute11                 ,
                        attribute12                 ,
                        attribute13                 ,
                        attribute14                 ,
                        attribute15                 ,
                        task_type                   ,
                        priority                    ,
                        task_group_id               ,
                        device_id                   ,
                        device_invoked              ,
                        device_request_id           ,
                        suggested_dest_subinventory ,
                        suggested_dest_locator_id   ,
                        operation_plan_id           ,
                        move_order_line_id          ,
                        transfer_lpn_id
                )
        SELECT  op_plan_instance_id ,
                task_method         ,
                p_new_task_id --task_id
                ,
                p_new_transaction_temp_id --transaction_temp_id
                ,
                organization_id      ,
                user_task_type       ,
                person_id            ,
                effective_start_date ,
                effective_end_date   ,
                equipment_id         ,
                equipment_instance   ,
                person_resource_id   ,
                machine_resource_id  ,
                status               ,
                dispatched_time      ,
                loaded_time          ,
                drop_off_time        ,
                l_sysdate --last_update_date
                ,
                FND_GLOBAL.USER_ID ,
                l_sysdate --creation_date
                ,
                FND_GLOBAL.USER_ID          ,
                last_update_login           ,
                attribute_category          ,
                attribute1                  ,
                attribute2                  ,
                attribute3                  ,
                attribute4                  ,
                attribute5                  ,
                attribute6                  ,
                attribute7                  ,
                attribute8                  ,
                attribute9                  ,
                attribute10                 ,
                attribute11                 ,
                attribute12                 ,
                attribute13                 ,
                attribute14                 ,
                attribute15                 ,
                task_type                   ,
                priority                    ,
                task_group_id               ,
                device_id                   ,
                device_invoked              ,
                device_request_id           ,
                suggested_dest_subinventory ,
                suggested_dest_locator_id   ,
                operation_plan_id           ,
                p_new_mol_id                ,
                transfer_lpn_id
        FROM    wms_dispatched_tasks
        WHERE   transaction_temp_id = p_orig_transaction_temp_id;
        x_return_status            := 'S';
EXCEPTION
WHEN OTHERS THEN
        x_return_status := 'E';
        IF g_debug       = 1 THEN
                mydebug(  ' Error Code : '|| SQLCODE || ' Error Message :'||SQLERRM,'SPLIT_WDT');
        END IF;
        RETURN;
END split_wdt;

PROCEDURE split_lot_serial( p_orig_transaction_temp_id IN NUMBER ,
			    p_new_transaction_temp_id IN NUMBER ,
			    p_transaction_qty_to_split IN NUMBER ,
			    p_primary_qty_to_split IN NUMBER ,
			    p_inventory_item_id IN NUMBER ,
			    p_organization_id IN NUMBER ,
			    x_return_status OUT NOCOPY VARCHAR2 ,
			    x_msg_data OUT NOCOPY VARCHAR2 ,
			    x_msg_count OUT NOCOPY VARCHAR2 ) IS

        CURSOR C_MTLT
        IS
                SELECT  rowid,
                        mtlt.*
                FROM    mtl_transaction_lots_temp mtlt
                WHERE   transaction_temp_id = p_orig_transaction_temp_id
                ORDER BY lot_number;
        l_transaction_remaining_qty NUMBER;
        l_primary_remaining_qty     NUMBER;
        l_txn_remaining_qty_mtlt    NUMBER;
        l_prim_remaining_qty_mtlt   NUMBER;
        l_lot_control_code          NUMBER;
        l_serial_control_code       NUMBER;
        l_new_serial_txn_temp_id    NUMBER;
        l_lot_control_code          NUMBER;
        l_serial_control_code       NUMBER;
        x_lot_return_status         VARCHAR2(1);

	g_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
        x_return_status := 'E';
        IF g_debug       = 1 THEN
                mydebug( 'Entered.', 'SPLIT_LOT_SERIAL');
        END IF;
        l_transaction_remaining_qty := p_transaction_qty_to_split;
        l_primary_remaining_qty     := p_primary_qty_to_split;
        FOR mtlt                    IN C_MTLT
        LOOP
                IF g_debug = 1 THEN
                  mydebug('In for loop(cursor mtlt) for transaction_temp_id : '||p_orig_transaction_temp_id||'l_transaction_remaining_qty : '||l_transaction_remaining_qty||  'l_primary_remaining_qty : '||l_primary_remaining_qty, 'SPLIT_LOT_SERIAL');
                END IF;
                IF l_transaction_remaining_qty >= mtlt.transaction_quantity THEN
                        -- Then this whole row can be consumed there is not need to split.
                        -- Update the row with the new ttemp_id and transaction_quantity.
                        -- Calculate remaining quantity.
                        -- Update mtl_lot_number
                        l_transaction_remaining_qty := l_transaction_remaining_qty - mtlt.transaction_quantity;
                        l_primary_remaining_qty     := l_primary_remaining_qty     - mtlt.primary_quantity;
                        UPDATE mtl_transaction_lots_temp
                                SET transaction_temp_id = p_new_transaction_temp_id ,
                                last_updated_by         = FND_GLOBAL.USER_ID
                        WHERE   rowid                   = mtlt.rowid;
                        IF l_transaction_remaining_qty  = 0 THEN
                                EXIT;
                        END IF;
                ELSE
                        -- Oops the mtlt quantity is bigger gotta split the row.
                        -- Insert a new row with the transaction_quantity.
                        -- Update the old row with the remaining quantity.
                        -- Update mtl_lot_number
                        split_mtlt (
				p_new_transaction_temp_id ,
				l_transaction_remaining_qty ,
				l_primary_remaining_qty ,
				mtlt.rowid ,
				x_lot_return_status ,
				x_msg_data ,
				x_msg_count );

                        IF mtlt.serial_transaction_temp_id IS NOT NULL THEN
                                SELECT  mtl_material_transactions_s.NEXTVAL
                                INTO    l_new_serial_txn_temp_id
                                FROM    dual;
                                UPDATE mtl_transaction_lots_temp
                                        SET serial_transaction_temp_id   = l_new_serial_txn_temp_id ,
                                        last_updated_by                  = FND_GLOBAL.USER_ID
                                WHERE   transaction_temp_id              = p_new_transaction_temp_id
                                    AND lot_number                       = mtlt.lot_number;
                                split_serial(
					p_orig_transaction_temp_id => mtlt.serial_transaction_temp_id ,
					p_new_transaction_temp_id => l_new_serial_txn_temp_id ,
					p_transaction_qty_to_split => l_transaction_remaining_qty ,
					p_primary_qty_to_split => l_primary_remaining_qty ,
					p_inventory_item_id => p_inventory_item_id ,
					p_organization_id => p_organization_id ,
					x_return_status => x_return_status ,
					x_msg_data => x_msg_data ,
					x_msg_count => x_msg_count );
                        END IF;
                        l_txn_remaining_qty_mtlt  := mtlt.transaction_quantity - l_transaction_remaining_qty;
                        l_prim_remaining_qty_mtlt := mtlt.primary_quantity     - l_primary_remaining_qty;
                        -- Update the remaining qty in the mtlt after insert.
                        UPDATE mtl_transaction_lots_temp
                                SET transaction_quantity = l_txn_remaining_qty_mtlt  ,
                                primary_quantity         = l_prim_remaining_qty_mtlt ,
                                last_updated_by          = FND_GLOBAL.USER_ID
                        WHERE   rowid                    = mtlt.rowid;
                        -- As the remaining quantity is already consumed we can safely exit
                        EXIT ;
                END IF;
        END LOOP;
        x_return_status := 'S';
EXCEPTION
WHEN OTHERS THEN
        IF g_debug = 1 THEN
                mydebug(  'Error occurred : '|| SQLERRM, 'SPLIT_LOT_SERIAL');
        END IF;
        x_return_status := 'E';
        RETURN;
END split_lot_serial;

PROCEDURE split_serial( p_orig_transaction_temp_id IN NUMBER ,
			p_new_transaction_temp_id IN NUMBER ,
			p_transaction_qty_to_split IN NUMBER ,
			p_primary_qty_to_split IN NUMBER ,
			p_inventory_item_id IN NUMBER ,
			p_organization_id IN NUMBER ,
			x_return_status OUT NOCOPY VARCHAR2 ,
			x_msg_data OUT NOCOPY VARCHAR2 ,
			x_msg_count OUT NOCOPY VARCHAR2 ) IS

        CURSOR C_MSNT
        IS
                SELECT  rowid,
                        msnt.*
                FROM    mtl_serial_numbers_temp msnt
                WHERE   transaction_temp_id = p_orig_transaction_temp_id
                ORDER BY fm_serial_number;

        l_transaction_remaining_qty NUMBER;
        l_primary_remaining_qty     NUMBER;
	g_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
        x_return_status             := 'E';
        l_transaction_remaining_qty := p_transaction_qty_to_split;
        l_primary_remaining_qty     := p_primary_qty_to_split;
        IF g_debug                   = 1 THEN
                mydebug(  'In for loop(cursor msnt) for transaction_temp_id : '||p_orig_transaction_temp_id ||  'l_transaction_remaining_qty : '||l_transaction_remaining_qty||  'l_primary_remaining_qty : '||l_primary_remaining_qty, 'SPLIT_SERIAL');
        END IF;
        FOR msnt IN C_MSNT
        LOOP
                l_transaction_remaining_qty := l_transaction_remaining_qty - 1;
                UPDATE mtl_serial_numbers_temp
                        SET transaction_temp_id = p_new_transaction_temp_id ,
                        last_updated_by         = FND_GLOBAL.USER_ID
                WHERE   rowid                   = msnt.rowid;
                UPDATE mtl_serial_numbers msn
                        SET msn.group_mark_id   = p_new_transaction_temp_id ,
                        last_updated_by         = FND_GLOBAL.USER_ID
                WHERE   msn.inventory_item_id   = p_inventory_item_id
                    AND serial_number           = msnt.fm_serial_number
                    AND current_organization_id = p_organization_id;
                IF l_transaction_remaining_qty  = 0 THEN
                        mydebug('All the quantity has been consumed, going back', 'SPLIT_SERIAL');
                        EXIT;
                END IF;
        END LOOP;
        x_return_status := 'S';
EXCEPTION
WHEN OTHERS THEN
        x_return_status := 'E';
        RETURN;
END split_serial;

PROCEDURE split_mtlt ( p_new_transaction_temp_id IN NUMBER ,
		       p_transaction_qty_to_split IN NUMBER ,
		       p_primary_qty_to_split IN NUMBER ,
		       p_row_id IN ROWID ,
		       x_return_status OUT NOCOPY VARCHAR2 ,
		       x_msg_data OUT NOCOPY VARCHAR2 ,
		       x_msg_count OUT NOCOPY VARCHAR2 ) IS

BEGIN
        x_return_status := 'E';
        INSERT
        INTO    mtl_transaction_lots_temp
                (
                        TRANSACTION_TEMP_ID        ,
                        LAST_UPDATE_DATE           ,
                        LAST_UPDATED_BY            ,
                        CREATION_DATE              ,
                        CREATED_BY                 ,
                        LAST_UPDATE_LOGIN          ,
                        REQUEST_ID                 ,
                        PROGRAM_APPLICATION_ID     ,
                        PROGRAM_ID                 ,
                        PROGRAM_UPDATE_DATE        ,
                        TRANSACTION_QUANTITY       ,
                        PRIMARY_QUANTITY           ,
                        LOT_NUMBER                 ,
                        LOT_EXPIRATION_DATE        ,
                        ERROR_CODE                 ,
                        SERIAL_TRANSACTION_TEMP_ID ,
                        GROUP_HEADER_ID            ,
                        PUT_AWAY_RULE_ID           ,
                        PICK_RULE_ID               ,
                        DESCRIPTION                ,
                        VENDOR_NAME                ,
                        SUPPLIER_LOT_NUMBER        ,
                        ORIGINATION_DATE           ,
                        DATE_CODE                  ,
                        GRADE_CODE                 ,
                        CHANGE_DATE                ,
                        MATURITY_DATE              ,
                        STATUS_ID                  ,
                        RETEST_DATE                ,
                        AGE                        ,
                        ITEM_SIZE                  ,
                        COLOR                      ,
                        VOLUME                     ,
                        VOLUME_UOM                 ,
                        PLACE_OF_ORIGIN            ,
                        BEST_BY_DATE               ,
                        LENGTH                     ,
                        LENGTH_UOM                 ,
                        RECYCLED_CONTENT           ,
                        THICKNESS                  ,
                        THICKNESS_UOM              ,
                        WIDTH                      ,
                        WIDTH_UOM                  ,
                        CURL_WRINKLE_FOLD          ,
                        LOT_ATTRIBUTE_CATEGORY     ,
                        C_ATTRIBUTE1               ,
                        C_ATTRIBUTE2               ,
                        C_ATTRIBUTE3               ,
                        C_ATTRIBUTE4               ,
                        C_ATTRIBUTE5               ,
                        C_ATTRIBUTE6               ,
                        C_ATTRIBUTE7               ,
                        C_ATTRIBUTE8               ,
                        C_ATTRIBUTE9               ,
                        C_ATTRIBUTE10              ,
                        C_ATTRIBUTE11              ,
                        C_ATTRIBUTE12              ,
                        C_ATTRIBUTE13              ,
                        C_ATTRIBUTE14              ,
                        C_ATTRIBUTE15              ,
                        C_ATTRIBUTE16              ,
                        C_ATTRIBUTE17              ,
                        C_ATTRIBUTE18              ,
                        C_ATTRIBUTE19              ,
                        C_ATTRIBUTE20              ,
                        D_ATTRIBUTE1               ,
                        D_ATTRIBUTE2               ,
                        D_ATTRIBUTE3               ,
                        D_ATTRIBUTE4               ,
                        D_ATTRIBUTE5               ,
                        D_ATTRIBUTE6               ,
                        D_ATTRIBUTE7               ,
                        D_ATTRIBUTE8               ,
                        D_ATTRIBUTE9               ,
                        D_ATTRIBUTE10              ,
                        N_ATTRIBUTE1               ,
                        N_ATTRIBUTE2               ,
                        N_ATTRIBUTE3               ,
                        N_ATTRIBUTE4               ,
                        N_ATTRIBUTE5               ,
                        N_ATTRIBUTE6               ,
                        N_ATTRIBUTE7               ,
                        N_ATTRIBUTE8               ,
                        N_ATTRIBUTE9               ,
                        N_ATTRIBUTE10              ,
                        VENDOR_ID                  ,
                        TERRITORY_CODE             ,
                        SUBLOT_NUM                 ,
                        SECONDARY_QUANTITY         ,
                        SECONDARY_UNIT_OF_MEASURE  ,
                        QC_GRADE                   ,
                        REASON_CODE                ,
                        PRODUCT_CODE               ,
                        PRODUCT_TRANSACTION_ID     ,
                        ATTRIBUTE_CATEGORY         ,
                        ATTRIBUTE1                 ,
                        ATTRIBUTE2                 ,
                        ATTRIBUTE3                 ,
                        ATTRIBUTE4                 ,
                        ATTRIBUTE5                 ,
                        ATTRIBUTE6                 ,
                        ATTRIBUTE7                 ,
                        ATTRIBUTE8                 ,
                        ATTRIBUTE9                 ,
                        ATTRIBUTE10                ,
                        ATTRIBUTE11                ,
                        ATTRIBUTE12                ,
                        ATTRIBUTE13                ,
                        ATTRIBUTE14                ,
                        ATTRIBUTE15
                )
        SELECT  p_new_transaction_temp_id --TRANSACTION_TEMP_ID
                ,
                sysdate --LAST_UPDATE_DATE
                ,
                FND_GLOBAL.USER_ID ,
                sysdate --CREATION_DATE
                ,
                FND_GLOBAL.USER_ID     ,
                LAST_UPDATE_LOGIN      ,
                REQUEST_ID             ,
                PROGRAM_APPLICATION_ID ,
                PROGRAM_ID             ,
                PROGRAM_UPDATE_DATE    ,
                p_transaction_qty_to_split --TRANSACTION_QUANTITY
                ,
                p_primary_qty_to_split --PRIMARY_QUANTITY
                ,
                LOT_NUMBER                 ,
                LOT_EXPIRATION_DATE        ,
                ERROR_CODE                 ,
                SERIAL_TRANSACTION_TEMP_ID ,
                GROUP_HEADER_ID            ,
                PUT_AWAY_RULE_ID           ,
                PICK_RULE_ID               ,
                DESCRIPTION                ,
                VENDOR_NAME                ,
                SUPPLIER_LOT_NUMBER        ,
                ORIGINATION_DATE           ,
                DATE_CODE                  ,
                GRADE_CODE                 ,
                CHANGE_DATE                ,
                MATURITY_DATE              ,
                STATUS_ID                  ,
                RETEST_DATE                ,
                AGE                        ,
                ITEM_SIZE                  ,
                COLOR                      ,
                VOLUME                     ,
                VOLUME_UOM                 ,
                PLACE_OF_ORIGIN            ,
                BEST_BY_DATE               ,
                LENGTH                     ,
                LENGTH_UOM                 ,
                RECYCLED_CONTENT           ,
                THICKNESS                  ,
                THICKNESS_UOM              ,
                WIDTH                      ,
                WIDTH_UOM                  ,
                CURL_WRINKLE_FOLD          ,
                LOT_ATTRIBUTE_CATEGORY     ,
                C_ATTRIBUTE1               ,
                C_ATTRIBUTE2               ,
                C_ATTRIBUTE3               ,
                C_ATTRIBUTE4               ,
                C_ATTRIBUTE5               ,
                C_ATTRIBUTE6               ,
                C_ATTRIBUTE7               ,
                C_ATTRIBUTE8               ,
                C_ATTRIBUTE9               ,
                C_ATTRIBUTE10              ,
                C_ATTRIBUTE11              ,
                C_ATTRIBUTE12              ,
                C_ATTRIBUTE13              ,
                C_ATTRIBUTE14              ,
                C_ATTRIBUTE15              ,
                C_ATTRIBUTE16              ,
                C_ATTRIBUTE17              ,
                C_ATTRIBUTE18              ,
                C_ATTRIBUTE19              ,
                C_ATTRIBUTE20              ,
                D_ATTRIBUTE1               ,
                D_ATTRIBUTE2               ,
                D_ATTRIBUTE3               ,
                D_ATTRIBUTE4               ,
                D_ATTRIBUTE5               ,
                D_ATTRIBUTE6               ,
                D_ATTRIBUTE7               ,
                D_ATTRIBUTE8               ,
                D_ATTRIBUTE9               ,
                D_ATTRIBUTE10              ,
                N_ATTRIBUTE1               ,
                N_ATTRIBUTE2               ,
                N_ATTRIBUTE3               ,
                N_ATTRIBUTE4               ,
                N_ATTRIBUTE5               ,
                N_ATTRIBUTE6               ,
                N_ATTRIBUTE7               ,
                N_ATTRIBUTE8               ,
                N_ATTRIBUTE9               ,
                N_ATTRIBUTE10              ,
                VENDOR_ID                  ,
                TERRITORY_CODE             ,
                SUBLOT_NUM                 ,
                SECONDARY_QUANTITY         ,
                SECONDARY_UNIT_OF_MEASURE  ,
                QC_GRADE                   ,
                REASON_CODE                ,
                PRODUCT_CODE               ,
                PRODUCT_TRANSACTION_ID     ,
                ATTRIBUTE_CATEGORY         ,
                ATTRIBUTE1                 ,
                ATTRIBUTE2                 ,
                ATTRIBUTE3                 ,
                ATTRIBUTE4                 ,
                ATTRIBUTE5                 ,
                ATTRIBUTE6                 ,
                ATTRIBUTE7                 ,
                ATTRIBUTE8                 ,
                ATTRIBUTE9                 ,
                ATTRIBUTE10                ,
                ATTRIBUTE11                ,
                ATTRIBUTE12                ,
                ATTRIBUTE13                ,
                ATTRIBUTE14                ,
                ATTRIBUTE15
        FROM    mtl_transaction_lots_temp
        WHERE   rowid    = p_row_id;
        x_return_status := 'S';
EXCEPTION
WHEN OTHERS THEN
        x_return_status := 'E';
        RETURN;
END split_mtlt;


--End Bug 6682436
END wms_picking_pkg;

/
