--------------------------------------------------------
--  DDL for Package Body INV_MO_LINE_DETAIL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MO_LINE_DETAIL_UTIL" AS
  /* $Header: INVUTLDB.pls 120.1 2008/02/08 09:08:51 aysaha ship $ */

  --  Global constant holding the package name

  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MO_LINE_DETAIL_UTIL';

  PROCEDURE DEBUG(p_message IN VARCHAR2, p_module IN VARCHAR2) IS
  BEGIN
    inv_log_util.trace(p_message, p_module, 9);
  END;

  --  Procedure Update_Row

  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_mo_line_detail_rec IN g_mmtt_rec) IS
  BEGIN
    UPDATE mtl_material_transactions_temp
       SET transaction_header_id = p_mo_line_detail_rec.transaction_header_id
         , source_code = p_mo_line_detail_rec.source_code
         , source_line_id = p_mo_line_detail_rec.source_line_id
         , transaction_mode = p_mo_line_detail_rec.transaction_mode
         , lock_flag = p_mo_line_detail_rec.lock_flag
         , last_update_date = p_mo_line_detail_rec.last_update_date
         , last_updated_by = p_mo_line_detail_rec.last_updated_by
         , creation_date = p_mo_line_detail_rec.creation_date
         , created_by = p_mo_line_detail_rec.created_by
         , last_update_login = p_mo_line_detail_rec.last_update_login
         , request_id = p_mo_line_detail_rec.request_id
         , program_application_id = p_mo_line_detail_rec.program_application_id
         , program_id = p_mo_line_detail_rec.program_id
         , program_update_date = p_mo_line_detail_rec.program_update_date
         , inventory_item_id = p_mo_line_detail_rec.inventory_item_id
         , revision = p_mo_line_detail_rec.revision
         , organization_id = p_mo_line_detail_rec.organization_id
         , subinventory_code = p_mo_line_detail_rec.subinventory_code
         , locator_id = p_mo_line_detail_rec.locator_id
         , transaction_quantity = p_mo_line_detail_rec.transaction_quantity
         , primary_quantity = p_mo_line_detail_rec.primary_quantity
         , transaction_uom = p_mo_line_detail_rec.transaction_uom
         , transaction_cost = p_mo_line_detail_rec.transaction_cost
         , transaction_type_id = p_mo_line_detail_rec.transaction_type_id
         , transaction_action_id = p_mo_line_detail_rec.transaction_action_id
         , transaction_source_type_id = p_mo_line_detail_rec.transaction_source_type_id
         , transaction_source_id = p_mo_line_detail_rec.transaction_source_id
         , transaction_source_name = p_mo_line_detail_rec.transaction_source_name
         , transaction_date = p_mo_line_detail_rec.transaction_date
         , acct_period_id = p_mo_line_detail_rec.acct_period_id
         , distribution_account_id = p_mo_line_detail_rec.distribution_account_id
         , transaction_reference = p_mo_line_detail_rec.transaction_reference
         , requisition_line_id = p_mo_line_detail_rec.requisition_line_id
         , requisition_distribution_id = p_mo_line_detail_rec.requisition_distribution_id
         , reason_id = p_mo_line_detail_rec.reason_id
         , lot_number = p_mo_line_detail_rec.lot_number
         , lot_expiration_date = p_mo_line_detail_rec.lot_expiration_date
         , serial_number = p_mo_line_detail_rec.serial_number
         , receiving_document = p_mo_line_detail_rec.receiving_document
         , demand_id = p_mo_line_detail_rec.demand_id
         , rcv_transaction_id = p_mo_line_detail_rec.rcv_transaction_id
         , move_transaction_id = p_mo_line_detail_rec.move_transaction_id
         , completion_transaction_id = p_mo_line_detail_rec.completion_transaction_id
         , wip_entity_type = p_mo_line_detail_rec.wip_entity_type
         , schedule_id = p_mo_line_detail_rec.schedule_id
         , repetitive_line_id = p_mo_line_detail_rec.repetitive_line_id
         , employee_code = p_mo_line_detail_rec.employee_code
         , primary_switch = p_mo_line_detail_rec.primary_switch
         , schedule_update_code = p_mo_line_detail_rec.schedule_update_code
         , setup_teardown_code = p_mo_line_detail_rec.setup_teardown_code
         , item_ordering = p_mo_line_detail_rec.item_ordering
         , negative_req_flag = p_mo_line_detail_rec.negative_req_flag
         , operation_seq_num = p_mo_line_detail_rec.operation_seq_num
         , picking_line_id = p_mo_line_detail_rec.picking_line_id
         , trx_source_line_id = p_mo_line_detail_rec.trx_source_line_id
         , trx_source_delivery_id = p_mo_line_detail_rec.trx_source_delivery_id
         , physical_adjustment_id = p_mo_line_detail_rec.physical_adjustment_id
         , cycle_count_id = p_mo_line_detail_rec.cycle_count_id
         , rma_line_id = p_mo_line_detail_rec.rma_line_id
         , customer_ship_id = p_mo_line_detail_rec.customer_ship_id
         , currency_code = p_mo_line_detail_rec.currency_code
         , currency_conversion_rate = p_mo_line_detail_rec.currency_conversion_rate
         , currency_conversion_type = p_mo_line_detail_rec.currency_conversion_type
         , currency_conversion_date = p_mo_line_detail_rec.currency_conversion_date
         , ussgl_transaction_code = p_mo_line_detail_rec.ussgl_transaction_code
         , vendor_lot_number = p_mo_line_detail_rec.vendor_lot_number
         , encumbrance_account = p_mo_line_detail_rec.encumbrance_account
         , encumbrance_amount = p_mo_line_detail_rec.encumbrance_amount
         , ship_to_location = p_mo_line_detail_rec.ship_to_location
         , shipment_number = p_mo_line_detail_rec.shipment_number
         , transfer_cost = p_mo_line_detail_rec.transfer_cost
         , transportation_cost = p_mo_line_detail_rec.transportation_cost
         , transportation_account = p_mo_line_detail_rec.transportation_account
         , freight_code = p_mo_line_detail_rec.freight_code
         , containers = p_mo_line_detail_rec.containers
         , waybill_airbill = p_mo_line_detail_rec.waybill_airbill
         , expected_arrival_date = p_mo_line_detail_rec.expected_arrival_date
         , transfer_subinventory = p_mo_line_detail_rec.transfer_subinventory
         , transfer_organization = p_mo_line_detail_rec.transfer_organization
         , transfer_to_location = p_mo_line_detail_rec.transfer_to_location
         , new_average_cost = p_mo_line_detail_rec.new_average_cost
         , value_change = p_mo_line_detail_rec.value_change
         , percentage_change = p_mo_line_detail_rec.percentage_change
         , material_allocation_temp_id = p_mo_line_detail_rec.material_allocation_temp_id
         , demand_source_header_id = p_mo_line_detail_rec.demand_source_header_id
         , demand_source_line = p_mo_line_detail_rec.demand_source_line
         , demand_source_delivery = p_mo_line_detail_rec.demand_source_delivery
         , item_segments = p_mo_line_detail_rec.item_segments
         , item_description = p_mo_line_detail_rec.item_description
         , item_trx_enabled_flag = p_mo_line_detail_rec.item_trx_enabled_flag
         , item_location_control_code = p_mo_line_detail_rec.item_location_control_code
         , item_restrict_subinv_code = p_mo_line_detail_rec.item_restrict_subinv_code
         , item_restrict_locators_code = p_mo_line_detail_rec.item_restrict_locators_code
         , item_revision_qty_control_code = p_mo_line_detail_rec.item_revision_qty_control_code
         , item_primary_uom_code = p_mo_line_detail_rec.item_primary_uom_code
         , item_uom_class = p_mo_line_detail_rec.item_uom_class
         , item_shelf_life_code = p_mo_line_detail_rec.item_shelf_life_code
         , item_shelf_life_days = p_mo_line_detail_rec.item_shelf_life_days
         , item_lot_control_code = p_mo_line_detail_rec.item_lot_control_code
         , item_serial_control_code = p_mo_line_detail_rec.item_serial_control_code
         , item_inventory_asset_flag = p_mo_line_detail_rec.item_inventory_asset_flag
         , allowed_units_lookup_code = p_mo_line_detail_rec.allowed_units_lookup_code
         , department_id = p_mo_line_detail_rec.department_id
         , department_code = p_mo_line_detail_rec.department_code
         , wip_supply_type = p_mo_line_detail_rec.wip_supply_type
         , supply_subinventory = p_mo_line_detail_rec.supply_subinventory
         , supply_locator_id = p_mo_line_detail_rec.supply_locator_id
         , valid_subinventory_flag = p_mo_line_detail_rec.valid_subinventory_flag
         , valid_locator_flag = p_mo_line_detail_rec.valid_locator_flag
         , locator_segments = p_mo_line_detail_rec.locator_segments
         , current_locator_control_code = p_mo_line_detail_rec.current_locator_control_code
         , number_of_lots_entered = p_mo_line_detail_rec.number_of_lots_entered
         , wip_commit_flag = p_mo_line_detail_rec.wip_commit_flag
         , next_lot_number = p_mo_line_detail_rec.next_lot_number
         , lot_alpha_prefix = p_mo_line_detail_rec.lot_alpha_prefix
         , next_serial_number = p_mo_line_detail_rec.next_serial_number
         , serial_alpha_prefix = p_mo_line_detail_rec.serial_alpha_prefix
         , shippable_flag = p_mo_line_detail_rec.shippable_flag
         , posting_flag = p_mo_line_detail_rec.posting_flag
         , required_flag = p_mo_line_detail_rec.required_flag
         , process_flag = p_mo_line_detail_rec.process_flag
         , ERROR_CODE = p_mo_line_detail_rec.ERROR_CODE
         , error_explanation = p_mo_line_detail_rec.error_explanation
         , movement_id = p_mo_line_detail_rec.movement_id
         , reservation_quantity = p_mo_line_detail_rec.reservation_quantity
         , shipped_quantity = p_mo_line_detail_rec.shipped_quantity
         , transaction_line_number = p_mo_line_detail_rec.transaction_line_number
         , task_id = p_mo_line_detail_rec.task_id
         , to_task_id = p_mo_line_detail_rec.to_task_id
         , source_task_id = p_mo_line_detail_rec.source_task_id
         , project_id = p_mo_line_detail_rec.project_id
         , source_project_id = p_mo_line_detail_rec.source_project_id
         , pa_expenditure_org_id = p_mo_line_detail_rec.pa_expenditure_org_id
         , to_project_id = p_mo_line_detail_rec.to_project_id
         , expenditure_type = p_mo_line_detail_rec.expenditure_type
         , final_completion_flag = p_mo_line_detail_rec.final_completion_flag
         , transfer_percentage = p_mo_line_detail_rec.transfer_percentage
         , transaction_sequence_id = p_mo_line_detail_rec.transaction_sequence_id
         , material_account = p_mo_line_detail_rec.material_account
         , material_overhead_account = p_mo_line_detail_rec.material_overhead_account
         , resource_account = p_mo_line_detail_rec.resource_account
         , outside_processing_account = p_mo_line_detail_rec.outside_processing_account
         , overhead_account = p_mo_line_detail_rec.overhead_account
         , flow_schedule = p_mo_line_detail_rec.flow_schedule
         , cost_group_id = p_mo_line_detail_rec.cost_group_id
         , demand_class = p_mo_line_detail_rec.demand_class
         , qa_collection_id = p_mo_line_detail_rec.qa_collection_id
         , kanban_card_id = p_mo_line_detail_rec.kanban_card_id
         , overcompletion_transaction_id = p_mo_line_detail_rec.overcompletion_transaction_id
         , overcompletion_primary_qty = p_mo_line_detail_rec.overcompletion_primary_qty
         , overcompletion_transaction_qty = p_mo_line_detail_rec.overcompletion_transaction_qty
         , end_item_unit_number = p_mo_line_detail_rec.end_item_unit_number
         , scheduled_payback_date = p_mo_line_detail_rec.scheduled_payback_date
         , line_type_code = p_mo_line_detail_rec.line_type_code
         , parent_transaction_temp_id = p_mo_line_detail_rec.parent_transaction_temp_id
         , put_away_strategy_id = p_mo_line_detail_rec.put_away_strategy_id
         , put_away_rule_id = p_mo_line_detail_rec.put_away_rule_id
         , pick_strategy_id = p_mo_line_detail_rec.pick_strategy_id
         , pick_rule_id = p_mo_line_detail_rec.pick_rule_id
         , common_bom_seq_id = p_mo_line_detail_rec.common_bom_seq_id
         , common_routing_seq_id = p_mo_line_detail_rec.common_routing_seq_id
         , cost_type_id = p_mo_line_detail_rec.cost_type_id
         , org_cost_group_id = p_mo_line_detail_rec.org_cost_group_id
         , move_order_line_id = p_mo_line_detail_rec.move_order_line_id
         , task_group_id = p_mo_line_detail_rec.task_group_id
         , pick_slip_number = p_mo_line_detail_rec.pick_slip_number
         , reservation_id = p_mo_line_detail_rec.reservation_id
         , transaction_status = p_mo_line_detail_rec.transaction_status
         , transfer_cost_group_id = p_mo_line_detail_rec.transfer_cost_group_id
         , lpn_id = p_mo_line_detail_rec.lpn_id
         , transfer_lpn_id = p_mo_line_detail_rec.transfer_lpn_id
         , pick_slip_date = p_mo_line_detail_rec.pick_slip_date
         , content_lpn_id = p_mo_line_detail_rec.content_lpn_id
         , secondary_transaction_quantity = p_mo_line_detail_rec.secondary_transaction_quantity  -- INVCONV change
         , secondary_uom_code             = p_mo_line_detail_rec.secondary_uom_code              -- INVCONV change
     WHERE move_order_line_id = p_mo_line_detail_rec.move_order_line_id
       AND transaction_temp_id = p_mo_line_detail_rec.transaction_temp_id;

    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Update_Row');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
  END update_row;

  --  Procedure Insert_Row
  PROCEDURE insert_row(x_return_status OUT NOCOPY VARCHAR2, p_mo_line_detail_rec IN g_mmtt_rec) IS
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

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
               , pick_slip_date
               , content_lpn_id
               , secondary_transaction_quantity  -- INVCONV change
               , secondary_uom_code              -- INVCONV change
                )
         VALUES (
                 p_mo_line_detail_rec.transaction_header_id
               , p_mo_line_detail_rec.transaction_temp_id
               , p_mo_line_detail_rec.source_code
               , p_mo_line_detail_rec.source_line_id
               , p_mo_line_detail_rec.transaction_mode
               , p_mo_line_detail_rec.lock_flag
               , p_mo_line_detail_rec.last_update_date
               , p_mo_line_detail_rec.last_updated_by
               , p_mo_line_detail_rec.creation_date
               , p_mo_line_detail_rec.created_by
               , p_mo_line_detail_rec.last_update_login
               , p_mo_line_detail_rec.request_id
               , p_mo_line_detail_rec.program_application_id
               , p_mo_line_detail_rec.program_id
               , p_mo_line_detail_rec.program_update_date
               , p_mo_line_detail_rec.inventory_item_id
               , p_mo_line_detail_rec.revision
               , p_mo_line_detail_rec.organization_id
               , p_mo_line_detail_rec.subinventory_code
               , p_mo_line_detail_rec.locator_id
               , p_mo_line_detail_rec.transaction_quantity
               , p_mo_line_detail_rec.primary_quantity
               , p_mo_line_detail_rec.transaction_uom
               , p_mo_line_detail_rec.transaction_cost
               , p_mo_line_detail_rec.transaction_type_id
               , p_mo_line_detail_rec.transaction_action_id
               , p_mo_line_detail_rec.transaction_source_type_id
               , p_mo_line_detail_rec.transaction_source_id
               , p_mo_line_detail_rec.transaction_source_name
               , p_mo_line_detail_rec.transaction_date
               , p_mo_line_detail_rec.acct_period_id
               , p_mo_line_detail_rec.distribution_account_id
               , p_mo_line_detail_rec.transaction_reference
               , p_mo_line_detail_rec.requisition_line_id
               , p_mo_line_detail_rec.requisition_distribution_id
               , p_mo_line_detail_rec.reason_id
               , p_mo_line_detail_rec.lot_number
               , p_mo_line_detail_rec.lot_expiration_date
               , p_mo_line_detail_rec.serial_number
               , p_mo_line_detail_rec.receiving_document
               , p_mo_line_detail_rec.demand_id
               , p_mo_line_detail_rec.rcv_transaction_id
               , p_mo_line_detail_rec.move_transaction_id
               , p_mo_line_detail_rec.completion_transaction_id
               , p_mo_line_detail_rec.wip_entity_type
               , p_mo_line_detail_rec.schedule_id
               , p_mo_line_detail_rec.repetitive_line_id
               , p_mo_line_detail_rec.employee_code
               , p_mo_line_detail_rec.primary_switch
               , p_mo_line_detail_rec.schedule_update_code
               , p_mo_line_detail_rec.setup_teardown_code
               , p_mo_line_detail_rec.item_ordering
               , p_mo_line_detail_rec.negative_req_flag
               , p_mo_line_detail_rec.operation_seq_num
               , p_mo_line_detail_rec.picking_line_id
               , p_mo_line_detail_rec.trx_source_line_id
               , p_mo_line_detail_rec.trx_source_delivery_id
               , p_mo_line_detail_rec.physical_adjustment_id
               , p_mo_line_detail_rec.cycle_count_id
               , p_mo_line_detail_rec.rma_line_id
               , p_mo_line_detail_rec.customer_ship_id
               , p_mo_line_detail_rec.currency_code
               , p_mo_line_detail_rec.currency_conversion_rate
               , p_mo_line_detail_rec.currency_conversion_type
               , p_mo_line_detail_rec.currency_conversion_date
               , p_mo_line_detail_rec.ussgl_transaction_code
               , p_mo_line_detail_rec.vendor_lot_number
               , p_mo_line_detail_rec.encumbrance_account
               , p_mo_line_detail_rec.encumbrance_amount
               , p_mo_line_detail_rec.ship_to_location
               , p_mo_line_detail_rec.shipment_number
               , p_mo_line_detail_rec.transfer_cost
               , p_mo_line_detail_rec.transportation_cost
               , p_mo_line_detail_rec.transportation_account
               , p_mo_line_detail_rec.freight_code
               , p_mo_line_detail_rec.containers
               , p_mo_line_detail_rec.waybill_airbill
               , p_mo_line_detail_rec.expected_arrival_date
               , p_mo_line_detail_rec.transfer_subinventory
               , p_mo_line_detail_rec.transfer_organization
               , p_mo_line_detail_rec.transfer_to_location
               , p_mo_line_detail_rec.new_average_cost
               , p_mo_line_detail_rec.value_change
               , p_mo_line_detail_rec.percentage_change
               , p_mo_line_detail_rec.material_allocation_temp_id
               , p_mo_line_detail_rec.demand_source_header_id
               , p_mo_line_detail_rec.demand_source_line
               , p_mo_line_detail_rec.demand_source_delivery
               , p_mo_line_detail_rec.item_segments
               , p_mo_line_detail_rec.item_description
               , p_mo_line_detail_rec.item_trx_enabled_flag
               , p_mo_line_detail_rec.item_location_control_code
               , p_mo_line_detail_rec.item_restrict_subinv_code
               , p_mo_line_detail_rec.item_restrict_locators_code
               , p_mo_line_detail_rec.item_revision_qty_control_code
               , p_mo_line_detail_rec.item_primary_uom_code
               , p_mo_line_detail_rec.item_uom_class
               , p_mo_line_detail_rec.item_shelf_life_code
               , p_mo_line_detail_rec.item_shelf_life_days
               , p_mo_line_detail_rec.item_lot_control_code
               , p_mo_line_detail_rec.item_serial_control_code
               , p_mo_line_detail_rec.item_inventory_asset_flag
               , p_mo_line_detail_rec.allowed_units_lookup_code
               , p_mo_line_detail_rec.department_id
               , p_mo_line_detail_rec.department_code
               , p_mo_line_detail_rec.wip_supply_type
               , p_mo_line_detail_rec.supply_subinventory
               , p_mo_line_detail_rec.supply_locator_id
               , p_mo_line_detail_rec.valid_subinventory_flag
               , p_mo_line_detail_rec.valid_locator_flag
               , p_mo_line_detail_rec.locator_segments
               , p_mo_line_detail_rec.current_locator_control_code
               , p_mo_line_detail_rec.number_of_lots_entered
               , p_mo_line_detail_rec.wip_commit_flag
               , p_mo_line_detail_rec.next_lot_number
               , p_mo_line_detail_rec.lot_alpha_prefix
               , p_mo_line_detail_rec.next_serial_number
               , p_mo_line_detail_rec.serial_alpha_prefix
               , p_mo_line_detail_rec.shippable_flag
               , p_mo_line_detail_rec.posting_flag
               , p_mo_line_detail_rec.required_flag
               , p_mo_line_detail_rec.process_flag
               , p_mo_line_detail_rec.ERROR_CODE
               , p_mo_line_detail_rec.error_explanation
               , p_mo_line_detail_rec.attribute_category
               , p_mo_line_detail_rec.attribute1
               , p_mo_line_detail_rec.attribute2
               , p_mo_line_detail_rec.attribute3
               , p_mo_line_detail_rec.attribute4
               , p_mo_line_detail_rec.attribute5
               , p_mo_line_detail_rec.attribute6
               , p_mo_line_detail_rec.attribute7
               , p_mo_line_detail_rec.attribute8
               , p_mo_line_detail_rec.attribute9
               , p_mo_line_detail_rec.attribute10
               , p_mo_line_detail_rec.attribute11
               , p_mo_line_detail_rec.attribute12
               , p_mo_line_detail_rec.attribute13
               , p_mo_line_detail_rec.attribute14
               , p_mo_line_detail_rec.attribute15
               , p_mo_line_detail_rec.movement_id
               , p_mo_line_detail_rec.reservation_quantity
               , p_mo_line_detail_rec.shipped_quantity
               , p_mo_line_detail_rec.transaction_line_number
               , p_mo_line_detail_rec.task_id
               , p_mo_line_detail_rec.to_task_id
               , p_mo_line_detail_rec.source_task_id
               , p_mo_line_detail_rec.project_id
               , p_mo_line_detail_rec.source_project_id
               , p_mo_line_detail_rec.pa_expenditure_org_id
               , p_mo_line_detail_rec.to_project_id
               , p_mo_line_detail_rec.expenditure_type
               , p_mo_line_detail_rec.final_completion_flag
               , p_mo_line_detail_rec.transfer_percentage
               , p_mo_line_detail_rec.transaction_sequence_id
               , p_mo_line_detail_rec.material_account
               , p_mo_line_detail_rec.material_overhead_account
               , p_mo_line_detail_rec.resource_account
               , p_mo_line_detail_rec.outside_processing_account
               , p_mo_line_detail_rec.overhead_account
               , p_mo_line_detail_rec.flow_schedule
               , p_mo_line_detail_rec.cost_group_id
               , p_mo_line_detail_rec.demand_class
               , p_mo_line_detail_rec.qa_collection_id
               , p_mo_line_detail_rec.kanban_card_id
               , p_mo_line_detail_rec.overcompletion_transaction_id
               , p_mo_line_detail_rec.overcompletion_primary_qty
               , p_mo_line_detail_rec.overcompletion_transaction_qty
               , p_mo_line_detail_rec.end_item_unit_number
               , p_mo_line_detail_rec.scheduled_payback_date
               , p_mo_line_detail_rec.line_type_code
               , p_mo_line_detail_rec.parent_transaction_temp_id
               , p_mo_line_detail_rec.put_away_strategy_id
               , p_mo_line_detail_rec.put_away_rule_id
               , p_mo_line_detail_rec.pick_strategy_id
               , p_mo_line_detail_rec.pick_rule_id
               , p_mo_line_detail_rec.common_bom_seq_id
               , p_mo_line_detail_rec.common_routing_seq_id
               , p_mo_line_detail_rec.cost_type_id
               , p_mo_line_detail_rec.org_cost_group_id
               , p_mo_line_detail_rec.move_order_line_id
               , p_mo_line_detail_rec.task_group_id
               , p_mo_line_detail_rec.pick_slip_number
               , p_mo_line_detail_rec.reservation_id
               , p_mo_line_detail_rec.transaction_status
               , p_mo_line_detail_rec.transfer_cost_group_id
               , p_mo_line_detail_rec.lpn_id
               , p_mo_line_detail_rec.transfer_lpn_id
               , p_mo_line_detail_rec.pick_slip_date
               , p_mo_line_detail_rec.content_lpn_id
               , p_mo_line_detail_rec.secondary_transaction_quantity       -- INVCONV change
               , p_mo_line_detail_rec.secondary_uom_code                   -- INVCONV change
                );
  END insert_row;

  --  Procedure Delete_Row
  PROCEDURE delete_row(x_return_status OUT NOCOPY VARCHAR2, p_line_id IN NUMBER, p_line_detail_id IN NUMBER) IS
  BEGIN
    DELETE FROM mtl_material_transactions_temp
          WHERE move_order_line_id = p_line_id
            AND transaction_temp_id = p_line_detail_id;

    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Delete_Row');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
  END delete_row;

  --  Procedure       lock_Row
  PROCEDURE lock_row(
    x_return_status      OUT NOCOPY VARCHAR2
  , p_mo_line_detail_rec IN         g_mmtt_rec
  , x_mo_line_detail_rec OUT NOCOPY g_mmtt_rec
  ) IS
    l_mmtt_rec g_mmtt_rec;
    l_debug    NUMBER     := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    SELECT     transaction_header_id
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
             , pick_slip_date
             , content_lpn_id
             , secondary_transaction_quantity     -- INVCONV change
             , secondary_uom_code                 -- INVCONV change
          INTO l_mmtt_rec.transaction_header_id
             , l_mmtt_rec.transaction_temp_id
             , l_mmtt_rec.source_code
             , l_mmtt_rec.source_line_id
             , l_mmtt_rec.transaction_mode
             , l_mmtt_rec.lock_flag
             , l_mmtt_rec.last_update_date
             , l_mmtt_rec.last_updated_by
             , l_mmtt_rec.creation_date
             , l_mmtt_rec.created_by
             , l_mmtt_rec.last_update_login
             , l_mmtt_rec.request_id
             , l_mmtt_rec.program_application_id
             , l_mmtt_rec.program_id
             , l_mmtt_rec.program_update_date
             , l_mmtt_rec.inventory_item_id
             , l_mmtt_rec.revision
             , l_mmtt_rec.organization_id
             , l_mmtt_rec.subinventory_code
             , l_mmtt_rec.locator_id
             , l_mmtt_rec.transaction_quantity
             , l_mmtt_rec.primary_quantity
             , l_mmtt_rec.transaction_uom
             , l_mmtt_rec.transaction_cost
             , l_mmtt_rec.transaction_type_id
             , l_mmtt_rec.transaction_action_id
             , l_mmtt_rec.transaction_source_type_id
             , l_mmtt_rec.transaction_source_id
             , l_mmtt_rec.transaction_source_name
             , l_mmtt_rec.transaction_date
             , l_mmtt_rec.acct_period_id
             , l_mmtt_rec.distribution_account_id
             , l_mmtt_rec.transaction_reference
             , l_mmtt_rec.requisition_line_id
             , l_mmtt_rec.requisition_distribution_id
             , l_mmtt_rec.reason_id
             , l_mmtt_rec.lot_number
             , l_mmtt_rec.lot_expiration_date
             , l_mmtt_rec.serial_number
             , l_mmtt_rec.receiving_document
             , l_mmtt_rec.demand_id
             , l_mmtt_rec.rcv_transaction_id
             , l_mmtt_rec.move_transaction_id
             , l_mmtt_rec.completion_transaction_id
             , l_mmtt_rec.wip_entity_type
             , l_mmtt_rec.schedule_id
             , l_mmtt_rec.repetitive_line_id
             , l_mmtt_rec.employee_code
             , l_mmtt_rec.primary_switch
             , l_mmtt_rec.schedule_update_code
             , l_mmtt_rec.setup_teardown_code
             , l_mmtt_rec.item_ordering
             , l_mmtt_rec.negative_req_flag
             , l_mmtt_rec.operation_seq_num
             , l_mmtt_rec.picking_line_id
             , l_mmtt_rec.trx_source_line_id
             , l_mmtt_rec.trx_source_delivery_id
             , l_mmtt_rec.physical_adjustment_id
             , l_mmtt_rec.cycle_count_id
             , l_mmtt_rec.rma_line_id
             , l_mmtt_rec.customer_ship_id
             , l_mmtt_rec.currency_code
             , l_mmtt_rec.currency_conversion_rate
             , l_mmtt_rec.currency_conversion_type
             , l_mmtt_rec.currency_conversion_date
             , l_mmtt_rec.ussgl_transaction_code
             , l_mmtt_rec.vendor_lot_number
             , l_mmtt_rec.encumbrance_account
             , l_mmtt_rec.encumbrance_amount
             , l_mmtt_rec.ship_to_location
             , l_mmtt_rec.shipment_number
             , l_mmtt_rec.transfer_cost
             , l_mmtt_rec.transportation_cost
             , l_mmtt_rec.transportation_account
             , l_mmtt_rec.freight_code
             , l_mmtt_rec.containers
             , l_mmtt_rec.waybill_airbill
             , l_mmtt_rec.expected_arrival_date
             , l_mmtt_rec.transfer_subinventory
             , l_mmtt_rec.transfer_organization
             , l_mmtt_rec.transfer_to_location
             , l_mmtt_rec.new_average_cost
             , l_mmtt_rec.value_change
             , l_mmtt_rec.percentage_change
             , l_mmtt_rec.material_allocation_temp_id
             , l_mmtt_rec.demand_source_header_id
             , l_mmtt_rec.demand_source_line
             , l_mmtt_rec.demand_source_delivery
             , l_mmtt_rec.item_segments
             , l_mmtt_rec.item_description
             , l_mmtt_rec.item_trx_enabled_flag
             , l_mmtt_rec.item_location_control_code
             , l_mmtt_rec.item_restrict_subinv_code
             , l_mmtt_rec.item_restrict_locators_code
             , l_mmtt_rec.item_revision_qty_control_code
             , l_mmtt_rec.item_primary_uom_code
             , l_mmtt_rec.item_uom_class
             , l_mmtt_rec.item_shelf_life_code
             , l_mmtt_rec.item_shelf_life_days
             , l_mmtt_rec.item_lot_control_code
             , l_mmtt_rec.item_serial_control_code
             , l_mmtt_rec.item_inventory_asset_flag
             , l_mmtt_rec.allowed_units_lookup_code
             , l_mmtt_rec.department_id
             , l_mmtt_rec.department_code
             , l_mmtt_rec.wip_supply_type
             , l_mmtt_rec.supply_subinventory
             , l_mmtt_rec.supply_locator_id
             , l_mmtt_rec.valid_subinventory_flag
             , l_mmtt_rec.valid_locator_flag
             , l_mmtt_rec.locator_segments
             , l_mmtt_rec.current_locator_control_code
             , l_mmtt_rec.number_of_lots_entered
             , l_mmtt_rec.wip_commit_flag
             , l_mmtt_rec.next_lot_number
             , l_mmtt_rec.lot_alpha_prefix
             , l_mmtt_rec.next_serial_number
             , l_mmtt_rec.serial_alpha_prefix
             , l_mmtt_rec.shippable_flag
             , l_mmtt_rec.posting_flag
             , l_mmtt_rec.required_flag
             , l_mmtt_rec.process_flag
             , l_mmtt_rec.ERROR_CODE
             , l_mmtt_rec.error_explanation
             , l_mmtt_rec.attribute_category
             , l_mmtt_rec.attribute1
             , l_mmtt_rec.attribute2
             , l_mmtt_rec.attribute3
             , l_mmtt_rec.attribute4
             , l_mmtt_rec.attribute5
             , l_mmtt_rec.attribute6
             , l_mmtt_rec.attribute7
             , l_mmtt_rec.attribute8
             , l_mmtt_rec.attribute9
             , l_mmtt_rec.attribute10
             , l_mmtt_rec.attribute11
             , l_mmtt_rec.attribute12
             , l_mmtt_rec.attribute13
             , l_mmtt_rec.attribute14
             , l_mmtt_rec.attribute15
             , l_mmtt_rec.movement_id
             , l_mmtt_rec.reservation_quantity
             , l_mmtt_rec.shipped_quantity
             , l_mmtt_rec.transaction_line_number
             , l_mmtt_rec.task_id
             , l_mmtt_rec.to_task_id
             , l_mmtt_rec.source_task_id
             , l_mmtt_rec.project_id
             , l_mmtt_rec.source_project_id
             , l_mmtt_rec.pa_expenditure_org_id
             , l_mmtt_rec.to_project_id
             , l_mmtt_rec.expenditure_type
             , l_mmtt_rec.final_completion_flag
             , l_mmtt_rec.transfer_percentage
             , l_mmtt_rec.transaction_sequence_id
             , l_mmtt_rec.material_account
             , l_mmtt_rec.material_overhead_account
             , l_mmtt_rec.resource_account
             , l_mmtt_rec.outside_processing_account
             , l_mmtt_rec.overhead_account
             , l_mmtt_rec.flow_schedule
             , l_mmtt_rec.cost_group_id
             , l_mmtt_rec.demand_class
             , l_mmtt_rec.qa_collection_id
             , l_mmtt_rec.kanban_card_id
             , l_mmtt_rec.overcompletion_transaction_id
             , l_mmtt_rec.overcompletion_primary_qty
             , l_mmtt_rec.overcompletion_transaction_qty
             , l_mmtt_rec.end_item_unit_number
             , l_mmtt_rec.scheduled_payback_date
             , l_mmtt_rec.line_type_code
             , l_mmtt_rec.parent_transaction_temp_id
             , l_mmtt_rec.put_away_strategy_id
             , l_mmtt_rec.put_away_rule_id
             , l_mmtt_rec.pick_strategy_id
             , l_mmtt_rec.pick_rule_id
             , l_mmtt_rec.common_bom_seq_id
             , l_mmtt_rec.common_routing_seq_id
             , l_mmtt_rec.cost_type_id
             , l_mmtt_rec.org_cost_group_id
             , l_mmtt_rec.move_order_line_id
             , l_mmtt_rec.task_group_id
             , l_mmtt_rec.pick_slip_number
             , l_mmtt_rec.reservation_id
             , l_mmtt_rec.transaction_status
             , l_mmtt_rec.transfer_cost_group_id
             , l_mmtt_rec.lpn_id
             , l_mmtt_rec.transfer_lpn_id
             , l_mmtt_rec.pick_slip_date
             , l_mmtt_rec.content_lpn_id
             , l_mmtt_rec.secondary_transaction_quantity     -- INVCONV change
             , l_mmtt_rec.secondary_uom_code                 -- INVCONV change
          FROM mtl_material_transactions_temp
         WHERE move_order_line_id = p_mo_line_detail_rec.move_order_line_id
    FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF inv_globals.equal(p_mo_line_detail_rec.transaction_header_id, l_mmtt_rec.transaction_header_id)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_temp_id, l_mmtt_rec.transaction_temp_id)
       AND inv_globals.equal(p_mo_line_detail_rec.source_code, l_mmtt_rec.source_code)
       AND inv_globals.equal(p_mo_line_detail_rec.source_line_id, l_mmtt_rec.source_line_id)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_mode, l_mmtt_rec.transaction_mode)
       AND inv_globals.equal(p_mo_line_detail_rec.lock_flag, l_mmtt_rec.lock_flag)
       AND inv_globals.equal(p_mo_line_detail_rec.last_update_date, l_mmtt_rec.last_update_date)
       AND inv_globals.equal(p_mo_line_detail_rec.last_updated_by, l_mmtt_rec.last_updated_by)
       AND inv_globals.equal(p_mo_line_detail_rec.creation_date, l_mmtt_rec.creation_date)
       AND inv_globals.equal(p_mo_line_detail_rec.created_by, l_mmtt_rec.created_by)
       AND inv_globals.equal(p_mo_line_detail_rec.last_update_login, l_mmtt_rec.last_update_login)
       AND inv_globals.equal(p_mo_line_detail_rec.request_id, l_mmtt_rec.request_id)
       AND inv_globals.equal(p_mo_line_detail_rec.program_application_id, l_mmtt_rec.program_application_id)
       AND inv_globals.equal(p_mo_line_detail_rec.program_id, l_mmtt_rec.program_id)
       AND inv_globals.equal(p_mo_line_detail_rec.program_update_date, l_mmtt_rec.program_update_date)
       AND inv_globals.equal(p_mo_line_detail_rec.inventory_item_id, l_mmtt_rec.inventory_item_id)
       AND inv_globals.equal(p_mo_line_detail_rec.revision, l_mmtt_rec.revision)
       AND inv_globals.equal(p_mo_line_detail_rec.organization_id, l_mmtt_rec.organization_id)
       AND inv_globals.equal(p_mo_line_detail_rec.subinventory_code, l_mmtt_rec.subinventory_code)
       AND inv_globals.equal(p_mo_line_detail_rec.locator_id, l_mmtt_rec.locator_id)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_quantity, l_mmtt_rec.transaction_quantity)
       AND inv_globals.equal(p_mo_line_detail_rec.primary_quantity, l_mmtt_rec.primary_quantity)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_uom, l_mmtt_rec.transaction_uom)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_cost, l_mmtt_rec.transaction_cost)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_type_id, l_mmtt_rec.transaction_type_id)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_action_id, l_mmtt_rec.transaction_action_id)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_source_type_id, l_mmtt_rec.transaction_source_type_id)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_source_id, l_mmtt_rec.transaction_source_id)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_source_name, l_mmtt_rec.transaction_source_name)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_date, l_mmtt_rec.transaction_date)
       AND inv_globals.equal(p_mo_line_detail_rec.acct_period_id, l_mmtt_rec.acct_period_id)
       AND inv_globals.equal(p_mo_line_detail_rec.distribution_account_id, l_mmtt_rec.distribution_account_id)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_reference, l_mmtt_rec.transaction_reference)
       AND inv_globals.equal(p_mo_line_detail_rec.requisition_line_id, l_mmtt_rec.requisition_line_id)
       AND inv_globals.equal(p_mo_line_detail_rec.requisition_distribution_id, l_mmtt_rec.requisition_distribution_id)
       AND inv_globals.equal(p_mo_line_detail_rec.reason_id, l_mmtt_rec.reason_id)
       AND inv_globals.equal(p_mo_line_detail_rec.lot_number, l_mmtt_rec.lot_number)
       AND inv_globals.equal(p_mo_line_detail_rec.lot_expiration_date, l_mmtt_rec.lot_expiration_date)
       AND inv_globals.equal(p_mo_line_detail_rec.serial_number, l_mmtt_rec.serial_number)
       AND inv_globals.equal(p_mo_line_detail_rec.receiving_document, l_mmtt_rec.receiving_document)
       AND inv_globals.equal(p_mo_line_detail_rec.demand_id, l_mmtt_rec.demand_id)
       AND inv_globals.equal(p_mo_line_detail_rec.rcv_transaction_id, l_mmtt_rec.rcv_transaction_id)
       AND inv_globals.equal(p_mo_line_detail_rec.move_transaction_id, l_mmtt_rec.move_transaction_id)
       AND inv_globals.equal(p_mo_line_detail_rec.completion_transaction_id, l_mmtt_rec.completion_transaction_id)
       AND inv_globals.equal(p_mo_line_detail_rec.wip_entity_type, l_mmtt_rec.wip_entity_type)
       AND inv_globals.equal(p_mo_line_detail_rec.schedule_id, l_mmtt_rec.schedule_id)
       AND inv_globals.equal(p_mo_line_detail_rec.repetitive_line_id, l_mmtt_rec.repetitive_line_id)
       AND inv_globals.equal(p_mo_line_detail_rec.employee_code, l_mmtt_rec.employee_code)
       AND inv_globals.equal(p_mo_line_detail_rec.primary_switch, l_mmtt_rec.primary_switch)
       AND inv_globals.equal(p_mo_line_detail_rec.schedule_update_code, l_mmtt_rec.schedule_update_code)
       AND inv_globals.equal(p_mo_line_detail_rec.setup_teardown_code, l_mmtt_rec.setup_teardown_code)
       AND inv_globals.equal(p_mo_line_detail_rec.item_ordering, l_mmtt_rec.item_ordering)
       AND inv_globals.equal(p_mo_line_detail_rec.negative_req_flag, l_mmtt_rec.negative_req_flag)
       AND inv_globals.equal(p_mo_line_detail_rec.operation_seq_num, l_mmtt_rec.operation_seq_num)
       AND inv_globals.equal(p_mo_line_detail_rec.picking_line_id, l_mmtt_rec.picking_line_id)
       AND inv_globals.equal(p_mo_line_detail_rec.trx_source_line_id, l_mmtt_rec.trx_source_line_id)
       AND inv_globals.equal(p_mo_line_detail_rec.trx_source_delivery_id, l_mmtt_rec.trx_source_delivery_id)
       AND inv_globals.equal(p_mo_line_detail_rec.physical_adjustment_id, l_mmtt_rec.physical_adjustment_id)
       AND inv_globals.equal(p_mo_line_detail_rec.cycle_count_id, l_mmtt_rec.cycle_count_id)
       AND inv_globals.equal(p_mo_line_detail_rec.rma_line_id, l_mmtt_rec.rma_line_id)
       AND inv_globals.equal(p_mo_line_detail_rec.customer_ship_id, l_mmtt_rec.customer_ship_id)
       AND inv_globals.equal(p_mo_line_detail_rec.currency_code, l_mmtt_rec.currency_code)
       AND inv_globals.equal(p_mo_line_detail_rec.currency_conversion_rate, l_mmtt_rec.currency_conversion_rate)
       AND inv_globals.equal(p_mo_line_detail_rec.currency_conversion_type, l_mmtt_rec.currency_conversion_type)
       AND inv_globals.equal(p_mo_line_detail_rec.currency_conversion_date, l_mmtt_rec.currency_conversion_date)
       AND inv_globals.equal(p_mo_line_detail_rec.ussgl_transaction_code, l_mmtt_rec.ussgl_transaction_code)
       AND inv_globals.equal(p_mo_line_detail_rec.vendor_lot_number, l_mmtt_rec.vendor_lot_number)
       AND inv_globals.equal(p_mo_line_detail_rec.encumbrance_account, l_mmtt_rec.encumbrance_account)
       AND inv_globals.equal(p_mo_line_detail_rec.ship_to_location, l_mmtt_rec.ship_to_location)
       AND inv_globals.equal(p_mo_line_detail_rec.shipment_number, l_mmtt_rec.shipment_number)
       AND inv_globals.equal(p_mo_line_detail_rec.transfer_cost, l_mmtt_rec.transfer_cost)
       AND inv_globals.equal(p_mo_line_detail_rec.transportation_cost, l_mmtt_rec.transportation_cost)
       AND inv_globals.equal(p_mo_line_detail_rec.transportation_account, l_mmtt_rec.transportation_account)
       AND inv_globals.equal(p_mo_line_detail_rec.freight_code, l_mmtt_rec.freight_code)
       AND inv_globals.equal(p_mo_line_detail_rec.containers, l_mmtt_rec.containers)
       AND inv_globals.equal(p_mo_line_detail_rec.waybill_airbill, l_mmtt_rec.waybill_airbill)
       AND inv_globals.equal(p_mo_line_detail_rec.expected_arrival_date, l_mmtt_rec.expected_arrival_date)
       AND inv_globals.equal(p_mo_line_detail_rec.transfer_subinventory, l_mmtt_rec.transfer_subinventory)
       AND inv_globals.equal(p_mo_line_detail_rec.transfer_organization, l_mmtt_rec.transfer_organization)
       AND inv_globals.equal(p_mo_line_detail_rec.transfer_to_location, l_mmtt_rec.transfer_to_location)
       AND inv_globals.equal(p_mo_line_detail_rec.new_average_cost, l_mmtt_rec.new_average_cost)
       AND inv_globals.equal(p_mo_line_detail_rec.value_change, l_mmtt_rec.value_change)
       AND inv_globals.equal(p_mo_line_detail_rec.percentage_change, l_mmtt_rec.percentage_change)
       AND inv_globals.equal(p_mo_line_detail_rec.material_allocation_temp_id, l_mmtt_rec.material_allocation_temp_id)
       AND inv_globals.equal(p_mo_line_detail_rec.demand_source_header_id, l_mmtt_rec.demand_source_header_id)
       AND inv_globals.equal(p_mo_line_detail_rec.demand_source_line, l_mmtt_rec.demand_source_line)
       AND inv_globals.equal(p_mo_line_detail_rec.demand_source_delivery, l_mmtt_rec.demand_source_delivery)
       AND inv_globals.equal(p_mo_line_detail_rec.item_segments, l_mmtt_rec.item_segments)
       AND inv_globals.equal(p_mo_line_detail_rec.item_description, l_mmtt_rec.item_description)
       AND inv_globals.equal(p_mo_line_detail_rec.item_trx_enabled_flag, l_mmtt_rec.item_trx_enabled_flag)
       AND inv_globals.equal(p_mo_line_detail_rec.item_location_control_code, l_mmtt_rec.item_location_control_code)
       AND inv_globals.equal(p_mo_line_detail_rec.item_restrict_subinv_code, l_mmtt_rec.item_restrict_subinv_code)
       AND inv_globals.equal(p_mo_line_detail_rec.item_restrict_locators_code, l_mmtt_rec.item_restrict_locators_code)
       AND inv_globals.equal(p_mo_line_detail_rec.item_revision_qty_control_code
          , l_mmtt_rec.item_revision_qty_control_code)
       AND inv_globals.equal(p_mo_line_detail_rec.item_primary_uom_code, l_mmtt_rec.item_primary_uom_code)
       AND inv_globals.equal(p_mo_line_detail_rec.item_uom_class, l_mmtt_rec.item_uom_class)
       AND inv_globals.equal(p_mo_line_detail_rec.item_shelf_life_code, l_mmtt_rec.item_shelf_life_code)
       AND inv_globals.equal(p_mo_line_detail_rec.item_shelf_life_days, l_mmtt_rec.item_shelf_life_days)
       AND inv_globals.equal(p_mo_line_detail_rec.item_lot_control_code, l_mmtt_rec.item_lot_control_code)
       AND inv_globals.equal(p_mo_line_detail_rec.item_serial_control_code, l_mmtt_rec.item_serial_control_code)
       AND inv_globals.equal(p_mo_line_detail_rec.item_inventory_asset_flag, l_mmtt_rec.item_inventory_asset_flag)
       AND inv_globals.equal(p_mo_line_detail_rec.allowed_units_lookup_code, l_mmtt_rec.allowed_units_lookup_code)
       AND inv_globals.equal(p_mo_line_detail_rec.department_id, l_mmtt_rec.department_id)
       AND inv_globals.equal(p_mo_line_detail_rec.department_code, l_mmtt_rec.department_code)
       AND inv_globals.equal(p_mo_line_detail_rec.wip_supply_type, l_mmtt_rec.wip_supply_type)
       AND inv_globals.equal(p_mo_line_detail_rec.supply_subinventory, l_mmtt_rec.supply_subinventory)
       AND inv_globals.equal(p_mo_line_detail_rec.supply_locator_id, l_mmtt_rec.supply_locator_id)
       AND inv_globals.equal(p_mo_line_detail_rec.valid_subinventory_flag, l_mmtt_rec.valid_subinventory_flag)
       AND inv_globals.equal(p_mo_line_detail_rec.locator_segments, l_mmtt_rec.locator_segments)
       AND inv_globals.equal(p_mo_line_detail_rec.current_locator_control_code, l_mmtt_rec.current_locator_control_code)
       AND inv_globals.equal(p_mo_line_detail_rec.number_of_lots_entered, l_mmtt_rec.number_of_lots_entered)
       AND inv_globals.equal(p_mo_line_detail_rec.wip_commit_flag, l_mmtt_rec.wip_commit_flag)
       AND inv_globals.equal(p_mo_line_detail_rec.next_lot_number, l_mmtt_rec.next_lot_number)
       AND inv_globals.equal(p_mo_line_detail_rec.lot_alpha_prefix, l_mmtt_rec.lot_alpha_prefix)
       AND inv_globals.equal(p_mo_line_detail_rec.next_serial_number, l_mmtt_rec.next_serial_number)
       AND inv_globals.equal(p_mo_line_detail_rec.serial_alpha_prefix, l_mmtt_rec.serial_alpha_prefix)
       AND inv_globals.equal(p_mo_line_detail_rec.shippable_flag, l_mmtt_rec.shippable_flag)
       AND inv_globals.equal(p_mo_line_detail_rec.posting_flag, l_mmtt_rec.posting_flag)
       AND inv_globals.equal(p_mo_line_detail_rec.required_flag, l_mmtt_rec.required_flag)
       AND inv_globals.equal(p_mo_line_detail_rec.process_flag, l_mmtt_rec.process_flag)
       AND inv_globals.equal(p_mo_line_detail_rec.ERROR_CODE, l_mmtt_rec.ERROR_CODE)
       AND inv_globals.equal(p_mo_line_detail_rec.error_explanation, l_mmtt_rec.error_explanation)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute_category, l_mmtt_rec.attribute_category)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute1, l_mmtt_rec.attribute1)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute2, l_mmtt_rec.attribute2)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute3, l_mmtt_rec.attribute3)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute4, l_mmtt_rec.attribute4)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute5, l_mmtt_rec.attribute5)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute6, l_mmtt_rec.attribute6)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute7, l_mmtt_rec.attribute7)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute8, l_mmtt_rec.attribute8)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute9, l_mmtt_rec.attribute9)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute10, l_mmtt_rec.attribute10)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute11, l_mmtt_rec.attribute11)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute12, l_mmtt_rec.attribute12)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute13, l_mmtt_rec.attribute13)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute14, l_mmtt_rec.attribute14)
       AND inv_globals.equal(p_mo_line_detail_rec.attribute15, l_mmtt_rec.attribute15)
       AND inv_globals.equal(p_mo_line_detail_rec.movement_id, l_mmtt_rec.movement_id)
       AND inv_globals.equal(p_mo_line_detail_rec.reservation_quantity, l_mmtt_rec.reservation_quantity)
       AND inv_globals.equal(p_mo_line_detail_rec.shipped_quantity, l_mmtt_rec.shipped_quantity)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_line_number, l_mmtt_rec.transaction_line_number)
       AND inv_globals.equal(p_mo_line_detail_rec.task_id, l_mmtt_rec.task_id)
       AND inv_globals.equal(p_mo_line_detail_rec.to_task_id, l_mmtt_rec.to_task_id)
       AND inv_globals.equal(p_mo_line_detail_rec.source_task_id, l_mmtt_rec.source_task_id)
       AND inv_globals.equal(p_mo_line_detail_rec.project_id, l_mmtt_rec.project_id)
       AND inv_globals.equal(p_mo_line_detail_rec.source_project_id, l_mmtt_rec.source_project_id)
       AND inv_globals.equal(p_mo_line_detail_rec.pa_expenditure_org_id, l_mmtt_rec.pa_expenditure_org_id)
       AND inv_globals.equal(p_mo_line_detail_rec.to_project_id, l_mmtt_rec.to_project_id)
       AND inv_globals.equal(p_mo_line_detail_rec.expenditure_type, l_mmtt_rec.expenditure_type)
       AND inv_globals.equal(p_mo_line_detail_rec.final_completion_flag, l_mmtt_rec.final_completion_flag)
       AND inv_globals.equal(p_mo_line_detail_rec.transfer_percentage, l_mmtt_rec.transfer_percentage)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_sequence_id, l_mmtt_rec.transaction_sequence_id)
       AND inv_globals.equal(p_mo_line_detail_rec.material_account, l_mmtt_rec.material_account)
       AND inv_globals.equal(p_mo_line_detail_rec.material_overhead_account, l_mmtt_rec.material_overhead_account)
       AND inv_globals.equal(p_mo_line_detail_rec.resource_account, l_mmtt_rec.resource_account)
       AND inv_globals.equal(p_mo_line_detail_rec.outside_processing_account, l_mmtt_rec.outside_processing_account)
       AND inv_globals.equal(p_mo_line_detail_rec.overhead_account, l_mmtt_rec.overhead_account)
       AND inv_globals.equal(p_mo_line_detail_rec.flow_schedule, l_mmtt_rec.flow_schedule)
       AND inv_globals.equal(p_mo_line_detail_rec.cost_group_id, l_mmtt_rec.cost_group_id)
       AND inv_globals.equal(p_mo_line_detail_rec.demand_class, l_mmtt_rec.demand_class)
       AND inv_globals.equal(p_mo_line_detail_rec.qa_collection_id, l_mmtt_rec.qa_collection_id)
       AND inv_globals.equal(p_mo_line_detail_rec.kanban_card_id, l_mmtt_rec.kanban_card_id)
       AND inv_globals.equal(p_mo_line_detail_rec.overcompletion_transaction_id
          , l_mmtt_rec.overcompletion_transaction_id)
       AND inv_globals.equal(p_mo_line_detail_rec.overcompletion_primary_qty, l_mmtt_rec.overcompletion_primary_qty)
       AND inv_globals.equal(p_mo_line_detail_rec.overcompletion_transaction_qty
          , l_mmtt_rec.overcompletion_transaction_qty)
       AND inv_globals.equal(p_mo_line_detail_rec.end_item_unit_number, l_mmtt_rec.end_item_unit_number)
       AND inv_globals.equal(p_mo_line_detail_rec.scheduled_payback_date, l_mmtt_rec.scheduled_payback_date)
       AND inv_globals.equal(p_mo_line_detail_rec.line_type_code, l_mmtt_rec.line_type_code)
       AND inv_globals.equal(p_mo_line_detail_rec.parent_transaction_temp_id, l_mmtt_rec.parent_transaction_temp_id)
       AND inv_globals.equal(p_mo_line_detail_rec.put_away_strategy_id, l_mmtt_rec.put_away_strategy_id)
       AND inv_globals.equal(p_mo_line_detail_rec.put_away_rule_id, l_mmtt_rec.put_away_rule_id)
       AND inv_globals.equal(p_mo_line_detail_rec.pick_strategy_id, l_mmtt_rec.pick_strategy_id)
       AND inv_globals.equal(p_mo_line_detail_rec.pick_rule_id, l_mmtt_rec.pick_rule_id)
       AND inv_globals.equal(p_mo_line_detail_rec.common_bom_seq_id, l_mmtt_rec.common_bom_seq_id)
       AND inv_globals.equal(p_mo_line_detail_rec.common_routing_seq_id, l_mmtt_rec.common_routing_seq_id)
       AND inv_globals.equal(p_mo_line_detail_rec.cost_type_id, l_mmtt_rec.cost_type_id)
       AND inv_globals.equal(p_mo_line_detail_rec.org_cost_group_id, l_mmtt_rec.org_cost_group_id)
       AND inv_globals.equal(p_mo_line_detail_rec.move_order_line_id, l_mmtt_rec.move_order_line_id)
       AND inv_globals.equal(p_mo_line_detail_rec.task_group_id, l_mmtt_rec.task_group_id)
       AND inv_globals.equal(p_mo_line_detail_rec.pick_slip_number, l_mmtt_rec.pick_slip_number)
       AND inv_globals.equal(p_mo_line_detail_rec.reservation_id, l_mmtt_rec.reservation_id)
       AND inv_globals.equal(p_mo_line_detail_rec.transaction_status, l_mmtt_rec.transaction_status)
       AND inv_globals.equal(p_mo_line_detail_rec.transfer_cost_group_id, l_mmtt_rec.transfer_cost_group_id)
       AND inv_globals.equal(p_mo_line_detail_rec.lpn_id, l_mmtt_rec.lpn_id)
       AND inv_globals.equal(p_mo_line_detail_rec.transfer_lpn_id, l_mmtt_rec.transfer_lpn_id)
       AND inv_globals.equal(p_mo_line_detail_rec.pick_slip_date, l_mmtt_rec.pick_slip_date)
       AND inv_globals.equal(p_mo_line_detail_rec.content_lpn_id, l_mmtt_rec.content_lpn_id) THEN
      --  Row has not changed. Set out parameter.

      x_mo_line_detail_rec  := l_mmtt_rec;
      --  Set return status

      x_return_status       := fnd_api.g_ret_sts_success;
    ELSE
      --  Row has changed by another user.

      x_return_status  := fnd_api.g_ret_sts_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('INV', 'OE_LOCK_ROW_CHANGED');
        fnd_msg_pub.ADD;
      END IF;
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('INV', 'OE_LOCK_ROW_DELETED');
        fnd_msg_pub.ADD;
      END IF;
    WHEN app_exceptions.record_lock_exception THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('INV', 'OE_LOCK_ROW_ALREADY_LOCKED');
        fnd_msg_pub.ADD;
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Lock_Row');
      END IF;
  END lock_row;

  --  Function Query_Row
  FUNCTION query_row(p_line_detail_id IN NUMBER) RETURN g_mmtt_rec IS
  BEGIN
    RETURN query_rows(p_line_detail_id => p_line_detail_id)(1);
  END query_row;

  --  Function Query_Rows
  --
  FUNCTION query_rows(p_line_id IN NUMBER := fnd_api.g_miss_num, p_line_detail_id IN NUMBER := fnd_api.g_miss_num)
    RETURN g_mmtt_tbl_type IS
    l_mmtt_rec g_mmtt_rec;
    l_mmtt_tbl g_mmtt_tbl_type;

    CURSOR l_mmtt_csr IS
      SELECT transaction_header_id
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
           , pick_slip_date
           , content_lpn_id
           , secondary_transaction_quantity   -- INVCONV change
           , secondary_uom_code               -- INVCONV change
        FROM mtl_material_transactions_temp
       WHERE move_order_line_id = p_line_id;

    CURSOR l_mmtt_csr_temp IS
      SELECT transaction_header_id
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
           , pick_slip_date
           , content_lpn_id
           , secondary_transaction_quantity   -- INVCONV change
           , secondary_uom_code               -- INVCONV change
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_line_detail_id;

    l_debug    NUMBER     := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (p_line_id IS NOT NULL AND p_line_id <> fnd_api.g_miss_num)
       AND(p_line_detail_id IS NOT NULL AND p_line_detail_id <> fnd_api.g_miss_num) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(
          g_pkg_name
        , 'Query Rows'
        , 'Keys are mutually exclusive: line_id = ' || p_line_id || ', line_detail_id = ' || p_line_detail_id
        );
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (p_line_id IS NOT NULL AND p_line_id <> fnd_api.g_miss_num) THEN
      FOR l_implicit_rec IN l_mmtt_csr LOOP
        l_mmtt_rec.transaction_header_id           := l_implicit_rec.transaction_header_id;
        l_mmtt_rec.transaction_temp_id             := l_implicit_rec.transaction_temp_id;
        l_mmtt_rec.source_code                     := l_implicit_rec.source_code;
        l_mmtt_rec.source_line_id                  := l_implicit_rec.source_line_id;
        l_mmtt_rec.transaction_mode                := l_implicit_rec.transaction_mode;
        l_mmtt_rec.lock_flag                       := l_implicit_rec.lock_flag;
        l_mmtt_rec.last_update_date                := l_implicit_rec.last_update_date;
        l_mmtt_rec.last_updated_by                 := l_implicit_rec.last_updated_by;
        l_mmtt_rec.creation_date                   := l_implicit_rec.creation_date;
        l_mmtt_rec.created_by                      := l_implicit_rec.created_by;
        l_mmtt_rec.last_update_login               := l_implicit_rec.last_update_login;
        l_mmtt_rec.request_id                      := l_implicit_rec.request_id;
        l_mmtt_rec.program_application_id          := l_implicit_rec.program_application_id;
        l_mmtt_rec.program_id                      := l_implicit_rec.program_id;
        l_mmtt_rec.program_update_date             := l_implicit_rec.program_update_date;
        l_mmtt_rec.inventory_item_id               := l_implicit_rec.inventory_item_id;
        l_mmtt_rec.revision                        := l_implicit_rec.revision;
        l_mmtt_rec.organization_id                 := l_implicit_rec.organization_id;
        l_mmtt_rec.subinventory_code               := l_implicit_rec.subinventory_code;
        l_mmtt_rec.locator_id                      := l_implicit_rec.locator_id;
        l_mmtt_rec.transaction_quantity            := l_implicit_rec.transaction_quantity;
        l_mmtt_rec.primary_quantity                := l_implicit_rec.primary_quantity;
        l_mmtt_rec.transaction_uom                 := l_implicit_rec.transaction_uom;
        l_mmtt_rec.transaction_cost                := l_implicit_rec.transaction_cost;
        l_mmtt_rec.transaction_type_id             := l_implicit_rec.transaction_type_id;
        l_mmtt_rec.transaction_action_id           := l_implicit_rec.transaction_action_id;
        l_mmtt_rec.transaction_source_type_id      := l_implicit_rec.transaction_source_type_id;
        l_mmtt_rec.transaction_source_id           := l_implicit_rec.transaction_source_id;
        l_mmtt_rec.transaction_source_name         := l_implicit_rec.transaction_source_name;
        l_mmtt_rec.transaction_date                := l_implicit_rec.transaction_date;
        l_mmtt_rec.acct_period_id                  := l_implicit_rec.acct_period_id;
        l_mmtt_rec.distribution_account_id         := l_implicit_rec.distribution_account_id;
        l_mmtt_rec.transaction_reference           := l_implicit_rec.transaction_reference;
        l_mmtt_rec.requisition_line_id             := l_implicit_rec.requisition_line_id;
        l_mmtt_rec.requisition_distribution_id     := l_implicit_rec.requisition_distribution_id;
        l_mmtt_rec.reason_id                       := l_implicit_rec.reason_id;
        l_mmtt_rec.lot_number                      := l_implicit_rec.lot_number;
        l_mmtt_rec.lot_expiration_date             := l_implicit_rec.lot_expiration_date;
        l_mmtt_rec.serial_number                   := l_implicit_rec.serial_number;
        l_mmtt_rec.receiving_document              := l_implicit_rec.receiving_document;
        l_mmtt_rec.demand_id                       := l_implicit_rec.demand_id;
        l_mmtt_rec.rcv_transaction_id              := l_implicit_rec.rcv_transaction_id;
        l_mmtt_rec.move_transaction_id             := l_implicit_rec.move_transaction_id;
        l_mmtt_rec.completion_transaction_id       := l_implicit_rec.completion_transaction_id;
        l_mmtt_rec.wip_entity_type                 := l_implicit_rec.wip_entity_type;
        l_mmtt_rec.schedule_id                     := l_implicit_rec.schedule_id;
        l_mmtt_rec.repetitive_line_id              := l_implicit_rec.repetitive_line_id;
        l_mmtt_rec.employee_code                   := l_implicit_rec.employee_code;
        l_mmtt_rec.primary_switch                  := l_implicit_rec.primary_switch;
        l_mmtt_rec.schedule_update_code            := l_implicit_rec.schedule_update_code;
        l_mmtt_rec.setup_teardown_code             := l_implicit_rec.setup_teardown_code;
        l_mmtt_rec.item_ordering                   := l_implicit_rec.item_ordering;
        l_mmtt_rec.negative_req_flag               := l_implicit_rec.negative_req_flag;
        l_mmtt_rec.operation_seq_num               := l_implicit_rec.operation_seq_num;
        l_mmtt_rec.picking_line_id                 := l_implicit_rec.picking_line_id;
        l_mmtt_rec.trx_source_line_id              := l_implicit_rec.trx_source_line_id;
        l_mmtt_rec.trx_source_delivery_id          := l_implicit_rec.trx_source_delivery_id;
        l_mmtt_rec.physical_adjustment_id          := l_implicit_rec.physical_adjustment_id;
        l_mmtt_rec.cycle_count_id                  := l_implicit_rec.cycle_count_id;
        l_mmtt_rec.rma_line_id                     := l_implicit_rec.rma_line_id;
        l_mmtt_rec.customer_ship_id                := l_implicit_rec.customer_ship_id;
        l_mmtt_rec.currency_code                   := l_implicit_rec.currency_code;
        l_mmtt_rec.currency_conversion_rate        := l_implicit_rec.currency_conversion_rate;
        l_mmtt_rec.currency_conversion_type        := l_implicit_rec.currency_conversion_type;
        l_mmtt_rec.currency_conversion_date        := l_implicit_rec.currency_conversion_date;
        l_mmtt_rec.ussgl_transaction_code          := l_implicit_rec.ussgl_transaction_code;
        l_mmtt_rec.vendor_lot_number               := l_implicit_rec.vendor_lot_number;
        l_mmtt_rec.encumbrance_account             := l_implicit_rec.encumbrance_account;
        l_mmtt_rec.encumbrance_amount              := l_implicit_rec.encumbrance_amount;
        l_mmtt_rec.ship_to_location                := l_implicit_rec.ship_to_location;
        l_mmtt_rec.shipment_number                 := l_implicit_rec.shipment_number;
        l_mmtt_rec.transfer_cost                   := l_implicit_rec.transfer_cost;
        l_mmtt_rec.transportation_cost             := l_implicit_rec.transportation_cost;
        l_mmtt_rec.transportation_account          := l_implicit_rec.transportation_account;
        l_mmtt_rec.freight_code                    := l_implicit_rec.freight_code;
        l_mmtt_rec.containers                      := l_implicit_rec.containers;
        l_mmtt_rec.waybill_airbill                 := l_implicit_rec.waybill_airbill;
        l_mmtt_rec.expected_arrival_date           := l_implicit_rec.expected_arrival_date;
        l_mmtt_rec.transfer_subinventory           := l_implicit_rec.transfer_subinventory;
        l_mmtt_rec.transfer_organization           := l_implicit_rec.transfer_organization;
        l_mmtt_rec.transfer_to_location            := l_implicit_rec.transfer_to_location;
        l_mmtt_rec.new_average_cost                := l_implicit_rec.new_average_cost;
        l_mmtt_rec.value_change                    := l_implicit_rec.value_change;
        l_mmtt_rec.percentage_change               := l_implicit_rec.percentage_change;
        l_mmtt_rec.material_allocation_temp_id     := l_implicit_rec.material_allocation_temp_id;
        l_mmtt_rec.demand_source_header_id         := l_implicit_rec.demand_source_header_id;
        l_mmtt_rec.demand_source_line              := l_implicit_rec.demand_source_line;
        l_mmtt_rec.demand_source_delivery          := l_implicit_rec.demand_source_delivery;
        l_mmtt_rec.item_segments                   := l_implicit_rec.item_segments;
        l_mmtt_rec.item_description                := l_implicit_rec.item_description;
        l_mmtt_rec.item_trx_enabled_flag           := l_implicit_rec.item_trx_enabled_flag;
        l_mmtt_rec.item_location_control_code      := l_implicit_rec.item_location_control_code;
        l_mmtt_rec.item_restrict_subinv_code       := l_implicit_rec.item_restrict_subinv_code;
        l_mmtt_rec.item_restrict_locators_code     := l_implicit_rec.item_restrict_locators_code;
        l_mmtt_rec.item_revision_qty_control_code  := l_implicit_rec.item_revision_qty_control_code;
        l_mmtt_rec.item_primary_uom_code           := l_implicit_rec.item_primary_uom_code;
        l_mmtt_rec.item_uom_class                  := l_implicit_rec.item_uom_class;
        l_mmtt_rec.item_shelf_life_code            := l_implicit_rec.item_shelf_life_code;
        l_mmtt_rec.item_shelf_life_days            := l_implicit_rec.item_shelf_life_days;
        l_mmtt_rec.item_lot_control_code           := l_implicit_rec.item_lot_control_code;
        l_mmtt_rec.item_serial_control_code        := l_implicit_rec.item_serial_control_code;
        l_mmtt_rec.item_inventory_asset_flag       := l_implicit_rec.item_inventory_asset_flag;
        l_mmtt_rec.allowed_units_lookup_code       := l_implicit_rec.allowed_units_lookup_code;
        l_mmtt_rec.department_id                   := l_implicit_rec.department_id;
        l_mmtt_rec.department_code                 := l_implicit_rec.department_code;
        l_mmtt_rec.wip_supply_type                 := l_implicit_rec.wip_supply_type;
        l_mmtt_rec.supply_subinventory             := l_implicit_rec.supply_subinventory;
        l_mmtt_rec.supply_locator_id               := l_implicit_rec.supply_locator_id;
        l_mmtt_rec.valid_subinventory_flag         := l_implicit_rec.valid_subinventory_flag;
        l_mmtt_rec.valid_locator_flag              := l_implicit_rec.valid_locator_flag;
        l_mmtt_rec.locator_segments                := l_implicit_rec.locator_segments;
        l_mmtt_rec.current_locator_control_code    := l_implicit_rec.current_locator_control_code;
        l_mmtt_rec.number_of_lots_entered          := l_implicit_rec.number_of_lots_entered;
        l_mmtt_rec.wip_commit_flag                 := l_implicit_rec.wip_commit_flag;
        l_mmtt_rec.next_lot_number                 := l_implicit_rec.next_lot_number;
        l_mmtt_rec.lot_alpha_prefix                := l_implicit_rec.lot_alpha_prefix;
        l_mmtt_rec.next_serial_number              := l_implicit_rec.next_serial_number;
        l_mmtt_rec.serial_alpha_prefix             := l_implicit_rec.serial_alpha_prefix;
        l_mmtt_rec.shippable_flag                  := l_implicit_rec.shippable_flag;
        l_mmtt_rec.posting_flag                    := l_implicit_rec.posting_flag;
        l_mmtt_rec.required_flag                   := l_implicit_rec.required_flag;
        l_mmtt_rec.process_flag                    := l_implicit_rec.process_flag;
        l_mmtt_rec.ERROR_CODE                      := l_implicit_rec.ERROR_CODE;
        l_mmtt_rec.error_explanation               := l_implicit_rec.error_explanation;
        l_mmtt_rec.attribute_category              := l_implicit_rec.attribute_category;
        l_mmtt_rec.attribute1                      := l_implicit_rec.attribute1;
        l_mmtt_rec.attribute2                      := l_implicit_rec.attribute2;
        l_mmtt_rec.attribute3                      := l_implicit_rec.attribute3;
        l_mmtt_rec.attribute4                      := l_implicit_rec.attribute4;
        l_mmtt_rec.attribute5                      := l_implicit_rec.attribute5;
        l_mmtt_rec.attribute6                      := l_implicit_rec.attribute6;
        l_mmtt_rec.attribute7                      := l_implicit_rec.attribute7;
        l_mmtt_rec.attribute8                      := l_implicit_rec.attribute8;
        l_mmtt_rec.attribute9                      := l_implicit_rec.attribute9;
        l_mmtt_rec.attribute10                     := l_implicit_rec.attribute10;
        l_mmtt_rec.attribute11                     := l_implicit_rec.attribute11;
        l_mmtt_rec.attribute12                     := l_implicit_rec.attribute12;
        l_mmtt_rec.attribute13                     := l_implicit_rec.attribute13;
        l_mmtt_rec.attribute14                     := l_implicit_rec.attribute14;
        l_mmtt_rec.attribute15                     := l_implicit_rec.attribute15;
        l_mmtt_rec.movement_id                     := l_implicit_rec.movement_id;
        l_mmtt_rec.reservation_quantity            := l_implicit_rec.reservation_quantity;
        l_mmtt_rec.shipped_quantity                := l_implicit_rec.shipped_quantity;
        l_mmtt_rec.transaction_line_number         := l_implicit_rec.transaction_line_number;
        l_mmtt_rec.task_id                         := l_implicit_rec.task_id;
        l_mmtt_rec.to_task_id                      := l_implicit_rec.to_task_id;
        l_mmtt_rec.source_task_id                  := l_implicit_rec.source_task_id;
        l_mmtt_rec.project_id                      := l_implicit_rec.project_id;
        l_mmtt_rec.source_project_id               := l_implicit_rec.source_project_id;
        l_mmtt_rec.pa_expenditure_org_id           := l_implicit_rec.pa_expenditure_org_id;
        l_mmtt_rec.to_project_id                   := l_implicit_rec.to_project_id;
        l_mmtt_rec.expenditure_type                := l_implicit_rec.expenditure_type;
        l_mmtt_rec.final_completion_flag           := l_implicit_rec.final_completion_flag;
        l_mmtt_rec.transfer_percentage             := l_implicit_rec.transfer_percentage;
        l_mmtt_rec.transaction_sequence_id         := l_implicit_rec.transaction_sequence_id;
        l_mmtt_rec.material_account                := l_implicit_rec.material_account;
        l_mmtt_rec.material_overhead_account       := l_implicit_rec.material_overhead_account;
        l_mmtt_rec.resource_account                := l_implicit_rec.resource_account;
        l_mmtt_rec.outside_processing_account      := l_implicit_rec.outside_processing_account;
        l_mmtt_rec.overhead_account                := l_implicit_rec.overhead_account;
        l_mmtt_rec.flow_schedule                   := l_implicit_rec.flow_schedule;
        l_mmtt_rec.cost_group_id                   := l_implicit_rec.cost_group_id;
        l_mmtt_rec.demand_class                    := l_implicit_rec.demand_class;
        l_mmtt_rec.qa_collection_id                := l_implicit_rec.qa_collection_id;
        l_mmtt_rec.kanban_card_id                  := l_implicit_rec.kanban_card_id;
        l_mmtt_rec.overcompletion_transaction_id   := l_implicit_rec.overcompletion_transaction_id;
        l_mmtt_rec.overcompletion_primary_qty      := l_implicit_rec.overcompletion_primary_qty;
        l_mmtt_rec.overcompletion_transaction_qty  := l_implicit_rec.overcompletion_transaction_qty;
        l_mmtt_rec.end_item_unit_number            := l_implicit_rec.end_item_unit_number;
        l_mmtt_rec.scheduled_payback_date          := l_implicit_rec.scheduled_payback_date;
        l_mmtt_rec.line_type_code                  := l_implicit_rec.line_type_code;
        l_mmtt_rec.parent_transaction_temp_id      := l_implicit_rec.parent_transaction_temp_id;
        l_mmtt_rec.put_away_strategy_id            := l_implicit_rec.put_away_strategy_id;
        l_mmtt_rec.put_away_rule_id                := l_implicit_rec.put_away_rule_id;
        l_mmtt_rec.pick_strategy_id                := l_implicit_rec.pick_strategy_id;
        l_mmtt_rec.pick_rule_id                    := l_implicit_rec.pick_rule_id;
        l_mmtt_rec.common_bom_seq_id               := l_implicit_rec.common_bom_seq_id;
        l_mmtt_rec.common_routing_seq_id           := l_implicit_rec.common_routing_seq_id;
        l_mmtt_rec.cost_type_id                    := l_implicit_rec.cost_type_id;
        l_mmtt_rec.org_cost_group_id               := l_implicit_rec.org_cost_group_id;
        l_mmtt_rec.move_order_line_id              := l_implicit_rec.move_order_line_id;
        l_mmtt_rec.task_group_id                   := l_implicit_rec.task_group_id;
        l_mmtt_rec.pick_slip_number                := l_implicit_rec.pick_slip_number;
        l_mmtt_rec.reservation_id                  := l_implicit_rec.reservation_id;
        l_mmtt_rec.transaction_status              := l_implicit_rec.transaction_status;
        l_mmtt_rec.transfer_cost_group_id          := l_implicit_rec.transfer_cost_group_id;
        l_mmtt_rec.lpn_id                          := l_implicit_rec.lpn_id;
        l_mmtt_rec.transfer_lpn_id                 := l_implicit_rec.transfer_lpn_id;
        l_mmtt_rec.pick_slip_date                  := l_implicit_rec.pick_slip_date;
        l_mmtt_rec.content_lpn_id                  := l_implicit_rec.content_lpn_id;
        l_mmtt_rec.secondary_transaction_quantity  := l_implicit_rec.secondary_transaction_quantity;   -- INVCONV change
        l_mmtt_rec.secondary_uom_code              := l_implicit_rec.secondary_uom_code;               -- INVCONV change
        l_mmtt_tbl(l_mmtt_tbl.COUNT + 1)           := l_mmtt_rec;
      END LOOP;
    ELSE
      FOR l_implicit_rec IN l_mmtt_csr_temp LOOP
        l_mmtt_rec.transaction_header_id           := l_implicit_rec.transaction_header_id;
        l_mmtt_rec.transaction_temp_id             := l_implicit_rec.transaction_temp_id;
        l_mmtt_rec.source_code                     := l_implicit_rec.source_code;
        l_mmtt_rec.source_line_id                  := l_implicit_rec.source_line_id;
        l_mmtt_rec.transaction_mode                := l_implicit_rec.transaction_mode;
        l_mmtt_rec.lock_flag                       := l_implicit_rec.lock_flag;
        l_mmtt_rec.last_update_date                := l_implicit_rec.last_update_date;
        l_mmtt_rec.last_updated_by                 := l_implicit_rec.last_updated_by;
        l_mmtt_rec.creation_date                   := l_implicit_rec.creation_date;
        l_mmtt_rec.created_by                      := l_implicit_rec.created_by;
        l_mmtt_rec.last_update_login               := l_implicit_rec.last_update_login;
        l_mmtt_rec.request_id                      := l_implicit_rec.request_id;
        l_mmtt_rec.program_application_id          := l_implicit_rec.program_application_id;
        l_mmtt_rec.program_id                      := l_implicit_rec.program_id;
        l_mmtt_rec.program_update_date             := l_implicit_rec.program_update_date;
        l_mmtt_rec.inventory_item_id               := l_implicit_rec.inventory_item_id;
        l_mmtt_rec.revision                        := l_implicit_rec.revision;
        l_mmtt_rec.organization_id                 := l_implicit_rec.organization_id;
        l_mmtt_rec.subinventory_code               := l_implicit_rec.subinventory_code;
        l_mmtt_rec.locator_id                      := l_implicit_rec.locator_id;
        l_mmtt_rec.transaction_quantity            := l_implicit_rec.transaction_quantity;
        l_mmtt_rec.primary_quantity                := l_implicit_rec.primary_quantity;
        l_mmtt_rec.transaction_uom                 := l_implicit_rec.transaction_uom;
        l_mmtt_rec.transaction_cost                := l_implicit_rec.transaction_cost;
        l_mmtt_rec.transaction_type_id             := l_implicit_rec.transaction_type_id;
        l_mmtt_rec.transaction_action_id           := l_implicit_rec.transaction_action_id;
        l_mmtt_rec.transaction_source_type_id      := l_implicit_rec.transaction_source_type_id;
        l_mmtt_rec.transaction_source_id           := l_implicit_rec.transaction_source_id;
        l_mmtt_rec.transaction_source_name         := l_implicit_rec.transaction_source_name;
        l_mmtt_rec.transaction_date                := l_implicit_rec.transaction_date;
        l_mmtt_rec.acct_period_id                  := l_implicit_rec.acct_period_id;
        l_mmtt_rec.distribution_account_id         := l_implicit_rec.distribution_account_id;
        l_mmtt_rec.transaction_reference           := l_implicit_rec.transaction_reference;
        l_mmtt_rec.requisition_line_id             := l_implicit_rec.requisition_line_id;
        l_mmtt_rec.requisition_distribution_id     := l_implicit_rec.requisition_distribution_id;
        l_mmtt_rec.reason_id                       := l_implicit_rec.reason_id;
        l_mmtt_rec.lot_number                      := l_implicit_rec.lot_number;
        l_mmtt_rec.lot_expiration_date             := l_implicit_rec.lot_expiration_date;
        l_mmtt_rec.serial_number                   := l_implicit_rec.serial_number;
        l_mmtt_rec.receiving_document              := l_implicit_rec.receiving_document;
        l_mmtt_rec.demand_id                       := l_implicit_rec.demand_id;
        l_mmtt_rec.rcv_transaction_id              := l_implicit_rec.rcv_transaction_id;
        l_mmtt_rec.move_transaction_id             := l_implicit_rec.move_transaction_id;
        l_mmtt_rec.completion_transaction_id       := l_implicit_rec.completion_transaction_id;
        l_mmtt_rec.wip_entity_type                 := l_implicit_rec.wip_entity_type;
        l_mmtt_rec.schedule_id                     := l_implicit_rec.schedule_id;
        l_mmtt_rec.repetitive_line_id              := l_implicit_rec.repetitive_line_id;
        l_mmtt_rec.employee_code                   := l_implicit_rec.employee_code;
        l_mmtt_rec.primary_switch                  := l_implicit_rec.primary_switch;
        l_mmtt_rec.schedule_update_code            := l_implicit_rec.schedule_update_code;
        l_mmtt_rec.setup_teardown_code             := l_implicit_rec.setup_teardown_code;
        l_mmtt_rec.item_ordering                   := l_implicit_rec.item_ordering;
        l_mmtt_rec.negative_req_flag               := l_implicit_rec.negative_req_flag;
        l_mmtt_rec.operation_seq_num               := l_implicit_rec.operation_seq_num;
        l_mmtt_rec.picking_line_id                 := l_implicit_rec.picking_line_id;
        l_mmtt_rec.trx_source_line_id              := l_implicit_rec.trx_source_line_id;
        l_mmtt_rec.trx_source_delivery_id          := l_implicit_rec.trx_source_delivery_id;
        l_mmtt_rec.physical_adjustment_id          := l_implicit_rec.physical_adjustment_id;
        l_mmtt_rec.cycle_count_id                  := l_implicit_rec.cycle_count_id;
        l_mmtt_rec.rma_line_id                     := l_implicit_rec.rma_line_id;
        l_mmtt_rec.customer_ship_id                := l_implicit_rec.customer_ship_id;
        l_mmtt_rec.currency_code                   := l_implicit_rec.currency_code;
        l_mmtt_rec.currency_conversion_rate        := l_implicit_rec.currency_conversion_rate;
        l_mmtt_rec.currency_conversion_type        := l_implicit_rec.currency_conversion_type;
        l_mmtt_rec.currency_conversion_date        := l_implicit_rec.currency_conversion_date;
        l_mmtt_rec.ussgl_transaction_code          := l_implicit_rec.ussgl_transaction_code;
        l_mmtt_rec.vendor_lot_number               := l_implicit_rec.vendor_lot_number;
        l_mmtt_rec.encumbrance_account             := l_implicit_rec.encumbrance_account;
        l_mmtt_rec.encumbrance_amount              := l_implicit_rec.encumbrance_amount;
        l_mmtt_rec.ship_to_location                := l_implicit_rec.ship_to_location;
        l_mmtt_rec.shipment_number                 := l_implicit_rec.shipment_number;
        l_mmtt_rec.transfer_cost                   := l_implicit_rec.transfer_cost;
        l_mmtt_rec.transportation_cost             := l_implicit_rec.transportation_cost;
        l_mmtt_rec.transportation_account          := l_implicit_rec.transportation_account;
        l_mmtt_rec.freight_code                    := l_implicit_rec.freight_code;
        l_mmtt_rec.containers                      := l_implicit_rec.containers;
        l_mmtt_rec.waybill_airbill                 := l_implicit_rec.waybill_airbill;
        l_mmtt_rec.expected_arrival_date           := l_implicit_rec.expected_arrival_date;
        l_mmtt_rec.transfer_subinventory           := l_implicit_rec.transfer_subinventory;
        l_mmtt_rec.transfer_organization           := l_implicit_rec.transfer_organization;
        l_mmtt_rec.transfer_to_location            := l_implicit_rec.transfer_to_location;
        l_mmtt_rec.new_average_cost                := l_implicit_rec.new_average_cost;
        l_mmtt_rec.value_change                    := l_implicit_rec.value_change;
        l_mmtt_rec.percentage_change               := l_implicit_rec.percentage_change;
        l_mmtt_rec.material_allocation_temp_id     := l_implicit_rec.material_allocation_temp_id;
        l_mmtt_rec.demand_source_header_id         := l_implicit_rec.demand_source_header_id;
        l_mmtt_rec.demand_source_line              := l_implicit_rec.demand_source_line;
        l_mmtt_rec.demand_source_delivery          := l_implicit_rec.demand_source_delivery;
        l_mmtt_rec.item_segments                   := l_implicit_rec.item_segments;
        l_mmtt_rec.item_description                := l_implicit_rec.item_description;
        l_mmtt_rec.item_trx_enabled_flag           := l_implicit_rec.item_trx_enabled_flag;
        l_mmtt_rec.item_location_control_code      := l_implicit_rec.item_location_control_code;
        l_mmtt_rec.item_restrict_subinv_code       := l_implicit_rec.item_restrict_subinv_code;
        l_mmtt_rec.item_restrict_locators_code     := l_implicit_rec.item_restrict_locators_code;
        l_mmtt_rec.item_revision_qty_control_code  := l_implicit_rec.item_revision_qty_control_code;
        l_mmtt_rec.item_primary_uom_code           := l_implicit_rec.item_primary_uom_code;
        l_mmtt_rec.item_uom_class                  := l_implicit_rec.item_uom_class;
        l_mmtt_rec.item_shelf_life_code            := l_implicit_rec.item_shelf_life_code;
        l_mmtt_rec.item_shelf_life_days            := l_implicit_rec.item_shelf_life_days;
        l_mmtt_rec.item_lot_control_code           := l_implicit_rec.item_lot_control_code;
        l_mmtt_rec.item_serial_control_code        := l_implicit_rec.item_serial_control_code;
        l_mmtt_rec.item_inventory_asset_flag       := l_implicit_rec.item_inventory_asset_flag;
        l_mmtt_rec.allowed_units_lookup_code       := l_implicit_rec.allowed_units_lookup_code;
        l_mmtt_rec.department_id                   := l_implicit_rec.department_id;
        l_mmtt_rec.department_code                 := l_implicit_rec.department_code;
        l_mmtt_rec.wip_supply_type                 := l_implicit_rec.wip_supply_type;
        l_mmtt_rec.supply_subinventory             := l_implicit_rec.supply_subinventory;
        l_mmtt_rec.supply_locator_id               := l_implicit_rec.supply_locator_id;
        l_mmtt_rec.valid_subinventory_flag         := l_implicit_rec.valid_subinventory_flag;
        l_mmtt_rec.valid_locator_flag              := l_implicit_rec.valid_locator_flag;
        l_mmtt_rec.locator_segments                := l_implicit_rec.locator_segments;
        l_mmtt_rec.current_locator_control_code    := l_implicit_rec.current_locator_control_code;
        l_mmtt_rec.number_of_lots_entered          := l_implicit_rec.number_of_lots_entered;
        l_mmtt_rec.wip_commit_flag                 := l_implicit_rec.wip_commit_flag;
        l_mmtt_rec.next_lot_number                 := l_implicit_rec.next_lot_number;
        l_mmtt_rec.lot_alpha_prefix                := l_implicit_rec.lot_alpha_prefix;
        l_mmtt_rec.next_serial_number              := l_implicit_rec.next_serial_number;
        l_mmtt_rec.serial_alpha_prefix             := l_implicit_rec.serial_alpha_prefix;
        l_mmtt_rec.shippable_flag                  := l_implicit_rec.shippable_flag;
        l_mmtt_rec.posting_flag                    := l_implicit_rec.posting_flag;
        l_mmtt_rec.required_flag                   := l_implicit_rec.required_flag;
        l_mmtt_rec.process_flag                    := l_implicit_rec.process_flag;
        l_mmtt_rec.ERROR_CODE                      := l_implicit_rec.ERROR_CODE;
        l_mmtt_rec.error_explanation               := l_implicit_rec.error_explanation;
        l_mmtt_rec.attribute_category              := l_implicit_rec.attribute_category;
        l_mmtt_rec.attribute1                      := l_implicit_rec.attribute1;
        l_mmtt_rec.attribute2                      := l_implicit_rec.attribute2;
        l_mmtt_rec.attribute3                      := l_implicit_rec.attribute3;
        l_mmtt_rec.attribute4                      := l_implicit_rec.attribute4;
        l_mmtt_rec.attribute5                      := l_implicit_rec.attribute5;
        l_mmtt_rec.attribute6                      := l_implicit_rec.attribute6;
        l_mmtt_rec.attribute7                      := l_implicit_rec.attribute7;
        l_mmtt_rec.attribute8                      := l_implicit_rec.attribute8;
        l_mmtt_rec.attribute9                      := l_implicit_rec.attribute9;
        l_mmtt_rec.attribute10                     := l_implicit_rec.attribute10;
        l_mmtt_rec.attribute11                     := l_implicit_rec.attribute11;
        l_mmtt_rec.attribute12                     := l_implicit_rec.attribute12;
        l_mmtt_rec.attribute13                     := l_implicit_rec.attribute13;
        l_mmtt_rec.attribute14                     := l_implicit_rec.attribute14;
        l_mmtt_rec.attribute15                     := l_implicit_rec.attribute15;
        l_mmtt_rec.movement_id                     := l_implicit_rec.movement_id;
        l_mmtt_rec.reservation_quantity            := l_implicit_rec.reservation_quantity;
        l_mmtt_rec.shipped_quantity                := l_implicit_rec.shipped_quantity;
        l_mmtt_rec.transaction_line_number         := l_implicit_rec.transaction_line_number;
        l_mmtt_rec.task_id                         := l_implicit_rec.task_id;
        l_mmtt_rec.to_task_id                      := l_implicit_rec.to_task_id;
        l_mmtt_rec.source_task_id                  := l_implicit_rec.source_task_id;
        l_mmtt_rec.project_id                      := l_implicit_rec.project_id;
        l_mmtt_rec.source_project_id               := l_implicit_rec.source_project_id;
        l_mmtt_rec.pa_expenditure_org_id           := l_implicit_rec.pa_expenditure_org_id;
        l_mmtt_rec.to_project_id                   := l_implicit_rec.to_project_id;
        l_mmtt_rec.expenditure_type                := l_implicit_rec.expenditure_type;
        l_mmtt_rec.final_completion_flag           := l_implicit_rec.final_completion_flag;
        l_mmtt_rec.transfer_percentage             := l_implicit_rec.transfer_percentage;
        l_mmtt_rec.transaction_sequence_id         := l_implicit_rec.transaction_sequence_id;
        l_mmtt_rec.material_account                := l_implicit_rec.material_account;
        l_mmtt_rec.material_overhead_account       := l_implicit_rec.material_overhead_account;
        l_mmtt_rec.resource_account                := l_implicit_rec.resource_account;
        l_mmtt_rec.outside_processing_account      := l_implicit_rec.outside_processing_account;
        l_mmtt_rec.overhead_account                := l_implicit_rec.overhead_account;
        l_mmtt_rec.flow_schedule                   := l_implicit_rec.flow_schedule;
        l_mmtt_rec.cost_group_id                   := l_implicit_rec.cost_group_id;
        l_mmtt_rec.demand_class                    := l_implicit_rec.demand_class;
        l_mmtt_rec.qa_collection_id                := l_implicit_rec.qa_collection_id;
        l_mmtt_rec.kanban_card_id                  := l_implicit_rec.kanban_card_id;
        l_mmtt_rec.overcompletion_transaction_id   := l_implicit_rec.overcompletion_transaction_id;
        l_mmtt_rec.overcompletion_primary_qty      := l_implicit_rec.overcompletion_primary_qty;
        l_mmtt_rec.overcompletion_transaction_qty  := l_implicit_rec.overcompletion_transaction_qty;
        l_mmtt_rec.end_item_unit_number            := l_implicit_rec.end_item_unit_number;
        l_mmtt_rec.scheduled_payback_date          := l_implicit_rec.scheduled_payback_date;
        l_mmtt_rec.line_type_code                  := l_implicit_rec.line_type_code;
        l_mmtt_rec.parent_transaction_temp_id      := l_implicit_rec.parent_transaction_temp_id;
        l_mmtt_rec.put_away_strategy_id            := l_implicit_rec.put_away_strategy_id;
        l_mmtt_rec.put_away_rule_id                := l_implicit_rec.put_away_rule_id;
        l_mmtt_rec.pick_strategy_id                := l_implicit_rec.pick_strategy_id;
        l_mmtt_rec.pick_rule_id                    := l_implicit_rec.pick_rule_id;
        l_mmtt_rec.common_bom_seq_id               := l_implicit_rec.common_bom_seq_id;
        l_mmtt_rec.common_routing_seq_id           := l_implicit_rec.common_routing_seq_id;
        l_mmtt_rec.cost_type_id                    := l_implicit_rec.cost_type_id;
        l_mmtt_rec.org_cost_group_id               := l_implicit_rec.org_cost_group_id;
        l_mmtt_rec.move_order_line_id              := l_implicit_rec.move_order_line_id;
        l_mmtt_rec.task_group_id                   := l_implicit_rec.task_group_id;
        l_mmtt_rec.pick_slip_number                := l_implicit_rec.pick_slip_number;
        l_mmtt_rec.reservation_id                  := l_implicit_rec.reservation_id;
        l_mmtt_rec.transaction_status              := l_implicit_rec.transaction_status;
        l_mmtt_rec.transfer_cost_group_id          := l_implicit_rec.transfer_cost_group_id;
        l_mmtt_rec.lpn_id                          := l_implicit_rec.lpn_id;
        l_mmtt_rec.transfer_lpn_id                 := l_implicit_rec.transfer_lpn_id;
        l_mmtt_rec.pick_slip_date                  := l_implicit_rec.pick_slip_date;
        l_mmtt_rec.content_lpn_id                  := l_implicit_rec.content_lpn_id;
        l_mmtt_rec.secondary_transaction_quantity  := l_implicit_rec.secondary_transaction_quantity;    -- INVCONV change
        l_mmtt_rec.secondary_uom_code              := l_implicit_rec.secondary_uom_code;                -- INVCONV change
        l_mmtt_tbl(l_mmtt_tbl.COUNT + 1)           := l_mmtt_rec;
      END LOOP;
    END IF;

    IF (p_line_detail_id IS NOT NULL AND p_line_detail_id <> fnd_api.g_miss_num)
       AND(l_mmtt_tbl.COUNT = 0) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    --  Return fetched table

    RETURN l_mmtt_tbl;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Query_Rows');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END query_rows;

  -- This API currently works only for no control and lot controlled items
  PROCEDURE update_quantity_allocations(
    p_move_order_line_id IN         NUMBER
  , p_mold_table         IN         inv_mo_line_detail_util.g_update_qty_tbl_type
  , x_mold_table         OUT NOCOPY inv_mo_line_detail_util.g_mmtt_tbl_type
  , x_return_status      OUT NOCOPY VARCHAR2
  , x_msg_count          OUT NOCOPY NUMBER
  , x_msg_data           OUT NOCOPY VARCHAR2
  ) IS
    i                           NUMBER := NULL;
    l_transaction_temp_id       NUMBER;
    l_primary_quantity          NUMBER;
    l_mmtt_primary_quantity     NUMBER;
    l_mmtt_transaction_quantity NUMBER;
    l_mtlt_primary_quantity     NUMBER;
    l_mtlt_transaction_quantity NUMBER;
    l_mtlt_sec_transaction_qty  NUMBER; --INVCONV
    l_mmtt_sec_transaction_qty  NUMBER; --INVCONV
    l_lot_control_code          NUMBER;
    l_serial_control_code       NUMBER;
    l_primary_uom_code          mtl_system_items.primary_uom_code%TYPE;
    l_secondary_uom_code        mtl_system_items.secondary_uom_code%TYPE;     --INVCONV
    l_mmtt_rowid                ROWID;
    l_mtlt_rowid                ROWID;

    TYPE mmtt_rec IS RECORD(
      row_id                      ROWID
    , transaction_quantity        NUMBER
    , picked_transaction_quantity NUMBER
    , sec_transaction_qty         NUMBER  --INVCONV
    , picked_sec_transaction_qty  NUMBER  --INVCONV
    , picked_primary_quantity     NUMBER
    );

    -- Will be indexed by the transaction_temp_id
    TYPE mmtt_table_type IS TABLE OF mmtt_rec
      INDEX BY BINARY_INTEGER;

    l_mmtt_table                mmtt_table_type;

    TYPE mtlt_table_type IS TABLE OF ROWID
      INDEX BY BINARY_INTEGER;

    l_mtlt_table                mtlt_table_type;
    l_mtlt_table_counter        NUMBER                                   := 1;
    tab_index                   INTEGER;
    l_sql_p                     INTEGER                                  := NULL;
    l_rows_processed            INTEGER                                  := NULL;
    l_del_mtlt                  LONG
      :=    'DELETE  mtl_transaction_lots_temp '
         || 'WHERE transaction_temp_id in '
         || '(select transaction_temp_id '
         || ' from mtl_material_transactions_temp '
         || ' where move_order_line_id = :b_move_order_line_id) ';
    l_del_mmtt                  LONG
                     := 'DELETE mtl_material_transactions_temp ' || ' where move_order_line_id = :b_move_order_line_id ';
    l_current_table             VARCHAR2(30);
    l_debug                     NUMBER                                   := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    SAVEPOINT update_qty;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF p_move_order_line_id IS NULL THEN
      fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    i                := p_mold_table.FIRST;

    IF i IS NULL THEN
      fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    WHILE i IS NOT NULL LOOP
      IF p_mold_table(i).organization_id IS NULL
         OR p_mold_table(i).organization_id = fnd_api.g_miss_num THEN
        fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_mold_table(i).subinventory_code IS NULL
         OR p_mold_table(i).subinventory_code = fnd_api.g_miss_char THEN
        fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_mold_table(i).locator_id = fnd_api.g_miss_num THEN
        fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_mold_table(i).inventory_item_id IS NULL
         OR p_mold_table(i).locator_id = fnd_api.g_miss_num THEN
        fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_mold_table(i).revision = fnd_api.g_miss_char THEN
        fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_mold_table(i).lot_number = fnd_api.g_miss_char THEN
        fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_mold_table(i).serial_number = fnd_api.g_miss_char THEN
        fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_mold_table(i).transaction_uom = fnd_api.g_miss_char THEN
        fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_mold_table(i).transaction_quantity IS NULL
         OR p_mold_table(i).transaction_quantity = 0
         OR p_mold_table(i).locator_id = fnd_api.g_miss_num THEN
        fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      BEGIN
        SELECT primary_uom_code
             , lot_control_code
             , serial_number_control_code
             , secondary_uom_code
          INTO l_primary_uom_code
             , l_lot_control_code
             , l_serial_control_code
             , l_secondary_uom_code
          FROM mtl_system_items
         WHERE inventory_item_id = p_mold_table(i).inventory_item_id
           AND organization_id = p_mold_table(i).organization_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INV-NO ITEM RECORD');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        WHEN OTHERS THEN
          RAISE;
      END;

      -- API does not handle serial controlled items
      IF l_serial_control_code IN(2, 5) THEN
        fnd_message.set_name('INV', 'INV_FIELD_INVALID');
        fnd_message.set_token('ENTITY1', 'SERIAL_CONTROL', TRUE);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      -- Get the primary quantity
      l_primary_quantity  :=
        inv_convert.inv_um_convert(
          p_mold_table(i).inventory_item_id
        , 5
        , p_mold_table(i).transaction_quantity
        , p_mold_table(i).transaction_uom
        , l_primary_uom_code
        , NULL
        , NULL
        );

      IF l_primary_quantity = -99999 THEN
        fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
        fnd_message.set_token('UOM', p_mold_table(i).transaction_uom);
        fnd_message.set_token('ROUTINE', 'inv_mo_line_detail_util.update_quantity_allocations');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_lot_control_code = 1
         AND l_serial_control_code IN(1, 6) THEN
        -- No control item
        l_current_table  := 'MTL_MATERIAL_TRANSACTIONS_TEMP';

        SELECT        ROWID
                    , transaction_temp_id
                    , transaction_quantity
                    , primary_quantity
                    , secondary_transaction_quantity
                 INTO l_mmtt_rowid
                    , l_transaction_temp_id
                    , l_mmtt_transaction_quantity
                    , l_mmtt_primary_quantity
                    , l_mmtt_sec_transaction_qty
                 FROM mtl_material_transactions_temp
                WHERE organization_id = p_mold_table(i).organization_id
                  AND subinventory_code = p_mold_table(i).subinventory_code
                  AND NVL(locator_id, -1) = NVL(p_mold_table(i).locator_id, -1)
                  AND inventory_item_id = p_mold_table(i).inventory_item_id
                  AND NVL(revision, '@@@') = NVL(p_mold_table(i).revision, '@@@')
                  AND move_order_line_id = p_move_order_line_id
        FOR UPDATE OF primary_quantity, transaction_quantity;

        -- Update the picked quantity in the table
        IF NOT(l_mmtt_table.EXISTS(l_transaction_temp_id)) THEN
          l_mmtt_table(l_transaction_temp_id).row_id                       := l_mmtt_rowid;
          l_mmtt_table(l_transaction_temp_id).transaction_quantity         := l_mmtt_transaction_quantity;
          l_mmtt_table(l_transaction_temp_id).picked_transaction_quantity  := p_mold_table(i).transaction_quantity;
          l_mmtt_table(l_transaction_temp_id).sec_transaction_qty          := l_mmtt_sec_transaction_qty;
          l_mmtt_table(l_transaction_temp_id).picked_sec_transaction_qty   := p_mold_table(i).secondary_transaction_quantity;
        ELSE
          l_mmtt_table(l_transaction_temp_id).picked_transaction_quantity  :=
                  l_mmtt_table(l_transaction_temp_id).picked_transaction_quantity
                  + p_mold_table(i).transaction_quantity;
          l_mmtt_table(l_transaction_temp_id).picked_sec_transaction_qty  :=
                  l_mmtt_table(l_transaction_temp_id).picked_sec_transaction_qty
                  + p_mold_table(i).secondary_transaction_quantity;
        END IF;

        IF l_mmtt_transaction_quantity > p_mold_table(i).transaction_quantity THEN
          UPDATE mtl_material_transactions_temp
             SET transaction_quantity = p_mold_table(i).transaction_quantity
               , secondary_transaction_quantity = p_mold_table(i).secondary_transaction_quantity
               , primary_quantity = l_primary_quantity
           WHERE ROWID = l_mmtt_rowid;
        ELSIF l_mmtt_transaction_quantity < p_mold_table(i).transaction_quantity THEN
          fnd_message.set_name('INV', 'INV_QUANTITY_TOO_BIG');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSIF l_lot_control_code = 2
            AND l_serial_control_code IN(1, 6) THEN
        -- Lot controlled item
        l_current_table                     := 'MTL_MATERIAL_TRANSACTIONS_TEMP';

        SELECT ROWID
             , transaction_temp_id
             , transaction_quantity
             , secondary_transaction_quantity
          INTO l_mmtt_rowid
             , l_transaction_temp_id
             , l_mmtt_transaction_quantity
             , l_mmtt_sec_transaction_qty
          FROM mtl_material_transactions_temp
         WHERE organization_id = p_mold_table(i).organization_id
           AND subinventory_code = p_mold_table(i).subinventory_code
           AND NVL(locator_id, -1) = NVL(p_mold_table(i).locator_id, -1)
           AND inventory_item_id = p_mold_table(i).inventory_item_id
           AND NVL(revision, '@@@') = NVL(p_mold_table(i).revision, '@@@')
           AND move_order_line_id = p_move_order_line_id;

        l_current_table                     := 'MTL_TRANSACTIONS_LOTS_TEMP';

        SELECT        ROWID
                    , primary_quantity
                    , transaction_quantity
                    , secondary_quantity
                 INTO l_mtlt_rowid
                    , l_mtlt_primary_quantity
                    , l_mtlt_transaction_quantity
                    , l_mtlt_sec_transaction_qty
                 FROM mtl_transaction_lots_temp
                WHERE transaction_temp_id = l_transaction_temp_id
                  AND lot_number = p_mold_table(i).lot_number
        FOR UPDATE OF primary_quantity, transaction_quantity;

        -- Update the picked quantity in the table
        IF NOT(l_mmtt_table.EXISTS(l_transaction_temp_id)) THEN
          l_mmtt_table(l_transaction_temp_id).row_id                       := l_mmtt_rowid;
          l_mmtt_table(l_transaction_temp_id).transaction_quantity         := l_mmtt_transaction_quantity;
          l_mmtt_table(l_transaction_temp_id).picked_transaction_quantity  := p_mold_table(i).transaction_quantity;
          l_mmtt_table(l_transaction_temp_id).picked_primary_quantity      := l_primary_quantity;
          l_mmtt_table(l_transaction_temp_id).sec_transaction_qty          := l_mmtt_sec_transaction_qty;
          l_mmtt_table(l_transaction_temp_id).picked_sec_transaction_qty   := p_mold_table(i).secondary_transaction_quantity;

        ELSE
          l_mmtt_table(l_transaction_temp_id).picked_transaction_quantity  :=
                  l_mmtt_table(l_transaction_temp_id).picked_transaction_quantity
                  + p_mold_table(i).transaction_quantity;
          l_mmtt_table(l_transaction_temp_id).picked_primary_quantity      :=
                                        l_mmtt_table(l_transaction_temp_id).picked_primary_quantity
                                        + l_primary_quantity;
          l_mmtt_table(l_transaction_temp_id).picked_sec_transaction_qty  :=
                  l_mmtt_table(l_transaction_temp_id).picked_sec_transaction_qty
                  + p_mold_table(i).secondary_transaction_quantity;

        END IF;

        -- Put the processed MTLT line rowid in the table
        l_mtlt_table(l_mtlt_table_counter)  := l_mtlt_rowid;
        l_mtlt_table_counter                := l_mtlt_table_counter + 1;

        UPDATE mtl_material_transactions_temp
           SET transaction_quantity = l_mmtt_table(l_transaction_temp_id).picked_transaction_quantity
             , secondary_transaction_quantity = l_mmtt_table(l_transaction_temp_id).picked_sec_transaction_qty
             , primary_quantity = l_mmtt_table(l_transaction_temp_id).picked_primary_quantity
         WHERE ROWID = l_mmtt_rowid;

        IF l_mtlt_transaction_quantity > p_mold_table(i).transaction_quantity THEN
          UPDATE mtl_transaction_lots_temp
             SET transaction_quantity = p_mold_table(i).transaction_quantity
               , secondary_quantity = p_mold_table(i).secondary_transaction_quantity
               , primary_quantity = l_primary_quantity
           WHERE ROWID = l_mtlt_rowid;
        ELSIF l_mtlt_transaction_quantity < p_mold_table(i).transaction_quantity THEN
          fnd_message.set_name('INV', 'INV_QUANTITY_TOO_BIG');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF; -- Type of item control

      i                   := p_mold_table.NEXT(i);
    END LOOP;

    -- after all this is done we need to delete the remaining MMTT, MTLT,
    -- MSNT lines which have not been picked
    IF l_mtlt_table.COUNT > 0 THEN
      FOR i IN 1 .. l_mtlt_table.COUNT LOOP
        IF (i = 1) THEN
          l_del_mtlt  := l_del_mtlt || ' AND ROWID NOT IN (' || '''' || l_mtlt_table(i) || '''';
        ELSE
          l_del_mtlt  := l_del_mtlt || ', ' || '''' || l_mtlt_table(i) || '''';
        END IF;

        IF i = l_mtlt_table.COUNT THEN
          l_del_mtlt  := l_del_mtlt || ')';
        END IF;
      END LOOP;

      l_sql_p           := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(l_sql_p, l_del_mtlt, DBMS_SQL.native);
      DBMS_SQL.bind_variable(l_sql_p, 'b_move_order_line_id', p_move_order_line_id);
      l_rows_processed  := DBMS_SQL.EXECUTE(l_sql_p);
    END IF;

    IF l_mmtt_table.COUNT > 0 THEN
      i                 := l_mmtt_table.FIRST;

      WHILE i IS NOT NULL LOOP
        IF (i = l_mmtt_table.FIRST) THEN
          l_del_mmtt  := l_del_mmtt || ' AND ROWID NOT IN (' || '''' || l_mmtt_table(i).row_id || '''';
        ELSE
          l_del_mmtt  := l_del_mmtt || ', ' || '''' || l_mmtt_table(i).row_id || '''';
        END IF;

        IF i = l_mmtt_table.LAST THEN
          l_del_mmtt  := l_del_mmtt || ')';
        END IF;

        i  := l_mmtt_table.NEXT(i);
      END LOOP;

      l_sql_p           := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(l_sql_p, l_del_mmtt, DBMS_SQL.native);
      DBMS_SQL.bind_variable(l_sql_p, 'b_move_order_line_id', p_move_order_line_id);
      l_rows_processed  := DBMS_SQL.EXECUTE(l_sql_p);
    END IF;

    -- Requery the MMTT rows and pass them back as the output parameter
    x_mold_table     := inv_mo_line_detail_util.query_rows(p_move_order_line_id);
    -- Get message count and data
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_message.set_name('INV', 'INV_MGD_MVT_TOO_MANY_TRANS');
      fnd_msg_pub.ADD;
      ROLLBACK TO update_qty;
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_message.set_name('INV', 'INV_NO_RECORDS');
      fnd_message.set_token('ENTITY', l_current_table);
      fnd_msg_pub.ADD;
      -- Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO update_qty;
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      -- Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO update_qty;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      -- Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO update_qty;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO update_qty;
  END;

  PROCEDURE delete_allocations(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , p_mo_line_id          IN         NUMBER
  , p_transaction_temp_id IN         NUMBER
  ) IS
    CURSOR c_mmtt_info IS
      SELECT transaction_temp_id
        FROM mtl_material_transactions_temp
       WHERE (p_mo_line_id IS NOT NULL AND move_order_line_id = p_mo_line_id)
         AND (p_transaction_temp_id IS NULL)
      UNION ALL
      SELECT transaction_temp_id
        FROM mtl_material_transactions_temp
       WHERE (p_transaction_temp_id IS NOT NULL AND transaction_temp_id = p_transaction_temp_id);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    IF p_mo_line_id IS NULL AND p_transaction_temp_id IS NULL THEN
      debug('Either Move Order Line ID or Transaction Temp ID has to be passed','DELETE_ALLOCATIONS');
      fnd_message.set_name('INV','INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    FOR l_mmtt IN c_mmtt_info LOOP
      inv_trx_util_pub.delete_transaction(
        x_return_status              => x_return_status
      , x_msg_data                   => x_msg_data
      , x_msg_count                  => x_msg_count
      , p_transaction_temp_id        => l_mmtt.transaction_temp_id
      );
    END LOOP;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END delete_allocations;

  PROCEDURE reduce_allocation_quantity(
    x_return_status       OUT NOCOPY VARCHAR2
  , p_transaction_temp_id IN         NUMBER
  , p_quantity            IN         NUMBER
  , p_secondary_quantity  IN         NUMBER   --INVCONV
  ) IS
    l_transaction_quantity       NUMBER;
    l_sec_transaction_quantity   NUMBER;  --INVCONV
    l_organization_id            NUMBER;
    l_inventory_item_id          NUMBER;
    l_primary_uom_code           VARCHAR2(3);
    l_transaction_uom_code       VARCHAR2(3);
    l_secondary_uom_code       VARCHAR2(3); --INVCONV
    l_remaining_quantity         NUMBER;
    l_lot_quantity               NUMBER;
    l_lot_sec_quantity           NUMBER;   --INVCONV
    l_lot_rowid                  ROWID;
    l_serial_transaction_temp_id NUMBER;
    l_from_serial_number         VARCHAR2(30);
    l_to_serial_number           VARCHAR2(30);
    l_serial_rowid               ROWID;
    l_lot_qty_to_delete          NUMBER;
    l_serial_qty_to_delete       NUMBER;
    l_serial_quantity            NUMBER;
    l_new_lot_quantity           NUMBER;
    l_new_lot_prim_quantity      NUMBER;
    l_new_lot_sec_quantity       NUMBER; --INVCONV
    l_new_sec_quantity           NUMBER; --INVCONV
    l_new_quantity               NUMBER;
    l_new_prim_quantity          NUMBER;
    l_last_deleted_serial_number VARCHAR2(30);
    l_new_from_serial_number     VARCHAR2(30);
    l_from_prefix                VARCHAR2(30);
    l_from_num                   NUMBER;
    l_new_num                    NUMBER;
    l_msg_data                   VARCHAR2(2000);
    l_msg_count                  NUMBER;

    CURSOR c_mmtt_info IS
      SELECT     transaction_quantity
               , secondary_transaction_quantity --INVCONV
               , organization_id
               , inventory_item_id
               , item_primary_uom_code
               , transaction_uom
               , secondary_uom_code   --INVCONV
            FROM mtl_material_transactions_temp
           WHERE transaction_temp_id = p_transaction_temp_id
      FOR UPDATE;

    CURSOR c_primary_uom IS
      SELECT primary_uom_code, secondary_uom_code --INVCONV
        FROM mtl_system_items
       WHERE organization_id = l_organization_id
         AND inventory_item_id = l_inventory_item_id;

    CURSOR c_lot_allocations IS
      SELECT   transaction_quantity
             , secondary_quantity  --INVCONV
             , serial_transaction_temp_id
             , ROWID
          FROM mtl_transaction_lots_temp
         WHERE transaction_temp_id = p_transaction_temp_id
      ORDER BY transaction_quantity ASC;

    CURSOR c_serial_allocations IS
      SELECT fm_serial_number
           , NVL(to_serial_number, fm_serial_number)
           , ROWID
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = l_serial_transaction_temp_id;

    l_debug                     NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    SAVEPOINT reduce_sp;

    IF p_quantity IS NULL
       OR p_transaction_temp_id IS NULL
       OR p_quantity <= 0 THEN
      RETURN;
    END IF;

    OPEN c_mmtt_info;
    FETCH c_mmtt_info INTO l_transaction_quantity, l_sec_transaction_quantity, l_organization_id, l_inventory_item_id, l_primary_uom_code
   , l_transaction_uom_code, l_secondary_uom_code;

    IF c_mmtt_info%NOTFOUND THEN
      RETURN;
    END IF;

    CLOSE c_mmtt_info;

    IF p_quantity >= l_transaction_quantity THEN
      delete_allocations(x_return_status, l_msg_data, l_msg_count, NULL, p_transaction_temp_id);
      RETURN;
    END IF;

    IF l_primary_uom_code IS NULL THEN
      OPEN c_primary_uom;
      FETCH c_primary_uom INTO l_primary_uom_code, l_secondary_uom_code;

      IF c_primary_uom%NOTFOUND
         OR l_primary_uom_code IS NULL THEN
        RETURN;
      END IF;

      CLOSE c_primary_uom;
    END IF;

    l_remaining_quantity  := p_quantity;
    OPEN c_lot_allocations;

    LOOP
      EXIT WHEN l_remaining_quantity <= 0;
      FETCH c_lot_allocations INTO l_lot_quantity, l_lot_sec_quantity, l_serial_transaction_temp_id, l_lot_rowid;
      EXIT WHEN c_lot_allocations%NOTFOUND;

      IF l_lot_quantity <= l_remaining_quantity THEN
        l_lot_qty_to_delete  := l_lot_quantity;
      ELSE
        l_lot_qty_to_delete  := l_remaining_quantity;
      END IF;

      l_remaining_quantity    := l_remaining_quantity - l_lot_qty_to_delete;
      l_serial_qty_to_delete  := l_lot_qty_to_delete;
      OPEN c_serial_allocations;

      LOOP
        EXIT WHEN l_serial_qty_to_delete <= 0;
        FETCH c_serial_allocations INTO l_from_serial_number, l_to_serial_number, l_serial_rowid;
        EXIT WHEN c_serial_allocations%NOTFOUND;

        --different processing if the serial record has a single
        -- serial number or multiple serial numbers
        IF l_to_serial_number <> l_from_serial_number THEN
          --determine how many to delete
          l_serial_quantity  := inv_detail_util_pvt.subtract_serials(l_from_serial_number, l_to_serial_number);
        ELSE
          l_serial_quantity  := 1;
        END IF;

        IF l_serial_quantity > l_serial_qty_to_delete THEN
                --determine last serial number to delete and first
          -- serial number to keep
          inv_detail_util_pvt.split_prefix_num(p_serial_number => l_from_serial_number, p_prefix => l_from_prefix
          , x_num                        => l_from_num);
          l_new_num                     := l_from_num + l_serial_qty_to_delete - 1;
          l_last_deleted_serial_number  := l_from_prefix || l_new_num;
          l_new_num                     := l_new_num + 1;
          l_new_from_serial_number      := l_from_prefix || l_new_num;

          UPDATE mtl_serial_numbers
             SET group_mark_id = NULL
           WHERE serial_number BETWEEN l_from_serial_number AND l_last_deleted_serial_number;

          UPDATE mtl_serial_numbers_temp
             SET fm_serial_number = l_new_from_serial_number
           WHERE ROWID = l_serial_rowid;

          l_serial_qty_to_delete        := 0;
        ELSE --delete the row

             --unmark in serial number table
          UPDATE mtl_serial_numbers
             SET group_mark_id = NULL
           WHERE inventory_item_id = l_inventory_item_id
             AND serial_number BETWEEN l_from_serial_number AND l_to_serial_number;

          --delete records
          DELETE FROM mtl_serial_numbers_temp
                WHERE ROWID = l_serial_rowid;

          --decrement
          l_serial_qty_to_delete  := l_serial_qty_to_delete - l_serial_quantity;
        END IF;
      END LOOP;

      CLOSE c_serial_allocations;

      IF l_lot_qty_to_delete = l_lot_quantity THEN
        DELETE FROM mtl_transaction_lots_temp
              WHERE ROWID = l_lot_rowid;
      ELSE
        l_new_lot_quantity       := l_lot_quantity - l_lot_qty_to_delete;
        --convert quantity
        l_new_lot_prim_quantity  :=
          inv_convert.inv_um_convert(l_inventory_item_id, 5, l_new_lot_quantity, l_transaction_uom_code
          , l_primary_uom_code, NULL, NULL);

        IF l_new_prim_quantity = -99999 THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        UPDATE mtl_transaction_lots_temp
           SET transaction_quantity = l_new_lot_quantity
             , primary_quantity = l_new_lot_prim_quantity
         WHERE ROWID = l_lot_rowid;
      END IF;
    END LOOP;

    CLOSE c_lot_allocations;
    l_new_quantity        := l_transaction_quantity - p_quantity;
    --convert quantity
    l_new_prim_quantity   :=
      inv_convert.inv_um_convert(l_inventory_item_id, 5, l_new_quantity, l_transaction_uom_code, l_primary_uom_code
      , NULL, NULL);

    IF l_new_prim_quantity = -99999 THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    UPDATE mtl_material_transactions_temp
       SET transaction_quantity = l_new_quantity
         , primary_quantity = l_new_prim_quantity
     WHERE transaction_temp_id = p_transaction_temp_id;

    x_return_status       := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO reduce_sp;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END reduce_allocation_quantity;

  /* Bug 2427514: To get the Lot Qty for a Given Transaction Temp ID */
  PROCEDURE get_lot_quantity(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , x_msg_data            OUT NOCOPY VARCHAR2
  , p_transaction_temp_id IN         NUMBER
  , x_lot_quantity        OUT NOCOPY NUMBER
  ) IS
    l_procedure_name VARCHAR2(30) := 'GET_LOT_QUANTITY';

    CURSOR lot_records IS
      SELECT NVL(SUM(mtlt.primary_quantity), 0)
        FROM mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id = p_transaction_temp_id;

    l_lot_quantity   NUMBER       := 0;
    l_debug          NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    OPEN lot_records;
    FETCH lot_records INTO l_lot_quantity;
    CLOSE lot_records;
    x_lot_quantity   := l_lot_quantity;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_lot_quantity   := 0;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_lot_quantity   := 0;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_lot_quantity   := 0;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_procedure_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_lot_quantity;

  /* Bug 2427514: To get the Serial Qty for a Given Transaction Temp ID */
  PROCEDURE get_serial_quantity(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , x_msg_data            OUT NOCOPY VARCHAR2
  , p_transaction_temp_id  IN        NUMBER
  , x_serial_quantity     OUT NOCOPY NUMBER
  ) IS
    l_procedure_name  VARCHAR2(30) := 'GET_SERIAL_QUANTITY';

    CURSOR serial_records IS
      SELECT SUM(inv_serial_number_pub.get_serial_diff(msnt.fm_serial_number, msnt.to_serial_number))
        FROM mtl_serial_numbers_temp msnt
       WHERE msnt.transaction_temp_id = p_transaction_temp_id;

    l_serial_quantity NUMBER       := 0;
    l_debug           NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    OPEN serial_records;
    FETCH serial_records INTO l_serial_quantity;
    CLOSE serial_records;
    x_serial_quantity  := l_serial_quantity;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    x_return_status    := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_serial_quantity  := 0;
      x_return_status    := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_serial_quantity  := 0;
      x_return_status    := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_serial_quantity  := 0;
      x_return_status    := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_procedure_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_serial_quantity;

  /* Bug 2427514: To check the whether records exists in MTLT and MSNT for a
     given Transaction Temp ID */
  PROCEDURE are_allocations_complete(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , x_msg_data            OUT NOCOPY VARCHAR2
  , p_transaction_temp_id IN         NUMBER
  ) IS
    l_procedure_name             VARCHAR2(30)                      := 'ARE_ALLOCATIONS_COMPLETE';

    CURSOR item_properties(c_transaction_temp_id NUMBER) IS
      SELECT NVL(lot_control_code, 1) lot_control_code
           , NVL(serial_number_control_code, 1) serial_number_control_code
           , mmtt.primary_quantity primary_quantity
           , mmtt.lot_number
           , mmtt.lot_expiration_date
           , mmtt.transaction_date
        FROM mtl_system_items_b msi, mtl_material_transactions_temp mmtt
       WHERE msi.inventory_item_id = mmtt.inventory_item_id
         AND msi.organization_id = mmtt.organization_id
         AND mmtt.transaction_temp_id = c_transaction_temp_id;

    CURSOR lot_records(c_transaction_temp_id NUMBER) IS
      SELECT mtlt.serial_transaction_temp_id
           , mtlt.primary_quantity
        FROM mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id = c_transaction_temp_id;

    l_quantity                   NUMBER                            := 0;
    l_lot_quantity               NUMBER                            := 0;
    l_serial_quantity            NUMBER                            := 0;
    l_temp_quantity              NUMBER                            := 0;
    l_lot_control_code           NUMBER                            := 1;
    l_serial_number_control_code NUMBER                            := 1;
    l_serial_transaction_temp_id NUMBER;
    l_return_status              VARCHAR2(10)                      := fnd_api.g_ret_sts_unexp_error;
    l_msg_data                   VARCHAR2(1000);
    l_msg_count                  NUMBER                            := 0;
    l_lot_number                 mtl_lot_numbers.lot_number%TYPE;
    l_lot_expiration_date        DATE;
    l_transaction_date           DATE;
    l_debug                      NUMBER                            := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    OPEN item_properties(p_transaction_temp_id);
    FETCH item_properties INTO l_lot_control_code
   , l_serial_number_control_code
   , l_quantity
   , l_lot_number
   , l_lot_expiration_date
   , l_transaction_date;
    CLOSE item_properties;

    /*  Changed for 2462679 */
    IF l_lot_control_code = 1 AND l_serial_number_control_code IN(1, 6) THEN
      x_return_status  := fnd_api.g_ret_sts_success;
      GOTO success;
    END IF;

    /*
    ** Only Lot controlled (and not serial controlled)
    ** Allocated Lot quantity must match transaction quantity
    ** If lot information is available from MMTT (manual allocations)
    ** then allocated quantity would be same as primary quantity
    */
     /*  Changed for 2462679 */
    IF l_lot_control_code <> 1 AND l_serial_number_control_code IN(1, 6) THEN
      l_lot_expiration_date  := TRUNC(l_lot_expiration_date);
      l_transaction_date     := TRUNC(l_transaction_date);

      IF l_lot_number IS NOT NULL THEN  --Bug3639464
        l_lot_quantity  := l_quantity;
      ELSE
        get_lot_quantity(l_return_status, l_msg_data, l_msg_count, p_transaction_temp_id, l_lot_quantity);

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

      IF l_lot_quantity <> l_quantity THEN
        RAISE fnd_api.g_exc_error;
      ELSE
        GOTO success;
      END IF;
    END IF;

    /*
    ** Only Serial controlled (and not lot controlled)
    ** Allocated Serials must match transaction quantity
    */
     /*  Changed for 2462679 */
    IF l_lot_control_code = 1 AND l_serial_number_control_code NOT IN(1, 6) THEN
      get_serial_quantity(l_return_status, l_msg_data, l_msg_count, p_transaction_temp_id, l_serial_quantity);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      /*Bug 6790396 added nvl to  l_serial_quantity*/
      IF NVL(l_serial_quantity,0) <> l_quantity THEN
        RAISE fnd_api.g_exc_error;
      ELSE
        GOTO success;
      END IF;
    END IF;

    /*
    ** Lot and Serial controlled items.
    ** Allocated Serials for each Lot must match transaction quantity of each lot
    ** Sum of all allocated lots must match transaction quantity
    */
    IF l_lot_number IS NOT NULL THEN
      x_return_status  := fnd_api.g_ret_sts_success;
      GOTO success;
    END IF;

    OPEN lot_records(p_transaction_temp_id);

    LOOP
      FETCH lot_records INTO l_serial_transaction_temp_id, l_lot_quantity;
      EXIT WHEN lot_records%NOTFOUND;
      get_serial_quantity(l_return_status, l_msg_data, l_msg_count, l_serial_transaction_temp_id, l_serial_quantity);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      /*Bug 6790396 added nvl to  l_serial_quantity*/
      IF NVL(l_serial_quantity,0) <> l_lot_quantity THEN
        RAISE fnd_api.g_exc_error;
      ELSE
        l_temp_quantity  := l_temp_quantity + l_lot_quantity;
      END IF;
    END LOOP;

    CLOSE lot_records;

    IF (l_temp_quantity <> l_quantity) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    <<success>>
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_procedure_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END are_allocations_complete;

  /* Bug 2427514: To find out whether a MO Line is correctly allocated */
  PROCEDURE is_line_detailed(
    x_return_status      OUT NOCOPY VARCHAR2
  , x_msg_count          OUT NOCOPY NUMBER
  , x_msg_data           OUT NOCOPY VARCHAR2
  , p_move_order_line_id IN     NUMBER
  ) IS
    l_procedure_name       VARCHAR2(30)   := 'IS_LINE_DETAILED';

    CURSOR mmtt_records IS
      SELECT mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.move_order_line_id = p_move_order_line_id;

    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(1000);
    l_detail_records_exist BOOLEAN        := FALSE;
    l_transaction_temp_id  NUMBER;
    l_debug                NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    OPEN mmtt_records;

    LOOP
      FETCH mmtt_records INTO l_transaction_temp_id;
      EXIT WHEN mmtt_records%NOTFOUND;
      l_detail_records_exist  := TRUE;
      are_allocations_complete(l_return_status, l_msg_count, l_msg_data, l_transaction_temp_id);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END LOOP;

    IF NOT l_detail_records_exist THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_procedure_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END is_line_detailed;
END inv_mo_line_detail_util;

/
