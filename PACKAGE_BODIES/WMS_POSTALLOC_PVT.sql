--------------------------------------------------------
--  DDL for Package Body WMS_POSTALLOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_POSTALLOC_PVT" AS
/* $Header: WMSVPRPB.pls 120.1.12010000.9 2010/03/09 01:18:26 sfulzele noship $*/

  g_pkg_body_ver           CONSTANT  VARCHAR2(100) := '$Header $';
  g_newline                CONSTANT  VARCHAR2(10)  := fnd_global.newline;
  g_bulk_fetch_limit       CONSTANT  NUMBER        := 1000;
  g_debug                            NUMBER        := NVL(fnd_profile.value('INV_DEBUG_TRACE'),0);
  g_user_id                CONSTANT  NUMBER        := fnd_global.user_id;
  g_hash_base                        NUMBER        := 1;
  g_hash_size                        NUMBER        := POWER(2, 25);


  TYPE tbl_num          IS TABLE OF  NUMBER        INDEX BY PLS_INTEGER;
  TYPE tbl_varchar1     IS TABLE OF  VARCHAR2(1)   INDEX BY PLS_INTEGER;
  TYPE tbl_varchar3     IS TABLE OF  VARCHAR2(3)   INDEX BY PLS_INTEGER;
  TYPE tbl_varchar10    IS TABLE OF  VARCHAR2(10)  INDEX BY PLS_INTEGER;
  TYPE tbl_varchar50    IS TABLE OF  VARCHAR2(50)  INDEX BY PLS_INTEGER;
  TYPE tbl_date         IS TABLE OF  DATE          INDEX BY PLS_INTEGER;


  -- Op plan, task type assignment
  g_opa_org_id                       NUMBER        := -1;
  g_opa_rule_exists                  BOOLEAN       := TRUE;
  g_tta_org_id                       NUMBER        := -1;
  g_tta_rule_exists                  BOOLEAN       := TRUE;

  TYPE t_rule_id        IS TABLE OF  wms_rules.rule_id%TYPE;
  TYPE t_type_hdr_id    IS TABLE OF  wms_rules.type_hdr_id%TYPE;
  g_t_opa_rule_id                    t_rule_id;
  g_t_opa_type_hdr_id                t_type_hdr_id;
  g_t_tta_rule_id                    t_rule_id;
  g_t_tta_type_hdr_id                t_type_hdr_id;


  -- Pick slip numbering
  TYPE grprectyp IS RECORD(
    grouping_rule_id                 NUMBER
  , use_order_ps                     VARCHAR2(1)   := 'N'
  , use_customer_ps                  VARCHAR2(1)   := 'N'
  , use_ship_to_ps                   VARCHAR2(1)   := 'N'
  , use_carrier_ps                   VARCHAR2(1)   := 'N'
  , use_ship_priority_ps             VARCHAR2(1)   := 'N'
  , use_trip_stop_ps                 VARCHAR2(1)   := 'N'
  , use_delivery_ps                  VARCHAR2(1)   := 'N'
  , use_src_sub_ps                   VARCHAR2(1)   := 'N'
  , use_src_locator_ps               VARCHAR2(1)   := 'N'
  , use_item_ps                      VARCHAR2(1)   := 'N'
  , use_revision_ps                  VARCHAR2(1)   := 'N'
  , use_lot_ps                       VARCHAR2(1)   := 'N'
  , use_jobsch_ps                    VARCHAR2(1)   := 'N'
  , use_oper_seq_ps                  VARCHAR2(1)   := 'N'
  , use_dept_ps                      VARCHAR2(1)   := 'N'
  , use_supply_type_ps               VARCHAR2(1)   := 'N'
  , use_supply_sub_ps                VARCHAR2(1)   := 'N'
  , use_supply_loc_ps                VARCHAR2(1)   := 'N'
  , use_project_ps                   VARCHAR2(1)   := 'N'
  , use_task_ps                      VARCHAR2(1)   := 'N'
  , pick_method                      VARCHAR2(30)  := '-99');

  g_ps_rule_rec                      grprectyp;

  g_cluster_pick_method    CONSTANT  VARCHAR2(1)   := '3';


  -- Device integration
  g_device_level_none      CONSTANT  NUMBER        := 0;
  g_device_level_org       CONSTANT  NUMBER        := 100;
  g_device_level_sub       CONSTANT  NUMBER        := 200;
  g_device_level_locator   CONSTANT  NUMBER        := 300;
  g_device_level_user      CONSTANT  NUMBER        := 400;
  g_wms_be_pick_release    CONSTANT  NUMBER        := 11;

  g_dev_tbl                          tbl_num;
  g_org_tbl                          tbl_num;
  g_sub_tbl                          tbl_varchar10;
  g_loc_tbl                          tbl_num;
  g_user_tbl                         tbl_num;


  -- Task splitting
  g_from_uom_code_tbl                tbl_varchar3;
  g_to_uom_code_tbl                  tbl_varchar3;
  g_from_to_uom_ratio_tbl            tbl_num;
  g_item_tbl                         tbl_num;

  g_hash_split_org_tbl               tbl_num;
  g_hash_split_inv_item_id_tbl       tbl_num;
  g_hash_split_std_op_id_tbl         tbl_num;
  g_hash_split_fac_tbl               tbl_num;

  g_eqp_org_id                       NUMBER        := -1;
  g_eqp_vol_uom                      tbl_varchar3;
  g_eqp_wt_uom                       tbl_varchar3;
  g_eqp_weight                       tbl_num;
  g_eqp_volume                       tbl_num;



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



  PROCEDURE print_version_info
    IS
  BEGIN
    print_debug ('Spec::  ' || g_pkg_spec_ver, 'print_version_info');
    print_debug ('Body::  ' || g_pkg_body_ver, 'print_version_info');
  END print_version_info;



  -- Fetches and locks the next record in wms_pr_workers table
  -- for a given batch and worker type
  PROCEDURE fetch_next_wpr_rec
  ( p_batch_id          IN    NUMBER
  , p_mode              IN    VARCHAR2
  , x_wpr_rec           OUT   NOCOPY   wms_pr_workers%ROWTYPE
  , x_return_status     OUT   NOCOPY   VARCHAR2
  ) IS

    l_api_name       VARCHAR2(30) := 'fetch_next_wpr_rec';
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);

    l_wpr_rec        wms_pr_workers%ROWTYPE;
    l_return_status  VARCHAR2(1);
    l_row_id         ROWID;
    done             BOOLEAN := FALSE;

    record_locked_exc      EXCEPTION;
    PRAGMA EXCEPTION_INIT  (record_locked_exc, -54);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT fetch_wpr_sp;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline           ||
                    'p_batch_id => '            || TO_CHAR(p_batch_id) || g_newline ||
                    'p_mode => '                || p_mode
                  , l_api_name);
    END IF;

    LOOP --{
       EXIT WHEN done;
       BEGIN
          -- If a record is locked successfully, or if no data found,
          -- or if an unknown exception occurs, then exit the loop.
          -- If unable to lock one record, try another (continue looping).
          SELECT rowid INTO l_row_id
            FROM wms_pr_workers
           WHERE batch_id       = p_batch_id
             AND worker_mode    = p_mode
             AND processed_flag = 'N'
             AND rownum < 2
             FOR UPDATE NOWAIT;

          done := TRUE;

          UPDATE wms_pr_workers
             SET processed_flag = 'Y'
           WHERE rowid = l_row_id
          RETURNING batch_id
                  , worker_mode
                  , processed_flag
                  , organization_id
                  , mo_header_id
                  , transaction_batch_id
                  , cartonization_id
                  , detailed_count
               INTO l_wpr_rec;

          COMMIT;

          IF g_debug = 1 THEN
             print_debug
             ( 'Successfully locked a WPR row: ' || g_newline ||
             ' Org ID: '           || TO_CHAR(l_wpr_rec.organization_id)      || g_newline ||
             ' MO Header ID: '     || TO_CHAR(l_wpr_rec.mo_header_id)         || g_newline ||
             ' Txn batch ID: '     || TO_CHAR(l_wpr_rec.transaction_batch_id) || g_newline ||
             ' Cartonization ID: ' || TO_CHAR(l_wpr_rec.cartonization_id)     || g_newline ||
             ' Detailed count: '   || TO_CHAR(l_wpr_rec.detailed_count)
             , l_api_name
             );
          END IF;

       EXCEPTION
          WHEN record_locked_exc THEN
             IF g_debug = 1 THEN
                print_debug ('Record locked', l_api_name);
             END IF;
             done := FALSE;
          WHEN NO_DATA_FOUND THEN
             IF g_debug = 1 THEN
                print_debug ('No more records', l_api_name);
             END IF;
             x_return_status := 'N';
             done := TRUE;
          WHEN OTHERS THEN
             IF g_debug = 1 THEN
                print_debug ('Other error: ' || SQLERRM, l_api_name);
             END IF;
             done := TRUE;
             RAISE fnd_api.g_exc_unexpected_error;
       END;

    END LOOP; --}

    IF x_return_status = fnd_api.g_ret_sts_success THEN
       x_wpr_rec := l_wpr_rec;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO fetch_wpr_sp;
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
      ROLLBACK TO fetch_wpr_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;

  END fetch_next_wpr_rec;



  PROCEDURE assign_op_plan
  ( p_transaction_batch_id    IN             NUMBER
  , p_organization_id         IN             NUMBER
  , x_return_status           OUT  NOCOPY    VARCHAR2
  ) IS

    l_api_name           VARCHAR2(30) := 'assign_op_plan';
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_return_status      NUMBER;
    l_op_plan_id         NUMBER;
    l_rule_applied       BOOLEAN;

    l_mmtt_temp_id  tbl_num;
    l_mmtt_hid      tbl_num;

    CURSOR c_mmtt_cursor (p_txn_batch_id NUMBER) IS
    SELECT transaction_temp_id
      FROM mtl_material_transactions_temp
     WHERE transaction_batch_id = p_txn_batch_id;

  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: '  || g_newline               ||
                    'p_transaction_batch_id => ' || p_transaction_batch_id  || g_newline ||
                    'p_organization_id => '      || p_organization_id       || g_newline
                  , l_api_name);
    END IF;

    -- Bulk fetch applicable rule IDs (only if first time or org changed)
    IF g_opa_org_id <> p_organization_id THEN
       g_opa_org_id := p_organization_id;
       BEGIN
          SELECT rules.rule_id, rules.type_hdr_id BULK COLLECT
            INTO g_t_opa_rule_id, g_t_opa_type_hdr_id
            FROM wms_rules       rules
               , wms_op_plans_b  wop
           WHERE rules.organization_id IN (g_opa_org_id,-1)
             AND rules.type_code      = 7
             AND rules.enabled_flag   = 'Y'
             AND rules.type_hdr_id    = wop.operation_plan_id
             AND wop.activity_type_id = 2  -- Outbound
             AND wop.enabled_flag     = 'Y'
           ORDER BY rules.rule_weight DESC, rules.creation_date;

           g_opa_rule_exists := TRUE;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               g_opa_rule_exists := FALSE;
       END ;
    END IF;

    -- If there is at least one operation plan selection rule enabled
    IF g_opa_rule_exists THEN --{
       OPEN c_mmtt_cursor(p_transaction_batch_id);

       LOOP --{
          FETCH c_mmtt_cursor BULK COLLECT
           INTO l_mmtt_temp_id LIMIT g_bulk_fetch_limit;
          EXIT WHEN l_mmtt_temp_id.COUNT = 0;

          FOR ii IN l_mmtt_temp_id.FIRST .. l_mmtt_temp_id.LAST LOOP --{
              l_rule_applied := FALSE;

              FOR jj IN g_t_opa_rule_id.FIRST .. g_t_opa_rule_id.LAST LOOP --{
                  wms_rule_pvt.execute_op_rule( g_t_opa_rule_id(jj), l_mmtt_temp_id(ii), l_return_status);

                  IF l_return_status > 0 THEN
                     l_mmtt_hid(ii) := g_t_opa_type_hdr_id(jj);
                     l_rule_applied := TRUE;
                     EXIT;
                  END IF;
              END LOOP; --}

              -- If no Operation Plan rule gets applied,
              -- stamp the org default outbound operation plan
              IF ( l_rule_applied <> TRUE ) THEN
                 IF ( inv_cache.set_org_rec( p_organization_id ) ) THEN
                    l_mmtt_hid(ii) := NVL(inv_cache.org_rec.default_pick_op_plan_id,1);
                 ELSE
                    IF g_debug = 1 THEN
                       print_debug ( 'Error setting cache for organization', l_api_name );
                    END IF;
                    RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
              END IF ;

              IF g_debug = 1 THEN
                 print_debug ('Temp ID: ' || l_mmtt_temp_id(ii) || ', op plan assigned: '
                                          || l_mmtt_hid(ii), l_api_name);
              END IF;
          END LOOP; --}

          -- Bulk update operation_plan_id in all the MMTTs with cached values
          FORALL kk IN l_mmtt_temp_id.FIRST .. l_mmtt_temp_id.LAST
             UPDATE mtl_material_transactions_temp
             SET operation_plan_id = l_mmtt_hid(kk)
             WHERE transaction_temp_id = l_mmtt_temp_id(kk);

       END LOOP; --}

       IF c_mmtt_cursor%ISOPEN THEN
          CLOSE c_mmtt_cursor;
       END IF;
    --}
    ELSE --{
       -- If there is no operation plan selection rule enabled,
       -- stamp the org default outbound operation plan
       IF (inv_cache.set_org_rec(p_organization_id) ) THEN
          l_op_plan_id := NVL(inv_cache.org_rec.default_pick_op_plan_id,1);
       ELSE
          IF g_debug = 1 THEN
             print_debug('Error setting cache for organization', l_api_name);
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       IF g_debug = 1 THEN
          print_debug ('No operation plan rules defined', l_api_name);
          print_debug ('l_op_plan_id value: ' || l_op_plan_id, l_api_name);
       END IF;

       UPDATE mtl_material_transactions_temp
       SET operation_plan_id = l_op_plan_id
       WHERE transaction_batch_id = p_transaction_batch_id;
    END IF; --}

    UPDATE wms_pr_workers
    SET worker_mode = 'TTA', processed_flag = 'N'
    WHERE transaction_batch_id = p_transaction_batch_id;

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

       IF c_mmtt_cursor%ISOPEN THEN
          CLOSE c_mmtt_cursor;
       END IF;

    WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       IF g_debug = 1 THEN
          print_debug ('Other error: ' || SQLERRM, l_api_name);
       END IF;

       IF c_mmtt_cursor%ISOPEN THEN
          CLOSE c_mmtt_cursor;
       END IF;
  END assign_op_plan;



  PROCEDURE assign_operation_plans
  ( p_batch_id          IN    NUMBER
  , x_return_status     OUT   NOCOPY   VARCHAR2
  ) IS
    l_api_name           VARCHAR2(30) := 'assign_operation_plans';
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_wpr_rec            wms_pr_workers%ROWTYPE;
    l_api_return_status  VARCHAR2(1);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline ||
                    'p_batch_id => '            || TO_CHAR(p_batch_id)
                  , l_api_name);
    END IF;

    LOOP --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       fetch_next_wpr_rec
       ( p_batch_id      => p_batch_id
       , p_mode          => 'OPA'
       , x_wpr_rec       => l_wpr_rec
       , x_return_status => l_api_return_status
       );

       IF l_api_return_status = 'N' THEN
          IF g_debug = 1 THEN
             print_debug ( 'No more records in WPR', l_api_name );
          END IF;
          EXIT;
       ELSIF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from fetch_next_wpr_rec: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

       l_api_return_status := fnd_api.g_ret_sts_success;
       assign_op_plan
       ( p_transaction_batch_id => l_wpr_rec.transaction_batch_id
       , p_organization_id      => l_wpr_rec.organization_id
       , x_return_status        => l_api_return_status
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from assign_op_plan: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
    END LOOP;

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

  END assign_operation_plans;



  -- Insert all the mmtt records for a move order header id
  -- into wms_cartonization_temp
  PROCEDURE create_wct
  ( p_move_order_header_id  IN          NUMBER
  , x_return_status         OUT NOCOPY  VARCHAR2
  ) IS

    l_api_name   VARCHAR2(30) := 'create_wct';
    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(2000);

  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;

     SAVEPOINT create_wct_sp;

     IF g_debug = 1 THEN
        print_debug( 'Entered with parameters: '  || g_newline              ||
                     'p_move_order_header_id => ' || p_move_order_header_id
                   , l_api_name);
     END IF;

-- Checking if the caller is 'TRP' (i.e) from Task Release then
-- cartonization_id can be null as well so removing the condition

if g_caller = 'TRP' THEN

	   INSERT INTO wms_cartonization_temp(
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
          , overcompletion_transaction_qty
          , overcompletion_primary_qty
          , overcompletion_transaction_id
          , end_item_unit_number
          , scheduled_payback_date
          , line_type_code
          , parent_transaction_temp_id
          , put_away_strategy_id
          , put_away_rule_id
          , pick_strategy_id
          , pick_rule_id
          , move_order_line_id
          , task_group_id
          , pick_slip_number
          , reservation_id
          , common_bom_seq_id
          , common_routing_seq_id
          , org_cost_group_id
          , cost_type_id
          , transaction_status
          , standard_operation_id
          , task_priority
          , wms_task_type
          , parent_line_id
          , source_lot_number
          , transfer_cost_group_id
          , lpn_id
          , transfer_lpn_id
          , wms_task_status
          , content_lpn_id
          , container_item_id
          , cartonization_id
          , pick_slip_date
          , rebuild_item_id
          , rebuild_serial_number
          , rebuild_activity_id
          , rebuild_job_name
          , organization_type
          , transfer_organization_type
          , owning_organization_id
          , owning_tp_type
          , xfr_owning_organization_id
          , transfer_owning_tp_type
          , planning_organization_id
          , planning_tp_type
          , xfr_planning_organization_id
          , transfer_planning_tp_type
          , secondary_uom_code
          , secondary_transaction_quantity
          , allocated_lpn_id
          , schedule_number
          , scheduled_flag
          , class_code
          , schedule_group
          , build_sequence
          , bom_revision
          , routing_revision
          , bom_revision_date
          , routing_revision_date
          , alternate_bom_designator
          , alternate_routing_designator
          , transaction_batch_id
          , transaction_batch_seq
          , operation_plan_id
          , intransit_account
          , fob_point
          , logical_trx_type_code
          , move_order_header_id
          , original_transaction_temp_id
          , serial_allocated_flag
          , trx_flow_header_id
          )
     SELECT mmtt.transaction_header_id
          , mmtt.transaction_temp_id
          , mmtt.source_code
          , mmtt.source_line_id
          , mmtt.transaction_mode
          , mmtt.lock_flag
          , mmtt.last_update_date
          , mmtt.last_updated_by
          , mmtt.creation_date
          , mmtt.created_by
          , mmtt.last_update_login
          , mmtt.request_id
          , mmtt.program_application_id
          , mmtt.program_id
          , mmtt.program_update_date
          , mmtt.inventory_item_id
          , mmtt.revision
          , mmtt.organization_id
          , mmtt.subinventory_code
          , mmtt.locator_id
          , mmtt.transaction_quantity
          , mmtt.primary_quantity
          , mmtt.transaction_uom
          , mmtt.transaction_cost
          , mmtt.transaction_type_id
          , mmtt.transaction_action_id
          , mmtt.transaction_source_type_id
          , mmtt.transaction_source_id
          , mmtt.transaction_source_name
          , mmtt.transaction_date
          , mmtt.acct_period_id
          , mmtt.distribution_account_id
          , mmtt.transaction_reference
          , mmtt.requisition_line_id
          , mmtt.requisition_distribution_id
          , mmtt.reason_id
          , mmtt.lot_number
          , mmtt.lot_expiration_date
          , mmtt.serial_number
          , mmtt.receiving_document
          , mmtt.demand_id
          , mmtt.rcv_transaction_id
          , mmtt.move_transaction_id
          , mmtt.completion_transaction_id
          , mmtt.wip_entity_type
          , mmtt.schedule_id
          , mmtt.repetitive_line_id
          , mmtt.employee_code
          , mmtt.primary_switch
          , mmtt.schedule_update_code
          , mmtt.setup_teardown_code
          , mmtt.item_ordering
          , mmtt.negative_req_flag
          , mmtt.operation_seq_num
          , mmtt.picking_line_id
          , mmtt.trx_source_line_id
          , mmtt.trx_source_delivery_id
          , mmtt.physical_adjustment_id
          , mmtt.cycle_count_id
          , mmtt.rma_line_id
          , mmtt.customer_ship_id
          , mmtt.currency_code
          , mmtt.currency_conversion_rate
          , mmtt.currency_conversion_type
          , mmtt.currency_conversion_date
          , mmtt.ussgl_transaction_code
          , mmtt.vendor_lot_number
          , mmtt.encumbrance_account
          , mmtt.encumbrance_amount
          , mmtt.ship_to_location
          , mmtt.shipment_number
          , mmtt.transfer_cost
          , mmtt.transportation_cost
          , mmtt.transportation_account
          , mmtt.freight_code
          , mmtt.containers
          , mmtt.waybill_airbill
          , mmtt.expected_arrival_date
          , mmtt.transfer_subinventory
          , mmtt.transfer_organization
          , mmtt.transfer_to_location
          , mmtt.new_average_cost
          , mmtt.value_change
          , mmtt.percentage_change
          , mmtt.material_allocation_temp_id
          , mmtt.demand_source_header_id
          , mmtt.demand_source_line
          , mmtt.demand_source_delivery
          , mmtt.item_segments
          , mmtt.item_description
          , mmtt.item_trx_enabled_flag
          , mmtt.item_location_control_code
          , mmtt.item_restrict_subinv_code
          , mmtt.item_restrict_locators_code
          , mmtt.item_revision_qty_control_code
          , mmtt.item_primary_uom_code
          , mmtt.item_uom_class
          , mmtt.item_shelf_life_code
          , mmtt.item_shelf_life_days
          , mmtt.item_lot_control_code
          , mmtt.item_serial_control_code
          , mmtt.item_inventory_asset_flag
          , mmtt.allowed_units_lookup_code
          , mmtt.department_id
          , mmtt.department_code
          , mmtt.wip_supply_type
          , mmtt.supply_subinventory
          , mmtt.supply_locator_id
          , mmtt.valid_subinventory_flag
          , mmtt.valid_locator_flag
          , mmtt.locator_segments
          , mmtt.current_locator_control_code
          , mmtt.number_of_lots_entered
          , mmtt.wip_commit_flag
          , mmtt.next_lot_number
          , mmtt.lot_alpha_prefix
          , mmtt.next_serial_number
          , mmtt.serial_alpha_prefix
          , mmtt.shippable_flag
          , mmtt.posting_flag
          , mmtt.required_flag
          , mmtt.process_flag
          , mmtt.error_code
          , mmtt.error_explanation
          , mmtt.attribute_category
          , mmtt.attribute1
          , mmtt.attribute2
          , mmtt.attribute3
          , mmtt.attribute4
          , mmtt.attribute5
          , mmtt.attribute6
          , mmtt.attribute7
          , mmtt.attribute8
          , mmtt.attribute9
          , mmtt.attribute10
          , mmtt.attribute11
          , mmtt.attribute12
          , mmtt.attribute13
          , mmtt.attribute14
          , mmtt.attribute15
          , mmtt.movement_id
          , mmtt.reservation_quantity
          , mmtt.shipped_quantity
          , mmtt.transaction_line_number
          , mmtt.task_id
          , mmtt.to_task_id
          , mmtt.source_task_id
          , mmtt.project_id
          , mmtt.source_project_id
          , mmtt.pa_expenditure_org_id
          , mmtt.to_project_id
          , mmtt.expenditure_type
          , mmtt.final_completion_flag
          , mmtt.transfer_percentage
          , mmtt.transaction_sequence_id
          , mmtt.material_account
          , mmtt.material_overhead_account
          , mmtt.resource_account
          , mmtt.outside_processing_account
          , mmtt.overhead_account
          , mmtt.flow_schedule
          , mmtt.cost_group_id
          , mmtt.demand_class
          , mmtt.qa_collection_id
          , mmtt.kanban_card_id
          , mmtt.overcompletion_transaction_qty
          , mmtt.overcompletion_primary_qty
          , mmtt.overcompletion_transaction_id
          , mmtt.end_item_unit_number
          , mmtt.scheduled_payback_date
          , mmtt.line_type_code
          , mmtt.parent_transaction_temp_id
          , mmtt.put_away_strategy_id
          , mmtt.put_away_rule_id
          , mmtt.pick_strategy_id
          , mmtt.pick_rule_id
          , mmtt.move_order_line_id
          , mmtt.task_group_id
          , mmtt.pick_slip_number
          , mmtt.reservation_id
          , mmtt.common_bom_seq_id
          , mmtt.common_routing_seq_id
          , mmtt.org_cost_group_id
          , mmtt.cost_type_id
          , mmtt.transaction_status
          , mmtt.standard_operation_id
          , mmtt.task_priority
          , mmtt.wms_task_type
          , mmtt.parent_line_id
          , mmtt.source_lot_number
          , mmtt.transfer_cost_group_id
          , mmtt.lpn_id
          , mmtt.transfer_lpn_id
          , mmtt.wms_task_status
          , mmtt.content_lpn_id
         , decode( g_pick_group_rule,'Y',decode(mmtt.container_item_id,-1,null,mmtt.container_item_id),mmtt.container_item_id)
          , mmtt.cartonization_id
          , mmtt.pick_slip_date
          , mmtt.rebuild_item_id
          , mmtt.rebuild_serial_number
          , mmtt.rebuild_activity_id
          , mmtt.rebuild_job_name
          , mmtt.organization_type
          , mmtt.transfer_organization_type
          , mmtt.owning_organization_id
          , mmtt.owning_tp_type
          , mmtt.xfr_owning_organization_id
          , mmtt.transfer_owning_tp_type
          , mmtt.planning_organization_id
          , mmtt.planning_tp_type
          , mmtt.xfr_planning_organization_id
          , mmtt.transfer_planning_tp_type
          , mmtt.secondary_uom_code
          , mmtt.secondary_transaction_quantity
          , mmtt.allocated_lpn_id
          , mmtt.schedule_number
          , mmtt.scheduled_flag
          , mmtt.class_code
          , mmtt.schedule_group
          , mmtt.build_sequence
          , mmtt.bom_revision
          , mmtt.routing_revision
          , mmtt.bom_revision_date
          , mmtt.routing_revision_date
          , mmtt.alternate_bom_designator
          , mmtt.alternate_routing_designator
          , mmtt.transaction_batch_id
          , mmtt.transaction_batch_seq
          , mmtt.operation_plan_id
          , mmtt.intransit_account
          , mmtt.fob_point
          , mmtt.logical_trx_type_code
          , mmtt.move_order_header_id
          , mmtt.original_transaction_temp_id
          , mmtt.serial_allocated_flag
          , mmtt.trx_flow_header_id
       FROM mtl_material_transactions_temp  mmtt
      WHERE mmtt.move_order_header_id = p_move_order_header_id;
      --  AND mmtt.container_item_id IS NULL;



ELSE

     INSERT INTO wms_cartonization_temp(
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
          , overcompletion_transaction_qty
          , overcompletion_primary_qty
          , overcompletion_transaction_id
          , end_item_unit_number
          , scheduled_payback_date
          , line_type_code
          , parent_transaction_temp_id
          , put_away_strategy_id
          , put_away_rule_id
          , pick_strategy_id
          , pick_rule_id
          , move_order_line_id
          , task_group_id
          , pick_slip_number
          , reservation_id
          , common_bom_seq_id
          , common_routing_seq_id
          , org_cost_group_id
          , cost_type_id
          , transaction_status
          , standard_operation_id
          , task_priority
          , wms_task_type
          , parent_line_id
          , source_lot_number
          , transfer_cost_group_id
          , lpn_id
          , transfer_lpn_id
          , wms_task_status
          , content_lpn_id
          , container_item_id
          , cartonization_id
          , pick_slip_date
          , rebuild_item_id
          , rebuild_serial_number
          , rebuild_activity_id
          , rebuild_job_name
          , organization_type
          , transfer_organization_type
          , owning_organization_id
          , owning_tp_type
          , xfr_owning_organization_id
          , transfer_owning_tp_type
          , planning_organization_id
          , planning_tp_type
          , xfr_planning_organization_id
          , transfer_planning_tp_type
          , secondary_uom_code
          , secondary_transaction_quantity
          , allocated_lpn_id
          , schedule_number
          , scheduled_flag
          , class_code
          , schedule_group
          , build_sequence
          , bom_revision
          , routing_revision
          , bom_revision_date
          , routing_revision_date
          , alternate_bom_designator
          , alternate_routing_designator
          , transaction_batch_id
          , transaction_batch_seq
          , operation_plan_id
          , intransit_account
          , fob_point
          , logical_trx_type_code
          , move_order_header_id
          , original_transaction_temp_id
          , serial_allocated_flag
          , trx_flow_header_id
          )
     SELECT mmtt.transaction_header_id
          , mmtt.transaction_temp_id
          , mmtt.source_code
          , mmtt.source_line_id
          , mmtt.transaction_mode
          , mmtt.lock_flag
          , mmtt.last_update_date
          , mmtt.last_updated_by
          , mmtt.creation_date
          , mmtt.created_by
          , mmtt.last_update_login
          , mmtt.request_id
          , mmtt.program_application_id
          , mmtt.program_id
          , mmtt.program_update_date
          , mmtt.inventory_item_id
          , mmtt.revision
          , mmtt.organization_id
          , mmtt.subinventory_code
          , mmtt.locator_id
          , mmtt.transaction_quantity
          , mmtt.primary_quantity
          , mmtt.transaction_uom
          , mmtt.transaction_cost
          , mmtt.transaction_type_id
          , mmtt.transaction_action_id
          , mmtt.transaction_source_type_id
          , mmtt.transaction_source_id
          , mmtt.transaction_source_name
          , mmtt.transaction_date
          , mmtt.acct_period_id
          , mmtt.distribution_account_id
          , mmtt.transaction_reference
          , mmtt.requisition_line_id
          , mmtt.requisition_distribution_id
          , mmtt.reason_id
          , mmtt.lot_number
          , mmtt.lot_expiration_date
          , mmtt.serial_number
          , mmtt.receiving_document
          , mmtt.demand_id
          , mmtt.rcv_transaction_id
          , mmtt.move_transaction_id
          , mmtt.completion_transaction_id
          , mmtt.wip_entity_type
          , mmtt.schedule_id
          , mmtt.repetitive_line_id
          , mmtt.employee_code
          , mmtt.primary_switch
          , mmtt.schedule_update_code
          , mmtt.setup_teardown_code
          , mmtt.item_ordering
          , mmtt.negative_req_flag
          , mmtt.operation_seq_num
          , mmtt.picking_line_id
          , mmtt.trx_source_line_id
          , mmtt.trx_source_delivery_id
          , mmtt.physical_adjustment_id
          , mmtt.cycle_count_id
          , mmtt.rma_line_id
          , mmtt.customer_ship_id
          , mmtt.currency_code
          , mmtt.currency_conversion_rate
          , mmtt.currency_conversion_type
          , mmtt.currency_conversion_date
          , mmtt.ussgl_transaction_code
          , mmtt.vendor_lot_number
          , mmtt.encumbrance_account
          , mmtt.encumbrance_amount
          , mmtt.ship_to_location
          , mmtt.shipment_number
          , mmtt.transfer_cost
          , mmtt.transportation_cost
          , mmtt.transportation_account
          , mmtt.freight_code
          , mmtt.containers
          , mmtt.waybill_airbill
          , mmtt.expected_arrival_date
          , mmtt.transfer_subinventory
          , mmtt.transfer_organization
          , mmtt.transfer_to_location
          , mmtt.new_average_cost
          , mmtt.value_change
          , mmtt.percentage_change
          , mmtt.material_allocation_temp_id
          , mmtt.demand_source_header_id
          , mmtt.demand_source_line
          , mmtt.demand_source_delivery
          , mmtt.item_segments
          , mmtt.item_description
          , mmtt.item_trx_enabled_flag
          , mmtt.item_location_control_code
          , mmtt.item_restrict_subinv_code
          , mmtt.item_restrict_locators_code
          , mmtt.item_revision_qty_control_code
          , mmtt.item_primary_uom_code
          , mmtt.item_uom_class
          , mmtt.item_shelf_life_code
          , mmtt.item_shelf_life_days
          , mmtt.item_lot_control_code
          , mmtt.item_serial_control_code
          , mmtt.item_inventory_asset_flag
          , mmtt.allowed_units_lookup_code
          , mmtt.department_id
          , mmtt.department_code
          , mmtt.wip_supply_type
          , mmtt.supply_subinventory
          , mmtt.supply_locator_id
          , mmtt.valid_subinventory_flag
          , mmtt.valid_locator_flag
          , mmtt.locator_segments
          , mmtt.current_locator_control_code
          , mmtt.number_of_lots_entered
          , mmtt.wip_commit_flag
          , mmtt.next_lot_number
          , mmtt.lot_alpha_prefix
          , mmtt.next_serial_number
          , mmtt.serial_alpha_prefix
          , mmtt.shippable_flag
          , mmtt.posting_flag
          , mmtt.required_flag
          , mmtt.process_flag
          , mmtt.error_code
          , mmtt.error_explanation
          , mmtt.attribute_category
          , mmtt.attribute1
          , mmtt.attribute2
          , mmtt.attribute3
          , mmtt.attribute4
          , mmtt.attribute5
          , mmtt.attribute6
          , mmtt.attribute7
          , mmtt.attribute8
          , mmtt.attribute9
          , mmtt.attribute10
          , mmtt.attribute11
          , mmtt.attribute12
          , mmtt.attribute13
          , mmtt.attribute14
          , mmtt.attribute15
          , mmtt.movement_id
          , mmtt.reservation_quantity
          , mmtt.shipped_quantity
          , mmtt.transaction_line_number
          , mmtt.task_id
          , mmtt.to_task_id
          , mmtt.source_task_id
          , mmtt.project_id
          , mmtt.source_project_id
          , mmtt.pa_expenditure_org_id
          , mmtt.to_project_id
          , mmtt.expenditure_type
          , mmtt.final_completion_flag
          , mmtt.transfer_percentage
          , mmtt.transaction_sequence_id
          , mmtt.material_account
          , mmtt.material_overhead_account
          , mmtt.resource_account
          , mmtt.outside_processing_account
          , mmtt.overhead_account
          , mmtt.flow_schedule
          , mmtt.cost_group_id
          , mmtt.demand_class
          , mmtt.qa_collection_id
          , mmtt.kanban_card_id
          , mmtt.overcompletion_transaction_qty
          , mmtt.overcompletion_primary_qty
          , mmtt.overcompletion_transaction_id
          , mmtt.end_item_unit_number
          , mmtt.scheduled_payback_date
          , mmtt.line_type_code
          , mmtt.parent_transaction_temp_id
          , mmtt.put_away_strategy_id
          , mmtt.put_away_rule_id
          , mmtt.pick_strategy_id
          , mmtt.pick_rule_id
          , mmtt.move_order_line_id
          , mmtt.task_group_id
          , mmtt.pick_slip_number
          , mmtt.reservation_id
          , mmtt.common_bom_seq_id
          , mmtt.common_routing_seq_id
          , mmtt.org_cost_group_id
          , mmtt.cost_type_id
          , mmtt.transaction_status
          , mmtt.standard_operation_id
          , mmtt.task_priority
          , mmtt.wms_task_type
          , mmtt.parent_line_id
          , mmtt.source_lot_number
          , mmtt.transfer_cost_group_id
          , mmtt.lpn_id
          , mmtt.transfer_lpn_id
          , mmtt.wms_task_status
          , mmtt.content_lpn_id
          , mmtt.container_item_id
          , mmtt.cartonization_id
          , mmtt.pick_slip_date
          , mmtt.rebuild_item_id
          , mmtt.rebuild_serial_number
          , mmtt.rebuild_activity_id
          , mmtt.rebuild_job_name
          , mmtt.organization_type
          , mmtt.transfer_organization_type
          , mmtt.owning_organization_id
          , mmtt.owning_tp_type
          , mmtt.xfr_owning_organization_id
          , mmtt.transfer_owning_tp_type
          , mmtt.planning_organization_id
          , mmtt.planning_tp_type
          , mmtt.xfr_planning_organization_id
          , mmtt.transfer_planning_tp_type
          , mmtt.secondary_uom_code
          , mmtt.secondary_transaction_quantity
          , mmtt.allocated_lpn_id
          , mmtt.schedule_number
          , mmtt.scheduled_flag
          , mmtt.class_code
          , mmtt.schedule_group
          , mmtt.build_sequence
          , mmtt.bom_revision
          , mmtt.routing_revision
          , mmtt.bom_revision_date
          , mmtt.routing_revision_date
          , mmtt.alternate_bom_designator
          , mmtt.alternate_routing_designator
          , mmtt.transaction_batch_id
          , mmtt.transaction_batch_seq
          , mmtt.operation_plan_id
          , mmtt.intransit_account
          , mmtt.fob_point
          , mmtt.logical_trx_type_code
          , mmtt.move_order_header_id
          , mmtt.original_transaction_temp_id
          , mmtt.serial_allocated_flag
          , mmtt.trx_flow_header_id
       FROM mtl_material_transactions_temp  mmtt
      WHERE mmtt.move_order_header_id = p_move_order_header_id
        AND mmtt.container_item_id IS NULL;

end if;

     IF g_debug = 1 THEN
        print_debug ('Number of rows inserted into WCT: ' || SQL%ROWCOUNT, l_api_name);
     END IF;

  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        ROLLBACK TO create_wct_sp;
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
        ROLLBACK TO create_wct_sp;
        IF g_debug = 1 THEN
           print_debug ('Other error: ' || SQLERRM, l_api_name);
        END IF;

  END create_wct;



  PROCEDURE merge_wct_to_mmtt
  ( x_return_status  OUT NOCOPY  VARCHAR2
  ) IS
    l_api_name   VARCHAR2(30) := 'merge_wct_to_mmtt';
    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(2000);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT merge_wct_sp;

    MERGE INTO mtl_material_transactions_temp  mmtt
    USING ( SELECT * FROM wms_cartonization_temp )  wct
       ON ( mmtt.transaction_temp_id = wct.transaction_temp_id )
     WHEN MATCHED THEN
          UPDATE SET
            mmtt.primary_quantity               = wct.primary_quantity
          , mmtt.transaction_quantity           = wct.transaction_quantity
          , mmtt.secondary_transaction_quantity = wct.secondary_transaction_quantity
          , mmtt.cartonization_id               = wct.cartonization_id
          , mmtt.container_item_id              = NVL(wct.container_item_id,-1)
          , mmtt.transaction_batch_id           = wct.transaction_batch_id
          , mmtt.last_update_date               = SYSDATE
          , mmtt.last_updated_by                = g_user_id
     WHEN NOT MATCHED THEN
          INSERT ( mmtt.transaction_header_id
                 , mmtt.transaction_temp_id
                 , mmtt.source_code
                 , mmtt.source_line_id
                 , mmtt.transaction_mode
                 , mmtt.lock_flag
                 , mmtt.last_update_date
                 , mmtt.last_updated_by
                 , mmtt.creation_date
                 , mmtt.created_by
                 , mmtt.last_update_login
                 , mmtt.request_id
                 , mmtt.program_application_id
                 , mmtt.program_id
                 , mmtt.program_update_date
                 , mmtt.inventory_item_id
                 , mmtt.revision
                 , mmtt.organization_id
                 , mmtt.subinventory_code
                 , mmtt.locator_id
                 , mmtt.transaction_quantity
                 , mmtt.primary_quantity
                 , mmtt.transaction_uom
                 , mmtt.transaction_cost
                 , mmtt.transaction_type_id
                 , mmtt.transaction_action_id
                 , mmtt.transaction_source_type_id
                 , mmtt.transaction_source_id
                 , mmtt.transaction_source_name
                 , mmtt.transaction_date
                 , mmtt.acct_period_id
                 , mmtt.distribution_account_id
                 , mmtt.transaction_reference
                 , mmtt.requisition_line_id
                 , mmtt.requisition_distribution_id
                 , mmtt.reason_id
                 , mmtt.lot_number
                 , mmtt.lot_expiration_date
                 , mmtt.serial_number
                 , mmtt.receiving_document
                 , mmtt.demand_id
                 , mmtt.rcv_transaction_id
                 , mmtt.move_transaction_id
                 , mmtt.completion_transaction_id
                 , mmtt.wip_entity_type
                 , mmtt.schedule_id
                 , mmtt.repetitive_line_id
                 , mmtt.employee_code
                 , mmtt.primary_switch
                 , mmtt.schedule_update_code
                 , mmtt.setup_teardown_code
                 , mmtt.item_ordering
                 , mmtt.negative_req_flag
                 , mmtt.operation_seq_num
                 , mmtt.picking_line_id
                 , mmtt.trx_source_line_id
                 , mmtt.trx_source_delivery_id
                 , mmtt.physical_adjustment_id
                 , mmtt.cycle_count_id
                 , mmtt.rma_line_id
                 , mmtt.customer_ship_id
                 , mmtt.currency_code
                 , mmtt.currency_conversion_rate
                 , mmtt.currency_conversion_type
                 , mmtt.currency_conversion_date
                 , mmtt.ussgl_transaction_code
                 , mmtt.vendor_lot_number
                 , mmtt.encumbrance_account
                 , mmtt.encumbrance_amount
                 , mmtt.ship_to_location
                 , mmtt.shipment_number
                 , mmtt.transfer_cost
                 , mmtt.transportation_cost
                 , mmtt.transportation_account
                 , mmtt.freight_code
                 , mmtt.containers
                 , mmtt.waybill_airbill
                 , mmtt.expected_arrival_date
                 , mmtt.transfer_subinventory
                 , mmtt.transfer_organization
                 , mmtt.transfer_to_location
                 , mmtt.new_average_cost
                 , mmtt.value_change
                 , mmtt.percentage_change
                 , mmtt.material_allocation_temp_id
                 , mmtt.demand_source_header_id
                 , mmtt.demand_source_line
                 , mmtt.demand_source_delivery
                 , mmtt.item_segments
                 , mmtt.item_description
                 , mmtt.item_trx_enabled_flag
                 , mmtt.item_location_control_code
                 , mmtt.item_restrict_subinv_code
                 , mmtt.item_restrict_locators_code
                 , mmtt.item_revision_qty_control_code
                 , mmtt.item_primary_uom_code
                 , mmtt.item_uom_class
                 , mmtt.item_shelf_life_code
                 , mmtt.item_shelf_life_days
                 , mmtt.item_lot_control_code
                 , mmtt.item_serial_control_code
                 , mmtt.item_inventory_asset_flag
                 , mmtt.allowed_units_lookup_code
                 , mmtt.department_id
                 , mmtt.department_code
                 , mmtt.wip_supply_type
                 , mmtt.supply_subinventory
                 , mmtt.supply_locator_id
                 , mmtt.valid_subinventory_flag
                 , mmtt.valid_locator_flag
                 , mmtt.locator_segments
                 , mmtt.current_locator_control_code
                 , mmtt.number_of_lots_entered
                 , mmtt.wip_commit_flag
                 , mmtt.next_lot_number
                 , mmtt.lot_alpha_prefix
                 , mmtt.next_serial_number
                 , mmtt.serial_alpha_prefix
                 , mmtt.shippable_flag
                 , mmtt.posting_flag
                 , mmtt.required_flag
                 , mmtt.process_flag
                 , mmtt.error_code
                 , mmtt.error_explanation
                 , mmtt.attribute_category
                 , mmtt.attribute1
                 , mmtt.attribute2
                 , mmtt.attribute3
                 , mmtt.attribute4
                 , mmtt.attribute5
                 , mmtt.attribute6
                 , mmtt.attribute7
                 , mmtt.attribute8
                 , mmtt.attribute9
                 , mmtt.attribute10
                 , mmtt.attribute11
                 , mmtt.attribute12
                 , mmtt.attribute13
                 , mmtt.attribute14
                 , mmtt.attribute15
                 , mmtt.movement_id
                 , mmtt.reservation_quantity
                 , mmtt.shipped_quantity
                 , mmtt.transaction_line_number
                 , mmtt.task_id
                 , mmtt.to_task_id
                 , mmtt.source_task_id
                 , mmtt.project_id
                 , mmtt.source_project_id
                 , mmtt.pa_expenditure_org_id
                 , mmtt.to_project_id
                 , mmtt.expenditure_type
                 , mmtt.final_completion_flag
                 , mmtt.transfer_percentage
                 , mmtt.transaction_sequence_id
                 , mmtt.material_account
                 , mmtt.material_overhead_account
                 , mmtt.resource_account
                 , mmtt.outside_processing_account
                 , mmtt.overhead_account
                 , mmtt.flow_schedule
                 , mmtt.cost_group_id
                 , mmtt.transfer_cost_group_id
                 , mmtt.demand_class
                 , mmtt.qa_collection_id
                 , mmtt.kanban_card_id
                 , mmtt.overcompletion_transaction_qty
                 , mmtt.overcompletion_primary_qty
                 , mmtt.overcompletion_transaction_id
                 , mmtt.end_item_unit_number
                 , mmtt.scheduled_payback_date
                 , mmtt.line_type_code
                 , mmtt.parent_transaction_temp_id
                 , mmtt.put_away_strategy_id
                 , mmtt.put_away_rule_id
                 , mmtt.pick_strategy_id
                 , mmtt.pick_rule_id
                 , mmtt.move_order_line_id
                 , mmtt.task_group_id
                 , mmtt.pick_slip_number
                 , mmtt.reservation_id
                 , mmtt.common_bom_seq_id
                 , mmtt.common_routing_seq_id
                 , mmtt.org_cost_group_id
                 , mmtt.cost_type_id
                 , mmtt.transaction_status
                 , mmtt.standard_operation_id
                 , mmtt.task_priority
                 , mmtt.wms_task_type
                 , mmtt.parent_line_id
                 , mmtt.source_lot_number
                 , mmtt.lpn_id
                 , mmtt.transfer_lpn_id
                 , mmtt.wms_task_status
                 , mmtt.content_lpn_id
                 , mmtt.container_item_id
                 , mmtt.cartonization_id
                 , mmtt.pick_slip_date
                 , mmtt.rebuild_item_id
                 , mmtt.rebuild_serial_number
                 , mmtt.rebuild_activity_id
                 , mmtt.rebuild_job_name
                 , mmtt.organization_type
                 , mmtt.transfer_organization_type
                 , mmtt.owning_organization_id
                 , mmtt.owning_tp_type
                 , mmtt.xfr_owning_organization_id
                 , mmtt.transfer_owning_tp_type
                 , mmtt.planning_organization_id
                 , mmtt.planning_tp_type
                 , mmtt.xfr_planning_organization_id
                 , mmtt.transfer_planning_tp_type
                 , mmtt.secondary_uom_code
                 , mmtt.secondary_transaction_quantity
                 , mmtt.transaction_batch_id
                 , mmtt.transaction_batch_seq
                 , mmtt.allocated_lpn_id
                 , mmtt.schedule_number
                 , mmtt.scheduled_flag
                 , mmtt.class_code
                 , mmtt.schedule_group
                 , mmtt.build_sequence
                 , mmtt.bom_revision
                 , mmtt.routing_revision
                 , mmtt.bom_revision_date
                 , mmtt.routing_revision_date
                 , mmtt.alternate_bom_designator
                 , mmtt.alternate_routing_designator
                 , mmtt.operation_plan_id
                 , mmtt.intransit_account
                 , mmtt.fob_point
                 , mmtt.logical_trx_type_code
                 , mmtt.original_transaction_temp_id
                 , mmtt.trx_flow_header_id
                 , mmtt.serial_allocated_flag
                 , mmtt.move_order_header_id
                 )
          VALUES ( wct.transaction_header_id
                 , wct.transaction_temp_id
                 , wct.source_code
                 , wct.source_line_id
                 , wct.transaction_mode
                 , wct.lock_flag
                 , SYSDATE
                 , g_user_id
                 , SYSDATE
                 , g_user_id
                 , wct.last_update_login
                 , wct.request_id
                 , wct.program_application_id
                 , wct.program_id
                 , wct.program_update_date
                 , wct.inventory_item_id
                 , wct.revision
                 , wct.organization_id
                 , wct.subinventory_code
                 , wct.locator_id
                 , wct.transaction_quantity
                 , wct.primary_quantity
                 , wct.transaction_uom
                 , wct.transaction_cost
                 , wct.transaction_type_id
                 , wct.transaction_action_id
                 , wct.transaction_source_type_id
                 , wct.transaction_source_id
                 , wct.transaction_source_name
                 , wct.transaction_date
                 , wct.acct_period_id
                 , wct.distribution_account_id
                 , wct.transaction_reference
                 , wct.requisition_line_id
                 , wct.requisition_distribution_id
                 , wct.reason_id
                 , wct.lot_number
                 , wct.lot_expiration_date
                 , wct.serial_number
                 , wct.receiving_document
                 , wct.demand_id
                 , wct.rcv_transaction_id
                 , wct.move_transaction_id
                 , wct.completion_transaction_id
                 , wct.wip_entity_type
                 , wct.schedule_id
                 , wct.repetitive_line_id
                 , wct.employee_code
                 , wct.primary_switch
                 , wct.schedule_update_code
                 , wct.setup_teardown_code
                 , wct.item_ordering
                 , wct.negative_req_flag
                 , wct.operation_seq_num
                 , wct.picking_line_id
                 , wct.trx_source_line_id
                 , wct.trx_source_delivery_id
                 , wct.physical_adjustment_id
                 , wct.cycle_count_id
                 , wct.rma_line_id
                 , wct.customer_ship_id
                 , wct.currency_code
                 , wct.currency_conversion_rate
                 , wct.currency_conversion_type
                 , wct.currency_conversion_date
                 , wct.ussgl_transaction_code
                 , wct.vendor_lot_number
                 , wct.encumbrance_account
                 , wct.encumbrance_amount
                 , wct.ship_to_location
                 , wct.shipment_number
                 , wct.transfer_cost
                 , wct.transportation_cost
                 , wct.transportation_account
                 , wct.freight_code
                 , wct.containers
                 , wct.waybill_airbill
                 , wct.expected_arrival_date
                 , wct.transfer_subinventory
                 , wct.transfer_organization
                 , wct.transfer_to_location
                 , wct.new_average_cost
                 , wct.value_change
                 , wct.percentage_change
                 , wct.material_allocation_temp_id
                 , wct.demand_source_header_id
                 , wct.demand_source_line
                 , wct.demand_source_delivery
                 , wct.item_segments
                 , wct.item_description
                 , wct.item_trx_enabled_flag
                 , wct.item_location_control_code
                 , wct.item_restrict_subinv_code
                 , wct.item_restrict_locators_code
                 , wct.item_revision_qty_control_code
                 , wct.item_primary_uom_code
                 , wct.item_uom_class
                 , wct.item_shelf_life_code
                 , wct.item_shelf_life_days
                 , wct.item_lot_control_code
                 , wct.item_serial_control_code
                 , wct.item_inventory_asset_flag
                 , wct.allowed_units_lookup_code
                 , wct.department_id
                 , wct.department_code
                 , wct.wip_supply_type
                 , wct.supply_subinventory
                 , wct.supply_locator_id
                 , wct.valid_subinventory_flag
                 , wct.valid_locator_flag
                 , wct.locator_segments
                 , wct.current_locator_control_code
                 , wct.number_of_lots_entered
                 , wct.wip_commit_flag
                 , wct.next_lot_number
                 , wct.lot_alpha_prefix
                 , wct.next_serial_number
                 , wct.serial_alpha_prefix
                 , wct.shippable_flag
                 , wct.posting_flag
                 , wct.required_flag
                 , wct.process_flag
                 , wct.error_code
                 , wct.error_explanation
                 , wct.attribute_category
                 , wct.attribute1
                 , wct.attribute2
                 , wct.attribute3
                 , wct.attribute4
                 , wct.attribute5
                 , wct.attribute6
                 , wct.attribute7
                 , wct.attribute8
                 , wct.attribute9
                 , wct.attribute10
                 , wct.attribute11
                 , wct.attribute12
                 , wct.attribute13
                 , wct.attribute14
                 , wct.attribute15
                 , wct.movement_id
                 , wct.reservation_quantity
                 , wct.shipped_quantity
                 , wct.transaction_line_number
                 , wct.task_id
                 , wct.to_task_id
                 , wct.source_task_id
                 , wct.project_id
                 , wct.source_project_id
                 , wct.pa_expenditure_org_id
                 , wct.to_project_id
                 , wct.expenditure_type
                 , wct.final_completion_flag
                 , wct.transfer_percentage
                 , wct.transaction_sequence_id
                 , wct.material_account
                 , wct.material_overhead_account
                 , wct.resource_account
                 , wct.outside_processing_account
                 , wct.overhead_account
                 , wct.flow_schedule
                 , wct.cost_group_id
                 , wct.transfer_cost_group_id
                 , wct.demand_class
                 , wct.qa_collection_id
                 , wct.kanban_card_id
                 , wct.overcompletion_transaction_qty
                 , wct.overcompletion_primary_qty
                 , wct.overcompletion_transaction_id
                 , wct.end_item_unit_number
                 , wct.scheduled_payback_date
                 , wct.line_type_code
                 , wct.parent_transaction_temp_id
                 , wct.put_away_strategy_id
                 , wct.put_away_rule_id
                 , wct.pick_strategy_id
                 , wct.pick_rule_id
                 , wct.move_order_line_id
                 , wct.task_group_id
                 , wct.pick_slip_number
                 , wct.reservation_id
                 , wct.common_bom_seq_id
                 , wct.common_routing_seq_id
                 , wct.org_cost_group_id
                 , wct.cost_type_id
                 , wct.transaction_status
                 , wct.standard_operation_id
                 , wct.task_priority
                 , wct.wms_task_type
                 , wct.parent_line_id
                 , wct.source_lot_number
                 , wct.lpn_id
                 , wct.transfer_lpn_id
                 , wct.wms_task_status
                 , wct.content_lpn_id
                 , NVL(wct.container_item_id,-1)
                 , wct.cartonization_id
                 , wct.pick_slip_date
                 , wct.rebuild_item_id
                 , wct.rebuild_serial_number
                 , wct.rebuild_activity_id
                 , wct.rebuild_job_name
                 , wct.organization_type
                 , wct.transfer_organization_type
                 , wct.owning_organization_id
                 , wct.owning_tp_type
                 , wct.xfr_owning_organization_id
                 , wct.transfer_owning_tp_type
                 , wct.planning_organization_id
                 , wct.planning_tp_type
                 , wct.xfr_planning_organization_id
                 , wct.transfer_planning_tp_type
                 , wct.secondary_uom_code
                 , wct.secondary_transaction_quantity
                 , wct.transaction_batch_id
                 , wct.transaction_batch_seq
                 , wct.allocated_lpn_id
                 , wct.schedule_number
                 , wct.scheduled_flag
                 , wct.class_code
                 , wct.schedule_group
                 , wct.build_sequence
                 , wct.bom_revision
                 , wct.routing_revision
                 , wct.bom_revision_date
                 , wct.routing_revision_date
                 , wct.alternate_bom_designator
                 , wct.alternate_routing_designator
                 , wct.operation_plan_id
                 , wct.intransit_account
                 , wct.fob_point
                 , wct.logical_trx_type_code
                 , wct.original_transaction_temp_id
                 , wct.trx_flow_header_id
                 , wct.serial_allocated_flag
                 , wct.move_order_header_id
                 );

    IF g_debug = 1 AND SQL%ROWCOUNT > 0 THEN
       print_debug(TO_CHAR(SQL%ROWCOUNT) || ' rows merged.', l_api_name);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
       x_return_status := fnd_api.g_ret_sts_error;
       ROLLBACK TO merge_wct_sp;
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
       ROLLBACK TO merge_wct_sp;
       IF g_debug = 1 THEN
          print_debug ('Other error: ' || SQLERRM, l_api_name);
       END IF;

  END merge_wct_to_mmtt;

  --
  -- If any cartonization rules setup exists in the organization this method
  -- gets invoked from the cartonize procedure.  It populates cartonization_id,
  -- container_item_id of MMTT rows belonging to a particular Move Order
  -- Header ID
  --
  PROCEDURE rulebased_cartonization
  ( x_return_status         OUT NOCOPY  VARCHAR2
  , p_org_id                IN          NUMBER
  , p_move_order_header_id  IN          NUMBER
  ) IS
    l_api_name              VARCHAR2(30) := 'rulebased_cartonization';
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

    l_api_return_status     VARCHAR2(1);
    l_move_order_type       NUMBER;

    TYPE rules_table_type   IS  TABLE OF wms_selection_criteria_txn%ROWTYPE;
    rules_table             rules_table_type;
    rules_table1            rules_table_type;

    l_count          NUMBER;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT rb_carton_sp;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline              ||
                    'p_org_id => '              || p_org_id               ||
                    'p_move_order_header_id =>' || p_move_order_header_id
                  , l_api_name);
    END IF;

    l_api_return_status := fnd_api.g_ret_sts_success;
    assign_pick_slip_numbers
    ( p_organization_id  => p_org_id
    , p_mo_header_id     => p_move_order_header_id
    , p_grouping_rule_id => NULL
    , x_return_status    => l_api_return_status
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF g_debug = 1 THEN
          print_debug('Error status from assign_pick_slip_number: '
                      || l_api_return_status, l_api_name);
       END IF;
       IF l_api_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSE
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    END IF;

    l_api_return_status := fnd_api.g_ret_sts_success;



   IF g_debug = 1 THEN
       print_debug('Fetching cartonization rules.. for checking if it is a pick slip group rule', l_api_name);
    END IF;

    SELECT * BULK COLLECT
      INTO rules_table1
      FROM wms_selection_criteria_txn
     WHERE rule_type_code = 12
       AND from_organization_id = p_org_id
       AND enabled_flag = 1
     ORDER BY sequence_number;

    l_api_return_status := fnd_api.g_ret_sts_success;
    FOR iii IN rules_table1.FIRST .. rules_table1.LAST LOOP --{

                            print_debug('Rules return type id is  '||rules_table1(iii).return_type_id, l_api_name);

           -- If pick slip grouping rule then set the global variable as 'Y'
        IF rules_table1(iii).return_type_id = 3 THEN

        	g_pick_group_rule := 'Y';

        end if;


      end loop;

    create_wct
    ( p_move_order_header_id => p_move_order_header_id
    , x_return_status        => l_api_return_status
    );



    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF g_debug = 1 THEN
          print_debug('Error status from create_wct: '
                      || l_api_return_status, l_api_name);
       END IF;
       IF l_api_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSE
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    END IF;

    IF g_debug = 1 THEN
       print_debug('Fetching cartonization rules..', l_api_name);
    END IF;

    SELECT * BULK COLLECT
      INTO rules_table
      FROM wms_selection_criteria_txn
     WHERE rule_type_code = 12
       AND from_organization_id = p_org_id
       AND enabled_flag = 1
     ORDER BY sequence_number;

    l_api_return_status := fnd_api.g_ret_sts_success;
    FOR ii IN rules_table.FIRST .. rules_table.LAST LOOP --{
        IF rules_table(ii).return_type_id = 1 THEN
           WMS_CARTNZN_PUB.cartonize_single_item
           ( x_return_status         => l_api_return_status
           , x_msg_count             => l_msg_count
           , x_msg_data              => l_msg_data
           , p_out_bound             => 'Y'
           , p_org_id                => rules_table(ii).from_organization_id
           , p_move_order_header_id  => p_move_order_header_id
           , p_subinventory_name     => rules_table(ii).from_subinventory_name
           );
        ELSIF rules_table(ii).return_type_id = 2 THEN
           WMS_CARTNZN_PUB.cartonize_mixed_item
           ( x_return_status         => l_api_return_status
           , x_msg_count             => l_msg_count
           , x_msg_data              => l_msg_data
           , p_out_bound             => 'Y'
           , p_org_id                => rules_table(ii).from_organization_id
           , p_move_order_header_id  => p_move_order_header_id
           , p_transaction_header_id => NULL
           , p_subinventory_name     => rules_table(ii).from_subinventory_name
           , p_pack_level            => 0
           , p_stop_level            => 0
           );
           WMS_CARTNZN_PUB.pack_level := 0;
        ELSIF rules_table(ii).return_type_id = 3 THEN
           WMS_CARTNZN_PUB.g_cartonize_pick_slip := 'Y';
           WMS_CARTNZN_PUB.cartonize_pick_slip
           ( p_org_id                => rules_table(ii).from_organization_id
           , p_move_order_header_id  => p_move_order_header_id
           , p_subinventory_name     => rules_table(ii).from_subinventory_name
           , x_return_status         => l_api_return_status
           );
        ELSIF rules_table(ii).return_type_id = 4 THEN
           WMS_CARTNZN_PUB.cartonize_customer_logic
           ( p_org_id                => rules_table(ii).from_organization_id
           , p_move_order_header_id  => p_move_order_header_id
           , p_subinventory_name     => rules_table(ii).from_subinventory_name
           , x_return_status         => l_api_return_status
           );
        END IF;

        IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
           IF g_debug = 1 THEN
              print_debug('Error status from WMS_CARTNZN_PUB APIs: '
                          || l_api_return_status, l_api_name);
           END IF;
           IF l_api_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
           ELSE
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;
        END IF;

        SELECT count(1) INTO l_count
          FROM wms_cartonization_temp
         WHERE cartonization_id IS NULL
           AND transaction_header_id >= 0;

        IF l_count = 0 THEN
           EXIT;
        END IF;

    END LOOP; --}

    -- If there are any more rows left for cartonization for first level,
    -- cartonize through default logic
    IF l_count > 0 THEN
       l_api_return_status := fnd_api.g_ret_sts_success;
       WMS_CARTNZN_PUB.cartonize_default_logic
       ( p_org_id                => p_org_id
       , p_move_order_header_id  => p_move_order_header_id
       , p_out_bound             => 'Y'
       , x_return_status         => l_api_return_status
       , x_msg_count             => l_msg_count
       , x_msg_data              => l_msg_data
       );
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from cartonize_default_logic: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
    END IF;

    IF g_debug = 1 THEN
       print_debug( 'Done with FIRST LEVEL OF CARTONIZATION, inserting packaging history'
                  , l_api_name);
    END IF;

    WMS_CARTNZN_PUB.pack_level := 0;

    l_api_return_status := fnd_api.g_ret_sts_success;
    WMS_CARTNZN_PUB.insert_ph
    ( p_move_order_header_id  => p_move_order_header_id
    , p_current_header_id     => p_move_order_header_id
    , x_return_status         => l_api_return_status
    );
    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF g_debug = 1 THEN
          print_debug('Error status from cartonize_default_logic: '
                      || l_api_return_status, l_api_name);
       END IF;
       IF l_api_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSE
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    END IF;

    IF g_debug = 1 THEN
       print_debug( 'Done with WMS_CARTNZN_PUB.insert_ph', l_api_name);
       print_debug( 'Calling CARTONIZE_MIXED_ITEM for doing MULTI-LEVEL CARTONIZATION'
                  , l_api_name);
    END IF;

    l_api_return_status := fnd_api.g_ret_sts_success;
    WMS_CARTNZN_PUB.cartonize_mixed_item
    ( x_return_status         => l_api_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    , p_out_bound             => 'Y'
    , p_org_id                => p_org_id
    , p_move_order_header_id  => p_move_order_header_id
    , p_transaction_header_id => NULL
    , p_pack_level            => 1
    );
    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF g_debug = 1 THEN
          print_debug('Error status from cartonize_mixed_item: '
                      || l_api_return_status, l_api_name);
       END IF;
       IF l_api_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSE
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    END IF;

    IF g_debug = 1 THEN
       print_debug('Calling Generate_LPNs', l_api_name);
    END IF;

    BEGIN
       WMS_CARTNZN_PUB.generate_lpns
       ( p_header_id       => p_move_order_header_id
       , p_organization_id => p_org_id
       );
    EXCEPTION
       WHEN OTHERS THEN
          IF (g_debug = 1) THEN
             print_debug( 'Not erroring out since the mode is Pick release'
                        , l_api_name);
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
    END;

    DELETE wms_cartonization_temp
     WHERE transaction_header_id < 0;

    l_api_return_status := fnd_api.g_ret_sts_success;
    merge_wct_to_mmtt(l_api_return_status);
    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF g_debug = 1 THEN
          print_debug('Error status from merge_wct_to_mmtt: '
                      || l_api_return_status, l_api_name);
       END IF;
       IF l_api_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSE
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO rb_carton_sp;
      IF g_debug = 1 THEN
         print_debug('Error in rulebased_cartonization: ' || SQLERRM, l_api_name);
      END IF;

  END rulebased_cartonization;



  -- Populates the cartonization_id, container_item_id columns
  -- on MMTT rows for a particular Move Order Header ID
  PROCEDURE cartonize
  ( p_org_id                IN           NUMBER
  , p_move_order_header_id  IN           NUMBER
  , p_caller                 IN VARCHAR2 DEFAULT 'N'
  , x_return_status         OUT   NOCOPY VARCHAR2
  ) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'cartonize';
    v1                           wms_cartnzn_pub.wct_row_type;
    cartonization_profile        VARCHAR2(1)   := 'Y';
    v_cart_value                 NUMBER;
    v_container_item_id          NUMBER := NULL;
    v_qty                        NUMBER := -1;
    v_qty_per_cont               NUMBER := -1;
    v_tr_qty_per_cont            NUMBER := -1;
    v_sec_tr_qty_per_cont        NUMBER := -1;
    v_primary_uom_code           VARCHAR2(3);
    v_loop                       NUMBER := 0;
    v_lpn_id                     NUMBER := 0;
    ret_value                    NUMBER := 29;
    v_return_status              VARCHAR2(1);
    v_left_prim_quant            NUMBER;
    v_left_tr_quant              NUMBER;
    v_sec_left_tr_quant          NUMBER;
    v_sublvlctrl                 VARCHAR2(1) := '2';
    l_api_return_status          VARCHAR2(1);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    v_prev_move_order_line_id    NUMBER := 0;
    space_avail_for              NUMBER := 0;
    tr_space_avail_for           NUMBER := 0;
    sec_tr_space_avail_for       NUMBER := 0;
    v_serial_control_code        NUMBER := NULL;
    l_current_header_id          NUMBER := NULL;
    l_stop_level                 NUMBER := -1;
    v_prev_item_id               NUMBER := NULL;
    l_prev_package_id            NUMBER := NULL;
    l_temp_id                    NUMBER := NULL;
    l_item_id                    NUMBER := NULL;
    l_qty                        NUMBER := NULL;
    l_tr_qty                     NUMBER := NULL;
    l_sec_tr_qty                 NUMBER := NULL;
    l_clpn_id                    NUMBER := NULL;
    l_citem_id                   NUMBER := NULL;
    l_package_id                 NUMBER := NULL;
    l_upd_qty_flag               VARCHAR2(1) := NULL;
    l_prev_header_id             NUMBER := NULL;
    l_header_id                  NUMBER := NULL;
    l_no_pkgs_gen                VARCHAR2(1);
    l_prev_condition             VARCHAR2(1);
    l_revision_code              VARCHAR2(1);
    l_lot_code                   VARCHAR2(1);
    l_serial_code                VARCHAR2(1);
    l_is_revision_control        BOOLEAN;
    l_is_lot_control             BOOLEAN;
    l_is_serial_control          BOOLEAN;
    packaging_mode               NUMBER := wms_cartnzn_pub.pr_pkg_mode;
    l_qoh                        NUMBER;
    l_lpn_fully_allocated        VARCHAR2(1) :='N';
    percent_fill_basis           VARCHAR2(1) :='W';
    l_valid_container            VARCHAR2(1) := 'Y';
    l_cartonize_sales_orders     VARCHAR2(1) :=NULL;
    l_rulebased_setup_exists     NUMBER := 0;
    error_code                   VARCHAR2(30);
    error_msg                    VARCHAR2(30);

    CURSOR wct_rows IS
    SELECT wct.*
      FROM wms_cartonization_temp wct
         , mtl_txn_request_lines mtrl
         , mtl_secondary_inventories sub
         , mtl_parameters mtlp
     WHERE wct.move_order_line_id = mtrl.line_id
       AND mtrl.header_id = p_move_order_header_id
       AND wct.cartonization_id IS NULL
       AND mtlp.organization_id = wct.organization_id
       AND sub.organization_id = wct.organization_id
       AND wct.transfer_lpn_id IS NULL
       AND sub.secondary_inventory_name = wct.subinventory_code
       AND ((Nvl(mtlp.cartonization_flag,-1) = 1)
	   OR (Nvl(mtlp.cartonization_flag,-1) = 3 AND sub.cartonization_flag = 1)
	   OR (NVL(mtlp.cartonization_flag,-1) = 4)
	   OR (NVL(mtlp.cartonization_flag,-1) = 5 AND sub.cartonization_flag = 1)
	   )
     ORDER BY wct.move_order_line_id
            , wct.inventory_item_id
            , ABS(wct.transaction_temp_id);

    CURSOR bpack_rows (p_hdr_id NUMBER) IS
    SELECT *
      FROM wms_cartonization_temp
     WHERE transaction_header_id = p_hdr_id
       AND cartonization_id IS NULL
       AND transfer_lpn_id  IS NULL
     ORDER BY move_order_line_id
         , DECODE( content_lpn_id
                 , NULL, inventory_item_id
                 , DECODE( SIGN(p_hdr_id)
                         , -1, inventory_item_id
                         , wms_cartnzn_pub.get_lpn_itemid (content_lpn_id)
                         )
                 )
         , ABS(transaction_temp_id);

    CURSOR packages(p_hdr_id NUMBER) IS
    SELECT transaction_temp_id
         , inventory_item_id
         , primary_quantity
         , transaction_quantity
         , secondary_transaction_quantity
         , content_lpn_id
         , container_item_id
         , cartonization_id
      FROM wms_cartonization_temp
     WHERE transaction_header_id = p_hdr_id
     ORDER BY cartonization_id;

    CURSOR opackages(p_hdr_id NUMBER) IS
    SELECT wct.transaction_temp_id
         , wct.inventory_item_id
         , wct.primary_quantity
         , wct.transaction_quantity
         , wct.secondary_transaction_quantity
         , wct.content_lpn_id
         , wct.container_item_id
         , wct.cartonization_id
      FROM wms_cartonization_temp wct
         , mtl_txn_request_lines mtrl
     WHERE wct.move_order_line_id = mtrl.line_id
       AND mtrl.header_id = p_hdr_id
     ORDER BY wct.cartonization_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    error_code := 'CARTONIZE 10';
    SAVEPOINT cartonization_sp;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline                ||
                    'p_org_id => '              || p_org_id                 ||
                    'p_move_order_header_id =>' || p_move_order_header_id
                  , l_api_name);
    END IF;

    WMS_CARTNZN_PUB.outbound := 'Y';

    --making sure that we are starting with an empty table
    DELETE wms_cartonization_temp;

    WMS_CARTNZN_PUB.pkg_attr_table.DELETE;
    WMS_CARTNZN_PUB.lpn_attr_table.DELETE;
    WMS_CARTNZN_PUB.lpns_generated_tb.DELETE;

    --get the values related to cartonization from org parameters
    BEGIN
       SELECT NVL(cartonization_flag,-1)
            , NVL(cartonize_sales_orders,'Y')
            , NVL(allocate_serial_flag,'N')
         INTO v_cart_value
            , l_cartonize_sales_orders
            , WMS_CARTNZN_PUB.g_allocate_serial_flag
         FROM mtl_parameters
        WHERE organization_id = p_org_id;
    EXCEPTION
       WHEN OTHERS THEN
            v_cart_value := NULL;
    END;

g_caller := p_caller; --- Assigning global variable for p_caller


-- Changes done for Task Release as a part of Wave Planning project
    if p_caller = 'TRP' then ---Calling Cartonization from Task release

    	if v_cart_value = 4 then -- Always Cartonize for Task Release process
    		v_cart_value := 1;

    	elsif v_cart_value = 5 then -- Cartonize for Task Release at subinventory level
    		v_cart_value := 3;

    	end if;

 end if;

    --check whether the cartonization is at subinv level or at org level
    IF v_cart_value  = 1 AND l_cartonize_sales_orders ='Y' THEN
       v_sublvlctrl := '1'; -- Cartonization is enabled for the whole organization
       cartonization_profile := 'Y';
    ELSIF v_cart_value  = 3 AND l_cartonize_sales_orders ='Y' THEN
       v_sublvlctrl := '3'; --cartonization is controlled at the subinventory level
       cartonization_profile := 'Y';
    ELSE
       cartonization_profile := 'N';
    END IF;

    IF cartonization_profile = 'N' THEN
       IF g_debug = 1 THEN
          print_debug ('Cartonization is disabled, so returning.', l_api_name);
       END IF;
       RETURN;
    END IF;

    WMS_CARTNZN_PUB.g_sublvlctrl := v_sublvlctrl; -- used when calling cartonize_mixed_item
                                                  -- from rule based cartonization
    IF g_debug = 1 THEN
       print_debug( 'WMS_CARTNZN_PUB.g_sublvlctrl: '||WMS_CARTNZN_PUB.g_sublvlctrl
                  , l_api_name);
    END IF;

    BEGIN
       SELECT percent_fill_basis_flag
         INTO percent_fill_basis
         FROM wsh_shipping_parameters
        WHERE organization_id = p_org_id AND
        ROWNUM < 2;
    EXCEPTION
       WHEN OTHERS THEN
            percent_fill_basis := 'W';
    END;

    -- Rule Based Cartonization
    SELECT count(1)
      INTO l_rulebased_setup_exists
      FROM wms_selection_criteria_txn_v
     WHERE rule_type_code = 12
       AND enabled_flag = 1
       AND from_organization_id = p_org_id
       AND ROWNUM = 1;

    IF l_rulebased_setup_exists > 0 THEN
       WMS_CARTNZN_PUB.table_name := 'wms_cartonization_temp';
       IF v_cart_value = 1 or v_cart_value = 3 THEN
          l_api_return_status := fnd_api.g_ret_sts_success;
          rulebased_cartonization
          ( x_return_status         => l_api_return_status
          , p_org_id                => p_org_id
          , p_move_order_header_id  => p_move_order_header_id
          );

          IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
             IF g_debug = 1 THEN
                print_debug('Error status from rulebased_cartonization: '
                            || l_api_return_status, l_api_name);
             END IF;
             IF l_api_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             ELSE
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          END IF;

          RETURN;
       END IF;
    ELSE
       IF g_debug = 1 THEN
          print_debug( 'Rulebased setup does not exist, going to default cartonization logic'
                     , l_api_name);
       END IF;
    END IF;
    -- End of Rule Based Cartonization

    IF g_debug = 1 THEN
       print_debug('Cartonization profile is '     || cartonization_profile    ||
                   ', outbound is '                || WMS_CARTNZN_PUB.outbound ||
                   ', controlled at sub level is ' || v_sublvlctrl
                  , l_api_name);
       print_debug(' Percent fill basis ' || percent_fill_basis, l_api_name);
    END IF;

    WMS_CARTNZN_PUB.table_name := 'wms_cartonization_temp';

    IF g_debug = 1 THEN
       print_debug('Inserting mmtt rows of this header into wms_cartonization_temp '
                    || p_move_order_header_id , l_api_name);
    END IF;

    error_code := 'CARTONIZE 50';

    l_api_return_status := fnd_api.g_ret_sts_success;
    create_wct
    ( p_move_order_header_id => p_move_order_header_id
    , x_return_status        => l_api_return_status
    );

    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF g_debug = 1 THEN
          print_debug('Error status from create_wct: '
                      || l_api_return_status, l_api_name);
       END IF;
       IF l_api_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSE
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    END IF;

    l_stop_level := -1;
    WMS_CARTNZN_PUB.pack_level := 0;
    l_current_header_id := p_move_order_header_id;

    IF cartonization_profile = 'Y' THEN --{
       --- This is the Multi level Cartonization loop
       LOOP --{
          IF g_debug = 1 THEN
             print_debug( 'cur lev '    || WMS_CARTNZN_PUB.pack_level ||
                          ', stop lev ' || l_stop_level
                        , l_api_name);
          END IF;

          EXIT WHEN ((WMS_CARTNZN_PUB.pack_level >= l_stop_level) AND (l_stop_level <> -1));

          v_prev_item_id := -1;
          v_prev_move_order_line_id  := -1;

          IF g_debug = 1 THEN
             print_debug( 'Opening cusror hdr id: ' || l_current_header_id
                        , l_api_name);
          END IF;

          IF ((WMS_CARTNZN_PUB.outbound = 'Y') AND (WMS_CARTNZN_PUB.pack_level = 0)) THEN
             error_code := 'CARTONIZE 70';
             IF g_debug = 1 THEN
                print_debug('Opening wct_rows', l_api_name);
             END IF;
             OPEN wct_rows;
             IF g_debug = 1 THEN
                print_debug('Opened wct_rows', l_api_name);
             END IF;
          ELSE
             error_code := 'CARTONIZE 90';
             IF g_debug = 1 THEN
                print_debug('Opening bpack_rows', l_api_name);
             END IF;
             OPEN bpack_rows(l_current_header_id);
             IF g_debug = 1 THEN
                print_debug('Opened bpack rows', l_api_name);
             END IF;
          END IF;

          error_code := 'CARTONIZE 100';

          LOOP --{
             IF g_debug = 1 THEN
                print_debug(' Fetching rows::pack_level: ' || WMS_CARTNZN_PUB.pack_level ||
                            ', outbound: ' || WMS_CARTNZN_PUB.outbound
                           , l_api_name);
             END IF;

             IF ((WMS_CARTNZN_PUB.outbound = 'Y') AND (WMS_CARTNZN_PUB.pack_level = 0)) THEN --{
                error_code := 'CARTONIZE 110';
                FETCH wct_rows INTO v1;
                EXIT WHEN wct_rows%notfound;

                SELECT revision_qty_control_code
                     , lot_control_code
                     , serial_number_control_code
                  INTO l_revision_code
                     , l_lot_code
                     , l_serial_code
                  FROM mtl_system_items
                 WHERE organization_id = v1.organization_id
                   AND inventory_item_id = v1.inventory_item_id;

                IF l_revision_code > 1 THEN
                   l_is_revision_control := TRUE;
                ELSE
                   l_is_revision_control := FALSE;
                END IF;

                IF l_lot_code > 1 THEN
                   l_is_lot_control := TRUE;
                ELSE
                   l_is_lot_control := FALSE;
                END IF;

                IF (l_serial_code > 1 AND l_serial_code <> 6) THEN
                   l_is_serial_control := TRUE;
                ELSE
                   l_is_serial_control := FALSE;
                END IF;

                IF (v1.allocated_lpn_id IS NOT NULL ) THEN --{
                   error_code := 'CARTONIZE 120';

                   SELECT NVL(SUM(primary_transaction_quantity),0)
                     INTO l_qoh FROM mtl_onhand_quantities_detail
                    WHERE organization_id = v1.organization_id
                      AND subinventory_code = v1.subinventory_code
                      AND locator_id = v1.locator_id
                      AND lpn_id = v1.allocated_lpn_id;

                   IF g_debug = 1 THEN
                      print_debug('lpn_id: '    || v1.allocated_lpn_id, l_api_name);
                      print_debug('l_qoh: '     || l_qoh, l_api_name);
                      print_debug('PrimaryQty: '|| v1.primary_quantity, l_api_name);
                   END IF;

                   IF l_qoh = v1.primary_quantity THEN
                      l_lpn_fully_allocated := 'Y';
                      SELECT v1.transaction_temp_id, 'Y'
                        INTO WMS_CARTNZN_PUB.t_lpn_alloc_flag_table(v1.transaction_temp_id)
                        FROM DUAL;
                   ELSE
                      l_lpn_fully_allocated := 'N';
                      SELECT v1.transaction_temp_id, 'N'
                        INTO WMS_CARTNZN_PUB.t_lpn_alloc_flag_table(v1.transaction_temp_id)
                        FROM DUAL;
                   END IF;
                --}
                ELSE
                   l_lpn_fully_allocated := 'Y';
                   SELECT v1.transaction_temp_id, 'Y'
                     INTO WMS_CARTNZN_PUB.t_lpn_alloc_flag_table(v1.transaction_temp_id)
                     FROM DUAL;
                END IF ;
             --}
             ELSE
                error_code := 'CARTONIZE 130';
                FETCH bpack_rows INTO v1;

                EXIT WHEN bpack_rows%notfound;

                l_lpn_fully_allocated := 'N';
             END IF;

             IF g_debug = 1 THEN
                print_debug('Fetch succeeded', l_api_name);
                print_debug('lpn_fully_allocated: ' || l_lpn_fully_allocated, l_api_name);
                print_debug('lpn_id after if: '     || v1.allocated_lpn_id, l_api_name);
             END IF;

             IF v1.allocated_lpn_id IS NOT NULL AND
                l_lpn_fully_allocated = 'Y' THEN
                NULL;
             ELSE --{
                --populate lpn_alloc_flag with null for loose item
                SELECT v1.transaction_temp_id, NULL
                  INTO WMS_CARTNZN_PUB.t_lpn_alloc_flag_table(v1.transaction_temp_id)
                  FROM DUAL;

                -- If the content_lpn_id is populated on the mmtt record
                -- could be two cases. Either we are trying to pack an LPN
                -- or a package. We will have packages poulated in this
                -- column only by multi level cartonization and when it
                -- does that, the row is inserted with negative header id
                -- Basing on this we either get the item associated with
                -- the lpn, or item associated with the package

                error_code := 'CARTONIZE 140';

                IF v1.content_lpn_id IS NOT NULL THEN
                   IF g_debug = 1 THEN
                      print_debug('Content_lpn_id IS NOT NULL', l_api_name);
                   END IF;

                   IF v1.transaction_header_id < 0 THEN
                      error_code := 'CARTONIZE 150';
                   ELSE
                      error_code := 'CARTONIZE 160';
                      v1.inventory_item_id := WMS_CARTNZN_PUB.get_lpn_itemid(v1.content_lpn_id);
                   END IF;

                   -- When we are packaing an lpn or a package the qty is
                   -- always 1
                   v1.primary_quantity := 1;
                   v1.transaction_quantity := 1;
                END IF;

                error_code := 'CARTONIZE 170';
                SELECT primary_uom_code
                  INTO v_primary_uom_code
                  FROM mtl_system_items
                 WHERE inventory_item_id = v1.inventory_item_id
                   AND organization_id   = v1.ORGANIZATION_ID;

                IF v1.content_lpn_id IS NOT NULL THEN
                   -- We want to set the transaction uom same as primary uom
                   v1.transaction_uom := v_primary_uom_code;
                END IF;

                IF g_debug = 1 THEN
                   print_debug('inventory_item_id: '    || v1.inventory_item_id, l_api_name);
                   print_debug('primary_quantity: '     || v1.primary_quantity, l_api_name);
                   print_debug('primary_uom_code: '     ||v_primary_uom_code, l_api_name);
                   print_debug('transaction_quantity: ' ||v1.transaction_quantity, l_api_name);
                   print_debug('transaction_uom: '      ||v1.transaction_uom, l_api_name);
                   print_debug('secondary_transaction_quantity: '||v1.secondary_transaction_quantity, l_api_name);
                   print_debug('secondary_uom_code: '   ||v1.secondary_uom_code, l_api_name);
                END IF;

                IF (WMS_CARTNZN_PUB.outbound = 'Y') AND (WMS_CARTNZN_PUB.pack_level = 0) AND
                   (v_prev_move_order_line_id  <> v1.move_order_line_id) THEN
                   l_prev_condition := 'Y';
                ELSIF (WMS_CARTNZN_PUB.outbound = 'Y') AND (WMS_CARTNZN_PUB.pack_level <> 0) AND
                   ((v_prev_move_order_line_id  <> v1.move_order_line_id) OR
                   (v1.inventory_item_id <> v_prev_item_id)) THEN
                   l_prev_condition := 'Y';
                ELSIF (WMS_CARTNZN_PUB.outbound = 'N') AND
                      (v1.inventory_item_id <> v_prev_item_id) THEN
                   l_prev_condition := 'Y';
                ELSE
                   l_prev_condition := 'N';
                END IF;

                -- The below condition is used when to make a
                -- call to the an api that returns conatiner item relation
                -- ship if present
                -- In outbound mode
                --  you have to call this when previous move order line id
                --  is different from the current one
                -- In the inbound mode
                --  We need to call if the previous item is different form
                -- the current item

                IF l_prev_condition = 'Y' THEN --{
                   IF g_debug = 1 THEN
                      print_debug('Call wms_container_pub.container_required_qty api for item id '
                                   || v1.inventory_item_id, l_api_name);
                   END IF;

                   v_prev_item_id := v1.inventory_item_id;
                   v_prev_move_order_line_id := v1.move_order_line_id;
                   v_container_item_id := NULL;
                   v_qty_per_cont := -1;
                   v_qty := -1;
                   space_avail_for := 0;
                   l_valid_container := 'Y';

                   IF (WMS_CARTNZN_PUB.outbound = 'Y') AND (WMS_CARTNZN_PUB.pack_level = 0) --{
                       AND (packaging_mode = wms_cartnzn_pub.pr_pkg_mode) THEN
                      error_code := 'CARTONIZE 180';
                      wsh_interface.Get_Max_Load_Qty
                      ( p_move_order_line_id => v1.move_order_line_id
                      , x_max_load_quantity  => v_qty_per_cont
                      , x_container_item_id  => v_container_item_id
                      , x_return_status      => v_return_status
                      );

                      l_valid_container := 'Y';

                      IF((v_return_status = fnd_api.g_ret_sts_success) AND
                         (v_qty_per_cont > 0) AND
                         (v_container_item_id IS NOT NULL) AND
                         (v_container_item_id > 0) ) THEN

                         v_qty := ceil(v1.primary_quantity/v_qty_per_cont);
                         -- This quantity needs to be recalculated. This is
                         -- poulated to pass the check marked by '#chk1'
                      END IF;

                      IF (g_debug = 1) THEN
                         print_debug('wsh_interface.Get_Max_Load_Qty return status: '
                                      || v_return_status, l_api_name);
                         print_debug('Container: ' || v_container_item_id, l_api_name);
                         print_debug('Number of dum containers: ' || v_qty, l_api_name);
                      END IF;

                      v_prev_move_order_line_id := v1.move_order_line_id;
                   --}
                   ELSE --{
                      error_code := 'CARTONIZE 190';
                      wms_container_pub.Container_Required_Qty
                      ( p_api_version       => 1.0
                      , x_return_status     => v_return_status
                      , x_msg_count         => l_msg_count
                      , x_msg_data          => l_msg_data
                      , p_source_item_id    => v1.inventory_item_id
                      , p_source_qty        => v1.primary_quantity
                      , p_source_qty_uom    => v_primary_uom_code
                      , p_organization_id   => v1.organization_id
                      , p_dest_cont_item_id => v_container_item_id
                      , p_qty_required      => v_qty
                      );

                      IF g_debug = 1 THEN
                         print_debug('Container_required_quantity return status: '
                                      || v_return_status, l_api_name);
                         print_debug('Container: ' || v_container_item_id, l_api_name);
                         print_debug('Number of conatiners: ' || v_qty, l_api_name);
                      END IF;

                      v_prev_item_id := v1.inventory_item_id;

                      IF ((v_return_status = fnd_api.g_ret_sts_success )   AND
                         (v_qty IS NOT NULL) AND
                         (v_qty > 0) AND
                         (v_container_item_id IS NOT NULL) AND
                         (v_container_item_id > 0) ) THEN

                         error_code := 'CARTONIZE 200';

                         SELECT max_load_quantity
                           INTO v_qty_per_cont
                           FROM wsh_container_items
                          WHERE load_item_id = v1.inventory_item_id
                            AND master_organization_id = v1.organization_id
                            AND container_item_id = v_container_item_id;
                      END IF;
                   --}
                   END IF;

                   IF g_debug = 1 THEN
                      print_debug('Qty per container is: ' || v_qty_per_cont, l_api_name);
                   END IF;

                   --#chk1

                   IF ((v_return_status <> fnd_api.g_ret_sts_success ) OR
                       (v_qty_per_cont IS NULL) OR
                       (v_qty IS NULL) OR
                       (v_container_item_id IS NULL) OR
                       (v_qty <= 0) OR
                       (v_container_item_id <= 0) OR
                       (v_qty_per_cont <= 0) OR
                       l_valid_container = 'N'
                      ) THEN
                      IF g_debug = 1 THEN
                         print_debug('Improper values returned by container_required_qty', l_api_name);
                      END IF;
                   ELSE --{
                      SELECT msi.serial_number_control_code
                        INTO v_serial_control_code
                        FROM mtl_system_items msi
                       WHERE msi.inventory_item_id = v1.inventory_item_id
                         AND msi.organization_id  = v1.organization_id;

                      IF ((v_serial_control_code NOT IN (1,6))
                         AND (Ceil(v_qty_per_cont) > v_qty_per_cont )) THEN
                         IF g_debug = 1 THEN
                            print_debug('cannot split serial controlled items to fractions', l_api_name);
                            print_debug('Please check the container item relationships', l_api_name);
                         END IF;

                         v_qty_per_cont := 0;
                         v_serial_control_code := NULL;
                      END IF;

                      v_serial_control_code := NULL;

                      v_tr_qty_per_cont := inv_convert.inv_um_convert
                                           ( v1.inventory_item_id
                                           , 5
                                           , v_qty_per_cont
                                           , v_primary_uom_code
                                           , v1.transaction_uom
                                           , NULL
                                           , NULL
                                           );

                      IF v1.secondary_uom_code IS NOT NULL THEN
                         v_sec_tr_qty_per_cont := inv_convert.inv_um_convert
                                                  ( v1.inventory_item_id
                                                  , 5
                                                  , v_qty_per_cont
                                                  , v_primary_uom_code
                                                  , v1.secondary_uom_code
                                                  , NULL
                                                  , NULL
                                                  );
                      END IF;
                      IF g_debug = 1 THEN
                         print_debug('Transaction qty per conatiner is: '
                                     || v_tr_qty_per_cont, l_api_name);
                      END IF;
                      IF g_debug = 1 THEN
                         print_debug('Secondary Transaction qty per conatiner is: '
                                     ||v_sec_tr_qty_per_cont, l_api_name);
                      END IF;
                   --}
                   END IF;
                --}
                ELSE --{
                   IF (space_avail_for > 0) THEN --{
                      IF g_debug = 1 THEN
                         print_debug('Space available for: ' || space_avail_for, l_api_name);
                      END IF;

                      IF (v1.primary_quantity <= space_avail_for) THEN --{
                         IF g_debug = 1 THEN
                            print_debug( 'Prim qty: ' || v1.primary_quantity
                                         || ' <= '    || space_avail_for
                                       , l_api_name);
                         END IF;

                         space_avail_for := space_avail_for -  v1.primary_quantity;

                         IF v1.content_lpn_id IS NULL THEN
                            l_upd_qty_flag := 'Y';
                         ELSE
                            l_upd_qty_flag := 'N';
                         END IF;

                         WMS_CARTNZN_PUB.update_mmtt
                         ( p_transaction_temp_id   => v1.transaction_temp_id
                         , p_primary_quantity      => v1.primary_quantity
                         , p_transaction_quantity  => v1.transaction_quantity
                         , p_secondary_quantity    => v1.secondary_transaction_quantity
                         , p_lpn_id                => v_lpn_id
                         , p_container_item_id     => v_container_item_id
                         , p_parent_line_id        => NULL
                         , p_upd_qty_flag          => l_upd_qty_flag
                         , x_return_status         => l_api_return_status
                         , x_msg_count             => l_msg_count
                         , x_msg_data              => l_msg_data
                         );

                         v1.primary_quantity := 0;
                      --}
                      ELSE --{
                         IF g_debug = 1 THEN
                            print_debug( 'Prim qty: ' || v1.primary_quantity
                                         || ' > '     || space_avail_for
                                       , l_api_name);
                         END IF;

                         tr_space_avail_for := inv_convert.inv_um_convert
                                               ( v1.inventory_item_id
                                               , 5
                                               , space_avail_for
                                               , v_primary_uom_code
                                               , v1.transaction_uom
                                               , NULL
                                               , NULL
                                               );

                         sec_tr_space_avail_for := NULL;
                         IF v1.secondary_uom_code IS NOT NULL THEN
                            sec_tr_space_avail_for := inv_convert.inv_um_convert
                                                      ( v1.inventory_item_id
                                                      , 5
                                                      , space_avail_for
                                                      , v_primary_uom_code
                                                      , v1.secondary_uom_code
                                                      , NULL
                                                      , NULL
                                                      );
                         END IF;
                         IF g_debug = 1 THEN
                            print_debug( 'Tr space avail for: ' || tr_space_avail_for
                                       , l_api_name);
                         END IF;

                         WMS_CARTNZN_PUB.insert_mmtt
                         ( p_transaction_temp_id   => v1.transaction_temp_id
                         , p_primary_quantity      => space_avail_for
                         , p_transaction_quantity  => tr_space_avail_for
                         , p_secondary_quantity    => sec_tr_space_avail_for
                         , p_lpn_id                => v_lpn_id
                         , p_container_item_id     => v_container_item_id
                         , x_return_status         => l_api_return_status
                         , x_msg_count             => l_msg_count
                         , x_msg_data              => l_msg_data
                         );

                         v1.primary_quantity := v1.primary_quantity -  space_avail_for;
                         v1.transaction_quantity := inv_convert.inv_um_convert
                                                    ( v1.inventory_item_id
                                                    , 5
                                                    , v1.primary_quantity
                                                    , v_primary_uom_code
                                                    , v1.transaction_uom
                                                    , NULL
                                                    , NULL
                                                    );

                         IF v1.secondary_uom_code IS NOT NULL THEN
                            v1.secondary_transaction_quantity
                               := inv_convert.inv_um_convert
                                  ( v1.inventory_item_id
                                  , 5
                                  , v1.primary_quantity
                                  , v_primary_uom_code
                                  , v1.secondary_uom_code
                                  , NULL
                                  , NULL
                                  );
                         END IF;

                         space_avail_for := 0;

                         IF g_debug = 1 THEN
                            print_debug('Prim qty: '   || v1.primary_quantity, l_api_name);
                            print_debug('Tr qty: '     ||v1.transaction_quantity, l_api_name);
                            print_debug('Sec Tr qty: ' || v1.secondary_transaction_quantity, l_api_name);
                            print_debug('Space Avail for: ' || space_avail_for, l_api_name);
                         END IF;
                      --}
                      END IF;
                   --}
                   END IF;
                --}
                END IF;

                /* Condition #3 */
                IF ( v_return_status <> FND_API.g_ret_sts_success OR
                     v_qty_per_cont IS NULL                       OR
                     v_qty_per_cont <= 0                          OR
                     v_container_item_id IS NULL                  OR
                     v_tr_qty_per_cont  IS NULL                   OR
                     v_tr_qty_per_cont <= 0                       OR
                     v1.primary_quantity <= 0 ) THEN

                   IF g_debug = 1 THEN
                      print_debug('Container_Required_Qty - inc values', l_api_name);
                   END IF;
                   /* Condition #3a */
                   NULL;
                ELSE --{
                   /* Condition #3b */
                   IF v1.content_lpn_id IS NULL THEN
                      l_upd_qty_flag := 'Y';
                   ELSE
                      l_upd_qty_flag := 'N';
                   END IF;

                   v_qty := CEIL(v1.primary_quantity/v_qty_per_cont);

                   IF (MOD(v1.primary_quantity,v_qty_per_cont) = 0) THEN
                      space_avail_for := 0;
                   ELSE
                      space_avail_for := v_qty_per_cont - MOD(v1.primary_quantity,v_qty_per_cont);
                   END IF;

                   IF g_debug = 1 THEN
                      print_debug('space avail for: ' || space_avail_for, l_api_name);
                   END IF;

                   /* Condition #4 */
                   IF ((v1.primary_quantity <= v_qty_per_cont) OR ( v_qty = 1)) THEN --{
                      IF g_debug = 1 THEN
                         print_debug('primary_quantity <= qty per conatiner or ' ||
                                     'NUMBER OF cont = 1', l_api_name);
                      END IF;

                      v_lpn_id := WMS_CARTNZN_PUB.get_next_package_id;

                      IF g_debug = 1 THEN
                         print_debug('Generated label Id '||v_lpn_id, l_api_name);
                      END IF;

                      WMS_CARTNZN_PUB.update_mmtt
                      ( p_transaction_temp_id   => v1.transaction_temp_id
                      , p_primary_quantity      => v1.primary_quantity
                      , p_transaction_quantity  => v1.transaction_quantity
                      , p_secondary_quantity    => v1.secondary_transaction_quantity
                      , p_lpn_id                => v_lpn_id
                      , p_container_item_id     => v_container_item_id
                      , p_parent_line_id        => NULL
                      , p_upd_qty_flag          => l_upd_qty_flag
                      , x_return_status         => l_api_return_status
                      , x_msg_count             => l_msg_count
                      , x_msg_data              => l_msg_data
                      );
                   --}
                   ELSE --{
                      /* Condition #4b */
                      v_loop := v_qty;

                      IF g_debug = 1 THEN
                         print_debug('NUMBER OF cont: ' || v_qty, l_api_name);
                      END IF;

                      v_lpn_id := WMS_CARTNZN_PUB.get_next_package_id;
                      IF g_debug = 1 THEN
                         print_debug('Generated label ID: ' || v_lpn_id, l_api_name);
                         print_debug('Calling update_mmtt', l_api_name);
                      END IF;

                      WMS_CARTNZN_PUB.update_mmtt
                      ( p_transaction_temp_id   => v1.transaction_temp_id
                      , p_primary_quantity      => v_qty_per_cont
                      , p_transaction_quantity  => v_tr_qty_per_cont
                      , p_secondary_quantity    => v_sec_tr_qty_per_cont
                      , p_lpn_id                => v_lpn_id
                      , p_container_item_id     => v_container_item_id
                      , p_parent_line_id        => NULL
                      , p_upd_qty_flag          => l_upd_qty_flag
                      , x_return_status         => l_api_return_status
                      , x_msg_count             => l_msg_count
                      , x_msg_data              => l_msg_data
                      );

                      v_loop := v_loop - 1;

                      LOOP --{
                         EXIT WHEN v_loop < 2;

                         v_lpn_id := WMS_CARTNZN_PUB.get_next_package_id;
                         IF g_debug = 1 THEN
                           print_debug('Generated label ID: ' || v_lpn_id, l_api_name);
                           print_debug('Calling insert mmtt', l_api_name);
                         END IF;
                         WMS_CARTNZN_PUB.insert_mmtt
                         ( p_transaction_temp_id   => v1.transaction_temp_id
                         , p_primary_quantity      => v_qty_per_cont
                         , p_transaction_quantity  => v_tr_qty_per_cont
                         , p_secondary_quantity    => v_sec_tr_qty_per_cont
                         , p_lpn_id                => v_lpn_id
                         , p_container_item_id     => v_container_item_id
                         , x_return_status         => l_api_return_status
                         , x_msg_count             => l_msg_count
                         , x_msg_data              => l_msg_data
                         );

                         IF g_debug = 1 THEN
                            print_debug('called insert mmtt', l_api_name);
                         END IF;
                         v_loop := v_loop - 1;
                      END LOOP; --}

                      v_lpn_id := WMS_CARTNZN_PUB.get_next_package_id;
                      IF g_debug = 1 THEN
                         print_debug('Generated label ID: ' || v_lpn_id, l_api_name);
                      END IF;

                      v_left_prim_quant := MOD(v1.primary_quantity,v_qty_per_cont);
                      v_left_tr_quant   := MOD(v1.transaction_quantity,v_tr_qty_per_cont);

                      IF v1.secondary_uom_code IS NOT NULL THEN
                         v_sec_left_tr_quant :=
                            MOD(v1.secondary_transaction_quantity,v_sec_tr_qty_per_cont);
                      END IF;

                      IF (v_left_prim_quant = 0 OR v_left_tr_quant =0) THEN
                         v_left_prim_quant := v_qty_per_cont;
                         v_left_tr_quant   := v_tr_qty_per_cont;
                         IF v1.secondary_uom_code IS NOT NULL THEN
                            v_sec_left_tr_quant :=  v_sec_tr_qty_per_cont;
                         END IF;
                      END IF;

                      IF g_debug = 1 THEN
                         print_debug('calling insert mmtt', l_api_name);
                      END IF;
                      WMS_CARTNZN_PUB.insert_mmtt
                      ( p_transaction_temp_id   => v1.transaction_temp_id
                      , p_primary_quantity      => v_left_prim_quant
                      , p_transaction_quantity  => v_left_tr_quant
                      , p_secondary_quantity    => v_sec_left_tr_quant
                      , p_lpn_id                => v_lpn_id
                      , p_container_item_id     => v_container_item_id
                      , x_return_status         => l_api_return_status
                      , x_msg_count             => l_msg_count
                      , x_msg_data              => l_msg_data
                      );

                      NULL;
                      -- Shipping API
                   END IF; --} /* Close Condition #4 */
                END IF; --} /* Close Condition #3 */
             END IF; --} /* for v1.allocated_lpn_id is not null */
          END LOOP; --}

          IF g_debug = 1 THEN
             print_debug( 'End working with wms_container_pub.container_required_qty api'
                        , l_api_name);
          END IF;

          error_code := 'CARTONIZE 220';

          IF g_debug = 1 THEN
             print_debug('Calling item-category cartonization', l_api_name);
          END IF;

          IF ((WMS_CARTNZN_PUB.outbound = 'Y') AND (WMS_CARTNZN_PUB.pack_level = 0)) THEN --{
             print_debug('p_move_order_header_id: ' || p_move_order_header_id   ||
                         ', outbound: '             || WMS_CARTNZN_PUB.outbound ||
                         ', v_sublvlctrl: '         || v_sublvlctrl             ||
                         ', percent_fill_basis: '   || percent_fill_basis
                        , l_api_name);

             ret_value := WMS_CARTNZN_PUB.do_cartonization
                          ( p_move_order_header_id
                          , 0
                          , WMS_CARTNZN_PUB.outbound
                          , v_sublvlctrl
                          , percent_fill_basis
                          );
          --}
          ELSE --{
             IF g_debug = 1 THEN
                print_debug('In else for cartonization', l_api_name);
                print_debug('Passing header id: ' || l_current_header_id, l_api_name);
                print_debug('Passing outbound: '  || WMS_CARTNZN_PUB.outbound, l_api_name);
                print_debug('Passing Sub level Control: ' || v_sublvlctrl, l_api_name);
             END IF;

             ret_value := WMS_CARTNZN_PUB.do_cartonization
                          ( 0
                          , l_current_header_id
                          , WMS_CARTNZN_PUB.outbound
                          , v_sublvlctrl
                          , percent_fill_basis
                          );
          --}
          END IF;

          IF g_debug = 1 THEN
             print_debug('Cartonization returned: ' || ret_value, l_api_name);
             print_debug('Calling split_lot_serials', l_api_name);
          END IF;

          WMS_CARTNZN_PUB.split_lot_serials (p_org_id);

          IF g_debug = 1 THEN
             print_debug('Populating Packaging History Table', l_api_name);
          END IF;

          l_prev_package_id := -1;
          l_prev_header_id := l_current_header_id;

          IF g_debug = 1 THEN
             print_debug('Prev header ID: ' || l_prev_header_id, l_api_name);
          END IF;

          l_current_header_id := WMS_CARTNZN_PUB.get_next_header_id;

          IF g_debug = 1 THEN
             print_debug('Current_header_id: ' || l_current_header_id, l_api_name);
          END IF;

          error_code := 'CARTONIZE 225';
          WMS_CARTNZN_PUB.t_lpn_alloc_flag_table.DELETE;
          error_code := 'CARTONIZE 226';
          IF ((WMS_CARTNZN_PUB.outbound = 'Y') AND (WMS_CARTNZN_PUB.pack_level = 0) ) THEN
             error_code := 'CARTONIZE 227';
             OPEN opackages(l_prev_header_id);
          ELSE
             error_code := 'CARTONIZE 228';
             OPEN packages(l_prev_header_id);
          END IF;

          l_no_pkgs_gen := 'Y';

          error_code := 'CARTONIZE 230';

          LOOP --{
             IF g_debug = 1 THEN
                print_debug('Fetching Packages cursor', l_api_name);
             END IF;

             error_code := 'CARTONIZE 240';

             IF ((WMS_CARTNZN_PUB.outbound = 'Y') AND (WMS_CARTNZN_PUB.pack_level = 0) ) THEN
                FETCH opackages
                 INTO l_temp_id
                    , l_item_id
                    , l_qty
                    , l_tr_qty
                    , l_sec_tr_qty
                    , l_clpn_id
                    , l_citem_id
                    , l_package_id;
                EXIT WHEN opackages%notfound;
             ELSE
                FETCH packages
                 INTO l_temp_id
                    , l_item_id
                    , l_qty
                    , l_tr_qty
                    , l_sec_tr_qty
                    , l_clpn_id
                    , l_citem_id
                    , l_package_id;
                EXIT WHEN packages%notfound;
             END IF;

             IF g_debug = 1 THEN
                print_debug('temp_id '||l_temp_id , l_api_name);
                print_debug('item_id  '||l_item_id , l_api_name);
                print_debug('qty  '||l_qty , l_api_name);
                print_debug('tr_qty '||l_tr_qty, l_api_name);
                print_debug('sec_tr_qty '||l_sec_tr_qty, l_api_name);
                print_debug('clpn_id '||l_clpn_id, l_api_name);
                print_debug('citem_id '||l_citem_id, l_api_name);
                print_debug('package_id '||l_package_id, l_api_name);
             END IF;

             IF l_package_id IS NOT NULL THEN --{
                l_no_pkgs_gen := 'N';

                IF l_package_id <> l_prev_package_id THEN --{
                   l_prev_package_id := l_package_id;

                   IF g_debug = 1 THEN
                      print_debug( 'Inserting a new row for package ' || l_package_id
                                 , l_api_name);
                   END IF;

                   WMS_CARTNZN_PUB.insert_mmtt
                   ( p_transaction_temp_id  => l_temp_id
                   , p_primary_quantity     => l_qty
                   , p_transaction_quantity => l_tr_qty
                   , p_secondary_quantity   => l_sec_tr_qty
                   , p_new_txn_hdr_id       => l_current_header_id
                   , p_new_txn_tmp_id       => WMS_CARTNZN_PUB.get_next_temp_id
                   , p_clpn_id              => l_package_id
                   , p_item_id              => l_citem_id
                   , x_return_status        => l_api_return_status
                   , x_msg_count            => l_msg_count
                   , x_msg_data             => l_msg_data
                   );
                --}
                END IF;

                IF g_debug = 1 THEN
                   print_debug('Calling InsertPH for temp_id ' || l_temp_id, l_api_name);
                END IF;

                IF WMS_CARTNZN_PUB.outbound = 'Y' THEN
                   WMS_CARTNZN_PUB.insert_ph (p_move_order_header_id, l_temp_id);
                   -- Insert_PH is overloaded in WMSCRTNS.pls. careful
                END IF;
             --}
             END IF;
          END LOOP; --}

          IF ((WMS_CARTNZN_PUB.outbound = 'Y') AND (WMS_CARTNZN_PUB.pack_level = 0) ) THEN
             IF opackages%ISOPEN THEN
                CLOSE opackages;
             END IF;
          ELSE
             IF packages%ISOPEN THEN
                CLOSE packages;
             END IF;
          END IF;

          IF l_no_pkgs_gen = 'Y' THEN
             IF g_debug = 1 THEN
                print_debug('No labels generated in the previous level-EXITING', l_api_name);
             END IF;

             IF ((WMS_CARTNZN_PUB.outbound = 'Y') AND (WMS_CARTNZN_PUB.pack_level = 0)) THEN
                IF wct_rows%ISOPEN then
                   CLOSE wct_rows;
                END IF;
             ELSE
                IF bpack_rows%ISOPEN THEN
                   CLOSE bpack_rows;
                END IF;
             END IF;

             EXIT;
          END IF;

          IF ((WMS_CARTNZN_PUB.outbound = 'Y') AND (WMS_CARTNZN_PUB.pack_level = 0)) THEN
             IF wct_rows%ISOPEN THEN
                CLOSE wct_rows;
             END IF;
          ELSE
             IF bpack_rows%iSOPEN THEN
                CLOSE bpack_rows;
             END IF;
          END IF;

          WMS_CARTNZN_PUB.pack_level := WMS_CARTNZN_PUB.pack_level + 1;
          IF g_debug = 1 THEN
             print_debug('Incremented the current level', l_api_name);
             print_debug('going back to the multi-cart loop', l_api_name);
          END IF;

       END LOOP; --}
       -- Ends the loop for Multi level Cartonization loop

       l_header_id := p_move_order_header_id;

       -- We have to update the end labels to LPNS and update the
       -- packaging history and mmtt correspondingly

       IF g_debug = 1 THEN
          print_debug('Calling Generate_LPNs for header id ' || l_header_id, l_api_name);
       END IF;

       BEGIN
          error_code := 'CARTONIZE 250';

          WMS_CARTNZN_PUB.generate_lpns
          ( p_header_id       => l_header_id
          , p_organization_id => p_org_id
          );
       EXCEPTION
          WHEN OTHERS THEN
             IF g_debug = 1 THEN
                print_debug('Other error (Pick release mode): ' || SQLERRM, l_api_name);
             END IF;
             RAISE fnd_api.g_exc_unexpected_error;
       END;

       DELETE wms_cartonization_temp
        WHERE transaction_header_id < 0;

       l_api_return_status := fnd_api.g_ret_sts_success;
       merge_wct_to_mmtt(l_api_return_status);
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from merge_wct_to_mmtt: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
    END IF; --} /* Cartonization profile = 'Y' */

    IF wct_rows%ISOPEN THEN
       CLOSE wct_rows;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
       ROLLBACK TO cartonization_sp;
       x_return_status := fnd_api.g_ret_sts_error;

       FND_MESSAGE.SET_NAME('WMS', 'WMS_CARTONIZATION_ERROR');
       FND_MESSAGE.SET_TOKEN('ERROR_CODE', ERROR_CODE);
       FND_MSG_PUB.ADD;

       IF g_debug = 1 THEN
          print_debug('EXCEPTION occurred from ERROR_CODE: ' || error_code, l_api_name);
       END IF;

       fnd_msg_pub.count_and_get
       ( p_count  => l_msg_count
       , p_data   => l_msg_data
       );

       IF wct_rows%ISOPEN THEN
          CLOSE wct_rows;
       END IF;
       IF opackages%ISOPEN THEN
          CLOSE opackages;
       END IF;
       IF packages%ISOPEN THEN
          CLOSE packages;
       END IF;
       IF bpack_rows%ISOPEN THEN
          CLOSE bpack_rows;
       END IF;

    WHEN OTHERS THEN
       ROLLBACK TO cartonization_sp;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

       ERROR_MSG := SQLERRM;

       IF g_debug = 1 THEN
          print_debug('Exception occurred from ERROR_CODE: ' || error_code, l_api_name);
       END IF;

       IF wct_rows%ISOPEN THEN
          CLOSE wct_rows;
       END IF;
       IF opackages%ISOPEN THEN
          CLOSE opackages;
       END IF;
       IF packages%ISOPEN THEN
          CLOSE packages;
       END IF;
       IF bpack_rows%ISOPEN THEN
          CLOSE bpack_rows;
       END IF;

  END cartonize;



  PROCEDURE consolidate_tasks
  ( p_mo_header_id      IN    NUMBER
  , x_return_status     OUT   NOCOPY   VARCHAR2
  ) IS
    l_api_name             VARCHAR2(30) := 'consolidate_tasks';
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    l_delivery_flag        VARCHAR2(1);
    l_bulk_pick_control    NUMBER;
    l_move_order_type      NUMBER;
    l_dummy                VARCHAR2(1);

    l_last_update_date            tbl_date;
    l_last_updated_by             tbl_num;
    l_creation_date               tbl_date;
    l_created_by                  tbl_num;
    l_inventory_item_id           tbl_num;
    l_revision                    tbl_varchar3;
    l_organization_id             tbl_num;
    l_subinventory_code           tbl_varchar10;
    l_locator_id                  tbl_num;
    l_transaction_quantity        tbl_num;
    l_primary_quantity            tbl_num;
    l_transaction_uom             tbl_varchar3;
    l_transaction_type_id         tbl_num;
    l_transaction_action_id       tbl_num;
    l_transaction_source_type_id  tbl_num;
    l_transaction_date            tbl_date;
    l_acct_period_id              tbl_num;
    l_to_org_id                   tbl_num;
    l_wms_task_type               tbl_num;
    l_task_priority               tbl_num;
    l_cost_group_id               tbl_num;
    l_transaction_header_id       tbl_num;
    l_container_item_id           tbl_num;
    l_operation_plan_id           tbl_num;
    l_wms_task_status             tbl_num;
    l_carton_grouping_id          tbl_num;
    l_primary_uom_code            tbl_varchar3;
    l_lot_control_code            tbl_num;
    l_serial_control_code         tbl_num;
    l_serial_allocated_flag       tbl_varchar1;
    l_transaction_batch_id        tbl_num;
    l_child_task_id               tbl_num;
    l_parent_task_id              tbl_num;

    tbl_transaction_temp_id       tbl_num;

    -- Cursor task_list is for the tasks within the delivery and
    -- and cursor task_list_cross_delivery is for tasks across deliveries
    CURSOR task_list (p_move_order_header_id NUMBER) IS
    SELECT SYSDATE last_update_date
         , g_user_id last_updated_by
         , SYSDATE creation_date
         , g_user_id created_by
         , mmtt.inventory_item_id
         , mmtt.revision
         , mmtt.organization_id
         , mmtt.subinventory_code
         , mmtt.locator_id
         , SUM(mmtt.transaction_quantity) transaction_quantity
         , SUM(mmtt.primary_quantity) primary_quantity
         , mmtt.transaction_uom
         , mmtt.transaction_type_id
         , mmtt.transaction_action_id
         , mmtt.transaction_source_type_id
         , MAX(mmtt.transaction_date) transaction_date
         , MAX(mmtt.acct_period_id) acct_period_id
         , mmtt.transfer_organization
         , mmtt.wms_task_type
         , MAX(mmtt.task_priority) task_priority
         , mmtt.cost_group_id
         , MAX(mmtt.transaction_header_id) transaction_header_id
         , mmtt.container_item_id
         , mmtt.operation_plan_id
         , mmtt.wms_task_status -- carry forward task status also for unreleased/pending statuses
         , NVL(wda.delivery_id, mol.carton_grouping_id) carton_grouping_id
         , mmtt.item_primary_uom_code
         , mmtt.item_lot_control_code
         , mmtt.item_serial_control_code
         , mmtt.serial_allocated_flag
         , mmtt.transaction_batch_id
    FROM mtl_material_transactions_temp mmtt, mtl_txn_request_lines mol
       , wsh_delivery_details_ob_grp_v wdd, wsh_delivery_assignments_v wda
    WHERE mmtt.move_order_line_id = mol.line_id
    AND mol.header_id = p_move_order_header_id
    AND mol.line_id = wdd.move_order_line_id
    AND wdd.delivery_detail_id = wda.delivery_detail_id
    AND mmtt.wms_task_type NOT IN(5, 6)
    AND mmtt.allocated_lpn_id IS NULL -- if lpn allocated, no need to do consolidation
    AND mmtt.cartonization_id IS NULL -- only bulk non_cartonized lines
    AND ( mmtt.serial_allocated_flag = 'N'  -- do not bulk serial allocated lines
          OR mmtt.serial_allocated_flag IS NULL )
    AND ( l_bulk_pick_control = WMS_GLOBALS.BULK_PICK_ENTIRE_WAVE
    -- If bulk picking is not disabled and not pick entire wave only the honor sub/item is left,
    -- so no need to check l_bulk_pick_control, only need to check the sub/item  flag
         OR EXISTS( SELECT 1   -- sub is bulk picking enabled
              FROM mtl_secondary_inventories msi
              WHERE msi.secondary_inventory_name = mmtt.subinventory_code
              AND msi.organization_id = mmtt.organization_id
              AND msi.enable_bulk_pick= 'Y' )
         OR EXISTS( SELECT 1   -- item is bulk picking enabled
              FROM mtl_system_items msi
              WHERE msi.inventory_item_id = mmtt.inventory_item_id
              AND msi.organization_id  = mmtt.organization_id
              AND msi.bulk_picked_flag = 'Y' )
        )
    GROUP BY mmtt.inventory_item_id
           , mmtt.revision
           , mmtt.organization_id
           , mmtt.subinventory_code
           , mmtt.locator_id
           , mmtt.transaction_uom
           , mmtt.transaction_type_id
           , mmtt.transaction_action_id
           , mmtt.transaction_source_type_id
           , mmtt.transfer_organization
           , mmtt.wms_task_type
           , mmtt.cost_group_id
           , mmtt.container_item_id
           , mmtt.operation_plan_id
           , NVL(wda.delivery_id, mol.carton_grouping_id) -- only consolidate tasks with the same carton_grouping_id
                                                          -- (hense delivery) if the delivery is checked in the rule
           , mmtt.wms_task_status
           , mmtt.item_primary_uom_code
           , mmtt.item_lot_control_code
           , mmtt.item_serial_control_code
           , mmtt.serial_allocated_flag
           , mmtt.transaction_batch_id
    HAVING SUM(mmtt.transaction_quantity) <> MIN(mmtt.transaction_quantity); -- make sure one line will not get consolidated

    CURSOR task_list_cross_delivery (p_move_order_header_id NUMBER) IS
    SELECT SYSDATE last_update_date
         , g_user_id last_updated_by
         , SYSDATE creation_date
         , g_user_id created_by
         , mmtt.inventory_item_id
         , mmtt.revision
         , mmtt.organization_id
         , mmtt.subinventory_code
         , mmtt.locator_id
         , SUM(mmtt.transaction_quantity) transaction_quantity
         , SUM(mmtt.primary_quantity) primary_quantity
         , mmtt.transaction_uom
         , mmtt.transaction_type_id
         , mmtt.transaction_action_id
         , mmtt.transaction_source_type_id
         , MAX(mmtt.transaction_date) transaction_date
         , MAX(mmtt.acct_period_id) acct_period_id
         , mmtt.transfer_organization
         , mmtt.wms_task_type
         , MAX(mmtt.task_priority) task_priority
         , mmtt.cost_group_id
         , MAX(mmtt.transaction_header_id) transaction_header_id
         , mmtt.container_item_id
         , mmtt.operation_plan_id
         , mmtt.wms_task_status -- carry forward task status also for unreleased/pending statuses
         , mmtt.item_primary_uom_code
         , mmtt.item_lot_control_code
         , mmtt.item_serial_control_code
         , mmtt.serial_allocated_flag
         , mmtt.transaction_batch_id
    FROM mtl_material_transactions_temp mmtt
    WHERE mmtt.wms_task_type NOT IN(5, 6)
    AND mmtt.allocated_lpn_id IS NULL -- if lpn allocated, no need to do consolidation
    AND mmtt.cartonization_id IS NULL -- only bulk non_cartonized lines
    AND mmtt.move_order_header_id = p_move_order_header_id
    AND ( mmtt.serial_allocated_flag = 'N'  -- do not bulk serial allocated lines
          or mmtt.serial_allocated_flag IS NULL )
    AND ( l_bulk_pick_control = WMS_GLOBALS.BULK_PICK_ENTIRE_WAVE
    -- if bulk picking is not disabled and not pick entire wave only the honor sub/item is left,
    -- so no need to check l_bulk_pick_control, only need to check the sub/item  flag
         OR EXISTS( SELECT 1   -- sub is bulk picking enabled
                    FROM mtl_secondary_inventories msi
                    WHERE msi.secondary_inventory_name = mmtt.subinventory_code
                    AND msi.organization_id = mmtt.organization_id
                    AND msi.enable_bulk_pick= 'Y' )
         OR EXISTS( SELECT 1   -- item is bulk picking enabled
                    FROM mtl_system_items msi
                    WHERE msi.inventory_item_id = mmtt.inventory_item_id
                    AND msi.organization_id  = mmtt.organization_id
                    AND msi.bulk_picked_flag = 'Y' )
        )
    GROUP BY mmtt.inventory_item_id
           , mmtt.revision
           , mmtt.organization_id
           , mmtt.subinventory_code
           , mmtt.locator_id
           , mmtt.transaction_uom
           , mmtt.transaction_type_id
           , mmtt.transaction_action_id
           , mmtt.transaction_source_type_id
           , mmtt.transfer_organization
           , mmtt.wms_task_type
           , mmtt.cost_group_id
           , mmtt.container_item_id
           , mmtt.operation_plan_id
           , mmtt.wms_task_status
           , mmtt.item_primary_uom_code
           , mmtt.item_lot_control_code
           , mmtt.item_serial_control_code
           , mmtt.serial_allocated_flag
           , mmtt.transaction_batch_id
    HAVING SUM(mmtt.transaction_quantity) <> MIN(mmtt.transaction_quantity); -- make sure one line will not get consolidated

  BEGIN

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT task_consolidation_sp;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline      ||
                    'p_mo_header_id => '        || p_mo_header_id
                  , l_api_name);
    END IF;

     -- Cache the move order header info
    IF NOT INV_CACHE.set_mtrh_rec(p_mo_header_id) THEN
       IF g_debug = 1 THEN
          print_debug( 'Error from INV_CACHE.set_mtrh_rec', l_api_name);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    SELECT spg.bulk_pick_control
    INTO l_bulk_pick_control
    FROM wsh_pick_grouping_rules spg
    WHERE spg.pick_grouping_rule_id = INV_CACHE.mtrh_rec.grouping_rule_id;

    -- If bulk picking is not enabled then RETURN
    IF l_bulk_pick_control IS NULL THEN
       l_bulk_pick_control := WMS_GLOBALS.BULK_PICK_SUB_ITEM;
    ELSE
       IF (l_bulk_pick_control = WMS_GLOBALS.BULK_PICK_DISABLED) THEN
          IF (g_debug = 1) THEN
             print_debug( 'Bulk picking is not enabled', l_api_name );
          END IF;
          RETURN;
       END IF;
    END IF;

    l_move_order_type := INV_CACHE.mtrh_rec.move_order_type;

    IF l_move_order_type <> inv_globals.g_move_order_pick_wave THEN
       IF (g_debug = 1) THEN
          print_debug('Move Order is a not pick wave move order', l_api_name );
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    SELECT DELIVERY_FLAG
    INTO l_delivery_flag
    FROM WSH_PICK_GROUPING_RULES
    WHERE pick_method=WMS_GLOBALS.PICK_METHOD_BULK
    AND user_defined_flag = 'N'  -- bulk picking default rule
    AND ROWNUM < 2; -- In case of pseudo translation, multiple records are inserted for the seeded rule

    IF g_debug = 1 THEN
       print_debug('Group-by-delivery flag: ' || l_delivery_flag, l_api_name);
    END IF;

    IF l_delivery_flag = 'Y' THEN
       OPEN task_list( p_mo_header_id );
    ELSE
       OPEN task_list_cross_delivery( p_mo_header_id );
    END IF;

    LOOP --{
      IF l_delivery_flag = 'Y' THEN
         FETCH task_list BULK COLLECT
         INTO l_last_update_date
            , l_last_updated_by
            , l_creation_date
            , l_created_by
            , l_inventory_item_id
            , l_revision
            , l_organization_id
            , l_subinventory_code
            , l_locator_id
            , l_transaction_quantity
            , l_primary_quantity
            , l_transaction_uom
            , l_transaction_type_id
            , l_transaction_action_id
            , l_transaction_source_type_id
            , l_transaction_date
            , l_acct_period_id
            , l_to_org_id
            , l_wms_task_type
            , l_task_priority
            , l_cost_group_id
            , l_transaction_header_id
            , l_container_item_id
            , l_operation_plan_id
            , l_wms_task_status
            , l_carton_grouping_id
            , l_primary_uom_code
            , l_lot_control_code
            , l_serial_control_code
            , l_serial_allocated_flag
            , l_transaction_batch_id LIMIT g_bulk_fetch_limit;

         EXIT WHEN l_transaction_header_id.COUNT = 0;
      ELSE
         FETCH task_list_cross_delivery BULK COLLECT
         INTO l_last_update_date
            , l_last_updated_by
            , l_creation_date
            , l_created_by
            , l_inventory_item_id
            , l_revision
            , l_organization_id
            , l_subinventory_code
            , l_locator_id
            , l_transaction_quantity
            , l_primary_quantity
            , l_transaction_uom
            , l_transaction_type_id
            , l_transaction_action_id
            , l_transaction_source_type_id
            , l_transaction_date
            , l_acct_period_id
            , l_to_org_id
            , l_wms_task_type
            , l_task_priority
            , l_cost_group_id
            , l_transaction_header_id
            , l_container_item_id
            , l_operation_plan_id
            , l_wms_task_status
            , l_primary_uom_code
            , l_lot_control_code
            , l_serial_control_code
            , l_serial_allocated_flag
            , l_transaction_batch_id LIMIT g_bulk_fetch_limit;

         EXIT WHEN l_transaction_header_id.COUNT = 0;
      END IF;

      -- Bulk insert parent rows directly into MMTT
      FORALL jj IN l_transaction_header_id.FIRST .. l_transaction_header_id.LAST
        INSERT INTO mtl_material_transactions_temp
                  ( transaction_header_id
                  , transaction_temp_id
                  , posting_flag
                  , transaction_status
                  , last_update_date
                  , last_updated_by
                  , creation_date
                  , created_by
                  , transaction_type_id
                  , transaction_action_id
                  , transaction_source_type_id
                  , organization_id
                  , inventory_item_id
                  , revision
                  , subinventory_code
                  , locator_id
                  , transfer_organization
                  , transaction_quantity
                  , primary_quantity
                  , transaction_uom
                  , transaction_date
                  , acct_period_id
                  , cost_group_id
                  , wms_task_type
                  , task_priority
                  , container_item_id
                  , operation_plan_id
                  , wms_task_status
                  , parent_line_id
                  , item_primary_uom_code
                  , item_lot_control_code
                  , item_serial_control_code
                  , serial_allocated_flag
                  , transaction_batch_id
                  , pick_slip_number )
           VALUES ( l_transaction_header_id(jj)
                  , mtl_material_transactions_s.NEXTVAL
                  , 'N'
                  , 2
                  , l_last_update_date(jj)
                  , l_last_updated_by(jj)
                  , l_creation_date(jj)
                  , l_created_by(jj)
                  , l_transaction_type_id(jj)
                  , l_transaction_action_id(jj)
                  , l_transaction_source_type_id(jj)
                  , l_organization_id(jj)
                  , l_inventory_item_id(jj)
                  , l_revision(jj)
                  , l_subinventory_code(jj)
                  , l_locator_id(jj)
                  , l_to_org_id(jj)
                  , l_transaction_quantity(jj)
                  , l_primary_quantity(jj)
                  , l_transaction_uom(jj)
                  , l_transaction_date(jj)
                  , l_acct_period_id(jj)
                  , l_cost_group_id(jj)
                  , l_wms_task_type(jj)
                  , l_task_priority(jj)
                  , l_container_item_id(jj)
                  , l_operation_plan_id(jj)
                  , l_wms_task_status(jj)
                  , mtl_material_transactions_s.CURRVAL
                  , l_primary_uom_code(jj)
                  , l_lot_control_code(jj)
                  , l_serial_control_code(jj)
                  , l_serial_allocated_flag(jj)
                  , l_transaction_batch_id(jj)
                  , wsh_pick_slip_numbers_s.NEXTVAL )
        RETURNING transaction_temp_id BULK COLLECT INTO tbl_transaction_temp_id;

      IF g_debug = 1 AND SQL%ROWCOUNT > 0 THEN
         print_debug( 'Inserted ' || l_transaction_header_id.COUNT || ' parent MMTTs'
                    , l_api_name);
      END IF;

      -- Bulk update the child MMTTs for setting parent_line_id
      -- and nulling out transaction_batch_id and pick_slip_number
      IF l_delivery_flag = 'Y' THEN
         FORALL kk IN tbl_transaction_temp_id.FIRST .. tbl_transaction_temp_id.LAST
           UPDATE mtl_material_transactions_temp mmtt
           SET parent_line_id = tbl_transaction_temp_id(kk)
             , transaction_batch_id = NULL
             , pick_slip_number = NULL
           WHERE transaction_temp_id <> tbl_transaction_temp_id(kk)
           AND move_order_header_id = p_mo_header_id
           AND inventory_item_id    = l_inventory_item_id(kk)
           AND NVL(revision, '#$%') = NVL(l_revision(kk), NVL(revision, '#$%'))
           AND organization_id      = l_organization_id(kk)
           AND subinventory_code    = l_subinventory_code(kk)
           AND transaction_uom      = l_transaction_uom(kk)
           AND NVL(cost_group_id, -1) = NVL(l_cost_group_id(kk), NVL(cost_group_id, -1))
           AND NVL(locator_id, -1)    = NVL(l_locator_id(kk), NVL(locator_id, -1))
           AND NVL(transfer_organization, -1)      = NVL(l_to_org_id(kk), NVL(transfer_organization, -1))
           AND NVL(transaction_type_id, -1)        = NVL(l_transaction_type_id(kk), NVL(transaction_type_id, -1))
           AND NVL(transaction_action_id, -1)      = NVL(l_transaction_action_id(kk), NVL(transaction_action_id, -1))
           AND NVL(transaction_source_type_id, -1) = NVL(l_transaction_source_type_id(kk), NVL(transaction_source_type_id, -1))
           AND EXISTS( SELECT 1
                       FROM mtl_txn_request_lines mol,wsh_delivery_details_ob_grp_v wdd,wsh_delivery_assignments_v wda
                       WHERE mol.line_id = mmtt.move_order_line_id
                       AND mol.line_id = wdd.move_order_line_id
                       AND wdd.delivery_detail_id = wda.delivery_detail_id
                       AND NVL(wda.delivery_id,mol.carton_grouping_id) = l_carton_grouping_id(kk) )
           AND allocated_lpn_id IS NULL   -- Bug: 9309619 Added below condition
           AND cartonization_id is NULL;--added for bug 9446937
      ELSE
         FORALL kk IN tbl_transaction_temp_id.FIRST .. tbl_transaction_temp_id.LAST
           UPDATE mtl_material_transactions_temp
           SET parent_line_id = tbl_transaction_temp_id(kk)
             , transaction_batch_id = NULL
             , pick_slip_number = NULL   --newly added
           WHERE transaction_temp_id <> tbl_transaction_temp_id(kk)
           AND move_order_header_id = p_mo_header_id
           AND inventory_item_id    = l_inventory_item_id(kk)
           AND NVL(revision, '#$%') = NVL(l_revision(kk), NVL(revision, '#$%'))
           AND organization_id      = l_organization_id(kk)
           AND subinventory_code    = l_subinventory_code(kk)
           AND transaction_uom      = l_transaction_uom(kk)
           AND NVL(locator_id, -1)    = NVL(l_locator_id(kk), NVL(locator_id, -1))
           AND NVL(cost_group_id, -1) = NVL(l_cost_group_id(kk), NVL(cost_group_id, -1))
           AND NVL(transfer_organization, -1)      = NVL(l_to_org_id(kk), NVL(transfer_organization, -1))
           AND NVL(transaction_type_id, -1)        = NVL(l_transaction_type_id(kk), NVL(transaction_type_id, -1))
           AND NVL(transaction_action_id, -1)      = NVL(l_transaction_action_id(kk), NVL(transaction_action_id, -1))
           AND NVL(transaction_source_type_id, -1) = NVL(l_transaction_source_type_id(kk), NVL(transaction_source_type_id, -1))
           AND allocated_lpn_id IS NULL  -- Bug: 9309619 Added below condition
           AND cartonization_id is NULL;--added for bug 9446937
      END IF;

      IF g_debug = 1 AND SQL%ROWCOUNT > 0 THEN
         print_debug('Updated child MMTTs', l_api_name);
      END IF;

      -- Bulk insert MTLT records for the parent tasks
      FORALL ii IN tbl_transaction_temp_id.FIRST .. tbl_transaction_temp_id.LAST
        INSERT INTO mtl_transaction_lots_temp
                  ( transaction_temp_id
                  , lot_number
                  , transaction_quantity
                  , primary_quantity
                  , lot_expiration_date
                  , last_update_date
                  , last_updated_by
                  , creation_date
                  , created_by
                  , serial_transaction_temp_id) -- always set to null since we don't bulk
                                                -- lines with allocated serial numbers

           ( SELECT tbl_transaction_temp_id(ii) -- transaction_temp_id of parent line
                  , mtlt.lot_number
                  , SUM(mtlt.transaction_quantity) transaction_quantity
                  , SUM(mtlt.primary_quantity) primary_quantity
                  , mtlt.lot_expiration_date
                  , SYSDATE
                  , g_user_id
                  , SYSDATE
                  , g_user_id
                  , NULL
               FROM mtl_transaction_lots_temp mtlt, mtl_material_transactions_temp mmtt
              WHERE mtlt.transaction_temp_id = mmtt.transaction_temp_id
                AND mmtt.parent_line_id      = tbl_transaction_temp_id(ii)  -- child task
                AND mmtt.transaction_temp_id <> tbl_transaction_temp_id(ii) -- not parent task
                AND l_lot_control_code(ii)   = 2
              GROUP BY mtlt.lot_number,mtlt.lot_expiration_date );

      IF g_debug = 1 AND SQL%ROWCOUNT > 0 THEN
         print_debug('Inserted parent MTLT records', l_api_name);
      END IF;

    END LOOP; --}

    IF task_list%ISOPEN THEN
       CLOSE task_list;
    END IF;

    IF task_list%ISOPEN THEN
       CLOSe task_list_cross_delivery;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO task_consolidation_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );
      IF g_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;
      IF task_list%ISOPEN THEN
         CLOSE task_list;
      END IF;
      IF task_list_cross_delivery%ISOPEN THEN
         CLOSE task_list_cross_delivery;
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO task_consolidation_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF g_debug = 1 THEN
         print_debug('Other error: ' || SQLERRM, l_api_name);
      END IF;
      IF task_list%ISOPEN THEN
         CLOSE task_list;
      END IF;
      IF task_list_cross_delivery%ISOPEN THEN
         CLOSE task_list_cross_delivery;
      END IF;

  END consolidate_tasks;



  PROCEDURE split_one_task
  ( p_mmtt_temp_id   IN          NUMBER
  , x_return_status  OUT NOCOPY  VARCHAR2
  ) IS

    l_api_name                    VARCHAR2(30) := 'split_one_task';
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_api_return_status           VARCHAR2(1);
    l_split_executed              BOOLEAN;
    l_savepoint_exists            BOOLEAN := FALSE;

    l_hash_split_fac_value        NUMBER;
    l_hash_split_fac_string       VARCHAR2(2000) := NULL;

    l_task_new_rec                mtl_material_transactions_temp%ROWTYPE;
    l_child_new_rec               mtl_material_transactions_temp%ROWTYPE;
    l_lot_split_rec               inv_rcv_common_apis.trans_rec_tb_tp;

    l_organization_id             NUMBER;
    l_parent_line_id              NUMBER;
    l_std_op_id                   NUMBER; --task type
    l_split_factor                NUMBER; --tasks would be split to this size
    l_item_vol                    NUMBER; --item unit volume
    l_item_weight                 NUMBER; --item unit weight
    l_item_v_uom                  VARCHAR2(3); --item unit volume UOM
    l_item_w_uom                  VARCHAR2(3); --item unit weight UOM
    l_equip_v_uom                 VARCHAR2(3); -- equipment volume UOM
    l_equip_w_uom                 VARCHAR2(3); -- equipment weight UOM
    l_equip_vol                   NUMBER; --equipment volume capacity
    l_equip_weight                NUMBER; --equipment weight capacity
    l_eqp_id                      NUMBER;
    l_eq_it_v_uom_ratio           NUMBER := 1; --conversion ratio between equipment volume capacity and item unit volume UOM
    l_eq_it_w_uom_ratio           NUMBER := 1; --conversion ratio between equipment weight capacity and item unit weight UOM

    l_loc_txn_uom_ratio           NUMBER; --conversion rate between locator uom and transaction uom
    l_txn_pri_uom_ratio           NUMBER; --conversion rate between transaction uom and item primary UOM
    l_txn_sec_uom_ratio           NUMBER; --conversion rate between transaction uom and secondary UOM
    l_loc_uom_code                VARCHAR2(3); --locator uom_code
    l_txn_uom_code                VARCHAR2(3); --transaction uom_code
    l_sec_uom_code                VARCHAR2(3); --secondary uom_code
    l_item_id                     NUMBER;
    l_init_qty                    NUMBER;
    l_sec_txn_qty                 NUMBER; --secondary transaction quantity
    l_item_prim_uom_code          VARCHAR2(3); --primary uom_code
    l_min_cap                     NUMBER; --minimum equipment capacity for a task
    l_min_cap_temp                NUMBER;
    l_new_qty                     NUMBER;
    l_lot_control_code            NUMBER;
    l_serial_number_control_code  NUMBER;
    l_sfactor_flag                NUMBER;

    l_child_remaining_qty         NUMBER := 0;
    l_child_temp_id               NUMBER := 0;
    l_child_total_qty             NUMBER := 0;
    l_new_child_temp_id           NUMBER;
    l_new_child_qty               NUMBER;
    l_new_temp_id                 NUMBER;

    l_hash_value_w                NUMBER;
    l_hash_string_w               VARCHAR2(2000) := NULL;
    l_hash_value_loctxnuom        NUMBER;
    l_hash_string_loctxnuom       VARCHAR2(2000) := NULL;
    l_hash_value_tpuom            NUMBER;
    l_hash_string_tpuom           VARCHAR2(2000) := NULL;
    l_hash_value_tsecuom          NUMBER;
    l_hash_string_tsecuom         VARCHAR2(2000) := NULL;
    l_hash_value_v                NUMBER;
    l_hash_string_v               VARCHAR2(2000) := NULL;


    CURSOR c_child_tasks(p_parent_line_id NUMBER) IS
    SELECT mmtt.transaction_temp_id
         , mmtt.transaction_quantity
    FROM mtl_material_transactions_temp mmtt
       , mtl_txn_request_lines mol
       , wsh_delivery_details_ob_grp_v wdd
       , wsh_delivery_assignments_v wda
    WHERE mmtt.parent_line_id = p_parent_line_id
    AND mol.line_id = mmtt.move_order_line_id
    AND mol.line_id = wdd.move_order_line_id
    AND wdd.delivery_detail_id = wda.delivery_detail_id
    AND mmtt.transaction_temp_id <> p_parent_line_id
    ORDER BY nvl(wda.delivery_id,mol.carton_grouping_id)
           , mmtt.transaction_quantity DESC;

    CURSOR c_eqp_capacity(p_task_id NUMBER) IS
    SELECT res_equip.inventory_item_id
     FROM mtl_material_transactions_temp  mmtt
       , bom_std_op_resources tt_x_res
       , bom_resources res
       , bom_resource_equipments res_equip
    WHERE mmtt.transaction_temp_id = p_task_id
     AND mmtt.standard_operation_id = tt_x_res.standard_operation_id
     AND tt_x_res.resource_id = res.resource_id
     AND res.organization_id = mmtt.organization_id
     AND res.resource_type = 1
     AND res_equip.resource_id = res.resource_id
     AND res_equip.organization_id = res.organization_id;

    l_child_rec           c_child_tasks%ROWTYPE;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline      ||
                    'p_mmtt_temp_id => '        || p_mmtt_temp_id
                  , l_api_name );
    END IF;

    l_split_factor   := -9999;
    l_min_cap        := -9999;
    l_split_executed := FALSE;

    SELECT NVL(mil.pick_uom_code, msi.pick_uom_code)
         , mmtt.organization_id
         , mmtt.parent_line_id
         , mmtt.inventory_item_id
         , mmtt.standard_operation_id
         , mmtt.transaction_quantity
         , mmtt.transaction_uom
         , mmtt.secondary_transaction_quantity
         , mmtt.secondary_uom_code
         , item.primary_uom_code
         , item.lot_control_code
         , item.serial_number_control_code
    INTO l_loc_uom_code
       , l_organization_id
       , l_parent_line_id
       , l_item_id
       , l_std_op_id
       , l_init_qty
       , l_txn_uom_code
       , l_sec_txn_qty
       , l_sec_uom_code
       , l_item_prim_uom_code
       , l_lot_control_code
       , l_serial_number_control_code
    FROM mtl_material_transactions_temp mmtt
       , mtl_item_locations mil
       , mtl_secondary_inventories msi
       , mtl_system_items item
    WHERE mmtt.transaction_temp_id = p_mmtt_temp_id
    AND mmtt.locator_id = mil.inventory_location_id(+)
    AND mmtt.organization_id = mil.organization_id(+)
    AND mmtt.subinventory_code = msi.secondary_inventory_name
    AND mmtt.organization_id = msi.organization_id
    AND mmtt.inventory_item_id = item.inventory_item_id
    AND mmtt.organization_id = item.organization_id;

    IF l_txn_uom_code IS NULL
       OR l_item_id IS NULL
       OR l_init_qty IS NULL
       OR l_item_prim_uom_code IS NULL
    THEN
       IF g_debug = 1 THEN
          print_debug('Necessary UOM information is missing for task: ' || p_mmtt_temp_id, l_api_name);
       END IF;
       RETURN;
    END IF;

    IF l_loc_uom_code IS NULL THEN
       IF g_debug = 1 THEN
          print_debug('l_loc_uom_code is NULL, initializing l_loc_txn_uom_ratio to 1', l_api_name);
       END IF;
       l_loc_txn_uom_ratio := 1;
    ELSE --{
       IF l_loc_uom_code = l_txn_uom_code THEN
          l_loc_txn_uom_ratio := 1;
       ELSE --{
          l_hash_string_loctxnuom := l_loc_uom_code || '-' || l_txn_uom_code || '-' || l_item_id; --newly added
          l_hash_value_loctxnuom  := DBMS_UTILITY.get_hash_value
                                     ( name      => l_hash_string_loctxnuom
                                     , base      => g_hash_base
                                     , hash_size => g_hash_size
                                     );

          IF g_from_to_uom_ratio_tbl.EXISTS(l_hash_value_loctxnuom)
             AND g_from_uom_code_tbl(l_hash_value_loctxnuom) = l_loc_uom_code
             AND g_to_uom_code_tbl(l_hash_value_loctxnuom)   = l_txn_uom_code
	     AND g_item_tbl(l_hash_value_loctxnuom)          = l_item_id        --newly added
          THEN
             l_loc_txn_uom_ratio := g_from_to_uom_ratio_tbl(l_hash_value_loctxnuom);
          ELSE --{
             -- Compute conversion ratio between transaction UOM and item primary UOM
             inv_convert.inv_um_conversion( from_unit => l_loc_uom_code
                                          , to_unit   => l_txn_uom_code
                                          , item_id   => l_item_id
                                          , uom_rate  => l_loc_txn_uom_ratio
                                          );
             g_from_uom_code_tbl(l_hash_value_loctxnuom)     := l_loc_uom_code;
             g_to_uom_code_tbl(l_hash_value_loctxnuom)       := l_txn_uom_code;
             g_from_to_uom_ratio_tbl(l_hash_value_loctxnuom) := l_loc_txn_uom_ratio;
             g_item_tbl(l_hash_value_loctxnuom)		     := l_item_id; --newly added
          END IF; --}
       END IF; --}
    END IF; --}

    IF l_loc_txn_uom_ratio = -99999 THEN -- UOM conversion failure
       IF g_debug = 1 THEN
          print_debug('Loc/txn UOM ratio calculation failed', l_api_name);
       END IF;
       RETURN;
    END IF;

    IF l_txn_uom_code = l_item_prim_uom_code THEN
       l_txn_pri_uom_ratio := 1;
    ELSE --{
       l_hash_string_tpuom := l_txn_uom_code || '-' || l_item_prim_uom_code || '-' || l_item_id; --newly added
       l_hash_value_tpuom  := DBMS_UTILITY.get_hash_value
                              ( name      => l_hash_string_tpuom
                              , base      => g_hash_base
                              , hash_size => g_hash_size
                              );

       IF g_from_to_uom_ratio_tbl.EXISTS(l_hash_value_tpuom)
          AND g_from_uom_code_tbl(l_hash_value_tpuom) = l_txn_uom_code
          AND g_to_uom_code_tbl(l_hash_value_tpuom)   = l_item_prim_uom_code
	  AND g_item_tbl(l_hash_value_tpuom)	      = l_item_id    --newly added
       THEN
          l_txn_pri_uom_ratio := g_from_to_uom_ratio_tbl(l_hash_value_tpuom);
       ELSE --{
          -- Compute conversion ratio between transaction UOM and item primary UOM
          inv_convert.inv_um_conversion( from_unit => l_txn_uom_code
                                       , to_unit   => l_item_prim_uom_code
                                       , item_id   => l_item_id
                                       , uom_rate  => l_txn_pri_uom_ratio
                                       );
          g_from_uom_code_tbl(l_hash_value_tpuom)     := l_txn_uom_code;
          g_to_uom_code_tbl(l_hash_value_tpuom)       := l_item_prim_uom_code;
          g_from_to_uom_ratio_tbl(l_hash_value_tpuom) := l_txn_pri_uom_ratio;
          g_item_tbl(l_hash_value_tpuom)              := l_item_id;      --newly added
       END IF; --}
    END IF; --}

    IF l_txn_pri_uom_ratio = -99999 THEN -- UOM conversion failure
       IF g_debug = 1 THEN
          print_debug('Txn/primary UOM ratio calculation failed', l_api_name);
       END IF;
       RETURN;
    END IF;

    IF l_sec_uom_code IS NOT NULL THEN --{
       IF l_txn_uom_code = l_sec_uom_code THEN
          l_txn_sec_uom_ratio := 1;
       ELSE --{
          l_hash_string_tsecuom := l_txn_uom_code || '-' || l_sec_uom_code || '-' || l_item_id;   --newly added
          l_hash_value_tsecuom  := DBMS_UTILITY.get_hash_value
                                   ( name      => l_hash_string_tsecuom
                                   , base      => g_hash_base
                                   , hash_size => g_hash_size
                                   );

          IF g_from_to_uom_ratio_tbl.EXISTS(l_hash_value_tsecuom)
             AND g_from_uom_code_tbl(l_hash_value_tsecuom) = l_txn_uom_code
             AND g_to_uom_code_tbl(l_hash_value_tsecuom)   = l_sec_uom_code
	     AND g_item_tbl(l_hash_value_tsecuom)	   = l_item_id        --newly added
          THEN
             l_txn_sec_uom_ratio := g_from_to_uom_ratio_tbl(l_hash_value_tsecuom);
          ELSE --{
             -- Compute conversion ratio between transaction UOM and item primary UOM
             inv_convert.inv_um_conversion( from_unit => l_txn_uom_code
                                          , to_unit   => l_sec_uom_code
                                          , item_id   => l_item_id
                                          , uom_rate  => l_txn_sec_uom_ratio
                                          );
             g_from_uom_code_tbl(l_hash_value_tsecuom)     := l_txn_uom_code;
             g_to_uom_code_tbl(l_hash_value_tsecuom)       := l_sec_uom_code;
             g_from_to_uom_ratio_tbl(l_hash_value_tsecuom) := l_txn_sec_uom_ratio;
	     g_item_tbl(l_hash_value_tsecuom)              := l_item_id;        --newly added
          END IF; --}
       END IF; --}

       IF l_txn_sec_uom_ratio = -99999 THEN -- UOM conversion failure
          IF g_debug = 1 THEN
             print_debug('Txn/secondary UOM ratio calculation failed', l_api_name);
          END IF;
          RETURN;
       END IF;
    END IF; --}

    IF g_debug = 1 THEN
       print_debug('l_loc_txn_uom_ratio => ' || l_loc_txn_uom_ratio, l_api_name);
       print_debug('l_txn_pri_uom_ratio => ' || l_txn_pri_uom_ratio, l_api_name);
    END IF;

    l_sfactor_flag := 0;
    l_hash_split_fac_string := TO_CHAR(l_organization_id) || '-' ||
                               TO_CHAR(l_item_id)         || '-' ||
                               TO_CHAR(l_std_op_id);
    l_hash_split_fac_value  := DBMS_UTILITY.get_hash_value
                               ( name      => l_hash_split_fac_string
                               , base      => g_hash_base
                               , hash_size => g_hash_size
                               );

    IF g_hash_split_fac_tbl.EXISTS(l_hash_split_fac_value)
       AND g_hash_split_org_tbl(l_hash_split_fac_value) = l_organization_id
       AND g_hash_split_inv_item_id_tbl(l_hash_split_fac_value) = l_item_id
       AND g_hash_split_std_op_id_tbl(l_hash_split_fac_value) = l_std_op_id
    THEN
       l_min_cap := g_hash_split_fac_tbl(l_hash_split_fac_value);
       l_sfactor_flag := 1;
    END IF;

    IF l_sfactor_flag = 0 THEN --{
       -- Add -9999 to the cache so that the split_factor calculation
       -- is only attempted once
       g_hash_split_org_tbl(l_hash_split_fac_value)         := l_organization_id;
       g_hash_split_inv_item_id_tbl(l_hash_split_fac_value) := l_item_id;
       g_hash_split_std_op_id_tbl(l_hash_split_fac_value)   := l_std_op_id;
       g_hash_split_fac_tbl(l_hash_split_fac_value)         := -9999;

       IF inv_cache.set_item_rec(l_organization_id, l_item_id) THEN
          l_item_v_uom  := inv_cache.item_rec.volume_uom_code;
          l_item_w_uom  := inv_cache.item_rec.weight_uom_code;
          l_item_weight := inv_cache.item_rec.unit_weight;
          l_item_vol    := inv_cache.item_rec.unit_volume;
       END IF ;

       IF (( l_item_v_uom IS NOT NULL AND l_item_vol IS NOT NULL )
          OR ( l_item_w_uom IS NOT NULL AND l_item_weight IS NOT NULL ))
       THEN --{
          OPEN c_eqp_capacity(p_mmtt_temp_id);
          -- Loop through equipment items
          LOOP --{
             FETCH c_eqp_capacity INTO l_eqp_id;
             EXIT WHEN c_eqp_capacity%NOTFOUND;

             IF g_eqp_org_id = l_organization_id
                AND g_eqp_vol_uom.EXISTS(l_eqp_id)
             THEN
                l_equip_v_uom  := g_eqp_vol_uom(l_eqp_id);
                l_equip_w_uom  := g_eqp_wt_uom(l_eqp_id);
                l_equip_weight := g_eqp_weight(l_eqp_id);
                l_equip_vol    := g_eqp_volume(l_eqp_id);
             ELSE --{
                BEGIN
                   SELECT msi.volume_uom_code
                        , msi.weight_uom_code
                        , msi.maximum_load_weight
                        , msi.internal_volume
                     INTO l_equip_v_uom
                        , l_equip_w_uom
                        , l_equip_weight
                        , l_equip_vol
                     FROM mtl_system_items  msi
                    WHERE msi.organization_id   = l_organization_id
                      AND msi.inventory_item_id = l_eqp_id;

                -- Cache equipment attributes
                g_eqp_org_id            := l_organization_id;
                g_eqp_vol_uom(l_eqp_id) := l_equip_v_uom;
                g_eqp_wt_uom(l_eqp_id)  := l_equip_w_uom;
                g_eqp_weight(l_eqp_id)  := l_equip_weight;
                g_eqp_volume(l_eqp_id)  := l_equip_vol;

                EXCEPTION
                   WHEN OTHERS THEN
                      IF g_debug = 1 THEN
                         print_debug ('Error fetching equipment attributes'
                                      || SQLERRM, l_api_name);
                      END IF;
                      RAISE fnd_api.g_exc_unexpected_error;
                END;
             END IF; --}

             IF ((l_equip_vol IS NOT NULL AND l_item_vol IS NOT NULL)
                OR (l_equip_weight IS NOT NULL AND l_item_weight IS NOT NULL))
             THEN --{
                l_eq_it_v_uom_ratio := -9999;
                l_eq_it_w_uom_ratio := -9999;
                l_min_cap_temp      := -9999;

                -- Derive item-to-equip weight UOM conversion
                IF l_item_w_uom IS NOT NULL AND l_equip_w_uom IS NOT NULL THEN --{
                   IF l_equip_w_uom = l_item_w_uom THEN
                      l_eq_it_w_uom_ratio := 1;
                   ELSE --{
                      l_hash_string_w := l_equip_w_uom || '-' || l_item_w_uom || '-' || '0';      --newly added
                      l_hash_value_w  := DBMS_UTILITY.get_hash_value
                                         ( name      => l_hash_string_w
                                         , base      => g_hash_base
                                         , hash_size => g_hash_size
                                         );

                      IF g_from_to_uom_ratio_tbl.EXISTS(l_hash_value_w)
                         AND g_from_uom_code_tbl(l_hash_value_w) = l_equip_w_uom
                         AND g_to_uom_code_tbl(l_hash_value_w)   = l_item_w_uom
			 AND g_item_tbl(l_hash_value_w)          = 0     --newly added
                      THEN
                         l_eq_it_w_uom_ratio := g_from_to_uom_ratio_tbl(l_hash_value_w);
                      ELSE --{
                         inv_convert.inv_um_conversion( from_unit => l_equip_w_uom
                                                      , to_unit   => l_item_w_uom
                                                      , item_id   => 0
                                                      , uom_rate  => l_eq_it_w_uom_ratio
                                                      );
                         g_from_uom_code_tbl(l_hash_value_w)     := l_equip_w_uom;
                         g_to_uom_code_tbl(l_hash_value_w)       := l_item_w_uom;
                         g_from_to_uom_ratio_tbl(l_hash_value_w) := l_eq_it_w_uom_ratio;
			 g_item_tbl(l_hash_value_w)              := 0;   --newly added
                      END IF; --}
                   END IF; --}
                END IF; --}

                -- Derive item-to-equip volume UOM conversion
                IF l_item_v_uom IS NOT NULL AND l_equip_v_uom IS NOT NULL THEN --{
                   IF l_equip_v_uom = l_item_v_uom THEN
                      l_eq_it_v_uom_ratio := 1;
                   ELSE --{
                      l_hash_string_v := l_equip_v_uom || '-' || l_item_v_uom || '-' || '0';  --newly added
                      l_hash_value_v  := DBMS_UTILITY.get_hash_value
                                         ( name      => l_hash_string_v
                                         , base      => g_hash_base
                                         , hash_size => g_hash_size
                                         );

                      IF g_from_to_uom_ratio_tbl.EXISTS(l_hash_value_v)
                         AND g_from_uom_code_tbl(l_hash_value_v) = l_equip_v_uom
                         AND g_to_uom_code_tbl(l_hash_value_v)   = l_item_v_uom
			 AND g_item_tbl(l_hash_value_v)          = 0      --newly added
                      THEN
                         l_eq_it_v_uom_ratio := g_from_to_uom_ratio_tbl(l_hash_value_v);
                      ELSE --{
                         inv_convert.inv_um_conversion( from_unit => l_equip_v_uom
                                                      , to_unit   => l_item_v_uom
                                                      , item_id   => 0
                                                      , uom_rate  => l_eq_it_v_uom_ratio
                                                      );
                         g_from_uom_code_tbl(l_hash_value_v)     := l_equip_v_uom;
                         g_to_uom_code_tbl(l_hash_value_v)       := l_item_v_uom;
                         g_from_to_uom_ratio_tbl(l_hash_value_v) := l_eq_it_v_uom_ratio;
			 g_item_tbl(l_hash_value_v)              := 0;    --newly added
                      END IF; --}
                   END IF; --}
                END IF; --}

                IF g_debug = 1 THEN
                   print_debug('l_equip_vol = '         || l_equip_vol, l_api_name);
                   print_debug('l_item_vol = '          || l_item_vol, l_api_name);
                   print_debug('l_eq_it_v_uom_ratio = ' || l_eq_it_v_uom_ratio, l_api_name);
                   print_debug('l_equip_weight = '      || l_equip_weight, l_api_name);
                   print_debug('l_item_weight = '       || l_item_weight, l_api_name);
                   print_debug('l_eq_it_w_uom_ratio = ' || l_eq_it_w_uom_ratio, l_api_name);
                END IF;

                IF l_eq_it_w_uom_ratio <> -9999 AND
                   l_eq_it_v_uom_ratio <> -9999 AND
                   l_equip_weight IS NOT NULL AND
                   l_equip_vol    IS NOT NULL
                THEN
                   l_min_cap_temp  := TRUNC(LEAST( ((l_equip_vol * l_eq_it_v_uom_ratio) / l_item_vol)
                                                 , ((l_equip_weight * l_eq_it_w_uom_ratio) / l_item_weight)
                                                 )
                                           );
                   IF l_min_cap_temp = 0 THEN
                      l_min_cap_temp := LEAST( ((l_equip_vol * l_eq_it_v_uom_ratio) / l_item_vol)
                                             , ((l_equip_weight * l_eq_it_w_uom_ratio) / l_item_weight)
                                             );
                   END IF;
                ELSIF l_eq_it_w_uom_ratio <> -9999 AND l_equip_weight IS NOT NULL THEN
                   l_min_cap_temp  := TRUNC((l_equip_weight * l_eq_it_w_uom_ratio) / l_item_weight);
                   IF l_min_cap_temp = 0 THEN
                      l_min_cap_temp := (l_equip_weight * l_eq_it_w_uom_ratio) / l_item_weight;
                   END IF;
                ELSIF l_eq_it_v_uom_ratio <> -9999 AND l_equip_vol IS NOT NULL THEN
                   l_min_cap_temp  := TRUNC((l_equip_vol * l_eq_it_v_uom_ratio) / l_item_vol);
                   IF l_min_cap_temp = 0 THEN
                      l_min_cap_temp := (l_equip_vol * l_eq_it_v_uom_ratio) / l_item_vol;
                   END IF;
                ELSE
                   IF g_debug = 1 THEN
                      print_debug( 'Both eqp/item volume and eqp/item weight UOM ratio calculation failed'
                                 , l_api_name);
                   END IF;
                END IF;

                IF (l_min_cap_temp <> -9999 AND l_min_cap_temp < l_min_cap)
                   OR l_min_cap = -9999
                THEN
                   l_min_cap := l_min_cap_temp;
                END IF;
             --}
             ELSE
                IF g_debug = 1 THEN
                   print_debug( 'Both eqp/it weight or eqp/it vol is not defined'
                              , l_api_name);
                END IF;
                IF c_eqp_capacity%ISOPEN THEN
                   CLOSE c_eqp_capacity;
                END IF;
                RETURN;
             END IF;
          END LOOP; --}
          IF c_eqp_capacity%ISOPEN THEN
             CLOSE c_eqp_capacity;
          END IF;

          g_hash_split_org_tbl(l_hash_split_fac_value)         := l_organization_id;
          g_hash_split_inv_item_id_tbl(l_hash_split_fac_value) := l_item_id;
          g_hash_split_std_op_id_tbl(l_hash_split_fac_value)   := l_std_op_id;
          g_hash_split_fac_tbl(l_hash_split_fac_value)         := l_min_cap;
       END IF; --}
    END IF; --}

    IF l_min_cap = -9999 THEN
       IF g_debug = 1 THEN
          print_debug('Invalid equipment capacity', l_api_name);
       END IF;
       RETURN;
    END IF;

    l_split_factor := l_min_cap / l_txn_pri_uom_ratio;

    IF l_split_factor >= l_loc_txn_uom_ratio THEN
       l_split_factor  := TRUNC( l_split_factor / l_loc_txn_uom_ratio ) * l_loc_txn_uom_ratio;
    END IF;

    IF l_split_factor <= 0 THEN
       IF g_debug = 1 THEN
          print_debug('Minimum capacity is 0', l_api_name);
       END IF;
       RETURN;
    END IF;

    IF g_debug = 1 THEN
       print_debug('l_split_factor = ' || l_split_factor, l_api_name);
    END IF;

    -- Splitting logic starts
    IF l_init_qty > l_split_factor AND l_split_factor > 0 THEN
       SAVEPOINT split_task_sp;
       l_savepoint_exists := TRUE;
       IF p_mmtt_temp_id = l_parent_line_id THEN
          OPEN c_child_tasks(p_mmtt_temp_id);
       END IF;
    END IF;

    WHILE (l_init_qty > l_split_factor AND l_split_factor > 0)
    LOOP --{
       IF g_debug = 1 THEN
          print_debug('l_init_qty: ' || l_init_qty, l_api_name);
       END IF;

       l_split_executed := TRUE;
       l_init_qty := l_init_qty - l_split_factor;

       IF l_init_qty >= 0 THEN
          l_new_qty  := l_split_factor;
       ELSE
          l_new_qty  := l_init_qty + l_split_factor;
       END IF;

       BEGIN
          SELECT *
            INTO l_task_new_rec
            FROM mtl_material_transactions_temp
           WHERE transaction_temp_id = p_mmtt_temp_id;
       EXCEPTION
          WHEN OTHERS THEN
             IF g_debug = 1 THEN
                print_debug ('Error fetching MMTT record: ' || SQLERRM, l_api_name);
             END IF;
             RAISE fnd_api.g_exc_unexpected_error;
       END;

       SELECT mtl_material_transactions_s.NEXTVAL
       INTO l_new_temp_id
       FROM DUAL;

       l_task_new_rec.transaction_temp_id  := l_new_temp_id;
       l_task_new_rec.transaction_quantity := l_new_qty;
       l_task_new_rec.primary_quantity     := l_new_qty * l_txn_pri_uom_ratio;
       IF l_task_new_rec.secondary_uom_code IS NOT NULL THEN
          l_task_new_rec.secondary_transaction_quantity := l_new_qty * l_txn_sec_uom_ratio;
       END IF;
       IF p_mmtt_temp_id = l_parent_line_id THEN
          l_task_new_rec.parent_line_id := l_new_temp_id;
       END IF;

       wms_task_dispatch_engine.insert_mmtt(l_task_new_rec);

       IF p_mmtt_temp_id = l_parent_line_id THEN --{
          -- Delete MTLT records created in task consolidation
          DELETE FROM mtl_transaction_lots_temp
          WHERE transaction_temp_id = p_mmtt_temp_id;

          l_child_total_qty := 0;
          LOOP --{
             IF l_child_remaining_qty = 0 THEN
                FETCH c_child_tasks INTO l_child_rec;
                EXIT WHEN c_child_tasks%NOTFOUND;

                l_child_remaining_qty := l_child_rec.transaction_quantity;
                l_child_temp_id := l_child_rec.transaction_temp_id;
                l_child_total_qty := l_child_total_qty + l_child_rec.transaction_quantity;
             ELSE
                l_child_rec.transaction_quantity := l_child_remaining_qty;
                l_child_total_qty := l_child_remaining_qty;
             END IF;

             IF l_child_total_qty <= l_new_qty THEN
                -- Update the child records with the new parent line id
                UPDATE mtl_material_transactions_temp
                SET parent_line_id = l_new_temp_id
                WHERE transaction_temp_id = l_child_rec.transaction_temp_id;

                l_child_remaining_qty := 0;
                IF l_child_total_qty = l_new_qty THEN
                   EXIT;
                END IF;
             ELSE --{
                l_child_remaining_qty := l_child_total_qty - l_new_qty;
                l_new_child_qty := l_child_rec.transaction_quantity - l_child_remaining_qty;

                -- Update the child line with the remaining qty
                UPDATE mtl_material_transactions_temp
                SET transaction_quantity = l_child_remaining_qty
                  , primary_quantity     = l_child_remaining_qty * l_txn_pri_uom_ratio
                  , secondary_transaction_quantity
                                         = DECODE( secondary_uom_code
                                                 , NULL, NULL
                                                 , l_child_remaining_qty * l_txn_sec_uom_ratio
                                                 )
                WHERE transaction_temp_id = l_child_rec.transaction_temp_id;

                SELECT mtl_material_transactions_s.NEXTVAL
                INTO l_new_child_temp_id
                FROM DUAL;

                SELECT *
                INTO l_child_new_rec
                FROM  mtl_material_transactions_temp
                WHERE transaction_temp_id = l_child_rec.transaction_temp_id;

                l_child_new_rec.transaction_temp_id   := l_new_child_temp_id;
                l_child_new_rec.transaction_quantity  := l_new_child_qty;
                l_child_new_rec.primary_quantity      := l_new_child_qty * l_txn_pri_uom_ratio;
                IF l_child_new_rec.secondary_uom_code IS NOT NULL THEN
                   l_child_new_rec.secondary_transaction_quantity := l_new_child_qty * l_txn_sec_uom_ratio;
                END IF;
                l_child_new_rec.parent_line_id        := l_new_temp_id;

                wms_task_dispatch_engine.insert_mmtt(l_child_new_rec);

                -- Split lot/serial temp table
                l_lot_split_rec(1).transaction_id    := l_new_child_temp_id;
                l_lot_split_rec(1).primary_quantity  := l_child_new_rec.primary_quantity;

                inv_rcv_common_apis.BREAK( p_original_tid        => l_child_rec.transaction_temp_id
                                         , p_new_transactions_tb => l_lot_split_rec
                                         , p_lot_control_code    => l_lot_control_code
                                         , p_serial_control_code => l_serial_number_control_code
                                         );
                EXIT;
             END IF; --}
          END LOOP; --}

          -- Copy the lot and serial to the parents
          l_api_return_status := fnd_api.g_ret_sts_success;
          wms_task_dispatch_engine.duplicate_lot_serial_in_parent
          ( p_parent_transaction_temp_id => l_new_temp_id
          , x_return_status              => l_api_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );
          IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
             IF g_debug = 1 THEN
                print_debug('Error status from duplicate_lot_serial_in_parent: '
                            || l_api_return_status, l_api_name);
             END IF;
             IF l_api_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             ELSE
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          END IF;
       END IF; --}

       -- Split lot/serial temp table
       IF l_parent_line_id IS NULL THEN
          l_lot_split_rec(1).transaction_id   := l_new_temp_id;
          l_lot_split_rec(1).primary_quantity := l_task_new_rec.primary_quantity;

          inv_rcv_common_apis.BREAK( p_original_tid         => p_mmtt_temp_id
                                   , p_new_transactions_tb  => l_lot_split_rec
                                   , p_lot_control_code     => l_lot_control_code
                                   , p_serial_control_code  => l_serial_number_control_code
                                   );
       END IF;
    END LOOP; --}

    IF l_init_qty <= l_split_factor AND l_split_executed THEN --{
       IF g_debug = 1 THEN
          print_debug('Update original MMTT row with remaining qty: '
                      || l_init_qty, l_api_name);
       END IF;

       UPDATE mtl_material_transactions_temp
          SET transaction_quantity = l_init_qty
            , primary_quantity     = l_init_qty * l_txn_pri_uom_ratio
            , secondary_transaction_quantity
                                   = DECODE( secondary_uom_code
                                           , NULL, NULL
                                           , l_init_qty * l_txn_sec_uom_ratio
                                           )
        WHERE transaction_temp_id  = p_mmtt_temp_id;

       IF p_mmtt_temp_id = l_parent_line_id THEN --{
          -- Copy the lot and serial to the parents
          l_api_return_status := fnd_api.g_ret_sts_success;
          wms_task_dispatch_engine.duplicate_lot_serial_in_parent
          ( p_parent_transaction_temp_id => p_mmtt_temp_id
          , x_return_status              => x_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );
          IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
             IF g_debug = 1 THEN
                print_debug('Error status from duplicate_lot_serial_in_parent: '
                            || l_api_return_status, l_api_name);
             END IF;
             IF l_api_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             ELSE
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          END IF;
       END IF; --}
    END IF; --}

    IF c_eqp_capacity%ISOPEN THEN
       CLOSE c_eqp_capacity;
    END IF;

    IF c_child_tasks%ISOPEN THEN
       CLOSE c_child_tasks;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF l_savepoint_exists THEN
         ROLLBACK TO split_task_sp;
      END IF;
      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );
      IF g_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;
      IF c_eqp_capacity%ISOPEN THEN
         CLOSE c_eqp_capacity;
      END IF;

      IF c_child_tasks%ISOPEN THEN
         CLOSE c_child_tasks;
      END IF;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF l_savepoint_exists THEN
         ROLLBACK TO split_task_sp;
      END IF;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;
      IF c_eqp_capacity%ISOPEN THEN
         CLOSE c_eqp_capacity;
      END IF;

      IF c_child_tasks%ISOPEN THEN
         CLOSE c_child_tasks;
      END IF;

  END split_one_task;



  PROCEDURE split_tasks
  ( p_batch_id          IN             NUMBER
  , x_return_status     OUT  NOCOPY    VARCHAR2
  ) IS

    l_api_name           VARCHAR2(30) := 'split_tasks';
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_mmtt_temp_id       tbl_num;
    l_api_return_status  VARCHAR2(1);
    l_wpr_rec            wms_pr_workers%ROWTYPE;

    CURSOR c_split_tasks (p_txn_batch_id NUMBER) IS
    SELECT transaction_temp_id
      FROM mtl_material_transactions_temp
     WHERE transaction_batch_id = p_txn_batch_id
       AND standard_operation_id IS NOT NULL; -- skip rows without task types

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline         ||
                    'p_batch_id => '            || p_batch_id
                  , l_api_name);
    END IF;

    LOOP --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       fetch_next_wpr_rec
       ( p_batch_id        =>  p_batch_id
       , p_mode            =>  'TSPLIT'
       , x_wpr_rec         =>  l_wpr_rec
       , x_return_status   =>  l_api_return_status
       );

       IF l_api_return_status = 'N' THEN
          IF g_debug = 1 THEN
             print_debug('No more records in WPR', l_api_name);
          END IF;
          EXIT;
       ELSIF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from fetch_next_wpr_rec: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

       OPEN c_split_tasks (l_wpr_rec.transaction_batch_id);
       LOOP --{
          FETCH c_split_tasks BULK COLLECT
           INTO l_mmtt_temp_id LIMIT g_bulk_fetch_limit;

          EXIT WHEN l_mmtt_temp_id.COUNT = 0;

          FOR ii IN l_mmtt_temp_id.FIRST .. l_mmtt_temp_id.LAST
          LOOP --{
             l_api_return_status := fnd_api.g_ret_sts_success;
             WMS_POSTALLOC_PVT.split_one_task
             ( p_mmtt_temp_id  => l_mmtt_temp_id(ii)
             , x_return_status => l_api_return_status
             );

             IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
                IF g_debug = 1 THEN
                   print_debug('Error status from split_one_task: '
                               || l_api_return_status, l_api_name);
                END IF;
                -- Ignore errors, continue to next task
                IF l_api_return_status = fnd_api.g_ret_sts_error THEN
                   NULL;
                   -- RAISE fnd_api.g_exc_error;
                ELSE
                   NULL;
                   -- RAISE fnd_api.g_exc_unexpected_error;
                END IF;
             END IF;

          END LOOP; --}
       END LOOP; --}

       IF c_split_tasks%ISOPEN THEN --{
          CLOSE c_split_tasks;
       END IF; --}

    END LOOP; --}

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
      IF c_split_tasks%ISOPEN THEN
         CLOSE c_split_tasks;
      END IF;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;
      IF c_split_tasks%ISOPEN THEN
         CLOSE c_split_tasks;
      END IF;

  END split_tasks;



  PROCEDURE assign_ttype
  ( p_transaction_batch_id    IN             NUMBER
  , p_organization_id         IN             NUMBER
  , x_return_status           OUT  NOCOPY    VARCHAR2
  ) IS

    l_api_name            VARCHAR2(30) := 'assign_ttype';
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);

    l_api_return_status   VARCHAR2(1);
    l_return_status       NUMBER;
    l_task_type_id        NUMBER;
    l_rule_applied        BOOLEAN;

    l_mmtt_temp_id        tbl_num;
    l_mmtt_hid            tbl_num;

    CURSOR c_mmtt_cursor (p_batch_id NUMBER) IS
    SELECT transaction_temp_id
      FROM mtl_material_transactions_temp
     WHERE transaction_batch_id = p_batch_id;

  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    IF g_debug = 1 THEN
      print_debug( 'Entered with parameters: '  || g_newline               ||
                   'p_transaction_batch_id => ' || p_transaction_batch_id  || g_newline ||
                   'p_organization_id => '      || p_organization_id       || g_newline
                 , l_api_name);
    END IF;

    -- Bulk fetch applicable rule IDs (only if first time or org changed)
    IF g_tta_org_id <> p_organization_id THEN
       g_tta_org_id := p_organization_id;
       BEGIN
          SELECT rules.rule_id, rules.type_hdr_id BULK COLLECT
            INTO g_t_tta_rule_id, g_t_tta_type_hdr_id
            FROM wms_rules_b  rules
               , bom_standard_operations  bso
           WHERE rules.organization_id IN (g_tta_org_id,-1)
             AND rules.type_code     = 3
             AND rules.enabled_flag  = 'Y'
             AND rules.type_hdr_id   = bso.standard_operation_id
             AND bso.organization_id = g_tta_org_id
             AND bso.wms_task_type   = 1
           ORDER BY rules.rule_weight DESC, rules.creation_date;

          g_tta_rule_exists := TRUE;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               g_tta_rule_exists := FALSE;
       END ;
    END IF;

    -- If there is at least one task type rule enabled
    IF g_tta_rule_exists THEN --{
       OPEN c_mmtt_cursor(p_transaction_batch_id);

       LOOP --{
          FETCH c_mmtt_cursor BULK COLLECT
           INTO l_mmtt_temp_id LIMIT g_bulk_fetch_limit;
          EXIT WHEN l_mmtt_temp_id.COUNT = 0;

          FOR ii IN l_mmtt_temp_id.FIRST .. l_mmtt_temp_id.LAST LOOP --{
              l_rule_applied := FALSE;

              FOR jj IN g_t_tta_rule_id.FIRST .. g_t_tta_rule_id.LAST LOOP --{
                  wms_rule_pvt.execute_task_rule( g_t_tta_rule_id(jj), l_mmtt_temp_id(ii), l_return_status);

                  IF l_return_status > 0 THEN
                     l_mmtt_hid(ii) := g_t_tta_type_hdr_id(jj);
                     l_rule_applied := TRUE;
                     EXIT;
                  END IF;
              END LOOP; --}

              -- If no Task type rule gets applied,
              -- stamp the org default task type
              IF ( l_rule_applied <> TRUE ) THEN
                 IF ( inv_cache.set_org_rec( p_organization_id ) ) THEN
                    l_mmtt_hid(ii) := inv_cache.org_rec.default_pick_task_type_id;
                 ELSE
                    IF g_debug = 1 THEN
                       print_debug ( 'Error setting cache for organization', l_api_name );
                    END IF;
                    RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
              END IF ;

              IF g_debug = 1 THEN
                 print_debug('Temp ID: ' || l_mmtt_temp_id(ii) || ', task type assigned: '
                                         || l_mmtt_hid(ii), l_api_name);
              END IF;
          END LOOP; --}

          -- Bulk update task_type_id in all the MMTTs with cached values
          FORALL kk IN l_mmtt_temp_id.FIRST .. l_mmtt_temp_id.LAST
             UPDATE mtl_material_transactions_temp
             SET standard_operation_id = l_mmtt_hid(kk)
             WHERE transaction_temp_id = l_mmtt_temp_id(kk);
       END LOOP; --}

       IF c_mmtt_cursor%ISOPEN THEN
          CLOSE c_mmtt_cursor;
       END IF;
    --}
    ELSE --{
       -- If there is no task type rule enabled,
       -- stamp the org default task type
       IF (inv_cache.set_org_rec(p_organization_id) ) THEN
          l_task_type_id := inv_cache.org_rec.default_pick_task_type_id;
       ELSE
          IF g_debug = 1 THEN
             print_debug('Error setting cache for organization', l_api_name);
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       IF g_debug = 1 THEN
          print_debug('l_task_type_id value: ' || l_task_type_id, l_api_name);
       END IF;

       UPDATE mtl_material_transactions_temp
       SET standard_operation_id = l_task_type_id
       WHERE transaction_batch_id = p_transaction_batch_id;
    END IF; --}

    UPDATE wms_pr_workers
    SET worker_mode = 'TSPLIT', processed_flag = 'N'
    WHERE transaction_batch_id = p_transaction_batch_id;

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
       IF c_mmtt_cursor%ISOPEN THEN
          CLOSE c_mmtt_cursor;
       END IF;

    WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       IF g_debug = 1 THEN
          print_debug ('Other error: ' || SQLERRM, l_api_name);
       END IF;
       IF c_mmtt_cursor%ISOPEN THEN
          CLOSE c_mmtt_cursor;
       END IF;

  END assign_ttype;



  PROCEDURE assign_task_types
  ( p_batch_id          IN    NUMBER
  , x_return_status     OUT   NOCOPY   VARCHAR2
  ) IS
    l_api_name           VARCHAR2(30) := 'assign_task_types';
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_api_return_status  VARCHAR2(1);
    l_wpr_rec            wms_pr_workers%ROWTYPE;
    l_tta_done           BOOLEAN;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF g_debug = 1 THEN
      print_debug( 'Entered with parameters: ' || g_newline         ||
                   'p_batch_id => '            || p_batch_id
                 , l_api_name);
    END IF;

    l_tta_done := FALSE;
    LOOP --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       fetch_next_wpr_rec
       ( p_batch_id        =>  p_batch_id
       , p_mode            =>  'TTA'
       , x_wpr_rec         =>  l_wpr_rec
       , x_return_status   =>  l_api_return_status
       );

       IF l_api_return_status = 'N' THEN
          IF g_debug = 1 THEN
             print_debug('No more records in WPR', l_api_name);
          END IF;
          l_tta_done := TRUE;
          EXIT;
       ELSIF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from fetch_next_wpr_rec: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

       l_api_return_status := fnd_api.g_ret_sts_success;
       assign_ttype
       ( p_transaction_batch_id => l_wpr_rec.transaction_batch_id
       , p_organization_id      => l_wpr_rec.organization_id
       , x_return_status        => l_api_return_status
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from assign_op_plan: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
    END LOOP; --}

    IF l_tta_done THEN --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       split_tasks
       ( p_batch_id      => p_batch_id
       , x_return_status => l_api_return_status
       );
       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from split_tasks: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
    END IF; --}

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

  END assign_task_types;



  FUNCTION get_device_id( p_organization_id   IN NUMBER
                        , p_subinventory_code IN VARCHAR2
                        , p_locator_id        IN NUMBER
                        ) RETURN NUMBER IS

    l_api_name                VARCHAR2(30) := 'get_device_id';
    l_hash_value              NUMBER;
    l_hash_string             VARCHAR2(2000) := NULL;
    l_force_sign_on_flag      VARCHAR2(1);
    l_ret_dev_id              NUMBER;
    l_temp_dev_id             NUMBER;

  BEGIN

    -- Concatenate the subinventory, locator, organization and user id string
    l_hash_string := TO_CHAR(p_organization_id) || '-'
                     || p_subinventory_code     || '-'
                     || TO_CHAR(p_locator_id)   || '-'
                     || TO_CHAR(g_user_id);

    -- Generate hash value with the concatenated string
    l_hash_value := DBMS_UTILITY.get_hash_value
                    ( name => l_hash_string
                    , base => g_hash_base
                    , hash_size => g_hash_size
                    );
    IF g_debug = 1 THEN
       print_debug ('Hash string: '          || l_hash_string, l_api_name);
       print_debug ('Hash value generated: ' || l_hash_value, l_api_name);
    END IF;

    -- If the hash value returned exists then take the device_id from the cache
    IF g_dev_tbl.EXISTS(l_hash_value) AND
       g_org_tbl(l_hash_value)  = p_organization_id AND
       g_sub_tbl(l_hash_value)  = p_subinventory_code AND
       g_loc_tbl(l_hash_value)  = p_locator_id AND
       g_user_tbl(l_hash_value) = g_user_id
    THEN
       l_ret_dev_id := g_dev_tbl(l_hash_value);
    ELSE --{
       SELECT device_id
       INTO l_ret_dev_id
       FROM ( SELECT wbed.device_id
              FROM wms_bus_event_devices wbed
                 , wms_devices_b wd
              WHERE wd.device_id = wbed.device_id
              AND wbed.organization_id = wd.organization_id
              AND wd.ENABLED_FLAG = 'Y'
              AND wbed.ENABLED_FLAG = 'Y'
              AND DECODE( level_type
                        , g_device_level_sub, p_subinventory_code
                        , level_value) = DECODE( level_type
                                               , g_device_level_sub, p_subinventory_code
                                               , g_device_level_org, p_organization_id
                                               , g_device_level_locator, p_locator_id
                                               , g_device_level_user, g_user_id
                                               , level_value
                                               )
              AND NVL(wbed.organization_id,-1)
                     = NVL(p_organization_id,NVL(wbed.organization_id,-1))
              AND wbed.auto_enabled_flag = 'Y'
              AND wbed.business_event_id = g_wms_be_pick_release
              ORDER BY level_type DESC )
        WHERE ROWNUM < 2;

        --
        -- In WMSDEVPB (select_device API), the device ID is set to zero
        -- instead of NULL.  However, if the devive ID is 0, it does not
        -- update the WDR records inserted by WMSCRTNB (insert_device_request_rec
        -- API) - instead leaves it as NULL.  It also skips inserting of
        -- lot/serial records for device ID=0.  This behavior is preserved
        -- in the new code.
        --
        IF l_ret_dev_id IS NOT NULL THEN --{
           BEGIN
              SELECT force_sign_on_flag
                INTO l_force_sign_on_flag
                FROM wms_devices_b
               WHERE device_id = l_ret_dev_id;

              IF l_force_sign_on_flag = 'Y' THEN
                 BEGIN
                    SELECT device_id
                      INTO l_temp_dev_id
                      FROM wms_device_assignment_temp
                     WHERE device_id = l_ret_dev_id
                       AND created_by = g_user_id;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         l_ret_dev_id := NULL;
                 END;
              END IF;
           EXCEPTION
              WHEN OTHERS THEN
                   l_ret_dev_id := NULL;
           END;
       END IF; --}

       -- Cache the device_id
       g_org_tbl(l_hash_value)  := p_organization_id;
       g_sub_tbl(l_hash_value)  := p_subinventory_code;
       g_loc_tbl(l_hash_value)  := p_locator_id;
       g_user_tbl(l_hash_value) := g_user_id;
       g_dev_tbl(l_hash_value)  := l_ret_dev_id;

    END IF; --}

    IF g_debug = 1 THEN
       print_debug ('Returning device ID ' || l_ret_dev_id, l_api_name);
    END IF;

    RETURN l_ret_dev_id;

  EXCEPTION
    WHEN OTHERS THEN
         IF g_debug = 1 THEN
            print_debug ('Other error: ' || SQLERRM, l_api_name);
         END IF;
         RETURN NULL;
  END get_device_id;



  PROCEDURE insert_device_requests
  ( p_organization_id   IN    NUMBER
  , p_mo_header_id      IN    NUMBER
  , x_return_status     OUT   NOCOPY   VARCHAR2
  ) IS
    l_api_name                   VARCHAR2(30) := 'insert_device_requests';
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);

    l_api_return_status          VARCHAR2(240);
    l_bus_event_id               NUMBER;
    l_req_msg                    VARCHAR2(255);

    t_transaction_temp_id        tbl_num;
    t_organization_id            tbl_num;
    t_subinventory_code          tbl_varchar10;
    t_locator_id                 tbl_num;
    t_transfer_organization      tbl_num;
    t_inventory_item_id          tbl_num;
    t_revision                   tbl_varchar3;
    t_transaction_uom            tbl_varchar3;
    t_allocated_lpn_id           tbl_num;
    t_cartonization_id           tbl_num;
    t_transaction_quantity       tbl_num;
    t_dev_id                     tbl_num;
    t_lot_serial_capable_flag    tbl_varchar1;
    t_transfer_subinventory      tbl_varchar10;
    t_transfer_to_location       tbl_num;
    t_last_update_date           tbl_date;
    t_last_updated_by            tbl_num;
    t_last_update_login          tbl_num;

    -- Cursor for non-bulk task records
    CURSOR c_non_bulk_tasks (p_mo_hdr_id IN NUMBER) IS
    SELECT x.transaction_temp_id
         , x.organization_id
         , x.subinventory_code
         , x.locator_id
         , x.transfer_organization
         , x.inventory_item_id
         , x.revision
         , x.transaction_uom
         , x.allocated_lpn_id
         , x.cartonization_id
         , x.transaction_quantity
         , x.transfer_subinventory
         , x.transfer_to_location
         , x.last_update_date
         , x.last_updated_by
         , x.last_update_login
         , x.dev_id
         , NVL(dev.lot_serial_capable,'N') lot_serial_capable_flag
    FROM ( SELECT mmtt.transaction_temp_id
                , mmtt.organization_id
                , mmtt.subinventory_code
                , mmtt.locator_id
                , mmtt.transfer_organization
                , mmtt.inventory_item_id
                , mmtt.revision
                , mmtt.transaction_uom
                , mmtt.allocated_lpn_id
                , mmtt.cartonization_id
                , mmtt.transaction_quantity
                , mmtt.transfer_subinventory
                , mmtt.transfer_to_location
                , mmtt.last_update_date
                , mmtt.last_updated_by
                , mmtt.last_update_login
                , get_device_id( mmtt.organization_id
                               , mmtt.subinventory_code
                               , mmtt.locator_id
                               ) dev_id
           FROM mtl_material_transactions_temp   mmtt
           WHERE mmtt.move_order_header_id = p_mo_hdr_id
           AND mmtt.parent_line_id IS NULL
         ) x
       , wms_devices_b dev
    WHERE x.dev_id = dev.device_id(+);

    -- Cursor for child task records
    CURSOR c_child_tasks (p_mo_hdr_id IN NUMBER) IS
    SELECT transaction_temp_id
         , organization_id
         , subinventory_code
         , locator_id
         , transfer_organization
         , inventory_item_id
         , revision
         , transaction_uom
         , allocated_lpn_id
         , cartonization_id
         , transaction_quantity
         , transfer_subinventory
         , transfer_to_location
         , last_update_date
         , last_updated_by
         , last_update_login
         , get_device_id( mmtt.organization_id
                        , mmtt.subinventory_code
                        , mmtt.locator_id
                        ) dev_id
    FROM mtl_material_transactions_temp mmtt
    WHERE mmtt.move_order_header_id = p_mo_hdr_id
    AND mmtt.parent_line_id IS NOT NULL;

    -- Cursor for parent task records
    CURSOR c_parent_tasks (p_mo_hdr_id IN NUMBER) IS
    SELECT x.transaction_temp_id
         , x.organization_id
         , x.subinventory_code
         , x.locator_id
         , x.transfer_organization
         , x.inventory_item_id
         , x.revision
         , x.transaction_uom
         , x.allocated_lpn_id
         , x.cartonization_id
         , x.transaction_quantity
         , x.transfer_subinventory
         , x.transfer_to_location
         , x.last_update_date
         , x.last_updated_by
         , x.last_update_login
         , x.dev_id
         , NVL(dev.lot_serial_capable,'N') lot_serial_capable_flag
    FROM ( SELECT mmtt.transaction_temp_id
                , mmtt.organization_id
                , mmtt.subinventory_code
                , mmtt.locator_id
                , mmtt.transfer_organization
                , mmtt.inventory_item_id
                , mmtt.revision
                , mmtt.transaction_uom
                , mmtt.allocated_lpn_id
                , mmtt.cartonization_id
                , mmtt.transaction_quantity
                , mmtt.transfer_subinventory
                , mmtt.transfer_to_location
                , mmtt.last_update_date
                , mmtt.last_updated_by
                , mmtt.last_update_login
                , get_device_id( mmtt.organization_id
                               , mmtt.subinventory_code
                               , mmtt.locator_id
                               ) dev_id
           FROM mtl_material_transactions_temp mmtt
           WHERE mmtt.transaction_temp_id IN
                 ( SELECT DISTINCT parent_line_id
                   FROM mtl_material_transactions_temp mmtt1
                   WHERE mmtt1.move_order_header_id = p_mo_hdr_id
                   AND mmtt1.parent_line_id IS NOT NULL
                 )
         ) x,
         wms_devices_b dev
    WHERE x.dev_id = dev.device_id(+);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline                  ||
                    'p_organization_id => '     || TO_CHAR(p_organization_id) || g_newline ||
                    'p_mo_header_id => '        || TO_CHAR(p_mo_header_id)
                  , l_api_name);
    END IF;

    l_api_return_status := fnd_api.g_ret_sts_success;
    wms_device_integration_pvt.is_device_set_up
    ( p_org_id        => p_organization_id
    , p_bus_event_id  => 11
    , x_return_status => l_api_return_status
    );
    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF g_debug = 1 THEN
          print_debug('Error status from is_device_set_up API: '
                      || l_api_return_status, l_api_name);
       END IF;
       IF l_api_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSE
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    END IF;

    IF g_debug = 1 THEN
       print_debug( 'Value of wms_call_device_request: '
                    || wms_device_integration_pvt.wms_call_device_request
                  , l_api_name);
    END IF;

    IF wms_device_integration_pvt.wms_call_device_request = 1 THEN
       l_bus_event_id := wms_device_integration_pvt.wms_be_pick_release;
    ELSE
       RETURN;
    END IF;

    -- BULK fetch the MMTT records for non-bulk tasks
    OPEN c_non_bulk_tasks( p_mo_header_id );

    LOOP --{
      FETCH c_non_bulk_tasks BULK COLLECT INTO t_transaction_temp_id
                                             , t_organization_id
                                             , t_subinventory_code
                                             , t_locator_id
                                             , t_transfer_organization
                                             , t_inventory_item_id
                                             , t_revision
                                             , t_transaction_uom
                                             , t_allocated_lpn_id
                                             , t_cartonization_id
                                             , t_transaction_quantity
                                             , t_transfer_subinventory
                                             , t_transfer_to_location
                                             , t_last_update_date
                                             , t_last_updated_by
                                             , t_last_update_login
                                             , t_dev_id
                                             , t_lot_serial_capable_flag  LIMIT g_bulk_fetch_limit;
      EXIT WHEN t_transaction_temp_id.COUNT = 0;

      -- BULK INSERT the records in WDR (for LOAD)
      FORALL ii IN t_transaction_temp_id.FIRST .. t_transaction_temp_id.LAST
        INSERT INTO wms_device_requests( request_id
                                       , task_id
                                       , task_summary
                                       , task_type_id
                                       , business_event_id
                                       , organization_id
                                       , subinventory_code
                                       , locator_id
                                       , transfer_org_id
                                       , transfer_sub_code
                                       , transfer_loc_id
                                       , inventory_item_id
                                       , revision
                                       , uom
                                       , lpn_id
                                       , xfer_lpn_id
                                       , transaction_quantity
                                       , last_update_date
                                       , last_updated_by
                                       , device_id )
        VALUES( wms_device_integration_pvt.wms_pkRel_dev_req_id --global var same for all pick release lines
              , t_transaction_temp_id(ii)
              , 'Y'
              , 1 --"LOAD"
              , l_bus_event_id
              , t_organization_id(ii)
              , t_subinventory_code(ii)
              , t_locator_id(ii)
              , t_transfer_organization(ii)
              , NULL
              , NULL
              , t_inventory_item_id(ii)
              , t_revision(ii)
              , t_transaction_uom(ii)
              , t_allocated_lpn_id(ii)
              , t_cartonization_id(ii)
              , t_transaction_quantity(ii)
              , SYSDATE
              , g_user_id
              , t_dev_id(ii) );

      -- BULK INSERT the records in WDR (for DROP)
      FORALL jj IN t_transaction_temp_id.FIRST .. t_transaction_temp_id.LAST
        INSERT INTO wms_device_requests( request_id
                                       , task_id
                                       , task_summary
                                       , task_type_id
                                       , business_event_id
                                       , organization_id
                                       , subinventory_code
                                       , locator_id
                                       , transfer_org_id
                                       , transfer_sub_code
                                       , transfer_loc_id
                                       , inventory_item_id
                                       , revision
                                       , uom
                                       , lpn_id
                                       , xfer_lpn_id
                                       , transaction_quantity
                                       , last_update_date
                                       , last_updated_by
                                       , device_id )
        VALUES( wms_device_integration_pvt.wms_pkRel_dev_req_id
              , t_transaction_temp_id(jj)
              , 'Y'
              , 2 --"DROP"
              , l_bus_event_id
              , t_organization_id(jj)
              , NULL
              , NULL
              , t_transfer_organization(jj)
              , t_transfer_subinventory(jj)
              , t_transfer_to_location(jj)
              , t_inventory_item_id(jj)
              , t_revision(jj)
              , t_transaction_uom(jj)
              , t_allocated_lpn_id(jj)
              , t_cartonization_id(jj)
              , t_transaction_quantity(jj)
              , SYSDATE
              , g_user_id
              , t_dev_id(jj) );

      --BULK INSERT lot/serial WDR record
      FORALL kk IN t_transaction_temp_id.FIRST .. t_transaction_temp_id.LAST
        INSERT INTO wms_device_requests( request_id
                                       , task_id
                                       , relation_id
                                       , sequence_id
                                       , task_summary
                                       , task_type_id
                                       , business_event_id
                                       , organization_id
                                       , subinventory_code
                                       , locator_id
                                       , transfer_org_id
                                       , transfer_sub_code
                                       , transfer_loc_id
                                       , inventory_item_id
                                       , revision
                                       , uom
                                       , lot_number
                                       , lot_qty
                                       , serial_number
                                       , lpn_id
                                       , xfer_lpn_id
                                       , transaction_quantity
                                       , device_id
                                       , status_code
                                       , last_update_date
                                       , last_updated_by
                                       , last_update_login )
        ( SELECT wms_device_integration_pvt.wms_pkRel_dev_req_id
                     , t_transaction_temp_id(kk)
                     , NULL
                     , NULL
                     , 'N'
                     , NULL
                     , l_bus_event_id
                     , t_organization_id(kk)
                     , t_subinventory_code(kk)
                     , t_locator_id(kk)
                     , t_transfer_organization(kk)
                     , t_transfer_subinventory(kk)
                     , t_transfer_to_location(kk)
                     , t_inventory_item_id(kk)
                     , t_revision(kk)
                     , t_transaction_uom(kk)
                     , mtlt.lot_number
                     , mtlt.transaction_quantity
                     , NULL
                     , t_allocated_lpn_id(kk)
                     , t_cartonization_id(kk)
                     , mtlt.transaction_quantity
                     , t_dev_id(kk)
                     , 'S'
                     , t_last_update_date(kk)
                     , t_last_updated_by(kk)
                     , t_last_update_login(kk)
                FROM mtl_transaction_lots_temp mtlt
                WHERE mtlt.transaction_temp_id = t_transaction_temp_id(kk)
                AND t_dev_id(kk) IS NOT NULL
                AND t_lot_serial_capable_flag(kk) <> 'N'
                AND mtlt.serial_transaction_temp_id IS NULL
                UNION ALL
                SELECT wms_device_integration_pvt.wms_pkRel_dev_req_id
                     , t_transaction_temp_id(kk)
                     , NULL
                     , NULL
                     , 'N'
                     , NULL
                     , l_bus_event_id
                     , t_organization_id(kk)
                     , t_subinventory_code(kk)
                     , t_locator_id(kk)
                     , t_transfer_organization(kk)
                     , t_transfer_subinventory(kk)
                     , t_transfer_to_location(kk)
                     , t_inventory_item_id(kk)
                     , t_revision(kk)
                     , t_transaction_uom(kk)
                     , NULL
                     , NULL
                     , msnt.fm_serial_number
                     , t_allocated_lpn_id(kk)
                     , t_cartonization_id(kk)
                     , 1
                     , t_dev_id(kk)
                     , 'S'
                     , t_last_update_date(kk)
                     , t_last_updated_by(kk)
                     , t_last_update_login(kk)
                FROM mtl_serial_numbers_temp msnt
                WHERE msnt.transaction_temp_id = t_transaction_temp_id(kk)
                AND t_dev_id(kk) IS NOT NULL
                AND t_lot_serial_capable_flag(kk) <> 'N'
                UNION ALL
                SELECT wms_device_integration_pvt.wms_pkRel_dev_req_id
                     , t_transaction_temp_id(kk)
                     , NULL
                     , NULL
                     , 'N'
                     , NULL
                     , l_bus_event_id
                     , t_organization_id(kk)
                     , t_subinventory_code(kk)
                     , t_locator_id(kk)
                     , t_transfer_organization(kk)
                     , t_transfer_subinventory(kk)
                     , t_transfer_to_location(kk)
                     , t_inventory_item_id(kk)
                     , t_revision(kk)
                     , t_transaction_uom(kk)
                     , mtlt.lot_number
                     , mtlt.transaction_quantity
                     , msnt.fm_serial_number
                     , t_allocated_lpn_id(kk)
                     , t_cartonization_id(kk)
                     , 1
                     , t_dev_id(kk)
                     , 'S'
                     , t_last_update_date(kk)
                     , t_last_updated_by(kk)
                     , t_last_update_login(kk)
                FROM mtl_transaction_lots_temp mtlt, mtl_serial_numbers_temp msnt
                WHERE mtlt.transaction_temp_id = t_transaction_temp_id(kk)
                AND mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
                AND t_dev_id(kk) IS NOT NULL
                AND t_lot_serial_capable_flag(kk) <> 'N' );
    END LOOP; --}

    IF c_non_bulk_tasks%ISOPEN THEN
       CLOSE c_non_bulk_tasks;
    END IF;

    IF g_debug = 1 THEN
       print_debug ('Done processing non-bulk tasks.', l_api_name);
    END IF;

    COMMIT;

    -- Delete the temp tables
    t_transaction_temp_id.DELETE;
    t_organization_id.DELETE;
    t_subinventory_code.DELETE;
    t_locator_id.DELETE;
    t_transfer_organization.DELETE;
    t_inventory_item_id.DELETE;
    t_revision.DELETE;
    t_transaction_uom.DELETE;
    t_allocated_lpn_id.DELETE;
    t_cartonization_id.DELETE;
    t_transaction_quantity.DELETE;
    t_dev_id.DELETE;
    t_lot_serial_capable_flag.DELETE;
    t_transfer_subinventory.DELETE;
    t_transfer_to_location.DELETE;
    t_last_update_date.DELETE;
    t_last_updated_by.DELETE;
    t_last_update_login.DELETE;

    -- BULK fetch the MMTT records for child tasks
    OPEN c_child_tasks( p_mo_header_id );

    LOOP --{
      FETCH c_child_tasks BULK COLLECT INTO t_transaction_temp_id
                                          , t_organization_id
                                          , t_subinventory_code
                                          , t_locator_id
                                          , t_transfer_organization
                                          , t_inventory_item_id
                                          , t_revision
                                          , t_transaction_uom
                                          , t_allocated_lpn_id
                                          , t_cartonization_id
                                          , t_transaction_quantity
                                          , t_transfer_subinventory
                                          , t_transfer_to_location
                                          , t_last_update_date
                                          , t_last_updated_by
                                          , t_last_update_login
                                          , t_dev_id  LIMIT g_bulk_fetch_limit;
      EXIT WHEN t_transaction_temp_id.COUNT = 0;

      -- BULK INSERT the WDR DROP record for child MMTT records
      FORALL ll IN t_transaction_temp_id.FIRST .. t_transaction_temp_id.LAST
        INSERT INTO wms_device_requests( request_id
                                       , task_id
                                       , task_summary
                                       , task_type_id
                                       , business_event_id
                                       , organization_id
                                       , subinventory_code
                                       , locator_id
                                       , transfer_org_id
                                       , transfer_sub_code
                                       , transfer_loc_id
                                       , inventory_item_id
                                       , revision
                                       , uom
                                       , lpn_id
                                       , xfer_lpn_id
                                       , transaction_quantity
                                       , last_update_date
                                       , last_updated_by
                                       , device_id )
        VALUES( wms_device_integration_pvt.wms_pkRel_dev_req_id
              , t_transaction_temp_id(ll)
              , 'Y'
              , 2 --"DROP"
              , l_bus_event_id
              , t_organization_id(ll)
              , NULL
              , NULL
              , t_transfer_organization(ll)
              , t_transfer_subinventory(ll)
              , t_transfer_to_location(ll)
              , t_inventory_item_id(ll)
              , t_revision(ll)
              , t_transaction_uom(ll)
              , t_allocated_lpn_id(ll)
              , t_cartonization_id(ll)
              , t_transaction_quantity(ll)
              , SYSDATE
              , g_user_id
              , t_dev_id(ll) );
    END LOOP; --}

    IF c_child_tasks%ISOPEN THEN
       CLOSE c_child_tasks;
    END IF;

    IF g_debug = 1 THEN
       print_debug ('Done processing bulk-pick child tasks.', l_api_name);
    END IF;

    COMMIT;

    -- Delete the temp tables
    t_transaction_temp_id.DELETE;
    t_organization_id.DELETE;
    t_subinventory_code.DELETE;
    t_locator_id.DELETE;
    t_transfer_organization.DELETE;
    t_inventory_item_id.DELETE;
    t_revision.DELETE;
    t_transaction_uom.DELETE;
    t_allocated_lpn_id.DELETE;
    t_cartonization_id.DELETE;
    t_transaction_quantity.DELETE;
    t_dev_id.DELETE;
    t_lot_serial_capable_flag.DELETE;
    t_transfer_subinventory.DELETE;
    t_transfer_to_location.DELETE;
    t_last_update_date.DELETE;
    t_last_updated_by.DELETE;
    t_last_update_login.DELETE;

    -- BULK fetch the MMTT records for parent tasks
    OPEN c_parent_tasks( p_mo_header_id );

    LOOP --{
      FETCH c_parent_tasks BULK COLLECT INTO t_transaction_temp_id
                                             , t_organization_id
                                             , t_subinventory_code
                                             , t_locator_id
                                             , t_transfer_organization
                                             , t_inventory_item_id
                                             , t_revision
                                             , t_transaction_uom
                                             , t_allocated_lpn_id
                                             , t_cartonization_id
                                             , t_transaction_quantity
                                             , t_transfer_subinventory
                                             , t_transfer_to_location
                                             , t_last_update_date
                                             , t_last_updated_by
                                             , t_last_update_login
                                             , t_dev_id
                                             , t_lot_serial_capable_flag  LIMIT g_bulk_fetch_limit;
      EXIT WHEN t_transaction_temp_id.COUNT = 0;

      IF g_debug = 1 THEN
         print_debug ('Fetched ' || t_transaction_temp_id.COUNT || ' parent tasks', l_api_name);
      END IF;

      --BULK INSERT the LOAD records for parent MMTT records
      FORALL mm IN t_transaction_temp_id.FIRST .. t_transaction_temp_id.LAST
        INSERT INTO wms_device_requests( request_id
                                       , task_id
                                       , task_summary
                                       , task_type_id
                                       , business_event_id
                                       , organization_id
                                       , subinventory_code
                                       , locator_id
                                       , transfer_org_id
                                       , transfer_sub_code
                                       , transfer_loc_id
                                       , inventory_item_id
                                       , revision
                                       , uom
                                       , lpn_id
                                       , xfer_lpn_id
                                       , transaction_quantity
                                       , last_update_date
                                       , last_updated_by
                                       , device_id )
        VALUES( wms_device_integration_pvt.wms_pkRel_dev_req_id
              , t_transaction_temp_id(mm)
              , 'Y'
              , 1 --"LOAD"
              , l_bus_event_id
              , t_organization_id(mm)
              , t_subinventory_code(mm)
              , t_locator_id(mm)
              , t_transfer_organization(mm)
              , NULL
              , NULL
              , t_inventory_item_id(mm)
              , t_revision(mm)
              , t_transaction_uom(mm)
              , t_allocated_lpn_id(mm)
              , t_cartonization_id(mm)
              , t_transaction_quantity(mm)
              , SYSDATE
              , g_user_id
              , t_dev_id(mm) );

      IF g_debug = 1 THEN
         print_debug ('Done inserting LOAD records for parent tasks', l_api_name);
      END IF;

      -- BULK INSERT the lot/serial record for parent MMTT records
      FORALL nn IN t_transaction_temp_id.FIRST .. t_transaction_temp_id.LAST
        INSERT INTO wms_device_requests( request_id
                                       , task_id
                                       , relation_id
                                       , sequence_id
                                       , task_summary
                                       , task_type_id
                                       , business_event_id
                                       , organization_id
                                       , subinventory_code
                                       , locator_id
                                       , transfer_org_id
                                       , transfer_sub_code
                                       , transfer_loc_id
                                       , inventory_item_id
                                       , revision
                                       , uom
                                       , lot_number
                                       , lot_qty
                                       , serial_number
                                       , lpn_id
                                       , xfer_lpn_id
                                       , transaction_quantity
                                       , device_id
                                       , status_code
                                       , last_update_date
                                       , last_updated_by
                                       , last_update_login )
        ( SELECT wms_device_integration_pvt.wms_pkRel_dev_req_id
                     , t_transaction_temp_id(nn)
                     , NULL
                     , NULL
                     , 'N'
                     , NULL
                     , l_bus_event_id
                     , t_organization_id(nn)
                     , t_subinventory_code(nn)
                     , t_locator_id(nn)
                     , t_transfer_organization(nn)
                     , t_transfer_subinventory(nn)
                     , t_transfer_to_location(nn)
                     , t_inventory_item_id(nn)
                     , t_revision(nn)
                     , t_transaction_uom(nn)
                     , mtlt.lot_number
                     , mtlt.transaction_quantity
                     , NULL
                     , t_allocated_lpn_id(nn)
                     , t_cartonization_id(nn)
                     , mtlt.transaction_quantity
                     , t_dev_id(nn)
                     , 'S'
                     , t_last_update_date(nn)
                     , t_last_updated_by(nn)
                     , t_last_update_login(nn)
                FROM mtl_transaction_lots_temp mtlt
                WHERE mtlt.transaction_temp_id = t_transaction_temp_id(nn)
                AND t_dev_id(nn) IS NOT NULL
                AND t_lot_serial_capable_flag(nn) <> 'N'
                AND mtlt.serial_transaction_temp_id IS NULL
                UNION ALL
                SELECT wms_device_integration_pvt.wms_pkRel_dev_req_id
                     , t_transaction_temp_id(nn)
                     , NULL
                     , NULL
                     , 'N'
                     , NULL
                     , l_bus_event_id
                     , t_organization_id(nn)
                     , t_subinventory_code(nn)
                     , t_locator_id(nn)
                     , t_transfer_organization(nn)
                     , t_transfer_subinventory(nn)
                     , t_transfer_to_location(nn)
                     , t_inventory_item_id(nn)
                     , t_revision(nn)
                     , t_transaction_uom(nn)
                     , NULL
                     , NULL
                     , msnt.fm_serial_number
                     , t_allocated_lpn_id(nn)
                     , t_cartonization_id(nn)
                     , 1
                     , t_dev_id(nn)
                     , 'S'
                     , t_last_update_date(nn)
                     , t_last_updated_by(nn)
                     , t_last_update_login(nn)
                FROM mtl_serial_numbers_temp msnt
                WHERE msnt.transaction_temp_id = t_transaction_temp_id(nn)
                AND t_dev_id(nn) IS NOT NULL
                AND t_lot_serial_capable_flag(nn) <> 'N'
                UNION ALL
                SELECT wms_device_integration_pvt.wms_pkRel_dev_req_id
                     , t_transaction_temp_id(nn)
                     , NULL
                     , NULL
                     , 'N'
                     , NULL
                     , l_bus_event_id
                     , t_organization_id(nn)
                     , t_subinventory_code(nn)
                     , t_locator_id(nn)
                     , t_transfer_organization(nn)
                     , t_transfer_subinventory(nn)
                     , t_transfer_to_location(nn)
                     , t_inventory_item_id(nn)
                     , t_revision(nn)
                     , t_transaction_uom(nn)
                     , mtlt.lot_number
                     , mtlt.transaction_quantity
                     , msnt.fm_serial_number
                     , t_allocated_lpn_id(nn)
                     , t_cartonization_id(nn)
                     , 1
                     , t_dev_id(nn)
                     , 'S'
                     , t_last_update_date(nn)
                     , t_last_updated_by(nn)
                     , t_last_update_login(nn)
                FROM mtl_transaction_lots_temp mtlt, mtl_serial_numbers_temp msnt
                WHERE mtlt.transaction_temp_id = t_transaction_temp_id(nn)
                AND mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
                AND t_dev_id(nn) IS NOT NULL
                AND t_lot_serial_capable_flag(nn) <> 'N' );
    END LOOP; --}

    IF c_parent_tasks%ISOPEN THEN
       CLOSE c_parent_tasks;
    END IF;

    IF g_debug = 1 THEN
       print_debug ('Done processing bulk-pick parent tasks.', l_api_name);
    END IF;

    COMMIT;

    l_api_return_status := fnd_api.g_ret_sts_success;
    wms_device_integration_pvt.device_request
    ( p_bus_event     => wms_device_integration_pvt.wms_be_pick_release
    , p_call_ctx      => wms_device_integration_pvt.dev_req_auto
    , p_task_trx_id   => p_organization_id
    , p_org_id        => p_mo_header_id
    , x_request_msg   => l_req_msg
    , x_return_status => l_api_return_status
    , x_msg_count     => l_msg_count
    , x_msg_data      => l_msg_data
    );
    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       IF g_debug = 1 THEN
          print_debug('Error status from device_request API: '
                      || l_api_return_status, l_api_name);
       END IF;
       IF l_api_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSE
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    END IF;

    IF g_debug = 1 THEN
       print_debug('Device request message: '|| l_req_msg, l_api_name);
    END IF;

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

      DELETE FROM wms_device_requests
      WHERE request_id = wms_device_integration_pvt.wms_pkRel_dev_req_id;

      COMMIT;

      IF c_non_bulk_tasks%ISOPEN THEN
         CLOSE c_non_bulk_tasks;
      END IF;
      IF c_child_tasks%ISOPEN THEN
         CLOSE c_child_tasks;
      END IF;
      IF c_parent_tasks%ISOPEN THEN
         CLOSE c_parent_tasks;
      END IF;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;

      DELETE FROM wms_device_requests
      WHERE request_id = wms_device_integration_pvt.wms_pkRel_dev_req_id;

      COMMIT;

      IF c_non_bulk_tasks%ISOPEN THEN
         CLOSE c_non_bulk_tasks;
      END IF;
      IF c_child_tasks%ISOPEN THEN
         CLOSE c_child_tasks;
      END IF;
      IF c_parent_tasks%ISOPEN THEN
         CLOSE c_parent_tasks;
      END IF;

  END insert_device_requests;



  PROCEDURE CreateDynSelSQL
  ( x_pick_slip_sql    OUT  NOCOPY  VARCHAR2
  , x_mmtt_sql         OUT  NOCOPY  VARCHAR2
  , x_num_criteria     OUT  NOCOPY  NUMBER
  , x_return_status    OUT  NOCOPY  VARCHAR2
  ) IS

    l_api_name         VARCHAR2(30) := 'CreateDynSelSQL';
    l_count            NUMBER := 0;
    l_pick_slip_sql    VARCHAR2(2000) := 'SELECT ';
    l_pickslip_base    VARCHAR2(2000) := ' FROM mtl_material_transactions_temp mmtt'
                                      || ' , mtl_txn_request_lines mtrl'
                                      || ' , wsh_inv_delivery_details_v wdd'
                                      || ' WHERE mtrl.header_id = :mo_header_id'
                                      || ' AND mmtt.move_order_line_id = mtrl.line_id'
                                      || ' AND wdd.move_order_line_id = mtrl.line_id';
    l_ps_group_by      VARCHAR2(2000) := ' GROUP BY ';

    l_mmtt_sql_where   VARCHAR2(2000) := '';
    l_mmtt_sql_base    VARCHAR2(2000) := 'SELECT mmtt.transaction_temp_id'
                                      || ' , inv_salesorder.get_salesorder_for_oeheader(wdd.oe_header_id)'
                                      || ' , wdd.oe_line_id'
                                      || ' FROM mtl_material_transactions_temp mmtt'
                                      || ' , mtl_txn_request_lines mtrl'
                                      || ' , wsh_inv_delivery_details_v wdd '
                                      || ' WHERE mtrl.header_id = :mo_header_id'
                                      || ' AND mmtt.move_order_line_id = mtrl.line_id'
                                      || ' AND wdd.move_order_line_id = mtrl.line_id'
                                      || ' AND mmtt.parent_line_id IS NULL';  -- non-bulk tasks

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF g_debug = 1 THEN
       print_debug('Entered ' || l_api_name, l_api_name);
    END IF;

    --
    -- For each grouping attribute that is checked and set to 'Y',
    -- append a column to the SELECT and GROUP BY clauses of Grouping Rule query
    -- Also, append an AND condition to MMTT query
    --
    -- For some columns we can safely avoid using NVL:
    --   Order Number       (Always populated on WDD for pick released lines)
    --   From Subinventory  (Always populated on MMTT for pick suggestions)
    --   From Locator       (Always populated on MMTT for pick suggestions)
    --   Item Number        (NOT NULL column on MMTT)
    --
    IF g_ps_rule_rec.use_order_ps = 'Y' THEN
       l_count := l_count + 1;
       l_pick_slip_sql  := l_pick_slip_sql     || ' wdd.oe_header_id ';
       l_ps_group_by    := l_ps_group_by       || ' wdd.oe_header_id ';

       l_mmtt_sql_where := l_mmtt_sql_where    || ' AND wdd.oe_header_id = TO_NUMBER(:var' || l_count || ')';
    END IF;

    IF g_ps_rule_rec.use_customer_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' wdd.customer_id ';
       l_ps_group_by      := l_ps_group_by    || ' wdd.customer_id ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND NVL(wdd.customer_id,-1) = TO_NUMBER(:var' || l_count || ')';
    END IF;

    IF g_ps_rule_rec.use_carrier_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' wdd.freight_code ';
       l_ps_group_by      := l_ps_group_by    || ' wdd.freight_code ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND NVL(wdd.freight_code,''-1'') = :var' || l_count;
    END IF;

    IF g_ps_rule_rec.use_ship_to_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' wdd.ship_to_location ';
       l_ps_group_by      := l_ps_group_by    || ' wdd.ship_to_location ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND NVL(wdd.ship_to_location,-1) = TO_NUMBER(:var' || l_count || ')';
    END IF;

    IF g_ps_rule_rec.use_ship_priority_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' wdd.shipment_priority_code ';
       l_ps_group_by      := l_ps_group_by    || ' wdd.shipment_priority_code ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND NVL(wdd.shipment_priority_code,''-1'') = :var' || l_count;
    END IF;

    IF g_ps_rule_rec.use_trip_stop_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' wdd.trip_stop_id ';
       l_ps_group_by      := l_ps_group_by    || ' wdd.trip_stop_id ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND NVL(wdd.trip_stop_id,-1) = TO_NUMBER(:var' || l_count || ')';
    END IF;

    IF g_ps_rule_rec.use_delivery_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' wdd.shipping_delivery_id ';
       l_ps_group_by      := l_ps_group_by    || ' wdd.shipping_delivery_id ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND NVL(wdd.shipping_delivery_id,-1) = TO_NUMBER(:var' || l_count || ')';
    END IF;

    IF g_ps_rule_rec.use_src_sub_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' mmtt.subinventory_code ';
       l_ps_group_by      := l_ps_group_by    || ' mmtt.subinventory_code ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND mmtt.subinventory_code = :var' || l_count;
    END IF;

    IF g_ps_rule_rec.use_src_locator_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' mmtt.locator_id ';
       l_ps_group_by      := l_ps_group_by    || ' mmtt.locator_id ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND mmtt.locator_id = TO_NUMBER(:var' || l_count || ')';
    END IF;

    IF g_ps_rule_rec.use_item_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' mmtt.inventory_item_id ';
       l_ps_group_by      := l_ps_group_by    || ' mmtt.inventory_item_id ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND mmtt.inventory_item_id = TO_NUMBER(:var' || l_count || ')';
    END IF;

    IF g_ps_rule_rec.use_revision_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' mmtt.revision ';
       l_ps_group_by      := l_ps_group_by    || ' mmtt.revision ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND NVL(mmtt.revision,''-1'') = :var' || l_count;
    END IF;

    IF g_ps_rule_rec.use_supply_sub_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' mmtt.transfer_subinventory ';
       l_ps_group_by      := l_ps_group_by    || ' mmtt.transfer_subinventory ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND NVL(mmtt.transfer_subinventory,''-1'') = :var' || l_count;
    END IF;

    IF g_ps_rule_rec.use_supply_loc_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' mmtt.transfer_to_location ';
       l_ps_group_by      := l_ps_group_by    || ' mmtt.transfer_to_location ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND NVL(mmtt.transfer_to_location,-1) = TO_NUMBER(:var' || l_count || ')';
    END IF;

    IF g_ps_rule_rec.use_project_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' mmtt.project_id ';
       l_ps_group_by      := l_ps_group_by    || ' mmtt.project_id ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND NVL(mmtt.project_id,-1) = TO_NUMBER(:var' || l_count || ')';
    END IF;

    IF g_ps_rule_rec.use_task_ps = 'Y' THEN
       l_count := l_count + 1;

       IF l_count > 1 THEN
          l_pick_slip_sql := l_pick_slip_sql  || ',';
          l_ps_group_by   := l_ps_group_by    || ',';
       END IF;
       l_pick_slip_sql    := l_pick_slip_sql  || ' mmtt.task_id ';
       l_ps_group_by      := l_ps_group_by    || ' mmtt.task_id ';

       l_mmtt_sql_where   := l_mmtt_sql_where || ' AND NVL(mmtt.task_id,-1) = TO_NUMBER(:var' || l_count || ')';
    END IF;

    -- Concatenate the clauses to form the final two queries
    x_pick_slip_sql := l_pick_slip_sql || l_pickslip_base || l_ps_group_by;
    x_mmtt_sql      := l_mmtt_sql_base || l_mmtt_sql_where;
    x_num_criteria  := l_count;

  EXCEPTION
    WHEN OTHERS THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;
  END CreateDynSelSQL;



  PROCEDURE assign_pick_slip_numbers
  ( p_organization_id   IN           NUMBER
  , p_mo_header_id      IN           NUMBER
  , p_grouping_rule_id  IN           NUMBER
  , x_return_status     OUT  NOCOPY  VARCHAR2
  ) IS

    l_api_name                   VARCHAR2(30) := 'assign_pick_slip_numbers';
    l_grouping_rule_id           NUMBER;
    l_organization_id            NUMBER;
    l_pick_slip_sql              VARCHAR2(2000);
    l_mmtt_sql                   VARCHAR2(2000);
    l_num_criteria               NUMBER;
    l_pick_slip_number           NUMBER;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    l_api_return_status          VARCHAR2(1);
    l_dummy                      VARCHAR2(1);

    t_grp_crit1                  tbl_varchar50;
    t_grp_crit2                  tbl_varchar50;
    t_grp_crit3                  tbl_varchar50;
    t_grp_crit4                  tbl_varchar50;
    t_grp_crit5                  tbl_varchar50;
    t_grp_crit6                  tbl_varchar50;
    t_grp_crit7                  tbl_varchar50;
    t_grp_crit8                  tbl_varchar50;
    t_grp_crit9                  tbl_varchar50;
    t_grp_crit10                 tbl_varchar50;
    t_grp_crit11                 tbl_varchar50;
    t_grp_crit12                 tbl_varchar50;
    t_grp_crit13                 tbl_varchar50;
    t_grp_crit14                 tbl_varchar50;
    t_grp_crit15                 tbl_varchar50;

    tbl_transaction_temp_id      tbl_num;
    tbl_sales_order_id           tbl_num;
    tbl_oe_line_id               tbl_num;
    tbl_parent_temp_id           tbl_num;

    TYPE l_ref_cur   IS REF CURSOR;
    l_pick_slip_cur  l_ref_cur;
    l_mmtt_cur       l_ref_cur;

    CURSOR c_ps_rule (p_pgr_id IN NUMBER) IS
    SELECT NVL(order_number_flag, 'N')
         , NVL(customer_flag, 'N')
         , NVL(ship_to_flag, 'N')
         , NVL(carrier_flag, 'N')
         , NVL(shipment_priority_flag, 'N')
         , NVL(trip_stop_flag, 'N')
         , NVL(delivery_flag, 'N')
         , NVL(subinventory_flag, 'N')
         , NVL(locator_flag, 'N')
         , NVL(dest_sub_flag, 'N')
         , NVL(dest_loc_flag, 'N')
         , NVL(project_flag, 'N')
         , NVL(task_flag, 'N')
         , NVL(item_flag, 'N')
         , NVL(revision_flag, 'N')
         , NVL(lot_flag, 'N')
         , NVL(pick_method, '-99')
    FROM wsh_pick_grouping_rules
    WHERE pick_grouping_rule_id = p_pgr_id;

    CURSOR c_mold IS
    SELECT mmtt.transaction_temp_id
         , inv_salesorder.get_salesorder_for_oeheader(wdd.oe_header_id)
         , wdd.oe_line_id
    FROM mtl_material_transactions_temp  mmtt
       , mtl_txn_request_lines           mol
       , wsh_inv_delivery_details_v      wdd
    WHERE mmtt.move_order_line_id = mol.line_id
    AND mol.header_id = p_mo_header_id
    AND wdd.move_order_line_id = mol.line_id
    AND mmtt.parent_line_id IS NULL;  -- exclude bulk pick child tasks

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT pick_slip_sp;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline               ||
                    'p_organization_id => '     || p_organization_id       || g_newline ||
                    'p_mo_header_id => '        || p_mo_header_id          || g_newline ||
                    'p_grouping_rule_id => '    || p_grouping_rule_id      || g_newline
                  , l_api_name );
    END IF;

    -- Need to handle the case where pick slip numbering
    -- was already done for rulebased cartonization
    BEGIN
       SELECT 'x' INTO l_dummy
         FROM dual
        WHERE EXISTS
            ( SELECT 'x'
                FROM mtl_material_transactions_temp  mmtt1
               WHERE mmtt1.move_order_header_id = p_mo_header_id
                 AND mmtt1.parent_line_id   IS NULL
                 AND mmtt1.pick_slip_number IS NULL
            );

       IF g_debug = 1 THEN
          print_debug( 'MMTTs exist which require pick slip numbering.'
                     , l_api_name);
       END IF;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          IF g_debug = 1 THEN
             print_debug( 'Pick slip numbering not required, exiting.'
                        , l_api_name);
          END IF;
          RETURN;
       WHEN OTHERS THEN
          IF g_debug = 1 THEN
             print_debug( 'Error checking pick slip numbering status: '
                          || SQLERRM, l_api_name);
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
    END;

    -- Setting the Grouping rule id. If PickSlip grouping rule Id is not passed,
    -- then fetch from mtl_txn_request_headers
    IF p_grouping_rule_id IS NOT NULL THEN
       l_grouping_rule_id := p_grouping_rule_id;
    ELSE
       BEGIN
          SELECT grouping_rule_id, organization_id
          INTO l_grouping_rule_id, l_organization_id
          FROM mtl_txn_request_headers
          WHERE header_id = p_mo_header_id;
       EXCEPTION
          WHEN OTHERS THEN
             IF g_debug = 1 THEN
                print_debug ('Error querying grouping rule from MO header: '
                             || SQLERRM, l_api_name);
             END IF;
             RAISE fnd_api.g_exc_unexpected_error;
       END;
    END IF;

    -- If Grouping rule id is still null, fetch it from wsh_parameters
    -- (the organization-level default)
    IF l_grouping_rule_id IS NULL THEN
       BEGIN
          SELECT pick_slip_rule_id
          INTO l_grouping_rule_id
          FROM wsh_parameters
          WHERE organization_id = p_organization_id;
       EXCEPTION
          WHEN OTHERS THEN
             IF g_debug = 1 THEN
                print_debug ('Error querying grouping rule from Shipping parameters: '
                            || SQLERRM, l_api_name);
             END IF;
             RAISE fnd_api.g_exc_unexpected_error;
       END;
    END IF;

    -- Fetch the attributes for the Pick Slip Grouping Rule
    OPEN c_ps_rule(l_grouping_rule_id);
    FETCH c_ps_rule INTO g_ps_rule_rec.use_order_ps
                       , g_ps_rule_rec.use_customer_ps
                       , g_ps_rule_rec.use_ship_to_ps
                       , g_ps_rule_rec.use_carrier_ps
                       , g_ps_rule_rec.use_ship_priority_ps
                       , g_ps_rule_rec.use_trip_stop_ps
                       , g_ps_rule_rec.use_delivery_ps
                       , g_ps_rule_rec.use_src_sub_ps
                       , g_ps_rule_rec.use_src_locator_ps
                       , g_ps_rule_rec.use_supply_sub_ps
                       , g_ps_rule_rec.use_supply_loc_ps
                       , g_ps_rule_rec.use_project_ps
                       , g_ps_rule_rec.use_task_ps
                       , g_ps_rule_rec.use_item_ps
                       , g_ps_rule_rec.use_revision_ps
                       , g_ps_rule_rec.use_lot_ps
                       , g_ps_rule_rec.pick_method;
    CLOSE c_ps_rule;

    g_ps_rule_rec.grouping_rule_id := l_grouping_rule_id;
    IF g_debug = 1 THEN
       print_debug( 'Pick method : ' || g_ps_rule_rec.pick_method
                  , l_api_name);
    END IF;

    -- If Pick method is not Cluster Pick
    IF (g_ps_rule_rec.pick_method <> g_cluster_pick_method) THEN --{

       -- Call CreateDynSelSQL API which constructs and returns the two dynamic queries,
       -- l_pick_slip_sql gives the grouping criteria and l_mmtt_sql dynamically gives the
       -- records in MMTT to be stamped with Pick Slip Number based on each record
       -- returned by l_pick_slip_sql
       l_api_return_status := fnd_api.g_ret_sts_success;
       CreateDynSelSQL(
         x_pick_slip_sql     => l_pick_slip_sql
       , x_mmtt_sql          => l_mmtt_sql
       , x_num_criteria      => l_num_criteria
       , x_return_status     => l_api_return_status);

       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from CreateDynSelSQL: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

       IF g_debug = 1 THEN
          print_debug( 'Number of grouping criteria returned : ' || l_num_criteria, l_api_name );
          print_debug( 'Pick Slip grouping criteria dynamic query : ' || l_pick_slip_sql, l_api_name );
          print_debug( 'Dynamic query for matching MMTT rows: '  || l_mmtt_sql, l_api_name );
       END IF;

       -- If no grouping criteria returned
       IF l_num_criteria < 1 THEN
          IF g_debug = 1 THEN
             print_debug( 'No Grouping criteria found', l_api_name );
          END IF;
          RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- Open grouping criteria cursor. Each row in this cursor represents a pick slip
       OPEN l_pick_slip_cur FOR l_pick_slip_sql USING p_mo_header_id;

       LOOP --{
          -- Bulk fetch the grouping criteria based on number of
          -- grouping attributes returned(l_num_criteria)
          IF l_num_criteria = 1 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 2 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 3 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 4 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3
                                                   , t_grp_crit4 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 5 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3
                                                   , t_grp_crit4
                                                   , t_grp_crit5 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 6 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3
                                                   , t_grp_crit4
                                                   , t_grp_crit5
                                                   , t_grp_crit6 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 7 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3
                                                   , t_grp_crit4
                                                   , t_grp_crit5
                                                   , t_grp_crit6
                                                   , t_grp_crit7 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 8 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3
                                                   , t_grp_crit4
                                                   , t_grp_crit5
                                                   , t_grp_crit6
                                                   , t_grp_crit7
                                                   , t_grp_crit8 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 9 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3
                                                   , t_grp_crit4
                                                   , t_grp_crit5
                                                   , t_grp_crit6
                                                   , t_grp_crit7
                                                   , t_grp_crit8
                                                   , t_grp_crit9 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 10 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3
                                                   , t_grp_crit4
                                                   , t_grp_crit5
                                                   , t_grp_crit6
                                                   , t_grp_crit7
                                                   , t_grp_crit8
                                                   , t_grp_crit9
                                                   , t_grp_crit10 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 11 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3
                                                   , t_grp_crit4
                                                   , t_grp_crit5
                                                   , t_grp_crit6
                                                   , t_grp_crit7
                                                   , t_grp_crit8
                                                   , t_grp_crit9
                                                   , t_grp_crit10
                                                   , t_grp_crit11 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 12 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3
                                                   , t_grp_crit4
                                                   , t_grp_crit5
                                                   , t_grp_crit6
                                                   , t_grp_crit7
                                                   , t_grp_crit8
                                                   , t_grp_crit9
                                                   , t_grp_crit10
                                                   , t_grp_crit11
                                                   , t_grp_crit12 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 13 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3
                                                   , t_grp_crit4
                                                   , t_grp_crit5
                                                   , t_grp_crit6
                                                   , t_grp_crit7
                                                   , t_grp_crit8
                                                   , t_grp_crit9
                                                   , t_grp_crit10
                                                   , t_grp_crit11
                                                   , t_grp_crit12
                                                   , t_grp_crit13 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 14 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3
                                                   , t_grp_crit4
                                                   , t_grp_crit5
                                                   , t_grp_crit6
                                                   , t_grp_crit7
                                                   , t_grp_crit8
                                                   , t_grp_crit9
                                                   , t_grp_crit10
                                                   , t_grp_crit11
                                                   , t_grp_crit12
                                                   , t_grp_crit13
                                                   , t_grp_crit14 LIMIT g_bulk_fetch_limit;
          ELSIF l_num_criteria = 15 THEN
             FETCH l_pick_slip_cur BULK COLLECT INTO t_grp_crit1
                                                   , t_grp_crit2
                                                   , t_grp_crit3
                                                   , t_grp_crit4
                                                   , t_grp_crit5
                                                   , t_grp_crit6
                                                   , t_grp_crit7
                                                   , t_grp_crit8
                                                   , t_grp_crit9
                                                   , t_grp_crit10
                                                   , t_grp_crit11
                                                   , t_grp_crit12
                                                   , t_grp_crit13
                                                   , t_grp_crit14
                                                   , t_grp_crit15 LIMIT g_bulk_fetch_limit;
          END IF;

          EXIT WHEN t_grp_crit1.COUNT = 0;

          FOR ii IN t_grp_crit1.FIRST .. t_grp_crit1.LAST LOOP --{

             -- Get the next pick slip number using the sequence
             SELECT wsh_pick_slip_numbers_s.NEXTVAL
             INTO l_pick_slip_number
             FROM DUAL;

             -- Open cursor to fetch matching MMTT rows based on number of Grouping attributes returned
             IF l_num_criteria = 1 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1');
             ELSIF l_num_criteria = 2 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1');
             ELSIF l_num_criteria = 3 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1');
             ELSIF l_num_criteria = 4 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1')
                                                   , NVL(t_grp_crit4(ii),'-1');
             ELSIF l_num_criteria = 5 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1')
                                                   , NVL(t_grp_crit4(ii),'-1')
                                                   , NVL(t_grp_crit5(ii),'-1');
             ELSIF l_num_criteria = 6 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1')
                                                   , NVL(t_grp_crit4(ii),'-1')
                                                   , NVL(t_grp_crit5(ii),'-1')
                                                   , NVL(t_grp_crit6(ii),'-1');
             ELSIF l_num_criteria = 7 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1')
                                                   , NVL(t_grp_crit4(ii),'-1')
                                                   , NVL(t_grp_crit5(ii),'-1')
                                                   , NVL(t_grp_crit6(ii),'-1')
                                                   , NVL(t_grp_crit7(ii),'-1');
             ELSIF l_num_criteria = 8 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1')
                                                   , NVL(t_grp_crit4(ii),'-1')
                                                   , NVL(t_grp_crit5(ii),'-1')
                                                   , NVL(t_grp_crit6(ii),'-1')
                                                   , NVL(t_grp_crit7(ii),'-1')
                                                   , NVL(t_grp_crit8(ii),'-1');
             ELSIF l_num_criteria = 9 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1')
                                                   , NVL(t_grp_crit4(ii),'-1')
                                                   , NVL(t_grp_crit5(ii),'-1')
                                                   , NVL(t_grp_crit6(ii),'-1')
                                                   , NVL(t_grp_crit7(ii),'-1')
                                                   , NVL(t_grp_crit8(ii),'-1')
                                                   , NVL(t_grp_crit9(ii),'-1');
             ELSIF l_num_criteria = 10 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1')
                                                   , NVL(t_grp_crit4(ii),'-1')
                                                   , NVL(t_grp_crit5(ii),'-1')
                                                   , NVL(t_grp_crit6(ii),'-1')
                                                   , NVL(t_grp_crit7(ii),'-1')
                                                   , NVL(t_grp_crit8(ii),'-1')
                                                   , NVL(t_grp_crit9(ii),'-1')
                                                   , NVL(t_grp_crit10(ii),'-1');
             ELSIF l_num_criteria = 11 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1')
                                                   , NVL(t_grp_crit4(ii),'-1')
                                                   , NVL(t_grp_crit5(ii),'-1')
                                                   , NVL(t_grp_crit6(ii),'-1')
                                                   , NVL(t_grp_crit7(ii),'-1')
                                                   , NVL(t_grp_crit8(ii),'-1')
                                                   , NVL(t_grp_crit9(ii),'-1')
                                                   , NVL(t_grp_crit10(ii),'-1')
                                                   , NVL(t_grp_crit11(ii),'-1');
             ELSIF l_num_criteria = 12 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1')
                                                   , NVL(t_grp_crit4(ii),'-1')
                                                   , NVL(t_grp_crit5(ii),'-1')
                                                   , NVL(t_grp_crit6(ii),'-1')
                                                   , NVL(t_grp_crit7(ii),'-1')
                                                   , NVL(t_grp_crit8(ii),'-1')
                                                   , NVL(t_grp_crit9(ii),'-1')
                                                   , NVL(t_grp_crit10(ii),'-1')
                                                   , NVL(t_grp_crit11(ii),'-1')
                                                   , NVL(t_grp_crit12(ii),'-1');
             ELSIF l_num_criteria = 13 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1')
                                                   , NVL(t_grp_crit4(ii),'-1')
                                                   , NVL(t_grp_crit5(ii),'-1')
                                                   , NVL(t_grp_crit6(ii),'-1')
                                                   , NVL(t_grp_crit7(ii),'-1')
                                                   , NVL(t_grp_crit8(ii),'-1')
                                                   , NVL(t_grp_crit9(ii),'-1')
                                                   , NVL(t_grp_crit10(ii),'-1')
                                                   , NVL(t_grp_crit11(ii),'-1')
                                                   , NVL(t_grp_crit12(ii),'-1')
                                                   , NVL(t_grp_crit13(ii),'-1');
             ELSIF l_num_criteria = 14 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1')
                                                   , NVL(t_grp_crit4(ii),'-1')
                                                   , NVL(t_grp_crit5(ii),'-1')
                                                   , NVL(t_grp_crit6(ii),'-1')
                                                   , NVL(t_grp_crit7(ii),'-1')
                                                   , NVL(t_grp_crit8(ii),'-1')
                                                   , NVL(t_grp_crit9(ii),'-1')
                                                   , NVL(t_grp_crit10(ii),'-1')
                                                   , NVL(t_grp_crit11(ii),'-1')
                                                   , NVL(t_grp_crit12(ii),'-1')
                                                   , NVL(t_grp_crit13(ii),'-1')
                                                   , NVL(t_grp_crit14(ii),'-1');
             ELSIF l_num_criteria = 15 THEN
                OPEN l_mmtt_cur FOR l_mmtt_sql USING p_mo_header_id
                                                   , NVL(t_grp_crit1(ii),'-1')
                                                   , NVL(t_grp_crit2(ii),'-1')
                                                   , NVL(t_grp_crit3(ii),'-1')
                                                   , NVL(t_grp_crit4(ii),'-1')
                                                   , NVL(t_grp_crit5(ii),'-1')
                                                   , NVL(t_grp_crit6(ii),'-1')
                                                   , NVL(t_grp_crit7(ii),'-1')
                                                   , NVL(t_grp_crit8(ii),'-1')
                                                   , NVL(t_grp_crit9(ii),'-1')
                                                   , NVL(t_grp_crit10(ii),'-1')
                                                   , NVL(t_grp_crit11(ii),'-1')
                                                   , NVL(t_grp_crit12(ii),'-1')
                                                   , NVL(t_grp_crit13(ii),'-1')
                                                   , NVL(t_grp_crit14(ii),'-1')
                                                   , NVL(t_grp_crit15(ii),'-1');
             END IF;

             LOOP --{
                -- BULK FETCH set of matching MMTTs
                FETCH l_mmtt_cur BULK COLLECT
                INTO tbl_transaction_temp_id
                   , tbl_sales_order_id
                   , tbl_oe_line_id LIMIT g_bulk_fetch_limit;
                EXIT WHEN tbl_transaction_temp_id.COUNT = 0;

                -- Assign the pick slip number to the records in MTL_MATERIAL_TRANSACTIONS_TEMP
                FORALL jj IN tbl_transaction_temp_id.FIRST .. tbl_transaction_temp_id.LAST
                UPDATE mtl_material_transactions_temp
                SET pick_slip_number = l_pick_slip_number
                  , transaction_source_id   = tbl_sales_order_id(jj)
                  , trx_source_line_id      = tbl_oe_line_id(jj)
                  , demand_source_header_id = tbl_sales_order_id(jj)
                  , demand_source_line      = tbl_oe_line_id(jj)
                WHERE transaction_temp_id = tbl_transaction_temp_id(jj);
             END LOOP; --}

             IF l_mmtt_cur%ISOPEN THEN
                CLOSE l_mmtt_cur;
             END IF;
          END LOOP; --}
       END LOOP; --}

       IF l_pick_slip_cur%ISOPEN THEN
          CLOSE l_pick_slip_cur;
       END IF;
    --}
    ELSIF (g_ps_rule_rec.pick_method = g_cluster_pick_method) THEN
       OPEN c_mold;
       LOOP --{
          FETCH c_mold BULK COLLECT
          INTO tbl_transaction_temp_id
             , tbl_sales_order_id
             , tbl_oe_line_id LIMIT g_bulk_fetch_limit;
          EXIT WHEN tbl_transaction_temp_id.COUNT = 0;

          FORALL jj IN tbl_transaction_temp_id.FIRST .. tbl_transaction_temp_id.LAST
            UPDATE mtl_material_transactions_temp
            SET pick_slip_number = wsh_pick_slip_numbers_s.NEXTVAL
              , transaction_source_id   = tbl_sales_order_id(jj)
              , trx_source_line_id      = tbl_oe_line_id(jj)
              , demand_source_header_id = tbl_sales_order_id(jj)
              , demand_source_line      = tbl_oe_line_id(jj)
            WHERE transaction_temp_id = tbl_transaction_temp_id(jj);
       END LOOP; --}
       IF c_mold%ISOPEN THEN
          CLOSE c_mold;
       END IF;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO pick_slip_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );
      IF g_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;
      IF c_ps_rule%ISOPEN THEN
         CLOSE c_ps_rule;
      END IF;
      IF c_mold%ISOPEN THEN
         CLOSE c_mold;
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO pick_slip_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF g_debug = 1 THEN
         print_debug ('Other error: ' || SQLERRM, l_api_name);
      END IF;
      IF c_ps_rule%ISOPEN THEN
         CLOSE c_ps_rule;
      END IF;
      IF c_mold%ISOPEN THEN
         CLOSE c_mold;
      END IF;

  END assign_pick_slip_numbers;



  PROCEDURE print_labels
  ( p_batch_id        IN            NUMBER
  , x_return_status   OUT  NOCOPY   VARCHAR2
  ) IS

    l_api_name            VARCHAR2(30) := 'print_labels';
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);

    l_api_return_status   VARCHAR2(1);
    l_lbl_api_status      VARCHAR2(1);
    l_label_status        VARCHAR2(500);
    l_wpr_rec             wms_pr_workers%ROWTYPE;
    t_carton_id	          inv_label.transaction_id_rec_type;
    t_cspk_temp_id	  inv_label.transaction_id_rec_type;
    l_wpr_counter         NUMBER;
    l_txn_batch_ctr       NUMBER;
    t_txn_batch_id        tbl_num;

    CURSOR c_lblprnt (p_batch_id NUMBER) IS
    SELECT transaction_temp_id
      FROM mtl_material_transactions_temp
     WHERE transaction_batch_id = p_batch_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF g_debug = 1 THEN
       print_debug( 'Entered with parameters: ' || g_newline         ||
                    'p_batch_id => '            || p_batch_id
                  , l_api_name);
    END IF;

    l_wpr_counter := 0;
    LOOP --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       fetch_next_wpr_rec
       ( p_batch_id      => p_batch_id
       , p_mode          => 'CRTN_LBL'
       , x_wpr_rec       => l_wpr_rec
       , x_return_status => l_api_return_status
       );

       IF l_api_return_status = 'N' THEN --{
          IF l_wpr_counter > 0 THEN
             IF g_debug = 1 THEN
                print_debug ('No more CRTN_LBL records in WPR, print remaining', l_api_name);
             END IF;
             l_lbl_api_status := fnd_api.g_ret_sts_success;
             inv_label.print_label
             ( x_return_status      => l_lbl_api_status
             , x_msg_count          => l_msg_count
             , x_msg_data           => l_msg_data
             , x_label_status       => l_label_status
             , p_api_version        => 1.0
             , p_print_mode         => 1
             , p_business_flow_code => 22
             , p_transaction_id     => t_carton_id
             );

             FORALL ii IN t_carton_id.FIRST .. t_carton_id.LAST
                DELETE wms_pr_workers
                WHERE cartonization_id = t_carton_id(ii);

             IF l_lbl_api_status <> fnd_api.g_ret_sts_success THEN
                FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');
                FND_MSG_PUB.ADD;
                RAISE fnd_api.g_exc_error;
             END IF;
             l_wpr_counter := 0;
             t_carton_id.DELETE;
             EXIT;
          ELSE
             IF g_debug = 1 THEN
                print_debug ('No more CRTN_LBL records in WPR', l_api_name);
             END IF;
             EXIT;
          END IF;
       --}
       ELSIF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from fetch_next_wpr_rec: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

       l_wpr_counter := l_wpr_counter + 1;
       t_carton_id (l_wpr_counter) := l_wpr_rec.cartonization_id;
       IF g_debug = 1 THEN
          print_debug( 'No. of cartonization IDs fetched so far: ' || l_wpr_counter
                     , l_api_name);
       END IF;

       IF l_wpr_counter >= 100 THEN
          l_lbl_api_status := fnd_api.g_ret_sts_success;
          inv_label.print_label
          ( x_return_status      => l_lbl_api_status
          , x_msg_count          => l_msg_count
          , x_msg_data           => l_msg_data
          , x_label_status       => l_label_status
          , p_api_version        => 1.0
          , p_print_mode         => 1
          , p_business_flow_code => 22
          , p_transaction_id     => t_carton_id
          );

          FORALL jj IN t_carton_id.FIRST .. t_carton_id.LAST
             DELETE wms_pr_workers
             WHERE cartonization_id = t_carton_id(jj);

          IF l_lbl_api_status <> fnd_api.g_ret_sts_success THEN
             FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');
             FND_MSG_PUB.ADD;
             RAISE fnd_api.g_exc_error;
          END IF;
          l_wpr_counter := 0;
          t_carton_id.DELETE;
       END IF;
    END LOOP; --}

    l_txn_batch_ctr := 0;
    LOOP --{
       l_api_return_status := fnd_api.g_ret_sts_success;
       fetch_next_wpr_rec
       ( p_batch_id      => p_batch_id
       , p_mode          => 'CSPK_LBL'
       , x_wpr_rec       => l_wpr_rec
       , x_return_status => l_api_return_status
       );

       IF l_api_return_status = 'N' THEN
          IF g_debug = 1 THEN
             print_debug ( 'No more records in WPR', l_api_name );
          END IF;
          EXIT;
       ELSIF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF g_debug = 1 THEN
             print_debug('Error status from fetch_next_wpr_rec: '
                         || l_api_return_status, l_api_name);
          END IF;
          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;

       l_txn_batch_ctr := l_txn_batch_ctr + 1;
       t_txn_batch_id(l_txn_batch_ctr) := l_wpr_rec.transaction_batch_id;

       OPEN c_lblprnt (l_wpr_rec.transaction_batch_id);
       FETCH c_lblprnt BULK COLLECT INTO t_cspk_temp_id;
       CLOSE c_lblprnt;

       l_api_return_status := fnd_api.g_ret_sts_success;
       inv_label.print_label
       ( x_return_status      => l_api_return_status
       , x_msg_count          => l_msg_count
       , x_msg_data           => l_msg_data
       , x_label_status       => l_label_status
       , p_api_version        => 1.0
       , p_print_mode         => 1
       , p_business_flow_code => 42
       , p_transaction_id     => t_cspk_temp_id
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          FND_MESSAGE.SET_NAME('WMS', 'WMS_PR_LABEL_FAIL');   -- TBD
          FND_MSG_PUB.ADD;
          RAISE fnd_api.g_exc_error;
       END IF;
       t_cspk_temp_id.DELETE;

    END LOOP; --}

    IF t_txn_batch_id.COUNT > 0 THEN
       FORALL kk IN t_txn_batch_id.FIRST .. t_txn_batch_id.LAST
          UPDATE mtl_material_transactions_temp
             SET transaction_batch_id = NULL
           WHERE transaction_batch_id = t_txn_batch_id(kk);

       FORALL mm IN t_txn_batch_id.FIRST .. t_txn_batch_id.LAST
          DELETE FROM wms_pr_workers
          WHERE transaction_batch_id = t_txn_batch_id(mm);
    END IF;

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
       IF c_lblprnt%ISOPEN THEN
          CLOSE c_lblprnt;
       END IF;
       IF t_carton_id.COUNT > 0 THEN
          FORALL jj IN t_carton_id.FIRST .. t_carton_id.LAST
             DELETE wms_pr_workers
             WHERE cartonization_id = t_carton_id(jj);
          COMMIT;
       END IF;
       IF t_txn_batch_id.COUNT > 0 THEN
          FORALL kk IN t_txn_batch_id.FIRST .. t_txn_batch_id.LAST
             UPDATE mtl_material_transactions_temp
                SET transaction_batch_id = NULL
              WHERE transaction_batch_id = t_txn_batch_id(kk);
          FORALL mm IN t_txn_batch_id.FIRST .. t_txn_batch_id.LAST
             DELETE FROM wms_pr_workers
             WHERE transaction_batch_id = t_txn_batch_id(mm);
          COMMIT;
       END IF;

    WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       IF g_debug = 1 THEN
          print_debug ('Other error: ' || SQLERRM, l_api_name);
       END IF;
       IF c_lblprnt%ISOPEN THEN
          CLOSE c_lblprnt;
       END IF;
       IF t_carton_id.COUNT > 0 THEN
          FORALL jj IN t_carton_id.FIRST .. t_carton_id.LAST
             DELETE wms_pr_workers
             WHERE cartonization_id = t_carton_id(jj);
          COMMIT;
       END IF;
       IF t_txn_batch_id.COUNT > 0 THEN
          FORALL kk IN t_txn_batch_id.FIRST .. t_txn_batch_id.LAST
             UPDATE mtl_material_transactions_temp
                SET transaction_batch_id = NULL
              WHERE transaction_batch_id = t_txn_batch_id(kk);
          FORALL mm IN t_txn_batch_id.FIRST .. t_txn_batch_id.LAST
             DELETE FROM wms_pr_workers
             WHERE transaction_batch_id = t_txn_batch_id(mm);
          COMMIT;
       END IF;

  END print_labels;



END wms_postalloc_pvt;

/
