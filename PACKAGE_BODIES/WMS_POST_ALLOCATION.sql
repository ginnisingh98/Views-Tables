--------------------------------------------------------
--  DDL for Package Body WMS_POST_ALLOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_POST_ALLOCATION" AS
/* $Header: WMSPRPAB.pls 120.0.12010000.9 2009/09/30 14:31:08 mitgupta noship $ */

  g_pkg_body_ver        CONSTANT VARCHAR2(100) := '$Header $';
  g_newline             CONSTANT VARCHAR2(10)  := fnd_global.newline;
  g_single_threaded     CONSTANT BOOLEAN       := FALSE;
  g_bulk_fetch_limit    CONSTANT NUMBER        := 1000;
  g_debug                        NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),0);
  g_num_workers                  NUMBER        := NVL(fnd_profile.value('WSH_PR_NUM_WORKERS'),1);

  g_assign_op_plans              BOOLEAN       := TRUE;
  g_call_cartonization           BOOLEAN       := TRUE;
  g_consolidate_tasks            BOOLEAN       := TRUE;
  g_assign_task_types            BOOLEAN       := TRUE;
  g_process_device_reqs          BOOLEAN       := TRUE;
  g_assign_pick_slips            BOOLEAN       := TRUE;
  g_plan_tasks                   BOOLEAN       := FALSE;
  g_print_labels                 BOOLEAN       := TRUE;


  TYPE t_num_tab IS TABLE OF NUMBER INDEX BY PLS_INTEGER;


  PROCEDURE print_debug
  ( p_msg      IN VARCHAR2
  , p_api_name IN VARCHAR2
  ) IS
  BEGIN
    inv_log_util.trace
    ( p_message => p_msg
    , p_module  => g_pkg_name || '.' || p_api_name
    , p_level   => 9
    );
  END print_debug;



  PROCEDURE print_version_info IS
  BEGIN
    print_debug ('Spec::  ' || g_pkg_spec_ver, 'print_version_info');
    print_debug ('Body::  ' || g_pkg_body_ver, 'print_version_info');
  END print_version_info;



  --
  -- This API divides MMTT into sub-batches and inserts records into
  -- WMS_PR_WORKERS, one for each sub-batch.
  --
  PROCEDURE create_sub_batches
  ( p_organization_id   IN    NUMBER
  , p_mo_header_id      IN    NUMBER
  , p_batch_id          IN    NUMBER
  , p_mode              IN    VARCHAR2
  , x_return_status     OUT   NOCOPY   VARCHAR2
  , x_num_sub_batches   OUT   NOCOPY   NUMBER
  ) IS
    l_api_name         VARCHAR2(30) := 'create_sub_batches';
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);

    l_sub_batch_id     NUMBER;
    l_num_sub_batches  NUMBER       := 0;
    l_detail_count     NUMBER       := 0;

    -- Tables used for bulk processing
    l_counts    t_num_tab;
    l_itm_ids   t_num_tab;
    l_sub_ids   t_num_tab;
    l_crt_ids   t_num_tab;
    l_tmp_ids   t_num_tab;

    -- Cursor to fetch cartonization IDs for label printing
    CURSOR c_wpr_carton_labels (p_mo_hdr_id NUMBER) IS
    SELECT COUNT(*)  l_num_rows
         , mmtt.cartonization_id
      FROM mtl_material_transactions_temp   mmtt
     WHERE mmtt.move_order_header_id = p_mo_hdr_id
       AND mmtt.cartonization_id IS NOT NULL
     GROUP BY mmtt.cartonization_id;

    -- Cursor to fetch temp IDs for case pick labels
    CURSOR c_wpr_casepick_labels (p_mo_hdr_id NUMBER) IS
    -- Non-bulk tasks
    SELECT mmtt.transaction_temp_id
      FROM mtl_material_transactions_temp   mmtt
     WHERE mmtt.move_order_header_id = p_mo_hdr_id
       AND mmtt.parent_line_id IS NULL
       AND EXISTS
         ( SELECT 'x'
             FROM wms_user_task_type_attributes   wutta
            WHERE wutta.organization_id = mmtt.organization_id
              AND wutta.user_task_type_id = mmtt.standard_operation_id
              AND wutta.honor_case_pick_flag = 'Y'
         )
    UNION ALL
    -- Bulk pick parent tasks
    SELECT mmtt.transaction_temp_id
      FROM mtl_material_transactions_temp   mmtt
     WHERE mmtt.transaction_temp_id IN
         ( SELECT DISTINCT mmtt2.parent_line_id
             FROM mtl_material_transactions_temp   mmtt2
            WHERE mmtt2.move_order_header_id = p_mo_hdr_id
              AND mmtt2.parent_line_id IS NOT NULL
              AND mmtt2.transaction_temp_id <> mmtt2.parent_line_id
         )
       AND EXISTS
         ( SELECT 'x'
             FROM wms_user_task_type_attributes   wutta
            WHERE wutta.organization_id = mmtt.organization_id
              AND wutta.user_task_type_id = mmtt.standard_operation_id
              AND wutta.honor_case_pick_flag = 'Y'
         );

    -- Op plan assignment: fetch unique item IDs across all records
    CURSOR c_wpr_opa (p_mo_hdr_id NUMBER) IS
    SELECT COUNT(*)   l_num_rows
         , mmtt.inventory_item_id
      FROM mtl_material_transactions_temp   mmtt
     WHERE mmtt.move_order_header_id = p_mo_hdr_id
     GROUP BY mmtt.inventory_item_id;

    -- Task type assignment: fetch unique item IDs from
    -- bulk pick parent tasks and non-bulk tasks
    CURSOR c_wpr_tta (p_mo_hdr_id NUMBER) IS
    SELECT COUNT(*)   l_num_rows
         , mmtt.inventory_item_id
      FROM mtl_material_transactions_temp   mmtt
     WHERE ( mmtt.move_order_header_id = p_mo_hdr_id
             AND mmtt.parent_line_id IS NULL)
        OR ( mmtt.transaction_temp_id IN
             ( SELECT DISTINCT mmtt2.parent_line_id
                 FROM mtl_material_transactions_temp   mmtt2
                WHERE mmtt2.move_order_header_id = p_mo_hdr_id
                  AND mmtt2.parent_line_id IS NOT NULL
                  AND mmtt2.transaction_temp_id <> mmtt2.parent_line_id
             )
           )
     GROUP BY mmtt.inventory_item_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT cr_sub_batch_sp;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline                  ||
                    'p_organization_id => '     || TO_CHAR(p_organization_id) || g_newline ||
                    'p_mo_header_id => '        || TO_CHAR(p_mo_header_id)    || g_newline ||
                    'p_batch_id => '            || TO_CHAR(p_batch_id)        || g_newline ||
                    'p_mode => '                || p_mode
                  , l_api_name);
    END IF;

    -- If type is LABEL, create sub-batches to print carton labels
    -- and case pick labels
    IF p_mode = 'LABEL' THEN --{
       OPEN c_wpr_carton_labels(p_mo_header_id);

       LOOP --{
          FETCH c_wpr_carton_labels BULK COLLECT
           INTO l_counts, l_crt_ids LIMIT g_bulk_fetch_limit;

          EXIT WHEN l_crt_ids.COUNT = 0;

          FORALL ii IN l_crt_ids.FIRST..l_crt_ids.LAST
             INSERT INTO wms_pr_workers( batch_id
                                       , worker_mode
                                       , processed_flag
                                       , organization_id
                                       , mo_header_id
                                       , cartonization_id
                                       , detailed_count
                                       )
             VALUES ( p_batch_id
                    , 'CRTN_LBL'       -- Carton label
                    , 'N'
                    , p_organization_id
                    , p_mo_header_id
                    , l_crt_ids(ii)
                    , l_counts(ii)
                    );

          l_num_sub_batches := l_num_sub_batches + l_crt_ids.COUNT;

       END LOOP; --}

       IF c_wpr_carton_labels%ISOPEN THEN
          CLOSE c_wpr_carton_labels;
       END IF;

       IF g_debug = 1 THEN
          print_debug( 'Inserted ' || l_num_sub_batches ||
                       ' worker records for cartonization label printing.'
                     , l_api_name);
       END IF;

       OPEN c_wpr_casepick_labels(p_mo_header_id);

       LOOP --{
          FETCH c_wpr_casepick_labels BULK COLLECT
           INTO l_tmp_ids LIMIT 500;

          EXIT WHEN l_tmp_ids.COUNT = 0;

          l_detail_count := l_tmp_ids.COUNT;

          INSERT INTO wms_pr_workers( batch_id
                                    , worker_mode
                                    , processed_flag
                                    , organization_id
                                    , mo_header_id
                                    , transaction_batch_id
                                    , detailed_count
                                    )
          VALUES ( p_batch_id
                 , 'CSPK_LBL'       -- Case pick label
                 , 'N'
                 , p_organization_id
                 , p_mo_header_id
                 , mtl_material_transactions_s.nextval
                 , l_detail_count
                 )
          RETURNING transaction_batch_id INTO l_sub_batch_id;

          l_num_sub_batches := l_num_sub_batches + 1;

          FORALL ii IN l_tmp_ids.FIRST..l_tmp_ids.LAST
             UPDATE mtl_material_transactions_temp   mmtt
                SET mmtt.transaction_batch_id = l_sub_batch_id
              WHERE mmtt.transaction_temp_id = l_tmp_ids(ii);

       END LOOP; --}

       IF c_wpr_casepick_labels%ISOPEN THEN
          CLOSE c_wpr_casepick_labels;
       END IF;

       IF g_debug = 1 THEN
          print_debug('Total number of worker records for label printing: '
                      || l_num_sub_batches, l_api_name);
       END IF;
    --}
    ELSIF p_mode IN ('OPA','TTA') THEN --{
       IF p_mode = 'OPA' THEN
          OPEN c_wpr_opa(p_mo_header_id);
       ELSE
          OPEN c_wpr_tta(p_mo_header_id);
       END IF;

       LOOP --{
          IF p_mode = 'OPA' THEN
             FETCH c_wpr_opa BULK COLLECT
              INTO l_counts, l_itm_ids LIMIT g_bulk_fetch_limit;
          ELSE
             FETCH c_wpr_tta BULK COLLECT
              INTO l_counts, l_itm_ids LIMIT g_bulk_fetch_limit;
          END IF;

          EXIT WHEN l_itm_ids.COUNT = 0;

          FORALL ii IN l_itm_ids.FIRST..l_itm_ids.LAST
             INSERT INTO wms_pr_workers( batch_id
                                       , worker_mode
                                       , processed_flag
                                       , organization_id
                                       , mo_header_id
                                       , transaction_batch_id
                                       , detailed_count
                                       )
             VALUES ( p_batch_id
                    , p_mode
                    , 'N'
                    , p_organization_id
                    , p_mo_header_id
                    , mtl_material_transactions_s.nextval
                    , l_counts(ii)
                    )
             RETURNING transaction_batch_id BULK COLLECT INTO l_sub_ids;

          l_num_sub_batches := l_num_sub_batches + l_itm_ids.COUNT;

          FORALL jj IN l_sub_ids.FIRST..l_sub_ids.LAST
             UPDATE mtl_material_transactions_temp   mmtt
                SET mmtt.transaction_batch_id = l_sub_ids(jj)
              WHERE mmtt.inventory_item_id = l_itm_ids(jj)
                AND ( ( mmtt.move_order_header_id = p_mo_header_id
                        AND mmtt.parent_line_id IS NULL)
                    OR ( p_mode = 'TTA'
                         AND mmtt.transaction_temp_id IN
                         ( SELECT DISTINCT mmtt2.parent_line_id
                             FROM mtl_material_transactions_temp   mmtt2
                            WHERE mmtt2.move_order_header_id = p_mo_header_id
                              AND mmtt2.parent_line_id IS NOT NULL
                              AND mmtt2.transaction_temp_id <> mmtt2.parent_line_id
                         )
                       )
                    );
       END LOOP; --}

       IF p_mode = 'OPA' AND c_wpr_opa%ISOPEN THEN
          CLOSE c_wpr_opa;
       ELSIF c_wpr_tta%ISOPEN THEN
          CLOSE c_wpr_tta;
       END IF;

       IF g_debug = 1 THEN
          print_debug('Done inserting worker records for ' || p_mode, l_api_name);
       END IF;
    --}
    ELSE --{
       IF g_debug = 1 THEN
          print_debug('Invalid worker type: ' || p_mode, l_api_name);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF; --}

    IF g_debug = 1 THEN
       print_debug('Number of sub-batches: ' || l_num_sub_batches, l_api_name);
    END IF;
    x_num_sub_batches := l_num_sub_batches;

    COMMIT;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO cr_sub_batch_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );
      IF g_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;
      IF c_wpr_carton_labels%ISOPEN THEN
         CLOSE c_wpr_carton_labels;
      END IF;
      IF c_wpr_casepick_labels%ISOPEN THEN
         CLOSE c_wpr_casepick_labels;
      END IF;
      IF c_wpr_opa%ISOPEN THEN
         CLOSE c_wpr_opa;
      END IF;
      IF c_wpr_tta%ISOPEN THEN
         CLOSE c_wpr_tta;
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO cr_sub_batch_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;
      IF c_wpr_carton_labels%ISOPEN THEN
         CLOSE c_wpr_carton_labels;
      END IF;
      IF c_wpr_casepick_labels%ISOPEN THEN
         CLOSE c_wpr_casepick_labels;
      END IF;
      IF c_wpr_opa%ISOPEN THEN
         CLOSE c_wpr_opa;
      END IF;
      IF c_wpr_tta%ISOPEN THEN
         CLOSE c_wpr_tta;
      END IF;
  END create_sub_batches;



  --
  -- This API submits concurrent requests for operation plan assignment,
  -- task type assignment and label printing.
  --
  PROCEDURE spawn_workers
  ( p_batch_id          IN    NUMBER
  , p_mode              IN    VARCHAR2
  , p_num_workers       IN    NUMBER
  , p_wsh_status        IN    VARCHAR2
  , p_auto_pick_confirm IN    VARCHAR2
  , x_return_status     OUT   NOCOPY   VARCHAR2
  ) IS
    l_api_name     VARCHAR2(30) := 'spawn_workers';
    l_msg_count    NUMBER;
    l_msg_data     VARCHAR2(2000);

    l_sub_request  BOOLEAN      := TRUE;
    l_request_id   NUMBER;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    -- Need to pause the parent request if doing operation plan assignment,
    -- task type assignment, or label printing with auto-pick-confirm = Y
    IF (p_mode = 'LABEL' AND p_auto_pick_confirm = 'Y')
       OR (p_mode <> 'LABEL') THEN
       l_sub_request := TRUE;
       IF g_debug = 1 THEN
          print_debug ('Sub request is TRUE.', l_api_name);
       END IF;
    ELSE
       l_sub_request := FALSE;
       IF g_debug = 1 THEN
          print_debug ('Sub request is FALSE.', l_api_name);
       END IF;
    END IF;

    FOR ii IN 1..p_num_workers LOOP -- {
        IF g_debug = 1 THEN
           print_debug ('Submitting worker #: ' || ii, l_api_name);
        END IF;
        l_request_id :=
          FND_REQUEST.Submit_Request( application => 'WMS'
                                    , program     => 'WMSPALOC_SUB'
                                    , description => ''
                                    , start_time  => ''
                                    , sub_request => l_sub_request
                                    , argument1   => p_batch_id
                                    , argument2   => p_mode
                                    , argument3   => ii     -- Worker ID
                                    );
        IF l_request_id = 0 THEN
           IF g_debug = 1 THEN
              print_debug( 'Request submission failed for worker ' || ii
                          , l_api_name);
           END IF;
           RAISE fnd_api.g_exc_unexpected_error;
        ELSE
           IF g_debug = 1 THEN
              print_debug( 'Request ' || l_request_id ||
                           ' submitted successfully' , l_api_name);
           END IF;
        END IF;
    END LOOP; --}

    IF l_sub_request THEN

       IF g_debug = 1 THEN
          print_debug ('Setting Parent Request to pause' , l_api_name);
       END IF;

       FND_CONC_GLOBAL.Set_Req_Globals( Conc_Status  => 'PAUSED'
                                      , Request_Data => p_batch_id   ||':'||
                                                        p_wsh_status ||':'||
                                                        p_mode);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );
      IF g_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;
  END spawn_workers;



  PROCEDURE assign_operation_plans
  ( p_organization_id      IN    NUMBER
  , p_mo_header_id         IN    NUMBER
  , p_batch_id             IN    NUMBER
  , p_num_workers          IN    NUMBER
  , p_create_sub_batches   IN    VARCHAR2
  , p_wsh_status           IN    VARCHAR2
  , x_return_status        OUT   NOCOPY   VARCHAR2
  ) IS
    l_api_name           VARCHAR2(30) := 'assign_operation_plans';
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_dummy              VARCHAR2(1);
    l_rule_exists        BOOLEAN := FALSE;
    l_api_return_status  VARCHAR2(1);
    l_op_plan_id         NUMBER;
    l_num_sub_batches    NUMBER;

    CURSOR c_opa_rule_exists (p_org_id NUMBER) IS
    SELECT 'x' FROM dual
     WHERE EXISTS
         ( SELECT 'x'
             FROM wms_rules       rules
                , wms_op_plans_b  wop
            WHERE rules.organization_id IN (p_org_id,-1)
              AND rules.type_code      = 7
              AND rules.enabled_flag   = 'Y'
              AND rules.type_hdr_id    = wop.operation_plan_id
              AND wop.activity_type_id = 2  -- Outbound
              AND wop.enabled_flag     = 'Y'
         );

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT op_plan_assign_sp;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline ||
                    'p_organization_id => '     || TO_CHAR(p_organization_id) || g_newline ||
                    'p_mo_header_id => '        || TO_CHAR(p_mo_header_id)    || g_newline ||
                    'p_batch_id => '            || TO_CHAR(p_batch_id)        || g_newline ||
                    'p_num_workers => '         || TO_CHAR(p_num_workers)     || g_newline ||
                    'p_create_sub_batches => '  || p_create_sub_batches       || g_newline ||
                    'p_wsh_status => '          || p_wsh_status
                  , l_api_name);
    END IF;

    OPEN c_opa_rule_exists (p_organization_id);
    FETCH c_opa_rule_exists INTO l_dummy;
    IF c_opa_rule_exists%FOUND THEN
       l_rule_exists := TRUE;
    END IF;
    CLOSE c_opa_rule_exists;

    IF l_rule_exists THEN --{
       IF g_debug = 1 THEN
          print_debug('OP plan rules exist, spawning sub-requests', l_api_name);
       END IF;
       IF p_create_sub_batches = 'Y' THEN --{
          l_api_return_status := fnd_api.g_ret_sts_success;
          create_sub_batches
          ( p_organization_id => p_organization_id
          , p_mo_header_id    => p_mo_header_id
          , p_batch_id        => p_batch_id
          , p_mode            => 'OPA'
          , x_return_status   => l_api_return_status
          , x_num_sub_batches => l_num_sub_batches
          );

          IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
             IF g_debug = 1 THEN
                print_debug('Error status from create_sub_batches: '
                            || l_api_return_status, l_api_name);
             END IF;
             IF l_api_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             ELSE
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          END IF;
       END IF; --}

       l_api_return_status := fnd_api.g_ret_sts_success;
       spawn_workers
       ( p_batch_id          => p_batch_id
       , p_mode              => 'OPA'
       , p_num_workers       => LEAST(l_num_sub_batches,g_num_workers)
       , p_wsh_status        => p_wsh_status
       , p_auto_pick_confirm => 'N'
       , x_return_status     => l_api_return_status
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from spawn_workers: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
    --}
    ELSE
       -- If there is no operation plan selection rule enabled,
       -- stamp the org default outbound operation plan
       IF g_debug = 1 THEN
          print_debug('No OP plan rules exist, checking for default org plan', l_api_name);
       END IF;
       IF (inv_cache.set_org_rec(p_organization_id) ) THEN
          l_op_plan_id := NVL(inv_cache.org_rec.default_pick_op_plan_id,1);
       ELSE
          IF g_debug = 1 THEN
             print_debug ( 'Error setting cache for organization', l_api_name );
          END IF;
          RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF g_debug = 1 THEN
          print_debug ('l_op_plan_id value: ' || l_op_plan_id, l_api_name);
       END IF;

       UPDATE mtl_material_transactions_temp
       SET operation_plan_id = l_op_plan_id
       WHERE move_order_header_id = p_mo_header_id;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO op_plan_assign_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );
      IF g_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

      IF c_opa_rule_exists%ISOPEN THEN
         CLOSE c_opa_rule_exists;
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO op_plan_assign_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;

      IF c_opa_rule_exists%ISOPEN THEN
         CLOSE c_opa_rule_exists;
      END IF;

  END assign_operation_plans;



  PROCEDURE assign_task_types
  ( p_organization_id      IN    NUMBER
  , p_mo_header_id         IN    NUMBER
  , p_batch_id             IN    NUMBER
  , p_num_workers          IN    NUMBER
  , p_create_sub_batches   IN    VARCHAR2
  , p_wsh_status           IN    VARCHAR2
  , x_return_status        OUT   NOCOPY   VARCHAR2
  ) IS
    l_api_name           VARCHAR2(30) := 'assign_task_types';
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_dummy              VARCHAR2(1);
    l_rule_exists        BOOLEAN := FALSE;
    l_api_return_status  VARCHAR2(1);
    l_ttype_id           NUMBER;
    l_num_sub_batches    NUMBER;

    CURSOR c_tta_rule_exists (p_org_id  NUMBER) IS
    SELECT 'x' FROM dual
     WHERE EXISTS
         ( SELECT 'x'
             FROM wms_rules   rules
            WHERE rules.organization_id IN (p_org_id,-1)
              AND rules.type_code    = 3
              AND rules.enabled_flag = 'Y'
         );

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT ttype_assign_sp;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline ||
                    'p_organization_id => '     || TO_CHAR(p_organization_id) || g_newline ||
                    'p_mo_header_id => '        || TO_CHAR(p_mo_header_id)    || g_newline ||
                    'p_batch_id => '            || TO_CHAR(p_batch_id)        || g_newline ||
                    'p_num_workers => '         || TO_CHAR(p_num_workers)     || g_newline ||
                    'p_create_sub_batches => '  || p_create_sub_batches       || g_newline ||
                    'p_wsh_status => '          || p_wsh_status
                  , l_api_name);
    END IF;

    OPEN c_tta_rule_exists (p_organization_id);
    FETCH c_tta_rule_exists INTO l_dummy;
    IF c_tta_rule_exists%FOUND THEN
       l_rule_exists := TRUE;
    END IF;
    CLOSE c_tta_rule_exists;

    IF l_rule_exists THEN --{
       IF g_debug = 1 THEN
          print_debug('Task type rules exist, spawning sub-requests', l_api_name);
       END IF;
       l_num_sub_batches := g_num_workers;
       IF p_create_sub_batches = 'Y' THEN --{
          l_api_return_status := fnd_api.g_ret_sts_success;
          create_sub_batches
          ( p_organization_id => p_organization_id
          , p_mo_header_id    => p_mo_header_id
          , p_batch_id        => p_batch_id
          , p_mode            => 'TTA'
          , x_return_status   => l_api_return_status
          , x_num_sub_batches => l_num_sub_batches
          );

          IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
             IF g_debug = 1 THEN
                print_debug('Error status from create_sub_batches: '
                            || l_api_return_status, l_api_name);
             END IF;
             IF l_api_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             ELSE
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          END IF;
       END IF; --}

       l_api_return_status := fnd_api.g_ret_sts_success;
       spawn_workers
       ( p_batch_id          => p_batch_id
       , p_mode              => 'TTA'
       , p_num_workers       => LEAST(l_num_sub_batches,g_num_workers)
       , p_wsh_status        => p_wsh_status
       , p_auto_pick_confirm => 'N'
       , x_return_status     => l_api_return_status
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from spawn_workers: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
    --}
    ELSE
       -- If there is no task type assignment rule enabled,
       -- stamp the org default picking task type
       IF g_debug = 1 THEN
          print_debug('No task type rules exist, checking for default org task type', l_api_name);
       END IF;
       IF (inv_cache.set_org_rec(p_organization_id) ) THEN
          l_ttype_id := inv_cache.org_rec.default_pick_task_type_id;
       ELSE
          IF g_debug = 1 THEN
             print_debug ( 'Error setting cache for organization', l_api_name );
          END IF;
          RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF g_debug = 1 THEN
          print_debug ('l_ttype_id value: ' || l_ttype_id, l_api_name);
       END IF;

       UPDATE mtl_material_transactions_temp
       SET standard_operation_id = l_ttype_id
       WHERE move_order_header_id = p_mo_header_id;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO ttype_assign_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );
      IF g_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

      IF c_tta_rule_exists%ISOPEN THEN
         CLOSE c_tta_rule_exists;
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO ttype_assign_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;

      IF c_tta_rule_exists%ISOPEN THEN
         CLOSE c_tta_rule_exists;
      END IF;

  END assign_task_types;



  PROCEDURE print_labels
  ( p_organization_id      IN    NUMBER
  , p_mo_header_id         IN    NUMBER
  , p_batch_id             IN    NUMBER
  , p_num_workers          IN    NUMBER
  , p_auto_pick_confirm    IN    VARCHAR2
  , p_create_sub_batches   IN    VARCHAR2
  , p_wsh_status           IN    VARCHAR2
  , x_return_status        OUT   NOCOPY   VARCHAR2
  ) IS
    l_api_name           VARCHAR2(30) := 'print_labels';
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_dummy              VARCHAR2(1);
    l_call_lbl_prnt      BOOLEAN := FALSE;
    l_api_return_status  VARCHAR2(1);
    l_num_sub_batches    NUMBER;

    CURSOR c_lbl_data_exists IS
    SELECT 'x' FROM dual
     WHERE EXISTS
         ( SELECT 'x'
             FROM mtl_material_transactions_temp  mmtt1
            WHERE mmtt1.move_order_header_id = p_mo_header_id
              AND mmtt1.cartonization_id IS NOT NULL
         )
        OR EXISTS
         ( SELECT 'x'
             FROM mtl_material_transactions_temp  mmtt2
            WHERE mmtt2.move_order_header_id = p_mo_header_id
              AND EXISTS
                ( SELECT 'x'
                    FROM wms_user_task_type_attributes   wutta1
                   WHERE wutta1.organization_id = mmtt2.organization_id
                     AND wutta1.user_task_type_id = mmtt2.standard_operation_id
                     AND wutta1.honor_case_pick_flag = 'Y'
                )
         )
        OR EXISTS
         ( SELECT 'x'
             FROM mtl_material_transactions_temp  mmtt3
            WHERE mmtt3.transaction_temp_id IN
                ( SELECT DISTINCT mmtt4.parent_line_id
                    FROM mtl_material_transactions_temp   mmtt4
                   WHERE mmtt4.move_order_header_id = p_mo_header_id
                     AND mmtt4.parent_line_id IS NOT NULL
                     AND mmtt4.transaction_temp_id <> mmtt4.parent_line_id
                )
              AND EXISTS
                ( SELECT 'x'
                    FROM wms_user_task_type_attributes   wutta2
                   WHERE wutta2.organization_id = mmtt3.organization_id
                     AND wutta2.user_task_type_id = mmtt3.standard_operation_id
                     AND wutta2.honor_case_pick_flag = 'Y'
                )
         );

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT label_print_sp;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline ||
                    'p_organization_id => '     || TO_CHAR(p_organization_id) || g_newline ||
                    'p_mo_header_id => '        || TO_CHAR(p_mo_header_id)    || g_newline ||
                    'p_batch_id => '            || TO_CHAR(p_batch_id)        || g_newline ||
                    'p_num_workers => '         || TO_CHAR(p_num_workers)     || g_newline ||
                    'p_create_sub_batches => '  || p_create_sub_batches       || g_newline ||
                    'p_wsh_status => '          || p_wsh_status
                  , l_api_name);
    END IF;

    OPEN c_lbl_data_exists;
    FETCH c_lbl_data_exists INTO l_dummy;
    IF c_lbl_data_exists%FOUND THEN
       l_call_lbl_prnt := TRUE;
    END IF;
    CLOSE c_lbl_data_exists;

    IF l_call_lbl_prnt THEN --{
       IF g_debug = 1 THEN
          print_debug('Label data exists, spawning sub-requests', l_api_name);
       END IF;
       l_num_sub_batches := g_num_workers;
       IF p_create_sub_batches = 'Y' THEN --{
          l_api_return_status := fnd_api.g_ret_sts_success;
          create_sub_batches
          ( p_organization_id => p_organization_id
          , p_mo_header_id    => p_mo_header_id
          , p_batch_id        => p_batch_id
          , p_mode            => 'LABEL'
          , x_return_status   => l_api_return_status
          , x_num_sub_batches => l_num_sub_batches
          );

          IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
             IF g_debug = 1 THEN
                print_debug('Error status from create_sub_batches: '
                            || l_api_return_status, l_api_name);
             END IF;
             IF l_api_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             ELSE
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          END IF;
       END IF; --}

       l_api_return_status := fnd_api.g_ret_sts_success;
       spawn_workers
       ( p_batch_id          => p_batch_id
       , p_mode              => 'LABEL'
       , p_num_workers       => LEAST(l_num_sub_batches,g_num_workers)
       , p_wsh_status        => p_wsh_status
       , p_auto_pick_confirm => p_auto_pick_confirm
       , x_return_status     => l_api_return_status
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from spawn_workers: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
    --}
    ELSE
       IF g_debug = 1 THEN
          print_debug('No label printing data exists', l_api_name);
       END IF;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO label_print_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );
      IF g_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

      IF c_lbl_data_exists%ISOPEN THEN
         CLOSE c_lbl_data_exists;
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO label_print_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;

      IF c_lbl_data_exists%ISOPEN THEN
         CLOSE c_lbl_data_exists;
      END IF;

  END print_labels;



  -- Invoked by the post-allocation child concurrent request (WMSPALOC_SUB)
  PROCEDURE process_sub_request
  ( errbuf              OUT   NOCOPY   VARCHAR2
  , retcode             OUT   NOCOPY   NUMBER
  , p_batch_id          IN    NUMBER
  , p_mode              IN    VARCHAR2
  , p_worker_id         IN    NUMBER
  ) IS
    l_api_name           VARCHAR2(30) := 'process_sub_request';
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_api_return_status  VARCHAR2(1);
    l_conc_ret_status    BOOLEAN;
    l_error_message      VARCHAR2(2000);

  BEGIN
    retcode := 0;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline           ||
                    'p_batch_id => '            || TO_CHAR(p_batch_id) || g_newline ||
                    'p_mode => '                || p_mode              || g_newline ||
                    'p_worker_id => '           || TO_CHAR(p_worker_id)
                  , l_api_name);
    END IF;

    l_api_return_status := fnd_api.g_ret_sts_success;
    IF p_mode = 'OPA' THEN
       WMS_POSTALLOC_PVT.assign_operation_plans
       ( p_batch_id      => p_batch_id
       , x_return_status => l_api_return_status
       );
    ELSIF p_mode = 'TTA' THEN
       WMS_POSTALLOC_PVT.assign_task_types
       ( p_batch_id      => p_batch_id
       , x_return_status => l_api_return_status
       );
    ELSIF p_mode = 'LABEL' THEN
       WMS_POSTALLOC_PVT.print_labels
       ( p_batch_id      => p_batch_id
       , x_return_status => l_api_return_status
       );
    ELSE
       IF g_debug = 1 THEN
          print_debug('Invalid worker type: ' || p_mode, l_api_name);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF g_debug = 1 THEN
          print_debug('Error status from WMS_POSTALLOC_PVT API: '
                      || l_api_return_status, l_api_name);
       END IF;
       IF l_api_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSE
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    END IF;

    l_conc_ret_status := fnd_concurrent.set_completion_status('NORMAL','');
    IF NOT l_conc_ret_status THEN
       IF g_debug = 1 THEN
          print_debug('Error setting concurrent return status to NORMAL', l_api_name);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );
      IF g_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

      l_conc_ret_status := fnd_concurrent.set_completion_status('ERROR', l_msg_data);
      retcode := 2;
      errbuf  := l_msg_data;

    WHEN OTHERS THEN
      l_error_message := SQLERRM;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || l_error_message, l_api_name);
      END IF;

      l_conc_ret_status := fnd_concurrent.set_completion_status('ERROR', l_error_message);
      retcode := 2;
      errbuf  := l_error_message;
  END process_sub_request;



  PROCEDURE cleanup_sub_batches
  ( p_org_id        IN  NUMBER
  , p_mo_header_id  IN  NUMBER
  , p_batch_id      IN  NUMBER
  ) IS
    l_api_name            VARCHAR2(30) := 'cleanup_sub_batches';

  BEGIN
    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline               ||
                    'p_org_id       => '        || TO_CHAR(p_org_id)       || g_newline ||
                    'p_mo_header_id => '        || TO_CHAR(p_mo_header_id)
                  , l_api_name);
    END IF;

    UPDATE mtl_material_transactions_temp
       SET transaction_batch_id = NULL
       , lock_flag = NULL  -- newly added
     WHERE move_order_header_id = p_mo_header_id;

    IF g_consolidate_tasks THEN
       UPDATE mtl_material_transactions_temp
          SET transaction_batch_id = NULL
        WHERE transaction_temp_id IN
            ( SELECT DISTINCT mmtt2.parent_line_id
                FROM mtl_material_transactions_temp  mmtt2
               WHERE move_order_header_id = p_mo_header_id
                 AND parent_line_id IS NOT NULL
            );
    END IF;

    DELETE wms_pr_workers
     WHERE batch_id = p_batch_id
       AND organization_id = p_org_id;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;
  END cleanup_sub_batches;



  PROCEDURE release_tasks
  ( p_mo_header_id   IN          NUMBER
  , x_return_status  OUT NOCOPY  VARCHAR2
  ) IS
    l_api_name            VARCHAR2(30) := 'release_tasks';
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT task_release_sp;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline               ||
                    'p_mo_header_id => '        || TO_CHAR(p_mo_header_id)
                  , l_api_name);
    END IF;

    UPDATE mtl_material_transactions_temp
       SET wms_task_status = 1
     WHERE move_order_header_id = p_mo_header_id;

    IF g_consolidate_tasks THEN
       UPDATE mtl_material_transactions_temp
          SET wms_task_status = 1
        WHERE transaction_temp_id IN
            ( SELECT DISTINCT mmtt2.parent_line_id
                FROM mtl_material_transactions_temp  mmtt2
               WHERE move_order_header_id = p_mo_header_id
                 AND parent_line_id IS NOT NULL
            );
    END IF;

    COMMIT;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      ROLLBACK TO task_release_sp;
      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );
      IF g_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO task_release_sp;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;

  END release_tasks;



  -- Entry point for post-allocation processing APIs
  PROCEDURE launch
  ( p_organization_id      IN    NUMBER
  , p_mo_header_id         IN    NUMBER
  , p_batch_id             IN    NUMBER
  , p_num_workers          IN    NUMBER
  , p_auto_pick_confirm    IN    VARCHAR2
  , p_wsh_status           IN    VARCHAR2
  , p_wsh_mode             IN    VARCHAR2
  , p_grouping_rule_id     IN    NUMBER
  , p_allow_partial_pick   IN    VARCHAR2
  , p_plan_tasks           IN    VARCHAR2
  , x_return_status        OUT   NOCOPY   VARCHAR2
  , x_org_complete         OUT   NOCOPY   VARCHAR2
  ) IS
    l_api_name            VARCHAR2(30) := 'launch';
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);

    l_api_return_status   VARCHAR2(1);
    l_create_sub_batches  VARCHAR2(1);
    l_do_post_alloc       NUMBER := NVL(FND_PROFILE.VALUE('WMS_ASSIGN_TASK_TYPE'),1);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    x_org_complete  := 'N';

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline                   ||
                    'p_organization_id => '     || TO_CHAR(p_organization_id)  || g_newline ||
                    'p_mo_header_id => '        || TO_CHAR(p_mo_header_id)     || g_newline ||
                    'p_batch_id => '            || TO_CHAR(p_batch_id)         || g_newline ||
                    'p_num_workers => '         || TO_CHAR(p_num_workers)      || g_newline ||
                    'p_auto_pick_confirm => '   || p_auto_pick_confirm         || g_newline ||
                    'p_wsh_status => '          || p_wsh_status                || g_newline ||
                    'p_wsh_mode => '            || p_wsh_mode                  || g_newline ||
                    'p_grouping_rule_id => '    || TO_CHAR(p_grouping_rule_id) || g_newline ||
                    'p_allow_partial_pick => '  || p_allow_partial_pick        || g_newline ||
                    'p_plan_tasks => '          || p_plan_tasks
                  , l_api_name);
    END IF;

    -- Validations
    IF p_organization_id IS NULL OR
       p_mo_header_id    IS NULL OR
       p_batch_id        IS NULL
    THEN
       IF g_debug = 1 THEN
          print_debug('Required input is missing.', l_api_name);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF p_plan_tasks = 'Y' THEN
       g_plan_tasks := TRUE;
    END IF;

    --
    -- Run single-threaded post-allocation if needed.
    -- Device Integration as well as Label Printing for Pick Release
    -- business flow will not work if doing parallel pick release and
    -- single-threaded post-allocation.  This problem has existed
    -- since base R12.
    --
    IF g_single_threaded   OR
       p_wsh_mode IS NULL  OR
       p_num_workers < 2
    THEN --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       inv_pick_release_pub.call_cartonization
       ( p_api_version          => 1.0
       , p_init_msg_list        => FND_API.G_FALSE
       , p_commit               => FND_API.G_FALSE
       , p_validation_level     => FND_API.G_VALID_LEVEL_FULL
       , p_out_bound            => 'Y'
       , p_org_id               => p_organization_id
       , p_move_order_header_id => p_mo_header_id
       , p_grouping_rule_id     => p_grouping_rule_id
       , p_allow_partial_pick   => FND_API.G_TRUE
       , x_return_status        => l_api_return_status
       , x_msg_count            => l_msg_count
       , x_msg_data             => l_msg_data
       );
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from call_cartonization: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

       IF NOT g_plan_tasks THEN
          l_api_return_status := fnd_api.g_ret_sts_success;
          release_tasks
          ( p_mo_header_id  => p_mo_header_id
          , x_return_status => l_api_return_status
          );
          IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
             IF g_debug = 1 THEN
                print_debug('Error status from release_tasks: '
                            || l_api_return_status, l_api_name);
             END IF;
             IF l_api_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             ELSE
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          END IF;
       END IF;

       x_org_complete := 'Y';
       GOTO END_POST_ALLOC;
    END IF; --}

    -- If doing auto-pick-confirm or if the profile "WMS: Assign Task Types"
    -- is set to NO, turn off everything except pick slip numbering
    IF p_auto_pick_confirm = 'Y' OR l_do_post_alloc <> 1 THEN
       g_assign_op_plans     := FALSE;
       g_call_cartonization  := FALSE;
       g_consolidate_tasks   := FALSE;
       g_assign_task_types   := FALSE;
       g_process_device_reqs := FALSE;
       g_assign_pick_slips   := TRUE;
       g_plan_tasks          := FALSE;  -- Over-rides p_plan_tasks
       g_print_labels        := FALSE;
    END IF;

    -- Multi threaded execution: Operation Plan assignment (OPA)
    IF g_assign_op_plans AND p_wsh_mode IN ('PICK-SS','PICK') THEN --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       assign_operation_plans
       ( p_organization_id    => p_organization_id
       , p_mo_header_id       => p_mo_header_id
       , p_batch_id           => p_batch_id
       , p_num_workers        => p_num_workers
       , p_create_sub_batches => 'Y'
       , p_wsh_status         => p_wsh_status
       , x_return_status      => l_api_return_status
       );
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from assign_operation_plans: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
       --
       -- Op plan assignment is parallelized, so skip to the end.
       -- Conc. req. is PAUSED until the child requests finish.
       --
       GOTO END_POST_ALLOC;
    END IF; --}

    -- Cartonization: single threaded, starts after OPA child requests finish
    IF g_call_cartonization AND p_wsh_mode IN ('PICK-SS','PICK','OPA') THEN --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       wms_postalloc_pvt.cartonize
       ( p_org_id               => p_organization_id
       , p_move_order_header_id => p_mo_header_id
       , x_return_status        => l_api_return_status
       );
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from wms_postalloc_pvt.cartonize: '
                         || l_api_return_status, l_api_name);
          END IF;
          -- Continue processing even if cartonization fails
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             -- RAISE fnd_api.g_exc_error;
             NULL;
          ELSE
             -- RAISE fnd_api.g_exc_unexpected_error;
             NULL;
          END IF;
       END IF;
    END IF; --}

    -- Task consolidation: single threaded
    IF g_consolidate_tasks AND p_wsh_mode IN ('PICK-SS','PICK','OPA') THEN --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       wms_postalloc_pvt.consolidate_tasks
       ( p_mo_header_id      => p_mo_header_id
       , x_return_status     => l_api_return_status
       );
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from wms_postalloc_pvt.consolidate_tasks: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
    END IF; --}

    -- Task Type assignment (TTA): multi-threaded
    IF g_assign_task_types AND p_wsh_mode IN ('PICK-SS','PICK','OPA') THEN --{
       IF p_wsh_mode = 'OPA' THEN
          l_create_sub_batches := 'N';
       ELSE
          l_create_sub_batches := 'Y';
       END IF;
       l_api_return_status := fnd_api.g_ret_sts_success;
       assign_task_types
       ( p_organization_id    => p_organization_id
       , p_mo_header_id       => p_mo_header_id
       , p_batch_id           => p_batch_id
       , p_num_workers        => p_num_workers
       , p_create_sub_batches => l_create_sub_batches
       , p_wsh_status         => p_wsh_status
       , x_return_status      => l_api_return_status
       );
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from assign_task_types: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
       -- Skip to end, and PAUSE.
       GOTO END_POST_ALLOC;
    END IF; --}

    --
    -- Resume from here after TTA child requests are complete
    --

    -- Device integration: single threaded
    IF g_process_device_reqs AND p_wsh_mode IN ('PICK-SS','PICK','OPA','TTA') THEN --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       wms_postalloc_pvt.insert_device_requests
       ( p_organization_id   => p_organization_id
       , p_mo_header_id      => p_mo_header_id
       , x_return_status     => l_api_return_status
       );
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from wms_postalloc_pvt.insert_device_requests: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
    END IF; --}

    -- Pick slip number assignment: single threaded
    IF g_assign_pick_slips AND p_wsh_mode IN ('PICK-SS','PICK','OPA','TTA') THEN --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       wms_postalloc_pvt.assign_pick_slip_numbers
       ( p_organization_id   => p_organization_id
       , p_mo_header_id      => p_mo_header_id
       , p_grouping_rule_id  => p_grouping_rule_id
       , x_return_status     => l_api_return_status
       );
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from wms_postalloc_pvt.assign_pick_slip_numbers: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
    END IF; --}

    -- Clear transaction_batch_id column on MMTT,
    -- delete WPR records
    cleanup_sub_batches
    ( p_org_id       => p_organization_id
    , p_mo_header_id => p_mo_header_id
    , p_batch_id     => p_batch_id
    );

    -- Release tasks: single threaded
    IF NOT g_plan_tasks AND p_wsh_mode IN ('PICK-SS','PICK','OPA','TTA') THEN --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       release_tasks
       ( p_mo_header_id  => p_mo_header_id
       , x_return_status => l_api_return_status
       );
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from release_tasks: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
    END IF; --}

    -- Label printing: multi-threaded.  Parent process is paused
    -- only if we are doing auto-pick-confirm
    IF g_print_labels AND p_wsh_mode IN ('PICK-SS','PICK','OPA','TTA') THEN --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       print_labels
       ( p_organization_id    => p_organization_id
       , p_mo_header_id       => p_mo_header_id
       , p_batch_id           => p_batch_id
       , p_num_workers        => p_num_workers
       , p_auto_pick_confirm  => p_auto_pick_confirm
       , p_create_sub_batches => 'Y'
       , p_wsh_status         => p_wsh_status
       , x_return_status      => l_api_return_status
       );
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from print_labels: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
       IF p_auto_pick_confirm = 'Y' THEN
          GOTO END_POST_ALLOC;
       END IF;
    END IF; --}

    --
    -- Set org completion flag to 'Y' after all processing completes
    -- to let Shipping know that the next org can be processed.
    -- Whenever we spawn child requests for OPA, TTA, etc., org_complete
    -- remains as 'N' and we skip to the part after END_POST_ALLOC
    --
    x_org_complete  := 'Y';

    <<END_POST_ALLOC>>
    COMMIT;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );
      IF g_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

      cleanup_sub_batches
      ( p_org_id       => p_organization_id
      , p_mo_header_id => p_mo_header_id
      , p_batch_id     => p_batch_id
      );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;

      cleanup_sub_batches
      ( p_org_id       => p_organization_id
      , p_mo_header_id => p_mo_header_id
      , p_batch_id     => p_batch_id
      );

  END launch;



  -- Concurrent processing wrapper for post-allocation processing APIs
  -- when running post-allocation standalone (outside of pick release)
  PROCEDURE process_post_allocation
  ( errbuf                 OUT   NOCOPY   VARCHAR2
  , retcode                OUT   NOCOPY   NUMBER
  , p_pickrel_batch        IN             VARCHAR2
  , p_organization_id      IN             NUMBER
  , p_assign_op_plans      IN             NUMBER
  , p_call_cartonization   IN             NUMBER
  , p_consolidate_tasks    IN             NUMBER
  , p_assign_task_types    IN             NUMBER
  , p_process_device_reqs  IN             NUMBER
  , p_assign_pick_slips    IN             NUMBER
  , p_plan_tasks           IN             NUMBER
  , p_print_labels         IN             NUMBER
  , p_wave_simulation_mode IN             VARCHAR2
  ) IS
    l_api_name              VARCHAR2(30) := 'process_post_allocation';
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

    l_api_return_status     VARCHAR2(1);
    l_conc_ret_status       BOOLEAN;
    l_error_message         VARCHAR2(2000);
    l_batch_id              NUMBER;
    l_mo_header_id          NUMBER;
    l_auto_pick_confirm     VARCHAR2(1);
    l_grouping_rule_id      NUMBER;
    l_request_data          VARCHAR2(30);
    l_mode                  VARCHAR2(30);
    l_wsh_status            VARCHAR2(10);
    l_plan_tasks            VARCHAR2(1) := 'N';
    l_org_complete          VARCHAR2(1);
    l_dummy                 VARCHAR2(1);
    l_bulk_tasks_exist      BOOLEAN;

    l_child_task_id         t_num_tab;
    l_parent_task_id        t_num_tab;
    l_lot_control_code      t_num_tab;
    l_serial_control_code   t_num_tab;

    plan_wave_error BOOLEAN := FALSE;

    CURSOR c_existing_bulk_tasks (p_mo_header_id NUMBER) IS
    SELECT mmtt.transaction_temp_id
         , mmtt.parent_line_id
         , msi.lot_control_code
         , msi.serial_number_control_code
      FROM mtl_material_transactions_temp  mmtt
         , mtl_system_items                msi
     WHERE mmtt.move_order_header_id = p_mo_header_id
       AND mmtt.parent_line_id IS NOT NULL
       AND msi.inventory_item_id = mmtt.inventory_item_id
       AND msi.organization_id   = mmtt.organization_id;

  BEGIN
    retcode := 0;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline                      ||
                    'p_pickrel_batch => '       || p_pickrel_batch                || g_newline ||
                    'p_organization_id => '     || TO_CHAR(p_organization_id)     || g_newline ||
                    'p_assign_op_plans => '     || TO_CHAR(p_assign_op_plans)     || g_newline ||
                    'p_call_cartonization => '  || TO_CHAR(p_call_cartonization)  || g_newline ||
                    'p_consolidate_tasks => '   || TO_CHAR(p_consolidate_tasks)   || g_newline ||
                    'p_assign_task_types => '   || TO_CHAR(p_assign_task_types)   || g_newline ||
                    'p_process_device_reqs => ' || TO_CHAR(p_process_device_reqs) || g_newline ||
                    'p_assign_pick_slips => '   || TO_CHAR(p_assign_pick_slips)   || g_newline ||
                    'p_plan_tasks => '          || TO_CHAR(p_plan_tasks)          || g_newline ||
                    'p_print_labels => '        || TO_CHAR(p_print_labels)        || g_newline ||
		    'p_wave_simulation_mode => '|| p_wave_simulation_mode
                  , l_api_name);
    END IF;

    -- Do not allow standalone post-allocation processing in single-threaded mode
    IF g_num_workers < 2 THEN
	IF p_wave_simulation_mode = 'Y' THEN
		g_num_workers := 3;
       ELSE
		IF g_debug = 1 THEN
			print_debug('Invalid number of workers: ' || g_num_workers, l_api_name);
		END IF;
       fnd_message.set_name('WMS', 'WMS_PALOC_PARALLEL_ONLY');  -- TBD
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
       END IF;
    END IF;

    IF p_assign_op_plans = 2 THEN
       g_assign_op_plans := FALSE;
    END IF;

    IF p_call_cartonization = 2 THEN
       g_call_cartonization := FALSE;
    END IF;

    IF p_consolidate_tasks = 2 THEN
       g_consolidate_tasks := FALSE;
    END IF;

    IF p_assign_task_types = 2 THEN
       g_assign_task_types := FALSE;
    END IF;

    IF p_process_device_reqs = 2 THEN
       g_process_device_reqs := FALSE;
    END IF;

    IF p_assign_pick_slips = 2 THEN
       g_assign_pick_slips := FALSE;
    END IF;

    IF p_plan_tasks = 1 THEN
       g_plan_tasks := TRUE;
       l_plan_tasks := 'Y';
    END IF;

    IF p_print_labels = 2 THEN
       g_print_labels := FALSE;
    END IF;

    -- Shipping's format of Request_Data is 'Batch_id:Request_Status:Mode'
    l_request_data := FND_CONC_GLOBAL.Request_Data;
    l_wsh_status   := SUBSTR( l_request_data
                            , INSTR(l_request_data,':',1,1) + 1
                            , 1);
    l_mode         := SUBSTR( l_request_data
                            , INSTR(l_request_data,':',1,2) + 1
                            , LENGTH(l_request_data));

    IF g_debug = 1 THEN
       print_debug('l_request_data: ' || l_request_data || g_newline ||
                   'l_mode: '         || l_mode         || g_newline ||
                   'l_wsh_status: '   || l_wsh_status
                  , l_api_name);
    END IF;

    BEGIN
       SELECT mtrh.header_id
            , mtrh.grouping_rule_id
            , DECODE(mp.mo_pick_confirm_required,1,'N','Y')
         INTO l_mo_header_id
            , l_grouping_rule_id
            , l_auto_pick_confirm
         FROM mtl_txn_request_headers  mtrh
            , mtl_parameters           mp
        WHERE mtrh.request_number  = p_pickrel_batch
          AND mtrh.organization_id = p_organization_id
          AND mtrh.move_order_type = inv_globals.g_move_order_pick_wave
          AND mp.organization_id   = p_organization_id;
    EXCEPTION
       WHEN OTHERS THEN
          IF g_debug = 1 THEN
             print_debug ('Error fetching MO header and Org attributes: '
                         || l_error_message, l_api_name);
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
    END;

    l_batch_id := TO_NUMBER(p_pickrel_batch);
    IF g_debug = 1 THEN
       print_debug('l_mo_header_id: '      || TO_CHAR(l_mo_header_id)     || g_newline ||
                   'l_batch_id: '          || TO_CHAR(l_batch_id)         || g_newline ||
                   'l_grouping_rule_id: '  || TO_CHAR(l_grouping_rule_id) || g_newline ||
                   'l_auto_pick_confirm: ' || l_auto_pick_confirm
                  , l_api_name);
    END IF;

    IF l_mode IS NULL AND g_debug = 1 THEN
       print_version_info;
    END IF;

/*  -- Check for conflicts with other running programs
    IF l_mode IS NULL THEN --{
       BEGIN
          SELECT 'x' INTO l_dummy
            FROM dual
           WHERE EXISTS
               ( SELECT 'x'
                   FROM wms_pr_workers
                  WHERE organization_id = p_organization_id
                    AND (batch_id = l_batch_id
                        OR worker_mode = 'WMSBLKPR')
               );
          IF g_debug = 1 THEN
             print_debug('Other running program(s) found, so return error', l_api_name);
          END IF;
          fnd_message.set_name('WMS', 'WMS_PALOC_OTHER_PROG');  -- TBD
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               IF g_debug = 1 THEN
                  print_debug('No conflicting programs found, so proceeding', l_api_name);
               END IF;
          WHEN fnd_api.g_exc_error THEN
               RAISE fnd_api.g_exc_error;
          WHEN OTHERS THEN
               IF g_debug = 1 THEN
                  print_debug( 'Error checking for conc program conflicts: ' || SQLERRM
                             , l_api_name);
               END IF;
               RAISE fnd_api.g_exc_unexpected_error;
       END;
    END IF; --}
*/
    IF l_mode IS NULL THEN --{
       -- Verify that unreleased tasks exist
       BEGIN
          SELECT 'x' INTO l_dummy
            FROM dual
           WHERE EXISTS
               ( SELECT 'x'
                   FROM mtl_material_transactions_temp
                  WHERE move_order_header_id = l_mo_header_id
                    AND wms_task_status = 8  -- Unreleased
               );
          IF g_debug = 1 THEN
             print_debug('Unreleased tasks exist, so proceed', l_api_name);
          END IF;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               IF g_debug = 1 THEN
                  print_debug('No unreleased tasks exist', l_api_name);
               END IF;
	       IF p_wave_simulation_mode = 'Y' THEN
		  IF g_debug = 1 THEN
                  print_debug('Running for Wave Planning. Concurrent request completion status will be normal only', l_api_name);
               END IF;
                  plan_wave_error := TRUE;
               END IF;
               fnd_message.set_name('WMS', 'WMS_PALOC_NO_UNREL_TASKS');  -- TBD
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
          WHEN OTHERS THEN
               IF g_debug = 1 THEN
                  print_debug( 'Error when checking for unreleased tasks: ' || SQLERRM
                             , l_api_name);
               END IF;
               RAISE fnd_api.g_exc_unexpected_error;
       END;

       -- Verify there are no released tasks
       BEGIN
          SELECT 'x' INTO l_dummy
            FROM dual
           WHERE EXISTS
               ( SELECT 'x'
                   FROM mtl_material_transactions_temp
                  WHERE move_order_header_id = l_mo_header_id
                    AND wms_task_status = 1  -- Released
               );
          IF g_debug = 1 THEN
             print_debug('Released tasks exist, so return error', l_api_name);
          END IF;
          fnd_message.set_name('WMS', 'WMS_PALOC_RLSD_TASK');  -- TBD
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               IF g_debug = 1 THEN
                  print_debug('No released tasks, proceed', l_api_name);
               END IF;
          WHEN fnd_api.g_exc_error THEN
               RAISE fnd_api.g_exc_error;
          WHEN OTHERS THEN
               IF g_debug = 1 THEN
                  print_debug( 'Error when checking for released tasks: ' || SQLERRM
                             , l_api_name);
               END IF;
               RAISE fnd_api.g_exc_unexpected_error;
       END;
    END IF; --}

    --
    -- If first time, and bulk picking is turned on,
    -- delete pre-existing bulk pick suggestions
    --
    IF l_mode IS NULL AND g_consolidate_tasks THEN --{
       l_bulk_tasks_exist := FALSE;
       BEGIN
          SELECT 'x' INTO l_dummy FROM dual
           WHERE EXISTS
               ( SELECT 'x' FROM mtl_material_transactions_temp
                  WHERE move_order_header_id = l_mo_header_id
                    AND parent_line_id IS NOT NULL
               );
          l_bulk_tasks_exist := TRUE;
          IF g_debug = 1 THEN
             print_debug('Found existing bulk pick suggestions, deleting..', l_api_name);
          END IF;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN NULL;
          WHEN OTHERS THEN
             IF (g_debug = 1) THEN
                print_debug( 'Other error when checking if bulk tasks already exist: '
                             || sqlerrm, l_api_name );
             END IF;
             RAISE fnd_api.g_exc_unexpected_error;
       END;

       IF l_bulk_tasks_exist THEN --{
          OPEN c_existing_bulk_tasks(l_mo_header_id);
          LOOP --{
             FETCH c_existing_bulk_tasks BULK COLLECT INTO
                   l_child_task_id
                 , l_parent_task_id
                 , l_lot_control_code
                 , l_serial_control_code LIMIT g_bulk_fetch_limit;

             EXIT WHEN l_child_task_id.COUNT = 0;

             FORALL ll IN l_child_task_id.FIRST .. l_child_task_id.LAST
                UPDATE mtl_material_transactions_temp
                   SET parent_line_id = NULL
                 WHERE transaction_temp_id = l_child_task_id(ll);

             FOR ii IN l_child_task_id.FIRST .. l_child_task_id.LAST LOOP --{
                 l_api_return_status := fnd_api.g_ret_sts_success;
                 inv_trx_util_pub.update_parent_mmtt
                 ( x_return_status       => l_api_return_status
                 , p_parent_line_id      => l_parent_task_id(ii)
                 , p_child_line_id       => l_child_task_id(ii)
                 , p_lot_control_code    => l_lot_control_code(ii)
                 , p_serial_control_code => l_serial_control_code(ii)
                 );
                 IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
                    IF g_debug = 1 THEN
                       print_debug('Error status from inv_trx_util_pub.update_parent_mmtt: '
                                   || l_api_return_status, l_api_name);
                    END IF;
                    IF l_api_return_status = fnd_api.g_ret_sts_error THEN
                       RAISE fnd_api.g_exc_error;
                    ELSE
                       RAISE fnd_api.g_exc_unexpected_error;
                    END IF;
                 END IF;
             END LOOP; --}
          END LOOP; --}
          l_lot_control_code.DELETE;
          l_serial_control_code.DELETE;
       END IF; --}

       COMMIT;
    END IF; --}

    --
    -- If first time, and cartonization is turned on,
    -- delete pre-existing cartonization suggestions
    --
    IF l_mode IS NULL AND g_call_cartonization THEN --{
       UPDATE mtl_material_transactions_temp
          SET cartonization_id  = NULL
            , container_item_id = NULL
        WHERE move_order_header_id = l_mo_header_id
          AND cartonization_id IS NOT NULL;

       IF g_debug = 1 and SQL%ROWCOUNT > 0 THEN
          print_debug('Cleared existing cartonization suggestions', l_api_name);
       END IF;

       -- This is required because of the unique index WMS_PACKAGING_HIST_U1
       -- (header_id + sequence_id + packaging_mode)
       DELETE wms_packaging_hist
        WHERE header_id = l_mo_header_id
          AND packaging_mode = wms_cartnzn_pub.pr_pkg_mode;

       IF g_debug = 1 and SQL%ROWCOUNT > 0 THEN
          print_debug('Cleared WMS_PACKAGING_HIST records', l_api_name);
       END IF;

       COMMIT;
    END IF; --}

    l_api_return_status := fnd_api.g_ret_sts_success;
    launch
    ( p_organization_id    => p_organization_id
    , p_mo_header_id       => l_mo_header_id
    , p_batch_id           => l_batch_id
    , p_num_workers        => g_num_workers
    , p_auto_pick_confirm  => l_auto_pick_confirm
    , p_wsh_status         => NVL(l_wsh_status,'0')
    , p_wsh_mode           => NVL(l_mode,'PICK')
    , p_grouping_rule_id   => l_grouping_rule_id
    , p_allow_partial_pick => fnd_api.g_true
    , p_plan_tasks         => l_plan_tasks
    , x_return_status      => l_api_return_status
    , x_org_complete       => l_org_complete
    );
    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF g_debug = 1 THEN
          print_debug('Error status from launch: '
                      || l_api_return_status, l_api_name);
       END IF;
       IF l_api_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSE
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );
      IF g_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

      IF plan_wave_error = FALSE THEN
	      l_conc_ret_status := fnd_concurrent.set_completion_status('ERROR', l_msg_data);
	      retcode := 2;
	      errbuf  := l_msg_data;
      end if;

    WHEN OTHERS THEN
      l_error_message := SQLERRM;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || l_error_message, l_api_name);
      END IF;

      l_conc_ret_status := fnd_concurrent.set_completion_status('ERROR', l_error_message);
      retcode := 2;
      errbuf  := l_error_message;
  END process_post_allocation;

END wms_post_allocation;

/
