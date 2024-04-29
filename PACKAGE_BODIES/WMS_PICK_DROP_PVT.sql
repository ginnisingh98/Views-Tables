--------------------------------------------------------
--  DDL for Package Body WMS_PICK_DROP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PICK_DROP_PVT" AS
  /* $Header: WMSPKDPB.pls 120.18.12010000.11 2011/09/21 07:53:20 abasheer ship $ */

  g_pkg_body_ver  CONSTANT VARCHAR2(100) := '$Header: WMSPKDPB.pls 120.18.12010000.11 2011/09/21 07:53:20 abasheer ship $';
  g_newline       CONSTANT VARCHAR2(10)  := fnd_global.newline;

  g_gtin_cross_ref_type    VARCHAR2(25)  := fnd_profile.value('INV:GTIN_CROSS_REFERENCE_TYPE');

  g_xfer_to_lpn_id NUMBER := NULL; --Added for bug 10139672
  --This variable is used to store the "To LPN" value and assigned in procedure validate_xfer_to_lpn and it will be used in
  --pick_drop procedure

  --
  -- These tables type store the current list of temp IDs
  -- for a drop LPN, and the groups they belong to
  --
  TYPE g_temp_id_status    IS TABLE OF VARCHAR2(10) INDEX BY LONG;  --For bug 8552027
  TYPE g_temp_id_tbl       IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;

  TYPE g_temp_id_group_ref_tbl IS TABLE OF NUMBER       INDEX BY LONG;  --For bug 8552027

  --
  -- Current pending temp IDs
  --
  g_cur_pend_temp  g_temp_id_tbl;

  --
  -- This record type stores information about the current
  -- drop LPN, including the list of temp IDs to be passed
  -- to the TM.
  --
  TYPE drop_lpn_rec_type IS RECORD
  ( lpn_id             NUMBER        := 0
  , organization_id    NUMBER        := 0
  , multiple_drops     VARCHAR2(10)  := ''
  , drop_lpn_option    NUMBER        := 1
  , current_drop_list  g_temp_id_status
  , temp_id_group_ref  g_temp_id_group_ref_tbl --For bug 8552027
  );

  g_current_drop_lpn  drop_lpn_rec_type;

  g_suggestion_drop VARCHAR2(50) :='NONE'; -- Added for bug 12853197
  g_total_qty number :=0; -- Added for bug 12853197
  g_chk_mult_subinv VARCHAR2(2) := NULL; -- Added for bug 12853197


  PROCEDURE print_debug
  ( p_msg      IN VARCHAR2
  , p_api_name IN VARCHAR2
  ) IS
  BEGIN
    inv_log_util.trace
    ( p_message => p_msg
    , p_module  => g_pkg_name || '.' || p_api_name
    , p_level   => 4
    );
  END print_debug;



  PROCEDURE print_version_info
    IS
  BEGIN
    print_debug ('Spec::  ' || g_pkg_spec_ver, 'print_version_info');
    print_debug ('Body::  ' || g_pkg_body_ver, 'print_version_info');
  END print_version_info;



  PROCEDURE clear_lpn_cache
  ( x_return_status   OUT NOCOPY   VARCHAR2
  ) IS
    l_debug  NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    g_current_drop_lpn.current_drop_list.DELETE;
    g_current_drop_lpn.temp_id_group_ref.DELETE;


    g_cur_pend_temp.DELETE;

    g_current_drop_lpn.lpn_id          := NULL;
    g_current_drop_lpn.organization_id := NULL;
    g_current_drop_lpn.multiple_drops  := NULL;
    g_current_drop_lpn.drop_lpn_option := 1;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug (sqlerrm, 'clear_lpn_cache');
      END IF;

  END clear_lpn_cache;



  PROCEDURE get_drop_type
  ( x_drop_type      OUT NOCOPY   VARCHAR2
  , x_return_status  OUT NOCOPY   VARCHAR2
  , p_temp_id        IN           NUMBER
  ) IS

    l_api_name  VARCHAR2(30) := 'get_drop_type';
    l_debug     NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    CURSOR c_txn_info
    ( p_txn_tmp_id  IN  NUMBER
    ) IS
      SELECT mmtt.move_order_line_id
           , mmtt.transaction_source_type_id
           , mmtt.transaction_action_id
           , mmtt.wms_task_type
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.transaction_temp_id = p_txn_tmp_id;

    CURSOR c_mo_type
    ( p_mo_line_id  IN  NUMBER
    ) IS
      SELECT mtrh.move_order_type
           , mtrl.line_status
        FROM mtl_txn_request_lines           mtrl
           , mtl_txn_request_headers         mtrh
       WHERE mtrl.line_id   = p_mo_line_id
         AND mtrl.header_id = mtrh.header_id;

    l_mo_line_id           NUMBER;
    l_txn_src_type_id      NUMBER;
    l_txn_action_id        NUMBER;
    l_move_order_type      NUMBER;
    l_mo_line_stat         NUMBER;
    l_wms_task_type        NUMBER;

  BEGIN

    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline          ||
         'p_temp_id => '             || to_char(p_temp_id)
       , l_api_name
       );
    END IF;

    OPEN c_txn_info (p_temp_id);
    FETCH c_txn_info
     INTO l_mo_line_id
        , l_txn_src_type_id
        , l_txn_action_id
        , l_wms_task_type;

    IF c_txn_info%NOTFOUND THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Passed-in temp ID is invalid: ' || to_char(p_temp_id)
          , l_api_name
          );
       END IF;
       CLOSE c_txn_info;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
       IF l_debug = 1 THEN
          print_debug
          ( 'l_mo_line_id: '        || to_char(l_mo_line_id)      ||
            ', l_txn_src_type_id: ' || to_char(l_txn_src_type_id) ||
            ', l_txn_action_id: '   || to_char(l_txn_action_id)   ||
            ', l_wms_task_type: '   || to_char(l_wms_task_type)
          , l_api_name
          );
       END IF;
    END IF;

    CLOSE c_txn_info;

    IF l_mo_line_id IS NOT NULL THEN
       OPEN c_mo_type (l_mo_line_id);
       FETCH c_mo_type
        INTO l_move_order_type
           , l_mo_line_stat;
       CLOSE c_mo_type;

       IF l_debug = 1 THEN
          print_debug
          ( 'l_move_order_type: ' || to_char(l_move_order_type) ||
            ', l_mo_line_stat: '  || to_char(l_mo_line_stat)
          , l_api_name
          );
       END IF;

       IF l_mo_line_stat = INV_GLOBALS.G_TO_STATUS_CANCEL_BY_SOURCE
       THEN
          x_drop_type := 'CANCELLED';
       ELSIF l_txn_action_id = INV_GLOBALS.G_ACTION_STGXFR    THEN
          x_drop_type := 'STG_XFER';
       ELSIF l_move_order_type = INV_GLOBALS.G_MOVE_ORDER_MFG_PICK
         AND l_txn_action_id   = INV_GLOBALS.G_ACTION_ISSUE   THEN
          x_drop_type := 'WIP_ISSUE';
       ELSIF l_move_order_type = INV_GLOBALS.G_MOVE_ORDER_MFG_PICK
         AND l_txn_action_id   = INV_GLOBALS.G_ACTION_SUBXFR  THEN
          x_drop_type := 'WIP_SUB_XFER';
       ELSIF l_txn_action_id = INV_GLOBALS.G_ACTION_SUBXFR    THEN
          x_drop_type := 'SUB_XFER';
       END IF;
    ELSIF l_wms_task_type = 7                                 THEN
       x_drop_type := 'CONS_STG_MV';
    ELSIF l_txn_action_id = INV_GLOBALS.G_ACTION_SUBXFR       THEN
       x_drop_type := 'OVERPICK';
    END IF;

    IF x_drop_type IS NULL THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Unable to determine drop type:'
            || g_newline || 'p_temp_id:         ' || to_char(p_temp_id)
            || g_newline || 'l_mo_line_id:      ' || to_char(l_mo_line_id)
            || g_newline || 'l_txn_src_type_id: ' || to_char(l_txn_src_type_id)
            || g_newline || 'l_txn_action_id:   ' || to_char(l_txn_action_id)
            || g_newline || 'l_move_order_type: ' || to_char(l_move_order_type)
            || g_newline || 'l_mo_line_stat:    ' || to_char(l_mo_line_stat)
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
       IF l_debug = 1 THEN
          print_debug
          ( 'Drop type: ' || x_drop_type
          , l_api_name
          );
       END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END get_drop_type;



  PROCEDURE get_delivery_id
  ( x_delivery_id    OUT NOCOPY   NUMBER
  , x_return_status  OUT NOCOPY   VARCHAR2
  , p_drop_type      IN           VARCHAR2
  , p_temp_id        IN           NUMBER
  ) IS

    l_api_name  VARCHAR2(30)      := 'get_delivery_id';
    l_debug     NUMBER            := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_delivery_id          NUMBER := NULL;

    CURSOR c_get_deliv_id
    ( p_tmp_id  IN  NUMBER
    ) IS
         SELECT wda.delivery_id
         FROM wsh_delivery_assignments_v        wda,
              wsh_delivery_details_ob_grp_v            wdd,
              mtl_material_transactions_temp  mmtt
        WHERE wda.delivery_detail_id   = wdd.delivery_detail_id
          AND wdd.move_order_line_id   = mmtt.move_order_line_id
          AND wdd.organization_id      = mmtt.organization_id
          AND mmtt.transaction_temp_id = p_tmp_id;

  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline          ||
         'p_temp_id => '             || to_char(p_temp_id) || g_newline ||
         'p_drop_type => '           || p_drop_type
       , l_api_name
       );
    END IF;
    x_delivery_id := 0;

    IF p_drop_type = 'CONS_STG_MV' THEN
       SELECT wda.delivery_id
         INTO x_delivery_id
         FROM wsh_delivery_assignments_v        wda,
              wsh_delivery_details_ob_grp_v            wdd,
              mtl_material_transactions_temp  mmtt
        WHERE wda.delivery_detail_id   = wdd.delivery_detail_id
          AND wdd.organization_id      = mmtt.organization_id
          AND mmtt.transaction_temp_id = p_temp_id
          AND mmtt.transfer_lpn_id     = wdd.lpn_id
          AND ROWNUM = 1;
       IF l_debug = 1 THEN print_debug ( 'x_delivery_id : ' || x_delivery_id , l_api_name); END IF;
    ELSE
       OPEN c_get_deliv_id (p_temp_id);
       FETCH c_get_deliv_id INTO l_delivery_id;

       IF c_get_deliv_id%NOTFOUND
          OR
             l_delivery_id IS NULL
       THEN
          x_delivery_id := 0;
       ELSE
          x_delivery_id := l_delivery_id;
       END IF;

       CLOSE c_get_deliv_id;
       IF l_debug = 1 THEN print_debug ( 'Cursor: x_delivery_id : ' || x_delivery_id , l_api_name); END IF;
    END IF ;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF c_get_deliv_id%ISOPEN THEN
         CLOSE c_get_deliv_id;
      END IF;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;
  END get_delivery_id;



  PROCEDURE gen_lock_handle
  ( x_lock_handle      OUT NOCOPY   VARCHAR2
  , x_return_status    OUT NOCOPY   VARCHAR2
  , p_organization_id  IN           NUMBER
  , p_transfer_lpn_id  IN           NUMBER
  ) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

    l_debug          NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_api_name       VARCHAR2(30) := 'gen_lock_handle';

    l_lock_name      VARCHAR2(128);
    l_lock_handle    VARCHAR2(128);

    l_first_temp_id  NUMBER;
    l_last_temp_id   NUMBER;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id)
       , l_api_name
       );
    END IF;

    l_lock_name := 'WMS_PICK_DROP'
                    || '-' || to_char(p_organization_id)
                    || '-' || to_char(p_transfer_lpn_id);

    IF l_debug = 1 THEN
       print_debug
       ( 'Lock name: ' || l_lock_name || ', ' ||
         'length: '    || LENGTH(l_lock_name)
       , l_api_name
       );
    END IF;

    --
    -- Set expiration to 30 minutes
    --
    dbms_lock.allocate_unique
    ( lockname    => l_lock_name
    , lockhandle  => l_lock_handle
    , expiration_secs => 1800
    );

    IF l_debug = 1 THEN
       print_debug
       ( 'Lock handle: ' || l_lock_handle
       , l_api_name
       );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug (sqlerrm, l_api_name);
      END IF;

  END gen_lock_handle;



  PROCEDURE lock_lpn
  ( x_return_status  OUT NOCOPY   VARCHAR2
  , p_org_id         IN           NUMBER
  , p_xfer_lpn_id    IN           NUMBER
  ) IS

    l_debug      NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_api_name   VARCHAR2(30) := 'lock_lpn';

    l_lock_handle        VARCHAR2(128);
    l_api_return_status  VARCHAR2(1);
    l_lock_req_stat      NUMBER;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline              ||
         'p_org_id      => '         || to_char(p_org_id)      || g_newline ||
         'p_xfer_lpn_id => '         || to_char(p_xfer_lpn_id)
       , l_api_name
       );
    END IF;

/*  l_api_return_status := fnd_api.g_ret_sts_success;

    gen_lock_handle
    ( x_lock_handle     => l_lock_handle
    , x_return_status   => l_api_return_status
    , p_organization_id => p_org_id
    , p_transfer_lpn_id => p_xfer_lpn_id
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Error status from gen_lock_handle: ' || l_api_return_status
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_lock_req_stat := dbms_lock.request
                       ( lockhandle => l_lock_handle
                       , lockmode   => dbms_lock.x_mode
                       , timeout    => 1
                       , release_on_commit => TRUE
                       );

    IF l_lock_req_stat = 1 THEN
       x_return_status := 'L';
    ELSIF l_lock_req_stat NOT IN (0,4) THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Error status from dbms_lock.request: ' ||
            to_char(l_lock_req_stat)
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
*/
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug (sqlerrm, l_api_name);
      END IF;

  END lock_lpn;



  PROCEDURE get_group_info
  ( x_drop_type        OUT NOCOPY   VARCHAR2
  , x_bulk_pick        OUT NOCOPY   VARCHAR2
  , x_delivery_id      OUT NOCOPY   NUMBER
  , x_task_type        OUT NOCOPY   NUMBER
  , x_return_status    OUT NOCOPY   VARCHAR2
  , p_txn_temp_id      IN           NUMBER
  ) IS

    l_api_name           VARCHAR2(30) := 'get_group_info';
    l_debug              NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_api_return_status  VARCHAR2(1);

    l_parent_temp_id     NUMBER;
    l_task_type          NUMBER;

    CURSOR c_get_parent_id
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mmtt.parent_line_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id;

    CURSOR c_get_task_type
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT wdt.task_type
        FROM wms_dispatched_tasks  wdt
       WHERE wdt.transaction_temp_id = p_temp_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with temp ID: ' || to_char(p_txn_temp_id)
       , l_api_name
       );
    END IF;

    --
    -- Derive the drop type
    --
    l_api_return_status := fnd_api.g_ret_sts_success;
    get_drop_type
    ( x_drop_type     => x_drop_type
    , x_return_status => l_api_return_status
    , p_temp_id       => p_txn_temp_id
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Error from get_drop_type'
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
       IF l_debug = 1 THEN
          print_debug
          ( 'Drop type: ' || x_drop_type
          , l_api_name
          );
       END IF;
    END IF;

    --
    -- Check if bulk
    --
    OPEN c_get_parent_id (p_txn_temp_id);
    FETCH c_get_parent_id INTO l_parent_temp_id;
    CLOSE c_get_parent_id;

    IF l_parent_temp_id IS NOT NULL
    THEN
       x_bulk_pick := 'TRUE';
    ELSE
       x_bulk_pick := 'FALSE';
    END IF;

    IF l_debug = 1 THEN
       print_debug
       ( 'Bulk pick? ' || x_bulk_pick
       , l_api_name
       );
    END IF;

    --
    -- Get delivery ID if staging xfer
    --

    IF l_debug = 1 THEN print_debug ( 'Outside ..Stg xfer or stg mv ' || x_drop_type , l_api_name); END IF;
    IF x_drop_type = 'STG_XFER' OR  x_drop_type = 'CONS_STG_MV' THEN
    -- mrana : added staging move too
    IF l_debug = 1 THEN print_debug ( 'Stg xfer or stg mv ' , l_api_name); END IF;
       l_api_return_status := fnd_api.g_ret_sts_success;
       get_delivery_id
       ( x_delivery_id   => x_delivery_id
       , x_return_status => l_api_return_status
       , p_drop_type     => x_drop_type
       , p_temp_id       => p_txn_temp_id
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'Error from get_delivery_id'
             , l_api_name
             );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSE
          IF l_debug = 1 THEN
             print_debug
             ( 'Delivery ID: ' || to_char(x_delivery_id)
             , l_api_name
             );
          END IF;
       END IF;
    END IF;

    IF x_bulk_pick = 'TRUE'
    THEN
       OPEN c_get_task_type (l_parent_temp_id);
       FETCH c_get_task_type INTO l_task_type;
       CLOSE c_get_task_type;
    ELSE
       IF x_drop_type = 'CANCELLED'
          OR
          x_drop_type = 'OVERPICK'
       THEN
          l_task_type := 1;
       ELSE
          OPEN c_get_task_type (p_txn_temp_id);
          FETCH c_get_task_type INTO l_task_type;
          CLOSE c_get_task_type;
       END IF;
    END IF;
    x_task_type := l_task_type;

    IF l_debug = 1 THEN
       print_debug
       ( 'Task type: ' || to_char(l_task_type)
       , l_api_name
       );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END get_group_info;



  PROCEDURE insert_wdt
  ( x_return_status    OUT NOCOPY   VARCHAR2
  , p_organization_id  IN           NUMBER
  , p_transfer_lpn_id  IN           NUMBER
  ) IS

    l_debug      NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_api_name   VARCHAR2(30) := 'insert_wdt';

    l_api_return_status  VARCHAR2(1);

    CURSOR c_parent_task_details
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT pmmtt.transaction_temp_id
           , wdt.user_task_type
           , wdt.person_id
           , wdt.effective_start_date
           , wdt.effective_end_date
           , wdt.equipment_id
           , wdt.equipment_instance
           , wdt.person_resource_id
           , wdt.machine_resource_id
           , wdt.dispatched_time
           , wdt.last_updated_by
           , wdt.created_by
           , wdt.task_type
           , wdt.loaded_time
        FROM mtl_material_transactions_temp  pmmtt
           , wms_dispatched_tasks            wdt
       WHERE pmmtt.organization_id = p_org_id
         AND pmmtt.transfer_lpn_id = p_lpn_id
         AND pmmtt.transaction_temp_id = NVL(pmmtt.parent_line_id,0)
         AND wdt.transaction_temp_id = pmmtt.parent_line_id;

    c_parent_task_rec  c_parent_task_details%ROWTYPE;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id)
       , l_api_name
       );
    END IF;

    SAVEPOINT insert_task_sp;

    FOR c_parent_task_rec IN c_parent_task_details( p_organization_id
                                                  , p_transfer_lpn_id)
    LOOP
       IF l_debug = 1 THEN
          print_debug
          ( 'Processing parent MMTT: ' || c_parent_task_rec.transaction_temp_id
          , l_api_name
          );
       END IF;

       INSERT INTO wms_dispatched_tasks
       ( task_id
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
       ( SELECT wms_dispatched_tasks_s.NEXTVAL
              , mmtt.transaction_temp_id
              , mmtt.organization_id
              , c_parent_task_rec.user_task_type
              , c_parent_task_rec.person_id
              , c_parent_task_rec.effective_start_date
              , c_parent_task_rec.effective_end_date
              , c_parent_task_rec.equipment_id
              , c_parent_task_rec.equipment_instance
              , c_parent_task_rec.person_resource_id
              , c_parent_task_rec.machine_resource_id
              , 4
              , c_parent_task_rec.dispatched_time
              , SYSDATE
              , c_parent_task_rec.last_updated_by
              , SYSDATE
              , c_parent_task_rec.created_by
              , c_parent_task_rec.task_type
              , c_parent_task_rec.loaded_time
              , mmtt.operation_plan_id
              , mmtt.move_order_line_id
           FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.parent_line_id = c_parent_task_rec.transaction_temp_id
            AND mmtt.parent_line_id <> mmtt.transaction_temp_id
            AND NOT EXISTS
              ( SELECT 'x'
                  FROM wms_dispatched_tasks  wdt2
                 WHERE wdt2.transaction_temp_id = mmtt.transaction_temp_id
              )
       );

       IF l_debug = 1 THEN
          print_debug
          ( 'No. of WDT records inserted: ' || SQL%ROWCOUNT
          , l_api_name
          );
       END IF;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO insert_task_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug (sqlerrm, l_api_name);
      END IF;

  END insert_wdt;



  PROCEDURE chk_if_deconsolidate
  ( x_multiple_drops   OUT NOCOPY   VARCHAR2
  , x_drop_type        OUT NOCOPY   VARCHAR2
  , x_bulk_pick        OUT NOCOPY   VARCHAR2
  , x_drop_lpn_option  OUT NOCOPY   NUMBER
  , x_delivery_id      OUT NOCOPY   NUMBER
  , x_first_temp_id    OUT NOCOPY   NUMBER
  , x_task_type        OUT NOCOPY   NUMBER
  , x_txn_type_id      OUT NOCOPY   NUMBER
  , x_return_status    OUT NOCOPY   VARCHAR2
  , p_organization_id  IN           NUMBER
  , p_transfer_lpn_id  IN           NUMBER
  , p_suggestion_drop  IN           VARCHAR2 -- Added for bug 12853197
  ) IS

    l_api_name           VARCHAR2(30) := 'chk_if_deconsolidate';
    l_debug              NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_drop_count         NUMBER       := 0;
    l_drop_lpn_option    NUMBER;

    l_api_return_status  VARCHAR2(1);
    l_dummy              VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_message            VARCHAR2(2000);

    l_progress           NUMBER       := 0;

    l_txn_type_id        NUMBER;
    l_txn_src_type_id    NUMBER;
    l_txn_action_id      NUMBER;
    l_txn_temp_id        NUMBER;
	-- bug#10062741
	l_delivery_cnt       NUMBER       := 0;                       --Bug 10062741
    l_line_rows                   WSH_UTIL_CORE.id_tab_type;      --Bug 10062741
    l_grouping_rows               WSH_UTIL_CORE.id_tab_type;      --Bug 10062741
    l_same_carton_grouping        BOOLEAN := FALSE;               --Bug 10062741
    l_return_status               VARCHAR2(2);                    --Bug 10062741


    CURSOR c_check_txns
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT 'x'
        FROM dual
       WHERE EXISTS
           ( SELECT 'x'
               FROM mtl_material_transactions_temp  mmtt
              WHERE mmtt.organization_id = p_org_id
                AND mmtt.transfer_lpn_id = p_lpn_id
           )
       --Added for Bug 6717052
       UNION ALL
       SELECT 'x'
        FROM dual
       WHERE EXISTS
           ( SELECT 'x'
               FROM mtl_material_transactions_temp  mmtt
              WHERE mmtt.organization_id = p_org_id
                AND mmtt.transfer_lpn_id IN (SELECT wlpn.lpn_id FROM wms_license_plate_numbers wlpn
                                              WHERE wlpn.outermost_lpn_id = p_lpn_id));


    CURSOR c_get_temp_txn_id
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT mmtt.transaction_temp_id
           , mmtt.transaction_type_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id    = p_org_id
         AND mmtt.transfer_lpn_id    = p_lpn_id
         AND (mmtt.parent_line_id   IS NULL
              OR
              (mmtt.parent_line_id  IS NOT NULL
               AND
               mmtt.parent_line_ID  <> mmtt.transaction_temp_id
              )
             )
     --Added for Bug 6717052
      UNION ALL
      SELECT mmtt.transaction_temp_id
           , mmtt.transaction_type_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id    = p_org_id
         AND mmtt.transfer_lpn_id IN   (SELECT wlpn.lpn_id FROM wms_license_plate_numbers wlpn
                                       WHERE wlpn.outermost_lpn_id = p_lpn_id)
         AND (mmtt.parent_line_id   IS NULL
              OR
              (mmtt.parent_line_id  IS NOT NULL
               AND
               mmtt.parent_line_ID  <> mmtt.transaction_temp_id
              )
             );



    CURSOR c_num_mo_types
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT COUNT (DISTINCT (to_char(mtrh.move_order_type)
                              ||';'||
                              to_char(mtrl.line_status)
                             )
                   )
        FROM mtl_material_transactions_temp  mmtt
           , mtl_txn_request_lines           mtrl
           , mtl_txn_request_headers         mtrh
       WHERE mmtt.organization_id    = p_org_id
       --Modified for Bug 6717052
         AND (mmtt.transfer_lpn_id    = p_lpn_id OR  mmtt.transfer_lpn_id    IN   (SELECT wlpn.lpn_id FROM wms_license_plate_numbers wlpn
                                       WHERE wlpn.outermost_lpn_id = p_lpn_id))
         AND mmtt.move_order_line_id = mtrl.line_id
         AND mtrl.header_id          = mtrh.header_id;

    CURSOR c_num_txn_actions
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT COUNT (DISTINCT mmtt.transaction_action_id)
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id    = p_org_id
       --Added for Bug 6717052
         AND (mmtt.transfer_lpn_id    = p_lpn_id OR  mmtt.transfer_lpn_id    IN   (SELECT wlpn.lpn_id FROM wms_license_plate_numbers wlpn
                                       WHERE wlpn.outermost_lpn_id = p_lpn_id))
         AND (mmtt.parent_line_id   IS NULL
              OR
              (mmtt.parent_line_id  IS NOT NULL
               AND
               mmtt.parent_line_ID  <> mmtt.transaction_temp_id
              )
             );


    CURSOR c_get_txn_type_details
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT mmtt.transaction_type_id
           , mmtt.transaction_source_type_id
           , mmtt.transaction_action_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id = p_org_id
         AND mmtt.transfer_lpn_id = p_lpn_id
         AND (mmtt.parent_line_id   IS NULL
              OR
              (mmtt.parent_line_id  IS NOT NULL
               AND
               mmtt.parent_line_ID  <> mmtt.transaction_temp_id
              )
             )
             --Added for Bug 6717052
             UNION ALL
              SELECT mmtt.transaction_type_id
           , mmtt.transaction_source_type_id
           , mmtt.transaction_action_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id = p_org_id
         AND mmtt.transfer_lpn_id IN   (SELECT wlpn.lpn_id FROM wms_license_plate_numbers wlpn
                                       WHERE wlpn.outermost_lpn_id = p_lpn_id)
         AND (mmtt.parent_line_id   IS NULL
              OR
              (mmtt.parent_line_id  IS NOT NULL
               AND
               mmtt.parent_line_ID  <> mmtt.transaction_temp_id
              )
             );


    CURSOR c_num_stg_xfers
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT COUNT (DISTINCT( mmtt.transfer_subinventory
                              ||';'||
                              to_char(mmtt.transfer_to_location)
                              ||';'||
                              to_char(NVL( wda.delivery_id
                                         , -1 -- bug#10062741 mtrl.carton_grouping_id
                                         )
                                     )
                            )
                   )
        FROM mtl_material_transactions_temp  mmtt
           , mtl_txn_request_lines           mtrl
           , wsh_delivery_details_ob_grp_v            wdd
           , wsh_delivery_assignments_v        wda
       WHERE mmtt.organization_id      = p_org_id
       --Modified for Bug 6717052
         AND (mmtt.transfer_lpn_id      = p_lpn_id OR mmtt.transfer_lpn_id IN   (SELECT wlpn.lpn_id FROM wms_license_plate_numbers wlpn
                                       WHERE wlpn.outermost_lpn_id = p_lpn_id))
         AND ( (mmtt.parent_line_id   IS NOT NULL
                AND
                mmtt.parent_line_id   <> mmtt.transaction_temp_id
               )
               OR
               mmtt.parent_line_id    IS NULL
             )
         AND mtrl.line_id              = mmtt.move_order_line_id
         AND wdd.organization_id       = mtrl.organization_id
         AND wdd.move_order_line_id    = mtrl.line_id
         AND wda.delivery_detail_id    = wdd.delivery_detail_id;

	 CURSOR c_stg_delivery_details   -- bug#10062741
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT DISTINCT delivery_detail_id
        FROM mtl_material_transactions_temp  mmtt
           , mtl_txn_request_lines           mtrl
           , wsh_delivery_details            wdd
       WHERE mmtt.organization_id      = p_org_id
         AND mmtt.transfer_lpn_id      = p_lpn_id
         AND ( (mmtt.parent_line_id   IS NOT NULL
                AND
                mmtt.parent_line_id   <> mmtt.transaction_temp_id
               )
               OR
               mmtt.parent_line_id    IS NULL
             )
         AND mtrl.line_id              = mmtt.move_order_line_id
         AND wdd.organization_id       = mtrl.organization_id
         AND wdd.move_order_line_id    = mtrl.line_id
         AND wdd.released_status NOT IN ('Y', 'C'); --Bug 5768776


    CURSOR c_num_wip_issue_drops
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT COUNT (DISTINCT (to_char(mtrl.txn_source_id)
                              ||';'||
                              to_char(mtrl.txn_source_line_id)
                              ||';'||
                              to_char(mtrl.reference_id)
                             )
                   )
        FROM mtl_material_transactions_temp  mmtt
           , mtl_txn_request_lines           mtrl
       WHERE mmtt.organization_id    = p_org_id
         AND mmtt.transfer_lpn_id    = p_lpn_id
         AND mmtt.move_order_line_id = mtrl.line_id;

   -- Added for bug 12853197
   CURSOR c_chk_mult_subinv
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
       SELECT Decode (Count(DISTINCT transfer_subinventory||' '||transfer_to_location),1,'N','Y')
              FROM mtl_material_transactions_temp  mmtt
             WHERE mmtt.organization_id = p_org_id
              AND mmtt.transfer_lpn_id  = p_lpn_id
              AND ((mmtt.parent_line_id IS NOT NULL
                    AND mmtt.parent_line_id   <> mmtt.transaction_temp_id
                    ) OR
                    mmtt.parent_line_id    IS NULL
                   );


    CURSOR c_num_sub_xfers
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT COUNT (DISTINCT (mmtt.transfer_subinventory
                              ||';'||
                              to_char(mmtt.transfer_to_location)
							  ||';'||
                              To_Char(Decode(g_chk_mult_subinv,'N','1',Decode(g_suggestion_drop,'NONE','1',mmtt.INVENTORY_ITEM_ID||';'||mmtt.revision))) -- Added for bug 12853197
                             )
                   )
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id    = p_org_id
         AND mmtt.transfer_lpn_id    = p_lpn_id
         AND ( (mmtt.parent_line_id   IS NOT NULL
                AND
                mmtt.parent_line_id   <> mmtt.transaction_temp_id
               )
               OR
               mmtt.parent_line_id    IS NULL
             );

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_msg_pub.initialize;

    IF l_debug = 1 THEN
       print_version_info;
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id) || g_newline ||
         'p_suggestion_drop => '     || to_char(p_suggestion_drop) -- Added for bug 12853197
       , l_api_name
       );
    END IF;

    SAVEPOINT chk_if_d_sp;

    -- Added for bug 12853197
	IF p_suggestion_drop IS NOT NULL AND Length(Trim(p_suggestion_drop))>0 then
		g_suggestion_drop:=p_suggestion_drop;
    END IF;

    l_progress := 10;

    --
    -- Attempt to get a lock on this LPN
    --
    l_api_return_status := fnd_api.g_ret_sts_success;
    lock_lpn
    ( x_return_status => l_api_return_status
    , p_org_id        => p_organization_id
    , p_xfer_lpn_id   => p_transfer_lpn_id
    );

    IF l_api_return_status = 'L'
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Failed to lock lpn'
          , l_api_name
          );
       END IF;
       fnd_message.set_name('WMS', 'WMS_DROP_LPN_LOCKED');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
    ELSIF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Error from lock_lpn'
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Verify this LPNs has associated transactions
    --
    OPEN c_check_txns (p_organization_id, p_transfer_lpn_id);
    FETCH c_check_txns INTO l_dummy;
    IF c_check_txns%NOTFOUND THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'This LPN has no MMTT records left to process.'
          , l_api_name
          );
       END IF;
       CLOSE c_check_txns;

       fnd_message.set_name('WMS', 'WMS_DROP_LPN_NO_MTL');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_check_txns;

    l_progress := 20;

    --
    -- Bug 4884284: insert WDT records for child MMTT records
    --              prior to calling ATF locator suggestion
    --
    l_api_return_status := fnd_api.g_ret_sts_success;
    insert_wdt
    ( x_return_status    => l_api_return_status
    , p_organization_id  => p_organization_id
    , p_transfer_lpn_id  => p_transfer_lpn_id
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Error from insert_wdt'
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- This API just updates transfer_locator of each MMTT record for
    -- passed in transfer_lpn_id.  If it fails, MMTT will not be updated
    -- and pick drop will continue.
    --
    -- This API needs to be called even if the LPN is cached since
    -- the updates to MMTT would be lost due to a rollback.
    --
    l_api_return_status := fnd_api.g_ret_sts_success;
    wms_op_runtime_pub_apis.update_drop_locator_for_task
    ( x_return_status    => l_api_return_status
    , x_message          => l_message
    , x_drop_lpn_option  => l_drop_lpn_option
    , p_transfer_lpn_id  => p_transfer_lpn_id
    );

    IF l_debug = 1 THEN
       print_debug
       ( 'Return status from wms_op_runtime_pub_apis.update_drop_locator_for_task: ' ||
         g_newline || 'l_api_return_status:   ' || l_api_return_status ||
         g_newline || 'l_message:             ' || l_message           ||
         g_newline || 'l_drop_lpn_option:     ' || to_char(l_drop_lpn_option)
       , l_api_name
       );
    END IF;

    IF l_api_return_status NOT IN (fnd_api.g_ret_sts_success,'W') THEN
       IF (l_debug = 1) THEN
          print_debug('Error status from update_drop_locator_for_task: ' || l_api_return_status
                     , l_api_name);
       END IF;

       IF l_api_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSE
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    ELSE
       IF (l_debug = 1) THEN
          print_debug('update_drop_locator_for_task returned success', l_api_name);
       END IF;
    END IF;

    g_current_drop_lpn.drop_lpn_option := l_drop_lpn_option;

    --
    -- Set drop lpn option and return status
    -- in case this LPN only has one drop
    --
    x_drop_lpn_option := l_drop_lpn_option;
    x_return_status   := l_api_return_status;

    l_progress := 30;

    --
    -- Get the drop type and other info here
    -- in case there is only one drop on this LPN
    --
    OPEN c_get_temp_txn_id (p_organization_id, p_transfer_lpn_id);
    FETCH c_get_temp_txn_id INTO l_txn_temp_id, l_txn_type_id;
    CLOSE c_get_temp_txn_id;

    IF l_debug = 1 THEN
       print_debug
       ( ' Fetched temp ID: ' || to_char(l_txn_temp_id)
         || ' with txn type ' || to_char(l_txn_type_id)
       , l_api_name
       );
    END IF;

    IF l_txn_temp_id IS NULL THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'This LPN has no MMTT records left to process.'
          , l_api_name
          );
       END IF;

       fnd_message.set_name('WMS', 'WMS_DROP_LPN_NO_MTL');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
    ELSE
       x_first_temp_id  := l_txn_temp_id;
       x_txn_type_id    := l_txn_type_id;
    END IF;

    l_api_return_status := fnd_api.g_ret_sts_success;
    get_group_info
    ( x_drop_type     => x_drop_type
    , x_bulk_pick     => x_bulk_pick
    , x_delivery_id   => x_delivery_id
    , x_task_type     => x_task_type
    , x_return_status => l_api_return_status
    , p_txn_temp_id   => l_txn_temp_id
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Error from get_group_info'
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := 45;

    --
    -- IF LPN info already cached, then return cached details
    --
    IF g_current_drop_lpn.organization_id = p_organization_id
       AND
       g_current_drop_lpn.lpn_id = p_transfer_lpn_id
    THEN
       x_multiple_drops := g_current_drop_lpn.multiple_drops;
       g_current_drop_lpn.current_drop_list(l_txn_temp_id) := 'PENDING';
       g_current_drop_lpn.temp_id_group_ref(l_txn_temp_id) := 1;
       IF l_debug = 1 THEN print_debug ( 'LPN info already cached ..RETURN' , l_api_name); END IF;
       RETURN;
    ELSIF g_current_drop_lpn.organization_id IS NOT NULL
          AND
          g_current_drop_lpn.lpn_id IS NOT NULL
          AND
          ( g_current_drop_lpn.organization_id <> p_organization_id
            OR
            g_current_drop_lpn.lpn_id <> p_transfer_lpn_id
          )
    THEN
       --
       -- LPN in cache is different from passed in LPN
       --
       IF l_debug = 1 THEN print_debug ( 'ELSE LPN info already cached ..clear_lpn_cache' , l_api_name); END IF;
       l_api_return_status := fnd_api.g_ret_sts_success;
       clear_lpn_cache(l_api_return_status);

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug ('Error from clear_lpn_cache', l_api_name);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    g_current_drop_lpn.lpn_id          := p_transfer_lpn_id;
    g_current_drop_lpn.organization_id := p_organization_id;
    g_current_drop_lpn.multiple_drops  := 'FALSE';
    g_current_drop_lpn.drop_lpn_option := l_drop_lpn_option;

    g_current_drop_lpn.current_drop_list.DELETE;
    g_current_drop_lpn.temp_id_group_ref.DELETE;
    g_current_drop_lpn.current_drop_list(l_txn_temp_id) := 'PENDING';
    g_current_drop_lpn.temp_id_group_ref(l_txn_temp_id) := 1;

    x_multiple_drops := 'FALSE';

    l_progress := 60;

    --
    -- If staging move, return
    --
    IF x_drop_type = 'CONS_STG_MV'
    THEN
       g_current_drop_lpn.multiple_drops := 'FALSE';
       x_multiple_drops := 'FALSE';
       RETURN;
    END IF;

    --
    -- Check number of drops on this LPN
    --
    OPEN c_num_mo_types (p_organization_id, p_transfer_lpn_id);
    FETCH c_num_mo_types INTO l_drop_count;
    CLOSE c_num_mo_types;

    IF l_debug = 1 THEN
       print_debug
       ( '# of mo types, statuses: ' || to_char(l_drop_count)
       , l_api_name
       );
    END IF;

    IF l_drop_count > 1 THEN
       g_current_drop_lpn.multiple_drops := 'TRUE';
       x_multiple_drops := 'TRUE';
       x_return_status := fnd_api.g_ret_sts_success;
       RETURN;
    END IF;

    l_progress := 70;

    OPEN c_num_txn_actions (p_organization_id, p_transfer_lpn_id);
    FETCH c_num_txn_actions INTO l_drop_count;
    CLOSE c_num_txn_actions;

    IF l_debug = 1 THEN
       print_debug
       ( '# of txn actions: ' || to_char(l_drop_count)
       , l_api_name
       );
    END IF;

    IF l_drop_count > 1 THEN
       g_current_drop_lpn.multiple_drops := 'TRUE';
       x_multiple_drops := 'TRUE';
       x_return_status := fnd_api.g_ret_sts_success;
       RETURN;
    END IF;

    l_progress := 80;

    OPEN c_get_txn_type_details (p_organization_id, p_transfer_lpn_id);
    FETCH c_get_txn_type_details
     INTO l_txn_type_id
        , l_txn_src_type_id
        , l_txn_action_id;
    CLOSE c_get_txn_type_details;

    IF l_debug = 1 THEN
       print_debug
       ( 'Txn type: '      || to_char(l_txn_type_id)     ||
         ' txn src type: ' || to_char(l_txn_src_type_id) ||
         ' txn action: '   || to_char(l_txn_action_id)
       , l_api_name
       );
    END IF;

    l_progress := 90;

    IF l_txn_action_id = INV_GLOBALS.G_ACTION_STGXFR
       AND
       x_drop_type    <> 'CANCELLED'
    THEN
       OPEN c_num_stg_xfers (p_organization_id, p_transfer_lpn_id);
       FETCH c_num_stg_xfers INTO l_drop_count;
       CLOSE c_num_stg_xfers;
		-- bug#10062741
	   IF (l_drop_count = 1 AND l_delivery_cnt = 0) THEN

        OPEN c_stg_delivery_details (p_organization_id, p_transfer_lpn_id);
        FETCH c_stg_delivery_details BULK COLLECT INTO l_line_rows;
        CLOSE c_stg_delivery_details;

        IF (l_debug = 1) THEN
          print_debug('Before calling WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping() to decide if we can drop into 1 LPN', l_api_name);
        END IF;
        --
        -- call to the shipping API.
        --
        WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping(
                    p_line_rows      => l_line_rows,
                    x_grouping_rows  => l_grouping_rows,
                    x_return_status  => l_return_status);
        --
        IF (l_return_status = FND_API.G_RET_STS_SUCCESS)  THEN
          l_same_carton_grouping := TRUE;
          FOR i IN  (l_grouping_rows.FIRST+1) .. l_grouping_rows.LAST LOOP
            IF (l_grouping_rows(i-1) <> l_grouping_rows(i)) THEN
              l_same_carton_grouping := FALSE;
              EXIT;
            END IF;
          END LOOP;
        ELSE
              l_same_carton_grouping := FALSE;
        END IF;

        IF NOT(l_same_carton_grouping) THEN
          l_drop_count := 2;
        END IF;

       END IF; --End Bug 10062741

       IF l_debug = 1 THEN
          print_debug
          ( '# of sales order/internal order drops: ' || to_char(l_drop_count)
          , l_api_name
          );
       END IF;
    ELSIF l_txn_src_type_id = INV_GLOBALS.G_SOURCETYPE_WIP
          AND
          l_txn_action_id   = INV_GLOBALS.G_ACTION_ISSUE
    THEN
       OPEN c_num_wip_issue_drops (p_organization_id, p_transfer_lpn_id);
       FETCH c_num_wip_issue_drops INTO l_drop_count;
       CLOSE c_num_wip_issue_drops;

       IF l_debug = 1 THEN
          print_debug
          ( '# of work order drops: ' || to_char(l_drop_count)
          , l_api_name
          );
       END IF;
    ELSIF x_drop_type = 'CANCELLED'
          OR
          x_drop_type = 'OVERPICK'
    THEN
       --
       -- Force deconsolidation
       --
       l_drop_count := 2;
    ELSIF l_txn_action_id = INV_GLOBALS.G_ACTION_SUBXFR
    THEN
       -- Added for bug 12853197
	   OPEN c_chk_mult_subinv (p_organization_id, p_transfer_lpn_id);
       FETCH c_chk_mult_subinv INTO g_chk_mult_subinv;
       IF c_chk_mult_subinv%NOTFOUND THEN
          g_chk_mult_subinv := 'Y';
       END IF;
       CLOSE c_chk_mult_subinv;

       OPEN c_num_sub_xfers (p_organization_id, p_transfer_lpn_id);
       FETCH c_num_sub_xfers INTO l_drop_count;
       CLOSE c_num_sub_xfers;

       IF l_debug = 1 THEN
          print_debug
          ( '# of sub xfers: ' || to_char(l_drop_count)||' Check Multiple Subinv exists for LPN :' || to_char(g_chk_mult_subinv) -- Modified for bug 12853197
          , l_api_name
          );
       END IF;
    ELSE
       IF l_debug = 1 THEN
          print_debug ('Unknown transaction', l_api_name);
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    l_progress := 100;

    IF l_drop_count > 1 THEN
       g_current_drop_lpn.multiple_drops := 'TRUE';
       x_multiple_drops := 'TRUE';
       x_return_status := fnd_api.g_ret_sts_success;
    ELSIF l_drop_count = 1 THEN
       g_current_drop_lpn.multiple_drops := 'FALSE';
       x_multiple_drops := 'FALSE';
    ELSIF l_drop_count = 0 THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'LPN has leftover MMTT records that cannot be processed'
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
       IF l_debug = 1 THEN
          print_debug
          ( 'Invalid drop count: ' || to_char(l_drop_count)
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO chk_if_d_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
         print_debug ('l_progress = ' || to_char(l_progress), l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO chk_if_d_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
         print_debug ('l_progress = ' || to_char(l_progress), l_api_name);
      END IF;

  END chk_if_deconsolidate;



  PROCEDURE group_drop_details
  ( p_drop_type       IN           VARCHAR2
  , x_return_status   OUT NOCOPY   VARCHAR2
  ) IS

    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_api_name             VARCHAR2(30) := 'group_drop_details';

    ii                     NUMBER       := 0;
    jj                     NUMBER       := 0;

    l_dum_lpn              VARCHAR2(31) := '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';

    l_dummy                VARCHAR2(1)  := NULL;
    l_transaction_temp_id  NUMBER       := NULL;
    l_orig_item_id         NUMBER       := NULL;
    l_content_lpn          VARCHAR2(30) := NULL;
    l_inner_lpn_id         NUMBER       := NULL; --Bug6913674
    l_inner_lpn            VARCHAR2(30) := NULL;
    l_serial_alloc         VARCHAR2(1)  := NULL;
    l_lot_alloc            VARCHAR2(1)  := NULL;
    l_inner_lpn_exists     VARCHAR2(1)  := NULL;
    l_loose_exists         VARCHAR2(1)  := NULL;

    l_group_num            NUMBER;
    l_cur_group_num        NUMBER := 0;

    CURSOR c_mmtt_info
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mmtt.lpn_id
           , mmtt.content_lpn_id
           , mmtt.transfer_lpn_id
           , mmtt.inventory_item_id
           , mmtt.revision
           , mmtt.primary_quantity
           , mmtt.parent_line_id
           , mmtt.serial_allocated_flag
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id;

    c_mmtt_rec  c_mmtt_info%ROWTYPE;

    CURSOR c_item_info
    ( p_org_id   IN  NUMBER
    , p_item_id  IN  NUMBER
    ) IS
      SELECT msik.concatenated_segments             item_num
           , msik.lot_control_code                  lot_control
           , msik.serial_number_control_code        serial_control
           , msik.primary_uom_code                  primary_uom_code
           , NVL(msik.allowed_units_lookup_code,2)  uom_lookup_code
        FROM mtl_system_items_kfv   msik
       WHERE msik.organization_id   = p_org_id
         AND msik.inventory_item_id = p_item_id;

    c_item_rec  c_item_info%ROWTYPE;

    CURSOR c_get_lpn
    ( p_lpn_id  IN  NUMBER
    ) IS
      SELECT license_plate_number
        FROM wms_license_plate_numbers  wlpn
       WHERE wlpn.lpn_id = p_lpn_id;


    CURSOR c_chk_nested_bulk
    ( p_lpn_id        IN  NUMBER
    , p_outer_lpn_id  IN  NUMBER
    , p_org_id        IN  NUMBER
    ) IS
      SELECT 'x'
        FROM dual
       WHERE EXISTS
           ( SELECT 'x'
               FROM mtl_material_transactions_temp  mmtt
              WHERE mmtt.organization_id = p_org_id
                AND mmtt.transfer_lpn_id = p_outer_lpn_id
                AND mmtt.parent_line_id  = mmtt.transaction_temp_id
                AND mmtt.content_lpn_id  = p_lpn_id
           );


    CURSOR c_lot_details
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mtlt.lot_number
           , mtlt.primary_quantity
           , mtlt.serial_transaction_temp_id
        FROM mtl_transaction_lots_temp  mtlt
       WHERE mtlt.transaction_temp_id = p_temp_id;

    c_lot_dtl_rec  c_lot_details%ROWTYPE;


    CURSOR c_srl_lot_details
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT msnt.fm_serial_number
        FROM mtl_serial_numbers_temp  msnt
       WHERE msnt.transaction_temp_id = p_temp_id;


    CURSOR c_srl_numbers
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT msnt.fm_serial_number
        FROM mtl_serial_numbers_temp  msnt
       WHERE msnt.transaction_temp_id = p_temp_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline   ||
         'p_drop_type => '           || p_drop_type
       , l_api_name
       );
    END IF;

    SAVEPOINT group_drop_det_sp;

    ii := g_current_drop_lpn.current_drop_list.FIRST;
    jj := g_current_drop_lpn.current_drop_list.LAST;

    l_transaction_temp_id := ii;

    IF l_debug =1 THEN
       print_debug
       ( '# of temp IDs in group: '
         || to_char(g_current_drop_lpn.current_drop_list.COUNT)
         || ', first temp ID: ' || to_char(ii)
         || ', last temp ID: '  || to_char(jj)
       , l_api_name
       );
    END IF;

    DELETE mtl_allocations_gtmp;

    WHILE (ii <= jj)
    LOOP

      OPEN c_mmtt_info (l_transaction_temp_id);
      FETCH c_mmtt_info INTO c_mmtt_rec;

      IF c_mmtt_info%NOTFOUND THEN
         IF l_debug = 1 THEN
            print_debug
            ( 'Invalid temp ID: ' || to_char(l_transaction_temp_id)
            , l_api_name
            );
         END IF;
         CLOSE c_mmtt_info;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
         IF l_debug = 1 THEN
            print_debug
            ( 'Fetched temp ID:   ' || to_char(l_transaction_temp_id)        || g_newline ||
              'LPN ID:            ' || to_char(c_mmtt_rec.lpn_id)            || g_newline ||
              'Content LPN ID:    ' || to_char(c_mmtt_rec.content_lpn_id)    || g_newline ||
              'Xfer LPN ID:       ' || to_char(c_mmtt_rec.transfer_lpn_id)   || g_newline ||
              'Item ID:           ' || to_char(c_mmtt_rec.inventory_item_id) || g_newline ||
              'Revision:          ' || c_mmtt_rec.revision                   || g_newline ||
              'Primary qty:       ' || to_char(c_mmtt_rec.primary_quantity)  || g_newline ||
              'Parent line ID:    ' || to_char(c_mmtt_rec.parent_line_id)    || g_newline ||
              'Serial alloc flag: ' || c_mmtt_rec.serial_allocated_flag
            , l_api_name
            );
         END IF;
      END IF;
      CLOSE c_mmtt_info;

      IF c_mmtt_rec.inventory_item_id <> NVL(l_orig_item_id,0) THEN
         OPEN c_item_info
         ( g_current_drop_lpn.organization_id
         , c_mmtt_rec.inventory_item_id
         );
         FETCH c_item_info INTO c_item_rec;
         CLOSE c_item_info;

         --
         -- Check if serials allocated
         --
         IF c_item_rec.serial_control  > 1
            AND
            c_item_rec.serial_control <> 6
         THEN
            IF c_mmtt_rec.parent_line_id IS NOT NULL
            THEN
               l_serial_alloc := c_mmtt_rec.serial_allocated_flag;
            ELSE
               l_serial_alloc := 'Y';
            END IF;
         END IF;

         IF c_item_rec.lot_control > 1
         THEN
            l_lot_alloc := 'Y';
         ELSE
            l_lot_alloc := NULL;
         END IF;

         l_orig_item_id := c_mmtt_rec.inventory_item_id;
      END IF;

      IF l_debug = 1 THEN
         print_debug
         ( 'Item #:              ' || c_item_rec.item_num                  || g_newline ||
           'Lot control code:    ' || to_char(c_item_rec.lot_control)      || g_newline ||
           'Serial control code: ' || to_char(c_item_rec.serial_control)   || g_newline ||
           'Primary UOM code:    ' || c_item_rec.primary_uom_code          || g_newline ||
           'Allowed units code:  ' || to_char(c_item_rec.uom_lookup_code)  || g_newline ||
           'l_serial_alloc:      ' || l_serial_alloc                       || g_newline ||
           'l_lot_alloc:         ' || l_lot_alloc
         , l_api_name
         );
      END IF;

      --
      -- Check if dropping content/inner LPN
      -- As of 11.5.10 LPNs can nest on Pick Load
      -- only if the entire LPN is picked
      --
      IF c_mmtt_rec.content_lpn_id IS NOT NULL
         AND
         c_mmtt_rec.content_lpn_id <> c_mmtt_rec.transfer_lpn_id
      THEN
         OPEN c_get_lpn (c_mmtt_rec.content_lpn_id);
         FETCH c_get_lpn INTO l_content_lpn;
         CLOSE c_get_lpn;
      ELSIF c_mmtt_rec.parent_line_id IS NOT NULL
            AND
            c_mmtt_rec.lpn_id IS NOT NULL
            AND
            c_mmtt_rec.lpn_id <> g_current_drop_lpn.lpn_id
            AND
            (
              ( NVL(l_lot_alloc,'N')    = 'Y'
                OR
                NVL(l_serial_alloc,'N') = 'Y'
              )
              OR
              ( p_drop_type = 'WIP_ISSUE'
                OR
                p_drop_type = 'WIP_SUB_XFER'
              )
            )
      THEN
         OPEN c_chk_nested_bulk
         ( c_mmtt_rec.lpn_id
         , g_current_drop_lpn.lpn_id
         , g_current_drop_lpn.organization_id
         );
         FETCH c_chk_nested_bulk INTO l_dummy;

         IF c_chk_nested_bulk%FOUND THEN
            OPEN c_get_lpn (c_mmtt_rec.lpn_id);
            FETCH c_get_lpn INTO l_inner_lpn;
            CLOSE c_get_lpn;

           -- Bug5659809: update last_update_date and last_update_by as well
           UPDATE wms_license_plate_numbers
               SET lpn_context = WMS_Container_PUB.LPN_CONTEXT_INV
                 , last_update_date = SYSDATE
                 , last_updated_by = fnd_global.user_id
            WHERE lpn_id = c_mmtt_rec.lpn_id;

            IF l_debug = 1 THEN
               print_debug
               ( 'Updated LPN context back to 1 for LPN ' || l_inner_lpn
               , l_api_name
               );
            END IF;

         END IF;

         CLOSE c_chk_nested_bulk;
      END IF;

      IF l_debug = 1 THEN
         print_debug
         ( 'Content LPN: ' || l_content_lpn ||
           ', inner LPN: ' || l_inner_lpn
         , l_api_name
         );
      END IF;

      IF l_content_lpn IS NOT NULL
         AND
         p_drop_type <> 'WIP_ISSUE'
         AND
         p_drop_type <> 'WIP_SUB_XFER'
      THEN
         BEGIN
           IF l_debug = 1 THEN
              print_debug
              ( 'Inserting content LPN ' || l_content_lpn
                , l_api_name
              );
           END IF;

           l_cur_group_num := l_cur_group_num + 1;
           g_current_drop_lpn.temp_id_group_ref(l_transaction_temp_id)
             := l_cur_group_num;

           INSERT INTO mtl_allocations_gtmp
           ( inventory_item_id
           , item_number
           , group_number
           , content_lpn
           , inner_lpn
           , revision
           , lot_number
           , serial_number
           , lot_alloc
           , serial_alloc
           , primary_quantity
           , primary_uom_code
           , uom_lookup_code
           )
           VALUES
           ( c_mmtt_rec.inventory_item_id   --9593852
           , NULL
           , l_cur_group_num
           , l_content_lpn
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           );
         EXCEPTION
           WHEN OTHERS THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'Unexpected error inserting content LPN: ' || sqlerrm
                , l_api_name
                );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;
      ELSIF p_drop_type = 'WIP_ISSUE'
            OR
            p_drop_type = 'WIP_SUB_XFER'
      THEN
         BEGIN
            SELECT group_number
              INTO l_group_num
              FROM mtl_allocations_gtmp  mtg
             WHERE mtg.inventory_item_id    = c_mmtt_rec.inventory_item_id
               AND NVL(mtg.revision,'@@@@') = NVL(c_mmtt_rec.revision,'@@@@')
               AND NVL(mtg.inner_lpn,l_dum_lpn)
                       = NVL(l_content_lpn, NVL(l_inner_lpn,l_dum_lpn))
               AND mtg.content_lpn IS NULL;

           IF l_debug = 1 THEN
              print_debug
              ( 'Updating item '     || c_item_rec.item_num  ||
                ', group number '    || to_char(l_group_num) ||
                ', revision '        || c_mmtt_rec.revision  ||
                ' with primary qty ' || to_char(c_mmtt_rec.primary_quantity)
              , l_api_name
              );
           END IF;

           g_current_drop_lpn.temp_id_group_ref(l_transaction_temp_id)
             := l_group_num;

           UPDATE mtl_allocations_gtmp
              SET primary_quantity
                    = primary_quantity + c_mmtt_rec.primary_quantity
            WHERE group_number = l_group_num;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'Inserting item '     || c_item_rec.item_num  ||
                  ', revision '         || c_mmtt_rec.revision  ||
                  ' with primary qty '  || to_char(c_mmtt_rec.primary_quantity) ||
                  ' and primary uom '   || c_item_rec.primary_uom_code
                , l_api_name
                );
             END IF;

             l_cur_group_num := l_cur_group_num + 1;
             g_current_drop_lpn.temp_id_group_ref(l_transaction_temp_id)
               := l_cur_group_num;

             INSERT INTO mtl_allocations_gtmp
             ( inventory_item_id
             , item_number
             , group_number
             , content_lpn
             , inner_lpn
             , revision
             , lot_number
             , serial_number
             , lot_alloc
             , serial_alloc
             , primary_quantity
             , primary_uom_code
             , uom_lookup_code
             )
             VALUES
             ( c_mmtt_rec.inventory_item_id
             , c_item_rec.item_num
             , l_cur_group_num
             , NULL
             , NVL(l_content_lpn, l_inner_lpn)
             , c_mmtt_rec.revision
             , NULL
             , NULL
             , l_lot_alloc
             , l_serial_alloc
             , c_mmtt_rec.primary_quantity
             , c_item_rec.primary_uom_code
             , c_item_rec.uom_lookup_code
             );

           WHEN OTHERS THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'Unexpected error updating record for WIP drop ' || sqlerrm
                , l_api_name
                );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;
      ELSIF NVL(l_lot_alloc,'N') = 'Y'
      THEN
         OPEN c_lot_details (l_transaction_temp_id);
         FETCH c_lot_details INTO c_lot_dtl_rec;

         IF c_lot_details%NOTFOUND
         THEN
            IF l_debug = 1 THEN
               print_debug
               ( 'No MTLT record found for temp ID '
                 || to_char(l_transaction_temp_id)
               , l_api_name
               );
            END IF;
            CLOSE c_lot_details;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF c_lot_details%ISOPEN
         THEN
            CLOSE c_lot_details;
         END IF;

         BEGIN
           SELECT group_number
             INTO l_group_num
             FROM mtl_allocations_gtmp  mtg
            WHERE mtg.inventory_item_id = c_mmtt_rec.inventory_item_id
              AND mtg.lot_number        = c_lot_dtl_rec.lot_number
              AND NVL(mtg.inner_lpn, l_dum_lpn)
                                        = NVL(l_inner_lpn, l_dum_lpn)
              AND NVL(mtg.revision,'@@@@')
                                        = NVL(c_mmtt_rec.revision,'@@@@')
              AND mtg.content_lpn IS NULL
              AND rownum < 2 ; --Bug#12853197

           IF l_debug = 1 THEN
              print_debug
              ( 'Found group number ' || to_char(l_group_num)     ||
                ' for item '          || c_item_rec.item_num      ||
                ', revision '         || c_mmtt_rec.revision      ||
                ', lot number '       || c_lot_dtl_rec.lot_number ||
                ', serial temp ID '   || to_char(c_lot_dtl_rec.serial_transaction_temp_id)
              , l_api_name
              );
           END IF;

           g_current_drop_lpn.temp_id_group_ref(l_transaction_temp_id)
             := l_group_num;

           IF NVL(l_serial_alloc,'N') = 'N'
           THEN
              IF l_debug = 1 THEN
                 print_debug
                 ( 'Updating item '     || c_item_rec.item_num       ||
                   ', revision '        || c_mmtt_rec.revision       ||
                   ', lot number '      || c_lot_dtl_rec.lot_number  ||
                   ' with primary qty ' || to_char(c_lot_dtl_rec.primary_quantity)
                 , l_api_name
                 );
              END IF;

              UPDATE mtl_allocations_gtmp
                 SET primary_quantity
                       = primary_quantity + c_lot_dtl_rec.primary_quantity
               WHERE group_number = l_group_num;
           END IF;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_cur_group_num := l_cur_group_num + 1;
             g_current_drop_lpn.temp_id_group_ref(l_transaction_temp_id)
               := l_cur_group_num;
             l_group_num := l_cur_group_num;

             IF NVL(l_serial_alloc,'N') = 'N'
             THEN
                IF l_debug = 1 THEN
                   print_debug
                   ( 'Inserting item '     || c_item_rec.item_num       ||
                     ', group number '     || to_char(l_group_num)      ||
                     ', revision '         || c_mmtt_rec.revision       ||
                     ', lot number '       || c_lot_dtl_rec.lot_number  ||
                     ', primary qty '      || to_char(c_lot_dtl_rec.primary_quantity) ||
                     ', primary uom code ' || c_item_rec.primary_uom_code
                   , l_api_name
                   );
                END IF;

                INSERT INTO mtl_allocations_gtmp
                ( inventory_item_id
                , item_number
                , group_number
                , content_lpn
                , inner_lpn
                , loose_qty_exists
                , revision
                , lot_number
                , serial_number
                , lot_alloc
                , serial_alloc
                , transaction_quantity
                , primary_quantity
                , primary_uom_code
                , uom_lookup_code
                )
                VALUES
                ( c_mmtt_rec.inventory_item_id
                , c_item_rec.item_num
                , l_group_num
                , NULL
                , l_inner_lpn
                , 'Y'
                , c_mmtt_rec.revision
                , c_lot_dtl_rec.lot_number
                , NULL
                , l_lot_alloc
                , l_serial_alloc
                , NULL
                , c_mmtt_rec.primary_quantity
                , c_item_rec.primary_uom_code
                , c_item_rec.uom_lookup_code
                );
             END IF;

             WHEN OTHERS THEN
               IF l_debug = 1 THEN
                  print_debug
                  ( 'Unexpected error checking if lot exists: ' || sqlerrm
                  , l_api_name
                  );
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;

         IF NVL(l_serial_alloc,'N') = 'Y'
         THEN
            FOR c_srl_lot_dtl_rec IN c_srl_lot_details (c_lot_dtl_rec.serial_transaction_temp_id)
            LOOP
              BEGIN
                IF l_debug = 1 THEN
                   print_debug
                   ( 'Inserting item ' || c_item_rec.item_num           ||
                     ', group # '      || to_char(l_group_num)          ||
                     ', lot number '   || c_lot_dtl_rec.lot_number      ||
                     ', serial # '     || c_srl_lot_dtl_rec.fm_serial_number
                     , l_api_name
                   );
                END IF;

                INSERT INTO mtl_allocations_gtmp
                ( inventory_item_id
                , item_number
                , group_number
                , content_lpn
                , inner_lpn
                , loose_qty_exists
                , revision
                , lot_number
                , serial_number
                , lot_alloc
                , serial_alloc
                , transaction_quantity
                , primary_quantity
                , primary_uom_code
                , uom_lookup_code
                )
                VALUES
                ( c_mmtt_rec.inventory_item_id
                , c_item_rec.item_num
                , l_group_num
                , NULL
                , l_inner_lpn
                , 'Y'
                , c_mmtt_rec.revision
                , c_lot_dtl_rec.lot_number
                , c_srl_lot_dtl_rec.fm_serial_number
                , l_lot_alloc
                , l_serial_alloc
                , NULL
                , 1
                , c_item_rec.primary_uom_code
                , c_item_rec.uom_lookup_code
                );
              EXCEPTION
                WHEN OTHERS THEN
                  IF l_debug = 1 THEN
                     print_debug
                     ( 'Unexpected error inserting allocated serials: ' || sqlerrm
                     , l_api_name
                     );
                  END IF;
                  IF c_srl_lot_details%ISOPEN THEN
                     CLOSE c_srl_lot_details;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END;
            END LOOP;
         END IF; -- end if serials allocated for lot item
      ELSIF NVL(l_serial_alloc,'N') = 'Y' THEN
         --
         -- Serial allocated (not lot controlled)
         --
         BEGIN
           SELECT group_number
             INTO l_group_num
             FROM mtl_allocations_gtmp  mtg
            WHERE mtg.inventory_item_id    = c_mmtt_rec.inventory_item_id
              AND NVL(mtg.revision,'@@@@') = NVL(c_mmtt_rec.revision,'@@@@')
              AND NVL(mtg.inner_lpn, l_dum_lpn)
                                           = NVL(l_inner_lpn, l_dum_lpn)
              AND mtg.content_lpn IS NULL
			  AND ROWNUM<2; --Bug#12853197

           IF l_debug = 1 THEN
              print_debug
              ( 'Found item '      || c_item_rec.item_num  ||
                ', group number '  || to_char(l_group_num) ||
                ', revision '      || c_mmtt_rec.revision  ||
                ' with inner LPN ' || l_inner_lpn
              , l_api_name
              );
           END IF;

           g_current_drop_lpn.temp_id_group_ref(l_transaction_temp_id)
             := l_group_num;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_cur_group_num := l_cur_group_num + 1;
             g_current_drop_lpn.temp_id_group_ref(l_transaction_temp_id)
               := l_cur_group_num;
             l_group_num := l_cur_group_num;
         END;

         FOR c_srl_numbers_rec IN c_srl_numbers (l_transaction_temp_id)
         LOOP
           BEGIN
             IF l_debug = 1 THEN
                print_debug
                ( 'Inserting item ' || c_item_rec.item_num           ||
                  ', serial # '     || c_srl_numbers_rec.fm_serial_number
                  , l_api_name
                );
             END IF;

             INSERT INTO mtl_allocations_gtmp
             ( inventory_item_id
             , item_number
             , group_number
             , content_lpn
             , inner_lpn
             , loose_qty_exists
             , revision
             , lot_number
             , serial_number
             , lot_alloc
             , serial_alloc
             , transaction_quantity
             , primary_quantity
             , primary_uom_code
             , uom_lookup_code
             )
             VALUES
             ( c_mmtt_rec.inventory_item_id
             , c_item_rec.item_num
             , l_group_num
             , NULL
             , l_inner_lpn
             , 'Y'
             , c_mmtt_rec.revision
             , NULL
             , c_srl_numbers_rec.fm_serial_number
             , l_lot_alloc
             , l_serial_alloc
             , NULL
             , 1
             , c_item_rec.primary_uom_code
             , c_item_rec.uom_lookup_code
             );
           EXCEPTION
             WHEN OTHERS THEN
               IF l_debug = 1 THEN
                  print_debug
                  ( 'Unexpected error inserting allocated serials: ' || sqlerrm
                  , l_api_name
                  );
               END IF;
               IF c_srl_numbers%ISOPEN THEN
                  CLOSE c_srl_numbers;
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
         END LOOP;
      ELSE
         --
         -- No lots or serials allocated, or item is vanilla
         -- or revision controlled
         --

         --
         -- For bulk picks null out LPN stamped by Pick Load
         -- on the child record
         -- Bug6913674 removed SUB & LOC from being nulled out
         IF c_mmtt_rec.parent_line_id IS NOT NULL
         THEN
            UPDATE mtl_material_transactions_temp  mmtt
               SET lpn_id            = NULL
                 , content_lpn_id    = NULL
               WHERE mmtt.transaction_temp_id = l_transaction_temp_id;
         END IF;

         BEGIN
           SELECT group_number
             INTO l_group_num
             FROM mtl_allocations_gtmp  mtg
            WHERE mtg.inventory_item_id    = c_mmtt_rec.inventory_item_id
              AND NVL(mtg.revision,'@@@@') = NVL(c_mmtt_rec.revision,'@@@@')
              AND mtg.inner_lpn   IS NULL
              AND mtg.content_lpn IS NULL;

           IF l_debug = 1 THEN
              print_debug
              ( 'Updating item '     || c_item_rec.item_num  ||
                ', group number '    || to_char(l_group_num) ||
                ', revision '        || c_mmtt_rec.revision  ||
                ' with primary qty ' || to_char(c_mmtt_rec.primary_quantity)
              , l_api_name
              );
           END IF;

           g_current_drop_lpn.temp_id_group_ref(l_transaction_temp_id)
             := l_group_num;

           UPDATE mtl_allocations_gtmp
              SET primary_quantity
                    = primary_quantity + c_mmtt_rec.primary_quantity
            WHERE group_number = l_group_num;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'Inserting item '     || c_item_rec.item_num  ||
                  ', revision '         || c_mmtt_rec.revision  ||
                  ' with primary qty '  || to_char(c_mmtt_rec.primary_quantity) ||
                  ', primary uom code ' || c_item_rec.primary_uom_code
                , l_api_name
                );
             END IF;

             IF c_mmtt_rec.parent_line_id IS NOT NULL
                AND
                p_drop_type <> 'WIP_ISSUE'
                AND
                p_drop_type <> 'WIP_SUB_XFER'
             THEN
                BEGIN
                   SELECT 'x'
                     INTO l_dummy
                     FROM dual
                    WHERE EXISTS
                        ( SELECT 'x'
                            FROM mtl_material_transactions_temp  mmtt
                           WHERE mmtt.organization_id = g_current_drop_lpn.organization_id
                             AND mmtt.transfer_lpn_id = g_current_drop_lpn.lpn_id
                             AND mmtt.parent_line_id  = mmtt.transaction_temp_id
                             AND mmtt.transaction_quantity > 0
                             AND mmtt.inventory_item_id    = c_mmtt_rec.inventory_item_id
                             AND NVL(mmtt.revision,'@@@@') = NVL(c_mmtt_rec.revision,'@@@@')
                             AND mmtt.content_lpn_id IS NOT NULL
                             AND mmtt.content_lpn_id <> mmtt.transfer_lpn_id
                        );
                   l_inner_lpn_exists := 'Y';
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        l_inner_lpn_exists := 'N';
                END;

                BEGIN
                   SELECT 'x'
                     INTO l_dummy
                     FROM dual
                    WHERE EXISTS
                        ( SELECT 'x'
                            FROM mtl_material_transactions_temp  mmtt
                           WHERE mmtt.organization_id = g_current_drop_lpn.organization_id
                             AND mmtt.transfer_lpn_id = g_current_drop_lpn.lpn_id
                             AND mmtt.parent_line_id  = mmtt.transaction_temp_id
                             AND mmtt.transaction_quantity > 0
                             AND mmtt.inventory_item_id    = c_mmtt_rec.inventory_item_id
                             AND NVL(mmtt.revision,'@@@@') = NVL(c_mmtt_rec.revision,'@@@@')
                             AND ( mmtt.content_lpn_id IS NULL
                                   OR
                                   mmtt.content_lpn_id  = mmtt.transfer_lpn_id
                                 )
                        );
                   l_loose_exists := 'Y';
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        l_loose_exists := 'N';
                END;

                IF l_inner_lpn_exists = 'N'
                   AND
                   l_loose_exists = 'N'
                THEN
                   IF l_debug = 1 THEN
                      print_debug
                      ( 'No loose or packed quantities available.'
                      , l_api_name
                      );
                   END IF;

                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

             END IF;

             IF l_debug = 1 THEN
                print_debug
                ( 'l_inner_lpn_exists: ' || l_inner_lpn_exists || ', ' ||
                  'l_loose_exists: '     || l_loose_exists
                , l_api_name
                );
             END IF;


             IF l_inner_lpn_exists = 'Y'
             THEN
	     --Bug6913674
             SELECT  mmtt.content_lpn_id INTO l_inner_lpn_id
                            FROM mtl_material_transactions_temp  mmtt
                           WHERE mmtt.organization_id = g_current_drop_lpn.organization_id
                             AND mmtt.transfer_lpn_id = g_current_drop_lpn.lpn_id
                             AND mmtt.parent_line_id  = mmtt.transaction_temp_id
                             AND mmtt.transaction_quantity > 0
                             AND mmtt.inventory_item_id    = c_mmtt_rec.inventory_item_id
                             AND NVL(mmtt.revision,'@@@@') = NVL(c_mmtt_rec.revision,'@@@@')
                             AND mmtt.content_lpn_id IS NOT NULL
                             AND mmtt.content_lpn_id <> mmtt.transfer_lpn_id ;
             OPEN c_get_lpn (l_inner_lpn_id);
            FETCH c_get_lpn INTO l_inner_lpn;
            CLOSE c_get_lpn;
                --Bug6913674


                -- Bug5659809: update last_update_date and last_update_by as well
                UPDATE wms_license_plate_numbers
                   SET lpn_context = WMS_Container_PUB.LPN_CONTEXT_INV
                     , last_update_date = SYSDATE
                     , last_updated_by = fnd_global.user_id
                 WHERE lpn_id IN
                     ( SELECT mmtt.content_lpn_id
                         FROM mtl_material_transactions_temp  mmtt
                        WHERE mmtt.organization_id = g_current_drop_lpn.organization_id
                          AND mmtt.transfer_lpn_id = g_current_drop_lpn.lpn_id
                          AND mmtt.parent_line_id  = mmtt.transaction_temp_id
                          AND mmtt.content_lpn_id IS NOT NULL
                          AND mmtt.content_lpn_id <> mmtt.transfer_lpn_id
                          AND mmtt.inventory_item_id    = c_mmtt_rec.inventory_item_id
                          AND NVL(mmtt.revision,'@@@@') = NVL(c_mmtt_rec.revision,'@@@@')
                     );

                IF l_debug = 1 AND SQL%FOUND
                THEN
                   print_debug
                   ( 'Updated LPN context back to 1 for nested LPN(s)'
                   , l_api_name
                   );
                END IF;
             END IF;

             IF l_loose_exists = 'Y'
             THEN
                -- Bug5659809: update last_update_date and last_update_by as well
                UPDATE wms_license_plate_numbers
                   SET lpn_context = WMS_Container_PUB.LPN_CONTEXT_INV
                     , last_update_date = SYSDATE
                     , last_updated_by = fnd_global.user_id
                 WHERE lpn_id IN
                     ( SELECT mmtt.content_lpn_id
                         FROM mtl_material_transactions_temp  mmtt
                        WHERE mmtt.organization_id = g_current_drop_lpn.organization_id
                          AND mmtt.transfer_lpn_id = g_current_drop_lpn.lpn_id
                          AND mmtt.parent_line_id  = mmtt.transaction_temp_id
                          AND mmtt.content_lpn_id IS NOT NULL
                          AND mmtt.content_lpn_id  = mmtt.transfer_lpn_id
                          AND mmtt.inventory_item_id    = c_mmtt_rec.inventory_item_id
                          AND NVL(mmtt.revision,'@@@@') = NVL(c_mmtt_rec.revision,'@@@@')
                     );

                IF l_debug = 1 AND SQL%FOUND
                THEN
                   print_debug
                   ( 'Updated LPN context back to 1 for content/transfer LPN'
                   , l_api_name
                   );
                END IF;
             END IF;

             l_cur_group_num := l_cur_group_num + 1;
             g_current_drop_lpn.temp_id_group_ref(l_transaction_temp_id)
               := l_cur_group_num;

             INSERT INTO mtl_allocations_gtmp
             ( inventory_item_id
             , item_number
             , group_number
             , content_lpn
             , inner_lpn
             , inner_lpn_exists
             , loose_qty_exists
             , revision
             , lot_number
             , serial_number
             , lot_alloc
             , serial_alloc
             , transaction_quantity
             , primary_quantity
             , primary_uom_code
             , uom_lookup_code
             )
             VALUES
             ( c_mmtt_rec.inventory_item_id
             , c_item_rec.item_num
             , l_cur_group_num
             , NULL
             , l_inner_lpn --Bug6913674
             , l_inner_lpn_exists
             , l_loose_exists
             , c_mmtt_rec.revision
             , NULL
             , NULL
             , l_lot_alloc
             , l_serial_alloc
             , NULL
             , c_mmtt_rec.primary_quantity
             , c_item_rec.primary_uom_code
             , c_item_rec.uom_lookup_code
             );

           WHEN OTHERS THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'Unexpected error checking if record for '         ||
                  'vanilla/revision/serial (not allocated) exists: ' || sqlerrm
                , l_api_name
                );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;
      END IF;

      IF ii < jj THEN
         ii := g_current_drop_lpn.current_drop_list.NEXT(ii);
         l_transaction_temp_id := ii;
      ELSE
         EXIT;
      END IF;

      IF l_debug = 1 THEN
         print_debug
         ( 'ii = ' || to_char(ii)
         , l_api_name
         );
      END IF;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK to group_drop_det_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

      IF c_mmtt_info%ISOPEN THEN
         CLOSE c_mmtt_info;
      END IF;

  END group_drop_details;



  PROCEDURE split_mmtt
  ( x_new_temp_id    OUT NOCOPY  NUMBER
  , x_return_status  OUT NOCOPY  VARCHAR2
  , p_temp_id        IN          NUMBER
  ) IS

    l_api_name      VARCHAR2(30) := 'split_mmtt';
    l_debug         NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_new_temp_id   NUMBER;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with p_temp_id => ' || to_char(p_temp_id)
       , l_api_name
       );
    END IF;

    SAVEPOINT split_mmtt_sp;

    SELECT mtl_material_transactions_s.NEXTVAL
      INTO l_new_temp_id
      FROM dual;

    IF l_debug = 1 THEN
       print_debug
       ( 'About to insert temp ID ' || to_char(l_new_temp_id)
       , l_api_name
       );
    END IF;

    INSERT INTO mtl_material_transactions_temp
    ( transaction_header_id
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
    , error_code
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
    , parent_line_id
    , transfer_cost_group_id
    , lpn_id
    , transfer_lpn_id
    , content_lpn_id
    , operation_plan_id
    , move_order_header_id
    , serial_allocated_flag
    )
    ( SELECT transaction_header_id
           , l_new_temp_id
           , source_code
           , source_line_id
           , transaction_mode
           , lock_flag
           , SYSDATE
           , fnd_global.user_id
           , SYSDATE
           , fnd_global.user_id
           , fnd_global.login_id
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
           , error_code
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
           , parent_line_id
           , transfer_cost_group_id
           , NULL
           , transfer_lpn_id
           , NULL
           , operation_plan_id
           , move_order_header_id
           , serial_allocated_flag
         FROM mtl_material_transactions_temp
        WHERE transaction_temp_id = p_temp_id
    );

    g_current_drop_lpn.current_drop_list(l_new_temp_id) := 'PENDING';

    IF l_debug = 1 THEN
       print_debug( 'About to insert WDT record', l_api_name);
    END IF;

    -- Bug 4884284: insert WDT record for new child MMTT
    INSERT INTO wms_dispatched_tasks
    ( task_id
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
    ( SELECT wms_dispatched_tasks_s.NEXTVAL
           , l_new_temp_id
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
           , wdt.last_updated_by
           , SYSDATE
           , wdt.created_by
           , wdt.task_type
           , wdt.loaded_time
           , mmtt.operation_plan_id
           , mmtt.move_order_line_id
        FROM wms_dispatched_tasks  wdt
           , mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id
         AND wdt.transaction_temp_id  = mmtt.transaction_temp_id
    );

    -- Bug 3902766
    IF g_current_drop_lpn.temp_id_group_ref.exists(p_temp_id) THEN
       g_current_drop_lpn.temp_id_group_ref(l_new_temp_id) := g_current_drop_lpn.temp_id_group_ref(p_temp_id);
    END IF;

    x_new_temp_id := l_new_temp_id;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK to split_mmtt_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END split_mmtt;



  PROCEDURE get_temp_list
  ( x_temp_tbl       OUT NOCOPY  g_temp_id_tbl
  , x_return_status  OUT NOCOPY  VARCHAR2
  , p_group_num      IN          NUMBER    DEFAULT NULL
  , p_status         IN          VARCHAR2  DEFAULT NULL
  ) IS

    l_api_name             VARCHAR2(30) := 'get_temp_list';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    ii                     NUMBER;
    l_transaction_temp_id  NUMBER;

    l_group_match          BOOLEAN;
    l_status_match         BOOLEAN;

    l_temp_ids             VARCHAR2(4000);   -- For bug#9247514
    l_mmtt_cur_str         VARCHAR2(4000);   -- For bug#9247514

    TYPE cur_typ IS REF CURSOR;   -- For bug#9247514
    l_mmtt_cur           cur_typ;   -- For bug#9247514

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline            ||
         'p_group_num => '           || to_char(p_group_num) || g_newline ||
         'p_status    => '           || p_status
       , l_api_name
       );
    END IF;

    x_temp_tbl.DELETE;

    l_transaction_temp_id := g_current_drop_lpn.current_drop_list.FIRST;

    /* Added for bug#9247514 */

    l_temp_ids:=To_Char(l_transaction_temp_id);

    LOOP

       IF l_transaction_temp_id = g_current_drop_lpn.current_drop_list.LAST
       THEN
          EXIT;
       ELSE
          l_transaction_temp_id := g_current_drop_lpn.current_drop_list.NEXT(l_transaction_temp_id);
       END IF;

       l_temp_ids:=l_temp_ids||', '||To_Char(l_transaction_temp_id);

    END LOOP;

    l_transaction_temp_id:=NULL;

    l_mmtt_cur_str :='SELECT mmtt.TRANSACTION_TEMP_ID FROM mtl_material_transactions_temp mmtt, wms_dispatched_tasks wdt '||
                      ' WHERE mmtt.TRANSACTION_TEMP_ID=wdt.TRANSACTION_TEMP_ID(+) and mmtt.TRANSACTION_TEMP_ID in ('||l_temp_ids||') ORDER BY wdt.loaded_time';

    ii := 1;

    IF l_debug = 1 THEN
      print_debug(l_mmtt_cur_str, l_api_name);
    END IF;

    OPEN l_mmtt_cur FOR l_mmtt_cur_str;   -- For bug#9247514

    LOOP

      FETCH l_mmtt_cur INTO l_transaction_temp_id;   -- For bug#9247514
      EXIT WHEN l_mmtt_cur%NOTFOUND;   -- For bug#9247514

      IF l_debug = 1 THEN
         print_debug ('l_transaction_temp_id: ' || l_transaction_temp_id, l_api_name);
      END IF;

       l_group_match  := FALSE;
       l_status_match := FALSE;

       IF ( ( p_group_num IS NOT NULL
              AND
              p_group_num = g_current_drop_lpn.temp_id_group_ref(l_transaction_temp_id)
            )
            OR
            p_group_num IS NULL
          )
       THEN
          l_group_match := TRUE;
       ELSE
          l_group_match := FALSE;
       END IF;

       IF ( ( p_status IS NOT NULL
              AND
              p_status = g_current_drop_lpn.current_drop_list(l_transaction_temp_id)
            )
            OR
            p_status IS NULL
          )
       THEN
          l_status_match := TRUE;
       ELSE
          l_status_match := FALSE;
       END IF;

       IF l_group_match AND l_status_match
       THEN
          x_temp_tbl(ii) := l_transaction_temp_id;
          ii := ii + 1;
       END IF;

/*       IF l_transaction_temp_id = g_current_drop_lpn.current_drop_list.LAST
       THEN
          EXIT;
       ELSE
          l_transaction_temp_id := g_current_drop_lpn.current_drop_list.NEXT(l_transaction_temp_id);
       END IF; */   -- For bug#9247514

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END get_temp_list;



  PROCEDURE split_lots
  ( x_return_status  OUT NOCOPY  VARCHAR2
  ) IS

    l_api_name             VARCHAR2(30) := 'split_lots';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_api_return_status    VARCHAR2(1);

    l_temp_tbl             g_temp_id_tbl;
    l_transaction_temp_id  NUMBER;
    l_count                NUMBER;
    l_orig_temp_id         NUMBER;

    ii                     NUMBER;
    jj                     NUMBER;


    CURSOR c_get_lot_count
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT COUNT(*)
        FROM mtl_transaction_lots_temp  mtlt
       WHERE mtlt.transaction_temp_id = p_temp_id;


    CURSOR c_get_lot_details
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mtlt.rowid
           , mtlt.lot_number
           , mtlt.transaction_quantity
           , mtlt.primary_quantity
        FROM mtl_transaction_lots_temp  mtlt
       WHERE mtlt.transaction_temp_id = p_temp_id;

    lot_dtl_rec  c_get_lot_details%ROWTYPE;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT split_lots_sp;

    l_api_return_status := fnd_api.g_ret_sts_success;
    get_temp_list
    ( x_temp_tbl      => l_temp_tbl
    , x_return_status => l_api_return_status
    , p_group_num     => NULL
    , p_status        => NULL
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug ('Error from get_temp_list', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_temp_tbl.COUNT > 0 THEN
       ii := l_temp_tbl.FIRST;
       jj := l_temp_tbl.LAST;

       IF l_debug = 1 THEN
          print_debug
          ( 'ii = ' || to_char(ii) || ', jj = ' || to_char(jj)
          , l_api_name
          );
       END IF;

       l_transaction_temp_id := l_temp_tbl(ii);
       WHILE (ii <= jj)
       LOOP
          IF l_debug = 1 THEN
             print_debug
             ( 'Checking temp ID ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;

          OPEN c_get_lot_count (l_transaction_temp_id);
          FETCH c_get_lot_count INTO l_count;
          CLOSE c_get_lot_count;

          IF l_count > 1 THEN

             IF l_debug = 1 THEN
                print_debug
                ( 'Lot count: ' || to_char(l_count)
                , l_api_name
                );
             END IF;

             l_orig_temp_id := l_transaction_temp_id;

             OPEN c_get_lot_details (l_orig_temp_id);
             FETCH c_get_lot_details INTO lot_dtl_rec;

             --
             -- Discard the first row
             --
             FETCH c_get_lot_details INTO lot_dtl_rec;

             IF l_debug = 1 THEN
                print_debug
                ( 'Fetched lot #: '    || lot_dtl_rec.lot_number
                  || ', txn qty: '     || to_char(lot_dtl_rec.transaction_quantity)
                  || ', primary qty: ' || to_char(lot_dtl_rec.primary_quantity)
                , l_api_name
                );
             END IF;

             WHILE (c_get_lot_details%FOUND)
             LOOP
                l_api_return_status := fnd_api.g_ret_sts_success;
                split_mmtt
                ( x_new_temp_id   => l_transaction_temp_id
                , x_return_status => l_api_return_status
                , p_temp_id       => l_orig_temp_id
                );

                IF l_api_return_status <> fnd_api.g_ret_sts_success
                THEN
                   IF l_debug = 1 THEN
                      print_debug ('Error from split_mmtt', l_api_name);
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                UPDATE mtl_material_transactions_temp
                   SET transaction_quantity = transaction_quantity
                                                 - lot_dtl_rec.transaction_quantity
                     , primary_quantity     = primary_quantity
                                                 - lot_dtl_rec.primary_quantity
                     , reservation_quantity = DECODE( reservation_quantity
                                                    , NULL, NULL
                                                    , reservation_quantity
                                                         - lot_dtl_rec.primary_quantity
                                                    )
                 WHERE transaction_temp_id = l_orig_temp_id;

                IF l_debug = 1 THEN
                   print_debug
                   ( 'Reduced txn and primary qty for original temp ID '
                     || to_char(l_orig_temp_id)
                   , l_api_name
                   );
                END IF;

                UPDATE mtl_material_transactions_temp
                   SET transaction_quantity = lot_dtl_rec.transaction_quantity
                     , primary_quantity     = lot_dtl_rec.primary_quantity
                     , reservation_quantity = DECODE( reservation_quantity
                                                    , NULL, NULL
                                                    , lot_dtl_rec.primary_quantity
                                                    )
                 WHERE transaction_temp_id = l_transaction_temp_id;

                IF l_debug = 1 THEN
                   print_debug
                   ('Updated new temp ID ' || to_char(l_transaction_temp_id)
                   , l_api_name
                   );
                END IF;

                UPDATE mtl_transaction_lots_temp
                   SET transaction_temp_id = l_transaction_temp_id
                 WHERE rowid = lot_dtl_rec.rowid;

                IF l_debug = 1 THEN
                   print_debug
                   ( 'Updated MTLT record for lot ' || lot_dtl_rec.lot_number
                     || ' to new temp ID '          || to_char(l_transaction_temp_id)
                   , l_api_name
                   );
                END IF;

                FETCH c_get_lot_details INTO lot_dtl_rec;

             END LOOP;

             CLOSE c_get_lot_details;
          END IF; -- end if l_count > 1;

          IF ii < jj THEN
             ii := l_temp_tbl.NEXT(ii);
             l_transaction_temp_id := l_temp_tbl(ii);
          ELSE
             EXIT;
          END IF;

          IF l_debug = 1 THEN
             print_debug
             ( 'Fetched next temp ID: ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;
       END LOOP;
    END IF; -- end IF l_temp_tbl.COUNT > 0

    l_temp_tbl.DELETE;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK to split_lots_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF c_get_lot_details%ISOPEN
      THEN
         CLOSE c_get_lot_details;
      END IF;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END split_lots;



  --
  -- Name
  --   PROCEDURE FETCH_NEXT_DROP
  --
  -- Purpose
  --   This API returns details for the next available drop
  --   (called only if the LPN requires deconsolidation)
  --
  -- Input Parameters
  --   p_organization_id - Org ID
  --   p_transfer_lpn_id - LPN being dropped
  --
  -- Output Parameters
  --   x_return_status   - fnd_api.g_ret_sts_error
  --                     - fnd_api.g_ret_sts_unexp_error
  --

  PROCEDURE fetch_next_drop
  ( x_drop_type        OUT NOCOPY   VARCHAR2
  , x_bulk_pick        OUT NOCOPY   VARCHAR2
  , x_drop_lpn_option  OUT NOCOPY   NUMBER
  , x_delivery_id      OUT NOCOPY   NUMBER
  , x_tasks            OUT NOCOPY   t_genref
  , x_lpn_done         OUT NOCOPY   VARCHAR2
  , x_first_temp_id    OUT NOCOPY   NUMBER
  , x_total_qty        OUT NOCOPY   NUMBER  -- Added for bug 12853197
  , x_task_type        OUT NOCOPY   NUMBER
  , x_txn_type_id      OUT NOCOPY   NUMBER
  , x_return_status    OUT NOCOPY   VARCHAR2
  , p_organization_id  IN           NUMBER
  , p_transfer_lpn_id  IN           NUMBER
  ) IS

    l_api_name             VARCHAR2(30) := 'fetch_next_drop';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_api_return_status    VARCHAR2(1);

    l_progress             NUMBER       := 0;

    l_details_done         BOOLEAN      := FALSE;
    l_group_end            BOOLEAN;

    l_transaction_temp_id  NUMBER;
    l_parent_temp_id       NUMBER;
    l_task_type            NUMBER;
    l_txn_type_id          NUMBER;
    l_count                NUMBER       := 0;
    -- bug#10062741
	l_line_rows                   WSH_UTIL_CORE.id_tab_type;   --Bug 10062741
    l_grouping_rows               WSH_UTIL_CORE.id_tab_type;   --Bug 10062741
    l_return_status               VARCHAR2(2) ;   --Bug 10062741

    CURSOR c_remaining_tasks
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      -- Staging xfers not in cancelled status
      SELECT 1  line_type
           , NVL(msi.dropping_order, 0)  sub_dropping_order
           , NVL(msi.picking_order, 0)   sub_picking_order
           , mmtt.transfer_subinventory  transfer_subinventory
           , NVL(mil.dropping_order, 0)  loc_dropping_order
           , NVL(mil.picking_order, 0)   loc_picking_order
           , mmtt.transfer_to_location   transfer_to_location
		   , null loaded_time  -- Added for bug 12853197
           , NVL(wda.delivery_id,-1)-- bug#10062741 NVL(wda.delivery_id,NVL(mtrl.carton_grouping_id,0))
                                         delivery_id
			,wdd.delivery_detail_id delivery_detail_id --Bug 10062741
           , 0  txn_source_id
           , 0  txn_source_line_id
           , 0  reference_id
           , mmtt.transaction_temp_id
           , mmtt.inventory_item_id      inventory_item_id
           , mmtt.revision               revision
           , DECODE( mmtt.parent_line_id
                   , NULL, 0
                   , 1
                   ) parent_line_id
        FROM mtl_material_transactions_temp  mmtt
           , mtl_secondary_inventories       msi
           , mtl_item_locations              mil
           , mtl_txn_request_lines           mtrl
           , wsh_delivery_details_ob_grp_v            wdd
           , wsh_delivery_assignments_v        wda
       WHERE mmtt.organization_id = p_org_id
         AND mmtt.transfer_lpn_id = p_lpn_id
         AND mmtt.transaction_action_id = 28
         AND ( (mmtt.parent_line_id IS NOT NULL
                AND
                mmtt.parent_line_id <> mmtt.transaction_temp_id
               )
               OR
               mmtt.parent_line_id  IS NULL
             )
         AND mmtt.organization_id       = msi.organization_id
         AND mmtt.transfer_subinventory = msi.secondary_inventory_name
         AND mmtt.organization_id       = mil.organization_id
         AND mmtt.transfer_subinventory = mil.subinventory_code
         AND mmtt.transfer_to_location  = mil.inventory_location_id
         AND mmtt.move_order_line_id    = mtrl.line_id
         AND mtrl.line_status          <> 9
         AND mtrl.organization_id       = wdd.organization_id
         AND mtrl.line_id               = wdd.move_order_line_id
         and wdd.delivery_detail_id     = wda.delivery_detail_id
       UNION ALL
      -- Non-WIP sub xfers, not in cancelled status
      SELECT 2  line_type
           , NVL(msi.dropping_order, 0)  sub_dropping_order
           , NVL(msi.picking_order, 0)   sub_picking_order
           , mmtt.transfer_subinventory  transfer_subinventory
           , NVL(mil.dropping_order, 0)  loc_dropping_order
           , NVL(mil.picking_order, 0)   loc_picking_order
           , mmtt.transfer_to_location   transfer_to_location
           , max(wdt.loaded_time) over (PARTITION BY mmtt.transfer_subinventory, mmtt.transfer_to_location, mmtt.inventory_item_id, mmtt.revision) loaded_time --Bug#12853197
           , 0  delivery_id
		   , 0  delivery_detail_id --Bug 10062741
           , 0  txn_source_id
           , 0  txn_source_line_id
           , 0  reference_id
           , mmtt.transaction_temp_id
           , mmtt.inventory_item_id      inventory_item_id
           , mmtt.revision               revision
           , DECODE( mmtt.parent_line_id
                   , NULL, 0
                   , 1
                   ) parent_line_id
        FROM mtl_material_transactions_temp  mmtt
           , mtl_secondary_inventories       msi
           , mtl_item_locations              mil
           , mtl_txn_request_lines           mtrl
           , mtl_txn_request_headers         mtrh
           , wms_dispatched_tasks            wdt  -- Added for bug 12853197
       WHERE mmtt.organization_id       = p_org_id
         AND mmtt.transfer_lpn_id       = p_lpn_id
         AND mmtt.transaction_action_id = 2
         AND ( (mmtt.parent_line_id IS NOT NULL
                AND
                mmtt.parent_line_id <> mmtt.transaction_temp_id
               )
               OR
               mmtt.parent_line_id  IS NULL
             )
         AND mmtt.organization_id       = msi.organization_id
         AND mmtt.transfer_subinventory = msi.secondary_inventory_name
         AND mmtt.organization_id       = mil.organization_id
         AND mmtt.transfer_subinventory = mil.subinventory_code
         AND mmtt.transfer_to_location  = mil.inventory_location_id
         AND mmtt.move_order_line_id    = mtrl.line_id
         AND mtrl.line_status          <> 9
         AND mtrl.header_id             = mtrh.header_id
         AND mtrh.move_order_type      <> 5
         AND wdt.transaction_temp_id(+) = mmtt.transaction_temp_id  -- Added for bug 12853197
       UNION ALL
      -- WIP sub xfers, not in cancelled status
      SELECT 3  line_type
           , NVL(msi.dropping_order, 0)  sub_dropping_order
           , NVL(msi.picking_order, 0)   sub_picking_order
           , mmtt.transfer_subinventory  transfer_subinventory
           , NVL(mil.dropping_order, 0)  loc_dropping_order
           , NVL(mil.picking_order, 0)   loc_picking_order
           , mmtt.transfer_to_location   transfer_to_location
           , null loaded_time  -- Added for bug 12853197
           , 0  delivery_id
		   , 0  delivery_detail_id --Bug 10062741
           , 0  txn_source_id
           , 0  txn_source_line_id
           , 0  reference_id
           , mmtt.transaction_temp_id
           , mmtt.inventory_item_id      inventory_item_id
           , mmtt.revision               revision
           , DECODE( mmtt.parent_line_id
                   , NULL, 0
                   , 1
                   ) parent_line_id
        FROM mtl_material_transactions_temp  mmtt
           , mtl_secondary_inventories       msi
           , mtl_item_locations              mil
           , mtl_txn_request_lines           mtrl
           , mtl_txn_request_headers         mtrh
       WHERE mmtt.organization_id       = p_org_id
         AND mmtt.transfer_lpn_id       = p_lpn_id
         AND mmtt.transaction_action_id = 2
         AND ( (mmtt.parent_line_id IS NOT NULL
                AND
                mmtt.parent_line_id <> mmtt.transaction_temp_id
               )
               OR
               mmtt.parent_line_id  IS NULL
             )
         AND mmtt.organization_id       = msi.organization_id
         AND mmtt.transfer_subinventory = msi.secondary_inventory_name
         AND mmtt.organization_id       = mil.organization_id
         AND mmtt.transfer_subinventory = mil.subinventory_code
         AND mmtt.transfer_to_location  = mil.inventory_location_id
         AND mmtt.move_order_line_id    = mtrl.line_id
         AND mtrl.line_status          <> 9
         AND mtrl.header_id             = mtrh.header_id
         AND mtrh.move_order_type       = 5
       UNION ALL
      -- WIP issues, not in cancelled status
      SELECT 4  line_type
           , 0  sub_dropping_order
           , 0  sub_picking_order
           , to_char(NULL)  transfer_subinventory
           , 0  loc_dropping_order
           , 0  loc_picking_order
           , 0  transfer_to_location
           , null loaded_time  -- Added for bug 12853197
           , 0  delivery_id
		   , 0  delivery_detail_id --Bug 10062741
           , mtrl.txn_source_id
           , mtrl.txn_source_line_id
           , mtrl.reference_id
           , mmtt.transaction_temp_id
           , mmtt.inventory_item_id
           , mmtt.revision
           , DECODE( mmtt.parent_line_id
                   , NULL, 0
                   , 1
                   ) parent_line_id
        FROM mtl_material_transactions_temp  mmtt
           , mtl_txn_request_lines           mtrl
       WHERE mmtt.organization_id = p_org_id
         AND mmtt.transfer_lpn_id = p_lpn_id
         AND mmtt.transaction_action_id      = 1
         AND mmtt.transaction_source_type_id = 5
         AND ( (mmtt.parent_line_id IS NOT NULL
                AND
                mmtt.parent_line_id <> mmtt.transaction_temp_id
               )
               OR
               mmtt.parent_line_id  IS NULL
             )
         AND mmtt.move_order_line_id = mtrl.line_id
         AND mtrl.line_status       <> 9
       UNION ALL
      -- Cancelled lines
      SELECT 5  line_type
           , 0  sub_dropping_order
           , 0  sub_picking_order
           , to_char(NULL)  transfer_subinventory
           , 0  loc_dropping_order
           , 0  loc_picking_order
           , 0  transfer_to_location
           , null loaded_time  -- Added for bug 12853197
           , 0  delivery_id
		   , 0  delivery_detail_id --Bug 10062741
           , 0  txn_source_id
           , 0  txn_source_line_id
           , 0  reference_id
           , mmtt.transaction_temp_id
           , mmtt.inventory_item_id
           , mmtt.revision
           , DECODE( mmtt.parent_line_id
                   , NULL, 0
                   , 1
                   ) parent_line_id
        FROM mtl_material_transactions_temp  mmtt
           , mtl_txn_request_lines           mtrl
       WHERE mmtt.organization_id        = p_org_id
         AND mmtt.transfer_lpn_id        = p_lpn_id
         AND mmtt.transaction_action_id IN (2,28)
         AND mmtt.move_order_line_id     = mtrl.line_id
         AND ( (mmtt.parent_line_id  IS NOT NULL
                AND
                mmtt.parent_line_id  <> mmtt.transaction_temp_id
               )
               OR
               mmtt.parent_line_id   IS NULL
             )
         AND mtrl.line_status            = 9
       UNION ALL
      -- Overpicked lines, other sub xfers without move orders
      SELECT 6  line_type
           , 0  sub_dropping_order
           , 0  sub_picking_order
           , to_char(NULL)  transfer_subinventory
           , 0  loc_dropping_order
           , 0  loc_picking_order
           , 0  transfer_to_location
           , null loaded_time  -- Added for bug 12853197
           , 0  delivery_id
		   , 0  delivery_detail_id --Bug 10062741
           , 0  txn_source_id
           , 0  txn_source_line_id
           , 0  reference_id
           , mmtt.transaction_temp_id
           , mmtt.inventory_item_id
           , mmtt.revision
           , DECODE( mmtt.parent_line_id
                   , NULL, 0
                   , 1
                   ) parent_line_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id = p_org_id
         AND mmtt.transfer_lpn_id = p_lpn_id
         AND mmtt.transaction_action_id = 2
         AND mmtt.move_order_line_id IS NULL
         AND ( (mmtt.parent_line_id  IS NOT NULL
                AND
                mmtt.parent_line_id  <> mmtt.transaction_temp_id
               )
               OR
               mmtt.parent_line_id   IS NULL
             )
       ORDER BY 1,2,3,4,5,6,7,8 desc,9,10,11,13,14,15;  -- Modified for bug 12853197

    c_tasks_curr_rec  c_remaining_tasks%ROWTYPE;
    c_tasks_orig_rec  c_remaining_tasks%ROWTYPE;


    CURSOR c_get_txn_type
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mmtt.transaction_type_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id)
       , l_api_name
       );
    END IF;

    l_progress := 10;

    OPEN c_remaining_tasks(p_organization_id, p_transfer_lpn_id);
    FETCH c_remaining_tasks INTO c_tasks_curr_rec;

    l_progress := 20;

    IF c_remaining_tasks%FOUND
    THEN
       g_current_drop_lpn.current_drop_list.DELETE;
       g_current_drop_lpn.temp_id_group_ref.DELETE;
       g_current_drop_lpn.current_drop_list(c_tasks_curr_rec.transaction_temp_id) := 'PENDING';

       c_tasks_orig_rec := c_tasks_curr_rec;

       OPEN c_get_txn_type (c_tasks_curr_rec.transaction_temp_id);
       FETCH c_get_txn_type INTO l_txn_type_id;
       CLOSE c_get_txn_type;
       x_txn_type_id := l_txn_type_id;

       x_drop_lpn_option := g_current_drop_lpn.drop_lpn_option;

       l_progress := 30;

       LOOP
         l_group_end := FALSE;

         IF l_debug = 1 THEN
            print_debug
            ( 'Original record: ' || g_newline ||
              'Txn temp ID:     ' || to_char(c_tasks_orig_rec.transaction_temp_id)  ||
               g_newline          ||
              'Line type:       ' || to_char(c_tasks_orig_rec.line_type)            ||
               g_newline          ||
              'Sub drop order:  ' || to_char(c_tasks_orig_rec.sub_dropping_order)   ||
               g_newline          ||
              'Sub pick order:  ' || to_char(c_tasks_orig_rec.sub_picking_order)    ||
               g_newline          ||
              'Xfer sub:        ' || c_tasks_orig_rec.transfer_subinventory         ||
               g_newline          ||
              'Loc drop order:  ' || to_char(c_tasks_orig_rec.loc_dropping_order)   ||
               g_newline          ||
              'Loc pick order:  ' || to_char(c_tasks_orig_rec.loc_picking_order)    ||
               g_newline          ||
              'Xfer loc:        ' || to_char(c_tasks_orig_rec.transfer_to_location) ||
               g_newline          ||
              'Delivery ID:     ' || to_char(c_tasks_orig_rec.delivery_id)          ||
               g_newline          ||
              'Txn src ID:      ' || to_char(c_tasks_orig_rec.txn_source_id)        ||
               g_newline          ||
              'Txn src line ID: ' || to_char(c_tasks_orig_rec.txn_source_line_id)   ||
               g_newline          ||
              'Reference ID:    ' || to_char(c_tasks_orig_rec.reference_id)         ||
               g_newline          ||
              'Item ID:         ' || to_char(c_tasks_orig_rec.inventory_item_id)    ||
               g_newline          ||
              'Revision:        ' || c_tasks_orig_rec.revision                      ||
               g_newline          ||
              'Parent line ID:  ' || to_char(c_tasks_orig_rec.parent_line_id)
            , l_api_name
            );
         END IF;

         FETCH c_remaining_tasks INTO c_tasks_curr_rec;
         EXIT WHEN c_remaining_tasks%NOTFOUND;

         IF l_debug = 1 THEN
            print_debug
            ( 'New record:      ' || g_newline ||
              'Txn temp ID:     ' || to_char(c_tasks_curr_rec.transaction_temp_id)  ||
               g_newline          ||
              'Line type:       ' || to_char(c_tasks_curr_rec.line_type)            ||
               g_newline          ||
              'Sub drop order:  ' || to_char(c_tasks_curr_rec.sub_dropping_order)   ||
               g_newline          ||
              'Sub pick order:  ' || to_char(c_tasks_curr_rec.sub_picking_order)    ||
               g_newline          ||
              'Xfer sub:        ' || c_tasks_curr_rec.transfer_subinventory         ||
               g_newline          ||
              'Loc drop order:  ' || to_char(c_tasks_curr_rec.loc_dropping_order)   ||
               g_newline          ||
              'Loc pick order:  ' || to_char(c_tasks_curr_rec.loc_picking_order)    ||
               g_newline          ||
              'Xfer loc:        ' || to_char(c_tasks_curr_rec.transfer_to_location) ||
               g_newline          ||
              'Delivery ID:     ' || to_char(c_tasks_curr_rec.delivery_id)          ||
               g_newline          ||
              'Txn src ID:      ' || to_char(c_tasks_curr_rec.txn_source_id)        ||
               g_newline          ||
              'Txn src line ID: ' || to_char(c_tasks_curr_rec.txn_source_line_id)   ||
               g_newline          ||
              'Reference ID:    ' || to_char(c_tasks_curr_rec.reference_id)         ||
               g_newline          ||
              'Item ID:         ' || to_char(c_tasks_curr_rec.inventory_item_id)    ||
               g_newline          ||
              'Revision:        ' || c_tasks_curr_rec.revision                      ||
               g_newline          ||
              'Parent line ID:  ' || to_char(c_tasks_curr_rec.parent_line_id)
            , l_api_name
            );
         END IF;

         IF c_tasks_curr_rec.line_type <> c_tasks_orig_rec.line_type
            OR
            NVL(c_tasks_curr_rec.transfer_subinventory,'@@@@@@@@@@@') <>
               NVL(c_tasks_orig_rec.transfer_subinventory,'@@@@@@@@@@@')
            OR
            c_tasks_curr_rec.transfer_to_location <> c_tasks_orig_rec.transfer_to_location
            OR
            c_tasks_curr_rec.delivery_id <> c_tasks_orig_rec.delivery_id
            OR
            c_tasks_curr_rec.txn_source_id <> c_tasks_orig_rec.txn_source_id
            OR
            c_tasks_curr_rec.txn_source_line_id <> c_tasks_orig_rec.txn_source_line_id
            OR
            c_tasks_curr_rec.reference_id <> c_tasks_orig_rec.reference_id
            OR
            -- bug 12853197
            (g_suggestion_drop <>'NONE'
             AND
             g_chk_mult_subinv <>'N'
             AND
             c_tasks_curr_rec.line_type = c_tasks_orig_rec.line_type
             AND
             c_tasks_curr_rec.inventory_item_id = c_tasks_orig_rec.inventory_item_id
			 AND
             NVL(c_tasks_curr_rec.revision,'@@@@') <> NVL(c_tasks_orig_rec.revision,'@@@@')
            )
            OR
			(g_suggestion_drop <>'NONE'
             AND
             g_chk_mult_subinv <>'N'
             AND
             c_tasks_curr_rec.line_type = c_tasks_orig_rec.line_type
             AND
             c_tasks_curr_rec.inventory_item_id <> c_tasks_orig_rec.inventory_item_id
            )
            OR
            (c_tasks_curr_rec.line_type IN (3,4)
             AND
             c_tasks_curr_rec.line_type = c_tasks_orig_rec.line_type
             AND
             c_tasks_curr_rec.inventory_item_id <> c_tasks_orig_rec.inventory_item_id
            )
            OR
            (c_tasks_curr_rec.line_type IN (3,4)
             AND
             c_tasks_curr_rec.line_type = c_tasks_orig_rec.line_type
             AND
             c_tasks_curr_rec.inventory_item_id = c_tasks_orig_rec.inventory_item_id
             AND
             NVL(c_tasks_curr_rec.revision,'@@@@') <> NVL(c_tasks_orig_rec.revision,'@@@@')
            )
            OR
            NVL(c_tasks_curr_rec.parent_line_id,0) <> NVL(c_tasks_orig_rec.parent_line_id,0)
         THEN
            IF l_debug = 1 THEN
               print_debug
               ( 'Current record is a new group, so exit inner loop'
               , l_api_name
               );
            END IF;
            l_group_end := TRUE;
         ELSE

		 --Bug 10062741
            IF (c_tasks_orig_rec.delivery_id = -1 AND c_tasks_curr_rec.delivery_id = -1) THEN
                l_line_rows(1) := c_tasks_orig_rec.delivery_detail_id;
                l_line_rows(2) := c_tasks_curr_rec.delivery_detail_id;

                IF (l_debug = 1) THEN
                  print_debug('Before calling WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping() to decide if we can drop in the same task', l_api_name);
                  print_debug('Parameters : delivery_detail_id(1):'|| l_line_rows(1) ||' , delivery_detail_id(2) :'||l_line_rows(2), l_api_name);
                END IF;
                --
                -- call to the shipping API.
                --
                WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping(
                           p_line_rows      => l_line_rows,
                           x_grouping_rows  => l_grouping_rows,
                           x_return_status  => l_return_status);
                --
                IF (l_return_status = FND_API.G_RET_STS_SUCCESS
                   AND l_grouping_rows (1) = l_grouping_rows(2) )  THEN

					IF l_debug = 1 THEN
					   print_debug
					   ( 'Current record is in the same group'
					   , l_api_name
					   );
					END IF;
					g_current_drop_lpn.current_drop_list(c_tasks_curr_rec.transaction_temp_id) := 'PENDING';
					c_tasks_orig_rec := c_tasks_curr_rec;
				ELSE

				   IF l_debug = 1 THEN
					 print_debug
					 ( 'Current record is a new group, so exit inner loop'
					 , l_api_name
					 );
				   END IF;
				   l_group_end := TRUE;

				END IF;
			ELSE
				IF l_debug = 1 THEN
				   print_debug
				   ( 'Current record is in the same group'
				   , l_api_name
				   );
				END IF;
				g_current_drop_lpn.current_drop_list(c_tasks_curr_rec.transaction_temp_id) := 'PENDING';
				c_tasks_orig_rec := c_tasks_curr_rec;
			END IF;
		 END IF;
         EXIT WHEN l_group_end;
       END LOOP;

       IF l_debug = 1 THEN
          print_debug
          ( '# of temp IDs in group: ' ||
            to_char(g_current_drop_lpn.current_drop_list.COUNT)
          , l_api_name
          );
       END IF;

       IF NOT g_current_drop_lpn.current_drop_list.COUNT > 0
       THEN
          fnd_message.set_name('WMS', 'WMS_DROP_LPN_NO_MTL');
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    ELSE
       IF l_debug = 1 THEN
          print_debug
          ( 'No material available on this LPN for drop'
          , l_api_name
          );
       END IF;

       fnd_message.set_name('WMS', 'WMS_DROP_LPN_NO_MTL');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF; -- end if c_remaining_tasks%FOUND

    l_progress := 40;

    IF c_remaining_tasks%NOTFOUND
    THEN
       x_lpn_done := 'TRUE';
    ELSE
       x_lpn_done := 'FALSE';
    END IF;
    CLOSE c_remaining_tasks;

    l_progress := 50;

    --
    -- Derive drop type, etc.
    --
    l_transaction_temp_id := g_current_drop_lpn.current_drop_list.FIRST;

    x_first_temp_id := l_transaction_temp_id;

    l_api_return_status := fnd_api.g_ret_sts_success;
    get_group_info
    ( x_drop_type     => x_drop_type
    , x_bulk_pick     => x_bulk_pick
    , x_delivery_id   => x_delivery_id
    , x_task_type     => x_task_type
    , x_return_status => l_api_return_status
    , p_txn_temp_id   => l_transaction_temp_id
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Error from get_group_info'
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Don't deconsolidate replenishments
    -- and move order sub xfers
    --
    -- Deconsolidating for sub xfers if destination sub is not LPN controlled. bug 12853197

    IF x_drop_type <> 'SUB_XFER' OR (g_suggestion_drop <>'NONE' AND g_chk_mult_subinv <>'N')  -- Modified for bug 12853197
    THEN
       --
       -- Process mtlt records for all temp IDs in current drop
       -- This is required so that we do not have more than
       -- one lot/revision per temp ID, and one temp ID
       -- will only belong to one group in the drop page.
       --
       l_api_return_status := fnd_api.g_ret_sts_success;
       split_lots(x_return_status => l_api_return_status);

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'Error from split_lots'
             , l_api_name
             );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       l_api_return_status := fnd_api.g_ret_sts_success;
       group_drop_details(x_drop_type, l_api_return_status);

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'Error from group_drop_details'
             , l_api_name
             );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       BEGIN
         SELECT count(*)
           INTO l_count
           FROM mtl_allocations_gtmp;

         IF l_debug = 1 THEN
            print_debug
            ( 'Count from mtl_allocations_gtmp: ' || to_char(l_count)
            , l_api_name
            );
         END IF;

       EXCEPTION
         WHEN OTHERS THEN
           l_count := 0;
           IF l_debug = 1 THEN
              print_debug
              ( 'Exception when checking record count in temp table: ' || sqlerrm
              , l_api_name
              );
           END IF;
       END;

       IF l_count > 0 THEN
          OPEN x_tasks FOR   -- Modified for bug 12853197
            SELECT mag.inventory_item_id
                 , mag.item_number
                 , mag.group_number
                 , mag.content_lpn
                 , mag.inner_lpn
                 , mag.inner_lpn_exists
                 , mag.loose_qty_exists
                 , mag.revision
                 , mag.lot_number
                 , mag.serial_number
                 , mag.lot_alloc
                 , mag.serial_alloc
                 , mag.primary_quantity
                 , mag.primary_uom_code
                 , mag.uom_lookup_code
                 , msi.description
              FROM mtl_allocations_gtmp mag, mtl_system_items_vl msi
             WHERE mag.inventory_item_id = msi.inventory_item_id
               AND msi.ORGANIZATION_ID     = p_organization_id
             ORDER BY group_number;

	      -- Added for bug 12853197
		  SELECT Sum(primary_quantity)
	        INTO g_total_qty
		    FROM mtl_allocations_gtmp;
       ELSE
          IF l_debug = 1 THEN
             print_debug
             ( 'Invalid count of records in mtl_allocations_gtmp: '
               || to_char(l_count)
             , l_api_name
             );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

	x_total_qty:=g_total_qty;  -- Added for bug 12853197

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
         print_debug ('l_progress = ' || to_char(l_progress), l_api_name);
      END IF;

      IF c_remaining_tasks%ISOPEN THEN
         CLOSE c_remaining_tasks;
      END IF;

	  x_total_qty:=g_total_qty;  -- Added for bug 12853197

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
         print_debug ('l_progress = ' || to_char(l_progress), l_api_name);
      END IF;

      IF c_remaining_tasks%ISOPEN THEN
         CLOSE c_remaining_tasks;
      END IF;

	  x_total_qty:=g_total_qty;  -- Added for bug 12853197

  END fetch_next_drop;



  PROCEDURE get_wip_job_info
  ( x_entity_type        OUT NOCOPY  NUMBER
  , x_job                OUT NOCOPY  VARCHAR2
  , x_line               OUT NOCOPY  VARCHAR2
  , x_dept               OUT NOCOPY  VARCHAR2
  , x_operation_seq_num  OUT NOCOPY  NUMBER
  , x_start_date         OUT NOCOPY  DATE
  , x_schedule           OUT NOCOPY  VARCHAR2
  , x_assembly           OUT NOCOPY  VARCHAR2
  , x_return_status      OUT NOCOPY  VARCHAR2
  , p_organization_id    IN          NUMBER
  , p_transfer_lpn_id    IN          NUMBER
  ) IS

    l_api_name             VARCHAR2(30) := 'get_wip_job_info';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_api_return_status    VARCHAR2(1);

    l_transaction_temp_id  NUMBER;
    l_wip_entity_type      NUMBER := NULL;

    CURSOR c_get_entity_type
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT wip_entity_type
        FROM mtl_material_transactions_temp  mmtt
           , mtl_txn_request_lines           mtrl
           , wip_entities                    we
       WHERE mmtt.transaction_temp_id        = p_temp_id
         AND mmtt.transaction_source_type_id = 5
         AND mmtt.transaction_action_id      = 1
         AND mmtt.move_order_line_id         = mtrl.line_id
         AND mtrl.txn_source_id              = we.wip_entity_id
         AND mtrl.organization_id            = we.organization_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id)
       , l_api_name
       );
    END IF;

    --
    -- Validate passed in Org and LPN
    --
    IF p_organization_id <> g_current_drop_lpn.organization_id
       OR
       p_transfer_lpn_id <> g_current_drop_lpn.lpn_id
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Passed in org or LPN did not match cached info: '
            || g_newline || 'p_organization_id: ' || to_char(p_organization_id)
            || g_newline || 'p_transfer_lpn_id: ' || to_char(p_transfer_lpn_id)
            || g_newline || 'Cached Org ID:     ' || to_char(g_current_drop_lpn.organization_id)
            || g_newline || 'Cached LPN ID:     ' || to_char(g_current_drop_lpn.lpn_id)
          , l_api_name
           );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_transaction_temp_id := g_current_drop_lpn.current_drop_list.FIRST;

    IF l_debug = 1 THEN
       print_debug
       ( 'Transaction temp ID: ' || to_char(l_transaction_temp_id)
       , l_api_name
       );
    END IF;

    OPEN c_get_entity_type (l_transaction_temp_id);
    FETCH c_get_entity_type INTO l_wip_entity_type;
    CLOSE c_get_entity_type;

    IF l_wip_entity_type IS NULL THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Unable to determine entity type'
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_entity_type := l_wip_entity_type;

    l_api_return_status := fnd_api.g_ret_sts_success;
    wms_wip_integration.get_wip_job_info
    ( p_temp_id            => l_transaction_temp_id
    , p_wip_entity_type    => l_wip_entity_type
    , x_job                => x_job
    , x_line               => x_line
    , x_dept               => x_dept
    , x_operation_seq_num  => x_operation_seq_num
    , x_start_date         => x_start_date
    , x_schedule           => x_schedule
    , x_assembly           => x_assembly
    , x_return_status      => l_api_return_status
    , x_msg_count          => l_msg_count
    , x_msg_data           => l_msg_data
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'wms_wip_integration.get_wip_job_info returned status '
            || l_api_return_status
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
       IF l_debug = 1 THEN
          print_debug
          ( 'Return values from wms_wip_integration.get_wip_job_info: '
            || g_newline || 'x_job:               ' || x_job
            || g_newline || 'x_line:              ' || x_line
            || g_newline || 'x_dept:              ' || x_dept
            || g_newline || 'x_operation_seq_num: ' || to_char(x_operation_seq_num)
            || g_newline || 'x_start_date:        ' || to_char(x_start_date, 'DD-MON-YYYY HH24:MI:SS')
            || g_newline || 'x_schedule:          ' || x_schedule
            || g_newline || 'x_assembly:          ' || x_assembly
          , l_api_name
          );
       END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END get_wip_job_info;


  PROCEDURE get_sub_xfer_dest_info
    (x_to_sub           OUT NOCOPY  VARCHAR2,
     x_to_loc           OUT NOCOPY  VARCHAR2,
     x_to_loc_id        OUT NOCOPY  NUMBER,
     x_project_num      OUT NOCOPY  VARCHAR2,
     x_prj_id           OUT NOCOPY  VARCHAR2,
     x_task_num         OUT NOCOPY  VARCHAR2,
     x_tsk_id           OUT NOCOPY  VARCHAR2,
     x_return_status    OUT NOCOPY  VARCHAR2,
     p_organization_id  IN          NUMBER,
     p_transfer_lpn_id  IN          NUMBER,
     x_transfer_lpn_id  OUT nocopy  NUMBER,
     x_transfer_lpn     OUT nocopy  VARCHAR2) IS

    l_api_name             VARCHAR2(30) := 'get_sub_xfer_dest_info';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    l_transaction_temp_id  NUMBER;
    l_subinventory_code    VARCHAR2(20);
    l_locator_id           NUMBER;

    CURSOR c_get_mmtt_info(p_temp_id NUMBER) IS
       SELECT mmtt.transfer_subinventory, mmtt.transfer_to_location,
              decode(transaction_action_id, 28,mmtt.cartonization_id, NULL)
              --mmtt.cartonization_id has the LPN suggested by MDC
              --IT is applicable only to MDC case for staging transfer PickDrops
              -- For all others, it should be null
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id;

  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;

     IF l_debug = 1 THEN
        print_debug
          ('Entered with parameters: ' || g_newline                  ||
           'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
           'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id)
           , l_api_name);
    END IF;

    --
    -- Validate passed in Org and LPN
    --
    IF p_organization_id <> g_current_drop_lpn.organization_id OR
       p_transfer_lpn_id <> g_current_drop_lpn.lpn_id THEN
       IF l_debug = 1 THEN
          print_debug
            ( 'Passed in org or LPN did not match cached info: '
              || g_newline || 'p_organization_id: ' || to_char(p_organization_id)
              || g_newline || 'p_transfer_lpn_id: ' || to_char(p_transfer_lpn_id)
              || g_newline || 'Cached Org ID:     ' || to_char(g_current_drop_lpn.organization_id)
              || g_newline || 'Cached LPN ID:     ' || to_char(g_current_drop_lpn.lpn_id)
              , l_api_name);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_transaction_temp_id := g_current_drop_lpn.current_drop_list.FIRST;

    IF l_debug = 1 THEN
       print_debug
         ('Transaction temp ID: ' || to_char(l_transaction_temp_id), l_api_name);
    END IF;

    OPEN c_get_mmtt_info (l_transaction_temp_id);
    FETCH c_get_mmtt_info INTO l_subinventory_code, l_locator_id, x_transfer_lpn_id;
    CLOSE c_get_mmtt_info;

    IF l_debug = 1 THEN
       print_debug
         ('c_get_mmtt_info returned To Subinventory ' || l_subinventory_code ||
          ', To Locator ID '                          || to_char(l_locator_id) ||
          ', To LPN ID '                              || x_transfer_lpn_id
          , l_api_name);
    END IF;

    x_to_sub := l_subinventory_code;
    x_to_loc := inv_project.get_locsegs(l_locator_id, p_organization_id);
    x_to_loc_id   := l_locator_id;

    x_project_num := inv_project.get_project_number;
    x_prj_id      := inv_project.get_project_id;
    x_task_num    := inv_project.get_task_number;
    x_tsk_id      := inv_project.get_task_id;

    IF x_transfer_lpn_id IS NOT NULL THEN
       SELECT license_plate_number
         INTO x_transfer_lpn
         FROM wms_license_plate_numbers
         WHERE lpn_id = x_transfer_lpn_id;
    END IF;

    IF l_debug = 1 THEN
       print_debug
       ( 'Return values from inv_project: '
         || g_newline || 'x_to_loc:      ' || x_to_loc
         || g_newline || 'x_project_num: ' || x_project_num
         || g_newline || 'x_prj_id       ' || x_prj_id
         || g_newline || 'x_task_num:    ' || x_task_num
         || g_newline || 'x_tsk_id:      ' || x_tsk_id
       , l_api_name);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;

       IF l_debug = 1 THEN
          print_debug ('Other error: ' || sqlerrm, l_api_name);
       END IF;

  END get_sub_xfer_dest_info;


  PROCEDURE get_default_drop_lpn
  ( x_drop_lpn_num     OUT NOCOPY  VARCHAR2
  , x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_delivery_id      IN          NUMBER
  , p_to_sub           IN          VARCHAR2
  , p_to_loc           IN          NUMBER
  ) IS

    l_api_name  VARCHAR2(30) := 'get_default_drop_lpn';
    l_debug     NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_lpn_id    NUMBER;
    l_lpn_num   VARCHAR2(30) := NULL;

    CURSOR c_get_drop_lpn_id
    ( p_org_id    IN  NUMBER
    , p_deliv_id  IN  NUMBER
    , p_subinv    IN  VARCHAR2
    , p_loc_id    IN  NUMBER
    ) IS
      SELECT wlpn.outermost_lpn_id
        FROM wsh_delivery_assignments_v   wda
           , wsh_delivery_details_ob_grp_v       wdd
           , wms_license_plate_numbers  wlpn
       WHERE wda.delivery_id               = p_deliv_id
         AND wda.parent_delivery_detail_id = wdd.delivery_detail_id
         AND wdd.organization_id           = p_org_id
         AND wdd.lpn_id                    = wlpn.lpn_id
         AND wlpn.subinventory_code        = p_subinv
         AND wlpn.locator_id               = p_loc_id
         AND wlpn.lpn_context              = 11
       ORDER BY wda.CREATION_DATE DESC;

    CURSOR c_get_lpn
    ( p_lpn_id  IN  NUMBER
    ) IS
      SELECT license_plate_number
        FROM wms_license_plate_numbers  wlpn
       WHERE wlpn.lpn_id = p_lpn_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    x_drop_lpn_num   := NULL;

    fnd_msg_pub.initialize;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_delivery_id     => '     || to_char(p_delivery_id)     || g_newline ||
         'p_to_sub          => '     || p_to_sub                   || g_newline ||
         'p_to_loc          => '     || to_char(p_to_loc)
       , l_api_name
       );
    END IF;

    OPEN c_get_drop_lpn_id
    ( p_organization_id
    , p_delivery_id
    , p_to_sub
    , p_to_loc
    );
    FETCH c_get_drop_lpn_id INTO l_lpn_id;
    CLOSE c_get_drop_lpn_id;

    IF l_lpn_id IS NOT NULL THEN
       OPEN c_get_lpn (l_lpn_id);
       FETCH c_get_lpn INTO l_lpn_num;
       CLOSE c_get_lpn;
    END IF;

    IF l_lpn_num IS NOT NULL THEN
       x_drop_lpn_num := l_lpn_num;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

      IF c_get_drop_lpn_id%ISOPEN THEN
         CLOSE c_get_drop_lpn_id;
      END IF;

      IF c_get_lpn%ISOPEN THEN
         CLOSE c_get_lpn;
      END IF;

  END get_default_drop_lpn;



  PROCEDURE get_lot_lov
  ( x_lot_lov        OUT NOCOPY  t_genref
  , p_item_id        IN          NUMBER
  , p_revision       IN          VARCHAR2
  , p_inner_lpn      IN          VARCHAR2
  , p_conf_uom_code  IN          VARCHAR2
  , p_lot_num        IN          VARCHAR2
  ) IS

    l_api_name  VARCHAR2(30) := 'get_lot_lov';
    l_debug     NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_dum_lpn   VARCHAR2(31) := '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';

  BEGIN

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline          ||
         'p_item_id       => '       || to_char(p_item_id) || g_newline ||
         'p_revision      => '       || p_revision         || g_newline ||
         'p_inner_lpn     => '       || p_inner_lpn        || g_newline ||
         'p_conf_uom_code => '       || p_conf_uom_code    || g_newline ||
         'p_lot_num       => '       || p_lot_num
       , l_api_name
       );
    END IF;

     IF p_conf_uom_code IS NULL THEN
        OPEN x_lot_lov FOR
           SELECT lot_number
                , primary_quantity
             FROM mtl_allocations_gtmp
            WHERE inventory_item_id        = p_item_id
              AND NVL(revision,'@@@@')     = NVL(p_revision, '@@@@')
              AND NVL(inner_lpn,l_dum_lpn) = NVL(p_inner_lpn,l_dum_lpn)
              AND lot_number            LIKE (p_lot_num);
     ELSE
        OPEN x_lot_lov FOR
           SELECT lot_number
                , inv_convert.inv_um_convert
                  ( p_item_id
                  , NULL
                  , primary_quantity
                  , primary_uom_code
                  , p_conf_uom_code
                  , NULL
                  , NULL
                  ) lot_qty
             FROM mtl_allocations_gtmp
            WHERE inventory_item_id        = p_item_id
              AND NVL(revision,'@@@@')     = NVL(p_revision, '@@@@')
              AND NVL(inner_lpn,l_dum_lpn) = NVL(p_inner_lpn,l_dum_lpn)
              AND lot_number            LIKE (p_lot_num);
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
        IF l_debug = 1 THEN
           print_debug
           ( 'Error in get_lot_lov: ' || sqlerrm
           , l_api_name
           );
        END IF;
        RAISE;
  END get_lot_lov;



  PROCEDURE get_serial_lov
  ( x_serial_lov  OUT NOCOPY  t_genref
  , p_item_id     IN          NUMBER
  , p_revision    IN          VARCHAR2
  , p_inner_lpn   IN          VARCHAR2
  , p_lot_num     IN          VARCHAR2
  , p_serial      IN          VARCHAR2
  ) IS

    l_api_name  VARCHAR2(30) := 'get_serial_lov';
    l_debug     NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_dum_lpn   VARCHAR2(31) := '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';

  BEGIN

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline          ||
         'p_item_id   => '           || to_char(p_item_id) || g_newline ||
         'p_revision  => '           || p_revision         || g_newline ||
         'p_inner_lpn => '           || p_inner_lpn        || g_newline ||
         'p_lot_num   => '           || p_lot_num          || g_newline ||
         'p_serial    => '           || p_serial
       , l_api_name
       );
    END IF;

     OPEN x_serial_lov FOR
        SELECT serial_number
          FROM mtl_allocations_gtmp
         WHERE inventory_item_id        = p_item_id
           AND NVL(revision,'@@@@')     = NVL(p_revision, '@@@@')
           AND NVL(inner_lpn,l_dum_lpn) = NVL(p_inner_lpn,l_dum_lpn)
           AND NVL(lot_number,'@@@@')   = NVL(p_lot_num, '@@@@')
           AND serial_number         LIKE (p_serial);
  EXCEPTION
     WHEN OTHERS THEN
        IF l_debug = 1 THEN
           print_debug
           ( 'Error in get_serial_lov: ' || sqlerrm
           , l_api_name
           );
        END IF;
        RAISE;
  END get_serial_lov;



  PROCEDURE insert_child_msnt
  ( x_return_status  OUT NOCOPY  VARCHAR2
  , p_temp_id        IN          NUMBER
  , p_parent_tmp_id  IN          NUMBER
  , p_txn_header_id  IN          NUMBER
  ) IS

    l_api_name             VARCHAR2(30) := 'insert_child_msnt';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_dummy                VARCHAR2(1)  := NULL;
    l_lot_controlled       BOOLEAN;
    l_srl_qty              NUMBER;

    l_serial_number        VARCHAR2(30);
    l_serial_temp_id       NUMBER;


    CURSOR c_get_mmtt_info
    ( p_tmp_id  IN  NUMBER
    ) IS
      SELECT mmtt.primary_quantity
           , mmtt.inventory_item_id
           , mmtt.organization_id
           , mmtt.revision
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.transaction_temp_id = p_tmp_id;

    mmtt_info_rec  c_get_mmtt_info%ROWTYPE;


    CURSOR c_get_msnt
    ( p_parent_id  IN  NUMBER
    ) IS
      SELECT rowid
           , fm_serial_number
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = p_parent_id;

    msnt_rec  c_get_msnt%ROWTYPE;


    CURSOR c_get_lot_msnt
    ( p_parent_id  IN  NUMBER
    , p_lot_num    IN  VARCHAR2
    ) IS
      SELECT msnt.rowid
           , msnt.fm_serial_number
        FROM mtl_transaction_lots_temp  mtlt
           , mtl_serial_numbers_temp    msnt
       WHERE mtlt.transaction_temp_id = p_parent_id
         AND mtlt.lot_number          = p_lot_num
         AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;

    lot_msnt_rec  c_get_lot_msnt%ROWTYPE;


    CURSOR c_get_lot_records
    ( p_tmp_id  IN  NUMBER
    ) IS
      SELECT mtlt.rowid
           , mtlt.lot_number
           , mtlt.primary_quantity
        FROM mtl_transaction_lots_temp  mtlt
       WHERE mtlt.transaction_temp_id = p_tmp_id;

    lot_details_rec  c_get_lot_records%ROWTYPE;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                ||
         'p_temp_id       => '       || to_char(p_temp_id)       || g_newline ||
         'p_parent_tmp_id => '       || to_char(p_parent_tmp_id) || g_newline ||
         'p_txn_header_id => '       || to_char(p_txn_header_id)
       , l_api_name
       );
    END IF;

    SAVEPOINT insert_msnt_sp;

    OPEN c_get_mmtt_info (p_temp_id);
    FETCH c_get_mmtt_info INTO mmtt_info_rec;
    CLOSE c_get_mmtt_info;

    IF l_debug = 1 THEN
       print_debug
       ( 'Serial qty: ' || to_char(mmtt_info_rec.primary_quantity)  ||
         ', Item ID: '  || to_char(mmtt_info_rec.inventory_item_id) ||
         ', Revision: ' || mmtt_info_rec.revision                   ||
         ', Org ID: '   || to_char(mmtt_info_rec.organization_id)
       , l_api_name
       );
    END IF;

    BEGIN
       SELECT 'x'
         INTO l_dummy
         FROM dual
        WHERE EXISTS
            ( SELECT 'x'
                FROM mtl_transaction_lots_temp  mtlt
               WHERE mtlt.transaction_temp_id = p_temp_id
            );

       IF l_debug = 1 THEN
          print_debug
          ( 'MTLT records exist for this temp ID'
          , l_api_name
          );
       END IF;

       l_lot_controlled := TRUE;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_lot_controlled := FALSE;

       WHEN OTHERS THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'Exception trying to determine if MTLT records exist: '
               || sqlerrm
             , l_api_name
             );
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    IF NOT l_lot_controlled
    THEN
       l_srl_qty := mmtt_info_rec.primary_quantity;

       OPEN c_get_msnt (p_parent_tmp_id);
       FETCH c_get_msnt INTO msnt_rec;

       IF c_get_msnt%NOTFOUND THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'No parent serial records found.'
             , l_api_name
             );
          END IF;
          CLOSE c_get_msnt;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       WHILE ( (c_get_msnt%FOUND)
               AND
               (l_srl_qty > 0)
             )
       LOOP
          UPDATE mtl_serial_numbers_temp  msnt
             SET transaction_temp_id = p_temp_id
           WHERE rowid = msnt_rec.rowid;

          l_srl_qty := l_srl_qty - 1;

          IF l_debug = 1 THEN
             print_debug
             ( 'Updated serial '      || msnt_rec.fm_serial_number ||
               ', l_srl_qty is now: ' || to_char(l_srl_qty)
             , l_api_name
             );
          END IF;

          UPDATE mtl_serial_numbers
             SET group_mark_id = p_txn_header_id
           WHERE current_organization_id = mmtt_info_rec.organization_id
             AND inventory_item_id       = mmtt_info_rec.inventory_item_id
             AND NVL(revision,'@@@@')    = NVL(mmtt_info_rec.revision,'@@@@')
             AND serial_number           = msnt_rec.fm_serial_number;

          FETCH c_get_msnt INTO msnt_rec;

       END LOOP;

       IF c_get_msnt%ISOPEN THEN
          CLOSE c_get_msnt;
       END IF;

       IF l_srl_qty > 0 THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'Still have qty on child with no MSNT: '
               || to_char(l_srl_qty)
             , l_api_name
             );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    ELSE
       --
       -- Lot controlled
       --
       OPEN c_get_lot_records (p_temp_id);
       FETCH c_get_lot_records INTO lot_details_rec;

       WHILE (c_get_lot_records%FOUND)
       LOOP
          IF l_debug = 1 THEN
             print_debug
             ( 'Processing lot ' || lot_details_rec.lot_number ||
               ' with quantity ' || to_char(lot_details_rec.primary_quantity)
             , l_api_name
             );
          END IF;

          l_srl_qty := lot_details_rec.primary_quantity;

          OPEN c_get_lot_msnt
          ( p_parent_tmp_id
          , lot_details_rec.lot_number
          );
          FETCH c_get_lot_msnt INTO lot_msnt_rec;

          IF c_get_lot_msnt%NOTFOUND THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'No parent serial records found.'
                , l_api_name
                );
             END IF;
             CLOSE c_get_lot_msnt;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSE
             IF l_debug = 1 THEN
                print_debug
                ( 'Fetched serial record for lot ' || lot_details_rec.lot_number
                , l_api_name
                );
             END IF;
          END IF;

          SELECT mtl_material_transactions_s.NEXTVAL
            INTO l_serial_temp_id
            FROM dual;

          IF l_debug = 1 THEN
             print_debug
             ( 'Generated new serial temp ID: ' || to_char(l_serial_temp_id)
             , l_api_name
             );
          END IF;

          UPDATE mtl_transaction_lots_temp
             SET serial_transaction_temp_id = l_serial_temp_id
           WHERE rowid = lot_details_rec.rowid;

          WHILE ( (c_get_lot_msnt%FOUND)
                  AND
                  (l_srl_qty > 0)
                )
          LOOP
             UPDATE mtl_serial_numbers_temp  msnt
                SET transaction_temp_id = l_serial_temp_id
              WHERE rowid = lot_msnt_rec.rowid;

             l_srl_qty := l_srl_qty - 1;

             IF l_debug = 1 THEN
                print_debug
                ( 'Updated serial '      || lot_msnt_rec.fm_serial_number ||
                  ', l_srl_qty is now: ' || to_char(l_srl_qty)
                , l_api_name
                );
             END IF;

             UPDATE mtl_serial_numbers
                SET group_mark_id = p_txn_header_id
              WHERE current_organization_id = mmtt_info_rec.organization_id
                AND inventory_item_id       = mmtt_info_rec.inventory_item_id
                AND NVL(revision,'@@@@')    = NVL(mmtt_info_rec.revision,'@@@@')
                AND serial_number           = lot_msnt_rec.fm_serial_number;

             FETCH c_get_lot_msnt INTO lot_msnt_rec;

          END LOOP;

          IF c_get_lot_msnt%ISOPEN THEN
             CLOSE c_get_lot_msnt;
          END IF;

          IF l_srl_qty > 0 THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'Still have qty on child with no MSNT: '
                  || to_char(l_srl_qty)
                , l_api_name
                );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          FETCH c_get_lot_records INTO lot_details_rec;
       END LOOP; -- done looping through lots
    END IF; -- end ELSE if lot controlled

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO insert_msnt_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END insert_child_msnt;



  PROCEDURE process_inner_lpn
  ( x_ret_code          OUT NOCOPY  NUMBER
  , x_remaining_qty     OUT NOCOPY  NUMBER
  , x_inner_lpn_exists  OUT NOCOPY  VARCHAR2
  , x_return_status     OUT NOCOPY  VARCHAR2
  , p_lpn               IN          VARCHAR2
  , p_group_number      IN          NUMBER
  , p_item_id           IN          NUMBER
  , p_revision          IN          VARCHAR2
  , p_qty               IN          NUMBER
  , p_primary_uom       IN          VARCHAR2
  , p_serial_control    IN          VARCHAR2
  ) IS

    l_api_name             VARCHAR2(30) := 'process_inner_lpn';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_api_return_status    VARCHAR2(1);

    l_temp_tbl             g_temp_id_tbl;

    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    l_inner_lpn_id         NUMBER;
    l_parent_temp_id       NUMBER;
    l_lpn_pri_qty          NUMBER;
    l_from_sub             VARCHAR2(30);
    l_from_loc_id          NUMBER;

    l_transaction_temp_id  NUMBER;
    l_txn_header_id        NUMBER;
    l_new_temp_id          NUMBER;
    l_mmtt_qty             NUMBER       := 0;
    l_tot_mmtt_qty         NUMBER       := 0;

    l_remaining_qty        NUMBER;
    l_txn_qty              NUMBER;
    l_pri_qty              NUMBER;

    ii                     NUMBER;
    jj                     NUMBER;

    l_dummy                VARCHAR2(1)  := NULL;
    l_inner_lpn_exists     VARCHAR2(1)  := NULL;

    CURSOR c_get_inner_lpn_details
    ( p_inner_lpn     IN  VARCHAR2
    , p_outer_lpn_id  IN  NUMBER
    , p_org_id        IN  NUMBER
    ) IS
      SELECT wlpn.lpn_id
           , mmtt.transaction_temp_id
           , mmtt.primary_quantity
           , mmtt.subinventory_code
           , mmtt.locator_id
        FROM wms_license_plate_numbers       wlpn
           , mtl_material_transactions_temp  mmtt
       WHERE wlpn.license_plate_number = p_inner_lpn
         AND wlpn.organization_id = p_org_id
         AND mmtt.transfer_lpn_id = p_outer_lpn_id
         AND mmtt.organization_id = p_org_id
         AND mmtt.parent_line_id  = mmtt.transaction_temp_id
         AND mmtt.content_lpn_id <> mmtt.transfer_lpn_id
         AND mmtt.content_lpn_id  = wlpn.lpn_id;

  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    fnd_msg_pub.initialize;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline               ||
         'p_lpn            => '      || p_lpn                   || g_newline ||
         'p_group_number   => '      || to_char(p_group_number) || g_newline ||
         'p_item_id        => '      || to_char(p_item_id)      || g_newline ||
         'p_revision       => '      || p_revision              || g_newline ||
         'p_qty            => '      || to_char(p_qty)          || g_newline ||
         'p_primary_uom    => '      || p_primary_uom           || g_newline ||
         'p_serial_control => '      || p_serial_control
       , l_api_name
       );
    END IF;

    SAVEPOINT process_lpn_sp;

    OPEN c_get_inner_lpn_details
    ( p_lpn
    , g_current_drop_lpn.lpn_id
    , g_current_drop_lpn.organization_id
    );
    FETCH c_get_inner_lpn_details INTO l_inner_lpn_id
                                     , l_parent_temp_id
                                     , l_lpn_pri_qty
                                     , l_from_sub
                                     , l_from_loc_id;

    IF c_get_inner_lpn_details%NOTFOUND THEN
       CLOSE c_get_inner_lpn_details;
       IF l_debug = 1 THEN
          print_debug
          ( 'Cannot find scanned LPN ' || p_lpn ||
            ' in outer LPN ID '        || to_char(g_current_drop_lpn.lpn_id)
          , l_api_name
          );
       END IF;

       fnd_message.set_name('WMS', 'WMS_LPN_NOT_IN_OUTER');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
    ELSE
       IF l_debug = 1 THEN
          print_debug
          ( 'Found scanned LPN '   || p_lpn                   ||
            '. LPN ID is '         || to_char(l_inner_lpn_id) ||
            '. Primary qty is '    || to_char(l_lpn_pri_qty)  ||
            '. Parent temp ID is ' || to_char(l_parent_temp_id)
          , l_api_name
          );
       END IF;
    END IF;

    IF c_get_inner_lpn_details%ISOPEN
    THEN
       CLOSE c_get_inner_lpn_details;
    END IF;

    l_api_return_status := fnd_api.g_ret_sts_success;
    get_temp_list
    ( x_temp_tbl      => l_temp_tbl
    , x_return_status => l_api_return_status
    , p_group_num     => p_group_number
    , p_status        => 'PENDING'
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug ('Error from get_temp_list', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF NOT (l_temp_tbl.COUNT > 0)
    THEN
       IF l_debug = 1 THEN
          print_debug ('get_temp_list returned no MMTT records', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
       IF l_debug = 1 THEN
          print_debug
          ( 'MMTT record count from get_temp_list: '
            || to_char(l_temp_tbl.COUNT)
          , l_api_name
          );
       END IF;
    END IF;

    IF l_lpn_pri_qty >= p_qty
    THEN
       IF l_lpn_pri_qty > p_qty
       THEN
          x_ret_code := 1;
       ELSE
          x_ret_code := 2;
       END IF;

       x_remaining_qty := 0;

       ii := l_temp_tbl.FIRST;
       jj := l_temp_tbl.LAST;

       l_transaction_temp_id := l_temp_tbl(ii);

       IF l_debug = 1 THEN
          print_debug
          ( 'ii = ' || to_char(ii) || ', jj = ' || to_char(jj)
          , l_api_name
          );
       END IF;

       WHILE (ii <= jj)
       LOOP
          IF l_debug = 1 THEN
             print_debug
             ( ' Updating lpn_id on temp ID ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;

          UPDATE mtl_material_transactions_temp  mmtt
             SET lpn_id            = l_inner_lpn_id
               , transfer_lpn_id   = DECODE( x_ret_code
                                           , 2, l_inner_lpn_id
                                           , NULL
                                           )
               , subinventory_code = l_from_sub
               , locator_id        = l_from_loc_id
           WHERE mmtt.transaction_temp_id  = l_transaction_temp_id
                 RETURNING mmtt.primary_quantity
                         , mmtt.transaction_header_id
                      INTO l_mmtt_qty
                         , l_txn_header_id;

          l_tot_mmtt_qty := l_tot_mmtt_qty + NVL(l_mmtt_qty,0);

          IF l_debug = 1 THEN
             print_debug
             ( 'Updated temp ID ' || to_char(l_transaction_temp_id) ||
               ' having qty '     || to_char(l_mmtt_qty)            ||
               ' and txn hdr ID ' || to_char(l_txn_header_id)       ||
               '. Total qty is '  || to_char(l_tot_mmtt_qty)
             , l_api_name
             );
          END IF;

          IF x_ret_code = 1
          THEN
             g_current_drop_lpn.current_drop_list(l_transaction_temp_id) := 'LPN_DONE';
          ELSIF x_ret_code = 2
          THEN
             g_current_drop_lpn.current_drop_list(l_transaction_temp_id) := 'DONE';

             -- Start change for Bug 5620764
             -- Updates LPN context to "Packing Content" since entire LPN is consumed
             -- Bug5659809: update last_update_date and last_update_by as well
             UPDATE wms_license_plate_numbers
                SET lpn_context = WMS_Container_PUB.LPN_CONTEXT_PACKING
                  , last_update_date = SYSDATE
                  , last_updated_by = fnd_global.user_id
              WHERE lpn_id = l_inner_lpn_id;

           	 IF l_debug = 1 THEN
               print_debug ('Updated LPN context to pack since entire LPN is
            		 consumed for LPN ' || l_inner_lpn_id
            		 , l_api_name);
             END IF;
						 -- End change for bug 5620764
          END IF;

          IF x_ret_code = 2
             AND
             p_serial_control = 'TRUE'
          THEN
             l_api_return_status := fnd_api.g_ret_sts_success;
             insert_child_msnt
             ( x_return_status => l_api_return_status
             , p_temp_id       => l_transaction_temp_id
             , p_parent_tmp_id => l_parent_temp_id
             , p_txn_header_id => l_txn_header_id
             );
             IF l_api_return_status <> fnd_api.g_ret_sts_success
             THEN
                IF l_debug = 1 THEN
                   print_debug ('Error from insert_child_msnt', l_api_name);
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSE
                IF l_debug = 1 THEN
                   print_debug ('Success status from insert_child_msnt', l_api_name);
                END IF;
             END IF;
          END IF;

          IF l_debug = 1 THEN
             print_debug
             ( ' Done processing temp ID ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;

          IF ii < jj THEN
             ii := l_temp_tbl.NEXT(ii);
             l_transaction_temp_id := l_temp_tbl(ii);
          ELSE
             EXIT;
          END IF;

          IF l_debug = 1 THEN
             print_debug
             ( 'Fetched next temp ID: ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;
       END LOOP;
    ELSE
       --
       -- l_lpn_pri_qty < p_qty
       --
       x_ret_code := 3;
       x_remaining_qty := p_qty - l_lpn_pri_qty;

       l_remaining_qty := l_lpn_pri_qty;

       ii := l_temp_tbl.FIRST;
       jj := l_temp_tbl.LAST;

       l_transaction_temp_id := l_temp_tbl(ii);

       IF l_debug = 1 THEN
          print_debug
          ( 'ii = ' || to_char(ii) || ', jj = ' || to_char(jj) ||
            ', l_remaining_qty: '  || to_char(l_remaining_qty)
          , l_api_name
          );
       END IF;

       WHILE ( (ii <= jj)
               AND
               (l_remaining_qty > 0)
             )
       LOOP
          IF l_debug = 1 THEN
             print_debug
             ( ' Updating lpn_id on temp ID ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;

          UPDATE mtl_material_transactions_temp  mmtt
             SET lpn_id            = l_inner_lpn_id
               , transfer_lpn_id   = l_inner_lpn_id
               , subinventory_code = l_from_sub
               , locator_id        = l_from_loc_id
           WHERE mmtt.transaction_temp_id  = l_transaction_temp_id
                 RETURNING mmtt.primary_quantity
                         , mmtt.transaction_header_id
                      INTO l_mmtt_qty
                         , l_txn_header_id;

          IF l_debug = 1 THEN
             print_debug
             ( ' Updated temp ID '    || to_char(l_transaction_temp_id)
               || ', primary qty is ' || to_char(l_mmtt_qty)
               || ', txn hdr ID is '  || to_char(l_txn_header_id)
             , l_api_name
             );
          END IF;

          IF l_mmtt_qty <= l_remaining_qty
          THEN
             l_remaining_qty := l_remaining_qty - l_mmtt_qty;

             IF l_debug = 1 THEN
                print_debug
                ( 'Current MMTT qty <= remaining. '
                  || 'Remaining is now: ' || to_char(l_remaining_qty)
                , l_api_name
                );
             END IF;

          ELSE
             l_api_return_status := fnd_api.g_ret_sts_success;
             split_mmtt
             ( x_new_temp_id   => l_new_temp_id
             , x_return_status => l_api_return_status
             , p_temp_id       => l_transaction_temp_id
             );

             IF l_api_return_status <> fnd_api.g_ret_sts_success
             THEN
                IF l_debug = 1 THEN
                   print_debug
                   ( 'split_mmtt returned status ' || l_api_return_status
                   , l_api_name
                   );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             UPDATE mtl_material_transactions_temp
                SET transaction_quantity = DECODE( transaction_uom
                                                 , p_primary_uom, l_remaining_qty
                                                 , inv_convert.inv_um_convert
                                                   ( p_item_id
                                                   , NULL
                                                   , l_remaining_qty
                                                   , p_primary_uom
                                                   , transaction_uom
                                                   , NULL
                                                   , NULL
                                                   )
                                                 )
                  , primary_quantity     = l_remaining_qty
                  , reservation_quantity = DECODE( reservation_quantity
                                                 , NULL, NULL
                                                 , l_remaining_qty
                                                 )
              WHERE transaction_temp_id = l_transaction_temp_id
                    RETURNING transaction_quantity INTO l_txn_qty;

             IF l_debug = 1 THEN
                print_debug
                ('Reduced qty for temp ID ' || to_char(l_transaction_temp_id)
                 || ' to '                  || to_char(l_remaining_qty)
                , l_api_name
                );
             END IF;

             UPDATE mtl_material_transactions_temp
                SET transaction_quantity = transaction_quantity - l_txn_qty
                  , primary_quantity     = primary_quantity     - l_remaining_qty
                  , reservation_quantity = DECODE( reservation_quantity
                                                 , NULL, NULL
                                                 , reservation_quantity - l_remaining_qty
                                                 )
                  , lpn_id               = NULL
                  , transfer_lpn_id      = NULL
                  , subinventory_code    = NULL
                  , locator_id           = NULL
              WHERE transaction_temp_id = l_new_temp_id
                    RETURNING primary_quantity INTO l_pri_qty;

             IF l_debug = 1 THEN
                print_debug
                ('Updated new temp ID ' || to_char(l_new_temp_id) ||
                 ' with qty : '         || to_char(l_pri_qty)
                , l_api_name
                );
             END IF;

             l_mmtt_qty      := l_remaining_qty;
             l_remaining_qty := 0;

          END IF;

          l_tot_mmtt_qty := l_tot_mmtt_qty + NVL(l_mmtt_qty,0);
          g_current_drop_lpn.current_drop_list(l_transaction_temp_id) := 'DONE';

          IF p_serial_control = 'TRUE'
          THEN
             l_api_return_status := fnd_api.g_ret_sts_success;
             insert_child_msnt
             ( x_return_status => l_api_return_status
             , p_temp_id       => l_transaction_temp_id
             , p_parent_tmp_id => l_parent_temp_id
             , p_txn_header_id => l_txn_header_id
             );
             IF l_api_return_status <> fnd_api.g_ret_sts_success
             THEN
                IF l_debug = 1 THEN
                   print_debug ('Error from insert_child_msnt', l_api_name);
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSE
                IF l_debug = 1 THEN
                   print_debug ('Success status from insert_child_msnt', l_api_name);
                END IF;
             END IF;
          END IF; -- if item is serial controlled

          IF l_debug = 1 THEN
             print_debug
             ( ' Done processing temp ID ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;

          IF ii < jj THEN
             ii := l_temp_tbl.NEXT(ii);
             l_transaction_temp_id := l_temp_tbl(ii);
          ELSE
             EXIT;
          END IF;

          IF l_debug = 1 THEN
             print_debug
             ( 'Fetched next temp ID: ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;
       END LOOP;

       IF l_remaining_qty > 0
       THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'Some qty remaining: ' || to_char(l_remaining_qty)
             , l_api_name
             );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END IF; -- checking LPN avail qty against entered qty

    IF x_ret_code IN (2,3)
    THEN
       UPDATE mtl_material_transactions_temp  mmtt
          SET content_lpn_id       = NULL
            , transaction_quantity = 0
            , primary_quantity     = 0
            , reservation_quantity = 0
        WHERE mmtt.transaction_temp_id = l_parent_temp_id;
    ELSE
       UPDATE mtl_material_transactions_temp  mmtt
          SET transaction_quantity = DECODE( transaction_uom
                                           , p_primary_uom, (primary_quantity - l_tot_mmtt_qty)
                                           , inv_convert.inv_um_convert
                                             ( p_item_id
                                             , NULL
                                             , primary_quantity - l_tot_mmtt_qty
                                             , p_primary_uom
                                             , transaction_uom
                                             , NULL
                                             , NULL
                                             )
                                           )
            , primary_quantity     = primary_quantity - l_tot_mmtt_qty
            , reservation_quantity = DECODE( reservation_quantity
                                           , NULL, NULL
                                           , reservation_quantity - l_tot_mmtt_qty
                                           )
        WHERE mmtt.transaction_temp_id = l_parent_temp_id;
    END IF;

    IF x_ret_code = 3
    THEN
       BEGIN
          SELECT 'x'
            INTO l_dummy
            FROM dual
           WHERE EXISTS
               ( SELECT 'x'
                   FROM mtl_material_transactions_temp  mmtt
                  WHERE mmtt.organization_id = g_current_drop_lpn.organization_id
                    AND mmtt.transfer_lpn_id = g_current_drop_lpn.lpn_id
                    AND mmtt.parent_line_id  = mmtt.transaction_temp_id
                    AND mmtt.transaction_quantity > 0
                    AND mmtt.inventory_item_id    = p_item_id
                    AND NVL(mmtt.revision,'@@@@') = NVL(p_revision,'@@@@')
                    AND mmtt.content_lpn_id IS NOT NULL
                    AND mmtt.content_lpn_id <> mmtt.transfer_lpn_id
               );
          l_inner_lpn_exists := 'Y';
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               l_inner_lpn_exists := 'N';
       END;
    END IF;
    x_inner_lpn_exists := l_inner_lpn_exists;

    l_temp_tbl.DELETE;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK to process_lpn_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK to process_lpn_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END process_inner_lpn;



  PROCEDURE process_loose_qty
  ( x_loose_qty_exists  OUT NOCOPY  VARCHAR2
  , x_return_status     OUT NOCOPY  VARCHAR2
  , p_group_number      IN          NUMBER
  , p_item_id           IN          NUMBER
  , p_revision          IN          VARCHAR2
  , p_qty               IN          NUMBER
  , p_primary_uom       IN          VARCHAR2
  ) IS

    l_api_name             VARCHAR2(30) := 'process_loose_qty';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_api_return_status    VARCHAR2(1);

    l_available_qty        NUMBER;

    l_temp_tbl             g_temp_id_tbl;
    l_process_tbl          g_temp_id_tbl;
    l_parent_tbl           g_temp_id_tbl;

    l_mmtt_qty             NUMBER       := 0;
    l_transaction_temp_id  NUMBER;
    l_remaining_qty        NUMBER;
    l_new_temp_id          NUMBER;
    l_txn_qty              NUMBER;
    l_pri_qty              NUMBER;
    l_parent_temp_id       NUMBER;

    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    ii                     NUMBER;
    jj                     NUMBER;
    kk                     NUMBER;

    l_dummy                VARCHAR2(1)  := NULL;
    l_loose_qty_exists     VARCHAR2(1)  := NULL;

    CURSOR c_get_available_loose_qty
    ( p_outer_lpn_id  IN  NUMBER
    , p_org_id        IN  NUMBER
    , p_itm_id        IN  NUMBER
    , p_rev           IN  VARCHAR2
    ) IS
      SELECT NVL(SUM(mmtt.primary_quantity),0)
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.transfer_lpn_id      = p_outer_lpn_id
         AND mmtt.organization_id      = p_org_id
         AND mmtt.parent_line_id       = mmtt.transaction_temp_id
         AND mmtt.transaction_quantity > 0
         AND mmtt.inventory_item_id    = p_itm_id
         AND NVL(mmtt.revision,'@@@@') = NVL(p_rev,'@@@@')
         AND ( mmtt.content_lpn_id IS NULL
               OR
               mmtt.content_lpn_id  = mmtt.transfer_lpn_id
             );


    CURSOR c_get_mmtt_qty
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT primary_quantity
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_temp_id;


    CURSOR c_get_parents
    ( p_outer_lpn_id  IN  NUMBER
    , p_org_id        IN  NUMBER
    , p_itm_id        IN  NUMBER
    , p_rev           IN  VARCHAR2
    ) IS
      SELECT mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.transfer_lpn_id      = p_outer_lpn_id
         AND mmtt.organization_id      = p_org_id
         AND mmtt.parent_line_id       = mmtt.transaction_temp_id
         AND mmtt.transaction_quantity > 0
         AND mmtt.inventory_item_id    = p_itm_id
         AND NVL(mmtt.revision,'@@@@') = NVL(p_rev,'@@@@')
         AND ( mmtt.content_lpn_id IS NULL
               OR
               mmtt.content_lpn_id  = mmtt.transfer_lpn_id
             );


    CURSOR c_get_parent_attributes
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mmtt.lpn_id
           , mmtt.content_lpn_id
           , mmtt.subinventory_code
           , mmtt.locator_id
           , mmtt.primary_quantity
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id;

    parent_rec  c_get_parent_attributes%ROWTYPE;

  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    fnd_msg_pub.initialize;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline               ||
         'p_group_number => '        || to_char(p_group_number) || g_newline ||
         'p_item_id      => '        || to_char(p_item_id)      || g_newline ||
         'p_revision     => '        || p_revision              || g_newline ||
         'p_qty          => '        || to_char(p_qty)          || g_newline ||
         'p_primary_uom  => '        || p_primary_uom
       , l_api_name
       );
    END IF;

    SAVEPOINT process_loose_sp;

    OPEN c_get_available_loose_qty
    ( g_current_drop_lpn.lpn_id
    , g_current_drop_lpn.organization_id
    , p_item_id
    , p_revision
    );
    FETCH c_get_available_loose_qty INTO l_available_qty;
    CLOSE c_get_available_loose_qty;

    IF l_available_qty < p_qty
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Not enough loose quantity available: '
            || to_char(l_available_qty)
          , l_api_name
          );
       END IF;

       fnd_message.set_name('WMS', 'WMS_NOT_ENOUGH_LOOSE_QTY');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
    ELSE
       IF l_debug = 1 THEN
          print_debug
          ( 'Available loose qty: ' || to_char(l_available_qty)
          , l_api_name
          );
       END IF;
    END IF;

    l_api_return_status := fnd_api.g_ret_sts_success;
    get_temp_list
    ( x_temp_tbl      => l_temp_tbl
    , x_return_status => l_api_return_status
    , p_group_num     => p_group_number
    , p_status        => 'PENDING'
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug ('Error from get_temp_list', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF NOT (l_temp_tbl.COUNT > 0)
    THEN
       IF l_debug = 1 THEN
          print_debug ('get_temp_list returned no MMTT records', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
       IF l_debug = 1 THEN
          print_debug
          ( 'MMTT record count from get_temp_list: '
            || to_char(l_temp_tbl.COUNT)
          , l_api_name
          );
       END IF;
    END IF;

    l_remaining_qty := p_qty;

    ii := l_temp_tbl.FIRST;
    jj := l_temp_tbl.LAST;

    kk := 1;

    l_transaction_temp_id := l_temp_tbl(ii);

    IF l_debug = 1 THEN
       print_debug
       ( 'ii = ' || to_char(ii) || ', jj = ' || to_char(jj) ||
         ', l_remaining_qty: '  || to_char(l_remaining_qty)
       , l_api_name
       );
    END IF;

    WHILE ( (ii <= jj)
            AND
            (l_remaining_qty > 0)
          )
    LOOP
       IF l_debug = 1 THEN
          print_debug
          ( ' Checking temp ID ' || to_char(l_transaction_temp_id)
          , l_api_name
          );
       END IF;

       OPEN c_get_mmtt_qty (l_transaction_temp_id);
       FETCH c_get_mmtt_qty INTO l_mmtt_qty;
       CLOSE c_get_mmtt_qty;

       IF l_debug = 1 THEN
          print_debug
          ( 'Primary qty is ' || to_char(l_mmtt_qty)
          , l_api_name
          );
       END IF;

       IF l_mmtt_qty <= l_remaining_qty
       THEN
          l_remaining_qty := l_remaining_qty - l_mmtt_qty;

          IF l_debug = 1 THEN
             print_debug
             ( 'Current MMTT qty <= remaining. '
               || 'Remaining is now: ' || to_char(l_remaining_qty)
             , l_api_name
             );
          END IF;

          l_process_tbl(kk) := l_transaction_temp_id;
          kk := kk + 1;

       ELSE
          l_api_return_status := fnd_api.g_ret_sts_success;
          split_mmtt
          ( x_new_temp_id   => l_new_temp_id
          , x_return_status => l_api_return_status
          , p_temp_id       => l_transaction_temp_id
          );

          IF l_api_return_status <> fnd_api.g_ret_sts_success
          THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'split_mmtt returned status ' || l_api_return_status
                , l_api_name
                );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          UPDATE mtl_material_transactions_temp
             SET transaction_quantity = DECODE( transaction_uom
                                              , p_primary_uom, l_remaining_qty
                                              , inv_convert.inv_um_convert
                                                ( p_item_id
                                                , NULL
                                                , l_remaining_qty
                                                , p_primary_uom
                                                , transaction_uom
                                                , NULL
                                                , NULL
                                                )
                                              )
               , primary_quantity     = l_remaining_qty
               , reservation_quantity = DECODE( reservation_quantity
                                              , NULL, NULL
                                              , l_remaining_qty
                                              )
           WHERE transaction_temp_id = l_transaction_temp_id
                 RETURNING transaction_quantity INTO l_txn_qty;

          IF l_debug = 1 THEN
             print_debug
             ('Reduced qty for temp ID ' || to_char(l_transaction_temp_id)
              || ' to '                  || to_char(l_remaining_qty)
             , l_api_name
             );
          END IF;

          UPDATE mtl_material_transactions_temp
             SET transaction_quantity = transaction_quantity - l_txn_qty
               , primary_quantity     = primary_quantity     - l_remaining_qty
               , reservation_quantity = DECODE( reservation_quantity
                                              , NULL, NULL
                                              , reservation_quantity - l_remaining_qty
                                              )
               , lpn_id               = NULL
               , transfer_lpn_id      = NULL
               , subinventory_code    = NULL
               , locator_id           = NULL
           WHERE transaction_temp_id = l_new_temp_id
                 RETURNING primary_quantity INTO l_pri_qty;

          IF l_debug = 1 THEN
             print_debug
             ('Updated new temp ID ' || to_char(l_new_temp_id) ||
              ' with qty : '         || to_char(l_pri_qty)
             , l_api_name
             );
          END IF;

          l_process_tbl(kk) := l_transaction_temp_id;
          l_remaining_qty := 0;
       END IF;

       IF ii < jj THEN
          ii := l_temp_tbl.NEXT(ii);
          l_transaction_temp_id := l_temp_tbl(ii);
       ELSE
          EXIT;
       END IF;

       IF l_debug = 1 THEN
          print_debug
          ( 'Fetched next temp ID: ' || to_char(l_transaction_temp_id)
          , l_api_name
          );
       END IF;
    END LOOP;

    l_temp_tbl.DELETE;

    IF l_remaining_qty > 0
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Some qty remaining: ' || to_char(l_remaining_qty)
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OPEN c_get_parents
    ( g_current_drop_lpn.lpn_id
    , g_current_drop_lpn.organization_id
    , p_item_id
    , p_revision
    );
    FETCH c_get_parents BULK COLLECT INTO l_parent_tbl;
    CLOSE c_get_parents;

    IF NOT (l_parent_tbl.COUNT > 0)
    THEN
       IF l_debug = 1 THEN
          print_debug ('No parent MMTT records found', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
       IF l_debug = 1 THEN
          print_debug
          ( 'MMTT parent record count: '
            || to_char(l_parent_tbl.COUNT)
          , l_api_name
          );
       END IF;
    END IF;

    kk := l_parent_tbl.FIRST;
    l_parent_temp_id := l_parent_tbl(kk);

    OPEN c_get_parent_attributes (l_parent_temp_id);
    FETCH c_get_parent_attributes INTO parent_rec;
    CLOSE c_get_parent_attributes;

    l_remaining_qty := parent_rec.primary_quantity;

    ii := l_process_tbl.FIRST;
    jj := l_process_tbl.LAST;

    l_transaction_temp_id := l_process_tbl(ii);

    IF l_debug = 1 THEN
       print_debug
       ( 'ii = ' || to_char(ii) || ', jj = ' || to_char(jj) ||
         ', l_remaining_qty: '  || to_char(l_remaining_qty)
       , l_api_name
       );
    END IF;

    LOOP
       IF l_debug = 1 THEN
          print_debug
          ( 'Updating temp ID '  || to_char(l_transaction_temp_id) ||
            ' with parent attr ' || to_char(l_parent_temp_id)
          , l_api_name
          );
       END IF;

       UPDATE mtl_material_transactions_temp  mmtt
          SET lpn_id            = NVL(parent_rec.content_lpn_id,parent_rec.lpn_id)
            , subinventory_code = parent_rec.subinventory_code
            , locator_id        = parent_rec.locator_id
        WHERE mmtt.transaction_temp_id  = l_transaction_temp_id
              RETURNING mmtt.primary_quantity
                   INTO l_mmtt_qty;

       IF l_debug = 1 THEN
          print_debug
          ( ' Updated temp ID '    || to_char(l_transaction_temp_id)
            || ', primary qty is ' || to_char(l_mmtt_qty)
          , l_api_name
          );
       END IF;

       IF l_mmtt_qty <= l_remaining_qty
       THEN
          l_remaining_qty := l_remaining_qty - l_mmtt_qty;

          IF l_debug = 1 THEN
             print_debug
             ( 'Current MMTT qty <= remaining. '
               || 'Remaining is now: ' || to_char(l_remaining_qty)
             , l_api_name
             );
          END IF;

          UPDATE mtl_material_transactions_temp  mmtt
             SET transaction_quantity = DECODE( transaction_uom
                                              , p_primary_uom, (primary_quantity - l_mmtt_qty)
                                              , inv_convert.inv_um_convert
                                                ( p_item_id
                                                , NULL
                                                , primary_quantity - l_mmtt_qty
                                                , p_primary_uom
                                                , transaction_uom
                                                , NULL
                                                , NULL
                                                )
                                              )
               , primary_quantity     = primary_quantity - l_mmtt_qty
               , reservation_quantity = DECODE( reservation_quantity
                                              , NULL, NULL
                                              , reservation_quantity - l_mmtt_qty
                                              )
           WHERE mmtt.transaction_temp_id = l_parent_temp_id;
       ELSE
          l_api_return_status := fnd_api.g_ret_sts_success;
          split_mmtt
          ( x_new_temp_id   => l_new_temp_id
          , x_return_status => l_api_return_status
          , p_temp_id       => l_transaction_temp_id
          );

          IF l_api_return_status <> fnd_api.g_ret_sts_success
          THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'split_mmtt returned status ' || l_api_return_status
                , l_api_name
                );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          UPDATE mtl_material_transactions_temp
             SET transaction_quantity = DECODE( transaction_uom
                                              , p_primary_uom, l_remaining_qty
                                              , inv_convert.inv_um_convert
                                                ( p_item_id
                                                , NULL
                                                , l_remaining_qty
                                                , p_primary_uom
                                                , transaction_uom
                                                , NULL
                                                , NULL
                                                )
                                              )
               , primary_quantity     = l_remaining_qty
               , reservation_quantity = DECODE( reservation_quantity
                                              , NULL, NULL
                                              , l_remaining_qty
                                              )
           WHERE transaction_temp_id = l_transaction_temp_id
                 RETURNING transaction_quantity INTO l_txn_qty;

          IF l_debug = 1 THEN
             print_debug
             ('Reduced qty for temp ID ' || to_char(l_transaction_temp_id)
              || ' to '                  || to_char(l_remaining_qty)
             , l_api_name
             );
          END IF;

          UPDATE mtl_material_transactions_temp
             SET transaction_quantity = transaction_quantity - l_txn_qty
               , primary_quantity     = primary_quantity     - l_remaining_qty
               , reservation_quantity = DECODE( reservation_quantity
                                              , NULL, NULL
                                              , reservation_quantity - l_remaining_qty
                                              )
               , lpn_id               = NULL
               , transfer_lpn_id      = NULL
               , subinventory_code    = NULL
               , locator_id           = NULL
           WHERE transaction_temp_id = l_new_temp_id
                 RETURNING primary_quantity INTO l_pri_qty;

          IF l_debug = 1 THEN
             print_debug
             ('Updated new temp ID ' || to_char(l_new_temp_id) ||
              ' with qty : '         || to_char(l_pri_qty)
             , l_api_name
             );
          END IF;

          jj := jj + 1;
          l_process_tbl(jj) := l_new_temp_id;

          UPDATE mtl_material_transactions_temp  mmtt
             SET transaction_quantity = 0
               , primary_quantity     = 0
               , reservation_quantity = 0
           WHERE mmtt.transaction_temp_id = l_parent_temp_id;

          l_remaining_qty := 0;

       END IF;

       g_current_drop_lpn.current_drop_list(l_transaction_temp_id) := 'LSE_DONE';

       IF l_debug = 1 THEN
          print_debug
          ( ' Done processing temp ID ' || to_char(l_transaction_temp_id)
          , l_api_name
          );
       END IF;

       IF ii < jj THEN
          ii := l_process_tbl.NEXT(ii);
          l_transaction_temp_id := l_process_tbl(ii);

          IF l_remaining_qty = 0
          THEN
             kk := l_parent_tbl.NEXT(kk);
             IF kk IS NOT NULL
             THEN
                l_parent_temp_id := l_parent_tbl(kk);
             ELSE
                IF l_debug = 1 THEN
                   print_debug
                   ( 'No parent records remaining, and not all child records processed.'
                   , l_api_name
                   );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             OPEN c_get_parent_attributes (l_parent_temp_id);
             FETCH c_get_parent_attributes INTO parent_rec;
             CLOSE c_get_parent_attributes;

             l_remaining_qty := parent_rec.primary_quantity;
          END IF;

       ELSE
          EXIT;
       END IF;

       IF l_debug = 1 THEN
          print_debug
          ( 'Fetched next temp ID: ' || to_char(l_transaction_temp_id)
          , l_api_name
          );
       END IF;
    END LOOP;

    BEGIN
       SELECT 'x'
         INTO l_dummy
         FROM dual
        WHERE EXISTS
            ( SELECT 'x'
                FROM mtl_material_transactions_temp  mmtt
               WHERE mmtt.organization_id = g_current_drop_lpn.organization_id
                 AND mmtt.transfer_lpn_id = g_current_drop_lpn.lpn_id
                 AND mmtt.parent_line_id  = mmtt.transaction_temp_id
                 AND mmtt.transaction_quantity > 0
                 AND mmtt.inventory_item_id    = p_item_id
                 AND NVL(mmtt.revision,'@@@@') = NVL(p_revision,'@@@@')
                 AND ( mmtt.content_lpn_id IS NULL
                       OR
                       mmtt.content_lpn_id  = mmtt.transfer_lpn_id
                     )
            );
       l_loose_qty_exists := 'Y';
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            l_loose_qty_exists := 'N';
    END;

    x_loose_qty_exists := l_loose_qty_exists;

    l_process_tbl.DELETE;
    l_parent_tbl.DELETE;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK to process_loose_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK to process_loose_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END process_loose_qty;



  PROCEDURE process_serial
  ( x_loose_qty_exists  OUT NOCOPY  VARCHAR2
  , x_return_status     OUT NOCOPY  VARCHAR2
  , p_organization_id   IN          NUMBER
  , p_transfer_lpn_id   IN          NUMBER
  , p_lpn               IN          VARCHAR2
  , p_item_id           IN          NUMBER
  , p_revision          IN          VARCHAR2
  , p_lot_number        IN          VARCHAR2
  , p_serial_number     IN          VARCHAR2
  , p_group_number      IN          NUMBER
  ) IS

    l_api_name             VARCHAR2(30) := 'process_serial';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_api_return_status    VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    l_inner_lpn_id         NUMBER := NULL;
    l_transaction_temp_id  NUMBER;
    l_orig_temp_id         NUMBER;
    l_parent_line_id       NUMBER;
    l_txn_header_id        NUMBER;
    l_parent_found         BOOLEAN;
    l_srl_temp_id          NUMBER;
    l_primary_qty          NUMBER;
    l_serial_count         NUMBER;
    l_temp_id              NUMBER;
    l_temp_found           BOOLEAN;

    l_old_mtlt_rowid       ROWID;
    l_mtlt_rec             mtl_transaction_lots_temp%ROWTYPE;

    ii                     NUMBER;
    jj                     NUMBER;

    l_dummy                VARCHAR2(1)  := NULL;
    l_loose_qty_exists     VARCHAR2(1)  := NULL;


    CURSOR c_get_inner_lpn_id
    ( p_inner_lpn     IN  VARCHAR2
    , p_outer_lpn_id  IN  NUMBER
    , p_org_id        IN  NUMBER
    ) IS
      SELECT wlpn.lpn_id
        FROM wms_license_plate_numbers       wlpn
           , mtl_material_transactions_temp  mmtt
       WHERE wlpn.license_plate_number = p_inner_lpn
         AND wlpn.organization_id = p_org_id
         AND mmtt.transfer_lpn_id = p_outer_lpn_id
         AND mmtt.organization_id = p_org_id
         AND mmtt.parent_line_id  = mmtt.transaction_temp_id
         AND mmtt.content_lpn_id  = wlpn.lpn_id;


    CURSOR c_get_loose_msnt
    ( p_xfer_lpn_id  IN  NUMBER
    , p_org_id       IN  NUMBER
    , p_serial_num   IN  VARCHAR2
    ) IS
      SELECT msnt.rowid
           , mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp  mmtt
           , mtl_serial_numbers_temp         msnt
       WHERE mmtt.organization_id       = p_org_id
         AND mmtt.transfer_lpn_id       = p_xfer_lpn_id
         AND mmtt.transaction_temp_id   = mmtt.parent_line_id
         AND ( mmtt.content_lpn_id IS NULL
               OR
               mmtt.content_lpn_id  = mmtt.transfer_lpn_id
             )
         AND mmtt.transaction_temp_id   = msnt.transaction_temp_id
         AND msnt.fm_serial_number      = p_serial_num;

    msnt_rec  c_get_loose_msnt%ROWTYPE;

    CURSOR c_get_lpn_msnt
    ( p_xfer_lpn_id  IN  NUMBER
    , p_org_id       IN  NUMBER
    , p_serial_num   IN  VARCHAR2
    , p_lpn_id       IN  NUMBER
    ) IS
      SELECT msnt.rowid
           , mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp  mmtt
           , mtl_serial_numbers_temp         msnt
       WHERE mmtt.organization_id       = p_org_id
         AND mmtt.transfer_lpn_id       = p_xfer_lpn_id
         AND mmtt.transaction_temp_id   = mmtt.parent_line_id
         AND mmtt.content_lpn_id        = p_lpn_id
         AND mmtt.transaction_temp_id   = msnt.transaction_temp_id
         AND msnt.fm_serial_number      = p_serial_num;


    CURSOR c_get_lot_msnt
    ( p_xfer_lpn_id  IN  NUMBER
    , p_org_id       IN  NUMBER
    , p_lot_num      IN  VARCHAR2
    , p_serial_num   IN  VARCHAR2
    , p_lpn_id       IN  NUMBER
    ) IS
      SELECT msnt.rowid
           , mmtt.transaction_temp_id   transaction_temp_id
        FROM mtl_material_transactions_temp  mmtt
           , mtl_transaction_lots_temp       mtlt
           , mtl_serial_numbers_temp         msnt
       WHERE mmtt.organization_id       = p_org_id
         AND mmtt.transfer_lpn_id       = p_xfer_lpn_id
         AND mmtt.transaction_temp_id   = mmtt.parent_line_id
         AND NVL(mmtt.content_lpn_id,0) = NVL(p_lpn_id,0)
         AND mmtt.transaction_temp_id   = mtlt.transaction_temp_id
         AND mtlt.lot_number            = p_lot_num
         AND msnt.transaction_temp_id   = mtlt.serial_transaction_temp_id
         AND msnt.fm_serial_number      = p_serial_num;

    lot_msnt_rec  c_get_lot_msnt%ROWTYPE;


    CURSOR c_get_parent
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT parent_line_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id;


    CURSOR c_get_parent_attributes
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mmtt.lpn_id
           , mmtt.content_lpn_id
           , mmtt.subinventory_code
           , mmtt.locator_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id;

    parent_rec  c_get_parent_attributes%ROWTYPE;


    CURSOR c_get_lot_srl_count
    ( p_temp_id  IN  NUMBER
    , p_lot_num  IN  VARCHAR2
    ) IS
      SELECT mtlt.primary_quantity
           , COUNT(msnt.fm_serial_number)    srl_count
        FROM mtl_material_transactions_temp  mmtt
           , mtl_transaction_lots_temp       mtlt
           , mtl_serial_numbers_temp         msnt
       WHERE mmtt.transaction_temp_id     = p_temp_id
         AND mmtt.transaction_temp_id     = mtlt.transaction_temp_id
         AND mtlt.lot_number              = p_lot_num
         AND msnt.transaction_temp_id (+) = mtlt.serial_transaction_temp_id
       GROUP BY mtlt.primary_quantity;


    CURSOR c_get_serial_count
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mmtt.primary_quantity
           , COUNT(msnt.fm_serial_number)    srl_count
        FROM mtl_material_transactions_temp  mmtt
           , mtl_serial_numbers_temp         msnt
       WHERE mmtt.transaction_temp_id     = p_temp_id
         AND msnt.transaction_temp_id (+) = mmtt.transaction_temp_id
       GROUP BY mmtt.primary_quantity;


  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_msg_pub.initialize;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id) || g_newline ||
         'p_lpn             => '     || p_lpn                      || g_newline ||
         'p_item_id         => '     || to_char(p_item_id)         || g_newline ||
         'p_revision        => '     || p_revision                 || g_newline ||
         'p_lot_number      => '     || p_lot_number               || g_newline ||
         'p_serial_number   => '     || p_serial_number            || g_newline ||
         'p_group_number    => '     || to_char(p_group_number)
       , l_api_name
       );
    END IF;

    SAVEPOINT process_serial_sp;

    --
    -- Validate passed in Org and LPN
    --
    IF p_organization_id <> g_current_drop_lpn.organization_id
       OR
       p_transfer_lpn_id <> g_current_drop_lpn.lpn_id
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Passed in org or LPN did not match cached info: '
            || g_newline || 'p_organization_id: ' || to_char(p_organization_id)
            || g_newline || 'p_transfer_lpn_id: ' || to_char(p_transfer_lpn_id)
            || g_newline || 'Cached Org ID:     ' || to_char(g_current_drop_lpn.organization_id)
            || g_newline || 'Cached LPN ID:     ' || to_char(g_current_drop_lpn.lpn_id)
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF p_lpn IS NOT NULL
    THEN
       OPEN c_get_inner_lpn_id
       ( p_lpn
       , g_current_drop_lpn.lpn_id
       , g_current_drop_lpn.organization_id
       );
       FETCH c_get_inner_lpn_id INTO l_inner_lpn_id;

       IF c_get_inner_lpn_id%NOTFOUND THEN
          CLOSE c_get_inner_lpn_id;
          IF l_debug = 1 THEN
             print_debug
             ( 'Cannot find nested LPN ' || p_lpn ||
               ' in outer LPN ID '       || to_char(g_current_drop_lpn.lpn_id)
             , l_api_name
             );
          END IF;

          fnd_message.set_name('WMS', 'WMS_LPN_NOT_IN_OUTER');
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
       ELSE
          IF l_debug = 1 THEN
             print_debug
             ( 'Found scanned LPN ' || p_lpn                   ||
               '. LPN ID is '       || to_char(l_inner_lpn_id)
             , l_api_name
             );
          END IF;
       END IF;
    END IF;

    IF p_lot_number IS NOT NULL
    THEN
       OPEN c_get_lot_msnt
       ( p_transfer_lpn_id
       , p_organization_id
       , p_lot_number
       , p_serial_number
       , l_inner_lpn_id
       );
       FETCH c_get_lot_msnt INTO lot_msnt_rec;

       IF c_get_lot_msnt%NOTFOUND THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'Serial number not found'
             , l_api_name
             );
          END IF;
          CLOSE c_get_lot_msnt;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF c_get_lot_msnt%ISOPEN THEN
          CLOSE c_get_lot_msnt;
       END IF;
    ELSE
       IF p_lpn IS NULL
       THEN
          OPEN c_get_loose_msnt
          ( p_transfer_lpn_id
          , p_organization_id
          , p_serial_number
          );
          FETCH c_get_loose_msnt INTO msnt_rec;

          IF c_get_loose_msnt%NOTFOUND THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'Serial number not found'
                , l_api_name
                );
             END IF;
             CLOSE c_get_loose_msnt;
             fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
             fnd_msg_pub.ADD;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
          IF c_get_loose_msnt%ISOPEN THEN
             CLOSE c_get_loose_msnt;
          END IF;
       ELSE
          OPEN c_get_lpn_msnt
          ( p_transfer_lpn_id
          , p_organization_id
          , p_serial_number
          , l_inner_lpn_id
          );
          FETCH c_get_lpn_msnt INTO msnt_rec;

          IF c_get_lpn_msnt%NOTFOUND THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'Serial number not found'
                , l_api_name
                );
             END IF;
             CLOSE c_get_lpn_msnt;
             fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
             fnd_msg_pub.ADD;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
          IF c_get_lpn_msnt%ISOPEN THEN
             CLOSE c_get_lpn_msnt;
          END IF;
       END IF;
    END IF;

    IF l_debug = 1 THEN
       print_debug( 'Serial number found', l_api_name);
    END IF;

    IF (NOT (g_cur_pend_temp.COUNT > 0)) THEN
       l_api_return_status := fnd_api.g_ret_sts_success;

       IF p_lpn IS NOT NULL
       THEN
          get_temp_list
          ( x_temp_tbl      => g_cur_pend_temp
          , x_return_status => l_api_return_status
          , p_group_num     => p_group_number
          , p_status        => 'LPN_DONE'
          );
       ELSE
          get_temp_list
          ( x_temp_tbl      => g_cur_pend_temp
          , x_return_status => l_api_return_status
          , p_group_num     => p_group_number
          , p_status        => 'PENDING'
          );
       END IF;

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug ('Error from get_temp_list', l_api_name);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    IF (NOT (g_cur_pend_temp.COUNT > 0)) THEN
       IF l_debug = 1 THEN
          print_debug ('No temp IDs found', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ii := g_cur_pend_temp.FIRST;
    jj := g_cur_pend_temp.LAST;

    IF l_debug = 1 THEN
       print_debug
       ( 'ii = ' || to_char(ii) || ', jj = ' || to_char(jj)
       , l_api_name
       );
    END IF;

    l_parent_found := FALSE;
    l_transaction_temp_id := g_cur_pend_temp(ii);
    WHILE ( (ii <= jj)
            AND
            (NOT l_parent_found)
          )
    LOOP
       OPEN c_get_parent(l_transaction_temp_id);
       FETCH c_get_parent INTO l_parent_line_id;
       CLOSE c_get_parent;

       IF l_debug = 1 THEN
          print_debug
          ( 'Temp ID: '  || to_char(l_transaction_temp_id) ||
            ', parent: ' || to_char(l_parent_line_id)
          , l_api_name
          );
       END IF;

       IF p_lot_number IS NOT NULL
       THEN
          IF l_parent_line_id = lot_msnt_rec.transaction_temp_id
          THEN
             l_parent_found := TRUE;
             EXIT;
          END IF;
       ELSE
          IF l_parent_line_id = msnt_rec.transaction_temp_id
          THEN
             l_parent_found := TRUE;
             EXIT;
          END IF;
       END IF;

       IF NOT l_parent_found THEN
          IF ii < jj THEN
             ii := g_cur_pend_temp.NEXT(ii);
             l_transaction_temp_id := g_cur_pend_temp(ii);
          ELSE
             EXIT;
          END IF;
       END IF;
    END LOOP;

    IF NOT l_parent_found THEN
       l_orig_temp_id := g_cur_pend_temp(g_cur_pend_temp.FIRST);

       l_api_return_status := fnd_api.g_ret_sts_success;
       split_mmtt
       ( x_new_temp_id   => l_transaction_temp_id
       , x_return_status => l_api_return_status
       , p_temp_id       => l_orig_temp_id
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug ('Error from split_mmtt', l_api_name);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       UPDATE mtl_material_transactions_temp
          SET transaction_quantity = transaction_quantity - 1
            , primary_quantity     = primary_quantity - 1
            , reservation_quantity = DECODE( reservation_quantity
                                           , NULL, NULL
                                           , reservation_quantity - 1
                                           )
        WHERE transaction_temp_id = l_orig_temp_id;

       IF l_debug = 1 THEN
          print_debug
          ('Reduced qty by 1 for temp ID ' || to_char(l_orig_temp_id)
          , l_api_name
          );
       END IF;

       IF p_lot_number IS NOT NULL
       THEN
          BEGIN
             SELECT mtlt.rowid
               INTO l_old_mtlt_rowid
               FROM mtl_transaction_lots_temp  mtlt
              WHERE mtlt.transaction_temp_id = l_orig_temp_id
                AND mtlt.lot_number          = p_lot_number
                AND rownum < 2;

             IF l_debug = 1 THEN
                print_debug ('Found rowid for old MTLT record', l_api_name);
             END IF;

             UPDATE mtl_transaction_lots_temp
                SET transaction_quantity = transaction_quantity - 1
                  , primary_quantity     = primary_quantity - 1
              WHERE rowid = l_old_mtlt_rowid;

             IF l_debug = 1 AND SQL%FOUND
             THEN
                print_debug ('Reduced qty by 1 for old MTLT record', l_api_name);
             END IF;

             OPEN c_get_parent_attributes (lot_msnt_rec.transaction_temp_id);
             FETCH c_get_parent_attributes INTO parent_rec;
             CLOSE c_get_parent_attributes;

             UPDATE mtl_material_transactions_temp
                SET transaction_quantity = 1
                  , primary_quantity     = 1
                  , reservation_quantity = DECODE( reservation_quantity
                                                 , NULL, NULL
                                                 , 1
                                                 )
                  , parent_line_id       = lot_msnt_rec.transaction_temp_id
                  , subinventory_code    = parent_rec.subinventory_code
                  , locator_id           = parent_rec.locator_id
                  , lpn_id               = NVL( l_inner_lpn_id
                                              , NVL( parent_rec.content_lpn_id
                                                   , parent_rec.lpn_id
                                                   )
                                              )
              WHERE transaction_temp_id = l_transaction_temp_id;

             IF l_debug = 1 AND SQL%FOUND
             THEN
                print_debug
                ('Updated new temp ID ' || to_char(l_transaction_temp_id) ||
                 ' with qty 1, sub '    || parent_rec.subinventory_code   ||
                 ', locator ID: '       || to_char(parent_rec.locator_id) ||
                 ', LPN ID: '           || to_char( NVL( l_inner_lpn_id
                                                       , NVL( parent_rec.content_lpn_id
                                                            , parent_rec.lpn_id
                                                            )
                                                       )
                                                  )                       ||
                 ', parent line ID: '   || to_char(lot_msnt_rec.transaction_temp_id)
                , l_api_name
                );
             END IF;

             SELECT *
               INTO l_mtlt_rec
               FROM mtl_transaction_lots_temp
              WHERE rowid = l_old_mtlt_rowid;

             INSERT INTO mtl_transaction_lots_temp
             ( TRANSACTION_TEMP_ID
             , LAST_UPDATE_DATE
             , LAST_UPDATED_BY
             , CREATION_DATE
             , CREATED_BY
             , LAST_UPDATE_LOGIN
             , REQUEST_ID
             , PROGRAM_APPLICATION_ID
             , PROGRAM_ID
             , PROGRAM_UPDATE_DATE
             , TRANSACTION_QUANTITY
             , PRIMARY_QUANTITY
             , LOT_NUMBER
             , LOT_EXPIRATION_DATE
             , ERROR_CODE
             , SERIAL_TRANSACTION_TEMP_ID
             , GROUP_HEADER_ID
             , PUT_AWAY_RULE_ID
             , PICK_RULE_ID
             , DESCRIPTION
             , VENDOR_NAME
             , SUPPLIER_LOT_NUMBER
             , ORIGINATION_DATE
             , DATE_CODE
             , GRADE_CODE
             , CHANGE_DATE
             , MATURITY_DATE
             , STATUS_ID
             , RETEST_DATE
             , AGE
             , ITEM_SIZE
             , COLOR
             , VOLUME
             , VOLUME_UOM
             , PLACE_OF_ORIGIN
             , BEST_BY_DATE
             , LENGTH
             , LENGTH_UOM
             , RECYCLED_CONTENT
             , THICKNESS
             , THICKNESS_UOM
             , WIDTH
             , WIDTH_UOM
             , CURL_WRINKLE_FOLD
             , LOT_ATTRIBUTE_CATEGORY
             , C_ATTRIBUTE1
             , C_ATTRIBUTE2
             , C_ATTRIBUTE3
             , C_ATTRIBUTE4
             , C_ATTRIBUTE5
             , C_ATTRIBUTE6
             , C_ATTRIBUTE7
             , C_ATTRIBUTE8
             , C_ATTRIBUTE9
             , C_ATTRIBUTE10
             , C_ATTRIBUTE11
             , C_ATTRIBUTE12
             , C_ATTRIBUTE13
             , C_ATTRIBUTE14
             , C_ATTRIBUTE15
             , C_ATTRIBUTE16
             , C_ATTRIBUTE17
             , C_ATTRIBUTE18
             , C_ATTRIBUTE19
             , C_ATTRIBUTE20
             , D_ATTRIBUTE1
             , D_ATTRIBUTE2
             , D_ATTRIBUTE3
             , D_ATTRIBUTE4
             , D_ATTRIBUTE5
             , D_ATTRIBUTE6
             , D_ATTRIBUTE7
             , D_ATTRIBUTE8
             , D_ATTRIBUTE9
             , D_ATTRIBUTE10
             , N_ATTRIBUTE1
             , N_ATTRIBUTE2
             , N_ATTRIBUTE3
             , N_ATTRIBUTE4
             , N_ATTRIBUTE5
             , N_ATTRIBUTE6
             , N_ATTRIBUTE7
             , N_ATTRIBUTE8
             , N_ATTRIBUTE9
             , N_ATTRIBUTE10
             , VENDOR_ID
             , TERRITORY_CODE
             , SUBLOT_NUM
             , SECONDARY_QUANTITY
             , SECONDARY_UNIT_OF_MEASURE
             , QC_GRADE
             , REASON_CODE
             , PRODUCT_CODE
             , PRODUCT_TRANSACTION_ID
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
             )
             VALUES
             ( l_transaction_temp_id
             , l_mtlt_rec.LAST_UPDATE_DATE
             , l_mtlt_rec.LAST_UPDATED_BY
             , l_mtlt_rec.CREATION_DATE
             , l_mtlt_rec.CREATED_BY
             , l_mtlt_rec.LAST_UPDATE_LOGIN
             , l_mtlt_rec.REQUEST_ID
             , l_mtlt_rec.PROGRAM_APPLICATION_ID
             , l_mtlt_rec.PROGRAM_ID
             , l_mtlt_rec.PROGRAM_UPDATE_DATE
             , 1
             , 1
             , l_mtlt_rec.LOT_NUMBER
             , l_mtlt_rec.LOT_EXPIRATION_DATE
             , l_mtlt_rec.ERROR_CODE
             , l_mtlt_rec.SERIAL_TRANSACTION_TEMP_ID
             , l_mtlt_rec.GROUP_HEADER_ID
             , l_mtlt_rec.PUT_AWAY_RULE_ID
             , l_mtlt_rec.PICK_RULE_ID
             , l_mtlt_rec.DESCRIPTION
             , l_mtlt_rec.VENDOR_NAME
             , l_mtlt_rec.SUPPLIER_LOT_NUMBER
             , l_mtlt_rec.ORIGINATION_DATE
             , l_mtlt_rec.DATE_CODE
             , l_mtlt_rec.GRADE_CODE
             , l_mtlt_rec.CHANGE_DATE
             , l_mtlt_rec.MATURITY_DATE
             , l_mtlt_rec.STATUS_ID
             , l_mtlt_rec.RETEST_DATE
             , l_mtlt_rec.AGE
             , l_mtlt_rec.ITEM_SIZE
             , l_mtlt_rec.COLOR
             , l_mtlt_rec.VOLUME
             , l_mtlt_rec.VOLUME_UOM
             , l_mtlt_rec.PLACE_OF_ORIGIN
             , l_mtlt_rec.BEST_BY_DATE
             , l_mtlt_rec.LENGTH
             , l_mtlt_rec.LENGTH_UOM
             , l_mtlt_rec.RECYCLED_CONTENT
             , l_mtlt_rec.THICKNESS
             , l_mtlt_rec.THICKNESS_UOM
             , l_mtlt_rec.WIDTH
             , l_mtlt_rec.WIDTH_UOM
             , l_mtlt_rec.CURL_WRINKLE_FOLD
             , l_mtlt_rec.LOT_ATTRIBUTE_CATEGORY
             , l_mtlt_rec.C_ATTRIBUTE1
             , l_mtlt_rec.C_ATTRIBUTE2
             , l_mtlt_rec.C_ATTRIBUTE3
             , l_mtlt_rec.C_ATTRIBUTE4
             , l_mtlt_rec.C_ATTRIBUTE5
             , l_mtlt_rec.C_ATTRIBUTE6
             , l_mtlt_rec.C_ATTRIBUTE7
             , l_mtlt_rec.C_ATTRIBUTE8
             , l_mtlt_rec.C_ATTRIBUTE9
             , l_mtlt_rec.C_ATTRIBUTE10
             , l_mtlt_rec.C_ATTRIBUTE11
             , l_mtlt_rec.C_ATTRIBUTE12
             , l_mtlt_rec.C_ATTRIBUTE13
             , l_mtlt_rec.C_ATTRIBUTE14
             , l_mtlt_rec.C_ATTRIBUTE15
             , l_mtlt_rec.C_ATTRIBUTE16
             , l_mtlt_rec.C_ATTRIBUTE17
             , l_mtlt_rec.C_ATTRIBUTE18
             , l_mtlt_rec.C_ATTRIBUTE19
             , l_mtlt_rec.C_ATTRIBUTE20
             , l_mtlt_rec.D_ATTRIBUTE1
             , l_mtlt_rec.D_ATTRIBUTE2
             , l_mtlt_rec.D_ATTRIBUTE3
             , l_mtlt_rec.D_ATTRIBUTE4
             , l_mtlt_rec.D_ATTRIBUTE5
             , l_mtlt_rec.D_ATTRIBUTE6
             , l_mtlt_rec.D_ATTRIBUTE7
             , l_mtlt_rec.D_ATTRIBUTE8
             , l_mtlt_rec.D_ATTRIBUTE9
             , l_mtlt_rec.D_ATTRIBUTE10
             , l_mtlt_rec.N_ATTRIBUTE1
             , l_mtlt_rec.N_ATTRIBUTE2
             , l_mtlt_rec.N_ATTRIBUTE3
             , l_mtlt_rec.N_ATTRIBUTE4
             , l_mtlt_rec.N_ATTRIBUTE5
             , l_mtlt_rec.N_ATTRIBUTE6
             , l_mtlt_rec.N_ATTRIBUTE7
             , l_mtlt_rec.N_ATTRIBUTE8
             , l_mtlt_rec.N_ATTRIBUTE9
             , l_mtlt_rec.N_ATTRIBUTE10
             , l_mtlt_rec.VENDOR_ID
             , l_mtlt_rec.TERRITORY_CODE
             , l_mtlt_rec.SUBLOT_NUM
             , l_mtlt_rec.SECONDARY_QUANTITY
             , l_mtlt_rec.SECONDARY_UNIT_OF_MEASURE
             , l_mtlt_rec.QC_GRADE
             , l_mtlt_rec.REASON_CODE
             , l_mtlt_rec.PRODUCT_CODE
             , l_mtlt_rec.PRODUCT_TRANSACTION_ID
             , l_mtlt_rec.ATTRIBUTE_CATEGORY
             , l_mtlt_rec.ATTRIBUTE1
             , l_mtlt_rec.ATTRIBUTE2
             , l_mtlt_rec.ATTRIBUTE3
             , l_mtlt_rec.ATTRIBUTE4
             , l_mtlt_rec.ATTRIBUTE5
             , l_mtlt_rec.ATTRIBUTE6
             , l_mtlt_rec.ATTRIBUTE7
             , l_mtlt_rec.ATTRIBUTE8
             , l_mtlt_rec.ATTRIBUTE9
             , l_mtlt_rec.ATTRIBUTE10
             , l_mtlt_rec.ATTRIBUTE11
             , l_mtlt_rec.ATTRIBUTE12
             , l_mtlt_rec.ATTRIBUTE13
             , l_mtlt_rec.ATTRIBUTE14
             , l_mtlt_rec.ATTRIBUTE15
             );

             IF l_debug = 1 AND SQL%FOUND
             THEN
                print_debug ('Inserted new MTLT', l_api_name);
             END IF;

          EXCEPTION
             WHEN OTHERS THEN
               IF l_debug = 1 THEN
                  print_debug
                  ( 'Exception processing MTLT records: ' || sqlerrm
                  , l_api_name
                  );
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;
       ELSE
          --
          -- Not lot controlled
          --
          OPEN c_get_parent_attributes (msnt_rec.transaction_temp_id);
          FETCH c_get_parent_attributes INTO parent_rec;
          CLOSE c_get_parent_attributes;

          UPDATE mtl_material_transactions_temp
             SET transaction_quantity = 1
               , primary_quantity     = 1
               , reservation_quantity = DECODE( reservation_quantity
                                              , NULL, NULL
                                              , 1
                                              )
               , parent_line_id       = msnt_rec.transaction_temp_id
               , subinventory_code    = parent_rec.subinventory_code
               , locator_id           = parent_rec.locator_id
               , lpn_id               = NVL( l_inner_lpn_id
                                           , NVL( parent_rec.content_lpn_id
                                                , parent_rec.lpn_id
                                                )
                                           )
           WHERE transaction_temp_id = l_transaction_temp_id;

          IF l_debug = 1 THEN
             print_debug
             ('Updated new temp ID ' || to_char(l_transaction_temp_id) ||
              ' with qty 1, sub '    || parent_rec.subinventory_code   ||
              ', locator ID: '       || to_char(parent_rec.locator_id) ||
              ', LPN ID: '           || to_char( NVL( l_inner_lpn_id
                                                    , NVL( parent_rec.content_lpn_id
                                                         , parent_rec.lpn_id
                                                         )
                                                    )
                                               )                       ||
              ', parent line ID: '   || to_char(msnt_rec.transaction_temp_id)
             , l_api_name
             );
          END IF;
       END IF; -- end if lot controlled
    ELSE
       IF p_lot_number IS NULL
          AND
          p_lpn        IS NULL
       THEN
          OPEN c_get_parent_attributes (msnt_rec.transaction_temp_id);
          FETCH c_get_parent_attributes INTO parent_rec;
          CLOSE c_get_parent_attributes;

          UPDATE mtl_material_transactions_temp
             SET subinventory_code = parent_rec.subinventory_code
               , locator_id        = parent_rec.locator_id
               , lpn_id            = NVL(parent_rec.content_lpn_id,parent_rec.lpn_id)
           WHERE transaction_temp_id = l_transaction_temp_id;

          IF l_debug = 1 AND SQL%FOUND
          THEN
             print_debug
             ('Updated temp ID '    || to_char(l_transaction_temp_id) ||
              ' with subinventory ' || parent_rec.subinventory_code   ||
              ', locator ID: '      || to_char(parent_rec.locator_id) ||
              ' and LPN ID: '       || to_char(NVL( parent_rec.content_lpn_id
                                                  , parent_rec.lpn_id
                                                  )
                                              )
             , l_api_name
             );
          END IF;
       END IF;
    END IF; -- end if parent NOT found

    --
    -- Transfer the MSNT record to child
    --
    IF p_lot_number IS NOT NULL
    THEN
       --
       -- Get serial temp ID or generate new
       --
       BEGIN
         SELECT mtlt.serial_transaction_temp_id
           INTO l_srl_temp_id
           FROM mtl_transaction_lots_temp  mtlt
          WHERE mtlt.transaction_temp_id = l_transaction_temp_id
            AND mtlt.lot_number          = p_lot_number;

         IF l_debug = 1 THEN
            print_debug
            ( 'Serial temp ID is: ' || to_char(l_srl_temp_id)
            , l_api_name
            );
         END IF;
       EXCEPTION
         WHEN OTHERS THEN
           IF l_debug = 1 THEN
              print_debug
              ( 'Exception getting serial temp ID for '           ||
                ' lot number '  || p_lot_number                   ||
                ' and temp ID'  || to_char(l_transaction_temp_id) ||
                ': '            || sqlerrm
              , l_api_name
              );
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;

       IF l_srl_temp_id IS NULL
       THEN
          SELECT mtl_material_transactions_s.NEXTVAL
            INTO l_srl_temp_id
            FROM dual;

          IF l_debug = 1 THEN
             print_debug
             ( 'New srl temp ID: ' || to_char(l_srl_temp_id)
             , l_api_name
             );
          END IF;

          UPDATE mtl_transaction_lots_temp  mtlt
             SET mtlt.serial_transaction_temp_id = l_srl_temp_id
           WHERE mtlt.transaction_temp_id   = l_transaction_temp_id
             AND mtlt.lot_number            = p_lot_number;
       END IF;

       UPDATE mtl_serial_numbers_temp  msnt
          SET transaction_temp_id = l_srl_temp_id
        WHERE rowid = lot_msnt_rec.rowid;

    ELSE
       UPDATE mtl_serial_numbers_temp  msnt
          SET transaction_temp_id = l_transaction_temp_id
        WHERE rowid = msnt_rec.rowid;

    END IF;

    IF l_debug = 1 AND SQL%FOUND
    THEN
       print_debug
       ( 'Updated MSNT record for serial ' || p_serial_number
       , l_api_name
       );
    END IF;

    --
    -- Now update the parent
    --
    BEGIN
       UPDATE mtl_material_transactions_temp
          SET transaction_quantity = transaction_quantity - 1
            , primary_quantity     = primary_quantity - 1
        WHERE transaction_temp_id  = l_parent_line_id;

       IF l_debug = 1 AND SQL%FOUND
       THEN
          print_debug
          ( 'Decremented txn/primary qty on parent MMTT record '
            || to_char(l_parent_line_id)
          , l_api_name
          );
       END IF;

       IF p_lot_number IS NOT NULL
       THEN
          UPDATE mtl_transaction_lots_temp
             SET transaction_quantity = transaction_quantity - 1
               , primary_quantity     = primary_quantity - 1
           WHERE transaction_temp_id  = l_parent_line_id
             AND lot_number           = p_lot_number;

          IF l_debug = 1 AND SQL%FOUND
          THEN
             print_debug
             ( 'Decremented txn/primary qty on parent record for lot '
               || p_lot_number
             , l_api_name
             );
          END IF;
       END IF;
    EXCEPTION
       WHEN OTHERS THEN
         IF l_debug = 1 THEN
            print_debug
            ( 'Error updating txn/primary quantity: ' || sqlerrm
            , l_api_name
            );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    BEGIN
       SELECT mmtt.transaction_header_id
         INTO l_txn_header_id
         FROM mtl_material_transactions_temp  mmtt
        WHERE mmtt.transaction_temp_id = l_transaction_temp_id;
    EXCEPTION
       WHEN OTHERS THEN
         IF l_debug = 1 THEN
            print_debug
            ( 'Error getting txn header ID: ' || sqlerrm
            , l_api_name
            );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    UPDATE mtl_serial_numbers
       SET group_mark_id = l_txn_header_id
     WHERE current_organization_id = p_organization_id
       AND inventory_item_id       = p_item_id
       AND NVL(revision,'@@@@')    = NVL(p_revision,'@@@@')
       AND serial_number           = p_serial_number;

    IF l_debug = 1 THEN
       print_debug
       ( 'Updated MSN record with header_id ' || to_char(l_txn_header_id)
       , l_api_name
       );
    END IF;

    IF NOT l_parent_found
    THEN
       g_current_drop_lpn.current_drop_list(l_transaction_temp_id) := 'SRL_DONE';
       IF l_debug = 1 THEN
          print_debug
          ( 'Marking new temp ID ' || to_char(l_transaction_temp_id) ||
            ' as SRL_DONE.'
          , l_api_name
          );
       END IF;

       l_transaction_temp_id := l_orig_temp_id;

       IF l_debug = 1 THEN
          print_debug
          ( 'l_transaction_temp_id is now ' || to_char(l_transaction_temp_id)
          , l_api_name
          );
       END IF;
    END IF;

    IF p_lot_number IS NOT NULL
    THEN
       OPEN c_get_lot_srl_count
       ( l_transaction_temp_id
       , p_lot_number
       );
       FETCH c_get_lot_srl_count
        INTO l_primary_qty
           , l_serial_count;

       IF c_get_lot_srl_count%NOTFOUND
       THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'c_get_lot_srl_count returned no records'
             , l_api_name
             );
          END IF;
          CLOSE c_get_lot_srl_count;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF c_get_lot_srl_count%ISOPEN
       THEN
          CLOSE c_get_lot_srl_count;
       END IF;
    ELSE
       OPEN c_get_serial_count (l_transaction_temp_id);
       FETCH c_get_serial_count
        INTO l_primary_qty
           , l_serial_count;

       IF c_get_serial_count%NOTFOUND
       THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'c_get_serial_count returned no records'
             , l_api_name
             );
          END IF;
          CLOSE c_get_serial_count;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF c_get_serial_count%ISOPEN
       THEN
          CLOSE c_get_serial_count;
       END IF;
    END IF;

    IF l_debug = 1 THEN
       print_debug
       ( 'l_primary_qty: '    || to_char(l_primary_qty) ||
         ', l_serial_count: ' || to_char(l_serial_count)
       , l_api_name
       );
    END IF;

    IF (NOT (l_primary_qty > l_serial_count))
    THEN
       --
       -- Set status to SRL_DONE, remove from serial cache
       --
       g_current_drop_lpn.current_drop_list(l_transaction_temp_id)
         := 'SRL_DONE';

       ii := g_cur_pend_temp.FIRST;
       jj := g_cur_pend_temp.LAST;

       IF l_debug = 1 THEN
          print_debug
          ( 'ii = ' || to_char(ii) || ', jj = ' || to_char(jj)
          , l_api_name
          );
       END IF;

       l_temp_found := FALSE;
       l_temp_id    := g_cur_pend_temp(ii);

       WHILE ( (ii <= jj)
               AND
               (NOT l_temp_found)
             )
       LOOP
          IF l_temp_id = l_transaction_temp_id
          THEN
             l_temp_found := TRUE;
             EXIT;
          END IF;

          IF NOT l_temp_found THEN
             IF ii < jj THEN
                ii := g_cur_pend_temp.NEXT(ii);
                l_temp_id := g_cur_pend_temp(ii);
             ELSE
                EXIT;
             END IF;
          END IF;
       END LOOP;

       IF NOT l_temp_found
       THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'Cannot find temp ID ' || to_char(l_transaction_temp_id) ||
               ' in g_cur_pend_temp'
             , l_api_name
             );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSE
          IF l_debug = 1 THEN
             print_debug
             ( 'Found temp ID ' || g_cur_pend_temp(ii)
               || ' in g_cur_pend_temp, which matches '
               || to_char(l_transaction_temp_id)
               || '.  Deleting...'
             , l_api_name
             );
          END IF;
          g_cur_pend_temp.DELETE(ii);
       END IF;
    END IF; -- end if MMTT qty matches serial count

    IF ( (p_lpn IS NULL)
         AND
         (p_lot_number IS NULL)
       )
    THEN
       BEGIN
          SELECT 'x'
            INTO l_dummy
            FROM dual
           WHERE EXISTS
               ( SELECT 'x'
                   FROM mtl_material_transactions_temp  mmtt
                  WHERE mmtt.organization_id = g_current_drop_lpn.organization_id
                    AND mmtt.transfer_lpn_id = g_current_drop_lpn.lpn_id
                    AND mmtt.parent_line_id  = mmtt.transaction_temp_id
                    AND mmtt.transaction_quantity > 0
                    AND mmtt.inventory_item_id    = p_item_id
                    AND NVL(mmtt.revision,'@@@@') = NVL(p_revision,'@@@@')
                    AND ( mmtt.content_lpn_id IS NULL
                          OR
                          mmtt.content_lpn_id  = mmtt.transfer_lpn_id
                        )
               );
          l_loose_qty_exists := 'Y';
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               l_loose_qty_exists := 'N';
       END;

       x_loose_qty_exists := l_loose_qty_exists;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK to process_serial_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK to process_serial_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END process_serial;



  PROCEDURE cancel_task
  ( x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  ) IS

    l_api_name             VARCHAR2(30) := 'cancel_task';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_api_return_status    VARCHAR2(1);

    CURSOR c_get_temp_ids
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT mmtt.transaction_temp_id
           , wdt.suggested_dest_subinventory
           , wdt.suggested_dest_locator_id
        FROM ( SELECT mmtt2.transaction_temp_id
                 FROM mtl_material_transactions_temp  mmtt2
                WHERE mmtt2.organization_id = p_org_id
                  AND mmtt2.transfer_lpn_id = p_lpn_id
                  AND mmtt2.parent_line_id IS NULL
                UNION
               SELECT mmtt3.transaction_temp_id
                 FROM mtl_material_transactions_temp  mmtt3
                WHERE mmtt3.parent_line_id IS NOT NULL
                  AND mmtt3.transaction_temp_id <> mmtt3.parent_line_id
                  AND mmtt3.transaction_temp_id IN
                    ( SELECT mmtt4.transaction_temp_id
                        FROM mtl_material_transactions_temp  mmtt4
                       WHERE mmtt4.organization_id = p_org_id
                         AND mmtt4.transfer_lpn_id = p_lpn_id
                       START WITH
                             mmtt4.transaction_temp_id = mmtt4.parent_line_id
                     CONNECT BY
                           ( mmtt4.parent_line_id = PRIOR mmtt4.transaction_temp_id
                             AND
                             mmtt4.parent_line_id <> mmtt4.transaction_temp_id
                           )
                    )
             ) mmtt
           , wms_dispatched_tasks  wdt
       WHERE wdt.transaction_temp_id = mmtt.transaction_temp_id
         AND wdt.suggested_dest_subinventory IS NOT NULL
         AND wdt.suggested_dest_locator_id   IS NOT NULL;

    TYPE TempIDTable  IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
    TYPE SubCodeTable IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE LocIDTable   IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;

    v_temp_id_tbl  TempIDTable;
    v_sub_tbl      SubCodeTable;
    v_loc_id_tbl   LocIDTable;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id)
       , l_api_name
       );
    END IF;

    fnd_msg_pub.initialize;

    --
    -- Validate passed in Org and LPN
    --
    IF p_organization_id <> g_current_drop_lpn.organization_id
       OR
       p_transfer_lpn_id <> g_current_drop_lpn.lpn_id
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Passed in org or LPN did not match cached info: '
            || g_newline || 'p_organization_id: ' || to_char(p_organization_id)
            || g_newline || 'p_transfer_lpn_id: ' || to_char(p_transfer_lpn_id)
            || g_newline || 'Cached Org ID:     ' || to_char(g_current_drop_lpn.organization_id)
            || g_newline || 'Cached LPN ID:     ' || to_char(g_current_drop_lpn.lpn_id)
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ROLLBACK;

    SAVEPOINT cancel_tsk_sp;

    --
    -- Bug 4884372: Restore original destination sub/loc to MMTT
    --              and null out suggested sub/loc on WDT
    --
    OPEN c_get_temp_ids (p_organization_id, p_transfer_lpn_id);
    FETCH c_get_temp_ids BULK COLLECT INTO v_temp_id_tbl, v_sub_tbl, v_loc_id_tbl;
    CLOSE c_get_temp_ids;

    FORALL ii IN v_temp_id_tbl.FIRST..v_temp_id_tbl.LAST
      UPDATE mtl_material_transactions_temp
         SET transfer_subinventory = v_sub_tbl(ii)
           , transfer_to_location  = v_loc_id_tbl(ii)
       WHERE transaction_temp_id = v_temp_id_tbl(ii);

    IF l_debug = 1 THEN
       print_debug('Updated dest sub, dest loc on MMTTs', l_api_name);
    END IF;

    FORALL jj IN v_temp_id_tbl.FIRST..v_temp_id_tbl.LAST
      UPDATE wms_dispatched_tasks
         SET suggested_dest_subinventory = NULL
           , suggested_dest_locator_id   = NULL
       WHERE transaction_temp_id = v_temp_id_tbl(jj);

    IF l_debug = 1 THEN
       print_debug('Updated suggested dest sub/loc on WDTs to NULL', l_api_name);
    END IF;

    -- Bug 4884284: Delete child WDT records
    DELETE wms_dispatched_tasks
     WHERE transaction_temp_id IN
         ( SELECT transaction_temp_id
             FROM mtl_material_transactions_temp  mmtt
            WHERE mmtt.parent_line_id IS NOT NULL
              AND mmtt.transaction_temp_id <> NVL(mmtt.parent_line_id,0)
              AND mmtt.transaction_temp_id IN
                ( SELECT mmtt2.transaction_temp_id
                    FROM mtl_material_transactions_temp  mmtt2
                   WHERE mmtt2.organization_id = p_organization_id
                     AND mmtt2.transfer_lpn_id = p_transfer_lpn_id
                   START WITH
                         mmtt2.transaction_temp_id = mmtt2.parent_line_id
                 CONNECT BY
                       ( mmtt2.parent_line_id = PRIOR mmtt2.transaction_temp_id
                         AND
                         mmtt2.parent_line_id <> mmtt2.transaction_temp_id
                       )
                )
         );

    IF l_debug = 1 THEN
       print_debug ('No. of child WDT records deleted: ' || SQL%ROWCOUNT, l_api_name);
    END IF;

    l_api_return_status := fnd_api.g_ret_sts_success;
    clear_lpn_cache(l_api_return_status);

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug ('Error from clear_lpn_cache', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Start change for Bug 5620764
    -- Restore LPN context for bulk picked content LPNs back to "Packing Content" from "In Inventory"
    -- Bug5659809: update last_update_date and last_update_by as well
    UPDATE wms_license_plate_numbers  wlpn1
       SET wlpn1.lpn_context = WMS_Container_PUB.LPN_CONTEXT_PACKING
         , last_update_date = SYSDATE
         , last_updated_by = fnd_global.user_id
     WHERE wlpn1.lpn_id IN
         ( SELECT mmtt.content_lpn_id
             FROM mtl_material_transactions_temp  mmtt
                , wms_license_plate_numbers       wlpn2
            WHERE mmtt.transfer_lpn_id = p_transfer_lpn_id
              AND mmtt.organization_id = p_organization_id
              AND mmtt.parent_line_id  = mmtt.transaction_temp_id
              AND mmtt.content_lpn_id  = wlpn2.lpn_id
              AND mmtt.organization_id = wlpn2.organization_id
              AND wlpn2.lpn_context    = WMS_Container_PUB.LPN_CONTEXT_INV
         );

    IF l_debug = 1 AND SQL%FOUND THEN
       print_debug ('Restored LPN context of bulk-picked content LPN', l_api_name);
    END IF;
		-- End change for Bug 5620764

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO cancel_tsk_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END cancel_task;



  PROCEDURE validate_xfer_to_lpn
  ( x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  , p_group_number     IN          NUMBER
  , p_outer_lpn_done   IN          VARCHAR2
  , p_xfer_to_lpn      IN          VARCHAR2
  , p_dest_sub         IN          VARCHAR2
  , p_dest_loc_id      IN          NUMBER
  , p_delivery_id      IN          NUMBER
  ) IS

    l_api_name             VARCHAR2(30) := 'validate_xfer_to_lpn';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_api_return_status    VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    l_lpn_id               NUMBER := NULL;
    l_lpn_delivery_id      NUMBER;
    l_process_id           NUMBER;
    l_primary_qty          NUMBER;

    l_lpn_carton_grp_id    NUMBER;
    l_cur_carton_grp_id    NUMBER;
    l_transaction_temp_id  NUMBER;

    ii                     NUMBER;
    jj                     NUMBER;

    l_temp_tbl             g_temp_id_tbl;

    l_allow_packing        NUMBER;

    CURSOR c_lpn_info
    ( p_lpn     IN  VARCHAR2
    , p_org_id  IN  NUMBER
    ) IS
      SELECT lpn_id
           , lpn_context
           , subinventory_code
           , locator_id
        FROM wms_license_plate_numbers
       WHERE organization_id      = p_org_id
         AND license_plate_number = p_lpn;

    to_lpn_rec  c_lpn_info%ROWTYPE;


    CURSOR c_get_lpn_delivery
    ( p_lpn_id  IN  NUMBER
    , p_org_id  IN  NUMBER
    ) IS
      SELECT wda.delivery_id
        FROM wsh_delivery_details_ob_grp_v      wdd
           , wsh_delivery_assignments_v  wda
       WHERE wdd.lpn_id             = p_lpn_id
         AND wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
         AND wdd.organization_id    = p_org_id
         AND wdd.delivery_detail_id = wda.parent_delivery_detail_id;


    CURSOR c_get_mmtt_lpn_info
    ( p_lpn_id  IN  NUMBER
    , p_org_id  IN  NUMBER
    ) IS
      SELECT mmtt.transfer_subinventory
           , mmtt.transfer_to_location
           , mtrl.carton_grouping_id
           , wda.delivery_id
        FROM mtl_material_transactions_temp  mmtt
           , mtl_txn_request_lines           mtrl
           , wsh_delivery_details_ob_grp_v            wdd
           , wsh_delivery_assignments_v        wda
       WHERE mmtt.organization_id    = p_org_id
         AND mmtt.transfer_lpn_id    = p_lpn_id
         AND mmtt.move_order_line_id = mtrl.line_id
         AND mtrl.line_id            = wdd.move_order_line_id (+)
         AND wdd.delivery_detail_id  = wda.delivery_detail_id (+);

    mmtt_lpn_rec  c_get_mmtt_lpn_info%ROWTYPE;


    CURSOR c_get_lpn_carton_grp
    ( p_lpn_id  IN  NUMBER
    , p_org_id  IN  NUMBER
    ) IS
      SELECT mtrl.carton_grouping_id
        FROM wsh_delivery_details_ob_grp_v      wdd
           , wsh_delivery_assignments_v  wda
           , wsh_delivery_details_ob_grp_v      wdd2
           , mtl_txn_request_lines     mtrl
       WHERE wdd.lpn_id              = p_lpn_id
         AND wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
         AND wdd.organization_id     = p_org_id
         AND wdd.delivery_detail_id  = wda.parent_delivery_detail_id
         AND wda.delivery_detail_id  = wdd2.delivery_detail_id
         AND wdd2.move_order_line_id = mtrl.line_id;


    CURSOR c_get_cur_carton_grp
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mtrl.carton_grouping_id
        FROM mtl_material_transactions_temp  mmtt
           , mtl_txn_request_lines           mtrl
       WHERE mmtt.transaction_temp_id = p_temp_id
         AND mmtt.move_order_line_id  = mtrl.line_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id) || g_newline ||
         'p_group_number    => '     || to_char(p_group_number)    || g_newline ||
         'p_outer_lpn_done  => '     || p_outer_lpn_done           || g_newline ||
         'p_xfer_to_lpn     => '     || p_xfer_to_lpn              || g_newline ||
         'p_dest_sub        => '     || p_dest_sub                 || g_newline ||
         'p_dest_loc_id     => '     || to_char(p_dest_loc_id)     || g_newline ||
         'p_delivery_id     => '     || to_char(p_delivery_id)
       , l_api_name
       );
    END IF;

    fnd_msg_pub.initialize;

    SAVEPOINT validate_xfer_sp;

    --
    -- Validate passed in Org and LPN
    --
    IF p_organization_id <> g_current_drop_lpn.organization_id
       OR
       p_transfer_lpn_id <> g_current_drop_lpn.lpn_id
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Passed in org or LPN did not match cached info: '
            || g_newline || 'p_organization_id: ' || to_char(p_organization_id)
            || g_newline || 'p_transfer_lpn_id: ' || to_char(p_transfer_lpn_id)
            || g_newline || 'Cached Org ID:     ' || to_char(g_current_drop_lpn.organization_id)
            || g_newline || 'Cached LPN ID:     ' || to_char(g_current_drop_lpn.lpn_id)
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Check if new
    --
    OPEN c_lpn_info (p_xfer_to_lpn, p_organization_id);
    FETCH c_lpn_info into to_lpn_rec;

    IF c_lpn_info%NOTFOUND
    THEN
       IF (l_debug = 1) THEN
          print_debug ('Xfer LPN is new.', l_api_name);
       END IF;

       l_api_return_status := fnd_api.g_ret_sts_success;
       wms_container_pub.create_lpn
       ( p_api_version     => 1.0
       , x_return_status   => l_api_return_status
       , x_msg_count       => l_msg_count
       , x_msg_data        => l_msg_data
       , p_lpn             => p_xfer_to_lpn
       , p_organization_id => p_organization_id
       , x_lpn_id          => l_lpn_id
       , p_source          => wms_container_pub.lpn_context_pregenerated
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'Error from WMS_Container_PUB.create_lpn: ' || l_msg_data
             , l_api_name);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       ELSE
          IF l_debug = 1 THEN
             print_debug
             ( 'WMS_Container_PUB.create_lpn returned LPN '
               || to_char(l_lpn_id)
             , l_api_name);
          END IF;
       END IF;

    --
    -- Check if pre-generated
    --
    ELSIF to_lpn_rec.lpn_context = wms_container_pub.lpn_context_pregenerated
    THEN
       IF (l_debug = 1) THEN
          print_debug ('Xfer LPN is pre-generated.', l_api_name);
       END IF;

    ELSIF to_lpn_rec.lpn_id = p_transfer_lpn_id
       AND
       p_outer_lpn_done <> 'TRUE'
    THEN
       IF (l_debug = 1) THEN
          print_debug ('LPN is outermost LPN, but not done', l_api_name);
       END IF;

       fnd_message.set_name('WMS', 'WMS_LPN_HAS_MORE_DROP_MTL');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;

    ELSIF to_lpn_rec.lpn_context <> wms_container_pub.lpn_context_picked
    THEN
       IF (l_debug = 1) THEN
          print_debug
          ( 'LPN has an invalid context: '
            || to_char(to_lpn_rec.lpn_context)
          , l_api_name
          );
       END IF;

       fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN_CONTEXT');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;

    ELSE
       --
       -- Check if staged in another sub/loc
       -- or for a different delivery
       --
       IF to_lpn_rec.subinventory_code <> p_dest_sub
          OR
          to_lpn_rec.locator_id <> p_dest_loc_id
       THEN
          IF (l_debug = 1) THEN
             print_debug
             ( 'Scanned LPN resides in a diff sub/loc: '
               || to_lpn_rec.subinventory_code || '/'
               || to_char(to_lpn_rec.locator_id)
             , l_api_name
             );
          END IF;

          fnd_message.set_name('WMS', 'WMS_XFER_LPN_DIFF_SUBINV');
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
       ELSE
          OPEN c_get_lpn_delivery (to_lpn_rec.lpn_id, p_organization_id);
          FETCH c_get_lpn_delivery INTO l_lpn_delivery_id;
          CLOSE c_get_lpn_delivery;

          IF NVL(p_delivery_id,0) <> NVL(l_lpn_delivery_id,0) THEN
             IF (l_debug = 1) THEN
                print_debug
                  ( 'LPN belongs to a diff delivery: '
                    || to_char(l_lpn_delivery_id)
                    , l_api_name
                    );
             END IF;

             fnd_message.set_name('WMS', 'WMS_DROP_LPN_DIFF_DELIV');
             fnd_msg_pub.ADD;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF NVL(p_delivery_id,0) = 0 AND NVL(l_lpn_delivery_id,0) = 0 THEN
             OPEN c_get_lpn_carton_grp (to_lpn_rec.lpn_id, p_organization_id);
             FETCH c_get_lpn_carton_grp INTO l_lpn_carton_grp_id;
             CLOSE c_get_lpn_carton_grp;

             IF (l_debug = 1) THEN
                print_debug
                ( 'LPN carton group ID: '
                  || to_char(l_lpn_carton_grp_id)
                , l_api_name
                );
             END IF;

             l_transaction_temp_id := g_current_drop_lpn.current_drop_list.FIRST;
             OPEN c_get_cur_carton_grp (l_transaction_temp_id);
             FETCH c_get_cur_carton_grp INTO l_cur_carton_grp_id;
             CLOSE c_get_cur_carton_grp;

             IF (l_debug = 1) THEN
                print_debug
                ( 'Current carton group ID: '
                  || to_char(l_cur_carton_grp_id)
                , l_api_name
                );
             END IF;

             IF NVL(l_lpn_carton_grp_id,0) <> NVL(l_cur_carton_grp_id,0)
             THEN
                IF (l_debug = 1) THEN
                   print_debug
                   ( 'LPN has a diff carton grouping ID'
                   , l_api_name
                   );
                END IF;

                fnd_message.set_name('WMS', 'WMS_INVALID_PACK_DELIVERY');
                fnd_msg_pub.ADD;
                RAISE FND_API.G_EXC_ERROR;
             END IF;

          END IF;
       END IF;
    END IF;

    IF c_lpn_info%ISOPEN
    THEN
       CLOSE c_lpn_info;
    END IF;

	--Start: Added for  bug 10139672
    IF NVL(l_lpn_id,0) = 0
	  THEN
	  g_xfer_to_lpn_id := to_lpn_rec.lpn_id;
	  ELSE
	  g_xfer_to_lpn_id := l_lpn_id;
	  END IF;

	  IF (l_debug = 1) THEN
                   print_debug
                   ( 'Xfer To LPN ID g_xfer_to_lpn_id:'|| to_char(g_xfer_to_lpn_id)
                   , l_api_name
                   );
    END IF;
    --END: Added for  bug 10139672

    --
    -- Update MMTT records that are PENDING
    --
    l_api_return_status := fnd_api.g_ret_sts_success;
    get_temp_list
    ( x_temp_tbl      => l_temp_tbl
    , x_return_status => l_api_return_status
    , p_group_num     => p_group_number
    , p_status        => 'PENDING'
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug ('Error from get_temp_list', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_temp_tbl.COUNT > 0 THEN
       ii := l_temp_tbl.FIRST;
       jj := l_temp_tbl.LAST;

       l_transaction_temp_id := l_temp_tbl(ii);

       IF l_debug = 1 THEN
          print_debug
          ( 'Processing PENDING records: ii = ' || to_char(ii)
            || ', jj = '            || to_char(jj)
            || ', temp ID = '       || to_char(l_transaction_temp_id)
            || ', l_lpn_id = '      || to_char(l_lpn_id)
            || ', ID in LPN rec = ' || to_char(to_lpn_rec.lpn_id)
          , l_api_name
          );
       END IF;

       WHILE (ii <= jj)
       LOOP
          UPDATE mtl_material_transactions_temp  mmtt
             SET mmtt.transfer_lpn_id = NVL(l_lpn_id,to_lpn_rec.lpn_id)
           WHERE mmtt.transaction_temp_id = l_transaction_temp_id
                 RETURNING primary_quantity
                      INTO l_primary_qty;

          IF l_primary_qty > 0
          THEN
             g_current_drop_lpn.current_drop_list(l_transaction_temp_id)
               := 'DONE';
          ELSE
             DELETE mtl_material_transactions_temp
              WHERE transaction_temp_id = l_transaction_temp_id;

             g_current_drop_lpn.current_drop_list.DELETE(l_transaction_temp_id);

             IF l_debug = 1 THEN
                print_debug
                ( 'Deleted temp ID: ' || to_char(l_transaction_temp_id)
                , l_api_name
                );
             END IF;
          END IF;

          IF ii < jj THEN
             ii := l_temp_tbl.NEXT(ii);
             l_transaction_temp_id := l_temp_tbl(ii);
          ELSE
             EXIT;
          END IF;

          IF l_debug = 1 THEN
             print_debug
             ( 'Fetched next temp ID: ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;
       END LOOP;

    END IF; -- end if l_temp_tbl.COUNT > 0

    l_temp_tbl.DELETE;

    --
    -- Update MMTT records for which serials have been processed
    --
    l_api_return_status := fnd_api.g_ret_sts_success;
    get_temp_list
    ( x_temp_tbl      => l_temp_tbl
    , x_return_status => l_api_return_status
    , p_group_num     => p_group_number
    , p_status        => 'SRL_DONE'
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug ('Error from get_temp_list', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_temp_tbl.COUNT > 0 THEN
       ii := l_temp_tbl.FIRST;
       jj := l_temp_tbl.LAST;

       l_transaction_temp_id := l_temp_tbl(ii);

       IF l_debug = 1 THEN
          print_debug
          ( 'Processing records in SRL_DONE status: ii = ' || to_char(ii)
            || ', jj = '            || to_char(jj)
            || ', temp ID = '       || to_char(l_transaction_temp_id)
            || ', l_lpn_id = '      || to_char(l_lpn_id)
            || ', ID in LPN rec = ' || to_char(to_lpn_rec.lpn_id)
          , l_api_name
          );
       END IF;

       WHILE (ii <= jj)
       LOOP
          UPDATE mtl_material_transactions_temp  mmtt
             SET mmtt.transfer_lpn_id = NVL(l_lpn_id,to_lpn_rec.lpn_id)
           WHERE mmtt.transaction_temp_id = l_transaction_temp_id
                 RETURNING primary_quantity
                      INTO l_primary_qty;

          IF l_primary_qty > 0
          THEN
             g_current_drop_lpn.current_drop_list(l_transaction_temp_id)
               := 'DONE';
          ELSE
             DELETE mtl_material_transactions_temp
              WHERE transaction_temp_id = l_transaction_temp_id;

             g_current_drop_lpn.current_drop_list.DELETE(l_transaction_temp_id);

             IF l_debug = 1 THEN
                print_debug
                ( 'Deleted temp ID: ' || to_char(l_transaction_temp_id)
                , l_api_name
                );
             END IF;
          END IF;

          IF ii < jj THEN
             ii := l_temp_tbl.NEXT(ii);
             l_transaction_temp_id := l_temp_tbl(ii);
          ELSE
             EXIT;
          END IF;

          IF l_debug = 1 THEN
             print_debug
             ( 'Fetched next temp ID: ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;
       END LOOP;

    END IF; -- end if l_temp_tbl.COUNT > 0

    l_temp_tbl.DELETE;

    --
    -- Update MMTT records for which from LPN has been stamped
    --
    l_api_return_status := fnd_api.g_ret_sts_success;
    get_temp_list
    ( x_temp_tbl      => l_temp_tbl
    , x_return_status => l_api_return_status
    , p_group_num     => p_group_number
    , p_status        => 'LPN_DONE'
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug ('Error from get_temp_list', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_temp_tbl.COUNT > 0 THEN
       ii := l_temp_tbl.FIRST;
       jj := l_temp_tbl.LAST;

       l_transaction_temp_id := l_temp_tbl(ii);

       IF l_debug = 1 THEN
          print_debug
          ( 'Processing records in LPN_DONE status: ii = ' || to_char(ii)
            || ', jj = '            || to_char(jj)
            || ', temp ID = '       || to_char(l_transaction_temp_id)
            || ', l_lpn_id = '      || to_char(l_lpn_id)
            || ', ID in LPN rec = ' || to_char(to_lpn_rec.lpn_id)
          , l_api_name
          );
       END IF;

       WHILE (ii <= jj)
       LOOP
          UPDATE mtl_material_transactions_temp  mmtt
             SET mmtt.transfer_lpn_id = NVL(l_lpn_id,to_lpn_rec.lpn_id)
           WHERE mmtt.transaction_temp_id = l_transaction_temp_id
                 RETURNING primary_quantity
                      INTO l_primary_qty;

          IF l_primary_qty > 0
          THEN
             g_current_drop_lpn.current_drop_list(l_transaction_temp_id)
               := 'DONE';
          ELSE
             DELETE mtl_material_transactions_temp
              WHERE transaction_temp_id = l_transaction_temp_id;

             g_current_drop_lpn.current_drop_list.DELETE(l_transaction_temp_id);

             IF l_debug = 1 THEN
                print_debug
                ( 'Deleted temp ID: ' || to_char(l_transaction_temp_id)
                , l_api_name
                );
             END IF;
          END IF;

          IF ii < jj THEN
             ii := l_temp_tbl.NEXT(ii);
             l_transaction_temp_id := l_temp_tbl(ii);
          ELSE
             EXIT;
          END IF;

          IF l_debug = 1 THEN
             print_debug
             ( 'Fetched next temp ID: ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;
       END LOOP;

    END IF; -- end if l_temp_tbl.COUNT > 0

    l_temp_tbl.DELETE;

    --
    -- Update MMTT records for which from loose qty
    -- has been processed
    --
    l_api_return_status := fnd_api.g_ret_sts_success;
    get_temp_list
    ( x_temp_tbl      => l_temp_tbl
    , x_return_status => l_api_return_status
    , p_group_num     => p_group_number
    , p_status        => 'LSE_DONE'
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success
    THEN
       IF l_debug = 1 THEN
          print_debug ('Error from get_temp_list', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_temp_tbl.COUNT > 0 THEN
       ii := l_temp_tbl.FIRST;
       jj := l_temp_tbl.LAST;

       l_transaction_temp_id := l_temp_tbl(ii);

       IF l_debug = 1 THEN
          print_debug
          ( 'Processing records in LSE_DONE status: ii = ' || to_char(ii)
            || ', jj = '            || to_char(jj)
            || ', temp ID = '       || to_char(l_transaction_temp_id)
            || ', l_lpn_id = '      || to_char(l_lpn_id)
            || ', ID in LPN rec = ' || to_char(to_lpn_rec.lpn_id)
          , l_api_name
          );
       END IF;

       WHILE (ii <= jj)
       LOOP
          UPDATE mtl_material_transactions_temp  mmtt
             SET mmtt.transfer_lpn_id = NVL(l_lpn_id,to_lpn_rec.lpn_id)
           WHERE mmtt.transaction_temp_id = l_transaction_temp_id
                 RETURNING primary_quantity
                      INTO l_primary_qty;

          IF l_primary_qty > 0
          THEN
             g_current_drop_lpn.current_drop_list(l_transaction_temp_id)
               := 'DONE';
          ELSE
             DELETE mtl_material_transactions_temp
              WHERE transaction_temp_id = l_transaction_temp_id;

             g_current_drop_lpn.current_drop_list.DELETE(l_transaction_temp_id);

             IF l_debug = 1 THEN
                print_debug
                ( 'Deleted temp ID: ' || to_char(l_transaction_temp_id)
                , l_api_name
                );
             END IF;
          END IF;

          IF ii < jj THEN
             ii := l_temp_tbl.NEXT(ii);
             l_transaction_temp_id := l_temp_tbl(ii);
          ELSE
             EXIT;
          END IF;

          IF l_debug = 1 THEN
             print_debug
             ( 'Fetched next temp ID: ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;
       END LOOP;

    END IF; -- end if l_temp_tbl.COUNT > 0

    l_temp_tbl.DELETE;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK to validate_xfer_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK to validate_xfer_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END validate_xfer_to_lpn;



  PROCEDURE insert_mmtt_pack
  ( x_pack_temp_id     OUT NOCOPY  NUMBER
  , x_return_status    OUT NOCOPY  VARCHAR2
  , p_parent_temp_id   IN          NUMBER
  , p_lpn_id           IN          NUMBER
  , p_outer_lpn_id     IN          NUMBER
  ) IS

    l_api_name             VARCHAR2(30) := 'insert_mmtt_pack';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    l_child_temp_id        NUMBER;
    l_pack_temp_id         NUMBER;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_parent_temp_id => '      || to_char(p_parent_temp_id)  || g_newline ||
         'p_lpn_id         => '      || to_char(p_lpn_id)          || g_newline ||
         'p_outer_lpn_id   => '      || to_char(p_outer_lpn_id)
       , l_api_name
       );
    END IF;

    SAVEPOINT insert_pack_sp;

    BEGIN
       SELECT mmtt.transaction_temp_id
         INTO l_child_temp_id
         FROM mtl_material_transactions_temp  mmtt
        WHERE mmtt.parent_line_id  = p_parent_temp_id
          AND mmtt.parent_line_id <> mmtt.transaction_temp_id
          AND ROWNUM < 2;

       IF l_debug = 1 THEN
          print_debug
          ( 'Found child temp ID: ' || to_char(l_child_temp_id)
          , l_api_name
          );
       END IF;

    EXCEPTION
       WHEN OTHERS THEN
          IF l_debug = 1 THEN
             print_debug
             ( 'Exception fetching child temp ID: ' || sqlerrm
             , l_api_name
             );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    SELECT mtl_material_transactions_s.NEXTVAL
      INTO l_pack_temp_id
      FROM DUAL;

    IF l_debug = 1 THEN
       print_debug
       ( 'About to insert pack txn with temp ID: '
         || to_char(l_pack_temp_id)
       , l_api_name
       );
    END IF;

    INSERT INTO mtl_material_transactions_temp
    ( transaction_header_id
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
          , l_pack_temp_id
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
          , INV_GLOBALS.G_TYPE_CONTAINER_PACK
          , INV_GLOBALS.G_ACTION_CONTAINERPACK
          , INV_GLOBALS.G_SOURCETYPE_INVENTORY
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
          , 3
          , transfer_cost_group_id
          , NULL
          , p_outer_lpn_id
          , p_lpn_id
          , operation_plan_id
          , transaction_header_id
          , l_pack_temp_id
       FROM mtl_material_transactions_temp
      WHERE transaction_temp_id = l_child_temp_id
    );

    x_pack_temp_id := l_pack_temp_id;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK to insert_pack_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK to insert_pack_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END insert_mmtt_pack;



  PROCEDURE preprocess_bulk_drop
  ( x_temp_tbl         OUT NOCOPY  g_temp_id_tbl
  , x_pack_txn_exists  OUT NOCOPY  BOOLEAN
  , x_return_status    OUT NOCOPY  VARCHAR2
  , p_orgn_id          IN          NUMBER
  , p_xfer_lpn_id      IN          NUMBER
  , p_drop_lpn         IN          VARCHAR2
  ) IS

    l_api_name             VARCHAR2(30) := 'preprocess_bulk_drop';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_api_return_status    VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    l_parent_temp_id       NUMBER;
    l_pack_temp_id         NUMBER;
    l_outer_most_lpn_id    NUMBER;
    ii                     NUMBER;

    l_pack_txn_ok          BOOLEAN;
    l_dummy                VARCHAR2(1);


    CURSOR c_get_bulk_tasks
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      -- Material unpacked from nested LPNs
      SELECT mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id  = p_org_id
         AND mmtt.transfer_lpn_id  = p_lpn_id
         AND mmtt.parent_line_id  IS NOT NULL
         AND mmtt.parent_line_id  <> mmtt.transaction_temp_id
         AND mmtt.content_lpn_id  IS NULL
         AND mmtt.lpn_id          IS NOT NULL
         AND EXISTS
           ( SELECT 'x'
               FROM mtl_material_transactions_temp  mmtt2
              WHERE mmtt2.organization_id      = p_org_id
                AND mmtt2.transfer_lpn_id      = p_lpn_id
                AND mmtt2.content_lpn_id       = mmtt.lpn_id
                AND mmtt2.transaction_temp_id  = mmtt2.parent_line_id
                AND mmtt2.parent_line_id      <> mmtt.parent_line_id
           )
       UNION ALL
      -- Nested LPNs
      SELECT mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id  = p_org_id
         AND mmtt.transfer_lpn_id  = p_lpn_id
         AND mmtt.parent_line_id  IS NOT NULL
         AND mmtt.parent_line_id  <> mmtt.transaction_temp_id
         AND mmtt.content_lpn_id  IS NULL
         AND mmtt.lpn_id          IS NOT NULL
         AND EXISTS
           ( SELECT 'x'
               FROM mtl_material_transactions_temp  mmtt2
              WHERE mmtt2.organization_id     = p_org_id
                AND mmtt2.transfer_lpn_id     = p_lpn_id
                AND mmtt2.content_lpn_id      = mmtt.lpn_id
                AND mmtt2.transaction_temp_id = mmtt2.parent_line_id
                AND mmtt2.parent_line_id      = mmtt.parent_line_id
           )
       UNION ALL
      -- Picked from LPN that is not a nested LPN
      SELECT mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id  = p_org_id
         AND mmtt.transfer_lpn_id  = p_lpn_id
         AND mmtt.parent_line_id  IS NOT NULL
         AND mmtt.parent_line_id  <> mmtt.transaction_temp_id
         AND mmtt.content_lpn_id  IS NULL
         AND mmtt.lpn_id          IS NOT NULL
         AND NOT EXISTS
           ( SELECT 'x'
               FROM mtl_material_transactions_temp  mmtt2
              WHERE mmtt2.organization_id      = p_org_id
                AND mmtt2.transfer_lpn_id      = p_lpn_id
                AND mmtt2.content_lpn_id       = mmtt.lpn_id
                AND mmtt2.transaction_temp_id  = mmtt2.parent_line_id
           )
       UNION ALL
      -- Loose material
      SELECT mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id  = p_org_id
         AND mmtt.transfer_lpn_id  = p_lpn_id
         AND mmtt.parent_line_id  IS NOT NULL
         AND mmtt.parent_line_id  <> mmtt.transaction_temp_id
         AND mmtt.content_lpn_id  IS NULL
         AND mmtt.lpn_id          IS NULL;


    CURSOR c_get_nested_lpns
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT mmtt.transaction_temp_id
           , mmtt.content_lpn_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id = p_org_id
         AND mmtt.transfer_lpn_id = p_lpn_id
         AND mmtt.parent_line_id  = mmtt.transaction_temp_id
         AND mmtt.content_lpn_id IS NOT NULL;


    CURSOR c_chk_child_records
    ( p_parent_temp_id  IN  NUMBER
    ) IS
      SELECT 'x'
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.parent_line_id  = p_parent_temp_id
         AND mmtt.parent_line_id <> mmtt.transaction_temp_id
         AND mmtt.transaction_action_id in (2,28)
         AND EXISTS
           ( SELECT 'x'
               FROM mtl_secondary_inventories  msi
              WHERE msi.secondary_inventory_name = mmtt.transfer_subinventory
                AND msi.organization_id          = mmtt.organization_id
                AND NVL(msi.disable_date,sysdate + 1)
                                                 > sysdate
                AND msi.lpn_controlled_flag      = 1
           );


  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline             ||
         'p_orgn_id     => '         || to_char(p_orgn_id)    || g_newline ||
         'p_xfer_lpn_id => '         || to_char(p_xfer_lpn_id)
       , l_api_name
       );
    END IF;

    x_pack_txn_exists := FALSE;

    SAVEPOINT preprocess_bulk_sp;

    OPEN c_get_bulk_tasks (p_orgn_id, p_xfer_lpn_id);
    FETCH c_get_bulk_tasks BULK COLLECT INTO x_temp_tbl;
    CLOSE c_get_bulk_tasks;

    IF NOT (x_temp_tbl.COUNT > 0)
    THEN
       IF l_debug = 1 THEN
          print_debug ('c_get_bulk_tasks returned no MMTT records', l_api_name);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Process nested LPNs:
    --   Update transfer_lpn_id on child records
    --   Update LPN context
    --   Insert pack transactions
    --   Add pack transaction to x_temp_tbl
    --
    FOR nested_lpn_rec IN c_get_nested_lpns (p_orgn_id, p_xfer_lpn_id)
    LOOP
       l_pack_txn_ok := FALSE;
       BEGIN
          IF l_debug = 1
          THEN
             print_debug
             ('Processing parent temp ID: '
              || to_char(nested_lpn_rec.transaction_temp_id)
              || ', with content LPN ID: '
              || to_char(nested_lpn_rec.content_lpn_id)
             , l_api_name
             );
          END IF;

          -- Start change for Bug 5620764
          -- This is not required, since entire LPN is being consumed
          --UPDATE wms_license_plate_numbers  wlpn
          --   SET wlpn.lpn_context = WMS_Container_PUB.LPN_CONTEXT_INV
          -- WHERE wlpn.lpn_id      = nested_lpn_rec.content_lpn_id
          --   AND wlpn.lpn_context = WMS_Container_PUB.LPN_CONTEXT_PACKING
          --   AND wlpn.organization_id = p_orgn_id;

          --IF l_debug = 1 AND SQL%FOUND
          --THEN
          --   print_debug
          --   ('Updated LPN context from packing to INV for LPN ID '
          --    || to_char(nested_lpn_rec.content_lpn_id)
          --   , l_api_name
          --   );
          --END IF;
					-- End change for Bug 5620764

          OPEN c_chk_child_records (nested_lpn_rec.transaction_temp_id);
          FETCH c_chk_child_records INTO l_dummy;

          IF c_chk_child_records%FOUND
          THEN
             l_pack_txn_ok := TRUE;
          END IF;

          CLOSE c_chk_child_records;

          IF nested_lpn_rec.content_lpn_id <> p_xfer_lpn_id
          THEN
             UPDATE mtl_material_transactions_temp  mmtt
                SET mmtt.transfer_lpn_id = nested_lpn_rec.content_lpn_id
                	, mmtt.lpn_id          = NVL(mmtt.lpn_id,nested_lpn_rec.content_lpn_id) -- Bug 5620764
              WHERE mmtt.parent_line_id  = nested_lpn_rec.transaction_temp_id
                AND mmtt.parent_line_id <> mmtt.transaction_temp_id;

             IF l_debug = 1 AND SQL%FOUND
             THEN
                print_debug
                ('Updated transfer LPN on child records for parent '
                 || to_char(nested_lpn_rec.transaction_temp_id)
                , l_api_name
                );
             END IF;

             IF l_pack_txn_ok
                THEN
                l_api_return_status := fnd_api.g_ret_sts_success;
                insert_mmtt_pack
                ( x_pack_temp_id   => l_pack_temp_id
                , x_return_status  => l_api_return_status
                , p_parent_temp_id => nested_lpn_rec.transaction_temp_id
                , p_lpn_id         => nested_lpn_rec.content_lpn_id
                , p_outer_lpn_id   => p_xfer_lpn_id
                );

                IF l_api_return_status <> fnd_api.g_ret_sts_success
                THEN
                   IF l_debug = 1 THEN
                      print_debug ('insert_mmtt_pack returned an error', l_api_name);
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                ii := x_temp_tbl.LAST + 1;
                x_temp_tbl(ii) := l_pack_temp_id;

                IF l_debug = 1
                THEN
                   print_debug
                   ('Added packing txn temp ID ' || to_char(l_pack_temp_id) ||
                    ' to x_temp_tbl at index '   || to_char(ii)
                   , l_api_name
                   );
                END IF;

                IF NOT x_pack_txn_exists
                THEN
                   x_pack_txn_exists := TRUE;
                   l_parent_temp_id  := nested_lpn_rec.transaction_temp_id;
                END IF;
             END IF; -- end if l_pack_txn_ok
          END IF; -- end if content_lpn_id <> p_xfer_lpn_id

       EXCEPTION
          WHEN OTHERS THEN
            IF l_debug = 1 THEN
               print_debug
               ( 'Exception processing nested LPNs: ' || sqlerrm
               , l_api_name
               );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       END;
    END LOOP;

    IF x_pack_txn_exists
       AND
       p_drop_lpn IS NOT NULL
    THEN
       BEGIN
          SELECT wlpn.lpn_id
            INTO l_outer_most_lpn_id
            FROM wms_license_plate_numbers  wlpn
           WHERE wlpn.license_plate_number = p_drop_lpn;

          IF l_debug = 1
          THEN
             print_debug
             ('Drop LPN ' || p_drop_lpn ||
              ' has ID '  || to_char(l_outer_most_lpn_id)
             , l_api_name
             );
          END IF;

       EXCEPTION
          WHEN OTHERS THEN
            IF l_debug = 1 THEN
               print_debug
               ( 'Exception getting outermost LPN ID: ' || sqlerrm
               , l_api_name
               );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;

       l_api_return_status := fnd_api.g_ret_sts_success;
       insert_mmtt_pack
       ( x_pack_temp_id   => l_pack_temp_id
       , x_return_status  => l_api_return_status
       , p_parent_temp_id => l_parent_temp_id
       , p_lpn_id         => p_xfer_lpn_id
       , p_outer_lpn_id   => l_outer_most_lpn_id
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug ('insert_mmtt_pack returned an error', l_api_name);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       ii := x_temp_tbl.LAST + 1;
       x_temp_tbl(ii) := l_pack_temp_id;

       IF l_debug = 1
       THEN
          print_debug
          ('Added packing txn temp ID ' || to_char(l_pack_temp_id) ||
           ' to x_temp_tbl at index '   || to_char(ii)
          , l_api_name
          );
       END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO preprocess_bulk_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO preprocess_bulk_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END preprocess_bulk_drop;



  PROCEDURE pick_drop
  ( x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  , p_emp_id           IN          NUMBER
  , p_drop_lpn         IN          VARCHAR2
  , p_orig_subinv      IN          VARCHAR2
  , p_subinventory     IN          VARCHAR2
  , p_orig_locid       IN          VARCHAR2
  , p_loc_id           IN          NUMBER
  , p_reason_id        IN          NUMBER
  , p_task_type        IN          NUMBER
  , p_outer_lpn_done   IN          VARCHAR2
  , p_bulk_drop        IN          VARCHAR2
  ) IS

    l_api_name             VARCHAR2(30) := 'pick_drop';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_api_return_status    VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_ok_to_process        VARCHAR2(10) := NULL;
    l_dummy                VARCHAR2(1)  := NULL;
    l_srl_stat             VARCHAR2(1)  := NULL;

    l_temp_tbl             g_temp_id_tbl;
    l_task_tbl             g_temp_id_tbl;

    l_txn_header_id        NUMBER;
    l_transaction_temp_id  NUMBER;
    l_first_temp_id        NUMBER;
    l_task_id              NUMBER;
    l_parent_line_id       NUMBER;
    l_txn_type_id          NUMBER;
    l_parent_task_id       NUMBER;
    l_parent_txn_id        NUMBER;
    l_curr_xfer_lpn_id     NUMBER;
    l_next_xfer_lpn_id     NUMBER;
    l_batch_seq_id         NUMBER;

    l_inventory_item_id    NUMBER;
    l_transaction_qty      NUMBER;
    l_transaction_uom      VARCHAR2(3);

    ii                     NUMBER;
    jj                     NUMBER;
    kk                     NUMBER;

    l_parent_done          BOOLEAN;
    l_curr_lpn_done        BOOLEAN;
    l_xfer_lpn_used        BOOLEAN;
    l_pack_txn_exists      BOOLEAN;


    -- MDC variables
    l_allow_packing       VARCHAR2(1);
    l_to_loc_type         NUMBER;
    l_drop_lpn_id         NUMBER;
    l_move_order_type     NUMBER;
    l_move_order_line_id  NUMBER;
    l_line_status         NUMBER;
	l_xfer_to_lpn_id      NUMBER; --added for bug 10139672

    CURSOR c_get_nonbulk_tasks   -- Modified for bug#9247514
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
    SELECT mmtt.transaction_temp_id  --bug#6323330. Added org,item,revision,sub,loc in SELECT clause.
    FROM (
      -- Material unpacked from nested LPNs
      SELECT mmtt.transaction_temp_id,
             mmtt.organization_id,
	     mmtt.inventory_item_id,
	     mmtt.revision ,
	     mmtt.subinventory_code,
	     mmtt.locator_id,
	     mmtt.transaction_date
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id  = p_org_id
         AND mmtt.transfer_lpn_id  = p_lpn_id
         AND mmtt.parent_line_id  IS NULL
         AND mmtt.content_lpn_id  IS NULL
         AND mmtt.lpn_id          IS NOT NULL
         AND EXISTS
           ( SELECT 'x'
               FROM mtl_material_transactions_temp  mmtt2
              WHERE mmtt2.organization_id      = p_org_id
                AND mmtt2.transfer_lpn_id      = p_lpn_id
                AND mmtt2.content_lpn_id       = mmtt.lpn_id
                AND mmtt2.transaction_temp_id <> mmtt.transaction_temp_id
           )
       UNION ALL
      -- Nested LPNs
      SELECT mmtt.transaction_temp_id ,
             mmtt.organization_id,
	     mmtt.inventory_item_id,
	     mmtt.revision ,
	     mmtt.subinventory_code,
	     mmtt.locator_id,
	     mmtt.transaction_date
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id  = p_org_id
         AND mmtt.transfer_lpn_id  = p_lpn_id
         AND mmtt.parent_line_id  IS NULL
         AND mmtt.content_lpn_id  IS NOT NULL
       UNION ALL
      -- Picked from LPN that is not a nested LPN
      SELECT mmtt.transaction_temp_id,
             mmtt.organization_id,
	     mmtt.inventory_item_id,
	     mmtt.revision ,
	     mmtt.subinventory_code,
	     mmtt.locator_id,
	     mmtt.transaction_date
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id  = p_org_id
         AND mmtt.transfer_lpn_id  = p_lpn_id
         AND mmtt.parent_line_id  IS NULL
         AND mmtt.content_lpn_id  IS NULL
         AND mmtt.lpn_id          IS NOT NULL
         AND NOT EXISTS
           ( SELECT 'x'
               FROM mtl_material_transactions_temp  mmtt2
              WHERE mmtt2.organization_id      = p_org_id
                AND mmtt2.transfer_lpn_id      = p_lpn_id
                AND mmtt2.content_lpn_id       = mmtt.lpn_id
                AND mmtt2.transaction_temp_id <> mmtt.transaction_temp_id
           )
       UNION ALL
       --Added for Bug 6717052
       SELECT mmtt.transaction_temp_id ,
             mmtt.organization_id,
	     mmtt.inventory_item_id,
	     mmtt.revision ,
	     mmtt.subinventory_code,
	     mmtt.locator_id,
	     mmtt.transaction_date
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id  = p_org_id
         AND mmtt.transfer_lpn_id  IN (SELECT lpn_id FROM wms_license_plate_numbers
                                       WHERE outermost_lpn_id = p_lpn_id AND lpn_id <> outermost_lpn_id)
         AND mmtt.parent_line_id  IS NULL
       UNION ALL
      -- Loose material
      SELECT mmtt.transaction_temp_id,
             mmtt.organization_id,
	     mmtt.inventory_item_id,
	     mmtt.revision ,
	     mmtt.subinventory_code,
	     mmtt.locator_id,
	     mmtt.transaction_date
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id  = p_org_id
         AND mmtt.transfer_lpn_id  = p_lpn_id
         AND mmtt.parent_line_id  IS NULL
         AND mmtt.content_lpn_id  IS NULL
         AND mmtt.lpn_id          IS NULL
     ORDER BY 2,3,4,5,6,7 ) mmtt, wms_dispatched_tasks wdt
  WHERE mmtt.TRANSACTION_TEMP_ID=wdt.TRANSACTION_TEMP_ID(+)
  ORDER BY mmtt.organization_id,
	     mmtt.inventory_item_id,
	     mmtt.revision ,
	     mmtt.subinventory_code,
	     mmtt.locator_id,
	     mmtt.transaction_date,
       wdt.loaded_time; --Bug#6267350    -- Modified for bug#9247514



    CURSOR c_get_txn_info
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mmtt.parent_line_id
           , mmtt.transaction_type_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id;


    CURSOR c_get_parent_tasks
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT mmtt.transaction_temp_id
           , wdt.task_id
        FROM mtl_material_transactions_temp  mmtt
           , wms_dispatched_tasks            wdt
       WHERE mmtt.organization_id    = p_org_id
         AND mmtt.transfer_lpn_id    = p_lpn_id
         AND mmtt.parent_line_id    IS NOT NULL
         AND mmtt.parent_line_id     = mmtt.transaction_temp_id
         AND wdt.transaction_temp_id = mmtt.transaction_temp_id;


    CURSOR c_get_srl_alloc_stat
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mmtt.serial_allocated_flag
        FROM mtl_material_transactions_temp  mmtt
       WHERE transaction_temp_id = p_temp_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( '...Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id) || g_newline ||
         'p_emp_id          => '     || to_char(p_emp_id)          || g_newline ||
         'p_drop_lpn        => '     || p_drop_lpn                 || g_newline ||
         'p_orig_subinv     => '     || p_orig_subinv              || g_newline ||
         'p_subinventory    => '     || p_subinventory             || g_newline ||
         'p_orig_locid      => '     || p_orig_locid               || g_newline ||
         'p_loc_id          => '     || to_char(p_loc_id)          || g_newline ||
         'p_reason_id       => '     || to_char(p_reason_id)       || g_newline ||
         'p_task_type       => '     || to_char(p_task_type)       || g_newline ||
         'p_outer_lpn_done  => '     || p_outer_lpn_done           || g_newline ||
          'p_bulk_drop       => '     || to_char(p_bulk_drop)
       , l_api_name
       );
    END IF;

    SAVEPOINT pick_drop_sp;

   IF p_drop_lpn IS NOT NULL THEN
      IF l_debug = 1 THEN print_debug ('find l_drop_lpn_id: ' , l_api_name); END IF;
      BEGIN
      SELECT wlpn.lpn_id
        INTO l_drop_lpn_id
         FROM wms_license_plate_numbers  wlpn
        WHERE wlpn.license_plate_number = p_drop_lpn
          AND wlpn.organization_id      = p_organization_id
          AND ROWNUM=1;
      IF l_debug = 1 THEN print_debug ('find l_drop_lpn_id: ' || l_drop_lpn_id , l_api_name); END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF l_debug = 1 THEN
            print_debug ('l_drop_lpn_id: not found ' , l_api_name);
            print_debug ('Drop LPN is new.' || p_drop_lpn, l_api_name);
         END IF;

         /* mrana: Bug: 5049145 : If drop LPN is a user-keyed in value, we still
          * need to do MDC validations and for that we must create this LPN before
          * calling MDC API */
          -- Start of 5049145
         wms_container_pub.create_lpn
         ( p_api_version     => 1.0
         , x_return_status   => l_api_return_status
         , x_msg_count       => l_msg_count
         , x_msg_data        => l_msg_data
         , p_lpn             => p_drop_lpn
         , p_organization_id => p_organization_id
         , x_lpn_id          => l_drop_lpn_id
         , p_source          => wms_container_pub.lpn_context_pregenerated
         );

         IF l_api_return_status <> fnd_api.g_ret_sts_success
         THEN
            IF l_debug = 1 THEN
               print_debug
               ( 'Error from WMS_Container_PUB.create_lpn: ' || l_msg_data
               , l_api_name);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            IF l_debug = 1 THEN
               print_debug
               ( 'WMS_Container_PUB.create_lpn returned LPN '
                 || to_char(l_drop_lpn_id)
               , l_api_name);
            END IF;
         END IF;
         -- End  of 5049145
      END ;
   END IF;

   IF l_debug = 1 THEN
      print_debug ('l_drop_lpn_id: ' || l_drop_lpn_id , l_api_name);
   END IF;

   -- Added the following if condition for bug 5186375
   IF l_drop_lpn_id IS NOT NULL   AND
      l_drop_lpn_id <> 0
   THEN

    --Start-Added the following for bug 10139672
      IF nvl(g_xfer_to_lpn_id,0) <> 0 AND
         g_xfer_to_lpn_id <> p_transfer_lpn_id
      THEN
         l_xfer_to_lpn_id := g_xfer_to_lpn_id;
      ELSE
		     l_xfer_to_lpn_id :=  Nvl(p_transfer_lpn_id,0);
	    END IF;

      IF l_debug = 1 THEN
      print_debug ('xfer_to_lpn_id passed to wms_mdc_pvt.validate_to_lpn' || l_xfer_to_lpn_id , l_api_name);
      END IF;
    --END-Added the following for bug 10139672

      wms_mdc_pvt.validate_to_lpn
            (--p_from_lpn_id              => nvl(p_transfer_lpn_id,0),commented for bug 10139672
			 p_from_lpn_id              => nvl(l_xfer_to_lpn_id,0),    --added for bug 10139672
             p_from_delivery_id         => null,
             p_to_lpn_id                => nvl(l_drop_lpn_id,0),
             p_is_from_to_delivery_same => 'U',
             p_to_sub                   => p_subinventory,
             p_to_locator_id            => nvl(p_loc_id,0),
             x_allow_packing            => l_allow_packing,
             x_return_status            => l_api_return_status,
             x_msg_count                => l_msg_count,
             x_msg_data                 => l_msg_data);

      IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
         IF l_debug = 1 THEN
            print_debug('Error from wms_mdc_pvt.validate_to_lpn: ' || l_msg_data, l_api_name);
         END IF;
         RAISE fnd_api.g_exc_error;
      ELSE
         IF l_debug = 1 THEN
            print_debug('wms_mdc_pvt.validate_to_lpn returned: ' || l_allow_packing, l_api_name);
         END IF;

         IF l_allow_packing = 'N' THEN
            RAISE fnd_api.g_exc_error;
         END IF;

      END IF;

     IF l_allow_packing = 'C' THEN -- one of the from LPNs is a consol LPN
        IF p_drop_lpn IS NULL OR p_drop_lpn = 0 THEN
           BEGIN
           SELECT mil.inventory_location_type
             INTO l_to_loc_type
             FROM mtl_item_locations mil
            WHERE mil.organization_id       = p_organization_id
              AND mil.subinventory_code     = p_subinventory
              AND mil.inventory_location_id = p_loc_id;
           IF (l_debug = 1) THEN print_debug('l_to_loc_type' || l_to_loc_type , l_api_name); END IF;
           EXCEPTION WHEN NO_DATA_FOUND THEN
                IF (l_debug = 1) THEN print_debug('exception selecting to_loc_type', l_api_name ); END IF;
                RAISE FND_API.G_exc_unexpected_error;
           END ;
           IF l_to_loc_type <> inv_globals.g_loc_type_staging_lane THEN
              fnd_message.set_name('WMS', 'WMS_STAGE_FROM_CONSOL_LPN');
              fnd_msg_pub.ADD;
              IF l_debug = 1 THEN
                 print_debug('WMS_STAGE_FROM_CONSOL_LPN : Destination Locator must be ' ||
                             'staging locator when one of the From LPNs is a consol LPN'
                            , l_api_name );
                 -- {{- Destination Locator must be staging locator when one of the From LPNs is a consol LPN }}

              END IF;
              RAISE fnd_api.g_exc_error;
           END IF ;
        END IF ;
     END IF;
   END IF;

    fnd_msg_pub.initialize;

    --
    -- Validate passed in Org and LPN
    --
    IF p_organization_id <> g_current_drop_lpn.organization_id
       OR
       p_transfer_lpn_id <> g_current_drop_lpn.lpn_id
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Passed in org or LPN did not match cached info: '
            || g_newline || 'p_organization_id: ' || to_char(p_organization_id)
            || g_newline || 'p_transfer_lpn_id: ' || to_char(p_transfer_lpn_id)
            || g_newline || 'Cached Org ID:     ' || to_char(g_current_drop_lpn.organization_id)
            || g_newline || 'Cached LPN ID:     ' || to_char(g_current_drop_lpn.lpn_id)
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_pack_txn_exists := FALSE;
     IF l_debug = 1 THEN
             print_debug ('g_current_drop_lpn.multiple_drops ' || g_current_drop_lpn.multiple_drops, l_api_name);
             print_debug ('p_bulk_drop ' || p_bulk_drop, l_api_name);
      END IF;
    IF g_current_drop_lpn.multiple_drops = 'TRUE'
    THEN
       l_api_return_status := fnd_api.g_ret_sts_success;
       get_temp_list
       ( x_temp_tbl      => l_temp_tbl
       , x_return_status => l_api_return_status
       , p_group_num     => NULL
       , p_status        => NULL
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug ('Error from get_temp_list', l_api_name);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       l_xfer_lpn_used := FALSE;
    ELSE
       IF p_bulk_drop = 'TRUE'
       THEN
          l_api_return_status := fnd_api.g_ret_sts_success;

          preprocess_bulk_drop
          ( x_temp_tbl         => l_temp_tbl
          , x_pack_txn_exists  => l_pack_txn_exists
          , x_return_status    => l_api_return_status
          , p_orgn_id          => p_organization_id
          , p_xfer_lpn_id      => p_transfer_lpn_id
          , p_drop_lpn         => p_drop_lpn
          );

          IF l_api_return_status <> fnd_api.g_ret_sts_success
          THEN
             IF l_debug = 1 THEN
                print_debug ('Error from preprocess_bulk_drop', l_api_name);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       ELSE
          OPEN c_get_nonbulk_tasks (p_organization_id, p_transfer_lpn_id);
          FETCH c_get_nonbulk_tasks BULK COLLECT INTO l_temp_tbl;
          CLOSE c_get_nonbulk_tasks;
       END IF;
       l_xfer_lpn_used := TRUE;
    END IF;

    WHILE l_temp_tbl.COUNT > 0
    LOOP
       ii := l_temp_tbl.FIRST;
       jj := l_temp_tbl.LAST;

       l_batch_seq_id := 1;

       IF l_debug = 1 THEN
          print_debug
          ( 'ii = ' || to_char(ii) || ', jj = ' || to_char(jj)
          , l_api_name
          );
       END IF;

       l_transaction_temp_id := l_temp_tbl(ii);
       l_first_temp_id       := l_transaction_temp_id;


       BEGIN
          SELECT mmtt.transfer_lpn_id,
                 mmtt.inventory_item_id,
                 mmtt.transaction_uom,
                 mmtt.transaction_quantity
            INTO l_curr_xfer_lpn_id, l_inventory_item_id, l_transaction_uom, l_transaction_qty
            FROM mtl_material_transactions_temp  mmtt
           WHERE mmtt.transaction_temp_id = l_transaction_temp_id;

          IF l_debug = 1 THEN
             print_debug
             ('Temp ID '           || to_char(l_transaction_temp_id) ||
              ' has Xfer lpn ID: ' || to_char(l_curr_xfer_lpn_id)
             , l_api_name
             );
          END IF;

          IF ( (NOT l_xfer_lpn_used)
               AND
               (l_curr_xfer_lpn_id = p_transfer_lpn_id)
             )
          THEN
             l_xfer_lpn_used := TRUE;
          END IF;
       EXCEPTION
          WHEN OTHERS THEN
             IF l_debug = 1 THEN
                print_debug
                ('Error getting MMTT xfer LPN ID: ' || sqlerrm
                , l_api_name
                );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;

       IF (to_number(p_orig_locid) <> p_loc_id) AND (to_number(p_orig_locid) <> 0) THEN
          inv_loc_wms_utils.revert_loc_suggested_capacity(x_return_status            => l_api_return_status,
                                                          x_msg_count                => l_msg_count,
                                                          x_msg_data                 => l_msg_data,
                                                          p_organization_id          => p_organization_id,
                                                          p_inventory_location_id    => To_number(p_orig_locid),
                                                          p_inventory_item_id        => l_inventory_item_id,
                                                          p_primary_uom_flag         => 'N',
                                                          p_transaction_uom_code     => l_transaction_uom,
                                                          p_quantity                 => l_transaction_qty);


          IF l_api_return_status <> fnd_api.g_ret_sts_success
            THEN
             IF l_debug = 1 THEN
                print_debug('Error from revert_loc_suggested_capacity', l_api_name);
             END IF;
             -- Bug 5393727: do not raise an exception if locator API returns an error
             -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

       END IF;

       --
       -- Update LPN context if required
       --
       -- Bug5659809: update last_update_date and last_update_by as well
       UPDATE wms_license_plate_numbers  wlpn
          SET wlpn.lpn_context = WMS_Container_PUB.LPN_CONTEXT_PACKING
            , last_update_date = SYSDATE
            , last_updated_by = fnd_global.user_id
        WHERE wlpn.lpn_id      = l_curr_xfer_lpn_id
          AND wlpn.lpn_context = WMS_Container_PUB.LPN_CONTEXT_PREGENERATED;

       IF l_debug = 1 AND SQL%FOUND
       THEN
          print_debug
          ('Updated LPN context to packing for LPN ID ' || to_char(l_curr_xfer_lpn_id)
          , l_api_name
          );
       END IF;

       --
       -- Generate a new transaction header ID
       --
       SELECT mtl_material_transactions_s.NEXTVAL
         INTO l_txn_header_id
         FROM dual;

       IF l_debug = 1 THEN
          print_debug
          ( 'Generated header ID: ' || to_char(l_txn_header_id)
          , l_api_name
          );
       END IF;

       l_curr_lpn_done := FALSE;
       WHILE (NOT l_curr_lpn_done)
       LOOP
          IF l_debug = 1 THEN
             print_debug
             ( 'Processing temp ID: ' || to_char(l_transaction_temp_id)
             , l_api_name
             );
          END IF;

          OPEN c_get_txn_info (l_transaction_temp_id);
          FETCH c_get_txn_info INTO l_parent_line_id, l_txn_type_id;
          CLOSE c_get_txn_info;

          IF l_debug = 1 THEN
             print_debug
             ( 'l_parent_line_id: ' || to_char(l_parent_line_id) ||
               ', l_txn_type_id: '  || to_char(l_txn_type_id)
             , l_api_name
             );
          END IF;

          IF l_parent_line_id IS NOT NULL
          THEN
             IF l_debug = 1 THEN
                print_debug
                ( ' Creating WDT record for temp ID: ' || to_char(l_transaction_temp_id)
                , l_api_name
                );
             END IF;

             IF g_current_drop_lpn.multiple_drops <> 'TRUE'
             THEN
                OPEN c_get_srl_alloc_stat (l_transaction_temp_id);
                FETCH c_get_srl_alloc_stat INTO l_srl_stat;
                CLOSE c_get_srl_alloc_stat;

                IF l_srl_stat = 'N' THEN
                   l_api_return_status := fnd_api.g_ret_sts_success;
                   insert_child_msnt
                   ( x_return_status => l_api_return_status
                   , p_temp_id       => l_transaction_temp_id
                   , p_parent_tmp_id => l_parent_line_id
                   , p_txn_header_id => l_txn_header_id
                   );
                   IF l_api_return_status <> fnd_api.g_ret_sts_success
                   THEN
                      IF l_debug = 1 THEN
                         print_debug ('Error from insert_child_msnt', l_api_name);
                      END IF;
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   ELSE
                      IF l_debug = 1 THEN
                         print_debug ('Success status from insert_child_msnt', l_api_name);
                      END IF;
                   END IF;
                END IF;
             END IF;

             BEGIN
                BEGIN
                   SELECT wdt.task_id
                     INTO l_task_id
                     FROM wms_dispatched_tasks  wdt
                    WHERE wdt.transaction_temp_id = l_transaction_temp_id;
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      INSERT INTO wms_dispatched_tasks
                      ( task_id
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
                      ( SELECT wms_dispatched_tasks_s.NEXTVAL
                             , l_transaction_temp_id
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
                             , p_emp_id
                             , SYSDATE
                             , p_emp_id
                             , wdt.task_type
                             , SYSDATE
                             , mmtt.operation_plan_id
                             , mmtt.move_order_line_id
                          FROM wms_dispatched_tasks  wdt
                             , mtl_material_transactions_temp mmtt
                         WHERE wdt.transaction_temp_id  = l_parent_line_id
                           AND mmtt.transaction_temp_id = l_transaction_temp_id
                           AND rownum                   = 1
                      );

                      SELECT wdt.task_id
                        INTO l_task_id
                        FROM wms_dispatched_tasks  wdt
                       WHERE wdt.transaction_temp_id = l_transaction_temp_id;

                   WHEN OTHERS THEN
                      IF l_debug = 1 THEN
                         print_debug
                         ( 'Exception querying WDT: ' || sqlerrm
                         , l_api_name
                         );
                      END IF;
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END;

                IF l_debug = 1 THEN
                   print_debug
                   ( 'Task ID: ' || to_char(l_task_id)
                   , l_api_name
                   );
                END IF;

                l_task_tbl(l_task_id) := l_parent_line_id;

             EXCEPTION
                WHEN OTHERS THEN
                   IF l_debug = 1 THEN
                      print_debug
                      ( 'Exception when processing child WDT: '
                        || sqlerrm
                      , l_api_name
                      );
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END;

             --
             -- Update parent line to NULL
             --
             BEGIN
                UPDATE mtl_material_transactions_temp  mmtt
                   SET mmtt.parent_line_id = NULL
                 WHERE transaction_temp_id = l_transaction_temp_id;

                IF l_debug = 1 THEN
                   print_debug( 'Updated MMTT', l_api_name);
                END IF;

             EXCEPTION
                WHEN OTHERS THEN
                   IF l_debug = 1 THEN
                      print_debug
                      ( 'Exception updating MMTT: ' || sqlerrm
                      , l_api_name
                      );
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END;
          END IF; -- IF l_parent_line_id IS NOT NULL

          --
          -- Call complete_pick
          --
          IF l_txn_type_id <> INV_GLOBALS.G_TYPE_CONTAINER_PACK
          THEN
             l_api_return_status := fnd_api.g_ret_sts_success;
             wms_task_dispatch_gen.complete_pick
             ( p_lpn               => p_drop_lpn
             , p_container_item_id => NULL
             , p_org_id            => p_organization_id
             , p_temp_id           => l_transaction_temp_id
             , p_loc               => p_loc_id
             , p_sub               => p_subinventory
             , p_from_lpn_id       => l_curr_xfer_lpn_id
             , p_txn_hdr_id        => l_txn_header_id
             , p_user_id           => fnd_global.user_id -- 9798240,p_emp_id
             , x_return_status     => l_api_return_status
             , x_msg_count         => l_msg_count
             , x_msg_data          => l_msg_data
             , p_ok_to_process     => l_ok_to_process
             );

             IF l_api_return_status <> fnd_api.g_ret_sts_success
             THEN
                IF l_debug = 1 THEN
                   print_debug
                   ('Error from wms_task_dispatch_gen.complete_pick'
                   , l_api_name
                   );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
             END IF;

             IF l_ok_to_process = 'false'
             THEN
                IF l_debug = 1 THEN
                   print_debug
                   ( 'wms_task_dispatch_gen.complete_pick returned not_ok_to_process'
                   , l_api_name
                   );
                END IF;
                fnd_message.set_name('INV', 'INV-SUBINV NOT RESERVABLE');
                fnd_msg_pub.ADD;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;

          BEGIN
             IF l_txn_type_id = INV_GLOBALS.G_TYPE_CONTAINER_PACK
             THEN
                UPDATE mtl_material_transactions_temp  mmtt
                   SET mmtt.transaction_header_id = l_txn_header_id
                     , mmtt.subinventory_code     = p_subinventory
                     , mmtt.locator_id            = p_loc_id
                     , mmtt.transfer_subinventory = p_subinventory
                     , mmtt.transfer_to_location  = p_loc_id
                     , mmtt.transaction_batch_id  = l_txn_header_id
                     , mmtt.transaction_batch_seq = l_batch_seq_id
                 WHERE transaction_temp_id = l_transaction_temp_id;

                IF l_debug = 1 THEN
                   print_debug
                   ( 'Updated packing txn '       || to_char(l_transaction_temp_id) ||
                     ' - set batch/header ID to ' || to_char(l_txn_header_id)       ||
                     ', batch sequence to '       || to_char(l_batch_seq_id)        ||
                     ', sub and xfer sub to '     || p_subinventory                 ||
                     ', loc and xfer loc to '     || to_char(p_loc_id)
                   , l_api_name
                   );
                END IF;
              ELSIF l_txn_type_id = 2 THEN -- Sub Transfer Transaction created by bulk overpick
                UPDATE mtl_material_transactions_temp  mmtt
                   SET mmtt.transfer_subinventory = p_subinventory,
                       mmtt.transfer_to_location  = p_loc_id,
                       mmtt.transaction_batch_id  = l_txn_header_id,
                       mmtt.transaction_batch_seq = l_batch_seq_id
                 WHERE transaction_temp_id = l_transaction_temp_id;

                IF l_debug = 1 THEN
                   print_debug
                   ( 'Updated subtransfer txn '       || to_char(l_transaction_temp_id) ||
                     ' - set batch/header ID to ' || to_char(l_txn_header_id)       ||
                     ', batch sequence to '       || to_char(l_batch_seq_id)        ||
                     ', xfer sub to '     || p_subinventory                 ||
                     ',  xfer loc to '     || to_char(p_loc_id)
                   , l_api_name);
                END IF;
              ELSE
                UPDATE mtl_material_transactions_temp  mmtt
                   SET mmtt.transaction_batch_seq = l_batch_seq_id
                 WHERE transaction_temp_id = l_transaction_temp_id;

                IF l_debug = 1 THEN
                   print_debug
                   ( 'Updated temp ID '          || to_char(l_transaction_temp_id) ||
                     ' - set batch sequence to ' || to_char(l_batch_seq_id)
                   , l_api_name
                   );
                END IF;
             END IF;

             l_batch_seq_id := l_batch_seq_id + 1;

          EXCEPTION
             WHEN OTHERS THEN
                IF l_debug = 1 THEN
                   print_debug
                   ( 'Exception updating batch sequence on MMTT: ' || sqlerrm
                   , l_api_name
                   );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

          IF ii = jj THEN
             l_temp_tbl.DELETE(ii);
             l_curr_lpn_done := TRUE;
          ELSE
             kk := ii;
             ii := l_temp_tbl.NEXT(ii);
             l_temp_tbl.DELETE(kk);

             WHILE (ii <= jj)
             LOOP
                l_transaction_temp_id := l_temp_tbl(ii);
                BEGIN
                   SELECT mmtt.transfer_lpn_id
                     INTO l_next_xfer_lpn_id
                     FROM mtl_material_transactions_temp  mmtt
                    WHERE mmtt.transaction_temp_id = l_transaction_temp_id;

                   IF l_debug = 1 THEN
                      print_debug
                      ('Temp ID '           || to_char(l_transaction_temp_id) ||
                       ' has Xfer lpn ID: ' || to_char(l_next_xfer_lpn_id)
                      , l_api_name
                      );
                   END IF;

                EXCEPTION
                   WHEN OTHERS THEN
                      IF l_debug = 1 THEN
                         print_debug
                         ('Error getting MMTT xfer LPN ID: ' || sqlerrm
                         , l_api_name
                         );
                      END IF;
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END;

                IF l_next_xfer_lpn_id = l_curr_xfer_lpn_id
                THEN
                   EXIT;
                ELSE
                   IF ii < jj THEN
                      ii := l_temp_tbl.NEXT(ii);
                   ELSE
                      l_curr_lpn_done := TRUE;
                      EXIT;
                   END IF;
                END IF;
             END LOOP;
          END IF;
       END LOOP; -- end LOOP l_curr_lpn_done

       --
       -- Call pick_drop
       --
       l_api_return_status := fnd_api.g_ret_sts_success;

       IF g_current_drop_lpn.multiple_drops = 'FALSE'
          AND
          p_bulk_drop = 'TRUE'
          AND
          l_pack_txn_exists
       THEN
          wms_task_dispatch_gen.pick_drop
          ( p_temp_id       => l_first_temp_id
          , p_txn_header_id => l_txn_header_id
          , p_org_id        => p_organization_id
          , x_return_status => l_api_return_status
          , x_msg_count     => l_msg_count
          , x_msg_data      => l_msg_data
          , p_from_lpn_id   => l_curr_xfer_lpn_id
          , p_drop_lpn      => NULL
          , p_loc_reason_id => 0
          , p_sub           => p_subinventory
          , p_loc           => p_loc_id
          , p_orig_sub      => p_orig_subinv
          , p_orig_loc      => p_orig_locid
          , p_user_id       => p_emp_id
          , p_task_type     => p_task_type
          , p_commit        => 'N'
          );
       ELSE
          wms_task_dispatch_gen.pick_drop
          ( p_temp_id       => l_first_temp_id
          , p_txn_header_id => l_txn_header_id
          , p_org_id        => p_organization_id
          , x_return_status => l_api_return_status
          , x_msg_count     => l_msg_count
          , x_msg_data      => l_msg_data
          , p_from_lpn_id   => l_curr_xfer_lpn_id
          , p_drop_lpn      => p_drop_lpn
          , p_loc_reason_id => p_reason_id
          , p_sub           => p_subinventory
          , p_loc           => p_loc_id
          , p_orig_sub      => p_orig_subinv
          , p_orig_loc      => p_orig_locid
          , p_user_id       => p_emp_id
          , p_task_type     => p_task_type
          , p_commit        => 'N'
          );
       END IF;

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug ('Error from wms_task_dispatch_gen.pick_drop', l_api_name);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    END LOOP; -- end WHILE l_temp_tbl.COUNT > 0

    IF l_task_tbl.COUNT > 0 THEN
       ii := l_task_tbl.FIRST;
       jj := l_task_tbl.LAST;

       IF l_debug = 1 THEN
          print_debug
          ( 'Updating WDTH: ii = ' || to_char(ii)
            || ', jj = ' || to_char(jj)
          , l_api_name
          );
       END IF;

       l_task_id        := ii;
       l_parent_line_id := l_task_tbl(ii);

       WHILE (ii <= jj)
       LOOP
          --
          -- Update parent_transaction_id in WDTH
          --
          BEGIN
             UPDATE wms_dispatched_tasks_history  wdth
                SET wdth.parent_transaction_id = l_parent_line_id
                  , wdth.is_parent = 'N'
              WHERE task_id = l_task_id;

             IF l_debug = 1 THEN
                print_debug
                ( 'Updated WDTH: set parent_transaction_id = '
                  || to_char(l_parent_line_id)
                , l_api_name
                );
             END IF;

          EXCEPTION
             WHEN OTHERS THEN
                IF l_debug = 1 THEN
                   print_debug
                   ( 'Exception updating WDTH: ' || sqlerrm
                   , l_api_name
                   );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

          IF ii < jj THEN
             ii               := l_task_tbl.NEXT(ii);
             l_task_id        := ii;
             l_parent_line_id := l_task_tbl(ii);
          ELSE
             EXIT;
          END IF;

          IF l_debug = 1 THEN
             print_debug
             ( 'Fetched next task ID: ' || to_char(l_task_id)
             , l_api_name
             );
          END IF;
       END LOOP;
    END IF;

    IF p_outer_lpn_done = 'TRUE'
    THEN
       FOR parent_rec IN c_get_parent_tasks(p_organization_id, p_transfer_lpn_id)
       LOOP
          IF l_debug = 1 THEN
             print_debug
             ( 'Processing parent: ' || to_char(parent_rec.transaction_temp_id)
               || ', task ID = '     || to_char(parent_rec.task_id)
             , l_api_name
             );
          END IF;

          SELECT mtl_material_transactions_s.NEXTVAL
            INTO l_txn_header_id
            FROM dual;

          IF l_debug = 1 THEN
             print_debug
             ( 'Generated header ID: ' || to_char(l_txn_header_id)
             , l_api_name
             );
          END IF;

          l_api_return_status := fnd_api.g_ret_sts_success;
          wms_task_dispatch_put_away.archive_task
          ( p_temp_id           => parent_rec.transaction_temp_id
          , p_org_id            => p_organization_id
          , x_return_status     => l_api_return_status
          , x_msg_count         => l_msg_count
          , x_msg_data          => l_msg_data
          , p_delete_mmtt_flag  => 'Y'
          , p_txn_header_id     => l_txn_header_id
          , p_transfer_lpn_id   => p_transfer_lpn_id
          );

          IF l_api_return_status <> fnd_api.g_ret_sts_success
          THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'Error from wms_task_dispatch_put_away.archive_task: '
                  || l_msg_data
                , l_api_name
                );
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          --
          -- Update parent_transaction_id in WDTH
          --
          BEGIN
             UPDATE wms_dispatched_tasks_history  wdth
                SET wdth.parent_transaction_id = wdth.transaction_id
                  , wdth.is_parent = 'Y'
              WHERE wdth.task_id = parent_rec.task_id
                    RETURNING wdth.transaction_id INTO l_parent_txn_id;

             IF l_debug = 1 THEN
                print_debug
                ( 'Updated WDTH.  Parent transaction ID is: '
                  || to_char(l_parent_txn_id)
                , l_api_name
                );
             END IF;

          EXCEPTION
             WHEN OTHERS THEN
                IF l_debug = 1 THEN
                   print_debug
                   ( 'Exception updating WDTH: ' || sqlerrm
                   , l_api_name
                   );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

          --
          -- Update child lines
          --
          BEGIN
             UPDATE wms_dispatched_tasks_history  wdth
                SET wdth.parent_transaction_id = l_parent_txn_id
              WHERE wdth.parent_transaction_id = parent_rec.transaction_temp_id;

             IF l_debug = 1 THEN
                print_debug
                ( 'Updated WDTH for child records.'
                , l_api_name
                );
             END IF;

          EXCEPTION
             WHEN OTHERS THEN
                IF l_debug = 1 THEN
                   print_debug
                   ( 'Exception updating WDTH: ' || sqlerrm
                   , l_api_name
                   );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;
       END LOOP;
    END IF;

    l_task_tbl.DELETE;

    DELETE mtl_allocations_gtmp;

    IF p_outer_lpn_done = 'TRUE'
    THEN
       IF ( (g_current_drop_lpn.multiple_drops = 'TRUE')
            AND
            (NOT l_xfer_lpn_used)
          )
       THEN
          l_api_return_status := fnd_api.g_ret_sts_success;
          wms_container_pub.modify_lpn_wrapper
          ( p_api_version    => '1.0'
          , x_return_status  => l_api_return_status
          , x_msg_count      => l_msg_count
          , x_msg_data       => l_msg_data
          , p_lpn_id         => p_transfer_lpn_id
          , p_lpn_context    => WMS_Container_PUB.LPN_CONTEXT_PREGENERATED
          );

          IF l_api_return_status <> fnd_api.g_ret_sts_success
          THEN
             IF l_debug = 1 THEN
                print_debug
                ( 'Error from modify_lpn_wrapper: ' || l_msg_data
                , l_api_name
                );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

       l_api_return_status := fnd_api.g_ret_sts_success;
       clear_lpn_cache(l_api_return_status);

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug ('Error from clear_lpn_cache', l_api_name);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    ELSE
       g_current_drop_lpn.current_drop_list.DELETE;
       g_current_drop_lpn.temp_id_group_ref.DELETE;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO pick_drop_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO pick_drop_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END pick_drop;



  PROCEDURE create_temp_id_list
  ( x_temp_id_list     OUT NOCOPY  VARCHAR2
  , x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  ) IS

    l_api_name             VARCHAR2(30) := 'create_temp_id_list';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_temp_tbl             g_temp_id_tbl;

    l_api_return_status    VARCHAR2(1);
    l_transaction_temp_id  NUMBER;
    l_temp_id_list         VARCHAR2(32767) := NULL;  -- Set size to maximum allowed

    ii                     NUMBER;
    jj                     NUMBER;

    CURSOR c_get_tasks
    ( p_org_id  IN  NUMBER
    , p_lpn_id  IN  NUMBER
    ) IS
      SELECT mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.organization_id = p_org_id
         AND mmtt.transfer_lpn_id = p_lpn_id
         AND ( (mmtt.parent_line_id IS NOT NULL
                AND
                mmtt.parent_line_id <> mmtt.transaction_temp_id
               )
               OR
               mmtt.parent_line_id  IS NULL
             );

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id)
       , l_api_name
       );
    END IF;

    --
    -- Validate passed in Org and LPN
    --
    IF p_organization_id <> g_current_drop_lpn.organization_id
       OR
       p_transfer_lpn_id <> g_current_drop_lpn.lpn_id
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Passed in org or LPN did not match cached info: '
            || g_newline || 'p_organization_id: ' || to_char(p_organization_id)
            || g_newline || 'p_transfer_lpn_id: ' || to_char(p_transfer_lpn_id)
            || g_newline || 'Cached Org ID:     ' || to_char(g_current_drop_lpn.organization_id)
            || g_newline || 'Cached LPN ID:     ' || to_char(g_current_drop_lpn.lpn_id)
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF g_current_drop_lpn.multiple_drops = 'TRUE'
    THEN
       l_api_return_status := fnd_api.g_ret_sts_success;
       get_temp_list
       ( x_temp_tbl      => l_temp_tbl
       , x_return_status => l_api_return_status
       , p_group_num     => NULL
       , p_status        => NULL
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug ('Error from get_temp_list', l_api_name);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    ELSE
       OPEN c_get_tasks (p_organization_id, p_transfer_lpn_id);
       FETCH c_get_tasks BULK COLLECT INTO l_temp_tbl;
       CLOSE c_get_tasks;
    END IF;

    IF l_temp_tbl.COUNT > 0 THEN
       ii := l_temp_tbl.FIRST;
       jj := l_temp_tbl.LAST;

       IF l_debug = 1 THEN
          print_debug
          ( 'ii = ' || to_char(ii) || ', jj = ' || to_char(jj)
          , l_api_name
          );
       END IF;

       l_transaction_temp_id := l_temp_tbl(ii);
       l_temp_id_list        := to_char(l_transaction_temp_id);

       WHILE (ii <= jj)
       LOOP
          IF ii < jj THEN
             ii := l_temp_tbl.NEXT(ii);
             l_transaction_temp_id := l_temp_tbl(ii);
             l_temp_id_list := l_temp_id_list
                               || ','
                               || to_char(l_transaction_temp_id);
          ELSE
             EXIT;
          END IF;
       END LOOP;
    END IF;

    IF l_debug = 1 THEN
       print_debug
       ( 'Temp ID list: ' || l_temp_id_list
       , l_api_name
       );
    END IF;

    l_temp_tbl.DELETE;

    x_temp_id_list := l_temp_id_list;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END create_temp_id_list;



  PROCEDURE get_delivery_info
  ( x_delivery_name    OUT NOCOPY  VARCHAR2
  , x_order_number     OUT NOCOPY  VARCHAR2
  , x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  , p_delivery_id      IN          NUMBER
  ) IS

    l_api_name             VARCHAR2(30) := 'get_delivery_info';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_delivery_name        VARCHAR2(30);
    l_order_number         NUMBER;
    l_count                NUMBER;

    CURSOR c_get_delivery_name
    ( p_del_id  IN  NUMBER
    ) IS
      SELECT name
        FROM wsh_new_deliveries_ob_grp_v  wnd
       WHERE wnd.delivery_id = p_del_id;


    CURSOR c_get_order_number
    ( p_del_id  IN  NUMBER
    ) IS
      SELECT MIN(ooha.order_number)
           , COUNT(DISTINCT ooha.order_number)
        FROM wsh_delivery_assignments_v  wda
           , wsh_delivery_details_ob_grp_v      wdd
           , oe_order_lines_all    oola
           , oe_order_headers_all  ooha
       WHERE wda.delivery_id        = p_del_id
         AND wda.delivery_detail_id = wdd.delivery_detail_id
         AND wdd.source_line_id     = oola.line_id
         AND oola.header_id         = ooha.header_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id) || g_newline ||
         'p_delivery_id     => '     || to_char(p_delivery_id)
       , l_api_name
       );
    END IF;

    --
    -- Validate passed in Org and LPN
    --
    IF p_organization_id <> g_current_drop_lpn.organization_id
       OR
       p_transfer_lpn_id <> g_current_drop_lpn.lpn_id
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Passed in org or LPN did not match cached info: '
            || g_newline || 'p_organization_id: ' || to_char(p_organization_id)
            || g_newline || 'p_transfer_lpn_id: ' || to_char(p_transfer_lpn_id)
            || g_newline || 'Cached Org ID:     ' || to_char(g_current_drop_lpn.organization_id)
            || g_newline || 'Cached LPN ID:     ' || to_char(g_current_drop_lpn.lpn_id)
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OPEN c_get_delivery_name (p_delivery_id);
    FETCH c_get_delivery_name INTO l_delivery_name;
    CLOSE c_get_delivery_name;

    x_delivery_name := l_delivery_name;

    OPEN c_get_order_number (p_delivery_id);
    FETCH c_get_order_number INTO l_order_number, l_count;
    CLOSE c_get_order_number;

    IF l_count > 1 THEN
       x_order_number := NULL;
    ELSIF l_count = 1 THEN
       x_order_number := l_order_number;
    ELSE
       x_order_number := NULL;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END get_delivery_info;



  PROCEDURE process_conf_item
  ( x_is_xref          OUT NOCOPY  VARCHAR2
  , x_item_segs        OUT NOCOPY  VARCHAR2
  , x_revision         OUT NOCOPY  VARCHAR2
  , x_uom_code         OUT NOCOPY  VARCHAR2
  , x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  , p_conf_item        IN          VARCHAR2
  ) IS

    l_api_name             VARCHAR2(30) := 'process_conf_item';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_count                NUMBER;
    l_item_segs            VARCHAR2(1000);


    CURSOR c_get_item_xref
    ( p_org_id    IN  NUMBER
    , p_xref      IN  VARCHAR2
    , p_ref_type  IN  VARCHAR2
    ) IS
      SELECT mcr.inventory_item_id
           , mcr.uom_code
           , mir.revision
        FROM mtl_cross_references  mcr
           , mtl_item_revisions    mir
       WHERE mcr.organization_id      = mir.organization_id    (+)
         AND mcr.inventory_item_id    = mir.inventory_item_id  (+)
         AND mcr.revision_id          = mir.revision_id        (+)
         AND mcr.cross_reference_type = p_ref_type
         AND mcr.cross_reference      = p_xref
         AND (mcr.organization_id      = p_org_id
              OR
              mcr.org_independent_flag = 'Y'
             );

   c_xref_rec  c_get_item_xref%ROWTYPE;


   CURSOR c_get_segments
   ( p_org_id   IN  NUMBER
   , p_item_id  IN  NUMBER
   ) IS
     SELECT concatenated_segments
       FROM mtl_system_items_kfv  msik
      WHERE msik.organization_id   = p_org_id
        AND msik.inventory_item_id = p_item_id;


  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id     => ' || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id     => ' || to_char(p_transfer_lpn_id) || g_newline ||
         'p_conf_item           => ' || p_conf_item                || g_newline ||
         'g_gtin_cross_ref_type => ' || g_gtin_cross_ref_type
       , l_api_name
       );
    END IF;

    --
    -- Validate passed in Org and LPN
    --
    IF p_organization_id <> g_current_drop_lpn.organization_id
       OR
       p_transfer_lpn_id <> g_current_drop_lpn.lpn_id
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Passed in org or LPN did not match cached info: '
            || g_newline || 'p_organization_id: ' || to_char(p_organization_id)
            || g_newline || 'p_transfer_lpn_id: ' || to_char(p_transfer_lpn_id)
            || g_newline || 'Cached Org ID:     ' || to_char(g_current_drop_lpn.organization_id)
            || g_newline || 'Cached LPN ID:     ' || to_char(g_current_drop_lpn.lpn_id)
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OPEN c_get_item_xref
    ( p_organization_id
    , p_conf_item
    , g_gtin_cross_ref_type
    );
    FETCH c_get_item_xref INTO c_xref_rec;

    IF c_get_item_xref%NOTFOUND
    THEN
       x_is_xref := 'FALSE';
    ELSE
       x_is_xref := 'TRUE';
    END IF;
    CLOSE c_get_item_xref;

    IF x_is_xref = 'TRUE'
    THEN
       OPEN c_get_segments (p_organization_id, c_xref_rec.inventory_item_id);
       FETCH c_get_segments INTO l_item_segs;
       CLOSE c_get_segments;
       --
       -- Set the return values
       --
       x_item_segs := l_item_segs;
       x_revision  := c_xref_rec.revision;
       x_uom_code  := c_xref_rec.uom_code;
    END IF;

    IF l_debug = 1 THEN
       print_debug
       ( 'Returning the following values: '
         || g_newline || 'x_is_xref:   ' || x_is_xref
         || g_newline || 'x_item_segs: ' || x_item_segs
         || g_newline || 'x_revision:  ' || x_revision
         || g_newline || 'x_uom_code:  ' || x_uom_code
       , l_api_name
       );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END process_conf_item;

  PROCEDURE validate_pick_drop_lpn
  ( x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  , p_outer_lpn_done   IN          VARCHAR2
  , p_drop_lpn         IN          VARCHAR2
  , p_drop_sub         IN          VARCHAR2
  , p_drop_loc_id      IN          NUMBER
  , p_delivery_id      IN          NUMBER
  ) IS

    l_api_name             VARCHAR2(30) := 'validate_pick_drop_lpn';
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_api_return_status    VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    l_temp_tbl             g_temp_id_tbl;
    l_transaction_temp_id  NUMBER;
    l_xfer_lpn_id          NUMBER;
    l_delivery_id          NUMBER;

    ii                     NUMBER;
    jj                     NUMBER;

    l_line_rows            WSH_UTIL_CORE.id_tab_type;  -- Added for bug#4106176
    l_grouping_rows        WSH_UTIL_CORE.id_tab_type;  -- Added for bug#4106176

    l_allow_packing        VARCHAR2(1);

    CURSOR c_drop_lpn_cursor
    ( p_lpn     IN  VARCHAR2
    , p_org_id  IN  NUMBER
    ) IS
    SELECT wlpn.lpn_id
         , wlpn.lpn_context
         , wlpn.subinventory_code
         , wlpn.locator_id
      FROM wms_license_plate_numbers  wlpn
     WHERE wlpn.license_plate_number = p_lpn
       AND wlpn.organization_id      = p_org_id;

    drop_lpn_rec  c_drop_lpn_cursor%ROWTYPE;


    CURSOR c_xfer_lpn_id
    ( p_temp_id  IN  NUMBER
    ) IS
      SELECT mmtt.transfer_lpn_id
        FROM mtl_material_transactions_temp  mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id;


    CURSOR c_drop_delivery
    ( p_lpn_id  IN  NUMBER
    , p_org_id  IN  NUMBER
    ) IS
      SELECT wda.delivery_id
        FROM wsh_delivery_assignments_v   wda
           , wsh_delivery_details_ob_grp_v       wdd
           , wms_license_plate_numbers  lpn
       WHERE wda.parent_delivery_detail_id = wdd.delivery_detail_id
         AND wdd.organization_id           = p_org_id
         AND wdd.lpn_id                    = lpn.lpn_id
         AND wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
         AND lpn.outermost_lpn_id          = p_lpn_id
       ORDER BY wda.delivery_id;


  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline                  ||
         'p_organization_id => '     || to_char(p_organization_id) || g_newline ||
         'p_transfer_lpn_id => '     || to_char(p_transfer_lpn_id) || g_newline ||
         'p_outer_lpn_done  => '     || p_outer_lpn_done           || g_newline ||
         'p_drop_lpn        => '     || p_drop_lpn                 || g_newline ||
         'p_drop_sub        => '     || p_drop_sub                 || g_newline ||
         'p_drop_loc_id     => '     || to_char(p_drop_loc_id)     || g_newline ||
         'p_delivery_id     => '     || to_char(p_delivery_id)
       , l_api_name
       );
    END IF;

    --
    -- Validate passed in Org and LPN
    --
    IF p_organization_id <> g_current_drop_lpn.organization_id
       OR
       p_transfer_lpn_id <> g_current_drop_lpn.lpn_id
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Passed in org or LPN did not match cached info: '
            || g_newline || 'p_organization_id: ' || to_char(p_organization_id)
            || g_newline || 'p_transfer_lpn_id: ' || to_char(p_transfer_lpn_id)
            || g_newline || 'Cached Org ID:     ' || to_char(g_current_drop_lpn.organization_id)
            || g_newline || 'Cached LPN ID:     ' || to_char(g_current_drop_lpn.lpn_id)
          , l_api_name
          );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OPEN c_drop_lpn_cursor (p_drop_lpn, p_organization_id);
    FETCH c_drop_lpn_cursor INTO drop_lpn_rec;

    IF c_drop_lpn_cursor%NOTFOUND
    THEN
       CLOSE c_drop_lpn_cursor;
       IF l_debug = 1 THEN
          print_debug
          ( 'Drop LPN is new.  No validations required.'
          , l_api_name
          );
       END IF;
       RETURN;
    ELSIF drop_lpn_rec.lpn_context =
          WMS_Container_PUB.LPN_CONTEXT_PREGENERATED
    THEN
       CLOSE c_drop_lpn_cursor;
       IF l_debug = 1 THEN
          print_debug
          ( 'Drop LPN is pre-generated.  No validations required.'
          , l_api_name
          );
       END IF;
       RETURN;
    ELSIF drop_lpn_rec.lpn_id = p_transfer_lpn_id
    THEN
      --Start change for bug 5620764: disallow using outer LPN as drop LPN
      CLOSE c_drop_lpn_cursor;
        IF l_debug = 1 THEN
      		print_debug
            ( 'Cannot use outer LPN as drop LPN'
            , l_api_name
            );
        END IF;
        fnd_message.set_name('WMS', 'WMS_DROP_PICK_LPN_SAME');
        fnd_msg_pub.ADD;
        RAISE FND_API.G_EXC_ERROR;
      RETURN;
      /*
       IF g_current_drop_lpn.multiple_drops = 'TRUE'
          AND
          p_outer_lpn_done <> 'TRUE'
       THEN
          CLOSE c_drop_lpn_cursor;
          IF l_debug = 1 THEN
             print_debug
             ( 'Outer LPN is not fully deconsolidated, so cannot use that as drop LPN'
             , l_api_name
             );
          END IF;
          fnd_message.set_name('WMS', 'WMS_LPN_HAS_MORE_DROP_MTL');
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
       ELSIF g_current_drop_lpn.multiple_drops <> 'TRUE'
       THEN
          CLOSE c_drop_lpn_cursor;
          IF l_debug = 1 THEN
             print_debug
             ( 'No deconsolidation, so cannot reuse outer as drop LPN'
             , l_api_name
             );
          END IF;
          fnd_message.set_name('WMS', 'WMS_DROP_PICK_LPN_SAME');
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       RETURN; -- multiple drops is TRUE and outer LPN done
      */
      -- End change for bug 5620764
    ELSIF drop_lpn_rec.lpn_context =
          WMS_Container_PUB.lpn_context_picked
    THEN
       IF drop_lpn_rec.subinventory_code <> p_drop_sub
          OR
          drop_lpn_rec.locator_id <> p_drop_loc_id
       THEN
          CLOSE c_drop_lpn_cursor;
          IF l_debug = 1 THEN
             print_debug
             ( 'Drop LPN resides in sub/loc '
               || drop_lpn_rec.subinventory_code   || '/'
               || to_char(drop_lpn_rec.locator_id)
               || ', which is different from '     || p_drop_sub
               || '/' || to_char(p_drop_loc_id)
             , l_api_name
             );
          END IF;
          fnd_message.set_name('WMS', 'WMS_DROP_LPN_SUBLOC_MISMATCH');
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSIF drop_lpn_rec.lpn_context =
          WMS_Container_PUB.LPN_LOADED_FOR_SHIPMENT
    THEN
        CLOSE c_drop_lpn_cursor;
        IF l_debug = 1 THEN
           print_debug
           ( 'Drop LPN is loaded to dock door already'
           , l_api_name
           );
        END IF;
        fnd_message.set_name('WMS', 'WMS_DROP_LPN_LOADED');
        fnd_msg_pub.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF c_drop_lpn_cursor%ISOPEN
    THEN
       CLOSE c_drop_lpn_cursor;
    END IF;

    IF g_current_drop_lpn.multiple_drops = 'TRUE'
    THEN
       l_api_return_status := fnd_api.g_ret_sts_success;
       get_temp_list
       ( x_temp_tbl      => l_temp_tbl
       , x_return_status => l_api_return_status
       , p_group_num     => NULL
       , p_status        => NULL
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF l_debug = 1 THEN
             print_debug ('Error from get_temp_list', l_api_name);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       --
       -- Check if transfer_lpn_id on any record matches
       -- drop LPN Id
       --
       IF l_temp_tbl.COUNT > 0 THEN
          ii := l_temp_tbl.FIRST;
          jj := l_temp_tbl.LAST;

          IF l_debug = 1 THEN
             print_debug
             ( 'ii = ' || to_char(ii) || ', jj = ' || to_char(jj)
             , l_api_name
             );
          END IF;

          l_transaction_temp_id := l_temp_tbl(ii);
          WHILE (ii <= jj)
          LOOP
             IF l_debug = 1 THEN
                print_debug
                ( ' Calling transfer_lpn_id on temp ID: '
                  || to_char(l_transaction_temp_id)
                , l_api_name
                );
             END IF;

             OPEN c_xfer_lpn_id (l_transaction_temp_id);
             FETCH c_xfer_lpn_id INTO l_xfer_lpn_id;
             IF c_xfer_lpn_id%NOTFOUND
             THEN
                CLOSE c_xfer_lpn_id;
                IF l_debug = 1 THEN
                   print_debug
                   ( 'No MMTT record found for temp ID: '
                     || to_char(l_transaction_temp_id)
                   , l_api_name
                   );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             IF c_xfer_lpn_id%ISOPEN
             THEN
                CLOSE c_xfer_lpn_id;
             END IF;

             IF l_xfer_lpn_id = drop_lpn_rec.lpn_id
             THEN
                IF l_debug = 1 THEN
                   print_debug
                   ( 'Xfer LPN '       || to_char(l_xfer_lpn_id)
                     || ' on temp ID ' || to_char(l_transaction_temp_id)
                     || ' matches drop LPN'
                   , l_api_name
                   );
                END IF;

                l_temp_tbl.DELETE;

                fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
                fnd_msg_pub.ADD;
                RAISE FND_API.G_EXC_ERROR;
             END IF;

             IF ii < jj THEN
                ii := l_temp_tbl.NEXT(ii);
                l_transaction_temp_id := l_temp_tbl(ii);
             ELSE
                EXIT;
             END IF;

             IF l_debug = 1 THEN
                print_debug
                ( 'Fetched next temp ID: ' || to_char(l_transaction_temp_id)
                , l_api_name
                );
             END IF;
          END LOOP;
       END IF;

       l_temp_tbl.DELETE;
    END IF;

    IF drop_lpn_rec.lpn_context <> WMS_Container_PUB.lpn_context_picked
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Invalid LPN context: ' || to_char(drop_lpn_rec.lpn_context)
          , l_api_name
          );
       END IF;
       fnd_message.set_name('WMS', 'WMS_INVALID_LPN_STATUS');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

--**MRANA temporary code for double validations and avoid data corruption

    wms_mdc_pvt.validate_to_lpn(p_from_lpn_id              => p_transfer_lpn_id,
                                p_from_delivery_id         => p_delivery_id,
                                p_to_lpn_id                => drop_lpn_rec.lpn_id,
                                p_is_from_to_delivery_same => 'U',
                                x_allow_packing            => l_allow_packing,
                                x_return_status            => l_api_return_status,
                                x_msg_count                => l_msg_count,
                                x_msg_data                 => l_msg_data);

    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF l_debug = 1 THEN
          print_debug('Error from wms_mdc_pvt.validate_to_lpn: ' || l_msg_data, l_api_name);
       END IF;
       RAISE fnd_api.g_exc_error;
     ELSE
       IF l_debug = 1 THEN
          print_debug('wms_mdc_pvt.validate_to_lpn returned: ' || l_allow_packing, l_api_name);
       END IF;

       IF l_allow_packing = 'N' THEN
          RAISE fnd_api.g_exc_error;
       END IF;

    END IF;


    -- MR: wms_mdc_pvt.validate_to_lpn API, returns  l_allow_packing = 'N', if
    -- {{- either from or To do not have a delivery id . Therefor, MDC is not }}
    -- {{  allowed if either of the 2 is NULL  }} */
 --mrana    IF l_allow_packing = 'U' THEN -- Both from LPN and to LPN are not tied to any delivery
     /*Bug#4106176.The following block is added.*/
    /* BEGIN  -- mrana: need to figure this out later
         SELECT delivery_detail_id
           INTO l_line_rows(1)
           FROM wsh_delivery_details_ob_grp_v
           WHERE lpn_id =  drop_lpn_rec.lpn_id
           AND rownum = 1 ;

         SELECT wdd.delivery_detail_id
           INTO l_line_rows(2)
           FROM wsh_delivery_details_ob_grp_v wdd, Mtl_material_transactions_temp mmtt
           WHERE mmtt.move_order_line_id = wdd.move_order_line_id
           AND wdd.organization_id = mmtt.organization_id
           AND mmtt.organization_id= p_organization_id
           AND mmtt.transfer_lpn_id= p_transfer_lpn_id
           AND rownum = 1 ;

         --call to the shipping API.
         WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping( p_line_rows     => l_line_rows,
                                                       x_grouping_rows => l_grouping_rows,
                                                       x_return_status => x_return_status);
         IF (l_debug = 1) THEN
            print_debug ('parameters : l_line_rows(1) :'||l_line_rows(1) ||',l_line_rows(2) :' || l_line_rows(2), l_api_name);
            print_debug('count l_grp_rows'|| l_grouping_rows.count, l_api_name);
            print_debug('l_grp_rows(1) : '||l_grouping_rows(1) ||',l_grp_rows(2) : '||l_grouping_rows(2), l_api_name);
         END IF;

         IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_grouping_rows(1) = l_grouping_rows(2) ) THEN
            IF (l_debug = 1) THEN
               print_debug('The LPN can be dropped into LPN_ID '||drop_lpn_rec.lpn_id, l_api_name);
            END IF;
          ELSE
            IF (l_debug = 1) THEN
               print_debug('Picked LPN does not belong to same delivery as Drop LPN. So cannot be dropped', l_api_name);
            END IF;
            fnd_message.set_name('WMS', 'WMS_DROP_LPN_DIFF_DELIV');
            fnd_msg_pub.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
               print_debug('No Data found Exception raised when checking for delivery grouping', l_api_name);
               print_debug('Picked LPN is not associated with a delivery, so dont show ANY lpn.', l_api_name);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
               print_debug('Other Exception raised when checking for delivery grouping', l_api_name);
               print_debug('Picked LPN is not associated with a delivery, so dont show ANY lpn.', l_api_name);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
      END; */ --End of Fix for bug#4106176        */
--mrana     END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END validate_pick_drop_lpn;


END wms_pick_drop_pvt;

/
