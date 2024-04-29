--------------------------------------------------------
--  DDL for Package Body WIP_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_VALIDATE" AS
/* $Header: WIPSVATB.pls 120.2 2006/02/21 11:18:00 sjchen noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Validate';

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  validation functions.
--
--  DO NOT REMOVE

PROCEDURE Get_Attr_Tbl
IS
I                             NUMBER:=0;
BEGIN

    FND_API.g_attr_tbl.DELETE;

--  START GEN attributes

--  Generator will append new attributes before end generate comment.

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Desc_Flex';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'created_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'creation_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'description';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'entity_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_updated_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_login';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'organization';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'primary_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_application';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'request';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'wip_entity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'wip_entity_name';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'alternate_bom_designator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'alternate_rout_designator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'bom_revision';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'bom_revision_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'build_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'class';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'completion_locator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'completion_subinventory';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'date_closed';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_class';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_source_delivery';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_source_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_source_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_source_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'kanban_card';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'material_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'material_overhead_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'material_variance_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'mps_net_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'mps_scheduled_cpl_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'osp_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'osp_variance_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'overhead_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'overhead_variance_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'planned_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'project';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quantity_completed';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'resource_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'resource_variance_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'routing_revision';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'routing_revision_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'scheduled_completion_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'scheduled';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'scheduled_start_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'schedule_group';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'schedule_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'status';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'std_cost_adj_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'task';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'bom_reference';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'common_bom_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'common_rout_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'date_completed';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'date_released';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'firm_planned';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'job_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lot_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'net_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'overcpl_tolerance_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'overcpl_tolerance_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'project_costed';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quantity_scrapped';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'routing_reference';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'source';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'source_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'start_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'status_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'wip_supply_type';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'daily_production_rate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'first_unit_cpl_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'first_unit_start_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_unit_cpl_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_unit_start_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'processing_work_days';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'repetitive_schedule';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'dummy';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'acct_period';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'allowed_units_lookup';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'completion_transaction';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'containers';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cost_group';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency_conversion_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency_conversion_rate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency_conversion_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'current_loc_control';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'customer_ship';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cycle_count';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'department';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'department';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'distribution_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'employee';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'encumbrance_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'encumbrance_amount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'error';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'error_explanation';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'expected_arrival_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'expenditure_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'final_completion';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'flow_schedule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'freight';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'inventory_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_description';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_inventory_asset';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_loc_control';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_lot_control';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_ordering';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_primary_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_restrict_loc';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_restrict_subinv';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_rev_qty_control';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_segments';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_serial_control';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_shelf_life';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_shelf_life_days';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_trx_enabled';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_uom_class';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'locator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'locator_segments';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lock_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lot_alpha_prefix';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lot_expiration_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'material_alloc_temp';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'movement';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'move_transaction';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'negative_req';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'new_average_cost';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'next_lot_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'next_serial_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'number_of_lots_entered';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'operation_seq_num';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'overcpl_primary_qty';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'overcpl_transaction';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'overcpl_transaction_qty';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pa_expenditure_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'percentage_change';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'physical_adjustment';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'picking_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'posting';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'primary_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'primary_switch';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'process';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'process_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qa_collection';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rcv_transaction';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'receiving_document';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'repetitive_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'required';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'req_distribution';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'requisition_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reservation_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'revision';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rma_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'schedule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'schedule_update';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'serial_alpha_prefix';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'serial_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'setup_teardown';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipment_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shippable';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipped_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_to_location';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'source_project';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'source_task';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'subinventory';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'supply_locator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'supply_subinventory';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_project';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_task';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_action';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_cost';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_line_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_mode';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_reference';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_source';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_source_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_src_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_temp';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transfer_cost';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transfer_organization';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transfer_percentage';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transfer_subinventory';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transfer_to_location';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transportation_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transportation_cost';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'trx_source_delivery';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'trx_source_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ussgl_transaction';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'valid_locator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'valid_subinventory';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'value_change';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'vendor_lot_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'waybill_airbill';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'wip_commit';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'wip_entity_type';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'activity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'activity_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'actual_resource_rate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'autocharge_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'basis_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'created_by_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency_actual_rsc_rate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'employee_num';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'group_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_updated_by_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'po_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'po_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'primary_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'primary_uom_class';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'process_phase';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'process_status';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'project_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reason_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'receiving_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'resource_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'resource_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'resource_seq_num';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'resource_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'standard_rate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'task_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'usage_rate_or_amount';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'fm_department';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'fm_department';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'fm_intraop_step_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'fm_operation';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'fm_operation_seq_num';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'kanban';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'overcompletion';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'overmove_txn_qty';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'scrap_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_department';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_department';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_intraop_step_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_operation';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_operation_seq_num';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_link';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency_act_rsc_rate';

--  END GEN attributes

END Get_Attr_Tbl;

--  Prototypes for validate functions.

--  START GEN validate

--  Generator will append new prototypes before end generate comment.


FUNCTION Desc_Flex ( p_flex_name IN VARCHAR2 )
RETURN BOOLEAN
IS
BEGIN

   --  Call FND validate API.
   --  This call is temporarily commented out
/*
    IF  FND_FLEX_DESCVAL.Validate_Desccols
        (   appl_short_name               => 'WIP'
        ,   desc_flex_name                => p_flex_name
        )
    THEN
        RETURN TRUE;
    ELSE
      --  Prepare the encoded message by setting it on the message
      --  dictionary stack. Then, add it to the API message list.

        FND_MESSAGE.Set_Encoded(FND_FLEX_DESCVAL.Encoded_Error_Message);
        FND_MSG_PUB.Add;
        --  Derive return status.

        IF FND_FLEX_DESCVAL.value_error OR
            FND_FLEX_DESCVAL.unsupported_error
        THEN
            --  In case of an expected error return FALSE
            RETURN FALSE;
        ELSE
            --  In case of an unexpected error raise an exception.
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
*/

    RETURN TRUE;

END Desc_Flex;

FUNCTION Entity_Type ( p_entity_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_entity_type IS NULL OR
        p_entity_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mfg_lookups
      WHERE    lookup_type = 'WIP_ENTITY'
      AND      lookup_code = p_entity_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'entity_type');
        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Entity_Type;

FUNCTION Organization ( p_organization_code IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_organization_code IS NULL OR
        p_organization_code = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     mtl_parameters
    WHERE    organization_code = p_organization_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'organization_code');

       RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization;

FUNCTION Organization ( p_organization_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_organization_id IS NULL OR
        p_organization_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     mtl_parameters
    WHERE    organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'organization');

       RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization;

FUNCTION Primary_Item ( p_primary_item_id IN NUMBER,
                        p_organization_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_primary_item_id IS NULL OR
        p_primary_item_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mtl_system_items
      WHERE    inventory_item_id = p_primary_item_id
      AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'primary_item');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Primary_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Primary_Item;

FUNCTION Wip_Entity ( p_wip_entity_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_wip_entity_id IS NULL OR
        p_wip_entity_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     wip_entities
    WHERE    wip_entity_id = p_wip_entity_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'wip_entity');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Wip_Entity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Wip_Entity;

FUNCTION Wip_Entity_Name ( p_wip_entity_name IN VARCHAR2,
                           p_organization_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_wip_entity_name IS NULL OR
        p_wip_entity_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     wip_entities
      WHERE    wip_entity_name = p_wip_entity_name
      AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'wip_entity_name');

        RETURN FALSE;


    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Wip_Entity_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Wip_Entity_Name;

FUNCTION Alternate_Bom_Designator ( p_alternate_bom_designator IN VARCHAR2,
                                    p_organization_id          IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_alternate_bom_designator IS NULL OR
        p_alternate_bom_designator = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     bom_alternate_designators
      WHERE    alternate_designator_code = p_alternate_bom_designator
      AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'alternate_bom_designator');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Alternate_Bom_Designator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Alternate_Bom_Designator;

FUNCTION Alternate_Rout_Designator ( p_alternate_rout_designator IN VARCHAR2,
                                     p_organization_id           IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_alternate_rout_designator IS NULL OR
        p_alternate_rout_designator = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     bom_alternate_designators
      WHERE    alternate_designator_code = p_alternate_rout_designator
      AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'alternate_rout_designator');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Alternate_Rout_Designator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Alternate_Rout_Designator;

FUNCTION Bom_Revision ( p_bom_revision      IN VARCHAR2,
                        p_inventory_item_id IN NUMBER,
                        p_organization_id   IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_bom_revision IS NULL OR
        p_bom_revision = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mtl_item_revisions
      WHERE    revision = p_bom_revision
      AND      inventory_item_id = p_inventory_item_id
      AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'bom_revision');

       RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Bom_Revision'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Bom_Revision;

FUNCTION Build_Sequence ( p_build_sequence      IN NUMBER,
                          p_wip_entity_id       IN NUMBER,
                          p_organization_id     IN NUMBER,
                          p_line_id             IN NUMBER,
                          p_schedule_group_id   IN NUMBER)
RETURN BOOLEAN
IS
   l_dummy                       VARCHAR2(10);
BEGIN

    IF p_build_sequence IS NULL OR
        p_build_sequence = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    -- check that the combination of build sequence, schedule group and production
    -- line is unique across all wip entities.

    SELECT 'VALID'
      INTO l_dummy
      FROM dual
      WHERE NOT EXISTS (
                        SELECT '1'
                        FROM wip_discrete_jobs
                        WHERE wip_entity_id <> p_wip_entity_id
                        AND build_sequence = p_build_sequence
                        AND Nvl(p_schedule_group_id, Nvl(schedule_group_id,-1)) = Nvl(schedule_group_id,-1)
                        AND Nvl(p_line_id, Nvl(line_id,-1)) = Nvl(line_id,-1)
                        )
      AND NOT EXISTS (
                      SELECT '1'
                      FROM wip_flow_schedules
                      WHERE wip_entity_id <> p_wip_entity_id
                      AND build_sequence = p_build_sequence
                      AND Nvl(p_schedule_group_id, Nvl(schedule_group_id,-1)) = Nvl(schedule_group_id,-1)
                      AND Nvl(p_line_id, Nvl(line_id,-1)) = Nvl(line_id,-1)
                      );

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'build_sequence');

       RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Build_Sequence'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Build_Sequence;

FUNCTION Class ( p_class_code      IN VARCHAR2,
                 p_organization_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_class_code IS NULL OR
        p_class_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     wip_accounting_classes
      WHERE    class_code = p_class_code
      AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'class');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Class'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Class;

FUNCTION Completion_Subinventory ( p_completion_subinventory IN VARCHAR2,
                                   p_organization_id         IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_completion_subinventory IS NULL OR
        p_completion_subinventory = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mtl_secondary_inventories
      WHERE    secondary_inventory_name = p_completion_subinventory
      AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'completion_subinventory');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Completion_Subinventory'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Completion_Subinventory;

FUNCTION Demand_Class ( p_demand_class IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_demand_class IS NULL OR
        p_demand_class = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     so_demand_classes_active_v
    WHERE    demand_class = p_demand_class;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'demand_class');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Class'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Class;

FUNCTION Demand_Source_Delivery ( p_demand_source_delivery  IN VARCHAR2,
                                  p_demand_source_line      IN VARCHAR2,
                                  p_demand_source_header_id IN NUMBER,
                                  p_demand_source_type      IN NUMBER,
                                  p_inventory_item_id       IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_demand_source_delivery IS NULL OR
        p_demand_source_delivery = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mtl_demand
      WHERE    demand_source_delivery = p_demand_source_delivery
      AND      demand_source_line = p_demand_source_line
      AND      demand_source_header_id = p_demand_source_header_id
      AND      demand_source_type = p_demand_source_type
      AND      inventory_item_id = p_inventory_item_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'demand_source_delivery');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Source_Delivery'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Source_Delivery;

FUNCTION Demand_Source_Header ( p_demand_source_header_id IN NUMBER,
                                p_demand_source_type      IN NUMBER,
                                p_inventory_item_id       IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_demand_source_header_id IS NULL OR
        p_demand_source_header_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mtl_demand
      WHERE    demand_source_header_id = p_demand_source_header_id
      AND      inventory_item_id = p_inventory_item_id
      AND      demand_source_type = p_demand_source_type
      AND      rownum = 1;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'demand_source_header');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Source_Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Source_Header;

FUNCTION Demand_Source_Line ( p_demand_source_line      IN VARCHAR2,
                              p_demand_source_header_id IN NUMBER,
                              p_demand_source_type      IN NUMBER,
                              p_inventory_item_id       IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_demand_source_line IS NULL OR
        p_demand_source_line = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mtl_demand
      WHERE    demand_source_line = p_demand_source_line
      AND      demand_source_header_id = p_demand_source_header_id
      AND      demand_source_type = p_demand_source_type
      AND      inventory_item_id = p_inventory_item_id
      AND      rownum = 1;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'demand_source_line');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Source_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Source_Line;

FUNCTION Kanban_Card ( p_kanban_card_id   IN NUMBER,
                       p_organization_id  IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_kanban_card_id IS NULL OR
        p_kanban_card_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mtl_kanban_cards
      WHERE    kanban_card_id = p_kanban_card_id
      AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'kanban_card');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Kanban_Card'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Kanban_Card;

FUNCTION Line ( p_line_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_line_code IS NULL OR
        p_line_code = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     wip_lines
      WHERE    line_code = p_line_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'line_code');

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line;

FUNCTION Line ( p_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_line_id IS NULL OR
        p_line_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     wip_lines
      WHERE    line_id = p_line_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'line_id');

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line;

FUNCTION Material_Account ( p_material_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_material_account IS NULL OR
        p_material_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     gl_code_combinations
    WHERE    code_combination_id = p_material_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'material_account');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Material_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Material_Account;

FUNCTION Material_Overhead_Account ( p_material_overhead_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_material_overhead_account IS NULL OR
        p_material_overhead_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     gl_code_combinations
    WHERE    code_combination_id = p_material_overhead_account;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'material_overhead_account');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Material_Overhead_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Material_Overhead_Account;

FUNCTION Material_Variance_Account ( p_material_variance_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_material_variance_account IS NULL OR
        p_material_variance_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     gl_code_combinations
    WHERE    code_combination_id = p_material_variance_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'material_variance_account');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Material_Variance_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Material_Variance_Account;

FUNCTION Osp_Account ( p_osp_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_osp_account IS NULL OR
        p_osp_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     gl_code_combinations
    WHERE    code_combination_id = p_osp_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'osp_account');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Osp_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Osp_Account;

FUNCTION Osp_Variance_Account ( p_osp_variance_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_osp_variance_account IS NULL OR
        p_osp_variance_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     gl_code_combinations
    WHERE    code_combination_id = p_osp_variance_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'osp_variance_account');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Osp_Variance_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Osp_Variance_Account;

FUNCTION Overhead_Account ( p_overhead_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_overhead_account IS NULL OR
        p_overhead_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     gl_code_combinations
    WHERE    code_combination_id = p_overhead_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'overhead_account');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Overhead_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Overhead_Account;

FUNCTION Overhead_Variance_Account ( p_overhead_variance_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_overhead_variance_account IS NULL OR
        p_overhead_variance_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     gl_code_combinations
    WHERE    code_combination_id = p_overhead_variance_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'overhead_variance_account');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Overhead_Variance_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Overhead_Variance_Account;

FUNCTION Project ( p_project_id      IN NUMBER,
                   p_organization_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_project_id IS NULL OR
        p_project_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    -- fix MOAC, set id so project view works
    fnd_profile.put('MFG_ORGANIZATION_ID',p_organization_id);

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mtl_project_v mpv, mtl_parameters mp
      WHERE    mpv.project_id = p_project_id
      AND      mp.organization_id = p_organization_id
      AND      mp.project_reference_enabled = 1;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'project');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Project'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Project;

FUNCTION Resource_Account ( p_resource_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_resource_account IS NULL OR
        p_resource_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     gl_code_combinations
    WHERE    code_combination_id = p_resource_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'resource_account');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Resource_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Resource_Account;

FUNCTION Resource_Variance_Account ( p_resource_variance_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_resource_variance_account IS NULL OR
        p_resource_variance_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     gl_code_combinations
    WHERE    code_combination_id = p_resource_variance_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'resource_variance_account');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Resource_Variance_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Resource_Variance_Account;

FUNCTION Routing_Revision ( p_routing_revision  IN VARCHAR2,
                            p_inventory_item_id IN NUMBER,
                            p_organization_id   IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_routing_revision IS NULL OR
        p_routing_revision = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mtl_rtg_item_revisions
      WHERE    process_revision = p_routing_revision
      AND      inventory_item_id = p_inventory_item_id
      AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'routing_revision');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Routing_Revision'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Routing_Revision;

FUNCTION Schedule_Group ( p_schedule_group_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_schedule_group_id IS NULL OR
        p_schedule_group_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     wip_schedule_groups
    WHERE    schedule_group_id = p_schedule_group_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'schedule_group');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Group'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Schedule_Group;

FUNCTION Std_Cost_Adj_Account ( p_std_cost_adj_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_std_cost_adj_account IS NULL OR
        p_std_cost_adj_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     gl_code_combinations
    WHERE    code_combination_id = p_std_cost_adj_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'std_cost_adj_account');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Std_Cost_Adj_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Std_Cost_Adj_Account;

FUNCTION Task ( p_task_id         IN NUMBER,
                p_project_id      IN NUMBER,
                p_organization_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_task_id IS NULL OR
        p_task_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

      SELECT  'VALID'
        INTO     l_dummy
        FROM     pa_tasks_expend_v ptv, mtl_parameters mp
        WHERE    ptv.task_id = p_task_id
        AND      ptv.project_id = p_project_id
        AND      mp.organization_id = p_organization_id
        AND      mp.project_reference_enabled = 1
        AND      mp.project_control_level = 2;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'task');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Task'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Task;


FUNCTION Bom_Reference ( p_bom_reference_id IN NUMBER,
                         p_organization_id  IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_bom_reference_id IS NULL OR
        p_bom_reference_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mtl_system_items
      WHERE    inventory_item_id = p_bom_reference_id
      AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'bom_reference');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Bom_Reference'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Bom_Reference;

FUNCTION Common_Bom_Sequence ( p_common_bom_sequence_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_common_bom_sequence_id IS NULL OR
        p_common_bom_sequence_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     bom_bill_of_materials
    WHERE    bill_sequence_id = p_common_bom_sequence_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'common_bom_sequence');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Common_Bom_Sequence'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Common_Bom_Sequence;

FUNCTION Common_Rout_Sequence ( p_common_rout_sequence_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_common_rout_sequence_id IS NULL OR
        p_common_rout_sequence_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     bom_operational_routings
    WHERE    routing_sequence_id = p_common_rout_sequence_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'common_rout_sequence');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Common_Rout_Sequence'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Common_Rout_Sequence;

FUNCTION Firm_Planned ( p_firm_planned_flag IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_firm_planned_flag IS NULL OR
        p_firm_planned_flag = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mfg_lookups
      WHERE    lookup_type = 'SYS_YES_NO'
      AND      lookup_code = p_firm_planned_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'firm_planned');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Firm_Planned'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Firm_Planned;

FUNCTION Job_Type ( p_job_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_job_type IS NULL OR
        p_job_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mfg_lookups
      WHERE    lookup_type = 'WIP_DISCRETE_JOB'
      AND      lookup_code = p_job_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'job_type');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Job_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Job_Type;

FUNCTION Overcpl_Tolerance_Type ( p_overcpl_tolerance_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_overcpl_tolerance_type IS NULL OR
        p_overcpl_tolerance_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_overcpl_tolerance_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'overcpl_tolerance_type');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Overcpl_Tolerance_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Overcpl_Tolerance_Type;

FUNCTION Routing_Reference ( p_routing_reference_id IN NUMBER,
                             p_organization_id      IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_routing_reference_id IS NULL OR
        p_routing_reference_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mtl_system_items
      WHERE    inventory_item_id = p_routing_reference_id
      AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'routing_reference');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Routing_Reference'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Routing_Reference;

FUNCTION Status_Type ( p_status_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_status_type IS NULL OR
        p_status_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mfg_lookups
      WHERE    lookup_type = 'WIP_JOB_STATUS'
      AND      lookup_code = p_status_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'status_type');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Status_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Status_Type;

FUNCTION Wip_Supply_Type ( p_wip_supply_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_wip_supply_type IS NULL OR
        p_wip_supply_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mfg_lookups
      WHERE    lookup_type = 'WIP_SUPPLY'
      AND      lookup_code = p_wip_supply_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'wip_supply_type');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Wip_Supply_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Wip_Supply_Type;


FUNCTION Repetitive_Schedule ( p_repetitive_schedule_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_repetitive_schedule_id IS NULL OR
        p_repetitive_schedule_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     wip_repetitive_schedules
    WHERE    repetitive_schedule_id = p_repetitive_schedule_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       Wip_Globals.Add_Error_Message(
                                p_message_name  => 'WIP_INVALID_ATTRIBUTE',
                                p_token1_name   => 'ATTRIBUTE',
                                p_token1_value  => 'repetitive_schedule_id');

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Repetitive_Schedule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Repetitive_Schedule;

FUNCTION Acct_Period ( p_acct_period_id  IN NUMBER,
                       p_organization_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_acct_period_id IS NULL OR
        p_acct_period_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     org_acct_periods
      WHERE    acct_period_id = p_acct_period_id
      AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','acct_period');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Acct_Period'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Acct_Period;


FUNCTION Completion_Transaction ( p_completion_transaction_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','completion_transaction');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Completion_Transaction'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Completion_Transaction;
/*
FUNCTION Cost_Group ( p_cost_group_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','cost_group');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Cost_Group'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cost_Group;

FUNCTION Current_Loc_Control ( p_current_loc_control_code IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','current_loc_control');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Current_Loc_Control'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Current_Loc_Control;

FUNCTION Demand ( p_demand_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','demand');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand;

FUNCTION Distribution_Account ( p_distribution_account_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_distribution_account_id IS NULL OR
        p_distribution_account_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_distribution_account_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','distribution_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Distribution_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Distribution_Account;

FUNCTION Encumbrance_Account ( p_encumbrance_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_encumbrance_account IS NULL OR
        p_encumbrance_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_encumbrance_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','encumbrance_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Encumbrance_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Encumbrance_Account;

FUNCTION Encumbrance_Amount ( p_encumbrance_amount IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','encumbrance_amount');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Encumbrance_Amount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Encumbrance_Amount;

FUNCTION Final_Completion ( p_final_completion_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','final_completion');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Final_Completion'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Final_Completion;

FUNCTION Flow_Schedule ( p_flow_schedule IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','flow_schedule');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Flow_Schedule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Flow_Schedule;

FUNCTION Inventory_Item ( p_inventory_item_id IN NUMBER,
                          p_organization_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_inventory_item_id IS NULL OR
        p_inventory_item_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     mtl_system_items
      WHERE    inventory_item_id = p_inventory_item_id
      AND      organization_id = p_organization_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Inventory_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Item;

FUNCTION Item_Description ( p_item_description IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_description');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Description'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Description;

FUNCTION Item_Inventory_Asset ( p_item_inventory_asset_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_inventory_asset');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Inventory_Asset'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Inventory_Asset;

FUNCTION Item_Loc_Control ( p_item_loc_control_code IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_loc_control');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Loc_Control'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Loc_Control;

FUNCTION Item_Lot_Control ( p_item_lot_control_code IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_lot_control');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Lot_Control'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Lot_Control;

FUNCTION Item_Primary_Uom ( p_item_primary_uom_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_item_primary_uom_code IS NULL OR
        p_item_primary_uom_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_item_primary_uom_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_primary_uom');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Primary_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Primary_Uom;

FUNCTION Item_Restrict_Loc ( p_item_restrict_loc_code IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_item_restrict_loc_code IS NULL OR
        p_item_restrict_loc_code = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_item_restrict_loc_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_restrict_loc');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Restrict_Loc'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Restrict_Loc;

FUNCTION Item_Restrict_Subinv ( p_item_restrict_subinv_code IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_item_restrict_subinv_code IS NULL OR
        p_item_restrict_subinv_code = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_item_restrict_subinv_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_restrict_subinv');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Restrict_Subinv'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Restrict_Subinv;

FUNCTION Item_Rev_Qty_Control ( p_item_rev_qty_control_code IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_item_rev_qty_control_code IS NULL OR
        p_item_rev_qty_control_code = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_item_rev_qty_control_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_rev_qty_control');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Rev_Qty_Control'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Rev_Qty_Control;

FUNCTION Item_Segments ( p_item_segments IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_item_segments IS NULL OR
        p_item_segments = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_item_segments;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_segments');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Segments'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Segments;

FUNCTION Item_Serial_Control ( p_item_serial_control_code IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_item_serial_control_code IS NULL OR
        p_item_serial_control_code = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_item_serial_control_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_serial_control');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Serial_Control'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Serial_Control;

FUNCTION Item_Trx_Enabled ( p_item_trx_enabled_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_item_trx_enabled_flag IS NULL OR
        p_item_trx_enabled_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_item_trx_enabled_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_trx_enabled');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Trx_Enabled'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Trx_Enabled;

FUNCTION Item_Uom_Class ( p_item_uom_class IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_item_uom_class IS NULL OR
        p_item_uom_class = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_item_uom_class;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_uom_class');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Uom_Class'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Uom_Class;

FUNCTION Locator ( p_locator_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_locator_id IS NULL OR
        p_locator_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_locator_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','locator');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Locator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Locator;

FUNCTION Locator_Segments ( p_locator_segments IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_locator_segments IS NULL OR
        p_locator_segments = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_locator_segments;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','locator_segments');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Locator_Segments'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Locator_Segments;

FUNCTION Lock_Flag ( p_lock_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_lock_flag IS NULL OR
        p_lock_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_lock_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lock');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lock_Flag;

FUNCTION Lot_Alpha_Prefix ( p_lot_alpha_prefix IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_lot_alpha_prefix IS NULL OR
        p_lot_alpha_prefix = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_lot_alpha_prefix;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lot_alpha_prefix');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lot_Alpha_Prefix'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lot_Alpha_Prefix;

FUNCTION Lot_Expiration_Date ( p_lot_expiration_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_lot_expiration_date IS NULL OR
        p_lot_expiration_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_lot_expiration_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lot_expiration_date');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lot_Expiration_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lot_Expiration_Date;

FUNCTION Material_Alloc_Temp ( p_material_alloc_temp_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_material_alloc_temp_id IS NULL OR
        p_material_alloc_temp_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_material_alloc_temp_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','material_alloc_temp');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Material_Alloc_Temp'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Material_Alloc_Temp;

FUNCTION Negative_Req ( p_negative_req_flag IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_negative_req_flag IS NULL OR
        p_negative_req_flag = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_negative_req_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','negative_req');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Negative_Req'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Negative_Req;

FUNCTION New_Average_Cost ( p_new_average_cost IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_new_average_cost IS NULL OR
        p_new_average_cost = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_new_average_cost;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','new_average_cost');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'New_Average_Cost'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END New_Average_Cost;

FUNCTION Next_Lot_Number ( p_next_lot_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_next_lot_number IS NULL OR
        p_next_lot_number = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_next_lot_number;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','next_lot_number');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Next_Lot_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Next_Lot_Number;

FUNCTION Next_Serial_Number ( p_next_serial_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_next_serial_number IS NULL OR
        p_next_serial_number = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_next_serial_number;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','next_serial_number');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Next_Serial_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Next_Serial_Number;

FUNCTION Number_Of_Lots_Entered ( p_number_of_lots_entered IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_number_of_lots_entered IS NULL OR
        p_number_of_lots_entered = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_number_of_lots_entered;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','number_of_lots_entered');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Number_Of_Lots_Entered'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Number_Of_Lots_Entered;

FUNCTION Overcpl_Primary_Qty ( p_overcpl_primary_qty IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_overcpl_primary_qty IS NULL OR
        p_overcpl_primary_qty = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_overcpl_primary_qty;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','overcpl_primary_qty');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Overcpl_Primary_Qty'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Overcpl_Primary_Qty;

FUNCTION Overcpl_Transaction ( p_overcpl_transaction_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_overcpl_transaction_id IS NULL OR
        p_overcpl_transaction_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_overcpl_transaction_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','overcpl_transaction');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Overcpl_Transaction'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Overcpl_Transaction;

FUNCTION Overcpl_Transaction_Qty ( p_overcpl_transaction_qty IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_overcpl_transaction_qty IS NULL OR
        p_overcpl_transaction_qty = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_overcpl_transaction_qty;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','overcpl_transaction_qty');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Overcpl_Transaction_Qty'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Overcpl_Transaction_Qty;

FUNCTION Pa_Expenditure_Org ( p_pa_expenditure_org_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pa_expenditure_org_id IS NULL OR
        p_pa_expenditure_org_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pa_expenditure_org_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pa_expenditure_org');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pa_Expenditure_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pa_Expenditure_Org;

FUNCTION Percentage_Change ( p_percentage_change IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_percentage_change IS NULL OR
        p_percentage_change = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_percentage_change;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','percentage_change');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Percentage_Change'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Percentage_Change;

FUNCTION Posting ( p_posting_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_posting_flag IS NULL OR
        p_posting_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_posting_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','posting');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Posting'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Posting;

FUNCTION Primary_Switch ( p_primary_switch IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_primary_switch IS NULL OR
        p_primary_switch = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_primary_switch;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_switch');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Primary_Switch'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Primary_Switch;

FUNCTION Process ( p_process_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_process_flag IS NULL OR
        p_process_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_process_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','process');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Process;

FUNCTION Process_Type ( p_process_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_process_type IS NULL OR
        p_process_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_process_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','process_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Process_Type;

FUNCTION Qa_Collection ( p_qa_collection_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qa_collection_id IS NULL OR
        p_qa_collection_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qa_collection_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qa_collection');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qa_Collection'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qa_Collection;

FUNCTION Receiving_Document ( p_receiving_document IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_receiving_document IS NULL OR
        p_receiving_document = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_receiving_document;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','receiving_document');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Receiving_Document'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Receiving_Document;

FUNCTION Repetitive_Line ( p_repetitive_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_repetitive_line_id IS NULL OR
        p_repetitive_line_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_repetitive_line_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','repetitive_line');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Repetitive_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Repetitive_Line;

FUNCTION Required ( p_required_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_required_flag IS NULL OR
        p_required_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_required_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','required');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Required'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Required;

FUNCTION Req_Distribution ( p_req_distribution_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_req_distribution_id IS NULL OR
        p_req_distribution_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_req_distribution_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','req_distribution');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Req_Distribution'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Req_Distribution;

FUNCTION Requisition_Line ( p_requisition_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_requisition_line_id IS NULL OR
        p_requisition_line_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_requisition_line_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','requisition_line');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Requisition_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Requisition_Line;

FUNCTION Reservation_Quantity ( p_reservation_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_reservation_quantity IS NULL OR
        p_reservation_quantity = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_reservation_quantity;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reservation_quantity');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reservation_Quantity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reservation_Quantity;

FUNCTION Revision ( p_revision IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_revision IS NULL OR
        p_revision = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_revision;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Revision'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Revision;

FUNCTION Schedule ( p_schedule_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_schedule_id IS NULL OR
        p_schedule_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_schedule_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','schedule');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Schedule;

FUNCTION Serial_Alpha_Prefix ( p_serial_alpha_prefix IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_serial_alpha_prefix IS NULL OR
        p_serial_alpha_prefix = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_serial_alpha_prefix;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','serial_alpha_prefix');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Serial_Alpha_Prefix'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Serial_Alpha_Prefix;

FUNCTION Serial_Number ( p_serial_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_serial_number IS NULL OR
        p_serial_number = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_serial_number;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','serial_number');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Serial_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Serial_Number;

FUNCTION Source_Project ( p_source_project_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_source_project_id IS NULL OR
        p_source_project_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_source_project_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','source_project');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Source_Project'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Source_Project;

FUNCTION Source_Task ( p_source_task_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_source_task_id IS NULL OR
        p_source_task_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_source_task_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','source_task');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Source_Task'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Source_Task;

FUNCTION Subinventory ( p_subinventory_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_subinventory_code IS NULL OR
        p_subinventory_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_subinventory_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','subinventory');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Subinventory'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Subinventory;

FUNCTION Supply_Locator ( p_supply_locator_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_supply_locator_id IS NULL OR
        p_supply_locator_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_supply_locator_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','supply_locator');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Supply_Locator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Supply_Locator;

FUNCTION Supply_Subinventory ( p_supply_subinventory IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_supply_subinventory IS NULL OR
        p_supply_subinventory = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_supply_subinventory;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','supply_subinventory');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Supply_Subinventory'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Supply_Subinventory;

FUNCTION To_Project ( p_to_project_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_to_project_id IS NULL OR
        p_to_project_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_to_project_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_project');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Project'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Project;

FUNCTION To_Task ( p_to_task_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_to_task_id IS NULL OR
        p_to_task_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_to_task_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_task');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Task'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Task;

FUNCTION Transaction_Action ( p_transaction_action_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_action_id IS NULL OR
        p_transaction_action_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_action_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_action');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Action'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Action;

FUNCTION Transaction_Cost ( p_transaction_cost IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_cost IS NULL OR
        p_transaction_cost = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_cost;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_cost');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Cost'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Cost;

FUNCTION Transaction_Date ( p_transaction_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_date IS NULL OR
        p_transaction_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_date');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Date;

FUNCTION Transaction_Header ( p_transaction_header_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_header_id IS NULL OR
        p_transaction_header_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_header_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_header');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Header;

FUNCTION Transaction_Line_Number ( p_transaction_line_number IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_line_number IS NULL OR
        p_transaction_line_number = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_line_number;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_line_number');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Line_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Line_Number;

FUNCTION Transaction_Mode ( p_transaction_mode IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_mode IS NULL OR
        p_transaction_mode = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_mode;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_mode');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Mode'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Mode;

FUNCTION Transaction_Quantity ( p_transaction_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_quantity IS NULL OR
        p_transaction_quantity = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_quantity;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_quantity');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Quantity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Quantity;

FUNCTION Transaction_Reference ( p_transaction_reference IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_reference IS NULL OR
        p_transaction_reference = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_reference;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_reference');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Reference'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Reference;

FUNCTION Transaction_Sequence ( p_transaction_sequence_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_sequence_id IS NULL OR
        p_transaction_sequence_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_sequence_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_sequence');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Sequence'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Sequence;

FUNCTION Transaction_Source ( p_transaction_source_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_source_id IS NULL OR
        p_transaction_source_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_source_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_source');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Source'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Source;

FUNCTION Transaction_Source_Name ( p_transaction_source_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_source_name IS NULL OR
        p_transaction_source_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_source_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_source_name');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Source_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Source_Name;

FUNCTION Transaction_Src_Type ( p_transaction_src_type_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_src_type_id IS NULL OR
        p_transaction_src_type_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_src_type_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_src_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Src_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Src_Type;

FUNCTION Transaction_Temp ( p_transaction_temp_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_temp_id IS NULL OR
        p_transaction_temp_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_temp_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_temp');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Temp'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Temp;

FUNCTION Transfer_Cost ( p_transfer_cost IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transfer_cost IS NULL OR
        p_transfer_cost = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transfer_cost;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transfer_cost');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transfer_Cost'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transfer_Cost;

FUNCTION Transfer_Organization ( p_transfer_organization IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transfer_organization IS NULL OR
        p_transfer_organization = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transfer_organization;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transfer_organization');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transfer_Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transfer_Organization;

FUNCTION Transfer_Subinventory ( p_transfer_subinventory IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transfer_subinventory IS NULL OR
        p_transfer_subinventory = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transfer_subinventory;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transfer_subinventory');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transfer_Subinventory'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transfer_Subinventory;

FUNCTION Transfer_To_Location ( p_transfer_to_location IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transfer_to_location IS NULL OR
        p_transfer_to_location = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transfer_to_location;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transfer_to_location');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transfer_To_Location'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transfer_To_Location;

FUNCTION Transportation_Account ( p_transportation_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transportation_account IS NULL OR
        p_transportation_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transportation_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transportation_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transportation_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transportation_Account;

FUNCTION Transportation_Cost ( p_transportation_cost IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transportation_cost IS NULL OR
        p_transportation_cost = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transportation_cost;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transportation_cost');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transportation_Cost'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transportation_Cost;

FUNCTION Trx_Source_Delivery ( p_trx_source_delivery_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_trx_source_delivery_id IS NULL OR
        p_trx_source_delivery_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_trx_source_delivery_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','trx_source_delivery');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Trx_Source_Delivery'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Trx_Source_Delivery;

FUNCTION Trx_Source_Line ( p_trx_source_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_trx_source_line_id IS NULL OR
        p_trx_source_line_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_trx_source_line_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','trx_source_line');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Trx_Source_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Trx_Source_Line;

FUNCTION Valid_Locator ( p_valid_locator_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_valid_locator_flag IS NULL OR
        p_valid_locator_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_valid_locator_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','valid_locator');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Valid_Locator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Valid_Locator;

FUNCTION Valid_Subinventory ( p_valid_subinventory_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_valid_subinventory_flag IS NULL OR
        p_valid_subinventory_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_valid_subinventory_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','valid_subinventory');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Valid_Subinventory'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Valid_Subinventory;

FUNCTION Value_Change ( p_value_change IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_value_change IS NULL OR
        p_value_change = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_value_change;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','value_change');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Value_Change'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_Change;

FUNCTION Vendor_Lot_Number ( p_vendor_lot_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_vendor_lot_number IS NULL OR
        p_vendor_lot_number = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_vendor_lot_number;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','vendor_lot_number');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Vendor_Lot_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Vendor_Lot_Number;

FUNCTION Wip_Commit ( p_wip_commit_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_wip_commit_flag IS NULL OR
        p_wip_commit_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_wip_commit_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','wip_commit');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Wip_Commit'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Wip_Commit;

FUNCTION Wip_Entity_Type ( p_wip_entity_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_wip_entity_type IS NULL OR
        p_wip_entity_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_wip_entity_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','wip_entity_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Wip_Entity_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Wip_Entity_Type;

*/
FUNCTION Activity ( p_activity_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_activity_id IS NULL OR
        p_activity_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_activity_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','activity');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Activity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Activity;

FUNCTION Activity_Name ( p_activity_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_activity_name IS NULL OR
        p_activity_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_activity_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','activity_name');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Activity_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Activity_Name;

FUNCTION Actual_Resource_Rate ( p_actual_resource_rate IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_actual_resource_rate IS NULL OR
        p_actual_resource_rate = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_actual_resource_rate;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','actual_resource_rate');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Actual_Resource_Rate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Actual_Resource_Rate;

FUNCTION Autocharge_Type ( p_autocharge_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_autocharge_type IS NULL OR
        p_autocharge_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     MFG_LOOKUPS
      WHERE    lookup_type = 'BOM_AUTOCHARGE_TYPE'
      AND      lookup_code = p_autocharge_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','autocharge_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Autocharge_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Autocharge_Type;

FUNCTION Basis_Type ( p_basis_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_basis_type IS NULL OR
        p_basis_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     MFG_LOOKUPS
      WHERE    lookup_type = 'CST_BASIS'
      AND      lookup_code = p_basis_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','basis_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Basis_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Basis_Type;

FUNCTION Created_By_Name ( p_created_by_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_created_by_name IS NULL OR
        p_created_by_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     fnd_user
    WHERE    user_name = p_created_by_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','created_by_name');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Created_By_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Created_By_Name;

FUNCTION Currency ( p_currency_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency;

FUNCTION Currency_Conversion_Date ( p_currency_conversion_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_conversion_date');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency_Conversion_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency_Conversion_Date;

FUNCTION Currency_Conversion_Rate ( p_currency_conversion_rate IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_conversion_rate');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency_Conversion_Rate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency_Conversion_Rate;

FUNCTION Currency_Conversion_Type ( p_currency_conversion_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_conversion_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency_Conversion_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency_Conversion_Type;

FUNCTION Currency_Actual_Rsc_Rate ( p_currency_actual_rsc_rate IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_currency_actual_rsc_rate IS NULL OR
        p_currency_actual_rsc_rate = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_currency_actual_rsc_rate;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_actual_rsc_rate');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency_Actual_Rsc_Rate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency_Actual_Rsc_Rate;

FUNCTION Department_Code ( p_department_code IN VARCHAR2,
                      p_organization_id IN NUMBER,
                      p_attribute_name  IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

   IF p_department_code IS NULL OR
      p_department_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;


   SELECT     'VALID'
     INTO     l_dummy
     FROM     bom_departments
     WHERE    department_code = p_department_code
     AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE', nvl(p_attribute_name,'Department_Code'));
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Department_Code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Department_Code;

FUNCTION Department_Id ( p_department_id  IN NUMBER,
                         p_attribute_name IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

   IF p_department_id IS NULL OR
      p_department_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;


   SELECT     'VALID'
     INTO     l_dummy
     FROM     bom_departments
     WHERE    department_id = p_department_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',nvl(p_attribute_name,'Department_Id'));
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Department_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Department_Id;

FUNCTION Employee ( p_employee_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','employee_code');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Employee'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Employee;

FUNCTION Employee_Num ( p_employee_num IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_employee_num IS NULL OR
        p_employee_num = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_employee_num;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','employee_num');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Employee_Num'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Employee_Num;

FUNCTION Group_Id ( p_group_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_group_id IS NULL OR
        p_group_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_group_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','group');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Group'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Group_Id;

FUNCTION Last_Updated_By_Name ( p_last_updated_by_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_last_updated_by_name IS NULL OR
        p_last_updated_by_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     fnd_user
    WHERE    user_name = p_last_updated_by_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','last_updated_by_name');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Updated_By_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Updated_By_Name;

FUNCTION Move_Transaction ( p_move_transaction_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','move_transaction');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Move_Transaction'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Move_Transaction;

FUNCTION Operation_Seq_Num ( p_operation_seq_num IN NUMBER ,
                             p_attribute_name    IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',nvl(p_attribute_name,'Operation_Seq_Num'));
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Operation_Seq_Num'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Operation_Seq_Num;

FUNCTION Po_Header ( p_po_header_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_po_header_id IS NULL OR
        p_po_header_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     po_headers_all
    WHERE    po_header_id = p_po_header_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','po_header');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Po_Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Po_Header;

FUNCTION Po_Line ( p_po_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_po_line_id IS NULL OR
        p_po_line_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     po_lines_all
    WHERE    po_line_id = p_po_line_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','po_line');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Po_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Po_Line;

FUNCTION Primary_Quantity ( p_primary_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_quantity');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Primary_Quantity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Primary_Quantity;

FUNCTION Primary_Uom ( p_primary_uom IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_primary_uom IS NULL OR
        p_primary_uom = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     mtl_units_of_measure
    WHERE    uom_code = p_primary_uom;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_uom');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Primary_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Primary_Uom;

FUNCTION Primary_Uom_Class ( p_primary_uom_class IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_primary_uom_class IS NULL OR
        p_primary_uom_class = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_primary_uom_class;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_uom_class');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Primary_Uom_Class'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Primary_Uom_Class;

FUNCTION Process_Phase ( p_process_phase IN NUMBER,
                         p_lookup_type IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_process_phase IS NULL OR
        p_process_phase = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     MFG_LOOKUPS
      WHERE    lookup_type = p_lookup_type
      AND      lookup_code = p_process_phase;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','process_phase');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Phase'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Process_Phase;

FUNCTION Process_Status ( p_process_status IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_process_status IS NULL OR
        p_process_status = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     MFG_LOOKUPS
      WHERE    lookup_type = 'WIP_PROCESS_STATUS'
      AND      lookup_code = p_process_status;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','process_status');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Status'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Process_Status;

FUNCTION Project_Number ( p_project_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_project_number IS NULL OR
        p_project_number = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_project_number;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','project_number');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Project_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Project_Number;

FUNCTION Rcv_Transaction ( p_rcv_transaction_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_rcv_transaction_id IS NULL OR
        p_rcv_transaction_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     dual
    WHERE exists (select 'EXISTS'
                  from rcv_transactions_interface rti
                  where rti.interface_transaction_id = p_rcv_transaction_id)
      OR  exists (select 'EXISTS'
                  from rcv_transactions rt
                  where rt.transaction_id = p_rcv_transaction_id);

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rcv_transaction');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rcv_Transaction'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rcv_Transaction;

FUNCTION Reason ( p_reason_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reason');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reason;

FUNCTION Reason_Name ( p_reason_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_reason_name IS NULL OR
        p_reason_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_reason_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reason_name');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reason_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reason_Name;

FUNCTION Receiving_Account ( p_receiving_account_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','receiving_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Receiving_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Receiving_Account;

FUNCTION Reference ( p_reference IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reference');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reference'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reference;

FUNCTION Resource_Code ( p_resource_code IN VARCHAR2,
                         p_organization_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_resource_code IS NULL OR
        p_resource_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     bom_resources
    WHERE    resource_code = p_resource_code
    AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','resource_code');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Resource'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Resource_Code;

FUNCTION Resource_Id ( p_resource_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_resource_id IS NULL OR
        p_resource_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

   SELECT  'VALID'
     INTO     l_dummy
     FROM     bom_resources
     WHERE    resource_id = p_resource_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','resource');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Resource'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Resource_Id;

FUNCTION Resource_Seq_Num ( p_resource_seq_num IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_resource_seq_num IS NULL OR
        p_resource_seq_num = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_resource_seq_num;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','resource_seq_num');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Resource_Seq_Num'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Resource_Seq_Num;

FUNCTION Resource_Type ( p_resource_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_resource_type IS NULL OR
        p_resource_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     MFG_LOOKUPS
      WHERE    lookup_type = 'BOM_RESOURCE_TYPE'
      AND      lookup_code = p_resource_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','resource_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Resource_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Resource_Type;

FUNCTION Standard_Rate ( p_standard_rate_flag IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_standard_rate_flag IS NULL OR
        p_standard_rate_flag = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
      INTO     l_dummy
      FROM     MFG_LOOKUPS
      WHERE    lookup_type = 'SYS_YES_NO'
      AND      lookup_code = p_standard_rate_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','standard_rate');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Standard_Rate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Standard_Rate;

FUNCTION Task_Number ( p_task_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_task_number IS NULL OR
        p_task_number = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_task_number;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','task_number');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Task_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Task_Number;

FUNCTION Transaction ( p_transaction_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_id IS NULL OR
        p_transaction_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction;

FUNCTION Usage_Rate_Or_Amount ( p_usage_rate_or_amount IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_usage_rate_or_amount IS NULL OR
        p_usage_rate_or_amount = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_usage_rate_or_amount;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','usage_rate_or_amount');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Usage_Rate_Or_Amount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Usage_Rate_Or_Amount;

/*
FUNCTION Fm_Department_Code ( p_fm_department_code IN VARCHAR2,
                         p_organization_id    IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_fm_department_code IS NULL OR
        p_fm_department_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     bom_departments
    WHERE    department_code = p_fm_department_code
    AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fm_department_code');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Fm_Department_code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fm_Department_Code;
*/
/*
FUNCTION Fm_Department_Id ( p_fm_department_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_fm_department_id IS NULL OR
        p_fm_department_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     bom_departments
    WHERE    department_id = p_fm_department_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fm_department_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Fm_Department_id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fm_Department_Id;
*/

FUNCTION Intraop_Step_Type ( p_intraop_step_type IN NUMBER,
                             p_attribute_name       IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_intraop_step_type IS NULL OR
        p_intraop_step_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     mfg_lookups ml
    WHERE    ml.lookup_code = p_intraop_step_type
    AND      ml.lookup_type = 'WIP_INTRAOPERATION_STEP';

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',nvl(p_attribute_name,'Intraop_Step_Type'));
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Intraop_Step_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Intraop_Step_Type;

FUNCTION Operation_Code ( p_operation_code IN VARCHAR2,
                          p_attribute_name IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_operation_code IS NULL OR
        p_operation_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;


    SELECT  'VALID'
    INTO     l_dummy
    FROM     bom_standard_operations
    WHERE    operation_code = p_operation_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',nvl(p_attribute_name,'Operation_Code'));
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Operation_Code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Operation_Code;

/*
FUNCTION Operation_Seq_Num ( p_operation_seq_num IN NUMBER
                             p_attribute_name    IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_operation_seq_num IS NULL OR
        p_operation_seq_num = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_fm_operation_seq_num;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_attribute_name);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Operation_Seq_Num'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Operation_Seq_Num;
*/

FUNCTION Kanban ( p_kanban_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_kanban_id IS NULL OR
        p_kanban_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_kanban_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','kanban');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Kanban'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Kanban;

FUNCTION Overcompletion ( p_overcompletion_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_overcompletion_flag IS NULL OR
        p_overcompletion_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_overcompletion_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','overcompletion');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Overcompletion'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Overcompletion;

FUNCTION Overmove_Txn_Qty ( p_overmove_txn_qty IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_overmove_txn_qty IS NULL OR
        p_overmove_txn_qty = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_overmove_txn_qty;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','overmove_txn_qty');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Overmove_Txn_Qty'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Overmove_Txn_Qty;

FUNCTION Scrap_Account ( p_scrap_account_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_scrap_account_id IS NULL OR
        p_scrap_account_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     gl_code_combinations
    WHERE    code_combination_id = p_scrap_account_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','scrap_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Scrap_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Scrap_Account;

/*
FUNCTION To_Department_Code ( p_to_department_code IN VARCHAR2 ,
                              p_organization_id    IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_to_department_code IS NULL OR
        p_to_department_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     bom_departments
    WHERE    department_code = p_to_department_code
    AND      organization_id = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_department_code');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Department_Code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Department_Code;
*/

/*
FUNCTION To_Department_Id ( p_to_department_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_to_department_id IS NULL OR
        p_to_department_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     bom_departments
    WHERE    department_id = p_to_department_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_department_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Department_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Department_Id;
*/

/*
FUNCTION To_Intraop_Step_Type ( p_to_intraop_step_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_to_intraop_step_type IS NULL OR
        p_to_intraop_step_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     mfg_lookups ml
    WHERE    ml.lookup_code = p_to_intraop_step_type
    AND      ml.lookup_type = 'WIP_INTRAOPERATION_STEP';

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_intraop_step_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Intraop_Step_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Intraop_Step_Type;
*/

FUNCTION To_Operation ( p_to_operation_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_to_operation_code IS NULL OR
        p_to_operation_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     bom_standard_operations
    WHERE    operation_code = p_to_operation_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_operation_code');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Operation'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Operation;

FUNCTION To_Operation_Seq_Num ( p_to_operation_seq_num IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_to_operation_seq_num IS NULL OR
        p_to_operation_seq_num = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_to_operation_seq_num;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_operation_seq_num');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Operation_Seq_Num'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Operation_Seq_Num;

FUNCTION Transaction_Link ( p_transaction_link_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_link_id IS NULL OR
        p_transaction_link_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_transaction_link_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_link');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Link'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Link;

FUNCTION Transaction_Type ( p_transaction_type_id IN NUMBER,
                            p_lookup_type IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_type_id IS NULL OR
        p_transaction_type_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     mfg_lookups ml
    WHERE    ml.lookup_code = p_transaction_type_id
    AND      ml.lookup_type = p_lookup_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Type;

FUNCTION Transaction_Uom ( p_transaction_uom IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transaction_uom IS NULL OR
        p_transaction_uom = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     mtl_units_of_measure
    WHERE    uom_code = p_transaction_uom;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_uom');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Uom;


--  END GEN validate

END WIP_Validate;

/
