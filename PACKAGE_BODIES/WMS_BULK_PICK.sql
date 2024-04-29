--------------------------------------------------------
--  DDL for Package Body WMS_BULK_PICK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_BULK_PICK" AS
/* $Header: WMSBKPIB.pls 120.2.12010000.4 2009/06/24 22:59:37 mchemban ship $*/

--
-- File        : WMSBKPIS.pls
-- Content     : WMS_bulk_pick package specification
-- Description : WMS bulk picking API for mobile application
-- Notes       :
-- Modified    : 07/30/2003 jali created
  g_pkg_name CONSTANT VARCHAR2(30)  := 'wms_bulk_pick';
  g_trace_on NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  g_newline       CONSTANT VARCHAR2(10)  := fnd_global.newline;

  -- Bug# 4185621: added global variable to be used later
  l_g_task_loaded                 CONSTANT NUMBER  := 4;


  PROCEDURE mydebug(p_msg IN VARCHAR2, p_api_name IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
   -- dbms_output.put_line(p_msg);
    IF g_trace_on = 1 THEN
       inv_mobile_helper_functions.tracelog( p_err_msg => p_msg
                                           , p_module  => 'WMS_BULK_PICK.' || p_api_name
                                           , p_level   => 4
                                           );
    END IF;
  END;


--
PROCEDURE wms_concurrent_bulk_process(
                 errbuf                    OUT    NOCOPY VARCHAR2
      ,retcode                   OUT    NOCOPY NUMBER
                ,p_organization_id    IN NUMBER
          ,p_start_mo_request_number  IN  VARCHAR2 :=null
  ,p_end_mo_request_number   IN VARCHAR2  :=null
  ,p_start_release_date IN VARCHAR2 :=null
  ,p_end_release_date IN VARCHAR2 :=null
  ,p_subinventory_code IN VARCHAR2 :=null
  ,p_item_id            IN NUMBER := null
  ,p_delivery_id IN NUMBER := null
  ,p_trip_id IN NUMBER := null
  ,p_only_sub_item IN NUMBER := null
  ) IS

l_bulk_input wms_bulk_pick.bulk_input_rec;
l_return_status  varchar2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_api_name CONSTANT VARCHAR2(30)  := 'wms_concurrent_bulk_process';
l_api_version CONSTANT NUMBER        := 1.0;
ret BOOLEAN;
l_debug              NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN

    -- Initialize API return status to success
    l_return_status  := fnd_api.g_ret_sts_success;
    -- Start API body

    IF l_debug=1 THEN
        mydebug('Input parameters:'                           ||g_newline||
                'p_organizaton_id '||p_organization_id        ||g_newline||
                'p_start_mo_request_number '||p_start_mo_request_number ||g_newline||
                'p_end_mo_request_number ' ||p_end_mo_request_number ||g_newline||
                'p_start_release_date '||p_start_release_date ||g_newline||
                'p_end_release_date '||p_end_release_date ||g_newline||
                'p_subinventory_code ' || p_subinventory_code ||g_newline||
                'p_item_id ' || p_item_id ||g_newline||
                'p_delivery_id ' || p_delivery_id ||g_newline||
                'p_trip_id ' || p_trip_id ||g_newline||
                'p_only_sub_item' || p_only_sub_item
                ,l_api_name);
    END IF;
    l_bulk_input.organization_id := p_organization_id;
    l_bulk_input.start_mo_request_number := p_start_mo_request_number;
    l_bulk_input.end_mo_request_number := p_end_mo_request_number;
    l_bulk_input.start_release_date :=FND_DATE.canonical_to_date(p_start_release_date);
    l_bulk_input.end_release_date :=FND_DATE.canonical_to_date(p_end_release_date);
    l_bulk_input.subinventory_code :=p_subinventory_code;
    l_bulk_input.item_id    := p_item_id;
    l_bulk_input.delivery_id := p_delivery_id;
    l_bulk_input.trip_id := p_trip_id;
    l_bulk_input.only_sub_item := p_only_sub_item;

    SAVEPOINT concurrent_bulk_process;
    -- calling cartonize API to do the bulking
    wms_cartnzn_pub.cartonize(p_api_version            => 1.0
                              ,x_return_status         => l_return_status
                              ,x_msg_count             => l_msg_count
                              ,x_msg_data              => l_msg_data
                              ,p_out_bound             => 'Y'
                              ,p_org_id                => p_organization_id
                              ,p_move_order_header_id  => -1   -- -1 to indicate this is come from bulk concurrent program
                              ,p_disable_cartonization => 'Y'
                              ,p_transaction_header_id => 0   -- default
                              ,p_input_for_bulk  => l_bulk_input);
    IF (l_return_status = fnd_api.g_ret_sts_success) THEN
      ret      := fnd_concurrent.set_completion_status('NORMAL', l_msg_data);
      retcode  := 0;
    ELSE
      ret      := fnd_concurrent.set_completion_status('ERROR', l_msg_data);
      retcode  := 2;
      errbuf   := l_msg_data;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO concurrent_bulk_process;
      l_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO concurrent_bulk_process;
      l_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO concurrent_bulk_process;
      l_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);

END wms_concurrent_bulk_process;

PROCEDURE split_child_mmtt(p_child_temp_id NUMBER,
                           p_new_child_temp_id  NUMBER,
                           p_split_pri_qty NUMBER,
			   p_split_sec_qty NUMBER) --bug 8197506
IS
 l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  -- starts bug 8197506
 l_api_name CONSTANT VARCHAR2(30)  := 'split_child_mmtt';
BEGIN
    -- 8197506

	  IF l_debug=1 THEN
                mydebug('Input parameters:'                           ||g_newline||
                'p_child_temp_id '||p_child_temp_id       ||g_newline||
                'primary_quantity '||p_split_pri_qty ||g_newline||
                'p_new_child_temp_id'||p_new_child_temp_id ||g_newline||
                'p_split_sec_qty'||p_split_sec_qty ,l_api_name);
           END IF;
   -- 8197506
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
		     , secondary_transaction_quantity    -- BUG 8197506
                     , secondary_uom_code  -- bug 8197506
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
                     , serial_allocated_flag
                     , move_order_header_id
                     , wms_task_status -- Bug# 4185621
                      )
            (SELECT transaction_header_id
                  , p_new_child_temp_id
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
                  , p_split_pri_qty
                  , p_split_pri_qty   -- only the primary UOM is used
		  , p_split_sec_qty   -- BUG 8197506
                  , secondary_uom_code   -- BUG 8197506
                  , item_primary_uom_code -- transaction_uom
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
                  , 'Y' --posting_flag  Bug#4185621: make sure new child mmtt is posting
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
                  , serial_allocated_flag
                  , move_order_line_id
                  , l_g_task_loaded -- Bug# 4185621: loaded status
               FROM mtl_material_transactions_temp
              WHERE transaction_temp_id = p_child_temp_id);

              -- update the old line with remaining qty
                 update mtl_material_transactions_temp
                    set primary_quantity = primary_quantity-p_split_pri_qty, -- UOM
                    secondary_transaction_quantity = decode(secondary_transaction_quantity,NULL,NULL,secondary_transaction_quantity-p_split_sec_qty), --bug 8197506
                    transaction_quantity = transaction_quantity-p_split_pri_qty
                   where transaction_temp_id = p_child_temp_id;



END split_child_mmtt;

PROCEDURE split_child_mtlt(p_child_temp_id NUMBER,
                           p_new_child_temp_id  NUMBER,
                           p_new_serial_temp_id NUMBER,
                           p_split_pri_qty NUMBER,
                           p_child_lot_number VARCHAR2,  --v1 Bug 3902766
			   p_split_sec_qty NUMBER) --bug 8197506
IS
 l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   -- 8197506
 l_api_name CONSTANT VARCHAR2(30)  := 'split_child_mtlt';
BEGIN
-- 8197506
           IF l_debug=1 THEN
                mydebug('MTLT Input parameters:'                           ||g_newline||
                'p_child_temp_id '||p_child_temp_id       ||g_newline||
                'primary_quantity '||p_split_pri_qty ||g_newline||
                'p_new_child_temp_id'||p_new_child_temp_id ||g_newline||
                'p_split_sec_qty'||p_split_sec_qty ,l_api_name);
           END IF;
-- 8197506
-- insert into mtlt and update the qty for old line
    INSERT INTO mtl_transaction_lots_temp
                (
                 transaction_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , request_id
               , program_application_id
               , program_id
               , program_update_date
               , transaction_quantity
               , primary_quantity
	       , secondary_quantity    -- BUG 8197506
               , secondary_unit_of_measure  -- bug 8197506
               , lot_number
               , lot_expiration_date
               , ERROR_CODE
               , serial_transaction_temp_id
               , group_header_id
               , put_away_rule_id
               , pick_rule_id
               , description
               , vendor_id
               , supplier_lot_number
               , territory_code
               , --country_of_origin,
                 origination_date
               , date_code
               , grade_code
               , change_date
               , maturity_date
               , status_id
               , retest_date
               , age
               , item_size
               , color
               , volume
               , volume_uom
               , place_of_origin
               , --kill_date,
                 best_by_date
               , LENGTH
               , length_uom
               , recycled_content
               , thickness
               , thickness_uom
               , width
               , width_uom
               , curl_wrinkle_fold
               , lot_attribute_category
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
               , vendor_name
                )
         (SELECT
                 p_new_child_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , request_id
               , program_application_id
               , program_id
               , program_update_date
               , p_split_pri_qty
               , p_split_pri_qty
	       , p_split_sec_qty  -- BUG 8197506
               , secondary_unit_of_measure  -- BUG 8197506
               , lot_number
               , lot_expiration_date
               , ERROR_CODE
               , p_new_serial_temp_id
               , group_header_id
               , put_away_rule_id
               , pick_rule_id
               , description
               , vendor_id
               , supplier_lot_number
               , territory_code
               , --country_of_origin,
                 origination_date
               , date_code
               , grade_code
               , change_date
               , maturity_date
               , status_id
               , retest_date
               , age
               , item_size
               , color
               , volume
               , volume_uom
               , place_of_origin
               , --kill_date,
                 best_by_date
               , LENGTH
               , length_uom
               , recycled_content
               , thickness
               , thickness_uom
               , width
               , width_uom
               , curl_wrinkle_fold
               , lot_attribute_category
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
               , vendor_name
               FROM mtl_transaction_lots_temp
               WHERE transaction_temp_id = p_child_temp_id
                AND   lot_number = p_child_lot_number); --v1 Bug 3902766

               -- update the old line with remaining qty
        update mtl_transaction_lots_temp
           set primary_quantity = primary_quantity-p_split_pri_qty, -- UOM
	       secondary_quantity = decode(secondary_quantity,NULL,NULL,secondary_quantity-p_split_sec_qty), --bug 8197506
               transaction_quantity = transaction_quantity-p_split_pri_qty -- UOM
                where transaction_temp_id = p_child_temp_id
                and   lot_number = p_child_lot_number;  --v1 Bug 3902766

END split_child_mtlt;

PROCEDURE update_child(p_child_temp_id NUMBER,
                       p_parent_temp_id NUMBER,
                       p_new_txn_hdr_id NUMBER) IS
   l_parent_uom         VARCHAR2(10);
   l_child_uom          VARCHAR2(10);

   l_parent_sub_code    VARCHAR2(30);
   l_parent_loc_id      NUMBER;
   l_lpn_id             NUMBER;
   l_transfer_lpn_id    NUMBER;
   l_api_name VARCHAR2(32):= 'update_child';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
IF l_debug=1 THEN
    mydebug('get parent line info, parent temp id:'||p_parent_temp_id,l_api_name);
END IF;

-- get the information in parent
select transfer_lpn_id,nvl(lpn_id,content_lpn_id),subinventory_code,locator_id, transaction_uom
into l_transfer_lpn_id,l_lpn_id,l_parent_sub_code,l_parent_loc_id,l_parent_uom
from mtl_material_transactions_temp
where transaction_temp_id = p_parent_temp_id;

IF p_child_temp_id is not null THEN
    IF l_debug=1 THEN
        mydebug('update child line '||p_child_temp_id||' with parent info and new header id '||p_new_txn_hdr_id,l_api_name);
    END IF;

 -- update child line with the correct parent info
    UPDATE mtl_material_transactions_temp mmtt
 SET mmtt.transaction_header_id = p_new_txn_hdr_id
        , mmtt.transfer_lpn_id = l_transfer_lpn_id
        , mmtt.lpn_id = l_lpn_id
        , mmtt.parent_line_id = p_parent_temp_id
        , mmtt.subinventory_code = l_parent_sub_code
        , mmtt.locator_id = l_parent_loc_id
        , mmtt.transaction_uom = mmtt.item_primary_uom_code
        , mmtt.transaction_quantity = mmtt.primary_quantity
        , mmtt.last_update_date = SYSDATE
        , mmtt.last_updated_by = FND_GLOBAL.USER_ID
        , mmtt.posting_flag = 'Y' -- Bug# 4185621: make sure child line mmtt is now posting
        , mmtt.wms_task_status = l_g_task_loaded -- Bug# 4185621: make sure child line mmtt task status is loaded
 WHERE mmtt.transaction_temp_id = p_child_temp_id;
ELSE
     -- update all child lines with the correct parent info
    IF l_debug=1 THEN
        mydebug('update all child lines with parent info and new header id '||p_new_txn_hdr_id,l_api_name);
    END IF;
    UPDATE mtl_material_transactions_temp mmtt
     SET mmtt.transaction_header_id = p_new_txn_hdr_id
            , mmtt.transfer_lpn_id = l_transfer_lpn_id
            , mmtt.lpn_id = l_lpn_id
            , mmtt.parent_line_id = p_parent_temp_id
            , mmtt.subinventory_code = l_parent_sub_code
            , mmtt.locator_id = l_parent_loc_id
            , mmtt.transaction_uom = mmtt.item_primary_uom_code
               , mmtt.transaction_quantity = mmtt.primary_quantity
            , mmtt.last_update_date = SYSDATE
            , mmtt.last_updated_by = FND_GLOBAL.USER_ID
            , mmtt.posting_flag = 'Y' -- Bug# 4185621: make sure child line mmtt is now posting
            , mmtt.wms_task_status = l_g_task_loaded -- Bug# 4185621: make sure child line mmtt task status is loaded
 WHERE mmtt.transaction_temp_id <> p_parent_temp_id
   and mmtt.parent_line_id = p_parent_temp_id;
END IF;

END update_child;

PROCEDURE create_sub_transfer(p_from_temp_id NUMBER,
                              p_pri_qty NUMBER,
                              p_txn_qty NUMBER,
                              p_lot_controlled VARCHAR2
                              ) IS
l_mmtt_rec mtl_material_transactions_temp%ROWTYPE;
l_mtlt_rec mtl_transaction_lots_temp%ROWTYPE;
l_new_temp_id NUMBER;
l_api_name VARCHAR2(30) := 'create_sub_transfer';
 l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

CURSOR over_picked_lots(p_temp_id NUMBER) IS
    select sum(transaction_quantity) transaction_quantity,
           sum(primary_quantity) primary_quantity, lot_number
    from mtl_allocations_gtmp
    where transaction_temp_id = p_temp_id
    group by lot_number;

BEGIN
    -- need to copy the child line since the child line contains the neccessary info
    -- which the sub transfer needs
    select *
    into l_mmtt_rec
    from mtl_material_transactions_temp
    where transaction_temp_id <> p_from_temp_id
      and parent_line_id = p_from_temp_id
      and rownum <2;

    IF l_debug=1 THEN
        mydebug('BULK_PICK:create_sub_transfer:get the rec for the child:'||l_mmtt_rec.transaction_temp_id,
            l_api_name);
    END IF;

    select mtl_material_transactions_s.NEXTVAL
    into l_new_temp_id
    from dual;

    l_mmtt_rec.primary_quantity := p_pri_qty;
    l_mmtt_rec.transaction_quantity := p_txn_qty;
    l_mmtt_rec.transaction_temp_id := l_new_temp_id;
    l_mmtt_rec.move_order_line_id := null;
    l_mmtt_rec.operation_plan_id := null;
    l_mmtt_rec.standard_operation_id := null;
    l_mmtt_rec.cartonization_id := null;
    l_mmtt_rec.trx_source_line_id := null;
    l_mmtt_rec.transaction_source_id := null;
    l_mmtt_rec.demand_source_line := null;
    l_mmtt_rec.pick_rule_id := null;
    l_mmtt_rec.reservation_id := null;
    l_mmtt_rec.wms_task_type := null;
    l_mmtt_rec.wms_task_status := l_g_task_loaded; -- Bug 4185621: new child mmtt line for overpicked quantity should have status loaded as well
    l_mmtt_rec.transfer_subinventory := null;
    l_mmtt_rec.transfer_to_location := null;

    l_mmtt_rec.posting_flag := 'Y';   -- will be shown in the qty tree
    l_mmtt_rec.transaction_source_type_id := 13;
    l_mmtt_rec.transaction_action_id := 2;
    l_mmtt_rec.transaction_type_id := 2;  -- inventory sub transfer
    -- the sub transfer transaction will have the same parent_line_id as the
    -- child line so that it can be used in unload



    wms_task_dispatch_engine.insert_mmtt(l_mmtt_rec);

    -- create lot record
    IF (p_lot_controlled = 'Y') THEN   -- lot controlled
        FOR lot_line in over_picked_lots(p_from_temp_id) LOOP
            select *
     into l_mtlt_rec
     from mtl_transaction_lots_temp
            where transaction_temp_id = p_from_temp_id
              and lot_number = lot_line.lot_number;

            l_mtlt_rec.transaction_temp_id := l_new_temp_id;
            l_mtlt_rec.primary_quantity := lot_line.primary_quantity;
            l_mtlt_rec.transaction_quantity := lot_line.primary_quantity; -- UOM will be using the primary uom

            l_mtlt_rec.serial_transaction_temp_id := null;   -- serial numbers never be allocated, so we can't create
                                                             -- serial records for the sub transfer

            -- insert lot rec
            inv_rcv_common_apis.insert_mtlt(l_mtlt_rec);

        END LOOP; -- end loop through each lot
   END IF; -- end lot process

END create_sub_transfer;
/*
-- This procedure will be used for distributing the quantity
-- picked (in one or more parent MMTT lines) to the original
-- child MMTT lines (again one or more)
*/


PROCEDURE bulk_pick(p_temp_id            IN NUMBER,
                   p_txn_hdr_id         IN NUMBER,
                   p_org_id             IN NUMBER,
                   p_multiple_pick      IN VARCHAR2, -- to indicate if this is multiple pick or not
                   p_exception          IN VARCHAR2, -- to indicate if this is over picking or short pick
                   p_lot_controlled     IN VARCHAR2,
                   p_user_id            IN NUMBER,
                   p_employee_id        IN NUMBER,
                   p_reason_id          IN NUMBER,
                   x_new_txn_hdr_id     OUT NOCOPY NUMBER,
                   x_return_status      OUT NOCOPY VARCHAR2,
                   x_msg_count          OUT NOCOPY NUMBER,
                   x_msg_data           OUT NOCOPY VARCHAR2)
IS


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
	     , mmtt.secondary_transaction_quantity   --bug 8197506
          FROM mtl_material_transactions_temp mmtt
         WHERE mmtt.transaction_header_id = p_txn_hdr_id
           AND mmtt.organization_id = p_org_id
           AND mmtt.transaction_quantity > 0
           AND mmtt.parent_line_id = mmtt.transaction_temp_id  -- make sure it is only parent lines
      ORDER BY mmtt.transaction_quantity DESC;

     CURSOR c_parent_mmtt_shortpick IS
      SELECT   mmtt.transaction_temp_id
             , mmtt.inventory_item_id
             , mmtt.subinventory_code
             , mmtt.locator_id
             , NVL(mmtt.content_lpn_id, mmtt.lpn_id)
             , mmtt.transfer_lpn_id
             , mmtt.transaction_uom
             , mmtt.transaction_quantity
             , mmtt.primary_quantity
	     , mmtt.secondary_transaction_quantity   --bug 8197506
          FROM mtl_material_transactions_temp mmtt
         WHERE mmtt.transaction_header_id = p_txn_hdr_id
           AND mmtt.organization_id = p_org_id
           AND mmtt.transaction_quantity > 0
           AND mmtt.parent_line_id <> p_temp_id
           AND mmtt.parent_line_id = mmtt.transaction_temp_id  -- make sure it is only parent lines
      ORDER BY mmtt.transaction_quantity DESC;




      CURSOR c_parent_mmtt_lines_for_lots IS
             SELECT   mmtt.transaction_temp_id
                      , mmtt.transfer_lpn_id
                      , mtlt.lot_number
                      , mtlt.transaction_quantity lot_trx_qty
                      , mtlt.primary_quantity   lot_primary_qty
		      , mtlt.secondary_quantity  lot_sec_qty --bug 8197506
             FROM mtl_material_transactions_temp mmtt,mtl_transaction_lots_temp mtlt
             WHERE mmtt.transaction_header_id = p_txn_hdr_id
               AND mmtt.organization_id = p_org_id
               AND mmtt.transaction_quantity > 0
               AND mmtt.parent_line_id = mmtt.transaction_temp_id
               AND mtlt.transaction_temp_id = mmtt.transaction_temp_id
             ORDER BY mmtt.transaction_quantity DESC;

      CURSOR c_parent_mmtt_shorpick_lots IS
             SELECT   mmtt.transaction_temp_id
                      , mmtt.transfer_lpn_id
                      , mtlt.lot_number
                      , mtlt.transaction_quantity lot_trx_qty
                      , mtlt.primary_quantity   lot_primary_qty
		      , mtlt.secondary_quantity lot_sec_qty --bug 8197506
             FROM mtl_material_transactions_temp mmtt,mtl_transaction_lots_temp mtlt
             WHERE mmtt.transaction_header_id = p_txn_hdr_id
               AND mmtt.organization_id = p_org_id
               AND mmtt.transaction_quantity > 0
               AND mmtt.parent_line_id <> p_temp_id
               AND mmtt.parent_line_id = mmtt.transaction_temp_id
               AND mtlt.transaction_temp_id = mmtt.transaction_temp_id
             ORDER BY mmtt.transaction_quantity DESC;


    CURSOR c_child_mmtt_lines IS
      SELECT   mmtt.transaction_temp_id
             , mmtt.transaction_uom
             , mmtt.transaction_quantity
             , mmtt.primary_quantity
	     , mmtt.secondary_transaction_quantity --bug 8197506
          FROM mtl_material_transactions_temp mmtt
         WHERE mmtt.parent_line_id = p_temp_id
           AND mmtt.parent_line_id <> mmtt.transaction_temp_id -- exclude the parent line
           AND mmtt.organization_id = p_org_id
      ORDER BY mmtt.transaction_quantity DESC;

   CURSOR c_child_mmtt_lines_so IS
      SELECT   mmtt.transaction_temp_id
             , mmtt.transaction_uom
             , mmtt.transaction_quantity
             , mmtt.primary_quantity
	     , mmtt.secondary_transaction_quantity  --bug 8197506
          FROM mtl_material_transactions_temp mmtt,mtl_txn_request_lines mol,
               wsh_delivery_details wdd,wsh_delivery_assignments_v wda
         WHERE mmtt.parent_line_id = p_temp_id
           AND mmtt.parent_line_id <> mmtt.transaction_temp_id -- exclude the parent line
           AND mmtt.organization_id = p_org_id
           AND mol.line_id = mmtt.move_order_line_id
           AND mol.line_id = wdd.move_order_line_id
	   AND wdd.released_status = 'S'  --Bug#6848907
           AND wda.delivery_detail_id = wdd.delivery_detail_id
      ORDER BY nvl(wda.delivery_id,mol.carton_grouping_id), mmtt.transaction_quantity DESC;

    CURSOR c_child_mmtt_lines_short IS
          SELECT   mmtt.transaction_temp_id
                 , mmtt.transaction_uom
                 , mmtt.transaction_quantity
                 , mmtt.primary_quantity
		 , mmtt.secondary_transaction_quantity  --bug 8197506
              FROM mtl_material_transactions_temp mmtt,mtl_txn_request_lines mol,
                   wsh_delivery_details wdd,wsh_delivery_assignments_v wda,
                   oe_order_lines_all ol,mtl_txn_request_headers moh
             WHERE mmtt.parent_line_id = p_temp_id
               AND mmtt.parent_line_id <> mmtt.transaction_temp_id -- exclude the parent line
               AND mmtt.organization_id = p_org_id
               AND mol.line_id = mmtt.move_order_line_id
               AND mol.line_id = wdd.move_order_line_id
               AND wdd.released_status = 'S'  --Bug#6848907
               AND wda.delivery_detail_id = wdd.delivery_detail_id
               AND ol.line_id = wdd.source_line_id
               AND mol.header_id = moh.header_id
      ORDER BY ol. SCHEDULE_SHIP_DATE,
               nvl(wda.delivery_id,mol.carton_grouping_id),
               moh.creation_date,   -- mmtt creation date is changed for splitting, so moh date will be better
               mmtt.transaction_quantity DESC;

    c_mmtt_line c_child_mmtt_lines%ROWTYPE;

    CURSOR c_child_lots(p_child_transaction_temp_id NUMBER) IS
      SELECT
               mtlt.lot_number
             , mtlt.transaction_quantity
             , mtlt.primary_quantity
	     , mtlt.secondary_quantity  -- bug 8197506
        FROM mtl_transaction_lots_temp mtlt
       WHERE
            mtlt.transaction_temp_id = p_child_transaction_temp_id;


    CURSOR c_lot_parents(p_lot_number VARCHAR2) IS
       SELECT mag.transaction_temp_id,
              mag.primary_quantity,
              mag.transaction_quantity,
	      mag.secondary_quantity --bug 8197506
        FROM mtl_allocations_gtmp mag
        WHERE lot_number = p_lot_number
         ORDER BY search_sequence;



    CURSOR over_picked_lines IS
    SELECT sum(transaction_quantity) transaction_quantity,
           sum(primary_quantity) primary_quantity, transaction_temp_id
    from mtl_allocations_gtmp
    group by transaction_temp_id;


    l_parent_txn_qty     NUMBER;
    l_child_txn_qty      NUMBER:= 0;
    l_parent_pri_qty     NUMBER;
    l_child_pri_qty      NUMBER;
    l_parent_uom         VARCHAR2(10);
    l_child_uom          VARCHAR2(10);
    l_primary_uom        VARCHAR2(10);
    l_parent_txn_temp_id NUMBER;
    l_child_txn_temp_id  NUMBER;
    l_item_id            NUMBER;
    l_parent_sub_code    VARCHAR2(30);
    l_parent_loc_id      NUMBER;
    l_lpn_id             NUMBER;
    l_transfer_lpn_id    NUMBER;
    l_debug              NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_new_temp_id        NUMBER;
    l_serial_temp_id    NUMBER;
    l_api_name VARCHAR2(30) := 'bulk_pick';
    l_mmtt_qty           NUMBER;
    l_new_serial_temp_id NUMBER;
    L_CHILD_LOT_TXN_QTY  NUMBER;
    l_link_mtlt_needed       VARCHAR2(1) := 'N';
    l_process_qty        NUMBER;
    l_move_order_type    NUMBER;
    g_not_lot_controlled     constant NUMBER := 1;
    g_lot_controlled         constant NUMBER := 2;
    l_unpicked_serial_rec_exists VARCHAR2(1);
    l_transaction_action_id NUMBER;
    l_search_sequence NUMBER;
    l_temp_id  NUMBER;
    --BUG 8197506
    l_parent_sec_qty     NUMBER;
    l_child_sec_qty     NUMBER;
    l_child_lot_sec_txn_qty  NUMBER;
    l_process_sec_qty   NUMBER;

BEGIN
x_return_status  := fnd_api.g_ret_sts_success;

IF l_debug = 1 THEN
mydebug('Dispatching Bulk Pick Tasks for TxnHdrID = ' || p_txn_hdr_id || ' : TxnTempID = ' || p_temp_id,l_api_name);
mydebug('p_multiple_pick:'||p_multiple_pick,l_api_name);
mydebug('p_exception:'||p_exception,l_api_name);
mydebug('Lot control code    : '|| p_lot_controlled, l_api_name);
END IF;

-- processed child lines will get a new header id

SELECT mtl_material_transactions_s.NEXTVAL
INTO x_new_txn_hdr_id
FROM DUAL;

IF (l_debug = 1) THEN
    mydebug('New header id the child lines will have :'||x_new_txn_hdr_id,l_api_name);
END IF;

l_temp_id := p_temp_id;
-- get the transaction action to be used later on
BEGIN
SELECT transaction_action_id
  INTO l_transaction_action_id
  FROM mtl_material_transactions_temp mmtt
     WHERE
        mmtt.transaction_temp_id  = p_temp_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN  -- when the line merged from APL and old temp id is not there any more
        SELECT transaction_action_id,transaction_temp_id
        INTO l_transaction_action_id,l_temp_id
        FROM mtl_material_transactions_temp mmtt
        WHERE transaction_header_id = p_txn_hdr_id
          and rownum<2;
END;

IF (l_debug = 1) THEN
    mydebug('transaction action id :'||l_transaction_action_id,l_api_name);
END IF;



-- if it is complete single pick, nothing need to be done except to update the child line with
-- the parent line info
IF (p_exception is null  and p_multiple_pick='N' ) THEN

    IF (l_debug = 1) THEN mydebug('This is a complete single pick!',l_api_name);
    END IF;
    -- update all child line with the correct parent info
    update_child(null,l_temp_id,x_new_txn_hdr_id);

    --Bug# 4185621: update parent line posting flag back to 'N'
    UPDATE mtl_material_transactions_temp
       SET posting_flag = 'N'
     WHERE transaction_temp_id = l_temp_id
       AND parent_line_id = transaction_temp_id;
   -- Bug# 4185621: end change

    return;
END IF;

-- make sure the global temp table is emplty
IF (l_debug = 1) THEN mydebug('deleting the global temp table ',l_api_name); END IF;
delete mtl_allocations_gtmp;

-- populate the temp table mtl_allocations_gtmp
if (p_lot_controlled = 'Y' ) THEN  -- lot controlled
   IF (l_debug = 1) THEN
           mydebug('inserting the records to the tmp table',l_api_name);
   END IF;
   l_search_sequence  := 0;
   IF (p_exception     = 'SHORT') THEN
           IF (l_debug = 1) THEN
                   mydebug('Inserting from c_parent_mmtt_shorpick_lots v1',l_api_name);
           END IF;
           FOR c_parent_lines_rec IN c_parent_mmtt_shorpick_lots
           LOOP
                   l_search_sequence := l_search_sequence +1;
                   INSERT
                   INTO   mtl_allocations_gtmp
                          (
                                 TRANSACTION_TEMP_ID  ,
                                 TRANSFER_LPN_ID      ,
                                 LOT_NUMBER           ,
                                 TRANSACTION_QUANTITY ,
                                 PRIMARY_QUANTITY     ,
                                 SEARCH_SEQUENCE      ,
                                 SECONDARY_QUANTITY --bug 8197506
                          )
                          VALUES
                          (
                                 c_parent_lines_rec.transaction_temp_id ,
                                 c_parent_lines_rec.transfer_lpn_id     ,
                                 c_parent_lines_rec.lot_number          ,
                                 c_parent_lines_rec.lot_trx_qty         ,
                                 c_parent_lines_rec.lot_primary_qty     ,
                                 l_search_sequence                      ,
                                 c_parent_lines_rec.lot_sec_qty
                          ); --bug 8197506
                   --Bug# 4185621: update parent line posting flag back to 'N'
                   UPDATE mtl_material_transactions_temp
                   SET    posting_flag        = 'N'
                   WHERE  transaction_temp_id = c_parent_lines_rec.transaction_temp_id
                      AND parent_line_id      = transaction_temp_id;

                   -- Bug# 4185621: end change
           END LOOP;
   ELSE
           FOR c_parent_lines_rec IN c_parent_mmtt_lines_for_lots
           LOOP
                   l_search_sequence := l_search_sequence +1;
                   INSERT
                   INTO   mtl_allocations_gtmp
                          (
                                 TRANSACTION_TEMP_ID  ,
                                 TRANSFER_LPN_ID      ,
                                 LOT_NUMBER           ,
                                 TRANSACTION_QUANTITY ,
                                 PRIMARY_QUANTITY     ,
                                 SEARCH_SEQUENCE      ,
                                 SECONDARY_QUANTITY --bug 8197506
                          )
                          VALUES
                          (
                                 c_parent_lines_rec.transaction_temp_id ,
                                 c_parent_lines_rec.transfer_lpn_id     ,
                                 c_parent_lines_rec.lot_number          ,
                                 c_parent_lines_rec.lot_trx_qty         ,
                                 c_parent_lines_rec.lot_primary_qty     ,
                                 l_search_sequence                      ,
                                 c_parent_lines_rec.lot_sec_qty --bug 8197506
                          );

                   --Bug# 4185621: update parent line posting flag back to 'N'
                   UPDATE mtl_material_transactions_temp
                   SET    posting_flag        = 'N'
                   WHERE  transaction_temp_id = c_parent_lines_rec.transaction_temp_id
                      AND parent_line_id      = transaction_temp_id;

                   -- Bug# 4185621: end change
           END LOOP;
   END IF;
   IF (l_debug = 1) THEN
           mydebug( l_search_sequence
           ||' parent lines are inserted',l_api_name);
   END IF;
   IF (l_transaction_action_id = 28 AND p_exception= 'SHORT') THEN
           IF (l_debug         = 1) THEN
                   mydebug('opening  c_child_mmtt_lines_short...',l_api_name);
           END IF;
           OPEN c_child_mmtt_lines_short;
   ELSIF l_transaction_action_id = 28 THEN
           IF (l_debug           = 1) THEN
                   mydebug('opening c_child_mmtt_lines_so ...',l_api_name);
           END IF;
           OPEN c_child_mmtt_lines_so;
   ELSE
           OPEN c_child_mmtt_lines;
   END IF;
   LOOP -- loop through each child mmtt line
           IF c_child_mmtt_lines%ISOPEN THEN
                   FETCH c_child_mmtt_lines
                   INTO  c_mmtt_line;

                   EXIT
           WHEN c_child_mmtt_lines%NOTFOUND;
           ELSIF c_child_mmtt_lines_so%ISOPEN THEN
                   FETCH c_child_mmtt_lines_so
                   INTO  c_mmtt_line;

                   EXIT
           WHEN c_child_mmtt_lines_so%NOTFOUND;
           ELSE
                   FETCH c_child_mmtt_lines_short
                   INTO  c_mmtt_line;

                   EXIT
           WHEN c_child_mmtt_lines_short%NOTFOUND;
           END IF;
           IF (l_debug = 1) THEN
                   mydebug('child transaction temp id'
                   ||c_mmtt_line.transaction_temp_id,l_api_name);
           END IF;
           l_child_txn_temp_id := c_mmtt_line.transaction_temp_id;
           FOR c_child_lots_rec IN c_child_lots(c_mmtt_line.transaction_temp_id)
           LOOP                                                                    -- loop through each child mtlt line
                   l_child_lot_txn_qty     := c_child_lots_rec.primary_quantity;   -- get the lot qty
                   l_child_lot_sec_txn_qty := c_child_lots_rec.secondary_quantity; --bug 8197506
                   IF (l_debug              = 1) THEN
                           mydebug('lot number '
                           ||c_child_lots_rec.lot_number
                           ||' lot qty:'
                           || c_child_lots_rec.primary_quantity
                           ||'sec lot qty:'
                           || c_child_lots_rec.secondary_quantity,l_api_name); --bug 8197506
                   END IF;
                   FOR c_lot_parents_rec IN c_lot_parents(c_child_lots_rec.lot_number)
                   LOOP -- loop though parent lines to find the
                           -- the proper parent lines for the lot
                           IF (l_debug = 1) THEN
                                   mydebug('parent transaction temp id:'
                                   ||c_lot_parents_rec.transaction_temp_id
                                   ||' parent lot qty:'
                                   || c_lot_parents_rec.primary_quantity
                                   ||' parent sec lot qty:'
                                   || c_lot_parents_rec.secondary_quantity,l_api_name);--bug 8197506
                           END IF;
                           -- find what's the lot qty can be processed
                           IF c_lot_parents_rec.primary_quantity >= l_child_lot_txn_qty THEN
                                   l_process_qty                 := l_child_lot_txn_qty;
                                   l_process_sec_qty             :=l_child_lot_sec_txn_qty; --bug 8197506
                           ELSE
                                   l_process_qty     := c_lot_parents_rec.primary_quantity;
                                   l_process_sec_qty := c_lot_parents_rec.secondary_quantity; --bug 8197506
                           END IF;
                           IF (l_debug = 1) THEN
                                   mydebug('processed lot qty :'
                                   ||l_process_qty,l_api_name);
                                   mydebug('processed sec lot qty :'
                                   ||l_process_sec_qty,l_api_name);--bug 8197506
                           END IF;
                           -- initialize the local variable
                           l_link_mtlt_needed := 'N';
                           -- first find out if the mmtt line for this parent line has been created or not, for multiple lots
                           BEGIN
                                   SELECT child_transaction_temp_id
                                   INTO   l_child_txn_temp_id
                                   FROM   mtl_allocations_gtmp
                                   WHERE  transaction_temp_id = c_lot_parents_rec.transaction_temp_id
                                      AND child_transaction_temp_id IS NOT NULL
                                      AND rownum = 1;

                                   l_link_mtlt_needed := 'Y'; -- remember it since the mtlt may be needed splitting
                                   IF (l_debug         = 1) THEN
                                           mydebug(' child line created before id:'
                                           || l_child_txn_temp_id,l_api_name);
                                   END IF;
                                   -- update the qty with the new process qty
                                   UPDATE mtl_material_transactions_temp
                                   SET    primary_quantity               = primary_quantity +l_process_qty ,
                                          secondary_transaction_quantity = DECODE(secondary_transaction_quantity,NULL,NULL,secondary_transaction_quantity + l_process_sec_qty), --bug 8197506
                                          transaction_quantity           = transaction_quantity+l_process_qty ,
                                          posting_flag                   = 'Y' , -- Bug# 4185621: change child line posting flag back to 'Y'
                                          wms_task_status                = l_g_task_loaded  -- Bug# 4185621: make sure child line task status is loaded
                                   WHERE  transaction_temp_id = l_child_txn_temp_id;

				  /*Bug8460179-We need to deduct the qty form original child MMTTs*/
                                  UPDATE mtl_material_transactions_temp
                                   SET    primary_quantity               = primary_quantity  - l_process_qty ,
                                          secondary_transaction_quantity = DECODE(secondary_transaction_quantity,NULL,NULL,secondary_transaction_quantity - l_process_sec_qty),
                                          transaction_quantity           = transaction_quantity - l_process_qty
                                   WHERE  transaction_temp_id            = c_mmtt_line.transaction_temp_id;

                                   IF (l_debug = 1) THEN
                                           mydebug('updated the chld line with the new processed qty',l_api_name);
                                   END IF;
                           EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                                   IF (l_debug = 1) THEN
                                           mydebug('child line was not created',l_api_name);
                                   END IF;
                                   -- child line is not created,split the mmtt line if needed
                                   IF c_mmtt_line.primary_quantity = l_process_qty THEN -- no need to split
                                           IF (l_debug             = 1) THEN
                                                   mydebug('no need to split....',l_api_name);
                                           END IF;
                                           l_child_txn_temp_id := c_mmtt_line.transaction_temp_id;
                                           l_link_mtlt_needed  := 'N';
                                   ELSE -- qty in mmtt > qty processed ,split anyway, will be cleaned up later on
                                           SELECT mtl_material_transactions_s.NEXTVAL
                                           INTO   l_new_temp_id
                                           FROM   dual;

                                           IF (l_debug = 1) THEN
                                                   mydebug('split the child line with the new temp id '
                                                   ||l_new_temp_id,l_api_name);
                                           END IF;
                                           split_child_mmtt(c_mmtt_line.transaction_temp_id, l_new_temp_id, l_process_qty, l_process_sec_qty --bug 8197506
                                           );
                                           l_child_txn_temp_id := l_new_temp_id;
                                           IF (l_debug          = 1) THEN
                                                   mydebug('update the processed qty for the new child line',l_api_name);
                                           END IF;
                                           UPDATE mtl_allocations_gtmp
                                           SET    child_transaction_temp_id = l_new_temp_id
                                           WHERE  transaction_temp_id       = c_lot_parents_rec.transaction_temp_id;

                                           l_link_mtlt_needed := 'Y';
                                   END IF;
                           END;
                           -- split the lot line if needed
                           IF (l_process_qty   = c_child_lots_rec.primary_quantity ) THEN -- no need to split
                                   IF (l_debug = 1) THEN
                                           mydebug('No need to split the mtlt....',l_api_name);
                                   END IF;
                                   IF l_link_mtlt_needed = 'Y' THEN
                                           IF (l_debug   = 1) THEN
                                                   mydebug('update the lot qty for temp id:'
                                                   ||c_mmtt_line.transaction_temp_id, l_api_name);
                                           END IF;
                                           UPDATE mtl_transaction_lots_temp
                                           SET    transaction_Temp_id = l_child_txn_temp_id
                                           WHERE  transaction_temp_id = c_mmtt_line.transaction_temp_id
                                              AND lot_number          = c_child_lots_rec.lot_number;

                                   END IF;
                           ELSE
                                   -- split lot is needed, l_process_qty <the lot qty
                                   IF (l_debug = 1) THEN
                                           mydebug('splitting the mtlt line with new temp id '
                                           || l_child_txn_temp_id,l_api_name);
                                   END IF;
                                   split_child_mtlt(c_mmtt_line.transaction_temp_id, l_child_txn_temp_id, -- new temp id
                                   NULL,                                                                  -- new serial temp id
                                   l_process_qty, c_child_lots_rec.lot_number,                            --v1
                                   l_process_sec_qty                                                      --bug 8197506
                                   );
                           END IF;
                           -- update child line with the correct parent info
                           IF (l_debug = 1) THEN
                                   mydebug('updating the child line with the correct parent....',l_api_name);
                           END IF;
                           update_child(l_child_txn_temp_id,c_lot_parents_rec.transaction_temp_id, x_new_txn_hdr_id);
                           -- update the processed lot quantity
                           l_child_lot_txn_qty     := l_child_lot_txn_qty     -l_process_qty;
                           l_child_lot_sec_txn_qty := l_child_lot_sec_txn_qty - l_process_sec_qty; --bug 8197506
                           IF (l_debug              = 1) THEN
                                   mydebug('left lot qty to be processed '
                                   ||l_child_lot_txn_qty,l_api_name);
                           END IF;
                           mydebug('left sec lot qty to be processed '
                           ||l_child_lot_sec_txn_qty,l_api_name); --bug 8197506
                           -- update the quantity for the parent line in the gtmp
                           UPDATE mtl_allocations_gtmp
                           SET    primary_quantity    = primary_quantity                                      -l_process_qty,     -- only primary UOM will be used
                                  secondary_quantity  = DECODE(secondary_quantity,NULL,NULL,secondary_quantity-l_process_sec_qty) --bug 8197506
                           WHERE  transaction_temp_id = c_lot_parents_rec.transaction_temp_id
                              AND lot_number          = c_child_lots_rec.lot_number;

                           IF (l_debug = 1) THEN
                                   mydebug('after updating the parent qty in the temp table.',l_api_name);
                           END IF;
                           -- delete the record if the qty has became 0
                           DELETE mtl_allocations_gtmp
                           WHERE  transaction_temp_id = c_lot_parents_rec.transaction_temp_id
                              AND primary_quantity    = 0;

                           IF (l_debug = 1 AND SQL%ROWCOUNT>0) THEN
                                   mydebug('records deteted for qty 0 in the temp table '
                                   ||SQL%ROWCOUNT,l_api_name);
                                   mydebug('child lot txn qty to be processed :'
                                   ||l_child_lot_txn_qty,l_api_name);
                           END IF;
                           EXIT
                   WHEN l_child_lot_txn_qty = 0;
                   END LOOP; -- for parent lines, c_lot_parents_rec
           END LOOP;         -- for mtlt,c_child_lots_rec
           -- delete the qty 0 mmtt due to the split
           DELETE
           FROM   mtl_material_transactions_temp mmtt
           WHERE  transaction_temp_id = c_mmtt_line.transaction_temp_id
              AND primary_quantity    = 0;

           -- before process another mmtt line, the child transaction temp id should be nullified
           UPDATE mtl_allocations_gtmp
           SET    child_transaction_temp_id = NULL;

   END LOOP; -- for mmtt
   IF c_child_mmtt_lines%ISOPEN THEN
           CLOSE c_child_mmtt_lines;
   ELSIF c_child_mmtt_lines_so%ISOPEN THEN
           CLOSE c_child_mmtt_lines_so ;
   ELSE
           CLOSE c_child_mmtt_lines_short;
   END IF;
   -- create sub transfer for over picked qty, they should be in the gtmp table
   IF (p_exception='OVER') THEN
           FOR over_qty_line IN over_picked_lines
           LOOP
                   create_sub_transfer(over_qty_line.transaction_temp_id, over_qty_line.primary_quantity, over_qty_line.primary_quantity, p_lot_controlled);
           END LOOP;
   END IF;

ELSE  -- plain item


   IF ( p_exception = 'SHORT') THEN
    IF (l_debug = 1) THEN  mydebug('Opening c_parent_mmtt_shortpick v1 ',p_exception); END IF;
    OPEN c_parent_mmtt_shortpick;
   ELSE
    OPEN c_parent_mmtt_lines;
   END IF;

    IF (l_transaction_action_id = 28 and p_exception = 'SHORT')THEN
 OPEN c_child_mmtt_lines_short;
    ELSIF l_transaction_action_id = 28 THEN
 OPEN c_child_mmtt_lines_so;
    ELSE OPEN c_child_mmtt_lines;
    END IF;


    LOOP


   IF c_parent_mmtt_shortpick%ISOPEN THEN
     IF (l_debug = 1) THEN mydebug('Fetching from c_parent_mmtt_shortpick v1',p_exception); END IF;
      FETCH c_parent_mmtt_shortpick INTO l_parent_txn_temp_id
     , l_item_id
     , l_parent_sub_code
     , l_parent_loc_id
     , l_lpn_id
     , l_transfer_lpn_id
     , l_parent_uom
     , l_parent_txn_qty
     , l_parent_pri_qty
     , l_parent_sec_qty;  --bug 8197506
      EXIT WHEN c_parent_mmtt_shortpick%NOTFOUND;
   ELSE
      FETCH c_parent_mmtt_lines INTO l_parent_txn_temp_id
     , l_item_id
     , l_parent_sub_code
     , l_parent_loc_id
     , l_lpn_id
     , l_transfer_lpn_id
     , l_parent_uom
     , l_parent_txn_qty
     , l_parent_pri_qty
     , l_parent_sec_qty;  --bug 8197506
      EXIT WHEN c_parent_mmtt_lines%NOTFOUND;
   END IF;

      --Bug# 4185621: update parent line posting flag back to 'N'
      UPDATE mtl_material_transactions_temp
         SET posting_flag = 'N'
       WHERE transaction_temp_id = l_parent_txn_temp_id
         AND parent_line_id = transaction_temp_id;
     -- Bug# 4185621: end change

      LOOP
        IF l_child_txn_qty = 0 THEN
            mydebug('BULK_PICK:fetching a new child record.',l_api_name);

     IF c_child_mmtt_lines%ISOPEN THEN
   fetch c_child_mmtt_lines into l_child_txn_temp_id, l_child_uom, l_child_txn_qty, l_child_pri_qty, l_child_sec_qty; --bug 8197506
   EXIT WHEN c_child_mmtt_lines%NOTFOUND;
     ELSIF c_child_mmtt_lines_so%ISOPEN THEN
   fetch c_child_mmtt_lines_so into l_child_txn_temp_id, l_child_uom, l_child_txn_qty, l_child_pri_qty,l_child_sec_qty; --bug 8197506
   EXIT WHEN c_child_mmtt_lines_so%NOTFOUND;
     ELSE fetch c_child_mmtt_lines_short into l_child_txn_temp_id, l_child_uom, l_child_txn_qty, l_child_pri_qty,l_child_sec_qty; --bug 8197506
   EXIT WHEN c_child_mmtt_lines_short%NOTFOUND;
     END IF;

        END IF;

        IF l_debug = 1 THEN
          mydebug('Child Temp ID = ' || l_child_txn_temp_id,l_api_name);
          mydebug('Parent Temp ID = ' || l_parent_txn_temp_id,l_api_name);
          mydebug('parent transfer_lpn_id = '|| l_transfer_lpn_id,l_api_name);
          mydebug('Current Parent Qty = ' || l_parent_txn_qty || ' : Child Qty = ' || l_child_txn_qty,l_api_name);
	   mydebug('Current Pri Parent Qty = ' || l_parent_pri_qty || ' : Child Pri Qty = ' || l_child_pri_qty,l_api_name); --bug 8197506
          mydebug('Current Sec Parent Qty = ' || l_parent_sec_qty || ' : Child SEc Qty = ' || l_child_sec_qty,l_api_name);  --bug 8197506
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

         l_child_uom := l_parent_uom ; --bug#6848907.child qty is in parent uom now
        END IF;

        IF l_parent_txn_qty >= l_child_txn_qty THEN
          UPDATE mtl_material_transactions_temp mmtt
             SET mmtt.transaction_header_id = x_new_txn_hdr_id
               , mmtt.transfer_lpn_id = l_transfer_lpn_id
               , mmtt.lpn_id = l_lpn_id
               , mmtt.parent_line_id = l_parent_txn_temp_id
               , mmtt.subinventory_code = l_parent_sub_code
               , mmtt.locator_id = l_parent_loc_id
               , mmtt.transaction_uom = mmtt.item_primary_uom_code
               , mmtt.transaction_quantity = mmtt.primary_quantity
               , mmtt.last_update_date = SYSDATE
               , mmtt.last_updated_by = p_user_id
               , mmtt.posting_flag = 'Y'  -- Bug# 4185621: change child line posting flag back to 'Y'
               , mmtt.wms_task_status = l_g_task_loaded -- Bug# 4185621: make sure child line task status is loaded
           WHERE mmtt.transaction_temp_id = l_child_txn_temp_id;

          l_parent_txn_qty  := l_parent_txn_qty - l_child_txn_qty;
          l_parent_pri_qty  := l_parent_pri_qty - l_child_pri_qty;
	  l_parent_sec_qty  := l_parent_sec_qty - l_child_sec_qty; --bug 8197506
          l_child_txn_qty   := 0;
          l_child_pri_qty   := 0;

          EXIT WHEN l_parent_txn_qty = 0;
        ELSE -- Current Child Qty is greater than Parent Picked Qty
          select mtl_material_transactions_s.NEXTVAL
          into l_new_temp_id
          from dual;

          split_child_mmtt(l_child_txn_temp_id,
                    l_new_temp_id,
                    l_child_pri_qty - l_parent_pri_qty,
                    l_child_sec_qty - l_parent_sec_qty );  --bug 8197506


          UPDATE mtl_material_transactions_temp mmtt
             SET mmtt.transaction_header_id = x_new_txn_hdr_id
               , mmtt.primary_quantity = l_parent_pri_qty
	       , mmtt.secondary_transaction_quantity = l_parent_sec_qty --bug 8197506
               , mmtt.parent_line_id = l_parent_txn_temp_id
               , mmtt.transfer_lpn_id = l_transfer_lpn_id
               , mmtt.lpn_id = l_lpn_id
               , mmtt.subinventory_code = l_parent_sub_code
               , mmtt.locator_id = l_parent_loc_id
               , mmtt.transaction_uom = mmtt.item_primary_uom_code
              , mmtt.transaction_quantity = mmtt.primary_quantity
               , mmtt.last_update_date = SYSDATE
               , mmtt.last_updated_by = p_user_id
               , mmtt.posting_flag = 'Y'  -- Bug# 4185621: change child line posting flag back to 'Y'
               , mmtt.wms_task_status = l_g_task_loaded -- Bug# 4185621: make sure task status is loaded
           WHERE mmtt.transaction_temp_id = l_child_txn_temp_id;

          l_child_txn_temp_id  := l_new_temp_id;
          l_child_pri_qty   := l_child_pri_qty - l_parent_pri_qty;
          l_child_txn_qty   := l_child_txn_qty - l_parent_txn_qty;
	  l_child_sec_qty   := l_child_sec_qty - l_parent_sec_qty;  --bug 8197506
          l_parent_txn_qty  := 0;
          l_parent_pri_qty  := 0;

          mydebug('BULK_PICK:new MMTT tmp id:'||l_new_temp_id,l_api_name);
          mydebug('BULK_PICK:new child pri qty:'||l_child_pri_qty,l_api_name);
          mydebug('BULK_PICK:new child txn qty:'||l_child_txn_qty,l_api_name);
	  mydebug('BULK_PICK:new child sec txn qty:'||l_child_sec_qty,l_api_name); --bug 8197506
          EXIT;
        END IF;
      END LOOP;

    END LOOP;
    -- create subtransfer if there are over picked qty
    IF (l_parent_pri_qty >0) THEN
        mydebug('BULK_PICK:calling create_sub_transfer to create sub transfer for over qty',l_api_name);
        create_sub_transfer(l_parent_txn_temp_id,l_parent_pri_qty,l_parent_pri_qty,1);
    END IF;
    IF c_child_mmtt_lines%ISOPEN THEN
  close c_child_mmtt_lines;
    ELSIF c_child_mmtt_lines_so%ISOPEN THEN
  close c_child_mmtt_lines_so ;
    ELSE close c_child_mmtt_lines_short;
    END IF;
   IF c_parent_mmtt_lines%ISOPEN THEN
    CLOSE c_parent_mmtt_lines;
   ELSE
    CLOSE c_parent_mmtt_shortpick;
   END IF;

END IF; -- end the association between child and parent lines


    IF p_exception= 'SHORT' THEN    -- picking short for lot controlled or plain item, need to make sure the cleanup
                                        -- task works for this case, no serial numbers if it is serial controlled
                                        -- should work since it is same as regular task


           mydebug('BULK_PICK: v1 calling cleanup_task for mmtt line:'||p_temp_id,l_api_name);
            wms_txnrsn_actions_pub.cleanup_task(
                p_temp_id => p_temp_id
                , p_qty_rsn_id => p_reason_id
                , p_user_id   => p_user_id
                , p_employee_id => p_employee_id
                , x_return_status  => x_return_status
                , x_msg_count           => x_msg_count
                , x_msg_data            => x_msg_data
            );

           IF x_return_status <> fnd_api.g_ret_sts_success THEN
           IF l_debug = 1 THEN
            mydebug('BULK_PICK: Error occurred while calling cleanup tasK ',l_api_name);
           END IF;
          RAISE fnd_api.g_exc_error;
        END IF;


    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('Unexpected Error occurred - ' || SQLERRM,l_api_name);
      END IF;

END bulk_pick;


END wms_bulk_pick;


/
